unit Achievements;
// Unit bracket (inferred): .text 0x00593054..0x00594CA6; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, EC_Buf, SimpleSteamApi;



type
  // Native record RTTI at $592A1C.
  TAchievementInfo = record // @size 8
    Key: AnsiString; // @offset 0
    MaxValue: Integer; // @offset 4
  end;
  TAchievementDefinitionTable = array[0..82] of TAchievementInfo;

const
  AchievementDefinitionTable: TAchievementDefinitionTable = (
    (Key: 'NONE'; MaxValue: 0),
    (Key: 'AGENT'; MaxValue: 50),
    (Key: 'ARCHEOLOGY'; MaxValue: 30000),
    (Key: 'BLACKHEAD'; MaxValue: 200),
    (Key: 'BREZHNEV'; MaxValue: 0),
    (Key: 'BUMMER'; MaxValue: 0),
    (Key: 'CHAMPION'; MaxValue: 0),
    (Key: 'DOLGOZHID'; MaxValue: 0),
    (Key: 'HOLEMAN'; MaxValue: 500),
    (Key: 'ILL'; MaxValue: 0),
    (Key: 'KIBERMAN'; MaxValue: 0),
    (Key: 'MANYFACES'; MaxValue: 30),
    (Key: 'MONEY'; MaxValue: 0),
    (Key: 'NARKOMAN'; MaxValue: 0),
    (Key: 'OLDFAG'; MaxValue: 5000000),
    (Key: 'PEACELOVER'; MaxValue: 0),
    (Key: 'PIECECREATOR'; MaxValue: 0),
    (Key: 'PRISON'; MaxValue: 10),
    (Key: 'SHIELD'; MaxValue: 500),
    (Key: 'SPEED'; MaxValue: 0),
    (Key: 'SPRINTER'; MaxValue: 0),
    (Key: 'TERMINATOR'; MaxValue: 0),
    (Key: 'MASTER'; MaxValue: 0),
    (Key: 'POSTMAN'; MaxValue: 10),
    (Key: 'HULL'; MaxValue: 0),
    (Key: 'PIRATE'; MaxValue: 10),
    (Key: 'FRY'; MaxValue: 10),
    (Key: 'COALLITION'; MaxValue: 0),
    (Key: 'DEALER'; MaxValue: 5000000),
    (Key: 'JUMPER'; MaxValue: 500),
    (Key: 'DEFENDER'; MaxValue: 20),
    (Key: 'NEGOCIANT'; MaxValue: 15),
    (Key: 'HATER'; MaxValue: 0),
    (Key: 'CREDITOR'; MaxValue: 3),
    (Key: 'HOLEPEACE'; MaxValue: 0),
    (Key: 'SKILL'; MaxValue: 0),
    (Key: 'GUARD'; MaxValue: 30),
    (Key: 'SCIENCE'; MaxValue: 0),
    (Key: 'IRONMAN'; MaxValue: 40),
    (Key: 'BOMBER'; MaxValue: 0),
    (Key: 'ROCKET'; MaxValue: 150),
    (Key: 'CONTRABAND'; MaxValue: 200),
    (Key: 'ASTEROID'; MaxValue: 100),
    (Key: 'QUEST'; MaxValue: 30),
    (Key: 'KELLERRESEARCH'; MaxValue: 0),
    (Key: 'KELLERDESTROY'; MaxValue: 0),
    (Key: 'BLAZERPROGRAM'; MaxValue: 0),
    (Key: 'BLAZERPIECE'; MaxValue: 0),
    (Key: 'TERRONSTAR'; MaxValue: 0),
    (Key: 'TERRONBATTLE'; MaxValue: 0),
    (Key: 'PIRATESYSTEMS'; MaxValue: 0),
    (Key: 'NODES'; MaxValue: 0),
    (Key: 'RATING'; MaxValue: 0),
    (Key: 'RUINS'; MaxValue: 20),
    (Key: 'PIRATEWIN'; MaxValue: 0),
    (Key: 'BEST'; MaxValue: 0),
    (Key: 'COMMANDOR'; MaxValue: 0),
    (Key: 'BARON'; MaxValue: 0),
    (Key: 'GIRLSQUEST'; MaxValue: 0),
    (Key: 'GIRLSHIRE'; MaxValue: 0),
    (Key: 'SHU'; MaxValue: 0),
    (Key: 'SIDECHANGER'; MaxValue: 15),
    (Key: 'ENERGY'; MaxValue: 250),
    (Key: 'SCRATCHDAMAGE'; MaxValue: 0),
    (Key: 'SPLINTER'; MaxValue: 200),
    (Key: 'EXPLORER'; MaxValue: 100),
    (Key: 'TRANCLUCATORS'; MaxValue: 0),
    (Key: 'SUNFUEL'; MaxValue: 0),
    (Key: 'TERRORIST'; MaxValue: 30),
    (Key: 'COUNTERTERRORIST'; MaxValue: 30),
    (Key: 'BLUEKILLS'; MaxValue: 500),
    (Key: 'GREENKILLS'; MaxValue: 500),
    (Key: 'REDKILLS'; MaxValue: 500),
    (Key: 'BERTORSLAYER'; MaxValue: 50),
    (Key: 'MAPBUILDER'; MaxValue: 0),
    (Key: 'HACKER'; MaxValue: 100),
    (Key: 'DELIVERY'; MaxValue: 50),
    (Key: 'INVESTOR'; MaxValue: 0),
    (Key: 'INSURANCE'; MaxValue: 0),
    (Key: 'PRISONBAIL'; MaxValue: 30),
    (Key: 'ROBBER'; MaxValue: 100),
    (Key: 'WARRIORKILLS'; MaxValue: 100),
    (Key: 'DRAIN'; MaxValue: 10000)
  ); // @addr $87B0B4


type
  TAchievementStats = class(TObject) // @size 0x30
  public
    AsteroidsDestroyed: Integer; // @offset $04 ASTEROID: player asteroid kills in TStar.ProcessPlayerAsteroidKill ($7AFA44).
    EnemiesDestroyedByStarHeat: Integer; // @offset $08 FRY counter.
    SystemsDefended: Integer; // @offset $0C DEFENDER: qualifying Coalition or pirate defenses; native increments $7C30AC/$7C3137.
    SystemsCapturedForPirates: Integer; // @offset $10 PIRATE progress, qualifying system captures.
    CompletedResearchPrograms: Byte; // @offset $14 SCIENCE counts completed Dominator research programs.
    SuccessfulDominatorHacks: Integer; // @offset $18 HACKER: accepted programs in TfTalk.RunDominatorProgram; native increment $6E263A.
    PrisonersBailedOut: Integer; // @offset $1C PRISONBAIL: ships released by TfGov.PayPrisonBail; native increment $6D09C9.
    DrainedHullPoints: Integer; // @offset $20 Hull restored by the player's draining weapons; DRAIN progress.
    StarFuelCollected: Cardinal; // @offset $24 SUNFUEL counter for the current fuel tank.
    StarFuelTankId: Integer; // @offset $28 Resets the counter when the installed tank changes.
    UninhabitedPlanetsVisited: Integer; // @offset 0x2C  First player landings while OwnerId=6; EXPLORER progress.
    constructor Create; // @addr $593348
    destructor Destroy; override; // @addr $5933E0
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr $593414 Includes the pre-version-99 counter layout.
    procedure SaveToBuffer(Buffer: TBufEC); // @addr $593588
    // These checks use global player/galaxy state. Victory and score eligibility
    // are checked by the caller; the instance counters are not used here.
    procedure CheckAllSkillsAchievement; // @addr $593BBC SKILL: all six player base skills are at least level six.
    procedure CheckMoneyAchievement; // @addr $593954 MONEY: at least 10000000 credits.
    procedure CheckMasterAchievement; // @addr $59399C MASTER: at least six player wingmen.
    procedure CheckAllDiseasesAchievement; // @addr $594038 ILL: the player has experienced every one of the twelve diseases.
    procedure CheckNoShotsArcadeVictoryAchievement; // @addr $593914 @note "Caller establishes a victory without firing; native HOLEPEACE unlock."
    procedure CheckScratchDamageAchievement(HitsReceived: Integer); // @addr $5940FC SCRATCHDAMAGE: twenty one-point hits on the same target.
    procedure CheckStarFuelAchievement; // @addr $594150 SUNFUEL threshold: 40 units in one fuel tank.
    procedure CheckSpeedAchievement; // @addr $593C24 Native SPEED threshold: calculated speed 2300.
    procedure CheckBestEquipmentAchievement; // @addr $593E98 Native BEST check: all direct slots and five weapons have nonstandard stats.
    procedure CheckBaronAchievement; // @addr $593D18 Requires player pirate rank 7.
    procedure CheckAllAwardsAchievement; // @addr $59367C Native award-presence buffer is left uninitialized by reversed FillChar arguments.
    procedure CheckHaterAchievement; // @addr 0x593DB0 @note "HATER requires at least one inhabited planet in Coalition-controlled systems and hostile relations with every such planet."
    procedure CheckNoQuestVictoryAchievement; // @addr 0x593800
    procedure CheckChampionVictoryAchievement(Score: Integer); // @addr 0x59387C @note "CHAMPION requires at least 50000 points."
    procedure CheckNoLoadVictoryAchievement; // @addr 0x5938CC
    procedure CheckLongGameVictoryAchievement(Score, FinishedTurn: Integer); // @addr 0x593A30 @note "DOLGOZHID requires at least 20000 points and turn 36800."
    procedure CheckPacifistVictoryAchievement; // @addr 0x593A80
    procedure CheckFirstPlaceRatingAchievement; // @addr 0x593B60 @note "Requires PlaceInRating=1 and CurrentTurn>=300."
    procedure CheckNodesAchievement; // @addr $5939E8
    procedure CheckCommanderAchievement; // @addr $593D60
    procedure CheckAllDrugsAchievement; // @addr $594094
    procedure CheckMapBuilderAchievement; // @addr $594194
    procedure CheckInvestorAchievement(Amount: Integer); // @addr $59427C
    procedure CheckScienceAchievement; // @addr $593CD4
    procedure CheckFastVictoryAchievement; // @addr 0x593C6C @note "SPRINTER requires fewer than seven elapsed years after turn 300."
    procedure CheckAllPirateSystemsAchievement; // @addr $593AD4 PIRATESYSTEMS: every registered star is pirate-controlled.
    procedure CheckBomberAchievement(KillsThisTurn: Integer); // @addr 0x593634 @note "BOMBER requires at least five kills and a current player/galaxy."
    procedure CheckTranclucatorFleetAchievement; // @addr 0x5942CC @note "TRANCLUCATORS requires ten live, normal-space Tranclucators owned by the player in the current star."
  end;

function GetCurrentAchievementProgress(Key: WideString; StoredValue: Integer): Integer; // @addr $5930B4

function GetAchievementBackend: Byte; // @addr $59457C 1=Steam, 2=Steam without achievement support, 3=local.
function GetAvailableAchievementCount: Integer; // @addr $5945B0 Capped at 82.
function CreateAchievementData: PAchievementData; // @addr $594BEC Allocates three 255-character caller-owned string buffers.
procedure FreeAchievementData(Data: PAchievementData); // @addr $594C6C Nil-safe; releases all three string cells and the record.
function GetAchievementData(Key: WideString): PAchievementData; // @addr $594AF4 Caller owns the result; nil for an unknown key.

function TryUnlockAchievement(Key: WideString): Boolean; // @addr 0x594610 @note "Checks availability, unlock budget and per-save duplicates; records successful unlocks in the current player's AwardedAchievementKeys."

function TrySetAchievementProgress(Key: WideString; Value: Integer): Boolean; // @addr $594918 @note "Raises progress to the supplied value, capped at the target; never reduces existing progress."

function TryAddAchievementProgress(Key: WideString; Amount: Integer): Boolean; // @addr 0x594764 @note "Caps the increment at the configured achievement target; checks platform availability and per-save completion."


var
  AchievementDefinitions: TBlockParEC = nil; // @addr $87B34C

procedure InitializeAchievementDefinitions; // @addr $5943B4

implementation

// @unit-initialization $8778A8
// @unit-finalization $594CA8

uses aRanger, aShip, aTranclucator, SysUtils, Math, WStringUtils, NoSteamAchievemens, GlobalsV, aPlayer, aGalaxy, aPlanet, aGalaxyStruct, GR_Main;

{ @routine $5930B4 GetCurrentAchievementProgress }
function GetCurrentAchievementProgress(Key: WideString; StoredValue: Integer): Integer;
var
  Stats: TAchievementStats;
begin
  Result := 0;
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
  begin
    Stats := GetPlayer.AchievementStats;
    if Key = 'ASTEROID' then Result := Stats.AsteroidsDestroyed
    else if Key = 'FRY' then Result := Stats.EnemiesDestroyedByStarHeat
    else if Key = 'DEFENDER' then Result := Stats.SystemsDefended
    else if Key = 'PIRATE' then Result := Stats.SystemsCapturedForPirates
    else if Key = 'SCIENCE' then Result := Integer(Stats.CompletedResearchPrograms)
    else if Key = 'HACKER' then Result := Stats.SuccessfulDominatorHacks
    else if Key = 'PRISONBAIL' then Result := Stats.PrisonersBailedOut
    else if Key = 'DRAIN' then Result := Stats.DrainedHullPoints
    else if Key = 'BERTORSLAYER' then Result := GetPlayer.DominatorKillsByType[Ord(ktBertor)]
    else if Key = 'SIDECHANGER' then Result := GetPlayer.SideChangeCount
    ;
    if Result = StoredValue then Result := 0;
  end;
end;
{ @end $5930B4 }

{ @routine $593348 TAchievementStats_Create }
constructor TAchievementStats.Create;
begin
  inherited Create;
  AsteroidsDestroyed := 0;
  EnemiesDestroyedByStarHeat := 0;
  SystemsDefended := 0;
  SystemsCapturedForPirates := 0;
  CompletedResearchPrograms := 0;
  SuccessfulDominatorHacks := 0;
  PrisonersBailedOut := 0;
  DrainedHullPoints := 0;
  StarFuelCollected := 0;
  StarFuelTankId := 0;
  UninhabitedPlanetsVisited := 0;
end;
{ @end $593348 }

{ @routine $5933E0 TAchievementStats_Destroy }
destructor TAchievementStats.Destroy;
begin
  inherited Destroy;
end;
{ @end $5933E0 }

{ @routine $593414 TAchievementStats_LoadFromBuffer }
procedure TAchievementStats.LoadFromBuffer(Buffer: TBufEC);
begin
  if LoadedSaveVersion >= 99 then
  begin
    AsteroidsDestroyed := Buffer.GetUInt32;
    EnemiesDestroyedByStarHeat := Buffer.GetUInt32;
    SystemsDefended := Buffer.GetUInt32;
    SystemsCapturedForPirates := Buffer.GetUInt32;
    CompletedResearchPrograms := Buffer.GetByte;
    SuccessfulDominatorHacks := Buffer.GetUInt32;
    PrisonersBailedOut := Buffer.GetUInt32;
    DrainedHullPoints := Buffer.GetUInt32;
    StarFuelCollected := Buffer.GetUInt32;
    StarFuelTankId := Buffer.GetUInt32;
    UninhabitedPlanetsVisited := Buffer.GetUInt32;
  end
  else
  begin
    AsteroidsDestroyed := Buffer.GetUInt32;
    Buffer.GetUInt32;
    Buffer.GetUInt32;
    Buffer.GetUInt32;
    EnemiesDestroyedByStarHeat := Buffer.GetUInt32;
    Buffer.GetUInt32;
    Buffer.GetUInt32;
    SystemsDefended := Buffer.GetUInt32;
    SystemsCapturedForPirates := Buffer.GetUInt32;
    CompletedResearchPrograms := Buffer.GetByte;
    Buffer.GetUInt32;
    Buffer.GetUInt32;
    Buffer.GetUInt32;
    SuccessfulDominatorHacks := 0;
    PrisonersBailedOut := 0;
    DrainedHullPoints := 0;
    StarFuelCollected := 0;
    StarFuelTankId := 0;
    UninhabitedPlanetsVisited := 0;
  end;
end;
{ @end $593414 }

{ @routine $593588 TAchievementStats_SaveToBuffer }
procedure TAchievementStats.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddDWord(AsteroidsDestroyed);
  Buffer.AddDWord(EnemiesDestroyedByStarHeat);
  Buffer.AddDWord(SystemsDefended);
  Buffer.AddDWord(SystemsCapturedForPirates);
  Buffer.AddAnsiChar(AnsiChar(CompletedResearchPrograms));
  Buffer.AddDWord(SuccessfulDominatorHacks);
  Buffer.AddDWord(PrisonersBailedOut);
  Buffer.AddDWord(DrainedHullPoints);
  Buffer.AddDWord(StarFuelCollected);
  Buffer.AddDWord(StarFuelTankId);
  Buffer.AddDWord(UninhabitedPlanetsVisited);
end;
{ @end $593588 }

{ @routine $593634 TAchievementStats_CheckBomberAchievement }
procedure TAchievementStats.CheckBomberAchievement(KillsThisTurn: Integer);
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if KillsThisTurn >= 5 then TryUnlockAchievement('BOMBER');
end;
{ @end $593634 }

{ @routine $59367C TAchievementStats_CheckAllAwardsAchievement }
procedure TAchievementStats.CheckAllAwardsAchievement;
var
  I, LastAward: Integer;
  AllPresent: Boolean;
  AwardId: Byte;
  Present: array[0..255] of Boolean;
begin
  { Native argument order is reversed: count zero leaves this buffer uninitialized. }
  FillChar(Present, 0, SizeOf(Present));
  LastAward := StrToInt(LookupLocalizedTextByKey('Reward.Count')) - 1;
  AllPresent := True;
  if (GetPlayer <> nil) and (GetPlayer.AwardIds <> nil) then
  begin
    for I := 0 to GetPlayer.AwardIds.Count - 1 do
    begin
      AwardId := Byte(GetPlayer.AwardIds[I]);
      Present[AwardId] := True;
    end;
    for I := 0 to LastAward do AllPresent := AllPresent and Present[I];
    if AllPresent then TryUnlockAchievement('BREZHNEV');
  end;
end;
{ @end $59367C }

{ @routine $593800 TAchievementStats_CheckNoQuestVictoryAchievement }
procedure TAchievementStats.CheckNoQuestVictoryAchievement;
var I: Integer; Quest: PPlayerOldQuest;
begin
  if GetPlayer <> nil then
    if PlayerOldQuests <> nil then
      for I := 0 to PlayerOldQuests.Count - 1 do
      begin
        Quest := PlayerOldQuests[I];
        if Quest.Successful then Exit;
      end;
  TryUnlockAchievement('BUMMER');
end;
{ @end $593800 }

{ @routine $59387C TAchievementStats_CheckChampionVictoryAchievement }
procedure TAchievementStats.CheckChampionVictoryAchievement(Score: Integer);
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (Score >= 50000) then TryUnlockAchievement('CHAMPION');
end;
{ @end $59387C }

{ @routine $5938CC TAchievementStats_CheckNoLoadVictoryAchievement }
procedure TAchievementStats.CheckNoLoadVictoryAchievement;
begin
  if (Galaxy <> nil) and (Galaxy.LoadCount = 0) then TryUnlockAchievement('KIBERMAN');
end;
{ @end $5938CC }

{ @routine $593914 TAchievementStats_CheckNoShotsArcadeVictoryAchievement }
procedure TAchievementStats.CheckNoShotsArcadeVictoryAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) then TryUnlockAchievement('HOLEPEACE');
end;
{ @end $593914 }

{ @routine $593954 TAchievementStats_CheckMoneyAchievement }
procedure TAchievementStats.CheckMoneyAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (GetPlayer.Money >= 10000000) then
    TryUnlockAchievement('MONEY');
end;
{ @end $593954 }

{ @routine $59399C TAchievementStats_CheckMasterAchievement }
procedure TAchievementStats.CheckMasterAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (GetPlayer.CountWingmen >= 6) then TryUnlockAchievement('MASTER');
end;
{ @end $59399C }

{ @routine $5939E8 TAchievementStats_CheckNodesAchievement }
procedure TAchievementStats.CheckNodesAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (GetPlayer.BaseNodes >= 25000) then TryUnlockAchievement('NODES');
end;
{ @end $5939E8 }

{ @routine $593A30 TAchievementStats_CheckLongGameVictoryAchievement }
procedure TAchievementStats.CheckLongGameVictoryAchievement(Score, FinishedTurn: Integer);
begin
  if (GetPlayer <> nil) and (Score >= 20000) and (FinishedTurn >= 36800) then TryUnlockAchievement('DOLGOZHID');
end;
{ @end $593A30 }

{ @routine $593A80 TAchievementStats_CheckPacifistVictoryAchievement }
procedure TAchievementStats.CheckPacifistVictoryAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (GetPlayer.TotalShipKillCount = 0) then TryUnlockAchievement('PEACELOVER');
end;
{ @end $593A80 }

{ @routine $593AD4 TAchievementStats_CheckAllPirateSystemsAchievement }
procedure TAchievementStats.CheckAllPirateSystemsAchievement;
var Index: Integer; Star: TStar; AllPirateSystems: Boolean;
begin
  AllPirateSystems := True;
  for Index := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[Index];
    if Star.ControlFaction <> sfPirates then
    begin
      AllPirateSystems := False;
      Break;
    end;
  end;
  if AllPirateSystems then TryUnlockAchievement('PIRATESYSTEMS');
end;
{ @end $593AD4 }

{ @routine $593B60 TAchievementStats_CheckFirstPlaceRatingAchievement }
procedure TAchievementStats.CheckFirstPlaceRatingAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (Galaxy.CurrentTurn >= 300) and
     (GetPlayer.PlaceInRating = 1) then TryUnlockAchievement('RATING');
end;
{ @end $593B60 }

{ @routine $593BBC TAchievementStats_CheckAllSkillsAchievement }
procedure TAchievementStats.CheckAllSkillsAchievement;
var Skill: TPilotSkill; Complete: Boolean;
begin
  Complete := True;
  if (GetPlayer <> nil) and (Galaxy <> nil) then begin
    for Skill := Low(TPilotSkill) to High(TPilotSkill) do
      if GetPlayer.GetBaseSkillLevel(Skill) < 6 then Complete := False;
    if Complete then TryUnlockAchievement('SKILL');
  end;
end;
{ @end $593BBC }

{ @routine $593C24 TAchievementStats_CheckSpeedAchievement }
procedure TAchievementStats.CheckSpeedAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (GetPlayer.CalculateSpeed >= 2300) then TryUnlockAchievement('SPEED');
end;
{ @end $593C24 }

{ @routine $593C6C TAchievementStats_CheckFastVictoryAchievement }
procedure TAchievementStats.CheckFastVictoryAchievement;
var Elapsed: Integer;
begin
  if Galaxy <> nil then
  begin
    Elapsed := Galaxy.CurrentTurn - 300;
    if Elapsed / 365.0 < 7.0 then TryUnlockAchievement('SPRINTER');
  end;
end;
{ @end $593C6C }

{ @routine $593CD4 TAchievementStats_CheckScienceAchievement }
procedure TAchievementStats.CheckScienceAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (CompletedResearchPrograms >= 3) then TryUnlockAchievement('SCIENCE');
end;
{ @end $593CD4 }

{ @routine $593D18 TAchievementStats_CheckBaronAchievement }
procedure TAchievementStats.CheckBaronAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (GetPlayer.PirateRank = 7) then
    TryUnlockAchievement('BARON');
end;
{ @end $593D18 }

{ @routine $593D60 TAchievementStats_CheckCommanderAchievement }
procedure TAchievementStats.CheckCommanderAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (GetPlayer.Rank = 7) then TryUnlockAchievement('COMMANDOR');
end;
{ @end $593D60 }

{ @routine $593DB0 TAchievementStats_CheckHaterAchievement }
procedure TAchievementStats.CheckHaterAchievement;
var
  I, J, Count: Integer;
  Star: TStar;
  Planet: TPlanet;
begin
  Count := 0;
  if (GetPlayer = nil) or (Galaxy = nil) then Exit;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if Star.ControlFaction = sfCoalition then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        if Planet.OwnerId <> oiUninhabited then
        begin
          Inc(Count);
          if Planet.GetRelationLevelToShip(GetPlayer) > rlHostile then Exit;
        end;
      end;
  end;
  if Count > 0 then TryUnlockAchievement('HATER');
end;
{ @end $593DB0 }

{ @routine $593E98 TAchievementStats_CheckBestEquipmentAchievement }
procedure TAchievementStats.CheckBestEquipmentAchievement;
var
  I: Integer;
begin
  if (GetPlayer = nil) or (Galaxy = nil) then Exit;
  if GetPlayer.GetHull.HasStandardStats then Exit;
  if (GetPlayer.GetFuelTanks = nil) or GetPlayer.GetFuelTanks.HasStandardStats then Exit;
  if (GetPlayer.GetEngine = nil) or GetPlayer.GetEngine.HasStandardStats then Exit;
  if (GetPlayer.GetRadar = nil) or GetPlayer.GetRadar.HasStandardStats then Exit;
  if (GetPlayer.GetScanner = nil) or GetPlayer.GetScanner.HasStandardStats then Exit;
  if (GetPlayer.GetRepairRobot = nil) or GetPlayer.GetRepairRobot.HasStandardStats then Exit;
  if (GetPlayer.GetCargoHook = nil) or GetPlayer.GetCargoHook.HasStandardStats then Exit;
  if (GetPlayer.GetDefGenerator = nil) or GetPlayer.GetDefGenerator.HasStandardStats then Exit;
  if GetPlayer.CountEquippedWeapons < 5 then Exit;
  for I := 1 to 5 do if GetPlayer.Weapons[I].HasStandardStats then Exit;
  TryUnlockAchievement('BEST');
end;
{ @end $593E98 }

{ @routine $594038 TAchievementStats_CheckAllDiseasesAchievement }
procedure TAchievementStats.CheckAllDiseasesAchievement;
var I: Integer;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) then
  begin
    for I := 1 to 12 do
      if GetPlayer.CaptainHealth[I].ApplicationCount = 0 then Exit;
    TryUnlockAchievement('ILL');
  end;
end;
{ @end $594038 }

{ @routine $594094 TAchievementStats_CheckAllDrugsAchievement }
procedure TAchievementStats.CheckAllDrugsAchievement;
var I: Integer;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) then begin
    for I := 13 to 24 do
      if GetPlayer.CaptainHealth[I].ApplicationCount = 0 then Exit;
    TryUnlockAchievement('NARKOMAN');
  end;
end;
{ @end $594094 }

{ @routine $5940FC TAchievementStats_CheckScratchDamageAchievement }
procedure TAchievementStats.CheckScratchDamageAchievement(HitsReceived: Integer);
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (HitsReceived >= 20) then
    TryUnlockAchievement('SCRATCHDAMAGE');
end;
{ @end $5940FC }

{ @routine $594150 TAchievementStats_CheckStarFuelAchievement }
procedure TAchievementStats.CheckStarFuelAchievement;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (StarFuelCollected >= 40) then
    TryUnlockAchievement('SUNFUEL');
end;
{ @end $594150 }

{ @routine $594194 TAchievementStats_CheckMapBuilderAchievement }
procedure TAchievementStats.CheckMapBuilderAchievement;
var I: Integer; Constellation: TConstellation; Year, Month, Day: Word;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) then begin
    DecodeDate(GameTurnToDateTime(Galaxy.CurrentTurn - 300), Year, Month, Day);
    if Year > 3304 then Exit;
    if (Year = 3304) and ((Month > 1) or (Day > 1)) then Exit;
    for I := 0 to Galaxy.Constellations.Count - 1 do begin
      Constellation := TConstellation(Galaxy.Constellations[I]);
      if (not Constellation.Visible) and (Constellation.Id <> 20) then Exit;
    end;
    TryUnlockAchievement('MAPBUILDER');
  end;
end;
{ @end $594194 }

{ @routine $59427C TAchievementStats_CheckInvestorAchievement }
procedure TAchievementStats.CheckInvestorAchievement(Amount: Integer);
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) and (Amount >= 300000) then TryUnlockAchievement('INVESTOR');
end;
{ @end $59427C }

{ @routine $5942CC TAchievementStats_CheckTranclucatorFleetAchievement }
procedure TAchievementStats.CheckTranclucatorFleetAchievement;
var I, Count: Integer; Ship: TShip; Star: TStar;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  Count := 0;
  Star := GetPlayer.CurrentStar;
  for I := 0 to Star.Ships.Count - 1 do
  begin
    Ship := Star.Ships[I];
    if Ship.InNormalSpace and not Ship.IsHullDestroyed and (Ship is TTranclucator) and
       ((Ship as TTranclucator).OwnerShip = GetPlayer) then Inc(Count);
  end;
  if Count >= 10 then TryUnlockAchievement('TRANCLUCATORS');
end;
{ @end $5942CC }

{ @routine $5943B4 InitializeAchievementDefinitions }
procedure InitializeAchievementDefinitions;
var
  Index: Integer;
  Block: TBlockParEC;
begin
  AchievementDefinitions := TBlockParEC.Create;
  // Entry zero is the native NONE sentinel and is not registered.
  for Index := 1 to 82 do
  begin
    Block := AchievementDefinitions.AddChildBlock(WideString(AchievementDefinitionTable[Index].Key));
    Block.AddParam('Id', WideString(AchievementDefinitionTable[Index].Key));
    Block.AddParam('Num', WideString(IntToStr(Index - 1)));
    Block.AddParam('MaxValue', WideString(IntToStr(AchievementDefinitionTable[Index].MaxValue)));
    Block.AddParam('Value', '0');
    Block.AddParam('Achieved', 'No');
    Block.AddParam('Date', '0');
  end;
end;
{ @end $5943B4 }

{ @routine $59457C GetAchievementBackend }
function GetAchievementBackend: Byte;
begin
  if SteamInitialized then
  begin
    if SteamAchievementsCount > 0 then Result := 1
    else Result := 2;
  end
  else Result := 3;
end;
{ @end $59457C }

{ @routine $5945B0 GetAvailableAchievementCount }
function GetAvailableAchievementCount: Integer;
begin
  case GetAchievementBackend of
    1: Result := Min(82, SteamAchievementsCount);
    3: Result := 82;
    2: Result := 0;
  else Result := 0;
  end;
end;
{ @end $5945B0 }

{ @routine $594610 TryUnlockAchievement }
function TryUnlockAchievement(Key: WideString): Boolean;
var Block: TBlockParEC;
begin
  Result := False;
  if Galaxy = nil then Exit;
  if not Galaxy.CanRecordAchievements then Exit;
  if (GetPlayer <> nil) and (GetPlayer.AwardedAchievementKeys.CountBlocks(Key) > 0) then Exit;
  if GetAvailableAchievementCount <= 0 then Exit;
  Block := AchievementDefinitions.FindBlock(Key);
  if Block = nil then Exit;
  case GetAchievementBackend of
    1: Result := SteamUnlockAchievement(StrToInt(AnsiString(Block.GetParam('Num'))));
    3: Result := UnlockLocalAchievement(Block);
    2: Result := False;
  else Result := False;
  end;
  if Result and (GetPlayer <> nil) then GetPlayer.AwardedAchievementKeys.AddChildBlock(Key);
end;
{ @end $594610 }

{ @routine $594764 TryAddAchievementProgress }
function TryAddAchievementProgress(Key: WideString; Amount: Integer): Boolean;
var Data: PAchievementData; Increment: Integer; Block: TBlockParEC;
begin
  Result := False;
  if Galaxy = nil then Exit;
  if not Galaxy.CanRecordAchievements then Exit;
  if (GetPlayer <> nil) and (GetPlayer.AwardedAchievementKeys.CountBlocks(Key) > 0) then Exit;
  if GetAvailableAchievementCount <= 0 then Exit;
  Block := AchievementDefinitions.FindBlock(Key);
  if Block = nil then Exit;
  Data := GetAchievementData(Key);
  if Amount + Data.Value <= Data.MaxValue then Increment := Amount
  else Increment := Data.MaxValue - Data.Value;
  case GetAchievementBackend of
    1: Result := SteamIncreaseStat(StrToInt(AnsiString(Block.GetParam('Num'))), Increment);
    3: Result := IncreaseLocalAchievementProgress(Block, Increment);
    2: Result := False;
  else Result := False;
  end;
  FreeAchievementData(Data);
  Data := GetAchievementData(Key);
  if (GetPlayer <> nil) and Data.Achieved then GetPlayer.AwardedAchievementKeys.AddChildBlock(Key);
  FreeAchievementData(Data);
end;
{ @end $594764 }

{ @routine $594918 TrySetAchievementProgress }
function TrySetAchievementProgress(Key: WideString; Value: Integer): Boolean;
var Data: PAchievementData; Increment: Integer; Block: TBlockParEC;
begin
  Result := False;
  if Galaxy = nil then Exit;
  if not Galaxy.CanRecordAchievements then Exit;
  if (GetPlayer <> nil) and (GetPlayer.AwardedAchievementKeys.CountBlocks(Key) > 0) then Exit;
  if GetAvailableAchievementCount <= 0 then Exit;
  Block := AchievementDefinitions.FindBlock(Key);
  if Block = nil then Exit;
  Data := GetAchievementData(Key);
  if (Value > Data.Value) and (Value <= Data.MaxValue) then Increment := Value - Data.Value
  else if Value > Data.MaxValue then Increment := Data.MaxValue - Data.Value
  else
  begin
    FreeAchievementData(Data);
    Exit;
  end;
  case GetAchievementBackend of
    1: Result := SteamIncreaseStat(StrToInt(AnsiString(Block.GetParam('Num'))), Increment);
    3: Result := IncreaseLocalAchievementProgress(Block, Increment);
    2: Result := False;
  else Result := False;
  end;
  FreeAchievementData(Data);
  Data := GetAchievementData(Key);
  if (GetPlayer <> nil) and Data.Achieved then GetPlayer.AwardedAchievementKeys.AddChildBlock(Key);
  FreeAchievementData(Data);
end;
{ @end $594918 }

{ @routine $594AF4 GetAchievementData }
function GetAchievementData(Key: WideString): PAchievementData;
var Block: TBlockParEC;
begin
  Result := nil;
  Block := AchievementDefinitions.FindBlock(Key);
  if Block <> nil then
  begin
    Result := CreateAchievementData;
    case GetAchievementBackend of
      1: SteamAchievementData(StrToInt(AnsiString(Block.GetParam('Num'))), Result);
      3: GetLocalAchievementData(Key, Result);
    end;
    TruncateStartupWideString(Result.Name);
    TruncateStartupWideString(Result.Description);
    TruncateStartupWideString(Result.IconPath);
  end;
end;
{ @end $594AF4 }

{ @routine $594BEC CreateAchievementData }
function CreateAchievementData: PAchievementData;
begin
  New(Result);
  Result.Name := AllocateStartupWideString(255);
  Result.Description := AllocateStartupWideString(255);
  Result.Achieved := False;
  Result.HasProgress := False;
  Result.Reserved0C := 0;
  Result.MaxValue := 0;
  Result.Value := 0;
  Result.IconPath := AllocateStartupWideString(255);
  Result.Date := 0;
end;
{ @end $594BEC }

{ @routine $594C6C FreeAchievementData }
procedure FreeAchievementData(Data: PAchievementData);
begin
  if Data <> nil then
  begin
    FreeStartupWideString(Data.Name);
    FreeStartupWideString(Data.Description);
    FreeStartupWideString(Data.IconPath);
    Dispose(Data);
  end;
end;
{ @end $594C6C }

end.
