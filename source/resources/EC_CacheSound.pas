unit EC_CacheSound;

interface

uses Classes, DirectSound, EC_Buf, EC_Cache;

type
  TWaveFileHeader = packed record // @size 0x2C
    // Fixed PCM header view. LoadFromConfigBuffer scans for data if it is not at $24.
    RiffId: Cardinal; // @offset 0x00 'RIFF'.
    RiffSize: Cardinal; // @offset 0x04 File size minus eight.
    WaveId: Cardinal; // @offset 0x08 'WAVE'.
    FormatId: Cardinal; // @offset 0x0C 'fmt '.
    FormatSize: Cardinal; // @offset 0x10
    FormatTag: Word; // @offset 0x14 Reader forces PCM without consulting this field.
    Channels: Word; // @offset 0x16
    SamplesPerSecond: Cardinal; // @offset 0x18
    AverageBytesPerSecond: Cardinal; // @offset 0x1C Reader recomputes this from block alignment and sample rate.
    BlockAlign: Word; // @offset 0x20
    BitsPerSample: Word; // @offset 0x22
    DataId: Cardinal; // @offset 0x24
    DataSize: Cardinal; // @offset 0x28
  end;

  TCSoundControlEC = class;
  TCSoundEC = class;

  TCSoundControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x004C6850 @slot 0x08
    function CreateData: TCacheDataEC; override; // @addr 0x004C68BC @slot 0x0C
    function AcquireData: TCacheDataEC; override; // @addr 0x004C68EC @slot 0x10
  end;

  TCSoundEC = class(TCacheDataEC) // @size 0x3C
  public
    // Playback copies the aligned 20-byte format, including its two-byte tail.
    Format: TSoundWaveFormat; // @offset 0x20
    SampleData: Pointer; // @offset 0x34
    SampleDataSize: Cardinal; // @offset 0x38

    constructor Create; // @addr 0x004C68F4
    destructor Destroy; override; // @addr 0x004C692C
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x004C6964 @slot 0x00 @note "Reads 44 bytes from the current position. Forces PCM without validating RIFF, WAVE or fmt identifiers. If data is absent at header offset 36, scans the whole buffer byte by byte for it. Ignores LoadOption."
  end;

function AcquireCachedSound(Control: TCacheControlEC): TCSoundEC; // @addr 0x004C68CC

implementation

uses EC_Mem, GR_Main, MMSystem;

const
  WaveDataChunkId = $61746164; // little-endian 'data'
  WaveChunkHeaderSize = 2 * SizeOf(Cardinal);

{ @routine $4C6850 TCSoundControlEC_QueueLoadIfMissing }
procedure TCSoundControlEC.QueueLoadIfMissing(PendingLoads: TList);
var
  Control: TCSoundControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCSoundEC) <> nil then Exit;
  Control := TCSoundControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $4C6850 }

{ @routine $4C68BC TCSoundControlEC_CreateData }
function TCSoundControlEC.CreateData: TCacheDataEC;
begin
  Result := TCSoundEC.Create;
end;
{ @end $4C68BC }

{ @routine $4C68CC AcquireCachedSound }
function AcquireCachedSound(Control: TCacheControlEC): TCSoundEC;
begin
  Result := Control.AcquireDataFromConfig(TCSoundEC) as TCSoundEC;
end;
{ @end $4C68CC }

{ @routine $4C68EC TCSoundControlEC_AcquireData }
function TCSoundControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedSound(Self);
end;
{ @end $4C68EC }

{ @routine $4C68F4 TCSoundEC_Create }
constructor TCSoundEC.Create;
begin
  inherited Create;
end;
{ @end $4C68F4 }

{ @routine $4C692C TCSoundEC_Destroy }
destructor TCSoundEC.Destroy;
begin
  if SampleData <> nil then
  begin
    FreeEC(SampleData);
    SampleData := nil;
  end;
  inherited Destroy;
end;
{ @end $4C692C }

{ @routine $4C6964 TCSoundEC_LoadFromConfigBuffer }
procedure TCSoundEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
var
  Offset: Integer;
  Header: TWaveFileHeader;
begin
  SourceBuffer.ReadBytes(@Header, SizeOf(Header));
  if Header.DataId <> WaveDataChunkId then
  begin
    Offset := 0;
    while SourceBuffer.DataSize - WaveChunkHeaderSize > Offset do
    begin
      if SourceBuffer.GetUInt32At(Offset) = WaveDataChunkId then Break;
      Inc(Offset);
    end;
    if SourceBuffer.DataSize - WaveChunkHeaderSize <= Offset then RaiseWideMessage('WAVE format');
    Header.DataId := WaveDataChunkId;
    Header.DataSize := SourceBuffer.GetUInt32At(Offset + SizeOf(Header.DataId));
    SourceBuffer.SetPosition(Offset + WaveChunkHeaderSize);
  end;
  Format.FormatTag := WAVE_FORMAT_PCM;
  Format.Channels := Header.Channels;
  Format.SamplesPerSecond := Header.SamplesPerSecond;
  Format.BitsPerSample := Header.BitsPerSample;
  Format.BlockAlign := Header.BlockAlign;
  Format.AverageBytesPerSecond := Format.BlockAlign * Format.SamplesPerSecond;
  Format.ExtraSize := 0;
  SampleDataSize := Header.DataSize;
  if SampleData <> nil then
  begin
    FreeEC(SampleData);
    SampleData := nil;
  end;
  SampleData := AllocEC(SampleDataSize);
  SourceBuffer.ReadBytes(SampleData, SampleDataSize);
end;
{ @end $4C6964 }

end.
