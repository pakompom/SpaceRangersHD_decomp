unit fTalk;
// Unit bracket (inferred): .text 0x006D0EE0..0x006E69C0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, EC_CacheFont, GI_Label, GI_Panel, GI_MessageLoop, Types, aScript, aItem, aGalaxyStruct;

type
  // TfStarMap.RunTalkDialogs dispatches the next modal screen from this value.
  TTalkModalTransition = (tmtNone = 0, tmtReopen = 1, tmtTrade = 2); // @size $04

  TDialogTextChoiceEvent = procedure(Text: WideString) of object;

  TfTalkA = class(TObjectEx) // @size $24
  public
    Reserved04: Integer; // @offset $04 No managed cleanup at this offset.
    Callback: TDialogChoiceEventGI; // @offset $08
    FallbackCallback: TDialogTextChoiceEvent; // @offset $10
    Value: Integer; // @offset $18
    ExtraValue: Integer; // @offset $1C
    FallbackText: WideString; // @offset $20 Native cleanup table $6D0F2C owns this string.
    constructor Create; // @addr $6D0FF0
    destructor Destroy; override; // @addr $6D1034
  end;

  TfTalk = class(TMessageLoopGI) // @size 0x134
  public
    MainPanel: TPanelGI; // @offset $D0
    DialogPanel: TPanelGI; // @offset $D4
    PresentedTextLength: Integer; // @offset $DC
    TextPresentationTimer: PCallbackTimerGI; // @offset $E0
    ChoiceHeight: Integer; // @offset $E4
    SkipShipScriptAdvance: Boolean; // @offset $F0
    ChoiceMousePressed: Boolean; // @offset $F1
    RequestedMapCenter: TObject; // @offset $F4
    CurrentMapCenter: TObject; // @offset $F8
    MapSelectionTimer: PCallbackTimerGI; // @offset $FC
    RequestedMapHover: TObject; // @offset $100
    CurrentFilmObjectId: Cardinal; // @offset $104
    CurrentMapHover: TObject; // @offset $108
    MinimapRefreshTimer: PCallbackTimerGI; // @offset $10C
    MinimapEnabled: Boolean; // @offset $110
    MapDragging: Boolean; // @offset $111
    MapDragPoint: TPoint; // @offset $112
    SlideTimer: PCallbackTimerGI; // @offset $11C
    SlideProgress: Single; // @offset $120
    DialogPanelLeft: Integer; // @offset $124
    SavedChoiceScroll: Integer; // @offset $130
    procedure ShowMoneyDemand(Action: Integer); // @addr $6D94E8
    procedure ShowTruceOffer(Action: Integer); // @addr $6D9BFC
    procedure ShowPartnerOffer(Action: Integer); // @addr $6DBFCC
    procedure ShowPartnerGift(Action: Integer); // @addr $6DD6B0
    procedure ShowPiratePartnerOffer(Action: Integer); // @addr $6DFBB4
    procedure ShowPiratePartnerGift(Action: Integer); // @addr $6E1768
    procedure ShowMilitarySupport(Action: Integer); // @addr $6E36B8
    procedure ShowMilitaryHullRepair(Action: Integer); // @addr $6E3C68
    procedure AcceptMilitaryHullRepair(Action: Integer); // @addr $6E40D4
    procedure ShowMilitaryEquipmentRepair(Action: Integer); // @addr $6E4458
    procedure AcceptMilitaryEquipmentRepair(Action: Integer); // @addr $6E48B0
    procedure ShowMilitaryRemains(Action: Integer); // @addr $6E4C1C
    procedure SellAllMilitaryRemains(Action: Integer); // @addr $6E51DC
    procedure SellIndividualMilitaryRemains(Action: Integer); // @addr $6E53E0
    procedure AcceptMilitaryBuff(Action: Integer); // @addr $6E5CBC
    procedure DiscussOldHull(Action: Integer); // @addr $6E5E70
    procedure ShowMilitaryBuff(Action: Integer); // @addr $6E59A8
    procedure BuildMilitarySupportChoices; // @addr $6E3200
    procedure AcceptScriptedConversation(Action: Integer); // @addr $6D8C88
    procedure RunScriptExitAnswer(Action: Integer); // @addr $6D8BC0
    function GetShipGreeting: WideString; // @addr $6E2F3C
    procedure ShowGreeting(Action: Integer); // @addr $6D8C20
    procedure OpenTrade(Action: Integer); // @addr $6D93F0
    procedure CancelTrade(Action: Integer); // @addr $6D9448
    procedure DemandMoney(Action: Integer); // @addr $6D9AAC
    procedure DemandCargo(Action: Integer); // @addr $6D9B98
    procedure HalveMoneyDemand(Action: Integer); // @addr $6D9B44
    procedure HalvePartnerOffer(Action: Integer); // @addr $6DC804
    procedure HalvePartnerGift(Action: Integer); // @addr $6DDC4C
    procedure HalvePiratePartnerOffer(Action: Integer); // @addr $6E0304
    procedure HalvePiratePartnerGift(Action: Integer); // @addr $6E1D64
    procedure DoubleMoneyDemand(Action: Integer); // @addr $6D9B70
    procedure HalveTruceOffer(Action: Integer); // @addr $6DA2EC
    procedure DoubleTruceOffer(Action: Integer); // @addr $6DA334
    procedure DoublePartnerOffer(Action: Integer); // @addr $6DC830
    procedure DoublePiratePartnerOffer(Action: Integer); // @addr $6E0330
    procedure DoublePartnerGift(Action: Integer); // @addr $6DDC78
    procedure DoublePiratePartnerGift(Action: Integer); // @addr $6E1D90
    procedure AcceptPartnerOffer(Action: Integer); // @addr $6DC790
    procedure AcceptPiratePartnerOffer(Action: Integer); // @addr $6E0278
    procedure ExitPartnerConversation(Action: Integer); // @addr $6DDE24
    procedure ShowDominatorGreeting(Action: Integer); // @addr $6E2808
    procedure ShowDominatorPeace(Action: Integer); // @addr $6E28D4
    procedure ShowDominatorGoods(Action: Integer); // @addr $6E29A8
    procedure ShowDominatorCommand(Action: Integer); // @addr $6E2A7C
    procedure RunInjectedAnswer(Action: Integer); // @addr $6E2FB8
    procedure RunInjectedAnswerKeepingScroll(Action: Integer); // @addr $6E31A4
    procedure StartScriptMessage(Script: TScript); // @addr $6E31C8
    procedure CancelMilitarySupport(Action: Integer); // @addr $6E3A44
    procedure DeclineMilitarySupport(Action: Integer); // @addr $6E3AFC
    procedure RunScriptRestartAnswer(Action: Integer); // @addr $6E6900
    procedure ShowTrade(Action: Integer); // @addr $6D8D38
    procedure AcceptTruceOffer(Action: Integer); // @addr $6DA1D8
    procedure GivePartnerGift(Action: Integer); // @addr $6DD9D8
    procedure GivePiratePartnerGift(Action: Integer); // @addr $6E1A8C
    procedure OrderPartnerFollow(Action: Integer); // @addr $6DC880
    procedure OrderPiratePartnerFollow(Action: Integer); // @addr $6E095C
    procedure OrderPartnerLand(Action: Integer); // @addr $6DCB34
    procedure OrderPartnerJump(Action: Integer); // @addr $6DCEE0
    procedure OrderPiratePartnerLand(Action: Integer); // @addr $6E0C0C
    procedure OrderPiratePartnerJump(Action: Integer); // @addr $6E1088
    procedure OrderPiratePartnerAttack(Action: Integer); // @addr $6E063C
    procedure ApplyOrderToAllPartners(Action: Integer); // @addr $6DDCC4
    procedure OrderPartnerDropCargo(Action: Integer); // @addr $6DD218
    procedure ShowPartnerFinances(Action: Integer); // @addr $6DD454
    procedure ShowPiratePartnerFinances(Action: Integer); // @addr $6E1514
    procedure ShowPartnerDismissal(Action: Integer); // @addr $6E1DDC
    procedure ShowPirateAttackTargets(Action: Integer); // @addr $6E0380
    procedure OrderTranclucatorFollow(Action: Integer); // @addr $6DDE40
    procedure OrderTranclucatorReturn(Action: Integer); // @addr $6DDF9C
    procedure OrderTranclucatorSeekItems(Action: Integer); // @addr $6DE0F8
    procedure CancelTranclucatorSeekItems(Action: Integer); // @addr $6DE260
    procedure OrderTranclucatorDropCargo(Action: Integer); // @addr $6DF2A4
    procedure OrderTranclucatorLand(Action: Integer); // @addr $6DF3F8
    procedure OrderTranclucatorStoreCargo(Action: Integer); // @addr $6DF654
    procedure AddTranclucatorGroupChoice; // @addr $6DF898
    procedure ApplyOrderToAllTranclucators(Action: Integer); // @addr $6DF9F8
    procedure ShowTranclucatorOptions(Action: Integer); // @addr $6DEE2C
    procedure ShowAttackTargets(Action: Integer); // @addr $6DA568
    procedure RequestAttackTarget(Action: Integer); // @addr $6DABA4
    procedure AcceptJointAttack(Action: Integer); // @addr $6DAFF8
    procedure RunDominatorProgram(Action: Integer); // @addr $6E2464
    function AddImmediateAttackChoices: Boolean; // @addr $6E2B54
    procedure RequestProtection(Action: Integer); // @addr $6DB26C
    procedure RequestPreserveItems(Action: Integer); // @addr $6DBD2C
    procedure BuildBuiltinChoices; // @addr $6D5048
    procedure BuildStandardChoices(KeepGreeting: Boolean); // @addr $6D498C
    procedure OnOpen; override; // @addr $6D14AC
    procedure OnClose; override; // @addr $6D222C
    procedure InitializeLayout; override; // @addr $6D1068
    procedure MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6D3074
    procedure MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6D3354
    procedure MainPanelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6D34AC
    procedure AddDialogEffect(Position: TPointF; ImagePath: WideString; DelayMs: Integer); // @addr $6D3C08
    procedure MinimapScrolled; // @addr $6D42DC
    procedure FlushMinimapRefresh(Timer: PCallbackTimerGI; UserData: Integer); // @addr $6D437C
    procedure AdvanceSlide(Timer: PCallbackTimerGI; UserData: Integer); // @addr $6D4410
    procedure UpdateSlidePosition; // @addr $6D44A0
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $6D45BC
    procedure ApplyMapSelection(Timer: PCallbackTimerGI; UserData: Integer); // @addr $6D3DF0
    DialogText: WideString; // @offset $D8
    ModalTransition: TTalkModalTransition; // @offset $128 Reopen dialogue or switch to goods trading after refreshing the star-map background.
    ReturnedFromTrade: Boolean; // @offset $12C Set after the goods-trading modal returns; reset on opening dialogue, with no retained reader.
    procedure RememberChoiceScroll; // @addr $6D247C
    procedure EnableCloseButton; // @addr $6D24C8
    procedure CloseClicked(Sender: TObjectGI); // @addr $6D250C
    procedure ClearChoices(AllowClose: Boolean); // @addr $6D2528
    function CreateDialogObject(LabelControl: TLabelGI; Item: PFontObjectEC): TObjectGI; // @addr $6D2BCC
    procedure CenterEmbeddedObject(Sender: TObjectGI); // @addr $6D2F60
    procedure CenterShipClicked(Sender: TObjectGI); // @addr $6D2FBC
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $6D3518
    procedure ChoiceMouseEnter(Sender: TObjectGI); // @addr $6D3610
    procedure ChoiceMouseLeave(Sender: TObjectGI); // @addr $6D3630
    procedure ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6D3650
    procedure ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6D36D8
    procedure RestartTextPresentation; // @addr $6D37C8
    procedure AdvanceTextPresentation(Timer: PCallbackTimerGI; UserData: Integer); // @addr $6D3860
    procedure ClearDialogEffects; // @addr $6D3D30
    procedure DialogEffectComplete(Sender: TObjectGI); // @addr $6D3D88
    procedure ProcessCallbackTimers; override; // @addr $6D3DB0
    procedure AddMessageClicked(Sender: TObjectGI); // @addr $6D40F8
    procedure ReturnToMap(Action: Integer); // @addr $6D8CE0
    procedure SelectMusic; override; // @addr $6D477C
    procedure AddChoice(Text: WideString; Value: Integer; Callback: TDialogChoiceEventGI; ExtraValue: Integer); // @addr $6D25DC ExtraValue is stored in the choice object at $1C; its wider meaning remains unresolved.
    procedure CodeMsgOut(KeepGreeting: Boolean); // @addr $6D831C
    procedure ShipDismissAct(Action: Integer); // @addr 0x6E20EC
    procedure AddScriptExitChoice(Caption: WideString); // @addr $6D822C
    procedure AddScriptRestartChoice(Caption: WideString); // @addr $6E6944
    procedure FastExit(Answer: Integer); // @addr $6D8B58
    procedure RunScriptAnswerKeepingScroll(Answer: Integer); // @addr $6D8B34
    procedure RunScriptAnswer(Answer: Integer); // @addr $6D8AC0
  end;

function IsMilitaryProtectedQuestItem(Item: TItem): Boolean; // @addr $6E4ABC
procedure DonateMilitaryResearchMaterial(Series: TDominatorSeries; Amount: Integer); // @addr $6E50D0

function GetMilitaryHullRepairCost: Integer; // @addr $6E3BA8
function GetMilitaryEquipmentRepairCost: Integer; // @addr $6E4320

function RunTalk(ParentLoop: TMessageLoopGI): Boolean; // @addr $6D4838 Native modal conversation wrapper.

var
  ScriptDialogBlockCallback: TDialogChoiceEventGI = nil; // @addr $87BFB4 Shared disabled-choice callback.
  TruceOfferAmount: Integer; // @addr $88B0C8
  ExtortionDemandAmount: Integer; // @addr $88B0CC
  PartnerOfferAmount: Integer; // @addr $88B0D0
  PartnerGiftAmount: Integer; // @addr $88B0D4
  TalkDialogActive: Boolean = False; // @addr $87BFBC Set by native conversation setup at $6D14AC; cleared by cleanup at $6D222C. Suppresses recursive SF_Dialog dispatch.
  TalkSlideCurve: array[0..15] of Single = (0, 0.033, 0.078, 0.149, 0.273, 0.44, 0.611, 0.753, 0.888, 0.963, 1.009, 1.025, 1.02, 1.012, 1.008, 1); // @addr $87BFC0

implementation

uses Globals, GlobalsV, aPlayer, aShip, aGalaxy, aConst, aMyFunction, fStarMap, GI_PanelScrollBar, GI_ScrollBar, GI_Image, GI_GraphButton, GI_Main, GI_GAI, EC_Str, SysUtils, Classes, Math, GR_Main, Windows, aPlanet, aItem, SE_Space, SE_Process, GI_GraphBuf, aRanger, aRuins, aKling, aNormalShip, aGalaxyStruct, aPirate, aTranclucator, SE_Weapon, Achievements, aWarrior;

{ @routine $6D0FF0 TfTalkA_Create }
constructor TfTalkA.Create;
begin
  inherited Create;
end;
{ @end $6D0FF0 }

{ @routine $6D1034 TfTalkA_Destroy }
destructor TfTalkA.Destroy;
begin
  inherited Destroy;
end;
{ @end $6D1034 }

{ @routine $6D1068 TfTalk_InitializeLayout }
procedure TfTalk.InitializeLayout;
var
  Panel, MapPanel, Sibling, CenterPlayer, TalkPanel: TObjectGI;
  LabelControl: TLabelGI;
  AddButton, CenterShipButton, CenterPlayerButton: TGraphButtonGI;
  MapBuffer: TGraphBufGI;
  CloseButton: TGraphButtonGI;
begin
  inherited InitializeLayout;
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Panel := GetByName('MainPanel');
  Panel.SetSize(Point(GameScreenWidth, GameScreenHeight));
  Panel.FindByNameRecursive('BGBuf').SetSize(Point(GameScreenWidth, GameScreenHeight));
  MapPanel := Panel.FindByNameRecursive('MapPanel');
  MapPanel.SetPosition(Point(MapPanel.LocalPosition.X + ExtraScreenWidth, MapPanel.LocalPosition.Y));
  Sibling := MapPanel.NextSibling;
  Sibling.SetPosition(Point(Sibling.LocalPosition.X + ExtraScreenWidth, Sibling.LocalPosition.Y));
  CenterPlayer := Panel.FindByNameRecursive('CenterPlayer');
  CenterPlayer.SetPosition(Point(CenterPlayer.LocalPosition.X + ExtraScreenWidth, CenterPlayer.LocalPosition.Y));
  TalkPanel := Panel.FindByNameRecursive('PanelTalk');
  TalkPanel.SetPosition(Point(TalkPanel.LocalPosition.X + ExtraScreenWidth, TalkPanel.LocalPosition.Y));
  ScriptDialogIndex := -1;
  MainPanel := GetByName('MainPanel') as TPanelGI;
  MainPanel.MouseMoveCallback := MainPanelMouseMove;
  MainPanel.KeyDownCallback := MainPanelKeyDown;
  MainPanel.RightButtonDownCallback := MainPanelMouseDown;
  MainPanel.RightButtonUpCallback := MainPanelMouseUp;
  DialogPanel := GetByName('PanelTalk') as TPanelGI;
  DialogPanelLeft := DialogPanel.LocalPosition.X;
  LabelControl := GetByName('TalkText') as TLabelGI;
  LabelControl.CreateEmbeddedControl := CreateDialogObject;
  AddButton := GetByName('UserMsgAdd') as TGraphButtonGI;
  AddButton.UpCallback := AddMessageClicked;
  CenterShipButton := GetByName('CenterShip') as TGraphButtonGI;
  CenterShipButton.UpCallback := CenterShipClicked;
  CenterPlayerButton := GetByName('CenterPlayer') as TGraphButtonGI;
  CenterPlayerButton.UpCallback := CenterShipClicked;
  MapBuffer := GetByName('MapPanel') as TGraphBufGI;
  MapBuffer.BindExternalGraphBuf(RenderScratchBuffer);
  CloseButton := GetByName('Close') as TGraphButtonGI;
  CloseButton.UpCallback := CloseClicked;
end;
{ @end $6D1068 }

{ @routine $6D14AC TfTalk_OnOpen }
procedure TfTalk.OnOpen;
var
  Position: TPoint;
  CenterShipButton, CenterPlayerButton: TGraphButtonGI;
  ExistingAnimation: TgaiGI;
  MapControl: TObjectGI;
  Portrait: TImageGI;
  Animation: TgaiGI;
  TextLabel: TLabelGI;
  Choices: TPanelScrollBarGI;
begin
  TalkDialogActive := True;
  if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(False, 0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  if SlideTimer <> nil then
  begin
    CancelCallbackTimer(SlideTimer);
    SlideTimer := nil;
  end;
  SavedChoiceScroll := -1;
  MinimapEnabled := False;
  ChoiceMousePressed := False;
  if (ModalTransition <> tmtNone) and MapDragging then
  begin
    if not IsCursorImageSelected('Scroll') then SetCursorByName('Scroll');
  end
  else if not IsCursorImageSelected('Main') then SetCursorByName('Main');
  CenterShipButton := GetByName('CenterShip') as TGraphButtonGI;
  CenterShipButton.SetActive(GetPlayer.InNormalSpace);
  CenterPlayerButton := GetByName('CenterPlayer') as TGraphButtonGI;
  CenterPlayerButton.SetActive(GetPlayer.InNormalSpace);
  ClearDialogEffects;
  if GetPlayer.InNormalSpace then
  begin
    if ModalTransition = tmtNone then
    begin
      if TalkShip <> nil then Position := TruncatePointF(TalkShip.Position)
      else Position := TruncatePointF(TalkPlanet.GetPosition);
      Position := StarMapScreen.MapControls.ToAbsolutePoint(Position);
      AddDialogEffect(PointToPointF(Position), 'Bm.SI.' + GiResourceSuffix + 'Ring', 0);
      AddDialogEffect(PointToPointF(Position), 'Bm.SI.' + GiResourceSuffix + 'Ring', 200);
      AddDialogEffect(PointToPointF(Position), 'Bm.SI.' + GiResourceSuffix + 'Ring', 400);
    end
    else if RequestedMapCenter <> nil then
    begin
      if RequestedMapCenter is TShip then Position := TruncatePointF((RequestedMapCenter as TShip).Position)
      else if RequestedMapCenter is TItem then Position := TruncatePointF((RequestedMapCenter as TItem).Position)
      else Position := TruncatePointF((RequestedMapCenter as TPlanet).GetPosition);
      Position := StarMapScreen.MapControls.ToAbsolutePoint(Position);
      AddDialogEffect(PointToPointF(Position), 'Bm.SI.' + GiResourceSuffix + 'Ring', 0);
      AddDialogEffect(PointToPointF(Position), 'Bm.SI.' + GiResourceSuffix + 'Ring', 200);
      AddDialogEffect(PointToPointF(Position), 'Bm.SI.' + GiResourceSuffix + 'Ring', 400);
    end;
  end;
  RequestedMapCenter := nil;
  if ModalTransition <> tmtNone then
  begin
    ExistingAnimation := GetByName('CaptainA') as TgaiGI;
    ExistingAnimation.RestartPlayback;
    ModalTransition := tmtNone;
    MinimapEnabled := True;
    if ReturnedFromTrade then
    begin
      DialogText := TalkShip.LookupTalkText('Talk.Trade.AfterTrade');
      BuildStandardChoices(True);
      RestartTextPresentation;
    end;
    ReturnedFromTrade := False;
  end
  else
  begin
    MapDragging := False;
    if GetPlayer.InNormalSpace then
    begin
      SpaceProcess.BindMinimap(GetByName('MapPanel'));
      GetByName('MapPanel').SetActive(True);
      SpaceProcess.Space.ScrollChangedCallback := MinimapScrolled;
    end
    else
    begin
      MapControl := GetByName('MapPanel');
      MapControl.LeftButtonDownCallback := nil;
      MapControl.RightButtonDownCallback := nil;
      MapControl.MouseEnterCallback := nil;
      MapControl.MouseMoveCallback := nil;
      MapControl.SetActive(False);
    end;
    CurrentMapCenter := nil;
    if not MusicInSpaceEnabled then MusicManager.RequestFadeOut;
    (GetByName('TalkText') as TLabelGI).SetText('');
    if TalkShip <> nil then
      (GetByName('TalkShip') as TLabelGI).SetText(FormatText1(LocalizedText('Talk.ShipSay'), '', '<Name>', TalkShip.GetFullName(#13#10)))
    else if TalkPlanet <> nil then
      (GetByName('TalkShip') as TLabelGI).SetText(FormatText1(LocalizedText('Talk.PlanetSay'), '', '<Name>', TalkPlanet.GetFullName(#13#10)))
    else (GetByName('TalkShip') as TLabelGI).SetText('');
    if (TalkShip <> nil) and (TalkShip.TypeId = stRanger) then
      (GetByName('TalkShipChar') as TLabelGI).SetText((TalkShip as TRanger).GetCharacterName)
    else if (TalkShip <> nil) and (TalkShip is TRuins) then
      (GetByName('TalkShipChar') as TLabelGI).SetText(LocalizedText('ShipType.TypeName.Ruins'))
    else if TalkShip <> nil then
      (GetByName('TalkShipChar') as TLabelGI).SetText(TalkShip.GetLocalizedTypeName)
    else if TalkPlanet <> nil then
      (GetByName('TalkShipChar') as TLabelGI).SetText(PlanetEconomyInfo[TalkPlanet.Economy].DisplayName)
    else (GetByName('TalkShipChar') as TLabelGI).SetText('');
    Portrait := GetByName('CaptainI') as TImageGI;
    if TalkShip <> nil then Portrait.SetImagePath('GI,' + TalkShip.GetCaptainPortraitResourceBase + 'i')
    else if TalkPlanet <> nil then Portrait.SetImagePath('GI,' + TalkPlanet.GetGovernmentPortraitGraph + 'i')
    else RaiseWideMessage('talk portrait');
    Portrait.SetImageKindX(ikxCenter);
    Portrait.SetImageKindY(ikyCenter);
    Portrait.SetActive(True);
    Animation := GetByName('CaptainA') as TgaiGI;
    Animation.FirstFrameOnly := not AnimCaptain;
    if TalkShip <> nil then Animation.SetImagePath(TalkShip.GetCaptainPortraitResourceBase + 'a')
    else if TalkPlanet <> nil then Animation.SetImagePath(TalkPlanet.GetGovernmentPortraitGraph + 'a')
    else RaiseWideMessage('talk portrait');
    Animation.SequenceIndex := 0;
    Animation.UpdateAutoGeometry;
    Animation.SetImageKindX(ikxCenter);
    Animation.SetImageKindY(ikyCenter);
    Animation.SetActive(True);
    Animation.RestartPlayback;
    TextLabel := GetByName('TalkText') as TLabelGI;
    if FontDialog = 0 then TextLabel.SetFontName(NormalFontName)
    else if FontDialog = 1 then TextLabel.SetFontName(SmoothBigFontName)
    else if FontDialog = 2 then TextLabel.SetFontName(SmoothHugeFontName)
    else if FontDialog >= 3 then TextLabel.SetFontName(SmoothIntroFontName);
    CodeMsgOut(False);
    RestartTextPresentation;
    Choices := GetByName('TalkPA') as TPanelScrollBarGI;
    Choices.SetVerticalScrollbarEnabled(False);
    SlideProgress := 0;
    SlideTimer := ScheduleCallbackTimer(30, 30, AdvanceSlide);
    UpdateSlidePosition;
    MinimapEnabled := True;
    ModalTransition := tmtNone;
    ReturnedFromTrade := False;
  end;
end;
{ @end $6D14AC }

{ @routine $6D222C TfTalk_OnClose }
procedure TfTalk.OnClose;
var
  I, Count: Integer;
  Ship: TShip;
  Star: TStar;
begin
  if AuxRenderBuffer <> nil then AuxRenderBuffer.Clear;
  MinimapEnabled := False;
  ClearDialogEffects;
  if MapSelectionTimer <> nil then
  begin
    CancelCallbackTimer(MapSelectionTimer);
    MapSelectionTimer := nil;
  end;
  if TextPresentationTimer <> nil then
  begin
    CancelCallbackTimer(TextPresentationTimer);
    TextPresentationTimer := nil;
  end;
  if MinimapRefreshTimer <> nil then
  begin
    CancelCallbackTimer(MinimapRefreshTimer);
    MinimapRefreshTimer := nil;
  end;
  if SlideTimer <> nil then
  begin
    CancelCallbackTimer(SlideTimer);
    SlideTimer := nil;
  end;
  if ModalTransition = tmtNone then
  begin
    RequestedMapCenter := nil;
    ClearChoices(False);
    Count := GetPlayer.ProgramCounts[prgIntercom];
    if (TalkShip <> nil) and (TalkShip.TypeId = stKling) and (Count > 0) and GetPlayer.CanResolveObjectWithScanner(TalkShip) then
    begin
      Dec(Count);
      GetPlayer.ProgramCounts[prgIntercom] := Count;
      SysUtils.Sleep(1);
      if (GetPlayer.ProgramCounts[prgIntercom] <> Count) and not GR_Main.CCInterface.GetTamperDetected then
        GR_Main.CCInterface.SetTamperDetected(True);
    end;
    if (GetPlayer <> nil) and (TalkShip <> nil) and not TalkScripted then GetPlayer.ScriptItemsAct(satOnPlayerTalkedWithShip, TalkShip, nil, 0);
    TalkShip := nil;
    TalkPlanet := nil;
    if not TalkScripted and not SkipShipScriptAdvance then
    begin
      I := 0;
      Star := GetPlayer.CurrentStar;
      while I < Star.Ships.Count do
      begin
        Ship := Star.Ships[I];
        if Ship = KellerShip then Inc(I)
        else if Ship = BlazerShip then Inc(I)
        else
        begin
          if Ship.ScriptShip <> nil then Ship.ScriptNextDay;
          Inc(I);
        end;
      end;
    end;
    TalkDialogActive := False;
  end;
end;
{ @end $6D222C }

{ @routine $6D247C TfTalk_RememberChoiceScroll }
procedure TfTalk.RememberChoiceScroll;
begin
  SavedChoiceScroll := (GetByName('TalkPA') as TPanelScrollBarGI).VerticalScrollBar.Position;
end;
{ @end $6D247C }

{ @routine $6D24C8 TfTalk_EnableCloseButton }
procedure TfTalk.EnableCloseButton;
var
  Button: TGraphButtonGI;
begin
  Button := GetByName('Close') as TGraphButtonGI;
  Button.SetDisabled(False);
end;
{ @end $6D24C8 }

{ @routine $6D250C TfTalk_CloseClicked }
procedure TfTalk.CloseClicked(Sender: TObjectGI);
begin
  FastExit(0);
end;
{ @end $6D250C }

{ @routine $6D2528 TfTalk_ClearChoices }
procedure TfTalk.ClearChoices(AllowClose: Boolean);
var
  Child, Panel: TObjectGI;
begin
  (GetByName('Close') as TGraphButtonGI).SetDisabled(not AllowClose);
  ChoiceHeight := 0;
  Panel := GetByName('TalkPA');
  Child := Panel.FirstChild;
  while Child <> nil do
  begin
    TObject(Child.UserValue).Free;
    Child := Child.NextSibling;
  end;
  Panel.FreeOwnedChildren;
  Panel.Invalidate;
end;
{ @end $6D2528 }

{ @routine $6D25DC TfTalk_AddChoice }
procedure TfTalk.AddChoice(Text: WideString; Value: Integer; Callback: TDialogChoiceEventGI; ExtraValue: Integer);
var Panel: TPanelScrollBarGI; Choice: TfTalkA; I: Integer; ExitCallback: TMethod; Row: TPanelGI;
  Highlight: TImageGI; BlockMode: Byte;
begin
  BlockMode := 0;
  if ScriptDialogBlocks <> nil then
    for I := 0 to ScriptDialogBlocks.Count - 1 do
      if FindTextOffsetW(Text, PScriptDialogBlock(ScriptDialogBlocks[I]).Text) >= 0 then
        BlockMode := Max(BlockMode, PScriptDialogBlock(ScriptDialogBlocks[I]).Mode);
  if BlockMode >= 2 then Exit;
  ExitCallback.Data := Self;
  ExitCallback.Code := @TfTalk.FastExit;
  if TMethod(Callback).Code = ExitCallback.Code then EnableCloseButton;
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
  Choice.ExtraValue := ExtraValue;
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
  SetSize(Point(Panel.ClientSize.X - GiScalePixels(20), 20));
  SetPosition(Point(GiScalePixels(10), 0));
  SetWordWrapEnabled(True);
  SetTextAlignX(taxLeft);
  SetTextAlignY(tayAuto);
  if not Assigned(Callback) then Text := RemoveTextTagsW(Text);
  SetText('<Object=0,20,14,0>' + ReplaceAllWideString(Text, '<color=255,240,100>', '<color=0,50,200>'));
  SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  if not Assigned(Choice.Callback) then SetTextColor(CurrentPixelFormat.PackRgbBytes(127, 127, 127));
  CreateEmbeddedControl := CreateDialogObject;
  SetTextAlignY(tayCenterEx);
  Row.SetSize(Point(Row.ClientSize.X, ClientSize.Y + 2 * GiScalePixelsEx(2, 1)));
  SetSize(Point(ClientSize.X, Row.ClientSize.Y));
  Highlight.SetSize(Row.ClientSize);
  Inc(ChoiceHeight, ClientSize.Y);
  end;
end;
{ @end $6D25DC }

{ @routine $6D2BCC TfTalk_CreateDialogObject }
function TfTalk.CreateDialogObject(LabelControl: TLabelGI; Item: PFontObjectEC): TObjectGI;
var
  Image: TImageGI;
  Button: TGraphButtonGI;
begin
  if Item.ObjectId = 0 then
  begin
    Result := TImageGI.Create(LabelControl);
    Image := Result as TImageGI;
    Image.SetImagePath('GI,Bm.FormGov2.' + GiResourceSuffix + 'Answer');
    Image.SetImageKindX(ikxLeft);
  end
  else
  begin
    Result := TGraphButtonGI.Create(LabelControl);
    Button := Result as TGraphButtonGI;
    Button.UserValue := Item.ObjectId;
    Button.SetImageNormalPath('GI,Bm.FormTalk2.' + GiResourceSuffix + 'Center2N');
    Button.SetImageNormalActivePath('GI,Bm.FormTalk2.' + GiResourceSuffix + 'Center2A');
    Button.SetImageDownPath('GI,Bm.FormTalk2.' + GiResourceSuffix + 'Center2D');
    Button.EnterSound := 'Sound.ButtonEnter';
    Button.LeaveSound := 'Sound.ButtonLeave';
    Button.ClickSound := 'Sound.ButtonClick';
    Button.NormalOffset := Point(3, 0);
    Button.NormalActiveOffset := Point(3, 0);
    Button.DownOffset := Point(3, 0);
    Button.MouseBlocking := True;
    Button.SetSize(Button.GetMaxStateImageSize);
    Button.HitKind := gbhRect;
    Button.UpdateStateImagePlacement;
    Button.UpdateStateVisuals;
    Button.UpCallback := CenterEmbeddedObject;
  end;
end;
{ @end $6D2BCC }

{ @routine $6D2F60 TfTalk_CenterEmbeddedObject }
procedure TfTalk.CenterEmbeddedObject(Sender: TObjectGI);
begin
  if (TextPresentationTimer <> nil) or (SlideTimer <> nil) then Exit;
  RequestedMapCenter := TObject(Sender.UserValue);
  RequestedMapHover := nil;
  CurrentMapCenter := nil;
  ApplyMapSelection(nil, 0);
end;
{ @end $6D2F60 }

{ @routine $6D2FBC TfTalk_CenterShipClicked }
procedure TfTalk.CenterShipClicked(Sender: TObjectGI);
begin
  if (TextPresentationTimer <> nil) or (SlideTimer <> nil) then Exit;
  if GetByName('CenterPlayer') = Sender then RequestedMapCenter := GetPlayer
  else if TalkPlanet <> nil then RequestedMapCenter := TalkShip
  else RequestedMapCenter := TalkShip; // Both native branches use TalkShip, including planet conversations.
  RequestedMapHover := nil;
  CurrentMapCenter := nil;
  ApplyMapSelection(nil, 0);
end;
{ @end $6D2FBC }

{ @routine $6D3074 TfTalk_MainPanelMouseMove }
procedure TfTalk.MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Child: TObjectGI;
begin
  if not GetPlayer.InHyperspace and (TextPresentationTimer = nil) and (SlideTimer = nil) then
  begin
    if MapDragging then
    begin
      RequestedMapCenter := nil;
      CurrentMapCenter := nil;
      RequestedMapHover := nil;
      CurrentMapHover := nil;
      StarMapScreen.ShowObjectInfo(nil);
      StarMapScreen.ShowFilmObjectInfo(nil, 0);
      StarMapScreen.SetMapCenter(Classes.Point(StarMapScreen.GetMapCenter.X + MapDragPoint.X - Point.X,
        StarMapScreen.GetMapCenter.Y + MapDragPoint.Y - Point.Y));
      MapDragPoint := Point;
    end
    else if (GetByName('ImageBG') as TImageGI).HitTestPixel(Point) or
      (GetByName('ImageBGB') as TImageGI).HitTestPixel(Point) or
      (GetByName('CaptainI') as TImageGI).ContainsPoint(Point) then
    begin
      RequestedMapHover := nil;
      if MapSelectionTimer = nil then MapSelectionTimer := ScheduleCallbackTimer(100, 100, ApplyMapSelection);
    end
    else
    begin
      Child := MainPanel.FirstChild;
      while Child <> nil do
      begin
        if Child.UserValue = 102 then Exit;
        Child := Child.NextSibling;
      end;
      StarMapScreen.CursorControl.SetPosition(GetCursorPoint);
      RequestedMapCenter := nil;
      if TalkScripted then RequestedMapHover := StarMapScreen.FindFilmObjectAtCursor(CurrentFilmObjectId)
      else RequestedMapHover := StarMapScreen.FindObjectAtCursor;
      if MapSelectionTimer = nil then MapSelectionTimer := ScheduleCallbackTimer(100, 100, ApplyMapSelection);
    end;
  end;
end;
{ @end $6D3074 }

{ @routine $6D3354 TfTalk_MainPanelMouseDown }
procedure TfTalk.MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if not GetPlayer.InHyperspace and (TextPresentationTimer = nil) and (SlideTimer = nil) then
    if not (GetByName('ImageBG') as TImageGI).HitTestPixel(Point) and
      not (GetByName('ImageBGB') as TImageGI).HitTestPixel(Point) and
      not (GetByName('CaptainI') as TImageGI).ContainsPoint(Point) then
    begin
      MapDragging := True;
      MapDragPoint := Point;
      if not IsCursorImageSelected('Scroll') then SetCursorByName('Scroll');
    end;
end;
{ @end $6D3354 }

{ @routine $6D34AC TfTalk_MainPanelMouseUp }
procedure TfTalk.MainPanelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if not GetPlayer.InHyperspace then
  begin
    MapDragging := False;
    if not IsCursorImageSelected('Main') then SetCursorByName('Main');
    PostMouseMoveMessage;
  end;
end;
{ @end $6D34AC }

{ @routine $6D3518 TfTalk_ProcessMouseWheel }
procedure TfTalk.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
var
  Panel: TPanelScrollBarGI;
begin
  Panel := GetByName('TextScroll') as TPanelScrollBarGI;
  if not Panel.ContainsPoint(Point) then Panel := GetByName('TalkPA') as TPanelScrollBarGI;
  if Delta = WHEEL_DELTA then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.SmallChange)
  else if Delta = -WHEEL_DELTA then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.SmallChange);
end;
{ @end $6D3518 }

{ @routine $6D3610 TfTalk_ChoiceMouseEnter }
procedure TfTalk.ChoiceMouseEnter(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(True);
end;
{ @end $6D3610 }

{ @routine $6D3630 TfTalk_ChoiceMouseLeave }
procedure TfTalk.ChoiceMouseLeave(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(False);
end;
{ @end $6D3630 }

{ @routine $6D3650 TfTalk_ChoiceMouseDown }
procedure TfTalk.ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
     (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(2, 0));
  ChoiceMousePressed := True;
end;
{ @end $6D3650 }

{ @routine $6D36D8 TfTalk_ChoiceMouseUp }
procedure TfTalk.ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Choice: TfTalkA;
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
    (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(0, 0));
  if Sender.IsOccludedAtPoint(Point) or not ChoiceMousePressed then Exit;
  ChoiceMousePressed := False;
  Choice := TfTalkA(Sender.UserValue);
  if Assigned(Choice.Callback) then Choice.Callback(Choice.Value)
  else if Assigned(Choice.FallbackCallback) then Choice.FallbackCallback(Choice.FallbackText)
  else Exit;
  RestartTextPresentation;
  BreakUiMessage;
end;
{ @end $6D36D8 }

{ @routine $6D37C8 TfTalk_RestartTextPresentation }
procedure TfTalk.RestartTextPresentation;
begin
  (GetByName('TalkPA') as TPanelScrollBarGI).SetActive(False);
  PresentedTextLength := 0;
  if TextPresentationTimer <> nil then
  begin
    CancelCallbackTimer(TextPresentationTimer);
    TextPresentationTimer := nil;
  end;
  TextPresentationTimer := ScheduleCallbackTimer(10, 10, AdvanceTextPresentation);
end;
{ @end $6D37C8 }

{ @routine $6D3860 TfTalk_AdvanceTextPresentation }
procedure TfTalk.AdvanceTextPresentation(Timer: PCallbackTimerGI; UserData: Integer);
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
    Choices.SetVerticalScrollbarEnabled(ChoiceHeight > Choices.ClientSize.Y);
    Choices.VerticalScrollBar.SetDepth(4);
    Choices.SetDragScrollingEnabled(Choices.IsVerticalScrollbarEnabled);
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
{ @end $6D3860 }

{ @routine $6D3C08 TfTalk_AddDialogEffect }
procedure TfTalk.AddDialogEffect(Position: TPointF; ImagePath: WideString; DelayMs: Integer);
var
  Animation: TgaiGI;
begin
  Animation := TgaiGI.Create(MainPanel);
  Animation.SetDepth(7);
  Animation.SetPosition(TruncatePointF(Position));
  Animation.SetPositionModeW(True);
  Animation.SetImagePath(ImagePath);
  Animation.SetSize(Animation.GetContentSize);
  Animation.SetOrigin(HalfPoint(Animation.ClientSize));
  Animation.UserValue := 102;
  Animation.SequenceIndex := 0;
  Animation.UpdateAutoGeometry;
  if DelayMs >= 0 then Animation.SetFrameDelay(0, DelayMs);
  Animation.CycleCompleteCallback := DialogEffectComplete;
  Animation.RestartPlayback;
end;
{ @end $6D3C08 }

{ @routine $6D3D30 TfTalk_ClearDialogEffects }
procedure TfTalk.ClearDialogEffects;
var
  Child, Next: TObjectGI;
begin
  Child := MainPanel.FirstChild;
  while Child <> nil do
  begin
    Next := Child;
    Child := Child.NextSibling;
    if Next.UserValue = 102 then
    begin
      Next.SetActive(False);
      Next.Free;
    end;
  end;
end;
{ @end $6D3D30 }

{ @routine $6D3D88 TfTalk_DialogEffectComplete }
procedure TfTalk.DialogEffectComplete(Sender: TObjectGI);
begin
  Sender.SetActive(False);
  Sender.Free;
  PostMouseMoveMessage;
end;
{ @end $6D3D88 }

{ @routine $6D3DB0 TfTalk_ProcessCallbackTimers }
procedure TfTalk.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $6D3DB0 }

{ @routine $6D3DF0 TfTalk_ApplyMapSelection }
procedure TfTalk.ApplyMapSelection(Timer: PCallbackTimerGI; UserData: Integer);
var
  Previous: TObject;
begin
  if RequestedMapCenter <> nil then
  begin
    Previous := CurrentMapCenter;
    CurrentMapCenter := RequestedMapCenter;
    if CurrentMapCenter = nil then CurrentMapCenter := TalkShip;
    if CurrentMapCenter = nil then CurrentMapCenter := TalkPlanet;
    if (CurrentMapCenter <> nil) and (CurrentMapCenter is TShip) then
      StarMapScreen.CenterMapForTalk((CurrentMapCenter as TShip).Position)
    else if (CurrentMapCenter <> nil) and (CurrentMapCenter is TPlanet) then
      StarMapScreen.CenterMapForTalk((CurrentMapCenter as TPlanet).GetPosition)
    else if (CurrentMapCenter <> nil) and (CurrentMapCenter is TItem) then
      StarMapScreen.CenterMapForTalk((CurrentMapCenter as TItem).Position);
    StarMapScreen.ShowObjectInfo(nil);
    StarMapScreen.ShowFilmObjectInfo(nil, 0);
    if MapSelectionTimer <> nil then
    begin
      CancelCallbackTimer(MapSelectionTimer);
      MapSelectionTimer := nil;
    end;
    if Previous <> CurrentMapCenter then
    begin
      ModalTransition := tmtReopen;
      RequestedScreenId := TalkReturnScreenId;
      if TalkScripted then StarMapScreen.ResumeMode := smrWaitForTurn;
      RequestClose(1);
    end;
  end
  else
  begin
    Previous := CurrentMapHover;
    CurrentMapHover := RequestedMapHover;
    if CurrentMapHover is TObjectSE then
    begin
      StarMapScreen.ShowObjectInfo(nil);
      StarMapScreen.ShowFilmObjectInfo(CurrentMapHover as TObjectSE, CurrentFilmObjectId);
    end
    else
    begin
      StarMapScreen.ShowFilmObjectInfo(nil, 0);
      StarMapScreen.ShowObjectInfo(CurrentMapHover);
    end;
    if MapSelectionTimer <> nil then
    begin
      CancelCallbackTimer(MapSelectionTimer);
      MapSelectionTimer := nil;
    end;
    if Previous <> CurrentMapHover then
    begin
      ModalTransition := tmtReopen;
      RequestedScreenId := TalkReturnScreenId;
      if TalkScripted then StarMapScreen.ResumeMode := smrWaitForTurn;
      RequestClose(1);
    end;
  end;
end;
{ @end $6D3DF0 }

{ @routine $6D40F8 TfTalk_AddMessageClicked }
procedure TfTalk.AddMessageClicked(Sender: TObjectGI);
var
  Text: WideString;
begin
  Text := (GetByName('TalkText') as TLabelGI).GetText;
  Text := ReplaceAllWideString(Text, '<color=0,50,200>', '<color=255,240,100>');
  Text := RemoveMatchingTextTagsW(Text, 'object', 'OBJECT');
  (GetByName('UserMsgAdd') as TGraphButtonGI).SetDisabled(True);
  SoundManager.PlaySound('Sound.UserMsgAdd');
  AddOrUpdatePlayerBubble(pmUserNote, Galaxy.CurrentTurn, Text, '');
  if not GetPlayer.InHyperspace then ReturnToMap(0);
end;
{ @end $6D40F8 }

{ @routine $6D42DC TfTalk_MinimapScrolled }
procedure TfTalk.MinimapScrolled;
begin
  if MinimapEnabled and (ModalTransition = tmtNone) and GetPlayer.InNormalSpace then
  begin
    SpaceProcess.Space.DrawMinimap;
    GetByName('MapPanel').Invalidate;
    if MinimapRefreshTimer = nil then MinimapRefreshTimer := ScheduleCallbackTimer(1, 1, FlushMinimapRefresh);
  end;
end;
{ @end $6D42DC }

{ @routine $6D437C TfTalk_FlushMinimapRefresh }
procedure TfTalk.FlushMinimapRefresh(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if (TextPresentationTimer = nil) and (SlideTimer = nil) then
  begin
    if MinimapRefreshTimer <> nil then
    begin
      CancelCallbackTimer(MinimapRefreshTimer);
      MinimapRefreshTimer := nil;
    end;
    ModalTransition := tmtReopen;
    RequestedScreenId := TalkReturnScreenId;
    if TalkScripted then StarMapScreen.ResumeMode := smrWaitForTurn;
    RequestClose(1);
  end;
end;
{ @end $6D437C }

{ @routine $6D4410 TfTalk_AdvanceSlide }
procedure TfTalk.AdvanceSlide(Timer: PCallbackTimerGI; UserData: Integer);
begin
  SlideProgress := SlideProgress + 0.05;
  if SlideProgress >= 1 then
  begin
    SlideProgress := 1;
    if SlideTimer <> nil then
    begin
      CancelCallbackTimer(SlideTimer);
      SlideTimer := nil;
    end;
  end;
  UpdateSlidePosition;
end;
{ @end $6D4410 }

{ @routine $6D44A0 TfTalk_UpdateSlidePosition }
procedure TfTalk.UpdateSlidePosition;
var
  T: Single;
  I, J: Integer;
begin
  if SlideProgress < 0 then SlideProgress := 0
  else if SlideProgress > 1 then SlideProgress := 1;
  I := Trunc(15 * SlideProgress);
  J := I + 1;
  if J > 15 then J := 15;
  T := 1 / 15;
  T := (SlideProgress - I * T) / T;
  T := (TalkSlideCurve[J] - TalkSlideCurve[I]) * T + TalkSlideCurve[I];
  DialogPanel.SetPosition(Point(DialogPanelLeft + DialogPanel.ClientSize.X - Round(DialogPanel.ClientSize.X * T),
    DialogPanel.LocalPosition.Y));
end;
{ @end $6D44A0 }

{ @routine $6D45BC TfTalk_MainPanelKeyDown }
procedure TfTalk.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
var
  Panel: TPanelScrollBarGI;
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_MENU) then
  begin
    Panel := GetByName('TalkPA') as TPanelScrollBarGI;
    if Key = Ord('C') then CenterShipClicked(GetByName('CenterPlayer'))
    else if (Key = VK_ESCAPE) and not (GetByName('Close') as TGraphButtonGI).Disabled then CloseClicked(nil)
    else if Key = VK_UP then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.SmallChange)
    else if Key = VK_DOWN then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.SmallChange)
    else if Key = VK_PRIOR then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.LargeChange)
    else if Key = VK_NEXT then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.LargeChange);
  end;
end;
{ @end $6D45BC }

{ @routine $6D477C TfTalk_SelectMusic }
procedure TfTalk.SelectMusic;
begin
  if not MusicInSpaceEnabled then
  begin
    MusicManager.RequestFadeOut;
    Exit;
  end;
  begin
    if (GetPlayer <> nil) and (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0, 100) < 20) then
    begin
      StarMapScreen.BattleMusicSelected := True;
      MusicManager.PlayCategory('Destroyer');
    end
    else
    begin
      StarMapScreen.BattleMusicSelected := False;
      MusicManager.PlayCategory('StarMap');
    end;
  end;
end;
{ @end $6D477C }

{ @routine $6D4838 RunTalk }
function RunTalk(ParentLoop: TMessageLoopGI): Boolean;
var
  OtherShip: TShip;
  State: TCursorStateGI;
begin
  ParentLoop.RootUiObject.OnModalSuspend;
  ParentLoop.CaptureCursorState(@State);
  ParentLoop.SetCursorActive(False);
  ParentLoop.DrawQueuedUpdateRects;
  TalkScreen.ParentLoop := ParentLoop;
  ParentLoop.ChildLoop := TalkScreen;
  OtherShip := TalkShip;
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct($18, OtherShip, nil, 0);
  if OtherShip <> nil then OtherShip.ScriptItemsAct($18, nil, nil, 0);
  if TalkScreen.Run = 1 then
  begin
    Result := True;
    if GetPlayer <> nil then GetPlayer.ScriptItemsAct($19, OtherShip, nil, 0);
    if OtherShip <> nil then OtherShip.ScriptItemsAct($19, nil, nil, 0);
  end
  else Result := False;
  TalkScreen.ParentLoop := nil;
  ParentLoop.ChildLoop := nil;
  ParentLoop.InvalidateViewport;
  ParentLoop.RestoreCursorState(@State);
  ParentLoop.UpdateCursorPosition;
  ParentLoop.RootUiObject.OnModalResume;
end;
{ @end $6D4838 }

{ @routine $6D498C TfTalk_BuildStandardChoices }
procedure TfTalk.BuildStandardChoices(KeepGreeting: Boolean);
var
  Binding: TScriptShip;
  Script: TScript;
  Text, Mode: WideString;
  I, J, Selected, Priority, PartCount: Integer;
  Swapped: Pointer;
  ReplacedGreeting: Boolean;
begin
  ClearScriptDialogRules;
  ClearChoices(False);
  if (CurrentScript <> nil) and (ScriptDialogIndex >= 0) then
  begin
    SkipShipScriptAdvance := True;
    CurrentScript.PublishCurrentShip(TalkShip);
    CurrentScript.CallDialogMessage(ScriptDialogIndex);
    Exit;
  end;
  if SkipShipScriptAdvance and (TalkShip.ScriptShip <> nil) then
  begin
    Binding := TScriptShip(TalkShip.ScriptShip);
    Binding.Script.PublishShipContext(Binding);
    Binding.Script.CallDialog(Binding.Script.CurrentDialog);
    if ScriptDialogIndex >= 0 then
    begin
      Binding.Script.CallDialogMessage(ScriptDialogIndex);
      Exit;
    end;
  end;
  for I := 0 to Galaxy.Scripts.Count - 1 do
  begin
    Script := Galaxy.Scripts[I];
    Script.RunDialogCode;
  end;
  if ScriptDialogOverrides.Count > 0 then
  begin
    Selected := 0;
    Priority := PScriptDialogOverride(ScriptDialogOverrides[0]).Priority;
    for I := 0 to ScriptDialogOverrides.Count - 1 do
      if PScriptDialogOverride(ScriptDialogOverrides[I]).Priority > Priority then
      begin
        Selected := I;
        Priority := PScriptDialogOverride(ScriptDialogOverrides[I]).Priority;
      end;
    Script := PScriptDialogOverride(ScriptDialogOverrides[Selected]).Script;
    Script.InitCode.LocalVar.GetVar('GAnswerData').SetDword(PScriptDialogOverride(ScriptDialogOverrides[Selected]).AnswerData);
    Text := PScriptDialogOverride(ScriptDialogOverrides[Selected]).DialogName;
    if Text <> '' then
    begin
      Script.PublishCurrentShip(TalkShip);
      Script.CallDialogByVariable(Text);
      if ScriptDialogIndex < 0 then
        AppendLogLineThreadSafe(AnsiString(Script.ScriptFileName + ' has overriden dialog with ' + Text + ' but it failed to start'));
    end;
    if ScriptDialogIndex < 0 then BuildBuiltinChoices
    else
    begin
      SkipShipScriptAdvance := True;
      StartScriptMessage(Script);
    end;
  end
  else
  begin
    Selected := -1;
    Priority := 0;
    for I := 0 to ScriptDialogInjections.Count - 1 do
      if PScriptDialogInjection(ScriptDialogInjections[I]).ReplaceGreeting then
        if (Selected < 0) or (PScriptDialogInjection(ScriptDialogInjections[I]).Priority > Priority) then
        begin
          Priority := PScriptDialogInjection(ScriptDialogInjections[I]).Priority;
          Selected := I;
        end;
    if Selected >= 0 then
    begin
      ReplacedGreeting := True;
      DialogText := PScriptDialogInjection(ScriptDialogInjections[Selected]).Text;
    end
    else ReplacedGreeting := False;
    for I := 1 to ScriptDialogInjections.Count - 1 do
      for J := ScriptDialogInjections.Count - 1 downto I do
        if PScriptDialogInjection(ScriptDialogInjections[J]).Priority > PScriptDialogInjection(ScriptDialogInjections[J - 1]).Priority then
        begin
          Swapped := ScriptDialogInjections[J];
          ScriptDialogInjections[J] := ScriptDialogInjections[J - 1];
          ScriptDialogInjections[J - 1] := Swapped;
        end;
    for I := 0 to ScriptDialogInjections.Count - 1 do
    begin
      if not PScriptDialogInjection(ScriptDialogInjections[I]).ReplaceGreeting then
      begin
        Text := PScriptDialogInjection(ScriptDialogInjections[I]).Text;
        if Text <> '' then
          if not KeepGreeting or ReplacedGreeting then DialogText := DialogText + #13#10 + Text;
      end;
      Text := PScriptDialogInjection(ScriptDialogInjections[I]).Answer;
      if Text <> '' then
      begin
        Mode := '';
        PartCount := CountDelimitedPartsW(Text, '~');
        if PartCount > 1 then
        begin
          Mode := ExtractDelimitedPartW(Text, 0, '~');
          Text := ExtractDelimitedRangeW(Text, 1, PartCount - 1, '~');
        end;
        if Mode = 'block' then AddChoice(Text, 0, ScriptDialogBlockCallback, 0)
        else if Mode = 'snap' then AddChoice(Text, Integer(ScriptDialogInjections[I]), RunInjectedAnswerKeepingScroll, 0)
        else AddChoice(PScriptDialogInjection(ScriptDialogInjections[I]).Answer, Integer(ScriptDialogInjections[I]), RunInjectedAnswer, 0);
      end;
    end;
    BuildBuiltinChoices;
  end;
end;
{ @end $6D498C }

{ @routine $6D5048 TfTalk_BuildBuiltinChoices }
procedure TfTalk.BuildBuiltinChoices;
var HasAttackChoice, RecognizesPlayer: Boolean; TargetName: WideString;
  Callback: TDialogChoiceEventGI; ProgramIndex: Byte; I: Integer;
begin
  RecognizesPlayer := not TalkShip.IsPlayerChameleonEffectiveAgainstSelf;
  if TalkScripted then
  begin
    case TalkType of
      tkMoneyDemand:
        begin
          if GetPlayer.Money >= TalkAmount then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Money.PlayerOk'), 0, AcceptScriptedConversation, 0)
          else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Money.PlayerNotMoney'), 0, FastExit, 0);
          if GetPlayer.CanEscapePursuer(TalkShip) then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Money.PlayerLongDistance'), 0, FastExit, 0)
          else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Money.PlayerNo'), 0, FastExit, 0);
        end;
      tkGoodsDemand:
        begin
          if GetPlayer.HasCargoGoods then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Goods.PlayerOk'), 0, AcceptScriptedConversation, 0)
          else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Goods.PlayerNotGoods'), 0, FastExit, 0);
          if GetPlayer.CanEscapePursuer(TalkShip) then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Goods.PlayerLongDistance'), 0, FastExit, 0)
          else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Goods.PlayerNo'), 0, FastExit, 0);
        end;
      tkTruceOffer:
        begin
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Truce.PlayerOk'), 0, AcceptScriptedConversation, 0);
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Truce.PlayerNo'), 0, FastExit, 0);
        end;
      tkAttack:
        begin
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerOk'), 0, AcceptScriptedConversation, 0);
          if (TalkShip.EnemyShip <> nil) and ((TalkShip.EnemyShip.RelationToShip(GetPlayer) >= RelationExcellentMin) or
            ((TalkShip.EnemyShip.RelationToShip(GetPlayer) >= RelationGoodMin) and (GetPlayer.GetDominantCareer <> rcPirate))) then
          begin
            if not (TalkShip.EnemyShip is TTranclucator) then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerWeFriends'), 0, FastExit, 0)
            else if GetPlayer = TTranclucator(TalkShip.EnemyShip).OwnerShip then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerItsMyTranc'), 0, FastExit, 0)
            else if TTranclucator(TalkShip.EnemyShip).OwnerShip = TalkShip then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerItsYourTranc'), 0, FastExit, 0)
            else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerWeFriendsTranc'), 0, FastExit, 0);
          end
          else if (TalkShip.EnemyShip <> nil) and GetPlayer.AcceptsRansomDemandFrom(TalkShip.EnemyShip) then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerFear'), 0, FastExit, 0)
          else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerHaveBusiness'), 0, FastExit, 0);
        end;
      tkPartnerBreak:
        begin
          if TalkShip.TypeId = stPirate then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.AnswerLiderBreak'), 0, FastExit, 0)
          else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.AnswerLiderBreak'), 0, FastExit, 0);
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
        end;
      tkPartnerEnd:
        begin
          if TalkShip.TypeId = stPirate then
          begin
            if GetPlayer.GetEffectiveSkillLevel(psLeadership) > GetPlayer.CountWingmen then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.AnswerLiderTheEnd'), 0, FastExit, 0)
            else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.AnswerLiderTheEndLowLeadership'), 0, FastExit, 0);
          end
          else
          begin
            if GetPlayer.GetEffectiveSkillLevel(psLeadership) > GetPlayer.CountWingmen then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.AnswerLiderTheEnd'), 0, FastExit, 0)
            else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.AnswerLiderTheEndLowLeadership'), 0, FastExit, 0);
          end;
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
        end;
      tkPartnerRiot:
        begin
          if TalkShip.TypeId = stPirate then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.AnswerLiderRiot'), 0, FastExit, 0)
          else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.AnswerLiderRiot'), 0, FastExit, 0);
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
        end
    else
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
    end;
  end
  else
  begin
    TruceOfferAmount := Min(GetPlayer.Money, GetPlayer.GetWealthScaledAmount(3));
    ExtortionDemandAmount := (TalkShip.GetWealthScaledAmount(3) + GetPlayer.GetWealthScaledAmount(3)) div 2;
    PartnerOfferAmount := Min(GetPlayer.Money, TalkShip.Wealth div 8);
    PartnerGiftAmount := Min(GetPlayer.Money, TalkShip.Wealth div 32);
    if ((GetPlayer <> TalkShip.PartnerShip) or not (TalkShip.TypeId in [stPirate])) and
      ((TalkShip.TypeId in [stRanger..stWarrior]) and RecognizesPlayer) then
    begin
      if (TalkShip.GetRelationLevelToShip(GetPlayer) = rlHostile) and (GetPlayer <> TalkShip.PartnerShip) then
      begin
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Truce.PlayerSend'), 0, ShowTruceOffer, 0);
        if GetPlayer.IsHealthEffectActive(5) then Callback := ScriptDialogBlockCallback
        else Callback := ShowMoneyDemand;
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Money.PlayerSend'), 0, Callback, 0);
        if GetPlayer.IsHealthEffectActive(5) then Callback := ScriptDialogBlockCallback
        else Callback := DemandCargo;
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Goods.PlayerSend'), 0, Callback, 0);
      end
      else
      begin
        HasAttackChoice := AddImmediateAttackChoices;
        if (not HasAttackChoice) and (GetPlayer <> TalkShip.PartnerShip) then
        begin
        if GetPlayer.IsHealthEffectActive(5) then Callback := ScriptDialogBlockCallback
        else Callback := ShowMoneyDemand;
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Money.PlayerSend'), 0, Callback, 0);
        if GetPlayer.IsHealthEffectActive(5) then Callback := ScriptDialogBlockCallback
        else Callback := DemandCargo;
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Goods.PlayerSend'), 0, Callback, 0);
        end;
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerOffersAttack'), 0, ShowAttackTargets, 0);
      end;
      if (GetPlayer <> TalkShip.PartnerShip) and (TalkShip.OrderTarget is TShip) and
        not (TalkShip.OrderTarget is TRuins) and (GetPlayer <> TalkShip.OrderTarget) and
        ((TalkShip.OrderTarget as TShip).GetRelationLevelToShip(GetPlayer) > rlHostile) and
        ((TalkShip.OrderTarget as TShip).OrderTarget <> TalkShip) and
        (TalkShip.GetRelationLevelToShip(TalkShip.OrderTarget as TShip) = rlHostile) then
        AddChoice(FormatText1('- ' + GetPlayer.LookupTalkText('Talk.Protect.PlayerSend'), '', '<Target>', (TalkShip.OrderTarget as TShip).GetFullName(' ') + GetLocalObjectLink(TalkShip.OrderTarget as TShip, False)), 0, RequestProtection, 0);
      if GetPlayer.PickupTargets <> nil then
        for I := 1 to TalkShip.WeaponCount do
          if (TalkShip.Weapons[I].Target <> nil) and
            (GetPlayer.PickupTargets.IndexOf(TalkShip.Weapons[I].Target) >= 0) then
          begin
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.PreserveItems.PlayerSend'), 0, RequestPreserveItems, 0);
            Break;
          end;
    end;
    case TalkShip.TypeId of
      stRanger:
        begin
          if GetPlayer <> TalkShip.PartnerShip then
          begin
            if RecognizesPlayer and (GetPlayer.Money > 0) and (GetPlayer.CountWingmen < 6) then
              AddChoice(FormatText1('- ' + GetPlayer.LookupTalkText('Talk.Partner.PlayerSend'), '', '<Ranger>', TalkShip.GetName), 0, ShowPartnerOffer, 0);
          end
          else
          begin
          if GetPlayer <> TalkShip.OrderTarget then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.FlyToMe'), 0, OrderPartnerFollow, 0);
          case GetPlayer.Order of
            soLand:
              if GetPlayer.OrderTarget <> TalkShip.OrderTarget then
              begin
                if GetPlayer.OrderTarget is TPlanet then TargetName := (GetPlayer.OrderTarget as TPlanet).Name
                else if GetPlayer.OrderTarget is TRuins then TargetName := (GetPlayer.OrderTarget as TRuins).GetColoredFullName('')
                else TargetName := '';
                if Length(TargetName) > 0 then
                  AddChoice(FormatText1('- ' + GetPlayer.LookupTalkText('Talk.Partner.LandingToObject'), '<color=255,240,100>', '<ObjectName>', TargetName), 0, OrderPartnerLand, 0);
              end;
            soJump:
              if GetPlayer.OrderTarget <> TalkShip.OrderTarget then
                AddChoice(FormatText1('- ' + GetPlayer.LookupTalkText('Talk.Partner.FlyToStar'), '<color=255,240,100>', '<Star>', (GetPlayer.OrderTarget as TStar).Name), 0, OrderPartnerJump, 0);
          end;
          if TalkShip.HasLooseNonScriptItemsOrGoods or not GetPlayer.CanResolveObjectWithScanner(TalkShip) then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.PlayerSendDropCargo'), 0, OrderPartnerDropCargo, 0);
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.FinancesCheck'), 0, ShowPartnerFinances, 0);
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.PlayerDismissSend'), 0, ShowPartnerDismissal, 0);
          end;
          if RecognizesPlayer and (GetPlayer <> TalkShip.PartnerShip) then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Trade.PlayerSend'), 0, ShowTrade, 0);
          if RecognizesPlayer and TalkShip.UsesVeteranHumanRangerAppearance and
            (TalkShip.GetRelationLevelToShip(GetPlayer) >= rlGood) then
          begin
            if GetPlayer = TalkShip.PartnerShip then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSendP'), 0, DiscussOldHull, 0)
            else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend'), 0, DiscussOldHull, 0);
          end;
        end;
      stTransport:
        if RecognizesPlayer then
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Trade.PlayerSend'), 0, ShowTrade, 0);
      stPirate:
        begin
          if GetPlayer <> TalkShip.PartnerShip then
          begin
            if (TalkShip.OwnerId <> oiPirate) or (TPirate(TalkShip).PirateType = 0) then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.PlayerSend'), 0, ShowPiratePartnerOffer, 0);
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Trade.PlayerSend'), 0, ShowTrade, 0);
          end
          else
          begin
          if GetPlayer <> TalkShip.OrderTarget then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.FlyToMe'), 0, OrderPiratePartnerFollow, 0);
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.Attack'), 0, ShowPirateAttackTargets, 0);
          case GetPlayer.Order of
            soLand:
              if GetPlayer.OrderTarget <> TalkShip.OrderTarget then
              begin
                if GetPlayer.OrderTarget is TPlanet then TargetName := (GetPlayer.OrderTarget as TPlanet).Name
                else if GetPlayer.OrderTarget is TRuins then TargetName := (GetPlayer.OrderTarget as TRuins).GetColoredFullName('')
                else TargetName := '';
                if Length(TargetName) > 0 then
                  AddChoice(FormatText1('- ' + GetPlayer.LookupTalkText('Talk.Pirate.LandingToObject'), '<color=255,240,100>', '<ObjectName>', TargetName), 0, OrderPiratePartnerLand, 0);
              end;
            soJump:
              if GetPlayer.OrderTarget <> TalkShip.OrderTarget then
                AddChoice(FormatText1('- ' + GetPlayer.LookupTalkText('Talk.Pirate.FlyToStar'), '<color=255,240,100>', '<Star>', (GetPlayer.OrderTarget as TStar).Name), 0, OrderPiratePartnerJump, 0);
          end;
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.FinancesCheck'), 0, ShowPiratePartnerFinances, 0);
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.PlayerDismissSend'), 0, ShowPartnerDismissal, 0);
          end;
        end;
      stWarrior:
        if RecognizesPlayer and (TWarrior(TalkShip).WarriorType = wtFlagship) then
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerAsk'), 0, ShowMilitarySupport, 0);
      stKling:
        if (TalkShip <> BlazerShip) and (TalkShip <> KellerShip) and (TalkShip <> TerronShip) and
          ((TalkShip as TKling).ActiveProgramAppliedTurn <= 0) and GetPlayer.HasProgram(prgIntercom) and
          GetPlayer.CanResolveObjectWithScanner(TalkShip) then
        begin
          for ProgramIndex := Low(ProgramNames) to High(ProgramNames) do
            if (GetPlayer.ProgramCounts[ProgramIndex] > 0) and (ProgramIndex in [prgShipwreck..prgDisconnection]) and
              ((TalkShip as TKling).ActiveProgramAppliedTurn = 0) then
              AddChoice('- ' + FormatText1(GetPlayer.LookupTalkText('Talk.Dominator.ProgrammPlayer'),
                '<color=255,240,100>', '<Name>', GetPlayer.GetProgramName(ProgramIndex)), ProgramIndex, RunDominatorProgram, 0);
          if RecognizesPlayer or GetPlayer.ChameleonDetected[Ord((TalkShip as TKling).DominatorSeries)] or
            ((TalkShip as TKling).DominatorSeries <> GetPlayer.ChameleonSeries) then
          begin
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Dominator.HiPlayer'), 0, ShowDominatorGreeting, 0);
            if (TalkShip.CurrentStar.Id <> Galaxy.KellerResearchTargetStarId) or (KellerShip = nil) then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Dominator.PeacePlayer'), 0, ShowDominatorPeace, 0);
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Dominator.GoodsPlayer'), 0, ShowDominatorGoods, 0);
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Dominator.CommandPlayer'), 0, ShowDominatorCommand, 0);
          end;
        end;
      stTranclucator:
        if (TalkShip as TTranclucator).OwnerShip = GetPlayer then
        begin
          AddImmediateAttackChoices;
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerOffersAttack'), 0, ShowAttackTargets, 0);
          if (TalkShip as TTranclucator).GetCargoHook <> nil then
          begin
            if (TalkShip as TTranclucator).SeekItems then
              AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.SeekItems.PlayerCancel'), 0, CancelTranclucatorSeekItems, 0)
            else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.SeekItems.PlayerSend'), 0, OrderTranclucatorSeekItems, 0);
          end;
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.Options.PlayerSend'), 0, ShowTranclucatorOptions, 0);
          if TalkShip.HasLooseNonScriptItemsOrGoods then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.DropCargo.PlayerSend'), 0, OrderTranclucatorDropCargo, 0);
          if (GetPlayer.Order in [soLand]) and (GetPlayer.OrderTarget <> TalkShip.OrderTarget) then
          begin
            TargetName := '';
            if GetPlayer.OrderTarget is TPlanet then
            begin
              if (GetPlayer.OrderTarget as TPlanet).OwnerId in [oiMaloc..oiGaal, oiPirate] then
                TargetName := (GetPlayer.OrderTarget as TPlanet).Name;
            end
            else if GetPlayer.OrderTarget is TRuins then
              TargetName := (GetPlayer.OrderTarget as TRuins).GetColoredFullName('');
            if Length(TargetName) > 0 then
            begin
              AddChoice(FormatText1('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.LandingToObject'), '<color=255,240,100>', '<ObjectName>', TargetName), 0, OrderTranclucatorLand, 0);
              AddChoice(FormatText1('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.LandingToStorage'), '<color=255,240,100>', '<ObjectName>', TargetName), 0, OrderTranclucatorStoreCargo, 0);
            end;
          end;
          if GetPlayer <> TalkShip.OrderTarget then
            AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.FlyToMe.PlayerSend'), 0, OrderTranclucatorFollow, 0);
          AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.Return.PlayerSend'), 0, OrderTranclucatorReturn, 0);
        end;
    end;
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end;
end;
{ @end $6D5048 }

{ @routine $6D822C TfTalk_AddScriptExitChoice }
procedure TfTalk.AddScriptExitChoice(Caption: WideString);
begin
  if Caption <> '' then AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptExitAnswer, 0)
  else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), CurrentScript.CurrentAnswer, RunScriptExitAnswer, 0);
end;
{ @end $6D822C }

{ @routine $6D831C TfTalk_CodeMsgOut }
procedure TfTalk.CodeMsgOut(KeepGreeting: Boolean);
var
  Binding: TScriptShip;
begin
  ClearScriptDialogRules;
  SkipShipScriptAdvance := False;
  if TalkPlanet <> nil then
  begin
    ClearChoices(False);
    CurrentScript.CallDialogMessage(ScriptDialogIndex);
  end
  else if (CurrentScript <> nil) and (ScriptDialogIndex >= 0) then
  begin
    ClearChoices(False);
    SkipShipScriptAdvance := True;
    CurrentScript.PublishCurrentShip(TalkShip);
    CurrentScript.CallDialogMessage(ScriptDialogIndex);
  end
  else if TalkShip.ScriptShip <> nil then
  begin
    if (TalkShip = BlazerShip) or (TalkShip = KellerShip) or (TalkShip = TerronShip) then
      if (TalkShip as TKling).IsPlayerCamouflageEffective(GetPlayer) then
      begin
        if (TalkShip = BlazerShip) and (Galaxy.BlazerLandingPlanetId <> 0) then
          DialogText := TalkShip.LookupTalkText('Talk.Dominator.Chameleon.BossBlazerLand')
        else if (TalkShip = TerronShip) and (Galaxy.TerronToStarTurn <> 0) then
          DialogText := TalkShip.LookupTalkText('Talk.Dominator.Chameleon.BossTerronToStar')
        else if (TalkShip = TerronShip) and (Galaxy.TerronGrowLockTurn <> 0) then
          DialogText := TalkShip.LookupTalkText('Talk.Dominator.Chameleon.BossTerronGrowLock')
        else DialogText := TalkShip.LookupTalkText('Talk.Dominator.Chameleon.Boss' + DominatorSeriesNames[Ord((TalkShip as TKling).DominatorSeries)]);
        BuildBuiltinChoices;
        Exit;
      end;
    ClearChoices(False);
    TScriptShip(TalkShip.ScriptShip).Script.PublishShipContext(TalkShip.ScriptShip as TScriptShip);
    if ScriptDialogIndex < 0 then
    begin
      Binding := TScriptShip(TalkShip.ScriptShip);
      if Binding.State.DialogCode <> nil then
      begin
        try
          Binding.State.DialogCode.Run(ScriptProcess);
        except
          on E: EBreakMessageGI do ;
          on E: Exception do
          begin
            AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
            LogScriptCallHistory;
            raise Exception.Create(AnsiString('Error in CodeMsgOut code of script ' + CurrentScript.ScriptFileName +
              ' (state #' + Binding.Ship.GetFullName(' ') + ' ' + Binding.State.Name + ')'));
          end;
        end;
        BuildStandardChoices(False);
      end
      else if (Binding.State.DialogTextOrVariable <> '') and (Binding.Script.InitCode.LocalVar.GetVarNE(Binding.State.DialogTextOrVariable) <> nil) then
      begin
        CurrentScript.CallDialogByVariable(Binding.State.DialogTextOrVariable);
        if ScriptDialogIndex < 0 then
        begin
          if not KeepGreeting then
          begin
            if TalkScripted then DialogText := TalkText
            else DialogText := GetShipGreeting;
          end;
          BuildBuiltinChoices;
        end
        else
        begin
          SkipShipScriptAdvance := True;
          CurrentScript.CallDialogMessage(ScriptDialogIndex);
        end;
      end
      else
      begin
        if not KeepGreeting then
        begin
          if TalkScripted then DialogText := TalkText
          else DialogText := GetShipGreeting;
        end;
        BuildStandardChoices(False);
      end;
    end
    else
    begin
      SkipShipScriptAdvance := True;
      CurrentScript.CallDialogMessage(ScriptDialogIndex);
    end;
  end
  else
  begin
    if not KeepGreeting then
    begin
      if TalkScripted then DialogText := TalkText
      else DialogText := GetShipGreeting;
    end;
    BuildStandardChoices(False);
  end;
end;
{ @end $6D831C }

{ @routine $6D8AC0 TfTalk_RunScriptAnswer }
procedure TfTalk.RunScriptAnswer(Answer: Integer);
begin
  ClearChoices(False);
  ScriptDialogIndex := -1;
  CurrentScript.ExecuteDialogAnswer(Answer);
  if ScriptDialogIndex < 0 then RaiseWideMessage('I_Script');
  CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $6D8AC0 }

{ @routine $6D8B34 TfTalk_RunScriptAnswerKeepingScroll }
procedure TfTalk.RunScriptAnswerKeepingScroll(Answer: Integer);
begin
  RememberChoiceScroll;
  RunScriptAnswer(Answer);
end;
{ @end $6D8B34 }

{ @routine $6D8B58 TfTalk_FastExit }
procedure TfTalk.FastExit(Answer: Integer);
begin
  if (TextPresentationTimer = nil) and (SlideTimer = nil) then
  begin
    RequestedScreenId := TalkReturnScreenId;
    if TalkScripted then StarMapScreen.ResumeMode := smrWaitForTurn;
    ScriptDialogIndex := -1;
    RequestClose(1);
  end;
end;
{ @end $6D8B58 }

{ @routine $6D8BC0 TfTalk_RunScriptExitAnswer }
procedure TfTalk.RunScriptExitAnswer(Action: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Action);
  RequestedScreenId := TalkReturnScreenId;
  if TalkScripted then StarMapScreen.ResumeMode := smrWaitForTurn;
  ScriptDialogIndex := -1;
  RequestClose(1);
end;
{ @end $6D8BC0 }

{ @routine $6D8C20 TfTalk_ShowGreeting }
procedure TfTalk.ShowGreeting(Action: Integer);
begin
  DialogText := GetShipGreeting;
  BuildStandardChoices(False);
end;
{ @end $6D8C20 }

{ @routine $6D8C88 TfTalk_AcceptScriptedConversation }
procedure TfTalk.AcceptScriptedConversation(Action: Integer);
begin
  TalkResponse := 1;
  RequestedScreenId := TalkReturnScreenId;
  if TalkScripted then StarMapScreen.ResumeMode := smrWaitForTurn;
  ScriptDialogIndex := -1;
  RequestClose(1);
end;
{ @end $6D8C88 }

{ @routine $6D8CE0 TfTalk_ReturnToMap }
procedure TfTalk.ReturnToMap(Action: Integer);
begin
  ModalTransition := tmtReopen;
  RequestedScreenId := TalkReturnScreenId;
  if TalkScripted then StarMapScreen.ResumeMode := smrWaitForTurn;
  RequestClose(1);
  BreakUiMessage;
end;
{ @end $6D8CE0 }

{ @routine $6D8D38 TfTalk_ShowTrade }
procedure TfTalk.ShowTrade(Action: Integer);
var
  Capacity, Money: Integer;
begin
  ClearChoices(False);
  Capacity := TalkShip.GetCargoFreeSpace - TalkShip.GetDesiredCargoFreeSpace;
  Money := TalkShip.Money;
  if TalkShip.GetRelationLevelToShip(GetPlayer) < rlNormal then
    DialogText := TalkShip.LookupTalkText('Talk.Trade.AnswerBadRelations')
  else if (TalkShip.EnemyShip <> nil) and ((TalkShip.EnemyShip.OrderTarget = TalkShip) or (TalkShip.OrderTarget = TalkShip.EnemyShip)) and
    (GetPlayer <> TalkShip.PartnerShip) then
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Trade.AnswerWar'), '<color=255,240,100>', '<ShipBad>',
      TalkShip.EnemyShip.GetName + GetLocalObjectLink(TalkShip.EnemyShip, False))
  else if (TalkShip.GetCurrentPickupItem <> nil) and (GetPlayer <> TalkShip.PartnerShip) then
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Trade.AnswerAlreadyTakeItem'), '<color=255,240,100>', '<Item>',
      TalkShip.GetCurrentPickupItem.GetDisplayName + GetLocalObjectLink(TalkShip.GetCurrentPickupItem, False))
  else if not TalkShip.HasCargoGoods and ((Capacity < 1) or (Money < GoodsMarket[Ord(t_Food)].AveragePrice)) then
    DialogText := TalkShip.LookupTalkText('Talk.Trade.AnswerNoNeedGoods')
  else if PointDistanceSquared(GetPlayer.Position, TalkShip.Position) > 250000 then
    DialogText := TalkShip.LookupTalkText('Talk.Trade.AnswerBigDist')
  else
  begin
    if Capacity > 0 then DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Trade.TradeOkMayBuyOk'),
      '<color=255,240,100>', '<Cnt>', WideString(IntToStr(Capacity)))
    else DialogText := TalkShip.LookupTalkText('Talk.Trade.TradeOkMayBuyNo');
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Trade.TradeGo'), 0, OpenTrade, 0);
  end;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Trade.TradeBreak'), 0, CancelTrade, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6D8D38 }

{ @routine $6D93F0 TfTalk_OpenTrade }
procedure TfTalk.OpenTrade(Action: Integer);
begin
  ModalTransition := tmtTrade;
  RequestedScreenId := TalkReturnScreenId;
  if TalkScripted then StarMapScreen.ResumeMode := smrWaitForTurn;
  RequestClose(1);
  BreakUiMessage;
end;
{ @end $6D93F0 }

{ @routine $6D9448 TfTalk_CancelTrade }
procedure TfTalk.CancelTrade(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.Trade.AfterBreak');
  BuildStandardChoices(True);
end;
{ @end $6D9448 }

{ @routine $6D94E8 TfTalk_ShowMoneyDemand }
procedure TfTalk.ShowMoneyDemand(Action: Integer);
var
  I: Integer;
  Partner: TShip;
  PartnerCanDemand: Boolean;
begin
  if (GetPlayer.TruceShip = TalkShip) or ((TalkShip is TNormalShip) and
    ((TalkShip as TNormalShip).LastPlayerExtortionTurn + 30 > Galaxy.CurrentTurn)) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Money.WeAlreadyHavePact');
    TalkShip.ReactToExtortionDemand(GetPlayer);
    BuildStandardChoices(True);
  end
  else
  begin
    PartnerCanDemand := False;
    for I := 0 to GetPlayer.PiratePartners.Count - 1 do
    begin
      Partner := GetPlayer.PiratePartners[I];
      if TalkShip.AcceptsRansomDemandFrom(Partner) then
      begin
        PartnerCanDemand := True;
        Break;
      end;
    end;
    if not TalkShip.AcceptsRansomDemandFrom(GetPlayer) and not PartnerCanDemand then
    begin
      DialogText := TalkShip.LookupTalkText('Talk.Money.' + TalkShip.GetTypeNameKey + 'No');
      TalkShip.ReactToExtortionDemand(GetPlayer);
      BuildStandardChoices(True);
    end
    else if (TalkShip.TypeId <> stWarrior) and TalkShip.CanEscapePursuer(GetPlayer) then
    begin
      DialogText := TalkShip.LookupTalkText('Talk.Money.' + TalkShip.GetTypeNameKey + 'LongDistance');
      TalkShip.ReactToExtortionDemand(GetPlayer);
      BuildStandardChoices(True);
    end
    else
    begin
      DialogText := TalkShip.LookupTalkText('Talk.Money.ComputerAsk');
      ClearChoices(False);
      AddChoice('- ' + ReplaceColoredToken(GetPlayer.LookupTalkText('Talk.Money.PlayerSendSum'), '<Money>',
        WideString(IntToStr(ExtortionDemandAmount)), '<color=255,240,100>'), 0, DemandMoney, 0);
      if ExtortionDemandAmount div 2 > 10 then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Money.PlayerLess'), 0, HalveMoneyDemand, 0);
      if 3 * (TalkShip.GetWealthScaledAmount(3) + GetPlayer.GetWealthScaledAmount(3)) >= 2 * ExtortionDemandAmount then
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Money.PlayerMore'), 0, DoubleMoneyDemand, 0);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Cancel'), 0, ShowGreeting, 0);
    end;
  end;
end;
{ @end $6D94E8 }

{ @routine $6D9AAC TfTalk_DemandMoney }
procedure TfTalk.DemandMoney(Action: Integer);
begin
  if TalkShip.BuildMoneyExtortionResponse(GetPlayer, DialogText, ExtortionDemandAmount) then
  begin
    SoundManager.PlaySound('Sound.Sell');
    TryAddAchievementProgress('ROBBER', 1);
  end;
  BuildStandardChoices(True);
end;
{ @end $6D9AAC }

{ @routine $6D9B44 TfTalk_HalveMoneyDemand }
procedure TfTalk.HalveMoneyDemand(Action: Integer);
begin
  ExtortionDemandAmount := ExtortionDemandAmount div 2;
  ShowMoneyDemand(0);
end;
{ @end $6D9B44 }

{ @routine $6D9B70 TfTalk_DoubleMoneyDemand }
procedure TfTalk.DoubleMoneyDemand(Action: Integer);
begin
  ExtortionDemandAmount := ExtortionDemandAmount * 2;
  ShowMoneyDemand(0);
end;
{ @end $6D9B70 }

{ @routine $6D9B98 TfTalk_DemandCargo }
procedure TfTalk.DemandCargo(Action: Integer);
begin
  if TalkShip.BuildCargoExtortionResponse(GetPlayer, DialogText) then TryAddAchievementProgress('ROBBER', 1);
  BuildStandardChoices(True);
end;
{ @end $6D9B98 }

{ @routine $6D9BFC TfTalk_ShowTruceOffer }
procedure TfTalk.ShowTruceOffer(Action: Integer);
var
  Response: WideString;
begin
  if GetPlayer.TruceShip = TalkShip then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Truce.WeAlreadyHavePact');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end
  else if TalkShip.RefusesFactionNegotiation(GetPlayer) then
  begin
    ClearChoices(False);
    BuildStandardChoices(True);
    DialogText := TalkShip.LookupTalkText('Talk.Refuse.' + TalkShip.GetTypeNameKey);
  end
  else if TalkShip.BuildTrucePaymentResponse(GetPlayer, Response, 0) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Truce.ComputerOkWithoutMoney');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end
  else
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Truce.ComputerAsk');
    ClearChoices(False);
    if GetPlayer.Money > 0 then
    begin
      AddChoice('- ' + ReplaceColoredToken(GetPlayer.LookupTalkText('Talk.Truce.PlayerSendSum'), '<Money>',
        WideString(IntToStr(TruceOfferAmount)), '<color=255,240,100>'), 0, AcceptTruceOffer, 0);
      if TruceOfferAmount div 2 > 100 then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Truce.PlayerLess'), 0, HalveTruceOffer, 0);
      if GetPlayer.Money > TruceOfferAmount then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Truce.PlayerMore'), 0, DoubleTruceOffer, 0);
    end
    else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Truce.PlayerNotHaveMoney'), 0, ShowGreeting, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Cancel'), 0, ShowGreeting, 0);
  end;
end;
{ @end $6D9BFC }

{ @routine $6DA1D8 TfTalk_AcceptTruceOffer }
procedure TfTalk.AcceptTruceOffer(Action: Integer);
begin
  if TalkShip.BuildTrucePaymentResponse(GetPlayer, DialogText, TruceOfferAmount) then
  begin
    SoundManager.PlaySound('Sound.Sell');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end
  else BuildStandardChoices(True);
end;
{ @end $6DA1D8 }

{ @routine $6DA2EC TfTalk_HalveTruceOffer }
procedure TfTalk.HalveTruceOffer(Action: Integer);
begin
  TruceOfferAmount := Max(100, TruceOfferAmount div 2);
  ShowTruceOffer(0);
end;
{ @end $6DA2EC }

{ @routine $6DA334 TfTalk_DoubleTruceOffer }
procedure TfTalk.DoubleTruceOffer(Action: Integer);
begin
  TruceOfferAmount := Min(GetPlayer.Money, TruceOfferAmount * 2);
  ShowTruceOffer(0);
end;
{ @end $6DA334 }

{ @routine $6DA568 TfTalk_ShowAttackTargets }
procedure TfTalk.ShowAttackTargets(Action: Integer);
var RadarRangeSquared: Integer; Ship: TShip; AllowTargets: Boolean; SavedText: WideString;
  // @nested $6DA384 AddAvailableAttackTargets
  procedure AddAvailableAttackTargets; // @addr $6DA384 @calls "0x6DA8CA"
  var I: Integer;
  begin
    RadarRangeSquared := GetPlayer.GetRadarRange * GetPlayer.GetRadarRange;
    for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
    begin
      Ship := GetPlayer.CurrentStar.Ships[I];
      if (TalkShip.OrderTarget <> Ship) and (GetPlayer <> Ship) and (Ship <> TalkShip) and
        (GetPlayer <> Ship.PartnerShip) and Ship.InNormalSpace and
        (RadarRangeSquared > PointDistanceSquared(GetPlayer.Position, Ship.Position)) and
        not (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and GetPlayer.CanSelectShipTarget(Ship) and
        not (Ship.TargetingRestriction in [1, 2]) then
        AddChoice('- ' + Ship.GetFullName(' ') + GetLocalObjectLink(Ship, False), Integer(Ship), RequestAttackTarget, Integer(Ship));
    end;
  end;
begin
  AllowTargets := True;
  ClearChoices(False);
  if TalkShip.RecomputeFearState and (GetPlayer <> TalkShip.PartnerShip) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Attack.ComputerInFear');
    AllowTargets := False;
  end
  else if TalkShip is TTranclucator then
    DialogText := TalkShip.LookupTalkText('Talk.Tranclucator.Attack.Ask')
  else if not TalkShip.TrustsAttackRequester(GetPlayer) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Attack.' + TalkShip.GetTypeNameKey + 'Suspect');
    AllowTargets := False;
  end
  else if TalkShip.HasLockedOrFollowOrder and (GetPlayer <> TalkShip.PartnerShip) and (TalkShip.TypeId <> stWarrior) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Attack.' + TalkShip.GetTypeNameKey + 'HaveBusiness');
    AllowTargets := False;
  end
  else if TalkShip.OrderTarget is TShip then
  begin
    Ship := TalkShip.OrderTarget as TShip;
    if (TalkShip.GetRelationLevelToShip(Ship) = rlHostile) and GetPlayer.CanSelectShipTarget(Ship) and
      not (Ship.TargetingRestriction in [1, 2]) then
    begin
      DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Attack.ComputerReadyAttack'),
        '<color=255,240,100>', '<Target>', Ship.GetFullName(' ') + GetLocalObjectLink(Ship, False));
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Attack.PlayerOk'), Integer(Ship), AcceptJointAttack, 0);
      AllowTargets := True;
    end
    else
    begin
      DialogText := TalkShip.LookupTalkText('Talk.Attack.' + TalkShip.GetTypeNameKey + 'HaveBusiness');
      AllowTargets := False;
    end;
  end
  else DialogText := TalkShip.LookupTalkText('Talk.Attack.ComputerAsk');
  // The native routine clears the ready-attack choice above before listing targets.
  ClearChoices(False);
  if AllowTargets then
  begin
    AddAvailableAttackTargets;
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Cancel'), 0, ShowGreeting, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end
  else
  begin
    SavedText := DialogText;
    BuildStandardChoices(True);
    DialogText := SavedText;
  end;
end;
{ @end $6DA568 }

{ @routine $6DABA4 TfTalk_RequestAttackTarget }
procedure TfTalk.RequestAttackTarget(Action: Integer);
var Target: TShip; Event: TGalaxyEvent; Accepted: Boolean;
begin
  Target := TShip(Action);
  if TalkShip.RecomputeFearState and (TalkShip.OrderTarget <> Target) and (GetPlayer <> TalkShip.PartnerShip) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Attack.ComputerInFear');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
    Exit;
  end;

  Accepted := TalkShip.BuildAttackRequestResponse(GetPlayer, DialogText, Target);
  if Accepted then
  begin
    Event := AddGalaxyEvent('PlayerTalkedShipIntoAttacking');
    Event.AddData(TalkShip.Id);
    Event.AddData(Target.Id);
  end;
  if Accepted and (GetPlayer = TalkShip.PartnerShip) then
  begin
    if GetPlayer.CountPartnersInNormalSpace > 1 then
    begin
      DialogText := DialogText + #13#10 + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
      ClearChoices(False);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForYou'), 0, ExitPartnerConversation, 0);
    end
    else
    begin
      ClearChoices(False);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
    end;
  end
  else
  begin
    ClearChoices(False);
    if Accepted and (TalkShip is TTranclucator) then AddTranclucatorGroupChoice;
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end;
end;
{ @end $6DABA4 }

{ @routine $6DAFF8 TfTalk_AcceptJointAttack }
procedure TfTalk.AcceptJointAttack(Action: Integer);
var Target: TShip;
begin
  Target := TShip(Action);
  TalkShip.SetJointAttackTarget(GetPlayer, Target);
  if GetPlayer = TalkShip.PartnerShip then
    if GetPlayer.CountPartnersInNormalSpace > 1 then
    begin
      DialogText := DialogText + #13#10 + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
      ClearChoices(False);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForYou'), 0, ExitPartnerConversation, 0);
    end
    else
    begin
      ClearChoices(False);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
    end;
  FastExit(0);
end;
{ @end $6DAFF8 }

{ @routine $6DB26C TfTalk_RequestProtection }
procedure TfTalk.RequestProtection(Action: Integer);
var Target: TShip; I, Reward: Integer; Weapon: TWeapon;
  CanEscape, FearsAttacker, RecognizesPlayer: Boolean;
begin
  if (not TalkShip.RecomputeFearState) and (TalkShip.GetRelationLevelToShip(GetPlayer) = rlHostile) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Protect.ComputerNotFearAndWar');
    BuildStandardChoices(True);
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
    Exit;
  end;

  Target := TShip(TalkShip.OrderTarget);
  if TalkShip.RefusesFactionNegotiation(Target) then
  begin
    if TalkShip.GetRelationLevelToShip(GetPlayer) = rlHostile then
      DialogText := TalkShip.LookupTalkText('Talk.Protect.ComputerNotFearAndWar')
    else DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Protect.' + TalkShip.GetTypeNameKey + 'No'), '<color=255,240,100>', '<Target>', Target.GetFullName(' ') + GetLocalObjectLink(Target, False));
    BuildStandardChoices(True);
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
    Exit;
  end;

  if TalkShip.AcceptsAppealFrom(GetPlayer) then
  begin
    CanEscape := Target.CanEscapePursuer(TalkShip);
    FearsAttacker := Target.AcceptsRansomDemandFrom(TalkShip);
    Reward := Round(RemapClamped(Target.ChanceToWin(TalkShip), 0.1, 1,
      Galaxy.ComputeScaledSmallMoney(Target.OwnerId) * 0.5,
      Galaxy.ComputeScaledMiniMoney(Target.OwnerId) * 0.5));
    if TalkShip.EnemyShip = Target then TalkShip.EnemyShip := nil;
    if TalkShip.TypeId = stRanger then Target.ChangeRelationToRanger(TalkShip, 15);
    if TalkShip = Target.EnemyShip then Target.EnemyShip := nil;
    if Target.TypeId = stRanger then TalkShip.ChangeRelationToRanger(Target, 15);
    TalkShip.TruceShip := Target;
    TalkShip.NextDay;
    if TalkShip.OrderTarget = Target then TalkShip.OrderNone(False);
    if (TalkShip.Order = soFollowShip) and ((TalkShip.OrderTarget as TShip).TypeId in [stRanger..stPirate]) then
    begin
      TalkShip.NavigateToQueuedPlanet(False);
      if TalkShip.Order = soFollowShip then TalkShip.OrderNone(False);
    end;
    for I := 1 to Target.WeaponCount do
    begin
      Weapon := Target.Weapons[I];
      if TalkShip = Weapon.Target then Weapon.Target := nil;
    end;
    for I := 1 to TalkShip.WeaponCount do
    begin
      Weapon := TalkShip.Weapons[I];
      if Weapon.Target = Target then Weapon.Target := nil;
    end;
    TalkShip.TruceWithShip(Target);
    Target.ChangeRelationToRanger(GetPlayer, 50);
    if TalkShip.TypeId = stPirate then GetPlayer.AddWarriorCareerActivity(4);
    if Target.TypeId = stPirate then GetPlayer.AddPirateCareerActivity(8);
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Protect.' + TalkShip.GetTypeNameKey + 'Ok'), '<color=255,240,100>', '<Target>', Target.GetFullName(' ') + GetLocalObjectLink(Target, False));
    RecognizesPlayer := not Target.IsPlayerChameleonEffectiveAgainstSelf;
    if RecognizesPlayer and (Target.TypeId in [stRanger..stPirate]) then
    begin
      if not FearsAttacker then Target.ShowMessageToPlayer(Target.LookupTalkText('Talk.Protect.TargetNotFearShip'))
      else if CanEscape and (Target.GetHullIntegrityPercent > 30) then
        Target.ShowMessageToPlayer(Target.LookupTalkText('Talk.Protect.TargetMayRunAway'))
      else if Target.HasCargoGoods then
      begin
        Target.JettisonCargoGoodsTowardTargetValue(Reward);
        Target.ShowMessageToPlayer(Target.LookupTalkText('Talk.Protect.TargetGiveGoods'));
      end
      else if Target.Money >= Reward then
      begin
        Target.SetMoney(Target.Money - Reward);
        GetPlayer.SetMoney(GetPlayer.Money + Reward);
        Target.ShowMessageToPlayer(FormatText1(Target.LookupTalkText('Talk.Protect.TargetGiveMoney'),
          '<color=255,240,100>', '<Money>', WideString(IntToStr(Reward))));
      end
      else Target.ShowMessageToPlayer(Target.LookupTalkText('Talk.Protect.TargetThanks'));
    end;
    if TalkShip is TPirate then TryAddAchievementProgress('NEGOCIANT', 1);
  end
  else DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Protect.' + TalkShip.GetTypeNameKey + 'No'), '<color=255,240,100>', '<Target>', Target.GetFullName(' ') + GetLocalObjectLink(Target, False));
  ClearChoices(False);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6DB26C }

{ @routine $6DBD2C TfTalk_RequestPreserveItems }
procedure TfTalk.RequestPreserveItems(Action: Integer);
var I: Integer;
begin
  if (TalkShip.GetRelationLevelToShip(GetPlayer) = rlHostile) and not TalkShip.RecomputeFearState then
    DialogText := TalkShip.LookupTalkText('Talk.PreserveItems.ComputerNotFearAndWar')
  else if (TalkShip.GetRelationLevelToShip(GetPlayer) >= rlGood) or TalkShip.AcceptsAppealFrom(GetPlayer) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.PreserveItems.' + TalkShip.GetTypeNameKey + 'Ok');
    if GetPlayer.PickupTargets <> nil then
      for I := 1 to TalkShip.WeaponCount do
        if (TalkShip.Weapons[I].Target <> nil) and
          (GetPlayer.PickupTargets.IndexOf(TalkShip.Weapons[I].Target) >= 0) then TalkShip.Weapons[I].Target := nil;
  end
  else DialogText := TalkShip.LookupTalkText('Talk.PreserveItems.' + TalkShip.GetTypeNameKey + 'No');
  BuildStandardChoices(True);
end;
{ @end $6DBD2C }

{ @routine $6DBFCC TfTalk_ShowPartnerOffer }
procedure TfTalk.ShowPartnerOffer(Action: Integer);
var
  Response: WideString;
begin
  if TalkShip.RelationToShip(GetPlayer) < 45 then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Partner.Suspect');
    BuildStandardChoices(True);
  end
  else if TalkShip.PartnerShip <> nil then
  begin
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Partner.AlreadyHavePartner'), '<color=255,240,100>', '<Partner>', (TalkShip.PartnerShip as TRanger).Name);
    BuildStandardChoices(True);
  end
  else if (TalkShip as TRanger).CountWingmen > 0 then
  begin
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Partner.ILeader'), '<color=255,240,100>', '<Ranger>', GetPlayer.Name);
    BuildStandardChoices(True);
  end
  else if GetPlayer.GetEffectiveSkillLevel(psLeadership) <= GetPlayer.CountWingmen then
  begin
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Partner.NeedLeadership'), '<color=255,240,100>', '<Ranger>', GetPlayer.Name);
    BuildStandardChoices(True);
  end
  else if (TalkShip as TRanger).Rank > GetPlayer.Rank then
  begin
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Partner.YouNeedInMoreRank'), '<color=255,240,100>', '<Ranger>', GetPlayer.Name);
    BuildStandardChoices(True);
  end
  else
  begin
    if TalkShip.BuildPartnershipOfferResponse(GetPlayer, Response, PartnerOfferAmount) then
      DialogText := FormatText2(TalkShip.LookupTalkText('Talk.Partner.ComputerSayOk'), '<color=255,240,100>',
        '<Money>', WideString(IntToStr(PartnerOfferAmount)), '<Month>', WideString(IntToStr(TalkShip.CalculatePartnershipMonths(PartnerOfferAmount, GetPlayer))))
    else DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Partner.ComputerSayNo'), '<color=255,240,100>', '<Money>', WideString(IntToStr(PartnerOfferAmount)));
    ClearChoices(False);
    if TalkShip.BuildPartnershipOfferResponse(GetPlayer, Response, PartnerOfferAmount) then
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.PlayerOk'), 0, AcceptPartnerOffer, 0);
    if PartnerOfferAmount div 2 > 0 then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.PlayerLess'), 0, HalvePartnerOffer, 0);
    if GetPlayer.Money > PartnerOfferAmount then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.PlayerMore'), 0, DoublePartnerOffer, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Cancel'), 0, ShowGreeting, 0);
  end;
end;
{ @end $6DBFCC }

{ @routine $6DC790 TfTalk_AcceptPartnerOffer }
procedure TfTalk.AcceptPartnerOffer(Action: Integer);
begin
  if TalkShip.AcceptPartnershipOffer(GetPlayer, DialogText, PartnerOfferAmount) then SoundManager.PlaySound('Sound.Sell');
  BuildStandardChoices(True);
end;
{ @end $6DC790 }

{ @routine $6DC804 TfTalk_HalvePartnerOffer }
procedure TfTalk.HalvePartnerOffer(Action: Integer);
begin
  PartnerOfferAmount := PartnerOfferAmount div 2;
  ShowPartnerOffer(0);
end;
{ @end $6DC804 }

{ @routine $6DC830 TfTalk_DoublePartnerOffer }
procedure TfTalk.DoublePartnerOffer(Action: Integer);
begin
  if GetPlayer.Money < PartnerOfferAmount * 2 then PartnerOfferAmount := GetPlayer.Money
  else PartnerOfferAmount := PartnerOfferAmount * 2;
  ShowPartnerOffer(0);
end;
{ @end $6DC830 }

{ @routine $6DC880 TfTalk_OrderPartnerFollow }
procedure TfTalk.OrderPartnerFollow(Action: Integer);
begin
  TalkShip.OrderFollowShip(GetPlayer, 0, True);
  DialogText := TalkShip.LookupTalkText('Talk.Partner.ComputerAgreeFlyToMe');
  if GetPlayer.CountPartnersInNormalSpace > 1 then
  begin
    DialogText := DialogText + #13#10;
    DialogText := DialogText + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForYou'), 0, ExitPartnerConversation, 0);
  end
  else
  begin
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end;
end;
{ @end $6DC880 }

{ @routine $6DCB34 TfTalk_OrderPartnerLand }
procedure TfTalk.OrderPartnerLand(Action: Integer);
var
  Name: WideString;
begin
  TalkShip.OrderLanding(GetPlayer.OrderTarget, True);
  if GetPlayer.OrderTarget is TPlanet then Name := (GetPlayer.OrderTarget as TPlanet).Name
  else if GetPlayer.OrderTarget is TRuins then Name := (GetPlayer.OrderTarget as TRuins).GetColoredFullName('');
  DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Partner.ComputerAgreeLandingToObject'), '<color=255,240,100>', '<ObjectName>', Name);
  if GetPlayer.CountPartnersInNormalSpace > 1 then
  begin
    DialogText := DialogText + #13#10;
    DialogText := DialogText + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForYou'), 0, ExitPartnerConversation, 0);
  end
  else
  begin
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end;
end;
{ @end $6DCB34 }

{ @routine $6DCEE0 TfTalk_OrderPartnerJump }
procedure TfTalk.OrderPartnerJump(Action: Integer);
begin
  TalkShip.OrderJump(GetPlayer.OrderTarget as TStar, True);
  DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Partner.ComputerAgreeFlyToStar'), '<color=255,240,100>', '<Star>',
    (GetPlayer.OrderTarget as TStar).Name);
  if GetPlayer.CountPartnersInNormalSpace > 1 then
  begin
    DialogText := DialogText + #13#10;
    DialogText := DialogText + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.OrderForYou'), 0, ExitPartnerConversation, 0);
  end
  else
  begin
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end;
end;
{ @end $6DCEE0 }

{ @routine $6DD218 TfTalk_OrderPartnerDropCargo }
procedure TfTalk.OrderPartnerDropCargo(Action: Integer);
begin
  TalkShip.ChangeRelationToRanger(GetPlayer, -Round(TalkShip.NextRandomInteger(5, 15) / PlanetRaceMarket[TalkShip.PilotRace].PirateRelationFactor));
  if TalkShip.GetRelationLevelToShip(GetPlayer) = rlHostile then TalkShip.ChangeRelationToRanger(GetPlayer, 10);
  if not GetPlayer.CanResolveObjectWithScanner(TalkShip) then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Partner.ComputerDropCargoNo');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end
  else
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Partner.ComputerDropCargoOk');
    TalkShip.DropUnequippedItemsAndGoods;
    BuildStandardChoices(True);
  end;
end;
{ @end $6DD218 }

{ @routine $6DD454 TfTalk_ShowPartnerFinances }
procedure TfTalk.ShowPartnerFinances(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.Partner.FinancesReport');
  ReplaceTextToken(DialogText, '<Money>', WideString(IntToStr(TalkShip.Money)), '<color=255,240,100>');
  ClearChoices(False);
  if GetPlayer.Money > 0 then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.FinancesOfferGift'), 0, ShowPartnerGift, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.FinancesConfirmed'), 0, ShowGreeting, 0);
end;
{ @end $6DD454 }

{ @routine $6DD6B0 TfTalk_ShowPartnerGift }
procedure TfTalk.ShowPartnerGift(Action: Integer);
var
  Text: WideString;
begin
  DialogText := TalkShip.LookupTalkText('Talk.Partner.FinancesWaitForGift');
  ClearChoices(False);
  Text := '- ' + GetPlayer.LookupTalkText('Talk.Partner.FinancesSendGift');
  ReplaceTextToken(Text, '<Money>', WideString(IntToStr(PartnerGiftAmount)), '<color=255,240,100>');
  AddChoice(Text, 0, GivePartnerGift, 0);
  if PartnerGiftAmount div 2 > 0 then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.PlayerLess'), 0, HalvePartnerGift, 0);
  if GetPlayer.Money > PartnerGiftAmount then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Partner.PlayerMore'), 0, DoublePartnerGift, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Cancel'), 0, ShowGreeting, 0);
end;
{ @end $6DD6B0 }

{ @routine $6DD9D8 TfTalk_GivePartnerGift }
procedure TfTalk.GivePartnerGift(Action: Integer);
var
  Change: Integer;
begin
  SoundManager.PlaySound('Sound.Sell');
  Change := Round((150 * PartnerGiftAmount) / Max(1, TalkShip.Wealth + GetPlayer.Wealth) * PlanetRaceMarket[TalkShip.PilotRace].FriendlyRelationScale);
  Change := Max(0, Min(100, Change));
  TalkShip.ChangeRelationToRanger(GetPlayer, Change);
  GetPlayer.SetMoney(Max(0, GetPlayer.Money - PartnerGiftAmount));
  TalkShip.SetMoney(TalkShip.Money + PartnerGiftAmount);
  DialogText := TalkShip.LookupTalkText('Talk.Partner.FinancesGotGift');
  ReplaceTextToken(DialogText, '<Money>', WideString(IntToStr(TalkShip.Money)), '<color=255,240,100>');
  BuildStandardChoices(True);
end;
{ @end $6DD9D8 }

{ @routine $6DDC4C TfTalk_HalvePartnerGift }
procedure TfTalk.HalvePartnerGift(Action: Integer);
begin
  PartnerGiftAmount := PartnerGiftAmount div 2;
  ShowPartnerGift(0);
end;
{ @end $6DDC4C }

{ @routine $6DDC78 TfTalk_DoublePartnerGift }
procedure TfTalk.DoublePartnerGift(Action: Integer);
begin
  PartnerGiftAmount := PartnerGiftAmount * 2;
  if GetPlayer.Money < PartnerGiftAmount then PartnerGiftAmount := GetPlayer.Money;
  ShowPartnerGift(0);
end;
{ @end $6DDC78 }

{ @routine $6DDCC4 TfTalk_ApplyOrderToAllPartners }
procedure TfTalk.ApplyOrderToAllPartners(Action: Integer);
var
  I: Integer;
  Ship: TShip;
begin
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if (GetPlayer = Ship.PartnerShip) and Ship.InNormalSpace and (GetPlayer <> Ship) and (TalkShip <> Ship) then
    begin
      if GetPlayer = TalkShip.OrderTarget then Ship.OrderFollowShip(GetPlayer, 0, True)
      else if TalkShip.Order = soFollowShip then Ship.SetJointAttackTarget(Ship, TalkShip.OrderTarget as TShip)
      else if TalkShip.Order = soLand then Ship.OrderLanding(GetPlayer.OrderTarget, True)
      else if TalkShip.Order = soJump then Ship.OrderJump(GetPlayer.OrderTarget as TStar, True);
    end;
  end;
  FastExit(0);
end;
{ @end $6DDCC4 }

{ @routine $6DDE24 TfTalk_ExitPartnerConversation }
procedure TfTalk.ExitPartnerConversation(Action: Integer);
begin
  FastExit(0);
end;
{ @end $6DDE24 }

{ @routine $6DDE40 TfTalk_OrderTranclucatorFollow }
procedure TfTalk.OrderTranclucatorFollow(Action: Integer);
var
  Ship: TTranclucator;
begin
  Ship := TalkShip as TTranclucator;
  Ship.OrderFollowShip(GetPlayer, 0, True);
  Ship.FollowOwner := False;
  Ship.SeekItems := False;
  DialogText := TalkShip.LookupTalkText('Talk.Tranclucator.FlyToMe.Ok');
  ClearChoices(False);
  AddTranclucatorGroupChoice;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6DDE40 }

{ @routine $6DDF9C TfTalk_OrderTranclucatorReturn }
procedure TfTalk.OrderTranclucatorReturn(Action: Integer);
var
  Ship: TTranclucator;
begin
  Ship := TalkShip as TTranclucator;
  Ship.OrderFollowShip(Ship.OwnerShip, 1, False);
  Ship.FollowOwner := True;
  Ship.SeekItems := False;
  DialogText := TalkShip.LookupTalkText('Talk.Tranclucator.Return.Ok');
  ClearChoices(False);
  AddTranclucatorGroupChoice;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6DDF9C }

{ @routine $6DE0F8 TfTalk_OrderTranclucatorSeekItems }
procedure TfTalk.OrderTranclucatorSeekItems(Action: Integer);
var
  Ship: TTranclucator;
begin
  Ship := TalkShip as TTranclucator;
  Ship.FollowOwner := False;
  Ship.SeekItems := True;
  if Ship.CargoFreeSpace > 0 then Ship.TryCollectPreferredFloatingLoot(50);
  DialogText := TalkShip.LookupTalkText('Talk.Tranclucator.SeekItems.Ok');
  ClearChoices(False);
  AddTranclucatorGroupChoice;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6DE0F8 }

{ @routine $6DE260 TfTalk_CancelTranclucatorSeekItems }
procedure TfTalk.CancelTranclucatorSeekItems(Action: Integer);
var
  Ship: TTranclucator;
begin
  Ship := TalkShip as TTranclucator;
  Ship.FollowOwner := False;
  Ship.SeekItems := False;
  Ship.UpdateFreeFlightOrder;
  DialogText := TalkShip.LookupTalkText('Talk.Tranclucator.SeekItems.Cancel');
  ClearChoices(False);
  AddTranclucatorGroupChoice;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6DE260 }

{ @routine $6DEE2C TfTalk_ShowTranclucatorOptions }
procedure TfTalk.ShowTranclucatorOptions(Action: Integer);
var
  Ship: TTranclucator;
  Digit: Cardinal;
  I: Integer;
  Enabled: Boolean;
  Text: WideString;

  // @nested $6DE3BC AddTranclucatorCollectionOption
  procedure AddTranclucatorCollectionOption(Kind: Integer); // @addr $6DE3BC @calls "0x6DF075"
  var
    Value: Integer;
    Caption: WideString;
  begin
    if Ship.GetCollectionPermission(TTranclucatorCollectionKind(Kind)) then
    begin
      Caption := WrapTextInColor(LocalizedColorText('Talk.Tranclucator.Options.CollectNo'), '<color=255,0,0>');
      Value := Kind * 10;
    end
    else
    begin
      Caption := WrapTextInColor(LocalizedColorText('Talk.Tranclucator.Options.CollectYes'), '<color=45,105,45>');
      Value := Kind * 10 + 1;
    end;
    AddChoice('- ' + FormatText1(Caption, '<color=255,240,100>', '<Item>',
      LocalizedColorText(WideString('Talk.Tranclucator.Options.Collect' + IntToStr(Kind)))), Value, ShowTranclucatorOptions, 0);
  end;

  // @nested $6DE650 GetTranclucatorCollectionText
  function GetTranclucatorCollectionText: WideString; // @addr $6DE650 @calls "0x6DEEF3"
  var
    Kind: Integer;
  begin
    Result := '';
    for Kind := 1 to 6 do
      if Ship.GetCollectionPermission(TTranclucatorCollectionKind(Kind)) then
      begin
        if Length(Result) > 0 then Result := Result + ', ';
        Result := Result + TalkShip.LookupTalkText(WideString('Talk.Tranclucator.Options.Collect' + IntToStr(Kind)));
      end;
  end;

  // @nested $6DE768 AddTranclucatorStorageOption
  procedure AddTranclucatorStorageOption(Kind: Integer); // @addr $6DE768 @calls "0x6DF09B"
  var
    Value: Integer;
    Caption: WideString;
  begin
    if Ship.GetStoragePermission(TTranclucatorStorageKind(Kind)) then
    begin
      Caption := WrapTextInColor(LocalizedColorText('Talk.Tranclucator.Options.LandNo'), '<color=255,0,0>');
      Value := Kind * 1000;
    end
    else
    begin
      Caption := WrapTextInColor(LocalizedColorText('Talk.Tranclucator.Options.LandYes'), '<color=45,105,45>');
      Value := Kind * 1000 + 100;
    end;
    AddChoice('- ' + FormatText1(Caption, '<color=255,240,100>', '<Land>',
      LocalizedColorText(WideString('Talk.Tranclucator.Options.Land' + IntToStr(Kind)))), Value, ShowTranclucatorOptions, 0);
  end;

  // @nested $6DE9EC GetTranclucatorStorageText
  function GetTranclucatorStorageText: WideString; // @addr $6DE9EC @calls "0x6DEF88"
  var
    Kind: Integer;
  begin
    Result := '';
    for Kind := 1 to 2 do
      if Ship.GetStoragePermission(TTranclucatorStorageKind(Kind)) then
      begin
        if Length(Result) > 0 then Result := Result + ', ';
        Result := Result + TalkShip.LookupTalkText(WideString('Talk.Tranclucator.Options.Land' + IntToStr(Kind)));
      end;
  end;

  // @nested $6DEB00 AddTranclucatorArrangeOption
  procedure AddTranclucatorArrangeOption; // @addr $6DEB00 @calls "0x6DF0AB"
  var
    Value: Integer;
    Caption: WideString;
  begin
    if Ship.AutoArrange then
    begin
      Caption := WrapTextInColor(LocalizedColorText('Talk.Tranclucator.Options.ArrangeNo'), '<color=255,0,0>');
      Value := 10000;
    end
    else
    begin
      Caption := WrapTextInColor(LocalizedColorText('Talk.Tranclucator.Options.ArrangeYes'), '<color=45,105,45>');
      Value := 20000;
    end;
    AddChoice('- ' + Caption, Value, ShowTranclucatorOptions, 0);
  end;

  // @nested $6DECBC GetTranclucatorArrangeText
  function GetTranclucatorArrangeText: WideString; // @addr $6DECBC @calls "0x6DF023"
  begin
    Result := '';
    if Ship.AutoArrange then Result := Result + TalkShip.LookupTalkText('Talk.Tranclucator.Options.ArrangeText')
    else Result := Result + TalkShip.LookupTalkText('Talk.Tranclucator.Options.ArrangeBad');
  end;

  // @nested $6DEDFC PopTranclucatorOptionDigit
  procedure PopTranclucatorOptionDigit; // @addr $6DEDFC @calls "0x6DEE73 0x6DEE82 0x6DEE97 0x6DEEA6 0x6DEEBB"
  begin
    Digit := Cardinal(Action) mod 10;
    Cardinal(Action) := Cardinal(Action) div 10;
  end;
begin
  DialogText := '';
  Ship := TalkShip as TTranclucator;
  PopTranclucatorOptionDigit;
  Enabled := Digit = 1;
  PopTranclucatorOptionDigit;
  Ship.SetCollectionPermission(TTranclucatorCollectionKind(Digit), Enabled);
  PopTranclucatorOptionDigit;
  Enabled := Digit = 1;
  PopTranclucatorOptionDigit;
  Ship.SetStoragePermission(TTranclucatorStorageKind(Digit), Enabled);
  PopTranclucatorOptionDigit;
  if Digit = 2 then Ship.AutoArrange := True
  else if Digit = 1 then Ship.AutoArrange := False;
  if Ship.GetCargoHook <> nil then Text := GetTranclucatorCollectionText else Text := '';
  if Text = '' then Text := '---';
  ExpandLocalizedTextMarkup(Text);
  DialogText := DialogText + FormatText1(LocalizedColorText('Talk.Tranclucator.Options.CollectText'), '<color=255,240,100>', '<List>', Text);
  DialogText := DialogText + #13#10;
  if Ship.GetCargoHook <> nil then Text := GetTranclucatorStorageText else Text := '';
  if Length(Text) > 0 then
  begin
    ExpandLocalizedTextMarkup(Text);
    DialogText := DialogText + FormatText1(LocalizedColorText('Talk.Tranclucator.Options.LandText'), '<color=255,240,100>', '<List>', Text);
  end
  else DialogText := DialogText + LocalizedColorText('Talk.Tranclucator.Options.LandBad');
  DialogText := DialogText + #13#10;
  Text := GetTranclucatorArrangeText;
  ExpandLocalizedTextMarkup(Text);
  DialogText := DialogText + Text;
  RememberChoiceScroll;
  ClearChoices(True);
  if Ship.GetCargoHook <> nil then
    for I := 1 to 6 do AddTranclucatorCollectionOption(I);
  if Ship.GetCargoHook <> nil then
    for I := 1 to 2 do AddTranclucatorStorageOption(I);
  AddTranclucatorArrangeOption;
  AddChoice('- ' + LocalizedColorText('Talk.Tranclucator.Options.PlayerBack'), 0, ShowGreeting, 0);
end;
{ @end $6DEE2C }

{ @routine $6DF2A4 TfTalk_OrderTranclucatorDropCargo }
procedure TfTalk.OrderTranclucatorDropCargo(Action: Integer);
var
  Ship: TTranclucator;
begin
  Ship := TalkShip as TTranclucator;
  Ship.FollowOwner := False;
  Ship.SeekItems := False;
  Ship.DropUnequippedItemsAndGoods;
  Ship.UpdateFreeFlightOrder;
  DialogText := TalkShip.LookupTalkText('Talk.Tranclucator.DropCargo.Ok');
  ClearChoices(False);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6DF2A4 }

{ @routine $6DF3F8 TfTalk_OrderTranclucatorLand }
procedure TfTalk.OrderTranclucatorLand(Action: Integer);
var
  Name: WideString;
  Ship: TTranclucator;
begin
  Ship := TalkShip as TTranclucator;
  Ship.FollowOwner := False;
  Ship.SeekItems := False;
  Ship.StoreOnLanding := False;
  Ship.OrderLanding(GetPlayer.OrderTarget, True);
  if GetPlayer.OrderTarget is TPlanet then Name := (GetPlayer.OrderTarget as TPlanet).Name
  else if GetPlayer.OrderTarget is TRuins then Name := (GetPlayer.OrderTarget as TRuins).GetColoredFullName('');
  DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Tranclucator.AgreeLandingToObject'), '<color=255,240,100>', '<ObjectName>', Name);
  ClearChoices(False);
  AddTranclucatorGroupChoice;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6DF3F8 }

{ @routine $6DF654 TfTalk_OrderTranclucatorStoreCargo }
procedure TfTalk.OrderTranclucatorStoreCargo(Action: Integer);
var
  Name: WideString;
  Ship: TTranclucator;
begin
  Ship := TalkShip as TTranclucator;
  Ship.FollowOwner := False;
  Ship.SeekItems := False;
  Ship.StoreOnLanding := True;
  Ship.OrderLanding(GetPlayer.OrderTarget, True);
  if GetPlayer.OrderTarget is TShip then Name := (GetPlayer.OrderTarget as TShip).Name
  else Name := (GetPlayer.OrderTarget as TPlanet).Name;
  DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Tranclucator.AgreeLandingToStorage'), '<color=255,240,100>', '<ObjectName>', Name);
  ClearChoices(False);
  AddTranclucatorGroupChoice;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6DF654 }

{ @routine $6DF898 TfTalk_AddTranclucatorGroupChoice }
procedure TfTalk.AddTranclucatorGroupChoice;
var
  Ship: TShip;
  I: Integer;
begin
  for I := 0 to TalkShip.CurrentStar.Ships.Count - 1 do
  begin
    Ship := TalkShip.CurrentStar.Ships[I];
    if (Ship is TTranclucator) and (Ship <> TalkShip) and ((Ship as TTranclucator).OwnerShip = GetPlayer) and Ship.InNormalSpace then
    begin
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Tranclucator.OrderForAll'), 0, ApplyOrderToAllTranclucators, 0);
      Break;
    end;
  end;
end;
{ @end $6DF898 }

{ @routine $6DF9F8 TfTalk_ApplyOrderToAllTranclucators }
procedure TfTalk.ApplyOrderToAllTranclucators(Action: Integer);
var
  Current, Target: TTranclucator;
  Ship: TShip;
  I: Integer;
begin
  Current := TalkShip as TTranclucator;
  for I := 0 to Current.CurrentStar.Ships.Count - 1 do
  begin
    Ship := Current.CurrentStar.Ships[I];
    if (Ship is TTranclucator) and (Ship <> Current) and ((Ship as TTranclucator).OwnerShip = GetPlayer) and Ship.InNormalSpace then
    begin
      Target := TTranclucator(Ship);
      Target.FollowOwner := Current.FollowOwner;
      Target.SeekItems := Current.SeekItems;
      Target.StoreOnLanding := Current.StoreOnLanding;
      Target.Order := Current.Order;
      Target.OrderStateData := Current.OrderStateData;
      Target.OrderTarget := Current.OrderTarget;
      Target.OrderDestination := Current.OrderDestination;
      Target.OrderAbsolute := Current.OrderAbsolute;
      if Current.OrderTarget = Current.EnemyShip then Target.EnemyShip := Current.EnemyShip;
      if Target.SeekItems then
      begin
        if Current.CargoFreeSpace > 0 then Target.TryCollectPreferredFloatingLoot(50)
        else Target.UpdateFreeFlightOrder;
      end;
    end;
  end;
  FastExit(0);
end;
{ @end $6DF9F8 }

{ @routine $6DFBB4 TfTalk_ShowPiratePartnerOffer }
procedure TfTalk.ShowPiratePartnerOffer(Action: Integer);
var
  Response: WideString;
begin
  if TalkShip.RelationToShip(GetPlayer) < 45 then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Pirate.Suspect');
    BuildStandardChoices(True);
  end
  else if TalkShip.PartnerShip <> nil then
  begin
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Pirate.AlreadyHavePartner'), '<color=255,240,100>', '<Partner>', (TalkShip.PartnerShip as TRanger).Name);
    BuildStandardChoices(True);
  end
  else if (GetPlayer.GetMaxPiratePartners <= GetPlayer.PiratePartners.Count) or
    (GetPlayer.GetEffectiveSkillLevel(psLeadership) <= GetPlayer.CountWingmen) or
    ((TalkShip is TPirate) and (TalkShip.OwnerId = oiPirate) and ((TalkShip as TPirate).PirateRank > GetPlayer.PirateRank)) then
  begin
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Pirate.NeedPirate'), '<color=255,240,100>', '<Ranger>', GetPlayer.Name);
    BuildStandardChoices(True);
  end
  else
  begin
    if TalkShip.BuildPartnershipOfferResponse(GetPlayer, Response, PartnerOfferAmount) then
      DialogText := FormatText2(TalkShip.LookupTalkText('Talk.Partner.ComputerSayOk'), '<color=255,240,100>',
        '<Money>', WideString(IntToStr(PartnerOfferAmount)), '<Month>', WideString(IntToStr(TalkShip.CalculatePartnershipMonths(PartnerOfferAmount, GetPlayer))))
    else DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Pirate.ComputerSayNo'), '<color=255,240,100>', '<Money>', WideString(IntToStr(PartnerOfferAmount)));
    ClearChoices(False);
    if TalkShip.BuildPartnershipOfferResponse(GetPlayer, Response, PartnerOfferAmount) then
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.PlayerOk'), 0, AcceptPiratePartnerOffer, 0);
    if PartnerOfferAmount div 2 > 0 then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.PlayerLess'), 0, HalvePiratePartnerOffer, 0);
    if GetPlayer.Money > PartnerOfferAmount then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.PlayerMore'), 0, DoublePiratePartnerOffer, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Cancel'), 0, ShowGreeting, 0);
  end;
end;
{ @end $6DFBB4 }

{ @routine $6E0278 TfTalk_AcceptPiratePartnerOffer }
procedure TfTalk.AcceptPiratePartnerOffer(Action: Integer);
begin
  if TalkShip.AcceptPartnershipOffer(GetPlayer, DialogText, PartnerOfferAmount) then
  begin
    SoundManager.PlaySound('Sound.Sell');
    GetPlayer.PiratePartners.Add(TalkShip);
  end;
  BuildStandardChoices(True);
end;
{ @end $6E0278 }

{ @routine $6E0304 TfTalk_HalvePiratePartnerOffer }
procedure TfTalk.HalvePiratePartnerOffer(Action: Integer);
begin
  PartnerOfferAmount := PartnerOfferAmount div 2;
  ShowPiratePartnerOffer(0);
end;
{ @end $6E0304 }

{ @routine $6E0330 TfTalk_DoublePiratePartnerOffer }
procedure TfTalk.DoublePiratePartnerOffer(Action: Integer);
begin
  if GetPlayer.Money < PartnerOfferAmount * 2 then PartnerOfferAmount := GetPlayer.Money
  else PartnerOfferAmount := PartnerOfferAmount * 2;
  ShowPiratePartnerOffer(0);
end;
{ @end $6E0330 }

{ @routine $6E0380 TfTalk_ShowPirateAttackTargets }
procedure TfTalk.ShowPirateAttackTargets(Action: Integer);
var
  I: Integer;
  Ship: TShip;
  RadarRangeSquared: Integer;
  ReservedFlag: Boolean;
  FollowMode: Byte;
begin
  DialogText := TalkShip.LookupTalkText('Talk.Pirate.AttackList');
  ClearChoices(False);
  ReservedFlag := False;
  FollowMode := Byte(ReservedFlag);
  RadarRangeSquared := GetPlayer.GetRadarRange * GetPlayer.GetRadarRange;
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if ((TalkShip.OrderTarget <> Ship) or (TalkShip.Order <> soFollowShip) or (TalkShip.OrderStateData = FollowMode)) and
      (GetPlayer <> Ship) and (TalkShip <> Ship) and (GetPlayer <> Ship.PartnerShip) and Ship.InNormalSpace then
      if (RadarRangeSquared > PointDistanceSquared(GetPlayer.Position, Ship.Position)) and not (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and
        ((Ship.OwnerId <> oiDominator) or ((TalkShip.OwnerId = oiPirate) and (Galaxy.CoalitionDefeatedTurn <> 0))) then
        AddChoice('- ' + Ship.GetFullName(' ') + GetLocalObjectLink(Ship, False), Integer(Ship), OrderPiratePartnerAttack, Integer(Ship));
  end;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.Back'), 0, ShowGreeting, 0);
end;
{ @end $6E0380 }

{ @routine $6E063C TfTalk_OrderPiratePartnerAttack }
procedure TfTalk.OrderPiratePartnerAttack(Action: Integer);
var
  Target: TShip;
begin
  Target := TShip(Action);
  TalkShip.SetJointAttackTarget(TalkShip, Target);
  DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Pirate.AttackShipOk'), '<color=255,240,100>', '<ShipName>', Target.GetFullName(' '));
  if GetPlayer.CountPartnersInNormalSpace > 1 then
  begin
    DialogText := DialogText + #13#10 + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.OrderForYou'), 0, ExitPartnerConversation, 0);
  end
  else
  begin
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end;
end;
{ @end $6E063C }

{ @routine $6E095C TfTalk_OrderPiratePartnerFollow }
procedure TfTalk.OrderPiratePartnerFollow(Action: Integer);
begin
  TalkShip.OrderFollowShip(GetPlayer, 0, True);
  DialogText := TalkShip.LookupTalkText('Talk.Pirate.ComputerAgreeFlyToMe');
  if GetPlayer.CountPartnersInNormalSpace > 1 then
  begin
    DialogText := DialogText + #13#10 + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.OrderForYou'), 0, ExitPartnerConversation, 0);
  end
  else
  begin
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end;
end;
{ @end $6E095C }

{ @routine $6E0C0C TfTalk_OrderPiratePartnerLand }
procedure TfTalk.OrderPiratePartnerLand(Action: Integer);
var
  Name: WideString;
  Relation: Byte;
begin
  if GetPlayer.OrderTarget is TRuins then
  begin
    Name := (GetPlayer.OrderTarget as TRuins).GetColoredFullName('');
    Relation := (GetPlayer.OrderTarget as TRuins).RelationToShip(TalkShip);
  end
  else
  begin
    Name := (GetPlayer.OrderTarget as TPlanet).Name;
    Relation := (GetPlayer.OrderTarget as TPlanet).RelationToShip(TalkShip);
  end;
  if Relation < RelationBadMin then
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Pirate.ComputerDisagreeLandingToObject'), '<color=255,240,100>', '<ObjectName>', Name)
  else
  begin
    TalkShip.OrderLanding(GetPlayer.OrderTarget, True);
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Pirate.ComputerAgreeLandingToObject'), '<color=255,240,100>', '<ObjectName>', Name);
  end;
  if GetPlayer.CountPartnersInNormalSpace > 1 then
  begin
    DialogText := DialogText + #13#10 + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.OrderForYou'), 0, ExitPartnerConversation, 0);
  end
  else
  begin
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
  end;
end;
{ @end $6E0C0C }

{ @routine $6E1088 TfTalk_OrderPiratePartnerJump }
procedure TfTalk.OrderPiratePartnerJump(Action: Integer);
begin
  if ((GetPlayer.OrderTarget as TStar).CountPlanetsByOwner(oiDominator) > 0) and
    ((TalkShip.OwnerId <> oiPirate) or (Galaxy.CoalitionDefeatedTurn = 0)) then
  begin
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Pirate.ComputerDisagreeFlyToStar'), '<color=255,240,100>', '<Star>',
      (GetPlayer.OrderTarget as TStar).Name);
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.Back'), 0, ShowGreeting, 0);
  end
  else
  begin
    TalkShip.OrderJump(GetPlayer.OrderTarget as TStar, True);
    DialogText := FormatText1(TalkShip.LookupTalkText('Talk.Pirate.ComputerAgreeFlyToStar'), '<color=255,240,100>', '<Star>',
      (GetPlayer.OrderTarget as TStar).Name);
    if GetPlayer.CountPartnersInNormalSpace > 1 then
    begin
      DialogText := DialogText + #13#10 + TalkShip.LookupTalkText('Talk.Partner.IsOrderForAll');
      ClearChoices(False);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.OrderForAll'), 0, ApplyOrderToAllPartners, 0);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.OrderForYou'), 0, ExitPartnerConversation, 0);
    end
    else
    begin
      ClearChoices(False);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
    end;
  end;
end;
{ @end $6E1088 }

{ @routine $6E1514 TfTalk_ShowPiratePartnerFinances }
procedure TfTalk.ShowPiratePartnerFinances(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.Pirate.FinancesReport');
  ReplaceTextToken(DialogText, '<Money>', WideString(IntToStr(TalkShip.Money)), '<color=255,240,100>');
  ClearChoices(False);
  if GetPlayer.Money > 0 then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.FinancesOfferGift'), 0, ShowPiratePartnerGift, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.FinancesConfirmed'), 0, ShowGreeting, 0);
end;
{ @end $6E1514 }

{ @routine $6E1768 TfTalk_ShowPiratePartnerGift }
procedure TfTalk.ShowPiratePartnerGift(Action: Integer);
var
  Text: WideString;
begin
  DialogText := TalkShip.LookupTalkText('Talk.Pirate.FinancesWaitForGift');
  ClearChoices(False);
  Text := '- ' + GetPlayer.LookupTalkText('Talk.Pirate.FinancesSendGift');
  ReplaceTextToken(Text, '<Money>', WideString(IntToStr(PartnerGiftAmount)), '<color=255,240,100>');
  AddChoice(Text, 0, GivePiratePartnerGift, 0);
  if PartnerGiftAmount div 2 > 0 then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.PlayerLess'), 0, HalvePiratePartnerGift, 0);
  if GetPlayer.Money > PartnerGiftAmount then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Pirate.PlayerMore'), 0, DoublePiratePartnerGift, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Cancel'), 0, ShowGreeting, 0);
end;
{ @end $6E1768 }

{ @routine $6E1A8C TfTalk_GivePiratePartnerGift }
procedure TfTalk.GivePiratePartnerGift(Action: Integer);
var
  Change: Integer;
begin
  SoundManager.PlaySound('Sound.Sell');
  if TalkShip is TNormalShip then
  Change := Round((150 * PartnerGiftAmount) / Max(1, TalkShip.Wealth + GetPlayer.Wealth) * PlanetRaceMarket[TalkShip.PilotRace].FriendlyRelationScale)
  else Change := Round((150 * PartnerGiftAmount) / Max(1, TalkShip.Wealth + GetPlayer.Wealth));
  Change := Max(0, Min(100, Change));
  TalkShip.ChangeRelationToRanger(GetPlayer, Change);
  GetPlayer.SetMoney(Max(0, GetPlayer.Money - PartnerGiftAmount));
  TalkShip.SetMoney(TalkShip.Money + PartnerGiftAmount);
  DialogText := TalkShip.LookupTalkText('Talk.Pirate.FinancesGotGift');
  ReplaceTextToken(DialogText, '<Money>', WideString(IntToStr(TalkShip.Money)), '<color=255,240,100>');
  BuildStandardChoices(True);
end;
{ @end $6E1A8C }

{ @routine $6E1D64 TfTalk_HalvePiratePartnerGift }
procedure TfTalk.HalvePiratePartnerGift(Action: Integer);
begin
  PartnerGiftAmount := PartnerGiftAmount div 2;
  ShowPiratePartnerGift(0);
end;
{ @end $6E1D64 }

{ @routine $6E1D90 TfTalk_DoublePiratePartnerGift }
procedure TfTalk.DoublePiratePartnerGift(Action: Integer);
begin
  PartnerGiftAmount := PartnerGiftAmount * 2;
  if GetPlayer.Money < PartnerGiftAmount then PartnerGiftAmount := GetPlayer.Money;
  ShowPiratePartnerGift(0);
end;
{ @end $6E1D90 }

{ @routine $6E1DDC TfTalk_ShowPartnerDismissal }
procedure TfTalk.ShowPartnerDismissal(Action: Integer);
var
  Prefix: WideString;
begin
  if TalkShip.TypeId = stPirate then Prefix := 'Pirate' else Prefix := 'Partner';
  DialogText := TalkShip.LookupTalkText('Talk.' + Prefix + '.ComputerDismissQuestion');
  ClearChoices(False);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.' + Prefix + '.PlayerDismissNo'), 1, ShipDismissAct, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.' + Prefix + '.PlayerDismissGood'), 2, ShipDismissAct, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.' + Prefix + '.PlayerDismissBad'), 3, ShipDismissAct, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6E1DDC }

{ @routine $6E20EC TfTalk_ShipDismissAct }
procedure TfTalk.ShipDismissAct(Action: Integer);
var
  Prefix: WideString;
begin
  if TalkShip.TypeId = stPirate then Prefix := 'Pirate' else Prefix := 'Partner';
  case Action of
    1: DialogText := TalkShip.LookupTalkText('Talk.' + Prefix + '.ComputerDismissNo');
    2:
    begin
      if (TalkShip.Order = soFollowShip) and (TalkShip.OrderTarget = TalkShip.PartnerShip) then TalkShip.OrderNone(False);
      TalkShip.PartnerShip := nil;
      DialogText := TalkShip.LookupTalkText('Talk.' + Prefix + '.ComputerDismissGood');
    end;
    3:
    begin
      TalkShip.PartnerShip := nil;
      TalkShip.ChangeRelationToRanger(GetPlayer, 10);
      TalkShip.EnemyShip := GetPlayer;
      TalkShip.EngageEnemyShip;
      DialogText := TalkShip.LookupTalkText('Talk.' + Prefix + '.ComputerDismissBad');
    end;
  else RaiseWideMessage(WideString('ShipDismissAct: invalid data = ' + IntToStr(Int64(Cardinal(Action)))));
  end;
  ClearChoices(False);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
end;
{ @end $6E20EC }

{ @routine $6E2464 TfTalk_RunDominatorProgram }
procedure TfTalk.RunDominatorProgram(Action: Integer);
var ProgramIndex: Byte; Remaining: Integer;
begin
  ProgramIndex := Action;
  Remaining := GetPlayer.ProgramCounts[ProgramIndex] - 1;
  GetPlayer.ProgramCounts[ProgramIndex] := Remaining;
  SysUtils.Sleep(1);
  if (GetPlayer.ProgramCounts[ProgramIndex] <> Remaining) and not GR_Main.CCInterface.GetTamperDetected then
    GR_Main.CCInterface.SetTamperDetected(True);
  if (TalkShip as TKling).KlingType in [ktBoss, ktBertor] then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.Dominator.ProgrammNo');
    (TalkShip as TKling).DetectAttackingPlayer(GetPlayer);
    ClearChoices(False);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
    Exit;
  end;

  DialogText := TalkShip.LookupTalkText('Talk.Dominator.ProgrammOk');
  ReplaceTextToken(DialogText, '<Name>', GetPlayer.GetProgramName(ProgramIndex), '<color=255,240,100>');
  (TalkShip as TKling).ActiveProgramAppliedTurn := Galaxy.CurrentTurn;
  (TalkShip as TKling).ActiveProgramId := ProgramIndex;
  Inc(GetPlayer.AchievementStats.SuccessfulDominatorHacks);
  TrySetAchievementProgress('HACKER', GetPlayer.AchievementStats.SuccessfulDominatorHacks);
  case (TalkShip as TKling).ActiveProgramId of
    prgShipwreck: TalkShip.DropItemsForDominatorProgram(SeededRandomIntRange(1, 3, Galaxy.CurrentTurn));
    prgSelfDestruction: TalkShip.DestroyQueued := True;
    prgDisconnection:
      begin
        TalkShip.OrderNone(False);
        TalkShip.ClearWeaponTargets(nil);
      end;
  end;
  (TalkShip as TKling).DetectAttackingPlayer(GetPlayer);
  BuildStandardChoices(True);
end;
{ @end $6E2464 }

{ @routine $6E2808 TfTalk_ShowDominatorGreeting }
procedure TfTalk.ShowDominatorGreeting(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.Dominator.Hi' + DominatorSeriesNames[Ord((TalkShip as TKling).DominatorSeries)]);
  BuildStandardChoices(True);
end;
{ @end $6E2808 }

{ @routine $6E28D4 TfTalk_ShowDominatorPeace }
procedure TfTalk.ShowDominatorPeace(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.Dominator.Peace' + DominatorSeriesNames[Ord((TalkShip as TKling).DominatorSeries)]);
  BuildStandardChoices(True);
end;
{ @end $6E28D4 }

{ @routine $6E29A8 TfTalk_ShowDominatorGoods }
procedure TfTalk.ShowDominatorGoods(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.Dominator.Goods' + DominatorSeriesNames[Ord((TalkShip as TKling).DominatorSeries)]);
  BuildStandardChoices(True);
end;
{ @end $6E29A8 }

{ @routine $6E2A7C TfTalk_ShowDominatorCommand }
procedure TfTalk.ShowDominatorCommand(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.Dominator.Command' + DominatorSeriesNames[Ord((TalkShip as TKling).DominatorSeries)]);
  BuildStandardChoices(True);
end;
{ @end $6E2A7C }

{ @routine $6E2B54 TfTalk_AddImmediateAttackChoices }
function TfTalk.AddImmediateAttackChoices: Boolean;
var I, J: Integer; Ship: TShip; RadarRangeSquared: Integer; Weapon: TWeapon;
begin
  Result := False;
  RadarRangeSquared := GetPlayer.GetRadarRange * GetPlayer.GetRadarRange;
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if not (Ship.TargetingRestriction in [1, 2]) then
      if (TalkShip.OrderTarget = Ship) and (TalkShip.GetRelationLevelToShip(Ship) = rlHostile) and
        ((GetPlayer.OrderTarget = Ship) or (PendingPlayerFollowTarget = Ship)) and
        (GetPlayer.GetRelationLevelToShip(Ship) = rlHostile) then Result := True
      else if (GetPlayer <> Ship) and (TalkShip <> Ship) and Ship.InNormalSpace and
        (RadarRangeSquared > PointDistanceSquared(GetPlayer.Position, Ship.Position)) then
      begin
        if (Ship.GetRelationLevelToShip(GetPlayer) = rlHostile) and
          (((GetPlayer = Ship.OrderTarget) and (Ship.TypeId <> stKling)) or (GetPlayer.OrderTarget = Ship)) then
        begin
          AddChoice('- ' + ReplaceColoredToken(GetPlayer.LookupTalkText('Talk.Attack.PlayerSend'), '<Target>', Ship.GetFullName(' '), '') + GetLocalObjectLink(Ship, False), Integer(Ship), RequestAttackTarget, 0);
          Result := True;
        end
        else if PendingPlayerFollowTarget = Ship then
        begin
          AddChoice('- ' + ReplaceColoredToken(GetPlayer.LookupTalkText('Talk.Attack.PlayerSend'), '<Target>', Ship.GetFullName(' '), '') + GetLocalObjectLink(Ship, False), Integer(Ship), RequestAttackTarget, 0);
          Result := True;
        end
        else
          for J := 1 to GetPlayer.WeaponCount do
          begin
            Weapon := GetPlayer.Weapons[J];
            if Weapon.Target = Ship then
            begin
              AddChoice('- ' + ReplaceColoredToken(GetPlayer.LookupTalkText('Talk.Attack.PlayerSend'), '<Target>', Ship.GetFullName(' '), '') + GetLocalObjectLink(Ship, False), Integer(Ship), RequestAttackTarget, 0);
              Result := True;
              Break;
            end;
          end;
      end;
  end;
end;
{ @end $6E2B54 }

{ @routine $6E2F3C TfTalk_GetShipGreeting }
function TfTalk.GetShipGreeting: WideString;
begin
  Result := TalkShip.GetGreetingText;
  if Result = '' then RaiseWideMessage('Не найдено приветствие корабля');
end;
{ @end $6E2F3C }

{ @routine $6E2FB8 TfTalk_RunInjectedAnswer }
procedure TfTalk.RunInjectedAnswer(Action: Integer);
var
  Text: WideString;
  Injection: PScriptDialogInjection;
  PartCount: Integer;
begin
  Injection := PScriptDialogInjection(Action);
  if Injection.ActionCode <> '' then
  begin
    CurrentScript := Injection.ActionScript;
    ExecuteScriptText(Injection.ActionCode, CurrentScript.InitCode.LocalVar);
  end;
  if Injection.DialogName = '' then FastExit(0)
  else
  begin
    Text := Injection.Answer;
    PartCount := CountDelimitedPartsW(Text, '~');
    if PartCount > 1 then
    begin
      Text := ExtractDelimitedPartW(WideString(LowerCase(AnsiString(Text))), 0, '~');
      if Text = 'snap' then RememberChoiceScroll;
    end;
    ClearChoices(False);
    Injection.Script.PublishCurrentShip(TalkShip);
    CurrentScript.InitCode.LocalVar.GetVar('GAnswerData').SetDword(Injection.AnswerData);
    CurrentScript.CallDialogByVariable(Injection.DialogName);
    if ScriptDialogIndex < 0 then BuildStandardChoices(False)
    else
    begin
      SkipShipScriptAdvance := True;
      CurrentScript.CallDialogMessage(ScriptDialogIndex);
    end;
  end;
end;
{ @end $6E2FB8 }

{ @routine $6E31A4 TfTalk_RunInjectedAnswerKeepingScroll }
procedure TfTalk.RunInjectedAnswerKeepingScroll(Action: Integer);
begin
  RememberChoiceScroll;
  RunInjectedAnswer(Action);
end;
{ @end $6E31A4 }

{ @routine $6E31C8 TfTalk_StartScriptMessage }
procedure TfTalk.StartScriptMessage(Script: TScript);
begin
  ClearChoices(False);
  CurrentScript := Script;
  CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $6E31C8 }

{ @routine $6E3200 TfTalk_BuildMilitarySupportChoices }
procedure TfTalk.BuildMilitarySupportChoices;
begin
  ClearChoices(True);
  case TalkShip.PilotRace of
    oiMaloc:
      begin
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendRepairHull'), 0, ShowMilitaryHullRepair, 0);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendGetBuff'), 0, ShowMilitaryBuff, 0);
      end;
    oiPeleng:
      begin
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendRepairHull'), 0, ShowMilitaryHullRepair, 0);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendSellRemains'), 0, ShowMilitaryRemains, 0);
      end;
    oiHuman:
      begin
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendSellRemains'), 0, ShowMilitaryRemains, 0);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendGetBuff'), 0, ShowMilitaryBuff, 0);
      end;
    oiFeyan:
      begin
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendRepairEq'), 0, ShowMilitaryEquipmentRepair, 0);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendSellRemains'), 0, ShowMilitaryRemains, 0);
      end;
    oiGaal:
      begin
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendRepairEq'), 0, ShowMilitaryEquipmentRepair, 0);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerSendGetBuff'), 0, ShowMilitaryBuff, 0);
      end;
  end;
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.Cancel'), 0, CancelMilitarySupport, 0);
end;
{ @end $6E3200 }

{ @routine $6E36B8 TfTalk_ShowMilitarySupport }
procedure TfTalk.ShowMilitarySupport(Action: Integer);
var Refused: Boolean;
begin
  Refused := True;
  if TalkShip.GetRelationLevelToShip(GetPlayer) <= rlHostile then
    DialogText := GetPlayer.LookupTalkText('Talk.MilitarySupport.RefuseEnemy')
  else if TalkShip.GetRelationLevelToShip(GetPlayer) <= rlNormal then
    DialogText := GetPlayer.LookupTalkText('Talk.MilitarySupport.RefuseWary')
  else if GetPlayer.CurrentStanding in [ssPiratePassive..ssPirateMilitary] then
    DialogText := GetPlayer.LookupTalkText('Talk.MilitarySupport.RefusePirate')
  else if PointDistance(GetPlayer.Position, TalkShip.Position) > 400 then
    DialogText := GetPlayer.LookupTalkText('Talk.MilitarySupport.RefuseDistance')
  else Refused := False;
  if Refused then BuildStandardChoices(True)
  else
  begin
    DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.Answer' + RaceToSys(TalkShip.PilotRace));
    ReplaceTextToken(DialogText, '<ShipName>', TalkShip.GetFullName(' '), '<color=255,240,100>');
    BuildMilitarySupportChoices;
  end;
end;
{ @end $6E36B8 }

{ @routine $6E3A44 TfTalk_CancelMilitarySupport }
procedure TfTalk.CancelMilitarySupport(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AfterCancel');
  BuildStandardChoices(True);
end;
{ @end $6E3A44 }

{ @routine $6E3AFC TfTalk_DeclineMilitarySupport }
procedure TfTalk.DeclineMilitarySupport(Action: Integer);
begin
  DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AfterNo');
  BuildMilitarySupportChoices;
end;
{ @end $6E3AFC }

{ @routine $6E3BA8 GetMilitaryHullRepairCost }
function GetMilitaryHullRepairCost: Integer;
begin
  Result := Ceil(((GetPlayer.GetHull.Weight - GetPlayer.GetHull.HullPoints) / 10) *
    (GetPlayer.GetCombatStatusStrength(cseBWRepairDebuff) * 0.002 + 1) *
    RemapClamped(Galaxy.TechLevel, 2, 8, 5, 1));
end;
{ @end $6E3BA8 }

{ @routine $6E3C68 TfTalk_ShowMilitaryHullRepair }
procedure TfTalk.ShowMilitaryHullRepair(Action: Integer);
var Cost, Available: Integer; Caption: WideString;
begin
  Cost := GetMilitaryHullRepairCost;
  if Cost <= 0 then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerNoNeedToRepairHull');
    BuildMilitarySupportChoices;
  end
  else
  begin
    Available := Min(Cost, GetPlayer.GetCarriedNodeCount);
    if Available > 0 then
    begin
      DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerRepairHull');
      ReplaceTextToken(DialogText, '<Nodes>', WideString(IntToStr(Cost)), '<color=255,240,100>');
      ClearChoices(True);
      if Available = Cost then Caption := GetPlayer.LookupTalkText('Talk.MilitarySupport.RepairHullOk')
      else Caption := GetPlayer.LookupTalkText('Talk.MilitarySupport.RepairHullPartialOk');
      AddChoice('- ' + Caption, Available, AcceptMilitaryHullRepair, 0);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerNo'), 0, DeclineMilitarySupport, 0);
    end
    else
    begin
      DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerRepairHullNoNodes');
      ReplaceTextToken(DialogText, '<Nodes>', WideString(IntToStr(Cost)), '<color=255,240,100>');
      BuildMilitarySupportChoices;
    end;
  end;
end;
{ @end $6E3C68 }

{ @routine $6E40D4 TfTalk_AcceptMilitaryHullRepair }
procedure TfTalk.AcceptMilitaryHullRepair(Action: Integer);
var Effect: TWeaponSE; RepairAmount: Integer; Fraction: Single;
begin
  GetPlayer.ConsumeAvailableNodes(Action, nil);
  Fraction := Action / GetMilitaryHullRepairCost;
  RepairAmount := Ceil(RemapClamped(Fraction, 0, 1, 0.01, GetPlayer.GetHull.Weight - GetPlayer.GetHull.HullPoints));
  Inc(GetPlayer.GetHull.HullPoints, RepairAmount);
  GetPlayer.AddCombatStatusStrength(cseBWRepairDebuff, RepairAmount, nil);
  GetPlayer.RefreshDerivedStats(True);
  Effect := TWeaponSE.Create('Weapon.NoGraph', Classes.Point(0, 0), 0, -1);
  Effect.SetEndpoints(GetPlayer.Graphic, GetPlayer.Graphic);
  // Multiplication by -1 retains the native DCC32 register copy before NEG.
  Effect.SetHit(OwnerToFilmColor(RaceToOwner(GetPlayer.PilotRace)), RepairAmount * -1, False, False);
  StarMapScreen.PendingSceneObjects.Add(Effect);
  SoundManager.PlaySound('Sound.Repair');
  DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AfterRepairHull');
  BuildMilitarySupportChoices;
end;
{ @end $6E40D4 }

{ @routine $6E4320 GetMilitaryEquipmentRepairCost }
function GetMilitaryEquipmentRepairCost: Integer;
var I: Integer; Item: TEquipment;
begin
  Result := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if ((not (Item is TWeapon)) or (TWeapon(Item).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) and
      (Item.ItemType <> t_Hull) and (Item.EquippedFlag <> 0) and
      TalkShip.CanRepairEquipmentTech(Item) and (Item.ConditionPercent < 90) then
      Inc(Result, Round(Item.CalculateRepairCost));
  end;
  if Result > 0 then
  begin
    Result := Round(Result * 0.0025 * RemapClamped(Galaxy.TechLevel, 2, 8, 5, 1));
    if Result = 0 then Result := 1;
  end;
end;
{ @end $6E4320 }

{ @routine $6E4458 TfTalk_ShowMilitaryEquipmentRepair }
procedure TfTalk.ShowMilitaryEquipmentRepair(Action: Integer);
var Cost, Available: Integer; Caption: WideString;
begin
  Cost := GetMilitaryEquipmentRepairCost;
  if Cost <= 0 then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerNoNeedToRepairEq');
    BuildMilitarySupportChoices;
  end
  else
  begin
    Available := Min(Cost, GetPlayer.GetCarriedNodeCount);
    if Available > 0 then
    begin
      DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerRepairEq');
      ReplaceTextToken(DialogText, '<Nodes>', WideString(IntToStr(Cost)), '<color=255,240,100>');
      ClearChoices(True);
      if Available = Cost then Caption := GetPlayer.LookupTalkText('Talk.MilitarySupport.RepairEqOk')
      else Caption := GetPlayer.LookupTalkText('Talk.MilitarySupport.RepairEqPartialOk');
      AddChoice('- ' + Caption, Available, AcceptMilitaryEquipmentRepair, 0);
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerNo'), 0, DeclineMilitarySupport, 0);
    end
    else
    begin
      DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerRepairEqNoNodes');
      ReplaceTextToken(DialogText, '<Nodes>', WideString(IntToStr(Cost)), '<color=255,240,100>');
      BuildMilitarySupportChoices;
    end;
  end;
end;
{ @end $6E4458 }

{ @routine $6E48B0 TfTalk_AcceptMilitaryEquipmentRepair }
procedure TfTalk.AcceptMilitaryEquipmentRepair(Action: Integer);
var Fraction: Single; I: Integer; Item: TEquipment;
begin
  Fraction := Action / GetMilitaryEquipmentRepairCost;
  GetPlayer.ConsumeAvailableNodes(Action, nil);
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if ((not (Item is TWeapon)) or (TWeapon(Item).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) and
      (Item.ItemType <> t_Hull) and (Item.EquippedFlag <> 0) and
      TalkShip.CanRepairEquipmentTech(Item) and (Item.ConditionPercent < 90) then
    begin
      Item.ConditionPercent := RemapClamped(Fraction, 0, 1, Item.ConditionPercent, 100);
      if Item.ConditionPercent > 0 then Item.BrokenFlag := 0;
    end;
  end;
  GetPlayer.RefreshDerivedStats(True);
  SoundManager.PlaySound('Sound.Repair');
  DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AfterRepairEq');
  BuildMilitarySupportChoices;
end;
{ @end $6E48B0 }

{ @routine $6E4ABC IsMilitaryProtectedQuestItem }
function IsMilitaryProtectedQuestItem(Item: TItem): Boolean;
var I: Integer; Quest: PQuest;
begin
  Result := False;
  if (Item is TUselessItem) and (Item.ScriptItem = nil) then
    for I := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[I];
      if Quest.QuestType = qtSendLetter then
        if LocalizedColorText(WideString('Quest.SendLetter.' + IntToStr(Quest.QuestNumber) + '.SysName')) =
          (Item as TUselessItem).ConfigBlockName then Result := True;
    end;
end;
{ @end $6E4ABC }

{ @routine $6E4C1C TfTalk_ShowMilitaryRemains }
procedure TfTalk.ShowMilitaryRemains(Action: Integer);
var I, Count, Cost: Integer; Item: TEquipment;
begin
  Count := 0;
  Cost := 0;
  for I := 1 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.OwnerId = oiDominator) and (Item is TUselessItem) and not IsMilitaryProtectedQuestItem(Item) then
    begin
      Inc(Count);
      if (Galaxy.DominatorResearch[Ord(Item.DominatorSeries)].Progress < 100) and
        Galaxy.IsDominatorSeriesUnresolved(Item.DominatorSeries) then
        Inc(Cost, Round(Item.Cost * 1.5))
      else Inc(Cost, Item.Cost);
    end;
  end;
  if Count <= 0 then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerNoRemains');
    BuildMilitarySupportChoices;
  end
  else
  begin
    DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerSellRemains');
    ReplaceTextToken(DialogText, '<Remains>', WideString(IntToStr(Count)), '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<Cost>', WideString(IntToStr(Cost)), '<color=255,240,100>');
    ClearChoices(True);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.SellRemainsSellAll'), 0, SellAllMilitaryRemains, 0);
    if Count > 1 then
      AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.SellRemainsSellSome'), 0, SellIndividualMilitaryRemains, 0);
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerNo'), 0, DeclineMilitarySupport, 0);
  end;
end;
{ @end $6E4C1C }

{ @routine $6E50D0 DonateMilitaryResearchMaterial }
procedure DonateMilitaryResearchMaterial(Series: TDominatorSeries; Amount: Integer);
var Other: TDominatorSeries; Count: Integer;
begin
  if (Galaxy.DominatorResearch[Ord(Series)].Progress < 100) and Galaxy.IsDominatorSeriesUnresolved(Series) then
    Inc(Galaxy.DominatorResearch[Ord(Series)].Material, Amount)
  else
  begin
    Count := 0;
    for Other := dsBlazer to dsTerron do
      if (Galaxy.DominatorResearch[Ord(Other)].Progress < 100) and Galaxy.IsDominatorSeriesUnresolved(Other) then
        Inc(Count);
    if Count <> 0 then
      for Other := dsBlazer to dsTerron do
        if (Galaxy.DominatorResearch[Ord(Other)].Progress < 100) and Galaxy.IsDominatorSeriesUnresolved(Other) then
          Inc(Galaxy.DominatorResearch[Ord(Other)].Material, Amount div Count);
  end;
end;
{ @end $6E50D0 }

{ @routine $6E51DC TfTalk_SellAllMilitaryRemains }
procedure TfTalk.SellAllMilitaryRemains(Action: Integer);
var I, Cost: Integer; Item: TEquipment;
begin
  Cost := 0;
  for I := GetPlayer.Inventory.Count - 1 downto 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.OwnerId = oiDominator) and (Item is TUselessItem) and not IsMilitaryProtectedQuestItem(Item) then
    begin
      GetPlayer.Inventory.Delete(I);
      if (Galaxy.DominatorResearch[Ord(Item.DominatorSeries)].Progress < 100) and
        Galaxy.IsDominatorSeriesUnresolved(Item.DominatorSeries) then
        Inc(Cost, Round(Item.Cost * 1.5))
      else Inc(Cost, Item.Cost);
      DonateMilitaryResearchMaterial(Item.DominatorSeries, Item.Weight);
      Item.Free;
    end;
  end;
  GetPlayer.SetMoney(GetPlayer.Money + Cost);
  SoundManager.PlaySound('Sound.Sell');
  DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AfterSellRemains');
  BuildMilitarySupportChoices;
end;
{ @end $6E51DC }

{ @routine $6E53E0 TfTalk_SellIndividualMilitaryRemains }
procedure TfTalk.SellIndividualMilitaryRemains(Action: Integer);
var I, Count, Cost: Integer; Item: TEquipment; Caption, BonusCaption: WideString;
begin
  if Action <> 0 then
  begin
    Item := TEquipment(Action);
    I := GetPlayer.Inventory.IndexOf(Item);
    if I >= 0 then
    begin
      GetPlayer.Inventory.Delete(I);
      if (Galaxy.DominatorResearch[Ord(Item.DominatorSeries)].Progress < 100) and
        Galaxy.IsDominatorSeriesUnresolved(Item.DominatorSeries) then Cost := Round(Item.Cost * 1.5)
      else Cost := Item.Cost;
      DonateMilitaryResearchMaterial(Item.DominatorSeries, Item.Weight);
      GetPlayer.SetMoney(GetPlayer.Money + Cost);
      SoundManager.PlaySound('Sound.Sell');
      Item.Free;
    end;
  end;
  DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerSellSomeRemains');
  ClearChoices(True);
  BonusCaption := ' ' + WrapTextInColor(LookupLocalizedTextOrEmpty('Talk.MilitarySupport.ItemsCool'), '<color=255,240,100>');
  Count := 0;
  for I := 1 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.OwnerId = oiDominator) and (Item is TUselessItem) and not IsMilitaryProtectedQuestItem(Item) then
    begin
      Inc(Count);
      if (Galaxy.DominatorResearch[Ord(Item.DominatorSeries)].Progress < 100) and
        Galaxy.IsDominatorSeriesUnresolved(Item.DominatorSeries) then Cost := Round(Item.Cost * 1.5)
      else Cost := Item.Cost;
      Caption := Item.GetDisplayName + ' (' + WrapTextInColor(WideString(IntToStr(Cost)), '<color=255,240,100>') + ' cr)';
      if (Galaxy.DominatorResearch[Ord(Item.DominatorSeries)].Progress < 100) and
        Galaxy.IsDominatorSeriesUnresolved(Item.DominatorSeries) then Caption := Caption + BonusCaption;
      AddChoice('- ' + Caption, Integer(Item), SellIndividualMilitaryRemains, 0);
      DialogText := DialogText + #13#10 + WideString(IntToStr(Count)) + ') ' + Caption;
    end;
  end;
  if Count <= 0 then
  begin
    DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AfterSellLastRemains');
    BuildMilitarySupportChoices;
  end
  else
    AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerNo'), 0, DeclineMilitarySupport, 0);
end;
{ @end $6E53E0 }

{ @routine $6E59A8 TfTalk_ShowMilitaryBuff }
procedure TfTalk.ShowMilitaryBuff(Action: Integer);
var Cost: Integer; Caption: WideString;
begin
  Cost := 100;
  DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AnswerBuff');
  ReplaceTextToken(DialogText, '<Nodes>', WideString(IntToStr(Cost)), '<color=255,240,100>');
  ClearChoices(True);
  if GetPlayer.GetCombatStatusStrength(cseBWBuff) > 0.01 then
    Caption := GetPlayer.LookupTalkText('Talk.MilitarySupport.BuffProlongateOk')
  else Caption := GetPlayer.LookupTalkText('Talk.MilitarySupport.BuffOk');
  if GetPlayer.GetCarriedNodeCount >= Cost then
    AddChoice('- ' + Caption, Cost, AcceptMilitaryBuff, 0)
  else AddChoice('- ' + Caption, 0, ScriptDialogBlockCallback, 0);
  AddChoice('- ' + GetPlayer.LookupTalkText('Talk.MilitarySupport.PlayerNo'), 0, DeclineMilitarySupport, 0);
end;
{ @end $6E59A8 }

{ @routine $6E5CBC TfTalk_AcceptMilitaryBuff }
procedure TfTalk.AcceptMilitaryBuff(Action: Integer);
begin
  GetPlayer.ConsumeAvailableNodes(Action, nil);
  SoundManager.PlaySound('Sound.Buy');
  if GetPlayer.GetCombatStatusStrength(cseBWBuff) > 0.01 then
    DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AfterBuffProlongate')
  else DialogText := TalkShip.LookupTalkText('Talk.MilitarySupport.AfterBuff');
  GetPlayer.AddCombatStatusStrength(cseBWBuff, 20, nil);
  GetPlayer.RefreshDerivedStats(True);
  BuildMilitarySupportChoices;
end;
{ @end $6E5CBC }

{ @routine $6E5E70 TfTalk_DiscussOldHull }
procedure TfTalk.DiscussOldHull(Action: Integer);
begin
  case Action of
    0:
      begin
        if GetPlayer = TalkShip.PartnerShip then
        begin
        DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswerP');
        ClearChoices(False);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend_1P'), 1, DiscussOldHull, 0);
        end
        else
        begin
        DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer');
        ClearChoices(False);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend_1'), 1, DiscussOldHull, 0);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend_2'), 2, DiscussOldHull, 0);
        end;
      end;
    1:
      begin
        if GetPlayer = TalkShip.PartnerShip then DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer_1P')
        else DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer_1');
        ClearChoices(False);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend_1_1'), 11, DiscussOldHull, 0);
      end;
    2:
      begin
        DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer_2');
        TalkShip.ChangeRelationToRanger(GetPlayer, -15);
        ClearChoices(False);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
      end;
    11:
      begin
        DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer_1_1');
        ClearChoices(False);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend_1_2'), 12, DiscussOldHull, 0);
      end;
    12:
      begin
        DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer_1_2');
        ClearChoices(False);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend_1_3'), 13, DiscussOldHull, 0);
      end;
    13:
      begin
        DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer_1_3');
        ClearChoices(False);
        if GetPlayer = TalkShip.PartnerShip then AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend_1_4P'), 14, DiscussOldHull, 0)
        else AddChoice('- ' + GetPlayer.LookupTalkText('Talk.ExTalk.OldHullPlayerSend_1_4'), 14, DiscussOldHull, 0);
      end;
    14:
      begin
        if GetPlayer = TalkShip.PartnerShip then DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer_1_4P')
        else DialogText := TalkShip.LookupTalkText('Talk.ExTalk.OldHullRangerAnswer_1_4');
        ClearChoices(False);
        AddChoice('- ' + GetPlayer.LookupTalkText('Talk.Exit'), 0, FastExit, 0);
      end;
  end;
end;
{ @end $6E5E70 }

{ @routine $6E6900 TfTalk_RunScriptRestartAnswer }
procedure TfTalk.RunScriptRestartAnswer(Action: Integer);
begin
  DialogText := '';
  CurrentScript.ExecuteDialogAnswer(Action);
  ScriptDialogIndex := -1;
  CodeMsgOut(False);
end;
{ @end $6E6900 }

{ @routine $6E6944 TfTalk_AddScriptRestartChoice }
procedure TfTalk.AddScriptRestartChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptRestartAnswer, 0);
end;
{ @end $6E6944 }

end.
