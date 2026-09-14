unit fLoadAB;
// Unit bracket (inferred): .text 0x005FE390..0x00600129; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_Image, GI_MessageLoop, Types;

type
  TfLoadABSlot = record // @size $1C Native RTTI name and managed-field offsets.
    Name: WideString; // @offset $00
    MapName: WideString; // @offset $04
    ImageName: WideString; // @offset $08
    Description: WideString; // @offset $0C Produced by the native multiline helper.
    ConfigIndex: Integer; // @offset $10
    BackgroundImage: TImageGI; // @offset $14 Borrowed from the row control.
    Difficulty: Integer; // @offset $18
  end;

  TfLoadAB = class(TMessageLoopGI) // @size $E4
  public
    Entries: array of TfLoadABSlot; // @offset $D0
    SelectedIndex: Integer; // @offset $D4
    HoveredIndex: Integer; // @offset $D8
    Category: Integer; // @offset $DC
    KeyHistory: WideString; // @offset $E0

    constructor Create; // @addr $5FE45C @ida "TfLoadAB *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $5FE4B8 @ida "void __usercall $name(TfLoadAB *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure OnOpen; override; // @addr $5FE82C
    procedure OnClose; override; // @addr $5FE948
    procedure SelectMusic; override; // @addr $600120
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $5FEC14 @ida "void __userpurge $name(TfLoadAB *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure InitializeLayout; override; // @addr $5FE4EC
    procedure ReturnToMenu(Sender: TObjectGI); // @addr $5FE984
    procedure ArenaListKeyDown(Sender: TObjectGI; VirtualKey: Cardinal); // @addr $5FE9B8
    function AppendEntry(IgnoredAccess: Integer): Integer; // @addr $5FED68
    procedure RebuildArenaList; // @addr $5FEF2C
    procedure InitializeArenaRow(Row: TObjectGI); // @addr $5FF3A8
    procedure SelectArena(Index: Integer); // @addr $5FF710
    procedure UpdateArenaRow(Index: Integer); // @addr $5FF820
    procedure ArenaRowMouseEnter(Sender: TObjectGI); // @addr $5FF964
    procedure ArenaRowMouseLeave(Sender: TObjectGI); // @addr $5FF9C4
    procedure ArenaRowMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5FFA18 @ida "void __userpurge $name(TfLoadAB *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure ArenaRowDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5FFA88 @ida "void __userpurge $name(TfLoadAB *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure SelectCategory(Sender: TObjectGI); // @addr $5FFAB4
    procedure StartSelectedArena(Sender: TObjectGI); // @addr $5FFBD8
    procedure ShowSelectedArenaDetails; // @addr $5FFC58
    procedure PrepareCatalog; // @addr $600098 @note "Native empty hook, retained during catalog rebuild."
    function GetCatalogSummary: WideString; // @addr $6000A4 @ida "void __usercall $name(TfLoadAB *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Returns the configured ABMap entry count for the main menu."
  end;

var
  ArcadeNameColor: Cardinal; // @addr $889C08

implementation

uses GlobalsV, GR_Main, SysUtils, Classes, EC_BlockPar, EC_Buf, EC_File, EC_Str,
  GI_GraphBuf, GI_GraphButton, GI_Label, GI_Main, GI_Panel, GI_PanelScrollBar,
  GI_ScrollBar, Globals, Windows;

{ @routine $5FE45C TfLoadAB_Create }
constructor TfLoadAB.Create;
begin
  inherited Create;
  SelectedIndex := -1;
  Category := 0;
end;
{ @end $5FE45C }

{ @routine $5FE4B8 TfLoadAB_Destroy }
destructor TfLoadAB.Destroy;
begin
  inherited Destroy;
end;
{ @end $5FE4B8 }

{ @routine $5FE4EC TfLoadAB_InitializeLayout }
procedure TfLoadAB.InitializeLayout;
var
  Root, Panel: TObjectGI;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fLoadAB... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Root := GetByName('');
  Root.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Root.FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Panel := Root.FindByNameRecursive('MainPanel');
  Panel.SetPosition(Classes.Point(Panel.LocalPosition.X + ExtraScreenWidth div 2, Panel.LocalPosition.Y + ExtraScreenHeight div 2));
  AppendLogLineThreadSafe('ok');
  GetByName('MainPanel').KeyDownCallback := ArenaListKeyDown;
  (GetByName('ButClose') as TGraphButtonGI).UpCallback := ReturnToMenu;
  (GetByName('ButCancel') as TGraphButtonGI).UpCallback := ReturnToMenu;
  (GetByName('ButStart') as TGraphButtonGI).UpCallback := StartSelectedArena;
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
  ArcadeNameColor := GetStyleColorGI('LoadAB.MapsNameColor', 192, 112, 112);
end;
{ @end $5FE4EC }

{ @routine $5FE82C TfLoadAB_OnOpen }
procedure TfLoadAB.OnOpen;
begin
  inherited OnOpen;
  KeyHistory := '';
  if (PreviousScreenId <> screenArcadeBattle) and (AuxRenderBuffer.GetPixels = nil) then
    CaptureScreenBackground(True, 0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  with GetByName('ButGroup0') as TGraphButtonGI do SetDown(Category = 0);
  with GetByName('ButGroup1') as TGraphButtonGI do SetDown(Category = 1);
  RebuildArenaList;
  SelectArena(0);
end;
{ @end $5FE82C }

{ @routine $5FE948 TfLoadAB_OnClose }
procedure TfLoadAB.OnClose;
begin
  Entries := nil;
  if RequestedScreenId <> screenArcadeBattle then AuxRenderBuffer.Clear;
  inherited OnClose;
end;
{ @end $5FE948 }

{ @routine $5FE984 TfLoadAB_ReturnToMenu }
procedure TfLoadAB.ReturnToMenu(Sender: TObjectGI);
begin
  AuxRenderBuffer.Clear;
  RequestedScreenId := screenMainMenu;
  RequestClose(1);
end;
{ @end $5FE984 }

{ @routine $5FE9B8 TfLoadAB_ArenaListKeyDown }
procedure TfLoadAB.ArenaListKeyDown(Sender: TObjectGI; VirtualKey: Cardinal);
begin
  if VirtualKey = VK_ESCAPE then ReturnToMenu(Sender)
  else if VirtualKey = Ord('F') then ReturnToMenu(Sender)
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
  else if VirtualKey = VK_HOME then SelectArena(0)
  else if VirtualKey = VK_END then SelectArena(High(Entries))
  else if VirtualKey = VK_UP then
  begin
    ArenaRowMouseLeave(nil);
    if SelectedIndex > 0 then SelectArena(SelectedIndex - 1);
  end
  else if VirtualKey = VK_DOWN then
  begin
    ArenaRowMouseLeave(nil);
    if High(Entries) > SelectedIndex then SelectArena(SelectedIndex + 1);
  end
  else if VirtualKey = VK_RETURN then StartSelectedArena(nil)
  else if VirtualKey = VK_TAB then
  begin
    ArenaRowMouseLeave(nil);
    if Category = 0 then SelectCategory(GetByName('ButGroup1'))
    else SelectCategory(GetByName('ButGroup0'));
  end;
end;
{ @end $5FE9B8 }

{ @routine $5FEC14 TfLoadAB_ProcessMouseWheel }
procedure TfLoadAB.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
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
{ @end $5FEC14 }

{ @routine $5FED68 TfLoadAB_AppendEntry }
function TfLoadAB.AppendEntry(IgnoredAccess: Integer): Integer;
var
  Index, I: Integer;
begin
  Index := High(Entries) + 1;
  SetLength(Entries, High(Entries) + 2);
  { Retained native insertion loop; appending makes its range empty. }
  for I := High(Entries) downto Index + 1 do Entries[I] := Entries[I - 1];
  Result := Index;
end;
{ @end $5FED68 }

{ @routine $5FEF2C TfLoadAB_RebuildArenaList }
procedure TfLoadAB.RebuildArenaList;
var
  Entry: TBlockParEC;
  I, Index, Top, Count, EntryCategory: Integer;
  Panel: TPanelScrollBarGI;
  Row: TPanelGI;
  List: TBlockParEC;
  Name: WideString;

  // @nested $5FEE20 ReadArcadeDescription
  function ReadArcadeDescription(const Path: WideString): WideString; // @addr $5FEE20 @ida "void __usercall $name(unsigned __int16 *Path@<eax>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x5ff0ec"
  var
    J, LineCount: Integer;
  begin
    Result := '';
    LineCount := Entry.CountParamsByPath(Path);
    for J := 0 to LineCount - 1 do
    begin
      if Result <> '' then Result := Result + #13#10;
      Result := Result + Entry.GetParamByPath(Path + ':' + IntToStr(J));
    end;
  end;

begin
  Panel := GetByName('PanelSlot') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  PrepareCatalog;
  Entries := nil;
  List := LanguageDataConfig.GetBlockByPath('ABMap');
  Count := List.GetBlockCount;
  for I := 0 to Count - 1 do
  begin
    Name := List.GetBlockNameByIndex(I);
    Entry := List.GetBlockByIndex(I);
    if Entry.CountParamsByPath('Group') > 0 then
      EntryCategory := ExtractDigitsToIntW(Entry.GetParam('Group'))
    else EntryCategory := 0;
    if EntryCategory = Category then
    begin
      Index := AppendEntry(ExtractDigitsToIntW(Entry.GetParam('Access')));
      Entries[Index].Name := Entry.GetParam('Name');
      Entries[Index].ImageName := Entry.GetParamOrMarker('Image');
      Entries[Index].MapName := Entry.GetParam('Map');
      Entries[Index].Description := ReadArcadeDescription('Desc');
      Entries[Index].ConfigIndex := I;
      Entries[Index].Difficulty := ExtractDigitsToIntW(Entry.GetParamOrMarker('Dif'));
    end;
  end;
  Top := 0;
  for I := 0 to High(Entries) do
  begin
    if I <> 0 then Inc(Top, 5);
    Row := TPanelGI.Create(Panel);
    Row.UserValue := I;
    Row.SetPosition(Classes.Point(0, Top));
    InitializeArenaRow(Row);
    Inc(Top, Row.ClientSize.Y);
    Row.SetPositionModeW(True);
    Panel.VerticalScrollBar.SetSmallChange(Row.ClientSize.Y + 5);
    UpdateArenaRow(I);
  end;
  Panel.UpdateScrollRanges;
  Panel.VerticalScrollBar.SetActive(Top > Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetLargeChange(Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetPageSize(Panel.ClientSize.Y);
  I := Panel.VerticalScrollBar.Position;
  Panel.VerticalScrollBar.SetPosition(I - 1);
  Panel.VerticalScrollBar.SetPosition(I);
  if (SelectedIndex < 0) or (High(Entries) + 1 <= SelectedIndex) then SelectedIndex := -1;
  SelectArena(SelectedIndex);
  Panel.Invalidate;
end;
{ @end $5FEF2C }

{ @routine $5FF3A8 TfLoadAB_InitializeArenaRow }
procedure TfLoadAB.InitializeArenaRow(Row: TObjectGI);
var
  Index: Integer;
  Background: TImageGI;
  TitleLabel: TLabelGI;
  DifficultyImage: TImageGI;
begin
  Index := Row.UserValue;
  Row.MouseEnterCallback := ArenaRowMouseEnter;
  Row.MouseLeaveCallback := ArenaRowMouseLeave;
  Row.LeftButtonDownCallback := ArenaRowMouseDown;
  Row.LeftButtonDoubleClickCallback := ArenaRowDoubleClick;
  Entries[Index].BackgroundImage := TImageGI.Create(Row);
  Background := Entries[Index].BackgroundImage;
  Background.SetPosition(Classes.Point(0, 0));
  Background.SetDepth(10);
  Background.SetImagePath('GI,Bm.FormLoadAB.SlotNormal');
  Background.SetSize(Background.GetContentSize);
  Row.SetSize(Background.ClientSize);
  Background.SetActive(True);
  TitleLabel := TLabelGI.Create(Row);
  TitleLabel.SetPosition(Classes.Point(14, 0));
  TitleLabel.SetSize(Classes.Point(Row.ClientSize.X - 38, Row.ClientSize.Y));
  TitleLabel.SetDepth(7);
  TitleLabel.SetFontName(NormalFontName);
  TitleLabel.SetTextAlignX(taxLeft);
  TitleLabel.SetTextAlignY(tayCenterEx);
  TitleLabel.SetText(Entries[Index].Name);
  TitleLabel.SetTextColor(ArcadeNameColor);
  if (Entries[Index].ConfigIndex >= 0) and (Entries[Index].ConfigIndex < 10000) then
  begin
    DifficultyImage := TImageGI.Create(Row);
    DifficultyImage.SetDepth(9);
    DifficultyImage.SetImagePath('GI,Bm.FormLoadAB.Dif' + IntToStr(Entries[Index].Difficulty + 1));
    DifficultyImage.SetSize(DifficultyImage.GetContentSize);
    DifficultyImage.SetPosition(Classes.Point(Row.ClientSize.X - DifficultyImage.ClientSize.X - 10,
      Row.ClientSize.Y div 2 - DifficultyImage.ClientSize.Y div 2));
    DifficultyImage.SetActive(True);
  end;
end;
{ @end $5FF3A8 }

{ @routine $5FF710 TfLoadAB_SelectArena }
procedure TfLoadAB.SelectArena(Index: Integer);
var
  Previous: Integer;
begin
  Previous := SelectedIndex;
  SelectedIndex := Index;
  if High(Entries) + 1 <= SelectedIndex then SelectedIndex := -1;
  UpdateArenaRow(Previous);
  UpdateArenaRow(SelectedIndex);
  if (Index < 0) or (High(Entries) < Index) then
  begin
    ShowSelectedArenaDetails;
    Exit;
  end;
  if SelectedIndex >= 0 then
      with GetByName('PanelSlot') as TPanelScrollBarGI do
        with Entries[SelectedIndex].BackgroundImage.Parent do
          ScrollRectIntoView(GetLocalBounds);
  ShowSelectedArenaDetails;
end;
{ @end $5FF710 }

{ @routine $5FF820 TfLoadAB_UpdateArenaRow }
procedure TfLoadAB.UpdateArenaRow(Index: Integer);
var
  Image: TImageGI;
begin
  if (Index < 0) or (High(Entries) < Index) then Exit;
  Image := Entries[Index].BackgroundImage;
  if SelectedIndex = Index then Image.SetImagePath('GI,Bm.FormLoadAB.SlotActive')
  else if HoveredIndex = Index then Image.SetImagePath('GI,Bm.FormLoadAB.SlotOnMouse')
  else Image.SetImagePath('GI,Bm.FormLoadAB.SlotNormal');
end;
{ @end $5FF820 }

{ @routine $5FF964 TfLoadAB_ArenaRowMouseEnter }
procedure TfLoadAB.ArenaRowMouseEnter(Sender: TObjectGI);
var
  Previous: Integer;
begin
  if HoveredIndex <> Sender.UserValue then
  begin
    Previous := HoveredIndex;
    HoveredIndex := Sender.UserValue;
    UpdateArenaRow(Previous);
    UpdateArenaRow(HoveredIndex);
  end;
end;
{ @end $5FF964 }

{ @routine $5FF9C4 TfLoadAB_ArenaRowMouseLeave }
procedure TfLoadAB.ArenaRowMouseLeave(Sender: TObjectGI);
var
  Previous: Integer;
begin
  if HoveredIndex <> -1 then
  begin
    Previous := HoveredIndex;
    HoveredIndex := -1;
    UpdateArenaRow(Previous);
    UpdateArenaRow(HoveredIndex);
  end;
end;
{ @end $5FF9C4 }

{ @routine $5FFA18 TfLoadAB_ArenaRowMouseDown }
procedure TfLoadAB.ArenaRowMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  SoundManager.PlaySound('Sound.ButtonClick');
  SelectArena(Sender.UserValue);
  BreakUiMessage;
end;
{ @end $5FFA18 }

{ @routine $5FFA88 TfLoadAB_ArenaRowDoubleClick }
procedure TfLoadAB.ArenaRowDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  StartSelectedArena(nil);
end;
{ @end $5FFA88 }

{ @routine $5FFAB4 TfLoadAB_SelectCategory }
procedure TfLoadAB.SelectCategory(Sender: TObjectGI);
var
  NewCategory: Integer;
begin
  NewCategory := ExtractDigitsToIntW(Sender.ControlName);
  (GetByName('ButGroup0') as TGraphButtonGI).SetDown(NewCategory = 0);
  (GetByName('ButGroup1') as TGraphButtonGI).SetDown(NewCategory = 1);
  if Category <> NewCategory then
  begin
    with GetByName('PanelSlot') as TPanelScrollBarGI do ScrollRectIntoView(Classes.Rect(0, 0, 1, 1));
    Category := NewCategory;
    SelectedIndex := -1;
    RebuildArenaList;
    SelectArena(0);
  end;
end;
{ @end $5FFAB4 }

{ @routine $5FFBD8 TfLoadAB_StartSelectedArena }
procedure TfLoadAB.StartSelectedArena(Sender: TObjectGI);
begin
  if SelectedIndex < 0 then Exit;
  if High(Entries) < SelectedIndex then Exit;
  ArcadeBattleScreen.SelectedMapName := Entries[SelectedIndex].MapName;
  RequestedScreenId := screenArcadeBattle;
  RequestClose(1);
  BreakUiMessage;
end;
{ @end $5FFBD8 }

{ @routine $5FFC58 TfLoadAB_ShowSelectedArenaDetails }
procedure TfLoadAB.ShowSelectedArenaDetails;
var
  Path: WideString;
  FileHandle: TFileEC;
  Opened: Boolean;
  Buffer: TBufEC;
begin
  with GetByName('ButStart') as TGraphButtonGI do
    SetDisabled((SelectedIndex < 0) or (High(Entries) < SelectedIndex));
  with GetByName('ImageMap') as TGraphBufGI do
  begin
    SetActive(False);
    if (SelectedIndex >= 0) and (High(Entries) >= SelectedIndex) then
    begin
      if (Category = 0) and (CountDelimitedPartsW(Entries[SelectedIndex].ImageName, '\') <= 1) then
        Path := 'Data\ABMap\' + Entries[SelectedIndex].ImageName
      else Path := Entries[SelectedIndex].ImageName;
      FileHandle := TFileEC.Create;
      FileHandle.SetFileName(Path);
      Opened := FileHandle.TryAcquireReadHandle(False);
      if Opened then
      begin
        Buffer := TBufEC.Create;
        Buffer.SetSize(FileHandle.GetSize);
        FileHandle.ReadBuffer(Buffer.Data, Buffer.DataSize);
        SetActive(True);
        GraphBuf.LoadImageRgb(Buffer);
        SourceHasPerPixelAlpha := False;
        if (ClientSize.X <> GraphBuf.Width) or (ClientSize.Y <> GraphBuf.Height) then
          GraphBuf.RescaleRgb(ClientSize.X, ClientSize.Y);
        GraphBuf.ConvertRgbTo565;
        Invalidate;
        Buffer.Free;
      end;
      FileHandle.Free;
    end;
  end;
  with GetByName('MessageText') as TLabelGI do
  begin
    SetActive(False);
    if (SelectedIndex >= 0) and (High(Entries) >= SelectedIndex) then
    begin
      SetActive(True);
      SetText(Entries[SelectedIndex].Description);
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
end;
{ @end $5FFC58 }

{ @routine $600098 TfLoadAB_PrepareCatalog }
procedure TfLoadAB.PrepareCatalog;
begin
end;
{ @end $600098 }

{ @routine $6000A4 TfLoadAB_GetCatalogSummary }
function TfLoadAB.GetCatalogSummary: WideString;
begin
  Result := IntToStr(LanguageDataConfig.GetBlockByPath('ABMap').GetBlockCount);
end;
{ @end $6000A4 }

{ @routine $600120 TfLoadAB_SelectMusic }
procedure TfLoadAB.SelectMusic;
begin
end;
{ @end $600120 }

end.
