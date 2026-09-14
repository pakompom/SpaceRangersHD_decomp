unit GI_SimpleImage;
// Unit bracket (inferred): .text 0x004851D0..0x00485EDC; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheBitmap, GI_Main, GI_MessageLoop, Types;

type
  TSimpleImageGI = class(TObjectGI) // @size 0x128
  public
    ImageCache: TCBitmapControlEC; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    HalfAlpha: Boolean; // @offset 0x126
    SourceRGBA: Boolean; // @offset 0x127

    constructor Create(Owner: TObjectGI); // @addr 0x4852F4 @ida "TSimpleImageGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x485384 @ida "void __usercall $name(TSimpleImageGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4853D0 @note "Preserves the cache control and its key."
    procedure SetImagePath(const ImagePath: WideString); // @addr 0x48540C @note "The RGBA key suffix enables SourceRGBA; keys shorter than four characters preserve the previous flag."
    function GetContentSize: TPoint; // @addr 0x4854C0 @ida "void __usercall $name(TSimpleImageGI *Self@<eax>, TPoint *Result@<edx>);"
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x48552C
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x485564
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x48559C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4855D4 @note "Image is optional."
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x48587C @note "Requires Image; does not update SourceRGBA from the key suffix."
    procedure Draw(ClipRect: TRect); override; // @addr 0x485AFC @ida "void __usercall $name(TSimpleImageGI *Self@<eax>, TRect *ClipRect@<edx>);" @note "CenterFill is unimplemented on both axes."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x485EBC
  end;

implementation

uses EC_Str, EC_Mem, GlobalsV, GR_Main, GR_DX, SysUtils;


{ @routine $4852F4 TSimpleImageGI_Create }
constructor TSimpleImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  HalfAlpha := False;
end;
{ @end $4852F4 }

{ @routine $485384 TSimpleImageGI_Destroy }
destructor TSimpleImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $485384 }

{ @routine $4853D0 TSimpleImageGI_Clear }
procedure TSimpleImageGI.Clear;
begin
  ImageKindX := ikxCenter;
  ImageKindY := ikyCenter;
  HalfAlpha := False;
  SourceRGBA := False;
  inherited Clear;
end;
{ @end $4853D0 }

{ @routine $48540C TSimpleImageGI_SetImagePath }
procedure TSimpleImageGI.SetImagePath(const ImagePath: WideString);
begin
  Invalidate;
  ImageCache.SetCacheKey(ImagePath);
  if Length(ImagePath) >= 4 then SourceRGBA := Copy(ImagePath, Length(ImagePath) - 4 + 1, 4) = 'RGBA';
end;
{ @end $48540C }

{ @routine $4854C0 TSimpleImageGI_GetContentSize }
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
{ @end $4854C0 }

{ @routine $48552C TSimpleImageGI_SetImageKindX }
procedure TSimpleImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    Invalidate;
  end;
end;
{ @end $48552C }

{ @routine $485564 TSimpleImageGI_SetImageKindY }
procedure TSimpleImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    Invalidate;
  end;
end;
{ @end $485564 }

{ @routine $48559C TSimpleImageGI_SetHalfAlpha }
procedure TSimpleImageGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlpha <> Value then
  begin
    HalfAlpha := Value;
    Invalidate;
  end;
end;
{ @end $48559C }

{ @routine $4855D4 TSimpleImageGI_LoadFromConfigPath }
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
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('HalfAlpha') > 0 then SetHalfAlpha(ParseEnabledNameGI(Block.GetParam('HalfAlpha')));
end;
{ @end $4855D4 }

{ @routine $48587C TSimpleImageGI_LoadFromBlock }
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
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('HalfAlpha') > 0 then SetHalfAlpha(ParseEnabledNameGI(Block.GetParam('HalfAlpha')));
end;
{ @end $48587C }

{ @routine $485AFC TSimpleImageGI_Draw }
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
      DrawTexture(Bitmap.Bitmap.GetTexture, X, Y, 255, $FFFFFF, @ClipRect, False, False);
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
      CopyGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, Bitmap.Bitmap, ClipRect, HalfAlpha, False);
      Inc(X, Width);
    end;
    Inc(Y, Height);
  end;
  end;
  finally
    ImageCache.Release;
  end;
end;
{ @end $485AFC }

{ @routine $485EBC TSimpleImageGI_QueueImageLoad }
procedure TSimpleImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $485EBC }

end.
