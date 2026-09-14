unit GI_SpaceCircle;
// Unit bracket (inferred): .text 0x00479DF8..0x0047AC9D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, EC_Struct, EC_BlockPar, Types;

type
  TSpaceCircleSegmentGI = record // @size $24
    First: TPointF; // @offset $00
    Last: TPointF; // @offset $08
    ClipResult: Integer; // @offset $10
    PixelFirst: TPoint; // @offset $14
    PixelLast: TPoint; // @offset $1C
  end;
  PSpaceCircleSegmentGI = ^TSpaceCircleSegmentGI;
  TSpaceCircleSavedLineGI = record // @size $10
    First: TPoint; // @offset $00
    Last: TPoint; // @offset $08
  end;
  PSpaceCircleSavedLineGI = ^TSpaceCircleSavedLineGI;

  TSpaceCircleGI = class(TObjectGI) // @size $154
  public
    SegmentCount: Integer; // @offset $120
    Segments: PSpaceCircleSegmentGI; // @offset $124
    PreviousLineCount: Integer; // @offset $128
    PreviousLines: PSpaceCircleSavedLineGI; // @offset $12C
    Center: TPoint; // @offset $130
    Radius: Integer; // @offset $138
    Color: Cardinal; // @offset $13C
    GeometryDirty: Boolean; // @offset $140
    DrawnSegmentCount: Integer; // @offset $144
    DeactivateAfterFrame: Boolean; // @offset $148
    AnimationTimer: PCallbackTimerGI; // @offset $14C
    SavedPixels: Pointer; // @offset $150

    constructor Create(Owner: TObjectGI); // @addr $479F1C @ida "TSpaceCircleGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $479F90 @ida "void __usercall $name(TSpaceCircleGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetRadius(Value: Integer); // @addr $479FF8
    procedure SetCenter(Value: TPoint); // @addr $47A040 @ida "void __usercall $name(TSpaceCircleGI *Self@<eax>, TPoint *Value@<edx>);"
    procedure ClearSegments; // @addr $47A0A4
    procedure ClearPreviousLines; // @addr $47A0E0
    procedure RebuildSegments; // @addr $47A11C
    procedure ProjectAndClipSegments; // @addr $47A3B0
    procedure RotateSegments(Timer: PCallbackTimerGI; UserData: Integer); // @addr $47A4A8
    procedure SetActive(Enabled: Boolean); override; // @addr $47A658 @note "Deactivation is deferred until CommitFrameDraw."
    procedure OnActivate; override; // @addr $47A6D8
    procedure OnDeactivate; override; // @addr $47A708
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $47A77C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $47A7B0
    procedure LoadSpaceCircleProperties(Block: TBlockParEC); // @addr $47A7D8 @note "Empty in native code."
    procedure Invalidate; override; // @addr $47A7E8 @note "Empty in native code."
    procedure ErasePreviousFrame; override; // @addr $47A7F4
    procedure PrepareFrameDraw; override; // @addr $47A98C
    procedure DrawUpdateRects(ClipRect: TRect); override; // @addr $47AAF4 @ida "void __usercall $name(TSpaceCircleGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure Draw(ClipRect: TRect); override; // @addr $47AB3C @ida "void __usercall $name(TSpaceCircleGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure CommitFrameDraw; override; // @addr $47AC6C
  end;

implementation

uses EC_Mem, GR_Main, GR_GraphBuf, GR_DX, GlobalsV, Classes;

{ @routine $479F1C TSpaceCircleGI_Create }
constructor TSpaceCircleGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  Radius := 100;
end;
{ @end $479F1C }

{ @routine $479F90 TSpaceCircleGI_Destroy }
destructor TSpaceCircleGI.Destroy;
begin
  ClearSegments;
  ClearPreviousLines;
  if SavedPixels <> nil then
  begin
    FreeEC(SavedPixels);
    SavedPixels := nil;
  end;
  inherited Destroy;
end;
{ @end $479F90 }

{ @routine $479FF8 TSpaceCircleGI_SetRadius }
procedure TSpaceCircleGI.SetRadius(Value: Integer);
begin
  if Radius <> Value then
  begin
    Radius := Value;
    if Active then
    begin
      RebuildSegments;
      GeometryDirty := True;
    end;
  end;
end;
{ @end $479FF8 }

{ @routine $47A040 TSpaceCircleGI_SetCenter }
procedure TSpaceCircleGI.SetCenter(Value: TPoint);
begin
  if (Center.X <> Value.X) or (Center.Y <> Value.Y) then
  begin
    Center := Value;
    if Active then
    begin
      RebuildSegments;
      GeometryDirty := True;
    end;
  end;
end;
{ @end $47A040 }

{ @routine $47A0A4 TSpaceCircleGI_ClearSegments }
procedure TSpaceCircleGI.ClearSegments;
begin
  if Segments <> nil then
  begin
    FreeEC(Segments);
    Segments := nil;
  end;
  SegmentCount := 0;
end;
{ @end $47A0A4 }

{ @routine $47A0E0 TSpaceCircleGI_ClearPreviousLines }
procedure TSpaceCircleGI.ClearPreviousLines;
begin
  if PreviousLines <> nil then
  begin
    FreeEC(PreviousLines);
    PreviousLines := nil;
  end;
  PreviousLineCount := 0;
end;
{ @end $47A0E0 }

{ @routine $47A11C TSpaceCircleGI_RebuildSegments }
procedure TSpaceCircleGI.RebuildSegments;
var Spacing, Circumference, Angle, Step, Length: Single;
    I, Count: Integer; Segment: PSpaceCircleSegmentGI; Point, Delta: TPointF;
begin
  ClearSegments;
  if Radius > 0 then
  begin
    Spacing := 20;
    Circumference := Radius * (2 * 3.1415926);
    Count := Round(Circumference / Spacing);
    if Count < 10 then Count := 10;
    Segments := AllocEC(Count * SizeOf(TSpaceCircleSegmentGI));
    Angle := 0;
    Step := (2 * 3.1415926) / Count;
    Point := MakePointF(Sin(Angle) * Radius, Cos(Angle) * (-Radius));
    Segment := Segments;
    for I := 0 to Count - 1 do
    begin
      Segment.First := AddPointsF(Point, PointToPointF(Center));
      Angle := Angle + Step;
      Point := MakePointF(Sin(Angle) * Radius, Cos(Angle) * (-Radius));
      Segment.Last := AddPointsF(Point, PointToPointF(Center));
      Delta := SubtractPointsF(Segment.Last, Segment.First);
      Length := Sqrt(Delta.X * Delta.X + Delta.Y * Delta.Y);
      Delta.X := Delta.X / Length;
      Delta.Y := Delta.Y / Length;
      Segment.Last.X := Delta.X * Length * 0.75 + Segment.First.X;
      Segment.Last.Y := Delta.Y * Length * 0.75 + Segment.First.Y;
      Segment.First.X := Delta.X * Length * 0.25 + Segment.First.X;
      Segment.First.Y := Delta.Y * Length * 0.25 + Segment.First.Y;
      Segment := AddPointerOffset(Segment, SizeOf(TSpaceCircleSegmentGI));
    end;
    SegmentCount := Count;
  end;
end;
{ @end $47A11C }

{ @routine $47A3B0 TSpaceCircleGI_ProjectAndClipSegments }
procedure TSpaceCircleGI.ProjectAndClipSegments;
var Segment: PSpaceCircleSegmentGI; I: Integer; Clip: TRect;
begin
  Clip.TopLeft := HitTestBounds.TopLeft;
  Clip.Right := HitTestBounds.Right - 1;
  Clip.Bottom := HitTestBounds.Bottom - 1;
  Segment := Segments;
  for I := 0 to SegmentCount - 1 do
  begin
    Segment.PixelFirst := AddPoints(RoundPointF(Segment.First), AbsolutePosition);
    Segment.PixelLast := AddPoints(RoundPointF(Segment.Last), AbsolutePosition);
    Segment.ClipResult := Ex_OKGR_Line_Clip(Segment.PixelFirst.X, Segment.PixelFirst.Y,
      Segment.PixelLast.X, Segment.PixelLast.Y, Clip);
    Segment := AddPointerOffset(Segment, SizeOf(TSpaceCircleSegmentGI));
  end;
end;
{ @end $47A3B0 }

{ @routine $47A4A8 TSpaceCircleGI_RotateSegments }
procedure TSpaceCircleGI.RotateSegments(Timer: PCallbackTimerGI; UserData: Integer);
var Segment: PSpaceCircleSegmentGI; I: Integer; Sine, Cosine, X, Y, Angle: Single;
begin
  if Radius > 0 then
  begin
    Angle := -2 / (Radius * (2 * 3.1415926)) * 3.1415926 * 2;
    Sine := Sin(Angle);
    Cosine := Cos(Angle);
    Segment := Segments;
    for I := 0 to SegmentCount - 1 do
    begin
      X := Segment.First.X - Center.X;
      Y := Segment.First.Y - Center.Y;
      Segment.First.X := Cosine * X + Sine * Y + Center.X;
      Segment.First.Y := -Sine * X + Cosine * Y + Center.Y;
      X := Segment.Last.X - Center.X;
      Y := Segment.Last.Y - Center.Y;
      Segment.Last.X := Cosine * X + Sine * Y + Center.X;
      Segment.Last.Y := -Sine * X + Cosine * Y + Center.Y;
      Segment := AddPointerOffset(Segment, SizeOf(TSpaceCircleSegmentGI));
    end;
    GeometryDirty := True;
  end;
end;
{ @end $47A4A8 }

{ @routine $47A658 TSpaceCircleGI_SetActive }
procedure TSpaceCircleGI.SetActive(Enabled: Boolean);
begin
  if Active <> Enabled then
    if Enabled then
    begin
      inherited SetActive(Enabled);
      RebuildSegments;
      GeometryDirty := True;
    end
    else
    begin
      if AnimationTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(AnimationTimer);
        AnimationTimer := nil;
      end;
      DeactivateAfterFrame := True;
      ClearSegments;
    end;
end;
{ @end $47A658 }

{ @routine $47A6D8 TSpaceCircleGI_OnActivate }
procedure TSpaceCircleGI.OnActivate;
begin
  inherited OnActivate;
  if Active then
  begin
    RebuildSegments;
    GeometryDirty := True;
  end;
end;
{ @end $47A6D8 }

{ @routine $47A708 TSpaceCircleGI_OnDeactivate }
procedure TSpaceCircleGI.OnDeactivate;
begin
  inherited OnDeactivate;
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  ClearSegments;
  ClearPreviousLines;
  if SavedPixels <> nil then
  begin
    FreeEC(SavedPixels);
    SavedPixels := nil;
  end;
end;
{ @end $47A708 }

{ @routine $47A77C TSpaceCircleGI_LoadFromConfigPath }
procedure TSpaceCircleGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadSpaceCircleProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $47A77C }

{ @routine $47A7B0 TSpaceCircleGI_LoadFromBlock }
procedure TSpaceCircleGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadSpaceCircleProperties(Block);
end;
{ @end $47A7B0 }

{ @routine $47A7D8 TSpaceCircleGI_LoadSpaceCircleProperties }
procedure TSpaceCircleGI.LoadSpaceCircleProperties(Block: TBlockParEC);
begin
end;
{ @end $47A7D8 }

{ @routine $47A7E8 TSpaceCircleGI_Invalidate }
procedure TSpaceCircleGI.Invalidate;
begin
end;
{ @end $47A7E8 }

{ @routine $47A7F4 TSpaceCircleGI_ErasePreviousFrame }
procedure TSpaceCircleGI.ErasePreviousFrame;
var Line: PSpaceCircleSavedLineGI; I: Integer; Buffer: Pointer; Count: Integer;
begin
  if GeometryDirty then
  begin
    ProjectAndClipSegments;
    GeometryDirty := False;
    if AnimationTimer = nil then
      AnimationTimer := MessageLoop.ScheduleCallbackTimer(50, 50, RotateSegments);
  end;
  if (not HardwareRenderingEnabled) and (not SkipSavedPixelRestore) then
    if not BGImage then
    begin
      Line := PreviousLines;
      for I := 0 to PreviousLineCount - 1 do
      begin
        ScreenRenderBuffer.DrawLine16Clipped(Line.First, Line.Last, 0, HitTestBounds);
        Line := AddPointerOffset(Line, SizeOf(TSpaceCircleSavedLineGI));
      end;
    end
    else
    begin
      if SavedPixels <> nil then
      begin
        Buffer := SavedPixels;
        Line := PreviousLines;
        for I := 0 to PreviousLineCount - 1 do
        begin
          Count := Ex_OKGR_Line_CopyFromBuf_WORD(Buffer, ScreenRenderBuffer.GetPixels,
            ScreenRenderBuffer.PitchBytes, Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y);
          Buffer := AddPointerOffset(Buffer, Count * 2);
          Line := AddPointerOffset(Line, SizeOf(TSpaceCircleSavedLineGI));
        end;
      end;
    end;
end;
{ @end $47A7F4 }

{ @routine $47A98C TSpaceCircleGI_PrepareFrameDraw }
procedure TSpaceCircleGI.PrepareFrameDraw;
var Segment: PSpaceCircleSegmentGI; Copied: Integer; Count, Capacity, I: Integer;
begin
  if not HardwareRenderingEnabled then
    if BGImage and (not DeactivateAfterFrame) then
    begin
      Count := 0;
      Capacity := 100;
      SavedPixels := ReAllocREC(SavedPixels, Capacity * 2);
      Segment := Segments;
      for I := 0 to SegmentCount - 1 do
      begin
        if Segment.ClipResult > 0 then
        begin
          Copied := Ex_OKGR_Line_CopyToBuf_WORD(AddPointerOffset(SavedPixels, Count * 2),
            ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
            Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.PixelLast.X, Segment.PixelLast.Y);
          Inc(Count, Copied);
          if Count + 30 > Capacity then
          begin
            Capacity := Count + 100;
            SavedPixels := ReAllocREC(SavedPixels, Capacity * 2);
          end;
        end;
        Segment := AddPointerOffset(Segment, SizeOf(TSpaceCircleSegmentGI));
      end;
    end
    else
    begin
      if SavedPixels <> nil then
      begin
        FreeEC(SavedPixels);
        SavedPixels := nil;
      end;
    end;
end;
{ @end $47A98C }

{ @routine $47AAF4 TSpaceCircleGI_DrawUpdateRects }
procedure TSpaceCircleGI.DrawUpdateRects(ClipRect: TRect);
begin
  Draw(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
end;
{ @end $47AAF4 }

{ @routine $47AB3C TSpaceCircleGI_Draw }
procedure TSpaceCircleGI.Draw(ClipRect: TRect);
var Segment: PSpaceCircleSegmentGI; I: Integer;
begin
  DrawnSegmentCount := 0;
  if not DeactivateAfterFrame then
  begin
    Segment := Segments;
    if HardwareRenderingEnabled then
    begin
      for I := 0 to SegmentCount - 1 do
      begin
        if Segment.ClipResult > 0 then
        begin
          DrawAntialiasedLineDX(Segment.PixelFirst.X, Segment.PixelFirst.Y,
            Segment.PixelLast.X, Segment.PixelLast.Y, Color565ToArgb(Color), 255, nil);
          Inc(DrawnSegmentCount);
        end;
        Segment := AddPointerOffset(Segment, SizeOf(TSpaceCircleSegmentGI));
      end;
    end
    else
    begin
      for I := 0 to SegmentCount - 1 do
      begin
        if Segment.ClipResult > 0 then
        begin
          ScreenRenderBuffer.DrawLine16(Segment.PixelFirst, Segment.PixelLast, Color);
          Inc(DrawnSegmentCount);
        end;
        Segment := AddPointerOffset(Segment, SizeOf(TSpaceCircleSegmentGI));
      end;
    end;
  end;
end;
{ @end $47AB3C }

{ @routine $47AC6C TSpaceCircleGI_CommitFrameDraw }
procedure TSpaceCircleGI.CommitFrameDraw;
begin
  // Native code retains this empty renderer test before deferred deactivation.
  if not HardwareRenderingEnabled then begin end;
  if DeactivateAfterFrame then
  begin
    inherited SetActive(False);
    DeactivateAfterFrame := False;
  end;
end;
{ @end $47AC6C }

end.
