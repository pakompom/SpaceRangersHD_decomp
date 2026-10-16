unit GI_GAI;

interface

uses Types, GR_GraphBuf, GI_Main, EC_CacheGI, EC_CacheGAI, EC_BlockPar, Classes, GI_MessageLoop;

const
  SingleFrameAnimationSpec = '[50,0-0]'; // Frame zero with a 50 ms delay.

type
  TgaiGI = class(TObjectGI) // @size 0x17C @methodorder source
  public
    procedure Clear; override; // @addr 0x0049644C @note "Preserves animation state."
    procedure SetSize(Size: TPoint); override; // @addr 0x00496928
    procedure SetActive(Value: Boolean); override; // @addr 0x004971DC
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x00497294
    procedure OnDeactivate; override; // @addr 0x00497254
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004972C0
    procedure UpdateAutoGeometry; override; // @addr 0x00497764 @note "Also rebuilds frame tables when SequenceIndex is nonnegative."
  public
    MainImageCache: TCGaiControlEC; // @offset 0x120
    FirstFrameImageCache: TCGiControlEC; // @offset 0x124
    AutoFrameTimer: TCallbackTimerIdGI; // @offset 0x128
    ImageKindX: TImageKindXGI; // @offset 0x12C
    ImageKindY: TImageKindYGI; // @offset 0x12D
    Alpha: Byte; // @offset 0x12E

    constructor Create(Owner: TObjectGI); // @addr 0x004962CC
    destructor Destroy; override; // @addr 0x004963C0
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x00496454 @note "Resets sequence position even when the key is unchanged."
    function GetImagePath: WideString; // @addr 0x004964A8
    procedure SetFirstFrameImagePath(const ImagePath: WideString); // @addr 0x004964C4
    function GetFirstFrameImagePath: WideString; // @addr $496544
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x00498DC4
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

    procedure Invalidate; override; // @addr 0x00497B14
    procedure SetHardwareMirrorHorizontal(Value: Boolean); // @addr $498004
    procedure Draw(ClipRect: TRect); override; // @addr 0x0049800C
    procedure SetSequenceFrame(FrameInSequence: Integer); // @addr 0x0049656C @note "Does not validate the index."
    procedure SetFramePosition(FrameInSequence: Integer; ForwardOnly: Boolean); // @addr 0x00496598 @note "Accepted out-of-range positions become zero."
    function GetMainImageFrameCount: Integer; // @addr 0x004965DC @note "Returns zero in FirstFrameOnly mode."
    procedure StopAutoPlayback; // @addr 0x00496648
    procedure RestartPlayback; // @addr 0x00496670 @note "Does not reset frame position; single-frame sequences remain timer-free."
    function GetContentSize: TPoint; // @addr 0x004966F8
    function GetContentOrigin: TPoint; // @addr 0x004967E0
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x004968E0
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x004968F8
    procedure SetAlpha(Value: Byte); // @addr 0x00496910
    procedure ClearFrameSequence; // @addr 0x00496940
    procedure LoadFrameSequenceFromText(const FrameSpec: WideString); // @addr 0x00496994 @note "Accepts ascending and descending ranges; changes the playback timer unless stopped."
    function GetSequenceCount: Integer; // @addr 0x00496BD0
    function GetSequenceFrameSourceIndex(FrameInSequence: Integer): Integer; // @addr 0x00496C3C @note "Does not validate the index."
    procedure SetFrameDelay(FrameInSequence, DelayMs: Integer); // @addr 0x00496C64 @note "Does not validate the index."
    function GetFrameDelay(FrameInSequence: Integer): Integer; // @addr 0x00496C94 @note "Does not validate the index."
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x00496CBC @note "Black pixels do not count as hits; composed playback may require an existing composition buffer."
    procedure LoadAnimationProperties(Block: TBlockParEC); // @addr 0x004972DC
    procedure SetOneCycleDuration(DurationMs: Integer); // @addr 0x00497980 @note "Enables StopAfterOneCycle; frame delays are rounded to milliseconds with a minimum of one."
    procedure AdvanceAutoFrame(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x004979F8
    procedure PrimeImageCaches; // @addr 0x00498D64 @note "Skips the main GAI in FirstFrameOnly mode."
  end;

var
  GaiFrameHeap: Cardinal = 0; // @addr 0x0080B704

procedure LoadGaiFrameToGraphBuf(const Path: WideString; GraphBuf: TGraphBufGR; Seed: Cardinal); // @addr $498DD0

implementation

uses GR_Sound, EC_Struct, Direct3D9, GR_DX, GR_gi, GR_Main, EC_Cache, EC_Str, EC_Mem, SysUtils, Windows, aMyFunction, GlobalsV;


{ @routine $4962CC TgaiGI_Create }
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
  ImageKindX := image_x_center;
  ImageKindY := image_y_center;
  StopPlaybackRequested := False;
  StopAfterOneCycle := False;
  SequenceIndex := -1;
  TransparentColor := 0;
  SkipImageUpdateRect := False;
end;
{ @end $4962CC }

{ @routine $4963C0 TgaiGI_Destroy }
destructor TgaiGI.Destroy;
begin
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
  if AutoFrameTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := 0;
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
{ @end $4963C0 }

{ @routine $49644C TgaiGI_Clear }
procedure TgaiGI.Clear;
begin
  inherited Clear;
end;
{ @end $49644C }

{ @routine $496454 TgaiGI_SetImagePath }
procedure TgaiGI.SetImagePath(const ImagePath: WideString);
begin
  SequenceFrame := 0;
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
  if MainImageCache.CacheKey = ImagePath then Exit;
  Invalidate;
  MainImageCache.SetCacheKey(ImagePath);
end;
{ @end $496454 }

{ @routine $4964A8 TgaiGI_GetImagePath }
function TgaiGI.GetImagePath: WideString;
begin
  Result := MainImageCache.CacheKey;
end;
{ @end $4964A8 }

{ @routine $4964C4 TgaiGI_SetFirstFrameImagePath }
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
  if FirstFrameImageCache.CacheKey = ImagePath then Exit;
  Invalidate;
  FirstFrameImageCache.SetCacheKey(ImagePath);
end;
{ @end $4964C4 }

{ @routine $496544 TgaiGI_GetFirstFrameImagePath }
function TgaiGI.GetFirstFrameImagePath: WideString;
begin
  if FirstFrameImageCache = nil then Result := ''
  else Result := FirstFrameImageCache.CacheKey;
end;
{ @end $496544 }

{ @routine $49656C TgaiGI_SetSequenceFrame }
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
{ @end $49656C }

{ @routine $496598 TgaiGI_SetFramePosition }
procedure TgaiGI.SetFramePosition(FrameInSequence: Integer; ForwardOnly: Boolean);
begin
  if SequenceFrame = FrameInSequence then Exit;
  if (FrameInSequence <= SequenceFrame) and ForwardOnly then Exit;
  SequenceFrame := FrameInSequence;
  if (SequenceFrame < 0) or (SequenceFrame >= SequenceFrameCount) then
    SequenceFrame := 0;
  Invalidate;
end;
{ @end $496598 }

{ @routine $4965DC TgaiGI_GetMainImageFrameCount }
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
{ @end $4965DC }

{ @routine $496648 TgaiGI_StopAutoPlayback }
procedure TgaiGI.StopAutoPlayback;
begin
  StopPlaybackRequested := True;
  if AutoFrameTimer = 0 then Exit;
  MessageLoop.CancelCallbackTimer(AutoFrameTimer);
  AutoFrameTimer := 0;
end;
{ @end $496648 }

{ @routine $496670 TgaiGI_RestartPlayback }
procedure TgaiGI.RestartPlayback;
var Delay: Integer;
begin
  StopPlaybackRequested := False;
  if AutoFrameTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := 0;
  end;
  if SequenceFrameCount > 1 then
  begin
    Delay := GetFrameDelay(SequenceFrame);
    AutoFrameTimer := MessageLoop.ScheduleCallbackTimer(Delay, Delay, AdvanceAutoFrame);
  end;
  if (StartSoundName <> '') and (SequenceFrame = 0) then SoundManager.PlaySound(StartSoundName);
end;
{ @end $496670 }

{ @routine $4966F8 TgaiGI_GetContentSize }
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
{ @end $4966F8 }

{ @routine $4967E0 TgaiGI_GetContentOrigin }
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
{ @end $4967E0 }

{ @routine $4968E0 TgaiGI_SetImageKindX }
procedure TgaiGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX = Value then Exit;
  ImageKindX := Value;
  Invalidate;
end;
{ @end $4968E0 }

{ @routine $4968F8 TgaiGI_SetImageKindY }
procedure TgaiGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY = Value then Exit;
  ImageKindY := Value;
  Invalidate;
end;
{ @end $4968F8 }

{ @routine $496910 TgaiGI_SetAlpha }
procedure TgaiGI.SetAlpha(Value: Byte);
begin
  if Alpha = Value then Exit;
  Alpha := Value;
  Invalidate;
end;
{ @end $496910 }

{ @routine $496928 TgaiGI_SetSize }
procedure TgaiGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
end;
{ @end $496928 }

{ @routine $496940 TgaiGI_ClearFrameSequence }
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
{ @end $496940 }

{ @routine $496994 TgaiGI_LoadFrameSequenceFromText }
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
  if AutoFrameTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := 0;
  end;
    AutoFrameTimer := MessageLoop.ScheduleCallbackTimer(TimerDelay, TimerDelay, AdvanceAutoFrame);
  end;
end;
{ @end $496994 }

{ @routine $496BD0 TgaiGI_GetSequenceCount }
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
{ @end $496BD0 }

{ @routine $496C3C TgaiGI_GetSequenceFrameSourceIndex }
function TgaiGI.GetSequenceFrameSourceIndex(FrameInSequence: Integer): Integer;
begin
  Result := ReadIntegerEC(AddPointerOffset(SequenceFrameIndexTable, FrameInSequence * SizeOf(Integer)));
end;
{ @end $496C3C }

{ @routine $496C64 TgaiGI_SetFrameDelay }
procedure TgaiGI.SetFrameDelay(FrameInSequence, DelayMs: Integer);
begin
  WriteInt32EC(AddPointerOffset(SequenceFrameDelayTable, FrameInSequence * SizeOf(Integer)), DelayMs);
end;
{ @end $496C64 }

{ @routine $496C94 TgaiGI_GetFrameDelay }
function TgaiGI.GetFrameDelay(FrameInSequence: Integer): Integer;
begin
  Result := ReadIntegerEC(AddPointerOffset(SequenceFrameDelayTable, FrameInSequence * SizeOf(Integer)));
end;
{ @end $496C94 }

{ @routine $496CBC TgaiGI_HitTestPixel }
function TgaiGI.HitTestPixel(Point: TPoint): Boolean;
var Image: TCGaiEC; First: TCGiEC; Width, Height, Left, Right, X, Top, Bottom, Y: Integer; Pixel: Cardinal; Pixels: Pointer; Buffer: TGraphBufGR; Frame: TgiGR; Clip, Bounds, FirstBounds: TRect;
begin
  Result := False;
  Pixel := 0;
  Clip.Left := Point.X;
  Clip.Top := Point.Y;
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
    if ImageKindX = image_x_tile_left then
    begin
      Left := HitTestBounds.Left;
      Right := HitTestBounds.Right;
    end
    else if ImageKindX = image_x_tile_right then
    begin
      Right := HitTestBounds.Right;
      Left := Right;
      while Left > Clip.Left do Dec(Left, Width);
    end
    else if ImageKindX = image_x_left then
    begin
      Left := HitTestBounds.Left;
      Right := Left + Width;
    end
    else if ImageKindX = image_x_right then
    begin
      Right := HitTestBounds.Right;
      Left := Right - Width;
    end
    else if ImageKindX = image_x_center then
    begin
      Left := (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - Width div 2;
      Right := Left + Width;
    end
    else begin Exit; end;
    if ImageKindY = image_y_tile_top then
    begin
      Top := HitTestBounds.Top;
      Bottom := HitTestBounds.Bottom;
    end
    else if ImageKindY = image_y_tile_bottom then
    begin
      Bottom := HitTestBounds.Bottom;
      Top := Bottom;
      while Top > Clip.Top do Dec(Top, Height);
    end
    else if ImageKindY = image_y_top then
    begin
      Top := HitTestBounds.Top;
      Bottom := Top + Height;
    end
    else if ImageKindY = image_y_bottom then
    begin
      Bottom := HitTestBounds.Bottom;
      Top := Bottom - Height;
    end
    else if ImageKindY = image_y_center then
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
    else if (FirstFrameImageCache <> nil) and (CachedPlaybackGraphBuf <> nil) and
      (Integer(CachedPlaybackGraphBuf.Width) = Width) and (Integer(CachedPlaybackGraphBuf.Height) = Height) then
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
    Buffer.Free;
  finally
    if Image <> nil then MainImageCache.Release;
    if First <> nil then FirstFrameImageCache.Release;
  end;
  Result := Pixel <> 0;
end;
{ @end $496CBC }

{ @routine $4971DC TgaiGI_SetActive }
procedure TgaiGI.SetActive(Value: Boolean);
begin
  if Active = Value then Exit;
  inherited SetActive(Value);
  if not Value then
  begin
    if AutoFrameTimer <> 0 then
    begin
      MessageLoop.CancelCallbackTimer(AutoFrameTimer);
      AutoFrameTimer := 0;
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
{ @end $4971DC }

{ @routine $497254 TgaiGI_OnDeactivate }
procedure TgaiGI.OnDeactivate;
begin
  if AutoFrameTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := 0;
  end;
  if CachedPlaybackGraphBuf <> nil then
  begin
    CachedPlaybackGraphBuf.Free;
    CachedPlaybackGraphBuf := nil;
  end;
  inherited OnDeactivate;
end;
{ @end $497254 }

{ @routine $497294 TgaiGI_LoadFromConfigPath }
procedure TgaiGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadAnimationProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $497294 }

{ @routine $4972C0 TgaiGI_LoadFromBlock }
procedure TgaiGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadAnimationProperties(Block);
end;
{ @end $4972C0 }

{ @routine $4972DC TgaiGI_LoadAnimationProperties }
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
  if AutoFrameTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := 0;
  end;
  end;
end;
{ @end $4972DC }

{ @routine $497764 TgaiGI_UpdateAutoGeometry }
procedure TgaiGI.UpdateAutoGeometry;
var Image: TCGaiEC;
begin
  inherited UpdateAutoGeometry;
  if (AutoUpdateFlags and auto_position) = auto_position then SetPosition(Parent.ToLocalPoint(GetContentOrigin));
  if (AutoUpdateFlags and auto_size) = auto_size then SetSize(GetContentSize);
  if SequenceIndex < 0 then Exit;
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
{ @end $497764 }

{ @routine $497980 TgaiGI_SetOneCycleDuration }
procedure TgaiGI.SetOneCycleDuration(DurationMs: Integer);
var Index, Delay: Integer;
begin
  StopAfterOneCycle := True;
  if SequenceFrameDelayTable = nil then Exit;
  Delay := Round(DurationMs / SequenceFrameCount);
  if Delay < 1 then Delay := 1;
  for Index := 0 to SequenceFrameCount - 1 do
    WriteInt32EC(AddPointerOffset(SequenceFrameDelayTable, Index * SizeOf(Integer)), Delay);
end;
{ @end $497980 }

{ @routine $4979F8 TgaiGI_AdvanceAutoFrame }
procedure TgaiGI.AdvanceAutoFrame(Timer: TCallbackTimerIdGI; UserData: Cardinal);
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
  if AutoFrameTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AutoFrameTimer);
    AutoFrameTimer := 0;
  end;
  end
  else if AutoFrameTimer = 0 then
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
  if not Wrapped then Exit;
  if StopAfterOneCycle then
  begin
    StopAutoPlayback;
    SetActive(False);
  end;
  if Assigned(CycleCompleteCallback) then CycleCompleteCallback(Self);
end;
{ @end $4979F8 }

{ @routine $497B14 TgaiGI_Invalidate }
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
  if ImageKindX = image_x_tile_left then
  begin
    Left := HitTestBounds.Left;
    Right := HitTestBounds.Right;
  end
  else if ImageKindX = image_x_tile_right then
  begin
    Right := HitTestBounds.Right;
    Left := Right;
    while Left > Clip.Left do Dec(Left, Width);
  end
  else if ImageKindX = image_x_left then
  begin
    Left := HitTestBounds.Left;
    Right := Left + Width;
  end
  else if ImageKindX = image_x_right then
  begin
    Right := HitTestBounds.Right;
    Left := Right - Width;
  end
  else if ImageKindX = image_x_center then
  begin
    Left := (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - Width div 2;
    Right := Left + Width;
  end
  else begin Exit; end;
  if ImageKindY = image_y_tile_top then
  begin
    Top := HitTestBounds.Top;
    Bottom := HitTestBounds.Bottom;
  end
  else if ImageKindY = image_y_tile_bottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom;
    while Top > Clip.Top do Dec(Top, Height);
  end
  else if ImageKindY = image_y_top then
  begin
    Top := HitTestBounds.Top;
    Bottom := Top + Height;
  end
  else if ImageKindY = image_y_bottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom - Height;
  end
  else if ImageKindY = image_y_center then
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
{ @end $497B14 }

{ @routine $498004 TgaiGI_SetHardwareMirrorHorizontal }
procedure TgaiGI.SetHardwareMirrorHorizontal(Value: Boolean);
begin
  HardwareMirrorHorizontal := Value;
end;
{ @end $498004 }

{ @routine $49800C TgaiGI_Draw }
procedure TgaiGI.Draw(ClipRect: TRect);
var Image: TCGaiEC; First: TCGiEC; Width, Height, Left, Right, X, Top, Bottom, Y, FrameIndex, FrameCount: Integer;
  Frame: TgiGR; Texture: IDirect3DTexture9; FrameOrigin: TPoint; Bounds, FirstBounds: TRect;
begin
  if SequenceFrame < 0 then Exit;
  if (SequenceFrame >= SequenceFrameCount) and (not FirstFrameOnly) then Exit;
  if (AutoFrameTimer = 0) and (not StopPlaybackRequested) then RestartPlayback;
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
  if ImageKindX = image_x_tile_left then
  begin
    Left := HitTestBounds.Left;
    Right := HitTestBounds.Right;
  end
  else if ImageKindX = image_x_tile_right then
  begin
    Right := HitTestBounds.Right;
    Left := Right;
    while Left > ClipRect.Left do Dec(Left, Width);
  end
  else if ImageKindX = image_x_left then
  begin
    Left := HitTestBounds.Left;
    Right := Left + Width;
  end
  else if ImageKindX = image_x_right then
  begin
    Right := HitTestBounds.Right;
    Left := Right - Width;
  end
  else if ImageKindX = image_x_center then
  begin
    Left := (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - Width div 2;
    Right := Left + Width;
  end
  else begin Exit; end;
  if ImageKindY = image_y_tile_top then
  begin
    Top := HitTestBounds.Top;
    Bottom := HitTestBounds.Bottom;
  end
  else if ImageKindY = image_y_tile_bottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom;
    while Top > ClipRect.Top do Dec(Top, Height);
  end
  else if ImageKindY = image_y_top then
  begin
    Top := HitTestBounds.Top;
    Bottom := Top + Height;
  end
  else if ImageKindY = image_y_bottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom - Height;
  end
  else if ImageKindY = image_y_center then
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
        if (CachedPlaybackGraphBuf = nil) or (Integer(CachedPlaybackGraphBuf.Width) <> Width) or (Integer(CachedPlaybackGraphBuf.Height) <> Height) then
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
        if (CachedPlaybackGraphBuf = nil) or (Integer(CachedPlaybackGraphBuf.Width) <> Width) or (Integer(CachedPlaybackGraphBuf.Height) <> Height) then
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
{ @end $49800C }

{ @routine $498D64 TgaiGI_PrimeImageCaches }
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
{ @end $498D64 }

{ @routine $498DC4 TgaiGI_QueueImageLoad }
procedure TgaiGI.QueueImageLoad(PendingLoads: TList);
begin
  MainImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $498DC4 }

{ @routine $498DD0 LoadGaiFrameToGraphBuf }
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
{ @end $498DD0 }

end.
