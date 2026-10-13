unit fRewards;

interface

uses GI_MessageLoop, GI_PanelScrollBar, aShip, Types;

type
  TfRewards = class(TMessageLoopGI) // @size 0xE4
  public
    AwardsPanel: TPanelScrollBarGI; // @offset $D0
    Ship: TShip; // @offset $D4 Borrowed from the shared inspected-ship selection.
    DraggedAward: TObjectGI; // @offset $D8
    HoveredAwardId: Integer; // @offset $DC -1 when no medal is under the pointer.
    ReadOnly: Boolean; // @offset $E0

    procedure CloseClicked(Sender: TObjectGI); // @addr $5D0770
    function CanEditAwards: Boolean; // @addr $5D07A0
    function GetAwardImagePath(AwardId: Integer): WideString; // @addr $5D07C4
    procedure PlatformMouseEnter(Sender: TObjectGI); // @addr $5D08E8
    procedure AwardMouseEnter(Sender: TObjectGI); // @addr $5D0B44
    procedure AwardMouseLeave(Sender: TObjectGI); // @addr $5D0B58
    procedure ClearHighlight(Sender: TObjectGI); // @addr $5D0B6C
    procedure AwardMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5D0D18
    procedure IncreaseVisibleCount(Sender: TObjectGI); // @addr $5D0F14
    procedure DecreaseVisibleCount(Sender: TObjectGI); // @addr $5D0F3C
    procedure RefreshVisibleCount; // @addr $5D0F58
    procedure BuildAwardControls; // @addr $5D1070
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5D157C
    procedure OnOpen; override; // @addr 0x005D0548
    procedure OnClose; override; // @addr 0x005D0758
    procedure ProcessCallbackTimers; override; // @addr 0x005D1550
    procedure SelectMusic; override; // @addr 0x005D1684
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x005D1AA0
    procedure InitializeLayout; override; // @addr 0x005D035C
    procedure UpdateActionCursor(CanTake: Boolean); override; // @addr 0x005D1484
  end;

function RunRewards(ParentLoop: TMessageLoopGI; ReadOnly: Boolean): Boolean; // @addr $5D19BC

implementation

uses aGalaxyStruct, Classes, SysUtils, Math, Windows, EC_Struct, GI_Panel, GI_ScrollBar,
  GI_GraphBuf, GI_GraphButton, GI_Image, GI_Label, GR_Main, GR_Sound, GR_Music,
  Globals, GlobalsV, aPlayer, aNormalShip, aConst, aPlanet, aMyFunction, fStarMap;


{ @routine $5D035C TfRewards_InitializeLayout }
procedure TfRewards.InitializeLayout;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fRewards... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('RewardPanel') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
  end;
  AppendLogLineThreadSafe('ok');
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  (GetByName('ButExit') as TGraphButtonGI).UpCallback := CloseClicked;
  AwardsPanel := GetByName('PTable') as TPanelScrollBarGI;
end;
{ @end $5D035C }

{ @routine $5D0548 TfRewards_OnOpen }
procedure TfRewards.OnOpen;
begin
  inherited OnOpen;
  Ship := AwardSubject as TShip;
  if Ship.AwardVisibleCount = 0 then Ship.AwardVisibleCount := Ship.AwardIds.Count;
  CaptureScreenBackground(False, 0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  with GetByName('PTable') as TPanelScrollBarGI do
  begin
    ScrollAxis := psaVertical;
    VerticalScrollBar.SetSmallChange(Round(ClientSize.Y / 50));
    VerticalScrollBar.SetLargeChange(ClientSize.Y);
    VerticalScrollBar.SetPageSize(ClientSize.Y);
  end;
  with GetByName('RewardCount') as TLabelGI do SetActive(CanEditAwards);
  with GetByName('Add') as TGraphButtonGI do
  begin
    DownCallback := IncreaseVisibleCount;
    SetActive(CanEditAwards);
  end;
  with GetByName('Sub') as TGraphButtonGI do
  begin
    DownCallback := DecreaseVisibleCount;
    SetActive(CanEditAwards);
  end;
  AwardsPanel.SetScrollOffset(Classes.Point(0, 0));
  BuildAwardControls;
  ClearHighlight(nil);
  DraggedAward := nil;
  HoveredAwardId := -1;
  UpdateActionCursor(False);
  RefreshVisibleCount;
end;
{ @end $5D0548 }

{ @routine $5D0758 TfRewards_OnClose }
procedure TfRewards.OnClose;
begin
  AwardsPanel.FreeOwnedChildren;
  inherited OnClose;
end;
{ @end $5D0758 }

{ @routine $5D0770 TfRewards_CloseClicked }
procedure TfRewards.CloseClicked(Sender: TObjectGI);
begin
  if GetPlayer = Ship then RequestedScreenId := screenShip
  else RequestedScreenId := screenScanner;
  RequestClose(1);
end;
{ @end $5D0770 }

{ @routine $5D07A0 TfRewards_CanEditAwards }
function TfRewards.CanEditAwards: Boolean;
begin
  Result := not ReadOnly and (GetPlayer = Ship);
end;
{ @end $5D07A0 }

{ @routine $5D07C4 TfRewards_GetAwardImagePath }
function TfRewards.GetAwardImagePath(AwardId: Integer): WideString;
begin
  if AwardId < 10 then Result := 'GI,Bm.FormRewards.' + GiResourceSuffix + '_0' + IntToStr(AwardId)
  else Result := 'GI,Bm.FormRewards.' + GiResourceSuffix + '_' + IntToStr(AwardId);
end;
{ @end $5D07C4 }

{ @routine $5D08E8 TfRewards_PlatformMouseEnter }
procedure TfRewards.PlatformMouseEnter(Sender: TObjectGI);
var
  Obj: TObjectGI;
  Platform: TImageGI;
  AwardId: Integer;
begin
  Platform := TImageGI(Sender.UserValue);
  AwardId := Sender.UserIndex;
  with GetByName('InfoZag') as TLabelGI do
    if AwardId <> 255 then Text := (Ship as TNormalShip).GetAwardInfo(AwardId).Name else Text := '';
  with GetByName('Info') as TLabelGI do
    if AwardId <> 255 then Text := (Ship as TNormalShip).GetAwardInfo(AwardId).Text else Text := '';
  Obj := AwardsPanel.FirstChild;
  while Obj <> nil do
  begin
    if Obj is TImageGI then
      with TImageGI(Obj) do
        if GetImagePath = 'GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformA' then
          SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformN');
    Obj := Obj.NextSibling;
  end;
  Platform.SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformA');
  UpdateActionCursor(False);
end;
{ @end $5D08E8 }

{ @routine $5D0B44 TfRewards_AwardMouseEnter }
procedure TfRewards.AwardMouseEnter(Sender: TObjectGI);
begin
  HoveredAwardId := Sender.UserIndex;
  PlatformMouseEnter(Sender);
end;
{ @end $5D0B44 }

{ @routine $5D0B58 TfRewards_AwardMouseLeave }
procedure TfRewards.AwardMouseLeave(Sender: TObjectGI);
begin
  HoveredAwardId := -1;
  UpdateActionCursor(False);
end;
{ @end $5D0B58 }

{ @routine $5D0B6C TfRewards_ClearHighlight }
procedure TfRewards.ClearHighlight(Sender: TObjectGI);
var Obj: TObjectGI;
begin
  HoveredAwardId := -1;
  with GetByName('InfoZag') as TLabelGI do Text := '';
  with GetByName('Info') as TLabelGI do Text := '';
  Obj := AwardsPanel.FirstChild;
  while Obj <> nil do
  begin
    if Obj is TImageGI then
      with TImageGI(Obj) do
        if GetImagePath = 'GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformA' then
          SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformN');
    Obj := Obj.NextSibling;
  end;
  UpdateActionCursor(False);
end;
{ @end $5D0B6C }

{ @routine $5D0D18 TfRewards_AwardMouseDown }
procedure TfRewards.AwardMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Temp: Integer;
begin
  if DraggedAward = nil then
  begin
    DraggedAward := Sender;
    (Sender as TImageGI).ImageSourcePath := '';
    SoundManager.PlaySound('Sound.SlotGet');
  end
  else
  begin
    Ship.AwardIds.Exchange(Sender.UserData, DraggedAward.UserData);
    Temp := Sender.UserIndex;
    Sender.UserIndex := DraggedAward.UserIndex;
    DraggedAward.UserIndex := Temp;
    Temp := TObjectGI(Sender.UserValue).UserIndex;
    TObjectGI(Sender.UserValue).UserIndex := TObjectGI(DraggedAward.UserValue).UserIndex;
    TObjectGI(DraggedAward.UserValue).UserIndex := Temp;
    with Sender as TImageGI do
    begin
      ImageSourcePath := GetAwardImagePath(Sender.UserIndex);
      SetSize(GetContentSize);
    end;
    with DraggedAward as TImageGI do
    begin
      ImageSourcePath := GetAwardImagePath(DraggedAward.UserIndex);
      SetSize(GetContentSize);
    end;
    DraggedAward := nil;
    SoundManager.PlaySound('Sound.SlotPut');
    PlatformMouseEnter(Sender);
  end;
  UpdateActionCursor(False);
end;
{ @end $5D0D18 }

{ @routine $5D0F14 TfRewards_IncreaseVisibleCount }
procedure TfRewards.IncreaseVisibleCount(Sender: TObjectGI);
begin
  if Ship.AwardVisibleCount < Ship.AwardIds.Count then Inc(Ship.AwardVisibleCount);
  RefreshVisibleCount;
end;
{ @end $5D0F14 }

{ @routine $5D0F3C TfRewards_DecreaseVisibleCount }
procedure TfRewards.DecreaseVisibleCount(Sender: TObjectGI);
begin
  if Ship.AwardVisibleCount > 0 then Dec(Ship.AwardVisibleCount);
  RefreshVisibleCount;
end;
{ @end $5D0F3C }

{ @routine $5D0F58 TfRewards_RefreshVisibleCount }
procedure TfRewards.RefreshVisibleCount;
begin
  (GetByName('RewardCount') as TLabelGI).Text := IntToStr(Ship.AwardVisibleCount);
  (GetByName('Sub') as TGraphButtonGI).SetDisabled(Ship.AwardVisibleCount <= 1);
  (GetByName('Add') as TGraphButtonGI).SetDisabled(Ship.AwardVisibleCount >= Ship.AwardIds.Count);
end;
{ @end $5D0F58 }

{ @routine $5D1070 TfRewards_BuildAwardControls }
procedure TfRewards.BuildAwardControls;
var
  I, Count, X, Y: Integer;
  Platform: TImageGI;
  AwardId: Byte;
begin
  AwardsPanel.FreeOwnedChildren;
  if Ship.AwardIds <> nil then Count := Max(10, Ship.AwardIds.Count) else Count := 10;
  if Count > 10 then Count := ((Count + 2) div 3) * 3;
  with TObjectGI.Create(AwardsPanel) do
  begin
    SetPosition(Classes.Point(0, 0));
    SetSize(Classes.Point(1, 1));
    SetPositionModeW(True);
  end;
  for I := 0 to Count - 1 do
  begin
    Platform := TImageGI.Create(AwardsPanel);
    Platform.SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformN');
    Platform.SetSize(Platform.GetContentSize);
    Platform.SetOrigin(HalfPoint(Platform.ClientSize));
    X := AwardsPanel.ClientSize.X div 3;
    X := X * (I mod 3) + (X - Platform.ClientSize.X div 2);
    Y := AwardsPanel.ClientSize.Y div 4;
    Y := Y * (I div 3) + (Y - Platform.ClientSize.Y div 2);
    Platform.SetPosition(Classes.Point(X, Y));
    Platform.SetPositionModeW(True);
    if (Ship.AwardIds <> nil) and (I < Ship.AwardIds.Count) then
    begin
      AwardId := Byte(Ship.AwardIds[I]);
      Platform.UserValue := Integer(Platform);
      Platform.UserIndex := AwardId;
      Platform.MouseEnterCallback := PlatformMouseEnter;
      Platform.MouseLeaveCallback := AwardMouseLeave;
    end
    else
    begin
      Platform.UserValue := 0;
      Platform.UserIndex := 255;
    end;
    if (Ship.AwardIds <> nil) and (I < Ship.AwardIds.Count) then
    begin
      AwardId := Byte(Ship.AwardIds[I]);
      with TImageGI.Create(AwardsPanel) do
      begin
        ImageSourcePath := GetAwardImagePath(AwardId);
        SetSize(GetContentSize);
        SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y));
        SetPositionModeW(True);
        SetPosition(Classes.Point(X, Y));
        UserValue := Integer(Platform);
        UserIndex := AwardId;
        UserData := I;
        MouseEnterCallback := AwardMouseEnter;
        MouseLeaveCallback := AwardMouseLeave;
        if CanEditAwards then LeftButtonDownCallback := AwardMouseDown
        else LeftButtonDownCallback := nil;
      end;
    end;
  end;
  AwardsPanel.MouseLeaveCallback := ClearHighlight;
  AwardsPanel.UpdateScrollRanges;
  AwardsPanel.SetVerticalScrollbarEnabled(Count > 10);
end;
{ @end $5D1070 }

{ @routine $5D1484 TfRewards_UpdateActionCursor }
procedure TfRewards.UpdateActionCursor(CanTake: Boolean);
begin
  if DraggedAward = nil then
  begin
    if (HoveredAwardId >= 0) and CanEditAwards then SetCursorByName('Take')
    else SetCursorByName('Main');
  end
  else SetCursorImage(GetAwardImagePath(DraggedAward.UserIndex), Classes.Point(16, 16));
end;
{ @end $5D1484 }

{ @routine $5D1550 TfRewards_ProcessCallbackTimers }
procedure TfRewards.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $5D1550 }

{ @routine $5D157C TfRewards_MainPanelKeyDown }
procedure TfRewards.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
  begin
    if (Key = VK_ESCAPE) or (Key = VK_RETURN) or (Key = Ord('R')) then CloseClicked(nil);
    with GetByName('PTable') as TPanelScrollBarGI do
    begin
      if Key = VK_UP then VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.SmallChange)
      else if Key = VK_DOWN then VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.SmallChange)
      else if Key = VK_PRIOR then VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.LargeChange)
      else if Key = VK_NEXT then VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.LargeChange);
    end;
  end;
end;
{ @end $5D157C }

{ @routine $5D1684 TfRewards_SelectMusic }
procedure TfRewards.SelectMusic;
begin
  if GetPlayer = nil then MusicManager.PlayCategory('Base')
  else if GetPlayer.IsOnPlanet then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
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
    else
    if GetPlayer.DockedTo.TypeId in [rstPirateBase, rstDominion] then
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
{ @end $5D1684 }

{ @routine $5D19BC RunRewards }
function RunRewards(ParentLoop: TMessageLoopGI; ReadOnly: Boolean): Boolean;
var
  State: TCursorStateGI;
begin
  ParentLoop.RootUiObject.OnModalSuspend;
  ParentLoop.CaptureCursorState(@State);
  ParentLoop.ShowCursor := False;
  ParentLoop.DrawQueuedUpdateRects;
  RewardsScreen.ParentLoop := ParentLoop;
  ParentLoop.ChildLoop := RewardsScreen;
  RewardsScreen.ReadOnly := ReadOnly;
  if RewardsScreen.Run = 1 then Result := True else Result := False;
  RewardsScreen.ParentLoop := nil;
  ParentLoop.ChildLoop := nil;
  ParentLoop.InvalidateViewport;
  ParentLoop.RestoreCursorState(@State);
  ParentLoop.UpdateCursorPosition;
  ParentLoop.RootUiObject.OnModalResume;
  ParentLoop.Present;
end;
{ @end $5D19BC }

{ @routine $5D1AA0 TfRewards_ProcessMouseWheel }
procedure TfRewards.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then
    with GetByName('PTable') as TPanelScrollBarGI do
      VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.SmallChange * 5)
  else if Delta = -WHEEL_DELTA then
    with GetByName('PTable') as TPanelScrollBarGI do
      VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.SmallChange * 5);
end;
{ @end $5D1AA0 }

end.
