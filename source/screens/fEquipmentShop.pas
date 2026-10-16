unit fEquipmentShop;

interface

uses Classes, EC_Buf, aGalaxy, EC_BlockPar, EC_Struct, GI_GAI, GI_Image, GI_MessageLoop, GI_Window, Types, aItem, aPlanet, aRuins, fPanelLoad, fPanelMain, fPanelPlanet, fPanelRuins;

type
  TShopSlot = class(TObjectEx) // @size 0x28
  public
    GridPoint: TPoint; // @offset 0x04
    Item: TItem; // @offset 0x0C
    SlotImage: TImageGI; // @offset 0x10
    BorderImage: TImageGI; // @offset 0x14
    TypeOverlayImage: TImageGI; // @offset 0x18
    ItemIconImage: TImageGI; // @offset 0x1C
    ItemAnimation: TgaiGI; // @offset 0x20
    MicroModuleImage: TImageGI; // @offset 0x24
    procedure SaveToBuffer(Buffer: TBufEC); // @addr $67E8A0
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); // @addr $67E918
    // Owns Item while the location's shop list is detached, and frees remaining controls.
    constructor Create; // @addr 0x0067E7CC
    destructor Destroy; override; // @addr 0x0067E804
  end;

  TfEquipmentShop = class(TMessageLoopGIWithMainPanel) // @size 0x120
  public
    PlanetPanel: TfPanelPlanet; // @offset 0xD4
    StationPanel: TfPanelRuins; // @offset 0xD8
    LoadPanel: TfPanelLoad; // @offset 0xDC
    ItemInfoAnchor: TPoint; // @offset 0xE0
    ItemInfoWindow: TWindowGI; // @offset 0xE8
    UnknownEC: Integer; // @offset $EC Cleared when rebuilding the stock controls; purpose unresolved.
    ContentColumnCount: Integer; // @offset 0xF0
    TargetScrollX: Integer; // @offset 0xF4
    ScrollTimer: TCallbackTimerIdGI; // @offset 0xF8
    ItemInfoTimer: TCallbackTimerIdGI; // @offset 0xFC
    OpenPreviewTimer: TCallbackTimerIdGI; // @offset 0x100
    PreviewSlot: TShopSlot; // @offset 0x104
    HullSizeOffset: TPoint; // @offset 0x108
    HullPriceOffset: TPoint; // @offset 0x110
    HullRaceOffset: TPoint; // @offset 0x118

    constructor Create; // @addr 0x0067E978
    destructor Destroy; override; // @addr 0x0067E9E4
    procedure OnOpen; override; // @addr 0x0067EFAC
    procedure OnClose; override; // @addr 0x0067F6D8
    procedure SelectMusic; override; // @addr 0x0068460C
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x006843A8
    procedure InitializeLayout; override; // @addr 0x0067EA50
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x006845A8
    procedure BuildGoodsControls; // @addr 0x0067F844
    procedure ClearGoodsControls; // @addr 0x00680650
    procedure UpdateScrollButtons; // @addr 0x00680AFC
    procedure ScrollLeft(Sender: TObjectGI); // @addr 0x00680ED8
    procedure ScrollRight(Sender: TObjectGI); // @addr 0x00680F98
    procedure ItemMouseEnter(Sender: TObjectGI); // @addr 0x00680C5C
    procedure ItemMouseLeave(Sender: TObjectGI); // @addr 0x00680DD8
    procedure RefreshItemInfo(Item: TItem); // @addr 0x00682150

    procedure EndTurnClicked(Sender: TObjectGI); // @addr $680748
    procedure ShipClicked(Sender: TObjectGI); // @addr $6809EC
    procedure ScrollTick(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $68106C
    procedure ItemMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $681178
    procedure ChooseAnimatedPreview(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $681F64
    procedure PreviewCycleComplete(Sender: TObjectGI); // @addr $68202C
    procedure HideItemInfo(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $682044
    procedure BuildHullSlotOverlays(Parent: TObjectGI; Hull: THull; OffsetX, OffsetY: Integer); // @addr $682E30
    procedure RefreshHullInfo(Target: TMessageLoopGI; Hull: THull; Text: WideString; SuppressImage: Boolean); // @addr $68323C
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $684448

    procedure StartSlotAnimatedPreview(Slot: TShopSlot); // @addr 0x00680BEC
    procedure ScheduleSlotPreviewStop(Slot: TShopSlot); // @addr 0x00680C40 @note "Playback continues until the current animation cycle ends."
    procedure PanelScrollChanged(Sender: TObjectGI); // @addr 0x0068112C
  end;

procedure TemporaryShopStockHook(Argument: Pointer); // @addr $67E2AC Native no-op. Sole caller passes nil; original parameter meaning is unresolved.
procedure BuildTemporaryShopSlotGrid; // @addr 0x0067E2B0 @note "Transfers ownership of market inventory into the temporary slots."
procedure RestoreTemporaryShopStock; // @addr 0x0067E5D4 @note "Returns ownership of remaining items to the original market."
procedure ClearTemporaryShopSlotGrid; // @addr 0x0067E68C @note "Frees remaining items without returning them to the market."
function FindShopSlotByGridPoint(Point: TPoint): TShopSlot; // @addr 0x0067E6E0
function FindShopSlotByItem(Item: TItem): TShopSlot; // @addr 0x0067E728
function GetShopItemIconName(Item: TItem): WideString; // @addr 0x0067E768

var
  ShopGridRowCount: Integer = 4; // @addr 0x0080F7D8
  ShopVisibleColumnCount: Integer = 6; // @addr 0x0080F7DC
  TemporaryShopSlots: TList = nil; // @addr 0x0080F7E0
  TemporaryShopPlanet: TPlanet = nil; // @addr 0x0080F7E4
  TemporaryShopStation: TRuins = nil; // @addr 0x0080F7E8

implementation

uses aGalaxyEvent, GI_MessageBox, SE_Space, aKling, aScript, GI_GraphBuf, GI_GI, fShip2, fRuinsTalk, aPlayer, aGalaxyStruct, aConst, aShip, aMyFunction, EC_Str, Math, Windows, SysUtils, GI_Panel, GI_PanelScrollBar, GI_GraphButton, GI_Label, GR_Main, GR_Music, Globals, GlobalsV;
{ @routine $67E2AC TemporaryShopStockHook }
procedure TemporaryShopStockHook(Argument: Pointer);
begin
end;
{ @end $67E2AC }

{ @routine $67E2B0 BuildTemporaryShopSlotGrid }
procedure BuildTemporaryShopSlotGrid;
var X, Y, EmptyCount, I, J: Integer; Slot, Other: TShopSlot; Item: TItem; ItemOrder, OtherOrder: Integer; Station: TRuins;
begin
  TemporaryShopStockHook(nil);
  ClearTemporaryShopSlotGrid;
  TemporaryShopSlots := TList.Create;
  if GetPlayer.CurrentPlanet <> nil then
  begin
    for I := 0 to GetPlayer.CurrentPlanet.EquipmentShop.Count - 1 do
    begin
      Item := GetPlayer.CurrentPlanet.EquipmentShop[I];
      Slot := TShopSlot.Create;
      TemporaryShopSlots.Add(Slot);
      Slot.Item := Item;
    end;
    GetPlayer.CurrentPlanet.EquipmentShop.Clear;
    TemporaryShopPlanet := GetPlayer.CurrentPlanet;
  end
  else
  begin
    if GetPlayer.DockedTo = nil then Exit;
    if not (GetPlayer.DockedTo is TRuins) then Exit;
    Station := GetPlayer.DockedTo as TRuins;
    for I := 0 to Station.EquipmentShop.Count - 1 do
    begin
      Item := Station.EquipmentShop[I];
      Slot := TShopSlot.Create;
      TemporaryShopSlots.Add(Slot);
      Slot.Item := Item;
    end;
    Station.EquipmentShop.Clear;
    TemporaryShopStation := Station;
  end;
  for I := 0 to TemporaryShopSlots.Count - 2 do
  begin
    Slot := TemporaryShopSlots[I];
    if Slot.Item = nil then Continue;
    for J := I + 1 to TemporaryShopSlots.Count - 1 do
    begin
      Other := TemporaryShopSlots[J];
      if Other.Item = nil then Continue;
      if Slot.Item.ItemType in [item_hull..item_custom_weapon] then ItemOrder := Ord(Slot.Item.ItemType) - 75
      else ItemOrder := Ord(Slot.Item.ItemType);
      if Other.Item.ItemType in [item_hull..item_custom_weapon] then OtherOrder := Ord(Other.Item.ItemType) - 75
      else OtherOrder := Ord(Other.Item.ItemType);
      if (ItemOrder > OtherOrder) or ((ItemOrder = OtherOrder) and (Slot.Item.Cost > Other.Item.Cost)) then
      begin
        Item := Slot.Item;
        Slot.Item := Other.Item;
        Other.Item := Item;
      end;
    end;
  end;
  EmptyCount := 0;
  if TemporaryShopSlots.Count < ShopVisibleColumnCount * ShopGridRowCount then
    EmptyCount := ShopVisibleColumnCount * ShopGridRowCount - TemporaryShopSlots.Count
  else if TemporaryShopSlots.Count mod ShopGridRowCount <> 0 then
    EmptyCount := ShopGridRowCount - TemporaryShopSlots.Count mod ShopGridRowCount;
  for I := 1 to EmptyCount do
  begin
    Slot := TShopSlot.Create;
    Slot.Item := nil;
    TemporaryShopSlots.Add(Slot);
  end;
  EmptyCount := 0;
  for Y := 0 to ShopGridRowCount - 1 do
    for X := 0 to TemporaryShopSlots.Count div ShopGridRowCount - 1 do
    begin
      Slot := TemporaryShopSlots[EmptyCount];
      Slot.GridPoint := Classes.Point(X, Y);
      Inc(EmptyCount);
    end;
end;
{ @end $67E2B0 }

{ @routine $67E5D4 RestoreTemporaryShopStock }
procedure RestoreTemporaryShopStock;
var I, Count: Integer; Slot: TShopSlot;
begin
  if TemporaryShopSlots = nil then Exit;
  if TemporaryShopPlanet <> nil then
  begin
    Count := TemporaryShopSlots.Count;
    for I := 0 to Count - 1 do
    begin
      Slot := TemporaryShopSlots[I];
      if Slot.Item <> nil then TemporaryShopPlanet.EquipmentShop.Add(Slot.Item);
      Slot.Item := nil;
    end;
  end
  else if TemporaryShopStation <> nil then
  begin
    Count := TemporaryShopSlots.Count;
    for I := 0 to Count - 1 do
    begin
      Slot := TemporaryShopSlots[I];
      if Slot.Item <> nil then TemporaryShopStation.EquipmentShop.Add(Slot.Item);
      Slot.Item := nil;
    end;
  end;
  ClearTemporaryShopSlotGrid;
end;
{ @end $67E5D4 }

{ @routine $67E68C ClearTemporaryShopSlotGrid }
procedure ClearTemporaryShopSlotGrid;
var I, Count: Integer; Slot: TShopSlot;
begin
  if TemporaryShopSlots = nil then Exit;
  Count := TemporaryShopSlots.Count;
  for I := 0 to Count - 1 do
  begin
    Slot := TemporaryShopSlots[I];
    Slot.Free;
  end;
  TemporaryShopSlots.Clear;
  TemporaryShopSlots.Free;
  TemporaryShopSlots := nil;
  TemporaryShopPlanet := nil;
  TemporaryShopStation := nil;
end;
{ @end $67E68C }

{ @routine $67E6E0 FindShopSlotByGridPoint }
function FindShopSlotByGridPoint(Point: TPoint): TShopSlot;
var
  Count, I: Integer;
  Slot: TShopSlot;
begin
  Count := TemporaryShopSlots.Count;
  for I := 0 to Count - 1 do
  begin
    Slot := TemporaryShopSlots[I];
    if (Slot.GridPoint.X = Point.X) and (Slot.GridPoint.Y = Point.Y) then
    begin
      Result := Slot;
      Exit;
    end;
  end;
  Result := nil;
end;
{ @end $67E6E0 }

{ @routine $67E728 FindShopSlotByItem }
function FindShopSlotByItem(Item: TItem): TShopSlot;
var I: Integer;
begin
  for I := 0 to TemporaryShopSlots.Count - 1 do
    if TShopSlot(TemporaryShopSlots[I]).Item = Item then
    begin
      Result := TemporaryShopSlots[I];
      Exit;
    end;
  Result := nil;
end;
{ @end $67E728 }

{ @routine $67E768 GetShopItemIconName }
function GetShopItemIconName(Item: TItem): WideString;
var Owner: TOwnerId;
begin
  if (Item is TEquipment) and (Item.ItemType in UtilityEquipmentTypes) and
    (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(disease_holy_fanaticism) then
  begin
    Owner := Item.OwnerId;
    Item.OwnerId := owner_dominator;
    Result := Item.GetBitmapResourceName;
    Item.OwnerId := Owner;
  end
  else Result := Item.GetBitmapResourceName;
end;
{ @end $67E768 }

{ @routine $67E7CC TShopSlot_Create }
constructor TShopSlot.Create;
begin
  inherited Create;
end;
{ @end $67E7CC }

{ @routine $67E804 TShopSlot_Destroy }
destructor TShopSlot.Destroy;
begin
  if Item <> nil then
  begin
    Item.Free;
    Item := nil;
  end;
  if SlotImage <> nil then
  begin
    SlotImage.Free;
    SlotImage := nil;
  end;
  if BorderImage <> nil then
  begin
    BorderImage.Free;
    BorderImage := nil;
  end;
  if TypeOverlayImage <> nil then
  begin
    TypeOverlayImage.Free;
    TypeOverlayImage := nil;
  end;
  if ItemIconImage <> nil then
  begin
    ItemIconImage.Free;
    ItemIconImage := nil;
  end;
  if ItemAnimation <> nil then
  begin
    ItemAnimation.Free;
    ItemAnimation := nil;
  end;
  if MicroModuleImage <> nil then
  begin
    MicroModuleImage.Free;
    MicroModuleImage := nil;
  end;
  inherited Destroy;
end;
{ @end $67E804 }

{ @routine $67E8A0 TShopSlot_SaveToBuffer }
procedure TShopSlot.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddAnsiChar(AnsiChar(GridPoint.X));
  Buffer.AddAnsiChar(AnsiChar(GridPoint.Y));
  if Item = nil then Buffer.AddAnsiChar(#0)
  else
  begin
    Buffer.AddAnsiChar(#1);
    Buffer.AddAnsiChar(AnsiChar(Item.ItemType));
    if Item is TWeapon then (Item as TWeapon).Target := nil;
    Item.SaveToBuffer(Buffer);
  end;
end;
{ @end $67E8A0 }

{ @routine $67E918 TShopSlot_LoadFromBuffer }
procedure TShopSlot.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  GridPoint.X := Buffer.GetByte;
  GridPoint.Y := Buffer.GetByte;
  if Buffer.GetByte = 1 then
  begin
    Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte)) as TEquipment;
    Item.LoadFromBuffer(Buffer, Galaxy);
  end;
end;
{ @end $67E918 }

{ @routine $67E978 TfEquipmentShop_Create }
constructor TfEquipmentShop.Create;
begin
  inherited Create;
  PlanetPanel := TfPanelPlanet.Create;
  StationPanel := TfPanelRuins.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $67E978 }

{ @routine $67E9E4 TfEquipmentShop_Destroy }
destructor TfEquipmentShop.Destroy;
begin
  if PlanetPanel <> nil then begin PlanetPanel.Free; PlanetPanel := nil; end;
  if StationPanel <> nil then begin StationPanel.Free; StationPanel := nil; end;
  if LoadPanel <> nil then begin LoadPanel.Free; LoadPanel := nil; end;
  inherited Destroy;
end;
{ @end $67E9E4 }

{ @routine $67EA50 TfEquipmentShop_InitializeLayout }
procedure TfEquipmentShop.InitializeLayout;
var ExtraWidth: Integer;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  PlanetPanel.InitializeLayout(Self);
  StationPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  ExtraWidth := ExtraScreenWidth div 198 * 198;
  if ExtraWidth > 198 then ExtraWidth := 198;
  ShopVisibleColumnCount := 6 + ExtraWidth div 99;
  AppendLogTextThreadSafe('fEquipmentShop... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGCity').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGCity2').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('PanelShop') do
    begin
      SetSize(Classes.Point(ClientSize.X + ExtraWidth, ClientSize.Y));
      SetPosition(Classes.Point((Integer(GameScreenWidth) - ClientSize.X) div 2, LocalPosition.Y + ExtraScreenHeight div 2));
      if ExtraWidth > 0 then
      begin
        with FindByNameRecursive('Right') do SetPosition(Classes.Point(LocalPosition.X + ExtraWidth, LocalPosition.Y));
        with FindByNameRecursive('ButFormClose') do SetPosition(Classes.Point(LocalPosition.X + ExtraWidth, LocalPosition.Y));
        with FindByNameRecursive('PanelImage') do SetSize(Classes.Point(ClientSize.X + ExtraWidth, ClientSize.Y));
        with FindByNameRecursive('BGImageRace') do SetSize(Classes.Point(ClientSize.X + ExtraWidth, ClientSize.Y));
        with FindByNameRecursive('PanelGoods') do SetSize(Classes.Point(ClientSize.X + ExtraWidth, ClientSize.Y));
      end;
    end;
  end;
  AppendLogLineThreadSafe('ok');
  (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
  (GetByName('PM_Ship') as TGraphButtonGI).UpCallback := ShipClicked;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  ItemInfoWindow := GetByName('PII') as TWindowGI;
  with GetByName('InfoHullSize') do HullSizeOffset := Classes.Point(LocalPosition.X, LocalPosition.Y - Parent.ClientSize.Y);
  with GetByName('InfoHullPrice') do HullPriceOffset := Classes.Point(LocalPosition.X, LocalPosition.Y - Parent.ClientSize.Y);
  with GetByName('InfoHullEmRace') do HullRaceOffset := Classes.Point(LocalPosition.X - Parent.ClientSize.X, LocalPosition.Y - Parent.ClientSize.Y);
end;
{ @end $67EA50 }

{ @routine $67EFAC TfEquipmentShop_OnOpen }
procedure TfEquipmentShop.OnOpen;
var
  Owner: TOwnerId;
  Size: Integer;
  BackgroundPath: WideString;
  SavedSlots: TList;
begin
  if not MusicInPlanetEnabled then MusicManager.RequestFadeOut;
  MainPanel.OnOpen;
  LoadPanel.OnOpen;
  if GetPlayer.IsOnPlanet then
  begin
    PlanetPanel.OnOpen;
    PlanetPanel.Show;
    StationPanel.Hide;
  end
  else
  begin
    PlanetPanel.Hide;
    StationPanel.OnOpen;
    StationPanel.Show;
  end;
  with GetByName('ButFormClose') as TGraphButtonGI do
    if GetPlayer.IsOnPlanet then UpCallback := PlanetPanel.PlanetClicked
    else if GetPlayer.IsDockedToShip then UpCallback := StationPanel.ServicesClicked;
  with GetByName('BGCity2') as TImageGI do
  begin
    SetActive(GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_military_base));
    if Active then
    begin
      ImageSourcePath := 'GAI,' + GetPlayer.CurrentStar.GetBackgroundImagePath(Size);
      GaiImageControl.LoadFrameSequenceFromText(SingleFrameAnimationSpec);
      KindX := image_x_center;
      KindY := image_y_center;
    end;
  end;
  with GetByName('BGCity') as TImageGI do
    if GetPlayer.IsOnPlanet then
    begin
      SetActive(True);
      (FindByNameRecursive('BGCity') as TImageGI).ImageSourcePath := GetPlayer.CurrentPlanet.GetGovernmentBackgroundGraph;
    end
    else if GetPlayer.IsDockedToShip then
    begin
      SetActive(True);
      if GetPlayer.DockedTo.TypeNameOverrideKey <> '' then
      begin
        BackgroundPath := 'Bm.FormRuins.' + GiResourceSuffix + GetPlayer.DockedTo.TypeNameOverrideKey + 'bg';
        if CacheDataRoot.FileExistsByPath(BackgroundPath) then SetImagePath('GI,' + BackgroundPath)
        else SetImagePath('GI,Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[GetPlayer.DockedTo.TypeId].Name + 'bg');
      end
      else SetImagePath('GI,Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[GetPlayer.DockedTo.TypeId].Name + 'bg');
    end
    else SetActive(False);
  with GetByName('BGImageRace') as TImageGI do
  begin
    if GetPlayer.IsOnPlanet then Owner := RaceToOwner(GetPlayer.CurrentPlanet.RaceId)
    else if GetPlayer.IsDockedToShip then Owner := GetPlayer.DockedTo.OwnerId
    else Owner := owner_maloc;
    SetActive(True);
    if Owner = owner_peleng then ImageSourcePath := 'GI,Bm.FormShop2.' + GiResourceSuffix + 'Peleng'
    else if Owner = owner_human then ImageSourcePath := 'GI,Bm.FormShop2.' + GiResourceSuffix + 'People'
    else if Owner = owner_feyan then ImageSourcePath := 'GI,Bm.FormShop2.' + GiResourceSuffix + 'Fei'
    else if Owner = owner_gaal then ImageSourcePath := 'GI,Bm.FormShop2.' + GiResourceSuffix + 'Gaal'
    else SetActive(False);
  end;
  with GetByName('Left') as TGraphButtonGI do DownCallback := ScrollLeft;
  with GetByName('Right') as TGraphButtonGI do DownCallback := ScrollRight;
  GetByName('PII').SetActive(False);
  ClearGoodsControls;
  RestoreTemporaryShopStock;
  if GetPlayer <> nil then
  begin
    SavedSlots := TemporaryShopSlots;
    TemporaryShopSlots := nil;
    GetPlayer.ScriptItemsAct(event_enter_form, nil, nil, 0);
    TemporaryShopSlots := SavedSlots;
  end;
  BuildTemporaryShopSlotGrid;
  BuildGoodsControls;
  UpdateScrollButtons;
  PreviewSlot := nil;
  if OpenPreviewTimer <> 0 then
  begin
    CancelCallbackTimer(OpenPreviewTimer);
    OpenPreviewTimer := 0;
  end;
  if AnimItem then OpenPreviewTimer := ScheduleCallbackTimer(100, 99999, ChooseAnimatedPreview);
  MainPanel.RebuildMessageButtons(False);
  Galaxy.PrimeIntegrityChecksum(190);
end;
{ @end $67EFAC }

{ @routine $67F6D8 TfEquipmentShop_OnClose }
procedure TfEquipmentShop.OnClose;
var
  Slot: TShopSlot;
  I, Count: Integer;
begin
  Galaxy.CheckIntegrityChecksum(191);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(event_leave_form, nil, nil, 0);
  if TemporaryShopSlots <> nil then
  begin
    Count := TemporaryShopSlots.Count;
    for I := 0 to Count - 1 do
    begin
      Slot := TemporaryShopSlots[I];
      if Slot.SlotImage <> nil then begin Slot.SlotImage.Free; Slot.SlotImage := nil; end;
      if Slot.BorderImage <> nil then begin Slot.BorderImage.Free; Slot.BorderImage := nil; end;
      if Slot.TypeOverlayImage <> nil then begin Slot.TypeOverlayImage.Free; Slot.TypeOverlayImage := nil; end;
      if Slot.ItemIconImage <> nil then begin Slot.ItemIconImage.Free; Slot.ItemIconImage := nil; end;
      if Slot.ItemAnimation <> nil then begin Slot.ItemAnimation.Free; Slot.ItemAnimation := nil; end;
      if Slot.MicroModuleImage <> nil then begin Slot.MicroModuleImage.Free; Slot.MicroModuleImage := nil; end;
    end;
  end;
  if OpenPreviewTimer <> 0 then begin CancelCallbackTimer(OpenPreviewTimer); OpenPreviewTimer := 0; end;
  if ScrollTimer <> 0 then begin CancelCallbackTimer(ScrollTimer); ScrollTimer := 0; end;
  if ItemInfoTimer <> 0 then begin CancelCallbackTimer(ItemInfoTimer); ItemInfoTimer := 0; end;
  RestoreTemporaryShopStock;
  MainPanel.OnClose;
  LoadPanel.OnClose;
  if (GetPlayer <> nil) and GetPlayer.IsOnPlanet then PlanetPanel.OnClose
  else StationPanel.OnClose;
end;
{ @end $67F6D8 }

{ @routine $67F844 TfEquipmentShop_BuildGoodsControls }
procedure TfEquipmentShop.BuildGoodsControls;
var
  Slot: TShopSlot;
  I, Count: Integer;
  Panel: TPanelGI;
  X, Y, Cost: Integer;
  CellWidth, CellHeight: Single;
  LevelSuffix: WideString;
begin
  UnknownEC := 0;
  ContentColumnCount := 0;
  Count := TemporaryShopSlots.Count;
  for I := 0 to Count - 1 do
  begin
    Slot := TemporaryShopSlots[I];
    if ContentColumnCount <= Slot.GridPoint.X then ContentColumnCount := Slot.GridPoint.X + 1;
  end;
  Panel := GetByName('PanelGoods') as TPanelGI;
  CellWidth := Panel.ClientSize.X / ShopVisibleColumnCount;
  CellHeight := Panel.ClientSize.Y / ShopGridRowCount;
  for I := 1 to ContentColumnCount - 1 do
    with TImageGI.Create(Panel) do
    begin
      World := True;
      ImageSourcePath := 'GI,Bm.FormShop2.' + GiResourceSuffix + 'Line';
      ObjectSize := GetContentSize;
      Sme := Classes.Point(ClientSize.X div 2, 0);
      Pos := Classes.Point(Round(I * CellWidth), Panel.ClientSize.Y div 2 - ClientSize.Y div 2);
      PosZd := 4;
      UserData := 1;
    end;
  for Y := 0 to ShopGridRowCount - 1 do
    for X := 0 to ContentColumnCount - 1 do
    begin
      Slot := FindShopSlotByGridPoint(Classes.Point(X, Y));
      Slot.SlotImage := TImageGI.Create(Panel);
      with Slot.SlotImage do
      begin
        World := True;
        Pos := Classes.Point(Round(X * CellWidth), Round(Y * CellHeight));
        ObjectSize := Classes.Point(Trunc(CellWidth), Trunc(CellHeight));
        PosZd := 3;
        UserValue := Integer(Slot);
        if Slot.Item = nil then IsActive := False
        else
        begin
          if Slot.Item is TWeapon then (Slot.Item as TWeapon).Target := nil;
          SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotN');
          MouseEnterCallback := ItemMouseEnter;
          MouseLeaveCallback := ItemMouseLeave;
          LeftButtonUpCallback := ItemMouseUp;
        end;
        SetImageKindX(image_x_center);
        SetImageKindY(image_y_center);
      end;
      Slot.BorderImage := TImageGI.Create(Panel);
      with Slot.BorderImage do
      begin
        World := True;
        Pos := Classes.Point(Round(X * CellWidth), Round(Y * CellHeight));
        ObjectSize := Classes.Point(Trunc(CellWidth), Trunc(CellHeight));
        PosZd := 3;
        if Slot.Item = nil then SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotBorderN')
        else
        begin
          Cost := Slot.Item.GetConditionAdjustedCost;
          if Slot.Item is THull then Cost := Max(1, Cost - GetPlayer.GetHull.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(skill_trading)));
          if (GetPlayer.Money < Cost) or ((Slot.Item.ItemType <> item_hull) and (GetPlayer.GetCargoFreeSpace < Slot.Item.Weight)) then
            SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotBorderH')
          else SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotBorderN');
        end;
        SetImageKindX(image_x_center);
        SetImageKindY(image_y_center);
      end;
      if Slot.Item <> nil then
      begin
        Slot.TypeOverlayImage := TImageGI.Create(Panel);
        with Slot.TypeOverlayImage do
        begin
          World := True;
          Pos := Classes.Point(Round(X * CellWidth), Round(Y * CellHeight));
          ObjectSize := Classes.Point(Trunc(CellWidth), Trunc(CellHeight));
          PosZd := 3;
          if TEquipment(Slot.Item).GetLevel <> 0 then LevelSuffix := '_' + IntToWideString(TEquipment(Slot.Item).GetLevel)
          else if Slot.Item is TMicroModule then LevelSuffix := '_' + IntToWideString(GetMicroModulePriorityColorTier(TEquipment(Slot.Item).MicroModuleIndex - 1))
          else LevelSuffix := '';
          if (TEquipment(Slot.Item).ConfigBlockName <> '') and
            CacheDataRoot.FileExistsByPath('Bm.FormShop2.' + GiResourceSuffix + 'Slot' + TEquipment(Slot.Item).ConfigBlockName + LevelSuffix) then
            SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'Slot' + TEquipment(Slot.Item).ConfigBlockName + LevelSuffix)
          else if (Slot.Item is TMicroModule) and (MicroModuleTemplates[TEquipment(Slot.Item).MicroModuleIndex - 1].KindGraph <> '') and
            CacheDataRoot.FileExistsByPath('Bm.FormShop2.' + GiResourceSuffix + 'Slot' + MicroModuleTemplates[TEquipment(Slot.Item).MicroModuleIndex - 1].KindGraph + LevelSuffix) then
            SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'Slot' + MicroModuleTemplates[TEquipment(Slot.Item).MicroModuleIndex - 1].KindGraph + LevelSuffix)
          else if CacheDataRoot.FileExistsByPath('Bm.FormShop2.' + GiResourceSuffix + 'Slot' + ItemTypeNames[Slot.Item.ItemType] + LevelSuffix) then
            SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'Slot' + ItemTypeNames[Slot.Item.ItemType] + LevelSuffix)
          else if (Slot.Item is TArtefact) and CacheDataRoot.FileExistsByPath('Bm.FormShop2.' + GiResourceSuffix + 'SlotArtefact') then
            SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotArtefact')
          else if (Slot.Item is TWeapon) and CacheDataRoot.FileExistsByPath('Bm.FormShop2.' + GiResourceSuffix + 'SlotWeapon' + LevelSuffix) then
            SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotWeapon' + LevelSuffix)
          else SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotLevel' + IntToWideString(TEquipment(Slot.Item).GetLevel));
          SetImageKindX(image_x_center);
          SetImageKindY(image_y_center);
        end;
      end;
      if Slot.Item <> nil then
      begin
        Slot.ItemIconImage := TImageGI.Create(Panel);
        with Slot.ItemIconImage do
        begin
          World := True;
          Pos := Classes.Point(Round(X * CellWidth), Round(Y * CellHeight));
          ObjectSize := Classes.Point(Trunc(CellWidth) - GiScalePixels(10), Trunc(CellHeight));
          PosZd := 2;
          IsActive := True;
          SetImagePath('GI,' + GetShopItemIconName(Slot.Item) + 'i');
          SetImageKindX(image_x_center);
          SetImageKindY(image_y_center);
          IsActive := True;
        end;
        if AnimItem then
        begin
          Slot.ItemAnimation := TgaiGI.Create(Panel);
          with Slot.ItemAnimation do
          begin
            World := True;
            Pos := Classes.Point(Round(X * CellWidth), Round(Y * CellHeight));
            ObjectSize := Classes.Point(Trunc(CellWidth) - GiScalePixels(10), Trunc(CellHeight));
            PosZd := 1;
            SetImagePath(GetShopItemIconName(Slot.Item) + 'a');
            SequenceIndex := 0;
            IsActive := False;
          end;
        end;
      end;
      if (Slot.Item <> nil) and TEquipment(Slot.Item).HasMicroModule and (Slot.Item.ItemType in [item_hull..item_custom_weapon]) then
      begin
        Slot.MicroModuleImage := TImageGI.Create(Panel);
        with Slot.MicroModuleImage do
        begin
          SetImagePath('GI,' + GetMicroModuleBitmapResourceName(TEquipment(Slot.Item).MicroModuleIndex - 1) + 'Set');
          World := True;
          Pos := Classes.Point(Round(X * CellWidth) + GiScalePixels(5), Round(Y * CellHeight) + GiScalePixels(45));
          ObjectSize := GetContentSize;
          PosZd := 0;
          SetImageKindX(image_x_center);
          SetImageKindY(image_y_center);
          IsActive := True;
        end;
      end;
    end;
  (Panel as TPanelScrollBarGI).UpdateScrollRanges;
  Panel.ScrollChangedCallback := PanelScrollChanged;
  TargetScrollX := 0;
  Panel.SetScrollOffset(Classes.Point(0, 0));
end;
{ @end $67F844 }

{ @routine $680650 TfEquipmentShop_ClearGoodsControls }
procedure TfEquipmentShop.ClearGoodsControls;
var
  Slot: TShopSlot;
  I, Count: Integer;
  Panel: TPanelGI;
  Child, Current: TObjectGI;
begin
  if TemporaryShopSlots <> nil then
  begin
    Count := TemporaryShopSlots.Count;
    for I := 0 to Count - 1 do
    begin
      Slot := TemporaryShopSlots[I];
      if Slot.SlotImage <> nil then begin Slot.SlotImage.Free; Slot.SlotImage := nil; end;
      if Slot.BorderImage <> nil then begin Slot.BorderImage.Free; Slot.BorderImage := nil; end;
      if Slot.TypeOverlayImage <> nil then begin Slot.TypeOverlayImage.Free; Slot.TypeOverlayImage := nil; end;
      if Slot.ItemIconImage <> nil then begin Slot.ItemIconImage.Free; Slot.ItemIconImage := nil; end;
      if Slot.ItemAnimation <> nil then begin Slot.ItemAnimation.Free; Slot.ItemAnimation := nil; end;
      if Slot.MicroModuleImage <> nil then begin Slot.MicroModuleImage.Free; Slot.MicroModuleImage := nil; end;
    end;
  end;
  Panel := GetByName('PanelGoods') as TPanelGI;
  Child := Panel.FirstChild;
  while Child <> nil do
  begin
    Current := Child;
    Child := Child.NextSibling;
    if Current.UserData = 1 then Current.Free;
  end;
end;
{ @end $680650 }

{ @routine $680748 TfEquipmentShop_EndTurnClicked }
procedure TfEquipmentShop.EndTurnClicked(Sender: TObjectGI);
begin
  if GetPlayer = nil then Exit;
  if GetPlayer.QueuedTravelTarget <> nil then Exit;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_dominion) and
    (GetPlayer.DockedTo.Order = order_teleport) and (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) and not GetPlayer.DockedTo.InHyperspace then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_dominion) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and
    ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_military_base) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and
    ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    if GetPlayer.Speed <= 0 then
    begin
      RuinsTalkScreen.DepartWithStation(1);
      Exit;
    end;
    StationPanel.TakeOffForStationTravel;
  end
  else
  begin
    RefreshItemInfo(nil);
    Galaxy.CheckIntegrityChecksum(192);
    RestoreTemporaryShopStock;
    MainPanel.EndTurnClicked(Sender);
    MainPanel.RebuildMessageButtons(False);
    if ExitCode = 0 then
    begin
      BuildTemporaryShopSlotGrid;
      Galaxy.PrimeIntegrityChecksum(193);
      ClearGoodsControls;
      BuildGoodsControls;
      UpdateScrollButtons;
      if OpenPreviewTimer <> 0 then
      begin
        CancelCallbackTimer(OpenPreviewTimer);
        OpenPreviewTimer := 0;
      end;
      if AnimItem then OpenPreviewTimer := ScheduleCallbackTimer(RandomIntRange(3000, 6000), 99999, ChooseAnimatedPreview);
    end;
  end;
end;
{ @end $680748 }

{ @routine $6809EC TfEquipmentShop_ShipClicked }
procedure TfEquipmentShop.ShipClicked(Sender: TObjectGI);
begin
  if ExitCode <> 0 then Exit;
  HideItemInfo(0, 0);
  Self.ShowCursor := False;
  Present;
  CaptureScreenBackground(True, 0);
  Self.ShowCursor := True;
  ShipScreen.PlayTransitionSounds := True;
  Galaxy.CheckIntegrityChecksum(194);
  while True do
  begin
    RunShipEquipment(Self);
    MainPanel.RefreshMoneyAndCargo;
    MainPanel.RebuildMessageButtons(False);
    ClearGoodsControls;
    BuildGoodsControls;
    UpdateScrollButtons;
    if not ShipScreen.ReopenRequested then Break;
    Self.ShowCursor := False;
    DrawQueuedUpdateRects;
    CaptureScreenBackground(True, 0);
    Self.ShowCursor := True;
  end;
  Galaxy.PrimeIntegrityChecksum(195);
  if GetPlayer.IsOnPlanet then
    if GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile then
    begin
      RequestedScreenId := screen_government;
      RequestClose(1);
    end;
end;
{ @end $6809EC }

{ @routine $680AFC TfEquipmentShop_UpdateScrollButtons }
procedure TfEquipmentShop.UpdateScrollButtons;
var Panel: TPanelGI;
begin
  Panel := GetByName('PanelGoods') as TPanelGI;
  with GetByName('Left') as TGraphButtonGI do SetDisabled(Panel.ScrollOffset.X <= 0);
  with GetByName('Right') as TGraphButtonGI do
    SetDisabled(Panel.ScrollOffset.X >= Round(Panel.ClientSize.X / ShopVisibleColumnCount * ContentColumnCount - Panel.ClientSize.X / ShopVisibleColumnCount * ShopVisibleColumnCount) - 1);
end;
{ @end $680AFC }

{ @routine $680BEC TfEquipmentShop_StartSlotAnimatedPreview }
procedure TfEquipmentShop.StartSlotAnimatedPreview(Slot: TShopSlot);
begin
  if Slot.ItemAnimation = nil then Exit;
  if not Slot.ItemAnimation.Active then
  begin
    Slot.ItemAnimation.UpdateAutoGeometry;
    Slot.ItemAnimation.SetImageKindX(image_x_center);
    Slot.ItemAnimation.SetImageKindY(image_y_center);
    Slot.ItemAnimation.SetActive(True);
  end;
  Slot.ItemAnimation.RestartPlayback;
  if Slot.ItemIconImage <> nil then
  begin
    Slot.ItemIconImage.Free;
    Slot.ItemIconImage := nil;
  end;
end;
{ @end $680BEC }

{ @routine $680C40 TfEquipmentShop_ScheduleSlotPreviewStop }
procedure TfEquipmentShop.ScheduleSlotPreviewStop(Slot: TShopSlot);
begin
  if Slot.ItemAnimation <> nil then Slot.ItemAnimation.CycleCompleteCallback := PreviewCycleComplete;
end;
{ @end $680C40 }

{ @routine $680C5C TfEquipmentShop_ItemMouseEnter }
procedure TfEquipmentShop.ItemMouseEnter(Sender: TObjectGI);
var
  Slot: TShopSlot;
  Panel: TObjectGI;
begin
  Slot := TShopSlot(Sender.UserValue);
  Slot.SlotImage.SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotA');
  Slot.SlotImage.SetImageKindX(image_x_center);
  Slot.SlotImage.SetImageKindY(image_y_center);
  StartSlotAnimatedPreview(Slot);
  Panel := GetByName('PanelShop');
  ItemInfoAnchor := Classes.Point(Sender.HitTestBounds.Left + Sender.ClientSize.X div 2, Min(Sender.HitTestBounds.Bottom, Panel.HitTestBounds.Bottom - Sender.ClientSize.Y - 24));
  RefreshItemInfo(Slot.Item);
  if not IsCursorImageSelected('Take') then SetCursorByName('Take');
end;
{ @end $680C5C }

{ @routine $680DD8 TfEquipmentShop_ItemMouseLeave }
procedure TfEquipmentShop.ItemMouseLeave(Sender: TObjectGI);
var Slot: TShopSlot;
begin
  Slot := TShopSlot(Sender.UserValue);
  Slot.SlotImage.SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotN');
  Slot.SlotImage.SetImageKindX(image_x_center);
  Slot.SlotImage.SetImageKindY(image_y_center);
  ScheduleSlotPreviewStop(Slot);
  RefreshItemInfo(nil);
  if not IsCursorImageSelected('Main') then SetCursorByName('Main');
end;
{ @end $680DD8 }

{ @routine $680ED8 TfEquipmentShop_ScrollLeft }
procedure TfEquipmentShop.ScrollLeft(Sender: TObjectGI);
var
  Panel: TPanelGI;
  Column: Integer;
begin
  Panel := GetByName('PanelGoods') as TPanelGI;
  Column := Round((Panel.ScrollOffset.X - Panel.ClientSize.X / ShopVisibleColumnCount) / (Panel.ClientSize.X / ShopVisibleColumnCount));
  if Column < 0 then Column := 0;
  TargetScrollX := Round(Panel.ClientSize.X / ShopVisibleColumnCount * Column);
  if (ScrollTimer = 0) and (TargetScrollX <> Panel.ScrollOffset.X) then ScrollTimer := ScheduleCallbackTimer(0, 20, ScrollTick);
  UpdateScrollButtons;
end;
{ @end $680ED8 }

{ @routine $680F98 TfEquipmentShop_ScrollRight }
procedure TfEquipmentShop.ScrollRight(Sender: TObjectGI);
var
  Panel: TPanelGI;
  Column: Integer;
begin
  Panel := GetByName('PanelGoods') as TPanelGI;
  Column := Round((Panel.ScrollOffset.X + Panel.ClientSize.X / ShopVisibleColumnCount) / (Panel.ClientSize.X / ShopVisibleColumnCount));
  if Column > ContentColumnCount - ShopVisibleColumnCount then Column := Max(ContentColumnCount - ShopVisibleColumnCount, 0);
  TargetScrollX := Round(Panel.ClientSize.X / ShopVisibleColumnCount * Column);
  if (ScrollTimer = 0) and (TargetScrollX <> Panel.ScrollOffset.X) then ScrollTimer := ScheduleCallbackTimer(0, 20, ScrollTick);
  UpdateScrollButtons;
end;
{ @end $680F98 }

{ @routine $68106C TfEquipmentShop_ScrollTick }
procedure TfEquipmentShop.ScrollTick(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Panel: TPanelGI;
begin
  Panel := GetByName('PanelGoods') as TPanelGI;
  if Panel.ScrollOffset.X = TargetScrollX then
  begin
    if ScrollTimer <> 0 then
    begin
      CancelCallbackTimer(ScrollTimer);
      ScrollTimer := 0;
    end;
  end
  else if TargetScrollX < Panel.ScrollOffset.X then Panel.SetScrollOffset(Classes.Point(Max(TargetScrollX, Panel.ScrollOffset.X - 12), 0))
  else Panel.SetScrollOffset(Classes.Point(Min(TargetScrollX, Panel.ScrollOffset.X + 12), 0));
  UpdateScrollButtons;
end;
{ @end $68106C }

{ @routine $68112C TfEquipmentShop_PanelScrollChanged }
procedure TfEquipmentShop.PanelScrollChanged(Sender: TObjectGI);
begin
  (GetByName('PanelGoods') as TPanelScrollBarGI).PanelScrollChanged(Sender);
  UpdateScrollButtons;
end;
{ @end $68112C }

{ @routine $681178 TfEquipmentShop_ItemMouseUp }
procedure TfEquipmentShop.ItemMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Slot: TShopSlot;
  Y, X, Cost: Integer;
  Event: TGalaxyEvent;
  PurchasedItem: TItem;
  Destination: Integer;
begin
  Slot := TShopSlot(Sender.UserValue);
  if (Slot <> nil) and (Slot.Item <> nil) then
  begin
    Galaxy.CheckIntegrityChecksum(198);
    Galaxy.PendingEquipmentPurchasePrice := Slot.Item.GetConditionAdjustedCost;
    GetPlayer.GetCargoFreeSpace;
    if (Slot.Item is THull) and (GetPlayer.Money < Galaxy.PendingEquipmentPurchasePrice) and
      (GetPlayer.GetHull.ScriptItem = nil) and (GetPlayer.GetHull.NoDropFlag = 0) then
      Galaxy.PendingEquipmentPurchasePrice := Max(1, Galaxy.PendingEquipmentPurchasePrice - GetPlayer.GetHull.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(skill_trading)));
    Galaxy.PrimeIntegrityChecksum(199);
    if GetPlayer.Money < Galaxy.PendingEquipmentPurchasePrice then
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      if Slot.Item is THull then
        ShowMessageBoxGI(Self, FormatText1(LanguageDataConfig.GetParamByPathOrMarker('FormShop.NoMoney'), TextHighlightColorTag, '<Money>', IntToWideString(Galaxy.PendingEquipmentPurchasePrice - GetPlayer.Money)), mbgCancel or mbgError);
      Galaxy.CheckIntegrityChecksum(309);
      MainPanel.FlashMoneyWarning;
      if not (Slot.Item is THull) and (GetPlayer.CargoFreeSpace < Slot.Item.Weight) then MainPanel.FlashCargoWarning;
      Galaxy.PrimeIntegrityChecksum(304);
    end
    else if not (Slot.Item is THull) and (GetPlayer.CargoFreeSpace < Slot.Item.Weight) then
    begin
      SoundManager.PlaySound('Sound.NoSize');
      MainPanel.FlashCargoWarning;
      Galaxy.PrimeIntegrityChecksum(305);
    end
    else
    begin
      if Slot.Item is THull then
      begin
        if GetPlayer.Money >= Slot.Item.GetConditionAdjustedCost then
        begin
          if ShowMessageBoxGI(Self, FormatText1(LanguageDataConfig.GetParamByPathOrMarker('FormShop.BuyHull'), TextHighlightColorTag, '<Money>', IntToWideString(Galaxy.PendingEquipmentPurchasePrice)), mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then Exit;
        end
        else
        begin
          if ShowMessageBoxGI(Self, FormatText1(LanguageDataConfig.GetParamByPathOrMarker('FormShop.UpgradeHull'), TextHighlightColorTag, '<Money>', IntToWideString(Galaxy.PendingEquipmentPurchasePrice)), mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then Exit;
        end;
      end
      else
      begin
        if ShowMessageBoxGI(Self, FormatText2(LanguageDataConfig.GetParamByPathOrMarker('FormShop.Buy'), TextHighlightColorTag, '<Item>', RemoveTextTagsW(Slot.Item.GetDisplayName), '<Money>', IntToWideString(Galaxy.PendingEquipmentPurchasePrice)), mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then Exit;
      end;
      SoundManager.PlaySound('Sound.Buy');
      Galaxy.CheckIntegrityChecksum(196);
      PurchasedItem := Slot.Item;
      Event := AddGalaxyEvent('PlayerBuysEquipment');
      Event.AddData(Ord(Slot.Item.ItemType));
      Event.AddData(Slot.Item.GetConditionAdjustedCost);
      Event.AddData(Slot.Item.Weight);
      Event.AddData(Slot.Item.Id);
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
      Event.AddTextData(Slot.Item.GetDisplayName);
      Event.AddTextData(Slot.Item.GetCategoryConfigName);
      if Slot.Item is THull then
      begin
        if GetPlayer.Money < Slot.Item.GetConditionAdjustedCost then
        begin
          Event := AddGalaxyEvent('PlayerSellsEquipment');
          Event.AddData(Ord(GetPlayer.GetHull.ItemType));
          Event.AddData(GetPlayer.GetHull.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(skill_trading)));
          Event.AddData(GetPlayer.GetHull.Weight);
          Event.AddData(GetPlayer.GetHull.Id);
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
          Event.AddTextData(GetPlayer.GetHull.GetDisplayName);
          Event.AddTextData(GetPlayer.GetHull.GetCategoryConfigName);
          GetPlayer.SetMoney(GetPlayer.Money - Galaxy.PendingEquipmentPurchasePrice);
          GetPlayer.ScriptItemsAct(event_player_change_hull, Slot.Item, GetPlayer.GetHull, 0);
          GetPlayer.Inventory.Delete(GetPlayer.Inventory.IndexOf(GetPlayer.GetHull));
          GetPlayer.GetHull.Free;
          GetPlayer.Inventory.Insert(0, Slot.Item);
          GetPlayer.Hull := Slot.Item as THull;
          GetPlayer.GetHull.OwnerShip := GetPlayer;
          GetPlayer.GetHull.AssignedSlotData := 0;
          if Slot.Item.ScriptItem <> nil then TScriptItem(Slot.Item.ScriptItem).RunActionCode(event_player_change_hull, GetPlayer, Slot.Item, nil, 0);
          Slot.Item := nil;
          GetPlayer.RefreshAssignedItemSlots;
          GetPlayer.RebuildEquipmentCache;
          GetPlayer.RefreshDerivedStats(True);
          if not GetPlayer.ScriptChameleon then
          begin
            ReleaseSpaceObject(GetPlayer.Graphic);
            GetPlayer.RefreshGraphic;
          end;
          Destination := Integer(GetPlayer);
        end
        else
        begin
          GetPlayer.SetMoney(GetPlayer.Money - Slot.Item.GetConditionAdjustedCost);
          if GetPlayer.IsOnPlanet then GetPlayer.AddItemToPlayerStorage(Slot.Item, GetPlayer.CurrentPlanet, -1)
          else GetPlayer.AddItemToPlayerStorage(Slot.Item, GetPlayer.DockedTo, -1);
          Slot.Item := nil;
          ShowMessageBoxGI(Self, LanguageDataConfig.GetParamByPathOrMarker('FormShop.AfterBuyHull'), mbgOK);
          if GetPlayer.CurrentPlanet <> nil then Destination := Integer(GetPlayer.CurrentPlanet)
          else Destination := Integer(GetPlayer.DockedTo);
        end;
      end
      else
      begin
        GetPlayer.SetMoney(GetPlayer.Money - Galaxy.PendingEquipmentPurchasePrice);
        TEquipment(Slot.Item).EquippedFlag := 0;
        if Slot.Item is TArtefact then GetPlayer.Artefacts.Add(Slot.Item)
        else GetPlayer.Inventory.Add(Slot.Item);
        Slot.Item := nil;
        Destination := Integer(GetPlayer);
      end;
      GetPlayer.ScriptItemsAct(event_player_buy_equipment, PurchasedItem, nil, Destination);
      GetPlayer.RefreshDerivedStats(True);
      Galaxy.PrimeIntegrityChecksum(197);
      with Slot.SlotImage do
      begin
        SetActive(False);
        MouseEnterCallback := nil;
        MouseLeaveCallback := nil;
        LeftButtonUpCallback := nil;
      end;
      with Slot.BorderImage do
      begin
        SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotBorderN');
        SetImageKindX(image_x_center);
        SetImageKindY(image_y_center);
      end;
      if Slot.TypeOverlayImage <> nil then begin Slot.TypeOverlayImage.Free; Slot.TypeOverlayImage := nil; end;
      if Slot.ItemIconImage <> nil then begin Slot.ItemIconImage.Free; Slot.ItemIconImage := nil; end;
      if Slot.ItemAnimation <> nil then begin Slot.ItemAnimation.Free; Slot.ItemAnimation := nil; end;
      if Slot.MicroModuleImage <> nil then begin Slot.MicroModuleImage.Free; Slot.MicroModuleImage := nil; end;
      RefreshItemInfo(nil);
      if not IsCursorImageSelected('Main') then SetCursorByName('Main');
      for Y := 0 to ShopGridRowCount - 1 do
        for X := 0 to ContentColumnCount - 1 do
        begin
          Slot := FindShopSlotByGridPoint(Classes.Point(X, Y));
          with Slot.BorderImage do
          begin
            if Slot.Item = nil then SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotBorderN')
            else
            begin
              Cost := Slot.Item.GetConditionAdjustedCost;
              if Slot.Item is THull then Cost := Max(1, Cost - GetPlayer.GetHull.CalculateResaleValue(GetPlayer.GetEffectiveSkillLevel(skill_trading)));
              if (GetPlayer.Money < Cost) or ((Slot.Item.ItemType <> item_hull) and (GetPlayer.CargoFreeSpace < Slot.Item.Weight)) then
                SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotBorderH')
              else SetImagePath('GI,Bm.FormShop2.' + GiResourceSuffix + 'SlotBorderN');
            end;
            SetImageKindX(image_x_center);
            SetImageKindY(image_y_center);
          end;
        end;
    end;
  end;
end;
{ @end $681178 }

{ @routine $681F64 TfEquipmentShop_ChooseAnimatedPreview }
procedure TfEquipmentShop.ChooseAnimatedPreview(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var
  I: Integer;
  Slot: TShopSlot;
  Attempts: Integer;
begin
  if TemporaryShopSlots.IndexOf(PreviewSlot) >= 0 then ScheduleSlotPreviewStop(PreviewSlot);
  PreviewSlot := nil;
  Attempts := 20;
  while Attempts > 0 do
  begin
    I := RandomIntRange(0, TemporaryShopSlots.Count - 1);
    Slot := TemporaryShopSlots[I];
    if Slot.Item <> nil then
    begin
      StartSlotAnimatedPreview(Slot);
      PreviewSlot := Slot;
      Break;
    end;
    Dec(Attempts);
  end;
  if OpenPreviewTimer <> 0 then
  begin
    CancelCallbackTimer(OpenPreviewTimer);
    OpenPreviewTimer := 0;
  end;
  if AnimItem then OpenPreviewTimer := ScheduleCallbackTimer(RandomIntRange(3000, 6000), 99999, ChooseAnimatedPreview);
end;
{ @end $681F64 }

{ @routine $68202C TfEquipmentShop_PreviewCycleComplete }
procedure TfEquipmentShop.PreviewCycleComplete(Sender: TObjectGI);
begin
  (Sender as TgaiGI).StopAutoPlayback;
end;
{ @end $68202C }

{ @routine $682044 TfEquipmentShop_HideItemInfo }
procedure TfEquipmentShop.HideItemInfo(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  if ItemInfoTimer <> 0 then
  begin
    CancelCallbackTimer(ItemInfoTimer);
    ItemInfoTimer := 0;
  end;
  GetByName('PII').SetActive(False);
  GetByName('InfoHull').SetActive(False);
  (GetByName('InfoText') as TLabelGI).Text := '';
  (GetByName('InfoSize') as TLabelGI).Text := '';
  (GetByName('InfoPrice') as TLabelGI).Text := '';
end;
{ @end $682044 }

{ @routine $682150 TfEquipmentShop_RefreshItemInfo }
procedure TfEquipmentShop.RefreshItemInfo(Item: TItem);
const
  DurableTypes = [Low(TItemType)..High(TItemType)] - [item_food..item_narcotics, item_custom_artefact_no_wear, artefact_transmitter..artefact_tranclucator, artefact_black_hole..artefact_artefactor, item_hull, item_nodes..item_fuel_container, item_treasure_map..item_stackable_misc];
var
  Equipment: TEquipment;
  Price: WideString;
  BarWidth, CapWidth, MinimumWidth: Integer;
begin
  Equipment := Item as TEquipment;
  if Equipment = nil then
  begin
    if ItemInfoTimer <> 0 then begin CancelCallbackTimer(ItemInfoTimer); ItemInfoTimer := 0; end;
    ItemInfoTimer := ScheduleCallbackTimer(100, 99999, HideItemInfo);
    MainPanel.HelpLabel.SetActive(False);
    MainPanel.SlideMessagesIn;
    if AnimItem then OpenPreviewTimer := ScheduleCallbackTimer(1000, 99999, ChooseAnimatedPreview);
  end
  else
  begin
    if OpenPreviewTimer <> 0 then begin CancelCallbackTimer(OpenPreviewTimer); OpenPreviewTimer := 0; end;
    if TemporaryShopSlots.IndexOf(PreviewSlot) >= 0 then ScheduleSlotPreviewStop(PreviewSlot);
    PreviewSlot := nil;
    if ItemInfoTimer <> 0 then begin CancelCallbackTimer(ItemInfoTimer); ItemInfoTimer := 0; end;
    with MainPanel.HelpLabel do
    begin
      SetActive(True);
      SetText(FormatText1(LookupLocalizedTextByKey('FormShop.BuyHelp'), InfoNameColorTag, '<Item>', Equipment.GetDisplayName));
    end;
    MainPanel.SlideMessagesOut;
    if Galaxy <> nil then
      if not Galaxy.Destroying then
        if GetPlayer <> nil then
        begin
          if GetPlayer.CurrentPlanet <> nil then
          begin
            if Item.ScriptItem <> nil then TScriptItem(Item.ScriptItem).RunActionCode(event_show_item_info, nil, GetPlayer.CurrentPlanet, nil, 0);
            if Item is TEquipmentWithActCode then RunItemConfigActionCode(Item, event_show_item_info, nil, GetPlayer.CurrentPlanet, nil, 0);
          end
          else
          begin
            if Item.ScriptItem <> nil then TScriptItem(Item.ScriptItem).RunActionCode(event_show_item_info, nil, GetPlayer.DockedTo, nil, 0);
            if Item is TEquipmentWithActCode then RunItemConfigActionCode(Item, event_show_item_info, nil, GetPlayer.DockedTo, nil, 0);
          end;
        end;
    if Item.ItemType = item_hull then
    begin
      RefreshHullInfo(Self, Item as THull, Equipment.GetInfoText(TextHighlightColorTag, nil), False);
      ItemInfoWindow.SetActive(False);
    end
    else
    begin
      ItemInfoWindow.SetActive(True);
      GetByName('InfoHull').SetActive(False);
      with GetByName('InfoImage') as TImageGI do
      begin
        ImageSourcePath := 'GI,' + GetShopItemIconName(Equipment) + 's';
        KindX := image_x_center;
        KindY := image_y_center;
        SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
      end;
      (GetByName('InfoName') as TLabelGI).Text := '';
      (GetByName('InfoName') as TLabelGI).Text := WrapTextInColor(Equipment.GetDisplayName, InfoNameColorTag);
      (GetByName('InfoText') as TLabelGI).Text := Equipment.GetInfoText(TextHighlightColorTag, nil);
      (GetByName('InfoSize') as TLabelGI).Text := IntToWideString(Equipment.Weight);
      Price := IntToWideString(Equipment.GetConditionAdjustedCost);
      if Equipment.GetConditionAdjustedCost < Equipment.Cost then Price := WrapTextInColor(Price, RedColorTag);
      (GetByName('InfoPrice') as TLabelGI).Text := Price;
      with GetByName('EmRace') as TImageGI do
      begin
        ImageSourcePath := GetFactionEmblemPath(Equipment.GetOwnerConfigName);
        KindX := image_x_center;
        KindY := image_y_center;
      end;
      if not (Equipment.ItemType in DurableTypes) and (Equipment.ItemType <> item_hull) then
      begin
        with GetByName('InfoDurable') as TImageGI do Parent.Parent.SetActive(False);
        MinimumWidth := 0;
      end
      else
      begin
        BarWidth := Min(192, Max(32, Round(64 / Max(0.1, Equipment.GetFragilityFactor([])))));
        with GetByName('InfoDurableLeft') as TImageGI do
        begin
          CapWidth := GetContentSize.X;
          MinimumWidth := 2 * CapWidth + BarWidth + LocalPosition.X + Parent.LocalPosition.X + 2 * Parent.Parent.LocalPosition.X;
        end;
        with GetByName('InfoDurable') as TImageGI do
        begin
          Parent.Parent.SetActive(True);
          Parent.Parent.SetSize(Classes.Point(2 * CapWidth + BarWidth, Parent.Parent.ClientSize.Y));
          Parent.SetSize(Classes.Point(BarWidth + 2, Parent.Parent.ClientSize.Y));
          if Equipment.ItemType = item_hull then
            SetPosition(Classes.Point(Round((Equipment as THull).HullPoints / (Equipment as THull).Weight * BarWidth) - (GetContentSize.X - 5), LocalPosition.Y))
          else SetPosition(Classes.Point(Round(BarWidth * (Equipment.ConditionPercent / 100)) - (GetContentSize.X - 5), LocalPosition.Y));
        end;
        with GetByName('InfoDurableRight') as TImageGI do
        begin
          SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X, LocalPosition.Y));
          Parent.SetPosition(Classes.Point(CapWidth, Parent.LocalPosition.Y));
          Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
        end;
        with GetByName('InfoDurableBack') as TImageGI do
        begin
          SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X, LocalPosition.Y));
          Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
        end;
      end;
      ShipScreen.LayoutItemInfo(ItemInfoWindow, GetByName('InfoName') as TLabelGI, GetByName('InfoText') as TLabelGI, True, True, MinimumWidth);
      GetByName('InfoSize').SetPosition(Classes.Point(ShipScreen.ItemSizeLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemSizeLabelPosition.Y));
      GetByName('InfoPrice').SetPosition(Classes.Point(ShipScreen.ItemPriceLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemPriceLabelPosition.Y));
      GetByName('EmRace').SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ShipScreen.ItemRaceImagePosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
      if DynamicTipsPos then ItemInfoWindow.SetPosition(Classes.Point(ItemInfoAnchor.X - ItemInfoWindow.ClientSize.X div 2, ItemInfoAnchor.Y))
      else ItemInfoWindow.SetPosition(Classes.Point(10, 10));
    end;
  end;
end;
{ @end $682150 }

{ @routine $682E30 TfEquipmentShop_BuildHullSlotOverlays }
procedure TfEquipmentShop.BuildHullSlotOverlays(Parent: TObjectGI; Hull: THull; OffsetX, OffsetY: Integer);
var
  Root: TObjectGI;
  I: Integer;

  // @nested $682D0C AddOverlay
  procedure AddOverlay(Name: WideString); // @addr $682D0C @calls "0x00682E77,0x00682E8F,0x00682EA9,0x00682EC3,0x00682EDD,0x00682EF7,0x00682F3A,0x00682F56,0x00682F6E,0x00682F86,0x00682F9E,0x00682FB6,0x00682FCE,0x00682FE6" @note "Nested in BuildHullSlotOverlays; captures root, parent and offsets."
  var
    Control: TObjectGI;
    Path: WideString;
    Graph: TGraphBufGI;
  begin
    Control := Root.FindByNameRecursive(Name);
    if Control <> nil then
    begin
      Graph := TGraphBufGI.Create(Parent, False);
      Graph.SetPositionModeW(True);
      Graph.SetPosition(Classes.Point(Control.LocalPosition.X + OffsetX, Control.LocalPosition.Y + OffsetY));
      Graph.SetSize(Control.ClientSize);
      Graph.SourceHasPerPixelAlpha := True;
      Path := (Control as TImageGI).GetImagePath;
      if CountDelimitedPartsW(Path, ',') = 2 then Path := ExtractDelimitedPartW(Path, 1, ',');
      LoadGiByPathIntoGraphBuf(Path, Graph.GraphBuf);
    end;
  end;

begin
  Root := GetByName('InfoHull');
  if Hull.GetSlotCount(slot_afterburner) >= 1 then AddOverlay('InfoHull_Forsage');
  if Hull.GetSlotCount(slot_weapon) < 1 then AddOverlay('InfoHull_W1');
  if Hull.GetSlotCount(slot_weapon) < 2 then AddOverlay('InfoHull_W2');
  if Hull.GetSlotCount(slot_weapon) < 3 then AddOverlay('InfoHull_W3');
  if Hull.GetSlotCount(slot_weapon) < 4 then AddOverlay('InfoHull_W4');
  if Hull.GetSlotCount(slot_weapon) < 5 then AddOverlay('InfoHull_W5');
  for I := 1 to DefaultHullSlotCounts[slot_artefact] do
    if Hull.GetSlotCount(slot_artefact) < I then AddOverlay('InfoHull_A' + IntToWideString(I));
  if Hull.GetSlotCount(slot_engine) < 1 then AddOverlay('InfoHull_Engine');
  if Hull.GetSlotCount(slot_fuel_tanks) < 1 then AddOverlay('InfoHull_FuelTanks');
  if Hull.GetSlotCount(slot_scanner) < 1 then AddOverlay('InfoHull_Scaner');
  if Hull.GetSlotCount(slot_radar) < 1 then AddOverlay('InfoHull_Radar');
  if Hull.GetSlotCount(slot_repair_robot) < 1 then AddOverlay('InfoHull_RepairRobot');
  if Hull.GetSlotCount(slot_cargo_hook) < 1 then AddOverlay('InfoHull_CargoHook');
  if Hull.GetSlotCount(slot_defense_generator) < 1 then AddOverlay('InfoHull_DefGenerator');
end;
{ @end $682E30 }

var
  ShopDominatorImagePrefixes: TDominatorSeriesNameTable = ('B', 'K', 'T'); // @addr $80F7EC

{ @routine $68323C TfEquipmentShop_RefreshHullInfo }
procedure TfEquipmentShop.RefreshHullInfo(Target: TMessageLoopGI; Hull: THull; Text: WideString; SuppressImage: Boolean);
var
  Window: TWindowGI;
  TextLabel: TLabelGI;
  Control: TObjectGI;
  I: Integer;
  PreviewPath, SeriesName: WideString;
  UnusedNativeLocal: array[0..7] of Byte; { Eight unreferenced frame bytes precede the managed temporaries; original local type is unknown. }
  HullKind: THullType; DisplayKind: TDominatorKind;
  Series: TDominatorSeries;
  BarWidth, CapWidth, MinimumWidth: Integer;
begin
  Window := Target.GetByName('InfoHull') as TWindowGI;
  TextLabel := Target.GetByName('InfoHullText') as TLabelGI;
  Window.SetActive(True);
  (Target.GetByName('InfoHullName') as TLabelGI).Text := WrapTextInColor(Hull.GetDisplayName, InfoNameColorTag);
  SeriesName := Hull.GetSeriesName;
  if SeriesName <> '' then SeriesName := #13#10 + WrapTextInColor(SeriesName, InfoHullSeriesColorTag);
  (Target.GetByName('InfoHullName') as TLabelGI).Text := (Target.GetByName('InfoHullName') as TLabelGI).Text + SeriesName;
  TextLabel.SetText(Text);
  Target.GetByName('InfoHull_Forsage').SetActive(Hull.GetSlotCount(slot_afterburner) >= 1);
  Target.GetByName('InfoHull_W1').SetActive(not (Hull.GetSlotCount(slot_weapon) >= 1));
  Target.GetByName('InfoHull_W2').SetActive(not (Hull.GetSlotCount(slot_weapon) >= 2));
  Target.GetByName('InfoHull_W3').SetActive(not (Hull.GetSlotCount(slot_weapon) >= 3));
  Target.GetByName('InfoHull_W4').SetActive(not (Hull.GetSlotCount(slot_weapon) >= 4));
  Target.GetByName('InfoHull_W5').SetActive(not (Hull.GetSlotCount(slot_weapon) >= 5));
  for I := 1 to DefaultHullSlotCounts[slot_artefact] do
  begin
    Control := Target.FindControlByPath('InfoHull_A' + IntToWideString(I));
    if Control <> nil then Control.SetActive(not (Hull.GetSlotCount(slot_artefact) >= I));
  end;
  Target.GetByName('InfoHull_Engine').SetActive(not (Hull.GetSlotCount(slot_engine) >= 1));
  Target.GetByName('InfoHull_FuelTanks').SetActive(not (Hull.GetSlotCount(slot_fuel_tanks) >= 1));
  Target.GetByName('InfoHull_Scaner').SetActive(not (Hull.GetSlotCount(slot_scanner) >= 1));
  Target.GetByName('InfoHull_Radar').SetActive(not (Hull.GetSlotCount(slot_radar) >= 1));
  Target.GetByName('InfoHull_RepairRobot').SetActive(not (Hull.GetSlotCount(slot_repair_robot) >= 1));
  Target.GetByName('InfoHull_CargoHook').SetActive(not (Hull.GetSlotCount(slot_cargo_hook) >= 1));
  Target.GetByName('InfoHull_DefGenerator').SetActive(not (Hull.GetSlotCount(slot_defense_generator) >= 1));
  DisplayKind := dominator_boss;
  Series := series_blazer;
  HullKind := Hull.HullType;
  if (Hull.OwnerShip <> nil) and (Hull.OwnerShip = GetPlayer) and GetPlayer.ChameleonActive and
    (GetPlayer.ChameleonVisualType in [Low(TDominatorKind)..High(TDominatorKind)]) and (GetPlayer.ChameleonVisualType <> dominator_boss) then
  begin
    HullKind := hull_dominator;
    DisplayKind := GetPlayer.ChameleonVisualType;
    Series := GetPlayer.ChameleonSeries;
  end;
  if (Hull.OwnerShip <> nil) and (Hull.OwnerShip is TKling) then
  begin
    HullKind := hull_dominator;
    DisplayKind := (Hull.OwnerShip as TKling).KlingType;
    Series := (Hull.OwnerShip as TKling).DominatorSeries;
  end;
  if not SuppressImage then
    with Target.GetByName('InfoHullImage') as TImageGI do
    begin
      if HullKind = hull_dominator then
      begin
        SetImagePath('GraphBuf');
        PreviewPath := '';
        if DisplayKind <> dominator_boss then PreviewPath := GameDataConfig.GetParamByPathOrMarker('SE.Ship.' + DominatorSeriesNames[Series] + '.' + ShopDominatorImagePrefixes[Series] + IntToWideString(Ord(DisplayKind)) + '.' + GiResourceSuffix + 'ImageP');
        if PreviewPath <> '' then
          with GraphBufControl do
          begin
            SourceHasPerPixelAlpha := True;
            LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(PreviewPath, 1, ','), GraphBuf);
            if GraphBuf.Width >= GraphBuf.Height then GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / GraphBuf.Width * GraphBuf.Height), 5)
            else GraphBuf.RescaleRgba(Round(ClientSize.Y / GraphBuf.Height * GraphBuf.Width), ClientSize.Y, 5);
          end
        else
          with GraphBufControl do
          begin
            SourceHasPerPixelAlpha := True;
            if DisplayKind = dominator_boss then
              case Series of
                series_terron: LoadGiByPathIntoGraphBuf('Bm.Ruins.Terroni', GraphBuf);
                series_keller: LoadGiByPathIntoGraphBuf('Bm.Ruins.Kelleri', GraphBuf);
                series_blazer: LoadGiByPathIntoGraphBuf('Bm.Ruins.Blazeri', GraphBuf);
              end;
            if GraphBuf.Width >= GraphBuf.Height then GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / GraphBuf.Width * GraphBuf.Height), 5)
            else GraphBuf.RescaleRgba(Round(ClientSize.Y / GraphBuf.Height * GraphBuf.Width), ClientSize.Y, 5);
          end;
      end
      else SetImagePath('GI,' + GetShopItemIconName(Hull) + 's');
      SetImageKindX(image_x_center);
      SetImageKindY(image_y_center);
      SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
    end;
  (Target.GetByName('InfoHullSize') as TLabelGI).Text := IntToWideString(Hull.Weight);
  (Target.GetByName('InfoHullPrice') as TLabelGI).Text := IntToWideString(Hull.GetConditionAdjustedCost);
  with Target.GetByName('InfoHullEmRace') as TImageGI do
  begin
    ImageSourcePath := GetFactionEmblemPath(Hull.GetOwnerConfigName);
    KindX := image_x_center;
    KindY := image_y_center;
  end;
  BarWidth := Round(Sqrt(Hull.Weight / HullBaseSize / Max(0.1, Hull.GetFragilityFactor([]))) * 64);
  BarWidth := Min(192, Max(32, BarWidth));
  with GetByName('InfoDurableLeft') as TImageGI do
  begin
    CapWidth := GetContentSize.X;
    MinimumWidth := 2 * CapWidth + BarWidth + LocalPosition.X + Parent.LocalPosition.X + 2 * Parent.Parent.LocalPosition.X;
  end;
  with Target.GetByName('InfoHullDurable') as TImageGI do
  begin
    Parent.Parent.SetSize(Classes.Point(2 * CapWidth + BarWidth, Parent.Parent.ClientSize.Y));
    Parent.SetSize(Classes.Point(BarWidth + 2, Parent.Parent.ClientSize.Y));
    SetPosition(Classes.Point(Round(Hull.HullPoints / Hull.Weight * BarWidth) - (GetContentSize.X - 5), LocalPosition.Y));
  end;
  with Target.GetByName('InfoHullDurableRight') as TImageGI do
  begin
    SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X, LocalPosition.Y));
    Parent.SetPosition(Classes.Point(CapWidth, Parent.LocalPosition.Y));
    Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
  end;
  with Target.GetByName('InfoHullDurableBack') as TImageGI do
  begin
    SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X, LocalPosition.Y));
    Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
  end;
  ShipScreen.LayoutItemInfo(Window, Target.GetByName('InfoHullName') as TLabelGI, TextLabel, False, True, MinimumWidth);
  Target.GetByName('InfoHullSize').SetPosition(Classes.Point(HullSizeOffset.X, Window.ClientSize.Y + HullSizeOffset.Y));
  Target.GetByName('InfoHullPrice').SetPosition(Classes.Point(HullPriceOffset.X, Window.ClientSize.Y + HullPriceOffset.Y));
  Target.GetByName('InfoHullEmRace').SetPosition(Classes.Point(Window.ClientSize.X + HullRaceOffset.X, Window.ClientSize.Y + HullRaceOffset.Y));
  if DynamicTipsPos then Window.SetPosition(Classes.Point(ItemInfoAnchor.X - Window.ClientSize.X div 2, ItemInfoAnchor.Y))
  else Window.SetPosition(Classes.Point(10, 10));
end;
{ @end $68323C }

{ @routine $6843A8 TfEquipmentShop_ProcessMouseWheel }
procedure TfEquipmentShop.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if (Delta = WHEEL_DELTA) and not (GetByName('Left') as TGraphButtonGI).Disabled then
  begin
    ScrollLeft(nil);
    RefreshItemInfo(nil);
  end
  else if (Delta = -WHEEL_DELTA) and not (GetByName('Right') as TGraphButtonGI).Disabled then
  begin
    ScrollRight(nil);
    RefreshItemInfo(nil);
  end;
end;
{ @end $6843A8 }

{ @routine $684448 TfEquipmentShop_MainPanelKeyDown }
procedure TfEquipmentShop.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) or (ExitCode <> 0) then Exit;
  if Key = Ord('S') then
  begin
    ShipClicked(nil);
    Exit;
  end;
  if ((Key = VK_LEFT) or (Key = VK_UP)) and not (GetByName('Left') as TGraphButtonGI).Disabled then
  begin
    ScrollLeft(nil);
    RefreshItemInfo(nil);
  end
  else if ((Key = VK_RIGHT) or (Key = VK_DOWN)) and not (GetByName('Right') as TGraphButtonGI).Disabled then
  begin
    ScrollRight(nil);
    RefreshItemInfo(nil);
  end
  else if Key = VK_SPACE then
  begin
    if GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
  end
  else
  begin
    MainPanel.ProcessKeyDown(Key);
    PlanetPanel.ProcessKeyDown(Key);
    StationPanel.ProcessKeyDown(Key);
  end;
end;
{ @end $684448 }

{ @routine $6845A8 TfEquipmentShop_ExecuteUiCode }
procedure TfEquipmentShop.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if MainPanel.NavigationLocked then Exit;
  if ExitScreenLoop then Exit;
  if TurnCalculationPhase in [turn_idle, turn_galaxy_finished, turn_player_star_finished, turn_player_star_prepared] then
  begin
    Galaxy.CheckIntegrityChecksum(10011);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20011);
  end;
end;
{ @end $6845A8 }

{ @routine $68460C TfEquipmentShop_SelectMusic }
procedure TfEquipmentShop.SelectMusic;
begin
  if (ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1) then Exit;
  if not MusicInPlanetEnabled then
  begin
    MusicManager.RequestFadeOut;
    Exit;
  end;
  if GetPlayer.IsOnPlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = owner_pirate then
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
    else if GetPlayer.DockedTo.TypeId in [station_pirate_base, station_dominion] then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end;
end;
{ @end $68460C }

end.
