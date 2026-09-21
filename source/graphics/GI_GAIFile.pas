unit GI_GAIFile;
// Unit bracket (inferred): .text 0x004989A4..0x0049A538; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.


interface

uses EC_BlockPar, EC_File, EC_Thread, GI_Main, GI_MessageLoop, GR_GI, GR_GraphBuf, SyncObjs, Types;

type
  TGAIFileGI = class;
  TGAIFileThreadGI = class(TThreadEC) // @size $30
  public
    Owner: TGAIFileGI; // @offset $2C
    procedure Execute; override; // @addr $498B28
  end;

  TGAIFileGI = class(TObjectGI) // @size $1A8
  public
    ImageFile: TFileEC; // @offset $120
    Header: TGaiHeader; // @offset $124
    FrameDirectory: Pointer; // @offset $154
    FrameBuffers: Pointer; // @offset $158
    LoaderThread: TGAIFileThreadGI; // @offset $15C
    FrameLock: TCriticalSection; // @offset $160
    PreloadCount: Integer; // @offset $164
    FrameImage: TgiGR; // @offset $168
    FrameTimer: PCallbackTimerGI; // @offset $16C
    ImageKindX: TImageKindXGI; // @offset $170
    ImageKindY: TImageKindYGI; // @offset $171
    CurrentFrame: Integer; // @offset $174
    SequenceFrameCount: Integer; // @offset $178
    SequenceFrames: Pointer; // @offset $17C
    FrameDelays: Pointer; // @offset $180
    UsePlaybackBuffer: Boolean; // @offset $184
    PlaybackBuffer: TGraphBufGR; // @offset $188
    LastBufferedFrame: Integer; // @offset $18C
    TransparentColor: Cardinal; // @offset $190
    CycleCompleteCallback: TObjectNotifyEventGI; // @offset $198
    Stopped: Boolean; // @offset $1A0
    AutoUpdateFlags: Cardinal; // @offset $1A4
    constructor Create(Owner: TObjectGI); // @addr $498D88
    destructor Destroy; override; // @addr $498E78
    procedure Clear; override; // @addr $498FE0
    procedure OpenImage; // @addr $498FFC
    procedure CloseImage; // @addr $4990A8
    function GetFrameData(FrameIndex: Integer): Pointer; // @addr $4991B8
    procedure TrimFrameCache; // @addr $499358
    function GetFrameCount: Integer; // @addr $499498
    function GetContentSize: TPoint; // @addr $499520
    function GetContentOrigin: TPoint; // @addr $4995BC
    procedure SetImageKindX(Value: TImageKindXGI); // @addr $499658
    procedure SetImageKindY(Value: TImageKindYGI); // @addr $499690
    procedure SetSize(Size: TPoint); override; // @addr $4996C8
    procedure SetFrameSequence(Sequence: WideString); // @addr $4996EC
    function GetSequenceFrame(Index: Integer): Integer; // @addr $4999E4
    function GetFrameDelay(Index: Integer): Integer; // @addr $499A1C
    procedure OnDeactivate; override; // @addr $499A54
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $499A94
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $499AC8
    procedure LoadImageProperties(Block: TBlockParEC); // @addr $499AF0
    procedure UpdateAutoGeometry; override; // @addr $499DE0
    procedure AdvanceFrame(Timer: PCallbackTimerGI; UserData: Integer); // @addr $499E54
    procedure Draw(ClipRect: TRect); override; // @addr $499F58
  end;

implementation

uses Windows, Classes, EC_Mem, EC_Str, GR_Main, EC_Struct;

function ReadGaiFrameSize(const Directory: Pointer; const Index: Integer): Cardinal; inline;
begin
  Result := ReadDWordEC(AddPointerOffset(Directory,
    Integer(@PGaiFrameEntry(Index * SizeOf(TGaiFrameEntry)).DataSize)));
end;

{ @routine $498B28 TGAIFileThreadGI_Execute }
procedure TGAIFileThreadGI.Execute;
var Index, Count, SourceFrame: Integer; Data: Pointer;
begin
  while not IsStopRequested do
  begin
    Count := 0;
    for Index := 0 to Owner.Header.FrameCount - 1 do
      if ReadDWordEC(AddPointerOffset(Owner.FrameBuffers, Index * SizeOf(Pointer))) > 0 then Inc(Count);
    if Count >= Owner.PreloadCount then Break;
    Owner.FrameLock.Enter;
    Index := Owner.CurrentFrame;
    Owner.FrameLock.Leave;
    Count := 0;
    while Count < Owner.GetFrameCount do
    begin
      if ReadDWordEC(AddPointerOffset(Owner.FrameBuffers, Owner.GetSequenceFrame(Index) * SizeOf(Pointer))) = 0 then Break;
      Inc(Index);
      if Index >= Owner.GetFrameCount then Index := 0;
      Inc(Count);
    end;
    if Count >= Owner.GetFrameCount then Break;
    SourceFrame := Owner.GetSequenceFrame(Index);
    if IsStopRequested then Break;
    Data := AllocEC(ReadGaiFrameSize(Owner.FrameDirectory, SourceFrame));
    Owner.ImageFile.SetPointer(ReadDWordEC(AddPointerOffset(Owner.FrameDirectory, SourceFrame * SizeOf(TGaiFrameEntry))), FILE_BEGIN);
    Owner.ImageFile.ReadBuffer(Data, ReadGaiFrameSize(Owner.FrameDirectory, SourceFrame));
    PrepareRawGiColorCache(Data);
    if IsStopRequested then
    begin
      FreeEC(Data);
      Exit;
    end;
    Owner.FrameLock.Enter;
    WriteIntegerEC(AddPointerOffset(Owner.FrameBuffers, SourceFrame * SizeOf(Pointer)), Integer(Data));
    Owner.FrameLock.Leave;
  end;
end;
{ @end $498B28 }

{ @routine $498D88 TGAIFileGI_Create }
constructor TGAIFileGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  FrameLock := TCriticalSection.Create;
  FrameImage := TgiGR.Create;
  ImageFile := TFileEC.Create;
  LoaderThread := TGAIFileThreadGI.Create;
  LoaderThread.Owner := Self;
  LoaderThread.SetPriority(1);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  Stopped := False;
  PreloadCount := 10;
  TransparentColor := 0;
end;
{ @end $498D88 }

{ @routine $498E78 TGAIFileGI_Destroy }
destructor TGAIFileGI.Destroy;
begin
  CloseImage;
  if LoaderThread <> nil then
  begin
    LoaderThread.Free;
    LoaderThread := nil;
  end;
  if FrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(FrameTimer);
    FrameTimer := nil;
  end;
  if SequenceFrames <> nil then
  begin
    FreeEC(SequenceFrames);
    SequenceFrames := nil;
  end;
  if FrameDelays <> nil then
  begin
    FreeEC(FrameDelays);
    FrameDelays := nil;
  end;
  if ImageFile <> nil then
  begin
    ImageFile.Free;
    ImageFile := nil;
  end;
  if FrameImage <> nil then
  begin
    FrameImage.Free;
    FrameImage := nil;
  end;
  if FrameLock <> nil then
  begin
    FrameLock.Free;
    FrameLock := nil;
  end;
  if PlaybackBuffer <> nil then
  begin
    PlaybackBuffer.Free;
    PlaybackBuffer := nil;
  end;
  inherited Destroy;
end;
{ @end $498E78 }

{ @routine $498FE0 TGAIFileGI_Clear }
procedure TGAIFileGI.Clear;
begin
  CloseImage;
  inherited Clear;
end;
{ @end $498FE0 }

{ @routine $498FFC TGAIFileGI_OpenImage }
procedure TGAIFileGI.OpenImage;
begin
  CloseImage;
  ImageFile.AcquireReadHandle(False);
  ImageFile.ReadBuffer(@Header, SizeOf(Header));
  FrameDirectory := ReAllocREC(FrameDirectory, Header.FrameCount * SizeOf(TGaiFrameEntry));
  ImageFile.ReadBuffer(FrameDirectory, Header.FrameCount * SizeOf(TGaiFrameEntry));
  FrameBuffers := AllocClearEC(Header.FrameCount * SizeOf(Pointer));
  LoaderThread.Start;
end;
{ @end $498FFC }

{ @routine $4990A8 TGAIFileGI_CloseImage }
procedure TGAIFileGI.CloseImage;
var Data: Pointer; I: Integer;
begin
  if (LoaderThread <> nil) and LoaderThread.IsRunning then
  begin
    LoaderThread.RequestStop;
    LoaderThread.WaitForIdle($FFFFFFFF);
  end;
  if (ImageFile <> nil) and (ImageFile.OpenDepth > 0) then ImageFile.ReleaseHandle;
  if FrameDirectory <> nil then
  begin
    FreeEC(FrameDirectory);
    FrameDirectory := nil;
  end;
  if FrameBuffers <> nil then
  begin
    for I := 0 to Header.FrameCount - 1 do
    begin
      Data := Pointer(ReadDWordEC(AddPointerOffset(FrameBuffers, I * SizeOf(Pointer))));
      if Data <> nil then FreeEC(Data);
    end;
    FreeEC(FrameBuffers);
    FrameBuffers := nil;
  end;
end;
{ @end $4990A8 }

{ @routine $4991B8 TGAIFileGI_GetFrameData }
function TGAIFileGI.GetFrameData(FrameIndex: Integer): Pointer;
var Data: Pointer;
begin
  FrameLock.Enter;
  Data := Pointer(ReadDWordEC(AddPointerOffset(FrameBuffers, FrameIndex * SizeOf(Pointer))));
  FrameLock.Leave;
  if Data <> nil then
  begin
    Result := Data;
    Exit;
  end;
  if LoaderThread.IsRunning then
  begin
    LoaderThread.RequestStop;
    LoaderThread.WaitForIdle($FFFFFFFF);
  end;
  Data := Pointer(ReadDWordEC(AddPointerOffset(FrameBuffers, FrameIndex * SizeOf(Pointer))));
  if Data <> nil then
  begin
    Result := Data;
    Exit;
  end;
  begin
    Data := AllocEC(ReadGaiFrameSize(FrameDirectory, FrameIndex));
    ImageFile.SetPointer(ReadDWordEC(AddPointerOffset(FrameDirectory, FrameIndex * SizeOf(TGaiFrameEntry))), FILE_BEGIN);
    ImageFile.ReadBuffer(Data, ReadGaiFrameSize(FrameDirectory, FrameIndex));
    PrepareRawGiColorCache(Data);
    WriteIntegerEC(AddPointerOffset(FrameBuffers, FrameIndex * SizeOf(Pointer)), Integer(Data));
    LoaderThread.Start;
  end;
  Result := Data;
end;
{ @end $4991B8 }

{ @routine $499358 TGAIFileGI_TrimFrameCache }
procedure TGAIFileGI.TrimFrameCache;
var I, J, Index: Integer; Data: Pointer;
begin
  if LoaderThread.IsRunning then
  begin
    LoaderThread.RequestStop;
    LoaderThread.WaitForIdle($FFFFFFFF);
  end;
  if SequenceFrameCount > PreloadCount then
  begin
    for I := 0 to Header.FrameCount - 1 do
    begin
      Data := Pointer(ReadDWordEC(AddPointerOffset(FrameBuffers, I * SizeOf(Pointer))));
      if Data <> nil then
      begin
        Index := CurrentFrame;
        J := 0;
        while J < PreloadCount do
        begin
          if GetSequenceFrame(Index) = I then Break;
          Inc(Index);
          if Index >= SequenceFrameCount then Index := 0;
          Inc(J);
        end;
        if J >= PreloadCount then
        begin
          FreeEC(Data);
          WriteIntegerEC(AddPointerOffset(FrameBuffers, I * SizeOf(Pointer)), 0);
        end;
      end;
    end;
    LoaderThread.Start;
  end;
end;
{ @end $499358 }

{ @routine $499498 TGAIFileGI_GetFrameCount }
function TGAIFileGI.GetFrameCount: Integer;
begin
  if ImageFile.GetFileName = '' then Result := 0
  else
  begin
    if ImageFile.OpenDepth < 1 then OpenImage;
    Result := Header.FrameCount;
  end;
end;
{ @end $499498 }

{ @routine $499520 TGAIFileGI_GetContentSize }
function TGAIFileGI.GetContentSize: TPoint;
begin
  if ImageFile.GetFileName = '' then Result := Classes.Point(0, 0)
  else
  begin
    if ImageFile.OpenDepth < 1 then OpenImage;
    Result := SubtractPoints(Header.Bounds.BottomRight, Header.Bounds.TopLeft);
  end;
end;
{ @end $499520 }

{ @routine $4995BC TGAIFileGI_GetContentOrigin }
function TGAIFileGI.GetContentOrigin: TPoint;
begin
  if ImageFile.GetFileName = '' then Result := Classes.Point(0, 0)
  else
  begin
    if ImageFile.OpenDepth < 1 then OpenImage;
    Result := Header.Bounds.TopLeft;
  end;
end;
{ @end $4995BC }

{ @routine $499658 TGAIFileGI_SetImageKindX }
procedure TGAIFileGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $499658 }

{ @routine $499690 TGAIFileGI_SetImageKindY }
procedure TGAIFileGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $499690 }

{ @routine $4996C8 TGAIFileGI_SetSize }
procedure TGAIFileGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
end;
{ @end $4996C8 }

{ @routine $4996EC TGAIFileGI_SetFrameSequence }
procedure TGAIFileGI.SetFrameSequence(Sequence: WideString);
var Text: WideString; I, Count, J, FrameCount, Delay, First, Last: Integer;
begin
  if LoaderThread.IsRunning then
  begin
    LoaderThread.RequestStop;
    LoaderThread.WaitForIdle($FFFFFFFF);
  end;
  if SequenceFrames <> nil then
  begin
    FreeEC(SequenceFrames);
    SequenceFrames := nil;
  end;
  if FrameDelays <> nil then
  begin
    FreeEC(FrameDelays);
    FrameDelays := nil;
  end;
  CurrentFrame := 0;
  SequenceFrameCount := 0;
  Count := (CountDelimitedPartsW(Sequence, '[]') - 1) div 2;
  for I := 0 to Count - 1 do
  begin
    Text := ExtractDelimitedPartW(Sequence, I * 2 + 1, '[]');
    Delay := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ',-'));
    First := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 1, ',-'));
    Last := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 2, ',-'));
    FrameCount := Abs(First - Last) + 1;
    SequenceFrameCount := SequenceFrameCount + FrameCount;
    SequenceFrames := ReAllocREC(SequenceFrames, SequenceFrameCount * SizeOf(Integer));
    FrameDelays := ReAllocREC(FrameDelays, SequenceFrameCount * SizeOf(Integer));
    for J := 0 to FrameCount - 1 do
    begin
      WriteInt32EC(AddPointerOffset(SequenceFrames, (SequenceFrameCount - FrameCount + J) * SizeOf(Integer)), First);
      WriteInt32EC(AddPointerOffset(FrameDelays, (SequenceFrameCount - FrameCount + J) * SizeOf(Integer)), Delay);
      if First < Last then Inc(First) else Dec(First);
    end;
  end;
  if not Stopped then FrameTimer := MessageLoop.ScheduleCallbackTimer(GetFrameDelay(CurrentFrame), $FFFFFF, AdvanceFrame);
end;
{ @end $4996EC }

{ @routine $4999E4 TGAIFileGI_GetSequenceFrame }
function TGAIFileGI.GetSequenceFrame(Index: Integer): Integer;
begin
  Result := ReadIntegerEC(AddPointerOffset(SequenceFrames, Index * SizeOf(Integer)));
end;
{ @end $4999E4 }

{ @routine $499A1C TGAIFileGI_GetFrameDelay }
function TGAIFileGI.GetFrameDelay(Index: Integer): Integer;
begin
  Result := ReadIntegerEC(AddPointerOffset(FrameDelays, Index * SizeOf(Integer)));
end;
{ @end $499A1C }

{ @routine $499A54 TGAIFileGI_OnDeactivate }
procedure TGAIFileGI.OnDeactivate;
begin
  inherited OnDeactivate;
  CloseImage;
  if PlaybackBuffer <> nil then
  begin
    PlaybackBuffer.Free;
    PlaybackBuffer := nil;
  end;
end;
{ @end $499A54 }

{ @routine $499A94 TGAIFileGI_LoadFromConfigPath }
procedure TGAIFileGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $499A94 }

{ @routine $499AC8 TGAIFileGI_LoadFromBlock }
procedure TGAIFileGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $499AC8 }

{ @routine $499AF0 TGAIFileGI_LoadImageProperties }
procedure TGAIFileGI.LoadImageProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Image') > 0 then ImageFile.SetFileName(Block.GetParam('Image'));
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('AlignX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('AlignX')));
  if Block.CountParams('AlignY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('AlignY')));
  if Block.CountParams('PBuf') > 0 then UsePlaybackBuffer := ParseEnabledNameGI(Block.GetParam('PBuf'));
  if Block.CountParams('Stop') > 0 then Stopped := ParseEnabledNameGI(Block.GetParam('Stop'));
  if Block.CountParams('Frame') > 0 then SetFrameSequence(Block.GetParam('Frame'));
  if Block.CountParams('Auto') > 0 then AutoUpdateFlags := ParseAutoGeometryFlagsGI(Block.GetParam('Auto'));
  if Block.CountParams('TransColor') > 0 then TransparentColor := GetColorGI(Block.GetParam('TransColor'));
end;
{ @end $499AF0 }

{ @routine $499DE0 TGAIFileGI_UpdateAutoGeometry }
procedure TGAIFileGI.UpdateAutoGeometry;
begin
  if AutoUpdateFlags and agfPosition = agfPosition then SetPosition(Parent.ToLocalPoint(GetContentOrigin));
  if AutoUpdateFlags and agfSize = agfSize then SetSize(GetContentSize);
end;
{ @end $499DE0 }

{ @routine $499E54 TGAIFileGI_AdvanceFrame }
procedure TGAIFileGI.AdvanceFrame(Timer: PCallbackTimerGI; UserData: Integer);
begin
  FrameLock.Enter;
  Inc(CurrentFrame);
  if CurrentFrame >= SequenceFrameCount then
  begin
    CurrentFrame := 0;
    FrameLock.Leave;
    if Assigned(CycleCompleteCallback) then CycleCompleteCallback(Self);
  end else FrameLock.Leave;
  if FrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(FrameTimer);
    FrameTimer := nil;
  end;
  if not Stopped then FrameTimer := MessageLoop.ScheduleCallbackTimer(GetFrameDelay(CurrentFrame), $FFFFFF, AdvanceFrame);
  Invalidate;
end;
{ @end $499E54 }

{ @routine $499F58 TGAIFileGI_Draw }
procedure TGAIFileGI.Draw(ClipRect: TRect);
var Data: Pointer; Width, Height, StartX, EndX, X, StartY, EndY, Y, Frame, SourceFrame: Integer; Bounds: TRect;
begin
  if (CurrentFrame < 0) or (CurrentFrame >= SequenceFrameCount) then Exit;
  if ImageFile.GetFileName = '' then Exit;
  if ImageFile.OpenDepth < 1 then OpenImage;
  Width := GetContentSize.X;
  Height := GetContentSize.Y;
  if ImageKindX = ikxLeftFill then
  begin
        StartX := HitTestBounds.Left;
        EndX := HitTestBounds.Right;
  end
  else if ImageKindX = ikxRightFill then
  begin
        EndX := HitTestBounds.Right;
        StartX := EndX;
        while StartX > ClipRect.Left do StartX := StartX - Width;
  end
  else if ImageKindX = ikxLeft then
  begin
        StartX := HitTestBounds.Left;
        EndX := StartX + Width;
  end
  else if ImageKindX = ikxRight then
  begin
        EndX := HitTestBounds.Right;
        StartX := EndX - Width;
  end
  else if ImageKindX = ikxCenter then
  begin
        StartX := (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - Width div 2;
        EndX := StartX + Width;
  end
  else Exit;
  if ImageKindY = ikyTopFill then
  begin
        StartY := HitTestBounds.Top;
        EndY := HitTestBounds.Bottom;
  end
  else if ImageKindY = ikyBottomFill then
  begin
        EndY := HitTestBounds.Bottom;
        StartY := EndY;
        while StartY > ClipRect.Top do StartY := StartY - Height;
  end
  else if ImageKindY = ikyTop then
  begin
        StartY := HitTestBounds.Top;
        EndY := StartY + Height;
  end
  else if ImageKindY = ikyBottom then
  begin
        EndY := HitTestBounds.Bottom;
        StartY := EndY - Height;
  end
  else if ImageKindY = ikyCenter then
  begin
        StartY := (HitTestBounds.Bottom - HitTestBounds.Top) div 2 + HitTestBounds.Top - Height div 2;
        EndY := StartY + Height;
  end
  else Exit;
  Bounds := Header.Bounds;
  if Header.Flags = 0 then
  begin
    SourceFrame := GetSequenceFrame(CurrentFrame);
    Data := GetFrameData(SourceFrame);
    FrameImage.LoadRawGiBytes(Data, ReadGaiFrameSize(FrameDirectory, SourceFrame));
    TrimFrameCache;
    Y := StartY;
    while Y < EndY do
    begin
      X := StartX;
      while X < EndX do
      begin
        FrameImage.DrawToGraphBuf(ScreenRenderBuffer, X + FrameImage.GetBoundsRect.Left - Bounds.Left,
          Y + FrameImage.GetBoundsRect.Top - Bounds.Top, ClipRect, 0, 255);
        X := X + Width;
      end;
      Y := Y + Height;
    end;
  end else if UsePlaybackBuffer then
  begin
    if (PlaybackBuffer = nil) or (PlaybackBuffer.Width <> Width) or (PlaybackBuffer.Height <> Height) then
    begin
      LastBufferedFrame := -1;
      if PlaybackBuffer = nil then PlaybackBuffer := TGraphBufGR.Create(False);
      PlaybackBuffer.AllocateNative(Width, Height);
    end;
    if LastBufferedFrame <> CurrentFrame then
    begin
      Frame := LastBufferedFrame + 1;
      if Frame > CurrentFrame then Frame := 0;
      if Frame = 0 then PlaybackBuffer.FillPixels16(TransparentColor);
      while Frame <= CurrentFrame do
      begin
        SourceFrame := GetSequenceFrame(Frame);
        Data := GetFrameData(SourceFrame);
        FrameImage.LoadRawGiBytes(Data, ReadGaiFrameSize(FrameDirectory, SourceFrame));
        FrameImage.DrawToGraphBuf(PlaybackBuffer, FrameImage.GetBoundsRect.Left - Bounds.Left, FrameImage.GetBoundsRect.Top - Bounds.Top,
          Classes.Rect(0, 0, PlaybackBuffer.Width, PlaybackBuffer.Height), 0, 255);
        Inc(Frame);
      end;
      TrimFrameCache;
      LastBufferedFrame := CurrentFrame;
    end;
    Y := StartY;
    while Y < EndY do
    begin
      X := StartX;
      while X < EndX do
      begin
        CopyTransparentGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, PlaybackBuffer, ClipRect, TransparentColor);
        X := X + Width;
      end;
      Y := Y + Height;
    end;
  end;
end;
{ @end $499F58 }

end.
