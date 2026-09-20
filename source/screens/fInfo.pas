unit fInfo;
// Unit bracket (inferred): .text 0x0059CB60..0x005AB2F2; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    procedure RefreshNewsAnimation(Sender: TObjectGI); // @addr $59E2B8
    procedure FocusSearchField(Force: Boolean); // @addr $5A0760
    procedure ToggleSearchMode(Sender: TObjectGI); // @addr $5A0B64
    procedure MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5A0C6C @ida "void __userpurge $name(TfInfo *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure SearchClicked(Sender: TObjectGI); // @addr $5A1A3C
    procedure RunSearch(Sender: TObjectGI); // @addr $5A5DA8
    procedure CategoryStateChanged(Sender: TObjectGI); // @addr $5A9B9C
    procedure CategoryClicked(Sender: TObjectGI); // @addr $5A9C70
    procedure NextSearchPageClicked(Sender: TObjectGI); // @addr $5AA294
    procedure BindFilterLabels(Parent: TObjectGI); // @addr $5AA474
    procedure ShowNews; // @addr $5A14C4
    procedure ShowSearch; // @addr $5A1784

    procedure EndTurnClicked(Sender: TObjectGI); // @addr $59E594
    procedure ShipClicked(Sender: TObjectGI); // @addr $59E7F8
    function GetSearchResultLimit: Integer; // @addr $5AB1E8
    procedure ClearInfoContents; // @addr $59E848
    procedure FinishInfoLayout; // @addr $59E8A0
    procedure AddInfoSeparator; // @addr $59E9F8
    procedure AddInfoHeading(Title, BookmarkText: WideString; LayoutKind, BookmarkIndex, GoodsReference: Integer); // @addr $59EB4C @ida "void __userpurge $name(TfInfo *Self@<eax>, unsigned __int16 *Title@<edx>, unsigned __int16 *BookmarkText@<ecx>, int LayoutKind@<^8>, int BookmarkIndex@<^4>, int GoodsReference@<^0>);" LayoutKind zero centers the heading; nonzero aligns it to the right.
    procedure AddSearchPriceLabel(Text: WideString); // @addr $59F220
    procedure AddInfoText(Text: WideString; Alignment: TTextAlignXGI; Font: WideString); // @addr $59F474
    procedure AddPlanetInfoText(Planet: TPlanet; Text: WideString); // @addr $59F9AC
    procedure AddEquipmentInfoText(Item: TItem; Text: WideString); // @addr $5A9420
    procedure AddItemInfoText(Item: TItem; Text: WideString); // @addr $59FDB4
    procedure AddStarInfoText(Star: TStar; Text: WideString); // @addr $5A0320
    procedure ToggleVisibleBookmark; // @addr $5A99B0
    function IsAtBusinessCenter: Boolean; // @addr $5A9B60
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5A0C98
    procedure AddInfoImageText(ImagePath, Text: WideString); // @addr $59F690
    procedure BookmarkClicked(Sender: TObjectGI); // @addr $5A113C
    procedure AddInfoSpacing(Pixels: Integer); // @addr $59E9D4
    procedure MainPanelKeyUp(Sender: TObjectGI; Key: Cardinal); // @addr $5A1074

    procedure FilterLabelMouseEnter(Sender: TObjectGI); // @addr $5AA660
    procedure FilterLabelMouseLeave(Sender: TObjectGI); // @addr $5AA688
    procedure FilterLabelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5AA6B0 @ida "void __userpurge $name(TfInfo *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure FilterLabelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5AA6D4 @ida "void __userpurge $name(TfInfo *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure ClearSearchText(Sender: TObjectGI); // @addr $5AA718
    procedure CopySearchText(Sender: TObjectGI); // @addr $5AA76C
    procedure PasteSearchText(Sender: TObjectGI); // @addr $5AA7C4
    procedure ClearSearch12Name(Sender: TObjectGI); // @addr $5AA850
    procedure CopySearch12Name(Sender: TObjectGI); // @addr $5AA89C
    procedure PasteSearch12Name(Sender: TObjectGI); // @addr $5AA8EC
    procedure ClearSearch15Name(Sender: TObjectGI); // @addr $5AA970
    procedure CopySearch15Name(Sender: TObjectGI); // @addr $5AA9BC
    procedure PasteSearch15Name(Sender: TObjectGI); // @addr $5AAA0C
    procedure ClearSearchField(Name: WideString); // @addr $5AAA90
    procedure ClearSearch01Filters(Sender: TObjectGI); // @addr $5AAAF0
    procedure ClearSearch02Filters(Sender: TObjectGI); // @addr $5AAB8C
    procedure ClearSearch03Filters(Sender: TObjectGI); // @addr $5AAC08
    procedure ClearSearch04Filters(Sender: TObjectGI); // @addr $5AAC80
    procedure ClearSearch05Filters(Sender: TObjectGI); // @addr $5AACF8
    procedure ClearSearch06Filters(Sender: TObjectGI); // @addr $5AAD70
    procedure ClearSearch07Filters(Sender: TObjectGI); // @addr $5AADEC
    procedure ClearSearch09Filters(Sender: TObjectGI); // @addr $5AAE64
    procedure ClearSearch10Filters(Sender: TObjectGI); // @addr $5AAEE0
    procedure ClearSearch11Filters(Sender: TObjectGI); // @addr $5AAF5C
    procedure ClearSearch12Filters(Sender: TObjectGI); // @addr $5AAFD0
    procedure ClearSearch13Filters(Sender: TObjectGI); // @addr $5AB0C4
    procedure ClearSearch15Filters(Sender: TObjectGI); // @addr $5AB170

    constructor Create; // @addr 0x59CEA4 @ida "TfInfo *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x59CF24 @ida "void __usercall $name(TfInfo *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure OnOpen; override; // @addr 0x59D4C0
    procedure OnClose; override; // @addr 0x59E180
    procedure SelectMusic; override; // @addr 0x5A125C
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x5A1088 @ida "void __userpurge $name(TfInfo *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure InitializeLayout; override; // @addr 0x59CFC4
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x5AB230
  end;

function FindLowercaseInfoTextFrom(const Search, Text: WideString; StartPosition: Integer): Integer; // @addr $59CBF4 Search is already lowercase; positions are one-based, zero means absent.
function FindLowercaseInfoText(const Search, Text: WideString): Integer; // @addr $59CC5C

function ItemMatchesInfoSearch(Item: TItem; Search: WideString): Boolean; // @addr $59CDF4 Search terms must already be lowercase.

const

// The native finalizer at $5AB2A4 clears ReservedInfoText and the animation
// name array. The descriptor at $5AB2F4 initializes all twenty names above.

implementation

// @unit-initialization $875880
// @unit-finalization $5AB2A4

uses Classes, aTransport, Messages, EC_Data, Windows, SE_Star, SE_Planet, GI_Image, GI_GraphBuf, GR_GraphBuf, GI_GI, aRuins, fRuinsTalk, fEquipmentShop, aGalaxyStruct, GI_GAI, fShip2, Math, GI_Label, fGov, aPlanet, aConst, EC_Struct, GI_Main, GR_Music, GI_Edit, GI_GraphButton, SysUtils, EC_Str, GR_Main, aPlayer, aShip, aGalaxy, aMyFunction, ThreadCalc, Globals, GlobalsV;

{ @routine $59CBF4 FindLowercaseInfoTextFrom }
function FindLowercaseInfoTextFrom(const Search, Text: WideString; StartPosition: Integer): Integer;
begin
  Result := FindTextOffsetW(WideLowerCase(Text),Search,StartPosition - 1) + 1;
end;
{ @end $59CBF4 }

{ @routine $59CC5C FindLowercaseInfoText }
function FindLowercaseInfoText(const Search, Text: WideString): Integer;
begin
  Result := FindLowercaseInfoTextFrom(Search,Text,1);
end;
{ @end $59CC5C }

{ @routine $59CDF4 ItemMatchesInfoSearch }
function ItemMatchesInfoSearch(Item: TItem; Search: WideString): Boolean;
var I, Count: Integer;

  // @nested $59CC84 ItemMatchesInfoSearchTerm
  function ItemMatchesInfoSearchTerm(Term: WideString): Boolean; // @addr $59CC84 @ida "bool __usercall $name@<al>(unsigned __int16 *Term@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x59CE5A" Nested helper captures Item.
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
{ @end $59CDF4 }

{ @routine $59CEA4 TfInfo_Create }
constructor TfInfo.Create;
begin
  inherited Create;
  PlanetPanel := TfPanelPlanet.Create;
  StationPanel := TfPanelRuins.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $59CEA4 }

{ @routine $59CF24 TfInfo_Destroy }
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
{ @end $59CF24 }

{ @routine $59CFC4 TfInfo_InitializeLayout }
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
{ @end $59CFC4 }

{ @routine $59D4C0 TfInfo_OnOpen }
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
      if GetPlayer.DockedTo.TypeNameOverrideKey <> WideString('') then
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
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm,nil,nil,0);
  Galaxy.PrimeIntegrityChecksum(201);
end;
{ @end $59D4C0 }

{ @routine $59E180 TfInfo_OnClose }
procedure TfInfo.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(202);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm,nil,nil,0);
  InfoPanel.FreeOwnedChildren;
  MainPanel.OnClose;
  LoadPanel.OnClose;
  if (GetPlayer <> nil) and GetPlayer.IsOnPlanet then PlanetPanel.OnClose
  else StationPanel.OnClose;
end;
{ @end $59E180 }

var
  ReservedInfoText: WideString = ''; // @addr $87AA4C Retained empty managed variable, cleared before the names array.
  InfoNewsAnimationNames: array[0..19] of WideString =
    ('a','b','c','d','e','f','g','h','k','l','m','n','o','p','q','r','s','t','u','v'); // @addr $87AA50
var
  InfoNewsAnimationWeights: array[0..19] of Integer =
    (9,5,9,9,7,5,7,1,3,1,0,3,3,2,3,2,3,4,5,3); // @addr $87AAA0 Native selection adds one to each weight.
  // $5A1A8E initializes I=1; $5A1AC0..$5A1AC7 increments and repeats until I=7.
  // The indexed FLD therefore reads these six remaining grades, not PirateSlotBonusWeights[-13+I].
  InfoQualityGrades: array[0..6] of Single = (0.7,0.8,0.9,1.0,1.2,1.4,1.6); // @addr $87AAF0 @indexrefs "$5A1A98"

{ @routine $59E2B8 TfInfo_RefreshNewsAnimation }
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
{ @end $59E2B8 }

{ @routine $59E594 TfInfo_EndTurnClicked }
procedure TfInfo.EndTurnClicked(Sender: TObjectGI);
begin
  if (GetPlayer = nil) or (GetPlayer.QueuedTravelTarget <> nil) then Exit;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstDominion)) and
    (GetPlayer.DockedTo.Order = soTeleport) and (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) and
    not GetPlayer.DockedTo.InHyperspace then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstDominion)) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and
    ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstMilitaryBase)) and
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
{ @end $59E594 }

{ @routine $59E7F8 TfInfo_ShipClicked }
procedure TfInfo.ShipClicked(Sender: TObjectGI);
begin
  MainPanel.ShipClicked(Sender);
  if ShipScreen.Flag3BC then
  begin
    MainPanel.RebuildMessageButtons(False);
    MainPanel.RefreshMoneyAndCargo;
  end;
end;
{ @end $59E7F8 }

{ @routine $59E848 TfInfo_ClearInfoContents }
procedure TfInfo.ClearInfoContents;
begin
  InfoContentHeight := 0;
  InfoPanel.FreeOwnedChildren;
  InfoPanel.SetScrollOffset(Types.Point(0,0));
  InfoPanel.Invalidate;
end;
{ @end $59E848 }

{ @routine $59E8A0 TfInfo_FinishInfoLayout }
procedure TfInfo.FinishInfoLayout;
begin
  InfoPanel.UpdateScrollRanges;
  InfoPanel.VerticalScrollBar.SetRange(0,InfoPanel.VerticalScrollBar.Maximum);
  InfoPanel.VerticalScrollBar.SetActive(InfoPanel.ClientSize.Y < InfoContentHeight);
  InfoPanel.VerticalScrollBar.SetSmallChange((GovernmentScreen.GetByName('TalkText') as TLabelGI).GetLineHeight);
  InfoPanel.VerticalScrollBar.SetLargeChange(InfoPanel.ClientSize.Y);
  InfoPanel.VerticalScrollBar.SetPageSize(InfoPanel.ClientSize.Y);
  InfoPanel.SetScrollOffset(Types.Point(0,0));
  InfoPanel.Invalidate;
end;
{ @end $59E8A0 }

{ @routine $59E9D4 TfInfo_AddInfoSpacing }
procedure TfInfo.AddInfoSpacing(Pixels: Integer);
begin
  Inc(InfoContentHeight,GiScalePixels(Pixels));
end;
{ @end $59E9D4 }

{ @routine $59E9F8 TfInfo_AddInfoSeparator }
procedure TfInfo.AddInfoSeparator;
var Image: TImageGI;
begin
  Image := TImageGI.Create(InfoPanel);
  Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'Line');
  Image.SetSize(Image.GetContentSize);
  Image.SetPosition(Types.Point(InfoPanel.ClientSize.X div 2 - Image.ClientSize.X div 2,InfoContentHeight));
  Image.SetDepth(1);
  Image.SetImageKindX(ikxLeftFill);
  Image.SetImageKindY(ikyCenter);
  Inc(InfoContentHeight,Image.ClientSize.Y);
  Image.SetPositionModeW(True);
end;
{ @end $59E9F8 }

{ @routine $59EB4C TfInfo_AddInfoHeading }
procedure TfInfo.AddInfoHeading(Title, BookmarkText: WideString; LayoutKind, BookmarkIndex, GoodsReference: Integer);
var
  Image: TImageGI;
  Caption: TLabelGI;
  Button: TGraphButtonGI;
begin
  Title := ReplaceAllWideString(Title,'<color=255,240,100>','<color=0,0,0>');
  Title := ReplaceAllWideString(Title,'<color=0,255,0>','<color=255,255,0>');
  Image := TImageGI.Create(InfoPanel);
  if LayoutKind = 0 then Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'CaptionL')
  else Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'Caption');
  Image.SetSize(Image.GetContentSize);
  if LayoutKind = 0 then Image.SetPosition(Types.Point(InfoPanel.ClientSize.X div 2 - Image.ClientSize.X div 2,InfoContentHeight))
  else Image.SetPosition(Types.Point(InfoPanel.ClientSize.X - Image.ClientSize.X,InfoContentHeight));
  Image.SetDepth(1);
  Image.SetImageKindX(ikxLeftFill);
  Image.SetImageKindY(ikyCenter);
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
  Caption.SetTextAlignX(taxCenter);
  Caption.SetTextAlignY(tayCenterEx);
  Caption.SetText(Title);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  if BookmarkText <> WideString('') then
  begin
    Button := TGraphButtonGI.Create(InfoPanel);
    Button.SetImageNormalPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemN');
    Button.SetImageNormalActivePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemA');
    Button.SetImageDownPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemD');
    Button.SetImageDisabledPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemH');
    Button.SetSize(Button.GetMaxStateImageSize);
    if LayoutKind = 0 then Button.SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - Button.ClientSize.X - GiScalePixels(10),Image.LocalPosition.Y))
    else Button.SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - Button.ClientSize.X - GiScalePixels(10),Image.LocalPosition.Y - GiScalePixels(5)));
    Button.SetKind(gbkDisable);
    Button.SetPositionModeW(True);
    Button.HelpText := BookmarkText;
    Button.UpCallback := BookmarkClicked;
    Button.SetName('MemBtn' + IntToStr(BookmarkIndex));
    Button.SetDown(False);
    Button.SetDisabled(FindPlayerBubbleByText(BookmarkText,False) <> nil);
    Button.UserValue := GoodsReference;
    Button.SetHovered(True);
    Button.Invalidate;
    Button.SetHovered(False);
  end;
end;
{ @end $59EB4C }

{ @routine $59F220 TfInfo_AddSearchPriceLabel }
procedure TfInfo.AddSearchPriceLabel(Text: WideString);
var Image: TImageGI; Caption: TLabelGI;
begin
  Image := TImageGI.Create(InfoPanel);
  Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'FindPrice');
  Image.SetSize(Image.GetContentSize);
  Image.SetPosition(Types.Point(InfoPanel.ClientSize.X - Image.ClientSize.X - GiScalePixels(40),InfoContentHeight));
  Image.SetDepth(1);
  Image.SetImageKindX(ikxLeftFill);
  Image.SetImageKindY(ikyCenter);
  Inc(InfoContentHeight,Image.ClientSize.Y);
  Image.SetPositionModeW(True);
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetDepth(-1);
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - (InfoPanel.ClientSize.X - Image.LocalPosition.X) - GiScalePixels(10),Image.ClientSize.Y));
  Caption.SetPosition(Types.Point(0,Image.LocalPosition.Y));
  Caption.SetWordWrapEnabled(False);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(taxRight);
  Caption.SetTextAlignY(tayCenterEx);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
end;
{ @end $59F220 }

{ @routine $59F474 TfInfo_AddInfoText }
procedure TfInfo.AddInfoText(Text: WideString; Alignment: TTextAlignXGI; Font: WideString);
var Caption: TLabelGI;
begin
  Text := ReplaceAllWideString(Text,'<color=255,240,100>','<color=0,50,200>');
  Caption := TLabelGI.Create(InfoPanel);
  if Font = WideString('') then
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
  Caption.SetTextAlignY(tayAuto);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Inc(InfoContentHeight,Caption.ClientSize.Y);
end;
{ @end $59F474 }

{ @routine $59F690 TfInfo_AddInfoImageText }
procedure TfInfo.AddInfoImageText(ImagePath, Text: WideString);
var Size: Integer; Image: TGraphBufGI; Caption: TLabelGI;
begin
  Text := ReplaceAllWideString(Text,'<color=255,240,100>','<color=0,50,200>');
  Size := GiScalePixels(64);
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Size));
  Image.SourceHasPerPixelAlpha := True;
  LoadGiByPathIntoGraphBuf(ImagePath,Image.GraphBuf);
  if Cardinal(Image.GraphBuf.Width) >= Cardinal(Image.GraphBuf.Height) then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Cardinal(Image.GraphBuf.Width) * Cardinal(Image.GraphBuf.Height)),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Cardinal(Image.GraphBuf.Height) * Cardinal(Image.GraphBuf.Width)),Image.ClientSize.Y,5);
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X,Size));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(taxLeft);
  Caption.SetTextAlignY(tayAuto);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Size := Max(Size,Caption.ClientSize.Y);
  InfoContentHeight := InfoContentHeight + Size + 5;
end;
{ @end $59F690 }

{ @routine $59F9AC TfInfo_AddPlanetInfoText }
procedure TfInfo.AddPlanetInfoText(Planet: TPlanet; Text: WideString);
var Size: Integer; Image: TGraphBufGI; Emblem: TImageGI; Caption: TLabelGI;
begin
  Text := ReplaceAllWideString(Text,'<color=255,240,100>','<color=0,50,200>');
  Size := GiScalePixels(64);
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Size));
  Image.SourceHasPerPixelAlpha := True;
  Planet.Graphic.RenderToBuffer(Self,Image.GraphBuf,False);
  if Cardinal(Image.GraphBuf.Width) >= Cardinal(Image.GraphBuf.Height) then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Cardinal(Image.GraphBuf.Width) * Cardinal(Image.GraphBuf.Height)),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Cardinal(Image.GraphBuf.Height) * Cardinal(Image.GraphBuf.Width)),Image.ClientSize.Y,5);
  if Planet.OwnerId <> Byte(oiUninhabited) then
  begin
    Emblem := TImageGI.Create(InfoPanel);
    Emblem.SetPositionModeW(True);
    Emblem.SetImagePath(GetFactionEmblemPath(Planet.GetFactionResourceName));
    Emblem.SetSize(Emblem.GetContentSize);
    Emblem.SetPosition(Types.Point(InfoPanel.ClientSize.X - Emblem.ClientSize.X - GiScalePixels(10),InfoContentHeight));
    Emblem.SetImageKindX(ikxCenter);
    Emblem.SetImageKindY(ikyCenter);
  end;
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X,Size));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(taxLeft);
  Caption.SetTextAlignY(tayAuto);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Size := Max(Size,Caption.ClientSize.Y);
  Caption.SetTextAlignY(tayCenter);
  Caption.SetSize(Types.Point(Caption.ClientSize.X,Size));
  InfoContentHeight := InfoContentHeight + Size + 5;
end;
{ @end $59F9AC }

{ @routine $59FDB4 TfInfo_AddItemInfoText }
procedure TfInfo.AddItemInfoText(Item: TItem; Text: WideString);
var Size: Integer; Image: TGraphBufGI; Caption: TLabelGI; Emblem: TImageGI;
begin
  Text := ReplaceAllWideString(Text,'<color=255,240,100>','<color=0,50,200>');
  Text := ReplaceAllWideString(Text,'<color=0,255,0>','<color=0,130,0>');
  Text := ReplaceAllWideString(Text,'<color=255,167,84>','<color=240,100,30>');
  Size := GiScalePixels(64);
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Size));
  Image.SourceHasPerPixelAlpha := True;
  LoadGiByPathIntoGraphBuf(Item.GetBitmapResourceName + 'i',Image.GraphBuf);
  if Cardinal(Image.GraphBuf.Width) >= Cardinal(Image.GraphBuf.Height) then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Cardinal(Image.GraphBuf.Width) * Cardinal(Image.GraphBuf.Height)),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Cardinal(Image.GraphBuf.Height) * Cardinal(Image.GraphBuf.Width)),Image.ClientSize.Y,5);
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X,Size + 20));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(taxLeft);
  Caption.SetTextAlignY(tayCenter);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  if Item is TEquipment then
  begin
    Emblem := TImageGI.Create(InfoPanel);
    Emblem.SetPositionModeW(True);
    Emblem.SetImagePath(GetFactionEmblemPath((Item as TEquipment).GetOwnerConfigName));
    Emblem.SetSize(Emblem.GetContentSize);
    Emblem.SetPosition(Types.Point(InfoPanel.ClientSize.X - Emblem.ClientSize.X - GiScalePixels(10),InfoContentHeight));
    Emblem.SetImageKindX(ikxCenter);
    Emblem.SetImageKindY(ikyCenter);
  end;
  InfoContentHeight := InfoContentHeight + Size + 21;
end;
{ @end $59FDB4 }

{ @routine $5A0320 TfInfo_AddStarInfoText }
procedure TfInfo.AddStarInfoText(Star: TStar; Text: WideString);
var Size: Integer; Image: TGraphBufGI; Emblem: TImageGI; Caption: TLabelGI;
  // @nested $5A0298 GetInfoStarFactionName
  function GetInfoStarFactionName(Star: TStar): WideString; // @addr $5A0298 @ida "void __usercall $name(TStar *Star@<eax>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x5A051F" Nested in AddStarInfoText; static link unused.
  begin
    if Star.Status.CustomFaction <> WideString('') then Result := Star.Status.CustomFaction
    else if Star.ControlFaction = sfDominators then Result := DominatorSeriesNames[Ord(Star.DominatorSeries)]
    else if Star.ControlFaction = sfPirates then Result := OwnerInfo[Ord(oiPirate)].InternalName
    else Result := OwnerInfo[Ord(oiUninhabited)].InternalName;
  end;
begin
  Text := ReplaceAllWideString(Text,'<color=255,240,100>','<color=0,50,200>');
  Size := GiScalePixels(64);
  Image := TGraphBufGI.Create(InfoPanel,False);
  Image.SetPositionModeW(True);
  Image.SetPosition(Types.Point(0,InfoContentHeight));
  Image.SetSize(Types.Point(Size,Size));
  Image.SourceHasPerPixelAlpha := True;
  LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TStarSE(Star.Graphic).StaticImagePath,1,','),Image.GraphBuf);
  if Cardinal(Image.GraphBuf.Width) >= Cardinal(Image.GraphBuf.Height) then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Cardinal(Image.GraphBuf.Width) * Cardinal(Image.GraphBuf.Height)),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Cardinal(Image.GraphBuf.Height) * Cardinal(Image.GraphBuf.Width)),Image.ClientSize.Y,5);
  if (Star.ControlFaction <> sfCoalition) or (Star.Status.CustomFaction <> WideString('')) then
  begin
    Emblem := TImageGI.Create(InfoPanel);
    Emblem.SetPositionModeW(True);
    Emblem.SetImagePath(GetFactionEmblemPath(GetInfoStarFactionName(Star)));
    Emblem.SetSize(Emblem.GetContentSize);
    Emblem.SetPosition(Types.Point(InfoPanel.ClientSize.X - Emblem.ClientSize.X - GiScalePixels(10),InfoContentHeight));
    Emblem.SetImageKindX(ikxCenter);
    Emblem.SetImageKindY(ikyCenter);
  end;
  Caption := TLabelGI.Create(InfoPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X,Size));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(taxLeft);
  Caption.SetTextAlignY(tayAuto);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Size := Max(Size,Caption.ClientSize.Y);
  Caption.SetTextAlignY(tayCenter);
  Caption.SetSize(Types.Point(Caption.ClientSize.X,Size));
  InfoContentHeight := InfoContentHeight + Size + 5;
end;
{ @end $5A0320 }

{ @routine $5A0760 TfInfo_FocusSearchField }
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
{ @end $5A0760 }

{ @routine $5A0B64 TfInfo_ToggleSearchMode }
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
{ @end $5A0B64 }

{ @routine $5A0C6C TfInfo_MainPanelMouseDown }
procedure TfInfo.MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  FocusSearchField(False);
end;
{ @end $5A0C6C }

{ @routine $5A0C98 TfInfo_MainPanelKeyDown }
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
{ @end $5A0C98 }

{ @routine $5A1074 TfInfo_MainPanelKeyUp }
procedure TfInfo.MainPanelKeyUp(Sender: TObjectGI; Key: Cardinal);
begin
end;
{ @end $5A1074 }

{ @routine $5A1088 TfInfo_ProcessMouseWheel }
procedure TfInfo.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then InfoPanel.VerticalScrollBar.SetPosition(InfoPanel.VerticalScrollBar.Position - InfoPanel.VerticalScrollBar.SmallChange * 5)
  else if Delta = -WHEEL_DELTA then InfoPanel.VerticalScrollBar.SetPosition(InfoPanel.VerticalScrollBar.Position + InfoPanel.VerticalScrollBar.SmallChange * 5);
end;
{ @end $5A1088 }

{ @routine $5A113C TfInfo_BookmarkClicked }
procedure TfInfo.BookmarkClicked(Sender: TObjectGI);
var Key: WideString;
begin
  SoundManager.PlaySound('Sound.UserMsgAdd');
  if Sender.UserValue <> 0 then Key := 'GOODS ' + IntToStr(Cardinal(Sender.UserValue)) else Key := '';
  AddOrUpdatePlayerBubble(7,Galaxy.CurrentTurn,Sender.HelpText,Key);
  MainPanel.RebuildMessageButtons(False);
  (Sender as TGraphButtonGI).SetDisabled(True);
  BreakUiMessage;
end;
{ @end $5A113C }

{ @routine $5A125C TfInfo_SelectMusic }
procedure TfInfo.SelectMusic;
begin
  if ((ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1)) then Exit;
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
    if not MusicInPlanetEnabled then
    begin
      MusicManager.RequestFadeOut;
      Exit;
    end;
    if GetPlayer.DockedTo.TypeId in [Ord(rstPirateBase),Ord(rstDominion)] then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end;
end;
{ @end $5A125C }

{ @routine $5A14C4 TfInfo_ShowNews }
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
    AddInfoHeading(WrapTextInColor(Galaxy.FormatTurnDate(Entry.Turn) + Source,'<color=255,240,100>'),
      WrapTextInColor(Galaxy.FormatTurnDate(Entry.Turn),'<color=255,240,100>') + #13#10 + ' ' + #13#10 + Entry.Text,1,0,0);
    AddInfoText(' .',taxCenter,'');
    AddInfoText(Entry.Text,taxAuto,'');
    AddInfoText(' .',taxCenter,'');
    AddInfoSpacing(10);
  end;
  FinishInfoLayout;
end;
{ @end $5A14C4 }

{ @routine $5A1784 TfInfo_ShowSearch }
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
{ @end $5A1784 }

{ @routine $5A1A3C TfInfo_SearchClicked }
procedure TfInfo.SearchClicked(Sender: TObjectGI);
begin
  RunSearch(Sender);
end;
{ @end $5A1A3C }

{ @routine $5A5DA8 TfInfo_RunSearch }
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
  StationType: Byte;
  MinGoodsCount, MinSellPrice, MaxBuyPrice: Integer;
  GoodsSelected: array[0..7] of Boolean;
  Good: Byte;

  // @nested $5A1A58 GetInfoQualityGrade
  function GetInfoQualityGrade(Quality: Single): WideString; // @addr $5A1A58 @ida "void __userpurge $name(unsigned __int16 **Result@<eax>, float Quality@<^0>, void *ParentFrame@<^4>);" @stackpop 4 @calls "0x5A21C0" Nested in RunSearch.
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

  // @nested $5A1B54 GetInfoEquipmentSummary
  function GetInfoEquipmentSummary(Item: TItem): WideString; // @addr $5A1B54 @ida "void __usercall $name(TItem *Item@<eax>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x5a3ece" Nested in RunSearch.
  var Detail, Text: WideString;
  begin
    Text := '';
    Text := Text + FormatText1(LocalizedText('FormInfo.Equipment.Cost'),'<color=255,240,100>','<val>',IntToStr(Item.GetConditionAdjustedCost));
    if Item.ItemType in [t_Hull..t_CustomWeapon] then Text := Text + ', ';
    if Item is TScaner then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Scaner'),'','<val>','<Percent>');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
    end
    else if Item is TRadar then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Radar'),'','<val>','<Radius>');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
    end
    else if Item is TFuelTanks then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Fuel'),'','<val>','<Capacity>');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
    end
    else if Item is TEngine then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Speed'),'','<val>','<Speed>') + ', ' + FormatText1(LocalizedText('FormInfo.Equipment.Jump'),'','<val>','<Parsec>');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
    end
    else if Item is TRepairRobot then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Droid'),'','<val>','<RecoverHitPoints>');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
    end
    else if Item is TCargoHook then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Hook'),'','<val>','<PickUpSize>') + ', ' + FormatText1(LocalizedText('FormInfo.Equipment.HookRadius'),'','<val>','<Radius>');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
    end
    else if Item is TDefGenerator then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Defend'),'','<val>','<Percent>');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
    end
    else if Item is TWeapon then
    begin
      if (Cardinal(TWeapon(Item).GetDamageFlags) and $100000) <> 0 then
        Detail := FormatText1(LocalizedText('FormInfo.Equipment.Damage'),'','<min>-<max>','<MaxDamage><Bonus>') + ', ' +
          FormatText1(LocalizedText('FormInfo.Equipment.Radius'),'','<val>','<Radius>')
      else Detail := FormatText2(LocalizedText('FormInfo.Equipment.Damage'),'','<min>','<MinDamage>','<max>','<MaxDamage><Bonus>') + ', ' +
          FormatText1(LocalizedText('FormInfo.Equipment.Radius'),'','<val>','<Radius>');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
      if ((Item as TWeapon).SpecialModuleIndex <> 0) and
        (MicroModuleTemplates[(Item as TWeapon).SpecialModuleIndex - 1].TextReplace = WideString('')) then
        Text := Text + #13#10 + LocalizedText('Items.Weapon.WSpecial') + ' ' +
          WrapTextInColor(TEquipment(Item).GetSpecialModuleName,'<color=255,240,100>');
    end
    else if Item is THull then
    begin
      Detail := FormatText1(LocalizedText('FormInfo.Equipment.Protect'),'','<val>','<HitProtect>') + #13#10 +
        LocalizedText('FormInfo.Equipment.Susceptibility');
      TEquipment(Item).ReplaceInfoTokens(Detail,'<color=255,240,100>',nil);
      Text := Text + Detail;
      if THull(Item).HullSeries <> -1 then
        Text := Text + #13#10 + FormatText1(LocalizedText('FormInfo.Equipment.Series'),'<color=255,240,100>','<val>',HullSeriesDefinitions[THull(Item).HullSeries].Name);
    end;
    if (Item is TEquipment) and (Item.ItemType in [t_FuelTanks..t_CustomWeapon,t_Satellite]) then
      Text := Text + #13#10 + FormatText1(LocalizedText('FormInfo.Equipment.Reliability'),'<color=255,240,100>','<val>',
        GetInfoQualityGrade(TEquipment(Item).GetFragilityFactor([])));
    Result := Text;
  end;

  // @nested $5A27E8 AddInfoSearchResult
  procedure AddInfoSearchResult(Value: TObject); // @addr $5A27E8 @ida "void __usercall $name(TObject *Value@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x5a49b9,0x5a4a73,0x5a4b2c,0x5a4be6,0x5a4ca0,0x5a4d59,0x5a4e21,0x5a4f2c,0x5a5154,0x5a52c0,0x5a5502,0x5a577f,0x5a5a53,0x5a7e89,0x5a7f6d,0x5a800e,0x5a80e8,0x5a819d,0x5a8263,0x5a82ef,0x5a83e5" Nested in RunSearch; captures location, count, and displayed objects.
  var GoodsText, Color: WideString; Good, GoodIndex: Byte;
  begin
    if (Value is TShip) and (Ship <> nil) and not (Ship.OwnerId in [Ord(oiMaloc)..Ord(oiGaal),Ord(oiPirate)]) then Exit;
    if (ResultCount < GetSearchResultLimit) and (Shown.IndexOf(Value) < 0) then
    begin
      Shown.Add(Value);
      if not Found then
      begin
        AddInfoText(FormatText1(LocalizedText('FormInfo.ObjectFoundStart'),'<color=255,240,100>','<Count>',IntToStr(GetSearchResultLimit)),taxCenter,'');
        AddInfoText(' .',taxCenter,'');
      end;
      if (Value is TRuins) and not TRuins(Value).NoLanding then
      begin
        Station := Value as TRuins;
      Description := FormatText1(LocalizedText('FormInfo.Sector'),'<color=255,240,100>','<SectorName>',Station.CurrentStar.Constellation.GetName);
      Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),'<color=255,240,100>','<StarName>',Station.CurrentStar.Name);
      GoodsText := '';
      for GoodIndex := 0 to 7 do
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
        Heading := WrapTextInColor('- ' + WrapTextInColor(Station.GetFullName(' '),'<color=255,240,100>') + ' -','<color=255,240,100>');
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,Integer(Cardinal(Station.Id) or $80000000));
        AddInfoText(' .',taxCenter,'');
        AddInfoImageText(ExtractDelimitedPartW(Station.GetShipPortraitImagePath,1,','),Description);
      end
      else if Value is TShip then
      begin
      Description := FormatText1(LocalizedText('FormInfo.Sector'),'<color=255,240,100>','<SectorName>',Ship.CurrentStar.Constellation.GetName);
      Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),'<color=255,240,100>','<StarName>',Ship.CurrentStar.Name);
        if Ship.CurrentPlanet <> nil then
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Planet'),'<color=255,240,100>','<PlanetName>',Ship.CurrentPlanet.Name);
        if Ship.IsInPrison then Description := Description + #13#10 + LocalizedText('FormInfo.InPrison');
        Ship.DaysSincePlayerSeen := 0;
        Heading := WrapTextInColor('- ' + WrapTextInColor(Ship.GetFullName(' '),'<color=255,240,100>') + ' -','<color=255,240,100>');
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,0);
        AddInfoText(' .',taxCenter,'');
        AddInfoImageText(ExtractDelimitedPartW(Ship.GetShipPortraitImagePath,1,','),Description);
      end
      else if Value is TPlanet then
      begin
      Description := FormatText1(LocalizedText('FormInfo.Sector'),'<color=255,240,100>','<SectorName>',Planet.CurrentStar.Constellation.GetName);
      Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),'<color=255,240,100>','<StarName>',Planet.CurrentStar.Name);
        Description := Description + #13#10 + Planet.GetInfoText(True);
        GoodsText := '';
        if (Planet.IsCoalitionOwned or (Planet.OwnerId = Byte(oiPirate))) and (Planet.CurrentStar.Status.CustomFaction = WideString('')) then
        begin
      for GoodIndex := 0 to 7 do
      begin
        Good := GoodsTextOrder[GoodIndex];
        GoodsText := GoodsText + #13#10 + '<td=' + IntToStr(GiScalePixels(5)) + '>' + '<align=center>' + WrapTextInColor(IntToStr(GoodIndex + 1),'') + '.' + '</align>';
        if GoodsLegalOnPlanet[Good,Planet.RaceId,Ord(Planet.Government)] or (Planet.OwnerId = Byte(oiPirate)) then Color := ''
        else Color := '<color=255,0,0>';
        GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(15)) + '>' + WideString('') + WrapTextInColor(GoodsMarket[Good].DisplayName,Color) + WideString('');
        GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(160)) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Planet.Goods[Good].Count),'') + '</align>';
        GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(205)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good,Planet)),'') + '</align>';
        GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(215)) + '><align=center>' + WrapTextInColor('/','') + '</align>';
        GoodsText := GoodsText + '<td=' + IntToStr(GiScalePixels(255)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good,Planet)),'') + '</align>';
      end;
        end;
        Description := Description + GoodsText;
        Heading := WrapTextInColor('- ' + WrapTextInColor(Planet.GetFullName(' '),'<color=255,240,100>') + ' -','<color=255,240,100>');
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,Planet.Id);
        AddInfoText(' .',taxCenter,'');
        AddPlanetInfoText(Value as TPlanet,Description);
      end
      else if Value is TStar then
      begin
        Description := FormatText1(LocalizedText('FormInfo.Sector'),'<color=255,240,100>','<SectorName>',Star.Constellation.GetName);
        Heading := FormatText1('- ' + LocalizedText('FormInfo.StarInfo.StarName') + ' -','<color=255,240,100>','<StarName>',(Value as TStar).Name);
        if TStar(Value).Status.CustomFaction <> WideString('') then
          Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.ControlledBy' + TStar(Value).Status.CustomFaction)
        else
          case TStar(Value).ControlFaction of
            sfCoalition: Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.ControlledByCoalition');
            sfPirates: Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.ControlledByPirates');
            sfDominators: Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.ControlledByDominators');
          end;
        if GetPlayer.CurrentStar <> Value then
        begin
          Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.RelativeLocation');
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.StarInfo.RelativeLocationDist'),'<color=255,240,100>','<Dist>',IntToStr(Round(PointDistance((Value as TStar).Position,GetPlayer.CurrentStar.Position))));
          Bearing := Round(PointBearingDegrees((Value as TStar).Position,GetPlayer.CurrentStar.Position));
          Bearing := Bearing + 180 - 15;
          if Bearing >= 360 then Dec(Bearing,360);
          Bearing := Bearing div 30 + 1;
          if Bearing = 1 then
            Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.StarInfo.RelativeLocationAngle0'),'<color=255,240,100>','<Angle>',IntToStr(Bearing));
          if (Bearing > 1) and (Bearing <= 4) then
            Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.StarInfo.RelativeLocationAngle1'),'<color=255,240,100>','<Angle>',IntToStr(Bearing));
          if Bearing > 4 then
            Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.StarInfo.RelativeLocationAngle2'),'<color=255,240,100>','<Angle>',IntToStr(Bearing));
        end;
        if (Value as TStar).Battle <> 0 then Description := Description + #13#10 + LocalizedText('FormInfo.StarInfo.BattleInSystem');
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,0);
        AddInfoText(' .',taxCenter,'');
        AddStarInfoText(Value as TStar,Description);
      end
      else if Value is TEquipment then
      begin
        if Planet <> nil then
        begin
      Description := FormatText1(LocalizedText('FormInfo.Sector'),'<color=255,240,100>','<SectorName>',Planet.CurrentStar.Constellation.GetName);
      Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),'<color=255,240,100>','<StarName>',Planet.CurrentStar.Name);
          Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Planet'),'<color=255,240,100>','<PlanetName>',Planet.Name);
        end
        else
        begin
      Description := FormatText1(LocalizedText('FormInfo.Sector'),'<color=255,240,100>','<SectorName>',Ship.CurrentStar.Constellation.GetName);
      Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),'<color=255,240,100>','<StarName>',Ship.CurrentStar.Name);
          Description := Description + #13#10 + WrapTextInColor(Ship.GetFullName(' '),'<color=255,240,100>');
        end;
        Heading := WrapTextInColor('- ' + WrapTextInColor(RemoveTextTagsW(TItem(Value).GetDisplayName),'<color=255,240,100>') + ' [' +
          WrapTextInColor(IntToStr(TItem(Value).Weight),'<color=0,255,0>') + ']' + ' -','<color=255,240,100>');
        Description := Description + #13#10 + GetInfoEquipmentSummary(TItem(Value));
        AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,0);
        AddInfoText(' .',taxCenter,'');
        if Value is THull then AddEquipmentInfoText(Value as TItem,Description)
        else AddItemInfoText(Value as TItem,Description);
      end;
      Found := True;
      Inc(ResultCount);
    end;
  end;

  // @nested $5A48CC CheckInfoSearchResult
  procedure CheckInfoSearchResult(Value: TObject); // @addr $5A48CC @ida "void __usercall $name(TObject *Value@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x5a7e95,0x5a7f79,0x5a801d,0x5a80f7,0x5a81a9,0x5a8272,0x5a82fe,0x5a83f1" Nested in RunSearch; applies the active category filters.
  var
    Engine: TEngine; Fuel: TFuelTanks; Radar: TRadar; Scanner: TScaner;
    Droid: TRepairRobot; Hook: TCargoHook; Defense: TDefGenerator;
    CandidateStar: TStar; CandidatePlanet: TPlanet; CandidateStation: TRuins;
    Hull: THull; Weapon: TWeapon; CandidateShip: TShip;
    I, EffectiveRange: Integer; Entry: PExtraSpecial;
  begin
    if SelectedSearchCategory = 1 then
    begin
      if Value is TEngine then
      begin
        Engine := Value as TEngine;
        if ((MinSpeed = 0) or (MinSpeed <= Engine.Speed)) and
          ((RangeFilter = 0) or (Engine.JumpRange >= RangeFilter)) and
          ((SizeFilter = 0) or (SizeFilter >= Engine.Weight)) and
          ((MaxCost = 0) or (Engine.GetConditionAdjustedCost <= MaxCost)) and
          (Engine.OwnerId in Owners) then AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 2 then
    begin
      if Value is TFuelTanks then
      begin
        Fuel := Value as TFuelTanks;
        if ((MinFuel = 0) or (Fuel.Capacity >= MinFuel)) and
          ((SizeFilter = 0) or (Fuel.Weight <= SizeFilter)) and
          ((MaxCost = 0) or (Fuel.GetConditionAdjustedCost <= MaxCost)) and
          (Fuel.OwnerId in Owners) then AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 3 then
    begin
      if Value is TRadar then
      begin
        Radar := Value as TRadar;
        if ((RangeFilter = 0) or (Radar.Range >= RangeFilter)) and
          ((SizeFilter = 0) or (Radar.Weight <= SizeFilter)) and
          ((MaxCost = 0) or (Radar.GetConditionAdjustedCost <= MaxCost)) and
          (Radar.OwnerId in Owners) then AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 4 then
    begin
      if Value is TScaner then
      begin
        Scanner := Value as TScaner;
        if ((MinPower = 0) or (Scanner.ScanPower >= MinPower)) and
          ((SizeFilter = 0) or (Scanner.Weight <= SizeFilter)) and
          ((MaxCost = 0) or (Scanner.GetConditionAdjustedCost <= MaxCost)) and
          (Scanner.OwnerId in Owners) then AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 5 then
    begin
      if Value is TRepairRobot then
      begin
        Droid := Value as TRepairRobot;
        if ((MinPower = 0) or (Droid.RepairPoints >= MinPower)) and
          ((SizeFilter = 0) or (Droid.Weight <= SizeFilter)) and
          ((MaxCost = 0) or (Droid.GetConditionAdjustedCost <= MaxCost)) and
          (Droid.OwnerId in Owners) then AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 6 then
    begin
      if Value is TCargoHook then
      begin
        Hook := Value as TCargoHook;
        if ((MinPickup = 0) or (Hook.PickupPower >= MinPickup)) and
          ((SizeFilter = 0) or (Hook.Weight <= SizeFilter)) and
          ((MaxCost = 0) or (Hook.GetConditionAdjustedCost <= MaxCost)) and
          (Hook.OwnerId in Owners) then AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 7 then
    begin
      if Value is TDefGenerator then
      begin
        Defense := Value as TDefGenerator;
        if ((MinDefense = 0) or (DefenseDamageFactorToPercent(Defense.DamageFactor) >= MinDefense)) and
          ((SizeFilter = 0) or (Defense.Weight <= SizeFilter)) and
          ((MaxCost = 0) or (Defense.GetConditionAdjustedCost <= MaxCost)) and
          (Defense.OwnerId in Owners) then AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 8 then
    begin
      if Value is TStar then
      begin
        CandidateStar := Value as TStar;
        if (CandidateStar.ControlFaction = sfDominators) and not IncludeDominators then Exit;
        if (CandidateStar.ControlFaction = sfCoalition) and not IncludeCoalition then Exit;
        if (CandidateStar.ControlFaction = sfPirates) and not IncludePirates then Exit;
        if (CandidateStar.Status.CustomFaction <> WideString('')) and (not IncludeDominators or not IncludeCoalition or not IncludePirates) then Exit;
        if (RangeFilter <> 0) and (RangeFilter < Round(PointDistance(CandidateStar.Position,GetPlayer.CurrentStar.Position))) then Exit;
        AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 9 then
    begin
      if Value is TPlanet then
      begin
        CandidatePlanet := Value as TPlanet;
        if (CandidatePlanet.OwnerId = Byte(oiDominator)) and (CandidatePlanet.CurrentStar.Status.CustomFaction = WideString('')) and not IncludeDominators then Exit;
        if (CandidatePlanet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal),Ord(oiPirate)]) and (CandidatePlanet.CurrentStar.Status.CustomFaction = WideString('')) and not IncludeCoalition then Exit;
        if (CandidatePlanet.CurrentStar.Status.CustomFaction <> WideString('')) and (not IncludeDominators or not IncludeCoalition) then Exit;
        if (CandidatePlanet.OwnerId = Byte(oiUninhabited)) and not IncludeUninhabited then Exit;
        if (((CandidatePlanet.OwnerId = Byte(oiPirate)) and (CandidatePlanet.CurrentStar.Status.CustomFaction = WideString('')) and
          (CandidatePlanet.OwnerId in Owners) and IncludeCoalition) or
          (RaceToOwner(CandidatePlanet.RaceId) in Owners) or (CandidatePlanet.CurrentStar.Status.CustomFaction <> WideString('')) or
          (not IncludeDominators and not IncludeCoalition)) then
        begin
          if (RangeFilter <> 0) and (RangeFilter < Round(PointDistance(CandidatePlanet.CurrentStar.Position,GetPlayer.CurrentStar.Position))) then Exit;
          if (ConstellationFilter <> WideString('')) and (FindLowercaseInfoText(ConstellationFilter,WideLowerCase(CandidatePlanet.CurrentStar.Constellation.GetName)) <= 0) then Exit;
          if (StarFilter <> WideString('')) and (FindLowercaseInfoText(StarFilter,WideLowerCase(CandidatePlanet.CurrentStar.Name)) <= 0) then Exit;
          AddInfoSearchResult(Value);
        end;
      end;
    end
    else if SelectedSearchCategory = 10 then
    begin
      if Value is TRuins then
      begin
        CandidateStation := Value as TRuins;
        if CandidateStation.TypeNameOverrideKey <> WideString('') then
        begin
          if StationTypes <> [] then Exit;
        end
        else if not (CandidateStation.TypeId in StationTypes) then Exit;
        if CandidateStation.OwnerId = Byte(oiDominator) then Exit;
        if CandidateStation.HasIndependentScriptFaction then Exit;
        if (RangeFilter <> 0) and (RangeFilter < Round(PointDistance(CandidateStation.CurrentStar.Position,GetPlayer.CurrentStar.Position))) then Exit;
        if (ConstellationFilter <> WideString('')) and (FindLowercaseInfoText(ConstellationFilter,WideLowerCase(CandidateStation.CurrentStar.Constellation.GetName)) <= 0) then Exit;
        if (StarFilter <> WideString('')) and (FindLowercaseInfoText(StarFilter,WideLowerCase(CandidateStation.CurrentStar.Name)) <= 0) then Exit;
        AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 11 then
    begin
      if Value is THull then
      begin
        Hull := Value as THull;
        if (Hull.OwnerId in Owners) and
          ((Hull.HullType <> htRanger) or IncludeRangerType) and
          ((Hull.HullType <> htWarrior) or IncludeWarriorType) and
          ((Hull.HullType <> htPirate) or IncludePirateType) and
          ((Hull.HullType <> htTransport) or IncludeTransportType) and
          ((Hull.HullType <> htLiner) or IncludeLinerType) and
          ((Hull.HullType <> htDiplomat) or IncludeDiplomatType) and
          ((SizeFilter = 0) or (Hull.Weight >= SizeFilter)) and
          ((MinArmor = 0) or (Hull.Armor >= MinArmor)) and
          ((MaxCost = 0) or (Hull.GetConditionAdjustedCost <= MaxCost)) and
          ((WeaponSlots = 0) or (Hull.GetSlotCount(sskWeapon) >= WeaponSlots)) and
          ((ScannerSlots = 0) or (Hull.GetSlotCount(sskScanner) >= ScannerSlots)) and
          ((RadarSlots = 0) or (Hull.GetSlotCount(sskRadar) >= RadarSlots)) and
          ((DroidSlots = 0) or (Hull.GetSlotCount(sskRepairRobot) >= DroidSlots)) and
          ((HookSlots = 0) or (Hull.GetSlotCount(sskCargoHook) >= HookSlots)) and
          ((DefenseSlots = 0) or (Hull.GetSlotCount(sskDefGenerator) >= DefenseSlots)) and
          ((ArtifactSlots = 0) or (Hull.GetSlotCount(sskArtefact) >= ArtifactSlots)) and
          ((AfterburnerSlots = 0) or (Hull.GetSlotCount(sskAfterburner) >= AfterburnerSlots)) then AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 12 then
    begin
      if Value is TWeapon then
      begin
        Weapon := Value as TWeapon;
        if not (Weapon.OwnerId in Owners) then Exit;
        if RangeFilter <> 0 then
        begin
          EffectiveRange := Weapon.Range;
          if Weapon.ExtraSpecials <> nil then
            for I := 0 to Weapon.ExtraSpecials.Count - 1 do
            begin
              Entry := Weapon.ExtraSpecials[I];
              Inc(EffectiveRange,MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(bonWRadius)] * Entry.Count);
            end;
          if Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
            EffectiveRange := Min(EffectiveRange - Weapon.CalculateGeneratedRange + Weapon.GetWeaponInfo.MissileRange,Weapon.GetWeaponInfo.MissileRange);
          if RangeFilter > EffectiveRange then Exit;
        end;
        if (SizeFilter <> 0) and (Weapon.Weight > SizeFilter) then Exit;
        if (MaxCost <> 0) and (Weapon.GetConditionAdjustedCost > MaxCost) then Exit;
        if ((Cardinal(Weapon.GetDamageFlags) and 1) <> 0) and not IncludeEnergy then Exit;
        if ((Cardinal(Weapon.GetDamageFlags) and 2) <> 0) and not IncludeSplinter then Exit;
        if (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and not IncludeMissile then Exit;
        if MinDamage <> 0 then
        begin
          if (Cardinal(Weapon.GetDamageFlags) and $100000) <> 0 then
          begin
            if MinDamage > Max(Weapon.MaxDamage,Weapon.MinDamage) then Exit;
          end
          else if Weapon.MinDamage < MinDamage then Exit;
        end;
        if (MaxDamage <> 0) and (Weapon.MaxDamage < MaxDamage) then Exit;
        if (NameFilter <> WideString('')) and not ItemMatchesInfoSearch(Weapon,NameFilter) then Exit;
        AddInfoSearchResult(Value);
      end;
    end
    else if SelectedSearchCategory = 15 then
    begin
      if Value is TShip then
      begin
        CandidateShip := Value as TShip;
        // The native category tests these four TypeId values and the six
        // checkbox slots directly, including their historical UI mapping.
        if (CandidateShip.OwnerId in Owners) and
          ((RaceToOwner(CandidateShip.PilotRace) in Owners) or (Owners = [Ord(oiPirate)])) and
          not CandidateShip.HasScriptStateText and (CandidateShip.TypeId in [stRanger..stWarrior]) and
          ((CandidateShip.TypeNameOverrideKey = WideString('')) or
            (IncludeRangerType and IncludeWarriorType and IncludePirateType and IncludeTransportType and IncludeLinerType and IncludeDiplomatType)) and
          ((CandidateShip.TypeId <> stRanger) or IncludeRangerType) and
          ((CandidateShip.TypeId <> stWarrior) or IncludeWarriorType) and
          ((CandidateShip.TypeId <> stPirate) or IncludePirateType) and
          ((CandidateShip.TypeId <> stTransport) or ((CandidateShip as TTransport).TransportType <> ttTransport) or IncludeTransportType) and
          ((CandidateShip.TypeId <> stTransport) or ((CandidateShip as TTransport).TransportType <> ttLiner) or IncludeLinerType) and
          ((CandidateShip.TypeId <> stTransport) or ((CandidateShip as TTransport).TransportType <> ttDiplomat) or IncludeDiplomatType) and
          ((ConstellationFilter = WideString('')) or (FindLowercaseInfoText(ConstellationFilter,WideLowerCase(CandidateShip.CurrentStar.Constellation.GetName)) > 0)) and
          ((StarFilter = WideString('')) or (FindLowercaseInfoText(StarFilter,WideLowerCase(CandidateShip.CurrentStar.Name)) > 0)) and
          ((NameFilter = WideString('')) or (FindLowercaseInfoText(NameFilter,WideLowerCase(CandidateShip.GetFullName(' '))) > 0) or
            (FindLowercaseInfoText(NameFilter,WideLowerCase(CandidateShip.GetLocalizedTypeName)) > 0)) then AddInfoSearchResult(Value);
      end;
    end;
  end;

  // @nested $5A5A94 ReadInfoSearchOwners
  procedure ReadInfoSearchOwners(Category: Integer); // @addr $5A5A94 @ida "void __usercall $name(int Category@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x5a60c1,0x5a6154,0x5a61e7,0x5a627a,0x5a630d,0x5a63a0,0x5a6433,0x5a65e9,0x5a6b64,0x5a6cef,0x5a7ded" Nested in RunSearch; captures the owner filter set.
  begin
    Owners := [];
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Maloc') as TGraphButtonGI).Down then Include(Owners, Ord(oiMaloc));
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Peleng') as TGraphButtonGI).Down then Include(Owners, Ord(oiPeleng));
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'People') as TGraphButtonGI).Down then Include(Owners, Ord(oiHuman));
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Fei') as TGraphButtonGI).Down then Include(Owners, Ord(oiFeyan));
    if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Gaal') as TGraphButtonGI).Down then Include(Owners, Ord(oiGaal));
    if FindControlByPath('M' + IntToFixedWidthWideString(Category,2) + 'Pirate') <> nil then
      if not (GetByName('M' + IntToFixedWidthWideString(Category,2) + 'Pirate') as TGraphButtonGI).Down then Include(Owners, Ord(oiPirate));
    if Owners = [] then Owners := [Ord(oiPirate)];
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
    AddInfoText(FormatText1(LocalizedText('FormInfo.NotMoney'),'<color=255,240,100>','<Money>',IntToStr(3)),taxCenter,'');
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
    if SearchText = WideString('') then SearchText := '   ';
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
      for StationType := Ord(rstRangerCenter) to Ord(rstDominion) do
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
      for I := 18 to DefaultHullSlotCounts[Ord(sskArtefact)] + 13 do
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
        Star := TObject(GetPlayer.CurrentStar.StarDistances[I].Star) as TStar;
        if (Star.Id = 71) or (Star.Id = 72) then Continue;
        if (RangeFilter <> 0) and (RangeFilter < Round(PointDistance(Star.Position,GetPlayer.CurrentStar.Position))) then Continue;
        if Star.Status.CustomFaction = WideString('') then
            begin
              for Index := 0 to Star.Planets.Count - 1 do
              begin
                if ResultCount >= GetSearchResultLimit then Break;
                Planet := TPlanet(Star.Planets[Index]);
                if Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal),Ord(oiPirate)] then
                begin
                  Heading := '';
                  for GoodsIndex := 0 to 7 do
                  begin
                    Good := GoodsTextOrder[GoodsIndex];
                    if ((MinGoodsCount = 0) or (Planet.Goods[Good].Count >= MinGoodsCount)) and GoodsSelected[Good] and
                      ((MaxBuyPrice = 0) or (GetPlayer.ShopGoodsPurchasePrice(Good,Planet) <= MaxBuyPrice)) and
                      ((MinSellPrice = 0) or (GetPlayer.ShopGoodsSellPrice(Good,Planet) >= MinSellPrice)) then
                    begin
                      Heading := Heading + #13#10 + '<td=' + IntToStr(GiScalePixels(5)) + '>' + '<align=center>' + WrapTextInColor(IntToStr(GoodsIndex + 1),'') + '.' + '</align>';
                      if GoodsLegalOnPlanet[Good,Planet.RaceId,Ord(Planet.Government)] or (Planet.OwnerId = Byte(oiPirate)) then SearchText := ''
                      else SearchText := '<color=255,0,0>';
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(15)) + '>' + WideString('') + WrapTextInColor(GoodsMarket[Good].DisplayName,SearchText) + WideString('');
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(160)) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Planet.Goods[Good].Count),'') + '</align>';
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(205)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good,Planet)),'') + '</align>';
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(215)) + '><align=center>' + WrapTextInColor('/','') + '</align>';
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(255)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good,Planet)),'') + '</align>';
                    end;
                  end;
                  if Heading <> WideString('') then
                  begin
                    Description := FormatText1(LocalizedText('FormInfo.Sector'),'<color=255,240,100>','<SectorName>',Planet.CurrentStar.Constellation.GetName);
                    Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),'<color=255,240,100>','<StarName>',Planet.CurrentStar.Name);
                    Description := Description + #13#10 + Planet.GetInfoText(False);
                    Description := Description + Heading;
                    Heading := WrapTextInColor('- ' + WrapTextInColor(Planet.GetFullName(' '),'<color=255,240,100>') + ' -','<color=255,240,100>');
                    AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,Planet.Id);
                    AddInfoText(' .',taxCenter,'');
                    AddPlanetInfoText(Planet,Description);
                    Found := True;
                    Inc(ResultCount);
                  end;
                end;
              end;
              Planet := nil;
              for Index := 0 to Star.Ships.Count - 1 do
              begin
                Ship := TShip(Star.Ships[Index]);
                if (Ship is TRuins) and ((Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> Byte(oiUninhabited))) then
                begin
                  Station := Ship as TRuins;
                  // Native exits here, bypassing the later list release and checksum.
                  if (Station.OwnerId = Byte(oiDominator)) or Station.HasIndependentScriptFaction then Exit;
                  if not Station.NoLanding then
                  begin
                    Heading := '';
                    for GoodsIndex := 0 to 7 do
                    begin
                      Good := GoodsTextOrder[GoodsIndex];
                      if ((MinGoodsCount = 0) or (Station.ShopGoods[Good].Count >= MinGoodsCount)) and GoodsSelected[Good] and
                        ((MaxBuyPrice = 0) or (GetPlayer.ShopGoodsPurchasePrice(Good,Station) <= MaxBuyPrice)) and
                        ((MinSellPrice = 0) or (GetPlayer.ShopGoodsSellPrice(Good,Station) >= MinSellPrice)) then
                      begin
                      Heading := Heading + #13#10 + '<td=' + IntToStr(GiScalePixels(5)) + '>' + '<align=center>' + WrapTextInColor(IntToStr(GoodsIndex + 1),'') + '.' + '</align>';
                      SearchText := '';
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(15)) + '>' + WideString('') + WrapTextInColor(GoodsMarket[Good].DisplayName,SearchText) + WideString('');
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(160)) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Station.ShopGoods[Good].Count),'') + '</align>';
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(205)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good,Station)),'') + '</align>';
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(215)) + '><align=center>' + WrapTextInColor('/','') + '</align>';
                      Heading := Heading + '<td=' + IntToStr(GiScalePixels(255)) + '><align=right>' + WrapTextInColor(IntToStr(GetPlayer.ShopGoodsSellPrice(Good,Station)),'') + '</align>';
                      end;
                    end;
                    if Heading <> WideString('') then
                    begin
                      Description := FormatText1(LocalizedText('FormInfo.Sector'),'<color=255,240,100>','<SectorName>',Station.CurrentStar.Constellation.GetName);
                      Description := Description + #13#10 + FormatText1(LocalizedText('FormInfo.Star'),'<color=255,240,100>','<StarName>',Station.CurrentStar.Name);
                      Description := Description + Heading;
                      Heading := WrapTextInColor('- ' + WrapTextInColor(Station.GetFullName(' '),'<color=255,240,100>') + ' -','<color=255,240,100>');
                      AddInfoHeading(Heading,Heading + #13#10 + Description,0,0,Integer(Cardinal(Station.Id) or $80000000));
                      AddInfoText(' .',taxCenter,'');
                      AddInfoImageText(ExtractDelimitedPartW(Station.GetShipPortraitImagePath,1,','),Description);
                      Found := True;
                      Inc(ResultCount);
                    end;
                  end;
                end;
              end;
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
      Star := TObject(GetPlayer.CurrentStar.StarDistances[I].Star) as TStar;
      if Star.Constellation.Id <> 20 then
      begin
        if SelectedSearchCategory = 0 then
        begin
          if FindLowercaseInfoText(SearchText,WideLowerCase(Star.Name)) > 0 then AddInfoSearchResult(Star);
        end
        else CheckInfoSearchResult(Star);
        Planet := nil;
        for Index := 0 to Star.Ships.Count - 1 do
        begin
          Ship := TShip(Star.Ships[Index]);
          if (Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> Byte(oiUninhabited)) then
          begin
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
                if Item <> nil then
                begin
                  if SelectedSearchCategory = 0 then
                  begin
                    if ItemMatchesInfoSearch(Item,SearchText) then AddInfoSearchResult(Item);
                  end
                  else CheckInfoSearchResult(Item);
                end;
              end;
            end
            else if (Ship is TRuins) and (Ship.OwnerId <> Byte(oiDominator)) and not Ship.HasIndependentScriptFaction and not TRuins(Ship).NoLanding then
            begin
              for ItemIndex := 0 to (Ship as TRuins).EquipmentShop.Count - 1 do
              begin
                Item := TItem(TRuins(Ship).EquipmentShop[ItemIndex]);
                if SelectedSearchCategory = 0 then
                begin
                  if ItemMatchesInfoSearch(Item,SearchText) then AddInfoSearchResult(Item);
                end
                else CheckInfoSearchResult(Item);
              end;
            end;
          end;
        end;
        for Index := 0 to Star.Planets.Count - 1 do
        begin
          Planet := TPlanet(Star.Planets[Index]);
          if SelectedSearchCategory = 0 then
          begin
            if FindLowercaseInfoText(SearchText,WideLowerCase(Planet.GetFullName(' '))) > 0 then AddInfoSearchResult(Planet);
          end
          else CheckInfoSearchResult(Planet);
          if Planet.IsCoalitionOwned or (Planet.OwnerId = Byte(oiPirate)) then
          begin
            if (GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet = Planet) and (TemporaryShopSlots <> nil) then
            begin
              for ItemIndex := 0 to TemporaryShopSlots.Count - 1 do
              begin
                Item := TShopSlot(TemporaryShopSlots[ItemIndex]).Item;
                if Item <> nil then
                begin
                  if SelectedSearchCategory = 0 then
                  begin
                    if ItemMatchesInfoSearch(Item,SearchText) then AddInfoSearchResult(Item);
                  end
                  else CheckInfoSearchResult(Item);
                end;
              end;
            end
            else
              for ItemIndex := 0 to Planet.EquipmentShop.Count - 1 do
              begin
                Item := TItem(Planet.EquipmentShop[ItemIndex]);
                if SelectedSearchCategory = 0 then
                begin
                  if ItemMatchesInfoSearch(Item,SearchText) then AddInfoSearchResult(Item);
                end
                else CheckInfoSearchResult(Item);
              end;
            for ItemIndex := 0 to Planet.Warriors.Count - 1 do
            begin
              Ship := TShip(Planet.Warriors[ItemIndex]);
              if Ship.CurrentStar.Ships.IndexOf(Ship) < 0 then
              begin
                if SelectedSearchCategory = 0 then
                begin
                  if (FindLowercaseInfoText(SearchText,WideLowerCase(Ship.GetFullName(' '))) > 0) or
                    (FindLowercaseInfoText(SearchText,WideLowerCase(Ship.GetLocalizedTypeName)) > 0) then AddInfoSearchResult(Ship);
                end
                else CheckInfoSearchResult(Ship);
              end;
            end;
          end;
        end;
      end;
    end;
    if Found then
    begin
      AddInfoSpacing(10);
      AddInfoSeparator;
      AddInfoText(' .',taxCenter,'');
      AddInfoText(FormatText1(LocalizedText('FormInfo.ObjectFoundEnd'),'<color=255,240,100>','<Count>',IntToStr(ResultCount)),taxCenter,'');
      GetPlayer.SetMoney(GetPlayer.Money - 3);
      SoundManager.PlaySound('Sound.Sell');
      SetFocusedControl(nil);
    end
    else
    begin
      ClearInfoContents;
      AddInfoSpacing(15);
      AddInfoText(LookupLocalizedTextByKey('FormInfo.NotFound'),taxCenter,'');
      SoundManager.PlaySound('Sound.NoMoney');
    end;
    AddInfoSpacing(10);
    AddInfoText(' .',taxCenter,'');
    FinishInfoLayout;
    Galaxy.PrimeIntegrityChecksum(208);
    Shown.Free;
  end;
end;
{ @end $5A5DA8 }

{ @routine $5A9420 TfInfo_AddEquipmentInfoText }
procedure TfInfo.AddEquipmentInfoText(Item: TItem; Text: WideString);
var Size, Height: Integer; Slots, Image: TGraphBufGI; Caption: TLabelGI;
begin
  Text := ReplaceAllWideString(Text,'<color=255,240,100>','<color=0,50,200>');
  Text := ReplaceAllWideString(Text,'<color=0,255,0>','<color=0,130,0>');
  Text := ReplaceAllWideString(Text,'<color=255,167,84>','<color=240,100,30>');
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
  if Cardinal(Image.GraphBuf.Width) >= Cardinal(Image.GraphBuf.Height) then
    Image.GraphBuf.RescaleRgba(Image.ClientSize.X,Round(Image.ClientSize.X / Cardinal(Image.GraphBuf.Width) * Cardinal(Image.GraphBuf.Height)),5)
  else Image.GraphBuf.RescaleRgba(Round(Image.ClientSize.Y / Cardinal(Image.GraphBuf.Height) * Cardinal(Image.GraphBuf.Width)),Image.ClientSize.Y,5);
  Caption := TLabelGI.Create(InfoPanel);
  if (GiResourceVariant = 2) or (Item is THull) then Caption.SetFontName(NormalFontName)
  else Caption.SetFontName(SmallFontName);
  Caption.SetPosition(Types.Point(Size + 10,InfoContentHeight));
  Caption.SetSize(Types.Point(InfoPanel.ClientSize.X - Caption.LocalPosition.X - 70,Height));
  Caption.SetWordWrapEnabled(True);
  Caption.SetPositionModeW(True);
  Caption.SetTextAlignX(taxLeft);
  Caption.SetTextAlignY(tayCenter);
  Caption.SetText(Text);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  InfoContentHeight := InfoContentHeight + Height + 5;
end;
{ @end $5A9420 }

{ @routine $5A99B0 TfInfo_ToggleVisibleBookmark }
// The explicit receiver value preserves native loading before the False argument.
procedure TfInfo.ToggleVisibleBookmark;
var I, ScrollPosition: Integer; Button: TGraphButtonGI; Finished: Boolean; Entry: TMessagePlayer;
begin
  if SearchMode then
  begin
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
    if Button <> nil then
    begin
      Entry := FindPlayerBubbleByText(Button.HelpText,False);
      if Entry <> nil then
      begin
        RemovePersistentPlayerMessage(Entry,False);
        MainPanel.Screen.GetByName('PM_WinMsg').SetActive(False);
        TfPanelMain(Integer(MainPanel) + 0).RebuildMessageButtons(False);
        Button.SetDisabled(False);
        SoundManager.PlaySound('Sound.DelMsg');
      end
      else BookmarkClicked(Button);
    end;
  end;
end;
{ @end $5A99B0 }

{ @routine $5A9B60 TfInfo_IsAtBusinessCenter }
function TfInfo.IsAtBusinessCenter: Boolean;
begin
  Result := False;
  if (GetPlayer <> nil) and (GetPlayer.DockedTo <> nil) and (GetPlayer.DockedTo.TypeId = Byte(rstRangerCenter)) then Result := True;
end;
{ @end $5A9B60 }

{ @routine $5A9B9C TfInfo_CategoryStateChanged }
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
{ @end $5A9B9C }

{ @routine $5A9C70 TfInfo_CategoryClicked }
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
  if SelectedSearchCategory = 14 then
  begin
    InfoPanel.SetActive(True);
    InfoPanel.VerticalScrollBar.SetActive(True);
    ClearInfoContents;
    AddInfoSpacing(2);
    AddInfoText(LocalizedColorText('FormInfo.SearchInfo1'),taxCenter,NormalBoldFontName);
    AddInfoSpacing(10);
    AddInfoSeparator;
    AddInfoSpacing(5);
    AddInfoText(LocalizedColorText('FormInfo.SearchInfo6'),taxCenter,SmallBoldFontName);
    AddInfoSpacing(10);
    AddInfoSeparator;
    AddInfoSpacing(10);
    AddSearchPriceLabel(LocalizedColorText('FormInfo.SearchInfo2'));
    AddInfoSpacing(5);
    AddInfoText(FormatText1(LocalizedColorText('FormInfo.SearchInfo3'),'<color=0,50,200>','<Count>',IntToStr(GetSearchResultLimit)),taxAuto,SmallFontName);
    AddInfoSpacing(10);
    AddInfoSeparator;
    AddInfoSpacing(5);
    AddInfoText(LocalizedColorText('FormInfo.SearchInfo7'),taxLeft,SmallBoldFontName);
    AddInfoSpacing(5);
    AddInfoText(LocalizedColorText('FormInfo.SearchInfo8'),taxLeft,SmallFontName);
    AddInfoSpacing(10);
    AddInfoSeparator;
    AddInfoSpacing(10);
    AddInfoText(LocalizedColorText('FormInfo.SearchInfo4'),taxCenter,NormalFontName);
    AddInfoText(' .',taxCenter,'');
    FinishInfoLayout;
  end;
end;
{ @end $5A9C70 }

{ @routine $5AA294 TfInfo_NextSearchPageClicked }
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
{ @end $5AA294 }

{ @routine $5AA474 TfInfo_BindFilterLabels }
procedure TfInfo.BindFilterLabels(Parent: TObjectGI);
var Child, Caption: TObjectGI; Button: TGraphButtonGI; Y, X: Integer;
begin
  Child := Parent.FirstChild;
  while Child <> nil do
  begin
    if Child is TGraphButtonGI then
    begin
      Button := Child as TGraphButtonGI;
      if (Button.ImageNormal <> nil) and (FindTextOffsetW(Button.ImageNormal.GetImagePath,'Check') >= 0) then
      begin
        X := Button.LocalPosition.X + Button.ClientSize.X + GiScalePixels(20);
        Y := Button.ClientSize.Y div 2 + Button.LocalPosition.Y;
        Caption := Parent.FirstChild;
        while Caption <> nil do
        begin
          if (Caption <> Child) and (Caption is TLabelGI) and
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
      end;
    end;
    BindFilterLabels(Child);
    Child := Child.NextSibling;
  end;
end;
{ @end $5AA474 }

{ @routine $5AA660 TfInfo_FilterLabelMouseEnter }
procedure TfInfo.FilterLabelMouseEnter(Sender: TObjectGI);
begin
  with TGraphButtonGI(Sender.UserValue) do SetHovered(True);
end;
{ @end $5AA660 }

{ @routine $5AA688 TfInfo_FilterLabelMouseLeave }
procedure TfInfo.FilterLabelMouseLeave(Sender: TObjectGI);
begin
  with TGraphButtonGI(Sender.UserValue) do SetHovered(False);
end;
{ @end $5AA688 }

{ @routine $5AA6B0 TfInfo_FilterLabelMouseDown }
procedure TfInfo.FilterLabelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
end;
{ @end $5AA6B0 }

{ @routine $5AA6D4 TfInfo_FilterLabelMouseUp }
procedure TfInfo.FilterLabelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  with TGraphButtonGI(Sender.UserValue) do SetDown(not Down);
end;
{ @end $5AA6D4 }

{ @routine $5AA718 TfInfo_ClearSearchText }
procedure TfInfo.ClearSearchText(Sender: TObjectGI);
begin
  with GetByName('TextSearch') as TEditGI do SetText('');
end;
{ @end $5AA718 }

{ @routine $5AA76C TfInfo_CopySearchText }
procedure TfInfo.CopySearchText(Sender: TObjectGI);
begin
  with GetByName('TextSearch') as TEditGI do SetClipboardWideText(Text);
end;
{ @end $5AA76C }

{ @routine $5AA7C4 TfInfo_PasteSearchText }
procedure TfInfo.PasteSearchText(Sender: TObjectGI);
begin
  with GetByName('TextSearch') as TEditGI do SetText(GetClipboardWideText);
end;
{ @end $5AA7C4 }

{ @routine $5AA850 TfInfo_ClearSearch12Name }
procedure TfInfo.ClearSearch12Name(Sender: TObjectGI);
begin
  with GetByName('M12Name') as TEditGI do SetText('');
end;
{ @end $5AA850 }

{ @routine $5AA89C TfInfo_CopySearch12Name }
procedure TfInfo.CopySearch12Name(Sender: TObjectGI);
begin
  with GetByName('M12Name') as TEditGI do SetClipboardWideText(Text);
end;
{ @end $5AA89C }

{ @routine $5AA8EC TfInfo_PasteSearch12Name }
procedure TfInfo.PasteSearch12Name(Sender: TObjectGI);
begin
  with GetByName('M12Name') as TEditGI do SetText(GetClipboardWideText);
end;
{ @end $5AA8EC }

{ @routine $5AA970 TfInfo_ClearSearch15Name }
procedure TfInfo.ClearSearch15Name(Sender: TObjectGI);
begin
  with GetByName('M15Name') as TEditGI do SetText('');
end;
{ @end $5AA970 }

{ @routine $5AA9BC TfInfo_CopySearch15Name }
procedure TfInfo.CopySearch15Name(Sender: TObjectGI);
begin
  with GetByName('M15Name') as TEditGI do SetClipboardWideText(Text);
end;
{ @end $5AA9BC }

{ @routine $5AAA0C TfInfo_PasteSearch15Name }
procedure TfInfo.PasteSearch15Name(Sender: TObjectGI);
begin
  with GetByName('M15Name') as TEditGI do SetText(GetClipboardWideText);
end;
{ @end $5AAA0C }

{ @routine $5AAA90 TfInfo_ClearSearchField }
procedure TfInfo.ClearSearchField(Name: WideString);
begin
  (GetByName(Name) as TEditGI).SetText('');
end;
{ @end $5AAA90 }

{ @routine $5AAAF0 TfInfo_ClearSearch01Filters }
procedure TfInfo.ClearSearch01Filters(Sender: TObjectGI);
begin
  ClearSearchField('M01Speed');
  ClearSearchField('M01Range');
  ClearSearchField('M01Size');
  ClearSearchField('M01Cost');
end;
{ @end $5AAAF0 }

{ @routine $5AAB8C TfInfo_ClearSearch02Filters }
procedure TfInfo.ClearSearch02Filters(Sender: TObjectGI);
begin
  ClearSearchField('M02Capacity');
  ClearSearchField('M02Size');
  ClearSearchField('M02Cost');
end;
{ @end $5AAB8C }

{ @routine $5AAC08 TfInfo_ClearSearch03Filters }
procedure TfInfo.ClearSearch03Filters(Sender: TObjectGI);
begin
  ClearSearchField('M03Range');
  ClearSearchField('M03Size');
  ClearSearchField('M03Cost');
end;
{ @end $5AAC08 }

{ @routine $5AAC80 TfInfo_ClearSearch04Filters }
procedure TfInfo.ClearSearch04Filters(Sender: TObjectGI);
begin
  ClearSearchField('M04Power');
  ClearSearchField('M04Size');
  ClearSearchField('M04Cost');
end;
{ @end $5AAC80 }

{ @routine $5AACF8 TfInfo_ClearSearch05Filters }
procedure TfInfo.ClearSearch05Filters(Sender: TObjectGI);
begin
  ClearSearchField('M05Power');
  ClearSearchField('M05Size');
  ClearSearchField('M05Cost');
end;
{ @end $5AACF8 }

{ @routine $5AAD70 TfInfo_ClearSearch06Filters }
procedure TfInfo.ClearSearch06Filters(Sender: TObjectGI);
begin
  ClearSearchField('M06ObjSize');
  ClearSearchField('M06Size');
  ClearSearchField('M06Cost');
end;
{ @end $5AAD70 }

{ @routine $5AADEC TfInfo_ClearSearch07Filters }
procedure TfInfo.ClearSearch07Filters(Sender: TObjectGI);
begin
  ClearSearchField('M07Block');
  ClearSearchField('M07Size');
  ClearSearchField('M07Cost');
end;
{ @end $5AADEC }

{ @routine $5AAE64 TfInfo_ClearSearch09Filters }
procedure TfInfo.ClearSearch09Filters(Sender: TObjectGI);
begin
  ClearSearchField('M09Const');
  ClearSearchField('M09Star');
  ClearSearchField('M09Range');
end;
{ @end $5AAE64 }

{ @routine $5AAEE0 TfInfo_ClearSearch10Filters }
procedure TfInfo.ClearSearch10Filters(Sender: TObjectGI);
begin
  ClearSearchField('M10Const');
  ClearSearchField('M10Star');
  ClearSearchField('M10Range');
end;
{ @end $5AAEE0 }

{ @routine $5AAF5C TfInfo_ClearSearch11Filters }
procedure TfInfo.ClearSearch11Filters(Sender: TObjectGI);
begin
  ClearSearchField('M11Size');
  ClearSearchField('M11Def');
  ClearSearchField('M11Cost');
end;
{ @end $5AAF5C }

{ @routine $5AAFD0 TfInfo_ClearSearch12Filters }
procedure TfInfo.ClearSearch12Filters(Sender: TObjectGI);
begin
  ClearSearchField('M12DamageMin');
  ClearSearchField('M12DamageMax');
  ClearSearchField('M12Range');
  ClearSearchField('M12Name');
  ClearSearchField('M12Size');
  ClearSearchField('M12Cost');
end;
{ @end $5AAFD0 }

{ @routine $5AB0C4 TfInfo_ClearSearch13Filters }
procedure TfInfo.ClearSearch13Filters(Sender: TObjectGI);
begin
  ClearSearchField('M13Range');
  ClearSearchField('M13PriceSell');
  ClearSearchField('M13Cnt');
  ClearSearchField('M13PriceBuy');
end;
{ @end $5AB0C4 }

{ @routine $5AB170 TfInfo_ClearSearch15Filters }
procedure TfInfo.ClearSearch15Filters(Sender: TObjectGI);
begin
  ClearSearchField('M15Const');
  ClearSearchField('M15Star');
  ClearSearchField('M15Name');
end;
{ @end $5AB170 }

{ @routine $5AB1E8 TfInfo_GetSearchResultLimit }
function TfInfo.GetSearchResultLimit: Integer;
begin
  if (GetPlayer <> nil) and (GetPlayer.DockedTo <> nil) and (GetPlayer.DockedTo.TypeId = Byte(rstRangerCenter)) then Result := MaxSearchResult
  else Result := 30;
end;
{ @end $5AB1E8 }

{ @routine $5AB230 TfInfo_ExecuteUiCode }
procedure TfInfo.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not MainPanel.NavigationLocked and not ExitScreenLoop and
    (TurnCalculationPhase in [tcpIdle,tcpGalaxyFinished,tcpPlayerStarFinished,tcpPlayerStarPrepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10010);
    ExecuteGameplayUiCode(Block,Key);
    Galaxy.PrimeIntegrityChecksum(20010);
  end;
end;
{ @end $5AB230 }

end.
