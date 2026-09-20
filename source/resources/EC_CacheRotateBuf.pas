unit EC_CacheRotateBuf;
// Unit bracket (inferred): .text 0x0049350C..0x0049395B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Cache;

type
  TCRotateBufControlEC = class;
  TCRotateBufEC = class;

  TCRotateBufControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x4935EC
    function CreateData: TCacheDataEC; override; // @addr 0x493670
    function AcquireData: TCacheDataEC; override; // @addr 0x4936BC
  end;

  TCRotateBufEC = class(TCacheDataEC) // @size 0x24
  public
    Buffer: Pointer; // @offset 0x20

    constructor Create; // @addr 0x4936D8
    destructor Destroy; override; // @addr 0x493724
    procedure LoadFromKey(const Key: WideString); override; // @addr 0x493774 @note "Key contains width,height,source width,source height,center X,center Y as comma-delimited integers."
  end;

function AcquireOrCreateRotateBuf(Control: TCacheControlEC): TCRotateBufEC; // @addr 0x493690

implementation

uses SysUtils, EC_Str, GR_Main, GR_GraphBuf;

{ @routine $4935EC TCRotateBufControlEC_QueueLoadIfMissing }
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
{ @end $4935EC }

{ @routine $493670 TCRotateBufControlEC_CreateData }
function TCRotateBufControlEC.CreateData: TCacheDataEC;
begin
  Result := TCRotateBufEC.Create;
end;
{ @end $493670 }

{ @routine $493690 AcquireOrCreateRotateBuf }
function AcquireOrCreateRotateBuf(Control: TCacheControlEC): TCRotateBufEC;
begin
  Result := Control.AcquireDataFromDirectKey(TCRotateBufEC) as TCRotateBufEC;
end;
{ @end $493690 }

{ @routine $4936BC TCRotateBufControlEC_AcquireData }
function TCRotateBufControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateRotateBuf(Self);
end;
{ @end $4936BC }

{ @routine $4936D8 TCRotateBufEC_Create }
constructor TCRotateBufEC.Create;
begin
  inherited Create;
  Buffer := nil;
end;
{ @end $4936D8 }

{ @routine $493724 TCRotateBufEC_Destroy }
destructor TCRotateBufEC.Destroy;
begin
  if Buffer <> nil then
  begin
    Ex_OKGR_RotateBuf_Free(Buffer);
    Buffer := nil;
  end;
  inherited Destroy;
end;
{ @end $493724 }

{ @routine $493774 TCRotateBufEC_LoadFromKey }
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
{ @end $493774 }

end.
