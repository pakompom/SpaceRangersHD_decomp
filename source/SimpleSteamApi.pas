unit SimpleSteamApi;

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
  SteamInitialized: Boolean = False; // @addr $80E770
  SteamUserId: TSteamUserId; // @addr $81ADB8
  SteamInit: TSteamInit; // @addr $81ADBC
  SteamCreateAchievements: TSteamCreateAchievements; // @addr $81ADC0
  SteamInitAchievement: TSteamInitAchievement; // @addr $81ADC4
  SteamSetLeaderboardName: TSteamSetLeaderboardName; // @addr $81ADC8
  SteamLeaderboardFound: TSteamLeaderboardFound; // @addr $81ADCC
  SteamUploadScore: TSteamUploadScore; // @addr $81ADD0
  SteamLocal: TSteamLocal; // @addr $81ADD4
  SteamRunCallbacks: TSteamRunCallbacks; // @addr $81ADD8 @note "steamCallBacks export loaded from steam_ach.dll; called without arguments by TSteamCallbacksThread."
  SteamResetAchievements: Pointer; // @addr $81ADDC @note "steamResetAchievements export; full signature remains unresolved."
  SteamUnlockAchievement: TSteamUnlockAchievement; // @addr $81ADE0
  SteamStat: Pointer; // @addr $81ADE4 @note "steamStat export; full signature remains unresolved."
  SteamIncreaseStat: TSteamIncreaseStat; // @addr $81ADE8
  SteamFree: TSteamFree; // @addr $81ADEC
  SteamAchievementsOverlay: Pointer; // @addr $81ADF0 @note "steamAchievementsOverlay export; full signature remains unresolved."
  SteamAchievementsCount: TSteamAchievementsCount; // @addr $81ADF4
  SteamAchievementData: TSteamAchievementData; // @addr $81ADF8
  SteamStatus: Pointer; // @addr $81ADFC @note "steamStatus export; full signature remains unresolved."

procedure LoadSteamApi; // @addr $4D6E58 @note "Loads steam_ach.dll and resolves exports without checking individual addresses."
procedure UnloadSteamApi; // @addr $4D7230 @note "Calls steamFree and releases the module if present; export pointers are left unchanged."
procedure InitializeSteamAchievements; // @addr $4D7260

implementation

uses Windows, SysUtils, EC_BlockPar, Achievements;

{ @routine $4D6E58 LoadSteamApi }
procedure LoadSteamApi;
var
  Module: HMODULE;
  Error: Integer;
begin
  Module := Windows.LoadLibrary('steam_ach.dll');
  if Module = 0 then
  begin
    Error := GetLastError;
    if Error = ERROR_MOD_NOT_FOUND then
      raise Exception.Create('cant load steam_ach.dll, missing some file')
    else if Error = ERROR_BAD_EXE_FORMAT then
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
{ @end $4D6E58 }

{ @routine $4D7230 UnloadSteamApi }
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
{ @end $4D7230 }

{ @routine $4D7260 InitializeSteamAchievements }
procedure InitializeSteamAchievements;
var
  Index, MaxValue, Number: Integer;
  Block: TBlockParEC;
  AchievementName, StatName: AnsiString;
begin
  SteamCreateAchievements(High(AchievementDefinitionTable));
  for Index := 0 to AchievementDefinitions.BlockCount - 1 do
  begin
    Block := AchievementDefinitions.Blocks[Index];
    AchievementName := AnsiString(AchievementDefinitions.BlockNames[Index]);
    Number := StrToInt(AnsiString(Block.Params['Num']));
    MaxValue := StrToInt(AnsiString(Block.Params['MaxValue']));
    if MaxValue > 0 then StatName := 'STAT_' + AchievementName
    else StatName := 'null';
    AchievementName := 'ACH_' + AchievementName;
    SteamInitAchievement(Number, AchievementName, StatName, MaxValue);
  end;
end;
{ @end $4D7260 }

end.
