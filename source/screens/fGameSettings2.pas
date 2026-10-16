unit fGameSettings2;

interface

uses EC_BlockPar, EC_Thread, GI_CountBar, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, Types, aGalaxyStruct;

type
  TNewGameSliderEvent = procedure(Sender: TCountBarGI) of object;

  TfGameSettings2 = class(TMessageLoopGI) // @size 0x16C
  public
    CollapsedLevelPanelTop: Integer; // @offset 0xD0
    LevelPanelTop: Integer; // @offset 0xD4
    LevelPanelTimer: TCallbackTimerIdGI; // @offset 0xD8
    PlayerRace: TOwnerId; // @offset 0xDC
    CharacterPreset: Integer; // @offset 0xE0
    CaptainPortraitIndex: Integer; // @offset 0xE4
    LastPortraitByRace: array[owner_maloc..owner_gaal] of Integer; // @offset 0xE8
    StartingSkills: array[0..1] of TPilotSkill; // @offset 0xFC
    SelectedSkillSlot: Integer; // @offset 0x100
    StartingItemChoices: array[0..1] of Integer; // @offset 0x104 // Choice values are 1..12; ItemTypeByChoice is zero-based.
    SelectedItemSlot: Integer; // @offset 0x10C
    ItemTypeByChoice: array[0..11] of Byte; // @offset 0x110
    DifficultyPreset: Byte; // @offset 0x11C
    DifficultyLevels: TGalaxyDifficultyLevels; // @offset 0x11D
    PlayerNameEdited: Boolean; // @offset 0x125
    PlayerNameValid: Boolean; // @offset 0x126
    IronWillImage: TImageGI; // @offset 0x128
    IronWillLabel: TLabelGI; // @offset 0x12C
    IronWill: Boolean; // @offset 0x130
    ActiveExtendedGroup: Integer; // @offset 0x134
    ExtendedGroupPanels: array[0..3] of TPanelGI; // @offset 0x138
    ExtendedGroupNextY: array[0..3] of Integer; // @offset 0x148
    BuildExtendedGroup: Integer; // @offset 0x158
    CurrentExtendedOption: WideString; // @offset 0x15C
    ExtendedGroupButtonTops: array[0..2] of Integer; // @offset 0x160

    procedure InitializeLayout; override; // @addr 0x005C03FC
    procedure OnOpen; override; // @addr 0x005C1900
    procedure OnClose; override; // @addr 0x005C6258
    procedure SelectMusic; override; // @addr 0x005CA4D0
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x005CCBF0
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x005CC454
    procedure AddIronWillChoice(Value, X, Y: Integer; Caption, Help: WideString; Selected, Disabled: Boolean); // @addr 0x005C62D4
    procedure IronWillMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005C6694
    procedure IronWillMouseEnter(Sender: TObjectGI); // @addr 0x005C6868
    procedure IronWillMouseLeave(Sender: TObjectGI); // @addr 0x005C699C
    procedure GeneratePlayerName; // @addr 0x005C6AD0
    procedure PlayerNameMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005C6C4C
    procedure ToggleLevelPanel(Sender: TObjectGI); // @addr 0x005C6C9C
    procedure AnimateLevelPanel(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x005C6D5C
    procedure RaceClicked(Sender: TObjectGI); // @addr 0x005C6FC4
    procedure CharacterPresetClicked(Sender: TObjectGI); // @addr 0x005C7198
    procedure PreviousPortraitClicked(Sender: TObjectGI); // @addr 0x005C7580
    procedure NextPortraitClicked(Sender: TObjectGI); // @addr 0x005C758C
    procedure StartingSkillClicked(Sender: TObjectGI); // @addr 0x005C76C4
    procedure StartingItemClicked(Sender: TObjectGI); // @addr 0x005C7874
    procedure DifficultyComponentClicked(Sender: TObjectGI); // @addr 0x005C7DB8
    procedure DifficultyPresetClicked(Sender: TObjectGI); // @addr 0x005C80A4
    procedure CustomDifficultyClicked(Sender: TObjectGI); // @addr 0x005C86CC
    procedure ApplyClicked(Sender: TObjectGI); // @addr 0x005C87B8
    procedure CancelClicked(Sender: TObjectGI); // @addr 0x005C9D64
    procedure PlayerNameChanged(Sender: TObjectGI); // @addr 0x005C9EB4
    procedure HelpMouseEnter(Sender: TObjectGI); // @addr 0x005CA4C0
    procedure HelpMouseLeave(Sender: TObjectGI); // @addr 0x005CA4C8
    procedure ExtendedSettingsPressed(Sender: TObjectGI); // @addr 0x005CA4F4
    procedure ToggleExtendedSettings(Sender: TObjectGI); // @addr 0x005CA4F8
    procedure ResetExtendedSettingsClicked(Sender: TObjectGI); // @addr 0x005CA5BC
    procedure ExtendedGroupClicked(Sender: TObjectGI); // @addr 0x005CACE4
    procedure RefreshPortrait; // @addr 0x005C72C8
    procedure RefreshStartingSkills; // @addr 0x005C7598
    procedure RefreshStartingItems; // @addr 0x005C773C
    procedure RefreshDifficulty; // @addr 0x005C78EC
    procedure StartNewGameGeneration; // @addr 0x005C8718
    procedure RefreshExtendedGroup; // @addr 0x005CADB8
    procedure IncreaseAllDifficulties; // @addr 0x005CC508
    procedure DecreaseAllDifficulties; // @addr 0x005CC588
    procedure RefreshDifficultyHelp; // @addr 0x005CC600
    procedure CustomDifficultyMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005C86E8
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x005C9DBC
    function ValidatePlayerName(ProposedName: WideString): Boolean; // @addr 0x005CA0B0 @note "Also removes <>{} from the edit control and adjusts its caret; rejects empty names and unsupported glyphs."
    procedure ShowControlHelp(Sender: TObjectGI; Show: Boolean); // @addr 0x005CA2E4
    function AddExtendedOptionLabel(OptionName, Caption: WideString; UnusedFlag: Boolean): TLabelGI; // @addr 0x005CAF04
    procedure AddExtendedOptionChoice(Value: Integer; Caption: WideString; Selected, Disabled: Boolean); // @addr 0x005CB138
    procedure AddExtendedOptionSlider(ValueLabel: TLabelGI; Minimum, Maximum, Position, UnusedStep: Integer; Callback: TNewGameSliderEvent); // @addr 0x005CB680 @note "Invokes Callback immediately with the new slider."
    procedure ExtendedChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005CB52C
    function GetExtendedOptionValue(OptionName: WideString): Integer; // @addr 0x005CBCD8 @note "Searches only the active extended group; raises when no value is found."
    procedure SetExtendedOptionValue(OptionName: WideString; Value: Integer); // @addr 0x005CBE2C @note "Searches only the active extended group; missing options are ignored."
    procedure FormatExtendedInteger(Sender: TCountBarGI); // @addr 0x005CBF14
    procedure FormatExtendedAutoPercent(Sender: TCountBarGI); // @addr 0x005CC000
    procedure FormatExtendedDifficultyPercent(Sender: TCountBarGI); // @addr 0x005CC248
    procedure FormatExtendedPercent(Sender: TCountBarGI); // @addr 0x005CC35C
  end;

implementation

uses fGameSettings, Classes, Windows, SysUtils, Math, EC_Str, EC_Struct, GI_GraphButton,
  GI_Edit, GI_PanelScrollBar, GI_Main, GR_Main, Globals, GlobalsV, aConst,
  aMyFunction, fFilmFile, GI_gai, GR_DX, aGalaxy, aPlayer, aPlanet, aRanger,
  aShip, aItem, aKling, aRuins, fIntroduction, ThreadCalc, aScript;



{ @routine $5C03FC TfGameSettings2_InitializeLayout }
procedure TfGameSettings2.InitializeLayout;
var I, J: Integer; Text: WideString; Race: TOwnerId; Unused: Integer; // Unused local; original type is unknown.
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fGameSettings2... ');
  for Race := owner_maloc to owner_gaal do
  begin
    I := -1;
    repeat
      Inc(I);
      Text := IntToStr(I);
      if I < 10 then Text := '0' + Text;
    until GameDataConfig.GetBlockByPath('StyleFace' + OwnerInfo[RaceToOwner(Race)].InternalName).CountParams(Text) <= 0;
    LastPortraitByRace[Race] := I - 1;
  end;
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('ImageBG') do SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('PanelChar') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PanelLevels') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PanelSkills') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PanelExtended') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ok') do
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('Cancel') do
    begin
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('ImageHelp') do
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('ImageFooter') do
    begin
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      SetSize(Classes.Point(GameScreenWidth,ClientSize.Y));
    end;
    with FindByNameRecursive('LabelHelp') do
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    end;
  end;
  AppendLogLineThreadSafe('ok');
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  GetByName('MainPanel').LeftButtonDownCallback := PlayerNameMouseDown;
  SetHelpCallback(ShowControlHelp);
  CollapsedLevelPanelTop := GetByName('PanelLevel').LocalPosition.Y;
  (GetByName('LevelOpen') as TGraphButtonGI).UpCallback := ToggleLevelPanel;
  (GetByName('LevelClose') as TGraphButtonGI).UpCallback := ToggleLevelPanel;
  with GetByName('RaceMaloc') as TGraphButtonGI do
  begin
    DownCallback := RaceClicked;
    UpCallback := RaceClicked;
    UserValue := 0;
  end;
  with GetByName('RacePeleng') as TGraphButtonGI do
  begin
    DownCallback := RaceClicked;
    UpCallback := RaceClicked;
    UserValue := 1;
  end;
  with GetByName('RacePeople') as TGraphButtonGI do
  begin
    DownCallback := RaceClicked;
    UpCallback := RaceClicked;
    UserValue := 2;
  end;
  with GetByName('RaceFei') as TGraphButtonGI do
  begin
    DownCallback := RaceClicked;
    UpCallback := RaceClicked;
    UserValue := 3;
  end;
  with GetByName('RaceGaal') as TGraphButtonGI do
  begin
    DownCallback := RaceClicked;
    UpCallback := RaceClicked;
    UserValue := 4;
  end;
  with GetByName('Char1') as TGraphButtonGI do
  begin
    DownCallback := CharacterPresetClicked;
    UpCallback := CharacterPresetClicked;
  end;
  with GetByName('Char2') as TGraphButtonGI do
  begin
    DownCallback := CharacterPresetClicked;
    UpCallback := CharacterPresetClicked;
  end;
  with GetByName('Char3') as TGraphButtonGI do
  begin
    DownCallback := CharacterPresetClicked;
    UpCallback := CharacterPresetClicked;
  end;
  with GetByName('Char4') as TGraphButtonGI do
  begin
    DownCallback := CharacterPresetClicked;
    UpCallback := CharacterPresetClicked;
  end;
  with GetByName('Char5') as TGraphButtonGI do
  begin
    DownCallback := CharacterPresetClicked;
    UpCallback := CharacterPresetClicked;
  end;
  (GetByName('FaceLeft') as TGraphButtonGI).DownCallback := PreviousPortraitClicked;
  (GetByName('FaceRight') as TGraphButtonGI).DownCallback := NextPortraitClicked;
  with GetByName('Skill1') as TGraphButtonGI do
  begin
    DownCallback := StartingSkillClicked;
    UpCallback := StartingSkillClicked;
  end;
  with GetByName('Skill2') as TGraphButtonGI do
  begin
    DownCallback := StartingSkillClicked;
    UpCallback := StartingSkillClicked;
  end;
  with GetByName('Skill3') as TGraphButtonGI do
  begin
    DownCallback := StartingSkillClicked;
    UpCallback := StartingSkillClicked;
  end;
  with GetByName('Skill4') as TGraphButtonGI do
  begin
    DownCallback := StartingSkillClicked;
    UpCallback := StartingSkillClicked;
  end;
  with GetByName('Skill5') as TGraphButtonGI do
  begin
    DownCallback := StartingSkillClicked;
    UpCallback := StartingSkillClicked;
  end;
  with GetByName('Skill6') as TGraphButtonGI do
  begin
    DownCallback := StartingSkillClicked;
    UpCallback := StartingSkillClicked;
  end;
  for I := 1 to Length(ItemTypeByChoice) do
    with GetByName('Item' + IntToStr(I)) as TGraphButtonGI do
    begin
      DownCallback := StartingItemClicked;
      UpCallback := StartingItemClicked;
    end;
  for I := Low(ItemTypeByChoice) to High(ItemTypeByChoice) do ItemTypeByChoice[I] := I + 43;
  for I := Low(ItemTypeByChoice) to High(ItemTypeByChoice) do
    if ItemTypeByChoice[I] in [Ord(item_industrial_laser)..Ord(item_lirecron)] then
      (GetByName('ItemI' + IntToStr(I + 1)) as TImageGI).ImageSourcePath := 'GI,Bm.Items.' + GiResourceSuffix + ItemTypeNames[TItemType(ItemTypeByChoice[I])] + 's'
    else
      (GetByName('ItemI' + IntToStr(I + 1)) as TImageGI).ImageSourcePath := 'GI,Bm.Items.' + GiResourceSuffix + ItemTypeNames[TItemType(ItemTypeByChoice[I])] + IntToStr(1) + 's';
  for I := 1 to 4 do
    for J := Low(DifficultyLevels) to High(DifficultyLevels) do
      with GetByName('Level' + IntToStr(I) + '_' + IntToStr(J)) as TGraphButtonGI do
      begin
        UpCallback := DifficultyComponentClicked;
        DownCallback := DifficultyComponentClicked;
        UserValue := J;
        UserIndex := I;
      end;
  with GetByName('LevelUser') as TGraphButtonGI do
  begin
    UpCallback := CustomDifficultyClicked;
    DownCallback := CustomDifficultyClicked;
  end;
  with GetByName('Level1') as TGraphButtonGI do
  begin
    UpCallback := DifficultyPresetClicked;
    DownCallback := DifficultyPresetClicked;
    LeftButtonDoubleClickCallback := CustomDifficultyMouseUp;
  end;
  with GetByName('Level2') as TGraphButtonGI do
  begin
    UpCallback := DifficultyPresetClicked;
    DownCallback := DifficultyPresetClicked;
    LeftButtonDoubleClickCallback := CustomDifficultyMouseUp;
  end;
  with GetByName('Level3') as TGraphButtonGI do
  begin
    UpCallback := DifficultyPresetClicked;
    DownCallback := DifficultyPresetClicked;
    LeftButtonDoubleClickCallback := CustomDifficultyMouseUp;
  end;
  with GetByName('Level4') as TGraphButtonGI do
  begin
    UpCallback := DifficultyPresetClicked;
    DownCallback := DifficultyPresetClicked;
    LeftButtonDoubleClickCallback := CustomDifficultyMouseUp;
  end;
  (GetByName('Ok') as TGraphButtonGI).UpCallback := ApplyClicked;
  (GetByName('Cancel') as TGraphButtonGI).UpCallback := CancelClicked;
  with GetByName('PlayerName') as TEditGI do
  begin
    ChangedCallback := PlayerNameChanged;
    MaxLength := 13;
    MouseEnterCallback := HelpMouseEnter;
    MouseLeaveCallback := HelpMouseLeave;
  end;
  with GetByName('CaptainI') do
  begin
    MouseEnterCallback := HelpMouseEnter;
    MouseLeaveCallback := HelpMouseLeave;
  end;
  with GetByName('LevelProc') do
  begin
    MouseEnterCallback := HelpMouseEnter;
    MouseLeaveCallback := HelpMouseLeave;
  end;
  (GetByName('ButExtended') as TGraphButtonGI).DownCallback := ExtendedSettingsPressed;
  (GetByName('ButCloseExt') as TGraphButtonGI).UpCallback := ToggleExtendedSettings;
  (GetByName('ButReset') as TGraphButtonGI).UpCallback := ResetExtendedSettingsClicked;
  with GetByName('ButGroup0') as TGraphButtonGI do
  begin
    UpCallback := ExtendedGroupClicked;
    DownCallback := ExtendedGroupClicked;
    ExtendedGroupButtonTops[0] := LocalPosition.Y;
  end;
  with GetByName('ButGroup1') as TGraphButtonGI do
  begin
    UpCallback := ExtendedGroupClicked;
    DownCallback := ExtendedGroupClicked;
    ExtendedGroupButtonTops[1] := LocalPosition.Y;
  end;
  with GetByName('ButGroup2') as TGraphButtonGI do
  begin
    UpCallback := ExtendedGroupClicked;
    DownCallback := ExtendedGroupClicked;
    ExtendedGroupButtonTops[2] := LocalPosition.Y;
  end;
end;
{ @end $5C03FC }

{ @routine $5C1900 TfGameSettings2_OnOpen }
procedure TfGameSettings2.OnOpen;
var
  I, X, Y, Value: Integer;
  Text, ValueText: WideString;
  Owner: TPanelScrollBarGI;
  ValueLabel: TLabelGI;
  Position: Integer;
  Enabled: Boolean;

  // @nested $5C184C GetNewGameCustomRule
  function GetNewGameCustomRule(Path: WideString): WideString; // @addr 0x005C184C @calls "0x005C221E,0x005C2291,0x005C2304,0x005C2377,0x005C23EA,0x005C245F,0x005C24D4,0x005C2546,0x005C25DC,0x005C2672,0x005C2708,0x005C27F1,0x005C2866,0x005C28DB,0x005C2950,0x005C29C5,0x005C2A3A,0x005C2ADA,0x005C2B70,0x005C2C06,0x005C2C9C,0x005C2D32,0x005C2DC8,0x005C2E3D,0x005C2EB2,0x005C2F48,0x005C2FBD,0x005C3032,0x005C30A7,0x005C311C,0x005C31B2,0x005C3248,0x005C32BD,0x005C3353,0x005C33E9,0x005C347F,0x005C3515,0x005C35AB" @note "Nested in OnOpen; static link unused. Returns an empty string for an absent CustomRules block or key."
  begin
    Result := '';
    if NewGameSettingsConfig.CountBlocks('CustomRules') <> 0 then
      if NewGameSettingsConfig.GetBlockByPath('CustomRules').CountParamsByPath(Path) <> 0 then
        Result := NewGameSettingsConfig.GetBlockByPath('CustomRules').GetParamByPath(Path);
  end;

begin
  PlayerNameEdited := False;
  PlayerNameValid := True;
  IronWillLabel := nil;
  IronWill := False;
  LevelPanelTop := CollapsedLevelPanelTop;
  GetByName('PanelLevel').SetPosition(Classes.Point(GetByName('PanelLevel').LocalPosition.X, LevelPanelTop));
  (GetByName('LevelOpen') as TGraphButtonGI).SetActive(True);
  (GetByName('LevelClose') as TGraphButtonGI).SetActive(False);
  if NewGameSettingsConfig.CountParamsByPath('Race') > 0 then
  begin
    Text := NewGameSettingsConfig.GetParamByPathOrMarker('Race');
    if Text = 'Maloc' then
    begin
      PlayerRace := owner_maloc;
      RaceClicked(GetByName('RaceMaloc'));
    end
    else if Text = 'Peleng' then
    begin
      PlayerRace := owner_peleng;
      RaceClicked(GetByName('RacePeleng'));
    end
    else if Text = 'Fei' then
    begin
      PlayerRace := owner_feyan;
      RaceClicked(GetByName('RaceFei'));
    end
    else if Text = 'Gaal' then
    begin
      PlayerRace := owner_gaal;
      RaceClicked(GetByName('RaceGaal'));
    end
    else
    begin
      PlayerRace := owner_human;
      RaceClicked(GetByName('RacePeople'));
    end;
  end
  else
  begin
    PlayerRace := owner_human;
    RaceClicked(GetByName('RacePeople'));
  end;
  if (NewGameSettingsConfig.CountParamsByPath('Name') > 0) and (NewGameSettingsConfig.GetParamByPathOrMarker('Name') <> '') then
  begin
    Text := NewGameSettingsConfig.GetParamByPathOrMarker('Name');
    (GetByName('PlayerName') as TEditGI).SetText(Text);
    ValidatePlayerName(Text);
  end;
  if (NewGameSettingsConfig.CountParamsByPath('Char') > 0) and
    IsIntegerTextW(NewGameSettingsConfig.GetParamByPathOrMarker('Char')) and
    (ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Char')) in [1..5]) then
    CharacterPreset := ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Char'))
  else CharacterPreset := 3;
  CharacterPresetClicked(GetByName('Char' + IntToStr(CharacterPreset)));
  if (NewGameSettingsConfig.CountParamsByPath('Face') > 0) and
    IsIntegerTextW(NewGameSettingsConfig.GetParamByPathOrMarker('Face')) then
    CaptainPortraitIndex := ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Face'))
  else CaptainPortraitIndex := 0;
  RefreshPortrait;
  SelectedSkillSlot := 0;
  if (NewGameSettingsConfig.CountParamsByPath('Skill1') > 0) and
    IsIntegerTextW(NewGameSettingsConfig.GetParamByPathOrMarker('Skill1')) and
    (ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Skill1')) in [0..5]) and
    (NewGameSettingsConfig.CountParamsByPath('Skill2') > 0) and
    IsIntegerTextW(NewGameSettingsConfig.GetParamByPathOrMarker('Skill2')) and
    (ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Skill2')) in [0..5]) and
    (ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Skill1')) <> ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Skill2'))) then
  begin
    StartingSkills[0] := TPilotSkill(ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Skill1')));
    StartingSkills[1] := TPilotSkill(ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Skill2')));
  end
  else
  begin
    StartingSkills[0] := skill_accuracy;
    StartingSkills[1] := skill_trading;
  end;
  RefreshStartingSkills;
  SelectedItemSlot := 0;
  if (NewGameSettingsConfig.CountParamsByPath('Item1') > 0) and
    IsIntegerTextW(NewGameSettingsConfig.GetParamByPathOrMarker('Item1')) and
    (ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Item1')) in [1..12]) and
    (NewGameSettingsConfig.CountParamsByPath('Item2') > 0) and
    IsIntegerTextW(NewGameSettingsConfig.GetParamByPathOrMarker('Item2')) and
    (ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Item2')) in [1..12]) and
    (ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Item1')) <> ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Item2'))) then
  begin
    StartingItemChoices[0] := ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Item1'));
    StartingItemChoices[1] := ExtractDigitsToIntW(NewGameSettingsConfig.GetParamByPathOrMarker('Item2'));
  end
  else
  begin
    StartingItemChoices[0] := 1;
    StartingItemChoices[1] := 2;
  end;
  RefreshStartingItems;
  DifficultyPreset := 1;
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do
    if NewGameSettingsConfig.CountParamsByPath('Level' + IntToStr(I)) > 0 then
    begin
      ValueText := NewGameSettingsConfig.GetParamByPathOrMarker('Level' + IntToStr(I));
      if IsIntegerTextW(ValueText) then
      begin
        Value := ExtractDigitsToIntW(ValueText);
        if Value in [0..MaximumNewGameDifficulty] then DifficultyLevels[I] := Value
        else DifficultyLevels[I] := DifficultyPreset;
      end;
    end;
  RefreshDifficultyHelp;
  RefreshDifficulty;
  X := 302;
  Y := 518;
  AddIronWillChoice(0, X, Y, LocalizedColorText('FormGameSet2.Common.IronWill'), LocalizedColorText('FormGameSet2.Common.HelpIronWill'), IronWill, False);
  if NewGameSettingsConfig.CountParamsByPath('IronWill') > 0 then
    if ParseEnabledNameGI(NewGameSettingsConfig.GetParamByPathOrMarker('IronWill')) then
      IronWillMouseDown(IronWillLabel, 0, Classes.Point(-1000,-1000));
  with GetByName('PanelExtended') do SetActive(False);
  with GetByName('ButExtended') as TGraphButtonGI do
    SetDown((NewGameSettingsConfig.CountParamsByPath('UseCustomRules') > 0) and ParseEnabledNameGI(NewGameSettingsConfig.GetParamByPathOrMarker('UseCustomRules')));
  Owner := GetByName('PanelSet') as TPanelScrollBarGI;
  Owner.FreeOwnedChildren;
  for I := 0 to 3 do
  begin
    ExtendedGroupNextY[I] := 0;
    ExtendedGroupPanels[I] := TPanelGI.Create(Owner);
    with ExtendedGroupPanels[I] do
    begin
      SetSize(Classes.Point(Owner.ClientSize.X,0));
      SetPosition(Classes.Point(0,0));
      SetDepth(-100);
      SetPositionModeW(True);
    end;
  end;
  BuildExtendedGroup := 0;
  Text := GetNewGameCustomRule('KlingStrength');
  if Text = '' then Position := 0 else Position := StrToInt(Text) + 1;
  ValueLabel := AddExtendedOptionLabel('KlingStrength', LocalizedText('FormGameSet2.Extended.ParameterNames.KlingStrength'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 73, Position, 1, FormatExtendedAutoPercent);
  Text := GetNewGameCustomRule('KlingAggro');
  if Text = '' then Position := 0 else Position := StrToInt(Text) + 1;
  ValueLabel := AddExtendedOptionLabel('KlingAggro', LocalizedText('FormGameSet2.Extended.ParameterNames.KlingAggro'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 73, Position, 1, FormatExtendedAutoPercent);
  Text := GetNewGameCustomRule('KlingSpawn');
  if Text = '' then Position := 0 else Position := StrToInt(Text) + 1;
  ValueLabel := AddExtendedOptionLabel('KlingSpawn', LocalizedText('FormGameSet2.Extended.ParameterNames.KlingSpawn'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 73, Position, 1, FormatExtendedAutoPercent);
  Text := GetNewGameCustomRule('PirateAggro');
  if Text = '' then Position := 0 else Position := StrToInt(Text) + 1;
  ValueLabel := AddExtendedOptionLabel('PirateAggro', LocalizedText('FormGameSet2.Extended.ParameterNames.PirateAggro'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 73, Position, 1, FormatExtendedAutoPercent);
  Text := GetNewGameCustomRule('CoalAggro');
  if Text = '' then Position := 8 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('CoalAggro', LocalizedText('FormGameSet2.Extended.ParameterNames.CoalAggro'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 24, Position, 1, FormatExtendedDifficultyPercent);
  Text := GetNewGameCustomRule('ExtraInventions');
  if Text = '' then Position := 0 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('ExtraInventions', LocalizedText('FormGameSet2.Extended.ParameterNames.ExtraInventions'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 255, Position, 1, FormatExtendedInteger);
  Text := GetNewGameCustomRule('ExtraRangers');
  if Text = '' then Position := 0 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('ExtraRangers', LocalizedText('FormGameSet2.Extended.ParameterNames.ExtraRangers'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 50, Position, 1, FormatExtendedInteger);
  Text := GetNewGameCustomRule('ZeroStartExp');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('ZeroStartExp', LocalizedText('FormGameSet2.Extended.ParameterNames.ZeroStartExp'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.ZeroStartExpNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.ZeroStartExpYes'), Enabled, False);
  Text := GetNewGameCustomRule('KlingRacialWeapons');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('KlingRacialWeapons', LocalizedText('FormGameSet2.Extended.ParameterNames.KlingRacialWeapons'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.KlingRacialWeaponsNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.KlingRacialWeaponsYes'), Enabled, False);
  Text := GetNewGameCustomRule('MaxRangeMissiles');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('MaxRangeMissiles', LocalizedText('FormGameSet2.Extended.ParameterNames.MaxRangeMissiles'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.MaxRangeMissilesNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.MaxRangeMissilesYes'), Enabled, False);
  Text := GetNewGameCustomRule('HullGrowth');
  if Text = '' then Position := 0 else Position := StrToInt(Text);
  AddExtendedOptionLabel('HullGrowth', LocalizedText('FormGameSet2.Extended.ParameterNames.HullGrowth'), False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.HullGrowthNormal'), not (Position in [1,2]), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.HullGrowthSlow'), Position = 1, False);
  AddExtendedOptionChoice(2, LocalizedText('FormGameSet2.Extended.ParameterNames.HullGrowthTechOnly'), Position = 2, False);
  BuildExtendedGroup := 1;
  Text := GetNewGameCustomRule('AsteroidMod');
  if Text = '' then Position := 8 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('AsteroidMod', LocalizedText('FormGameSet2.Extended.ParameterNames.AsteroidMod'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 24, Position, 1, FormatExtendedDifficultyPercent);
  Text := GetNewGameCustomRule('SunDamageMod');
  if Text = '' then Position := 8 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('SunDamageMod', LocalizedText('FormGameSet2.Extended.ParameterNames.SunDamageMod'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 24, Position, 1, FormatExtendedDifficultyPercent);
  Text := GetNewGameCustomRule('AgPlanets');
  if Text = '' then Position := 5 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('AgPlanets', LocalizedText('FormGameSet2.Extended.ParameterNames.PlanetsAg'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 10, Position, 1, FormatExtendedInteger);
  Text := GetNewGameCustomRule('MiPlanets');
  if Text = '' then Position := 5 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('MiPlanets', LocalizedText('FormGameSet2.Extended.ParameterNames.PlanetsMi'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 10, Position, 1, FormatExtendedInteger);
  Text := GetNewGameCustomRule('InPlanets');
  if Text = '' then Position := 5 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('InPlanets', LocalizedText('FormGameSet2.Extended.ParameterNames.PlanetsIn'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 10, Position, 1, FormatExtendedInteger);
  Text := GetNewGameCustomRule('StartCenter');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('StartCenter', LocalizedText('FormGameSet2.Extended.ParameterNames.StartCenter'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.StartCenterNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.StartCenterYes'), Enabled, False);
  BuildExtendedGroup := 2;
  Text := GetNewGameCustomRule('RndChaotic');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('RndType', LocalizedText('FormGameSet2.Extended.ParameterNames.Rnd'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.RndDetermined'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.RndChaotic'), Enabled, False);
  Text := GetNewGameCustomRule('RuinsNearStars');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('RuinsPosition', LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsPosition'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsPositionNormal'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsPositionNear'), Enabled, False);
  Text := GetNewGameCustomRule('RuinsTargettingFull');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('RuinsTargetting', LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsTargetting'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsTargettingLimited'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsTargettingFull'), Enabled, False);
  Text := GetNewGameCustomRule('RuinsUseShop');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('RuinsUseShop', LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsUseShop'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsUseShopNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.RuinsUseShopYes'), Enabled, False);
  Text := GetNewGameCustomRule('SpecialShipsInGame');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('SpecialShipsInGame', LocalizedText('FormGameSet2.Extended.ParameterNames.SpecialShips'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.SpecialShipsNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.SpecialShipsYes'), Enabled, False);
  Text := GetNewGameCustomRule('AkrinMod');
  if Text = '' then Position := 30 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('AkrinMod', LocalizedText('FormGameSet2.Extended.ParameterNames.AkrinMod'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 100, Position, 1, FormatExtendedPercent);
  Text := GetNewGameCustomRule('NodeDropMod');
  if Text = '' then Position := 8 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('NodeDropMod', LocalizedText('FormGameSet2.Extended.ParameterNames.NodeDropMod'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 24, Position, 1, FormatExtendedDifficultyPercent);
  Text := GetNewGameCustomRule('EqKnowledgeUnRestricted');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('EqKnowledgeType', LocalizedText('FormGameSet2.Extended.ParameterNames.EqKnowledge'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.EqKnowledgeRestricted'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.EqKnowledgeUnRestricted'), Enabled, False);
  Text := GetNewGameCustomRule('DropValueMod');
  if Text = '' then Position := 8 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('DropValueMod', LocalizedText('FormGameSet2.Extended.ParameterNames.DropValueMod'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 24, Position, 1, FormatExtendedDifficultyPercent);
  Text := GetNewGameCustomRule('ABDropValueMod');
  if Text = '' then Position := 8 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('ABDropValueMod', LocalizedText('FormGameSet2.Extended.ParameterNames.ABDropValueMod'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 24, Position, 1, FormatExtendedDifficultyPercent);
  Text := GetNewGameCustomRule('ABHitpointsMod');
  if Text = '' then Position := 8 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('ABHitpointsMod', LocalizedText('FormGameSet2.Extended.ParameterNames.ABHitpointsMod'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 24, Position, 1, FormatExtendedDifficultyPercent);
  Text := GetNewGameCustomRule('ABDamageMod');
  if Text = '' then Position := 8 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('ABDamageMod', LocalizedText('FormGameSet2.Extended.ParameterNames.ABDamageMod'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 24, Position, 1, FormatExtendedDifficultyPercent);
  Text := GetNewGameCustomRule('ABattleRoyale');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('ABattleRoyale', LocalizedText('FormGameSet2.Extended.ParameterNames.ABattleRoyale'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.ABattleRoyaleNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.ABattleRoyaleYes'), Enabled, False);
  Text := GetNewGameCustomRule('ABChangeEq');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('ABChangeEq', LocalizedText('FormGameSet2.Extended.ParameterNames.ABChangeEq'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.ABChangeEqNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.ABChangeEqYes'), Enabled, False);
  Text := GetNewGameCustomRule('AITolerateJunk');
  if Text = '' then Position := 7 else Position := StrToInt(Text);
  ValueLabel := AddExtendedOptionLabel('AITolerateJunk', LocalizedText('FormGameSet2.Extended.ParameterNames.AITolerateJunk'), False);
  AddExtendedOptionSlider(ValueLabel, 0, 50, Position, 1, FormatExtendedInteger);
  Text := GetNewGameCustomRule('OldHyper');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('OldHyper', LocalizedText('FormGameSet2.Extended.ParameterNames.OldHyper'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.OldHyperNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.OldHyperYes'), Enabled, False);
  Text := GetNewGameCustomRule('PirateNodes');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('PirateNodes', LocalizedText('FormGameSet2.Extended.ParameterNames.PirateNodes'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.PirateNodesNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.PirateNodesYes'), Enabled, False);
  Text := GetNewGameCustomRule('AIUseShops');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('AIUseShops', LocalizedText('FormGameSet2.Extended.ParameterNames.AIUseShops'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.AIUseShopsNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.AIUseShopsYes'), Enabled, False);
  Text := GetNewGameCustomRule('DuplicateArts');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('DuplicateArts', LocalizedText('FormGameSet2.Extended.ParameterNames.DuplicateArts'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.DuplicateArtsNo'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.DuplicateArtsYes'), Enabled, False);
  Text := GetNewGameCustomRule('OldSpeedCalc');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('SpeedCalc', LocalizedText('FormGameSet2.Extended.ParameterNames.SpeedCalc'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.SpeedCalcNonLinear'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.SpeedCalcLinear'), Enabled, False);
  Text := GetNewGameCustomRule('OldMissileBonuses');
  if Text = '' then Enabled := False else Enabled := ParseEnabledNameGI(Text);
  AddExtendedOptionLabel('MissileBonuses', LocalizedText('FormGameSet2.Extended.ParameterNames.MissileBonuses'), False);
  AddExtendedOptionChoice(1, LocalizedText('FormGameSet2.Extended.ParameterNames.MissileBonusesSplit'), not Enabled, False);
  AddExtendedOptionChoice(0, LocalizedText('FormGameSet2.Extended.ParameterNames.MissileBonusesNotSplit'), Enabled, False);
  for I := 0 to 3 do
    with ExtendedGroupPanels[I] do SetSize(Classes.Point(ClientSize.X, ExtendedGroupNextY[I]));
  Owner.VerticalScrollBar.SetSmallChange((GetByName('ButReset') as TGraphButtonGI).CaptionLabel.GetLineHeight * 2);
  Owner.VerticalScrollBar.SetLargeChange(Owner.ClientSize.Y);
  Owner.VerticalScrollBar.SetPageSize(Owner.ClientSize.Y);
  ActiveExtendedGroup := 0;
  RefreshExtendedGroup;
end;
{ @end $5C1900 }

{ @routine $5C6258 TfGameSettings2_OnClose }
procedure TfGameSettings2.OnClose;
begin
  if LevelPanelTimer <> 0 then
  begin
    CancelCallbackTimer(LevelPanelTimer);
    LevelPanelTimer := 0;
  end;
  IronWillImage.Free;
  IronWillImage := nil;
  IronWillLabel.Free;
  IronWillLabel := nil;
  with GetByName('PanelSet') as TPanelScrollBarGI do FreeOwnedChildren;
end;
{ @end $5C6258 }

{ @routine $5C62D4 TfGameSettings2_AddIronWillChoice }
procedure TfGameSettings2.AddIronWillChoice(Value, X, Y: Integer; Caption, Help: WideString; Selected, Disabled: Boolean);
var Width: Integer; Owner: TObjectGI;
begin
  Owner := GetByName('PanelChar');
  IronWillImage := TImageGI.Create(Owner);
  with IronWillImage do
  begin
    Name := 'ImgRadio';
    if Disabled then SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchH')
    else if not Selected then SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN')
    else SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchD');
    SetPosition(Classes.Point(X, Y));
    SetSize(GetContentSize);
    SetImageKindY(image_y_center);
    HelpText := Help;
    if not Disabled then
    begin
      LeftButtonDownCallback := IronWillMouseDown;
      MouseEnterCallback := IronWillMouseEnter;
      MouseLeaveCallback := IronWillMouseLeave;
      HelpCallback := ShowControlHelp;
      UserValue := Value;
    end;
  end;
  Width := GiScalePixelsEx(300, 200);
  IronWillLabel := TLabelGI.Create(Owner);
  with IronWillLabel do
  begin
    SetFontName(RangerFontName);
    SetPositionModeW(False);
    SetPosition(Classes.Point(X + IronWillImage.GetContentSize.X + 2, Y + GiScalePixelsEx(2, 1)));
    SetSize(Classes.Point(Width, 1));
    SetTextAlignX(text_x_fit_or_justify);
    SetTextAlignY(text_y_fit_height);
    HelpText := Help;
    SetText(Caption);
    if Disabled then SetTextColor(CurrentPixelFormat.PackRgbBytes(127,127,127))
    else SetTextColor(CurrentPixelFormat.PackRgbBytes(0,200,0));
    if not Disabled then
    begin
      LeftButtonDownCallback := IronWillMouseDown;
      MouseEnterCallback := IronWillMouseEnter;
      MouseLeaveCallback := IronWillMouseLeave;
      HelpCallback := ShowControlHelp;
    end;
    UserValue := Integer(IronWillImage);
  end;
end;
{ @end $5C62D4 }

{ @routine $5C6694 TfGameSettings2_IronWillMouseDown }
procedure TfGameSettings2.IronWillMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if Sender is TLabelGI then Sender := TObjectGI(Sender.UserValue);
  IronWill := not IronWill;
  if IronWill then
  begin
    (Sender as TImageGI).ImageSourcePath := 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchD';
    IronWillLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255,0,0));
  end
  else
  begin
    (Sender as TImageGI).ImageSourcePath := 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN';
    IronWillLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,200,0));
  end;
  if (Point.X <> -1000) or (Point.Y <> -1000) then SoundManager.PlaySound('Sound.ButtonClick');
end;
{ @end $5C6694 }

{ @routine $5C6868 TfGameSettings2_IronWillMouseEnter }
procedure TfGameSettings2.IronWillMouseEnter(Sender: TObjectGI);
begin
  if not (Sender is TImageGI) then Sender := TObjectGI(Sender.UserValue);
  if (Sender as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN' then
    (Sender as TImageGI).ImageSourcePath := 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchA';
end;
{ @end $5C6868 }

{ @routine $5C699C TfGameSettings2_IronWillMouseLeave }
procedure TfGameSettings2.IronWillMouseLeave(Sender: TObjectGI);
begin
  if not (Sender is TImageGI) then Sender := TObjectGI(Sender.UserValue);
  if (Sender as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchA' then
    (Sender as TImageGI).ImageSourcePath := 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN';
end;
{ @end $5C699C }

{ @routine $5C6AD0 TfGameSettings2_GeneratePlayerName }
procedure TfGameSettings2.GeneratePlayerName;
var BlockName, Name: WideString; Index: Integer;
begin
  BlockName := OwnerToSys(RaceToOwner(PlayerRace));
  repeat
    Index := RandomIntRange(0, LanguageDataConfig.GetBlock('ShipName').GetBlock('Ranger').GetBlock(BlockName).GetParamCount - 1);
    Name := LanguageDataConfig.GetBlock('ShipName').GetBlock('Ranger').GetBlock(BlockName).GetParamValue(Index);
    (GetByName('PlayerName') as TEditGI).SetText(Name);
    (GetByName('Ok') as TGraphButtonGI).SetDisabled(not ValidatePlayerName((GetByName('PlayerName') as TEditGI).Text));
  until Length(Name) <= 13;
end;
{ @end $5C6AD0 }

{ @routine $5C6C4C TfGameSettings2_PlayerNameMouseDown }
procedure TfGameSettings2.PlayerNameMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  SetFocusedControl(GetByName('PlayerName'));
end;
{ @end $5C6C4C }

{ @routine $5C6C9C TfGameSettings2_ToggleLevelPanel }
procedure TfGameSettings2.ToggleLevelPanel(Sender: TObjectGI);
begin
  if LevelPanelTimer = 0 then LevelPanelTimer := ScheduleCallbackTimer(10,10,AnimateLevelPanel);
  GetByName('LevelOpen').SetActive(not GetByName('LevelOpen').Active);
  GetByName('LevelClose').SetActive(not GetByName('LevelOpen').Active);
  RefreshStartingSkills;
  RefreshStartingItems;
  BreakUiMessage;
end;
{ @end $5C6C9C }

{ @routine $5C6D5C TfGameSettings2_AnimateLevelPanel }
procedure TfGameSettings2.AnimateLevelPanel(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Level, I: Integer;
begin
  if (GetByName('LevelOpen') as TGraphButtonGI).Active then
  begin
    Dec(LevelPanelTop, 10);
    if LevelPanelTop <= CollapsedLevelPanelTop then
    begin
      LevelPanelTop := CollapsedLevelPanelTop;
      if LevelPanelTimer <> 0 then
      begin
        CancelCallbackTimer(LevelPanelTimer);
        LevelPanelTimer := 0;
      end;
    end;
  end
  else
  begin
    Inc(LevelPanelTop, 10);
    if LevelPanelTop >= 0 then
    begin
      LevelPanelTop := 0;
      if LevelPanelTimer <> 0 then
      begin
        CancelCallbackTimer(LevelPanelTimer);
        LevelPanelTimer := 0;
      end;
    end;
  end;
  GetByName('PanelLevel').SetPosition(Classes.Point(GetByName('PanelLevel').LocalPosition.X, LevelPanelTop));
  with GetByName('LevelUser') as TGraphButtonGI do
    if not Down then
    begin
      SetDown(True);
      SetDown(False);
    end;
  RefreshDifficulty;
  for Level := 1 to 4 do
    for I := Low(DifficultyLevels) to High(DifficultyLevels) do
      with GetByName('Level' + IntToStr(Level) + '_' + IntToStr(I)) as TGraphButtonGI do
        if not Down then
        begin
          SetDown(True);
          SetDown(False);
        end;
  PostMouseMoveMessage;
end;
{ @end $5C6D5C }

{ @routine $5C6FC4 TfGameSettings2_RaceClicked }
procedure TfGameSettings2.RaceClicked(Sender: TObjectGI);
begin
  PlayerRace := TOwnerId(Sender.UserValue);
  (GetByName('RaceMaloc') as TGraphButtonGI).SetDown(PlayerRace = owner_maloc);
  (GetByName('RacePeleng') as TGraphButtonGI).SetDown(PlayerRace = owner_peleng);
  (GetByName('RacePeople') as TGraphButtonGI).SetDown(PlayerRace = owner_human);
  (GetByName('RaceFei') as TGraphButtonGI).SetDown(PlayerRace = owner_feyan);
  (GetByName('RaceGaal') as TGraphButtonGI).SetDown(PlayerRace = owner_gaal);
  CaptainPortraitIndex := 0;
  RefreshPortrait;
  if not PlayerNameEdited then GeneratePlayerName;
  SetFocusedControl(GetByName('PlayerName'));
  with GetByName('PlayerName') as TEditGI do SetCaretPosition(Length(Text));
  PlayerNameChanged(nil);
end;
{ @end $5C6FC4 }

{ @routine $5C7198 TfGameSettings2_CharacterPresetClicked }
procedure TfGameSettings2.CharacterPresetClicked(Sender: TObjectGI);
begin
  CharacterPreset := ExtractDigitsToIntW(Sender.ControlName);
  (GetByName('Char1') as TGraphButtonGI).SetDown(CharacterPreset = 1);
  (GetByName('Char2') as TGraphButtonGI).SetDown(CharacterPreset = 2);
  (GetByName('Char3') as TGraphButtonGI).SetDown(CharacterPreset = 3);
  (GetByName('Char4') as TGraphButtonGI).SetDown(CharacterPreset = 4);
  (GetByName('Char5') as TGraphButtonGI).SetDown(CharacterPreset = 5);
  PlayerNameChanged(nil);
end;
{ @end $5C7198 }

{ @routine $5C72C8 TfGameSettings2_RefreshPortrait }
procedure TfGameSettings2.RefreshPortrait;
begin
  if CaptainPortraitIndex < 0 then CaptainPortraitIndex := LastPortraitByRace[PlayerRace]
  else if CaptainPortraitIndex > LastPortraitByRace[PlayerRace] then CaptainPortraitIndex := 0;
  with GetByName('CaptainI') as TImageGI do
  begin
    if LastPortraitByRace[PlayerRace] >= 0 then
    begin
      ImageSourcePath := 'GI,Bm.Captain.' + GiResourceSuffix + OwnerInfo[RaceToOwner(PlayerRace)].InternalName + IntToStr(CaptainPortraitIndex) + 'i';
      KindX := image_x_center;
      KindY := image_y_center;
      SetActive(True);
    end
    else SetActive(False);
  end;
  with GetByName('CaptainA') as TgaiGI do
  begin
    FirstFrameOnly := not AnimCaptain;
    if LastPortraitByRace[PlayerRace] >= 0 then
    begin
      SetImagePath('Bm.Captain.' + GiResourceSuffix + OwnerInfo[RaceToOwner(PlayerRace)].InternalName + IntToStr(CaptainPortraitIndex) + 'a');
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetImageKindX(image_x_center);
      SetImageKindY(image_y_center);
      SetActive(True);
      RestartPlayback;
    end
    else SetActive(False);
  end;
end;
{ @end $5C72C8 }

{ @routine $5C7580 TfGameSettings2_PreviousPortraitClicked }
procedure TfGameSettings2.PreviousPortraitClicked(Sender: TObjectGI);
begin
  Dec(CaptainPortraitIndex);
  RefreshPortrait;
end;
{ @end $5C7580 }

{ @routine $5C758C TfGameSettings2_NextPortraitClicked }
procedure TfGameSettings2.NextPortraitClicked(Sender: TObjectGI);
begin
  Inc(CaptainPortraitIndex);
  RefreshPortrait;
end;
{ @end $5C758C }

{ @routine $5C7598 TfGameSettings2_RefreshStartingSkills }
procedure TfGameSettings2.RefreshStartingSkills;
var Skill: TPilotSkill; Number, Slot: Integer; Selected: Boolean;
begin
  with GetByName('SkillCur') do SetPosition(Classes.Point(68 + 55 * Ord(StartingSkills[SelectedSkillSlot]),109));
  Number := 1;
  for Skill := Low(TPilotSkill) to High(TPilotSkill) do
  begin
    Selected := False;
    for Slot := 0 to 1 do
      if StartingSkills[Slot] = Skill then
      begin
        Selected := True;
        Break;
      end;
    (GetByName(AnsiString('Skill') + IntToStr(Number)) as TGraphButtonGI).SetDown(Selected);
    Inc(Number);
  end;
end;
{ @end $5C7598 }

{ @routine $5C76C4 TfGameSettings2_StartingSkillClicked }
procedure TfGameSettings2.StartingSkillClicked(Sender: TObjectGI);
var Slot: Integer; Skill: TPilotSkill;
begin
  if (GetByName('LevelOpen') as TGraphButtonGI).Active then
  begin
    Skill := TPilotSkill(ExtractDigitsToIntW(Sender.ControlName) - 1);
    for Slot := 0 to 1 do
      if StartingSkills[Slot] = Skill then
      begin
        SelectedSkillSlot := Slot;
        Break;
      end;
    StartingSkills[SelectedSkillSlot] := Skill;
    RefreshStartingSkills;
  end;
end;
{ @end $5C76C4 }

{ @routine $5C773C TfGameSettings2_RefreshStartingItems }
procedure TfGameSettings2.RefreshStartingItems;
var Item, Slot: Integer; Selected: Boolean;
begin
  with GetByName('ItemCur') do
    SetPosition(Classes.Point(68 + ((StartingItemChoices[SelectedItemSlot] - 1) mod 6) * 55,210 + ((StartingItemChoices[SelectedItemSlot] - 1) div 6) * 61));
  for Item := 1 to 12 do
  begin
    Selected := False;
    for Slot := 0 to 1 do
      if StartingItemChoices[Slot] = Item then
      begin
        Selected := True;
        Break;
      end;
    (GetByName(AnsiString('Item') + IntToStr(Item)) as TGraphButtonGI).SetDown(Selected);
  end;
end;
{ @end $5C773C }

{ @routine $5C7874 TfGameSettings2_StartingItemClicked }
procedure TfGameSettings2.StartingItemClicked(Sender: TObjectGI);
var Slot, Item: Integer;
begin
  if (GetByName('LevelOpen') as TGraphButtonGI).Active then
  begin
    Item := ExtractDigitsToIntW(Sender.ControlName);
    for Slot := 0 to 1 do
      if StartingItemChoices[Slot] = Item then
      begin
        SelectedItemSlot := Slot;
        Break;
      end;
    StartingItemChoices[SelectedItemSlot] := Item;
    RefreshStartingItems;
  end;
end;
{ @end $5C7874 }

{ @routine $5C78EC TfGameSettings2_RefreshDifficulty }
procedure TfGameSettings2.RefreshDifficulty;
var I, Level, Custom, Average: Integer; Color: WideString;
begin
  Custom := 0;
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do
  begin
    for Level := 1 to 4 do
      with FindControlByPath('Level' + IntToStr(Level) + '_' + IntToStr(I)) as TGraphButtonGI do
      begin
        SetActive(LevelPanelTop > CollapsedLevelPanelTop);
        SetDown(DifficultyLevels[I] = Byte(UserIndex));
      end;
    if DifficultyLevels[I] <> DifficultyLevels[1] then Custom := -1;
  end;
  if Custom = 0 then DifficultyPreset := DifficultyLevels[1];
  (GetByName('LevelUser') as TGraphButtonGI).SetDown(LongBool(Custom));
  (GetByName('Level1') as TGraphButtonGI).SetDown((DifficultyPreset = 0) and (Custom = 0));
  (GetByName('Level2') as TGraphButtonGI).SetDown((DifficultyPreset = 1) and (Custom = 0));
  (GetByName('Level3') as TGraphButtonGI).SetDown((DifficultyPreset = 2) and (Custom = 0));
  (GetByName('Level4') as TGraphButtonGI).SetDown((DifficultyPreset = 3) and (Custom = 0));
  Average := 0;
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do Average := Average + 50 + DifficultyLevels[I] * 50;
  Average := Average div Length(DifficultyLevels);
  if Average = 50 then Color := GreenColorTag
  else if Average <= 100 then Color := '<color=254,255,255>'
  else if Average <= 150 then Color := TextHighlightColorTag
  else if Average <= 200 then Color := OrangeColorTag
  else Color := '<color=255,' + IntToWideString(Round(RemapClamped(Average, 200, 500, 166, 0))) + ',0>';
  (GetByName('LevelProc') as TLabelGI).Text := WrapTextInColor(IntToStr(Average) + '%', Color);
end;
{ @end $5C78EC }

{ @routine $5C7DB8 TfGameSettings2_DifficultyComponentClicked }
procedure TfGameSettings2.DifficultyComponentClicked(Sender: TObjectGI);
var I, Component: Integer; Saved: TGalaxyDifficultyLevels; Value: Byte; Custom: Boolean;
begin
  Component := Sender.UserValue;
  Value := Sender.UserIndex;
  if (Sender.ControlName = 'Level4_' + IntToStr(Component)) and IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) and (MaximumNewGameDifficulty > Value) then
  begin
    for I := Low(DifficultyLevels) to High(DifficultyLevels) do
    begin
      Saved[I] := DifficultyLevels[I];
      DifficultyLevels[I] := (GetByName('Level4_' + IntToStr(I)) as TGraphButtonGI).UserIndex;
    end;
    Inc(DifficultyLevels[Component]);
    RefreshDifficultyHelp;
    for I := Low(DifficultyLevels) to High(DifficultyLevels) do DifficultyLevels[I] := Saved[I];
  end;
  if (Sender.ControlName = 'Level1_' + IntToStr(Component)) and IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) and (Value > 0) then
  begin
    for I := Low(DifficultyLevels) to High(DifficultyLevels) do
    begin
      Saved[I] := DifficultyLevels[I];
      DifficultyLevels[I] := (GetByName('Level4_' + IntToStr(I)) as TGraphButtonGI).UserIndex;
    end;
    Dec(DifficultyLevels[Component]);
    RefreshDifficultyHelp;
    for I := Low(DifficultyLevels) to High(DifficultyLevels) do DifficultyLevels[I] := Saved[I];
  end;
  Value := Sender.UserIndex;
  DifficultyLevels[Component] := Value;
  Custom := False;
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do
    if DifficultyLevels[I] <> Value then Custom := True;
  if not Custom then DifficultyPreset := Value;
  RefreshDifficulty;
end;
{ @end $5C7DB8 }

{ @routine $5C80A4 TfGameSettings2_DifficultyPresetClicked }
procedure TfGameSettings2.DifficultyPresetClicked(Sender: TObjectGI);
var I, First, J: Integer; CaptionLabel: TLabelGI;
begin
  DifficultyPreset := ExtractDigitsToIntW(Sender.ControlName) - 1;
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do DifficultyLevels[I] := DifficultyPreset;
  First := Max(DifficultyPreset - 3, 0);
  for I := 1 to Length(DifficultyLevels) do
  begin
    for J := 0 to 3 do
    begin
      CaptionLabel := FindControlByPath('NameGroup' + IntToWideString(I) + 'Level' + IntToWideString(J)) as TLabelGI;
      if CaptionLabel <> nil then
      begin
        case First + J of
          0:
            begin
              CaptionLabel.SetText(LocalizedColorText('FormGameSet2.Common.NameGroup' + IntToWideString(I) + 'Easy'));
              CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,255,0));
            end;
          1:
            begin
              CaptionLabel.SetText(LocalizedColorText('FormGameSet2.Common.NameGroup' + IntToWideString(I) + 'Normal'));
              CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(254,255,255));
            end;
          2:
            begin
              CaptionLabel.SetText(LocalizedColorText('FormGameSet2.Common.NameGroup' + IntToWideString(I) + 'Hard'));
              CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255,240,100));
            end;
          3:
            begin
              CaptionLabel.SetText(LocalizedColorText('FormGameSet2.Common.NameGroup' + IntToWideString(I) + 'Expert'));
              CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255,166,0));
            end;
        else
          begin
            CaptionLabel.SetText(IntToWideString((First + J + 1) * 50) + '%');
            CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255, Round(RemapClamped(First + J, 3, 9, 166, 0)), 0));
          end;
        end;
        with GetByName('Level' + IntToStr(J + 1) + '_' + IntToStr(I - 1)) as TGraphButtonGI do
        begin
          UserValue := I - 1;
          UserIndex := First + J;
          case First + J of
            0: HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Easy');
            1: HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Normal');
            2: HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Hard');
            3: HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Expert');
          else HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Expert') + '+';
          end;
        end;
      end;
    end;
  end;
  RefreshDifficulty;
end;
{ @end $5C80A4 }

{ @routine $5C86CC TfGameSettings2_CustomDifficultyClicked }
procedure TfGameSettings2.CustomDifficultyClicked(Sender: TObjectGI);
begin
  RefreshDifficulty;
  ToggleLevelPanel(Sender);
end;
{ @end $5C86CC }

{ @routine $5C86E8 TfGameSettings2_CustomDifficultyMouseUp }
procedure TfGameSettings2.CustomDifficultyMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  RefreshDifficulty;
  ToggleLevelPanel(Sender);
end;
{ @end $5C86E8 }

{ @routine $5C8718 TfGameSettings2_StartNewGameGeneration }
procedure TfGameSettings2.StartNewGameGeneration;
var I: Integer;
begin
  FilmHistory.Clear;
  NewGameGenerationThread.IronWill := IronWill;
  NewGameGenerationThread.PlayerRace := PlayerRace;
  NewGameGenerationThread.CharacterPreset := CharacterPreset;
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do NewGameGenerationThread.DifficultyLevels[I] := DifficultyLevels[I];
  NewGameGenerationThread.SetPriority(ThreadPriorityBelowNormal);
  NewGameGenerationThread.CaptainPortraitIndex := CaptainPortraitIndex;
  for I := 0 to 1 do NewGameGenerationThread.StartingItemTypes[I] := ItemTypeByChoice[StartingItemChoices[I] - 1];
  for I := 0 to 1 do NewGameGenerationThread.StartingSkills[I] := StartingSkills[I];
  NewGameGenerationThread.Start;
end;
{ @end $5C8718 }

{ @routine $5C87B8 TfGameSettings2_ApplyClicked }
procedure TfGameSettings2.ApplyClicked(Sender: TObjectGI);
var I: Integer; FileName: WideString;
begin
  if (GetByName('Ok') as TGraphButtonGI).Disabled then Exit;
  if (GetByName('ButExtended') as TGraphButtonGI).Down and not GetByName('PanelExtended').Active then
  begin
    with GetByName('PanelChar') do SetActive(False);
    with GetByName('PanelLevels') do SetActive(False);
    with GetByName('PanelSkills') do SetActive(False);
    with GetByName('PanelExtended') do SetActive(True);
    Exit;
  end;
  if PlayerNameEdited then
    NewGameSettingsConfig.SetOrAddParam('Name', (GetByName('PlayerName') as TEditGI).Text)
  else if (NewGameSettingsConfig.CountParamsByPath('Name') <= 0) or
    (NewGameSettingsConfig.GetParamByPathOrMarker('Name') <> (GetByName('PlayerName') as TEditGI).Text) then
    NewGameSettingsConfig.SetOrAddParam('Name', '');
  if IronWill then NewGameSettingsConfig.SetOrAddParam('IronWill', 'True')
  else NewGameSettingsConfig.SetOrAddParam('IronWill', 'False');
  NewGameSettingsConfig.SetOrAddParam('Race', OwnerInfo[RaceToOwner(PlayerRace)].InternalName);
  NewGameSettingsConfig.SetOrAddParam('Char', IntToStr(CharacterPreset));
  NewGameSettingsConfig.SetOrAddParam('Face', IntToStr(CaptainPortraitIndex));
  NewGameSettingsConfig.SetOrAddParam('Skill1', IntToStr(Ord(StartingSkills[0])));
  NewGameSettingsConfig.SetOrAddParam('Skill2', IntToStr(Ord(StartingSkills[1])));
  NewGameSettingsConfig.SetOrAddParam('Item1', IntToStr(StartingItemChoices[0]));
  NewGameSettingsConfig.SetOrAddParam('Item2', IntToStr(StartingItemChoices[1]));
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do NewGameSettingsConfig.SetOrAddParam('Level' + IntToStr(I), IntToStr(DifficultyLevels[I]));
  FileName := GetGameUserDirectory + 'newgame.txt';
  if NewGameSettingsConfig.CountBlocks('CustomRules') = 0 then NewGameSettingsConfig.AddBlockByPath('CustomRules');
  NewGameSettingsConfig.SetOrAddParam('UseCustomRules', BoolToWideString((GetByName('ButExtended') as TGraphButtonGI).Down));
  with NewGameSettingsConfig.GetBlockByPath('CustomRules') do
  begin
    ActiveExtendedGroup := 0;
    SetOrAddParam('KlingStrength', IntToStr(GetExtendedOptionValue('KlingStrength') - 1));
    SetOrAddParam('KlingAggro', IntToStr(GetExtendedOptionValue('KlingAggro') - 1));
    SetOrAddParam('KlingSpawn', IntToStr(GetExtendedOptionValue('KlingSpawn') - 1));
    SetOrAddParam('PirateAggro', IntToStr(GetExtendedOptionValue('PirateAggro') - 1));
    SetOrAddParam('CoalAggro', IntToStr(GetExtendedOptionValue('CoalAggro')));
    SetOrAddParam('ExtraInventions', IntToStr(GetExtendedOptionValue('ExtraInventions')));
    SetOrAddParam('ExtraRangers', IntToStr(GetExtendedOptionValue('ExtraRangers')));
    SetOrAddParam('ZeroStartExp', BoolToWideString(GetExtendedOptionValue('ZeroStartExp') = 0));
    SetOrAddParam('KlingRacialWeapons', BoolToWideString(GetExtendedOptionValue('KlingRacialWeapons') = 0));
    SetOrAddParam('MaxRangeMissiles', BoolToWideString(GetExtendedOptionValue('MaxRangeMissiles') = 0));
    SetOrAddParam('HullGrowth', IntToStr(GetExtendedOptionValue('HullGrowth')));
    ActiveExtendedGroup := 1;
    SetOrAddParam('AsteroidMod', IntToStr(GetExtendedOptionValue('AsteroidMod')));
    SetOrAddParam('SunDamageMod', IntToStr(GetExtendedOptionValue('SunDamageMod')));
    SetOrAddParam('AgPlanets', IntToStr(GetExtendedOptionValue('AgPlanets')));
    SetOrAddParam('MiPlanets', IntToStr(GetExtendedOptionValue('MiPlanets')));
    SetOrAddParam('InPlanets', IntToStr(GetExtendedOptionValue('InPlanets')));
    SetOrAddParam('StartCenter', BoolToWideString(GetExtendedOptionValue('StartCenter') = 0));
    ActiveExtendedGroup := 2;
    SetOrAddParam('RndChaotic', BoolToWideString(GetExtendedOptionValue('RndType') = 0));
    SetOrAddParam('EqKnowledgeUnRestricted', BoolToWideString(GetExtendedOptionValue('EqKnowledgeType') = 0));
    SetOrAddParam('RuinsNearStars', BoolToWideString(GetExtendedOptionValue('RuinsPosition') = 0));
    SetOrAddParam('RuinsTargettingFull', BoolToWideString(GetExtendedOptionValue('RuinsTargetting') = 0));
    SetOrAddParam('RuinsUseShop', BoolToWideString(GetExtendedOptionValue('RuinsUseShop') = 0));
    SetOrAddParam('SpecialShipsInGame', BoolToWideString(GetExtendedOptionValue('SpecialShipsInGame') = 0));
    SetOrAddParam('AkrinMod', IntToStr(GetExtendedOptionValue('AkrinMod')));
    SetOrAddParam('NodeDropMod', IntToStr(GetExtendedOptionValue('NodeDropMod')));
    SetOrAddParam('DropValueMod', IntToStr(GetExtendedOptionValue('DropValueMod')));
    SetOrAddParam('ABDropValueMod', IntToStr(GetExtendedOptionValue('ABDropValueMod')));
    SetOrAddParam('ABHitpointsMod', IntToStr(GetExtendedOptionValue('ABHitpointsMod')));
    SetOrAddParam('ABDamageMod', IntToStr(GetExtendedOptionValue('ABDamageMod')));
    SetOrAddParam('ABattleRoyale', BoolToWideString(GetExtendedOptionValue('ABattleRoyale') = 0));
    SetOrAddParam('ABChangeEq', BoolToWideString(GetExtendedOptionValue('ABChangeEq') = 0));
    SetOrAddParam('AITolerateJunk', IntToStr(GetExtendedOptionValue('AITolerateJunk')));
    SetOrAddParam('OldHyper', BoolToWideString(GetExtendedOptionValue('OldHyper') = 0));
    SetOrAddParam('PirateNodes', BoolToWideString(GetExtendedOptionValue('PirateNodes') = 0));
    SetOrAddParam('AIUseShops', BoolToWideString(GetExtendedOptionValue('AIUseShops') = 0));
    SetOrAddParam('DuplicateArts', BoolToWideString(GetExtendedOptionValue('DuplicateArts') = 0));
    SetOrAddParam('OldSpeedCalc', BoolToWideString(GetExtendedOptionValue('SpeedCalc') = 0));
    SetOrAddParam('OldMissileBonuses', BoolToWideString(GetExtendedOptionValue('MissileBonuses') = 0));
  end;
  ToggleExtendedSettings(nil);
  with GetByName('PanelSet') as TPanelScrollBarGI do FreeOwnedChildren;
  ReleaseAllTextureSurfaces;
  NewGameSettingsConfig.SaveTextFile(PWideChar(FileName), True, False);
  if NewGameGenerationThread <> nil then
  begin
    NewGameGenerationThread.Free;
    NewGameGenerationThread := nil;
  end;
  NewGameGenerationThread := TThreadCreateNewGame.Create;
  NewGameGenerationThread.PlayerName := TrimWideString((GetByName('PlayerName') as TEditGI).Text);
  StartNewGameGeneration;
  RequestedScreenId := screen_introduction;
  RequestClose(1);
end;
{ @end $5C87B8 }

{ @routine $5C9D64 TfGameSettings2_CancelClicked }
procedure TfGameSettings2.CancelClicked(Sender: TObjectGI);
begin
  if GetByName('PanelExtended').Active then ToggleExtendedSettings(nil)
  else
  begin
    RequestedScreenId := screen_main_menu;
    RequestClose(1);
  end;
end;
{ @end $5C9D64 }

{ @routine $5C9DBC TfGameSettings2_MainPanelKeyDown }
procedure TfGameSettings2.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) and IsVirtualKeyDown(VK_RIGHT) then IncreaseAllDifficulties;
  if IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) and IsVirtualKeyDown(VK_LEFT) then DecreaseAllDifficulties;
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if Key = VK_RETURN then
  begin
    TGraphButtonGI(GetByName('Ok')).ExecuteOnPressCode;
    ApplyClicked(nil);
  end
  else if Key = VK_ESCAPE then
  begin
    TGraphButtonGI(GetByName('Cancel')).ExecuteOnPressCode;
    CancelClicked(nil);
  end;
end;
{ @end $5C9DBC }

{ @routine $5C9EB4 TfGameSettings2_PlayerNameChanged }
procedure TfGameSettings2.PlayerNameChanged(Sender: TObjectGI);
var Text: WideString;
begin
  if Sender <> nil then PlayerNameEdited := True;
  (GetByName('Ok') as TGraphButtonGI).SetDisabled(not ValidatePlayerName((GetByName('PlayerName') as TEditGI).Text));
  Text := LocalizedColorText('FormGameSet2.' + OwnerInfo[RaceToOwner(PlayerRace)].InternalName + '.Char' + IntToStr(CharacterPreset));
  ReplaceTextToken(Text, '<Name>', TrimWideString((GetByName('PlayerName') as TEditGI).Text), TextHighlightColorTag);
  (GetByName('Info') as TLabelGI).Text := Text;
end;
{ @end $5C9EB4 }

{ @routine $5CA0B0 TfGameSettings2_ValidatePlayerName }
function TfGameSettings2.ValidatePlayerName(ProposedName: WideString): Boolean;
var I: Integer; HelpLabel: TLabelGI;
begin
  Result := True;
  ProposedName := RemoveWideStringChars(ProposedName, '<>{}');
  with GetByName('PlayerName') as TEditGI do
    if Text <> ProposedName then
    begin
      I := CaretPosition;
      SetText(ProposedName);
      if I > 0 then SetCaretPosition(I - 1) else SetCaretPosition(0);
    end;
  ProposedName := TrimWideString(ProposedName);
  if Length(ProposedName) < 1 then Result := False;
  if Result then
    with GetByName('PlayerName') as TEditGI do
      for I := 0 to Length(ProposedName) - 1 do
        if not HasGlyph(ProposedName[I + 1]) then
        begin
          Result := False;
          Break;
        end;
  HelpLabel := GetByName('LabelHelp') as TLabelGI;
  if PlayerNameValid and not Result then
  begin
    HelpLabel.SetText(LookupLocalizedTextByKey('FormGameSet2.Common.ErrorName'));
    HelpLabel.SetActive(True);
  end;
  if Result and not PlayerNameValid then HelpLabel.SetActive(False);
  PlayerNameValid := Result;
end;
{ @end $5CA0B0 }

{ @routine $5CA2E4 TfGameSettings2_ShowControlHelp }
procedure TfGameSettings2.ShowControlHelp(Sender: TObjectGI; Show: Boolean);
var HelpLabel: TLabelGI;
begin
  if not PlayerNameValid then Exit;
  HelpLabel := GetByName('LabelHelp') as TLabelGI;
  if not ValidatePlayerName((GetByName('PlayerName') as TEditGI).Text) then
  begin
    HelpLabel.SetText(LookupLocalizedTextByKey('FormGameSet2.Common.ErrorName'));
    HelpLabel.SetActive(True);
  end
  else
  begin
    if (Sender.HelpText = '') or Sender.IsOccludedAtPoint(GetCursorPoint) then Show := False;
    HelpLabel.SetActive(Show);
    if HelpLabel.Active and (Sender = GetByName('Ok')) and not ValidatePlayerName((GetByName('PlayerName') as TEditGI).Text) then
      HelpLabel.SetText(LookupLocalizedTextByKey('FormGameSet2.Common.ErrorName'))
    else HelpLabel.SetText(Sender.HelpText);
  end;
end;
{ @end $5CA2E4 }

{ @routine $5CA4C0 TfGameSettings2_HelpMouseEnter }
procedure TfGameSettings2.HelpMouseEnter(Sender: TObjectGI);
begin
  ShowControlHelp(Sender,True);
end;
{ @end $5CA4C0 }

{ @routine $5CA4C8 TfGameSettings2_HelpMouseLeave }
procedure TfGameSettings2.HelpMouseLeave(Sender: TObjectGI);
begin
  ShowControlHelp(Sender,False);
end;
{ @end $5CA4C8 }

{ @routine $5CA4D0 TfGameSettings2_SelectMusic }
procedure TfGameSettings2.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $5CA4D0 }

{ @routine $5CA4F4 TfGameSettings2_ExtendedSettingsPressed }
procedure TfGameSettings2.ExtendedSettingsPressed(Sender: TObjectGI);
begin

end;
{ @end $5CA4F4 }

{ @routine $5CA4F8 TfGameSettings2_ToggleExtendedSettings }
procedure TfGameSettings2.ToggleExtendedSettings(Sender: TObjectGI);
begin
  with GetByName('PanelExtended') do SetActive(False);
  with GetByName('PanelChar') do SetActive(True);
  with GetByName('PanelLevels') do SetActive(True);
  with GetByName('PanelSkills') do SetActive(True);
end;
{ @end $5CA4F8 }

{ @routine $5CA5BC TfGameSettings2_ResetExtendedSettingsClicked }
procedure TfGameSettings2.ResetExtendedSettingsClicked(Sender: TObjectGI);
var OldGroup: Integer;
begin
  OldGroup := ActiveExtendedGroup;
  ActiveExtendedGroup := 0;
  SetExtendedOptionValue('KlingStrength', 0);
  SetExtendedOptionValue('KlingAggro', 0);
  SetExtendedOptionValue('KlingSpawn', 0);
  SetExtendedOptionValue('PirateAggro', 0);
  SetExtendedOptionValue('CoalAggro', 8);
  SetExtendedOptionValue('ExtraInventions', 0);
  SetExtendedOptionValue('ExtraRangers', 0);
  SetExtendedOptionValue('ZeroStartExp', 1);
  SetExtendedOptionValue('KlingRacialWeapons', 1);
  SetExtendedOptionValue('MaxRangeMissiles', 1);
  SetExtendedOptionValue('MaxGrowth', 0);
  ActiveExtendedGroup := 1;
  SetExtendedOptionValue('AsteroidMod', 8);
  SetExtendedOptionValue('SunDamageMod', 8);
  SetExtendedOptionValue('AgPlanets', 5);
  SetExtendedOptionValue('MiPlanets', 5);
  SetExtendedOptionValue('InPlanets', 5);
  SetExtendedOptionValue('StartCenter', 1);
  ActiveExtendedGroup := 2;
  SetExtendedOptionValue('RndType', 1);
  SetExtendedOptionValue('EqKnowledgeType', 1);
  SetExtendedOptionValue('RuinsPosition', 1);
  SetExtendedOptionValue('RuinsTargetting', 1);
  SetExtendedOptionValue('RuinsUseShop', 1);
  SetExtendedOptionValue('SpecialShipsInGame', 1);
  SetExtendedOptionValue('AkrinMod', 30);
  SetExtendedOptionValue('NodeDropMod', 8);
  SetExtendedOptionValue('DropValueMod', 8);
  SetExtendedOptionValue('ABDropValueMod', 8);
  SetExtendedOptionValue('ABHitpointsMod', 8);
  SetExtendedOptionValue('ABDamageMod', 8);
  SetExtendedOptionValue('ABattleRoyale', 1);
  SetExtendedOptionValue('ABChangeEq', 1);
  SetExtendedOptionValue('AITolerateJunk', 7);
  SetExtendedOptionValue('OldHyper', 1);
  SetExtendedOptionValue('PirateNodes', 1);
  SetExtendedOptionValue('AIUseShops', 1);
  SetExtendedOptionValue('DuplicateArts', 1);
  SetExtendedOptionValue('SpeedCalc', 1);
  SetExtendedOptionValue('MissileBonuses', 1);
  ActiveExtendedGroup := OldGroup;
end;
{ @end $5CA5BC }

{ @routine $5CACE4 TfGameSettings2_ExtendedGroupClicked }
procedure TfGameSettings2.ExtendedGroupClicked(Sender: TObjectGI);
var Group: Integer;
begin
  Group := ExtractDigitsToIntW(Sender.ControlName);
  (GetByName('ButGroup0') as TGraphButtonGI).SetDown(Group = 0);
  (GetByName('ButGroup1') as TGraphButtonGI).SetDown(Group = 1);
  (GetByName('ButGroup2') as TGraphButtonGI).SetDown(Group = 2);
  if ActiveExtendedGroup <> Group then
  begin
    ActiveExtendedGroup := Group;
    RefreshExtendedGroup;
  end;
end;
{ @end $5CACE4 }

{ @routine $5CADB8 TfGameSettings2_RefreshExtendedGroup }
procedure TfGameSettings2.RefreshExtendedGroup;
var I: Integer;
begin
  with GetByName('ButGroup0') as TGraphButtonGI do SetDown(ActiveExtendedGroup = 0);
  with GetByName('ButGroup1') as TGraphButtonGI do SetDown(ActiveExtendedGroup = 1);
  with GetByName('ButGroup2') as TGraphButtonGI do SetDown(ActiveExtendedGroup = 2);
  for I := 0 to 3 do
    with ExtendedGroupPanels[I] do SetActive(I = ActiveExtendedGroup);
  with GetByName('PanelSet') as TPanelScrollBarGI do
  begin
    SetScrollOffset(Classes.Point(0,0));
    UpdateScrollRanges;
    SetVerticalScrollbarEnabled(ExtendedGroupNextY[ActiveExtendedGroup] > ClientSize.Y);
  end;
end;
{ @end $5CADB8 }

{ @routine $5CAF04 TfGameSettings2_AddExtendedOptionLabel }
function TfGameSettings2.AddExtendedOptionLabel(OptionName, Caption: WideString; UnusedFlag: Boolean): TLabelGI;
begin
  CurrentExtendedOption := OptionName;
  if ExtendedGroupNextY[BuildExtendedGroup] <> 0 then
    with TImageGI.Create(ExtendedGroupPanels[BuildExtendedGroup]) do
    begin
      ImageSourcePath := 'GI,Bm.FormOptions2.2Line';
      SetPosition(Classes.Point(0, ExtendedGroupNextY[BuildExtendedGroup]));
      SetSize(Classes.Point(ExtendedGroupPanels[BuildExtendedGroup].ClientSize.X, GetContentSize.Y + 2));
      KindX := image_x_tile_left;
      ExtendedGroupNextY[BuildExtendedGroup] := ExtendedGroupNextY[BuildExtendedGroup] + ClientSize.Y;
    end;
  Result := TLabelGI.Create(ExtendedGroupPanels[BuildExtendedGroup]);
  Result.SetFontName(NormalFontName);
  Result.SetPositionModeW(False);
  Result.SetPosition(Classes.Point(0, ExtendedGroupNextY[BuildExtendedGroup]));
  Result.SetSize(Classes.Point(ExtendedGroupPanels[BuildExtendedGroup].ClientSize.X, 1));
  Result.SetTextAlignX(text_x_left);
  Result.SetTextAlignY(text_y_fit_height);
  Result.SetTextColor(CurrentPixelFormat.PackRgbBytes(205,205,205));
  Result.SetText(Caption);
  Result.HelpText := Caption;
  Result.SetTextAlignY(text_y_top);
  Result.SetSize(Classes.Point(Result.ClientSize.X, Result.ClientSize.Y + 1));
  Inc(ExtendedGroupNextY[BuildExtendedGroup], 2);
end;
{ @end $5CAF04 }

{ @routine $5CB138 TfGameSettings2_AddExtendedOptionChoice }
procedure TfGameSettings2.AddExtendedOptionChoice(Value: Integer; Caption: WideString; Selected, Disabled: Boolean);
var ChoiceImage: TImageGI; CaptionLabel: TLabelGI; Indent: Integer;
begin
  Indent := GiScalePixelsEx(50,30);
  CaptionLabel := TLabelGI.Create(ExtendedGroupPanels[BuildExtendedGroup]);
  CaptionLabel.SetFontName(NormalFontName);
  CaptionLabel.SetPositionModeW(False);
  CaptionLabel.SetPosition(Classes.Point(0, ExtendedGroupNextY[BuildExtendedGroup]));
  CaptionLabel.SetSize(Classes.Point(ExtendedGroupPanels[BuildExtendedGroup].ClientSize.X - Indent, 1));
  CaptionLabel.SetTextAlignX(text_x_right);
  CaptionLabel.SetTextAlignY(text_y_fit_height);
  if Selected then CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255,234,118))
  else CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(205,205,205));
  CaptionLabel.SetText(Caption);
  if not Disabled then
  begin
    CaptionLabel.LeftButtonDownCallback := ExtendedChoiceMouseDown;
    CaptionLabel.MouseEnterCallback := IronWillMouseEnter;
    CaptionLabel.MouseLeaveCallback := IronWillMouseLeave;
  end;
  CaptionLabel.SetTextAlignY(text_y_font_center);
  ChoiceImage := TImageGI.Create(ExtendedGroupPanels[BuildExtendedGroup]);
  if Disabled then ChoiceImage.SetImagePath('GI,Bm.FormOptions2.2SwitchH')
  else if not Selected then ChoiceImage.SetImagePath('GI,Bm.FormOptions2.2SwitchN')
  else ChoiceImage.SetImagePath('GI,Bm.FormOptions2.2SwitchD');
  ChoiceImage.SetPosition(Classes.Point(ExtendedGroupPanels[BuildExtendedGroup].ClientSize.X - ChoiceImage.GetContentSize.X - Indent, ExtendedGroupNextY[BuildExtendedGroup]));
  ChoiceImage.SetSize(ChoiceImage.GetContentSize);
  ChoiceImage.SetImageKindY(image_y_center);
  if not Disabled then
  begin
    ChoiceImage.LeftButtonDownCallback := ExtendedChoiceMouseDown;
    ChoiceImage.MouseEnterCallback := IronWillMouseEnter;
    ChoiceImage.MouseLeaveCallback := IronWillMouseLeave;
  end;
  if not Disabled then ChoiceImage.Name := CurrentExtendedOption;
  ChoiceImage.UserValue := Value;
  CaptionLabel.SetSize(Classes.Point(CaptionLabel.ClientSize.X - ChoiceImage.ClientSize.X - 10, Max(CaptionLabel.ClientSize.Y, ChoiceImage.ClientSize.Y)));
  ChoiceImage.SetPosition(Classes.Point(ChoiceImage.LocalPosition.X, ChoiceImage.LocalPosition.Y + (Max(CaptionLabel.ClientSize.Y, ChoiceImage.ClientSize.Y) - CaptionLabel.ClientSize.Y) div 2));
  ExtendedGroupNextY[BuildExtendedGroup] := ExtendedGroupNextY[BuildExtendedGroup] + CaptionLabel.ClientSize.Y + GiScalePixels(5);
  CaptionLabel.UserValue := Integer(ChoiceImage);
end;
{ @end $5CB138 }

{ @routine $5CB52C TfGameSettings2_ExtendedChoiceMouseDown }
procedure TfGameSettings2.ExtendedChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Control: TObjectGI;
begin
  if not (Sender is TImageGI) then Sender := TObjectGI(Sender.UserValue);
  Control := ExtendedGroupPanels[ActiveExtendedGroup].FirstChild;
  while Control <> nil do
  begin
    if Control.ControlName = Sender.ControlName then
    begin
      if Control = Sender then (Control as TImageGI).ImageSourcePath := 'GI,Bm.FormOptions2.2SwitchD'
      else (Control as TImageGI).ImageSourcePath := 'GI,Bm.FormOptions2.2SwitchN';
    end;
    Control := Control.NextSibling;
  end;
  if (Point.X <> -1000) or (Point.Y <> -1000) then SoundManager.PlaySound('Sound.ButtonClick');
end;
{ @end $5CB52C }

{ @routine $5CB680 TfGameSettings2_AddExtendedOptionSlider }
procedure TfGameSettings2.AddExtendedOptionSlider(ValueLabel: TLabelGI; Minimum, Maximum, Position, UnusedStep: Integer; Callback: TNewGameSliderEvent);
var Slider: TCountBarGI;
begin
  Slider := TCountBarGI.Create(ExtendedGroupPanels[BuildExtendedGroup]);
  ExtendedGroupNextY[BuildExtendedGroup] := ExtendedGroupNextY[BuildExtendedGroup];
  Slider.SetPositionModeW(False);
  Slider.SetSize(Classes.Point(199,20));
  Slider.Pos := Classes.Point(ExtendedGroupPanels[BuildExtendedGroup].ClientSize.X - Slider.ClientSize.X, ExtendedGroupNextY[BuildExtendedGroup]);
  Slider.DecreaseButton.SetKind(button_push_can_disable);
  Slider.DecreaseButton.SetImageNormalPath('GI,Bm.FormOptions2.2TrackLeftN');
  Slider.DecreaseButton.SetImageNormalActivePath('GI,Bm.FormOptions2.2TrackLeftA');
  Slider.DecreaseButton.SetImageDownPath('GI,Bm.FormOptions2.2TrackLeftD');
  Slider.DecreaseButton.SetImageDisabledPath('GI,Bm.FormOptions2.2TrackLeftH');
  Slider.DecreaseButton.EnterSound := 'Sound.ButtonEnter';
  Slider.DecreaseButton.LeaveSound := 'Sound.ButtonLeave';
  Slider.DecreaseButton.ClickSound := 'Sound.ButtonClick';
  Slider.IncreaseButton.SetKind(button_push_can_disable);
  Slider.IncreaseButton.SetImageNormalPath('GI,Bm.FormOptions2.2TrackRightN');
  Slider.IncreaseButton.SetImageNormalActivePath('GI,Bm.FormOptions2.2TrackRightA');
  Slider.IncreaseButton.SetImageDownPath('GI,Bm.FormOptions2.2TrackRightD');
  Slider.IncreaseButton.SetImageDisabledPath('GI,Bm.FormOptions2.2TrackRightH');
  Slider.IncreaseButton.EnterSound := 'Sound.ButtonEnter';
  Slider.IncreaseButton.LeaveSound := 'Sound.ButtonLeave';
  Slider.IncreaseButton.ClickSound := 'Sound.ButtonClick';
  Slider.MarkerImage.SetImagePath('GI,Bm.FormOptions2.2TrackUp');
  Slider.MarkerImage.SetSize(Slider.MarkerImage.GetContentSize);
  Slider.MarkerImage.SetOrigin(HalfPoint(Slider.MarkerImage.ClientSize));
  Slider.AfterThumbImage.SetImagePath('GI,Bm.FormOptions2.2TrackLeft');
  Slider.BeforeThumbImage.SetImagePath('GI,Bm.FormOptions2.2TrackRight');
  Slider.ThumbButton.SetImageNormalPath('GI,Bm.FormOptions2.2TrackPol');
  Slider.ThumbButton.SetImageNormalActivePath('GI,Bm.FormOptions2.2TrackPol');
  Slider.ThumbButton.SetImageDownPath('GI,Bm.FormOptions2.2TrackPol');
  Slider.PositionChangedCallback := TObjectNotifyEventGI(Callback);
  Slider.UpdateLayout;
  Slider.SetRange(Minimum, Maximum);
  Slider.SetPositionInternal(Position);
  Slider.Name := CurrentExtendedOption;
  Slider.UserIndex := Integer(ValueLabel);
  ExtendedGroupNextY[BuildExtendedGroup] := ExtendedGroupNextY[BuildExtendedGroup] + Slider.ClientSize.Y + GiScalePixels(6);
  Callback(Slider);
end;
{ @end $5CB680 }

{ @routine $5CBCD8 TfGameSettings2_GetExtendedOptionValue }
function TfGameSettings2.GetExtendedOptionValue(OptionName: WideString): Integer;
var Control: TObjectGI;
begin
  Result := 0;
  Control := ExtendedGroupPanels[ActiveExtendedGroup].FirstChild;
  while Control <> nil do
  begin
    if Control.ControlName = OptionName then
    begin
      if Control is TImageGI then
      begin
        if (Control as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.2SwitchD' then
        begin
          Result := Control.UserValue;
          Exit;
        end;
      end
      else if Control is TCountBarGI then
      begin
        Result := (Control as TCountBarGI).Position;
        Exit;
      end;
    end;
    Control := Control.NextSibling;
  end;
  RaiseWideMessage('UnitGet Type=' + OptionName);
end;
{ @end $5CBCD8 }

{ @routine $5CBE2C TfGameSettings2_SetExtendedOptionValue }
procedure TfGameSettings2.SetExtendedOptionValue(OptionName: WideString; Value: Integer);
var Control: TObjectGI;
begin
  Control := ExtendedGroupPanels[ActiveExtendedGroup].FirstChild;
  while Control <> nil do
  begin
    if Control.ControlName = OptionName then
    begin
      if (Control is TImageGI) and (Control.UserValue = Value) and Assigned(Control.LeftButtonDownCallback) then
      begin
        ExtendedChoiceMouseDown(Control, 0, Classes.Point(-1000, -1000));
        Exit;
      end;
      if Control is TCountBarGI then
      begin
        (Control as TCountBarGI).SetPosition(Value);
        Exit;
      end;
    end;
    Control := Control.NextSibling;
  end;
end;
{ @end $5CBE2C }

{ @routine $5CBF14 TfGameSettings2_FormatExtendedInteger }
procedure TfGameSettings2.FormatExtendedInteger(Sender: TCountBarGI);
begin
  if Sender.UserIndex <> 0 then
    with TLabelGI(Sender.UserIndex) do
      SetText(HelpText + TextHighlightColorTag + ' ' + IntToStr(Sender.Position) + EndColorTag);
end;
{ @end $5CBF14 }

{ @routine $5CC000 TfGameSettings2_FormatExtendedAutoPercent }
procedure TfGameSettings2.FormatExtendedAutoPercent(Sender: TCountBarGI);
var Value: Integer;
begin
  if Sender.UserIndex <> 0 then
    with TLabelGI(Sender.UserIndex) do
    begin
      Value := Sender.Position;
      if Value = 0 then
        SetText(HelpText + TextHighlightColorTag + ' ' + LocalizedText('FormGameSet2.Extended.HelpAuto') + EndColorTag)
      else if Value <= 25 then
        SetText(HelpText + TextHighlightColorTag + ' ' + IntToStr(50 + Round((Value - 1) * 6.25)) + '%' + EndColorTag)
      else
        SetText(HelpText + OrangeColorTag + ' ' + IntToStr(50 + Round((Value - 1) * 6.25)) + '%' + EndColorTag);
    end;
end;
{ @end $5CC000 }

{ @routine $5CC248 TfGameSettings2_FormatExtendedDifficultyPercent }
procedure TfGameSettings2.FormatExtendedDifficultyPercent(Sender: TCountBarGI);
var Value: Integer;
begin
  if Sender.UserIndex <> 0 then
    with TLabelGI(Sender.UserIndex) do
    begin
      Value := Sender.Position;
      SetText(HelpText + TextHighlightColorTag + ' ' + IntToStr(50 + Round(Value * 6.25)) + '%' + EndColorTag);
    end;
end;
{ @end $5CC248 }

{ @routine $5CC35C TfGameSettings2_FormatExtendedPercent }
procedure TfGameSettings2.FormatExtendedPercent(Sender: TCountBarGI);
var Value: Integer;
begin
  if Sender.UserIndex <> 0 then
    with TLabelGI(Sender.UserIndex) do
    begin
      Value := Sender.Position;
      SetText(HelpText + TextHighlightColorTag + ' ' + IntToStr(Value) + '%' + EndColorTag);
    end;
end;
{ @end $5CC35C }

{ @routine $5CC454 TfGameSettings2_ProcessMouseWheel }
procedure TfGameSettings2.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if GetByName('PanelExtended').Active then
    with GetByName('PanelSet') as TPanelScrollBarGI do
    begin
      if Delta = WHEEL_DELTA then
      begin
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.SmallChange);
        Exit;
      end;
      if Delta = -WHEEL_DELTA then
      begin
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.SmallChange);
        Exit;
      end;
    end;
end;
{ @end $5CC454 }

{ @routine $5CC508 TfGameSettings2_IncreaseAllDifficulties }
procedure TfGameSettings2.IncreaseAllDifficulties;
var I: Integer; Button: TObjectGI;
begin
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do
    if MaximumNewGameDifficulty > DifficultyLevels[I] then Inc(DifficultyLevels[I]);
  Button := FindControlByPath('KeyArrowRight');
  if (Button <> nil) and (Button is TGraphButtonGI) then TGraphButtonGI(Button).ExecuteOnPressCode;
  RefreshDifficultyHelp;
  RefreshDifficulty;
end;
{ @end $5CC508 }

{ @routine $5CC588 TfGameSettings2_DecreaseAllDifficulties }
procedure TfGameSettings2.DecreaseAllDifficulties;
var I: Integer; Button: TObjectGI;
begin
  for I := Low(DifficultyLevels) to High(DifficultyLevels) do
    if DifficultyLevels[I] > 0 then Dec(DifficultyLevels[I]);
  Button := FindControlByPath('KeyArrowLeft');
  if (Button <> nil) and (Button is TGraphButtonGI) then TGraphButtonGI(Button).ExecuteOnPressCode;
  RefreshDifficultyHelp;
  RefreshDifficulty;
end;
{ @end $5CC588 }

{ @routine $5CC600 TfGameSettings2_RefreshDifficultyHelp }
procedure TfGameSettings2.RefreshDifficultyHelp;
var I, J, First: Integer; CaptionLabel: TLabelGI;
begin
  for I := 1 to Length(DifficultyLevels) do
  begin
    First := Max(DifficultyLevels[I - 1] - 3, 0);
    for J := 0 to 3 do
    begin
      CaptionLabel := FindControlByPath('NameGroup' + IntToWideString(I) + 'Level' + IntToWideString(J)) as TLabelGI;
      if CaptionLabel <> nil then
      begin
        case First + J of
          0:
            begin
              CaptionLabel.SetText(LocalizedColorText('FormGameSet2.Common.NameGroup' + IntToWideString(I) + 'Easy'));
              CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,255,0));
            end;
          1:
            begin
              CaptionLabel.SetText(LocalizedColorText('FormGameSet2.Common.NameGroup' + IntToWideString(I) + 'Normal'));
              CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(254,255,255));
            end;
          2:
            begin
              CaptionLabel.SetText(LocalizedColorText('FormGameSet2.Common.NameGroup' + IntToWideString(I) + 'Hard'));
              CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255,240,100));
            end;
          3:
            begin
              CaptionLabel.SetText(LocalizedColorText('FormGameSet2.Common.NameGroup' + IntToWideString(I) + 'Expert'));
              CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255,166,0));
            end;
        else
          begin
            CaptionLabel.SetText(IntToWideString((First + J + 1) * 50) + '%');
            CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255, Round(RemapClamped(First + J, 3, 9, 166, 0)), 0));
          end;
        end;
        with GetByName('Level' + IntToStr(J + 1) + '_' + IntToStr(I - 1)) as TGraphButtonGI do
        begin
          UserValue := I - 1;
          UserIndex := First + J;
          case First + J of
            0: HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Easy');
            1: HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Normal');
            2: HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Hard');
            3: HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Expert');
          else HelpText := LocalizedColorText('FormGameSet2.Common.HelpGroup' + IntToWideString(I) + 'Expert') + '+';
          end;
        end;
      end;
    end;
  end;
end;
{ @end $5CC600 }

{ @routine $5CCBF0 TfGameSettings2_ExecuteUiCode }
procedure TfGameSettings2.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  ExecuteGameplayUiCode(Block,Key);
end;
{ @end $5CCBF0 }

end.
