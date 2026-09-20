unit GI_TransImage;
// Unit bracket (inferred): .text 0x00474860..0x00475394; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheTBitmap, GI_Main, GI_MessageLoop, Types;

type
  TTransImageGI = class(TObjectGI) // @size 0x128
  public
    ImageCache: TCTBitmapControlEC; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    HalfAlpha: Boolean; // @offset 0x126

    constructor Create(Owner: TObjectGI); // @addr 0x474984
    destructor Destroy; override; // @addr 0x474A0C
    procedure Clear; override; // @addr 0x474A58 @note "Preserves HalfAlpha and the cache key."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x474A80
    function GetContentSize: TPoint; // @addr 0x474AC4
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x474B28
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x474B60
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x474B98
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x474BD0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x474E5C
    procedure Draw(ClipRect: TRect); override; // @addr 0x4750C4
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x475374
  end;

implementation

uses EC_Str, EC_Mem, GlobalsV, GR_Main, GR_DX, SysUtils;


{ @routine $474984 TTransImageGI_Create }
constructor TTransImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCTBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
end;
{ @end $474984 }

{ @routine $474A0C TTransImageGI_Destroy }
destructor TTransImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $474A0C }

{ @routine $474A58 TTransImageGI_Clear }
procedure TTransImageGI.Clear;
begin
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  inherited Clear;
end;
{ @end $474A58 }

{ @routine $474A80 TTransImageGI_SetImagePath }
procedure TTransImageGI.SetImagePath(const ImagePath: WideString);
begin
  if ImageCache.CacheKey <> ImagePath then
  begin
    Invalidate;
    ImageCache.SetCacheKey(ImagePath);
  end;
end;
{ @end $474A80 }

{ @routine $474AC4 TTransImageGI_GetContentSize }
function TTransImageGI.GetContentSize: TPoint;
var Bitmap: TCTBitmapEC;
begin
  Bitmap := AcquireCachedTransBitmap(ImageCache);
  try
    Result := Bitmap.PixelSize;
  finally
    ImageCache.Release;
  end;
end;
{ @end $474AC4 }

{ @routine $474B28 TTransImageGI_SetImageKindX }
procedure TTransImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $474B28 }

{ @routine $474B60 TTransImageGI_SetImageKindY }
procedure TTransImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $474B60 }

{ @routine $474B98 TTransImageGI_SetHalfAlpha }
procedure TTransImageGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlpha <> Value then
  begin
    HalfAlpha := Value;
    Invalidate;
  end;
end;
{ @end $474B98 }

{ @routine $474BD0 TTransImageGI_LoadFromConfigPath }
procedure TTransImageGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC; Bitmap: TCTBitmapEC; Text: WideString;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Image') > 0 then
  begin
  ImageCache.SetCacheKey(Block.GetParam('Image'));
  Bitmap := AcquireCachedTransBitmap(ImageCache);
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
  if Block.CountParams('HalfAlpha') > 0 then SetHalfAlpha(ParseEnabledNameGI(Block.GetParam('HalfAlpha')));
end;
{ @end $474BD0 }

{ @routine $474E5C TTransImageGI_LoadFromBlock }
procedure TTransImageGI.LoadFromBlock(Block: TBlockParEC);
var Bitmap: TCTBitmapEC; Text: WideString;
begin
  inherited LoadFromBlock(Block);
  ImageCache.SetCacheKey(Block.GetParam('Image'));
  Bitmap := AcquireCachedTransBitmap(ImageCache);
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
  if Block.CountParams('HalfAlpha') > 0 then SetHalfAlpha(ParseEnabledNameGI(Block.GetParam('HalfAlpha')));
end;
{ @end $474E5C }

{ @routine $4750C4 TTransImageGI_Draw }
procedure TTransImageGI.Draw(ClipRect: TRect);
var Bitmap: TCTBitmapEC; Width, Height, Left, Right, X, Top, Bottom, Y: Integer;
begin
  Bitmap := AcquireCachedTransBitmap(ImageCache);
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
  AppendLogLineThreadSafe('Test');
  Y := Top;
  while (Y < Bottom) do
  begin
    X := Left;
    while (X < Right) do
    begin
      DrawTransparentBuffer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, Bitmap.TransBuffer, ClipRect, HalfAlpha);
      Inc(X, Width);
    end;
    Inc(Y, Height);
  end;
  finally
    ImageCache.Release;
  end;
end;
{ @end $4750C4 }

{ @routine $475374 TTransImageGI_QueueImageLoad }
procedure TTransImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $475374 }

end.
