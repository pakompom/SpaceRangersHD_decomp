unit EC_CacheBuf;
// Unit bracket (inferred): .text 0x0053A558..0x0053A7F3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache;

type
  TCBufControlEC = class;
  TCBufEC = class;

  TCBufControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x53A628
    function CreateData: TCacheDataEC; override; // @addr 0x53A6AC
    function AcquireData: TCacheDataEC; override; // @addr 0x53A708
  end;

  TCBufEC = class(TCacheDataEC) // @size 0x24
  public
    Buffer: TBufEC; // @offset 0x20

    constructor Create; // @addr 0x53A724
    destructor Destroy; override; // @addr 0x53A768
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x53A7B8 @note "Ignores LoadOption; ResidentBytes is not updated."
  end;

function AcquireOrCreateBuffer(Control: TCacheControlEC): TCBufEC; // @addr 0x53A6CC @note "Rewinds the shared buffer."

implementation

uses GR_Main;

{ @routine $53A628 TCBufControlEC_QueueLoadIfMissing }
procedure TCBufControlEC.QueueLoadIfMissing(PendingLoads: TList);
var
  Control: TCBufControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCBufEC) = nil then
  begin
    Control := TCBufControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $53A628 }

{ @routine $53A6AC TCBufControlEC_CreateData }
function TCBufControlEC.CreateData: TCacheDataEC;
begin
  Result := TCBufEC.Create;
end;
{ @end $53A6AC }

{ @routine $53A6CC AcquireOrCreateBuffer }
function AcquireOrCreateBuffer(Control: TCacheControlEC): TCBufEC;
begin
  Result := Control.AcquireDataFromConfig(TCBufEC) as TCBufEC;
  Result.Buffer.SetPosition(0);
end;
{ @end $53A6CC }

{ @routine $53A708 TCBufControlEC_AcquireData }
function TCBufControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateBuffer(Self);
end;
{ @end $53A708 }

{ @routine $53A724 TCBufEC_Create }
constructor TCBufEC.Create;
begin
  inherited Create;
end;
{ @end $53A724 }

{ @routine $53A768 TCBufEC_Destroy }
destructor TCBufEC.Destroy;
begin
  if Buffer <> nil then
  begin
    Buffer.Free;
    Buffer := nil;
  end;
  inherited Destroy;
end;
{ @end $53A768 }

{ @routine $53A7B8 TCBufEC_LoadFromConfigBuffer }
procedure TCBufEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  Buffer := TBufEC.Create;
  Buffer.AddBytes(SourceBuffer.Data, SourceBuffer.DataSize);
end;
{ @end $53A7B8 }

end.
