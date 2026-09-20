unit aNormalShip;
// Unit bracket (inferred): .text 0x0073D7BC..0x00747B75; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_BlockPar, aGalaxyStruct, aConst, aGalaxy, aPlanet, aShip;

type
  TAwardTypeMask = set of 0..7; // @size $01

  TSystemKillCountArray = array[0..3] of Word; // @size $08

  TSystemKillCounts = packed record // @size 0x08
    Normal: Word; // @offset 0x00
    Dominator: Word; // @offset 0x02
    Pirate: Word; // @offset 0x04
    Custom: Word; // @offset 0x06
  end;

  TNormalShip = class(TShip) // @size 0x510
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
    Rank: Byte; // @offset 0x500
    RankPoints: Word; // @offset 0x502
    LastPlayerExtortionTurn: Integer; // @offset 0x504  Shared 30-turn cooldown for money, cargo and paid-truce demands.
    PirateRank: Byte; // @offset 0x508
    PirateRankPoints: Cardinal; // @offset 0x50C

    procedure ClearObjectReferences; override; // @addr $73DE90 @slot $0C Clears pending liberation and last-docked planet after inherited cleanup.
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr $73DEB8 @slot $10
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $73E0F8 @slot $14 Native editable import truncates PirateRankPoints to Word.
    procedure CheckKillCountAwards(Victim: TShip); // @addr $742F74
    function SelectAward(Owner: Byte; Kinds: TAwardTypeMask; VictimTypes: TShipTypeMask): Byte; // @addr $7431AC @ida "unsigned __int8 __userpurge $name@<al>(TNormalShip *Self@<eax>, unsigned __int8 Owner@<dl>, unsigned __int8 Kinds@<cl>, unsigned __int16 VictimTypes@<^0>);" @note "Returns 255 when no award qualifies; retries duplicates twice."
    procedure ProcessShipKill(Victim: TShip); // @addr $740018 Distributes kill rewards, career/rank changes and event counters.
    function CollectLiberationRewards: WideString; // @addr $73E710 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Consumes the pending ceremony, grants rewards and returns the player's presentation text."
    function SelectSituationalMessage(Automatic: Boolean): WideString; // @addr $74414C @ida "void __usercall $name(TNormalShip *Self@<eax>, bool Automatic@<dl>, unsigned __int16 **Result@<ecx>);" @note "Automatic messages suppress object links and select the automatic-message category."
    procedure UpdateRelationsForNearbyCombat; // @addr $742FFC Nearby rangers attacking a friend incur a penalty; attacks on an enemy can improve relations.
    procedure NextDay; override; // @addr 0x73E328 @slot 0x18
    constructor Create; // @addr 0x73D8E4 @ida "TNormalShip *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x73D9D8 @ida "void __usercall $name(TNormalShip *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x73DA40 @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x73DBDC @slot 0x04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x73DE24 @slot 0x08
    function AwardRandomMedal: WideString; // @addr $73FE40 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);" Selects a merit award using the current planet, station or default human owner and returns its name.
    function GetPirateRankName: WideString; // @addr $743BC4 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetNextPirateRankName: WideString; // @addr $743DB8 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);" Does not check maximum rank.
    function CanPromotePirateRank: Boolean; // @addr $743F88
    procedure UpdateAfterburnerState; override; // @addr $747A14 @slot $9C Enables afterburner for multi-turn orders with a serviceable engine.
    procedure TrainSkillsAutomatically; // @addr 0x747A78

    function GetAwardInfo(AwardId: Byte): TRewardInfo; // @addr 0x7435A0 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int8 AwardId@<dl>, TRewardInfo *Result@<ecx>);"
    function GetRankLongName: WideString; // @addr $743780 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetRankDescription: WideString; // @addr $743820 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetPirateRankLongName: WideString; // @addr $743C68 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetPirateRankDescription: WideString; // @addr $743D14 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetRankName: WideString; // @addr 0x7436E8 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetNextRankName: WideString; // @addr 0x7438B8 @ida "void __usercall $name(TNormalShip *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Does not check for maximum rank."

    function GetRankPointsToNextRank: Word; // @addr 0x743950
    procedure AddRankPoints(Amount: Word); // @addr 0x7439B8 @note "Caps the addition at the points needed for the next rank."
    function CanPromoteRank: Boolean; // @addr 0x743B90
    function TryPromoteRank: Boolean; // @addr 0x743B48 @note "Maximum rank is 7; promotion resets RankPoints."
    function GetPirateRankPointsToNextRank: Word; // @addr 0x743E5C
    procedure AddPirateRankPoints(Amount: Cardinal); // @addr 0x743EC4 @note "Caps the addition at the points needed for the next rank."
    function TryPromotePirateRank: Boolean; // @addr 0x743F24 @note "Maximum rank is 7; promotion resets PirateRankPoints."
  end;

procedure ProcessSystemLiberationRewards(SourceShip: TNormalShip; Star: TStar); // @addr 0x7421CC @note "Processes qualifying ships after a control change; SourceShip supplies the news-variant seed."

implementation

uses EC_Str, aGalaxyEvent, Classes, Achievements, aMyFunction, aRanger, GlobalsV, GR_Main, Math, SysUtils, aConst, aItem, aPlayer, aKling, aPirate, aTransport, aWarrior, aTranclucator, Globals;

{ @routine $73D8E4 TNormalShip_Create }
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
{ @end $73D8E4 }

{ @routine $73D9D8 TNormalShip_Destroy }
destructor TNormalShip.Destroy;
var
  Career: Byte;
begin
  for Career := 0 to 2 do
    if Galaxy.EminentCareerShips[Career] = Self then Galaxy.EminentCareerShips[Career] := nil;
  inherited Destroy;
end;
{ @end $73D9D8 }

{ @routine $73DA40 TNormalShip_SaveToBuffer }
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
{ @end $73DA40 }

{ @routine $73DBDC TNormalShip_LoadFromBuffer }
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
  if (LoadedSaveVersion < 126) and (Buffer.GetByte <> 0) then OwnerId := Byte(oiPirate);
  LastDockedPlanet := TPlanet(Buffer.GetUInt32);
  LastPlayerExtortionTurn := Buffer.GetInt32;
end;
{ @end $73DBDC }

{ @routine $73DE24 TNormalShip_ResolveLoadedReferences }
procedure TNormalShip.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  PendingLiberationCeremonyPlanet := TObject(Galaxy.IdToPlanet(Cardinal(PendingLiberationCeremonyPlanet))) as TPlanet;
  LastDockedPlanet := TObject(Galaxy.IdToPlanet(Cardinal(LastDockedPlanet))) as TPlanet;
end;
{ @end $73DE24 }

{ @routine $73DE90 TNormalShip_ClearObjectReferences }
procedure TNormalShip.ClearObjectReferences;
begin
  inherited ClearObjectReferences;
  PendingLiberationCeremonyPlanet := nil;
  LastDockedPlanet := nil;
end;
{ @end $73DE90 }

{ @routine $73DEB8 TNormalShip_SaveToBlock }
procedure TNormalShip.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Roarnuke'), WideString(IntToStr(Rank))); // Decoded: 'Rank'
  Block.AddParam(DecodeTextW('RearnaksProcitnotas'), WideString(IntToStr(RankPoints))); // Decoded: 'RankPoints'
  Block.AddParam(DecodeTextW('PlivroaktrenRiasnuk'), WideString(IntToStr(PirateRank))); // Decoded: 'PirateRank'
  Block.AddParam(DecodeTextW('PhilroaAtrelRoasnAkoPiopionatos'), WideString(IntToStr(PirateRankPoints))); // Decoded: 'PirateRankPoints'
end;
{ @end $73DEB8 }

{ @routine $73E0F8 TNormalShip_LoadFromBlock }
procedure TNormalShip.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Rank := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Roarnuke')))); // Decoded: 'Rank'
  RankPoints := StrToInt(AnsiString(Block.GetParam(DecodeTextW('RearnaksProcitnotas')))); // Decoded: 'RankPoints'
  PirateRank := StrToInt(AnsiString(Block.GetParam(DecodeTextW('PlivroaktrenRiasnuk')))); // Decoded: 'PirateRank'
  PirateRankPoints := Word(StrToInt(AnsiString(Block.GetParam(DecodeTextW('PhilroaAtrelRoasnAkoPiopionatos'))))); // Decoded: 'PirateRankPoints'
end;
{ @end $73E0F8 }

{ @routine $73E328 TNormalShip_NextDay }
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
       (Order <> soNone) and PlayerStarDayPrepared and (TurnsSinceLastShipMessage > 5) and
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
{ @end $73E328 }

{ @routine $73E710 TNormalShip_CollectLiberationRewards }
function TNormalShip.CollectLiberationRewards: WideString;
const
  RewardPrograms = [prgShipwreck..prgDisconnection];
  RewardKinds = [atLiberation, atAccomplishment];
  RewardVictims = [stKling..Ord(rstCustomStation)];
var
  I, MinimumPriority, RewardKind, Quantity, ModuleIndex, TotalPriority, Priority, Roll: Integer;
  TextBlock: TBlockParEC;
  Prefix: WideString;
  Award: Byte;
  AwardWeight, ProgramWeight, ArtefactWeight, ModuleWeight: Single;
  RewardItem: TItem;
  ProgramIndex: Byte;
  ModuleItem: TMicroModule;
  Event: TGalaxyEvent;
begin
  if AwardIds = nil then AwardWeight := 80
  else AwardWeight := RemapClamped(AwardIds.Count, 0, 15, 80, 10);
  if (Self is TRanger) and (Self as TRanger).HasProgram(prgIntercom) then
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
  if (CurrentPlanet.OwnerId = Byte(oiPirate)) and (AwardWeight > 0) then AwardWeight := 1;
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
    if CurrentPlanet.OwnerId <> Byte(oiPirate) then
    begin
      if Byte(CurrentPlanet.CurrentStar.PreviousControlFaction) = 1 then
        Result := LocalizedColorText('PlanetCongratulations.LiberationStarNormalsFromKling.' + OwnerToSys(CurrentPlanet.OwnerId) + 'Text')
      else
        Result := LocalizedColorText('PlanetCongratulations.LiberationStarNormalsFromPirateClan.' + OwnerToSys(CurrentPlanet.OwnerId) + 'Text');
    end
    else
    begin
      if Byte(CurrentPlanet.CurrentStar.PreviousControlFaction) = 0 then
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
  if CurrentPlanet.OwnerId <> Byte(oiPirate) then Prefix := 'PlanetCongratulations.LiberationAwardNormals.'
  else Prefix := 'PlanetCongratulations.LiberationAwardPirateClan.';
  case RewardKind of
    1: begin
      Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), RewardKinds, RewardVictims);
      AddAward(Award);
      if GetPlayer = Self then
      begin
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddReward');
        ReplaceTextToken(Result, '<Reward>', GetAwardInfo(Award).Name, '<color=255,240,100>');
      end
      else Result := '';
    end;
    2: if Self is TRanger then
    begin
      ProgramIndex := (Self as TRanger).SelectRandomProgramIdFromFilter(RewardPrograms);
      Quantity := SeededRandomIntRange(1,
        Round(RemapClamped((Self as TRanger).CountProgramsInFilter(RewardPrograms), 2, 10,
          GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].MaximumQuestProgramRewardCount, 1)),
        ProgramIndex + CurrentStar.GenerationSeed * (Galaxy.CurrentTurn div 25));
      Inc((Self as TRanger).ProgramCounts[ProgramIndex], Quantity);
      if GetPlayer = Self then
      begin
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddProgramms');
        ReplaceTextToken(Result, '<Programm>', (Self as TRanger).GetProgramName(ProgramIndex), '<color=255,240,100>');
        ReplaceTextToken(Result, '<Count>', IntToStr(Quantity), '<color=255,240,100>');
      end
      else Result := '';
    end;
    3: begin
      RewardItem := CreateRandomLootItem(ilpReward, CurrentPlanet.OwnerId, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 50 + 123424767);
      if RewardItem is TArtefactTranclucator then TTranclucator(TArtefactTranclucator(RewardItem).Ship).OwnerShip := Self;
      if RewardItem is TArtefact then Artefacts.Add(RewardItem)
      else Inventory.Add(RewardItem);
      if GetPlayer = Self then
      begin
        GetPlayer.ScriptItemsAct(satOnGovItemReward, RewardItem, nil, 0);
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddArtefact') + #13#10 + RewardItem.GetDescriptionText;
        ReplaceTextToken(Result, '<Artefact>', RewardItem.GetDisplayName, '<color=255,240,100>');
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
        GetPlayer.ScriptItemsAct(satOnGovItemReward, ModuleItem, nil, 0);
        Event := AddGalaxyEvent('PlayerReceivesMMAsReward');
        Event.AddData(ModuleItem.Id);
        Event.AddData(ModuleItem.MicroModuleIndex - 1);
      end;
      Inventory.Add(ModuleItem);
      if GetPlayer = Self then
      begin
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddNod') + #13#10 + ModuleItem.GetInfoText('<color=255,240,100>', nil);
        ReplaceTextToken(Result, '<Nod>', MicroModuleTemplates[ModuleIndex].Name, '<color=255,240,100>');
      end
      else Result := '';
    end;
  end;
  I := RoundAndTruncateToTens(SeededRandomIntRange(250, Galaxy.ScaleIntByTechLevel(500, 1000),
    (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 100) + Ln(PendingLiberationContribution * 0.2 + 1) * 1000);
  GainExperience(I, 0);
  if GetPlayer = Self then
  begin
    Result := Result + #13#10 + ' ' + #13#10 + WrapTextInColor(LocalizedColorText(Prefix + 'AddPoints'), '<color=45,105,45>');
    ReplaceTextToken(Result, '<Points>', IntToStr(I), '');
  end
  else Result := '';
  if GetPlayer = Self then
  begin
    ReplaceTextToken(Result, '<Star>', CurrentPlanet.CurrentStar.Name, '<color=255,240,100>');
    ReplaceTextToken(Result, '<Planet>', CurrentPlanet.Name, '<color=255,240,100>');
  end;
  PendingLiberationCeremonyPlanet := nil;
  PendingLiberationContribution := 0;
end;
{ @end $73E710 }

{ @routine $73FE40 TNormalShip_AwardRandomMedal }
function TNormalShip.AwardRandomMedal: WideString;
var Award: Byte;
begin
  if CurrentPlanet <> nil then Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atLiberation, atAccomplishment], [stKling..Ord(rstCustomStation)])
  else if DockedTo <> nil then Award := SelectAward(RaceToOwner(DockedTo.PilotRace), [atLiberation, atAccomplishment], [stKling..Ord(rstCustomStation)])
  else Award := SelectAward(Ord(oiHuman), [atLiberation, atAccomplishment], [stKling..Ord(rstCustomStation)]);
  AddAward(Award);
  Result := GetAwardInfo(Award).Name;
end;
{ @end $73FE40 }

{ @routine $740018 TNormalShip_ProcessShipKill }
procedure TNormalShip.ProcessShipKill(Victim: TShip);
var
  I, SharedExperience, ExperienceDelta, ActivityAmount: Integer;
  Experience, RankReward, PirateReward: Integer;
  SourceKind: Byte;
  OtherShip: TShip;
  OtherNormal: TNormalShip;
  Event: TGalaxyEvent;
  Quest: PQuest;
  QuestTargetKill: Boolean;

  // @nested $73FF3C RecordShipKillCategory
  procedure RecordShipKillCategory(Ship: TNormalShip; Victim: TShip); // @addr $73FF3C @ida "void __usercall $name(TNormalShip *Ship@<eax>, TShip *Victim@<edx>, void *ParentFrame@<^0>);" @note "Nested helper; unused caller-popped static link."
  begin
    case Victim.TypeId of
      stTransport: if Victim.OwnerId <> Byte(oiPirate) then
        begin
          Inc(Ship.CivilianKillCount);
          if GetPlayer = Ship then TryAddAchievementProgress('BLACKHEAD', 1);
          Ship.CheckKillCountAwards(Victim);
        end;
      stWarrior: begin
        Inc(Ship.MilitaryKillCount);
        Ship.CheckKillCountAwards(Victim);
      end;
      stRanger: if ((Victim as TRanger).GetDominantCareer <> rcPirate) and (Victim.OwnerId <> Byte(oiPirate)) and
        not (Victim as TRanger).ExcludedFromRating then
        begin
          Inc(Ship.RangerKillCount);
          Ship.CheckKillCountAwards(Victim);
        end;
    end;
  end;

begin
  if Self = Victim then Exit;
  SourceKind := 3;
  QuestTargetKill := False;
  if GetPlayer = Self then
  begin
    Event := AddGalaxyEvent('PlayerKillsShip');
    Event.AddData(Victim.TypeId);
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Victim.OwnerId);
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
      if not Quest.Successful and (Quest.QuestType = qtKillShip) and
         (Quest.ObjectiveTarget = Victim) then QuestTargetKill := True;
    end;
  end;
  if GetPlayer = PartnerShip then
  begin
    Event := AddGalaxyEvent('PlayerCompanionKillsShip');
    Event.AddData(Victim.TypeId);
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Victim.OwnerId);
    Event.AddTextData(Victim.GetName);
    Event.AddData(Self.TypeId);
    Event.AddData(Self.Id);
    Event.AddData(Self.OwnerId);
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
  if CurrentStanding = ssCustom then Exit;
  if Victim.CurrentStanding = ssCustom then
  begin
    IncrementWordSaturating(CurrentSystemKills.Custom);
    RankReward := 10;
    Experience := NextRandomIntRange(250, 500, Galaxy.RandomState);
    SourceKind := 0;
    if Self is TRanger then
    begin
      if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 8;
      if Galaxy.CoalitionDefeatedTurn = 0 then
        (Self as TRanger).AddWarriorCareerActivity(Byte(ActivityAmount));
    end;
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
     (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace then (PartnerShip as TNormalShip).AddRankPoints(6);
    if OwnerId = Byte(oiPirate) then PirateReward := 8;
  end
  else if (Victim.TypeId = stTransport) and (Self is TRanger) then
  begin
    if not QuestTargetKill then IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    Experience := Round(NextRandomIntRange(100, 250, Galaxy.RandomState) * (ShortInt(TNormalShip(Victim).Rank + Byte(0)) * 0.1 + 1));
    if OwnerId = Byte(oiPirate) then
    begin
      PirateReward := 8;
      Experience := Round(Experience * 1.5);
    end;
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
  end
  else if (Victim is TRanger) and (Self is TRanger) then
  begin
    if (Victim as TRanger).GetDominantCareer = rcPirate then
    begin
      SourceKind := 2;
      RankReward := 10;
      (Self as TRanger).AddWarriorCareerActivity(4);
      Experience := Round(NextRandomIntRange(250, 500, Galaxy.RandomState) * (ShortInt(TNormalShip(Victim).PirateRank + Byte(0)) * 0.1 + 1));
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
    (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
      Experience := Round(NextRandomIntRange(100, 250, Galaxy.RandomState) * (ShortInt(TNormalShip(Victim).Rank + Byte(0)) * 0.1 + 1));
      if OwnerId = Byte(oiPirate) then
      begin
        PirateReward := 24;
        Experience := Round(Experience * 1.5);
      end;
    end;
  end
  else if (Victim is TRanger) and (Self is TPirate) then
  begin
    if TRanger(Victim).GetDominantCareer <> rcPirate then
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
    SourceKind := 2;
    if (Victim.OwnerId = Byte(oiPirate)) and not QuestTargetKill then
    begin
      IncrementWordSaturating(CurrentSystemKills.Pirate);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Pirate = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Pirate);
    end;
    Inc(PirateKillCount);
    if GetPlayer = Self then TryAddAchievementProgress('SHIELD', 1);
    Experience := Round(NextRandomIntRange(250, 500, Galaxy.RandomState) * (ShortInt(TNormalShip(Victim).PirateRank + Byte(0)) * 0.1 + 1));
    RankReward := 10;
    if OwnerId = Byte(oiPirate) then Experience := Experience div 2;
    if Self is TRanger then (Self as TRanger).AddWarriorCareerActivity(4);
  end
  else if Victim is TKling then
  begin
    Inc(DominatorKillCount);
    if GetPlayer = Self then Inc(GetPlayer.DominatorKillsByType[Ord((Victim as TKling).KlingType)]);
    IncrementWordSaturating(CurrentSystemKills.Dominator);
    RankReward := DominatorShipDefinitions[Ord((Victim as TKling).KlingType)].RankPoints;
    Experience := Round(DominatorShipDefinitions[Ord((Victim as TKling).KlingType)].KillExperience * Galaxy.GetDominatorKillExperienceScale);
    SourceKind := 1;
    if Self is TRanger then
    begin
      if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 8;
      if Galaxy.CoalitionDefeatedTurn = 0 then
        (Self as TRanger).AddWarriorCareerActivity(Byte(ActivityAmount));
      if GetPlayer = Self then GetPlayer.TryAwardDominatorPrograms(Victim);
      if (GetPlayer = Self) and GetPlayer.HasRadiationSickness then
        Experience := Round(GetPlayer.RadiationHealth[1].Progress * Experience);
    end;
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
     (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace then
    begin
      (PartnerShip as TNormalShip).AddRankPoints(DominatorShipDefinitions[Ord((Victim as TKling).KlingType)].RankPoints div 2 + 1);
      if (PartnerShip as TNormalShip).CurrentSystemKills.Dominator = 0 then
        Inc(TNormalShip(PartnerShip).CurrentSystemKills.Dominator);
    end;
    if OwnerId = Byte(oiPirate) then PirateReward := DominatorShipDefinitions[Ord((Victim as TKling).KlingType)].PirateRankPoints;
  end
  else if Victim is TWarrior then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = Byte(oiPirate) then
    begin
      Experience := Round(NextRandomIntRange(250, 500, Galaxy.RandomState) * (ShortInt(TNormalShip(Victim).Rank + Byte(0)) * 0.1 + 1));
      if (Victim as TWarrior).WarriorType = wtFlagship then
      begin
        Experience := Experience * 2;
        PirateReward := 60;
      end
      else PirateReward := 16;
    end;
    if Self is TRanger then
    begin
    if GetPlayer = Self then ActivityAmount := 8 else ActivityAmount := 2;
    (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
    end;
  end
  else if Victim.TypeId = stTransport then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = Byte(oiPirate) then PirateReward := 8;
  end
  else if (Victim.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Victim.CurrentStanding = ssCoalitionMilitary) then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = Byte(oiPirate) then PirateReward := 32;
    if Self is TRanger then
    begin
    if GetPlayer = Self then ActivityAmount := 8 else ActivityAmount := 2;
    (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
    end;
  end
  else if (Victim.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Victim.CurrentStanding = ssCoalitionActive) then
  begin
    Inc(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = Byte(oiPirate) then PirateReward := 24;
    if Self is TRanger then
    begin
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
    end;
  end
  else if (Victim.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Victim.CurrentStanding in [ssCoalitionPassive..ssPiratePassive]) then
  begin
    if CurrentStar.ControlFaction = sfCoalition then
    begin
      IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    end;
    if CurrentStar.ControlFaction = sfPirates then
    begin
      IncrementWordSaturating(CurrentSystemKills.Pirate);
    if (PartnerShip <> nil) and (PartnerShip is TNormalShip) and
         (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace and
         ((PartnerShip as TNormalShip).CurrentSystemKills.Pirate = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Pirate);
    end;
    if (Victim.TypeId <> Byte(rstPirateBase)) and (Self is TRanger) then
    begin
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
    end;
    if (Victim.TypeId = Byte(rstPirateBase)) and (Self is TRanger) then
    begin
    if GetPlayer = Self then ActivityAmount := 4 else ActivityAmount := 1;
    (Self as TRanger).AddWarriorCareerActivity(Byte(ActivityAmount));
    end;
  end
  else if (Victim.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Victim.CurrentStanding in [ssPirateActive..ssPirateMilitary]) then
  begin
    if CurrentStar.ControlFaction = sfPirates then
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
    (Self as TRanger).AddWarriorCareerActivity(Byte(ActivityAmount));
    end;
  end;
  if Victim.CurrentStanding <> ssCustom then
  begin
    if (GetPlayer = Self) and (GetPlayer.PirateLicenseTicks > 0) then
    begin
      if Victim is TWarrior then
      begin
        if (Victim as TWarrior).WarriorType = wtFlagship then
          Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 2000))
        else Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 6000));
      end;
      if Victim.TypeId = Byte(rstMilitaryBase) then
        Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 2000));
    end;
    if (GetPlayer = Self) and (CurrentStar.ControlFaction = sfCoalition) then
      GetPlayer.AchievementStats.CheckHaterAchievement;
    RecordShipKillCategory(Self, Victim);
  end;
  if Self is TPirate then (Self as TPirate).RaidPressure := 0;
  if (RankReward > 0) or (Experience > 0) or (PirateReward > 0) then
  begin
    if RankReward > 0 then
    begin
      if OwnerId <> Byte(oiPirate) then AddRankPoints(Word(RankReward));
      RankReward := RankReward div 2 + 1;
    end;
    if Experience > 0 then
    begin
      GainExperience(Experience, SourceKind);
      if (PartnerShip <> nil) and (PartnerShip.CurrentStar = CurrentStar) and PartnerShip.InNormalSpace then
      begin
        SharedExperience := Round(Experience * LeadershipExperiencePercent[PartnerShip.GetEffectiveSkillLevel(psLeadership)] * 0.01);
        if GetPlayer = PartnerShip then
        begin
          Event := AddGalaxyEvent('PlayerGotExpFromPartner');
          Event.AddData(Id);
          Event.AddData(PartnerShip.GetEffectiveSkillLevel(psLeadership));
          if SourceKind = 1 then ExperienceDelta := GetPlayer.ExperienceByDominators
          else if SourceKind = 2 then ExperienceDelta := GetPlayer.ExperienceByPirates
          else if SourceKind = 3 then ExperienceDelta := GetPlayer.ExperienceByNormals
          else ExperienceDelta := 0;
          GetPlayer.GainExperience(SharedExperience, SourceKind);
          if SourceKind = 1 then ExperienceDelta := GetPlayer.ExperienceByDominators - ExperienceDelta
          else if SourceKind = 2 then ExperienceDelta := GetPlayer.ExperienceByPirates - ExperienceDelta
          else if SourceKind = 3 then ExperienceDelta := GetPlayer.ExperienceByNormals - ExperienceDelta;
          Event.AddData(SourceKind);
          Event.AddData(SharedExperience);
          Event.AddData(ExperienceDelta);
        end
        else (PartnerShip as TNormalShip).GainExperience(SharedExperience, SourceKind);
      end;
      Experience := Experience div 2 + 1;
    end;
    if PirateReward > 0 then
    begin
      if OwnerId = Byte(oiPirate) then AddPirateRankPoints(PirateReward);
      PirateReward := PirateReward div 2 + 1;
    end;
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      OtherShip := CurrentStar.Ships[I];
      if (OtherShip = Self) or not OtherShip.InNormalSpace or not OtherShip.IsAttackingShip(Victim) then Continue;
      if (OtherShip is TTranclucator) and (GetPlayer = TTranclucator(OtherShip).OwnerShip) then
      begin
    Event := AddGalaxyEvent('PlayerTranclucatorAssistKillsShip');
    Event.AddData(Victim.TypeId);
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Victim.OwnerId);
    Event.AddTextData(Victim.GetName);
    Event.AddData(OtherShip.Id);
    Event.AddData(OtherShip.OwnerId);
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
    Event.AddData(Victim.TypeId);
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Victim.OwnerId);
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
    Event.AddData(Victim.TypeId);
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Victim.OwnerId);
    Event.AddTextData(Victim.GetName);
    Event.AddData(OtherShip.TypeId);
    Event.AddData(OtherShip.Id);
    Event.AddData(OtherShip.OwnerId);
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
      if (RankReward > 0) and (OtherNormal.OwnerId <> Byte(oiPirate)) then OtherNormal.AddRankPoints(Word(RankReward));
      if Experience > 0 then OtherNormal.GainExperience(Experience, SourceKind);
      if (PirateReward > 0) and (OtherNormal.OwnerId = Byte(oiPirate)) then OtherNormal.AddPirateRankPoints(PirateReward);
      Inc(OtherNormal.TotalShipKillCount);
      if Victim.CurrentStanding = ssCustom then IncrementWordSaturating(OtherNormal.CurrentSystemKills.Custom)
      else if Victim is TKling then
      begin
        Inc(OtherNormal.DominatorKillCount);
        IncrementWordSaturating(OtherNormal.CurrentSystemKills.Dominator);
        if GetPlayer = OtherShip then Inc(GetPlayer.DominatorKillsByType[Ord((Victim as TKling).KlingType)]);
      end
      else if (Victim is TPirate) or ((Victim is TRanger) and ((Victim as TRanger).GetDominantCareer = rcPirate)) then
      begin
        if (Victim.OwnerId = Byte(oiPirate)) and not QuestTargetKill then IncrementWordSaturating(OtherNormal.CurrentSystemKills.Pirate);
        Inc(OtherNormal.PirateKillCount);
        if (GetPlayer = OtherShip) and (Victim is TPirate) then TryAddAchievementProgress('SHIELD', 1);
      end
      else if (Victim is TNormalShip) and (Victim.OwnerId in TOwnerMask(PlanetOwnerMasks.Coalition)) then
      begin
        if not QuestTargetKill then IncrementWordSaturating(OtherNormal.CurrentSystemKills.Normal);
      end
      else if (Victim.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Victim.CurrentStanding in TStationStandingMask(FactionStandingMasks[Ord(CurrentStar.ControlFaction)])) then
        IncrementWordSaturating(TSystemKillCountArray(OtherNormal.CurrentSystemKills)[Ord(CurrentStar.ControlFaction)]);
      RecordShipKillCategory(OtherNormal, Victim);
    end;
  end;
end;
{ @end $740018 }

{ @routine $7421CC ProcessSystemLiberationRewards }
procedure ProcessSystemLiberationRewards(SourceShip: TNormalShip; Star: TStar);
var
  I, J: Integer;
  Ship: TShip;
  Normal: TNormalShip;
  Planet, CeremonyPlanet: TPlanet;
  Text: WideString;

  // @nested $742114 LogPlayerEvent
  procedure LogPlayerEvent(Ship: TShip); // @addr $742114 @ida "void __usercall $name(TShip *Ship@<eax>, void *ParentFrame@<^0>);" @note "Nested helper; caller-popped link, Star at ParentFrame-4."
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
  if Star.ControlFaction = sfCoalition then
  begin
    CeremonyPlanet := TObject(Star.FindFirstInhabitedPlanet) as TPlanet;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship is TNormalShip then
      begin
        Normal := Ship as TNormalShip;
        Normal.PendingLiberationCeremonyPlanet := nil;
        if ((Normal.CurrentSystemKills.Dominator > 0) and (Star.PreviousControlFaction = sfDominators)) or
           ((Normal.CurrentSystemKills.Pirate > 0) and (Star.PreviousControlFaction = sfPirates) and (Normal.OwnerId <> Byte(oiPirate))) or
           ((GetPlayer <> Ship) and (Ship.DaysSincePlayerSeen > 1) and
            (Normal.DominatorKillCount + Normal.PirateKillCount > Normal.LiberatedSystemCount)) then
        begin
          if Star.PreviousControlFaction = sfDominators then Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Dominator;
          if Star.PreviousControlFaction = sfPirates then Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Pirate;
          Normal.CurrentSystemKills.Dominator := 0;
          Normal.CurrentSystemKills.Pirate := 0;
          Normal.CurrentSystemKills.Normal := 0;
          Normal.CurrentSystemKills.Custom := 0;
          Inc(Normal.LiberatedSystemCount);
          Normal.PendingLiberationCeremonyPlanet := CeremonyPlanet;
          if Normal.OwnerId <> Byte(oiPirate) then Normal.AddRankPoints(30) else Normal.AddPirateRankPoints(16);
          Normal.GainExperience(NextRandomIntRange(250, 500, Galaxy.RandomState), 0);
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
      if Star.PreviousControlFaction = sfDominators then
      begin
        Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.NormalsTakeSystemFromKling', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name);
        Galaxy.AddPlanetNews(29, Text);
      end
      else
      begin
        Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.NormalsTakeSystemFromPirateClan', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name);
        Galaxy.AddPlanetNews(30, Text);
      end;
      with AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '') do
      begin
        if (GetPlayer.CurrentStar = Star) and GetPlayer.InNormalSpace then NotificationSoundKind := 1
        else NotificationSoundKind := 0;
        Targets[0].PlanetId := CeremonyPlanet.Id;
      end;
    end;
  end
  else if Star.ControlFaction = sfPirates then
  begin
    CeremonyPlanet := TObject(Star.FindFirstInhabitedPlanet) as TPlanet;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship is TNormalShip then
      begin
        Normal := Ship as TNormalShip;
        Normal.PendingLiberationCeremonyPlanet := nil;
        if ((Normal.CurrentSystemKills.Dominator > 0) and (Star.PreviousControlFaction = sfDominators)) or
           ((Normal.CurrentSystemKills.Normal > 0) and (Star.PreviousControlFaction = sfCoalition) and (Normal.OwnerId = Byte(oiPirate))) or
           ((GetPlayer <> Ship) and (Ship.DaysSincePlayerSeen > 1) and
            (Normal.MilitaryKillCount + Normal.DominatorKillCount > Normal.LiberatedSystemCount)) then
        begin
          if Star.PreviousControlFaction = sfDominators then Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Dominator;
          if Star.PreviousControlFaction = sfCoalition then Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Normal;
          Normal.CurrentSystemKills.Dominator := 0;
          Normal.CurrentSystemKills.Pirate := 0;
          Normal.CurrentSystemKills.Normal := 0;
          Normal.CurrentSystemKills.Custom := 0;
          Inc(Normal.LiberatedSystemCount);
          Normal.PendingLiberationCeremonyPlanet := CeremonyPlanet;
          Normal.AddPirateRankPoints(16);
          Normal.GainExperience(NextRandomIntRange(250, 500, Galaxy.RandomState), 0);
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
    if Star.PreviousControlFaction = sfCoalition then
    begin
      Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.PirateClanTakeSystemFromNormals', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name);
      if Galaxy.CoalitionDefeatedTurn = 0 then Galaxy.AddPlanetNews(32, Text);
    end
    else
    begin
      if Galaxy.CoalitionDefeatedTurn = 0 then
        Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.PirateClanTakeSystemFromKling', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name)
      else
        Text := FormatText3(PickLocalizedTextVariant('GalaxyNews.Globals.PirateClanTakeSystemFromKlingAlt', SourceShip.Seed * (Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName, '<Planet>', CeremonyPlanet.Name);
      if Galaxy.CoalitionDefeatedTurn = 0 then Galaxy.AddPlanetNews(31, Text);
    end;
    with AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '') do
      begin
        if (GetPlayer.CurrentStar = Star) and GetPlayer.InNormalSpace then NotificationSoundKind := 1
        else NotificationSoundKind := 0;
        Targets[0].PlanetId := CeremonyPlanet.Id;
      end;
  end;
end;
{ @end $7421CC }

{ @routine $742F74 TNormalShip_CheckKillCountAwards }
procedure TNormalShip.CheckKillCountAwards(Victim: TShip);
  // @nested $742D18 Check
  procedure Check(InitialThreshold, Multiplier: Integer; Count: Word; VictimType: Byte); // @addr $742D18 @ida "void __userpurge $name(int InitialThreshold@<eax>, int Multiplier@<edx>, unsigned __int16 Count@<cx>, unsigned __int8 VictimType@<^0>, void *ParentFrame@<^4>);" @stackpop $4 @calls "0x742FAB 0x742FCA 0x742FF2" @note "Caller-popped static link; ship at ParentFrame-4."
  const
    BadAwards = [atPerfidy];
  var
    I, Threshold, Award: Integer;
    Text, ShipTypeName: WideString;
  begin
    if (Galaxy.CoalitionDefeatedTurn > 0) or (Count = High(Word)) then Exit;
    Threshold := InitialThreshold;
    I := 1;
    repeat
      if Count < Threshold then Break;
      if Count = Threshold then
      begin
        Award := Integer(SelectAward(OwnerId, BadAwards, [VictimType])) and $FF;
        if Award <> AwardNotFound then
        begin
          AddAward(Byte(Award));
          if GetPlayer = Self then
          begin
            ShipTypeName := ShipTypeNames[VictimType].Name;
            Text := PickLocalizedTextVariant('GalaxyNews.BadReward.Kill' + ShipTypeName, Seed + Cardinal(Galaxy.CurrentTurn div 10));
            ReplaceTextToken(Text, '<Reward>', GetAwardInfo(Byte(Award)).Name, '<color=255,240,100>');
            AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '');
          end;
        end;
        Break;
      end;
      Threshold := Min(Threshold * Multiplier, 10000000);
      Inc(I);
    until I = 9;
  end;
begin
  case Victim.TypeId of
    stTransport: Check(5, 5, Word(CivilianKillCount), stTransport);
    stWarrior: Check(3, 3, Word(MilitaryKillCount), stWarrior);
    stRanger: if TypeId = stRanger then Check(2, 4, Word(RangerKillCount), stRanger);
  end;
end;
{ @end $742F74 }

{ @routine $742FFC TNormalShip_UpdateRelationsForNearbyCombat }
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
    if (Ship is TRanger) and (Ship <> Self) and Ship.InNormalSpace then
    begin
      Ranger := Ship as TRanger;
      if (Ranger.OrderTarget is TShip) and (Ranger.OrderTarget = Ranger.EnemyShip) then
      begin
        Target := Ranger.OrderTarget as TShip;
        if GetRelationLevelToShip(Target) = rlExcellent then
        begin
          if (GetPlayer = Ship) or (NextRandomUnitFloat(RandomState) <= 0.1) then
          begin
            Change := (Target.OrderTarget <> Ranger) and (Target.GetRelationLevelToShip(Ranger) = rlHostile);
            if Change then ChangeRelationToRanger(Ranger, -2);
          end;
        end
        else if GetRelationLevelToShip(Target) = rlHostile then
        begin
          Change := Target.GetRelationLevelToShip(Ranger) = rlHostile;
          if Change then ChangeRelationToRanger(Ranger, 2);
        end;
      end;
    end;
  end;
end;
{ @end $742FFC }

{ @routine $7431AC TNormalShip_SelectAward }
function TNormalShip.SelectAward(Owner: Byte; Kinds: TAwardTypeMask; VictimTypes: TShipTypeMask): Byte;
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
      MatchesCareerName(Byte(GetDominantCareer), LookupLocalizedTextByKey('Reward.' + IntToStr(I) + '.Status')) then
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
{ @end $7431AC }

{ @routine $7435A0 TNormalShip_GetAwardInfo }
function TNormalShip.GetAwardInfo(AwardId: Byte): TRewardInfo;
begin
  Result.AwardId := AwardId;
  Result.Name := LookupLocalizedTextByKey('Reward.' + IntToStr(AwardId) + '.Name');
  Result.Text := LookupLocalizedTextByKey('Reward.' + IntToStr(AwardId) + '.Text');
end;
{ @end $7435A0 }

{ @routine $7436E8 TNormalShip_GetRankName }
function TNormalShip.GetRankName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank] + '.Name');
end;
{ @end $7436E8 }

{ @routine $743780 TNormalShip_GetRankLongName }
function TNormalShip.GetRankLongName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank] + '.NameBig');
end;
{ @end $743780 }

{ @routine $743820 TNormalShip_GetRankDescription }
function TNormalShip.GetRankDescription: WideString;
begin
  Result := LocalizedColorText('Rank.' + CoalitionRankNames[Rank] + '.Text');
end;
{ @end $743820 }

{ @routine $7438B8 TNormalShip_GetNextRankName }
function TNormalShip.GetNextRankName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank + 1] + '.Name');
end;
{ @end $7438B8 }

{ @routine $743950 TNormalShip_GetRankPointsToNextRank }
function TNormalShip.GetRankPointsToNextRank: Word;
begin
  if (Rank < 7) and (CoalitionRankPointThresholds[Rank] > RankPoints) then
    Result := CoalitionRankPointThresholds[Rank] - RankPoints
  else Result := 0;
end;
{ @end $743950 }

{ @routine $7439B8 TNormalShip_AddRankPoints }
procedure TNormalShip.AddRankPoints(Amount: Word);
var
  Needed: Integer;
begin
  Needed := GetRankPointsToNextRank;
  Inc(RankPoints, Min(Amount, Needed));
  if (Needed > 0) and (GetPlayer = Self) and GetPlayer.CanPromoteRank and
     (Galaxy.CoalitionDefeatedTurn = 0) then
    AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn,
      FormatText1(PickLocalizedTextVariant('GalaxyNews.WB.NewRank', Seed * (Galaxy.CurrentTurn div 10)),
        '<color=255,240,100>', '<Rank>', GetPlayer.GetNextRankName), '');
end;
{ @end $7439B8 }

{ @routine $743B48 TNormalShip_TryPromoteRank }
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
{ @end $743B48 }

{ @routine $743B90 TNormalShip_CanPromoteRank }
function TNormalShip.CanPromoteRank: Boolean;
begin
  Result := (Rank < 7) and (GetRankPointsToNextRank = 0);
end;
{ @end $743B90 }

{ @routine $743BC4 TNormalShip_GetPirateRankName }
function TNormalShip.GetPirateRankName: WideString;
begin Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank] + '.Name'); end;
{ @end $743BC4 }

{ @routine $743C68 TNormalShip_GetPirateRankLongName }
function TNormalShip.GetPirateRankLongName: WideString;
begin
  Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank] + '.NameBig');
end;
{ @end $743C68 }

{ @routine $743D14 TNormalShip_GetPirateRankDescription }
function TNormalShip.GetPirateRankDescription: WideString;
begin
  Result := LocalizedColorText('RankPirate.' + PirateRankNames[PirateRank] + '.Text');
end;
{ @end $743D14 }

{ @routine $743DB8 TNormalShip_GetNextPirateRankName }
function TNormalShip.GetNextPirateRankName: WideString;
begin Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank + 1] + '.Name'); end;
{ @end $743DB8 }

{ @routine $743E5C TNormalShip_GetPirateRankPointsToNextRank }
function TNormalShip.GetPirateRankPointsToNextRank: Word;
begin
  if (PirateRank < 7) and (PirateRankPointThresholds[PirateRank] > PirateRankPoints) then
    Result := PirateRankPointThresholds[PirateRank] - PirateRankPoints
  else Result := 0;
end;
{ @end $743E5C }

{ @routine $743EC4 TNormalShip_AddPirateRankPoints }
procedure TNormalShip.AddPirateRankPoints(Amount: Cardinal);
var
  Needed: Integer;
begin
  Needed := GetPirateRankPointsToNextRank;
  Inc(PirateRankPoints, Min(Amount, Needed));
end;
{ @end $743EC4 }

{ @routine $743F24 TNormalShip_TryPromotePirateRank }
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
{ @end $743F24 }

{ @routine $743F88 TNormalShip_CanPromotePirateRank }
function TNormalShip.CanPromotePirateRank: Boolean;
begin Result := (PirateRank < 7) and (GetPirateRankPointsToNextRank = 0); end;
{ @end $743F88 }

{ @routine $74414C TNormalShip_SelectSituationalMessage }
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
  ShipKind: Byte;
  CountMask: TGreetingCountMask;
  Other: TShip;
  // @nested $743FE0 ShuffleDefinitions
  procedure ShuffleDefinitions; // @addr $743FE0 @ida "void __usercall $name(void *ParentFrame@<^0>);" @note "Nested helper; caller-popped static link. Copies definitions and swaps the first half against deterministic random positions."
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
  begin
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
    if (Definitions[EntryIndex].CoalitionAlreadyDefeated <> 2) and (((Definitions[EntryIndex].CoalitionAlreadyDefeated = 0) and (not (Galaxy.CoalitionDefeatedTurn <> 0))) or ((Definitions[EntryIndex].CoalitionAlreadyDefeated = 1) and (Galaxy.CoalitionDefeatedTurn <> 0))) then Continue;
    if (Definitions[EntryIndex].DominatorsAlreadyDefeated <> 2) and (((Definitions[EntryIndex].DominatorsAlreadyDefeated = 0) and (not (not Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron])))) or ((Definitions[EntryIndex].DominatorsAlreadyDefeated = 1) and (not Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron])))) then Continue;
      if BestPriority > 0 then begin
        CandidatePriority := Definitions[EntryIndex].Priority;
        if CandidatePriority * SeededRandomIntRange(1, 100, Seed + EntryIndex * (Galaxy.CurrentTurn div 20)) <
          BestPriority * SeededRandomIntRange(1, 100, Seed + EntryIndex * (Galaxy.CurrentTurn div 20) * 3) then Continue;
      end;
      Good := 50;
      if Definitions[EntryIndex].Goods <> 42 then Good := Definitions[EntryIndex].Goods;
      if (Definitions[EntryIndex].AutoTalk <> 2) and
        ((Automatic and (Definitions[EntryIndex].AutoTalk = 1)) or (not Automatic and (Definitions[EntryIndex].AutoTalk = 0))) then Continue;
      if Definitions[EntryIndex].FlyType = 0 then MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text')
      else begin
        if Definitions[EntryIndex].FlyType = 1 then begin
          if not (OrderTarget is TPlanet) then Continue;
          Planet := OrderTarget as TPlanet;
          if not (Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then Continue;
          if CurrentStar.Status.CustomFaction <> '' then Continue;
    if (Definitions[EntryIndex].ToPlanetRace <> []) and not (Planet.RaceId in Definitions[EntryIndex].ToPlanetRace) then Continue;
    if (Definitions[EntryIndex].ToPlanetRelations <> []) and not (Byte(Planet.GetRelationLevelToShip(GetPlayer)) in Definitions[EntryIndex].ToPlanetRelations) then Continue;
    if Good <> 50 then begin
    if (Definitions[EntryIndex].ToPlanetGoodsCnt <> []) and not (Galaxy.ClassifyGoodsQuantity(Planet.Goods[Good].Count, Good) in Definitions[EntryIndex].ToPlanetGoodsCnt) then Continue;
    if (Definitions[EntryIndex].ToPlanetGoodsSale <> []) and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsPurchasePrice(Good, Planet), Good) in Definitions[EntryIndex].ToPlanetGoodsSale) then Continue;
    if (Definitions[EntryIndex].ToPlanetGoodsBuy <> []) and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsSellPrice(Good, Planet), Good) in Definitions[EntryIndex].ToPlanetGoodsBuy) then Continue;
    end;
    if (Definitions[EntryIndex].ToPlanetIsHomePlanet <> 2) and (((Definitions[EntryIndex].ToPlanetIsHomePlanet = 0) and (not (HomePlanet = Planet))) or ((Definitions[EntryIndex].ToPlanetIsHomePlanet = 1) and (HomePlanet = Planet))) then Continue;
    if (Definitions[EntryIndex].ToPlanetRaceIsShipRace <> 2) and (((Definitions[EntryIndex].ToPlanetRaceIsShipRace = 0) and (not (Planet.RaceId = PilotRace))) or ((Definitions[EntryIndex].ToPlanetRaceIsShipRace = 1) and (Planet.RaceId = PilotRace))) then Continue;
    if (Definitions[EntryIndex].ToPlanetRaceIsPlayerRace <> 2) and (((Definitions[EntryIndex].ToPlanetRaceIsPlayerRace = 0) and (not (GetPlayer.PilotRace = Planet.RaceId))) or ((Definitions[EntryIndex].ToPlanetRaceIsPlayerRace = 1) and (GetPlayer.PilotRace = Planet.RaceId))) then Continue;
    if (Definitions[EntryIndex].ToPlanetEconomy <> []) and not (Byte(Planet.Economy) in Definitions[EntryIndex].ToPlanetEconomy) then Continue;
    if (Definitions[EntryIndex].ToPlanetGovernment <> []) and not (Byte(Planet.Government) in Definitions[EntryIndex].ToPlanetGovernment) then Continue;
    if (Definitions[EntryIndex].ToPlanetIsLastPlanet <> 2) and (((Definitions[EntryIndex].ToPlanetIsLastPlanet = 0) and (not (LastDockedPlanet = Planet))) or ((Definitions[EntryIndex].ToPlanetIsLastPlanet = 1) and (LastDockedPlanet = Planet))) then Continue;
    if Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace <> 2 then begin
      if not (LastDockedPlanet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then Continue;
    if (((Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace = 0) and (not (Planet.RaceId = LastDockedPlanet.RaceId))) or ((Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace = 1) and (Planet.RaceId = LastDockedPlanet.RaceId))) then Continue;
    end;
    MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
    MessageText := ReplaceColoredToken(MessageText, '<ToPlanet>', Planet.Name + GetLocalObjectLink(Planet, Automatic), '<color=255,240,100>');
    if Good <> 50 then begin
    MessageText := ReplaceColoredToken(MessageText, '<ToPlanetGoodsSale>', IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, Planet)), '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<ToPlanetGoodsBuy>', IntToStr(GetPlayer.ShopGoodsSellPrice(Good, Planet)), '<color=255,240,100>');
    end;
  end else if Definitions[EntryIndex].FlyType = 2 then begin
    if not (OrderTarget is TStar) then Continue;
    if (Definitions[EntryIndex].HomePlanetInToStar <> 2) and (((Definitions[EntryIndex].HomePlanetInToStar = 0) and (not (HomePlanet.CurrentStar = OrderTarget))) or ((Definitions[EntryIndex].HomePlanetInToStar = 1) and (HomePlanet.CurrentStar = OrderTarget))) then Continue;
    if (Definitions[EntryIndex].HomePlanetInCurStar <> 2) and (((Definitions[EntryIndex].HomePlanetInCurStar = 0) and (not (HomePlanet.CurrentStar = CurrentStar))) or ((Definitions[EntryIndex].HomePlanetInCurStar = 1) and (HomePlanet.CurrentStar = CurrentStar))) then Continue;
    Rejected := False;
    for ShipKind := 0 to 4 do begin
      case ShipKind of
        0: CountMask := Definitions[EntryIndex].KlingInToStar;
        1: CountMask := Definitions[EntryIndex].RangerInToStar;
        3: CountMask := Definitions[EntryIndex].PirateInToStar;
        4: CountMask := Definitions[EntryIndex].WarriorInToStar;
        2: CountMask := Definitions[EntryIndex].TransportInToStar;
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
    if Definitions[EntryIndex].ToStarControlByKling <> 2 then begin
      if (OrderTarget as TStar).Status.CustomFaction <> '' then Continue;
    if (((Definitions[EntryIndex].ToStarControlByKling = 0) and (not ((OrderTarget as TStar).ControlFaction = sfDominators))) or ((Definitions[EntryIndex].ToStarControlByKling = 1) and ((OrderTarget as TStar).ControlFaction = sfDominators))) then Continue;
    end;
    if Definitions[EntryIndex].ToStarControlByPirates <> 2 then begin
      if (OrderTarget as TStar).Status.CustomFaction <> '' then Continue;
    if (((Definitions[EntryIndex].ToStarControlByPirates = 0) and (not ((OrderTarget as TStar).ControlFaction = sfPirates))) or ((Definitions[EntryIndex].ToStarControlByPirates = 1) and ((OrderTarget as TStar).ControlFaction = sfPirates))) then Continue;
    end;
    if (Definitions[EntryIndex].ToStarInBattle <> 2) and (((Definitions[EntryIndex].ToStarInBattle = 0) and (not ((OrderTarget as TStar).Battle <> 0))) or ((Definitions[EntryIndex].ToStarInBattle = 1) and ((OrderTarget as TStar).Battle <> 0))) then Continue;
    MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
    MessageText := ReplaceColoredToken(MessageText, '<ToStar>', (OrderTarget as TStar).Name, '<color=255,240,100>');
  end else if Definitions[EntryIndex].FlyType = 3 then begin
    if (Order <> soMove) or not OrderAbsolute then Continue;
    Rejected := False;
    Item := nil;
    for J := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[J];
      // Native accepts either matching coordinate, rather than requiring both.
      if (GetPickupApproachPosition(Item.Position).X = OrderDestination.X) or
        (GetPickupApproachPosition(Item.Position).Y = OrderDestination.Y) then begin
        ItemTypes := Definitions[EntryIndex].ItemType;
        if (ItemTypes = '') or (ItemTypes = 'Any') or (FindTextPosW(Item.GetCategoryConfigName, ItemTypes) <> 0) then begin
          if (Definitions[EntryIndex].ShipNeedInItem <> 2) and
            (((Definitions[EntryIndex].ShipNeedInItem = 0) and not ShouldPickUpItem(Item)) or
             ((Definitions[EntryIndex].ShipNeedInItem = 1) and ShouldPickUpItem(Item))) then Continue;
          Rejected := True;
          Break;
        end;
      end;
    end;
    if not Rejected then Continue;
    MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
    MessageText := ReplaceColoredToken(MessageText, '<Item>', Item.GetDisplayName + GetLocalObjectLink(Item, Automatic), '<color=255,240,100>');
  end else if Definitions[EntryIndex].FlyType = 4 then begin
    if not (OrderTarget is TShip) then Continue;
    if (Definitions[EntryIndex].ToShipType <> []) and not ((OrderTarget as TShip).GetGreetingShipCategory in Definitions[EntryIndex].ToShipType) then Continue;
    if (Definitions[EntryIndex].ToShipRace <> []) and not ((OrderTarget as TShip).PilotRace in Definitions[EntryIndex].ToShipRace) then Continue;
    if (Definitions[EntryIndex].ToShipInPlanet <> 2) and (((Definitions[EntryIndex].ToShipInPlanet = 0) and (not ((OrderTarget as TShip).CurrentPlanet <> nil))) or ((Definitions[EntryIndex].ToShipInPlanet = 1) and ((OrderTarget as TShip).CurrentPlanet <> nil))) then Continue;
    if (Definitions[EntryIndex].ToShipBad <> 2) and (((Definitions[EntryIndex].ToShipBad = 0) and (not ((OrderTarget as TShip).EnemyShip = Self))) or ((Definitions[EntryIndex].ToShipBad = 1) and ((OrderTarget as TShip).EnemyShip = Self))) then Continue;
    if (Definitions[EntryIndex].ToShipRelations <> []) and not (Byte(GetRelationLevelToShip(OrderTarget as TShip)) in Definitions[EntryIndex].ToShipRelations) then Continue;
    MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
    MessageText := ReplaceColoredToken(MessageText, '<ToShip>', (OrderTarget as TShip).GetName + GetLocalObjectLink(OrderTarget, Automatic), '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<ToFullShip>', (OrderTarget as TShip).GetFullName(' ') + GetLocalObjectLink(OrderTarget, Automatic), '<color=255,240,100>');
    if (OrderTarget as TShip).CurrentPlanet <> nil then begin
    MessageText := ReplaceColoredToken(MessageText, '<ToShipInPlanet>', (OrderTarget as TShip).CurrentPlanet.GetFullName(' ') + GetLocalObjectLink((OrderTarget as TShip).CurrentPlanet, Automatic), '<color=255,240,100>');
    end;
  end;
end;
    if (Definitions[EntryIndex].ShipType <> []) and not (GetGreetingShipCategory in Definitions[EntryIndex].ShipType) then Continue;
    if (Definitions[EntryIndex].Relations <> []) and not (Byte(GetRelationLevelToShip(GetPlayer)) in Definitions[EntryIndex].Relations) then Continue;
    if (Definitions[EntryIndex].ShipRace <> []) and not (PilotRace in Definitions[EntryIndex].ShipRace) then Continue;
    if (Definitions[EntryIndex].PlayerRace <> []) and not (GetPlayer.PilotRace in Definitions[EntryIndex].PlayerRace) then Continue;
    if (Definitions[EntryIndex].ShipRaceIsPlayerRace <> 2) and (((Definitions[EntryIndex].ShipRaceIsPlayerRace = 0) and (not (GetPlayer.PilotRace = PilotRace))) or ((Definitions[EntryIndex].ShipRaceIsPlayerRace = 1) and (GetPlayer.PilotRace = PilotRace))) then Continue;
    if Definitions[EntryIndex].PlayerAttackGoodShip <> 2 then begin
      if GetPlayer.OrderTarget is TShip then begin
        Other := GetPlayer.OrderTarget as TShip;
        Rejected := (Other is TNormalShip) and (GetPlayer <> Other.OrderTarget) and
          (GetRelationLevelToShip(Other) = rlExcellent) and (Other.GetRelationLevelToShip(GetPlayer) = rlHostile);
      end else Rejected := False;
      if Definitions[EntryIndex].PlayerAttackGoodShip = 1 then
        if Rejected then Continue;
      if (Definitions[EntryIndex].PlayerAttackGoodShip = 0) and not Rejected then Continue;
      if Rejected then begin
    MessageText := ReplaceColoredToken(MessageText, '<FullShipGood>', (GetPlayer.OrderTarget as TShip).GetFullName(' ') + GetLocalObjectLink(GetPlayer.OrderTarget, Automatic), '');
    end;
  end;
    if (Definitions[EntryIndex].InFear <> 2) and (((Definitions[EntryIndex].InFear = 0) and (not (InFear))) or ((Definitions[EntryIndex].InFear = 1) and (InFear))) then Continue;
    if Definitions[EntryIndex].ShipBadFlyToShip <> 2 then begin
      Rejected := IsEnemyPursuingSelf;
    if (((Definitions[EntryIndex].ShipBadFlyToShip = 0) and (not (Rejected))) or ((Definitions[EntryIndex].ShipBadFlyToShip = 1) and (Rejected))) then Continue;
    end;
    if (Definitions[EntryIndex].ShipBadType <> []) and (EnemyShip <> nil) and not (EnemyShip.GetGreetingShipCategory in Definitions[EntryIndex].ShipBadType) then Continue;
    if (Definitions[EntryIndex].ShipBadRace <> []) and (EnemyShip <> nil) and not (EnemyShip.PilotRace in Definitions[EntryIndex].ShipBadRace) then Continue;
    if (Definitions[EntryIndex].ShipFlyToPlayer <> 2) and (((Definitions[EntryIndex].ShipFlyToPlayer = 0) and (not (GetPlayer = OrderTarget))) or ((Definitions[EntryIndex].ShipFlyToPlayer = 1) and (GetPlayer = OrderTarget))) then Continue;
    if (Definitions[EntryIndex].PlayerFlyToShip <> 2) and (((Definitions[EntryIndex].PlayerFlyToShip = 0) and (not (GetPlayer.OrderTarget = Self))) or ((Definitions[EntryIndex].PlayerFlyToShip = 1) and (GetPlayer.OrderTarget = Self))) then Continue;
    if (Definitions[EntryIndex].PlayerIsShipBad <> 2) and (((Definitions[EntryIndex].PlayerIsShipBad = 0) and (not (GetPlayer = EnemyShip))) or ((Definitions[EntryIndex].PlayerIsShipBad = 1) and (GetPlayer = EnemyShip))) then Continue;
    if (Definitions[EntryIndex].ShipTurnBeforeEndOrder <> []) then begin
      Count := Min(10, EstimateOrderTravelTurns);
      if not (Cardinal(Count) in Definitions[EntryIndex].ShipTurnBeforeEndOrder) then Continue;
    end;
    if (Definitions[EntryIndex].PlayerTurnBeforeEndOrder <> []) then begin
      Count := Min(10, GetPlayer.EstimateOrderTravelTurns);
      if not (Cardinal(Count) in Definitions[EntryIndex].PlayerTurnBeforeEndOrder) then Continue;
    end;
    if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace and (Definitions[EntryIndex].ShipBadTurnBeforeEndOrder <> []) then begin
      Count := Min(10, EnemyShip.EstimateOrderTravelTurns);
      if not (Cardinal(Count) in Definitions[EntryIndex].ShipBadTurnBeforeEndOrder) then Continue;
    end;
    if (Self is TRanger) and (Definitions[EntryIndex].ShipStatus <> []) and not (Byte((Self as TRanger).GetDominantCareer) in Definitions[EntryIndex].ShipStatus) then Continue;
    if (Definitions[EntryIndex].PlayerStatus <> []) and not (Byte(GetPlayer.GetDominantCareer) in Definitions[EntryIndex].PlayerStatus) then Continue;
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
    if Good <> 50 then begin
    if (Definitions[EntryIndex].ShipGoodsCnt <> []) and not (Galaxy.ClassifyGoodsQuantity(CargoGoods[Good].Count, Good) in Definitions[EntryIndex].ShipGoodsCnt) then Continue;
    if (Definitions[EntryIndex].PlayerGoodsCnt <> []) and not (Galaxy.ClassifyGoodsQuantity(GetPlayer.CargoGoods[Good].Count, Good) in Definitions[EntryIndex].PlayerGoodsCnt) then Continue;
    if (Definitions[EntryIndex].ShipHaveGoods <> 2) and (((Definitions[EntryIndex].ShipHaveGoods = 0) and (CargoGoods[Good].Count = 0)) or ((Definitions[EntryIndex].ShipHaveGoods = 1) and (CargoGoods[Good].Count > 0))) then Continue;
    if (Definitions[EntryIndex].PlayerHaveGoods <> 2) and (((Definitions[EntryIndex].PlayerHaveGoods = 0) and (GetPlayer.CargoGoods[Good].Count = 0)) or ((Definitions[EntryIndex].PlayerHaveGoods = 1) and (GetPlayer.CargoGoods[Good].Count > 0))) then Continue;
    end;
    if (Definitions[EntryIndex].ShipGoodsTypeCnt <> []) and not (CountCargoGoodsTypes in Definitions[EntryIndex].ShipGoodsTypeCnt) then Continue;
    if (Definitions[EntryIndex].PlayerGoodsTypeCnt <> []) and not (GetPlayer.CountCargoGoodsTypes in Definitions[EntryIndex].PlayerGoodsTypeCnt) then Continue;
    if (Definitions[EntryIndex].ShipMayScanPlayer <> 2) and (((Definitions[EntryIndex].ShipMayScanPlayer = 0) and (not (CanResolveObjectWithScanner(GetPlayer) and (GetRadarRange > 0)))) or ((Definitions[EntryIndex].ShipMayScanPlayer = 1) and (CanResolveObjectWithScanner(GetPlayer) and (GetRadarRange > 0)))) then Continue;
    Rejected := False;
    for ShipKind := 0 to 4 do begin
      case ShipKind of
        0: CountMask := Definitions[EntryIndex].KlingInCurStar;
        1: CountMask := Definitions[EntryIndex].RangerInCurStar;
        3: CountMask := Definitions[EntryIndex].PirateInCurStar;
        4: CountMask := Definitions[EntryIndex].WarriorInCurStar;
        2: CountMask := Definitions[EntryIndex].TransportInCurStar;
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
      if not (LastDockedPlanet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then Continue;
      if LastDockedPlanet.CurrentStar.Status.CustomFaction <> '' then Continue;
      if not (LastDockedPlanet.RaceId in Definitions[EntryIndex].LastPlanetRace) then Continue;
    if (Definitions[EntryIndex].LastPlanetRelations <> []) and not (Byte(LastDockedPlanet.GetRelationLevelToShip(GetPlayer)) in Definitions[EntryIndex].LastPlanetRelations) then Continue;
    if Good <> 50 then begin
    if (Definitions[EntryIndex].LastPlanetGoodsCnt <> []) and not (Galaxy.ClassifyGoodsQuantity(LastDockedPlanet.Goods[Good].Count, Good) in Definitions[EntryIndex].LastPlanetGoodsCnt) then Continue;
    if (Definitions[EntryIndex].LastPlanetGoodsSale <> []) and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsPurchasePrice(Good, LastDockedPlanet), Good) in Definitions[EntryIndex].LastPlanetGoodsSale) then Continue;
    if (Definitions[EntryIndex].LastPlanetGoodsBuy <> []) and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsSellPrice(Good, LastDockedPlanet), Good) in Definitions[EntryIndex].LastPlanetGoodsBuy) then Continue;
    end;
    if (Definitions[EntryIndex].LastPlanetIsHomePlanet <> 2) and (((Definitions[EntryIndex].LastPlanetIsHomePlanet = 0) and (not (LastDockedPlanet = HomePlanet))) or ((Definitions[EntryIndex].LastPlanetIsHomePlanet = 1) and (LastDockedPlanet = HomePlanet))) then Continue;
    if Definitions[EntryIndex].LastPlanetRaceIsShipRace <> 2 then begin
      if not (LastDockedPlanet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then Continue;
    if (((Definitions[EntryIndex].LastPlanetRaceIsShipRace = 0) and (not (LastDockedPlanet.RaceId = PilotRace))) or ((Definitions[EntryIndex].LastPlanetRaceIsShipRace = 1) and (LastDockedPlanet.RaceId = PilotRace))) then Continue;
    end;
    if Definitions[EntryIndex].LastPlanetRaceIsPlayerRace <> 2 then begin
      if not (LastDockedPlanet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then Continue;
    if (((Definitions[EntryIndex].LastPlanetRaceIsPlayerRace = 0) and (not (GetPlayer.PilotRace = LastDockedPlanet.RaceId))) or ((Definitions[EntryIndex].LastPlanetRaceIsPlayerRace = 1) and (GetPlayer.PilotRace = LastDockedPlanet.RaceId))) then Continue;
    end;
    if (Definitions[EntryIndex].LastPlanetEconomy <> []) and not (Byte(LastDockedPlanet.Economy) in Definitions[EntryIndex].LastPlanetEconomy) then Continue;
    if (Definitions[EntryIndex].LastPlanetGovernment <> []) and not (Byte(LastDockedPlanet.Government) in Definitions[EntryIndex].LastPlanetGovernment) then Continue;
    if (Definitions[EntryIndex].LastPlanetInCurStar <> 2) and (((Definitions[EntryIndex].LastPlanetInCurStar = 0) and (not (LastDockedPlanet.CurrentStar = CurrentStar))) or ((Definitions[EntryIndex].LastPlanetInCurStar = 1) and (LastDockedPlanet.CurrentStar = CurrentStar))) then Continue;
    if Definitions[EntryIndex].LastPlanetDistToShipInTurn <> [] then begin
      Count := Min(10, EstimateTravelTurnsToPlanet(LastDockedPlanet));
      if Count = -1 then Continue;
      if not (Cardinal(Count) in Definitions[EntryIndex].LastPlanetDistToShipInTurn) then Continue;
    end;
    if LastDockedPlanet.CurrentStar <> CurrentStar then begin
    Rejected := False;
    for ShipKind := 0 to 4 do begin
      case ShipKind of
        0: CountMask := Definitions[EntryIndex].KlingInLastPlanetStar;
        1: CountMask := Definitions[EntryIndex].RangerInLastPlanetStar;
        3: CountMask := Definitions[EntryIndex].PirateInLastPlanetStar;
        4: CountMask := Definitions[EntryIndex].WarriorInLastPlanetStar;
        2: CountMask := Definitions[EntryIndex].TransportInLastPlanetStar;
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
    MessageText := ReplaceColoredToken(MessageText, '<LastPlanet>', LastDockedPlanet.Name + GetLocalObjectLink(LastDockedPlanet, Automatic), '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<LastPlanetStar>', LastDockedPlanet.CurrentStar.Name, '<color=255,240,100>');
    if Good <> 50 then begin
    MessageText := ReplaceColoredToken(MessageText, '<LastPlanetGoodsSale>', IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, LastDockedPlanet)), '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<LastPlanetGoodsBuy>', IntToStr(GetPlayer.ShopGoodsSellPrice(Good, LastDockedPlanet)), '<color=255,240,100>');
    end;
  end;
  if MessageText <> '' then begin
    MessageText := ReplaceColoredToken(MessageText, '<Ship>', GetName + GetLocalObjectLink(Self, Automatic), '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<FullShip>', GetFullName(' ') + GetLocalObjectLink(Self, Automatic), '<color=255,240,100>');
    if EnemyShip <> nil then begin
    MessageText := ReplaceColoredToken(MessageText, '<ShipBad>', EnemyShip.GetName + GetLocalObjectLink(EnemyShip, Automatic), '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<FullShipBad>', EnemyShip.GetFullName(' ') + GetLocalObjectLink(EnemyShip, Automatic), '<color=255,240,100>');
    end;
    MessageText := ReplaceColoredToken(MessageText, '<ShipRank>', GetRankName, '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<PlayerRank>', GetPlayer.GetRankName, '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<CurStar>', CurrentStar.Name, '<color=255,240,100>');
    if HomePlanet <> nil then begin
    MessageText := ReplaceColoredToken(MessageText, '<HomePlanet>', HomePlanet.Name + GetLocalObjectLink(HomePlanet, Automatic), '<color=255,240,100>');
    MessageText := ReplaceColoredToken(MessageText, '<HomePlanetStar>', HomePlanet.CurrentStar.Name, '<color=255,240,100>');
    end;
    BestText := MessageText;
    if CandidatePriority = -1 then BestPriority := Definitions[EntryIndex].Priority else BestPriority := CandidatePriority;
    if BestPriority >= 50 then Break;
  end;
  end;
  Result := BestText;
  end;
end;
{ @end $74414C }

{ @routine $747A14 TNormalShip_UpdateAfterburnerState }
procedure TNormalShip.UpdateAfterburnerState;
begin
  AfterburnerActive := (GetSlotCount(sskAfterburner) > 0) and (GetEngine <> nil) and (GetEngine.ConditionPercent > 10) and (EstimateOrderTravelTurns > 1);
  RefreshDerivedStats(True);
end;
{ @end $747A14 }

{ @routine $747A78 TNormalShip_TrainSkillsAutomatically }
procedure TNormalShip.TrainSkillsAutomatically;
var
  Score, BestScore: Single;
  Skill, BestSkill: TPilotSkill;
  Bonus: Byte;
begin
  repeat
    BestScore := -1;
    BestSkill := psAccuracy;
    for Bonus := 22 to 27 do
    begin
      Skill := TPilotSkill(EquipmentBonusSkills[Bonus - 22]);
      if BaseSkills[Ord(Skill)] < 6 then
      begin
        Score := Sqr(EvaluateStatBonus(TEquipmentBonusKind(Bonus), 1)) / SkillTrainingCosts[BaseSkills[Ord(Skill)] + 1, Ord(Skill)];
        if Score > BestScore then
        begin
          BestScore := Score;
          BestSkill := Skill;
        end;
      end;
    end;
    if (BestScore < 0) or (SkillTrainingCosts[BaseSkills[Ord(BestSkill)] + 1, Ord(BestSkill)] > FreeExperience) then Break;
  until not TrainSkill(BestSkill);
end;
{ @end $747A78 }

end.
