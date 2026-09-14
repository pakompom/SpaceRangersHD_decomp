unit fRewards;
// Unit bracket (inferred): .text 0x005E8A4C..0x005EA642; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    procedure CloseClicked(Sender: TObjectGI); // @addr $5E8F74
    function CanEditAwards: Boolean; // @addr $5E8FB4
    function GetAwardImagePath(AwardId: Integer): WideString; // @addr $5E8FEC @ida "void __usercall $name(TfRewards *Self@<eax>, int AwardId@<edx>, unsigned __int16 **Result@<ecx>);"
    procedure PlatformMouseEnter(Sender: TObjectGI); // @addr $5E911C
    procedure AwardMouseEnter(Sender: TObjectGI); // @addr $5E93A4
    procedure AwardMouseLeave(Sender: TObjectGI); // @addr $5E93D4
    procedure ClearHighlight(Sender: TObjectGI); // @addr $5E93FC
    procedure AwardMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5E95D8 @ida "void __userpurge $name(TfRewards *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure IncreaseVisibleCount(Sender: TObjectGI); // @addr $5E9834
    procedure DecreaseVisibleCount(Sender: TObjectGI); // @addr $5E9880
    procedure RefreshVisibleCount; // @addr $5E98BC
    procedure BuildAwardControls; // @addr $5E99E8
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5E9FE4
    procedure OnOpen; override; // @addr 0x5E8CE8
    procedure OnClose; override; // @addr 0x5E8F54
    procedure ProcessCallbackTimers; override; // @addr 0x5E9FA4
    procedure SelectMusic; override; // @addr 0x5EA14C
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x5EA580 @ida "void __userpurge $name(TfRewards *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure InitializeLayout; override; // @addr 0x5E8AE4
    procedure UpdateActionCursor(CanTake: Boolean); override; // @addr 0x5E9EC4
  end;

function RunRewards(ParentLoop: TMessageLoopGI; ReadOnly: Boolean): Boolean; // @addr $5EA480

implementation

uses aGalaxyStruct, Classes, SysUtils, Math, Windows, EC_Struct, GI_Panel, GI_ScrollBar,
  GI_GraphBuf, GI_GraphButton, GI_Image, GI_Label, GR_Main, GR_Sound, GR_Music,
  Globals, GlobalsV, aPlayer, aNormalShip, aConst, aPlanet, aMyFunction, fStarMap;


{ @routine $5E8AE4 TfRewards_InitializeLayout }
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
{ @end $5E8AE4 }

{ @routine $5E8CE8 TfRewards_OnOpen }
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
{ @end $5E8CE8 }

{ @routine $5E8F54 TfRewards_OnClose }
procedure TfRewards.OnClose;
begin
  AwardsPanel.FreeOwnedChildren;
  inherited OnClose;
end;
{ @end $5E8F54 }

{ @routine $5E8F74 TfRewards_CloseClicked }
procedure TfRewards.CloseClicked(Sender: TObjectGI);
begin
  if GetPlayer = Ship then RequestedScreenId := screenShip
  else RequestedScreenId := screenScanner;
  RequestClose(1);
end;
{ @end $5E8F74 }

{ @routine $5E8FB4 TfRewards_CanEditAwards }
function TfRewards.CanEditAwards: Boolean;
begin
  Result := not ReadOnly and (GetPlayer = Ship);
end;
{ @end $5E8FB4 }

{ @routine $5E8FEC TfRewards_GetAwardImagePath }
function TfRewards.GetAwardImagePath(AwardId: Integer): WideString;
begin
  if AwardId < 10 then Result := 'GI,Bm.FormRewards.' + GiResourceSuffix + '_0' + IntToStr(AwardId)
  else Result := 'GI,Bm.FormRewards.' + GiResourceSuffix + '_' + IntToStr(AwardId);
end;
{ @end $5E8FEC }

{ @routine $5E911C TfRewards_PlatformMouseEnter }
procedure TfRewards.PlatformMouseEnter(Sender: TObjectGI);
var
  Obj: TObjectGI;
  Platform: TImageGI;
  AwardId: Integer;
begin
  Platform := TImageGI(Sender.UserValue);
  AwardId := Sender.UserIndex;
  with GetByName('InfoZag') as TLabelGI do
    if AwardId <> 255 then SetText((Ship as TNormalShip).GetAwardInfo(AwardId).Name) else SetText('');
  with GetByName('Info') as TLabelGI do
    if AwardId <> 255 then SetText((Ship as TNormalShip).GetAwardInfo(AwardId).Text) else SetText('');
  Obj := AwardsPanel.FirstChild;
  while Obj <> nil do
  begin
    if (Obj is TImageGI) and (TImageGI(Obj).GetImagePath = 'GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformA') then
      TImageGI(Obj).SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformN');
    Obj := Obj.NextSibling;
  end;
  Platform.SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformA');
  UpdateActionCursor(False);
end;
{ @end $5E911C }

{ @routine $5E93A4 TfRewards_AwardMouseEnter }
procedure TfRewards.AwardMouseEnter(Sender: TObjectGI);
begin
  HoveredAwardId := Sender.UserIndex;
  PlatformMouseEnter(Sender);
end;
{ @end $5E93A4 }

{ @routine $5E93D4 TfRewards_AwardMouseLeave }
procedure TfRewards.AwardMouseLeave(Sender: TObjectGI);
begin
  HoveredAwardId := -1;
  UpdateActionCursor(False);
end;
{ @end $5E93D4 }

{ @routine $5E93FC TfRewards_ClearHighlight }
procedure TfRewards.ClearHighlight(Sender: TObjectGI);
var Obj: TObjectGI;
begin
  HoveredAwardId := -1;
  with GetByName('InfoZag') as TLabelGI do SetText('');
  with GetByName('Info') as TLabelGI do SetText('');
  Obj := AwardsPanel.FirstChild;
  while Obj <> nil do
  begin
    if (Obj is TImageGI) and (TImageGI(Obj).GetImagePath = 'GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformA') then
      TImageGI(Obj).SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + 'PlatformN');
    Obj := Obj.NextSibling;
  end;
  UpdateActionCursor(False);
end;
{ @end $5E93FC }

{ @routine $5E95D8 TfRewards_AwardMouseDown }
procedure TfRewards.AwardMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Temp: Integer;
begin
  if DraggedAward = nil then
  begin
    DraggedAward := Sender;
    (Sender as TImageGI).SetImagePath('');
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
      SetImagePath(GetAwardImagePath(Sender.UserIndex));
      SetSize(GetContentSize);
    end;
    with DraggedAward as TImageGI do
    begin
      SetImagePath(GetAwardImagePath(DraggedAward.UserIndex));
      SetSize(GetContentSize);
    end;
    DraggedAward := nil;
    SoundManager.PlaySound('Sound.SlotPut');
    PlatformMouseEnter(Sender);
  end;
  UpdateActionCursor(False);
end;
{ @end $5E95D8 }

{ @routine $5E9834 TfRewards_IncreaseVisibleCount }
procedure TfRewards.IncreaseVisibleCount(Sender: TObjectGI);
begin
  if Ship.AwardVisibleCount < Ship.AwardIds.Count then Inc(Ship.AwardVisibleCount);
  RefreshVisibleCount;
end;
{ @end $5E9834 }

{ @routine $5E9880 TfRewards_DecreaseVisibleCount }
procedure TfRewards.DecreaseVisibleCount(Sender: TObjectGI);
begin
  if Ship.AwardVisibleCount > 0 then Dec(Ship.AwardVisibleCount);
  RefreshVisibleCount;
end;
{ @end $5E9880 }

{ @routine $5E98BC TfRewards_RefreshVisibleCount }
procedure TfRewards.RefreshVisibleCount;
begin
  (GetByName('RewardCount') as TLabelGI).SetText(IntToStr(Ship.AwardVisibleCount));
  (GetByName('Sub') as TGraphButtonGI).SetDisabled(Ship.AwardVisibleCount <= 1);
  (GetByName('Add') as TGraphButtonGI).SetDisabled(Ship.AwardVisibleCount >= Ship.AwardIds.Count);
end;
{ @end $5E98BC }

{ @routine $5E99E8 TfRewards_BuildAwardControls }
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
        SetImagePath(GetAwardImagePath(AwardId));
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
{ @end $5E99E8 }

{ @routine $5E9EC4 TfRewards_UpdateActionCursor }
procedure TfRewards.UpdateActionCursor(CanTake: Boolean);
begin
  if DraggedAward = nil then
  begin
    if (HoveredAwardId >= 0) and CanEditAwards then SetCursorByName('Take')
    else SetCursorByName('Main');
  end
  else SetCursorImage(GetAwardImagePath(DraggedAward.UserIndex), Classes.Point(16, 16));
end;
{ @end $5E9EC4 }

{ @routine $5E9FA4 TfRewards_ProcessCallbackTimers }
procedure TfRewards.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $5E9FA4 }

{ @routine $5E9FE4 TfRewards_MainPanelKeyDown }
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
{ @end $5E9FE4 }

{ @routine $5EA14C TfRewards_SelectMusic }
procedure TfRewards.SelectMusic;
begin
  if GetPlayer = nil then MusicManager.PlayCategory('Base')
  else if GetPlayer.IsOnPlanet then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else
      if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
      begin
        if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
          MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.CurrentPlanet.RaceId)) and $7F].InternalName + 'Pirate')
        else MusicManager.PlayCategory('Nation.PiratePlanetMain');
      end
      else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
  end
  else if GetPlayer.IsDockedToShip then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else
      if GetPlayer.DockedTo.TypeId in [Ord(rstPirateBase), Ord(rstDominion)] then
        MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.DockedTo.PilotRace)) and $7F].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.DockedTo.PilotRace)) and $7F].InternalName);
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
{ @end $5EA14C }

{ @routine $5EA480 RunRewards }
function RunRewards(ParentLoop: TMessageLoopGI; ReadOnly: Boolean): Boolean;
var
  CursorAlignment: array[0..1] of Byte; // Native cursor record starts at EBP-$20; the shared packed layout otherwise lands two bytes higher.
  State: TCursorStateGI;
begin
  ParentLoop.RootUiObject.NativeHook50;
  ParentLoop.CaptureCursorState(@State);
  ParentLoop.SetCursorActive(False);
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
  ParentLoop.RootUiObject.NativeHook48;
  ParentLoop.Present;
end;
{ @end $5EA480 }

{ @routine $5EA580 TfRewards_ProcessMouseWheel }
procedure TfRewards.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then
    with GetByName('PTable') as TPanelScrollBarGI do
      VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.SmallChange * 5)
  else if Delta = -WHEEL_DELTA then
    with GetByName('PTable') as TPanelScrollBarGI do
      VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.SmallChange * 5);
end;
{ @end $5EA580 }

end.
