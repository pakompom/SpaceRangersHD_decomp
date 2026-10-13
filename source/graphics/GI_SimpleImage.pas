unit GI_SimpleImage;

interface

uses Classes, EC_BlockPar, EC_CacheBitmap, GI_Main, GI_MessageLoop, Types;

type
  TSimpleImageGI = class(TObjectGI) // @size 0x128 @methodorder source
  public
    ImageCache: TCBitmapControlEC; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    HalfAlphaValue: Boolean; // @offset 0x126
    SourceRGBA: Boolean; // @offset 0x127

    constructor Create(Owner: TObjectGI); // @addr 0x00492578
    destructor Destroy; override; // @addr 0x004925F0
    procedure Clear; override; // @addr 0x00492628 @note "Preserves the cache control and its key."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x0049264C @note "The RGBA key suffix enables SourceRGBA; keys shorter than four characters preserve the previous flag."
    property Image: WideString write SetImagePath;
    function GetContentSize: TPoint; // @addr 0x004926F0
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x00492754
    property KindX: TImageKindXGI read ImageKindX write SetImageKindX;
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x00492774
    property KindY: TImageKindYGI read ImageKindY write SetImageKindY;
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x00492794
    property HalfAlpha: Boolean read HalfAlphaValue write SetHalfAlpha;
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004927B4 @note "Image is optional."
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00492A54 @note "Requires Image; does not update SourceRGBA from the key suffix."
    procedure Draw(ClipRect: TRect); override; // @addr 0x00492CD4 @note "CenterFill is unimplemented on both axes."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x00492FD4
  end;

implementation

uses EC_Str, EC_Mem, GlobalsV, GR_Main, GR_DX, SysUtils;


{ @routine $492578 TSimpleImageGI_Create }
constructor TSimpleImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  HalfAlphaValue := False;
end;
{ @end $492578 }

{ @routine $4925F0 TSimpleImageGI_Destroy }
destructor TSimpleImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $4925F0 }

{ @routine $492628 TSimpleImageGI_Clear }
procedure TSimpleImageGI.Clear;
begin
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  HalfAlphaValue := False;
  SourceRGBA := False;
  inherited Clear;
end;
{ @end $492628 }

{ @routine $49264C TSimpleImageGI_SetImagePath }
procedure TSimpleImageGI.SetImagePath(const ImagePath: WideString);
begin
  Invalidate;
  ImageCache.SetCacheKey(ImagePath);
  if Length(ImagePath) >= 4 then SourceRGBA := Copy(ImagePath, Length(ImagePath) - 4 + 1, 4) = 'RGBA';
end;
{ @end $49264C }

{ @routine $4926F0 TSimpleImageGI_GetContentSize }
function TSimpleImageGI.GetContentSize: TPoint;
var Bitmap: TCBitmapEC;
begin
  Bitmap := AcquireOrCreateBitmap(ImageCache);
  try
    Result := Classes.Point(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height);
  finally
    ImageCache.Release;
  end;
end;
{ @end $4926F0 }

{ @routine $492754 TSimpleImageGI_SetImageKindX }
procedure TSimpleImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX = Value then Exit;
  ImageKindX := Value;
  Invalidate;
end;
{ @end $492754 }

{ @routine $492774 TSimpleImageGI_SetImageKindY }
procedure TSimpleImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY = Value then Exit;
  ImageKindY := Value;
  Invalidate;
end;
{ @end $492774 }

{ @routine $492794 TSimpleImageGI_SetHalfAlpha }
procedure TSimpleImageGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlphaValue = Value then Exit;
  HalfAlphaValue := Value;
  Invalidate;
end;
{ @end $492794 }

{ @routine $4927B4 TSimpleImageGI_LoadFromConfigPath }
procedure TSimpleImageGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC; Bitmap: TCBitmapEC; Text: WideString;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Image') > 0 then
  begin
  ImageCache.SetCacheKey(Block.GetParam('Image'));
  Bitmap := AcquireOrCreateBitmap(ImageCache);
  try
    SetSize(Classes.Point(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height));
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
{ @end $4927B4 }

{ @routine $492A54 TSimpleImageGI_LoadFromBlock }
procedure TSimpleImageGI.LoadFromBlock(Block: TBlockParEC);
var Bitmap: TCBitmapEC; Text: WideString;
begin
  inherited LoadFromBlock(Block);
  ImageCache.SetCacheKey(Block.GetParam('Image'));
  Bitmap := AcquireOrCreateBitmap(ImageCache);
  try
    SetSize(Classes.Point(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height));
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
{ @end $492A54 }

{ @routine $492CD4 TSimpleImageGI_Draw }
procedure TSimpleImageGI.Draw(ClipRect: TRect);
var Bitmap: TCBitmapEC; Width, Height, Left, Right, X, Top, Bottom, Y: Integer;
begin
  Bitmap := AcquireOrCreateBitmap(ImageCache);
  try
  Width := Bitmap.Bitmap.Width;
  Height := Bitmap.Bitmap.Height;
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
      DrawTexture(Bitmap.Bitmap.GetTexture, X, Y, 255, RgbWhite, @ClipRect, False, False);
      Inc(X, Width);
    end;
    Inc(Y, Height);
  end;
  end
  else if SourceRGBA then
  begin
  Y := Top;
  while (Y < Bottom) do
  begin
    X := Left;
    while (X < Right) do
    begin
      DrawAlphaGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, Bitmap.Bitmap, ClipRect);
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
      CopyGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, Bitmap.Bitmap, ClipRect, HalfAlphaValue, False);
      Inc(X, Width);
    end;
    Inc(Y, Height);
  end;
  end;
  finally
    ImageCache.Release;
  end;
end;
{ @end $492CD4 }

{ @routine $492FD4 TSimpleImageGI_QueueImageLoad }
procedure TSimpleImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $492FD4 }

end.
