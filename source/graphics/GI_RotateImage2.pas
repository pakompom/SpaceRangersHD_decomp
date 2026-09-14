unit GI_RotateImage2;
// Unit bracket (inferred): .text 0x004B0FA4..0x004B1B30; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create(Owner: TObjectGI); // @addr 0x4B10C8 @ida "TRotateImage2GI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4B11AC @ida "void __usercall $name(TRotateImage2GI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4B1228 @note "Preserves cache keys and the allocated image buffer."
    procedure SetAngle(Value: Byte); // @addr 0x4B1264 @note "A full turn has 256 steps."
    procedure SetAlpha(Value: Byte); // @addr 0x4B12A4
    procedure SetImage(Path: WideString; ImageSize, Pivot: TPoint); // @addr 0x4B12E4 @ida "void __userpurge $name(TRotateImage2GI *Self@<eax>, unsigned __int16 *Path@<edx>, TPoint *ImageSize@<ecx>, TPoint *Pivot@<^0>);" @note "Appends ?RGBA to Path; replaces size and origin with a centered square enclosing all rotations."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4B169C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4B16D0
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x4B1720
    procedure Draw(ClipRect: TRect); override; // @addr 0x4B18E8 @ida "void __usercall $name(TRotateImage2GI *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

implementation

uses Classes, SysUtils, Math, EC_Cache, EC_Mem, GR_Main, GI_Main;
{ @routine $4B10C8 TRotateImage2GI_Create }
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
{ @end $4B10C8 }

{ @routine $4B11AC TRotateImage2GI_Destroy }
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
{ @end $4B11AC }

{ @routine $4B1228 TRotateImage2GI_Clear }
procedure TRotateImage2GI.Clear;
begin
  ImageDirty := True;
  RenderedAngle := 255;
  Angle := 0;
  Alpha := 255;
  inherited Clear;
end;
{ @end $4B1228 }

{ @routine $4B1264 TRotateImage2GI_SetAngle }
procedure TRotateImage2GI.SetAngle(Value: Byte);
begin
  if Value <> Angle then
  begin
    Angle := Value;
    ImageDirty := True;
    Invalidate;
  end;
end;
{ @end $4B1264 }

{ @routine $4B12A4 TRotateImage2GI_SetAlpha }
procedure TRotateImage2GI.SetAlpha(Value: Byte);
begin
  if Value <> Alpha then
  begin
    Alpha := Value;
    ImageDirty := True;
    Invalidate;
  end;
end;
{ @end $4B12A4 }

{ @routine $4B12E4 TRotateImage2GI_SetImage }
procedure TRotateImage2GI.SetImage(Path: WideString; ImageSize, Pivot: TPoint);
var
  Image: TCBitmapEC;
  Radius: Double;
begin
  ImageCache.SetCacheKey(Path + '?RGBA');
  Image := AcquireOrCreateBitmap(ImageCache);
  try
    RotationCache.SetCacheKey(IntToStr(ImageSize.X) + ',' + IntToStr(ImageSize.Y) + ',' +
      IntToStr(Cardinal(Image.Bitmap.Width)) + ',' + IntToStr(Cardinal(Image.Bitmap.Height)) + ',' + IntToStr(Pivot.X) + ',' + IntToStr(Pivot.Y));
    Radius := Sqr(Pivot.X - 0) + Sqr(Pivot.Y - 0);
    Radius := Max(Radius, Sqr(Pivot.X - ImageSize.X) + Sqr(Pivot.Y - ImageSize.Y));
    Radius := Max(Radius, Sqr(Pivot.X - ImageSize.X) + Sqr(Pivot.Y - 0));
    Radius := Max(Radius, Sqr(Pivot.X - 0) + Sqr(Pivot.Y - ImageSize.Y));
    Radius := Floor(Sqrt(Radius) * 2.0 + 2.0);
    SetSize(Classes.Point(Trunc(Radius), Trunc(Radius)));
    SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y div 2));
    if (RotatedImage.Width <> ClientSize.X) or (RotatedImage.Height <> ClientSize.Y) then
      RotatedImage.AllocateRgbaTight(ClientSize.X, ClientSize.Y);
    ImageDirty := True;
  finally
    ImageCache.Release;
  end;
  Invalidate;
end;
{ @end $4B12E4 }

{ @routine $4B169C TRotateImage2GI_LoadFromConfigPath }
procedure TRotateImage2GI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B169C }

{ @routine $4B16D0 TRotateImage2GI_LoadFromBlock }
procedure TRotateImage2GI.LoadFromBlock(Block: TBlockParEC);
begin
  RenderedAngle := 255;
  Angle := 0;
  Alpha := 255;
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
  ImageDirty := True;
end;
{ @end $4B16D0 }

{ @routine $4B1720 TRotateImage2GI_LoadImageProperties }
procedure TRotateImage2GI.LoadImageProperties(Block: TBlockParEC);
begin
  if (Block.CountParams('Image') > 0) and (Block.CountParams('Size') > 0) and (Block.CountParams('Sme') > 0) then
    SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')), GetPointGI(Block.GetParam('Sme')));
  if Block.CountParams('Angle') > 0 then SetAngle(StrToInt(Block.GetParam('Angle')));
  if Block.CountParams('Trans') > 0 then SetAlpha(StrToInt(Block.GetParam('Trans')));
end;
{ @end $4B1720 }

{ @routine $4B18E8 TRotateImage2GI_Draw }
procedure TRotateImage2GI.Draw(ClipRect: TRect);
var
  Image: TCBitmapEC;
  Rotation: TCRotateBufEC;
begin
  if (HitTestBounds.Left + ClientSize.X < 0) or (HitTestBounds.Left - ClientSize.X div 2 > GameScreenWidth) or
    (HitTestBounds.Top + ClientSize.Y < 0) or (HitTestBounds.Top - ClientSize.Y div 2 > GameScreenHeight) then Exit;
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
{ @end $4B18E8 }

end.
