unit GI_StarField;
// Unit bracket (inferred): .text 0x004B00F8..0x004B135E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, GI_Panel, GI_MessageLoop, EC_CacheGAI, EC_BlockPar, Types;

type
  TStarFieldPoint = record // @size $14
    X: Single; // @offset $00
    Y: Single; // @offset $04
    Depth: Single; // @offset $08
    InverseDepth: Single; // @offset $0C
    Color: Word; // @offset $10
  end;
  PStarFieldPoint = ^TStarFieldPoint;

  TStarFieldPixel = record // @size $10
    ByteOffset: Integer; // @offset $00
    Position: TPoint; // @offset $04
    Color: Word; // @offset $0C
    SavedPixel: Word; // @offset $0E
  end;
  PStarFieldPixel = ^TStarFieldPixel;

  TStarFieldList = class(TObject) // @size $10
  public
    Points: PStarFieldPoint; // @offset $04
    Count: Integer; // @offset $08
    Capacity: Integer; // @offset $0C
    constructor Create; // @addr $4B027C
    destructor Destroy; override; // @addr $4B02C0
    procedure Clear; // @addr $4B02FC
    function AllocatePoint: PStarFieldPoint; // @addr $4B0334 @note "Grows by 100 when incremented Count reaches Capacity."
    procedure AddPoint(X, Y, Depth: Single; Color: Integer); // @addr $4B039C @ida "void __userpurge $name(TStarFieldList *Self@<eax>, int Color@<edx>, float X@<^8>, float Y@<^4>, float Depth@<^0>);" @note "Depth must be nonzero; retains the low 16 bits of Color."
  end;

  TStarFieldGI = class(TPanelGI) // @size $190
  public
    BackgroundCache: TCGaiControlEC; // @offset $140
    Stars: TStarFieldList; // @offset $144
    ViewPosition: TPointF; // @offset $148
    Unknown150: Integer; // @offset $150
    ViewDirty: Boolean; // @offset $154
    Pixels: PStarFieldPixel; // @offset $158
    PixelCapacity: Integer; // @offset $15C
    PixelCount: Integer; // @offset $160
    PreviousPixels: PStarFieldPixel; // @offset $164
    PreviousPixelCount: Integer; // @offset $168
    BackgroundScale: Single; // @offset $16C
    PreviousBackgroundBounds: TRect; // @offset $170
    BackgroundBounds: TRect; // @offset $180

    constructor Create(Owner: TObjectGI); // @addr $4B03F4
    destructor Destroy; override; // @addr $4B04A8
    procedure SetBackgroundImage(const Path: WideString); // @addr $4B0578
    procedure ClearProjectedPixels; // @addr $4B05A4
    procedure GrowPixelBuffers; // @addr $4B05BC
    procedure RebuildProjectedPixels; // @addr $4B0618
    procedure SetViewPosition(Position: TPointF); // @addr $4B0794
    procedure SetSize(Size: TPoint); override; // @addr $4B0808
    procedure MarkViewDirty; // @addr $4B084C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4B0860
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4B0894
    procedure LoadStarFieldProperties(Block: TBlockParEC); // @addr $4B08BC
    procedure Invalidate; override; // @addr $4B0938 @note "Empty in native code."
    procedure UpdateBackgroundBounds; // @addr $4B0944 @note "Updates GlobalsV.SkipSavedPixelRestore from the background rectangle change."
    procedure ErasePreviousFrame; override; // @addr $4B0AA8
    procedure DrawBackground(ClipRect: TRect); // @addr $4B0BE0
    procedure PrepareFrameDraw; override; // @addr $4B112C
    procedure DrawUpdateRects(ClipRect: TRect); override; // @addr $4B11D8
    procedure Draw(ClipRect: TRect); override; // @addr $4B1220 @note "Draws all projected pixels, ignoring ClipRect."
    procedure CommitFrameDraw; override; // @addr $4B12FC
  end;

implementation

uses EC_Mem, EC_Cache, GR_Main, GR_DX, GR_Gi, GR_GraphBuf, GlobalsV, Classes, SysUtils, Windows;

{ @routine $4B027C TStarFieldList_Create }
constructor TStarFieldList.Create;
begin
  inherited Create;
end;
{ @end $4B027C }

{ @routine $4B02C0 TStarFieldList_Destroy }
destructor TStarFieldList.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $4B02C0 }

{ @routine $4B02FC TStarFieldList_Clear }
procedure TStarFieldList.Clear;
begin
  if Points <> nil then
  begin
    FreeEC(Points);
    Points := nil;
  end;
  Capacity := 0;
  Count := 0;
end;
{ @end $4B02FC }

{ @routine $4B0334 TStarFieldList_AllocatePoint }
function TStarFieldList.AllocatePoint: PStarFieldPoint;
begin
  Inc(Count);
  if Count >= Capacity then
  begin
    Inc(Capacity, 100);
    Points := ReAllocREC(Points, Capacity * SizeOf(TStarFieldPoint));
  end;
  Result := AddPointerOffset(Points, (Count - 1) * SizeOf(TStarFieldPoint));
end;
{ @end $4B0334 }

{ @routine $4B039C TStarFieldList_AddPoint }
procedure TStarFieldList.AddPoint(X, Y, Depth: Single; Color: Integer);
var Point: PStarFieldPoint;
begin
  Point := AllocatePoint;
  Point.X := X;
  Point.Y := Y;
  Point.Depth := Depth;
  Point.InverseDepth := 1.0 / Depth;
  Point.Color := Color;
end;
{ @end $4B039C }

{ @routine $4B03F4 TStarFieldGI_Create }
constructor TStarFieldGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  BackgroundCache := TCGaiControlEC.Create;
  GlobalCache.ResetControl(BackgroundCache);
  Stars := TStarFieldList.Create;
  ViewDirty := True;
  MessageLoop.RegionDrawControl := Self;
  Unknown150 := 0;
  BackgroundScale := 8.0;
end;
{ @end $4B03F4 }

{ @routine $4B04A8 TStarFieldGI_Destroy }
destructor TStarFieldGI.Destroy;
begin
  MessageLoop.RegionDrawControl := nil;
  Stars.Free;
  if Pixels <> nil then
  begin
    FreeEC(Pixels);
    Pixels := nil;
  end;
  PixelCount := 0;
  PixelCapacity := 0;
  if PreviousPixels <> nil then
  begin
    FreeEC(PreviousPixels);
    PreviousPixels := nil;
  end;
  PreviousPixelCount := 0;
  BackgroundCache.Free;
  BackgroundCache := nil;
  inherited Destroy;
end;
{ @end $4B04A8 }

{ @routine $4B0578 TStarFieldGI_SetBackgroundImage }
procedure TStarFieldGI.SetBackgroundImage(const Path: WideString);
begin
  inherited Invalidate;
  BackgroundCache.SetCacheKey(Path);
end;
{ @end $4B0578 }

{ @routine $4B05A4 TStarFieldGI_ClearProjectedPixels }
procedure TStarFieldGI.ClearProjectedPixels;
begin
  PixelCount := 0;
end;
{ @end $4B05A4 }

{ @routine $4B05BC TStarFieldGI_GrowPixelBuffers }
procedure TStarFieldGI.GrowPixelBuffers;
begin
  Inc(PixelCapacity, 64);
  Pixels := ReAllocREC(Pixels, PixelCapacity * SizeOf(TStarFieldPixel));
  PreviousPixels := ReAllocREC(PreviousPixels, PixelCapacity * SizeOf(TStarFieldPixel));
end;
{ @end $4B05BC }

{ @routine $4B0618 TStarFieldGI_RebuildProjectedPixels }
procedure TStarFieldGI.RebuildProjectedPixels;
var
  Point: PStarFieldPoint;
  Pixel: PStarFieldPixel;
  Position: TPoint;
  Left, Top, Right, Bottom, I, Pitch: Integer;
begin
  ClearProjectedPixels;
  Pitch := ScreenRenderBuffer.PitchBytes;
  Left := HitTestBounds.Left;
  Top := HitTestBounds.Top;
  Right := HitTestBounds.Right;
  Bottom := HitTestBounds.Bottom;
  Point := Stars.Points;
  for I := 0 to Stars.Count - 1 do
  begin
    Position.X := Integer(Round((Point.X - ViewPosition.X) * Point.InverseDepth)) + AbsolutePosition.X;
    Position.Y := Integer(Round((Point.Y - ViewPosition.Y) * Point.InverseDepth)) + AbsolutePosition.Y;
    if (Position.X >= Left) and (Position.X < Right) and (Position.Y >= Top) and (Position.Y < Bottom) then
    begin
      Inc(PixelCount);
      if PixelCount > PixelCapacity then GrowPixelBuffers;
      Pixel := AddPointerOffset(Pixels, (PixelCount - 1) * SizeOf(TStarFieldPixel));
      Pixel.ByteOffset := Position.X * 2 + Position.Y * Pitch;
      Pixel.Position := Position;
      Pixel.Color := Point.Color;
    end;
    Point := AddPointerOffset(Point, SizeOf(TStarFieldPoint));
  end;
end;
{ @end $4B0618 }

{ @routine $4B0794 TStarFieldGI_SetViewPosition }
procedure TStarFieldGI.SetViewPosition(Position: TPointF);
begin
  if (ViewPosition.X <> Position.X) or (ViewPosition.Y <> Position.Y) then
  begin
    Invalidate;
    ViewPosition := Position;
    ViewDirty := True;
    Invalidate;
  end;
end;
{ @end $4B0794 }

{ @routine $4B0808 TStarFieldGI_SetSize }
procedure TStarFieldGI.SetSize(Size: TPoint);
begin
  if (ClientSize.X <> Size.X) or (ClientSize.Y <> Size.Y) then
  begin
    inherited SetSize(Size);
    ViewDirty := True;
  end;
end;
{ @end $4B0808 }

{ @routine $4B084C TStarFieldGI_MarkViewDirty }
procedure TStarFieldGI.MarkViewDirty;
begin
  ViewDirty := True;
end;
{ @end $4B084C }

{ @routine $4B0860 TStarFieldGI_LoadFromConfigPath }
procedure TStarFieldGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadStarFieldProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B0860 }

{ @routine $4B0894 TStarFieldGI_LoadFromBlock }
procedure TStarFieldGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadStarFieldProperties(Block);
end;
{ @end $4B0894 }

{ @routine $4B08BC TStarFieldGI_LoadStarFieldProperties }
procedure TStarFieldGI.LoadStarFieldProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Image') > 0 then SetBackgroundImage(Block.GetParam('Image'));
end;
{ @end $4B08BC }

{ @routine $4B0938 TStarFieldGI_Invalidate }
procedure TStarFieldGI.Invalidate;
begin
end;
{ @end $4B0938 }

{ @routine $4B0944 TStarFieldGI_UpdateBackgroundBounds }
procedure TStarFieldGI.UpdateBackgroundBounds;
var Data: TCGaiEC; X, Y, Width, Height: Integer; Bounds: TRect;
begin
  SkipSavedPixelRestore := False;
  if BGImage then
    if BackgroundCache.CacheKey <> '' then
    begin
      SkipSavedPixelRestore := True;
      Data := AcquireCachedGai(BackgroundCache);
      try
        Bounds := Data.GetBoundsRect;
      finally
        BackgroundCache.Release;
      end;
      Width := Bounds.Right - Bounds.Left;
      Height := Bounds.Bottom - Bounds.Top;
      X := Integer(Round((0.0 - ViewPosition.X) / BackgroundScale)) + AbsolutePosition.X - Width div 2;
      Y := Integer(Round((0.0 - ViewPosition.Y) / BackgroundScale)) + AbsolutePosition.Y - Height div 2;
      Bounds.Left := X;
      Bounds.Top := Y;
      Bounds.Right := X + Width;
      Bounds.Bottom := Y + Height;
      BackgroundBounds := Bounds;
      SkipSavedPixelRestore := not CompareMem(@BackgroundBounds, @PreviousBackgroundBounds, SizeOf(TRect));
    end;
end;
{ @end $4B0944 }

{ @routine $4B0AA8 TStarFieldGI_ErasePreviousFrame }
procedure TStarFieldGI.ErasePreviousFrame;
var Pixel: PStarFieldPixel; Buffer: Pointer; I: Integer;
begin
  if ViewDirty then
  begin
    RebuildProjectedPixels;
    ViewDirty := False;
  end;
  if not HardwareRenderingEnabled then
  begin
    Buffer := ScreenRenderBuffer.GetPixels;
    if not SkipSavedPixelRestore then
    begin
      if (not BGImage) or (BackgroundCache.CacheKey = '') then
      begin
        Pixel := PreviousPixels;
        for I := 0 to PreviousPixelCount - 1 do
        begin
          WriteWordEC(AddPointerOffset(Buffer, Pixel.ByteOffset), 0);
          Pixel := AddPointerOffset(Pixel, SizeOf(TStarFieldPixel));
        end;
      end
      else
      begin
        Pixel := PreviousPixels;
        for I := 0 to PreviousPixelCount - 1 do
        begin
          WriteWordEC(AddPointerOffset(Buffer, Pixel.ByteOffset), Pixel.SavedPixel);
          Pixel := AddPointerOffset(Pixel, SizeOf(TStarFieldPixel));
        end;
      end;
    end;
  end;
end;
{ @end $4B0AA8 }

{ @routine $4B0BE0 TStarFieldGI_DrawBackground }
procedure TStarFieldGI.DrawBackground(ClipRect: TRect);
var
  I, X, Y, Width, Height: Integer;
  Data: TCGaiEC;
  Frame: TgiGR;
  Intersection, Bounds: TRect;
begin
  if (not BGImage) or (BackgroundCache.CacheKey = '') or
    (BackgroundBounds.Top >= ClipRect.Bottom) or (BackgroundBounds.Bottom <= ClipRect.Top) or
    (BackgroundBounds.Left >= ClipRect.Right) or (BackgroundBounds.Right <= ClipRect.Left) then
  begin
    X := ClipRect.Left;
    Y := ClipRect.Top;
    Width := ClipRect.Right - X;
    Height := ClipRect.Bottom - Y;
    if HardwareRenderingEnabled then
      DrawColoredRect(X, Y, Width, Height, 0, 255, True, @ClipRect)
    else
      Ex_OKGR_Fill_WORD(AddPointerOffset(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes * Y + X * 2), ScreenRenderBuffer.PitchBytes, Width, Height, 0);
  end
  else
  begin
    if BackgroundBounds.Top > ClipRect.Top then
    begin
      X := ClipRect.Left;
      Y := ClipRect.Top;
      Width := ClipRect.Right - ClipRect.Left;
      Height := BackgroundBounds.Top - ClipRect.Top;
      if HardwareRenderingEnabled then
        DrawColoredRect(X, Y, Width, Height, 0, 255, True, @ClipRect)
      else
        Ex_OKGR_Fill_WORD(AddPointerOffset(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes * Y + X * 2), ScreenRenderBuffer.PitchBytes, Width, Height, 0);
    end;
    if BackgroundBounds.Bottom < ClipRect.Bottom then
    begin
      X := ClipRect.Left;
      Y := BackgroundBounds.Bottom;
      Width := ClipRect.Right - ClipRect.Left;
      Height := ClipRect.Bottom - BackgroundBounds.Bottom;
      if HardwareRenderingEnabled then
        DrawColoredRect(X, Y, Width, Height, 0, 255, True, @ClipRect)
      else
        Ex_OKGR_Fill_WORD(AddPointerOffset(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes * Y + X * 2), ScreenRenderBuffer.PitchBytes, Width, Height, 0);
    end;
    if BackgroundBounds.Left > ClipRect.Left then
    begin
      X := ClipRect.Left;
      Y := BackgroundBounds.Top;
      if Y < ClipRect.Top then Y := ClipRect.Top;
      Width := BackgroundBounds.Left - ClipRect.Left;
      Height := BackgroundBounds.Bottom;
      if Height > ClipRect.Bottom then Height := ClipRect.Bottom;
      Height := Height - Y;
      if HardwareRenderingEnabled then
        DrawColoredRect(X, Y, Width, Height, 0, 255, True, @ClipRect)
      else
        Ex_OKGR_Fill_WORD(AddPointerOffset(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes * Y + X * 2), ScreenRenderBuffer.PitchBytes, Width, Height, 0);
    end;
    if BackgroundBounds.Right < ClipRect.Right then
    begin
      X := BackgroundBounds.Right;
      Y := BackgroundBounds.Top;
      if Y < ClipRect.Top then Y := ClipRect.Top;
      Width := ClipRect.Right - BackgroundBounds.Right;
      Height := BackgroundBounds.Bottom;
      if Height > ClipRect.Bottom then Height := ClipRect.Bottom;
      Height := Height - Y;
      if HardwareRenderingEnabled then
        DrawColoredRect(X, Y, Width, Height, 0, 255, True, @ClipRect)
      else
        Ex_OKGR_Fill_WORD(AddPointerOffset(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes * Y + X * 2), ScreenRenderBuffer.PitchBytes, Width, Height, 0);
    end;
    Data := AcquireCachedGai(BackgroundCache);
    try
      for I := 0 to Data.GetFrameCount - 1 do
      begin
        Frame := Data.LoadFrameGi(I);
        Bounds := Frame.GetBoundsRect;
        Inc(Bounds.Left, BackgroundBounds.Left);
        Inc(Bounds.Top, BackgroundBounds.Top);
        Inc(Bounds.Right, BackgroundBounds.Left);
        Inc(Bounds.Bottom, BackgroundBounds.Top);
        if IntersectRects(Intersection, ClipRect, Bounds) then
        begin
          if HardwareRenderingEnabled then
            DrawTexture(Data.GetOrCreateFrameSurface(I), Bounds.Left, Bounds.Top, 255, $FFFFFF, @Intersection, False, False)
          else
            Frame.DrawToGraphBuf(ScreenRenderBuffer, Bounds.Left, Bounds.Top, Intersection, 0, 255);
        end;
      end;
    finally
      BackgroundCache.Release;
    end;
  end;
end;
{ @end $4B0BE0 }

{ @routine $4B112C TStarFieldGI_PrepareFrameDraw }
procedure TStarFieldGI.PrepareFrameDraw;
var Pixel: PStarFieldPixel; I: Integer; Buffer: Pointer;
begin
  if not HardwareRenderingEnabled then
    if BGImage then
      if BackgroundCache.CacheKey <> '' then
      begin
        Buffer := ScreenRenderBuffer.GetPixels;
        Pixel := Pixels;
        for I := 0 to PixelCount - 1 do
        begin
          Pixel.SavedPixel := ReadWordEC(AddPointerOffset(Buffer, Pixel.ByteOffset));
          Pixel := AddPointerOffset(Pixel, SizeOf(TStarFieldPixel));
        end;
      end;
end;
{ @end $4B112C }

{ @routine $4B11D8 TStarFieldGI_DrawUpdateRects }
procedure TStarFieldGI.DrawUpdateRects(ClipRect: TRect);
begin
  Draw(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
end;
{ @end $4B11D8 }

{ @routine $4B1220 TStarFieldGI_Draw }
procedure TStarFieldGI.Draw(ClipRect: TRect);
var Pixel: PStarFieldPixel; Buffer: Pointer; Count: Integer;
begin
  Pixel := Pixels;
  Count := PixelCount;
  if HardwareRenderingEnabled then
  begin
    while Count > 0 do
    begin
      QueueDrawPoint(Pixel.Position.X, Pixel.Position.Y, Color565ToArgb(Pixel.Color), 255);
      Pixel := AddPointerOffset(Pixel, SizeOf(TStarFieldPixel));
      Dec(Count);
    end;
    FlushDrawPoints(nil);
  end
  else
  begin
    Buffer := ScreenRenderBuffer.GetPixels;
    while Count > 0 do
    begin
      WriteWordEC(AddPointerOffset(Buffer, Pixel.ByteOffset), Pixel.Color);
      Pixel := AddPointerOffset(Pixel, SizeOf(TStarFieldPixel));
      Dec(Count);
    end;
  end;
end;
{ @end $4B1220 }

{ @routine $4B12FC TStarFieldGI_CommitFrameDraw }
procedure TStarFieldGI.CommitFrameDraw;
begin
  if not HardwareRenderingEnabled then
  begin
    PreviousPixelCount := PixelCount;
    CopyMemory(PreviousPixels, Pixels, PreviousPixelCount * SizeOf(TStarFieldPixel));
    PreviousBackgroundBounds := BackgroundBounds;
  end;
end;
{ @end $4B12FC }

end.
