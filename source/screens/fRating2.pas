unit fRating2;

interface

uses GI_MessageLoop, GI_PanelScrollBar, GI_Window, Types, aRanger, fPanelMain;

type
  TRangerRatingSortColumn = (rrscName=1, rrscExperience=2, rrscRace=3,
    rrscRank=4, rrscCharacter=5); // @size 0x4

  TRangerRatingRow = packed record // @size 0x0C
    Ranger: TRanger; // @offset 0x00  Borrowed.
    Top: Integer; // @offset 0x04
    Height: Integer; // @offset 0x08
  end;
  TRangerRatingRows = array of TRangerRatingRow;

  TfRating2 = class(TMessageLoopGIWithMainPanel) // @size 0x108
  public
    RewardWindow: TWindowGI; // @offset 0xD4
    Rows: array of TRangerRatingRow; // @offset 0xD8
    SelectedIndex: Integer; // @offset 0xDC  -1 means no selection.
    SelectedRangerId: Cardinal; // @offset 0xE0
    SortColumn: TRangerRatingSortColumn; // @offset 0xE4
    SortAscending: Boolean; // @offset 0xE8
    TablePanel: TPanelScrollBarGI; // @offset 0xEC
    SelectedRowRect: TRect; // @offset 0xF0
    BackgroundClickStarted: Boolean; // @offset 0x100
    HoveredAwardId: Integer; // @offset 0x104  -1 means no award hint.

    constructor Create; // @addr 0x005D1C08
    destructor Destroy; override; // @addr 0x005D1C40
    procedure OnOpen; override; // @addr 0x005D1EA4 @slot 0x1C
    procedure OnClose; override; // @addr 0x005D21B4 @slot 0x20
    procedure ProcessCallbackTimers; override; // @addr 0x005D8058 @slot 0x24
    procedure SelectMusic; override; // @addr 0x005D7D20 @slot 0x28
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x005D24D0 @slot 0x2C
    procedure InitializeLayout; override; // @addr 0x005D1C68 @slot 0x30
    procedure CloseClicked(Sender: TObjectGI); // @addr 0x005D2200
    procedure KeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x005D220C
    procedure BackgroundMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005D237C
    procedure BackgroundMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005D2424
    procedure AwardsMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005D2528
    procedure AwardsMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005D25D8
    procedure HintMouseLeave(Sender: TObjectGI); // @addr 0x005D26B0
    procedure ShowPartnershipHint(Sender: TObjectGI); // @addr 0x005D2A54
    procedure ShowCareerHint(Sender: TObjectGI); // @addr 0x005D3828
    procedure ShowAwardHint(Ranger: TRanger; AwardId: Integer); // @addr 0x005D3E74
    procedure HideHint; // @addr 0x005D4230
    function FindRowByRangerId(RangerId: Cardinal): Integer; // @addr 0x005D4248 @note "Returns -1 if the ranger is absent."
    procedure SortHeaderMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005D4280
    procedure FeaturedRangerClicked(Sender: TObjectGI); // @addr 0x005D430C
    procedure RowMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005D433C
    procedure SelectRow(Index: Integer); // @addr 0x005D43D0 @note "Accepts -1; other indices must be valid. Rebuilds the old and new rows because selection changes row height."
    procedure ClearRows; // @addr 0x005D449C
    procedure RebuildTable; // @addr 0x005D452C @note "Excludes ExcludedFromRating rangers; preserves selection by ID when SelectedIndex is -1."
    procedure RebuildRow(Index: Integer); // @addr 0x005D4CF0
    procedure CreateRow(Index: Integer); // @addr 0x005D548C
    procedure RowMouseEnter(Sender: TObjectGI); // @addr 0x005D7248
    procedure RowMouseLeave(Sender: TObjectGI); // @addr 0x005D736C
    procedure RefreshFeaturedRangers; // @addr 0x005D7490
    procedure ShowDominatorKillsHint(Sender: TObjectGI); // @addr 0x005D81B4 @note "Only displays a hint for the player."
  end;

function ShowRangerRating(Parent: TMessageLoopGI): Boolean; // @addr 0x005D8084 @note "Runs the registered rating screen modally; true for normal close."

const
  CareerHintColumns: array[1..3] of Integer = (10,75,105); // @addr $80F55C @indexrefs "0x005D37EC"
  DominatorHintColumns: array[1..3] of Integer = (10,75,95); // @addr $80F568

implementation

uses aGalaxyStruct, GI_Panel, GR_GraphBuf, aPirate, GI_GAI, GI_Label, fShip2, aMyFunction, Math, Windows, SysUtils, Classes, EC_Str, EC_Struct, GI_GI, GI_Image,
  GI_GraphBuf, GI_GraphButton, GI_Main, GR_Main, GR_Music, Globals, GlobalsV,
  aConst, aGalaxy, aPlanet, aPlayer, aShip, aItem, fRewards, fStarMap;

{ @routine $5D1C08 TfRating2_Create }
constructor TfRating2.Create;
begin
  inherited Create;
end;
{ @end $5D1C08 }

{ @routine $5D1C40 TfRating2_Destroy }
destructor TfRating2.Destroy;
begin
  inherited Destroy;
end;
{ @end $5D1C40 }

{ @routine $5D1C68 TfRating2_InitializeLayout }
procedure TfRating2.InitializeLayout;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('ButClose').Parent do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
  end;
  RewardWindow := GetByName('RewardWnd') as TWindowGI;
  (GetByName('ButClose') as TGraphButtonGI).UpCallback := CloseClicked;
  GetByName('MainPanel').KeyDownCallback := KeyDown;
  GetByName('MainPanel').LeftButtonDownCallback := BackgroundMouseDown;
  GetByName('MainPanel').LeftButtonUpCallback := BackgroundMouseUp;
  TablePanel := GetByName('PTable') as TPanelScrollBarGI;
  TablePanel.VerticalScrollBar.SetPageSize(TablePanel.ClientSize.Y);
  TablePanel.VerticalScrollBar.SetLargeChange(TablePanel.ClientSize.Y);
end;
{ @end $5D1C68 }

{ @routine $5D1EA4 TfRating2_OnOpen }
procedure TfRating2.OnOpen;
begin
  inherited OnOpen;
  if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True,0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm,nil,nil,0);
  MainPanel.OnOpen;
  (GetByName('PM_Ship') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Gal') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Quest') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_EndTurn') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Logo') as TGraphButtonGI).SetHitTestDisabled(True);
  BackgroundClickStarted := True;
  SortColumn := rrscExperience;
  SelectedIndex := -1;
  SelectedRangerId := GetPlayer.Id;
  with GetByName('SortName') do
  begin
    LeftButtonUpCallback := SortHeaderMouseUp;
    UserValue := 1;
  end;
  with GetByName('SortCharacter') do UserValue := 5;
  with GetByName('SortRace') do
  begin
    LeftButtonUpCallback := SortHeaderMouseUp;
    UserValue := 3;
  end;
  with GetByName('SortRank') do
  begin
    LeftButtonUpCallback := SortHeaderMouseUp;
    UserValue := 4;
  end;
  with GetByName('SortScore') do
  begin
    LeftButtonUpCallback := SortHeaderMouseUp;
    UserValue := 2;
  end;
  HideHint;
  RefreshFeaturedRangers;
  RebuildTable;
  Galaxy.PrimeIntegrityChecksum(1113);
  MainPanel.RebuildMessageButtons(False);
end;
{ @end $5D1EA4 }

{ @routine $5D21B4 TfRating2_OnClose }
procedure TfRating2.OnClose;
begin
  inherited OnClose;
  Galaxy.CheckIntegrityChecksum(1114);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm,nil,nil,0);
  ClearRows;
  MainPanel.OnClose;
end;
{ @end $5D21B4 }

{ @routine $5D2200 TfRating2_CloseClicked }
procedure TfRating2.CloseClicked(Sender: TObjectGI);
begin
  RequestClose(1);
end;
{ @end $5D2200 }

{ @routine $5D220C TfRating2_KeyDown }
procedure TfRating2.KeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if Key = Ord('R') then CloseClicked(nil)
  else if (Key = VK_UP) or (Key = VK_LEFT) then
  begin
    if SelectedIndex > 0 then SelectRow(SelectedIndex - 1);
  end
  else if (Key = VK_DOWN) or (Key = VK_RIGHT) then
  begin
    if SelectedIndex < High(Rows) then SelectRow(SelectedIndex + 1);
  end
  else if Key = VK_HOME then SelectRow(0)
  else if Key = VK_END then SelectRow(High(Rows))
  else if Key = VK_PRIOR then TablePanel.VerticalScrollBar.SetPosition(TablePanel.VerticalScrollBar.Position - TablePanel.VerticalScrollBar.LargeChange)
  else if Key = VK_NEXT then TablePanel.VerticalScrollBar.SetPosition(TablePanel.VerticalScrollBar.Position + TablePanel.VerticalScrollBar.LargeChange)
  else if Key = VK_ESCAPE then RequestClose(1)
  else if Key = VK_F11 then
    if not MainPanel.RemoveDismissibleMessages('GOODS') then MainPanel.RemoveDismissibleMessages('');
end;
{ @end $5D220C }

{ @routine $5D237C TfRating2_BackgroundMouseDown }
procedure TfRating2.BackgroundMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if ClickAutoCloseForm then
  begin
    BackgroundClickStarted := False;
    if not (GetByName('ImagePanel') as TImageGI).ContainsPoint(Point) and
      not GetByName('PM_PanelMsg').ContainsPoint(Point) then BackgroundClickStarted := True;
  end;
end;
{ @end $5D237C }

{ @routine $5D2424 TfRating2_BackgroundMouseUp }
procedure TfRating2.BackgroundMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if ClickAutoCloseForm then
    if not (GetByName('ImagePanel') as TImageGI).ContainsPoint(Point) and
      not GetByName('PM_PanelMsg').ContainsPoint(Point) and BackgroundClickStarted then CloseClicked(nil);
end;
{ @end $5D2424 }

{ @routine $5D24D0 TfRating2_ProcessMouseWheel }
procedure TfRating2.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then TablePanel.VerticalScrollBar.SetPosition(TablePanel.VerticalScrollBar.Position - TablePanel.VerticalScrollBar.SmallChange)
  else if Delta = -WHEEL_DELTA then TablePanel.VerticalScrollBar.SetPosition(TablePanel.VerticalScrollBar.Position + TablePanel.VerticalScrollBar.SmallChange);
end;
{ @end $5D24D0 }

{ @routine $5D2528 TfRating2_AwardsMouseDown }
procedure TfRating2.AwardsMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if not AwardDialogsEnabled then Exit;
  RewardWindow.SetActive(False);
  AwardSubject := Galaxy.IdToShip(Sender.UserValue,True);
  if AwardSubject <> nil then
  begin
    Galaxy.CheckIntegrityChecksum(335);
    if not RunRewards(Self,True) then
    begin
      Galaxy.PrimeIntegrityChecksum(336);
      RequestClose(2);
    end
    else Galaxy.PrimeIntegrityChecksum(336);
  end;
end;
{ @end $5D2528 }

{ @routine $5D25D8 TfRating2_AwardsMouseMove }
procedure TfRating2.AwardsMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Size, Step: Integer; Ranger: TRanger; Index: Integer; AwardId: Byte;
begin
  Size := GiScalePixels(20);
  Step := Size div 2;
  Ranger := Rows[Sender.UserState].Ranger;
  Index := Max(0,Ranger.AwardIds.Count - 8) + Sender.ToLocalPoint(Point).X div Step;
  if Sender.ToLocalPoint(Point).Y < Sender.ClientSize.Y - Size then HideHint
  else
  begin
    if Index >= Ranger.AwardIds.Count then Index := Ranger.AwardIds.Count - 1;
    AwardId := Byte(Ranger.AwardIds[Index]);
    ShowAwardHint(Ranger,AwardId);
  end;
end;
{ @end $5D25D8 }

{ @routine $5D26B0 TfRating2_HintMouseLeave }
procedure TfRating2.HintMouseLeave(Sender: TObjectGI);
begin
  HideHint;
end;
{ @end $5D26B0 }

{ @routine $5D2A54 TfRating2_ShowPartnershipHint }
procedure TfRating2.ShowPartnershipHint(Sender: TObjectGI);
var Cursor: TPoint; I: Integer; CaptionText, PartnerInfo, Names: WideString;
  Ally: TRanger; Pirate: TPirate;

  // @nested $5D26B8 FormatRangerWingmenHint
  function FormatRangerWingmenHint(Ranger: TRanger): WideString; // @addr 0x005D26B8 @calls "0x005D3112,0x005D323D" @note "Nested in TfRating2.ShowPartnershipHint; caller supplies its parent frame."
  var I: Integer; Names: WideString; Ally: TRanger;
  begin
    if Ranger.CountWingmen = 1 then
    begin
      for I := 0 to Galaxy.Rangers.Count - 1 do
      begin
        Ally := Galaxy.Rangers[I];
        if (GetPlayer <> Ally) and (Ally.PartnerShip = Ranger) then
          Result := FormatText2(LocalizedColorText('FormRating.PartnerBossOneText'),TextHighlightColorTag,'<Name>',Ally.GetName,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + Ally.PartnershipDaysRemaining));
      end;
    end
    else
    begin
      Names := '';
      for I := 0 to Galaxy.Rangers.Count - 1 do
      begin
        Ally := Galaxy.Rangers[I];
        if (GetPlayer <> Ally) and (Ally.PartnerShip = Ranger) then
        begin
          if Names <> '' then Names := Names + ', ' + FormatText2(LocalizedColorText('FormRating.AddInfoAboutPartner'),TextHighlightColorTag,'<Name>',Ally.GetName,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + Ally.PartnershipDaysRemaining))
          else Names := FormatText2(LocalizedColorText('FormRating.AddInfoAboutPartner'),TextHighlightColorTag,'<Name>',Ally.GetName,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + Ally.PartnershipDaysRemaining));
        end;
      end;
      Result := FormatText1(LocalizedColorText('FormRating.PartnerBossManyText'),'','<Names>',Names);
    end;
  end;
begin
  RewardWindow.SetActive(True);
  if Rows[Sender.UserValue].Ranger = GetPlayer then
  begin
    with GetByName('RewardName') as TLabelGI do
      Text := FormatText1(LocalizedColorText('FormRating.PlayerName'),TextHighlightColorTag,'<Name>',GetPlayer.GetName);
    if GetPlayer.CountWingmen > 0 then
    begin
      Names := '';
      for I := 0 to Galaxy.Rangers.Count - 1 do
      begin
        Ally := Galaxy.Rangers[I];
        if (GetPlayer <> Ally) and (GetPlayer = Ally.PartnerShip) then
        begin
          if Names <> '' then Names := Names + ', ' + FormatText2(LocalizedColorText('FormRating.AddInfoAboutPartner'),TextHighlightColorTag,'<Name>',Ally.GetName,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + Ally.PartnershipDaysRemaining))
          else Names := FormatText2(LocalizedColorText('FormRating.AddInfoAboutPartner'),TextHighlightColorTag,'<Name>',Ally.GetName,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + Ally.PartnershipDaysRemaining));
        end;
      end;
      for I := 0 to GetPlayer.PiratePartners.Count - 1 do
      begin
        Pirate := GetPlayer.PiratePartners[I];
        if Names <> '' then Names := Names + ', ' + FormatText2(LocalizedColorText('FormRating.AddInfoAboutPirate'),TextHighlightColorTag,'<Name>',Pirate.GetName,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + Pirate.PartnershipDaysRemaining))
        else Names := FormatText2(LocalizedColorText('FormRating.AddInfoAboutPirate'),TextHighlightColorTag,'<Name>',Pirate.GetName,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + Pirate.PartnershipDaysRemaining));
      end;
      PartnerInfo := FormatText1(LocalizedColorText('FormRating.PlayerPartnerOk'),'','<Names>',Names);
    end
    else PartnerInfo := LocalizedColorText('FormRating.PlayerPartnerNo');
    CaptionText := LocalizedColorText('FormRating.PlayerText');
    ReplaceTextToken(CaptionText,'<PartnerInfo>',PartnerInfo,'');
    with GetByName('RewardText') as TLabelGI do Text := CaptionText;
    with GetByName('RewardImage') as TGraphBufGI do
      LoadGiByPathIntoGraphBuf('Bm.FormRating2.' + GiResourceSuffix + 'PlayerB',GraphBuf);
  end
  else if Rows[Sender.UserValue].Ranger.IsInPrison then
  begin
    with GetByName('RewardName') as TLabelGI do
      Text := FormatText1(LocalizedColorText('FormRating.InPrisonName'),TextHighlightColorTag,'<Name>',Rows[Sender.UserValue].Ranger.GetName);
    if Rows[Sender.UserValue].Ranger.CurrentPlanet <> nil then
      CaptionText := FormatText1(LocalizedColorText('FormRating.InPrisonText'),TextHighlightColorTag,'<Planet>',Rows[Sender.UserValue].Ranger.CurrentPlanet.Name)
    else CaptionText := '';
    with GetByName('RewardText') as TLabelGI do Text := CaptionText;
    with GetByName('RewardImage') as TGraphBufGI do
      LoadGiByPathIntoGraphBuf('Bm.FormRating2.' + GiResourceSuffix + 'PrisonB',GraphBuf);
  end
  else if Rows[Sender.UserValue].Ranger.PartnerShip <> nil then
  begin
    with GetByName('RewardName') as TLabelGI do
      Text := FormatText1(LocalizedColorText('FormRating.PartnerName'),TextHighlightColorTag,'<Name>',Rows[Sender.UserValue].Ranger.GetName);
    CaptionText := LocalizedColorText('FormRating.PartnerText');
    ReplaceTextToken(CaptionText,'<Name>',Rows[Sender.UserValue].Ranger.PartnerShip.GetName,TextHighlightColorTag);
    ReplaceTextToken(CaptionText,'<Date>',Galaxy.FormatTurnDate(Galaxy.CurrentTurn + Rows[Sender.UserValue].Ranger.PartnershipDaysRemaining),TextHighlightColorTag);
    if Rows[Sender.UserValue].Ranger.PartnershipDaysRemaining = 0 then
      CaptionText := CaptionText + ' ' + LocalizedColorText('FormRating.PartnerTextDateEnd');
    if Rows[Sender.UserValue].Ranger.CountWingmen > 0 then
      CaptionText := CaptionText + #13#10 + FormatRangerWingmenHint(Rows[Sender.UserValue].Ranger);
    with GetByName('RewardText') as TLabelGI do Text := CaptionText;
    with GetByName('RewardImage') as TGraphBufGI do
      LoadGiByPathIntoGraphBuf('Bm.FormRating2.' + GiResourceSuffix + 'DutyB',GraphBuf);
  end
  else if Rows[Sender.UserValue].Ranger.CountWingmen > 0 then
  begin
    with GetByName('RewardName') as TLabelGI do
      Text := FormatText1(LocalizedColorText('FormRating.PartnerName'),TextHighlightColorTag,'<Name>',Rows[Sender.UserValue].Ranger.GetName);
    CaptionText := FormatRangerWingmenHint(Rows[Sender.UserValue].Ranger);
    with GetByName('RewardText') as TLabelGI do Text := CaptionText;
    with GetByName('RewardImage') as TGraphBufGI do
      LoadGiByPathIntoGraphBuf('Bm.FormRating2.' + GiResourceSuffix + 'DutyB',GraphBuf);
  end;
  with GetByName('RewardImage') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  ShipScreen.LayoutItemInfo(RewardWindow,GetByName('RewardName') as TLabelGI,GetByName('RewardText') as TLabelGI,True,True,0);
  with GetByName('RewardName') as TLabelGI do
    SetSize(Classes.Point(Self.RewardWindow.ClientSize.X - LocalPosition.X - Self.RewardWindow.WorkSubRect.Right,ClientSize.Y));
  Cursor := GetCursorPoint;
  RewardWindow.SetPosition(Classes.Point(Cursor.X + 100,Max(0,Cursor.Y - RewardWindow.ClientSize.Y - 20)));
end;
{ @end $5D2A54 }

{ @routine $5D3828 TfRating2_ShowCareerHint }
procedure TfRating2.ShowCareerHint(Sender: TObjectGI);
var Career: TRangerCareer; Cursor: TPoint; CaptionText: WideString; Ranger: TRanger;
  // @nested $5D37D0 FormatCareerHintColumn
  function FormatCareerHintColumn(Column: Integer): WideString; // @addr 0x005D37D0 @calls "0x005D39CA,0x005D3A16,0x005D3A4D,0x005D3A62" @note "Nested in TfRating2.ShowCareerHint; caller supplies its parent frame."
  begin
    Result := IntToStr(CareerHintColumns[Column] + 40);
  end;
begin
  RewardWindow.SetActive(True);
  Ranger := Rows[Sender.UserValue].Ranger;
  if GetPlayer = Ranger then
  begin
    with GetByName('RewardName') as TLabelGI do
      Text := FormatText1(LocalizedColorText('FormRating.PlayerName'),TextHighlightColorTag,'<Name>',Ranger.GetName);
    with GetByName('RewardImage') as TGraphBufGI do
      LoadGiByPathIntoGraphBuf('Bm.FormRating2.' + GiResourceSuffix + 'PlayerB',GraphBuf);
  end
  else
  begin
    with GetByName('RewardName') as TLabelGI do
      Text := FormatText1(LocalizedColorText('FormRating.PartnerName'),TextHighlightColorTag,'<Name>',Ranger.GetName);
    with GetByName('RewardImage') as TGraphBufGI do
      LoadGiByPathIntoGraphBuf('Bm.FormRating2.' + GiResourceSuffix + 'DutyB',GraphBuf);
  end;
  CaptionText := '<td=' + FormatCareerHintColumn(1) + '><align=left>' + LocalizedColorText('FormRating.Rating.Title') + '</align>' + #13#10;
  for Career := Low(TRangerCareer) to High(TRangerCareer) do
    CaptionText := CaptionText + '<td=' + FormatCareerHintColumn(1) + '><align=left>' + LocalizedColorText('FormRating.Rating.' + CareerTuning[Career].Name) +
      '<td=' + FormatCareerHintColumn(2) + '>:</align><td=' + FormatCareerHintColumn(3) + '><align=right>' +
      WrapTextInColor(IntToStr(Ranger.CareerStatus[Career]) ,TextHighlightColorTag) + '</align>' + #13#10;
  with GetByName('RewardText') as TLabelGI do Text := CaptionText;
  with GetByName('RewardImage') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  ShipScreen.LayoutItemInfo(RewardWindow,GetByName('RewardName') as TLabelGI,GetByName('RewardText') as TLabelGI,True,True,0);
  with GetByName('RewardText') as TLabelGI do SetTextAlignX(taxLeft);
  with GetByName('RewardName') as TLabelGI do
    SetSize(Classes.Point(Self.RewardWindow.ClientSize.X - LocalPosition.X - Self.RewardWindow.WorkSubRect.Right,ClientSize.Y));
  Cursor := GetCursorPoint;
  RewardWindow.SetPosition(Classes.Point(Cursor.X + 100,Max(0,Cursor.Y - RewardWindow.ClientSize.Y - 20)));
end;
{ @end $5D3828 }

{ @routine $5D3E74 TfRating2_ShowAwardHint }
procedure TfRating2.ShowAwardHint(Ranger: TRanger; AwardId: Integer);
var Cursor: TPoint; Path: WideString;
begin
  if HoveredAwardId = AwardId then Exit;
  HoveredAwardId := AwardId;
  RewardWindow.SetActive(True);
  Cursor := GetCursorPoint;
  RewardWindow.SetPosition(Classes.Point(Cursor.X + 100,Max(0,Cursor.Y - RewardWindow.ClientSize.Y - 20)));
  if AwardId < 10 then Path := 'Bm.FormRewards.' + GiResourceSuffix + '_0' + IntToStr(AwardId)
  else Path := 'Bm.FormRewards.' + GiResourceSuffix + '_' + IntToStr(AwardId);
  with GetByName('RewardImage') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    LoadGiByPathIntoGraphBuf(Path,GraphBuf);
    if GraphBuf.Width >= GraphBuf.Height then
      GraphBuf.RescaleRgba(ClientSize.X,Round(ClientSize.X / GraphBuf.Width * GraphBuf.Height),5)
    else
      GraphBuf.RescaleRgba(Round(ClientSize.Y / GraphBuf.Height * GraphBuf.Width),ClientSize.Y,5);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  with GetByName('RewardName') as TLabelGI do Text := Ranger.GetAwardInfo(AwardId).Name;
  with GetByName('RewardText') as TLabelGI do Text := Ranger.GetAwardInfo(AwardId).Text;
  ShipScreen.LayoutItemInfo(RewardWindow,GetByName('RewardName') as TLabelGI,GetByName('RewardText') as TLabelGI,True,True,0);
  with GetByName('RewardName') as TLabelGI do
    SetSize(Classes.Point(Self.RewardWindow.ClientSize.X - LocalPosition.X - Self.RewardWindow.WorkSubRect.Right,ClientSize.Y));
end;
{ @end $5D3E74 }

{ @routine $5D4230 TfRating2_HideHint }
procedure TfRating2.HideHint;
begin
  HoveredAwardId := -1;
  RewardWindow.SetActive(False);
end;
{ @end $5D4230 }

{ @routine $5D4248 TfRating2_FindRowByRangerId }
function TfRating2.FindRowByRangerId(RangerId: Cardinal): Integer;
var I: Integer;
begin
  for I := 0 to High(Rows) do
    if Rows[I].Ranger.Id = RangerId then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;
{ @end $5D4248 }

{ @routine $5D4280 TfRating2_SortHeaderMouseUp }
procedure TfRating2.SortHeaderMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Column: TRangerRatingSortColumn;
begin
  if SelectedIndex >= 0 then
  begin
    SelectedRangerId := Rows[SelectedIndex].Ranger.Id;
    SelectedIndex := -1;
  end;
  Column := TRangerRatingSortColumn(Sender.UserValue);
  if Column = SortColumn then SortAscending := not SortAscending
  else
  begin
    SortColumn := Column;
    SortAscending := (SortColumn = rrscName) or (SortColumn = rrscRace);
  end;
  RebuildTable;
end;
{ @end $5D4280 }

{ @routine $5D430C TfRating2_FeaturedRangerClicked }
procedure TfRating2.FeaturedRangerClicked(Sender: TObjectGI);
begin
  SelectRow(-1);
  SelectRow(FindRowByRangerId(Sender.UserValue));
  PostMouseMoveMessage;
end;
{ @end $5D430C }

{ @routine $5D433C TfRating2_RowMouseDown }
procedure TfRating2.RowMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if not Sender.IsOccludedAtPoint(GetCursorPoint) then
  begin
    if SelectedIndex <> Integer(Sender.UserState) then
    begin
      SoundManager.PlaySound('Sound.ButtonClick');
      SelectRow(Sender.UserState);
    end;
    PostMouseMoveMessage;
    BreakUiMessage;
  end;
end;
{ @end $5D433C }

{ @routine $5D43D0 TfRating2_SelectRow }
procedure TfRating2.SelectRow(Index: Integer);
var Previous: Integer;
begin
  if SelectedIndex = Index then Exit;
  Galaxy.CheckIntegrityChecksum(1115);
  Previous := SelectedIndex;
  SelectedIndex := Index;
  if Previous >= 0 then RebuildRow(Previous);
  if SelectedIndex >= 0 then RebuildRow(SelectedIndex);
  if Index >= 0 then
  begin
    SelectedRowRect := Classes.Rect(0,Rows[Index].Top,1,Rows[Index].Top + Rows[Index].Height);
    TablePanel.ScrollRectIntoView(SelectedRowRect);
  end;
  HideHint;
  Galaxy.PrimeIntegrityChecksum(1116);
end;
{ @end $5D43D0 }

{ @routine $5D449C TfRating2_ClearRows }
procedure TfRating2.ClearRows;
begin
  TablePanel.FreeOwnedChildren;
  GetByName('MainPanel').Invalidate;
  Rows := nil;
  SelectedRowRect := Classes.Rect(0,0,1,1);
  TablePanel.VerticalScrollBar.SetSmallChange(TablePanel.VerticalScrollBar.LargeChange);
end;
{ @end $5D449C }

{ @routine $5D452C TfRating2_RebuildTable }
procedure TfRating2.RebuildTable;
// Compare the signed ordinal values used by the native sort.
var I, J, Top: Integer; List: TList; A, B: TRanger;
begin
  ClearRows;
  with GetByName('SortImage') as TImageGI do
  begin
    if Self.SortColumn = rrscName then SetPosition(Classes.Point(Self.GetByName('SortName').LocalPosition.X + Self.GetByName('SortName').ClientSize.X - ClientSize.X,LocalPosition.Y))
    else if Self.SortColumn = rrscExperience then SetPosition(Classes.Point(Self.GetByName('SortScore').LocalPosition.X + Self.GetByName('SortScore').ClientSize.X - ClientSize.X,LocalPosition.Y))
    else if Self.SortColumn = rrscRace then SetPosition(Classes.Point(Self.GetByName('SortRace').LocalPosition.X + Self.GetByName('SortRace').ClientSize.X - ClientSize.X,LocalPosition.Y))
    else if Self.SortColumn = rrscRank then SetPosition(Classes.Point(Self.GetByName('SortRank').LocalPosition.X + Self.GetByName('SortRank').ClientSize.X - ClientSize.X,LocalPosition.Y));
    if Self.SortAscending then ImageSourcePath := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'SortDown'
    else ImageSourcePath := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'SortUp';
  end;
  List := TList.Create;
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    A := Galaxy.Rangers[I];
    if not A.ExcludedFromRating then List.Add(A);
  end;
  for I := 0 to List.Count - 2 do
    for J := I + 1 to List.Count - 1 do
    begin
      A := List[I];
      B := List[J];
      if SortColumn = rrscName then
      begin
        if SortAscending then
        begin
          if CompareString(LOCALE_USER_DEFAULT,0,PChar(AnsiString(B.Name)),-1,PChar(AnsiString(A.Name)),-1) - 2 < 0 then List.Exchange(I,J);
        end
        else if CompareString(LOCALE_USER_DEFAULT,0,PChar(AnsiString(B.Name)),-1,PChar(AnsiString(A.Name)),-1) - 2 > 0 then List.Exchange(I,J);
      end
      else if SortColumn = rrscExperience then
      begin
        if SortAscending then
        begin
          if B.TotalExperience < A.TotalExperience then List.Exchange(I,J);
        end
        else if B.TotalExperience > A.TotalExperience then List.Exchange(I,J);
      end
      else if SortColumn = rrscRace then
      begin
        if SortAscending then
        begin
          if Ord(B.PilotRace) < Ord(A.PilotRace) then List.Exchange(I,J);
        end
        else if Ord(B.PilotRace) > Ord(A.PilotRace) then List.Exchange(I,J);
      end
      else if SortColumn = rrscRank then
      begin
        if SortAscending then
        begin
          if Ord(B.Rank) < Ord(A.Rank) then List.Exchange(I,J);
        end
        else if Ord(B.Rank) > Ord(A.Rank) then List.Exchange(I,J);
      end
      else if SortColumn = rrscCharacter then
      begin
        if SortAscending then
        begin
          if AnsiStrComp(PChar(AnsiString(B.GetCharacterName)),PChar(AnsiString(A.GetCharacterName))) < 0 then List.Exchange(I,J);
        end
        else if AnsiStrComp(PChar(AnsiString(B.GetCharacterName)),PChar(AnsiString(A.GetCharacterName))) > 0 then List.Exchange(I,J);
      end;
    end;
  Rows := nil;
  if List.Count > 0 then
  begin
    SetLength(Rows,List.Count);
    for I := 0 to List.Count - 1 do
    begin
      Rows[I].Ranger := List[I];
      Rows[I].Top := 0;
      Rows[I].Height := 0;
      if (SelectedIndex < 0) and (Rows[I].Ranger.Id = SelectedRangerId) then SelectedIndex := I;
    end;
  end;
  List.Free;
  Top := 0;
  for I := 0 to High(Rows) do
  begin
    Rows[I].Top := Top;
    CreateRow(I);
    Top := Top + Rows[I].Height;
  end;
  TablePanel.SetActive(True);
  TablePanel.UpdateScrollRanges;
  J := TablePanel.VerticalScrollBar.Position;
  TablePanel.VerticalScrollBar.SetPosition(J - 1);
  TablePanel.VerticalScrollBar.SetPosition(J);
  TablePanel.ScrollRectIntoView(SelectedRowRect);
end;
{ @end $5D452C }

{ @routine $5D4CF0 TfRating2_RebuildRow }
procedure TfRating2.RebuildRow(Index: Integer);
var Child, Previous: TObjectGI; I, Delta: Integer;
begin
  Child := TablePanel.FirstChild;
  while Child <> nil do
  begin
    Previous := Child;
    Child := Child.NextSibling;
    if Previous.UserState = Cardinal(Index) then Previous.Free;
  end;
  Delta := Rows[Index].Height;
  CreateRow(Index);
  Delta := Rows[Index].Height - Delta;
  for I := Index + 1 to High(Rows) do Inc(Rows[I].Top,Delta);
  Child := TablePanel.FirstChild;
  while Child <> nil do
  begin
    if Child.UserState > Cardinal(Index) then Child.SetPosition(Classes.Point(Child.LocalPosition.X,Child.LocalPosition.Y + Delta));
    Child := Child.NextSibling;
  end;
  TablePanel.UpdateScrollRanges;
  I := TablePanel.VerticalScrollBar.Position;
  TablePanel.VerticalScrollBar.SetPosition(I - 1);
  TablePanel.VerticalScrollBar.SetPosition(I);
end;
{ @end $5D4CF0 }

{ @routine $5D548C TfRating2_CreateRow }
procedure TfRating2.CreateRow(Index: Integer);
var Ranger: TRanger; Panel, BarPanel: TPanelGI; Image: TImageGI;
  Caption: TLabelGI; Ratio: Single; ExtraKills: Integer; Animation: TgaiGI;

  // @nested $5D4DF0 GetRatingRankImagePath
  function GetRatingRankImagePath(Rank: TShipRank): WideString; // @addr 0x005D4DF0 @calls "0x005D69C0" @note "Nested in TfRating2.CreateRow; caller supplies its parent frame."
  begin
    if Rank = 0 then Result := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank1'
    else if Rank = 1 then Result := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank2'
    else if Rank = 2 then Result := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank3'
    else if Rank = 3 then Result := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank4'
    else if Rank = 4 then Result := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank5'
    else if Rank = 5 then Result := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank6'
    else if Rank = 6 then Result := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank7'
    else if Rank = 7 then Result := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank8'
    else RaiseWideMessage('error');
  end;

  // @nested $5D5040 CreateRatingRowAwardStrip
  procedure CreateRatingRowAwardStrip; // @addr 0x005D5040 @calls "0x005D6730" @ida "void __cdecl $name(void *ParentFrame);" @stackpop 0 @note "Nested in TfRating2.CreateRow; requires its parent frame."
  var I, J: Integer; Buffer: TGraphBufGI; Icon: TGraphBufGR; Award: Byte;
    Path: WideString; Size, Step, Count: Integer;
  begin
    Count := 8;
    Size := GiScalePixels(20);
    Step := Size div 2;
    if (Ranger.AwardIds <> nil) and (Ranger.AwardIds.Count >= 1) then
    begin
      Buffer := TGraphBufGI.Create(Panel,False);
      Buffer.SetDepth(11);
      Buffer.SetImageKindX(ikxLeft);
      Buffer.SetImageKindY(ikyBottom);
      Buffer.SetPosition(Classes.Point(GiScalePixels(93),GiScalePixels(130)));
      Buffer.SetSize(Classes.Point(92,Size));
      Buffer.SetPositionModeW(True);
      Buffer.MouseMoveCallback := AwardsMouseMove;
      Buffer.MouseLeaveCallback := HintMouseLeave;
      Buffer.LeftButtonDownCallback := AwardsMouseDown;
      Buffer.UserValue := Ranger.Id;
      Buffer.GraphBuf.AllocateRgbaTight(Max(Buffer.ClientSize.X,Step * Count + Size - Step),Size);
      for I := 0 to Size - 1 do
        Buffer.GraphBuf.FillRect32(Classes.Rect(0,I,Buffer.GraphBuf.Width,I + 1),Integer(Round(I / Size * 240) + 10) shl 24 or (250 shl 16) or (250 shl 8) or 50);
      Buffer.SourceHasPerPixelAlpha := True;
      Buffer.UserState := Index;
      Icon := TGraphBufGR.Create(False);
      I := Max(0,Ranger.AwardIds.Count - Count);
      J := 0;
      while I < Ranger.AwardIds.Count do
      begin
        Award := Byte(Ranger.AwardIds[I]);
        if Award < 10 then Path := 'Bm.FormRewards.' + GiResourceSuffix + '_0' + IntToStr(Award)
        else Path := 'Bm.FormRewards.' + GiResourceSuffix + '_' + IntToStr(Award);
        LoadGiByPathIntoGraphBuf(Path,Icon);
        if Icon.Width >= Icon.Height then
          Icon.RescaleRgba(Size,Round(Size / Icon.Width * Icon.Height),5)
        else Icon.RescaleRgba(Round(Size / Icon.Height * Icon.Width),Size,5);
        if Integer(Icon.Height) <= Size then
          if Integer(Icon.Width) + J * Step <= Integer(Buffer.GraphBuf.Width) then
            Buffer.GraphBuf.BlendRect32(Classes.Point(J * Step,0),Icon,Classes.Rect(0,0,Icon.Width,Icon.Height));
        Inc(I);
        Inc(J);
      end;
      Icon.Free;
    end;
  end;

begin
  Ranger := Rows[Index].Ranger;
  Panel := TPanelGI.Create(TablePanel);
  Panel.UserState := Index;
  Panel.SetPosition(Classes.Point(0,Rows[Index].Top));
  Panel.SetPositionModeW(True);
  if SelectedIndex = Index then
  begin
    Image := TImageGI.Create(Panel);
    Image.UserState := Index;
    Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'Open' + OwnerInfo[RaceToOwner(Ranger.PilotRace)].InternalName);
    Image.SetSize(Image.GetContentSize);
    Image.SetPosition(Classes.Point(0,0));
    Image.SetDepth(11);
    Image.LeftButtonDownCallback := RowMouseDown;
    Panel.SetSize(Image.ClientSize);
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(414),GiScalePixelsEx(39,32)));
    Caption.SetSize(Classes.Point(GiScalePixels(150),GiScalePixels(30)));
    Caption.SetFontName(SmallFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(Ranger.GetRankName);
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(345),GiScalePixelsEx(62,49)));
    Caption.SetSize(Classes.Point(GiScalePixels(96),GiScalePixels(19)));
    Caption.SetFontName(SmallFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(LocalizedText('FormRating.Kill') + ':');
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(322),GiScalePixelsEx(77,63)));
    Caption.SetSize(Classes.Point(GiScalePixels(94),GiScalePixels(24)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(LocalizedText('FormRating.Dominator'));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption.UserValue := Index;
    Caption.MouseEnterCallback := ShowDominatorKillsHint;
    Caption.MouseLeaveCallback := HintMouseLeave;
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(419),GiScalePixelsEx(77,63)));
    Caption.SetSize(Classes.Point(GiScalePixels(69),GiScalePixels(24)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(LocalizedText('FormRating.Pirate'));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(490),GiScalePixelsEx(77,63)));
    Caption.SetSize(Classes.Point(GiScalePixels(69),GiScalePixels(24)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(LocalizedText('FormRating.Other'));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(557),GiScalePixelsEx(77,63)));
    Caption.SetSize(Classes.Point(GiScalePixels(74),GiScalePixels(24)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(LocalizedText('FormRating.KillAllShip'));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(321),GiScalePixelsEx(102,83)));
    Caption.SetSize(Classes.Point(GiScalePixels(94),GiScalePixels(22)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(IntToStr(Ranger.DominatorKillCount));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(418),GiScalePixelsEx(102,83)));
    Caption.SetSize(Classes.Point(GiScalePixels(69),GiScalePixels(22)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(IntToStr(Ranger.PirateKillCount));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(489),GiScalePixelsEx(102,83)));
    Caption.SetSize(Classes.Point(GiScalePixels(69),GiScalePixels(22)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption.SetText(IntToStr(Ranger.TotalShipKillCount - Ranger.PirateKillCount - Ranger.DominatorKillCount));
    ExtraKills := 0;
    if GetPlayer = Ranger then
    begin
      ExtraKills := (Ranger as TPlayer).HyperspaceKillCount + (Ranger as TPlayer).BlackHoleKillCount;
      Caption.SetText(Caption.GetText + '/' + IntToStr(ExtraKills));
    end;
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(556),GiScalePixelsEx(102,83)));
    Caption.SetSize(Classes.Point(GiScalePixels(74),GiScalePixels(22)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(IntToStr(Ranger.TotalShipKillCount + ExtraKills));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(321),GiScalePixelsEx(126,101)));
    Caption.SetSize(Classes.Point(GiScalePixels(300),GiScalePixels(22)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxCenter);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(LocalizedText('FormRating.LiberationSystem') + ': ' + IntToStr(Ranger.LiberatedSystemCount));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(208),GiScalePixels(61)));
    Caption.SetSize(Classes.Point(GiScalePixels(120),GiScalePixels(18)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxLeft);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(LocalizedText('FormRating.Strength'));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    Caption := TLabelGI.Create(Panel);
    Caption.SetPosition(Classes.Point(GiScalePixels(208),GiScalePixels(106)));
    Caption.SetSize(Classes.Point(GiScalePixels(120),GiScalePixels(18)));
    Caption.SetFontName(NormalFontName);
    Caption.SetWordWrapEnabled(False);
    Caption.SetTextAlignX(taxLeft);
    Caption.SetTextAlignY(tayCenterEx);
    Caption.SetText(LocalizedText('FormRating.Capital'));
    Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    BarPanel := TPanelGI.Create(Panel);
    BarPanel.SetPosition(Classes.Point(GiScalePixels(201),GiScalePixels(83)));
    if GiResourceVariant = 1 then BarPanel.SetSize(Classes.Point(82,10))
    else BarPanel.SetSize(Classes.Point(103,11));
    Image := TImageGI.Create(BarPanel);
    Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'BarFrame');
    Image.SetSize(Image.GetContentSize);
    Image.SetPosition(Classes.Point(0,0));
    Image.SetDepth(8);
    Image := TImageGI.Create(BarPanel);
    Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'Bar');
    Image.SetSize(Image.GetContentSize);
    Image.SetDepth(9);
    Ratio := Ranger.Strength / (TObject(Galaxy.FindStrongestRanger) as TRanger).Strength;
    if Ratio < 0 then Ratio := 0
    else if Ratio > 1 then Ratio := 1;
    Image.SetPosition(Classes.Point(1 - Round((1 - Ratio) * (Image.ClientSize.X div 2)),1));
    BarPanel := TPanelGI.Create(Panel);
    BarPanel.SetPosition(Classes.Point(GiScalePixels(201),GiScalePixels(128)));
    if GiResourceVariant = 1 then BarPanel.SetSize(Classes.Point(82,10))
    else BarPanel.SetSize(Classes.Point(103,11));
    Image := TImageGI.Create(BarPanel);
    Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'BarFrame');
    Image.SetSize(Image.GetContentSize);
    Image.SetPosition(Classes.Point(0,0));
    Image.SetDepth(8);
    Image := TImageGI.Create(BarPanel);
    Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'Bar');
    Image.SetSize(Image.GetContentSize);
    Image.SetDepth(9);
    Ratio := Ranger.Wealth / (TObject(Galaxy.FindWealthiestRanger) as TRanger).Wealth;
    if Ratio < 0 then Ratio := 0
    else if Ratio > 1 then Ratio := 1;
    Image.SetPosition(Classes.Point(1 - Round((1 - Ratio) * (Image.ClientSize.X div 2)),1));
    Image := TImageGI.Create(Panel);
    Image.SetDepth(13);
    Image.SetImagePath('GI,' + Ranger.GetCaptainPortraitResourceBase + 'i');
    Image.SetImageKindX(ikxCenter);
    Image.SetImageKindY(ikyCenter);
    if GiResourceVariant = 1 then Image.SetPosition(Classes.Point(72,34))
    else Image.SetPosition(Classes.Point(90,43));
    if GiResourceVariant = 1 then Image.SetSize(Classes.Point(77,86))
    else Image.SetSize(Classes.Point(99,110));
    if AnimCaptain then
    begin
      Animation := TgaiGI.Create(Panel);
      Animation.SetDepth(12);
      Animation.UsesPlaybackBuffer := True;
      Animation.SetImagePath(Ranger.GetCaptainPortraitResourceBase + 'a');
      Animation.SequenceIndex := 0;
      Animation.UpdateAutoGeometry;
      Animation.TransparentColor := CurrentPixelFormat.PackRgbBytes(255,0,255);
      Animation.SetImageKindX(ikxCenter);
      Animation.SetImageKindY(ikyCenter);
      if GiResourceVariant = 1 then Animation.SetPosition(Classes.Point(72,34))
      else Animation.SetPosition(Classes.Point(90,43));
      if GiResourceVariant = 1 then Animation.SetSize(Classes.Point(77,86))
      else Animation.SetSize(Classes.Point(99,110));
      Animation.RestartPlayback;
    end;
    if (Ranger.AwardIds <> nil) and (Ranger.AwardIds.Count > 0) then CreateRatingRowAwardStrip;
  end
  else
  begin
    Image := TImageGI.Create(Panel);
    Image.UserState := Index;
    Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'Normal' + OwnerInfo[RaceToOwner(Ranger.PilotRace)].InternalName);
    Image.SetSize(Image.GetContentSize);
    Image.SetPosition(Classes.Point(0,0));
    Image.SetDepth(11);
    Image.MouseEnterCallback := RowMouseEnter;
    Image.MouseLeaveCallback := RowMouseLeave;
    Image.LeftButtonDownCallback := RowMouseDown;
    Panel.SetSize(Image.ClientSize);
  end;
  if (GetPlayer = Ranger) or Ranger.IsInPrison or (Ranger.PartnerShip <> nil) or (Ranger.CountWingmen > 0) then
  begin
    Image := TImageGI.Create(Panel);
    if GetPlayer = Ranger then Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'Player')
    else if Ranger.IsInPrison then Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'Prison')
    else Image.SetImagePath('GI,Bm.FormRating2.' + GiResourceSuffix + 'Duty');
    Image.SetSize(Image.GetContentSize);
    Image.SetPosition(Classes.Point(GiScalePixels(77),4));
    Image.SetDepth(10);
    Image.UserValue := Index;
    Image.MouseEnterCallback := ShowPartnershipHint;
    Image.MouseLeaveCallback := HintMouseLeave;
  end;
  Image := TImageGI.Create(Panel);
  Image.SetImagePath(GetRatingRankImagePath(Ranger.Rank));
  Image.SetSize(Classes.Point(GiScalePixels(100),GiScalePixels(30)));
  Image.SetPosition(Classes.Point(GiScalePixels(442),GiScalePixels(9)));
  Image.SetImageKindX(ikxCenter);
  Image.SetImageKindY(ikyCenter);
  Image.SetDepth(8);
  Caption := TLabelGI.Create(Panel);
  if GiResourceVariant = 1 then Caption.SetPosition(Classes.Point(GiScalePixels(215),GiScalePixels(16) + 1))
  else Caption.SetPosition(Classes.Point(GiScalePixels(215),GiScalePixels(16)));
  Caption.SetSize(Classes.Point(GiScalePixels(117),GiScalePixels(17)));
  Caption.SetFontName(NormalFontName);
  Caption.SetWordWrapEnabled(False);
  Caption.SetTextAlignX(taxCenter);
  Caption.SetTextAlignY(tayCenterEx);
  Caption.SetText(Ranger.GetCharacterName);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Caption.UserValue := Index;
  Caption.MouseEnterCallback := ShowCareerHint;
  Caption.MouseLeaveCallback := HintMouseLeave;
  Caption := TLabelGI.Create(Panel);
  if GiResourceVariant = 1 then Caption.SetPosition(Classes.Point(GiScalePixels(73),GiScalePixels(16) + 1))
  else Caption.SetPosition(Classes.Point(GiScalePixels(73),GiScalePixels(16)));
  Caption.SetSize(Classes.Point(GiScalePixels(130),GiScalePixels(17)));
  Caption.SetFontName(NormalBoldFontName);
  Caption.SetWordWrapEnabled(False);
  Caption.SetTextAlignX(taxCenter);
  Caption.SetTextAlignY(tayCenterEx);
  Caption.SetText(Ranger.GetName);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Caption := TLabelGI.Create(Panel);
  if GiResourceVariant = 1 then Caption.SetPosition(Classes.Point(GiScalePixels(24),GiScalePixels(16) + 1))
  else Caption.SetPosition(Classes.Point(GiScalePixels(24),GiScalePixels(16)));
  Caption.SetSize(Classes.Point(GiScalePixels(45),GiScalePixels(17)));
  Caption.SetFontName(NormalFontName);
  Caption.SetWordWrapEnabled(False);
  Caption.SetTextAlignX(taxCenter);
  Caption.SetTextAlignY(tayCenterEx);
  Caption.SetText(IntToStr(Index + 1));
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Caption := TLabelGI.Create(Panel);
  if GiResourceVariant = 1 then Caption.SetPosition(Classes.Point(GiScalePixels(555),GiScalePixels(16) + 1))
  else Caption.SetPosition(Classes.Point(GiScalePixels(555),GiScalePixels(16)));
  Caption.SetSize(Classes.Point(GiScalePixels(75),GiScalePixels(17)));
  Caption.SetFontName(NormalBoldFontName);
  Caption.SetWordWrapEnabled(False);
  Caption.SetTextAlignX(taxCenter);
  Caption.SetTextAlignY(tayCenterEx);
  Caption.SetText(IntToStr(Ranger.TotalExperience));
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  Rows[Index].Height := Panel.ClientSize.Y;
  TablePanel.VerticalScrollBar.SetSmallChange(Min(Rows[Index].Height,TablePanel.VerticalScrollBar.SmallChange));
  if SelectedIndex = Index then
    SelectedRowRect := Classes.Rect(0,Rows[Index].Top,1,Rows[Index].Top + Rows[Index].Height);
end;
{ @end $5D548C }

{ @routine $5D7248 TfRating2_RowMouseEnter }
procedure TfRating2.RowMouseEnter(Sender: TObjectGI);
begin
  (Sender as TImageGI).ImageSourcePath := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Select' + OwnerInfo[RaceToOwner(Rows[Sender.UserState].Ranger.PilotRace)].InternalName;
  SoundManager.PlaySound('Sound.ButtonEnter');
end;
{ @end $5D7248 }

{ @routine $5D736C TfRating2_RowMouseLeave }
procedure TfRating2.RowMouseLeave(Sender: TObjectGI);
begin
  (Sender as TImageGI).ImageSourcePath := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Normal' + OwnerInfo[RaceToOwner(Rows[Sender.UserState].Ranger.PilotRace)].InternalName;
  SoundManager.PlaySound('Sound.ButtonLeave');
end;
{ @end $5D736C }

{ @routine $5D7490 TfRating2_RefreshFeaturedRangers }
procedure TfRating2.RefreshFeaturedRangers;
var Ship: TShip;
begin
  if Galaxy.EminentCareerShips[rcTrader] = nil then
  begin
    GetByName('TraderCaptainI').SetActive(False);
    GetByName('TraderCaptainA').SetActive(False);
    GetByName('BestTrader').SetActive(False);
    (GetByName('ButTrader') as TGraphButtonGI).SetDisabled(True);
    GetByName('TraderEmpty').SetActive(True);
    (GetByName('TraderEmpty') as TgaiGI).RestartPlayback;
  end
  else
  begin
    Ship := TShip(Galaxy.EminentCareerShips[rcTrader]);
    with GetByName('ButTrader') as TGraphButtonGI do
    begin
      SetDisabled(False);
      UserValue := Ship.Id;
      UpCallback := FeaturedRangerClicked;
    end;
    GetByName('TraderEmpty').SetActive(False);
    with GetByName('BestTrader') as TLabelGI do
    begin
      Text := Ship.Name;
      SetActive(True);
    end;
    with GetByName('TraderCaptainI') as TImageGI do
    begin
      UserValue := Ship.Id;
      ImageSourcePath := 'GI,' + Ship.GetCaptainPortraitResourceBase + 'i';
      KindX := ikxCenter;
      KindY := ikyCenter;
      SetActive(True);
    end;
    with GetByName('TraderCaptainA') as TgaiGI do
    begin
      FirstFrameOnly := not AnimCaptain;
      SetImagePath(Ship.GetCaptainPortraitResourceBase + 'a');
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetSequenceFrame(RandomIntRange(0,SequenceFrameCount - 1));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
      RestartPlayback;
    end;
  end;
  if Galaxy.EminentCareerShips[rcWarrior] = nil then
  begin
    GetByName('WarriorCaptainI').SetActive(False);
    GetByName('WarriorCaptainA').SetActive(False);
    GetByName('BestWarrior').SetActive(False);
    (GetByName('ButWarior') as TGraphButtonGI).SetDisabled(True);
    GetByName('WariorEmpty').SetActive(True);
    (GetByName('WariorEmpty') as TgaiGI).RestartPlayback;
  end
  else
  begin
    Ship := TShip(Galaxy.EminentCareerShips[rcWarrior]);
    with GetByName('ButWarior') as TGraphButtonGI do
    begin
      SetDisabled(False);
      UserValue := Ship.Id;
      UpCallback := FeaturedRangerClicked;
    end;
    GetByName('WariorEmpty').SetActive(False);
    with GetByName('BestWarrior') as TLabelGI do
    begin
      Text := Ship.Name;
      SetActive(True);
    end;
    with GetByName('WarriorCaptainI') as TImageGI do
    begin
      UserValue := Ship.Id;
      ImageSourcePath := 'GI,' + Ship.GetCaptainPortraitResourceBase + 'i';
      KindX := ikxCenter;
      KindY := ikyCenter;
      SetActive(True);
    end;
    with GetByName('WarriorCaptainA') as TgaiGI do
    begin
      FirstFrameOnly := not AnimCaptain;
      SetImagePath(Ship.GetCaptainPortraitResourceBase + 'a');
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetSequenceFrame(RandomIntRange(0,SequenceFrameCount - 1));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
      RestartPlayback;
    end;
  end;
  if Galaxy.EminentCareerShips[rcPirate] = nil then
  begin
    GetByName('PirateCaptainI').SetActive(False);
    GetByName('PirateCaptainA').SetActive(False);
    GetByName('BestPirate').SetActive(False);
    (GetByName('ButPirate') as TGraphButtonGI).SetDisabled(True);
    GetByName('PirateEmpty').SetActive(True);
    (GetByName('PirateEmpty') as TgaiGI).RestartPlayback;
  end
  else
  begin
    Ship := TShip(Galaxy.EminentCareerShips[rcPirate]);
    with GetByName('ButPirate') as TGraphButtonGI do
    begin
      SetDisabled(False);
      UserValue := Ship.Id;
      UpCallback := FeaturedRangerClicked;
    end;
    GetByName('PirateEmpty').SetActive(False);
    with GetByName('BestPirate') as TLabelGI do
    begin
      Text := Ship.Name;
      SetActive(True);
    end;
    with GetByName('PirateCaptainI') as TImageGI do
    begin
      UserValue := Ship.Id;
      ImageSourcePath := 'GI,' + Ship.GetCaptainPortraitResourceBase + 'i';
      KindX := ikxCenter;
      KindY := ikyCenter;
      SetActive(True);
    end;
    with GetByName('PirateCaptainA') as TgaiGI do
    begin
      FirstFrameOnly := not AnimCaptain;
      SetImagePath(Ship.GetCaptainPortraitResourceBase + 'a');
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetSequenceFrame(RandomIntRange(0,SequenceFrameCount - 1));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
      RestartPlayback;
    end;
  end;
end;
{ @end $5D7490 }

{ @routine $5D7D20 TfRating2_SelectMusic }
procedure TfRating2.SelectMusic;
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
    else if GetPlayer.DockedTo.TypeId in [rstPirateBase, rstDominion] then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end
  else if GetPlayer.InNormalSpace then
  begin
    if MusicInSpaceEnabled then
    begin
      if (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0, 100) < 20) then
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
{ @end $5D7D20 }

{ @routine $5D8058 TfRating2_ProcessCallbackTimers }
procedure TfRating2.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $5D8058 }

{ @routine $5D8084 ShowRangerRating }
function ShowRangerRating(Parent: TMessageLoopGI): Boolean;
var State: TCursorStateGI;
begin
  Parent.RootUiObject.OnModalSuspend;
  Parent.CaptureCursorState(@State);
  Parent.ShowCursor := False;
  Parent.DrawQueuedUpdateRects;
  RangerRatingScreen.ParentLoop := Parent;
  Parent.ChildLoop := RangerRatingScreen;
  if RangerRatingScreen.Run = 1 then Result := True else Result := False;
  RangerRatingScreen.ParentLoop := nil;
  Parent.ChildLoop := nil;
  Parent.InvalidateViewport;
  Parent.RestoreCursorState(@State);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.OnModalResume;
  Parent.Present;
  PostMouseMoveMessage;
end;
{ @end $5D8084 }

{ @routine $5D81B4 TfRating2_ShowDominatorKillsHint }
procedure TfRating2.ShowDominatorKillsHint(Sender: TObjectGI);
var DisplayIndex: TDominatorDisplayIndex; Cursor: TPoint; CaptionText: WideString; Ranger: TRanger;
  // @nested $5D815C FormatDominatorKillsHintColumn
  function FormatDominatorKillsHintColumn(Column: Integer): WideString; // @addr 0x005D815C @calls "0x005D836E,0x005D83C3,0x005D8411,0x005D8426" @note "Nested in TfRating2.ShowDominatorKillsHint; caller supplies its parent frame."
  begin
    Result := IntToStr(DominatorHintColumns[Column] + 40);
  end;
begin
  Ranger := Rows[Sender.UserValue].Ranger;
  if GetPlayer <> Ranger then Exit;
  RewardWindow.SetActive(True);
  if GetPlayer = Ranger then
  begin
    with GetByName('RewardName') as TLabelGI do
      Text := FormatText1(LocalizedColorText('FormRating.PlayerName'),TextHighlightColorTag,'<Name>',Ranger.GetName);
    with GetByName('RewardImage') as TGraphBufGI do
      LoadGiByPathIntoGraphBuf('Bm.FormRating2.' + GiResourceSuffix + 'PlayerB',GraphBuf);
  end
  else
  begin
    with GetByName('RewardName') as TLabelGI do
      Text := FormatText1(LocalizedColorText('FormRating.PartnerName'),TextHighlightColorTag,'<Name>',Ranger.GetName);
    with GetByName('RewardImage') as TGraphBufGI do
      LoadGiByPathIntoGraphBuf('Bm.FormRating2.' + GiResourceSuffix + 'DutyB',GraphBuf);
  end;
  if GetPlayer = Ranger then
  begin
    CaptionText := '<td=' + FormatDominatorKillsHintColumn(1) + '><align=left>' + LocalizedText('FormRating.Dominator') + '</align>' + #13#10;
    for DisplayIndex := Low(DominatorDisplayOrder) to High(DominatorDisplayOrder) do
    begin
      if DominatorDisplayOrder[DisplayIndex] = ktBoss then Continue;
      CaptionText := CaptionText + '<td=' + FormatDominatorKillsHintColumn(1) + '><align=left>' + LocalizedColorText(AnsiString('ShipType.Dominator.Blazer.') + IntToStr(Ord(DominatorDisplayOrder[DisplayIndex]))) +
        '<td=' + FormatDominatorKillsHintColumn(2) + '>:</align><td=' + FormatDominatorKillsHintColumn(3) + '><align=left>' +
        WrapTextInColor(IntToStr(GetPlayer.DominatorKillsByType[DominatorDisplayOrder[DisplayIndex]]) ,TextHighlightColorTag) + '</align>' + #13#10;
    end;
    with GetByName('RewardText') as TLabelGI do Text := CaptionText;
  end;
  with GetByName('RewardImage') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  ShipScreen.LayoutItemInfo(RewardWindow,GetByName('RewardName') as TLabelGI,GetByName('RewardText') as TLabelGI,True,True,0);
  with GetByName('RewardText') as TLabelGI do SetTextAlignX(taxLeft);
  with GetByName('RewardName') as TLabelGI do
    SetSize(Classes.Point(Self.RewardWindow.ClientSize.X - LocalPosition.X - Self.RewardWindow.WorkSubRect.Right,ClientSize.Y));
  Cursor := GetCursorPoint;
  RewardWindow.SetPosition(Classes.Point(Cursor.X + 100,Max(0,Cursor.Y - RewardWindow.ClientSize.Y - 20)));
end;
{ @end $5D81B4 }

end.
