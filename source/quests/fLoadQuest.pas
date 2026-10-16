unit fLoadQuest;

interface

uses GI_Image, GI_MessageLoop, Types, fPanelLoad;

type
  TfLoadQuestSlot = record // @size 0x2C
    Name: WideString; // @offset 0x00
    Title: WideString; // @offset 0x04
    Description: WideString; // @offset 0x08
    Image: WideString; // @offset 0x0C
    Genre: WideString; // @offset 0x10
    Length: Integer; // @offset 0x14
    QuestId: Integer; // @offset 0x18 // -1 for nonnumeric names.
    BackgroundImage: TImageGI; // @offset 0x1C // Borrowed from the row control.
    RequiredAccess: Integer; // @offset 0x20
    AlternateGroup: Boolean; // @offset 0x24
    Difficulty: Integer; // @offset 0x28
  end;

  TfLoadQuest = class(TMessageLoopGI) // @size 0xF0
  public
    LoadPanel: TfPanelLoad; // @offset 0xD0 // Owned.
    Entries: array of TfLoadQuestSlot; // @offset 0xD4 // Owned dynamic array, indexed from zero.
    SelectedIndex: Integer; // @offset 0xD8
    HoveredIndex: Integer; // @offset 0xDC
    CompletionData: array of Integer; // @offset 0xE0 // Dynamic array: auxiliary value, status pairs indexed by quest ID.
    Category: Integer; // @offset 0xE4
    AccessLevel: Integer; // @offset 0xE8
    KeyHistory: WideString; // @offset 0xEC

    constructor Create; // @addr 0x005E066C
    destructor Destroy; override; // @addr 0x005E06C8
    procedure InitializeLayout; override; // @addr 0x005E0704
    procedure OnOpen; override; // @addr 0x005E0AB0
    procedure OnClose; override; // @addr 0x005E0BF4
    procedure ReturnToMenu(Sender: TObjectGI); // @addr 0x005E0C34
    procedure QuestListKeyDown(Sender: TObjectGI; VirtualKey: Cardinal); // @addr 0x005E0C48
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x005E10B4
    procedure RebuildQuestList; // @addr 0x005E1274
    procedure InitializeQuestRow(Row: TObjectGI); // @addr 0x005E196C
    procedure SelectQuest(Index: Integer); // @addr 0x005E2100 @note "Index is zero-based; locked entries clear the selection."
    procedure UpdateQuestRow(Index: Integer); // @addr 0x005E2200
    procedure QuestRowMouseEnter(Sender: TObjectGI); // @addr 0x005E2400
    procedure QuestRowMouseLeave(Sender: TObjectGI); // @addr 0x005E2434
    procedure QuestRowMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005E2464
    procedure QuestRowDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005E24D0
    procedure SelectCategory(Sender: TObjectGI); // @addr 0x005E24F0
    procedure StartSelectedQuest(Sender: TObjectGI); // @addr 0x005E2630
    procedure ShowSelectedQuestDetails; // @addr 0x005E269C @note "Loads the quest with HeaderOnly enabled."
    procedure LoadCompletionData; // @addr 0x005E2FD0 @note "QuestComplate.dat: CRC32, Int32 count, then Int32 entries."
    procedure SaveCompletionData; // @addr 0x005E3160
    procedure RecordCompletion(QuestId, Value, Status: Integer); // @addr 0x005E328C @note "QuestId must be 0..9999. Higher status wins; equal status minimizes an existing nonzero Value."
    function CalculateAccessLevel: Integer; // @addr 0x005E3394 @note "Advances past a group when all but one quest is completed."
    function GetCompletionCounts: TPoint; // @addr 0x005E34AC @note "X is completed, Y is total; includes only numeric quests with positive Access."
    function GetCompletionSummary: WideString; // @addr 0x005E3628 @note "The displayed total includes groups below 3."
    procedure SelectMusic; override; // @addr 0x005E3778 @note "Empty implementation."
    function InsertEntryByAccess(RequiredAccess: Integer): Integer; // @addr 0x005E11C8 @note "Returns a zero-based index; inserts after entries with equal access."
  end;

var
  QuestNameColor: Cardinal; // @addr $81B804

implementation

uses EC_CacheBitmap, Classes, EC_BlockPar, EC_Buf, EC_Cache, EC_CacheBuf, EC_File, EC_Str, GI_GraphBuf, GI_GraphButton, GI_Label, GI_Main, GI_Panel, GI_PanelScrollBar, GI_ScrollBar, GR_GraphBuf, GR_Main, Globals, GlobalsV, Math, SysUtils, TextQuest, Windows, aConst, aGalaxy, aMyFunction, aGalaxyStruct;

{ @routine $5E066C TfLoadQuest_Create }
constructor TfLoadQuest.Create;
begin
  inherited Create;
  SelectedIndex := -1;
  Category := 0;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $5E066C }

{ @routine $5E06C8 TfLoadQuest_Destroy }
destructor TfLoadQuest.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $5E06C8 }

{ @routine $5E0704 TfLoadQuest_InitializeLayout }
procedure TfLoadQuest.InitializeLayout;
var
  Root, Panel: TObjectGI;
begin
  inherited InitializeLayout;
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fLoadQuest... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Root := GetByName('');
  Root.ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
  Root.FindByNameRecursive('BGBuf').ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
  Panel := Root.FindByNameRecursive('MainPanel');
  if ExtraScreenHeight < 0 then
    Panel.Pos := Classes.Point(ExtraScreenWidth div 2 + Panel.LocalPosition.X, (Integer(GameScreenHeight) - Panel.ClientSize.Y) div 2)
  else Panel.Pos := Classes.Point(ExtraScreenWidth div 2 + Panel.LocalPosition.X, ExtraScreenHeight div 2 + Panel.LocalPosition.Y);
  AppendLogLineThreadSafe('ok');
  GetByName('MainPanel').KeyDownCallback := QuestListKeyDown;
  (GetByName('ButClose') as TGraphButtonGI).UpCallback := ReturnToMenu;
  (GetByName('ButCancel') as TGraphButtonGI).UpCallback := ReturnToMenu;
  (GetByName('ButStart') as TGraphButtonGI).UpCallback := StartSelectedQuest;
  with GetByName('ButGroup0') as TGraphButtonGI do
  begin
    UpCallback := SelectCategory;
    DownCallback := SelectCategory;
  end;
  with GetByName('ButGroup1') as TGraphButtonGI do
  begin
    UpCallback := SelectCategory;
    DownCallback := SelectCategory;
  end;
  with GetByName('ButGroup2') as TGraphButtonGI do
  begin
    UpCallback := SelectCategory;
    DownCallback := SelectCategory;
  end;
  QuestNameColor := GetStyleColorGI('LoadQuest.QuestsNameColor', 165, 183, 143);
end;
{ @end $5E0704 }

{ @routine $5E0AB0 TfLoadQuest_OnOpen }
procedure TfLoadQuest.OnOpen;
begin
  inherited OnOpen;
  LoadPanel.OnOpen;
  KeyHistory := '';
  if PreviousScreenId <> screen_text_quest then
    if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True, 0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  with GetByName('ButGroup0') as TGraphButtonGI do SetDown(Category = 0);
  with GetByName('ButGroup1') as TGraphButtonGI do SetDown(Category = 1);
  with GetByName('ButGroup2') as TGraphButtonGI do SetDown(Category = 2);
  RebuildQuestList;
  SelectQuest(0);
end;
{ @end $5E0AB0 }

{ @routine $5E0BF4 TfLoadQuest_OnClose }
procedure TfLoadQuest.OnClose;
begin
  Entries := nil;
  if RequestedScreenId <> screen_text_quest then AuxRenderBuffer.Clear;
  LoadPanel.OnClose;
  inherited OnClose;
end;
{ @end $5E0BF4 }

{ @routine $5E0C34 TfLoadQuest_ReturnToMenu }
procedure TfLoadQuest.ReturnToMenu(Sender: TObjectGI);
begin
  RequestedScreenId := screen_main_menu;
  RequestClose(1);
end;
{ @end $5E0C34 }

{ @routine $5E0C48 TfLoadQuest_QuestListKeyDown }
procedure TfLoadQuest.QuestListKeyDown(Sender: TObjectGI; VirtualKey: Cardinal);
var
  CaptureKey: Boolean;
  I, QuestId: Integer;
begin
  CaptureKey := False;
  if IsVirtualKeyDown(VK_CONTROL) then
    if IsVirtualKeyDown(VK_SHIFT) then
    begin
      KeyHistory := KeyHistory + WideChar(VirtualKey);
      CaptureKey := True;
    end;
  // Ctrl+Shift+WIN records completion for an eligible quest. Both rejection and
  // completion fall through to normal navigation-key handling below.
  repeat
    if not CaptureKey then Break;
    if FindTextOffsetW(KeyHistory, 'WIN') < 0 then Break;
    KeyHistory := '';
    if SelectedIndex < 0 then Break;
    if SelectedIndex > High(Entries) then Break;
    if Entries[SelectedIndex].QuestId < 0 then Break;
    LoadCompletionData;
    // At most one completion update is performed.
    while True do
    begin
      if (Entries[SelectedIndex].QuestId < 0) or
         (Entries[SelectedIndex].QuestId >= FirstLicensedQuestId) then Break;
      QuestId := Entries[SelectedIndex].QuestId;
      if (QuestId < 0) or ((High(CompletionData) + 1) div 2 <= QuestId) or (CompletionData[QuestId * 2 + 1] = 0) then
      begin
        RecordCompletion(QuestId, 0, 1);
        SaveCompletionData;
        RebuildQuestList;
      end;
      Break;
    end;
  until True;
  if VirtualKey = VK_ESCAPE then ReturnToMenu(Sender)
  else if VirtualKey = Ord('Q') then ReturnToMenu(Sender)
  else if VirtualKey = VK_PRIOR then
  begin
    with GetByName('PanelSlot') as TPanelScrollBarGI do
      if VerticalScrollBar.Active then
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.LargeChange);
  end
  else if VirtualKey = VK_NEXT then
  begin
    with GetByName('PanelSlot') as TPanelScrollBarGI do
      if VerticalScrollBar.Active then
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.LargeChange);
  end
  else if VirtualKey = VK_HOME then
  begin
    if High(Entries) + 1 > 0 then
      if Entries[0].RequiredAccess <= AccessLevel then SelectQuest(0);
  end
  else if VirtualKey = VK_END then
  begin
    for I := High(Entries) downto 0 do
      if Entries[I].RequiredAccess <= AccessLevel then
      begin
        SelectQuest(I);
        Break;
      end;
  end
  else if VirtualKey = VK_UP then
  begin
    QuestRowMouseLeave(nil);
    if SelectedIndex > 0 then SelectQuest(SelectedIndex - 1)
    else if High(Entries) + 1 > 0 then
      if Entries[0].RequiredAccess <= AccessLevel then SelectQuest(0);
  end
  else if VirtualKey = VK_DOWN then
  begin
    QuestRowMouseLeave(nil);
    if SelectedIndex >= 0 then
    begin
      if SelectedIndex < High(Entries) then
        if Entries[SelectedIndex + 1].RequiredAccess <= AccessLevel then SelectQuest(SelectedIndex + 1);
    end
    else if High(Entries) + 1 > 0 then
      if Entries[0].RequiredAccess <= AccessLevel then SelectQuest(0);
  end
  else if VirtualKey = VK_RETURN then StartSelectedQuest(nil)
  else if VirtualKey = VK_TAB then
  begin
    QuestRowMouseLeave(nil);
    if Category = 0 then SelectCategory(GetByName('ButGroup1'))
    else if Category = 1 then SelectCategory(GetByName('ButGroup2'))
    else if Category = 2 then SelectCategory(GetByName('ButGroup0'));
  end;
end;
{ @end $5E0C48 }

{ @routine $5E10B4 TfLoadQuest_ProcessMouseWheel }
procedure TfLoadQuest.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
var
  Panel: TPanelScrollBarGI;
  Bounds: TRect;
begin
  Bounds := GetByName('MessageWindow').HitTestBounds;
  with Bounds do
    if (Point.X >= Left) and (Point.X < Right) and (Point.Y >= Top) and (Point.Y < Bottom) then
      Panel := GetByName('MessageWindow') as TPanelScrollBarGI
    else Panel := GetByName('PanelSlot') as TPanelScrollBarGI;
  if Delta = WHEEL_DELTA then
  begin
    if Panel.VerticalScrollBar.Active then
      Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.SmallChange);
    PostMouseMoveMessage;
  end
  else if Delta = -WHEEL_DELTA then
  begin
    if Panel.VerticalScrollBar.Active then
      Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.SmallChange);
    PostMouseMoveMessage;
  end;
end;
{ @end $5E10B4 }

{ @routine $5E11C8 TfLoadQuest_InsertEntryByAccess }
function TfLoadQuest.InsertEntryByAccess(RequiredAccess: Integer): Integer;
var
  Index, I: Integer;
begin
  Index := 0;
  while (High(Entries) >= Index) and (Entries[Index].RequiredAccess <= RequiredAccess) do Inc(Index);
  SetLength(Entries, High(Entries) + 1 + 1);
  for I := High(Entries) downto Index + 1 do Entries[I] := Entries[I - 1];
  Entries[Index].RequiredAccess := RequiredAccess;
  Result := Index;
end;
{ @end $5E11C8 }

{ @routine $5E1274 TfLoadQuest_RebuildQuestList }
procedure TfLoadQuest.RebuildQuestList;
var
  I, Index, QuestIdAndTop, Count: Integer;
  Panel: TPanelScrollBarGI;
  Row: TPanelGI;
  Alternate: Boolean;
  List, Entry: TBlockParEC;
  Name: WideString;
begin
  Panel := GetByName('PanelSlot') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  LoadCompletionData;
  QuestIdAndTop := 0;
  Entries := nil;
  if (Category = 0) or (Category = 1) then
  begin
    List := LanguageDataConfig.GetBlockByPath('PlanetQuest.List');
    Count := List.GetBlockCount;
    for I := 0 to Count - 1 do
    begin
      Name := List.GetBlockNameByIndex(I);
      Entry := List.GetBlockByIndex(I);
      QuestIdAndTop := -1;
      if IsIntegerTextW(Name) then QuestIdAndTop := StrToInt(AnsiString(Name));
      if Entry.CountParams('Group') > 0 then
        if ExtractSignedDigitsToIntW(Entry.GetParam('Group')) = Category then
        begin
          Index := InsertEntryByAccess(ExtractDigitsToIntW(Entry.GetParam('Access')));
          Entries[Index].Name := Name;
          Entries[Index].Title := Entry.GetParam('Name');
          Entries[Index].Description := LanguageDataConfig.GetBlock('PlanetQuest').GetBlock('PlanetQuest').GetParam(Name);
          Entries[Index].QuestId := QuestIdAndTop;
          Entries[Index].Image := Entry.GetParamOrMarker('Image');
          Entries[Index].Genre := Entry.GetParamOrMarker('Genre');
          Entries[Index].Length := ExtractDigitsToIntW(Entry.GetParamOrMarker('Length'));
          Entries[Index].Difficulty := ExtractDigitsToIntW(Entry.GetParamOrMarker('Dif'));
        end;
    end;
  end
  else
  begin
    List := LanguageDataConfig.GetBlockByPath('PlanetQuest.List');
    Count := List.GetBlockCount;
    for I := 0 to Count - 1 do
    begin
      Name := List.GetBlockNameByIndex(I);
      Entry := List.GetBlockByIndex(I);
      QuestIdAndTop := -1;
      if IsIntegerTextW(Name) then QuestIdAndTop := StrToInt(AnsiString(Name));
      if Entry.CountParams('Group') > 0 then
        if ExtractSignedDigitsToIntW(Entry.GetParam('Group')) = Category then
        begin
          Index := InsertEntryByAccess(0);
          Entries[Index].Name := Name;
          Entries[Index].Title := Entry.GetParam('Name');
          Entries[Index].Description := LanguageDataConfig.GetBlock('PlanetQuest').GetBlock('PlanetQuest').GetParam(Name);
          Entries[Index].QuestId := QuestIdAndTop;
          Entries[Index].Image := Entry.GetParamOrMarker('Image');
          Entries[Index].Genre := Entry.GetParamOrMarker('Genre');
          Entries[Index].Length := ExtractDigitsToIntW(Entry.GetParamOrMarker('Length'));
          Entries[Index].Difficulty := ExtractDigitsToIntW(Entry.GetParamOrMarker('Dif'));
        end;
    end;
  end;
  AccessLevel := CalculateAccessLevel;
  Alternate := True;
  Index := -100;
  // Native code reuses the final parsed quest ID as the first row's top.
  for I := 0 to High(Entries) do
  begin
    if I <> 0 then Inc(QuestIdAndTop, GiScalePixels(5));
    if Entries[I].RequiredAccess <> Index then
    begin
      Alternate := not Alternate;
      Index := Entries[I].RequiredAccess;
    end;
    Entries[I].AlternateGroup := Alternate;
    Row := TPanelGI.Create(Panel);
    Row.UserValue := I;
    Row.Pos := Classes.Point(0, QuestIdAndTop);
    InitializeQuestRow(Row);
    Inc(QuestIdAndTop, Row.ClientSize.Y);
    Row.World := True;
    Panel.VerticalScrollBar.SetSmallChange(GiScalePixels(5) + Row.ClientSize.Y);
    UpdateQuestRow(I);
  end;
  Panel.UpdateScrollRanges;
  Panel.VerticalScrollBar.IsActive := Panel.ClientSize.Y < QuestIdAndTop;
  Panel.VerticalScrollBar.SetLargeChange(Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetPageSize(Panel.ClientSize.Y);
  I := Panel.VerticalScrollBar.Position;
  Panel.VerticalScrollBar.SetPosition(I - 1);
  Panel.VerticalScrollBar.SetPosition(I);
  if (SelectedIndex < 0) or (SelectedIndex >= High(Entries) + 1) then SelectedIndex := -1;
  SelectQuest(SelectedIndex);
  Panel.Invalidate;
end;
{ @end $5E1274 }

{ @routine $5E196C TfLoadQuest_InitializeQuestRow }
procedure TfLoadQuest.InitializeQuestRow(Row: TObjectGI);
var
  Index, Status, TitleRight, CompletionIndex, GenreRight: Integer;
  Background, LengthImage, CompletionImage: TImageGI;
  TitleLabel, GenreLabel: TLabelGI;
begin
  Index := Row.UserValue;
  Row.MouseEnterCallback := QuestRowMouseEnter;
  Row.MouseLeaveCallback := QuestRowMouseLeave;
  Row.LeftButtonDownCallback := QuestRowMouseDown;
  Row.LeftButtonDoubleClickCallback := QuestRowDoubleClick;
  Entries[Index].BackgroundImage := TImageGI.Create(Row);
  Background := Entries[Index].BackgroundImage;
  Background.Pos := Classes.Point(0, 0);
  Background.SetDepth(10);
  if Entries[Index].RequiredAccess <= AccessLevel then
  begin
    if not Entries[Index].AlternateGroup then Background.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'SlotNormal'
    else Background.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'SlotNormal2';
  end
  else Background.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'SlotDisabled';
  Background.ObjectSize := Background.GetContentSize;
  Row.ObjectSize := Background.ClientSize;
  Background.IsActive := True;
  TitleRight := GiScalePixels(262);
  if (Entries[Index].QuestId >= 0) and (Entries[Index].QuestId < FirstLicensedQuestId) then
  begin
    LengthImage := TImageGI.Create(Row);
    LengthImage.SetDepth(9);
    if Entries[Index].RequiredAccess <= AccessLevel then
      LengthImage.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'D' + IntToStr(Entries[Index].Length + 1)
    else LengthImage.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'D' + IntToStr(Entries[Index].Length + 1) + 'D';
    LengthImage.ObjectSize := LengthImage.GetContentSize;
    LengthImage.Pos := Classes.Point(TitleRight - LengthImage.ClientSize.X, Row.ClientSize.Y div 2 - LengthImage.ClientSize.Y div 2);
    LengthImage.IsActive := True;
    TitleRight := TitleRight - LengthImage.ClientSize.X - 1;
  end;
  Status := Entries[Index].QuestId;
  CompletionIndex := Status;
  GenreRight := Row.ClientSize.X;
  if CompletionIndex >= 0 then
    if (High(CompletionData) + 1) div 2 > CompletionIndex then
    begin
      Status := CompletionData[CompletionIndex * 2 + 1];
      if Status <> 0 then
      begin
        CompletionImage := TImageGI.Create(Row);
        CompletionImage.Pos := Classes.Point(0, 0);
        CompletionImage.SetDepth(9);
        CompletionImage.ImageSourcePath := 'GI,Bm.FormRewards.' + GiResourceSuffix + '_33';
        CompletionImage.ObjectSize := CompletionImage.GetContentSize;
        CompletionImage.Pos := Classes.Point(Row.ClientSize.X - CompletionImage.ClientSize.X - GiScalePixels(10), Row.ClientSize.Y div 2 - CompletionImage.ClientSize.Y div 2);
        GenreRight := CompletionImage.LocalPosition.X;
        CompletionImage.IsActive := True;
      end;
    end;
  TitleLabel := TLabelGI.Create(Row);
  if GiResourceVariant = 1 then
  begin
    TitleLabel.Pos := Classes.Point(11, 0);
    TitleLabel.ObjectSize := Classes.Point(TitleRight - TitleLabel.LocalPosition.X, Row.ClientSize.Y);
  end
  else
  begin
    TitleLabel.Pos := Classes.Point(14, 0);
    TitleLabel.ObjectSize := Classes.Point(TitleRight - TitleLabel.LocalPosition.X, Row.ClientSize.Y);
  end;
  TitleLabel.SetDepth(7);
  TitleLabel.SetFontName(NormalFontName);
  TitleLabel.SetTextAlignX(text_x_left);
  TitleLabel.SetTextAlignY(text_y_font_center);
  TitleLabel.Text := Entries[Index].Title;
  if Entries[Index].RequiredAccess <= AccessLevel then TitleLabel.SetTextColor(QuestNameColor)
  else TitleLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(112, 112, 112));
  GenreLabel := TLabelGI.Create(Row);
  if GiResourceVariant = 1 then
  begin
    GenreLabel.Pos := Classes.Point(209, 0);
    GenreLabel.ObjectSize := Classes.Point(GenreRight - 209, Row.ClientSize.Y - 2);
  end
  else
  begin
    GenreLabel.Pos := Classes.Point(267, 0);
    GenreLabel.ObjectSize := Classes.Point(GenreRight - 267, Row.ClientSize.Y - 2);
  end;
  GenreLabel.SetDepth(7);
  GenreLabel.SetFontName(SmallFontName);
  GenreLabel.SetTextAlignX(text_x_left);
  GenreLabel.SetTextAlignY(text_y_center);
  GenreLabel.SetWordWrapEnabled(True);
  GenreLabel.Text := TrimWideString(Entries[Index].Genre);
  if Entries[Index].RequiredAccess <= AccessLevel then GenreLabel.SetTextColor(QuestNameColor)
  else GenreLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(112, 112, 112));
end;
{ @end $5E196C }

{ @routine $5E2100 TfLoadQuest_SelectQuest }
procedure TfLoadQuest.SelectQuest(Index: Integer);
var
  Previous: Integer;
begin
  Previous := SelectedIndex;
  SelectedIndex := Index;
  if SelectedIndex >= High(Entries) + 1 then SelectedIndex := -1;
  if SelectedIndex >= 0 then
    if Entries[SelectedIndex].RequiredAccess > AccessLevel then SelectedIndex := -1;
  UpdateQuestRow(Previous);
  UpdateQuestRow(SelectedIndex);
  if (Index < 0) or (High(Entries) < Index) then
  begin
    ShowSelectedQuestDetails;
    Exit;
  end;
  if SelectedIndex >= 0 then
      with GetByName('PanelSlot') as TPanelScrollBarGI do
        with Entries[SelectedIndex].BackgroundImage.Parent do
          ScrollRectIntoView(GetLocalBounds);
  ShowSelectedQuestDetails;
end;
{ @end $5E2100 }

{ @routine $5E2200 TfLoadQuest_UpdateQuestRow }
procedure TfLoadQuest.UpdateQuestRow(Index: Integer);
var
  Image: TImageGI;
begin
  if (Index < 0) or (High(Entries) < Index) then Exit;
  Image := Entries[Index].BackgroundImage;
  if Entries[Index].RequiredAccess > AccessLevel then Exit;
  if SelectedIndex = Index then Image.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'SlotActive'
  else if HoveredIndex = Index then Image.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'SlotOnMouse'
  else if not Entries[Index].AlternateGroup then Image.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'SlotNormal'
  else Image.ImageSourcePath := 'GI,Bm.FormLoadQuest.' + GiResourceSuffix + 'SlotNormal2';
end;
{ @end $5E2200 }

{ @routine $5E2400 TfLoadQuest_QuestRowMouseEnter }
procedure TfLoadQuest.QuestRowMouseEnter(Sender: TObjectGI);
var
  Previous: Integer;
begin
  if HoveredIndex = Sender.UserValue then Exit;
  Previous := HoveredIndex;
  HoveredIndex := Sender.UserValue;
  UpdateQuestRow(Previous);
  UpdateQuestRow(HoveredIndex);
end;
{ @end $5E2400 }

{ @routine $5E2434 TfLoadQuest_QuestRowMouseLeave }
procedure TfLoadQuest.QuestRowMouseLeave(Sender: TObjectGI);
var
  Previous: Integer;
begin
  if HoveredIndex = -1 then Exit;
  Previous := HoveredIndex;
  HoveredIndex := -1;
  UpdateQuestRow(Previous);
  UpdateQuestRow(HoveredIndex);
end;
{ @end $5E2434 }

{ @routine $5E2464 TfLoadQuest_QuestRowMouseDown }
procedure TfLoadQuest.QuestRowMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  SoundManager.PlaySound('Sound.ButtonClick');
  SelectQuest(Sender.UserValue);
  BreakUiMessage;
end;
{ @end $5E2464 }

{ @routine $5E24D0 TfLoadQuest_QuestRowDoubleClick }
procedure TfLoadQuest.QuestRowDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  StartSelectedQuest(nil);
end;
{ @end $5E24D0 }

{ @routine $5E24F0 TfLoadQuest_SelectCategory }
procedure TfLoadQuest.SelectCategory(Sender: TObjectGI);
var
  NewCategory: Integer;
begin
  NewCategory := ExtractDigitsToIntW(Sender.ControlName);
  (GetByName('ButGroup0') as TGraphButtonGI).SetDown(NewCategory = 0);
  (GetByName('ButGroup1') as TGraphButtonGI).SetDown(NewCategory = 1);
  (GetByName('ButGroup2') as TGraphButtonGI).SetDown(NewCategory = 2);
  if Category <> NewCategory then
  begin
    with GetByName('PanelSlot') as TPanelScrollBarGI do ScrollRectIntoView(Classes.Rect(0, 0, 1, 1));
    Category := NewCategory;
    SelectedIndex := -1;
    RebuildQuestList;
    SelectQuest(0);
  end;
end;
{ @end $5E24F0 }

{ @routine $5E2630 TfLoadQuest_StartSelectedQuest }
procedure TfLoadQuest.StartSelectedQuest(Sender: TObjectGI);
var
  Selected: Integer;
begin
  Selected := SelectedIndex;
  if Selected < 0 then Exit;
  if Selected > High(Entries) then Exit;
  PendingQuestName := Entries[SelectedIndex].Name;
  StandaloneQuestMode := True;
  QuestReturnScreenId := FormToId(Self);
  RequestedScreenId := screen_text_quest;
  RequestClose(1);
  BreakUiMessage;
end;
{ @end $5E2630 }

{ @routine $5E269C TfLoadQuest_ShowSelectedQuestDetails }
procedure TfLoadQuest.ShowSelectedQuestDetails;
var
  Quest: TTextQuest;
  DescriptionText: WideString;
  Y, X, RowSkip: Integer;
  Pixel: Pointer;
  Control: TCBufControlEC;
  Data: TCBufEC;
begin
  with GetByName('ButStart') as TGraphButtonGI do
    SetDisabled((SelectedIndex < 0) or (SelectedIndex > High(Entries)));
  with GetByName('ImageMap') as TGraphBufGI do
  begin
    IsActive := False;
    if (SelectedIndex >= 0) and (SelectedIndex <= High(Entries)) and
      (Entries[SelectedIndex].Image <> '') then
    begin
      IsActive := True;
      LoadBitmapPathAsRgba(Entries[SelectedIndex].Image + RgbaImagePathSuffix);
      if (ClientSize.X <> Integer(GraphBuf.Width)) or (ClientSize.Y <> Integer(GraphBuf.Height)) then
        GraphBuf.RescaleRgba(ClientSize.X, ClientSize.Y, 5);
      RowSkip := GraphBuf.PitchBytes - GraphBuf.Width * SizeOf(TColorRGBA);
      Pixel := GraphBuf.GetPixels;
      for Y := 0 to GraphBuf.Height - 1 do
      begin
        for X := 0 to GraphBuf.Width - 1 do
        begin
          if (Y < 23) and (X > Integer(GraphBuf.Width) - 23 + Y) then
            PByte(Cardinal(Pixel) + SizeOf(TColorRGB))^ := 0
          else PByte(Cardinal(Pixel) + SizeOf(TColorRGB))^ := 255;
          Pixel := Pointer(PAnsiChar(Pixel) + SizeOf(TColorRGBA));
        end;
        Pixel := Pointer(PAnsiChar(Pixel) + RowSkip);
      end;
      Invalidate;
    end;
  end;
  with GetByName('MessageText') as TLabelGI do
  begin
    IsActive := False;
    if (SelectedIndex >= 0) and (SelectedIndex <= High(Entries)) then
    begin
      Quest := TTextQuest.Create;
      if Entries[SelectedIndex].QuestId >= 0 then
      begin
        Control := nil;
        try
          Control := TCBufControlEC.Create;
          GlobalCache.ResetControl(Control);
          Control.SetCacheKey('PlanetQuest.' + IntToStr(Entries[SelectedIndex].QuestId));
          Data := AcquireOrCreateBuffer(Control);
          Quest.LoadFromReader(Data.Buffer, True);
        finally
          if Control <> nil then
          begin
            Control.Release;
            Control.Free;
          end;
        end;
      end
      else
      begin
        Control := nil;
        try
          Control := TCBufControlEC.Create;
          GlobalCache.ResetControl(Control);
          Control.SetCacheKey('PlanetQuest.' + Entries[SelectedIndex].Name);
          Data := AcquireOrCreateBuffer(Control);
          Quest.LoadFromReader(Data.Buffer, True);
        finally
          if Control <> nil then
          begin
            Control.Release;
            Control.Free;
          end;
        end;
      end;
      DescriptionText := Quest.QuestDescriptionText.Text;
      ReplaceTextToken(DescriptionText, '<Ranger>', LocalizedText('FormLoadQuest.PRanger'), BrightBlueColorTag);
      ReplaceTextToken(DescriptionText, '<ToPlanet>', LocalizedText('FormLoadQuest.PToPlanet'), BrightBlueColorTag);
      ReplaceTextToken(DescriptionText, '<ToStar>', LocalizedText('FormLoadQuest.PToStar'), BrightBlueColorTag);
      ReplaceTextToken(DescriptionText, '<Parsec>', IntToStr(10), BrightBlueColorTag);
      ReplaceTextToken(DescriptionText, '<Date>', FormatGameTurnDate(1000), BrightBlueColorTag);
      ReplaceTextToken(DescriptionText, '<Day>', IntToStr(30), BrightBlueColorTag);
      ReplaceTextToken(DescriptionText, '<Money>', IntToStr(10000), BrightBlueColorTag);
      ReplaceTextToken(DescriptionText, '<FromPlanet>', LocalizedText('FormLoadQuest.PFromPlanet'), BrightBlueColorTag);
      ReplaceTextToken(DescriptionText, '<FromStar>', LocalizedText('FormLoadQuest.PFromStar'), BrightBlueColorTag);
      DescriptionText := ReplaceAllWideString(DescriptionText, '<clr>', BrightBlueColorTag);
      ExpandLocalizedTextMarkup(DescriptionText);
      Quest.Free;
      IsActive := True;
      Text := DescriptionText;
    end;
  end;
  with GetByName('MessageWindow') as TPanelScrollBarGI do
  begin
    SetScrollOffset(Classes.Point(0, 0));
    UpdateScrollRanges;
    VerticalScrollBar.IsActive := FindByNameRecursive('MessageText').Active and
      ((FindByNameRecursive('MessageText') as TLabelGI).ClientSize.Y > ClientSize.Y);
    VerticalScrollBar.SetSmallChange((FindByNameRecursive('MessageText') as TLabelGI).GetLineHeight);
    VerticalScrollBar.SetLargeChange(ClientSize.Y);
    VerticalScrollBar.SetPageSize(ClientSize.Y);
  end;
end;
{ @end $5E269C }

{ @routine $5E2FD0 TfLoadQuest_LoadCompletionData }
procedure TfLoadQuest.LoadCompletionData;
var
  Buffer: TBufEC;
  I, Count: Integer;
begin
  CompletionData := nil;
  if SysUtils.FileExists(AnsiString(GetGameUserDirectory + 'QuestComplate.dat')) then
  begin
    try
      Buffer := TBufEC.Create;
      Buffer.LoadFromWideFilePath(PWideChar(GetGameUserDirectory + 'QuestComplate.dat'));
      if Buffer.ComputeCrc32Range(4, Buffer.DataSize) <> Buffer.GetUInt32 then Abort;
      Count := Buffer.GetInt32;
      SetLength(CompletionData, Count);
      for I := 0 to Count - 1 do CompletionData[I] := Buffer.GetInt32;
      Buffer.Free;
    except
      CompletionData := nil;
    end;
  end;
end;
{ @end $5E2FD0 }

{ @routine $5E3160 TfLoadQuest_SaveCompletionData }
procedure TfLoadQuest.SaveCompletionData;
var
  Buffer: TBufEC;
  FileHandle: TFileEC;
  I: Integer;
begin
  Buffer := TBufEC.Create;
  Buffer.AddDword(0);
  Buffer.AddInteger(High(CompletionData) + 1);
  for I := 0 to High(CompletionData) do Buffer.AddIntegerValue(CompletionData[I]);
  PCardinal(Buffer.Data)^ := Buffer.ComputeCrc32Range(4, Buffer.DataSize);
  FileHandle := TFileEC.Create;
  FileHandle.SetFileName(GetGameUserDirectory + 'QuestComplate.dat');
  FileHandle.CreateNew;
  FileHandle.WriteBuffer(Buffer.Data, Buffer.DataSize);
  FileHandle.Free;
  Buffer.Free;
end;
{ @end $5E3160 }

{ @routine $5E328C TfLoadQuest_RecordCompletion }
procedure TfLoadQuest.RecordCompletion(QuestId, Value, Status: Integer);
var
  Count, I: Integer;
begin
  if (QuestId < 0) or (QuestId >= FirstLicensedQuestId) then Exit;
  Count := (High(CompletionData) + 1) div 2;
  if QuestId >= Count then
  begin
    SetLength(CompletionData, (QuestId + 1) * 2);
    for I := Count * 2 to High(CompletionData) do CompletionData[I] := 0;
  end;
  if CompletionData[QuestId * 2 + 1] > Status then Exit else
  if (CompletionData[QuestId * 2] = 0) or (CompletionData[QuestId * 2 + 1] < Status) then
    CompletionData[QuestId * 2] := Value
  else CompletionData[QuestId * 2] := Min(CompletionData[QuestId * 2], Value);
  CompletionData[QuestId * 2 + 1] := Status;
end;
{ @end $5E328C }

{ @routine $5E3394 TfLoadQuest_CalculateAccessLevel }
function TfLoadQuest.CalculateAccessLevel: Integer;
var
  I, QuestId, Access, GroupCount, CompletedCount, CompletionIndex: Integer;
begin
  Result := 0;
  I := 0;
  while High(Entries) >= I do
  begin
    Access := Entries[I].RequiredAccess;
    GroupCount := 0;
    CompletedCount := 0;
    while High(Entries) >= I + GroupCount do
    begin
      if Entries[I + GroupCount].RequiredAccess <> Access then Break;
      QuestId := Entries[I + GroupCount].QuestId;
      if (QuestId >= 0) and (QuestId < FirstLicensedQuestId) then
      begin
        CompletionIndex := QuestId;
        if CompletionIndex >= 0 then
          if (High(CompletionData) + 1) div 2 > CompletionIndex then
            // The native inlined completion check repeats this upper bound.
            if (High(CompletionData) + 1) div 2 > CompletionIndex then
              if CompletionData[CompletionIndex * 2 + 1] <> 0 then Inc(CompletedCount);
      end;
      Inc(GroupCount);
    end;
    Result := Access;
    if (Access > 0) and (GroupCount - 1 > CompletedCount) then Break;
    Inc(I, GroupCount);
  end;
  if Result = 0 then Result := 1;
end;
{ @end $5E3394 }

{ @routine $5E34AC TfLoadQuest_GetCompletionCounts }
function TfLoadQuest.GetCompletionCounts: TPoint;
var
  I, CompletionIndex, Count, QuestId: Integer;
  List, Entry: TBlockParEC;
  Name: WideString;
begin
  Result.X := 0;
  Result.Y := 0;
  LoadCompletionData;
  List := LanguageDataConfig.GetBlockByPath('PlanetQuest.List');
  Count := List.GetBlockCount;
  for I := 0 to Count - 1 do
  begin
    Entry := List.GetBlockByIndex(I);
    Name := List.GetBlockNameByIndex(I);
    QuestId := -1;
    if IsIntegerTextW(Name) then QuestId := StrToInt(AnsiString(Name));
    if (QuestId >= 0) and (ExtractDigitsToIntW(Entry.GetParam('Access')) > 0) then
    begin
      Inc(Result.Y);
      CompletionIndex := QuestId;
      if CompletionIndex >= 0 then
        if (High(CompletionData) + 1) div 2 > CompletionIndex then
          if CompletionData[CompletionIndex * 2 + 1] <> 0 then Inc(Result.X);
    end;
  end;
end;
{ @end $5E34AC }

{ @routine $5E3628 TfLoadQuest_GetCompletionSummary }
function TfLoadQuest.GetCompletionSummary: WideString;
var
  Counts: TPoint;
  List, Entry: TBlockParEC;
  Count, I, Total: Integer;
begin
  List := LanguageDataConfig.GetBlockByPath('PlanetQuest.List');
  Count := List.GetBlockCount;
  Total := 0;
  for I := 0 to Count - 1 do
  begin
    Entry := List.GetBlockByIndex(I);
    if Entry.CountParams('Group') > 0 then
      if ExtractSignedDigitsToIntW(Entry.GetParam('Group')) in [0, 1, 2] then Inc(Total);
  end;
  Counts := GetCompletionCounts;
  Result := IntToStr(Counts.X) + '/' + IntToStr(Total);
end;
{ @end $5E3628 }

{ @routine $5E3778 TfLoadQuest_SelectMusic }
procedure TfLoadQuest.SelectMusic;
begin
end;
{ @end $5E3778 }

end.
