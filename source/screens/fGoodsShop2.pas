unit fGoodsShop2;
// Unit bracket (inferred): .text 0x007D4AA8..0x007DC847; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types, aGalaxyStruct, GR_Sound, EC_BlockPar, GI_MessageLoop, fPanelLoad, fPanelMain, fPanelPlanet, fPanelRuins;

type
  TGoodsShopTradeRow = record // @size $10 Ship-to-ship market row; scalar layout is also consumed by the integrity checksum.
    Count: Integer; // @offset $00
    MaximumPrice: Single; // @offset $04
    PurchasePrice: Integer; // @offset $08
    BaseSalePrice: Integer; // @offset $0C
  end;

  TfGoodsShop2 = class(TMessageLoopGIWithMainPanel) // @size 0x194
  public
    PlanetPanel: TfPanelPlanet; // @offset 0xD4
    StationPanel: TfPanelRuins; // @offset 0xD8
    LoadPanel: TfPanelLoad; // @offset 0xDC
    DraggedGoodsIndex: Integer; // @offset $E0 -1 when no market/cargo row is being dragged.
    NameFaceHeight: Integer; // @offset $E4
    FaceCaptionHeight: Integer; // @offset $E8 Total original extent from name top to character-description bottom.
    ReopenRequested: Boolean; // @offset $EC Keeps the modal goods shop active for another pass after refreshing the parent background.

    TradeRows: array[0..7] of TGoodsShopTradeRow; // @offset $F0
    PartnerCargoLimit: Integer; // @offset $170 Trading partner cargo limit.
    PartnerMoneyLimit: Integer; // @offset $174 Trading partner money limit.

    MoneyWarningActive: Boolean; // @offset $178
    MoneyWarningTicks: Integer; // @offset $17C
    MoneyWarningTimer: PCallbackTimerGI; // @offset $180
    CargoWarningActive: Boolean; // @offset $184
    CargoWarningTicks: Integer; // @offset $188
    CargoWarningTimer: PCallbackTimerGI; // @offset $18C
    AmbientSound: TSoundBufferControl; // @offset $190

    procedure GoodsMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $7D8840
    procedure GoodsRightMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $7D965C
    procedure GoodsMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $7D96A8
    procedure GoodsMouseEnter(Sender: TObjectGI); // @addr $7DA088
    procedure GoodsMouseLeave(Sender: TObjectGI); // @addr $7DA0A4
    function GetMaximumTradeCount(Index: Integer; IgnoreCargoSpace: Boolean): Integer; // @addr $7DA0C0
    function GetAvailableGoodsCount(Index: Integer): Integer; // @addr $7DA24C
    procedure SavePricesClicked(Sender: TObjectGI); // @addr $7DB224
    procedure EndTurnClicked(Sender: TObjectGI); // @addr $7DB388
    procedure GalaxyClicked(Sender: TObjectGI); // @addr $7DB660
    procedure QuestClicked(Sender: TObjectGI); // @addr $7DB6A4
    procedure MenuClicked(Sender: TObjectGI); // @addr $7DB6E8
    procedure ShipClicked(Sender: TObjectGI); // @addr $7DB72C
    procedure FinishModalTrade; // @addr $7DB8AC
    procedure CaptureMerchantBackground(Sender: TObjectGI); // @addr $7DB8DC
    procedure MerchantAnimationComplete(Sender: TObjectGI); // @addr $7DBA1C
    procedure CloseClicked(Sender: TObjectGI); // @addr $7DBD18
    procedure RefreshMoneyWarning; // @addr $7DBD44
    procedure FlashMoneyWarning; // @addr $7DBE94
    procedure MoneyWarningTick(Timer: PCallbackTimerGI; UserData: Integer); // @addr $7DBF0C
    procedure RefreshCargoWarning; // @addr $7DBF70
    procedure FlashCargoWarning; // @addr $7DC0BC
    procedure CargoWarningTick(Timer: PCallbackTimerGI; UserData: Integer); // @addr $7DC134
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $7DC198
    procedure ShowControlHelp(Sender: TObjectGI; Visible: Boolean); // @addr $7DC358
    procedure ShowHelpText(Value: WideString; Visible: Boolean); // @addr $7DC400

    constructor Create; // @addr 0x7D4B44
    destructor Destroy; override; // @addr 0x7D4C14
    procedure OnOpen; override; // @addr 0x7D5474
    procedure RefreshGoodsDisplay; // @addr $7D725C Rebuilds cargo/market controls and prices for the current trading context.
    procedure OnClose; override; // @addr 0x7D70D0
    procedure ProcessCallbackTimers; override; // @addr 0x7DC4C0
    procedure SelectMusic; override; // @addr 0x7DC574
    procedure InitializeLayout; override; // @addr 0x7D4CC4
    procedure UpdateActionCursor(CanTake: Boolean); override; // @addr 0x7D9E14
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x7DC500
    function BuildPriceText(Location: TObject): WideString; // @addr $7DA2A0
  end;

function RunGoodsShop(ParentLoop: TMessageLoopGI): Boolean; // @addr $7DC7DC Native modal wrapper used while talking to another ship.

const
  ShopGoodsOrder: TGoodsTextOrder = (0, 1, 5, 4, 3, 2, 6, 7); // @addr $87CCFC Native unit-local copy of the goods presentation order.


implementation

uses GI_Panel, SE_Ruins, aRanger, GI_MessageBox, fCount2, EC_Str, EC_Mem, GI_GAI, fRuinsTalk, Classes, Math, Windows, GI_Main, GI_Image, GI_GraphButton, GI_GraphBuf, GI_Label, GR_GraphBuf, GR_Music, fStarMap, fShip2, Globals, GlobalsV, GR_Main, SysUtils, aGalaxy, aConst, aMyFunction, aPlanet, aPlayer, aRuins, aShip;

var
  OutOfStockColor: WideString; // @addr $88B100 Native style-derived out-of-stock price markup.

{ @routine $7D4B44 TfGoodsShop2_Create }
constructor TfGoodsShop2.Create;
begin
  inherited Create;
  PlanetPanel := TfPanelPlanet.Create;
  StationPanel := TfPanelRuins.Create;
  LoadPanel := TfPanelLoad.Create;
  AmbientSound := TSoundBufferControl.Create;
  AmbientSound.Configure('Sound.GoodsLoop', 0, True);
end;
{ @end $7D4B44 }

{ @routine $7D4C14 TfGoodsShop2_Destroy }
destructor TfGoodsShop2.Destroy;
begin
  if PlanetPanel <> nil then begin PlanetPanel.Free; PlanetPanel := nil; end;
  if StationPanel <> nil then begin StationPanel.Free; StationPanel := nil; end;
  if LoadPanel <> nil then begin LoadPanel.Free; LoadPanel := nil; end;
  AmbientSound.Free;
  inherited Destroy;
end;
{ @end $7D4C14 }

{ @routine $7D4CC4 TfGoodsShop2_InitializeLayout }
procedure TfGoodsShop2.InitializeLayout;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  PlanetPanel.InitializeLayout(Self);
  StationPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  SetHelpCallback(ShowControlHelp);
  AppendLogTextThreadSafe('fGoodsShop2... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGCity2').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGCity').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('ADD_WarningSpace') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('ADD_WarningMoney') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('ADD_Space') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('ADD_Money') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('GS_Help') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('GoodsPanel') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    FindByNameRecursive('BGShrLight').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  end;
  AppendLogLineThreadSafe('ok');
  (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
  (GetByName('PM_Ship') as TGraphButtonGI).UpCallback := ShipClicked;
  (GetByName('PM_Gal') as TGraphButtonGI).UpCallback := GalaxyClicked;
  (GetByName('PM_Quest') as TGraphButtonGI).UpCallback := QuestClicked;
  (GetByName('PM_Logo') as TGraphButtonGI).UpCallback := MenuClicked;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  GetByName('MainPanel').MouseMoveCallback := GoodsMouseMove;
  GetByName('MainPanel').LeftButtonUpCallback := GoodsMouseUp;
  GetByName('MainPanel').RightButtonDownCallback := GoodsRightMouseDown;
  (GetByName('UserMsgAdd') as TGraphButtonGI).UpCallback := SavePricesClicked;
  NameFaceHeight := (GetByName('NameFace') as TLabelGI).ClientSize.Y;
  FaceCaptionHeight := (GetByName('CharFace') as TLabelGI).LocalPosition.Y + (GetByName('CharFace') as TLabelGI).ClientSize.Y - (GetByName('NameFace') as TLabelGI).LocalPosition.Y;
  OutOfStockColor := GetStyleColorTagGI('GoodsShop.GoodsColorOutOfStock', 127, 127, 127);
end;
{ @end $7D4CC4 }

{ @routine $7D5474 TfGoodsShop2_OnOpen }
procedure TfGoodsShop2.OnOpen;
var
  I: Integer;
  BackgroundPath: WideString;
  UnusedNativeLocal: array[0..3] of Byte; { Unreferenced native storage; original type is unknown. }
begin
  if not ReopenRequested then LoadPanel.OnOpen;
  if not MusicInPlanetEnabled then MusicManager.RequestFadeOut;
  if GetPlayer.IsOnPlanet or GetPlayer.IsDockedToShip then
  begin
    MainPanel.Show;
    MainPanel.OnOpen;
  end
  else MainPanel.Hide;
  for I := 0 to 17 do
    if (I <> 8) and (I <> 9) then
    begin
      with GetByName('TovCnt' + IntToStr(I)) as TLabelGI do
      begin
        if FontDialog = 0 then SetFontName(NormalFontName)
        else if FontDialog = 1 then SetFontName(SmoothBigFontName)
        else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
        else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
      end;
      with GetByName('TovPrice' + IntToStr(I)) as TLabelGI do
      begin
        if FontDialog = 0 then SetFontName(NormalFontName)
        else if FontDialog = 1 then SetFontName(SmoothBigFontName)
        else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
        else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
      end;
    end;
  GetByName('GS_Help').SetActive(False);
  (GetByName('UserMsgAdd') as TGraphButtonGI).SetDisabled(False);
  with GetByName('ButFormClose') as TGraphButtonGI do
    if GetPlayer.IsOnPlanet then UpCallback := PlanetPanel.PlanetClicked
    else if GetPlayer.IsDockedToShip then UpCallback := StationPanel.ServicesClicked
    else UpCallback := CloseClicked;
  DraggedGoodsIndex := -1;
  (GetByName('NameFace') as TLabelGI).SetSize(Classes.Point((GetByName('NameFace') as TLabelGI).ClientSize.X, NameFaceHeight));
  GetByName('GraphBufFace').SetActive(False);
  GetByName('CloseLine').SetActive(False);
  if GetPlayer.IsOnPlanet then
  begin
    (GetByName('NameFace') as TLabelGI).SetText(GetPlayer.CurrentPlanet.GetFullName(#13#10));
    if GetPlayer.CurrentPlanet.IsMainPiratePlanet then (GetByName('CharFace') as TLabelGI).SetText('')
    else (GetByName('CharFace') as TLabelGI).SetText(PlanetEconomyInfo[Ord(GetPlayer.CurrentPlanet.Economy)].ShortDisplayName + #13#10 + PlanetGovernmentMarket[Ord(GetPlayer.CurrentPlanet.Government)].DisplayName);
    (GetByName('ImageFace') as TImageGI).SetImagePath('GI,Bm.FormGoods2.' + GiResourceSuffix + 'PlanetL');
    with GetByName('GraphBufFace') as TGraphBufGI do
    begin
      SetActive(True);
      SourceHasPerPixelAlpha := True;
      GetPlayer.CurrentPlanet.Graphic.RenderToBuffer(Self, GraphBuf, False);
      GraphBuf.RescaleBilinearRgba(ClientSize.X, ClientSize.Y);
    end;
  end
  else if GetPlayer.IsDockedToShip then
  begin
    (GetByName('NameFace') as TLabelGI).SetText(GetPlayer.DockedTo.GetFullName(#13#10));
    (GetByName('CharFace') as TLabelGI).SetText('');
    GetByName('CloseLine').SetActive(True);
    (GetByName('NameFace') as TLabelGI).SetSize(Classes.Point((GetByName('NameFace') as TLabelGI).ClientSize.X, FaceCaptionHeight));
    (GetByName('ImageFace') as TImageGI).SetImagePath('GI,Bm.FormGoods2.' + GiResourceSuffix + 'AllL');
    with GetByName('GraphBufFace') as TGraphBufGI do
    begin
      SetActive(True);
      SourceHasPerPixelAlpha := True;
      if GetPlayer.DockedTo.Graphic is TRuinsSE then
        LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((GetPlayer.DockedTo.Graphic as TRuinsSE).StaticImagePath, 1, ','), GraphBuf)
      else LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(GetPlayer.DockedTo.GetShipPortraitImagePath, 1, ','), GraphBuf);
      if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
        GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
      else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
    end;
  end
  else if GetPlayer.InNormalSpace then
  begin
    if TalkShip is TRanger then
    begin
      (GetByName('NameFace') as TLabelGI).SetText(TalkShip.GetFullName(#13#10));
      (GetByName('CharFace') as TLabelGI).SetText((TalkShip as TRanger).GetCharacterName);
    end
    else
    begin
      (GetByName('NameFace') as TLabelGI).SetText(TalkShip.GetFullName(#13#10));
      (GetByName('CharFace') as TLabelGI).SetText('');
      GetByName('CloseLine').SetActive(True);
      (GetByName('NameFace') as TLabelGI).SetSize(Classes.Point((GetByName('NameFace') as TLabelGI).ClientSize.X, FaceCaptionHeight));
    end;
    (GetByName('ImageFace') as TImageGI).SetImagePath('GI,Bm.FormGoods2.' + GiResourceSuffix + 'AllL');
    with GetByName('GraphBufFace') as TGraphBufGI do
    begin
      SetActive(True);
      SourceHasPerPixelAlpha := True;
      if TalkShip.Graphic is TRuinsSE then
        LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((TalkShip.Graphic as TRuinsSE).StaticImagePath, 1, ','), GraphBuf)
      else LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TalkShip.GetShipPortraitImagePath, 1, ','), GraphBuf);
      if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
        GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
      else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
    end;
  end;
  if ReopenRequested then
  begin
    with GetByName('FaceA') as TgaiGI do
    begin
      SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
      RestartPlayback;
    end;
    with GetByName('CaptainA') as TgaiGI do RestartPlayback;
  end
  else
  begin
    if GetPlayer.IsOnPlanet then
    begin
      with GetByName('FaceI') as TImageGI do
      begin
        SetImagePath('GI,Bm.Captain.' + GiResourceSuffix + 'ShopBot1i');
        SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
        SetActive(True);
      end;
      with GetByName('FaceA') as TgaiGI do
      begin
        FirstFrameOnly := not AnimCaptain;
        SetImagePath('Bm.Captain.' + GiResourceSuffix + 'ShopBot1a');
        SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
        SequenceIndex := 0;
        UpdateAutoGeometry;
        SetSequenceFrame(RandomIntRange(0, SequenceFrameCount - 1));
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
        SetActive(True);
        RestartPlayback;
        UserValue := 1;
        CycleCompleteCallback := MerchantAnimationComplete;
      end;
    end
    else if GetPlayer.IsDockedToShip then
    begin
      with GetByName('FaceI') as TImageGI do
      begin
        SetImagePath('GI,Bm.Captain.' + GiResourceSuffix + 'ShopBot1i');
        SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
        SetActive(True);
      end;
      with GetByName('FaceA') as TgaiGI do
      begin
        FirstFrameOnly := not AnimCaptain;
        SetImagePath('Bm.Captain.' + GiResourceSuffix + 'ShopBot1a');
        SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
        SequenceIndex := 0;
        UpdateAutoGeometry;
        SetSequenceFrame(RandomIntRange(0, SequenceFrameCount - 1));
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
        SetActive(True);
        RestartPlayback;
        UserValue := 1;
        CycleCompleteCallback := MerchantAnimationComplete;
      end;
    end
    else if GetPlayer.InNormalSpace then
    begin
    with GetByName('FaceI') as TImageGI do
    begin
      SetImagePath('GI,' + TalkShip.GetCaptainPortraitResourceBase + 'i');
      SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end;
    with GetByName('FaceA') as TgaiGI do
    begin
      FirstFrameOnly := not AnimCaptain;
      SetImagePath(TalkShip.GetCaptainPortraitResourceBase + 'a');
      SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetSequenceFrame(RandomIntRange(0, SequenceFrameCount - 1));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
      RestartPlayback;
      CycleCompleteCallback := nil;
    end;
    end;
    with GetByName('FaceA') as TgaiGI do FrameAdvancedCallback := CaptureMerchantBackground;
    GetByName('FaceGB').SetActive(False);
    with GetByName('CaptainI') as TImageGI do
    begin
      SetImagePath('GI,' + GetPlayer.GetCaptainPortraitResourceBase + 'i');
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end;
    with GetByName('CaptainA') as TgaiGI do
    begin
      FirstFrameOnly := not AnimCaptain;
      SetImagePath(GetPlayer.GetCaptainPortraitResourceBase + 'a');
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
      RestartPlayback;
    end;
    (GetByName('NameCaptain') as TLabelGI).SetText(GetPlayer.GetFullName(#13#10));
    (GetByName('CharCaptain') as TLabelGI).SetText(GetPlayer.GetCharacterName);
  end;
  (GetByName('ImageCaptain') as TImageGI).SetImagePath('GI,Bm.FormGoods2.' + GiResourceSuffix + 'AllR');
    with GetByName('GraphBufCaptain') as TGraphBufGI do
    begin
      SetActive(True);
      SourceHasPerPixelAlpha := True;
      if GetPlayer.Graphic is TRuinsSE then
        LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((GetPlayer.Graphic as TRuinsSE).StaticImagePath, 1, ','), GraphBuf)
      else LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(GetPlayer.GetShipPortraitImagePath, 1, ','), GraphBuf);
      if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
        GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
      else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
    end;
  if GetPlayer.IsOnPlanet then
  begin
    PlanetPanel.OnOpen;
    PlanetPanel.Show;
    StationPanel.Hide;
  end
  else if GetPlayer.IsDockedToShip then
  begin
    PlanetPanel.Hide;
    StationPanel.OnOpen;
    StationPanel.Show;
  end
  else
  begin
    PlanetPanel.Hide;
    StationPanel.Hide;
  end;
  with GetByName('BGCity2') as TImageGI do
  begin
    SetActive(GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstMilitaryBase)));
    if Active then
    begin
      SetImagePath('GAI,' + GetPlayer.CurrentStar.GetBackgroundImagePath(I));
      GaiImageControl.LoadFrameSequenceFromText('[50,0-0]');
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
    end;
  end;
  with GetByName('BGCity') as TImageGI do
    if GetPlayer.IsOnPlanet then
    begin
      SetActive(True);
      (FindByNameRecursive('BGCity') as TImageGI).SetImagePath(GetPlayer.CurrentPlanet.GetGovernmentBackgroundGraph);
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
  with GetByName('BGBuf') as TGraphBufGI do
    if GetPlayer.InNormalSpace then
    begin
      if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True, 0);
      BindExternalGraphBuf(AuxRenderBuffer);
      SetActive(True);
    end
    else SetActive(False);
  GetByName('BGShrLight').SetActive(GetPlayer.InNormalSpace and not BackgroundShade);
  MainPanel.RebuildMessageButtons(False);
  RefreshGoodsDisplay;
  CaptureMerchantBackground(nil);
  MoneyWarningActive := False;
  CargoWarningActive := False;
  RefreshMoneyWarning;
  RefreshCargoWarning;
  ReopenRequested := False;
  AmbientSound.SetVolume(1);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm, nil, nil, 0);
  if not GetPlayer.InNormalSpace then Galaxy.PrimeIntegrityChecksum(134);
end;
{ @end $7D5474 }

{ @routine $7D70D0 TfGoodsShop2_OnClose }
procedure TfGoodsShop2.OnClose;
begin
  if GetPlayer <> nil then
    if not GetPlayer.InNormalSpace then Galaxy.CheckIntegrityChecksum(135);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm, nil, nil, 0);
  LoadPanel.OnClose;
  if MoneyWarningTimer <> nil then
  begin
    CancelCallbackTimer(MoneyWarningTimer);
    MoneyWarningTimer := nil;
  end;
  if CargoWarningTimer <> nil then
  begin
    CancelCallbackTimer(CargoWarningTimer);
    CargoWarningTimer := nil;
  end;
  if GetPlayer <> nil then
    if GetPlayer.IsOnPlanet or GetPlayer.IsDockedToShip then MainPanel.OnClose;
  (GetByName('GraphBufFace') as TGraphBufGI).GraphBuf.Clear;
  if (GetPlayer <> nil) and GetPlayer.IsOnPlanet then PlanetPanel.OnClose
  else if GetPlayer <> nil then
    if GetPlayer.IsDockedToShip then StationPanel.OnClose;
  if not ReopenRequested then AmbientSound.SetVolume(0);
end;
{ @end $7D70D0 }

{ @routine $7D725C TfGoodsShop2_RefreshGoodsDisplay }
procedure TfGoodsShop2.RefreshGoodsDisplay;
var
  Good: Byte;
  I, J, IconCount, SellPrice, OldCost: Integer;
  Panel: TPanelGI;
  Image: TImageGI;
  ImageName, Color: WideString;
  Location: TObject;
begin
  if GetPlayer.InNormalSpace then
  begin
    for Good := 0 to 7 do
    begin
      TradeRows[Good].Count := TalkShip.CargoGoods[Good].Count;
      TradeRows[Good].MaximumPrice := GoodsMarket[Good].MaxPrice;
      if TalkShip.CargoGoods[Good].Count <= 0 then
      begin
        TradeRows[Good].PurchasePrice := Round(Max(GoodsMarket[Good].AveragePrice * 1.1, 0));
        TradeRows[Good].BaseSalePrice := Round(Max(GoodsMarket[Good].MinPrice, 0));
      end
      else
      begin
        TradeRows[Good].PurchasePrice := Round(Max(GoodsMarket[Good].AveragePrice * 1.1, TalkShip.CargoGoods[Good].TotalCost / TalkShip.CargoGoods[Good].Count * 1.3));
        TradeRows[Good].BaseSalePrice := Round(Max(GoodsMarket[Good].MinPrice, TalkShip.CargoGoods[Good].TotalCost / TalkShip.CargoGoods[Good].Count * 0.7));
      end;
    end;
    PartnerCargoLimit := TalkShip.GetCargoFreeSpace - TalkShip.GetDesiredCargoFreeSpace;
    PartnerMoneyLimit := TalkShip.Money;
  end;
  with GetByName('DownLeft') do SetActive((DraggedGoodsIndex >= 10) and (DraggedGoodsIndex < 20));
  with GetByName('DownRight') do SetActive((DraggedGoodsIndex >= 0) and (DraggedGoodsIndex < 10));
  for I := 0 to 7 do
  begin
    Good := ShopGoodsOrder[I];
    with GetByName('Tov' + IntToStr(I)) as TGraphButtonGI do
    begin
      MouseEnterCallback := GoodsMouseEnter;
      MouseLeaveCallback := GoodsMouseLeave;
      SetDisabled((((DraggedGoodsIndex >= 10) and (DraggedGoodsIndex < 20)) or (GetPlayer.GetLocationGoodsEntry(ShopGoodsOrder[I]).Count <= 0)) and
        ((DraggedGoodsIndex < 10) or (DraggedGoodsIndex >= 20) or (DraggedGoodsIndex mod 10 <> I)));
    end;
    with GetByName('Tov' + IntToStr(I + 10)) as TGraphButtonGI do
    begin
      MouseEnterCallback := GoodsMouseEnter;
      MouseLeaveCallback := GoodsMouseLeave;
      SetDisabled((((DraggedGoodsIndex >= 0) and (DraggedGoodsIndex < 10)) or (GetPlayer.CargoGoods[ShopGoodsOrder[I]].Count <= 0)) and
        ((DraggedGoodsIndex < 0) or (DraggedGoodsIndex >= 10) or (DraggedGoodsIndex mod 10 <> I)));
    end;
    GetByName('TovPermit' + IntToStr(I + 1)).SetActive(GetPlayer.IsCargoGoodIllegalOnCurrentPlanet(ShopGoodsOrder[I]));
    GetByName('TovPermit' + IntToStr(I + 10 + 1)).SetActive(GetByName('TovPermit' + IntToStr(I + 1)).Active);
    Panel := GetByName('TovCool' + IntToStr(I + 1)) as TPanelGI;
    Panel.Invalidate;
    Panel.FreeOwnedChildren;
    if GetPlayer.GetLocationGoodsEntry(Good).Count <= 0 then IconCount := 0
    else IconCount := Round(RemapClamped(Galaxy.GetGoodsPricePercent(Good, GetPlayer.ShopGoodsPurchasePrice(Good, nil)), 0, 30, 3, 0));
    ImageName := 'Good';
    for J := 0 to IconCount - 1 do
    begin
      Image := TImageGI.Create(Panel);
      Image.SetImagePath('GI,Bm.FormGoods2.' + GiResourceSuffix + ImageName);
      Image.SetSize(Image.GetContentSize);
      Image.SetPosition(Classes.Point(Panel.ClientSize.X - (Image.ClientSize.X + 1) * (J + 1), 0));
    end;
    Panel := GetByName('TovCool' + IntToStr(I + 10 + 1)) as TPanelGI;
    Panel.Invalidate;
    Panel.FreeOwnedChildren;
    OldCost := Round(GetPlayer.GetAverageCargoCost(Good));
    SellPrice := GetPlayer.ShopGoodsSellPrice(Good, nil);
    if GetPlayer.CargoGoods[Good].Count > 0 then
    begin
      if SellPrice > OldCost then IconCount := 1 else IconCount := 0;
    end
    else IconCount := 0;
    ImageName := 'Good';
    for J := 0 to IconCount - 1 do
    begin
      Image := TImageGI.Create(Panel);
      Image.SetImagePath('GI,Bm.FormGoods2.' + GiResourceSuffix + ImageName);
      Image.SetSize(Image.GetContentSize);
      Image.SetPosition(Classes.Point(Panel.ClientSize.X - (Image.ClientSize.X + 1) * (J + 1), 0));
    end;
  end;
  for I := 0 to 7 do
  begin
    Good := ShopGoodsOrder[I];
    Panel := GetByName('TovImgCnt' + IntToStr(I)) as TPanelGI;
    Panel.FreeOwnedChildren;
    Panel.Invalidate;
    IconCount := Round(GetPlayer.GetLocationGoodsEntry(Good).Count / GoodsMarket[Good].BaseStock * 6);
    if (IconCount <= 0) and (GetPlayer.GetLocationGoodsEntry(Good).Count >= 1) then IconCount := 1
    else if IconCount > 6 then IconCount := 6;
    for J := 0 to IconCount - 1 do
    begin
      Image := TImageGI.Create(Panel);
      Image.SetImagePath('GI,Bm.FormGoods2.' + GiResourceSuffix + 'Goods' + IntToStr(I + 1));
      if I in [2, 4, 5, 6] then Image.SetPosition(Classes.Point(J * GiScalePixels(12), 0))
      else Image.SetPosition(Classes.Point(J * GiScalePixels(11), 0));
      Image.SetDepth(J);
      Image.SetSize(Image.GetContentSize);
    end;
    Color := '';
    if GetPlayer.GetLocationGoodsEntry(Good).Count < 0 then RaiseWideMessage('Player.ShopGoods(it).Cnt<0')
    else if GetPlayer.GetLocationGoodsEntry(Good).Count = 0 then Color := OutOfStockColor;
    { Native writes this sell-price label once with the market color, then again with the cargo color below. }
    (GetByName('TovPrice' + IntToStr(I + 10)) as TLabelGI).SetText(WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good, nil)), Color));
    (GetByName('TovCnt' + IntToStr(I)) as TLabelGI).SetText(WrapTextInColor(IntToStr(GetPlayer.GetLocationGoodsEntry(Good).Count), Color));
    (GetByName('TovPrice' + IntToStr(I)) as TLabelGI).SetText(WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, nil)), Color));
    Panel := GetByName('TovImgCnt' + IntToStr(I + 10)) as TPanelGI;
    Panel.FreeOwnedChildren;
    IconCount := Round(GetPlayer.CargoGoods[Good].Count / GoodsMarket[Good].BaseStock * 6);
    if (IconCount <= 0) and (GetPlayer.CargoGoods[Good].Count >= 1) then IconCount := 1
    else if IconCount > 6 then IconCount := 6;
    for J := 0 to IconCount - 1 do
    begin
      Image := TImageGI.Create(Panel);
      Image.SetImagePath('GI,Bm.FormGoods2.' + GiResourceSuffix + 'Goods' + IntToStr(I + 1));
      { Unlike the market row, native cargo-icon spacing does not use GiScalePixels. }
      if I in [4, 5, 6] then Image.SetPosition(Classes.Point(J * 12, 0))
      else Image.SetPosition(Classes.Point(J * 11, 0));
      Image.SetDepth(J);
      Image.SetSize(Image.GetContentSize);
    end;
    Color := '';
    if GetPlayer.CargoGoods[Good].Count < 0 then RaiseWideMessage('Player.FGoods[it].Cnt<0')
    else if GetPlayer.CargoGoods[Good].Count = 0 then Color := OutOfStockColor;
    (GetByName('TovCnt' + IntToStr(I + 10)) as TLabelGI).SetText(WrapTextInColor(IntToStr(GetPlayer.CargoGoods[Good].Count), Color));
    (GetByName('TovPrice' + IntToStr(I + 10)) as TLabelGI).SetText(WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good, nil)), Color));
  end;
  if GetPlayer.IsOnPlanet then Location := GetPlayer.CurrentPlanet
  else if GetPlayer.IsDockedToShip then Location := GetPlayer.DockedTo
  else if GetPlayer.InNormalSpace then Location := TalkShip
  else Location := nil;
  with GetByName('UserMsgAdd') as TGraphButtonGI do
    if GetPlayer.InNormalSpace then SetDisabled(True)
    else SetDisabled(FindPlayerBubbleByText(BuildPriceText(Location), False) <> nil);
end;
{ @end $7D725C }

{ @routine $7D8840 TfGoodsShop2_GoodsMouseUp }
procedure TfGoodsShop2.GoodsMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  I, Index, Count, Price, Maximum, TotalLimit, Available, Limit: Integer;
  OverMarket, OverCargo: Boolean;
  Description: WideString;
begin
  OverMarket := False;
  OverCargo := False;
  if (GetByName('DownLeft') as TImageGI).HitTestPixel(Point) then OverMarket := True
  else if (GetByName('DownRight') as TImageGI).HitTestPixel(Point) then OverCargo := True
  else
  begin
    if DraggedGoodsIndex >= 0 then
    begin
      DraggedGoodsIndex := -1;
      UpdateActionCursor(False);
      RefreshGoodsDisplay;
    end;
    Exit;
  end;
  Index := -1;
  for I := 0 to 7 do
  begin
    with GetByName('Tov' + IntToStr(I)) as TGraphButtonGI do
      if ContainsPoint(GetCursorPoint) then begin Index := I; Break; end;
    with GetByName('Tov' + IntToStr(I + 10)) as TGraphButtonGI do
      if ContainsPoint(GetCursorPoint) then begin Index := I + 10; Break; end;
  end;
  if (Index < 0) and ((DraggedGoodsIndex < 0) or
    (OverMarket and (DraggedGoodsIndex >= 0) and (DraggedGoodsIndex < 10)) or
    (OverCargo and (DraggedGoodsIndex >= 10) and (DraggedGoodsIndex < 20))) then
  begin
    DraggedGoodsIndex := -1;
    UpdateActionCursor(False);
    RefreshGoodsDisplay;
  end
  else if (DraggedGoodsIndex < 0) or
    ((DraggedGoodsIndex >= 0) and (DraggedGoodsIndex < 10) and (Index >= 0) and (Index < 10)) or
    ((DraggedGoodsIndex >= 10) and (DraggedGoodsIndex < 20) and (Index >= 10) and (Index < 20)) then
  begin
    if Index = DraggedGoodsIndex then DraggedGoodsIndex := -1
    else if GetAvailableGoodsCount(Index) > 0 then DraggedGoodsIndex := Index;
    UpdateActionCursor(False);
    RefreshGoodsDisplay;
    with GetByName('Tov' + IntToStr(Index)) as TGraphButtonGI do
    begin
      SetDown(False);
      SetHovered(False);
      SetHovered(True);
    end;
  end;
  if DraggedGoodsIndex >= 0 then
  begin
    Count := GetMaximumTradeCount(DraggedGoodsIndex, False);
    if (Count <= 0) and ((DraggedGoodsIndex >= 10) or GetPlayer.InNormalSpace or
      (GetMaximumTradeCount(DraggedGoodsIndex, True) <= 0)) then
    begin
      if GetPlayer.InNormalSpace then
      begin
        if (DraggedGoodsIndex >= 10) and (DraggedGoodsIndex < 20) then
        begin
          if PartnerCargoLimit <= 0 then ShowMessageBoxGI(Self, TalkShip.LookupTalkText('Talk.Trade.NoSpace'), mbgCancel or mbgError)
          else ShowMessageBoxGI(Self, TalkShip.LookupTalkText('Talk.Trade.NoMoney'), mbgOK or mbgError);
        end
        else if DraggedGoodsIndex < 10 then
          if GetPlayer.GetLocationGoodsEntry(ShopGoodsOrder[DraggedGoodsIndex]).Count > 0 then
          begin
            if GetPlayer.GetCargoFreeSpace <= 0 then FlashCargoWarning;
            if GetPlayer.ShopGoodsPurchasePrice(ShopGoodsOrder[DraggedGoodsIndex], nil) > GetPlayer.Money then FlashMoneyWarning;
            DraggedGoodsIndex := -1;
            UpdateActionCursor(False);
            RefreshGoodsDisplay;
            BreakUiMessage;
            Exit;
          end;
      end
      else if DraggedGoodsIndex < 10 then
        if GetPlayer.GetLocationGoodsEntry(ShopGoodsOrder[DraggedGoodsIndex]).Count > 0 then
        begin
          if GetPlayer.GetCargoFreeSpace <= 0 then MainPanel.FlashCargoWarning;
          if GetPlayer.ShopGoodsPurchasePrice(ShopGoodsOrder[DraggedGoodsIndex], nil) > GetPlayer.Money then MainPanel.FlashMoneyWarning;
        end;
    end
    else
    begin
      Limit := Max(0, Count);
      if DraggedGoodsIndex < 10 then
      begin
        Description := FormatText1(LocalizedText('FormGS.Buy'), '<color=0,50,200>', '<Name>', LowerCaseWideString(GoodsMarket[ShopGoodsOrder[DraggedGoodsIndex mod 10]].TradeName));
        Price := GetPlayer.ShopGoodsPurchasePrice(ShopGoodsOrder[DraggedGoodsIndex mod 10], nil);
        Maximum := GetPlayer.GetLocationGoodsEntry(ShopGoodsOrder[DraggedGoodsIndex]).Count;
        Available := GetPlayer.GetCargoFreeSpace;
        TotalLimit := GetPlayer.Money;
        if not GetPlayer.InNormalSpace then Limit := Min(Maximum, TotalLimit div Price);
      end
      else
      begin
        Description := FormatText1(LocalizedText('FormGS.Sell'), '<color=0,50,200>', '<Name>', LowerCaseWideString(GoodsMarket[ShopGoodsOrder[DraggedGoodsIndex mod 10]].TradeName));
        Price := GetPlayer.ShopGoodsSellPrice(ShopGoodsOrder[DraggedGoodsIndex mod 10], nil);
        Maximum := GetPlayer.CargoGoods[ShopGoodsOrder[DraggedGoodsIndex - 10]].Count;
        if not GetPlayer.InNormalSpace then
        begin
          Available := 1000000000;
          TotalLimit := 1000000000;
        end
        else
        begin
          Available := PartnerCargoLimit;
          TotalLimit := PartnerMoneyLimit;
          Limit := 1000000000;
        end;
      end;
      Count := Max(0, Count);
      if ShowCountDialog(Self, 'GI,' + GetItemTypeBitmapPath(TItemType(ShopGoodsOrder[DraggedGoodsIndex mod 10])),
        Description, 0, Maximum, Limit, Price, Max(0, Available), TotalLimit, Count) = 1 then
      begin
        if (GetMaximumTradeCount(DraggedGoodsIndex, False) < Count) and (DraggedGoodsIndex >= 10) and GetPlayer.InNormalSpace then
        begin
          if Count > PartnerCargoLimit then ShowMessageBoxGI(Self, TalkShip.LookupTalkText('Talk.Trade.NoSpace'), mbgCancel or mbgError)
          else ShowMessageBoxGI(Self, TalkShip.LookupTalkText('Talk.Trade.NoMoney'), mbgOK or mbgError);
        end
        else if (Count > 0) and (GetMaximumTradeCount(DraggedGoodsIndex, not GetPlayer.InNormalSpace) >= Count) then
        begin
          // Native legality check uses the hovered row, even when a different
          // row supplied the dragged good; preserve that original selection.
          if GetPlayer.IsCargoGoodIllegalOnCurrentPlanet(ShopGoodsOrder[Index mod 10]) then
            if ShowMessageBoxGI(Self, LanguageDataConfig.GetParamByPathOrMarker('FormGS.NotPermitGoods'), mbgOK or mbgCancel) <> mbgResultOK then
            begin
              DraggedGoodsIndex := -1;
              UpdateActionCursor(False);
              RefreshGoodsDisplay;
              FinishModalTrade;
              BreakUiMessage;
            Exit;
            end;
          if not GetPlayer.InNormalSpace then Galaxy.CheckIntegrityChecksum(136);
          if GetPlayer.InNormalSpace then
          begin
            if DraggedGoodsIndex < 10 then
            begin
              TalkShip.SetMoney(TalkShip.Money + Count * GetPlayer.ShopGoodsPurchasePrice(ShopGoodsOrder[DraggedGoodsIndex mod 10], nil));
              Dec(TalkShip.CargoGoods[ShopGoodsOrder[DraggedGoodsIndex]].TotalCost, Count * GetPlayer.ShopGoodsPurchasePrice(ShopGoodsOrder[DraggedGoodsIndex mod 10], nil));
              Dec(TalkShip.CargoGoods[ShopGoodsOrder[DraggedGoodsIndex]].Count, Count);
            end
            else
            begin
              TalkShip.SetMoney(TalkShip.Money - Count * GetPlayer.ShopGoodsSellPrice(ShopGoodsOrder[DraggedGoodsIndex mod 10], nil));
              Inc(TalkShip.CargoGoods[ShopGoodsOrder[DraggedGoodsIndex mod 10]].TotalCost, Count * GetPlayer.ShopGoodsSellPrice(ShopGoodsOrder[DraggedGoodsIndex mod 10], nil));
              Inc(TalkShip.CargoGoods[ShopGoodsOrder[DraggedGoodsIndex mod 10]].Count, Count);
            end;
            TalkShip.RefreshDerivedStats(True);
          end;
          if DraggedGoodsIndex < 10 then
          begin
            SoundManager.PlaySound('Sound.Buy');
            GetPlayer.BuyGoodsFromLocation(ShopGoodsOrder[DraggedGoodsIndex], Count);
          end
          else
          begin
            SoundManager.PlaySound('Sound.Sell');
            GetPlayer.SellGoodsToLocation(ShopGoodsOrder[DraggedGoodsIndex - 10], Count);
          end;
          if not GetPlayer.InNormalSpace then Galaxy.PrimeIntegrityChecksum(137);
          if GetPlayer.IsOnPlanet then
            if GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile then
            begin
              RequestedScreenId := screenGovernment;
              RequestClose(1);
            end;
        end;
      end;
    end;
    DraggedGoodsIndex := -1;
    UpdateActionCursor(False);
    RefreshGoodsDisplay;
    FinishModalTrade;
  end;
  BreakUiMessage;
end;
{ @end $7D8840 }

{ @routine $7D965C TfGoodsShop2_GoodsRightMouseDown }
procedure TfGoodsShop2.GoodsRightMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if DraggedGoodsIndex >= 0 then
  begin
    DraggedGoodsIndex := -1;
    UpdateActionCursor(False);
    RefreshGoodsDisplay;
  end;
end;
{ @end $7D965C }

{ @routine $7D96A8 TfGoodsShop2_GoodsMouseMove }
procedure TfGoodsShop2.GoodsMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Index, Count, Price: Integer;
  Control: TObjectGI;
  I, Profit: Integer;
  Action, Color, Text: WideString;
  Good: Byte;
begin
  if GetPlayer = nil then Exit;
  Index := -1;
  Text := '';
  if DraggedGoodsIndex >= 0 then Index := DraggedGoodsIndex
  else
    for I := 0 to 7 do
    begin
      Control := GetByName('Tov' + IntToStr(I));
      with Control as TGraphButtonGI do
        if ContainsPoint(GetCursorPoint) then begin Index := I; Break; end;
      Control := GetByName('Tov' + IntToStr(I + 10));
      with Control as TGraphButtonGI do
        if ContainsPoint(GetCursorPoint) then begin Index := I + 10; Break; end;
    end;
  if Index >= 0 then
  begin
    Good := ShopGoodsOrder[Index mod 10];
    if ((Index < 10) and (GetPlayer.GetLocationGoodsEntry(Good).Count > 0)) or
      ((Index >= 10) and (GetPlayer.CargoGoods[Good].Count > 0)) then
    begin
      if Index < 10 then
      begin
        Action := 'Buy';
        Price := GetPlayer.ShopGoodsPurchasePrice(Good, nil);
        Count := GetPlayer.GetLocationGoodsEntry(Good).Count;
        Profit := 0;
      end
      else
      begin
        Action := 'Sale';
        Price := GetPlayer.ShopGoodsSellPrice(Good, nil);
        Count := GetPlayer.CargoGoods[Good].Count;
        Profit := GetPlayer.ShopGoodsSellPrice(Good, nil) - Integer(Round(GetPlayer.GetAverageCargoCost(Good)));
      end;
      Text := LookupLocalizedTextByKey('FormGS.' + Action + 'Help');
      ReplaceTextToken(Text, '<Goods>', GoodsMarket[Good].TradeName, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Count>', IntToStr(Count), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Cost>', IntToStr(Price), '<color=255,240,100>');
      if Profit > 0 then Color := '<color=0,255,0>'
      else if Profit < 0 then Color := '<color=255,0,0>'
      else if Profit = 0 then Color := '';
      ReplaceTextToken(Text, '<OldCost>', IntToStr(Round(GetPlayer.GetAverageCargoCost(Good))), Color);
      ReplaceTextToken(Text, '<Profit>', IntToStr(Profit), '<color=255,240,100>');
    end
    else if Index < 10 then
    begin
      if GetPlayer.IsOutsideStarSpace then
        Text := FormatText1(LookupLocalizedTextByKey('FormGS.NotGoodsForBuyHelp'), '<color=255,240,100>', '<Goods>', LowerCaseWideString(GoodsMarket[Good].DisplayName))
      else Text := FormatText1(LookupLocalizedTextByKey('FormGS.NotGoodsForBuyHelpInShip'), '<color=255,240,100>', '<Goods>', LowerCaseWideString(GoodsMarket[Good].DisplayName));
    end
    else Text := FormatText1(LookupLocalizedTextByKey('FormGS.NotGoodsForSaleHelp'), '<color=255,240,100>', '<Goods>', LowerCaseWideString(GoodsMarket[Good].DisplayName));
  end;
  if (HoveredControl = nil) or (HoveredControl.HelpText = '') then ShowHelpText(Text, Text <> '');
end;
{ @end $7D96A8 }

{ @routine $7D9E14 TfGoodsShop2_UpdateActionCursor }
procedure TfGoodsShop2.UpdateActionCursor(CanTake: Boolean);
var
  Found: Boolean;
  Index: Integer;
begin
  if GetPlayer = nil then Exit;
  if DraggedGoodsIndex >= 0 then
    SetCursorImage('GI,' + GetItemTypeBitmapPath(TItemType(ShopGoodsOrder[DraggedGoodsIndex mod 10])), Classes.Point(16, 16))
  else
  begin
    Found := False;
    for Index := 0 to 7 do
    begin
      with GetByName('Tov' + IntToStr(Index)) as TGraphButtonGI do
        if ContainsPoint(GetCursorPoint) then
          if GetPlayer.GetLocationGoodsEntry(ShopGoodsOrder[Index]).Count > 0 then
          begin Found := True; Break; end;
      with GetByName('Tov' + IntToStr(Index + 10)) as TGraphButtonGI do
        if ContainsPoint(GetCursorPoint) then
          if GetPlayer.CargoGoods[ShopGoodsOrder[Index]].Count > 0 then
          begin Found := True; Break; end;
    end;
    if Found then
    begin
      if not IsCursorImageSelected('Take') then SetCursorByName('Take');
    end
    else if not IsCursorImageSelected('Main') then SetCursorByName('Main');
  end;
end;
{ @end $7D9E14 }

{ @routine $7DA088 TfGoodsShop2_GoodsMouseEnter }
procedure TfGoodsShop2.GoodsMouseEnter(Sender: TObjectGI);
begin
  UpdateActionCursor(False);
end;
{ @end $7DA088 }

{ @routine $7DA0A4 TfGoodsShop2_GoodsMouseLeave }
procedure TfGoodsShop2.GoodsMouseLeave(Sender: TObjectGI);
begin
  UpdateActionCursor(False);
end;
{ @end $7DA0A4 }

{ @routine $7DA0C0 TfGoodsShop2_GetMaximumTradeCount }
function TfGoodsShop2.GetMaximumTradeCount(Index: Integer; IgnoreCargoSpace: Boolean): Integer;
var Total: Double;
begin
  if (Index >= 0) and (Index < 10) then
  begin
    Result := GetPlayer.GetLocationGoodsEntry(ShopGoodsOrder[Index]).Count;
    if (GetPlayer.GetCargoFreeSpace < Result) and not IgnoreCargoSpace then
      Result := GetPlayer.GetCargoFreeSpace;
    Total := Result;
    Total := GetPlayer.ShopGoodsPurchasePrice(ShopGoodsOrder[Index], nil) * Total;
    if (Result * GetPlayer.ShopGoodsPurchasePrice(ShopGoodsOrder[Index], nil) > GetPlayer.Money) or (Total > 100000000) then
      Result := GetPlayer.Money div GetPlayer.ShopGoodsPurchasePrice(ShopGoodsOrder[Index], nil);
  end
  else
  begin
    Result := GetPlayer.CargoGoods[ShopGoodsOrder[Index - 10]].Count;
    if GetPlayer.InNormalSpace then
    begin
      if PartnerCargoLimit < Result then Result := PartnerCargoLimit;
      if Result * TalkShip.ShopGoodsSellPrice(ShopGoodsOrder[Index - 10], nil) > PartnerMoneyLimit then
        Result := PartnerMoneyLimit div TalkShip.ShopGoodsSellPrice(ShopGoodsOrder[Index - 10], nil);
    end;
  end;
end;
{ @end $7DA0C0 }

{ @routine $7DA24C TfGoodsShop2_GetAvailableGoodsCount }
function TfGoodsShop2.GetAvailableGoodsCount(Index: Integer): Integer;
begin
  if (Index >= 0) and (Index < 10) then Result := GetPlayer.GetLocationGoodsEntry(ShopGoodsOrder[Index]).Count
  else Result := GetPlayer.CargoGoods[ShopGoodsOrder[Index - 10]].Count;
end;
{ @end $7DA24C }

{ @routine $7DA2A0 TfGoodsShop2_BuildPriceText }
function TfGoodsShop2.BuildPriceText(Location: TObject): WideString;
var
  RowNumber, SeparatorLength, Stock: Integer;
  Text, Title, Info, Separator: WideString;
  Good, Index: Byte;
  SavedPlanet: TPlanet;
  SavedDockedTo: TShip;
begin
  if GiResourceVariant = 1 then SeparatorLength := 76 else SeparatorLength := 95;
  for RowNumber := 1 to SeparatorLength do Separator := Separator + '-';
  if Location is TPlanet then
    Title := FormatText1(LocalizedColorText('FormGS.PlanetInfo'), '<color=255,240,100>', '<Planet>', (Location as TPlanet).Name)
  else if Location is TRuins then
    Title := WrapTextInColor((Location as TRuins).GetColoredFullName('<color=255,240,100>'), '')
  else if GetPlayer.InNormalSpace then Title := WrapTextInColor(TalkShip.GetFullName(' '), '<color=255,240,100>');
  Text := '<td=' + IntToStr(GiScalePixels(0)) + '>' + '<align=left>' + Title + '</align>';
  Text := Text + '<td=' + IntToStr(GiScalePixels(230)) + '>' + '<align=center>' +
    WrapTextInColor(Galaxy.FormatTurnDate(Galaxy.CurrentTurn), '<color=0,255,0>') + '</align>';
  if Location is TPlanet then
    Info := FormatText1(LocalizedColorText('FormGS.StarInfo'), '<color=255,240,100>', '<Star>', (Location as TPlanet).CurrentStar.Name)
  else if Location is TShip then
    Info := FormatText1(LocalizedColorText('FormGS.StarInfo'), '<color=255,240,100>', '<Star>', (Location as TShip).CurrentStar.Name);
  Text := Text + '<td=' + IntToStr(GiScalePixels(400)) + '>' + '<align=center>' + WrapTextInColor(Info, '') + '</align>';
  Text := Text + #13#10 + Separator;
  Text := Text + #13#10 + '<td=' + IntToStr(GiScalePixels(10)) + '>' + '<align=center>' +
    WrapTextInColor(LocalizedColorText('FormGS.ColumnNumber'), '<color=255,240,100>') + '</align>';
  Text := Text + '<td=' + IntToStr(GiScalePixels(30)) + '>' + '<align=left>' +
    WrapTextInColor(LocalizedColorText('FormGS.ColumnName'), '<color=255,240,100>') + '</align>';
  Text := Text + '<td=' + IntToStr(GiScalePixels(190)) + '>' + '<align=center>' +
    WrapTextInColor(LocalizedColorText('FormGS.ColumnCount'), '<color=255,240,100>') + '</align>';
  Text := Text + '<td=' + IntToStr(GiScalePixels(300)) + '>' + '<align=center>' +
    WrapTextInColor(LocalizedColorText('FormGS.ColumnCost'), '<color=255,240,100>') + '</align>';
  Text := Text + '<td=' + IntToStr(GiScalePixels(410)) + '>' + '<align=center>' +
    WrapTextInColor(LocalizedColorText('FormGS.ColumnLegality'), '<color=255,240,100>') + '</align>';
  Text := Text + #13#10 + Separator;
  RowNumber := 1;
  for Index := 0 to 7 do
  begin
    Good := GoodsTextOrder[Index];
    Stock := 0;
    if Location is TPlanet then Stock := (Location as TPlanet).Goods[Good].Count
    else if Location is TRuins then Stock := (Location as TRuins).ShopGoods[Good].Count
    else RaiseWideMessage('no goods shop');
    Text := Text + #13#10 + '<td=' + IntToStr(GiScalePixels(10)) + '>' + '<align=center>' +
      WrapTextInColor(IntToStr(RowNumber), '') + '</align>';
    Inc(RowNumber);
    Text := Text + '<td=' + IntToStr(GiScalePixels(30)) + '>' + '' + WrapTextInColor(GoodsMarket[Good].DisplayName, '') + '';
    Text := Text + '<td=' + IntToStr(GiScalePixels(190)) + '>' + '<align=center>' + WrapTextInColor(IntToStr(Stock), '') + '</align>';
    Text := Text + '<td=' + IntToStr(GiScalePixels(285)) + '><align=right>' +
      WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, Location)), '') + '</align>';
    Text := Text + '<td=' + IntToStr(GiScalePixels(300)) + '><align=center>' + WrapTextInColor('/', '') + '</align>';
    Text := Text + '<td=' + IntToStr(GiScalePixels(335)) + '><align=right>' +
      WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good, Location)), '') + '</align>';
    SavedPlanet := GetPlayer.CurrentPlanet;
    SavedDockedTo := GetPlayer.DockedTo;
    // Both native writes clear CurrentPlanet; retain the original duplicate assignment.
    GetPlayer.CurrentPlanet := nil;
    GetPlayer.CurrentPlanet := nil;
    if Location is TPlanet then GetPlayer.CurrentPlanet := TPlanet(Location)
    else if Location is TRuins then GetPlayer.DockedTo := TShip(Location);
    if not GetPlayer.IsCargoGoodIllegalOnCurrentPlanet(Good) then Info := LookupLocalizedTextByKey('FormGS.LegalityOk')
    else Info := WrapTextInColor(LookupLocalizedTextByKey('FormGS.LegalityNo'), '<color=255,0,0>');
    GetPlayer.CurrentPlanet := SavedPlanet;
    GetPlayer.DockedTo := SavedDockedTo;
    Text := Text + '<td=' + IntToStr(GiScalePixels(405)) + '><align=center>' + WrapTextInColor(Info, '') + '</align>';
  end;
  Result := Text;
end;
{ @end $7DA2A0 }

{ @routine $7DB224 TfGoodsShop2_SavePricesClicked }
procedure TfGoodsShop2.SavePricesClicked(Sender: TObjectGI);
var
  Location: TObject;
begin
  (GetByName('UserMsgAdd') as TGraphButtonGI).SetDisabled(True);
  SoundManager.PlaySound('Sound.UserMsgAdd');
  if GetPlayer.IsOnPlanet then Location := GetPlayer.CurrentPlanet
  else if GetPlayer.IsDockedToShip then Location := GetPlayer.DockedTo
  else if GetPlayer.InNormalSpace then Location := TalkShip else Location := nil;
  AddOrUpdatePlayerBubble(7, Galaxy.CurrentTurn, BuildPriceText(Location), StarMapScreen.GetPriceSnapshotKey(Location));
  MainPanel.RebuildMessageButtons(False);
  FinishModalTrade;
end;
{ @end $7DB224 }

{ @routine $7DB388 TfGoodsShop2_EndTurnClicked }
procedure TfGoodsShop2.EndTurnClicked(Sender: TObjectGI);
begin
  if GetPlayer = nil then Exit;
  if GetPlayer.QueuedTravelTarget <> nil then Exit;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstDominion)) and
    (GetPlayer.DockedTo.Order = soTeleport) and (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) and not GetPlayer.DockedTo.InHyperspace then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstDominion)) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and
    ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstMilitaryBase)) and
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
    (GetByName('UserMsgAdd') as TGraphButtonGI).SetDisabled(False);
    if DraggedGoodsIndex >= 0 then
    begin
      DraggedGoodsIndex := -1;
      UpdateActionCursor(False);
      RefreshGoodsDisplay;
    end;
    if not GetPlayer.InNormalSpace then Galaxy.CheckIntegrityChecksum(138);
    RestoreTemporaryShopStock;
    MainPanel.EndTurnClicked(Sender);
    if ExitCode = 0 then
    begin
      BuildTemporaryShopSlotGrid;
      if not GetPlayer.InNormalSpace then Galaxy.PrimeIntegrityChecksum(139);
      RefreshGoodsDisplay;
      MainPanel.RebuildMessageButtons(False);
    end;
  end;
end;
{ @end $7DB388 }

{ @routine $7DB660 TfGoodsShop2_GalaxyClicked }
procedure TfGoodsShop2.GalaxyClicked(Sender: TObjectGI);
begin
  AmbientSound.SetVolume(0);
  MainPanel.GalaxyClicked(Sender);
  AmbientSound.SetVolume(1);
end;
{ @end $7DB660 }

{ @routine $7DB6A4 TfGoodsShop2_QuestClicked }
procedure TfGoodsShop2.QuestClicked(Sender: TObjectGI);
begin
  AmbientSound.SetVolume(0);
  MainPanel.QuestClicked(Sender);
  AmbientSound.SetVolume(1);
end;
{ @end $7DB6A4 }

{ @routine $7DB6E8 TfGoodsShop2_MenuClicked }
procedure TfGoodsShop2.MenuClicked(Sender: TObjectGI);
begin
  AmbientSound.SetVolume(0);
  MainPanel.MenuClicked(Sender);
  AmbientSound.SetVolume(1);
end;
{ @end $7DB6E8 }

{ @routine $7DB72C TfGoodsShop2_ShipClicked }
procedure TfGoodsShop2.ShipClicked(Sender: TObjectGI);
begin
  if ExitCode <> 0 then Exit;
  if DraggedGoodsIndex >= 0 then
  begin
    DraggedGoodsIndex := -1;
    UpdateActionCursor(False);
    RefreshGoodsDisplay;
  end;
  AmbientSound.SetVolume(0);
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  ShipScreen.PlayTransitionSounds := True;
  if not GetPlayer.InNormalSpace then Galaxy.CheckIntegrityChecksum(142);
  while True do
  begin
    RunShipEquipment(Self);
    MainPanel.RefreshMoneyAndCargo;
    MainPanel.RebuildMessageButtons(False);
    RefreshGoodsDisplay;
    if not ShipScreen.ReopenRequested then Break;
    SetCursorActive(False);
    DrawQueuedUpdateRects;
    CaptureScreenBackground(True, 0);
    SetCursorActive(True);
  end;
  if not GetPlayer.InNormalSpace then Galaxy.PrimeIntegrityChecksum(143);
  AmbientSound.SetVolume(1);
  if GetPlayer.IsOnPlanet then
    if GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile then
    begin
      RequestedScreenId := screenGovernment;
      RequestClose(1);
    end;
end;
{ @end $7DB72C }

{ @routine $7DB8AC TfGoodsShop2_FinishModalTrade }
procedure TfGoodsShop2.FinishModalTrade;
begin
  if ParentLoop <> nil then
  begin
    ReopenRequested := True;
    RequestClose(1);
    BreakUiMessage;
  end;
end;
{ @end $7DB8AC }

{ @routine $7DB8DC TfGoodsShop2_CaptureMerchantBackground }
procedure TfGoodsShop2.CaptureMerchantBackground(Sender: TObjectGI);
var Position: TPoint;
begin
  if not HardwareRenderingEnabled then
    with GetByName('FaceGB') as TGraphBufGI do
    begin
      SetActive(False);
      if not ShowSystemMouse then SetCursorActive(False);
      DrawQueuedUpdateRects;
      if not ShowSystemMouse then SetCursorActive(True);
      Position := ToAbsolutePoint(Classes.Point(0, 0));
      GraphBuf.AllocateNative(ClientSize.X, ClientSize.Y);
      Ex_OKGR_Copy_XY_XY_WORD(GraphBuf.GetPixels, GraphBuf.PitchBytes, 0, 0,
        PAnsiChar(ScreenRenderBuffer.GetPixels) + Position.X * 2 + Position.Y * ScreenRenderBuffer.PitchBytes,
        ScreenRenderBuffer.PitchBytes, 0, 0, ClientSize.X, ClientSize.Y);
      GraphBuf.FlipHorizontal16;
      SetActive(True);
    end;
end;
{ @end $7DB8DC }

{ @routine $7DBA1C TfGoodsShop2_MerchantAnimationComplete }
procedure TfGoodsShop2.MerchantAnimationComplete(Sender: TObjectGI);
var Sequence: Integer;
begin
  if Sender.UserValue = 1 then
  begin
    Sequence := RandomIntRange(1, 5);
    if Sequence in [1, 2] then Sequence := 1
    else if Sequence in [3, 4] then Sequence := 2
    else if Sequence in [5] then Sequence := 3
    else Sequence := 1;
  end
  else Sequence := 1;
  if Sender.UserValue <> Sequence then
  begin
    Sender.UserValue := Sequence;
    with GetByName('FaceI') as TImageGI do
    begin
      SetImagePath('GI,Bm.Captain.' + GiResourceSuffix + 'ShopBot' + IntToStr(Cardinal(Sender.UserValue)) + 'i');
      SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end;
    with GetByName('FaceA') as TgaiGI do
    begin
      FirstFrameOnly := not AnimCaptain;
      SetImagePath('Bm.Captain.' + GiResourceSuffix + 'ShopBot' + IntToStr(Cardinal(Sender.UserValue)) + 'a');
      SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetSequenceFrame(0);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
      RestartPlayback;
      CycleCompleteCallback := MerchantAnimationComplete;
    end;
  end;
end;
{ @end $7DBA1C }

{ @routine $7DBD18 TfGoodsShop2_CloseClicked }
procedure TfGoodsShop2.CloseClicked(Sender: TObjectGI);
begin
  if ParentLoop <> nil then
  begin
    RequestClose(1);
    BreakUiMessage;
  end;
end;
{ @end $7DBD18 }

{ @routine $7DBD44 TfGoodsShop2_RefreshMoneyWarning }
procedure TfGoodsShop2.RefreshMoneyWarning;
begin
  if MoneyWarningActive and not Odd(MoneyWarningTicks) then
  begin
    GetByName('ADD_WarningMoney').SetActive(True);
    with GetByName('ADD_Money') as TLabelGI do
    begin
      SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 128, 61));
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
{ @end $7DBD44 }

{ @routine $7DBE94 TfGoodsShop2_FlashMoneyWarning }
procedure TfGoodsShop2.FlashMoneyWarning;
begin
  if MoneyWarningTimer <> nil then
  begin
    CancelCallbackTimer(MoneyWarningTimer);
    MoneyWarningTimer := nil;
  end;
  MoneyWarningTimer := ScheduleCallbackTimer(100, 100, MoneyWarningTick);
  MoneyWarningActive := True;
  MoneyWarningTicks := 6;
  RefreshMoneyWarning;
end;
{ @end $7DBE94 }

{ @routine $7DBF0C TfGoodsShop2_MoneyWarningTick }
procedure TfGoodsShop2.MoneyWarningTick(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Dec(MoneyWarningTicks);
  if MoneyWarningTicks <= 0 then
  begin
    if MoneyWarningTimer <> nil then
    begin
      CancelCallbackTimer(MoneyWarningTimer);
      MoneyWarningTimer := nil;
    end;
    MoneyWarningActive := False;
  end;
  RefreshMoneyWarning;
end;
{ @end $7DBF0C }

{ @routine $7DBF70 TfGoodsShop2_RefreshCargoWarning }
procedure TfGoodsShop2.RefreshCargoWarning;
begin
  if CargoWarningActive and not Odd(CargoWarningTicks) then
  begin
    GetByName('ADD_WarningSpace').SetActive(True);
    with GetByName('ADD_Space') as TLabelGI do
    begin
      SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 128, 61));
      SetText(IntToStr(GetPlayer.GetCargoFreeSpace));
      SetActive(True);
    end;
  end
  else
  begin
    GetByName('ADD_WarningSpace').SetActive(False);
    GetByName('ADD_Space').SetActive(False);
  end;
end;
{ @end $7DBF70 }

{ @routine $7DC0BC TfGoodsShop2_FlashCargoWarning }
procedure TfGoodsShop2.FlashCargoWarning;
begin
  if CargoWarningTimer <> nil then
  begin
    CancelCallbackTimer(CargoWarningTimer);
    CargoWarningTimer := nil;
  end;
  CargoWarningTimer := ScheduleCallbackTimer(100, 100, CargoWarningTick);
  CargoWarningActive := True;
  CargoWarningTicks := 6;
  RefreshCargoWarning;
end;
{ @end $7DC0BC }

{ @routine $7DC134 TfGoodsShop2_CargoWarningTick }
procedure TfGoodsShop2.CargoWarningTick(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Dec(CargoWarningTicks);
  if CargoWarningTicks <= 0 then
  begin
    if CargoWarningTimer <> nil then
    begin
      CancelCallbackTimer(CargoWarningTimer);
      CargoWarningTimer := nil;
    end;
    CargoWarningActive := False;
  end;
  RefreshCargoWarning;
end;
{ @end $7DC134 }

{ @routine $7DC198 TfGoodsShop2_MainPanelKeyDown }
procedure TfGoodsShop2.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if (Key = VK_ESCAPE) and (DraggedGoodsIndex >= 0) then
  begin
    DraggedGoodsIndex := -1;
    UpdateActionCursor(False);
    RefreshGoodsDisplay;
  end
  else if (Key = VK_ESCAPE) and GetPlayer.InNormalSpace then CloseClicked(nil)
  else if (Key = VK_SPACE) and not GetPlayer.InNormalSpace then
  begin
    if GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
  end
  else if (Key = Ord('S')) and not GetPlayer.InNormalSpace then ShipClicked(nil)
  else if not GetPlayer.InNormalSpace then
  begin
    if (Key = Ord('M')) or (Key = Ord('R')) or (Key = VK_ESCAPE) or (Key = VK_F2) or (Key = VK_F3) then AmbientSound.SetVolume(0);
    MainPanel.ProcessKeyDown(Key);
    PlanetPanel.ProcessKeyDown(Key);
    StationPanel.ProcessKeyDown(Key);
    if (Key = Ord('M')) or (Key = Ord('R')) or (Key = VK_ESCAPE) or (Key = VK_F2) or (Key = VK_F3) then AmbientSound.SetVolume(1);
  end;
end;
{ @end $7DC198 }

{ @routine $7DC358 TfGoodsShop2_ShowControlHelp }
procedure TfGoodsShop2.ShowControlHelp(Sender: TObjectGI; Visible: Boolean);
begin
  if (GetPlayer <> nil) and GetPlayer.InNormalSpace then
    with GetByName('GS_Help') as TLabelGI do
    begin
      if (Sender = nil) or (Sender.HelpText = '') then Visible := False;
      SetActive(Visible);
      if Visible then SetText(Sender.HelpText);
    end
  else MainPanel.ShowControlHelp(Sender, Visible);
end;
{ @end $7DC358 }

{ @routine $7DC400 TfGoodsShop2_ShowHelpText }
procedure TfGoodsShop2.ShowHelpText(Value: WideString; Visible: Boolean);
begin
  if (GetPlayer <> nil) and GetPlayer.InNormalSpace then
    with GetByName('GS_Help') as TLabelGI do
    begin
      SetActive(Visible);
      if Visible then SetText(Value);
    end
  else MainPanel.ShowHelpText(Value, Visible);
end;
{ @end $7DC400 }

{ @routine $7DC4C0 TfGoodsShop2_ProcessCallbackTimers }
procedure TfGoodsShop2.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $7DC4C0 }

{ @routine $7DC500 TfGoodsShop2_ExecuteUiCode }
procedure TfGoodsShop2.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if MainPanel.NavigationLocked then Exit;
  if ExitScreenLoop then Exit;
  if TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared] then
  begin
    Galaxy.CheckIntegrityChecksum(10006);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20006);
  end;
end;
{ @end $7DC500 }

{ @routine $7DC574 TfGoodsShop2_SelectMusic }
procedure TfGoodsShop2.SelectMusic;
begin
  if (ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1) then Exit;
  if not MusicInPlanetEnabled then
  begin
    MusicManager.RequestFadeOut;
    Exit;
  end;
  if GetPlayer.IsOnPlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
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
    else if GetPlayer.DockedTo.TypeId in [Ord(rstPirateBase), Ord(rstDominion)] then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end;
end;
{ @end $7DC574 }

{ @routine $7DC7DC RunGoodsShop }
function RunGoodsShop(ParentLoop: TMessageLoopGI): Boolean;
begin
  ParentLoop.RootUiObject.OnModalSuspend;
  GoodsShopScreen.ParentLoop := ParentLoop;
  ParentLoop.ChildLoop := GoodsShopScreen;
  if GoodsShopScreen.Run = 1 then Result := True else Result := False;
  GoodsShopScreen.ParentLoop := nil;
  ParentLoop.ChildLoop := nil;
  ParentLoop.RootUiObject.OnModalResume;
end;
{ @end $7DC7DC }
end.
