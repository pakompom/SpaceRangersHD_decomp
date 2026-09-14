unit EC_CacheRotateBuf;
// Unit bracket (inferred): .text 0x0047C3A8..0x0047C7F7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Cache;

type
  TCRotateBufControlEC = class;
  TCRotateBufEC = class;

  TCRotateBufControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x47C488
    function CreateData: TCacheDataEC; override; // @addr 0x47C50C
    function AcquireData: TCacheDataEC; override; // @addr 0x47C558
  end;

  TCRotateBufEC = class(TCacheDataEC) // @size 0x24
  public
    Buffer: Pointer; // @offset 0x20

    constructor Create; // @addr 0x47C574 @ida "TCRotateBufEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x47C5C0 @ida "void __usercall $name(TCRotateBufEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromKey(const Key: WideString); override; // @addr 0x47C610 @note "Key contains width,height,source width,source height,center X,center Y as comma-delimited integers."
  end;

function AcquireOrCreateRotateBuf(Control: TCacheControlEC): TCRotateBufEC; // @addr 0x47C52C

implementation

uses SysUtils, EC_Str, GR_Main, GR_GraphBuf;

{ @routine $47C488 TCRotateBufControlEC_QueueLoadIfMissing }
procedure TCRotateBufControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCRotateBufControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCRotateBufEC) = nil then
  begin
    Control := TCRotateBufControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $47C488 }

{ @routine $47C50C TCRotateBufControlEC_CreateData }
function TCRotateBufControlEC.CreateData: TCacheDataEC;
begin
  Result := TCRotateBufEC.Create;
end;
{ @end $47C50C }

{ @routine $47C52C AcquireOrCreateRotateBuf }
function AcquireOrCreateRotateBuf(Control: TCacheControlEC): TCRotateBufEC;
begin
  Result := Control.AcquireDataFromDirectKey(TCRotateBufEC) as TCRotateBufEC;
end;
{ @end $47C52C }

{ @routine $47C558 TCRotateBufControlEC_AcquireData }
function TCRotateBufControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateRotateBuf(Self);
end;
{ @end $47C558 }

{ @routine $47C574 TCRotateBufEC_Create }
constructor TCRotateBufEC.Create;
begin
  inherited Create;
  Buffer := nil;
end;
{ @end $47C574 }

{ @routine $47C5C0 TCRotateBufEC_Destroy }
destructor TCRotateBufEC.Destroy;
begin
  if Buffer <> nil then
  begin
    Ex_OKGR_RotateBuf_Free(Buffer);
    Buffer := nil;
  end;
  inherited Destroy;
end;
{ @end $47C5C0 }

{ @routine $47C610 TCRotateBufEC_LoadFromKey }
procedure TCRotateBufEC.LoadFromKey(const Key: WideString);
begin
  if CountDelimitedPartsW(Key, ',') <> 6 then
    raise Exception.Create('TCRotateBufEC.Load. Error create rotate buf.');
  Buffer := Ex_OKGR_RotateBuf_Build(
    StrToInt(AnsiString(ExtractDelimitedPartW(Key, 0, ','))),
    StrToInt(AnsiString(ExtractDelimitedPartW(Key, 1, ','))),
    StrToInt(AnsiString(ExtractDelimitedPartW(Key, 2, ','))),
    StrToInt(AnsiString(ExtractDelimitedPartW(Key, 3, ','))),
    StrToInt(AnsiString(ExtractDelimitedPartW(Key, 4, ','))),
    StrToInt(AnsiString(ExtractDelimitedPartW(Key, 5, ','))));
  if Buffer = nil then
    raise Exception.Create('TCRotateBufEC.Load. Error create rotate buf.');
end;
{ @end $47C610 }

end.
