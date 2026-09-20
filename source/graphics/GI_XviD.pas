unit GI_XviD;
// Unit bracket (inferred): .text 0x004B6C68..0x004B7A9C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_File, EC_Buf, EC_BlockPar, GI_MessageLoop, Vfw;

type
  TXvidFunction = function(Handle: Pointer; Option: Integer; Param1, Param2: Pointer): Integer; cdecl;
  TXvidGlobalInit = packed record // @size $0C
    Version: Integer; // @offset $00
    CpuFlags: Cardinal; // @offset $04
    Debug: Integer; // @offset $08
  end;
  TXvidDecoderCreate = packed record // @size $10
    Version: Integer; // @offset $00
    Width: Integer; // @offset $04
    Height: Integer; // @offset $08
    Handle: Pointer; // @offset $0C
  end;
  TXvidImage = packed record // @size $24
    ColorSpace: Integer; // @offset $00
    Planes: array[0..3] of Pointer; // @offset $04
    Strides: array[0..3] of Integer; // @offset $14
  end;
  TXvidDecoderFrame = packed record // @size $38
    Version: Integer; // @offset $00
    General: Integer; // @offset $04
    Bitstream: Pointer; // @offset $08
    Length: Integer; // @offset $0C
    Output: TXvidImage; // @offset $10
    Brightness: Integer; // @offset $34
  end;
  TXvidDecoderStats = packed record // @size $20
    Version: Integer; // @offset $00
    FrameType: Integer; // @offset $04
    // Native code clears the whole structure but does not inspect the union.
    Data: array[0..23] of Byte; // @offset $08
  end;

  TxvidGI = class(TObjectGI) // @size $170
  public
    SourceFile: TFileEC; // @offset $120
    CompressedFrame: TBufEC; // @offset $124
    DecoderHandle: Pointer; // @offset $130
    DecodedFrameCount: Integer; // @offset $134
    TargetFrame: Integer; // @offset $138
    VideoWidth: Integer; // @offset $13C
    VideoHeight: Integer; // @offset $140
    PlaybackFinished: TObjectNotifyEventGI; // @offset $148
    ColorSpace: Integer; // @offset $150
    FillViewport: Boolean; // @offset $154
    AviFile: IAVIFile; // @offset $158
    AviStream: IAVIStream; // @offset $15C
    FrameCount: Integer; // @offset $160
    FramesPerSecond: Double; // @offset $168

    constructor Create(Owner: TObjectGI); // @addr $4B6DA0
    destructor Destroy; override; // @addr $4B6DE8
    procedure Clear; override; // @addr $4B6E24
    function ImageOpen(const FileName: WideString; FillViewport: Boolean): Boolean; // @addr $4B6E40
    procedure XvidClose; // @addr $4B75BC
    procedure ImageClose; // @addr $4B76D4
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4B7744
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4B7778
    procedure ReadVideoConfig(Block: TBlockParEC); // @addr $4B77A0
    function DecodeNextFrame: Boolean; // @addr $4B77B0
    function SetPlaybackTime(TimeMs: Double): Boolean; // @addr $4B79C0
    procedure SetFramePosition(Frame: Integer); // @addr $4B7A28
  end;

var
  XvidLibrary: Cardinal = 0; // @addr $87A9F8
  XvidGlobal: TXvidFunction = nil; // @addr $87A9FC
  XvidDecore: TXvidFunction = nil; // @addr $87AA00

implementation

uses Windows, SysUtils, Direct3D9, GR_DX, GR_Main, EC_Str, EC_Struct;

{ @routine $4B6DA0 TxvidGI_Create }
constructor TxvidGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $4B6DA0 }

{ @routine $4B6DE8 TxvidGI_Destroy }
destructor TxvidGI.Destroy;
begin
  ImageClose;
  inherited Destroy;
end;
{ @end $4B6DE8 }

{ @routine $4B6E24 TxvidGI_Clear }
procedure TxvidGI.Clear;
begin
  ImageClose;
  inherited Clear;
end;
{ @end $4B6E24 }

{ @routine $4B6E40 TxvidGI_ImageOpen }
function TxvidGI.ImageOpen(const FileName: WideString; FillViewport: Boolean): Boolean;
var
  ErrorCode, FormatSize, Status: Integer;
  GlobalInit: TXvidGlobalInit;
  DecoderCreate: TXvidDecoderCreate;
  Format: TBitmapInfoHeader;
  Info: TAVIStreamInfoA;
begin
  Result := True;
  Self.FillViewport := FillViewport;
  ImageClose;
  try
    if XvidLibrary = 0 then
    begin
      XvidLibrary := LoadLibrary('xvidcore.dll');
      if XvidLibrary = 0 then RaiseWideMessage('Error xvidcore.dll');
      XvidGlobal := GetProcAddress(XvidLibrary, 'xvid_global');
      if not Assigned(XvidGlobal) then RaiseWideMessage('Error xvid_global');
      XvidDecore := GetProcAddress(XvidLibrary, 'xvid_decore');
      if not Assigned(XvidDecore) then RaiseWideMessage('Error xvid_decore');
    end;
    FillChar(GlobalInit, SizeOf(GlobalInit), 0);
    GlobalInit.Version := $10100;
    GlobalInit.CpuFlags := 0;
    XvidGlobal(nil, 0, @GlobalInit, nil);
    SourceFile := TFileEC.Create;
    CompressedFrame := TBufEC.Create;
    CompressedFrame.SetSize($180000);
    AVIFileInit;
    Status := AVIFileOpenA(AviFile, PAnsiChar(AnsiString(FileName)), 0, nil);
    if Status <> 0 then RaiseWideMessage('Error AVIFileOpenA = ' + IntToStr(Status));
    Status := AVIFileGetStream(AviFile, AviStream, $73646976, 0);
    if Status <> 0 then RaiseWideMessage('Error AVIFileGetStream = ' + IntToStr(Status));
    AVIStreamInfoA(AviStream, Info, SizeOf(Info));
    FramesPerSecond := Info.Rate / Info.Scale;
    FormatSize := SizeOf(Format);
    Status := AVIStreamReadFormat(AviStream, 0, @Format, FormatSize);
    if Status <> 0 then RaiseWideMessage('Error AVIStreamReadFormat ret = ' + IntToStr(Status));
    FrameCount := AVIStreamLength(AviStream);
    if FrameCount < 0 then RaiseWideMessage('Error AVIStreamLength FAVILen = ' + IntToStr(FrameCount));
    FillChar(DecoderCreate, SizeOf(DecoderCreate), 0);
    DecoderCreate.Version := $10100;
    DecoderCreate.Width := Format.biWidth;
    DecoderCreate.Height := Format.biHeight;
    Status := XvidDecore(nil, 0, @DecoderCreate, nil);
    if Status <> 0 then RaiseWideMessage('Error xvid_decore_func = ' + IntToStr(Status));
    DecoderHandle := DecoderCreate.Handle;
    DecodedFrameCount := 0;
    ColorSpace := $40;
    VideoWidth := Format.biWidth;
    VideoHeight := Format.biHeight;
    if Direct3DDevice = nil then raise Exception.Create('TxvidGI.ImageOpen(..)::GR_D3DDevice = nil');
    ErrorCode := Direct3DDevice.CreateTexture(VideoWidth, VideoHeight, 1, 0, D3DFMT_X8R8G8B8, D3DPOOL_MANAGED, OffscreenTexture, nil);
    if ErrorCode <> 0 then raise Exception.Create(Direct3DErrorText(ErrorCode));
    SetFramePosition(1);
    OffscreenFillViewport := Self.FillViewport;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      Result := False;
      ImageClose;
    end;
  end;
end;
{ @end $4B6E40 }

{ @routine $4B75BC TxvidGI_XvidClose }
procedure TxvidGI.XvidClose;
var Status: Integer;
begin
  if DecoderHandle <> nil then
  begin
    Status := XvidDecore(DecoderHandle, 1, nil, nil);
    DecoderHandle := nil;
    if Status <> 0 then AppendLogLineThreadSafe('Error XvidClose: xvid_decore_func - XVID_DEC_DESTROY = ' + IntToStr(Status));
  end;
  if AviStream <> nil then AviStream := nil;
  if AviFile <> nil then AviFile := nil;
  AVIFileExit;
end;
{ @end $4B75BC }

{ @routine $4B76D4 TxvidGI_ImageClose }
procedure TxvidGI.ImageClose;
begin
  XvidClose;
  if SourceFile <> nil then
  begin
    SourceFile.Free;
    SourceFile := nil;
  end;
  if CompressedFrame <> nil then
  begin
    CompressedFrame.Free;
    CompressedFrame := nil;
  end;
  if OffscreenTexture <> nil then OffscreenTexture := nil;
end;
{ @end $4B76D4 }

{ @routine $4B7744 TxvidGI_LoadFromConfigPath }
procedure TxvidGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  ReadVideoConfig(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B7744 }

{ @routine $4B7778 TxvidGI_LoadFromBlock }
procedure TxvidGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  ReadVideoConfig(Block);
end;
{ @end $4B7778 }

{ @routine $4B77A0 TxvidGI_ReadVideoConfig }
procedure TxvidGI.ReadVideoConfig(Block: TBlockParEC);
begin
end;
{ @end $4B77A0 }

{ @routine $4B77B0 TxvidGI_DecodeNextFrame }
function TxvidGI.DecodeNextFrame: Boolean;
var
  BytesUsed, ErrorCode: Integer;
  BytesRead: Cardinal;
  Data: Pointer;
  LockedRect: TD3DLockedRect;
  Frame: TXvidDecoderFrame;
  Stats: TXvidDecoderStats;
begin
  if DecodedFrameCount >= FrameCount then
  begin
    Result := False;
    Exit;
  end;
  if AVIStreamRead(AviStream, DecodedFrameCount, 1, CompressedFrame.Data,
    CompressedFrame.DataSize, @BytesRead, nil) <> 0 then RaiseWideMessage('AVI stream read');
  Data := CompressedFrame.Data;
  ErrorCode := OffscreenTexture.LockRect(0, LockedRect, nil, 0);
  if ErrorCode <> 0 then raise Exception.Create('GR_lpTexAVI.LockRect error');
  while BytesRead > 1 do
  begin
    FillChar(Stats, SizeOf(Stats), 0);
    Stats.Version := $10100;
    FillChar(Frame, SizeOf(Frame), 0);
    Frame.Version := $10100;
    Frame.General := 1;
    Frame.Bitstream := Data;
    Frame.Length := BytesRead;
    Frame.Output.ColorSpace := ColorSpace;
    Frame.Output.Planes[0] := LockedRect.Bits;
    Frame.Output.Strides[0] := LockedRect.Pitch;
    BytesUsed := XvidDecore(DecoderHandle, 2, @Frame, @Stats);
    if BytesUsed < 0 then RaiseWideMessage('AVI decode');
    Data := Pointer(PAnsiChar(Data) + BytesUsed);
    Dec(BytesRead, BytesUsed);
  end;
  OffscreenTexture.UnlockRect(0);
  Inc(DecodedFrameCount);
  OffscreenFillViewport := FillViewport;
  OffscreenFrameUpdated := True;
  Result := DecodedFrameCount < FrameCount;
end;
{ @end $4B77B0 }

{ @routine $4B79C0 TxvidGI_SetPlaybackTime }
function TxvidGI.SetPlaybackTime(TimeMs: Double): Boolean;
var Frame: Integer;
begin
  Result := False;
  Frame := Round(0.001 * TimeMs * FramesPerSecond);
  if Frame >= FrameCount then
  begin
    Frame := FrameCount - 1;
    Result := True;
  end;
  SetFramePosition(Frame);
end;
{ @end $4B79C0 }

{ @routine $4B7A28 TxvidGI_SetFramePosition }
procedure TxvidGI.SetFramePosition(Frame: Integer);
begin
  if DecoderHandle <> nil then
  begin
    TargetFrame := Frame;
    while TargetFrame > DecodedFrameCount do
      if not DecodeNextFrame then
      begin
        XvidClose;
        if Assigned(PlaybackFinished) then PlaybackFinished(Self);
        Break;
      end;
  end;
end;
{ @end $4B7A28 }

end.
