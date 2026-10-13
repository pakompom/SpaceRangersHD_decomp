unit Achievements;

interface

uses EC_BlockPar, EC_Buf, SimpleSteamApi;

type
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
  ); // @addr $812B10

type
  TAchievementStats = class(TObject) // @size 0x30
  public
    AsteroidsDestroyed: Integer; // @offset $04 ASTEROID: player asteroid kills in TStar.ProcessPlayerAsteroidKill ($7E0B54).
    EnemiesDestroyedByStarHeat: Integer; // @offset $08 FRY counter.
    SystemsDefended: Integer; // @offset $0C DEFENDER: qualifying Coalition or pirate defenses.
    SystemsCapturedForPirates: Integer; // @offset $10 PIRATE progress, qualifying system captures.
    CompletedResearchPrograms: Byte; // @offset $14 SCIENCE counts completed Dominator research programs.
    SuccessfulDominatorHacks: Integer; // @offset $18 HACKER: accepted programs in TfTalk.RunDominatorProgram.
    PrisonersBailedOut: Integer; // @offset $1C PRISONBAIL: ships released by TfGov.PayPrisonBail.
    DrainedHullPoints: Integer; // @offset $20 Hull restored by the player's draining weapons; DRAIN progress.
    StarFuelCollected: Cardinal; // @offset $24 SUNFUEL counter for the current fuel tank.
    StarFuelTankId: Cardinal; // @offset $28 Resets the counter when the installed tank changes.
    UninhabitedPlanetsVisited: Integer; // @offset 0x2C  First player landings while OwnerId=6; EXPLORER progress.
    constructor Create; // @addr $79CB1C
    destructor Destroy; override; // @addr $79CB88
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr $79CBB0 Includes the pre-version-99 counter layout.
    procedure SaveToBuffer(Buffer: TBufEC); // @addr $79CCBC
    // These checks use global player/galaxy state. Victory and score eligibility
    // are checked by the caller; the instance counters are not used here.
    procedure CheckAllSkillsAchievement; // @addr $79D1F4 SKILL: all six player base skills are at least level six.
    procedure CheckMoneyAchievement; // @addr $79CFE4 MONEY: at least 10000000 credits.
    procedure CheckMasterAchievement; // @addr $79D024 MASTER: at least six player wingmen.
    procedure CheckAllDiseasesAchievement; // @addr $79D5FC ILL: the player has experienced every one of the twelve diseases.
    procedure CheckNoShotsArcadeVictoryAchievement; // @addr $79CFAC @note "Caller establishes a victory without firing; native HOLEPEACE unlock."
    procedure CheckScratchDamageAchievement(HitsReceived: Integer); // @addr $79D6A0 SCRATCHDAMAGE: twenty one-point hits on the same target.
    procedure CheckStarFuelAchievement; // @addr $79D6E8 SUNFUEL threshold: 40 units in one fuel tank.
    procedure CheckSpeedAchievement; // @addr $79D24C Native SPEED threshold: calculated speed 2300.
    procedure CheckBestEquipmentAchievement; // @addr $79D474 Native BEST check: all direct slots and five weapons have nonstandard stats.
    procedure CheckBaronAchievement; // @addr $79D328 Requires player pirate rank 7.
    procedure CheckAllAwardsAchievement; // @addr $79CD70 Native award-presence buffer is left uninitialized by reversed FillChar arguments.
    procedure CheckHaterAchievement; // @addr 0x0079D3A8 @note "HATER requires at least one inhabited planet in Coalition-controlled systems and hostile relations with every such planet."
    procedure CheckNoQuestVictoryAchievement; // @addr 0x0079CEC8
    procedure CheckChampionVictoryAchievement(Score: Integer); // @addr 0x0079CF28 @note "CHAMPION requires at least 50000 points."
    procedure CheckNoLoadVictoryAchievement; // @addr 0x0079CF6C
    procedure CheckLongGameVictoryAchievement(Score, FinishedTurn: Integer); // @addr 0x0079D0A8 @note "DOLGOZHID requires at least 20000 points and turn 36800."
    procedure CheckPacifistVictoryAchievement; // @addr 0x0079D0EC
    procedure CheckFirstPlaceRatingAchievement; // @addr 0x0079D1A0 @note "Requires PlaceInRating=1 and CurrentTurn>=300."
    procedure CheckNodesAchievement; // @addr $79D068
    procedure CheckCommanderAchievement; // @addr $79D364
    procedure CheckAllDrugsAchievement; // @addr $79D648
    procedure CheckMapBuilderAchievement; // @addr $79D724
    procedure CheckInvestorAchievement(Amount: Integer); // @addr $79D7F8
    procedure CheckScienceAchievement; // @addr $79D2EC
    procedure CheckFastVictoryAchievement; // @addr 0x0079D28C @note "SPRINTER requires fewer than seven elapsed years after turn 300."
    procedure CheckAllPirateSystemsAchievement; // @addr $79D134 PIRATESYSTEMS: every registered star is pirate-controlled.
    procedure CheckBomberAchievement(KillsThisTurn: Integer); // @addr 0x0079CD34 @note "BOMBER requires at least five kills and a current player/galaxy."
    procedure CheckTranclucatorFleetAchievement; // @addr 0x0079D83C @note "TRANCLUCATORS requires ten live, normal-space Tranclucators owned by the player in the current star."
  end;

function GetCurrentAchievementProgress(Key: WideString; StoredValue: Integer): Integer; // @addr $79C8D0

type
  TAchievementBackend = (
    achSteam = 1, // API reports achievement definitions.
    achSteamWithoutAchievements = 2, // Initialized without achievement definitions; recording disabled.
    achLocal = 3 // Local achievement storage.
  ); // @size $01

function GetAchievementBackend: TAchievementBackend; // @addr $79DAB8

function GetAvailableAchievementCount: Integer; // @addr $79DADC Capped at 82.
function CreateAchievementData: PAchievementData; // @addr $79E078 Allocates three 255-character caller-owned string buffers.
procedure FreeAchievementData(Data: PAchievementData); // @addr $79E0D4 Nil-safe; releases all three string cells and the record.
function GetAchievementData(Key: WideString): PAchievementData; // @addr $79DF94 Caller owns the result; nil for an unknown key.

function TryUnlockAchievement(Key: WideString): Boolean; // @addr 0x0079DB10 @note "Checks availability, unlock budget and per-save duplicates; records successful unlocks in the current player's AwardedAchievementKeys."

function TrySetAchievementProgress(Key: WideString; Value: Integer): Boolean; // @addr $79DDE8 @note "Raises progress to the supplied value, capped at the target; never reduces existing progress."

function TryAddAchievementProgress(Key: WideString; Amount: Integer): Boolean; // @addr 0x0079DC54 @note "Caps the increment at the configured achievement target; checks platform availability and per-save completion."

var
  AchievementDefinitions: TBlockParEC = nil; // @addr $812DA8

procedure InitializeAchievementDefinitions; // @addr $79D908

implementation

// @unit-initialization $8079C0
// @unit-finalization $79E100

uses aRanger, aShip, aTranclucator, SysUtils, Math, WStringUtils, NoSteamAchievemens, GlobalsV, aPlayer, aGalaxy, aPlanet, aGalaxyStruct, GR_Main;

{ @routine $79C8D0 GetCurrentAchievementProgress }
function GetCurrentAchievementProgress(Key: WideString; StoredValue: Integer): Integer;
var
  Stats: TAchievementStats;
begin
  Result := 0;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then Exit;
  Stats := GetPlayer.AchievementStats;
  if Key = 'ASTEROID' then Result := Stats.AsteroidsDestroyed
  else if Key = 'FRY' then Result := Stats.EnemiesDestroyedByStarHeat
  else if Key = 'DEFENDER' then Result := Stats.SystemsDefended
  else if Key = 'PIRATE' then Result := Stats.SystemsCapturedForPirates
  else if Key = 'SCIENCE' then Result := Stats.CompletedResearchPrograms
  else if Key = 'HACKER' then Result := Stats.SuccessfulDominatorHacks
  else if Key = 'PRISONBAIL' then Result := Stats.PrisonersBailedOut
  else if Key = 'DRAIN' then Result := Stats.DrainedHullPoints
  else if Key = 'BERTORSLAYER' then Result := GetPlayer.DominatorKillsByType[ktBertor]
  else if Key = 'SIDECHANGER' then Result := GetPlayer.SideChangeCount;
  if Result = StoredValue then Result := 0;
end;
{ @end $79C8D0 }

{ @routine $79CB1C TAchievementStats_Create }
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
{ @end $79CB1C }

{ @routine $79CB88 TAchievementStats_Destroy }
destructor TAchievementStats.Destroy;
begin
  inherited Destroy;
end;
{ @end $79CB88 }

{ @routine $79CBB0 TAchievementStats_LoadFromBuffer }
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
    Exit;
  end;
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
{ @end $79CBB0 }

{ @routine $79CCBC TAchievementStats_SaveToBuffer }
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
{ @end $79CCBC }

{ @routine $79CD34 TAchievementStats_CheckBomberAchievement }
procedure TAchievementStats.CheckBomberAchievement(KillsThisTurn: Integer);
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if KillsThisTurn >= 5 then TryUnlockAchievement('BOMBER');
end;
{ @end $79CD34 }

{ @routine $79CD70 TAchievementStats_CheckAllAwardsAchievement }
procedure TAchievementStats.CheckAllAwardsAchievement;
var
  I, LastAward: Integer;
  AllPresent: Boolean;
  AwardId: Byte;
  Present: array[Byte] of Boolean;
begin
  { Native argument order is reversed: count zero leaves this buffer uninitialized. }
  FillChar(Present, 0, SizeOf(Present));
  LastAward := StrToInt(LookupLocalizedTextByKey('Reward.Count')) - 1;
  AllPresent := True;
  if (GetPlayer = nil) or (GetPlayer.AwardIds = nil) then Exit;
  for I := 0 to GetPlayer.AwardIds.Count - 1 do
  begin
    AwardId := Byte(GetPlayer.AwardIds[I]);
    Present[AwardId] := True;
  end;
  for I := 0 to LastAward do AllPresent := AllPresent and Present[I];
  if AllPresent then TryUnlockAchievement('BREZHNEV');
end;
{ @end $79CD70 }

{ @routine $79CEC8 TAchievementStats_CheckNoQuestVictoryAchievement }
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
{ @end $79CEC8 }

{ @routine $79CF28 TAchievementStats_CheckChampionVictoryAchievement }
procedure TAchievementStats.CheckChampionVictoryAchievement(Score: Integer);
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if Score < 50000 then Exit;
  TryUnlockAchievement('CHAMPION');
end;
{ @end $79CF28 }

{ @routine $79CF6C TAchievementStats_CheckNoLoadVictoryAchievement }
procedure TAchievementStats.CheckNoLoadVictoryAchievement;
begin
  if Galaxy = nil then Exit;
  if Galaxy.LoadCount <> 0 then Exit;
  TryUnlockAchievement('KIBERMAN');
end;
{ @end $79CF6C }

{ @routine $79CFAC TAchievementStats_CheckNoShotsArcadeVictoryAchievement }
procedure TAchievementStats.CheckNoShotsArcadeVictoryAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  TryUnlockAchievement('HOLEPEACE');
end;
{ @end $79CFAC }

{ @routine $79CFE4 TAchievementStats_CheckMoneyAchievement }
procedure TAchievementStats.CheckMoneyAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if GetPlayer.Money < 10000000 then Exit;
  TryUnlockAchievement('MONEY');
end;
{ @end $79CFE4 }

{ @routine $79D024 TAchievementStats_CheckMasterAchievement }
procedure TAchievementStats.CheckMasterAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if GetPlayer.CountWingmen < 6 then Exit;
  TryUnlockAchievement('MASTER');
end;
{ @end $79D024 }

{ @routine $79D068 TAchievementStats_CheckNodesAchievement }
procedure TAchievementStats.CheckNodesAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if GetPlayer.BaseNodes < 25000 then Exit;
  TryUnlockAchievement('NODES');
end;
{ @end $79D068 }

{ @routine $79D0A8 TAchievementStats_CheckLongGameVictoryAchievement }
procedure TAchievementStats.CheckLongGameVictoryAchievement(Score, FinishedTurn: Integer);
begin
  if GetPlayer = nil then Exit;
  if Score < 20000 then Exit;
  if FinishedTurn < 36800 then Exit;
  TryUnlockAchievement('DOLGOZHID');
end;
{ @end $79D0A8 }

{ @routine $79D0EC TAchievementStats_CheckPacifistVictoryAchievement }
procedure TAchievementStats.CheckPacifistVictoryAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if GetPlayer.TotalShipKillCount <> 0 then Exit;
  TryUnlockAchievement('PEACELOVER');
end;
{ @end $79D0EC }

{ @routine $79D134 TAchievementStats_CheckAllPirateSystemsAchievement }
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
{ @end $79D134 }

{ @routine $79D1A0 TAchievementStats_CheckFirstPlaceRatingAchievement }
procedure TAchievementStats.CheckFirstPlaceRatingAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if Galaxy.CurrentTurn < GalaxyWarmupTurns then Exit;
  if GetPlayer.PlaceInRating <> 1 then Exit;
  TryUnlockAchievement('RATING');
end;
{ @end $79D1A0 }

{ @routine $79D1F4 TAchievementStats_CheckAllSkillsAchievement }
procedure TAchievementStats.CheckAllSkillsAchievement;
var Skill: TPilotSkill; Complete: Boolean;
begin
  Complete := True;
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  for Skill := Low(TPilotSkill) to High(TPilotSkill) do
    if GetPlayer.GetBaseSkillLevel(Skill) < High(TPilotSkillLevel) then Complete := False;
  if Complete then TryUnlockAchievement('SKILL');
end;
{ @end $79D1F4 }

{ @routine $79D24C TAchievementStats_CheckSpeedAchievement }
procedure TAchievementStats.CheckSpeedAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if GetPlayer.CalculateSpeed < 2300 then Exit;
  TryUnlockAchievement('SPEED');
end;
{ @end $79D24C }

{ @routine $79D28C TAchievementStats_CheckFastVictoryAchievement }
procedure TAchievementStats.CheckFastVictoryAchievement;
begin
  if Galaxy = nil then Exit;
  if (Galaxy.CurrentTurn - GalaxyWarmupTurns) / 365.0 < 7.0 then TryUnlockAchievement('SPRINTER');
end;
{ @end $79D28C }

{ @routine $79D2EC TAchievementStats_CheckScienceAchievement }
procedure TAchievementStats.CheckScienceAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if CompletedResearchPrograms < 3 then Exit;
  TryUnlockAchievement('SCIENCE');
end;
{ @end $79D2EC }

{ @routine $79D328 TAchievementStats_CheckBaronAchievement }
procedure TAchievementStats.CheckBaronAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if GetPlayer.PirateRank <> High(TShipRank) then Exit;
  TryUnlockAchievement('BARON');
end;
{ @end $79D328 }

{ @routine $79D364 TAchievementStats_CheckCommanderAchievement }
procedure TAchievementStats.CheckCommanderAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if GetPlayer.Rank <> High(TShipRank) then Exit;
  TryUnlockAchievement('COMMANDOR');
end;
{ @end $79D364 }

{ @routine $79D3A8 TAchievementStats_CheckHaterAchievement }
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
        if Planet.OwnerId = oiUninhabited then Continue;
        Inc(Count);
        if Planet.GetRelationLevelToShip(GetPlayer) > rlHostile then Exit;
      end;
  end;
  if Count > 0 then TryUnlockAchievement('HATER');
end;
{ @end $79D3A8 }

{ @routine $79D474 TAchievementStats_CheckBestEquipmentAchievement }
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
  for I := Low(GetPlayer.Weapons) to High(GetPlayer.Weapons) do
    if GetPlayer.Weapons[I].HasStandardStats then Exit;
  TryUnlockAchievement('BEST');
end;
{ @end $79D474 }

{ @routine $79D5FC TAchievementStats_CheckAllDiseasesAchievement }
procedure TAchievementStats.CheckAllDiseasesAchievement;
var I: TCaptainHealthEffect;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  for I := Low(TCaptainDisease) to High(TCaptainDisease) do
    if GetPlayer.CaptainHealth[I].ApplicationCount = 0 then Exit;
  TryUnlockAchievement('ILL');
end;
{ @end $79D5FC }

{ @routine $79D648 TAchievementStats_CheckAllDrugsAchievement }
procedure TAchievementStats.CheckAllDrugsAchievement;
var I: TCaptainHealthEffect;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  for I := Low(TCaptainStimulant) to High(TCaptainStimulant) do
    if GetPlayer.CaptainHealth[I].ApplicationCount = 0 then Exit;
  TryUnlockAchievement('NARKOMAN');
end;
{ @end $79D648 }

{ @routine $79D6A0 TAchievementStats_CheckScratchDamageAchievement }
procedure TAchievementStats.CheckScratchDamageAchievement(HitsReceived: Integer);
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if HitsReceived < 20 then Exit;
  TryUnlockAchievement('SCRATCHDAMAGE');
end;
{ @end $79D6A0 }

{ @routine $79D6E8 TAchievementStats_CheckStarFuelAchievement }
procedure TAchievementStats.CheckStarFuelAchievement;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if StarFuelCollected < 40 then Exit;
  TryUnlockAchievement('SUNFUEL');
end;
{ @end $79D6E8 }

{ @routine $79D724 TAchievementStats_CheckMapBuilderAchievement }
procedure TAchievementStats.CheckMapBuilderAchievement;
var
  I: Integer;
  Constellation: TConstellation;
  Year, Month, Day: Word;
begin
  if (GetPlayer <> nil) and (Galaxy <> nil) then
  begin
    DecodeDate(GameTurnToDateTime(Galaxy.CurrentTurn - GalaxyWarmupTurns), Year, Month, Day);
    if Year > 3304 then Exit;
    if (Year = 3304) and ((Month > 1) or (Day > 1)) then Exit;
    for I := 0 to Galaxy.Constellations.Count - 1 do
    begin
      Constellation := Galaxy.Constellations[I];
      if (not Constellation.Visible) and (Constellation.Id <> 20) then Exit;
    end;
    TryUnlockAchievement('MAPBUILDER');
  end;
end;
{ @end $79D724 }

{ @routine $79D7F8 TAchievementStats_CheckInvestorAchievement }
procedure TAchievementStats.CheckInvestorAchievement(Amount: Integer);
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if Amount < 300000 then Exit;
  TryUnlockAchievement('INVESTOR');
end;
{ @end $79D7F8 }

{ @routine $79D83C TAchievementStats_CheckTranclucatorFleetAchievement }
procedure TAchievementStats.CheckTranclucatorFleetAchievement;
var
  I, Count: Integer;
  Ship: TShip;
  Star: TStar;
begin
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  Count := 0;
  Star := GetPlayer.CurrentStar;
  for I := 0 to Star.Ships.Count - 1 do
  begin
    Ship := Star.Ships[I];
    if not (Ship.InNormalSpace and not Ship.IsHullDestroyed and
      (Ship is TTranclucator)) then Continue;
    if (Ship as TTranclucator).OwnerShip = GetPlayer then Inc(Count);
  end;
  if Count >= 10 then TryUnlockAchievement('TRANCLUCATORS');
end;
{ @end $79D83C }

{ @routine $79D908 InitializeAchievementDefinitions }
procedure InitializeAchievementDefinitions;
var
  Index: Integer;
  Block: TBlockParEC;
begin
  AchievementDefinitions := TBlockParEC.Create;
  // Entry zero is the native NONE sentinel and is not registered.
  for Index := 1 to High(AchievementDefinitionTable) do
  begin
    Block := AchievementDefinitions.AddChildBlock(AchievementDefinitionTable[Index].Key);
    Block.AddParam('Id', AchievementDefinitionTable[Index].Key);
    Block.AddParam('Num', IntToStr(Index - 1));
    Block.AddParam('MaxValue', IntToStr(AchievementDefinitionTable[Index].MaxValue));
    Block.AddParam('Value', '0');
    Block.AddParam('Achieved', 'No');
    Block.AddParam('Date', '0');
  end;
end;
{ @end $79D908 }

{ @routine $79DAB8 GetAchievementBackend }
function GetAchievementBackend: TAchievementBackend;
begin
  if SteamInitialized then
  begin
    if SteamAchievementsCount > 0 then Result := achSteam
    else Result := achSteamWithoutAchievements;
  end
  else Result := achLocal;
end;
{ @end $79DAB8 }

{ @routine $79DADC GetAvailableAchievementCount }
function GetAvailableAchievementCount: Integer;
begin
  case GetAchievementBackend of
    achSteam: Result := Min(High(AchievementDefinitionTable), SteamAchievementsCount);
    achLocal: Result := High(AchievementDefinitionTable);
    achSteamWithoutAchievements: Result := 0;
  else Result := 0;
  end;
end;
{ @end $79DADC }

{ @routine $79DB10 TryUnlockAchievement }
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
    achSteam: Result := SteamUnlockAchievement(StrToInt(AnsiString(Block.Params['Num'])));
    achLocal: Result := UnlockLocalAchievement(Block);
    achSteamWithoutAchievements: Result := False;
  else Result := False;
  end;
  if Result and (GetPlayer <> nil) then GetPlayer.AwardedAchievementKeys.AddChildBlock(Key);
end;
{ @end $79DB10 }

{ @routine $79DC54 TryAddAchievementProgress }
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
    achSteam: Result := SteamIncreaseStat(StrToInt(AnsiString(Block.Params['Num'])), Increment);
    achLocal: Result := IncreaseLocalAchievementProgress(Block, Increment);
    achSteamWithoutAchievements: Result := False;
  else Result := False;
  end;
  FreeAchievementData(Data);
  Data := GetAchievementData(Key);
  if (GetPlayer <> nil) and Data.Achieved then GetPlayer.AwardedAchievementKeys.AddChildBlock(Key);
  FreeAchievementData(Data);
end;
{ @end $79DC54 }

{ @routine $79DDE8 TrySetAchievementProgress }
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
    achSteam: Result := SteamIncreaseStat(StrToInt(AnsiString(Block.Params['Num'])), Increment);
    achLocal: Result := IncreaseLocalAchievementProgress(Block, Increment);
    achSteamWithoutAchievements: Result := False;
  else Result := False;
  end;
  FreeAchievementData(Data);
  Data := GetAchievementData(Key);
  if (GetPlayer <> nil) and Data.Achieved then GetPlayer.AwardedAchievementKeys.AddChildBlock(Key);
  FreeAchievementData(Data);
end;
{ @end $79DDE8 }

{ @routine $79DF94 GetAchievementData }
function GetAchievementData(Key: WideString): PAchievementData;
var Block: TBlockParEC;
begin
  Result := nil;
  Block := AchievementDefinitions.FindBlock(Key);
  if Block = nil then Exit;
  Result := CreateAchievementData;
  case GetAchievementBackend of
    achSteam: SteamAchievementData(StrToInt(AnsiString(Block.Params['Num'])), Result);
    achLocal: GetLocalAchievementData(Key, Result);
  end;
  TruncateStartupWideString(Result.Name);
  TruncateStartupWideString(Result.Description);
  TruncateStartupWideString(Result.IconPath);
end;
{ @end $79DF94 }

{ @routine $79E078 CreateAchievementData }
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
{ @end $79E078 }

{ @routine $79E0D4 FreeAchievementData }
procedure FreeAchievementData(Data: PAchievementData);
begin
  if Data = nil then Exit;
  FreeStartupWideString(Data.Name);
  FreeStartupWideString(Data.Description);
  FreeStartupWideString(Data.IconPath);
  Dispose(Data);
end;
{ @end $79E0D4 }

end.
