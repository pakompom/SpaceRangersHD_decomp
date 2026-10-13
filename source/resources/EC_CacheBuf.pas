unit EC_CacheBuf;

interface

uses Classes, EC_Buf, EC_Cache;

type
  TCBufControlEC = class;
  TCBufEC = class;

  TCBufControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x004E6FF4
    function CreateData: TCacheDataEC; override; // @addr 0x004E7060
    function AcquireData: TCacheDataEC; override; // @addr 0x004E709C
  end;

  TCBufEC = class(TCacheDataEC) // @size 0x24
  public
    Buffer: TBufEC; // @offset 0x20

    constructor Create; // @addr 0x004E70A4
    destructor Destroy; override; // @addr 0x004E70DC
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x004E7114 @note "Ignores LoadOption; ResidentBytes is not updated."
  end;

function AcquireOrCreateBuffer(Control: TCacheControlEC): TCBufEC; // @addr 0x004E7070 @note "Rewinds the shared buffer."

implementation

uses GR_Main;

{ @routine $4E6FF4 TCBufControlEC_QueueLoadIfMissing }
procedure TCBufControlEC.QueueLoadIfMissing(PendingLoads: TList);
var
  Control: TCBufControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCBufEC) <> nil then Exit;
  Control := TCBufControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $4E6FF4 }

{ @routine $4E7060 TCBufControlEC_CreateData }
function TCBufControlEC.CreateData: TCacheDataEC;
begin
  Result := TCBufEC.Create;
end;
{ @end $4E7060 }

{ @routine $4E7070 AcquireOrCreateBuffer }
function AcquireOrCreateBuffer(Control: TCacheControlEC): TCBufEC;
begin
  Result := Control.AcquireDataFromConfig(TCBufEC) as TCBufEC;
  Result.Buffer.SetPosition(0);
end;
{ @end $4E7070 }

{ @routine $4E709C TCBufControlEC_AcquireData }
function TCBufControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateBuffer(Self);
end;
{ @end $4E709C }

{ @routine $4E70A4 TCBufEC_Create }
constructor TCBufEC.Create;
begin
  inherited Create;
end;
{ @end $4E70A4 }

{ @routine $4E70DC TCBufEC_Destroy }
destructor TCBufEC.Destroy;
begin
  if Buffer <> nil then
  begin
    Buffer.Free;
    Buffer := nil;
  end;
  inherited Destroy;
end;
{ @end $4E70DC }

{ @routine $4E7114 TCBufEC_LoadFromConfigBuffer }
procedure TCBufEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  Buffer := TBufEC.Create;
  Buffer.AddBytes(SourceBuffer.Data, SourceBuffer.DataSize);
end;
{ @end $4E7114 }

end.
