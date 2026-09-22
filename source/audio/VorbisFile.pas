unit VorbisFile;
// Unit bracket (inferred): .text 0x0084E5D8..0x0084ECA1; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses SyncObjs, DirectSound, EC_FileStream;

const
  // OpenVorbisStream always advertises this format, independent of file metadata.
  VorbisOutputChannels = 2;
  VorbisOutputSampleRate = 44100;
  VorbisOutputSampleBytes = SizeOf(SmallInt);
  VorbisOutputBlockAlign = VorbisOutputChannels * VorbisOutputSampleBytes;
  VorbisOutputBytesPerSecond = VorbisOutputSampleRate * VorbisOutputBlockAlign;

type
  PCriticalSection = ^TCriticalSection;
  // libvorbis owns the internal OggVorbis_File fields. The Delphi wrapper
  // embeds it at +8 and keeps the shared lock and current bitstream after it.
  TOggWorker = class(TObject) // @size $2E4
  public
    VorbisState: array[0..$2CF] of Byte; // @offset $08
    Lock: PCriticalSection; // @offset $2D8
    Bitstream: Integer; // @offset $2DC
    ExternalLibrary: Boolean; // @offset $2E0
    constructor Create(var SharedLock: TCriticalSection; UseExternalLibrary: Boolean); // @addr $84E658
    destructor Destroy; override; // @addr $84E6FC @note "Decrements the shared use count without unloading or clearing the decoder."

  end;
  // libvorbisfile C ABI: https://github.com/xiph/vorbis/blob/master/include/vorbis/vorbisfile.h
  TVorbisReadCallback = function(Buffer: Pointer; Size, Count: Cardinal; Source: Pointer): Cardinal; cdecl;
  TVorbisSeekCallback = function(Source: Pointer; Offset: Int64; Origin: Integer): Integer; cdecl;
  TVorbisCloseCallback = function(Source: Pointer): Integer; cdecl;
  TVorbisTellCallback = function(Source: Pointer): Integer; cdecl;
  TVorbisCallbacks = record // @size $10
    Read: TVorbisReadCallback; // @offset $0
    Seek: TVorbisSeekCallback; // @offset $4
    Close: TVorbisCloseCallback; // @offset $8
    Tell: TVorbisTellCallback; // @offset $C
  end;
  TVorbisFileStatus = function(State: Pointer): Integer; cdecl;
  TVorbisFOpen = function(Path: PAnsiChar; State: Pointer): Integer; cdecl;
  TVorbisOpenCallbacks = function(Source, State: Pointer; Initial: PAnsiChar; InitialBytes: Integer; Callbacks: TVorbisCallbacks): Integer; cdecl;
  TVorbisLinkStatus = function(State: Pointer; Link: Integer): Integer; cdecl;
  TVorbisLinkCount = function(State: Pointer; Link: Integer): Int64; cdecl;
  TVorbisLinkTime = function(State: Pointer; Link: Integer): Double; cdecl;
  TVorbisSeekOffset = function(State: Pointer; Offset: Int64): Integer; cdecl;
  TVorbisSeekTime = function(State: Pointer; Seconds: Double): Integer; cdecl;
  TVorbisTellOffset = function(State: Pointer): Int64; cdecl;
  TVorbisTellTime = function(State: Pointer): Double; cdecl;
  TVorbisLinkInfo = function(State: Pointer; Link: Integer): Pointer; cdecl;
  TVorbisReadFloat = function(State: Pointer; var Channels: Pointer; Samples: Integer; var Bitstream: Integer): Integer; cdecl;
  TVorbisRead = function(State, Buffer: Pointer; Length, BigEndian, WordSize, SignedSamples: Integer; var Bitstream: Integer): Integer; cdecl;

var
  VorbisLoaded: Boolean = False; // @addr $882728
  VorbisClear: TVorbisFileStatus; // @addr $88C3B0
  VorbisFOpen: TVorbisFOpen; // @addr $88C3B4
  VorbisOpenCallbacks: TVorbisOpenCallbacks; // @addr $88C3B8
  VorbisTestCallbacks: TVorbisOpenCallbacks; // @addr $88C3BC
  VorbisTestOpen: TVorbisFileStatus; // @addr $88C3C0
  VorbisBitrate: TVorbisLinkStatus; // @addr $88C3C4
  VorbisBitrateInstant: TVorbisFileStatus; // @addr $88C3C8
  VorbisStreams: TVorbisFileStatus; // @addr $88C3CC
  VorbisSeekable: TVorbisFileStatus; // @addr $88C3D0
  VorbisSerialNumber: TVorbisLinkStatus; // @addr $88C3D4
  VorbisRawTotal: TVorbisLinkCount; // @addr $88C3D8
  VorbisPcmTotal: TVorbisLinkCount; // @addr $88C3DC
  VorbisTimeTotal: TVorbisLinkTime; // @addr $88C3E0
  VorbisRawSeek: TVorbisSeekOffset; // @addr $88C3E4
  VorbisPcmSeek: TVorbisSeekOffset; // @addr $88C3E8
  VorbisPcmSeekPage: TVorbisSeekOffset; // @addr $88C3EC
  VorbisTimeSeek: TVorbisSeekTime; // @addr $88C3F0
  VorbisTimeSeekPage: TVorbisSeekTime; // @addr $88C3F4
  VorbisRawTell: TVorbisTellOffset; // @addr $88C3F8
  VorbisPcmTell: TVorbisTellOffset; // @addr $88C3FC
  VorbisTimeTell: TVorbisTellTime; // @addr $88C400
  VorbisInfo: TVorbisLinkInfo; // @addr $88C404
  VorbisComment: TVorbisLinkInfo; // @addr $88C408
  VorbisReadFloat: TVorbisReadFloat; // @addr $88C40C
  VorbisRead: TVorbisRead; // @addr $88C410

  VorbisUseCount: Integer; // @addr $88C414
  VorbisCallbacks: TVorbisCallbacks; // @addr $88C418
  VorbisLibrary: Cardinal; // @addr $88C428

procedure LoadVorbisLibrary; // @addr $84E99C
function ReadVorbisSource(Buffer: Pointer; Size, Count: Cardinal; Source: Pointer): Cardinal; cdecl; // @addr $84E630 @note "Returns bytes read, rather than fread's element count."
function OpenVorbisStream(Decoder: TOggWorker; var Format: TSoundWaveFormat; var Stream: TFileStreamEC): Integer; stdcall; // @addr $84E768 @note "Always advertises stereo 44100-Hz signed 16-bit PCM; raises if ov_open_callbacks fails."

function ReadVorbisSamples(Decoder: TOggWorker; Buffer: Pointer; var ByteCount: Integer): Integer; stdcall; // @addr $84E880

implementation

uses EC_Mem, GR_Main, SysUtils, Windows, MMSystem;

const
  // libvorbis codec.h status codes returned by ov_read.
  OV_HOLE = -3;
  OV_EINVAL = -131;
  OV_EBADLINK = -137;
  VorbisLittleEndian = 0;
  VorbisSignedSamples = 1;
  VorbisScratchBytes = 4096;

{ @routine $84E630 ReadVorbisSource }
function ReadVorbisSource(Buffer: Pointer; Size, Count: Cardinal; Source: Pointer): Cardinal; cdecl;
var Stream: TFileStreamEC;
begin
  Stream := Source;
  Result := Stream.Read(Buffer, Size * Count);
end;
{ @end $84E630 }

{ @routine $84E658 TOggWorker_Create }
constructor TOggWorker.Create(var SharedLock: TCriticalSection; UseExternalLibrary: Boolean);
begin
  inherited Create;
  Lock := @SharedLock;
  if not UseExternalLibrary then
  begin
    Lock^.Enter;
    if not VorbisLoaded then begin VorbisUseCount := 1; LoadVorbisLibrary; end
    else Inc(VorbisUseCount);
    Lock^.Leave;
  end;
  ExternalLibrary := UseExternalLibrary;
end;
{ @end $84E658 }

{ @routine $84E6FC TOggWorker_Destroy }
destructor TOggWorker.Destroy;
begin
  if not ExternalLibrary then
  begin
    Lock^.Enter;
    Dec(VorbisUseCount);
    // The native routine still compares the count, but has no unload body.
    if VorbisUseCount = 0 then begin end;
    Lock^.Leave;
  end;
  inherited Destroy;
end;
{ @end $84E6FC }

{ @routine $84E768 OpenVorbisStream }
function OpenVorbisStream(Decoder: TOggWorker; var Format: TSoundWaveFormat; var Stream: TFileStreamEC): Integer; stdcall;
begin
  Format.FormatTag := WAVE_FORMAT_PCM;
  Format.Channels := VorbisOutputChannels;
  Format.BitsPerSample := VorbisOutputSampleBytes * 8;
  Format.ExtraSize := 0;
  Format.SamplesPerSecond := VorbisOutputSampleRate;
  Format.BlockAlign := VorbisOutputBlockAlign;
  Format.AverageBytesPerSecond := VorbisOutputBytesPerSecond;
  Decoder.Bitstream := 0;
  Decoder.Lock^.Enter;
  Result := VorbisOpenCallbacks(Stream, @Decoder.VorbisState, nil, 0, VorbisCallbacks);
  Decoder.Lock^.Leave;
  if Result <> 0 then raise Exception.Create('Error open audiofile.')
  else Result := 1;
end;
{ @end $84E768 }

{ @routine $84E880 ReadVorbisSamples }
function ReadVorbisSamples(Decoder: TOggWorker; Buffer: Pointer; var ByteCount: Integer): Integer; stdcall;
var Total, Count, Remaining: Integer;
    Temp: array of AnsiChar;
    Done: Boolean;
begin
  SetLength(Temp, VorbisScratchBytes);
  Total := 0;
  Remaining := ByteCount;
  Done := False;
  Decoder.Lock^.Enter;
  while not Done do
  begin
    Count := VorbisRead(@Decoder.VorbisState, Pointer(Temp), Remaining, VorbisLittleEndian, VorbisOutputSampleBytes, VorbisSignedSamples, Decoder.Bitstream);
    if Count = OV_EBADLINK then Break;
    if Count = OV_HOLE then Break;
    if Count = OV_EINVAL then Break;
    if Count = 0 then Break;
    CopyMemory(AddPointerOffset(Buffer, Total), @Temp[0], Count);
    Inc(Total, Count);
    Dec(Remaining, Count);
    if Remaining = 0 then Break;
  end;
  Decoder.Lock^.Leave;
  ByteCount := Total;
  Result := Total;
end;
{ @end $84E880 }

{ @routine $84E99C LoadVorbisLibrary }
procedure LoadVorbisLibrary;
begin
  AppendLogTextThreadSafe('Loading libvorbisfile.dll....');
  VorbisLibrary := Windows.LoadLibrary('libvorbisfile.dll');
  if VorbisLibrary <> 0 then
  begin
    AppendLogLineThreadSafe('ok!');
    VorbisLoaded := True;
    @VorbisClear := GetProcAddress(VorbisLibrary, 'ov_clear');
    @VorbisFOpen := GetProcAddress(VorbisLibrary, 'ov_fopen');
    @VorbisOpenCallbacks := GetProcAddress(VorbisLibrary, 'ov_open_callbacks');
    @VorbisTestCallbacks := GetProcAddress(VorbisLibrary, 'ov_test_callbacks');
    @VorbisTestOpen := GetProcAddress(VorbisLibrary, 'ov_test_open');
    @VorbisBitrate := GetProcAddress(VorbisLibrary, 'ov_bitrate');
    @VorbisBitrateInstant := GetProcAddress(VorbisLibrary, 'ov_bitrate_instant');
    @VorbisStreams := GetProcAddress(VorbisLibrary, 'ov_streams');
    @VorbisSeekable := GetProcAddress(VorbisLibrary, 'ov_seekable');
    @VorbisSerialNumber := GetProcAddress(VorbisLibrary, 'ov_serialnumber');
    @VorbisRawTotal := GetProcAddress(VorbisLibrary, 'ov_raw_total');
    @VorbisPcmTotal := GetProcAddress(VorbisLibrary, 'ov_pcm_total');
    @VorbisTimeTotal := GetProcAddress(VorbisLibrary, 'ov_time_total');
    @VorbisRawSeek := GetProcAddress(VorbisLibrary, 'ov_raw_seek');
    @VorbisPcmSeek := GetProcAddress(VorbisLibrary, 'ov_pcm_seek');
    @VorbisPcmSeekPage := GetProcAddress(VorbisLibrary, 'ov_pcm_seek_page');
    @VorbisTimeSeek := GetProcAddress(VorbisLibrary, 'ov_time_seek');
    @VorbisTimeSeekPage := GetProcAddress(VorbisLibrary, 'ov_time_seek_page');
    @VorbisRawTell := GetProcAddress(VorbisLibrary, 'ov_raw_tell');
    @VorbisPcmTell := GetProcAddress(VorbisLibrary, 'ov_pcm_tell');
    @VorbisTimeTell := GetProcAddress(VorbisLibrary, 'ov_time_tell');
    @VorbisInfo := GetProcAddress(VorbisLibrary, 'ov_info');
    @VorbisComment := GetProcAddress(VorbisLibrary, 'ov_comment');
    @VorbisReadFloat := GetProcAddress(VorbisLibrary, 'ov_read_float');
    @VorbisRead := GetProcAddress(VorbisLibrary, 'ov_read');
  end
  else
  begin
    AppendLogTextThreadSafe('FAIL');
    AppendLogLineThreadSafe(' GetLastError=' + IntToStr(Int64(GetLastError)));
    raise Exception.Create('Error load=libvorbisfile.dll ' + SysErrorMessage(GetLastError));
  end;
  VorbisCallbacks.Read := ReadVorbisSource;
  VorbisCallbacks.Seek := nil; VorbisCallbacks.Tell := nil; VorbisCallbacks.Close := nil;
end;
{ @end $84E99C }

end.
