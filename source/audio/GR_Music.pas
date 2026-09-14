unit GR_Music;
// Unit bracket (inferred): .text 0x007F8C28..0x007FA061; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Thread, EC_FileStream, VorbisFile, GR_Sound, SyncObjs;

type
  TMusicUnit = class(TThreadEC) // @size $54
  public
    Decoder: TOggWorker; // @offset $2C
    BuiltinVorbis: Boolean; // @offset $30
    RequestedFileName: WideString; // @offset $34
    ImmediateStop: Boolean; // @offset $38
    Buffer: TSoundBuffer; // @offset $3C
    DecodeLock: TCriticalSection; // @offset $40
    DecoderLibrary: Cardinal; // @offset $44
    Stream: TFileStreamEC; // @offset $48
    StartPlaybackEvent: Cardinal; // @offset $4C
    CompletionEvent: Cardinal; // @offset $50
    constructor Create(LibraryName: PWideChar); // @addr $7F8D10 @ida "TMusicUnit *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int16 *LibraryName@<ecx>);"
    destructor Destroy; override; // @addr $7F9048 @ida "void __usercall $name(TMusicUnit *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr $7F90F4
    procedure LoadFile(const FileName: WideString; Deferred: Boolean); // @addr $7F9160
    function GetFileName: WideString; // @addr $7F9290 @ida "void __usercall $name(TMusicUnit *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function IsIntroTrack: Boolean; // @addr $7F92F0
    procedure Execute; override; // @addr $7F93F4
  end;
  TMusicControl = class(TThreadEC) // @size $48
  public
    CompletionEvent: Cardinal; // @offset $2C
    ControlLock: TCriticalSection; // @offset $30
    Current: TMusicUnit; // @offset $34
    Queued: TMusicUnit; // @offset $38
    CurrentFileName: WideString; // @offset $40
    CategoryOverride: WideString; // @offset $44
    constructor Create; // @addr $7F9638 @ida "TMusicControl *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $7F97AC @ida "void __usercall $name(TMusicControl *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr $7F9854
    procedure Execute; override; // @addr $7F9928
    procedure PlayFile(const FileName: WideString); // @addr $7F9A34
    procedure PlayCategory(const Category: WideString); // @addr $7F9B0C
    procedure RequestFadeOut; // @addr $7F9C6C
    procedure StopImmediately; // @addr $7F9C9C
    function HasSelectedMusic: Boolean; // @addr $7F9CD4
    function IsPlaying: Boolean; // @addr $7F9D94
  end;

function ChooseMusicFile(const Category, CurrentFile: WideString): WideString; // @addr $7F9E34 @ida "void __usercall $name(unsigned __int16 *Category@<eax>, unsigned __int16 *CurrentFile@<edx>, unsigned __int16 **Result@<ecx>);"

implementation

uses Windows, SysUtils, DirectSound, EC_Str, EC_BlockPar, GR_Main;

const
  MusicChunkBytes = 2 * VorbisOutputBytesPerSecond;
  MusicEndFadeThresholdBytes = $C800;

{ @routine $7F8D10 TMusicUnit_Create }
constructor TMusicUnit.Create(LibraryName: PWideChar);
begin
  inherited Create;
  Buffer := nil;
  DecodeLock := nil;
  BuiltinVorbis := False;
  DecodeLock := TCriticalSection.Create;
  if AnsiString(LibraryName) = 'vorbisfile.dll' then
  begin
    Decoder := TOggWorker.Create(@DecodeLock, False);
    BuiltinVorbis := True;
    Buffer := SoundManager.AddBuffer;
  end
  else
  begin
    Decoder := TOggWorker.Create(@DecodeLock, True);
    if not BuiltinVorbis then
    begin
      AppendLogTextThreadSafe('Load ' + AnsiString(LibraryName) + ' .... ');
      try
        DecoderLibrary := LoadLibraryW(LibraryName);
      except
        AppendLogLineThreadSafe('fail');
        raise;
      end;
      if DecoderLibrary = 0 then
      begin
        AppendLogLineThreadSafe(AnsiString('fail GetLastError=' + IntToWideString(GetLastError)));
        raise Exception.Create(AnsiString(WideString('Error load=' + AnsiString(LibraryName) + '  GetLastError=') + IntToWideString(GetLastError)));
      end;
      AppendLogLineThreadSafe('ok');
    end;
    Buffer := SoundManager.AddBuffer;
  end;
end;
{ @end $7F8D10 }

{ @routine $7F9048 TMusicUnit_Destroy }
destructor TMusicUnit.Destroy;
begin
  if IsRunning then
  begin
    RequestStop;
    if StartPlaybackEvent <> 0 then SetEvent(StartPlaybackEvent);
    WaitForIdle(INFINITE);
  end;
  Clear;
  if Buffer <> nil then
  begin
    SoundManager.RemoveBuffer(Buffer);
    Buffer := nil;
  end;
  if DecodeLock <> nil then
  begin
    DecodeLock.Free;
    DecodeLock := nil;
  end;
  // The native destructor leaves Decoder and DecoderLibrary allocated.
  inherited Destroy;
end;
{ @end $7F9048 }

{ @routine $7F90F4 TMusicUnit_Clear }
procedure TMusicUnit.Clear;
begin
  ImmediateStop := False;
  Buffer.Clear;
  if StartPlaybackEvent <> 0 then
  begin
    CloseHandle(StartPlaybackEvent);
    StartPlaybackEvent := 0;
  end;
  DecodeLock.Enter;
  if Stream <> nil then
  begin
    Stream.Free;
    Stream := nil;
  end;
  DecodeLock.Leave;
end;
{ @end $7F90F4 }

{ @routine $7F9160 TMusicUnit_LoadFile }
procedure TMusicUnit.LoadFile(const FileName: WideString; Deferred: Boolean);
begin
  if GetFileName <> FileName then
  begin
    RequestedFileName := FileName;
    if IsRunning then
    begin
      RequestStop;
      if StartPlaybackEvent <> 0 then SetEvent(StartPlaybackEvent);
      WaitForIdle(INFINITE);
    end;
    Clear;
    Stream := TFileStreamEC.Create($400FF, FileName);
    if Deferred then
    begin
      SetPriority(ThreadPriorityLowest);
      StartPlaybackEvent := CreateEvent(nil, False, False, nil);
      if StartPlaybackEvent = 0 then raise Exception.Create('CreateEvent');
    end
    else SetPriority(ThreadPriorityAboveNormal);
    Start;
  end;
end;
{ @end $7F9160 }

{ @routine $7F9290 TMusicUnit_GetFileName }
function TMusicUnit.GetFileName: WideString;
begin
  if not IsRunning then Result := '';
  DecodeLock.Enter;
  if Stream = nil then Result := ''
  else Result := Stream.SourceFile.GetFileName;
  DecodeLock.Leave;
end;
{ @end $7F9290 }

{ @routine $7F92F0 TMusicUnit_IsIntroTrack }
function TMusicUnit.IsIntroTrack: Boolean;
begin
  Result := (GetFileName = 'music\1c.dat') or
    (GetFileName = 'music\logo.dat') or (GetFileName = 'music\intro.dat');
end;
{ @end $7F92F0 }

{ @routine $7F93F4 TMusicUnit_Execute }
procedure TMusicUnit.Execute;
var
  Ended: Boolean;
  Format: TSoundWaveFormat;
  Chunk: Integer;
begin
  if OpenVorbisStream(Decoder, Format, Stream) = 0 then
  begin
    Clear;
    SetEvent(CompletionEvent);
    Exit;
  end;
  try
    Buffer.InitStream(MusicChunkBytes, @Format);
    if not Buffer.WriteStream(SoundStreamPrimeAll, Decoder) then
    begin
      Clear;
      SetEvent(CompletionEvent);
      Exit;
    end;
    if StartPlaybackEvent <> 0 then
    begin
      WaitForSingleObject(StartPlaybackEvent, INFINITE);
      if IsStopRequested then
      begin
        Clear;
        SetEvent(CompletionEvent);
        Exit;
      end;
      SetPriority(ThreadPriorityAboveNormal);
      SysUtils.Sleep(100);
      SysUtils.Sleep(100);
    end;
    Ended := False;
    if IsIntroTrack then Buffer.SetVolumeScale(1)
    else Buffer.SetVolumeScale(0);
    if not IsIntroTrack then Buffer.StartVolumeRamp(100, 0.1);
    Buffer.Play(False);
    repeat
      Chunk := Buffer.WaitForChunk;
    until Chunk <> 0;
    while not Ended do
    begin
      if ImmediateStop then Break;
      if IsStopRequested then
      begin
        SetStopRequested(False);
        if not IsIntroTrack then Buffer.StartVolumeRamp(100, -0.1);
      end;
      Ended := not Buffer.WriteStream(Chunk, Decoder);
      if Stream.EndOfFile then
        if Stream.FillAvailable + Stream.ReadAvailable <= MusicEndFadeThresholdBytes then RequestStop;
      Chunk := Buffer.WaitForChunk;
      if Chunk < 0 then Break;
    end;
  except
  end;
  Clear;
  SetEvent(CompletionEvent);
end;
{ @end $7F93F4 }

{ @routine $7F9638 TMusicControl_Create }
constructor TMusicControl.Create;
begin
  inherited Create;
  Current := nil;
  Queued := nil;
  ControlLock := TCriticalSection.Create;
  if MusicEnabled then
  begin
    if MusicEnabled then
    begin
      Current := TMusicUnit.Create('vorbisfile.dll');
      Queued := TMusicUnit.Create('vorbisfile.dll');
      // Native order: Current receives the still-zero handle before creation.
      Current.CompletionEvent := CompletionEvent;
      Queued.CompletionEvent := 0;
    end;
    SetPriority(ThreadPriorityAboveNormal);
    CompletionEvent := CreateEvent(nil, False, False, nil);
    if CompletionEvent = 0 then raise Exception.Create('CreateEvent');
    if MusicEnabled then Start;
    AppendLogLineThreadSafe('Pre-fetching music.... ok!');
  end;
end;
{ @end $7F9638 }

{ @routine $7F97AC TMusicControl_Destroy }
destructor TMusicControl.Destroy;
begin
  RequestStop;
  if CompletionEvent <> 0 then SetEvent(CompletionEvent);
  if IsRunning then WaitForIdle(INFINITE);
  Clear;
  if CompletionEvent <> 0 then
  begin
    CloseHandle(CompletionEvent);
    CompletionEvent := 0;
  end;
  if ControlLock <> nil then
  begin
    ControlLock.Free;
    ControlLock := nil;
  end;
  inherited Destroy;
end;
{ @end $7F97AC }

{ @routine $7F9854 TMusicControl_Clear }
procedure TMusicControl.Clear;
begin
  if Current <> nil then
  begin
    Current.RequestStop;
    SetEvent(Current.StartPlaybackEvent);
  end;
  if Queued <> nil then
  begin
    Queued.RequestStop;
    SetEvent(Queued.StartPlaybackEvent);
  end;
  if Current <> nil then
    if Current.IsRunning then Current.WaitForIdle(INFINITE);
  if Queued <> nil then
    if Queued.IsRunning then Queued.WaitForIdle(INFINITE);
  if Current <> nil then
  begin
    Current.Free;
    Current := nil;
  end;
  if Queued <> nil then
  begin
    Queued.Free;
    Queued := nil;
  end;
end;
{ @end $7F9854 }

{ @routine $7F9928 TMusicControl_Execute }
procedure TMusicControl.Execute;
var Previous: TMusicUnit;
begin
  while not IsStopRequested do
  begin
    WaitForSingleObject(CompletionEvent, INFINITE);
    if IsStopRequested then Break;
    SysUtils.Sleep(10);
    ControlLock.Enter;
    if Queued.IsRunning then
    begin
      Previous := Current;
      Current := Queued;
      Queued := Previous;
      CurrentFileName := Current.GetFileName;
      Current.CompletionEvent := CompletionEvent;
      Queued.CompletionEvent := 0;
      if Current.StartPlaybackEvent <> 0 then SetEvent(Current.StartPlaybackEvent);
    end;
    ControlLock.Leave;
  end;
end;
{ @end $7F9928 }

{ @routine $7F9A34 TMusicControl_PlayFile }
procedure TMusicControl.PlayFile(const FileName: WideString);
begin
  if not MusicEnabled then Exit;
  if FileName = '' then Exit;
  ControlLock.Enter;
  try
    if Queued.IsRunning then
    begin
      Queued.RequestStop;
      SetEvent(Queued.StartPlaybackEvent);
      Queued.WaitForIdle(INFINITE);
    end;
    Queued.LoadFile(FileName, True);
    if Current.IsRunning then Current.RequestStop
    else SetEvent(CompletionEvent);
  finally
    ControlLock.Leave;
  end;
end;
{ @end $7F9A34 }

{ @routine $7F9B0C TMusicControl_PlayCategory }
procedure TMusicControl.PlayCategory(const Category: WideString);
var
  Attempts: Integer;
  Chosen: WideString;
begin
  if MusicEnabled then
  begin
    ControlLock.Enter;
    try
      if CategoryOverride = '' then
      begin
        Chosen := ChooseMusicFile(Category, Current.GetFileName);
        if (Chosen <> '') and (Chosen = CurrentFileName) then
          Chosen := ChooseMusicFile('All', Current.GetFileName);
      end
      else
      begin
        Attempts := 0;
        repeat
          Chosen := ChooseMusicFile(CategoryOverride, Current.GetFileName);
          Inc(Attempts);
          if Attempts > 20 then Break;
        until (Chosen = '') or (Chosen <> CurrentFileName);
      end;
      if Chosen <> '' then PlayFile(Chosen);
    finally
      ControlLock.Leave;
    end;
  end;
end;
{ @end $7F9B0C }

{ @routine $7F9C6C TMusicControl_RequestFadeOut }
procedure TMusicControl.RequestFadeOut;
begin
  if MusicEnabled and Current.IsRunning then Current.RequestStop;
end;
{ @end $7F9C6C }

{ @routine $7F9C9C TMusicControl_StopImmediately }
procedure TMusicControl.StopImmediately;
begin
  if MusicEnabled and Current.IsRunning then
  begin
    Current.RequestStop;
    Current.ImmediateStop := True;
  end;
end;
{ @end $7F9C9C }

{ @routine $7F9CD4 TMusicControl_HasSelectedMusic }
function TMusicControl.HasSelectedMusic: Boolean;
begin
  ControlLock.Enter;
  try
    Result := (Current.GetFileName <> '') or (Queued.GetFileName <> '');
  finally
    ControlLock.Leave;
  end;
end;
{ @end $7F9CD4 }

{ @routine $7F9D94 TMusicControl_IsPlaying }
function TMusicControl.IsPlaying: Boolean;
begin
  ControlLock.Enter;
  try
    Result := ((Current <> nil) and (Current.Buffer <> nil) and Current.Buffer.IsPlaying) or
      ((Queued <> nil) and (Queued.Buffer <> nil) and Queued.Buffer.IsPlaying);
  finally
    ControlLock.Leave;
  end;
end;
{ @end $7F9D94 }

{ @routine $7F9E34 ChooseMusicFile }
function ChooseMusicFile(const Category, CurrentFile: WideString): WideString;
var
  Block: TBlockParEC;
  Count, Index, Weight: Integer;
begin
  try
    Block := MainDataConfig.GetBlockByPath('Music.' + Category);
    Count := Block.GetParamCount;
    for Index := 0 to Count - 1 do
      if (Block.GetParamValue(Index) <> '') and
        (TrimWideString(LowerCaseWideString(Block.GetParamValue(Index))) = CurrentFile) then
      begin
        Result := '';
        Exit;
      end;
    Weight := 0;
    for Index := 0 to Count - 1 do
      if Block.GetParamValue(Index) <> '' then
        Inc(Weight, ExtractDigitsToIntW(Block.GetParamName(Index)));
    Weight := Random(Weight);
    for Index := 0 to Count - 1 do
      if Block.GetParamValue(Index) <> '' then
      begin
        Dec(Weight, ExtractDigitsToIntW(Block.GetParamName(Index)));
        if Weight < 0 then
        begin
          Result := TrimWideString(LowerCaseWideString(Block.GetParamValue(Index)));
          AppendLogLineThreadSafe(AnsiString(Result));
          Exit;
        end;
      end;
  except
    Result := '';
  end;
end;
{ @end $7F9E34 }

end.
