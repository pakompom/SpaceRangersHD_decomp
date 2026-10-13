unit GI_RotateImage2;

interface

uses EC_BlockPar, EC_CacheBitmap, EC_CacheRotateBuf, GI_MessageLoop, GR_GraphBuf, Types;

type
  TRotateImage2GI = class(TObjectGI) // @size 0x130
  public
    ImageCache: TCBitmapControlEC; // @offset 0x120
    RotationCache: TCRotateBufControlEC; // @offset 0x124
    RotatedImage: TGraphBufGR; // @offset 0x128
    RenderedAngle: Byte; // @offset 0x12C
    Angle: Byte; // @offset 0x12D
    Alpha: Byte; // @offset 0x12E
    ImageDirty: Boolean; // @offset 0x12F

    constructor Create(Owner: TObjectGI); // @addr 0x004BA390
    destructor Destroy; override; // @addr 0x004BA44C
    procedure Clear; override; // @addr 0x004BA4AC @note "Preserves cache keys and the allocated image buffer."
    procedure SetAngle(Value: Byte); // @addr 0x004BA4D0 @note "A full turn has 256 steps."
    procedure SetAlpha(Value: Byte); // @addr 0x004BA4F4
    procedure SetImage(Path: WideString; ImageSize, Pivot: TPoint); // @addr 0x004BA518 @note "Appends ?RGBA to Path; replaces size and origin with a centered square enclosing all rotations."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004BA8A8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004BA8D4
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x004BA90C
    procedure Draw(ClipRect: TRect); override; // @addr 0x004BAAC8
  end;

implementation

uses EC_Struct, Classes, SysUtils, Math, EC_Cache, EC_Mem, GR_Main, GI_Main;
{ @routine $4BA390 TRotateImage2GI_Create }
constructor TRotateImage2GI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageDirty := True;
  ImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  RotationCache := TCRotateBufControlEC.Create;
  GlobalCache.ResetControl(RotationCache);
  RotatedImage := TGraphBufGR.Create(False);
  RenderedAngle := 0;
  Angle := 0;
  Alpha := 255;
  ImageDirty := True;
end;
{ @end $4BA390 }

{ @routine $4BA44C TRotateImage2GI_Destroy }
destructor TRotateImage2GI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  RotationCache.Free;
  RotationCache := nil;
  RotatedImage.Free;
  RotatedImage := nil;
  inherited Destroy;
end;
{ @end $4BA44C }

{ @routine $4BA4AC TRotateImage2GI_Clear }
procedure TRotateImage2GI.Clear;
begin
  ImageDirty := True;
  RenderedAngle := 255;
  Angle := 0;
  Alpha := 255;
  inherited Clear;
end;
{ @end $4BA4AC }

{ @routine $4BA4D0 TRotateImage2GI_SetAngle }
procedure TRotateImage2GI.SetAngle(Value: Byte);
begin
  if Value = Angle then Exit;
  Angle := Value;
  ImageDirty := True;
  Invalidate;
end;
{ @end $4BA4D0 }

{ @routine $4BA4F4 TRotateImage2GI_SetAlpha }
procedure TRotateImage2GI.SetAlpha(Value: Byte);
begin
  if Value = Alpha then Exit;
  Alpha := Value;
  ImageDirty := True;
  Invalidate;
end;
{ @end $4BA4F4 }

{ @routine $4BA518 TRotateImage2GI_SetImage }
procedure TRotateImage2GI.SetImage(Path: WideString; ImageSize, Pivot: TPoint);
var
  Image: TCBitmapEC;
  Radius: Double;
begin
  ImageCache.SetCacheKey(Path + RgbaImagePathSuffix);
  Image := AcquireOrCreateBitmap(ImageCache);
  try
    RotationCache.SetCacheKey(IntToStr(ImageSize.X) + ',' + IntToStr(ImageSize.Y) + ',' +
      IntToStr(Image.Bitmap.Width) + ',' + IntToStr(Image.Bitmap.Height) + ',' + IntToStr(Pivot.X) + ',' + IntToStr(Pivot.Y));
    Radius := SquaredDistanceToPoint(Pivot, 0, 0);
    Radius := Max(Radius, SquaredDistanceToPoint(Pivot, ImageSize.X, ImageSize.Y));
    Radius := Max(Radius, SquaredDistanceToPoint(Pivot, ImageSize.X, 0));
    Radius := Max(Radius, SquaredDistanceToPoint(Pivot, 0, ImageSize.Y));
    Radius := Floor(Sqrt(Radius) * 2.0 + 2.0);
    SetSize(Classes.Point(Trunc(Radius), Trunc(Radius)));
    SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y div 2));
    if (Integer(RotatedImage.Width) <> ClientSize.X) or (Integer(RotatedImage.Height) <> ClientSize.Y) then
      RotatedImage.AllocateRgbaTight(ClientSize.X, ClientSize.Y);
    ImageDirty := True;
  finally
    ImageCache.Release;
  end;
  Invalidate;
end;
{ @end $4BA518 }

{ @routine $4BA8A8 TRotateImage2GI_LoadFromConfigPath }
procedure TRotateImage2GI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4BA8A8 }

{ @routine $4BA8D4 TRotateImage2GI_LoadFromBlock }
procedure TRotateImage2GI.LoadFromBlock(Block: TBlockParEC);
begin
  RenderedAngle := 255;
  Angle := 0;
  Alpha := 255;
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
  ImageDirty := True;
end;
{ @end $4BA8D4 }

{ @routine $4BA90C TRotateImage2GI_LoadImageProperties }
procedure TRotateImage2GI.LoadImageProperties(Block: TBlockParEC);
begin
  if (Block.CountParams('Image') > 0) and (Block.CountParams('Size') > 0) and (Block.CountParams('Sme') > 0) then
    SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')), GetPointGI(Block.GetParam('Sme')));
  if Block.CountParams('Angle') > 0 then SetAngle(StrToInt(Block.GetParam('Angle')));
  if Block.CountParams('Trans') > 0 then SetAlpha(StrToInt(Block.GetParam('Trans')));
end;
{ @end $4BA90C }

{ @routine $4BAAC8 TRotateImage2GI_Draw }
procedure TRotateImage2GI.Draw(ClipRect: TRect);
var
  Image: TCBitmapEC;
  Rotation: TCRotateBufEC;
begin
  if (HitTestBounds.Left + ClientSize.X < 0) or (HitTestBounds.Left - ClientSize.X div 2 > Integer(GameScreenWidth)) then Exit;
  if (HitTestBounds.Top + ClientSize.Y < 0) or (HitTestBounds.Top - ClientSize.Y div 2 > Integer(GameScreenHeight)) then Exit;
  if (RenderedAngle <> Angle) or (ImageDirty = True) then
  begin
    ImageDirty := False;
    RenderedAngle := Angle;
    Image := nil;
    Rotation := nil;
    try
      Image := AcquireOrCreateBitmap(ImageCache);
      Rotation := AcquireOrCreateRotateBuf(RotationCache);
      RotatedImage.ClearPixels;
      Ex_OKGR_RotateBuf_Draw_DWORD(RotatedImage.GetPixels, RotatedImage.PitchBytes, Image.Bitmap.GetPixels,
        Image.Bitmap.PitchBytes, OriginPoint.X, OriginPoint.Y, Angle, Rotation.Buffer);
      if Alpha <> 255 then
        Ex_OKGR_Light_BYTE(AddPointerOffset(RotatedImage.GetPixels, 3), 4,
          RotatedImage.PitchBytes - 4 * RotatedImage.Width, RotatedImage.Width, RotatedImage.Height, Alpha);
    finally
      if Image <> nil then ImageCache.Release;
      if Rotation <> nil then RotationCache.Release;
    end;
  end;
  DrawAlphaGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
    HitTestBounds.Left, HitTestBounds.Top, RotatedImage, ClipRect);
end;
{ @end $4BAAC8 }

end.
