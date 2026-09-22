unit GI_GAI;
// Unit bracket (inferred): .text 0x0047FE50..0x00483241; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types, GR_GraphBuf, GI_Main, EC_CacheGI, EC_CacheGAI, EC_BlockPar, Classes, GI_MessageLoop;

type
  TgaiGI = class(TObjectGI) // @size 0x17C
  public
    MainImageCache: TCGaiControlEC; // @offset 0x120
    FirstFrameImageCache: TCGiControlEC; // @offset 0x124
    AutoFrameTimer: PCallbackTimerGI; // @offset 0x128
    ImageKindX: TImageKindXGI; // @offset 0x12C
    ImageKindY: TImageKindYGI; // @offset 0x12D
    Alpha: Byte; // @offset 0x12E
    // Playback position is within the selected sequence, not the source image.
    SequenceFrame: Integer; // @offset 0x130
    SequenceFrameCount: Integer; // @offset 0x134
    SequenceFrameIndexTable: ^Integer; // @offset 0x138
    SequenceFrameDelayTable: ^Integer; // @offset 0x13C
    SequenceIndex: Integer; // @offset 0x140
    UsesPlaybackBuffer: Boolean; // @offset 0x144
    CachedPlaybackGraphBuf: TGraphBufGR; // @offset 0x148
    LastCachedFrameIndex: Integer; // @offset 0x14C
    TransparentColor: Cardinal; // @offset 0x150
    CycleCompleteCallback: TObjectNotifyEventGI; // @offset $158
    FrameAdvancedCallback: TObjectNotifyEventGI; // @offset $160
    SkipImageUpdateRect: Boolean; // @offset 0x168
    StopPlaybackRequested: Boolean; // @offset 0x169
    StopAfterOneCycle: Boolean; // @offset 0x16A
    StartSoundName: WideString; // @offset 0x16C
    FirstFrameOnly: Boolean; // @offset 0x170
    AutoUpdateFlags: Cardinal; // @offset 0x174
    HardwareMirrorHorizontal: Boolean; // @offset $178  Passed to hardware texture drawing only.

    procedure SetHardwareMirrorHorizontal(Value: Boolean); // @addr $4821E0

    constructor Create(Owner: TObjectGI); // @addr 0x47FF80
    destructor Destroy; override; // @addr 0x48009C
    procedure Clear; override; // @addr 0x480164 @note "Preserves animation state."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x480178 @note "Resets sequence position even when the key is unchanged."
    function GetImagePath: WideString; // @addr 0x4801EC
    function GetFirstFrameImagePath: WideString; // @addr $4802B8
    procedure SetFirstFrameImagePath(const ImagePath: WideString); // @addr 0x480210
    procedure SetSequenceFrame(FrameInSequence: Integer); // @addr 0x4802F4 @note "Does not validate the index."
    procedure SetFramePosition(FrameInSequence: Integer; ForwardOnly: Boolean); // @addr 0x480340 @note "Accepted out-of-range positions become zero."
    function GetMainImageFrameCount: Integer; // @addr 0x4803B8 @note "Returns zero in FirstFrameOnly mode."
    procedure StopAutoPlayback; // @addr 0x480428
    procedure RestartPlayback; // @addr 0x480468 @note "Does not reset frame position; single-frame sequences remain timer-free."
    function GetContentSize: TPoint; // @addr 0x480524
    function GetContentOrigin: TPoint; // @addr 0x48061C
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x480730
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x480768
    procedure SetAlpha(Value: Byte); // @addr 0x4807A0
    procedure SetSize(Size: TPoint); override; // @addr 0x4807D8
    procedure ClearFrameSequence; // @addr 0x4807FC
    procedure LoadFrameSequenceFromText(const FrameSpec: WideString); // @addr 0x480870 @note "Accepts ascending and descending ranges; changes the playback timer unless stopped."
    function GetSequenceCount: Integer; // @addr 0x480B08
    function GetSequenceFrameSourceIndex(FrameInSequence: Integer): Integer; // @addr 0x480B78 @note "Does not validate the index."
    procedure SetFrameDelay(FrameInSequence, DelayMs: Integer); // @addr 0x480BB0 @note "Does not validate the index."
    function GetFrameDelay(FrameInSequence: Integer): Integer; // @addr 0x480BEC @note "Does not validate the index."
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x480C24 @note "Black pixels do not count as hits; composed playback may require an existing composition buffer."
    procedure SetActive(Value: Boolean); override; // @addr 0x4811F8
    procedure OnDeactivate; override; // @addr 0x4812AC
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x481310
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x481344
    procedure LoadAnimationProperties(Block: TBlockParEC); // @addr 0x48136C
    procedure UpdateAutoGeometry; override; // @addr 0x481840 @note "Also rebuilds frame tables when SequenceIndex is nonnegative."
    procedure SetOneCycleDuration(DurationMs: Integer); // @addr 0x481A68 @note "Enables StopAfterOneCycle; frame delays are rounded to milliseconds with a minimum of one."
    procedure AdvanceAutoFrame(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x481AF8
    procedure Invalidate; override; // @addr 0x481C84
    procedure Draw(ClipRect: TRect); override; // @addr 0x4821FC
    procedure PrimeImageCaches; // @addr 0x4830DC @note "Skips the main GAI in FirstFrameOnly mode."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x48316C
  end;

var
  GaiFrameHeap: Cardinal = 0; // @addr 0x87A9F0

procedure LoadGaiFrameToGraphBuf(const Path: WideString; GraphBuf: TGraphBufGR; Seed: Cardinal); // @addr $483190

implementation

uses GR_Sound, EC_Struct, Direct3D9, GR_DX, GR_gi, GR_Main, EC_Cache, EC_Str, EC_Mem, SysUtils, Windows, aMyFunction, GlobalsV;


{ @routine $47FF80 TgaiGI_Create }
constructor TgaiGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  if GaiFrameHeap = 0 then
  begin
    GaiFrameHeap := HeapCreate(0, $8000, 0);
    if GaiFrameHeap = 0 then raise Exception.Create('TgaiGI.HeapCreate');
  end;
  Alpha := 255;
  MainImageCache := TCGaiControlEC.Create;
  GlobalCache.ResetControl(MainImageCache);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  StopPlaybackRequested := False;
  StopAfterOneCycle := False;
  SequenceIndex := -1;
  TransparentColor := 0;
  SkipImageUpdateRect := False;
end;
{ @end $47FF80 }

{ @routine $48009C TgaiGI_Destroy }
destructor TgaiGI.Destroy;
begin
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
  if AutoFrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := nil;
  end;
  MainImageCache.Free;
  MainImageCache := nil;
  if FirstFrameImageCache <> nil then
  begin
    FirstFrameImageCache.Free;
    FirstFrameImageCache := nil;
  end;
  ClearFrameSequence;
  inherited Destroy;
end;
{ @end $48009C }

{ @routine $480164 TgaiGI_Clear }
procedure TgaiGI.Clear;
begin
  inherited Clear;
end;
{ @end $480164 }

{ @routine $480178 TgaiGI_SetImagePath }
procedure TgaiGI.SetImagePath(const ImagePath: WideString);
begin
  SequenceFrame := 0;
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
  if MainImageCache.CacheKey <> ImagePath then
  begin
    Invalidate;
    MainImageCache.SetCacheKey(ImagePath);
  end;
end;
{ @end $480178 }

{ @routine $4801EC TgaiGI_GetImagePath }
function TgaiGI.GetImagePath: WideString;
begin
  Result := MainImageCache.CacheKey;
end;
{ @end $4801EC }

{ @routine $480210 TgaiGI_SetFirstFrameImagePath }
procedure TgaiGI.SetFirstFrameImagePath(const ImagePath: WideString);
begin
  SequenceFrame := 0;
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
  if FirstFrameImageCache = nil then
  begin
    FirstFrameImageCache := TCGiControlEC.Create;
    GlobalCache.ResetControl(FirstFrameImageCache);
  end;
  if FirstFrameImageCache.CacheKey <> ImagePath then
  begin
    Invalidate;
    FirstFrameImageCache.SetCacheKey(ImagePath);
  end;
end;
{ @end $480210 }

{ @routine $4802B8 TgaiGI_GetFirstFrameImagePath }
function TgaiGI.GetFirstFrameImagePath: WideString;
begin
  if FirstFrameImageCache = nil then Result := ''
  else Result := FirstFrameImageCache.CacheKey;
end;
{ @end $4802B8 }

{ @routine $4802F4 TgaiGI_SetSequenceFrame }
procedure TgaiGI.SetSequenceFrame(FrameInSequence: Integer);
begin
  SequenceFrame := FrameInSequence;
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
  Invalidate;
end;
{ @end $4802F4 }

{ @routine $480340 TgaiGI_SetFramePosition }
procedure TgaiGI.SetFramePosition(FrameInSequence: Integer; ForwardOnly: Boolean);
begin
  if SequenceFrame = FrameInSequence then Exit;
  if (FrameInSequence <= SequenceFrame) and ForwardOnly then Exit;
  SequenceFrame := FrameInSequence;
  if (SequenceFrame < 0) or (SequenceFrame >= SequenceFrameCount) then
    SequenceFrame := 0;
  Invalidate;
end;
{ @end $480340 }

{ @routine $4803B8 TgaiGI_GetMainImageFrameCount }
function TgaiGI.GetMainImageFrameCount: Integer;
var Image: TCGaiEC;
begin
  if FirstFrameOnly then
  begin
    Result := 0;
    Exit;
  end;
  Image := AcquireCachedGai(MainImageCache);
  try
    Result := Image.GetFrameCount;
  finally
    MainImageCache.Release;
  end;
end;
{ @end $4803B8 }

{ @routine $480428 TgaiGI_StopAutoPlayback }
procedure TgaiGI.StopAutoPlayback;
begin
  StopPlaybackRequested := True;
  if AutoFrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := nil;
  end;
end;
{ @end $480428 }

{ @routine $480468 TgaiGI_RestartPlayback }
procedure TgaiGI.RestartPlayback;
var Delay: Integer;
begin
  StopPlaybackRequested := False;
  if AutoFrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := nil;
  end;
  if SequenceFrameCount > 1 then
  begin
    Delay := GetFrameDelay(SequenceFrame);
    AutoFrameTimer := MessageLoop.ScheduleCallbackTimer(Delay, Delay, AdvanceAutoFrame);
  end;
  if (StartSoundName <> '') and (SequenceFrame = 0) then SoundManager.PlaySound(StartSoundName);
end;
{ @end $480468 }

{ @routine $480524 TgaiGI_GetContentSize }
function TgaiGI.GetContentSize: TPoint;
var Image: TCGaiEC; First: TCGiEC;
begin
  if MainImageCache.CacheKey = '' then
  begin
    Result := Classes.Point(0, 0);
    Exit;
  end;
  if not FirstFrameOnly then
  begin
    Image := AcquireCachedGai(MainImageCache);
    try
      Result := Image.GetCanvasSize;
    finally
      MainImageCache.Release;
    end;
  end
  else if FirstFrameImageCache <> nil then
  begin
    First := AcquireCachedGi(FirstFrameImageCache);
    try
      Result := First.Image.GetContentSize;
    finally
      FirstFrameImageCache.Release;
    end;
  end
  else Result := Classes.Point(0, 0);
end;
{ @end $480524 }

{ @routine $48061C TgaiGI_GetContentOrigin }
function TgaiGI.GetContentOrigin: TPoint;
var Image: TCGaiEC; First: TCGiEC;
begin
  if MainImageCache.CacheKey = '' then
  begin
    Result := Classes.Point(0, 0);
    Exit;
  end;
  if not FirstFrameOnly then
  begin
    Image := AcquireCachedGai(MainImageCache);
    try
      Result := Image.GetBoundsRect.TopLeft;
    finally
      MainImageCache.Release;
    end;
  end
  else if FirstFrameImageCache <> nil then
  begin
    First := AcquireCachedGi(FirstFrameImageCache);
    try
      Result := First.Image.GetBoundsRect.TopLeft;
    finally
      FirstFrameImageCache.Release;
    end;
  end
  else Result := Classes.Point(0, 0);
end;
{ @end $48061C }

{ @routine $480730 TgaiGI_SetImageKindX }
procedure TgaiGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $480730 }

{ @routine $480768 TgaiGI_SetImageKindY }
procedure TgaiGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $480768 }

{ @routine $4807A0 TgaiGI_SetAlpha }
procedure TgaiGI.SetAlpha(Value: Byte);
begin
  if Alpha <> Value then
  begin
    Alpha := Value;
    Invalidate;
  end;
end;
{ @end $4807A0 }

{ @routine $4807D8 TgaiGI_SetSize }
procedure TgaiGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
end;
{ @end $4807D8 }

{ @routine $4807FC TgaiGI_ClearFrameSequence }
procedure TgaiGI.ClearFrameSequence;
begin
  if SequenceFrameIndexTable <> nil then
  begin
    FreeFromHeapEC(GaiFrameHeap, SequenceFrameIndexTable);
    SequenceFrameIndexTable := nil;
  end;
  if SequenceFrameDelayTable <> nil then
  begin
    FreeFromHeapEC(GaiFrameHeap, SequenceFrameDelayTable);
    SequenceFrameDelayTable := nil;
  end;
  SequenceFrame := 0;
  SequenceFrameCount := 0;
end;
{ @end $4807FC }

{ @routine $480870 TgaiGI_LoadFrameSequenceFromText }
procedure TgaiGI.LoadFrameSequenceFromText(const FrameSpec: WideString);
var Part: WideString; Index, Count, Offset, RangeCount, Delay, First, Last, TimerDelay: Integer;
begin
  ClearFrameSequence;
  Count := (CountDelimitedPartsW(FrameSpec, '[]') - 1) div 2;
  for Index := 0 to Count - 1 do
  begin
    Part := ExtractDelimitedPartW(FrameSpec, Index * 2 + 1, '[]');
    Delay := ExtractDigitsToIntW(ExtractDelimitedPartW(Part, 0, ',-'));
    First := ExtractDigitsToIntW(ExtractDelimitedPartW(Part, 1, ',-'));
    Last := ExtractDigitsToIntW(ExtractDelimitedPartW(Part, 2, ',-'));
    RangeCount := Abs(First - Last) + 1;
    Inc(SequenceFrameCount, RangeCount);
    SequenceFrameIndexTable := ReAllocFromHeapREC(GaiFrameHeap, SequenceFrameIndexTable, SequenceFrameCount * SizeOf(Integer));
    SequenceFrameDelayTable := ReAllocFromHeapREC(GaiFrameHeap, SequenceFrameDelayTable, SequenceFrameCount * SizeOf(Integer));
    for Offset := 0 to RangeCount - 1 do
    begin
      WriteInt32EC(AddPointerOffset(SequenceFrameIndexTable, (SequenceFrameCount - RangeCount + Offset) * SizeOf(Integer)), First);
      WriteInt32EC(AddPointerOffset(SequenceFrameDelayTable, (SequenceFrameCount - RangeCount + Offset) * SizeOf(Integer)), Delay);
      if First < Last then Inc(First) else Dec(First);
    end;
  end;
  if not StopPlaybackRequested then
  begin
    TimerDelay := GetFrameDelay(SequenceFrame);
  if AutoFrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := nil;
  end;
    AutoFrameTimer := MessageLoop.ScheduleCallbackTimer(TimerDelay, TimerDelay, AdvanceAutoFrame);
  end;
end;
{ @end $480870 }

{ @routine $480B08 TgaiGI_GetSequenceCount }
function TgaiGI.GetSequenceCount: Integer;
var Image: TCGaiEC;
begin
  if FirstFrameOnly then
  begin
    Result := 0;
    Exit;
  end;
  Image := AcquireCachedGai(MainImageCache);
  try
    Result := Image.GetSequenceCount;
  finally
    MainImageCache.Release;
  end;
end;
{ @end $480B08 }

{ @routine $480B78 TgaiGI_GetSequenceFrameSourceIndex }
function TgaiGI.GetSequenceFrameSourceIndex(FrameInSequence: Integer): Integer;
begin
  Result := ReadIntegerEC(AddPointerOffset(SequenceFrameIndexTable, FrameInSequence * SizeOf(Integer)));
end;
{ @end $480B78 }

{ @routine $480BB0 TgaiGI_SetFrameDelay }
procedure TgaiGI.SetFrameDelay(FrameInSequence, DelayMs: Integer);
begin
  WriteInt32EC(AddPointerOffset(SequenceFrameDelayTable, FrameInSequence * SizeOf(Integer)), DelayMs);
end;
{ @end $480BB0 }

{ @routine $480BEC TgaiGI_GetFrameDelay }
function TgaiGI.GetFrameDelay(FrameInSequence: Integer): Integer;
begin
  Result := ReadIntegerEC(AddPointerOffset(SequenceFrameDelayTable, FrameInSequence * SizeOf(Integer)));
end;
{ @end $480BEC }

{ @routine $480C24 TgaiGI_HitTestPixel }
function TgaiGI.HitTestPixel(Point: TPoint): Boolean;
var Image: TCGaiEC; First: TCGiEC; Width, Height, Left, Right, X, Top, Bottom, Y: Integer; Pixel: Cardinal; Pixels: Pointer; Buffer: TGraphBufGR; Frame: TgiGR; Clip, Bounds, FirstBounds: TRect;
begin
  Result := False;
  Pixel := 0;
  Clip.TopLeft := Point;
  Clip.Right := Point.X + 1;
  Clip.Bottom := Point.Y + 1;
  Image := nil;
  First := nil;
  try
    if not FirstFrameOnly then Image := AcquireCachedGai(MainImageCache);
    if FirstFrameImageCache <> nil then First := AcquireCachedGi(FirstFrameImageCache);
    if Image <> nil then
    begin
      Width := Image.GetCanvasSize.X;
      Height := Image.GetCanvasSize.Y;
      if First <> nil then
      begin
        FirstBounds := First.Image.GetBoundsRect;
        UnionRect(Bounds, Image.GetBoundsRect, FirstBounds);
        if not CompareMem(@Bounds, @FirstBounds, SizeOf(TRect)) then RaiseWideMessage('TgaiGI.Draw Pos-Size');
        Width := FirstBounds.Right - FirstBounds.Left;
        Height := FirstBounds.Bottom - FirstBounds.Top;
        if First.Image.GetFormat <> 0 then RaiseWideMessage('TgaiGI.Draw Format gi not 0');
      end;
    end
    else if First <> nil then
    begin
      FirstBounds := First.Image.GetBoundsRect;
      Width := FirstBounds.Right - FirstBounds.Left;
      Height := FirstBounds.Bottom - FirstBounds.Top;
      if First.Image.GetFormat <> 0 then RaiseWideMessage('TgaiGI.Draw Format gi not 0');
    end
    else
    begin
      Width := 0;
      Height := 0;
    end;
  if ImageKindX = ikxLeftFill then
  begin
    Left := HitTestBounds.Left;
    Right := HitTestBounds.Right;
  end
  else if ImageKindX = ikxRightFill then
  begin
    Right := HitTestBounds.Right;
    Left := Right;
    while Left > Clip.Left do Dec(Left, Width);
  end
  else if ImageKindX = ikxLeft then
  begin
    Left := HitTestBounds.Left;
    Right := Left + Width;
  end
  else if ImageKindX = ikxRight then
  begin
    Right := HitTestBounds.Right;
    Left := Right - Width;
  end
  else if ImageKindX = ikxCenter then
  begin
    Left := (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - Width div 2;
    Right := Left + Width;
  end
  else begin Exit; end;
  if ImageKindY = ikyTopFill then
  begin
    Top := HitTestBounds.Top;
    Bottom := HitTestBounds.Bottom;
  end
  else if ImageKindY = ikyBottomFill then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom;
    while Top > Clip.Top do Dec(Top, Height);
  end
  else if ImageKindY = ikyTop then
  begin
    Top := HitTestBounds.Top;
    Bottom := Top + Height;
  end
  else if ImageKindY = ikyBottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom - Height;
  end
  else if ImageKindY = ikyCenter then
  begin
    Top := (HitTestBounds.Bottom - HitTestBounds.Top) div 2 + HitTestBounds.Top - Height div 2;
    Bottom := Top + Height;
  end
  else begin Exit; end;
    Pixels := AddPointerOffset(@Pixel, -(ScreenRenderBuffer.PitchBytes * Point.Y + Point.X * SizeOf(Word)));
    Buffer := TGraphBufGR.Create(False);
    Buffer.AttachPixels(1, 1, ScreenRenderBuffer.PitchBytes, Pixels);
    if Image <> nil then Bounds := Image.GetBoundsRect;
    if (Image <> nil) and (not Image.HasPlaybackFlags) then
    begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        Frame := Image.LoadFrameGi(GetSequenceFrameSourceIndex(SequenceFrame));
        Frame.DrawToGraphBuf(Buffer, X + Frame.GetBoundsRect.Left - Bounds.Left, Y + Frame.GetBoundsRect.Top - Bounds.Top, Clip, 0, 255);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
    end
    else if FirstFrameImageCache <> nil then
    begin
      if CachedPlaybackGraphBuf <> nil then
      begin
        if (CachedPlaybackGraphBuf.Width = Width) and (CachedPlaybackGraphBuf.Height = Height) then
        begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawAlphaGraphBuffer16Clipped(Buffer.GetPixels, Buffer.PitchBytes, X, Y, CachedPlaybackGraphBuf, Clip);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
        end;
      end;
    end;
    Buffer.Free;
  finally
    if Image <> nil then MainImageCache.Release;
    if First <> nil then FirstFrameImageCache.Release;
  end;
  Result := Pixel <> 0;
end;
{ @end $480C24 }

{ @routine $4811F8 TgaiGI_SetActive }
procedure TgaiGI.SetActive(Value: Boolean);
begin
  if Active <> Value then
  begin
    inherited SetActive(Value);
    if not Value then
    begin
  if AutoFrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := nil;
  end;
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
      Active := True;
      inherited Invalidate;
      Active := False;
    end
    else
    begin
      if not StopPlaybackRequested then RestartPlayback;
      inherited Invalidate;
    end;
  end;
end;
{ @end $4811F8 }

{ @routine $4812AC TgaiGI_OnDeactivate }
procedure TgaiGI.OnDeactivate;
begin
  if AutoFrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := nil;
  end;
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
  inherited OnDeactivate;
end;
{ @end $4812AC }

{ @routine $481310 TgaiGI_LoadFromConfigPath }
procedure TgaiGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadAnimationProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $481310 }

{ @routine $481344 TgaiGI_LoadFromBlock }
procedure TgaiGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadAnimationProperties(Block);
end;
{ @end $481344 }

{ @routine $48136C TgaiGI_LoadAnimationProperties }
procedure TgaiGI.LoadAnimationProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Image') > 0 then MainImageCache.SetCacheKey(Block.GetParam('Image'));
  if Block.CountParams('ImageFirst') > 0 then SetFirstFrameImagePath(Block.GetParam('ImageFirst'));
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('AlignX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('AlignX')));
  if Block.CountParams('AlignY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('AlignY')));
  if Block.CountParams('PBuf') > 0 then UsesPlaybackBuffer := ParseEnabledNameGI(Block.GetParam('PBuf'));
  if Block.CountParams('Stop') > 0 then StopPlaybackRequested := ParseEnabledNameGI(Block.GetParam('Stop'));
  if Block.CountParams('Frame') > 0 then LoadFrameSequenceFromText(Block.GetParam('Frame'));
  if Block.CountParams('FrameLoad') > 0 then SequenceIndex := StrToInt(Block.GetParam('FrameLoad'));
  if Block.CountParams('Auto') > 0 then AutoUpdateFlags := ParseAutoGeometryFlagsGI(Block.GetParam('Auto'));
  if Block.CountParams('TransColor') > 0 then TransparentColor := GetColorGI(Block.GetParam('TransColor'));
  if Block.CountParams('SkipImageUpdateRect') > 0 then SkipImageUpdateRect := ParseEnabledNameGI(Block.GetParam('SkipImageUpdateRect'));
  if Block.CountParams('StopAfterOneCycle') > 0 then StopAfterOneCycle := ParseEnabledNameGI(Block.GetParam('StopAfterOneCycle'));
  if Block.CountParams('SoundStart') > 0 then
  begin
    StartSoundName := Block.GetParam('SoundStart');
  if AutoFrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := nil;
  end;
  end;
end;
{ @end $48136C }

{ @routine $481840 TgaiGI_UpdateAutoGeometry }
procedure TgaiGI.UpdateAutoGeometry;
var Image: TCGaiEC;
begin
  inherited UpdateAutoGeometry;
  if (AutoUpdateFlags and agfPosition) = agfPosition then SetPosition(Parent.ToLocalPoint(GetContentOrigin));
  if (AutoUpdateFlags and agfSize) = agfSize then SetSize(GetContentSize);
  if SequenceIndex >= 0 then
  begin
    ClearFrameSequence;
    if (not FirstFrameOnly) and (MainImageCache <> nil) and (MainImageCache.CacheKey <> '') then
    begin
      Image := AcquireCachedGai(MainImageCache);
      try
        if (SequenceIndex < 0) or (SequenceIndex >= Image.GetSequenceCount) then
        begin
          MainImageCache.Release;
          SequenceFrameCount := 0;
          AppendLogLineThreadSafe('TgaiGI.AfterLoad. Anim not found.');
          Exit;
        end;
        SequenceFrameCount := Image.GetSequenceFrameCount(SequenceIndex);
        SequenceFrameIndexTable := ReAllocFromHeapREC(GaiFrameHeap, SequenceFrameIndexTable, SequenceFrameCount * SizeOf(Integer));
        SequenceFrameDelayTable := ReAllocFromHeapREC(GaiFrameHeap, SequenceFrameDelayTable, SequenceFrameCount * SizeOf(Integer));
        Image.FillSequenceFrameIndexTable(SequenceIndex, SequenceFrameIndexTable, SizeOf(Integer));
        Image.FillSequenceFrameDelayTable(SequenceIndex, SequenceFrameDelayTable, SizeOf(Integer));
      finally
        MainImageCache.Release;
      end;
    end;
  end;
end;
{ @end $481840 }

{ @routine $481A68 TgaiGI_SetOneCycleDuration }
procedure TgaiGI.SetOneCycleDuration(DurationMs: Integer);
var Index, Delay: Integer;
begin
  StopAfterOneCycle := True;
  if SequenceFrameDelayTable <> nil then
  begin
    Delay := Round(DurationMs / SequenceFrameCount);
    if Delay < 1 then Delay := 1;
    for Index := 0 to SequenceFrameCount - 1 do
      WriteInt32EC(AddPointerOffset(SequenceFrameDelayTable, Index * SizeOf(Integer)), Delay);
  end;
end;
{ @end $481A68 }

{ @routine $481AF8 TgaiGI_AdvanceAutoFrame }
procedure TgaiGI.AdvanceAutoFrame(Timer: PCallbackTimerGI; UserData: Integer);
var Wrapped: Boolean; Delay: Integer;
begin
  Wrapped := False;
  Inc(SequenceFrame);
  if Assigned(FrameAdvancedCallback) then FrameAdvancedCallback(Self);
  if SequenceFrame >= SequenceFrameCount then
  begin
    SequenceFrame := 0;
    if StartSoundName <> '' then SoundManager.PlaySound(StartSoundName);
    Wrapped := True;
  end;
  if StopPlaybackRequested then
  begin
  if AutoFrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := nil;
  end;
  end
  else if AutoFrameTimer = nil then
  begin
    Delay := GetFrameDelay(SequenceFrame);
    AutoFrameTimer := MessageLoop.ScheduleCallbackTimer(Delay, Delay, AdvanceAutoFrame);
  end
  else
  begin
    Delay := GetFrameDelay(SequenceFrame);
    MessageLoop.UpdateCallbackTimer(AutoFrameTimer, Delay, Delay);
  end;
  Invalidate;
  if Wrapped then
  begin
    if StopAfterOneCycle then
    begin
      StopAutoPlayback;
      SetActive(False);
    end;
    if Assigned(CycleCompleteCallback) then CycleCompleteCallback(Self);
  end;
end;
{ @end $481AF8 }

{ @routine $481C84 TgaiGI_Invalidate }
procedure TgaiGI.Invalidate;
var Image: TCGaiEC; First: TCGiEC; Width, Height, Left, Right, X, Top, Bottom, Y, FrameIndex, RectIndex, RectCount: Integer; Frame: TgiGR; Bounds, FirstBounds, Rect, Clip, FrameBounds: TRect;
begin
  if (not Active) or HardwareRenderingEnabled then Exit;
  if (not SkipImageUpdateRect) and (FirstFrameImageCache <> nil) and (not FirstFrameOnly) and UsesPlaybackBuffer then
  begin
  if (CachedPlaybackGraphBuf = nil) or (LastCachedFrameIndex < 0) or (SequenceFrame < LastCachedFrameIndex) then
  begin
    inherited Invalidate;
    Exit;
  end;
  if SequenceFrame <= LastCachedFrameIndex then Exit;
  Image := nil;
  First := nil;
  Clip := HitTestBounds;
  try
    Image := AcquireCachedGai(MainImageCache);
    First := AcquireCachedGi(FirstFrameImageCache);
    FirstBounds := First.Image.GetBoundsRect;
    UnionRect(Bounds, Image.GetBoundsRect, FirstBounds);
    if not CompareMem(@Bounds, @FirstBounds, SizeOf(TRect)) then RaiseWideMessage('TgaiGI.Update Pos-Size');
    Width := FirstBounds.Right - FirstBounds.Left;
    Height := FirstBounds.Bottom - FirstBounds.Top;
    if First.Image.GetFormat <> 0 then RaiseWideMessage('TgaiGI.Update Format gi not 0');
  if ImageKindX = ikxLeftFill then
  begin
    Left := HitTestBounds.Left;
    Right := HitTestBounds.Right;
  end
  else if ImageKindX = ikxRightFill then
  begin
    Right := HitTestBounds.Right;
    Left := Right;
    while Left > Clip.Left do Dec(Left, Width);
  end
  else if ImageKindX = ikxLeft then
  begin
    Left := HitTestBounds.Left;
    Right := Left + Width;
  end
  else if ImageKindX = ikxRight then
  begin
    Right := HitTestBounds.Right;
    Left := Right - Width;
  end
  else if ImageKindX = ikxCenter then
  begin
    Left := (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - Width div 2;
    Right := Left + Width;
  end
  else begin Exit; end;
  if ImageKindY = ikyTopFill then
  begin
    Top := HitTestBounds.Top;
    Bottom := HitTestBounds.Bottom;
  end
  else if ImageKindY = ikyBottomFill then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom;
    while Top > Clip.Top do Dec(Top, Height);
  end
  else if ImageKindY = ikyTop then
  begin
    Top := HitTestBounds.Top;
    Bottom := Top + Height;
  end
  else if ImageKindY = ikyBottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom - Height;
  end
  else if ImageKindY = ikyCenter then
  begin
    Top := (HitTestBounds.Bottom - HitTestBounds.Top) div 2 + HitTestBounds.Top - Height div 2;
    Bottom := Top + Height;
  end
  else begin Exit; end;
    Bounds := Image.GetBoundsRect;
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        FrameIndex := LastCachedFrameIndex + 1;
        if FrameIndex > SequenceFrame then FrameIndex := 0;
        while FrameIndex <= SequenceFrame do
        begin
          Frame := Image.LoadFrameGi(GetSequenceFrameSourceIndex(FrameIndex));
          if Frame <> nil then
          begin
            FrameBounds := Frame.GetBoundsRect;
            RectCount := Frame.GetClipRectCount;
            if RectCount < 1 then
            begin
              inherited Invalidate;
              Exit;
            end;
            for RectIndex := 0 to RectCount - 1 do
            begin
              Rect := Frame.GetClipRect(RectIndex);
              Rect.Left := X + Rect.Left + (FrameBounds.Left - Bounds.Left);
              Rect.Top := Y + Rect.Top + (FrameBounds.Top - Bounds.Top);
              Rect.Right := X + Rect.Right + (FrameBounds.Left - Bounds.Left);
              Rect.Bottom := Y + Rect.Bottom + (FrameBounds.Top - Bounds.Top);
              MessageLoop.QueueUpdateRect(Rect);
            end;
          end;
          Inc(FrameIndex);
        end;
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  finally
    if Image <> nil then MainImageCache.Release;
    if First <> nil then FirstFrameImageCache.Release;
  end;
  end
  else inherited Invalidate;
end;
{ @end $481C84 }

{ @routine $4821E0 TgaiGI_SetHardwareMirrorHorizontal }
procedure TgaiGI.SetHardwareMirrorHorizontal(Value: Boolean);
begin
  HardwareMirrorHorizontal := Value;
end;
{ @end $4821E0 }

{ @routine $4821FC TgaiGI_Draw }
procedure TgaiGI.Draw(ClipRect: TRect);
var Image: TCGaiEC; First: TCGiEC; Width, Height, Left, Right, X, Top, Bottom, Y, FrameIndex, FrameCount: Integer;
  Frame: TgiGR; Texture: IDirect3DTexture9; FrameOrigin: TPoint; Bounds, FirstBounds: TRect;
begin
  if SequenceFrame < 0 then Exit;
  if (SequenceFrame >= SequenceFrameCount) and (not FirstFrameOnly) then Exit;
  if (AutoFrameTimer = nil) and (not StopPlaybackRequested) then RestartPlayback;
  if (MainImageCache.CacheKey = '') and
    ((FirstFrameImageCache = nil) or (FirstFrameImageCache.CacheKey = '') or (not FirstFrameOnly)) then Exit;
  Image := nil;
  First := nil;
  try
    if not FirstFrameOnly then Image := AcquireCachedGai(MainImageCache);
    if FirstFrameImageCache <> nil then First := AcquireCachedGi(FirstFrameImageCache);
    if Image <> nil then
    begin
      Width := Image.GetCanvasSize.X;
      Height := Image.GetCanvasSize.Y;
      if First <> nil then
      begin
        FirstBounds := First.Image.GetBoundsRect;
        UnionRect(Bounds, Image.GetBoundsRect, FirstBounds);
        if not CompareMem(@Bounds, @FirstBounds, SizeOf(TRect)) then RaiseWideMessage('TgaiGI.Draw Pos-Size');
        Width := FirstBounds.Right - FirstBounds.Left;
        Height := FirstBounds.Bottom - FirstBounds.Top;
        if First.Image.GetFormat <> 0 then RaiseWideMessage('TgaiGI.Draw Format gi not 0');
      end;
    end
    else if First <> nil then
    begin
      FirstBounds := First.Image.GetBoundsRect;
      Width := FirstBounds.Right - FirstBounds.Left;
      Height := FirstBounds.Bottom - FirstBounds.Top;
      if First.Image.GetFormat <> 0 then RaiseWideMessage('TgaiGI.Draw Format gi not 0');
    end
    else
    begin
      Width := 0;
      Height := 0;
    end;
  if ImageKindX = ikxLeftFill then
  begin
    Left := HitTestBounds.Left;
    Right := HitTestBounds.Right;
  end
  else if ImageKindX = ikxRightFill then
  begin
    Right := HitTestBounds.Right;
    Left := Right;
    while Left > ClipRect.Left do Dec(Left, Width);
  end
  else if ImageKindX = ikxLeft then
  begin
    Left := HitTestBounds.Left;
    Right := Left + Width;
  end
  else if ImageKindX = ikxRight then
  begin
    Right := HitTestBounds.Right;
    Left := Right - Width;
  end
  else if ImageKindX = ikxCenter then
  begin
    Left := (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - Width div 2;
    Right := Left + Width;
  end
  else begin Exit; end;
  if ImageKindY = ikyTopFill then
  begin
    Top := HitTestBounds.Top;
    Bottom := HitTestBounds.Bottom;
  end
  else if ImageKindY = ikyBottomFill then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom;
    while Top > ClipRect.Top do Dec(Top, Height);
  end
  else if ImageKindY = ikyTop then
  begin
    Top := HitTestBounds.Top;
    Bottom := Top + Height;
  end
  else if ImageKindY = ikyBottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom - Height;
  end
  else if ImageKindY = ikyCenter then
  begin
    Top := (HitTestBounds.Bottom - HitTestBounds.Top) div 2 + HitTestBounds.Top - Height div 2;
    Bottom := Top + Height;
  end
  else begin Exit; end;
    if Image <> nil then Bounds := Image.GetBoundsRect
    else if First <> nil then Bounds := First.Image.GetBoundsRect;
    if (Image <> nil) and (not Image.HasPlaybackFlags) then
    begin
      if HardwareRenderingEnabled then
      begin
        Texture := Image.GetOrCreateFrameSurface(GetSequenceFrameSourceIndex(SequenceFrame));
        FrameOrigin := Image.GetFrameOrigin(GetSequenceFrameSourceIndex(SequenceFrame));
        if Texture <> nil then
        begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawTexture(Texture, FrameOrigin.X + X, FrameOrigin.Y + Y, Alpha, RgbWhite, @ClipRect, False, HardwareMirrorHorizontal);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
        end;
      end
      else
      begin
        Frame := Image.LoadFrameGi(GetSequenceFrameSourceIndex(SequenceFrame));
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        if Frame <> nil then Frame.DrawToGraphBuf(ScreenRenderBuffer, X + Frame.GetBoundsRect.Left - Bounds.Left, Y + Frame.GetBoundsRect.Top - Bounds.Top, ClipRect, 0, Alpha);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
      end;
    end
    else if (Image <> nil) and (not UsesPlaybackBuffer) then
    begin
      Y := Top;
      if HardwareRenderingEnabled then
      begin
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        FrameCount := GetSequenceFrameSourceIndex(SequenceFrame);
        for FrameIndex := 0 to FrameCount - 1 do
        begin
          Texture := Image.GetOrCreateFrameSurface(GetSequenceFrameSourceIndex(SequenceFrame));
          FrameOrigin := Image.GetFrameOrigin(GetSequenceFrameSourceIndex(SequenceFrame));
          DrawTexture(Texture, FrameOrigin.X + X, FrameOrigin.Y + Y, Alpha, RgbWhite, @ClipRect, False, HardwareMirrorHorizontal);
        end;
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
      end
      else
      begin
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        FrameCount := GetSequenceFrameSourceIndex(SequenceFrame);
        for FrameIndex := 0 to FrameCount - 1 do
        begin
          Frame := Image.LoadFrameGi(GetSequenceFrameSourceIndex(FrameIndex));
          if Frame <> nil then Frame.DrawToGraphBuf(ScreenRenderBuffer, X + Frame.GetBoundsRect.Left - Bounds.Left, Y + Frame.GetBoundsRect.Top - Bounds.Top, ClipRect, 0, Alpha);
        end;
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
      end;
    end
    else
    begin
      if FirstFrameImageCache <> nil then
      begin
        if (CachedPlaybackGraphBuf = nil) or (CachedPlaybackGraphBuf.Width <> Width) or (CachedPlaybackGraphBuf.Height <> Height) then
        begin
          LastCachedFrameIndex := -1;
          if CachedPlaybackGraphBuf = nil then CachedPlaybackGraphBuf := TGraphBufGR.Create(True);
          CachedPlaybackGraphBuf.AllocateRgba(Width, Height, Width * 4);
        end;
        if LastCachedFrameIndex <> SequenceFrame then
        begin
          FrameIndex := LastCachedFrameIndex + 1;
          if FrameIndex > SequenceFrame then FrameIndex := 0;
          if FrameIndex = 0 then
            CopyMemory(CachedPlaybackGraphBuf.GetPixels,
              AddPointerOffset(First.Image.Data, First.Image.GetPlane(0).DataOffset),
              CachedPlaybackGraphBuf.PitchBytes * CachedPlaybackGraphBuf.Height);
          if Image <> nil then
          begin
            while FrameIndex <= SequenceFrame do
            begin
              Frame := Image.LoadFrameGi(GetSequenceFrameSourceIndex(FrameIndex));
              if (Frame <> nil) and (Frame.GetContentSize.X > 0) and (Frame.GetContentSize.Y > 0) then
                Frame.DrawToGraphBuf(CachedPlaybackGraphBuf, Frame.GetBoundsRect.Left - Bounds.Left, Frame.GetBoundsRect.Top - Bounds.Top, Classes.Rect(0, 0, CachedPlaybackGraphBuf.Width, CachedPlaybackGraphBuf.Height), 0, Alpha);
              Inc(FrameIndex);
            end;
          end;
          LastCachedFrameIndex := SequenceFrame;
        end;
        Y := Top;
        if HardwareRenderingEnabled then
        begin
          Texture := CachedPlaybackGraphBuf.GetTexture;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawTexture(Texture, X, Y, Alpha, RgbWhite, @ClipRect, False, HardwareMirrorHorizontal);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
        end
        else
        begin
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawAlphaGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, CachedPlaybackGraphBuf, ClipRect);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
        end;
      end
      else if Image <> nil then
      begin
        if (CachedPlaybackGraphBuf = nil) or (CachedPlaybackGraphBuf.Width <> Width) or (CachedPlaybackGraphBuf.Height <> Height) then
        begin
          LastCachedFrameIndex := -1;
          if CachedPlaybackGraphBuf = nil then CachedPlaybackGraphBuf := TGraphBufGR.Create(True);
          if HardwareRenderingEnabled then CachedPlaybackGraphBuf.AllocateRgba(Width, Height, Width * 4)
          else CachedPlaybackGraphBuf.AllocateNative(Width, Height);
        end;
        if LastCachedFrameIndex <> SequenceFrame then
        begin
          FrameIndex := LastCachedFrameIndex + 1;
          if FrameIndex > SequenceFrame then FrameIndex := 0;
          if (FrameIndex = 0) and (not HardwareRenderingEnabled) then CachedPlaybackGraphBuf.FillPixels16(TransparentColor);
          while FrameIndex <= SequenceFrame do
          begin
            Frame := Image.LoadFrameGi(GetSequenceFrameSourceIndex(FrameIndex));
            if Frame <> nil then
            begin
              if HardwareRenderingEnabled then
                Frame.DecodeToPixels(AddPointerOffset(CachedPlaybackGraphBuf.GetPixels,
                  (Frame.GetBoundsRect.Top - Bounds.Top) * CachedPlaybackGraphBuf.PitchBytes + (Frame.GetBoundsRect.Left - Bounds.Left) * 4),
                  CachedPlaybackGraphBuf.PitchBytes, CachedPlaybackGraphBuf.Width, CachedPlaybackGraphBuf.Height, False)
              else Frame.DrawToGraphBuf(CachedPlaybackGraphBuf, Frame.GetBoundsRect.Left - Bounds.Left, Frame.GetBoundsRect.Top - Bounds.Top, Classes.Rect(0, 0, CachedPlaybackGraphBuf.Width, CachedPlaybackGraphBuf.Height), 0, Alpha);
            end;
            Inc(FrameIndex);
          end;
          LastCachedFrameIndex := SequenceFrame;
        end;
        Y := Top;
        if HardwareRenderingEnabled then
        begin
          Texture := CachedPlaybackGraphBuf.GetTexture;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawTexture(Texture, X, Y, Alpha, RgbWhite, @ClipRect, False, HardwareMirrorHorizontal);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
        end
        else
        begin
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        CopyTransparentGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, CachedPlaybackGraphBuf, ClipRect, TransparentColor);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
        end;
      end;
    end;
  finally
    if Image <> nil then MainImageCache.Release;
    if First <> nil then FirstFrameImageCache.Release;
  end;
end;
{ @end $4821FC }

{ @routine $4830DC TgaiGI_PrimeImageCaches }
procedure TgaiGI.PrimeImageCaches;
begin
  if (MainImageCache <> nil) and (not FirstFrameOnly) and (MainImageCache.CacheKey <> '') then
  begin
    AcquireCachedGai(MainImageCache);
    MainImageCache.Release;
  end;
  if (FirstFrameImageCache <> nil) and (FirstFrameImageCache.CacheKey <> '') then
  begin
    AcquireCachedGi(FirstFrameImageCache);
    FirstFrameImageCache.Release;
  end;
end;
{ @end $4830DC }

{ @routine $48316C TgaiGI_QueueImageLoad }
procedure TgaiGI.QueueImageLoad(PendingLoads: TList);
begin
  MainImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $48316C }

{ @routine $483190 LoadGaiFrameToGraphBuf }
procedure LoadGaiFrameToGraphBuf(const Path: WideString; GraphBuf: TGraphBufGR; Seed: Cardinal);
var
  Control: TCacheControlEC;
  Gai: TCGaiEC;
  FrameIndex: Integer;
begin
  Control := TCGaiControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(Path);
  Gai := AcquireCachedGai(Control);
  try
    FrameIndex := 0;
    if Seed <> 0 then FrameIndex := SeededRandomIntRange(0, Gai.GetFrameCount - 1, Seed);
    Gai.LoadFrameGi(FrameIndex).DecodeToGraphBuf(GraphBuf, False);
  finally
    Control.Release;
  end;
  Control.Free;
end;
{ @end $483190 }

end.
