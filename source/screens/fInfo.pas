unit fInfo;

interface

uses aGalaxy, aPlanet, GI_Label, aItem, GI_MessageLoop, EC_BlockPar, GI_PanelScrollBar, Types, fPanelLoad, fPanelMain, fPanelPlanet, fPanelRuins;

type
  TfInfo = class(TMessageLoopGIWithMainPanel) // @size 0xF8
  public
    PlanetPanel: TfPanelPlanet; // @offset 0xD4
    StationPanel: TfPanelRuins; // @offset 0xD8
    LoadPanel: TfPanelLoad; // @offset 0xDC
    InfoPanel: TPanelScrollBarGI; // @offset 0xE0
    InfoContentHeight: Integer; // @offset $E4
    SearchMode: Boolean; // @offset $E8
    SelectedSearchCategory: Integer; // @offset $EC  Zero selects the general name search.

    PreviousSearchCategory: Integer; // @offset $F0
    HasSearchResults: Boolean; // @offset $F4

    procedure RefreshNewsAnimation(Sender: TObjectGI); // @addr $58CFF0
    procedure FocusSearchField(Force: Boolean); // @addr $58F108
    procedure ToggleSearchMode(Sender: TObjectGI); // @addr $58F474
    procedure MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $58F55C
    procedure SearchClicked(Sender: TObjectGI); // @addr $590124
    procedure RunSearch(Sender: TObjectGI); // @addr $59422C
    procedure CategoryStateChanged(Sender: TObjectGI); // @addr $597D54
    procedure CategoryClicked(Sender: TObjectGI); // @addr $597E10
    procedure NextSearchPageClicked(Sender: TObjectGI); // @addr $5983A4
    procedure BindFilterLabels(Parent: TObjectGI); // @addr $598548
    procedure ShowNews; // @addr $58FC38
    procedure ShowSearch; // @addr $58FEB4

    procedure EndTurnClicked(Sender: TObjectGI); // @addr $58D298
    procedure ShipClicked(Sender: TObjectGI); // @addr $58D4E0
    function GetSearchResultLimit: Integer; // @addr $5990DC
    procedure ClearInfoContents; // @addr $58D518
    procedure FinishInfoLayout; // @addr $58D560
    procedure AddInfoSeparator; // @addr $58D660
    procedure AddInfoHeading(Title, BookmarkText: WideString; LayoutKind, BookmarkIndex, GoodsReference: Integer); // @addr $58D79C LayoutKind zero centers the heading; nonzero aligns it to the right.
    procedure AddSearchPriceLabel(Text: WideString); // @addr $58DE08
    procedure AddInfoText(Text: WideString; Alignment: TTextAlignXGI; Font: WideString); // @addr $58E034
    procedure AddPlanetInfoText(Planet: TPlanet; Text: WideString); // @addr $58E4F0
    procedure AddEquipmentInfoText(Item: TItem; Text: WideString); // @addr $597698
    procedure AddItemInfoText(Item: TItem; Text: WideString); // @addr $58E870
    procedure AddStarInfoText(Star: TStar; Text: WideString); // @addr $58ED54
    procedure ToggleVisibleBookmark; // @addr $597BAC
    function IsAtBusinessCenter: Boolean; // @addr $597D28
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $58F57C
    procedure AddInfoImageText(ImagePath, Text: WideString); // @addr $58E238
    procedure BookmarkClicked(Sender: TObjectGI); // @addr $58F8B8
    procedure AddInfoSpacing(Pixels: Integer); // @addr $58D648
    procedure MainPanelKeyUp(Sender: TObjectGI; Key: Cardinal); // @addr $58F850

    procedure FilterLabelMouseEnter(Sender: TObjectGI); // @addr $5986E0
    procedure FilterLabelMouseLeave(Sender: TObjectGI); // @addr $5986F0
    procedure FilterLabelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $598700
    procedure FilterLabelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $598718
    procedure ClearSearchText(Sender: TObjectGI); // @addr $598748
    procedure CopySearchText(Sender: TObjectGI); // @addr $598788
    procedure PasteSearchText(Sender: TObjectGI); // @addr $5987CC
    procedure ClearSearch12Name(Sender: TObjectGI); // @addr $59884C
    procedure CopySearch12Name(Sender: TObjectGI); // @addr $598884
    procedure PasteSearch12Name(Sender: TObjectGI); // @addr $5988C0
    procedure ClearSearch15Name(Sender: TObjectGI); // @addr $598938
    procedure CopySearch15Name(Sender: TObjectGI); // @addr $598970
    procedure PasteSearch15Name(Sender: TObjectGI); // @addr $5989AC
    procedure ClearSearchField(Name: WideString); // @addr $598A24
    procedure ClearSearch01Filters(Sender: TObjectGI); // @addr $598A84
    procedure ClearSearch02Filters(Sender: TObjectGI); // @addr $598B14
    procedure ClearSearch03Filters(Sender: TObjectGI); // @addr $598B84
    procedure ClearSearch04Filters(Sender: TObjectGI); // @addr $598BF0
    procedure ClearSearch05Filters(Sender: TObjectGI); // @addr $598C5C
    procedure ClearSearch06Filters(Sender: TObjectGI); // @addr $598CC8
    procedure ClearSearch07Filters(Sender: TObjectGI); // @addr $598D38
    procedure ClearSearch09Filters(Sender: TObjectGI); // @addr $598DA4
    procedure ClearSearch10Filters(Sender: TObjectGI); // @addr $598E14
    procedure ClearSearch11Filters(Sender: TObjectGI); // @addr $598E84
    procedure ClearSearch12Filters(Sender: TObjectGI); // @addr $598EEC
    procedure ClearSearch13Filters(Sender: TObjectGI); // @addr $598FD0
    procedure ClearSearch15Filters(Sender: TObjectGI); // @addr $599070

    constructor Create; // @addr 0x0058BDB4
    destructor Destroy; override; // @addr 0x0058BE20
    procedure OnOpen; override; // @addr 0x0058C2F0
    procedure OnClose; override; // @addr 0x0058CECC
    procedure SelectMusic; override; // @addr 0x0058F9CC
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x0058F854
    procedure InitializeLayout; override; // @addr 0x0058BE8C
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x0059910C
  end;

function FindLowercaseInfoTextFrom(const Search, Text: WideString; StartPosition: Integer): Integer; // @addr $58BB58 Search is already lowercase; positions are one-based, zero means absent.
function FindLowercaseInfoText(const Search, Text: WideString): Integer; // @addr $58BBB4

function ItemMatchesInfoSearch(Item: TItem; Search: WideString): Boolean; // @addr $58BD14 Search terms must already be lowercase.

implementation

// @unit-initialization $80689C
// @unit-finalization $599170

uses Classes, aTransport, Messages, EC_Data, Windows, SE_Star, SE_Planet, GI_Image, GI_GraphBuf, GR_GraphBuf, GI_GI, aRuins, fRuinsTalk, fEquipmentShop, aGalaxyStruct, GI_GAI, fShip2, Math, GI_Label, fGov, aPlanet, aConst, EC_Struct, GI_Main, GR_Music, GI_Edit, GI_GraphButton, SysUtils, EC_Str, GR_Main, aPlayer, aShip, aGalaxy, aMyFunction, ThreadCalc, Globals, GlobalsV;

{ @routine $58BB58 FindLowercaseInfoTextFrom }
function FindLowercaseInfoTextFrom(const Search, Text: WideString; StartPosition: Integer): Integer;
begin
  Result := FindTextOffsetW(WideLowerCase(Text),Search,StartPosition - 1) + 1;
end;
{ @end $58BB58 }

{ @routine $58BBB4 FindLowercaseInfoText }
function FindLowercaseInfoText(const Search, Text: WideString): Integer;
begin
  Result := FindLowercaseInfoTextFrom(Search,Text,1);
end;
{ @end $58BBB4 }

{ @routine $58BD14 ItemMatchesInfoSearch }
function ItemMatchesInfoSearch(Item: TItem; Search: WideString): Boolean;
var I, Count: Integer;

  // @nested $58BBC0 ItemMatchesInfoSearchTerm
  function ItemMatchesInfoSearchTerm(Term: WideString): Boolean; // @addr $58BBC0 @calls "0x0058BD6E" Nested helper captures Item.
  begin
    Result := True;
    if FindTextOffsetW(WideLowerCase(RemoveTextTagsW(Item.GetDisplayName)),Term) >= 0 then Exit;
    if (Item is THull) and ((Item as THull).HullSeries <> -1) then
      if FindTextOffsetW(WideLowerCase(RemoveTextTagsW(HullSeriesDefinitions[THull(Item).HullSeries].Name)),Term) >= 0 then Exit;
    if (Item is TWeapon) and ((Item as TWeapon).SpecialModuleIndex <> 0) then
      if FindTextOffsetW(WideLowerCase(RemoveTextTagsW((Item as TWeapon).GetSpecialModuleName)),Term) >= 0 then Exit;
    Result := False;
  end;

begin
  Result := False;
  Count := CountDelimitedPartsW(Search,' ');
  for I := 0 to Count - 1 do
    if not ItemMatchesInfoSearchTerm(ExtractDelimitedPartW(Search,I,' ')) then Exit;
  Result := True;
end;
{ @end $58BD14 }

{ @routine $58BDB4 TfInfo_Create }
constructor TfInfo.Create;
begin
  inherited Create;
  PlanetPanel := TfPanelPlanet.Create;
  StationPanel := TfPanelRuins.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $58BDB4 }

{ @routine $58BE20 TfInfo_Destroy }
destructor TfInfo.Destroy;
begin
  if PlanetPanel <> nil then
  begin
    PlanetPanel.Free;
    PlanetPanel := nil;
  end;
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
{ @end $58BE20 }

{ @routine $58BE8C TfInfo_InitializeLayout }
procedure TfInfo.InitializeLayout;
var ExtraHeight: Integer;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  PlanetPanel.InitializeLayout(Self);
  StationPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fInfo... ');
  ViewportRect := Types.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Types.Point(GameScreenWidth,GameScreenHeight));
    FindByNameRecursive('BGCity2').SetSize(Types.Point(GameScreenWidth,GameScreenHeight));
    FindByNameRecursive('BGCity').SetSize(Types.Point(GameScreenWidth,GameScreenHeight));
    ExtraHeight := Min(Max(ExtraScreenHeight,0),432) div 3 * 3;
    with FindByNameRecursive('ButFormClose') do
    begin
      SetPosition(Types.Point(LocalPosition.X,LocalPosition.Y + ExtraHeight));
      with Parent do
      begin
        SetPosition(Types.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + (Max(ExtraScreenHeight,0) - ExtraHeight) div 2));
        SetSize(Types.Point(ClientSize.X,ClientSize.Y + ExtraHeight));
        with FirstChild.NextSibling do
        begin
          SetSize(Types.Point(ClientSize.X,ClientSize.Y + ExtraHeight));
          with NextSibling do SetPosition(Types.Point(LocalPosition.X,LocalPosition.Y + ExtraHeight));
        end;
        with FindByNameRecursive('ButSearch') do SetPosition(Types.Point(LocalPosition.X,LocalPosition.Y + ExtraHeight));
        with FindByNameRecursive('ButNews') do SetPosition(Types.Point(LocalPosition.X,LocalPosition.Y + ExtraHeight));
        with FindByNameRecursive('PanelInfo') as TPanelScrollBarGI do
        begin
          SetSize(Types.Point(ClientSize.X,ClientSize.Y + ExtraHeight));
          VerticalScrollBar.SetSize(Types.Point(VerticalScrollBar.ClientSize.X,VerticalScrollBar.ClientSize.Y + ExtraHeight));
        end;
      end;
    end;
  end;
  AppendLogLineThreadSafe('ok');
  (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
  (GetByName('PM_Ship') as TGraphButtonGI).UpCallback := ShipClicked;
  InfoPanel := GetByName('PanelInfo') as TPanelScrollBarGI;
  (GetByName('TextSearch') as TEditGI).ClearFocusOnEnter := False;
end;
{ @end $58BE8C }

{ @routine $58C2F0 TfInfo_OnOpen }
procedure TfInfo.OnOpen;
var I: Integer; Path: WideString;
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
    else UpCallback := StationPanel.ServicesClicked;
  with GetByName('MainPanel') do
  begin
    KeyDownCallback := MainPanelKeyDown;
    KeyUpCallback := MainPanelKeyUp;
    LeftButtonDownCallback := MainPanelMouseDown;
  end;
  (GetByName('OkSearch') as TGraphButtonGI).UpCallback := SearchClicked;
  (GetByName('ButClear') as TGraphButtonGI).UpCallback := ClearSearchText;
  (GetByName('ButCopy') as TGraphButtonGI).UpCallback := CopySearchText;
  (GetByName('ButPaste') as TGraphButtonGI).UpCallback := PasteSearchText;
  (GetByName('M01Clear') as TGraphButtonGI).UpCallback := ClearSearch01Filters;
  (GetByName('M02Clear') as TGraphButtonGI).UpCallback := ClearSearch02Filters;
  (GetByName('M03Clear') as TGraphButtonGI).UpCallback := ClearSearch03Filters;
  (GetByName('M04Clear') as TGraphButtonGI).UpCallback := ClearSearch04Filters;
  (GetByName('M05Clear') as TGraphButtonGI).UpCallback := ClearSearch05Filters;
  (GetByName('M06Clear') as TGraphButtonGI).UpCallback := ClearSearch06Filters;
  (GetByName('M07Clear') as TGraphButtonGI).UpCallback := ClearSearch07Filters;
  (GetByName('M09Clear') as TGraphButtonGI).UpCallback := ClearSearch09Filters;
  (GetByName('M10Clear') as TGraphButtonGI).UpCallback := ClearSearch10Filters;
  (GetByName('M11Clear') as TGraphButtonGI).UpCallback := ClearSearch11Filters;
  (GetByName('M12Clear') as TGraphButtonGI).UpCallback := ClearSearch12Filters;
  (GetByName('M13Clear') as TGraphButtonGI).UpCallback := ClearSearch13Filters;
  (GetByName('M15Clear') as TGraphButtonGI).UpCallback := ClearSearch15Filters;
  (GetByName('M12ButClear') as TGraphButtonGI).UpCallback := ClearSearch12Name;
  (GetByName('M12ButCopy') as TGraphButtonGI).UpCallback := CopySearch12Name;
  (GetByName('M12ButPaste') as TGraphButtonGI).UpCallback := PasteSearch12Name;
  (GetByName('M15ButCopy') as TGraphButtonGI).UpCallback := CopySearch15Name;
  (GetByName('M15ButPaste') as TGraphButtonGI).UpCallback := PasteSearch15Name;
  (GetByName('M11S03') as TGraphButtonGI).SetDown(True);
  MainPanel.RebuildMessageButtons(False);
  SearchMode := False;
  with GetByName('ButSearch') as TGraphButtonGI do
  begin
    UpCallback := ToggleSearchMode;
    SetDisabled(SearchMode);
  end;
  with GetByName('ButNews') as TGraphButtonGI do
  begin
    UpCallback := ToggleSearchMode;
    SetDisabled(not SearchMode);
  end;
  GetByName('PanelSearch').SetActive(SearchMode);
  with GetByName('BGCity2') as TImageGI do
  begin
    SetActive(GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_military_base));
    if Active then
    begin
      ImageSourcePath := 'GAI,' + GetPlayer.CurrentStar.GetBackgroundImagePath(I);
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
        Path := 'Bm.FormRuins.' + GiResourceSuffix + GetPlayer.DockedTo.TypeNameOverrideKey + 'bg';
        if CacheDataRoot.FileExistsByPath(Path) then SetImagePath('GI,' + Path)
        else SetImagePath('GI,Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[GetPlayer.DockedTo.TypeId].Name + 'bg');
      end
      else SetImagePath('GI,Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[GetPlayer.DockedTo.TypeId].Name + 'bg');
    end
    else SetActive(False);
  for I := 1 to 15 do
    with GetByName('ButMM_' + IntToFixedWidthWideString(I,2)) as TGraphButtonGI do
    begin
      StateChangedCallback := CategoryStateChanged;
      UpCallback := CategoryClicked;
    end;
  BindFilterLabels(GetByName('PanelInfo').Parent);
  RefreshNewsAnimation(nil);
  SetFocusedControl(nil);
  ShowNews;
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(event_enter_form,nil,nil,0);
  Galaxy.PrimeIntegrityChecksum(201);
end;
{ @end $58C2F0 }

{ @routine $58CECC TfInfo_OnClose }
procedure TfInfo.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(202);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(event_leave_form,nil,nil,0);
  InfoPanel.FreeOwnedChildren;
  MainPanel.OnClose;
  LoadPanel.OnClose;
  if (GetPlayer <> nil) and GetPlayer.IsOnPlanet then PlanetPanel.OnClose
  else StationPanel.OnClose;
end;
{ @end $58CECC }

var
  ReservedInfoText: WideString = ''; // @addr $80E9AC Retained empty managed variable, cleared before the names array.
  InfoNewsAnimationNames: array[0..19] of WideString =
    ('a','b','c','d','e','f','g','h','k','l','m','n','o','p','q','r','s','t','u','v'); // @addr $80E9B0
var
  InfoNewsAnimationWeights: array[0..19] of Integer =
    (9,5,9,9,7,5,7,1,3,1,0,3,3,2,3,2,3,4,5,3); // @addr $80EA00 Native selection adds one to each weight.
  InfoQualityGrades: array[0..6] of Single = (0.7,0.8,0.9,1.0,1.2,1.4,1.6); // @addr $80EA50

{ @routine $58CFF0 TfInfo_RefreshNewsAnimation }
procedure TfInfo.RefreshNewsAnimation(Sender: TObjectGI);
var I, Weight: Integer;
begin
  Weight := 0;
  for I := 0 to 19 do Inc(Weight,InfoNewsAnimationWeights[I] + 1);
  Weight := RandomIntRange(0,Weight - 1);
  I := 0;
  while I < 19 do
  begin
    Dec(Weight,InfoNewsAnimationWeights[I] + 1);
    if Weight < 0 then Break;
    Inc(I);
  end;
  with GetByName('TV') as TgaiGI do
  begin
    if SearchMode then
    begin
      SetFirstFrameImagePath('Bm.News.' + GiResourceSuffix + 'FindI');
      SetImagePath('Bm.News.' + GiResourceSuffix + 'FindA');
      LoadFrameSequenceFromText('[75,0-' + IntToStr(GetMainImageFrameCount - 1) + ']');
    end
    else
    begin
      SetFirstFrameImagePath('Bm.News.' + GiResourceSuffix + InfoNewsAnimationNames[I] + 'i');
      SetImagePath('Bm.News.' + GiResourceSuffix + InfoNewsAnimationNames[I] + 'a');
      LoadFrameSequenceFromText('[75,0-' + IntToStr(GetMainImageFrameCount - 1) + ']');
    end;
    UpdateAutoGeometry;
    CycleCompleteCallback := RefreshNewsAnimation;
    RestartPlayback;
  end;
end;
{ @end $58CFF0 }

{ @routine $58D298 TfInfo_EndTurnClicked }
procedure TfInfo.EndTurnClicked(Sender: TObjectGI);
begin
  if (GetPlayer = nil) or (GetPlayer.QueuedTravelTarget <> nil) then Exit;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_dominion) and
    (GetPlayer.DockedTo.Order = order_teleport) and (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) and
    not GetPlayer.DockedTo.InHyperspace then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_dominion) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and
    ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = station_military_base) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and
    ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    if GetPlayer.Speed <= 0 then RuinsTalkScreen.DepartWithStation(1)
    else StationPanel.TakeOffForStationTravel;
    Exit;
  end;
  if SearchMode then ToggleSearchMode(nil);
  Galaxy.CheckIntegrityChecksum(203);
  RestoreTemporaryShopStock;
  MainPanel.EndTurnClicked(Sender);
  MainPanel.RebuildMessageButtons(False);
  if ExitCode = 0 then
  begin
    BuildTemporaryShopSlotGrid;
    ShowNews;
    Galaxy.PrimeIntegrityChecksum(204);
  end;
end;
{ @end $58D298 }

{ @routine $58D4E0 TfInfo_ShipClicked }
procedure TfInfo.ShipClicked(Sender: TObjectGI);
begin
  MainPanel.ShipClicked(Sender);
  if ShipScreen.ShipStateChanged then
  begin
    MainPanel.RebuildMessageButtons(False);
    MainPanel.RefreshMoneyAndCargo;
  end;
end;
{ @end $58D4E0 }

{ @routine $58D518 TfInfo_ClearInfoContents }
procedure TfInfo.ClearInfoContents;
begin
  InfoContentHeight := 0;
  InfoPanel.FreeOwnedChildren;
  InfoPanel.SetScrollOffset(Types.Point(0,0));
  InfoPanel.Invalidate;
end;
{ @end $58D518 }

{ @routine $58D560 TfInfo_FinishInfoLayout }
procedure TfInfo.FinishInfoLayout;
begin
  InfoPanel.UpdateScrollRanges;
  InfoPanel.VerticalScrollBar.SetRange(0,InfoPanel.VerticalScrollBar.Maximum);
  InfoPanel.VerticalScrollBar.IsActive := InfoPanel.ClientSize.Y < InfoContentHeight;
  InfoPanel.VerticalScrollBar.SetSmallChange((GovernmentScreen.GetByName('TalkText') as TLabelGI).GetLineHeight);
  InfoPanel.VerticalScrollBar.SetLargeChange(InfoPanel.ClientSize.Y);
  InfoPanel.VerticalScrollBar.SetPageSize(InfoPanel.ClientSize.Y);
  InfoPanel.SetScrollOffset(Types.Point(0,0));
  InfoPanel.Invalidate;
end;
{ @end $58D560 }

{ @routine $58D648 TfInfo_AddInfoSpacing }
procedure TfInfo.AddInfoSpacing(Pixels: Integer);
begin
  Inc(InfoContentHeight,GiScalePixels(Pixels));
end;
{ @end $58D648 }

{ @routine $58D660 TfInfo_AddInfoSeparator }
procedure TfInfo.AddInfoSeparator;
var Image: TImageGI;
begin
  Image := TImageGI.Create(InfoPanel);
  Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'Line');
  Image.SetSize(Image.GetContentSize);
  Image.SetPosition(Types.Point(InfoPanel.ClientSize.X div 2 - Image.ClientSize.X div 2,InfoContentHeight));
  Image.SetDepth(1);
  Image.SetImageKindX(image_x_tile_left);
  Image.SetImageKindY(image_y_center);
  Inc(InfoContentHeight,Image.ClientSize.Y);
  Image.SetPositionModeW(True);
end;
{ @end $58D660 }

{ @routine $58D79C TfInfo_AddInfoHeading }
procedure TfInfo.AddInfoHeading(Title, BookmarkText: WideString; LayoutKind, BookmarkIndex, GoodsReference: Integer);
var
  Image: TImageGI;
  Caption: TLabelGI;
  Button: TGraphButtonGI;
begin
  Title := ReplaceAllWideString(Title,TextHighlightColorTag,BlackColorTag);
  Title := ReplaceAllWideString(Title,GreenColorTag,YellowColorTag);
  Image := TImageGI.Create(InfoPanel);
  if LayoutKind = 0 then Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'CaptionL')
  else Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'Caption');
  Image.SetSize(Image.GetContentSize);
  if LayoutKind = 0 then Image.SetPosition(Types.Point(InfoPanel.ClientSize.X div 2 - Image.ClientSize.X div 2,InfoContentHeight))
  else Image.SetPosition(Types.Point(InfoPanel.ClientSize.X - Image.ClientSize.X,InfoContentHeight));
  Image.SetDepth(1);
  Image.SetImageKindX(image_x_tile_left);
  Image.SetImageKindY(image_y_center);
  Inc(InfoContentHeight,Image.ClientSize.Y);
  Image.SetPositionModeW(True);
  Caption := TLabelGI.Create(InfoPanel);
  if (FontDialog = 0) or SearchMode then Caption.SetFontName(NormalFontName)
  else if FontDialog = 1 then Caption.SetFontName(SmoothBigFontName)
  else if FontDialog = 2 then Caption.SetFontName(SmoothHugeFontName)
  else if FontDialog >= 3 then Caption.SetFontName(SmoothIntroFontName);
  Caption.SetDepth(-1);
  Caption.SetSize(Image.ClientSize);
  if LayoutKind <> 0 then Caption.SetSize(Types.Point(Caption.ClientSize.X - GiScalePixels(20),Caption.ClientSize.Y));
  Caption.SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - Caption.ClientSize.X,Image.LocalPosition.Y));
  Caption.SetWordWrapEnabled(False);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(text_x_center);
  Caption.SetTextAlignY(text_y_font_center);
  Caption.SetText(Title);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  if BookmarkText <> '' then
  begin
    Button := TGraphButtonGI.Create(InfoPanel);
    Button.SetImageNormalPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemN');
    Button.SetImageNormalActivePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemA');
    Button.SetImageDownPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemD');
    Button.SetImageDisabledPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemH');
    Button.SetSize(Button.GetMaxStateImageSize);
    if LayoutKind = 0 then Button.SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - Button.ClientSize.X - GiScalePixels(10),Image.LocalPosition.Y))
    else Button.SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - Button.ClientSize.X - GiScalePixels(10),Image.LocalPosition.Y - GiScalePixels(5)));
    Button.SetKind(button_push_can_disable);
    Button.SetPositionModeW(True);
    Button.HelpText := BookmarkText;
    Button.UpCallback := BookmarkClicked;
    Button.Name := 'MemBtn' + IntToStr(BookmarkIndex);
    Button.SetDown(False);
    Button.SetDisabled(FindPlayerBubbleByText(BookmarkText,False) <> nil);
    Button.UserValue := GoodsReference;
    Button.SetHovered(True);
    Button.Invalidate;
    Button.SetHovered(False);
  end;
end;
{ @end $58D79C }

{ @routine $58DE08 TfInfo_AddSearchPriceLabel }
procedure TfInfo.AddSearchPriceLabel(Text: WideString);
var Image: TImageGI; Caption: TLabelGI;
begin
  Image := TImageGI.Create(InfoPanel);
  Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'FindPrice');
  Image.SetSize(Image.GetContentSize);
  Image.SetPosition(Types.Point(InfoPanel.ClientSize.X - Image.ClientSize.X - GiScalePixels(40),InfoContentHeight));
  Image.SetDepth(1);
  Image.SetImageKindX(image_x_tile_left);
  Image.SetImageKindY(image_y_center);
  Inc(InfoContentHeight,Image.ClientSize.Y);
  Image.SetPositionModeW(True);
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetDepth(-1);
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - (InfoPanel.ClientSize.X - Image.LocalPosition.X) - GiScalePixels(10),Image.ClientSize.Y));
  Caption.SetPosition(Types.Point(0,Image.LocalPosition.Y));
  Caption.SetWordWrapEnabled(False);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(text_x_right);
  Caption.SetTextAlignY(text_y_font_center);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
end;
{ @end $58DE08 }

{ @routine $58E034 TfInfo_AddInfoText }
procedure TfInfo.AddInfoText(Text: WideString; Alignment: TTextAlignXGI; Font: WideString);
var Caption: TLabelGI;
begin
  Text := ReplaceAllWideString(Text,TextHighlightColorTag,DialogHighlightColorTag);
  Caption := TLabelGI.Create(InfoPanel);
  if Font = '' then
  begin
    if FontDialog = 0 then Caption.SetFontName(NormalFontName)
    else if FontDialog = 1 then Caption.SetFontName(SmoothBigFontName)
    else if FontDialog = 2 then Caption.SetFontName(SmoothHugeFontName)
    else if FontDialog >= 3 then Caption.SetFontName(SmoothIntroFontName);
  end
  else Caption.SetFontName(Font);
  Caption.SetPosition(Types.Point(0,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X,1));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(Alignment);
  Caption.SetTextAlignY(text_y_fit_height);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Inc(InfoContentHeight,Caption.ClientSize.Y);
end;
{ @end $58E034 }

{ @routine $58E238 TfInfo_AddInfoImageText }
procedure TfInfo.AddInfoImageText(ImagePath, Text: WideString);
var Size: Integer; Image: TGraphBufGI; Caption: TLabelGI;
begin
  Text := ReplaceAllWideString(Text,TextHighlightColorTag,DialogHighlightColorTag);
  Size := GiScalePixels(64);
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Size));
  Image.SourceHasPerPixelAlpha := True;
  LoadGiByPathIntoGraphBuf(ImagePath,Image.GraphBuf);
  if Image.GraphBuf.Width >= Image.GraphBuf.Height then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Image.GraphBuf.Width * Image.GraphBuf.Height),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Image.GraphBuf.Height * Image.GraphBuf.Width),Image.ClientSize.Y,5);
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X,Size));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(text_x_left);
  Caption.SetTextAlignY(text_y_fit_height);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Size := Max(Size,Caption.ClientSize.Y);
  InfoContentHeight := InfoContentHeight + Size + 5;
end;
{ @end $58E238 }

{ @routine $58E4F0 TfInfo_AddPlanetInfoText }
procedure TfInfo.AddPlanetInfoText(Planet: TPlanet; Text: WideString);
var Size: Integer; Image: TGraphBufGI; Emblem: TImageGI; Caption: TLabelGI;
begin
  Text := ReplaceAllWideString(Text,TextHighlightColorTag,DialogHighlightColorTag);
  Size := GiScalePixels(64);
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Size));
  Image.SourceHasPerPixelAlpha := True;
  Planet.Graphic.RenderToBuffer(Self,Image.GraphBuf,False);
  if Image.GraphBuf.Width >= Image.GraphBuf.Height then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Image.GraphBuf.Width * Image.GraphBuf.Height),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Image.GraphBuf.Height * Image.GraphBuf.Width),Image.ClientSize.Y,5);
  if Planet.OwnerId <> owner_uninhabited then
  begin
    Emblem := TImageGI.Create(InfoPanel);
    Emblem.SetPositionModeW(True);
    Emblem.SetImagePath(GetFactionEmblemPath(Planet.GetFactionResourceName));
    Emblem.SetSize(Emblem.GetContentSize);
    Emblem.SetPosition(Types.Point(InfoPanel.ClientSize.X - Emblem.ClientSize.X - GiScalePixels(10),InfoContentHeight));
    Emblem.SetImageKindX(image_x_center);
    Emblem.SetImageKindY(image_y_center);
  end;
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X,Size));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(text_x_left);
  Caption.SetTextAlignY(text_y_fit_height);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Size := Max(Size,Caption.ClientSize.Y);
  Caption.SetTextAlignY(text_y_center);
  Caption.SetSize(Types.Point(Caption.ClientSize.X,Size));
  InfoContentHeight := InfoContentHeight + Size + 5;
end;
{ @end $58E4F0 }

{ @routine $58E870 TfInfo_AddItemInfoText }
procedure TfInfo.AddItemInfoText(Item: TItem; Text: WideString);
var Size: Integer; Image: TGraphBufGI; Caption: TLabelGI; Emblem: TImageGI;
begin
  Text := ReplaceAllWideString(Text,TextHighlightColorTag,DialogHighlightColorTag);
  Text := ReplaceAllWideString(Text,GreenColorTag,DialogGreenColorTag);
  Text := ReplaceAllWideString(Text,EquipmentBonusColorTag,DialogEquipmentBonusColorTag);
  Size := GiScalePixels(64);
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Size));
  Image.SourceHasPerPixelAlpha := True;
  LoadGiByPathIntoGraphBuf(Item.GetBitmapResourceName + 'i',Image.GraphBuf);
  if Image.GraphBuf.Width >= Image.GraphBuf.Height then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Image.GraphBuf.Width * Image.GraphBuf.Height),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Image.GraphBuf.Height * Image.GraphBuf.Width),Image.ClientSize.Y,5);
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X,Size + 20));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(text_x_left);
  Caption.SetTextAlignY(text_y_center);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  if Item is TEquipment then
  begin
    Emblem := TImageGI.Create(InfoPanel);
    Emblem.SetPositionModeW(True);
    Emblem.SetImagePath(GetFactionEmblemPath((Item as TEquipment).GetOwnerConfigName));
    Emblem.SetSize(Emblem.GetContentSize);
    Emblem.SetPosition(Types.Point(InfoPanel.ClientSize.X - Emblem.ClientSize.X - GiScalePixels(10),InfoContentHeight));
    Emblem.SetImageKindX(image_x_center);
    Emblem.SetImageKindY(image_y_center);
  end;
  InfoContentHeight := InfoContentHeight + Size + 21;
end;
{ @end $58E870 }

{ @routine $58ED54 TfInfo_AddStarInfoText }
procedure TfInfo.AddStarInfoText(Star: TStar; Text: WideString);
var Size: Integer; Image: TGraphBufGI; Emblem: TImageGI; Caption: TLabelGI;
  // @nested $58ECE8 GetInfoStarFactionName
  function GetInfoStarFactionName(Star: TStar): WideString; // @addr $58ECE8 @calls "0x0058EF0C" Nested in AddStarInfoText; static link unused.
  begin
    if Star.Status.CustomFaction <> '' then Result := Star.Status.CustomFaction
    else if Star.ControlFaction = faction_dominators then Result := DominatorSeriesNames[Star.DominatorSeries]
    else if Star.ControlFaction = faction_pirates then Result := OwnerInfo[owner_pirate].InternalName
    else Result := OwnerInfo[owner_uninhabited].InternalName;
  end;
begin
  Text := ReplaceAllWideString(Text,TextHighlightColorTag,DialogHighlightColorTag);
  Size := GiScalePixels(64);
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Size));
  Image.SourceHasPerPixelAlpha := True;
  LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TStarSE(Star.Graphic).StaticImagePath,1,','),Image.GraphBuf);
  if Image.GraphBuf.Width >= Image.GraphBuf.Height then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Image.GraphBuf.Width * Image.GraphBuf.Height),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Image.GraphBuf.Height * Image.GraphBuf.Width),Image.ClientSize.Y,5);
  if (Star.ControlFaction <> faction_coalition) or (Star.Status.CustomFaction <> '') then
  begin
    Emblem := TImageGI.Create(InfoPanel);
    Emblem.SetPositionModeW(True);
    Emblem.SetImagePath(GetFactionEmblemPath(GetInfoStarFactionName(Star)));
    Emblem.SetSize(Emblem.GetContentSize);
    Emblem.SetPosition(Types.Point(InfoPanel.ClientSize.X - Emblem.ClientSize.X - GiScalePixels(10),InfoContentHeight));
    Emblem.SetImageKindX(image_x_center);
    Emblem.SetImageKindY(image_y_center);
  end;
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X,Size));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(text_x_left);
  Caption.SetTextAlignY(text_y_fit_height);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Size := Max(Size,Caption.ClientSize.Y);
  Caption.SetTextAlignY(text_y_center);
  Caption.SetSize(Types.Point(Caption.ClientSize.X,Size));
  InfoContentHeight := InfoContentHeight + Size + 5;
end;
{ @end $58ED54 }

{ @routine $58F108 TfInfo_FocusSearchField }
procedure TfInfo.FocusSearchField(Force: Boolean);
begin
  if SearchMode then
  begin
    if SelectedSearchCategory = 0 then SetFocusedControl(GetByName('TextSearch'))
    else if (FocusedControl = nil) or Force then
    begin
      if SelectedSearchCategory = 1 then SetFocusedControl(GetByName('M01Speed'))
      else if SelectedSearchCategory = 2 then SetFocusedControl(GetByName('M02Capacity'))
      else if SelectedSearchCategory = 3 then SetFocusedControl(GetByName('M03Range'))
      else if SelectedSearchCategory = 4 then SetFocusedControl(GetByName('M04Power'))
      else if SelectedSearchCategory = 5 then SetFocusedControl(GetByName('M05Power'))
      else if SelectedSearchCategory = 6 then SetFocusedControl(GetByName('M06ObjSize'))
      else if SelectedSearchCategory = 7 then SetFocusedControl(GetByName('M07Block'))
      else if SelectedSearchCategory = 8 then SetFocusedControl(GetByName('M08Range'))
      else if SelectedSearchCategory = 9 then SetFocusedControl(GetByName('M09Const'))
      else if SelectedSearchCategory = 10 then SetFocusedControl(GetByName('M10Const'))
      else if SelectedSearchCategory = 11 then SetFocusedControl(GetByName('M11Size'))
      else if SelectedSearchCategory = 12 then SetFocusedControl(GetByName('M12DamageMin'))
      else if SelectedSearchCategory = 13 then SetFocusedControl(GetByName('M13Range'))
      else if SelectedSearchCategory = 15 then SetFocusedControl(GetByName('M15Const'));
    end;
  end
  else SetFocusedControl(nil);
end;
{ @end $58F108 }

{ @routine $58F474 TfInfo_ToggleSearchMode }
procedure TfInfo.ToggleSearchMode(Sender: TObjectGI);
begin
  SearchMode := not SearchMode;
  RefreshNewsAnimation(nil);
  (GetByName('ButSearch') as TGraphButtonGI).SetDisabled(SearchMode);
  (GetByName('ButNews') as TGraphButtonGI).SetDisabled(not SearchMode);
  GetByName('PanelSearch').SetActive(SearchMode);
  FocusSearchField(True);
  if not SearchMode then ShowNews else ShowSearch;
end;
{ @end $58F474 }

{ @routine $58F55C TfInfo_MainPanelMouseDown }
procedure TfInfo.MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  FocusSearchField(False);
end;
{ @end $58F55C }

{ @routine $58F57C TfInfo_MainPanelKeyDown }
procedure TfInfo.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
var NewPosition: Integer; Msg: TMsg;
begin
  if (Key = VK_ESCAPE) and (ParentLoop <> nil) then RequestClose(1)
  else if IsVirtualKeyDown(VK_CONTROL) then
  begin
    if Key = Ord('C') then
    begin
      if SelectedSearchCategory = 12 then CopySearch12Name(nil)
      else if SelectedSearchCategory = 15 then CopySearch15Name(nil)
      else CopySearchText(nil);
    end
    else if Key = Ord('V') then
    begin
      if SelectedSearchCategory = 12 then PasteSearch12Name(nil)
      else if SelectedSearchCategory = 15 then PasteSearch15Name(nil)
      else PasteSearchText(nil);
    end
    else if Key = VK_BACK then
    begin
      if SelectedSearchCategory = 12 then ClearSearch12Name(nil)
      else if SelectedSearchCategory = 15 then ClearSearch15Name(nil)
      else ClearSearchText(nil);
    end;
  end
  else if not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) and
    (not SearchMode or (Key < Ord('A')) or (Key > Ord('Z'))) then
  begin
    if IsAtBusinessCenter and (Key = VK_INSERT) then ToggleVisibleBookmark;
    NewPosition := InfoPanel.VerticalScrollBar.Position;
    if Key = VK_PRIOR then Dec(NewPosition,InfoPanel.VerticalScrollBar.LargeChange);
    if Key = VK_NEXT then Inc(NewPosition,InfoPanel.VerticalScrollBar.LargeChange);
    if Key = VK_UP then Dec(NewPosition,InfoPanel.VerticalScrollBar.SmallChange);
    if Key = VK_DOWN then Inc(NewPosition,InfoPanel.VerticalScrollBar.SmallChange);
    if NewPosition < InfoPanel.VerticalScrollBar.Minimum then NewPosition := InfoPanel.VerticalScrollBar.Minimum;
    if NewPosition > InfoPanel.VerticalScrollBar.Maximum then NewPosition := InfoPanel.VerticalScrollBar.Maximum;
    InfoPanel.VerticalScrollBar.SetPosition(NewPosition);
    if Key = VK_HOME then
    begin
      if not SearchMode then InfoPanel.SetScrollOffset(Types.Point(0,0));
    end
    else if Key = VK_SPACE then
    begin
      if not SearchMode and GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
    end
    else if (Key = VK_RETURN) and SearchMode then SearchClicked(nil)
    else if (Key = Ord('F')) and not SearchMode then ToggleSearchMode(nil)
    else if (Key = Ord('I')) and not SearchMode then
    begin
      PeekMessage(Msg,0,WM_CHAR,WM_CHAR,PM_REMOVE);
      ToggleSearchMode(nil);
    end
    else if Key = Ord('S') then ShipClicked(nil)
    else
    begin
      MainPanel.ProcessKeyDown(Key);
      PlanetPanel.ProcessKeyDown(Key);
      StationPanel.ProcessKeyDown(Key);
    end;
  end;
end;
{ @end $58F57C }

{ @routine $58F850 TfInfo_MainPanelKeyUp }
procedure TfInfo.MainPanelKeyUp(Sender: TObjectGI; Key: Cardinal);
begin
end;
{ @end $58F850 }

{ @routine $58F854 TfInfo_ProcessMouseWheel }
procedure TfInfo.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then InfoPanel.VerticalScrollBar.SetPosition(InfoPanel.VerticalScrollBar.Position - InfoPanel.VerticalScrollBar.SmallChange * 5)
  else if Delta = -WHEEL_DELTA then InfoPanel.VerticalScrollBar.SetPosition(InfoPanel.VerticalScrollBar.Position + InfoPanel.VerticalScrollBar.SmallChange * 5);
end;
{ @end $58F854 }

{ @routine $58F8B8 TfInfo_BookmarkClicked }
procedure TfInfo.BookmarkClicked(Sender: TObjectGI);
var Key: WideString;
begin
  SoundManager.PlaySound('Sound.UserMsgAdd');
  if Sender.UserValue <> 0 then Key := 'GOODS ' + IntToStr(Cardinal(Sender.UserValue)) else Key := '';
  AddOrUpdatePlayerBubble(message_user_note,Galaxy.CurrentTurn,Sender.HelpText,Key);
  MainPanel.RebuildMessageButtons(False);
  (Sender as TGraphButtonGI).SetDisabled(True);
  BreakUiMessage;
end;
{ @end $58F8B8 }

{ @routine $58F9CC TfInfo_SelectMusic }
procedure TfInfo.SelectMusic;
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
    if not MusicInPlanetEnabled then
    begin
      MusicManager.RequestFadeOut;
      Exit;
    end;
    if GetPlayer.DockedTo.TypeId in [station_pirate_base,station_dominion] then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end;
end;
{ @end $58F9CC }

{ @routine $58FC38 TfInfo_ShowNews }
procedure TfInfo.ShowNews;
var I: Integer; Entry: PPlanetNewsEntry; Source: WideString;
begin
  InfoPanel.SetActive(True);
  InfoPanel.VerticalScrollBar.SetActive(True);
  with GetByName('ButPrev') as TGraphButtonGI do SetActive(False);
  with GetByName('ButNext') as TGraphButtonGI do SetActive(False);
  for I := 1 to 15 do
    with GetByName('PanelM' + IntToFixedWidthWideString(I,2)) do SetActive(False);
  ClearInfoContents;
  AddInfoSpacing(10);
  for I := Galaxy.PlanetNews.Count - 1 downto 0 do
  begin
    Entry := Galaxy.PlanetNews[I];
    // Native retains this empty local string in the heading expression.
    AddInfoHeading(WrapTextInColor(Galaxy.FormatTurnDate(Entry.Turn) + Source,TextHighlightColorTag),
      WrapTextInColor(Galaxy.FormatTurnDate(Entry.Turn),TextHighlightColorTag) + #13#10 + ' ' + #13#10 + Entry.Text,1,0,0);
    AddInfoText(' .',text_x_center,'');
    AddInfoText(Entry.Text,text_x_fit_or_justify,'');
    AddInfoText(' .',text_x_center,'');
    AddInfoSpacing(10);
  end;
  FinishInfoLayout;
end;
{ @end $58FC38 }

{ @routine $58FEB4 TfInfo_ShowSearch }
procedure TfInfo.ShowSearch;
var I: Integer;
begin
  SelectedSearchCategory := 0;
  PreviousSearchCategory := 0;
  HasSearchResults := False;
  InfoPanel.SetActive(False);
  InfoPanel.VerticalScrollBar.SetActive(False);
  with GetByName('ButPrev') as TGraphButtonGI do
  begin
    UpCallback := CategoryClicked;
    SetActive(True);
    SetDisabled(True);
  end;
  with GetByName('ButNext') as TGraphButtonGI do
  begin
    UpCallback := NextSearchPageClicked;
    SetActive(True);
    SetDisabled(True);
  end;
  GetByName('PanelSearch').SetActive(True);
  for I := 1 to 15 do
  begin
    with GetByName('PanelM' + IntToFixedWidthWideString(I,2)) do SetActive(False);
    if I <> 14 then
      with GetByName('M' + IntToFixedWidthWideString(I,2) + 'Search') as TGraphButtonGI do UpCallback := SearchClicked;
  end;
  GetByName('ImgMM_C1').SetActive(False);
  GetByName('ImgMM_C2').SetActive(False);
  ClearInfoContents;
  FinishInfoLayout;
end;
{ @end $58FEB4 }

{ @routine $590124 TfInfo_SearchClicked }
procedure TfInfo.SearchClicked(Sender: TObjectGI);
begin
  RunSearch(Sender);
end;
{ @end $590124 }

{ @routine $59422C TfInfo_RunSearch }
procedure TfInfo.RunSearch(Sender: TObjectGI);
var
  Ship: TShip;
  ResultCount: Integer;
  Shown: TList;
  Found: Boolean;
  Station: TRuins;
  Description, Heading: WideString;
  Planet: TPlanet;
  Star: TStar;
  Bearing, MinSpeed, RangeFilter, SizeFilter, MaxCost: Integer;
  Owners: TOwnerMask;
  MinFuel, MinPower, MinPickup, MinDefense: Integer;
  IncludeDominators, IncludeCoalition, IncludePirates, IncludeUninhabited: Boolean;
  ConstellationFilter, StarFilter: WideString;
  StationTypes: TShipTypeMask;
  IncludeRangerType, IncludeWarriorType, IncludePirateType: Boolean;
  IncludeTransportType, IncludeLinerType, IncludeDiplomatType: Boolean;
  MinArmor, WeaponSlots, ScannerSlots, RadarSlots, DroidSlots, HookSlots: Integer;
  DefenseSlots, ArtifactSlots, AfterburnerSlots: Integer;
  IncludeEnergy, IncludeSplinter, IncludeMissile: Boolean;
  MinDamage, MaxDamage: Integer;
  NameFilter: WideString;
  I, Index, ItemIndex: Integer;
  Item: TItem;
  SearchText: WideString;
  GoodsIndex: Byte;
  Control: TObjectGI;
  StationType: TStationType;
  MinGoodsCount, MinSellPrice, MaxBuyPrice: Integer;
  GoodsSelected: array[0..7] of Boolean;
  Good: Byte;

  // @nested $59012C GetInfoQualityGrade
  function GetInfoQualityGrade(Quality: Single): WideString; // @addr $59012C @calls "0x0059085F" @ida "void __userpurge $name(unsigned __int16 **Result@<eax>, float Quality@<^0>, void *ParentFrame@<^4>);" @stackpop 4 Nested in RunSearch.
  var
    I, Grade: Integer;
    Distance, BestDistance: Single;
  begin
    Grade := 0;
    BestDistance := Abs(InfoQualityGrades[0] - Quality);
    for I := 1 to 6 do
    begin
      Distance := Abs(InfoQualityGrades[I] - Quality);
      if Distance < BestDistance then
      begin
        BestDistance := Distance;
        Grade := I;
      end;
    end;
    Result := LocalizedText('FormInfo.Equipment.QualityGrade' + IntToStr(Grade));
  end;

  // @nested $590220 GetInfoEquipmentSummary
  function GetInfoEquipmentSummary(Item: TObject): WideString; // @addr $590220 @calls "0x0059253E" Nested in RunSearch.
  var Detail, Text: WideString;
  begin
    Text := '';
    Text := Text + FormatText1(LocalizedText('FormInfo.Equipment.Cost'),TextHighlightColorTag,'<val>',IntToStr(TItem(Item).GetConditionAdjustedCost));
    if TItem(Item).ItemType in [item_hull..item_custom_weapon] then Text := Text + ', ';
    if Item is TScaner then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Scaner'),'','<val>','<Percent>');
      TEquipment(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
    end
    else if Item is TRadar then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Radar'),'','<val>','<Radius>');
      TEquipment(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
    end
    else if Item is TFuelTanks then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Fuel'),'','<val>','<Capacity>');
      TEquipment(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
    end
    else if Item is TEngine then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Speed'),'','<val>','<Speed>') + ', ' + FormatText1(LocalizedText('FormInfo.Equipment.Jump'),'','<val>','<Parsec>');
      TEquipment(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
    end
    else if Item is TRepairRobot then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Droid'),'','<val>','<RecoverHitPoints>');
      TEquipment(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
    end
    else if Item is TCargoHook then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Hook'),'','<val>','<PickUpSize>') + ', ' + FormatText1(LocalizedText('FormInfo.Equipment.HookRadius'),'','<val>','<Radius>');
      TEquipment(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
    end
    else if Item is TDefGenerator then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Defend'),'','<val>','<Percent>');
      TEquipment(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
    end
    else if Item is TWeapon then
    begin
      if (Cardinal(TWeapon(Item).GetDamageFlags) and $100000) <> 0 then
        Detail := FormatText1(LocalizedText('FormInfo.Equipment.Damage'),'','<min>-<max>','<MaxDamage><Bonus>') + ', ' +
          FormatText1(LocalizedText('FormInfo.Equipment.Radius'),'','<val>','<Radius>')
      else Detail := FormatText2(LocalizedText('FormInfo.Equipment.Damage'),'','<min>','<MinDamage>','<max>','<MaxDamage><Bonus>') + ', ' +
          FormatText1(LocalizedText('FormInfo.Equipment.Radius'),'','<val>','<Radius>');
      TWeapon(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
      if ((Item as TWeapon).SpecialModuleIndex <> 0) and
        (MicroModuleTemplates[(Item as TWeapon).SpecialModuleIndex - 1].TextReplace = '') then
        Text := Text + #13#10 + LocalizedText('Items.Weapon.WSpecial') + ' ' +
          WrapTextInColor(TEquipment(Item).GetSpecialModuleName,TextHighlightColorTag);
    end
    else if Item is THull then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Protect'),'','<val>','<HitProtect>') + #13#10 +
        LocalizedText('FormInfo.Equipment.Susceptibility');
      TEquipment(Item).ReplaceInfoTokens(Detail,TextHighlightColorTag,nil);
      Text := Text + Detail;
      if THull(Item).HullSeries <> -1 then
        Text := Text + #13#10 + FormatText1(LocalizedText('FormInfo.Equipment.Series'),TextHighlightColorTag,'<val>',HullSeriesDefinitions[THull(Item).HullSeries].Name);
    end;
    if (Item is TEquipment) and (TItem(Item).ItemType in [item_fuel_tanks..item_custom_weapon,item_satellite]) then
      Text := Text + #13#10 + FormatText1(LocalizedText('FormInfo.Equipment.Reliability'),TextHighlightColorTag,'<val>',
        GetInfoQualityGrade(TEquipment(Item).GetFragilityFactor([])));
    Result := Text;
  end;

  // @nested $590E94 AddInfoSearchResult
  procedure AddInfoSearchResult(Value: TObject); // @addr $590E94 @calls "0x00593018,0x005930BE,0x00593163,0x00593209,0x005932AF,0x00593354,0x00593408,0x005934F9,0x005936EF,0x0059383E,0x00593A52,0x00593C64,0x00593EF1,0x00596209,0x005962E8,0x0059635C,0x005963FE,0x005964A5,0x0059653A,0x00596597,0x0059666D" Nested in RunSearch; captures location, count, and displayed objects.
  var GoodsText, Color: WideString; Good, GoodIndex: TGoodsIndex;
  begin
    if (Value is TShip) and (Ship <> nil) and not (Ship.OwnerId in [owner_maloc..owner_gaal,owner_pirate]) then Exit;
    if (ResultCount < GetSearchResultLimit) and (Shown.IndexOf(Value) < 0) then
    begin
      Shown.Add(Value);
      if not Found then
      begin
        AddInfoText(FormatText1(LocalizedText('FormInfo.ObjectFoundStart'),TextHighlightColorTag,'<Count>',IntToStr(GetSearchResultLimit)),text_x_center,'');
        AddInfoText(' .',text_x_center,'');
      end;
      if (Value is TRuins) and not TRuins(Value).NoLanding then
      begin
        Station := Value as TRuins;
        Description := FormatText1(LocalizedText('FormInfo.Sector'),TextHighlightColorTag,'<SectorName>',Station.CurrentStar.Constellation.GetName);
        Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),TextHighlightColorTag,'<StarName>',Station.CurrentStar.Name);
        GoodsText := '';
        for GoodIndex := Low(GoodsTextOrder) to High(GoodsTextOrder) do
        begin
          Good := GoodsTextOrder[GoodIndex];
          GoodsText := GoodsText + #13#10 + '<td=' + IntToStr(GiScalePixels(5)) + '>' + '<align=center>' + WrapTextInColor(IntToStr(GoodIndex + 1),'') + '.' + '</align>';
          Color := '';
          GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(15)) + '>' + WideString('') + WrapTextInColor(GoodsMarket[Good].DisplayName,Color) + WideString('');
          GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(160)) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Station.ShopGoods[Good].Count),'') + '</align>';
          GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(205)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good,Station)),'') + '</align>';
          GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(215)) + '><align=center>' + WrapTextInColor('/','') + '</align>';
          GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(255)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good,Station)),'') + '</align>';
        end;
        Description := Description + GoodsText;
        Heading := WrapTextInColor('- ' + WrapTextInColor(Station.GetFullName(' '),TextHighlightColorTag) + ' -',TextHighlightColorTag);
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,Integer(Station.Id or $80000000));
        AddInfoText(' .',text_x_center,'');
        AddInfoImageText(ExtractDelimitedPartW(Station.GetShipPortraitImagePath,1,','),Description);
      end
      else if Value is TShip then
      begin
        Description := FormatText1(LocalizedText('FormInfo.Sector'),TextHighlightColorTag,'<SectorName>',Ship.CurrentStar.Constellation.GetName);
        Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),TextHighlightColorTag,'<StarName>',Ship.CurrentStar.Name);
        if Ship.CurrentPlanet <> nil then
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Planet'),TextHighlightColorTag,'<PlanetName>',Ship.CurrentPlanet.Name);
        if Ship.IsInPrison then Description := Description + #13#10 + LocalizedText('FormInfo.InPrison');
        Ship.DaysSincePlayerSeen := 0;
        Heading := WrapTextInColor('- ' + WrapTextInColor(Ship.GetFullName(' '),TextHighlightColorTag) + ' -',TextHighlightColorTag);
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,0);
        AddInfoText(' .',text_x_center,'');
        AddInfoImageText(ExtractDelimitedPartW(Ship.GetShipPortraitImagePath,1,','),Description);
      end
      else if Value is TPlanet then
      begin
        Description := FormatText1(LocalizedText('FormInfo.Sector'),TextHighlightColorTag,'<SectorName>',Planet.CurrentStar.Constellation.GetName);
        Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),TextHighlightColorTag,'<StarName>',Planet.CurrentStar.Name);
        Description := Description + #13#10 + Planet.GetInfoText(True);
        GoodsText := '';
        if (Planet.IsCoalitionOwned or (Planet.OwnerId = owner_pirate)) and (Planet.CurrentStar.Status.CustomFaction = '') then
        begin
          for GoodIndex := Low(GoodsTextOrder) to High(GoodsTextOrder) do
          begin
            Good := GoodsTextOrder[GoodIndex];
            GoodsText := GoodsText + #13#10 + '<td=' + IntToStr(GiScalePixels(5)) + '>' + '<align=center>' + WrapTextInColor(IntToStr(GoodIndex + 1),'') + '.' + '</align>';
            if GoodsLegalOnPlanet[Good,Planet.RaceId, Planet.Government] or (Planet.OwnerId = owner_pirate) then Color := ''
            else Color := RedColorTag;
            GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(15)) + '>' + WideString('') + WrapTextInColor(GoodsMarket[Good].DisplayName,Color) + WideString('');
            GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(160)) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Planet.Goods[Good].Count),'') + '</align>';
            GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(205)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good,Planet)),'') + '</align>';
            GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(215)) + '><align=center>' + WrapTextInColor('/','') + '</align>';
            GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(255)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good,Planet)),'') + '</align>';
          end;
        end;
        Description := Description + GoodsText;
        Heading := WrapTextInColor('- ' + WrapTextInColor(Planet.GetFullName(' '),TextHighlightColorTag) + ' -',TextHighlightColorTag);
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,Planet.Id);
        AddInfoText(' .',text_x_center,'');
        AddPlanetInfoText(Value as TPlanet,Description);
      end
      else if Value is TStar then
      begin
        Description := FormatText1(LocalizedText('FormInfo.Sector'),TextHighlightColorTag,'<SectorName>',Star.Constellation.GetName);
        Heading := FormatText1('- ' + LocalizedText('FormInfo.StarInfo.StarName') + ' -',TextHighlightColorTag,'<StarName>',(Value as TStar).Name);
        if TStar(Value).Status.CustomFaction <> '' then
          Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.ControlledBy' + TStar(Value).Status.CustomFaction)
        else
          case TStar(Value).ControlFaction of
            faction_coalition: Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.ControlledByCoalition');
            faction_pirates: Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.ControlledByPirates');
            faction_dominators: Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.ControlledByDominators');
          end;
        if GetPlayer.CurrentStar <> Value then
        begin
          Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.RelativeLocation');
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.StarInfo.RelativeLocationDist'),TextHighlightColorTag,'<Dist>',IntToStr(Round(PointDistance((Value as TStar).Position,GetPlayer.CurrentStar.Position))));
          Bearing := Round(PointBearingDegrees((Value as TStar).Position,GetPlayer.CurrentStar.Position));
          Bearing := Bearing + 180 - 15;
          if Bearing >= 360 then Dec(Bearing,360);
          Bearing := Bearing div 30 + 1;
          if Bearing = 1 then
            Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.StarInfo.RelativeLocationAngle0'),TextHighlightColorTag,'<Angle>',IntToStr(Bearing));
          if (Bearing > 1) and (Bearing <= 4) then
            Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.StarInfo.RelativeLocationAngle1'),TextHighlightColorTag,'<Angle>',IntToStr(Bearing));
          if Bearing > 4 then
            Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.StarInfo.RelativeLocationAngle2'),TextHighlightColorTag,'<Angle>',IntToStr(Bearing));
        end;
        if (Value as TStar).Battle <> 0 then Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.BattleInSystem');
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,0);
        AddInfoText(' .',text_x_center,'');
        AddStarInfoText(Value as TStar,Description);
      end
      else if Value is TEquipment then
      begin
        if Planet <> nil then
        begin
          Description := FormatText1(LocalizedText('FormInfo.Sector'),TextHighlightColorTag,'<SectorName>',Planet.CurrentStar.Constellation.GetName);
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),TextHighlightColorTag,'<StarName>',Planet.CurrentStar.Name);
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Planet'),TextHighlightColorTag,'<PlanetName>',Planet.Name);
        end
        else
        begin
          Description := FormatText1(LocalizedText('FormInfo.Sector'),TextHighlightColorTag,'<SectorName>',Ship.CurrentStar.Constellation.GetName);
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),TextHighlightColorTag,'<StarName>',Ship.CurrentStar.Name);
          Description := Description + #13#10 + WrapTextInColor(Ship.GetFullName(' '),TextHighlightColorTag);
        end;
        Heading := WrapTextInColor('- ' + WrapTextInColor(RemoveTextTagsW(TItem(Value).GetDisplayName),TextHighlightColorTag) + ' [' +
          WrapTextInColor(IntToStr(TItem(Value).Weight),GreenColorTag) + ']' + ' -',TextHighlightColorTag);
        Description := Description + #13#10 + GetInfoEquipmentSummary(Value);
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,0);
        AddInfoText(' .',text_x_center,'');
        if Value is THull then AddEquipmentInfoText(Value as TItem,Description)
        else AddItemInfoText(Value as TItem,Description);
      end;
      Found := True;
      Inc(ResultCount);
    end;
  end;

  // @nested $592F38 CheckInfoSearchResult
  procedure CheckInfoSearchResult(Value: TObject); // @addr $592F38 @calls "0x00596215,0x005962F4,0x00596367,0x00596409,0x005964B1,0x00596545,0x005965A2,0x00596679" Nested in RunSearch; applies the active category filters.
  var
    Engine: TEngine; Fuel: TFuelTanks; Radar: TRadar; Scanner: TScaner;
    Droid: TRepairRobot; Hook: TCargoHook; Defense: TDefGenerator;
    CandidateStar: TStar; CandidatePlanet: TPlanet; CandidateStation: TRuins;
    Hull: THull; Weapon: TWeapon; CandidateShip: TShip;
    I, EffectiveRange: Integer; Entry: PExtraSpecial;
  begin
    if SelectedSearchCategory = 1 then
    begin
      if not (Value is TEngine) then Exit;
      Engine := Value as TEngine;
      if (MinSpeed <> 0) and (Engine.Speed < MinSpeed) then Exit;
      if (RangeFilter <> 0) and (Engine.JumpRange < RangeFilter) then Exit;
      if (SizeFilter <> 0) and (Engine.Weight > SizeFilter) then Exit;
      if (MaxCost <> 0) and (Engine.GetConditionAdjustedCost > MaxCost) then Exit;
      if not (Engine.OwnerId in Owners) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 2 then
    begin
      if not (Value is TFuelTanks) then Exit;
      Fuel := Value as TFuelTanks;
      if (MinFuel <> 0) and (Fuel.Capacity < MinFuel) then Exit;
      if (SizeFilter <> 0) and (Fuel.Weight > SizeFilter) then Exit;
      if (MaxCost <> 0) and (Fuel.GetConditionAdjustedCost > MaxCost) then Exit;
      if not (Fuel.OwnerId in Owners) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 3 then
    begin
      if not (Value is TRadar) then Exit;
      Radar := Value as TRadar;
      if (RangeFilter <> 0) and (Radar.Range < RangeFilter) then Exit;
      if (SizeFilter <> 0) and (Radar.Weight > SizeFilter) then Exit;
      if (MaxCost <> 0) and (Radar.GetConditionAdjustedCost > MaxCost) then Exit;
      if not (Radar.OwnerId in Owners) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 4 then
    begin
      if not (Value is TScaner) then Exit;
      Scanner := Value as TScaner;
      if (MinPower <> 0) and (Scanner.ScanPower < MinPower) then Exit;
      if (SizeFilter <> 0) and (Scanner.Weight > SizeFilter) then Exit;
      if (MaxCost <> 0) and (Scanner.GetConditionAdjustedCost > MaxCost) then Exit;
      if not (Scanner.OwnerId in Owners) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 5 then
    begin
      if not (Value is TRepairRobot) then Exit;
      Droid := Value as TRepairRobot;
      if (MinPower <> 0) and (Droid.RepairPoints < MinPower) then Exit;
      if (SizeFilter <> 0) and (Droid.Weight > SizeFilter) then Exit;
      if (MaxCost <> 0) and (Droid.GetConditionAdjustedCost > MaxCost) then Exit;
      if not (Droid.OwnerId in Owners) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 6 then
    begin
      if not (Value is TCargoHook) then Exit;
      Hook := Value as TCargoHook;
      if (MinPickup <> 0) and (Hook.PickupPower < MinPickup) then Exit;
      if (SizeFilter <> 0) and (Hook.Weight > SizeFilter) then Exit;
      if (MaxCost <> 0) and (Hook.GetConditionAdjustedCost > MaxCost) then Exit;
      if not (Hook.OwnerId in Owners) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 7 then
    begin
      if not (Value is TDefGenerator) then Exit;
      Defense := Value as TDefGenerator;
      if (MinDefense <> 0) and (DefenseDamageFactorToPercent(Defense.DamageFactor) < MinDefense) then Exit;
      if (SizeFilter <> 0) and (Defense.Weight > SizeFilter) then Exit;
      if (MaxCost <> 0) and (Defense.GetConditionAdjustedCost > MaxCost) then Exit;
      if not (Defense.OwnerId in Owners) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 8 then
    begin
      if not (Value is TStar) then Exit;
      CandidateStar := Value as TStar;
      if (CandidateStar.ControlFaction = faction_dominators) and not IncludeDominators then Exit;
      if (CandidateStar.ControlFaction = faction_coalition) and not IncludeCoalition then Exit;
      if (CandidateStar.ControlFaction = faction_pirates) and not IncludePirates then Exit;
      if (CandidateStar.Status.CustomFaction <> '') and (not IncludeDominators or not IncludeCoalition or not IncludePirates) then Exit;
      if (RangeFilter <> 0) and (RangeFilter < Round(PointDistance(CandidateStar.Position,GetPlayer.CurrentStar.Position))) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 9 then
    begin
      if not (Value is TPlanet) then Exit;
      CandidatePlanet := Value as TPlanet;
      if (CandidatePlanet.OwnerId = owner_dominator) and (CandidatePlanet.CurrentStar.Status.CustomFaction = '') and not IncludeDominators then Exit;
      if (CandidatePlanet.OwnerId in [owner_maloc..owner_gaal,owner_pirate]) and (CandidatePlanet.CurrentStar.Status.CustomFaction = '') and not IncludeCoalition then Exit;
      if (CandidatePlanet.CurrentStar.Status.CustomFaction <> '') and (not IncludeDominators or not IncludeCoalition) then Exit;
      if (CandidatePlanet.OwnerId = owner_uninhabited) and not IncludeUninhabited then Exit;
      if ((CandidatePlanet.OwnerId = owner_pirate) and (CandidatePlanet.CurrentStar.Status.CustomFaction = '') and
        (CandidatePlanet.OwnerId in Owners) and IncludeCoalition) or
        (RaceToOwner(CandidatePlanet.RaceId) in Owners) or (CandidatePlanet.CurrentStar.Status.CustomFaction <> '') or
        (not IncludeDominators and not IncludeCoalition) then
      begin
        if (RangeFilter <> 0) and (RangeFilter < Round(PointDistance(CandidatePlanet.CurrentStar.Position,GetPlayer.CurrentStar.Position))) then Exit;
        if (ConstellationFilter <> '') and (FindLowercaseInfoText(ConstellationFilter,WideLowerCase(CandidatePlanet.CurrentStar.Constellation.GetName)) <= 0) then Exit;
        if (StarFilter <> '') and (FindLowercaseInfoText(StarFilter,WideLowerCase(CandidatePlanet.CurrentStar.Name)) <= 0) then Exit;
        AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 10 then
    begin
      if not (Value is TRuins) then Exit;
      CandidateStation := Value as TRuins;
      if CandidateStation.TypeNameOverrideKey <> '' then
      begin
        if StationTypes <> [] then Exit;
      end
      else if not (CandidateStation.TypeId in StationTypes) then Exit;
      if CandidateStation.OwnerId = owner_dominator then Exit;
      if CandidateStation.HasIndependentScriptFaction then Exit;
      if (RangeFilter <> 0) and (RangeFilter < Round(PointDistance(CandidateStation.CurrentStar.Position,GetPlayer.CurrentStar.Position))) then Exit;
      if (ConstellationFilter <> '') and (FindLowercaseInfoText(ConstellationFilter,WideLowerCase(CandidateStation.CurrentStar.Constellation.GetName)) <= 0) then Exit;
      if (StarFilter <> '') and (FindLowercaseInfoText(StarFilter,WideLowerCase(CandidateStation.CurrentStar.Name)) <= 0) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 11 then
    begin
      if not (Value is THull) then Exit;
      Hull := Value as THull;
      if not (Hull.OwnerId in Owners) then Exit;
      if (Hull.HullType = hull_ranger) and not IncludeRangerType then Exit;
      if (Hull.HullType = hull_warrior) and not IncludeWarriorType then Exit;
      if (Hull.HullType = hull_pirate) and not IncludePirateType then Exit;
      if (Hull.HullType = hull_transport) and not IncludeTransportType then Exit;
      if (Hull.HullType = hull_liner) and not IncludeLinerType then Exit;
      if (Hull.HullType = hull_diplomat) and not IncludeDiplomatType then Exit;
      if (SizeFilter <> 0) and (Hull.Weight < SizeFilter) then Exit;
      if (MinArmor <> 0) and (Hull.Armor < MinArmor) then Exit;
      if (MaxCost <> 0) and (Hull.GetConditionAdjustedCost > MaxCost) then Exit;
      if (WeaponSlots <> 0) and (Hull.GetSlotCount(slot_weapon) < WeaponSlots) then Exit;
      if (ScannerSlots <> 0) and (Hull.GetSlotCount(slot_scanner) < ScannerSlots) then Exit;
      if (RadarSlots <> 0) and (Hull.GetSlotCount(slot_radar) < RadarSlots) then Exit;
      if (DroidSlots <> 0) and (Hull.GetSlotCount(slot_repair_robot) < DroidSlots) then Exit;
      if (HookSlots <> 0) and (Hull.GetSlotCount(slot_cargo_hook) < HookSlots) then Exit;
      if (DefenseSlots <> 0) and (Hull.GetSlotCount(slot_defense_generator) < DefenseSlots) then Exit;
      if (ArtifactSlots <> 0) and (Hull.GetSlotCount(slot_artefact) < ArtifactSlots) then Exit;
      if (AfterburnerSlots <> 0) and (Hull.GetSlotCount(slot_afterburner) < AfterburnerSlots) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 12 then
    begin
      if not (Value is TWeapon) then Exit;
      Weapon := Value as TWeapon;
      if not (Weapon.OwnerId in Owners) then Exit;
      if RangeFilter <> 0 then
      begin
        EffectiveRange := Weapon.Range;
        if Weapon.ExtraSpecials <> nil then
          for I := 0 to Weapon.ExtraSpecials.Count - 1 do
          begin
            Entry := Weapon.ExtraSpecials[I];
            Inc(EffectiveRange,MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonus_weapon_range] * Entry.Count);
          end;
        if Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
          EffectiveRange := Min(EffectiveRange - Weapon.CalculateGeneratedRange + Weapon.GetWeaponInfo.MissileRange,Weapon.GetWeaponInfo.MissileRange);
        if RangeFilter > EffectiveRange then Exit;
      end;
      if (SizeFilter <> 0) and (Weapon.Weight > SizeFilter) then Exit;
      if (MaxCost <> 0) and (Weapon.GetConditionAdjustedCost > MaxCost) then Exit;
      if ((Cardinal(Weapon.GetDamageFlags) and 1) <> 0) and not IncludeEnergy then Exit;
      if ((Cardinal(Weapon.GetDamageFlags) and 2) <> 0) and not IncludeSplinter then Exit;
      if (Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) and not IncludeMissile then Exit;
      if MinDamage <> 0 then
      begin
        if (Cardinal(Weapon.GetDamageFlags) and $100000) <> 0 then
        begin
          if MinDamage > Max(Weapon.MaxDamage,Weapon.MinDamage) then Exit;
        end
        else if Weapon.MinDamage < MinDamage then Exit;
      end;
      if (MaxDamage <> 0) and (Weapon.MaxDamage < MaxDamage) then Exit;
      if (NameFilter <> '') and not ItemMatchesInfoSearch(Weapon,NameFilter) then Exit;
      AddInfoSearchResult(Value);
    end
    else if SelectedSearchCategory = 15 then
    begin
      if not (Value is TShip) then Exit;
      CandidateShip := Value as TShip;
      if not (CandidateShip.OwnerId in Owners) then Exit;
      if not (RaceToOwner(CandidateShip.PilotRace) in Owners) and (Owners <> [owner_pirate]) then Exit;
      if CandidateShip.HasScriptStateText then Exit;
      if not (CandidateShip.TypeId in [ship_ranger..ship_warrior]) then Exit;
      if (CandidateShip.TypeNameOverrideKey <> '') and
        not (IncludeRangerType and IncludeWarriorType and IncludePirateType and IncludeTransportType and IncludeLinerType and IncludeDiplomatType) then Exit;
      if (CandidateShip.TypeId = ship_ranger) and not IncludeRangerType then Exit;
      if (CandidateShip.TypeId = ship_warrior) and not IncludeWarriorType then Exit;
      if (CandidateShip.TypeId = ship_pirate) and not IncludePirateType then Exit;
      if (CandidateShip.TypeId = ship_transport) and ((CandidateShip as TTransport).TransportType = transport_standard) and not IncludeTransportType then Exit;
      if (CandidateShip.TypeId = ship_transport) and ((CandidateShip as TTransport).TransportType = transport_liner) and not IncludeLinerType then Exit;
      if (CandidateShip.TypeId = ship_transport) and ((CandidateShip as TTransport).TransportType = transport_diplomat) and not IncludeDiplomatType then Exit;
      if (ConstellationFilter <> '') and (FindLowercaseInfoText(ConstellationFilter,WideLowerCase(CandidateShip.CurrentStar.Constellation.GetName)) <= 0) then Exit;
      if (StarFilter <> '') and (FindLowercaseInfoText(StarFilter,WideLowerCase(CandidateShip.CurrentStar.Name)) <= 0) then Exit;
      if (NameFilter <> '') and (FindLowercaseInfoText(NameFilter,WideLowerCase(CandidateShip.GetFullName(' '))) <= 0) and
        (FindLowercaseInfoText(NameFilter,WideLowerCase(CandidateShip.GetLocalizedTypeName)) <= 0) then Exit;
      AddInfoSearchResult(Value);
    end;
  end;

  // @nested $593F30 ReadInfoSearchOwners
  procedure ReadInfoSearchOwners(Category: Integer); // @addr $593F30 @calls "0x00594525,0x005945B1,0x0059463D,0x005946C9,0x00594755,0x005947E1,0x0059486D,0x00594A1B,0x00594F6F,0x005950F6,0x0059616D" Nested in RunSearch; captures the owner filter set.
  begin
    Owners := [];
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Maloc') as TGraphButtonGI).Down then Include(Owners, owner_maloc);
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Peleng') as TGraphButtonGI).Down then Include(Owners, owner_peleng);
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'People') as TGraphButtonGI).Down then Include(Owners, owner_human);
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Fei') as TGraphButtonGI).Down then Include(Owners, owner_feyan);
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Gaal') as TGraphButtonGI).Down then Include(Owners, owner_gaal);
    if FindControlByPath('M' + IntToFixedWidthWideString(Category,2) + 'Pirate') <> nil then
      if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Pirate') as TGraphButtonGI).Down then Include(Owners, owner_pirate);
    if Owners = [] then Owners := [owner_pirate];
  end;

begin
  PreviousSearchCategory := SelectedSearchCategory;
  HasSearchResults := True;
  InfoPanel.SetActive(True);
  InfoPanel.VerticalScrollBar.SetActive(True);
  GetByName('PanelSearch').SetActive(False);
  for I := 1 to 15 do
    with GetByName('PanelM' + IntToFixedWidthWideString(I,2)) do SetActive(False);
  with GetByName('ButPrev') as TGraphButtonGI do SetDisabled(False);
  with GetByName('ButNext') as TGraphButtonGI do SetDisabled(True);
  if GetPlayer.Money < 3 then
  begin
    ClearInfoContents;
    AddInfoText(FormatText1(LocalizedText('FormInfo.NotMoney'),TextHighlightColorTag,'<Money>',IntToStr(3)),text_x_center,'');
    FinishInfoLayout;
    MainPanel.FlashMoneyWarning;
  end
  else
  begin
    Shown := TList.Create;
    Galaxy.CheckIntegrityChecksum(207);
    Found := False;
    ResultCount := 0;
    ClearInfoContents;
    AddInfoSpacing(10);
    SearchText := TrimWideString(WideLowerCase((GetByName('TextSearch') as TEditGI).Text));
    if SearchText = '' then SearchText := '   ';
    if SelectedSearchCategory = 1 then
    begin
      MinSpeed := ExtractDigitsToIntW((GetByName('M01Speed') as TEditGI).Text);
      RangeFilter := ExtractDigitsToIntW((GetByName('M01Range') as TEditGI).Text);
      SizeFilter := ExtractDigitsToIntW((GetByName('M01Size') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M01Cost') as TEditGI).Text);
      ReadInfoSearchOwners(1);
    end
    else if SelectedSearchCategory = 2 then
    begin
      MinFuel := ExtractDigitsToIntW((GetByName('M02Capacity') as TEditGI).Text);
      SizeFilter := ExtractDigitsToIntW((GetByName('M02Size') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M02Cost') as TEditGI).Text);
      ReadInfoSearchOwners(2);
    end
    else if SelectedSearchCategory = 3 then
    begin
      RangeFilter := ExtractDigitsToIntW((GetByName('M03Range') as TEditGI).Text);
      SizeFilter := ExtractDigitsToIntW((GetByName('M03Size') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M03Cost') as TEditGI).Text);
      ReadInfoSearchOwners(3);
    end
    else if SelectedSearchCategory = 4 then
    begin
      MinPower := ExtractDigitsToIntW((GetByName('M04Power') as TEditGI).Text);
      SizeFilter := ExtractDigitsToIntW((GetByName('M04Size') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M04Cost') as TEditGI).Text);
      ReadInfoSearchOwners(4);
    end
    else if SelectedSearchCategory = 5 then
    begin
      MinPower := ExtractDigitsToIntW((GetByName('M05Power') as TEditGI).Text);
      SizeFilter := ExtractDigitsToIntW((GetByName('M05Size') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M05Cost') as TEditGI).Text);
      ReadInfoSearchOwners(5);
    end
    else if SelectedSearchCategory = 6 then
    begin
      MinPickup := ExtractDigitsToIntW((GetByName('M06ObjSize') as TEditGI).Text);
      SizeFilter := ExtractDigitsToIntW((GetByName('M06Size') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M06Cost') as TEditGI).Text);
      ReadInfoSearchOwners(6);
    end
    else if SelectedSearchCategory = 7 then
    begin
      MinDefense := ExtractDigitsToIntW((GetByName('M07Block') as TEditGI).Text);
      SizeFilter := ExtractDigitsToIntW((GetByName('M07Size') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M07Cost') as TEditGI).Text);
      ReadInfoSearchOwners(7);
    end
    else if SelectedSearchCategory = 8 then
    begin
      IncludeCoalition := (GetByName('M08CtrlCol') as TGraphButtonGI).Down;
      IncludeDominators := (GetByName('M08CtrlDom') as TGraphButtonGI).Down;
      IncludePirates := (GetByName('M08CtrlPirate') as TGraphButtonGI).Down;
      RangeFilter := ExtractDigitsToIntW((GetByName('M08Range') as TEditGI).Text);
    end
    else if SelectedSearchCategory = 9 then
    begin
      ConstellationFilter := TrimWideString(WideLowerCase((GetByName('M09Const') as TEditGI).Text));
      StarFilter := TrimWideString(WideLowerCase((GetByName('M09Star') as TEditGI).Text));
      IncludeCoalition := (GetByName('M09CtrlCol') as TGraphButtonGI).Down;
      IncludeDominators := (GetByName('M09CtrlDom') as TGraphButtonGI).Down;
      IncludeUninhabited := (GetByName('M09CtrlNo') as TGraphButtonGI).Down;
      RangeFilter := ExtractDigitsToIntW((GetByName('M09Range') as TEditGI).Text);
      ReadInfoSearchOwners(9);
    end
    else if SelectedSearchCategory = 10 then
    begin
      ConstellationFilter := TrimWideString(WideLowerCase((GetByName('M10Const') as TEditGI).Text));
      StarFilter := TrimWideString(WideLowerCase((GetByName('M10Star') as TEditGI).Text));
      StationTypes := [];
      for StationType := station_ranger_center to station_dominion do
      begin
        Control := FindControlByPath('M10Type' + ShipTypeNames[StationType].Name);
        if (Control <> nil) and (Control as TGraphButtonGI).Down then Include(StationTypes,StationType);
      end;
      RangeFilter := ExtractDigitsToIntW((GetByName('M10Range') as TEditGI).Text);
    end
    else if SelectedSearchCategory = 11 then
    begin
      IncludeRangerType := (GetByName('M11TypeRanger') as TGraphButtonGI).Down;
      IncludeWarriorType := (GetByName('M11TypeWarrior') as TGraphButtonGI).Down;
      IncludePirateType := (GetByName('M11TypePirat') as TGraphButtonGI).Down;
      IncludeTransportType := (GetByName('M11TypeTransport') as TGraphButtonGI).Down;
      IncludeLinerType := (GetByName('M11TypeLiner') as TGraphButtonGI).Down;
      IncludeDiplomatType := (GetByName('M11TypeDiplomat') as TGraphButtonGI).Down;
      SizeFilter := ExtractDigitsToIntW((GetByName('M11Size') as TEditGI).Text);
      MinArmor := ExtractDigitsToIntW((GetByName('M11Def') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M11Cost') as TEditGI).Text);
      WeaponSlots := 0;
      if (GetByName('M11S01') as TGraphButtonGI).Down then Inc(WeaponSlots);
      if (GetByName('M11S02') as TGraphButtonGI).Down then Inc(WeaponSlots);
      if (GetByName('M11S03') as TGraphButtonGI).Down then Inc(WeaponSlots);
      if (GetByName('M11S04') as TGraphButtonGI).Down then Inc(WeaponSlots);
      if (GetByName('M11S05') as TGraphButtonGI).Down then Inc(WeaponSlots);
      ScannerSlots := 0;
      if (GetByName('M11S08') as TGraphButtonGI).Down then Inc(ScannerSlots);
      RadarSlots := 0;
      if (GetByName('M11S09') as TGraphButtonGI).Down then Inc(RadarSlots);
      DroidSlots := 0;
      if (GetByName('M11S10') as TGraphButtonGI).Down then Inc(DroidSlots);
      HookSlots := 0;
      if (GetByName('M11S11') as TGraphButtonGI).Down then Inc(HookSlots);
      DefenseSlots := 0;
      if (GetByName('M11S12') as TGraphButtonGI).Down then Inc(DefenseSlots);
      ArtifactSlots := 0;
      if (GetByName('M11S13') as TGraphButtonGI).Down then Inc(ArtifactSlots);
      if (GetByName('M11S14') as TGraphButtonGI).Down then Inc(ArtifactSlots);
      if (GetByName('M11S15') as TGraphButtonGI).Down then Inc(ArtifactSlots);
      if (GetByName('M11S16') as TGraphButtonGI).Down then Inc(ArtifactSlots);
      for I := 18 to DefaultHullSlotCounts[slot_artefact] + 13 do
      begin
        Control := FindControlByPath('M11S' + IntToWideString(I));
        if (Control <> nil) and (Control as TGraphButtonGI).Down then Inc(ArtifactSlots);
      end;
      AfterburnerSlots := 0;
      if (GetByName('M11S17') as TGraphButtonGI).Down then Inc(AfterburnerSlots);
      ReadInfoSearchOwners(11);
    end
    else if SelectedSearchCategory = 12 then
    begin
      MinDamage := ExtractDigitsToIntW((GetByName('M12DamageMin') as TEditGI).Text);
      MaxDamage := ExtractDigitsToIntW((GetByName('M12DamageMax') as TEditGI).Text);
      RangeFilter := ExtractDigitsToIntW((GetByName('M12Range') as TEditGI).Text);
      NameFilter := TrimWideString(WideLowerCase((GetByName('M12Name') as TEditGI).Text));
      SizeFilter := ExtractDigitsToIntW((GetByName('M12Size') as TEditGI).Text);
      MaxCost := ExtractDigitsToIntW((GetByName('M12Cost') as TEditGI).Text);
      IncludeEnergy := (GetByName('M12TypeEne') as TGraphButtonGI).Down;
      IncludeSplinter := (GetByName('M12TypeOsk') as TGraphButtonGI).Down;
      IncludeMissile := (GetByName('M12TypeRak') as TGraphButtonGI).Down;
      ReadInfoSearchOwners(12);
    end
    else if SelectedSearchCategory = 13 then
    begin
      MinGoodsCount := ExtractDigitsToIntW((GetByName('M13Cnt') as TEditGI).Text);
      MinSellPrice := ExtractDigitsToIntW((GetByName('M13PriceBuy') as TEditGI).Text);
      MaxBuyPrice := ExtractDigitsToIntW((GetByName('M13PriceSell') as TEditGI).Text);
      RangeFilter := ExtractDigitsToIntW((GetByName('M13Range') as TEditGI).Text);
      GoodsSelected[0] := not (GetByName('M13Goods0') as TGraphButtonGI).Down;
      GoodsSelected[1] := not (GetByName('M13Goods1') as TGraphButtonGI).Down;
      GoodsSelected[5] := not (GetByName('M13Goods2') as TGraphButtonGI).Down;
      GoodsSelected[4] := not (GetByName('M13Goods3') as TGraphButtonGI).Down;
      GoodsSelected[3] := not (GetByName('M13Goods4') as TGraphButtonGI).Down;
      GoodsSelected[2] := not (GetByName('M13Goods5') as TGraphButtonGI).Down;
      GoodsSelected[6] := not (GetByName('M13Goods6') as TGraphButtonGI).Down;
      GoodsSelected[7] := not (GetByName('M13Goods7') as TGraphButtonGI).Down;
      for I := 0 to Galaxy.Stars.Count - 1 do
      begin
        if ResultCount >= GetSearchResultLimit then Break;
        Star := GetPlayer.CurrentStar.StarDistances[I].Star as TStar;
        if (Star.Id = 71) or (Star.Id = 72) then Continue;
        if (RangeFilter <> 0) and (RangeFilter < Round(PointDistance(Star.Position,GetPlayer.CurrentStar.Position))) then Continue;
        if Star.Status.CustomFaction <> '' then Continue;
        for Index := 0 to Star.Planets.Count - 1 do
        begin
          if ResultCount >= GetSearchResultLimit then Break;
          Planet := Star.Planets[Index];
          if not (Planet.OwnerId in [owner_maloc..owner_gaal,owner_pirate]) then Continue;
          Heading := '';
          for GoodsIndex := Low(GoodsTextOrder) to High(GoodsTextOrder) do
          begin
            Good := GoodsTextOrder[GoodsIndex];
            if (MinGoodsCount <> 0) and (Planet.Goods[Good].Count < MinGoodsCount) then Continue;
            if not GoodsSelected[Good] then Continue;
            if (MaxBuyPrice <> 0) and (GetPlayer.ShopGoodsPurchasePrice(Good,Planet) > MaxBuyPrice) then Continue;
            if (MinSellPrice <> 0) and (GetPlayer.ShopGoodsSellPrice(Good,Planet) < MinSellPrice) then Continue;
            Heading := Heading + #13#10 + '<td=' + IntToStr(GiScalePixels(5)) + '>' + '<align=center>' + WrapTextInColor(IntToStr(GoodsIndex + 1),'') + '.' + '</align>';
            if GoodsLegalOnPlanet[Good,Planet.RaceId, Planet.Government] or (Planet.OwnerId = owner_pirate) then SearchText := ''
            else SearchText := RedColorTag;
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(15)) + '>' + WideString('') + WrapTextInColor(GoodsMarket[Good].DisplayName,SearchText) + WideString('');
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(160)) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Planet.Goods[Good].Count),'') + '</align>';
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(205)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good,Planet)),'') + '</align>';
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(215)) + '><align=center>' + WrapTextInColor('/','') + '</align>';
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(255)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good,Planet)),'') + '</align>';
          end;
          if Heading = '' then Continue;
          Description := FormatText1(LocalizedText('FormInfo.Sector'),TextHighlightColorTag,'<SectorName>',Planet.CurrentStar.Constellation.GetName);
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),TextHighlightColorTag,'<StarName>',Planet.CurrentStar.Name);
          Description := Description + #13#10 + Planet.GetInfoText(False);
          Description := Description + Heading;
          Heading := WrapTextInColor('- ' + WrapTextInColor(Planet.GetFullName(' '),TextHighlightColorTag) + ' -',TextHighlightColorTag);
          AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,Planet.Id);
          AddInfoText(' .',text_x_center,'');
          AddPlanetInfoText(Planet,Description);
          Found := True;
          Inc(ResultCount);
        end;
        Planet := nil;
        for Index := 0 to Star.Ships.Count - 1 do
        begin
          Ship := Star.Ships[Index];
          if not (Ship is TRuins) then Continue;
          if (Ship.CurrentPlanet <> nil) and (Ship.CurrentPlanet.OwnerId = owner_uninhabited) then Continue;
          Station := Ship as TRuins;
          // Native exits here, bypassing the later list release and checksum.
          if (Station.OwnerId = owner_dominator) or Station.HasIndependentScriptFaction then Exit;
          if Station.NoLanding then Continue;
          Heading := '';
          for GoodsIndex := Low(GoodsTextOrder) to High(GoodsTextOrder) do
          begin
            Good := GoodsTextOrder[GoodsIndex];
            if (MinGoodsCount <> 0) and (Station.ShopGoods[Good].Count < MinGoodsCount) then Continue;
            if not GoodsSelected[Good] then Continue;
            if (MaxBuyPrice <> 0) and (GetPlayer.ShopGoodsPurchasePrice(Good,Station) > MaxBuyPrice) then Continue;
            if (MinSellPrice <> 0) and (GetPlayer.ShopGoodsSellPrice(Good,Station) < MinSellPrice) then Continue;
            Heading := Heading + #13#10 + '<td=' + IntToStr(GiScalePixels(5)) + '>' + '<align=center>' + WrapTextInColor(IntToStr(GoodsIndex + 1),'') + '.' + '</align>';
            SearchText := '';
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(15)) + '>' + WideString('') + WrapTextInColor(GoodsMarket[Good].DisplayName,SearchText) + WideString('');
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(160)) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Station.ShopGoods[Good].Count),'') + '</align>';
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(205)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good,Station)),'') + '</align>';
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(215)) + '><align=center>' + WrapTextInColor('/','') + '</align>';
            Heading := Heading + '<td=' + IntToStr(GiScalePixels(255)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good,Station)),'') + '</align>';
          end;
          if Heading = '' then Continue;
          Description := FormatText1(LocalizedText('FormInfo.Sector'),TextHighlightColorTag,'<SectorName>',Station.CurrentStar.Constellation.GetName);
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),TextHighlightColorTag,'<StarName>',Station.CurrentStar.Name);
          Description := Description + Heading;
          Heading := WrapTextInColor('- ' + WrapTextInColor(Station.GetFullName(' '),TextHighlightColorTag) + ' -',TextHighlightColorTag);
          AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,Integer(Station.Id or $80000000));
          AddInfoText(' .',text_x_center,'');
          AddInfoImageText(ExtractDelimitedPartW(Station.GetShipPortraitImagePath,1,','),Description);
          Found := True;
          Inc(ResultCount);
        end;
      end;
    end
    else if SelectedSearchCategory = 15 then
    begin
      NameFilter := TrimWideString(WideLowerCase((GetByName('M15Name') as TEditGI).Text));
      ConstellationFilter := TrimWideString(WideLowerCase((GetByName('M15Const') as TEditGI).Text));
      StarFilter := TrimWideString(WideLowerCase((GetByName('M15Star') as TEditGI).Text));
      IncludeRangerType := (GetByName('M15TypeRanger') as TGraphButtonGI).Down;
      IncludeWarriorType := (GetByName('M15TypeWarrior') as TGraphButtonGI).Down;
      IncludePirateType := (GetByName('M15TypePirat') as TGraphButtonGI).Down;
      IncludeTransportType := (GetByName('M15TypeTransport') as TGraphButtonGI).Down;
      IncludeLinerType := (GetByName('M15TypeLiner') as TGraphButtonGI).Down;
      IncludeDiplomatType := (GetByName('M15TypeDiplomat') as TGraphButtonGI).Down;
      ReadInfoSearchOwners(15);
    end;
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := GetPlayer.CurrentStar.StarDistances[I].Star as TStar;
      if Star.Constellation.Id = 20 then Continue;
      if SelectedSearchCategory = 0 then
      begin
        if FindLowercaseInfoText(SearchText,WideLowerCase(Star.Name)) > 0 then AddInfoSearchResult(Star);
      end
      else CheckInfoSearchResult(Star);
      Planet := nil;
      for Index := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[Index];
        if (Ship.CurrentPlanet <> nil) and (Ship.CurrentPlanet.OwnerId = owner_uninhabited) then Continue;
        if SelectedSearchCategory = 0 then
        begin
          if (FindLowercaseInfoText(SearchText,WideLowerCase(Ship.GetFullName(' '))) > 0) or
            (FindLowercaseInfoText(SearchText,WideLowerCase(Ship.GetLocalizedTypeName)) > 0) then AddInfoSearchResult(Ship);
        end
        else CheckInfoSearchResult(Ship);
        if (GetPlayer.DockedTo = Ship) and (TemporaryShopSlots <> nil) then
        begin
          for ItemIndex := 0 to TemporaryShopSlots.Count - 1 do
          begin
            Item := TShopSlot(TemporaryShopSlots[ItemIndex]).Item;
            if Item = nil then Continue;
            if SelectedSearchCategory = 0 then
            begin
              if ItemMatchesInfoSearch(Item,SearchText) then AddInfoSearchResult(Item);
            end
            else CheckInfoSearchResult(Item);
          end;
        end
        else if (Ship is TRuins) and (Ship.OwnerId <> owner_dominator) and not Ship.HasIndependentScriptFaction and not TRuins(Ship).NoLanding then
        begin
          for ItemIndex := 0 to (Ship as TRuins).EquipmentShop.Count - 1 do
          begin
            Item := TRuins(Ship).EquipmentShop[ItemIndex];
            if SelectedSearchCategory = 0 then
            begin
              if ItemMatchesInfoSearch(Item,SearchText) then AddInfoSearchResult(Item);
            end
            else CheckInfoSearchResult(Item);
          end;
        end;
      end;
      for Index := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[Index];
        if SelectedSearchCategory = 0 then
        begin
          if FindLowercaseInfoText(SearchText,WideLowerCase(Planet.GetFullName(' '))) > 0 then AddInfoSearchResult(Planet);
        end
        else CheckInfoSearchResult(Planet);
        if not Planet.IsCoalitionOwned and (Planet.OwnerId <> owner_pirate) then Continue;
        if (GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet = Planet) and (TemporaryShopSlots <> nil) then
        begin
          for ItemIndex := 0 to TemporaryShopSlots.Count - 1 do
          begin
            Item := TShopSlot(TemporaryShopSlots[ItemIndex]).Item;
            if Item = nil then Continue;
            if SelectedSearchCategory = 0 then
            begin
              if ItemMatchesInfoSearch(Item,SearchText) then AddInfoSearchResult(Item);
            end
            else CheckInfoSearchResult(Item);
          end;
        end
        else
          for ItemIndex := 0 to Planet.EquipmentShop.Count - 1 do
          begin
            Item := Planet.EquipmentShop[ItemIndex];
            if SelectedSearchCategory = 0 then
            begin
              if ItemMatchesInfoSearch(Item,SearchText) then AddInfoSearchResult(Item);
            end
            else CheckInfoSearchResult(Item);
          end;
        for ItemIndex := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := Planet.Warriors[ItemIndex];
          if Ship.CurrentStar.Ships.IndexOf(Ship) >= 0 then Continue;
          if SelectedSearchCategory = 0 then
          begin
            if (FindLowercaseInfoText(SearchText,WideLowerCase(Ship.GetFullName(' '))) > 0) or
              (FindLowercaseInfoText(SearchText,WideLowerCase(Ship.GetLocalizedTypeName)) > 0) then AddInfoSearchResult(Ship);
          end
          else CheckInfoSearchResult(Ship);
        end;
      end;
    end;
    if Found then
    begin
      AddInfoSpacing(10);
      AddInfoSeparator;
      AddInfoText(' .',text_x_center,'');
      AddInfoText(FormatText1(LocalizedText('FormInfo.ObjectFoundEnd'),TextHighlightColorTag,'<Count>',IntToStr(ResultCount)),text_x_center,'');
      GetPlayer.SetMoney(GetPlayer.Money - 3);
      SoundManager.PlaySound('Sound.Sell');
      SetFocusedControl(nil);
    end
    else
    begin
      ClearInfoContents;
      AddInfoSpacing(15);
      AddInfoText(LookupLocalizedTextByKey('FormInfo.NotFound'),text_x_center,'');
      SoundManager.PlaySound('Sound.NoMoney');
    end;
    AddInfoSpacing(10);
    AddInfoText(' .',text_x_center,'');
    FinishInfoLayout;
    Galaxy.PrimeIntegrityChecksum(208);
    Shown.Free;
  end;
end;
{ @end $59422C }

{ @routine $597698 TfInfo_AddEquipmentInfoText }
procedure TfInfo.AddEquipmentInfoText(Item: TItem; Text: WideString);
var Size, Height: Integer; Slots, Image: TGraphBufGI; Caption: TLabelGI;
begin
  Text := ReplaceAllWideString(Text,TextHighlightColorTag,DialogHighlightColorTag);
  Text := ReplaceAllWideString(Text,GreenColorTag,DialogGreenColorTag);
  Text := ReplaceAllWideString(Text,EquipmentBonusColorTag,DialogEquipmentBonusColorTag);
  Size := GiScalePixels(64);
  Height := Size;
  if Item is THull then
  begin
    Slots := TGraphBufGI.Create(InfoPanel,False);
    Slots.SetPositionModeW(True);
    Slots.SetPosition(Types.Point(InfoPanel.ClientSize.X - 80,InfoContentHeight));
    Slots.SetSize(Types.Point(80,90));
    Slots.SourceHasPerPixelAlpha := True;
    LoadGiByPathIntoGraphBuf('Bm.FormNote.' + GiResourceSuffix + 'HP_Bg',Slots.GraphBuf);
    EquipmentShopScreen.BuildHullSlotOverlays(InfoPanel,Item as THull,InfoPanel.ClientSize.X - 80,InfoContentHeight);
    Height := 90;
  end
  else if Item is TEquipment then begin end;
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Height));
  Image.SourceHasPerPixelAlpha := True;
  LoadGiByPathIntoGraphBuf(Item.GetBitmapResourceName + 'i',Image.GraphBuf);
  if Image.GraphBuf.Width >= Image.GraphBuf.Height then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Image.GraphBuf.Width * Image.GraphBuf.Height),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Image.GraphBuf.Height * Image.GraphBuf.Width),Image.ClientSize.Y,5);
  Caption := TLabelGI.Create(InfoPanel);
  if (GiResourceVariant = 2) or (Item is THull) then Caption.SetFontName(NormalFontName)
  else Caption.SetFontName(SmallFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X - 70,Height));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(text_x_left);
  Caption.SetTextAlignY(text_y_center);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  InfoContentHeight := InfoContentHeight + Height + 5;
end;
{ @end $597698 }

{ @routine $597BAC TfInfo_ToggleVisibleBookmark }
procedure TfInfo.ToggleVisibleBookmark;
var I, ScrollPosition: Integer; Button: TGraphButtonGI; Finished: Boolean; Entry: TMessagePlayer;
begin
  if not SearchMode then Exit;
  ScrollPosition := InfoPanel.VerticalScrollBar.Position;
  I := 0;
  Finished := False;
  Button := nil;
  while not Finished do
  begin
    Button := InfoPanel.FindByNameRecursive('MemBtn' + IntToStr(I)) as TGraphButtonGI;
    if Button = nil then Exit;
    if Button.LocalPosition.Y >= ScrollPosition then Break;
    Inc(I);
  end;
  if Button = nil then Exit;
  Entry := FindPlayerBubbleByText(Button.HelpText,False);
  if Entry <> nil then
  begin
    RemovePersistentPlayerMessage(Entry,False);
    MainPanel.Screen.GetByName('PM_WinMsg').SetActive(False);
    MainPanel.RebuildMessageButtons(False);
    Button.SetDisabled(False);
    SoundManager.PlaySound('Sound.DelMsg');
  end
  else BookmarkClicked(Button);
end;
{ @end $597BAC }

{ @routine $597D28 TfInfo_IsAtBusinessCenter }
function TfInfo.IsAtBusinessCenter: Boolean;
begin
  Result := False;
  if (GetPlayer <> nil) and (GetPlayer.DockedTo <> nil) and (GetPlayer.DockedTo.TypeId = station_ranger_center) then Result := True;
end;
{ @end $597D28 }

{ @routine $597D54 TfInfo_CategoryStateChanged }
procedure TfInfo.CategoryStateChanged(Sender: TObjectGI);
var I: Integer; Button: TGraphButtonGI;
begin
  I := ExtractDigitsToIntW(Sender.ControlName);
  Button := Sender as TGraphButtonGI;
  if (I >= 1) and (I <= 7) then
    with GetByName('ImgMM_C1') do
    begin
      Invalidate;
      SetActive(Button.IsHovered);
    end;
  if (I >= 8) and (I <= 10) then
    with GetByName('ImgMM_C2') do
    begin
      Invalidate;
      SetActive(Button.IsHovered);
    end;
end;
{ @end $597D54 }

{ @routine $597E10 TfInfo_CategoryClicked }
procedure TfInfo.CategoryClicked(Sender: TObjectGI);
var I: Integer;
begin
  if not InfoPanel.Active or (SelectedSearchCategory = 14) then
  begin
    SelectedSearchCategory := ExtractDigitsToIntW(Sender.ControlName);
    if (SelectedSearchCategory <> 0) and (SelectedSearchCategory <> PreviousSearchCategory) then HasSearchResults := False;
  end;
  if SelectedSearchCategory <> 0 then PreviousSearchCategory := SelectedSearchCategory;
  InfoPanel.SetActive(False);
  InfoPanel.VerticalScrollBar.SetActive(False);
  with GetByName('PanelSearch') do SetActive(SelectedSearchCategory = 0);
  for I := 1 to 15 do
    with GetByName('PanelM' + IntToFixedWidthWideString(I,2)) do SetActive(SelectedSearchCategory = I);
  with GetByName('ButPrev') as TGraphButtonGI do SetDisabled(SelectedSearchCategory = 0);
  with GetByName('ButNext') as TGraphButtonGI do
    SetDisabled(not (((SelectedSearchCategory = 0) and ((PreviousSearchCategory <> 0) or HasSearchResults)) or
      ((SelectedSearchCategory <> 0) and HasSearchResults)));
  FocusSearchField(True);
  if SelectedSearchCategory <> 14 then Exit;
  InfoPanel.SetActive(True);
  InfoPanel.VerticalScrollBar.SetActive(True);
  ClearInfoContents;
  AddInfoSpacing(2);
  AddInfoText(LocalizedColorText('FormInfo.SearchInfo1'),text_x_center,NormalBoldFontName);
  AddInfoSpacing(10);
  AddInfoSeparator;
  AddInfoSpacing(5);
  AddInfoText(LocalizedColorText('FormInfo.SearchInfo6'),text_x_center,SmallBoldFontName);
  AddInfoSpacing(10);
  AddInfoSeparator;
  AddInfoSpacing(10);
  AddSearchPriceLabel(LocalizedColorText('FormInfo.SearchInfo2'));
  AddInfoSpacing(5);
  AddInfoText(FormatText1(LocalizedColorText('FormInfo.SearchInfo3'),DialogHighlightColorTag,'<Count>',IntToStr(GetSearchResultLimit)),text_x_fit_or_justify,SmallFontName);
  AddInfoSpacing(10);
  AddInfoSeparator;
  AddInfoSpacing(5);
  AddInfoText(LocalizedColorText('FormInfo.SearchInfo7'),text_x_left,SmallBoldFontName);
  AddInfoSpacing(5);
  AddInfoText(LocalizedColorText('FormInfo.SearchInfo8'),text_x_left,SmallFontName);
  AddInfoSpacing(10);
  AddInfoSeparator;
  AddInfoSpacing(10);
  AddInfoText(LocalizedColorText('FormInfo.SearchInfo4'),text_x_center,NormalFontName);
  AddInfoText(' .',text_x_center,'');
  FinishInfoLayout;
end;
{ @end $597E10 }

{ @routine $5983A4 TfInfo_NextSearchPageClicked }
procedure TfInfo.NextSearchPageClicked(Sender: TObjectGI);
var I: Integer;
begin
  if (SelectedSearchCategory = 0) and (PreviousSearchCategory <> 0) and (PreviousSearchCategory <> 14) then
    CategoryClicked(GetByName('PanelM' + IntToFixedWidthWideString(PreviousSearchCategory,2)))
  else
  begin
    InfoPanel.VerticalScrollBar.SetActive(True);
    InfoPanel.SetActive(True);
    GetByName('PanelSearch').SetActive(False);
    for I := 1 to 15 do
      with GetByName('PanelM' + IntToFixedWidthWideString(I,2)) do SetActive(False);
    with GetByName('ButPrev') as TGraphButtonGI do SetDisabled(False);
    with GetByName('ButNext') as TGraphButtonGI do SetDisabled(True);
    FinishInfoLayout;
  end;
end;
{ @end $5983A4 }

{ @routine $598548 TfInfo_BindFilterLabels }
procedure TfInfo.BindFilterLabels(Parent: TObjectGI);
var Child, Caption: TObjectGI; Button: TGraphButtonGI; Y, X: Integer;
begin
  Child := Parent.FirstChild;
  while Child <> nil do
  begin
    while True do
    begin
      if not (Child is TGraphButtonGI) then Break;
      Button := Child as TGraphButtonGI;
      if (Button.ImageNormal = nil) or (FindTextOffsetW(Button.ImageNormal.GetImagePath,'Check') < 0) then Break;
      X := Button.LocalPosition.X + Button.ClientSize.X + GiScalePixels(20);
      Y := Button.ClientSize.Y div 2 + Button.LocalPosition.Y;
      Caption := Parent.FirstChild;
      while Caption <> nil do
      begin
        if Caption <> Child then
          if (Caption is TLabelGI) and
            (X >= Caption.LocalPosition.X) and (X < Caption.LocalPosition.X + Caption.ClientSize.X) and
            (Y >= Caption.LocalPosition.Y) and (Y < Caption.LocalPosition.Y + Caption.ClientSize.Y) then Break;
        Caption := Caption.NextSibling;
      end;
      if Caption <> nil then
      begin
        Caption.UserValue := Integer(Button);
        Caption.MouseEnterCallback := FilterLabelMouseEnter;
        Caption.MouseLeaveCallback := FilterLabelMouseLeave;
        Caption.LeftButtonDownCallback := FilterLabelMouseDown;
        Caption.LeftButtonUpCallback := FilterLabelMouseUp;
      end;
      Break;
    end;
    BindFilterLabels(Child);
    Child := Child.NextSibling;
  end;
end;
{ @end $598548 }

{ @routine $5986E0 TfInfo_FilterLabelMouseEnter }
procedure TfInfo.FilterLabelMouseEnter(Sender: TObjectGI);
begin
  with TGraphButtonGI(Sender.UserValue) do SetHovered(True);
end;
{ @end $5986E0 }

{ @routine $5986F0 TfInfo_FilterLabelMouseLeave }
procedure TfInfo.FilterLabelMouseLeave(Sender: TObjectGI);
begin
  with TGraphButtonGI(Sender.UserValue) do SetHovered(False);
end;
{ @end $5986F0 }

{ @routine $598700 TfInfo_FilterLabelMouseDown }
procedure TfInfo.FilterLabelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
end;
{ @end $598700 }

{ @routine $598718 TfInfo_FilterLabelMouseUp }
procedure TfInfo.FilterLabelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  with TGraphButtonGI(Sender.UserValue) do SetDown(not Down);
end;
{ @end $598718 }

{ @routine $598748 TfInfo_ClearSearchText }
procedure TfInfo.ClearSearchText(Sender: TObjectGI);
begin
  with GetByName('TextSearch') as TEditGI do SetText('');
end;
{ @end $598748 }

{ @routine $598788 TfInfo_CopySearchText }
procedure TfInfo.CopySearchText(Sender: TObjectGI);
begin
  with GetByName('TextSearch') as TEditGI do SetClipboardWideText(Text);
end;
{ @end $598788 }

{ @routine $5987CC TfInfo_PasteSearchText }
procedure TfInfo.PasteSearchText(Sender: TObjectGI);
begin
  with GetByName('TextSearch') as TEditGI do SetText(GetClipboardWideText);
end;
{ @end $5987CC }

{ @routine $59884C TfInfo_ClearSearch12Name }
procedure TfInfo.ClearSearch12Name(Sender: TObjectGI);
begin
  with GetByName('M12Name') as TEditGI do SetText('');
end;
{ @end $59884C }

{ @routine $598884 TfInfo_CopySearch12Name }
procedure TfInfo.CopySearch12Name(Sender: TObjectGI);
begin
  with GetByName('M12Name') as TEditGI do SetClipboardWideText(Text);
end;
{ @end $598884 }

{ @routine $5988C0 TfInfo_PasteSearch12Name }
procedure TfInfo.PasteSearch12Name(Sender: TObjectGI);
begin
  with GetByName('M12Name') as TEditGI do SetText(GetClipboardWideText);
end;
{ @end $5988C0 }

{ @routine $598938 TfInfo_ClearSearch15Name }
procedure TfInfo.ClearSearch15Name(Sender: TObjectGI);
begin
  with GetByName('M15Name') as TEditGI do SetText('');
end;
{ @end $598938 }

{ @routine $598970 TfInfo_CopySearch15Name }
procedure TfInfo.CopySearch15Name(Sender: TObjectGI);
begin
  with GetByName('M15Name') as TEditGI do SetClipboardWideText(Text);
end;
{ @end $598970 }

{ @routine $5989AC TfInfo_PasteSearch15Name }
procedure TfInfo.PasteSearch15Name(Sender: TObjectGI);
begin
  with GetByName('M15Name') as TEditGI do SetText(GetClipboardWideText);
end;
{ @end $5989AC }

{ @routine $598A24 TfInfo_ClearSearchField }
procedure TfInfo.ClearSearchField(Name: WideString);
begin
  (GetByName(Name) as TEditGI).SetText('');
end;
{ @end $598A24 }

{ @routine $598A84 TfInfo_ClearSearch01Filters }
procedure TfInfo.ClearSearch01Filters(Sender: TObjectGI);
begin
  ClearSearchField('M01Speed');
  ClearSearchField('M01Range');
  ClearSearchField('M01Size');
  ClearSearchField('M01Cost');
end;
{ @end $598A84 }

{ @routine $598B14 TfInfo_ClearSearch02Filters }
procedure TfInfo.ClearSearch02Filters(Sender: TObjectGI);
begin
  ClearSearchField('M02Capacity');
  ClearSearchField('M02Size');
  ClearSearchField('M02Cost');
end;
{ @end $598B14 }

{ @routine $598B84 TfInfo_ClearSearch03Filters }
procedure TfInfo.ClearSearch03Filters(Sender: TObjectGI);
begin
  ClearSearchField('M03Range');
  ClearSearchField('M03Size');
  ClearSearchField('M03Cost');
end;
{ @end $598B84 }

{ @routine $598BF0 TfInfo_ClearSearch04Filters }
procedure TfInfo.ClearSearch04Filters(Sender: TObjectGI);
begin
  ClearSearchField('M04Power');
  ClearSearchField('M04Size');
  ClearSearchField('M04Cost');
end;
{ @end $598BF0 }

{ @routine $598C5C TfInfo_ClearSearch05Filters }
procedure TfInfo.ClearSearch05Filters(Sender: TObjectGI);
begin
  ClearSearchField('M05Power');
  ClearSearchField('M05Size');
  ClearSearchField('M05Cost');
end;
{ @end $598C5C }

{ @routine $598CC8 TfInfo_ClearSearch06Filters }
procedure TfInfo.ClearSearch06Filters(Sender: TObjectGI);
begin
  ClearSearchField('M06ObjSize');
  ClearSearchField('M06Size');
  ClearSearchField('M06Cost');
end;
{ @end $598CC8 }

{ @routine $598D38 TfInfo_ClearSearch07Filters }
procedure TfInfo.ClearSearch07Filters(Sender: TObjectGI);
begin
  ClearSearchField('M07Block');
  ClearSearchField('M07Size');
  ClearSearchField('M07Cost');
end;
{ @end $598D38 }

{ @routine $598DA4 TfInfo_ClearSearch09Filters }
procedure TfInfo.ClearSearch09Filters(Sender: TObjectGI);
begin
  ClearSearchField('M09Const');
  ClearSearchField('M09Star');
  ClearSearchField('M09Range');
end;
{ @end $598DA4 }

{ @routine $598E14 TfInfo_ClearSearch10Filters }
procedure TfInfo.ClearSearch10Filters(Sender: TObjectGI);
begin
  ClearSearchField('M10Const');
  ClearSearchField('M10Star');
  ClearSearchField('M10Range');
end;
{ @end $598E14 }

{ @routine $598E84 TfInfo_ClearSearch11Filters }
procedure TfInfo.ClearSearch11Filters(Sender: TObjectGI);
begin
  ClearSearchField('M11Size');
  ClearSearchField('M11Def');
  ClearSearchField('M11Cost');
end;
{ @end $598E84 }

{ @routine $598EEC TfInfo_ClearSearch12Filters }
procedure TfInfo.ClearSearch12Filters(Sender: TObjectGI);
begin
  ClearSearchField('M12DamageMin');
  ClearSearchField('M12DamageMax');
  ClearSearchField('M12Range');
  ClearSearchField('M12Name');
  ClearSearchField('M12Size');
  ClearSearchField('M12Cost');
end;
{ @end $598EEC }

{ @routine $598FD0 TfInfo_ClearSearch13Filters }
procedure TfInfo.ClearSearch13Filters(Sender: TObjectGI);
begin
  ClearSearchField('M13Range');
  ClearSearchField('M13PriceSell');
  ClearSearchField('M13Cnt');
  ClearSearchField('M13PriceBuy');
end;
{ @end $598FD0 }

{ @routine $599070 TfInfo_ClearSearch15Filters }
procedure TfInfo.ClearSearch15Filters(Sender: TObjectGI);
begin
  ClearSearchField('M15Const');
  ClearSearchField('M15Star');
  ClearSearchField('M15Name');
end;
{ @end $599070 }

{ @routine $5990DC TfInfo_GetSearchResultLimit }
function TfInfo.GetSearchResultLimit: Integer;
begin
  if (GetPlayer <> nil) and (GetPlayer.DockedTo <> nil) and (GetPlayer.DockedTo.TypeId = station_ranger_center) then Result := MaxSearchResult
  else Result := 30;
end;
{ @end $5990DC }

{ @routine $59910C TfInfo_ExecuteUiCode }
procedure TfInfo.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not MainPanel.NavigationLocked and not ExitScreenLoop and
    (TurnCalculationPhase in [turn_idle,turn_galaxy_finished,turn_player_star_finished,turn_player_star_prepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10010);
    ExecuteGameplayUiCode(Block,Key);
    Galaxy.PrimeIntegrityChecksum(20010);
  end;
end;
{ @end $59910C }

end.
