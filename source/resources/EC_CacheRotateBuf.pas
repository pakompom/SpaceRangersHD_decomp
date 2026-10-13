unit EC_CacheRotateBuf;

interface

uses Classes, EC_Cache;

type
  TCRotateBufControlEC = class;
  TCRotateBufEC = class;

  TCRotateBufControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x0048AD90
    function CreateData: TCacheDataEC; override; // @addr 0x0048ADFC
    function AcquireData: TCacheDataEC; override; // @addr 0x0048AE2C
  end;

  TCRotateBufEC = class(TCacheDataEC) // @size 0x24
  public
    Buffer: Pointer; // @offset 0x20

    constructor Create; // @addr 0x0048AE34
    destructor Destroy; override; // @addr 0x0048AE70
    procedure LoadFromKey(const Key: WideString); override; // @addr 0x0048AEA8 @note "Key contains width,height,source width,source height,center X,center Y as comma-delimited integers."
  end;

function AcquireOrCreateRotateBuf(Control: TCacheControlEC): TCRotateBufEC; // @addr 0x0048AE0C

implementation

uses SysUtils, EC_Str, GR_Main, GR_GraphBuf;

{ @routine $48AD90 TCRotateBufControlEC_QueueLoadIfMissing }
procedure TCRotateBufControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCRotateBufControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCRotateBufEC) <> nil then Exit;
  Control := TCRotateBufControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $48AD90 }

{ @routine $48ADFC TCRotateBufControlEC_CreateData }
function TCRotateBufControlEC.CreateData: TCacheDataEC;
begin
  Result := TCRotateBufEC.Create;
end;
{ @end $48ADFC }

{ @routine $48AE0C AcquireOrCreateRotateBuf }
function AcquireOrCreateRotateBuf(Control: TCacheControlEC): TCRotateBufEC;
begin
  Result := Control.AcquireDataFromDirectKey(TCRotateBufEC) as TCRotateBufEC;
end;
{ @end $48AE0C }

{ @routine $48AE2C TCRotateBufControlEC_AcquireData }
function TCRotateBufControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateRotateBuf(Self);
end;
{ @end $48AE2C }

{ @routine $48AE34 TCRotateBufEC_Create }
constructor TCRotateBufEC.Create;
begin
  inherited Create;
  Buffer := nil;
end;
{ @end $48AE34 }

{ @routine $48AE70 TCRotateBufEC_Destroy }
destructor TCRotateBufEC.Destroy;
begin
  if Buffer <> nil then
  begin
    Ex_OKGR_RotateBuf_Free(Buffer);
    Buffer := nil;
  end;
  inherited Destroy;
end;
{ @end $48AE70 }

{ @routine $48AEA8 TCRotateBufEC_LoadFromKey }
procedure TCRotateBufEC.LoadFromKey(const Key: WideString);
begin
  if CountDelimitedPartsW(Key, ',') <> 6 then
    raise Exception.Create('TCRotateBufEC.Load. Error create rotate buf.');
  Buffer := Ex_OKGR_RotateBuf_Build(
    StrToInt(ExtractDelimitedPartW(Key, 0, ',')),
    StrToInt(ExtractDelimitedPartW(Key, 1, ',')),
    StrToInt(ExtractDelimitedPartW(Key, 2, ',')),
    StrToInt(ExtractDelimitedPartW(Key, 3, ',')),
    StrToInt(ExtractDelimitedPartW(Key, 4, ',')),
    StrToInt(ExtractDelimitedPartW(Key, 5, ',')));
  if Buffer = nil then
    raise Exception.Create('TCRotateBufEC.Load. Error create rotate buf.');
end;
{ @end $48AEA8 }

end.
