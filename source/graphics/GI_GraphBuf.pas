unit GI_GraphBuf;
// Unit bracket (inferred): .text 0x004828F8..0x00483EF6; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_Main, GI_MessageLoop, GR_GraphBuf, Types;

type
  TGraphBufGI = class(TObjectGI) // @size 0x12C
  public
    GraphBuf: TGraphBufGR; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    HalfAlpha: Boolean; // @offset 0x126
    SourceHasPerPixelAlpha: Boolean; // @offset 0x127
    UsesExternalGraphBuf: Boolean; // @offset 0x128

    constructor Create(Owner: TObjectGI; UseTexture: Boolean); // @addr 0x482A18 @ida "TGraphBufGI *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>, bool UseTexture@<^0>);"
    destructor Destroy; override; // @addr 0x482AA4 @ida "void __usercall $name(TGraphBufGI *Self@<eax>, __int8 DestroyFlags@<dl>);" @note "Frees GraphBuf only when it is owned."
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x482AFC
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x482B34
    procedure Clear; override; // @addr 0x482B6C @note "Detaches borrowed buffers without freeing them."
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x482BD8
    procedure AllocateBuffer(Width, Height: Integer; UseTexture: Boolean); // @addr 0x482C10 @note "Does not modify a previously borrowed buffer; the resulting buffer is owned."
    procedure ClearOwnedBuffer; // @addr 0x482C74
    procedure CopyScreenRectToBuffer(ScreenRect, BufferRect: TRect); // @addr 0x482C98 @ida "void __usercall $name(TGraphBufGI *Self@<eax>, TRect *ScreenRect@<edx>, TRect *BufferRect@<ecx>);" @note "Requires equal nonempty extents, in-bounds rectangles and a buffer without per-pixel alpha."
    procedure LoadBitmapPathAsRgba(const BitmapPath: WideString); // @addr 0x482E00
    procedure LoadBitmapPathAsRgb(const BitmapPath: WideString); // @addr 0x482EE4
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x482FC8 @ida "bool __usercall $name@<al>(TGraphBufGI *Self@<eax>, TPoint *Point@<edx>);" @note "Black pixels do not count as hits."
    function GetVisualCenter: TPoint; // @addr 0x483338 @ida "void __usercall $name(TGraphBufGI *Self@<eax>, TPoint *Result@<edx>);" @note "Uses nonzero pixels. CenterFill is unsupported and can leave bounds changed and temporary storage leaked."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x48372C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x483760
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x483788
    procedure LoadScaledBitmapPathAsRgba(const BitmapPath: WideString); // @addr 0x4838A0 @note "Fits the image inside the control size while preserving its aspect ratio."
    procedure LoadScaledGiPath(const GiPath: WideString); // @addr 0x48398C
    procedure Draw(ClipRect: TRect); override; // @addr 0x483AF8 @ida "void __usercall $name(TGraphBufGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure BindExternalGraphBuf(Buffer: TGraphBufGR); // @addr 0x483EA0 @note "Buffer is borrowed; alpha flags are unchanged."
  end;

implementation

uses EC_Cache, EC_CacheBitmap, EC_CacheGI, EC_Mem, GlobalsV, GR_Main, GR_DX, Classes, Windows;


{ @routine $482A18 TGraphBufGI_Create }
constructor TGraphBufGI.Create(Owner: TObjectGI; UseTexture: Boolean);
begin
  inherited Create(Owner);
  GraphBuf := TGraphBufGR.Create(UseTexture);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  HalfAlpha := False;
  UsesExternalGraphBuf := False;
end;
{ @end $482A18 }

{ @routine $482AA4 TGraphBufGI_Destroy }
destructor TGraphBufGI.Destroy;
begin
  if not UsesExternalGraphBuf then GraphBuf.Free;
  GraphBuf := nil;
  inherited Destroy;
end;
{ @end $482AA4 }

{ @routine $482AFC TGraphBufGI_SetImageKindX }
procedure TGraphBufGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $482AFC }

{ @routine $482B34 TGraphBufGI_SetImageKindY }
procedure TGraphBufGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $482B34 }

{ @routine $482B6C TGraphBufGI_Clear }
procedure TGraphBufGI.Clear;
begin
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  HalfAlpha := False;
  if UsesExternalGraphBuf then
  begin
    GraphBuf := nil;
    UsesExternalGraphBuf := False;
  end;
  if GraphBuf <> nil then GraphBuf.Clear;
  inherited Clear;
end;
{ @end $482B6C }

{ @routine $482BD8 TGraphBufGI_SetHalfAlpha }
procedure TGraphBufGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlpha <> Value then
  begin
    HalfAlpha := Value;
    Invalidate;
  end;
end;
{ @end $482BD8 }

{ @routine $482C10 TGraphBufGI_AllocateBuffer }
procedure TGraphBufGI.AllocateBuffer(Width, Height: Integer; UseTexture: Boolean);
begin
  if UsesExternalGraphBuf then GraphBuf := TGraphBufGR.Create(UseTexture);
  GraphBuf.AllocateNative(Width, Height);
  SourceHasPerPixelAlpha := False;
  UsesExternalGraphBuf := False;
end;
{ @end $482C10 }

{ @routine $482C74 TGraphBufGI_ClearOwnedBuffer }
procedure TGraphBufGI.ClearOwnedBuffer;
begin
  if not UsesExternalGraphBuf then GraphBuf.Clear;
end;
{ @end $482C74 }

{ @routine $482C98 TGraphBufGI_CopyScreenRectToBuffer }
procedure TGraphBufGI.CopyScreenRectToBuffer(ScreenRect, BufferRect: TRect);
begin
  if SourceHasPerPixelAlpha then Exit;
  if GraphBuf.GetPixels = nil then Exit;
  if ScreenRect.Right - ScreenRect.Left <> BufferRect.Right - BufferRect.Left then Exit;
  if ScreenRect.Bottom - ScreenRect.Top <> BufferRect.Bottom - BufferRect.Top then Exit;
  if ScreenRect.Right = ScreenRect.Left then Exit;
  if ScreenRect.Bottom = ScreenRect.Top then Exit;
  if ScreenRect.Left < 0 then Exit;
  if ScreenRect.Top < 0 then Exit;
  if GameScreenWidth < ScreenRect.Right then Exit;
  if GameScreenHeight < ScreenRect.Bottom then Exit;
  if BufferRect.Left < 0 then Exit;
  if BufferRect.Top < 0 then Exit;
  if GraphBuf.Width < BufferRect.Right then Exit;
  if GraphBuf.Height < BufferRect.Bottom then Exit;
  if HardwareRenderingEnabled then GraphBuf.LoadFromScreen(0)
  else Ex_OKGR_Copy_XY_XY_WORD(GraphBuf.GetPixels, GraphBuf.PitchBytes,
    BufferRect.Left, BufferRect.Top, ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
    ScreenRect.Left, ScreenRect.Top, BufferRect.Right - BufferRect.Left, BufferRect.Bottom - BufferRect.Top);
end;
{ @end $482C98 }

{ @routine $482E00 TGraphBufGI_LoadBitmapPathAsRgba }
procedure TGraphBufGI.LoadBitmapPathAsRgba(const BitmapPath: WideString);
var Control: TCacheControlEC; Bitmap: TCBitmapEC;
begin
  Control := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(BitmapPath);
  Bitmap := AcquireOrCreateBitmap(Control);
  try
    GraphBuf.AllocateRgba(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height, Bitmap.Bitmap.PitchBytes);
    CopyMemory(GraphBuf.GetPixels, Bitmap.Bitmap.GetPixels, GraphBuf.PitchBytes * GraphBuf.Height);
  finally
    Control.Release;
  end;
  Control.Free;
  SourceHasPerPixelAlpha := True;
end;
{ @end $482E00 }

{ @routine $482EE4 TGraphBufGI_LoadBitmapPathAsRgb }
procedure TGraphBufGI.LoadBitmapPathAsRgb(const BitmapPath: WideString);
var Control: TCacheControlEC; Bitmap: TCBitmapEC;
begin
  Control := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(BitmapPath);
  Bitmap := AcquireOrCreateBitmap(Control);
  try
    GraphBuf.AllocateRgb(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height, Bitmap.Bitmap.PitchBytes);
    CopyMemory(GraphBuf.GetPixels, Bitmap.Bitmap.GetPixels, GraphBuf.PitchBytes * GraphBuf.Height);
  finally
    Control.Release;
  end;
  Control.Free;
  SourceHasPerPixelAlpha := False;
end;
{ @end $482EE4 }

{ @routine $482FC8 TGraphBufGI_HitTestPixel }
function TGraphBufGI.HitTestPixel(Point: TPoint): Boolean;
var Width, Height, Left, Right, X, Top, Bottom, Y: Integer; Pixel: Cardinal; Pixels: Pointer; Buffer: TGraphBufGR; Clip: TRect;
begin
  Result := False;
  if GraphBuf.GetPixels = nil then Exit;
  Pixel := 0;
  Clip.Left := Point.X;
  Clip.Top := Point.Y;
  Clip.Right := Point.X + 1;
  Clip.Bottom := Point.Y + 1;
  Width := GraphBuf.Width;
  Height := GraphBuf.Height;
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
  else begin Result := False; Exit; end;
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
  else begin Result := False; Exit; end;
  Pixels := AddPointerOffset(@Pixel, -(ScreenRenderBuffer.PitchBytes * Point.Y + Point.X * SizeOf(Word)));
  Buffer := TGraphBufGR.Create(False);
  Buffer.AttachPixels(1, 1, ScreenRenderBuffer.PitchBytes, Pixels);
  if SourceHasPerPixelAlpha then
  begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawAlphaGraphBuffer16Clipped(Buffer.GetPixels, Buffer.PitchBytes, X, Y, GraphBuf, Clip);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  end
  else
  begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        CopyGraphBuffer16Clipped(Buffer.GetPixels, Buffer.PitchBytes, X, Y, GraphBuf, Clip, HalfAlpha, False);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  end;
  Buffer.Free;
  Result := Pixel <> 0;
end;
{ @end $482FC8 }

{ @routine $483338 TGraphBufGI_GetVisualCenter }
function TGraphBufGI.GetVisualCenter: TPoint;
var Buffer: TGraphBufGR; Width, Height, Left, Right, X, Top, Bottom, Y, Count: Integer; SavedBounds, Clip: TRect;
begin
  SavedBounds := HitTestBounds;
  Dec(HitTestBounds.Right, HitTestBounds.Left);
  Dec(HitTestBounds.Bottom, HitTestBounds.Top);
  HitTestBounds.Left := 0;
  HitTestBounds.Top := 0;
  Clip := HitTestBounds;
  Buffer := TGraphBufGR.Create(False);
  Buffer.AllocateNative(HitTestBounds.Right, HitTestBounds.Bottom);
  Width := GraphBuf.Width;
  Height := GraphBuf.Height;
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
  Buffer.ClearPixels;
  if SourceHasPerPixelAlpha then
  begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawAlphaGraphBuffer16Clipped(Buffer.GetPixels, Buffer.PitchBytes, X, Y, GraphBuf, Clip);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  end
  else
  begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        CopyGraphBuffer16Clipped(Buffer.GetPixels, Buffer.PitchBytes, X, Y, GraphBuf, Clip, HalfAlpha, False);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  end;
  Result.X := 0;
  Result.Y := 0;
  Count := 0;
  for Y := 0 to Buffer.Height - 1 do
    for X := 0 to Buffer.Width - 1 do
      if Buffer.GetPixel16(X, Y) <> 0 then
      begin
        Inc(Result.X, X);
        Inc(Result.Y, Y);
        Inc(Count);
      end;
  Buffer.Free;
  HitTestBounds := SavedBounds;
  if Count < 1 then Result := Classes.Point(0, 0)
  else Result := Classes.Point(Result.X div Count, Result.Y div Count);
end;
{ @end $483338 }

{ @routine $48372C TGraphBufGI_LoadFromConfigPath }
procedure TGraphBufGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $48372C }

{ @routine $483760 TGraphBufGI_LoadFromBlock }
procedure TGraphBufGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $483760 }

{ @routine $483788 TGraphBufGI_LoadImageProperties }
procedure TGraphBufGI.LoadImageProperties(Block: TBlockParEC);
begin
  if Block.CountParams('HalfAlpha') > 0 then SetHalfAlpha(ParseEnabledNameGI(Block.GetParam('HalfAlpha')));
  if Block.CountParams('CacheRGBA') > 0 then LoadScaledBitmapPathAsRgba(Block.GetParam('CacheRGBA'))
  else if Block.CountParams('CacheGI') > 0 then LoadScaledGiPath(Block.GetParam('CacheGI'));
end;
{ @end $483788 }

{ @routine $4838A0 TGraphBufGI_LoadScaledBitmapPathAsRgba }
procedure TGraphBufGI.LoadScaledBitmapPathAsRgba(const BitmapPath: WideString);
begin
  LoadBitmapPathAsRgba(BitmapPath);
  if GraphBuf.Width * ClientSize.Y >= GraphBuf.Height * ClientSize.X then
    GraphBuf.RescaleBilinearRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)))
  else GraphBuf.RescaleBilinearRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y);
end;
{ @end $4838A0 }

{ @routine $48398C TGraphBufGI_LoadScaledGiPath }
procedure TGraphBufGI.LoadScaledGiPath(const GiPath: WideString);
var Control: TCacheControlEC; Image: TCGiEC;
begin
  SourceHasPerPixelAlpha := True;
  Control := TCGiControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(GiPath);
  Image := AcquireCachedGi(Control);
  try
    Image.Image.DecodeToGraphBuf(GraphBuf, False);
  finally
    Control.Release;
  end;
  Control.Free;
  if GraphBuf.Width * ClientSize.Y >= GraphBuf.Height * ClientSize.X then
    GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
  else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
end;
{ @end $48398C }

{ @routine $483AF8 TGraphBufGI_Draw }
procedure TGraphBufGI.Draw(ClipRect: TRect);
var Width, Height, Left, Right, X, Top, Bottom, Y: Integer;
begin
  if GraphBuf.GetPixels = nil then Exit;
  Width := GraphBuf.Width;
  Height := GraphBuf.Height;
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
  if HardwareRenderingEnabled then
  begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawTexture(GraphBuf.GetTexture, X, Y, 255 - (Ord(HalfAlpha) shl 7), $FFFFFF, @ClipRect, False, False);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  end
  else if SourceHasPerPixelAlpha then
  begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        DrawAlphaGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, GraphBuf, ClipRect);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  end
  else
  begin
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        CopyGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, GraphBuf, ClipRect, HalfAlpha, False);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  end;

end;
{ @end $483AF8 }

{ @routine $483EA0 TGraphBufGI_BindExternalGraphBuf }
procedure TGraphBufGI.BindExternalGraphBuf(Buffer: TGraphBufGR);
begin
  if (GraphBuf <> nil) and not UsesExternalGraphBuf then
  begin
    GraphBuf.Free;
    GraphBuf := nil;
  end;
  GraphBuf := Buffer;
  UsesExternalGraphBuf := True;
end;
{ @end $483EA0 }

end.
