unit GI_PolyLine;
// Unit bracket (inferred): .text 0x00474C8C..0x004761F9; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, GI_Circle, EC_BlockPar, Types, Windows;

type
  PPolyLineSegmentGI = ^TPolyLineSegmentGI;
  TPolyLineSegmentGI = record // @size $6C
    Next: PPolyLineSegmentGI; // @offset $00
    Prev: PPolyLineSegmentGI; // @offset $04
    First: TPoint; // @offset $08
    Last: TPoint; // @offset $10
    UserData: Integer; // @offset $18
    Animated: Boolean; // @offset $1C
    PixelCount: Integer; // @offset $20
    PixelCapacity: Integer; // @offset $24
    PixelFirst: TPoint; // @offset $28
    PixelLast: TPoint; // @offset $30
    SavedPixels: Pointer; // @offset $38
    Visible: Boolean; // @offset $3C
    PreviousFirst: TPoint; // @offset $3D
    PreviousLast: TPoint; // @offset $45
    PreviousPixels: Pointer; // @offset $50
    PreviouslyVisible: Boolean; // @offset $54
    ClippedColor: Cardinal; // @offset $58
    ClippedEndColor: Cardinal; // @offset $5C
    Color: Cardinal; // @offset $60
    EndColor: Cardinal; // @offset $64
    Kind: Integer; // @offset $68 0 animated RGB565, 1 alpha, 2 gradient.
  end;

  TPolyLineGI = class(TObjectGI) // @size $140
  public
    FirstSegment: PPolyLineSegmentGI; // @offset $120
    LastSegment: PPolyLineSegmentGI; // @offset $124
    AnimationPhase: Cardinal; // @offset $128
    AnimationTimer: PCallbackTimerGI; // @offset $12C
    FrameDrawing: Boolean; // @offset $130
    ShadowCircle: TCircleGI; // @offset $134 Borrowed light-mask control.
    AutoRebuildBounds: Boolean; // @offset $138
    NormalizeBounds: Boolean; // @offset $139
    SegmentHeap: Cardinal; // @offset $13C

    constructor Create(Owner: TObjectGI); // @addr $474DB4 @ida "TPolyLineGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $474EBC @ida "void __usercall $name(TPolyLineGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr $474F30
    function AllocateSegment: PPolyLineSegmentGI; // @addr $474F7C
    procedure ClearSegments; // @addr $475024
    procedure RemoveSegment(Segment: PPolyLineSegmentGI); // @addr $475050
    procedure AllocatePixelBuffers(Segment: PPolyLineSegmentGI); // @addr $47512C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $47518C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4751C4
    procedure LoadPolyLineProperties(Block: TBlockParEC); // @addr $4751EC @note "Empty in native code."
    procedure RebuildBounds; // @addr $4751FC
    function AddParentLine(First, Last: TPoint; Color: Cardinal; UserData: Integer): PPolyLineSegmentGI; // @addr $4753D0 @ida "PPolyLineSegmentGI __userpurge $name@<eax>(TPolyLineGI *Self@<eax>, TPoint *First@<edx>, TPoint *Last@<ecx>, unsigned int Color@<^4>, int UserData@<^0>);"
    function AddLine(First, Last: TPoint; Color: Cardinal): PPolyLineSegmentGI; // @addr $4754A4 @ida "PPolyLineSegmentGI __userpurge $name@<eax>(TPolyLineGI *Self@<eax>, TPoint *First@<edx>, TPoint *Last@<ecx>, unsigned int Color@<^0>);"
    function AddLocalLine(First, Last: TPoint; Color: Cardinal; UserData: Integer): PPolyLineSegmentGI; // @addr $4754E0 @ida "PPolyLineSegmentGI __userpurge $name@<eax>(TPolyLineGI *Self@<eax>, TPoint *First@<edx>, TPoint *Last@<ecx>, unsigned int Color@<^4>, int UserData@<^0>);"
    procedure UpdateSegmentLength(Segment: PPolyLineSegmentGI); // @addr $475580
    procedure RetireSegment(Segment: PPolyLineSegmentGI); // @addr $47561C
    procedure StartAnimation; // @addr $475690
    procedure StopAnimation; // @addr $4756F0
    procedure AdvanceAnimation(Timer: PCallbackTimerGI; UserData: Integer); // @addr $475728
    procedure Invalidate; override; // @addr $47576C
    procedure ErasePreviousFrame; override; // @addr $4757C8
    procedure PrepareFrameDraw; override; // @addr $47585C
    procedure DrawUpdateRects(ClipRect: TRect); override; // @addr $475A50 @ida "void __usercall $name(TPolyLineGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure Draw(ClipRect: TRect); override; // @addr $475AD0 @ida "void __usercall $name(TPolyLineGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure DrawSegment(Segment: PPolyLineSegmentGI; ClipRect: TRect); virtual; // @addr $475B88 @slot $C8 @ida "void __usercall $name(TPolyLineGI *Self@<eax>, PPolyLineSegmentGI Segment@<edx>, TRect *ClipRect@<ecx>);"
    procedure DrawFrameSegment(Segment: PPolyLineSegmentGI; ClipRect: TRect); virtual; // @addr $475CD0 @slot $CC @ida "void __usercall $name(TPolyLineGI *Self@<eax>, PPolyLineSegmentGI Segment@<edx>, TRect *ClipRect@<ecx>);"
    procedure CommitFrameDraw; override; // @addr $4761F0 @note "Empty in native code."
  end;

implementation

uses EC_Mem, EC_Struct, GR_Main, GR_GraphBuf, GR_DX, GR_Rect, GlobalsV,
  Classes, SysUtils, aMyFunction;

{ @routine $474DB4 TPolyLineGI_Create }
constructor TPolyLineGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  SegmentHeap := HeapCreate(1, $8000, 0);
  if SegmentHeap = 0 then raise Exception.Create('TPolyLineGI.HeapCreate');
  ClientSize := Classes.Point(1, 1);
  AnimationTimer := nil;
  AnimationPhase := 0;
  FrameDrawing := False;
  ShadowCircle := nil;
  AutoRebuildBounds := True;
  NormalizeBounds := True;
  StartAnimation;
end;
{ @end $474DB4 }

{ @routine $474EBC TPolyLineGI_Destroy }
destructor TPolyLineGI.Destroy;
begin
  ShadowCircle := nil;
  StopAnimation;
  Clear;
  if SegmentHeap <> 0 then
  begin
    HeapDestroy(SegmentHeap);
    SegmentHeap := 0;
  end;
  inherited Destroy;
end;
{ @end $474EBC }

{ @routine $474F30 TPolyLineGI_Clear }
procedure TPolyLineGI.Clear;
begin
  ShadowCircle := nil;
  ClientSize := Classes.Point(1, 1);
  ClearSegments;
  inherited Clear;
end;
{ @end $474F30 }

{ @routine $474F7C TPolyLineGI_AllocateSegment }
function TPolyLineGI.AllocateSegment: PPolyLineSegmentGI;
var Segment: PPolyLineSegmentGI;
begin
  Segment := AllocFromHeapEC(SegmentHeap, SizeOf(TPolyLineSegmentGI));
  Segment.Next := nil;
  Segment.Prev := LastSegment;
  Segment.SavedPixels := nil;
  Segment.PreviousPixels := nil;
  Segment.Visible := False;
  Segment.PreviouslyVisible := False;
  if LastSegment <> nil then LastSegment.Next := Segment;
  if FirstSegment = nil then FirstSegment := Segment;
  LastSegment := Segment;
  Segment.Kind := 0;
  Result := Segment;
end;
{ @end $474F7C }

{ @routine $475024 TPolyLineGI_ClearSegments }
procedure TPolyLineGI.ClearSegments;
begin
  while FirstSegment <> nil do RemoveSegment(FirstSegment);
end;
{ @end $475024 }

{ @routine $475050 TPolyLineGI_RemoveSegment }
procedure TPolyLineGI.RemoveSegment(Segment: PPolyLineSegmentGI);
begin
  if Segment.Next <> nil then Segment.Next.Prev := Segment.Prev;
  if Segment.Prev <> nil then Segment.Prev.Next := Segment.Next;
  if LastSegment = Segment then LastSegment := Segment.Prev;
  if FirstSegment = Segment then FirstSegment := Segment.Next;
  if SegmentHeap <> 0 then
  begin
    if Segment.SavedPixels <> nil then
    begin
      FreeFromHeapEC(SegmentHeap, Segment.SavedPixels);
      Segment.SavedPixels := nil;
    end;
    if Segment.PreviousPixels <> nil then
    begin
      FreeFromHeapEC(SegmentHeap, Segment.PreviousPixels);
      Segment.PreviousPixels := nil;
    end;
    FreeFromHeapEC(SegmentHeap, Segment);
  end;
end;
{ @end $475050 }

{ @routine $47512C TPolyLineGI_AllocatePixelBuffers }
procedure TPolyLineGI.AllocatePixelBuffers(Segment: PPolyLineSegmentGI);
begin
  if Segment.SavedPixels = nil then Segment.SavedPixels := AllocFromHeapEC(SegmentHeap, Segment.PixelCount * 2 + 10);
  if Segment.PreviousPixels = nil then Segment.PreviousPixels := AllocFromHeapEC(SegmentHeap, Segment.PixelCount * 2 + 10);
end;
{ @end $47512C }

{ @routine $47518C TPolyLineGI_LoadFromConfigPath }
procedure TPolyLineGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  LoadPolyLineProperties(Block);
end;
{ @end $47518C }

{ @routine $4751C4 TPolyLineGI_LoadFromBlock }
procedure TPolyLineGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadPolyLineProperties(Block);
end;
{ @end $4751C4 }

{ @routine $4751EC TPolyLineGI_LoadPolyLineProperties }
procedure TPolyLineGI.LoadPolyLineProperties(Block: TBlockParEC);
begin

end;
{ @end $4751EC }

{ @routine $4751FC TPolyLineGI_RebuildBounds }
procedure TPolyLineGI.RebuildBounds;
var Segment: PPolyLineSegmentGI; Minimum, Size: TPoint;
begin
  if NormalizeBounds then
  begin
    Segment := FirstSegment;
    if Segment = nil then SetSize(Classes.Point(1, 1))
    else
    begin
      Minimum := Segment.First;
      while Segment <> nil do
      begin
        if Minimum.X > Segment.First.X then Minimum.X := Segment.First.X;
        if Minimum.Y > Segment.First.Y then Minimum.Y := Segment.First.Y;
        if Minimum.X > Segment.Last.X then Minimum.X := Segment.Last.X;
        if Minimum.Y > Segment.Last.Y then Minimum.Y := Segment.Last.Y;
        Segment := Segment.Next;
      end;
      SetPosition(Classes.Point(LocalPosition.X + Minimum.X, LocalPosition.Y + Minimum.Y));
      Size := Classes.Point(1, 1);
      Segment := FirstSegment;
      while Segment <> nil do
      begin
        Segment.First := Classes.Point(Segment.First.X - Minimum.X, Segment.First.Y - Minimum.Y);
        Segment.Last := Classes.Point(Segment.Last.X - Minimum.X, Segment.Last.Y - Minimum.Y);
        if Size.X <= Segment.First.X then Size.X := Segment.First.X + 1;
        if Size.Y <= Segment.First.Y then Size.Y := Segment.First.Y + 1;
        if Size.X <= Segment.Last.X then Size.X := Segment.Last.X + 1;
        if Size.Y <= Segment.Last.Y then Size.Y := Segment.Last.Y + 1;
        Segment := Segment.Next;
      end;
      SetSize(Size);
    end;
  end;
end;
{ @end $4751FC }

{ @routine $4753D0 TPolyLineGI_AddParentLine }
function TPolyLineGI.AddParentLine(First, Last: TPoint; Color: Cardinal; UserData: Integer): PPolyLineSegmentGI;
var Segment: PPolyLineSegmentGI;
begin
  Segment := AllocateSegment;
  Segment.First := Classes.Point(First.X - LocalPosition.X, First.Y - LocalPosition.Y);
  Segment.Last := Classes.Point(Last.X - LocalPosition.X, Last.Y - LocalPosition.Y);
  Segment.Color := Color;
  Segment.PixelCount := IntegerPointDistancePlusOne(First, Last);
  Segment.PixelCapacity := Segment.PixelCount;
  Segment.UserData := UserData;
  Segment.Animated := True;
  if AutoRebuildBounds then RebuildBounds;
  Result := Segment;
end;
{ @end $4753D0 }

{ @routine $4754A4 TPolyLineGI_AddLine }
function TPolyLineGI.AddLine(First, Last: TPoint; Color: Cardinal): PPolyLineSegmentGI;
begin
  Result := AddLocalLine(First, Last, Color, 0);
end;
{ @end $4754A4 }

{ @routine $4754E0 TPolyLineGI_AddLocalLine }
function TPolyLineGI.AddLocalLine(First, Last: TPoint; Color: Cardinal; UserData: Integer): PPolyLineSegmentGI;
var Segment: PPolyLineSegmentGI;
begin
  Segment := AllocateSegment;
  Segment.First := First;
  Segment.Last := Last;
  Segment.Color := Color;
  Segment.PixelCount := IntegerPointDistancePlusOne(First, Last);
  Segment.PixelCapacity := Segment.PixelCount;
  Segment.UserData := UserData;
  Segment.Animated := True;
  if AutoRebuildBounds then RebuildBounds;
  Result := Segment;
end;
{ @end $4754E0 }

{ @routine $475580 TPolyLineGI_UpdateSegmentLength }
procedure TPolyLineGI.UpdateSegmentLength(Segment: PPolyLineSegmentGI);
var Count: Integer;
begin
  Count := IntegerPointDistancePlusOne(Segment.First, Segment.Last);
  if Count > Segment.PixelCapacity then
  begin
    Segment.PixelCount := Count;
    Segment.PixelCapacity := Segment.PixelCount;
    Segment.SavedPixels := ReAllocFromHeapREC(SegmentHeap, Segment.SavedPixels, Segment.PixelCount * 2 + 10);
    Segment.PreviousPixels := ReAllocFromHeapREC(SegmentHeap, Segment.PreviousPixels, Segment.PixelCount * 2 + 10);
  end
  else Segment.PixelCount := Count;
end;
{ @end $475580 }

{ @routine $47561C TPolyLineGI_RetireSegment }
procedure TPolyLineGI.RetireSegment(Segment: PPolyLineSegmentGI);
var Buffer: Pointer;
begin
  if Segment.PreviouslyVisible and (Segment.PreviousPixels <> nil) then
  begin
    Buffer := AllocEC(Segment.PixelCount * 2 + 10);
    CopyMemory(Buffer, Segment.PreviousPixels, Segment.PixelCount * 2 + 10);
    MessageLoop.AddSavedLine(Segment.PreviousFirst, Segment.PreviousLast, Buffer);
  end;
  RemoveSegment(Segment);
end;
{ @end $47561C }

{ @routine $475690 TPolyLineGI_StartAnimation }
procedure TPolyLineGI.StartAnimation;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  AnimationTimer := MessageLoop.ScheduleCallbackTimer(100, 100, AdvanceAnimation);
end;
{ @end $475690 }

{ @routine $4756F0 TPolyLineGI_StopAnimation }
procedure TPolyLineGI.StopAnimation;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
end;
{ @end $4756F0 }

{ @routine $475728 TPolyLineGI_AdvanceAnimation }
procedure TPolyLineGI.AdvanceAnimation(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Inc(AnimationPhase, 30);
  if AnimationPhase >= 360 then Dec(AnimationPhase, 360);
  Invalidate;
end;
{ @end $475728 }

{ @routine $47576C TPolyLineGI_Invalidate }
procedure TPolyLineGI.Invalidate;
begin
  if not FrameDrawing then
  begin
    inherited Invalidate;
    Exit;
  end;
  if ShadowCircle = nil then
  begin
    MessageLoop.UpdateRects.Clear;
    MessageLoop.UpdateRectsEnabled := True;
    MessageLoop.InvalidateViewport;
    MessageLoop.UpdateRectsEnabled := False;
  end;
end;
{ @end $47576C }

{ @routine $4757C8 TPolyLineGI_ErasePreviousFrame }
procedure TPolyLineGI.ErasePreviousFrame;
var Segment: PPolyLineSegmentGI;
begin
  FrameDrawing := True;
  if not SkipSavedPixelRestore then
  begin
    Segment := FirstSegment;
    while Segment <> nil do
    begin
      AllocatePixelBuffers(Segment);
      if Segment.PreviouslyVisible then
        Ex_OKGR_Line_CopyFromBuf_WORD(Segment.PreviousPixels, ScreenRenderBuffer.GetPixels,
          ScreenRenderBuffer.PitchBytes, Segment.PreviousFirst.X, Segment.PreviousFirst.Y,
          Segment.PreviousLast.X, Segment.PreviousLast.Y);
      Segment := Segment.Next;
    end;
  end;
end;
{ @end $4757C8 }

{ @routine $47585C TPolyLineGI_PrepareFrameDraw }
procedure TPolyLineGI.PrepareFrameDraw;
var Segment: PPolyLineSegmentGI; Clip: TRect;
begin
  FrameDrawing := True;
  if ShadowCircle <> nil then Clip := ShadowCircle.HitTestBounds
  else Clip := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Segment := FirstSegment;
  while Segment <> nil do
  begin
    AllocatePixelBuffers(Segment);
    Segment.PixelFirst := Classes.Point(Segment.First.X + AbsolutePosition.X, Segment.First.Y + AbsolutePosition.Y);
    Segment.PixelLast := Classes.Point(Segment.Last.X + AbsolutePosition.X, Segment.Last.Y + AbsolutePosition.Y);
    if Segment.Kind <> 2 then
    begin
      if Ex_OKGR_Line_Clip(Segment.PixelFirst.X, Segment.PixelFirst.Y,
        Segment.PixelLast.X, Segment.PixelLast.Y, Clip) = 0 then Segment.Visible := False
      else Segment.Visible := True;
    end
    else
    begin
      Segment.ClippedColor := Segment.Color;
      Segment.ClippedEndColor := Segment.EndColor;
      if Ex_OKGR_LineColor_Clip(Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.ClippedColor,
        Segment.PixelLast.X, Segment.PixelLast.Y, Segment.ClippedEndColor, Clip) = 0 then
        Segment.Visible := False
      else Segment.Visible := True;
    end;
    Segment := Segment.Next;
  end;
  Exit;
  // Retained native dormant background capture after the unconditional exit.
  Segment := FirstSegment;
  while Segment <> nil do
  begin
    if Segment.Visible then
      Ex_OKGR_Line_CopyToBuf_WORD(Segment.SavedPixels, ScreenRenderBuffer.GetPixels,
        ScreenRenderBuffer.PitchBytes, Segment.PixelFirst.X, Segment.PixelFirst.Y,
        Segment.PixelLast.X, Segment.PixelLast.Y);
    Segment := Segment.Next;
  end;
end;
{ @end $47585C }

{ @routine $475A50 TPolyLineGI_DrawUpdateRects }
procedure TPolyLineGI.DrawUpdateRects(ClipRect: TRect);
var Segment: PPolyLineSegmentGI; Clip: TRect;
begin
  FrameDrawing := True;
  Clip := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Segment := FirstSegment;
  while Segment <> nil do
  begin
    if Segment.Visible then DrawFrameSegment(Segment, Clip);
    Segment := Segment.Next;
  end;
end;
{ @end $475A50 }

{ @routine $475AD0 TPolyLineGI_Draw }
procedure TPolyLineGI.Draw(ClipRect: TRect);
var Segment: PPolyLineSegmentGI;
begin
  FrameDrawing := False;
  Segment := FirstSegment;
  while Segment <> nil do
  begin
    Segment.PixelFirst := Classes.Point(Segment.First.X + AbsolutePosition.X, Segment.First.Y + AbsolutePosition.Y);
    Segment.PixelLast := Classes.Point(Segment.Last.X + AbsolutePosition.X, Segment.Last.Y + AbsolutePosition.Y);
    DrawSegment(Segment, ClipRect);
    Segment := Segment.Next;
  end;
end;
{ @end $475AD0 }

{ @routine $475B88 TPolyLineGI_DrawSegment }
procedure TPolyLineGI.DrawSegment(Segment: PPolyLineSegmentGI; ClipRect: TRect);
begin
    if HardwareRenderingEnabled then
    begin
      if Segment.Animated then DrawAnimatedLineDX(Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.PixelLast.X, Segment.PixelLast.Y, Color565ToArgb(Segment.Color), AnimationPhase, @ClipRect)
      else DrawAnimatedLineDX(Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.PixelLast.X, Segment.PixelLast.Y, Color565ToArgb(Segment.Color), 0, @ClipRect);
    end
    else
    begin
      if Segment.Animated then ScreenRenderBuffer.DrawAnimatedLine16(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y), Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, AnimationPhase, ClipRect)
      else ScreenRenderBuffer.DrawAnimatedLine16(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y), Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, 0, ClipRect);
    end;
end;
{ @end $475B88 }

{ @routine $475CD0 TPolyLineGI_DrawFrameSegment }
procedure TPolyLineGI.DrawFrameSegment(Segment: PPolyLineSegmentGI; ClipRect: TRect);
var X, Y: Integer;
begin
  X := 0;
  Y := 0;
  if ShadowCircle = nil then
  begin
    if Segment.Kind = 0 then
    begin
    if HardwareRenderingEnabled then
    begin
      if Segment.Animated then DrawAnimatedLineDX(Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.PixelLast.X, Segment.PixelLast.Y, Color565ToArgb(Segment.Color), AnimationPhase, @ClipRect)
      else DrawAnimatedLineDX(Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.PixelLast.X, Segment.PixelLast.Y, Color565ToArgb(Segment.Color), 0, @ClipRect);
    end
    else
    begin
      if Segment.Animated then ScreenRenderBuffer.DrawAnimatedLine16(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y), Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, AnimationPhase, ClipRect)
      else ScreenRenderBuffer.DrawAnimatedLine16(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y), Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, 0, ClipRect);
    end;
    end
    else if Segment.Kind = 1 then
    begin
      if HardwareRenderingEnabled then
        DrawAlphaLine(Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.PixelLast.X, Segment.PixelLast.Y,
          Segment.Color, (Segment.Color shr 24) and $FF, @ClipRect)
      else ScreenRenderBuffer.DrawLine16Clipped(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y),
        Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, ClipRect);
    end
    else
    begin
      if HardwareRenderingEnabled then
        DrawGradientLine(Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.ClippedColor,
          Segment.PixelLast.X, Segment.PixelLast.Y, Segment.ClippedEndColor, @ClipRect)
      else LineRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
        Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.ClippedColor,
        Segment.PixelLast.X, Segment.PixelLast.Y, Segment.ClippedEndColor);
    end;
  end
  else
    if (ShadowCircle.LightBuffer <> nil) and (ShadowCircle.LightBuffer.GetPixels <> nil) and Segment.Visible then
    begin
      if not SkipSavedPixelRestore then
      begin
        Ex_OKGR_Line_CopyFromBuf_WORD(Segment.SavedPixels, ScreenRenderBuffer.GetPixels,
          ScreenRenderBuffer.PitchBytes, Segment.PixelFirst.X, Segment.PixelFirst.Y, Segment.PixelLast.X, Segment.PixelLast.Y);
        if Segment.Animated then ScreenRenderBuffer.DrawShadowLine16(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y), Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, AnimationPhase, ClipRect, AddPointerOffset(ShadowCircle.LightBuffer.GetPixels, ShadowCircle.LightBuffer.PitchBytes * Y + X), ShadowCircle.LightBuffer.PitchBytes)
        else ScreenRenderBuffer.DrawShadowLine16(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y), Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, 0, ClipRect, AddPointerOffset(ShadowCircle.LightBuffer.GetPixels, ShadowCircle.LightBuffer.PitchBytes * Y + X), ShadowCircle.LightBuffer.PitchBytes);
      end
      else
      begin
        if Segment.Animated then ScreenRenderBuffer.DrawAnimatedLine16(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y), Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, AnimationPhase, ClipRect)
        else ScreenRenderBuffer.DrawAnimatedLine16(Classes.Point(Segment.PixelFirst.X, Segment.PixelFirst.Y), Classes.Point(Segment.PixelLast.X, Segment.PixelLast.Y), Segment.Color, 0, ClipRect);
      end;
    end;
end;
{ @end $475CD0 }

{ @routine $4761F0 TPolyLineGI_CommitFrameDraw }
procedure TPolyLineGI.CommitFrameDraw;
begin

end;
{ @end $4761F0 }

end.
