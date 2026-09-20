unit GI_GI;
// Unit bracket (inferred): .text 0x0047B4D4..0x0047C67E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheGI, GI_Main, GI_MessageLoop, GR_GraphBuf, Types;

type
  TgiGI = class(TObjectGI) // @size 0x128
  public
    ImageCache: TCGiControlEC; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    Alpha: Byte; // @offset 0x126
    HardwareMirrorHorizontal: Boolean; // @offset $127  Passed to the hardware texture draw only.

    constructor Create(Owner: TObjectGI); // @addr 0x47B5F0
    destructor Destroy; override; // @addr 0x47B680
    procedure Clear; override; // @addr 0x47B6CC @note "Preserves alpha and the cache key."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x47B6F4
    function GetImagePath: WideString; // @addr 0x47B738
    function GetContentSize: TPoint; // @addr 0x47B75C
    function GetContentOrigin: TPoint; // @addr 0x47B7BC
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x47B82C
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x47B864
    procedure SetHardwareMirrorHorizontal(Value: Boolean); // @addr $47C1A4
    procedure SetAlpha(Value: Byte); // @addr 0x47B89C
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x47B8D4 @note "Black pixels do not count as hits."
    function GetVisualCenter: TPoint; // @addr 0x47BBF4 @note "Returns the mean coordinates of nonzero rendered pixels, or (0,0) when none exist."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x47BFBC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x47BFF0
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x47C018
    procedure Draw(ClipRect: TRect); override; // @addr 0x47C1C0
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x47C5D4
  end;

procedure LoadGiByPathIntoGraphBuf(const GiPath: WideString; Destination: TGraphBufGR); // @addr 0x47C5F8

implementation

uses EC_Cache, EC_Mem, GR_Main, GR_DX, GlobalsV;


{ @routine $47B5F0 TgiGI_Create }
constructor TgiGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCGiControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  Alpha := 255;
end;
{ @end $47B5F0 }

{ @routine $47B680 TgiGI_Destroy }
destructor TgiGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $47B680 }

{ @routine $47B6CC TgiGI_Clear }
procedure TgiGI.Clear;
begin
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  inherited Clear;
end;
{ @end $47B6CC }

{ @routine $47B6F4 TgiGI_SetImagePath }
procedure TgiGI.SetImagePath(const ImagePath: WideString);
begin
  if ImageCache.CacheKey <> ImagePath then
  begin
    Invalidate;
    ImageCache.SetCacheKey(ImagePath);
  end;
end;
{ @end $47B6F4 }

{ @routine $47B738 TgiGI_GetImagePath }
function TgiGI.GetImagePath: WideString;
begin
  Result := ImageCache.CacheKey;
end;
{ @end $47B738 }

{ @routine $47B75C TgiGI_GetContentSize }
function TgiGI.GetContentSize: TPoint;
var Image: TCGiEC;
begin
  Image := AcquireCachedGi(ImageCache);
  try
    Result := Image.Image.GetContentSize;
  finally
    ImageCache.Release;
  end;
end;
{ @end $47B75C }

{ @routine $47B7BC TgiGI_GetContentOrigin }
function TgiGI.GetContentOrigin: TPoint;
var Image: TCGiEC; Bounds: TRect;
begin
  Image := AcquireCachedGi(ImageCache);
  try
    Bounds := Image.Image.GetBoundsRect;
    Result := Bounds.TopLeft;
  finally
    ImageCache.Release;
  end;
end;
{ @end $47B7BC }

{ @routine $47B82C TgiGI_SetImageKindX }
procedure TgiGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $47B82C }

{ @routine $47B864 TgiGI_SetImageKindY }
procedure TgiGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $47B864 }

{ @routine $47B89C TgiGI_SetAlpha }
procedure TgiGI.SetAlpha(Value: Byte);
begin
  if Alpha <> Value then
  begin
    Alpha := Value;
    Invalidate;
  end;
end;
{ @end $47B89C }

{ @routine $47B8D4 TgiGI_HitTestPixel }
function TgiGI.HitTestPixel(Point: TPoint): Boolean;
var Image: TCGiEC; Width, Height, Left, Right, X, Top, Bottom, Y: Integer; Pixel: Cardinal; Pixels: Pointer; Buffer: TGraphBufGR; Clip: TRect;
begin
  Result := False;
  Pixel := 0;
  Clip.Left := Point.X;
  Clip.Top := Point.Y;
  Clip.Right := Point.X + 1;
  Clip.Bottom := Point.Y + 1;
  Image := AcquireCachedGi(ImageCache);
  try
  Width := Image.Image.GetContentSize.X;
  Height := Image.Image.GetContentSize.Y;
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
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        Image.Image.DrawToGraphBuf(Buffer, X, Y, Clip, 0, 255);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
    Buffer.Free;
  finally
    ImageCache.Release;
  end;
  Result := Pixel <> 0;
end;
{ @end $47B8D4 }

{ @routine $47BBF4 TgiGI_GetVisualCenter }
function TgiGI.GetVisualCenter: TPoint;
var Buffer: TGraphBufGR; Image: TCGiEC; Width, Height, Left, Right, X, Top, Bottom, Y, Count: Integer; SavedBounds, Clip: TRect;
begin
  SavedBounds := HitTestBounds;
  Dec(HitTestBounds.Right, HitTestBounds.Left);
  Dec(HitTestBounds.Bottom, HitTestBounds.Top);
  HitTestBounds.Left := 0;
  HitTestBounds.Top := 0;
  Clip := HitTestBounds;
  Buffer := TGraphBufGR.Create(False);
  Buffer.AllocateNative(HitTestBounds.Right, HitTestBounds.Bottom);
  Image := AcquireCachedGi(ImageCache);
  try
  Width := Image.Image.GetContentSize.X;
  Height := Image.Image.GetContentSize.Y;
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
    Y := Top;
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        Image.Image.DrawToGraphBuf(Buffer, X, Y, Clip, 0, 255);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  finally
    ImageCache.Release;
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
{ @end $47BBF4 }

{ @routine $47BFBC TgiGI_LoadFromConfigPath }
procedure TgiGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $47BFBC }

{ @routine $47BFF0 TgiGI_LoadFromBlock }
procedure TgiGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $47BFF0 }

{ @routine $47C018 TgiGI_LoadImageProperties }
procedure TgiGI.LoadImageProperties(Block: TBlockParEC);
begin
  ImageCache.SetCacheKey(Block.GetParam('Image'));
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('AlignX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('AlignX')));
  if Block.CountParams('AlignY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('AlignY')));
end;
{ @end $47C018 }

{ @routine $47C1A4 TgiGI_SetHardwareMirrorHorizontal }
procedure TgiGI.SetHardwareMirrorHorizontal(Value: Boolean);
begin
  HardwareMirrorHorizontal := Value;
end;
{ @end $47C1A4 }

{ @routine $47C1C0 TgiGI_Draw }
procedure TgiGI.Draw(ClipRect: TRect);
var Image: TCGiEC; Width, Height, Left, Right, X, Top, Bottom, Y, TileIndex: Integer; TileOrigin: TPoint;
begin
  Image := AcquireCachedGi(ImageCache);
  try
  Width := Image.Image.GetContentSize.X;
  Height := Image.Image.GetContentSize.Y;
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
    if Image.UsesTiledSurfaces then
    begin
    while Y < Bottom do
    begin
      X := Left;
      while X < Right do
      begin
        TileIndex := 0;
        while TileIndex < Image.TileCount do
        begin
          TileOrigin := Image.GetTileOrigin(TileIndex);
          DrawTexture(Image.GetOrCreateSurface(TileIndex), X + TileOrigin.X, Y + TileOrigin.Y, Alpha, $FFFFFF, @ClipRect, False, HardwareMirrorHorizontal);
          Inc(TileIndex);
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
        DrawTexture(Image.GetOrCreateSurface(0), X, Y, Alpha, $FFFFFF, @ClipRect, False, HardwareMirrorHorizontal);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
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
        Image.Image.DrawToGraphBuf(ScreenRenderBuffer, X, Y, ClipRect, 0, Alpha);
        Inc(X, Width);
      end;
      Inc(Y, Height);
    end;
  end;
  finally
    ImageCache.Release;
  end;
end;
{ @end $47C1C0 }

{ @routine $47C5D4 TgiGI_QueueImageLoad }
procedure TgiGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $47C5D4 }

{ @routine $47C5F8 LoadGiByPathIntoGraphBuf }
procedure LoadGiByPathIntoGraphBuf(const GiPath: WideString; Destination: TGraphBufGR);
var Control: TCacheControlEC; Image: TCGiEC;
begin
  Control := TCGiControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(GiPath);
  Image := AcquireCachedGi(Control);
  try
    Image.Image.DecodeToGraphBuf(Destination, False);
  finally
    Control.Release;
  end;
  Control.Free;
end;
{ @end $47C5F8 }

end.
