unit EC_CacheBuf;
// Unit bracket (inferred): .text 0x004E84A0..0x004E873B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache;

type
  TCBufControlEC = class;
  TCBufEC = class;

  TCBufControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x4E8570
    function CreateData: TCacheDataEC; override; // @addr 0x4E85F4
    function AcquireData: TCacheDataEC; override; // @addr 0x4E8650
  end;

  TCBufEC = class(TCacheDataEC) // @size 0x24
  public
    Buffer: TBufEC; // @offset 0x20

    constructor Create; // @addr 0x4E866C @ida "TCBufEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4E86B0 @ida "void __usercall $name(TCBufEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x4E8700 @note "Ignores LoadOption; ResidentBytes is not updated."
  end;

function AcquireOrCreateBuffer(Control: TCacheControlEC): TCBufEC; // @addr 0x4E8614 @note "Rewinds the shared buffer."

implementation

uses GR_Main;

{ @routine $4E8570 TCBufControlEC_QueueLoadIfMissing }
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
{ @end $4E8570 }

{ @routine $4E85F4 TCBufControlEC_CreateData }
function TCBufControlEC.CreateData: TCacheDataEC;
begin
  Result := TCBufEC.Create;
end;
{ @end $4E85F4 }

{ @routine $4E8614 AcquireOrCreateBuffer }
function AcquireOrCreateBuffer(Control: TCacheControlEC): TCBufEC;
begin
  Result := Control.AcquireDataFromConfig(TCBufEC) as TCBufEC;
  Result.Buffer.SetPosition(0);
end;
{ @end $4E8614 }

{ @routine $4E8650 TCBufControlEC_AcquireData }
function TCBufControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateBuffer(Self);
end;
{ @end $4E8650 }

{ @routine $4E866C TCBufEC_Create }
constructor TCBufEC.Create;
begin
  inherited Create;
end;
{ @end $4E866C }

{ @routine $4E86B0 TCBufEC_Destroy }
destructor TCBufEC.Destroy;
begin
  if Buffer <> nil then
  begin
    Buffer.Free;
    Buffer := nil;
  end;
  inherited Destroy;
end;
{ @end $4E86B0 }

{ @routine $4E8700 TCBufEC_LoadFromConfigBuffer }
procedure TCBufEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  Buffer := TBufEC.Create;
  Buffer.AddBytes(SourceBuffer.Data, SourceBuffer.DataSize);
end;
{ @end $4E8700 }

end.
