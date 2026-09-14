unit GI_GI;
// Unit bracket (inferred): .text 0x00486A18..0x00487BC2; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create(Owner: TObjectGI); // @addr 0x486B34 @ida "TgiGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x486BC4 @ida "void __usercall $name(TgiGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x486C10 @note "Preserves alpha and the cache key."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x486C38
    function GetImagePath: WideString; // @addr 0x486C7C @ida "void __usercall $name(TgiGI *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetContentSize: TPoint; // @addr 0x486CA0 @ida "void __usercall $name(TgiGI *Self@<eax>, TPoint *Result@<edx>);"
    function GetContentOrigin: TPoint; // @addr 0x486D00 @ida "void __usercall $name(TgiGI *Self@<eax>, TPoint *Result@<edx>);"
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x486D70
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x486DA8
    procedure SetHardwareMirrorHorizontal(Value: Boolean); // @addr $4876E8
    procedure SetAlpha(Value: Byte); // @addr 0x486DE0
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x486E18 @ida "bool __usercall $name@<al>(TgiGI *Self@<eax>, TPoint *Point@<edx>);" @note "Black pixels do not count as hits."
    function GetVisualCenter: TPoint; // @addr 0x487138 @ida "void __usercall $name(TgiGI *Self@<eax>, TPoint *Result@<edx>);" @note "Returns the mean coordinates of nonzero rendered pixels, or (0,0) when none exist."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x487500
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x487534
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x48755C
    procedure Draw(ClipRect: TRect); override; // @addr 0x487704 @ida "void __usercall $name(TgiGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x487B18
  end;

procedure LoadGiByPathIntoGraphBuf(const GiPath: WideString; Destination: TGraphBufGR); // @addr 0x487B3C

implementation

uses EC_Cache, EC_Mem, GR_Main, GR_DX, GlobalsV;


{ @routine $486B34 TgiGI_Create }
constructor TgiGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCGiControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  Alpha := 255;
end;
{ @end $486B34 }

{ @routine $486BC4 TgiGI_Destroy }
destructor TgiGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $486BC4 }

{ @routine $486C10 TgiGI_Clear }
procedure TgiGI.Clear;
begin
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  inherited Clear;
end;
{ @end $486C10 }

{ @routine $486C38 TgiGI_SetImagePath }
procedure TgiGI.SetImagePath(const ImagePath: WideString);
begin
  if ImageCache.CacheKey <> ImagePath then
  begin
    Invalidate;
    ImageCache.SetCacheKey(ImagePath);
  end;
end;
{ @end $486C38 }

{ @routine $486C7C TgiGI_GetImagePath }
function TgiGI.GetImagePath: WideString;
begin
  Result := ImageCache.CacheKey;
end;
{ @end $486C7C }

{ @routine $486CA0 TgiGI_GetContentSize }
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
{ @end $486CA0 }

{ @routine $486D00 TgiGI_GetContentOrigin }
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
{ @end $486D00 }

{ @routine $486D70 TgiGI_SetImageKindX }
procedure TgiGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $486D70 }

{ @routine $486DA8 TgiGI_SetImageKindY }
procedure TgiGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $486DA8 }

{ @routine $486DE0 TgiGI_SetAlpha }
procedure TgiGI.SetAlpha(Value: Byte);
begin
  if Alpha <> Value then
  begin
    Alpha := Value;
    Invalidate;
  end;
end;
{ @end $486DE0 }

{ @routine $486E18 TgiGI_HitTestPixel }
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
{ @end $486E18 }

{ @routine $487138 TgiGI_GetVisualCenter }
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
{ @end $487138 }

{ @routine $487500 TgiGI_LoadFromConfigPath }
procedure TgiGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $487500 }

{ @routine $487534 TgiGI_LoadFromBlock }
procedure TgiGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $487534 }

{ @routine $48755C TgiGI_LoadImageProperties }
procedure TgiGI.LoadImageProperties(Block: TBlockParEC);
begin
  ImageCache.SetCacheKey(Block.GetParam('Image'));
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('AlignX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('AlignX')));
  if Block.CountParams('AlignY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('AlignY')));
end;
{ @end $48755C }

{ @routine $4876E8 TgiGI_SetHardwareMirrorHorizontal }
procedure TgiGI.SetHardwareMirrorHorizontal(Value: Boolean);
begin
  HardwareMirrorHorizontal := Value;
end;
{ @end $4876E8 }

{ @routine $487704 TgiGI_Draw }
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
{ @end $487704 }

{ @routine $487B18 TgiGI_QueueImageLoad }
procedure TgiGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $487B18 }

{ @routine $487B3C LoadGiByPathIntoGraphBuf }
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
{ @end $487B3C }

end.
