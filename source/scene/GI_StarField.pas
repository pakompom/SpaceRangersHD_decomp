unit GI_StarField;

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
    constructor Create; // @addr $48CD74
    destructor Destroy; override; // @addr $48CDAC
    procedure Clear; // @addr $48CDD8
    function AllocatePoint: PStarFieldPoint; // @addr $48CDF8 @note "Grows by 100 when incremented Count reaches Capacity."
    procedure AddPoint(AX, AY, ADepth: Single; AColor: Integer); // @addr $48CE3C @ida "void __userpurge $name(TStarFieldList *Self@<eax>, int Color@<edx>, float X@<^8>, float Y@<^4>, float Depth@<^0>);" @note "Depth must be nonzero; retains the low 16 bits of Color."
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

    constructor Create(Owner: TObjectGI); // @addr $48CE78
    destructor Destroy; override; // @addr $48CF0C
    procedure SetBackgroundImage(const Path: WideString); // @addr $48CFA0
    procedure ClearProjectedPixels; // @addr $48CFC0
    procedure GrowPixelBuffers; // @addr $48CFCC
    procedure RebuildProjectedPixels; // @addr $48D00C
    procedure SetViewPosition(Position: TPointF); // @addr $48D138
    procedure SetSize(Size: TPoint); override; // @addr $48D19C
    procedure MarkViewDirty; // @addr $48D1D4
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $48D1DC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $48D208
    procedure LoadStarFieldProperties(Block: TBlockParEC); // @addr $48D224
    procedure Invalidate; override; // @addr $48D298 @note "Empty in native code."
    procedure UpdateBackgroundBounds; // @addr $48D29C @note "Updates GlobalsV.SkipSavedPixelRestore from the background rectangle change."
    procedure ErasePreviousFrame; override; // @addr $48D3E4
    procedure DrawBackground(ClipRect: TRect); // @addr $48D4C8
    procedure PrepareFrameDraw; override; // @addr $48D940
    procedure DrawUpdateRects(ClipRect: TRect); override; // @addr $48D9B8
    procedure Draw(ClipRect: TRect); override; // @addr $48D9F0 @note "Draws all projected pixels, ignoring ClipRect."
    procedure CommitFrameDraw; override; // @addr $48DA88
  end;

implementation

uses EC_Mem, EC_Cache, GR_Main, GR_DX, GR_Gi, GR_GraphBuf, GlobalsV, Classes, SysUtils, Windows;

{ @routine $48CD74 TStarFieldList_Create }
constructor TStarFieldList.Create;
begin
  inherited Create;
end;
{ @end $48CD74 }

{ @routine $48CDAC TStarFieldList_Destroy }
destructor TStarFieldList.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $48CDAC }

{ @routine $48CDD8 TStarFieldList_Clear }
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
{ @end $48CDD8 }

{ @routine $48CDF8 TStarFieldList_AllocatePoint }
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
{ @end $48CDF8 }

{ @routine $48CE3C TStarFieldList_AddPoint }
procedure TStarFieldList.AddPoint(AX, AY, ADepth: Single; AColor: Integer);
begin
  with AllocatePoint^ do
  begin
    X := AX;
    Y := AY;
    Depth := ADepth;
    InverseDepth := 1.0 / ADepth;
    Color := AColor;
  end;
end;
{ @end $48CE3C }

{ @routine $48CE78 TStarFieldGI_Create }
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
{ @end $48CE78 }

{ @routine $48CF0C TStarFieldGI_Destroy }
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
{ @end $48CF0C }

{ @routine $48CFA0 TStarFieldGI_SetBackgroundImage }
procedure TStarFieldGI.SetBackgroundImage(const Path: WideString);
begin
  inherited Invalidate;
  BackgroundCache.SetCacheKey(Path);
end;
{ @end $48CFA0 }

{ @routine $48CFC0 TStarFieldGI_ClearProjectedPixels }
procedure TStarFieldGI.ClearProjectedPixels;
begin
  PixelCount := 0;
end;
{ @end $48CFC0 }

{ @routine $48CFCC TStarFieldGI_GrowPixelBuffers }
procedure TStarFieldGI.GrowPixelBuffers;
begin
  Inc(PixelCapacity, 64);
  Pixels := ReAllocREC(Pixels, PixelCapacity * SizeOf(TStarFieldPixel));
  PreviousPixels := ReAllocREC(PreviousPixels, PixelCapacity * SizeOf(TStarFieldPixel));
end;
{ @end $48CFCC }

{ @routine $48D00C TStarFieldGI_RebuildProjectedPixels }
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
{ @end $48D00C }

{ @routine $48D138 TStarFieldGI_SetViewPosition }
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
{ @end $48D138 }

{ @routine $48D19C TStarFieldGI_SetSize }
procedure TStarFieldGI.SetSize(Size: TPoint);
begin
  if (ClientSize.X <> Size.X) or (ClientSize.Y <> Size.Y) then
  begin
    inherited SetSize(Size);
    ViewDirty := True;
  end;
end;
{ @end $48D19C }

{ @routine $48D1D4 TStarFieldGI_MarkViewDirty }
procedure TStarFieldGI.MarkViewDirty;
begin
  ViewDirty := True;
end;
{ @end $48D1D4 }

{ @routine $48D1DC TStarFieldGI_LoadFromConfigPath }
procedure TStarFieldGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadStarFieldProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $48D1DC }

{ @routine $48D208 TStarFieldGI_LoadFromBlock }
procedure TStarFieldGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadStarFieldProperties(Block);
end;
{ @end $48D208 }

{ @routine $48D224 TStarFieldGI_LoadStarFieldProperties }
procedure TStarFieldGI.LoadStarFieldProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Image') > 0 then SetBackgroundImage(Block.GetParam('Image'));
end;
{ @end $48D224 }

{ @routine $48D298 TStarFieldGI_Invalidate }
procedure TStarFieldGI.Invalidate;
begin
end;
{ @end $48D298 }

{ @routine $48D29C TStarFieldGI_UpdateBackgroundBounds }
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
{ @end $48D29C }

{ @routine $48D3E4 TStarFieldGI_ErasePreviousFrame }
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
{ @end $48D3E4 }

{ @routine $48D4C8 TStarFieldGI_DrawBackground }
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
      Dec(Height, Y);
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
      Dec(Height, Y);
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
            DrawTexture(Data.GetOrCreateFrameSurface(I), Bounds.Left, Bounds.Top, 255, RgbWhite, @Intersection, False, False)
          else
            Frame.DrawToGraphBuf(ScreenRenderBuffer, Bounds.Left, Bounds.Top, Intersection, 0, 255);
        end;
      end;
    finally
      BackgroundCache.Release;
    end;
  end;
end;
{ @end $48D4C8 }

{ @routine $48D940 TStarFieldGI_PrepareFrameDraw }
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
{ @end $48D940 }

{ @routine $48D9B8 TStarFieldGI_DrawUpdateRects }
procedure TStarFieldGI.DrawUpdateRects(ClipRect: TRect);
begin
  Draw(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
end;
{ @end $48D9B8 }

{ @routine $48D9F0 TStarFieldGI_Draw }
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
{ @end $48D9F0 }

{ @routine $48DA88 TStarFieldGI_CommitFrameDraw }
procedure TStarFieldGI.CommitFrameDraw;
begin
  if not HardwareRenderingEnabled then
  begin
    PreviousPixelCount := PixelCount;
    CopyMemory(PreviousPixels, Pixels, PreviousPixelCount * SizeOf(TStarFieldPixel));
    PreviousBackgroundBounds := BackgroundBounds;
  end;
end;
{ @end $48DA88 }

end.
