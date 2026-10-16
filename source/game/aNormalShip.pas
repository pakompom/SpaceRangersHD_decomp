unit aNormalShip;

interface

uses EC_Buf, EC_BlockPar, aGalaxyStruct, aConst, aGalaxy, aPlanet, aShip;

type
  TAwardTypeMask = set of TAwardKind; // @size $01

  TSystemKillCounts = packed record // @size 0x08
    case Boolean of
      False: (
        Normal: Word; // @offset 0x00
        Dominator: Word; // @offset 0x02
        Pirate: Word; // @offset 0x04
        Custom: Word; // @offset 0x06
      );
      True: (
        ByFaction: array[TStarFaction] of Word; // @offset 0x00 Custom kills remain separate.
      );
  end;

  TNormalShip = class(TShip) // @size 0x510 @methodorder source
  public
    LastDockedPlanet: TPlanet; // @offset 0x4D0
    TotalShipKillCount: Integer; // @offset 0x4D4
    PirateKillCount: Integer; // @offset 0x4D8
    DominatorKillCount: Integer; // @offset 0x4DC
    LiberatedSystemCount: Integer; // @offset 0x4E0  Also counts qualifying captures by the pirate side.
    CivilianKillCount: Integer; // @offset 0x4E4  Excludes Pirate Clan civilians.
    MilitaryKillCount: Integer; // @offset 0x4E8
    RangerKillCount: Integer; // @offset 0x4EC  Excludes rangers omitted from the rating.
    CurrentSystemKills: TSystemKillCounts; // @offset 0x4F0
    PendingLiberationCeremonyPlanet: TPlanet; // @offset 0x4F8
    PendingLiberationContribution: Integer; // @offset 0x4FC
    Rank: TShipRank; // @offset 0x500
    RankPoints: Word; // @offset 0x502
    LastPlayerExtortionTurn: Integer; // @offset 0x504  Shared 30-turn cooldown for money, cargo and paid-truce demands.
    PirateRank: TShipRank; // @offset 0x508
    PirateRankPoints: Cardinal; // @offset 0x50C

    procedure ClearObjectReferences; override; // @addr $73DCC8 @slot $0C Clears pending liberation and last-docked planet after inherited cleanup.
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr $73DCE4 @slot $10
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $73DF14 @slot $14 Native editable import truncates PirateRankPoints to Word.
    procedure CheckKillCountAwards(Victim: TShip); // @addr $742804
    function SelectAward(Owner: TOwnerId; Kinds: TAwardTypeMask; VictimTypes: TShipTypeMask): Byte; // @addr $7429F8 @ida "unsigned __int8 __userpurge $name@<al>(TNormalShip *Self@<eax>, unsigned __int8 Owner@<dl>, unsigned __int8 Kinds@<cl>, unsigned __int16 VictimTypes@<^0>);" @note "Returns 255 when no award qualifies; retries duplicates twice."
    procedure ProcessShipKill(Victim: TShip); // @addr $73FC64 Distributes kill rewards, career/rank changes and event counters.
    function CollectLiberationRewards: WideString; // @addr $73E510 @note "Consumes the pending ceremony, grants rewards and returns the player's presentation text."
    function SelectSituationalMessage(Automatic: Boolean): WideString; // @addr $7437E0 @note "Automatic messages suppress object links and select the automatic-message category."
    procedure UpdateRelationsForNearbyCombat; // @addr $742888 Nearby rangers attacking a friend incur a penalty; attacks on an enemy can improve relations.
    procedure NextDay; override; // @addr 0x0073E134 @slot 0x18
    constructor Create; // @addr 0x0073D874
    destructor Destroy; override; // @addr 0x0073D92C
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0073D97C @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x0073DAB0 @slot 0x04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x0073DC74 @slot 0x08
    function AwardRandomMedal: WideString; // @addr $73FAC0 Selects a merit award using the current planet, station or default human owner and returns its name.
    function GetPirateRankName: WideString; // @addr $74331C
    function GetNextPirateRankName: WideString; // @addr $7434EC Does not check maximum rank.
    function CanPromotePirateRank: Boolean; // @addr $743664

    function GetAwardInfo(AwardId: Byte): TRewardInfo; // @addr 0x00742DB0
    function GetRankLongName: WideString; // @addr $742F74
    function GetRankDescription: WideString; // @addr $743008
    function GetPirateRankLongName: WideString; // @addr $7433B4
    function GetPirateRankDescription: WideString; // @addr $743454
    function GetRankName: WideString; // @addr 0x00742EE8
    function GetNextRankName: WideString; // @addr 0x00743094 @note "Does not check for maximum rank."

    function GetRankPointsToNextRank: Word; // @addr 0x00743124
    procedure AddRankPoints(Amount: Word); // @addr 0x00743164 @note "Caps the addition at the points needed for the next rank."
    function CanPromoteRank: Boolean; // @addr 0x007432FC
    function TryPromoteRank: Boolean; // @addr 0x007432CC @note "Maximum rank is 7; promotion resets RankPoints."
    function GetPirateRankPointsToNextRank: Word; // @addr 0x00743588
    procedure AddPirateRankPoints(Amount: Cardinal); // @addr 0x007435C8 @note "Caps the addition at the points needed for the next rank."
    function TryPromotePirateRank: Boolean; // @addr 0x0074361C @note "Maximum rank is 7; promotion resets PirateRankPoints."

    procedure UpdateAfterburnerState; override; // @addr $746EE4 @slot $9C Enables afterburner for multi-turn orders with a serviceable engine.
    procedure TrainSkillsAutomatically; // @addr 0x00746F3C
  end;

procedure ProcessSystemLiberationRewards(SourceShip: TNormalShip; Star: TStar); // @addr 0x00741B4C @note "Processes qualifying ships after a control change; SourceShip supplies the news-variant seed."

implementation

uses EC_Str, aGalaxyEvent, Classes, Achievements, aMyFunction, aRanger, GlobalsV, GR_Main, Math, SysUtils, aConst, aItem, aPlayer, aKling, aPirate, aTransport, aWarrior, aTranclucator, Globals;

{ @routine $73D874 TNormalShip_Create }
constructor TNormalShip.Create;
begin
  inherited Create;
  TotalShipKillCount := 0;
  PirateKillCount := 0;
  DominatorKillCount := 0;
  LiberatedSystemCount := 0;
  CurrentSystemKills.Dominator := 0;
  CurrentSystemKills.Pirate := 0;
  CurrentSystemKills.Normal := 0;
  CurrentSystemKills.Custom := 0;
  PendingLiberationCeremonyPlanet := nil;
  PendingLiberationContribution := 0;
  Rank := 0;
  RankPoints := 0;
  LastDockedPlanet := nil;
  LastPlayerExtortionTurn := 0;
  PirateRank := 0;
  PirateRankPoints := 0;
end;
{ @end $73D874 }

{ @routine $73D92C TNormalShip_Destroy }
destructor TNormalShip.Destroy;
var
  Career: TRangerCareer;
begin
  for Career := Low(TRangerCareer) to High(TRangerCareer) do
    if Galaxy.EminentCareerShips[Career] = Self then Galaxy.EminentCareerShips[Career] := nil;
  inherited Destroy;
end;
{ @end $73D92C }

{ @routine $73D97C TNormalShip_SaveToBuffer }
procedure TNormalShip.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(TotalShipKillCount);
  Buffer.AddIntegerValue(PirateKillCount);
  Buffer.AddIntegerValue(DominatorKillCount);
  Buffer.AddIntegerValue(LiberatedSystemCount);
  Buffer.AddIntegerValue(CivilianKillCount);
  Buffer.AddIntegerValue(MilitaryKillCount);
  Buffer.AddIntegerValue(RangerKillCount);
  Buffer.AddWideChar(WideChar(CurrentSystemKills.Dominator));
  Buffer.AddWideChar(WideChar(CurrentSystemKills.Pirate));
  Buffer.AddWideChar(WideChar(CurrentSystemKills.Normal));
  Buffer.AddWideChar(WideChar(CurrentSystemKills.Custom));
  if PendingLiberationCeremonyPlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(PendingLiberationCeremonyPlanet.Id);
  Buffer.AddIntegerValue(PendingLiberationContribution);
  Buffer.AddAnsiChar(AnsiChar(Rank));
  Buffer.AddWideChar(WideChar(RankPoints));
  Buffer.AddAnsiChar(AnsiChar(PirateRank));
  Buffer.AddDWord(PirateRankPoints);
  if LastDockedPlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(LastDockedPlanet.Id);
  Buffer.AddIntegerValue(LastPlayerExtortionTurn);
end;
{ @end $73D97C }

{ @routine $73DAB0 TNormalShip_LoadFromBuffer }
procedure TNormalShip.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion >= 57 then
  begin
    TotalShipKillCount := Buffer.GetInt32;
    PirateKillCount := Buffer.GetInt32;
    DominatorKillCount := Buffer.GetInt32;
    LiberatedSystemCount := Buffer.GetInt32;
    CivilianKillCount := Buffer.GetInt32;
    MilitaryKillCount := Buffer.GetInt32;
    RangerKillCount := Buffer.GetInt32;
  end
  else
  begin
    TotalShipKillCount := Buffer.GetWord;
    PirateKillCount := Buffer.GetWord;
    DominatorKillCount := Buffer.GetWord;
    LiberatedSystemCount := Buffer.GetWord;
    CivilianKillCount := Buffer.GetWord;
    MilitaryKillCount := Buffer.GetWord;
    RangerKillCount := Buffer.GetWord;
  end;
  CurrentSystemKills.Dominator := Buffer.GetWord;
  CurrentSystemKills.Pirate := Buffer.GetWord;
  CurrentSystemKills.Normal := Buffer.GetWord;
  if LoadedSaveVersion >= 153 then CurrentSystemKills.Custom := Buffer.GetWord;
  PendingLiberationCeremonyPlanet := TPlanet(Buffer.GetUInt32);
  if LoadedSaveVersion >= 80 then PendingLiberationContribution := Buffer.GetInt32
  else PendingLiberationContribution := 0;
  Rank := Buffer.GetByte;
  RankPoints := Buffer.GetWord;
  PirateRank := Buffer.GetByte;
  PirateRankPoints := Buffer.GetUInt32;
  if (LoadedSaveVersion < 126) and (Buffer.GetByte <> 0) then OwnerId := owner_pirate;
  LastDockedPlanet := TPlanet(Buffer.GetUInt32);
  LastPlayerExtortionTurn := Buffer.GetInt32;
end;
{ @end $73DAB0 }

{ @routine $73DC74 TNormalShip_ResolveLoadedReferences }
procedure TNormalShip.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  PendingLiberationCeremonyPlanet := Galaxy.IdToPlanet(Cardinal(PendingLiberationCeremonyPlanet)) as TPlanet;
  LastDockedPlanet := Galaxy.IdToPlanet(Cardinal(LastDockedPlanet)) as TPlanet;
end;
{ @end $73DC74 }

{ @routine $73DCC8 TNormalShip_ClearObjectReferences }
procedure TNormalShip.ClearObjectReferences;
begin
  inherited ClearObjectReferences;
  PendingLiberationCeremonyPlanet := nil;
  LastDockedPlanet := nil;
end;
{ @end $73DCC8 }

{ @routine $73DCE4 TNormalShip_SaveToBlock }
procedure TNormalShip.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Roarnuke'), WideString(IntToStr(Rank))); // 'Rank'
  Block.AddParam(DecodeTextW('RearnaksProcitnotas'), WideString(IntToStr(RankPoints))); // 'RankPoints'
  Block.AddParam(DecodeTextW('PlivroaktrenRiasnuk'), WideString(IntToStr(PirateRank))); // 'PirateRank'
  Block.AddParam(DecodeTextW('PhilroaAtrelRoasnAkoPiopionatos'), WideString(IntToStr(PirateRankPoints))); // 'PirateRankPoints'
end;
{ @end $73DCE4 }

{ @routine $73DF14 TNormalShip_LoadFromBlock }
procedure TNormalShip.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Rank := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Roarnuke')))); // 'Rank'
  RankPoints := StrToInt(AnsiString(Block.GetParam(DecodeTextW('RearnaksProcitnotas')))); // 'RankPoints'
  PirateRank := StrToInt(AnsiString(Block.GetParam(DecodeTextW('PlivroaktrenRiasnuk')))); // 'PirateRank'
  PirateRankPoints := Word(StrToInt(AnsiString(Block.GetParam(DecodeTextW('PhilroaAtrelRoasnAkoPiopionatos'))))); // 'PirateRankPoints'
end;
{ @end $73DF14 }

{ @routine $73E134 TNormalShip_NextDay }
procedure TNormalShip.NextDay;
var
  MessageText: WideString;
  Stage: Integer;
begin
  inherited NextDay;
  Stage := 0;
  try
    if InHyperspace then
    begin
      CurrentSystemKills.Dominator := 0;
      CurrentSystemKills.Pirate := 0;
      CurrentSystemKills.Normal := 0;
      CurrentSystemKills.Custom := 0;
    end;
    if (GetPlayer = Self) and not GetPlayer.ProcessPendingPlayerFollowTargeting then Exit;
    if (CurrentPlanet <> nil) and (PendingLiberationCeremonyPlanet = CurrentPlanet) then CollectLiberationRewards;
    Stage := 1;
    RecomputeFearState;
    if (GetPlayer <> nil) and (GetPlayer.CurrentStar = CurrentStar) and
       (Order <> order_none) and PlayerStarDayPrepared and (TurnsSinceLastShipMessage > 5) and
       (((Integer(Seed) * Galaxy.CurrentTurn) mod 7) = 0) and InNormalSpace and GetPlayer.InNormalSpace and
       (PointDistance(Position, GetPlayer.Position) < GetRadarRange) and not PlayerAutomaticControl and
       not GetPlayer.ProcessPendingPlayerFollowTargeting and (ScriptShip = nil) and (LiberationGroup = nil) then
    begin
      MessageText := SelectSituationalMessage(True);
      if MessageText <> '' then ShowMessageToPlayer(MessageText);
    end;
    Stage := 2;
    UpdateRelationsForNearbyCombat;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TNormalShip.NextDay ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $73E134 }

{ @routine $73E510 TNormalShip_CollectLiberationRewards }
function TNormalShip.CollectLiberationRewards: WideString;
const
  RewardPrograms = [program_shipwreck..program_disconnection];
  RewardKinds = [award_liberation, award_accomplishment];
  RewardVictims = [ship_dominator..station_custom];
var
  I, MinimumPriority, RewardKind, Quantity, ModuleIndex, TotalPriority, Priority, Roll: Integer;
  TextBlock: TBlockParEC;
  Prefix: WideString;
  Award: Byte;
  AwardWeight, ProgramWeight, ArtefactWeight, ModuleWeight: Single;
  RewardItem: TItem;
  ProgramIndex: TProgramIndex;
  ModuleItem: TMicroModule;
  Event: TGalaxyEvent;
begin
  if AwardIds = nil then AwardWeight := 80
  else AwardWeight := RemapClamped(AwardIds.Count, 0, 15, 80, 10);
  if (Self is TRanger) and (Self as TRanger).HasProgram(program_intercom) then
    ProgramWeight := RemapClamped((Self as TRanger).CountProgramsInFilter(RewardPrograms), 0, 10, 80, 10)
  else ProgramWeight := 0;
  if Self is TPlayer then ArtefactWeight := RemapClamped(Artefacts.Count, 0, 6, 80, 10)
  else ArtefactWeight := 0;
  if Self is TPlayer then ModuleWeight := RandomIntRange(10, 90)
  else ModuleWeight := 0;
  if (AwardWeight = 0) and (ProgramWeight = 0) and (ArtefactWeight = 0) and (ModuleWeight = 0) then ModuleWeight := 1;
  if AwardWeight > 0 then AwardWeight := AwardWeight * SeededRandomIntRange(5, 25, CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 100 + 1667);
  if ProgramWeight > 0 then ProgramWeight := ProgramWeight * SeededRandomIntRange(5, 25, CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 100 + 197673);
  if ArtefactWeight > 0 then ArtefactWeight := ArtefactWeight * SeededRandomIntRange(5, 25, CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 100 + 719671);
  if ModuleWeight > 0 then ModuleWeight := ModuleWeight * SeededRandomIntRange(5, 25, CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 107 + 1967);
  if (CurrentPlanet.OwnerId = owner_pirate) and (AwardWeight > 0) then AwardWeight := 1;
  if (AwardWeight > 0) and (AwardWeight >= Max(ModuleWeight, Max(ProgramWeight, ArtefactWeight))) then RewardKind := 1
  else if (ProgramWeight > 0) and (ProgramWeight >= Max(ModuleWeight, Max(AwardWeight, ArtefactWeight))) then RewardKind := 2
  else if (ArtefactWeight > 0) and (ArtefactWeight >= Max(ModuleWeight, Max(AwardWeight, ProgramWeight))) then RewardKind := 3
  else if (ModuleWeight > 0) and (ModuleWeight >= Max(ArtefactWeight, Max(AwardWeight, ProgramWeight))) then RewardKind := 4
  else
  begin
    RaiseWideMessage('CongratulationsLiberator');
    RewardKind := 0;
  end;
  if GetPlayer = Self then
  begin
    if CurrentPlanet.OwnerId <> owner_pirate then
    begin
      if CurrentPlanet.CurrentStar.PreviousControlFaction = faction_dominators then
        Result := LocalizedColorText('PlanetCongratulations.LiberationStarNormalsFromKling.' + OwnerToSys(CurrentPlanet.OwnerId) + 'Text')
      else
        Result := LocalizedColorText('PlanetCongratulations.LiberationStarNormalsFromPirateClan.' + OwnerToSys(CurrentPlanet.OwnerId) + 'Text');
    end
    else
    begin
      if CurrentPlanet.CurrentStar.PreviousControlFaction = faction_coalition then
        Prefix := 'PlanetCongratulations.LiberationStarPirateClanFromNormals.'
      else Prefix := 'PlanetCongratulations.LiberationStarPirateClanFromKling.';
      TotalPriority := 0;
      for I := 0 to StrToInt(LookupLocalizedTextByKey(Prefix + 'CongratulationsCount')) - 1 do
      begin
        TextBlock := LanguageDataConfig.FindBlockByPath(Prefix + IntToStr(I));
        if TextBlock <> nil then
        begin
          if TextBlock.CountParams('Priority') <= 0 then Priority := 10
          else Priority := StrToInt(LookupLocalizedTextByKey(Prefix + IntToStr(I) + '.Priority'));
          Inc(TotalPriority, Priority);
        end;
      end;
      Roll := SeededRandomIntRange(1, TotalPriority, Integer(Seed) * ((Integer(Seed) + Galaxy.CurrentTurn) div 20));
      for I := 0 to StrToInt(LookupLocalizedTextByKey(Prefix + 'CongratulationsCount')) - 1 do
      begin
        TextBlock := LanguageDataConfig.FindBlockByPath(Prefix + IntToStr(I));
        if TextBlock <> nil then
        begin
          if TextBlock.CountParams('Priority') <= 0 then Priority := 10
          else Priority := StrToInt(LookupLocalizedTextByKey(Prefix + IntToStr(I) + '.Priority'));
          Dec(TotalPriority, Priority);
          if Roll > TotalPriority then Break;
        end;
      end;
      Result := LocalizedColorText(Prefix + IntToStr(I) + '.Text');
    end;
  end
  else Result := '';
  if CurrentPlanet.OwnerId <> owner_pirate then Prefix := 'PlanetCongratulations.LiberationAwardNormals.'
  else Prefix := 'PlanetCongratulations.LiberationAwardPirateClan.';
  case RewardKind of
    1: begin
      Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), RewardKinds, RewardVictims);
      AddAward(Award);
      if GetPlayer = Self then
      begin
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddReward');
        ReplaceTextToken(Result, '<Reward>', GetAwardInfo(Award).Name, TextHighlightColorTag);
      end
      else Result := '';
    end;
    2: if Self is TRanger then
    begin
      ProgramIndex := (Self as TRanger).SelectRandomProgramIdFromFilter(RewardPrograms);
      Quantity := SeededRandomIntRange(1,
        Round(RemapClamped((Self as TRanger).CountProgramsInFilter(RewardPrograms), 2, 10,
          GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].MaximumQuestProgramRewardCount, 1)),
        Integer(ProgramIndex) + CurrentStar.GenerationSeed * (Galaxy.CurrentTurn div 25));
      Inc((Self as TRanger).ProgramCounts[ProgramIndex], Quantity);
      if GetPlayer = Self then
      begin
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddProgramms');
        ReplaceTextToken(Result, '<Programm>', (Self as TRanger).GetProgramName(ProgramIndex), TextHighlightColorTag);
        ReplaceTextToken(Result, '<Count>', IntToStr(Quantity), TextHighlightColorTag);
      end
      else Result := '';
    end;
    3: begin
      RewardItem := CreateRandomLootItem(loot_reward, CurrentPlanet.OwnerId, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 50 + 123424767);
      if RewardItem is TArtefactTranclucator then TTranclucator(TArtefactTranclucator(RewardItem).Ship).OwnerShip := Self;
      if RewardItem is TArtefact then Artefacts.Add(RewardItem)
      else Inventory.Add(RewardItem);
      if GetPlayer = Self then
      begin
        GetPlayer.ScriptItemsAct(event_government_item_reward, RewardItem, nil, 0);
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddArtefact') + #13#10 + RewardItem.GetDescriptionText;
        ReplaceTextToken(Result, '<Artefact>', RewardItem.GetDisplayName, TextHighlightColorTag);
      end
      else Result := '';
    end;
    4: begin
      I := 0;
      repeat
        MinimumPriority := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 70, 20));
        ModuleIndex := Galaxy.SelectMicroModule(MinimumPriority, Min(MinimumPriority + 30, 100), Galaxy.CurrentTurn div 77 + 17 * I + CurrentPlanet.Id, CurrentPlanet);
        Inc(I);
        if I > 50 then Break;
      until GetPlayer.NeedsMicroModule(ModuleIndex + 1);
      ModuleItem := TMicroModule.Create;
      ModuleItem.Init(ModuleIndex);
      ModuleItem.OwnerId := CurrentPlanet.OwnerId;
      if GetPlayer = Self then
      begin
        GetPlayer.ScriptItemsAct(event_government_item_reward, ModuleItem, nil, 0);
        Event := AddGalaxyEvent('PlayerReceivesMMAsReward');
        Event.AddData(ModuleItem.Id);
        Event.AddData(ModuleItem.MicroModuleIndex - 1);
      end;
      Inventory.Add(ModuleItem);
      if GetPlayer = Self then
      begin
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddNod') + #13#10 + ModuleItem.GetInfoText(TextHighlightColorTag, nil);
        ReplaceTextToken(Result, '<Nod>', MicroModuleTemplates[ModuleIndex].Name, TextHighlightColorTag);
      end
      else Result := '';
    end;
  end;
  I := RoundAndTruncateToTens(SeededRandomIntRange(250, Galaxy.ScaleIntByTechLevel(500, 1000),
    (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 100) + Ln(PendingLiberationContribution * 0.2 + 1) * 1000);
  GainExperience(I, experience_unscaled);
  if GetPlayer = Self then
  begin
    Result := Result + #13#10 + ' ' + #13#10 + WrapTextInColor(LocalizedColorText(Prefix + 'AddPoints'), DarkGreenColorTag);
    ReplaceTextToken(Result, '<Points>', IntToStr(I), '');
  end
  else Result := '';
  if GetPlayer = Self then
  begin
    ReplaceTextToken(Result, '<Star>', CurrentPlanet.CurrentStar.Name, TextHighlightColorTag);
    ReplaceTextToken(Result, '<Planet>', CurrentPlanet.Name, TextHighlightColorTag);
  end;
  PendingLiberationCeremonyPlanet := nil;
  PendingLiberationContribution := 0;
end;
{ @end $73E510 }

{ @routine $73FAC0 TNormalShip_AwardRandomMedal }
function TNormalShip.AwardRandomMedal: WideString;
var Award: Byte;
begin
  if CurrentPlanet <> nil then Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [award_liberation, award_accomplishment], [ship_dominator..station_custom])
  else if DockedTo <> nil then Award := SelectAward(RaceToOwner(DockedTo.PilotRace), [award_liberation, award_accomplishment], [ship_dominator..station_custom])
  else Award := SelectAward(owner_human, [award_liberation, award_accomplishment], [ship_dominator..station_custom]);
  AddAward(Award);
  Result := GetAwardInfo(Award).Name;
end;
{ @end $73FAC0 }

{ @routine $73FC64 TNormalShip_ProcessShipKill }
procedure TNormalShip.ProcessShipKill(Victim: TShip);
var
  I, SharedExperience, ExperienceDelta, ActivityAmount: Integer;
  Experience, RankReward, PirateReward: Integer;
  SourceKind: TExperienceSource;
  OtherShip: TShip;
  OtherNormal: TNormalShip;
  Event: TGalaxyEvent;
  Quest: PQuest;
  QuestTargetKill: Boolean;

  // @nested $73FBA4 RecordShipKillCategory
  procedure RecordShipKillCategory(Ship: TNormalShip; Victim: TShip); // @addr $73FBA4 @note "Nested helper; unused caller-popped static link."
  begin
    case Victim.TypeId of
      ship_transport: if Victim.OwnerId <> owner_pirate then
        begin
          Inc(Ship.CivilianKillCount);
          if GetPlayer = Ship then TryAddAchievementProgress('BLACKHEAD', 1);
          Ship.CheckKillCountAwards(Victim);
        end;
      ship_warrior: begin
        Inc(Ship.MilitaryKillCount);
        Ship.CheckKillCountAwards(Victim);
      end;
      ship_ranger: if ((Victim as TRanger).GetDominantCareer <> career_pirate) and (Victim.OwnerId <> owner_pirate) and
        not (Victim as TRanger).ExcludedFromRating then
        begin
          Inc(Ship.RangerKillCount);
          Ship.CheckKillCountAwards(Victim);
        end;
    end;
  end;

begin
  if Self = Victim then Exit;
  SourceKind := experience_normal_ships;
  QuestTargetKill := False;
  if GetPlayer = Self then
  begin
    Event := AddGalaxyEvent('PlayerKillsShip');
    Event.AddData(Ord(Victim.TypeId));
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Ord(Victim.OwnerId));
    Event.AddTextData(Victim.GetName);
    Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
    Event.AddTextData(Victim.GetFullName(' '));
    Event.AddTextData(Victim.TypeNameOverrideKey);
    if Victim is TKling then Event.AddData(Byte((Victim as TKling).KlingType))
    else if Victim is TTransport then Event.AddData(Byte((Victim as TTransport).TransportType))
    else if Victim is TWarrior then Event.AddData(Byte((Victim as TWarrior).WarriorType))
    else if Victim is TPirate then Event.AddData(Byte((Victim as TPirate).PirateType))
    else Event.AddData(0);
    for I := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[I];
      if not Quest.Successful and (Quest.QuestType = quest_kind_destroy_ship) and
         (Quest.ObjectiveTarget = Victim) then QuestTargetKill := True;
    end;
  end;
  if GetPlayer = PartnerShip then
  begin
    Event := AddGalaxyEvent('PlayerCompanionKillsShip');
    Event.AddData(Ord(Victim.TypeId));
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Ord(Victim.OwnerId));
    Event.AddTextData(Victim.GetName);
    Event.AddData(Ord(Self.TypeId));
    Event.AddData(Self.Id);
    Event.AddData(Ord(Self.OwnerId));
    Event.AddTextData(Self.GetName);
    Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
    Event.AddTextData(Victim.GetFullName(' '));
    Event.AddTextData(Victim.TypeNameOverrideKey);
    if Victim is TKling then Event.AddData(Byte((Victim as TKling).KlingType))
    else if Victim is TTransport then Event.AddData(Byte((Victim as TTransport).TransportType))
    else if Victim is TWarrior then Event.AddData(Byte((Victim as TWarrior).WarriorType))
    else if Victim is TPirate then Event.AddData(Byte((Victim as TPirate).PirateType))
    else Event.AddData(0);
  end;
  Experience := 0;
  RankReward := 0;
  PirateReward := 0;
  Inc(TotalShipKillCount);
  if CurrentStanding = standing_custom then Exit;
  if Victim.CurrentStanding = standing_custom then
  begin
    IncrementWordSaturating(CurrentSystemKills.Custom);
    RankReward := 10;
    Experience := NextRandomIntRange(250, 500, Galaxy.RandomState);
    SourceKind := experience_unscaled;
    if Self is TRanger then
    begin
      if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 8;
      if Galaxy.CoalitionDefeatedTurn = 0 then
        (Self as TRanger).AddWarriorCareerActivity(ActivityAmount);
    end;
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
     (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace then (PartnerShip as TNormalShip).AddRankPoints(6);
    if OwnerId = owner_pirate then PirateReward := 8;
  end
  else if (Victim.TypeId = ship_transport) and (Self is TRanger) then
  begin
    if not QuestTargetKill then IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    Experience := Round(NextRandomIntRange(100, 250, Galaxy.RandomState) * (Ord(TNormalShip(Victim).Rank) * 0.1 + 1));
    if OwnerId = owner_pirate then
    begin
      PirateReward := 8;
      Experience := Round(Experience * 1.5);
    end;
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddPirateCareerActivity(ActivityAmount);
  end
  else if (Victim is TRanger) and (Self is TRanger) then
  begin
    if (Victim as TRanger).GetDominantCareer = career_pirate then
    begin
      SourceKind := experience_pirates;
      RankReward := 10;
      (Self as TRanger).AddWarriorCareerActivity(4);
      Experience := Round(NextRandomIntRange(250, 500, Galaxy.RandomState) * (Ord(TNormalShip(Victim).PirateRank) * 0.1 + 1));
    end
    else
    begin
      if not QuestTargetKill then
      begin
        IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
      end;
    if GetPlayer = Self then ActivityAmount := 8 else ActivityAmount := 2;
    (Self as TRanger).AddPirateCareerActivity(ActivityAmount);
      Experience := Round(NextRandomIntRange(100, 250, Galaxy.RandomState) * (Ord(TNormalShip(Victim).Rank) * 0.1 + 1));
      if OwnerId = owner_pirate then
      begin
        PirateReward := 24;
        Experience := Round(Experience * 1.5);
      end;
    end;
  end
  else if (Victim is TRanger) and (Self is TPirate) then
  begin
    if TRanger(Victim).GetDominantCareer <> career_pirate then
    begin
      Inc(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
      PirateReward := 24;
    end;
  end
  else if Victim is TPirate then
  begin
    SourceKind := experience_pirates;
    if (Victim.OwnerId = owner_pirate) and not QuestTargetKill then
    begin
      IncrementWordSaturating(CurrentSystemKills.Pirate);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Pirate = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Pirate);
    end;
    Inc(PirateKillCount);
    if GetPlayer = Self then TryAddAchievementProgress('SHIELD', 1);
    Experience := Round(NextRandomIntRange(250, 500, Galaxy.RandomState) * (Ord(TNormalShip(Victim).PirateRank) * 0.1 + 1));
    RankReward := 10;
    if OwnerId = owner_pirate then Experience := Experience div 2;
    if Self is TRanger then (Self as TRanger).AddWarriorCareerActivity(4);
  end
  else if Victim is TKling then
  begin
    Inc(DominatorKillCount);
    if GetPlayer = Self then Inc(GetPlayer.DominatorKillsByType[(Victim as TKling).KlingType]);
    IncrementWordSaturating(CurrentSystemKills.Dominator);
    RankReward := DominatorShipDefinitions[(Victim as TKling).KlingType].RankPoints;
    Experience := Round(DominatorShipDefinitions[(Victim as TKling).KlingType].KillExperience * Galaxy.GetDominatorKillExperienceScale);
    SourceKind := experience_dominators;
    if Self is TRanger then
    begin
      if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 8;
      if Galaxy.CoalitionDefeatedTurn = 0 then
        (Self as TRanger).AddWarriorCareerActivity(ActivityAmount);
      if GetPlayer = Self then GetPlayer.TryAwardDominatorPrograms(Victim);
      if (GetPlayer = Self) and GetPlayer.HasRadiationSickness then
        Experience := Round(GetPlayer.RadiationHealth[1].Progress * Experience);
    end;
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
     (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace then
    begin
      (PartnerShip as TNormalShip).AddRankPoints(DominatorShipDefinitions[(Victim as TKling).KlingType].RankPoints div 2 + 1);
      if (PartnerShip as TNormalShip).CurrentSystemKills.Dominator = 0 then
        Inc(TNormalShip(PartnerShip).CurrentSystemKills.Dominator);
    end;
    if OwnerId = owner_pirate then PirateReward := DominatorShipDefinitions[(Victim as TKling).KlingType].PirateRankPoints;
  end
  else if Victim is TWarrior then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = owner_pirate then
    begin
      Experience := Round(NextRandomIntRange(250, 500, Galaxy.RandomState) * (Ord(TNormalShip(Victim).Rank) * 0.1 + 1));
      if (Victim as TWarrior).WarriorType = warrior_flagship then
      begin
        Experience := Experience * 2;
        PirateReward := 60;
      end
      else PirateReward := 16;
    end;
    if Self is TRanger then
    begin
    if GetPlayer = Self then ActivityAmount := 8 else ActivityAmount := 2;
    (Self as TRanger).AddPirateCareerActivity(ActivityAmount);
    end;
  end
  else if Victim.TypeId = ship_transport then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = owner_pirate then PirateReward := 8;
  end
  else if (Victim.TypeId in [station_ranger_center..station_custom]) and (Victim.CurrentStanding = standing_coalition_military) then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = owner_pirate then PirateReward := 32;
    if Self is TRanger then
    begin
    if GetPlayer = Self then ActivityAmount := 8 else ActivityAmount := 2;
    (Self as TRanger).AddPirateCareerActivity(ActivityAmount);
    end;
  end
  else if (Victim.TypeId in [station_ranger_center..station_custom]) and (Victim.CurrentStanding = standing_coalition_active) then
  begin
    Inc(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = owner_pirate then PirateReward := 24;
    if Self is TRanger then
    begin
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddPirateCareerActivity(ActivityAmount);
    end;
  end
  else if (Victim.TypeId in [station_ranger_center..station_custom]) and (Victim.CurrentStanding in [standing_coalition_passive..standing_pirate_passive]) then
  begin
    if CurrentStar.ControlFaction = faction_coalition then
    begin
      IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    end;
    if CurrentStar.ControlFaction = faction_pirates then
    begin
      IncrementWordSaturating(CurrentSystemKills.Pirate);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Pirate = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Pirate);
    end;
    if (Victim.TypeId <> station_pirate_base) and (Self is TRanger) then
    begin
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddPirateCareerActivity(ActivityAmount);
    end;
    if (Victim.TypeId = station_pirate_base) and (Self is TRanger) then
    begin
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddWarriorCareerActivity(ActivityAmount);
    end;
  end
  else if (Victim.TypeId in [station_ranger_center..station_custom]) and (Victim.CurrentStanding in [standing_pirate_active..standing_pirate_military]) then
  begin
    if CurrentStar.ControlFaction = faction_pirates then
    begin
      IncrementWordSaturating(CurrentSystemKills.Pirate);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Pirate = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Pirate);
    end;
    if Self is TRanger then
    begin
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddWarriorCareerActivity(ActivityAmount);
    end;
  end;
  if Victim.CurrentStanding <> standing_custom then
  begin
    if (GetPlayer = Self) and (GetPlayer.PirateLicenseTicks > 0) then
    begin
      if Victim is TWarrior then
      begin
        if (Victim as TWarrior).WarriorType = warrior_flagship then
          Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 2000))
        else Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 6000));
      end;
      if Victim.TypeId = station_military_base then
        Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 2000));
    end;
    if (GetPlayer = Self) and (CurrentStar.ControlFaction = faction_coalition) then
      GetPlayer.AchievementStats.CheckHaterAchievement;
    RecordShipKillCategory(Self, Victim);
  end;
  if Self is TPirate then (Self as TPirate).RaidPressure := 0;
  if (RankReward > 0) or (Experience > 0) or (PirateReward > 0) then
  begin
    if RankReward > 0 then
    begin
      if OwnerId <> owner_pirate then AddRankPoints(Word(RankReward));
      RankReward := RankReward div 2 + 1;
    end;
    if Experience > 0 then
    begin
      GainExperience(Experience, SourceKind);
      if (PartnerShip <> nil) and (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace then
      begin
        SharedExperience := Round(Experience * LeadershipExperiencePercent[PartnerShip.GetEffectiveSkillLevel(skill_leadership)] * 0.01);
        if PartnerShip = GetPlayer then
        begin
          Event := AddGalaxyEvent('PlayerGotExpFromPartner');
          Event.AddData(Id);
          Event.AddData(PartnerShip.GetEffectiveSkillLevel(skill_leadership));
          if SourceKind = experience_dominators then ExperienceDelta := GetPlayer.ExperienceByDominators
          else if SourceKind = experience_pirates then ExperienceDelta := GetPlayer.ExperienceByPirates
          else if SourceKind = experience_normal_ships then ExperienceDelta := GetPlayer.ExperienceByNormals
          else ExperienceDelta := 0;
          GetPlayer.GainExperience(SharedExperience, SourceKind);
          if SourceKind = experience_dominators then ExperienceDelta := GetPlayer.ExperienceByDominators - ExperienceDelta
          else if SourceKind = experience_pirates then ExperienceDelta := GetPlayer.ExperienceByPirates - ExperienceDelta
          else if SourceKind = experience_normal_ships then ExperienceDelta := GetPlayer.ExperienceByNormals - ExperienceDelta;
          Event.AddData(Ord(SourceKind));
          Event.AddData(SharedExperience);
          Event.AddData(ExperienceDelta);
        end
        else (PartnerShip as TNormalShip).GainExperience(SharedExperience, SourceKind);
      end;
      Experience := Experience div 2 + 1;
    end;
    if PirateReward > 0 then
    begin
      if OwnerId = owner_pirate then AddPirateRankPoints(PirateReward);
      PirateReward := PirateReward div 2 + 1;
    end;
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      OtherShip := CurrentStar.Ships[I];
      if (OtherShip = Self) or not OtherShip.InNormalSpace or not OtherShip.IsAttackingShip(Victim) then Continue;
      if (OtherShip is TTranclucator) and (GetPlayer = TTranclucator(OtherShip).OwnerShip) then
      begin
    Event := AddGalaxyEvent('PlayerTranclucatorAssistKillsShip');
    Event.AddData(Ord(Victim.TypeId));
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Ord(Victim.OwnerId));
    Event.AddTextData(Victim.GetName);
    Event.AddData(OtherShip.Id);
    Event.AddData(Ord(OtherShip.OwnerId));
    Event.AddTextData(OtherShip.GetName);
    Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
    Event.AddTextData(Victim.GetFullName(' '));
    Event.AddTextData(Victim.TypeNameOverrideKey);
    if Victim is TKling then Event.AddData(Byte((Victim as TKling).KlingType))
    else if Victim is TTransport then Event.AddData(Byte((Victim as TTransport).TransportType))
    else if Victim is TWarrior then Event.AddData(Byte((Victim as TWarrior).WarriorType))
    else if Victim is TPirate then Event.AddData(Byte((Victim as TPirate).PirateType))
    else Event.AddData(0);
      end;
      if not (OtherShip is TNormalShip) then Continue;
      OtherNormal := TNormalShip(OtherShip);
      if GetPlayer = OtherShip then
      begin
    Event := AddGalaxyEvent('PlayerAssistKillsShip');
    Event.AddData(Ord(Victim.TypeId));
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Ord(Victim.OwnerId));
    Event.AddTextData(Victim.GetName);
    Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
    Event.AddTextData(Victim.GetFullName(' '));
    Event.AddTextData(Victim.TypeNameOverrideKey);
    if Victim is TKling then Event.AddData(Byte((Victim as TKling).KlingType))
    else if Victim is TTransport then Event.AddData(Byte((Victim as TTransport).TransportType))
    else if Victim is TWarrior then Event.AddData(Byte((Victim as TWarrior).WarriorType))
    else if Victim is TPirate then Event.AddData(Byte((Victim as TPirate).PirateType))
    else Event.AddData(0);
      end;
      if GetPlayer = OtherShip.PartnerShip then
      begin
    Event := AddGalaxyEvent('PlayerCompanionAssistKillsShip');
    Event.AddData(Ord(Victim.TypeId));
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Ord(Victim.OwnerId));
    Event.AddTextData(Victim.GetName);
    Event.AddData(Ord(OtherShip.TypeId));
    Event.AddData(OtherShip.Id);
    Event.AddData(Ord(OtherShip.OwnerId));
    Event.AddTextData(OtherShip.GetName);
    Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
    Event.AddTextData(Victim.GetFullName(' '));
    Event.AddTextData(Victim.TypeNameOverrideKey);
    if Victim is TKling then Event.AddData(Byte((Victim as TKling).KlingType))
    else if Victim is TTransport then Event.AddData(Byte((Victim as TTransport).TransportType))
    else if Victim is TWarrior then Event.AddData(Byte((Victim as TWarrior).WarriorType))
    else if Victim is TPirate then Event.AddData(Byte((Victim as TPirate).PirateType))
    else Event.AddData(0);
      end;
      if OtherNormal is TPirate then (OtherNormal as TPirate).RaidPressure := 0;
      if (RankReward > 0) and (OtherNormal.OwnerId <> owner_pirate) then OtherNormal.AddRankPoints(Word(RankReward));
      if Experience > 0 then OtherNormal.GainExperience(Experience, SourceKind);
      if (PirateReward > 0) and (OtherNormal.OwnerId = owner_pirate) then OtherNormal.AddPirateRankPoints(PirateReward);
      Inc(OtherNormal.TotalShipKillCount);
      if Victim.CurrentStanding = standing_custom then IncrementWordSaturating(OtherNormal.CurrentSystemKills.Custom)
      else if Victim is TKling then
      begin
        Inc(OtherNormal.DominatorKillCount);
        IncrementWordSaturating(OtherNormal.CurrentSystemKills.Dominator);
        if GetPlayer = OtherShip then Inc(GetPlayer.DominatorKillsByType[(Victim as TKling).KlingType]);
      end
      else if (Victim is TPirate) or ((Victim is TRanger) and ((Victim as TRanger).GetDominantCareer = career_pirate)) then
      begin
        if (Victim.OwnerId = owner_pirate) and not QuestTargetKill then IncrementWordSaturating(OtherNormal.CurrentSystemKills.Pirate);
        Inc(OtherNormal.PirateKillCount);
        if (GetPlayer = OtherShip) and (Victim is TPirate) then TryAddAchievementProgress('SHIELD', 1);
      end
      else if (Victim is TNormalShip) and (Victim.OwnerId in PlanetOwnerMasks.Coalition) then
      begin
        if not QuestTargetKill then IncrementWordSaturating(OtherNormal.CurrentSystemKills.Normal);
      end
      else if Victim.TypeId in [station_ranger_center..station_custom] then
        if Victim.CurrentStanding in FactionStandingMasks[CurrentStar.ControlFaction] then
        IncrementWordSaturating(OtherNormal.CurrentSystemKills.ByFaction[CurrentStar.ControlFaction]);
      RecordShipKillCategory(OtherNormal, Victim);
    end;
  end;
end;
{ @end $73FC64 }

{ @routine $741B4C ProcessSystemLiberationRewards }
procedure ProcessSystemLiberationRewards(SourceShip: TNormalShip; Star: TStar);
var
  I, J: Integer;
  Ship: TShip;
  Normal: TNormalShip;
  Planet, CeremonyPlanet: TPlanet;
  Text: WideString;

  // @nested $741AA0 LogPlayerEvent
  procedure LogPlayerEvent(Ship: TShip); // @addr $741AA0 @note "Nested helper; caller-popped link, Star at ParentFrame-4."
  var
    Event: TGalaxyEvent;
  begin
    if GetPlayer = Ship then
    begin
      Event := AddGalaxyEvent('PlayerLiberatesSystem');
      Event.AddData(Star.Id);
      Event.AddData(Byte(Star.ControlFaction));
      Event.AddData(Byte(Star.PreviousControlFaction));
      Event.AddData(GetPlayer.PendingLiberationContribution);
      Event.AddData(GetPlayer.PendingLiberationCeremonyPlanet.Id);
    end;
  end;
begin
  if Star.ControlFaction = faction_coalition then
  begin
    CeremonyPlanet := TObject(Star.FindFirstInhabitedPlanet) as TPlanet;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship is TNormalShip then
      begin
        Normal := Ship as TNormalShip;
        Normal.PendingLiberationCeremonyPlanet := nil;
        if ((Normal.CurrentSystemKills.Dominator > 0) and (Star.PreviousControlFaction = faction_dominators)) or
           ((Normal.CurrentSystemKills.Pirate > 0) and (Star.PreviousControlFaction = faction_pirates) and (Normal.OwnerId <> owner_pirate)) or
           ((GetPlayer <> Ship) and (Ship.DaysSincePlayerSeen > 1) and
            (Normal.DominatorKillCount + Normal.PirateKillCount > Normal.LiberatedSystemCount)) then
        begin
          if Star.PreviousControlFaction = faction_dominators then Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Dominator;
          if Star.PreviousControlFaction = faction_pirates then Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Pirate;
          Normal.CurrentSystemKills.Dominator := 0;
          Normal.CurrentSystemKills.Pirate := 0;
          Normal.CurrentSystemKills.Normal := 0;
          Normal.CurrentSystemKills.Custom := 0;
          Inc(Normal.LiberatedSystemCount);
          Normal.PendingLiberationCeremonyPlanet := CeremonyPlanet;
          if Normal.OwnerId <> owner_pirate then Normal.AddRankPoints(30) else Normal.AddPirateRankPoints(16);
          Normal.GainExperience(NextRandomIntRange(250, 500, Galaxy.RandomState), experience_unscaled);
          if Ship is TRanger then
            for J := 0 to Star.Planets.Count - 1 do
            begin
              Planet := Star.Planets[J];
              if Planet.IsCoalitionOwned then Planet.ChangeRelationToRanger(Ship, 100);
            end;
          if Ship.InNormalSpace and ((GetPlayer <> Ship) or PlayerAutomaticControl) then Ship.OrderLanding(CeremonyPlanet, True);
          LogPlayerEvent(Ship);
        end;
      end;
    end;
    if Galaxy.CoalitionDefeatedTurn = 0 then
    begin
      if Star.PreviousControlFaction = faction_dominators then
      begin
        Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.NormalsTakeSystemFromKling', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          TextHighlightColorTag, '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name);
        Galaxy.AddPlanetNews(news_coalition_takes_dominator_system, Text);
      end
      else
      begin
        Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.NormalsTakeSystemFromPirateClan', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          TextHighlightColorTag, '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name);
        Galaxy.AddPlanetNews(news_coalition_takes_pirate_system, Text);
      end;
      with AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, Text, '') do
      begin
        if (GetPlayer.CurrentStar = Star) and GetPlayer.InNormalSpace then NotificationSoundKind := 1
        else NotificationSoundKind := 0;
        Targets[0].PlanetId := CeremonyPlanet.Id;
      end;
    end;
  end
  else if Star.ControlFaction = faction_pirates then
  begin
    CeremonyPlanet := TObject(Star.FindFirstInhabitedPlanet) as TPlanet;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship is TNormalShip then
      begin
        Normal := Ship as TNormalShip;
        Normal.PendingLiberationCeremonyPlanet := nil;
        if ((Normal.CurrentSystemKills.Dominator > 0) and (Star.PreviousControlFaction = faction_dominators)) or
           ((Normal.CurrentSystemKills.Normal > 0) and (Star.PreviousControlFaction = faction_coalition) and (Normal.OwnerId = owner_pirate)) or
           ((GetPlayer <> Ship) and (Ship.DaysSincePlayerSeen > 1) and
            (Normal.MilitaryKillCount + Normal.DominatorKillCount > Normal.LiberatedSystemCount)) then
        begin
          if Star.PreviousControlFaction = faction_dominators then Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Dominator;
          if Star.PreviousControlFaction = faction_coalition then Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Normal;
          Normal.CurrentSystemKills.Dominator := 0;
          Normal.CurrentSystemKills.Pirate := 0;
          Normal.CurrentSystemKills.Normal := 0;
          Normal.CurrentSystemKills.Custom := 0;
          Inc(Normal.LiberatedSystemCount);
          Normal.PendingLiberationCeremonyPlanet := CeremonyPlanet;
          Normal.AddPirateRankPoints(16);
          Normal.GainExperience(NextRandomIntRange(250, 500, Galaxy.RandomState), experience_unscaled);
          if Ship is TRanger then
            if MainPiratePlanet <> nil then
            begin
              MainPiratePlanet.ChangeRelationToRanger(Ship, 10);
              if (GetPlayer = Ship) and (GetPlayer.PirateLicenseTicks > 0) then
                Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 1000));
            end;
          if Ship.InNormalSpace and ((GetPlayer <> Ship) or PlayerAutomaticControl) then Ship.OrderLanding(CeremonyPlanet, True);
          LogPlayerEvent(Ship);
          if GetPlayer = Ship then
          begin
            Inc(GetPlayer.AchievementStats.SystemsCapturedForPirates);
            TrySetAchievementProgress('PIRATE', GetPlayer.AchievementStats.SystemsCapturedForPirates);
          end;
        end;
      end;
    end;
    if Star.PreviousControlFaction = faction_coalition then
    begin
      Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.PirateClanTakeSystemFromNormals', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          TextHighlightColorTag, '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name);
      if Galaxy.CoalitionDefeatedTurn = 0 then Galaxy.AddPlanetNews(news_pirates_take_coalition_system, Text);
    end
    else
    begin
      if Galaxy.CoalitionDefeatedTurn = 0 then
        Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.PirateClanTakeSystemFromKling', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          TextHighlightColorTag, '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name)
      else
        Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.PirateClanTakeSystemFromKlingAlt', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          TextHighlightColorTag, '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name);
      if Galaxy.CoalitionDefeatedTurn = 0 then Galaxy.AddPlanetNews(news_pirates_take_dominator_system, Text);
    end;
    with AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, Text, '') do
      begin
        if (GetPlayer.CurrentStar = Star) and GetPlayer.InNormalSpace then NotificationSoundKind := 1
        else NotificationSoundKind := 0;
        Targets[0].PlanetId := CeremonyPlanet.Id;
      end;
  end;
end;
{ @end $741B4C }

{ @routine $742804 TNormalShip_CheckKillCountAwards }
procedure TNormalShip.CheckKillCountAwards(Victim: TShip);
  // @nested $7425E0 Check
  procedure Check(InitialThreshold, Multiplier: Integer; Count: Word; VictimType: TShipType); // @addr $7425E0 @calls "0x00742834,0x00742854,0x0074287D" @note "Caller-popped static link; ship at ParentFrame-4."
  const
    BadAwards = [award_perfidy];
  var
    I, Threshold, Award: Integer;
    Text, ShipTypeName: WideString;
  begin
    if (Galaxy.CoalitionDefeatedTurn > 0) or (Count = High(Word)) then Exit;
    Threshold := InitialThreshold;
    for I := 1 to 8 do
    begin
      if Count < Threshold then Exit;
      if Count = Threshold then
      begin
        Award := SelectAward(OwnerId, BadAwards, [VictimType]);
        if Award <> AwardNotFound then
        begin
          AddAward(Award);
          if GetPlayer = Self then
          begin
            ShipTypeName := ShipTypeNames[VictimType].Name;
            Text := PickLocalizedTextVariant('GalaxyNews.BadReward.Kill' + ShipTypeName, Seed + Cardinal(Galaxy.CurrentTurn div 10));
            ReplaceTextToken(Text, '<Reward>', GetAwardInfo(Byte(Award)).Name, TextHighlightColorTag);
            AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, Text, '');
          end;
        end;
        Exit;
      end;
      Threshold := Min(Threshold * Multiplier, 10000000);
    end;
  end;
begin
  case Victim.TypeId of
    ship_transport: Check(5, 5, Word(CivilianKillCount), ship_transport);
    ship_warrior: Check(3, 3, Word(MilitaryKillCount), ship_warrior);
    ship_ranger: if TypeId = ship_ranger then Check(2, 4, Word(RangerKillCount), ship_ranger);
  end;
end;
{ @end $742804 }

{ @routine $742888 TNormalShip_UpdateRelationsForNearbyCombat }
procedure TNormalShip.UpdateRelationsForNearbyCombat;
var
  I: Integer;
  Ship, Target: TShip;
  Ranger: TRanger;
  Change: Boolean;
begin
  if not InNormalSpace or (GetPlayer = Self) then Exit;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[I];
    if not (Ship is TRanger) or (Ship = Self) or not Ship.InNormalSpace then Continue;
    Ranger := Ship as TRanger;
    if (Ranger.OrderTarget is TShip) and (Ranger.OrderTarget = Ranger.EnemyShip) then
    begin
      Target := Ranger.OrderTarget as TShip;
      if GetRelationLevelToShip(Target) = relation_level_excellent then
      begin
        if (GetPlayer = Ship) or (NextRandomUnitFloat(RandomState) <= 0.1) then
        begin
          Change := (Target.OrderTarget <> Ranger) and (Target.GetRelationLevelToShip(Ranger) = relation_level_hostile);
          if Change then ChangeRelationToRanger(Ranger, -2);
        end;
      end
      else if GetRelationLevelToShip(Target) = relation_level_hostile then
      begin
        Change := Target.GetRelationLevelToShip(Ranger) = relation_level_hostile;
        if Change then ChangeRelationToRanger(Ranger, 2);
      end;
    end;
  end;
end;
{ @end $742888 }

{ @routine $7429F8 TNormalShip_SelectAward }
function TNormalShip.SelectAward(Owner: TOwnerId; Kinds: TAwardTypeMask; VictimTypes: TShipTypeMask): Byte;
var
  I, Count: Integer;
  Candidates: TList;
  KillName: WideString;
begin
  Candidates := TList.Create;
  Count := StrToInt(LookupLocalizedTextByKey('Reward.Count')) - 1;
  for I := 0 to Count do
    if MatchesOwnerName(Owner, LookupLocalizedTextByKey('Reward.' + IntToStr(I) + '.Race')) and
      (SysToReward(LookupLocalizedTextByKey('Reward.' + IntToStr(I) + '.Type')) in Kinds) and
      MatchesCareerName(GetDominantCareer, LookupLocalizedTextByKey('Reward.' + IntToStr(I) + '.Status')) then
    begin
      KillName := LocalizedText('Reward.' + IntToStr(I) + '.Kill');
      if (Length(KillName) = 0) or (SysToShipType(KillName) in VictimTypes) then Candidates.Add(Pointer(I));
    end;
  if Candidates.Count > 0 then
  begin
    Result := Byte(Candidates[SeededRandomIntRange(0, Candidates.Count - 1, (Integer(Seed) + Galaxy.CurrentTurn) div 101)]);
    if (AwardIds <> nil) and (AwardIds.IndexOf(Pointer(Result)) >= 0) then
      Result := Byte(Candidates[SeededRandomIntRange(0, Candidates.Count - 1, (Integer(Seed) + 2 * Galaxy.CurrentTurn) div 101)]);
    if (AwardIds <> nil) and (AwardIds.IndexOf(Pointer(Result)) >= 0) then
      Result := Byte(Candidates[SeededRandomIntRange(0, Candidates.Count - 1, (Integer(Seed) + 3 * Galaxy.CurrentTurn) div 101)]);
  end
  else Result := AwardNotFound;
  Candidates.Free;
end;
{ @end $7429F8 }

{ @routine $742DB0 TNormalShip_GetAwardInfo }
function TNormalShip.GetAwardInfo(AwardId: Byte): TRewardInfo;
begin
  Result.AwardId := AwardId;
  Result.Name := LookupLocalizedTextByKey('Reward.' + IntToStr(AwardId) + '.Name');
  Result.Text := LookupLocalizedTextByKey('Reward.' + IntToStr(AwardId) + '.Text');
end;
{ @end $742DB0 }

{ @routine $742EE8 TNormalShip_GetRankName }
function TNormalShip.GetRankName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank] + '.Name');
end;
{ @end $742EE8 }

{ @routine $742F74 TNormalShip_GetRankLongName }
function TNormalShip.GetRankLongName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank] + '.NameBig');
end;
{ @end $742F74 }

{ @routine $743008 TNormalShip_GetRankDescription }
function TNormalShip.GetRankDescription: WideString;
begin
  Result := LocalizedColorText('Rank.' + CoalitionRankNames[Rank] + '.Text');
end;
{ @end $743008 }

{ @routine $743094 TNormalShip_GetNextRankName }
function TNormalShip.GetNextRankName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank + 1] + '.Name');
end;
{ @end $743094 }

{ @routine $743124 TNormalShip_GetRankPointsToNextRank }
function TNormalShip.GetRankPointsToNextRank: Word;
begin
  if (Rank < 7) and (CoalitionRankPointThresholds[Rank] > RankPoints) then
    Result := CoalitionRankPointThresholds[Rank] - RankPoints
  else Result := 0;
end;
{ @end $743124 }

{ @routine $743164 TNormalShip_AddRankPoints }
procedure TNormalShip.AddRankPoints(Amount: Word);
var
  Needed: Integer;
begin
  Needed := GetRankPointsToNextRank;
  Inc(RankPoints, Min(Amount, Needed));
  if (Needed > 0) and (GetPlayer = Self) and GetPlayer.CanPromoteRank and
     (Galaxy.CoalitionDefeatedTurn = 0) then
    AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn,
      FormatText1(PickLocalizedTextVariant('GalaxyNews.WB.NewRank', Seed * (Galaxy.CurrentTurn div 10)),
        TextHighlightColorTag, '<Rank>', GetPlayer.GetNextRankName), '');
end;
{ @end $743164 }

{ @routine $7432CC TNormalShip_TryPromoteRank }
function TNormalShip.TryPromoteRank: Boolean;
begin
  if (Rank < 7) and (GetRankPointsToNextRank = 0) then
  begin
    Inc(Rank);
    RankPoints := 0;
    Result := True;
  end
  else Result := False;
end;
{ @end $7432CC }

{ @routine $7432FC TNormalShip_CanPromoteRank }
function TNormalShip.CanPromoteRank: Boolean;
begin
  Result := (Rank < 7) and (GetRankPointsToNextRank = 0);
end;
{ @end $7432FC }

{ @routine $74331C TNormalShip_GetPirateRankName }
function TNormalShip.GetPirateRankName: WideString;
begin Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank] + '.Name'); end;
{ @end $74331C }

{ @routine $7433B4 TNormalShip_GetPirateRankLongName }
function TNormalShip.GetPirateRankLongName: WideString;
begin
  Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank] + '.NameBig');
end;
{ @end $7433B4 }

{ @routine $743454 TNormalShip_GetPirateRankDescription }
function TNormalShip.GetPirateRankDescription: WideString;
begin
  Result := LocalizedColorText('RankPirate.' + PirateRankNames[PirateRank] + '.Text');
end;
{ @end $743454 }

{ @routine $7434EC TNormalShip_GetNextPirateRankName }
function TNormalShip.GetNextPirateRankName: WideString;
begin Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank + 1] + '.Name'); end;
{ @end $7434EC }

{ @routine $743588 TNormalShip_GetPirateRankPointsToNextRank }
function TNormalShip.GetPirateRankPointsToNextRank: Word;
begin
  if (PirateRank < 7) and (PirateRankPointThresholds[PirateRank] > PirateRankPoints) then
    Result := PirateRankPointThresholds[PirateRank] - PirateRankPoints
  else Result := 0;
end;
{ @end $743588 }

{ @routine $7435C8 TNormalShip_AddPirateRankPoints }
procedure TNormalShip.AddPirateRankPoints(Amount: Cardinal);
var
  Needed: Integer;
begin
  Needed := GetPirateRankPointsToNextRank;
  Inc(PirateRankPoints, Min(Amount, Needed));
end;
{ @end $7435C8 }

{ @routine $74361C TNormalShip_TryPromotePirateRank }
function TNormalShip.TryPromotePirateRank: Boolean;
begin
  if (PirateRank < 7) and (GetPirateRankPointsToNextRank = 0) then
  begin
    Inc(PirateRank);
    if GetPlayer = Self then GetPlayer.AchievementStats.CheckBaronAchievement;
    PirateRankPoints := 0;
    Result := True;
  end
  else Result := False;
end;
{ @end $74361C }

{ @routine $743664 TNormalShip_CanPromotePirateRank }
function TNormalShip.CanPromotePirateRank: Boolean;
begin Result := (PirateRank < 7) and (GetPirateRankPointsToNextRank = 0); end;
{ @end $743664 }

{ @routine $7437E0 TNormalShip_SelectSituationalMessage }
function TNormalShip.SelectSituationalMessage(Automatic: Boolean): WideString;
var
  Definitions: array of TShipGreetingsInfo;
  LastIndex: Integer;
  SwapA, SwapB: TShipGreetingsInfo;
  ItemTypes, MessageText, BestText: WideString;
  I, J, K, Count, Minimum, EntryIndex, BestPriority, CandidatePriority: Integer;
  Good: Byte;
  Rejected: Boolean;
  Planet: TPlanet;
  Item: TItem;
  ShipKind: TShipType;
  CountMask: TGreetingCountMask;
  Other: TShip;
  // @nested $7436A8 ShuffleDefinitions
  procedure ShuffleDefinitions; // @addr $7436A8 @note "Nested helper; caller-popped static link. Copies definitions and swaps the first half against deterministic random positions."
  var I, OtherIndex: Integer;
  begin
    SetLength(Definitions, ShipGreetingCount);
    for I := 0 to LastIndex do Definitions[I] := ShipGreetingDefinitions[I];
    for I := 0 to LastIndex div 2 do begin
      OtherIndex := SeededRandomIntRange(0, LastIndex, Seed + 7 * I);
      SwapA := Definitions[OtherIndex];
      SwapB := Definitions[I];
      Definitions[I] := SwapA;
      Definitions[OtherIndex] := SwapB;
    end;
  end;
begin
  BestText := '';
  if (GetPlayer = PartnerShip) or GetPlayer.ChameleonActive or HasIndependentScriptFaction then begin Result := ''; Exit; end;
  ItemTypes := '';
  BestPriority := -1;
  CandidatePriority := -1;
  Minimum := 0;
  LastIndex := ShipGreetingCount - 1;
  ShuffleDefinitions;
  EntryIndex := SeededRandomIntRange(0, LastIndex, Integer(Seed * Cardinal(Galaxy.CurrentTurn)) div 20);
  for I := 0 to LastIndex do begin
    MessageText := '';
    IncrementWrapped(EntryIndex, Minimum, LastIndex);
    if IsFemaleHumanPilot <> (Definitions[EntryIndex].Female = 0) then Continue;
    if (Definitions[EntryIndex].CoalitionAlreadyDefeated <> greeting_match_any) and (((Definitions[EntryIndex].CoalitionAlreadyDefeated = greeting_match_true) and (not (Galaxy.CoalitionDefeatedTurn <> 0))) or ((Definitions[EntryIndex].CoalitionAlreadyDefeated = greeting_match_false) and (Galaxy.CoalitionDefeatedTurn <> 0))) then Continue;
    if (Definitions[EntryIndex].DominatorsAlreadyDefeated <> greeting_match_any) then begin
      if ((Definitions[EntryIndex].DominatorsAlreadyDefeated = greeting_match_true) and (not (not Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron])))) then Continue;
      if ((Definitions[EntryIndex].DominatorsAlreadyDefeated = greeting_match_false) and (not Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]))) then Continue;
    end;
    if BestPriority > 0 then begin
      CandidatePriority := Definitions[EntryIndex].Priority;
      if CandidatePriority * SeededRandomIntRange(1, 100, Seed + EntryIndex * (Galaxy.CurrentTurn div 20)) <
        BestPriority * SeededRandomIntRange(1, 100, Seed + EntryIndex * (Galaxy.CurrentTurn div 20) * 3) then Continue;
    end;
    Good := NoGreetingGoods;
    if Definitions[EntryIndex].Goods <> UnspecifiedGoods then Good := Definitions[EntryIndex].Goods;
    if (Definitions[EntryIndex].AutoTalk <> greeting_match_any) then begin
      if (Automatic and (Definitions[EntryIndex].AutoTalk = greeting_match_false)) then Continue;
      if (not Automatic and (Definitions[EntryIndex].AutoTalk = greeting_match_true)) then Continue;
    end;
    if Definitions[EntryIndex].FlyType = greeting_flight_any then MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text')
    else begin
      if Definitions[EntryIndex].FlyType = greeting_flight_to_planet then begin
        if not (OrderTarget is TPlanet) then Continue;
        Planet := OrderTarget as TPlanet;
        if not (Planet.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) then Continue;
        if CurrentStar.Status.CustomFaction <> '' then Continue;
        if (Definitions[EntryIndex].ToPlanetRace <> []) and not (Planet.RaceId in Definitions[EntryIndex].ToPlanetRace) then Continue;
        if (Definitions[EntryIndex].ToPlanetRelations <> []) and not (Planet.GetRelationLevelToShip(GetPlayer) in Definitions[EntryIndex].ToPlanetRelations) then Continue;
        if Good <> NoGreetingGoods then begin
          if (Definitions[EntryIndex].ToPlanetGoodsCnt <> []) and not (Galaxy.ClassifyGoodsQuantity(Planet.Goods[Good].Count, Good) in Definitions[EntryIndex].ToPlanetGoodsCnt) then Continue;
          if (Definitions[EntryIndex].ToPlanetGoodsSale <> []) and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsPurchasePrice(Good, Planet), Good) in Definitions[EntryIndex].ToPlanetGoodsSale) then Continue;
          if (Definitions[EntryIndex].ToPlanetGoodsBuy <> []) and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsSellPrice(Good, Planet), Good) in Definitions[EntryIndex].ToPlanetGoodsBuy) then Continue;
        end;
        if (Definitions[EntryIndex].ToPlanetIsHomePlanet <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].ToPlanetIsHomePlanet = greeting_match_true) and (not (HomePlanet = Planet))) then Continue;
          if ((Definitions[EntryIndex].ToPlanetIsHomePlanet = greeting_match_false) and (HomePlanet = Planet)) then Continue;
        end;
        if (Definitions[EntryIndex].ToPlanetRaceIsShipRace <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].ToPlanetRaceIsShipRace = greeting_match_true) and (not (Planet.RaceId = PilotRace))) then Continue;
          if ((Definitions[EntryIndex].ToPlanetRaceIsShipRace = greeting_match_false) and (Planet.RaceId = PilotRace)) then Continue;
        end;
        if (Definitions[EntryIndex].ToPlanetRaceIsPlayerRace <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].ToPlanetRaceIsPlayerRace = greeting_match_true) and (not (GetPlayer.PilotRace = Planet.RaceId))) then Continue;
          if ((Definitions[EntryIndex].ToPlanetRaceIsPlayerRace = greeting_match_false) and (GetPlayer.PilotRace = Planet.RaceId)) then Continue;
        end;
        if (Definitions[EntryIndex].ToPlanetEconomy <> []) and not (Planet.Economy in Definitions[EntryIndex].ToPlanetEconomy) then Continue;
        if (Definitions[EntryIndex].ToPlanetGovernment <> []) and not (Planet.Government in Definitions[EntryIndex].ToPlanetGovernment) then Continue;
        if (Definitions[EntryIndex].ToPlanetIsLastPlanet <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].ToPlanetIsLastPlanet = greeting_match_true) and (not (LastDockedPlanet = Planet))) then Continue;
          if ((Definitions[EntryIndex].ToPlanetIsLastPlanet = greeting_match_false) and (LastDockedPlanet = Planet)) then Continue;
        end;
        if Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace <> greeting_match_any then begin
          if not (LastDockedPlanet.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) then Continue;
          if (((Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace = greeting_match_true) and (not (Planet.RaceId = LastDockedPlanet.RaceId))) or ((Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace = greeting_match_false) and (Planet.RaceId = LastDockedPlanet.RaceId))) then Continue;
        end;
        MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
        MessageText := ReplaceColoredToken(MessageText, '<ToPlanet>', Planet.Name + GetLocalObjectLink(Planet, Automatic), TextHighlightColorTag);
        if Good <> NoGreetingGoods then begin
          MessageText := ReplaceColoredToken(MessageText, '<ToPlanetGoodsSale>', IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, Planet)), TextHighlightColorTag);
          MessageText := ReplaceColoredToken(MessageText, '<ToPlanetGoodsBuy>', IntToStr(GetPlayer.ShopGoodsSellPrice(Good, Planet)), TextHighlightColorTag);
        end;
      end else if Definitions[EntryIndex].FlyType = greeting_flight_to_star then begin
        if not (OrderTarget is TStar) then Continue;
        if (Definitions[EntryIndex].HomePlanetInToStar <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].HomePlanetInToStar = greeting_match_true) and (not (HomePlanet.CurrentStar = OrderTarget))) then Continue;
          if ((Definitions[EntryIndex].HomePlanetInToStar = greeting_match_false) and (HomePlanet.CurrentStar = OrderTarget)) then Continue;
        end;
        if (Definitions[EntryIndex].HomePlanetInCurStar <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].HomePlanetInCurStar = greeting_match_true) and (not (HomePlanet.CurrentStar = CurrentStar))) then Continue;
          if ((Definitions[EntryIndex].HomePlanetInCurStar = greeting_match_false) and (HomePlanet.CurrentStar = CurrentStar)) then Continue;
        end;
        Rejected := False;
        for ShipKind := ship_dominator to ship_warrior do begin
          case ShipKind of
            ship_dominator: CountMask := Definitions[EntryIndex].KlingInToStar;
            ship_ranger: CountMask := Definitions[EntryIndex].RangerInToStar;
            ship_pirate: CountMask := Definitions[EntryIndex].PirateInToStar;
            ship_warrior: CountMask := Definitions[EntryIndex].WarriorInToStar;
            ship_transport: CountMask := Definitions[EntryIndex].TransportInToStar;
          end;
          if CountMask <> [] then begin
            Count := 0;
            for K := 0 to (OrderTarget as TStar).Ships.Count - 1 do begin
              Other := (OrderTarget as TStar).Ships[K];
              if not Other.HasScriptStateText and (Other.TypeNameOverrideKey = '') and (Other.TypeId = ShipKind) then Inc(Count);
            end;
            Count := Min(10, Count);
            if not (Cardinal(Count) in CountMask) then begin Rejected := True; Break; end;
          end;
        end;
        if Rejected then Continue;
        if Definitions[EntryIndex].ToStarControlByKling <> greeting_match_any then begin
          if (OrderTarget as TStar).Status.CustomFaction <> '' then Continue;
          if (((Definitions[EntryIndex].ToStarControlByKling = greeting_match_true) and (not ((OrderTarget as TStar).ControlFaction = faction_dominators))) or ((Definitions[EntryIndex].ToStarControlByKling = greeting_match_false) and ((OrderTarget as TStar).ControlFaction = faction_dominators))) then Continue;
        end;
        if Definitions[EntryIndex].ToStarControlByPirates <> greeting_match_any then begin
          if (OrderTarget as TStar).Status.CustomFaction <> '' then Continue;
          if (((Definitions[EntryIndex].ToStarControlByPirates = greeting_match_true) and (not ((OrderTarget as TStar).ControlFaction = faction_pirates))) or ((Definitions[EntryIndex].ToStarControlByPirates = greeting_match_false) and ((OrderTarget as TStar).ControlFaction = faction_pirates))) then Continue;
        end;
        if (Definitions[EntryIndex].ToStarInBattle <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].ToStarInBattle = greeting_match_true) and (not ((OrderTarget as TStar).Battle <> 0))) then Continue;
          if ((Definitions[EntryIndex].ToStarInBattle = greeting_match_false) and ((OrderTarget as TStar).Battle <> 0)) then Continue;
        end;
        MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
        MessageText := ReplaceColoredToken(MessageText, '<ToStar>', (OrderTarget as TStar).Name, TextHighlightColorTag);
      end else if Definitions[EntryIndex].FlyType = greeting_flight_to_item then begin
        if (Order <> order_move) or not OrderAbsolute then Continue;
        Rejected := False;
        Item := nil;
        for J := 0 to CurrentStar.Items.Count - 1 do begin
          Item := CurrentStar.Items[J];
      // Native accepts either matching coordinate, rather than requiring both.
          if (GetPickupApproachPosition(Item.Position).X = OrderDestination.X) or
            (GetPickupApproachPosition(Item.Position).Y = OrderDestination.Y) then begin
            ItemTypes := Definitions[EntryIndex].ItemType;
            if (ItemTypes = '') or (ItemTypes = 'Any') or (FindTextPosW(Item.GetCategoryConfigName, ItemTypes) <> 0) then begin
              if (Definitions[EntryIndex].ShipNeedInItem <> greeting_match_any) then begin
                if ((Definitions[EntryIndex].ShipNeedInItem = greeting_match_true) and not ShouldPickUpItem(Item)) then Continue;
                if ((Definitions[EntryIndex].ShipNeedInItem = greeting_match_false) and ShouldPickUpItem(Item)) then Continue;
              end;
              Rejected := True;
              Break;
            end;
          end;
        end;
        if not Rejected then Continue;
        MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
        MessageText := ReplaceColoredToken(MessageText, '<Item>', Item.GetDisplayName + GetLocalObjectLink(Item, Automatic), TextHighlightColorTag);
      end else if Definitions[EntryIndex].FlyType = greeting_flight_to_ship then begin
        if not (OrderTarget is TShip) then Continue;
        if (Definitions[EntryIndex].ToShipType <> []) and not ((OrderTarget as TShip).GetGreetingShipCategory in Definitions[EntryIndex].ToShipType) then Continue;
        if (Definitions[EntryIndex].ToShipRace <> []) and not ((OrderTarget as TShip).PilotRace in Definitions[EntryIndex].ToShipRace) then Continue;
        if (Definitions[EntryIndex].ToShipInPlanet <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].ToShipInPlanet = greeting_match_true) and (not ((OrderTarget as TShip).CurrentPlanet <> nil))) then Continue;
          if ((Definitions[EntryIndex].ToShipInPlanet = greeting_match_false) and ((OrderTarget as TShip).CurrentPlanet <> nil)) then Continue;
        end;
        if (Definitions[EntryIndex].ToShipBad <> greeting_match_any) then begin
          if ((Definitions[EntryIndex].ToShipBad = greeting_match_true) and (not ((OrderTarget as TShip).EnemyShip = Self))) then Continue;
          if ((Definitions[EntryIndex].ToShipBad = greeting_match_false) and ((OrderTarget as TShip).EnemyShip = Self)) then Continue;
        end;
        if (Definitions[EntryIndex].ToShipRelations <> []) and not (GetRelationLevelToShip(OrderTarget as TShip) in Definitions[EntryIndex].ToShipRelations) then Continue;
        MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
        MessageText := ReplaceColoredToken(MessageText, '<ToShip>', (OrderTarget as TShip).GetName + GetLocalObjectLink(OrderTarget, Automatic), TextHighlightColorTag);
        MessageText := ReplaceColoredToken(MessageText, '<ToFullShip>', (OrderTarget as TShip).GetFullName(' ') + GetLocalObjectLink(OrderTarget, Automatic), TextHighlightColorTag);
        if (OrderTarget as TShip).CurrentPlanet <> nil then begin
          MessageText := ReplaceColoredToken(MessageText, '<ToShipInPlanet>', (OrderTarget as TShip).CurrentPlanet.GetFullName(' ') + GetLocalObjectLink((OrderTarget as TShip).CurrentPlanet, Automatic), TextHighlightColorTag);
        end;
      end;
    end;
    if (Definitions[EntryIndex].ShipType <> []) and not (GetGreetingShipCategory in Definitions[EntryIndex].ShipType) then Continue;
    if (Definitions[EntryIndex].Relations <> []) and not (GetRelationLevelToShip(GetPlayer) in Definitions[EntryIndex].Relations) then Continue;
    if (Definitions[EntryIndex].ShipRace <> []) and not (PilotRace in Definitions[EntryIndex].ShipRace) then Continue;
    if (Definitions[EntryIndex].PlayerRace <> []) and not (GetPlayer.PilotRace in Definitions[EntryIndex].PlayerRace) then Continue;
    if (Definitions[EntryIndex].ShipRaceIsPlayerRace <> greeting_match_any) then begin
      if ((Definitions[EntryIndex].ShipRaceIsPlayerRace = greeting_match_true) and (not (GetPlayer.PilotRace = PilotRace))) then Continue;
      if ((Definitions[EntryIndex].ShipRaceIsPlayerRace = greeting_match_false) and (GetPlayer.PilotRace = PilotRace)) then Continue;
    end;
    if Definitions[EntryIndex].PlayerAttackGoodShip <> greeting_match_any then begin
      if GetPlayer.OrderTarget is TShip then begin
        Other := GetPlayer.OrderTarget as TShip;
        Rejected := (Other is TNormalShip) and (GetPlayer <> Other.OrderTarget) and
          (GetRelationLevelToShip(Other) = relation_level_excellent) and (Other.GetRelationLevelToShip(GetPlayer) = relation_level_hostile);
      end else Rejected := False;
      if Definitions[EntryIndex].PlayerAttackGoodShip = greeting_match_false then
        if Rejected then Continue;
      if (Definitions[EntryIndex].PlayerAttackGoodShip = greeting_match_true) and not Rejected then Continue;
      if Rejected then begin
        MessageText := ReplaceColoredToken(MessageText, '<FullShipGood>', (GetPlayer.OrderTarget as TShip).GetFullName(' ') + GetLocalObjectLink(GetPlayer.OrderTarget, Automatic), '');
      end;
    end;
    if (Definitions[EntryIndex].InFear <> greeting_match_any) then begin
      if ((Definitions[EntryIndex].InFear = greeting_match_true) and (not (InFear))) then Continue;
      if ((Definitions[EntryIndex].InFear = greeting_match_false) and (InFear)) then Continue;
    end;
    if Definitions[EntryIndex].ShipBadFlyToShip <> greeting_match_any then begin
      Rejected := IsEnemyPursuingSelf;
      if (((Definitions[EntryIndex].ShipBadFlyToShip = greeting_match_true) and (not (Rejected))) or ((Definitions[EntryIndex].ShipBadFlyToShip = greeting_match_false) and (Rejected))) then Continue;
    end;
    if (Definitions[EntryIndex].ShipBadType <> []) and (EnemyShip <> nil) and not (EnemyShip.GetGreetingShipCategory in Definitions[EntryIndex].ShipBadType) then Continue;
    if (Definitions[EntryIndex].ShipBadRace <> []) and (EnemyShip <> nil) and not (EnemyShip.PilotRace in Definitions[EntryIndex].ShipBadRace) then Continue;
    if (Definitions[EntryIndex].ShipFlyToPlayer <> greeting_match_any) then begin
      if ((Definitions[EntryIndex].ShipFlyToPlayer = greeting_match_true) and (not (GetPlayer = OrderTarget))) then Continue;
      if ((Definitions[EntryIndex].ShipFlyToPlayer = greeting_match_false) and (GetPlayer = OrderTarget)) then Continue;
    end;
    if (Definitions[EntryIndex].PlayerFlyToShip <> greeting_match_any) then begin
      if ((Definitions[EntryIndex].PlayerFlyToShip = greeting_match_true) and (not (GetPlayer.OrderTarget = Self))) then Continue;
      if ((Definitions[EntryIndex].PlayerFlyToShip = greeting_match_false) and (GetPlayer.OrderTarget = Self)) then Continue;
    end;
    if (Definitions[EntryIndex].PlayerIsShipBad <> greeting_match_any) then begin
      if ((Definitions[EntryIndex].PlayerIsShipBad = greeting_match_true) and (not (GetPlayer = EnemyShip))) then Continue;
      if ((Definitions[EntryIndex].PlayerIsShipBad = greeting_match_false) and (GetPlayer = EnemyShip)) then Continue;
    end;
    if (Definitions[EntryIndex].ShipTurnBeforeEndOrder <> []) then begin
      Count := Min(10, EstimateOrderTravelTurns);
      if not (Cardinal(Count) in Definitions[EntryIndex].ShipTurnBeforeEndOrder) then Continue;
    end;
    if (Definitions[EntryIndex].PlayerTurnBeforeEndOrder <> []) then begin
      Count := Min(10, GetPlayer.EstimateOrderTravelTurns);
      if not (Cardinal(Count) in Definitions[EntryIndex].PlayerTurnBeforeEndOrder) then Continue;
    end;
    if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then
      if Definitions[EntryIndex].ShipBadTurnBeforeEndOrder <> [] then begin
        Count := Min(10, EnemyShip.EstimateOrderTravelTurns);
        if not (Cardinal(Count) in Definitions[EntryIndex].ShipBadTurnBeforeEndOrder) then Continue;
      end;
    if (Self is TRanger) and (Definitions[EntryIndex].ShipStatus <> []) and not ((Self as TRanger).GetDominantCareer in Definitions[EntryIndex].ShipStatus) then Continue;
    if (Definitions[EntryIndex].PlayerStatus <> []) and not (GetPlayer.GetDominantCareer in Definitions[EntryIndex].PlayerStatus) then Continue;
    if (Definitions[EntryIndex].ShipStrength <> []) and not (GetRelativeStrengthCategory in Definitions[EntryIndex].ShipStrength) then Continue;
    if (Definitions[EntryIndex].PlayerStrength <> []) and not (GetPlayer.GetRelativeStrengthCategory in Definitions[EntryIndex].PlayerStrength) then Continue;
    if (Definitions[EntryIndex].ShipStructure <> []) and not (GetHullConditionCategory in Definitions[EntryIndex].ShipStructure) then Continue;
    if (Definitions[EntryIndex].PlayerStructure <> []) and not (GetPlayer.GetHullConditionCategory in Definitions[EntryIndex].PlayerStructure) then Continue;
    if (Self is TRanger) and not (Self as TRanger).ExcludedFromRating and (Definitions[EntryIndex].ShipRating <> []) and not (GetRangerRatingBand in Definitions[EntryIndex].ShipRating) then Continue;
    if (Definitions[EntryIndex].PlayerRating <> []) and not (GetPlayer.GetRangerRatingBand in Definitions[EntryIndex].PlayerRating) then Continue;
    if (Definitions[EntryIndex].ShipRank <> []) and not (Rank in Definitions[EntryIndex].ShipRank) then Continue;
    if (Definitions[EntryIndex].PlayerRank <> []) and not (GetPlayer.Rank in Definitions[EntryIndex].PlayerRank) then Continue;
    if (Definitions[EntryIndex].PlayerPirateRank <> []) and not (GetPlayer.PirateRank in Definitions[EntryIndex].PlayerPirateRank) then Continue;
    if (Self is TRanger) and not (Self as TRanger).ExcludedFromRating and (Definitions[EntryIndex].RatingShipWithPlayer <> []) and not (GetPlayer.GetShipRatingComparison(Self) in Definitions[EntryIndex].RatingShipWithPlayer) then Continue;
    if (Definitions[EntryIndex].RankShipWithPlayer <> []) and not (GetPlayer.GetShipRankComparison(Self) in Definitions[EntryIndex].RankShipWithPlayer) then Continue;
    if (Definitions[EntryIndex].RankShipWithPlayerExtra <> []) and not (GetPlayer.GetShipPirateRankComparison(Self) in Definitions[EntryIndex].RankShipWithPlayerExtra) then Continue;
    if (Definitions[EntryIndex].StrengthShipWithPlayer <> []) and not (GetPlayer.GetShipStrengthComparison(Self) in Definitions[EntryIndex].StrengthShipWithPlayer) then Continue;
    if Good <> NoGreetingGoods then begin
      if (Definitions[EntryIndex].ShipGoodsCnt <> []) and not (Galaxy.ClassifyGoodsQuantity(CargoGoods[Good].Count, Good) in Definitions[EntryIndex].ShipGoodsCnt) then Continue;
      if (Definitions[EntryIndex].PlayerGoodsCnt <> []) and not (Galaxy.ClassifyGoodsQuantity(GetPlayer.CargoGoods[Good].Count, Good) in Definitions[EntryIndex].PlayerGoodsCnt) then Continue;
      if (Definitions[EntryIndex].ShipHaveGoods <> greeting_match_any) then begin
        if ((Definitions[EntryIndex].ShipHaveGoods = greeting_match_true) and (CargoGoods[Good].Count = 0)) then Continue;
        if ((Definitions[EntryIndex].ShipHaveGoods = greeting_match_false) and (CargoGoods[Good].Count > 0)) then Continue;
      end;
      if (Definitions[EntryIndex].PlayerHaveGoods <> greeting_match_any) then begin
        if ((Definitions[EntryIndex].PlayerHaveGoods = greeting_match_true) and (GetPlayer.CargoGoods[Good].Count = 0)) then Continue;
        if ((Definitions[EntryIndex].PlayerHaveGoods = greeting_match_false) and (GetPlayer.CargoGoods[Good].Count > 0)) then Continue;
      end;
    end;
    if (Definitions[EntryIndex].ShipGoodsTypeCnt <> []) and not (CountCargoGoodsTypes in Definitions[EntryIndex].ShipGoodsTypeCnt) then Continue;
    if (Definitions[EntryIndex].PlayerGoodsTypeCnt <> []) and not (GetPlayer.CountCargoGoodsTypes in Definitions[EntryIndex].PlayerGoodsTypeCnt) then Continue;
    if (Definitions[EntryIndex].ShipMayScanPlayer <> greeting_match_any) then begin
      if ((Definitions[EntryIndex].ShipMayScanPlayer = greeting_match_true) and (not (CanResolveObjectWithScanner(GetPlayer) and (GetRadarRange > 0)))) then Continue;
      if ((Definitions[EntryIndex].ShipMayScanPlayer = greeting_match_false) and (CanResolveObjectWithScanner(GetPlayer) and (GetRadarRange > 0))) then Continue;
    end;
    Rejected := False;
    for ShipKind := ship_dominator to ship_warrior do begin
      case ShipKind of
        ship_dominator: CountMask := Definitions[EntryIndex].KlingInCurStar;
        ship_ranger: CountMask := Definitions[EntryIndex].RangerInCurStar;
        ship_pirate: CountMask := Definitions[EntryIndex].PirateInCurStar;
        ship_warrior: CountMask := Definitions[EntryIndex].WarriorInCurStar;
        ship_transport: CountMask := Definitions[EntryIndex].TransportInCurStar;
      end;
      if CountMask <> [] then begin
        Count := 0;
        for K := 0 to CurrentStar.Ships.Count - 1 do begin
          Other := CurrentStar.Ships[K];
          if not Other.HasScriptStateText and (Other.TypeNameOverrideKey = '') and (Other.TypeId = ShipKind) then Inc(Count);
        end;
        Count := Min(10, Count);
        if not (Cardinal(Count) in CountMask) then begin Rejected := True; Break; end;
      end;
    end;
    if Rejected then Continue;
    if Definitions[EntryIndex].LastPlanetRace <> [] then begin
      if LastDockedPlanet = nil then Continue;
      if not (LastDockedPlanet.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) then Continue;
      if LastDockedPlanet.CurrentStar.Status.CustomFaction <> '' then Continue;
      if not (LastDockedPlanet.RaceId in Definitions[EntryIndex].LastPlanetRace) then Continue;
      if (Definitions[EntryIndex].LastPlanetRelations <> []) and not (LastDockedPlanet.GetRelationLevelToShip(GetPlayer) in Definitions[EntryIndex].LastPlanetRelations) then Continue;
      if Good <> NoGreetingGoods then begin
        if (Definitions[EntryIndex].LastPlanetGoodsCnt <> []) and not (Galaxy.ClassifyGoodsQuantity(LastDockedPlanet.Goods[Good].Count, Good) in Definitions[EntryIndex].LastPlanetGoodsCnt) then Continue;
        if (Definitions[EntryIndex].LastPlanetGoodsSale <> []) and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsPurchasePrice(Good, LastDockedPlanet), Good) in Definitions[EntryIndex].LastPlanetGoodsSale) then Continue;
        if (Definitions[EntryIndex].LastPlanetGoodsBuy <> []) and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsSellPrice(Good, LastDockedPlanet), Good) in Definitions[EntryIndex].LastPlanetGoodsBuy) then Continue;
      end;
      if (Definitions[EntryIndex].LastPlanetIsHomePlanet <> greeting_match_any) then begin
        if ((Definitions[EntryIndex].LastPlanetIsHomePlanet = greeting_match_true) and (not (LastDockedPlanet = HomePlanet))) then Continue;
        if ((Definitions[EntryIndex].LastPlanetIsHomePlanet = greeting_match_false) and (LastDockedPlanet = HomePlanet)) then Continue;
      end;
      if Definitions[EntryIndex].LastPlanetRaceIsShipRace <> greeting_match_any then begin
        if not (LastDockedPlanet.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) then Continue;
        if (((Definitions[EntryIndex].LastPlanetRaceIsShipRace = greeting_match_true) and (not (LastDockedPlanet.RaceId = PilotRace))) or ((Definitions[EntryIndex].LastPlanetRaceIsShipRace = greeting_match_false) and (LastDockedPlanet.RaceId = PilotRace))) then Continue;
      end;
      if Definitions[EntryIndex].LastPlanetRaceIsPlayerRace <> greeting_match_any then begin
        if not (LastDockedPlanet.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) then Continue;
        if (((Definitions[EntryIndex].LastPlanetRaceIsPlayerRace = greeting_match_true) and (not (GetPlayer.PilotRace = LastDockedPlanet.RaceId))) or ((Definitions[EntryIndex].LastPlanetRaceIsPlayerRace = greeting_match_false) and (GetPlayer.PilotRace = LastDockedPlanet.RaceId))) then Continue;
      end;
      if (Definitions[EntryIndex].LastPlanetEconomy <> []) and not (LastDockedPlanet.Economy in Definitions[EntryIndex].LastPlanetEconomy) then Continue;
      if (Definitions[EntryIndex].LastPlanetGovernment <> []) and not (LastDockedPlanet.Government in Definitions[EntryIndex].LastPlanetGovernment) then Continue;
      if (Definitions[EntryIndex].LastPlanetInCurStar <> greeting_match_any) then begin
        if ((Definitions[EntryIndex].LastPlanetInCurStar = greeting_match_true) and (not (LastDockedPlanet.CurrentStar = CurrentStar))) then Continue;
        if ((Definitions[EntryIndex].LastPlanetInCurStar = greeting_match_false) and (LastDockedPlanet.CurrentStar = CurrentStar)) then Continue;
      end;
      if Definitions[EntryIndex].LastPlanetDistToShipInTurn <> [] then begin
        Count := Min(10, EstimateTravelTurnsToPlanet(LastDockedPlanet));
        if Count = -1 then Continue;
        if not (Cardinal(Count) in Definitions[EntryIndex].LastPlanetDistToShipInTurn) then Continue;
      end;
      if LastDockedPlanet.CurrentStar <> CurrentStar then begin
        Rejected := False;
        for ShipKind := ship_dominator to ship_warrior do begin
          case ShipKind of
            ship_dominator: CountMask := Definitions[EntryIndex].KlingInLastPlanetStar;
            ship_ranger: CountMask := Definitions[EntryIndex].RangerInLastPlanetStar;
            ship_pirate: CountMask := Definitions[EntryIndex].PirateInLastPlanetStar;
            ship_warrior: CountMask := Definitions[EntryIndex].WarriorInLastPlanetStar;
            ship_transport: CountMask := Definitions[EntryIndex].TransportInLastPlanetStar;
          end;
          if CountMask <> [] then begin
            Count := 0;
            for K := 0 to LastDockedPlanet.CurrentStar.Ships.Count - 1 do begin
              Other := LastDockedPlanet.CurrentStar.Ships[K];
              if not Other.HasScriptStateText and (Other.TypeNameOverrideKey = '') and (Other.TypeId = ShipKind) then Inc(Count);
            end;
            Count := Min(10, Count);
            if not (Cardinal(Count) in CountMask) then begin Rejected := True; Break; end;
          end;
        end;
        if Rejected then Continue;
      end;
      MessageText := ReplaceColoredToken(MessageText, '<LastPlanet>', LastDockedPlanet.Name + GetLocalObjectLink(LastDockedPlanet, Automatic), TextHighlightColorTag);
      MessageText := ReplaceColoredToken(MessageText, '<LastPlanetStar>', LastDockedPlanet.CurrentStar.Name, TextHighlightColorTag);
      if Good <> NoGreetingGoods then begin
        MessageText := ReplaceColoredToken(MessageText, '<LastPlanetGoodsSale>', IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, LastDockedPlanet)), TextHighlightColorTag);
        MessageText := ReplaceColoredToken(MessageText, '<LastPlanetGoodsBuy>', IntToStr(GetPlayer.ShopGoodsSellPrice(Good, LastDockedPlanet)), TextHighlightColorTag);
      end;
    end;
    if MessageText = '' then Continue;
    MessageText := ReplaceColoredToken(MessageText, '<Ship>', GetName + GetLocalObjectLink(Self, Automatic), TextHighlightColorTag);
    MessageText := ReplaceColoredToken(MessageText, '<FullShip>', GetFullName(' ') + GetLocalObjectLink(Self, Automatic), TextHighlightColorTag);
    if EnemyShip <> nil then begin
      MessageText := ReplaceColoredToken(MessageText, '<ShipBad>', EnemyShip.GetName + GetLocalObjectLink(EnemyShip, Automatic), TextHighlightColorTag);
      MessageText := ReplaceColoredToken(MessageText, '<FullShipBad>', EnemyShip.GetFullName(' ') + GetLocalObjectLink(EnemyShip, Automatic), TextHighlightColorTag);
    end;
    MessageText := ReplaceColoredToken(MessageText, '<ShipRank>', GetRankName, TextHighlightColorTag);
    MessageText := ReplaceColoredToken(MessageText, '<PlayerRank>', GetPlayer.GetRankName, TextHighlightColorTag);
    MessageText := ReplaceColoredToken(MessageText, '<CurStar>', CurrentStar.Name, TextHighlightColorTag);
    if HomePlanet <> nil then begin
      MessageText := ReplaceColoredToken(MessageText, '<HomePlanet>', HomePlanet.Name + GetLocalObjectLink(HomePlanet, Automatic), TextHighlightColorTag);
      MessageText := ReplaceColoredToken(MessageText, '<HomePlanetStar>', HomePlanet.CurrentStar.Name, TextHighlightColorTag);
    end;
    BestText := MessageText;
    if CandidatePriority = -1 then BestPriority := Definitions[EntryIndex].Priority else BestPriority := CandidatePriority;
    if BestPriority >= 50 then Break;
  end;
  Result := BestText;
end;
{ @end $7437E0 }

{ @routine $746EE4 TNormalShip_UpdateAfterburnerState }
procedure TNormalShip.UpdateAfterburnerState;
begin
  AfterburnerActive := (GetSlotCount(slot_afterburner) > 0) and (GetEngine <> nil) and (GetEngine.ConditionPercent > 10) and (EstimateOrderTravelTurns > 1);
  RefreshDerivedStats(True);
end;
{ @end $746EE4 }

{ @routine $746F3C TNormalShip_TrainSkillsAutomatically }
procedure TNormalShip.TrainSkillsAutomatically;
var
  Score, BestScore: Single;
  Skill, BestSkill: TPilotSkill;
  Bonus: TEquipmentBonusKind;
begin
  repeat
    BestScore := -1;
    BestSkill := skill_accuracy;
    for Bonus := bonus_accuracy to bonus_leadership do
    begin
      Skill := EquipmentBonusSkills[Bonus];
      if BaseSkills[Skill] < 6 then
      begin
        Score := Sqr(EvaluateStatBonus(Bonus, 1)) / SkillTrainingCosts[BaseSkills[Skill] + 1, Skill];
        if Score > BestScore then
        begin
          BestScore := Score;
          BestSkill := Skill;
        end;
      end;
    end;
    if (BestScore < 0) then Break;
    if (SkillTrainingCosts[BaseSkills[BestSkill] + 1, BestSkill] > FreeExperience) then Break;
  until not TrainSkill(BestSkill);
end;
{ @end $746F3C }

end.
