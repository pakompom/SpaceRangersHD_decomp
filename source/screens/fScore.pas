unit fScore;
// Unit bracket (inferred): .text 0x006B7B40..0x006BFC16; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, GI_MessageLoop, Types, aGalaxyStruct, aPlayer;

type
  TScoreQuestResult = packed record // @size 0x4
    Successful: Boolean; // @offset 0x0
    QuestType: TQuestType; // @offset 0x1
    QuestNumber: Word; // @offset 0x2
  end;

  TfScoreUnit = class(TObject) // @size 0x7C
  public
    VictoryAchieved: Boolean; // @offset 0x04
    Disqualified: Boolean; // @offset 0x05
    DifficultyLevels: array[0..7] of Byte; // @offset 0x06
    DifficultyPercent: Integer; // @offset 0x10
    PlayerName: WideString; // @offset 0x14
    PortraitFaceId: Integer; // @offset 0x18
    PilotRace: Byte; // @offset 0x1C
    FinishedTurn: Integer; // @offset 0x20
    Rank: Byte; // @offset 0x24
    PirateRank: Byte; // @offset 0x25
    OtherShipKillCount: Integer; // @offset 0x28
    PirateKillCount: Integer; // @offset 0x2C
    DominatorKillCount: Integer; // @offset 0x30
    LiberatedSystemCount: Integer; // @offset 0x34
    CivilianKillCount: Integer; // @offset 0x38
    MilitaryKillCount: Integer; // @offset 0x3C
    RangerKillCount: Integer; // @offset 0x40
    ArcadeKillCount: Integer; // @offset 0x44
    AwardCount: Integer; // @offset 0x48  Defaults can have a count without individual IDs.
    AwardIds: array of Byte; // @offset 0x4C
    TotalExperience: Integer; // @offset 0x50
    SkillLevels: array[0..5] of Byte; // @offset 0x54
    GenerationSeed: Integer; // @offset 0x5C
    ScoreTags: TBufEC; // @offset 0x60  Owned buffer.
    QuestResults: array of TScoreQuestResult; // @offset 0x64
    PlanetBattles: Integer; // @offset 0x68
    PlanetBattleHistory: array of TPlanetBattleHistoryEntry; // @offset 0x6C
    BlazerEndingState: Byte; // @offset 0x70
    KellerEndingState: Byte; // @offset 0x71
    TerronEndingState: Byte; // @offset 0x72
    PirateEndingState: Byte; // @offset 0x73
    TotalScore: Integer; // @offset 0x74
    Exported: Boolean; // @offset 0x78  Session-only; not serialized.

    constructor Create; // @addr 0x6B7CB4 @ida "TfScoreUnit *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x6B7D08 @ida "void __usercall $name(TfScoreUnit *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure CapturePlayer(Victory: Boolean); // @addr 0x6B7D44 @note "Also checks end-game achievements and submits eligible victories through the Steam score callback."
    procedure RecalculateDifficultyPercent; // @addr 0x6B8360
    procedure RecalculateTotalScore; // @addr 0x6B83B8 @note "Defeats score zero. Victories use experience, difficulty, elapsed years and ending-resolution penalties; Disqualified does not suppress the local score."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x6B8528 @note "Writes entry marker 205. PortraitFaceId and quest numbers are truncated to bytes; separate civilian/military/ranger kill counts are not saved."
    procedure LoadFromBuffer(Buffer: TBufEC; FileVersion: Integer); // @addr 0x6B88AC @note "Recalculates TotalScore. An unexpected entry marker resets the registered score screen to defaults."
    procedure ExportToFile(FileName: WideString); // @addr 0x6B8D28 @note "Writes readable statistics and a protected payload; overwrites the destination."
  end;

  TfScore = class(TMessageLoopGI) // @size 0xD8
  public
    Entries: TList; // @offset 0xD0  Owned TfScoreUnit objects; table capacity is 11.
    SelectedIndex: Integer; // @offset 0xD4

    constructor Create; // @addr 0x6BB20C @ida "TfScore *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x6BB264 @ida "void __usercall $name(TfScore *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitializeLayout; override; // @addr 0x6BB2AC @slot 0x30
    procedure OnOpen; override; // @addr 0x6BB528 @slot 0x1C @note "Releases the active galaxy and memory save snapshot."
    procedure OnClose; override; // @addr 0x6BC344 @slot 0x20
    procedure SelectMusic; override; // @addr 0x6BFBFC @slot 0x28
    procedure SortAndTrimEntries; // @addr 0x6B96F4 @note "Keeps 11 entries. Equal-score comparison only favors an earlier finish when candidate difficulty is at least the incumbent's; this is not a lexicographic comparison."
    procedure InitializeDefaultEntry(Index: Integer; var Entry: TfScoreUnit); // @addr 0x6B97FC @note "Index must be 0..10; Entry must already be allocated."
    procedure CreateDefaultTable; // @addr 0x6BA834
    procedure RecordPlayerResult(Victory: Boolean); // @addr 0x6BA890 @note "Reloads the table. Matches an existing run by score and generation seed; otherwise replaces the last entry, sorts by score alone, and tracks its selection. Saves immediately."
    procedure RemoveSelectedEntryAndRefill; // @addr 0x6BAADC @note "Also removes every entry with an empty ScoreTags buffer; surviving entries are mixed with defaults and trimmed to 11. Does not save."
    procedure ClearEntries; // @addr 0x6BABE0
    procedure LoadTableFromDisk; // @addr 0x6BAC3C @note "Appends to Entries; the caller must clear it first. Reads file version 2 and verifies its checksum."
    procedure ReloadTable; // @addr 0x6BAEFC @note "Clears Entries, loads score.dat when present, otherwise creates defaults."
    procedure SaveTableToDisk; // @addr 0x6BAFA8 @note "Replaces the table with defaults if its count is not 11."
    procedure EntryMouseEnter(Sender: TObjectGI); // @addr 0x6BC3D0
    procedure EntryMouseLeave(Sender: TObjectGI); // @addr 0x6BC578
    procedure DeleteEntryClicked(Sender: TObjectGI); // @addr 0x6BC720
    procedure ClearTableClicked(Sender: TObjectGI); // @addr 0x6BC8AC
    procedure CloseClicked(Sender: TObjectGI); // @addr 0x6BC9DC
    procedure KeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x6BCA14
    procedure RefreshDetails; // @addr 0x6BCB48
    procedure EntryMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x6BF7B0 @ida "void __userpurge $name(TfScore *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure ExportEntryClicked(Sender: TObjectGI); // @addr 0x6BF838 @note "Exports ToServerNN.txt and also submits an eligible score through the Steam callback when available."
    procedure QuestHelpMouseEnter(Sender: TObjectGI); // @addr 0x6BFB48
    procedure QuestHelpMouseLeave(Sender: TObjectGI); // @addr 0x6BFB68
    procedure ShowControlHelp(Sender: TObjectGI; Visible: Boolean); // @addr 0x6BFB88
  end;

implementation

uses aKling, SysUtils, Windows, Math, EC_File, EC_Str, GR_Main, GlobalsV, Globals,
  aGalaxy, SimpleSteamApi, aConst, aMyFunction, aRanger, aShip, Achievements,
  GI_GraphButton, GI_Image, GI_Label, GI_Panel, GI_MessageBox, aSaveLoad, GI_GAI, ExceptionInfo;

{ @routine $6B7CB4 TfScoreUnit_Create }
constructor TfScoreUnit.Create;
begin
  inherited Create;
  ScoreTags := TBufEC.Create;
end;
{ @end $6B7CB4 }

{ @routine $6B7D08 TfScoreUnit_Destroy }
destructor TfScoreUnit.Destroy;
begin
  ScoreTags.Free;
  inherited Destroy;
end;
{ @end $6B7D08 }

{ @routine $6B7D44 TfScoreUnit_CapturePlayer }
procedure TfScoreUnit.CapturePlayer(Victory: Boolean);
type
  TScoreKillCounters = array[0..6] of Integer;
  // These views preserve the native aggregate assignment across seven named fields.
  PScoreCounterView = ^TScoreCounterView;
  TScoreCounterView = packed record
    Prefix: array[0..$27] of Byte;
    Counters: TScoreKillCounters;
  end;
  PShipCounterView = ^TShipCounterView;
  TShipCounterView = packed record
    Prefix: array[0..$4D3] of Byte;
    Counters: TScoreKillCounters;
  end;
var
  Skill: TPilotSkill;
  I: Integer;
  Quest: PPlayerOldQuest;
  Difficulty, Award: Byte;
begin
  PlayerName := GetPlayer.Name;
  PortraitFaceId := GetPlayer.PortraitFaceId;
  PilotRace := GetPlayer.PilotRace;
  for Difficulty := Low(DifficultyLevels) to High(DifficultyLevels) do DifficultyLevels[Difficulty] := Galaxy.DifficultyLevels[Difficulty];
  Disqualified := GR_Main.CCInterface.GetTamperDetected or GR_Main.CCInterface.GetFlag0A or GR_Main.CCInterface.GetEditableStateApplied or
    Galaxy.CustomRules.Enabled or (GR_Main.CCInterface.GetIntegrityError <> 0) or (Galaxy.GetCheatPoints <> 0);
  FinishedTurn := Galaxy.CurrentTurn;
  Rank := GetPlayer.Rank;
  PirateRank := GetPlayer.PirateRank;
  // Native copies the seven adjacent kill/liberation counters as one block.
  PScoreCounterView(Self).Counters := PShipCounterView(GetPlayer).Counters;
  OtherShipKillCount := OtherShipKillCount - PirateKillCount - DominatorKillCount;
  ArcadeKillCount := GetPlayer.HyperspaceKillCount + GetPlayer.BlackHoleKillCount;
  if GetPlayer.AwardIds = nil then AwardCount := 0
  else
  begin
    AwardCount := GetPlayer.AwardIds.Count;
    SetLength(AwardIds, AwardCount);
    for I := 0 to AwardCount - 1 do
    begin
      Award := Byte(GetPlayer.AwardIds[I]);
      AwardIds[I] := Award;
    end;
  end;
  TotalExperience := GetPlayer.TotalExperience;
  for Skill := Low(TPilotSkill) to High(TPilotSkill) do SkillLevels[Ord(Skill)] := GetPlayer.GetBaseSkillLevel(Skill);
  ScoreTags.Clear;
  if GR_Main.CCInterface.Buffer.DataSize > 0 then ScoreTags.AddBytes(GR_Main.CCInterface.Buffer.Data, GR_Main.CCInterface.Buffer.DataSize);
  GenerationSeed := Galaxy.GenerationSeed;
  SetLength(QuestResults, PlayerOldQuests.Count);
  for I := 0 to PlayerOldQuests.Count - 1 do
  begin
    Quest := PlayerOldQuests[I];
    QuestResults[I].Successful := Quest.Successful;
    QuestResults[I].QuestType := Quest.QuestType;
    QuestResults[I].QuestNumber := Quest.QuestNumber;
  end;
  PlanetBattles := GetPlayer.PlanetBattles;
  SetLength(PlanetBattleHistory, High(GetPlayer.PlanetBattleHistory) + 1);
  for I := 0 to High(GetPlayer.PlanetBattleHistory) do PlanetBattleHistory[I] := GetPlayer.PlanetBattleHistory[I];
  if Galaxy.BlazerSeriesResolvedTurn = 0 then BlazerEndingState := 0
  else if (Galaxy.BlazerLandingPlanetId <> 0) and (BlazerShip <> nil) then BlazerEndingState := 3
  else if Galaxy.BlazerSelfDestructTurn <> 0 then BlazerEndingState := 2
  else BlazerEndingState := 1;
  if CurrentScreenId = screenArcadeBattle then
  begin
    if Galaxy.KellerLeaveTurn <> 0 then KellerEndingState := 2
    else if KellerShip = nil then KellerEndingState := 1
    else KellerEndingState := 0;
  end
  else
  begin
    if Galaxy.KellerSeriesResolvedTurn = 0 then KellerEndingState := 0
    else if Galaxy.KellerLeaveTurn <> 0 then KellerEndingState := 2
    else if Galaxy.KellerResearchTargetStarId <> 0 then KellerEndingState := 3
    else KellerEndingState := 1;
  end;
  if Galaxy.TerronSeriesResolvedTurn = 0 then TerronEndingState := 0
  else if Galaxy.TerronToStarTurn <> 0 then TerronEndingState := 2
  else if Galaxy.TerronLandingLockTurn <> 0 then TerronEndingState := 3
  else TerronEndingState := 1;
  if Galaxy.PirateWinTurn = 0 then PirateEndingState := 0
  else PirateEndingState := Byte(Galaxy.PirateWinType);
  VictoryAchieved := Victory;
  RecalculateTotalScore;
  if VictoryAchieved and not GR_Main.CCInterface.GetTamperDetected and not GR_Main.CCInterface.GetFlag0A and not GR_Main.CCInterface.GetEditableStateApplied and
    (GR_Main.CCInterface.GetIntegrityError = 0) and (Galaxy.GetCheatPoints = 0) then
  begin
    GetPlayer.AchievementStats.CheckNoQuestVictoryAchievement;
    GetPlayer.AchievementStats.CheckChampionVictoryAchievement(TotalScore);
    GetPlayer.AchievementStats.CheckLongGameVictoryAchievement(TotalScore, FinishedTurn);
    GetPlayer.AchievementStats.CheckPacifistVictoryAchievement;
    GetPlayer.AchievementStats.CheckNoLoadVictoryAchievement;
    GetPlayer.AchievementStats.CheckFastVictoryAchievement;
    if SteamInitialized and SteamLeaderboardFound then SteamUploadScore(TotalScore);
  end;
end;
{ @end $6B7D44 }

{ @routine $6B8360 TfScoreUnit_RecalculateDifficultyPercent }
procedure TfScoreUnit.RecalculateDifficultyPercent;
var I: Byte;
begin
  DifficultyPercent := 0;
  for I := 0 to 7 do DifficultyPercent := DifficultyPercent + 50 * DifficultyLevels[I] + 50;
  DifficultyPercent := DifficultyPercent div 8;
end;
{ @end $6B8360 }

{ @routine $6B83B8 TfScoreUnit_RecalculateTotalScore }
procedure TfScoreUnit.RecalculateTotalScore;
var
  Experience, Difficulty: Extended;
  DominatorsResolved, PirateResolved, PirateDefeat: Boolean;
begin
  RecalculateDifficultyPercent;
  Experience := TotalExperience;
  Difficulty := DifficultyPercent;
  if VictoryAchieved then
  begin
    TotalScore := Round(Experience * Difficulty / 100 / Power(Max(7, (FinishedTurn - 300) / 365), 1.3));
    DominatorsResolved := (TerronEndingState <> 0) and (KellerEndingState <> 0) and (BlazerEndingState <> 0);
    PirateResolved := (PirateRank >= 7) or (PirateEndingState = 3);
    PirateDefeat := PirateEndingState = 4;
    if (DominatorsResolved = False) or (PirateDefeat <> False) then
      if PirateResolved or DominatorsResolved then TotalScore := Floor(TotalScore * 0.75)
      else TotalScore := TotalScore div 2;
  end
  else TotalScore := 0;
end;
{ @end $6B83B8 }

{ @routine $6B8528 TfScoreUnit_SaveToBuffer }
procedure TfScoreUnit.SaveToBuffer(Buffer: TBufEC);
var
  Skill: Byte;
  I: Integer;
  Difficulty: Byte;
begin
  Buffer.AddIntegerValue(205);
  Buffer.AddBoolean(VictoryAchieved);
  for Difficulty := Low(DifficultyLevels) to High(DifficultyLevels) do Buffer.AddAnsiChar(AnsiChar(DifficultyLevels[Difficulty]));
  Buffer.AddWideStringZ(PlayerName);
  Buffer.AddAnsiChar(AnsiChar(PortraitFaceId));
  Buffer.AddAnsiChar(AnsiChar(PilotRace));
  Buffer.AddIntegerValue(FinishedTurn);
  Buffer.AddAnsiChar(AnsiChar(Rank));
  Buffer.AddAnsiChar(AnsiChar(PirateRank));
  Buffer.AddIntegerValue(OtherShipKillCount);
  Buffer.AddIntegerValue(PirateKillCount);
  Buffer.AddIntegerValue(DominatorKillCount);
  Buffer.AddIntegerValue(LiberatedSystemCount);
  Buffer.AddIntegerValue(ArcadeKillCount);
  Buffer.AddIntegerValue(AwardCount);
  Buffer.AddIntegerValue(High(AwardIds) + 1);
  for I := 0 to High(AwardIds) do Buffer.AddAnsiChar(AnsiChar(AwardIds[I]));
  Buffer.AddIntegerValue(TotalExperience);
  for Skill := 0 to 5 do Buffer.AddAnsiChar(AnsiChar(SkillLevels[Skill]));
  Buffer.AddBoolean(Disqualified);
  Buffer.AddBuffer(ScoreTags);
  Buffer.AddIntegerValue(GenerationSeed);
  Buffer.AddWideChar(WideChar(High(QuestResults) + 1));
  for I := 0 to High(QuestResults) do
  begin
    Buffer.AddBoolean(QuestResults[I].Successful);
    Buffer.AddAnsiChar(AnsiChar(QuestResults[I].QuestType));
    Buffer.AddAnsiChar(AnsiChar(QuestResults[I].QuestNumber));
  end;
  Buffer.AddIntegerValue(PlanetBattles);
  Buffer.AddAnsiChar(AnsiChar(BlazerEndingState));
  Buffer.AddAnsiChar(AnsiChar(KellerEndingState));
  Buffer.AddAnsiChar(AnsiChar(TerronEndingState));
  Buffer.AddAnsiChar(AnsiChar(PirateEndingState));
  Buffer.AddWideChar(WideChar(High(PlanetBattleHistory) + 1));
  for I := 0 to High(PlanetBattleHistory) do
  begin
    Buffer.AddIntegerValue(PlanetBattleHistory[I].MapId);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics[0]);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics[1]);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics[2]);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics[3]);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics[4]);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics[5]);
    Buffer.AddAnsiChar(AnsiChar(PlanetBattleHistory[I].ResultCode));
    Buffer.AddAnsiChar(AnsiChar(PlanetBattleHistory[I].CompletionMode));
    Buffer.AddIntegerValue(PlanetBattleHistory[I].DateTurn);
  end;
end;
{ @end $6B8528 }

{ @routine $6B88AC TfScoreUnit_LoadFromBuffer }
procedure TfScoreUnit.LoadFromBuffer(Buffer: TBufEC; FileVersion: Integer);
var
  Skill: Byte;
  I, Count: Integer;
  Difficulty: Byte;
  Marker: Integer;
begin
  Marker := Buffer.GetInt32;
  if (Marker < 205) or (Marker > 205) then ScoreScreen.CreateDefaultTable
  else
  begin
    VictoryAchieved := Buffer.GetBoolean;
    for Difficulty := Low(DifficultyLevels) to High(DifficultyLevels) do DifficultyLevels[Difficulty] := Buffer.GetByte;
    PlayerName := Buffer.ReadWideString;
    PortraitFaceId := Buffer.GetByte;
    PilotRace := Buffer.GetByte;
    FinishedTurn := Buffer.GetInt32;
    Rank := Buffer.GetByte;
    PirateRank := Buffer.GetByte;
    OtherShipKillCount := Buffer.GetInt32;
    PirateKillCount := Buffer.GetInt32;
    DominatorKillCount := Buffer.GetInt32;
    LiberatedSystemCount := Buffer.GetInt32;
    ArcadeKillCount := Buffer.GetInt32;
    AwardCount := Buffer.GetInt32;
    Count := Buffer.GetInt32;
    SetLength(AwardIds, Count);
    for I := 0 to Count - 1 do AwardIds[I] := Buffer.GetByte;
    TotalExperience := Buffer.GetInt32;
    for Skill := 0 to 5 do SkillLevels[Skill] := Buffer.GetByte;
    if FileVersion < 1 then
    begin
      Disqualified := False;
      ScoreTags.Clear;
      GenerationSeed := 0;
      QuestResults := nil;
    end
    else
    begin
      Disqualified := Buffer.GetBoolean;
      Buffer.ReadLengthPrefixedBuffer(ScoreTags);
      GenerationSeed := Buffer.GetInt32;
      SetLength(QuestResults, Buffer.GetWord);
      for I := 0 to High(QuestResults) do
      begin
        QuestResults[I].Successful := Buffer.GetBoolean;
        QuestResults[I].QuestType := TQuestType(Buffer.GetByte);
        QuestResults[I].QuestNumber := Buffer.GetByte;
      end;
    end;
    PlanetBattles := Buffer.GetInt32;
    BlazerEndingState := Buffer.GetByte;
    KellerEndingState := Buffer.GetByte;
    TerronEndingState := Buffer.GetByte;
    PirateEndingState := Buffer.GetByte;
    PlanetBattleHistory := nil;
    // Native tests the entry marker here, not FileVersion.
    if Marker >= 2 then
    begin
      SetLength(PlanetBattleHistory, Buffer.GetWord);
      for I := 0 to High(PlanetBattleHistory) do
      begin
        PlanetBattleHistory[I].MapId := Buffer.GetInt32;
        PlanetBattleHistory[I].Statistics[0] := Buffer.GetInt32;
        PlanetBattleHistory[I].Statistics[1] := Buffer.GetInt32;
        PlanetBattleHistory[I].Statistics[2] := Buffer.GetInt32;
        PlanetBattleHistory[I].Statistics[3] := Buffer.GetInt32;
        PlanetBattleHistory[I].Statistics[4] := Buffer.GetInt32;
        PlanetBattleHistory[I].Statistics[5] := Buffer.GetInt32;
        PlanetBattleHistory[I].ResultCode := Buffer.GetByte;
        PlanetBattleHistory[I].CompletionMode := Buffer.GetByte;
        PlanetBattleHistory[I].DateTurn := Buffer.GetInt32;
      end;
    end;
    RecalculateTotalScore;
  end;
end;
{ @end $6B88AC }

{ @routine $6B8D28 TfScoreUnit_ExportToFile }
procedure TfScoreUnit.ExportToFile(FileName: WideString);
var
  Text: WideString;
  AnsiText: AnsiString;
  FileObject: TFileEC;
  Buffer, Encoded: TBufEC;
  Seed: Integer;
  Data: PByte;
  I: Integer;
begin
  Text := '// Score for Space Rangers 2' + #13#10;
  Text := Text + 'Name=' + PlayerName + #13#10;
  Text := Text + 'EMail=' + #13#10;
  Text := Text + 'Race=' + OwnerInfo[RaceToOwner(PilotRace)].DisplayName + #13#10;
  Text := Text + 'Score=' + WideString(IntToStr(TotalScore)) + #13#10;
  Text := Text + 'Level=' + WideString(IntToStr(DifficultyPercent)) + #13#10;
  Text := Text + 'Date=' + FormatGameTurnDate(FinishedTurn) + #13#10;
  Text := Text + 'Rank=' + LocalizedText('Rank.' + CoalitionRankNames[Rank] + '.Name') + #13#10;
  Text := Text + 'LiberationSystem=' + WideString(IntToStr(LiberatedSystemCount)) + #13#10;
  Text := Text + 'Rewards=' + WideString(IntToStr(AwardCount)) + #13#10;
  Text := Text + 'SkillAccuracy=' + WideString(IntToStr(SkillLevels[0])) + #13#10;
  Text := Text + 'SkillMobility=' + WideString(IntToStr(SkillLevels[1])) + #13#10;
  Text := Text + 'SkillTechnical=' + WideString(IntToStr(SkillLevels[2])) + #13#10;
  Text := Text + 'SkillTrader=' + WideString(IntToStr(SkillLevels[3])) + #13#10;
  Text := Text + 'SkillCharm=' + WideString(IntToStr(SkillLevels[4])) + #13#10;
  Text := Text + 'SkillLeadership=' + WideString(IntToStr(SkillLevels[5])) + #13#10 + #13#10 + #13#10;
  Text := Text + '*************** Protect database ****************' + #13#10 + #13#10;
  Buffer := TBufEC.Create;
  Encoded := TBufEC.Create;
  Seed := RandomIntRange(0, 2000000000);
  SaveToBuffer(Buffer);
  if SteamInitialized then Buffer.AddAnsiStringZ(IntToStr(SteamUserId))
  else Buffer.AddAnsiStringZ(IntToStr(0));
  Buffer.CompressZlibPayloadInPlace(False);
  Buffer.ApplyDatXorCipher(Seed);
  Encoded.AddIntegerValue(3);
  Encoded.AddDWord(Seed xor $140F3F9B);
  Encoded.AddDWord(0);
  Encoded.AddDWord(0);
  Encoded.AddBytes(Buffer.Data, Buffer.DataSize);
  Encoded.UpdateEmbeddedCrc32(0, Encoded.DataSize, 8);
  Buffer.Clear;
  Data := Encoded.Data;
  for I := 0 to Encoded.DataSize - 1 do
  begin
    Buffer.AddAnsiStringRaw(AnsiString(' ' + ByteToHexText(Data^)));
    if I and $0F = $0F then Buffer.AddAnsiStringRaw(#13#10);
    Data := PByte(PAnsiChar(Data) + 1);
  end;
  AnsiText := AnsiString(Text);
  FileObject := TFileEC.Create;
  try
    FileObject.SetFileName(FileName);
    FileObject.CreateNew;
    FileObject.WriteBuffer(PAnsiChar(AnsiText), Length(AnsiText));
    FileObject.WriteBuffer(Buffer.Data, Buffer.DataSize);
  except
  end;
  FileObject.Free;
  Buffer.Free;
  Encoded.Free;
end;
{ @end $6B8D28 }

{ @routine $6B96F4 TfScore_SortAndTrimEntries }
procedure TfScore.SortAndTrimEntries;
var
  Candidate, Current: TfScoreUnit;
  Last: TObject;
  I, Count, J: Integer;
  // @nested $6B9644 ShouldSwapScoreEntries
  function ShouldSwapScoreEntries: Boolean; // @addr 0x6B9644 @ida "bool __cdecl $name(void *ParentFrame);" @note "Nested in TfScore.SortAndTrimEntries; requires its parent frame."
  begin
    if Candidate.TotalScore < Current.TotalScore then begin Result := False; Exit; end;
    if Candidate.TotalScore > Current.TotalScore then begin Result := True; Exit; end;
    if Candidate.DifficultyPercent < Current.DifficultyPercent then begin Result := False; Exit; end;
    // Repeated '<' is present in the native comparator, including the dormant branch.
    if Candidate.DifficultyPercent < Current.DifficultyPercent then begin Result := True; Exit; end;
    if Candidate.FinishedTurn > Current.FinishedTurn then begin Result := False; Exit; end;
    if Candidate.FinishedTurn < Current.FinishedTurn then begin Result := True; Exit; end;
    Result := False;
  end;
begin
  Count := Entries.Count;
  for I := 0 to Count - 2 do
    for J := I + 1 to Count - 1 do
    begin
      Current := Entries[I];
      Candidate := Entries[J];
      if ShouldSwapScoreEntries then
      begin
        Entries[I] := Candidate;
        Entries[J] := Current;
      end;
    end;
  while Entries.Count > 11 do
  begin
    Last := Entries[Entries.Count - 1];
    Last.Free;
    Entries.Delete(Entries.Count - 1);
  end;
end;
{ @end $6B96F4 }

{ @routine $6B97FC TfScore_InitializeDefaultEntry }
procedure TfScore.InitializeDefaultEntry(Index: Integer; var Entry: TfScoreUnit);
var
  Count, I: Integer;
  Kind: TQuestType;
  QuestCounts: array[0..4] of Integer;
begin
  case Index of
    0:
      begin
        Entry.PortraitFaceId := 0;
        Entry.DifficultyLevels[0] := 3;
        Entry.DifficultyLevels[1] := 3;
        Entry.DifficultyLevels[2] := 3;
        Entry.DifficultyLevels[3] := 3;
        Entry.DifficultyLevels[4] := 3;
        Entry.DifficultyLevels[5] := 3;
        Entry.DifficultyLevels[6] := 3;
        Entry.DifficultyLevels[7] := 3;
        Entry.FinishedTurn := 5600;
        Entry.OtherShipKillCount := 34;
        Entry.PirateKillCount := 50;
        Entry.DominatorKillCount := 170;
        Entry.ArcadeKillCount := 27;
        Entry.LiberatedSystemCount := 15;
        Entry.AwardCount := 14;
        Entry.TotalExperience := 100000;
        Entry.SkillLevels[0] := 4;
        Entry.SkillLevels[1] := 5;
        Entry.SkillLevels[2] := 4;
        Entry.SkillLevels[3] := 5;
        Entry.SkillLevels[4] := 5;
        Entry.SkillLevels[5] := 5;
        QuestCounts[Ord(qtSendLetter)] := 20;
        QuestCounts[Ord(qtKillShip)] := 5;
        QuestCounts[Ord(qtPlanetQuest)] := 30;
        QuestCounts[Ord(qtDefendSystem)] := 8;
        QuestCounts[Ord(qtDefendShip)] := 12;
        Entry.PlanetBattles := 7;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 3;
        Entry.KellerEndingState := 2;
        Entry.TerronEndingState := 2;
      end;
    1:
      begin
        Entry.PortraitFaceId := 9;
        Entry.DifficultyLevels[0] := 3;
        Entry.DifficultyLevels[1] := 3;
        Entry.DifficultyLevels[2] := 2;
        Entry.DifficultyLevels[3] := 2;
        Entry.DifficultyLevels[4] := 2;
        Entry.DifficultyLevels[5] := 2;
        Entry.DifficultyLevels[6] := 2;
        Entry.DifficultyLevels[7] := 2;
        Entry.FinishedTurn := 6000;
        Entry.OtherShipKillCount := 12;
        Entry.PirateKillCount := 95;
        Entry.DominatorKillCount := 280;
        Entry.ArcadeKillCount := 22;
        Entry.LiberatedSystemCount := 13;
        Entry.AwardCount := 11;
        Entry.TotalExperience := 90000;
        Entry.SkillLevels[0] := 5;
        Entry.SkillLevels[1] := 5;
        Entry.SkillLevels[2] := 4;
        Entry.SkillLevels[3] := 5;
        Entry.SkillLevels[4] := 3;
        Entry.SkillLevels[5] := 4;
        QuestCounts[Ord(qtSendLetter)] := 18;
        QuestCounts[Ord(qtKillShip)] := 2;
        QuestCounts[Ord(qtPlanetQuest)] := 28;
        QuestCounts[Ord(qtDefendSystem)] := 8;
        QuestCounts[Ord(qtDefendShip)] := 2;
        Entry.PlanetBattles := 6;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 2;
        Entry.KellerEndingState := 2;
        Entry.TerronEndingState := 2;
      end;
    2:
      begin
        Entry.PortraitFaceId := 11;
        Entry.DifficultyLevels[0] := 2;
        Entry.DifficultyLevels[1] := 2;
        Entry.DifficultyLevels[2] := 2;
        Entry.DifficultyLevels[3] := 2;
        Entry.DifficultyLevels[4] := 2;
        Entry.DifficultyLevels[5] := 2;
        Entry.DifficultyLevels[6] := 2;
        Entry.DifficultyLevels[7] := 2;
        Entry.FinishedTurn := 6500;
        Entry.OtherShipKillCount := 50;
        Entry.PirateKillCount := 46;
        Entry.DominatorKillCount := 308;
        Entry.ArcadeKillCount := 66;
        Entry.LiberatedSystemCount := 8;
        Entry.AwardCount := 7;
        Entry.TotalExperience := 85000;
        Entry.SkillLevels[0] := 5;
        Entry.SkillLevels[1] := 5;
        Entry.SkillLevels[2] := 4;
        Entry.SkillLevels[3] := 3;
        Entry.SkillLevels[4] := 3;
        Entry.SkillLevels[5] := 5;
        QuestCounts[Ord(qtSendLetter)] := 14;
        QuestCounts[Ord(qtKillShip)] := 18;
        QuestCounts[Ord(qtPlanetQuest)] := 26;
        QuestCounts[Ord(qtDefendSystem)] := 11;
        QuestCounts[Ord(qtDefendShip)] := 14;
        Entry.PlanetBattles := 11;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 1;
        Entry.KellerEndingState := 1;
        Entry.TerronEndingState := 1;
      end;
    3:
      begin
        Entry.PortraitFaceId := 13;
        Entry.DifficultyLevels[0] := 2;
        Entry.DifficultyLevels[1] := 2;
        Entry.DifficultyLevels[2] := 2;
        Entry.DifficultyLevels[3] := 2;
        Entry.DifficultyLevels[4] := 2;
        Entry.DifficultyLevels[5] := 2;
        Entry.DifficultyLevels[6] := 1;
        Entry.DifficultyLevels[7] := 1;
        Entry.FinishedTurn := 7000;
        Entry.OtherShipKillCount := 102;
        Entry.PirateKillCount := 2;
        Entry.DominatorKillCount := 135;
        Entry.ArcadeKillCount := 16;
        Entry.LiberatedSystemCount := 6;
        Entry.AwardCount := 12;
        Entry.TotalExperience := 80000;
        Entry.SkillLevels[0] := 3;
        Entry.SkillLevels[1] := 5;
        Entry.SkillLevels[2] := 4;
        Entry.SkillLevels[3] := 5;
        Entry.SkillLevels[4] := 5;
        Entry.SkillLevels[5] := 2;
        QuestCounts[Ord(qtSendLetter)] := 8;
        QuestCounts[Ord(qtKillShip)] := 19;
        QuestCounts[Ord(qtPlanetQuest)] := 5;
        QuestCounts[Ord(qtDefendSystem)] := 1;
        QuestCounts[Ord(qtDefendShip)] := 0;
        Entry.PlanetBattles := 9;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 2;
        Entry.KellerEndingState := 1;
        Entry.TerronEndingState := 3;
      end;
    4:
      begin
        Entry.PortraitFaceId := 3;
        Entry.DifficultyLevels[0] := 2;
        Entry.DifficultyLevels[1] := 2;
        Entry.DifficultyLevels[2] := 2;
        Entry.DifficultyLevels[3] := 2;
        Entry.DifficultyLevels[4] := 1;
        Entry.DifficultyLevels[5] := 1;
        Entry.DifficultyLevels[6] := 1;
        Entry.DifficultyLevels[7] := 1;
        Entry.FinishedTurn := 7500;
        Entry.OtherShipKillCount := 28;
        Entry.PirateKillCount := 110;
        Entry.DominatorKillCount := 282;
        Entry.ArcadeKillCount := 44;
        Entry.LiberatedSystemCount := 7;
        Entry.AwardCount := 11;
        Entry.TotalExperience := 76000;
        Entry.SkillLevels[0] := 5;
        Entry.SkillLevels[1] := 4;
        Entry.SkillLevels[2] := 3;
        Entry.SkillLevels[3] := 1;
        Entry.SkillLevels[4] := 2;
        Entry.SkillLevels[5] := 5;
        QuestCounts[Ord(qtSendLetter)] := 7;
        QuestCounts[Ord(qtKillShip)] := 13;
        QuestCounts[Ord(qtPlanetQuest)] := 10;
        QuestCounts[Ord(qtDefendSystem)] := 15;
        QuestCounts[Ord(qtDefendShip)] := 4;
        Entry.PlanetBattles := 3;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 1;
        Entry.KellerEndingState := 1;
        Entry.TerronEndingState := 1;
      end;
    5:
      begin
        Entry.PortraitFaceId := 10;
        Entry.DifficultyLevels[0] := 2;
        Entry.DifficultyLevels[1] := 2;
        Entry.DifficultyLevels[2] := 1;
        Entry.DifficultyLevels[3] := 1;
        Entry.DifficultyLevels[4] := 1;
        Entry.DifficultyLevels[5] := 1;
        Entry.DifficultyLevels[6] := 1;
        Entry.DifficultyLevels[7] := 1;
        Entry.FinishedTurn := 8000;
        Entry.OtherShipKillCount := 34;
        Entry.PirateKillCount := 50;
        Entry.DominatorKillCount := 148;
        Entry.ArcadeKillCount := 30;
        Entry.LiberatedSystemCount := 11;
        Entry.AwardCount := 10;
        Entry.TotalExperience := 63000;
        Entry.SkillLevels[0] := 3;
        Entry.SkillLevels[1] := 4;
        Entry.SkillLevels[2] := 4;
        Entry.SkillLevels[3] := 2;
        Entry.SkillLevels[4] := 5;
        Entry.SkillLevels[5] := 1;
        QuestCounts[Ord(qtSendLetter)] := 17;
        QuestCounts[Ord(qtKillShip)] := 10;
        QuestCounts[Ord(qtPlanetQuest)] := 3;
        QuestCounts[Ord(qtDefendSystem)] := 9;
        QuestCounts[Ord(qtDefendShip)] := 18;
        Entry.PlanetBattles := 5;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 3;
        Entry.KellerEndingState := 2;
        Entry.TerronEndingState := 1;
      end;
    6:
      begin
        Entry.PortraitFaceId := 10;
        Entry.DifficultyLevels[0] := 1;
        Entry.DifficultyLevels[1] := 1;
        Entry.DifficultyLevels[2] := 1;
        Entry.DifficultyLevels[3] := 1;
        Entry.DifficultyLevels[4] := 1;
        Entry.DifficultyLevels[5] := 1;
        Entry.DifficultyLevels[6] := 1;
        Entry.DifficultyLevels[7] := 1;
        Entry.FinishedTurn := 8500;
        Entry.OtherShipKillCount := 40;
        Entry.PirateKillCount := 30;
        Entry.DominatorKillCount := 180;
        Entry.ArcadeKillCount := 52;
        Entry.LiberatedSystemCount := 8;
        Entry.AwardCount := 7;
        Entry.TotalExperience := 52000;
        Entry.SkillLevels[0] := 2;
        Entry.SkillLevels[1] := 5;
        Entry.SkillLevels[2] := 2;
        Entry.SkillLevels[3] := 4;
        Entry.SkillLevels[4] := 2;
        Entry.SkillLevels[5] := 3;
        QuestCounts[Ord(qtSendLetter)] := 5;
        QuestCounts[Ord(qtKillShip)] := 20;
        QuestCounts[Ord(qtPlanetQuest)] := 6;
        QuestCounts[Ord(qtDefendSystem)] := 18;
        QuestCounts[Ord(qtDefendShip)] := 4;
        Entry.PlanetBattles := 2;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 2;
        Entry.KellerEndingState := 1;
        Entry.TerronEndingState := 2;
      end;
    7:
      begin
        Entry.PortraitFaceId := 11;
        Entry.DifficultyLevels[0] := 1;
        Entry.DifficultyLevels[1] := 1;
        Entry.DifficultyLevels[2] := 1;
        Entry.DifficultyLevels[3] := 1;
        Entry.DifficultyLevels[4] := 1;
        Entry.DifficultyLevels[5] := 1;
        Entry.DifficultyLevels[6] := 0;
        Entry.DifficultyLevels[7] := 0;
        Entry.FinishedTurn := 9000;
        Entry.OtherShipKillCount := 12;
        Entry.PirateKillCount := 25;
        Entry.DominatorKillCount := 92;
        Entry.ArcadeKillCount := 1;
        Entry.LiberatedSystemCount := 6;
        Entry.AwardCount := 9;
        Entry.TotalExperience := 45000;
        Entry.SkillLevels[0] := 4;
        Entry.SkillLevels[1] := 2;
        Entry.SkillLevels[2] := 5;
        Entry.SkillLevels[3] := 1;
        Entry.SkillLevels[4] := 1;
        Entry.SkillLevels[5] := 0;
        QuestCounts[Ord(qtSendLetter)] := 10;
        QuestCounts[Ord(qtKillShip)] := 18;
        QuestCounts[Ord(qtPlanetQuest)] := 15;
        QuestCounts[Ord(qtDefendSystem)] := 10;
        QuestCounts[Ord(qtDefendShip)] := 0;
        Entry.PlanetBattles := 1;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 2;
        Entry.KellerEndingState := 1;
        Entry.TerronEndingState := 1;
      end;
    8:
      begin
        Entry.PortraitFaceId := 7;
        Entry.DifficultyLevels[0] := 1;
        Entry.DifficultyLevels[1] := 1;
        Entry.DifficultyLevels[2] := 1;
        Entry.DifficultyLevels[3] := 1;
        Entry.DifficultyLevels[4] := 0;
        Entry.DifficultyLevels[5] := 0;
        Entry.DifficultyLevels[6] := 0;
        Entry.DifficultyLevels[7] := 0;
        Entry.FinishedTurn := 9300;
        Entry.OtherShipKillCount := 40;
        Entry.PirateKillCount := 2;
        Entry.DominatorKillCount := 74;
        Entry.ArcadeKillCount := 10;
        Entry.LiberatedSystemCount := 5;
        Entry.AwardCount := 7;
        Entry.TotalExperience := 38500;
        Entry.SkillLevels[0] := 2;
        Entry.SkillLevels[1] := 3;
        Entry.SkillLevels[2] := 4;
        Entry.SkillLevels[3] := 4;
        Entry.SkillLevels[4] := 0;
        Entry.SkillLevels[5] := 2;
        QuestCounts[Ord(qtSendLetter)] := 16;
        QuestCounts[Ord(qtKillShip)] := 3;
        QuestCounts[Ord(qtPlanetQuest)] := 6;
        QuestCounts[Ord(qtDefendSystem)] := 5;
        QuestCounts[Ord(qtDefendShip)] := 8;
        Entry.PlanetBattles := 2;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 2;
        Entry.KellerEndingState := 2;
        Entry.TerronEndingState := 2;
      end;
    9:
      begin
        Entry.PortraitFaceId := 28;
        Entry.DifficultyLevels[0] := 1;
        Entry.DifficultyLevels[1] := 1;
        Entry.DifficultyLevels[2] := 0;
        Entry.DifficultyLevels[3] := 0;
        Entry.DifficultyLevels[4] := 0;
        Entry.DifficultyLevels[5] := 0;
        Entry.DifficultyLevels[6] := 0;
        Entry.DifficultyLevels[7] := 0;
        Entry.FinishedTurn := 9500;
        Entry.OtherShipKillCount := 8;
        Entry.PirateKillCount := 9;
        Entry.DominatorKillCount := 45;
        Entry.ArcadeKillCount := 2;
        Entry.LiberatedSystemCount := 3;
        Entry.AwardCount := 5;
        Entry.TotalExperience := 33000;
        Entry.SkillLevels[0] := 0;
        Entry.SkillLevels[1] := 3;
        Entry.SkillLevels[2] := 0;
        Entry.SkillLevels[3] := 3;
        Entry.SkillLevels[4] := 5;
        Entry.SkillLevels[5] := 3;
        QuestCounts[Ord(qtSendLetter)] := 5;
        QuestCounts[Ord(qtKillShip)] := 13;
        QuestCounts[Ord(qtPlanetQuest)] := 8;
        QuestCounts[Ord(qtDefendSystem)] := 0;
        QuestCounts[Ord(qtDefendShip)] := 0;
        Entry.PlanetBattles := 3;
        Entry.VictoryAchieved := True;
        Entry.BlazerEndingState := 1;
        Entry.KellerEndingState := 1;
        Entry.TerronEndingState := 3;
      end;
    10:
      begin
        Entry.PortraitFaceId := 12;
        Entry.DifficultyLevels[0] := 0;
        Entry.DifficultyLevels[1] := 0;
        Entry.DifficultyLevels[2] := 0;
        Entry.DifficultyLevels[3] := 0;
        Entry.DifficultyLevels[4] := 0;
        Entry.DifficultyLevels[5] := 0;
        Entry.DifficultyLevels[6] := 0;
        Entry.DifficultyLevels[7] := 0;
        Entry.FinishedTurn := 3000;
        Entry.OtherShipKillCount := 63;
        Entry.PirateKillCount := 7;
        Entry.DominatorKillCount := 40;
        Entry.ArcadeKillCount := 28;
        Entry.LiberatedSystemCount := 1;
        Entry.AwardCount := 1;
        Entry.TotalExperience := 12000;
        Entry.SkillLevels[0] := 2;
        Entry.SkillLevels[1] := 3;
        Entry.SkillLevels[2] := 1;
        Entry.SkillLevels[3] := 1;
        Entry.SkillLevels[4] := 2;
        Entry.SkillLevels[5] := 1;
        QuestCounts[Ord(qtSendLetter)] := 10;
        QuestCounts[Ord(qtKillShip)] := 0;
        QuestCounts[Ord(qtPlanetQuest)] := 6;
        QuestCounts[Ord(qtDefendSystem)] := 0;
        QuestCounts[Ord(qtDefendShip)] := 4;
        Entry.PlanetBattles := 0;
        Entry.VictoryAchieved := False;
        Entry.BlazerEndingState := 1;
        Entry.KellerEndingState := 0;
        Entry.TerronEndingState := 0;
      end;
  end;
  Entry.PlayerName := LookupLocalizedTextByKey(WideString('FormScore.Winners.' + IntToStr(Index) + '.Name'));
  Entry.PilotRace := OwnerToRace(OwnerFromInternalName(LookupLocalizedTextByKey(WideString('FormScore.Winners.' + IntToStr(Index) + '.Race'))));
  Entry.Rank := Round(RemapClamped(Index, 0, 10, 6, 3));
  Count := QuestCounts[Ord(qtSendLetter)] + QuestCounts[Ord(qtKillShip)] + QuestCounts[Ord(qtPlanetQuest)] + QuestCounts[Ord(qtDefendSystem)] + QuestCounts[Ord(qtDefendShip)];
  SetLength(Entry.QuestResults, Count);
  Count := 0;
  for Kind := Low(TQuestType) to High(TQuestType) do
    for I := 0 to QuestCounts[Ord(Kind)] - 1 do
    begin
      Entry.QuestResults[Count].Successful := True;
      Entry.QuestResults[Count].QuestType := Kind;
      Entry.QuestResults[Count].QuestNumber := Count;
      Inc(Count);
    end;
  Entry.RecalculateTotalScore;
end;
{ @end $6B97FC }

{ @routine $6BA834 TfScore_CreateDefaultTable }
procedure TfScore.CreateDefaultTable;
var Entry: TfScoreUnit; I: Integer;
begin
  ClearEntries;
  for I := 0 to 10 do
  begin
    Entry := TfScoreUnit.Create;
    Entries.Add(Entry);
    InitializeDefaultEntry(I, Entry);
  end;
  SortAndTrimEntries;
end;
{ @end $6BA834 }

{ @routine $6BA890 TfScore_RecordPlayerResult }
procedure TfScore.RecordPlayerResult(Victory: Boolean);
var
  I, J, Count: Integer;
  Entry, Other: TfScoreUnit;
begin
  if SteamInitialized and not SteamLeaderboardFound then SteamSetLeaderboardName('Scores');
  ReloadTable;
  Count := Entries.Count;
  if Count <> 11 then RaiseWideMessage('Score sort');
  Galaxy.AppendIntegritySnapshot;
  Entry := TfScoreUnit.Create;
  Entry.CapturePlayer(Victory);
  for I := 0 to Entries.Count - 1 do
  begin
    Other := Entries[I];
    if (Entry.TotalScore = Other.TotalScore) and (Entry.GenerationSeed = Other.GenerationSeed) then
    begin
      Other.CapturePlayer(Victory);
      SaveTableToDisk;
      SelectedIndex := I;
      Entry.Free;
      Exit;
    end;
  end;
  Entry.Free;
  TfScoreUnit(Entries[Entries.Count - 1]).CapturePlayer(Victory);
  SelectedIndex := Count - 1;
  for I := 0 to Count - 2 do
    for J := I + 1 to Count - 1 do
    begin
      Entry := Entries[I];
      Other := Entries[J];
      if Entry.TotalScore < Other.TotalScore then
      begin
        Entries[I] := Other;
        Entries[J] := Entry;
        if SelectedIndex = I then SelectedIndex := J
        else if SelectedIndex = J then SelectedIndex := I;
      end;
    end;
  SaveTableToDisk;
end;
{ @end $6BA890 }

{ @routine $6BAADC TfScore_RemoveSelectedEntryAndRefill }
procedure TfScore.RemoveSelectedEntryAndRefill;
var I: Integer; Entry: TfScoreUnit;
begin
  for I := 0 to Entries.Count - 1 do
  begin
    Entry := Entries[I];
    if (Entry.ScoreTags.DataSize <= 0) or (I = SelectedIndex) then
    begin
      Entry.Free;
      Entries[I] := nil;
    end;
  end;
  I := 0;
  while I < Entries.Count do
    if Entries[I] = nil then Entries.Delete(I) else Inc(I);
  for I := 0 to 10 do
  begin
    Entry := TfScoreUnit.Create;
    Entries.Add(Entry);
    InitializeDefaultEntry(I, Entry);
  end;
  SortAndTrimEntries;
end;
{ @end $6BAADC }

{ @routine $6BABE0 TfScore_ClearEntries }
procedure TfScore.ClearEntries;
var I: Integer; Entry: TObject;
begin
  for I := 0 to Entries.Count - 1 do
  begin
    Entry := Entries[I];
    Entry.Free;
  end;
  Entries.Clear;
end;
{ @end $6BABE0 }

{ @routine $6BAC3C TfScore_LoadTableFromDisk }
procedure TfScore.LoadTableFromDisk;
var
  Buffer: TBufEC;
  Data: PByte;
  I, Size, Seed: Integer;
  Checksum: Cardinal;
  Entry: TfScoreUnit;
  Version: Integer;
begin
  Buffer := TBufEC.Create;
  try
    try
      Buffer.LoadFromWideFilePath(PWideChar(GetGameUserDirectory + 'score.dat'));
      Buffer.ExpandZlibPayloadInPlace;
      Version := Buffer.GetInt32At(0);
      if Version <> 2 then raise EAbort.Create('Error unpacking score.dat');
      Seed := Integer(Buffer.GetByteAt(6)) or (Integer(Buffer.GetByteAt(7)) shl 8) or
        (Integer(Buffer.GetByteAt(4)) shl 16) or (Integer(Buffer.GetByteAt(5)) shl 24);
      Data := PByte(Cardinal(Buffer.Data) + 8);
      Size := Buffer.DataSize;
      for I := 8 to Size - 1 do
      begin
        Data^ := Data^ xor Byte(Seed - 1);
        Seed := 16807 * (Seed mod 127773) - 2836 * (Seed div 127773);
        if Seed <= 0 then Inc(Seed, MaxInt);
        Data := PByte(PAnsiChar(Data) + 1);
      end;
      Checksum := 0;
      Data := PByte(Cardinal(Buffer.Data) + 12);
      for I := 12 to Size - 1 do
      begin
        Inc(Checksum, Byte(Data^ xor $FF));
        Data := PByte(PAnsiChar(Data) + 1);
      end;
      if Buffer.GetUInt32At(8) <> Checksum then raise EAbort.Create('Error unpacking score.dat');
      Buffer.SetPosition(12);
      for I := 0 to 10 do
      begin
        Entry := TfScoreUnit.Create;
        Entries.Add(Entry);
        Entry.LoadFromBuffer(Buffer, Version);
      end;
    except
      CreateDefaultTable;
    end;
  finally
    Buffer.Free;
  end;
end;
{ @end $6BAC3C }

{ @routine $6BAEFC TfScore_ReloadTable }
procedure TfScore.ReloadTable;
begin
  ClearEntries;
  if not FileExists(AnsiString(GetGameUserDirectory + 'score.dat')) then CreateDefaultTable
  else
  begin
    LoadTableFromDisk;
    SortAndTrimEntries;
  end;
end;
{ @end $6BAEFC }

{ @routine $6BAFA8 TfScore_SaveTableToDisk }
procedure TfScore.SaveTableToDisk;
var
  Buffer: TBufEC;
  I, Size, Seed: Integer;
  Entry: TfScoreUnit;
  Data: PByte;
  FileObject: TFileEC;
  Checksum: Integer;
begin
  if Entries.Count <> 11 then CreateDefaultTable;
  Seed := Random(MaxInt);
  Buffer := TBufEC.Create;
  Buffer.AddIntegerValue(2);
  Buffer.AddIntegerValue(0);
  Buffer.AddIntegerValue(0);
  Buffer.SetByteAt(6, Byte(Seed));
  Buffer.SetByteAt(7, Byte(Seed shr 8));
  Buffer.SetByteAt(4, Byte(Seed shr 16));
  Buffer.SetByteAt(5, Byte(Seed shr 24));
  for I := 0 to Entries.Count - 1 do
  begin
    Entry := Entries[I];
    Entry.SaveToBuffer(Buffer);
  end;
  Size := Buffer.DataSize;
  Checksum := 0;
  Data := PByte(Cardinal(Buffer.Data) + 12);
  for I := 12 to Size - 1 do
  begin
    Inc(Checksum, Byte(Data^ xor $FF));
    Data := PByte(PAnsiChar(Data) + 1);
  end;
  Buffer.SetInt32At(8, Checksum);
  Data := PByte(Cardinal(Buffer.Data) + 8);
  for I := 8 to Size - 1 do
  begin
    Data^ := Data^ xor Byte(Seed - 1);
    Seed := 16807 * (Seed mod 127773) - 2836 * (Seed div 127773);
    if Seed <= 0 then Inc(Seed, MaxInt);
    Data := PByte(PAnsiChar(Data) + 1);
  end;
  Buffer.CompressZlibPayloadInPlace(False);
  FileObject := TFileEC.Create;
  FileObject.SetFileName(GetGameUserDirectory + 'score.dat');
  FileObject.CreateNew;
  FileObject.WriteBuffer(Buffer.Data, Buffer.DataSize);
  FileObject.Free;
  Buffer.Free;
end;
{ @end $6BAFA8 }

{ @routine $6BB20C TfScore_Create }
constructor TfScore.Create;
begin
  inherited Create;
  Entries := TList.Create;
end;
{ @end $6BB20C }

{ @routine $6BB264 TfScore_Destroy }
destructor TfScore.Destroy;
begin
  ClearEntries;
  Entries.Free;
  inherited Destroy;
end;
{ @end $6BB264 }

{ @routine $6BB2AC TfScore_InitializeLayout }
procedure TfScore.InitializeLayout;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fScore... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FirstChild.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('PanelToServer') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PanelWin') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
  end;
  AppendLogLineThreadSafe('ok');
  SetHelpCallback(ShowControlHelp);
  (GetByName('ButClear') as TGraphButtonGI).UpCallback := DeleteEntryClicked;
  (GetByName('ButExit') as TGraphButtonGI).UpCallback := CloseClicked;
  GetByName('MainPanel').KeyDownCallback := KeyDown;
  SelectedIndex := 0;
end;
{ @end $6BB2AC }

{ @routine $6BB528 TfScore_OnOpen }
procedure TfScore.OnOpen;
var
  I: Integer;
  Row, Panel, SendPanel: TPanelGI;
begin
  if SteamInitialized and not SteamLeaderboardFound then SteamSetLeaderboardName('Scores');
  if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
  MemorySnapshotBuffer := nil;
  MemorySnapshotActive := False;
  if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
  Galaxy := nil;
  GetByName('LabelHelp').SetActive(False);
  Panel := GetByName('PanelSlot') as TPanelGI;
  for I := 0 to 10 do
  begin
    Row := TPanelGI.Create(Panel);
    if GiResourceVariant = 1 then
    begin
      Row.SetPosition(Classes.Point(0, I * 40));
      Row.SetSize(Classes.Point(Panel.ClientSize.X, 40));
    end
    else
    begin
      Row.SetPosition(Classes.Point(0, I * 51));
      Row.SetSize(Classes.Point(Panel.ClientSize.X, 51));
    end;
    Row.SetName(WideString('Slot' + IntToStr(I)));
    Row.LeftButtonDownCallback := EntryMouseDown;
    Row.MouseEnterCallback := EntryMouseEnter;
    Row.MouseLeaveCallback := EntryMouseLeave;
    Row.UserValue := I;
    with TImageGI.Create(Row) do
    begin
      SetDepthByName('99');
      SetPosition(Classes.Point(0, 0));
      if GiResourceVariant = 1 then SetSize(Classes.Point(454, 40))
      else SetSize(Classes.Point(577, 51));
      SetActive(True);
      SetName(WideString('Slot' + IntToStr(I) + 'Active'));
    end;
    with TLabelGI.Create(Row) do
    begin
      if GiResourceVariant = 1 then
      begin
        SetPosition(Classes.Point(6, 4));
        SetSize(Classes.Point(45, 32));
      end
      else
      begin
        SetPosition(Classes.Point(5, 4));
        SetSize(Classes.Point(59, 43));
      end;
      SetDepthByName('98');
      SetFontName(NormalFontName);
      SetTextAlignX(taxCenter);
      SetTextAlignY(tayCenterEx);
      SetName(WideString('Slot' + IntToStr(I) + 'Nom'));
      SetText(WideString(IntToStr(I + 1)));
    end;
    with TLabelGI.Create(Row) do
    begin
      if GiResourceVariant = 1 then
      begin
        SetPosition(Classes.Point(370, 4));
        SetSize(Classes.Point(80, 28));
      end
      else
      begin
        SetPosition(Classes.Point(471, 4));
        SetSize(Classes.Point(101, 43));
      end;
      SetDepthByName('98');
      SetFontName(NormalBoldFontName);
      SetTextAlignX(taxCenter);
      SetTextAlignY(tayCenterEx);
      SetName(WideString('Slot' + IntToStr(I) + 'Score'));
    end;
    with TLabelGI.Create(Row) do
    begin
      if GiResourceVariant = 1 then
      begin
        SetPosition(Classes.Point(117, 4));
        SetSize(Classes.Point(173, 32));
      end
      else
      begin
        SetPosition(Classes.Point(148, 4));
        SetSize(Classes.Point(221, 43));
      end;
      SetDepthByName('98');
      SetFontName(NormalBoldFontName);
      SetTextAlignX(taxCenter);
      SetTextAlignY(tayCenterEx);
      SetName(WideString('Slot' + IntToStr(I) + 'Name'));
    end;
    with TLabelGI.Create(Row) do
    begin
      if GiResourceVariant = 1 then
      begin
        SetPosition(Classes.Point(291, 4));
        SetSize(Classes.Point(78, 32));
      end
      else
      begin
        SetPosition(Classes.Point(371, 4));
        SetSize(Classes.Point(99, 43));
      end;
      SetDepthByName('98');
      SetFontName(NormalFontName);
      SetTextAlignX(taxCenter);
      SetTextAlignY(tayCenterEx);
      SetName(WideString('Slot' + IntToStr(I) + 'Code'));
    end;
    SendPanel := TPanelGI.Create(GetByName('PanelToServer') as TPanelGI);
    SendPanel.SetName(WideString('Slot' + IntToStr(I) + 'ToServer'));
    SendPanel.SetPosition(Classes.Point(0, I * GiScalePixelsEx(51, 40)));
    SendPanel.SetSize(Classes.Point(GiScalePixelsEx(56, 45), GiScalePixelsEx(55, 44)));
    with TImageGI.Create(SendPanel) do
    begin
      SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'SendPanel');
      SetPosition(Classes.Point(0, 0));
      SetSize(GetContentSize);
      SetDepth(9);
    end;
    with TImageGI.Create(SendPanel) do
    begin
      SetName(WideString('Slot' + IntToStr(I) + 'ToServerLight'));
      SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'SendLight');
      SetPosition(Classes.Point(GiScalePixelsEx(20, 16), GiScalePixelsEx(4, 5)));
      SetSize(GetContentSize);
      SetDepth(8);
      SetActive(True);
    end;
    with TGraphButtonGI.Create(SendPanel) do
    begin
      UpCallback := ExportEntryClicked;
      SetPosition(Classes.Point(GiScalePixelsEx(12, 10), GiScalePixelsEx(9, 7)));
      SetDepth(7);
      SetImageNormalPath('GI,Bm.FormScore2.' + GiResourceSuffix + 'SendN');
      SetImageNormalActivePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'SendA');
      SetImageDownPath('GI,Bm.FormScore2.' + GiResourceSuffix + 'SendD');
      EnterSound := 'Sound.ButtonEnter';
      LeaveSound := 'Sound.ButtonLeave';
      ClickSound := 'Sound.ButtonClick';
      HitKind := gbhGraph;
      MouseBlocking := True;
      SetSize(GetMaxStateImageSize);
      UserValue := I;
      HelpText := LookupLocalizedTextByKey('FormScore.HelpToServer');
      HelpCallback := ShowControlHelp;
    end;
  end;
  ReloadTable;
  RefreshDetails;
end;
{ @end $6BB528 }

{ @routine $6BC344 TfScore_OnClose }
procedure TfScore.OnClose;
begin
  with GetByName('PanelSlot') as TPanelGI do FreeOwnedChildren;
  with GetByName('PanelToServer') as TPanelGI do FreeOwnedChildren;
end;
{ @end $6BC344 }

{ @routine $6BC3D0 TfScore_EntryMouseEnter }
procedure TfScore.EntryMouseEnter(Sender: TObjectGI);
begin
  if Sender.UserValue <> SelectedIndex then
  begin
    SoundManager.PlaySound('Sound.ButtonEnter');
    with GetByName(WideString('Slot' + IntToStr(Sender.UserValue) + 'Active')) as TImageGI do
      SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix +
        OwnerInfo[RaceToOwner(TfScoreUnit(Entries[Sender.UserValue]).PilotRace)].InternalName + 'A');
  end;
end;
{ @end $6BC3D0 }

{ @routine $6BC578 TfScore_EntryMouseLeave }
procedure TfScore.EntryMouseLeave(Sender: TObjectGI);
begin
  if Sender.UserValue <> SelectedIndex then
  begin
    SoundManager.PlaySound('Sound.ButtonLeave');
    with GetByName(WideString('Slot' + IntToStr(Sender.UserValue) + 'Active')) as TImageGI do
      SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix +
        OwnerInfo[RaceToOwner(TfScoreUnit(Entries[Sender.UserValue]).PilotRace)].InternalName + 'N');
  end;
end;
{ @end $6BC578 }

{ @routine $6BC720 TfScore_DeleteEntryClicked }
procedure TfScore.DeleteEntryClicked(Sender: TObjectGI);
var Text: WideString; Entry: TfScoreUnit;
begin
  Entry := Entries[SelectedIndex];
  Text := FormatText2(LanguageDataConfig.GetParamByPathOrMarker('FormScore.QueryDelete'),
    '<color=255,240,100>', '<Name>', Entry.PlayerName, '<Score>', WideString(IntToStr(Entry.TotalScore)));
  if ShowMessageBoxGI(Self, Text, mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then PostMouseMoveMessage
  else
  begin
    PostMouseMoveMessage;
    RemoveSelectedEntryAndRefill;
    SaveTableToDisk;
    RefreshDetails;
  end;
end;
{ @end $6BC720 }

{ @routine $6BC8AC TfScore_ClearTableClicked }
procedure TfScore.ClearTableClicked(Sender: TObjectGI);
begin
  if ShowMessageBoxGI(Self, LanguageDataConfig.GetParamByPathOrMarker('FormScore.QueryClear'), mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then
    PostMouseMoveMessage
  else
  begin
    PostMouseMoveMessage;
    SysUtils.DeleteFile(AnsiString(GetGameUserDirectory + 'score.dat'));
    ReloadTable;
    SaveTableToDisk;
    RefreshDetails;
  end;
end;
{ @end $6BC8AC }

{ @routine $6BC9DC TfScore_CloseClicked }
procedure TfScore.CloseClicked(Sender: TObjectGI);
begin
  ScreenLoadMode := 4;
  PostLoadScreenId := screenMainMenu;
  RequestedScreenId := screenLoad;
  RequestClose(1);
end;
{ @end $6BC9DC }

{ @routine $6BCA14 TfScore_KeyDown }
procedure TfScore.KeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if (Key = VK_ESCAPE) or (Key = VK_RETURN) then CloseClicked(nil)
  else if Key = Ord('C') then ClearTableClicked(nil)
  else if (Key = VK_HOME) or (Key = VK_PRIOR) then
  begin
    SelectedIndex := 0;
    RefreshDetails;
  end
  else if (Key = VK_END) or (Key = VK_NEXT) then
  begin
    SelectedIndex := Entries.Count - 1;
    RefreshDetails;
  end
  else if (Key = VK_UP) or (Key = VK_LEFT) then
  begin
    SelectedIndex := Max(0, SelectedIndex - 1);
    RefreshDetails;
  end
  else if (Key = VK_DOWN) or (Key = VK_RIGHT) then
  begin
    SelectedIndex := Min(Entries.Count - 1, SelectedIndex + 1);
    RefreshDetails;
  end;
end;
{ @end $6BCA14 }

{ @routine $6BCB48 TfScore_RefreshDetails }
procedure TfScore.RefreshDetails;
var
  I, X: Integer;
  Entry: TfScoreUnit;
  Selected: Boolean;
  LetterQuests, ShipKillQuests, PlanetQuests, SystemDefenseQuests, ShipDefenseQuests: Word;
  Control: TObjectGI;
  Text, Separator, ResolvedColor, UnresolvedColor: WideString;
begin
  for I := 0 to Entries.Count - 1 do
  begin
    Entry := Entries[I];
    Selected := I = SelectedIndex;
    with GetByName(WideString('Slot' + IntToStr(I) + 'Active')) as TImageGI do
      if Selected then SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix +
        OwnerInfo[RaceToOwner(Entry.PilotRace)].InternalName + 'D')
      else SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix +
        OwnerInfo[RaceToOwner(Entry.PilotRace)].InternalName + 'N');
    with GetByName(WideString('Slot' + IntToStr(I) + 'Nom')) as TLabelGI do
    begin
      if Selected then SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 222, 0))
      else SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    end;
    with GetByName(WideString('Slot' + IntToStr(I) + 'Score')) as TLabelGI do
    begin
      if Selected then SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 222, 0))
      else SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
      SetText(WideString(IntToStr(Entry.TotalScore)));
    end;
    with GetByName(WideString('Slot' + IntToStr(I) + 'Name')) as TLabelGI do
    begin
      SetText(Entry.PlayerName);
      if Selected then SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 222, 0))
      else SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    end;
    with GetByName(WideString('Slot' + IntToStr(I) + 'Code')) as TLabelGI do
    begin
      SetText(WideString(IntToStr(Entry.DifficultyPercent) + '%'));
      if Selected then SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 222, 0))
      else SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    end;
    with GetByName(WideString('Slot' + IntToStr(I) + 'ToServer')) as TPanelGI do SetActive(False);
    with GetByName(WideString('Slot' + IntToStr(I) + 'ToServerLight')) do SetActive(TfScoreUnit(Entries[I]).Exported);
  end;
  Entry := Entries[SelectedIndex];
  with GetByName('ButClear') as TGraphButtonGI do SetDisabled(Entry.ScoreTags.DataSize <= 0);
  with GetByName('CaptainI') as TImageGI do
  begin
    SetImagePath('GI,Bm.Captain.' + GiResourceSuffix +
      OwnerInfo[RaceToOwner(Entry.PilotRace)].InternalName + WideString(IntToStr(Entry.PortraitFaceId)) + 'i');
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
  end;
  with GetByName('CaptainA') as TgaiGI do
  begin
    FirstFrameOnly := not AnimCaptain;
    SetImagePath('Bm.Captain.' + GiResourceSuffix +
      OwnerInfo[RaceToOwner(Entry.PilotRace)].InternalName + WideString(IntToStr(Entry.PortraitFaceId)) + 'a');
    SequenceIndex := 0;
    UpdateAutoGeometry;
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
    RestartPlayback;
  end;
  with GetByName('IRankImage') as TImageGI do
    if Entry.Rank = 0 then SetImagePath('GI,Bm.FormShip.' + GiResourceSuffix + 'Rank0')
    else if Entry.Rank = 1 then SetImagePath('GI,Bm.FormShip.' + GiResourceSuffix + 'Rank1')
    else if Entry.Rank = 2 then SetImagePath('GI,Bm.FormShip.' + GiResourceSuffix + 'Rank2')
    else if Entry.Rank = 3 then SetImagePath('GI,Bm.FormShip.' + GiResourceSuffix + 'Rank3')
    else if Entry.Rank = 4 then SetImagePath('GI,Bm.FormShip.' + GiResourceSuffix + 'Rank4')
    else if Entry.Rank = 5 then SetImagePath('GI,Bm.FormShip.' + GiResourceSuffix + 'Rank5')
    else if Entry.Rank = 6 then SetImagePath('GI,Bm.FormShip.' + GiResourceSuffix + 'Rank6')
    else if Entry.Rank = 7 then SetImagePath('GI,Bm.FormShip.' + GiResourceSuffix + 'Rank7');
  with GetByName('Skill0') as TImageGI do
  begin
    SetActive(Entry.SkillLevels[0] > 0);
    if Active then SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'Skill' + WideString(IntToStr(Entry.SkillLevels[0] - 1)));
  end;
  with GetByName('Skill1') as TImageGI do
  begin
    SetActive(Entry.SkillLevels[1] > 0);
    if Active then SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'Skill' + WideString(IntToStr(Entry.SkillLevels[1] - 1)));
  end;
  with GetByName('Skill2') as TImageGI do
  begin
    SetActive(Entry.SkillLevels[2] > 0);
    if Active then SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'Skill' + WideString(IntToStr(Entry.SkillLevels[2] - 1)));
  end;
  with GetByName('Skill3') as TImageGI do
  begin
    SetActive(Entry.SkillLevels[3] > 0);
    if Active then SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'Skill' + WideString(IntToStr(Entry.SkillLevels[3] - 1)));
  end;
  with GetByName('Skill4') as TImageGI do
  begin
    SetActive(Entry.SkillLevels[4] > 0);
    if Active then SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'Skill' + WideString(IntToStr(Entry.SkillLevels[4] - 1)));
  end;
  with GetByName('Skill5') as TImageGI do
  begin
    SetActive(Entry.SkillLevels[5] > 0);
    if Active then SetImagePath('GI,Bm.FormScore2.' + GiResourceSuffix + 'Skill' + WideString(IntToStr(Entry.SkillLevels[5] - 1)));
  end;
  (GetByName('IDate') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.DateWin'),
    '<color=255,222,0>', '<Date>', FormatGameTurnDate(Entry.FinishedTurn)));
  (GetByName('ITurn') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.TurnWin'),
    '<color=255,222,0>', '<Date>', WideString(IntToStr(Max(0, Entry.FinishedTurn - 300)))));
  (GetByName('IRank') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.Rank'),
    '<color=255,240,100>', '<Rank>', LocalizedText('Rank.' + CoalitionRankNames[Entry.Rank] + '.Name')));
  (GetByName('IKillDominator') as TLabelGI).SetText(WideString(IntToStr(Entry.DominatorKillCount)));
  (GetByName('IKillPirate') as TLabelGI).SetText(WideString(IntToStr(Entry.PirateKillCount)));
  (GetByName('IKillNormal') as TLabelGI).SetText(WideString(IntToStr(Entry.OtherShipKillCount)));
  (GetByName('IKillHyper') as TLabelGI).SetText(WideString(IntToStr(Entry.ArcadeKillCount)));
  (GetByName('ILiberationSystem') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.LiberationSystem'),
    '<color=255,222,0>', '<LiberationSystem>', WideString(IntToStr(Entry.LiberatedSystemCount))));
  (GetByName('IRewards') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.Rewards'),
    '<color=255,240,100>', '<Rewards>', WideString(IntToStr(Entry.AwardCount))));
  LetterQuests := 0;
  ShipKillQuests := 0;
  PlanetQuests := 0;
  SystemDefenseQuests := 0;
  ShipDefenseQuests := 0;
  for I := 0 to High(Entry.QuestResults) do
    if Entry.QuestResults[I].Successful then
      if Entry.QuestResults[I].QuestType = qtSendLetter then Inc(LetterQuests)
      else if Entry.QuestResults[I].QuestType = qtKillShip then Inc(ShipKillQuests)
      else if Entry.QuestResults[I].QuestType = qtPlanetQuest then Inc(PlanetQuests)
      else if Entry.QuestResults[I].QuestType = qtDefendSystem then Inc(SystemDefenseQuests)
      else if Entry.QuestResults[I].QuestType = qtDefendShip then Inc(ShipDefenseQuests);
  (GetByName('IQuests') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.Quests'),
    '<color=255,240,100>', '<Quests>', WideString(IntToStr(LetterQuests + ShipKillQuests + PlanetQuests + SystemDefenseQuests + ShipDefenseQuests))));
  if GiResourceVariant = 2 then Separator := '+' else Separator := ':';
  with GetByName('IQuests') do
  begin
    X := LocalPosition.X + ClientSize.X + 5;
    for I := 0 to 10 do
    begin
      Control := FindControlByPath(WideString('QI' + IntToStr(I)));
      if Control = nil then
      begin
        Control := TLabelGI.Create(GetByName('PanelWin'));
        Control.SetName(WideString('QI' + IntToStr(I)));
      end;
      Control.SetPosition(Classes.Point(X, LocalPosition.Y + 2));
      Control.SetSize(Classes.Point(1, ClientSize.Y - 2));
      with Control as TLabelGI do
      begin
        if GiResourceVariant = 2 then SetFontName(SmallFontName) else SetFontName(MiniFontName);
        SetTextAlignX(taxAuto);
        SetTextAlignY(tayCenterEx);
        SetTextColor(CurrentPixelFormat.PackRgbBytes(199, 135, 0));
        if I = 0 then SetText('(')
        else if I = 1 then SetText(WideString(IntToStr(LetterQuests)))
        else if I = 2 then SetText(Separator)
        else if I = 3 then SetText(WideString(IntToStr(ShipKillQuests)))
        else if I = 4 then SetText(Separator)
        else if I = 5 then SetText(WideString(IntToStr(PlanetQuests)))
        else if I = 6 then SetText(Separator)
        else if I = 7 then SetText(WideString(IntToStr(SystemDefenseQuests)))
        else if I = 8 then SetText(Separator)
        else if I = 9 then SetText(WideString(IntToStr(ShipDefenseQuests)))
        else if I = 10 then SetText(')');
        if I in [1, 3, 5, 7, 9] then
        begin
          HelpText := FormatText1(LookupLocalizedTextByKey(WideString('FormScore.Quests' + IntToStr((I - 1) div 2 + 1))),
            '<color=255,240,100>', '<N>', GetText);
          MouseEnterCallback := QuestHelpMouseEnter;
          MouseLeaveCallback := QuestHelpMouseLeave;
        end;
        SetTextAlignX(taxCenter);
        if GiResourceVariant = 1 then SetSize(Classes.Point(ClientSize.X - 3, ClientSize.Y))
        else SetSize(Classes.Point(ClientSize.X - 4, ClientSize.Y));
        Inc(X, ClientSize.X);
      end;
    end;
  end;
  (GetByName('IPlanetBattles') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.PlanetBattles'),
    '<color=255,240,100>', '<PlanetBattles>', WideString(IntToStr(Entry.PlanetBattles))));
  (GetByName('IExp') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.Exp'),
    '<color=255,222,0>', '<Exp>', WideString(IntToStr(Entry.TotalExperience))));
  ResolvedColor := '<color=255,100,50>';
  UnresolvedColor := '<color=30,252,30>';
  case Entry.BlazerEndingState of
    0: Text := WrapTextInColor(LocalizedColorText('FormScore.BlazerLeave'), UnresolvedColor);
    1: Text := WrapTextInColor(LocalizedColorText('FormScore.BlazerDead'), ResolvedColor);
    2: Text := WrapTextInColor(LocalizedColorText('FormScore.BlazerSuicide'), ResolvedColor);
  else
    if Entry.PirateEndingState = 5 then Text := WrapTextInColor(LocalizedColorText('FormScore.BlazerChangeSideAlt'), ResolvedColor)
    else Text := WrapTextInColor(LocalizedColorText('FormScore.BlazerChangeSide'), ResolvedColor);
  end;
  (GetByName('IBlazer') as TLabelGI).SetText(FormatText1(Text, '', '<Blazer>', LookupLocalizedTextByKey('ShipType.Dominator.Blazer.0')));
  case Entry.KellerEndingState of
    0: Text := WrapTextInColor(LocalizedColorText('FormScore.KellerLeave'), UnresolvedColor);
    1: Text := WrapTextInColor(LocalizedColorText('FormScore.KellerDead'), ResolvedColor);
    2: Text := WrapTextInColor(LocalizedColorText('FormScore.KellerFly'), ResolvedColor);
  else Text := WrapTextInColor(LocalizedColorText('FormScore.KellerNewResearch'), ResolvedColor);
  end;
  (GetByName('IKeller') as TLabelGI).SetText(FormatText1(Text, '', '<Keller>', LookupLocalizedTextByKey('ShipType.Dominator.Keller.0')));
  case Entry.TerronEndingState of
    0: Text := WrapTextInColor(LocalizedColorText('FormScore.TerronLeave'), UnresolvedColor);
    1: Text := WrapTextInColor(LocalizedColorText('FormScore.TerronDead'), ResolvedColor);
    2: Text := WrapTextInColor(LocalizedColorText('FormScore.TerronStar'), ResolvedColor);
  else Text := WrapTextInColor(LocalizedColorText('FormScore.TerronBattle'), ResolvedColor);
  end;
  (GetByName('ITerron') as TLabelGI).SetText(FormatText1(Text, '', '<Terron>', LookupLocalizedTextByKey('ShipType.Dominator.Terron.0')));
  if Entry.PirateEndingState > 0 then
    Text := WrapTextInColor(LocalizedColorText(WideString('FormScore.PirateWin' + IntToStr(Entry.PirateEndingState))), ResolvedColor)
  else Text := WrapTextInColor(LocalizedColorText('FormScore.PirateWin0'), UnresolvedColor);
  with GetByName('IPirate') as TLabelGI do
  begin
    SetActive(True);
    SetText(Text);
  end;
  if Entry.VictoryAchieved then
    (GetByName('ITotal') as TLabelGI).SetText(FormatText1(LocalizedColorText('FormScore.TotalWin'),
      '<color=255,222,0>', '<Total>', WideString(IntToStr(Entry.TotalScore))))
  else (GetByName('ITotal') as TLabelGI).SetText(LocalizedColorText('FormScore.TotalLoss'));
  (GetByName('INote') as TLabelGI).SetText(LocalizedColorText('FormScore.Note'));
end;
{ @end $6BCB48 }

{ @routine $6BF7B0 TfScore_EntryMouseDown }
procedure TfScore.EntryMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if not Sender.IsOccludedAtPoint(Point) then
  begin
    SoundManager.PlaySound('Sound.ButtonClick');
    SelectedIndex := ExtractDigitsToIntW(Sender.ControlName);
    RefreshDetails;
  end;
end;
{ @end $6BF7B0 }

{ @routine $6BF838 TfScore_ExportEntryClicked }
procedure TfScore.ExportEntryClicked(Sender: TObjectGI);
var
  Entry: TfScoreUnit;
  Index: Integer;
  FileName, Text: WideString;
begin
  Index := Sender.UserValue;
  Entry := Entries[Index];
  if SteamInitialized and SteamLeaderboardFound and not Entry.Disqualified then SteamUploadScore(Entry.TotalScore);
  if Index + 1 < 10 then FileName := GetGameUserDirectory + 'ToServer0' + WideString(IntToStr(Index + 1)) + '.txt'
  else FileName := GetGameUserDirectory + 'ToServer' + WideString(IntToStr(Index + 1)) + '.txt';
  Entry.ExportToFile(FileName);
  Text := LocalizedColorText('FormScore.ToServer');
  Text := ReplaceColoredToken(Text, '<Player>', Entry.PlayerName, '<color=255,240,100>');
  Text := ReplaceColoredToken(Text, '<File>', ReplaceAllWideString(FileName, '\', ' \ '), '<color=255,240,100>');
  Text := ReplaceColoredToken(Text, '<WinGameDate>', FormatGameTurnDate(Entry.FinishedTurn), '<color=255,240,100>');
  Entry.Exported := True;
  ShowMessageBoxGI(Self, Text, mbgOK or mbgUnused04 or mbgLeftAlign);
  RefreshDetails;
end;
{ @end $6BF838 }

{ @routine $6BFB48 TfScore_QuestHelpMouseEnter }
procedure TfScore.QuestHelpMouseEnter(Sender: TObjectGI);
begin
  ShowControlHelp(Sender, True);
end;
{ @end $6BFB48 }

{ @routine $6BFB68 TfScore_QuestHelpMouseLeave }
procedure TfScore.QuestHelpMouseLeave(Sender: TObjectGI);
begin
  ShowControlHelp(Sender, False);
end;
{ @end $6BFB68 }

{ @routine $6BFB88 TfScore_ShowControlHelp }
procedure TfScore.ShowControlHelp(Sender: TObjectGI; Visible: Boolean);
begin
  with GetByName('LabelHelp') as TLabelGI do
  begin
    if Sender.HelpText = '' then Visible := False;
    SetActive(Visible);
    SetText(Sender.HelpText);
  end;
end;
{ @end $6BFB88 }

{ @routine $6BFBFC TfScore_SelectMusic }
procedure TfScore.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $6BFBFC }

end.
