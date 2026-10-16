unit fScaner;

interface

uses EC_BlockPar, GI_GraphBuf, GI_GraphButton, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, GI_Window, Types, EC_CacheFont, aShip, aItem, aNormalShip, aGalaxyStruct, GI_GAI, GI_Zone;

type
  TfScaner = class(TMessageLoopGI) // @size 0x27C
  public
    BackgroundBuffer: TGraphBufGI; // @offset 0xD0
    ExitButton: TGraphButtonGI; // @offset 0xD4
    ShipToInspect: TShip; // @offset $D8 Borrowed scan target, assigned from ScannerTarget by OnOpen.
    ItemInfoWindow: TWindowGI; // @offset 0xDC
    ItemImage: TImageGI; // @offset 0xE0
    ItemNameLabel: TLabelGI; // @offset 0xE4
    ItemDescriptionLabel: TLabelGI; // @offset 0xE8
    ItemSizeLabel: TLabelGI; // @offset 0xEC
    ItemPriceLabel: TLabelGI; // @offset 0xF0
    ItemRaceImage: TImageGI; // @offset 0xF4
    SkillsPanel: TPanelGI; // @offset 0xF8
    FreeSkillPointsLabel: TLabelGI; // @offset 0xFC
    SkillImages: array[0..5] of TImageGI; // @offset 0x100
    SkillPositiveImages: array[0..5] of TImageGI; // @offset $118
    SkillNegativeImages: array[0..5] of TImageGI; // @offset $130
    SkillPanels: array[0..5] of TPanelGI; // @offset 0x148
    SkillImageRestTop: array[0..5] of Integer; // @offset 0x160
    SkillButtons: array[0..5] of TGraphButtonGI; // @offset 0x178
    RewardsBuffer: TGraphBufGI; // @offset 0x190
    RewardWindow: TWindowGI; // @offset 0x194
    HoveredItemAnimation: TgaiGI; // @offset $198
    VisibleCargoCount: Integer; // @offset $19C
    CargoOffset: Integer; // @offset $1A0
    CargoEntryCount: Integer; // @offset $1A4
    PanelSlideTimer: TCallbackTimerIdGI; // @offset $1A8
    PanelSlideStep: Integer; // @offset $1AC
    PanelSlideStartX: Integer; // @offset $1B0
    PanelSlideEndX: Integer; // @offset $1B4
    ItemHoverTimer: TCallbackTimerIdGI; // @offset $1B8
    HideItemTimer: TCallbackTimerIdGI; // @offset $1BC
    PropertyHintTimer: TCallbackTimerIdGI; // @offset $1C0
    ShipImageCenter: TPoint; // @offset $1C4
    ArtefactZones: array of TZoneGI; // @offset $1CC
    EquipmentAnimations: array[0..7, 0..4] of TgaiGI; // @offset $1D0
    HoveredItem: TItem; // @offset $270
    HoveredRewardId: Integer; // @offset $274
    CompactHullInfo: Boolean; // @offset $278 Suppresses the dedicated hull panel; OnOpen sets this for station types 6..13.

    procedure UpdateSkills; // @addr $51B474
    procedure BuildAdditionalInfo; // @addr $51BA6C
    procedure ShowPropertyInfo(Sender: TObjectGI); // @addr $516668
    procedure ShowItemInfo(Item: TObject); // @addr $519FA0
    procedure ShowGoodsInfo(ItemType: TItemType); // @addr $51AD34
    function CreateAdditionalInfoIcon(Sender: TLabelGI; Item: PFontObjectEC): TObjectGI; // @addr $51B640
    procedure BuildRewardStrip(Ship: TShip); // @addr $515AC4
    procedure RewardsMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $515FB0
    procedure ShowRewardInfo(Ship: TNormalShip; AwardId: Integer); // @addr $516114
    procedure HideRewardInfo; // @addr $5164E0
    procedure RewardMouseLeave(Sender: TObjectGI); // @addr $51610C
    procedure AdvancePanelSlide(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $5164F8
    procedure RewardsMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5165B8
    procedure HidePropertyInfo(Sender: TObjectGI); // @addr $517BC4
    procedure RefreshRewardHint(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $517BF0
    procedure CountCargoEntries; // @addr $517BF4
    function GetCargoEntry(Index: Integer; var ItemType: TItemType; var Item: TItem): Boolean; // @addr $517C88
    procedure ScrollCargoLeft(Sender: TObjectGI); // @addr $51958C
    procedure ScrollCargoRight(Sender: TObjectGI); // @addr $519598
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5195A4
    procedure MainPanelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $519690
    procedure UpdateItemHover; // @addr $51986C
    procedure AdvanceItemHover(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $519E84
    procedure HideItemInfo(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $519E8C

    procedure OnOpen; override; // @addr 0x005144D4
    procedure Update; // @addr 0x00517DB0
    procedure OnClose; override; // @addr 0x00515A40
    procedure SelectMusic; override; // @addr 0x0051C0EC
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x00519644
    procedure InitializeLayout; override; // @addr 0x00513CA8
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x0051C094
    procedure CloseClicked(Sender: TObjectGI); // @addr 0x00516588
  end;

function GetPirateRankSmallImagePath(Rank: TShipRank): WideString; // @addr $513BE4

implementation

uses Classes, SysUtils, Math, Windows, EC_Struct, EC_Str, GR_Main, GR_GraphBuf,
  GR_Music, Globals, GlobalsV, aGalaxy, aPlayer, aConst, aMyFunction, aScript,
  ThreadCalc, fRewards, fStarMap, fShip2, GI_PanelScrollBar, GI_ScrollBar, fEquipmentShop,
  aRanger, aKling, aRuins, aTranclucator;

{ @routine $513BE4 GetPirateRankSmallImagePath }
function GetPirateRankSmallImagePath(Rank: TShipRank): WideString;
begin
  case Rank of
    0..7: Result := 'GI,Bm.FormShip2.PRank' + IntToStr(Rank + 1) + 's';
  else RaiseWideMessage('error');
  end;
end;
{ @end $513BE4 }

{ @routine $513CA8 TfScaner_InitializeLayout }
procedure TfScaner.InitializeLayout;
var
  I: Integer;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fScaner... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('BGBuf') do
    begin
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      with NextSibling do SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('PanelRight').Parent.Parent do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('RankWnd') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
    with FindByNameRecursive('RewardWnd') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
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
  SkillsPanel := GetByName('Skills') as TPanelGI;
  FreeSkillPointsLabel := GetByName('SkillFreePoints') as TLabelGI;
  ExitButton := GetByName('Exit') as TGraphButtonGI;
  ExitButton.UpCallback := CloseClicked;
  RewardsBuffer := GetByName('RewardsImg') as TGraphBufGI;
  RewardWindow := GetByName('RewardWnd') as TWindowGI;
  (GetByName('S_Left') as TGraphButtonGI).UpCallback := ScrollCargoLeft;
  (GetByName('S_Right') as TGraphButtonGI).UpCallback := ScrollCargoRight;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  GetByName('MainPanel').LeftButtonUpCallback := MainPanelMouseUp;
  with GetByName('Ship3D') do ShipImageCenter := AddPoints(LocalPosition, HalfPoint(ClientSize));
  for I := 0 to 5 do
  begin
    SkillImages[I] := GetByName('Skill' + IntToStr(I)) as TImageGI;
    SkillPositiveImages[I] := GetByName('Skill' + IntToStr(I) + 'p') as TImageGI;
    SkillNegativeImages[I] := GetByName('Skill' + IntToStr(I) + 'n') as TImageGI;
    SkillPanels[I] := GetByName('Skill' + IntToStr(I) + 'c') as TPanelGI;
    SkillImageRestTop[I] := SkillImages[I].LocalPosition.Y;
    SkillButtons[I] := GetByName('Skill' + IntToStr(I) + 'Add') as TGraphButtonGI;
  end;
  PanelSlideStartX := GiScalePixels(100);
  PanelSlideEndX := GetByName('PanelRight').LocalPosition.X;
end;
{ @end $513CA8 }

{ @routine $5144D4 TfScaner_OnOpen }
procedure TfScaner.OnOpen;
var
  I, SlotCount, J, MaximumSlots: Integer;
  Ranger: TRanger;
  Stage: Integer;
  ReservedText: WideString; // Native frame initializes and finalizes this unreferenced managed slot.
begin
  Stage := 0;
  try
    SetLength(ArtefactZones, DefaultHullSlotCounts[slot_artefact]);
    for I := 0 to DefaultHullSlotCounts[slot_artefact] - 1 do ArtefactZones[I] := GetByName('Art' + IntToStr(I) + 'z') as TZoneGI;
    Stage := 1;
    if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True, 0);
    BackgroundBuffer.BindExternalGraphBuf(AuxRenderBuffer);
    Stage := 2;
    ShipToInspect := ScannerTarget as TShip;
    Stage := 3;
    if GetPlayer <> nil then GetPlayer.ScriptItemsAct(event_scan, ShipToInspect, nil, 0);
    Stage := 4;
    ShipToInspect.ScriptItemsAct(event_enter_form, nil, nil, 0);
    Stage := 5;
    CompactHullInfo := ShipToInspect.TypeId in [station_ranger_center..station_custom];
    Stage := 6;
    CountCargoEntries;
    VisibleCargoCount := 6;
    CargoOffset := 0;
    Stage := 7;
    for I := 0 to 5 do
      with GetByName('Skill' + IntToStr(I) + 'z') as TZoneGI do
      begin
        EnterCallback := ShowPropertyInfo;
        LeaveCallback := HidePropertyInfo;
      end;
    Stage := 8;
    for I := 0 to 7 do
    begin
      MaximumSlots := 1;
      if EquipmentSlotLayouts[I].ItemType = weapon_category then MaximumSlots := 5;
      SlotCount := ShipToInspect.GetSlotCountForItemType(EquipmentSlotLayouts[I].ItemType);
      for J := 0 to SlotCount - 1 do
      begin
        EquipmentAnimations[I, J] := GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'anim') as TgaiGI;
        EquipmentAnimations[I, J].UserState := 0;
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'off').SetActive(False);
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'Set').SetActive(False);
      end;
      if EquipmentSlotLayouts[I].ItemType = weapon_category then
      begin
        for J := SlotCount to 4 do
        begin
          GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'off').SetActive(True);
          GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'Set').SetActive(False);
        end;
      end
      else
        for J := SlotCount to 0 do
        begin
          GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'off').SetActive(True);
          GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'Set').SetActive(False);
        end;
      for J := SlotCount to MaximumSlots - 1 do
      begin
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'i').SetActive(False);
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(J) + 'anim').SetActive(False);
      end;
    end;
    Stage := 9;
    for I := 0 to 5 do
      with GetByName('Skill' + IntToStr(I) + 'z') as TZoneGI do
      begin
        EnterCallback := ShowPropertyInfo;
        LeaveCallback := HidePropertyInfo;
      end;
    Stage := 10;
    HoveredItem := nil;
    GetByName('PII').SetActive(False);
    GetByName('InfoHull').SetActive(False);
    Stage := 11;
    if ShipToInspect.TypeId = ship_ranger then
    begin
      Ranger := ShipToInspect as TRanger;
      (GetByName('ShipName') as TLabelGI).Text := Ranger.GetFullName(#13#10);
      (GetByName('CharName') as TLabelGI).Text := Ranger.GetCharacterName;
    end
    else
    begin
      (GetByName('ShipName') as TLabelGI).Text := ShipToInspect.GetFullName(#13#10);
      (GetByName('CharName') as TLabelGI).Text := ShipToInspect.GetLocalizedTypeName;
    end;
    Stage := 12;
    with GetByName('Ship3D') as TImageGI do
    begin
      ImageSourcePath := ShipToInspect.GetShipPortraitImagePath;
      KindX := image_x_center;
      KindY := image_y_center;
      SetPosition(SubtractPoints(ShipImageCenter, GetVisualCenter));
    end;
    Stage := 13;
    GetByName('RankWnd').SetActive(False);
    with GetByName('RankI') as TImageGI do
    begin
      Stage := 14;
      if (ShipToInspect is TKling) or (ShipToInspect is TRuins) or (ShipToInspect is TTranclucator) then
      begin
        MouseEnterCallback := nil;
        MouseLeaveCallback := nil;
      end
      else
      begin
        MouseEnterCallback := ShowPropertyInfo;
        MouseLeaveCallback := HidePropertyInfo;
      end;
      SetActive(True);
      Stage := 15;
      if ShipToInspect is TKling then
        ImageSourcePath := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank' + IntToStr(DominatorShipDefinitions[(ShipToInspect as TKling).KlingType].RankImageIndex)
      else if ShipToInspect is TRuins then ImageSourcePath := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank7'
      else if ShipToInspect is TTranclucator then ImageSourcePath := 'GI,Bm.FormRating2.' + GiResourceSuffix + 'Rank4'
      else if (ShipToInspect is TNormalShip) and (ShipToInspect.OwnerId <> owner_pirate) then
        ImageSourcePath := 'GI,Bm.FormRating2.2Rank' + IntToStr((ShipToInspect as TNormalShip).Rank + 1)
      else SetActive(False);
    end;
    Stage := 16;
    with GetByName('RankI2') as TImageGI do
      if (ShipToInspect is TNormalShip) and (ShipToInspect.OwnerId = owner_pirate) then
      begin
        SetActive(True);
        MouseEnterCallback := ShowPropertyInfo;
        MouseLeaveCallback := HidePropertyInfo;
        SetImagePath('GI,Bm.FormShip2.PRank' + IntToStr((ShipToInspect as TNormalShip).PirateRank + 1));
      end
      else SetActive(False);
    Stage := 17;
    GetByName('PRankForm').SetActive(False);
    UpdateSkills;
    GetByName('S_Left').SetActive(False);
    GetByName('S_Right').SetActive(False);
    GetByName('S_Left').SetActive(True);
    GetByName('S_Right').SetActive(True);
    Stage := 18;
    with GetByName('CaptainI') as TImageGI do
    begin
      ImageSourcePath := 'GI,' + ShipToInspect.GetCaptainPortraitResourceBase + 'i';
      KindX := image_x_center;
      KindY := image_y_center;
      SetActive(True);
    end;
    Stage := 19;
    with GetByName('CaptainA') as TgaiGI do
    begin
      FirstFrameOnly := not AnimCaptain;
      SetImagePath(ShipToInspect.GetCaptainPortraitResourceBase + 'a');
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetImageKindX(image_x_center);
      SetImageKindY(image_y_center);
      SetActive(True);
      RestartPlayback;
    end;
    Stage := 20;
    BuildRewardStrip(ShipToInspect);
    Stage := 21;
    Update;
    Stage := 22;
    InvalidateViewport;
    Stage := 23;
    DrawQueuedUpdateRects;
    Stage := 24;
    GetByName('PanelRight').SetPosition(Classes.Point(PanelSlideStartX, GetByName('PanelRight').LocalPosition.Y));
    PanelSlideStep := 20;
    if PanelSlideTimer <> 0 then
    begin
      CancelCallbackTimer(PanelSlideTimer);
      PanelSlideTimer := 0;
    end;
    PanelSlideTimer := ScheduleCallbackTimer(20, 20, AdvancePanelSlide);
    Stage := 25;
    if ItemHoverTimer <> 0 then
    begin
      CancelCallbackTimer(ItemHoverTimer);
      ItemHoverTimer := 0;
    end;
    ItemHoverTimer := ScheduleCallbackTimer(1, 1, AdvanceItemHover);
    Stage := 26;
    if ShipToInspect.GetHull.HullPoints / ShipToInspect.GetHull.Weight > 0.2 then
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
    Stage := 27;
    GetByName('Forsage').SetActive(ShipToInspect.GetSlotCount(slot_afterburner) > 0);
    GetByName('ForsageLight').SetActive(ShipToInspect.AfterburnerActive and ShipToInspect.IsEquipmentUsable(ShipToInspect.GetEngine));
    Stage := 28;
    with GetByName('ForsageBut') as TGraphButtonGI do
    begin
      MouseEnterCallback := ShowPropertyInfo;
      MouseLeaveCallback := HidePropertyInfo;
      SetDisabled(True);
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TfScaner.BeforeRun, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5144D4 }

{ @routine $515A40 TfScaner_OnClose }
procedure TfScaner.OnClose;
begin
  ShipToInspect.ScriptItemsAct(event_leave_form, nil, nil, 0);
  if ItemHoverTimer <> 0 then
  begin
    CancelCallbackTimer(ItemHoverTimer);
    ItemHoverTimer := 0;
  end;
  if HideItemTimer <> 0 then
  begin
    CancelCallbackTimer(HideItemTimer);
    HideItemTimer := 0;
  end;
  if PropertyHintTimer <> 0 then
  begin
    CancelCallbackTimer(PropertyHintTimer);
    PropertyHintTimer := 0;
  end;
  if PanelSlideTimer <> 0 then
  begin
    CancelCallbackTimer(PanelSlideTimer);
    PanelSlideTimer := 0;
  end;
end;
{ @end $515A40 }

{ @routine $515AC4 TfScaner_BuildRewardStrip }
procedure TfScaner.BuildRewardStrip(Ship: TShip);
var
  I, DrawIndex: Integer;
  Image, Shadow: TGraphBufGR;
  AwardId: Byte;
  Path: WideString;
  Size: Integer;
  Spacing: Single;
  VisibleCount: Integer;
begin
  HideRewardInfo;
  if not (Ship is TNormalShip) or (Ship.AwardIds = nil) or (Ship.AwardIds.Count < 1) then
  begin
    RewardsBuffer.SetActive(False);
    Exit;
  end;
  if (Ship.AwardIds = nil) or (Ship.AwardIds.Count < 1) then
  begin
    RewardsBuffer.SetActive(False);
    Exit;
  end;
  Size := GiScalePixels(20);
  VisibleCount := (RewardsBuffer.ClientSize.X - 2) div Size;
  if Ship.AwardIds.Count <= VisibleCount then Spacing := Size
  else
  begin
    VisibleCount := Min(30, Ship.AwardIds.Count);
    Spacing := (RewardsBuffer.ClientSize.X - 2 - Size) / (VisibleCount - 1);
  end;
  with RewardsBuffer do
  begin
    SetActive(True);
    SetImageKindX(image_x_left);
    SetImageKindY(image_y_bottom);
    GraphBuf.AllocateRgbaTight(Max(ClientSize.X, Round(VisibleCount * Spacing + Size - Spacing)) + 2, Size + 2);
    MouseMoveCallback := RewardsMouseMove;
    MouseLeaveCallback := RewardMouseLeave;
    LeftButtonDownCallback := RewardsMouseDown;
    GraphBuf.ClearPixels;
    SourceHasPerPixelAlpha := True;
  end;
  Image := TGraphBufGR.Create(False);
  Shadow := TGraphBufGR.Create(False);
  I := Max(0, Ship.AwardIds.Count - VisibleCount);
  DrawIndex := 0;
  while I < Ship.AwardIds.Count do
  begin
    AwardId := Byte(Ship.AwardIds[I]);
    if AwardId < 10 then Path := 'Bm.FormRewards.' + GiResourceSuffix + '_0' + IntToStr(AwardId)
    else Path := 'Bm.FormRewards.' + GiResourceSuffix + '_' + IntToStr(AwardId);
    LoadGiByPathIntoGraphBuf(Path, Image);
    if Image.Width >= Image.Height then
      Image.RescaleRgba(Size, Round(Size / Image.Width * Image.Height), 5)
    else Image.RescaleRgba(Round(Size / Image.Height * Image.Width), Size, 5);
    Shadow.AllocateRgbaTight(Image.Width, Image.Height);
    Shadow.CopyRect32(Classes.Point(0, 0), Image, Classes.Rect(0, 0, Image.Width, Image.Height));
    Shadow.MakeShadow;
    if (Integer(Image.Height) <= Size) and (Integer(Image.Width) + Round(DrawIndex * Spacing) <= Integer(RewardsBuffer.GraphBuf.Width)) then
    begin
      RewardsBuffer.GraphBuf.BlendRect32(Classes.Point(Round(DrawIndex * Spacing) + 2, 2), Shadow, Classes.Rect(0, 0, Image.Width, Image.Height));
      RewardsBuffer.GraphBuf.BlendRect32(Classes.Point(Round(DrawIndex * Spacing), 0), Image, Classes.Rect(0, 0, Image.Width, Image.Height));
    end;
    Inc(I);
    Inc(DrawIndex);
  end;
  Image.Free;
  Shadow.Free;
end;
{ @end $515AC4 }

{ @routine $515FB0 TfScaner_RewardsMouseMove }
procedure TfScaner.RewardsMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Size: Integer;
  Spacing: Single;
  VisibleCount: Integer;
  Ship: TShip;
  I, DrawIndex, X: Integer;
  AwardId: Byte;
begin
  Ship := ShipToInspect;
  Size := GiScalePixels(20);
  VisibleCount := (RewardsBuffer.ClientSize.X - 2) div Size;
  if Ship.AwardIds.Count <= VisibleCount then Spacing := Size
  else
  begin
    VisibleCount := Min(30, Ship.AwardIds.Count);
    Spacing := (RewardsBuffer.ClientSize.X - 2 - Size) / (VisibleCount - 1);
  end;
  X := Sender.ToLocalPoint(Point).X;
  I := Max(0, Ship.AwardIds.Count - VisibleCount);
  DrawIndex := 0;
  while I < Ship.AwardIds.Count do
  begin
    if (X >= Round(DrawIndex * Spacing)) and (X < Round((DrawIndex + 1) * Spacing)) then Break;
    Inc(DrawIndex);
    Inc(I);
  end;
  if I >= Ship.AwardIds.Count then I := Ship.AwardIds.Count - 1;
  AwardId := Byte(Ship.AwardIds[I]);
  if Ship is TNormalShip then ShowRewardInfo(Ship as TNormalShip, AwardId);
end;
{ @end $515FB0 }

{ @routine $51610C TfScaner_RewardMouseLeave }
procedure TfScaner.RewardMouseLeave(Sender: TObjectGI);
begin
  HideRewardInfo;
end;
{ @end $51610C }

{ @routine $516114 TfScaner_ShowRewardInfo }
procedure TfScaner.ShowRewardInfo(Ship: TNormalShip; AwardId: Integer);
var
  CursorPoint: TPoint;
  Path: WideString;
begin
  if HoveredRewardId = AwardId then Exit;
  HoveredRewardId := AwardId;
  RewardWindow.SetActive(True);
  CursorPoint := GetCursorPoint;
  RewardWindow.SetPosition(Classes.Point(CursorPoint.X - RewardWindow.ClientSize.X - 50,
    Max(10, CursorPoint.Y - RewardWindow.ClientSize.Y - 20)));
  if AwardId < 10 then Path := 'Bm.FormRewards.' + GiResourceSuffix + '_0' + IntToStr(AwardId)
  else Path := 'Bm.FormRewards.' + GiResourceSuffix + '_' + IntToStr(AwardId);
  with GetByName('RewardImage') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    LoadGiByPathIntoGraphBuf(Path, GraphBuf);
    if GraphBuf.Width >= GraphBuf.Height then
      GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / GraphBuf.Width * GraphBuf.Height), 5)
    else GraphBuf.RescaleRgba(Round(ClientSize.Y / GraphBuf.Height * GraphBuf.Width), ClientSize.Y, 5);
    SetImageKindX(image_x_center);
    SetImageKindY(image_y_center);
  end;
  with GetByName('RewardName') as TLabelGI do Text := Ship.GetAwardInfo(AwardId).Name;
  with GetByName('RewardText') as TLabelGI do Text := Ship.GetAwardInfo(AwardId).Text;
  ShipScreen.LayoutItemInfo(RewardWindow, GetByName('RewardName') as TLabelGI, GetByName('RewardText') as TLabelGI, True, True, 0);
  with GetByName('RewardName') as TLabelGI do
    SetSize(Classes.Point(RewardWindow.ClientSize.X - LocalPosition.X - RewardWindow.WorkSubRect.Right, ClientSize.Y));
  RefreshRewardHint(0, 0);
end;
{ @end $516114 }

{ @routine $5164E0 TfScaner_HideRewardInfo }
procedure TfScaner.HideRewardInfo;
begin
  HoveredRewardId := -1;
  RewardWindow.SetActive(False);
end;
{ @end $5164E0 }

{ @routine $5164F8 TfScaner_AdvancePanelSlide }
procedure TfScaner.AdvancePanelSlide(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var
  X: Integer;
  Panel: TObjectGI;
begin
  Panel := GetByName('PanelRight');
  X := Panel.LocalPosition.X + PanelSlideStep;
  if X >= PanelSlideEndX then
  begin
    X := PanelSlideEndX;
    if PanelSlideTimer <> 0 then
    begin
      CancelCallbackTimer(PanelSlideTimer);
      PanelSlideTimer := 0;
    end;
    RootUiObject.UpdateAbsolutePosition;
    RootUiObject.UpdateSubtreeHitBounds;
  end;
  Panel.SetPosition(Classes.Point(X, Panel.LocalPosition.Y));
end;
{ @end $5164F8 }

{ @routine $516588 TfScaner_CloseClicked }
procedure TfScaner.CloseClicked(Sender: TObjectGI);
begin
  AuxRenderBuffer.Clear;
  RequestedScreenId := ScannerReturnScreenId;
  RequestClose(1);
end;
{ @end $516588 }

{ @routine $5165B8 TfScaner_RewardsMouseDown }
procedure TfScaner.RewardsMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if AwardDialogsEnabled and not ShipToInspect.InHyperspace and RewardsBuffer.Active then
  begin
    RewardWindow.SetActive(False);
    AwardSubject := ShipToInspect;
    Galaxy.CheckIntegrityChecksum(337);
    if not RunRewards(Self, True) then
    begin
      Galaxy.PrimeIntegrityChecksum(338);
      RequestClose(2);
    end
    else Galaxy.PrimeIntegrityChecksum(338);
  end;
end;
{ @end $5165B8 }

{ @routine $516668 TfScaner_ShowPropertyInfo }
procedure TfScaner.ShowPropertyInfo(Sender: TObjectGI);
var
  ImagePath, Title, Text, Description, Caption: WideString;
  Skill: TPilotSkill;
  Ship: TNormalShip;
  Window: TWindowGI;
  UseAnchor: Boolean;
  Position: TPoint;
  Info: PCustomShipInfo;
begin
  if PanelSlideTimer <> 0 then Exit;
  UseAnchor := False;
  Position := Classes.Point(10, 10);
  ImagePath := '';
  if Sender.UserValue = -1 then
  begin
    if Sender.UserData <> 0 then
    begin
      Info := PCustomShipInfo(Sender.UserData);
      RunCustomShipInfoActionCode(Info, event_show_item_info, ShipToInspect, nil, nil, 0);
      Description := Info.Description;
      if Description = '' then Description := LocalizedColorText('ShipInfo.AddInfo.CustomInfos.' + Info.TypeName + '.Description');
      ReplaceTextToken(Description, '<Data1>', IntToStr(Info.Data[1]), TextHighlightColorTag);
      ReplaceTextToken(Description, '<Data2>', IntToStr(Info.Data[2]), TextHighlightColorTag);
      ReplaceTextToken(Description, '<Data3>', IntToStr(Info.Data[3]), TextHighlightColorTag);
      ReplaceTextToken(Description, '<TextData1>', Info.TextData1, TextHighlightColorTag);
      ReplaceTextToken(Description, '<TextData2>', Info.TextData2, TextHighlightColorTag);
      ReplaceTextToken(Description, '<TextData3>', Info.TextData3, TextHighlightColorTag);
      Caption := LocalizedColorText('ShipInfo.AddInfo.CustomInfos.' + Info.TypeName + '.Name');
      ReplaceTextToken(Caption, '<Data1>', IntToStr(Info.Data[1]), TextHighlightColorTag);
      ReplaceTextToken(Caption, '<Data2>', IntToStr(Info.Data[2]), TextHighlightColorTag);
      ReplaceTextToken(Caption, '<Data3>', IntToStr(Info.Data[3]), TextHighlightColorTag);
      ReplaceTextToken(Caption, '<TextData1>', Info.TextData1, TextHighlightColorTag);
      ReplaceTextToken(Caption, '<TextData2>', Info.TextData2, TextHighlightColorTag);
      ReplaceTextToken(Caption, '<TextData3>', Info.TextData3, TextHighlightColorTag);
      Sender.HelpText := Caption + '~' + Description;
    end;
    with GetByName('RankImage') as TGraphBufGI do
    begin
      SourceHasPerPixelAlpha := True;
      LoadGiByPathIntoGraphBuf('Bm.FormShip2.' + GiResourceSuffix + 'AI_' + IntToStr(Cardinal(Sender.UserIndex)) + 'L', GraphBuf);
      SetImageKindX(image_x_center);
      SetImageKindY(image_y_center);
    end;
    Title := ExtractDelimitedPartW(Sender.HelpText, 0, '~');
    Text := ExtractDelimitedRangeW(Sender.HelpText, 1, CountDelimitedPartsW(Sender.HelpText, '~') - 1, '~');
  end
  else if GetByName('ForsageBut') = Sender then
  begin
    UseAnchor := True;
    with GetByName('RankImage') as TGraphBufGI do
    begin
      SourceHasPerPixelAlpha := True;
      LoadGiByPathIntoGraphBuf('Bm.FormShip2.' + GiResourceSuffix + 'ForsageIcon', GraphBuf);
      SetImageKindX(image_x_center);
      SetImageKindY(image_y_center);
    end;
    Title := LocalizedColorText('ShipInfo.Forsage.Name');
    Text := LocalizedColorText('ShipInfo.Forsage.Text');
    if DynamicTipsPos then Position := Classes.Point(Sender.HitTestBounds.Left - 10, Sender.HitTestBounds.Top + Sender.ClientSize.Y + 10);
  end
  else if Sender is TImageGI then
  begin
    if Sender.ControlName = 'RankI' then
    begin
      if ShipToInspect is TNormalShip then
      begin
        if ShipToInspect is TTranclucator then ImagePath := 'Bm.FormShip.' + GiResourceSuffix + 'Rank4'
        else if (ShipToInspect as TNormalShip).Rank = 0 then ImagePath := 'Bm.FormShip2.' + GiResourceSuffix + 'Rank1'
        else if (ShipToInspect as TNormalShip).Rank = 1 then ImagePath := 'Bm.FormShip2.' + GiResourceSuffix + 'Rank2'
        else if (ShipToInspect as TNormalShip).Rank = 2 then ImagePath := 'Bm.FormShip2.' + GiResourceSuffix + 'Rank3'
        else if (ShipToInspect as TNormalShip).Rank = 3 then ImagePath := 'Bm.FormShip2.' + GiResourceSuffix + 'Rank4'
        else if (ShipToInspect as TNormalShip).Rank = 4 then ImagePath := 'Bm.FormShip2.' + GiResourceSuffix + 'Rank5'
        else if (ShipToInspect as TNormalShip).Rank = 5 then ImagePath := 'Bm.FormShip2.' + GiResourceSuffix + 'Rank6'
        else if (ShipToInspect as TNormalShip).Rank = 6 then ImagePath := 'Bm.FormShip2.' + GiResourceSuffix + 'Rank7'
        else if (ShipToInspect as TNormalShip).Rank = 7 then ImagePath := 'Bm.FormShip2.' + GiResourceSuffix + 'Rank8';
      end;
      with GetByName('RankImage') as TGraphBufGI do
      begin
        SetActive(ImagePath <> '');
        SourceHasPerPixelAlpha := True;
        if ImagePath <> '' then
        begin
          LoadGiByPathIntoGraphBuf(ImagePath, GraphBuf);
          SetImageKindX(image_x_center);
          SetImageKindY(image_y_center);
        end;
      end;
      if ShipToInspect is TNormalShip then
      begin
        Ship := ShipToInspect as TNormalShip;
        Title := WrapTextInColor(Ship.GetRankLongName, InfoNameColorTag);
        Text := Ship.GetRankDescription;
        if Ship.Rank <> 7 then
        begin
          if Ship.GetRankPointsToNextRank > 0 then
            Text := Text + ' ' + FormatText2(LocalizedText('Rank.NextRankText'), TextHighlightColorTag, '<NextRank>', Ship.GetNextRankName, '<WarPoints>', IntToStr(Ship.GetRankPointsToNextRank))
          else Text := Text + ' ' + FormatText1(LocalizedText('Rank.NextRankGetText'), TextHighlightColorTag, '<NextRank>', Ship.GetNextRankName);
        end;
      end;
    end
    else if Sender.ControlName = 'RankI2' then
      if ShipToInspect is TNormalShip then
      begin
        Ship := ShipToInspect as TNormalShip;
        ImagePath := ExtractDelimitedPartW(GetPirateRankSmallImagePath(Ship.PirateRank), 1, ',');
        with GetByName('RankImage') as TGraphBufGI do
        begin
          SourceHasPerPixelAlpha := True;
          LoadGiByPathIntoGraphBuf(ImagePath, GraphBuf);
          SetImageKindX(image_x_center);
          SetImageKindY(image_y_center);
        end;
        Title := WrapTextInColor(Ship.GetPirateRankLongName, InfoNameColorTag);
        Text := Ship.GetPirateRankDescription;
        Text := Text + #13#10 + FormatText1(LocalizedText('RankPirate.NextRankText'), TextHighlightColorTag, '<WarPoints>', IntToStr(Ship.GetPirateRankPointsToNextRank));
      end;
  end
  else if Sender is TZoneGI then
  begin
    with GetByName('RankImage') as TGraphBufGI do
    begin
      SourceHasPerPixelAlpha := True;
      LoadGiByPathIntoGraphBuf('Bm.FormShip2.' + GiResourceSuffix + 'Skill' + IntToStr(ExtractDigitsToIntW(Sender.ControlName) + 1), GraphBuf);
      SetImageKindX(image_x_center);
      SetImageKindY(image_y_center);
    end;
    Skill := TPilotSkill(ExtractDigitsToIntW(Sender.ControlName));
    Title := WrapTextInColor(LocalizedText('Skills.' + SkillConfigNames[Skill] + '.Name'), InfoNameColorTag);
    Text := FormatText1(LocalizedText('Skills.' + SkillConfigNames[Skill] + '.Text'), TextHighlightColorTag, '<SkillValue>', IntToStr(PilotSkillEffects[ShipToInspect.GetEffectiveSkillLevel(Skill), Skill]));
    ReplaceTextToken(Text, '<SkillLevel>', IntToStr(ShipToInspect.GetEffectiveSkillLevel(Skill)), TextHighlightColorTag);
    if Skill = skill_technical then ReplaceTextToken(Text, '<N>', IntToStr(ShipToInspect.GetSatelliteLimit), TextHighlightColorTag);
    if Skill = skill_trading then ReplaceTextToken(Text, '<SkillValue2>', IntToStr(TradingSkillSalePercent[ShipToInspect.GetEffectiveSkillLevel(Skill)]), TextHighlightColorTag);
    if Skill = skill_leadership then ReplaceTextToken(Text, '<SkillValue2>', IntToStr(LeadershipExperiencePercent[ShipToInspect.GetEffectiveSkillLevel(Skill)]), TextHighlightColorTag);
    if ShipToInspect.GetBaseSkillLevel(Skill) < 6 then Text := Text + #13#10 + #13#10 + FormatText1(LocalizedText('Skills.PointForNextLevel'), TextHighlightColorTag, '<PointForNextLevel>', IntToStr(SkillTrainingCosts[ShipToInspect.BaseSkills[Skill] + 1, Skill]));
  end;
  (GetByName('RankName') as TLabelGI).Text := Title;
  (GetByName('RankText') as TLabelGI).Text := Text;
  Window := GetByName('RankWnd') as TWindowGI;
  Window.SetPosition(Classes.Point(Window.LocalPosition.X, Max(10, Sender.HitTestBounds.Top - Sender.ClientSize.Y div 3 - 60)));
  Window.SetActive(True);
  Window.Invalidate;
  ShipScreen.LayoutItemInfo(Window, GetByName('RankName') as TLabelGI, GetByName('RankText') as TLabelGI, True, True, 0);
  with GetByName('RankName') as TLabelGI do SetSize(Classes.Point(Window.ClientSize.X - LocalPosition.X - Window.WorkSubRect.Right, ClientSize.Y));
  if not UseAnchor then Window.SetPosition(Classes.Point(ShipScreen.PropertyHintRightEdge - Window.ClientSize.X, Window.LocalPosition.Y))
  else Window.SetPosition(Position);
  if PropertyHintTimer <> 0 then
  begin
    CancelCallbackTimer(PropertyHintTimer);
    PropertyHintTimer := 0;
  end;
end;
{ @end $516668 }

{ @routine $517BC4 TfScaner_HidePropertyInfo }
procedure TfScaner.HidePropertyInfo(Sender: TObjectGI);
begin
  GetByName('RankWnd').SetActive(False);
end;
{ @end $517BC4 }

{ @routine $517BF0 TfScaner_RefreshRewardHint }
procedure TfScaner.RefreshRewardHint(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
end;
{ @end $517BF0 }

{ @routine $517BF4 TfScaner_CountCargoEntries }
procedure TfScaner.CountCargoEntries;
var
  I: Integer;
  Kind: Byte;
  Item: TEquipment;
begin
  CargoEntryCount := 0;
  for Kind := 0 to 7 do
    if ShipToInspect.CargoGoods[Kind].Count > 0 then Inc(CargoEntryCount);
  for I := 0 to ShipToInspect.Inventory.Count - 1 do
  begin
    Item := ShipToInspect.Inventory[I];
    if (Item.EquippedFlag = 0) and (ShipToInspect.GetHull <> Item) then Inc(CargoEntryCount);
  end;
  Inc(CargoEntryCount, ShipToInspect.Artefacts.Count);
end;
{ @end $517BF4 }

{ @routine $517C88 TfScaner_GetCargoEntry }
function TfScaner.GetCargoEntry(Index: Integer; var ItemType: TItemType; var Item: TItem): Boolean;
var
  I: Integer;
  Kind: TItemType;
  Equipment: TEquipment;
begin
  for Kind := item_food to item_narcotics do
    if ShipToInspect.CargoGoods[Ord(Kind)].Count > 0 then
    begin
      Dec(Index);
      if Index < 0 then
      begin
        Item := nil;
        ItemType := Kind;
        Result := True;
        Exit;
      end;
    end;
  for I := 0 to ShipToInspect.Inventory.Count - 1 do
  begin
    Equipment := ShipToInspect.Inventory[I];
    if not ((Equipment.EquippedFlag = 0) and (ShipToInspect.GetHull <> Equipment)) then Continue;
    Dec(Index);
    if Index < 0 then
    begin
      Item := Equipment;
      ItemType := Equipment.ItemType;
      Result := True;
      Exit;
    end;
  end;
  for I := 0 to ShipToInspect.Artefacts.Count - 1 do
  begin
    Equipment := ShipToInspect.Artefacts[I];
    if Equipment.EquippedFlag <> 0 then Continue;
    Dec(Index);
    if Index < 0 then
    begin
      Item := Equipment;
      ItemType := Equipment.ItemType;
      Result := True;
      Exit;
    end;
  end;
  Item := nil;
  ItemType := item_food;
  Result := False;
end;
{ @end $517C88 }

{ @routine $517DB0 TfScaner_Update }
procedure TfScaner.Update;
var
  I, SlotIndex, SlotCount: Integer;
  CanBoost: Boolean;
  Item: TItem;
  CargoKind: TItemType;
  Artefact: TArtefact;
  Text: WideString;
  Image: TImageGI;
  Stage: Integer;
begin
  Stage := 0;
  try
    ShipToInspect.RefreshAssignedItemSlots;
    Stage := 1;
    Text := IntToStr(ShipToInspect.GetDefensePercent) + '%';
    Text := Text + ' + ' + WrapTextInColor(IntToStr(ShipToInspect.GetArmor), '');
    (GetByName('IDef') as TLabelGI).Text := Text;
    Stage := 2;
    (GetByName('IMass') as TLabelGI).Text := IntToStr(ShipToInspect.CalculateMass);
    Stage := 3;
    if ShipToInspect.CalculateSpeed <= 0 then Text := RedColorTag else Text := '';
    (GetByName('ISpeed') as TLabelGI).Text := WrapTextInColor(IntToStr(ShipToInspect.CalculateSpeed), Text);
    Stage := 4;
    if ShipToInspect.GetCargoFreeSpace < 0 then Text := RedColorTag else Text := '';
    (GetByName('IEmpty') as TLabelGI).Text := WrapTextInColor(IntToStr(ShipToInspect.GetCargoFreeSpace), Text);
    (GetByName('S_Left') as TGraphButtonGI).SetDisabled(not (CargoOffset > 0));
    (GetByName('S_Right') as TGraphButtonGI).SetDisabled(not (CargoOffset + VisibleCargoCount <= CargoEntryCount));
    HoveredItemAnimation := nil;
    Stage := 5;
    with GetByName('HullSet') as TImageGI do
    begin
      SetActive(ShipToInspect.GetHull.HasMicroModule);
      if Active then ImageSourcePath := 'GI,' + GetMicroModuleBitmapResourceName(ShipToInspect.GetHull.MicroModuleIndex - 1) + 'Set';
    end;
    Stage := 6;
    for I := 0 to 7 do
    begin
      SlotCount := ShipToInspect.GetSlotCountForItemType(EquipmentSlotLayouts[I].ItemType);
      Stage := 7;
      for SlotIndex := 0 to SlotCount - 1 do
      begin
        Item := ShipToInspect.FindEquippedItemInSlot(EquipmentSlotLayouts[I].ItemType, SlotIndex);
        Stage := 8;
        Image := GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'i') as TImageGI;
        Stage := 9;
        if Image.UserValue = 0 then
        begin
          Image.UserValue := Image.LocalPosition.X + Image.ClientSize.X div 2;
          Image.UserIndex := Image.LocalPosition.Y + Image.ClientSize.Y div 2;
        end;
        Stage := 10;
        if Item = nil then
        begin
          Image.SetActive(False);
          Image.SetImagePath('');
          GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'Set').SetActive(False);
        end
        else
        begin
          Image.SetActive(True);
          Image.SetImagePath('GI,' + GetShopItemIconName(Item) + 'i');
          Image.SetImageKindX(image_x_center);
          Image.SetImageKindY(image_y_center);
          with GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'Set') as TImageGI do
          begin
            SetActive(TEquipment(Item).HasMicroModule);
            if Active then ImageSourcePath := 'GI,' + GetMicroModuleBitmapResourceName(TEquipment(Item).MicroModuleIndex - 1) + 'Set';
          end;
        end;
        Stage := 11;
        if AnimItem and (Item <> nil) then
        begin
          Stage := 12;
          with GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'anim') as TgaiGI do
          begin
            UserData := Integer(Image);
            SetPosition(Image.LocalPosition);
            SetImagePath(GetShopItemIconName(Item) + 'a');
            SequenceIndex := 0;
            SetActive(False);
            Stage := 13;
            if UserState <> 0 then
            begin
              Image.SetActive(False);
              UpdateAutoGeometry;
              SetSequenceFrame(Min(Cardinal(UserState), SequenceFrameCount - 1));
              SetActive(True);
              StopAutoPlayback;
            end;
            Stage := 14;
          end;
        end
        else
        begin
          Stage := 15;
          GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'anim').SetActive(False);
        end;
        Stage := 16;
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'a').SetActive(False);
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'n').SetActive((Item <> nil) and ShipToInspect.IsEquipmentUsable(TEquipment(Item)));
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'b').SetActive((Item <> nil) and not ShipToInspect.IsEquipmentUsable(TEquipment(Item)));
        GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'Ex').SetActive(False);
        Stage := 17;
      end;
      if EquipmentSlotLayouts[I].ItemType = weapon_category then
      begin
        Stage := 18;
        for SlotIndex := SlotCount to 4 do
          (GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'z') as TZoneGI).ZoneMouseDownCallback := nil;
      end
      else
      begin
        Stage := 19;
        for SlotIndex := SlotCount to 0 do
          (GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'z') as TZoneGI).ZoneMouseDownCallback := nil;
      end;
    end;
    Stage := 20;
    SlotCount := ShipToInspect.GetSlotCountForItemType(item_custom_artefact);
    for SlotIndex := 0 to SlotCount - 1 do
    begin
      Stage := 21;
      Artefact := ShipToInspect.FindEquippedItemInSlot(item_custom_artefact, SlotIndex) as TArtefact;
      CanBoost := (Artefact <> nil) and (Artefact.BrokenFlag = 0) and ShipToInspect.CanBoostArtefact(Artefact.ItemType, nil, False);
      Stage := 22;
      GetByName('Art' + IntToStr(SlotIndex) + 'n').SetActive((Artefact <> nil) and (Artefact.BrokenFlag = 0) and not CanBoost);
      GetByName('Art' + IntToStr(SlotIndex) + 'b').SetActive((Artefact <> nil) and Boolean(Artefact.BrokenFlag) and not CanBoost);
      GetByName('Art' + IntToStr(SlotIndex) + 'a').SetActive(False);
      GetByName('Art' + IntToStr(SlotIndex) + 'i').SetActive(Artefact <> nil);
      GetByName('Art' + IntToStr(SlotIndex) + 'Ex').SetActive(CanBoost);
      GetByName('Art' + IntToStr(SlotIndex) + 'off').SetActive(False);
      Stage := 23;
      with GetByName('Art' + IntToStr(SlotIndex) + 'i') as TImageGI do
      begin
        Stage := 24;
        if Artefact = nil then ImageSourcePath := ''
        else
        begin
          ImageSourcePath := 'GI,' + GetShopItemIconName(Artefact) + 's';
          KindX := image_x_center;
          KindY := image_y_center;
        end;
      end;
      Stage := 25;
      with GetByName('Art' + IntToStr(SlotIndex) + 'z') as TZoneGI do SetActive(Artefact <> nil);
    end;
    Stage := 26;
    for SlotIndex := SlotCount to DefaultHullSlotCounts[slot_artefact] - 1 do
    begin
      GetByName('Art' + IntToStr(SlotIndex) + 'n').SetActive(False);
      GetByName('Art' + IntToStr(SlotIndex) + 'b').SetActive(False);
      GetByName('Art' + IntToStr(SlotIndex) + 'a').SetActive(False);
      GetByName('Art' + IntToStr(SlotIndex) + 'i').SetActive(False);
      GetByName('Art' + IntToStr(SlotIndex) + 'z').SetActive(False);
      GetByName('Art' + IntToStr(SlotIndex) + 'Ex').SetActive(False);
      GetByName('Art' + IntToStr(SlotIndex) + 'off').SetActive(True);
    end;
    Stage := 27;
    for I := 0 to VisibleCargoCount - 1 do
      with GetByName('S_' + IntToStr(I) + 'i') as TImageGI do
        if not GetCargoEntry(CargoOffset + I, CargoKind, Item) then SetImagePath('')
        else if CargoKind in [item_food..item_narcotics] then
        begin
          SetImagePath('GI,' + GetItemTypeBitmapPath(CargoKind));
          SetImageKindX(image_x_center);
          SetImageKindY(image_y_center);
        end
        else
        begin
          SetImagePath('GI,' + GetShopItemIconName(Item) + 's');
          SetImageKindX(image_x_center);
          SetImageKindY(image_y_center);
        end;
    Stage := 28;
    BuildAdditionalInfo;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TfScaner.Update, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $517DB0 }

{ @routine $51958C TfScaner_ScrollCargoLeft }
procedure TfScaner.ScrollCargoLeft(Sender: TObjectGI);
begin
  Dec(CargoOffset);
  Update;
end;
{ @end $51958C }

{ @routine $519598 TfScaner_ScrollCargoRight }
procedure TfScaner.ScrollCargoRight(Sender: TObjectGI);
begin
  Inc(CargoOffset);
  Update;
end;
{ @end $519598 }

{ @routine $5195A4 TfScaner_MainPanelKeyDown }
procedure TfScaner.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if (Key = VK_ESCAPE) or ((Key = Ord('I')) and not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT)) then
  begin
    AuxRenderBuffer.Clear;
    RequestedScreenId := ScannerReturnScreenId;
    RequestClose(1);
  end
  else if Key = VK_LEFT then
  begin
    if CargoOffset > 0 then
    begin
      Dec(CargoOffset);
      Update;
    end;
  end
  else if Key = VK_RIGHT then
    if CargoOffset + VisibleCargoCount <= CargoEntryCount then
    begin
      Inc(CargoOffset);
      Update;
    end;
end;
{ @end $5195A4 }

{ @routine $519644 TfScaner_ProcessMouseWheel }
procedure TfScaner.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then
  begin
    if CargoOffset > 0 then
    begin
      Dec(CargoOffset);
      Update;
    end;
  end
  else if (Delta = -WHEEL_DELTA) and (CargoOffset + VisibleCargoCount <= CargoEntryCount) then
  begin
    Inc(CargoOffset);
    Update;
  end;
end;
{ @end $519644 }

{ @routine $519690 TfScaner_MainPanelMouseUp }
procedure TfScaner.MainPanelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if PanelSlideTimer <> 0 then Exit;
  if (GetByName('PanelLeft') as TImageGI).HitTestPixel(Point) then Exit;
  if (GetByName('RightOpen') as TImageGI).HitTestPixel(Point) then Exit;
  if (GetByName('S_Left') as TGraphButtonGI).ContainsPoint(Point) then Exit;
  if (GetByName('S_Right') as TGraphButtonGI).ContainsPoint(Point) then Exit;
  if (GetByName('GateZone') as TZoneGI).ContainsPoint(Point) then Exit;
  if GetByName('CenterNormalImage').ContainsPoint(Point) then Exit;
  if GetByName('CenterDamageImage').ContainsPoint(Point) then Exit;
  CloseClicked(nil);
end;
{ @end $519690 }

{ @routine $51986C TfScaner_UpdateItemHover }
procedure TfScaner.UpdateItemHover;
var
  Item: TItem;
  CargoKind: TItemType;
  I, SlotIndex, SlotCount: Integer;
  Found: Boolean;
  Animation: TgaiGI;
  CenterX, CenterY: Boolean;
  Window: TWindowGI;
  Position, AnchorSize: TPoint;
begin
  Found := False;
  Animation := nil;
  Position := Classes.Point(0, 0);
  AnchorSize := Classes.Point(0, 0);
  CenterX := False;
  CenterY := False;
  if not Found then
  begin
    SlotCount := ShipToInspect.GetSlotCountForItemType(item_custom_artefact);
    for SlotIndex := 0 to SlotCount - 1 do
    begin
      Item := ShipToInspect.FindEquippedItemInSlot(item_custom_artefact, SlotIndex);
      if Item <> nil then
        with ArtefactZones[SlotIndex] do
          if HitTest(GetCursorPoint) then
          begin
            CenterX := True;
            Position := Classes.Point(HitTestBounds.Left + ClientSize.X div 2, HitTestBounds.Top + ClientSize.Y);
            ShowItemInfo(Item);
            Found := True;
            Break;
          end;
    end;
  end;
  if not Found then
    for I := 0 to 7 do
    begin
      SlotCount := ShipToInspect.GetSlotCountForItemType(EquipmentSlotLayouts[I].ItemType);
      for SlotIndex := 0 to SlotCount - 1 do
      begin
        Item := ShipToInspect.FindEquippedItemInSlot(EquipmentSlotLayouts[I].ItemType, SlotIndex);
        if Item = nil then Continue;
        with GetByName('S_' + EquipmentSlotLayouts[I].Name + '_' + IntToStr(SlotIndex) + 'z') as TZoneGI do
          if HitTest(GetCursorPoint) then
          begin
            CenterX := True;
            Position := Classes.Point(HitTestBounds.Left + ClientSize.X div 2, HitTestBounds.Top + ClientSize.Y);
            ShowItemInfo(Item);
            Found := True;
            if AnimItem then Animation := EquipmentAnimations[I, SlotIndex];
            Break;
          end;
      end;
    end;
  if not Found then
    with GetByName('S_Hull_0z') as TZoneGI do
      if HitTest(GetCursorPoint) then
      begin
        CenterX := True;
        Position := Classes.Point(HitTestBounds.Left + ClientSize.X div 2, HitTestBounds.Top + ClientSize.Y);
        ShowItemInfo(ShipToInspect.GetHull);
        Found := True;
      end;
  if not Found then
    for I := 0 to VisibleCargoCount - 1 do
      with GetByName('S_' + IntToStr(I) + 'z') as TZoneGI do
        if HitTest(GetCursorPoint) then
        begin
          CenterX := True;
          Position := Classes.Point(HitTestBounds.Left + ClientSize.X div 2, HitTestBounds.Top + ClientSize.Y);
          if GetCargoEntry(CargoOffset + I, CargoKind, Item) then
          begin
            if CargoKind in [item_food..item_narcotics] then ShowGoodsInfo(CargoKind) else ShowItemInfo(Item);
            Found := True;
            Break;
          end;
        end;
  if (Position.X <> 0) or (Position.Y <> 0) then
  begin
    if ItemInfoWindow.Active then Window := ItemInfoWindow
    else Window := GetByName('InfoHull') as TWindowGI;
    if DynamicTipsPos then
    begin
      if CenterX then Position.X := Position.X - Window.ClientSize.X div 2;
      if Position.X < 0 then Position.X := Abs(Position.X) - Window.ClientSize.X;
      if CenterY then
      begin
        Position.Y := Position.Y - Window.ClientSize.Y div 2;
        if Integer(GameScreenHeight) < Window.ClientSize.Y + Position.Y + 10 then Position.Y := Integer(GameScreenHeight) - Window.ClientSize.Y - 10;
      end
      else if Window.ClientSize.Y + Position.Y + 10 > Integer(GameScreenHeight) then Position.Y := Position.Y - AnchorSize.Y - Window.ClientSize.Y;
      Window.SetPosition(Position);
    end
    else Window.SetPosition(Classes.Point(10, 10));
  end;
  if not Found and (HideItemTimer = 0) then ShowItemInfo(nil);
  if (Animation <> HoveredItemAnimation) and (HoveredItemAnimation <> nil) then
  begin
    HoveredItemAnimation.StopAutoPlayback;
    HoveredItemAnimation.UserState := HoveredItemAnimation.SequenceFrame;
    HoveredItemAnimation := nil;
  end;
  if (Animation <> HoveredItemAnimation) and (Animation <> nil) then
  begin
    HoveredItemAnimation := Animation;
    HoveredItemAnimation.UpdateAutoGeometry;
    HoveredItemAnimation.SetSequenceFrame(Min(Cardinal(HoveredItemAnimation.UserState), HoveredItemAnimation.SequenceFrameCount - 1));
    HoveredItemAnimation.SetActive(True);
    HoveredItemAnimation.RestartPlayback;
    TObjectGI(HoveredItemAnimation.UserData).SetActive(False);
  end;
end;
{ @end $51986C }

{ @routine $519E84 TfScaner_AdvanceItemHover }
procedure TfScaner.AdvanceItemHover(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  UpdateItemHover;
end;
{ @end $519E84 }

{ @routine $519E8C TfScaner_HideItemInfo }
procedure TfScaner.HideItemInfo(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  HoveredItem := nil;
  if HideItemTimer <> 0 then
  begin
    CancelCallbackTimer(HideItemTimer);
    HideItemTimer := 0;
  end;
  GetByName('PII').SetActive(False);
  GetByName('InfoHull').SetActive(False);
  (GetByName('InfoText') as TLabelGI).Text := '';
  (GetByName('InfoSize') as TLabelGI).Text := '';
  (GetByName('InfoPrice') as TLabelGI).Text := '';
end;
{ @end $519E8C }

{ @routine $519FA0 TfScaner_ShowItemInfo }
procedure TfScaner.ShowItemInfo(Item: TObject);
const
  DurableTypes = [Low(TItemType)..High(TItemType)] - [item_food..item_narcotics, item_custom_artefact_no_wear, artefact_transmitter..artefact_tranclucator, artefact_black_hole..artefact_artefactor, item_hull, item_nodes..item_fuel_container, item_treasure_map..item_stackable_misc];
var
  Equipment: TEquipment;
  Portrait: WideString;
  BarWidth, CapWidth, MinimumWidth: Integer;
begin
  Equipment := Item as TEquipment;
  if Equipment = nil then
  begin
    HoveredItem := nil;
    if HideItemTimer <> 0 then
    begin
      CancelCallbackTimer(HideItemTimer);
      HideItemTimer := 0;
    end;
    HideItemTimer := ScheduleCallbackTimer(100, 99999, HideItemInfo);
  end
  else if TItem(Item) <> HoveredItem then
  begin
    HoveredItem := TItem(Item);
    if HideItemTimer <> 0 then
    begin
      CancelCallbackTimer(HideItemTimer);
      HideItemTimer := 0;
    end;
    if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    begin
      if TItem(Item).ScriptItem <> nil then TScriptItem(TItem(Item).ScriptItem).RunActionCode(event_show_item_info, ShipToInspect, nil, nil, 0);
      if Item is TEquipmentWithActCode then RunItemConfigActionCode(TItem(Item), event_show_item_info, ShipToInspect, nil, nil, 0);
    end;
    if (TItem(Item).ItemType = item_hull) and (ShipToInspect.TypeId <> ship_tranclucator) and (ShipToInspect.TypeId <> ship_dominator) then
      if not CompactHullInfo then
      begin
        EquipmentShopScreen.RefreshHullInfo(Self, Item as THull, Equipment.GetInfoText(TextHighlightColorTag, ShipToInspect), True);
        ItemInfoWindow.SetActive(False);
        Portrait := ShipToInspect.GetShipPortraitImagePath;
        if Portrait <> '' then
          with GetByName('InfoHullImage') as TImageGI do
          begin
            SetActive(True);
            SetImagePath('GraphBuf');
            with GraphBufControl do
            begin
              SourceHasPerPixelAlpha := True;
              LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(Portrait, 1, ','), GraphBuf);
              if GraphBuf.Width >= GraphBuf.Height then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / GraphBuf.Width * GraphBuf.Height), 5)
              else GraphBuf.RescaleRgba(Round(ClientSize.Y / GraphBuf.Height * GraphBuf.Width), ClientSize.Y, 5);
            end;
            SetImageKindX(image_x_center);
            SetImageKindY(image_y_center);
            SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
          end;
        Exit;
      end;
    ItemInfoWindow.SetActive(True);
    GetByName('InfoHull').SetActive(False);
    with GetByName('InfoImage') as TImageGI do
    begin
      SetActive(Equipment.ItemType <> item_hull);
      if Active then
      begin
        ImageSourcePath := 'GI,' + GetShopItemIconName(Equipment) + 's';
        KindX := image_x_center;
        KindY := image_y_center;
        SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
      end;
    end;
    with GetByName('InfoImage2') as TGraphBufGI do
    begin
      SetActive(Equipment.ItemType = item_hull);
      if Active then
      begin
        Portrait := ShipToInspect.GetShipPortraitImagePath;
        SetActive(Portrait <> '');
        if Active then
        begin
          SourceHasPerPixelAlpha := True;
          LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(Portrait, 1, ','), GraphBuf);
          if GraphBuf.Width >= GraphBuf.Height then
            GraphBuf.RescaleRgba(ClientSize.X - 5, Round((ClientSize.X - 5) / GraphBuf.Width * GraphBuf.Height), 5)
          else GraphBuf.RescaleRgba(Round((ClientSize.Y - 5) / GraphBuf.Height * GraphBuf.Width), ClientSize.Y - 5, 5);
          SetImageKindX(image_x_center);
          SetImageKindY(image_y_center);
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
        end;
      end;
    end;
    (GetByName('InfoName') as TLabelGI).Text := '';
    (GetByName('InfoName') as TLabelGI).Text := WrapTextInColor(Equipment.GetDisplayName, InfoNameColorTag);
    (GetByName('InfoText') as TLabelGI).Text := Equipment.GetInfoText(TextHighlightColorTag, ShipToInspect);
    (GetByName('InfoSize') as TLabelGI).Text := IntToStr(Equipment.Weight);
    (GetByName('InfoPrice') as TLabelGI).Text := IntToStr(Equipment.Cost);
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
      if Equipment is THull then BarWidth := Round(Sqrt(Equipment.Weight / HullBaseSize / Max(0.1, Equipment.GetFragilityFactor([]))) * 64)
      else BarWidth := Round(64 / Max(0.1, Equipment.GetFragilityFactor([])));
      BarWidth := Min(192, Max(32, BarWidth));
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
    ShipScreen.LayoutItemInfo(ItemInfoWindow, ItemNameLabel, ItemDescriptionLabel, True, True, MinimumWidth);
    ItemSizeLabel.SetPosition(Classes.Point(ShipScreen.ItemSizeLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemSizeLabelPosition.Y));
    ItemPriceLabel.SetPosition(Classes.Point(ShipScreen.ItemPriceLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemPriceLabelPosition.Y));
    ItemRaceImage.SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ShipScreen.ItemRaceImagePosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
  end;
end;
{ @end $519FA0 }

{ @routine $51AD34 TfScaner_ShowGoodsInfo }
procedure TfScaner.ShowGoodsInfo(ItemType: TItemType);
begin
  HoveredItem := nil;
  if HideItemTimer <> 0 then
  begin
    CancelCallbackTimer(HideItemTimer);
    HideItemTimer := 0;
  end;
  GetByName('PII').SetActive(True);
  GetByName('InfoHull').SetActive(False);
  GetByName('InfoImage2').SetActive(False);
  with GetByName('InfoImage') as TImageGI do
  begin
    SetActive(True);
    ImageSourcePath := 'GI,' + GetItemTypeBitmapPath(ItemType);
    KindX := image_x_center;
    KindY := image_y_center;
    SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
  end;
  (GetByName('InfoName') as TLabelGI).Text := WrapTextInColor(GoodsMarket[Ord(ItemType)].DisplayName, InfoNameColorTag);
  (GetByName('InfoText') as TLabelGI).Text := LocalizedText('Items.Goods.Text.' + IntToStr(Ord(ItemType) + 1));
  (GetByName('InfoSize') as TLabelGI).Text := IntToStr(ShipToInspect.CargoGoods[Ord(ItemType)].Count);
  if GetPlayer = ShipToInspect then
    (GetByName('InfoPrice') as TLabelGI).Text := IntToStr(ShipToInspect.CargoGoods[Ord(ItemType)].TotalCost)
  else (GetByName('InfoPrice') as TLabelGI).Text := '-';
  with GetByName('EmRace') as TImageGI do
  begin
    ImageSourcePath := GetFactionEmblemPath(ShipToInspect.GetFactionNameKey);
    KindX := image_x_center;
    KindY := image_y_center;
  end;
  GetByName('InfoDurable').Parent.Parent.SetActive(False);
  ShipScreen.LayoutItemInfo(ItemInfoWindow, ItemNameLabel, ItemDescriptionLabel, True, True, 0);
  ItemSizeLabel.SetPosition(Classes.Point(ShipScreen.ItemSizeLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemSizeLabelPosition.Y));
  ItemPriceLabel.SetPosition(Classes.Point(ShipScreen.ItemPriceLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemPriceLabelPosition.Y));
  ItemRaceImage.SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ShipScreen.ItemRaceImagePosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
end;
{ @end $51AD34 }

{ @routine $51B474 TfScaner_UpdateSkills }
procedure TfScaner.UpdateSkills;
var
  I: Integer;
  // @nested $51B248 UpdateOne
  procedure UpdateOne(Index, BaseLevel, EffectiveLevel: Integer); // @addr $51B248
  var
    Step, Gap, Bottom: Integer;
  begin
    Gap := 2;
    Step := 5 + Gap;
    Bottom := 43;
    with SkillImages[Index] do
    begin
      SetActive(Min(BaseLevel, EffectiveLevel) > 0);
      SetSize(Classes.Point(ClientSize.X, Step * Min(BaseLevel, EffectiveLevel)));
      SetPosition(Classes.Point(LocalPosition.X, SkillImageRestTop[Index] + Bottom - ClientSize.Y));
      SetImageKindY(image_y_bottom);
    end;
    if BaseLevel < EffectiveLevel then
    begin
      with SkillPanels[Index] do
      begin
        SetSize(Classes.Point(ClientSize.X, (EffectiveLevel - BaseLevel) * Step));
        SetPosition(Classes.Point(LocalPosition.X, SkillImageRestTop[Index] + Bottom - Step * EffectiveLevel));
      end;
      with SkillPositiveImages[Index] do
      begin
        SetPosition(Classes.Point(LocalPosition.X, -Step * (6 - EffectiveLevel) - 1));
        SetActive(True);
      end;
    end
    else SkillPositiveImages[Index].SetActive(False);
    if BaseLevel > EffectiveLevel then
    begin
      with SkillPanels[Index] do
      begin
        SetSize(Classes.Point(ClientSize.X, (BaseLevel - EffectiveLevel) * Step));
        SetPosition(Classes.Point(LocalPosition.X, SkillImageRestTop[Index] + Bottom - Step * BaseLevel));
      end;
      with SkillNegativeImages[Index] do
      begin
        SetPosition(Classes.Point(LocalPosition.X, -Step * (6 - BaseLevel) - 1));
        SetActive(True);
      end;
    end
    else SkillNegativeImages[Index].SetActive(False);
  end;
begin
  with FreeSkillPointsLabel do SetText(IntToStr(ShipToInspect.FreeExperience));
  UpdateOne(0, ShipToInspect.GetBaseSkillLevel(skill_accuracy), ShipToInspect.GetEffectiveSkillLevel(skill_accuracy));
  UpdateOne(1, ShipToInspect.GetBaseSkillLevel(skill_maneuverability), ShipToInspect.GetEffectiveSkillLevel(skill_maneuverability));
  UpdateOne(2, ShipToInspect.GetBaseSkillLevel(skill_technical), ShipToInspect.GetEffectiveSkillLevel(skill_technical));
  UpdateOne(3, ShipToInspect.GetBaseSkillLevel(skill_trading), ShipToInspect.GetEffectiveSkillLevel(skill_trading));
  UpdateOne(4, ShipToInspect.GetBaseSkillLevel(skill_charisma), ShipToInspect.GetEffectiveSkillLevel(skill_charisma));
  UpdateOne(5, ShipToInspect.GetBaseSkillLevel(skill_leadership), ShipToInspect.GetEffectiveSkillLevel(skill_leadership));
  for I := 0 to 5 do SkillButtons[I].SetActive(False);
end;
{ @end $51B474 }

{ @routine $51B640 TfScaner_CreateAdditionalInfoIcon }
function TfScaner.CreateAdditionalInfoIcon(Sender: TLabelGI; Item: PFontObjectEC): TObjectGI;
begin
  Result := TImageGI.Create(Sender);
  with Result as TImageGI do
  begin
    ImageSourcePath := 'GI,Bm.FormShip2.' + GiResourceSuffix + 'AI_' + IntToStr(Cardinal(Item.ObjectId));
    KindX := image_x_left;
  end;
end;
{ @end $51B640 }

{ @routine $51BA6C TfScaner_BuildAdditionalInfo }
procedure TfScaner.BuildAdditionalInfo;
var
  Panel: TPanelScrollBarGI;
  OffsetY, I, IconKind: Integer;
  Info: PCustomShipInfo;
  Block: TBlockParEC;
  Description, Caption: WideString;
  // @nested $51B73C AddRow
  procedure AddRow(IconId: Integer; Caption, Help: WideString; Data: Integer); // @addr $51B73C @calls "0x0051BB2D,0x0051BDCE"
  begin
    with TLabelGI.Create(Panel) do
    begin
      SetFontName(SmallFontName);
      SetPosition(Classes.Point(0, OffsetY));
      SetSize(Classes.Point(Panel.ClientSize.X, 1));
      SetTextAlignX(text_x_left);
      SetTextAlignY(text_y_fit_height);
      SetWordWrapEnabled(True);
      if GiResourceVariant = 1 then
        Text := '<Object=' + IntToStr(IconId) + ',' + IntToStr(21) + ',' + IntToStr(17) + ',0>' + ReplaceAllWideString(Caption, '<br>', #13#10)
      else
        Text := '<Object=' + IntToStr(IconId) + ',' + IntToStr(25) + ',' + IntToStr(20) + ',0>' + ReplaceAllWideString(Caption, '<br>', #13#10);
      SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
      SetTextAlignY(text_y_font_center);
      SetPositionModeW(True);
      CreateEmbeddedControl := CreateAdditionalInfoIcon;
      MouseEnterCallback := ShowPropertyInfo;
      MouseLeaveCallback := HidePropertyInfo;
      UserValue := -1;
      UserIndex := IconId;
      UserData := Data;
      HelpText := Help;
      Inc(OffsetY, ClientSize.Y);
      Panel.VerticalScrollBar.SetSmallChange(GetLineHeight);
    end;
  end;
begin
  Panel := GetByName('PanelAddInfo') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  Panel.SetScrollOffset(Classes.Point(0, 0));
  Panel.SetDragScrollingEnabled(True);
  OffsetY := 0;
  for I := 1 to 24 do
    if ShipToInspect.IsHealthEffectActive(I) then
    begin
      if I < 13 then IconKind := 1 else IconKind := 2;
      AddRow(IconKind, CaptainHealthDefinitions[I].Name,
        CaptainHealthDefinitions[I].Name + '~' + CaptainHealthDefinitions[I].Text, 0);
    end;
  for I := 0 to ShipToInspect.CustomShipInfos.Count - 1 do
  begin
    Info := ShipToInspect.CustomShipInfos[I];
    if Info.DeleteQueued then Continue;
    Block := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').GetBlock(Info.TypeName);
    Description := Info.Description;
    if Description = '' then Description := LocalizedColorText('ShipInfo.AddInfo.CustomInfos.' + Info.TypeName + '.Description');
    if Description = 'NoShow' then Continue;
    ReplaceTextToken(Description, '<Data1>', IntToStr(Info.Data[1]), TextHighlightColorTag);
    ReplaceTextToken(Description, '<Data2>', IntToStr(Info.Data[2]), TextHighlightColorTag);
    ReplaceTextToken(Description, '<Data3>', IntToStr(Info.Data[3]), TextHighlightColorTag);
    ReplaceTextToken(Description, '<TextData1>', Info.TextData1, TextHighlightColorTag);
    ReplaceTextToken(Description, '<TextData2>', Info.TextData2, TextHighlightColorTag);
    ReplaceTextToken(Description, '<TextData3>', Info.TextData3, TextHighlightColorTag);
    Caption := Block.GetParam('Name');
    ReplaceTextToken(Caption, '<Data1>', IntToStr(Info.Data[1]), TextHighlightColorTag);
    ReplaceTextToken(Caption, '<Data2>', IntToStr(Info.Data[2]), TextHighlightColorTag);
    ReplaceTextToken(Caption, '<Data3>', IntToStr(Info.Data[3]), TextHighlightColorTag);
    ReplaceTextToken(Caption, '<TextData1>', Info.TextData1, TextHighlightColorTag);
    ReplaceTextToken(Caption, '<TextData2>', Info.TextData2, TextHighlightColorTag);
    ReplaceTextToken(Caption, '<TextData3>', Info.TextData3, TextHighlightColorTag);
    AddRow(StrToInt(AnsiString(Block.GetParam('Icon'))), Caption,
      Caption + '~' + Description, Integer(Info));
  end;
  Panel.UpdateScrollRanges;
  Panel.VerticalScrollBar.SetActive(Panel.ClientSize.Y < OffsetY);
  if Panel.VerticalScrollBar.Active then
  begin
    Panel.VerticalScrollBar.SetLargeChange(Panel.ClientSize.Y);
    Panel.VerticalScrollBar.SetPageSize(Panel.ClientSize.Y);
  end;
end;
{ @end $51BA6C }

{ @routine $51C094 TfScaner_ExecuteUiCode }
procedure TfScaner.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not ExitScreenLoop and (TurnCalculationPhase in [turn_idle, turn_galaxy_finished, turn_player_star_finished, turn_player_star_prepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10004);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20004);
  end;
end;
{ @end $51C094 }

{ @routine $51C0EC TfScaner_SelectMusic }
procedure TfScaner.SelectMusic;
begin
  if GetPlayer = nil then
  begin
    MusicManager.PlayCategory('Base');
    Exit;
  end;
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
{ @end $51C0EC }

end.
