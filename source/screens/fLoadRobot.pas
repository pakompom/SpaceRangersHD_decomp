unit fLoadRobot;
// Unit bracket (inferred): .text 0x0055CAA8..0x00560FD9; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, Types, fPanelLoad, GI_Image;

type
  TfLoadRobotSlot = record // @size $20 Native RTTI name and managed-field offsets.
    Name: WideString; // @offset $00
    FileName: WideString; // @offset $04 Passed to FRun when starting the battle.
    MapIndex: Integer; // @offset $08 -1 for loose map files absent from configured maps.
    Image: TImageGI; // @offset $0C Borrowed child of the entry panel.
    Access: Integer; // @offset $10 Unlock group, zero for loose maps.
    Side: Integer; // @offset $14 Red=1, Green=2, Blue=4.
    AlternateBackground: Boolean; // @offset $18 Alternates at each unlock group.
    Length: Integer; // @offset $1C -1 for an unknown duration.
  end;

  TfLoadRobot = class(TMessageLoopGI) // @size $F8
  public
    LoadPanel: TfPanelLoad; // @offset $D0 Owned.
    Entries: array of TfLoadRobotSlot; // @offset $D4
    SelectedIndex: Integer; // @offset $D8
    HoveredIndex: Integer; // @offset $DC
    BattleResult: Integer; // @offset $E0 Nonzero preserves Entries during the planetary-battle transition.
    CompletionData: array of Integer; // @offset $E4
    Category: Integer; // @offset $E8
    UnlockedAccess: Integer; // @offset $EC
    KeyHistory: WideString; // @offset $F0
    Difficulty: Integer; // @offset $F4 Dif1/Dif2/Dif3 controls.

    procedure CloseClick(Sender: TObjectGI); // @addr $55DA6C
    procedure KeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $55DAA0
    function InsertEntry(Access: Integer): Integer; // @addr $55E198
    procedure RebuildEntries; // @addr $55E280
    procedure BuildEntryPanel(Panel: TObjectGI); // @addr $55E9E4
    procedure SelectEntry(Index: Integer); // @addr $55F810
    procedure UpdateEntryImage(Index: Integer); // @addr $55F958
    procedure EntryMouseEnter(Sender: TObjectGI); // @addr $55FB8C
    procedure EntryMouseLeave(Sender: TObjectGI); // @addr $55FBF8
    procedure EntryMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $55FC58
    procedure EntryDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $55FCD0
    procedure CategoryClick(Sender: TObjectGI); // @addr $55FCFC
    procedure DifficultyClick(Sender: TObjectGI); // @addr $55FE5C
    procedure StartClick(Sender: TObjectGI); // @addr $55FF30
    procedure UpdateSelectionDetails; // @addr $55FFB8
    function GetUnlockedAccess: Integer; // @addr $560CBC

    constructor Create; // @addr $55CBA8
    destructor Destroy; override; // @addr $55CC24
    procedure OnOpen; override; // @addr $55D180
    procedure OnClose; override; // @addr $55DA2C
    procedure SelectMusic; override; // @addr $560FD0
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $55E044
    procedure InitializeLayout; override; // @addr $55CC7C
    procedure SaveCompletionData; // @addr $560A00
    procedure RecordCompletion(MapId, Score, Level: Integer); // @addr $560B74
    procedure LoadCompletionData; // @addr $560858
    function GetCompletionCounts: TPoint; // @addr $560E18 @note "X completed, Y eligible; groups greater than -1 are eligible."
    function GetCompletionSummary: WideString; // @addr $560EF0 @note "Menu summary; displayed total includes groups 0..2."
  end;

var
  RobotMapNameColor: Cardinal; // @addr $88A814

implementation

uses Globals, GR_Main, EC_Buf, SysUtils, EC_File, Math, EC_Str, Classes, GI_Main, GI_Panel, GI_PanelScrollBar, GI_GraphButton, GlobalsV, Robot, GI_GraphBuf, aConst, aMyFunction, Windows, GI_Label;

{ @routine $55CBA8 TfLoadRobot_Create }
constructor TfLoadRobot.Create;
begin
  inherited Create;
  SelectedIndex := -1;
  Category := 0;
  Difficulty := 1;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $55CBA8 }

{ @routine $55CC24 TfLoadRobot_Destroy }
destructor TfLoadRobot.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $55CC24 }

{ @routine $55CC7C TfLoadRobot_InitializeLayout }
procedure TfLoadRobot.InitializeLayout;
var Root, Panel: TObjectGI;
begin
  inherited InitializeLayout;
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fLoadRobot... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Root := GetByName('');
  Root.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Root.FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Panel := Root.FindByNameRecursive('MainPanel');
  if ExtraScreenHeight < 0 then
    Panel.SetPosition(Classes.Point(Panel.LocalPosition.X + ExtraScreenWidth div 2, (GameScreenHeight - Panel.ClientSize.Y) div 2))
  else Panel.SetPosition(Classes.Point(Panel.LocalPosition.X + ExtraScreenWidth div 2, Panel.LocalPosition.Y + ExtraScreenHeight div 2));
  AppendLogLineThreadSafe('ok');
  GetByName('MainPanel').KeyDownCallback := KeyDown;
  (GetByName('ButClose') as TGraphButtonGI).UpCallback := CloseClick;
  (GetByName('ButCancel') as TGraphButtonGI).UpCallback := CloseClick;
  (GetByName('ButStart') as TGraphButtonGI).UpCallback := StartClick;
  with GetByName('ButGroup0') as TGraphButtonGI do
  begin UpCallback := CategoryClick; DownCallback := CategoryClick; end;
  with GetByName('ButGroup1') as TGraphButtonGI do
  begin UpCallback := CategoryClick; DownCallback := CategoryClick; end;
  with GetByName('ButGroup2') as TGraphButtonGI do
  begin UpCallback := CategoryClick; DownCallback := CategoryClick; end;
  with GetByName('Dif1') as TGraphButtonGI do
  begin UpCallback := DifficultyClick; DownCallback := DifficultyClick; end;
  with GetByName('Dif2') as TGraphButtonGI do
  begin UpCallback := DifficultyClick; DownCallback := DifficultyClick; end;
  with GetByName('Dif3') as TGraphButtonGI do
  begin UpCallback := DifficultyClick; DownCallback := DifficultyClick; end;
  RobotMapNameColor := GetStyleColorGI('LoadRobot.MapsNameColor', 88, 229, 255);
end;
{ @end $55CC7C }

{ @routine $55D180 TfLoadRobot_OnOpen }
procedure TfLoadRobot.OnOpen;
var StartText, WinText, LossText, TerronName: WideString;
begin
  inherited OnOpen;
  LoadPanel.OnOpen;
  KeyHistory := '';
  if BattleResult = 1 then
  begin
    if Entries[SelectedIndex].MapIndex >= 0 then
    begin
      StartText := RobotMapDefinitions[Entries[SelectedIndex].MapIndex].RobotsStart;
      WinText := RobotMapDefinitions[Entries[SelectedIndex].MapIndex].RobotsWin;
      LossText := RobotMapDefinitions[Entries[SelectedIndex].MapIndex].RobotsLoss;
    end
    else
    begin
      StartText := LocalizedText('FormLoadRobot.StdBegin');
      WinText := LocalizedText('FormLoadRobot.StdVictory');
      LossText := LocalizedText('FormLoadRobot.StdDefeat');
    end;
    ReplaceTextToken(StartText, '<Star>', LocalizedText('FormLoadRobot.PStar'), TextHighlightColorTag);
    ReplaceTextToken(StartText, '<Planet>', LocalizedText('FormLoadRobot.PPlanet'), TextHighlightColorTag);
    ReplaceTextToken(StartText, '<Player>', LocalizedText('FormLoadRobot.PPlayer'), TextHighlightColorTag);
    ExpandLocalizedTextMarkupAndPrefixLines(StartText);
    StartText := WideString(IntToStr(Difficulty)) + StartText;
    StartText := WideString(IntToStr(2)) + StartText;
    StartText := WideString(IntToStr(3)) + StartText;
    ReplaceTextToken(WinText, '<Star>', LocalizedText('FormLoadRobot.PStar'), TextHighlightColorTag);
    ReplaceTextToken(WinText, '<Planet>', LocalizedText('FormLoadRobot.PPlanet'), TextHighlightColorTag);
    ReplaceTextToken(WinText, '<Player>', LocalizedText('FormLoadRobot.PPlayer'), TextHighlightColorTag);
    ExpandLocalizedTextMarkupAndPrefixLines(WinText);
    ReplaceTextToken(LossText, '<Star>', LocalizedText('FormLoadRobot.PStar'), TextHighlightColorTag);
    ReplaceTextToken(LossText, '<Planet>', LocalizedText('FormLoadRobot.PPlanet'), TextHighlightColorTag);
    ReplaceTextToken(LossText, '<Player>', LocalizedText('FormLoadRobot.PPlayer'), TextHighlightColorTag);
    ExpandLocalizedTextMarkupAndPrefixLines(LossText);
    TerronName := LocalizedText('FormLoadRobot.PPlace');
    LoadPanel.OnOpen;
    LoadPanel.SelectBackgroundStyle(3);
    LoadPanel.RefreshBackgroundImages;
    BattleResult := FRun(Entries[SelectedIndex].FileName, StartText, WinText, LossText, TerronName);
    PostMouseMoveMessage;
    if BattleResult <> 0 then
    begin
      if Entries[SelectedIndex].MapIndex >= 0 then
      begin
        if BattleResult = 3 then
        begin
          LoadCompletionData;
          if Difficulty = 1 then
            RecordCompletion(RobotMapDefinitions[Entries[SelectedIndex].MapIndex].Id, -RobotBattleStatistics.SignedTimeMs div 1000, 2)
          else RecordCompletion(RobotMapDefinitions[Entries[SelectedIndex].MapIndex].Id, -RobotBattleStatistics.SignedTimeMs div 1000, 1);
          SaveCompletionData;
        end;
      end;
      BattleResult := 0;
      RequestedScreenId := screenLoadRobot;
      RequestClose(1);
    end;
  end
  else
  begin
    if BattleResult = 0 then
    begin
      if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True, 0);
      (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
    end
    else BattleResult := 0;
    with GetByName('ButGroup0') as TGraphButtonGI do SetDown(Category = 0);
    with GetByName('ButGroup1') as TGraphButtonGI do SetDown(Category = 1);
    with GetByName('ButGroup2') as TGraphButtonGI do SetDown(Category = 2);
    RebuildEntries;
    (GetByName('Dif1') as TGraphButtonGI).SetDown(Difficulty = 1);
    (GetByName('Dif2') as TGraphButtonGI).SetDown(Difficulty = 2);
    (GetByName('Dif3') as TGraphButtonGI).SetDown(Difficulty = 3);
    SelectEntry(0);
  end;
end;
{ @end $55D180 }

{ @routine $55DA2C TfLoadRobot_OnClose }
procedure TfLoadRobot.OnClose;
begin
  if BattleResult = 0 then Entries := nil;
  LoadPanel.OnClose;
  inherited OnClose;
end;
{ @end $55DA2C }

{ @routine $55DA6C TfLoadRobot_CloseClick }
procedure TfLoadRobot.CloseClick(Sender: TObjectGI);
begin
  AuxRenderBuffer.Clear;
  RequestedScreenId := screenMainMenu;
  RequestClose(1);
end;
{ @end $55DA6C }

{ @routine $55DAA0 TfLoadRobot_KeyDown }
procedure TfLoadRobot.KeyDown(Sender: TObjectGI; Key: Cardinal);
var CheatKeys: Boolean;
    I, MapId: Integer;
begin
  CheatKeys := False;
  if IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) then
  begin
    KeyHistory := KeyHistory + WideChar(Key);
    CheatKeys := True;
  end;
  if CheatKeys then
  begin
    if FindTextOffsetW(KeyHistory, 'WIN') >= 0 then
    begin
      KeyHistory := '';
      if (SelectedIndex >= 0) and (SelectedIndex <= High(Entries)) and (Entries[SelectedIndex].MapIndex >= 0) then
      begin
        LoadCompletionData;
        while (Entries[SelectedIndex].MapIndex >= 0) and (Entries[SelectedIndex].MapIndex <= High(RobotMapDefinitions)) do
        begin
          MapId := RobotMapDefinitions[Entries[SelectedIndex].MapIndex].Id;
          if (MapId >= 0) and (MapId < (High(CompletionData) + 1) div 2) and (CompletionData[MapId * 2 + 1] <> 0) then Break;
          RecordCompletion(MapId, 0, 1);
          SaveCompletionData;
          RebuildEntries;
          Break;
        end;
      end;
    end;
  end;
  if Key = VK_ESCAPE then CloseClick(Sender)
  else if Key = Ord('R') then CloseClick(Sender)
  else if Key = VK_PRIOR then
  begin
    with GetByName('PanelSlot') as TPanelScrollBarGI do
      if VerticalScrollBar.Active then VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.LargeChange);
  end
  else if Key = VK_NEXT then
  begin
    with GetByName('PanelSlot') as TPanelScrollBarGI do
      if VerticalScrollBar.Active then VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.LargeChange);
  end
  else if Key = VK_HOME then
  begin
    if (High(Entries) + 1 > 0) and (Entries[0].Access <= UnlockedAccess) then SelectEntry(0);
  end
  else if Key = VK_END then
  begin
    for I := High(Entries) downto 0 do
      if Entries[I].Access <= UnlockedAccess then
      begin SelectEntry(I); Break; end;
  end
  else if Key = VK_UP then
  begin
    EntryMouseLeave(nil);
    if SelectedIndex > 0 then SelectEntry(SelectedIndex - 1)
    else if (High(Entries) + 1 > 0) and (Entries[0].Access <= UnlockedAccess) then SelectEntry(0);
  end
  else if Key = VK_DOWN then
  begin
    EntryMouseLeave(nil);
    if SelectedIndex >= 0 then
    begin
      if (SelectedIndex < High(Entries)) and (Entries[SelectedIndex + 1].Access <= UnlockedAccess) then SelectEntry(SelectedIndex + 1);
    end
    else if (High(Entries) + 1 > 0) and (Entries[0].Access <= UnlockedAccess) then SelectEntry(0);
  end
  else if Key = VK_RETURN then StartClick(nil)
  else if Key = VK_TAB then
  begin
    EntryMouseLeave(nil);
    if Category = 0 then CategoryClick(GetByName('ButGroup1'))
    else if Category = 1 then CategoryClick(GetByName('ButGroup2'))
    else if Category = 2 then CategoryClick(GetByName('ButGroup0'));
  end;
end;
{ @end $55DAA0 }

{ @routine $55E044 TfLoadRobot_ProcessMouseWheel }
procedure TfLoadRobot.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
var Panel: TPanelScrollBarGI;
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
{ @end $55E044 }

{ @routine $55E198 TfLoadRobot_InsertEntry }
function TfLoadRobot.InsertEntry(Access: Integer): Integer;
var I, J: Integer;
begin
  I := 0;
  while (I <= High(Entries)) and (Entries[I].Access <= Access) do Inc(I);
  SetLength(Entries, High(Entries) + 1 + 1);
  for J := High(Entries) downto I + 1 do Entries[J] := Entries[J - 1];
  Entries[I].Access := Access;
  Result := I;
end;
{ @end $55E198 }

{ @routine $55E280 TfLoadRobot_RebuildEntries }
procedure TfLoadRobot.RebuildEntries;
var
  I, EntryIndex, Y: Integer;
  Panel: TPanelScrollBarGI;
  EntryPanel: TPanelGI;
  Alternate: Boolean;
  Path: WideString;
  FindHandle: Cardinal;
  FindData: TWin32FindDataW;
begin
  Panel := GetByName('PanelSlot') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  LoadCompletionData;
  Y := 0;
  Entries := nil;
  if (Category = 0) or (Category = 1) then
  begin
    for I := 0 to High(RobotMapDefinitions) do
      if RobotMapDefinitions[I].Group = Category then
      begin
        EntryIndex := InsertEntry(RobotMapDefinitions[I].Access);
        Entries[EntryIndex].Name := RobotMapDefinitions[I].Name;
        Entries[EntryIndex].FileName := RobotMapDefinitions[I].Map;
        Entries[EntryIndex].MapIndex := I;
        Entries[EntryIndex].Side := RobotMapDefinitions[I].Side;
        Entries[EntryIndex].Length := RobotMapDefinitions[I].Length;
      end;
  end
  else
  begin
    for I := 0 to High(RobotMapDefinitions) do
      if RobotMapDefinitions[I].Group = Category then
      begin
        EntryIndex := InsertEntry(0);
        Entries[EntryIndex].Name := RobotMapDefinitions[I].Name;
        Entries[EntryIndex].FileName := RobotMapDefinitions[I].Map;
        Entries[EntryIndex].MapIndex := I;
        Entries[EntryIndex].Side := RobotMapDefinitions[I].Side;
        Entries[EntryIndex].Length := RobotMapDefinitions[I].Length;
      end;
    Path := '';
    if InstallConfig.CountParams('RobotPath') > 0 then Path := InstallConfig.GetParam('RobotPath');
    FindHandle := Windows.FindFirstFileW(PWideChar(Path + 'Matrix\Map\*.cmap'), FindData);
    if FindHandle <> INVALID_HANDLE_VALUE then
    begin
      repeat
        if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
        begin
          Path := TrimWideString(LowerCaseWideString(WideString(FindData.cFileName)));
          I := 0;
          while I <= High(RobotMapDefinitions) do
          begin
            if Path = TrimWideString(LowerCaseWideString(RobotMapDefinitions[I].Map)) then Break;
            Inc(I);
          end;
          if I > High(RobotMapDefinitions) then
          begin
            EntryIndex := InsertEntry(0);
            Entries[EntryIndex].Name := ExtractFileNameNoExtW(WideString(FindData.cFileName));
            Entries[EntryIndex].FileName := WideString(FindData.cFileName);
            Entries[EntryIndex].MapIndex := -1;
            Entries[EntryIndex].Side := 0;
            Entries[EntryIndex].Length := -1;
          end;
        end;
      until not Windows.FindNextFileW(FindHandle, FindData);
      Windows.FindClose(FindHandle);
    end;
  end;
  UnlockedAccess := GetUnlockedAccess;
  Alternate := True;
  EntryIndex := -100;
  for I := 0 to High(Entries) do
  begin
    if I <> 0 then Inc(Y, GiScalePixels(5));
    if Entries[I].Access <> EntryIndex then
    begin
      Alternate := not Alternate;
      EntryIndex := Entries[I].Access;
    end;
    Entries[I].AlternateBackground := Alternate;
    EntryPanel := TPanelGI.Create(Panel);
    EntryPanel.UserValue := I;
    EntryPanel.SetPosition(Classes.Point(0, Y));
    BuildEntryPanel(EntryPanel);
    Inc(Y, EntryPanel.ClientSize.Y);
    EntryPanel.SetPositionModeW(True);
    Panel.VerticalScrollBar.SetSmallChange(EntryPanel.ClientSize.Y + GiScalePixels(5));
    UpdateEntryImage(I);
  end;
  Panel.UpdateScrollRanges;
  Panel.VerticalScrollBar.SetActive(Panel.ClientSize.Y < Y);
  Panel.VerticalScrollBar.SetLargeChange(Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetPageSize(Panel.ClientSize.Y);
  I := Panel.VerticalScrollBar.Position;
  Panel.VerticalScrollBar.SetPosition(I - 1);
  Panel.VerticalScrollBar.SetPosition(I);
  if (SelectedIndex < 0) or (SelectedIndex >= High(Entries) + 1) then SelectedIndex := -1;
  SelectEntry(SelectedIndex);
  Panel.Invalidate;
end;
{ @end $55E280 }

{ @routine $55E9E4 TfLoadRobot_BuildEntryPanel }
procedure TfLoadRobot.BuildEntryPanel(Panel: TObjectGI);
var Index, MapIndex, RightEdge, MapId, Hours, Minutes, Seconds: Integer;
    TimeText: WideString;
begin
  Index := Panel.UserValue;
  Panel.MouseEnterCallback := EntryMouseEnter;
  Panel.MouseLeaveCallback := EntryMouseLeave;
  Panel.LeftButtonDownCallback := EntryMouseDown;
  Panel.LeftButtonDoubleClickCallback := EntryDoubleClick;
  Entries[Index].Image := TImageGI.Create(Panel);
  with Entries[Index].Image do
  begin
    SetPosition(Classes.Point(0, 0));
    SetDepth(10);
    if Entries[Index].Access <= UnlockedAccess then
    begin
      if not Entries[Index].AlternateBackground then
        SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'SlotNormal')
      else SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'SlotNormal2');
    end
    else SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'SlotDisabled');
    SetSize(GetContentSize);
    Panel.SetSize(ClientSize);
    SetActive(True);
  end;
  RightEdge := GiScalePixels(313);
  if (Entries[Index].Side and 4) <> 0 then
    with TImageGI.Create(Panel) do
    begin
      SetDepth(9);
      if Entries[Index].Access <= UnlockedAccess then
        SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'IconKeller')
      else SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'IconKellerD');
      SetSize(GetContentSize);
      SetPosition(Classes.Point(RightEdge - ClientSize.X, Panel.ClientSize.Y div 2 - ClientSize.Y div 2));
      SetActive(True);
      RightEdge := RightEdge - ClientSize.X - 1;
    end;
  if (Entries[Index].Side and 2) <> 0 then
    with TImageGI.Create(Panel) do
    begin
      SetDepth(9);
      if Entries[Index].Access <= UnlockedAccess then
        SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'IconTerron')
      else SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'IconTerronD');
      SetSize(GetContentSize);
      SetPosition(Classes.Point(RightEdge - ClientSize.X, Panel.ClientSize.Y div 2 - ClientSize.Y div 2));
      SetActive(True);
      RightEdge := RightEdge - ClientSize.X - 1;
    end;
  if (Entries[Index].Side and 1) <> 0 then
    with TImageGI.Create(Panel) do
    begin
      SetDepth(9);
      if Entries[Index].Access <= UnlockedAccess then
        SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'IconBlazer')
      else SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'IconBlazerD');
      SetSize(GetContentSize);
      SetPosition(Classes.Point(RightEdge - ClientSize.X, Panel.ClientSize.Y div 2 - ClientSize.Y div 2));
      SetActive(True);
      RightEdge := RightEdge - ClientSize.X - 1;
    end;
  MapIndex := Entries[Index].MapIndex;
  if (MapIndex >= 0) and (MapIndex <= High(RobotMapDefinitions)) then
  begin
    MapId := RobotMapDefinitions[MapIndex].Id;
    if (MapId >= 0) and (MapId < (High(CompletionData) + 1) div 2) then
    begin
      MapIndex := CompletionData[MapId * 2 + 1];
      if MapIndex <> 0 then
        with TImageGI.Create(Panel) do
        begin
          SetPosition(Classes.Point(0, 0));
          SetDepth(9);
          if MapIndex = 1 then SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + '_06')
          else SetImagePath('GI,Bm.FormRewards.' + GiResourceSuffix + '_13');
          SetSize(GetContentSize);
          SetPosition(Classes.Point(Panel.ClientSize.X - ClientSize.X - GiScalePixels(10), Panel.ClientSize.Y div 2 - ClientSize.Y div 2));
          SetActive(True);
        end;
    end;
  end;
  with TLabelGI.Create(Panel) do
  begin
    if GiResourceVariant = 1 then
    begin
      SetPosition(Classes.Point(11, 0));
      SetSize(Classes.Point(RightEdge - LocalPosition.X, Panel.ClientSize.Y));
    end
    else
    begin
      SetPosition(Classes.Point(14, 0));
      SetSize(Classes.Point(RightEdge - LocalPosition.X, Panel.ClientSize.Y));
    end;
    SetDepth(7);
    SetFontName(NormalFontName);
    SetTextAlignX(taxLeft);
    SetTextAlignY(tayCenterEx);
    SetText(Entries[Index].Name);
    if Entries[Index].Access <= UnlockedAccess then SetTextColor(RobotMapNameColor)
    else SetTextColor(CurrentPixelFormat.PackRgbBytes(112, 112, 112));
  end;
  with TLabelGI.Create(Panel) do
  begin
    if GiResourceVariant = 1 then
    begin
      SetPosition(Classes.Point(252, 0));
      SetSize(Classes.Point(109, Panel.ClientSize.Y));
    end
    else
    begin
      SetPosition(Classes.Point(323, 0));
      SetSize(Classes.Point(140, Panel.ClientSize.Y));
    end;
    SetDepth(7);
    SetFontName(NormalFontName);
    SetTextAlignX(taxRight);
    SetTextAlignY(tayCenterEx);
    MapIndex := Entries[Index].MapIndex;
    repeat
      if (MapIndex >= 0) and (MapIndex <= High(RobotMapDefinitions)) then
      begin
        MapId := RobotMapDefinitions[MapIndex].Id;
        if (MapId >= 0) and (MapId < (High(CompletionData) + 1) div 2) and
           (CompletionData[MapId * 2 + 1] <> 0) then
        begin
          RightEdge := CompletionData[MapId * 2];
          Hours := RightEdge div 3600;
          Minutes := (RightEdge - Hours * 3600) div 60;
          Seconds := RightEdge - Hours * 3600 - Minutes * 60;
          if Hours < 10 then TimeText := TimeText + '0';
          TimeText := TimeText + WideString(IntToStr(Hours)) + ':';
          if Minutes < 10 then TimeText := TimeText + '0';
          TimeText := TimeText + WideString(IntToStr(Minutes)) + ':';
          if Seconds < 10 then TimeText := TimeText + '0';
          TimeText := TimeText + WideString(IntToStr(Seconds));
          TimeText := ReplaceAllWideString(LocalizedText('FormLoadRobot.Time'), '<Val>', TimeText);
          SetText(TimeText);
          Break;
        end;
      end;
      if Entries[Index].Length < 0 then SetText('')
      else SetText(LocalizedText(WideString('FormLoadRobot.Length' + IntToStr(Entries[Index].Length))));
    until True;
    if Entries[Index].Access <= UnlockedAccess then SetTextColor(RobotMapNameColor)
    else SetTextColor(CurrentPixelFormat.PackRgbBytes(112, 112, 112));
  end;
end;
{ @end $55E9E4 }

{ @routine $55F810 TfLoadRobot_SelectEntry }
procedure TfLoadRobot.SelectEntry(Index: Integer);
var Previous: Integer;
    Panel: TPanelScrollBarGI;
    EntryPanel: TObjectGI;
begin
  Previous := SelectedIndex;
  SelectedIndex := Index;
  if SelectedIndex >= High(Entries) + 1 then SelectedIndex := -1;
  if (SelectedIndex >= 0) and (Entries[SelectedIndex].Access > UnlockedAccess) then SelectedIndex := -1;
  UpdateEntryImage(Previous);
  UpdateEntryImage(SelectedIndex);
  if (Index < 0) or (Index > High(Entries)) then
  begin
    UpdateSelectionDetails;
    Exit;
  end;
  if SelectedIndex >= 0 then
  begin
    Panel := GetByName('PanelSlot') as TPanelScrollBarGI;
    EntryPanel := Entries[SelectedIndex].Image.Parent;
    Panel.ScrollRectIntoView(EntryPanel.GetLocalBounds);
  end;
  UpdateSelectionDetails;
end;
{ @end $55F810 }

{ @routine $55F958 TfLoadRobot_UpdateEntryImage }
procedure TfLoadRobot.UpdateEntryImage(Index: Integer);
var Image: TImageGI;
begin
  if (Index < 0) or (Index > High(Entries)) then Exit;
  Image := Entries[Index].Image;
  if Entries[Index].Access > UnlockedAccess then Exit;
  if SelectedIndex = Index then
    Image.SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'SlotActive')
  else if HoveredIndex = Index then
    Image.SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'SlotOnMouse')
  else if not Entries[Index].AlternateBackground then
    Image.SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'SlotNormal')
  else
    Image.SetImagePath('GI,Bm.FormLoadRobot.' + GiResourceSuffix + 'SlotNormal2');
end;
{ @end $55F958 }

{ @routine $55FB8C TfLoadRobot_EntryMouseEnter }
procedure TfLoadRobot.EntryMouseEnter(Sender: TObjectGI);
var Previous: Integer;
begin
  if BattleResult <> 0 then Exit;
  if HoveredIndex = Sender.UserValue then Exit;
  Previous := HoveredIndex;
  HoveredIndex := Sender.UserValue;
  UpdateEntryImage(Previous);
  UpdateEntryImage(HoveredIndex);
end;
{ @end $55FB8C }

{ @routine $55FBF8 TfLoadRobot_EntryMouseLeave }
procedure TfLoadRobot.EntryMouseLeave(Sender: TObjectGI);
var Previous: Integer;
begin
  if BattleResult <> 0 then Exit;
  if HoveredIndex = -1 then Exit;
  Previous := HoveredIndex;
  HoveredIndex := -1;
  UpdateEntryImage(Previous);
  UpdateEntryImage(HoveredIndex);
end;
{ @end $55FBF8 }

{ @routine $55FC58 TfLoadRobot_EntryMouseDown }
procedure TfLoadRobot.EntryMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if BattleResult <> 0 then Exit;
  SoundManager.PlaySound('Sound.ButtonClick');
  SelectEntry(Sender.UserValue);
end;
{ @end $55FC58 }

{ @routine $55FCD0 TfLoadRobot_EntryDoubleClick }
procedure TfLoadRobot.EntryDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  StartClick(nil);
end;
{ @end $55FCD0 }

{ @routine $55FCFC TfLoadRobot_CategoryClick }
procedure TfLoadRobot.CategoryClick(Sender: TObjectGI);
var NewCategory: Integer;
    Panel: TPanelScrollBarGI;
begin
  NewCategory := ExtractDigitsToIntW(Sender.ControlName);
  (GetByName('ButGroup0') as TGraphButtonGI).SetDown(NewCategory = 0);
  (GetByName('ButGroup1') as TGraphButtonGI).SetDown(NewCategory = 1);
  (GetByName('ButGroup2') as TGraphButtonGI).SetDown(NewCategory = 2);
  if Category = NewCategory then Exit;
  Panel := GetByName('PanelSlot') as TPanelScrollBarGI;
  Panel.ScrollRectIntoView(Classes.Rect(0, 0, 1, 1));
  Category := NewCategory;
  SelectedIndex := -1;
  RebuildEntries;
  SelectEntry(0);
end;
{ @end $55FCFC }

{ @routine $55FE5C TfLoadRobot_DifficultyClick }
procedure TfLoadRobot.DifficultyClick(Sender: TObjectGI);
var NewDifficulty: Integer;
begin
  NewDifficulty := ExtractDigitsToIntW(Sender.ControlName);
  (GetByName('Dif1') as TGraphButtonGI).SetDown(NewDifficulty = 1);
  (GetByName('Dif2') as TGraphButtonGI).SetDown(NewDifficulty = 2);
  (GetByName('Dif3') as TGraphButtonGI).SetDown(NewDifficulty = 3);
  if Difficulty <> NewDifficulty then Difficulty := NewDifficulty;
end;
{ @end $55FE5C }

{ @routine $55FF30 TfLoadRobot_StartClick }
procedure TfLoadRobot.StartClick(Sender: TObjectGI);
begin
  if BattleResult <> 0 then Exit;
  if (SelectedIndex < 0) or (SelectedIndex > High(Entries)) then Exit;
  BattleResult := 1;
  RequestedScreenId := screenLoadRobot;
  LoadPanel.SelectBackgroundStyle(3);
  LoadPanel.RefreshBackgroundImages;
  LoadPanel.StartClosingShutters;
end;
{ @end $55FF30 }

{ @routine $55FFB8 TfLoadRobot_UpdateSelectionDetails }
procedure TfLoadRobot.UpdateSelectionDetails;
var Text, MapName, Extension: WideString;
    F: TFileEC;
    Success: Boolean;
    Buffer: TBufEC;
begin
  with GetByName('ButStart') as TGraphButtonGI do
    SetDisabled((SelectedIndex < 0) or (SelectedIndex > High(Entries)));
  with GetByName('ImageMap') as TGraphBufGI do
  begin
    SetActive(False);
    if (SelectedIndex >= 0) and (SelectedIndex <= High(Entries)) then
    begin
      if CountDelimitedPartsW(Entries[SelectedIndex].FileName, '\/') = 1 then
        Text := 'Matrix\Map\' + ExtractFileNameNoExtW(Entries[SelectedIndex].FileName) + '.jpg'
      else
      begin
        MapName := Entries[SelectedIndex].FileName;
        Extension := ExtractDelimitedPartW(MapName, CountDelimitedPartsW(MapName, '.') - 1, '.');
        Text := ReplaceAllWideString(Entries[SelectedIndex].FileName, Extension, 'jpg');
      end;
      F := TFileEC.Create;
      F.SetFileName(Text);
      Success := F.TryAcquireReadHandle(False);
      if Success then
      begin
        Buffer := TBufEC.Create;
        Buffer.SetSize(F.GetSize);
        F.ReadBuffer(Buffer.Data, Buffer.DataSize);
        SetActive(True);
        GraphBuf.LoadImageRgb(Buffer);
        SourceHasPerPixelAlpha := False;
        if (ClientSize.X <> GraphBuf.Width) or (ClientSize.Y <> GraphBuf.Height) then
          GraphBuf.RescaleRgb(ClientSize.X, ClientSize.Y);
        GraphBuf.ConvertRgbTo565;
        Invalidate;
        Buffer.Free;
      end;
      F.Free;
    end;
  end;
  with GetByName('MessageText') as TLabelGI do
  begin
    SetActive(False);
    if (SelectedIndex >= 0) and (SelectedIndex <= High(Entries)) and
       (Entries[SelectedIndex].MapIndex >= 0) and (Entries[SelectedIndex].MapIndex <= High(RobotMapDefinitions)) then
    begin
      SetActive(True);
      Text := RobotMapDefinitions[Entries[SelectedIndex].MapIndex].GovTextStart;
      ReplaceTextToken(Text, '<Star>', LocalizedText('FormLoadRobot.PStar'), BrightBlueColorTag);
      ReplaceTextToken(Text, '<Planet>', LocalizedText('FormLoadRobot.PPlanet'), BrightBlueColorTag);
      ReplaceTextToken(Text, '<Player>', LocalizedText('FormLoadRobot.PPlayer'), BrightBlueColorTag);
      ReplaceTextToken(Text, '<Money>', WideString(IntToStr(1000)), BrightBlueColorTag);
      SetText(Text);
      Text := RobotMapDefinitions[Entries[SelectedIndex].MapIndex].FromAuthor;
      if Text <> '' then SetText(GetText + #13#10 + ' ' + #13#10 + Text);
    end;
  end;
  with GetByName('MessageWindow') as TPanelScrollBarGI do
  begin
    SetScrollOffset(Classes.Point(0, 0));
    UpdateScrollRanges;
    VerticalScrollBar.SetActive(FindByNameRecursive('MessageText').Active and
      ((FindByNameRecursive('MessageText') as TLabelGI).ClientSize.Y > ClientSize.Y));
    VerticalScrollBar.SetSmallChange((FindByNameRecursive('MessageText') as TLabelGI).GetLineHeight);
    VerticalScrollBar.SetLargeChange(ClientSize.Y);
    VerticalScrollBar.SetPageSize(ClientSize.Y);
  end;
  Success := False;
  with GetByName('Dif2') as TGraphButtonGI do
  begin
    SetDisabled(False);
    if (SelectedIndex >= 0) and (SelectedIndex <= High(Entries)) and
       (Entries[SelectedIndex].MapIndex >= 0) and (Entries[SelectedIndex].MapIndex <= High(RobotMapDefinitions)) then
    begin
      if RobotMapDefinitions[Entries[SelectedIndex].MapIndex].ReinforcementsDisabled then
      begin
        if Down then
        begin SetDown(False); Success := True; end;
        SetDisabled(True);
      end;
    end;
  end;
  if Success then (GetByName('Dif1') as TGraphButtonGI).SetDown(True);
end;
{ @end $55FFB8 }

{ @routine $560858 TfLoadRobot_LoadCompletionData }
procedure TfLoadRobot.LoadCompletionData;
var
  Buffer: TBufEC;
  I, Count: Integer;
  FileName: WideString;
begin
  CompletionData := nil;
  FileName := GetGameUserDirectory + 'robotcomplate.dat';
  if SysUtils.FileExists(AnsiString(FileName)) then
  begin
    try
      Buffer := TBufEC.Create;
      Buffer.LoadFromWideFilePath(PWideChar(FileName));
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
{ @end $560858 }

{ @routine $560A00 TfLoadRobot_SaveCompletionData }
procedure TfLoadRobot.SaveCompletionData;
var
  Buffer: TBufEC;
  F: TFileEC;
  I: Integer;
  FileName: AnsiString;
begin
  Buffer := TBufEC.Create;
  Buffer.AddDWord(0);
  Buffer.AddInteger(High(CompletionData) + 1);
  for I := 0 to High(CompletionData) do Buffer.AddIntegerValue(CompletionData[I]);
  PCardinal(Buffer.Data)^ := Buffer.ComputeCrc32Range(4, Buffer.DataSize);
  F := TFileEC.Create;
  FileName := AnsiString(GetGameUserDirectory + 'robotcomplate.dat');
  F.SetFileName(WideString(FileName));
  F.CreateNew;
  F.WriteBuffer(Buffer.Data, Buffer.DataSize);
  F.Free;
  Buffer.Free;
end;
{ @end $560A00 }

{ @routine $560B74 TfLoadRobot_RecordCompletion }
procedure TfLoadRobot.RecordCompletion(MapId, Score, Level: Integer);
var
  Count, Index: Integer;
begin
  Count := (High(CompletionData) + 1) div 2;
  if MapId >= Count then
  begin
    SetLength(CompletionData, 2 * (MapId + 1));
    for Index := 2 * Count to High(CompletionData) do CompletionData[Index] := 0;
  end;
  if CompletionData[2 * MapId + 1] > Level then Exit;
  if (CompletionData[2 * MapId] = 0) or (CompletionData[2 * MapId + 1] < Level) then
    CompletionData[2 * MapId] := Score
  else CompletionData[2 * MapId] := Min(CompletionData[2 * MapId], Score);
  CompletionData[2 * MapId + 1] := Level;
end;
{ @end $560B74 }

{ @routine $560CBC TfLoadRobot_GetUnlockedAccess }
function TfLoadRobot.GetUnlockedAccess: Integer;
var I, MapIndex, Access, Count, Completed, MapId: Integer;
begin
  Result := 0;
  I := 0;
  while I <= High(Entries) do
  begin
    Access := Entries[I].Access;
    Count := 0;
    Completed := 0;
    while I + Count <= High(Entries) do
    begin
      if Entries[I + Count].Access <> Access then Break;
      MapIndex := Entries[I + Count].MapIndex;
      if (MapIndex >= 0) and (MapIndex <= High(RobotMapDefinitions)) then
      begin
        MapId := RobotMapDefinitions[MapIndex].Id;
        if (MapId >= 0) and (MapId < (High(CompletionData) + 1) div 2) then
          if (MapId < (High(CompletionData) + 1) div 2) and (CompletionData[MapId * 2 + 1] <> 0) then Inc(Completed);
      end;
      Inc(Count);
    end;
    Result := Access;
    if (Access > 0) and (Completed < Count - 1) then Break;
    Inc(I, Count);
  end;
  if Result = 0 then Result := 1;
end;
{ @end $560CBC }

{ @routine $560E18 TfLoadRobot_GetCompletionCounts }
function TfLoadRobot.GetCompletionCounts: TPoint;
var I, CompletionIndex: Integer;
begin
  LoadCompletionData;
  Result.X := 0;
  Result.Y := 0;
  for I := 0 to High(RobotMapDefinitions) do
  begin
    if RobotMapDefinitions[I].Group > -1 then Inc(Result.Y);
    CompletionIndex := RobotMapDefinitions[I].Id;
    if (CompletionIndex >= 0) and (RobotMapDefinitions[I].Group > -1) then
      if (High(CompletionData) + 1) div 2 > CompletionIndex then
        if CompletionData[CompletionIndex * 2 + 1] <> 0 then Inc(Result.X);
  end;
end;
{ @end $560E18 }

{ @routine $560EF0 TfLoadRobot_GetCompletionSummary }
function TfLoadRobot.GetCompletionSummary: WideString;
var Counts: TPoint;
    I, Total: Integer;
begin
  Counts := GetCompletionCounts;
  Total := 0;
  for I := 0 to High(RobotMapDefinitions) do
    if RobotMapDefinitions[I].Group in [0, 1, 2] then Inc(Total);
  Result := IntToStr(Counts.X) + '/' + IntToStr(Total);
end;
{ @end $560EF0 }

{ @routine $560FD0 TfLoadRobot_SelectMusic }
procedure TfLoadRobot.SelectMusic;
begin
end;
{ @end $560FD0 }

end.
