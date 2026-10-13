unit NoSteamAchievemens;
// Local achievement loading, persistence and notification.
// Original ownership of NotifyLocalAchievement is unresolved.

interface

uses SimpleSteamApi, EC_BlockPar;

procedure GetLocalAchievementData(Key: WideString; Data: PAchievementData); // @addr $4D6C00 Fills caller-owned strings/counters for a registered local achievement.

procedure LoadLocalAchievements; // @addr $4D6260 @note "Reads achievements.dat, expands zlib, decodes its payload and verifies the additive checksum. Unknown keys do not consume their value fields in the native reader."

function UnlockLocalAchievement(Block: TBlockParEC): Boolean; // @addr $4D68C4 Returns true even if already unlocked; absent timestamps allow a fresh unlock.
function IncreaseLocalAchievementProgress(Block: TBlockParEC; Amount: Integer): Boolean; // @addr $4D69DC Positive increments only; clamps to MaxValue and saves accepted changes.

procedure SaveLocalAchievements; // @addr $4D65C8 Writes the native checksummed, encoded and compressed achievements.dat format.
procedure NotifyLocalAchievement(Block: TBlockParEC); // @addr $4D6080 Queues the localized achievement toast when its controller exists.

implementation

uses aMyFunction, SysUtils, EC_Buf, GR_Main, GI_MessageLoop, Achievements, EC_File, DateUtils, Math, GlobalsV, aConst;

{ @routine $4D6080 NotifyLocalAchievement }
procedure NotifyLocalAchievement(Block: TBlockParEC);
var Text, ImagePath: WideString;
begin
  if PopupController = nil then Exit;
  Text := LocalizedColorText('Achievements.AchievementReceived');
  ReplaceTextToken(Text, '<Achievement>',
    LocalizedColorText('Achievements.' + Block.Params['Id'] + '.Name'),
    BrightBlueColorTag);
  ImagePath := 'GI,Bm.FormAchievements.Img.' + Block.Params['Id'];
  PopupController.QueueNotification(Text, ImagePath);
end;
{ @end $4D6080 }

{ @routine $4D6260 LoadLocalAchievements }
procedure LoadLocalAchievements;
var
  Index, Size, Count: Integer;
  FileName: WideString;
  Buffer: TBufEC;
  Block: TBlockParEC;
  Version: Integer;
  Key: WideString;
  Seed: Integer;
  Checksum: Cardinal;
  Cursor: PByte;
begin
  FileName := GetGameUserDirectory + 'achievements.dat';
  if not FileExists(FileName) then Exit;
  Buffer := TBufEC.Create;
  try
    Buffer.LoadFromWideFilePath(PWideChar(FileName));
    Buffer.ExpandZlibPayloadInPlace;
    Version := Buffer.GetInt32At(0);
    if Version <> 0 then
      raise EAbort.Create('Error unpacking achievements.dat');
    Seed := Buffer.GetByteAt(6) or (Buffer.GetByteAt(7) shl 8) or
      (Buffer.GetByteAt(4) shl 16) or (Buffer.GetByteAt(5) shl 24);
    Cursor := PByte(PAnsiChar(Buffer.Data) + 8);
    Size := Buffer.DataSize;
    for Index := 8 to Size - 1 do
    begin
      Cursor^ := Cursor^ xor Byte(Seed - 1);
      Seed := SeedRngMultiplier * (Seed mod SeedRngQuotient) - SeedRngRemainder * (Seed div SeedRngQuotient);
      if Seed <= 0 then Inc(Seed, SeedRngModulus);
      Cursor := PByte(PAnsiChar(Cursor) + 1);
    end;
    Checksum := 0;
    Cursor := PByte(PAnsiChar(Buffer.Data) + SizeOf(TEncodedTableHeaderEC));
    for Index := SizeOf(TEncodedTableHeaderEC) to Size - 1 do
    begin
      Inc(Checksum, Byte(Cursor^ xor $FF));
      Cursor := PByte(PAnsiChar(Cursor) + 1);
    end;
    if Buffer.GetUInt32At(8) <> Checksum then
      raise EAbort.Create('Error unpacking achievements.dat');
    Buffer.SetPosition(SizeOf(TEncodedTableHeaderEC));
    Count := Buffer.GetInt32;
    for Index := 0 to Count - 1 do
    begin
      Key := Buffer.ReadWideString;
      Block := AchievementDefinitions.FindBlock(Key);
      if Block = nil then Continue;
      if Buffer.GetBoolean then Block.SetOrAddParam('Achieved', 'Yes');
      Block.SetOrAddParam('Date', IntToStr(Buffer.GetUInt32));
      Block.SetOrAddParam('Value', IntToStr(Buffer.GetInt32));
    end;
  finally
    Buffer.Free;
  end;
end;
{ @end $4D6260 }

{ @routine $4D65C8 SaveLocalAchievements }
procedure SaveLocalAchievements;
var
  Buffer: TBufEC;
  Index, Size, Count, Seed: Integer;
  Cursor: PByte;
  FileHandle: TFileEC;
  Checksum: Integer;
  Block: TBlockParEC;
begin
  Seed := Random(MaxInt);
  Buffer := TBufEC.Create;
  Buffer.AddIntegerValue(0);
  Buffer.AddIntegerValue(0);
  Buffer.AddIntegerValue(0);
  Buffer.SetByteAt(6, Seed);
  Buffer.SetByteAt(7, Cardinal(Seed) shr 8);
  Buffer.SetByteAt(4, Cardinal(Seed) shr 16);
  Buffer.SetByteAt(5, Cardinal(Seed) shr 24);
  Count := AchievementDefinitions.BlockCount;
  Buffer.AddIntegerValue(Count);
  for Index := 0 to Count - 1 do
  begin
    Block := AchievementDefinitions.Blocks[Index];
    Buffer.AddWideStringZ(AchievementDefinitions.BlockNames[Index]);
    Buffer.AddBoolean(ParseEnabledNameGI(Block.Params['Achieved']));
    Buffer.AddDWord(StrToInt64(Block.Params['Date']));
    Buffer.AddIntegerValue(StrToInt(Block.Params['Value']));
  end;
  Size := Buffer.DataSize;
  Checksum := 0;
  Cursor := PByte(PAnsiChar(Buffer.Data) + SizeOf(TEncodedTableHeaderEC));
  for Index := SizeOf(TEncodedTableHeaderEC) to Size - 1 do
  begin
    Inc(Checksum, Byte(Cursor^ xor $FF));
    Inc(Cursor);
  end;
  Buffer.SetInt32At(8, Checksum);
  Cursor := PByte(PAnsiChar(Buffer.Data) + 8);
  for Index := 8 to Size - 1 do
  begin
    Cursor^ := Cursor^ xor Byte(Seed - 1);
    Seed := SeedRngMultiplier * (Seed mod SeedRngQuotient) - SeedRngRemainder * (Seed div SeedRngQuotient);
    if Seed <= 0 then Inc(Seed, SeedRngModulus);
    Inc(Cursor);
  end;
  Buffer.CompressZlibPayloadInPlace(False);
  FileHandle := TFileEC.Create;
  FileHandle.SetFileName(GetGameUserDirectory + 'achievements.dat');
  FileHandle.CreateNew;
  FileHandle.WriteBuffer(Buffer.Data, Buffer.DataSize);
  FileHandle.Free;
  Buffer.Free;
end;
{ @end $4D65C8 }

{ @routine $4D68C4 UnlockLocalAchievement }
function UnlockLocalAchievement(Block: TBlockParEC): Boolean;
begin
  Result := True;
  if ParseEnabledNameGI(Block.Params['Achieved']) and (Block.Params['Date'] <> '0') then Exit;
  Block.SetOrAddParam('Achieved', 'Yes');
  Block.SetOrAddParam('Date', IntToStr(DateTimeToUnix(Now)));
  NotifyLocalAchievement(Block);
  SaveLocalAchievements;
end;
{ @end $4D68C4 }

{ @routine $4D69DC IncreaseLocalAchievementProgress }
function IncreaseLocalAchievementProgress(Block: TBlockParEC; Amount: Integer): Boolean;
var OldValue, NewValue, MaxValue: Integer;
begin
  Result := False;
  if Amount <= 0 then Exit;
  if ParseEnabledNameGI(Block.Params['Achieved']) and
    (Block.Params['Date'] <> '0') then Exit;
  MaxValue := StrToInt(Block.Params['MaxValue']);
  if MaxValue = 0 then Exit;
  OldValue := StrToInt(Block.Params['Value']);
  if OldValue >= MaxValue then Exit;
  Result := True;
  NewValue := Min(MaxValue, OldValue + Amount);
  Block.SetOrAddParam('Value', IntToStr(NewValue));
  if NewValue >= MaxValue then
  begin
    Block.SetOrAddParam('Achieved', 'Yes');
    Block.SetOrAddParam('Date', IntToStr(DateTimeToUnix(Now)));
    NotifyLocalAchievement(Block);
  end;
  SaveLocalAchievements;
end;
{ @end $4D69DC }

{ @routine $4D6C00 GetLocalAchievementData }
procedure GetLocalAchievementData(Key: WideString; Data: PAchievementData);
var Block: TBlockParEC;
begin
  Block := AchievementDefinitions.FindBlock(Key);
  if Block = nil then Exit;
  Data.Achieved := ParseEnabledNameGI(Block.Params['Achieved']);
  Data.Name^ := LocalizedColorText('Achievements.' + Key + '.Name');
  Data.Description^ := LocalizedColorText('Achievements.' + Key + '.Description');
  Data.Reserved0C := 0;
  Data.MaxValue := StrToInt(Block.Params['MaxValue']);
  Data.HasProgress := Data.MaxValue > 0;
  Data.Value := StrToInt(Block.Params['Value']);
  Data.IconPath^ := 'null';
  Data.Date := StrToInt64(Block.Params['Date']);
end;
{ @end $4D6C00 }

end.
