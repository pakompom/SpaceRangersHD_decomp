unit GI_AlphaImage;
// Unit bracket (inferred): .text 0x00488268..0x00489140; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheAlphaBitmap, GI_Main, GI_MessageLoop, Types;

type
  TAlphaImageGI = class(TObjectGI) // @size 0x128
  public
    ImageCache: TCAlphaBitmapControlEC; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125

    constructor Create(Owner: TObjectGI); // @addr 0x48838C @ida "TAlphaImageGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x488414 @ida "void __usercall $name(TAlphaImageGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x488460
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x488488
    function GetContentSize: TPoint; // @addr 0x4884CC @ida "void __usercall $name(TAlphaImageGI *Self@<eax>, TPoint *Result@<edx>);"
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x488530
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x488568
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x4885A0 @ida "bool __usercall $name@<al>(TAlphaImageGI *Self@<eax>, TPoint *Point@<edx>);" @note "Black pixels do not count as hits."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x488874
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x488B44
    procedure Draw(ClipRect: TRect); override; // @addr 0x488DF0 @ida "void __usercall $name(TAlphaImageGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x489120
  end;

implementation

uses EC_Str, EC_Mem, GlobalsV, GR_Main, GR_DX, SysUtils;


{ @routine $48838C TAlphaImageGI_Create }
constructor TAlphaImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCAlphaBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
end;
{ @end $48838C }

{ @routine $488414 TAlphaImageGI_Destroy }
destructor TAlphaImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $488414 }

{ @routine $488460 TAlphaImageGI_Clear }
procedure TAlphaImageGI.Clear;
begin
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  inherited Clear;
end;
{ @end $488460 }

{ @routine $488488 TAlphaImageGI_SetImagePath }
procedure TAlphaImageGI.SetImagePath(const ImagePath: WideString);
begin
  if ImageCache.CacheKey <> ImagePath then
  begin
    Invalidate;
    ImageCache.SetCacheKey(ImagePath);
  end;
end;
{ @end $488488 }

{ @routine $4884CC TAlphaImageGI_GetContentSize }
function TAlphaImageGI.GetContentSize: TPoint;
var Bitmap: TCAlphaBitmapEC;
begin
  Bitmap := AcquireOrCreateAlphaBitmap(ImageCache);
  try
    Result := Bitmap.PixelSize;
  finally
    ImageCache.Release;
  end;
end;
{ @end $4884CC }

{ @routine $488530 TAlphaImageGI_SetImageKindX }
procedure TAlphaImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $488530 }

{ @routine $488568 TAlphaImageGI_SetImageKindY }
procedure TAlphaImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $488568 }

{ @routine $4885A0 TAlphaImageGI_HitTestPixel }
function TAlphaImageGI.HitTestPixel(Point: TPoint): Boolean;
var Bitmap: TCAlphaBitmapEC; Width, Height, Left, Right, X, Top, Bottom, Y: Integer; Pixel: Cardinal; Pixels: Pointer; Clip: TRect;
begin
  Result := False;
  Pixel := 0;
  Clip.Left := Point.X;
  Clip.Top := Point.Y;
  Clip.Right := Point.X + 1;
  Clip.Bottom := Point.Y + 1;
  Bitmap := AcquireOrCreateAlphaBitmap(ImageCache);
  try
  Width := Bitmap.PixelSize.X;
  Height := Bitmap.PixelSize.Y;
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
  Y := Top;
  while (Y < Bottom) and (Pixel = 0) do
  begin
    X := Left;
    while (X < Right) and (Pixel = 0) do
    begin
      Bitmap.Draw16(Pixels, ScreenRenderBuffer.PitchBytes, X, Y, Clip);
      Inc(X, Width);
    end;
    Inc(Y, Height);
  end;
  finally
    ImageCache.Release;
  end;
  Result := Pixel <> 0;
end;
{ @end $4885A0 }

{ @routine $488874 TAlphaImageGI_LoadFromConfigPath }
procedure TAlphaImageGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC; Bitmap: TCAlphaBitmapEC; Text: WideString;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Image') > 0 then
  begin
  ImageCache.SetCacheKey(Block.GetParam('Image'));
  Bitmap := AcquireOrCreateAlphaBitmap(ImageCache);
  try
    SetSize(Bitmap.PixelSize);
  finally
    ImageCache.Release;
  end;
  end;
  if Block.CountParams('Size') > 0 then
  begin
    Text := Block.GetParam('Size');
    SetSize(Classes.Point(StrToInt(ExtractDelimitedPartW(Text, 0, ',')), StrToInt(ExtractDelimitedPartW(Text, 1, ','))));
  end;
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('AlignX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('AlignX')));
  if Block.CountParams('AlignY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('AlignY')));
end;
{ @end $488874 }

{ @routine $488B44 TAlphaImageGI_LoadFromBlock }
procedure TAlphaImageGI.LoadFromBlock(Block: TBlockParEC);
var Bitmap: TCAlphaBitmapEC; Text: WideString;
begin
  inherited LoadFromBlock(Block);
  ImageCache.SetCacheKey(Block.GetParam('Image'));
  Bitmap := AcquireOrCreateAlphaBitmap(ImageCache);
  try
    SetSize(Bitmap.PixelSize);
  finally
    ImageCache.Release;
  end;
  if Block.CountParams('Size') > 0 then
  begin
    Text := Block.GetParam('Size');
    SetSize(Classes.Point(StrToInt(ExtractDelimitedPartW(Text, 0, ',')), StrToInt(ExtractDelimitedPartW(Text, 1, ','))));
  end;
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('AlignX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('AlignX')));
  if Block.CountParams('AlignY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('AlignY')));
end;
{ @end $488B44 }

{ @routine $488DF0 TAlphaImageGI_Draw }
procedure TAlphaImageGI.Draw(ClipRect: TRect);
var Bitmap: TCAlphaBitmapEC; Width, Height, Left, Right, X, Top, Bottom, Y: Integer;
begin
  Bitmap := AcquireOrCreateAlphaBitmap(ImageCache);
  try
  Width := Bitmap.PixelSize.X;
  Height := Bitmap.PixelSize.Y;
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
  while (Y < Bottom) do
  begin
    X := Left;
    while (X < Right) do
    begin
      DrawTexture(Bitmap.GetTexture, X, Y, 255, $FFFFFF, @ClipRect, False, False);
      Inc(X, Width);
    end;
    Inc(Y, Height);
  end;
  end
  else
  begin
  Y := Top;
  while (Y < Bottom) do
  begin
    X := Left;
    while (X < Right) do
    begin
      Bitmap.Draw16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, ClipRect);
      Inc(X, Width);
    end;
    Inc(Y, Height);
  end;
  end;
  finally
    ImageCache.Release;
  end;
end;
{ @end $488DF0 }

{ @routine $489120 TAlphaImageGI_QueueImageLoad }
procedure TAlphaImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $489120 }

end.
