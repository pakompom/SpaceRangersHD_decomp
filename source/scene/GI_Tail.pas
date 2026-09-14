unit GI_Tail;
// Native GI_Tail metadata starts at $4EA2F0; methods end at $4EB368.
// TTailGI belongs to GI_Tail through its dynamic-array RTTI.

interface

uses EC_BlockPar, EC_CacheGAI, EC_Struct, GI_MessageLoop, SE_Process, Types;

type
  TTailSegmentGI = record // @size 0x20
    Active: Boolean; // @offset 0x00
    FrameIndex: Integer; // @offset 0x04
    Position: TPointF; // @offset 0x08
    Velocity: TPointF; // @offset 0x10
    PixelPosition: TPoint; // @offset 0x18
  end;
  PTailSegmentGI = ^TTailSegmentGI;

  TTailGI = class(TObjectGI) // @size 0x160
  public
    ImageCache: TCGaiControlEC; // @offset 0x120
    FrameCount: Integer; // @offset 0x124
    SegmentCapacity: Integer; // @offset 0x128
    Segments: array of TTailSegmentGI; // @offset 0x12C
    ImageSize: TPoint; // @offset 0x130
    LastSegmentIndex: Integer; // @offset 0x138
    EmitterPosition: TPointF; // @offset 0x13C
    SegmentVelocity: TPointF; // @offset 0x144
    FrameTimer: PCallbackTimerGI; // @offset 0x14C
    MoveTimer: PCallbackTimerGI; // @offset 0x150
    EmitTimer: PCallbackTimerGI; // @offset 0x154
    EmitIntervalMs: Integer; // @offset 0x158
    Emitting: Boolean; // @offset 0x15C
    // Segments is a Delphi dynamic array, with inactive slots included in SegmentCapacity.
    // SegmentVelocity is displacement per 20 ms movement callback.

    constructor Create(Owner: TObjectGI); // @addr 0x4EA440 @ida "TTailGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4EA4D8 @ida "void __usercall $name(TTailGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure ClearSegments; // @addr 0x4EA5AC @note "Preserves timers and emission state."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x4EA5E4 @note "Requires at least one GAI sequence. Existing segments are kept."
    function GetImagePath: WideString; // @addr 0x4EA748 @ida "void __usercall $name(TTailGI *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function AllocateSegment: PTailSegmentGI; // @addr 0x4EA76C @note "Reuses the last inactive slot or grows by 16. Growth can invalidate earlier pointers; only Active is initialized."
    procedure AdvanceSegmentFrames(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x4EA844
    procedure MoveSegments(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x4EA8D0
    procedure EmitSegment(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x4EA96C @note "Suppresses emission within squared distance 0.001 of the last live segment."
    procedure OffsetSegments(Delta: TPointF); // @addr 0x4EAA60 @ida "void __usercall $name(TTailGI *Self@<eax>, TPointF *Delta@<edx>);"
    procedure SetActive(Enabled: Boolean); override; // @addr 0x4EAAF8 @note "Deactivation cancels timers. Drawing restarts them when Emitting is true."
    procedure SetEmitting(Enabled: Boolean); // @addr 0x4EABB0 @note "Disabling emission leaves existing segments animating."
    procedure Invalidate; override; // @addr 0x4EAD24
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4EADDC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4EAE10
    procedure LoadTailProperties(Block: TBlockParEC); // @addr 0x4EAE38 @note "Empty in the native binary."
    procedure UpdateAutoGeometry; override; // @addr 0x4EAE48 @note "Empty; does not call inherited UpdateAutoGeometry."
    procedure Draw(ClipRect: TRect); override; // @addr 0x4EAE54 @ida "void __usercall $name(TTailGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure DrawUpdateRects(ClipRect: TRect); override; // @addr 0x4EB0C8 @ida "void __usercall $name(TTailGI *Self@<eax>, TRect *ClipRect@<edx>);" @note "Ignores ClipRect; uses the message loop's update rectangles."
  end;

implementation

uses Math, aMyFunction, GR_Main, EC_Cache, GR_Gi, GR_DX, GR_Rect, Direct3D9;

{ @routine $4EA440 TTailGI_Create }
constructor TTailGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCGaiControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  EmitIntervalMs := 20;
  Emitting := True;
  LastSegmentIndex := -1;
end;
{ @end $4EA440 }

{ @routine $4EA4D8 TTailGI_Destroy }
destructor TTailGI.Destroy;
begin
  if FrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(FrameTimer);
    FrameTimer := nil;
  end;
  if MoveTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(MoveTimer);
    MoveTimer := nil;
  end;
  if EmitTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(EmitTimer);
    EmitTimer := nil;
  end;
  ClearSegments;
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $4EA4D8 }

{ @routine $4EA5AC TTailGI_ClearSegments }
procedure TTailGI.ClearSegments;
begin
  LastSegmentIndex := -1;
  SegmentCapacity := 0;
  Segments := nil;
end;
{ @end $4EA5AC }

{ @routine $4EA5E4 TTailGI_SetImagePath }
procedure TTailGI.SetImagePath(const ImagePath: WideString);
var Data: TCGaiEC;
begin
  if ImageCache.CacheKey <> ImagePath then
  begin
    Invalidate;
    ImageCache.SetCacheKey(ImagePath);
    Data := nil;
    try
      Data := AcquireCachedGai(ImageCache);
      if Data.GetSequenceCount < 1 then
        RaiseWideMessage('TTailGI.SetImage.AnimCount Path=' + ImagePath);
      FrameCount := Data.GetSequenceFrameCount(0);
      ImageSize := Data.GetCanvasSize;
    finally
      if Data <> nil then ImageCache.Release;
    end;
  end;
end;
{ @end $4EA5E4 }

{ @routine $4EA748 TTailGI_GetImagePath }
function TTailGI.GetImagePath: WideString;
begin
  Result := ImageCache.CacheKey;
end;
{ @end $4EA748 }

{ @routine $4EA76C TTailGI_AllocateSegment }
function TTailGI.AllocateSegment: PTailSegmentGI;
var I: Integer;
begin
  Result := nil;
  for I := 0 to SegmentCapacity - 1 do
    if not Segments[I].Active then
    begin
      Result := @Segments[I];
      LastSegmentIndex := I;
    end;
  if Result = nil then
  begin
    SetLength(Segments, SegmentCapacity + 16);
    Result := @Segments[SegmentCapacity];
    LastSegmentIndex := SegmentCapacity;
    Inc(SegmentCapacity, 16);
  end;
  Result.Active := True;
end;
{ @end $4EA76C }

{ @routine $4EA844 TTailGI_AdvanceSegmentFrames }
procedure TTailGI.AdvanceSegmentFrames(Timer: PCallbackTimerGI; UserData: Integer);
var Segment: PTailSegmentGI; I: Integer;
begin
  for I := 0 to SegmentCapacity - 1 do
  begin
    Segment := @Segments[I];
    if Segment.Active then
    begin
      Inc(Segment.FrameIndex);
      // The neutral additions preserve native operand materialization order.
      if Segment.FrameIndex + 0 >= FrameCount then
      begin
        Segment.Active := False;
        if I + 0 = LastSegmentIndex then LastSegmentIndex := -1;
      end;
    end;
  end;
end;
{ @end $4EA844 }

{ @routine $4EA8D0 TTailGI_MoveSegments }
procedure TTailGI.MoveSegments(Timer: PCallbackTimerGI; UserData: Integer);
var Segment: PTailSegmentGI; I: Integer;
begin
  for I := 0 to SegmentCapacity - 1 do
  begin
    Segment := @Segments[I];
    if Segment.Active then
    begin
      Segment.Position.X := Segment.Position.X + Segment.Velocity.X;
      Segment.Position.Y := Segment.Position.Y + Segment.Velocity.Y;
      Segment.PixelPosition.X := Round(Segment.Position.X);
      Segment.PixelPosition.Y := Round(Segment.Position.Y);
    end;
  end;
end;
{ @end $4EA8D0 }

{ @routine $4EA96C TTailGI_EmitSegment }
procedure TTailGI.EmitSegment(Timer: PCallbackTimerGI; UserData: Integer);
var Segment: PTailSegmentGI; Position: TPointF;
begin
  Position.X := SegmentVelocity.X * 1.0 + EmitterPosition.X;
  Position.Y := SegmentVelocity.Y * 1.0 + EmitterPosition.Y;
  if LastSegmentIndex >= 0 then
    if PointDistanceSquared(Position, Segments[LastSegmentIndex].Position) < 0.001 then Exit;
  Segment := AllocateSegment;
  Segment.FrameIndex := 0;
  Segment.Position := Position;
  Segment.Velocity := SegmentVelocity;
  Segment.PixelPosition.X := Round(Segment.Position.X);
  Segment.PixelPosition.Y := Round(Segment.Position.Y);
end;
{ @end $4EA96C }

{ @routine $4EAA60 TTailGI_OffsetSegments }
procedure TTailGI.OffsetSegments(Delta: TPointF);
var Segment: PTailSegmentGI; I: Integer;
begin
  for I := 0 to SegmentCapacity - 1 do
  begin
    Segment := @Segments[I];
    if Segment.Active then
    begin
      Segment.Position.X := Segment.Position.X + Delta.X;
      Segment.Position.Y := Segment.Position.Y + Delta.Y;
      Segment.PixelPosition.X := Round(Segment.Position.X);
      Segment.PixelPosition.Y := Round(Segment.Position.Y);
    end;
  end;
end;
{ @end $4EAA60 }

{ @routine $4EAAF8 TTailGI_SetActive }
procedure TTailGI.SetActive(Enabled: Boolean);
begin
  if Active <> Enabled then
  begin
    inherited SetActive(Enabled);
    if not Active then
    begin
      if FrameTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(FrameTimer);
        FrameTimer := nil;
      end;
      if MoveTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(MoveTimer);
        MoveTimer := nil;
      end;
      if EmitTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(EmitTimer);
        EmitTimer := nil;
      end;
    end;
  end;
end;
{ @end $4EAAF8 }

{ @routine $4EABB0 TTailGI_SetEmitting }
procedure TTailGI.SetEmitting(Enabled: Boolean);
begin
  if Emitting <> Enabled then
  begin
    Emitting := Enabled;
    if not Emitting then
    begin
      if EmitTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(EmitTimer);
        EmitTimer := nil;
      end;
    end
    else
    begin
      if FrameTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(FrameTimer);
        FrameTimer := nil;
      end;
      if MoveTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(MoveTimer);
        MoveTimer := nil;
      end;
      if EmitTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(EmitTimer);
        EmitTimer := nil;
      end;
      FrameTimer := MessageLoop.ScheduleCallbackTimer(20, 20, AdvanceSegmentFrames);
      MoveTimer := MessageLoop.ScheduleCallbackTimer(20, 20, MoveSegments);
      EmitTimer := MessageLoop.ScheduleCallbackTimer(EmitIntervalMs, EmitIntervalMs, EmitSegment);
    end;
  end;
end;
{ @end $4EABB0 }

{ @routine $4EAD24 TTailGI_Invalidate }
procedure TTailGI.Invalidate;
var Segment: PTailSegmentGI; I: Integer; Bounds: TRect;
begin
  for I := 0 to SegmentCapacity - 1 do
  begin
    Segment := @Segments[I];
    if Segment.Active then
    begin
      Bounds.Left := AbsolutePosition.X + Segment.PixelPosition.X - (ImageSize.X shr 1);
      Bounds.Top := AbsolutePosition.Y + Segment.PixelPosition.Y - (ImageSize.Y shr 1);
      Bounds.Right := Bounds.Left + ImageSize.X;
      Bounds.Bottom := Bounds.Top + ImageSize.Y;
      MessageLoop.QueueUpdateRect(Bounds);
    end;
  end;
end;
{ @end $4EAD24 }

{ @routine $4EADDC TTailGI_LoadFromConfigPath }
procedure TTailGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadTailProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4EADDC }

{ @routine $4EAE10 TTailGI_LoadFromBlock }
procedure TTailGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadTailProperties(Block);
end;
{ @end $4EAE10 }

{ @routine $4EAE38 TTailGI_LoadTailProperties }
procedure TTailGI.LoadTailProperties(Block: TBlockParEC);
begin
end;
{ @end $4EAE38 }

{ @routine $4EAE48 TTailGI_UpdateAutoGeometry }
procedure TTailGI.UpdateAutoGeometry;
begin
end;
{ @end $4EAE48 }

{ @routine $4EAE54 TTailGI_Draw }
procedure TTailGI.Draw(ClipRect: TRect);
var
  Data: TCGaiEC;
  Segment: PTailSegmentGI;
  I: Integer;
  Gi: TgiGR;
  Origin: TPoint;
  Bounds, Intersection: TRect;
begin
  if Emitting then
    if FrameTimer = nil then
    begin
      Emitting := False;
      SetEmitting(True);
    end;
  Data := nil;
  try
    Data := AcquireCachedGai(ImageCache);
    for I := 0 to SegmentCapacity - 1 do
    begin
      Segment := @Segments[I];
      if Segment.Active then
      begin
        Bounds.Left := AbsolutePosition.X + Segment.PixelPosition.X - (ImageSize.X shr 1);
        Bounds.Top := AbsolutePosition.Y + Segment.PixelPosition.Y - (ImageSize.Y shr 1);
        Bounds.Right := ImageSize.X + Bounds.Left;
        Bounds.Bottom := ImageSize.Y + Bounds.Top;
        if IntersectRects(Intersection, Bounds, ClipRect) then
        begin
          if HardwareRenderingEnabled then
          begin
            Origin := Data.GetFrameOrigin(Data.GetSequenceFrameIndex(0, Segment.FrameIndex));
            DrawTexture(Data.GetOrCreateFrameSurface(Data.GetSequenceFrameIndex(0, Segment.FrameIndex)), Origin.X + Bounds.Left, Origin.Y + Bounds.Top, 255, $FFFFFF, @ClipRect, False, False);
          end
          else
          begin
            Gi := Data.LoadFrameGi(Data.GetSequenceFrameIndex(0, Segment.FrameIndex));
            Gi.DrawToGraphBuf(ScreenRenderBuffer, Gi.GetBoundsRect.Left + Bounds.Left - Data.GetBoundsRect.Left,
              Gi.GetBoundsRect.Top + Bounds.Top - Data.GetBoundsRect.Top, ClipRect, 0, 255);
          end;
        end;
      end;
    end;
  finally
    if Data <> nil then ImageCache.Release;
  end;
end;
{ @end $4EAE54 }

{ @routine $4EB0C8 TTailGI_DrawUpdateRects }
procedure TTailGI.DrawUpdateRects(ClipRect: TRect);
var
  Data: TCGaiEC;
  Segment: PTailSegmentGI;
  I: Integer;
  Gi: TgiGR;
  RectNode: TRectGR;
  Origin: TPoint;
  Bounds, Intersection: TRect;
begin
  if Emitting then
    if FrameTimer = nil then
    begin
      Emitting := False;
      SetEmitting(True);
    end;
  Data := nil;
  try
    Data := AcquireCachedGai(ImageCache);
    for I := 0 to SegmentCapacity - 1 do
    begin
      Segment := @Segments[I];
      if Segment.Active then
      begin
        Bounds.Left := AbsolutePosition.X + Segment.PixelPosition.X - (ImageSize.X shr 1);
        Bounds.Top := AbsolutePosition.Y + Segment.PixelPosition.Y - (ImageSize.Y shr 1);
        Bounds.Right := ImageSize.X + Bounds.Left;
        Bounds.Bottom := ImageSize.Y + Bounds.Top;
        RectNode := MessageLoop.UpdateRects.FirstRect;
        while RectNode <> nil do
        begin
          if IntersectRects(Intersection, RectNode.Bounds, Bounds) then
          begin
            if HardwareRenderingEnabled then
            begin
              Origin := Data.GetFrameOrigin(Data.GetSequenceFrameIndex(0, Segment.FrameIndex));
              DrawTexture(Data.GetOrCreateFrameSurface(Data.GetSequenceFrameIndex(0, Segment.FrameIndex)), Origin.X + Bounds.Left, Origin.Y + Bounds.Top, 255, $FFFFFF, @Intersection, False, False);
            end
            else
            begin
              Gi := Data.LoadFrameGi(Data.GetSequenceFrameIndex(0, Segment.FrameIndex));
              Gi.DrawToGraphBuf(ScreenRenderBuffer, Gi.GetBoundsRect.Left + Bounds.Left - Data.GetBoundsRect.Left,
                Gi.GetBoundsRect.Top + Bounds.Top - Data.GetBoundsRect.Top, Intersection, 0, 255);
            end;
          end;
          RectNode := RectNode.Next;
        end;
      end;
    end;
  finally
    if Data <> nil then ImageCache.Release;
  end;
end;
{ @end $4EB0C8 }

end.
