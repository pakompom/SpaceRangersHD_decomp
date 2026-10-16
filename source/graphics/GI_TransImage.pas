unit GI_TransImage;

interface

uses Classes, EC_BlockPar, EC_CacheTBitmap, GI_Main, GI_MessageLoop, Types;

type
  TTransImageGI = class(TObjectGI) // @size 0x128 @methodorder source
  public
    ImageCache: TCTBitmapControlEC; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    HalfAlphaValue: Boolean; // @offset 0x126

    constructor Create(Owner: TObjectGI); // @addr 0x00493104
    destructor Destroy; override; // @addr 0x00493174
    procedure Clear; override; // @addr 0x004931AC @note "Preserves HalfAlphaValue and the cache key."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x004931C0
    property Image: WideString write SetImagePath;
    function GetContentSize: TPoint; // @addr 0x004931F4
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x0049324C
    property KindX: TImageKindXGI read ImageKindX write SetImageKindX;
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x0049326C
    property KindY: TImageKindYGI read ImageKindY write SetImageKindY;
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x0049328C
    property HalfAlpha: Boolean read HalfAlphaValue write SetHalfAlpha;
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004932AC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00493534
    procedure Draw(ClipRect: TRect); override; // @addr 0x0049379C
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x004939C8
  end;

implementation

uses EC_Str, EC_Mem, GlobalsV, GR_Main, GR_DX, SysUtils;


{ @routine $493104 TTransImageGI_Create }
constructor TTransImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCTBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  ImageKindX := image_x_center;
  ImageKindY := image_y_center;
end;
{ @end $493104 }

{ @routine $493174 TTransImageGI_Destroy }
destructor TTransImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $493174 }

{ @routine $4931AC TTransImageGI_Clear }
procedure TTransImageGI.Clear;
begin
  ImageKindX := image_x_center;
  ImageKindY := image_y_center;
  inherited Clear;
end;
{ @end $4931AC }

{ @routine $4931C0 TTransImageGI_SetImagePath }
procedure TTransImageGI.SetImagePath(const ImagePath: WideString);
begin
  if ImageCache.CacheKey = ImagePath then Exit;
  Invalidate;
  ImageCache.SetCacheKey(ImagePath);
end;
{ @end $4931C0 }

{ @routine $4931F4 TTransImageGI_GetContentSize }
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
{ @end $4931F4 }

{ @routine $49324C TTransImageGI_SetImageKindX }
procedure TTransImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX = Value then Exit;
  ImageKindX := Value;
  Invalidate;
end;
{ @end $49324C }

{ @routine $49326C TTransImageGI_SetImageKindY }
procedure TTransImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY = Value then Exit;
  ImageKindY := Value;
  Invalidate;
end;
{ @end $49326C }

{ @routine $49328C TTransImageGI_SetHalfAlpha }
procedure TTransImageGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlphaValue = Value then Exit;
  HalfAlphaValue := Value;
  Invalidate;
end;
{ @end $49328C }

{ @routine $4932AC TTransImageGI_LoadFromConfigPath }
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
  if Block.CountParams('KindX') > 0 then KindX := ParseImageKindXName(Block.GetParam('KindX'));
  if Block.CountParams('KindY') > 0 then KindY := ParseImageKindYName(Block.GetParam('KindY'));
  if Block.CountParams('HalfAlpha') > 0 then HalfAlpha := ParseEnabledNameGI(Block.GetParam('HalfAlpha'));
end;
{ @end $4932AC }

{ @routine $493534 TTransImageGI_LoadFromBlock }
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
  if Block.CountParams('KindX') > 0 then KindX := ParseImageKindXName(Block.GetParam('KindX'));
  if Block.CountParams('KindY') > 0 then KindY := ParseImageKindYName(Block.GetParam('KindY'));
  if Block.CountParams('HalfAlpha') > 0 then HalfAlpha := ParseEnabledNameGI(Block.GetParam('HalfAlpha'));
end;
{ @end $493534 }

{ @routine $49379C TTransImageGI_Draw }
procedure TTransImageGI.Draw(ClipRect: TRect);
var Bitmap: TCTBitmapEC; Width, Height, Left, Right, X, Top, Bottom, Y: Integer;
begin
  Bitmap := AcquireCachedTransBitmap(ImageCache);
  try
  Width := Bitmap.PixelSize.X;
  Height := Bitmap.PixelSize.Y;
  if ImageKindX = image_x_tile_left then
  begin
    Left := HitTestBounds.Left;
    Right := HitTestBounds.Right;
  end
  else if ImageKindX = image_x_tile_right then
  begin
    Right := HitTestBounds.Right;
    Left := Right;
    while Left > ClipRect.Left do Dec(Left, Width);
  end
  else if ImageKindX = image_x_left then
  begin
    Left := HitTestBounds.Left;
    Right := Left + Width;
  end
  else if ImageKindX = image_x_right then
  begin
    Right := HitTestBounds.Right;
    Left := Right - Width;
  end
  else if ImageKindX = image_x_center then
  begin
    Left := (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - Width div 2;
    Right := Left + Width;
  end
  else begin Exit; end;
  if ImageKindY = image_y_tile_top then
  begin
    Top := HitTestBounds.Top;
    Bottom := HitTestBounds.Bottom;
  end
  else if ImageKindY = image_y_tile_bottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom;
    while Top > ClipRect.Top do Dec(Top, Height);
  end
  else if ImageKindY = image_y_top then
  begin
    Top := HitTestBounds.Top;
    Bottom := Top + Height;
  end
  else if ImageKindY = image_y_bottom then
  begin
    Bottom := HitTestBounds.Bottom;
    Top := Bottom - Height;
  end
  else if ImageKindY = image_y_center then
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
      DrawTransparentBuffer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, Bitmap.TransBuffer, ClipRect, HalfAlphaValue);
      Inc(X, Width);
    end;
    Inc(Y, Height);
  end;
  finally
    ImageCache.Release;
  end;
end;
{ @end $49379C }

{ @routine $4939C8 TTransImageGI_QueueImageLoad }
procedure TTransImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4939C8 }

end.
