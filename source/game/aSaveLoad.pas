unit aSaveLoad;
// Unit bracket (inferred): .text 0x00523D18..0x00526281; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Thread, SyncObjs;

type
  TSaver = class(TThreadEC) // @size 0x44
  public
    FileName: WideString; // @offset 0x2C
    HeaderBuffer: TBufEC; // @offset 0x30
    PreviewBuffer: TBufEC; // @offset 0x34
    SecondaryPreviewBuffer: TBufEC; // @offset 0x38
    GameStateBuffer: TBufEC; // @offset 0x3C
    FilmBuffer: TBufEC; // @offset 0x40

    procedure Execute; override; // @addr 0x523D84 @note "Owns and frees all five buffers. Writes Save.tmp before replacing the destination; shares SaveLoadLock with the loader."
    procedure QueueSave(AFileName: WideString; Header, Preview, SecondaryPreview, GameState, Films: TBufEC); // @addr 0x524440 @note "Waits for the preceding job, then takes ownership of all five buffers."
  end;

  // Immediately precedes the encrypted game-state payload, after both previews.
  TSaveStateEnvelope = packed record // @size 0x0C
    CompressedCrc32: Cardinal; // @offset 0x00
    XorSeed: Integer; // @offset 0x04
    PayloadSize: Integer; // @offset 0x08
  end;

// Disk header: eight NUL-terminated UTF-16 strings: RSG, v<version>,
// description, turn, money, pilot name, race/emblem name, EZ.
// Each preview has a four-byte byte count. The trailing film block runs to EOF.

function SaveGameToFile(FileName, Description: WideString): Boolean; // @addr 0x5244E4 @note "Queues the write; true does not mean the background writer has finished."
function LoadGameFromFile(FileName: WideString): Boolean; // @addr 0x524D3C @note "Replaces the current galaxy."
procedure LoadGameFromSaveBuffer(Buffer: TBufEC); // @addr 0x524C58 @note "Requires an existing galaxy object and a decoded buffer positioned at the player-hold section."
procedure SaveGameToMemorySnapshot; // @addr 0x525558 @note "Requires a live galaxy/player and no outstanding snapshot. Obfuscates and detaches the live galaxy until restoration; does not increment the persistent save count."
procedure RestoreGameFromMemorySnapshot; // @addr 0x5258B4 @note "Consumes the snapshot, destroys the detached galaxy and rebuilds it. Preserves the persistent load count and restores UI references by object ID."
procedure InitializeSaveWriter; // @addr 0x526238
procedure FinalizeSaveWriter; // @addr 0x52624C @note "Waits for a pending write before freeing the worker."

var
  MemorySnapshotBuffer: TBufEC = nil; // @addr 0x87AD88
  SaveLoadLock: TCriticalSection = nil; // @addr 0x87AD8C
  SaveWriter: TSaver = nil; // @addr 0x87AD90
  MemorySnapshotXorSeed: Integer; // @addr 0x88A420
  MemorySnapshotGalaxyToken: Cardinal; // @addr 0x88A424 @note "Detached galaxy address plus 0x17557455, modulo 2^32."

implementation


uses aGalaxyStruct, aKling, Windows, SysUtils, EC_File, EC_Str, EC_BlockPar, aGalaxy, aConst,
  aPlayer, GR_Main, Globals, GlobalsV, fSaveManager, fShip2, fStarMap, fFilmFile, GI_Main, GI_MessageBox,
  EC_Struct, Types, aShip, aRuins, GI_MessageLoop, fGov, fEquipmentShop,
  fCount2, fRating2, fJournal, fSelectFace, fScaner, fGalaxy2, fGameMenu,
  fRewards, fChameleon, fTalk, ab_MainForm, fLoad, fGameLoad, fHangar,
  fPlanet, fPlanetNO, fPlanetQuest, fGoodsShop2, fRuinsTalk, fInfo, fJump;

{ @routine $523D84 TSaver_Execute }
procedure TSaver.Execute;
var
  F: TFileEC;
  Size, I, Seed: Integer;
  SourceName, TargetName, NewName, OldName, Prefix, AutoName, TurnName, QuickName, TempName: WideString;
begin
  SaveLoadLock.Enter;
  AutoName := SaveManagerScreen.GetAutoSavePath;
  TurnName := SaveManagerScreen.GetTurnSavePath;
  QuickName := SaveManagerScreen.GetQuickSavePath(1);
  CreateDir(AnsiString(GetGameUserDirectory + 'Save'));
  F := nil;
  try
    F := TFileEC.Create;
    TempName := GetGameUserDirectory + 'save\save.tmp';
    if FileExists(AnsiString(TempName)) then Windows.DeleteFile(PAnsiChar(AnsiString(TempName)));
    F.SetFileName(TempName);
    F.CreateNew;
    HeaderBuffer.SaveToFile(F);
    if PreviewBuffer.DataSize > 0 then PreviewBuffer.CompressZlibPayloadInPlace(False);
    Size := PreviewBuffer.DataSize;
    F.WriteBuffer(@Size, SizeOf(Size));
    if Size > 0 then F.WriteBuffer(PreviewBuffer.Data, Size);
    if SecondaryPreviewBuffer.DataSize > 0 then SecondaryPreviewBuffer.CompressZlibPayloadInPlace(False);
    Size := SecondaryPreviewBuffer.DataSize;
    F.WriteBuffer(@Size, SizeOf(Size));
    if Size > 0 then F.WriteBuffer(SecondaryPreviewBuffer.Data, Size);
    GameStateBuffer.CompressZlibPayloadInPlace(False);
    Size := GameStateBuffer.ComputeCrc32;
    F.WriteBuffer(@Size, SizeOf(Size));
    Seed := RandomIntRange(0, 2000000000);
    GameStateBuffer.ApplyDatXorCipher(Seed);
    F.WriteBuffer(@Seed, SizeOf(Seed));
    Size := GameStateBuffer.DataSize;
    F.WriteBuffer(@Size, SizeOf(Size));
    if Size > 0 then F.WriteBuffer(GameStateBuffer.Data, Size);
    FilmBuffer.CompressZlibPayloadInPlace(False);
    Size := FilmBuffer.DataSize;
    F.WriteBuffer(FilmBuffer.Data, Size);
    F.ReleaseHandle;
    SourceName := TempName;
    TargetName := FileName;
    if (FileName = QuickName) and (QuickSaveExtraSlots > 0) then begin
      Prefix := TrimWideString(ExtractFileDirW(QuickName)) + '\' + TrimWideString(ExtractFileNameNoExtW(QuickName));
      NewName := Prefix + IntToWideString(QuickSaveExtraSlots + 1) + '.sav';
      for I := QuickSaveExtraSlots downto 1 do begin
        if I > 1 then OldName := Prefix + IntToWideString(I) + '.sav'
        else OldName := QuickName;
        if FileExists(AnsiString(NewName)) then Windows.DeleteFile(PAnsiChar(AnsiString(NewName)));
        MoveFileW(PWideChar(OldName), PWideChar(NewName));
        NewName := OldName;
      end;
    end;
    if FileExists(AnsiString(TargetName)) then Windows.DeleteFile(PAnsiChar(AnsiString(TargetName)));
    MoveFileW(PWideChar(SourceName), PWideChar(TargetName));
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.Message);
      if FileName = AutoName then Galaxy.ShowLocalizedWarning('Warning.AutoSaveFailed');
      if FileName = TurnName then Galaxy.ShowLocalizedWarning('Warning.TurnSaveFailed');
      if FileName = QuickName then Galaxy.ShowLocalizedWarning('Warning.QuickSaveFailed');
    end;
  end;
  if F <> nil then F.Free;
  if FileExists(AnsiString(TempName)) then Windows.DeleteFile(PAnsiChar(AnsiString(TempName)));
  if HeaderBuffer <> nil then HeaderBuffer.Free;
  HeaderBuffer := nil;
  if PreviewBuffer <> nil then PreviewBuffer.Free;
  PreviewBuffer := nil;
  if SecondaryPreviewBuffer <> nil then SecondaryPreviewBuffer.Free;
  SecondaryPreviewBuffer := nil;
  if GameStateBuffer <> nil then GameStateBuffer.Free;
  GameStateBuffer := nil;
  if FilmBuffer <> nil then FilmBuffer.Free;
  FilmBuffer := nil;
  SaveLoadLock.Leave;
end;
{ @end $523D84 }

{ @routine $524440 TSaver_QueueSave }
procedure TSaver.QueueSave(AFileName: WideString; Header, Preview, SecondaryPreview, GameState, Films: TBufEC);
begin
  if IsRunning then WaitForIdle(INFINITE);
  FileName := AFileName;
  HeaderBuffer := Header;
  PreviewBuffer := Preview;
  SecondaryPreviewBuffer := SecondaryPreview;
  GameStateBuffer := GameState;
  FilmBuffer := Films;
  Start;
end;
{ @end $524440 }

{ @routine $5244E4 SaveGameToFile }
function SaveGameToFile(FileName, Description: WideString): Boolean;
var Header, Preview, SecondaryPreview, GameState, Films, FilmEntry: TBufEC;
  Size, I, Count: Integer; Message: TMessagePlayer; Entry: TPlayerHoldUnit;
  AutoName, TurnName, QuickName: WideString;
begin
  Result := False;
  if (Galaxy <> nil) and (GetPlayer <> nil) then begin
    FilmEntry := nil;
    AutoName := SaveManagerScreen.GetAutoSavePath;
    TurnName := SaveManagerScreen.GetTurnSavePath;
    QuickName := SaveManagerScreen.GetQuickSavePath(1);
    if FileName = AutoName then Description := SaveManagerScreen.BuildCurrentSaveDescription;
    try
      Header := TBufEC.Create;
      Header.AddWideStringZ('RSG');
      Header.AddWideStringZ('v' + IntToStr(CurrentSaveVersion));
      Header.AddWideStringZ(Description);
      Header.AddWideStringZ(IntToStr(Galaxy.CurrentTurn));
      Header.AddWideStringZ(IntToStr(GetPlayer.Money));
      Header.AddWideStringZ(GetPlayer.Name);
      if GetPlayer.OwnerId = Byte(oiPirate) then
        Header.AddWideStringZ(OwnerInfo[Ord(oiPirate)].InternalName + OwnerInfo[RaceToOwner(GetPlayer.PilotRace)].InternalName)
      else Header.AddWideStringZ(OwnerInfo[GetPlayer.OwnerId].InternalName);
      Header.AddWideStringZ('EZ');
      Preview := TBufEC.Create;
      if SavePreviewGraph <> nil then SavePreviewGraph.SaveToBuffer(Preview);
      SecondaryPreview := TBufEC.Create;
      if SecondarySavePreviewGraph <> nil then SecondarySavePreviewGraph.SaveToBuffer(SecondaryPreview);
      GameState := TBufEC.Create;
      GameState.AddIntegerValue(Ord(SaveManagerReturnScreenId));
      GameState.AddIntegerValue(StarMapScreen.GetMapCenter.X);
      GameState.AddIntegerValue(StarMapScreen.GetMapCenter.Y);
      GameState.AddBoolean(StarMapWeaponPanelOpen);
      GameState.AddAnsiChar(#0);
      GameState.AddBoolean(FilmCameraFollow);
      GameState.AddAnsiChar(#0);
      GameState.AddAnsiChar(#0);
      GameState.AddAnsiChar(#0);
      GameState.AddBoolean(False);
      GameState.AddBoolean(PlayerStarDayPrepared);
      GameState.AddDWord(ShownPlayerTips);
      GameState.AddIntegerValue(0);
      Count := CountPersistentPlayerMessages;
      GameState.AddIntegerValue(Count);
      Message := FirstPersistentPlayerMessage;
      while Message <> nil do begin
        Message.SaveToBuffer(GameState);
        Message := Message.Next;
      end;
      PlayerHoldShip := GetPlayer;
      RefreshPlayerHoldView(False);
      Count := PlayerHoldEntries.Count;
      GameState.AddWideChar(WideChar(Count));
      for I := 0 to Count - 1 do begin
        Entry := PlayerHoldEntries[I];
        GameState.AddAnsiChar(AnsiChar(Entry.Kind));
        GameState.AddAnsiChar(AnsiChar(Entry.GoodsIndex));
        GameState.AddDWord(Entry.ItemId);
      end;
      Galaxy.SaveToBuffer(GameState);
      Films := TBufEC.Create;
      FilmEntry := TBufEC.Create;
      Count := 0;
      Count := FilmHistory.GetCount;
      Films.AddBytes(@Count, 4);
      for I := 0 to Count - 1 do begin
        FilmHistory.SaveEntryToBuffer(FilmHistory.GetEntry(I), FilmEntry);
        Size := FilmEntry.DataSize;
        Films.AddBytes(@Size, 4);
        if Size > 0 then Films.AddBytes(FilmEntry.Data, Size);
      end;
      SaveWriter.QueueSave(FileName, Header, Preview, SecondaryPreview, GameState, Films);
      if Galaxy.CampaignFlag183 <> 0 then begin
        EditableSaveFileName := SaveManagerScreen.GetSaveConfigPath(FileName);
        if (UserSettingsConfig.CountParams('UnicodeDump') > 0) and
          ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('UnicodeDump'))) then
          EditableSaveBlock.SaveTextFile(PWideChar(EditableSaveFileName), False, False)
        else EditableSaveBlock.SaveTextFile(PWideChar(EditableSaveFileName), True, False);
        EditableSaveBlock.Clear;
        Galaxy.CampaignFlag183 := 0;
      end;
      Result := True;
    except
      on E: Exception do begin
        AppendLogLineThreadSafe(E.Message);
        if FileName = AutoName then Galaxy.ShowLocalizedWarning('Warning.AutoSaveFailed');
        if FileName = TurnName then Galaxy.ShowLocalizedWarning('Warning.TurnSaveFailed');
        if FileName = QuickName then Galaxy.ShowLocalizedWarning('Warning.QuickSaveFailed');
      end;
    end;
    if FilmEntry <> nil then FilmEntry.Free;
    if Result = True then FreeSavePreviewBuffers;
  end;
end;
{ @end $5244E4 }

{ @routine $524C58 LoadGameFromSaveBuffer }
procedure LoadGameFromSaveBuffer(Buffer: TBufEC);
var I, Count: Integer; Entry: TPlayerHoldUnit; LoadingGalaxy: TGalaxy;
begin
  InitializePlayerHoldView;
  Count := Buffer.GetWord;
  for I := 0 to Count - 1 do begin
    Entry := TPlayerHoldUnit.Create;
    PlayerHoldEntries.Add(Entry);
    Entry.Kind := TPlayerHoldKind(Buffer.GetByte);
    Entry.GoodsIndex := Buffer.GetByte;
    Entry.ItemId := Buffer.GetUInt32;
  end;
  LoadingGalaxy := Galaxy;
  Galaxy := nil;
  LoadingGalaxy.LoadFromBuffer(Buffer);
  if ApplyEditableSaveOnLoad then begin
    Galaxy.ApplyEditableState;
    ApplyEditableSaveOnLoad := False;
    Galaxy.PrimeIntegrityChecksum(101);
  end;
  Galaxy.RunConfigOnLoadHandlers;
end;
{ @end $524C58 }

{ @routine $524D3C LoadGameFromFile }
function LoadGameFromFile(FileName: WideString): Boolean;
var
  F: TFileEC;
  Buffer, Films: TBufEC;
  Center: TPoint;
  Size, I, Count, Seed: Integer;
  Crc: Cardinal;
  Message: TMessagePlayer;
begin
  Result := False;
  LoadedSaveModSet := SelectedMods;
  SaveLoadLock.Enter;
  F := nil;
  Buffer := nil;
  try
    if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
    MemorySnapshotBuffer := nil;
    MemorySnapshotActive := False;
    if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
    Galaxy := nil;
    F := TFileEC.Create;
    F.SetFileName(FileName);
    if not F.TryAcquireReadHandle(False) then raise EAbort.Create('Cannot open file ' + FileName);
    if F.ReadWideString <> 'RSG' then raise EAbort.Create('Bad pre-signature of file' + FileName);
    LoadedSaveVersion := ExtractDigitsToIntW(F.ReadWideString);
    F.ReadWideString;
    StrToInt(F.ReadWideString);
    StrToInt(F.ReadWideString);
    F.ReadWideString;
    F.ReadWideString;
    if F.ReadWideString <> 'EZ' then raise EAbort.Create('Bad post-signature of file' + FileName);
    Buffer := TBufEC.Create;
    F.ReadBuffer(@Size, SizeOf(Size));
    if Size > 0 then F.SetPointer(Size, FILE_CURRENT);
    F.ReadBuffer(@Size, SizeOf(Size));
    if Size > 0 then F.SetPointer(Size, FILE_CURRENT);
    F.ReadBuffer(@Crc, SizeOf(Crc));
    F.ReadBuffer(@Seed, SizeOf(Seed));
    F.ReadBuffer(@Size, SizeOf(Size));
    if Size > 0 then begin
      Buffer.SetSize(Size);
      try
        F.ReadBuffer(Buffer.Data, Size);
      except
        ShowMessageBoxGI(nil, 'Compressed galaxy read fail', mbgOK);
      end;
    end;
    Buffer.ApplyDatXorCipher(Seed);
    if Buffer.ComputeCrc32 <> Crc then raise EAbort.Create('Integrity check fail');
    Buffer.ExpandZlibPayloadInPlace;
    ActiveLoadBuffer := Buffer;
    RequestedScreenId := TGameScreenId(Buffer.GetInt32);
    Galaxy := TGalaxy.Create;
    Center.X := Buffer.GetInt32;
    Center.Y := Buffer.GetInt32;
    SpaceViewPosition := PointToPointF(Center);
    StarMapScreen.SetMapCenterManually(Center);
    StarMapWeaponPanelOpen := Buffer.GetBoolean;
    Buffer.GetByte;
    FilmCameraFollow := Buffer.GetBoolean;
    Buffer.GetByte;
    Buffer.GetByte;
    Buffer.GetByte;
    Buffer.GetBoolean;
    PlayerStarDayPrepared := Buffer.GetBoolean;
    if PlayerStarDayPrepared then begin end;
    ShownPlayerTips := Buffer.GetUInt32;
    Buffer.GetInt32;
    Count := Buffer.GetInt32;
    for I := 0 to Count - 1 do begin
      Message := CreatePersistentPlayerMessage;
      Message.LoadFromBuffer(Buffer);
    end;
    LoadGameFromSaveBuffer(Buffer);
    Films := nil;
    try
      Films := TBufEC.Create;
      Films.Clear;
      Size := F.GetSize - F.GetPointer;
      if Size > 0 then begin
        Films.SetSize(Size);
        F.ReadBuffer(Films.Data, Size);
        Films.ExpandZlibPayloadInPlace;
        FilmHistory.Clear;
        Films.ReadBytes(@Count, 4);
        LoadingFilmCount := Count;
        LoadedFilmCount := 0;
        for I := 0 to Count - 1 do begin
          Films.ReadBytes(@Size, 4);
          if Size > 0 then begin
            Buffer.SetSize(Size);
            Films.ReadBytes(Buffer.Data, Size);
            Buffer.SetPosition(0);
            FilmHistory.LoadEntryFromBuffer(Buffer);
          end;
          Inc(LoadedFilmCount);
        end;
        LoadingFilmCount := -1;
      end;
    finally
      if Films <> nil then Films.Free;
    end;
    LoadingFilmCount := -1;
    PreviousFilmActivity := 0;
    Result := True;
  except
    if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
    MemorySnapshotBuffer := nil;
    MemorySnapshotActive := False;
    if (Galaxy <> nil) and not Galaxy.Destroying then begin
      try Galaxy.Free;
      finally Galaxy := nil; end;
    end;
    if EditableSaveBlock <> nil then EditableSaveBlock.Clear;
  end;
  LoadingFilmCount := -1;
  ActiveLoadBuffer := nil;
  if Buffer <> nil then Buffer.Free;
  if F <> nil then F.Free;
  SaveLoadLock.Leave;
end;
{ @end $524D3C }

{ @routine $525558 SaveGameToMemorySnapshot }
procedure SaveGameToMemorySnapshot;
var I, Count: Integer; Message: TMessagePlayer; Entry: TPlayerHoldUnit; Loop: TMessageLoopGI;
begin
  MemorySnapshotBuffer := TBufEC.Create;
  Galaxy.ClearIntegrityStatus;
  if (CurrentScreenId <> screenPlanetQuest) and
    ((CurrentScreenId <> screenGovernment) or (GovernmentScreen.PendingTransition = 0)) and
    ((CurrentScreenId <> screenStarMap) or (StarMapScreen.PlanetBattleState = 0)) then
    (TObject(RegisteredScreens[Ord(CurrentScreenId)]) as TMessageLoopGI).OnClose;
  for I := MessageLoopStack.Count - 1 downto 0 do begin
    Loop := MessageLoopStack[I];
    if Loop is TfShip2 then (Loop as TfShip2).ReturnSelectedHoldEntry;
  end;
  Galaxy.ClearIntegrityStatus;
  if (GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.OwnerId <> Byte(oiUninhabited))) or
    (GetPlayer.IsDockedToShip and (GetPlayer.DockedTo is TRuins)) then RestoreTemporaryShopStock;
  Count := CountPersistentPlayerMessages;
  MemorySnapshotBuffer.AddIntegerValue(Count);
  Message := FirstPersistentPlayerMessage;
  while Message <> nil do begin
    Message.SaveToBuffer(MemorySnapshotBuffer);
    Message := Message.Next;
  end;
  MemorySnapshotBuffer.AddDWord(ShownPlayerTips);
  PlayerHoldShip := GetPlayer;
  RefreshPlayerHoldView(False);
  Count := PlayerHoldEntries.Count;
  MemorySnapshotBuffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Entry := PlayerHoldEntries[I];
    MemorySnapshotBuffer.AddAnsiChar(AnsiChar(Entry.Kind));
    MemorySnapshotBuffer.AddAnsiChar(AnsiChar(Entry.GoodsIndex));
    MemorySnapshotBuffer.AddDWord(Entry.ItemId);
  end;
  Dec(Galaxy.SaveCount);
  Galaxy.SaveToBuffer(MemorySnapshotBuffer);
  if Galaxy.ContainsShipReference(TalkShip) then MemorySnapshotBuffer.AddDWord(TalkShip.Id)
  else MemorySnapshotBuffer.AddDWord(0);
  if Galaxy.ContainsPlanetReference(TalkPlanet) then MemorySnapshotBuffer.AddDWord(TalkPlanet.Id)
  else MemorySnapshotBuffer.AddDWord(0);
  if Galaxy.ContainsShipReference(ShipScreen.ShipToInspect) then MemorySnapshotBuffer.AddDWord(ShipScreen.ShipToInspect.Id)
  else MemorySnapshotBuffer.AddDWord(0);
  MemorySnapshotXorSeed := RandomIntRange(0, 2000000000);
  MemorySnapshotBuffer.ApplyDatXorCipher(MemorySnapshotXorSeed);
  GetPlayer.SetMoney(0);
  Galaxy.ObfuscateProtectedState;
  MemorySnapshotGalaxyToken := Cardinal(Galaxy) + $17557455;
  Galaxy := nil;
  BlazerShip := nil;
  KellerShip := nil;
  TerronShip := nil;
  MemorySnapshotActive := True;
end;
{ @end $525558 }

{ @routine $5258B4 RestoreGameFromMemorySnapshot }
procedure RestoreGameFromMemorySnapshot;
var ReopenScreen: Boolean; I, Count: Integer; Entry: TPlayerHoldUnit; Message: TMessagePlayer; Loop: TMessageLoopGI;
begin
  ReopenScreen := True;
  Galaxy := TGalaxy(MemorySnapshotGalaxyToken - $17557455);
  Galaxy.RestoreProtectedState;
  if DominatorSpawnPlanet <> nil then begin
    DominatorSpawnPlanet.Free;
    DominatorSpawnPlanet := nil;
  end;
  Galaxy.Free;
  MemorySnapshotBuffer.SetPosition(0);
  MemorySnapshotBuffer.ApplyDatXorCipher(MemorySnapshotXorSeed);
  MemorySnapshotActive := True;
  Galaxy := TGalaxy.Create;
  LoadedSaveVersion := CurrentSaveVersion;
  Count := MemorySnapshotBuffer.GetInt32;
  for I := 0 to Count - 1 do begin
    Message := CreatePersistentPlayerMessage;
    Message.LoadFromBuffer(MemorySnapshotBuffer);
  end;
  ShownPlayerTips := MemorySnapshotBuffer.GetUInt32;
  InitializePlayerHoldView;
  Count := MemorySnapshotBuffer.GetWord;
  for I := 0 to Count - 1 do begin
    Entry := TPlayerHoldUnit.Create;
    PlayerHoldEntries.Add(Entry);
    Entry.Kind := TPlayerHoldKind(MemorySnapshotBuffer.GetByte);
    Entry.GoodsIndex := MemorySnapshotBuffer.GetByte;
    Entry.ItemId := MemorySnapshotBuffer.GetUInt32;
  end;
  Galaxy.LoadFromBuffer(MemorySnapshotBuffer);
  Dec(Galaxy.LoadCount);
  TalkShip := Galaxy.IdToShip(MemorySnapshotBuffer.GetUInt32, True);
  TalkPlanet := Galaxy.IdToPlanet(MemorySnapshotBuffer.GetUInt32);
  ShipScreen.ShipToInspect := Galaxy.IdToShip(MemorySnapshotBuffer.GetUInt32, True);
  for I := MessageLoopStack.Count - 1 downto 0 do begin
    Loop := MessageLoopStack[I];
    if Loop is TMessageBoxGI then Loop.RequestClose(254)
    else if Loop is TfCount2 then Loop.RequestClose(254)
    else if (Loop is TfStarMap) and (StarMapScreen.PlanetBattleState <> 0) then ReopenScreen := False
    else if Loop is TfRating2 then Loop.RequestClose(1)
    else if Loop is TfJournal then Loop.RequestClose(1)
    else if Loop is TfSelectFace then Loop.RequestClose(254)
    else if Loop is TfScaner then begin
      RequestedScreenId := ScannerReturnScreenId;
      Loop.RequestClose(1);
      ReopenScreen := False;
    end
    else if (Loop is TfShip2) and not GetPlayer.InNormalSpace then Loop.RequestClose(1)
    else if (Loop is TfGalaxy2) and not GetPlayer.InNormalSpace then Loop.RequestClose(1)
    else if (Loop is TfShip2) and GetPlayer.InNormalSpace then begin
      RequestedScreenId := ShipReturnScreenId;
      Loop.RequestClose(1);
    end
    else if (Loop is TfGalaxy2) and GetPlayer.InNormalSpace then begin
      RequestedScreenId := GalaxyReturnScreenId;
      Loop.RequestClose(1);
    end
    else if Loop is TfGameMenu then begin
      RequestedScreenId := GameMenuReturnScreenId;
      Loop.RequestClose(1);
    end
    else if Loop is TfSaveManager then begin
      RequestedScreenId := SaveManagerReturnScreenId;
      Loop.RequestClose(1);
    end
    else if Loop is TfRewards then Loop.RequestClose(254)
    else if Loop is TfChameleon then Loop.RequestClose(254)
    else if Loop is TfTalk then begin
      RequestedScreenId := TalkReturnScreenId;
      if TalkScripted then RaiseWideMessage('gtalk AI');
      Loop.RequestClose(1);
    end
    else if Loop is TfAB then begin
      RequestedScreenId := screenMainMenu;
      Loop.RequestClose(1);
      ReopenScreen := False;
    end
    else if Loop is TfLoad then begin
      if GetPlayer.InNormalSpace then begin
        RequestedScreenId := screenStarMap;
        StarMapScreen.ResumeMode := smrOrders;
      end;
      PostLoadScreenId := RequestedScreenId;
      Loop.RequestClose(1);
    end
    else if Loop is TfGameLoad then begin
      Loop.RequestClose(1);
      ReopenScreen := False;
    end
    else if GetPlayer.InNormalSpace and
      ((Loop is TfHangar) or (Loop is TfPlanet) or (Loop is TfPlanetNO) or
       (Loop is TfGov) or (Loop is TfPlanetQuest) or (Loop is TfEquipmentShop) or
       (Loop is TfGoodsShop2) or (Loop is TfRuinsTalk) or (Loop is TfInfo)) then begin
      RequestedScreenId := screenStarMap;
      StarMapScreen.ResumeMode := smrOrders;
      if Loop is TfGoodsShop2 then begin
        Loop.RequestClose(2);
        TalkScreen.ModalTransition := tmtNone;
        GoodsShopScreen.ReopenRequested := False;
        StarMapScreen.RequestClose(1);
      end
      else Loop.RequestClose(1);
      ReopenScreen := False;
    end
    else if (GetPlayer.IsOnPlanet or GetPlayer.IsDockedToShip) and (Loop is TfStarMap) then begin
      Loop.RequestClose(1);
      if GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.OwnerId = Byte(oiUninhabited)) then RequestedScreenId := screenPlanetNO
      else if GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.OwnerId <> Byte(oiUninhabited)) then RequestedScreenId := screenPlanet
      else if GetPlayer.IsDockedToShip then RequestedScreenId := screenRuinsTalk;
    end
    else if GetPlayer.InHyperspace and (GetPlayer.Order = soJumpHole) and
      ((Loop is TfStarMap) or (Loop is TfAB)) then begin
      RequestedScreenId := screenMainMenu;
      Loop.RequestClose(1);
      ReopenScreen := False;
    end
    else if GetPlayer.InHyperspace and (GetPlayer.Order = soJump) and (Loop is TfStarMap) then begin
      RequestedScreenId := screenJump;
      Loop.RequestClose(1);
      ReopenScreen := False;
    end
    else if Loop is TfPlanetQuest then ReopenScreen := False
    else if (Loop is TfGov) and (GovernmentScreen.PendingTransition <> 0) then ReopenScreen := False
    else if Loop is TfJump then JumpScreen.RestoreOrdersOnArrival := True;
  end;
  if (GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.OwnerId <> Byte(oiUninhabited))) or
    (GetPlayer.IsDockedToShip and (GetPlayer.DockedTo is TRuins)) then BuildTemporaryShopSlotGrid;
  if ReopenScreen then (TObject(RegisteredScreens[Ord(CurrentScreenId)]) as TMessageLoopGI).OnOpen;
  Galaxy.ClearIntegrityStatus;
  Galaxy.PrimeIntegrityChecksum(1);
  MemorySnapshotBuffer.Free;
  MemorySnapshotBuffer := nil;
  MemorySnapshotActive := False;
  Galaxy.RunConfigOnLoadHandlers;
end;
{ @end $5258B4 }

{ @routine $526238 InitializeSaveWriter }
procedure InitializeSaveWriter;
begin SaveWriter := TSaver.Create; end;
{ @end $526238 }

{ @routine $52624C FinalizeSaveWriter }
procedure FinalizeSaveWriter;
begin
  if SaveWriter <> nil then begin
    if SaveWriter.IsRunning then SaveWriter.WaitForIdle(INFINITE);
    SaveWriter.Free;
    SaveWriter := nil;
  end;
end;
{ @end $52624C }

end.
