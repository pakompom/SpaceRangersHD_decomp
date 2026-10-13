unit VorbisFile;

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
    constructor Create(var SharedLock: TCriticalSection; UseExternalLibrary: Boolean); // @addr $4C6AD4
    destructor Destroy; override; // @addr $4C6B64 @note "Decrements the shared use count without unloading or clearing the decoder."

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
  VorbisLoaded: Boolean = False; // @addr $80B718
  VorbisClear: TVorbisFileStatus; // @addr $819EB8
  VorbisFOpen: TVorbisFOpen; // @addr $819EBC
  VorbisOpenCallbacks: TVorbisOpenCallbacks; // @addr $819EC0
  VorbisTestCallbacks: TVorbisOpenCallbacks; // @addr $819EC4
  VorbisTestOpen: TVorbisFileStatus; // @addr $819EC8
  VorbisBitrate: TVorbisLinkStatus; // @addr $819ECC
  VorbisBitrateInstant: TVorbisFileStatus; // @addr $819ED0
  VorbisStreams: TVorbisFileStatus; // @addr $819ED4
  VorbisSeekable: TVorbisFileStatus; // @addr $819ED8
  VorbisSerialNumber: TVorbisLinkStatus; // @addr $819EDC
  VorbisRawTotal: TVorbisLinkCount; // @addr $819EE0
  VorbisPcmTotal: TVorbisLinkCount; // @addr $819EE4
  VorbisTimeTotal: TVorbisLinkTime; // @addr $819EE8
  VorbisRawSeek: TVorbisSeekOffset; // @addr $819EEC
  VorbisPcmSeek: TVorbisSeekOffset; // @addr $819EF0
  VorbisPcmSeekPage: TVorbisSeekOffset; // @addr $819EF4
  VorbisTimeSeek: TVorbisSeekTime; // @addr $819EF8
  VorbisTimeSeekPage: TVorbisSeekTime; // @addr $819EFC
  VorbisRawTell: TVorbisTellOffset; // @addr $819F00
  VorbisPcmTell: TVorbisTellOffset; // @addr $819F04
  VorbisTimeTell: TVorbisTellTime; // @addr $819F08
  VorbisInfo: TVorbisLinkInfo; // @addr $819F0C
  VorbisComment: TVorbisLinkInfo; // @addr $819F10
  VorbisReadFloat: TVorbisReadFloat; // @addr $819F14
  VorbisRead: TVorbisRead; // @addr $819F18

  VorbisUseCount: Integer; // @addr $819F1C
  VorbisCallbacks: TVorbisCallbacks; // @addr $819F20
  VorbisLibrary: Cardinal; // @addr $819F30

procedure LoadVorbisLibrary; // @addr $4C6DB4
function ReadVorbisSource(Buffer: Pointer; Size, Count: Cardinal; Source: Pointer): Cardinal; cdecl; // @addr $4C6ABC @note "Returns bytes read, rather than fread's element count."
function OpenVorbisStream(Decoder: TOggWorker; var Format: TSoundWaveFormat; var Stream: TFileStreamEC): Integer; stdcall; // @addr $4C6BBC @note "Always advertises stereo 44100-Hz signed 16-bit PCM; raises if ov_open_callbacks fails."

function ReadVorbisSamples(Decoder: TOggWorker; Buffer: Pointer; var ByteCount: Integer): Integer; stdcall; // @addr $4C6CB4

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

{ @routine $4C6ABC ReadVorbisSource }
function ReadVorbisSource(Buffer: Pointer; Size, Count: Cardinal; Source: Pointer): Cardinal; cdecl;
var Stream: TFileStreamEC;
begin
  Stream := Source;
  Result := Stream.Read(Buffer, Size * Count);
end;
{ @end $4C6ABC }

{ @routine $4C6AD4 TOggWorker_Create }
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
{ @end $4C6AD4 }

{ @routine $4C6B64 TOggWorker_Destroy }
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
{ @end $4C6B64 }

{ @routine $4C6BBC OpenVorbisStream }
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
{ @end $4C6BBC }

{ @routine $4C6CB4 ReadVorbisSamples }
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
    Count := VorbisRead(@Decoder.VorbisState, @Temp[0], Remaining, VorbisLittleEndian, VorbisOutputSampleBytes, VorbisSignedSamples, Decoder.Bitstream);
    if (Count <> OV_EBADLINK) and (Count <> OV_HOLE) and (Count <> OV_EINVAL) and (Count <> 0) then
    begin
      CopyMemory(AddPointerOffset(Buffer, Total), @Temp[0], Count);
      Inc(Total, Count);
      Dec(Remaining, Count);
    end
    else Break;
    if Remaining = 0 then Break;
  end;
  Decoder.Lock^.Leave;
  ByteCount := Total;
  Result := Total;
end;
{ @end $4C6CB4 }

{ @routine $4C6DB4 LoadVorbisLibrary }
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
{ @end $4C6DB4 }

end.
