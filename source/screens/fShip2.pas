unit fShip2;
// Unit bracket (inferred): .text 0x006EFFE4..0x00713D11; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_CacheFont, aGalaxy, Classes, EC_BlockPar, GI_GAI, GI_GraphBuf, GI_GraphButton, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, GI_Window, GI_Zone, GR_Sound, Types, aItem, aNormalShip, aPlayer, aShip, fPanelMain;

type
  TArtefactSlotZones = array of TZoneGI;

  TPlayerHoldKind = (phkEmpty=0, phkGoods=1, phkEquipment=2, phkArtefact=3); // @size 0x4
  TPlayerHoldSort = (phsType=0, phsSize=1, phsPrice=2); // @size 0x4

  TPlayerHoldUnit = class(TObject) // @size 0x1C
  public
    Kind: TPlayerHoldKind; // @offset 0x04
    GoodsIndex: Byte; // @offset 0x08
    ItemId: Integer; // @offset 0x0C
    DisplayOrder: Integer; // @offset 0x10
    Item: TItem; // @offset 0x14
    Retained: Boolean; // @offset 0x18
    // Item is borrowed. Retained marks entries still present during a hold refresh.
  end;

  TfShip2 = class(TMessageLoopGIWithMainPanel) // @size 0x588
  public
    function CanUseLocalStorage: Boolean; // @addr $6F5A10 Native Self/result stack ordering establishes this as a method.
    function GetLocalStorageOwner: TObject; // @addr $6F5A70 Borrows the current planet or docked ship.
    function SlotToTip(SlotName: WideString): TItemType; // @addr 0x6F7FBC @note "Matches the second underscore-delimited component against eight equipment slot names; raises on no match."
    PlayServiceAnimations: Boolean; // @offset $D5 Restarts active hull/equipment repair animations on the next OnOpen.
    ReopenRequested: Boolean; // @offset $D4 Requests a background refresh and another ship-screen pass; OnOpen selects the script re-entry events.
    ItemInfoWindow: TWindowGI; // @offset 0xD8
    ItemImage: TImageGI; // @offset 0xDC
    ItemNameLabel: TLabelGI; // @offset 0xE0
    ItemDescriptionLabel: TLabelGI; // @offset 0xE4
    ItemSizeLabel: TLabelGI; // @offset 0xE8
    ItemPriceLabel: TLabelGI; // @offset 0xEC
    ItemRaceImage: TImageGI; // @offset 0xF0
    RightOpenImage: TImageGI; // @offset 0xF4
    SkillsPanel: TPanelGI; // @offset 0xF8
    FreeSkillPointsLabel: TLabelGI; // @offset 0xFC
    ExperienceLabel: TLabelGI; // @offset 0x100
    SkillImages: array[0..5] of TImageGI; // @offset 0x104
    SkillPanels: array[0..5] of TPanelGI; // @offset 0x14C
    SkillImageRestTop: array[0..5] of Integer; // @offset 0x164
    SkillButtons: array[0..5] of TGraphButtonGI; // @offset 0x17C
    SkillValueLabels: array[0..5] of TLabelGI; // @offset 0x194
    HoldSlotZones: array[0..5] of TZoneGI; // @offset 0x1DC
    BackgroundBuffer: TGraphBufGI; // @offset 0x338
    RewardsBuffer: TGraphBufGI; // @offset 0x340
    RewardsWindow: TWindowGI; // @offset $344 Verified by InitializeLayout assigning RewardWnd.
    SelectedHoldKind: TPlayerHoldKind; // @offset $34C Reset by the main menu's New handler.
    SelectedGoodsIndex: Byte; // @offset $350 Selected goods type.
    SelectedGoodsQuantity: Integer; // @offset $354 Selected goods quantity.
    SelectedGoodsCost: Integer; // @offset $358 Total purchase cost of the selected goods.
    ItemImageCenter: TPoint; // @offset $398 Used by the shared item/arena hover panels.
    ItemSizeLabelPosition: TPoint; // @offset $3A0 Offset from the information window's bottom.
    ItemPriceLabelPosition: TPoint; // @offset $3A8 Offset from the information window's bottom.
    ItemRaceImagePosition: TPoint; // @offset $3B0 Offset from the information window's bottom-right corner.
    SelectedHoldItem: TItem; // @offset $35C Selected equipment or artefact; nil for goods.

    PreserveSpaceMusic: Boolean; // @offset $3BD Suppresses space-music changes in SelectMusic.
    ShipStateChanged: Boolean; // @offset $3BC Accumulates changes across modal reopenings so callers refresh ship information and cargo controls.
    PropertyHintRightEdge: Integer; // @offset $47C Captured RankWnd left edge; the scanner positions its property window immediately to its left.
    ShipToInspect: TShip; // @offset $49C Native OnOpen selects this ship when non-nil.
    ShipLoopSound: TSoundBufferControl; // @offset $48C
    ScriptVideoStartedAt: Cardinal; // @offset $480
    ScriptVideoTimer: PCallbackTimerGI; // @offset $484
    RemoteHoldMode: Boolean; // @offset $4A4 ToggleRemoteHoldClicked switches between equipment/local cargo and the remote-hold panels.

    SkillImagesP: array[0..5] of TImageGI; // @offset $11C
    SkillImagesN: array[0..5] of TImageGI; // @offset $134
    SkillProgressImages: array[0..5] of TImageGI; // @offset $1AC
    SkillGainImages: array[0..5] of TImageGI; // @offset $1C4
    ExitButton: TGraphButtonGI; // @offset $33C
    PanelSlideWidth: Integer; // @offset $374
    RightPanelRestLeft: Integer; // @offset $378
    DestrPanelSlideWidth: Integer; // @offset $37C
    DestrPanelRestLeft: Integer; // @offset $380
    ShipImageCenter: TPoint; // @offset $390
    GateLeftRestLeft: Integer; // @offset $3DC
    GateRightRestLeft: Integer; // @offset $3E0
    UseLeftRestLeft: Integer; // @offset $3EC
    UseRightRestLeft: Integer; // @offset $3F0
    StorageImages: array[0..20] of TImageGI; // @offset $410
    StorageUpButton: TGraphButtonGI; // @offset $464
    StoragePanelSlideHeight: Integer; // @offset $470
    StoragePanelRestTop: Integer; // @offset $474
    SavedCaptainFrame: Integer; // @offset $494
    RemoteHoldVisible: Boolean; // @offset $498
    RemoteHoldImages: array[0..54] of TImageGI; // @offset $4A8

    HoldFirstIndex: Integer; // @offset $348
    HoldScrollTimer: PCallbackTimerGI; // @offset $488
    RemoteHoldFirstOrder: Integer; // @offset $584
    StorageSlideTimer: PCallbackTimerGI; // @offset $468
    GateSlideTimer: PCallbackTimerGI; // @offset $3D4
    UseSlideTimer: PCallbackTimerGI; // @offset $3E4
    StorageSlideOffset: Integer; // @offset $46C
    StorageFirstSlot: Integer; // @offset $478
    SavedShipExperience: Integer; // @offset $4A0
    NativeTimer384: PCallbackTimerGI; // @offset $384
    ItemInfoHideTimer: PCallbackTimerGI; // @offset $388
    PropertyInfoHideTimer: PCallbackTimerGI; // @offset $38C
    MoneyWarningTimer: PCallbackTimerGI; // @offset $3CC
    UsePanelSlideTimer: PCallbackTimerGI; // @offset $3F4
    SpecialSlot1Timer: PCallbackTimerGI; // @offset $404
    SpecialSlot2Timer: PCallbackTimerGI; // @offset $408
    SpecialSlot3Timer: PCallbackTimerGI; // @offset $40C
    RightPanelSlideTimer: PCallbackTimerGI; // @offset $36C
    GateSlideOffset: Integer; // @offset $3D8
    UseSlideOffset: Integer; // @offset $3E8
    constructor Create; // @addr 0x6F1284
    destructor Destroy; override; // @addr 0x6F132C
    procedure ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer); override; // @addr 0x71179C
    procedure OnOpen; override; // @addr 0x6F3078
    procedure OnClose; override; // @addr 0x6F552C
    procedure ProcessCallbackTimers; override; // @addr 0x71175C
    procedure SelectMusic; override; // @addr 0x7117F4
    procedure AdvanceScriptVideo(Timer: PCallbackTimerGI; UserData: Integer); // @addr $707490
    function StopScriptVideo: Boolean; // @addr $707548 Returns whether a video timer was active.
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x70248C
    procedure InitializeLayout; override; // @addr 0x6F136C
    procedure UpdateActionCursor(CanTake: Boolean); override; // @addr 0x6FCABC
    function GetActionParentLoop: TMessageLoopGI; override; // @addr 0x713C70
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x713C8C
    procedure LayoutItemInfo(Window: TWindowGI; Title, Text: TLabelGI; KeepMinimumHeight, WordWrap: Boolean; MinimumWidth: Integer); // @addr $70A9C4
    procedure LayoutObjectInfo(Window: TWindowGI; Title: TLabelGI; Left1, Right1, Left2, Right2, Left3, Right3, Left4, Right4, Left5, Right5, Left6, Right6, Left7, Right7, Left8, Right8: TLabelGI; Emblem: TObjectGI; KeepMinimumHeight: Boolean; MinimumWidth: Integer); // @addr $70AE84 Two-column planet/ship statistics, shared with live and recorded star-map panels.
    procedure CloseClicked(Sender: TObjectGI); // @addr $6F67F0 Checks integrity outside inspection mode, restores the return screen, closes and raises BreakUiMessage.
    procedure EnterBridgeClicked(Sender: TObjectGI); // @addr $713C1C Verified callback assignment in InitializeLayout.
    procedure HoldLeftReleased(Sender: TObjectGI); // @addr $7012EC Verified callback assignment in InitializeLayout.
    procedure HoldLeftPressed(Sender: TObjectGI); // @addr $70127C Verified callback assignment in InitializeLayout.
    procedure HoldRightReleased(Sender: TObjectGI); // @addr $701394 Verified callback assignment in InitializeLayout.
    procedure HoldRightPressed(Sender: TObjectGI); // @addr $701324 Verified callback assignment in InitializeLayout.
    function ConfigureChameleon: Boolean; // @addr $701030
    procedure MainKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $701D58
    procedure MainKeyUp(Sender: TObjectGI; Key: Cardinal); // @addr $702404 Verified callback assignment in InitializeLayout.
    procedure MainLeftButtonUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $702784 Verified callback assignment in InitializeLayout.
    procedure MainRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $7030CC Verified callback assignment in InitializeLayout.
    procedure GateMouseEnter(Sender: TObjectGI); // @addr $70D944 Verified callback assignment in InitializeLayout.
    procedure GateMouseLeave(Sender: TObjectGI); // @addr $70D9A0 Verified callback assignment in InitializeLayout.
    procedure GateMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $70DC0C Verified callback assignment in InitializeLayout.
    procedure UseMouseEnter(Sender: TObjectGI); // @addr $70DC40 Verified callback assignment in InitializeLayout.
    procedure UseMouseLeave(Sender: TObjectGI); // @addr $70DC70 Verified callback assignment in InitializeLayout.
    procedure DropSelectedInArcade; // @addr $705490 Transfers the selected cargo to arcade space, or destroys it in arcade view mode.
    procedure UseMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $707618 Verified callback assignment in InitializeLayout.
    procedure StorageUpClicked(Sender: TObjectGI); // @addr $70E9A4 Verified callback assignment in InitializeLayout.
    procedure StorageDownClicked(Sender: TObjectGI); // @addr $70E900 Verified callback assignment in InitializeLayout.
    procedure ToggleRemoteHoldClicked(Sender: TObjectGI); // @addr $711BEC Verified callback assignment in InitializeLayout.
    procedure RemoteHoldItemMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6FE338 Verified callback assignment in InitializeLayout.
    procedure SortRemoteHoldClicked(Sender: TObjectGI); // @addr $7120C8 Verified callback assignment in InitializeLayout.
    procedure RemoteHoldUpPressed(Sender: TObjectGI); // @addr $711DAC Verified callback assignment in InitializeLayout.
    procedure RemoteHoldUpReleased(Sender: TObjectGI); // @addr $711E44 Verified callback assignment in InitializeLayout.
    procedure RemoteHoldDownPressed(Sender: TObjectGI); // @addr $711E7C Verified callback assignment in InitializeLayout.
    procedure RemoteHoldDownReleased(Sender: TObjectGI); // @addr $711F24 Verified callback assignment in InitializeLayout.
    procedure StorageToShipClicked(Sender: TObjectGI); // @addr $7121D0 Verified callback assignment in InitializeLayout.
    procedure SellStorageClicked(Sender: TObjectGI); // @addr $712294
    procedure ShipToStorageClicked(Sender: TObjectGI); // @addr $7124F8 Verified callback assignment in InitializeLayout.
    procedure SortStorageByTypeClicked(Sender: TObjectGI); // @addr $7125B8 Verified callback assignment in InitializeLayout.
    procedure SortStorageBySizeClicked(Sender: TObjectGI); // @addr $7125DC Verified callback assignment in InitializeLayout.
    procedure SortStorageByPriceClicked(Sender: TObjectGI); // @addr $712604 Verified callback assignment in InitializeLayout.
    procedure LoadHoldRocketsClicked(Sender: TObjectGI); // @addr $71262C Verified callback assignment in InitializeLayout.
    procedure SellHoldClicked(Sender: TObjectGI); // @addr $712654 Verified callback assignment in InitializeLayout.
    procedure LoadEquippedRocketsClicked(Sender: TObjectGI); // @addr $71298C Verified callback assignment in InitializeLayout.
    procedure EquipmentConfigurationClicked(Sender: TObjectGI); // @addr $701D30 Verified callback assignment in InitializeLayout.
    procedure RefreshShipView; // @addr $6F86B0
    procedure ReturnSelectedHoldEntry; // @addr $7014B8
    procedure ScrollHoldTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $7013CC
    procedure ScrollRemoteHoldTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $711F5C
    function GetRemoteHoldScrollLimit: Integer; // @addr $712020
    procedure SlideStorageTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70EA48
    procedure OpenGate; // @addr $70D9B8
    procedure CloseGate; // @addr $70DA48
    procedure OpenUsePanel; // @addr $70DC88
    procedure CloseUsePanel; // @addr $70DD14
    procedure SlideGateTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70DAA0
    procedure SlideUseTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70DD6C
    procedure SortStorage(Sort: TPlayerHoldSort); // @addr $712CAC
    procedure RefreshStorageView; // @addr $70EB98
    procedure LoadRockets(Equipped: Boolean); // @addr $709350
    procedure SelectEquipmentConfiguration(Index: Integer); // @addr $701B78
    procedure ScrollStorageUp(Sender: TObjectGI); // @addr $70EE6C
    procedure ScrollStorageDown(Sender: TObjectGI); // @addr $70EEB4
    function IsHoldNormalShip: Boolean; // @addr $711B4C
    function CanUsePlayerExperience: Boolean; // @addr $711B70 Ruins with modernization sponsorship or a player-owned tranclucator.
    procedure StorageItemMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $70EF44
    procedure RefreshRewards(Ship: TNormalShip); // @addr $6F5ABC
    procedure RewardsMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6F6054
    procedure RewardsMouseLeave(Sender: TObjectGI); // @addr $6F61F8
    procedure ShowRewardTooltip(Ship: TNormalShip; Award: Integer); // @addr $6F6210
    procedure HideRewardTooltip; // @addr $6F6674
    procedure SlideRightPanelTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $6F669C
    procedure RewardsMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6F6854
    procedure UpdateInfoHint(First, Second: Integer); // @addr $6F7FA8 Native empty three-register method; argument purposes unresolved.
    RightPanelSlideStep: Integer; // @offset $370
    UsePanelSlideOffset: Integer; // @offset $3F8
    SelectedReward: Integer; // @offset $3C0
    procedure ShipNameMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6F6974
    procedure RefreshEquipmentConfigurationButtons; // @addr $701A5C
    procedure SlideUsePanelTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70DF90
    procedure SpecialSlot1Clicked(Sender: TObjectGI); // @addr $705B10
    procedure OpenSpecialSlot1; // @addr $70E0A8
    procedure CloseSpecialSlot1; // @addr $70E180
    procedure AnimateSpecialSlot1(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70E220
    procedure SpecialSlot2Clicked(Sender: TObjectGI); // @addr $706600
    procedure OpenSpecialSlot2; // @addr $70E370
    procedure CloseSpecialSlot2; // @addr $70E448
    procedure AnimateSpecialSlot2(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70E4E8
    procedure SpecialSlot3Clicked(Sender: TObjectGI); // @addr $707BC4
    procedure OpenSpecialSlot3; // @addr $70E638
    procedure CloseSpecialSlot3; // @addr $70E710
    procedure AnimateSpecialSlot3(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70E7B0
    SelectedHoldOrigin: Integer; // @offset $360 Zero is ship inventory; nonzero returns to local storage.
    SelectedHoldSlot: Integer; // @offset $364 Original hold/storage index; negative values encode equipment slots as -slot-1.
    SelectedHoldUsesDisplayOrder: Boolean; // @offset $368 Interpret SelectedHoldSlot as a persistent display order.
    function IsCompatibleSlot(ItemType, SlotType: TItemType): Boolean; // @addr $6F808C
    procedure RefreshActionPanels(Kind: TPlayerHoldKind; Good: Byte; Quantity, Cost: Integer; Item: TItem; Origin: Integer); // @addr $6FBB30
    EquipmentSlotZones: array[0..7,0..4] of TZoneGI; // @offset $1F4 Five slots per equipment category.
    EquipmentSlotAnimations: array[0..7,0..4] of TgaiGI; // @offset $294 Five slots per equipment category.
    procedure RefreshEquipmentSlotControls; // @addr $6F80C8
    procedure ShowShipPropertyInfo(Sender: TObjectGI); // @addr $6F6AC8
    procedure TrainSkillClicked(Sender: TObjectGI); // @addr $6FCCA4
    procedure RepairAllClicked(Sender: TObjectGI); // @addr $708854
    HighlightRepairableEquipment: Boolean; // @offset $490
    procedure RepairAllMouseEnter(Sender: TObjectGI); // @addr $7092BC
    procedure RepairAllMouseLeave(Sender: TObjectGI); // @addr $70932C
    DisplayedItemKey: Integer; // @offset $3B8 Zero for no item, Good+1 for hold goods, or an item pointer for equipment/storage.
    procedure HideItemInfo(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70A8F0
    MoneyWarningVisible: Boolean; // @offset $3C4
    MoneyWarningTicks: Integer; // @offset $3C8
    procedure HideShipPropertyInfo(Sender: TObjectGI); // @addr $6F7F70
    procedure ToggleAfterburner(Sender: TObjectGI); // @addr $709D28
    procedure ShowItemInfo; // @addr $709ED8
    procedure ShowItemInfoTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70A8C8
    procedure RefreshMoneyWarning; // @addr $70D5F8
    procedure StartMoneyWarning; // @addr $70D748
    procedure AdvanceMoneyWarning(Timer: PCallbackTimerGI; UserData: Integer); // @addr $70D7C0
    procedure ShowNoDropMessage(Code: Integer); // @addr $70D824
    procedure DropSelectedOutside(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $7042EC
    procedure OpenUseSidePanel; // @addr $70DED4
    procedure CloseUseSidePanel; // @addr $70DF38
    procedure HideSender(Sender: TObjectGI); // @addr $711740
    procedure RefreshLoadEquippedRocketsButton; // @addr $712E7C
    function TryDeployTranclucator(Ship: TShip): Boolean; // @addr $7041B8
    function CreateShipInfoImage(Sender: TLabelGI; Item: PFontObjectEC): TObjectGI; // @addr $70FBC8
    procedure SellAllItems(Origin: Integer); // @addr $71331C Zero sells hold contents; one sells local storage.
    procedure TakeHoldEntry(Entry: TPlayerHoldUnit; Slot: Integer; UsesDisplayOrder: Boolean); // @addr $700548
    procedure HullMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $700750
    procedure EquipmentSlotMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6FCE0C
    procedure ArtefactSlotMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6FDC50
    procedure UseOnArtefactSlot(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6FDF68
    ArtefactSlotZones: array of TZoneGI; // @offset $334 Dynamically sized to the ship's artefact slot count.
    HoveredEquipmentAnimation: TgaiGI; // @offset $3D0
    procedure ShowEquipmentInfo(Item: TItem; FromStorage: Boolean); // @addr $70B1A0
    procedure ShowHoldGoodsInfo(Good: Byte); // @addr $70C680
    procedure ShowStoredGoodsInfo(Goods: TGoods); // @addr $70CF50
    procedure BuildAdditionalInfoPanel; // @addr 0x7100F4
  end;

function RunShipEquipment(ParentLoop: TMessageLoopGI): Boolean; // @addr $7120F0

function CompareStoredItems(Left, Right: PStorageEntry; Sort: TPlayerHoldSort): Integer; // @addr $712A10

function RankToImage(Rank: Byte): WideString; // @addr $6F0130

function RankToImageSmall(Rank: Byte): WideString; // @addr $6F0258

function PirateRankToImage(Rank: Byte): WideString; // @addr $6F038C

function PirateRankToImageSmall(Rank: Byte): WideString; // @addr $6F04D0

procedure InitializePlayerHoldView; // @addr 0x6F0638
procedure FinalizePlayerHoldView; // @addr 0x6F0650
procedure RefreshPlayerHoldView(IncludeFilteredItems: Boolean); // @addr 0x6F0670 @note "Uses PlayerHoldShip, or the player when nil; preserves display order."
procedure RemoveEmptyPlayerHoldSlot(Index: Integer); // @addr 0x6F0B58
procedure ClearPlayerHoldEntries; // @addr 0x6F0BA8
procedure RemoveEmptyPlayerHoldSlots; // @addr 0x6F0BFC
function IsPlayerHoldSlotEmpty(Index: Integer): Boolean; // @addr 0x6F0C58 @note "Returns true for out-of-range indices as well as empty slots."
function ComparePlayerHoldEntries(Left, Right: TPlayerHoldUnit; Sort: TPlayerHoldSort): Integer; // @addr 0x6F0C9C @note "Ascending order; goods prices are total purchase costs, not unit prices."
procedure SortPlayerHoldEntries(Sort: TPlayerHoldSort); // @addr 0x6F0FB0
procedure RestorePlayerHoldDisplayOrder; // @addr 0x6F10E0
function FindPlayerHoldIndexByOrder(DisplayOrder: Integer): Integer; // @addr 0x6F11B8 @note "Returns -1 when absent."
function FindFreePlayerHoldOrder: Integer; // @addr 0x6F121C

var
  StorageImageCount: Integer = 21; // @addr $87C000
  PlayerHoldEntries: TList = nil; // @addr 0x87C004
  PlayerHoldShip: TShip = nil; // @addr 0x87C008

implementation

// @unit-initialization $87797C
// @unit-finalization $713D14

uses aAsteroid, aMissile, aRanger, SE_Ruins, SE_Weapon, aEFilmEnd, ab_Item, ab_Ship, GI_Tail, ab_Global, SE_Space, fChameleon, aKling, aGalaxyEvent, fHangar, GI_MessageBox, fTextBox, GR_GraphBuf, GR_gi, fRewards, aPlanet, aGalaxy, aConst, aScript, aMyFunction, ThreadCalc, SysUtils, Messages, fStarMap, aTranclucator, aRuins, aGalaxyStruct, fEquipmentShop, GI_PanelScrollBar, GI_ScrollBar, EC_Struct, EC_Str, Globals, GlobalsV, GR_Main, GR_Music, Math, GI_Main, GI_XviD, Windows, MMSystem;

var
  SelfSkillPointColor: Cardinal; // @addr $88B0DC
  OtherSkillPointColor: Cardinal; // @addr $88B0E0

{ @routine $6F0130 RankToImage }
function RankToImage(Rank: Byte): WideString;
begin
  if Rank in [0..7] then
    Result := 'GI,Bm.FormRating2.2Rank' + IntToStr(Integer(Rank) + 1)
  else
    RaiseWideMessage('No image for rank in function RankToImage(tr:TRank):WideString;');
end;
{ @end $6F0130 }

{ @routine $6F0258 RankToImageSmall }
function RankToImageSmall(Rank: Byte): WideString;
begin
  if Rank in [0..7] then
    Result := 'GI,Bm.FormShip2.2Rank' + IntToStr(Integer(Rank) + 1)
  else
    RaiseWideMessage('No image for rank in function RankToImageSmall(tr:TRank):WideString;');
end;
{ @end $6F0258 }

{ @routine $6F038C PirateRankToImage }
function PirateRankToImage(Rank: Byte): WideString;
begin
  if Rank in [0..7] then
    Result := 'GI,Bm.FormShip2.PRank' + IntToStr(Integer(Rank) + 1)
  else
    RaiseWideMessage('No image for rank in function PirateRankToImage(tr: TPirateRank): WideString;');
end;
{ @end $6F038C }

{ @routine $6F04D0 PirateRankToImageSmall }
function PirateRankToImageSmall(Rank: Byte): WideString;
begin
  if Rank in [0..7] then
    Result := 'GI,Bm.FormShip2.PRank' + IntToStr(Integer(Rank) + 1) + 's'
  else
    RaiseWideMessage('No image for rank in function PirateRankToImageSmall(tr: TPirateRank): WideString;');
end;
{ @end $6F04D0 }

{ @routine $6F0638 InitializePlayerHoldView }
procedure InitializePlayerHoldView;
begin
  FinalizePlayerHoldView;
  PlayerHoldEntries := TList.Create;
end;
{ @end $6F0638 }

{ @routine $6F0650 FinalizePlayerHoldView }
procedure FinalizePlayerHoldView;
begin
  if PlayerHoldEntries <> nil then
  begin
    ClearPlayerHoldEntries;
    PlayerHoldEntries.Free;
    PlayerHoldEntries := nil;
  end;
end;
{ @end $6F0650 }

{ @routine $6F0670 RefreshPlayerHoldView }
procedure RefreshPlayerHoldView(IncludeFilteredItems: Boolean);
var Ship: TShip; Goods: Byte; Entry, Other: TPlayerHoldUnit; I, J, Order: Integer; Item: TEquipment;
begin
  if PlayerHoldEntries = nil then InitializePlayerHoldView;
  if PlayerHoldShip <> nil then Ship := PlayerHoldShip else Ship := GetPlayer;
  for I := 0 to PlayerHoldEntries.Count - 1 do
  begin
    Entry := PlayerHoldEntries[I];
    Entry.Retained := Entry.Kind = phkEmpty;
  end;
  for Goods := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    if not IncludeFilteredItems then
      if not GetPlayer.CanAccessHoldGoods(Goods) then Continue;
    if Ship.CargoGoods[Goods].Count > 0 then
    begin
      I := 0;
      while I < PlayerHoldEntries.Count do
      begin
        Entry := PlayerHoldEntries[I];
        if not Entry.Retained and (Entry.Kind = phkGoods) and (Entry.GoodsIndex = Goods) then
        begin
          Entry.Retained := True;
          Break;
        end;
        Inc(I);
      end;
      if I >= PlayerHoldEntries.Count then
      begin
        Entry := TPlayerHoldUnit.Create;
        PlayerHoldEntries.Insert(0, Entry);
        Entry.Kind := phkGoods;
        Entry.GoodsIndex := Goods;
        Entry.Retained := True;
      end;
    end;
  end;
  for J := 0 to Ship.Inventory.Count - 1 do
  begin
    Item := TEquipment(Ship.Inventory[J]);
    if (Item.EquippedFlag = 0) and (Ship.GetHull <> Item) then
    begin
      if IncludeFilteredItems or GetPlayer.CanAccessStoredItem(Item) then
      begin
        I := 0;
        while I < PlayerHoldEntries.Count do
        begin
          Entry := PlayerHoldEntries[I];
          if not Entry.Retained and (Entry.Kind = phkEquipment) and (Item.Id = Entry.ItemId) then
          begin
            Entry.Retained := True;
            Entry.Item := Item;
            Break;
          end;
          Inc(I);
        end;
        if I >= PlayerHoldEntries.Count then
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
          Entry.Kind := phkEquipment;
          Entry.ItemId := Item.Id;
          Entry.Item := Item;
          Entry.Retained := True;
        end;
      end;
    end;
  end;
  for J := 0 to Ship.Artefacts.Count - 1 do
  begin
    Item := TEquipment(Ship.Artefacts[J]);
    if Item.EquippedFlag = 0 then
    begin
      if IncludeFilteredItems or GetPlayer.CanAccessStoredItem(Item) then
      begin
        I := 0;
        while I < PlayerHoldEntries.Count do
        begin
          Entry := PlayerHoldEntries[I];
          if not Entry.Retained and (Entry.Kind = phkArtefact) and (Item.Id = Entry.ItemId) then
          begin
            Entry.Retained := True;
            Entry.Item := Item;
            Break;
          end;
          Inc(I);
        end;
        if I >= PlayerHoldEntries.Count then
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
          Entry.Kind := phkArtefact;
          Entry.ItemId := Item.Id;
          Entry.Item := Item;
          Entry.Retained := True;
        end;
      end;
    end;
  end;
  I := PlayerHoldEntries.Count - 1;
  while I >= 0 do
  begin
    Entry := PlayerHoldEntries[I];
    if Entry.Kind <> phkEmpty then Break;
    Entry.Retained := False;
    Dec(I);
  end;
  I := 0;
  while I < PlayerHoldEntries.Count do
  begin
    Entry := PlayerHoldEntries[I];
    if not Entry.Retained then
    begin
      PlayerHoldEntries.Delete(I);
      Entry.Free;
    end else Inc(I);
  end;
  Order := 0;
  for I := 1 to PlayerHoldEntries.Count - 1 do
  begin
    Entry := PlayerHoldEntries[I];
    if Entry.Kind = phkEmpty then Continue;
    J := 0;
    while J < I do
    begin
      Other := PlayerHoldEntries[J];
      if (Other.Kind <> phkEmpty) and (Other.DisplayOrder = Entry.DisplayOrder) then Break;
      Inc(J);
    end;
    if J < I then
    begin
      while True do
      begin
        J := 0;
        while J < PlayerHoldEntries.Count do
        begin
          Other := PlayerHoldEntries[J];
          if Other.Kind <> phkEmpty then
            if Other.DisplayOrder = Order then Break;
          Inc(J);
        end;
        if J >= PlayerHoldEntries.Count then Break;
        Inc(Order);
      end;
      Entry.DisplayOrder := Order;
      Inc(Order);
    end;
  end;
end;
{ @end $6F0670 }

{ @routine $6F0B58 RemoveEmptyPlayerHoldSlot }
procedure RemoveEmptyPlayerHoldSlot(Index: Integer);
var Entry: TPlayerHoldUnit;
begin
  if (Index < 0) or (Index >= PlayerHoldEntries.Count) then Exit;
  Entry := PlayerHoldEntries[Index];
  if Entry.Kind = phkEmpty then
  begin
    PlayerHoldEntries.Delete(Index);
    Entry.Free;
  end;
end;
{ @end $6F0B58 }

{ @routine $6F0BA8 ClearPlayerHoldEntries }
procedure ClearPlayerHoldEntries;
var I: Integer; Entry: TPlayerHoldUnit;
begin
  if PlayerHoldEntries = nil then Exit;
  for I := PlayerHoldEntries.Count - 1 downto 0 do
  begin
    Entry := PlayerHoldEntries[I];

    begin
      PlayerHoldEntries.Delete(I);
      Entry.Free;
    end;
  end;
end;
{ @end $6F0BA8 }

{ @routine $6F0BFC RemoveEmptyPlayerHoldSlots }
procedure RemoveEmptyPlayerHoldSlots;
var I: Integer; Entry: TPlayerHoldUnit;
begin
  if PlayerHoldEntries = nil then Exit;
  for I := PlayerHoldEntries.Count - 1 downto 0 do
  begin
    Entry := PlayerHoldEntries[I];
    if Entry.Kind = phkEmpty then
    begin
      PlayerHoldEntries.Delete(I);
      Entry.Free;
    end;
  end;
end;
{ @end $6F0BFC }

{ @routine $6F0C58 IsPlayerHoldSlotEmpty }
function IsPlayerHoldSlotEmpty(Index: Integer): Boolean;
var Entry: TPlayerHoldUnit;
begin
  Result := True;
  if (Index < 0) or (Index >= PlayerHoldEntries.Count) then Exit;
  Entry := PlayerHoldEntries[Index];
  Result := Entry.Kind = phkEmpty;
end;
{ @end $6F0C58 }

{ @routine $6F0C9C ComparePlayerHoldEntries }
function ComparePlayerHoldEntries(Left, Right: TPlayerHoldUnit; Sort: TPlayerHoldSort): Integer;
var LeftValue, RightValue: Integer; LeftType, RightType: Byte; LeftName, RightName: WideString; NameComparison: Integer;
begin
  Result := 0;
  if Sort = phsType then
  begin
    if Integer(Left.Kind) < Integer(Right.Kind) then begin Result := -1; Exit end;
    if Integer(Left.Kind) > Integer(Right.Kind) then begin Result := 1; Exit end;
    if Left.Kind = phkGoods then LeftType := Left.GoodsIndex else LeftType := Byte(Left.Item.ItemType);
    if Right.Kind = phkGoods then RightType := Right.GoodsIndex else RightType := Byte(Right.Item.ItemType);
    if Integer(LeftType) < Integer(RightType) then begin Result := -1; Exit end;
    if Integer(LeftType) > Integer(RightType) then begin Result := 1; Exit end;
    if (Left.Kind in [phkEquipment, phkArtefact]) and (Right.Kind in [phkEquipment, phkArtefact]) and (Left.Item <> nil) and (Right.Item <> nil) then
    begin
      if (Left.Item.ItemType = t_MicroModule) and (Right.Item.ItemType = t_MicroModule) then
      begin
        LeftValue := GetMicroModulePriorityColorTier((Left.Item as TMicroModule).MicroModuleIndex - 1);
        RightValue := GetMicroModulePriorityColorTier((Right.Item as TMicroModule).MicroModuleIndex - 1);
        if LeftValue < RightValue then begin Result := -1; Exit end;
        if LeftValue > RightValue then begin Result := 1; Exit end;
      end;
      LeftName := Left.Item.GetDisplayName;
      RightName := Right.Item.GetDisplayName;
      NameComparison := CompareWideChars(PWideChar(LeftName), PWideChar(RightName));
      if NameComparison <> 0 then begin Result := NameComparison; Exit end;
    end;
  end;
  if Integer(Sort) <= Integer(phsSize) then
  begin
    if Left.Kind = phkGoods then LeftValue := PlayerHoldShip.CargoGoods[Left.GoodsIndex].Count else LeftValue := Left.Item.Weight;
    if Right.Kind = phkGoods then RightValue := PlayerHoldShip.CargoGoods[Right.GoodsIndex].Count else RightValue := Right.Item.Weight;
    if LeftValue < RightValue then begin Result := -1; Exit end;
    if LeftValue > RightValue then begin Result := 1; Exit end;
  end;
  if Left.Kind = phkGoods then LeftValue := PlayerHoldShip.CargoGoods[Left.GoodsIndex].TotalCost else LeftValue := Left.Item.Cost;
  if Right.Kind = phkGoods then RightValue := PlayerHoldShip.CargoGoods[Right.GoodsIndex].TotalCost else RightValue := Right.Item.Cost;
  if LeftValue < RightValue then begin Result := -1; Exit end;
  if LeftValue > RightValue then begin Result := 1; Exit end;
end;
{ @end $6F0C9C }

{ @routine $6F0FB0 SortPlayerHoldEntries }
procedure SortPlayerHoldEntries(Sort: TPlayerHoldSort);
var I, J: Integer; Entry: TPlayerHoldUnit;
begin
  Galaxy.CheckIntegrityChecksum1(413);
  RemoveEmptyPlayerHoldSlots;
  for I := 0 to PlayerHoldEntries.Count - 2 do
    for J := I + 1 to PlayerHoldEntries.Count - 1 do
      if ComparePlayerHoldEntries(PlayerHoldEntries[I], PlayerHoldEntries[J], Sort) > 0 then
      begin
        Entry := PlayerHoldEntries[I];
        PlayerHoldEntries[I] := PlayerHoldEntries[J];
        PlayerHoldEntries[J] := Entry;
      end;
  J := 0;
  for I := 0 to PlayerHoldEntries.Count - 1 do
  begin
    Entry := PlayerHoldEntries[I];
    if Entry.Kind <> phkEmpty then
    begin
      Entry.DisplayOrder := J;
      Inc(J);
    end;
  end;
  Galaxy.PrimeIntegrityChecksum1(414);
end;
{ @end $6F0FB0 }

{ @routine $6F10E0 RestorePlayerHoldDisplayOrder }
procedure RestorePlayerHoldDisplayOrder;
var I, J: Integer; Entry: TPlayerHoldUnit;
begin
  for I := PlayerHoldEntries.Count - 1 downto 0 do RemoveEmptyPlayerHoldSlot(I);
  for I := 0 to PlayerHoldEntries.Count - 2 do
    for J := I + 1 to PlayerHoldEntries.Count - 1 do
      if TPlayerHoldUnit(PlayerHoldEntries[I]).DisplayOrder > TPlayerHoldUnit(PlayerHoldEntries[J]).DisplayOrder then
      begin
        Entry := PlayerHoldEntries[I];
        PlayerHoldEntries[I] := PlayerHoldEntries[J];
        PlayerHoldEntries[J] := Entry;
      end;
end;
{ @end $6F10E0 }

{ @routine $6F11B8 FindPlayerHoldIndexByOrder }
function FindPlayerHoldIndexByOrder(DisplayOrder: Integer): Integer;
var I: Integer; Entry: TPlayerHoldUnit;
begin
  for I := 0 to PlayerHoldEntries.Count - 1 do
  begin
    Entry := PlayerHoldEntries[I];
    if Entry.Kind <> phkEmpty then
      if Entry.DisplayOrder = DisplayOrder then
      begin
        Result := I;
        Exit;
      end;
  end;
  Result := -1;
end;
{ @end $6F11B8 }

{ @routine $6F121C FindFreePlayerHoldOrder }
function FindFreePlayerHoldOrder: Integer;
var Order, I: Integer; Entry: TPlayerHoldUnit;
begin
  Order := 0;
  while True do
  begin
    I := 0;
    while I < PlayerHoldEntries.Count do
    begin
      Entry := PlayerHoldEntries[I];
      if Entry.Kind <> phkEmpty then
        if Entry.DisplayOrder = Order then Break;
      Inc(I);
    end;
    if I >= PlayerHoldEntries.Count then
    begin
      Result := Order;
      Exit;
    end;
    Inc(Order);
  end;
end;
{ @end $6F121C }

{ @routine $6F1284 TfShip2_Create }
constructor TfShip2.Create;
begin
  inherited Create;
  ShipLoopSound := TSoundBufferControl.Create;
  ShipLoopSound.Configure('Sound.ShipLoop', 0, True);
  ShipToInspect := nil;
  RemoteHoldMode := False;
end;
{ @end $6F1284 }

{ @routine $6F132C TfShip2_Destroy }
destructor TfShip2.Destroy;
begin
  ShipLoopSound.Free;
  inherited Destroy;
end;
{ @end $6F132C }

{ @routine $6F136C TfShip2_InitializeLayout }
procedure TfShip2.InitializeLayout;
var
  Unused7C: Integer; // Native unused local at EBP-$7C, allocated after the live locals.
  I: Integer;
  Unused0C: Integer; // Native unused local at EBP-$0C; original type and name are unknown.
  Column, Row: Integer;
  Unused18: Integer;
  Panel: TPanelGI;
  Button: TGraphButtonGI;
begin
  with GetByName('InfoImage') do Self.ItemImageCenter := AddPoints(LocalPosition, HalfPoint(ClientSize));
  with GetByName('InfoSize') do Self.ItemSizeLabelPosition := Classes.Point(LocalPosition.X, LocalPosition.Y - Parent.ClientSize.Y);
  with GetByName('InfoPrice') do Self.ItemPriceLabelPosition := Classes.Point(LocalPosition.X, LocalPosition.Y - Parent.ClientSize.Y);
  with GetByName('EmRace') do Self.ItemRaceImagePosition := Classes.Point(LocalPosition.X - Parent.ClientSize.X, LocalPosition.Y - Parent.ClientSize.Y);
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fShip2... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('BGBuf') do
    begin
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      with NextSibling do SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('ADD_WarningMoney') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('ADD_Money') do
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
      if GiResourceVariant = 1 then SetDepth(-151.0) else SetDepth(-106.0);
    end;
    with FindByNameRecursive('UsePanel').Parent do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('SC_Panel') do SetPosition(Classes.Point(LocalPosition.X, (GameScreenHeight - ClientSize.Y) div 2 - 50));
    with FindByNameRecursive('RankWnd') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
    with FindByNameRecursive('RewardWnd') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
    FindByNameRecursive('Film').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('CustomBridgeInto') as TGraphButtonGI do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
  end;
  AppendLogLineThreadSafe('ok');
  BackgroundBuffer := GetByName('BGBuf') as TGraphBufGI;
  ItemInfoWindow := GetByName('PII') as TWindowGI;
  ItemImage := GetByName('InfoImage') as TImageGI;
  ItemNameLabel := GetByName('InfoName') as TLabelGI;
  ItemDescriptionLabel := GetByName('InfoText') as TLabelGI;
  ItemSizeLabel := GetByName('InfoSize') as TLabelGI;
  ItemPriceLabel := GetByName('InfoPrice') as TLabelGI;
  ItemRaceImage := GetByName('EmRace') as TImageGI;
  RightOpenImage := GetByName('RightOpen') as TImageGI;
  SkillsPanel := GetByName('Skills') as TPanelGI;
  FreeSkillPointsLabel := GetByName('SkillFreePoints') as TLabelGI;
  ExperienceLabel := GetByName('PDS_Exp') as TLabelGI;
  for I := 0 to 5 do HoldSlotZones[I] := GetByName('S_' + IntToStr(I) + 'z') as TZoneGI;
  for I := 0 to 5 do
  begin
    SkillImages[I] := GetByName('Skill' + IntToStr(I)) as TImageGI;
    SkillImagesP[I] := GetByName('Skill' + IntToStr(I) + 'p') as TImageGI;
    SkillImagesN[I] := GetByName('Skill' + IntToStr(I) + 'n') as TImageGI;
    SkillPanels[I] := GetByName('Skill' + IntToStr(I) + 'c') as TPanelGI;
    SkillImageRestTop[I] := SkillImages[I].LocalPosition.Y;
    SkillButtons[I] := GetByName('Skill' + IntToStr(I) + 'Add') as TGraphButtonGI;
    SkillValueLabels[I] := GetByName('PDS_Skill' + IntToStr(I) + 'v') as TLabelGI;
    SkillProgressImages[I] := GetByName('PDS_Skill' + IntToStr(I) + 'i') as TImageGI;
    SkillGainImages[I] := GetByName('PDS_Skill' + IntToStr(I) + 'g') as TImageGI;
  end;
  for I := 0 to StorageImageCount - 1 do StorageImages[I] := GetByName('Storage_' + IntToStr(I) + 'i') as TImageGI;
  RewardsBuffer := GetByName('RewardsImg') as TGraphBufGI;
  RewardsWindow := GetByName('RewardWnd') as TWindowGI;
  ExitButton := GetByName('Exit') as TGraphButtonGI;
  ExitButton.UpCallback := CloseClicked;
  (GetByName('ExitRH') as TGraphButtonGI).UpCallback := CloseClicked;
  (GetByName('DestrInto') as TGraphButtonGI).UpCallback := EnterBridgeClicked;
  (GetByName('CustomBridgeInto') as TGraphButtonGI).UpCallback := EnterBridgeClicked;
  (GetByName('S_Left') as TGraphButtonGI).UpCallback := HoldLeftReleased;
  (GetByName('S_Left') as TGraphButtonGI).DownCallback := HoldLeftPressed;
  (GetByName('S_Right') as TGraphButtonGI).UpCallback := HoldRightReleased;
  (GetByName('S_Right') as TGraphButtonGI).DownCallback := HoldRightPressed;
  GetByName('MainPanel').KeyDownCallback := MainKeyDown;
  GetByName('MainPanel').KeyUpCallback := MainKeyUp;
  GetByName('MainPanel').LeftButtonUpCallback := MainLeftButtonUp;
  GetByName('MainPanel').RightButtonDownCallback := MainRightButtonDown;
  with GetByName('Ship3D') do Self.ShipImageCenter := AddPoints(LocalPosition, HalfPoint(ClientSize));
  with GetByName('GateZone') as TZoneGI do
  begin
    MouseEnterCallback := GateMouseEnter;
    MouseLeaveCallback := GateMouseLeave;
    ZoneMouseUpCallback := GateMouseUp;
  end;
  with GetByName('UseZone') as TZoneGI do
  begin
    MouseEnterCallback := UseMouseEnter;
    MouseLeaveCallback := UseMouseLeave;
    ZoneMouseUpCallback := UseMouseUp;
  end;
  PanelSlideWidth := GiScalePixels(100);
  RightPanelRestLeft := GetByName('PanelRight').LocalPosition.X;
  DestrPanelSlideWidth := 404;
  DestrPanelRestLeft := GetByName('PanelDestr').LocalPosition.X;
  GateLeftRestLeft := GetByName('GateLeft').LocalPosition.X;
  GateRightRestLeft := GetByName('GateRight').LocalPosition.X;
  UseLeftRestLeft := GetByName('UseLeft').LocalPosition.X;
  UseRightRestLeft := GetByName('UseRight').LocalPosition.X;
  StoragePanelSlideHeight := -366;
  StoragePanelRestTop := GetByName('SC_Storage_Panel').LocalPosition.Y;
  StorageUpButton := GetByName('SC_Up') as TGraphButtonGI;
  StorageUpButton.UpCallback := StorageUpClicked;
  (GetByName('SC_Down') as TGraphButtonGI).UpCallback := StorageDownClicked;
  PropertyHintRightEdge := GetByName('RankWnd').LocalPosition.X;
  (GetByName('FromRH') as TGraphButtonGI).UpCallback := ToggleRemoteHoldClicked;
  (GetByName('ToRH') as TGraphButtonGI).UpCallback := ToggleRemoteHoldClicked;
  Panel := GetByName('PanelItemRH') as TPanelGI;
  Panel.FreeOwnedChildren;
  for Row := 0 to 10 do
    for Column := 0 to 4 do
    begin
      RemoteHoldImages[5 * Row + Column] := TImageGI.Create(Panel);
      with RemoteHoldImages[5 * Row + Column] do
      begin
        SetPosition(Classes.Point(Column * GiScalePixelsEx(42,33), Row * GiScalePixelsEx(42,33)));
        SetSize(Classes.Point(GiScalePixelsEx(40,31), GiScalePixelsEx(40,31)));
        SetName('RHItem' + IntToStr(Column + 5 * Row));
        LeftButtonDownCallback := RemoteHoldItemMouseDown;
      end;
    end;
  with GetByName('SortTypeRH') as TGraphButtonGI do begin UserValue := 0; UpCallback := SortRemoteHoldClicked end;
  with GetByName('SortSizeRH') as TGraphButtonGI do begin UserValue := 1; UpCallback := SortRemoteHoldClicked end;
  with GetByName('SortMoneyRH') as TGraphButtonGI do begin UserValue := 2; UpCallback := SortRemoteHoldClicked end;
  (GetByName('UpRH') as TGraphButtonGI).DownCallback := RemoteHoldUpPressed;
  (GetByName('UpRH') as TGraphButtonGI).UpCallback := RemoteHoldUpReleased;
  (GetByName('DownRH') as TGraphButtonGI).DownCallback := RemoteHoldDownPressed;
  (GetByName('DownRH') as TGraphButtonGI).UpCallback := RemoteHoldDownReleased;
  (GetByName('StorageToShip') as TGraphButtonGI).UpCallback := StorageToShipClicked;
  (GetByName('SellAllFromStorage') as TGraphButtonGI).UpCallback := SellStorageClicked;
  (GetByName('ShipToStorage') as TGraphButtonGI).UpCallback := ShipToStorageClicked;
  (GetByName('SortStorageByType') as TGraphButtonGI).UpCallback := SortStorageByTypeClicked;
  (GetByName('SortStorageBySize') as TGraphButtonGI).UpCallback := SortStorageBySizeClicked;
  (GetByName('SortStorageByMoney') as TGraphButtonGI).UpCallback := SortStorageByPriceClicked;
  (GetByName('LoadRocketsInHold') as TGraphButtonGI).UpCallback := LoadHoldRocketsClicked;
  (GetByName('SellAllFromHold') as TGraphButtonGI).UpCallback := SellHoldClicked;
  (GetByName('LoadRocketsInSlots') as TGraphButtonGI).UpCallback := LoadEquippedRocketsClicked;
  SavedCaptainFrame := 0;
  RemoteHoldVisible := False;
  for I := 0 to 9 do
  begin
    Button := FindControlByPath('Compl' + IntToStr(I)) as TGraphButtonGI;
    if Button <> nil then
    begin
      Button.DownCallback := EquipmentConfigurationClicked;
      Button.UpCallback := EquipmentConfigurationClicked;
    end;
  end;
  SelfSkillPointColor := GetStyleColorGI('Ship.ExpPointsToSpendOnSelf',45,105,124);
  OtherSkillPointColor := GetStyleColorGI('Ship.ExpPointsToSpendOnOther',180,60,60);
end;
{ @end $6F136C }

{ @routine $6F3078 TfShip2_OnOpen }
procedure TfShip2.OnOpen;
var
  Reserved08, SlotCount: Integer;
  PortraitPath, ReservedText: WideString;
  I, J: Integer;
  Item: TItem;
  SavedFlag, ScriptChangedFlag: Boolean;
  Control: TObjectGI;
begin
  inherited OnOpen;
  SetLength(ArtefactSlotZones,DefaultHullSlotCounts[sskArtefact]);
  for I := 0 to DefaultHullSlotCounts[sskArtefact] - 1 do
    ArtefactSlotZones[I] := GetByName('Art' + IntToStr(I) + 'z') as TZoneGI;
  if ShipToInspect <> nil then PlayerHoldShip := ShipToInspect else PlayerHoldShip := GetPlayer;
  (GetByName('PM_Ship') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Gal') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Quest') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_EndTurn') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Logo') as TGraphButtonGI).SetHitTestDisabled(True);
  HighlightRepairableEquipment := False;
  CustomCursorEnabled := True;
  UpdateActionCursor(ReopenRequested);
  SetCursorActive(True);
  SavedFlag := ReopenRequested;
  ReopenRequested := False;
  if SavedFlag then
  begin
    PlayerHoldShip.ScriptItemsAct(satOnReEnteringForm,nil,nil,0);
    if GetPlayer <> PlayerHoldShip then GetPlayer.ScriptItemsAct(satOnReEnteringOtherShip,nil,nil,0);
  end
  else
  begin
    PlayerHoldShip.ScriptItemsAct(satOnEnteringForm,nil,nil,0);
    if GetPlayer <> PlayerHoldShip then GetPlayer.ScriptItemsAct(satOnEnteringOtherShip,nil,nil,0);
  end;
  ScriptChangedFlag := ReopenRequested;
  ReopenRequested := SavedFlag;
  MainPanel.OnOpen;
  if CurrentScreenId = screenArcadeBattle then MainPanel.Hide else MainPanel.Show;
  for I := 0 to PlayerHoldShip.Inventory.Count - 1 do
  begin
    Item := TItem(PlayerHoldShip.Inventory[I]);
    if (Item is TWeapon) and ((Item as TWeapon).Target <> nil) then
      if (Item as TWeapon).EquippedFlag = 0 then (Item as TWeapon).Target := nil
      else if (not ((Item as TWeapon).Target is TShip) or (Galaxy.IdToShip(((Item as TWeapon).Target as TShip).Id,False) = nil)) and
        (not ((Item as TWeapon).Target is TItem) or (Galaxy.IdToItem(((Item as TWeapon).Target as TItem).Id,False) = nil)) and
        (not ((Item as TWeapon).Target is TAsteroid) or (Galaxy.IdToAsteroid(((Item as TWeapon).Target as TAsteroid).Id) = nil)) and
        (not ((Item as TWeapon).Target is TMissile) or (Galaxy.IdToMissile(((Item as TWeapon).Target as TMissile).Id) = nil)) then
        (Item as TWeapon).Target := nil;
  end;
  if not ReopenRequested then RemoveEmptyPlayerHoldSlots;
  if not ReopenRequested then StorageFirstSlot := 0;
  GetPlayer.RepairDuplicateStorageSlots(GetLocalStorageOwner);
  RefreshEquipmentSlotControls;
  Galaxy.PrimeIntegrityChecksum1(420);
  if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True,0);
  BackgroundBuffer.BindExternalGraphBuf(AuxRenderBuffer);
  PreserveSpaceMusic := ArcadeBattleScreen = ParentLoop;
  ShipStateChanged := False;
  if not ReopenRequested then
  begin
    SelectedHoldKind := phkEmpty;
    SelectedHoldItem := nil;
    HoldFirstIndex := 0;
    RemoteHoldFirstOrder := 0;
  end;
  for I := 0 to 5 do
    with GetByName('Skill' + IntToStr(I) + 'z') as TZoneGI do
    begin
      EnterCallback := ShowShipPropertyInfo;
      LeaveCallback := HideShipPropertyInfo;
    end;
  DisplayedItemKey := 0;
  GetByName('PII').SetActive(False);
  GetByName('InfoHull').SetActive(False);
  with GetByName('ShipName') as TLabelGI do
  begin
    if PlayerHoldShip is TRuins then SetText(TRuins(PlayerHoldShip).GetColoredFullName(''))
    else SetText(PlayerHoldShip.GetFullName(#13#10));
    if (PlayerHoldShip is TTranclucator) and ((PlayerHoldShip as TTranclucator).OwnerShip = GetPlayer) then
      LeftButtonDownCallback := ShipNameMouseDown
    else LeftButtonDownCallback := nil;
  end;
  with GetByName('CharName') as TLabelGI do
  begin
    if PlayerHoldShip is TRanger then
    begin
      SetText((PlayerHoldShip as TRanger).GetCharacterName);
      SetActive(True);
    end
    else
    begin
      SetText('');
      SetActive(False);
    end;
  end;
  GetByName('RankWnd').SetActive(False);
  with GetByName('RankI') as TImageGI do
  begin
    SetActive(True);
    if (PlayerHoldShip is TKling) or (PlayerHoldShip is TRuins) or (PlayerHoldShip is TTranclucator) then
    begin
      MouseEnterCallback := nil;
      MouseLeaveCallback := nil;
    end
    else
    begin
      MouseEnterCallback := ShowShipPropertyInfo;
      MouseLeaveCallback := HideShipPropertyInfo;
    end;
    if PlayerHoldShip is TKling then SetImagePath(RankToImage(Byte(DominatorShipDefinitions[Ord((PlayerHoldShip as TKling).KlingType)].RankImageIndex)))
    else if PlayerHoldShip is TRuins then SetImagePath(RankToImage(6))
    else if PlayerHoldShip is TTranclucator then SetImagePath(RankToImage(3))
    else if (PlayerHoldShip is TNormalShip) and (PlayerHoldShip.OwnerId <> oiPirate) then SetImagePath(RankToImage((PlayerHoldShip as TNormalShip).Rank))
    else SetActive(False);
  end;
  with GetByName('RankAdd') as TImageGI do
  begin
    if (GetPlayer = PlayerHoldShip) and (GetPlayer.OwnerId = oiPirate) then SetActive(False)
    else if PlayerHoldShip is TRanger then
    begin
      MouseEnterCallback := ShowShipPropertyInfo;
      MouseLeaveCallback := HideShipPropertyInfo;
      SetActive((PlayerHoldShip as TRanger).CanPromoteRank);
    end
    else SetActive(False);
  end;
  with GetByName('RankI2') as TImageGI do
  begin
    if (PlayerHoldShip is TNormalShip) and (PlayerHoldShip.OwnerId = oiPirate) then
    begin
      SetActive(True);
      MouseEnterCallback := ShowShipPropertyInfo;
      MouseLeaveCallback := HideShipPropertyInfo;
      SetImagePath(PirateRankToImage((PlayerHoldShip as TNormalShip).PirateRank));
    end
    else SetActive(False);
  end;
  with GetByName('PRankForm') do SetActive(False);
  with GetByName('RankAdd2') as TImageGI do
  begin
    if (PlayerHoldShip is TNormalShip) and (PlayerHoldShip.OwnerId = oiPirate) then
    begin
      SetPosition(Classes.Point(193,58));
      MouseEnterCallback := ShowShipPropertyInfo;
      MouseLeaveCallback := HideShipPropertyInfo;
      SetActive((PlayerHoldShip as TRanger).CanPromotePirateRank);
    end
    else SetActive(False);
  end;
  if (PlayerHoldShip is TRuins) or (PlayerHoldShip.Graphic is TRuinsSE) then
  begin
    GetByName('Ship3D').SetActive(False);
    with GetByName('Ship3DBuf') as TGraphBufGI do
    begin
      PortraitPath := PlayerHoldShip.GetShipPortraitImagePath;
      SourceHasPerPixelAlpha := True;
      LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(PortraitPath,1,','),GraphBuf);
      if (ClientSize.X < Integer(GraphBuf.Width)) or (ClientSize.Y < Integer(GraphBuf.Height)) then
      begin
        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
          GraphBuf.RescaleRgba(ClientSize.X,Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),5)
        else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),ClientSize.Y,5);
      end;
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end;
  end
  else
  begin
    GetByName('Ship3DBuf').SetActive(False);
    with GetByName('Ship3D') as TImageGI do
    begin
      SetImagePath(PlayerHoldShip.GetShipPortraitImagePath);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetPosition(SubtractPoints(ShipImageCenter,GetVisualCenter));
      SetActive(True);
    end;
  end;
  with GetByName('S_Hull_0z') as TZoneGI do ZoneMouseUpCallback := HullMouseDown;
  GetByName('S_Left').SetActive(False);
  GetByName('S_Right').SetActive(False);
  GetByName('S_Left').SetActive(True);
  GetByName('S_Right').SetActive(True);
  with GetByName('CaptainI') as TImageGI do
  begin
    SetImagePath('GI,' + PlayerHoldShip.GetCaptainPortraitResourceBase + 'i');
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
  end;
  with GetByName('CaptainA') as TgaiGI do
  begin
    FirstFrameOnly := not AnimCaptain;
    SetImagePath(PlayerHoldShip.GetCaptainPortraitResourceBase + 'a');
    SequenceIndex := 0;
    UpdateAutoGeometry;
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    if (SavedCaptainFrame >= 0) and (SequenceFrameCount > SavedCaptainFrame) then SetSequenceFrame(SavedCaptainFrame)
    else SetSequenceFrame(0);
    SetActive(True);
    RestartPlayback;
  end;
  RefreshRewards(TNormalShip(PlayerHoldShip));
  SavedShipExperience := -1;
  with GetByName('TextPoints') as TLabelGI do
  begin
    if CanUsePlayerExperience then
    begin
      SetText(LocalizedColorText('FormShip.PlayerPoints'));
      SetTextColor(OtherSkillPointColor);
      SavedShipExperience := PlayerHoldShip.FreeExperience;
      PlayerHoldShip.FreeExperience := GetPlayer.FreeExperience;
    end
    else
    begin
      SetText(LocalizedColorText('FormShip.Points'));
      SetTextColor(SelfSkillPointColor);
    end;
  end;
  with GetByName('LNewExp1') as TLabelGI do
    if CanUsePlayerExperience then SetText(LocalizedColorText('FormShip.LNewExp1b'))
    else SetText(LocalizedColorText('FormShip.LNewExp1'));
  with GetByName('LNewExp2') as TLabelGI do
    if CanUsePlayerExperience then SetText(LocalizedColorText('FormShip.LNewExp2b'))
    else SetText(LocalizedColorText('FormShip.LNewExp2'));
  Galaxy.PrimeIntegrityChecksum1(422);
  RefreshShipView;
  InvalidateViewport;
  DrawQueuedUpdateRects;
  if RightPanelSlideTimer <> nil then
  begin
    CancelCallbackTimer(RightPanelSlideTimer);
    RightPanelSlideTimer := nil;
  end;
  if not ReopenRequested or RemoteHoldMode then
  begin
    with GetByName('PanelRight') do
    begin
      SetPosition(Classes.Point(PanelSlideWidth,LocalPosition.Y));
      SetActive(not RemoteHoldMode);
    end;
    with GetByName('PanelLH') do SetActive(not RemoteHoldMode);
  end
  else
  begin
    with GetByName('PanelRight') do
    begin
      SetPosition(Classes.Point(RightPanelRestLeft,LocalPosition.Y));
      SetActive(True);
    end;
    with GetByName('PanelLH') do SetActive(True);
  end;
  if not ReopenRequested or not RemoteHoldMode then
  begin
    with GetByName('PanelRH') do
    begin
      SetPosition(Classes.Point(PanelSlideWidth,LocalPosition.Y));
      SetActive(RemoteHoldMode);
    end;
    with GetByName('PanelDS') do SetActive(RemoteHoldMode);
  end
  else
  begin
    with GetByName('PanelRH') do
    begin
      SetPosition(Classes.Point(RightPanelRestLeft,LocalPosition.Y));
      SetActive(True);
    end;
    with GetByName('PanelDS') do SetActive(True);
  end;
  with GetByName('PanelDestr') do
  begin
    if not ReopenRequested then SetPosition(Classes.Point(DestrPanelSlideWidth,LocalPosition.Y))
    else SetPosition(Classes.Point(DestrPanelRestLeft,LocalPosition.Y));
    SetActive(not RemoteHoldMode and (GetPlayer = PlayerHoldShip) and (GetPlayer.GetHull.CapitalShip = 1));
  end;
  with GetByName('DestrInto') do
    SetActive((GetPlayer = PlayerHoldShip) and not GetPlayer.InHyperspace and (GetPlayer.RuinsMode = 0) and (QueuedArcadeBattles.Count <= 0));
  with GetByName('CustomBridgeInto') as TGraphButtonGI do
    SetActive((GetPlayer = PlayerHoldShip) and (GetPlayer.GetHull.CapitalShip > 1) and not GetPlayer.InHyperspace and (GetPlayer.RuinsMode = 0) and (QueuedArcadeBattles.Count <= 0));
  if not ReopenRequested then
  begin
    RightPanelSlideStep := 20;
    RightPanelSlideTimer := ScheduleCallbackTimer(20,20,SlideRightPanelTimer);
  end;
  if NativeTimer384 <> nil then
  begin
    CancelCallbackTimer(NativeTimer384);
    NativeTimer384 := nil;
  end;
  RefreshTimerTick;
  NativeTimer384 := ScheduleCallbackTimer(1,1,ShowItemInfoTimer);
  MoneyWarningVisible := False;
  RefreshMoneyWarning;
  if PlayerHoldShip.GetHull.HullPoints / PlayerHoldShip.GetHull.Weight > 0.2 then
  begin
    GetByName('CenterNormalImage').SetActive(True);
    with GetByName('CenterNormalAnim') as TgaiGI do
    begin
      SetActive(True);
      RestartPlayback;
    end;
    GetByName('CenterDamageImage').SetActive(False);
    GetByName('CenterDamageAnim').SetActive(False);
  end
  else
  begin
    GetByName('CenterNormalImage').SetActive(False);
    GetByName('CenterNormalAnim').SetActive(False);
    GetByName('CenterDamageImage').SetActive(True);
    with GetByName('CenterDamageAnim') as TgaiGI do
    begin
      SetActive(True);
      RestartPlayback;
    end;
  end;
  if ReopenRequested then
  begin
    if StorageUpButton.Active then StorageDownClicked(nil) else StorageUpClicked(nil);
  end
  else
  begin
    GateSlideOffset := 0;
    with GetByName('GateLeft') do SetPosition(Classes.Point(GateLeftRestLeft,LocalPosition.Y));
    with GetByName('GateRight') do SetPosition(Classes.Point(GateRightRestLeft,LocalPosition.Y));
    if GateSlideTimer <> nil then
    begin
      CancelCallbackTimer(GateSlideTimer);
      GateSlideTimer := nil;
    end;
    UseSlideOffset := 0;
    with GetByName('UseLeft') do SetPosition(Classes.Point(UseLeftRestLeft,LocalPosition.Y));
    with GetByName('UseRight') do SetPosition(Classes.Point(UseRightRestLeft,LocalPosition.Y));
    if UseSlideTimer <> nil then
    begin
      CancelCallbackTimer(UseSlideTimer);
      UseSlideTimer := nil;
    end;
    UsePanelSlideOffset := 0;
    with GetByName('UsePanel') do SetPosition(Classes.Point(ClientSize.X,LocalPosition.Y));
    if UsePanelSlideTimer <> nil then
    begin
      CancelCallbackTimer(UsePanelSlideTimer);
      UsePanelSlideTimer := nil;
    end;
    (GetByName('SC_Slot1_Anim') as TgaiGI).SetSequenceFrame(0);
    (GetByName('SC_Slot2_Anim') as TgaiGI).SetSequenceFrame(0);
    (GetByName('SC_Slot3_Anim') as TgaiGI).SetSequenceFrame(0);
    if SpecialSlot1Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot1Timer);
      SpecialSlot1Timer := nil;
    end;
    if SpecialSlot2Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot2Timer);
      SpecialSlot2Timer := nil;
    end;
    if SpecialSlot3Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot3Timer);
      SpecialSlot3Timer := nil;
    end;
    StorageSlideOffset := 0;
    with GetByName('SC_Storage_Panel') do SetPosition(Classes.Point(LocalPosition.X,StoragePanelSlideHeight));
    StorageUpButton.SetActive(False);
    (GetByName('SC_Down') as TGraphButtonGI).SetActive(True);
    if StorageSlideTimer <> nil then
    begin
      CancelCallbackTimer(StorageSlideTimer);
      StorageSlideTimer := nil;
    end;
    if not GetPlayer.HasAccessibleStorageAt(nil) then StorageDownClicked(nil);
    with GetByName('SC_Panel') as TPanelGI do SetPosition(Classes.Point(0,LocalPosition.Y));
  end;
  with GetByName('HullRepair') as TgaiGI do
    if Active then
    begin
      if not PlayServiceAnimations then SetActive(False)
      else
      begin
        SetSequenceFrame(0);
        CycleCompleteCallback := HideSender;
        SetActive(True);
        RestartPlayback;
      end;
    end;
  for I := 0 to 7 do
  begin
    SlotCount := 1;
    if EquipmentSlotLayouts[I].ItemType = t_Weapon1 then SlotCount := 5;
    for J := 0 to SlotCount - 1 do
      with GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'Repair') as TgaiGI do
        if Active then
        begin
          if not PlayServiceAnimations then SetActive(False)
          else
          begin
            SetSequenceFrame(0);
            CycleCompleteCallback := HideSender;
            SetActive(True);
            RestartPlayback;
          end;
        end;
  end;
  for J := 0 to DefaultHullSlotCounts[sskArtefact] - 1 do
  begin
    Control := FindControlByPath('Art' + IntToStr(J) + 'Repair');
    if Control <> nil then Control.SetActive(False);
  end;
  RefreshLoadEquippedRocketsButton;
  GetByName('SC_Panel').SetActive(CanUseLocalStorage);
  CustomCursorEnabled := True;
  UpdateActionCursor(ReopenRequested);
  SetCursorActive(True);
  ShipLoopSound.SetVolume(1.0);
  PlayServiceAnimations := False;
  ReopenRequested := ScriptChangedFlag;
  MainPanel.RebuildMessageButtons(False);
  Galaxy.PrimeIntegrityChecksum1(501);
  if not ReopenRequested then Galaxy.PrimeIntegrityChecksum2(502);
end;
{ @end $6F3078 }

{ @routine $6F552C TfShip2_OnClose }
procedure TfShip2.OnClose;
var I: Integer; Binding: TScriptShip;
begin
  Galaxy.CheckIntegrityChecksum1(503);
  if not ReopenRequested then Galaxy.CheckIntegrityChecksum2(504);
  inherited OnClose;
  if ShipToInspect <> nil then PlayerHoldShip := ShipToInspect else PlayerHoldShip := GetPlayer;
  if not ReopenRequested then
  begin
    PlayerHoldShip.ScriptItemsAct(satOnLeavingForm,nil,nil,0);
    if GetPlayer <> PlayerHoldShip then GetPlayer.ScriptItemsAct(satOnLeavingOtherShip,nil,nil,0);
  end;
  BackgroundBuffer.GraphBuf.Clear;
    if HoldScrollTimer <> nil then
    begin
      CancelCallbackTimer(HoldScrollTimer);
      HoldScrollTimer := nil;
    end;
  StopScriptVideo;
    if SpecialSlot1Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot1Timer);
      SpecialSlot1Timer := nil;
    end;
    if SpecialSlot2Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot2Timer);
      SpecialSlot2Timer := nil;
    end;
    if SpecialSlot3Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot3Timer);
      SpecialSlot3Timer := nil;
    end;
    if GateSlideTimer <> nil then
    begin
      CancelCallbackTimer(GateSlideTimer);
      GateSlideTimer := nil;
    end;
    if UseSlideTimer <> nil then
    begin
      CancelCallbackTimer(UseSlideTimer);
      UseSlideTimer := nil;
    end;
    if UsePanelSlideTimer <> nil then
    begin
      CancelCallbackTimer(UsePanelSlideTimer);
      UsePanelSlideTimer := nil;
    end;
    if StorageSlideTimer <> nil then
    begin
      CancelCallbackTimer(StorageSlideTimer);
      StorageSlideTimer := nil;
    end;
    if MoneyWarningTimer <> nil then
    begin
      CancelCallbackTimer(MoneyWarningTimer);
      MoneyWarningTimer := nil;
    end;
    if NativeTimer384 <> nil then
    begin
      CancelCallbackTimer(NativeTimer384);
      NativeTimer384 := nil;
    end;
    if ItemInfoHideTimer <> nil then
    begin
      CancelCallbackTimer(ItemInfoHideTimer);
      ItemInfoHideTimer := nil;
    end;
    if PropertyInfoHideTimer <> nil then
    begin
      CancelCallbackTimer(PropertyInfoHideTimer);
      PropertyInfoHideTimer := nil;
    end;
  if not ReopenRequested then ReturnSelectedHoldEntry;
    if RightPanelSlideTimer <> nil then
    begin
      CancelCallbackTimer(RightPanelSlideTimer);
      RightPanelSlideTimer := nil;
    end;
  ScriptUseItem := nil;
  Galaxy.CheckIntegrityChecksum1(423);
  if (SavedShipExperience >= 0) and CanUsePlayerExperience then
  begin
    GetPlayer.FreeExperience := PlayerHoldShip.FreeExperience;
    PlayerHoldShip.FreeExperience := SavedShipExperience;
    SavedShipExperience := -1;
  end;
  PlayerHoldShip.RefreshDerivedStats(True);
  if PlayerHoldShip.Order = soJump then
    if PlayerHoldShip.JumpRange < System.Round(PointDistance(PlayerHoldShip.CurrentStar.Position,TStar(PlayerHoldShip.OrderTarget).Position)) then PlayerHoldShip.OrderNone(False);
  if GetPlayer.ScriptShipBindings <> nil then
  begin
    I := GetPlayer.ScriptShipBindings.Count - 1;
    while I >= 0 do
    begin
      if I >= GetPlayer.ScriptShipBindings.Count then I := GetPlayer.ScriptShipBindings.Count - 1
      else
      begin
        Binding := GetPlayer.ScriptShipBindings[I];
        if Binding.Script <> nil then Binding.Script.RunShipState(Binding);
        Dec(I);
      end;
    end;
  end;
  GetPlayer.RefreshStorageBubbles;
  if not ReopenRequested then
  begin
    ShipLoopSound.SetVolume(0.0);
    PlayerHoldShip := nil;
    ShipToInspect := nil;
  end;
  CustomCursorEnabled := not ReopenRequested;
  SavedCaptainFrame := (GetByName('CaptainA') as TgaiGI).SequenceFrame;
  ShipStateChanged := True;
  RemoteHoldVisible := False;
  MainPanel.OnClose;
end;
{ @end $6F552C }

{ @routine $6F5A10 TfShip2_CanUseLocalStorage }
function TfShip2.CanUseLocalStorage: Boolean;
begin
  Result := ((GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.OwnerId <> oiUninhabited)) or
    (GetPlayer.IsDockedToShip and (GetPlayer.RuinsMode = 0))) and (QueuedArcadeBattles.Count <= 0);
end;
{ @end $6F5A10 }

{ @routine $6F5A70 TfShip2_GetLocalStorageOwner }
function TfShip2.GetLocalStorageOwner: TObject;
begin
  if GetPlayer.IsOnPlanet then Result := GetPlayer.CurrentPlanet
  else if GetPlayer.IsDockedToShip then Result := GetPlayer.DockedTo
  else Result := nil;
end;
{ @end $6F5A70 }

{ @routine $6F5ABC TfShip2_RefreshRewards }
procedure TfShip2.RefreshRewards(Ship: TNormalShip);
var Index, I: Integer; Icon, Shadow: TGraphBufGR; Award: Byte; Path: WideString;
  IconSize: Integer; Spacing: Single; VisibleCount, Count: Integer;
begin
  HideRewardTooltip;
  if (Ship.AwardIds = nil) or (Ship.AwardIds.Count < 1) then
  begin
    RewardsBuffer.SetActive(False);
    Exit;
  end;
  Count := Min(Ship.AwardVisibleCount,Ship.AwardIds.Count);
  IconSize := GiScalePixels(20);
  VisibleCount := (RewardsBuffer.ClientSize.X - 2) div IconSize;
  if Count <= VisibleCount then Spacing := IconSize
  else
  begin
    VisibleCount := Min(30,Count);
    Spacing := (RewardsBuffer.ClientSize.X - 2 - IconSize) / (VisibleCount - 1);
  end;
  with RewardsBuffer do
  begin
    SetActive(True);
    SetImageKindX(ikxLeft);
    SetImageKindY(ikyBottom);
    GraphBuf.AllocateRgbaTight(Max(ClientSize.X,Round(VisibleCount * Spacing + IconSize - Spacing)) + 2,IconSize + 2);
    MouseMoveCallback := RewardsMouseMove;
    MouseLeaveCallback := RewardsMouseLeave;
    LeftButtonDownCallback := RewardsMouseDown;
    GraphBuf.ClearPixels;
    SourceHasPerPixelAlpha := True;
  end;
  Icon := TGraphBufGR.Create(False);
  Shadow := TGraphBufGR.Create(False);
  Index := Max(0,Count - VisibleCount);
  I := 0;
  while Index < Count do
  begin
    Award := Byte(Ship.AwardIds[Index]);
    if Award < 10 then Path := 'Bm.FormRewards.' + GiResourceSuffix + '_0' + IntToStr(Award)
    else Path := 'Bm.FormRewards.' + GiResourceSuffix + '_' + IntToStr(Award);
    LoadGiByPathIntoGraphBuf(Path,Icon);
    if Cardinal(Icon.Width) >= Cardinal(Icon.Height) then
      Icon.RescaleRgba(IconSize,Round(IconSize / Cardinal(Icon.Width) * Cardinal(Icon.Height)),5)
    else
      Icon.RescaleRgba(Round(IconSize / Cardinal(Icon.Height) * Cardinal(Icon.Width)),IconSize,5);
    Shadow.AllocateRgbaTight(Icon.Width,Icon.Height);
    Shadow.CopyRect32(Classes.Point(0,0),Icon,Classes.Rect(0,0,Icon.Width,Icon.Height));
    Shadow.MakeShadow;
    if (Icon.Height > IconSize) or (RewardsBuffer.GraphBuf.Width < Round(I * Spacing) + Icon.Width) then
    begin
      { The native renderer skips icons outside the allocated buffer. }
    end
    else
    begin
      RewardsBuffer.GraphBuf.BlendRect32(Classes.Point(Round(I * Spacing) + 2,2),Shadow,Classes.Rect(0,0,Icon.Width,Icon.Height));
      RewardsBuffer.GraphBuf.BlendRect32(Classes.Point(Round(I * Spacing),0),Icon,Classes.Rect(0,0,Icon.Width,Icon.Height));
    end;
    Inc(Index);
    Inc(I);
  end;
  Icon.Free;
  Shadow.Free;
end;
{ @end $6F5ABC }

{ @routine $6F6054 TfShip2_RewardsMouseMove }
procedure TfShip2.RewardsMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var IconSize: Integer; Spacing: Single; VisibleCount: Integer; Ship: TNormalShip;
  Index, I, X: Integer; Award: Byte; Count: Integer;
begin
  if PlayerHoldShip is TNormalShip then
  begin
    Ship := PlayerHoldShip as TNormalShip;
    Count := Ship.AwardVisibleCount;
    IconSize := GiScalePixels(20);
    VisibleCount := (RewardsBuffer.ClientSize.X - 2) div IconSize;
    if Count <= VisibleCount then Spacing := IconSize
    else
    begin
      VisibleCount := Min(30,Count);
      Spacing := (RewardsBuffer.ClientSize.X - 2 - IconSize) / (VisibleCount - 1);
    end;
    X := Sender.ToLocalPoint(Point).X;
    Index := Max(0,Count - VisibleCount);
    I := 0;
    while Index < Count do
    begin
      if (X >= Round(I * Spacing)) and (X < Round((I + 1) * Spacing)) then Break;
      Inc(I);
      Inc(Index);
    end;
    if Index >= Count then Index := Count - 1;
    Award := Byte(Ship.AwardIds[Index]);
    ShowRewardTooltip(Ship,Award);
  end;
end;
{ @end $6F6054 }

{ @routine $6F61F8 TfShip2_RewardsMouseLeave }
procedure TfShip2.RewardsMouseLeave(Sender: TObjectGI);
begin
  HideRewardTooltip;
end;
{ @end $6F61F8 }

{ @routine $6F6210 TfShip2_ShowRewardTooltip }
procedure TfShip2.ShowRewardTooltip(Ship: TNormalShip; Award: Integer);
var Path: WideString;
begin
  if SelectedReward <> Award then
  begin
    SelectedReward := Award;
    RewardsWindow.SetActive(True);
    if Award < 10 then Path := 'Bm.FormRewards.' + GiResourceSuffix + '_0' + IntToStr(Award)
    else Path := 'Bm.FormRewards.' + GiResourceSuffix + '_' + IntToStr(Award);
    with GetByName('RewardImage') as TGraphBufGI do
    begin
      SourceHasPerPixelAlpha := True;
      LoadGiByPathIntoGraphBuf(Path,GraphBuf);
      if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
        GraphBuf.RescaleRgba(ClientSize.X,Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),5)
      else
        GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),ClientSize.Y,5);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
    end;
    with GetByName('RewardName') as TLabelGI do SetText(Ship.GetAwardInfo(Award).Name);
    with GetByName('RewardText') as TLabelGI do SetText(Ship.GetAwardInfo(Award).Text);
    LayoutItemInfo(RewardsWindow,GetByName('RewardName') as TLabelGI,GetByName('RewardText') as TLabelGI,True,True,0);
    with GetByName('RewardName') as TLabelGI do
      SetSize(Classes.Point(Self.RewardsWindow.ClientSize.X - LocalPosition.X - Self.RewardsWindow.WorkSubRect.Right,ClientSize.Y));
    RewardsWindow.SetPosition(Classes.Point(ExtraScreenWidth div 2 + 680 - RewardsWindow.ClientSize.X,ExtraScreenHeight div 2 + 160));
    with RewardsWindow do
    begin
      Invalidate;
      UpdateAbsolutePosition;
      UpdateSubtreeHitBounds;
      Invalidate;
    end;
    UpdateInfoHint(0,0);
  end;
end;
{ @end $6F6210 }

{ @routine $6F6674 TfShip2_HideRewardTooltip }
procedure TfShip2.HideRewardTooltip;
begin
  SelectedReward := -1;
  RewardsWindow.SetActive(False);
end;
{ @end $6F6674 }

{ @routine $6F669C TfShip2_SlideRightPanelTimer }
procedure TfShip2.SlideRightPanelTimer(Timer: PCallbackTimerGI; UserData: Integer);
var X: Integer; Panel, DestrPanel: TObjectGI;
begin
  if not RemoteHoldMode then Panel := GetByName('PanelRight') else Panel := GetByName('PanelRH');
  DestrPanel := GetByName('PanelDestr');
  X := Panel.LocalPosition.X + RightPanelSlideStep;
  if X >= RightPanelRestLeft then
  begin
    X := RightPanelRestLeft;
    if RightPanelSlideTimer <> nil then
    begin
      CancelCallbackTimer(RightPanelSlideTimer);
      RightPanelSlideTimer := nil;
    end;
    RootUiObject.UpdateAbsolutePosition;
    RootUiObject.UpdateSubtreeHitBounds;
  end;
  DestrPanel.SetPosition(Classes.Point(DestrPanelRestLeft - RightPanelRestLeft + X,DestrPanel.LocalPosition.Y));
  Panel.SetPosition(Classes.Point(X,Panel.LocalPosition.Y));
end;
{ @end $6F669C }

{ @routine $6F67F0 TfShip2_CloseClicked }
procedure TfShip2.CloseClicked(Sender: TObjectGI);
begin
  if not ReopenRequested then
  begin
    Galaxy.CheckIntegrityChecksum1(427);
    ReturnSelectedHoldEntry;
  end;
  AuxRenderBuffer.Clear;
  RequestedScreenId := ShipReturnScreenId;
  RequestClose(1);
  BreakUiMessage;
end;
{ @end $6F67F0 }

{ @routine $6F6854 TfShip2_RewardsMouseDown }
procedure TfShip2.RewardsMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if AwardDialogsEnabled and not PlayerHoldShip.InHyperspace and (QueuedArcadeBattles.Count <= 0) and RewardsBuffer.Active then
  begin
    if SelectedHoldKind <> phkEmpty then
    begin
      Galaxy.CheckIntegrityChecksum1(427);
      ReturnSelectedHoldEntry;
    end;
    RewardsWindow.SetActive(False);
    AwardSubject := PlayerHoldShip;
    Galaxy.CheckIntegrityChecksum1(333);
    if not RunRewards(Self,False) then
    begin
      Galaxy.CheckIntegrityChecksum1(334);
      RequestClose(2);
    end
    else
    begin
      Galaxy.CheckIntegrityChecksum1(334);
      ShipStateChanged := True;
      ReopenRequested := True;
      PlayTransitionSounds := False;
      CloseClicked(nil);
    end;
  end;
end;
{ @end $6F6854 }

{ @routine $6F6974 TfShip2_ShipNameMouseDown }
procedure TfShip2.ShipNameMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Name: WideString;
begin
  if not PlayerHoldShip.InHyperspace and (QueuedArcadeBattles.Count <= 0) then
  begin
    Name := PlayerHoldShip.GetName;
    if ShowTextInputDialog(Self,LocalizedColorText('FormShip.EnterShipName'),Name,30,0,0) = 1 then
    begin
      Galaxy.CheckIntegrityChecksum1(430);
      PlayerHoldShip.Name := Name;
      (GetByName('ShipName') as TLabelGI).SetText(Name);
      Galaxy.PrimeIntegrityChecksum1(431);
    end;
  end;
end;
{ @end $6F6974 }

{ @routine $6F6AC8 TfShip2_ShowShipPropertyInfo }
procedure TfShip2.ShowShipPropertyInfo(Sender: TObjectGI);
var Ship: TNormalShip; Path, Title, Description, CustomDescription, CustomName: WideString;
  Skill: TPilotSkill; Window: TWindowGI; Afterburner: Boolean; Position: TPoint; Info: PCustomShipInfo;
begin
  if PlayerHoldShip is TNormalShip then Ship := PlayerHoldShip as TNormalShip else Ship := nil;
  Afterburner := False;
  if RightPanelSlideTimer = nil then
  begin
    Path := '';
    Description := '';
    Position := Classes.Point(10,10);
    if Sender.UserValue = -1 then
    begin
      if Sender.UserData <> 0 then
      begin
        Info := PCustomShipInfo(Sender.UserData);
        RunCustomShipInfoActionCode(Info, satOnShowingItemInfo,PlayerHoldShip,nil,nil,0);
        CustomDescription := Info.Description;
        if CustomDescription = '' then CustomDescription := LocalizedColorText('ShipInfo.AddInfo.CustomInfos.' + Info.TypeName + '.Description');
        ReplaceTextToken(CustomDescription,'<Data1>',IntToStr(Info.Data[1]),TextHighlightColorTag);
        ReplaceTextToken(CustomDescription,'<Data2>',IntToStr(Info.Data[2]),TextHighlightColorTag);
        ReplaceTextToken(CustomDescription,'<Data3>',IntToStr(Info.Data[3]),TextHighlightColorTag);
        ReplaceTextToken(CustomDescription,'<TextData1>',Info.TextData1,TextHighlightColorTag);
        ReplaceTextToken(CustomDescription,'<TextData2>',Info.TextData2,TextHighlightColorTag);
        ReplaceTextToken(CustomDescription,'<TextData3>',Info.TextData3,TextHighlightColorTag);
        CustomName := LocalizedColorText('ShipInfo.AddInfo.CustomInfos.' + Info.TypeName + '.Name');
        ReplaceTextToken(CustomName,'<Data1>',IntToStr(Info.Data[1]),TextHighlightColorTag);
        ReplaceTextToken(CustomName,'<Data2>',IntToStr(Info.Data[2]),TextHighlightColorTag);
        ReplaceTextToken(CustomName,'<Data3>',IntToStr(Info.Data[3]),TextHighlightColorTag);
        ReplaceTextToken(CustomName,'<TextData1>',Info.TextData1,TextHighlightColorTag);
        ReplaceTextToken(CustomName,'<TextData2>',Info.TextData2,TextHighlightColorTag);
        ReplaceTextToken(CustomName,'<TextData3>',Info.TextData3,TextHighlightColorTag);
        Sender.HelpText := CustomName + '~' + CustomDescription;
      end;
      with GetByName('RankImage') as TGraphBufGI do
      begin
        SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf('Bm.FormShip2.' + GiResourceSuffix + 'AI_' + IntToStr(Cardinal(Sender.UserIndex)) + 'L',GraphBuf);
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
      Title := ExtractDelimitedPartW(Sender.HelpText,0,'~');
      Description := ExtractDelimitedRangeW(Sender.HelpText,1,CountDelimitedPartsW(Sender.HelpText,'~') - 1,'~');
    end
    else if GetByName('ForsageBut') = Sender then
    begin
      Afterburner := True;
      with GetByName('RankImage') as TGraphBufGI do
      begin
        SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf('Bm.FormShip2.' + GiResourceSuffix + 'ForsageIcon',GraphBuf);
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
      Title := LocalizedColorText('ShipInfo.Forsage.Name');
      Description := LocalizedColorText('ShipInfo.Forsage.Text');
      if DynamicTipsPos then Position := Classes.Point(Sender.HitTestBounds.Left - 10,Sender.HitTestBounds.Top + Sender.ClientSize.Y + 10);
    end
    else if Sender is TImageGI then
    begin
      if Ship = nil then Exit;
      if (Sender.ControlName = 'RankI') or (Sender.ControlName = 'RankAdd') then
      begin
        Path := ExtractDelimitedPartW(RankToImageSmall(Ship.Rank),1,',');
        with GetByName('RankImage') as TGraphBufGI do
        begin
          SourceHasPerPixelAlpha := True;
          LoadGiByPathIntoGraphBuf(Path,GraphBuf);
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
        end;
        Title := WrapTextInColor(Ship.GetRankLongName,InfoNameColorTag);
        Description := Ship.GetRankDescription;
        if Ship.Rank <> 7 then
        begin
          if Ship.GetRankPointsToNextRank > 0 then
            Description := Description + ' ' + FormatText2(LocalizedText('Rank.NextRankText'),TextHighlightColorTag,'<NextRank>',Ship.GetNextRankName,'<WarPoints>',IntToStr(Ship.GetRankPointsToNextRank))
          else
            Description := Description + ' ' + FormatText1(LocalizedText('Rank.NextRankGetText'),TextHighlightColorTag,'<NextRank>',Ship.GetNextRankName);
        end;
      end
      else if (Sender.ControlName = 'RankI2') or (Sender.ControlName = 'RankAdd2') then
      begin
        Path := ExtractDelimitedPartW(PirateRankToImageSmall(Ship.PirateRank),1,',');
        with GetByName('RankImage') as TGraphBufGI do
        begin
          SourceHasPerPixelAlpha := True;
          LoadGiByPathIntoGraphBuf(Path,GraphBuf);
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
        end;
        Title := WrapTextInColor(Ship.GetPirateRankLongName,InfoNameColorTag);
        Description := Ship.GetPirateRankDescription;
        if Ship.PirateRank <> 7 then
        begin
          if Ship.GetPirateRankPointsToNextRank > 0 then
            Description := Description + ' ' + FormatText2(LocalizedText('RankPirate.NextRankText'),TextHighlightColorTag,'<NextRank>',Ship.GetNextPirateRankName,'<WarPoints>',IntToStr(Ship.GetPirateRankPointsToNextRank))
          else
            Description := Description + ' ' + FormatText1(LocalizedText('RankPirate.NextRankGetText'),TextHighlightColorTag,'<NextRank>',Ship.GetNextPirateRankName);
        end;
      end;
    end
    else if Sender is TZoneGI then
    begin
      with GetByName('RankImage') as TGraphBufGI do
      begin
        SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf('Bm.FormShip2.' + GiResourceSuffix + 'Skill' + IntToStr(ExtractDigitsToIntW(Sender.ControlName) + 1),GraphBuf);
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
      Skill := TPilotSkill(ExtractDigitsToIntW(Sender.ControlName));
      Title := WrapTextInColor(LocalizedText('Skills.' + SkillConfigNames[Skill] + '.Name'),InfoNameColorTag);
      Description := FormatText1(LocalizedText('Skills.' + SkillConfigNames[Skill] + '.Text'),TextHighlightColorTag,'<SkillValue>',IntToStr(PilotSkillEffects[PlayerHoldShip.GetEffectiveSkillLevel(Skill), Skill]));
      ReplaceTextToken(Description,'<SkillLevel>',IntToStr(PlayerHoldShip.GetEffectiveSkillLevel(Skill)),TextHighlightColorTag);
      if Skill = psTechnical then ReplaceTextToken(Description,'<N>',IntToStr(PlayerHoldShip.GetSatelliteLimit),TextHighlightColorTag);
      if Skill = psTrading then ReplaceTextToken(Description,'<SkillValue2>',IntToStr(TradingSkillSalePercent[PlayerHoldShip.GetEffectiveSkillLevel(Skill)]),TextHighlightColorTag);
      if Skill = psLeadership then ReplaceTextToken(Description,'<SkillValue2>',IntToStr(LeadershipExperiencePercent[PlayerHoldShip.GetEffectiveSkillLevel(Skill)]),TextHighlightColorTag);
      if PlayerHoldShip.GetBaseSkillLevel(Skill) < 6 then
        Description := Description + #13#10 + #13#10 + FormatText1(LocalizedText('Skills.PointForNextLevel'),TextHighlightColorTag,'<PointForNextLevel>',IntToStr(SkillTrainingCosts[PlayerHoldShip.BaseSkills[Skill] + 1, Skill]));
    end;
    (GetByName('RankName') as TLabelGI).SetText(Title);
    (GetByName('RankText') as TLabelGI).SetText(Description);
    Window := GetByName('RankWnd') as TWindowGI;
    Window.SetPosition(Classes.Point(Window.LocalPosition.X,Max(10,Sender.HitTestBounds.Top - Sender.ClientSize.Y div 3 - 60)));
    Window.SetActive(True);
    Window.Invalidate;
    LayoutItemInfo(Window,GetByName('RankName') as TLabelGI,GetByName('RankText') as TLabelGI,True,True,0);
    with GetByName('RankName') as TLabelGI do SetSize(Classes.Point(Window.ClientSize.X - LocalPosition.X - Window.WorkSubRect.Right,ClientSize.Y));
    if not Afterburner then Window.SetPosition(Classes.Point(PropertyHintRightEdge - Window.ClientSize.X,Window.LocalPosition.Y))
    else Window.SetPosition(Position);
    if PropertyInfoHideTimer <> nil then
    begin
      CancelCallbackTimer(PropertyInfoHideTimer);
      PropertyInfoHideTimer := nil;
    end;
    HideItemInfo(nil,0);
  end;
end;
{ @end $6F6AC8 }

{ @routine $6F7F70 TfShip2_HideShipPropertyInfo }
procedure TfShip2.HideShipPropertyInfo(Sender: TObjectGI);
begin
  GetByName('RankWnd').SetActive(False);
end;
{ @end $6F7F70 }

{ @routine $6F7FA8 TfShip2_UpdateInfoHint }
procedure TfShip2.UpdateInfoHint(First, Second: Integer);
begin
end;
{ @end $6F7FA8 }

{ @routine $6F7FBC TfShip2_SlotToTip }
function TfShip2.SlotToTip(SlotName: WideString): TItemType;
var Name: WideString; I: Integer;
begin
  Name := ExtractDelimitedPartW(SlotName, 1, '_');
  for I := 0 to 7 do
    if Name = EquipmentSlotLayouts[I].Name then
    begin
      Result := EquipmentSlotLayouts[I].ItemType;
      Exit;
    end;
  raise Exception.Create('SlotToTip');
end;
{ @end $6F7FBC }

{ @routine $6F808C TfShip2_IsCompatibleSlot }
function TfShip2.IsCompatibleSlot(ItemType, SlotType: TItemType): Boolean;
begin
  Result := (ItemType = SlotType) or ((ItemType in [t_Weapon1..t_CustomWeapon]) and (SlotType in [t_Weapon1..t_CustomWeapon]));
end;
{ @end $6F808C }

{ @routine $6F80C8 TfShip2_RefreshEquipmentSlotControls }
procedure TfShip2.RefreshEquipmentSlotControls;
var Count, MaximumSlots, I, Slot: Integer;
begin
  for I := 0 to 7 do
  begin
    MaximumSlots := 1;
    if EquipmentSlotLayouts[I].ItemType = t_Weapon1 then MaximumSlots := 5;
    Count := PlayerHoldShip.GetSlotCountForItemType(EquipmentSlotLayouts[I].ItemType);
    for Slot := 0 to Count - 1 do
    begin
      EquipmentSlotZones[I,Slot] := GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'z') as TZoneGI;
      EquipmentSlotAnimations[I,Slot] := GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'anim') as TgaiGI;
      EquipmentSlotAnimations[I,Slot].UserState := 0;
      GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'off').SetActive(False);
      GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'Set').SetActive(False);
    end;
    if EquipmentSlotLayouts[I].ItemType = t_Weapon1 then
    begin
      for Slot := Count to 4 do
      begin
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'off').SetActive(True);
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'Set').SetActive(False);
      end;
    end
    else
      for Slot := Count to 0 do
      begin
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'off').SetActive(True);
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'Set').SetActive(False);
      end;
    for Slot := Count to MaximumSlots - 1 do
    begin
      GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'i').SetActive(False);
      GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'anim').SetActive(False);
    end;
  end;
end;
{ @end $6F80C8 }

{ @routine $6F86B0 TfShip2_RefreshShipView }
procedure TfShip2.RefreshShipView;
var
  I, Slot, SlotCount, DuplicateSlot, Column, Row: Integer;
  Item: TEquipment;
  Entry: TPlayerHoldUnit;
  ReservedPoint: TPoint;
  Highlight, Boost: Boolean;
  SelectedType, InstalledType: TItemType;
  Artefact: TArtefact;
  Text: WideString;
  SlotImage: TImageGI;
begin
  Galaxy.CheckIntegrityChecksum1(432);
  RefreshEquipmentConfigurationButtons;
  PlayerHoldShip.RefreshAssignedItemSlots;
  PlayerHoldShip.RefreshDerivedStats(True);
  RefreshPlayerHoldView(False);
  RefreshEquipmentSlotControls;
  with GetByName('LifeLeft') as TImageGI do
  begin
    if PlayerHoldShip.CountActiveArtefacts(t_ArtBio) > 0 then
    begin
      SetActive(True);
      if PlayerHoldShip.HasActiveDisease then SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'LifeRed')
      else if PlayerHoldShip.CountPresentDiseases > 0 then SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'LifeYellow')
      else SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'LifeGreen');
    end
    else SetActive(False);
  end;
  with GetByName('LifeRight') as TImageGI do
  begin
    if PlayerHoldShip.CountActiveArtefacts(t_ArtBio) > 0 then
    begin
      SetActive(True);
      if PlayerHoldShip.HasActiveDisease then SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'LifeRed')
      else if PlayerHoldShip.CountPresentDiseases > 0 then SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'LifeYellow')
      else SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'LifeGreen');
    end
    else SetActive(False);
  end;
  Text := IntToStr(PlayerHoldShip.GetDefensePercent) + '%';
  Text := Text + ' + ' + WrapTextInColor(IntToStr(PlayerHoldShip.GetArmor),'');
  (GetByName('IDef') as TLabelGI).SetText(Text);
  (GetByName('IMass') as TLabelGI).SetText(IntToStr(PlayerHoldShip.CalculateMass));
  if PlayerHoldShip.CalculateSpeed <= 0 then Text := RedColorTag else Text := '';
  (GetByName('ISpeed') as TLabelGI).SetText(WrapTextInColor(IntToStr(PlayerHoldShip.CalculateSpeed),Text));
  if PlayerHoldShip.GetCargoFreeSpace < 0 then Text := RedColorTag else Text := '';
  (GetByName('IEmpty') as TLabelGI).SetText(WrapTextInColor(IntToStr(PlayerHoldShip.GetCargoFreeSpace),Text));
  (GetByName('S_Left') as TGraphButtonGI).SetDisabled(HoldFirstIndex <= 0);
  (GetByName('S_Right') as TGraphButtonGI).SetDisabled(HoldFirstIndex + 6 > PlayerHoldEntries.Count);
  (GetByName('UpRH') as TGraphButtonGI).SetDisabled(RemoteHoldFirstOrder <= 0);
  (GetByName('DownRH') as TGraphButtonGI).SetDisabled(RemoteHoldFirstOrder >= GetRemoteHoldScrollLimit);
  RefreshActionPanels(SelectedHoldKind,SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,SelectedHoldItem,SelectedHoldOrigin);
  HoveredEquipmentAnimation := nil;
  with GetByName('HullSet') as TImageGI do
  begin
    SetActive(PlayerHoldShip.GetHull.HasMicroModule);
    if Active then SetImagePath('GI,' + GetMicroModuleBitmapResourceName(PlayerHoldShip.GetHull.MicroModuleIndex - 1) + 'Set');
  end;
  for I := 0 to 7 do
  begin
    SlotCount := PlayerHoldShip.GetSlotCountForItemType(EquipmentSlotLayouts[I].ItemType);
    for Slot := 0 to SlotCount - 1 do
    begin
      Item := PlayerHoldShip.FindEquippedItemInSlot(EquipmentSlotLayouts[I].ItemType,Slot);
      SlotImage := GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'i') as TImageGI;
      if SlotImage.UserValue = 0 then
      begin
        SlotImage.UserValue := SlotImage.LocalPosition.X + SlotImage.ClientSize.X div 2;
        SlotImage.UserIndex := SlotImage.LocalPosition.Y + SlotImage.ClientSize.Y div 2;
      end;
      if Item = nil then
      begin
        SlotImage.SetActive(False);
        SlotImage.SetImagePath('');
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'Set').SetActive(False);
      end
      else
      begin
        SlotImage.SetActive(True);
        SlotImage.SetImagePath('GI,' + GetShopItemIconName(Item) + 'i');
        SlotImage.SetImageKindX(ikxCenter);
        SlotImage.SetImageKindY(ikyCenter);
        with GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'Set') as TImageGI do
        begin
          SetActive(Item.HasMicroModule);
          if Active then SetImagePath('GI,' + GetMicroModuleBitmapResourceName(Item.MicroModuleIndex - 1) + 'Set');
        end;
      end;
      if AnimItem and (Item <> nil) then
      begin
        with GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'anim') as TgaiGI do
        begin
          UserData := Integer(SlotImage);
          SetPosition(SlotImage.LocalPosition);
          SetImagePath(GetShopItemIconName(Item) + 'a');
          SequenceIndex := 0;
          SetActive(False);
          if UserState <> 0 then
          begin
            SlotImage.SetActive(False);
            UpdateAutoGeometry;
            SetSequenceFrame(Min(Cardinal(UserState),SequenceFrameCount - 1));
            SetActive(True);
            StopAutoPlayback;
          end;
        end;
      end
      else GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'anim').SetActive(False);
      with GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'z') as TZoneGI do ZoneMouseDownCallback := EquipmentSlotMouseDown;
      if HighlightRepairableEquipment and (Item <> nil) and ((Item.EquippedFlag <> 0) or (Item is THull)) and Item.NeedsRepair then Highlight := True
      else if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_MicroModule) and (Item <> nil) and (Item.MicroModuleIndex = 0) and (SelectedHoldItem as TMicroModule).CanInstallOn(Item) then Highlight := True
      else if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem is TEquipmentWithActCode) and (Item <> nil) and (RunItemConfigActionCode(SelectedHoldItem, satOnCheckingUsability,PlayerHoldShip,Item,nil,0) > 0) then Highlight := True
      else if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem.ScriptItem <> nil) and (Item <> nil) and (TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnCheckingUsability,PlayerHoldShip,Item,nil,0) > 0) then Highlight := True
      else if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (Item <> nil) and (Item is TEquipmentWithActCode) and (RunItemConfigActionCode(Item, satOnCheckingUsability2,PlayerHoldShip,SelectedHoldItem,nil,0) > 0) then Highlight := True
      else if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (Item <> nil) and (Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).RunActionCode(satOnCheckingUsability2,PlayerHoldShip,SelectedHoldItem,nil,0) > 0) then Highlight := True
      else if (SelectedHoldKind = phkGoods) and (Item <> nil) and (Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).RunActionCode(satOnCheckingUsabilityGoods,PlayerHoldShip,TObject(SelectedGoodsIndex),TObject(SelectedGoodsQuantity),0) > 0) then Highlight := True
      else if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_Cistern) and (Item <> nil) and (Item.ItemType = t_FuelTanks) and ((SelectedHoldItem as TCistern).Fuel > 0) and ((Item as TFuelTanks).Fuel < (Item as TFuelTanks).Capacity) then Highlight := True
      else Highlight := (SelectedHoldKind = phkEquipment) and IsCompatibleSlot(SelectedHoldItem.ItemType,EquipmentSlotLayouts[I].ItemType);
      Boost := (SelectedHoldKind = phkArtefact) and (SelectedHoldItem is TArtefact) and PlayerHoldShip.IsEquipmentUsable(Item) and PlayerHoldShip.CanBoostArtefact(TArtefact(SelectedHoldItem).GetEffectiveType,Item,True);
      if Highlight and (Item <> nil) and (Item.NoDropFlag > 0) then Highlight := False;
      GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'a').SetActive(Highlight and not Boost);
      GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'n').SetActive((Item <> nil) and not Highlight and PlayerHoldShip.IsEquipmentUsable(Item) and not Boost);
      GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'b').SetActive((Item <> nil) and not Highlight and not PlayerHoldShip.IsEquipmentUsable(Item) and not Boost);
      GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'Ex').SetActive(Boost);
    end;
    if EquipmentSlotLayouts[I].ItemType = t_Weapon1 then
    begin
      for Slot := SlotCount to 4 do
        (GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'z') as TZoneGI).ZoneMouseDownCallback := nil;
    end
    else
      for Slot := SlotCount to 0 do
        (GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(Slot) + 'z') as TZoneGI).ZoneMouseDownCallback := nil;
  end;
  SlotCount := PlayerHoldShip.GetSlotCountForItemType(t_Artefact);
  for Slot := 0 to SlotCount - 1 do
  begin
    Artefact := PlayerHoldShip.FindEquippedItemInSlot(t_Artefact,Slot) as TArtefact;
    Highlight := (SelectedHoldKind = phkArtefact) and (SelectedHoldItem.ItemType in [t_Artefact..t_ArtefactAntigrav,t_ArtDefToEnergy..t_ArtGiperJump,t_ArtDefToArms1..t_ArtFastRacks]);
    DuplicateSlot := -1;
    if Highlight and not Galaxy.AreDuplicateArtefactsEnabled then
    begin
      SelectedType := SelectedHoldItem.ItemType;
      if (SelectedType in [t_Artefact..t_Artefact2]) and TArtefactCustom(SelectedHoldItem).SharedUse then SelectedType := TArtefactCustom(SelectedHoldItem).CountsAsItemType;
      for I := 0 to PlayerHoldShip.Artefacts.Count - 1 do
      begin
        Item := TEquipment(PlayerHoldShip.Artefacts[I]);
        if Item.EquippedFlag <> 0 then
        begin
          InstalledType := Item.ItemType;
          if (Byte(InstalledType) in [8..9]) and TArtefactCustom(Item).SharedUse then InstalledType := TArtefactCustom(Item).CountsAsItemType;
          if (SelectedType = InstalledType) and (not (SelectedType in [t_Artefact..t_Artefact2]) or (Item.ConfigBlockName = TEquipment(SelectedHoldItem).ConfigBlockName)) then
          begin
            DuplicateSlot := Item.AssignedSlotData;
            Break;
          end;
        end;
      end;
    end;
    if (DuplicateSlot >= 0) and (Slot <> DuplicateSlot) then Highlight := False;
    if not Highlight and (Artefact <> nil) and (Artefact.BrokenFlag = 0) and
      (PlayerHoldShip.CanBoostArtefact(Artefact.GetEffectiveType,nil,False) or
      ((SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TEquipment) and PlayerHoldShip.CanBoostArtefact(Artefact.GetEffectiveType,TEquipment(SelectedHoldItem),True))) then Boost := True else Boost := False;
    if Highlight and (Artefact <> nil) and (Artefact.NoDropFlag > 0) then Highlight := False;
    GetByName('Art' + IntToStr(Slot) + 'n').SetActive((Artefact <> nil) and not Highlight and (Artefact.BrokenFlag = 0) and not Boost);
    GetByName('Art' + IntToStr(Slot) + 'b').SetActive((Artefact <> nil) and not Highlight and (Artefact.BrokenFlag <> 0) and not Boost);
    GetByName('Art' + IntToStr(Slot) + 'a').SetActive(Highlight and not Boost);
    GetByName('Art' + IntToStr(Slot) + 'i').SetActive(Artefact <> nil);
    GetByName('Art' + IntToStr(Slot) + 'Ex').SetActive(Boost);
    with GetByName('Art' + IntToStr(Slot) + 'i') as TImageGI do
    begin
      if Artefact = nil then SetImagePath('')
      else
      begin
        SetImagePath('GI,' + GetShopItemIconName(Artefact) + 's');
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
    end;
    with GetByName('Art' + IntToStr(Slot) + 'z') as TZoneGI do
    begin
      SetActive((Artefact <> nil) or Highlight);
      if Highlight or (SelectedHoldKind = phkEmpty) then ZoneMouseDownCallback := ArtefactSlotMouseDown
      else if (Artefact <> nil) and (SelectedHoldKind = phkEquipment) then ZoneMouseDownCallback := UseOnArtefactSlot
      else if (Artefact <> nil) and (SelectedHoldKind = phkArtefact) and not (SelectedHoldItem.ItemType in [t_Artefact..t_ArtefactAntigrav,t_ArtDefToEnergy..t_ArtGiperJump,t_ArtDefToArms1..t_ArtFastRacks]) then ZoneMouseDownCallback := UseOnArtefactSlot
      else ZoneMouseDownCallback := nil;
    end;
    GetByName('Art' + IntToStr(Slot) + 'off').SetActive(False);
  end;
  for Slot := SlotCount to DefaultHullSlotCounts[sskArtefact] - 1 do
  begin
    GetByName('Art' + IntToStr(Slot) + 'n').SetActive(False);
    GetByName('Art' + IntToStr(Slot) + 'b').SetActive(False);
    GetByName('Art' + IntToStr(Slot) + 'a').SetActive(False);
    GetByName('Art' + IntToStr(Slot) + 'i').SetActive(False);
    GetByName('Art' + IntToStr(Slot) + 'z').SetActive(False);
    GetByName('Art' + IntToStr(Slot) + 'Ex').SetActive(False);
    GetByName('Art' + IntToStr(Slot) + 'off').SetActive(True);
  end;
  for I := 0 to 5 do
  begin
    if HoldFirstIndex + I >= PlayerHoldEntries.Count then Entry := nil else Entry := TPlayerHoldUnit(PlayerHoldEntries[HoldFirstIndex + I]);
    with GetByName('S_' + IntToStr(I) + 'i') as TImageGI do
    begin
      if (Entry = nil) or (Entry.Kind = phkEmpty) then SetImagePath('')
      else
      begin
        if Entry.Kind = phkGoods then
            begin
              SetImagePath('GI,' + GetItemTypeBitmapPath(TItemType(Entry.GoodsIndex)));
              SetImageKindX(ikxCenter);
              SetImageKindY(ikyCenter);
            end
        else if Entry.Kind = phkEquipment then
            begin
              SetImagePath('GI,' + GetShopItemIconName(Entry.Item) + 's');
              SetImageKindX(ikxCenter);
              SetImageKindY(ikyCenter);
              if Entry.Item = ScriptUseItem then SetImagePath('');
            end
        else if Entry.Kind = phkArtefact then
            begin
              SetImagePath('GI,' + GetShopItemIconName(Entry.Item) + 's');
              SetImageKindX(ikxCenter);
              SetImageKindY(ikyCenter);
              if Entry.Item = ScriptUseItem then SetImagePath('');
            end;
      end;
    end;
    with GetByName('S_' + IntToStr(I) + 'z') as TZoneGI do ZoneMouseDownCallback := RemoteHoldItemMouseDown;
    GetByName('S_' + IntToStr(I) + 'f').SetActive(SelectedHoldKind <> phkEmpty);
  end;
  for Row := 0 to 10 do
    for Column := 0 to 4 do
    begin
      I := FindPlayerHoldIndexByOrder(RemoteHoldFirstOrder + Column + Row * 5);
      if I < 0 then Entry := nil else Entry := TPlayerHoldUnit(PlayerHoldEntries[I]);
      with RemoteHoldImages[Row * 5 + Column] do
      begin
        if (Entry = nil) or (Entry.Kind = phkEmpty) then SetImagePath('')
        else
        begin
          if Entry.Kind = phkGoods then
              begin
                SetImagePath('GI,' + GetItemTypeBitmapPath(TItemType(Entry.GoodsIndex)));
                SetImageKindX(ikxCenter);
                SetImageKindY(ikyCenter);
              end
          else if Entry.Kind = phkEquipment then
              begin
                SetImagePath('GI,' + GetShopItemIconName(Entry.Item) + 's');
                SetImageKindX(ikxCenter);
                SetImageKindY(ikyCenter);
                if Entry.Item = ScriptUseItem then SetImagePath('');
              end
          else if Entry.Kind = phkArtefact then
              begin
                SetImagePath('GI,' + GetShopItemIconName(Entry.Item) + 's');
                SetImageKindX(ikxCenter);
                SetImageKindY(ikyCenter);
                if Entry.Item = ScriptUseItem then SetImagePath('');
              end;
        end;
      end;
    end;
  if (HighlightRepairableEquipment and PlayerHoldShip.GetHull.NeedsRepair) then GetByName('HullA').SetActive(True)
  else if ((SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_MicroModule) and (PlayerHoldShip.GetHull.MicroModuleIndex = 0) and (SelectedHoldItem as TMicroModule).CanInstallOn(PlayerHoldShip.GetHull)) then GetByName('HullA').SetActive(True)
  else if ((SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem is TEquipmentWithActCode) and (RunItemConfigActionCode(SelectedHoldItem, satOnCheckingUsability,PlayerHoldShip,PlayerHoldShip.GetHull,nil,0) > 0)) then GetByName('HullA').SetActive(True)
  else if ((SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem.ScriptItem <> nil) and (TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnCheckingUsability,PlayerHoldShip,PlayerHoldShip.GetHull,nil,0) > 0)) then GetByName('HullA').SetActive(True)
  else if ((SelectedHoldKind in [phkEquipment,phkArtefact]) and (PlayerHoldShip.GetHull.ScriptItem <> nil) and (TScriptItem(PlayerHoldShip.GetHull.ScriptItem).RunActionCode(satOnCheckingUsability2,PlayerHoldShip,SelectedHoldItem,nil,0) > 0)) then GetByName('HullA').SetActive(True)
  else if ((SelectedHoldKind = phkGoods) and (PlayerHoldShip.GetHull.ScriptItem <> nil) and (TScriptItem(PlayerHoldShip.GetHull.ScriptItem).RunActionCode(satOnCheckingUsabilityGoods,PlayerHoldShip,TObject(SelectedGoodsIndex),TObject(SelectedGoodsQuantity),0) > 0)) then GetByName('HullA').SetActive(True)
  else GetByName('HullA').SetActive((SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_Hull) and IsHoldNormalShip and (TItem(PlayerHoldShip.Inventory[0]).NoDropFlag = 0));
  if (SelectedHoldKind = phkArtefact) and (SelectedHoldItem is TArtefact) and not GetByName('HullA').Active and PlayerHoldShip.CanBoostArtefact(TArtefact(SelectedHoldItem).GetEffectiveType,PlayerHoldShip.GetHull,True) then GetByName('HullEx').SetActive(True)
  else GetByName('HullEx').SetActive(False);
  GetByName('Forsage').SetActive(PlayerHoldShip.GetSlotCount(sskAfterburner) > 0);
  GetByName('ForsageLight').SetActive(PlayerHoldShip.AfterburnerActive and PlayerHoldShip.IsEquipmentUsable(PlayerHoldShip.GetEngine));
  with GetByName('ForsageBut') as TGraphButtonGI do
  begin
    MouseEnterCallback := ShowShipPropertyInfo;
    MouseLeaveCallback := HideShipPropertyInfo;
    UpCallback := ToggleAfterburner;
    SetDisabled(not PlayerHoldShip.IsEquipmentUsable(PlayerHoldShip.GetEngine) or not PlayerHoldShip.InNormalSpace);
  end;
  with GetByName('IDestrEnergy') as TLabelGI do SetText(FormatText2(LocalizedText('FormShip.DestrEnergy'),BrightBlueColorTag,'<Value1>',IntToStr(PlayerHoldShip.GetHull.Energy),'<Value2>',IntToStr(PlayerHoldShip.GetHull.EnergyMax)));
  with GetByName('IDestrShields') as TLabelGI do
  begin
    if PlayerHoldShip.GetHull.ImpulseShieldsEnabled then SetText(LocalizedText('FormShip.DestrIShield'))
    else SetText(LocalizedText('FormShip.DestrNShield'));
  end;
  with GetByName('IDestrCount') as TLabelGI do SetText(FormatText2(LocalizedText('FormShip.DestrCount'),BrightBlueColorTag,'<Count>',IntToStr(PlayerHoldShip.CountActiveInterceptorTargets),'<Cost>',IntToStr(PlayerHoldShip.GetInterceptorEnergyCost)));
  with GetByName('IDestrEnergyOut') as TLabelGI do SetText('-' + FormatText1(LocalizedText('FormShip.DestrPerDay'),BrightBlueColorTag,'<Value>',IntToStr(PlayerHoldShip.CountActiveInterceptorTargets * 3)));
  with GetByName('IDestrEnergyIn') as TLabelGI do SetText('+' + FormatText1(LocalizedText('FormShip.DestrPerDay'),BrightBlueColorTag,'<Value>',IntToStr(PlayerHoldShip.GetHullEnergyRegeneration)));
  RefreshLoadEquippedRocketsButton;
  BuildAdditionalInfoPanel;
  RefreshStorageView;
  ShowItemInfo;
  Galaxy.PrimeIntegrityChecksum1(433);
end;
{ @end $6F86B0 }

{ @routine $6FBB30 TfShip2_RefreshActionPanels }
procedure TfShip2.RefreshActionPanels(Kind: TPlayerHoldKind; Good: Byte; Quantity, Cost: Integer; Item: TItem; Origin: Integer);
var I, TotalRepair: Integer; Equipment: TEquipment; OrdinaryShip: Boolean;
  Unused60, Unused64: Integer; { Two native unused stack slots before managed temporaries. }
  // @nested $6FB6F0 Skill
  procedure Skill(Index, BaseLevel, EffectiveLevel: Integer; CanTrain: Boolean); // @addr $6FB6F0 @calls "0x6FBC2A,0x6FBC66,0x6FBCA2,0x6FBCE1,0x6FBD20,0x6FBD5F" Nested in RefreshActionPanels; captures Self.
  var Step, Gap, Height: Integer;
  begin
    Gap := 2;
    Step := Gap + 5;
    Height := 43;
    with SkillImages[Index] do
    begin
      SetActive(Min(BaseLevel,EffectiveLevel) > 0);
      SetSize(Classes.Point(ClientSize.X,Step * Min(BaseLevel,EffectiveLevel)));
      SetPosition(Classes.Point(LocalPosition.X,Self.SkillImageRestTop[Index] + Height - ClientSize.Y));
      SetImageKindY(ikyBottom);
    end;
    if BaseLevel < EffectiveLevel then
    begin
      with SkillPanels[Index] do
      begin
        SetSize(Classes.Point(ClientSize.X,(EffectiveLevel - BaseLevel) * Step));
        SetPosition(Classes.Point(LocalPosition.X,Self.SkillImageRestTop[Index] + Height - Step * EffectiveLevel));
      end;
      with SkillImagesP[Index] do
      begin
        SetPosition(Classes.Point(LocalPosition.X,-Step * (6 - EffectiveLevel) - 1));
        SetActive(True);
      end;
    end else SkillImagesP[Index].SetActive(False);
    if BaseLevel > EffectiveLevel then
    begin
      with SkillPanels[Index] do
      begin
        SetSize(Classes.Point(ClientSize.X,(BaseLevel - EffectiveLevel) * Step));
        SetPosition(Classes.Point(LocalPosition.X,Self.SkillImageRestTop[Index] + Height - Step * BaseLevel));
      end;
      with SkillImagesN[Index] do
      begin
        SetPosition(Classes.Point(LocalPosition.X,-Step * (6 - BaseLevel) - 1));
        SetActive(True);
      end;
    end else SkillImagesN[Index].SetActive(False);
    with SkillValueLabels[Index] do SetText(IntToStr(EffectiveLevel));
    with SkillProgressImages[Index] do
    begin
      if EffectiveLevel > BaseLevel then SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'DSGreen')
      else if EffectiveLevel < BaseLevel then SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'DSRed')
      else SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'DSBlue');
    end;
    with SkillGainImages[Index] do SetActive(CanTrain);
  end;
begin
  OrdinaryShip := not (PlayerHoldShip is TRuins) and not (PlayerHoldShip is TTranclucator);
  with FreeSkillPointsLabel do SetText(IntToStr(PlayerHoldShip.FreeExperience));
  with ExperienceLabel do SetText(IntToStr(PlayerHoldShip.FreeExperience));
  Skill(0,PlayerHoldShip.GetBaseSkillLevel(psAccuracy),PlayerHoldShip.GetEffectiveSkillLevel(psAccuracy),PlayerHoldShip.CanTrainSkill(psAccuracy));
  Skill(1,PlayerHoldShip.GetBaseSkillLevel(psManeuverability),PlayerHoldShip.GetEffectiveSkillLevel(psManeuverability),PlayerHoldShip.CanTrainSkill(psManeuverability));
  Skill(2,PlayerHoldShip.GetBaseSkillLevel(psTechnical),PlayerHoldShip.GetEffectiveSkillLevel(psTechnical),PlayerHoldShip.CanTrainSkill(psTechnical));
  Skill(3,PlayerHoldShip.GetBaseSkillLevel(psTrading),PlayerHoldShip.GetEffectiveSkillLevel(psTrading),PlayerHoldShip.CanTrainSkill(psTrading) and OrdinaryShip);
  Skill(4,PlayerHoldShip.GetBaseSkillLevel(psCharisma),PlayerHoldShip.GetEffectiveSkillLevel(psCharisma),PlayerHoldShip.CanTrainSkill(psCharisma) and OrdinaryShip);
  Skill(5,PlayerHoldShip.GetBaseSkillLevel(psLeadership),PlayerHoldShip.GetEffectiveSkillLevel(psLeadership),PlayerHoldShip.CanTrainSkill(psLeadership) and OrdinaryShip);
  with SkillButtons[0] do
  begin
    UserValue := 0;
    SetActive(PlayerHoldShip.CanTrainSkill(psAccuracy));
    UpCallback := TrainSkillClicked;
  end;
  with SkillButtons[1] do
  begin
    UserValue := 1;
    SetActive(PlayerHoldShip.CanTrainSkill(psManeuverability));
    UpCallback := TrainSkillClicked;
  end;
  with SkillButtons[2] do
  begin
    UserValue := 2;
    SetActive(PlayerHoldShip.CanTrainSkill(psTechnical));
    UpCallback := TrainSkillClicked;
  end;
  with SkillButtons[3] do
  begin
    UserValue := 3;
    SetActive(PlayerHoldShip.CanTrainSkill(psTrading) and OrdinaryShip);
    UpCallback := TrainSkillClicked;
  end;
  with SkillButtons[4] do
  begin
    UserValue := 4;
    SetActive(PlayerHoldShip.CanTrainSkill(psCharisma) and OrdinaryShip);
    UpCallback := TrainSkillClicked;
  end;
  with SkillButtons[5] do
  begin
    UserValue := 5;
    SetActive(PlayerHoldShip.CanTrainSkill(psLeadership) and OrdinaryShip);
    UpCallback := TrainSkillClicked;
  end;
  if ((Kind = phkEquipment) or (Kind = phkArtefact)) and (Item as TEquipment).NeedsRepair and
    ((Item.ItemType <> t_Protoplasm) or (GetPlayer.DockedTo.TypeId <> Byte(rstRangerCenter))) and not PreserveSpaceMusic and (GetPlayer.IsDockedToShip or (GetPlayer.IsOnPlanet and not (GetPlayer.CurrentPlanet.OwnerId in [oiDominator,oiUninhabited]))) then
  begin
    OpenSpecialSlot1;
    with GetByName('SC_Slot1_Text') as TLabelGI do
      SetText(FormatText1(LocalizedText('FormShip.Repair'),'','<Money>',IntToStr((Item as TEquipment).CalculateRepairCost)));
  end else CloseSpecialSlot1;
  if ((Kind = phkGoods) or (Kind = phkEquipment) or (Kind = phkArtefact)) and
    ((Kind = phkGoods) or (Item = nil) or ((Item.ScriptItem = nil) and (Item.NoDropFlag = 0)) or
    ((Item.ScriptItem <> nil) and TScriptItem(Item.ScriptItem).CanSell)) and
    ((Kind = phkGoods) or (Kind = phkArtefact) or not (Item is THull) or (Origin <> 0)) and not PreserveSpaceMusic and (GetPlayer.IsDockedToShip or (GetPlayer.IsOnPlanet and not (GetPlayer.CurrentPlanet.OwnerId in [oiDominator,oiUninhabited]))) then
  begin
    OpenSpecialSlot2;
    with GetByName('SC_Slot2_Text') as TLabelGI do
    begin
      if Kind = phkGoods then
        SetText(FormatText1(LocalizedText('FormShip.Sell'),'','<Money>',IntToStr(Quantity * GetPlayer.ShopGoodsSellPrice(Good,nil))))
      else SetText(FormatText1(LocalizedText('FormShip.Sell'),'','<Money>',IntToStr(Item.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading)))));
    end;
  end else CloseSpecialSlot2;
  if (Kind = phkEquipment) and (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and
    (TWeapon(Item).Ammo < TWeapon(Item).AmmoCapacity) and not PreserveSpaceMusic and (GetPlayer.IsDockedToShip or (GetPlayer.IsOnPlanet and not (GetPlayer.CurrentPlanet.OwnerId in [oiDominator,oiUninhabited]))) then
  begin
    OpenSpecialSlot3;
    with GetByName('SC_Slot3_Text') as TLabelGI do
      SetText(FormatText1(LocalizedText('FormShip.Missile'),'','<Money>',IntToStr((TWeapon(Item).AmmoCapacity - TWeapon(Item).Ammo) * Galaxy.ScaleIntByTechLevel(10,100))));
  end
  else if (Kind = phkEquipment) and (Item is TCistern) and ((Item as TCistern).Fuel < (Item as TCistern).Capacity) and not PreserveSpaceMusic and (GetPlayer.IsDockedToShip or (GetPlayer.IsOnPlanet and not (GetPlayer.CurrentPlanet.OwnerId in [oiDominator,oiUninhabited]))) then
  begin
    OpenSpecialSlot3;
    with GetByName('SC_Slot3_Text') as TLabelGI do
    begin
      if GetPlayer.IsOnPlanet then I := CalculateRoundedFuelCost((Item as TCistern).Capacity - (Item as TCistern).Fuel,GetPlayer.CurrentPlanet.OwnerId)
      else I := CalculateRoundedFuelCost((Item as TCistern).Capacity - (Item as TCistern).Fuel, oiUninhabited);
      SetText(FormatText1(LocalizedText('FormShip.Fuel'),'','<Money>',IntToStr(I)));
    end;
  end
  else if (Kind = phkEquipment) and (Item is TFuelTanks) and ((Item as TFuelTanks).Fuel < (Item as TFuelTanks).Capacity) and not PreserveSpaceMusic and (GetPlayer.IsDockedToShip or (GetPlayer.IsOnPlanet and not (GetPlayer.CurrentPlanet.OwnerId in [oiDominator,oiUninhabited]))) then
  begin
    OpenSpecialSlot3;
    with GetByName('SC_Slot3_Text') as TLabelGI do
    begin
      if GetPlayer.IsOnPlanet then I := CalculateRoundedFuelCost((Item as TFuelTanks).Capacity - (Item as TFuelTanks).Fuel,GetPlayer.CurrentPlanet.OwnerId)
      else I := CalculateRoundedFuelCost((Item as TFuelTanks).Capacity - (Item as TFuelTanks).Fuel, oiUninhabited);
      SetText(FormatText1(LocalizedText('FormShip.Fuel'),'','<Money>',IntToStr(I)));
    end;
  end
  else CloseSpecialSlot3;
  TotalRepair := 0;
  for I := 0 to PlayerHoldShip.Inventory.Count - 1 do
  begin
    Equipment := PlayerHoldShip.Inventory[I];
    if (not (Equipment is TWeapon) or (TWeapon(Equipment).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair) or GetPlayer.CanRepairArtefactsAtLocation) then
      if PlayerHoldShip.CanRepairEquipmentTech(Equipment) and (Equipment <> Item) and
        ((Equipment.EquippedFlag <> 0) or (Equipment is THull)) and Equipment.NeedsRepair then
        Inc(TotalRepair,Equipment.CalculateRepairCost);
  end;
  with GetByName('FullRepareSum') as TLabelGI do
  begin
    if TotalRepair > 0 then SetText(FormatText1(LocalizedText('FormShip.RepairAll'),'','<Money>',IntToStr(TotalRepair)))
    else SetText(LocalizedText('FormShip.FullRepareNo'));
  end;
  with GetByName('SC_RepareFull_But') as TGraphButtonGI do
  begin
    SetDisabled(TotalRepair <= 0);
    UpCallback := RepairAllClicked;
    MouseEnterCallback := RepairAllMouseEnter;
    MouseLeaveCallback := RepairAllMouseLeave;
  end;
end;
{ @end $6FBB30 }

{ @routine $6FCABC TfShip2_UpdateActionCursor }
procedure TfShip2.UpdateActionCursor(CanTake: Boolean);
begin
  if SelectedHoldKind = phkEmpty then
  begin
    if CanTake then
    begin
      if not IsCursorImageSelected('Take') then SetCursorByName('Take');
    end
    else if not IsCursorImageSelected('Main') then SetCursorByName('Main');
  end
  else if SelectedHoldKind = phkEquipment then SetCursorImage('GI,' + GetShopItemIconName(TItem(SelectedHoldItem)) + 's',Classes.Point(16,16))
  else if SelectedHoldKind = phkGoods then SetCursorImage('GI,' + GetItemTypeBitmapPath(TItemType(SelectedGoodsIndex)),Classes.Point(16,16))
  else if SelectedHoldKind = phkArtefact then SetCursorImage('GI,' + GetShopItemIconName(TItem(SelectedHoldItem)) + 's',Classes.Point(16,16));
end;
{ @end $6FCABC }

{ @routine $6FCCA4 TfShip2_TrainSkillClicked }
procedure TfShip2.TrainSkillClicked(Sender: TObjectGI);
begin
  Galaxy.CheckIntegrityChecksum1(434);
  PlayerHoldShip.TrainSkill(TPilotSkill(Sender.UserValue));
  if CanUsePlayerExperience then GetPlayer.FreeExperience := PlayerHoldShip.FreeExperience;
  Galaxy.PrimeIntegrityChecksum1(435);
  RefreshShipView;
  ShowShipPropertyInfo(GetByName('Skill' + IntToStr(Cardinal(Sender.UserValue)) + 'z'));
  Galaxy.CheckIntegrityChecksum1(436);
  if GetPlayer = PlayerHoldShip then GetPlayer.AchievementStats.CheckAllSkillsAchievement;
  PlayerHoldShip.ScriptItemsAct(satOnPlayerSkillIncrease,nil,nil,0);
  Galaxy.PrimeIntegrityChecksum1(437);
end;
{ @end $6FCCA4 }

{ @routine $6FCE0C TfShip2_EquipmentSlotMouseDown }
procedure TfShip2.EquipmentSlotMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  ItemType: TItemType;
  Slot, Quantity: Integer;
  Item: TEquipment;
  Text: WideString;
  ActionResult: Integer;
begin
  ItemType := SlotToTip(Sender.ControlName);
  Slot := ExtractDigitsToIntW(Sender.ControlName);
  if (SelectedHoldKind = phkEmpty) and (PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot) = nil) then Exit;
  if (GetPlayer.InHyperspace or (QueuedArcadeBattles.Count > 0)) and not Galaxy.IsArcadeEquipmentChangeEnabled then
  begin
    SoundManager.PlaySound('Sound.NoMoney');
    ShowMessageBoxGI(Self,LocalizedColorText('FormShip.NoEquipChangeInHyper'),mbgOK);
    Exit;
  end;
  Galaxy.CheckIntegrityChecksum1(438);
  if SelectedHoldKind = phkEmpty then
  begin
    Item := PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot);
    if Item <> nil then
    begin
      if (PlayerHoldShip is TRuins) and ((Item is TEngine) or (Item is TFuelTanks) or ((Item is TCargoHook) and (PlayerHoldShip.TypeId = Byte(rstDominion)))) then
      begin
        SoundManager.PlaySound('Sound.NoMoney');
        ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.RuinMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(Item.GetDisplayName)),mbgCancel or mbgWarning);
        Exit;
      end;
      if (PlayerHoldShip is TTranclucator) and ((Item is TEngine) or (Item is TFuelTanks)) then
      begin
        SoundManager.PlaySound('Sound.NoMoney');
        ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.TrancMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(Item.GetDisplayName)),mbgCancel or mbgWarning);
        Exit;
      end;
      if Item.EquippedFlag <> 0 then PlayerHoldShip.UnequipItem(Item);
      PlayerHoldShip.Inventory.Delete(PlayerHoldShip.Inventory.IndexOf(Item));
      PlayerHoldShip.RebuildEquipmentCache;
      PlayerHoldShip.RefreshDerivedStats(True);
      SelectedHoldKind := phkEquipment;
      SelectedHoldOrigin := 0;
      SelectedHoldSlot := -(Slot + 1);
      SelectedHoldUsesDisplayOrder := False;
      SelectedHoldItem := Item;
      if Item is TWeapon then (Item as TWeapon).Target := nil;
      UpdateActionCursor(True);
      Galaxy.PrimeIntegrityChecksum1(439);
      SoundManager.PlaySound('Sound.SlotGet');
    end;
  end
  else
  begin
    if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_MicroModule) and
      (PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot) <> nil) and (PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot).MicroModuleIndex = 0) and
      (SelectedHoldItem as TMicroModule).CanInstallOn(PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot)) then
    begin
      Item := PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot);
      Text := FormatText2(LocalizedText('MicroModuls.AddToItem'),TextHighlightColorTag,'<ModuleName>',(SelectedHoldItem as TMicroModule).GetPlainName,'<ItemName>',RemoveTextTagsW(Item.GetDisplayName));
      if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
      begin
        PlayerHoldShip.ScriptItemsAct(satOnPlayerUseMM,Item,SelectedHoldItem,0);
        ApplyMicroModule((SelectedHoldItem as TMicroModule).MicroModuleIndex - 1,Item);
        SelectedHoldItem.Free;
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
        PlayerHoldShip.RefreshDerivedStats(True);
        UpdateActionCursor(True);
        Galaxy.PrimeIntegrityChecksum1(440);
      end;
    end
    else if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_Cistern) and ((SelectedHoldItem as TCistern).Fuel > 0) and
      (ItemType = t_FuelTanks) and (PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot) <> nil) and
      ((PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot) as TFuelTanks).Fuel < (PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot) as TFuelTanks).Capacity) then
    begin
      Item := PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot);
      Text := LocalizedColorText('Items.Cistern.ToFuelTanks');
      if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
      begin
        Quantity := Min((SelectedHoldItem as TCistern).Fuel,(Item as TFuelTanks).Capacity - (Item as TFuelTanks).Fuel);
        Dec((SelectedHoldItem as TCistern).Fuel,Quantity);
        Inc((Item as TFuelTanks).Fuel,Quantity);
        PlayerHoldShip.RefreshDerivedStats(True);
        UpdateActionCursor(True);
        Galaxy.PrimeIntegrityChecksum1(441);
      end;
    end
    else if (SelectedHoldKind = phkEquipment) and IsCompatibleSlot(ItemType,SelectedHoldItem.ItemType) then
    begin
      Item := PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot);
      if (Item <> nil) and (Item.EquippedFlag <> 0) then PlayerHoldShip.UnequipItem(Item);
      PlayerHoldShip.Inventory.Add(SelectedHoldItem);
      (SelectedHoldItem as TEquipment).AssignedSlotData := ((SelectedHoldItem as TEquipment).AssignedSlotData and EquipmentSecondaryFireFlag) or Slot;
      (SelectedHoldItem as TEquipment).Equip;
      if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
      SoundManager.PlaySound('Sound.SlotPut');
      if (PlayerHoldShip is TTranclucator) and (SelectedHoldItem is TWeapon) and (TWeapon(SelectedHoldItem).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and (PlayerHoldShip.GetRadar = nil) then
        ShowMessageBoxGI(Self,LocalizedColorText('FormShip.TrancMissileWarning'),mbgOK or mbgWarning);
      SelectedHoldKind := phkEmpty;
      SelectedHoldItem := nil;
      if Item <> nil then
      begin
        PlayerHoldShip.Inventory.Delete(PlayerHoldShip.Inventory.IndexOf(Item));
        SelectedHoldKind := phkEquipment;
        SelectedHoldOrigin := 0;
        SelectedHoldSlot := -(Slot + 1);
        SelectedHoldUsesDisplayOrder := False;
        SelectedHoldItem := Item;
      end;
      UpdateActionCursor(True);
      Galaxy.PrimeIntegrityChecksum1(442);
    end
    else if (SelectedHoldKind in [phkGoods]) and (PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot) <> nil) then
    begin
      Item := PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot);
      ActionResult := 0;
      if Item.ScriptItem <> nil then ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(satOnAnotherGoods,PlayerHoldShip,TObject(SelectedGoodsIndex),TObject(SelectedGoodsQuantity),0);
      if ActionResult <> 0 then
      begin
        Quantity := Abs(ActionResult);
        if Quantity < SelectedGoodsQuantity then
        begin
          Dec(SelectedGoodsCost,Round(Quantity / SelectedGoodsQuantity * SelectedGoodsCost));
          Dec(SelectedGoodsQuantity,Quantity);
        end
        else
        begin
          SelectedHoldKind := phkEmpty;
          SelectedGoodsQuantity := 0;
          SelectedGoodsCost := 0;
        end;
      end;
      PlayerHoldShip.RefreshDerivedStats(True);
      UpdateActionCursor(True);
      Galaxy.PrimeIntegrityChecksum1(440);
      if ActionResult < 0 then CloseClicked(nil);
    end
    else if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot) <> nil) then
    begin
      Item := PlayerHoldShip.FindEquippedItemInSlot(ItemType,Slot);
      ActionResult := 0;
      if SelectedHoldItem.ScriptItem <> nil then ActionResult := TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnAnotherItem,PlayerHoldShip,Item,nil,ActionResult);
      if SelectedHoldItem is TEquipmentWithActCode then ActionResult := RunItemConfigActionCode(SelectedHoldItem, satOnAnotherItem,PlayerHoldShip,Item,nil,ActionResult);
      if Item.ScriptItem <> nil then ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
      if Item is TEquipmentWithActCode then ActionResult := RunItemConfigActionCode(Item, satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
      if ActionResult in [1,3] then
      begin
        SelectedHoldItem.Free;
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
      end;
      PlayerHoldShip.RefreshDerivedStats(True);
      UpdateActionCursor(True);
      Galaxy.PrimeIntegrityChecksum1(440);
      if ActionResult = 3 then CloseClicked(nil);
    end;
  end;
  if PlayerHoldShip.InHyperspace or (QueuedArcadeBattles.Count > 0) then RefreshShipView
  else if not RemoteHoldVisible then
  begin
    ShipStateChanged := True;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $6FCE0C }

{ @routine $6FDC50 TfShip2_ArtefactSlotMouseDown }
procedure TfShip2.ArtefactSlotMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Slot: Integer;
  Equipment: TEquipment;
  Item: TArtefact;
begin
  Slot := ExtractDigitsToIntW(Sender.ControlName);
  Galaxy.CheckIntegrityChecksum1(443);
  if SelectedHoldKind = phkEmpty then
  begin
    Equipment := PlayerHoldShip.FindEquippedItemInSlot(t_Artefact,Slot);
    if Equipment <> nil then
    begin
      Item := Equipment as TArtefact;
      Item.Unequip;
      PlayerHoldShip.Artefacts.Delete(PlayerHoldShip.Artefacts.IndexOf(Item));
      PlayerHoldShip.RefreshDerivedStats(True);
      SelectedHoldKind := phkArtefact;
      SelectedHoldOrigin := 0;
      SelectedHoldSlot := -(Slot + 1);
      SelectedHoldUsesDisplayOrder := False;
      SelectedHoldItem := Item;
      Galaxy.PrimeIntegrityChecksum1(444);
      UpdateActionCursor(True);
      SoundManager.PlaySound('Sound.SlotGet');
    end;
  end
  else if SelectedHoldKind = phkArtefact then
  begin
    Equipment := PlayerHoldShip.FindEquippedItemInSlot(t_Artefact,Slot);
    if (Equipment <> nil) and (Equipment.EquippedFlag <> 0) then Equipment.Unequip;
    PlayerHoldShip.Artefacts.Add(SelectedHoldItem);
    (SelectedHoldItem as TEquipment).AssignedSlotData := Slot;
    (SelectedHoldItem as TEquipment).EquippedFlag := 0;
    (SelectedHoldItem as TEquipment).Equip;
    SelectedHoldKind := phkEmpty;
    SelectedHoldItem := nil;
    SoundManager.PlaySound('Sound.SlotPut');
    if Equipment <> nil then
    begin
      PlayerHoldShip.Artefacts.Delete(PlayerHoldShip.Artefacts.IndexOf(Equipment));
      SelectedHoldKind := phkArtefact;
      SelectedHoldOrigin := 0;
      SelectedHoldSlot := -(Slot + 1);
      SelectedHoldUsesDisplayOrder := False;
      SelectedHoldItem := Equipment;
    end;
    Galaxy.PrimeIntegrityChecksum1(444);
    UpdateActionCursor(True);
  end;
  if PlayerHoldShip.InHyperspace or (QueuedArcadeBattles.Count > 0) then
  begin
    RefreshShipView;
    Galaxy.PrimeIntegrityChecksum1(445);
  end
  else if not RemoteHoldVisible then
  begin
    ShipStateChanged := True;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $6FDC50 }

{ @routine $6FDF68 TfShip2_UseOnArtefactSlot }
procedure TfShip2.UseOnArtefactSlot(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Slot, Quantity: Integer;
  Item: TItem;
  ActionResult: Integer;
begin
  Slot := ExtractDigitsToIntW(Sender.ControlName);
  Galaxy.CheckIntegrityChecksum1(443);
  Item := PlayerHoldShip.FindEquippedItemInSlot(t_Artefact,Slot);
  if Item = nil then Exit;
  if SelectedHoldKind in [phkGoods] then
  begin
    if Item.ScriptItem <> nil then
      ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(satOnAnotherGoods,PlayerHoldShip,TObject(SelectedGoodsIndex),TObject(SelectedGoodsQuantity),0)
    else ActionResult := RunItemConfigActionCode(Item, satOnAnotherGoods,PlayerHoldShip,TObject(SelectedGoodsIndex),TObject(SelectedGoodsQuantity),0);
    if ActionResult <> 0 then
    begin
      Quantity := Abs(ActionResult);
      if Quantity < SelectedGoodsQuantity then
      begin
        Dec(SelectedGoodsCost,Round(Quantity / SelectedGoodsQuantity * SelectedGoodsCost));
        Dec(SelectedGoodsQuantity,Quantity);
      end
      else
      begin
        SelectedHoldKind := phkEmpty;
        SelectedGoodsQuantity := 0;
        SelectedGoodsCost := 0;
      end;
    end;
    PlayerHoldShip.RefreshDerivedStats(True);
    UpdateActionCursor(True);
    Galaxy.PrimeIntegrityChecksum1(440);
    if ActionResult < 0 then CloseClicked(nil);
  end
  else if SelectedHoldKind in [phkEquipment,phkArtefact] then
  begin
    ActionResult := 0;
    if SelectedHoldItem.ScriptItem <> nil then
      ActionResult := TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnAnotherItem,PlayerHoldShip,Item,nil,ActionResult);
    if SelectedHoldItem is TEquipmentWithActCode then
      ActionResult := RunItemConfigActionCode(SelectedHoldItem, satOnAnotherItem,PlayerHoldShip,Item,nil,ActionResult);
    if Item.ScriptItem <> nil then
      ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
    ActionResult := RunItemConfigActionCode(Item, satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
    if ActionResult in [1,3] then
    begin
      SelectedHoldItem.Free;
      SelectedHoldKind := phkEmpty;
      SelectedHoldItem := nil;
    end;
    PlayerHoldShip.RefreshDerivedStats(True);
    UpdateActionCursor(True);
    Galaxy.PrimeIntegrityChecksum1(440);
    if ActionResult = 3 then CloseClicked(nil);
  end
  else Exit;
  if PlayerHoldShip.InHyperspace or (QueuedArcadeBattles.Count > 0) then
  begin
    RefreshShipView;
    Galaxy.PrimeIntegrityChecksum1(445);
  end
  else if not RemoteHoldVisible then
  begin
    ShipStateChanged := True;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $6FDF68 }

{ @routine $6FE338 TfShip2_RemoteHoldItemMouseDown }
procedure TfShip2.RemoteHoldItemMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Index, J, Count, Missing, DialogCount, Available: Integer;
  Text: WideString;
  Equipment: TEquipment;
  Entry, Swap: TPlayerHoldUnit;
  Stack: TCountableItem;
  ReservedCisternFrom, ReservedCisternTo: TCistern;
  FuelFrom, FuelTo: TFuelTanks;
  Expanded, NeedsRefresh: Boolean;
  ActionResult: Integer;
  // @nested $6FE29C RefreshAfterTransfer
  procedure RefreshAfterTransfer; // @addr $6FE29C @calls "0x6FE4D2,0x6FEAFA,0x6FF231,0x6FFE42,0x70028B,0x700294" Captures Self and NeedsRefresh.
  begin
    Galaxy.PrimeIntegrityChecksum1(445);
    if PlayerHoldShip.InHyperspace or (QueuedArcadeBattles.Count > 0) or
      (RemoteHoldVisible and NeedsRefresh) then RefreshShipView
    else if not RemoteHoldVisible then
    begin
      ShipStateChanged := True;
      ReopenRequested := True;
      PlayTransitionSounds := False;
      CloseClicked(nil);
    end;
  end;
begin
  Index := ExtractDigitsToIntW(Sender.ControlName);
  Expanded := Sender is TImageGI;
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_Hull) then
  begin
    if not RemoteHoldVisible then
      ShowMessageBoxGI(Self,LocalizedText('FormShip.HullInHoldError'),mbgCancel or mbgWarning);
    Exit;
  end;
  if not Expanded then
    begin
    Inc(Index,HoldFirstIndex);
    if (Index < 0) or (PlayerHoldEntries.Count <= Index) then Entry := nil else Entry := TPlayerHoldUnit(PlayerHoldEntries[Index]);
  end
    else
    begin
    Inc(Index,RemoteHoldFirstOrder);
    J := FindPlayerHoldIndexByOrder(Index);
    if J < 0 then Entry := nil else Entry := TPlayerHoldUnit(PlayerHoldEntries[J]);
  end;
  if (SelectedHoldKind = phkEmpty) and (Entry = nil) then Exit;
  NeedsRefresh := False;
  Galaxy.CheckIntegrityChecksum1(446);
  if SelectedHoldKind = phkEmpty then
  begin
    if Entry <> nil then
    begin
      TakeHoldEntry(Entry,Index,Expanded);
      NeedsRefresh := True;
      PlayerHoldShip.RefreshDerivedStats(True);
      UpdateActionCursor(True);
      SoundManager.PlaySound('Sound.SlotGet');
    end;
    RefreshAfterTransfer;
    Exit;
  end;
  if SelectedHoldKind = phkGoods then
  begin
    Count := SelectedGoodsQuantity;
    if not RemoteHoldVisible then
    begin
      Available := Max(0,PlayerHoldShip.CargoFreeSpace);
      DialogCount := Min(Count,Available);
      if (SelectedHoldOrigin = 1) and (not Expanded or (Entry = nil)) and (Count > 1) then
      begin
        if Count > 1 then
        if ShowCountDialog(Self,'GI,' + GetItemTypeBitmapPath(TItemType(SelectedGoodsIndex)),
          FormatText1(LocalizedText('FormShip.FromStorageItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemTypeName(TItemType(SelectedGoodsIndex)))),
          0,Count,Count,0,Available,0,DialogCount) <> 1 then
        begin
          Galaxy.PrimeIntegrityChecksum1(459);
          Exit;
        end;
        Count := DialogCount;
      end;
    end;
    if (Count < 1) or (SelectedGoodsQuantity < Count) then
    begin
      Galaxy.PrimeIntegrityChecksum1(460);
      Exit;
    end;
    if (Entry <> nil) and (Entry.Kind in [phkEquipment,phkArtefact]) then
    begin
      if Entry.Item.ScriptItem <> nil then
        ActionResult := TScriptItem(Entry.Item.ScriptItem).RunActionCode(satOnAnotherGoods,PlayerHoldShip,TObject(SelectedGoodsIndex),TObject(Count),0)
      else ActionResult := RunItemConfigActionCode(Entry.Item, satOnAnotherGoods,PlayerHoldShip,TObject(SelectedGoodsIndex),TObject(Count),0);
      if ActionResult <> 0 then
      begin
        Count := Min(Count,Abs(ActionResult));
        if Count < SelectedGoodsQuantity then
        begin
          Dec(SelectedGoodsCost,Round(Count / SelectedGoodsQuantity * SelectedGoodsCost));
          Dec(SelectedGoodsQuantity,Count);
        end
        else
        begin
          SelectedHoldKind := phkEmpty;
          SelectedGoodsQuantity := 0;
          SelectedGoodsCost := 0;
        end;
        PlayerHoldShip.RefreshDerivedStats(True);
        UpdateActionCursor(True);
        Galaxy.PrimeIntegrityChecksum1(4440);
        if ActionResult < 0 then CloseClicked(nil);
        Exit;
      end;
    end;
    Inc(PlayerHoldShip.CargoGoods[SelectedGoodsIndex].Count,Count);
    Inc(PlayerHoldShip.CargoGoods[SelectedGoodsIndex].TotalCost,Round(Count / SelectedGoodsQuantity * SelectedGoodsCost));
    SoundManager.PlaySound('Sound.SlotPut');
    if not Expanded then
    begin
      if Entry = nil then
    begin
        Missing := Index - PlayerHoldEntries.Count + 1;
        for J := 0 to Missing - 1 do
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
          Entry.Kind := phkEmpty;
        end;
        Entry := TPlayerHoldUnit(PlayerHoldEntries[PlayerHoldEntries.Count - 1]);
      end
    else
    begin
        if Entry.Kind <> phkEmpty then
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Insert(Index,Entry);
          Entry.Kind := phkEmpty;
        end;
      end;
      Entry.DisplayOrder := FindFreePlayerHoldOrder;
      Entry.Kind := phkGoods;
      Entry.GoodsIndex := SelectedGoodsIndex;
      Dec(SelectedGoodsCost,Round(Count / SelectedGoodsQuantity * SelectedGoodsCost));
      Dec(SelectedGoodsQuantity,Count);
      RemoveEmptyPlayerHoldSlot(PlayerHoldEntries.IndexOf(Entry) + 1);
      if SelectedGoodsQuantity <= 0 then SelectedHoldKind := phkEmpty else ReturnSelectedHoldEntry;
    end
    else
    begin
      Swap := nil;
      if Entry = nil then
    begin
        Entry := TPlayerHoldUnit.Create;
        PlayerHoldEntries.Add(Entry);
      end
    else
    begin
        if Entry.Kind <> phkEmpty then
        begin
          Swap := Entry;
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
        end;
      end;
      Entry.DisplayOrder := Index;
      Entry.Kind := phkGoods;
      Entry.GoodsIndex := SelectedGoodsIndex;
      Dec(SelectedGoodsCost,Round(Count / SelectedGoodsQuantity * SelectedGoodsCost));
      Dec(SelectedGoodsQuantity,Count);
      if Swap <> nil then
      begin
        if SelectedGoodsQuantity > 0 then RaiseWideMessage('move goods');
        TakeHoldEntry(Swap,Index,Expanded);
      end
      else if SelectedGoodsQuantity <= 0 then
      begin
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
      end
      else ReturnSelectedHoldEntry;
      RestorePlayerHoldDisplayOrder;
    end;
    for J := PlayerHoldEntries.Count - 1 downto 0 do
    begin
      Swap := TPlayerHoldUnit(PlayerHoldEntries[J]);
      if (Swap.Kind = phkGoods) and (SelectedGoodsIndex = Swap.GoodsIndex) and (Entry <> Swap) then
      begin
        if not Expanded then
    begin
          Swap.Item := nil;
          Swap.Kind := phkEmpty;
        end
    else
    begin
          PlayerHoldEntries.Delete(J);
          Swap.Free;
        end;
      end;
    end;
    PlayerHoldShip.RefreshDerivedStats(True);
    UpdateActionCursor(True);
    RefreshAfterTransfer;
    Exit;
  end;
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TCountableItem) then
  begin
    Count := TCountableItem(SelectedHoldItem).StackCount;
    if not RemoteHoldVisible then
    begin
      Available := Max(0,PlayerHoldShip.CargoFreeSpace);
      DialogCount := Min(Count,Available);
      if (SelectedHoldOrigin = 1) and (not Expanded or (Entry = nil) or TCountableItem(SelectedHoldItem).CanMerge(Entry.Item)) then
      begin
        if Count > 1 then
          if ShowCountDialog(Self,'GI,' + GetShopItemIconName(SelectedHoldItem) + 's',
            FormatText1(LocalizedText('FormShip.FromStorageItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemName(SelectedHoldItem))),
            0,Count,Count,0,Available,0,DialogCount) <> 1 then Exit;
        Count := DialogCount;
      end;
    end;
    if (TCountableItem(SelectedHoldItem).StackCount <> Count) or
      ((Entry <> nil) and TCountableItem(SelectedHoldItem).CanMerge(Entry.Item)) then
    begin
      if not RemoteHoldVisible and (SelectedHoldOrigin = 0) and (Entry <> nil) and (Entry.Item <> nil) and
        (Entry.Kind in [phkEquipment,phkArtefact]) and not TCountableItem(SelectedHoldItem).CanMerge(Entry.Item) then
      begin
        ActionResult := 0;
        if SelectedHoldItem.ScriptItem <> nil then
          ActionResult := TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnAnotherItem,PlayerHoldShip,Entry.Item,nil,ActionResult);
        if Entry.Item.ScriptItem <> nil then
          ActionResult := TScriptItem(Entry.Item.ScriptItem).RunActionCode(satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
        if Entry.Item is TEquipmentWithActCode then
          ActionResult := RunItemConfigActionCode(Entry.Item, satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
        if ActionResult in [1,3] then
        begin
          SelectedHoldItem.Free;
          SelectedHoldKind := phkEmpty;
          SelectedHoldItem := nil;
        end;
        if ActionResult in [1..3] then
        begin
          PlayerHoldShip.RefreshDerivedStats(True);
          Galaxy.PrimeIntegrityChecksum1(461);
          UpdateActionCursor(True);
          RefreshShipView;
          if ActionResult = 3 then CloseClicked(nil);
          Exit;
        end;
        Count := TCountableItem(SelectedHoldItem).StackCount;
      end;
      if (Count < 1) or (TCountableItem(SelectedHoldItem).StackCount < Count) then Exit;
      if Count < TCountableItem(SelectedHoldItem).StackCount then
      begin
        Stack := TCountableItem(SelectedHoldItem).Split(Count);
        if (Entry <> nil) and (Entry.Item <> nil) and Stack.CanMerge(Entry.Item) then
        begin
          TCountableItem(Entry.Item).Merge(Stack);
          Stack.Free;
          ReturnSelectedHoldEntry;
          Exit;
        end;
        PlayerHoldShip.Inventory.Add(Stack);
      end
      else
      begin
        Stack := TCountableItem(SelectedHoldItem);
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
        if (Entry <> nil) and (Entry.Item <> nil) and Stack.CanMerge(Entry.Item) then
        begin
          TCountableItem(Entry.Item).Merge(Stack);
          Stack.Free;
          SelectedHoldItem := nil;
          SelectedHoldKind := phkEmpty;
          Exit;
        end;
        PlayerHoldShip.Inventory.Add(Stack);
      end;
      SoundManager.PlaySound('Sound.SlotPut');
      if not Expanded then
    begin
      if Entry = nil then
    begin
        Missing := Index - PlayerHoldEntries.Count + 1;
        for J := 0 to Missing - 1 do
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
          Entry.Kind := phkEmpty;
        end;
        Entry := TPlayerHoldUnit(PlayerHoldEntries[PlayerHoldEntries.Count - 1]);
      end
    else
    begin
        if Entry.Kind <> phkEmpty then
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Insert(Index,Entry);
          Entry.Kind := phkEmpty;
        end;
      end;
      Entry.DisplayOrder := FindFreePlayerHoldOrder;
      Entry.Kind := phkEquipment;
      Entry.ItemId := Stack.Id;
      Entry.Item := Stack;
      RemoveEmptyPlayerHoldSlot(PlayerHoldEntries.IndexOf(Entry) + 1);
      if SelectedHoldItem <> nil then ReturnSelectedHoldEntry;
      end
    else
    begin
      Swap := nil;
      if Entry = nil then
    begin
        Entry := TPlayerHoldUnit.Create;
        PlayerHoldEntries.Add(Entry);
      end
    else
    begin
        if Entry.Kind <> phkEmpty then
        begin
          Swap := Entry;
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
        end;
      end;
      Entry.DisplayOrder := Index;
      Entry.Kind := phkEquipment;
      Entry.ItemId := Stack.Id;
      Entry.Item := Stack;
      if Swap <> nil then
      begin
        if TCountableItem(SelectedHoldItem).StackCount > 0 then RaiseWideMessage('move protoplasm');
        TakeHoldEntry(Swap,Index,Expanded);
      end
      else if SelectedHoldItem <> nil then ReturnSelectedHoldEntry;
      RestorePlayerHoldDisplayOrder;
      end;
      for J := 0 to PlayerHoldEntries.Count - 1 do
      begin
        Swap := TPlayerHoldUnit(PlayerHoldEntries[J]);
        if (Swap.Kind = phkEquipment) and (Entry.Item as TCountableItem).Merge(Swap.Item) then
        begin
          PlayerHoldShip.Inventory.Delete(PlayerHoldShip.Inventory.IndexOf(Swap.Item));
          Swap.Item.Free;
          Swap.Item := nil;
          Swap.Kind := phkEmpty;
        end;
      end;
    PlayerHoldShip.RefreshDerivedStats(True);
    UpdateActionCursor(True);
    RefreshAfterTransfer;
    Exit;
    end;
  end;
  if SelectedHoldKind = phkEquipment then
  begin
    if not RemoteHoldVisible then
    begin
      if (SelectedHoldItem.ItemType = t_Cistern) and (Entry <> nil) and (Entry.Kind = phkEquipment) and (Entry.Item.ItemType = t_Cistern) and
        ((SelectedHoldItem as TCistern).Fuel > 0) and ((Entry.Item as TCistern).Fuel < (Entry.Item as TCistern).Capacity) then
      begin
        Text := LocalizedColorText('Items.Cistern.Merge');
        if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        begin
          Count := Min((SelectedHoldItem as TCistern).Fuel,(Entry.Item as TCistern).Capacity - (Entry.Item as TCistern).Fuel);
          Dec((SelectedHoldItem as TCistern).Fuel,Count);
          Inc((Entry.Item as TCistern).Fuel,Count);
          PlayerHoldShip.RefreshDerivedStats(True);
          Galaxy.PrimeIntegrityChecksum1(454);
          UpdateActionCursor(True);
          RefreshShipView;
          Exit;
        end;
      end;
      if (SelectedHoldItem.ItemType = t_FuelTanks) and (Entry <> nil) and (Entry.Kind = phkEquipment) and (Entry.Item.ItemType = t_FuelTanks) then
      begin
        FuelFrom := SelectedHoldItem as TFuelTanks;
        FuelTo := Entry.Item as TFuelTanks;
        if (FuelFrom.Fuel > 0) and (FuelTo.Fuel < FuelTo.Capacity) then
      begin
        Text := LocalizedColorText('Items.Cistern.Merge');
        if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        begin
          Count := Min(FuelFrom.Fuel,FuelTo.Capacity - FuelTo.Fuel);
          Dec(FuelFrom.Fuel,Count);
          Inc(FuelTo.Fuel,Count);
          PlayerHoldShip.RefreshDerivedStats(True);
          Galaxy.PrimeIntegrityChecksum1(455);
          UpdateActionCursor(True);
          RefreshShipView;
          Exit;
        end;
      end;
      end;
      if (SelectedHoldItem.ItemType = t_Cistern) and (Entry <> nil) and (Entry.Kind = phkEquipment) and (Entry.Item.ItemType = t_FuelTanks) and
        ((SelectedHoldItem as TCistern).Fuel > 0) and ((Entry.Item as TFuelTanks).Fuel < (Entry.Item as TFuelTanks).Capacity) then
      begin
        Text := LocalizedColorText('Items.Cistern.ToFuelTanks');
        if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        begin
          Count := Min((SelectedHoldItem as TCistern).Fuel,(Entry.Item as TFuelTanks).Capacity - (Entry.Item as TFuelTanks).Fuel);
          Dec((SelectedHoldItem as TCistern).Fuel,Count);
          Inc((Entry.Item as TFuelTanks).Fuel,Count);
          PlayerHoldShip.RefreshDerivedStats(True);
          Galaxy.PrimeIntegrityChecksum1(456);
          UpdateActionCursor(True);
          RefreshShipView;
          Exit;
        end;
      end;
      if (SelectedHoldItem.ItemType = t_FuelTanks) and (Entry <> nil) and (Entry.Kind = phkEquipment) and (Entry.Item.ItemType = t_Cistern) and
        ((SelectedHoldItem as TFuelTanks).Fuel > 0) and ((Entry.Item as TCistern).Fuel < (Entry.Item as TCistern).Capacity) then
      begin
        Text := LocalizedColorText('Items.Cistern.FromFuelTanks');
        if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        begin
          Count := Min((SelectedHoldItem as TFuelTanks).Fuel,(Entry.Item as TCistern).Capacity - (Entry.Item as TCistern).Fuel);
          Dec((SelectedHoldItem as TFuelTanks).Fuel,Count);
          Inc((Entry.Item as TCistern).Fuel,Count);
          PlayerHoldShip.RefreshDerivedStats(True);
          Galaxy.PrimeIntegrityChecksum1(457);
          UpdateActionCursor(True);
          RefreshShipView;
          Exit;
        end;
      end;
      if (SelectedHoldItem.ItemType = t_MicroModule) and (Entry <> nil) and (Entry.Kind = phkEquipment) and
        (TEquipment(Entry.Item).MicroModuleIndex = 0) and (SelectedHoldItem as TMicroModule).CanInstallOn(TEquipment(Entry.Item)) and
        not PlayerHoldShip.InHyperspace and (QueuedArcadeBattles.Count <= 0) then
      begin
        Text := FormatText2(LocalizedText('MicroModuls.AddToItem'),TextHighlightColorTag,'<ModuleName>',(SelectedHoldItem as TMicroModule).GetPlainName,'<ItemName>',RemoveTextTagsW(Entry.Item.GetDisplayName));
        if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        begin
          Equipment := TEquipment(Entry.Item);
          PlayerHoldShip.ScriptItemsAct(satOnPlayerUseMM,Equipment,SelectedHoldItem,0);
          ApplyMicroModule((SelectedHoldItem as TMicroModule).MicroModuleIndex - 1,Equipment);
          SelectedHoldItem.Free;
          SelectedHoldKind := phkEmpty;
          SelectedHoldItem := nil;
          PlayerHoldShip.RefreshDerivedStats(True);
          Galaxy.PrimeIntegrityChecksum1(458);
          UpdateActionCursor(True);
          RefreshShipView;
          Exit;
        end;
      end;
      if (Entry <> nil) and (Entry.Item <> nil) and (Entry.Kind in [phkEquipment,phkArtefact]) and
        not PlayerHoldShip.InHyperspace and (QueuedArcadeBattles.Count <= 0) then
      begin
        ActionResult := 0;
        if SelectedHoldItem.ScriptItem <> nil then
          ActionResult := TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnAnotherItem,PlayerHoldShip,Entry.Item,nil,ActionResult);
        if SelectedHoldItem is TEquipmentWithActCode then
          ActionResult := RunItemConfigActionCode(SelectedHoldItem, satOnAnotherItem,PlayerHoldShip,Entry.Item,nil,ActionResult);
        if Entry.Item.ScriptItem <> nil then
          ActionResult := TScriptItem(Entry.Item.ScriptItem).RunActionCode(satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
        if Entry.Item is TEquipmentWithActCode then
          ActionResult := RunItemConfigActionCode(Entry.Item, satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
        if ActionResult in [1,3] then
        begin
          SelectedHoldItem.Free;
          SelectedHoldKind := phkEmpty;
          SelectedHoldItem := nil;
        end;
        if ActionResult in [1..3] then
        begin
          PlayerHoldShip.RefreshDerivedStats(True);
          Galaxy.PrimeIntegrityChecksum1(449);
          UpdateActionCursor(True);
          RefreshShipView;
          if ActionResult = 3 then CloseClicked(nil);
          Exit;
        end;
      end;
    end;
    if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
    PlayerHoldShip.Inventory.Add(SelectedHoldItem);
    (SelectedHoldItem as TEquipment).EquippedFlag := 0;
    SoundManager.PlaySound('Sound.SlotPut');
    if not Expanded then
    begin
      if Entry = nil then
    begin
        Count := Index - PlayerHoldEntries.Count + 1;
        for J := 0 to Count - 1 do
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
          Entry.Kind := phkEmpty;
        end;
        Entry := TPlayerHoldUnit(PlayerHoldEntries[PlayerHoldEntries.Count - 1]);
      end
    else
    begin
        if Entry.Kind <> phkEmpty then
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Insert(Index,Entry);
          Entry.Kind := phkEmpty;
        end;
      end;
      Entry.DisplayOrder := FindFreePlayerHoldOrder;
      Entry.Kind := phkEquipment;
      Entry.ItemId := SelectedHoldItem.Id;
      Entry.Item := SelectedHoldItem;
      RemoveEmptyPlayerHoldSlot(PlayerHoldEntries.IndexOf(Entry) + 1);
      SelectedHoldKind := phkEmpty;
      SelectedHoldItem := nil;
    end
    else
    begin
      if (Entry <> nil) and (Entry.Item <> nil) and (Entry.Item.NoDropFlag > 0) then Entry := nil;
      Swap := nil;
      if Entry = nil then
    begin
        Entry := TPlayerHoldUnit.Create;
        PlayerHoldEntries.Add(Entry);
      end
    else
    begin
        if Entry.Kind <> phkEmpty then
        begin
          Swap := Entry;
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
        end;
      end;
      Entry.DisplayOrder := Index;
      Entry.Kind := phkEquipment;
      Entry.ItemId := SelectedHoldItem.Id;
      Entry.Item := SelectedHoldItem;
      if Swap <> nil then TakeHoldEntry(Swap,Index,Expanded)
      else
      begin
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
      end;
      RestorePlayerHoldDisplayOrder;
    end;
    PlayerHoldShip.RefreshDerivedStats(True);
    UpdateActionCursor(True);
    RefreshAfterTransfer;
    Exit;
  end;
  if SelectedHoldKind = phkArtefact then
  begin
    if not RemoteHoldVisible and (Entry <> nil) and (Entry.Item <> nil) and (Entry.Kind in [phkEquipment,phkArtefact]) and
      not PlayerHoldShip.InHyperspace and (QueuedArcadeBattles.Count <= 0) then
    begin
      ActionResult := 0;
      if SelectedHoldItem.ScriptItem <> nil then
        ActionResult := TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnAnotherItem,PlayerHoldShip,Entry.Item,nil,ActionResult);
      ActionResult := RunItemConfigActionCode(SelectedHoldItem, satOnAnotherItem,PlayerHoldShip,Entry.Item,nil,ActionResult);
      if Entry.Item.ScriptItem <> nil then
        ActionResult := TScriptItem(Entry.Item.ScriptItem).RunActionCode(satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
      if Entry.Item is TEquipmentWithActCode then
        ActionResult := RunItemConfigActionCode(Entry.Item, satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
      if ActionResult in [1,3] then
      begin
        SelectedHoldItem.Free;
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
      end;
      if ActionResult in [1..3] then
      begin
        PlayerHoldShip.RefreshDerivedStats(True);
        Galaxy.PrimeIntegrityChecksum1(460);
        UpdateActionCursor(True);
        RefreshShipView;
        if ActionResult = 3 then CloseClicked(nil);
        Exit;
      end;
    end;
    PlayerHoldShip.Artefacts.Add(SelectedHoldItem);
    (SelectedHoldItem as TEquipment).EquippedFlag := 0;
    if SelectedHoldItem is TArtefactTranclucator then
      (TObject((SelectedHoldItem as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := GetPlayer;
    SoundManager.PlaySound('Sound.SlotPut');
    if not Expanded then
    begin
      if Entry = nil then
    begin
        Count := Index - PlayerHoldEntries.Count + 1;
        for J := 0 to Count - 1 do
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
          Entry.Kind := phkEmpty;
        end;
        Entry := TPlayerHoldUnit(PlayerHoldEntries[PlayerHoldEntries.Count - 1]);
      end
    else
    begin
        if Entry.Kind <> phkEmpty then
        begin
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Insert(Index,Entry);
          Entry.Kind := phkEmpty;
        end;
      end;
      Entry.Kind := phkArtefact;
      Entry.ItemId := SelectedHoldItem.Id;
      Entry.Item := SelectedHoldItem;
      RemoveEmptyPlayerHoldSlot(PlayerHoldEntries.IndexOf(Entry) + 1);
      SelectedHoldKind := phkEmpty;
      SelectedHoldItem := nil;
    end
    else
    begin
      if (Entry <> nil) and (Entry.Item <> nil) and (Entry.Item.NoDropFlag > 0) then Entry := nil;
      Swap := nil;
      if Entry = nil then
    begin
        Entry := TPlayerHoldUnit.Create;
        PlayerHoldEntries.Add(Entry);
      end
    else
    begin
        if Entry.Kind <> phkEmpty then
        begin
          Swap := Entry;
          Entry := TPlayerHoldUnit.Create;
          PlayerHoldEntries.Add(Entry);
        end;
      end;
      Entry.DisplayOrder := Index;
      Entry.Kind := phkArtefact;
      Entry.ItemId := SelectedHoldItem.Id;
      Entry.Item := SelectedHoldItem;
      if Swap <> nil then TakeHoldEntry(Swap,Index,Expanded)
      else
      begin
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
      end;
      RestorePlayerHoldDisplayOrder;
    end;
    PlayerHoldShip.RefreshDerivedStats(True);
    UpdateActionCursor(True);
    RefreshAfterTransfer;
    Exit;
  end;
  RefreshAfterTransfer;
end;
{ @end $6FE338 }

{ @routine $700548 TfShip2_TakeHoldEntry }
procedure TfShip2.TakeHoldEntry(Entry: TPlayerHoldUnit; Slot: Integer; UsesDisplayOrder: Boolean);
begin
  if Entry.Kind = phkEquipment then
  begin
    SelectedHoldKind := phkEquipment;
    SelectedHoldOrigin := 0;
    SelectedHoldSlot := Slot;
    SelectedHoldUsesDisplayOrder := UsesDisplayOrder;
    SelectedHoldItem := Entry.Item;
    PlayerHoldShip.Inventory.Delete(PlayerHoldShip.Inventory.IndexOf(Entry.Item));
    Entry.Kind := phkEmpty;
    Entry.Item := nil;
  end
  else if Entry.Kind = phkGoods then
  begin
    SelectedHoldKind := phkGoods;
    SelectedHoldOrigin := 0;
    SelectedHoldSlot := Slot;
    SelectedHoldUsesDisplayOrder := UsesDisplayOrder;
    SelectedGoodsIndex := Entry.GoodsIndex;
    SelectedGoodsQuantity := PlayerHoldShip.CargoGoods[SelectedGoodsIndex].Count;
    SelectedGoodsCost := PlayerHoldShip.CargoGoods[SelectedGoodsIndex].TotalCost;
    PlayerHoldShip.CargoGoods[SelectedGoodsIndex].Count := 0;
    PlayerHoldShip.CargoGoods[SelectedGoodsIndex].TotalCost := 0;
    Entry.Kind := phkEmpty;
    Entry.Item := nil;
  end
  else if Entry.Kind = phkArtefact then
  begin
    SelectedHoldKind := phkArtefact;
    SelectedHoldOrigin := 0;
    SelectedHoldSlot := Slot;
    SelectedHoldUsesDisplayOrder := UsesDisplayOrder;
    SelectedHoldItem := Entry.Item;
    PlayerHoldShip.Artefacts.Delete(PlayerHoldShip.Artefacts.IndexOf(Entry.Item));
    Entry.Kind := phkEmpty;
    Entry.Item := nil;
  end
  else SelectedHoldKind := phkEmpty;
  Galaxy.PrimeIntegrityChecksum1(462);
end;
{ @end $700548 }

{ @routine $700750 TfShip2_HullMouseDown }
procedure TfShip2.HullMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Text: WideString;
  OldHull: THull;
  ActionResult, Quantity: Integer;
begin
  if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem <> nil) and (SelectedHoldItem is THull) and (PlayerHoldShip.GetHull.NoDropFlag > 0) then Exit;
  Galaxy.CheckIntegrityChecksum1(463);
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_MicroModule) and (PlayerHoldShip.GetHull.MicroModuleIndex = 0) and
    (SelectedHoldItem as TMicroModule).CanInstallOn(PlayerHoldShip.GetHull) then
  begin
    Text := FormatText2(LocalizedText('MicroModuls.AddToItem'),TextHighlightColorTag,'<ModuleName>',(SelectedHoldItem as TMicroModule).GetPlainName,'<ItemName>',RemoveTextTagsW(PlayerHoldShip.GetHull.GetDisplayName));
    if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
    begin
      PlayerHoldShip.ScriptItemsAct(satOnPlayerUseMM,PlayerHoldShip.GetHull,SelectedHoldItem,0);
      ApplyMicroModule((SelectedHoldItem as TMicroModule).MicroModuleIndex - 1,PlayerHoldShip.GetHull);
      SelectedHoldItem.Free;
      SelectedHoldKind := phkEmpty;
      SelectedHoldItem := nil;
      PlayerHoldShip.RefreshDerivedStats(True);
      Galaxy.PrimeIntegrityChecksum1(464);
      UpdateActionCursor(True);
      RefreshShipView;
    end;
    Exit;
  end
  else if SelectedHoldKind in [phkGoods] then
  begin
    ActionResult := 0;
    if PlayerHoldShip.GetHull.ScriptItem <> nil then ActionResult := TScriptItem(PlayerHoldShip.GetHull.ScriptItem).RunActionCode(satOnAnotherGoods,PlayerHoldShip,TObject(SelectedGoodsIndex),TObject(SelectedGoodsQuantity),0);
    if ActionResult <> 0 then
    begin
      Quantity := Abs(ActionResult);
      if Quantity < SelectedGoodsQuantity then
      begin
        Dec(SelectedGoodsCost,Round(Quantity / SelectedGoodsQuantity * SelectedGoodsCost));
        Dec(SelectedGoodsQuantity,Quantity);
      end
      else
      begin
        SelectedHoldKind := phkEmpty;
        SelectedGoodsQuantity := 0;
        SelectedGoodsCost := 0;
      end;
    end;
    PlayerHoldShip.RefreshDerivedStats(True);
    Galaxy.PrimeIntegrityChecksum1(440);
    UpdateActionCursor(True);
    RefreshShipView;
    if ActionResult < 0 then CloseClicked(nil);
    Exit;
  end
  else if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem <> nil) then
  begin
    ActionResult := 0;
    if SelectedHoldItem.ScriptItem <> nil then ActionResult := TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnAnotherItem,PlayerHoldShip,PlayerHoldShip.GetHull,nil,ActionResult);
    if SelectedHoldItem is TEquipmentWithActCode then ActionResult := RunItemConfigActionCode(SelectedHoldItem, satOnAnotherItem,PlayerHoldShip,PlayerHoldShip.GetHull,nil,ActionResult);
    if PlayerHoldShip.GetHull.ScriptItem <> nil then ActionResult := TScriptItem(PlayerHoldShip.GetHull.ScriptItem).RunActionCode(satOnAnotherItem2,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
    if ActionResult in [1,3] then
    begin
      SelectedHoldItem.Free;
      SelectedHoldKind := phkEmpty;
      SelectedHoldItem := nil;
    end;
    if ActionResult in [1..3] then
    begin
      PlayerHoldShip.RefreshDerivedStats(True);
      Galaxy.PrimeIntegrityChecksum1(464);
      UpdateActionCursor(True);
      RefreshShipView;
      if ActionResult = 3 then CloseClicked(nil);
      Exit;
    end;
  end
  else if SelectedHoldKind = phkEmpty then
  begin
    if IsHoldNormalShip and (TItem(PlayerHoldShip.Inventory[0]).NoDropFlag <= 0) then
    begin
      SelectedHoldKind := phkEquipment;
      SelectedHoldOrigin := 0;
      SelectedHoldSlot := 0;
      SelectedHoldUsesDisplayOrder := False;
      SelectedHoldItem := TItem(PlayerHoldShip.Inventory[0]);
      PlayerHoldShip.RefreshDerivedStats(True);
      Galaxy.PrimeIntegrityChecksum1(465);
      UpdateActionCursor(True);
      RefreshShipView;
      SoundManager.PlaySound('Sound.SlotGet');
    end;
    Exit;
  end;
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_Hull) and (SelectedHoldOrigin = 0) then ReturnSelectedHoldEntry
  else if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_Hull) and (SelectedHoldOrigin = 1) and IsHoldNormalShip then
  begin
    PlayerHoldShip.ScriptItemsAct(satOnPlayerChangeHull,SelectedHoldItem,PlayerHoldShip.GetHull,0);
    OldHull := PlayerHoldShip.GetHull;
    PlayerHoldShip.Inventory.Insert(0,SelectedHoldItem);
    PlayerHoldShip.Hull := SelectedHoldItem as THull;
    PlayerHoldShip.GetHull.OwnerShip := PlayerHoldShip;
    PlayerHoldShip.GetHull.AssignedSlotData := 0;
    PlayerHoldShip.GetHull.EquippedFlag := 1;
    SelectedHoldKind := phkEmpty;
    SelectedHoldItem := nil;
    if OldHull <> nil then
    begin
      OldHull.OwnerShip := nil;
      PlayerHoldShip.Inventory.Delete(PlayerHoldShip.Inventory.IndexOf(OldHull));
      GetPlayer.AddItemToPlayerStorage(OldHull,GetLocalStorageOwner,-1);
      Galaxy.PrimeIntegrityChecksum1(466);
    end;
    if PlayerHoldShip.GetHull.ScriptItem <> nil then TScriptItem(PlayerHoldShip.GetHull.ScriptItem).RunActionCode(satOnPlayerChangeHull,PlayerHoldShip,PlayerHoldShip.GetHull,OldHull,0);
    PlayerHoldShip.RefreshAssignedItemSlots;
    PlayerHoldShip.RebuildEquipmentCache;
    PlayerHoldShip.RefreshDerivedStats(True);
    if not PlayerHoldShip.ScriptChameleon then
    begin
      ReleaseSpaceObject(PlayerHoldShip.Graphic);
      PlayerHoldShip.RefreshGraphic;
    end;
    Galaxy.PrimeIntegrityChecksum1(467);
    UpdateActionCursor(True);
    RefreshShipView;
    ShipStateChanged := True;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $700750 }

{ @routine $701030 TfShip2_ConfigureChameleon }
function TfShip2.ConfigureChameleon: Boolean;
var
  Choice, ExpectedCharges, I: Integer;
  Series: TDominatorSeries;
  VisualType: Byte;
  Ship: TShip;

  // @nested $700FFC ChameleonDialogChoiceToSeries
  function ChameleonDialogChoiceToSeries(Choice: Integer): TDominatorSeries; // @addr $700FFC @ida "unsigned __int8 __usercall $name@<al>(int Choice@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x7011A4" Nested helper; does not access its parent frame.
  begin
    Result := dsBlazer;
    case Choice of
      2: Result := dsBlazer;
      3: Result := dsKeller;
      4: Result := dsTerron;
    end;
  end;

begin
  Result := False;
  if not PlayerHoldShip.InHyperspace and (QueuedArcadeBattles.Count <= 0) and not PlayerHoldShip.ScriptChameleon and
    (PlayerHoldShip.HasPlayerChameleonCharges or PlayerHoldShip.ChameleonActive) then
  begin
    Galaxy.CheckIntegrityChecksum1(427);
    ReturnSelectedHoldEntry;
    VisualType := PlayerHoldShip.SelectChameleonVisualType;
    if ShowChameleonDialog(Self,PlayerHoldShip.ChameleonCharges[0],PlayerHoldShip.ChameleonCharges[1],PlayerHoldShip.ChameleonCharges[2],
      VisualType,PlayerHoldShip.ChameleonActive,Choice) = 1 then
    begin
      if Choice = 1 then
      begin
        PlayerHoldShip.ChameleonActive := False;
        for I := 0 to PlayerHoldShip.CurrentStar.Ships.Count - 1 do
        begin
          Ship := TShip(PlayerHoldShip.CurrentStar.Ships[I]);
          if (Ship <> PlayerHoldShip) and Ship.InNormalSpace and not Ship.HasScriptControl and
            (Ship is TNormalShip) and (Ship.TypeId <> stPirate) then Ship.AssignWeaponTargetsInStar;
        end;
      end
      else
      begin
        Series := ChameleonDialogChoiceToSeries(Choice);
        ExpectedCharges := Max(0,PlayerHoldShip.ChameleonCharges[Ord(Series)] - 1);
        PlayerHoldShip.ChameleonCharges[Ord(Series)] := ExpectedCharges;
        PlayerHoldShip.ChameleonSeries := Series;
        PlayerHoldShip.ChameleonActive := True;
        SysUtils.Sleep(1);
        if (PlayerHoldShip.ChameleonCharges[Ord(Series)] <> ExpectedCharges) and not GR_Main.CCInterface.GetTamperDetected then
          GR_Main.CCInterface.SetTamperDetected(True);
      end;
      ReleaseSpaceObject(PlayerHoldShip.Graphic);
      PlayerHoldShip.RefreshGraphic;
      Result := True;
    end;
    Galaxy.PrimeIntegrityChecksum1(468);
  end;
end;
{ @end $701030 }

{ @routine $70127C TfShip2_HoldLeftPressed }
procedure TfShip2.HoldLeftPressed(Sender: TObjectGI);
begin
  Dec(HoldFirstIndex);
  RefreshShipView;
  if HoldScrollTimer <> nil then
  begin
    CancelCallbackTimer(HoldScrollTimer);
    HoldScrollTimer := nil;
  end;
  HoldScrollTimer := ScheduleCallbackTimer(500,50,ScrollHoldTimer);
end;
{ @end $70127C }

{ @routine $7012EC TfShip2_HoldLeftReleased }
procedure TfShip2.HoldLeftReleased(Sender: TObjectGI);
begin
  if HoldScrollTimer <> nil then
  begin
    CancelCallbackTimer(HoldScrollTimer);
    HoldScrollTimer := nil;
  end;
end;
{ @end $7012EC }

{ @routine $701324 TfShip2_HoldRightPressed }
procedure TfShip2.HoldRightPressed(Sender: TObjectGI);
begin
  Inc(HoldFirstIndex);
  RefreshShipView;
  if HoldScrollTimer <> nil then
  begin
    CancelCallbackTimer(HoldScrollTimer);
    HoldScrollTimer := nil;
  end;
  HoldScrollTimer := ScheduleCallbackTimer(500,50,ScrollHoldTimer,1);
end;
{ @end $701324 }

{ @routine $701394 TfShip2_HoldRightReleased }
procedure TfShip2.HoldRightReleased(Sender: TObjectGI);
begin
  if HoldScrollTimer <> nil then
  begin
    CancelCallbackTimer(HoldScrollTimer);
    HoldScrollTimer := nil;
  end;
end;
{ @end $701394 }

{ @routine $7013CC TfShip2_ScrollHoldTimer }
procedure TfShip2.ScrollHoldTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if UserData = 0 then Dec(HoldFirstIndex) else Inc(HoldFirstIndex);
  if HoldFirstIndex <= 0 then
  begin
    HoldFirstIndex := 0;
    if HoldScrollTimer <> nil then
    begin
      CancelCallbackTimer(HoldScrollTimer);
      HoldScrollTimer := nil;
    end;
  end
  else if HoldFirstIndex + 6 >= PlayerHoldEntries.Count + 1 then
  begin
    HoldFirstIndex := Max(0, PlayerHoldEntries.Count + 1 - 6);
    if HoldScrollTimer <> nil then
    begin
      CancelCallbackTimer(HoldScrollTimer);
      HoldScrollTimer := nil;
    end;
  end;
  RefreshShipView;
end;
{ @end $7013CC }

{ @routine $7014B8 TfShip2_ReturnSelectedHoldEntry }
procedure TfShip2.ReturnSelectedHoldEntry;
var I, Count: Integer; Entry: TPlayerHoldUnit;
begin
  if SelectedHoldKind <> phkEmpty then
  begin
    if SelectedHoldOrigin = 0 then
    begin
      if SelectedHoldKind = phkGoods then
      begin
        PlayerHoldShip.CargoGoods[SelectedGoodsIndex].Count := SelectedGoodsQuantity;
        PlayerHoldShip.CargoGoods[SelectedGoodsIndex].TotalCost := SelectedGoodsCost;
      end
      else if SelectedHoldKind = phkEquipment then
      begin
        if not (SelectedHoldItem is THull) then
        begin
          if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
          PlayerHoldShip.Inventory.Add(SelectedHoldItem);
          (SelectedHoldItem as TEquipment).EquippedFlag := 0;
        end;
      end
      else if SelectedHoldKind = phkArtefact then
      begin
        PlayerHoldShip.Artefacts.Add(SelectedHoldItem);
        (SelectedHoldItem as TEquipment).EquippedFlag := 0;
      end;
      if (SelectedHoldKind = phkGoods) or (SelectedHoldKind = phkEquipment) or (SelectedHoldKind = phkArtefact) then
      begin
        if SelectedHoldUsesDisplayOrder then
        begin
          if FindPlayerHoldIndexByOrder(SelectedHoldSlot) < 0 then
          begin
            Entry := TPlayerHoldUnit.Create;
            PlayerHoldEntries.Add(Entry);
            Entry.DisplayOrder := SelectedHoldSlot;
          end
          else
          begin
            Entry := TPlayerHoldUnit.Create;
            Entry.DisplayOrder := FindFreePlayerHoldOrder;
            PlayerHoldEntries.Add(Entry);
          end;
          Entry.Kind := SelectedHoldKind;
          if SelectedHoldKind = phkGoods then Entry.GoodsIndex := SelectedGoodsIndex
          else
          begin
            Entry.ItemId := SelectedHoldItem.Id;
            Entry.Item := SelectedHoldItem;
          end;
          RestorePlayerHoldDisplayOrder;
        end
        else if SelectedHoldSlot >= 0 then
        begin
          if IsPlayerHoldSlotEmpty(SelectedHoldSlot) then
          begin
            if PlayerHoldEntries.Count > SelectedHoldSlot then Entry := PlayerHoldEntries[SelectedHoldSlot]
            else
            begin
              Count := SelectedHoldSlot - PlayerHoldEntries.Count + 1;
              for I := 0 to Count - 1 do
              begin
                Entry := TPlayerHoldUnit.Create;
                PlayerHoldEntries.Add(Entry);
                Entry.Kind := phkEmpty;
              end;
              Entry := PlayerHoldEntries[PlayerHoldEntries.Count - 1];
            end;
          end
          else
          begin
            Entry := TPlayerHoldUnit.Create;
            PlayerHoldEntries.Add(Entry);
          end;
          Entry.DisplayOrder := FindFreePlayerHoldOrder;
          Entry.Kind := SelectedHoldKind;
          if SelectedHoldKind = phkGoods then Entry.GoodsIndex := SelectedGoodsIndex
          else
          begin
            Entry.ItemId := SelectedHoldItem.Id;
            Entry.Item := SelectedHoldItem;
          end;
        end
        else
        begin
          if ((SelectedHoldKind = phkEquipment) or (SelectedHoldKind = phkArtefact)) and
            (PlayerHoldShip.FindEquippedItemInSlot(SelectedHoldItem.ItemType,-SelectedHoldSlot - 1) = nil) then
          begin
            (SelectedHoldItem as TEquipment).EquippedFlag := 0;
            (SelectedHoldItem as TEquipment).Equip;
          end;
        end
      end;
    end
    else
    begin
      if SelectedHoldKind = phkGoods then
      begin
        if GetPlayer.FindStorageIndexByLocationAndSlot(GetLocalStorageOwner,SelectedHoldSlot) < 0 then
          GetPlayer.AddGoodsToPlayerStorage(SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,GetLocalStorageOwner,SelectedHoldSlot)
        else GetPlayer.AddGoodsToPlayerStorage(SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,GetLocalStorageOwner,-1);
      end
      else if (SelectedHoldKind = phkEquipment) or (SelectedHoldKind = phkArtefact) then
      begin
        if GetPlayer.FindStorageIndexByLocationAndSlot(GetLocalStorageOwner,SelectedHoldSlot) < 0 then
          GetPlayer.AddItemToPlayerStorage(SelectedHoldItem,GetLocalStorageOwner,SelectedHoldSlot)
        else GetPlayer.AddItemToPlayerStorage(SelectedHoldItem,GetLocalStorageOwner,-1);
      end;
    end;
    SelectedHoldKind := phkEmpty;
    SelectedHoldItem := nil;
    if not ExitScreenLoop then
    begin
      PlayerHoldShip.RefreshDerivedStats(True);
      if not IsCursorImageSelected('Main') then SetCursorByName('Main');
      Galaxy.PrimeIntegrityChecksum1(428);
      RefreshShipView;
    end
    else Galaxy.PrimeIntegrityChecksum1(428);
  end;
end;
{ @end $7014B8 }

{ @routine $701A5C TfShip2_RefreshEquipmentConfigurationButtons }
procedure TfShip2.RefreshEquipmentConfigurationButtons;
var Button: TGraphButtonGI; I: Integer;
begin
  if GetPlayer <> nil then
    for I := 0 to 9 do
    begin
      Button := FindControlByPath('Compl' + IntToStr(I)) as TGraphButtonGI;
      if Button <> nil then
      begin
        Button.SetDisabled((GetPlayer.SelectedEquipmentConfiguration = I) and (GetPlayer = PlayerHoldShip));
        Button.SetDown(GetPlayer.HasEquipmentConfiguration(I) and (GetPlayer = PlayerHoldShip));
      end;
    end;
end;
{ @end $701A5C }

{ @routine $701B78 TfShip2_SelectEquipmentConfiguration }
procedure TfShip2.SelectEquipmentConfiguration(Index: Integer);
var Button: TGraphButtonGI;
begin
  if GetPlayer <> nil then
  begin
    if GetPlayer <> PlayerHoldShip then
    begin
      Button := FindControlByPath('Compl' + IntToStr(Index)) as TGraphButtonGI;
      if Button <> nil then
      begin
        Button.SetDisabled(False);
        Button.SetDown(False);
      end;
    end
    else if not GetPlayer.InHyperspace and (QueuedArcadeBattles.Count <= 0) and (GetPlayer.SelectedEquipmentConfiguration <> Index) then
    begin
      Galaxy.CheckIntegrityChecksum1(470);
      GetPlayer.SaveEquipmentConfiguration(GetPlayer.SelectedEquipmentConfiguration);
      GetPlayer.SelectedEquipmentConfiguration := Index;
      if GetPlayer.HasEquipmentConfiguration(Index) and not IsVirtualKeyDown(VK_CONTROL) then
      begin
        GetPlayer.ApplyEquipmentConfiguration(Index);
        if GetInnermostScreenLoop = Self then RefreshShipView;
      end
      else RefreshEquipmentConfigurationButtons;
      GetPlayer.ScriptItemsAct(satOnNonStandartEqChange,nil,nil,0);
      Galaxy.PrimeIntegrityChecksum1(471);
    end;
  end;
end;
{ @end $701B78 }

{ @routine $701D30 TfShip2_EquipmentConfigurationClicked }
procedure TfShip2.EquipmentConfigurationClicked(Sender: TObjectGI);
begin
  SelectEquipmentConfiguration(ExtractDigitsToIntW(Sender.ControlName));
end;
{ @end $701D30 }

{ @routine $701D58 TfShip2_MainKeyDown }
procedure TfShip2.MainKeyDown(Sender: TObjectGI; Key: Cardinal);
var
  Index: Integer;
  CanAfterburn: Boolean;
begin
  Galaxy.CheckIntegrityChecksum1(472);
  if (Key = VK_SHIFT) and (SelectedHoldKind = phkEquipment) then
    RefreshActionPanels(SelectedHoldKind,SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,SelectedHoldItem,SelectedHoldOrigin)
  else if Key = VK_CONTROL then
  begin
    if GetPlayer.IsOnPlanet then RefreshShipView;
  end;
  if (GetPlayer = PlayerHoldShip) and not GetPlayer.InHyperspace and (QueuedArcadeBattles.Count <= 0) and (Key >= Ord('1')) and (Key <= Ord('9')) then
  begin
    Index := Key - Ord('1');
    if IsVirtualKeyDown(VK_CONTROL) then
    begin
      GetPlayer.SaveEquipmentConfiguration(Index);
      RefreshEquipmentConfigurationButtons;
      SoundManager.PlaySound('Sound.UserMsgAdd');
      ShowMessageBoxGI(Self,FormatText1(LocalizedText('FormShip.SetHotEqu'),TextHighlightColorTag,'<Key>','"' + Chr(Key) + '"'),mbgOK or mbgUnused04);
    end
    else SelectEquipmentConfiguration(Index);
    Galaxy.PrimeIntegrityChecksum1(473);
  end
  else
  begin
    if not PlayerHoldShip.InHyperspace and (QueuedArcadeBattles.Count <= 0) and IsVirtualKeyDown(VK_CONTROL) then
    begin
      if Key = Ord('I') then ShipToStorageClicked(nil)
      else if Key = Ord('O') then StorageToShipClicked(nil);
    end;
    if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then
    begin
      Galaxy.PrimeIntegrityChecksum1(474);
      Exit;
    end;
    if (GetPlayer = PlayerHoldShip) and (Key = Ord('K')) and ConfigureChameleon then
    begin
      ShipStateChanged := True;
      ReopenRequested := True;
      PlayTransitionSounds := False;
      Galaxy.PrimeIntegrityChecksum1(475);
      CloseClicked(nil);
    end;
    if Key = Ord('S') then
    begin
      Galaxy.PrimeIntegrityChecksum1(476);
      CloseClicked(nil);
    end
    else if Key = Ord('B') then
    begin
      if (GetPlayer = PlayerHoldShip) and (GetPlayer.GetHull.CapitalShip > 0) and (GetPlayer.RuinsMode = 0) then
      begin
        if SelectedHoldKind <> phkEmpty then ReturnSelectedHoldEntry;
        GetPlayer.EnterRuinsMode(0);
      end;
    end
    else if Key = Ord('F') then
    begin
      CanAfterburn := (PlayerHoldShip.GetSlotCount(sskAfterburner) > 0) and PlayerHoldShip.IsEquipmentUsable(PlayerHoldShip.GetEngine) and PlayerHoldShip.InNormalSpace;
      if not PlayerHoldShip.AfterburnerActive and CanAfterburn then
      begin
        SoundManager.PlaySound('Sound.ForsageOn');
        PlayerHoldShip.AfterburnerActive := True;
        PlayerHoldShip.RefreshDerivedStats(True);
        RefreshShipView;
      end
      else if PlayerHoldShip.AfterburnerActive then
      begin
        SoundManager.PlaySound('Sound.ForsageOff');
        PlayerHoldShip.AfterburnerActive := False;
        PlayerHoldShip.RefreshDerivedStats(True);
        RefreshShipView;
      end;
    end
    else if (Key = VK_ESCAPE) or (Key = VK_RETURN) then
    begin
      if SelectedHoldKind <> phkEmpty then ReturnSelectedHoldEntry
      else
      begin
        AuxRenderBuffer.Clear;
        RequestedScreenId := ShipReturnScreenId;
        RequestClose(1);
      end;
    end
    else if Key = VK_LEFT then
    begin
      if HoldFirstIndex > 0 then
      begin
        Dec(HoldFirstIndex);
        RefreshShipView;
      end;
    end
    else if Key = VK_RIGHT then
    begin
      if HoldFirstIndex + 6 <= PlayerHoldEntries.Count then
      begin
        Inc(HoldFirstIndex);
        RefreshShipView;
      end;
    end
    else if Key = VK_UP then ScrollStorageUp(nil)
    else if Key = VK_DOWN then ScrollStorageDown(nil)
    else if Key = VK_F11 then
    begin
      if not MainPanel.RemoveDismissibleMessages('GOODS') then MainPanel.RemoveDismissibleMessages('');
    end
    else if Key = Ord('R') then RewardsMouseDown(RewardsBuffer,0,RewardsBuffer.LocalPosition)
    else if Key = Ord('U') then LoadRockets(True)
    else if Key = Ord('Y') then LoadRockets(False);
    Galaxy.PrimeIntegrityChecksum1(471);
  end;
end;
{ @end $701D58 }

{ @routine $702404 TfShip2_MainKeyUp }
procedure TfShip2.MainKeyUp(Sender: TObjectGI; Key: Cardinal);
begin
  if (Key = VK_SHIFT) and (SelectedHoldKind = phkEquipment) then
    RefreshActionPanels(SelectedHoldKind,SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,SelectedHoldItem,SelectedHoldOrigin)
  else if Key = VK_CONTROL then
    if GetPlayer.IsOnPlanet then RefreshShipView;
end;
{ @end $702404 }

{ @routine $70248C TfShip2_ProcessMouseWheel }
procedure TfShip2.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then
  begin
    if CanUseLocalStorage and GetByName('SC_Panel').ContainsPoint(Point) then ScrollStorageUp(nil)
    else if RemoteHoldMode and GetByName('PanelItemRH').ContainsPoint(Point) then
    begin
      RemoteHoldFirstOrder := Max(0,RemoteHoldFirstOrder - 5);
      RefreshShipView;
    end
    else if not RemoteHoldMode and GetByName('PanelAddInfo').ContainsPoint(Point) then
    begin
      with GetByName('PanelAddInfo') as TPanelScrollBarGI do
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.SmallChange * 5);
    end
    else if HoldFirstIndex > 0 then
    begin
      Dec(HoldFirstIndex);
      RefreshShipView;
    end;
  end
  else if Delta = -WHEEL_DELTA then
  begin
    if CanUseLocalStorage and GetByName('SC_Panel').ContainsPoint(Point) then ScrollStorageDown(nil)
    else if RemoteHoldMode and GetByName('PanelItemRH').ContainsPoint(Point) then
    begin
      RemoteHoldFirstOrder := Min(GetRemoteHoldScrollLimit,RemoteHoldFirstOrder + 5);
      RefreshShipView;
    end
    else if not RemoteHoldMode and GetByName('PanelAddInfo').ContainsPoint(Point) then
    begin
      with GetByName('PanelAddInfo') as TPanelScrollBarGI do
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.SmallChange * 5);
    end
    else if HoldFirstIndex + 6 <= PlayerHoldEntries.Count then
    begin
      Inc(HoldFirstIndex);
      RefreshShipView;
    end;
  end;
end;
{ @end $70248C }

{ @routine $702784 TfShip2_MainLeftButtonUp }
procedure TfShip2.MainLeftButtonUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Panels, Child: TObjectGI;
begin
  if ClickAutoCloseForm then
  begin
    if GetByName('PanelDestr').ContainsPoint(Point) then Exit;
    if GetByName('LoadRocketsInSlots').ContainsPoint(Point) then Exit;
    if (GetByName('PanelLeft') as TImageGI).HitTestPixel(Point) then Exit;
    if (GetByName('RightOpen') as TImageGI).HitTestPixel(Point) then Exit;
    if (GetByName('RHOpen') as TImageGI).HitTestPixel(Point) then Exit;
    if (GetByName('S_Left') as TGraphButtonGI).ContainsPoint(Point) then Exit;
    if (GetByName('S_Right') as TGraphButtonGI).ContainsPoint(Point) then Exit;
    if (GetByName('UseImage') as TImageGI).HitTestPixel(Point) then Exit;
    if (GetByName('GateZone') as TZoneGI).ContainsPoint(Point) then Exit;
    if (GetByName('UseZone') as TZoneGI).ContainsPoint(Point) then Exit;
    if GetByName('CenterNormalImage').ContainsPoint(Point) then Exit;
    if GetByName('CenterDamageImage').ContainsPoint(Point) then Exit;
    if GetByName('SC_Panel').ContainsPoint(Point) then Exit;
    if GetByName('Forsage').ContainsPoint(Point) then Exit;
    if GetByName('PM_PanelMsg').ContainsPoint(Point) then Exit;
    if GetByName('PanelLH').ContainsPoint(Point) then Exit;
    if GetByName('PanelDS').ContainsPoint(Point) then Exit;
    Panels := FindControlByPath('TestHitPanels');
    if Panels <> nil then
    begin
      Child := Panels.FirstChild;
      while Child <> nil do
      begin
        if Child.ContainsPoint(Point) then Exit;
        Child := Child.NextSibling;
      end;
    end;
    CloseClicked(nil);
  end;
end;
{ @end $702784 }

var
  // Native initialized-WideString descriptor at $713D5C; compiler-generated
  // finalizer at $713D14 clears these 13 entries (unit counter $88B0D8).
  ShipEquipmentZoneNames: array[0..12] of WideString = (
    'S_Hull_0z', 'S_FuelTanks_0z', 'S_Engine_0z', 'S_Radar_0z',
    'S_Scaner_0z', 'S_RepairRobot_0z', 'S_CargoHook_0z', 'S_DefGenerator_0z',
    'S_Weapon_0z', 'S_Weapon_1z', 'S_Weapon_2z', 'S_Weapon_3z', 'S_Weapon_4z'
  ); // @addr $87C00C

{ @routine $7030CC TfShip2_MainRightButtonDown }
procedure TfShip2.MainRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  ItemType, OtherType: TItemType;
  Zone: TZoneGI;
  I: Integer;
  Control: TObjectGI;
  Button: TGraphButtonGI;
  Changed: Boolean;

  // @nested $702DA4 EquipSelected
  procedure EquipSelected; // @addr $702DA4 @calls "0x703898,0x7039A1,0x703AAF,0x703E60,0x703F34" Nested helper captures selected item types, KeyState, Zone and Self.
  var
    Slot, Index: Integer;
    Equipment: TEquipment;
  begin
    if SelectedHoldItem = nil then Exit;
    if SelectedHoldItem.ItemType in [t_Artefact..t_ArtFastRacks] then
    begin
      Slot := 0;
      ItemType := SelectedHoldItem.ItemType;
      if (ItemType in [t_Artefact,t_Artefact2]) and TArtefactCustom(SelectedHoldItem).SharedUse then
        ItemType := TArtefactCustom(SelectedHoldItem).CountsAsItemType;
      if (ItemType in [t_Artefact..t_ArtefactAntigrav,t_ArtDefToEnergy..t_ArtGiperJump,t_ArtDefToArms1..t_ArtFastRacks]) and
        (not PlayerHoldShip.HasEquippedArtefactOfSameUseGroup(SelectedHoldItem) or Galaxy.AreDuplicateArtefactsEnabled) then
      begin
        Index := 0;
        while Index < PlayerHoldShip.GetSlotCount(sskArtefact) do
        begin
          Equipment := PlayerHoldShip.FindEquippedItemInSlot(ItemType,Index);
          if Equipment = nil then
          begin
            Inc(Slot,Index);
            Break;
          end;
          if Galaxy.AreDuplicateArtefactsEnabled then
          begin
            Inc(Index);
            Continue;
          end;
          OtherType := Equipment.ItemType;
          if (OtherType in [t_Artefact,t_Artefact2]) and TArtefactCustom(Equipment).SharedUse then
            OtherType := TArtefactCustom(Equipment).CountsAsItemType;
          if (ItemType = OtherType) and not (ItemType in [t_Artefact,t_Artefact2]) then
          begin
            Inc(Slot,Index);
            Break;
          end;
          if (ItemType = OtherType) and (ItemType in [t_Artefact,t_Artefact2]) and
            (Equipment.ConfigBlockName = TEquipment(SelectedHoldItem).ConfigBlockName) then
          begin
            Inc(Slot,Index);
            Break;
          end;
          Inc(Index);
        end;
        if Index < PlayerHoldShip.GetSlotCount(sskArtefact) then
          ArtefactSlotMouseDown(ArtefactSlotZones[Slot],KeyState,Zone.LocalPosition);
      end;
    end
    else
    begin
      Slot := -1;
      if SelectedHoldItem.ItemType in [t_FuelTanks..t_DefGenerator] then Slot := Ord(SelectedHoldItem.ItemType) - 42
      else if SelectedHoldItem.ItemType in [t_Weapon1..t_CustomWeapon] then Slot := 8;
      if Slot < 0 then Exit;
      if Slot >= 8 then
      begin
        Index := 0;
        while Index < PlayerHoldShip.GetSlotCount(sskWeapon) do
        begin
          if PlayerHoldShip.FindEquippedItemInSlot(SelectedHoldItem.ItemType,Index) = nil then
          begin
            Inc(Slot,Index);
            Break;
          end;
          Inc(Index);
        end;
        if Index = PlayerHoldShip.GetSlotCount(sskWeapon) then Exit;
      end;
      Zone := GetByName(ShipEquipmentZoneNames[Slot]) as TZoneGI;
      if Slot < 13 then EquipmentSlotMouseDown(Zone,KeyState,Zone.LocalPosition)
      else ArtefactSlotMouseDown(Zone,KeyState,Zone.LocalPosition);
    end;
  end;

begin
  if PlayerHoldShip.InHyperspace or (QueuedArcadeBattles.Count > 0) then Exit;
  Galaxy.CheckIntegrityChecksum1(427);
  if SelectedHoldKind <> phkEmpty then
  begin
    ReturnSelectedHoldEntry;
    Exit;
  end;
  Changed := False;
  if (GetPlayer = PlayerHoldShip) and not Changed then
  begin
    Zone := GetByName('S_Hull_0z') as TZoneGI;
    if Zone.ContainsPoint(Point) then Changed := ConfigureChameleon;
  end;
  if (GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.OwnerId <> oiUninhabited)) or
    (GetPlayer.IsDockedToShip and (GetPlayer.RuinsMode = 0)) then
  begin
    if not Changed then
    begin
      for I := 1 to 12 do
      begin
        Zone := GetByName(ShipEquipmentZoneNames[I]) as TZoneGI;
        if Zone.ContainsPoint(Point) then
        begin
          RemoteHoldVisible := True;
          EquipmentSlotMouseDown(Zone,KeyState,Point);
          if SelectedHoldKind <> phkEmpty then
          begin
            if IsVirtualKeyDown(VK_MENU) then StorageItemMouseUp(Zone,KeyState,Zone.LocalPosition)
            else if IsVirtualKeyDown(VK_CONTROL) then
            begin
              if (SelectedHoldItem = nil) or ((SelectedHoldItem.ScriptItem = nil) and (SelectedHoldItem.NoDropFlag = 0)) or
                ((SelectedHoldItem.ScriptItem <> nil) and TScriptItem(SelectedHoldItem.ScriptItem).CanSell) then SpecialSlot2Clicked(Zone)
              else RemoteHoldItemMouseDown(Zone,KeyState,Zone.LocalPosition);
            end
            else RemoteHoldItemMouseDown(Zone,KeyState,Zone.LocalPosition);
            Changed := True;
          end;
          RemoteHoldVisible := False;
          Break;
        end;
      end;
      for I := 1 to DefaultHullSlotCounts[sskArtefact] do
      begin
        Zone := ArtefactSlotZones[I - 1];
        if Zone.Parent.Active and Zone.ContainsPoint(Point) then
        begin
          RemoteHoldVisible := True;
          ArtefactSlotMouseDown(Zone,KeyState,Point);
          if SelectedHoldKind <> phkEmpty then
          begin
            if IsVirtualKeyDown(VK_MENU) then StorageItemMouseUp(Zone,KeyState,Zone.LocalPosition)
            else if IsVirtualKeyDown(VK_CONTROL) then
            begin
              if (SelectedHoldItem = nil) or ((SelectedHoldItem.ScriptItem = nil) and (SelectedHoldItem.NoDropFlag = 0)) or
                ((SelectedHoldItem.ScriptItem <> nil) and TScriptItem(SelectedHoldItem.ScriptItem).CanSell) then SpecialSlot2Clicked(Zone)
              else RemoteHoldItemMouseDown(Zone,KeyState,Zone.LocalPosition);
            end
            else RemoteHoldItemMouseDown(Zone,KeyState,Zone.LocalPosition);
            Changed := True;
          end;
          RemoteHoldVisible := False;
          Break;
        end;
      end;
    end;
    if IsVirtualKeyDown(VK_CONTROL) then
    begin
      if not Changed and not RemoteHoldMode then
        for I := 0 to 5 do
        begin
          Control := GetByName('S_' + IntToStr(I) + 'z');
          if Control.ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            RemoteHoldItemMouseDown(Control,KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              if (SelectedHoldItem = nil) or ((SelectedHoldItem.ScriptItem = nil) and (SelectedHoldItem.NoDropFlag = 0)) or
                      ((SelectedHoldItem.ScriptItem <> nil) and TScriptItem(SelectedHoldItem.ScriptItem).CanSell) then SpecialSlot2Clicked(Control)
              else RemoteHoldItemMouseDown(Control,KeyState,Point);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
      if not Changed and RemoteHoldMode then
        for I := 0 to 54 do
        begin
          if RemoteHoldImages[I].ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            RemoteHoldItemMouseDown(RemoteHoldImages[I],KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              if (SelectedHoldItem = nil) or ((SelectedHoldItem.ScriptItem = nil) and (SelectedHoldItem.NoDropFlag = 0)) or
                      ((SelectedHoldItem.ScriptItem <> nil) and TScriptItem(SelectedHoldItem.ScriptItem).CanSell) then SpecialSlot2Clicked(RemoteHoldImages[I])
              else RemoteHoldItemMouseDown(RemoteHoldImages[I],KeyState,Point);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
      if not Changed then
        for I := 0 to StorageImageCount - 1 do
        begin
          if StorageImages[I].ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            StorageItemMouseUp(StorageImages[I],KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              if (SelectedHoldItem = nil) or ((SelectedHoldItem.ScriptItem = nil) and (SelectedHoldItem.NoDropFlag = 0)) or
                      ((SelectedHoldItem.ScriptItem <> nil) and TScriptItem(SelectedHoldItem.ScriptItem).CanSell) then SpecialSlot2Clicked(StorageImages[I])
              else StorageItemMouseUp(StorageImages[I],KeyState,Point);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
      if Changed then
      begin
        ShipStateChanged := True;
        ReopenRequested := True;
        PlayTransitionSounds := False;
        CloseClicked(nil);
      end;
      Exit;
    end;
    if not Changed and RemoteHoldMode then
      for I := 0 to 54 do
      begin
        if RemoteHoldImages[I].ContainsPoint(Point) then
        begin
          RemoteHoldVisible := True;
          RemoteHoldItemMouseDown(RemoteHoldImages[I],KeyState,Point);
          if SelectedHoldKind <> phkEmpty then
          begin
            if IsVirtualKeyDown(VK_MENU) then StorageItemMouseUp(RemoteHoldImages[0],KeyState,RemoteHoldImages[0].LocalPosition)
            else
            begin
              EquipSelected;
              RemoteHoldItemMouseDown(RemoteHoldImages[I],KeyState,Point);
            end;
            Changed := True;
          end;
          RemoteHoldVisible := False;
          Break;
        end;
      end;
    if not Changed and not RemoteHoldMode then
      for I := 0 to 5 do
      begin
        Control := GetByName('S_' + IntToStr(I) + 'z');
        if Control.ContainsPoint(Point) then
        begin
          RemoteHoldVisible := True;
          RemoteHoldItemMouseDown(Control,KeyState,Point);
          if SelectedHoldKind <> phkEmpty then
          begin
            if IsVirtualKeyDown(VK_MENU) then StorageItemMouseUp(StorageImages[0],KeyState,StorageImages[0].LocalPosition)
            else
            begin
              EquipSelected;
              RemoteHoldItemMouseDown(Control,KeyState,Point);
            end;
            Changed := True;
          end;
          RemoteHoldVisible := False;
          Break;
        end;
      end;
    if not Changed then
      for I := 0 to StorageImageCount - 1 do
      begin
        if StorageImages[I].ContainsPoint(Point) then
        begin
          RemoteHoldVisible := True;
          StorageItemMouseUp(StorageImages[I],KeyState,Point);
          if SelectedHoldKind <> phkEmpty then
          begin
            Control := GetByName('S_' + IntToStr(0) + 'z');
            if IsVirtualKeyDown(VK_MENU) then RemoteHoldItemMouseDown(Control,KeyState,Control.LocalPosition)
            else
            begin
              EquipSelected;
              StorageItemMouseUp(StorageImages[I],KeyState,Point);
            end;
            GetPlayer.CloseVacantStorageSlot(GetLocalStorageOwner,I);
            Changed := True;
          end;
          RemoteHoldVisible := False;
          Break;
        end;
      end;
  end
  else
  begin
    if IsVirtualKeyDown(VK_SHIFT) then
    begin
      if not Changed and RemoteHoldMode then
        for I := 0 to 54 do
        begin
          if RemoteHoldImages[I].ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            RemoteHoldItemMouseDown(RemoteHoldImages[I],KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              Zone := GetByName('GateZone') as TZoneGI;
              DropSelectedOutside(RemoteHoldImages[0],KeyState,RemoteHoldImages[0].LocalPosition);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
      if not Changed and not RemoteHoldMode then
        for I := 0 to 5 do
        begin
          Control := GetByName('S_' + IntToStr(I) + 'z');
          if Control.ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            RemoteHoldItemMouseDown(Control,KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              Zone := GetByName('GateZone') as TZoneGI;
              DropSelectedOutside(Zone,KeyState,Zone.LocalPosition);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
    end
    else
    begin
      if not Changed then
      begin
        for I := 1 to 12 do
        begin
          Zone := GetByName(ShipEquipmentZoneNames[I]) as TZoneGI;
          if Zone.ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            EquipmentSlotMouseDown(Zone,KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              RemoteHoldItemMouseDown(Zone,KeyState,Zone.LocalPosition);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
        for I := 1 to DefaultHullSlotCounts[sskArtefact] do
        begin
          Zone := ArtefactSlotZones[I - 1];
          if Zone.ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            ArtefactSlotMouseDown(Zone,KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              RemoteHoldItemMouseDown(Zone,KeyState,Zone.LocalPosition);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
      end;
      if not Changed and RemoteHoldMode then
        for I := 0 to 54 do
        begin
          if RemoteHoldImages[I].ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            RemoteHoldItemMouseDown(RemoteHoldImages[I],KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              EquipSelected;
              RemoteHoldItemMouseDown(RemoteHoldImages[I],KeyState,Point);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
      if not Changed and not RemoteHoldMode then
        for I := 0 to 5 do
        begin
          Control := GetByName('S_' + IntToStr(I) + 'z');
          if Control.ContainsPoint(Point) then
          begin
            RemoteHoldVisible := True;
            RemoteHoldItemMouseDown(Control,KeyState,Point);
            if SelectedHoldKind <> phkEmpty then
            begin
              EquipSelected;
              RemoteHoldItemMouseDown(Control,KeyState,Point);
              Changed := True;
            end;
            RemoteHoldVisible := False;
            Break;
          end;
        end;
    end;
  end;
  if not Changed and not RemoteHoldMode then
  begin
    Button := GetByName('S_Left') as TGraphButtonGI;
    if Button.ContainsPoint(Point) then
    begin
      I := 0;
      while (HoldFirstIndex > 0) and (I < 6) do
      begin
        Dec(HoldFirstIndex);
        Inc(I);
      end;
      RefreshShipView;
      if I > 0 then SoundManager.PlaySound(Button.ClickSound);
    end;
  end;
  if not Changed and not RemoteHoldMode then
  begin
    Button := GetByName('S_Right') as TGraphButtonGI;
    if Button.ContainsPoint(Point) then
    begin
      I := 0;
      while (HoldFirstIndex + 6 <= PlayerHoldEntries.Count) and (I < 6) do
      begin
        Inc(HoldFirstIndex);
        Inc(I);
      end;
      RefreshShipView;
      if I > 0 then SoundManager.PlaySound(Button.ClickSound);
    end;
  end;
  Galaxy.PrimeIntegrityChecksum1(473);
  if Changed then
  begin
    ShipStateChanged := True;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $7030CC }

{ @routine $7041B8 TfShip2_TryDeployTranclucator }
function TfShip2.TryDeployTranclucator(Ship: TShip): Boolean;
var
  I: Integer;
  Full: Boolean;
begin
  Result := False;
  if CanUseLocalStorage and (Ship is TTranclucator) then
  begin
    Full := True;
    HangarScreen.RefreshDockedShips;
    for I := 0 to 8 do
      if HangarScreen.ShipSlots[I].AnimationState = 0 then
      begin
        Full := False;
        Break;
      end;
    if not Full then
    begin
      (Ship as TTranclucator).OwnerShip := GetPlayer;
      if GetPlayer.IsOnPlanet then
      begin
        Ship.CurrentPlanet := GetPlayer.CurrentPlanet;
        Result := True;
      end
      else if GetPlayer.IsDockedToShip then
      begin
        Ship.DockedTo := GetPlayer.DockedTo;
        Result := True;
      end;
      if Result then
      begin
        Ship.CurrentStar := PlayerHoldShip.CurrentStar;
        if PlayerHoldShip.CurrentStar.Ships.IndexOf(Ship) < 0 then
          PlayerHoldShip.CurrentStar.Ships.Add(Ship);
        Ship.OrderNone(False);
        Ship.OrderStateData := 0;
      end;
    end;
  end;
end;
{ @end $7041B8 }

{ @routine $7042EC TfShip2_DropSelectedOutside }
procedure TfShip2.DropSelectedOutside(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Item: TItem;
  Goods: TGoods;
  Angle: Double;
  Effect: TWeaponSE;
  Entry: PEFilmEndEntry;
  Quantity, I, Index: Integer;
  Text: WideString;
  ActionResult: Integer;
begin
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is THull) then Exit;
  if SelectedHoldKind = phkEmpty then Exit;
  if (SelectedHoldItem <> nil) and (SelectedHoldItem.NoDropFlag > 0) then
  begin
    ShowNoDropMessage(SelectedHoldItem.NoDropFlag);
    Exit;
  end;
  Galaxy.CheckIntegrityChecksum1(476);
  if PreserveSpaceMusic then
  begin
    DropSelectedInArcade;
    Galaxy.PrimeIntegrityChecksum1(477);
    Exit;
  end;
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TCountableItem) and (TCountableItem(SelectedHoldItem).StackCount > 1) then
  begin
    Quantity := TCountableItem(SelectedHoldItem).StackCount;
    if not RemoteHoldVisible then
      if ShowCountDialog(Self,'GI,' + GetShopItemIconName(SelectedHoldItem) + 's',
        FormatText1(LocalizedText('FormShip.ThrowItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemName(SelectedHoldItem))),
        0,Quantity,Quantity,0,Quantity,0,Quantity) <> 1 then Exit;
    if (Quantity < 1) or (TCountableItem(SelectedHoldItem).StackCount < Quantity) then Exit;
    Item := TCountableItem(SelectedHoldItem).Split(Quantity);
    if (not PlayerHoldShip.IsOnPlanet and not PlayerHoldShip.IsDockedToShip) or
      ((GetPlayer.RuinsMode > 0) and (GetPlayer.RuinsSavedDockedTo = nil) and (GetPlayer.RuinsSavedPlanet = nil)) then
    begin
      with PlayerHoldShip.CurrentStar do
      begin
        Items.Add(Item);
        Angle := SeededRandomIntRange(0,360,PlayerHoldShip.CurrentStar.GenerationSeed * Galaxy.CurrentTurn * Item.Id) * Pi / 180;
        Item.Position.X := Sin(Angle) * 100 + PlayerHoldShip.Position.X;
        Item.Position.Y := PlayerHoldShip.Position.Y - Cos(Angle) * 100;
        Item.GetGraphObject.SetPosition(Item.Position);
        if DamageRadius * DamageRadius > Sqr(Item.Position.X) + Sqr(Item.Position.Y) then
        begin
          Effect := TWeaponSE.Create('Weapon.NoGraph',Classes.Point(0,0),0,-1);
          Effect.SetEndpoints(nil,Item.GetGraphObject);
          Effect.SetHit(0,0,True,True);
          if TrailingFilmEffects = nil then TrailingFilmEffects := TEFilmEnd.Create;
          Entry := TrailingFilmEffects.AppendEntry;
          RetainSpaceObject(Entry.SceneObject,Effect);
          RetainSpaceObject(Entry.RelatedObject1,Item.GetGraphObject);
          ReleaseSpaceObject(Item.GraphObject);
          Items.Delete(Items.IndexOf(Item));
          Item.Free;
        end;
      end;
    end
    else Item.Free;
    if TCountableItem(SelectedHoldItem).StackCount < 1 then
    begin
      SelectedHoldItem.Free;
      SelectedHoldItem := nil;
      SelectedHoldKind := phkEmpty;
      SetCursorByName('Main');
      RefreshShipView;
    end;
    SoundManager.PlaySound('Sound.Drop');
  end
  else if (SelectedHoldKind = phkEquipment) or (SelectedHoldKind = phkArtefact) then
  begin
    if SelectedHoldItem is TArtefactTranclucator then
      (TObject((SelectedHoldItem as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := nil;
    if PlayerHoldShip is TRuins then
    begin
      if PlayerHoldShip.NeedsEquipmentType(SelectedHoldItem.ItemType) then
      begin
        ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.RuinMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(SelectedHoldItem.GetDisplayName)),mbgCancel or mbgWarning);
        Exit;
      end;
    end
    else if PlayerHoldShip is TTranclucator then
    begin
      if ((SelectedHoldItem.ItemType = t_FuelTanks) or (SelectedHoldItem.ItemType = t_Engine)) and PlayerHoldShip.NeedsEquipmentType(SelectedHoldItem.ItemType) then
      begin
        ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.TrancMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(SelectedHoldItem.GetDisplayName)),mbgCancel or mbgWarning);
        Galaxy.PrimeIntegrityChecksum1(478);
        Exit;
      end;
    end
    else if SelectedHoldItem.ItemType = t_FuelTanks then
    begin
      if PlayerHoldShip.GetFuelTanks = nil then
      begin
        if PlayerHoldShip is TRuins then
          Text := FormatText1(LocalizedColorText('FormShip.RuinMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(SelectedHoldItem.GetDisplayName))
        else Text := LocalizedText('FormShip.ThrowFuelTanksError');
        ShowMessageBoxGI(Self,Text,mbgCancel or mbgWarning);
        Galaxy.PrimeIntegrityChecksum1(479);
        Exit;
      end;
    end
    else if SelectedHoldItem.ItemType = t_Engine then
    begin
      if PlayerHoldShip.GetEngine = nil then
      begin
        if PlayerHoldShip is TRuins then
          Text := FormatText1(LocalizedColorText('FormShip.RuinMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(SelectedHoldItem.GetDisplayName))
        else Text := LocalizedText('FormShip.ThrowEngineError');
        ShowMessageBoxGI(Self,Text,mbgCancel or mbgWarning);
        Galaxy.PrimeIntegrityChecksum1(480);
        Exit;
      end;
    end
    else if SelectedHoldItem.NoDropFlag > 0 then
    begin
      Galaxy.PrimeIntegrityChecksum1(481);
      Exit;
    end;
    if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
    SoundManager.PlaySound('Sound.Drop');
    if PlayerHoldShip.IsOnPlanet or (PlayerHoldShip.IsDockedToShip and (GetPlayer.RuinsMode = 0)) or
      ((GetPlayer.RuinsMode > 0) and ((GetPlayer.RuinsSavedDockedTo <> nil) or (GetPlayer.RuinsSavedPlanet <> nil))) then
    begin
      SelectedHoldItem.Free;
      SelectedHoldItem := nil;
    end
    else
      with PlayerHoldShip.CurrentStar do
      begin
        Items.Add(SelectedHoldItem);
        Angle := SeededRandomIntRange(0,360,PlayerHoldShip.CurrentStar.GenerationSeed * Galaxy.CurrentTurn * SelectedHoldItem.Id) * Pi / 180;
        SelectedHoldItem.Position.X := Sin(Angle) * 100 + PlayerHoldShip.Position.X;
        SelectedHoldItem.Position.Y := PlayerHoldShip.Position.Y - Cos(Angle) * 100;
        ActionResult := PlayerHoldShip.ScriptItemsAct(satOnDropItemFixed,SelectedHoldItem,nil,0);
        if SelectedHoldItem is TEquipmentWithActCode then
          ActionResult := RunItemConfigActionCode(SelectedHoldItem, satOnDropItemFixed,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
        if SelectedHoldItem.ScriptItem <> nil then
          ActionResult := TScriptItem(SelectedHoldItem.ScriptItem).RunActionCode(satOnDropItemFixed,PlayerHoldShip,SelectedHoldItem,nil,ActionResult);
        if ActionResult = 0 then
        begin
          SelectedHoldItem.GetGraphObject.SetPosition(SelectedHoldItem.Position);
          if DamageRadius * DamageRadius > Sqr(SelectedHoldItem.Position.X) + Sqr(SelectedHoldItem.Position.Y) then
          begin
            Effect := TWeaponSE.Create('Weapon.NoGraph',Classes.Point(0,0),0,-1);
            Effect.SetEndpoints(nil,SelectedHoldItem.GetGraphObject);
            Effect.SetHit(0,0,True,True);
            if TrailingFilmEffects = nil then TrailingFilmEffects := TEFilmEnd.Create;
            Entry := TrailingFilmEffects.AppendEntry;
            RetainSpaceObject(Entry.SceneObject,Effect);
            RetainSpaceObject(Entry.RelatedObject1,SelectedHoldItem.GetGraphObject);
            Items.Delete(Items.IndexOf(SelectedHoldItem));
            SelectedHoldItem.Free;
          end;
        end
        else
        begin
          Items.Delete(Items.IndexOf(SelectedHoldItem));
          if ActionResult < 0 then SelectedHoldItem.Free;
        end;
      end;
    SelectedHoldKind := phkEmpty;
    SelectedHoldItem := nil;
    SetCursorByName('Main');
    RefreshShipView;
  end
  else if SelectedHoldKind = phkGoods then
  begin
    Quantity := SelectedGoodsQuantity;
    if SelectedGoodsQuantity > 1 then
    begin
      if not RemoteHoldVisible then
        if ShowCountDialog(Self,'GI,' + GetItemTypeBitmapPath(TItemType(SelectedGoodsIndex)),
          FormatText1(LocalizedText('FormShip.ThrowItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemTypeName(TItemType(SelectedGoodsIndex)))),
          0,SelectedGoodsQuantity,SelectedGoodsQuantity,0,Quantity,0,Quantity) <> 1 then Exit;
      if (Quantity < 1) or (Quantity > SelectedGoodsQuantity) then Exit;
    end;
    SoundManager.PlaySound('Sound.Drop');
    if (not PlayerHoldShip.IsOnPlanet and not PlayerHoldShip.IsDockedToShip) or
      ((GetPlayer.RuinsMode > 0) and (GetPlayer.RuinsSavedDockedTo = nil) and (GetPlayer.RuinsSavedPlanet = nil)) then
      with PlayerHoldShip.CurrentStar do
      begin
        Goods := TGoods.Create;
        Goods.Init(TItemType(SelectedGoodsIndex),Quantity);
        Goods.Cost := Round(Quantity / SelectedGoodsQuantity * SelectedGoodsCost);
        for I := 0 to 20 do
        begin
          Angle := SeededRandomIntRange(0,360,PlayerHoldShip.CurrentStar.GenerationSeed * Galaxy.CurrentTurn * (SelectedGoodsIndex + I)) * Pi / 180;
          Goods.Position.X := Sin(Angle) * 100 + PlayerHoldShip.Position.X;
          Goods.Position.Y := PlayerHoldShip.Position.Y - Cos(Angle) * 100;
          Index := 0;
          while Items.Count > Index do
          begin
            Item := Items[Index];
            if PointDistanceSquared(Item.Position,Goods.Position) < 100 then Break;
            Inc(Index);
          end;
          if Items.Count <= Index then Break;
        end;
        Items.Add(Goods);
        Goods.GetGraphObject.SetPosition(Goods.Position);
      end;
    Dec(SelectedGoodsCost,Round(Quantity / SelectedGoodsQuantity * SelectedGoodsCost));
    Dec(SelectedGoodsQuantity,Quantity);
    if SelectedGoodsQuantity < 1 then
    begin
      SelectedHoldKind := phkEmpty;
      SetCursorByName('Main');
      RefreshShipView;
    end;
  end;
  Galaxy.PrimeIntegrityChecksum1(482);
  RemoveEmptyPlayerHoldSlots;
  if not RemoteHoldVisible then
  begin
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $7042EC }

{ @routine $705490 TfShip2_DropSelectedInArcade }
procedure TfShip2.DropSelectedInArcade;
var
  Item: TCountableItem;
  Goods: TGoods;
  Quantity: Integer;
begin
  if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem <> nil) and (SelectedHoldItem.NoDropFlag > 0) then
  begin
    ShowNoDropMessage(SelectedHoldItem.NoDropFlag);
    Exit;
  end;
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TCountableItem) and (TCountableItem(SelectedHoldItem).StackCount > 1) then
  begin
    Quantity := TCountableItem(SelectedHoldItem).StackCount;
    if (ShowCountDialog(Self,'GI,' + GetShopItemIconName(SelectedHoldItem) + 's',
      FormatText1(LocalizedText('FormShip.ThrowItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemName(SelectedHoldItem))),
      0,Quantity,Quantity,0,Quantity,0,Quantity) <> 1) or (Quantity < 1) or (TCountableItem(SelectedHoldItem).StackCount < Quantity) then Exit;
    Item := TCountableItem(SelectedHoldItem).Split(Quantity);
    if ArcadeViewMode = 0 then ab_Item_Drop(PlayerArcadeShip,Item,100,150)
    else Item.Free;
    if TCountableItem(SelectedHoldItem).StackCount < 1 then
    begin
      SelectedHoldItem.Free;
      SelectedHoldItem := nil;
      SelectedHoldKind := phkEmpty;
      SetCursorByName('Main');
      RefreshShipView;
    end;
    SoundManager.PlaySound('Sound.Drop');
  end
  else if (SelectedHoldKind = phkEquipment) or (SelectedHoldKind = phkArtefact) then
  begin
    if SelectedHoldItem is TArtefactTranclucator then
      (TObject((SelectedHoldItem as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := nil;
    if SelectedHoldItem.ItemType = t_FuelTanks then
    begin
      if PlayerHoldShip.GetFuelTanks = nil then
      begin
        ShowMessageBoxGI(Self,LocalizedText('FormShip.ThrowFuelTanksError'),mbgCancel or mbgWarning);
        Exit;
      end;
    end
    else if (SelectedHoldItem.ItemType = t_Engine) and (PlayerHoldShip.GetEngine = nil) then
    begin
      ShowMessageBoxGI(Self,LocalizedText('FormShip.ThrowEngineError'),mbgCancel or mbgWarning);
      Exit;
    end;
    SoundManager.PlaySound('Sound.Drop');
    if ArcadeViewMode <> 0 then
    begin
      SelectedHoldItem.Free;
      SelectedHoldItem := nil;
    end
    else ab_Item_Drop(PlayerArcadeShip,SelectedHoldItem,100,150);
    SelectedHoldKind := phkEmpty;
    SetCursorByName('Main');
    RefreshShipView;
  end
  else if SelectedHoldKind = phkGoods then
  begin
    Quantity := SelectedGoodsQuantity;
    if SelectedGoodsQuantity > 1 then
      if (ShowCountDialog(Self,'GI,' + GetItemTypeBitmapPath(TItemType(SelectedGoodsIndex)),
        FormatText1(LocalizedText('FormShip.ThrowItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemTypeName(TItemType(SelectedGoodsIndex)))),
        0,SelectedGoodsQuantity,SelectedGoodsQuantity,0,Quantity,0,Quantity) <> 1) or
        (Quantity < 1) or (Quantity > SelectedGoodsQuantity) then Exit;
    SoundManager.PlaySound('Sound.Drop');
    if ArcadeViewMode = 0 then
    begin
      Goods := TGoods.Create;
      Goods.Init(TItemType(SelectedGoodsIndex),Quantity);
      Goods.Cost := Round(Quantity / SelectedGoodsQuantity * SelectedGoodsCost);
      ab_Item_Drop(PlayerArcadeShip,Goods,100,150);
    end;
    Dec(SelectedGoodsCost,Round(Quantity / SelectedGoodsQuantity * SelectedGoodsCost));
    Dec(SelectedGoodsQuantity,Quantity);
    if SelectedGoodsQuantity < 1 then
    begin
      SelectedHoldKind := phkEmpty;
      SetCursorByName('Main');
      RefreshShipView;
    end;
  end;
  BreakUiMessage;
end;
{ @end $705490 }

{ @routine $705B10 TfShip2_SpecialSlot1Clicked }
procedure TfShip2.SpecialSlot1Clicked(Sender: TObjectGI);
var
  I, Nodes: Integer;
  Text: WideString;
begin
  if GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning)
    else
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning);
    Exit;
  end;
  Galaxy.CheckIntegrityChecksum1(493);
  if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem as TEquipment).NeedsRepair then
  begin
    if not GetPlayer.CanRepairEquipmentTech(SelectedHoldItem as TEquipment) then
    begin
      ShipStateChanged := True;
      ShowMessageBoxGI(Self,LocalizedText('FormShip.TooAdvancedForRepair'),mbgCancel or mbgUnused04);
      RefreshShipView;
    end
    else if GetPlayer.CanRepairArtefactsAtLocation or
      (not (SelectedHoldItem is TArtefact) and
       (not (SelectedHoldItem is TWeapon) or (TWeapon(SelectedHoldItem).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair))) then
    begin
      if (SelectedHoldItem as TEquipment).CalculateRepairCost > GetPlayer.Money then
      begin
        SoundManager.PlaySound('Sound.NoMoney');
        StartMoneyWarning;
        Exit;
      end;
      if (SelectedHoldItem is TWeapon) and (TWeapon(SelectedHoldItem).GetWeaponInfo.Availability = waNotSoldAndNodeRepair) then
      begin
        Nodes := Round((SelectedHoldItem as TEquipment).CalculateRepairCost * 0.0025);
        if Nodes = 0 then Nodes := 1;
        if GetPlayer.GetAvailableNodeCount(PlayerHoldShip) < Nodes then
        begin
          SoundManager.PlaySound('Sound.NoMoney');
          ShowMessageBoxGI(Self,FormatText1(LocalizedText('FormShip.RepairMsgNeedNode'),TextHighlightColorTag,'<NeedNode>',IntToStr(Nodes - GetPlayer.GetAvailableNodeCount(PlayerHoldShip))),mbgCancel);
          Exit;
        end;
        if ShowMessageBoxGI(Self,FormatText1(LocalizedText('FormShip.RepairMsgEnoughNode'),TextHighlightColorTag,'<NeedNode>',IntToStr(Nodes)),mbgOK or mbgCancel) <> mbgResultOK then Exit;
        GetPlayer.ConsumeAvailableNodes(Nodes,PlayerHoldShip);
      end;
      GetPlayer.SetMoney(GetPlayer.Money - (SelectedHoldItem as TEquipment).CalculateRepairCost);
      (SelectedHoldItem as TEquipment).Repair;
      ShipStateChanged := True;
      SoundManager.PlaySound('Sound.Repair');
      if SelectedHoldKind = phkEquipment then
      begin
        I := 0;
        while I < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) do
        begin
          if PlayerHoldShip.FindEquippedItemInSlot(SelectedHoldItem.ItemType,I) = nil then Break;
          Inc(I);
        end;
        if I < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) then
        begin
          if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
          PlayerHoldShip.Inventory.Add(SelectedHoldItem);
          (SelectedHoldItem as TEquipment).AssignedSlotData := ((SelectedHoldItem as TEquipment).AssignedSlotData and EquipmentSecondaryFireFlag) or I;
          (SelectedHoldItem as TEquipment).EquippedFlag := 0;
          (SelectedHoldItem as TEquipment).Equip;
          SelectedHoldKind := phkEmpty;
          SelectedHoldItem := nil;
        end;
      end
      else if (SelectedHoldKind = phkArtefact) and
        (not PlayerHoldShip.HasEquippedArtefactOfSameUseGroup(SelectedHoldItem) or Galaxy.AreDuplicateArtefactsEnabled) then
      begin
        I := 0;
        while I < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) do
        begin
          if PlayerHoldShip.FindEquippedItemInSlot(SelectedHoldItem.ItemType,I) = nil then Break;
          Inc(I);
        end;
        if I < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) then
        begin
          PlayerHoldShip.Artefacts.Add(SelectedHoldItem);
          if (PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) <= Integer((SelectedHoldItem as TEquipment).AssignedSlotData)) or
            (PlayerHoldShip.FindEquippedItemInSlot(SelectedHoldItem.ItemType,Integer((SelectedHoldItem as TEquipment).AssignedSlotData)) <> nil) then
            (SelectedHoldItem as TEquipment).AssignedSlotData := I;
          (SelectedHoldItem as TEquipment).EquippedFlag := 0;
          (SelectedHoldItem as TEquipment).Equip;
          SelectedHoldKind := phkEmpty;
          SelectedHoldItem := nil;
        end;
      end;
      Galaxy.PrimeIntegrityChecksum1(494);
      RefreshShipView;
    end
    else
    begin
      ShipStateChanged := True;
      Text := '';
      if PlayerHoldShip.DockedTo <> nil then
      begin
        if PlayerHoldShip.DockedTo.TypeNameOverrideKey <> WideString('') then
          Text := LocalizedText('FormShip.NotLicenseForRepair' + PlayerHoldShip.DockedTo.TypeNameOverrideKey);
        if Text = WideString('') then
          Text := LocalizedText('FormShip.NotLicenseForRepair' + ShipTypeNames[PlayerHoldShip.DockedTo.TypeId].Name);
      end
      else if PlayerHoldShip.CurrentPlanet <> nil then
        Text := LocalizedText('FormShip.NotLicenseForRepair' + OwnerInfo[PlayerHoldShip.CurrentPlanet.OwnerId].InternalName);
      if Text = WideString('') then Text := LocalizedText('FormShip.NotLicenseForRepair');
      ShowMessageBoxGI(Self,Text,mbgCancel or mbgUnused04);
      RefreshShipView;
    end;
  end;
  RemoveEmptyPlayerHoldSlots;
  ReopenRequested := True;
  PlayTransitionSounds := False;
  CloseClicked(nil);
end;
{ @end $705B10 }

{ @routine $706600 TfShip2_SpecialSlot2Clicked }
procedure TfShip2.SpecialSlot2Clicked(Sender: TObjectGI);
var
  Count, Price: Integer;
  Item: TItem;
  Event: TGalaxyEvent;
begin
  if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem <> nil) and (SelectedHoldItem.NoDropFlag > 0) then
  begin
    ShowNoDropMessage(SelectedHoldItem.NoDropFlag);
    Exit;
  end;
  if GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet <> nil) and
    (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning)
    else
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning);
    Exit;
  end;
  if SelectedHoldKind = phkEmpty then Exit;
  Galaxy.CheckIntegrityChecksum1(495);
  if (SelectedHoldKind = phkEquipment) or (SelectedHoldKind = phkArtefact) then
  begin
    if PlayerHoldShip is TRuins then
    begin
      if PlayerHoldShip.NeedsEquipmentType(SelectedHoldItem.ItemType) then
      begin
        ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.RuinMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(SelectedHoldItem.GetDisplayName)),mbgCancel or mbgWarning);
        Exit;
      end;
    end
    else if (PlayerHoldShip is TTranclucator) and
      ((SelectedHoldItem.ItemType = t_FuelTanks) or (SelectedHoldItem.ItemType = t_Engine)) and PlayerHoldShip.NeedsEquipmentType(SelectedHoldItem.ItemType) then
    begin
      ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.TrancMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(SelectedHoldItem.GetDisplayName)),mbgCancel or mbgWarning);
      Exit;
    end;
    if (SelectedHoldItem is TArtefactTranclucator) and
      (ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.SellItemQuestion'),TextHighlightColorTag,'<Item>',SelectedHoldItem.GetDisplayName),mbgOK or mbgCancel or mbgQuestion) = 2) then Exit;
    if (SelectedHoldItem is TCountableItem) and ((SelectedHoldItem as TCountableItem).StackCount > 1) then
    begin
      Count := (SelectedHoldItem as TCountableItem).StackCount;
      if (ShowCountDialog(Self,'GI,' + GetShopItemIconName(SelectedHoldItem) + 's',
        FormatText1(LocalizedText('FormShip.SellItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemName(SelectedHoldItem))),
        0,(SelectedHoldItem as TCountableItem).StackCount,(SelectedHoldItem as TCountableItem).StackCount,
        Round(SelectedHoldItem.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading)) / (SelectedHoldItem as TCountableItem).StackCount),
        Count,SelectedHoldItem.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading)),Count) <> 1) or
        (Count < 1) or (Count > (SelectedHoldItem as TCountableItem).StackCount) then Exit;
      Item := (SelectedHoldItem as TCountableItem).Split(Count);
      Price := Item.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading));
      GetPlayer.SetMoney(GetPlayer.Money + Price);
      Item.Free;
    end
    else
    begin
      Price := SelectedHoldItem.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading));
      GetPlayer.SetMoney(GetPlayer.Money + Price);
      if SelectedHoldItem is TCountableItem then (SelectedHoldItem as TCountableItem).StackCount := 0;
    end;
    if Price <> 0 then SoundManager.PlaySound('Sound.Sell');
    if not (SelectedHoldItem is TCountableItem) then
    begin
      Event := AddGalaxyEvent('PlayerSellsEquipment');
      Event.AddData(Ord(SelectedHoldItem.ItemType));
      Event.AddData(SelectedHoldItem.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading)));
      Event.AddData(SelectedHoldItem.Weight);
      Event.AddData(SelectedHoldItem.Id);
      if GetPlayer.CurrentPlanet <> nil then
      begin
        Event.AddData(0);
        Event.AddData(GetPlayer.CurrentPlanet.Id);
      end
      else if GetPlayer.DockedTo <> nil then
      begin
        Event.AddData(1);
        Event.AddData(GetPlayer.DockedTo.Id);
      end
      else
      begin
        Event.AddData(2);
        Event.AddData(0);
      end;
      Event.AddTextData(SelectedHoldItem.GetDisplayName);
      Event.AddTextData(SelectedHoldItem.GetCategoryConfigName);
    end;
    ShipStateChanged := True;
    if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
    if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem.ItemType = t_Hull) and ((SelectedHoldItem as THull).HullType = htSpecial) then
    begin
      SelectedHoldItem.Free;
      SelectedHoldItem := nil;
    end
    else if (SelectedHoldItem.OwnerId in [oiMaloc..oiGaal,oiPirate]) and (SelectedHoldKind = phkEquipment) and
      (SelectedHoldItem.ItemType in [t_Hull..t_CustomWeapon]) and
      (not (SelectedHoldItem is TWeapon) or (TWeapon(SelectedHoldItem).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) then
    begin
      RestoreTemporaryShopStock;
      if GetPlayer.CurrentPlanet <> nil then GetPlayer.CurrentPlanet.EquipmentShop.Add(SelectedHoldItem)
      else (GetPlayer.DockedTo as TRuins).EquipmentShop.Add(SelectedHoldItem);
      BuildTemporaryShopSlotGrid;
    end
    else if not (SelectedHoldItem is TCountableItem) or ((SelectedHoldItem as TCountableItem).StackCount = 0) then
    begin
      SelectedHoldItem.Free;
      SelectedHoldItem := nil;
    end;
    if (SelectedHoldItem = nil) or not (SelectedHoldItem is TCountableItem) or ((SelectedHoldItem as TCountableItem).StackCount = 0) then
    begin
      SelectedHoldItem := nil;
      SelectedHoldKind := phkEmpty;
      SetCursorByName('Main');
    end;
    Galaxy.PrimeIntegrityChecksum1(496);
    RefreshShipView;
  end
  else if SelectedHoldKind = phkGoods then
  begin
    if GetPlayer.IsCargoGoodIllegalOnCurrentPlanet(SelectedGoodsIndex) and
      (ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormGS.NotPermitGoods'),mbgOK or mbgCancel) <> mbgResultOK) then Exit;
    Count := SelectedGoodsQuantity;
    if SelectedGoodsQuantity > 1 then
      if (ShowCountDialog(Self,'GI,' + GetItemTypeBitmapPath(TItemType(SelectedGoodsIndex)),
        FormatText1(LocalizedText('FormShip.SellItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GoodsMarket[SelectedGoodsIndex].DisplayName)),
        0,SelectedGoodsQuantity,SelectedGoodsQuantity,GetPlayer.ShopGoodsSellPrice(SelectedGoodsIndex,nil),Count,1000000000,Count) <> 1) or
        (Count < 1) or (Count > SelectedGoodsQuantity) then Exit;
    ShipStateChanged := True;
    SoundManager.PlaySound('Sound.Sell');
    Inc(GetPlayer.CargoGoods[SelectedGoodsIndex].Count,SelectedGoodsQuantity);
    Inc(GetPlayer.CargoGoods[SelectedGoodsIndex].TotalCost,SelectedGoodsCost);
    GetPlayer.SellGoodsToLocation(SelectedGoodsIndex,Count);
    SelectedHoldKind := phkEmpty;
    Galaxy.PrimeIntegrityChecksum1(497);
    SetCursorByName('Main');
    RefreshShipView;
  end;
  RemoveEmptyPlayerHoldSlots;
  ReopenRequested := True;
  PlayTransitionSounds := False;
  CloseClicked(nil);
end;
{ @end $706600 }

{ @routine $707490 TfShip2_AdvanceScriptVideo }
procedure TfShip2.AdvanceScriptVideo(Timer: PCallbackTimerGI; UserData: Integer);
var
  Progress: Double;
  Video: TxvidGI;
begin
  Progress := (timeGetTime - ScriptVideoStartedAt) / 30000;
  if Progress > 1 then Progress := 1;
  Video := GetByName('Film') as TxvidGI;
  Video.SetFramePosition(Round(749 * Progress));
  if Progress >= 1 then StopScriptVideo;
end;
{ @end $707490 }

{ @routine $707548 TfShip2_StopScriptVideo }
function TfShip2.StopScriptVideo: Boolean;
var
  Video: TxvidGI;
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
  Video := GetByName('Film') as TxvidGI;
  Video.ImageClose;
  Video.SetActive(False);
  InvalidateViewport;
  ShipLoopSound.SetVolume(1);
end;
{ @end $707548 }

{ @routine $707618 TfShip2_UseMouseUp }
procedure TfShip2.UseMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Text: WideString;
  Item: TItem;
  ActionResult: Integer;
begin
  if UsePanelSlideTimer <> nil then Exit;
  if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind in [phkEquipment,phkArtefact]) and
      (SelectedHoldItem.ScriptItem <> nil) and (TScriptItem(SelectedHoldItem.ScriptItem).OnUseText <> WideString('')) then
  begin
    Item := SelectedHoldItem;
    Galaxy.CheckIntegrityChecksum1(521);
    Galaxy.CheckIntegrityChecksum2(522);
    ReturnSelectedHoldEntry;
    ActionResult := RunItemUseCode(Item,PlayerHoldShip);
    if not HasPendingScriptRequests and (ExitCode = 0) then
    begin
      Galaxy.PrimeIntegrityChecksum1(523);
      Galaxy.PrimeIntegrityChecksum2(524);
      SetCursorByName('Main');
      if not GetByName('Film').Active then
      begin
        RefreshShipView;
        if ActionResult <> 1 then
        begin
          ShipStateChanged := True;
          ReopenRequested := True;
          PlayTransitionSounds := False;
        end;
        CloseClicked(nil);
      end;
    end;
  end
  else if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind = phkEquipment) and
      (SelectedHoldItem.ItemType = t_UselessItem) and ((SelectedHoldItem as TUselessItem).GetOnUseCodeText <> WideString('')) then
  begin
    Item := SelectedHoldItem;
    Galaxy.CheckIntegrityChecksum1(521);
    Galaxy.CheckIntegrityChecksum2(522);
    ReturnSelectedHoldEntry;
    ActionResult := RunItemUseCode(Item,PlayerHoldShip);
    if not HasPendingScriptRequests and (ExitCode = 0) then
    begin
      Galaxy.PrimeIntegrityChecksum1(523);
      Galaxy.PrimeIntegrityChecksum2(524);
      SetCursorByName('Main');
      RefreshShipView;
      if not GetByName('Film').Active then
      begin
        if ActionResult <> 1 then
        begin
          ShipStateChanged := True;
          ReopenRequested := True;
          PlayTransitionSounds := False;
        end;
        CloseClicked(nil);
      end;
    end;
  end
  else
  begin
    if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TTreasureMap) then
    begin
      SoundManager.PlaySound('Sound.UseATranc');
      if GiResourceVariant = 1 then Text := (SelectedHoldItem as TTreasureMap).PreviewTablePage1
      else Text := (SelectedHoldItem as TTreasureMap).PreviewTablePage2;
      Galaxy.CheckIntegrityChecksum1(520);
      AddOrUpdatePlayerBubble(pmUserNote,Galaxy.CurrentTurn,Text,(SelectedHoldItem as TTreasureMap).GetTargetPlanetName);
      MainPanel.RebuildMessageButtons(False);
      ReturnSelectedHoldEntry;
      ReopenRequested := True;
      PlayTransitionSounds := False;
      CloseClicked(nil);
    end;
    if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind = phkArtefact) and
          (SelectedHoldItem is TArtefact) and ((SelectedHoldItem as TArtefact).GetOnUseCodeText <> WideString('')) then
    begin
      Item := SelectedHoldItem;
      Galaxy.CheckIntegrityChecksum1(521);
      Galaxy.CheckIntegrityChecksum2(522);
      ReturnSelectedHoldEntry;
      ActionResult := RunItemUseCode(Item,PlayerHoldShip);
      if not HasPendingScriptRequests and (ExitCode = 0) then
      begin
        Galaxy.PrimeIntegrityChecksum1(523);
        Galaxy.PrimeIntegrityChecksum2(524);
        if not GetByName('Film').Active then
        begin
          SetCursorByName('Main');
          RefreshShipView;
          if ActionResult <> 1 then
          begin
            ShipStateChanged := True;
            ReopenRequested := True;
            PlayTransitionSounds := False;
          end;
          CloseClicked(nil);
        end;
      end;
    end
    else if SelectedHoldKind = phkArtefact then
    begin
      RemoveEmptyPlayerHoldSlots;
      ReopenRequested := True;
      PlayTransitionSounds := False;
      CloseClicked(nil);
    end;
  end;
end;
{ @end $707618 }

{ @routine $707BC4 TfShip2_SpecialSlot3Clicked }
procedure TfShip2.SpecialSlot3Clicked(Sender: TObjectGI);
var
  Limit, Cost, Affordable, Amount: Integer;
  UnitPrice: Single;
  Cistern: TCistern;
  FuelTanks: TFuelTanks;
  Weapon: TWeapon;
  Text: WideString;
begin
  Galaxy.CheckIntegrityChecksum1(498);
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TCistern) and
    ((SelectedHoldItem as TCistern).Fuel < (SelectedHoldItem as TCistern).Capacity) then
  begin
    Cistern := SelectedHoldItem as TCistern;
    Limit := Cistern.Capacity - Cistern.Fuel;
    if GetPlayer.IsOnPlanet then UnitPrice := CalculateFuelCost(1,GetPlayer.CurrentPlanet.OwnerId)
    else UnitPrice := CalculateFuelCost(1, oiUninhabited);
    Affordable := Min(Limit,Trunc(GetPlayer.Money / UnitPrice));
    if Affordable <= 0 then
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      StartMoneyWarning;
      Exit;
    end;
    Amount := Affordable;
    if IsVirtualKeyDown(VK_CONTROL) then
    begin
      Text := LocalizedText('FormShip.FuelAct') + #13#10 + DialogHighlightColorTag + LocalizedText('Items.Cistern.Name2') + EndColorTag;
      if ShowCountDialogWithFont(Self,'',Text,1,Limit,Affordable,UnitPrice,Limit,GetPlayer.Money,Amount,GetShopItemIconName(Cistern) + 's',SmallFontName) <> 1 then Exit;
    end;
    if GetPlayer.IsOnPlanet then Cost := CalculateRoundedFuelCost(Amount,GetPlayer.CurrentPlanet.OwnerId)
    else Cost := CalculateRoundedFuelCost(Amount, oiUninhabited);
    if GetPlayer.Money < Cost then
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      StartMoneyWarning;
      Exit;
    end;
    GetPlayer.SetMoney(GetPlayer.Money - Cost);
    Inc(Cistern.Fuel,Amount);
    Galaxy.PrimeIntegrityChecksum1(499);
    SoundManager.PlaySound('Sound.Buy');
    RefreshShipView;
    RemoveEmptyPlayerHoldSlots;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end
  else if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TFuelTanks) and
    ((SelectedHoldItem as TFuelTanks).Fuel < (SelectedHoldItem as TFuelTanks).Capacity) then
  begin
    FuelTanks := SelectedHoldItem as TFuelTanks;
    Limit := FuelTanks.Capacity - FuelTanks.Fuel;
    if GetPlayer.IsOnPlanet then UnitPrice := CalculateFuelCost(1,GetPlayer.CurrentPlanet.OwnerId)
    else UnitPrice := CalculateFuelCost(1, oiUninhabited);
    Affordable := Min(Limit,Trunc(GetPlayer.Money / UnitPrice));
    if Affordable <= 0 then
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      StartMoneyWarning;
      Exit;
    end;
    Amount := Affordable;
    if IsVirtualKeyDown(VK_CONTROL) then
    begin
      Text := LocalizedText('FormShip.FuelAct') + #13#10 + DialogHighlightColorTag + FuelTanks.GetDisplayName + EndColorTag;
      if ShowCountDialogWithFont(Self,'',Text,1,Limit,Affordable,UnitPrice,Limit,GetPlayer.Money,Amount,GetShopItemIconName(FuelTanks) + 's',SmallFontName) <> 1 then Exit;
    end;
    if GetPlayer.IsOnPlanet then Cost := CalculateRoundedFuelCost(Amount,GetPlayer.CurrentPlanet.OwnerId)
    else Cost := CalculateRoundedFuelCost(Amount, oiUninhabited);
    if GetPlayer.Money < Cost then
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      StartMoneyWarning;
      Exit;
    end;
    GetPlayer.SetMoney(GetPlayer.Money - Cost);
    Inc(FuelTanks.Fuel,Amount);
    Galaxy.PrimeIntegrityChecksum1(500);
    SoundManager.PlaySound('Sound.Buy');
    RefreshShipView;
    RemoveEmptyPlayerHoldSlots;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end
  else
  begin
    if GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
    begin
      if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
        ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning)
      else
        ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning);
      Exit;
    end;
    if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TWeapon) and
      (TWeapon(SelectedHoldItem).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and
      (TWeapon(SelectedHoldItem).Ammo < TWeapon(SelectedHoldItem).AmmoCapacity) then
    begin
      Weapon := SelectedHoldItem as TWeapon;
      Limit := Weapon.AmmoCapacity - Weapon.Ammo;
      UnitPrice := Galaxy.ScaleIntByTechLevel(10,100);
      Affordable := Min(Limit,Trunc(GetPlayer.Money / UnitPrice));
      if Affordable <= 0 then
      begin
        SoundManager.PlaySound('Sound.NoMoney');
        StartMoneyWarning;
        Exit;
      end;
      Amount := Affordable;
      if IsVirtualKeyDown(VK_CONTROL) then
      begin
        Text := LocalizedText('FormShip.MissileAct') + #13#10 + DialogHighlightColorTag + Weapon.GetDisplayName + EndColorTag;
        if ShowCountDialogWithFont(Self,'',Text,1,Limit,Affordable,UnitPrice,Limit,GetPlayer.Money,Amount,GetShopItemIconName(Weapon) + 's',SmallFontName) <> 1 then Exit;
      end;
      Cost := Round(Amount * UnitPrice);
      if GetPlayer.Money < Cost then
      begin
        SoundManager.PlaySound('Sound.NoMoney');
        StartMoneyWarning;
        Exit;
      end;
      GetPlayer.SetMoney(GetPlayer.Money - Cost);
      Inc(Weapon.Ammo,Amount);
      SoundManager.PlaySound('Sound.Buy');
      Cost := 0;
      while Cost < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) do
      begin
        if PlayerHoldShip.FindEquippedItemInSlot(SelectedHoldItem.ItemType,Cost) = nil then Break;
        Inc(Cost);
      end;
      if Cost < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) then
      begin
        if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
        PlayerHoldShip.Inventory.Add(SelectedHoldItem);
        (SelectedHoldItem as TEquipment).AssignedSlotData := ((SelectedHoldItem as TEquipment).AssignedSlotData and EquipmentSecondaryFireFlag) or Cost;
        (SelectedHoldItem as TEquipment).EquippedFlag := 0;
        (SelectedHoldItem as TEquipment).Equip;
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
      end;
      Galaxy.PrimeIntegrityChecksum1(501);
      RefreshShipView;
      RemoveEmptyPlayerHoldSlots;
      ReopenRequested := True;
      PlayTransitionSounds := False;
      CloseClicked(nil);
    end;
  end;
end;
{ @end $707BC4 }

{ @routine $708854 TfShip2_RepairAllClicked }
procedure TfShip2.RepairAllClicked(Sender: TObjectGI);
var
  I, Cost, NodeCost, Nodes: Integer;
  Item: TEquipment;
  Control: TObjectGI;
begin
  if not CanUseLocalStorage then Exit;
  if GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning)
    else
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning);
    Exit;
  end;
  Cost := 0;
  NodeCost := 0;
  Nodes := 0;
  for I := 0 to PlayerHoldShip.Inventory.Count - 1 do
  begin
    Item := PlayerHoldShip.Inventory[I];
    if PlayerHoldShip.CanRepairEquipmentTech(Item) and (Item <> SelectedHoldItem) and
      ((Item.EquippedFlag <> 0) or (Item is THull)) and Item.NeedsRepair then
      if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = waNotSoldAndNodeRepair) then
        Inc(NodeCost,Item.CalculateRepairCost)
      else Inc(Cost,Item.CalculateRepairCost);
  end;
  if Cost + NodeCost <= 0 then Exit;
  if not GetPlayer.CanRepairArtefactsAtLocation then NodeCost := 0;
  if GetPlayer.Money < Cost + NodeCost then
  begin
    SoundManager.PlaySound('Sound.NoMoney');
    StartMoneyWarning;
    Exit;
  end;
  Galaxy.CheckIntegrityChecksum1(502);
  if NodeCost > 0 then
  begin
    Nodes := Round(NodeCost * 0.0025);
    if Nodes = 0 then Nodes := 1;
    if GetPlayer.GetAvailableNodeCount(PlayerHoldShip) < Nodes then
    begin
      ShowMessageBoxGI(Self,FormatText1(LocalizedText('FormShip.RepairMsgAllNeedNode'),TextHighlightColorTag,'<NeedNode>',IntToStr(Nodes)),mbgCancel);
      Nodes := 0;
    end
    else if ShowMessageBoxGI(Self,FormatText1(LocalizedText('FormShip.RepairMsgEnoughNode'),TextHighlightColorTag,'<NeedNode>',IntToStr(Nodes)),mbgOK or mbgCancel) = mbgResultOK then
      GetPlayer.ConsumeAvailableNodes(Nodes,PlayerHoldShip)
    else Nodes := 0;
  end;
  if Nodes <> 0 then Inc(Cost,NodeCost);
  if Cost > 0 then
  begin
    GetPlayer.SetMoney(GetPlayer.Money - Cost);
    for I := 0 to PlayerHoldShip.Inventory.Count - 1 do
    begin
      Item := PlayerHoldShip.Inventory[I];
      if PlayerHoldShip.CanRepairEquipmentTech(Item) and
        (not (Item is TWeapon) or (TWeapon(Item).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair) or (Nodes <> 0)) and
        (Item <> SelectedHoldItem) and ((Item.EquippedFlag <> 0) or (Item is THull)) and Item.NeedsRepair then
      begin
        Item.Repair;
        if Item is THull then Control := GetByName('HullRepair')
        else if Item is TWeapon then Control := GetByName('S_Weapon_' + IntToStr(Integer(Item.AssignedSlotData) and EquipmentSlotIndexMask) + 'Repair')
        else Control := GetByName('S_' + ItemTypeNames[Item.ItemType] + '_' + IntToStr(Integer(Item.AssignedSlotData) and EquipmentSlotIndexMask) + 'Repair');
        if Control <> nil then
          with Control as TgaiGI do SetActive(True);
      end;
    end;
    ShipStateChanged := True;
    SoundManager.PlaySound('Sound.Repair');
    if SelectedHoldKind = phkEquipment then
    begin
      I := 0;
      while I < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) do
      begin
        if PlayerHoldShip.FindEquippedItemInSlot(SelectedHoldItem.ItemType,I) = nil then Break;
        Inc(I);
      end;
      if I < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) then
      begin
        if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
        PlayerHoldShip.Inventory.Add(SelectedHoldItem);
        (SelectedHoldItem as TEquipment).AssignedSlotData := ((SelectedHoldItem as TEquipment).AssignedSlotData and EquipmentSecondaryFireFlag) or I;
        (SelectedHoldItem as TEquipment).EquippedFlag := 0;
        (SelectedHoldItem as TEquipment).Equip;
        SelectedHoldKind := phkEmpty;
        SelectedHoldItem := nil;
      end;
    end
    else if (SelectedHoldKind = phkArtefact) and
      (not PlayerHoldShip.HasEquippedArtefactOfSameUseGroup(SelectedHoldItem) or Galaxy.AreDuplicateArtefactsEnabled) then
    begin
      PlayerHoldShip.Artefacts.Add(SelectedHoldItem);
      (SelectedHoldItem as TEquipment).AssignedSlotData := 0;
      (SelectedHoldItem as TEquipment).EquippedFlag := 0;
      (SelectedHoldItem as TEquipment).Equip;
      SelectedHoldKind := phkEmpty;
      SelectedHoldItem := nil;
    end;
    Galaxy.PrimeIntegrityChecksum1(503);
    RefreshShipView;
    RemoveEmptyPlayerHoldSlots;
    PlayServiceAnimations := True;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $708854 }

{ @routine $7092BC TfShip2_RepairAllMouseEnter }
procedure TfShip2.RepairAllMouseEnter(Sender: TObjectGI);
begin
  with GetByName('SC_RepareFull_But') as TGraphButtonGI do Self.HighlightRepairableEquipment := not Disabled;
  RefreshShipView;
end;
{ @end $7092BC }

{ @routine $70932C TfShip2_RepairAllMouseLeave }
procedure TfShip2.RepairAllMouseLeave(Sender: TObjectGI);
begin
  HighlightRepairableEquipment := False;
  RefreshShipView;
end;
{ @end $70932C }

{ @routine $709350 TfShip2_LoadRockets }
procedure TfShip2.LoadRockets(Equipped: Boolean);
var
  I, Cost, Quantity: Integer;
  Item: TEquipment;
  Suffix: WideString;
  Event: TGalaxyEvent;
begin
  if not CanUseLocalStorage then Exit;
  if Equipped then
    with GetByName('LoadRocketsInSlots') do
      if not Active or not Parent.Active then Exit;
  if not Equipped then
    with GetByName('LoadRocketsInHold') do
      if not Active or not Parent.Active then Exit;
  if GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning)
    else
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning);
    Exit;
  end;
  Cost := 0;
  for I := 0 to PlayerHoldShip.Inventory.Count - 1 do
  begin
    Item := PlayerHoldShip.Inventory[I];
    if (Equipped = Boolean(Item.EquippedFlag)) and (Item <> SelectedHoldItem) and (Item is TWeapon) and (Item as TWeapon).NeedsAmmo then
      Inc(Cost,(Item as TWeapon).CalculateAmmoRefillCost);
  end;
  if Equipped then Suffix := 'Slot' else Suffix := 'Hold';
  if Cost <= 0 then
  begin
    ShowMessageBoxGI(Self,LocalizedColorText('FormShip.ReloadAll.' + Suffix + '.NoItem'),mbgCancel or mbgWarning);
    Exit;
  end;
  if GetPlayer.Money < Cost then
  begin
    ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.ReloadAll.' + Suffix + '.NoMoney'),TextHighlightColorTag,'<Money>',IntToStr(Cost)),mbgCancel or mbgWarning);
    Exit;
  end;
  if ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.ReloadAll.' + Suffix + '.Confirm'),TextHighlightColorTag,'<Money>',IntToStr(Cost)),mbgOK or mbgCancel or mbgQuestion) = 2 then Exit;
  if GetPlayer.Money < Cost then
  begin
    SoundManager.PlaySound('Sound.NoMoney');
    StartMoneyWarning;
    Exit;
  end;
  Galaxy.CheckIntegrityChecksum1(504);
  GetPlayer.SetMoney(GetPlayer.Money - Cost);
  Quantity := 0;
  for I := 0 to PlayerHoldShip.Inventory.Count - 1 do
  begin
    Item := PlayerHoldShip.Inventory[I];
    if (Equipped = Boolean(Item.EquippedFlag)) and (Item <> SelectedHoldItem) and (Item is TWeapon) and (Item as TWeapon).NeedsAmmo then
    begin
      Quantity := Quantity + (Item as TWeapon).AmmoCapacity - (Item as TWeapon).Ammo;
      (Item as TWeapon).Ammo := (Item as TWeapon).AmmoCapacity;
    end;
  end;
  Event := AddGalaxyEvent('PlayerBuysMissiles');
  Event.AddData(Cost);
  Event.AddData(Quantity);
  ShipStateChanged := True;
  SoundManager.PlaySound('Sound.Buy');
  if SelectedHoldKind = phkEquipment then
  begin
    I := 0;
    while I < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) do
    begin
      if PlayerHoldShip.FindEquippedItemInSlot(SelectedHoldItem.ItemType,I) = nil then Break;
      Inc(I);
    end;
    if I < PlayerHoldShip.GetSlotCountForItemType(SelectedHoldItem.ItemType) then
    begin
      if SelectedHoldItem is TWeapon then (SelectedHoldItem as TWeapon).Target := nil;
      PlayerHoldShip.Inventory.Add(SelectedHoldItem);
      (SelectedHoldItem as TEquipment).AssignedSlotData := ((SelectedHoldItem as TEquipment).AssignedSlotData and EquipmentSecondaryFireFlag) or I;
      (SelectedHoldItem as TEquipment).EquippedFlag := 0;
      (SelectedHoldItem as TEquipment).Equip;
      SelectedHoldKind := phkEmpty;
      SelectedHoldItem := nil;
    end;
  end
  else if (SelectedHoldKind = phkArtefact) and
    (not PlayerHoldShip.HasEquippedArtefactOfSameUseGroup(SelectedHoldItem) or Galaxy.AreDuplicateArtefactsEnabled) then
  begin
    PlayerHoldShip.Artefacts.Add(SelectedHoldItem);
    (SelectedHoldItem as TEquipment).AssignedSlotData := 0;
    (SelectedHoldItem as TEquipment).EquippedFlag := 0;
    (SelectedHoldItem as TEquipment).Equip;
    SelectedHoldKind := phkEmpty;
    SelectedHoldItem := nil;
  end;
  Galaxy.PrimeIntegrityChecksum1(505);
  RefreshShipView;
  RemoveEmptyPlayerHoldSlots;
  PlayServiceAnimations := True;
  ReopenRequested := True;
  PlayTransitionSounds := False;
  CloseClicked(nil);
end;
{ @end $709350 }

{ @routine $709D28 TfShip2_ToggleAfterburner }
procedure TfShip2.ToggleAfterburner(Sender: TObjectGI);
begin
  Galaxy.CheckIntegrityChecksum1(506);
  PlayerHoldShip.AfterburnerActive := not PlayerHoldShip.AfterburnerActive;
  PlayerHoldShip.RefreshDerivedStats(True);
  Galaxy.PrimeIntegrityChecksum1(507);
  RefreshShipView;
  ShowShipPropertyInfo(GetByName('ForsageBut'));
  if PlayerHoldShip.AfterburnerActive then SoundManager.PlaySound('Sound.ForsageOn')
  else SoundManager.PlaySound('Sound.ForsageOff');
  if PlayerHoldShip.AfterburnerActive then
    ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormShip.ForsageActivate'),mbgOK);
end;
{ @end $709D28 }

{ @routine $709ED8 TfShip2_ShowItemInfo }
procedure TfShip2.ShowItemInfo;
var
  Item: TEquipment;
  I, Slot, Count, Column, Row: Integer;
  Found, CanTake: Boolean;
  Hold: TPlayerHoldUnit;
  Animation: TgaiGI;
  Stored: PStorageEntry;
  CenterX, CenterY: Boolean;
  InfoWindow: TWindowGI;
  Position, CellSize: TPoint;
  Reserved70: Int64; { Native frame retains an unused eight-byte slot before expression temporaries. }
begin
  Found := False;
  CanTake := False;
  Animation := nil;
  Position := Classes.Point(0,0);
  CellSize := Classes.Point(0,0);
  CenterX := False;
  CenterY := False;
  if not Found then
  begin
    Count := PlayerHoldShip.GetSlotCountForItemType(t_Artefact);
    for Slot := 0 to Count - 1 do
    begin
      Item := PlayerHoldShip.FindEquippedItemInSlot(t_Artefact,Slot);
      if Item <> nil then
        with ArtefactSlotZones[Slot] do
          if HitTest(GetCursorPoint) then
          begin
            CenterX := True;
            Position := Classes.Point(HitTestBounds.Left + ClientSize.X div 2,HitTestBounds.Top + ClientSize.Y);
            ShowEquipmentInfo(Item,False);
            Found := True;
            CanTake := True;
            Break;
          end;
    end;
  end;
  if not Found then
    for I := 0 to 7 do
    begin
      Count := PlayerHoldShip.GetSlotCountForItemType(EquipmentSlotLayouts[I].ItemType);
      for Slot := 0 to Count - 1 do
      begin
        Item := PlayerHoldShip.FindEquippedItemInSlot(EquipmentSlotLayouts[I].ItemType,Slot);
        if Item <> nil then
          with EquipmentSlotZones[I,Slot] do
            if HitTest(GetCursorPoint) then
            begin
              CenterX := True;
              Position := Classes.Point(HitTestBounds.Left + ClientSize.X div 2,HitTestBounds.Top + ClientSize.Y);
              ShowEquipmentInfo(Item,False);
              Found := True;
              CanTake := True;
              if AnimItem then Animation := EquipmentSlotAnimations[I,Slot];
              Break;
            end;
      end;
    end;
  if not Found then
    with GetByName('S_Hull_0z') as TZoneGI do
      if HitTest(GetCursorPoint) then
      begin
        CenterX := True;
        Position := Classes.Point(HitTestBounds.Left + ClientSize.X div 2,HitTestBounds.Top + ClientSize.Y);
        ShowEquipmentInfo(PlayerHoldShip.GetHull,False);
        Found := True;
        if IsHoldNormalShip then CanTake := True;
      end;
  if not Found and not RemoteHoldMode then
    for I := 0 to 5 do
    begin
      if HoldFirstIndex + I >= PlayerHoldEntries.Count then Hold := nil
      else Hold := PlayerHoldEntries[HoldFirstIndex + I];
      with HoldSlotZones[I] do
        if HitTest(GetCursorPoint) then
        begin
          CenterX := True;
          Position := Classes.Point(HitTestBounds.Left + ClientSize.X div 2,HitTestBounds.Top + ClientSize.Y);
          CellSize := ClientSize;
          if (Hold <> nil) and ((Hold.Kind = phkEquipment) or (Hold.Kind = phkArtefact)) then ShowEquipmentInfo(Hold.Item,False)
          else if (Hold <> nil) and (Hold.Kind = phkGoods) then ShowHoldGoodsInfo(Hold.GoodsIndex)
          else Continue;
          Found := True;
          CanTake := True;
          Break;
        end;
    end;
  if not Found and RemoteHoldMode then
    for Row := 0 to 10 do
    begin
      Column := 0;
      while Column < 5 do
      begin
        if RemoteHoldImages[Row * 5 + Column].ContainsPoint(GetCursorPoint) then
        begin
          CenterY := True;
          Position.X := -(670 + ExtraScreenWidth div 2);
          with RemoteHoldImages[Row * 5 + Column] do Position.Y := HitTestBounds.Top + ClientSize.Y div 2;
          I := FindPlayerHoldIndexByOrder(RemoteHoldFirstOrder + Column + Row * 5);
          if I >= 0 then
          begin
            Hold := PlayerHoldEntries[I];
            if (Hold <> nil) and ((Hold.Kind = phkEquipment) or (Hold.Kind = phkArtefact)) then ShowEquipmentInfo(Hold.Item,False)
            else if (Hold <> nil) and (Hold.Kind = phkGoods) then ShowHoldGoodsInfo(Hold.GoodsIndex)
            else Continue; { Native retries the same column for an unexpected hold entry kind. }
            Found := True;
            CanTake := True;
            Break;
          end;
        end;
        Inc(Column);
      end;
      if Column < 5 then Break;
    end;
  if not Found and StorageUpButton.Active then
    for I := 0 to StorageImageCount - 1 do
      if StorageImages[I].ContainsPoint(GetCursorPoint) then
      begin
        Slot := GetPlayer.FindStorageIndexByLocationAndSlot(GetLocalStorageOwner,StorageFirstSlot + I);
        if Slot >= 0 then
        begin
          Stored := GetPlayer.StorageEntries[Slot];
          CenterY := True;
          Position.X := 158;
          with GetByName('Storage_' + IntToStr(I) + 'i') as TImageGI do Position.Y := HitTestBounds.Top + ClientSize.Y div 2;
          if Stored.Item is TGoods then ShowStoredGoodsInfo(Stored.Item as TGoods)
          else ShowEquipmentInfo(Stored.Item,True);
          Found := True;
          CanTake := True;
        end;
      end;
  if (Position.X <> 0) or (Position.Y <> 0) then
  begin
    if ItemInfoWindow.Active then InfoWindow := ItemInfoWindow
    else InfoWindow := GetByName('InfoHull') as TWindowGI;
    if DynamicTipsPos then
    begin
      if CenterX then Dec(Position.X,InfoWindow.ClientSize.X div 2);
      if Position.X < 0 then Position.X := Abs(Position.X) - InfoWindow.ClientSize.X;
      if CenterY then
      begin
        Dec(Position.Y,InfoWindow.ClientSize.Y div 2);
        if Position.Y + InfoWindow.ClientSize.Y + 10 > GameScreenHeight then
          Position.Y := GameScreenHeight - InfoWindow.ClientSize.Y - 10;
      end
      else if Position.Y + InfoWindow.ClientSize.Y + 10 > GameScreenHeight then
        Position.Y := Position.Y - CellSize.Y - InfoWindow.ClientSize.Y;
      InfoWindow.SetPosition(Position);
    end
    else InfoWindow.SetPosition(Classes.Point(10,10));
  end;
  if SelectedHoldKind = phkEmpty then
    if CanTake then
    begin
      if not IsCursorImageSelected('Take') then SetCursorByName('Take');
    end
    else if not IsCursorImageSelected('Main') then SetCursorByName('Main');
  if not Found and (ItemInfoHideTimer = nil) then ShowEquipmentInfo(nil,False);
  if (Animation <> HoveredEquipmentAnimation) and (HoveredEquipmentAnimation <> nil) then
  begin
    HoveredEquipmentAnimation.StopAutoPlayback;
    HoveredEquipmentAnimation.UserState := HoveredEquipmentAnimation.SequenceFrame;
    HoveredEquipmentAnimation := nil;
  end;
  if (Animation <> HoveredEquipmentAnimation) and (Animation <> nil) then
  begin
    HoveredEquipmentAnimation := Animation;
    HoveredEquipmentAnimation.UpdateAutoGeometry;
    HoveredEquipmentAnimation.SetSequenceFrame(Min(Cardinal(HoveredEquipmentAnimation.UserState),HoveredEquipmentAnimation.SequenceFrameCount - 1));
    HoveredEquipmentAnimation.SetActive(True);
    HoveredEquipmentAnimation.RestartPlayback;
    TObjectGI(HoveredEquipmentAnimation.UserData).SetActive(False);
  end;
end;
{ @end $709ED8 }

{ @routine $70A8C8 TfShip2_ShowItemInfoTimer }
procedure TfShip2.ShowItemInfoTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if RightPanelSlideTimer = nil then ShowItemInfo;
end;
{ @end $70A8C8 }

{ @routine $70A8F0 TfShip2_HideItemInfo }
procedure TfShip2.HideItemInfo(Timer: PCallbackTimerGI; UserData: Integer);
begin
  DisplayedItemKey := 0;
  if ItemInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(ItemInfoHideTimer);
    ItemInfoHideTimer := nil;
  end;
  GetByName('PII').SetActive(False);
  GetByName('InfoHull').SetActive(False);
  RefreshActionPanels(SelectedHoldKind,SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,SelectedHoldItem,SelectedHoldOrigin);
end;
{ @end $70A8F0 }

{ @routine $70A9C4 TfShip2_LayoutItemInfo }
procedure TfShip2.LayoutItemInfo(Window: TWindowGI; Title, Text: TLabelGI; KeepMinimumHeight, WordWrap: Boolean; MinimumWidth: Integer);
var
  TextSize, WindowSize, TargetSize: TPoint;
  Attempts: Integer;
  TargetRatio, Ratio: Single;
  Borders: Windows.TRect;
begin
  TargetRatio := 1.6230366;
  Borders := Window.WorkSubRect;
  TargetSize := Window.AlignSizeToBorderTiles(Classes.Point(0, 0));
  Attempts := 100;
  while Attempts > 0 do
  begin
    Text.SetTextAlignX(taxCenter);
    Text.SetTextAlignY(tayCenter);
    Text.SetSize(Classes.Point(TargetSize.X - Borders.Left - Borders.Right, 1));
    if WordWrap then
    begin
      Text.SetWordWrapEnabled(True);
      Text.SetTextAlignX(taxLeft);
      Text.SetTextAlignY(tayAuto);
    end
    else
    begin
      Text.SetWordWrapEnabled(False);
      Text.SetTextAlignX(taxAuto);
      Text.SetTextAlignY(tayAuto);
    end;
    TextSize := Text.ClientSize;
    if KeepMinimumHeight then
      Window.SetSize(Classes.Point(TextSize.X + Borders.Left + Borders.Right, Max(TargetSize.Y, TextSize.Y + Borders.Top + Borders.Bottom)))
    else
      Window.SetSize(Classes.Point(TextSize.X + Borders.Left + Borders.Right, TextSize.Y + Borders.Top + Borders.Bottom));
    Window.UpdateAutoGeometry;
    WindowSize := Window.ClientSize;
    Ratio := WindowSize.X / WindowSize.Y;
    if Ratio - TargetRatio < -0.1 then Inc(TargetSize.X, 10)
    else if Ratio - TargetRatio > 0.1 then Inc(TargetSize.Y, 10)
    else Break;
    Dec(Attempts);
  end;
  Window.SetSize(Classes.Point(Max(MinimumWidth, Window.ClientSize.X), Window.ClientSize.Y));
  Window.UpdateAutoGeometry;
  Text.SetTextAlignX(taxCenter);
  Text.SetTextAlignY(tayCenterEx);
  Text.SetSize(Classes.Point(Window.ClientSize.X - Borders.Left - Borders.Right, Window.ClientSize.Y - Borders.Top - Borders.Bottom));
  Text.SetPosition(Borders.TopLeft);
  Title.SetSize(Classes.Point(Window.ClientSize.X - Window.WorkSubRect.Right - Title.LocalPosition.X - 15, Title.ClientSize.Y));
end;
{ @end $70A9C4 }

{ @routine $70AE84 TfShip2_LayoutObjectInfo }
procedure TfShip2.LayoutObjectInfo(Window: TWindowGI; Title: TLabelGI; Left1, Right1, Left2, Right2, Left3, Right3, Left4, Right4, Left5, Right5, Left6, Right6, Left7, Right7, Left8, Right8: TLabelGI; Emblem: TObjectGI; KeepMinimumHeight: Boolean; MinimumWidth: Integer);
var
  TargetRatio, Ratio: Single;
  TextSize, WindowSize, TargetSize: TPoint;
  Attempts, Reserved: Integer; { Native frame retains one unused local. }
  Borders: Windows.TRect;
  LeftWidth, RightWidth, TotalHeight, EmblemMargin, CenterX, CenterY, RowY: Integer;

  // @nested $70AC50 MeasurePair
  procedure MeasurePair(Left, Right: TLabelGI); // @addr $70AC50 @calls "0x70aee7,0x70aef4,0x70af01,0x70af0e,0x70af1b,0x70af28,0x70af35,0x70af42" @note "Nested in LayoutObjectInfo; captures column widths, total height and row count."
  begin
    if (Left <> nil) and (Right <> nil) and Left.Active and Right.Active then
    begin
      Left.SetTextAlignX(taxAuto);
      Right.SetTextAlignX(taxAuto);
      LeftWidth := Max(LeftWidth, Left.ClientSize.X);
      RightWidth := Max(RightWidth, Right.ClientSize.X);
      Inc(TotalHeight, Max(Left.ClientSize.Y, Right.ClientSize.Y));
      Inc(Attempts);
    end;
  end;

  // @nested $70AD30 PlacePair
  procedure PlacePair(Left, Right: TLabelGI); // @addr $70AD30 @calls "0x70b0a9,0x70b0b6,0x70b0c3,0x70b0d0,0x70b0dd,0x70b0ea,0x70b0f7,0x70b104" @note "Nested in LayoutObjectInfo; captures window, border dimensions and accumulated row position."
  begin
    if (Left <> nil) and (Right <> nil) and Left.Active and Right.Active then
    begin
      CenterX := (Window.ClientSize.X - Borders.Left - Borders.Right) div 2 -
        (LeftWidth + RightWidth + EmblemMargin) div 2;
      CenterY := (Window.ClientSize.Y - Borders.Top - Borders.Bottom) div 2 - TotalHeight div 2;
      Left.SetPosition(Classes.Point(Borders.Left + CenterX + LeftWidth - Left.ClientSize.X, RowY + Borders.Top + CenterY));
      Right.SetPosition(Classes.Point(Borders.Left + CenterX + LeftWidth, RowY + Borders.Top + CenterY));
      Inc(RowY, Max(Left.ClientSize.Y, Right.ClientSize.Y));
      Inc(Attempts);
    end;
  end;

begin
  TargetRatio := 1.6230366;
  LeftWidth := 0;
  RightWidth := 0;
  TotalHeight := 0;
  RowY := 0;
  Attempts := 0;
  EmblemMargin := 0;
  if Emblem <> nil then EmblemMargin := Emblem.ClientSize.X div 2;
  Borders := Window.WorkSubRect;
  MeasurePair(Left1, Right1);
  MeasurePair(Left2, Right2);
  MeasurePair(Left3, Right3);
  MeasurePair(Left4, Right4);
  MeasurePair(Left5, Right5);
  MeasurePair(Left6, Right6);
  MeasurePair(Left7, Right7);
  MeasurePair(Left8, Right8);
  TargetSize := Window.AlignSizeToBorderTiles(Classes.Point(0, 0));
  Attempts := 100;
  while Attempts > 0 do
  begin
    TextSize := Classes.Point(LeftWidth + RightWidth + EmblemMargin, TotalHeight);
    if KeepMinimumHeight then
      Window.SetSize(Classes.Point(TextSize.X + Borders.Left + Borders.Right, Max(TargetSize.Y, TextSize.Y + Borders.Top + Borders.Bottom)))
    else
      Window.SetSize(Classes.Point(TextSize.X + Borders.Left + Borders.Right, TextSize.Y + Borders.Top + Borders.Bottom));
    Window.UpdateAutoGeometry;
    WindowSize := Window.ClientSize;
    Ratio := WindowSize.X / WindowSize.Y;
    if Ratio - TargetRatio < -0.1 then Inc(TargetSize.X, 10)
    else if Ratio - TargetRatio > 0.1 then Inc(TargetSize.Y, 10)
    else Break;
    Dec(Attempts);
  end;
  Window.SetSize(Classes.Point(Max(MinimumWidth, Window.ClientSize.X), Window.ClientSize.Y));
  Window.UpdateAutoGeometry;
  Attempts := 0;
  PlacePair(Left1, Right1);
  PlacePair(Left2, Right2);
  PlacePair(Left3, Right3);
  PlacePair(Left4, Right4);
  PlacePair(Left5, Right5);
  PlacePair(Left6, Right6);
  PlacePair(Left7, Right7);
  PlacePair(Left8, Right8);
  Title.SetSize(Classes.Point(Window.ClientSize.X - Window.WorkSubRect.Right - Title.LocalPosition.X - 15, Title.ClientSize.Y));
  if Emblem <> nil then
    Emblem.SetPosition(Classes.Point(Window.ClientSize.X + ItemRaceImagePosition.X, Window.ClientSize.Y + ItemRaceImagePosition.Y - GiScalePixels(5)));
end;
{ @end $70AE84 }

{ @routine $70B1A0 TfShip2_ShowEquipmentInfo }
procedure TfShip2.ShowEquipmentInfo(Item: TItem; FromStorage: Boolean);
const
  DurableTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
var
  Equipment: TEquipment;
  Origin: Integer;
  Text: WideString;
  SpecialHull: Boolean;
  BarWidth, CapWidth, MinimumWidth: Integer;
  Reserved9C, ReservedA0, ReservedA4: Integer;
begin
  Equipment := Item as TEquipment;
  if Equipment = nil then
  begin
    DisplayedItemKey := 0;
    if ItemInfoHideTimer <> nil then
    begin
      CancelCallbackTimer(ItemInfoHideTimer);
      ItemInfoHideTimer := nil;
    end;
    ItemInfoHideTimer := ScheduleCallbackTimer(100,99999,HideItemInfo);
    if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind in [phkEquipment,phkArtefact]) and not PreserveSpaceMusic and
      (SelectedHoldItem.ScriptItem <> nil) and (TScriptItem(SelectedHoldItem.ScriptItem).OnUseText <> '') then OpenUseSidePanel
    else if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind = phkArtefact) and (SelectedHoldItem is TArtefact) and not PreserveSpaceMusic and
      ((SelectedHoldItem as TArtefact).GetOnUseCodeText <> '') then OpenUseSidePanel
    else if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind = phkEquipment) and not PreserveSpaceMusic and
      (SelectedHoldItem.ItemType = t_UselessItem) and ((SelectedHoldItem as TUselessItem).GetOnUseCodeText <> '') then OpenUseSidePanel
    else if (SelectedHoldKind = phkEquipment) and not PreserveSpaceMusic and (SelectedHoldItem.ItemType = t_TreasureMap) then OpenUseSidePanel
    else CloseUseSidePanel;
  end
  else if DisplayedItemKey <> Integer(Item) then
  begin
    DisplayedItemKey := Integer(Item);
    UpdateInfoHint(0,0);
    SoundManager.PlaySound('Sound.ShipItemInfo');
    if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    begin
      if Item.ScriptItem <> nil then TScriptItem(Item.ScriptItem).RunActionCode(satOnShowingItemInfo,PlayerHoldShip,nil,nil,0);
      if Item is TEquipmentWithActCode then RunItemConfigActionCode(Item, satOnShowingItemInfo,PlayerHoldShip,nil,nil,0);
    end;
    if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind in [phkEquipment,phkArtefact]) and not PreserveSpaceMusic and
      (SelectedHoldItem.ScriptItem <> nil) and (TScriptItem(SelectedHoldItem.ScriptItem).OnUseText <> '') then OpenUseSidePanel
    else if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind = phkArtefact) and not PreserveSpaceMusic and (SelectedHoldItem is TArtefact) and
      ((SelectedHoldItem as TArtefact).GetOnUseCodeText <> '') then OpenUseSidePanel
    else if (GetPlayer = PlayerHoldShip) and (SelectedHoldKind = phkEquipment) and
      (SelectedHoldItem.ItemType = t_UselessItem) and ((SelectedHoldItem as TUselessItem).GetOnUseCodeText <> '') then OpenUseSidePanel;
    if (GetPlayer = PlayerHoldShip) and (Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).OnUseText <> '') then OpenUseSidePanel
    else if (GetPlayer = PlayerHoldShip) and not PreserveSpaceMusic and (Item is TArtefact) and ((Item as TArtefact).GetOnUseCodeText <> '') then OpenUseSidePanel
    else if (GetPlayer = PlayerHoldShip) and not PreserveSpaceMusic and (Item.ItemType = t_UselessItem) and ((Item as TUselessItem).GetOnUseCodeText <> '') then OpenUseSidePanel
    else if (Item.ItemType = t_TreasureMap) and not PreserveSpaceMusic then OpenUseSidePanel;
    if ItemInfoHideTimer <> nil then
    begin
      CancelCallbackTimer(ItemInfoHideTimer);
      ItemInfoHideTimer := nil;
    end;
    if FromStorage then Origin := 1 else Origin := 0;
    if (SelectedHoldKind = phkEmpty) and (Item is TArtefact) then RefreshActionPanels(phkArtefact,Byte(Item.ItemType),0,0,Item,Origin)
    else if SelectedHoldKind = phkEmpty then RefreshActionPanels(phkEquipment,Byte(Item.ItemType),0,0,Item,Origin)
    else RefreshActionPanels(SelectedHoldKind,SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,SelectedHoldItem,SelectedHoldOrigin);
    SpecialHull := ((PlayerHoldShip is TRuins) or (PlayerHoldShip is TTranclucator) or (PlayerHoldShip is TKling)) and (PlayerHoldShip.GetHull = Equipment);
    if (Item.ItemType = t_Hull) and not SpecialHull then
    begin
      EquipmentShopScreen.RefreshHullInfo(Self,Item as THull,Equipment.GetInfoText(TextHighlightColorTag,PlayerHoldShip),True);
      ItemInfoWindow.SetActive(False);
      GetByName('InfoHullImage').SetActive(False);
      if PlayerHoldShip.GetHull = Equipment then
      begin
        Text := PlayerHoldShip.GetShipPortraitImagePath;
        if Text <> '' then
          with GetByName('InfoHullImage') as TImageGI do
          begin
            SetActive(True);
            SetImagePath('GraphBuf');
            with GraphBufControl do
            begin
              SourceHasPerPixelAlpha := True;
              LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(Text,1,','),GraphBuf);
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X,Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),5)
              else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),ClientSize.Y,5);
            end;
            SetImageKindX(ikxCenter);
            SetImageKindY(ikyCenter);
            SetPosition(SubtractPoints(ShipScreen.ItemImageCenter,GetVisualCenter));
          end;
      end
      else
        with GetByName('InfoHullImage') as TImageGI do
        begin
          SetActive(True);
          SetImagePath('GI,' + GetShopItemIconName(Equipment) + 's');
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter,GetVisualCenter));
        end;
    end
    else
    begin
      ItemInfoWindow.SetActive(True);
      GetByName('InfoHull').SetActive(False);
      with ItemImage do
      begin
        SetActive(PlayerHoldShip.GetHull <> Equipment);
        if Active then
        begin
          SetImagePath('GI,' + GetShopItemIconName(Equipment) + 's');
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter,GetVisualCenter));
        end;
      end;
      with GetByName('InfoImage2') as TGraphBufGI do
      begin
        SetActive(PlayerHoldShip.GetHull = Equipment);
        if Active then
        begin
          Text := PlayerHoldShip.GetShipPortraitImagePath;
          SetActive(Text <> '');
          if Active then
          begin
            SourceHasPerPixelAlpha := True;
            LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(Text,1,','),GraphBuf);
            if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
              GraphBuf.RescaleRgba(ClientSize.X - 5,Round((ClientSize.X - 5) / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),5)
            else GraphBuf.RescaleRgba(Round((ClientSize.Y - 5) / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),ClientSize.Y - 5,5);
            SetImageKindX(ikxCenter);
            SetImageKindY(ikyCenter);
            SetPosition(SubtractPoints(ShipScreen.ItemImageCenter,GetVisualCenter));
          end;
        end;
      end;
      ItemNameLabel.SetText('');
      ItemNameLabel.SetText(WrapTextInColor(Equipment.GetDisplayName,InfoNameColorTag));
      ItemDescriptionLabel.SetText(Equipment.GetInfoText(TextHighlightColorTag,PlayerHoldShip));
      ItemSizeLabel.SetText(IntToStr(Equipment.Weight));
      ItemPriceLabel.SetText(IntToStr(Equipment.Cost));
      with ItemRaceImage do
      begin
        SetImagePath(GetFactionEmblemPath(Equipment.GetOwnerConfigName));
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
      if not (Byte(Equipment.ItemType) in DurableTypes) and (Equipment.ItemType <> t_Hull) then
      begin
        with GetByName('InfoDurable') as TImageGI do Parent.Parent.SetActive(False);
        MinimumWidth := 0;
      end
      else
      begin
        if Equipment is THull then BarWidth := Round(Sqrt(Equipment.Weight / HullBaseSize / Max(0.1,Equipment.GetFragilityFactor([]))) * 64)
        else BarWidth := Round(64 / Max(0.1,Equipment.GetFragilityFactor([])));
        BarWidth := Min(192,Max(32,BarWidth));
        with GetByName('InfoDurableLeft') as TImageGI do
        begin
          CapWidth := GetContentSize.X;
          MinimumWidth := 2 * CapWidth + BarWidth + LocalPosition.X + Parent.LocalPosition.X + 2 * Parent.Parent.LocalPosition.X;
        end;
        with GetByName('InfoDurable') as TImageGI do
        begin
          Parent.Parent.SetActive(True);
          Parent.Parent.SetSize(Classes.Point(2 * CapWidth + BarWidth,Parent.Parent.ClientSize.Y));
          Parent.SetSize(Classes.Point(BarWidth + 2,Parent.Parent.ClientSize.Y));
          if Equipment.ItemType = t_Hull then
            SetPosition(Classes.Point(Round((Equipment as THull).HullPoints / (Equipment as THull).Weight * BarWidth) - (GetContentSize.X - 5),LocalPosition.Y))
          else SetPosition(Classes.Point(Round(BarWidth * (Equipment.ConditionPercent / 100)) - (GetContentSize.X - 5),LocalPosition.Y));
        end;
        with GetByName('InfoDurableRight') as TImageGI do
        begin
          SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X,LocalPosition.Y));
          Parent.SetPosition(Classes.Point(CapWidth,Parent.LocalPosition.Y));
          Parent.SetSize(Classes.Point(BarWidth + CapWidth,Parent.ClientSize.Y));
        end;
        with GetByName('InfoDurableBack') as TImageGI do
        begin
          SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X,LocalPosition.Y));
          Parent.SetSize(Classes.Point(BarWidth + CapWidth,Parent.ClientSize.Y));
        end;
      end;
      LayoutItemInfo(ItemInfoWindow,ItemNameLabel,ItemDescriptionLabel,True,True,MinimumWidth);
      ItemSizeLabel.SetPosition(Classes.Point(ItemSizeLabelPosition.X,ItemInfoWindow.ClientSize.Y + ItemSizeLabelPosition.Y));
      ItemPriceLabel.SetPosition(Classes.Point(ItemPriceLabelPosition.X,ItemInfoWindow.ClientSize.Y + ItemPriceLabelPosition.Y));
      ItemRaceImage.SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ItemRaceImagePosition.X,ItemInfoWindow.ClientSize.Y + ItemRaceImagePosition.Y));
    end;
  end;
end;
{ @end $70B1A0 }

{ @routine $70C680 TfShip2_ShowHoldGoodsInfo }
procedure TfShip2.ShowHoldGoodsInfo(Good: Byte);
var
  Changed: Boolean;
  Text: WideString;
begin
  UpdateInfoHint(0,0);
  Changed := False;
  if ItemInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(ItemInfoHideTimer);
    ItemInfoHideTimer := nil;
  end;
  if Good + 1 <> DisplayedItemKey then
  begin
    DisplayedItemKey := Good + 1;
    if SelectedHoldKind = phkEmpty then
      RefreshActionPanels(phkGoods,Good,PlayerHoldShip.CargoGoods[Good].Count,PlayerHoldShip.CargoGoods[Good].TotalCost,nil,0)
    else RefreshActionPanels(SelectedHoldKind,SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,SelectedHoldItem,SelectedHoldOrigin);
    if not ItemInfoWindow.Active then Changed := True;
    ItemInfoWindow.SetActive(True);
    GetByName('InfoHull').SetActive(False);
    with GetByName('InfoImage') as TImageGI do
    begin
      if GetImagePath <> 'GI,' + GetItemTypeBitmapPath(TItemType(Good)) then Changed := True;
      SetImagePath('GI,' + GetItemTypeBitmapPath(TItemType(Good)));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetPosition(SubtractPoints(ItemImageCenter,GetVisualCenter));
    end;
    Text := LocalizedText('Items.Goods.Text.' + IntToStr(Good + 1));
    Text := Text + #13#10 + FormatText1(LocalizedText('FormShip.CostGoods'),TextHighlightColorTag,'<OldCost>',IntToStr(Round(PlayerHoldShip.GetAverageCargoCost(Good))));
    if (GetByName('InfoName') as TLabelGI).GetText <> WrapTextInColor(GoodsMarket[Good].DisplayName,InfoNameColorTag) then Changed := True;
    if (GetByName('InfoText') as TLabelGI).GetText <> Text then Changed := True;
    if (GetByName('InfoSize') as TLabelGI).GetText <> IntToStr(PlayerHoldShip.CargoGoods[Good].Count) then Changed := True;
    if (GetByName('InfoPrice') as TLabelGI).GetText <> IntToStr(PlayerHoldShip.CargoGoods[Good].TotalCost) then Changed := True;
    (GetByName('InfoName') as TLabelGI).SetText(WrapTextInColor(GoodsMarket[Good].DisplayName,InfoNameColorTag));
    (GetByName('InfoText') as TLabelGI).SetText(Text);
    (GetByName('InfoSize') as TLabelGI).SetText(IntToStr(PlayerHoldShip.CargoGoods[Good].Count));
    (GetByName('InfoPrice') as TLabelGI).SetText(IntToStr(PlayerHoldShip.CargoGoods[Good].TotalCost));
    with GetByName('EmRace') as TImageGI do
    begin
      if GetImagePath <> GetFactionEmblemPath(PlayerHoldShip.GetFactionNameKey) then Changed := True;
      SetImagePath(GetFactionEmblemPath(PlayerHoldShip.GetFactionNameKey));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
    end;
    GetByName('InfoDurable').Parent.Parent.SetActive(False);
    LayoutItemInfo(ItemInfoWindow,ItemNameLabel,ItemDescriptionLabel,True,True,0);
    ItemSizeLabel.SetPosition(Classes.Point(ItemSizeLabelPosition.X,ItemInfoWindow.ClientSize.Y + ItemSizeLabelPosition.Y));
    ItemPriceLabel.SetPosition(Classes.Point(ItemPriceLabelPosition.X,ItemInfoWindow.ClientSize.Y + ItemPriceLabelPosition.Y));
    ItemRaceImage.SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ItemRaceImagePosition.X,ItemInfoWindow.ClientSize.Y + ItemRaceImagePosition.Y));
    if Changed then SoundManager.PlaySound('Sound.ShipItemInfo');
  end;
end;
{ @end $70C680 }

{ @routine $70CF50 TfShip2_ShowStoredGoodsInfo }
procedure TfShip2.ShowStoredGoodsInfo(Goods: TGoods);
var
  Text: WideString;
  AverageCost: Single;
begin
  UpdateInfoHint(0,0);
  if ItemInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(ItemInfoHideTimer);
    ItemInfoHideTimer := nil;
  end;
  if DisplayedItemKey <> Integer(Goods) then
  begin
    DisplayedItemKey := Integer(Goods);
    if SelectedHoldKind = phkEmpty then
      RefreshActionPanels(phkGoods,Byte(Goods.ItemType),Goods.Quantity,Goods.Cost,nil,0)
    else RefreshActionPanels(SelectedHoldKind,SelectedGoodsIndex,SelectedGoodsQuantity,SelectedGoodsCost,SelectedHoldItem,SelectedHoldOrigin);
    SoundManager.PlaySound('Sound.ShipItemInfo');
    GetByName('PII').SetActive(True);
    GetByName('InfoHull').SetActive(False);
    with GetByName('InfoImage') as TImageGI do
    begin
      SetImagePath('GI,' + GetItemTypeBitmapPath(Goods.ItemType));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetPosition(SubtractPoints(ItemImageCenter,GetVisualCenter));
    end;
    Text := LocalizedText('Items.Goods.Text.' + IntToStr(Ord(Goods.ItemType) + 1));
    if Goods.Quantity > 0 then AverageCost := Goods.Cost / Goods.Quantity
    else AverageCost := 0;
    Text := Text + #13#10 + FormatText1(LocalizedText('FormShip.CostGoods'),TextHighlightColorTag,'<OldCost>',IntToStr(Round(AverageCost)));
    (GetByName('InfoName') as TLabelGI).SetText(WrapTextInColor(GoodsMarket[Ord(Goods.ItemType)].DisplayName,InfoNameColorTag));
    (GetByName('InfoText') as TLabelGI).SetText(Text);
    (GetByName('InfoSize') as TLabelGI).SetText(IntToStr(Goods.Quantity));
    (GetByName('InfoPrice') as TLabelGI).SetText(IntToStr(Goods.Cost));
    with GetByName('EmRace') as TImageGI do
    begin
      SetImagePath(GetFactionEmblemPath(PlayerHoldShip.GetFactionNameKey));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
    end;
    GetByName('InfoDurable').Parent.Parent.SetActive(False);
    LayoutItemInfo(ItemInfoWindow,ItemNameLabel,ItemDescriptionLabel,True,True,0);
    ItemSizeLabel.SetPosition(Classes.Point(ItemSizeLabelPosition.X,ItemInfoWindow.ClientSize.Y + ItemSizeLabelPosition.Y));
    ItemPriceLabel.SetPosition(Classes.Point(ItemPriceLabelPosition.X,ItemInfoWindow.ClientSize.Y + ItemPriceLabelPosition.Y));
    ItemRaceImage.SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ItemRaceImagePosition.X,ItemInfoWindow.ClientSize.Y + ItemRaceImagePosition.Y));
  end;
end;
{ @end $70CF50 }

{ @routine $70D5F8 TfShip2_RefreshMoneyWarning }
procedure TfShip2.RefreshMoneyWarning;
begin
  if MoneyWarningVisible and ((MoneyWarningTicks and 1) = 0) then
  begin
    GetByName('ADD_WarningMoney').SetActive(True);
    with GetByName('ADD_Money') as TLabelGI do
    begin
      SetTextColor(CurrentPixelFormat.PackRgbBytes(255,128,61));
      SetText(IntToStr(GetPlayer.Money));
      SetActive(True);
    end;
  end
  else
  begin
    GetByName('ADD_WarningMoney').SetActive(False);
    GetByName('ADD_Money').SetActive(False);
  end;
end;
{ @end $70D5F8 }

{ @routine $70D748 TfShip2_StartMoneyWarning }
procedure TfShip2.StartMoneyWarning;
begin
  if MoneyWarningTimer <> nil then
  begin
    CancelCallbackTimer(MoneyWarningTimer);
    MoneyWarningTimer := nil;
  end;
  MoneyWarningTimer := ScheduleCallbackTimer(100,100,AdvanceMoneyWarning);
  MoneyWarningVisible := True;
  MoneyWarningTicks := 6;
  RefreshMoneyWarning;
end;
{ @end $70D748 }

{ @routine $70D7C0 TfShip2_AdvanceMoneyWarning }
procedure TfShip2.AdvanceMoneyWarning(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Dec(MoneyWarningTicks);
  if MoneyWarningTicks <= 0 then
  begin
    if MoneyWarningTimer <> nil then
    begin
      CancelCallbackTimer(MoneyWarningTimer);
      MoneyWarningTimer := nil;
    end;
    MoneyWarningVisible := False;
  end;
  RefreshMoneyWarning;
end;
{ @end $70D7C0 }

{ @routine $70D824 TfShip2_ShowNoDropMessage }
procedure TfShip2.ShowNoDropMessage(Code: Integer);
var
  Text: WideString;
  Options: Cardinal;
begin
  if Code = 1 then Text := LocalizedColorText('FormShip.NoDrop')
  else Text := LocalizedColorText('FormShip.NoDrop' + IntToWideString(Code));
  Options := 1;
  if CountDelimitedPartsW(Text,'|') > 1 then
  begin
    Options := ExtractDigitsToIntW(ExtractDelimitedPartW(Text,0,'|'));
    Text := ExtractDelimitedPartW(Text,1,'|');
  end;
  ShowMessageBoxGI(Self,Text,Options);
end;
{ @end $70D824 }

{ @routine $70D944 TfShip2_GateMouseEnter }
procedure TfShip2.GateMouseEnter(Sender: TObjectGI);
begin
  if (SelectedHoldKind = phkEquipment) and (TObject(SelectedHoldItem) is THull) then CloseGate
  else if SelectedHoldKind <> phkEmpty then OpenGate else CloseGate;
end;
{ @end $70D944 }

{ @routine $70D9A0 TfShip2_GateMouseLeave }
procedure TfShip2.GateMouseLeave(Sender: TObjectGI);
begin
  CloseGate;
end;
{ @end $70D9A0 }

{ @routine $70D9B8 TfShip2_OpenGate }
procedure TfShip2.OpenGate;
begin
  if GateSlideTimer <> nil then
  begin
    CancelCallbackTimer(GateSlideTimer);
    GateSlideTimer := nil;
  end;
  GateSlideTimer := ScheduleCallbackTimer(20,20,SlideGateTimer,1);
  (GetByName('GateAnim') as TgaiGI).RestartPlayback;
end;
{ @end $70D9B8 }

{ @routine $70DA48 TfShip2_CloseGate }
procedure TfShip2.CloseGate;
begin
  if GateSlideTimer <> nil then
  begin
    CancelCallbackTimer(GateSlideTimer);
    GateSlideTimer := nil;
  end;
  GateSlideTimer := ScheduleCallbackTimer(20,20,SlideGateTimer,2);
end;
{ @end $70DA48 }

{ @routine $70DAA0 TfShip2_SlideGateTimer }
procedure TfShip2.SlideGateTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if UserData = 1 then
  begin
    Inc(GateSlideOffset,2);
    if GiScalePixels(20) <= GateSlideOffset then
    begin
      GateSlideOffset := GiScalePixels(20);
      if GateSlideTimer <> nil then
      begin
        CancelCallbackTimer(GateSlideTimer);
        GateSlideTimer := nil;
      end;
    end;
  end
  else
  begin
    Dec(GateSlideOffset,2);
    if GateSlideOffset <= 0 then
    begin
      GateSlideOffset := 0;
      if GateSlideTimer <> nil then
      begin
        CancelCallbackTimer(GateSlideTimer);
        GateSlideTimer := nil;
      end;
    end;
  end;
  with GetByName('GateLeft') do SetPosition(Classes.Point(Self.GateLeftRestLeft - Self.GateSlideOffset,LocalPosition.Y));
  with GetByName('GateRight') do SetPosition(Classes.Point(Self.GateRightRestLeft + Self.GateSlideOffset,LocalPosition.Y));
end;
{ @end $70DAA0 }

{ @routine $70DC0C TfShip2_GateMouseUp }
procedure TfShip2.GateMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  DropSelectedOutside(Sender,KeyState,Point);
end;
{ @end $70DC0C }

{ @routine $70DC40 TfShip2_UseMouseEnter }
procedure TfShip2.UseMouseEnter(Sender: TObjectGI);
begin
  if SelectedHoldKind <> phkEmpty then OpenUsePanel else CloseUsePanel;
end;
{ @end $70DC40 }

{ @routine $70DC70 TfShip2_UseMouseLeave }
procedure TfShip2.UseMouseLeave(Sender: TObjectGI);
begin
  CloseUsePanel;
end;
{ @end $70DC70 }

{ @routine $70DC88 TfShip2_OpenUsePanel }
procedure TfShip2.OpenUsePanel;
begin
  if UseSlideTimer <> nil then
  begin
    CancelCallbackTimer(UseSlideTimer);
    UseSlideTimer := nil;
  end;
  UseSlideTimer := ScheduleCallbackTimer(20,20,SlideUseTimer,1);
  (GetByName('UseAnim') as TgaiGI).RestartPlayback;
end;
{ @end $70DC88 }

{ @routine $70DD14 TfShip2_CloseUsePanel }
procedure TfShip2.CloseUsePanel;
begin
  if UseSlideTimer <> nil then
  begin
    CancelCallbackTimer(UseSlideTimer);
    UseSlideTimer := nil;
  end;
  UseSlideTimer := ScheduleCallbackTimer(20,20,SlideUseTimer,2);
end;
{ @end $70DD14 }

{ @routine $70DD6C TfShip2_SlideUseTimer }
procedure TfShip2.SlideUseTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if UserData = 1 then
  begin
    Inc(UseSlideOffset,2);
    if GiScalePixels(20) <= UseSlideOffset then
    begin
      UseSlideOffset := GiScalePixels(20);
      if UseSlideTimer <> nil then
      begin
        CancelCallbackTimer(UseSlideTimer);
        UseSlideTimer := nil;
      end;
    end;
  end
  else
  begin
    Dec(UseSlideOffset,2);
    if UseSlideOffset <= 0 then
    begin
      UseSlideOffset := 0;
      if UseSlideTimer <> nil then
      begin
        CancelCallbackTimer(UseSlideTimer);
        UseSlideTimer := nil;
      end;
    end;
  end;
  with GetByName('UseLeft') do SetPosition(Classes.Point(Self.UseLeftRestLeft - Self.UseSlideOffset,LocalPosition.Y));
  with GetByName('UseRight') do SetPosition(Classes.Point(Self.UseRightRestLeft + Self.UseSlideOffset,LocalPosition.Y));
end;
{ @end $70DD6C }

{ @routine $70DED4 TfShip2_OpenUseSidePanel }
procedure TfShip2.OpenUseSidePanel;
begin
  if UsePanelSlideTimer <> nil then
  begin
    CancelCallbackTimer(UsePanelSlideTimer);
    UsePanelSlideTimer := nil;
  end;
  if IsHoldNormalShip then
    UsePanelSlideTimer := ScheduleCallbackTimer(20,20,SlideUsePanelTimer,1);
end;
{ @end $70DED4 }

{ @routine $70DF38 TfShip2_CloseUseSidePanel }
procedure TfShip2.CloseUseSidePanel;
begin
  if UsePanelSlideTimer <> nil then
  begin
    CancelCallbackTimer(UsePanelSlideTimer);
    UsePanelSlideTimer := nil;
  end;
  UsePanelSlideTimer := ScheduleCallbackTimer(20,20,SlideUsePanelTimer,2);
end;
{ @end $70DF38 }

{ @routine $70DF90 TfShip2_SlideUsePanelTimer }
procedure TfShip2.SlideUsePanelTimer(Timer: PCallbackTimerGI; UserData: Integer);
var Panel: TPanelGI;
begin
  Panel := GetByName('UsePanel') as TPanelGI;
  if UserData = 1 then
  begin
    Inc(UsePanelSlideOffset,6);
    if UsePanelSlideOffset >= Panel.ClientSize.X then
    begin
      UsePanelSlideOffset := Panel.ClientSize.X;
    if UsePanelSlideTimer <> nil then
    begin
      CancelCallbackTimer(UsePanelSlideTimer);
      UsePanelSlideTimer := nil;
    end;
    end;
  end
  else
  begin
    Dec(UsePanelSlideOffset,6);
    if UsePanelSlideOffset <= 0 then
    begin
      UsePanelSlideOffset := 0;
    if UsePanelSlideTimer <> nil then
    begin
      CancelCallbackTimer(UsePanelSlideTimer);
      UsePanelSlideTimer := nil;
    end;
    end;
  end;
  Panel.SetPosition(Classes.Point(Panel.ClientSize.X - UsePanelSlideOffset,Panel.LocalPosition.Y));
end;
{ @end $70DF90 }

{ @routine $70E0A8 TfShip2_OpenSpecialSlot1 }
procedure TfShip2.OpenSpecialSlot1;
begin
    if SpecialSlot1Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot1Timer);
      SpecialSlot1Timer := nil;
    end;
  SpecialSlot1Timer := ScheduleCallbackTimer(20,20,AnimateSpecialSlot1,1);
  TgaiGI(GetByName('SC_Slot1_Anim')).RestartPlayback;
  (GetByName('SC_Slot1_But') as TGraphButtonGI).UpCallback := SpecialSlot1Clicked;
end;
{ @end $70E0A8 }

{ @routine $70E180 TfShip2_CloseSpecialSlot1 }
procedure TfShip2.CloseSpecialSlot1;
begin
    if SpecialSlot1Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot1Timer);
      SpecialSlot1Timer := nil;
    end;
  SpecialSlot1Timer := ScheduleCallbackTimer(20,20,AnimateSpecialSlot1,2);
  (GetByName('SC_Slot1_But') as TGraphButtonGI).UpCallback := nil;
end;
{ @end $70E180 }

{ @routine $70E220 TfShip2_AnimateSpecialSlot1 }
procedure TfShip2.AnimateSpecialSlot1(Timer: PCallbackTimerGI; UserData: Integer);
var Animation: TgaiGI;
begin
  Animation := GetByName('SC_Slot1_Anim') as TgaiGI;
  if UserData = 1 then
  begin
    Animation.SetSequenceFrame(Min(Animation.SequenceFrame + 1,Animation.SequenceFrameCount - 1));
    if Animation.SequenceFrameCount - 1 = Animation.SequenceFrame then
    begin
      Animation.StopAutoPlayback;
    if SpecialSlot1Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot1Timer);
      SpecialSlot1Timer := nil;
    end;
    end;
  end
  else
  begin
    Animation.SetSequenceFrame(Max(Animation.SequenceFrame - 1,0));
    if Animation.SequenceFrame = 0 then
    begin
      Animation.StopAutoPlayback;
    if SpecialSlot1Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot1Timer);
      SpecialSlot1Timer := nil;
    end;
    end;
  end;
end;
{ @end $70E220 }

{ @routine $70E370 TfShip2_OpenSpecialSlot2 }
procedure TfShip2.OpenSpecialSlot2;
begin
    if SpecialSlot2Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot2Timer);
      SpecialSlot2Timer := nil;
    end;
  SpecialSlot2Timer := ScheduleCallbackTimer(20,20,AnimateSpecialSlot2,1);
  TgaiGI(GetByName('SC_Slot2_Anim')).RestartPlayback;
  (GetByName('SC_Slot2_But') as TGraphButtonGI).UpCallback := SpecialSlot2Clicked;
end;
{ @end $70E370 }

{ @routine $70E448 TfShip2_CloseSpecialSlot2 }
procedure TfShip2.CloseSpecialSlot2;
begin
    if SpecialSlot2Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot2Timer);
      SpecialSlot2Timer := nil;
    end;
  SpecialSlot2Timer := ScheduleCallbackTimer(20,20,AnimateSpecialSlot2,2);
  (GetByName('SC_Slot2_But') as TGraphButtonGI).UpCallback := nil;
end;
{ @end $70E448 }

{ @routine $70E4E8 TfShip2_AnimateSpecialSlot2 }
procedure TfShip2.AnimateSpecialSlot2(Timer: PCallbackTimerGI; UserData: Integer);
var Animation: TgaiGI;
begin
  Animation := GetByName('SC_Slot2_Anim') as TgaiGI;
  if UserData = 1 then
  begin
    Animation.SetSequenceFrame(Min(Animation.SequenceFrame + 1,Animation.SequenceFrameCount - 1));
    if Animation.SequenceFrameCount - 1 = Animation.SequenceFrame then
    begin
      Animation.StopAutoPlayback;
    if SpecialSlot2Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot2Timer);
      SpecialSlot2Timer := nil;
    end;
    end;
  end
  else
  begin
    Animation.SetSequenceFrame(Max(Animation.SequenceFrame - 1,0));
    if Animation.SequenceFrame = 0 then
    begin
      Animation.StopAutoPlayback;
    if SpecialSlot2Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot2Timer);
      SpecialSlot2Timer := nil;
    end;
    end;
  end;
end;
{ @end $70E4E8 }

{ @routine $70E638 TfShip2_OpenSpecialSlot3 }
procedure TfShip2.OpenSpecialSlot3;
begin
    if SpecialSlot3Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot3Timer);
      SpecialSlot3Timer := nil;
    end;
  SpecialSlot3Timer := ScheduleCallbackTimer(20,20,AnimateSpecialSlot3,1);
  TgaiGI(GetByName('SC_Slot3_Anim')).RestartPlayback;
  (GetByName('SC_Slot3_But') as TGraphButtonGI).UpCallback := SpecialSlot3Clicked;
end;
{ @end $70E638 }

{ @routine $70E710 TfShip2_CloseSpecialSlot3 }
procedure TfShip2.CloseSpecialSlot3;
begin
    if SpecialSlot3Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot3Timer);
      SpecialSlot3Timer := nil;
    end;
  SpecialSlot3Timer := ScheduleCallbackTimer(20,20,AnimateSpecialSlot3,2);
  (GetByName('SC_Slot3_But') as TGraphButtonGI).UpCallback := nil;
end;
{ @end $70E710 }

{ @routine $70E7B0 TfShip2_AnimateSpecialSlot3 }
procedure TfShip2.AnimateSpecialSlot3(Timer: PCallbackTimerGI; UserData: Integer);
var Animation: TgaiGI;
begin
  Animation := GetByName('SC_Slot3_Anim') as TgaiGI;
  if UserData = 1 then
  begin
    Animation.SetSequenceFrame(Min(Animation.SequenceFrame + 1,Animation.SequenceFrameCount - 1));
    if Animation.SequenceFrameCount - 1 = Animation.SequenceFrame then
    begin
      Animation.StopAutoPlayback;
    if SpecialSlot3Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot3Timer);
      SpecialSlot3Timer := nil;
    end;
    end;
  end
  else
  begin
    Animation.SetSequenceFrame(Max(Animation.SequenceFrame - 1,0));
    if Animation.SequenceFrame = 0 then
    begin
      Animation.StopAutoPlayback;
    if SpecialSlot3Timer <> nil then
    begin
      CancelCallbackTimer(SpecialSlot3Timer);
      SpecialSlot3Timer := nil;
    end;
    end;
  end;
end;
{ @end $70E7B0 }

{ @routine $70E900 TfShip2_StorageDownClicked }
procedure TfShip2.StorageDownClicked(Sender: TObjectGI);
begin
  if StorageSlideTimer <> nil then
  begin
    CancelCallbackTimer(StorageSlideTimer);
    StorageSlideTimer := nil;
  end;
  StorageSlideTimer := ScheduleCallbackTimer(20,20,SlideStorageTimer,1);
  StorageUpButton.SetActive(True);
  (GetByName('SC_Down') as TGraphButtonGI).SetActive(False);
end;
{ @end $70E900 }

{ @routine $70E9A4 TfShip2_StorageUpClicked }
procedure TfShip2.StorageUpClicked(Sender: TObjectGI);
begin
  if StorageSlideTimer <> nil then
  begin
    CancelCallbackTimer(StorageSlideTimer);
    StorageSlideTimer := nil;
  end;
  StorageSlideTimer := ScheduleCallbackTimer(20,20,SlideStorageTimer,2);
  StorageUpButton.SetActive(False);
  (GetByName('SC_Down') as TGraphButtonGI).SetActive(True);
end;
{ @end $70E9A4 }

{ @routine $70EA48 TfShip2_SlideStorageTimer }
procedure TfShip2.SlideStorageTimer(Timer: PCallbackTimerGI; UserData: Integer);
var Panel: TPanelGI;
begin
  Panel := GetByName('SC_Storage_Panel') as TPanelGI;
  if UserData = 1 then
  begin
    Inc(StorageSlideOffset, StorageImageCount);
    if StoragePanelRestTop - StoragePanelSlideHeight <= StorageSlideOffset then
    begin
      StorageSlideOffset := StoragePanelRestTop - StoragePanelSlideHeight;
    if StorageSlideTimer <> nil then
    begin
      CancelCallbackTimer(StorageSlideTimer);
      StorageSlideTimer := nil;
    end;
    end;
  end
  else
  begin
    Dec(StorageSlideOffset, StorageImageCount);
    if StorageSlideOffset <= 0 then
    begin
      StorageSlideOffset := 0;
    if StorageSlideTimer <> nil then
    begin
      CancelCallbackTimer(StorageSlideTimer);
      StorageSlideTimer := nil;
    end;
    end;
  end;
  Panel.SetPosition(Classes.Point(Panel.LocalPosition.X,StoragePanelSlideHeight + StorageSlideOffset));
  PostMouseMoveMessage;
end;
{ @end $70EA48 }

{ @routine $70EB98 TfShip2_RefreshStorageView }
procedure TfShip2.RefreshStorageView;
var I, Index: Integer; Entry: PStorageEntry;
begin
  for I := 0 to StorageImageCount - 1 do
  begin
    Index := GetPlayer.FindStorageIndexByLocationAndSlot(GetLocalStorageOwner,StorageFirstSlot + I);
    if Index < 0 then
    begin
      with StorageImages[I] do
      begin
        SetImagePath('');
        LeftButtonUpCallback := StorageItemMouseUp;
      end;
    end
    else
    begin
      Entry := GetPlayer.StorageEntries[Index];
      with StorageImages[I] do
      begin
        if Entry.Item is TGoods then SetImagePath('GI,' + Entry.Item.GetBitmapResourceName)
        else
        begin
          SetImagePath('GI,' + GetShopItemIconName(Entry.Item) + 's');
          if Entry.Item = ScriptUseItem then SetImagePath('');
        end;
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
        LeftButtonUpCallback := StorageItemMouseUp;
      end;
    end;
  end;
  with GetByName('Storage_Up') as TGraphButtonGI do
  begin
    SetDisabled(Self.StorageFirstSlot <= 0);
    UpCallback := ScrollStorageUp;
  end;
  with GetByName('Storage_Down') as TGraphButtonGI do
  begin
    SetDisabled(((StorageImageCount - 3 + Self.StorageFirstSlot) div 3) * 3 > Max(0,(GetPlayer.GetStorageSlotExtent(Self.GetLocalStorageOwner) div 3) * 3 - 3));
    UpCallback := ScrollStorageDown;
  end;
end;
{ @end $70EB98 }

{ @routine $70EE6C TfShip2_ScrollStorageUp }
procedure TfShip2.ScrollStorageUp(Sender: TObjectGI);
begin
  StorageFirstSlot := Max(0,StorageFirstSlot - 3);
  RefreshStorageView;
end;
{ @end $70EE6C }

{ @routine $70EEB4 TfShip2_ScrollStorageDown }
procedure TfShip2.ScrollStorageDown(Sender: TObjectGI);
var Limit: Integer;
begin
  StorageFirstSlot := ((StorageFirstSlot + 3) div 3) * 3;
  Limit := Max(0, (GetPlayer.GetStorageSlotExtent(GetLocalStorageOwner) div 3) * 3 - 3);
  if StorageFirstSlot > Limit then StorageFirstSlot := Limit;
  RefreshStorageView;
end;
{ @end $70EEB4 }

{ @routine $70EF44 TfShip2_StorageItemMouseUp }
procedure TfShip2.StorageItemMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Entry: PStorageEntry;
  Count, Slot, Index: Integer;
  Item: TItem;
begin
  if not StorageUpButton.Active then StorageUpButton.SetActive(True);
  if (SelectedHoldKind in [phkEquipment,phkArtefact]) and (SelectedHoldItem <> nil) and
    (SelectedHoldItem.NoDropFlag > 0) and (SelectedHoldOrigin <> 1) then
  begin
    ShowNoDropMessage(SelectedHoldItem.NoDropFlag);
    Exit;
  end;
  Slot := ExtractDigitsToIntW(Sender.ControlName) + StorageFirstSlot;
  Index := GetPlayer.FindStorageIndexByLocationAndSlot(GetLocalStorageOwner,Slot);
  if (Index >= 0) and (SelectedHoldKind = phkEmpty) and (GetPlayer <> PlayerHoldShip) and
    (PStorageEntry(GetPlayer.StorageEntries[Index]).Item.NoDropFlag > 0) then Exit;
  Galaxy.CheckIntegrityChecksum1(510);
  if (SelectedHoldKind <> phkEmpty) and (SelectedHoldOrigin = 0) then RemoveEmptyPlayerHoldSlots;
  if (SelectedHoldKind = phkEquipment) and (SelectedHoldItem is TCountableItem) and
    (TCountableItem(SelectedHoldItem).StackCount >= 1) then
  begin
    Count := TCountableItem(SelectedHoldItem).StackCount;
    if not RemoteHoldVisible and (SelectedHoldOrigin = 0) and (Count > 1) then
      if ShowCountDialog(Self,'GI,' + GetShopItemIconName(SelectedHoldItem) + 's',
        FormatText1(LocalizedText('FormShip.StorageItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemName(SelectedHoldItem))),
        0,Count,Count,0,Count,0,Count) <> 1 then
      begin
        Galaxy.PrimeIntegrityChecksum1(515);
        Exit;
      end;
    if (Count < 1) or (TCountableItem(SelectedHoldItem).StackCount < Count) then
    begin
      Galaxy.PrimeIntegrityChecksum1(515);
      Exit;
    end;
    Item := (SelectedHoldItem as TCountableItem).Split(Count);
    GetPlayer.MergeItemIntoPlayerStorage(Item,GetLocalStorageOwner,Slot);
    if TCountableItem(SelectedHoldItem).StackCount < 1 then
    begin
      SelectedHoldItem.Free;
      SelectedHoldItem := nil;
      SelectedHoldKind := phkEmpty;
      Galaxy.PrimeIntegrityChecksum1(511);
      RefreshShipView;
      UpdateActionCursor(True);
    end;
    ReturnSelectedHoldEntry;
    SoundManager.PlaySound('Sound.SlotPut');
  end
  else if (SelectedHoldKind = phkEquipment) or (SelectedHoldKind = phkArtefact) then
  begin
    if PlayerHoldShip is TRuins then
    begin
      if PlayerHoldShip.NeedsEquipmentType(SelectedHoldItem.ItemType) then
      begin
        ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.RuinMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(SelectedHoldItem.GetDisplayName)),mbgCancel or mbgWarning);
        Galaxy.PrimeIntegrityChecksum1(515);
        Exit;
      end;
    end
    else if (PlayerHoldShip is TTranclucator) and
      ((SelectedHoldItem.ItemType = t_FuelTanks) or (SelectedHoldItem.ItemType = t_Engine)) and PlayerHoldShip.NeedsEquipmentType(SelectedHoldItem.ItemType) then
    begin
      ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.TrancMoveItemInvalid'),TextHighlightColorTag,'<Item>',RemoveTextTagsW(SelectedHoldItem.GetDisplayName)),mbgCancel or mbgWarning);
      Galaxy.PrimeIntegrityChecksum1(515);
      Exit;
    end;
    if (SelectedHoldItem is THull) and (SelectedHoldOrigin = 0) then
    begin
      if Index >= 0 then
      begin
        Entry := GetPlayer.StorageEntries[Index];
        if not (Entry.Item is THull) then
        begin
          Galaxy.PrimeIntegrityChecksum1(510);
          Exit;
        end;
        GetPlayer.StorageEntries.Delete(Index);
        SelectedHoldKind := phkEquipment;
        SelectedHoldOrigin := 1;
        SelectedHoldSlot := Slot;
        SelectedHoldUsesDisplayOrder := False;
        SelectedHoldItem := Entry.Item;
        Entry.LocationOwner := nil;
        Entry.Item := nil;
        Dispose(Entry);
        HullMouseDown(nil,0,Classes.Point(0,0));
      end;
      Galaxy.PrimeIntegrityChecksum1(512);
      Exit;
    end;
    if SelectedHoldItem is TArtefactTranclucator then
      (TObject((SelectedHoldItem as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := nil;
    SoundManager.PlaySound('Sound.SlotPut');
    SelectedHoldKind := phkEmpty;
    GetPlayer.AddItemToPlayerStorage(SelectedHoldItem,GetLocalStorageOwner,Slot);
    Galaxy.PrimeIntegrityChecksum1(513);
    RefreshShipView;
    UpdateActionCursor(True);
  end
  else if SelectedHoldKind = phkGoods then
  begin
    Count := SelectedGoodsQuantity;
    if not RemoteHoldVisible and (SelectedHoldOrigin = 0) and (Count > 1) then
      if ShowCountDialog(Self,'GI,' + GetItemTypeBitmapPath(TItemType(SelectedGoodsIndex)),
        FormatText1(LocalizedText('FormShip.StorageItem'),DialogHighlightColorTag,'<Name>',LowerCaseWideString(GetStackableItemTypeName(TItemType(SelectedGoodsIndex)))),
        0,SelectedGoodsQuantity,SelectedGoodsQuantity,0,Count,0,Count) <> 1 then
      begin
        Galaxy.PrimeIntegrityChecksum1(515);
        Exit;
      end;
    if (Count < 1) or (Count > SelectedGoodsQuantity) then
    begin
      Galaxy.PrimeIntegrityChecksum1(515);
      Exit;
    end;
    SoundManager.PlaySound('Sound.SlotPut');
    GetPlayer.AddGoodsToPlayerStorage(SelectedGoodsIndex,Count,Round(Count / SelectedGoodsQuantity * SelectedGoodsCost),GetLocalStorageOwner,Slot);
    Dec(SelectedGoodsCost,Round(Count / SelectedGoodsQuantity * SelectedGoodsCost));
    Dec(SelectedGoodsQuantity,Count);
    if SelectedGoodsQuantity < 1 then
    begin
      SelectedHoldKind := phkEmpty;
      Galaxy.PrimeIntegrityChecksum1(513);
      RefreshShipView;
      UpdateActionCursor(True);
    end;
    ReturnSelectedHoldEntry;
  end
  else if (Index >= 0) and (SelectedHoldKind = phkEmpty) then
  begin
    Entry := GetPlayer.StorageEntries[Index];
    GetPlayer.StorageEntries.Delete(Index);
    if Entry.Item is TGoods then
    begin
      SelectedHoldKind := phkGoods;
      SelectedHoldOrigin := 1;
      SelectedHoldSlot := Slot;
      SelectedHoldUsesDisplayOrder := False;
      SelectedGoodsIndex := Byte(Entry.Item.ItemType);
      SelectedGoodsQuantity := (Entry.Item as TGoods).Quantity;
      SelectedGoodsCost := (Entry.Item as TGoods).Cost;
      Entry.Item.Free;
    end
    else if Entry.Item is TArtefact then
    begin
      SelectedHoldKind := phkArtefact;
      SelectedHoldOrigin := 1;
      SelectedHoldSlot := Slot;
      SelectedHoldUsesDisplayOrder := False;
      SelectedHoldItem := Entry.Item;
    end
    else
    begin
      SelectedHoldKind := phkEquipment;
      SelectedHoldOrigin := 1;
      SelectedHoldSlot := Slot;
      SelectedHoldUsesDisplayOrder := False;
      SelectedHoldItem := Entry.Item;
    end;
    Entry.LocationOwner := nil;
    Entry.Item := nil;
    Dispose(Entry);
    Galaxy.PrimeIntegrityChecksum1(514);
    UpdateActionCursor(True);
    PlayerHoldShip.ScriptItemsAct(satOnReEnteringForm,nil,nil,0);
    RefreshShipView;
    SoundManager.PlaySound('Sound.SlotGet');
    Exit;
  end
  else
  begin
    Galaxy.PrimeIntegrityChecksum1(515);
    Exit;
  end;
  GetPlayer.CloseVacantStorageSlot(GetLocalStorageOwner,Slot + 1);
  Galaxy.CheckIntegrityChecksum1(515);
  if not RemoteHoldVisible then
  begin
    ShipStateChanged := True;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $70EF44 }

{ @routine $70FBC8 TfShip2_CreateShipInfoImage }
function TfShip2.CreateShipInfoImage(Sender: TLabelGI; Item: PFontObjectEC): TObjectGI;
begin
  Result := TImageGI.Create(Sender);
  with Result as TImageGI do
  begin
    SetImagePath('GI,Bm.FormShip2.' + GiResourceSuffix + 'AI_' + IntToStr(Cardinal(Item.ObjectId)));
    SetImageKindX(ikxLeft);
  end;
end;
{ @end $70FBC8 }

{ @routine $7100F4 TfShip2_BuildAdditionalInfoPanel }
procedure TfShip2.BuildAdditionalInfoPanel;
var
  Panel: TPanelScrollBarGI;
  Height: Integer;
  I, Kind, Turn: Integer;
  ProgramIndex: TProgramIndex;
  Name, SeriesName, TypeName, CountText, Text, ChargesText, Description, Title: WideString;
  ColorIndex: Byte;
  Info: PCustomShipInfo;
  Block: TBlockParEC;

  // @nested $70FCD4 AddLine
  procedure AddLine(Icon: Integer; Text, Hint: WideString; Data: Integer); // @addr $70FCD4 @calls "0x7102B1,0x71040A,0x7104EE,0x7105C2,0x710722,0x7107BC,0x710ABD,0x710B4B,0x710E85" Nested helper captures the panel, accumulated height and Self.
  var
    LabelControl: TLabelGI;
  begin
    LabelControl := TLabelGI.Create(Panel);
    LabelControl.SetFontName(SmallFontName);
    LabelControl.SetPosition(Classes.Point(0,Height));
    LabelControl.SetSize(Classes.Point(Panel.ClientSize.X,1));
    LabelControl.SetTextAlignX(taxLeft);
    LabelControl.SetTextAlignY(tayAuto);
    LabelControl.SetWordWrapEnabled(True);
    if GiResourceVariant = 1 then
      LabelControl.SetText('<Object=' + IntToStr(Icon) + ',' + IntToStr(21) + ',' + IntToStr(17) + ',0>' + ReplaceAllWideString(Text,'<br>',#13#10))
    else
      LabelControl.SetText('<Object=' + IntToStr(Icon) + ',' + IntToStr(25) + ',' + IntToStr(20) + ',0>' + ReplaceAllWideString(Text,'<br>',#13#10));
    LabelControl.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    LabelControl.SetTextAlignY(tayCenterEx);
    LabelControl.SetPositionModeW(True);
    LabelControl.CreateEmbeddedControl := CreateShipInfoImage;
    LabelControl.MouseEnterCallback := ShowShipPropertyInfo;
    LabelControl.MouseLeaveCallback := HideShipPropertyInfo;
    LabelControl.UserValue := -1;
    LabelControl.UserIndex := Icon;
    LabelControl.UserData := Data;
    LabelControl.HelpText := Hint;
    Inc(Height,LabelControl.ClientSize.Y);
    Panel.VerticalScrollBar.SetSmallChange(LabelControl.GetLineHeight);
  end;

  // @nested $710030 GetShipInfoColor
  function GetShipInfoColor(ColorIndex: Byte): WideString; // @addr $710030 @calls "0x710A3A" Nested in BuildAdditionalInfoPanel; does not access its parent frame.
  begin
    Result := '';
    case ColorIndex of
      0: Result := RedColorTag;
      1: Result := AzureColorTag;
      2: Result := GreenColorTag;
    end;
  end;

begin
  Panel := GetByName('PanelAddInfo') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  Panel.SetScrollOffset(Classes.Point(0,0));
  Panel.SetDragScrollingEnabled(True);
  Height := 0;
  for I := 1 to 24 do
    if PlayerHoldShip.IsHealthEffectActive(I) then
    begin
      if I < 13 then Kind := 1 else Kind := 2;
      Name := CaptainHealthDefinitions[I].Name + '~' + CaptainHealthDefinitions[I].Text;
      if PlayerHoldShip.CountActiveArtefacts(t_ArtBio) > 0 then
      begin
        Turn := PlayerHoldShip.CaptainHealth[I].ExpireTurn;
        if Kind = 1 then
          Name := Name + #13#10 + FormatText1(LocalizedText('Illness.Illness.EndDate'),TextHighlightColorTag,'<Date>',Galaxy.FormatTurnDate(Turn))
        else
          Name := Name + #13#10 + FormatText1(LocalizedText('Illness.Stimulant.EndDate'),TextHighlightColorTag,'<Date>',Galaxy.FormatTurnDate(Turn));
      end;
      AddLine(Kind,CaptainHealthDefinitions[I].Name,Name,0);
    end;
  for I := 1 to 1 do
    if PlayerHoldShip.RadiationHealth[I].Progress > 0 then
    begin
      Name := RadiationHealthDefinitions[I].Name + '~' + RadiationHealthDefinitions[I].Text;
      if PlayerHoldShip.CountActiveArtefacts(t_ArtBio) > 0 then
      begin
        Turn := Round(100 - 100 * PlayerHoldShip.RadiationHealth[1].Progress);
        Name := Name + #13#10 + FormatText1(LocalizedText('Illness.ExtraIllness.' + IntToStr(I) + '.TextEx'),TextHighlightColorTag,'<Percent>',IntToStr(Turn) + '%');
      end;
      AddLine(1,RadiationHealthDefinitions[I].Name,Name,0);
    end;
  if GetPlayer = PlayerHoldShip then
  begin
    if GetPlayer.MedicalPolicyTicks > 0 then
      AddLine(0,LocalizedText('ShipInfo.AddInfo.MedPolicy.Name'),
        LocalizedText('ShipInfo.AddInfo.MedPolicy.Name') + '~' +
        FormatText1(LocalizedText('ShipInfo.AddInfo.MedPolicy.Text'),TextHighlightColorTag,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + GetPlayer.MedicalPolicyTicks)),0);
    if GetPlayer.DebtAmount > 0 then
    begin
      Name := LocalizedText('ShipInfo.AddInfo.DebtInfo.Name');
      AddLine(0,Name,Name + '~' +
        FormatText2(LocalizedText('ShipInfo.AddInfo.DebtInfo.Text'),TextHighlightColorTag,'<Money>',IntToStr(GetPlayer.DebtAmount),'<Date>',Galaxy.FormatTurnDate(GetPlayer.DebtDueTurn)),0);
    end;
    if GetPlayer.DepositAmount > 0 then
    begin
      Name := LocalizedText('ShipInfo.AddInfo.DepositInfo.Name');
      Text := LocalizedText('ShipInfo.AddInfo.DepositInfo.Text');
      ReplaceTextToken(Text,'<Date>',Galaxy.FormatTurnDate(GetPlayer.DepositStartTurn),TextHighlightColorTag);
      ReplaceTextToken(Text,'<Money>',IntToStr(GetPlayer.DepositAmount),TextHighlightColorTag);
      ReplaceTextToken(Text,'<Percent>',FloatToStrF(GetPlayer.DepositInterestRate,ffFixed,1,1),TextHighlightColorTag);
      ReplaceTextToken(Text,'<Sum>',IntToStr(GetPlayer.ComputeDepositAccruedValue),TextHighlightColorTag);
      AddLine(0,Name,Name + '~' + Text,0);
    end;
    if GetPlayer.PirateLicenseTicks > 0 then
    begin
      Name := LocalizedText('ShipInfo.AddInfo.PirateLicenseInfo.Name');
      Text := LocalizedText('ShipInfo.AddInfo.PirateLicenseInfo.Text');
      ReplaceTextToken(Text,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + GetPlayer.PirateLicenseTicks),TextHighlightColorTag);
      AddLine(0,Name,Name + '~' + Text,0);
    end;
    if GetPlayer.ChameleonActive or GetPlayer.HasPlayerChameleonCharges then
    begin
      Name := LocalizedText('ShipInfo.AddInfo.Chameleon.Name');
      Text := '';
      if GetPlayer.ChameleonActive then
      begin
        SeriesName := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[Ord(GetPlayer.ChameleonSeries)] + '.0');
        TypeName := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[Ord(GetPlayer.ChameleonSeries)] + '.' + IntToStr(GetPlayer.ChameleonVisualType));
        CountText := IntToStr(GetPlayer.ChameleonDisplayCount);
        Text := FormatText3(LocalizedText('ShipInfo.AddInfo.Chameleon.Text'),TextHighlightColorTag,'<Series>',SeriesName,'<Type>',TypeName,'<Count>',CountText);
      end;
      if GetPlayer.HasPlayerChameleonCharges then
      begin
        if Length(Text) > 0 then Text := Text + #13#10;
        Text := Text + LocalizedText('ShipInfo.AddInfo.Chameleon.Charge');
        ChargesText := '';
        for ColorIndex := 0 to 2 do
          if GetPlayer.ChameleonCharges[ColorIndex] > 0 then
          begin
            SeriesName := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[ColorIndex] + '.0');
            CountText := FormatText1(LocalizedText('ShipInfo.AddInfo.Chameleon.Count'),TextHighlightColorTag,'<Count>',IntToStr(GetPlayer.ChameleonCharges[ColorIndex]));
            if Length(ChargesText) > 0 then ChargesText := ChargesText + #13#10;
            ChargesText := ChargesText + WrapTextInColor(SeriesName,GetShipInfoColor(ColorIndex)) + ' - ' + CountText;
          end;
        Text := Text + #13#10 + ChargesText;
      end;
      AddLine(0,Name,Name + '~' + Text,0);
    end;
    for ProgramIndex := Low(ProgramNames) to High(ProgramNames) do
      if GetPlayer.ProgramCounts[ProgramIndex] > 0 then
        AddLine(3,GetPlayer.GetProgramName(ProgramIndex),GetPlayer.GetProgramName(ProgramIndex) + '~' + GetPlayer.GetProgramInfoText(ProgramIndex),0);
  end;
  for I := 0 to PlayerHoldShip.CustomShipInfos.Count - 1 do
  begin
    Info := PlayerHoldShip.CustomShipInfos[I];
    if not Info.DeleteQueued then
    begin
      Block := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').GetBlock(Info.TypeName);
      Description := Info.Description;
      if Description = WideString('') then
        Description := LocalizedColorText('ShipInfo.AddInfo.CustomInfos.' + Info.TypeName + '.Description');
      if Description <> WideString('NoShow') then
      begin
        ReplaceTextToken(Description,'<Data1>',IntToStr(Info.Data[1]),TextHighlightColorTag);
        ReplaceTextToken(Description,'<Data2>',IntToStr(Info.Data[2]),TextHighlightColorTag);
        ReplaceTextToken(Description,'<Data3>',IntToStr(Info.Data[3]),TextHighlightColorTag);
        ReplaceTextToken(Description,'<TextData1>',Info.TextData1,TextHighlightColorTag);
        ReplaceTextToken(Description,'<TextData2>',Info.TextData2,TextHighlightColorTag);
        ReplaceTextToken(Description,'<TextData3>',Info.TextData3,TextHighlightColorTag);
        Title := Block.GetParam('Name');
        ReplaceTextToken(Title,'<Data1>',IntToStr(Info.Data[1]),TextHighlightColorTag);
        ReplaceTextToken(Title,'<Data2>',IntToStr(Info.Data[2]),TextHighlightColorTag);
        ReplaceTextToken(Title,'<Data3>',IntToStr(Info.Data[3]),TextHighlightColorTag);
        ReplaceTextToken(Title,'<TextData1>',Info.TextData1,TextHighlightColorTag);
        ReplaceTextToken(Title,'<TextData2>',Info.TextData2,TextHighlightColorTag);
        ReplaceTextToken(Title,'<TextData3>',Info.TextData3,TextHighlightColorTag);
        AddLine(StrToInt(Block.GetParam('Icon')),Title,Title + '~' + Description,Integer(Info));
      end;
    end;
  end;
  Panel.UpdateScrollRanges;
  Panel.VerticalScrollBar.SetActive(Panel.ClientSize.Y < Height);
  if Panel.VerticalScrollBar.Active then
  begin
    Panel.VerticalScrollBar.SetLargeChange(Panel.ClientSize.Y);
    Panel.VerticalScrollBar.SetPageSize(Panel.ClientSize.Y);
  end;
end;
{ @end $7100F4 }

{ @routine $711740 TfShip2_HideSender }
procedure TfShip2.HideSender(Sender: TObjectGI);
begin
  Sender.SetActive(False);
end;
{ @end $711740 }

{ @routine $71175C TfShip2_ProcessCallbackTimers }
procedure TfShip2.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $71175C }

{ @routine $71179C TfShip2_ProcessWindowMessage }
procedure TfShip2.ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer);
begin
  if (Message = WM_LBUTTONDOWN) or (Message = WM_RBUTTONDOWN) or (Message = WM_MBUTTONDOWN) or (Message = WM_KEYDOWN) then
    if StopScriptVideo then Exit;
  inherited ProcessWindowMessage(Message, WParam, LParam);
end;
{ @end $71179C }

{ @routine $7117F4 TfShip2_SelectMusic }
procedure TfShip2.SelectMusic;
begin
  if GetPlayer = nil then MusicManager.PlayCategory('Base')
  else if GetPlayer.IsOnPlanet then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
    begin
      if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
        MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.PiratePlanetMain');
    end
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
  end
  else if GetPlayer.IsDockedToShip then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else if GetPlayer.DockedTo.TypeId in [Ord(rstPirateBase),Ord(rstDominion)] then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end
  else if not PreserveSpaceMusic and PlayerHoldShip.InNormalSpace then
  begin
    if MusicInSpaceEnabled then
    begin
      if (GetPlayer = PlayerHoldShip) and (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0,100) < 20) then
      begin
        StarMapScreen.BattleMusicSelected := True;
        MusicManager.PlayCategory('Destroyer');
      end
      else
      begin
        StarMapScreen.BattleMusicSelected := False;
        MusicManager.PlayCategory('StarMap');
      end;
    end
    else MusicManager.RequestFadeOut;
  end;
end;
{ @end $7117F4 }

{ @routine $711B4C TfShip2_IsHoldNormalShip }
function TfShip2.IsHoldNormalShip: Boolean;
begin
  Result := PlayerHoldShip is TNormalShip;
end;
{ @end $711B4C }

{ @routine $711B70 TfShip2_CanUsePlayerExperience }
function TfShip2.CanUsePlayerExperience: Boolean;
begin
  Result := True;
  if not ((PlayerHoldShip is TRuins) and (PlayerHoldShip as TRuins).ModernizationSponsor) and
    not ((PlayerHoldShip is TTranclucator) and ((PlayerHoldShip as TTranclucator).OwnerShip = GetPlayer)) then Result := False;
end;
{ @end $711B70 }

{ @routine $711BEC TfShip2_ToggleRemoteHoldClicked }
procedure TfShip2.ToggleRemoteHoldClicked(Sender: TObjectGI);
begin
  RemoteHoldMode := not RemoteHoldMode;
  with GetByName('PanelRight') do
  begin
    SetPosition(Classes.Point(Self.RightPanelRestLeft,LocalPosition.Y));
    SetActive(not Self.RemoteHoldMode);
  end;
  with GetByName('PanelRH') do
  begin
    SetPosition(Classes.Point(Self.RightPanelRestLeft,LocalPosition.Y));
    SetActive(Self.RemoteHoldMode);
  end;
  with GetByName('PanelLH') do SetActive(not Self.RemoteHoldMode);
  with GetByName('PanelDS') do SetActive(Self.RemoteHoldMode);
  with GetByName('PanelDestr') do SetActive(not Self.RemoteHoldMode and (GetPlayer = PlayerHoldShip) and (GetPlayer.GetHull.CapitalShip = 1));
  MainPanel.ShowControlHelp(nil,False);
end;
{ @end $711BEC }

{ @routine $711DAC TfShip2_RemoteHoldUpPressed }
procedure TfShip2.RemoteHoldUpPressed(Sender: TObjectGI);
begin
  RemoteHoldFirstOrder := Max(0, RemoteHoldFirstOrder - 5);
  RefreshShipView;
  if HoldScrollTimer <> nil then
  begin
    CancelCallbackTimer(HoldScrollTimer);
    HoldScrollTimer := nil;
  end;
  HoldScrollTimer := ScheduleCallbackTimer(500,50,ScrollRemoteHoldTimer);
end;
{ @end $711DAC }

{ @routine $711E44 TfShip2_RemoteHoldUpReleased }
procedure TfShip2.RemoteHoldUpReleased(Sender: TObjectGI);
begin
  if HoldScrollTimer <> nil then
  begin
    CancelCallbackTimer(HoldScrollTimer);
    HoldScrollTimer := nil;
  end;
end;
{ @end $711E44 }

{ @routine $711E7C TfShip2_RemoteHoldDownPressed }
procedure TfShip2.RemoteHoldDownPressed(Sender: TObjectGI);
begin
  RemoteHoldFirstOrder := Min(GetRemoteHoldScrollLimit, RemoteHoldFirstOrder + 5);
  RefreshShipView;
  if HoldScrollTimer <> nil then
  begin
    CancelCallbackTimer(HoldScrollTimer);
    HoldScrollTimer := nil;
  end;
  HoldScrollTimer := ScheduleCallbackTimer(500,50,ScrollRemoteHoldTimer,1);
end;
{ @end $711E7C }

{ @routine $711F24 TfShip2_RemoteHoldDownReleased }
procedure TfShip2.RemoteHoldDownReleased(Sender: TObjectGI);
begin
  if HoldScrollTimer <> nil then
  begin
    CancelCallbackTimer(HoldScrollTimer);
    HoldScrollTimer := nil;
  end;
end;
{ @end $711F24 }

{ @routine $711F5C TfShip2_ScrollRemoteHoldTimer }
procedure TfShip2.ScrollRemoteHoldTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if UserData = 0 then Dec(RemoteHoldFirstOrder,5) else Inc(RemoteHoldFirstOrder,5);
  if RemoteHoldFirstOrder <= 0 then
  begin
    RemoteHoldFirstOrder := 0;
    if HoldScrollTimer <> nil then
    begin
      CancelCallbackTimer(HoldScrollTimer);
      HoldScrollTimer := nil;
    end;
  end
  else if RemoteHoldFirstOrder >= GetRemoteHoldScrollLimit then
  begin
    RemoteHoldFirstOrder := GetRemoteHoldScrollLimit;
    if HoldScrollTimer <> nil then
    begin
      CancelCallbackTimer(HoldScrollTimer);
      HoldScrollTimer := nil;
    end;
  end;
  RefreshShipView;
end;
{ @end $711F5C }

{ @routine $712020 TfShip2_GetRemoteHoldScrollLimit }
function TfShip2.GetRemoteHoldScrollLimit: Integer;
var Entry: TPlayerHoldUnit; I: Integer;
begin
  Result := 0;
  for I := 0 to PlayerHoldEntries.Count - 1 do
  begin
    Entry := PlayerHoldEntries[I];
    if Entry.Kind <> phkEmpty then Result := Max(Result,Entry.DisplayOrder);
  end;
  Result := Max(0, (Result div 5 + 1) * 5 - 50);
end;
{ @end $712020 }

{ @routine $7120C8 TfShip2_SortRemoteHoldClicked }
procedure TfShip2.SortRemoteHoldClicked(Sender: TObjectGI);
begin
  SortPlayerHoldEntries(TPlayerHoldSort(Sender.UserValue));
  RefreshShipView;
end;
{ @end $7120C8 }

{ @routine $7120F0 RunShipEquipment }
function RunShipEquipment(ParentLoop: TMessageLoopGI): Boolean;
var
  CursorAlignment: array[0..2] of Byte; // Native three unused bytes between the Boolean result and packed cursor record.
  State: TCursorStateGI;
begin
  ParentLoop.RootUiObject.OnModalSuspend;
  ParentLoop.CaptureCursorState(@State);
  ParentLoop.SetCursorActive(False);
  ParentLoop.DrawQueuedUpdateRects;
  ShipScreen.ParentLoop := ParentLoop;
  ParentLoop.ChildLoop := ShipScreen;
  Result := ShipScreen.Run = 1;
  ShipScreen.ParentLoop := nil;
  ParentLoop.ChildLoop := nil;
  ParentLoop.InvalidateViewport;
  ParentLoop.RestoreCursorState(@State);
  ParentLoop.UpdateCursorPosition;
  ParentLoop.RootUiObject.OnModalResume;
  PostMouseMoveMessage;
end;
{ @end $7120F0 }

{ @routine $7121D0 TfShip2_StorageToShipClicked }
procedure TfShip2.StorageToShipClicked(Sender: TObjectGI);
begin
  if not PlayerHoldShip.InHyperspace and (QueuedArcadeBattles.Count <= 0) and ((GetPlayer = PlayerHoldShip) or (PlayerHoldShip is TTranclucator)) and (GetPlayer.RuinsMode <= 0) then
  begin
    Galaxy.CheckIntegrityChecksum1(515);
    if PlayerHoldShip.RetrieveStoredItems(GetLocalStorageOwner) then
    begin
      Galaxy.PrimeIntegrityChecksum1(516);
      ShipStateChanged := True;
      ReopenRequested := True;
      PlayTransitionSounds := False;
      CloseClicked(nil);
    end;
  end;
end;
{ @end $7121D0 }

{ @routine $712294 TfShip2_SellStorageClicked }
procedure TfShip2.SellStorageClicked(Sender: TObjectGI);
var
  Text: WideString;
  Value, I: Integer;
  Item: TItem;
  Location: TObject;
  Entry: PStorageEntry;
begin
  Text := LocalizedColorText('FormShip.SellAllFromStorage');
  Value := 0;
  if QueuedArcadeBattles.Count <= 0 then
  begin
    if GetPlayer.CurrentPlanet <> nil then Location := GetPlayer.CurrentPlanet
    else Location := GetPlayer.DockedTo;
    if Location <> nil then
    begin
      for I := 0 to GetPlayer.StorageEntries.Count - 1 do
      begin
        Entry := GetPlayer.StorageEntries[I];
        if (Entry = nil) or (Entry.LocationOwner <> Location) then Continue;
        Item := Entry.Item;
        if Item <> nil then
          if (Item.NoDropFlag <= 0) and ((Item.ScriptItem = nil) or TScriptItem(Item.ScriptItem).CanSell) then
            if Item is TGoods then Inc(Value,TGoods(Item).Quantity * GetPlayer.ShopGoodsSellPrice(Byte(Item.ItemType),Location))
            else if Item is TEquipment then Inc(Value,Item.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading)));
      end;
      if Value > 0 then
      begin
        ReplaceTextToken(Text,'<Cost>',IntToStr(Value),TextHighlightColorTag);
        if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) <> 2 then SellAllItems(1);
      end;
    end;
  end;
end;
{ @end $712294 }

{ @routine $7124F8 TfShip2_ShipToStorageClicked }
procedure TfShip2.ShipToStorageClicked(Sender: TObjectGI);
begin
  if ((GetPlayer = PlayerHoldShip) or (PlayerHoldShip is TTranclucator)) and (GetPlayer.RuinsMode <= 0) and not GetPlayer.InHyperspace and (QueuedArcadeBattles.Count <= 0) then
  begin
    Galaxy.CheckIntegrityChecksum1(519);
    if PlayerHoldShip.StoreLooseInventoryAt(GetLocalStorageOwner) then
    begin
      Galaxy.PrimeIntegrityChecksum1(520);
      ShipStateChanged := True;
      ReopenRequested := True;
      PlayTransitionSounds := False;
      CloseClicked(nil);
    end;
  end;
end;
{ @end $7124F8 }

{ @routine $7125B8 TfShip2_SortStorageByTypeClicked }
procedure TfShip2.SortStorageByTypeClicked(Sender: TObjectGI);
begin
  SortStorage(phsType);
  RefreshStorageView;
end;
{ @end $7125B8 }

{ @routine $7125DC TfShip2_SortStorageBySizeClicked }
procedure TfShip2.SortStorageBySizeClicked(Sender: TObjectGI);
begin
  SortStorage(phsSize);
  RefreshStorageView;
end;
{ @end $7125DC }

{ @routine $712604 TfShip2_SortStorageByPriceClicked }
procedure TfShip2.SortStorageByPriceClicked(Sender: TObjectGI);
begin
  SortStorage(phsPrice);
  RefreshStorageView;
end;
{ @end $712604 }

{ @routine $71262C TfShip2_LoadHoldRocketsClicked }
procedure TfShip2.LoadHoldRocketsClicked(Sender: TObjectGI);
begin
  if GetPlayer.RuinsMode <= 0 then LoadRockets(False);
end;
{ @end $71262C }

{ @routine $712654 TfShip2_SellHoldClicked }
procedure TfShip2.SellHoldClicked(Sender: TObjectGI);
var
  Text: WideString;
  Value, I: Integer;
  Good: Byte;
  Item: TEquipment;
  Location: TObject;
begin
  if ((GetPlayer = PlayerHoldShip) or (PlayerHoldShip is TTranclucator)) and (GetPlayer.RuinsMode <= 0) then
    if GetPlayer.IsDocked and ((GetPlayer.CurrentPlanet = nil) or (GetPlayer.CurrentPlanet.OwnerId <> oiUninhabited)) then
    begin
      Text := LocalizedColorText('FormShip.SellAllFromHold');
      Value := 0;
      if GetPlayer.CurrentPlanet <> nil then Location := GetPlayer.CurrentPlanet
      else Location := GetPlayer.DockedTo;
      for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
        Inc(Value,PlayerHoldShip.CargoGoods[Good].Count * GetPlayer.ShopGoodsSellPrice(Good,Location));
      for I := 1 to PlayerHoldShip.Inventory.Count - 1 do
      begin
        Item := PlayerHoldShip.Inventory[I];
        if (Item.EquippedFlag = 0) and (Item.NoDropFlag <= 0) and (Item.ScriptItem = nil) and GetPlayer.CanAccessStoredItem(Item) and
          (Item.NoDropFlag <= 0) and ((Item.ScriptItem = nil) or TScriptItem(Item.ScriptItem).CanSell) and GetPlayer.CanAccessStoredItem(Item) then
          Inc(Value,Item.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading)));
      end;
      for I := 0 to PlayerHoldShip.Artefacts.Count - 1 do
      begin
        Item := PlayerHoldShip.Artefacts[I];
        if (Item.EquippedFlag = 0) and (Item.NoDropFlag <= 0) and
          ((Item.ScriptItem = nil) or TScriptItem(Item.ScriptItem).CanSell) and GetPlayer.CanAccessStoredItem(Item) then
          Inc(Value,Item.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading)));
      end;
      if Value > 0 then
      begin
        ReplaceTextToken(Text,'<Cost>',IntToStr(Value),TextHighlightColorTag);
        if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) <> 2 then SellAllItems(0);
      end;
    end;
end;
{ @end $712654 }

{ @routine $71298C TfShip2_LoadEquippedRocketsClicked }
procedure TfShip2.LoadEquippedRocketsClicked(Sender: TObjectGI);
begin
  if GetPlayer.RuinsMode <= 0 then LoadRockets(True);
end;
{ @end $71298C }

{ @routine $712A10 CompareStoredItems }
function CompareStoredItems(Left, Right: PStorageEntry; Sort: TPlayerHoldSort): Integer;
var LeftValue, RightValue: Integer; LeftType, RightType: Byte; LeftClass, RightClass: Integer;
  LeftName, RightName: WideString; NameComparison: Integer;

  // @nested $7129B4 Classify
  function Classify(ItemType: Byte): Integer; // @addr $7129B4 @calls "0x712A81,0x712A8E" Nested helper; does not read the parent frame.
  begin
    Result := 0;
    if ItemType in [Ord(t_Food)..Ord(t_Narcotics)] then Result := 1
    else if ItemType in [Ord(t_Artefact)..Ord(t_ArtFastRacks)] then Result := 3
    else if ItemType in [Ord(t_Hull)..Ord(t_CustomWeapon)] then Result := 2
    else if ItemType in [Ord(t_Protoplasm)..Ord(t_UselessCountableItem)] then Result := 4;
  end;

begin
  Result := 0;
  if Left.Item = nil then begin Result := -1; Exit end;
  if Right.Item = nil then begin Result := 1; Exit end;
  LeftType := Byte(Left.Item.ItemType);
  RightType := Byte(Right.Item.ItemType);
  LeftClass := Classify(LeftType);
  RightClass := Classify(RightType);
  if Sort = phsType then
  begin
    if LeftClass < RightClass then begin Result := -1; Exit end;
    if LeftClass > RightClass then begin Result := 1; Exit end;
    if Integer(LeftType) < Integer(RightType) then begin Result := -1; Exit end;
    if Integer(LeftType) > Integer(RightType) then begin Result := 1; Exit end;
    if (LeftClass = 4) and (RightClass = 4) and (Left.Item.ItemType = t_MicroModule) and (Right.Item.ItemType = t_MicroModule) then
    begin
      LeftValue := GetMicroModulePriorityColorTier((Left.Item as TMicroModule).MicroModuleIndex - 1);
      RightValue := GetMicroModulePriorityColorTier((Right.Item as TMicroModule).MicroModuleIndex - 1);
      if LeftValue < RightValue then begin Result := -1; Exit end;
      if LeftValue > RightValue then begin Result := 1; Exit end;
    end;
    LeftName := Left.Item.GetDisplayName;
    RightName := Right.Item.GetDisplayName;
    NameComparison := CompareWideChars(PWideChar(LeftName), PWideChar(RightName));
    if NameComparison <> 0 then begin Result := NameComparison; Exit end;
  end;
  if Integer(Sort) <= Integer(phsSize) then
  begin
    if LeftClass = 1 then LeftValue := TGoods(Left.Item).Quantity else LeftValue := Left.Item.Weight;
    if RightClass = 1 then RightValue := TGoods(Right.Item).Quantity else RightValue := Right.Item.Weight;
    if LeftValue < RightValue then begin Result := -1; Exit end;
    if LeftValue > RightValue then begin Result := 1; Exit end;
  end;
  LeftValue := Left.Item.Cost;
  RightValue := Right.Item.Cost;
  if LeftValue < RightValue then begin Result := -1; Exit end;
  if LeftValue > RightValue then begin Result := 1; Exit end;
end;
{ @end $712A10 }

{ @routine $712CAC TfShip2_SortStorage }
procedure TfShip2.SortStorage(Sort: TPlayerHoldSort);
var I, J, Count: Integer; Entry: PStorageEntry; LeftIndex, RightIndex: Integer;
begin
  Galaxy.CheckIntegrityChecksum1(515);
  Count := GetPlayer.StorageEntries.Count;
  I := 0;
  J := 0;
  while I < Count do
  begin
    Entry := GetPlayer.StorageEntries[I];
    if GetLocalStorageOwner = Entry.LocationOwner then
    begin
      if Entry.Item = nil then
      begin
        GetPlayer.StorageEntries.Delete(I);
        Dispose(Entry);
        Dec(Count);
        Continue;
      end;
      Entry.SlotIndex := J;
      Inc(J);
    end;
    Inc(I);
  end;
  Count := GetPlayer.GetStorageSlotExtent(GetLocalStorageOwner);
  for I := 0 to Count - 2 do
    for J := I + 1 to Count - 1 do
    begin
      LeftIndex := GetPlayer.FindStorageIndexByLocationAndSlot(GetLocalStorageOwner,I);
      RightIndex := GetPlayer.FindStorageIndexByLocationAndSlot(GetLocalStorageOwner,J);
      if (LeftIndex >= 0) and (RightIndex >= 0) then
        if CompareStoredItems(GetPlayer.StorageEntries[LeftIndex],GetPlayer.StorageEntries[RightIndex],Sort) > 0 then
        begin
          Entry := GetPlayer.StorageEntries[LeftIndex];
          Entry.SlotIndex := J;
          Entry := GetPlayer.StorageEntries[RightIndex];
          Entry.SlotIndex := I;
        end;
    end;
  Galaxy.PrimeIntegrityChecksum1(516);
end;
{ @end $712CAC }

{ @routine $712E7C TfShip2_RefreshLoadEquippedRocketsButton }
procedure TfShip2.RefreshLoadEquippedRocketsButton;
var
  I: Integer;
  Button: TGraphButtonGI;
begin
  Button := GetByName('LoadRocketsInSlots') as TGraphButtonGI;
  Button.SetActive(False);
  if ((PlayerHoldShip.CurrentPlanet <> nil) or (PlayerHoldShip.DockedTo <> nil) or (PlayerHoldShip is TRuins)) and
    ((PlayerHoldShip.CurrentPlanet = nil) or (PlayerHoldShip.CurrentPlanet.OwnerId <> oiUninhabited)) and
    ((GetPlayer <> PlayerHoldShip) or (GetPlayer.RuinsMode <= 0)) then
    for I := 1 to 5 do
      if PlayerHoldShip.Weapons[I] <> nil then
        if PlayerHoldShip.Weapons[I].NeedsAmmo then
        begin
          Button.SetActive(True);
          Break;
        end;
end;
{ @end $712E7C }

{ @routine $71331C TfShip2_SellAllItems }
procedure TfShip2.SellAllItems(Origin: Integer);
var
  PlaySaleSound, Changed: Boolean;
  I, StorageIndex, SavedCount, SavedCost: Integer;
  Item: TItem;
  AllowIllegal, DeclineIllegal: Boolean;
  Good: Byte;
  Entry: PStorageEntry;

  // @nested $712F80 SellItem
  function SellItem(Item: TItem; IgnoreRequiredEquipment: Boolean): Boolean; // @addr $712F80 @calls "0x713540,0x713661,0x7139EB" Nested helper captures sale/change flags.
  var
    Count, Cost, Price: Integer;
    Event: TGalaxyEvent;
  begin
    Result := False;
    if Item = nil then Exit;
    if not IgnoreRequiredEquipment then
    begin
      if PlayerHoldShip is TRuins then
      begin
        if PlayerHoldShip.NeedsEquipmentType(Item.ItemType) then Exit;
      end
      else if ((Item.ItemType = t_FuelTanks) or (Item.ItemType = t_Engine)) and PlayerHoldShip.NeedsEquipmentType(Item.ItemType) then Exit;
    end;
    if Item.ItemType in [t_Food..t_Narcotics] then
    begin
      Count := GetPlayer.CargoGoods[Ord(Item.ItemType)].Count;
      Cost := GetPlayer.CargoGoods[Ord(Item.ItemType)].TotalCost;
      GetPlayer.CargoGoods[Ord(Item.ItemType)].Count := (Item as TGoods).Quantity;
      GetPlayer.CargoGoods[Ord(Item.ItemType)].TotalCost := (Item as TGoods).Cost;
      GetPlayer.SellGoodsToLocation(Byte(Item.ItemType),(Item as TGoods).Quantity);
      PlaySaleSound := True;
      GetPlayer.CargoGoods[Ord(Item.ItemType)].Count := Count;
      GetPlayer.CargoGoods[Ord(Item.ItemType)].TotalCost := Cost;
      Item.Free;
    end
    else
    begin
      if not (Item is TCountableItem) then
      begin
        Event := AddGalaxyEvent('PlayerSellsEquipment');
        Event.AddData(Ord(Item.ItemType));
        Event.AddData(Item.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading)));
        Event.AddData(Item.Weight);
        Event.AddData(Item.Id);
        Event.AddTextData(Item.GetDisplayName);
        Event.AddTextData(Item.GetCategoryConfigName);
      end;
      Price := Item.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(psTrading));
      GetPlayer.SetMoney(GetPlayer.Money + Price);
      if Price <> 0 then PlaySaleSound := True;
      if Item is TWeapon then (Item as TWeapon).Target := nil;
      if (Item.ItemType = t_Hull) and ((Item as THull).HullType = htSpecial) then Item.Free
      else if (Item.OwnerId in [oiMaloc..oiGaal,oiPirate]) and (Item.ItemType in [t_Hull..t_CustomWeapon]) and
        (not (Item is TWeapon) or (TWeapon(Item).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) then
      begin
        RestoreTemporaryShopStock;
        if GetPlayer.CurrentPlanet <> nil then GetPlayer.CurrentPlanet.EquipmentShop.Add(Item)
        else (GetPlayer.DockedTo as TRuins).EquipmentShop.Add(Item);
        BuildTemporaryShopSlotGrid;
      end
      else Item.Free;
    end;
    Result := True;
    Changed := True;
  end;

begin
  if GetPlayer.InNormalSpace or GetPlayer.InHyperspace or (GetPlayer.RuinsMode > 0) or
    (QueuedArcadeBattles.Count > 0) or ((GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet.OwnerId = oiUninhabited)) then Exit;
  if GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet <> nil) and
    (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning)
    else
      ShowMessageBoxGI(Self,ReplaceColoredToken(LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),'<Planet>',GetPlayer.CurrentPlanet.Name,TextHighlightColorTag),mbgCancel or mbgWarning);
    Exit;
  end;
  Galaxy.CheckIntegrityChecksum1(517);
  Changed := False;
  PlaySaleSound := False;
  AllowIllegal := False;
  DeclineIllegal := False;
  if Origin = 0 then
  begin
    I := PlayerHoldShip.Inventory.Count - 1;
    while I >= 0 do
    begin
      Item := PlayerHoldShip.Inventory[I];
      if (Item.NoDropFlag = 0) and (Item.ItemType <> t_Hull) and (TEquipment(Item).EquippedFlag = 0) and
        ((Item.ScriptItem = nil) or TScriptItem(Item.ScriptItem).CanSell) and GetPlayer.CanAccessStoredItem(Item) then
        if SellItem(Item,False) then PlayerHoldShip.Inventory.Delete(I);
      Dec(I);
    end;
    I := PlayerHoldShip.Artefacts.Count - 1;
    while I >= 0 do
    begin
      Item := PlayerHoldShip.Artefacts[I];
      if (Item.NoDropFlag = 0) and (TEquipment(Item).EquippedFlag = 0) and
        ((Item.ScriptItem = nil) or TScriptItem(Item.ScriptItem).CanSell) and GetPlayer.CanAccessStoredItem(Item) then
      begin
        if Item is TArtefactTranclucator then
          if ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.SellItemQuestion'),TextHighlightColorTag,'<Item>',Item.GetDisplayName),mbgOK or mbgCancel or mbgQuestion) = 2 then
          begin
            Dec(I);
            Continue;
          end;
        PlayerHoldShip.Artefacts.Delete(I);
        SellItem(Item,True);
      end;
      Dec(I);
    end;
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
      if PlayerHoldShip.CargoGoods[Good].Count > 0 then
        if GetPlayer.CanAccessHoldGoods(Good) then
        begin
          if GetPlayer.IsCargoGoodIllegalOnCurrentPlanet(Good) and not AllowIllegal and not DeclineIllegal then
            if ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormGS.NotPermitGoods'),mbgOK or mbgCancel) <> mbgResultOK then DeclineIllegal := True
            else AllowIllegal := True;
          if not (GetPlayer.IsCargoGoodIllegalOnCurrentPlanet(Good) and DeclineIllegal) then
          begin
            Changed := True;
            PlaySaleSound := True;
            if GetPlayer = PlayerHoldShip then GetPlayer.SellGoodsToLocation(Good,GetPlayer.CargoGoods[Good].Count)
            else
            begin
              SavedCount := GetPlayer.CargoGoods[Good].Count;
              SavedCost := GetPlayer.CargoGoods[Good].TotalCost;
              GetPlayer.CargoGoods[Good].Count := PlayerHoldShip.CargoGoods[Good].Count;
              GetPlayer.CargoGoods[Good].TotalCost := PlayerHoldShip.CargoGoods[Good].TotalCost;
              PlayerHoldShip.CargoGoods[Good].Count := 0;
              PlayerHoldShip.CargoGoods[Good].TotalCost := 0;
              GetPlayer.SellGoodsToLocation(Good,GetPlayer.CargoGoods[Good].Count);
              GetPlayer.CargoGoods[Good].Count := SavedCount;
              GetPlayer.CargoGoods[Good].TotalCost := SavedCost;
            end;
          end;
        end;
  end
  else
  begin
    I := GetPlayer.GetStorageSlotExtent(GetLocalStorageOwner) - 1;
    while I >= 0 do
    begin
      StorageIndex := GetPlayer.FindStorageIndexByLocationAndSlot(GetLocalStorageOwner,I);
      if StorageIndex >= 0 then
      begin
        Entry := GetPlayer.StorageEntries[StorageIndex];
        Item := Entry.Item;
        if (Item.NoDropFlag > 0) or ((Item.ScriptItem <> nil) and not TScriptItem(Item.ScriptItem).CanSell) then
        begin
          Dec(I);
          Continue;
        end;
        if Item is TArtefactTranclucator then
          if ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormShip.SellItemQuestion'),TextHighlightColorTag,'<Item>',Item.GetDisplayName),mbgOK or mbgCancel or mbgQuestion) = 2 then
          begin
            Dec(I);
            Continue;
          end;
        if Item is TGoods then
          if GetPlayer.IsCargoGoodIllegalOnCurrentPlanet(Byte(Item.ItemType)) and not AllowIllegal and not DeclineIllegal then
            if ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormGS.NotPermitGoods'),mbgOK or mbgCancel) <> mbgResultOK then DeclineIllegal := True
            else AllowIllegal := True;
        if (Item is TGoods) and GetPlayer.IsCargoGoodIllegalOnCurrentPlanet(Byte(Item.ItemType)) and DeclineIllegal then
        begin
          Dec(I);
          Continue;
        end;
        Entry.Item := nil;
        GetPlayer.StorageEntries.Delete(StorageIndex);
        Dispose(Entry);
        SellItem(Item,True);
      end;
      Dec(I);
    end;
  end;
  if Changed then
  begin
    ShipStateChanged := True;
    if PlaySaleSound then SoundManager.PlaySound('Sound.Sell');
    Galaxy.PrimeIntegrityChecksum1(518);
    RefreshShipView;
    ReopenRequested := True;
    PlayTransitionSounds := False;
    CloseClicked(nil);
  end;
end;
{ @end $71331C }

{ @routine $713C1C TfShip2_EnterBridgeClicked }
procedure TfShip2.EnterBridgeClicked(Sender: TObjectGI);
begin
  Galaxy.CheckIntegrityChecksum1(416);
  if SelectedHoldKind <> phkEmpty then ReturnSelectedHoldEntry;
  GetPlayer.EnterRuinsMode(0);
  Galaxy.PrimeIntegrityChecksum1(471);
end;
{ @end $713C1C }

{ @routine $713C70 TfShip2_GetActionParentLoop }
function TfShip2.GetActionParentLoop: TMessageLoopGI;
begin
  Result := ParentLoop;
end;
{ @end $713C70 }

{ @routine $713C8C TfShip2_ExecuteUiCode }
procedure TfShip2.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not ExitScreenLoop and (TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared]) then
  begin
    Galaxy.CheckIntegrityChecksum1(10012);
    Galaxy.CheckIntegrityChecksum2(10013);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum1(20012);
    Galaxy.PrimeIntegrityChecksum2(20013);
  end;
end;
{ @end $713C8C }

end.
