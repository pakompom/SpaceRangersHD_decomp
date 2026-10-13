unit EC_Cache;

interface

uses EC_Data, EC_Buf, EC_Struct, SyncObjs, Classes;

type
  TCacheDataEC = class;
  TCacheDataClass = class of TCacheDataEC;

  TCacheControlEC = class(TObjectEx) // @size 0x18
  public
    PrevBoundControl: TCacheControlEC; // @offset 0x04
    NextBoundControl: TCacheControlEC; // @offset 0x08
    BoundData: TCacheDataEC; // @offset 0x0C
    CacheKey: WideString; // @offset 0x10
    RetainCount: Integer; // @offset 0x14

    constructor Create; // @addr 0x004D2F34
    destructor Destroy; override; // @addr 0x004D2F6C
    procedure Reset; virtual; // @addr 0x004D2F98 @slot 0x00 @note "Drops all retains and the data binding."
    procedure SetCacheKey(const NewKey: WideString); virtual; // @addr 0x004D2FE0 @slot 0x04 @note "Drops existing retains and the data binding; may apply configured key substitutions."
    function HasEmptyCacheKey: Boolean; // @addr 0x004D3094
    procedure QueueLoadIfMissing(PendingLoads: TList); virtual; // @addr 0x004D30AC @slot 0x08
    function CreateData: TCacheDataEC; virtual; // @addr 0x004D30B0 @slot 0x0C @note "Base implementation returns nil."
    function AcquireData: TCacheDataEC; virtual; // @addr 0x004D3634 @slot 0x10 @note "Base implementation returns nil."
    procedure Release; virtual; // @addr 0x004D3638 @slot 0x14 @note "Saturates at zero; the data remains bound."

    // Acquisitions may block on pending loads and evict other cache entries.
    // Nested acquisitions reuse BoundData; the class argument selects existing entries.
    function AcquireDataFromConfig(CacheDataClass: TCacheDataClass): TCacheDataEC; // @addr 0x004D30B4
    function AcquireDataFromDirectKey(CacheDataClass: TCacheDataClass): TCacheDataEC; // @addr 0x004D33C0
    procedure EvictData(CacheDataClass: TCacheDataClass); // @addr 0x004D3648 @note "Only checks this control's RetainCount; frees the shared entry and detaches all its controls."
  end;

  TCacheDataEC = class(TObjectEx) // @size 0x20
  public
    PrevData: TCacheDataEC; // @offset 0x04
    NextData: TCacheDataEC; // @offset 0x08
    FirstBoundControl: TCacheControlEC; // @offset 0x0C
    LastBoundControl: TCacheControlEC; // @offset 0x10
    CacheKey: WideString; // @offset 0x14
    ResidentBytes: Integer; // @offset 0x18
    // Win32 event handle; zero after loading has completed.
    LoadCompleteEvent: Cardinal; // @offset 0x1C

    constructor Create; // @addr 0x004D36B8
    destructor Destroy; override; // @addr 0x004D36F0 @note "Detaches all controls without freeing them."
    procedure AppendControl(Control: TCacheControlEC); // @addr 0x004D3728 @note "Caller must set Control.BoundData."
    procedure UnlinkControl(Control: TCacheControlEC); // @addr 0x004D374C @note "Clears BoundData but preserves RetainCount."
    // Base load hooks are empty in the native implementation.
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); virtual; // @addr 0x004D3790 @slot 0x00
    procedure LoadFromKey(const Key: WideString); virtual; // @addr 0x004D3794 @slot 0x04
  end;

  TCacheEC = class(TObjectEx) // @size 0x1C
  public
    CacheLock: TCriticalSection; // @offset 0x04
    MostRecentData: TCacheDataEC; // @offset 0x08
    LeastRecentData: TCacheDataEC; // @offset 0x0C
    DataRoot: TDataEC; // @offset 0x10
    ResidentBytes: Integer; // @offset 0x14
    ResidentByteLimit: Integer; // @offset 0x18

    constructor Create; // @addr 0x004D3798
    destructor Destroy; override; // @addr 0x004D37DC
    procedure Clear; // @addr 0x004D3810 @note "Invalidates all entries, including retained ones."
    procedure SetDataRoot(Root: TDataEC); // @addr 0x004D382C @note "Root is borrowed; invalidates existing cached entries."
    procedure ResetControl(Control: TCacheControlEC); // @addr 0x004D3840
    // List and lookup helpers below do not acquire CacheLock.
    procedure AddDataToLruHead(Data: TCacheDataEC); // @addr 0x004D3848
    procedure RemoveAndFreeData(Data: TCacheDataEC); // @addr 0x004D386C @note "Does not adjust ResidentBytes. Accepts nil."
    function FindDataByKeyAndClass(const Key: WideString; CacheDataClass: TCacheDataClass): TCacheDataEC; // @addr 0x004D38AC @note "Case-sensitive key and exact class match; returns nil when absent."
    procedure TouchData(Data: TCacheDataEC); // @addr 0x004D38E8
    function OpenDataBuffer(const Path: WideString): TBufEC; // @addr 0x004D3928 @note "Caller owns the returned buffer."
    procedure TrimToBudget(BudgetBytes: Integer); // @addr 0x004D3950 @note "Retained entries can prevent reaching the budget."
    procedure QueueNamedLoadIfMissing(PendingLoads: TList; const CacheKind, Key: WideString); // @addr 0x004D39DC @note "PendingLoads owns added controls; duplicate pending entries are possible."
  end;

procedure EvictMainMenuShipCachesWhenAddressSpaceHigh; // @addr 0x004D3CAC @note "The threshold is 0x30000000 bytes of used virtual address space."
procedure EvictRuinsAndGovernmentCaches; // @addr $4D3F58
procedure EvictStarAndBackgroundCaches; // @addr $4D3FD8
procedure EvictBlockChildrenFromCache(BlockPath: WideString; CacheDataClass: TCacheDataClass); // @addr 0x004D4024 @note "Requires an exact cache-data class match."

implementation

uses EC_CacheSound, EC_CacheBitmap, EC_CacheTBitmap, EC_CacheAlphaBitmap, EC_CacheGAI, EC_CacheGI, EC_CachePlanetTempl, GR_DX, GR_Main, EC_Str, GlobalsV, SysUtils, Windows;

{ @routine $4D2F34 TCacheControlEC_Create }
constructor TCacheControlEC.Create;
begin
  inherited Create;
end;
{ @end $4D2F34 }

{ @routine $4D2F6C TCacheControlEC_Destroy }
destructor TCacheControlEC.Destroy;
begin
  Reset;
  inherited Destroy;
end;
{ @end $4D2F6C }

{ @routine $4D2F98 TCacheControlEC_Reset }
procedure TCacheControlEC.Reset;
begin
  RetainCount := 0;
  if BoundData <> nil then
  begin
    GlobalCache.CacheLock.Enter;
    BoundData.UnlinkControl(Self);
    GlobalCache.CacheLock.Leave;
    BoundData := nil;
  end;
  CacheKey := '';
end;
{ @end $4D2F98 }

{ @routine $4D2FE0 TCacheControlEC_SetCacheKey }
procedure TCacheControlEC.SetCacheKey(const NewKey: WideString);
begin
  Reset;
  CacheKey := NewKey;
  if not FontSmoothingEnabled then Exit;
  if NewKey = SmallFontName then CacheKey := SmoothSmallFontName
  else if NewKey = SmallBoldFontName then CacheKey := SmoothSmallBoldFontName
  else if NewKey = NormalFontName then CacheKey := SmoothNormalFontName
  else if NewKey = NormalBoldFontName then CacheKey := SmoothNormalBoldFontName;
end;
{ @end $4D2FE0 }

{ @routine $4D3094 TCacheControlEC_HasEmptyCacheKey }
function TCacheControlEC.HasEmptyCacheKey: Boolean;
begin
  if Length(CacheKey) < 1 then
    Result := True
  else
    Result := False;
end;
{ @end $4D3094 }

{ @routine $4D30AC TCacheControlEC_QueueLoadIfMissing }
procedure TCacheControlEC.QueueLoadIfMissing(PendingLoads: TList);
begin
end;
{ @end $4D30AC }

{ @routine $4D30B0 TCacheControlEC_CreateData }
function TCacheControlEC.CreateData: TCacheDataEC;
begin
  Result := nil;
end;
{ @end $4D30B0 }

{ @routine $4D30B4 TCacheControlEC_AcquireDataFromConfig }
function TCacheControlEC.AcquireDataFromConfig(CacheDataClass: TCacheDataClass): TCacheDataEC;
var
  Data: TCacheDataEC;
  Buffer: TBufEC;
  PartCount: Integer;
  Path, LoadOption: WideString;
begin
  if HardwareRenderingEnabled and not TextureManagerDisabled then
    EvictTextureCaches(False);
  if RetainCount > 0 then
    Inc(RetainCount)
  else
  begin
    GlobalCache.CacheLock.Enter;
    if BoundData = nil then
    begin
      BoundData := GlobalCache.FindDataByKeyAndClass(CacheKey, CacheDataClass);
      if BoundData = nil then
      begin
        Data := CreateData;
        Data.CacheKey := CacheKey;
        if CacheLoadLoggingEnabled then
          AppendLogLineThreadSafe('Cache Add=' + Data.CacheKey);
        Data.LoadCompleteEvent := CreateEvent(nil, True, False, nil);
        Data.AppendControl(Self);
        BoundData := Data;
        RetainCount := 1;
        GlobalCache.AddDataToLruHead(Data);
        GlobalCache.CacheLock.Leave;
        PartCount := CountDelimitedPartsW(CacheKey, '?');
        if PartCount < 2 then
        begin
          Path := CacheKey;
          LoadOption := '';
        end
        else
        begin
          Path := ExtractDelimitedPartW(CacheKey, 0, '?');
          LoadOption := ExtractDelimitedRangeW(CacheKey, 1, PartCount - 1, '?');
        end;
        Buffer := GlobalCache.OpenDataBuffer(Path);
        try
          Data.LoadFromConfigBuffer(Buffer, LoadOption);
        finally
          GlobalCache.CacheLock.Enter;
          Inc(GlobalCache.ResidentBytes, Data.ResidentBytes);
          SetEvent(Data.LoadCompleteEvent);
          CloseHandle(Data.LoadCompleteEvent);
          Data.LoadCompleteEvent := 0;
          Buffer.Free;
        end;
      end
      else
      begin
        if BoundData.LoadCompleteEvent <> 0 then
        begin
          GlobalCache.CacheLock.Leave;
          WaitForSingleObject(BoundData.LoadCompleteEvent, INFINITE);
          GlobalCache.CacheLock.Enter;
        end;
        BoundData.AppendControl(Self);
        RetainCount := 1;
      end;
    end
    else
      RetainCount := 1;
    GlobalCache.TouchData(BoundData);
    GlobalCache.CacheLock.Leave;
  end;
  Result := BoundData;
  GlobalCache.TrimToBudget(GlobalCache.ResidentByteLimit);
end;
{ @end $4D30B4 }

{ @routine $4D33C0 TCacheControlEC_AcquireDataFromDirectKey }
function TCacheControlEC.AcquireDataFromDirectKey(CacheDataClass: TCacheDataClass): TCacheDataEC;
var
  Data: TCacheDataEC;
begin
  if HardwareRenderingEnabled then
    EvictTextureCaches(False);
  if RetainCount > 0 then
    Inc(RetainCount)
  else
  begin
    GlobalCache.CacheLock.Enter;
    if BoundData = nil then
    begin
      BoundData := GlobalCache.FindDataByKeyAndClass(CacheKey, CacheDataClass);
      if BoundData = nil then
      begin
        Data := CreateData;
        Data.CacheKey := CacheKey;
        if CacheLoadLoggingEnabled then
          AppendLogLineThreadSafe('Cache Add=' + Data.CacheKey);
        Data.AppendControl(Self);
        Data.LoadCompleteEvent := CreateEvent(nil, True, False, nil);
        BoundData := Data;
        RetainCount := 1;
        GlobalCache.AddDataToLruHead(Data);
        GlobalCache.CacheLock.Leave;
        try
          Data.LoadFromKey(CacheKey);
        finally
          GlobalCache.CacheLock.Enter;
          Inc(GlobalCache.ResidentBytes, Data.ResidentBytes);
          SetEvent(Data.LoadCompleteEvent);
          CloseHandle(Data.LoadCompleteEvent);
          Data.LoadCompleteEvent := 0;
        end;
      end
      else
      begin
        if BoundData.LoadCompleteEvent <> 0 then
        begin
          GlobalCache.CacheLock.Leave;
          WaitForSingleObject(BoundData.LoadCompleteEvent, INFINITE);
          GlobalCache.CacheLock.Enter;
        end;
        BoundData.AppendControl(Self);
        RetainCount := 1;
      end;
    end
    else
      RetainCount := 1;
    GlobalCache.TouchData(BoundData);
    GlobalCache.CacheLock.Leave;
  end;
  Result := BoundData;
  GlobalCache.TrimToBudget(GlobalCache.ResidentByteLimit);
end;
{ @end $4D33C0 }

{ @routine $4D3634 TCacheControlEC_AcquireData }
function TCacheControlEC.AcquireData: TCacheDataEC;
begin
  Result := nil;
end;
{ @end $4D3634 }

{ @routine $4D3638 TCacheControlEC_Release }
procedure TCacheControlEC.Release;
begin
  if RetainCount > 0 then
    Dec(RetainCount)
  else
    RetainCount := 0;
end;
{ @end $4D3638 }

{ @routine $4D3648 TCacheControlEC_EvictData }
procedure TCacheControlEC.EvictData(CacheDataClass: TCacheDataClass);
begin
  if RetainCount > 0 then Exit;
  GlobalCache.CacheLock.Enter;
  if BoundData = nil then
    BoundData := GlobalCache.FindDataByKeyAndClass(CacheKey, CacheDataClass);
  if BoundData <> nil then
  begin
    Dec(GlobalCache.ResidentBytes, BoundData.ResidentBytes);
    GlobalCache.RemoveAndFreeData(BoundData);
    BoundData := nil;
  end;
  GlobalCache.CacheLock.Leave;
end;
{ @end $4D3648 }

{ @routine $4D36B8 TCacheDataEC_Create }
constructor TCacheDataEC.Create;
begin
  inherited Create;
end;
{ @end $4D36B8 }

{ @routine $4D36F0 TCacheDataEC_Destroy }
destructor TCacheDataEC.Destroy;
begin
  while FirstBoundControl <> nil do
    UnlinkControl(LastBoundControl);
  inherited Destroy;
end;
{ @end $4D36F0 }

{ @routine $4D3728 TCacheDataEC_AppendControl }
procedure TCacheDataEC.AppendControl(Control: TCacheControlEC);
begin
  if (LastBoundControl <> nil) then
  begin
    LastBoundControl.NextBoundControl := Control;
  end;
  Control.PrevBoundControl := LastBoundControl;
  Control.NextBoundControl := nil;
  LastBoundControl := Control;
  if (FirstBoundControl = nil) then
  begin
    FirstBoundControl := Control;
  end;
end;
{ @end $4D3728 }

{ @routine $4D374C TCacheDataEC_UnlinkControl }
procedure TCacheDataEC.UnlinkControl(Control: TCacheControlEC);
begin
  if (Control.PrevBoundControl <> nil) then
  begin
    Control.PrevBoundControl.NextBoundControl := Control.NextBoundControl;
  end;
  if (Control.NextBoundControl <> nil) then
  begin
    Control.NextBoundControl.PrevBoundControl := Control.PrevBoundControl;
  end;
  if (LastBoundControl = Control) then
  begin
    LastBoundControl := Control.PrevBoundControl;
  end;
  if (FirstBoundControl = Control) then
  begin
    FirstBoundControl := Control.NextBoundControl;
  end;
  Control.PrevBoundControl := nil;
  Control.NextBoundControl := nil;
  Control.BoundData := nil;
end;
{ @end $4D374C }

{ @routine $4D3790 TCacheDataEC_LoadFromConfigBuffer }
procedure TCacheDataEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
end;
{ @end $4D3790 }

{ @routine $4D3794 TCacheDataEC_LoadFromKey }
procedure TCacheDataEC.LoadFromKey(const Key: WideString);
begin
end;
{ @end $4D3794 }

{ @routine $4D3798 TCacheEC_Create }
constructor TCacheEC.Create;
begin
  inherited Create;
  CacheLock := TCriticalSection.Create;
end;
{ @end $4D3798 }

{ @routine $4D37DC TCacheEC_Destroy }
destructor TCacheEC.Destroy;
begin
  Clear;
  CacheLock.Free;
  inherited Destroy;
end;
{ @end $4D37DC }

{ @routine $4D3810 TCacheEC_Clear }
procedure TCacheEC.Clear;
begin
  while (MostRecentData <> nil) do
  begin
    RemoveAndFreeData(LeastRecentData);
  end;
  ResidentBytes := 0;
end;
{ @end $4D3810 }

{ @routine $4D382C TCacheEC_SetDataRoot }
procedure TCacheEC.SetDataRoot(Root: TDataEC);
begin
  Clear;
  DataRoot := Root;
end;
{ @end $4D382C }

{ @routine $4D3840 TCacheEC_ResetControl }
procedure TCacheEC.ResetControl(Control: TCacheControlEC);
begin
  Control.Reset;
end;
{ @end $4D3840 }

{ @routine $4D3848 TCacheEC_AddDataToLruHead }
procedure TCacheEC.AddDataToLruHead(Data: TCacheDataEC);
begin
  if (MostRecentData <> nil) then
  begin
    MostRecentData.PrevData := Data;
  end;
  Data.PrevData := nil;
  Data.NextData := MostRecentData;
  MostRecentData := Data;
  if (LeastRecentData = nil) then
  begin
    LeastRecentData := Data;
  end;
end;
{ @end $4D3848 }

{ @routine $4D386C TCacheEC_RemoveAndFreeData }
procedure TCacheEC.RemoveAndFreeData(Data: TCacheDataEC);
begin
  if Data = nil then Exit;
  if (Data.PrevData <> nil) then
  begin
    Data.PrevData.NextData := Data.NextData;
  end;
  if (Data.NextData <> nil) then
  begin
    Data.NextData.PrevData := Data.PrevData;
  end;
  if (LeastRecentData = Data) then
  begin
    LeastRecentData := Data.PrevData;
  end;
  if (MostRecentData = Data) then
  begin
    MostRecentData := Data.NextData;
  end;
  Data.Free;
end;
{ @end $4D386C }

{ @routine $4D38AC TCacheEC_FindDataByKeyAndClass }
function TCacheEC.FindDataByKeyAndClass(const Key: WideString; CacheDataClass: TCacheDataClass): TCacheDataEC;
var
  Data: TCacheDataEC;
begin
  Data := MostRecentData;
  while Data <> nil do
  begin
    if (Data.ClassType = CacheDataClass) and (Data.CacheKey = Key) then
      begin
        Result := Data;
        Exit;
      end;
    Data := Data.NextData;
  end;
  Result := nil;
end;
{ @end $4D38AC }

{ @routine $4D38E8 TCacheEC_TouchData }
procedure TCacheEC.TouchData(Data: TCacheDataEC);
begin
  if Data = MostRecentData then Exit;
  if (Data.PrevData <> nil) then
  begin
    Data.PrevData.NextData := Data.NextData;
  end;
  if (Data.NextData <> nil) then
  begin
    Data.NextData.PrevData := Data.PrevData;
  end;
  if (LeastRecentData = Data) then
  begin
    LeastRecentData := Data.PrevData;
  end;
  if (MostRecentData = Data) then
  begin
    MostRecentData := Data.NextData;
  end;
  AddDataToLruHead(Data);
end;
{ @end $4D38E8 }

{ @routine $4D3928 TCacheEC_OpenDataBuffer }
function TCacheEC.OpenDataBuffer(const Path: WideString): TBufEC;
var
  Buffer: TBufEC;
begin
  Buffer := TBufEC.Create;
  DataRoot.ReadBufferByPath(Path, Buffer);
  Result := Buffer;
end;
{ @end $4D3928 }

{ @routine $4D3950 TCacheEC_TrimToBudget }
procedure TCacheEC.TrimToBudget(BudgetBytes: Integer);
var
  Data, Removed: TCacheDataEC;
  RemainingBytes: Integer;
  Control: TCacheControlEC;
begin
  CacheLock.Enter;
  RemainingBytes := ResidentBytes;
  if RemainingBytes < BudgetBytes then
  begin
    CacheLock.Leave;
    Exit;
  end;
  EvictTextureCaches(True);
  Data := LeastRecentData;
  while (Data <> nil) and (RemainingBytes >= BudgetBytes) do
  begin
    Removed := Data;
    Data := Data.PrevData;
    Control := Removed.FirstBoundControl;
    while Control <> nil do
    begin
      if Control.RetainCount > 0 then Break;
      Control := Control.NextBoundControl;
    end;
    if Control = nil then
    begin
      RemainingBytes := RemainingBytes - Removed.ResidentBytes;
      Dec(ResidentBytes, Removed.ResidentBytes);
      RemoveAndFreeData(Removed);
    end;
  end;
  CacheLock.Leave;
end;
{ @end $4D3950 }

{ @routine $4D39DC TCacheEC_QueueNamedLoadIfMissing }
procedure TCacheEC.QueueNamedLoadIfMissing(PendingLoads: TList; const CacheKind: WideString; const Key: WideString);
var
  AlphaBitmap: TCAlphaBitmapControlEC;
  Bitmap: TCBitmapControlEC;
  TBitmap: TCTBitmapControlEC;
  Sound: TCSoundControlEC;
  Gai: TCGaiControlEC;
  Gi: TCGiControlEC;
  PlanetTempl: TCPlanetTemplControlEC;
begin
  if CacheKind = 'Alpha' then
  begin
    if FindDataByKeyAndClass(Key, TCAlphaBitmapEC) = nil then
    begin
      AlphaBitmap := TCAlphaBitmapControlEC.Create;
      ResetControl(AlphaBitmap);
      AlphaBitmap.SetCacheKey(Key);
      PendingLoads.Add(AlphaBitmap);
    end;
  end
  else if CacheKind = 'Bitmap' then
  begin
    if FindDataByKeyAndClass(Key, TCBitmapEC) = nil then
    begin
      Bitmap := TCBitmapControlEC.Create;
      ResetControl(Bitmap);
      Bitmap.SetCacheKey(Key);
      PendingLoads.Add(Bitmap);
    end;
  end
  else if CacheKind = 'Trans' then
  begin
    if FindDataByKeyAndClass(Key, TCTBitmapEC) = nil then
    begin
      TBitmap := TCTBitmapControlEC.Create;
      ResetControl(TBitmap);
      TBitmap.SetCacheKey(Key);
      PendingLoads.Add(TBitmap);
    end;
  end
  else if CacheKind = 'GI' then
  begin
    if FindDataByKeyAndClass(Key, TCGiEC) = nil then
    begin
      Gi := TCGiControlEC.Create;
      ResetControl(Gi);
      Gi.SetCacheKey(Key);
      PendingLoads.Add(Gi);
    end;
  end
  else if CacheKind = 'GAI' then
  begin
    if FindDataByKeyAndClass(Key, TCGaiEC) = nil then
    begin
      Gai := TCGaiControlEC.Create;
      ResetControl(Gai);
      Gai.SetCacheKey(Key);
      PendingLoads.Add(Gai);
    end;
  end
  else if CacheKind = 'Sound' then
  begin
    if FindDataByKeyAndClass(Key, TCSoundEC) = nil then
    begin
      Sound := TCSoundControlEC.Create;
      ResetControl(Sound);
      Sound.SetCacheKey(Key);
      PendingLoads.Add(Sound);
    end;
  end
  else if CacheKind = 'PlanetTempl' then
  begin
    if FindDataByKeyAndClass(Key, TCPlanetTemplEC) = nil then
    begin
      PlanetTempl := TCPlanetTemplControlEC.Create;
      ResetControl(PlanetTempl);
      PlanetTempl.SetCacheKey(Key);
      PendingLoads.Add(PlanetTempl);
    end;
  end;
end;
{ @end $4D39DC }

{ @routine $4D3CAC EvictMainMenuShipCachesWhenAddressSpaceHigh }
procedure EvictMainMenuShipCachesWhenAddressSpaceHigh;
var
  i: Integer;
  Control: TCacheControlEC;
  Status: TMemoryStatusEx;
begin
  Status.Length := SizeOf(Status);
  GlobalMemoryStatusEx(Status);
  if Status.TotalVirtual - Status.AvailVirtual < $30000000 then Exit;
  Control := TCacheControlEC.Create;
  GlobalCache.ResetControl(Control);
  for i := 1 to 3 do
  begin
    Control.SetCacheKey('Bm.FormMain3.2ShipA' + IntToStr(i));
    Control.EvictData(TCGaiEC);
  end;
  for i := 1 to 3 do
  begin
    Control.SetCacheKey('Bm.FormMain3.2Ship' + IntToStr(i));
    Control.EvictData(TCGiEC);
  end;
  for i := 1 to 3 do
  begin
    Control.SetCacheKey('Bm.FormMain3.AnimGaalShip0' + IntToStr(i) + 'A');
    Control.EvictData(TCGaiEC);
  end;
  for i := 1 to 3 do
  begin
    Control.SetCacheKey('Bm.FormMain3.AnimGaalShip0' + IntToStr(i));
    Control.EvictData(TCGiEC);
  end;
  Control.SetCacheKey('Bm.FormMain3.2BG');
  Control.EvictData(TCGiEC);
  Control.Free;
end;
{ @end $4D3CAC }

{ @routine $4D3F58 EvictRuinsAndGovernmentCaches }
procedure EvictRuinsAndGovernmentCaches;
begin
  EvictBlockChildrenFromCache('Bm.FormRuins', TCGaiEC);
  EvictBlockChildrenFromCache('Bm.GovHD', TCGaiEC);
  EvictBlockChildrenFromCache('Bm.Gov', TCGaiEC);
end;
{ @end $4D3F58 }

{ @routine $4D3FD8 EvictStarAndBackgroundCaches }
procedure EvictStarAndBackgroundCaches;
begin
  EvictBlockChildrenFromCache('Bm.Star', TCGaiEC);
  EvictBlockChildrenFromCache('Bm.BGO', TCGaiEC);
end;
{ @end $4D3FD8 }

{ @routine $4D4024 EvictBlockChildrenFromCache }
procedure EvictBlockChildrenFromCache(BlockPath: WideString; CacheDataClass: TCacheDataClass);
var
  i: Integer;
  Control: TCacheControlEC;
  Data: TDataEC;
begin
  Data := CacheDataRoot;
  for i := 0 to CountDelimitedPartsW(BlockPath, '.') - 1 do
    Data := Data.GetData(ExtractDelimitedPartW(BlockPath, i, '.'));
  Control := TCacheControlEC.Create;
  GlobalCache.ResetControl(Control);
  for i := 0 to Data.IndexedEntryCount - 1 do
  begin
    Control.SetCacheKey(BlockPath + '.' + Data.IndexedEntries[i].Name);
    Control.EvictData(CacheDataClass);
  end;
  Control.Free;
end;
{ @end $4D4024 }

end.
