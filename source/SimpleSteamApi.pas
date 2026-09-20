unit SimpleSteamApi;
// Unit bracket (inferred): .text 0x0057AFEC..0x0057B5AC; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses WStringUtils;

type
  TAchievementData = record // @size $28 Caller-owned buffers used by both Steam and local achievement queries.
    Name: PStartupWideString; // @offset $00
    Description: PStartupWideString; // @offset $04
    Achieved: Boolean; // @offset $08
    HasProgress: Boolean; // @offset $09
    Reserved0C: Integer; // @offset $0C Native local backend and allocator set zero; meaning unresolved.
    MaxValue: Integer; // @offset $10
    Value: Integer; // @offset $14
    IconPath: PStartupWideString; // @offset $18
    Date: Int64; // @offset $20
  end;
  PAchievementData = ^TAchievementData;
  TSteamAchievementData = procedure(Index: Integer; Data: PAchievementData); cdecl;
  TSteamUserId = function: Int64; cdecl;
  TSteamInit = function(var Language, AvailableLanguages: WideString): Boolean; cdecl;
  TSteamCreateAchievements = procedure(Count: Integer); cdecl;
  TSteamInitAchievement = procedure(Index: Integer; const AchievementName, StatName: AnsiString; MaxValue: Integer); cdecl;
  TSteamSetLeaderboardName = procedure(const Name: AnsiString); cdecl;
  TSteamLeaderboardFound = function: Boolean; cdecl;
  TSteamUploadScore = procedure(Score: Integer); cdecl;
  TSteamLocal = function(AppId: Integer): Boolean; cdecl;
  TSteamRunCallbacks = procedure; cdecl;
  TSteamUnlockAchievement = function(Index: Integer): Boolean; cdecl;
  TSteamIncreaseStat = function(Index, Amount: Integer): Boolean; cdecl;
  TSteamFree = procedure; cdecl;
  TSteamAchievementsCount = function: Integer; cdecl;

var
  SteamInitialized: Boolean = False; // @addr $87B04C
  SteamUserId: TSteamUserId; // @addr $88A820
  SteamInit: TSteamInit; // @addr $88A824
  SteamCreateAchievements: TSteamCreateAchievements; // @addr $88A828
  SteamInitAchievement: TSteamInitAchievement; // @addr $88A82C
  SteamSetLeaderboardName: TSteamSetLeaderboardName; // @addr $88A830
  SteamLeaderboardFound: TSteamLeaderboardFound; // @addr $88A834
  SteamUploadScore: TSteamUploadScore; // @addr $88A838
  SteamLocal: TSteamLocal; // @addr $88A83C
  SteamRunCallbacks: TSteamRunCallbacks; // @addr $88A840 @note "steamCallBacks export loaded from steam_ach.dll; called without arguments by TSteamCallbacksThread."
  SteamResetAchievements: Pointer; // @addr $88A844 @note "steamResetAchievements export; full signature remains unresolved."
  SteamUnlockAchievement: TSteamUnlockAchievement; // @addr $88A848
  SteamStat: Pointer; // @addr $88A84C @note "steamStat export; full signature remains unresolved."
  SteamIncreaseStat: TSteamIncreaseStat; // @addr $88A850
  SteamFree: TSteamFree; // @addr $88A854
  SteamAchievementsOverlay: Pointer; // @addr $88A858 @note "steamAchievementsOverlay export; full signature remains unresolved."
  SteamAchievementsCount: TSteamAchievementsCount; // @addr $88A85C
  SteamAchievementData: TSteamAchievementData; // @addr $88A860
  SteamStatus: Pointer; // @addr $88A864 @note "steamStatus export; full signature remains unresolved."

procedure LoadSteamApi; // @addr $57AFEC @note "Loads steam_ach.dll and resolves exports without checking individual addresses."
procedure UnloadSteamApi; // @addr $57B408 @note "Calls steamFree and releases the module if present; export pointers are left unchanged."
procedure InitializeSteamAchievements; // @addr $57B444

implementation

uses Windows, SysUtils, EC_BlockPar, Achievements;

{ @routine $57AFEC LoadSteamApi }
procedure LoadSteamApi;
var
  Module: HMODULE;
  Error: Integer;
begin
  Module := Windows.LoadLibrary('steam_ach.dll');
  if Module = 0 then
  begin
    Error := GetLastError;
    if Error = 126 then
      raise Exception.Create('cant load steam_ach.dll, missing some file')
    else if Error = 193 then
      raise Exception.Create('cant load steam_ach.dll, module versions mismatch')
    else
      raise Exception.Create('cant load steam_ach.dll, lasterror=' + IntToStr(Error));
  end;
  SteamUserId := GetProcAddress(Module, 'steamUserID');
  SteamInit := GetProcAddress(Module, 'steamInit');
  SteamCreateAchievements := GetProcAddress(Module, 'createAchievements');
  SteamInitAchievement := GetProcAddress(Module, 'initAchievement');
  SteamSetLeaderboardName := GetProcAddress(Module, 'steamSetLeaderBoardName');
  SteamLeaderboardFound := GetProcAddress(Module, 'steamLeaderBoardFound');
  SteamUploadScore := GetProcAddress(Module, 'steamUploadScore');
  SteamLocal := GetProcAddress(Module, 'steamLocal');
  SteamRunCallbacks := GetProcAddress(Module, 'steamCallBacks');
  SteamResetAchievements := GetProcAddress(Module, 'steamResetAchievements');
  SteamUnlockAchievement := GetProcAddress(Module, 'steamAchievement');
  SteamStat := GetProcAddress(Module, 'steamStat');
  SteamIncreaseStat := GetProcAddress(Module, 'steamStatIncrease');
  SteamFree := GetProcAddress(Module, 'steamFree');
  SteamAchievementsOverlay := GetProcAddress(Module, 'steamAchievementsOverlay');
  SteamAchievementsCount := GetProcAddress(Module, 'steamAchievementsCount');
  SteamAchievementData := GetProcAddress(Module, 'steamAchievementData');
  SteamStatus := GetProcAddress(Module, 'steamStatus');
end;
{ @end $57AFEC }

{ @routine $57B408 UnloadSteamApi }
procedure UnloadSteamApi;
var Module: HMODULE;
begin
  Module := Windows.GetModuleHandle('steam_ach.dll');
  if Module <> 0 then
  begin
    SteamFree;
    FreeLibrary(Module);
  end;
end;
{ @end $57B408 }

{ @routine $57B444 InitializeSteamAchievements }
procedure InitializeSteamAchievements;
var
  Index, MaxValue, Number: Integer;
  Block: TBlockParEC;
  AchievementName, StatName: AnsiString;
begin
  SteamCreateAchievements(82);
  for Index := 0 to AchievementDefinitions.GetBlockCount - 1 do
  begin
    Block := AchievementDefinitions.GetBlockByIndex(Index);
    AchievementName := AnsiString(AchievementDefinitions.GetBlockNameByIndex(Index));
    Number := StrToInt(AnsiString(Block.GetParam('Num')));
    MaxValue := StrToInt(AnsiString(Block.GetParam('MaxValue')));
    if MaxValue > 0 then StatName := 'STAT_' + AchievementName
    else StatName := 'null';
    AchievementName := 'ACH_' + AchievementName;
    SteamInitAchievement(Number, AchievementName, StatName, MaxValue);
  end;
end;
{ @end $57B444 }

end.
