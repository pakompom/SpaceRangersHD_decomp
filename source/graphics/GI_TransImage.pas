unit GI_TransImage;
// Unit bracket (inferred): .text 0x00485EE0..0x00486A14; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheTBitmap, GI_Main, GI_MessageLoop, Types;

type
  TTransImageGI = class(TObjectGI) // @size 0x128
  public
    ImageCache: TCTBitmapControlEC; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    HalfAlpha: Boolean; // @offset 0x126

    constructor Create(Owner: TObjectGI); // @addr 0x486004 @ida "TTransImageGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x48608C @ida "void __usercall $name(TTransImageGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4860D8 @note "Preserves HalfAlpha and the cache key."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x486100
    function GetContentSize: TPoint; // @addr 0x486144 @ida "void __usercall $name(TTransImageGI *Self@<eax>, TPoint *Result@<edx>);"
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x4861A8
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x4861E0
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x486218
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x486250
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4864DC
    procedure Draw(ClipRect: TRect); override; // @addr 0x486744 @ida "void __usercall $name(TTransImageGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x4869F4
  end;

implementation

uses EC_Str, EC_Mem, GlobalsV, GR_Main, GR_DX, SysUtils;


{ @routine $486004 TTransImageGI_Create }
constructor TTransImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCTBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
end;
{ @end $486004 }

{ @routine $48608C TTransImageGI_Destroy }
destructor TTransImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $48608C }

{ @routine $4860D8 TTransImageGI_Clear }
procedure TTransImageGI.Clear;
begin
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  inherited Clear;
end;
{ @end $4860D8 }

{ @routine $486100 TTransImageGI_SetImagePath }
procedure TTransImageGI.SetImagePath(const ImagePath: WideString);
begin
  if ImageCache.CacheKey <> ImagePath then
  begin
    Invalidate;
    ImageCache.SetCacheKey(ImagePath);
  end;
end;
{ @end $486100 }

{ @routine $486144 TTransImageGI_GetContentSize }
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
{ @end $486144 }

{ @routine $4861A8 TTransImageGI_SetImageKindX }
procedure TTransImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $4861A8 }

{ @routine $4861E0 TTransImageGI_SetImageKindY }
procedure TTransImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $4861E0 }

{ @routine $486218 TTransImageGI_SetHalfAlpha }
procedure TTransImageGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlpha <> Value then
  begin
    HalfAlpha := Value;
    Invalidate;
  end;
end;
{ @end $486218 }

{ @routine $486250 TTransImageGI_LoadFromConfigPath }
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
{ @end $486250 }

{ @routine $4864DC TTransImageGI_LoadFromBlock }
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
{ @end $4864DC }

{ @routine $486744 TTransImageGI_Draw }
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
{ @end $486744 }

{ @routine $4869F4 TTransImageGI_QueueImageLoad }
procedure TTransImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4869F4 }

end.
