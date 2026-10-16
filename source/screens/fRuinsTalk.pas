unit fRuinsTalk;

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

  TResearchItemSortKey = record // @size $0C
    Priority: Byte; // @offset $00
    Cost: Integer; // @offset $04
    Weight: Integer; // @offset $08
  end;
  TResearchItemVisited = array of Boolean;
  TResearchItemIndexes = array of Integer;

  TfRuinsTalk = class(TMessageLoopGIWithMainPanel) // @size 0x10C
  public
    StationPanel: TfPanelRuins; // @offset $D4 Owned.
    LoadPanel: TfPanelLoad; // @offset $D8 Owned.
    DialogText: WideString; // @offset 0xDC
    PresentedTextLength: Integer; // @offset $E0
    TextPresentationTimer: TCallbackTimerIdGI; // @offset $E4
    ChoiceHeight: Integer; // @offset $E8 Accumulated dialogue-choice row height.
    NextPortraitCycleAlternate: Boolean; // @offset $EC
    ShowArrivalVideo: Boolean; // @offset $ED Set after docked hyperspace travel; OnOpen tests this together with SkipVideo.
    StationOwner: TOwnerId; // @offset $EE Copied from the docked ship on entry.
    StationType: TStationType; // @offset $EF Copied from the docked ship on entry.
    ScriptVideoStartedAt: Cardinal; // @offset $F0 timeGetTime timestamp used by the queued-video callback.
    ScriptVideoTimer: TCallbackTimerIdGI; // @offset $F4
    ResearchItemVisited: array of Boolean; // @offset $F8
    ResearchItemIndexes: array of Integer; // @offset $FC Negative entries terminate the sorted sale list.
    LargePortraitLayout: Boolean; // @offset $100 Viewport is at least 1280x960; permits HD portraits or the table layout.
    PortraitTableVisible: Boolean; // @offset $101 Large layout with UseTablesForGov; shows the table and standard portrait animations.
    StationTransientControl: TObjectGI; // @offset $104
    SavedChoiceScroll: Integer; // @offset $108

    function SortResearchItems(Series: TDominatorSeries): Integer; // @addr $559080 Returns inventory count; unused sorted slots are -1.
    function IsResearchItemQuestLetter(Item: TItem): Boolean; // @addr $5591D4
    function CountResearchRemains(Series: TDominatorSeries; Count: Integer): Integer; // @addr $559314
    function CountResearchEquipment(Count: Integer): Integer; // @addr $5593A4
    procedure BuildResearchItemChoices(Series: TDominatorSeries; var Text: WideString); // @addr $559410
    procedure ContinueDominatorVictoryDialog(Action: Cardinal); // @addr $55BFD8
    function ShowDominatorVictoryDialog: Boolean; // @addr $55B818
    procedure ShowMilitaryBaseRepairQuote(Action: Cardinal); // @addr $56CBB0
    procedure AcceptMilitaryBaseRepair(Action: Cardinal); // @addr $56CFE4
    procedure AcceptMilitaryBasePrograms(Action: Cardinal); // @addr $56D554
    procedure AcceptMilitaryBaseWarOperation(Action: Cardinal); // @addr $56DA68
    procedure ConfirmMilitaryBaseTravel(Action: Cardinal); // @addr $56E1D8
    procedure DeclineMilitaryBaseTravel(Action: Cardinal); // @addr $56E76C
    procedure ShowMilitaryBaseArrivalInfo(Action: Cardinal); // @addr $56E8F4
    procedure ShowMilitaryBaseArrivalQuestions(Action: Cardinal); // @addr $56ED0C
    procedure ShowMilitaryBaseArrivalDialog(Action: Integer); // @addr $56E52C
    procedure RunInjectedDialog(Action: Cardinal); // @addr $580AD0
    procedure RunInjectedDialogKeepingScroll(Action: Cardinal); // @addr $580C6C
    procedure AdvanceTextPresentation(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $55A5D0
    procedure PortraitCycleComplete(Sender: TObjectGI); // @addr $55A9C0
    procedure SelectPortraitAnimation(Alternate: Boolean); // @addr $55A9EC
    procedure ShowDominionWarOperationDialog(Action: Cardinal); // @addr $5888BC
    procedure ShowDominionRelocationDialog(Action: Cardinal); // @addr $586A04
    procedure ShowDominionAmbushDialog(Action: Cardinal); // @addr $589688
    procedure ShowDominionAssaultDialog(Action: Cardinal); // @addr $58A358
    procedure ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $55A3F8
    procedure ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $55A458
    function CreateChoiceBullet(LabelControl: TLabelGI; Item: PFontObjectEC): TObjectGI; // @addr $55AC10
    constructor Create; // @addr $55749C
    destructor Destroy; override; // @addr $5574F8
    procedure AdvanceScriptVideo(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $55B0E0 Advances Film over the native 138-second interval.

    procedure OnClose; override; // @addr $558EA8
    procedure EndTurnClicked(Sender: TObjectGI); // @addr $559988
    procedure ShipClicked(Sender: TObjectGI); // @addr $559BF4
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $55ACE0
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $55ADA8
    procedure AddMessageClicked(Sender: TObjectGI); // @addr $55AF7C
    procedure SelectMusic; override; // @addr $55B29C
    procedure InitializeLayout; override; // @addr $557774
    procedure LayoutStationPortrait(Panel: TObjectGI); // @addr $557E2C
    procedure OnOpen; override; // @addr 0x005582FC @note "Native diagnostic name: TfRuinsTalk.BeforeRun."
    procedure DepartWithStation(Action: Cardinal); // @addr $56E494
    procedure ClearChoices; // @addr $559CAC Native diagnostic name: TfRuinsTalk.A_Start.
    procedure RestartTextPresentation; // @addr $55A550 Clears the dialogue panel state and restarts its ten-millisecond presentation timer.
    procedure I_Start; // @addr 0x0055B660 Rebuilds the station dialogue root.
    procedure M_Main(KeepText: Boolean); // @addr 0x0055BFF0 Rebuilds choices; KeepText preserves the current greeting and skips rank rewards.
    procedure I_WarWithKlingAndPirates(Action: Cardinal); // @addr 0x0056BBC0
    procedure I_CBWarWithKlingAndCoalition(Action: Cardinal); // @addr 0x005879E8
    procedure AddChoice(CaptionText: WideString; Value: Cardinal; Callback: TDialogChoiceEventGI); // @addr 0x00559E88 @note "Text filters may disable or suppress the choice. Invokes the method callback with Value in EDX."
    procedure ShowBridgeBlackHoleDialog(Action: Cardinal); // @addr $55F034
    procedure ShowInterceptorDialog(Action: Cardinal); // @addr $55F3F8
    procedure SelectBridgeBlackHoleDestination(Action: Cardinal); // @addr $55F368
    procedure RecallInterceptorsFromTarget(Action: Cardinal); // @addr $5606C4
    procedure RecallAllInterceptors(Action: Cardinal); // @addr $5606F4
    procedure IncreaseInterceptorPassCount(Action: Cardinal); // @addr $560C5C
    procedure DecreaseInterceptorPassCount(Action: Cardinal); // @addr $560C88
    procedure SelectInterceptorTarget(Action: Cardinal); // @addr $5610CC
    procedure ClearInterceptorTarget(Action: Cardinal); // @addr $5610EC
    procedure SelectInterceptorStrategy(Action: Cardinal); // @addr $5618E0
    procedure ShowBridgeHelpAnswer(Action: Cardinal); // @addr $561ADC
    procedure ShowInterceptorTargetDialog(Action: Cardinal); // @addr $560CB4
    procedure ShowInterceptorStrategyDialog(Action: Cardinal); // @addr $56110C
    procedure ShowActiveInterceptors(Action: Cardinal); // @addr $560248
    procedure ShowInterceptorPassDialog(Action: Cardinal); // @addr $560784
    procedure ShowBridgeHelp(Action: Cardinal); // @addr $561904
    procedure BuyRangerCenterMicroModule(Action: Cardinal); // @addr $565E00
    procedure ExchangeMicroModuleForNodes(Action: Cardinal); // @addr $566CA0
    procedure ShowRangerCenterTakeNodeDialog(Action: Cardinal); // @addr $565200
    procedure ShowRangerCenterGiveNodeDialog(Action: Cardinal); // @addr $566228
    procedure AcceptPirateBaseNationality(Action: Cardinal); // @addr $567AF8
    procedure BuyPirateBaseNodes(Action: Cardinal); // @addr $56940C
    procedure BuyPirateBaseProgram(Action: Cardinal); // @addr $569E50
    procedure AcceptPirateBaseRepair(Action: Cardinal); // @addr $56A75C
    procedure BuyPirateBaseChameleon(Action: Cardinal); // @addr $56B970
    procedure ShowPirateBaseProgramDialog(Action: Cardinal); // @addr $5696F8
    procedure ShowPirateBaseNodeDialog(Action: Cardinal); // @addr $568EE0
    procedure ShowPirateBaseRepairDialog(Action: Cardinal); // @addr $56A168
    procedure ShowPirateBaseChameleonDialog(Action: Cardinal); // @addr $56B40C
    procedure ConfirmPirateBaseSubCrack(Action: Cardinal); // @addr $56ACB4
    procedure BuyPirateBaseSubCrack(Action: Cardinal); // @addr $56AFD8
    procedure BuyPirateBaseSubCrackHalfPrice(Action: Cardinal); // @addr $56B16C
    procedure DeclinePirateBaseSubCrack(Action: Cardinal); // @addr $56B308
    procedure DeclinePirateBaseNationality(Action: Cardinal); // @addr $5683BC
    procedure DeclinePirateBaseSideChange(Action: Cardinal); // @addr $568D8C
    procedure DeclinePirateBaseProgram(Action: Cardinal); // @addr $56A044
    procedure DeclinePirateBaseRepair(Action: Cardinal); // @addr $56AA24
    procedure DeclinePirateBaseChameleon(Action: Cardinal); // @addr $56BA94
    procedure ShowPirateBaseSubCrackDialog(Action: Cardinal); // @addr $56AAC8
    procedure ShowMilitaryBaseRepairDialog(Action: Cardinal); // @addr $56CA2C
    procedure ShowMilitaryBaseWarOperationDialog(Action: Cardinal); // @addr $56D664
    procedure ShowMilitaryBaseTravelDialog(Action: Cardinal); // @addr $56E098
    procedure ShowMilitaryBaseProgramsDialog(Action: Cardinal); // @addr $56D17C
    procedure ShowScienceBaseImprovementItems(Action: Cardinal); // @addr $56EF88
    procedure ShowScienceBaseImprovementQuote(Action: Cardinal); // @addr $56F700
    procedure SelectScienceBaseImprovementKind(Action: Cardinal); // @addr $56FFBC
    procedure AcceptScienceBaseImprovement(Action: Cardinal); // @addr $570334
    procedure ShowScienceBaseRepairQuote(Action: Cardinal); // @addr $5709B0
    procedure AcceptScienceBaseRepair(Action: Cardinal); // @addr $571008
    procedure ShowScienceBaseImprovementDialog(Action: Cardinal); // @addr $56EE54
    procedure ShowScienceBaseRepairDialog(Action: Cardinal); // @addr $57082C
    procedure SellResearchRemains(Action: Cardinal); // @addr $57266C
    procedure SellResearchEquipment(Action: Cardinal); // @addr $572C3C
    procedure SellResearchItem(Action: Cardinal); // @addr $5731F0
    procedure SelectScienceBaseResearchSection(Action: Cardinal); // @addr $5722CC
    procedure DeclineScienceBaseResearch(Action: Cardinal); // @addr $57376C
    procedure AcceptScienceBaseResearchProgram(Action: Cardinal); // @addr $573CF4
    procedure DeclineScienceBaseResearchProgram(Action: Cardinal); // @addr $573EF8
    procedure ShowScienceBaseResearchDialog(Action: Cardinal); // @addr $571C40
    procedure BuyScienceBaseResearchProgram(Action: Cardinal); // @addr $573964
    procedure ShowScienceBaseHistoryDialog(Action: Cardinal); // @addr $574004
    procedure AcceptBusinessCenterInvestment(Action: Cardinal); // @addr $579DC4
    procedure DeclineBusinessCenterInvestment(Action: Cardinal); // @addr $57BD54
    procedure ShowBusinessCenterInvestmentDialog(Action: Cardinal); // @addr $576ACC
    procedure BuyBusinessCenterTradeAdvice(Action: Cardinal); // @addr $57CA28
    procedure DeclineBusinessCenterTradeAdvice(Action: Cardinal); // @addr $57CF24
    procedure ShowBusinessCenterTradeDialog(Action: Cardinal); // @addr $57BE60
    procedure ShowDominionImprovementItems(Action: Cardinal); // @addr $583844
    procedure ShowDominionImprovementQuote(Action: Cardinal); // @addr $583FBC
    procedure AcceptDominionImprovement(Action: Cardinal); // @addr $584554
    procedure BuyDominionPirateLicense(Action: Cardinal); // @addr $584E88
    procedure DeclineDominionPirateLicense(Action: Cardinal); // @addr $585024
    function CheckDominionServiceStanding(RequiredRank: TShipRank; Prefix: WideString; CreditCost: Single): Boolean; // @addr $5851E8
    procedure SpendDominionServiceCredit(CreditCost: Single); // @addr $5854DC
    function CheckDominionAvailable: Boolean; // @addr $585568
    procedure ConfirmDominionTravel(Action: Cardinal); // @addr $585F70
    procedure AcceptDominionTravel(Action: Cardinal); // @addr $5862C0
    procedure DeclineDominionCancelTravel(Action: Cardinal); // @addr $5867E0
    procedure AcceptDominionRelocation(Action: Cardinal); // @addr $587118
    procedure AcceptDominionWarOperation(Action: Cardinal); // @addr $588CD8
    procedure AcceptDominionAmbush(Action: Cardinal); // @addr $58A044
    procedure AcceptDominionAssault(Action: Cardinal); // @addr $58AA50
    procedure ShowDominionImprovementDialog(Action: Cardinal); // @addr $583710
    procedure BuyStationSpecialShip(Action: Cardinal); // @addr $580774
    procedure DeclineStationSpecialShip(Action: Cardinal); // @addr $580698
    procedure ShowStationSpecialShipDialog(Action: Cardinal); // @addr $57FA8C
    procedure BuildBuiltinServiceOptions; // @addr 0x00561DB0
    procedure OpenStationModernization(QuotedCost: Cardinal); // @addr 0x005649AC @note "Zero requests a quote; a nonzero quote is charged and enables sponsorship. Sponsored stations open the equipment-refit screen."
    procedure DeclineStationModernization(Action: Cardinal); // @addr $564E5C
    procedure ShowRangerCenterNodeInfoContinuation(Action: Cardinal); // @addr $5671B4
    procedure DepositNodesAtRangerCenter(Action: Cardinal); // @addr 0x00565024 @note "Deposits every carried node stack."
    procedure ShowRangerCenterNodeInfo(Action: Cardinal); // @addr 0x00567018
    procedure ShowPirateBaseNationalityDialog(Action: Cardinal); // @addr 0x005674C4
    procedure ShowPirateBaseSideChangeDialog(Action: Cardinal); // @addr 0x00568508
    procedure AcceptPirateBaseSideChange(Action: Cardinal); // @addr 0x00568920 @note "Recalculates the fee at acceptance time."
    procedure ShowMilitaryBaseNextRankDialog(Action: Cardinal); // @addr 0x0056C5C0 @note "Does not promote the player."
    procedure ShowScienceBaseSatelliteOfferDialog(Refresh: Cardinal); // @addr 0x00571294
    procedure BuyScienceBaseSatellite(Action: Cardinal); // @addr 0x005719E4 @note "Transfers the existing SatelliteOffer into inventory."
    procedure ShowBusinessCenterPolicyDetails(Action: Cardinal); // @addr $576840
    procedure DeclineBusinessCenterPolicy(Action: Cardinal); // @addr $576948
    procedure ShowBusinessCenterDebtDialog(Action: Cardinal); // @addr 0x00574394
    procedure AcceptBusinessCenterDebtQuote(Quote: Cardinal); // @addr 0x005750B8 @note "Quotes 1/2/3 use the large/medium/small principal, with 20/15/10 percent interest included in DebtAmount."
    procedure DeclineBusinessCenterDebtDialog(Action: Cardinal); // @addr 0x00575464
    procedure RepayBusinessCenterDebt(Action: Cardinal); // @addr 0x00575560 @note "Requires the menu's prior affordability check."
    procedure ShowBusinessCenterDepositDialog(Action: Cardinal); // @addr 0x00575698
    procedure AcceptBusinessCenterDepositQuote(Quote: Cardinal); // @addr 0x00575CF4 @note "Quotes 1/2/3 select large/medium/small amounts; a new deposit resets accrued days."
    procedure DeclineBusinessCenterDepositDialog(Action: Cardinal); // @addr 0x00575FAC
    procedure WithdrawBusinessCenterDeposit(Action: Cardinal); // @addr 0x005760A8
    procedure ShowBusinessCenterMedicalPolicyDialog(Refresh: Cardinal); // @addr 0x005762C0
    procedure BuyBusinessCenterMedicalPolicy(Action: Cardinal); // @addr 0x00576630 @note "Policy duration is 1825 ticks."
    procedure DeclineMedicalCenterTreatment(Action: Cardinal); // @addr $57E4DC
    procedure LeaveMedicalCenterTreatment(Action: Cardinal); // @addr $57E5DC
    procedure DeclineMedicalCenterStimulants(Action: Cardinal); // @addr $57F8E8
    procedure ShowMedicalCenterIllnessTreatmentDialog(Refresh: Cardinal); // @addr 0x0057D01C
    procedure TreatSelectedDiseaseAtMedicalCenter(DiseaseIndex: Cardinal); // @addr 0x0057DE70 @note "Treats disease indexes 1..12; valid insurance halves the fee outside pirate-owned systems."
    procedure TreatAllDiseasesAtMedicalCenter(QuotedCost: Cardinal); // @addr 0x0057E264 @note "Trusts QuotedCost from the menu."
    procedure ShowMedicalCenterStimulantDialog(Action: Cardinal); // @addr 0x0057E778
    procedure BuySelectedStimulantAtMedicalCenter(StimulantIndex: Cardinal); // @addr 0x0057F514 @note "Stimulants use effect indices 13..24; valid insurance halves the fee outside pirate-owned systems."
    function BuildConstructionItemChoices(Kind: TItemType): Integer; // @addr $58135C
    procedure ConfirmDominionConstructionLimit(Action: Cardinal); // @addr $581B2C
    procedure SelectConstructionHeldItem(Action: Cardinal); // @addr $581D00
    procedure SelectConstructionStoredItem(Action: Cardinal); // @addr $581D70
    procedure SelectConstructionShopItem(Action: Cardinal); // @addr $581DE0
    procedure SkipConstructionItem(Action: Cardinal); // @addr $581E50
    procedure AppendConstructionItemList; // @addr $581E58
    procedure ContinueDominionConstruction(PreviousItem: WideString); // @addr $5823A4
    procedure PickConstructionWeapon(Action: Cardinal); // @addr $582D2C
    procedure PickConstructionRadar(Action: Cardinal); // @addr $582E18
    procedure PickConstructionScanner(Action: Cardinal); // @addr $582F04
    procedure PickConstructionRepairRobot(Action: Cardinal); // @addr $582FF0
    procedure PickConstructionDefGenerator(Action: Cardinal); // @addr $5830E8
    procedure CompleteDominionConstruction(Action: Cardinal); // @addr $5832B8
    procedure ShowDominionShipConstructionDialog(Action: Cardinal); // @addr 0x00581898
    procedure ShowDominionPirateLicenseDialog(Action: Cardinal); // @addr 0x00584954
    procedure ShowDominionTravelDialog(Action: Cardinal); // @addr 0x00585708
    procedure ShowDominionCancelTravelDialog(Action: Cardinal); // @addr 0x00586538
    procedure CancelDominionTravel(Action: Cardinal); // @addr 0x0058670C
    procedure AddScriptTakeoffChoice(Caption: WideString); // @addr $5644A8
    procedure ContinueScriptDialog; // @addr $564484
    procedure AddScriptNewsExitChoice(Caption: WideString); // @addr $56459C
    procedure AddScriptGameEndChoice(Caption: WideString); // @addr $564728
    procedure AddScriptHangarChoice(Caption: WideString); // @addr $564620
    procedure AddScriptRestartChoice(Caption: WideString); // @addr $580CB4
    procedure AddScriptGoodsChoice(Caption: WideString); // @addr $5646A4
    procedure RunScriptAnswerKeepingScroll(Answer: Cardinal); // @addr $564838
    procedure RunScriptAnswer(Answer: Cardinal); // @addr $5647D4

    procedure RememberChoiceScroll; // @addr $559C68
    procedure HideStationTransientControl; // @addr $5582E8
    procedure ChoiceMouseEnter(Sender: TObjectGI); // @addr $55A3E0
    procedure ChoiceMouseLeave(Sender: TObjectGI); // @addr $55A3EC
    procedure ResetPortraitCycle; // @addr $55A9B8
    procedure SelectScriptDialog(ScriptValue: Cardinal); // @addr $5647AC @note "Choice callback value carries a TScript pointer."
    procedure RunScriptNewsExit(Answer: Cardinal); // @addr $564904
    procedure RunScriptHangar(Answer: Cardinal); // @addr $564924
    procedure RunScriptGoods(Answer: Cardinal); // @addr $564954
    procedure OpenHangar(Action: Cardinal); // @addr $564944
    procedure RunScriptGameEnd(Answer: Cardinal); // @addr $564974
    procedure ReturnToMain(Action: Cardinal); // @addr $5649A4
    procedure RunScriptRestart(Answer: Cardinal); // @addr $580C88
    procedure RunScriptTakeoff(Answer: Cardinal); // @addr $564854
    procedure CloseHullMode(Action: Cardinal); // @addr $55EFC8
    procedure CloseRuinsMode(Sender: TObjectGI); // @addr $580D38
    procedure ToggleImpulseShields(Action: Cardinal); // @addr $55EFD4
    function StopScriptVideo(Unused: Boolean): Boolean; // @addr $55B190
    procedure ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer); override; // @addr $55B24C
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr $58ACF8
    procedure DeclineRangerCenterNodeDeposit(Action: Cardinal); // @addr $56617C
    procedure DeclineRangerCenterNodeReward(Action: Cardinal); // @addr $566F7C
    procedure ShowRangerCenterRatingAnswer(Action: Cardinal); // @addr $5672E0
    procedure ShowRangerCenterPirateClanAnswer(Action: Cardinal); // @addr $56737C
    procedure ShowRangerCenterBestRangerAnswer(Action: Cardinal); // @addr $567420
    procedure DeclinePirateBaseNodes(Action: Cardinal); // @addr $569658
    procedure DeclineMilitaryBaseRepair(Action: Cardinal); // @addr $56D0E0
    procedure DeclineMilitaryBaseWarOperation(Action: Cardinal); // @addr $56DFF0
    procedure DeclineScienceBaseImprovement(Action: Cardinal); // @addr $56F648
    procedure DeclineScienceBaseRepeatImprovement(Action: Cardinal); // @addr $570774
    procedure DeclineScienceBaseRepair(Action: Cardinal); // @addr $5711F8
    procedure ShowSatelliteInstructions(Action: Cardinal); // @addr $571934
    procedure DeclineScienceBaseSatellite(Action: Cardinal); // @addr $571B9C
    procedure DeclineDominionShipConstruction(Action: Cardinal); // @addr $581BE0
    procedure DeclineDominionImprovement(Action: Cardinal); // @addr $583F00
    procedure DeclineDominionRepeatImprovement(Action: Cardinal); // @addr $584898
    procedure DeclineDominionTravel(Action: Cardinal); // @addr $586208
    procedure DeclineDominionTravelConfirmation(Action: Cardinal); // @addr $58647C
    procedure DeclineDominionRelocation(Action: Cardinal); // @addr $587438
    procedure ShowDominionCaptureAnswer(Action: Cardinal); // @addr $588550
    procedure ShowDominionRanksAnswer(Action: Cardinal); // @addr $588608
    procedure DeclineDominionWarOperation(Action: Cardinal); // @addr $5895CC
    procedure DeclineDominionAmbush(Action: Cardinal); // @addr $58A2A0
    procedure DeclineDominionAssault(Action: Cardinal); // @addr $58AC40
    procedure BuildDominionWarOptions; // @addr $5874F4
  end;

function GetDominionRelocationCost(Star: TStar): Integer; // @addr $586908

function ApplyRecentDominionOrderSurcharge(Cost: Single): Integer; // @addr $5886F4 @ida "int __stdcall $name(float Cost);"

function GetConstructionShopCost: Integer; // @addr $580D44
function GetConstructionFreeSpace: Integer; // @addr $580D88
procedure SelectConstructionItem(Item: TEquipment; Source: Byte); // @addr $581C90

function GetStationBackgroundPath: WideString; // @addr $55754C

procedure ResetStationImprovement; // @addr $557484

var
  BusinessQuoteSmallAmount: Integer; // @addr 0x0081B654
  BusinessQuoteMediumAmount: Integer; // @addr 0x0081B658
  BusinessQuoteLargeAmount: Integer; // @addr 0x0081B65C
  BusinessQuoteLargeDueTurn: Integer; // @addr 0x0081B660
  BusinessQuoteMediumDueTurn: Integer; // @addr 0x0081B664
  BusinessQuoteSmallDueTurn: Integer; // @addr 0x0081B668
  BusinessDepositQuoteInterestRate: Single; // @addr 0x0081B66C
  NodeExchangeHighPriorityModule: Integer; // @addr $81B670
  NodeExchangeMediumPriorityModule: Integer; // @addr $81B674
  NodeExchangeLowPriorityModule: Integer; // @addr $81B678
  NodeExchangeHighPriorityCost: Integer; // @addr $81B67C
  NodeExchangeMediumPriorityCost: Integer; // @addr $81B680
  NodeExchangeLowPriorityCost: Integer; // @addr $81B684
  StationServiceQuoteCost: Integer; // @addr $81B688 Shared by allegiance changes and station service quotes.
  MilitaryTravelDistance: Integer; // @addr $81B68C Rounded distance to the military base destination.
  InvestmentRangerCenterStar: TStar; // @addr $81B690
  InvestmentPirateBaseStar: TStar; // @addr $81B694
  InvestmentMilitaryBaseStar: TStar; // @addr $81B698
  InvestmentScienceBaseStar: TStar; // @addr $81B69C
  InvestmentBusinessCenterStar: TStar; // @addr $81B6A0
  InvestmentMedicalBaseStar: TStar; // @addr $81B6A4
  InvestmentDefensePlanet: TPlanet; // @addr $81B6A8
  InvestmentQuoteCosts: array[TCoalitionProject] of Integer; // @addr $81B6AC
  SelectedResearchSeries: TDominatorSeries; // @addr $81B6DC
  NearbyTradeAdviceCost: Integer; // @addr $81B6E0
  DistantTradeAdviceCost: Integer; // @addr $81B6E4
  PirateProgramQuoteCosts: array[TProgramIndex] of Integer; // @addr $81B6E8
  PirateChameleonQuoteCosts: array[TDominatorSeries] of Integer; // @addr $81B718
  // Shared quote amounts are replaced when opening either banking dialog.
  StationImprovementItem: TEquipment; // @addr $81B724
  StationImprovementKind: TUpgradeKind; // @addr $81B728
  StationImprovementDetail: Integer; // @addr $81B72C
  StationBridgeMode: Byte; // @addr $81B730 0: station services; 1: hull bridge; higher values: custom bridge.
  ConstructionEquipment: array[item_hull..item_defense_generator] of TConstructionEquipment; // @addr $81B734
  ConstructionWeapons: array[1..5] of TConstructionEquipment; // @addr $81B774
  DominionTravelQuotes: array[1..4] of TDominionTravelQuote; // @addr $81B79C

implementation

uses aPirate, aWarrior, aGroup, aPlanet, fSelectFace, aGalaxyEvent, fShip2, fGalaxy2, aMyFunction, aRanger, EC_Expression, SysUtils, EC_Str, Globals, GlobalsV, GR_Main, fEquipmentShop, aGalaxy, aPlayer, aShip, Math, Windows, MMSystem, GI_XviD, GI_PanelScrollBar, ThreadCalc, aCalc, Messages, Classes, fTalk, GI_Main, GI_Panel, GI_Image, GI_ScrollBar, aSaveLoad, fSaveManager, fHangar, GI_GraphButton, GI_GAI, aConst, aGalaxyStruct, aRuins;

{ @routine $557484 ResetStationImprovement }
procedure ResetStationImprovement;
begin
  StationImprovementItem := nil;
  StationImprovementKind := upgrade_random;
  StationImprovementDetail := 0;
end;
{ @end $557484 }

{ @routine $55749C TfRuinsTalk_Create }
constructor TfRuinsTalk.Create;
begin
  inherited Create;
  StationPanel := TfPanelRuins.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $55749C }

{ @routine $5574F8 TfRuinsTalk_Destroy }
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
{ @end $5574F8 }

{ @routine $55754C GetStationBackgroundPath }
function GetStationBackgroundPath: WideString;
var
  Station: TShip;
begin
  if StationBridgeMode > 0 then
  begin
    Result := GetPlayer.RuinsStatusText;
    if Result = '' then Result := GameDataConfig.GetBlockByPath(WideString('CustomBridges.' + IntToStr(StationBridgeMode))).GetParam('BGI');
    Exit;
  end;
  if GetPlayer <> nil then Station := GetPlayer.DockedTo else Station := nil;
  if Station = nil then Result := 'Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[RuinsTalkScreen.StationType].Name + 'bg'
  else
  begin
    if Station.TypeNameOverrideKey <> '' then Result := 'Bm.FormRuins.' + GiResourceSuffix + Station.TypeNameOverrideKey + 'bg'
    else Result := 'Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[Station.TypeId].Name + OwnerInfo[Station.OwnerId].InternalName + 'bg';
    if not CacheDataRoot.FileExistsByPath(Result) then Result := 'Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[Station.TypeId].Name + 'bg';
  end;
end;
{ @end $55754C }

{ @routine $557774 TfRuinsTalk_InitializeLayout }
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
  if (GameScreenWidth >= 1280) and (GameScreenHeight >= 960) then
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
{ @end $557774 }

{ @routine $557E2C TfRuinsTalk_LayoutStationPortrait }
procedure TfRuinsTalk.LayoutStationPortrait(Panel: TObjectGI);
var
  I, HalfWidth, PortraitX, PortraitY, TableY, Bottom, DeltaX, DeltaY: Integer;
  Table, Table2, Animation, HdAnimation: TObjectGI;
begin
  if Panel = nil then Exit;
  Panel.ReloadFromBlock;
  Panel.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  HalfWidth := GameScreenWidth div 2;
  PortraitY := GameScreenHeight div 10;
  TableY := PortraitY + Panel.FindByNameRecursive('Panel_Anim0').ClientSize.Y div 10 * 6;
  if Panel.FindByNameRecursive('Table2') <> nil then
    Bottom := TableY + Round(Min(Panel.FindByNameRecursive('Table').ClientSize.Y * 0.95 + Panel.FindByNameRecursive('Table').LocalPosition.Y,
      Panel.FindByNameRecursive('Table2').ClientSize.Y * 0.9 + Panel.FindByNameRecursive('Table2').LocalPosition.Y))
  else Bottom := TableY + Round(Panel.FindByNameRecursive('Table').ClientSize.Y * 0.95 + Panel.FindByNameRecursive('Table').LocalPosition.Y);
  DeltaX := Panel.FindByNameRecursive('Panel_Anim0').LocalPosition.X - Panel.FindByNameRecursive('Panel_Anim1').LocalPosition.X;
  DeltaY := Panel.FindByNameRecursive('Panel_Anim0').ClientSize.Y - Panel.FindByNameRecursive('Panel_Anim1').ClientSize.Y;
  if Integer(GameScreenHeight) > Bottom then
  begin
    PortraitY := PortraitY + Integer(GameScreenHeight) - Bottom;
    TableY := TableY + Integer(GameScreenHeight) - Bottom;
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
{ @end $557E2C }

{ @routine $5582E8 TfRuinsTalk_HideStationTransientControl }
procedure TfRuinsTalk.HideStationTransientControl;
begin
  if StationTransientControl <> nil then StationTransientControl.SetActive(False);
end;
{ @end $5582E8 }

{ @routine $5582FC TfRuinsTalk_OnOpen }
procedure TfRuinsTalk.OnOpen;
var
  Owner: TOwnerId; Kind: TStationType;
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
    Background.SetActive(StationType = station_military_base);
    if Background.Active then
    begin
      Background.SetImagePath('GAI,' + GetPlayer.CurrentStar.GetBackgroundImagePath(Index));
      Background.GaiImageControl.LoadFrameSequenceFromText(SingleFrameAnimationSpec);
      Background.SetImageKindX(image_x_center);
      Background.SetImageKindY(image_y_center);
    end;
    Stage := 9;
    (GetByName('ImageBG') as TImageGI).ImageSourcePath := 'GI,' + GetStationBackgroundPath;
    Stage := 10;
    I_Start;
    Stage := 11;
    RestartTextPresentation;
    Stage := 12;
    Choices := GetByName('TalkPA') as TPanelScrollBarGI;
    Choices.SetVerticalScrollbarEnabled(False);
    Stage := 13;
    for Owner := owner_maloc to owner_gaal do
    begin
      Control := FindControlByPath('Panel' + OwnerInfo[Owner].InternalName);
      if Control <> nil then Control.SetActive(False);
      for Kind := station_ranger_center to station_dominion do
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
    if GetPlayer <> nil then GetPlayer.ScriptItemsAct(event_enter_form, nil, nil, 0);
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
{ @end $5582FC }

{ @routine $558EA8 TfRuinsTalk_OnClose }
procedure TfRuinsTalk.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(181);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(event_leave_form, nil, nil, 0);
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
{ @end $558EA8 }

{ @routine $559080 TfRuinsTalk_SortResearchItems }
function TfRuinsTalk.SortResearchItems(Series: TDominatorSeries): Integer;
var
  I, Count, BestIndex, SortedCount: Integer;
  Item: TEquipment;
  BestKey, Key: TResearchItemSortKey;

  // @nested $558F5C ClearResearchItemSortKey
  procedure ClearResearchItemSortKey(var Key: TResearchItemSortKey); // @addr $558F5C @calls "0x0055910E"
  begin
    Key.Cost := 0;
    Key.Priority := 0;
    Key.Weight := 0;
  end;

  // @nested $558F6C MakeResearchItemSortKey
  function MakeResearchItemSortKey(Item: TEquipment): TResearchItemSortKey; // @addr $558F6C @calls "0x00559146"
  begin
    Result.Cost := Item.Cost;
    Result.Weight := Item.Weight;
    Result.Priority := 0;
    if (Item.OwnerId = owner_dominator) and (Item.EquippedFlag = 0) and (Item.NoDropFlag = 0) and (Item.CustomFaction = '') and not (Item is THull) then
    begin
      if Item is TUselessItem then
      begin
        if Series = Item.DominatorSeries then Result.Priority := 5 else Result.Priority := 4;
      end
      else if Item is TCountableItem then Result.Priority := 2
      else if Item is TMicroModule then Result.Priority := 1
      else Result.Priority := 3;
    end;
  end;

  // @nested $559010 CompareResearchItemSortKeys
  function CompareResearchItemSortKeys(Left, Right: TResearchItemSortKey): Integer; // @addr $559010 @calls "0x00559176"
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
{ @end $559080 }

{ @routine $5591D4 TfRuinsTalk_IsResearchItemQuestLetter }
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
      if Quest.QuestType = quest_kind_deliver_letter then
        if LocalizedColorText(WideString('Quest.SendLetter.' + IntToStr(Quest.QuestNumber) + '.SysName')) = (Item as TUselessItem).ConfigBlockName then Result := True;
    end;
end;
{ @end $5591D4 }

{ @routine $559314 TfRuinsTalk_CountResearchRemains }
function TfRuinsTalk.CountResearchRemains(Series: TDominatorSeries; Count: Integer): Integer;
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
    if ((Item.DominatorSeries = Series) and (Item is TUselessItem)) and ((Item as TUselessItem).IsDominatorRemains and not IsResearchItemQuestLetter(Item)) then Inc(Matches);
  end;
  Result := Matches;
end;
{ @end $559314 }

{ @routine $5593A4 TfRuinsTalk_CountResearchEquipment }
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
    if not (Item is TUselessItem) and (Item.EquippedFlag = 0) and (Item.ItemType <> item_nodes) and (Item.ItemType <> item_micro_module) then Inc(Matches);
  end;
  Result := Matches;
end;
{ @end $5593A4 }

{ @routine $559410 TfRuinsTalk_BuildResearchItemChoices }
procedure TfRuinsTalk.BuildResearchItemChoices(Series: TDominatorSeries; var Text: WideString);
var
  I, Count, Index, Number: Integer;
  Item: TEquipment;
  Items, Description, Bonus: WideString;
begin
  Bonus := ' ' + WrapTextInColor(LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), TextHighlightColorTag);
  Number := 0;
  Count := SortResearchItems(Series);
  if CountResearchRemains(Series, Count) > 0 then
    case Series of
      series_blazer: AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleAllUselessBlazer'), Count, SellResearchRemains);
      series_keller: AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleAllUselessKeller'), Count, SellResearchRemains);
      series_terron: AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleAllUselessTerron'), Count, SellResearchRemains);
    end;
  if CountResearchEquipment(Count) > 1 then
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleAllEq'), Count, SellResearchEquipment);
  for I := 0 to Count - 1 do
  begin
    Index := ResearchItemIndexes[I];
    if Index < 0 then Break;
    Item := GetPlayer.Inventory[Index];
    Inc(Number);
    Description := NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)) + ' (' + WrapTextInColor(IntToStr(Item.Cost), TextHighlightColorTag) + ' cr)';
    if (Item.DominatorSeries = Series) and (Item is TUselessItem) then Description := Description + Bonus;
    Items := Items + #13#10 + IntToStr(Number) + ') ' + Description;
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.SB.Scn.PlayerSale'), '', '<ItemName>', Description), Index, SellResearchItem);
  end;
  Text := Items;
end;
{ @end $559410 }

{ @routine $559988 TfRuinsTalk_EndTurnClicked }
procedure TfRuinsTalk.EndTurnClicked(Sender: TObjectGI);
begin
  if (GetPlayer = nil) or (GetPlayer.PendingDockDialogue > 1) or (StationBridgeMode > 0) or (GetPlayer.QueuedTravelTarget <> nil) then Exit;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_dominion) and (GetPlayer.DockedTo.Order = order_teleport) and
    (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) and not GetPlayer.DockedTo.InHyperspace then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_dominion) and ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_military_base) and ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
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
{ @end $559988 }

{ @routine $559BF4 TfRuinsTalk_ShipClicked }
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
{ @end $559BF4 }

{ @routine $559C68 TfRuinsTalk_RememberChoiceScroll }
procedure TfRuinsTalk.RememberChoiceScroll;
begin
  SavedChoiceScroll := (GetByName('TalkPA') as TPanelScrollBarGI).VerticalScrollBar.Position;
end;
{ @end $559C68 }

{ @routine $559CAC TfRuinsTalk_ClearChoices }
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
{ @end $559CAC }

{ @routine $559E88 TfRuinsTalk_AddChoice }
procedure TfRuinsTalk.AddChoice(CaptionText: WideString; Value: Cardinal; Callback: TDialogChoiceEventGI);
var Panel: TPanelScrollBarGI; Choice: TfTalkA; I: Integer; Row: TPanelGI;
  Highlight: TImageGI; BlockMode: Byte;
begin
  BlockMode := 0;
  if ScriptDialogBlocks <> nil then
    for I := 0 to ScriptDialogBlocks.Count - 1 do
      if FindTextOffsetW(CaptionText, PScriptDialogBlock(ScriptDialogBlocks[I]).Text) >= 0 then
        BlockMode := Max(BlockMode, PScriptDialogBlock(ScriptDialogBlocks[I]).Mode);
  if BlockMode >= 2 then Exit;
  Panel := GetByName('TalkPA') as TPanelScrollBarGI;
  I := 0;
  while I < Length(CaptionText) do
  begin
    if (CaptionText[I + 1] <> '-') and (CaptionText[I + 1] <> ' ') then Break;
    Inc(I);
  end;
  if I > 0 then CaptionText := Copy(CaptionText, I + 1, Length(CaptionText) - I);
  Choice := TfTalkA.Create;
  Choice.Callback := Callback;
  Choice.Value := Value;
  if BlockMode > 0 then Choice.Callback := nil;
  Row := TPanelGI.Create(Panel);
  Row.UserValue := Integer(Choice);
  Row.SetPosition(Point(0, ChoiceHeight));
  Row.ObjectSize := Point(Panel.ClientSize.X, 20);
  Row.SetPositionModeW(True);
  Row.MouseEnterCallback := ChoiceMouseEnter;
  Row.MouseLeaveCallback := ChoiceMouseLeave;
  Row.LeftButtonDownCallback := ChoiceMouseDown;
  Row.LeftButtonUpCallback := ChoiceMouseUp;
  Highlight := TImageGI.Create(Row);
  Highlight.SetDepth(3);
  Highlight.SetPosition(Point(0, 0));
  Highlight.ObjectSize := Point(Panel.ClientSize.X, 20);
  Highlight.SetImagePath('GI,Bm.FormGov2.' + GiResourceSuffix + 'Line');
  Highlight.SetImageKindX(image_x_tile_left);
  Highlight.SetImageKindY(image_y_tile_top);
  Highlight.SetActive(False);
  with TLabelGI.Create(Row) do
  begin
    if FontDialog = 0 then SetFontName(NormalFontName)
    else if FontDialog = 1 then SetFontName(SmoothBigFontName)
    else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
    else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
    ObjectSize := Point(Panel.ClientSize.X - GiScalePixels(20), 1);
    SetPosition(Point(GiScalePixels(10), 0));
    SetWordWrapEnabled(True);
    SetTextAlignX(text_x_left);
    SetTextAlignY(text_y_fit_height);
    if not Assigned(Callback) then CaptionText := RemoveTextTagsW(CaptionText);
    Text := '<Object=0,20,14,0>' + ReplaceAllWideString(CaptionText, TextHighlightColorTag, DialogHighlightColorTag);
    SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    if not Assigned(Choice.Callback) then SetTextColor(CurrentPixelFormat.PackRgbBytes(127, 127, 127));
    CreateEmbeddedControl := CreateChoiceBullet;
    SetTextAlignY(text_y_font_center);
    Row.ObjectSize := Point(Row.ClientSize.X, ClientSize.Y + 2 * GiScalePixelsEx(2, 2));
    ObjectSize := Point(ClientSize.X, Row.ClientSize.Y);
    Highlight.ObjectSize := Row.ClientSize;
    Inc(ChoiceHeight, ClientSize.Y);
  end;
end;
{ @end $559E88 }

{ @routine $55A3E0 TfRuinsTalk_ChoiceMouseEnter }
procedure TfRuinsTalk.ChoiceMouseEnter(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(True);
end;
{ @end $55A3E0 }

{ @routine $55A3EC TfRuinsTalk_ChoiceMouseLeave }
procedure TfRuinsTalk.ChoiceMouseLeave(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(False);
end;
{ @end $55A3EC }

{ @routine $55A3F8 TfRuinsTalk_ChoiceMouseDown }
procedure TfRuinsTalk.ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
    (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(2, 0));
end;
{ @end $55A3F8 }

{ @routine $55A458 TfRuinsTalk_ChoiceMouseUp }
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
{ @end $55A458 }

{ @routine $55A550 TfRuinsTalk_RestartTextPresentation }
procedure TfRuinsTalk.RestartTextPresentation;
begin
  ResetPortraitCycle;
  (GetByName('TalkPA') as TPanelScrollBarGI).SetActive(False);
  PresentedTextLength := 0;
  if TextPresentationTimer <> 0 then
  begin
    CancelCallbackTimer(TextPresentationTimer);
    TextPresentationTimer := 0;
  end;
  TextPresentationTimer := ScheduleCallbackTimer(10, 10, AdvanceTextPresentation);
end;
{ @end $55A550 }

{ @routine $55A5D0 TfRuinsTalk_AdvanceTextPresentation }
procedure TfRuinsTalk.AdvanceTextPresentation(Timer: TCallbackTimerIdGI; UserData: Cardinal);
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
    if TextPresentationTimer <> 0 then
    begin
      CancelCallbackTimer(TextPresentationTimer);
      TextPresentationTimer := 0;
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
    DialogText := ReplaceAllWideString(DialogText, TextHighlightColorTag, DialogHighlightColorTag);
    (GetByName('TalkText') as TLabelGI).Text := DialogText;
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
{ @end $55A5D0 }

{ @routine $55A9B8 TfRuinsTalk_ResetPortraitCycle }
procedure TfRuinsTalk.ResetPortraitCycle;
begin
  NextPortraitCycleAlternate := True;
end;
{ @end $55A9B8 }

{ @routine $55A9C0 TfRuinsTalk_PortraitCycleComplete }
procedure TfRuinsTalk.PortraitCycleComplete(Sender: TObjectGI);
begin
  if NextPortraitCycleAlternate then
  begin
    SelectPortraitAnimation(True);
    NextPortraitCycleAlternate := False;
  end
  else SelectPortraitAnimation(False);
end;
{ @end $55A9C0 }

{ @routine $55A9EC TfRuinsTalk_SelectPortraitAnimation }
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
{ @end $55A9EC }

{ @routine $55AC10 TfRuinsTalk_CreateChoiceBullet }
function TfRuinsTalk.CreateChoiceBullet(LabelControl: TLabelGI; Item: PFontObjectEC): TObjectGI;
var Image: TImageGI;
begin
  Result := TImageGI.Create(LabelControl);
  Image := Result as TImageGI;
  Image.SetImagePath('GI,Bm.FormGov2.' + GiResourceSuffix + 'Answer');
  Image.SetImageKindX(image_x_left);
end;
{ @end $55AC10 }

{ @routine $55ACE0 TfRuinsTalk_ProcessMouseWheel }
procedure TfRuinsTalk.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
var
  Panel: TPanelScrollBarGI;
begin
  Panel := GetByName('TalkPA') as TPanelScrollBarGI;
  if not Panel.ContainsPoint(Point) then Panel := GetByName('TextScroll') as TPanelScrollBarGI;
  if Delta = WHEEL_DELTA then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.SmallChange)
  else if Delta = -WHEEL_DELTA then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.SmallChange);
end;
{ @end $55ACE0 }

{ @routine $55ADA8 TfRuinsTalk_MainPanelKeyDown }
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
{ @end $55ADA8 }

{ @routine $55AF7C TfRuinsTalk_AddMessageClicked }
procedure TfRuinsTalk.AddMessageClicked(Sender: TObjectGI);
var
  Text: WideString;
begin
  Text := (GetByName('TalkText') as TLabelGI).Text;
  Text := ReplaceAllWideString(Text, DialogHighlightColorTag, TextHighlightColorTag);
  (Sender as TGraphButtonGI).SetDisabled(True);
  SoundManager.PlaySound('Sound.UserMsgAdd');
  AddOrUpdatePlayerBubble(message_user_note, Galaxy.CurrentTurn, Text, '');
  MainPanel.RebuildMessageButtons(False);
  BreakUiMessage;
end;
{ @end $55AF7C }

{ @routine $55B0E0 TfRuinsTalk_AdvanceScriptVideo }
procedure TfRuinsTalk.AdvanceScriptVideo(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Progress: Double; Film: TxvidGI;
begin
  Progress := (timeGetTime - ScriptVideoStartedAt) / 138000;
  if Progress > 1 then Progress := 1;
  Film := GetByName('Film') as TxvidGI;
  Film.SetFramePosition(Round(3449 * Progress));
  if Progress >= 1 then StopScriptVideo(False);
end;
{ @end $55B0E0 }

{ @routine $55B190 TfRuinsTalk_StopScriptVideo }
function TfRuinsTalk.StopScriptVideo(Unused: Boolean): Boolean;
var Film: TxvidGI;
begin
  Result := ScriptVideoTimer <> 0;
  if MusicEnabled and Result then
  begin
    MusicManager.StopImmediately;
    while MusicManager.IsPlaying do SysUtils.Sleep(1);
  end;
  if ScriptVideoTimer <> 0 then
  begin
    CancelCallbackTimer(ScriptVideoTimer);
    ScriptVideoTimer := 0;
  end;
  Film := GetByName('Film') as TxvidGI;
  Film.ImageClose;
  Film.SetActive(False);
  InvalidateViewport;
  if Result and (QueuedVideos.Count > 0) then CompleteQueuedVideo(2);
end;
{ @end $55B190 }

{ @routine $55B24C TfRuinsTalk_ProcessWindowMessage }
procedure TfRuinsTalk.ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer);
begin
  if ((Message <> WM_LBUTTONDOWN) and (Message <> WM_RBUTTONDOWN) and (Message <> WM_MBUTTONDOWN) and (Message <> WM_KEYDOWN)) or not StopScriptVideo(False) then
    inherited ProcessWindowMessage(Message, WParam, LParam);
end;
{ @end $55B24C }

{ @routine $55B29C TfRuinsTalk_SelectMusic }
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
  if GetPlayer.DockedTo.TypeId in [station_ranger_center..station_custom] then
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
    if GetPlayer.CurrentPlanet.OwnerId = owner_pirate then
    begin
      if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.PiratePlanetMain');
    end
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
  end;
end;
{ @end $55B29C }

{ @routine $55B660 TfRuinsTalk_I_Start }
procedure TfRuinsTalk.I_Start;
var
  Stage: Integer;
begin
  Stage := 0;
  try
    if IsTurnCalculationRunningUI then WaitForTurnCalculationUI;
    Stage := 1;
    if ShowArrivalVideo and (StationType = station_military_base) then
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
{ @end $55B660 }

{ @routine $55B818 TfRuinsTalk_ShowDominatorVictoryDialog }
function TfRuinsTalk.ShowDominatorVictoryDialog: Boolean;
var
  MessageEntry: TMessagePlayer;
  Variant: Integer;
begin
  Result := False;
  while True do
  begin
    if (Galaxy.TerronSeriesResolvedTurn = 0) and (Galaxy.KellerSeriesResolvedTurn = 0) and (Galaxy.BlazerSeriesResolvedTurn = 0) then Break;
    MessageEntry := FindPlayerBubbleByKey('BlazerWin', False);
    if (MessageEntry <> nil) and (MessageEntry.Kind = message_quest_active) then
    begin
      MessageEntry.Kind := message_quest_succeeded;
      MessageEntry.WasRead := False;
      Result := True;
      if (BlazerShip = nil) and (Galaxy.BlazerSelfDestructTurn <> 0) then Variant := 1
      else if Galaxy.BlazerLandingPlanetId <> 0 then Variant := 2
      else Variant := 3;
      DialogText := ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Blazer' + IntToStr(Variant)), '<Date>', FormatGameTurnDate(Galaxy.BlazerSeriesResolvedTurn), TextHighlightColorTag);
      if (Variant = 2) and (BlazerShip <> nil) and (BlazerShip.CurrentPlanet <> nil) then
        DialogText := ReplaceColoredToken(DialogText, '<Planet>', BlazerShip.CurrentPlanet.Name, TextHighlightColorTag);
      DialogText := DialogText + #13#10 + ' ' + #13#10 + ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Reward'), '<Reward>', GetPlayer.AwardRandomMedal, TextHighlightColorTag);
      ClearChoices;
      AddChoice('- ' + LocalizedColorText('FormRuinsRC.Continue'), 0, ContinueDominatorVictoryDialog);
      Break;
    end;
    MessageEntry := FindPlayerBubbleByKey('KellerWin', False);
    if (MessageEntry <> nil) and (MessageEntry.Kind = message_quest_active) then
    begin
      MessageEntry.Kind := message_quest_succeeded;
      MessageEntry.WasRead := False;
      Result := True;
      if KellerShip = nil then Variant := 1 else Variant := 2;
      DialogText := ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Keller' + IntToStr(Variant)), '<Date>', FormatGameTurnDate(Galaxy.KellerSeriesResolvedTurn), TextHighlightColorTag);
      DialogText := DialogText + #13#10 + ' ' + #13#10 + ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Reward'), '<Reward>', GetPlayer.AwardRandomMedal, TextHighlightColorTag);
      ClearChoices;
      AddChoice('- ' + LocalizedColorText('FormRuinsRC.Continue'), 0, ContinueDominatorVictoryDialog);
      Break;
    end;
    MessageEntry := FindPlayerBubbleByKey('TerronWin', False);
    if (MessageEntry <> nil) and (MessageEntry.Kind = message_quest_active) then
    begin
      MessageEntry.Kind := message_quest_succeeded;
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
      DialogText := ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Terron' + IntToStr(Variant)), '<Date>', FormatGameTurnDate(Galaxy.TerronSeriesResolvedTurn), TextHighlightColorTag);
      if (Variant = 1) and (TerronShip <> nil) and (TerronShip.CurrentStar <> nil) then
        DialogText := ReplaceColoredToken(DialogText, '<Star>', TerronShip.CurrentStar.Name, TextHighlightColorTag);
      DialogText := DialogText + #13#10 + ' ' + #13#10 + ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Reward'), '<Reward>', GetPlayer.AwardRandomMedal, TextHighlightColorTag);
      ClearChoices;
      AddChoice('- ' + LocalizedColorText('FormRuinsRC.Continue'), 0, ContinueDominatorVictoryDialog);
      Break;
    end;
    Break;
  end;
end;
{ @end $55B818 }

{ @routine $55BFD8 TfRuinsTalk_ContinueDominatorVictoryDialog }
procedure TfRuinsTalk.ContinueDominatorVictoryDialog(Action: Cardinal);
begin
  if not ShowDominatorVictoryDialog then I_Start;
end;
{ @end $55BFD8 }

{ @routine $55BFF0 TfRuinsTalk_M_Main }
procedure TfRuinsTalk.M_Main(KeepText: Boolean);
const AllSeries = [series_blazer, series_keller, series_terron];
var
  Script: TScript;
  Text, Prefix: WideString;
  Item: TItem;
  I, J, SelectedIndex: Integer;
  UnusedLocal: Integer; // Existing native frame gap before BestPriority; original type unknown.
  BestPriority, ModuleIndex, Place, ExcludedBefore, RangerCount, Parts: Integer;
  Ranger: TRanger;
  SwapEntry: TObject;
  Seed: Cardinal;
  ItemType: TItemType;
  Weight, Level: Integer;
  Info: PWeaponInfo;
  MinimumSizeFactor, MaximumSizeFactor: Single;
  Stage: Integer;
begin
  Stage := 0;
  try
    ClearScriptDialogRules;
    Stage := 1;
    ClearChoices;
    ScriptDialogIndex := -1;
    Script := nil;
    Stage := 2;
    if (GetPlayer.DockedTo.TypeId = station_ranger_center) and ShowDominatorVictoryDialog then Exit;
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
        ReplaceTextToken(DialogText, '<Energy>', IntToStr(GetPlayer.GetHull.Energy), TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<EnergyMax>', IntToStr(GetPlayer.GetHull.EnergyMax), TextHighlightColorTag);
        if GetPlayer.GetHull.ImpulseShieldsEnabled then
          ReplaceTextToken(DialogText, '<ShieldMode>', LocalizedColorText('FormRuins.Bridge.BridgeImpulseShieldsStatusOn'), TextHighlightColorTag)
        else ReplaceTextToken(DialogText, '<ShieldMode>', LocalizedColorText('FormRuins.Bridge.BridgeImpulseShieldsStatusOff'), TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Count>', IntToStr(GetPlayer.CountActiveInterceptorTargets), TextHighlightColorTag);
        if GetPlayer.InHyperspace or (GetPlayer.RuinsSavedDockedTo <> nil) or (GetPlayer.RuinsSavedPlanet <> nil) then
          ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetNotNormalSpace'), EndColorTag)
        else if GetPlayer.GetHull.Energy < GetPlayer.GetInterceptorEnergyCost then
          ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetNoEnergy'), EndColorTag)
        else if GetPlayer.GetHull.InterceptorTarget <> nil then
          ReplaceTextToken(DialogText, '<Ship>', TShip(GetPlayer.GetHull.InterceptorTarget).GetFullName(' '), TextHighlightColorTag)
        else if GetPlayer.GetHull.InterceptorTargetingStrategy = interceptor_manual then
          ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetOff'), EndColorTag)
        else if GetPlayer.SelectInterceptorTarget <> nil then
          ReplaceTextToken(DialogText, '<Ship>', GetPlayer.SelectInterceptorTarget.GetFullName(' '), TextHighlightColorTag)
        else ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetMissing'), EndColorTag);
        case GetPlayer.GetHull.InterceptorTargetingStrategy of
          interceptor_manual: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), TextHighlightColorTag);
          interceptor_most_health: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMax'), TextHighlightColorTag);
          interceptor_least_health: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMin'), TextHighlightColorTag);
          interceptor_strongest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyStrMax'), TextHighlightColorTag);
          interceptor_best_defense: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDefMax'), TextHighlightColorTag);
          interceptor_nearest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMin'), TextHighlightColorTag);
          interceptor_farthest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMax'), TextHighlightColorTag);
        else ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), TextHighlightColorTag);
        end;
        ReplaceTextToken(DialogText, '<Duration>', IntToStr(GetPlayer.GetInterceptorPassCount), TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<DeployCost>', IntToStr(GetPlayer.GetInterceptorEnergyCost), TextHighlightColorTag);
      end
      else if (StationBridgeMode > 1) or (GetPlayer.RuinsMode > 0) then DialogText := 'text missing'
      else
      begin
        Stage := 7;
        case GetPlayer.DockedTo.TypeId of
          station_ranger_center:
            begin
              Stage := 8;
              Galaxy.RefreshRangerRatingPlaces;
              DialogText := LocalizedColorText('FormRuins.RC.Greeting');
              Place := GetPlayer.PlaceInRating;
              ExcludedBefore := 0;
              RangerCount := Galaxy.Rangers.Count;
              for I := 0 to Galaxy.Rangers.Count - 1 do
              begin
                Ranger := Galaxy.Rangers[I];
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
              ReplaceTextToken(DialogText, '<RC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
              ReplaceTextToken(DialogText, '<Number>', IntToStr(Place), TextHighlightColorTag);
              ReplaceTextToken(DialogText, '<BaseNod>', IntToStr(GetPlayer.BaseNodes), TextHighlightColorTag);
            end;
          station_pirate_base:
            begin
              Stage := 9;
              // Flag comparison with an empty body.
              if (GetPlayer.DockedTo as TRuins).SpecialServiceActive then;
              GetPlayer.AchievementStats.CheckBaronAchievement;
              DialogText := LocalizedColorText('FormRuins.PB.GreetingPre');
              DialogText := DialogText + LocalizedColorText('FormRuins.PB.GreetingMod');
              DialogText := DialogText + LocalizedColorText('FormRuins.PB.GreetingAft');
              if GetPlayer.MayTakeSubCrack then
                DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.PB.SabCrack.PBGreetingAdd');
              ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
              ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.GetSubCrackCost), TextHighlightColorTag);
            end;
          station_science_base:
            begin
              Stage := 10;
              if Galaxy.IsDominatorResearchComplete(AllSeries) or
                not Galaxy.HasUnresolvedDominatorSeries(AllSeries) then
                DialogText := LocalizedColorText('FormRuins.SB.GreetingAfterScn')
              else DialogText := LocalizedColorText('FormRuins.SB.GreetingBeforeScn');
              DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.SB.GreetingAdd');
              if Galaxy.CurrentTurn - GalaxyWarmupTurns < 120 then DialogText := DialogText + #13#10 + LocalizedColorText('FormRuinsSB.History.SB');
              ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
            end;
          station_military_base:
            begin
              Stage := 11;
              if GetPlayer.CurrentStar.ControlFaction = faction_dominators then
              begin
                DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBAfterQuestions');
                ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
              end
              else
              begin
                if (GetPlayer.OwnerId <> owner_pirate) and GetPlayer.TryPromoteRank then
                begin
                  Stage := 12;
                  DialogText := LocalizedColorText('FormRuins.WB.' + CoalitionRankNames[GetPlayer.Rank] + '.NewRank');
                  GetPlayer.AchievementStats.CheckCommanderAchievement;
                  ReplaceTextToken(DialogText, '<PredPoints>', IntToStr(CoalitionRankPointThresholds[GetPlayer.Rank - 1]), TextHighlightColorTag);
                  if GetPlayer.Rank = 7 then
                  begin
                    ModuleIndex := FindMicroModuleTemplateByCustomTag('AkrinAmplifier');
                    Item := TMicroModule.Create;
                    if ModuleIndex >= 0 then (Item as TMicroModule).Init(ModuleIndex)
                    else (Item as TMicroModule).Init(Galaxy.SelectMicroModule(1, 15, Galaxy.GenerationSeed + Cardinal(Galaxy.CurrentTurn), GetPlayer.DockedTo));
                    GetPlayer.Inventory.Add(Item);
                    ReplaceTextToken(DialogText, '<MMName>', (Item as TMicroModule).GetPlainName, TextHighlightColorTag);
                  end;
                  Seed := Galaxy.CurrentTurn div 50 * (GetPlayer.DockedTo.Id * (GetPlayer.Rank + 11));
                  MinimumSizeFactor := EquipmentSizeFactors[4];
                  MaximumSizeFactor := EquipmentSizeFactors[2];
                  if NextRandomIntRange(1, 100, Seed) > 70 then
                  begin
                    Info := Galaxy.SelectWeaponInfo(Seed, [availability_unrestricted, availability_coalition_only, OwnerWeaponAvailability[StationOwner]], Min(Galaxy.TechLevel + 2, 8), Galaxy.TechLevel);
                    Seed := Galaxy.CurrentTurn div 33 * (GetPlayer.DockedTo.Id * (GetPlayer.Rank + 17));
                    Weight := NextRandomIntRange(Round(Info.AverageSize * MinimumSizeFactor), Round(Info.AverageSize * MaximumSizeFactor), Seed);
                    Level := Round(RemapClamped(Round(RemapClamped(Ord(GetPlayer.Rank), 0, 7, 1, 5)), 1, 5, 3, 8));
                    Item := CreateGeneratedWeapon(Info, Weight, Level, StationOwner);
                  end
                  else
                  begin
                    ItemType := TItemType(PickRandomItemType([item_fuel_tanks..item_defense_generator]));
                    Seed := Galaxy.CurrentTurn div 33 * (GetPlayer.DockedTo.Id * (GetPlayer.Rank + 17));
                    Weight := NextRandomIntRange(Round(GetAverageItemSize(ItemType) * MinimumSizeFactor), Round(GetAverageItemSize(ItemType) * MaximumSizeFactor), Seed);
                    Level := Round(RemapClamped(Ord(GetPlayer.Rank), 0, 7, 3, 8));
                    Item := CreateGeneratedEquipment(ItemType, Weight, Level, StationOwner);
                  end;
                  if Item <> nil then
                    ReplaceTextToken(DialogText, '<ItemName>', Item.GetDisplayName, TextHighlightColorTag)
                  else RaiseWideMessage('eq=nil');
                  GetPlayer.Inventory.Add(Item);
                end
                else DialogText := LocalizedColorText('FormRuins.WB.' + CoalitionRankNames[GetPlayer.Rank] + '.Greeting');
                if ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
                  ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and (GetPlayer.OwnerId <> owner_pirate) then
                begin
                  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.WB.FlyToEnemy.GreetingAdd');
                  ReplaceTextToken(DialogText, '<StarEnemy>', (GetPlayer.DockedTo as TRuins).FlyToStar.Name, TextHighlightColorTag);
                  ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate((GetPlayer.DockedTo as TRuins).FlyDate), TextHighlightColorTag);
                  MilitaryTravelDistance := Round(PointDistance((GetPlayer.DockedTo as TRuins).FlyToStar.Position, GetPlayer.CurrentStar.Position));
                end;
                if GetPlayer.CountProgramRewardStocks > 0 then
                  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.WB.Programms.GreetingAdd');
                ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
                ReplaceTextToken(DialogText, '<Rank>', GetPlayer.GetRankName, TextHighlightColorTag);
                ReplaceTextToken(DialogText, '<NeedPoints>', IntToStr(GetPlayer.GetRankPointsToNextRank), TextHighlightColorTag);
              end;
            end;
          station_business_center:
            begin
              Stage := 13;
              DialogText := LocalizedColorText('FormRuins.BK.Greeting');
              if GetPlayer.DebtAmount > 0 then DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.BK.AddDebtYes')
              else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.BK.AddDebtNot');
              if GetPlayer.DebtDefaultCount >= 3 then DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.BK.AddDebtContinue');
              ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
              ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.DebtAmount), TextHighlightColorTag);
              ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(GetPlayer.DebtDueTurn), TextHighlightColorTag);
            end;
          station_medical_base:
            begin
              Stage := 14;
              DialogText := LocalizedColorText('FormRuins.MC.Greeting');
              ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
            end;
          station_dominion:
            begin
              Stage := 15;
              if GetPlayer.DockedTo.InHyperspace then DialogText := LocalizedColorText('FormRuins.CB.GreetingHyperspace')
              else if GetPlayer.QueuedTravelTarget <> nil then
              begin
                DialogText := LocalizedColorText('FormRuins.CB.GreetingPlayerFlyToStar');
                ReplaceTextToken(DialogText, '<FlyToStar>', GetPlayer.QueuedTravelTarget.Name, TextHighlightColorTag);
              end
              else if (GetPlayer.DockedTo.Order = order_teleport) and (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) then
              begin
                DialogText := LocalizedColorText('FormRuins.CB.GreetingFlyToStar');
                ReplaceTextToken(DialogText, '<FlyToStar>', TStar(GetPlayer.DockedTo.OrderTarget).Name, TextHighlightColorTag);
              end
              else DialogText := LocalizedColorText('FormRuins.CB.GreetingNormal');
              ReplaceTextToken(DialogText, '<CB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
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
        Script := Galaxy.Scripts[I];
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
{ @end $55BFF0 }

{ @routine $55EFC8 TfRuinsTalk_CloseHullMode }
procedure TfRuinsTalk.CloseHullMode(Action: Cardinal);
begin
  GetPlayer.CloseRuinsModeScreen;
end;
{ @end $55EFC8 }

{ @routine $55EFD4 TfRuinsTalk_ToggleImpulseShields }
procedure TfRuinsTalk.ToggleImpulseShields(Action: Cardinal);
begin
  GetPlayer.GetHull.ImpulseShieldsEnabled := not GetPlayer.GetHull.ImpulseShieldsEnabled;
  GetPlayer.GetHull.Energy := Max(0, GetPlayer.GetHull.Energy - 10);
  ClearChoices;
  M_Main(False);
end;
{ @end $55EFD4 }

{ @routine $55F034 TfRuinsTalk_ShowBridgeBlackHoleDialog }
procedure TfRuinsTalk.ShowBridgeBlackHoleDialog(Action: Cardinal);
begin
  if not GetPlayer.NoJump then
  begin
    DialogText := LocalizedColorText('FormRuins.Bridge.BridgeBHChooseDestination');
    ReplaceTextToken(DialogText, '<Cost>', IntToStr(600), TextHighlightColorTag);
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
{ @end $55F034 }

{ @routine $55F368 TfRuinsTalk_SelectBridgeBlackHoleDestination }
procedure TfRuinsTalk.SelectBridgeBlackHoleDestination(Action: Cardinal);
begin
  MainPanel.NavigationLocked := True;
  GetByName('PM_WinMsg').SetActive(False);
  Self.ShowCursor := False;
  Present;
  CaptureScreenBackground(True, 0);
  Self.ShowCursor := True;
  GalaxyScreen.ViewMode := 3;
  GalaxyReturnScreenId := FormToId(Self);
  RequestedScreenId := screen_galaxy_map;
  RequestClose(1);
end;
{ @end $55F368 }

{ @routine $55F3F8 TfRuinsTalk_ShowInterceptorDialog }
procedure TfRuinsTalk.ShowInterceptorDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsChooseAction');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(GetPlayer.CountActiveInterceptorTargets), TextHighlightColorTag);
  if GetPlayer.InHyperspace or (GetPlayer.RuinsSavedDockedTo <> nil) or (GetPlayer.RuinsSavedPlanet <> nil) then
    ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetNotNormalSpace'), EndColorTag)
  else if GetPlayer.GetHull.Energy < GetPlayer.GetInterceptorEnergyCost then
    ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetNoEnergy'), EndColorTag)
  else if GetPlayer.GetHull.InterceptorTarget <> nil then
    ReplaceTextToken(DialogText, '<Ship>', TShip(GetPlayer.GetHull.InterceptorTarget).GetFullName(' '), TextHighlightColorTag)
  else if GetPlayer.GetHull.InterceptorTargetingStrategy = interceptor_manual then
    ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetOff'), EndColorTag)
  else if GetPlayer.SelectInterceptorTarget <> nil then
    ReplaceTextToken(DialogText, '<Ship>', GetPlayer.SelectInterceptorTarget.GetFullName(' '), TextHighlightColorTag)
  else ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetMissing'), EndColorTag);
  case GetPlayer.GetHull.InterceptorTargetingStrategy of
    interceptor_manual: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), TextHighlightColorTag);
    interceptor_most_health: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMax'), TextHighlightColorTag);
    interceptor_least_health: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMin'), TextHighlightColorTag);
    interceptor_strongest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyStrMax'), TextHighlightColorTag);
    interceptor_best_defense: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDefMax'), TextHighlightColorTag);
    interceptor_nearest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMin'), TextHighlightColorTag);
    interceptor_farthest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMax'), TextHighlightColorTag);
  else ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), TextHighlightColorTag);
  end;
  ReplaceTextToken(DialogText, '<Duration>', IntToStr(GetPlayer.GetInterceptorPassCount), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<DeployCost>', IntToStr(GetPlayer.GetInterceptorEnergyCost), TextHighlightColorTag);
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
{ @end $55F3F8 }

{ @routine $560248 TfRuinsTalk_ShowActiveInterceptors }
procedure TfRuinsTalk.ShowActiveInterceptors(Action: Cardinal);
var
  ShipList, Text: WideString;
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffChoose');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(GetPlayer.CountActiveInterceptorTargets), TextHighlightColorTag);
  ShipList := '';
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffAll'), 0, RecallAllInterceptors);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(GetPlayer.CurrentStar.StarDistances[I].Star);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if GetPlayer = Ship.InterceptorSourceShip then
      begin
        ShipList := ShipList + Ship.GetFullName(' ') + #13#10;
        Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffShip');
        ReplaceTextToken(Text, '<Ship>', Ship.GetFullName(' '), TextHighlightColorTag);
        AddChoice('- ' + Text, Integer(Ship), RecallInterceptorsFromTarget);
      end;
    end;
  end;
  ReplaceTextToken(DialogText, '<ShipList>', ShipList, TextHighlightColorTag);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffCancel'), 0, ShowInterceptorDialog);
end;
{ @end $560248 }

{ @routine $5606C4 TfRuinsTalk_RecallInterceptorsFromTarget }
procedure TfRuinsTalk.RecallInterceptorsFromTarget(Action: Cardinal);
begin
  TShip(Action).ClearIncomingInterceptors;
  if GetPlayer.CountActiveInterceptorTargets > 0 then ShowActiveInterceptors(0)
  else ShowInterceptorDialog(0);
end;
{ @end $5606C4 }

{ @routine $5606F4 TfRuinsTalk_RecallAllInterceptors }
procedure TfRuinsTalk.RecallAllInterceptors(Action: Cardinal);
var
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
begin
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(GetPlayer.CurrentStar.StarDistances[I].Star);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if GetPlayer = Ship.InterceptorSourceShip then Ship.ClearIncomingInterceptors;
    end;
  end;
  ShowInterceptorDialog(0);
end;
{ @end $5606F4 }

{ @routine $560784 TfRuinsTalk_ShowInterceptorPassDialog }
procedure TfRuinsTalk.ShowInterceptorPassDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationChoose');
  ReplaceTextToken(DialogText, '<Duration>', IntToStr(GetPlayer.GetInterceptorPassCount), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<DeployCost>', IntToStr(GetPlayer.GetInterceptorEnergyCost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<DurationMax>', IntToStr(10), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<DurationMin>', IntToStr(2), TextHighlightColorTag);
  ClearChoices;
  if GetPlayer.GetInterceptorPassCount < 10 then
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationMore'), 0, IncreaseInterceptorPassCount)
  else AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationMore'), 0, ScriptDialogBlockCallback);
  if GetPlayer.GetInterceptorPassCount > 2 then
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationLess'), 0, DecreaseInterceptorPassCount)
  else AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationLess'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationDone'), 0, ShowInterceptorDialog);
end;
{ @end $560784 }

{ @routine $560C5C TfRuinsTalk_IncreaseInterceptorPassCount }
procedure TfRuinsTalk.IncreaseInterceptorPassCount(Action: Cardinal);
begin
  GetPlayer.GetHull.InterceptorPassCountOverride := GetPlayer.GetInterceptorPassCount + 1;
  ShowInterceptorPassDialog(0);
end;
{ @end $560C5C }

{ @routine $560C88 TfRuinsTalk_DecreaseInterceptorPassCount }
procedure TfRuinsTalk.DecreaseInterceptorPassCount(Action: Cardinal);
begin
  GetPlayer.GetHull.InterceptorPassCountOverride := GetPlayer.GetInterceptorPassCount - 1;
  ShowInterceptorPassDialog(0);
end;
{ @end $560C88 }

{ @routine $560CB4 TfRuinsTalk_ShowInterceptorTargetDialog }
procedure TfRuinsTalk.ShowInterceptorTargetDialog(Action: Cardinal);
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
    Ship := GetPlayer.CurrentStar.Ships[I];
    if (GetPlayer <> Ship) and (GetPlayer.DockedTo <> Ship) and
      (not (Ship is TRuins) or GetPlayer.CanSelectShipTarget(Ship)) and Ship.InNormalSpace and
      (PointDistanceSquared(GetPlayer.Position, Ship.Position) <= InterceptorTargetRangeSquared) and (Ship.InterceptorPassesRemaining <= 0) then
    begin
      Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetShip');
      ReplaceTextToken(Text, '<Ship>', Ship.GetFullName(' '), TextHighlightColorTag);
      AddChoice('- ' + Text, Integer(Ship), SelectInterceptorTarget);
    end;
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetCancel'), 0, ShowInterceptorDialog);
end;
{ @end $560CB4 }

{ @routine $5610CC TfRuinsTalk_SelectInterceptorTarget }
procedure TfRuinsTalk.SelectInterceptorTarget(Action: Cardinal);
begin
  GetPlayer.GetHull.InterceptorTarget := Pointer(Action);
  ShowInterceptorDialog(0);
end;
{ @end $5610CC }

{ @routine $5610EC TfRuinsTalk_ClearInterceptorTarget }
procedure TfRuinsTalk.ClearInterceptorTarget(Action: Cardinal);
begin
  GetPlayer.GetHull.InterceptorTarget := nil;
  ShowInterceptorDialog(0);
end;
{ @end $5610EC }

{ @routine $56110C TfRuinsTalk_ShowInterceptorStrategyDialog }
procedure TfRuinsTalk.ShowInterceptorStrategyDialog(Action: Cardinal);
var
  Text: WideString;
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargeting');
  ClearChoices;
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), TextHighlightColorTag);
  AddChoice('- ' + Text, 0, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMax'), TextHighlightColorTag);
  AddChoice('- ' + Text, 1, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMin'), TextHighlightColorTag);
  AddChoice('- ' + Text, 2, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyStrMax'), TextHighlightColorTag);
  AddChoice('- ' + Text, 3, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDefMax'), TextHighlightColorTag);
  AddChoice('- ' + Text, 4, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMin'), TextHighlightColorTag);
  AddChoice('- ' + Text, 5, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMax'), TextHighlightColorTag);
  AddChoice('- ' + Text, 6, SelectInterceptorStrategy);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingCancel'), 0, ShowInterceptorDialog);
end;
{ @end $56110C }

{ @routine $5618E0 TfRuinsTalk_SelectInterceptorStrategy }
procedure TfRuinsTalk.SelectInterceptorStrategy(Action: Cardinal);
begin
  GetPlayer.GetHull.InterceptorTargetingStrategy := TInterceptorTargetingStrategy(Action);
  ShowInterceptorDialog(0);
end;
{ @end $5618E0 }

{ @routine $561904 TfRuinsTalk_ShowBridgeHelp }
procedure TfRuinsTalk.ShowBridgeHelp(Action: Cardinal);
var
  I: Integer;
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeHelpChoose');
  ClearChoices;
  for I := 1 to 5 do
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpQuestion' + IntToStr(I)), I, ShowBridgeHelpAnswer);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpCancel'), 0, ReturnToMain);
end;
{ @end $561904 }

{ @routine $561ADC TfRuinsTalk_ShowBridgeHelpAnswer }
procedure TfRuinsTalk.ShowBridgeHelpAnswer(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeHelpAnswer' + IntToStr(Action));
  ClearChoices;
  ReplaceTextToken(DialogText, '<SwitchCost>', IntToStr(10), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<BHCost>', IntToStr(600), TextHighlightColorTag);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpMoreQuestions'), 0, ShowBridgeHelp);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpNoQuestions'), 0, ReturnToMain);
end;
{ @end $561ADC }

{ @routine $561DB0 TfRuinsTalk_BuildBuiltinServiceOptions }
procedure TfRuinsTalk.BuildBuiltinServiceOptions;
const AllSeries = [series_blazer, series_keller, series_terron];
var
  Text: WideString;
begin
  if StationBridgeMode = 1 then
  begin
    if GetPlayer.GetHull.ImpulseShieldsEnabled then
      Text := LocalizedColorText('FormRuins.Bridge.BridgeImpulseShieldsOff')
    else Text := LocalizedColorText('FormRuins.Bridge.BridgeImpulseShieldsOn');
    ReplaceTextToken(Text, '<SwitchCost>', IntToStr(10), TextHighlightColorTag);
    if GetPlayer.GetHull.Energy >= 10 then AddChoice('- ' + Text, 0, ToggleImpulseShields)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
    Text := LocalizedColorText('FormRuins.Bridge.BridgeBHAsk');
    ReplaceTextToken(Text, '<Cost>', IntToStr(600), TextHighlightColorTag);
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
      station_ranger_center:
        begin
          if GetPlayer.GetCarriedNodeCount > 0 then
            AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.RC.SaleNod.PlayerSend'), TextHighlightColorTag, '<Count>', IntToStr(GetPlayer.GetCarriedNodeCount)), 0, DepositNodesAtRangerCenter);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerSend'), 0, ShowRangerCenterTakeNodeDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.GiveNod.PlayerSend'), 0, ShowRangerCenterGiveNodeDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.AboutNod.PlayerSend'), 0, ShowRangerCenterNodeInfo);
          if Galaxy.PirateWinTurn = 0 then
            AddChoice('- ' + LocalizedColorText('FormRuins.RC.PirateClan.PlayerSend'), 0, ShowRangerCenterPirateClanAnswer);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.Rating.PlayerSend'), 0, ShowRangerCenterRatingAnswer);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.BestRanger.PlayerSend'), 0, ShowRangerCenterBestRangerAnswer);
        end;
      station_pirate_base:
        begin
          AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeNationality.ChangeNationality'), 0, ShowPirateBaseNationalityDialog);
          if GetPlayer.PirateClanReal and (GetPlayer.OwnerId <> owner_pirate) and (Galaxy.PirateWinType <> 3) then
            AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.ChangeSideToPirate'), 0, ShowPirateBaseSideChangeDialog);
          if (GetPlayer.OwnerId = owner_pirate) and (Galaxy.CoalitionDefeatedTurn = 0) then
            AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.ChangeSideToNormal'), 0, ShowPirateBaseSideChangeDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.PB.Program.PlayerAsk'), 0, ShowPirateBaseProgramDialog);
          if Galaxy.ArePirateNodesEnabled then
            AddChoice('- ' + LocalizedColorText('FormRuins.PB.Nod.PlayerAsk'), 0, ShowPirateBaseNodeDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.PB.Repair.PlayerSend'), 0, ShowPirateBaseRepairDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.PB.Chameleon.PlayerAsk'), 0, ShowPirateBaseChameleonDialog);
          if GetPlayer.MayTakeSubCrack then
          begin
            if GetPlayer.GetSubCrackCost <= GetPlayer.Money then
              AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerInfo'), 0, ShowPirateBaseSubCrackDialog)
            else AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerInfo'), 0, ScriptDialogBlockCallback);
          end;
        end;
      station_military_base:
        begin
          if GetPlayer.CurrentStar.ControlFaction = faction_dominators then
          begin
            ClearChoices;
            AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerHangar'), 0, OpenHangar);
          end
          else
          begin
            if GetPlayer.OwnerId <> owner_pirate then
            begin
              AddChoice('- ' + LocalizedColorText('FormRuins.WB.WarWithKlingAndPirates.PlayerSend'), 0, I_WarWithKlingAndPirates);
              if GetPlayer.Rank < 6 then
                AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.WB.NextRank.PlayerSend'), TextHighlightColorTag, '<NextRank>', GetPlayer.GetNextRankName), 0, ShowMilitaryBaseNextRankDialog);
              AddChoice('- ' + LocalizedColorText('FormRuins.WB.Repair.PlayerSend'), 0, ShowMilitaryBaseRepairDialog);
              AddChoice('- ' + LocalizedColorText('FormRuins.WB.WarOperation.PlayerSend'), 0, ShowMilitaryBaseWarOperationDialog);
              if ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
                ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) then
                AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerAsk'), TextHighlightColorTag, '<StarEnemy>', (GetPlayer.DockedTo as TRuins).FlyToStar.Name), 0, ShowMilitaryBaseTravelDialog);
            end
            else AddChoice('- ' + LocalizedColorText('FormRuins.WB.Repair.PlayerSend'), 0, ShowMilitaryBaseRepairDialog);
            if GetPlayer.CountProgramRewardStocks > 0 then
              AddChoice('- ' + LocalizedColorText('FormRuins.WB.Programms.PlayerAsk'), 0, ShowMilitaryBaseProgramsDialog);
          end;
        end;
      station_science_base:
        begin
          AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerSend'), 0, ShowScienceBaseImprovementDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.SB.Repair.PlayerSend'), 0, ShowScienceBaseRepairDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.SB.Satellite.PlayerSend'), 0, ShowScienceBaseSatelliteOfferDialog);
          if Galaxy.HasUnresolvedDominatorSeries(AllSeries) and
            not Galaxy.IsDominatorResearchComplete(AllSeries) then
            AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerAsk'), 0, ShowScienceBaseResearchDialog);
          if Galaxy.IsDominatorSeriesUnresolved(series_blazer) and Galaxy.IsDominatorResearchComplete([series_blazer]) and not GetPlayer.HasProgram(program_logical_negation) then
            AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechBlazer'), 1, BuyScienceBaseResearchProgram);
          if Galaxy.IsDominatorSeriesUnresolved(series_keller) and Galaxy.IsDominatorResearchComplete([series_keller]) and not GetPlayer.HasProgram(program_dematerial) then
            AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechKeller'), 2, BuyScienceBaseResearchProgram);
          if Galaxy.IsDominatorSeriesUnresolved(series_terron) and Galaxy.IsDominatorResearchComplete([series_terron]) and not GetPlayer.HasProgram(program_energotron) then
            AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechTerron'), 3, BuyScienceBaseResearchProgram);
          if Galaxy.CurrentTurn - GalaxyWarmupTurns < 120 then
            AddChoice('- ' + LocalizedColorText('FormRuinsSB.History.PlayerOk'), 0, ShowScienceBaseHistoryDialog);
        end;
      station_business_center:
        begin
          if GetPlayer.DebtAmount = 0 then
            AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerSend'), 0, ShowBusinessCenterDebtDialog)
          else
          begin
            if GetPlayer.Money > GetPlayer.DebtAmount then
              AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.BK.RetDebt.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(GetPlayer.DebtAmount)), 0, RepayBusinessCenterDebt)
            else AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.BK.RetDebt.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(GetPlayer.DebtAmount)), 0, ScriptDialogBlockCallback);
          end;
          if GetPlayer.DebtDefaultCount < 3 then
          begin
            if GetPlayer.DepositAmount = 0 then
              AddChoice('- ' + LocalizedColorText('FormRuins.BK.Deposit.PlayerSend'), 0, ShowBusinessCenterDepositDialog)
            else
            begin
              if Galaxy.CurrentTurn - GetPlayer.DepositStartTurn > 30 then
                AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.BK.RetDeposit.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(GetPlayer.ComputeDepositAccruedValue)), 0, WithdrawBusinessCenterDeposit)
              else AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.BK.RetDeposit.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(GetPlayer.ComputeDepositAccruedValue)), 0, ScriptDialogBlockCallback);
            end;
            AddChoice('- ' + LocalizedColorText('FormRuins.BK.Investment.PlayerSend'), 0, ShowBusinessCenterInvestmentDialog);
            AddChoice('- ' + LocalizedColorText('FormRuins.BK.Trade.PlayerSend'), 0, ShowBusinessCenterTradeDialog);
            if GetPlayer.MedicalPolicyTicks <= 0 then
              AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerSend'), 0, ShowBusinessCenterMedicalPolicyDialog);
          end;
        end;
      station_medical_base:
        begin
          AddChoice('- ' + LocalizedColorText('FormRuins.MC.Illnes.PlayerSend'), 0, ShowMedicalCenterIllnessTreatmentDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.MC.Stimulants.PlayerSend'), 0, ShowMedicalCenterStimulantDialog);
        end;
      station_dominion:
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
{ @end $561DB0 }

{ @routine $564484 TfRuinsTalk_ContinueScriptDialog }
procedure TfRuinsTalk.ContinueScriptDialog;
begin
  CurrentScript.ExecuteDialogAnswer(CurrentScript.CurrentAnswer);
  M_Main(True);
end;
{ @end $564484 }

{ @routine $5644A8 TfRuinsTalk_AddScriptTakeoffChoice }
procedure TfRuinsTalk.AddScriptTakeoffChoice(Caption: WideString);
begin
  if Caption = '' then AddChoice('- ' + LocalizedColorText('FormRuins.I_TakeOff'), CurrentScript.CurrentAnswer, RunScriptTakeoff)
  else AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptTakeoff);
end;
{ @end $5644A8 }

{ @routine $56459C TfRuinsTalk_AddScriptNewsExitChoice }
procedure TfRuinsTalk.AddScriptNewsExitChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptNewsExit);
end;
{ @end $56459C }

{ @routine $564620 TfRuinsTalk_AddScriptHangarChoice }
procedure TfRuinsTalk.AddScriptHangarChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptHangar);
end;
{ @end $564620 }

{ @routine $5646A4 TfRuinsTalk_AddScriptGoodsChoice }
procedure TfRuinsTalk.AddScriptGoodsChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptGoods);
end;
{ @end $5646A4 }

{ @routine $564728 TfRuinsTalk_AddScriptGameEndChoice }
procedure TfRuinsTalk.AddScriptGameEndChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptGameEnd);
end;
{ @end $564728 }

{ @routine $5647AC TfRuinsTalk_SelectScriptDialog }
procedure TfRuinsTalk.SelectScriptDialog(ScriptValue: Cardinal);
begin
  ClearChoices;
  CurrentScript := TScript(ScriptValue);
  CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $5647AC }

{ @routine $5647D4 TfRuinsTalk_RunScriptAnswer }
procedure TfRuinsTalk.RunScriptAnswer(Answer: Cardinal);
begin
  ClearChoices;
  ScriptDialogIndex := -1;
  CurrentScript.ExecuteDialogAnswer(Answer);
  if ScriptDialogIndex < 0 then RaiseWideMessage('I_Script');
  CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $5647D4 }

{ @routine $564838 TfRuinsTalk_RunScriptAnswerKeepingScroll }
procedure TfRuinsTalk.RunScriptAnswerKeepingScroll(Answer: Cardinal);
begin
  RememberChoiceScroll;
  RunScriptAnswer(Answer);
end;
{ @end $564838 }

{ @routine $564854 TfRuinsTalk_RunScriptTakeoff }
procedure TfRuinsTalk.RunScriptTakeoff(Answer: Cardinal);
begin
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  CurrentScript.ExecuteDialogAnswer(Answer);
  if not HangarScreen.TryTakeOff then RequestedScreenId := screen_hangar;
  RequestClose(1);
end;
{ @end $564854 }

{ @routine $564904 TfRuinsTalk_RunScriptNewsExit }
procedure TfRuinsTalk.RunScriptNewsExit(Answer: Cardinal);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  StationPanel.InformationClicked(nil);
end;
{ @end $564904 }

{ @routine $564924 TfRuinsTalk_RunScriptHangar }
procedure TfRuinsTalk.RunScriptHangar(Answer: Cardinal);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  StationPanel.HangarClicked(nil);
end;
{ @end $564924 }

{ @routine $564944 TfRuinsTalk_OpenHangar }
procedure TfRuinsTalk.OpenHangar(Action: Cardinal);
begin
  StationPanel.HangarClicked(nil);
end;
{ @end $564944 }

{ @routine $564954 TfRuinsTalk_RunScriptGoods }
procedure TfRuinsTalk.RunScriptGoods(Answer: Cardinal);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  StationPanel.GoodsShopClicked(nil);
end;
{ @end $564954 }

{ @routine $564974 TfRuinsTalk_RunScriptGameEnd }
procedure TfRuinsTalk.RunScriptGameEnd(Answer: Cardinal);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  GameEndReason := game_end_default;
  RequestedScreenId := screen_game_end;
  RequestClose(1);
end;
{ @end $564974 }

{ @routine $5649A4 TfRuinsTalk_ReturnToMain }
procedure TfRuinsTalk.ReturnToMain(Action: Cardinal);
begin
  M_Main(False);
end;
{ @end $5649A4 }

{ @routine $5649AC TfRuinsTalk_OpenStationModernization }
procedure TfRuinsTalk.OpenStationModernization(QuotedCost: Cardinal);
var
  Cost: Integer;
  Station: TRuins;
  Text: WideString;
begin
  Cost := 0;
  Station := GetPlayer.DockedTo as TRuins;
  if QuotedCost > 0 then
  begin
    GetPlayer.SetMoney(Max(0, GetPlayer.Money - Trunc(QuotedCost)));
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
      station_pirate_base: DialogText := LocalizedColorText('FormRuins.PB.Modern.Answer');
      station_military_base: DialogText := LocalizedColorText('FormRuins.WB.Modern.Answer');
      station_dominion: DialogText := LocalizedColorText('FormRuins.CB.Modern.Answer');
    else DialogText := LocalizedColorText('FormRuins.GN.Modern.Answer');
    end;
    DialogText := FormatText1(DialogText, TextHighlightColorTag, '<Money>', IntToStr(Cost));
    ClearChoices;
    Text := '- ' + LocalizedColorText('FormRuins.GN.Modern.PlayerOk');
    if GetPlayer.Money >= Cost then AddChoice(Text, Cost, OpenStationModernization)
    else AddChoice(Text, 0, ScriptDialogBlockCallback);
    AddChoice('- ' + LocalizedColorText('FormRuins.GN.Modern.PlayerNo'), 0, DeclineStationModernization);
  end;
end;
{ @end $5649AC }

{ @routine $564E5C TfRuinsTalk_DeclineStationModernization }
procedure TfRuinsTalk.DeclineStationModernization(Action: Cardinal);
begin
  case GetPlayer.DockedTo.TypeId of
    station_pirate_base: DialogText := LocalizedColorText('FormRuins.PB.Modern.AfterNo');
    station_military_base: DialogText := LocalizedColorText('FormRuins.WB.Modern.AfterNo');
    station_dominion: DialogText := LocalizedColorText('FormRuins.CB.Modern.AfterNo');
  else DialogText := LocalizedColorText('FormRuins.GN.Modern.AfterNo');
  end;
  M_Main(True);
end;
{ @end $564E5C }

{ @routine $565024 TfRuinsTalk_DepositNodesAtRangerCenter }
procedure TfRuinsTalk.DepositNodesAtRangerCenter(Action: Cardinal);
var
  Count: Integer;
begin
  Count := GetPlayer.GetCarriedNodeCount;
  GetPlayer.DepositCarriedNodes;
  GetPlayer.AchievementStats.CheckNodesAchievement;
  Galaxy.RefreshRangerRatingPlaces;
  SoundManager.PlaySound('Sound.Sell');
  DialogText := LocalizedColorText('FormRuins.RC.SaleNod.RCAnswer');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(Count), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<BaseNod>', IntToStr(GetPlayer.BaseNodes), TextHighlightColorTag);
  M_Main(True);
end;
{ @end $565024 }

{ @routine $565200 TfRuinsTalk_ShowRangerCenterTakeNodeDialog }
procedure TfRuinsTalk.ShowRangerCenterTakeNodeDialog(Action: Cardinal);
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
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeLowPriorityCost), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeLowPriorityModule].Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Text>', GetMicroModuleInfoText(NodeExchangeLowPriorityModule, TextHighlightColorTag), '');
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
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeMediumPriorityCost), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeMediumPriorityModule].Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Text>', GetMicroModuleInfoText(NodeExchangeMediumPriorityModule, TextHighlightColorTag), '');
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
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeHighPriorityCost), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeHighPriorityModule].Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Text>', GetMicroModuleInfoText(NodeExchangeHighPriorityModule, TextHighlightColorTag), '');
  DialogText := DialogText + #13#10 + Text;
  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.TakeNod.RCAnswerEnd');
  ReplaceTextToken(DialogText, '<BaseNod>', IntToStr(GetPlayer.BaseNodes), TextHighlightColorTag);
  ClearChoices;
  Text := '- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerOk');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeLowPriorityCost), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeLowPriorityModule].Name, TextHighlightColorTag);
  if GetPlayer.BaseNodes >= NodeExchangeLowPriorityCost then AddChoice(Text, 3, BuyRangerCenterMicroModule)
  else AddChoice(Text, 0, ScriptDialogBlockCallback);
  Text := '- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerOk');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeMediumPriorityCost), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeMediumPriorityModule].Name, TextHighlightColorTag);
  if GetPlayer.BaseNodes >= NodeExchangeMediumPriorityCost then AddChoice(Text, 2, BuyRangerCenterMicroModule)
  else AddChoice(Text, 0, ScriptDialogBlockCallback);
  Text := '- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerOk');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeHighPriorityCost), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeHighPriorityModule].Name, TextHighlightColorTag);
  if GetPlayer.BaseNodes >= NodeExchangeHighPriorityCost then AddChoice(Text, 1, BuyRangerCenterMicroModule)
  else AddChoice(Text, 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerNo'), 0, DeclineRangerCenterNodeDeposit);
end;
{ @end $565200 }

{ @routine $565E00 TfRuinsTalk_BuyRangerCenterMicroModule }
procedure TfRuinsTalk.BuyRangerCenterMicroModule(Action: Cardinal);
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
  ReplaceTextToken(DialogText, '<NodCnt>', IntToStr(Cost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Name>', MicroModuleTemplates[ModuleIndex].Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<RC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
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
{ @end $565E00 }

{ @routine $56617C TfRuinsTalk_DeclineRangerCenterNodeDeposit }
procedure TfRuinsTalk.DeclineRangerCenterNodeDeposit(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.RC.TakeNod.RCAfterPlayerNo');
  M_Main(True);
end;
{ @end $56617C }

{ @routine $566228 TfRuinsTalk_ShowRangerCenterGiveNodeDialog }
procedure TfRuinsTalk.ShowRangerCenterGiveNodeDialog(Action: Cardinal);
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
    Item := GetPlayer.Inventory[I];
    if Item.ItemType = item_micro_module then
    begin
      Module := Item as TMicroModule;
      DialogText := DialogText + #13#10 + FormatText2(LocalizedColorText('FormRuins.RC.GiveNod.Nod'), TextHighlightColorTag, '<Name>', Module.GetHighlightedName, '<Count>', IntToStr(Module.CalculateNodeExchangeValue(NodeExchangeLowPriorityCost, NodeExchangeMediumPriorityCost)));
      Inc(Count);
    end;
  end;
  if Count > 0 then
  begin
    DialogText := DialogText + #13#10 + '----------------------------';
    DialogText := DialogText + #13#10 + FormatText1(LocalizedColorText('FormRuins.RC.GiveNod.Sum'), TextHighlightColorTag, '<BaseNod>', IntToStr(GetPlayer.BaseNodes));
  end
  else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.GiveNod.Nothing');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.RC.GiveNod.PlayerNo'), 0, DeclineRangerCenterNodeReward);
  if Count > 0 then
    for I := 0 to GetPlayer.Inventory.Count - 1 do
    begin
      Item := GetPlayer.Inventory[I];
      if Item.ItemType = item_micro_module then
      begin
        Module := Item as TMicroModule;
        AddChoice(FormatText2('- ' + LocalizedColorText('FormRuins.RC.GiveNod.PlayerOk'), TextHighlightColorTag, '<Name>', Module.GetHighlightedName, '<Count>', IntToStr(Module.CalculateNodeExchangeValue(NodeExchangeLowPriorityCost, NodeExchangeMediumPriorityCost))), Module.Id, ExchangeMicroModuleForNodes);
      end;
    end;
end;
{ @end $566228 }

{ @routine $566CA0 TfRuinsTalk_ExchangeMicroModuleForNodes }
procedure TfRuinsTalk.ExchangeMicroModuleForNodes(Action: Cardinal);
var
  I, Value: Integer;
  Item: TItem;
  Module: TMicroModule;
begin
  Module := nil;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.ItemType = item_micro_module then
    begin
      Module := Item as TMicroModule;
      if Module.Id = Action then Break;
      Module := nil;
    end;
  end;
  if Module = nil then RaiseWideMessage('Косяк: TfRuinsTalk.I_GiveNodOk [FId = ' + IntToStr(Action) + ']');
  Value := Module.CalculateNodeExchangeValue(NodeExchangeLowPriorityCost, NodeExchangeMediumPriorityCost);
  DialogText := FormatText2(LocalizedColorText('FormRuins.RC.GiveNod.AfterOk'), TextHighlightColorTag, '<Name>', Module.GetHighlightedName, '<Count>', IntToStr(Value));
  GetPlayer.Inventory.Delete(GetPlayer.Inventory.IndexOf(Module));
  Module.Free;
  Inc(GetPlayer.BaseNodes, Value);
  GetPlayer.AchievementStats.CheckNodesAchievement;
  GetPlayer.RefreshDerivedStats(True);
  SoundManager.PlaySound('Sound.Sell');
  ShowRangerCenterGiveNodeDialog(Action);
end;
{ @end $566CA0 }

{ @routine $566F7C TfRuinsTalk_DeclineRangerCenterNodeReward }
procedure TfRuinsTalk.DeclineRangerCenterNodeReward(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.RC.GiveNod.AfterNo');
  M_Main(True);
end;
{ @end $566F7C }

{ @routine $567018 TfRuinsTalk_ShowRangerCenterNodeInfo }
procedure TfRuinsTalk.ShowRangerCenterNodeInfo(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.RC.AboutNod.RCAnswer');
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(30), TextHighlightColorTag);
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.I_Continue'), 0, ShowRangerCenterNodeInfoContinuation);
end;
{ @end $567018 }

{ @routine $5671B4 TfRuinsTalk_ShowRangerCenterNodeInfoContinuation }
procedure TfRuinsTalk.ShowRangerCenterNodeInfoContinuation(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.RC.AboutNod.RCAnswerAdd');
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(30), TextHighlightColorTag);
  M_Main(True);
end;
{ @end $5671B4 }

{ @routine $5672E0 TfRuinsTalk_ShowRangerCenterRatingAnswer }
procedure TfRuinsTalk.ShowRangerCenterRatingAnswer(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.RC.Rating.RCAnswer');
  M_Main(True);
end;
{ @end $5672E0 }

{ @routine $56737C TfRuinsTalk_ShowRangerCenterPirateClanAnswer }
procedure TfRuinsTalk.ShowRangerCenterPirateClanAnswer(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.RC.PirateClan.RCAnswer');
  M_Main(True);
end;
{ @end $56737C }

{ @routine $567420 TfRuinsTalk_ShowRangerCenterBestRangerAnswer }
procedure TfRuinsTalk.ShowRangerCenterBestRangerAnswer(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.RC.BestRanger.RCAnswer');
  M_Main(True);
end;
{ @end $567420 }

{ @routine $5674C4 TfRuinsTalk_ShowPirateBaseNationalityDialog }
procedure TfRuinsTalk.ShowPirateBaseNationalityDialog(Action: Cardinal);
var
  Text: WideString;
  I: Integer;
  Factor: Double;
  C, D, E, DE, CDE, B, BCDE, A, MinimumCost: Integer;
begin
  DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AnswerChangeNationality');
  Text := LocalizedColorText('FormRuins.PB.ChangeNationality.PBNext');
  Factor := 1;
  for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
  begin
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + TurnsPerYear < Galaxy.CurrentTurn then Break;
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerChangesNationality' then Factor := Factor * 1.5;
  end;
  ReplaceTextToken(Text, '<MoneyMaloc>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(owner_maloc) * Factor)), TextHighlightColorTag);
  ReplaceTextToken(Text, '<MoneyPeleng>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(owner_peleng) * Factor)), TextHighlightColorTag);
  ReplaceTextToken(Text, '<MoneyPeople>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(owner_human) * Factor)), TextHighlightColorTag);
  ReplaceTextToken(Text, '<MoneyFei>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(owner_feyan) * Factor)), TextHighlightColorTag);
  ReplaceTextToken(Text, '<MoneyGaal>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(owner_gaal) * Factor)), TextHighlightColorTag);
  DialogText := DialogText + Text;
  ClearChoices;
  A := Galaxy.ComputeScaledBigMoney(owner_maloc);
  B := Galaxy.ComputeScaledBigMoney(owner_peleng);
  C := Galaxy.ComputeScaledBigMoney(owner_human);
  D := Galaxy.ComputeScaledBigMoney(owner_feyan);
  E := Galaxy.ComputeScaledBigMoney(owner_gaal);
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
{ @end $5674C4 }

{ @routine $567AF8 TfRuinsTalk_AcceptPirateBaseNationality }
procedure TfRuinsTalk.AcceptPirateBaseNationality(Action: Cardinal);
const
  RelationShipTypes = [hull_ranger, hull_pirate..hull_diplomat];
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
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + TurnsPerYear < Galaxy.CurrentTurn then Break;
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerChangesNationality' then Factor := Factor * 1.5;
  end;
  SelectFaceScreen.PlayerRace := GetPlayer.PilotRace;
  SelectFaceScreen.CaptainPortraitIndex := GetPlayer.PortraitFaceId;
  SelectFaceScreen.PlayerName := GetPlayer.Name;
  SelectFaceScreen.NationalityCosts[owner_maloc] := Round(Galaxy.ComputeScaledBigMoney(owner_maloc) * Factor);
  SelectFaceScreen.NationalityCosts[owner_peleng] := Round(Galaxy.ComputeScaledBigMoney(owner_peleng) * Factor);
  SelectFaceScreen.NationalityCosts[owner_human] := Round(Galaxy.ComputeScaledBigMoney(owner_human) * Factor);
  SelectFaceScreen.NationalityCosts[owner_feyan] := Round(Galaxy.ComputeScaledBigMoney(owner_feyan) * Factor);
  SelectFaceScreen.NationalityCosts[owner_gaal] := Round(Galaxy.ComputeScaledBigMoney(owner_gaal) * Factor);
  SelectFaceScreen.AvailableMoney := GetPlayer.Money;
  Galaxy.PrimeIntegrityChecksum(320);
  if RunSelectFaceDialog(Self) then
  begin
    Galaxy.CheckIntegrityChecksum(321);
    GetPlayer.PortraitFaceId := SelectFaceScreen.CaptainPortraitIndex;
    GetPlayer.PilotRace := SelectFaceScreen.PlayerRace;
    if GetPlayer.OwnerId <> owner_pirate then GetPlayer.OwnerId := RaceToOwner(SelectFaceScreen.PlayerRace);
    GetPlayer.Name := SelectFaceScreen.PlayerName;
    LastLoadedPlayerName := GetPlayer.Name;
    GetPlayer.SetMoney(Max(0, GetPlayer.Money - Max(0, SelectFaceScreen.AcceptedCost)));
    GetPlayer.AddPirateCareerActivity(8);
    Inc(GetPlayer.NationalityChangeCount);
    TryAddAchievementProgress('MANYFACES', 1);
    for J := 1 to 12 do
    begin
      if CaptainHealthDefinitions[J].Disabled then Continue;
      if RaceToOwner(GetPlayer.PilotRace) in CaptainHealthDefinitions[J].AllowedOwners then Continue;
      if GetPlayer.CaptainHealth[J].Progress >= 100 then Continue;
      GetPlayer.CaptainHealth[J].Progress := 0;
      GetPlayer.StatusEffectSourceNames[J] := '';
    end;
    GetPlayer.ChangePlanetRelations(nil, relation_change_floor, 70, PlanetOwnerMasks.Coalition);
    GetPlayer.ChangeShipRelations(nil, relation_change_floor, 70, RelationShipTypes, PlanetOwnerMasks.Coalition);
    if MainPiratePlanet <> nil then
    begin
      RangerIndex := Galaxy.Rangers.IndexOf(GetPlayer);
      Relation := Byte(MainPiratePlanet.RangerRelations[RangerIndex]);
      if Relation < 45 then MainPiratePlanet.RangerRelations[RangerIndex] := Pointer(45);
    end;
    GetPlayer.ChangeShipRelations(nil, relation_change_floor, 45, RelationShipTypes, PlanetOwnerMasks.PirateClan);
    SoundManager.PlaySound('Sound.Sell');
    Event := AddGalaxyEvent('PlayerChangesNationality');
    Event.AddData(Ord(GetPlayer.PilotRace));
    case SelectFaceScreen.PlayerRace of
      owner_maloc: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationMaloc');
      owner_peleng: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationPeleng');
      owner_human: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationPeople');
      owner_feyan: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationFei');
      owner_gaal: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationGaal');
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
{ @end $567AF8 }

{ @routine $5683BC TfRuinsTalk_DeclinePirateBaseNationality }
procedure TfRuinsTalk.DeclinePirateBaseNationality(Action: Cardinal);
begin
  if Galaxy.CoalitionDefeatedTurn = 0 then DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.PBAfterNo')
  else DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.PBAfterNoAlt');
  ClearChoices;
  M_Main(True);
end;
{ @end $5683BC }

{ @routine $568508 TfRuinsTalk_ShowPirateBaseSideChangeDialog }
procedure TfRuinsTalk.ShowPirateBaseSideChangeDialog(Action: Cardinal);
var
  I: Integer;
begin
  if GetPlayer.OwnerId = owner_pirate then DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerChangeSideToNormal')
  else DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerChangeSideToPirate');
  StationServiceQuoteCost := Galaxy.ComputeScaledHugeMoney(owner_human);
  for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
  begin
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + TurnsPerYear < Galaxy.CurrentTurn then Break;
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerChangesSide' then
      StationServiceQuoteCost := Min(Int64(MaxMonetaryValue), Round(StationServiceQuoteCost * 1.5));
  end;
  ReplaceTextToken(DialogText, '<Cost>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
  ClearChoices;
  if GetPlayer.Money >= StationServiceQuoteCost then
    AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.PlayerOk'), 0, AcceptPirateBaseSideChange)
  else
    AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.PlayerOk'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.PlayerNo'), 0, DeclinePirateBaseSideChange);
end;
{ @end $568508 }

{ @routine $568920 TfRuinsTalk_AcceptPirateBaseSideChange }
procedure TfRuinsTalk.AcceptPirateBaseSideChange(Action: Cardinal);
const
  RelationShipTypes = [hull_ranger, hull_pirate..hull_diplomat];
var
  Event: TGalaxyEvent;
  I, RangerIndex: Integer;
  Relation: Byte;
begin
  if GetPlayer.OwnerId = owner_pirate then GetPlayer.OwnerId := RaceToOwner(GetPlayer.PilotRace)
  else GetPlayer.OwnerId := owner_pirate;
  StationServiceQuoteCost := Galaxy.ComputeScaledHugeMoney(owner_human);
  for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
  begin
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + TurnsPerYear < Galaxy.CurrentTurn then Break;
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerChangesSide' then
      StationServiceQuoteCost := Min(Int64(MaxMonetaryValue), Round(StationServiceQuoteCost * 1.5));
  end;
  GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
  SoundManager.PlaySound('Sound.Sell');
  Inc(GetPlayer.SideChangeCount);
  TrySetAchievementProgress('SIDECHANGER', GetPlayer.SideChangeCount);
  RangerIndex := Galaxy.Rangers.IndexOf(GetPlayer);
  if MainPiratePlanet <> nil then Relation := Byte(MainPiratePlanet.RangerRelations[RangerIndex])
  else Relation := 0;
  if GetPlayer.OwnerId = owner_pirate then
  begin
    if (Relation < 45) and (MainPiratePlanet <> nil) then MainPiratePlanet.RangerRelations[RangerIndex] := Pointer(45);
    GetPlayer.ChangeShipRelations(nil, relation_change_floor, 45, RelationShipTypes, PlanetOwnerMasks.PirateClan);
    GetPlayer.ChangePlanetRelations(nil, relation_change_cap, 20, PlanetOwnerMasks.Coalition);
    GetPlayer.ChangeShipRelations(nil, relation_change_cap, 20, RelationShipTypes, PlanetOwnerMasks.Coalition);
    DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerPlayerOkPirate');
  end
  else
  begin
    GetPlayer.ChangePlanetRelations(nil, relation_change_floor, 45, PlanetOwnerMasks.Coalition);
    GetPlayer.ChangeShipRelations(nil, relation_change_floor, 45, RelationShipTypes, PlanetOwnerMasks.Coalition);
    if (Relation > 20) and (MainPiratePlanet <> nil) then MainPiratePlanet.RangerRelations[RangerIndex] := Pointer(20);
    GetPlayer.ChangeShipRelations(nil, relation_change_cap, 20, RelationShipTypes, PlanetOwnerMasks.PirateClan);
    DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerPlayerOkNormal');
  end;
  Event := AddGalaxyEvent('PlayerChangesSide');
  Event.AddData(Ord(GetPlayer.OwnerId = owner_pirate));
  ClearChoices;
  M_Main(True);
end;
{ @end $568920 }

{ @routine $568D8C TfRuinsTalk_DeclinePirateBaseSideChange }
procedure TfRuinsTalk.DeclinePirateBaseSideChange(Action: Cardinal);
begin
  if GetPlayer.OwnerId = owner_pirate then DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerPlayerNoNormal')
  else DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerPlayerNoPirate');
  ClearChoices;
  M_Main(True);
end;
{ @end $568D8C }

{ @routine $568EE0 TfRuinsTalk_ShowPirateBaseNodeDialog }
procedure TfRuinsTalk.ShowPirateBaseNodeDialog(Action: Cardinal);
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
    ReplaceTextToken(Text, '<Count>', IntToStr(Count), TextHighlightColorTag);
    ReplaceTextToken(Text, '<MoneyAll>', IntToStr(Cost), TextHighlightColorTag);
    ReplaceTextToken(Text, '<Percent>', IntToStr(Discount), TextHighlightColorTag);
    ReplaceTextToken(Text, '<MoneyDec>', IntToStr(DiscountedCost), TextHighlightColorTag);
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
      ReplaceTextToken(Text, '<ToSector>', OtherBase.CurrentStar.Constellation.GetName, TextHighlightColorTag);
      ReplaceTextToken(Text, '<ToBase>', OtherBase.Name, TextHighlightColorTag);
    end;
    DialogText := Text;
    ClearChoices;
    M_Main(True);
  end;
end;
{ @end $568EE0 }

{ @routine $56940C TfRuinsTalk_BuyPirateBaseNodes }
procedure TfRuinsTalk.BuyPirateBaseNodes(Action: Cardinal);
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
{ @end $56940C }

{ @routine $569658 TfRuinsTalk_DeclinePirateBaseNodes }
procedure TfRuinsTalk.DeclinePirateBaseNodes(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.PB.Nod.PBAfterNo');
  ClearChoices;
  M_Main(True);
end;
{ @end $569658 }

{ @routine $5696F8 TfRuinsTalk_ShowPirateBaseProgramDialog }
procedure TfRuinsTalk.ShowPirateBaseProgramDialog(Action: Cardinal);
var
  I: TProgramIndex;
  Text: WideString;
  Discount, Nodes: Integer;
begin
  Text := '';
  for I := Low(PirateProgramQuoteCosts) to High(PirateProgramQuoteCosts) do PirateProgramQuoteCosts[I] := 0;
  Discount := GetPlayer.GetPirateServiceDiscount;
  Text := LocalizedColorText('FormRuins.PB.Program.PBStart');
  Text := FormatText1(Text, TextHighlightColorTag, '<Percent>', WrapTextInColor(IntToStr(Discount), TextHighlightColorTag));
  Text := FormatText1(Text, TextHighlightColorTag, '<NodTrum>', WrapTextInColor(IntToStr(GetPlayer.GetAvailableNodeCount(nil)), TextHighlightColorTag));
  Text := FormatText1(Text, TextHighlightColorTag, '<NodAcc>', WrapTextInColor(IntToStr(GetPlayer.BaseNodes), TextHighlightColorTag));
  Text := Text + #13#10;
  for I := Low(PirateProgramBatchSizes) to High(PirateProgramBatchSizes) do
    if PirateProgramBatchSizes[I] <> 0 then
    begin
      Text := Text + WrapTextInColor(GetPlayer.GetProgramName(I), TextHighlightColorTag) + ' - ';
      Text := Text + FormatText1(LocalizedText('Programms.' + ProgramNames[I] + '.Text'), TextHighlightColorTag, '<Count>', IntToStr(PirateProgramBatchSizes[I])) + #13#10;
      PirateProgramQuoteCosts[I] := Max(Int64(100), PirateProgramBaseCosts[I] - Round(PirateProgramBaseCosts[I] / 100 * Discount));
      Text := Text + FormatText1(LocalizedText('FormRuins.PB.Program.NodCost'), TextHighlightColorTag, '<Cost>', IntToStr(PirateProgramQuoteCosts[I]));
      Text := Text + #13#10 + #13#10;
    end;
  DialogText := Text;
  ClearChoices;
  Nodes := GetPlayer.GetAvailableNodeCount(nil) + GetPlayer.BaseNodes;
  for I := Low(PirateProgramBatchSizes) to High(PirateProgramBatchSizes) do
    if PirateProgramBatchSizes[I] <> 0 then
    begin
      Text := ' - ' + LocalizedColorText('FormRuins.PB.Program.PlayerOk');
      Text := FormatText1(Text, TextHighlightColorTag, '<Nod>', WrapTextInColor(IntToStr(PirateProgramQuoteCosts[I]), TextHighlightColorTag));
      Text := FormatText1(Text, TextHighlightColorTag, '<Text>', WrapTextInColor(GetPlayer.GetProgramName(I), TextHighlightColorTag));
      if PirateProgramQuoteCosts[I] <= Nodes then AddChoice(Text, Ord(I), BuyPirateBaseProgram)
      else AddChoice(Text, 0, ScriptDialogBlockCallback);
    end;
  AddChoice(LocalizedColorText('FormRuins.PB.Program.PlayerNo'), 0, DeclinePirateBaseProgram);
end;
{ @end $5696F8 }

{ @routine $569E50 TfRuinsTalk_BuyPirateBaseProgram }
procedure TfRuinsTalk.BuyPirateBaseProgram(Action: Cardinal);
var
  ProgramIndex: TProgramIndex;
  Cost, CarriedNodes, BaseNodes: Integer;
begin
  ProgramIndex := TProgramIndex(Action);
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
    DialogText := FormatText1(LocalizedColorText('FormRuins.PB.Program.PBAfterOk'), TextHighlightColorTag, '<Text>', GetPlayer.GetProgramName(ProgramIndex));
    ClearChoices;
    M_Main(True);
  end
  else DeclinePirateBaseProgram(0);
end;
{ @end $569E50 }

{ @routine $56A044 TfRuinsTalk_DeclinePirateBaseProgram }
procedure TfRuinsTalk.DeclinePirateBaseProgram(Action: Cardinal);
begin
  if Galaxy.CoalitionDefeatedTurn = 0 then DialogText := LocalizedColorText('FormRuins.PB.Program.PBAfterNo')
  else DialogText := LocalizedColorText('FormRuins.PB.Program.PBAfterNoAlt');
  ClearChoices;
  M_Main(True);
end;
{ @end $56A044 }

{ @routine $56A168 TfRuinsTalk_ShowPirateBaseRepairDialog }
procedure TfRuinsTalk.ShowPirateBaseRepairDialog(Action: Cardinal);
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
    if ((Item.EquippedFlag <> 0) and ((Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = availability_not_sold_node_repair) and Item.NeedsRepair)) and ((GetPlayer.DockedTo as TRuins).CanRepairEquipmentTech(Item)) then Inc(NodeCost, Item.CalculateRepairCost);
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
    ReplaceTextToken(Text, '<MoneyAll>', IntToStr(Cost), TextHighlightColorTag);
    ReplaceTextToken(Text, '<Percent>', IntToStr(Discount), TextHighlightColorTag);
    ReplaceTextToken(Text, '<MoneyDec>', IntToStr(DiscountedCost), TextHighlightColorTag);
    ReplaceTextToken(Text, '<PB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
    DialogText := Text;
    if NodeCost <> 0 then
    begin
      DialogText := DialogText + LocalizedColorText('FormRuins.PB.Repair.PBCostAnswerNeedNode');
      ReplaceTextToken(DialogText, '<NeedNode>', IntToStr(NodeCost), TextHighlightColorTag);
    end;
    ClearChoices;
    if (GetPlayer.Money >= DiscountedCost) and ((NodeCost = 0) or ((NodeCost > 0) and (GetPlayer.GetAvailableNodeCount(nil) >= NodeCost))) then
      AddChoice('- ' + LocalizedColorText('FormRuins.PB.Repair.PlayerOk'), 0, AcceptPirateBaseRepair);
    AddChoice('- ' + LocalizedColorText('FormRuins.PB.Repair.PlayerNo'), 0, DeclinePirateBaseRepair);
  end;
end;
{ @end $56A168 }

{ @routine $56A75C TfRuinsTalk_AcceptPirateBaseRepair }
procedure TfRuinsTalk.AcceptPirateBaseRepair(Action: Cardinal);
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
      if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = availability_not_sold_node_repair) and Item.NeedsRepair then
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
{ @end $56A75C }

{ @routine $56AA24 TfRuinsTalk_DeclinePirateBaseRepair }
procedure TfRuinsTalk.DeclinePirateBaseRepair(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.PB.Repair.PBAfterNo');
  ClearChoices;
  M_Main(True);
end;
{ @end $56AA24 }

{ @routine $56AAC8 TfRuinsTalk_ShowPirateBaseSubCrackDialog }
procedure TfRuinsTalk.ShowPirateBaseSubCrackDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBInfo');
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.GetSubCrackCost), TextHighlightColorTag);
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerContinue'), 0, ConfirmPirateBaseSubCrack);
end;
{ @end $56AAC8 }

{ @routine $56ACB4 TfRuinsTalk_ConfirmPirateBaseSubCrack }
procedure TfRuinsTalk.ConfirmPirateBaseSubCrack(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBContinue');
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.GetSubCrackCost), TextHighlightColorTag);
  ClearChoices;
  AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.PB.SabCrack.PlayerOk'), TextHighlightColorTag, '<Money>', IntToStr(GetPlayer.GetSubCrackCost)), 0, BuyPirateBaseSubCrack);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerOkHalf'), 0, BuyPirateBaseSubCrackHalfPrice);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerNo'), 0, DeclinePirateBaseSubCrack);
end;
{ @end $56ACB4 }

{ @routine $56AFD8 TfRuinsTalk_BuyPirateBaseSubCrack }
procedure TfRuinsTalk.BuyPirateBaseSubCrack(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBAfterOk');
  GetPlayer.SetMoney(GetPlayer.Money - GetPlayer.GetSubCrackCost);
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.GetSubCrackCost), TextHighlightColorTag);
  GetPlayer.ProgramCounts[program_sab_crack] := 1;
  ClearChoices;
  M_Main(True);
end;
{ @end $56AFD8 }

{ @routine $56B16C TfRuinsTalk_BuyPirateBaseSubCrackHalfPrice }
procedure TfRuinsTalk.BuyPirateBaseSubCrackHalfPrice(Action: Cardinal);
var
  Cost: Integer;
begin
  Cost := GetPlayer.GetSubCrackCost div 2;
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBAfterOkHalf');
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), TextHighlightColorTag);
  GetPlayer.SetMoney(GetPlayer.Money - Cost);
  GetPlayer.ProgramCounts[program_sab_crack] := 1;
  ClearChoices;
  M_Main(True);
end;
{ @end $56B16C }

{ @routine $56B308 TfRuinsTalk_DeclinePirateBaseSubCrack }
procedure TfRuinsTalk.DeclinePirateBaseSubCrack(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBAfterNo');
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ClearChoices;
  M_Main(True);
end;
{ @end $56B308 }

{ @routine $56B40C TfRuinsTalk_ShowPirateBaseChameleonDialog }
procedure TfRuinsTalk.ShowPirateBaseChameleonDialog(Action: Cardinal);
var
  I: TDominatorSeries;
  Text, SeriesName: WideString;
  Value, Cost: Integer;
  SeriesCost, BaseCost: Single;
begin
  BaseCost := Max(1000, Galaxy.ComputeScaledBigMoney(GetPlayer.DockedTo.OwnerId));
  SeriesCost := 0;
  for I := Low(TDominatorSeries) to High(TDominatorSeries) do
  begin
    case I of
      series_keller: SeriesCost := BaseCost * 1.1;
      series_blazer: SeriesCost := BaseCost * 1.2;
      series_terron: SeriesCost := BaseCost * 1.3;
    end;
    PirateChameleonQuoteCosts[I] := Round(SeriesCost + GetPlayer.ChameleonCharges[I] * SeriesCost * 0.1);
  end;
  Text := '-----------------------' + #13#10;
  for I := Low(TDominatorSeries) to High(TDominatorSeries) do
  begin
    SeriesName := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[I] + '.0');
    Cost := PirateChameleonQuoteCosts[I];
    Text := Text + FormatText2(LocalizedColorText('FormRuins.PB.Chameleon.PlayerOk'), TextHighlightColorTag, '<Series>', SeriesName, '<Cost>', IntToStr(Cost)) + #13#10;
  end;
  Text := Text + '-----------------------';
  DialogText := FormatText1(LocalizedColorText('FormRuins.PB.Chameleon.PBAsk'), '', '<List>', Text);
  ClearChoices;
  for I := Low(TDominatorSeries) to High(TDominatorSeries) do
  begin
    Value := Ord(I);
    SeriesName := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[I] + '.0');
    Cost := PirateChameleonQuoteCosts[I];
    Text := FormatText2(LocalizedColorText('FormRuins.PB.Chameleon.PlayerOk'), TextHighlightColorTag, '<Series>', SeriesName, '<Cost>', IntToStr(Cost));
    if GetPlayer.Money >= Cost then AddChoice('- ' + Text, Value, BuyPirateBaseChameleon)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.Chameleon.PlayerNo'), 0, DeclinePirateBaseChameleon);
end;
{ @end $56B40C }

{ @routine $56B970 TfRuinsTalk_BuyPirateBaseChameleon }
procedure TfRuinsTalk.BuyPirateBaseChameleon(Action: Cardinal);
var
  Series: TDominatorSeries;
  Cost: Integer;
begin
  Series := TDominatorSeries(Action);
  Cost := PirateChameleonQuoteCosts[Series];
  Inc(GetPlayer.ChameleonCharges[Series]);
  GetPlayer.SetMoney(Max(0, GetPlayer.Money - Cost));
  SoundManager.PlaySound('Sound.Sell');
  DialogText := LocalizedColorText('FormRuins.PB.Chameleon.PBAfterOk');
  ClearChoices;
  M_Main(True);
end;
{ @end $56B970 }

{ @routine $56BA94 TfRuinsTalk_DeclinePirateBaseChameleon }
procedure TfRuinsTalk.DeclinePirateBaseChameleon(Action: Cardinal);
begin
  if Galaxy.CoalitionDefeatedTurn = 0 then DialogText := LocalizedColorText('FormRuins.PB.Chameleon.PBAfterNo')
  else DialogText := LocalizedColorText('FormRuins.PB.Chameleon.PBAfterNoAlt');
  ClearChoices;
  M_Main(True);
end;
{ @end $56BA94 }

{ @routine $56BBC0 TfRuinsTalk_I_WarWithKlingAndPirates }
procedure TfRuinsTalk.I_WarWithKlingAndPirates(Action: Cardinal);
var
  CoalitionPercent, DominatorPercent, PiratePercent: Byte;
  Key: WideString;
  EnemyStar: TStar;
  I: Integer;
begin
  EnemyStar := nil;
  CoalitionPercent := Galaxy.GetFactionControlPercent(faction_coalition);
  DominatorPercent := Galaxy.GetFactionControlPercent(faction_dominators);
  PiratePercent := Galaxy.GetFactionControlPercent(faction_pirates);
  for I := 0 to Galaxy.Stars.Count - 1 do
    if ((GetPlayer.CurrentStar.StarDistances[I].Star as TStar).ControlFaction in [faction_dominators, faction_pirates]) and
      ((GetPlayer.CurrentStar.StarDistances[I].Star as TStar).Constellation.Id <> 20) then
    begin
      EnemyStar := TStar(GetPlayer.CurrentStar.StarDistances[I].Star);
      Break;
    end;
  if EnemyStar = nil then
  begin
    if not Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]) and (Galaxy.PirateWinType <> 3) then
      Key := 'FormRuins.WB.WarWithKlingAndPirates.PiratesOnly.WBAnswerWeControl100Percent'
    else if Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]) and (Galaxy.PirateWinType = 3) then
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
  ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(CoalitionPercent), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<DominatorsPercent>', IntToStr(DominatorPercent), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<PiratesPercent>', IntToStr(PiratePercent), TextHighlightColorTag);
  if EnemyStar <> nil then
  begin
    ReplaceTextToken(DialogText, '<Star>', EnemyStar.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Sector>', EnemyStar.Constellation.GetName, TextHighlightColorTag);
  end;
  M_Main(True);
end;
{ @end $56BBC0 }

{ @routine $56C5C0 TfRuinsTalk_ShowMilitaryBaseNextRankDialog }
procedure TfRuinsTalk.ShowMilitaryBaseNextRankDialog(Action: Cardinal);
var
  I: TDominatorKind;
  Token: WideString;
begin
  DialogText := LocalizedColorText('FormRuins.WB.NextRank.WBAnswer');
  ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<NextRank>', GetPlayer.GetNextRankName, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<NeedPoints>', IntToStr(GetPlayer.GetRankPointsToNextRank), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<RankPointsForLiberationSystem>', IntToStr(30), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<RankPointsForDeadPirates>', IntToStr(10), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<RankPointsForDeadPiratesInGiperSpace>', IntToStr(2), TextHighlightColorTag);
  for I := Low(TDominatorKind) to High(TDominatorKind) do
  begin
    if I = dominator_boss then Continue;
    Token := '<Name' + IntToStr(Ord(I)) + '>';
    ReplaceTextToken(DialogText, Token, DominatorShipDefinitions[I].DisplayNames[series_blazer], '');
    Token := '<RankPointsFor' + DominatorShipTypeKeys[I] + '>';
    ReplaceTextToken(DialogText, Token, IntToStr(DominatorShipDefinitions[I].RankPoints), TextHighlightColorTag);
  end;
  M_Main(True);
end;
{ @end $56C5C0 }

{ @routine $56CA2C TfRuinsTalk_ShowMilitaryBaseRepairDialog }
procedure TfRuinsTalk.ShowMilitaryBaseRepairDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.WB.Repair.WBAnswer');
  ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.Repair.PlayerCostAsk'), 0, ShowMilitaryBaseRepairQuote);
end;
{ @end $56CA2C }

{ @routine $56CBB0 TfRuinsTalk_ShowMilitaryBaseRepairQuote }
procedure TfRuinsTalk.ShowMilitaryBaseRepairQuote(Action: Cardinal);
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
    ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), TextHighlightColorTag);
    ClearChoices;
    if (Cost > 0) and (GetPlayer.Money >= Cost) then
      AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.WB.Repair.PlayerOk'), TextHighlightColorTag, '<Money>', IntToStr(Cost)), 0, AcceptMilitaryBaseRepair);
    AddChoice('- ' + LocalizedColorText('FormRuins.WB.Repair.PlayerNo'), 0, DeclineMilitaryBaseRepair);
  end;
end;
{ @end $56CBB0 }

{ @routine $56CFE4 TfRuinsTalk_AcceptMilitaryBaseRepair }
procedure TfRuinsTalk.AcceptMilitaryBaseRepair(Action: Cardinal);
begin
  (GetPlayer.DockedTo as TRuins).RepairShipEquipment(GetPlayer);
  GetPlayer.RefreshDerivedStats(True);
  DialogText := LocalizedColorText('FormRuins.WB.Repair.WBAfterOk');
  SoundManager.PlaySound('Sound.Repair');
  M_Main(True);
end;
{ @end $56CFE4 }

{ @routine $56D0E0 TfRuinsTalk_DeclineMilitaryBaseRepair }
procedure TfRuinsTalk.DeclineMilitaryBaseRepair(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.WB.Repair.WBAfterNo');
  M_Main(True);
end;
{ @end $56D0E0 }

{ @routine $56D17C TfRuinsTalk_ShowMilitaryBaseProgramsDialog }
procedure TfRuinsTalk.ShowMilitaryBaseProgramsDialog(Action: Cardinal);
var
  Text, Info: WideString;
  I: TProgramIndex;
begin
  Text := '';
  for I := Low(ProgramNames) to High(ProgramNames) do
    if GetPlayer.ProgramRewardStocks[I] > 0 then
    begin
      Info := LocalizedColorText('FormRuins.WB.Programms.Info');
      ReplaceTextToken(Info, '<Name>', GetPlayer.GetProgramName(I), TextHighlightColorTag);
      ReplaceTextToken(Info, '<Text>', FormatText1(LocalizedText('Programms.' + ProgramNames[I] + '.Text'), TextHighlightColorTag, '<Count>', IntToStr(GetPlayer.ProgramRewardStocks[I])), '');
      ReplaceTextToken(Info, '<Count>', IntToStr(GetPlayer.ProgramRewardStocks[I]), TextHighlightColorTag);
      if Text = '' then Text := Info
      else Text := Text + #13#10 + Info;
    end;
  DialogText := LocalizedColorText('FormRuins.WB.Programms.WBAnswer');
  ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Programms>', Text, '');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.Programms.PlayerOk'), 0, AcceptMilitaryBasePrograms);
end;
{ @end $56D17C }

{ @routine $56D554 TfRuinsTalk_AcceptMilitaryBasePrograms }
procedure TfRuinsTalk.AcceptMilitaryBasePrograms(Action: Cardinal);
var
  I: TProgramIndex;
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
{ @end $56D554 }

{ @routine $56D664 TfRuinsTalk_ShowMilitaryBaseWarOperationDialog }
procedure TfRuinsTalk.ShowMilitaryBaseWarOperationDialog(Action: Cardinal);
begin
  BusinessQuoteSmallAmount := RoundAndTruncateToTens(Galaxy.ComputeScaledSmallMoney(owner_human));
  StationServiceQuoteCost := RoundAndTruncateToHundreds(Galaxy.ComputeScaledHugeMoney(owner_human));
  StationServiceQuoteCost := RoundAndTruncateToHundreds(StationServiceQuoteCost * RemapClamped(Galaxy.CurrentTurn - GetPlayer.StationServiceLastUseTurns[project_liberation_operation], 0, StationServiceRepeatPeriods[project_liberation_operation], 7.7, 1));
  DialogText := LocalizedColorText('FormRuins.WB.WarOperation.WB');
  ReplaceTextToken(DialogText, '<DecMoney>', IntToStr(BusinessQuoteSmallAmount), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
  ClearChoices;
  if GetPlayer.Money >= StationServiceQuoteCost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.WB.WarOperation.PlayerOk'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, AcceptMilitaryBaseWarOperation)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.WB.WarOperation.PlayerOk'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.WarOperation.PlayerNo'), 0, DeclineMilitaryBaseWarOperation);
end;
{ @end $56D664 }

{ @routine $56DA68 TfRuinsTalk_AcceptMilitaryBaseWarOperation }
procedure TfRuinsTalk.AcceptMilitaryBaseWarOperation(Action: Cardinal);
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
    GetPlayer.StationServiceLastUseTurns[project_liberation_operation] := Galaxy.CurrentTurn;
    GetPlayer.ChangePlanetRelations(nil, relation_change_add, 25, [owner_maloc]);
    GetPlayer.ChangePlanetRelations(nil, relation_change_add, 15, [owner_human, owner_feyan, owner_gaal]);
    GetPlayer.ChangePlanetRelations(nil, relation_change_add, 5, [owner_peleng]);
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
    ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<StarNormal>', FromStar.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<StarEnemy>', ToStar.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<SectorNormal>', FromStar.Constellation.GetName, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<SectorEnemy>', ToStar.Constellation.GetName, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(Group.Route[2].WaitUntilTurn), TextHighlightColorTag);
  end
  else
  begin
    GetPlayer.SetMoney(GetPlayer.Money - BusinessQuoteSmallAmount);
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.WB.WarOperation.WBAfterOkBad');
    ReplaceTextToken(DialogText, '<DecMoney>', IntToStr(BusinessQuoteSmallAmount), TextHighlightColorTag);
  end;
  M_Main(True);
end;
{ @end $56DA68 }

{ @routine $56DFF0 TfRuinsTalk_DeclineMilitaryBaseWarOperation }
procedure TfRuinsTalk.DeclineMilitaryBaseWarOperation(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.WB.WarOperation.WBAfterNo');
  M_Main(True);
end;
{ @end $56DFF0 }

{ @routine $56E098 TfRuinsTalk_ShowMilitaryBaseTravelDialog }
procedure TfRuinsTalk.ShowMilitaryBaseTravelDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBToChamber');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerToChamber'), 0, ConfirmMilitaryBaseTravel);
end;
{ @end $56E098 }

{ @routine $56E1D8 TfRuinsTalk_ConfirmMilitaryBaseTravel }
procedure TfRuinsTalk.ConfirmMilitaryBaseTravel(Action: Cardinal);
begin
  if LargePortraitLayout and PortraitTableVisible and (StationTransientControl.FindByNameRecursive('Table2') <> nil) then
  begin
    StationTransientControl.FindByNameRecursive('Table2').SetActive(True);
    StationTransientControl.FindByNameRecursive('Table').SetActive(False);
  end;
  (GetByName('ImageBG') as TImageGI).ImageSourcePath := 'GI,Bm.FormRuins.' + GiResourceSuffix + 'WBbg2';
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBInChamber');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerFly'), 0, DepartWithStation);
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerNotFly'), 0, DeclineMilitaryBaseTravel);
end;
{ @end $56E1D8 }

{ @routine $56E494 TfRuinsTalk_DepartWithStation }
procedure TfRuinsTalk.DepartWithStation(Action: Cardinal);
begin
  if Action = 1 then Galaxy.CheckIntegrityChecksum(200);
  RequestedScreenId := screen_jump;
  ClearChoices;
  RestoreTemporaryShopStock;
  if SkipVideo then
  begin
    ActiveLoadPanel.SelectBackgroundStyle(2);
    ActiveLoadPanel.RefreshBackgroundImages;
    ActiveLoadPanel.StartClosingShutters;
  end
  else (TObject(RegisteredScreens[CurrentScreenId]) as TMessageLoopGI).RequestClose(1);
  if Action = 0 then BreakUiMessage;
end;
{ @end $56E494 }

{ @routine $56E52C TfRuinsTalk_ShowMilitaryBaseArrivalDialog }
procedure TfRuinsTalk.ShowMilitaryBaseArrivalDialog(Action: Integer);
begin
  if LargePortraitLayout and PortraitTableVisible and (StationTransientControl.FindByNameRecursive('Table2') <> nil) then
  begin
    StationTransientControl.FindByNameRecursive('Table2').SetActive(True);
    StationTransientControl.FindByNameRecursive('Table').SetActive(False);
  end;
  (GetByName('ImageBG') as TImageGI).ImageSourcePath := 'GI,Bm.FormRuins.' + GiResourceSuffix + 'WBbg2';
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBInStarEnemy');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerUp'), 0, ShowMilitaryBaseArrivalInfo);
end;
{ @end $56E52C }

{ @routine $56E76C TfRuinsTalk_DeclineMilitaryBaseTravel }
procedure TfRuinsTalk.DeclineMilitaryBaseTravel(Action: Cardinal);
begin
  if LargePortraitLayout and PortraitTableVisible and (StationTransientControl.FindByNameRecursive('Table2') <> nil) then
  begin
    StationTransientControl.FindByNameRecursive('Table').SetActive(True);
    StationTransientControl.FindByNameRecursive('Table2').SetActive(False);
  end;
  (GetByName('ImageBG') as TImageGI).ImageSourcePath := 'GI,' + GetStationBackgroundPath;
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBAfterNotFly');
  M_Main(True);
end;
{ @end $56E76C }

{ @routine $56E8F4 TfRuinsTalk_ShowMilitaryBaseArrivalInfo }
procedure TfRuinsTalk.ShowMilitaryBaseArrivalInfo(Action: Cardinal);
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
  (GetByName('ImageBG') as TImageGI).ImageSourcePath := 'GI,' + GetStationBackgroundPath;
  Names := '';
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if not ((Ship.TypeId = ship_dominator) and not Ship.InHyperspace) then Continue;
    if Names = '' then Names := Ship.GetName
    else Names := Names + ', ' + Ship.GetName;
  end;
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBStarEnemyInfo');
  ReplaceTextToken(DialogText, '<N>', IntToStr(MilitaryTravelDistance), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Star>', GetPlayer.CurrentStar.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Ships>', Names, TextHighlightColorTag);
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerHangar'), 0, OpenHangar);
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerQuestions'), 0, ShowMilitaryBaseArrivalQuestions);
end;
{ @end $56E8F4 }

{ @routine $56ED0C TfRuinsTalk_ShowMilitaryBaseArrivalQuestions }
procedure TfRuinsTalk.ShowMilitaryBaseArrivalQuestions(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBAfterQuestions');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerHangar'), 0, OpenHangar);
end;
{ @end $56ED0C }

{ @routine $56EE54 TfRuinsTalk_ShowScienceBaseImprovementDialog }
procedure TfRuinsTalk.ShowScienceBaseImprovementDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAnswer');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerAsk'), 0, ShowScienceBaseImprovementItems);
end;
{ @end $56EE54 }

{ @routine $56EF88 TfRuinsTalk_ShowScienceBaseImprovementItems }
procedure TfRuinsTalk.ShowScienceBaseImprovementItems(Action: Cardinal);
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
    if Item.ItemType in [item_hull..item_custom_weapon] then
    begin
      if Item.CanImprove and GetPlayer.CanUseEquipmentTech(Item) and GetPlayer.CanRepairEquipmentTech(Item) then
      begin
        Inc(Count);
        Text := Text + #13#10 + IntToStr(Count) + ') ' + LocalizedColorText('FormRuins.SB.Improvement.ItemReadyForImprovement');
        AddChoice('- ' + NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), Integer(Item), ShowScienceBaseImprovementQuote);
      end;
      ReplaceTextToken(Text, '<ItemName>', NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), '');
      ReplaceTextToken(Text, '<Money>', IntToStr(Item.Cost), TextHighlightColorTag);
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
      ReplaceTextToken(Text, '<Money>', IntToStr(Item.Cost), TextHighlightColorTag);
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
{ @end $56EF88 }

{ @routine $56F648 TfRuinsTalk_DeclineScienceBaseImprovement }
procedure TfRuinsTalk.DeclineScienceBaseImprovement(Action: Cardinal);
begin
  ResetStationImprovement;
  DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAnswerNothing');
  M_Main(True);
end;
{ @end $56F648 }

{ @routine $56F700 TfRuinsTalk_ShowScienceBaseImprovementQuote }
procedure TfRuinsTalk.ShowScienceBaseImprovementQuote(Action: Cardinal);
var
  Item: TEquipment;
  Nodes: Integer;
begin
  Item := TEquipment(Action);
  StationImprovementItem := Item;
  if Item.OwnerId = owner_dominator then
  begin
    DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBNeedCostImprovementNodes');
    ReplaceTextToken(DialogText, '<MinNode>', IntToStr(Round(Item.CalculateImprovementCost(upgrade_minor) * 0.01)), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<AverageNode>', IntToStr(Round(Item.CalculateImprovementCost(upgrade_medium) * 0.01)), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MaxNode>', IntToStr(Round(Item.CalculateImprovementCost(upgrade_major) * 0.01)), TextHighlightColorTag);
  end
  else DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBNeedCostImprovement');
  ReplaceTextToken(DialogText, '<FullName>', NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Item.Cost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Min>', IntToStr(Item.CalculateImprovementCost(upgrade_minor)), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Average>', IntToStr(Item.CalculateImprovementCost(upgrade_medium)), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Max>', IntToStr(Item.CalculateImprovementCost(upgrade_major)), TextHighlightColorTag);
  ClearChoices;
  if Item.OwnerId = owner_dominator then
  begin
    Nodes := GetPlayer.GetAvailableNodeCount(nil);
    if (Nodes >= Round(Item.CalculateImprovementCost(upgrade_major) * 0.01)) and (Item.CalculateImprovementCost(upgrade_major) <= GetPlayer.Money) then
      AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkMax'), 2, SelectScienceBaseImprovementKind);
    if (Nodes >= Round(Item.CalculateImprovementCost(upgrade_medium) * 0.01)) and (Item.CalculateImprovementCost(upgrade_medium) <= GetPlayer.Money) then
      AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkAverage'), 1, SelectScienceBaseImprovementKind);
    if (Nodes >= Round(Item.CalculateImprovementCost(upgrade_minor) * 0.01)) and (Item.CalculateImprovementCost(upgrade_minor) <= GetPlayer.Money) then
      AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkMin'), 0, SelectScienceBaseImprovementKind);
  end
  else
  begin
    if Item.CalculateImprovementCost(upgrade_major) <= GetPlayer.Money then
      AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkMax'), 2, SelectScienceBaseImprovementKind);
    if Item.CalculateImprovementCost(upgrade_medium) <= GetPlayer.Money then
      AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkAverage'), 1, SelectScienceBaseImprovementKind);
    if Item.CalculateImprovementCost(upgrade_minor) <= GetPlayer.Money then
      AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkMin'), 0, SelectScienceBaseImprovementKind);
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerNo'), 0, DeclineScienceBaseImprovement);
end;
{ @end $56F700 }

{ @routine $56FFBC TfRuinsTalk_SelectScienceBaseImprovementKind }
procedure TfRuinsTalk.SelectScienceBaseImprovementKind(Action: Cardinal);
var
  Item: TEquipment;
  Text: WideString;
  Detail, Count: Integer;
begin
  StationImprovementKind := TUpgradeKind(Action);
  Item := StationImprovementItem;
  Detail := 1;
  Count := 0;
  repeat
    if not (Item is TEngine) and not (Item is TWeapon) and not (Item is TCargoHook) then Break;
    repeat
      if Detail = 2 then
        if Item is TWeapon then
          if TWeapon(Item).GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then Break;
      Text := LocalizedColorText('Items.' + Item.GetCategoryConfigName + '.Detail.' + IntToStr(Detail));
      if Length(Text) <> 0 then
      begin
        if Detail = 1 then
        begin
          DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBDetailImprovement');
          ClearChoices;
        end;
        AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.SB.Improvement.PlayerDetailOk'), TextHighlightColorTag, '<Attr>', Text), Detail, AcceptScienceBaseImprovement);
        Inc(Count);
      end;
    until True;
    Inc(Detail);
  until Detail > 100;
  if Count > 1 then
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerDetailNo'), 0, DeclineScienceBaseImprovement)
  else AcceptScienceBaseImprovement(0);
end;
{ @end $56FFBC }

{ @routine $570334 TfRuinsTalk_AcceptScienceBaseImprovement }
procedure TfRuinsTalk.AcceptScienceBaseImprovement(Action: Cardinal);
var
  Item: TEquipment;
  Kind: TUpgradeKind;
  Cost, Nodes: Integer;
begin
  StationImprovementDetail := Action;
  Item := StationImprovementItem;
  Kind := StationImprovementKind;
  Cost := Item.CalculateImprovementCost(Kind);
  if Item.OwnerId = owner_dominator then Nodes := Round(Cost * 0.01) else Nodes := 0;
  if (GetPlayer.Money >= Cost) and (GetPlayer.GetAvailableNodeCount(nil) >= Nodes) then
  begin
    GetPlayer.SetMoney(GetPlayer.Money - Cost);
    if Item.OwnerId = owner_dominator then GetPlayer.ConsumeAvailableNodes(Nodes, nil);
    Item.DetailImprovement := StationImprovementDetail;
    Item.Improve(Kind);
    GetPlayer.RefreshDerivedStats(True);
    case Kind of
      upgrade_minor: DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAfterOkMin');
      upgrade_medium: DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAfterOkAverage');
      upgrade_major: DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAfterOkMax');
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
{ @end $570334 }

{ @routine $570774 TfRuinsTalk_DeclineScienceBaseRepeatImprovement }
procedure TfRuinsTalk.DeclineScienceBaseRepeatImprovement(Action: Cardinal);
begin
  ResetStationImprovement;
  DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAfterRepeatNo');
  M_Main(True);
end;
{ @end $570774 }

{ @routine $57082C TfRuinsTalk_ShowScienceBaseRepairDialog }
procedure TfRuinsTalk.ShowScienceBaseRepairDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Repair.SBAnswer');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Repair.PlayerCostAsk'), 0, ShowScienceBaseRepairQuote);
end;
{ @end $57082C }

{ @routine $5709B0 TfRuinsTalk_ShowScienceBaseRepairQuote }
procedure TfRuinsTalk.ShowScienceBaseRepairQuote(Action: Cardinal);
var
  Cost, EquipmentCost, I, NodeCost: Integer;
  Item: TEquipment;
begin
  NodeCost := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.EquippedFlag = 0 then Continue;
    if not (Item is TWeapon) then Continue;
    if TWeapon(Item).GetWeaponInfo.Availability <> availability_not_sold_node_repair then Continue;
    if not Item.NeedsRepair then Continue;
    if not (GetPlayer.DockedTo as TRuins).CanRepairEquipmentTech(Item) then Continue;
    Inc(NodeCost, Item.CalculateRepairCost);
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
    Exit;
  end;
  if Cost < GetPlayer.Wealth div 10 then DialogText := LocalizedColorText('FormRuins.SB.Repair.SBCostAnswerYouHaveGoodEquipments')
  else DialogText := LocalizedColorText('FormRuins.SB.Repair.SBCostAnswerYouHaveBadEquipments');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<EqMoney>', IntToStr(EquipmentCost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<ArtMoney>', IntToStr(Cost - EquipmentCost), TextHighlightColorTag);
  if NodeCost <> 0 then
  begin
    DialogText := DialogText + LocalizedColorText('FormRuins.SB.Repair.SBCostAnswerNeedNode');
    ReplaceTextToken(DialogText, '<NeedNode>', IntToStr(NodeCost), TextHighlightColorTag);
  end;
  ClearChoices;
  if (Cost > 0) and (GetPlayer.Money >= Cost) then
    if (NodeCost = 0) or ((NodeCost > 0) and (GetPlayer.GetAvailableNodeCount(nil) >= NodeCost)) then
      AddChoice('- ' + LocalizedColorText('FormRuins.SB.Repair.PlayerOk'), 0, AcceptScienceBaseRepair);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Repair.PlayerNo'), 0, DeclineScienceBaseRepair);
end;
{ @end $5709B0 }

{ @routine $571008 TfRuinsTalk_AcceptScienceBaseRepair }
procedure TfRuinsTalk.AcceptScienceBaseRepair(Action: Cardinal);
var
  I, NodeCost: Integer;
  Item: TEquipment;
begin
  NodeCost := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.EquippedFlag <> 0 then
      if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = availability_not_sold_node_repair) and Item.NeedsRepair then
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
{ @end $571008 }

{ @routine $5711F8 TfRuinsTalk_DeclineScienceBaseRepair }
procedure TfRuinsTalk.DeclineScienceBaseRepair(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Repair.SBAfterNo');
  M_Main(True);
end;
{ @end $5711F8 }

{ @routine $571294 TfRuinsTalk_ShowScienceBaseSatelliteOfferDialog }
procedure TfRuinsTalk.ShowScienceBaseSatelliteOfferDialog(Refresh: Cardinal);
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
    ReplaceTextToken(DialogText, '<SatName>', Satellite.GetDisplayName, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<SatText>', Satellite.GetInfoText('', nil), '');
    ReplaceTextToken(DialogText, '<SatSize>', IntToStr(Satellite.Weight), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<SatMoney>', IntToStr(Satellite.Cost), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<SatCurCount>', IntToStr(Galaxy.CountExistingSatellites), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<SatMayCount>', IntToStr(GetPlayer.GetSatelliteLimit), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  end;
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Satellite.PlayerInstruction'), 0, ShowSatelliteInstructions);
  Text := LocalizedColorText('FormRuins.SB.Satellite.PlayerOk');
  ReplaceTextToken(Text, '<SatName>', Satellite.GetDisplayName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<SatMoney>', IntToStr(Satellite.Cost), TextHighlightColorTag);
  if (Galaxy.CountExistingSatellites < GetPlayer.GetSatelliteLimit) and (GetPlayer.Money >= Satellite.Cost) then
    AddChoice('- ' + Text, 0, BuyScienceBaseSatellite)
  else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Satellite.PlayerNo'), 0, DeclineScienceBaseSatellite);
end;
{ @end $571294 }

{ @routine $571934 TfRuinsTalk_ShowSatelliteInstructions }
procedure TfRuinsTalk.ShowSatelliteInstructions(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Satellite.SBInstruction');
  ShowScienceBaseSatelliteOfferDialog(1);
end;
{ @end $571934 }

{ @routine $5719E4 TfRuinsTalk_BuyScienceBaseSatellite }
procedure TfRuinsTalk.BuyScienceBaseSatellite(Action: Cardinal);
var Satellite: TSatellite;
begin
  Satellite := (GetPlayer.DockedTo as TRuins).SatelliteOffer;
  DialogText := LocalizedColorText('FormRuins.SB.Satellite.SBAfterOk');
  ReplaceTextToken(DialogText, '<SatName>', Satellite.GetDisplayName, TextHighlightColorTag);
  GetPlayer.SetMoney(GetPlayer.Money - Satellite.Cost);
  GetPlayer.Inventory.Add(Satellite);
  (GetPlayer.DockedTo as TRuins).SatelliteOffer := nil;
  (GetPlayer.DockedTo as TRuins).RegenerateSatelliteOffer;
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $5719E4 }

{ @routine $571B9C TfRuinsTalk_DeclineScienceBaseSatellite }
procedure TfRuinsTalk.DeclineScienceBaseSatellite(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Satellite.SBAfterNo');
  M_Main(True);
end;
{ @end $571B9C }

{ @routine $571C40 TfRuinsTalk_ShowScienceBaseResearchDialog }
procedure TfRuinsTalk.ShowScienceBaseResearchDialog(Action: Cardinal);
var
  Text, Info: WideString;
  Series: TDominatorSeries;
begin
  Text := LocalizedColorText('FormRuins.SB.Scn.SBSectionInfo');
  ClearChoices;
  for Series := series_blazer to series_terron do
  begin
    if not Galaxy.IsDominatorResearchComplete([Series]) and Galaxy.IsDominatorSeriesUnresolved(Series) then
    begin
      Info := LocalizedColorText('FormRuins.SB.Scn.SBSectionInfoAdd');
      if GetPlayer.CountUnequippedDominatorEquipment > 0 then
        AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[Series]), Ord(Series) + 1, SelectScienceBaseResearchSection)
      else AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[Series]), 0, ScriptDialogBlockCallback);
      ReplaceTextToken(Info, '<Count>', IntToStr(Galaxy.DominatorResearch[Series].Material), TextHighlightColorTag);
      ReplaceTextToken(Info, '<Speed>', IntToStr(Galaxy.GetDominatorResearchEfficiency(Series)), TextHighlightColorTag);
      ReplaceTextToken(Info, '<Day>', IntToStr(Round(Max(1.0, (100 - Galaxy.DominatorResearch[Series].Progress) / Galaxy.GetDominatorResearchRate(Series)))), TextHighlightColorTag);
    end
    else Info := LocalizedColorText('FormRuins.SB.Scn.SBSectionInfoEnd');
    case Series of
      series_blazer: ReplaceTextToken(Text, '<SBAnswerInfoBlazer>', Info, '');
      series_keller: ReplaceTextToken(Text, '<SBAnswerInfoKeller>', Info, '');
      series_terron: ReplaceTextToken(Text, '<SBAnswerInfoTerron>', Info, '');
    end;
  end;
  if Action = 0 then DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAnswer')
  else DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAnswer2');
  ReplaceTextToken(DialogText, '<SBSectionInfo>', Text, '');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.SectionNone'), 0, SelectScienceBaseResearchSection);
end;
{ @end $571C40 }

{ @routine $5722CC TfRuinsTalk_SelectScienceBaseResearchSection }
procedure TfRuinsTalk.SelectScienceBaseResearchSection(Action: Cardinal);
var
  Text: WideString;
  Series: TDominatorSeries;
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
    Series := TDominatorSeries(Action - 1);
    SelectedResearchSeries := Series;
    BuildResearchItemChoices(Series, Text);
    DialogText := LocalizedColorText('FormRuins.SB.Scn.SBSection1');
    ReplaceTextToken(DialogText, '<SectionName>', LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[Series]), '');
    ReplaceTextToken(DialogText, '<Items>', Text, '');
    ReplaceTextToken(DialogText, '<ItemsCool>', LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), TextHighlightColorTag);
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSectionChoose'), 1, ShowScienceBaseResearchDialog);
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 1, DeclineScienceBaseResearch);
  end;
end;
{ @end $5722CC }

{ @routine $57266C TfRuinsTalk_SellResearchRemains }
procedure TfRuinsTalk.SellResearchRemains(Action: Cardinal);
var
  Text: WideString;
  Money, I: Integer;
  Item: TEquipment;
begin
  Money := 0;
  for I := GetPlayer.Inventory.Count - 1 downto 0 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.OwnerId = owner_dominator) and (Item.DominatorSeries = SelectedResearchSeries) and (Item.NoDropFlag = 0) and (Item is TUselessItem) then
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
  ReplaceTextToken(DialogText, '<Count>', IntToStr(Galaxy.DominatorResearch[SelectedResearchSeries].Material), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Money), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<ItemsCool>', LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), TextHighlightColorTag);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSectionChoose'), 1, ShowScienceBaseResearchDialog);
  if Text <> '' then
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 2, DeclineScienceBaseResearch)
  else
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 3, DeclineScienceBaseResearch);
end;
{ @end $57266C }

{ @routine $572C3C TfRuinsTalk_SellResearchEquipment }
procedure TfRuinsTalk.SellResearchEquipment(Action: Cardinal);
var
  Text: WideString;
  Money, I: Integer;
  Item: TEquipment;
begin
  Money := 0;
  for I := GetPlayer.Inventory.Count - 1 downto 0 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.OwnerId = owner_dominator) and not (Item is TUselessItem) and (Item.EquippedFlag = 0) and (Item.NoDropFlag = 0) and (Item.ItemType <> item_nodes) and (Item.ItemType <> item_micro_module) and (Item.CustomFaction = '') then
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
  ReplaceTextToken(DialogText, '<Count>', IntToStr(Galaxy.DominatorResearch[SelectedResearchSeries].Material), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Money), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<ItemsCool>', LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), TextHighlightColorTag);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSectionChoose'), 1, ShowScienceBaseResearchDialog);
  if Text <> '' then
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 2, DeclineScienceBaseResearch)
  else
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 3, DeclineScienceBaseResearch);
end;
{ @end $572C3C }

{ @routine $5731F0 TfRuinsTalk_SellResearchItem }
procedure TfRuinsTalk.SellResearchItem(Action: Cardinal);
var
  Text: WideString;
  Money: Integer;
  Item: TEquipment;
begin
  Item := GetPlayer.Inventory[Action];
  Inc(Galaxy.DominatorResearch[SelectedResearchSeries].Material, Item.Weight);
  if (Item.DominatorSeries = SelectedResearchSeries) and (Item is TUselessItem) then Money := Item.Cost * 2
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
  ReplaceTextToken(DialogText, '<Count>', IntToStr(Galaxy.DominatorResearch[SelectedResearchSeries].Material), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Money), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<ItemsCool>', LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), TextHighlightColorTag);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSectionChoose'), 1, ShowScienceBaseResearchDialog);
  if Text <> '' then
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 2, DeclineScienceBaseResearch)
  else
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 3, DeclineScienceBaseResearch);
end;
{ @end $5731F0 }

{ @routine $57376C TfRuinsTalk_DeclineScienceBaseResearch }
procedure TfRuinsTalk.DeclineScienceBaseResearch(Action: Cardinal);
begin
  ClearChoices;
  if Action = 1 then DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterPlayerSaleNo1')
  else if Action = 2 then DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterPlayerSaleNo2')
  else if Action = 3 then DialogText := LocalizedColorText('FormRuins.SB.Scn.SBSectionEnd');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $57376C }

{ @routine $573964 TfRuinsTalk_BuyScienceBaseResearchProgram }
procedure TfRuinsTalk.BuyScienceBaseResearchProgram(Action: Cardinal);
var
  Cost: Integer;
begin
  SelectedResearchSeries := TDominatorSeries(Action - 1);
  Cost := RoundAndTruncateToHundreds(Min(Galaxy.ComputeScaledHugeMoney(owner_human) * 2, GetPlayer.Wealth div 30) * ResearchProgramCostFactors[SelectedResearchSeries]);
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBBuyTech' + DominatorSeriesNames[SelectedResearchSeries]);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ClearChoices;
  if GetPlayer.Money >= Cost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechOk'), TextHighlightColorTag, '<Money>', IntToStr(Cost)), Cost, AcceptScienceBaseResearchProgram)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechOk'), TextHighlightColorTag, '<Money>', IntToStr(Cost)), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechNo'), 0, DeclineScienceBaseResearchProgram);
end;
{ @end $573964 }

{ @routine $573CF4 TfRuinsTalk_AcceptScienceBaseResearchProgram }
procedure TfRuinsTalk.AcceptScienceBaseResearchProgram(Action: Cardinal);
var
  Cost: Integer;
begin
  Cost := Action;
  GetPlayer.SetMoney(GetPlayer.Money - Cost);
  SoundManager.PlaySound('Sound.Sell');
  case SelectedResearchSeries of
    series_blazer: GetPlayer.ProgramCounts[program_logical_negation] := 1;
    series_keller: GetPlayer.ProgramCounts[program_dematerial] := 1;
    series_terron: GetPlayer.ProgramCounts[program_energotron] := 1;
  end;
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterPlayerBuyTech' + DominatorSeriesNames[SelectedResearchSeries]);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $573CF4 }

{ @routine $573EF8 TfRuinsTalk_DeclineScienceBaseResearchProgram }
procedure TfRuinsTalk.DeclineScienceBaseResearchProgram(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterPlayerBuyTechNo');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $573EF8 }

{ @routine $574004 TfRuinsTalk_ShowScienceBaseHistoryDialog }
procedure TfRuinsTalk.ShowScienceBaseHistoryDialog(Action: Cardinal);
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
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
end;
{ @end $574004 }

{ @routine $574394 TfRuinsTalk_ShowBusinessCenterDebtDialog }
procedure TfRuinsTalk.ShowBusinessCenterDebtDialog(Action: Cardinal);
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
      Event := Galaxy.GalaxyEvents[I];
      if Event.Turn + 1825 < Galaxy.CurrentTurn then Break;
      if ((Event.EventType = 'PlayerKillsShip') or (Event.EventType = 'PlayerCompanionKillsShip') or (Event.EventType = 'PlayerTranclucatorKillsShip')) and (Event.GetData(0) = 10) then
      begin
        DialogText := LocalizedColorText('FormRuins.BK.DebtNoPenalty');
        ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(Event.Turn + 1825), TextHighlightColorTag);
        M_Main(True);
        Exit;
      end;
    end;
    Factor := 1;
    for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
    begin
      Event := Galaxy.GalaxyEvents[I];
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
    ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MinMoney>', IntToStr(BusinessQuoteSmallAmount), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<AveMoney>', IntToStr(BusinessQuoteMediumAmount), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MaxMoney>', IntToStr(BusinessQuoteLargeAmount), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MinDay>', IntToStr(BusinessQuoteLargeDueTurn - Galaxy.CurrentTurn), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<AveDay>', IntToStr(BusinessQuoteMediumDueTurn - Galaxy.CurrentTurn), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MaxDay>', IntToStr(BusinessQuoteSmallDueTurn - Galaxy.CurrentTurn), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MinMoneyAdd>', IntToStr(Round(BusinessQuoteSmallAmount * 1.1) - BusinessQuoteSmallAmount), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<AveMoneyAdd>', IntToStr(Round(BusinessQuoteMediumAmount * 1.15) - BusinessQuoteMediumAmount), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MaxMoneyAdd>', IntToStr(Round(BusinessQuoteLargeAmount * 1.2) - BusinessQuoteLargeAmount), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MinMoneyReturn>', IntToStr(Round(BusinessQuoteSmallAmount * 1.1)), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<AveMoneyReturn>', IntToStr(Round(BusinessQuoteMediumAmount * 1.15)), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<MaxMoneyReturn>', IntToStr(Round(BusinessQuoteLargeAmount * 1.2)), TextHighlightColorTag);
    ClearChoices;
    AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerOkMaxMoney'), 1, AcceptBusinessCenterDebtQuote);
    AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerOkAveMoney'), 2, AcceptBusinessCenterDebtQuote);
    AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerOkMinMoney'), 3, AcceptBusinessCenterDebtQuote);
    AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerNo'), 0, DeclineBusinessCenterDebtDialog);
  end;
end;
{ @end $574394 }

{ @routine $5750B8 TfRuinsTalk_AcceptBusinessCenterDebtQuote }
procedure TfRuinsTalk.AcceptBusinessCenterDebtQuote(Quote: Cardinal);
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
  ReplaceTextToken(DialogText, '<SendMoney>', IntToStr(Amount), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<DebtMoney>', IntToStr(GetPlayer.DebtAmount), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(GetPlayer.DebtDueTurn), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $5750B8 }

{ @routine $575464 TfRuinsTalk_DeclineBusinessCenterDebtDialog }
procedure TfRuinsTalk.DeclineBusinessCenterDebtDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.BK.TakeDebt.BKAfterNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $575464 }

{ @routine $575560 TfRuinsTalk_RepayBusinessCenterDebt }
procedure TfRuinsTalk.RepayBusinessCenterDebt(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.BK.RetDebt.BK');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  GetPlayer.DebtDefaultCount := 0;
  GetPlayer.SetMoney(GetPlayer.Money - GetPlayer.DebtAmount);
  GetPlayer.DebtAmount := 0;
  GetPlayer.DebtDueTurn := 0;
  M_Main(True);
end;
{ @end $575560 }

{ @routine $575698 TfRuinsTalk_ShowBusinessCenterDepositDialog }
procedure TfRuinsTalk.ShowBusinessCenterDepositDialog(Action: Cardinal);
var
  Text: WideString;
begin
  BusinessQuoteLargeAmount := Min(10000000, Max(1000, GetPlayer.Money));
  BusinessQuoteMediumAmount := Min(10000000, Max(1000, GetPlayer.Money div 2));
  BusinessQuoteSmallAmount := Min(10000000, Max(1000, GetPlayer.Money div 4));
  BusinessDepositQuoteInterestRate := RoundTo(RemapClamped(Galaxy.GetFactionControlPercent(faction_dominators), 5, 95, 7, 1), -1);
  DialogText := LocalizedColorText('FormRuins.BK.Deposit.BK');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Percent>', FloatToStrF(BusinessDepositQuoteInterestRate, ffFixed, 1, 1), TextHighlightColorTag);
  ClearChoices;
  Text := FormatText1(LocalizedColorText('FormRuins.BK.Deposit.PlayerOkMaxMoney'), TextHighlightColorTag, '<MaxMoney>', IntToStr(BusinessQuoteLargeAmount));
  if GetPlayer.Money >= BusinessQuoteLargeAmount then AddChoice('- ' + Text, 1, AcceptBusinessCenterDepositQuote)
  else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  if BusinessQuoteMediumAmount <> BusinessQuoteLargeAmount then
  begin
    Text := FormatText1(LocalizedColorText('FormRuins.BK.Deposit.PlayerOkAveMoney'), TextHighlightColorTag, '<AveMoney>', IntToStr(BusinessQuoteMediumAmount));
    if GetPlayer.Money >= BusinessQuoteMediumAmount then AddChoice('- ' + Text, 2, AcceptBusinessCenterDepositQuote)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  end;
  if (BusinessQuoteSmallAmount <> BusinessQuoteLargeAmount) and (BusinessQuoteSmallAmount <> BusinessQuoteMediumAmount) then
  begin
    Text := FormatText1(LocalizedColorText('FormRuins.BK.Deposit.PlayerOkMinMoney'), TextHighlightColorTag, '<MinMoney>', IntToStr(BusinessQuoteSmallAmount));
    if GetPlayer.Money >= BusinessQuoteSmallAmount then AddChoice('- ' + Text, 3, AcceptBusinessCenterDepositQuote)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Deposit.PlayerNo'), 0, DeclineBusinessCenterDepositDialog);
end;
{ @end $575698 }

{ @routine $575CF4 TfRuinsTalk_AcceptBusinessCenterDepositQuote }
procedure TfRuinsTalk.AcceptBusinessCenterDepositQuote(Quote: Cardinal);
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
  ReplaceTextToken(DialogText, '<SendMoney>', IntToStr(GetPlayer.DepositAmount), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Percent>', FloatToStrF(BusinessDepositQuoteInterestRate, ffFixed, 1, 1), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $575CF4 }

{ @routine $575FAC TfRuinsTalk_DeclineBusinessCenterDepositDialog }
procedure TfRuinsTalk.DeclineBusinessCenterDepositDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Deposit.BKAfterNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $575FAC }

{ @routine $5760A8 TfRuinsTalk_WithdrawBusinessCenterDeposit }
procedure TfRuinsTalk.WithdrawBusinessCenterDeposit(Action: Cardinal);
var Profit: Integer;
begin
  if GetPlayer.CurrentStar.Battle <> 0 then
    DialogText := LocalizedColorText('FormRuins.BK.RetDeposit.War')
  else
  begin
    DialogText := LocalizedColorText('FormRuins.BK.RetDeposit.BK');
    ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
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
{ @end $5760A8 }

{ @routine $5762C0 TfRuinsTalk_ShowBusinessCenterMedicalPolicyDialog }
procedure TfRuinsTalk.ShowBusinessCenterMedicalPolicyDialog(Refresh: Cardinal);
begin
  if Refresh = 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.BK.Policy.BK');
    ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Money>', IntToStr(Galaxy.ComputeScaledAverageMoney(owner_human)), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Year>', IntToStr(5), TextHighlightColorTag);
  end;
  ClearChoices;
  if Galaxy.ComputeScaledAverageMoney(owner_human) <= GetPlayer.Money then
    AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerOk'), 0, BuyBusinessCenterMedicalPolicy)
  else
    AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerOk'), 0, ScriptDialogBlockCallback);
  if Refresh = 0 then
    AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerAsk'), 0, ShowBusinessCenterPolicyDetails);
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerNo'), 0, DeclineBusinessCenterPolicy);
end;
{ @end $5762C0 }

{ @routine $576630 TfRuinsTalk_BuyBusinessCenterMedicalPolicy }
procedure TfRuinsTalk.BuyBusinessCenterMedicalPolicy(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Policy.BKAfterOk');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Galaxy.ComputeScaledAverageMoney(owner_human)), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Year>', IntToStr(5), TextHighlightColorTag);
  GetPlayer.SetMoney(GetPlayer.Money - Galaxy.ComputeScaledAverageMoney(owner_human));
  GetPlayer.MedicalPolicyTicks := 1825;
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $576630 }

{ @routine $576840 TfRuinsTalk_ShowBusinessCenterPolicyDetails }
procedure TfRuinsTalk.ShowBusinessCenterPolicyDetails(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Policy.BKAfterAsk');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ClearChoices;
  ShowBusinessCenterMedicalPolicyDialog(1);
end;
{ @end $576840 }

{ @routine $576948 TfRuinsTalk_DeclineBusinessCenterPolicy }
procedure TfRuinsTalk.DeclineBusinessCenterPolicy(Action: Cardinal);
var
  Date: TDateTime;
  YearText: AnsiString;
begin
  DialogText := LocalizedColorText('FormRuins.BK.Policy.BKAfterNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  Date := Galaxy.TurnToDateTime(-1);
  DateTimeToString(YearText, 'yyyy', Date);
  ReplaceTextToken(DialogText, '<CurYear>', YearText, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $576948 }

{ @routine $576ACC TfRuinsTalk_ShowBusinessCenterInvestmentDialog }
procedure TfRuinsTalk.ShowBusinessCenterInvestmentDialog(Action: Cardinal);
const
  StationTypes = [station_ranger_center..station_dominion];
var
  I, Index, BoundA, BoundB, BestScore, Score: Integer;
  Kind: TCoalitionProject;
  Choice: Byte;
  Offers, Text, Name: WideString;
  Star, BestStar: TStar;
  Planet, BestPlanet: TPlanet;
begin
  Offers := '';
  ClearChoices;
  for Kind := Low(CoalitionProjectNames) to High(CoalitionProjectNames) do
  begin
    Choice := Integer(Kind);
    Text := '';
    BoundA := 1;
    BoundB := Galaxy.Stars.Count - 1;
    Index := SeededRandomIntRange(BoundA, BoundB, GetPlayer.DockedTo.Seed + Galaxy.GenerationSeed + Galaxy.CurrentTurn div 60 + 1743 + 731 * Integer(Kind));
    if GetPlayer.StationServiceLastUseTurns[Kind] > Galaxy.CurrentTurn - StationServiceRepeatPeriods[Kind] then Continue;
    case Kind of
      project_build_ranger_center:
        begin
          if Galaxy.ShipTypeCounts[station_ranger_center] > Galaxy.CountFactionStars(faction_coalition) * 0.33 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := GetPlayer.CurrentStar.StarDistances[Index].Star as TStar;
            if not (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 7281) >= 0.6) then Continue;
            if Star.Constellation.Id = 20 then Continue;
            if Star.Constellation.ShipTypeCounts[station_ranger_center] > 0 then Continue;
            if Star.Constellation.CountShipsByTypeMask(StationTypes) >= Star.Constellation.Stars.Count then Continue;
            if Star.ShipTypeCounts[station_ranger_center] > 0 then Continue;
            if Star.CountShipsByTypeMask(StationTypes) > 2 then Continue;
            if Star.ShipTypeCounts[ship_dominator] > 0 then Continue;
            if Star.ControlFaction <> faction_coalition then Continue;
            if not ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) then Continue;
            if Star.Status.CustomFaction <> '' then Continue;
            if GetPlayer.CurrentStar = Star then Continue;
            if Star.DaysSincePlayerVisit < 30 then Continue;
            if not Star.IsConstellationVisible then Continue;
            Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
              10 * Star.Constellation.ShipTypeCounts[station_ranger_center] - Star.CountShipsByTypeMask(StationTypes) -
              Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
            if BestScore <= Score then
            begin
              BestScore := Score;
              BestStar := Star;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentRangerCenterStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1171 * (Integer(Kind) + 13) + InvestmentRangerCenterStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, TextHighlightColorTag);
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_build_pirate_base:
        begin
          if Galaxy.ShipTypeCounts[station_pirate_base] > Galaxy.CountFactionStars(faction_coalition) * 0.22 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := GetPlayer.CurrentStar.StarDistances[Index].Star as TStar;
            if not (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 113223) >= 0.6) then Continue;
            if Star.Constellation.Id = 20 then Continue;
            if Star.Constellation.ShipTypeCounts[station_pirate_base] > 0 then Continue;
            if Star.Constellation.CountShipsByTypeMask(StationTypes) >= Star.Constellation.Stars.Count then Continue;
            if Star.ShipTypeCounts[station_pirate_base] > 0 then Continue;
            if Star.CountShipsByTypeMask(StationTypes) > 1 then Continue;
            if Star.ShipTypeCounts[ship_dominator] > 0 then Continue;
            if not (Star.ControlFaction in [faction_coalition, faction_pirates]) then Continue;
            if Star.Status.CustomFaction <> '' then Continue;
            if GetPlayer.CurrentStar = Star then Continue;
            if Star.DaysSincePlayerVisit < 30 then Continue;
            if not Star.IsConstellationVisible then Continue;
            Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
              10 * Star.Constellation.ShipTypeCounts[station_pirate_base] - Star.CountShipsByTypeMask(StationTypes) -
              Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
            if BestScore <= Score then
            begin
              BestScore := Score;
              BestStar := Star;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentPirateBaseStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1171 * (Integer(Kind) + 13) + InvestmentPirateBaseStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, TextHighlightColorTag);
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_build_military_base:
        begin
          if Galaxy.ShipTypeCounts[station_military_base] > Galaxy.CountFactionStars(faction_coalition) * 0.22 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := GetPlayer.CurrentStar.StarDistances[Index].Star as TStar;
            if not (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 17823) >= 0.6) then Continue;
            if Star.Constellation.Id = 20 then Continue;
            if Star.Constellation.ShipTypeCounts[station_military_base] > 0 then Continue;
            if Star.Constellation.CountShipsByTypeMask(StationTypes) >= Star.Constellation.Stars.Count then Continue;
            if Star.ShipTypeCounts[station_military_base] > 0 then Continue;
            if Star.CountShipsByTypeMask(StationTypes) > 1 then Continue;
            if Star.ShipTypeCounts[ship_dominator] > 0 then Continue;
            if Star.ControlFaction <> faction_coalition then Continue;
            if not ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) then Continue;
            if Star.Status.CustomFaction <> '' then Continue;
            if GetPlayer.CurrentStar = Star then Continue;
            if Star.DaysSincePlayerVisit < 30 then Continue;
            if not Star.IsConstellationVisible then Continue;
            Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
              10 * Star.Constellation.ShipTypeCounts[station_military_base] - Star.CountShipsByTypeMask(StationTypes) -
              Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
            if BestScore <= Score then
            begin
              BestScore := Score;
              BestStar := Star;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentMilitaryBaseStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            3 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1171 * (Integer(Kind) + 13) + InvestmentMilitaryBaseStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, TextHighlightColorTag);
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_build_science_base:
        begin
          if Galaxy.ShipTypeCounts[station_science_base] > Galaxy.CountFactionStars(faction_coalition) * 0.15 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := GetPlayer.CurrentStar.StarDistances[Index].Star as TStar;
            if not (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 11123) >= 0.6) then Continue;
            if Star.Constellation.Id = 20 then Continue;
            if Star.Constellation.ShipTypeCounts[station_science_base] > 0 then Continue;
            if Star.Constellation.CountShipsByTypeMask(StationTypes) >= Star.Constellation.Stars.Count then Continue;
            if Star.ShipTypeCounts[station_science_base] > 0 then Continue;
            if Star.CountShipsByTypeMask(StationTypes) > 1 then Continue;
            if Star.ShipTypeCounts[ship_dominator] > 0 then Continue;
            if Star.ControlFaction <> faction_coalition then Continue;
            if not ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) then Continue;
            if Star.Status.CustomFaction <> '' then Continue;
            if GetPlayer.CurrentStar = Star then Continue;
            if Star.DaysSincePlayerVisit < 30 then Continue;
            if not Star.IsConstellationVisible then Continue;
            Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
              10 * Star.Constellation.ShipTypeCounts[station_science_base] - Star.CountShipsByTypeMask(StationTypes) -
              Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
            if BestScore <= Score then
            begin
              BestScore := Score;
              BestStar := Star;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentScienceBaseStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)),
            4 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1172 * (Integer(Kind) + 13) + InvestmentScienceBaseStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, TextHighlightColorTag);
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_build_business_center:
        begin
          if Galaxy.ShipTypeCounts[station_business_center] > Galaxy.CountFactionStars(faction_coalition) * 0.1 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := GetPlayer.CurrentStar.StarDistances[Index].Star as TStar;
            if not (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 9112323) >= 0.6) then Continue;
            if Star.Constellation.Id = 20 then Continue;
            if Star.Constellation.ShipTypeCounts[station_business_center] > 0 then Continue;
            if Star.Constellation.CountShipsByTypeMask(StationTypes) >= Star.Constellation.Stars.Count then Continue;
            if Star.ShipTypeCounts[station_business_center] > 0 then Continue;
            if Star.CountShipsByTypeMask(StationTypes) > 1 then Continue;
            if Star.ShipTypeCounts[ship_dominator] > 0 then Continue;
            if Star.ControlFaction <> faction_coalition then Continue;
            if not ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) then Continue;
            if Star.Status.CustomFaction <> '' then Continue;
            if GetPlayer.CurrentStar = Star then Continue;
            if Star.DaysSincePlayerVisit < 30 then Continue;
            if not Star.IsConstellationVisible then Continue;
            Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
              10 * Star.Constellation.ShipTypeCounts[station_business_center] - Star.CountShipsByTypeMask(StationTypes) -
              Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
            if BestScore <= Score then
            begin
              BestScore := Score;
              BestStar := Star;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentBusinessCenterStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1173 * (Integer(Kind) + 13) + InvestmentBusinessCenterStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, TextHighlightColorTag);
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_build_medical_base:
        begin
          if Galaxy.ShipTypeCounts[station_medical_base] > Galaxy.CountFactionStars(faction_coalition) * 0.15 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := GetPlayer.CurrentStar.StarDistances[Index].Star as TStar;
            if not (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 1123087) >= 0.6) then Continue;
            if Star.Constellation.Id = 20 then Continue;
            if Star.Constellation.ShipTypeCounts[station_medical_base] > 0 then Continue;
            if Star.Constellation.CountShipsByTypeMask(StationTypes) >= Star.Constellation.Stars.Count then Continue;
            if Star.ShipTypeCounts[station_medical_base] > 0 then Continue;
            if Star.CountShipsByTypeMask(StationTypes) > 1 then Continue;
            if Star.ShipTypeCounts[ship_dominator] > 0 then Continue;
            if Star.ControlFaction <> faction_coalition then Continue;
            if not ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) then Continue;
            if Star.Status.CustomFaction <> '' then Continue;
            if GetPlayer.CurrentStar = Star then Continue;
            if Star.DaysSincePlayerVisit < 30 then Continue;
            if not Star.IsConstellationVisible then Continue;
            Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
              10 * Star.Constellation.ShipTypeCounts[station_medical_base] - Star.CountShipsByTypeMask(StationTypes) -
              Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
            if BestScore <= Score then
            begin
              BestScore := Score;
              BestStar := Star;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentMedicalBaseStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1174 * (Integer(Kind) + 13) + InvestmentMedicalBaseStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, TextHighlightColorTag);
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_fund_rangers:
        begin
          if Galaxy.CountEligibleRangers < 20 then Continue;
          if SeededRandomUnitFloat(Galaxy.CurrentTurn div 71 + GetPlayer.DockedTo.Seed + 16689) < 0.5 then Continue;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 4,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1123475 * (Integer(Kind) + 13));
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_fund_pirates:
        begin
          if SeededRandomUnitFloat(Galaxy.CurrentTurn div 71 + GetPlayer.DockedTo.Seed + 5789) < 0.7 then Continue;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1175234 * (Integer(Kind) + 13));
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_fund_transports:
        begin
          if SeededRandomUnitFloat(Galaxy.CurrentTurn div 71 + GetPlayer.DockedTo.Seed + 23739) < 0.5 then Continue;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 4,
            Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 117627 * (Integer(Kind) + 13));
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_lost_subsidy:
        begin
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)),
            4 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1177961 * (Integer(Kind) + 13));
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
      project_fund_planet_defense:
        begin
          BestPlanet := nil;
          BestScore := 0;
          BoundA := 0;
          BoundB := Galaxy.Planets.Count - 1;
          Index := SeededRandomIntRange(BoundA, BoundB, GetPlayer.DockedTo.Seed + Galaxy.GenerationSeed + Galaxy.CurrentTurn div 60 + 174313 + 73163 * Integer(Kind));
          for I := 0 to Galaxy.Planets.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Planet := Galaxy.Planets[Index];
            if not Planet.IsCoalitionOwned then Continue;
            if Planet.IsMainPiratePlanet then Continue;
            if not (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Planet.GenerationSeed + Galaxy.CurrentTurn div 60 + 5889) >= 0.9) then Continue;
            if Planet.CurrentStar.ShipTypeCounts[ship_dominator] > 0 then Continue;
            if Planet.OwnerId = owner_pirate then Continue;
            if not ((Planet.CurrentStar.Battle = 0) or (Planet.CurrentStar.CountPirateShips(False) <= 0)) then Continue;
            if Planet.CurrentStar.DaysSincePlayerVisit < 30 then Continue;
            if not Planet.CurrentStar.IsConstellationVisible then Continue;
            Score := Min(40, Planet.CurrentStar.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Planet.GenerationSeed) -
              10 * Planet.Warriors.Count - Round(PointDistance(GetPlayer.CurrentStar.Position, Planet.CurrentStar.Position));
            if BestScore <= Score then
            begin
              BestScore := Score;
              BestPlanet := Planet;
            end;
          end;
          if BestPlanet = nil then Continue;
          InvestmentDefensePlanet := BestPlanet;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)),
            5 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1178 * (Integer(Kind) + 13) + InvestmentDefensePlanet.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Planet>', BestPlanet.Name, TextHighlightColorTag);
          ReplaceTextToken(Name, '<Star>', BestPlanet.CurrentStar.Name, TextHighlightColorTag);
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Planet>', InvestmentDefensePlanet.Name), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), TextHighlightColorTag, '<Planet>', InvestmentDefensePlanet.Name), 0, ScriptDialogBlockCallback);
        end;
    end;
    InvestmentQuoteCosts[Kind] := StationServiceQuoteCost;
  end;
  DialogText := LocalizedColorText('FormRuins.BK.Investment.BK');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<BKInvestment>', Offers, '');
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Investment.PlayerNo'), 0, DeclineBusinessCenterInvestment);
end;
{ @end $576ACC }

{ @routine $579DC4 TfRuinsTalk_AcceptBusinessCenterInvestment }
procedure TfRuinsTalk.AcceptBusinessCenterInvestment(Action: Cardinal);
const
  RangerTypes = [hull_ranger];
  FriendlyTypes = [hull_ranger, hull_transport..hull_diplomat];
  PirateTypes = [hull_pirate];
  TransportTypes = [hull_ranger..hull_flagship] - [hull_ranger..hull_pirate, hull_diplomat..hull_flagship];
var
  Kind: TCoalitionProject;
  RangerCenter, PirateBase, MilitaryBase, ScienceBase, BusinessCenter, MedicalBase: TRuins;
  I, J, Experience, RankPoints, Count: Integer;
  Star: TStar;
  Ship: TShip;
  Ranger: TRanger;
  Warrior: TWarrior;
  Text, ShipNames: WideString;
begin
  Kind := TCoalitionProject(Action);
  StationServiceQuoteCost := InvestmentQuoteCosts[Kind];
  GetPlayer.StationServiceLastUseTurns[Kind] := Galaxy.CurrentTurn;
  case Kind of
    project_build_ranger_center:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        RangerCenter := TRuins.Create;
        RangerCenter.Init(station_ranger_center, InvestmentRangerCenterStar, '');
        Galaxy.AddPlanetNewsWithPlayerBubble(news_station_created, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.RC', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Name>', RangerCenter.GetName, '<Star>', RangerCenter.CurrentStar.Name, '<Sector>', RangerCenter.CurrentStar.Constellation.GetName));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Name>', RangerCenter.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Star>', RangerCenter.CurrentStar.Name, TextHighlightColorTag);
        Experience := SeededRandomIntRange(1000, 1500, RangerCenter.Seed);
        GetPlayer.GainExperience(Experience, experience_unscaled);
        ReplaceTextToken(DialogText, '<Point>', IntToStr(Experience), TextHighlightColorTag);
        Galaxy.UpdateConstellationMilitaryStats;
        GetPlayer.ChangePlanetRelations(nil, relation_change_add, 10, PlanetOwnerMasks.Coalition);
        GetPlayer.ChangeShipRelations(nil, relation_change_add, 40, RangerTypes, PlanetOwnerMasks.Coalition);
        TryAddAchievementProgress('RUINS', 1);
      end;
    project_build_pirate_base:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        PirateBase := TRuins.Create;
        PirateBase.Init(station_pirate_base, InvestmentPirateBaseStar, '');
        Galaxy.AddPlanetNewsWithPlayerBubble(news_station_created, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.PB', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Name>', PirateBase.GetName, '<Star>', PirateBase.CurrentStar.Name, '<Sector>', PirateBase.CurrentStar.Constellation.GetName));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Name>', PirateBase.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Star>', PirateBase.CurrentStar.Name, TextHighlightColorTag);
        Galaxy.UpdateConstellationMilitaryStats;
        GetPlayer.ChangePlanetRelations(nil, relation_change_subtract_floor_20, 30, [owner_feyan, owner_gaal]);
        GetPlayer.ChangePlanetRelations(nil, relation_change_subtract_floor_20, 10, [owner_maloc, owner_human]);
        GetPlayer.ChangePlanetRelations(nil, relation_change_add, 20, [owner_peleng]);
      end;
    project_build_military_base:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        MilitaryBase := TRuins.Create;
        MilitaryBase.Init(station_military_base, InvestmentMilitaryBaseStar, '');
        Galaxy.AddPlanetNewsWithPlayerBubble(news_station_created, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.WB', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Name>', MilitaryBase.GetName, '<Star>', MilitaryBase.CurrentStar.Name, '<Sector>', MilitaryBase.CurrentStar.Constellation.GetName));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        if GetPlayer.OwnerId <> owner_pirate then
          ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '')
        else ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.TextAlt'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Name>', MilitaryBase.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Star>', MilitaryBase.CurrentStar.Name, TextHighlightColorTag);
        if GetPlayer.OwnerId <> owner_pirate then
        begin
          RankPoints := SeededRandomIntRange(50, 200, MilitaryBase.Seed);
          GetPlayer.AddRankPoints(RankPoints);
          ReplaceTextToken(DialogText, '<Point>', IntToStr(RankPoints), TextHighlightColorTag);
        end;
        Galaxy.UpdateConstellationMilitaryStats;
        GetPlayer.ChangePlanetRelations(nil, relation_change_add, 30, PlanetOwnerMasks.Coalition);
        GetPlayer.ChangeShipRelations(nil, relation_change_add, 10, FriendlyTypes, PlanetOwnerMasks.Coalition);
        GetPlayer.ChangeShipRelations(nil, relation_change_subtract_floor_20, 30, PirateTypes, PlanetOwnerMasks.Coalition);
        TryAddAchievementProgress('RUINS', 1);
      end;
    project_build_science_base:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        ScienceBase := TRuins.Create;
        ScienceBase.Init(station_science_base, InvestmentScienceBaseStar, '');
        Galaxy.AddPlanetNewsWithPlayerBubble(news_station_created, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.SB', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Name>', ScienceBase.GetName, '<Star>', ScienceBase.CurrentStar.Name, '<Sector>', ScienceBase.CurrentStar.Constellation.GetName));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Name>', ScienceBase.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Star>', ScienceBase.CurrentStar.Name, TextHighlightColorTag);
        Galaxy.UpdateConstellationMilitaryStats;
        GetPlayer.ChangeShipRelations(nil, relation_change_add, 25, RangerTypes, PlanetOwnerMasks.Coalition);
        TryAddAchievementProgress('RUINS', 1);
      end;
    project_build_business_center:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        BusinessCenter := TRuins.Create;
        BusinessCenter.Init(station_business_center, InvestmentBusinessCenterStar, '');
        Galaxy.AddPlanetNewsWithPlayerBubble(news_station_created, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.BK', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Name>', BusinessCenter.GetName, '<Star>', BusinessCenter.CurrentStar.Name, '<Sector>', BusinessCenter.CurrentStar.Constellation.GetName));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Name>', BusinessCenter.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Star>', BusinessCenter.CurrentStar.Name, TextHighlightColorTag);
        Galaxy.UpdateConstellationMilitaryStats;
        GetPlayer.ChangeShipRelations(nil, relation_change_add, 30, TransportTypes, PlanetOwnerMasks.Coalition);
        TryAddAchievementProgress('RUINS', 1);
      end;
    project_build_medical_base:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        MedicalBase := TRuins.Create;
        MedicalBase.Init(station_medical_base, InvestmentMedicalBaseStar, '');
        Galaxy.AddPlanetNewsWithPlayerBubble(news_station_created, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.MC', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Name>', MedicalBase.GetName, '<Star>', MedicalBase.CurrentStar.Name, '<Sector>', MedicalBase.CurrentStar.Constellation.GetName));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Name>', MedicalBase.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Star>', MedicalBase.CurrentStar.Name, TextHighlightColorTag);
        Galaxy.UpdateConstellationMilitaryStats;
        GetPlayer.ChangeShipRelations(nil, relation_change_add, 30, FriendlyTypes, PlanetOwnerMasks.Coalition);
        TryAddAchievementProgress('RUINS', 1);
      end;
    project_fund_rangers:
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
        Galaxy.AddPlanetNewsWithPlayerBubble(news_coalition_investment, FormatText1(PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Integer(Kind) + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Money>', IntToStr(StationServiceQuoteCost)));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
      end;
    project_fund_pirates:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        Count := Max(1, Galaxy.ShipTypeCounts[ship_pirate]);
        for I := 0 to Galaxy.Stars.Count - 1 do
        begin
          Star := Galaxy.Stars[I];
          for J := 0 to Star.Ships.Count - 1 do
          begin
            Ship := Star.Ships[J];
            if Ship.TypeId = ship_pirate then Ship.SetMoney(Ship.Money + StationServiceQuoteCost div Count);
          end;
        end;
        Galaxy.AddPlanetNewsWithPlayerBubble(news_coalition_investment, FormatText2(PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Integer(Kind) + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Money>', IntToStr(StationServiceQuoteCost), '<BK>', GetPlayer.DockedTo.Name));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
      end;
    project_fund_transports:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        Count := Max(1, Galaxy.ShipTypeCounts[ship_transport]);
        for I := 0 to Galaxy.Stars.Count - 1 do
        begin
          Star := Galaxy.Stars[I];
          for J := 0 to Star.Ships.Count - 1 do
          begin
            Ship := Star.Ships[J];
            if Ship.TypeId = ship_transport then Ship.SetMoney(Ship.Money + StationServiceQuoteCost div Count);
          end;
        end;
        Galaxy.AddPlanetNewsWithPlayerBubble(news_coalition_investment, FormatText2(PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Integer(Kind) + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Money>', IntToStr(StationServiceQuoteCost), '<BK>', GetPlayer.DockedTo.Name));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
      end;
    project_lost_subsidy:
      begin
        GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
        Galaxy.AddPlanetNewsWithPlayerBubble(news_coalition_investment, FormatText2(PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Integer(Kind) + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), TextHighlightColorTag,
          '<Money>', IntToStr(StationServiceQuoteCost), '<BK>', GetPlayer.DockedTo.Name));
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
        GetPlayer.ChangePlanetRelations(nil, relation_change_add, 30, PlanetOwnerMasks.Coalition);
        GetPlayer.ChangeShipRelations(nil, relation_change_add, 20, FriendlyTypes, PlanetOwnerMasks.Coalition);
        GetPlayer.ChangeShipRelations(nil, relation_change_subtract_floor_20, 20, PirateTypes, PlanetOwnerMasks.Coalition);
      end;
    project_fund_planet_defense:
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
        Text := PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Integer(Kind) + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed);
        ReplaceTextToken(Text, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(Text, '<Count>', IntToStr(Count), TextHighlightColorTag);
        ReplaceTextToken(Text, '<Planet>', InvestmentDefensePlanet.Name, TextHighlightColorTag);
        ReplaceTextToken(Text, '<Star>', InvestmentDefensePlanet.CurrentStar.Name, TextHighlightColorTag);
        ReplaceTextToken(Text, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
        Galaxy.AddPlanetNewsWithPlayerBubble(news_coalition_investment, Text);
        DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
        ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<ShipsName>', ShipNames, '');
        ReplaceTextToken(DialogText, '<Count>', IntToStr(Count), TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Planet>', InvestmentDefensePlanet.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Star>', InvestmentDefensePlanet.CurrentStar.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
        InvestmentDefensePlanet.ChangeRelationToRanger(GetPlayer, 100);
        GetPlayer.ChangePlanetRelations(nil, relation_change_add, 20, PlanetOwnerMasks.Coalition);
        GetPlayer.ChangeShipRelations(nil, relation_change_subtract_floor_20, 30, PirateTypes, PlanetOwnerMasks.Coalition);
      end;
  end;
  M_Main(True);
end;
{ @end $579DC4 }

{ @routine $57BD54 TfRuinsTalk_DeclineBusinessCenterInvestment }
procedure TfRuinsTalk.DeclineBusinessCenterInvestment(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterPlayerNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $57BD54 }

{ @routine $57BE60 TfRuinsTalk_ShowBusinessCenterTradeDialog }
procedure TfRuinsTalk.ShowBusinessCenterTradeDialog(Action: Cardinal);
var
  Discount: Byte;
begin
  DialogText := LocalizedColorText('FormRuins.BK.Trade.BK');
  NearbyTradeAdviceCost := RoundAndTruncateToTens(Min(GetPlayer.Money div 100,
    SeededRandomIntRange(Galaxy.ComputeScaledMiniMoney(owner_human) div 2, 2 * Galaxy.ComputeScaledMiniMoney(owner_human), Galaxy.GenerationSeed + Galaxy.CurrentTurn div 10)) + 30);
  DistantTradeAdviceCost := RoundAndTruncateToTens(SeededRandomIntRange(NearbyTradeAdviceCost div 3, NearbyTradeAdviceCost div 2,
    Galaxy.GenerationSeed + Galaxy.CurrentTurn div 10 + 1231341) + 10);
  Discount := Round(GetPlayer.CareerStatus[career_trader] / 1.3) + 1;
  NearbyTradeAdviceCost := Max(Int64(10), NearbyTradeAdviceCost - Round(NearbyTradeAdviceCost / 100 * Discount));
  DistantTradeAdviceCost := Max(Int64(5), DistantTradeAdviceCost - Round(DistantTradeAdviceCost / 100 * Discount));
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<NeaMoney>', IntToStr(NearbyTradeAdviceCost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<FarMoney>', IntToStr(DistantTradeAdviceCost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(Discount), TextHighlightColorTag);
  ClearChoices;
  if GetPlayer.Money >= NearbyTradeAdviceCost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.BK.Trade.PlayerNea'), TextHighlightColorTag, '<NeaMoney>', IntToStr(NearbyTradeAdviceCost)), 1, BuyBusinessCenterTradeAdvice)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.BK.Trade.PlayerNea'), TextHighlightColorTag, '<NeaMoney>', IntToStr(NearbyTradeAdviceCost)), 0, ScriptDialogBlockCallback);
  if GetPlayer.Money >= DistantTradeAdviceCost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.BK.Trade.PlayerFar'), TextHighlightColorTag, '<FarMoney>', IntToStr(DistantTradeAdviceCost)), 2, BuyBusinessCenterTradeAdvice)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.BK.Trade.PlayerFar'), TextHighlightColorTag, '<FarMoney>', IntToStr(DistantTradeAdviceCost)), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Trade.PlayerNo'), 0, DeclineBusinessCenterTradeAdvice);
end;
{ @end $57BE60 }

{ @routine $57CA28 TfRuinsTalk_BuyBusinessCenterTradeAdvice }
procedure TfRuinsTalk.BuyBusinessCenterTradeAdvice(Action: Cardinal);
var
  Text: WideString;
  Count: Integer;
  Paths: WideString;
  Nearby, Found: Boolean;
  Dialog, Greeting, Panel: WideString;

  // @nested $57C568 FindBusinessCenterTradeRoutes
  procedure FindBusinessCenterTradeRoutes; // @addr $57C568 @calls "0x0057CAF8" @ida "void __cdecl $name(void *ParentFrame);"
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
    GoodsMask := [Ord(item_food)..Ord(item_narcotics)];
    for I := Low(Routes) to High(Routes) do
    begin
      Routes[I].FromPlanet := nil;
      Routes[I].ToPlanet := nil;
    end;
    for I := Low(Routes) to High(Routes) do
    begin
      Attempts := 0;
      while True do
      begin
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
        if Found then Break;
      end;
      Exclude(GoodsMask, Routes[I].GoodsIndex);
      Inc(Count);
      Text := LocalizedColorText('FormRuins.BK.Trade.BKFindTradePath');
      ReplaceTextToken(Text, '<Num>', IntToStr(I), '');
      ReplaceTextToken(Text, '<Goods>', GoodsMarket[Routes[I].GoodsIndex].DisplayName, TextHighlightColorTag);
      ReplaceTextToken(Text, '<FromPlanet>', Routes[I].FromPlanet.Name, TextHighlightColorTag);
      ReplaceTextToken(Text, '<FromStar>', Routes[I].FromPlanet.CurrentStar.Name, TextHighlightColorTag);
      ReplaceTextToken(Text, '<Buy>', IntToStr(GetPlayer.ShopGoodsPurchasePrice(Routes[I].GoodsIndex, Routes[I].FromPlanet)), TextHighlightColorTag);
      ReplaceTextToken(Text, '<Cnt>', IntToStr(Routes[I].FromPlanet.Goods[Routes[I].GoodsIndex].Count), TextHighlightColorTag);
      ReplaceTextToken(Text, '<ToPlanet>', Routes[I].ToPlanet.Name, TextHighlightColorTag);
      ReplaceTextToken(Text, '<ToStar>', Routes[I].ToPlanet.CurrentStar.Name, TextHighlightColorTag);
      ReplaceTextToken(Text, '<Sale>', IntToStr(GetPlayer.ShopGoodsSellPrice(Routes[I].GoodsIndex, Routes[I].ToPlanet)), TextHighlightColorTag);
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
  ReplaceTextToken(Panel, '<Date>', Galaxy.FormatTurnDate(Galaxy.CurrentTurn), GreenColorTag);
  ReplaceTextToken(Panel, '<BK>', GetPlayer.DockedTo.Name, GreenColorTag);
  FindBusinessCenterTradeRoutes;
  if Count = 0 then DialogText := Greeting + #13#10 + LocalizedColorText('FormRuins.BK.Trade.BKNotVariant')
  else
  begin
    Dialog := Greeting + #13#10 + LocalizedColorText('FormRuins.BK.Trade.BKAfterOk');
    ReplaceTextToken(Dialog, '<BKFindTradePath>', Paths, '');
    ReplaceTextToken(Dialog, '<Count>', IntToStr(Count), TextHighlightColorTag);
    DialogText := Dialog;
    if Action = 1 then GetPlayer.SetMoney(GetPlayer.Money - NearbyTradeAdviceCost)
    else GetPlayer.SetMoney(GetPlayer.Money - DistantTradeAdviceCost);
    SoundManager.PlaySound('Sound.Sell');
    AddOrUpdatePlayerBubble(message_user_note, Galaxy.CurrentTurn, Panel + #13#10 + Paths, '');
    MainPanel.RebuildMessageButtons(False);
  end;
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $57CA28 }

{ @routine $57CF24 TfRuinsTalk_DeclineBusinessCenterTradeAdvice }
procedure TfRuinsTalk.DeclineBusinessCenterTradeAdvice(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Trade.BKAfterNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $57CF24 }

{ @routine $57D01C TfRuinsTalk_ShowMedicalCenterIllnessTreatmentDialog }
procedure TfRuinsTalk.ShowMedicalCenterIllnessTreatmentDialog(Refresh: Cardinal);
var
  I: TCaptainHealthEffect;
  Cost, TotalCost, AllCost: Integer;
  Text, IllnessText, Key: WideString;
  HasDisease: Boolean;
begin
  if Refresh = 0 then
  begin
    if GetPlayer.OwnerId <> owner_pirate then DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSee')
    else DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeePirate');
  end;
  HasDisease := GetPlayer.HasPresentDisease;
  if HasDisease or GetPlayer.HasRadiationSickness then
  begin
    if Refresh = 0 then
    begin
      if HasDisease then
      begin
        if GetPlayer.DockedTo.CurrentStar.ControlFaction <> faction_pirates then
          DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Illnes.MCSeeIllness')
        else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Illnes.MCSeeIllnessPirate');
      end
      else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Illnes.MCSeeCureless');
    end;
    ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
    TotalCost := 0;
    IllnessText := '';
    if HasDisease then
      for I := Low(TCaptainDisease) to High(TCaptainDisease) do
      begin
        Text := '';
        if GetPlayer.CaptainHealth[I].Progress <> 0 then
        begin
          Text := LocalizedColorText('FormRuins.MC.Illnes.MCSeeIll');
          ReplaceTextToken(Text, '<IllName>', CaptainHealthDefinitions[I].Name, TextHighlightColorTag);
          if GetPlayer.CaptainHealth[I].Progress >= 100 then
            ReplaceTextToken(Text, '<MCSeeIllType>', LocalizedColorText('FormRuins.MC.Illnes.MCSeeIllType1'), '')
          else
          begin
            ReplaceTextToken(Text, '<MCSeeIllType>', LocalizedColorText('FormRuins.MC.Illnes.MCSeeIllType2'), '');
            Inc(GetPlayer.CaptainHealth[I].ApplicationCount);
            GetPlayer.AchievementStats.CheckAllDiseasesAchievement;
          end;
          ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(GetPlayer.CaptainHealth[I].AppliedTurn), TextHighlightColorTag);
          ReplaceTextToken(Text, '<InfectionObjectName>', GetPlayer.StatusEffectSourceNames[I], TextHighlightColorTag);
          Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledMiniMoney(GetPlayer.DockedTo.OwnerId), Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 10) * Galaxy.GenerationSeed * I);
          Inc(TotalCost, Cost);
          ReplaceTextToken(Text, '<Money>', IntToStr(Cost), TextHighlightColorTag);
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
      for I := Low(TCaptainDisease) to High(TCaptainDisease) do
      begin
        if GetPlayer.CaptainHealth[I].Progress = 0 then Continue;
        Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledMiniMoney(GetPlayer.DockedTo.OwnerId), Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 10) * Galaxy.GenerationSeed * I);
        if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> faction_pirates) then Cost := Cost div 2;
        if GetPlayer.Money >= Cost then
          AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.MC.Illnes.PlayerIll'), TextHighlightColorTag, '<IllName>', CaptainHealthDefinitions[I].Name, '<Money>', IntToStr(Cost)), I, TreatSelectedDiseaseAtMedicalCenter)
        else AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.MC.Illnes.PlayerIll'), TextHighlightColorTag, '<IllName>', CaptainHealthDefinitions[I].Name, '<Money>', IntToStr(Cost)), 0, ScriptDialogBlockCallback);
      end;
      AllCost := TotalCost div 3 + Galaxy.ComputeScaledSmallMoney(GetPlayer.DockedTo.OwnerId);
      if GetPlayer.Money >= AllCost then
        AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.MC.Illnes.PlayerIllAll'), TextHighlightColorTag, '<Money>', IntToStr(AllCost)), AllCost, TreatAllDiseasesAtMedicalCenter)
      else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.MC.Illnes.PlayerIllAll'), TextHighlightColorTag, '<Money>', IntToStr(AllCost)), 0, ScriptDialogBlockCallback);
      AddChoice('- ' + LocalizedColorText('FormRuins.MC.Illnes.PlayerNo'), 0, DeclineMedicalCenterTreatment);
    end
    else if GetPlayer.OwnerId <> owner_pirate then
      AddChoice('- ' + LocalizedColorText('FormRuins.MC.Illnes.PlayerExit'), 0, LeaveMedicalCenterTreatment)
    else AddChoice('- ' + LocalizedColorText('FormRuins.MC.Illnes.PlayerExitPirate'), 0, LeaveMedicalCenterTreatment);
  end
  else
  begin
    if Refresh = 0 then
    begin
      Key := 'FormRuins.MC.Illnes.MCSeeGood';
      if GetPlayer.DockedTo.CurrentStar.ControlFaction = faction_pirates then Key := Key + 'PirateTo'
      else Key := Key + 'NormalTo';
      if GetPlayer.OwnerId = owner_pirate then Key := Key + 'Pirate'
      else Key := Key + 'Normal';
      DialogText := DialogText + #13#10 + LocalizedColorText(Key);
    end;
    ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
    M_Main(True);
  end;
end;
{ @end $57D01C }

{ @routine $57DE70 TfRuinsTalk_TreatSelectedDiseaseAtMedicalCenter }
procedure TfRuinsTalk.TreatSelectedDiseaseAtMedicalCenter(DiseaseIndex: Cardinal);
var
  I, Cost: Integer;
  Name: WideString;
begin
  for I := 1 to 12 do
  begin
    if I <> Integer(DiseaseIndex) then Continue;
    if I = 3 then
    begin
      Galaxy.GraphDominatorSurfacesEnabled := True;
      Galaxy.DisableDominatorSurfaces;
    end;
    GetPlayer.CaptainHealth[I].Progress := 0;
    GetPlayer.StatusEffectSourceNames[I] := '';
    Name := CaptainHealthDefinitions[I].Name;
    Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledMiniMoney(GetPlayer.DockedTo.OwnerId), Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 10) * Galaxy.GenerationSeed * I);
    if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> faction_pirates) then Cost := Cost div 2;
    GetPlayer.SetMoney(GetPlayer.Money - Cost);
    GetPlayer.DiseaseImmunity := Min(100, GetPlayer.DiseaseImmunity + 40);
    SoundManager.PlaySound('Sound.Sell');
    Break;
  end;
  if GetPlayer.DockedTo.CurrentStar.ControlFaction <> faction_pirates then
    DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterIll')
  else DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterIllPirate');
  if GetPlayer.HasRadiationSickness and not GetPlayer.HasPresentDisease then
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterIllRadiation');
  ReplaceTextToken(DialogText, '<IllName>', Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ClearChoices;
  ShowMedicalCenterIllnessTreatmentDialog(1);
end;
{ @end $57DE70 }

{ @routine $57E264 TfRuinsTalk_TreatAllDiseasesAtMedicalCenter }
procedure TfRuinsTalk.TreatAllDiseasesAtMedicalCenter(QuotedCost: Cardinal);
var
  I: Integer;
  Date: TDateTime;
  YearText: AnsiString;
begin
  DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterIllAll');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  Date := Now;
  DateTimeToString(YearText, 'yyyy', Date);
  ReplaceTextToken(DialogText, '<CurrentYear>', YearText, TextHighlightColorTag);
  for I := 1 to 12 do
  begin
    if GetPlayer.CaptainHealth[I].Progress = 0 then Continue;
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
{ @end $57E264 }

{ @routine $57E4DC TfRuinsTalk_DeclineMedicalCenterTreatment }
procedure TfRuinsTalk.DeclineMedicalCenterTreatment(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterNo');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $57E4DC }

{ @routine $57E5DC TfRuinsTalk_LeaveMedicalCenterTreatment }
procedure TfRuinsTalk.LeaveMedicalCenterTreatment(Action: Cardinal);
begin
  if (GetPlayer.OwnerId = owner_pirate) and (GetPlayer.DockedTo.CurrentStar.ControlFaction = faction_pirates) then DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterExitPirate')
  else DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterExit');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $57E5DC }

{ @routine $57E778 TfRuinsTalk_ShowMedicalCenterStimulantDialog }
procedure TfRuinsTalk.ShowMedicalCenterStimulantDialog(Action: Cardinal);
var
  I, OfferCount, Cost, Duration, MaxStimulants, LawStimulants: Integer;
  Seed: Cardinal;
  Text, StimulantText, Key: WideString;
  Offers: set of 8..39;
  Rank: TShipRank;
  Bonus: Integer;
begin
  Offers := [];
  OfferCount := 0;
  Seed := Galaxy.GenerationSeed * (Galaxy.CurrentTurn div 13);
  if GetPlayer.DockedTo.CurrentStar.ControlFaction = faction_pirates then Rank := GetPlayer.PirateRank
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
  Bonus := GetPlayer.GetTotalStatBonus(bonus_stimulant_capacity) + GetPlayer.CountActiveArtefacts(artefact_health_protection);
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
  if GetPlayer.DockedTo.CurrentStar.ControlFaction = faction_pirates then
  begin
    Key := Key + 'Pirate';
    if not GetPlayer.PirateClanReal then Key := Key + 'NoRank';
  end;
  DialogText := DialogText + LocalizedColorText(Key);
  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Stimulants.MC4');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<MaxStim>', IntToStr(MaxStimulants), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<CurStim>', IntToStr(GetPlayer.CountActiveStimulants), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<AddStim>', IntToStr(MaxStimulants - GetPlayer.CountActiveStimulants), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<LawStim>', IntToStr(LawStimulants), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Rank>', GetPlayer.GetRankName, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<PirateRank>', GetPlayer.GetPirateRankName, TextHighlightColorTag);
  if GetPlayer.CountActiveStimulants < MaxStimulants then
  begin
    StimulantText := '';
    for I := 13 to 24 do
    begin
      if not (I in Offers) then Continue;
      Text := '';
      Text := LocalizedColorText('FormRuins.MC.Stimulants.MCStimInfo');
      ReplaceTextToken(Text, '<StimName>', CaptainHealthDefinitions[I].Name, TextHighlightColorTag);
      ReplaceTextToken(Text, '<StimText>', CaptainHealthDefinitions[I].Text, '');
      Duration := CaptainHealthDefinitions[I].Duration + SeededRandomIntRange(CaptainHealthDefinitions[I].Duration div 10,
        CaptainHealthDefinitions[I].Duration div 3, GetPlayer.DockedTo.Id + I + Galaxy.CurrentTurn div 13);
      Duration := Round(Duration / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor);
      ReplaceTextToken(Text, '<Month>', IntToStr(Duration div 30), TextHighlightColorTag);
      Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledSmallMoney(GetPlayer.DockedTo.OwnerId), 2 * Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 13) * Galaxy.GenerationSeed * I);
      if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> faction_pirates) then Cost := Cost div 2;
      ReplaceTextToken(Text, '<Money>', IntToStr(Cost), TextHighlightColorTag);
      if StimulantText = '' then StimulantText := StimulantText + Text
      else StimulantText := StimulantText + #13#10 + Text;
    end;
    if GetPlayer.DockedTo.CurrentStar.ControlFaction <> faction_pirates then
      DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Stimulants.MC5MedPolicy');
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Stimulants.MC5');
    ReplaceTextToken(DialogText, '<MCStimInfo>', StimulantText, '');
    ClearChoices;
    for I := 13 to 24 do
      if I in Offers then
      begin
        Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledSmallMoney(GetPlayer.DockedTo.OwnerId), 2 * Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 13) * Galaxy.GenerationSeed * I);
        if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> faction_pirates) then Cost := Cost div 2;
        if (GetPlayer.Money < Cost) or (GetPlayer.CaptainHealth[I].Progress = 100) then
          AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.MC.Stimulants.PlayerStim'), TextHighlightColorTag, '<StimName>', CaptainHealthDefinitions[I].Name, '<Money>', IntToStr(Cost)), 0, ScriptDialogBlockCallback)
        else AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.MC.Stimulants.PlayerStim'), TextHighlightColorTag, '<StimName>', CaptainHealthDefinitions[I].Name, '<Money>', IntToStr(Cost)), I, BuySelectedStimulantAtMedicalCenter);
      end;
    AddChoice('- ' + LocalizedColorText('FormRuins.MC.Stimulants.PlayerNo'), 0, DeclineMedicalCenterStimulants);
  end
  else
  begin
    ClearChoices;
    M_Main(True);
  end;
end;
{ @end $57E778 }

{ @routine $57F514 TfRuinsTalk_BuySelectedStimulantAtMedicalCenter }
procedure TfRuinsTalk.BuySelectedStimulantAtMedicalCenter(StimulantIndex: Cardinal);
var
  I, Cost, Duration: Integer;
  Name: WideString;
begin
  for I := 13 to 24 do
    if I = Integer(StimulantIndex) then
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
      if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> faction_pirates) then Cost := Cost div 2;
      GetPlayer.SetMoney(GetPlayer.Money - Cost);
      GetPlayer.DiseaseImmunity := Max(0, GetPlayer.DiseaseImmunity - 20);
      Inc(GetPlayer.StimulantPurchaseCount);
      SoundManager.PlaySound('Sound.Sell');
      DialogText := LocalizedColorText('FormRuins.MC.Stimulants.MCAfterPlayerStim');
      ReplaceTextToken(DialogText, '<StimName>', Name, TextHighlightColorTag);
      ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(GetPlayer.CaptainHealth[I].ExpireTurn), TextHighlightColorTag);
      ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
      Inc(GetPlayer.CaptainHealth[I].ApplicationCount);
      GetPlayer.AchievementStats.CheckAllDrugsAchievement;
      M_Main(True);
      Break;
    end;
end;
{ @end $57F514 }

{ @routine $57F8E8 TfRuinsTalk_DeclineMedicalCenterStimulants }
procedure TfRuinsTalk.DeclineMedicalCenterStimulants(Action: Cardinal);
begin
  if GetPlayer.DockedTo.CurrentStar.ControlFaction = faction_pirates then DialogText := LocalizedColorText('FormRuins.MC.Stimulants.MCAfterPlayerNoPirate')
  else DialogText := LocalizedColorText('FormRuins.MC.Stimulants.MCAfterPlayerNo');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $57F8E8 }

{ @routine $57FA8C TfRuinsTalk_ShowStationSpecialShipDialog }
procedure TfRuinsTalk.ShowStationSpecialShipDialog(Action: Cardinal);
var
  CanBuy: Boolean;
  Price: Integer;
  Hull: THull;
  I, CompletedQuests: Integer;
  Quest: PPlayerOldQuest;
begin
  CanBuy := True;
  Hull := THull.Create;
  if GetPlayer.DockedTo.TypeId = station_pirate_base then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, hull_special, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullPB'), Hull);
  end
  else if GetPlayer.DockedTo.TypeId = station_military_base then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, hull_special, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullWB'), Hull);
  end
  else if GetPlayer.DockedTo.TypeId = station_science_base then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, hull_special, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullSB'), Hull);
  end
  else RaiseWideMessage('Ask special ship');
  Price := Hull.GetConditionAdjustedCost;
  Hull.Free;
  DialogText := LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Info');
  if GetPlayer.DockedTo.TypeId = station_pirate_base then
  begin
    ReplaceTextToken(DialogText, '<KillCnt>', IntToStr(100), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Price>', IntToStr(Price), TextHighlightColorTag);
    if GetPlayer.CivilianKillCount < 100 then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<KillComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<KillComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
    if GetPlayer.GetDominantCareer <> career_pirate then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<PirateComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<PirateComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
    if GetPlayer.Rank < 5 then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<RankComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<RankComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
  end
  else if GetPlayer.DockedTo.TypeId = station_military_base then
  begin
    ReplaceTextToken(DialogText, '<KillCnt>', IntToStr(50), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Price>', IntToStr(Price), TextHighlightColorTag);
    if GetPlayer.PirateKillCount < 50 then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<KillComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<KillComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
    if GetPlayer.GetDominantCareer <> career_warrior then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<WarriorComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<WarriorComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
    if GetPlayer.Rank < 5 then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<RankComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<RankComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
  end
  else if GetPlayer.DockedTo.TypeId = station_science_base then
  begin
    ReplaceTextToken(DialogText, '<KillCnt>', IntToStr(500), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Price>', IntToStr(Price), TextHighlightColorTag);
    if GetPlayer.DominatorKillCount < 500 then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<KillComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<KillComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
    if GetPlayer.Rank < 5 then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<RankComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<RankComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
    CompletedQuests := 0;
    for I := 0 to PlayerOldQuests.Count - 1 do
    begin
      Quest := PlayerOldQuests[I];
      if Quest.Successful then Inc(CompletedQuests);
    end;
    ReplaceTextToken(DialogText, '<QuestCnt>', IntToStr(20), TextHighlightColorTag);
    if CompletedQuests < 20 then
    begin
      CanBuy := False;
      ReplaceTextToken(DialogText, '<QuestComplate>', '', '');
    end
    else ReplaceTextToken(DialogText, '<QuestComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), TextHighlightColorTag);
  end
  else RaiseWideMessage('Ask special ship 2');
  ClearChoices;
  if CanBuy and (GetPlayer.Money >= Price) then
    AddChoice('- ' + LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.PlayerBuy'), 0, BuyStationSpecialShip);
  AddChoice('- ' + LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.PlayerNo'), 0, DeclineStationSpecialShip);
end;
{ @end $57FA8C }

{ @routine $580698 TfRuinsTalk_DeclineStationSpecialShip }
procedure TfRuinsTalk.DeclineStationSpecialShip(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.AfterNo');
  M_Main(True);
end;
{ @end $580698 }

{ @routine $580774 TfRuinsTalk_BuyStationSpecialShip }
procedure TfRuinsTalk.BuyStationSpecialShip(Action: Cardinal);
const
  RelationShipTypes = [hull_ranger, hull_pirate..hull_diplomat];
  PirateOwners = [owner_peleng];
  CoalitionOwners = [owner_maloc, owner_human..owner_gaal];
var
  Price: Integer;
  Hull: THull;
begin
  (GetPlayer.DockedTo as TRuins).SpecialServiceActive := False;
  Hull := THull.Create;
  if GetPlayer.DockedTo.TypeId = station_pirate_base then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, hull_special, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullPB'), Hull);
  end
  else if GetPlayer.DockedTo.TypeId = station_military_base then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, hull_special, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullWB'), Hull);
  end
  else if GetPlayer.DockedTo.TypeId = station_science_base then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, hull_special, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullSB'), Hull);
  end
  else RaiseWideMessage('Buy special ship');
  Price := Hull.GetConditionAdjustedCost;
  if GetPlayer.Money >= Price then
  begin
    GetPlayer.SetMoney(GetPlayer.Money - Price);
    if GetPlayer.IsOnPlanet then GetPlayer.AddItemToPlayerStorage(Hull, GetPlayer.CurrentPlanet, -1)
    else GetPlayer.AddItemToPlayerStorage(Hull, GetPlayer.DockedTo, -1);
    if GetPlayer.DockedTo.TypeId = station_pirate_base then
    begin
      GetPlayer.ChangePlanetRelations(nil, relation_change_add, 30, [owner_peleng]);
      GetPlayer.ChangeShipRelations(nil, relation_change_add, 30, RelationShipTypes, PirateOwners);
      GetPlayer.ChangePlanetRelations(nil, relation_change_subtract_floor_20, 50, [owner_maloc, owner_human, owner_feyan, owner_gaal]);
      GetPlayer.ChangeShipRelations(nil, relation_change_subtract_floor_20, 50, RelationShipTypes, CoalitionOwners);
    end;
  end
  else Hull.Free;
  DialogText := LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.AfterBuy');
  M_Main(True);
end;
{ @end $580774 }

{ @routine $580AD0 TfRuinsTalk_RunInjectedDialog }
procedure TfRuinsTalk.RunInjectedDialog(Action: Cardinal);
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
{ @end $580AD0 }

{ @routine $580C6C TfRuinsTalk_RunInjectedDialogKeepingScroll }
procedure TfRuinsTalk.RunInjectedDialogKeepingScroll(Action: Cardinal);
begin
  RememberChoiceScroll;
  RunInjectedDialog(Action);
end;
{ @end $580C6C }

{ @routine $580C88 TfRuinsTalk_RunScriptRestart }
procedure TfRuinsTalk.RunScriptRestart(Answer: Cardinal);
begin
  DialogText := '';
  CurrentScript.ExecuteDialogAnswer(Answer);
  M_Main(False);
end;
{ @end $580C88 }

{ @routine $580CB4 TfRuinsTalk_AddScriptRestartChoice }
procedure TfRuinsTalk.AddScriptRestartChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptRestart);
end;
{ @end $580CB4 }

{ @routine $580D38 TfRuinsTalk_CloseRuinsMode }
procedure TfRuinsTalk.CloseRuinsMode(Sender: TObjectGI);
begin
  GetPlayer.CloseRuinsModeScreen;
end;
{ @end $580D38 }

{ @routine $580D44 GetConstructionShopCost }
function GetConstructionShopCost: Integer;
var
  J: Integer;
  Kind: TItemType;
begin
  Result := 0;
  for Kind := item_hull to item_defense_generator do
    if (ConstructionEquipment[Kind].Item <> nil) and (ConstructionEquipment[Kind].Source = 2) then
      Inc(Result, ConstructionEquipment[Kind].Item.Cost);
  for J := 1 to 5 do
    if (ConstructionWeapons[J].Item <> nil) and (ConstructionWeapons[J].Source = 2) then
      Inc(Result, ConstructionWeapons[J].Item.Cost);
end;
{ @end $580D44 }

{ @routine $580D88 GetConstructionFreeSpace }
function GetConstructionFreeSpace: Integer;
var
  J: Integer;
  Kind: TItemType;
begin
  Result := 0;
  for Kind := item_hull to item_defense_generator do
    if ConstructionEquipment[Kind].Item <> nil then
    begin
      if Kind = item_hull then Inc(Result, ConstructionEquipment[Kind].Item.Weight)
      else Dec(Result, ConstructionEquipment[Kind].Item.Weight);
    end;
  for J := 1 to 5 do
    if ConstructionWeapons[J].Item <> nil then Dec(Result, ConstructionWeapons[J].Item.Weight);
end;
{ @end $580D88 }

{ @routine $58135C TfRuinsTalk_BuildConstructionItemChoices }
function TfRuinsTalk.BuildConstructionItemChoices(Kind: TItemType): Integer;
var
  I, Count: Integer;
  Slot: TShopSlot;
  Item: TEquipment;
  Text: WideString;
  Entry: PStorageEntry;

  // @nested $580DCC IsConstructionItemEligible
  function IsConstructionItemEligible(Item: TEquipment): Boolean; // @addr $580DCC @calls "0x005813CD,0x005814AE,0x00581581"
  var
    I: Integer;
  begin
    Result := False;
    if (Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '') then Exit;
    if (Kind in WeaponItemTypes) and not (Item.ItemType in WeaponItemTypes) then Exit;
    if not (Kind in WeaponItemTypes) and (Kind <> Item.ItemType) then Exit;
    if Kind = item_hull then
    begin
      if not (THull(Item).HullType in [hull_pirate, hull_special]) or (THull(Item).GetSlotCount(slot_cargo_hook) < 1) or (THull(Item).CapitalShip <> 0) then Exit;
      if THull(Item).HullType = hull_special then
      begin
        if Item.SpecialModuleIndex = 0 then Exit;
        if not (GetPlayer.DockedTo.TypeId in MicroModuleTemplates[Item.SpecialModuleIndex - 1].OfferStationTypes) then Exit;
      end
      else if not (Item.OwnerId in PlanetOwnerMasks.Coalition) then Exit;
    end;
    if Kind in WeaponItemTypes then
      for I := 1 to 5 do
        if ConstructionWeapons[I].Item = Item then Exit;
    Result := True;
  end;
  // @nested $580ECC FormatConstructionItem
  procedure FormatConstructionItem(var Text: WideString; Item: TEquipment); // @addr $580ECC @calls "0x005813E9,0x005814CA,0x005815A1"
  var
    Stats: WideString;
  begin
    ReplaceTextToken(Text, '<ItemName>', RemoveTextTagsW(Item.GetDisplayName), TextHighlightColorTag);
    ReplaceTextToken(Text, '<Size>', IntToStr(Item.Weight), TextHighlightColorTag);
    ReplaceTextToken(Text, '<Cost>', IntToStr(Item.Cost), TextHighlightColorTag);
    if Item is TWeapon then Stats := LocalizedColorText('FormRuins.CB.ConstructPirate.StatsWeapon')
    else Stats := LocalizedColorText('FormRuins.CB.ConstructPirate.Stats' + ItemTypeNames[Item.ItemType]);
    Item.ReplaceInfoTokens(Stats, TextHighlightColorTag, nil);
    if (Item is THull) and (THull(Item).HullSeries <> -1) then
    begin
      Stats := Stats + ', ' + LocalizedColorText('FormRuins.CB.ConstructPirate.StatsSeries');
      ReplaceTextToken(Stats, '<SeriesName>', '"' + HullSeriesDefinitions[THull(Item).HullSeries].Name + '"', TextHighlightColorTag);
    end;
    if (Item is TWeapon) and (Item.SpecialModuleIndex > 0) then
    begin
      Stats := Stats + ', ' + LocalizedColorText('FormRuins.CB.ConstructPirate.StatsSeries');
      ReplaceTextToken(Stats, '<SeriesName>', Item.GetSpecialModuleName, TextHighlightColorTag);
    end;
    ReplaceTextToken(Text, '<Stats>', Stats, '');
    Text := ReplaceAllWideString(Text, TextHighlightColorTag, DialogHighlightColorTag);
    Text := ReplaceAllWideString(Text, GreenColorTag, DialogGreenColorTag);
  end;

begin
  Count := 0;
  if Kind <> item_hull then
    for I := 0 to GetPlayer.Inventory.Count - 1 do
    begin
      Item := GetPlayer.Inventory[I];
      if (Item.EquippedFlag = 0) and IsConstructionItemEligible(Item) then
      begin
        Text := LocalizedColorText('FormRuins.CB.ConstructPirate.InHold');
        FormatConstructionItem(Text, Item);
        if (Kind <> item_hull) and (GetConstructionFreeSpace - Item.Weight < 0) then
          AddChoice('- ' + Text, 0, ScriptDialogBlockCallback)
        else AddChoice('- ' + Text, Integer(Item), SelectConstructionHeldItem);
        Inc(Count);
      end;
    end;
  for I := 0 to GetPlayer.StorageEntries.Count - 1 do
  begin
    Entry := GetPlayer.StorageEntries[I];
    if GetPlayer.DockedTo <> Entry.LocationOwner then Continue;
    if Entry = nil then Continue;
    if Entry.Item = nil then Continue;
    Item := TEquipment(Entry.Item);
    if IsConstructionItemEligible(Item) then
    begin
      Text := LocalizedColorText('FormRuins.CB.ConstructPirate.InStorage');
      FormatConstructionItem(Text, Item);
      if (Kind <> item_hull) and (GetConstructionFreeSpace - Item.Weight < 0) then
        AddChoice('- ' + Text, 0, ScriptDialogBlockCallback)
      else AddChoice('- ' + Text, Integer(Item), SelectConstructionStoredItem);
      Inc(Count);
    end;
  end;
  if TemporaryShopSlots <> nil then
    for I := 0 to TemporaryShopSlots.Count - 1 do
    begin
      Slot := TemporaryShopSlots[I];
      if Slot = nil then Continue;
      Item := TEquipment(Slot.Item);
      if (Item <> nil) and IsConstructionItemEligible(Item) then
      begin
        Text := LocalizedColorText('FormRuins.CB.ConstructPirate.InShop');
        FormatConstructionItem(Text, Item);
        if Item.Cost + GetConstructionShopCost > GetPlayer.Money then
          AddChoice('- ' + Text, 0, ScriptDialogBlockCallback)
        else if (Kind <> item_hull) and (GetConstructionFreeSpace - Item.Weight < 0) then
          AddChoice('- ' + Text, 0, ScriptDialogBlockCallback)
        else AddChoice('- ' + Text, Integer(Item), SelectConstructionShopItem);
        Inc(Count);
      end;
    end;
  if not (Kind in [item_hull..item_engine, item_cargo_hook]) and ((Kind <> weapon_category) or (ConstructionWeapons[1].Item <> nil)) then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.skip'), 0, SkipConstructionItem);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.cancel'), 0, DeclineDominionShipConstruction);
  Result := Count;
end;
{ @end $58135C }

{ @routine $581898 TfRuinsTalk_ShowDominionShipConstructionDialog }
procedure TfRuinsTalk.ShowDominionShipConstructionDialog(Action: Cardinal);
var
  J: Integer;
  Kind: TItemType;
begin
  ClearChoices;
  for Kind := item_hull to item_defense_generator do ConstructionEquipment[Kind].Item := nil;
  for J := 1 to 5 do ConstructionWeapons[J].Item := nil;
  if GetPlayer.GetMaxDominionShips <= GetPlayer.PiratePartners.Count then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.WarningPirateCnt');
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.WarningConfirm'), 0, ConfirmDominionConstructionLimit);
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.cancel'), 0, DeclineDominionShipConstruction);
  end
  else
  begin
    BuildConstructionItemChoices(item_hull);
    DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.PickHull');
  end;
end;
{ @end $581898 }

{ @routine $581B2C TfRuinsTalk_ConfirmDominionConstructionLimit }
procedure TfRuinsTalk.ConfirmDominionConstructionLimit(Action: Cardinal);
begin
  ClearChoices;
  BuildConstructionItemChoices(item_hull);
  DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.PickHull');
end;
{ @end $581B2C }

{ @routine $581BE0 TfRuinsTalk_DeclineDominionShipConstruction }
procedure TfRuinsTalk.DeclineDominionShipConstruction(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.Cancelled');
  M_Main(True);
end;
{ @end $581BE0 }

{ @routine $581C90 SelectConstructionItem }
procedure SelectConstructionItem(Item: TEquipment; Source: Byte);
var
  I: Integer;
begin
  if Item.ItemType in [item_hull..item_defense_generator] then
  begin
    ConstructionEquipment[Item.ItemType].Item := Item;
    ConstructionEquipment[Item.ItemType].Source := Source;
  end
  else
  begin
    if not (Item is TWeapon) then Exit;
    I := 1;
    while (I <= 5) and (ConstructionWeapons[I].Item <> nil) do Inc(I);
    if I <= 5 then
    begin
      ConstructionWeapons[I].Item := Item;
      ConstructionWeapons[I].Source := Source;
    end;
  end;
end;
{ @end $581C90 }

{ @routine $581D00 TfRuinsTalk_SelectConstructionHeldItem }
procedure TfRuinsTalk.SelectConstructionHeldItem(Action: Cardinal);
begin
  SelectConstructionItem(TEquipment(Action), 0);
  ContinueDominionConstruction(RemoveTextTagsW(TEquipment(Action).GetDisplayName));
end;
{ @end $581D00 }

{ @routine $581D70 TfRuinsTalk_SelectConstructionStoredItem }
procedure TfRuinsTalk.SelectConstructionStoredItem(Action: Cardinal);
begin
  SelectConstructionItem(TEquipment(Action), 1);
  ContinueDominionConstruction(RemoveTextTagsW(TEquipment(Action).GetDisplayName));
end;
{ @end $581D70 }

{ @routine $581DE0 TfRuinsTalk_SelectConstructionShopItem }
procedure TfRuinsTalk.SelectConstructionShopItem(Action: Cardinal);
begin
  SelectConstructionItem(TEquipment(Action), 2);
  ContinueDominionConstruction(RemoveTextTagsW(TEquipment(Action).GetDisplayName));
end;
{ @end $581DE0 }

{ @routine $581E50 TfRuinsTalk_SkipConstructionItem }
procedure TfRuinsTalk.SkipConstructionItem(Action: Cardinal);
begin
  ContinueDominionConstruction('');
end;
{ @end $581E50 }

{ @routine $581E58 TfRuinsTalk_AppendConstructionItemList }
procedure TfRuinsTalk.AppendConstructionItemList;
var
  I: Integer;
  Kind: TItemType;
  Item: TEquipment;
  Text: WideString;
begin
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.ItemList');
  Text := '';
  for Kind := item_hull to item_defense_generator do
  begin
    Item := ConstructionEquipment[Kind].Item;
    if Item <> nil then
    begin
      Text := Text + Item.GetShortName + ' - ' + RemoveTextTagsW(Item.GetDisplayName) + #13#10;
      Continue;
    end;
    Text := Text + LocalizedText('Items.' + ItemTypeNames[Kind] + '.ShortName') + ' - ';
    if THull(ConstructionEquipment[item_hull].Item).GetSlotCount(ItemTypeToSlotKind(Kind)) > 0 then
      Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.NotInstalled') + #13#10
    else Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.NotAvailable') + #13#10;
  end;
  for I := 1 to 5 do
  begin
    Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.weaponN') + IntToStr(I) + ' - ';
    Item := ConstructionWeapons[I].Item;
    if Item <> nil then
    begin
      Text := Text + RemoveTextTagsW(Item.GetDisplayName) + #13#10;
      Continue;
    end;
    if THull(ConstructionEquipment[item_hull].Item).GetSlotCount(slot_weapon) >= I then
    begin
      Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.NotInstalled') + #13#10;
      Continue;
    end;
    Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.NotAvailable') + #13#10;
  end;
  ReplaceTextToken(DialogText, '<ItemList>', Text, '');
  ReplaceTextToken(DialogText, '<TotalCost>', IntToStr(GetConstructionShopCost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<FreeSpace>', IntToStr(GetConstructionFreeSpace), TextHighlightColorTag);
end;
{ @end $581E58 }

{ @routine $5823A4 TfRuinsTalk_ContinueDominionConstruction }
procedure TfRuinsTalk.ContinueDominionConstruction(PreviousItem: WideString);
var
  CanAdd: Boolean;
  Hull: THull;
begin
  if PreviousItem <> '' then DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.AddedEq')
  else DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.AddedNothing');
  ReplaceTextToken(DialogText, '<PrevItem>', PreviousItem, TextHighlightColorTag);
  AppendConstructionItemList;
  ClearChoices;
  if ConstructionEquipment[item_engine].Item = nil then
  begin
    BuildConstructionItemChoices(item_engine);
    DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickEngine');
  end
  else if ConstructionEquipment[item_fuel_tanks].Item = nil then
  begin
    BuildConstructionItemChoices(item_fuel_tanks);
    DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickFuelTanks');
  end
  else if ConstructionEquipment[item_cargo_hook].Item = nil then
  begin
    BuildConstructionItemChoices(item_cargo_hook);
    DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickCargoHook');
  end
  else if ConstructionWeapons[1].Item = nil then
  begin
    BuildConstructionItemChoices(weapon_category);
    DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickWeapon');
  end
  else
  begin
    CanAdd := False;
    Hull := THull(ConstructionEquipment[item_hull].Item);
    if ConstructionWeapons[Hull.GetSlotCount(slot_weapon)].Item = nil then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddWeapon'), 0, PickConstructionWeapon);
    end;
    if (Hull.GetSlotCount(slot_radar) > 0) and (ConstructionEquipment[item_radar].Item = nil) then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddRadar'), 0, PickConstructionRadar);
    end;
    if (Hull.GetSlotCount(slot_scanner) > 0) and (ConstructionEquipment[item_scanner].Item = nil) then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddScaner'), 0, PickConstructionScanner);
    end;
    if (Hull.GetSlotCount(slot_repair_robot) > 0) and (ConstructionEquipment[item_repair_robot].Item = nil) then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddRepairRobot'), 0, PickConstructionRepairRobot);
    end;
    if (Hull.GetSlotCount(slot_defense_generator) > 0) and (ConstructionEquipment[item_defense_generator].Item = nil) then
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
{ @end $5823A4 }

{ @routine $582D2C TfRuinsTalk_PickConstructionWeapon }
procedure TfRuinsTalk.PickConstructionWeapon(Action: Cardinal);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(weapon_category);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickWeapon');
end;
{ @end $582D2C }

{ @routine $582E18 TfRuinsTalk_PickConstructionRadar }
procedure TfRuinsTalk.PickConstructionRadar(Action: Cardinal);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(item_radar);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickRadar');
end;
{ @end $582E18 }

{ @routine $582F04 TfRuinsTalk_PickConstructionScanner }
procedure TfRuinsTalk.PickConstructionScanner(Action: Cardinal);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(item_scanner);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickScaner');
end;
{ @end $582F04 }

{ @routine $582FF0 TfRuinsTalk_PickConstructionRepairRobot }
procedure TfRuinsTalk.PickConstructionRepairRobot(Action: Cardinal);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(item_repair_robot);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickRepairRobot');
end;
{ @end $582FF0 }

{ @routine $5830E8 TfRuinsTalk_PickConstructionDefGenerator }
procedure TfRuinsTalk.PickConstructionDefGenerator(Action: Cardinal);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(item_defense_generator);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickDefGenerator');
end;
{ @end $5830E8 }

{ @routine $5832B8 TfRuinsTalk_CompleteDominionConstruction }
procedure TfRuinsTalk.CompleteDominionConstruction(Action: Cardinal);
var
  Ship: TPirate;
  Planet: TPlanet;
  TotalCost, Price: Integer;
  Kind: TItemType;
  J, Months: Integer;
  Item: TEquipment;
  // @nested $5831E0 RemoveConstructionStoredItem
  procedure RemoveConstructionStoredItem(Item: TEquipment); // @addr $5831E0 @calls "0x0058338D,0x00583409"
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

  // @nested $583254 RemoveConstructionShopItem
  procedure RemoveConstructionShopItem(Item: TEquipment); // @addr $583254 @calls "0x00583396,0x00583412"
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
  for Kind := item_hull to item_defense_generator do
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
  ReplaceTextToken(DialogText, '<FullName>', Ship.GetFullName(' '), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<CntMonth>', IntToStr(Months), TextHighlightColorTag);
  M_Main(True);
end;
{ @end $5832B8 }

{ @routine $583710 TfRuinsTalk_ShowDominionImprovementDialog }
procedure TfRuinsTalk.ShowDominionImprovementDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.Improvement.CBAnswer');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerAsk'), 0, ShowDominionImprovementItems);
end;
{ @end $583710 }

{ @routine $583844 TfRuinsTalk_ShowDominionImprovementItems }
procedure TfRuinsTalk.ShowDominionImprovementItems(Action: Cardinal);
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
    if Item.ItemType in [item_hull..item_custom_weapon] then
    begin
      if Item.CanImprove and GetPlayer.CanUseEquipmentTech(Item) and GetPlayer.CanRepairEquipmentTech(Item) then
      begin
        Inc(Count);
        Text := Text + #13#10 + IntToStr(Count) + ') ' + LocalizedColorText('FormRuins.CB.Improvement.ItemReadyForImprovement');
        AddChoice('- ' + NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), Integer(Item), ShowDominionImprovementQuote);
      end;
      ReplaceTextToken(Text, '<ItemName>', NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), '');
      ReplaceTextToken(Text, '<Money>', IntToStr(Item.Cost), TextHighlightColorTag);
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
      ReplaceTextToken(Text, '<Money>', IntToStr(Item.Cost), TextHighlightColorTag);
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
{ @end $583844 }

{ @routine $583F00 TfRuinsTalk_DeclineDominionImprovement }
procedure TfRuinsTalk.DeclineDominionImprovement(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.Improvement.CBAnswerNothing');
  ClearChoices;
  M_Main(True);
end;
{ @end $583F00 }

{ @routine $583FBC TfRuinsTalk_ShowDominionImprovementQuote }
procedure TfRuinsTalk.ShowDominionImprovementQuote(Action: Cardinal);
var
  Item: TEquipment;
  NodeCost, MoneyCost: Integer;
  Discount: Byte;
  Text: WideString;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  Item := TEquipment(Action);
  NodeCost := 0;
  if Item.OwnerId = owner_dominator then
  begin
    Text := LocalizedColorText('FormRuins.CB.Improvement.CBNeedCostImprovementNodes');
    ReplaceTextToken(Text, '<Nodes>', IntToStr(Round(Item.CalculateImprovementCost(upgrade_major) * 0.01 * 1.5)), TextHighlightColorTag);
    NodeCost := Round(Item.CalculateImprovementCost(upgrade_major) * 0.01 * 1.5 * (100 - Discount) / 100);
    ReplaceTextToken(Text, '<NodesDiscount>', IntToStr(NodeCost), TextHighlightColorTag);
  end
  else Text := LocalizedColorText('FormRuins.CB.Improvement.CBNeedCostImprovement');
  ReplaceTextToken(Text, '<Money>', IntToStr(Item.CalculateImprovementCost(upgrade_major)), TextHighlightColorTag);
  MoneyCost := Round(Item.CalculateImprovementCost(upgrade_major) * (100 - Discount) / 100);
  ReplaceTextToken(Text, '<MoneyDiscount>', IntToStr(MoneyCost), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Discount>', IntToStr(Discount), TextHighlightColorTag);
  ReplaceTextToken(Text, '<FullName>', NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), TextHighlightColorTag);
  DialogText := Text;
  ClearChoices;
  if (GetPlayer.GetAvailableNodeCount(nil) >= NodeCost) and (GetPlayer.Money >= MoneyCost) then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerOk'), Action, AcceptDominionImprovement)
  else AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerOk'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerNo'), 0, DeclineDominionImprovement);
end;
{ @end $583FBC }

{ @routine $584554 TfRuinsTalk_AcceptDominionImprovement }
procedure TfRuinsTalk.AcceptDominionImprovement(Action: Cardinal);
var
  Item: TEquipment;
  Cost, Nodes: Integer;
  Discount: Byte;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  Item := TEquipment(Action);
  Cost := Item.CalculateImprovementCost(upgrade_major);
  if Item.OwnerId = owner_dominator then Nodes := Round(Cost * 0.01 * 1.5 * (100 - Discount) / 100) else Nodes := 0;
  Cost := Round(Cost * (100 - Discount) / 100);
  if (GetPlayer.Money >= Cost) and (GetPlayer.GetAvailableNodeCount(nil) >= Nodes) then
  begin
    GetPlayer.SetMoney(GetPlayer.Money - Cost);
    if Item.OwnerId = owner_dominator then GetPlayer.ConsumeAvailableNodes(Nodes, nil);
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
{ @end $584554 }

{ @routine $584898 TfRuinsTalk_DeclineDominionRepeatImprovement }
procedure TfRuinsTalk.DeclineDominionRepeatImprovement(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.Improvement.CBAfterRepeatNo');
  ClearChoices;
  M_Main(True);
end;
{ @end $584898 }

{ @routine $584954 TfRuinsTalk_ShowDominionPirateLicenseDialog }
procedure TfRuinsTalk.ShowDominionPirateLicenseDialog(Action: Cardinal);
var
  Cost: Integer;
  Discount: Byte;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  if GetPlayer.PirateLicenseTicks = 0 then
    DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAnswer')
  else DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAnswerProlongate');
  Cost := RoundAndTruncateToTens(RemapClamped(GetPlayer.PirateLicenseTicks, 0, TurnsPerYear, Galaxy.ComputeScaledAverageMoney(owner_human), 0));
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Discount>', IntToStr(Discount), TextHighlightColorTag);
  Cost := Round(Cost * (100 - Discount) / 100);
  ReplaceTextToken(DialogText, '<DiscountMoney>', IntToStr(Cost), TextHighlightColorTag);
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
{ @end $584954 }

{ @routine $584E88 TfRuinsTalk_BuyDominionPirateLicense }
procedure TfRuinsTalk.BuyDominionPirateLicense(Action: Cardinal);
begin
  if GetPlayer.PirateLicenseTicks = 0 then
    DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAfterOk')
  else DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAfterOkProlongate');
  GetPlayer.SetMoney(GetPlayer.Money - Action);
  GetPlayer.PirateLicenseTicks := TurnsPerYear;
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $584E88 }

{ @routine $585024 TfRuinsTalk_DeclineDominionPirateLicense }
procedure TfRuinsTalk.DeclineDominionPirateLicense(Action: Cardinal);
begin
  if GetPlayer.PirateLicenseTicks = 0 then
    DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAfterNo')
  else DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAfterNoProlongate');
  ReplaceTextToken(DialogText, '<Days>', IntToStr(GetPlayer.PirateLicenseTicks), TextHighlightColorTag);
  M_Main(True);
end;
{ @end $585024 }

{ @routine $5851E8 TfRuinsTalk_CheckDominionServiceStanding }
function TfRuinsTalk.CheckDominionServiceStanding(RequiredRank: TShipRank; Prefix: WideString; CreditCost: Single): Boolean;
begin
  Result := False;
  if GetPlayer.PirateRank < RequiredRank then
  begin
    DialogText := Prefix + ' ' + LocalizedColorText('FormRuins.CB.GenericRefuseNeedRank');
    ReplaceTextToken(DialogText, '<PirateRank>', LocalizedText('RankPirate.' + PirateRankNames[RequiredRank] + '.Name'), TextHighlightColorTag);
    Exit;
  end;
  if (Galaxy.AverageRangerCapital * CreditCost / 600 > GetPlayer.PirateLicenseCash) and (GetPlayer.PirateRank < 7) then
  begin
    if GetPlayer.PirateLicenseTicks > 0 then
      DialogText := Prefix + ' ' + LocalizedColorText('FormRuins.CB.GenericRefuseNeedPoints')
    else DialogText := Prefix + ' ' + LocalizedColorText('FormRuins.CB.GenericRefuseNeedLicense');
    Exit;
  end;
  Result := True;
end;
{ @end $5851E8 }

{ @routine $5854DC TfRuinsTalk_SpendDominionServiceCredit }
procedure TfRuinsTalk.SpendDominionServiceCredit(CreditCost: Single);
begin
  GetPlayer.PirateLicenseCash := Max(0, Round((GetPlayer.PirateLicenseCash - Galaxy.AverageRangerCapital * CreditCost / 600) * 0.85));
end;
{ @end $5854DC }

{ @routine $585568 TfRuinsTalk_CheckDominionAvailable }
function TfRuinsTalk.CheckDominionAvailable: Boolean;
begin
  if (TRuins(GetPlayer.DockedTo).FlyToStar <> nil) or (GetPlayer.DockedTo.Order = order_teleport) or GetPlayer.DockedTo.HasScriptControl then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.GenericRefuseHaveOtherPlans');
    Result := False;
  end
  else Result := True;
end;
{ @end $585568 }

{ @routine $585708 TfRuinsTalk_ShowDominionTravelDialog }
procedure TfRuinsTalk.ShowDominionTravelDialog(Action: Cardinal);
var
  Text: WideString;
  Seed: Cardinal;
  Star: TStar;
  I, J, Count: Integer;
  Duplicate: Boolean;
  Discount: Byte;
  // @nested $585650 GetDominionTravelQuoteCost
  function GetDominionTravelQuoteCost(Index: Integer): Integer; // @addr $585650 @calls "0x005858FF,0x00585936"
  begin
    Result := Min(MaxMonetaryValue, Round(Galaxy.ComputeScaledHugeMoney(owner_human) / DominionTravelQuotes[Index].DrawCount * PointDistanceSquared(GetPlayer.CurrentStar.Position, DominionTravelQuotes[Index].Star.Position) / 1600 * (100 - Discount) / 100));
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
    if not ((GetPlayer.CurrentStar <> Star) and Star.IsConstellationVisible and ((Star.Constellation.Id <> 20) or (Galaxy.CoalitionDefeatedTurn <> 0))) then Continue;
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
    ReplaceTextToken(Text, '<ToStar>', DominionTravelQuotes[I].Star.Name, TextHighlightColorTag);
    ReplaceTextToken(Text, '<Cost>', IntToStr(DominionTravelQuotes[I].Cost), TextHighlightColorTag);
    if GetPlayer.Money >= DominionTravelQuotes[I].Cost then
      AddChoice('- ' + Text, I, ConfirmDominionTravel)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
    Text := LocalizedColorText('FormRuins.CB.ShuffleTeleport.ToList');
    ReplaceTextToken(Text, '<ToStar>', DominionTravelQuotes[I].Star.Name, TextHighlightColorTag);
    ReplaceTextToken(Text, '<Cost>', IntToStr(DominionTravelQuotes[I].Cost), TextHighlightColorTag);
    ReplaceTextToken(Text, '<Dist>', IntToStr(Round(PointDistance(GetPlayer.CurrentStar.Position, DominionTravelQuotes[I].Star.Position))), TextHighlightColorTag);
    DialogText := DialogText + #13#10 + IntToStr(I) + ') ' + Text;
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.Refuse'), 0, DeclineDominionTravel);
end;
{ @end $585708 }

{ @routine $585F70 TfRuinsTalk_ConfirmDominionTravel }
procedure TfRuinsTalk.ConfirmDominionTravel(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBConfirmation');
  ReplaceTextToken(DialogText, '<ToStar>', DominionTravelQuotes[Action].Star.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Cost>', IntToStr(DominionTravelQuotes[Action].Cost), TextHighlightColorTag);
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.Confirm'), Action, AcceptDominionTravel);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.NoConfirm'), 0, DeclineDominionTravelConfirmation);
end;
{ @end $585F70 }

{ @routine $586208 TfRuinsTalk_DeclineDominionTravel }
procedure TfRuinsTalk.DeclineDominionTravel(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterRefuse');
  M_Main(True);
end;
{ @end $586208 }

{ @routine $5862C0 TfRuinsTalk_AcceptDominionTravel }
procedure TfRuinsTalk.AcceptDominionTravel(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterConfirm');
  GetPlayer.QueuedTravelTarget := DominionTravelQuotes[Action].Star;
  GetPlayer.SetMoney(GetPlayer.Money - DominionTravelQuotes[Action].Cost);
  SpendDominionServiceCredit(0.5);
  TRuins(GetPlayer.DockedTo).RelocationAge := (TRuins(GetPlayer.DockedTo).RelocationAge - 45) div 2;
  SoundManager.PlaySound('Sound.Sell');
  ReplaceTextToken(DialogText, '<FlyToStar>', GetPlayer.QueuedTravelTarget.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $5862C0 }

{ @routine $58647C TfRuinsTalk_DeclineDominionTravelConfirmation }
procedure TfRuinsTalk.DeclineDominionTravelConfirmation(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterNoConfirm');
  M_Main(True);
end;
{ @end $58647C }

{ @routine $586538 TfRuinsTalk_ShowDominionCancelTravelDialog }
procedure TfRuinsTalk.ShowDominionCancelTravelDialog(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBCancelTeleport');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.CancelYes'), 0, CancelDominionTravel);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.CancelNo'), 0, DeclineDominionCancelTravel);
end;
{ @end $586538 }

{ @routine $58670C TfRuinsTalk_CancelDominionTravel }
procedure TfRuinsTalk.CancelDominionTravel(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterCancelTeleport');
  GetPlayer.QueuedTravelTarget := nil;
  M_Main(True);
end;
{ @end $58670C }

{ @routine $5867E0 TfRuinsTalk_DeclineDominionCancelTravel }
procedure TfRuinsTalk.DeclineDominionCancelTravel(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterNoCancel');
  ReplaceTextToken(DialogText, '<FlyToStar>', GetPlayer.QueuedTravelTarget.Name, TextHighlightColorTag);
  M_Main(True);
end;
{ @end $5867E0 }

{ @routine $586908 GetDominionRelocationCost }
function GetDominionRelocationCost(Star: TStar): Integer;
var
  Discount: Byte;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  Result := Min(MaxMonetaryValue, Round((PointDistanceSquared(GetPlayer.DockedTo.CurrentStar.Position, Star.Position) + 6400) * SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(owner_human) div 2, Galaxy.ComputeScaledHugeMoney(owner_human) * 2, Star.GenerationSeed + 1171 + GetPlayer.DockedTo.CurrentStar.GenerationSeed) / 6400 * (100 - Discount) / 100));
end;
{ @end $586908 }

{ @routine $586A04 TfRuinsTalk_ShowDominionRelocationDialog }
procedure TfRuinsTalk.ShowDominionRelocationDialog(Action: Cardinal);
const
  StationMask = [station_ranger_center..station_dominion];
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
  begin
    if GetPlayer.NoJump then Continue;
    IncrementWrapped(Index, First, Last);
    Star := GetPlayer.CurrentStar.StarDistances[Index].Star as TStar;
    if Star.NoComeKling then Continue;
    if Constellations.IndexOf(Star.Constellation) >= 0 then Continue;
    if not ((SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 1387) >= 0.6)) then Continue;
    if Star.Constellation.Id = 20 then Continue;
    if not (((Star.Constellation.ShipTypeCounts[station_dominion] <= 0) or (Star.Constellation = GetPlayer.DockedTo.CurrentStar.Constellation))) then Continue;
    if not ((Star.Constellation.CountShipsByTypeMask(StationMask) < Star.Constellation.Stars.Count)) then Continue;
    if Star.Dominion <> nil then Continue;
    if not ((Star.CountShipsByTypeMask(StationMask) <= 2)) then Continue;
    if Star.ShipTypeCounts[ship_dominator] > 0 then Continue;
    if Star.ControlFaction <> faction_pirates then Continue;
    if Star.Battle <> 0 then Continue;
    if Star.Status.CustomFaction <> '' then Continue;
    if GetPlayer.DockedTo.CurrentStar = Star then Continue;
    if not (Star.IsConstellationVisible) then Continue;
    Inc(Count);
    Cost := GetDominionRelocationCost(Star);
    if Cost > GetPlayer.Money then
      AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.CB.WarPlans.Relocate.ToStar'), TextHighlightColorTag, '<ToStar>', Star.Name, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback)
    else AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.CB.WarPlans.Relocate.ToStar'), TextHighlightColorTag, '<ToStar>', Star.Name, '<Cost>', IntToStr(Cost)), Integer(Star), AcceptDominionRelocation);
    // Native disabled choice uses the shared quote and <Money>, unlike the enabled choice.
    Constellations.Add(Star.Constellation);
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
{ @end $586A04 }

{ @routine $587118 TfRuinsTalk_AcceptDominionRelocation }
procedure TfRuinsTalk.AcceptDominionRelocation(Action: Cardinal);
var
  Star: TStar;
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Relocate.CBAfterConfirm');
  Star := TStar(Action);
  ReplaceTextToken(DialogText, '<ToStar>', Star.Name, TextHighlightColorTag);
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
{ @end $587118 }

{ @routine $587438 TfRuinsTalk_DeclineDominionRelocation }
procedure TfRuinsTalk.DeclineDominionRelocation(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Relocate.CBAfterRefuse');
  BuildDominionWarOptions;
end;
{ @end $587438 }

{ @routine $5874F4 TfRuinsTalk_BuildDominionWarOptions }
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
  if Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]) then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Assault.PlayerSend2'), 1, ShowDominionAssaultDialog);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.PlayerNoQuestions'), 0, ReturnToMain);
end;
{ @end $5874F4 }

{ @routine $5879E8 TfRuinsTalk_I_CBWarWithKlingAndCoalition }
procedure TfRuinsTalk.I_CBWarWithKlingAndCoalition(Action: Cardinal);
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
  CoalitionPercent := Galaxy.GetFactionControlPercent(faction_coalition);
  DominatorPercent := Galaxy.GetFactionControlPercent(faction_dominators);
  PiratePercent := Galaxy.GetFactionControlPercent(faction_pirates);
  for I := 0 to Galaxy.Stars.Count - 1 do
    if ((GetPlayer.CurrentStar.StarDistances[I].Star as TStar).ControlFaction in [faction_coalition, faction_dominators]) and
      ((GetPlayer.CurrentStar.StarDistances[I].Star as TStar).Constellation.Id <> 20) then
    begin
      Star := TStar(GetPlayer.CurrentStar.StarDistances[I].Star);
      Break;
    end;
  if Star = nil then
  begin
    if not Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]) and (Galaxy.CoalitionDefeatedTurn = 0) then
      Path := 'FormRuins.CB.WarPlans.WarWithKlingAndCoalition.CoalitionOnly.CBAnswerWeControl100Percent'
    else if Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]) and (Galaxy.CoalitionDefeatedTurn <> 0) then
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
  ReplaceTextToken(DialogText, '<CB>', GetPlayer.DockedTo.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(CoalitionPercent), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<DominatorsPercent>', IntToStr(DominatorPercent), TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<PiratesPercent>', IntToStr(PiratePercent), TextHighlightColorTag);
  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.CB.WarPlans.WarWithKlingAndCoalition.ExtraTextAboutRanks');
  BuildDominionWarOptions;
end;
{ @end $5879E8 }

{ @routine $588550 TfRuinsTalk_ShowDominionCaptureAnswer }
procedure TfRuinsTalk.ShowDominionCaptureAnswer(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.CBAnswersAboutCapture');
  BuildDominionWarOptions;
end;
{ @end $588550 }

{ @routine $588608 TfRuinsTalk_ShowDominionRanksAnswer }
procedure TfRuinsTalk.ShowDominionRanksAnswer(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.CBAnswersAboutRanks');
  ReplaceTextToken(DialogText, '<BaseName>', GetPlayer.DockedTo.Name, '');
  BuildDominionWarOptions;
end;
{ @end $588608 }

{ @routine $5886F4 ApplyRecentDominionOrderSurcharge }
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
{ @end $5886F4 }

{ @routine $5888BC TfRuinsTalk_ShowDominionWarOperationDialog }
procedure TfRuinsTalk.ShowDominionWarOperationDialog(Action: Cardinal);
begin
  if not CheckDominionServiceStanding(1, LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBRefusePrefix'), 0) then
  begin
    BuildDominionWarOptions;
    Exit;
  end;
  StationServiceQuoteCost := ApplyRecentDominionOrderSurcharge(Galaxy.ComputeScaledHugeMoney(owner_human));
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBAboutWarOperation');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
  ClearChoices;
  if GetPlayer.Money >= StationServiceQuoteCost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.PlayerOk'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, AcceptDominionWarOperation)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.PlayerOk'), TextHighlightColorTag, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.PlayerNo'), 0, DeclineDominionWarOperation);
end;
{ @end $5888BC }

{ @routine $588CD8 TfRuinsTalk_AcceptDominionWarOperation }
procedure TfRuinsTalk.AcceptDominionWarOperation(Action: Cardinal);
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
  StationServiceQuoteCost := ApplyRecentDominionOrderSurcharge(Galaxy.ComputeScaledHugeMoney(owner_human));
  GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
  if MainPiratePlanet <> nil then MainPiratePlanet.ChangeRelationToRanger(GetPlayer, 10);
  Target := nil;
  BestAvailable := 0;
  BestTotal := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Candidate := Galaxy.Stars[I];
    if (Candidate.Constellation.Id <> 20) and Candidate.IsConstellationVisible and not Candidate.NoComeKling and
      not IsStarProtectedByScript(Candidate) and (Candidate.ControlFaction <> faction_pirates) then
    begin
      Available := 0;
      Total := 0;
      for J := 0 to Galaxy.Stars.Count - 1 do
      begin
        Origin := Galaxy.Stars[J];
        if (Candidate <> Origin) and (Origin.ControlFaction = faction_pirates) and (Origin.Status.CustomFaction = '') and
          (Origin.Battle = 0) and (Origin.CountForcesByOwnerGroups(Strength, True, True, False, False) <= 0) then
          for K := 0 to Origin.Ships.Count - 1 do
          begin
            Ship := Origin.Ships[K];
            if (Ship is TPirate) and (Ship.OwnerId = owner_pirate) and (Ship.PartnerShip = nil) then
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
        Origin := TStar(Target.StarDistances[J].Star);
        if (Origin.ControlFaction = faction_pirates) and (Origin.Status.CustomFaction = '') and (Origin.Battle = 0) and
          (Origin.CountForcesByOwnerGroups(Strength, True, True, False, False) <= 0) then
          for K := 0 to Origin.Ships.Count - 1 do
          begin
            Ship := Origin.Ships[K];
            if (Ship is TPirate) and (Ship.OwnerId = owner_pirate) and (Ship.PartnerShip = nil) then
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
    ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<StarEnemy>', Target.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<SectorEnemy>', Target.Constellation.GetName, TextHighlightColorTag);
    ClearChoices;
    M_Main(True);
  end;
end;
{ @end $588CD8 }

{ @routine $5895CC TfRuinsTalk_DeclineDominionWarOperation }
procedure TfRuinsTalk.DeclineDominionWarOperation(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBAfterNo');
  BuildDominionWarOptions;
end;
{ @end $5895CC }

{ @routine $589688 TfRuinsTalk_ShowDominionAmbushDialog }
procedure TfRuinsTalk.ShowDominionAmbushDialog(Action: Cardinal);
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
    if (Group = nil) or (Group.Ships.Count <= 0) then Continue;
    Entry := Group.Route[Length(Group.Route) - 1];
    if Entry.Kind <> order_jump then Continue;
    Star := TStar(Entry.Target);
    if Star = nil then Continue;
    if not Star.IsConstellationVisible then Continue;
    if (Star.ControlFaction = faction_coalition) and (Star.Status.CustomFaction = '') then Continue;
    if (Group.Route[2].WaitUntilTurn < Turn) or (Target = nil) then
    begin
      Target := Star;
      Turn := Group.Route[2].WaitUntilTurn;
    end;
  end;
  Base := Galaxy.FindMilitaryBaseInTransit;
  if Base <> nil then
  begin
    Star := Base.FlyToStar;
    // The native fallback is outside the destination eligibility conjunction.
    if ((Star <> nil) and Star.IsConstellationVisible and ((Star.ControlFaction <> faction_coalition) or (Star.Status.CustomFaction <> '')) and
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
    ReplaceTextToken(DialogText, '<Star>', Target.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Date>', FormatGameTurnDate(Turn), TextHighlightColorTag);
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
        ReplaceTextToken(DialogText, '<Star>', Target.Name, TextHighlightColorTag);
        ReplaceTextToken(DialogText, '<Date>', FormatGameTurnDate(Turn), TextHighlightColorTag);
        BuildDominionWarOptions;
        Exit;
      end;
  end;
  Count := 0;
  Star := GetPlayer.DockedTo.CurrentStar;
  for I := 0 to Star.Ships.Count - 1 do
  begin
    Ship := Star.Ships[I];
    if not Ship.InHyperspace and (Ship is TPirate) and (Ship.OwnerId = owner_pirate) and (Ship.PartnerShip = nil) and
      (Ship.ScriptShip = nil) and not Ship.HasScriptControl then Inc(Count);
  end;
  if Count < 8 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAnswerNotEnoughPirates');
    ReplaceTextToken(DialogText, '<Star>', Target.Name, TextHighlightColorTag);
    ReplaceTextToken(DialogText, '<Date>', FormatGameTurnDate(Turn), TextHighlightColorTag);
    BuildDominionWarOptions;
    Exit;
  end;
  ClearChoices;
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAnswerOperationSoon');
  ReplaceTextToken(DialogText, '<Star>', Target.Name, TextHighlightColorTag);
  ReplaceTextToken(DialogText, '<Date>', FormatGameTurnDate(Turn), TextHighlightColorTag);
  StationServiceQuoteCost := ApplyRecentDominionOrderSurcharge(GetDominionRelocationCost(Target) * 1.5);
  ReplaceTextToken(DialogText, '<Cost>', IntToStr(StationServiceQuoteCost), TextHighlightColorTag);
  if GetPlayer.Money >= StationServiceQuoteCost then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Ambush.Confirm'), Integer(Target), AcceptDominionAmbush)
  else AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Ambush.Confirm'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Ambush.Refuse'), 0, DeclineDominionAmbush);
end;
{ @end $589688 }

{ @routine $58A044 TfRuinsTalk_AcceptDominionAmbush }
procedure TfRuinsTalk.AcceptDominionAmbush(Action: Cardinal);
var
  Star: TStar;
  Event: TGalaxyEvent;
begin
  Star := TStar(Action);
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAfterOk');
  ReplaceTextToken(DialogText, '<ToStar>', Star.Name, TextHighlightColorTag);
  StationServiceQuoteCost := ApplyRecentDominionOrderSurcharge(GetDominionRelocationCost(Star) * 1.5);
  Event := AddGalaxyEvent('PlayerOrdersPirateAmbush');
  Event.AddData(Star.Id);
  SoundManager.PlaySound('Sound.Sell');
  GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
  SpendDominionServiceCredit(1.5);
  TRuins(GetPlayer.DockedTo).RelocationAge := (TRuins(GetPlayer.DockedTo).RelocationAge - 150) div 2;
  TRuins(GetPlayer.DockedTo).FlyToStar := Star;
  if Star.ControlFaction = faction_pirates then TRuins(GetPlayer.DockedTo).FlyDate := Galaxy.CurrentTurn + 12
  else TRuins(GetPlayer.DockedTo).FlyDate := Galaxy.CurrentTurn + 16;
  M_Main(True);
end;
{ @end $58A044 }

{ @routine $58A2A0 TfRuinsTalk_DeclineDominionAmbush }
procedure TfRuinsTalk.DeclineDominionAmbush(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAfterRefuse');
  BuildDominionWarOptions;
end;
{ @end $58A2A0 }

{ @routine $58A358 TfRuinsTalk_ShowDominionAssaultDialog }
procedure TfRuinsTalk.ShowDominionAssaultDialog(Action: Cardinal);
var
  I, Count, Index, First, Last, Cost: Integer;
  Star: TStar;
  Constellations: TList;
  Faction: TStarFaction;
  Rank: TShipRank;
  CreditCost: Single;
begin
  ClearChoices;
  if Action = 0 then
  begin
    Faction := faction_coalition;
    Rank := 5;
    CreditCost := 2;
  end
  else
  begin
    Faction := faction_dominators;
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
  begin
    if GetPlayer.NoJump then Continue;
    IncrementWrapped(Index, First, Last);
    Star := GetPlayer.CurrentStar.StarDistances[Index].Star as TStar;
    if Star.NoComeKling then Continue;
    if Constellations.IndexOf(Star.Constellation) >= 0 then Continue;
    if SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 1387) < 0.8 then Continue;
    if Star.Constellation.Id = 20 then Continue;
    if not ((Star.Constellation.ShipTypeCounts[station_dominion] <= 0) and
      (Star.Dominion = nil)) then Continue;
    if not ((Star.ControlFaction = Faction) and
      (Star.Status.CustomFaction = '')) then Continue;
    if GetPlayer.DockedTo.CurrentStar = Star then Continue;
    if not (Star.IsConstellationVisible) then Continue;
    Inc(Count);
    Cost := ApplyRecentDominionOrderSurcharge(GetDominionRelocationCost(Star) * 2.5);
    if Cost > GetPlayer.Money then
      AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.CB.WarPlans.Assault.ToStar'), TextHighlightColorTag, '<ToStar>', Star.Name, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback)
    else AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.CB.WarPlans.Assault.ToStar'), TextHighlightColorTag, '<ToStar>', Star.Name, '<Cost>', IntToStr(Cost)), Integer(Star), AcceptDominionAssault);
    // Native disabled choice uses the shared quote and <Money>, unlike the enabled choice.
    Constellations.Add(Star.Constellation);
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
{ @end $58A358 }

{ @routine $58AA50 TfRuinsTalk_AcceptDominionAssault }
procedure TfRuinsTalk.AcceptDominionAssault(Action: Cardinal);
var
  Star: TStar;
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Assault.CBAfterConfirm');
  Star := TStar(Action);
  ReplaceTextToken(DialogText, '<ToStar>', Star.Name, TextHighlightColorTag);
  GetPlayer.SetMoney(GetPlayer.Money - ApplyRecentDominionOrderSurcharge(GetDominionRelocationCost(Star) * 2.5));
  SpendDominionServiceCredit(1);
  TRuins(GetPlayer.DockedTo).RelocationAge := (TRuins(GetPlayer.DockedTo).RelocationAge - 150) div 2;
  SoundManager.PlaySound('Sound.Sell');
  TRuins(GetPlayer.DockedTo).FlyToStar := Star;
  TRuins(GetPlayer.DockedTo).FlyDate := Galaxy.CurrentTurn + 12;
  M_Main(True);
end;
{ @end $58AA50 }

{ @routine $58AC40 TfRuinsTalk_DeclineDominionAssault }
procedure TfRuinsTalk.DeclineDominionAssault(Action: Cardinal);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Assault.CBAfterRefuse');
  BuildDominionWarOptions;
end;
{ @end $58AC40 }

{ @routine $58ACF8 TfRuinsTalk_ExecuteUiCode }
procedure TfRuinsTalk.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not MainPanel.NavigationLocked and not ExitScreenLoop and
    (TurnCalculationPhase in [turn_idle, turn_galaxy_finished, turn_player_star_finished, turn_player_star_prepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10009);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20009);
  end;
end;
{ @end $58ACF8 }

end.
