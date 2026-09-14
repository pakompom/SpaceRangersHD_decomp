unit fMods;
// Unit bracket (inferred): .text 0x00532C34..0x00538ADF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, GI_GraphButton, GI_Panel, GI_Image, Types, Classes, aModsInfo;

type
  TfModsManager = class(TMessageLoopGI) // @size $F8 Native RTTI name.
  public
    SelectedTab: Integer; // @offset $D0
    TabCount: Integer; // @offset $D4
    TabButtons: array of TGraphButtonGI; // @offset $D8
    TabPanels: array of TPanelGI; // @offset $DC
    TabHeights: array of Integer; // @offset $E0
    SelectedCounts: array of Integer; // @offset $E4
    WarningCounts: array of Integer; // @offset $E8
    ErrorCounts: array of Integer; // @offset $EC
    InvalidSelections: array of Boolean; // @offset $F0
    NeedsValidation: Boolean; // @offset $F4
    destructor Destroy; override; // @addr $532DEC @ida "void __usercall $name(TfModsManager *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitializeLayout; override; // @addr $533B68
    procedure OnOpen; override; // @addr $534F28
    procedure SelectMusic; override; // @addr $5388FC
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $5360F0 @ida "void __userpurge $name(TfModsManager *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure TabClick(Sender: TObjectGI); // @addr $5352C0
    procedure UpdateTabDisplay; // @addr $535388
    procedure ValidateSelection; // @addr $5355C0
    procedure ClearSelectionClick(Sender: TObjectGI); // @addr $5357F4
    procedure SelectAll; // @addr $53584C
    procedure DeselectAll; // @addr $535AC0
    procedure CloseClick(Sender: TObjectGI); // @addr $535C94
    procedure ApplyClick(Sender: TObjectGI); // @addr $535CCC
    procedure KeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $53607C
    procedure SwitchMouseEnter(Sender: TObjectGI); // @addr $5361A8
    procedure SwitchMouseLeave(Sender: TObjectGI); // @addr $536278
    procedure SwitchMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5367E0 @ida "void __userpurge $name(TfModsManager *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure SetModSelected(Sender: TObjectGI; Value: Boolean); // @addr $5377BC
    procedure UpdateModSwitch(Sender: TObjectGI); // @addr $53792C
    procedure ShowInfoClick(Sender: TObjectGI); // @addr $537AE0
    procedure ShowProblemsClick(Sender: TObjectGI); // @addr $537FF8
  end;

var
  ModsManagerScreen: TfModsManager = nil; // @addr $87AA24
  ModTabColor: Cardinal; // @addr $889A38
  ModTabDownColor: Cardinal; // @addr $889A3C
  ModSelectedColor: Cardinal; // @addr $889A40
  ModWarningColor: Cardinal; // @addr $889A44
  ModErrorColor: Cardinal; // @addr $889A48

function ShowModsManager(Parent: TMessageLoopGI): Integer; // @addr $538928

implementation

uses Windows, EC_Str, GR_Main, GI_PanelScrollBar, GI_ScrollBar, GI_Label, GI_MessageBox, GI_Main, Globals, aConst, GI_GraphBuf, EC_BlockPar, aMyFunction, fListBox;

{ @routine $532DEC TfModsManager_Destroy }
destructor TfModsManager.Destroy;
begin
  SetLength(TabButtons, 0);
  SetLength(TabPanels, 0);
  SetLength(TabHeights, 0);
  SetLength(SelectedCounts, 0);
  SetLength(WarningCounts, 0);
  SetLength(ErrorCounts, 0);
  SetLength(InvalidSelections, 0);
  inherited Destroy;
end;
{ @end $532DEC }

{ @routine $533B68 TfModsManager_InitializeLayout }
procedure TfModsManager.InitializeLayout;
var
  ButtonWidth, I, J, GroupIndex, SeparateGroups, Weight, CandidateWeight,
    BestWeight, Reserved28, BestIndex, Reserved30, GroupCount, AvailableTabs: Integer;
  GroupName, SectionName: WideString;
  Reserved44: Integer;
  Button: TGraphButtonGI;
  ScrollPanel: TPanelScrollBarGI;
  Info, Dependency: TModInfo;
  Missing, Anonymous, NoSection, Groups, Group, Weights: TList;
  GroupIndices, Dependents, Block: TBlockParEC;

  // @nested $532EE8 AlignModRowHeight
  function AlignModRowHeight(Height, Step: Integer): Integer; // @addr $532EE8 @ida "int __usercall $name@<eax>(int Height@<eax>, int Step@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x533124,0x53368D,0x53381B"
  begin
    Result := Round(Height / Step + 0.501) * Step;
  end;

  // @nested $532F24 AddModSectionTitle
  procedure AddModSectionTitle(Text: WideString; Tab: Integer); // @addr $532F24 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, int Tab@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x534A21,0x534B52"
  var Image: TImageGI; LabelControl: TLabelGI;
  begin
    if TabHeights[Tab] <> 0 then
    begin
      Image := TImageGI.Create(TabPanels[Tab]);
      Image.SetImagePath('GI,Bm.FormOptions2.2Line');
      Image.SetPosition(Point(0, TabHeights[Tab]));
      Image.SetSize(Point(TabPanels[Tab].ClientSize.X, Image.GetContentSize.Y + 2));
      Image.SetImageKindX(ikxLeftFill);
      Inc(TabHeights[Tab], Image.ClientSize.Y);
    end
    else Inc(TabHeights[Tab], 10);
    LabelControl := TLabelGI.Create(TabPanels[Tab]);
    LabelControl.SetFontName(BigFontName);
    LabelControl.SetPositionModeW(False);
    LabelControl.SetWordWrapEnabled(False);
    LabelControl.SetPosition(Point(0, TabHeights[Tab]));
    LabelControl.SetSize(Point(TabPanels[Tab].ClientSize.X, 1));
    LabelControl.SetTextAlignX(taxLeft);
    LabelControl.SetTextAlignY(tayAuto);
    LabelControl.SetTextColor(ModTabColor);
    LabelControl.SetText(Text);
    LabelControl.SetTextAlignY(tayTop);
    LabelControl.SetSize(Point(LabelControl.ClientSize.X, LabelControl.ClientSize.Y + 1));
    TabHeights[Tab] := TabHeights[Tab] + AlignModRowHeight(LabelControl.ClientSize.Y, 10) + 2;
  end;

  // @nested $5331AC AddModRow
  procedure AddModRow(Info: TModInfo; Tab: Integer); // @addr $5331AC @ida "void __usercall $name(TModInfo *Info@<eax>, int Tab@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x533AB2"
  var
    Switch, Line: TImageGI;
    InfoButton: TGraphButtonGI;
  begin
    if TabHeights[Tab] <> 0 then
    begin
      Line := TImageGI.Create(TabPanels[Tab]);
      Line.SetImagePath('GI,Bm.FormOptions2.2Line');
      Line.SetPosition(Point(0, TabHeights[Tab]));
      Line.SetSize(Point(TabPanels[Tab].ClientSize.X, Line.GetContentSize.Y + 2));
      Line.SetImageKindX(ikxLeftFill);
      Inc(TabHeights[Tab], Line.ClientSize.Y);
    end
    else Inc(TabHeights[Tab], 10);
    Switch := TImageGI.Create(TabPanels[Tab]);
    Switch.UserValue := Integer(Info);
    Switch.SetImagePath('GI,Bm.FormOptions2.2SwitchN');
    Switch.UserIndex := Ord(Info.Selected);
    Switch.SetSize(Switch.GetContentSize);
    ButtonWidth := Switch.ClientSize.X;
    Switch.SetPosition(Point(TabPanels[Tab].ClientSize.X - ButtonWidth - 0, TabHeights[Tab] + 10));
    Switch.SetImageKindY(ikyCenter);
    Switch.LeftButtonDownCallback := SwitchMouseDown;
    Switch.MouseEnterCallback := SwitchMouseEnter;
    Switch.MouseLeaveCallback := SwitchMouseLeave;
    Info.SwitchImage := Switch;
    InfoButton := TGraphButtonGI.Create(TabPanels[Tab]);
    InfoButton.SetImageNormalPath('GI,Bm.MsgPlayer.2UserN');
    InfoButton.SetImageNormalActivePath('GI,Bm.MsgPlayer.2UserA');
    InfoButton.SetImageDownPath('GI,Bm.MsgPlayer.2UserD');
    InfoButton.SetSize(InfoButton.GetMaxStateImageSize);
    Inc(ButtonWidth, InfoButton.ClientSize.X);
    InfoButton.SetPosition(Point(TabPanels[Tab].ClientSize.X - ButtonWidth - 0, TabHeights[Tab] + 9));
    InfoButton.UpCallback := ShowInfoClick;
    InfoButton.UserValue := Integer(Info);
    Switch.UserData := Integer(TGraphButtonGI.Create(TabPanels[Tab]));
    with TGraphButtonGI(Switch.UserData) do
    begin
      SetImageNormalPath('GI,Bm.MsgPlayer.2ShipMinusN');
      SetImageNormalActivePath('GI,Bm.MsgPlayer.2ShipMinusA');
      SetImageDownPath('GI,Bm.MsgPlayer.2ShipMinusD');
      SetSize(GetMaxStateImageSize);
      Inc(ButtonWidth, ClientSize.X);
      SetPosition(Point(TabPanels[Tab].ClientSize.X - ButtonWidth + 2, TabHeights[Tab] + 9));
      UpCallback := ShowProblemsClick;
      UserValue := Integer(Info);
    end;
    Switch.UserState := Integer(TLabelGI.Create(TabPanels[Tab]));
    with TLabelGI(Switch.UserState) do
    begin
      SetFontName(NormalFontName);
      SetPositionModeW(False);
      SetWordWrapEnabled(True);
      SetPosition(Point(0, TabHeights[Tab]));
      SetSize(Point(TabPanels[Tab].ClientSize.X - ButtonWidth, 1));
      SetTextAlignX(taxLeft);
      SetTextAlignY(tayAuto);
      SetText(Info.GetDisplayName);
      SetTextAlignY(tayTop);
      SetSize(Point(ClientSize.X, ClientSize.Y + 1));
      TabHeights[Tab] := TabHeights[Tab] + AlignModRowHeight(ClientSize.Y, 20) + 2;
    end;
    with TLabelGI.Create(TabPanels[Tab]) do
    begin
      SetFontName(NormalFontName);
      SetPositionModeW(False);
      SetWordWrapEnabled(True);
      SetPosition(Point(0, TabHeights[Tab]));
      SetSize(Point(TabPanels[Tab].ClientSize.X - ButtonWidth, 1));
      SetTextAlignX(taxLeft);
      SetTextAlignY(tayAuto);
      SetTextColor(CurrentPixelFormat.PackRgbBytes(205, 205, 205));
      if Info.SmallDescription <> '' then SetText(Info.SmallDescription)
      else if Info.FullDescription <> '' then SetText(Info.FullDescription)
      else SetText(LocalizedText('FormMods.NoDescription'));
      SetTextAlignY(tayTop);
      SetSize(Point(ClientSize.X, ClientSize.Y + 1));
      TabHeights[Tab] := TabHeights[Tab] + AlignModRowHeight(ClientSize.Y, 20) + 5;
    end;
    UpdateModSwitch(Switch);
  end;

  // @nested $533A78 AddModRows
  procedure AddModRows(List: TList; Tab: Integer); // @addr $533A78 @ida "void __usercall $name(TList *List@<eax>, int Tab@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x5348E3,0x534A2E,0x534B60"
  var I: Integer; Info: TModInfo;
  begin
    for I := 0 to List.Count - 1 do
    begin
      Info := TModInfo(List[I]);
      AddModRow(Info, Tab);
    end;
  end;

  // @nested $533AC4 ConfigureModTab
  procedure ConfigureModTab(Text: WideString; Tab: Integer); // @addr $533AC4 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, int Tab@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x534903,0x534A3B,0x534B90"
  begin
    with TabButtons[Tab] do
    begin
      HelpText := Text;
      UpCallback := TabClick;
      DownCallback := TabClick;
      SetActive(True);
    end;
  end;

begin
  inherited InitializeLayout;
  ModTabColor := GetStyleColorGI('Mods.ColorNormal', 88, 229, 255);
  ModTabDownColor := GetStyleColorGI('Mods.ColorSelected', 0, 0, 0);
  ModSelectedColor := GetStyleColorGI('Mods.ColorActive', 0, 255, 0);
  ModWarningColor := GetStyleColorGI('Mods.ColorProblems', 255, 150, 50);
  ModErrorColor := GetStyleColorGI('Mods.ColorCriticalProblems', 255, 0, 0);
  ViewportRect := Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Point(GameScreenWidth, GameScreenHeight));
    ScrollPanel := FindByNameRecursive('PanelSet') as TPanelScrollBarGI;
    ScrollPanel.VerticalScrollBar.SetSmallChange((FindByNameRecursive('ButGroup0') as TGraphButtonGI).CaptionLabel.GetLineHeight * 2);
    ScrollPanel.VerticalScrollBar.SetLargeChange(ScrollPanel.ClientSize.Y);
    ScrollPanel.VerticalScrollBar.SetPageSize(ScrollPanel.ClientSize.Y);
  end;
  with ScrollPanel.Parent do
    SetPosition(Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
  (GetByName('Cancel') as TGraphButtonGI).UpCallback := CloseClick;
  (GetByName('Confirm') as TGraphButtonGI).UpCallback := ApplyClick;
  (GetByName('ButReset') as TGraphButtonGI).UpCallback := ClearSelectionClick;
  SetLength(TabButtons, 1);
  TabCount := 0;
  Button := GetByName('ButGroup0') as TGraphButtonGI;
  repeat
    TabButtons[TabCount] := Button;
    Inc(TabCount);
    SetLength(TabButtons, TabCount + 1);
    Button := FindControlByPath('ButGroup' + IntToWideString(TabCount)) as TGraphButtonGI;
  until Button = nil;
  SetLength(TabPanels, TabCount);
  SetLength(TabHeights, TabCount);
  SetLength(SelectedCounts, TabCount);
  SetLength(WarningCounts, TabCount);
  SetLength(ErrorCounts, TabCount);
  SetLength(InvalidSelections, TabCount);
  NeedsValidation := True;
  for I := 0 to TabCount - 1 do
  begin
    TabHeights[I] := 0;
    TabPanels[I] := TPanelGI.Create(ScrollPanel);
    with TabPanels[I] do
    begin
      SetSize(Point(ScrollPanel.ClientSize.X, 0));
      SetPosition(Point(0, 0));
      SetDepth(-100);
      SetPositionModeW(True);
      UserValue := I;
    end;
    SelectedCounts[I] := 0;
    WarningCounts[I] := 0;
    ErrorCounts[I] := 0;
  end;
  Missing := TList.Create;
  Anonymous := TList.Create;
  NoSection := TList.Create;
  Groups := TList.Create;
  Weights := TList.Create;
  GroupIndices := TBlockParEC.Create;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.MissingFolder then Missing.Add(Info)
    else if (Info.Name = '') and (Info.Section = '') then Anonymous.Add(Info)
    else if Info.Section = '' then NoSection.Add(Info)
    else if GroupIndices.CountParams(Info.Section) > 0 then
      TList(Groups[ExtractDigitsToIntW(GroupIndices.GetParam(Info.Section))]).Add(Info)
    else
    begin
      Group := TList.Create;
      Group.Add(Info);
      GroupIndices.AddParam(Info.Section, IntToWideString(Groups.Count));
      Groups.Add(Group);
    end;
  end;
  Dependents := TBlockParEC.Create;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if not Info.MissingFolder then
      for J := 0 to Info.DependencyCount - 1 do
      begin
        Dependency := Info.Dependencies[J];
        if Dependency <> nil then
        begin
          if Dependents.CountBlocks(Dependency.Name) > 0 then Block := Dependents.GetBlock(Dependency.Name)
          else Block := Dependents.AddChildBlock(Dependency.Name);
          if Info.Section <> '' then SectionName := Info.Section else SectionName := '{';
          if Block.CountParams(SectionName) > 0 then Block.SetOrAddParam(SectionName, IntToWideString(ExtractDigitsToIntW(Block.GetParam(SectionName)) + 1))
          else Block.AddParam(SectionName, '1');
        end;
      end;
  end;
  for I := 0 to Groups.Count - 1 do Weights.Add(Pointer(TList(Groups[I]).Count));
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.MissingFolder or (Info.Name = '') or (Dependents.CountBlocks(Info.Name) <= 0) then Continue;
    if not Info.DuplicateName then
    begin
      if Info.Section <> '' then
      begin
        Block := Dependents.GetBlockByPath(Info.Name);
        Weight := 0;
        for J := 0 to Block.GetParamCount - 1 do
          if Block.GetParamName(J) <> Info.Section then
            Inc(Weight, ExtractDigitsToIntW(Block.GetParamValue(J)));
        J := ExtractDigitsToIntW(GroupIndices.GetParam(Info.Section));
        Weights[J] := Pointer(Integer(Weights[J]) + Weight);
      end;
      Dependents.DeleteChildBlock(Info.Name);
    end
    else
    begin
      Block := Dependents.GetBlockByPath(Info.Name);
      if Info.Section <> '' then GroupName := Info.Section else GroupName := '{';
      if Block.CountParams(GroupName) > 0 then
      begin
        Block.DeleteParam(GroupName);
        if Block.GetParamCount <= 0 then Dependents.DeleteChildBlock(Info.Name);
      end
      else if Block.CountBlocks(GroupName) <= 0 then Block.AddBlockByPath(GroupName);
    end;
  end;
  for I := 0 to Dependents.GetBlockCount - 1 do
  begin
    Block := Dependents.GetBlockByIndex(I);
    if Block.GetBlockCount > 0 then
    begin
      Weight := 0;
      for J := 0 to Block.GetParamCount - 1 do Inc(Weight, ExtractDigitsToIntW(Block.GetParamValue(J)));
      Weight := (Weight - 1) div Block.GetBlockCount + 1;
      for J := 0 to Block.GetBlockCount - 1 do
      begin
        GroupName := Block.GetBlockNameByIndex(J);
        if GroupName <> '{' then
        begin
          GroupIndex := ExtractDigitsToIntW(GroupIndices.GetParam(GroupName));
          Weights[GroupIndex] := Pointer(Integer(Weights[GroupIndex]) + Weight);
        end;
      end;
    end;
  end;
  GroupCount := Groups.Count;
  Group := TList.Create;
  for I := 0 to Groups.Count - 1 do
    if (Integer(Weights[I]) <= 1) and (TList(Groups[I]).Count = 1) then
    begin
      Weights[I] := nil;
      Dec(GroupCount);
      Group.Add(TList(Groups[I])[0]);
    end;
  for I := 0 to NoSection.Count - 1 do Group.Add(NoSection[I]);
  for I := 0 to Anonymous.Count - 1 do Group.Add(Anonymous[I]);
  if Group.Count > 0 then
  begin
    GroupIndices.AddParam('{}', IntToWideString(Groups.Count));
    Groups.Add(Group);
    Weights.Add(Pointer(1));
    Inc(GroupCount);
  end
  else Group.Free;
  for J := 0 to TabCount - 1 do TabButtons[J].SetActive(False);
  AvailableTabs := TabCount;
  if Missing.Count > 0 then
  begin
    if TabCount <= GroupCount + 1 then I := TabCount - 1 else I := GroupCount;
    Dec(AvailableTabs);
    AddModRows(Missing, I);
    ConfigureModTab(LocalizedText('FormMods.GroupNameForMissing'), I);
  end;
  SeparateGroups := AvailableTabs - Ord(AvailableTabs < GroupCount);
  if SeparateGroups > GroupCount then SeparateGroups := GroupCount;
  for J := 0 to SeparateGroups - 1 do
  begin
    BestWeight := 0;
    BestIndex := -1;
    for I := 0 to Groups.Count - 1 do
    begin
      GroupIndex := ExtractDigitsToIntW(GroupIndices.GetParamValue(I));
      CandidateWeight := Integer(Weights[GroupIndex]);
      if CandidateWeight > BestWeight then
      begin
        BestWeight := CandidateWeight;
        BestIndex := I;
      end;
    end;
    GroupIndex := ExtractDigitsToIntW(GroupIndices.GetParamValue(BestIndex));
    Weights[GroupIndex] := nil;
    Group := TList(Groups[GroupIndex]);
    GroupName := GroupIndices.GetParamName(BestIndex);
    if GroupName = '{}' then GroupName := LocalizedText('FormMods.GroupNameForMisc');
    AddModSectionTitle(GroupName, J);
    AddModRows(Group, J);
    ConfigureModTab(GroupName, J);
  end;
  if SeparateGroups < GroupCount then
  begin
    for J := SeparateGroups to GroupCount - 1 do
    begin
      BestWeight := 0;
      BestIndex := -1;
      for I := 0 to Groups.Count - 1 do
      begin
        GroupIndex := ExtractDigitsToIntW(GroupIndices.GetParamValue(I));
        CandidateWeight := Integer(Weights[GroupIndex]);
        if CandidateWeight > BestWeight then
        begin
          BestWeight := CandidateWeight;
          BestIndex := I;
        end;
      end;
      GroupIndex := ExtractDigitsToIntW(GroupIndices.GetParamValue(BestIndex));
      Weights[GroupIndex] := nil;
      Group := TList(Groups[GroupIndex]);
      GroupName := GroupIndices.GetParamName(BestIndex);
      if GroupName = '{}' then GroupName := LocalizedText('FormMods.GroupNameForMisc');
      AddModSectionTitle(GroupName, AvailableTabs - 1);
      AddModRows(Group, AvailableTabs - 1);
    end;
    ConfigureModTab(LocalizedText('FormMods.GroupNameForOther'), AvailableTabs - 1);
  end;
  for I := 0 to TabCount - 1 do
    with TabPanels[I] do SetSize(Point(ClientSize.X, TabHeights[I]));
  GetByName('MainPanel').KeyDownCallback := KeyDown;
  Missing.Free;
  Anonymous.Free;
  NoSection.Free;
  for I := 0 to Groups.Count - 1 do TObject(Groups[I]).Free;
  Groups.Free;
  Weights.Free;
  GroupIndices.Free;
end;
{ @end $533B68 }

{ @routine $534F28 TfModsManager_OnOpen }
procedure TfModsManager.OnOpen;
var
  FileName: WideString;
  I, Tab: Integer;
  Info: TModInfo;
begin
  if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True, 0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  for I := 0 to TabCount - 1 do
  begin
    SelectedCounts[I] := 0;
    WarningCounts[I] := 0;
    ErrorCounts[I] := 0;
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    Info.SwitchImage.UserIndex := Ord(Info.Selected);
    if (Info.ConflictCount = 0) and (Info.DependencyCount = 0) then UpdateModSwitch(Info.SwitchImage);
    Tab := Info.SwitchImage.Parent.UserValue;
    if Info.Selected then Inc(SelectedCounts[Tab]);
    if Info.DuplicateName or Info.Misplaced or (Info.UnsupportedLanguage and Info.Selected) then
      Inc(WarningCounts[Tab]);
    if Info.MissingFolder or Info.MissingDependency then
      if Info.Selected then Inc(ErrorCounts[Tab]) else Inc(WarningCounts[Tab]);
  end;
  ValidateSelection;
  SelectedTab := -1;
  TabClick(TabButtons[0]);
  if (UserSettingsConfig.CountParams('WeWarnedUserAboutMods') = 0) or
     not ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('WeWarnedUserAboutMods'))) then
  begin
    ShowMessageBoxGI(Self, LocalizedColorText('FormMods.WarningAchievements'), mbgCancel or mbgUnused04);
    if UserSettingsConfig.CountParams('WeWarnedUserAboutMods') = 0 then
      UserSettingsConfig.AddParam('WeWarnedUserAboutMods', 'True')
    else UserSettingsConfig.SetOrAddParam('WeWarnedUserAboutMods', 'True');
    FileName := GetGameUserDirectory + 'CFG.TXT';
    UserSettingsConfig.SaveTextFile(PWideChar(FileName), True, False);
  end;
end;
{ @end $534F28 }

{ @routine $5352C0 TfModsManager_TabClick }
procedure TfModsManager.TabClick(Sender: TObjectGI);
var Index: Integer;
begin
  Index := ExtractDigitsToIntW(Sender.ControlName);
  if SelectedTab = Index then UpdateTabDisplay
  else
  begin
    SelectedTab := Index;
    UpdateTabDisplay;
    with GetByName('PanelSet') as TPanelScrollBarGI do
    begin
      SetScrollOffset(Point(0, 0));
      UpdateScrollRanges;
      SetVerticalScrollbarEnabled(TabHeights[SelectedTab] > ClientSize.Y);
    end;
  end;
end;
{ @end $5352C0 }

{ @routine $535388 TfModsManager_UpdateTabDisplay }
procedure TfModsManager.UpdateTabDisplay;
var I: Integer;
begin
  if NeedsValidation then ValidateSelection;
  for I := 0 to TabCount - 1 do
    with TabButtons[I] do
      if Active then
      begin
        if SelectedCounts[I] = 0 then SetCaption(HelpText)
        else SetCaption(HelpText + ' (' + IntToWideString(SelectedCounts[I]) + ')');
        SetDown(I = SelectedTab);
        if (ErrorCounts[I] > 0) or InvalidSelections[I] then SetCaptionColor(ModErrorColor)
        else if WarningCounts[I] > 0 then SetCaptionColor(ModErrorColor)
        else if SelectedCounts[I] > 0 then SetCaptionColor(ModSelectedColor)
        else if Down then
        begin
          SetCaptionColor(ModTabDownColor);
          CaptionColors[0] := ModTabColor;
          CaptionColors[1] := ModTabColor;
        end
        else
        begin
          SetCaptionColor(ModTabColor);
          CaptionColors[2] := ModTabDownColor;
          CaptionColors[3] := ModTabDownColor;
        end;
        TabPanels[I].SetActive(I = SelectedTab);
      end;
end;
{ @end $535388 }

{ @routine $5355C0 TfModsManager_ValidateSelection }
procedure TfModsManager.ValidateSelection;
var
  I, J, VariantIndex: Integer;
  Info, Related: TModInfo;
  Switch, RelatedSwitch: TImageGI;
  Invalid, Found: Boolean;
begin
  for I := 0 to TabCount - 1 do InvalidSelections[I] := False;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if (Info.ConflictCount <> 0) or (Info.DependencyCount <> 0) then
    begin
      Switch := Info.SwitchImage;
      UpdateModSwitch(Switch);
      if Switch.UserIndex <> 0 then
        if not InvalidSelections[Switch.Parent.UserValue] then
        begin
          Invalid := False;
          for J := 0 to Info.ConflictCount - 1 do
          begin
            VariantIndex := 0;
            Related := Info.Conflicts[J];
            if Related <> nil then
              while True do
              begin
                RelatedSwitch := Related.SwitchImage;
                if RelatedSwitch.UserIndex = 1 then
                begin
                  Invalid := True;
                  Break;
                end;
                if not Related.DuplicateName then Break;
                Inc(VariantIndex);
                Related := Info.GetConflict(J, VariantIndex);
                if Related = nil then Break;
              end;
            if Invalid then Break;
          end;
          if not Invalid then
            for J := 0 to Info.DependencyCount - 1 do
            begin
              Found := False;
              VariantIndex := 0;
              Related := Info.Dependencies[J];
              if Related <> nil then
                while True do
                begin
                  RelatedSwitch := Related.SwitchImage;
                if RelatedSwitch.UserIndex = 1 then
                  begin
                    Found := True;
                    Break;
                  end;
                  if not Related.DuplicateName then Break;
                  Inc(VariantIndex);
                  Related := Info.GetDependency(J, VariantIndex);
                  if Related = nil then Break;
                end;
              if not Found then
              begin
                Invalid := True;
                Break;
              end;
            end;
          if Invalid then
          begin
            InvalidSelections[Switch.Parent.UserValue] := True;
            TLabelGI(Switch.UserState).SetTextColor(ModErrorColor);
            TObjectGI(Switch.UserData).SetActive(Invalid);
          end;
        end;
    end;
  end;
  NeedsValidation := False;
end;
{ @end $5355C0 }

{ @routine $5357F4 TfModsManager_ClearSelectionClick }
procedure TfModsManager.ClearSelectionClick(Sender: TObjectGI);
var I: Integer;
begin
  for I := 0 to ModInfos.Count - 1 do SetModSelected(TModInfo(ModInfos[I]).SwitchImage, False);
  UpdateTabDisplay;
end;
{ @end $5357F4 }

{ @routine $53584C TfModsManager_SelectAll }
procedure TfModsManager.SelectAll;
var
  I, J, K: Integer;
  Info, Related, Conflict: TModInfo;
  Switch: TImageGI;
  Changed, Invalid, Found: Boolean;
begin
  repeat
    Changed := False;
    for I := 0 to ModInfos.Count - 1 do
    begin
      Info := TModInfo(ModInfos[I]);
      if not Info.MissingFolder and not Info.MissingDependency then
      begin
        Switch := Info.SwitchImage;
        if (Switch.UserIndex <> 1) and (Switch.Parent.UserValue = SelectedTab) then
        begin
          Invalid := False;
          for J := 0 to Info.ConflictCount - 1 do
          begin
            Related := Info.Conflicts[J];
            K := 0;
            if Related <> nil then
              while True do
              begin
                if Related.SwitchImage.UserIndex = 1 then
                begin
                  Invalid := True;
                  Break;
                end;
                if not Related.DuplicateName then Break;
                Inc(K);
                Related := Info.GetConflict(J, K);
                if Related = nil then Break;
              end;
          end;
          if not Invalid then
          begin
            for J := 0 to Info.DependencyCount - 1 do
            begin
              Related := Info.Dependencies[J];
              Found := False;
              K := 0;
              if Related <> nil then
                while True do
                begin
                  if Related.SwitchImage.UserIndex = 1 then
                  begin
                    Found := True;
                    Break;
                  end;
                  if not Related.DuplicateName then Break;
                  Inc(K);
                  Related := Info.GetDependency(J, K);
                  if Related = nil then Break;
                end;
              if not Found then
              begin
                Invalid := True;
                Break;
              end;
            end;
            if not Invalid then
            begin
              if Info.ReferencedAsConflict then
                for J := 0 to ModInfos.Count - 1 do
                begin
                  Related := TModInfo(ModInfos[J]);
                  if Related.SwitchImage.UserIndex <> 0 then
                  begin
                    for K := 0 to Related.ConflictCount - 1 do
                    begin
                      Conflict := Related.Conflicts[K];
                      if Conflict <> nil then
                        if Conflict.Name = Info.Name then
                        begin
                          Invalid := True;
                          Break;
                        end;
                    end;
                    if Invalid then Break;
                  end;
                end;
              if not Invalid then
              begin
                Changed := True;
                SetModSelected(Switch, True);
              end;
            end;
          end;
        end;
      end;
    end;
  until not Changed;
  UpdateTabDisplay;
end;
{ @end $53584C }

{ @routine $535AC0 TfModsManager_DeselectAll }
procedure TfModsManager.DeselectAll;
var
  I, J, K, VariantIndex: Integer;
  Info, Related, Dependency: TModInfo;
  Switch: TImageGI;
  Changed, Required, Found, UniqueName: Boolean;
begin
  repeat
    Changed := False;
    for I := 0 to ModInfos.Count - 1 do
    begin
      Info := TModInfo(ModInfos[I]);
      Switch := Info.SwitchImage;
      if (Switch.UserIndex <> 0) and (Switch.Parent.UserValue = SelectedTab) then
      begin
        UniqueName := not Info.DuplicateName;
        Required := False;
        if Info.ReferencedAsDependency then
          for J := 0 to ModInfos.Count - 1 do
          begin
            Related := TModInfo(ModInfos[J]);
            if Related.SwitchImage.UserIndex <> 0 then
            begin
              for K := 0 to Related.DependencyCount - 1 do
              begin
                Dependency := Related.Dependencies[K];
                if Dependency <> nil then
                begin
                  if UniqueName then
                  begin
                    Required := Dependency = Info;
                    if Required then Break;
                  end
                  else if Dependency.Name = Info.Name then
                  begin
                    Found := False;
                    VariantIndex := 0;
                    while Dependency <> nil do
                    begin
                      if (Dependency <> Info) and (Dependency.SwitchImage.UserIndex = 1) then
                      begin
                        Found := True;
                        Break;
                      end;
                      Inc(VariantIndex);
                      Dependency := Related.GetDependency(K, VariantIndex);
                    end;
                    if not Found then
                    begin
                      Required := True;
                      Break;
                    end;
                  end;
                end;
              end;
              if Required then Break;
            end;
          end;
        if not Required then
        begin
          Changed := True;
          SetModSelected(Switch, False);
        end;
      end;
    end;
  until not Changed;
  UpdateTabDisplay;
end;
{ @end $535AC0 }

{ @routine $535C94 TfModsManager_CloseClick }
procedure TfModsManager.CloseClick(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(2) else RequestClose(ExitCode);
end;
{ @end $535C94 }

{ @routine $535CCC TfModsManager_ApplyClick }
procedure TfModsManager.ApplyClick(Sender: TObjectGI);
var
  I, J: Integer;
  Info: TModInfo;
  Folders: WideString;
  List: TList;
  Unchanged, Ordered: Boolean;
  Block: TBlockParEC;
begin
  Unchanged := True;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if (Info.SwitchImage.UserIndex = 1) <> Info.Selected then
    begin
      Unchanged := False;
      Break;
    end;
  end;
  if Unchanged then
  begin
    Ordered := True;
    for I := 1 to SelectedModInfos.Count - 1 do
      if TModInfo(SelectedModInfos[I]).Priority < TModInfo(SelectedModInfos[I - 1]).Priority then
      begin
        Ordered := False;
        Break;
      end;
    if Ordered or
       (ShowMessageBoxGI(GetInnermostScreenLoop, LocalizedText('FormMods.QueryWrongOrderFix'), mbgOK or mbgCancel or mbgWarning) <> mbgResultOK) then
    begin
      if ExitCode = 0 then RequestClose(2) else RequestClose(ExitCode);
      Exit;
    end;
  end;
  List := TList.Create;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.SwitchImage.UserIndex = 1 then List.Add(Info);
  end;
  Folders := '';
  if List.Count > 0 then
  begin
    for I := 1 to List.Count - 1 do
      for J := 0 to List.Count - 1 - I do
        if TModInfo(List[J]).Priority > TModInfo(List[J + 1]).Priority then
        begin
          Info := TModInfo(List[J]);
          List[J] := List[J + 1];
          List[J + 1] := Info;
        end;
    Folders := TModInfo(List[0]).Folder;
    for I := 1 to List.Count - 1 do Folders := Folders + ', ' + TModInfo(List[I]).Folder;
  end;
  List.Free;
  Block := TBlockParEC.Create;
  Block.AddParam('CurrentMod', Folders);
  Block.SaveTextFile('Mods\ModCFG.txt', True, False);
  Block.Free;
  ReloadModsRequested := True;
  if ExitCode = 0 then RequestClose(2) else RequestClose(ExitCode);
end;
{ @end $535CCC }

{ @routine $53607C TfModsManager_KeyDown }
procedure TfModsManager.KeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if Key = VK_RETURN then ApplyClick(nil)
  else if Key = VK_ESCAPE then CloseClick(nil)
  else if (Key = Ord('A')) and IsVirtualKeyDown(VK_CONTROL) then SelectAll
  else if (Key = Ord('Z')) and IsVirtualKeyDown(VK_CONTROL) then DeselectAll;
end;
{ @end $53607C }

{ @routine $5360F0 TfModsManager_ProcessMouseWheel }
procedure TfModsManager.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  with GetByName('PanelSet') as TPanelScrollBarGI do
    if Delta = WHEEL_DELTA then VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.SmallChange)
    else if Delta = -WHEEL_DELTA then VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.SmallChange);
end;
{ @end $5360F0 }

{ @routine $5361A8 TfModsManager_SwitchMouseEnter }
procedure TfModsManager.SwitchMouseEnter(Sender: TObjectGI);
begin
  if Sender.UserIndex <> 1 then
    (Sender as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchA');
end;
{ @end $5361A8 }

{ @routine $536278 TfModsManager_SwitchMouseLeave }
procedure TfModsManager.SwitchMouseLeave(Sender: TObjectGI);
begin
  if Sender.UserIndex <> 1 then
    (Sender as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN');
end;
{ @end $536278 }

{ @routine $5367E0 TfModsManager_SwitchMouseDown }
procedure TfModsManager.SwitchMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  EnableIndices, KnownNames: TBlockParEC;
  VariantIndex: Integer;
  AskBeforeDependency: Boolean;
  Choices: TList;
  I, J, Index: Integer;
  Info, Related, Dependency: TModInfo;
  Value, Text, Temp: WideString;
  DisableIndices, DisableNames: TBlockParEC;
  Changed, PassChanged, Alternative: Boolean;

  // @nested $536348 CollectModDependencies
  function CollectModDependencies(Info: TModInfo): Boolean; // @addr $536348 @ida "bool __usercall $name@<al>(TModInfo *Info@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x536489,0x536660,0x536C8C"
  var
    Name, Caption: WideString;
    Related: TModInfo;
    PartIndex, I, SelectedIndex: Integer;
    Choice: PWideString;
    Found: Boolean;
  begin
    Result := False;
    EnableIndices.AddParam(Info.IndexText, '');
    for PartIndex := 0 to Info.DependencyCount - 1 do
    begin
      Related := Info.Dependencies[PartIndex];
      if Related = nil then
      begin
        Name := LocalizedText('FormMods.ErrorNoDependency');
        ReplaceTextToken(Name, '<ModName>', '<color=255,240,100>' + TrimWideString(ExtractDelimitedPartW(Info.DependencyNames, PartIndex, ',')) + '</color>', '');
        ShowMessageBoxGI(Self, Name, mbgOK or mbgError);
        Exit;
      end;
      Name := Related.Name;
      if KnownNames.CountParams(Name) > 0 then Continue;
      KnownNames.AddParam(Name, '');
      if Related.SwitchImage.UserIndex <> 1 then
      begin
        if not Related.DuplicateName then
        begin
          if not CollectModDependencies(Related) then Exit;
        end
        else
        begin
          Found := False;
          VariantIndex := 1;
          Related := Info.GetDependency(PartIndex, VariantIndex);
          while Related <> nil do
          begin
            if Related.SwitchImage.UserIndex = 1 then
            begin
              Found := True;
              Break;
            end;
            Inc(VariantIndex);
            Related := Info.GetDependency(PartIndex, VariantIndex);
          end;
          if not Found then
          begin
            if AskBeforeDependency then
            begin
              AskBeforeDependency := False;
              if ShowMessageBoxGI(GetInnermostScreenLoop, LocalizedText('FormMods.QuerySelectDependencyFirst'), mbgOK or mbgCancel or mbgUnused04) <> mbgResultOK then Exit;
            end;
            if Choices = nil then Choices := TList.Create;
            I := 0;
            Related := Info.Dependencies[PartIndex];
            while Related <> nil do
            begin
              New(Choice);
              Choice^ := Related.Folder;
              Choices.Add(Choice);
              Inc(I);
              Related := Info.GetDependency(PartIndex, I);
            end;
            Caption := LocalizedText('FormMods.QuerySelectDependency');
            ReplaceTextToken(Caption, '<ModName>', Name, '');
            if ShowListDialog(GetInnermostScreenLoop, SelectedIndex, Caption, Choices, 0, 0) <> 1 then SelectedIndex := -1;
            for I := 0 to Choices.Count - 1 do Dispose(Pointer(Choices[I]));
            Choices.Clear;
            if SelectedIndex < 0 then Exit;
            if not CollectModDependencies(Info.GetDependency(PartIndex, SelectedIndex)) then Exit;
          end;
        end;
      end;
    end;
    Result := True;
  end;

begin
  SoundManager.PlaySound('Sound.ButtonClick');
  Info := TModInfo(Sender.UserValue);
  Changed := False;
  Choices := nil;
  DisableIndices := nil;
  EnableIndices := nil;
  DisableNames := nil;
  KnownNames := nil;
  AskBeforeDependency := True;
  try
    if Sender.UserIndex = 1 then
    begin
      if not Info.ReferencedAsDependency then
      begin
        SetModSelected(Sender, False);
        Changed := True;
        Exit;
      end;
      DisableIndices := TBlockParEC.Create;
      DisableNames := TBlockParEC.Create;
      DisableIndices.AddParam(Info.IndexText, '');
      DisableNames.AddParam(Info.Name, '');
      repeat
        PassChanged := False;
        for I := 0 to ModInfos.Count - 1 do
        begin
          Related := TModInfo(ModInfos[I]);
          if Related.SwitchImage.UserIndex <> 0 then
            if Related.DependencyCount <> 0 then
              if DisableIndices.CountParams(IntToWideString(I)) <= 0 then
                for J := 0 to Related.DependencyCount - 1 do
                begin
                  Dependency := Related.Dependencies[J];
                  if (Dependency <> nil) and (DisableNames.CountParams(Dependency.Name) > 0) then
                  begin
                    Alternative := False;
                    if Dependency.DuplicateName then
                    begin
                      VariantIndex := 0;
                      while Dependency <> nil do
                      begin
                        if (Dependency.SwitchImage.UserIndex = 1) and (DisableIndices.CountParams(Dependency.IndexText) <= 0) then
                        begin
                          Alternative := True;
                          Break;
                        end;
                        Inc(VariantIndex);
                        Dependency := Related.GetDependency(J, VariantIndex);
                      end;
                    end;
                    if not Alternative then
                    begin
                      PassChanged := True;
                      DisableIndices.AddParam(IntToWideString(I), '');
                      if DisableNames.CountParams(Related.Name) <= 0 then DisableNames.AddParam(Related.Name, '');
                      Break;
                    end;
                  end;
                end;
        end;
      until not PassChanged;
      if DisableIndices.GetParamCount = 1 then
      begin
        SetModSelected(Sender, False);
        Changed := True;
        Exit;
      end;
      Value := '';
      for I := 0 to DisableIndices.GetParamCount - 1 do
      begin
        Text := DisableIndices.GetParamName(I);
        if Text <> Info.IndexText then
        begin
          Index := ExtractDigitsToIntW(Text);
          if Value = '' then Value := TModInfo(ModInfos[Index]).Name
          else Value := Value + ', ' + TModInfo(ModInfos[Index]).Name;
        end;
      end;
      Text := LocalizedText('FormMods.QueryTurnOffWithExtra');
      ReplaceTextToken(Text, '<ModName>', '<color=255,240,100>' + Info.Name + '</color>', '');
      ReplaceTextToken(Text, '<ModsList>', '<color=255,240,100>' + Value + '</color>', '');
      if ShowMessageBoxGI(GetInnermostScreenLoop, Text, mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then Exit;
      for I := 0 to DisableIndices.GetParamCount - 1 do
      begin
        Index := ExtractDigitsToIntW(DisableIndices.GetParamName(I));
        SetModSelected(TModInfo(ModInfos[Index]).SwitchImage, False);
      end;
      Changed := True;
    end
    else
    begin
      if not Info.ReferencedAsConflict and (Info.ConflictCount = 0) and (Info.DependencyCount = 0) then
      begin
        SetModSelected(Sender, True);
        Changed := True;
        Exit;
      end;
      EnableIndices := TBlockParEC.Create;
      KnownNames := TBlockParEC.Create;
      DisableIndices := TBlockParEC.Create;
      DisableNames := TBlockParEC.Create;
      KnownNames.AddParam(Info.Name, '');
      if not CollectModDependencies(Info) then Exit;
      for I := 0 to EnableIndices.GetParamCount - 1 do
      begin
        Related := TModInfo(ModInfos[ExtractDigitsToIntW(EnableIndices.GetParamName(I))]);
        for J := 0 to Related.ConflictCount - 1 do
        begin
          Dependency := Related.Conflicts[J];
          if (Dependency <> nil) and (DisableNames.CountParams(Dependency.Name) <= 0) then
          begin
            if KnownNames.CountParams(Dependency.Name) > 0 then
            begin
              Text := LocalizedText('FormMods.ErrorInvalidConfiguration');
              ReplaceTextToken(Text, '<ModName>', Dependency.Name, '');
              ShowMessageBoxGI(Self, Text, mbgOK or mbgError);
              Exit;
            end;
            DisableNames.AddParam(Dependency.Name, '');
            VariantIndex := 0;
            while Dependency <> nil do
            begin
              if Dependency.SwitchImage.UserIndex = 1 then DisableIndices.AddParam(Dependency.IndexText, '');
              if not Dependency.DuplicateName then Break;
              Inc(VariantIndex);
              Dependency := Related.GetConflict(J, VariantIndex);
            end;
          end;
        end;
      end;
      for I := 0 to ModInfos.Count - 1 do
      begin
        Related := TModInfo(ModInfos[I]);
        if Related.ConflictCount <> 0 then
        begin
          Text := IntToWideString(I);
          if ((Related.SwitchImage.UserIndex <> 0) or (EnableIndices.CountParams(Text) > 0)) and
             (DisableIndices.CountParams(Text) <= 0) then
            for J := 0 to Related.ConflictCount - 1 do
            begin
              Dependency := Related.Conflicts[J];
              if Dependency <> nil then
                if KnownNames.CountParams(Dependency.Name) > 0 then
                begin
                  if EnableIndices.CountParams(Text) > 0 then
                  begin
                    Text := LocalizedText('FormMods.ErrorInvalidConfiguration');
                    ReplaceTextToken(Text, '<ModName>', Related.Name, '');
                    ShowMessageBoxGI(Self, Text, mbgOK or mbgError);
                  end;
                  DisableIndices.AddParam(Text, '');
                  if DisableNames.CountParams(Related.Name) <= 0 then DisableNames.AddParam(Related.Name, '');
                  Break;
                end;
            end;
        end;
      end;
      repeat
        PassChanged := False;
        for I := 0 to ModInfos.Count - 1 do
        begin
          Related := TModInfo(ModInfos[I]);
          if Related.DependencyCount <> 0 then
          begin
            Value := IntToWideString(I);
            if ((Related.SwitchImage.UserIndex <> 0) or (EnableIndices.CountParams(Value) > 0)) and
               (DisableIndices.CountParams(Value) <= 0) then
              for J := 0 to Related.DependencyCount - 1 do
              begin
                Dependency := Related.Dependencies[J];
                if (Dependency <> nil) and (DisableNames.CountParams(Dependency.Name) > 0) then
                begin
                  Alternative := False;
                  if Dependency.DuplicateName then
                  begin
                    VariantIndex := 0;
                    while Dependency <> nil do
                    begin
                      if (Dependency.SwitchImage.UserIndex = 1) and (DisableIndices.CountParams(Dependency.IndexText) <= 0) then
                      begin
                        Alternative := True;
                        Break;
                      end;
                      Inc(VariantIndex);
                      Dependency := Related.GetDependency(J, VariantIndex);
                    end;
                  end;
                  if not Alternative then
                  begin
                    PassChanged := True;
                    Temp := IntToWideString(I);
                    if EnableIndices.CountParams(Temp) > 0 then
                    begin
                      Text := LocalizedText('FormMods.ErrorInvalidConfiguration');
                      if Related <> Info then ReplaceTextToken(Text, '<ModName>', Related.Name, '')
                      else ReplaceTextToken(Text, '<ModName>', Info.Folder, '');
                      ShowMessageBoxGI(Self, Text, mbgOK or mbgError);
                      Exit;
                    end;
                    DisableIndices.AddParam(Temp, '');
                    if DisableNames.CountParams(Related.Name) <= 0 then DisableNames.AddParam(Related.Name, '');
                    Break;
                  end;
                end;
              end;
          end;
        end;
      until not PassChanged;
      if (DisableIndices.GetParamCount = 0) and (EnableIndices.GetParamCount = 1) then
      begin
        SetModSelected(Sender, True);
        Changed := True;
        Exit;
      end;
      Value := '';
      for I := 0 to DisableIndices.GetParamCount - 1 do
      begin
        Index := ExtractDigitsToIntW(DisableIndices.GetParamName(I));
        if Value = '' then Value := TModInfo(ModInfos[Index]).Name
        else Value := Value + ', ' + TModInfo(ModInfos[Index]).Name;
      end;
      Text := '';
      for I := 0 to EnableIndices.GetParamCount - 1 do
      begin
        Temp := EnableIndices.GetParamName(I);
        if Temp <> Info.IndexText then
        begin
          Index := ExtractDigitsToIntW(Temp);
          if Text = '' then Text := TModInfo(ModInfos[Index]).Name
          else Text := Text + ', ' + TModInfo(ModInfos[Index]).Name;
        end;
      end;
      if Value <> '' then
      begin
        Temp := LocalizedText('FormMods.QueryTurnOnWithExtra2');
        ReplaceTextToken(Temp, '<ModsList>', '<color=255,240,100>' + Value + '</color>', '');
      end
      else Temp := '';
      if Text <> '' then
      begin
        Value := LocalizedText('FormMods.QueryTurnOnWithExtra1');
        ReplaceTextToken(Value, '<ModsList>', '<color=255,240,100>' + Text + '</color>', '');
      end
      else Value := '';
      if (Temp <> '') and (Value <> '') then Value := Value + #13#10 + Temp
      else Value := Value + Temp;
      Temp := LocalizedText('FormMods.QueryTurnOnWithExtra0') + #13#10 + Value + #13#10 + LocalizedText('FormMods.QueryTurnOnWithExtra3');
      if ShowMessageBoxGI(GetInnermostScreenLoop, Temp, mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then Exit;
      Changed := True;
      for I := 0 to DisableIndices.GetParamCount - 1 do
      begin
        Index := ExtractDigitsToIntW(DisableIndices.GetParamName(I));
        SetModSelected(TModInfo(ModInfos[Index]).SwitchImage, False);
      end;
      for I := 0 to EnableIndices.GetParamCount - 1 do
      begin
        Index := ExtractDigitsToIntW(EnableIndices.GetParamName(I));
        SetModSelected(TModInfo(ModInfos[Index]).SwitchImage, True);
      end;
    end;
  finally
    if Choices <> nil then Choices.Free;
    if DisableIndices <> nil then DisableIndices.Free;
    if EnableIndices <> nil then EnableIndices.Free;
    if DisableNames <> nil then DisableNames.Free;
    if KnownNames <> nil then KnownNames.Free;
    if Changed then UpdateTabDisplay;
    SwitchMouseLeave(Sender);
  end;
end;
{ @end $5367E0 }

{ @routine $5377BC TfModsManager_SetModSelected }
procedure TfModsManager.SetModSelected(Sender: TObjectGI; Value: Boolean);
var
  Info: TModInfo;
  Tab: Integer;
  LanguageWarning: Boolean;
begin
  if (Sender.UserIndex = 1) = Value then Exit;
  Tab := Sender.Parent.UserValue;
  Info := TModInfo(Sender.UserValue);
  LanguageWarning := Info.UnsupportedLanguage and not Info.DuplicateName and not Info.Misplaced;
  if Value then
  begin
    Sender.UserIndex := 1;
    Inc(SelectedCounts[Tab]);
    if Info.MissingFolder or Info.MissingDependency then
    begin
      Inc(ErrorCounts[Tab]);
      Dec(WarningCounts[Tab]);
    end
    else if LanguageWarning then Inc(WarningCounts[Tab]);
  end
  else
  begin
    Sender.UserIndex := 0;
    Dec(SelectedCounts[Tab]);
    if Info.MissingFolder or Info.MissingDependency then
    begin
      Dec(ErrorCounts[Tab]);
      Inc(WarningCounts[Tab]);
    end
    else if LanguageWarning then Dec(WarningCounts[Tab]);
  end;
  UpdateModSwitch(Sender);
  if (Info.ConflictCount > 0) or (Info.DependencyCount > 0) or
     Info.ReferencedAsConflict or Info.ReferencedAsDependency then NeedsValidation := True;
end;
{ @end $5377BC }

{ @routine $53792C TfModsManager_UpdateModSwitch }
procedure TfModsManager.UpdateModSwitch(Sender: TObjectGI);
var
  Info: TModInfo;
  Selected, Warning: Boolean;
begin
  Info := TModInfo(Sender.UserValue);
  Selected := Sender.UserIndex = 1;
  Warning := Info.DuplicateName or Info.Misplaced or
    (Info.UnsupportedLanguage and Selected) or Info.MissingFolder or Info.MissingDependency;
  if Selected then (Sender as TImageGI).SetImagePath('GI,Bm.FormOptions2.2SwitchD')
  else (Sender as TImageGI).SetImagePath('GI,Bm.FormOptions2.2SwitchN');
  TObjectGI(Sender.UserData).SetActive(Warning or Info.UnsupportedLanguage);
  with TLabelGI(Sender.UserState) do
    if (Info.MissingFolder or Info.MissingDependency) and Selected then SetTextColor(ModErrorColor)
    else if Warning then SetTextColor(ModWarningColor)
    else if Selected then SetTextColor(ModSelectedColor)
    else SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 234, 118));
end;
{ @end $53792C }

{ @routine $537AE0 TfModsManager_ShowInfoClick }
procedure TfModsManager.ShowInfoClick(Sender: TObjectGI);
var
  Info: TModInfo;
  Body, Text: WideString;
begin
  Info := TModInfo(Sender.UserValue);
  Body := LocalizedText('FormMods.InfoName');
  ReplaceTextToken(Body, '<Name>', '<color=255,240,100>' + Info.GetDisplayName + '</color>', '');
  Body := Body + #13#10 + ' ' + #13#10;
  if Info.Author = '' then Text := LocalizedText('FormMods.InfoAuthorUnknown')
  else if CountDelimitedPartsW(Info.Author, ',') > 1 then Text := LocalizedText('FormMods.InfoAuthors')
  else Text := LocalizedText('FormMods.InfoAuthor');
  ReplaceTextToken(Text, '<Name>', '<color=255,240,100>' + Info.Author + '</color>', '');
  Body := Body + Text + #13#10 + ' ' + #13#10;
  if Info.FullDescription = '' then Body := Body + LocalizedText('FormMods.NoDescription') + #13#10 + ' ' + #13#10
  else Body := Body + Info.FullDescription + #13#10 + ' ' + #13#10;
  if Info.DependencyNames <> '' then
  begin
    Text := LocalizedText('FormMods.InfoDependencies');
    ReplaceTextToken(Text, '<Mods>', '<color=255,240,100>' + Info.DependencyNames + '</color>', '');
    Body := Body + Text + #13#10 + ' ' + #13#10;
  end;
  if Info.ConflictNames <> '' then
  begin
    Text := LocalizedText('FormMods.InfoConflicts');
    ReplaceTextToken(Text, '<Mods>', '<color=255,240,100>' + Info.ConflictNames + '</color>', '');
    Body := Body + Text + #13#10 + ' ' + #13#10;
  end;
  Text := LocalizedText('FormMods.InfoPath');
  ReplaceTextToken(Text, '<Path>', '<color=255,240,100>' + Info.Folder + '</color>', '');
  Body := Body + Text;
  ShowMessageBoxGI(Self, Body, mbgOK or mbgUnused04 or mbgLeftAlign);
end;
{ @end $537AE0 }

{ @routine $537FF8 TfModsManager_ShowProblemsClick }
procedure TfModsManager.ShowProblemsClick(Sender: TObjectGI);
var
  I, J, VariantIndex: Integer;
  Info, Related: TModInfo;
  Body, Value, Text: WideString;
  Critical, Found, Selected: Boolean;
  Options: Cardinal;
begin
  Info := TModInfo(Sender.UserValue);
  Selected := Info.SwitchImage.UserIndex = 1;
  Critical := False;
  Body := LocalizedText('FormMods.ProblemsInfoHeader');
  ReplaceTextToken(Body, '<Name>', '<color=255,240,100>' + Info.GetDisplayName + '</color>', '');
  Body := Body + #13#10 + ' ' + #13#10;
  if Info.MissingFolder then
  begin
    Critical := True;
    Body := Body + LocalizedText('FormMods.ProblemsInfoMissing') + #13#10 + ' ' + #13#10;
  end
  else
  begin
    if Info.UnsupportedLanguage then
      Body := Body + LocalizedText('FormMods.ProblemsInfoForeign') + #13#10 + ' ' + #13#10;
    if Info.Misplaced then
      Body := Body + LocalizedText('FormMods.ProblemsInfoMisplaced') + #13#10 + ' ' + #13#10;
    if Info.DuplicateName then
    begin
      Value := '';
      for I := 0 to ModInfos.Count - 1 do
      begin
        Related := TModInfo(ModInfos[I]);
        if Related.DuplicateName and (Related.Name = Info.Name) and (Related <> Info) then
          if Value = '' then Value := Related.Folder else Value := Value + ', ' + Related.Folder;
      end;
      if Info.ReferencedAsConflict or Info.ReferencedAsDependency then
      begin
        Text := LocalizedText('FormMods.ProblemsInfoSharedName');
        Critical := True;
      end
      else Text := LocalizedText('FormMods.ProblemsInfoSharedName2');
      ReplaceTextToken(Text, '<Mods>', '<color=255,240,100>' + Value + '</color>', '');
      Body := Body + Text + #13#10 + ' ' + #13#10;
    end;
    if Selected and (Info.ConflictCount > 0) then
    begin
      Text := '';
      for J := 0 to Info.ConflictCount - 1 do
      begin
        VariantIndex := 0;
        Related := Info.Conflicts[J];
        while Related <> nil do
        begin
          if Related.SwitchImage.UserIndex = 1 then
            if Text = '' then Text := Related.Folder else Text := Text + ', ' + Related.Folder;
          if not Related.DuplicateName then Break;
          Inc(VariantIndex);
          Related := Info.GetConflict(J, VariantIndex);
        end;
      end;
      if Text <> '' then
      begin
        Value := LocalizedText('FormMods.ProblemsInfoConflicts');
        ReplaceTextToken(Value, '<Mods>', '<color=255,240,100>' + Text + '</color>', '');
        Body := Body + Value + #13#10 + ' ' + #13#10;
        Critical := True;
      end;
    end;
    if Info.DependencyCount > 0 then
    begin
      Text := '';
      for J := 0 to Info.DependencyCount - 1 do
      begin
        Related := Info.Dependencies[J];
        if Related = nil then
        begin
          Value := LocalizedText('FormMods.ProblemsInfoDependencies2');
          ReplaceTextToken(Value, '<Mod>', '<color=255,240,100>' + TrimWideString(ExtractDelimitedPartW(Info.DependencyNames, J, ',')) + '</color>', '');
          Body := Body + Value + #13#10 + ' ' + #13#10;
          Critical := Selected;
        end
        else if Selected then
        begin
          Found := False;
          VariantIndex := 0;
          while Related <> nil do
          begin
            if Related.SwitchImage.UserIndex = 1 then
            begin
              Found := True;
              Break;
            end;
            if not Related.DuplicateName then Break;
            Inc(VariantIndex);
            Related := Info.GetDependency(J, VariantIndex);
          end;
          if not Found then
            if Text = '' then Text := Info.Dependencies[J].Name
            else Text := Text + ', ' + Info.Dependencies[J].Name;
        end;
      end;
      if Text <> '' then
      begin
        Value := LocalizedText('FormMods.ProblemsInfoDependencies');
        ReplaceTextToken(Value, '<Mods>', '<color=255,240,100>' + Text + '</color>', '');
        Body := Body + Value + #13#10 + ' ' + #13#10;
        Critical := True;
      end;
    end;
  end;
  if Critical then Options := $20 else Options := $08;
  ShowMessageBoxGI(Self, Body, Options or (mbgOK or mbgUnused04));
end;
{ @end $537FF8 }

{ @routine $5388FC TfModsManager_SelectMusic }
procedure TfModsManager.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $5388FC }

{ @routine $538928 ShowModsManager }
function ShowModsManager(Parent: TMessageLoopGI): Integer;
var State: TCursorStateGI;
begin
  if ((ModInfos = nil) or (ModInfos.Count <= 0)) and (ModsManagerScreen <> nil) then
  begin
    ModsManagerScreen.Free;
    ModsManagerScreen := nil;
  end;
  InitializeModInfos;
  if ModInfos.Count <= 0 then
  begin
    ShowMessageBoxGI(Parent, LocalizedText('FormMods.NoMods'), mbgOK or mbgUnused04);
    Result := 0;
    Exit;
  end;
  Parent.RootUiObject.NativeHook50;
  Parent.CaptureCursorState(@State);
  Parent.SetCursorActive(False);
  Parent.DrawQueuedUpdateRects;
  CaptureScreenBackground(True, 0);
  if ModsManagerScreen = nil then
  begin
    ModsManagerScreen := TfModsManager.Create;
    ModsManagerScreen.InitializeFromConfig(UiStyleConfig, 'ModsManager', True);
    ModsManagerScreen.InitializeLayout;
  end;
  ModsManagerScreen.ParentLoop := Parent;
  Parent.ChildLoop := ModsManagerScreen;
  try
    Result := ModsManagerScreen.Run;
    Parent.InvalidateViewport;
  finally
    Parent.ChildLoop := nil;
    ModsManagerScreen.ParentLoop := nil;
  end;
  Parent.RestoreCursorState(@State);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.NativeHook48;
end;
{ @end $538928 }

end.
