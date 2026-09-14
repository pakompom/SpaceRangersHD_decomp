unit GR_Sound;
// Unit bracket (inferred): .text 0x007F5204..0x007F8518; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, DirectSound, SyncObjs, VorbisFile;

const
  SoundStreamPrimeAll = -1;

type

  TSoundBufferControl = class;
  TSoundBuffer = class;
  TSoundControl = class;

  TSoundBufferControl = class(TObjectEx) // @size 0x1C
  public
    SoundPath: WideString; // @offset 0x04
    SoundGroup: Integer; // @offset 0x08  Nonzero groups suppress quieter concurrent sounds in the same group.
    Looping: Boolean; // @offset 0x0C
    Buffer: TSoundBuffer; // @offset 0x10  Borrowed from the sound manager; the buffer holds a back-reference to this controller.
    Volume: Single; // @offset 0x14
    Pan: Single; // @offset 0x18

    constructor Create; // @addr 0x7F59EC @ida "TSoundBufferControl *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7F5A30 @ida "void __usercall $name(TSoundBufferControl *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr 0x7F5A6C @note "Releases the active buffer and resets Volume/Pan only when Buffer is non-nil. Keeps path, group and looping mode."
    procedure Configure(const Path: WideString; Group: Integer; ALooping: Boolean); // @addr 0x7F5AB0 @note "Identical paths leave every setting unchanged, including group and looping mode."
    procedure SetVolume(Value: Single); // @addr 0x7F5B00 @ida "void __userpurge $name(TSoundBufferControl *Self@<eax>, float Value@<^0>);" @note "Unchanged values do nothing. Looping sounds start lazily at nonzero volume; changing to zero clears an active loop. The controller retains the unclamped value."
    procedure SetPan(Value: Single); // @addr 0x7F5BE4 @ida "void __userpurge $name(TSoundBufferControl *Self@<eax>, float Value@<^0>);" @note "A changed pan can start an inactive looping sound, even at zero volume."
    procedure Play; // @addr 0x7F5C8C @note "Restarts non-looping sounds; does nothing in looping mode."
    function IsPlaying: Boolean; // @addr 0x7F5CF0
  end;

  TSoundBuffer = class(TObjectEx) // @size 0x68
  public
    Prev: TSoundBuffer; // @offset 0x04
    Next: TSoundBuffer; // @offset 0x08
    AutoRelease: Boolean; // @offset 0x0C
    Streaming: Boolean; // @offset 0x0D
    Started: Boolean; // @offset 0x0E
    DirectBuffer: IDirectSoundBuffer; // @offset 0x10
    Notify: IDirectSoundNotify; // @offset 0x14
    // WaitForChunk passes this contiguous stop/chunk/volume event sequence to Win32.
    StopEvent: Cardinal; // @offset 0x18
    ChunkEvents: array[0..2] of Cardinal; // @offset 0x1C
    VolumeEvent: Cardinal; // @offset 0x28
    BufferBytes: Integer; // @offset 0x2C  One chunk when Streaming, otherwise the whole buffer.
    WaveFormat: TSoundWaveFormat; // @offset 0x30
    VolumeTimer: Cardinal; // @offset 0x44
    Volume: Single; // @offset 0x48
    VolumeScale: Single; // @offset 0x4C
    VolumeStep: Single; // @offset 0x50
    FadingOut: Boolean; // @offset 0x54
    SoundGroup: Integer; // @offset 0x58
    Controller: TSoundBufferControl; // @offset 0x5C
    WriteOffset: Integer; // @offset 0x60
    LastPlayCursor: Cardinal; // @offset 0x64

    destructor Destroy; override; // @addr $7F5E5C @ida "void __usercall $name(TSoundBuffer *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr $7F5F08
    function WaitForChunk: Integer; // @addr $7F6EC4
    procedure SignalStop; // @addr $7F70D8
    procedure SetVolumeScale(Value: Single); // @addr $7F735C @ida "void __userpurge $name(TSoundBuffer *Self@<eax>, float Value@<^0>);"
    procedure StartVolumeRamp(Interval: Cardinal; Step: Single); // @addr $7F73C0 @ida "void __userpurge $name(TSoundBuffer *Self@<eax>, unsigned int Interval@<edx>, float Step@<^0>);"
    constructor Create; // @addr 0x7F5D1C @ida "TSoundBuffer *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    procedure Init(ByteCount: Integer; Format: Pointer); // @addr 0x7F5FEC @note "Copies 20 bytes from Format into internal wave-format storage."
    procedure InitStream(ChunkBytes: Integer; Format: Pointer); // @addr 0x7F6184 @note "Copies 20 bytes from Format; allocates three chunks of streaming audio."
    procedure ClearBuf; // @addr 0x7F657C @note "Fills the audio buffer with silence; does not release it."
    procedure Write(Data: Pointer; ByteCount: Cardinal; Format: Pointer); // @addr 0x7F674C @note "Format points to 20 bytes; data and format are copied, not retained."
    function WriteStream(Chunk: Integer; var Decoder: TOggWorker): Boolean; // @addr $7F6940 @note "Chunk=-1 primes the buffer; other values refill from the current playback cursor. False indicates exhaustion or an unavailable buffer."
    procedure Play(Looping: Boolean); // @addr 0x7F6CE0 @note "Streaming buffers always loop."
    function IsPlaying: Boolean; // @addr 0x7F6FC0
    procedure SetVolume(Value: Single); // @addr 0x7F70F0 @ida "void __userpurge $name(TSoundBuffer *Self@<eax>, float Value@<^0>);" @note "Stores the unclamped value and combines it with the buffer's secondary volume multiplier."
    procedure SetPan(Value: Single); // @addr 0x7F7420 @ida "void __userpurge $name(TSoundBuffer *Self@<eax>, float Value@<^0>);" @note "Clamps the DirectSound pan to -10000..10000."
  end;

  TSoundControl = class(TObjectEx) // @size 0x30
  public
    FirstBuffer: TSoundBuffer; // @offset 0x04
    LastBuffer: TSoundBuffer; // @offset 0x08
    DirectSound: IDirectSound; // @offset 0x0C
    PrimaryBuffer: IDirectSoundBuffer; // @offset 0x10
    WaveFormat: TSoundWaveFormat; // @offset 0x14
    Lock: TCriticalSection; // @offset 0x28
    LastFadeTick: Cardinal; // @offset 0x2C

    destructor Destroy; override; // @addr $7F7CB4 @ida "void __usercall $name(TSoundControl *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr $7F7D10
    procedure StopUncontrolledSounds; // @addr $7F7D34
    function AddBuffer: TSoundBuffer; // @addr $7F7DA4
    procedure RemoveBuffer(Buffer: TSoundBuffer); // @addr $7F7E48
    function SuppressGroup(Group: Integer; Volume: Single): Boolean; // @addr $7F7EF8 @ida "bool __userpurge $name@<al>(TSoundControl *Self@<eax>, int Group@<edx>, float Volume@<^0>);"
    procedure RemoveFinishedBuffers; // @addr $7F7FBC
    procedure UpdateFades; // @addr $7F8048
    procedure PlaySound(const Path: WideString); // @addr $7F815C
    function PlayEffect(const Path: WideString; Group: Integer; Volume, Pan: Single): TSoundBuffer; // @addr $7F8258 @ida "TSoundBuffer *__userpurge $name@<eax>(TSoundControl *Self@<eax>, unsigned __int16 *Path@<edx>, int Group@<ecx>, float Volume@<^4>, float Pan@<^0>);"
    function PlayLoop(const Path: WideString; Group: Integer; Volume, Pan: Single): TSoundBuffer; // @addr $7F8394 @ida "TSoundBuffer *__userpurge $name@<eax>(TSoundControl *Self@<eax>, unsigned __int16 *Path@<edx>, int Group@<ecx>, float Volume@<^4>, float Pan@<^0>);"
    procedure SignalStop; // @addr $7F84D0
    constructor Create; // @addr 0x7F7634 @ida "TSoundControl *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
  end;

function EnumerateSoundDevice(Guid: Pointer; Description, Module: PAnsiChar; Context: Pointer): LongBool; stdcall; // @addr $7F7560

function SoundErrorText(Code: Integer): AnsiString; // @addr $7F5360 @ida "void __usercall $name(int Code@<eax>, char **Result@<edx>);"

implementation

uses Windows, SysUtils, GR_Main, MMSystem, EC_Cache, EC_CacheSound, EC_Str, EC_Mem, Math;

const
  UnsignedPcmSilence = $80;
  SoundEventPollMs = 1000;

{ @routine $7F5360 SoundErrorText }
function SoundErrorText(Code: Integer): AnsiString;
begin
  Result := '';
  case Code of
    DS_OK: Result := 'DS_OK';
    DS_NO_VIRTUALIZATION: Result := 'DS_NO_VIRTUALIZATION';
    DS_INCOMPLETE: Result := 'DS_INCOMPLETE';
    DSERR_ALLOCATED: Result := 'DSERR_ALLOCATED';
    DSERR_CONTROLUNAVAIL: Result := 'DSERR_CONTROLUNAVAIL';
    DSERR_INVALIDPARAM: Result := 'DSERR_INVALIDPARAM';
    DSERR_INVALIDCALL: Result := 'DSERR_INVALIDCALL';
    DSERR_GENERIC: Result := 'DSERR_GENERIC';
    DSERR_PRIOLEVELNEEDED: Result := 'DSERR_PRIOLEVELNEEDED';
    DSERR_OUTOFMEMORY: Result := 'DSERR_OUTOFMEMORY';
    DSERR_BADFORMAT: Result := 'DSERR_BADFORMAT';
    DSERR_UNSUPPORTED: Result := 'DSERR_UNSUPPORTED';
    DSERR_NODRIVER: Result := 'DSERR_NODRIVER';
    DSERR_ALREADYINITIALIZED: Result := 'DSERR_ALREADYINITIALIZED';
    DSERR_NOAGGREGATION: Result := 'DSERR_NOAGGREGATION';
    DSERR_BUFFERLOST: Result := 'DSERR_BUFFERLOST';
    DSERR_OTHERAPPHASPRIO: Result := 'DSERR_OTHERAPPHASPRIO';
    DSERR_UNINITIALIZED: Result := 'DSERR_UNINITIALIZED';
    DSERR_NOINTERFACE: Result := 'DSERR_NOINTERFACE';
    DSERR_ACCESSDENIED: Result := 'DSERR_ACCESSDENIED';
    DSERR_BUFFERTOOSMALL: Result := 'DSERR_BUFFERTOOSMALL';
    DSERR_DS8_REQUIRED: Result := 'DSERR_DS8_REQUIRED';
    DSERR_SENDLOOP: Result := 'DSERR_SENDLOOP';
    DSERR_BADSENDBUFFERGUID: Result := 'DSERR_BADSENDBUFFERGUID';
    DSERR_OBJECTNOTFOUND: Result := 'DSERR_OBJECTNOTFOUND';
    DSERR_FXUNAVAILABLE: Result := 'DSERR_FXUNAVAILABLE';
  else
    Result := 'unrecognized DirectSound error ' + CardinalToHexWideString(Code);
  end;
end;
{ @end $7F5360 }

{ @routine $7F59EC TSoundBufferControl_Create }
constructor TSoundBufferControl.Create;
begin
  inherited Create;
end;
{ @end $7F59EC }

{ @routine $7F5A30 TSoundBufferControl_Destroy }
destructor TSoundBufferControl.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $7F5A30 }

{ @routine $7F5A6C TSoundBufferControl_Clear }
procedure TSoundBufferControl.Clear;
begin
  if Buffer <> nil then
  begin
    Buffer.Controller := nil;
    Buffer.Clear;
    Buffer := nil;
    Volume := 0;
    Pan := 0;
  end;
end;
{ @end $7F5A6C }

{ @routine $7F5AB0 TSoundBufferControl_Configure }
procedure TSoundBufferControl.Configure(const Path: WideString; Group: Integer; ALooping: Boolean);
begin
  if SoundPath <> Path then
  begin
    Clear;
    SoundGroup := Group;
    SoundPath := Path;
    Looping := ALooping;
  end;
end;
{ @end $7F5AB0 }

{ @routine $7F5B00 TSoundBufferControl_SetVolume }
procedure TSoundBufferControl.SetVolume(Value: Single);
begin
  if Volume = Value then Exit;
  if Looping then
  begin
    if Value = 0 then
    begin
      if Buffer <> nil then Clear;
    end
    else
    begin
      Volume := Value;
      if Buffer = nil then
      begin
        Buffer := SoundManager.PlayLoop(SoundPath, SoundGroup, Volume, Pan);
        if Buffer <> nil then Buffer.Controller := Self;
      end
      else Buffer.SetVolumeScale(Volume);
    end;
  end
  else
  begin
    Volume := Value;
    if Buffer <> nil then Buffer.SetVolumeScale(Volume);
  end;
end;
{ @end $7F5B00 }

{ @routine $7F5BE4 TSoundBufferControl_SetPan }
procedure TSoundBufferControl.SetPan(Value: Single);
begin
  if Pan = Value then Exit;
  Pan := Value;
  if Looping then
  begin
    if Buffer = nil then
    begin
      Buffer := SoundManager.PlayLoop(SoundPath, SoundGroup, Volume, Pan);
      if Buffer <> nil then Buffer.Controller := Self;
    end
    else Buffer.SetPan(Pan);
  end
  else if Buffer <> nil then Buffer.SetPan(Pan);
end;
{ @end $7F5BE4 }

{ @routine $7F5C8C TSoundBufferControl_Play }
procedure TSoundBufferControl.Play;
begin
  if Looping then Exit;
  if Buffer <> nil then Clear;
  Buffer := SoundManager.PlayEffect(SoundPath, SoundGroup, Volume, Pan);
  if Buffer <> nil then Buffer.Controller := Self;
end;
{ @end $7F5C8C }

{ @routine $7F5CF0 TSoundBufferControl_IsPlaying }
function TSoundBufferControl.IsPlaying: Boolean;
begin
  Result := False;
  if Buffer <> nil then Result := Buffer.IsPlaying;
end;
{ @end $7F5CF0 }

{ @routine $7F5D1C TSoundBuffer_Create }
constructor TSoundBuffer.Create;
var i: Integer;
begin
  inherited Create;
  Streaming := False;
  DirectBuffer := nil;
  Notify := nil;
  for i := Low(ChunkEvents) to High(ChunkEvents) do ChunkEvents[i] := 0;
  StopEvent := Windows.CreateEvent(nil, True, False, nil);
  for i := Low(ChunkEvents) to High(ChunkEvents) do ChunkEvents[i] := Windows.CreateEvent(nil, False, False, nil);
  VolumeEvent := Windows.CreateEvent(nil, False, False, nil);
  BufferBytes := 0;
  Volume := 1;
  VolumeScale := 1;
  FillChar(WaveFormat, SizeOf(WaveFormat), 0);
  if PAnsiChar(@VolumeEvent) - PAnsiChar(@StopEvent) <> SizeOf(StopEvent) + SizeOf(ChunkEvents) then
    RaiseWideMessage('TSoundBuffer.Create 2');
end;
{ @end $7F5D1C }

{ @routine $7F5E5C TSoundBuffer_Destroy }
destructor TSoundBuffer.Destroy;
var i: Integer;
begin
  Clear;
  if StopEvent <> 0 then
  begin
    CloseHandle(StopEvent);
    StopEvent := 0;
  end;
  for i := Low(ChunkEvents) to High(ChunkEvents) do
    if ChunkEvents[i] <> 0 then
    begin
      CloseHandle(ChunkEvents[i]);
      ChunkEvents[i] := 0;
    end;
  if VolumeEvent <> 0 then
  begin
    CloseHandle(VolumeEvent);
    VolumeEvent := 0;
  end;
  inherited Destroy;
end;
{ @end $7F5E5C }

{ @routine $7F5F08 TSoundBuffer_Clear }
procedure TSoundBuffer.Clear;
begin
  SoundManager.Lock.Enter;
  try
    if Controller <> nil then
    begin
      Controller.Buffer := nil;
      Controller.Volume := 0;
      Controller := nil;
    end;
    if VolumeTimer <> 0 then
    begin
      timeKillEvent(VolumeTimer);
      VolumeTimer := 0;
    end;
    if DirectBuffer <> nil then DirectBuffer.Stop;
    Notify := nil;
    DirectBuffer := nil;
    BufferBytes := 0;
    Streaming := False;
    Started := False;
    FillChar(WaveFormat, SizeOf(WaveFormat), 0);
  finally
    SoundManager.Lock.Leave;
  end;
end;
{ @end $7F5F08 }

{ @routine $7F5FEC TSoundBuffer_Init }
procedure TSoundBuffer.Init(ByteCount: Integer; Format: Pointer);
var Status: Integer;
    Desc: TDSBufferDesc;
begin
  SoundManager.Lock.Enter;
  try
    Clear;
    BufferBytes := ByteCount;
    CopyMemory(@WaveFormat, Format, SizeOf(WaveFormat));
    FillChar(Desc, SizeOf(Desc), 0);
    Desc.Size := SizeOf(Desc);
    Desc.Flags := DSBCAPS_STATIC or DSBCAPS_LOCSOFTWARE or DSBCAPS_CTRLPAN or DSBCAPS_CTRLVOLUME;
    Desc.BufferBytes := ByteCount;
    Desc.WaveFormat := @WaveFormat;
    SoundManager.Lock.Enter;
    try
      Status := SoundManager.DirectSound.CreateSoundBuffer(Desc, DirectBuffer, nil);
    finally
      SoundManager.Lock.Leave;
    end;
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.Init');
      raise Exception.Create(SoundErrorText(Status));
    end;
  finally
    SoundManager.Lock.Leave;
  end;
end;
{ @end $7F5FEC }

{ @routine $7F6184 TSoundBuffer_InitStream }
procedure TSoundBuffer.InitStream(ChunkBytes: Integer; Format: Pointer);
var Status: Integer;
    Positions, Position: PDSPositionNotify;
    i: Integer;
    Desc: TDSBufferDesc;
begin
  SoundManager.Lock.Enter;
  try
    Clear;
    WriteOffset := 0;
    LastPlayCursor := 0;
    BufferBytes := ChunkBytes;
    CopyMemory(@WaveFormat, Format, SizeOf(WaveFormat));
    FillChar(Desc, SizeOf(Desc), 0);
    Desc.Size := SizeOf(Desc);
    Desc.Flags := DSBCAPS_LOCSOFTWARE or DSBCAPS_CTRLPAN or DSBCAPS_CTRLVOLUME or
      DSBCAPS_CTRLPOSITIONNOTIFY or DSBCAPS_GETCURRENTPOSITION2;
    Desc.BufferBytes := ChunkBytes * Length(ChunkEvents);
    Desc.WaveFormat := @WaveFormat;
    SoundManager.Lock.Enter;
    try
      Status := SoundManager.DirectSound.CreateSoundBuffer(Desc, DirectBuffer, nil);
    finally
      SoundManager.Lock.Leave;
    end;
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.InitStream 1');
      raise Exception.Create(SoundErrorText(Status));
    end;
    Status := DirectBuffer.QueryInterface(IDirectSoundNotify, Notify);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.InitStream 2');
      raise Exception.Create(SoundErrorText(Status));
    end;
    Positions := AllocClearEC(Length(ChunkEvents) * SizeOf(TDSPositionNotify));
    Position := Positions;
    for i := Low(ChunkEvents) to High(ChunkEvents) do
    begin
      Position.EventHandle := ChunkEvents[i];
      if i = 0 then Position.Offset := ChunkBytes * Length(ChunkEvents) - 1
      else Position.Offset := i * ChunkBytes - 1;
      Position := AddPointerOffset(Position, SizeOf(TDSPositionNotify));
    end;
    Status := Notify.SetNotificationPositions(Length(ChunkEvents), Positions);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.InitStream 3');
      FreeEC(Positions);
      raise Exception.Create(SoundErrorText(Status));
    end;
    FreeEC(Positions);
    Status := DirectBuffer.GetFormat(@WaveFormat, SizeOf(WaveFormat), nil);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.InitStream 4');
      raise Exception.Create(SoundErrorText(Status));
    end;
    ClearBuf;
    SetVolume(MusicVolume * MusicVolumeScale);
    SetVolumeScale(1);
    Streaming := True;
  finally
    SoundManager.Lock.Leave;
  end;
end;
{ @end $7F6184 }

{ @routine $7F657C TSoundBuffer_ClearBuf }
procedure TSoundBuffer.ClearBuf;
var Data: Pointer;
    Bytes: Cardinal;
    Status: Integer;
begin
  SoundManager.Lock.Enter;
  try
    Data := nil;
    Bytes := 0;
    if DirectBuffer = nil then Exit;
    Status := DirectBuffer.Lock(0, 0, @Data, @Bytes, nil, nil, DSBLOCK_ENTIREBUFFER);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.ClearBuf 1');
      raise Exception.Create(SoundErrorText(Status));
    end;
    if WaveFormat.BitsPerSample = 8 then FillMemory(Data, Bytes, UnsignedPcmSilence)
    else FillChar(Data^, Bytes, 0);
    Status := DirectBuffer.Unlock(Data, Bytes, nil, 0);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.ClearBuf 2');
      raise Exception.Create(SoundErrorText(Status));
    end;
  finally
    SoundManager.Lock.Leave;
  end;
end;
{ @end $7F657C }

{ @routine $7F674C TSoundBuffer_Write }
procedure TSoundBuffer.Write(Data: Pointer; ByteCount: Cardinal; Format: Pointer);
var Dest: Pointer;
    Bytes: Cardinal;
    Status: Integer;
begin
  SoundManager.Lock.Enter;
  try
    if (Cardinal(BufferBytes) < ByteCount) or not CompareMem(@WaveFormat, Format, SizeOf(WaveFormat)) or Streaming then
      Init(ByteCount, Format);
    if DirectBuffer = nil then Exit;
    Dest := nil;
    Bytes := 0;
    Status := DirectBuffer.Lock(0, ByteCount, @Dest, @Bytes, nil, nil, DSBLOCK_ENTIREBUFFER);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.Write 1');
      raise Exception.Create(SoundErrorText(Status));
    end;
    CopyMemory(Dest, Data, ByteCount);
    Status := DirectBuffer.Unlock(Dest, Bytes, nil, 0);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.Write 2');
      raise Exception.Create(SoundErrorText(Status));
    end;
  finally
    SoundManager.Lock.Leave;
  end;
end;
{ @end $7F674C }

{ @routine $7F6940 TSoundBuffer_WriteStream }
function TSoundBuffer.WriteStream(Chunk: Integer; var Decoder: TOggWorker): Boolean;
var Offset: Integer;
    Dest: Pointer;
    LockedBytes: Cardinal;
    Status, ReadBytes, WantedBytes: Integer;
    Temp: Pointer;
    PlayCursor, WriteCursor, PlayedChunkStart: Cardinal;
begin
  SoundManager.Lock.Enter;
  Result := False;
  try
    if not Streaming then Exit;
    if DirectBuffer = nil then Exit;
    if Chunk = SoundStreamPrimeAll then
    begin
      Offset := 0;
      WantedBytes := BufferBytes * Length(ChunkEvents);
    end
    else
    begin
      DirectBuffer.GetCurrentPosition(@PlayCursor, @WriteCursor);
      PlayedChunkStart := PlayCursor div Cardinal(BufferBytes) * Cardinal(BufferBytes);
      if LastPlayCursor = PlayedChunkStart then
      begin
        Result := True;
        Exit;
      end;
      LastPlayCursor := PlayedChunkStart;
      if Cardinal(WriteOffset) >= PlayedChunkStart then
      begin
        if Cardinal(WriteOffset) >= WriteCursor then
        begin
          WantedBytes := BufferBytes * Length(ChunkEvents) - WriteOffset;
          Offset := WriteOffset;
          WriteOffset := 0;
        end
        else
        begin
          Offset := (Cardinal(BufferBytes) + WriteCursor - 1) div Cardinal(BufferBytes) * Cardinal(BufferBytes);
          if BufferBytes * Length(ChunkEvents) <= Offset then
          begin
            Offset := 0;
            WantedBytes := PlayedChunkStart;
            WriteOffset := PlayedChunkStart;
          end
          else
          begin
            WriteOffset := 0;
            WantedBytes := BufferBytes * Length(ChunkEvents) - Offset;
          end;
        end;
      end
      else
      begin
        Offset := WriteOffset;
        WantedBytes := PlayedChunkStart - Cardinal(Offset);
        if WantedBytes <= 0 then
        begin
          Result := True;
          Exit;
        end;
        Inc(WriteOffset, WantedBytes);
      end;
    end;
    ReadBytes := WantedBytes;
    Temp := AllocEC(ReadBytes);
    if ReadVorbisSamples(Decoder, Temp, ReadBytes) = 0 then ReadBytes := 0;
    if ReadBytes > 0 then
    begin
      Dest := nil;
      LockedBytes := 0;
      Status := DirectBuffer.Lock(Offset, ReadBytes, @Dest, @LockedBytes, nil, nil, 0);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
      begin
        AppendLogLineThreadSafe('Error in TSoundBuffer.WriteStream 1');
        raise Exception.Create(SoundErrorText(Status));
      end;
      CopyMemory(Dest, Temp, ReadBytes);
      if BufferBytes > ReadBytes then
      begin
        if WaveFormat.BitsPerSample = 8 then
          FillMemory(PAnsiChar(Dest) + ReadBytes, BufferBytes - ReadBytes, UnsignedPcmSilence)
        else FillChar(Pointer(PAnsiChar(Dest) + ReadBytes)^, BufferBytes - ReadBytes, 0);
      end;
      Status := DirectBuffer.Unlock(Dest, LockedBytes, nil, 0);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
      begin
        AppendLogLineThreadSafe('Error in TSoundBuffer.WriteStream 2');
        raise Exception.Create(SoundErrorText(Status));
      end;
    end;
    FreeEC(Temp);
  finally
    SoundManager.Lock.Leave;
  end;
  Result := ReadBytes >= WantedBytes;
end;
{ @end $7F6940 }

{ @routine $7F6CE0 TSoundBuffer_Play }
procedure TSoundBuffer.Play(Looping: Boolean);
var Status, i: Integer;
begin
  SoundManager.Lock.Enter;
  try
    for i := Low(ChunkEvents) to High(ChunkEvents) do ResetEvent(ChunkEvents[i]);
    ResetEvent(VolumeEvent);
    if DirectBuffer = nil then Exit;
    if not Streaming then
    begin
      if Looping then Status := DirectBuffer.Play(0, 0, DSBPLAY_LOOPING)
      else Status := DirectBuffer.Play(0, 0, 0);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.Play 1');
      raise Exception.Create(SoundErrorText(Status));
    end;
    end
    else
    begin
      Status := DirectBuffer.Play(0, 0, DSBPLAY_LOOPING);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.Play 2');
      raise Exception.Create(SoundErrorText(Status));
    end;
    end;
    Started := True;
  finally
    SoundManager.Lock.Leave;
  end;
end;
{ @end $7F6CE0 }

{ @routine $7F6EC4 TSoundBuffer_WaitForChunk }
function TSoundBuffer.WaitForChunk: Integer;
var WaitResult: Cardinal;
begin
  Result := -1;
  if not Streaming then
  begin
    WaitForSingleObject(ChunkEvents[0], INFINITE);
    Result := 0;
  end
  else if VolumeTimer = 0 then
  begin
    WaitResult := WaitForMultipleObjects(Length(ChunkEvents) + 1, @StopEvent, False, SoundEventPollMs);
    if WaitResult = WAIT_TIMEOUT then Result := 0
    else Result := WaitResult - WAIT_OBJECT_0 - 1;
  end
  else
  begin
    while True do
    begin
      WaitResult := WaitForMultipleObjects(Length(ChunkEvents) + 2, @StopEvent, False, SoundEventPollMs);
      if WaitResult = WAIT_TIMEOUT then begin Result := 0; Break end;
      if WaitResult = WAIT_OBJECT_0 then begin Result := -1; Break end;
      if WaitResult <> WAIT_OBJECT_0 + Length(ChunkEvents) + 1 then
      begin
        Result := WaitResult - WAIT_OBJECT_0 - 1;
        Break;
      end;
      SetVolumeScale(VolumeScale + VolumeStep);
      if VolumeScale = 0 then begin Result := -1; Break end;
    end;
  end;
end;
{ @end $7F6EC4 }

{ @routine $7F6FC0 TSoundBuffer_IsPlaying }
function TSoundBuffer.IsPlaying: Boolean;
var Flags: Cardinal;
    Status: Integer;
begin
  SoundManager.Lock.Enter;
  Result := False;
  try
    if DirectBuffer = nil then Exit;
    Status := DirectBuffer.GetStatus(Flags);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.IsPlaying');
      raise Exception.Create(SoundErrorText(Status));
    end;
  finally
    SoundManager.Lock.Leave;
  end;
  Result := (Flags and DSBSTATUS_PLAYING) = DSBSTATUS_PLAYING;
end;
{ @end $7F6FC0 }

{ @routine $7F70D8 TSoundBuffer_SignalStop }
procedure TSoundBuffer.SignalStop;
begin
  SetEvent(StopEvent);
end;
{ @end $7F70D8 }

{ @routine $7F70F0 TSoundBuffer_SetVolume }
procedure TSoundBuffer.SetVolume(Value: Single);
var Status: Integer;
    Minimum: Single;
begin
  SoundManager.Lock.Enter;
  try
    Volume := Value;
    if DirectBuffer = nil then Exit;
    Minimum := -3000;
    if Value = 0 then Status := DirectBuffer.SetVolume(DSBVOLUME_MIN)
    else Status := DirectBuffer.SetVolume(Round((0 - Minimum) * (Volume * VolumeScale) + Minimum));
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.SetVolume');
      AppendLogLineThreadSafe('volume = ' + FloatToWideString(Value) + '*' + FloatToWideString(VolumeScale));
      if Controller <> nil then AppendLogLineThreadSafe('Path=' + Controller.SoundPath)
      else AppendLogLineThreadSafe('control missing');
      raise Exception.Create(SoundErrorText(Status));
    end;
  finally
    SoundManager.Lock.Leave;
  end;
end;
{ @end $7F70F0 }

{ @routine $7F735C TSoundBuffer_SetVolumeScale }
procedure TSoundBuffer.SetVolumeScale(Value: Single);
begin
  VolumeScale := Value;
  if VolumeScale < 0 then VolumeScale := 0
  else if VolumeScale > 1 then VolumeScale := 1;
  SetVolume(Volume);
end;
{ @end $7F735C }

{ @routine $7F73C0 TSoundBuffer_StartVolumeRamp }
procedure TSoundBuffer.StartVolumeRamp(Interval: Cardinal; Step: Single);
begin
  ResetEvent(VolumeEvent);
  VolumeStep := Step;
  if VolumeTimer <> 0 then
  begin
    timeKillEvent(VolumeTimer);
    VolumeTimer := 0;
  end;
  VolumeTimer := timeSetEvent(Interval, 0, TFNTimeCallBack(VolumeEvent), 0, TIME_PERIODIC or TIME_CALLBACK_EVENT_SET);
end;
{ @end $7F73C0 }

{ @routine $7F7420 TSoundBuffer_SetPan }
procedure TSoundBuffer.SetPan(Value: Single);
var Status, Pan: Integer;
begin
  SoundManager.Lock.Enter;
  try
    if DirectBuffer = nil then Exit;
    Pan := Round(10000 * Value);
    if Pan < DSBPAN_LEFT then Pan := DSBPAN_LEFT
    else if Pan > DSBPAN_RIGHT then Pan := DSBPAN_RIGHT;
    Status := DirectBuffer.SetPan(Pan);
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      AppendLogLineThreadSafe('Error in TSoundBuffer.SetPan');
      raise Exception.Create(SoundErrorText(Status));
    end;
  finally
    SoundManager.Lock.Leave;
  end;
end;
{ @end $7F7420 }

{ @routine $7F7560 EnumerateSoundDevice }
function EnumerateSoundDevice(Guid: Pointer; Description, Module: PAnsiChar; Context: Pointer): LongBool; stdcall;
var Text: WideString;
begin
  Text := SysUtils.Format('- %s', [Description]);
  AppendLogLineThreadSafe(Text);
  if FindTextOffsetW(Text, 'Xonar') >= 0 then XonarSoundDevice := True;
  Result := True;
end;
{ @end $7F7560 }

{ @routine $7F7634 TSoundControl_Create }
constructor TSoundControl.Create;
var Status: Integer;
    Desc: TDSBufferDesc;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
  FirstBuffer := nil;
  LastBuffer := nil;
  DirectSound := nil;
  PrimaryBuffer := nil;
  if SoundEnabled or MusicEnabled then
  begin
    try
      DirectSoundEnumerateA(EnumerateSoundDevice, nil);
      Status := DirectSoundCreate(nil, DirectSound, nil);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
      begin
        SuppressExceptionLogCopy := True;
        AppendLogLineThreadSafe('Error in TSoundControl.Create 1');
        raise Exception.Create(SoundErrorText(Status));
      end;
      Status := DirectSound.SetCooperativeLevel(MainWindowHandle, DSSCL_PRIORITY);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
      begin
        SuppressExceptionLogCopy := True;
        AppendLogLineThreadSafe('Error in TSoundControl.Create 2');
        raise Exception.Create(SoundErrorText(Status));
      end;
      FillChar(Desc, SizeOf(Desc), 0);
      Desc.Size := SizeOf(Desc);
      Desc.Flags := DSBCAPS_PRIMARYBUFFER or DSBCAPS_LOCSOFTWARE;
      Status := DirectSound.CreateSoundBuffer(Desc, PrimaryBuffer, nil);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
      begin
        AppendLogLineThreadSafe('Error in TSoundControl.Create 3');
        raise Exception.Create(SoundErrorText(Status));
      end;
      FillChar(WaveFormat, SizeOf(WaveFormat), 0);
      WaveFormat.FormatTag := 1;
      WaveFormat.Channels := 2;
      WaveFormat.SamplesPerSecond := 44100;
      WaveFormat.BitsPerSample := 16;
      WaveFormat.BlockAlign := (WaveFormat.BitsPerSample shr 3) * WaveFormat.Channels;
      WaveFormat.AverageBytesPerSecond := WaveFormat.SamplesPerSecond * WaveFormat.BlockAlign;
      Status := PrimaryBuffer.SetFormat(@WaveFormat);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
      begin
        AppendLogLineThreadSafe('Error in TSoundControl.Create 4');
        raise Exception.Create(SoundErrorText(Status));
      end;
      Status := PrimaryBuffer.GetFormat(@WaveFormat, SizeOf(WaveFormat), nil);
      if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
      begin
        AppendLogLineThreadSafe('Error in TSoundControl.Create 5');
        raise Exception.Create(SoundErrorText(Status));
      end;
      if WaveFormat.FormatTag <> 1 then
        AppendLogLineThreadSafe('Sound format changed to ' + IntToStr(WaveFormat.FormatTag));
      AppendLogLineThreadSafe('Selected interface: ' + IntToWideString(WaveFormat.Channels) +
        ' channels at ' + IntToWideString(WaveFormat.SamplesPerSecond) + ' Hz, ' +
        IntToWideString(WaveFormat.BitsPerSample) + ' bit ');
      if (WaveFormat.BitsPerSample shr 3) * WaveFormat.Channels <> WaveFormat.BlockAlign then
        AppendLogLineThreadSafe('BlockAlign is ' + IntToStr(WaveFormat.BlockAlign));
      if WaveFormat.SamplesPerSecond * WaveFormat.BlockAlign <> WaveFormat.AverageBytesPerSecond then
        AppendLogLineThreadSafe('AvgBytesPerSec is ' + IntToStr(WaveFormat.AverageBytesPerSecond));
      AppendLogLineThreadSafe('Initializing sound.... ok!');
    except
      PrimaryBuffer := nil;
      DirectSound := nil;
      SoundEnabled := False;
      MusicEnabled := False;
      AppendLogLineThreadSafe('Initializing sound.... failed!');
    end;
  end;
end;
{ @end $7F7634 }

{ @routine $7F7CB4 TSoundControl_Destroy }
destructor TSoundControl.Destroy;
begin
  Clear;
  PrimaryBuffer := nil;
  DirectSound := nil;
  Lock.Free;
  inherited Destroy;
end;
{ @end $7F7CB4 }

{ @routine $7F7D10 TSoundControl_Clear }
procedure TSoundControl.Clear;
begin
  while FirstBuffer <> nil do RemoveBuffer(FirstBuffer);
end;
{ @end $7F7D10 }

{ @routine $7F7D34 TSoundControl_StopUncontrolledSounds }
procedure TSoundControl.StopUncontrolledSounds;
var NextBuffer, Buffer: TSoundBuffer;
begin
  Lock.Enter;
    NextBuffer := FirstBuffer;
    while NextBuffer <> nil do
    begin
      Buffer := NextBuffer;
      NextBuffer := NextBuffer.Next;
      if (Buffer.Controller = nil) and not Buffer.Streaming and Buffer.IsPlaying then RemoveBuffer(Buffer);
    end;
    Lock.Leave;
end;
{ @end $7F7D34 }

{ @routine $7F7DA4 TSoundControl_AddBuffer }
function TSoundControl.AddBuffer: TSoundBuffer;
var Buffer: TSoundBuffer;
begin
  Lock.Enter;
  try
    Buffer := TSoundBuffer.Create;
    if LastBuffer <> nil then LastBuffer.Next := Buffer;
    Buffer.Prev := LastBuffer;
    Buffer.Next := nil;
    LastBuffer := Buffer;
    if FirstBuffer = nil then FirstBuffer := Buffer;
  finally
    Lock.Leave;
  end;
  Result := Buffer;
end;
{ @end $7F7DA4 }

{ @routine $7F7E48 TSoundControl_RemoveBuffer }
procedure TSoundControl.RemoveBuffer(Buffer: TSoundBuffer);
begin
  Lock.Enter;
  try
    if Buffer.Prev <> nil then Buffer.Prev.Next := Buffer.Next;
    if Buffer.Next <> nil then Buffer.Next.Prev := Buffer.Prev;
    if LastBuffer = Buffer then LastBuffer := Buffer.Prev;
    if FirstBuffer = Buffer then FirstBuffer := Buffer.Next;
    Buffer.Free;
  finally
    Lock.Leave;
  end;
end;
{ @end $7F7E48 }

{ @routine $7F7EF8 TSoundControl_SuppressGroup }
function TSoundControl.SuppressGroup(Group: Integer; Volume: Single): Boolean;
var Buffer: TSoundBuffer;
begin
  Result := False;
  Lock.Enter;
  try
    Buffer := FirstBuffer;
    while Buffer <> nil do
    begin
      if Buffer.SoundGroup = Group then
      begin
        if Buffer.VolumeScale >= Volume then
        begin
          Result := True;
          Exit;
        end;
        Buffer.FadingOut := True;
        if Buffer.Controller <> nil then
        begin
          Buffer.Controller.Buffer := nil;
          Buffer.Controller.Volume := 0;
          Buffer.Controller := nil;
        end;
      end;
      Buffer := Buffer.Next;
    end;
  finally
    Lock.Leave;
  end;
end;
{ @end $7F7EF8 }

{ @routine $7F7FBC TSoundControl_RemoveFinishedBuffers }
procedure TSoundControl.RemoveFinishedBuffers;
var NextBuffer, Buffer: TSoundBuffer;
begin
  Lock.Enter;
  try
    NextBuffer := FirstBuffer;
    while NextBuffer <> nil do
    begin
      Buffer := NextBuffer;
      NextBuffer := NextBuffer.Next;
      if Buffer.AutoRelease and not Buffer.IsPlaying then RemoveBuffer(Buffer);
    end;
  finally
    Lock.Leave;
  end;
end;
{ @end $7F7FBC }

{ @routine $7F8048 TSoundControl_UpdateFades }
procedure TSoundControl.UpdateFades;
var NextBuffer, Buffer: TSoundBuffer;
    NewVolume: Single;
    Tick: Cardinal;
begin
  Tick := timeGetTime;
  if Tick - LastFadeTick < 10 then Exit;
  LastFadeTick := Tick;
  Lock.Enter;
  try
    NextBuffer := FirstBuffer;
    while NextBuffer <> nil do
    begin
      Buffer := NextBuffer;
      NextBuffer := NextBuffer.Next;
      if Buffer.FadingOut then
      begin
        NewVolume := Max(0, Buffer.VolumeScale - 0.05);
        if NewVolume > 0.05 then Buffer.SetVolumeScale(NewVolume)
        else RemoveBuffer(Buffer);
      end;
    end;
  finally
    Lock.Leave;
  end;
end;
{ @end $7F8048 }

{ @routine $7F815C TSoundControl_PlaySound }
procedure TSoundControl.PlaySound(const Path: WideString);
var Control: TCSoundControlEC;
    Sound: TCSoundEC;
    Buffer: TSoundBuffer;
begin
  if Path = '' then Exit;
  if not SoundEnabled then Exit;
  Control := nil;
  RemoveFinishedBuffers;
  try
    Control := TCSoundControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(Path);
    Sound := AcquireCachedSound(Control);
    Buffer := AddBuffer;
    Buffer.AutoRelease := True;
    Buffer.Write(Sound.SampleData, Sound.SampleDataSize, @Sound.Format);
    Buffer.SetVolume(SoundVolume);
    Buffer.SetVolumeScale(1);
    Buffer.Play(False);
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;
{ @end $7F815C }

{ @routine $7F8258 TSoundControl_PlayEffect }
function TSoundControl.PlayEffect(const Path: WideString; Group: Integer; Volume, Pan: Single): TSoundBuffer;
var Control: TCSoundControlEC;
    Sound: TCSoundEC;
    Buffer: TSoundBuffer;
begin
  Result := nil;
  if Path = '' then Exit;
  if not SoundEnabled then Exit;
  Control := nil;
  RemoveFinishedBuffers;
  if (Group <> 0) and SuppressGroup(Group, Volume) then Exit;
  try
    Control := TCSoundControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(Path);
    Sound := AcquireCachedSound(Control);
    Buffer := AddBuffer;
    Buffer.SoundGroup := Group;
    Buffer.AutoRelease := True;
    Buffer.Write(Sound.SampleData, Sound.SampleDataSize, @Sound.Format);
    Buffer.SetVolume(SoundVolume);
    Buffer.SetVolumeScale(Volume);
    Buffer.SetPan(Pan);
    Buffer.Play(False);
    Result := Buffer;
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;
{ @end $7F8258 }

{ @routine $7F8394 TSoundControl_PlayLoop }
function TSoundControl.PlayLoop(const Path: WideString; Group: Integer; Volume, Pan: Single): TSoundBuffer;
var Control: TCSoundControlEC;
    Sound: TCSoundEC;
    Buffer: TSoundBuffer;
begin
  Result := nil;
  if Path = '' then Exit;
  if not SoundEnabled then Exit;
  Control := nil;
  RemoveFinishedBuffers;
  if (Group <> 0) and SuppressGroup(Group, Volume) then Exit;
  try
    Control := TCSoundControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(Path);
    Sound := AcquireCachedSound(Control);
    Buffer := AddBuffer;
    Buffer.SoundGroup := Group;
    Buffer.AutoRelease := True;
    Buffer.Write(Sound.SampleData, Sound.SampleDataSize, @Sound.Format);
    Buffer.SetVolume(SoundVolume);
    Buffer.SetVolumeScale(Volume);
    Buffer.SetPan(Pan);
    Buffer.Play(True);
    Result := Buffer;
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;
{ @end $7F8394 }

{ @routine $7F84D0 TSoundControl_SignalStop }
procedure TSoundControl.SignalStop;
var Buffer: TSoundBuffer;
begin
  Lock.Enter;
  Buffer := FirstBuffer;
  while Buffer <> nil do
  begin
    Buffer.SignalStop;
    Buffer := Buffer.Next;
  end;
  Lock.Leave;
end;
{ @end $7F84D0 }

end.
