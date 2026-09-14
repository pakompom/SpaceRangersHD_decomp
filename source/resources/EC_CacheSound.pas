unit EC_CacheSound;
// Unit bracket (inferred): .text 0x007EBFB8..0x007EC33C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache;

type
  TWaveFormatEx = packed record // @size 0x12
    FormatTag: Word; // @offset 0x00
    Channels: Word; // @offset 0x02
    SamplesPerSecond: Cardinal; // @offset 0x04
    AverageBytesPerSecond: Cardinal; // @offset 0x08
    BlockAlign: Word; // @offset 0x0C
    BitsPerSample: Word; // @offset 0x0E
    ExtraSize: Word; // @offset 0x10
  end;
  PWaveFormatEx = ^TWaveFormatEx;

  TWaveFileHeader = packed record // @size 0x2C
    // Uninterpreted RIFF/fmt identifiers and lengths precede these fields.
    Channels: Word; // @offset 0x16
    SamplesPerSecond: Cardinal; // @offset 0x18
    BlockAlign: Word; // @offset 0x20
    BitsPerSample: Word; // @offset 0x22
    DataId: Cardinal; // @offset 0x24
    DataSize: Cardinal; // @offset 0x28
  end;

  TCSoundControlEC = class;
  TCSoundEC = class;

  TCSoundControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x7EC090 @slot 0x08
    function CreateData: TCacheDataEC; override; // @addr 0x7EC114 @slot 0x0C
    function AcquireData: TCacheDataEC; override; // @addr 0x7EC160 @slot 0x10
  end;

  TCSoundEC = class(TCacheDataEC) // @size 0x3C
  public
    Format: TWaveFormatEx; // @offset 0x20
    SampleData: Pointer; // @offset 0x34
    SampleDataSize: Cardinal; // @offset 0x38

    constructor Create; // @addr 0x7EC17C @ida "TCSoundEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7EC1C0 @ida "void __usercall $name(TCSoundEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x7EC210 @slot 0x00 @note "Reads 44 bytes from the current position. Forces PCM without validating RIFF, WAVE or fmt identifiers. If data is absent at header offset 36, scans the whole buffer byte by byte for it. Ignores LoadOption."
  end;

function AcquireCachedSound(Control: TCacheControlEC): TCSoundEC; // @addr 0x7EC134

implementation

uses EC_Mem, GR_Main, MMSystem;

const
  WaveDataChunkId = $61746164; // little-endian 'data'
  WaveChunkHeaderSize = 2 * SizeOf(Cardinal);

{ @routine $7EC090 TCSoundControlEC_QueueLoadIfMissing }
procedure TCSoundControlEC.QueueLoadIfMissing(PendingLoads: TList);
var
  Control: TCSoundControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCSoundEC) = nil then
  begin
    Control := TCSoundControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $7EC090 }

{ @routine $7EC114 TCSoundControlEC_CreateData }
function TCSoundControlEC.CreateData: TCacheDataEC;
begin
  Result := TCSoundEC.Create;
end;
{ @end $7EC114 }

{ @routine $7EC134 AcquireCachedSound }
function AcquireCachedSound(Control: TCacheControlEC): TCSoundEC;
begin
  Result := Control.AcquireDataFromConfig(TCSoundEC) as TCSoundEC;
end;
{ @end $7EC134 }

{ @routine $7EC160 TCSoundControlEC_AcquireData }
function TCSoundControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedSound(Self);
end;
{ @end $7EC160 }

{ @routine $7EC17C TCSoundEC_Create }
constructor TCSoundEC.Create;
begin
  inherited Create;
end;
{ @end $7EC17C }

{ @routine $7EC1C0 TCSoundEC_Destroy }
destructor TCSoundEC.Destroy;
begin
  if SampleData <> nil then
  begin
    FreeEC(SampleData);
    SampleData := nil;
  end;
  inherited Destroy;
end;
{ @end $7EC1C0 }

{ @routine $7EC210 TCSoundEC_LoadFromConfigBuffer }
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
{ @end $7EC210 }

end.
