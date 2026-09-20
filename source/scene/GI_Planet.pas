unit GI_Planet;
// Unit bracket (inferred): .text 0x004A6468..0x004A99EB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types, Classes, EC_CachePalBitmap, EC_CacheRotateBuf, EC_CachePlanetTempl, EC_CacheLightPal, EC_CacheBitmap, GI_MessageLoop, GR_DX, GR_GraphBufPal, EC_BlockPar, GR_GraphBuf;

type
  TPlanetGI = class(TObjectGI) // @size 0x1AC
  public
    TemplateCache: TCPlanetTemplControlEC; // @offset 0x120
    SurfaceImageCache: TCPalBitmapControlEC; // @offset 0x124
    SurfacePaletteCache: TCLightPalControlEC; // @offset 0x128
    Cloud1ImageCache: TCPalBitmapControlEC; // @offset 0x12C
    Cloud1PaletteCache: TCLightPalControlEC; // @offset 0x130
    Cloud2ImageCache: TCPalBitmapControlEC; // @offset 0x134
    Cloud2PaletteCache: TCLightPalControlEC; // @offset 0x138
    Cloud3ImageCache: TCPalBitmapControlEC; // @offset 0x13C
    Cloud3PaletteCache: TCLightPalControlEC; // @offset 0x140
    LightRotationCache: TCRotateBufControlEC; // @offset 0x144
    AtmosphereRotationCache: TCRotateBufControlEC; // @offset 0x148
    AtmosphereBuffer: TGraphBufPalGR; // @offset 0x14C
    AtmosphereImageCache: TCBitmapControlEC; // @offset 0x150
    AtmosphereMaskCache: TCBitmapControlEC; // @offset 0x154
    AtmosphereColor: Cardinal; // @offset 0x158
    AtmosphereDirty: Boolean; // @offset 0x15C
    AtmospherePaletteDirty: Boolean; // @offset 0x15D
    MapWidthMask: Integer; // @offset 0x160
    SurfaceMapOffset: Integer; // @offset 0x164
    Cloud1MapOffset: Integer; // @offset 0x168
    Cloud2MapOffset: Integer; // @offset 0x16C
    Cloud3MapOffset: Integer; // @offset 0x170
    RenderedMapOffsets: array[0..3] of Integer; // @offset 0x174
    // Opaque OKGR light buffers, released by Clear.
    SourceLightBuffer: Pointer; // @offset 0x184
    RotatedLightBuffer: Pointer; // @offset 0x188
    LightAngle: Byte; // @offset 0x18C
    MapWidth: Integer; // @offset 0x190
    MapHeight: Integer; // @offset 0x194
    TextureCache: TTextureGR; // @offset 0x198
    TextureSize: TPoint; // @offset 0x19C
    AtmosphereTextureSize: TPoint; // @offset 0x1A4

    constructor Create(Owner: TObjectGI); // @addr 0x4A6588
    destructor Destroy; override; // @addr 0x4A6854
    procedure Clear; override; // @addr 0x4A6A08 @note "Preserves image caches, atmosphere storage and texture cache."
    procedure SetImage(const MaskPath, ImagePath, LightMapPath: WideString); // @addr 0x4A6A70 @note "Image width must be a power of two from 16 through 2048; height must not exceed half the width. The light map must cover that height on both axes."
    procedure SetCloud1Image(const Path: WideString); // @addr 0x4A7194 @note "Requires the same dimensions as the surface map."
    procedure SetCloud2Image(const Path: WideString); // @addr 0x4A7268 @note "Requires the same dimensions as the surface map."
    procedure SetCloud3Image(const Path: WideString); // @addr 0x4A733C @note "Requires the same dimensions as the surface map."
    procedure SetImageWithRadius(const MaskPath, ImagePath, LightMapPath: WideString; Radius: Integer); // @addr 0x4A7410 @note "Uses a diameter of 2*Radius+1. Applies the surface-map dimension checks but omits the light-map size check."
    procedure SetImageFromTemplate(const TemplateKey, ImagePath: WideString; Radius: Integer); // @addr 0x4A7AB8 @note "Uses a diameter of 2*Radius. Reuses an existing surface image and light buffers; ImagePath is used only when the surface cache key is empty."
    procedure SetAtmosphere(ImagePath, MaskPath: WideString; Color: Cardinal); // @addr 0x4A7ED0 @note "Appends ?Gray to both paths; Color is 0x00BBGGRR. Zero suppresses atmosphere drawing."
    procedure BuildAtmospherePalette; // @addr 0x4A8140 @note "Requires space for 256 colors. RGB channels and the alpha ramp are truncated to multiples of eight."
    procedure RebuildAtmosphereImage; // @addr 0x4A81C0
    procedure SetSurfaceMapOffset(Value: Integer); // @addr 0x4A847C
    procedure SetCloud1MapOffset(Value: Integer); // @addr 0x4A84B4
    procedure SetCloud2MapOffset(Value: Integer); // @addr 0x4A84EC
    procedure SetCloud3MapOffset(Value: Integer); // @addr 0x4A8524
    procedure SetLightAngle(Value: Byte); // @addr 0x4A855C @note "A full turn has 256 steps; requires initialized light buffers when the angle changes."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4A8618
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4A87FC
    procedure Draw(ClipRect: TRect); override; // @addr 0x4A899C @note "The native routine does not release its third cloud layer's cache acquisitions."
    procedure RenderSurfaceToBuffer(Buffer: TGraphBufGR); // @addr 0x4A97EC @note "Resizes and clears Buffer; excludes clouds and atmosphere."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x4A9998 @note "Queues the template, surface, surface palette and light rotation only."
  end;

implementation

uses SysUtils, EC_Cache, EC_Mem, GR_Main, GI_Main, GlobalsV, Direct3D9;

{ @routine $4A6588 TPlanetGI_Create }
constructor TPlanetGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  TemplateCache := TCPlanetTemplControlEC.Create;
  GlobalCache.ResetControl(TemplateCache);
  SurfaceImageCache := TCPalBitmapControlEC.Create;
  GlobalCache.ResetControl(SurfaceImageCache);
  SurfacePaletteCache := TCLightPalControlEC.Create;
  GlobalCache.ResetControl(SurfacePaletteCache);
  Cloud1ImageCache := TCPalBitmapControlEC.Create;
  GlobalCache.ResetControl(Cloud1ImageCache);
  Cloud1PaletteCache := TCLightPalControlEC.Create;
  GlobalCache.ResetControl(Cloud1PaletteCache);
  Cloud2ImageCache := TCPalBitmapControlEC.Create;
  GlobalCache.ResetControl(Cloud2ImageCache);
  Cloud2PaletteCache := TCLightPalControlEC.Create;
  GlobalCache.ResetControl(Cloud2PaletteCache);
  Cloud3ImageCache := TCPalBitmapControlEC.Create;
  GlobalCache.ResetControl(Cloud3ImageCache);
  Cloud3PaletteCache := TCLightPalControlEC.Create;
  GlobalCache.ResetControl(Cloud3PaletteCache);
  LightRotationCache := TCRotateBufControlEC.Create;
  GlobalCache.ResetControl(LightRotationCache);
  AtmosphereRotationCache := TCRotateBufControlEC.Create;
  GlobalCache.ResetControl(AtmosphereRotationCache);
  AtmosphereBuffer := TGraphBufPalGR.Create;
  AtmosphereImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(AtmosphereImageCache);
  AtmosphereMaskCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(AtmosphereMaskCache);
  RenderedMapOffsets[0] := $FFFFFF;
  RenderedMapOffsets[1] := RenderedMapOffsets[0];
  RenderedMapOffsets[2] := RenderedMapOffsets[0];
  RenderedMapOffsets[3] := RenderedMapOffsets[0];
  TextureCache := nil;
end;
{ @end $4A6588 }

{ @routine $4A6854 TPlanetGI_Destroy }
destructor TPlanetGI.Destroy;
begin
  TemplateCache.Free;
  TemplateCache := nil;
  SurfacePaletteCache.Free;
  SurfacePaletteCache := nil;
  SurfaceImageCache.Free;
  SurfaceImageCache := nil;
  Cloud1PaletteCache.Free;
  Cloud1PaletteCache := nil;
  Cloud1ImageCache.Free;
  Cloud1ImageCache := nil;
  Cloud2PaletteCache.Free;
  Cloud2PaletteCache := nil;
  Cloud2ImageCache.Free;
  Cloud2ImageCache := nil;
  Cloud3PaletteCache.Free;
  Cloud3PaletteCache := nil;
  Cloud3ImageCache.Free;
  Cloud3ImageCache := nil;
  LightRotationCache.Free;
  LightRotationCache := nil;
  AtmosphereRotationCache.Free;
  AtmosphereRotationCache := nil;
  AtmosphereBuffer.Free;
  AtmosphereBuffer := nil;
  AtmosphereImageCache.Free;
  AtmosphereImageCache := nil;
  AtmosphereMaskCache.Free;
  AtmosphereMaskCache := nil;
  if TextureCache <> nil then
  begin
    FreeTextureCache(TextureCache);
    TextureCache := nil;
  end;
  inherited Destroy;
end;
{ @end $4A6854 }

{ @routine $4A6A08 TPlanetGI_Clear }
procedure TPlanetGI.Clear;
begin
  if SourceLightBuffer <> nil then
  begin
    Ex_OKGR_LightBuf_Destroy(SourceLightBuffer);
    SourceLightBuffer := nil;
  end;
  if RotatedLightBuffer <> nil then
  begin
    Ex_OKGR_LightBuf_Destroy(RotatedLightBuffer);
    RotatedLightBuffer := nil;
  end;
  LightAngle := 0;
  inherited Clear;
end;
{ @end $4A6A08 }

{ @routine $4A6A70 TPlanetGI_SetImage }
procedure TPlanetGI.SetImage(const MaskPath, ImagePath, LightMapPath: WideString);
var
  Image: TCPalBitmapEC;
  LightControl: TCPalBitmapControlEC;
  LightImage: TCPalBitmapEC;
begin
  Invalidate;
  if SourceLightBuffer <> nil then
  begin
    Ex_OKGR_LightBuf_Destroy(SourceLightBuffer);
    SourceLightBuffer := nil;
  end;
  if RotatedLightBuffer <> nil then
  begin
    Ex_OKGR_LightBuf_Destroy(RotatedLightBuffer);
    RotatedLightBuffer := nil;
  end;
  SurfaceImageCache.SetCacheKey(ImagePath);
  SurfacePaletteCache.SetCacheKey(ImagePath);
  Image := AcquireOrCreatePalBitmap(SurfaceImageCache);
  try
    MapWidth := Image.Bitmap.Width;
    MapHeight := Image.Bitmap.Height;
    if (Cardinal(Image.Bitmap.Width) shr 1) < Cardinal(Image.Bitmap.Height) then
      raise Exception.Create('TPlanetGI.SetImage. Error create template planet. (LenX div 2)<LenY');
    if (Image.Bitmap.Width <> 16) and (Image.Bitmap.Width <> 32) and
       (Image.Bitmap.Width <> 64) and (Image.Bitmap.Width <> 128) and
       (Image.Bitmap.Width <> 256) and (Image.Bitmap.Width <> 512) and
       (Image.Bitmap.Width <> 1024) and (Image.Bitmap.Width <> 2048) then
      raise Exception.Create('TPlanetGI.SetImage. Error create template planet. LenX<>16 or 32 or 64 or 128 or 256 or 512 or 1024 or 2048');
    MapWidthMask := Image.Bitmap.Width - 1;
    SetSize(Classes.Point(Image.Bitmap.Height + 1, Image.Bitmap.Height + 1));
    TemplateCache.SetCacheKey(MaskPath + '?' + IntToStr(Cardinal(Image.Bitmap.Width)) + ',' + IntToStr(Cardinal(Image.Bitmap.Height)));
    LightControl := TCPalBitmapControlEC.Create;
    GlobalCache.ResetControl(LightControl);
    LightControl.SetCacheKey(LightMapPath);
    LightImage := AcquireOrCreatePalBitmap(LightControl);
    try
      if (Cardinal(Image.Bitmap.Height) > Cardinal(LightImage.Bitmap.Width)) or (Cardinal(Image.Bitmap.Height) > Cardinal(LightImage.Bitmap.Height)) then
        raise Exception.Create('TPlanetGI.SetImage. Error: Size light map < planet.');
      SourceLightBuffer := Ex_OKGR_LightBuf_Create(LightImage.Bitmap.Width, LightImage.Bitmap.Height);
      Ex_OKGR_LightBuf_SetSme(SourceLightBuffer, LightImage.Bitmap.Width shr 1, LightImage.Bitmap.Height shr 1);
      if SourceLightBuffer = nil then raise Exception.Create('TPlanetGI.SetImage. Error create light buffer.');
      RotatedLightBuffer := Ex_OKGR_LightBuf_Create(LightImage.Bitmap.Width, LightImage.Bitmap.Height);
      Ex_OKGR_LightBuf_SetSme(RotatedLightBuffer, LightImage.Bitmap.Width shr 1, LightImage.Bitmap.Height shr 1);
      if RotatedLightBuffer = nil then raise Exception.Create('TPlanetGI.SetImage. Error create light buffer.');
      Ex_OKGR_LightBuf_Init(SourceLightBuffer, 0);
      Ex_OKGR_LightBuf_Init(RotatedLightBuffer, 0);
      try
        LightRotationCache.SetCacheKey(IntToStr(Cardinal(LightImage.Bitmap.Width)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height)) + ',' +
          IntToStr(Cardinal(LightImage.Bitmap.Width)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height)) + ',' +
          IntToStr(Cardinal(LightImage.Bitmap.Width shr 1)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height shr 1)));
      except
        raise Exception.Create('Error in TPlanetGI.SetImage');
      end;
      Ex_OKGR_LightBuf_LoadFromPalBuf(SourceLightBuffer, LightImage.Bitmap.Pixels, LightImage.Bitmap.Width, LightImage.Bitmap.Height, LightImage.Bitmap.PitchBytes, LightImage.Bitmap.Palette);
    finally
      LightControl.Release;
      LightControl.Free;
    end;
  finally
    SurfaceImageCache.Release;
  end;
  LightAngle := 1;
  SetLightAngle(0);
end;
{ @end $4A6A70 }

{ @routine $4A7194 TPlanetGI_SetCloud1Image }
procedure TPlanetGI.SetCloud1Image(const Path: WideString);
var
  Image: TCPalBitmapEC;
begin
  Cloud1ImageCache.SetCacheKey(Path);
  Cloud1PaletteCache.SetCacheKey(Path);
  Image := AcquireOrCreatePalBitmap(Cloud1ImageCache);
  try
    if (MapWidth <> Image.Bitmap.Width) or (MapHeight <> Image.Bitmap.Height) then
      raise Exception.Create('Cloud size incorrect');
  finally
    Cloud1ImageCache.Release;
  end;
end;
{ @end $4A7194 }

{ @routine $4A7268 TPlanetGI_SetCloud2Image }
procedure TPlanetGI.SetCloud2Image(const Path: WideString);
var
  Image: TCPalBitmapEC;
begin
  Cloud2ImageCache.SetCacheKey(Path);
  Cloud2PaletteCache.SetCacheKey(Path);
  Image := AcquireOrCreatePalBitmap(Cloud2ImageCache);
  try
    if (MapWidth <> Image.Bitmap.Width) or (MapHeight <> Image.Bitmap.Height) then
      raise Exception.Create('Cloud size incorrect');
  finally
    Cloud2ImageCache.Release;
  end;
end;
{ @end $4A7268 }

{ @routine $4A733C TPlanetGI_SetCloud3Image }
procedure TPlanetGI.SetCloud3Image(const Path: WideString);
var
  Image: TCPalBitmapEC;
begin
  Cloud3ImageCache.SetCacheKey(Path);
  Cloud3PaletteCache.SetCacheKey(Path);
  Image := AcquireOrCreatePalBitmap(Cloud3ImageCache);
  try
    if (MapWidth <> Image.Bitmap.Width) or (MapHeight <> Image.Bitmap.Height) then
      raise Exception.Create('Cloud size incorrect');
  finally
    Cloud3ImageCache.Release;
  end;
end;
{ @end $4A733C }

{ @routine $4A7410 TPlanetGI_SetImageWithRadius }
procedure TPlanetGI.SetImageWithRadius(const MaskPath, ImagePath, LightMapPath: WideString; Radius: Integer);
var
  Image: TCPalBitmapEC;
  LightControl: TCPalBitmapControlEC;
  LightImage: TCPalBitmapEC;
begin
  Invalidate;
  if SourceLightBuffer <> nil then
  begin
    Ex_OKGR_LightBuf_Destroy(SourceLightBuffer);
    SourceLightBuffer := nil;
  end;
  if RotatedLightBuffer <> nil then
  begin
    Ex_OKGR_LightBuf_Destroy(RotatedLightBuffer);
    RotatedLightBuffer := nil;
  end;
  SurfaceImageCache.SetCacheKey(ImagePath);
  SurfacePaletteCache.SetCacheKey(ImagePath);
  Image := AcquireOrCreatePalBitmap(SurfaceImageCache);
  try
    MapWidth := Image.Bitmap.Width;
    MapHeight := Image.Bitmap.Height;
    if (Cardinal(Image.Bitmap.Width) shr 1) < Cardinal(Image.Bitmap.Height) then
      raise Exception.Create('TPlanetGI.SetImage. Error create template planet. (LenX div 2)<LenY');
    if (Image.Bitmap.Width <> 16) and (Image.Bitmap.Width <> 32) and
       (Image.Bitmap.Width <> 64) and (Image.Bitmap.Width <> 128) and
       (Image.Bitmap.Width <> 256) and (Image.Bitmap.Width <> 512) and
       (Image.Bitmap.Width <> 1024) and (Image.Bitmap.Width <> 2048) then
      raise Exception.Create('TPlanetGI.SetImage. Error create template planet. LenX<>16 or 32 or 64 or 128 or 256 or 512 or 1024 or 2048');
    MapWidthMask := Image.Bitmap.Width - 1;
    SetSize(Classes.Point(Radius * 2 + 1, Radius * 2 + 1));
    TemplateCache.SetCacheKey(MaskPath + '?' + IntToStr(Cardinal(Image.Bitmap.Width)) + ',' + IntToStr(Cardinal(Image.Bitmap.Height)));
    LightControl := TCPalBitmapControlEC.Create;
    GlobalCache.ResetControl(LightControl);
    LightControl.SetCacheKey(LightMapPath);
    LightImage := AcquireOrCreatePalBitmap(LightControl);
    try
      SourceLightBuffer := Ex_OKGR_LightBuf_Create(LightImage.Bitmap.Width, LightImage.Bitmap.Height);
      Ex_OKGR_LightBuf_SetSme(SourceLightBuffer, LightImage.Bitmap.Width shr 1, LightImage.Bitmap.Height shr 1);
      if SourceLightBuffer = nil then raise Exception.Create('TPlanetGI.SetImage. Error create light buffer.');
      RotatedLightBuffer := Ex_OKGR_LightBuf_Create(LightImage.Bitmap.Width, LightImage.Bitmap.Height);
      Ex_OKGR_LightBuf_SetSme(RotatedLightBuffer, LightImage.Bitmap.Width shr 1, LightImage.Bitmap.Height shr 1);
      if RotatedLightBuffer = nil then raise Exception.Create('TPlanetGI.SetImage. Error create light buffer.');
      Ex_OKGR_LightBuf_Init(SourceLightBuffer, 0);
      Ex_OKGR_LightBuf_Init(RotatedLightBuffer, 0);
      try
        LightRotationCache.SetCacheKey(IntToStr(Cardinal(LightImage.Bitmap.Width)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height)) + ',' +
          IntToStr(Cardinal(LightImage.Bitmap.Width)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height)) + ',' +
          IntToStr(Cardinal(LightImage.Bitmap.Width shr 1)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height shr 1)));
      except
        raise Exception.Create('Error in TPlanetGI.SetImageEx');
      end;
      Ex_OKGR_LightBuf_LoadFromPalBuf(SourceLightBuffer, LightImage.Bitmap.Pixels, LightImage.Bitmap.Width, LightImage.Bitmap.Height, LightImage.Bitmap.PitchBytes, LightImage.Bitmap.Palette);
    finally
      LightControl.Release;
      LightControl.Free;
    end;
  finally
    SurfaceImageCache.Release;
  end;
  LightAngle := 1;
  SetLightAngle(0);
end;
{ @end $4A7410 }

{ @routine $4A7AB8 TPlanetGI_SetImageFromTemplate }
procedure TPlanetGI.SetImageFromTemplate(const TemplateKey, ImagePath: WideString; Radius: Integer);
var
  LightControl: TCPalBitmapControlEC;
  LightImage: TCPalBitmapEC;
begin
  Invalidate;
  if SurfaceImageCache.HasEmptyCacheKey then
  begin
    SurfaceImageCache.SetCacheKey(ImagePath);
    SurfacePaletteCache.SetCacheKey(ImagePath);
  end;
  TemplateCache.SetCacheKey(TemplateKey);
  SetSize(Classes.Point(Radius * 2, Radius * 2));
  if SourceLightBuffer = nil then
  begin
    MapWidthMask := SatelliteTemplateParameter1 - 1;
    LightControl := TCPalBitmapControlEC.Create;
    GlobalCache.ResetControl(LightControl);
    LightControl.SetCacheKey(SatelliteLightMapPath);
    LightImage := AcquireOrCreatePalBitmap(LightControl);
    try
      SourceLightBuffer := Ex_OKGR_LightBuf_Create(LightImage.Bitmap.Width, LightImage.Bitmap.Height);
      Ex_OKGR_LightBuf_SetSme(SourceLightBuffer, LightImage.Bitmap.Width shr 1, LightImage.Bitmap.Height shr 1);
      if SourceLightBuffer = nil then raise Exception.Create('TPlanetGI.SetImage. Error create light buffer.');
      RotatedLightBuffer := Ex_OKGR_LightBuf_Create(LightImage.Bitmap.Width, LightImage.Bitmap.Height);
      Ex_OKGR_LightBuf_SetSme(RotatedLightBuffer, LightImage.Bitmap.Width shr 1, LightImage.Bitmap.Height shr 1);
      if RotatedLightBuffer = nil then raise Exception.Create('TPlanetGI.SetImage. Error create light buffer.');
      Ex_OKGR_LightBuf_Init(SourceLightBuffer, 0);
      Ex_OKGR_LightBuf_Init(RotatedLightBuffer, 0);
      try
        LightRotationCache.SetCacheKey(IntToStr(Cardinal(LightImage.Bitmap.Width)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height)) + ',' +
          IntToStr(Cardinal(LightImage.Bitmap.Width)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height)) + ',' +
          IntToStr(Cardinal(LightImage.Bitmap.Width shr 1)) + ',' + IntToStr(Cardinal(LightImage.Bitmap.Height shr 1)));
      except
        raise Exception.Create('Error in TPlanetGI.SetImageSputnik');
      end;
      Ex_OKGR_LightBuf_LoadFromPalBuf(SourceLightBuffer, LightImage.Bitmap.Pixels, LightImage.Bitmap.Width, LightImage.Bitmap.Height, LightImage.Bitmap.PitchBytes, LightImage.Bitmap.Palette);
    finally
      LightControl.Release;
      LightControl.Free;
    end;
    LightAngle := 1;
    SetLightAngle(0);
  end;
end;
{ @end $4A7AB8 }

{ @routine $4A7ED0 TPlanetGI_SetAtmosphere }
procedure TPlanetGI.SetAtmosphere(ImagePath, MaskPath: WideString; Color: Cardinal);
var
  Image, Mask: TCBitmapEC;
begin
  AtmosphereColor := Color;
  AtmosphereImageCache.SetCacheKey(ImagePath + '?Gray');
  AtmosphereMaskCache.SetCacheKey(MaskPath + '?Gray');
  Image := nil;
  Mask := nil;
  try
    Image := AcquireOrCreateBitmap(AtmosphereImageCache);
    Mask := AcquireOrCreateBitmap(AtmosphereMaskCache);
    AtmosphereRotationCache.SetCacheKey(IntToStr(Cardinal(Mask.Bitmap.Width)) + ',' + IntToStr(Cardinal(Mask.Bitmap.Height)) + ',' +
      IntToStr(Cardinal(Mask.Bitmap.Width)) + ',' + IntToStr(Cardinal(Mask.Bitmap.Height)) + ',' +
      IntToStr(Cardinal(Mask.Bitmap.Width shr 1)) + ',' + IntToStr(Cardinal(Mask.Bitmap.Height shr 1)));
    SetSize(Classes.Point(Image.Bitmap.Width, Image.Bitmap.Height));
    AtmosphereDirty := True;
    AtmospherePaletteDirty := True;
  finally
    if Image <> nil then AtmosphereImageCache.Release;
    if Mask <> nil then AtmosphereMaskCache.Release;
  end;
end;
{ @end $4A7ED0 }

{ @routine $4A8140 TPlanetGI_BuildAtmospherePalette }
procedure TPlanetGI.BuildAtmospherePalette;
var
  Index: Integer;
  Color: PColorRGBA;
begin
  Color := AtmosphereBuffer.Palette;
  for Index := 0 to 255 do
  begin
    Color.R := (AtmosphereColor and $FF) and $F8;
    Color.G := ((AtmosphereColor shr 8) and $FF) and $F8;
    Color.B := ((AtmosphereColor shr 16) and $FF) and $F8;
    Color.A := Index and $F8;
    Color := PColorRGBA(PAnsiChar(Color) + SizeOf(TColorRGBA));
  end;
end;
{ @end $4A8140 }

{ @routine $4A81C0 TPlanetGI_RebuildAtmosphereImage }
procedure TPlanetGI.RebuildAtmosphereImage;
var
  ImagePixels, MaskPixels, DestPixels: Pointer;
  Width: Integer;
  MulTable: Pointer;
  ImageSkip, MaskSkip, DestSkip, Height: Integer;
  Image, Mask: TCBitmapEC;
  RotatedMask: TGraphBufGR;
  Rotation: TCRotateBufEC;
begin
  Image := nil;
  Mask := nil;
  Rotation := nil;
  RotatedMask := nil;
  try
    Image := AcquireOrCreateBitmap(AtmosphereImageCache);
    Mask := AcquireOrCreateBitmap(AtmosphereMaskCache);
    Rotation := AcquireOrCreateRotateBuf(AtmosphereRotationCache);
    RotatedMask := TGraphBufGR.Create(False);
    if (AtmosphereBuffer.Width <> Image.Bitmap.Width) or (AtmosphereBuffer.Height <> Image.Bitmap.Height) then
    begin
      AtmosphereBuffer.AllocateTight(Image.Bitmap.Width, Image.Bitmap.Height, 256);
      AtmospherePaletteDirty := True;
    end;
    if AtmospherePaletteDirty then
    begin
      AtmospherePaletteDirty := False;
      BuildAtmospherePalette;
    end;
    RotatedMask.AllocateGrayscale(Mask.Bitmap.Width + (Mask.Bitmap.Width shr 1), Mask.Bitmap.Height + (Mask.Bitmap.Height shr 1));
    RotatedMask.ClearPixels;
    Ex_OKGR_RotateBuf_Draw_BYTE(RotatedMask.GetPixels, RotatedMask.PitchBytes,
      Mask.Bitmap.GetPixels, Mask.Bitmap.PitchBytes, RotatedMask.Width shr 1, RotatedMask.Height shr 1, LightAngle, Rotation.Buffer);
    Width := Image.Bitmap.Width;
    Height := Image.Bitmap.Height;
    ImagePixels := Image.Bitmap.GetPixels;
    MaskPixels := Pointer(PAnsiChar(RotatedMask.GetPixels) + ((RotatedMask.Width shr 1) - (Width shr 1)) +
      ((RotatedMask.Height shr 1) - (Height shr 1)) * RotatedMask.PitchBytes);
    DestPixels := AtmosphereBuffer.Pixels;
    ImageSkip := Image.Bitmap.PitchBytes - Width;
    MaskSkip := RotatedMask.PitchBytes - Width;
    DestSkip := AtmosphereBuffer.PitchBytes - Width;
    MulTable := Ex_OKGF_MulTable256x256;
    { This register-based pixel loop is handwritten assembly in the native routine. }
    asm
      push esi
      push edi
      push edx
      push ebx
      push ecx
      mov esi, ImagePixels
      mov edi, MaskPixels
      mov ebx, DestPixels
      mov ecx, Width
    @@Pixel:
      xor edx, edx
      mov dl, [edi]
      shl edx, 8
      add edx, MulTable
      xor eax, eax
      mov al, [esi]
      add eax, edx
      mov al, [eax]
      mov [ebx], al
      add esi, 1
      add edi, 1
      add ebx, 1
      dec ecx
      jnz @@Pixel
      mov ecx, Width
      add esi, ImageSkip
      add edi, MaskSkip
      add ebx, DestSkip
      dec Height
      jnz @@Pixel
      pop ecx
      pop ebx
      pop edx
      pop edi
      pop esi
    end;
  finally
    if Image <> nil then AtmosphereImageCache.Release;
    if Mask <> nil then AtmosphereMaskCache.Release;
    if Rotation <> nil then AtmosphereRotationCache.Release;
    if RotatedMask <> nil then RotatedMask.Free;
  end;
end;
{ @end $4A81C0 }

{ @routine $4A847C TPlanetGI_SetSurfaceMapOffset }
procedure TPlanetGI.SetSurfaceMapOffset(Value: Integer);
begin
  if SurfaceMapOffset <> Value then
  begin
    SurfaceMapOffset := Value;
    Invalidate;
  end;
end;
{ @end $4A847C }

{ @routine $4A84B4 TPlanetGI_SetCloud1MapOffset }
procedure TPlanetGI.SetCloud1MapOffset(Value: Integer);
begin
  if Cloud1MapOffset <> Value then
  begin
    Cloud1MapOffset := Value;
    Invalidate;
  end;
end;
{ @end $4A84B4 }

{ @routine $4A84EC TPlanetGI_SetCloud2MapOffset }
procedure TPlanetGI.SetCloud2MapOffset(Value: Integer);
begin
  if Cloud2MapOffset <> Value then
  begin
    Cloud2MapOffset := Value;
    Invalidate;
  end;
end;
{ @end $4A84EC }

{ @routine $4A8524 TPlanetGI_SetCloud3MapOffset }
procedure TPlanetGI.SetCloud3MapOffset(Value: Integer);
begin
  if Cloud3MapOffset <> Value then
  begin
    Cloud3MapOffset := Value;
    Invalidate;
  end;
end;
{ @end $4A8524 }

{ @routine $4A855C TPlanetGI_SetLightAngle }
procedure TPlanetGI.SetLightAngle(Value: Byte);
var
  Rotation: TCRotateBufEC;
begin
  if LightAngle <> Value then
  begin
    LightAngle := Value;
    Ex_OKGR_LightBuf_Init(RotatedLightBuffer, 0);
    Rotation := AcquireOrCreateRotateBuf(LightRotationCache);
    try
      Ex_OKGR_LightBuf_Rotate(RotatedLightBuffer, SourceLightBuffer, Rotation.Buffer, LightAngle);
    finally
      LightRotationCache.Release;
    end;
    AtmosphereDirty := True;
    Invalidate;
  end;
end;
{ @end $4A855C }

{ @routine $4A8618 TPlanetGI_LoadFromConfigPath }
procedure TPlanetGI.LoadFromConfigPath(const Path: WideString);
var
  Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if (Block.CountParams('Mask') > 0) or (Block.CountParams('Image') > 0) or (Block.CountParams('ImageLight') > 0) then
    SetImage(Block.GetParam('Mask'), Block.GetParam('Image'), Block.GetParam('ImageLight'));
  if Block.CountParams('SmeMap') > 0 then SurfaceMapOffset := StrToInt(Block.GetParam('SmeMap'));
  if Block.CountParams('AngleLight') > 0 then LightAngle := StrToInt(Block.GetParam('AngleLight'));
end;
{ @end $4A8618 }

{ @routine $4A87FC TPlanetGI_LoadFromBlock }
procedure TPlanetGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  SetImage(Block.GetParam('Mask'), Block.GetParam('Image'), Block.GetParam('ImageLight'));
  if Block.CountParams('SmeMap') > 0 then SurfaceMapOffset := StrToInt(Block.GetParam('SmeMap'));
  if Block.CountParams('AngleLight') > 0 then LightAngle := StrToInt(Block.GetParam('AngleLight'));
end;
{ @end $4A87FC }

{ @routine $4A899C TPlanetGI_Draw }
procedure TPlanetGI.Draw(ClipRect: TRect);
var
  Image, Cloud1, Cloud2, Cloud3: TCPalBitmapEC;
  Palette, CloudPalette1, CloudPalette2, CloudPalette3: TCLightPalEC;
  Template: TCPlanetTemplEC;
  HasCloud1, HasCloud2, HasCloud3: Boolean;
  Locked: TD3DLockedRect;
  Index: Integer;
  Texture: IDirect3DTexture9;
  // Native frame retains eight unused bytes; their original types are unknown.
  UnusedLocals: array[0..7] of Byte;
begin
  HasCloud1 := Cloud1ImageCache.CacheKey <> '';
  HasCloud2 := Cloud2ImageCache.CacheKey <> '';
  HasCloud3 := Cloud3ImageCache.CacheKey <> '';
  Image := nil;
  Palette := nil;
  Template := nil;
  Cloud1 := nil;
  CloudPalette1 := nil;
  Cloud2 := nil;
  CloudPalette2 := nil;
  Cloud3 := nil;
  CloudPalette3 := nil;
  try
    Template := AcquireOrCreatePlanetTemplate(TemplateCache);
    Image := AcquireOrCreatePalBitmap(SurfaceImageCache);
    Palette := AcquireOrCreateLightPalette(SurfacePaletteCache);
    if HasCloud1 then
    begin
      Cloud1 := AcquireOrCreatePalBitmap(Cloud1ImageCache);
      CloudPalette1 := AcquireOrCreateLightPalette(Cloud1PaletteCache);
    end;
    if HasCloud2 then
    begin
      Cloud2 := AcquireOrCreatePalBitmap(Cloud2ImageCache);
      CloudPalette2 := AcquireOrCreateLightPalette(Cloud2PaletteCache);
    end;
    if HasCloud3 then
    begin
      Cloud3 := AcquireOrCreatePalBitmap(Cloud3ImageCache);
      CloudPalette3 := AcquireOrCreateLightPalette(Cloud3PaletteCache);
    end;
    if HardwareRenderingEnabled then
    begin
      if TextureCache = nil then TextureCache := CreateTextureCache;
      if ((HitTestBounds.Right - HitTestBounds.Left) <> TextureSize.X) or
         ((HitTestBounds.Bottom - HitTestBounds.Top) <> TextureSize.Y) then
      begin
        RenderedMapOffsets[0] := $FFFFFF;
        RenderedMapOffsets[1] := RenderedMapOffsets[0];
        RenderedMapOffsets[2] := RenderedMapOffsets[0];
        RenderedMapOffsets[3] := RenderedMapOffsets[0];
        for Index := 0 to 3 do TextureCache.SetSurface(nil, Index);
      end;
      TextureSize := Classes.Point(HitTestBounds.Right - HitTestBounds.Left, HitTestBounds.Bottom - HitTestBounds.Top);
      Texture := TextureCache.GetSurface(0);
      if (SurfaceMapOffset <> RenderedMapOffsets[0]) or (Texture = nil) then
      begin
        RenderedMapOffsets[0] := SurfaceMapOffset;
        if Texture = nil then Texture := GR_CreateTexture(TextureSize.X, TextureSize.Y, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
        Texture.LockRect(0, Locked, nil, 0);
        if Locked.Bits <> nil then
        begin
          if Image.Bitmap.BytesPerPixel = 2 then
            Ex_OKGR_Planet3_DrawAndLight_32(Locked.Bits, Locked.Pitch, Template.TemplateData,
              Image.Bitmap.Pixels, Image.Bitmap.PitchBytes, MapWidthMask, SurfaceMapOffset,
              RotatedLightBuffer, Palette.PaletteData, TextureSize.X div 2, TextureSize.Y div 2)
          else
            Ex_OKGR_Planet2_DrawAndLight_32(Locked.Bits, Locked.Pitch, Template.TemplateData,
              Image.Bitmap.Pixels, Image.Bitmap.PitchBytes, MapWidthMask, SurfaceMapOffset,
              RotatedLightBuffer, Palette.PaletteData, TextureSize.X div 2, TextureSize.Y div 2);
          Texture.UnlockRect(0);
          TextureCache.SetSurface(Texture, 0);
        end;
      end;
      DrawTexture(Texture, HitTestBounds.Left, HitTestBounds.Top, 255, $FFFFFF, @ClipRect, False, False);
      if HasCloud1 then
      begin
        Texture := TextureCache.GetSurface(1);
        if Cloud1MapOffset <> RenderedMapOffsets[1] then
        begin
          RenderedMapOffsets[1] := Cloud1MapOffset;
          if Texture = nil then Texture := GR_CreateTexture(TextureSize.X, TextureSize.Y, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
          Texture.LockRect(0, Locked, nil, 0);
          if Locked.Bits <> nil then
            Ex_OKGR_Planet4_DrawAndLight_32(Locked.Bits, Locked.Pitch, Template.TemplateData,
              Cloud1.Bitmap.Pixels, Cloud1.Bitmap.PitchBytes, MapWidthMask, Cloud1MapOffset,
              RotatedLightBuffer, CloudPalette1.PaletteData, TextureSize.X div 2, TextureSize.Y div 2);
          Texture.UnlockRect(0);
          TextureCache.SetSurface(Texture, 1);
        end;
        DrawTexture(Texture, HitTestBounds.Left, HitTestBounds.Top, 255, $FFFFFF, @ClipRect, False, False);
      end
      else TextureCache.SetSurface(nil, 1);
      if HasCloud2 then
      begin
        Texture := TextureCache.GetSurface(2);
        if Cloud2MapOffset <> RenderedMapOffsets[2] then
        begin
          RenderedMapOffsets[2] := Cloud2MapOffset;
          if Texture = nil then Texture := GR_CreateTexture(TextureSize.X, TextureSize.Y, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
          Texture.LockRect(0, Locked, nil, 0);
          if Locked.Bits <> nil then
            Ex_OKGR_Planet4_DrawAndLight_32(Locked.Bits, Locked.Pitch, Template.TemplateData,
              Cloud2.Bitmap.Pixels, Cloud2.Bitmap.PitchBytes, MapWidthMask, Cloud2MapOffset,
              RotatedLightBuffer, CloudPalette2.PaletteData, TextureSize.X div 2, TextureSize.Y div 2);
          Texture.UnlockRect(0);
          TextureCache.SetSurface(Texture, 2);
        end;
        DrawTexture(Texture, HitTestBounds.Left, HitTestBounds.Top, 255, $FFFFFF, @ClipRect, False, False);
      end
      else TextureCache.SetSurface(nil, 2);
      if HasCloud3 then
      begin
        Texture := TextureCache.GetSurface(3);
        if Cloud3MapOffset <> RenderedMapOffsets[3] then
        begin
          RenderedMapOffsets[3] := Cloud3MapOffset;
          if Texture = nil then Texture := GR_CreateTexture(TextureSize.X, TextureSize.Y, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
          Texture.LockRect(0, Locked, nil, 0);
          if Locked.Bits <> nil then
            Ex_OKGR_Planet4_DrawAndLight_32(Locked.Bits, Locked.Pitch, Template.TemplateData,
              Cloud3.Bitmap.Pixels, Cloud3.Bitmap.PitchBytes, MapWidthMask, Cloud3MapOffset,
              RotatedLightBuffer, CloudPalette3.PaletteData, TextureSize.X div 2, TextureSize.Y div 2);
          Texture.UnlockRect(0);
          TextureCache.SetSurface(Texture, 3);
        end;
        DrawTexture(Texture, HitTestBounds.Left, HitTestBounds.Top, 255, $FFFFFF, @ClipRect, False, False);
      end
      else TextureCache.SetSurface(nil, 3);
      if not AtmosphereImageCache.HasEmptyCacheKey and AtmosphereDirty and (AtmosphereColor <> 0) then
      begin
        AtmosphereDirty := False;
        RebuildAtmosphereImage;
        AtmosphereTextureSize := Classes.Point(AtmosphereBuffer.Width, AtmosphereBuffer.Height);
        Texture := GR_CreateTexture(AtmosphereTextureSize.X, AtmosphereTextureSize.Y, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
        if Texture <> nil then
        begin
          Texture.LockRect(0, Locked, nil, 0);
          if Locked.Bits <> nil then
            ExpandPaletteToBgra(Locked.Bits, Locked.Pitch, AtmosphereTextureSize.X, AtmosphereTextureSize.Y,
              AtmosphereBuffer.Pixels, AtmosphereBuffer.PitchBytes, AtmosphereBuffer.Palette);
          Texture.UnlockRect(0);
          TextureCache.SetSurface(Texture, 4);
        end;
      end;
      Texture := TextureCache.GetSurface(4);
      if not AtmosphereImageCache.HasEmptyCacheKey and (Texture <> nil) and (AtmosphereColor <> 0) then
        DrawTexture(Texture, HitTestBounds.Left, HitTestBounds.Top, 255, $FFFFFF, @ClipRect, False, False);
    end
    else
    begin
      if Image.Bitmap.BytesPerPixel = 2 then
        Ex_OKGR_Planet3_DrawAndLightClip_16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, Template.TemplateData,
          Image.Bitmap.Pixels, Image.Bitmap.PitchBytes, MapWidthMask, SurfaceMapOffset, RotatedLightBuffer, Palette.PaletteData,
          HitTestBounds.Left + (HitTestBounds.Right - HitTestBounds.Left) div 2,
          HitTestBounds.Top + (HitTestBounds.Bottom - HitTestBounds.Top) div 2, ClipRect)
      else
        Ex_OKGR_Planet2_DrawAndLightClip_16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, Template.TemplateData,
          Image.Bitmap.Pixels, Image.Bitmap.PitchBytes, MapWidthMask, SurfaceMapOffset, RotatedLightBuffer, Palette.PaletteData,
          HitTestBounds.Left + (HitTestBounds.Right - HitTestBounds.Left) div 2,
          HitTestBounds.Top + (HitTestBounds.Bottom - HitTestBounds.Top) div 2, ClipRect);
      if HasCloud1 then
        Ex_OKGR_Planet4_DrawAndLightClip_16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, Template.TemplateData,
          Cloud1.Bitmap.Pixels, Cloud1.Bitmap.PitchBytes, MapWidthMask, Cloud1MapOffset, RotatedLightBuffer, CloudPalette1.PaletteData,
          HitTestBounds.Left + (HitTestBounds.Right - HitTestBounds.Left) div 2,
          HitTestBounds.Top + (HitTestBounds.Bottom - HitTestBounds.Top) div 2, ClipRect);
      if HasCloud2 then
        Ex_OKGR_Planet4_DrawAndLightClip_16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, Template.TemplateData,
          Cloud2.Bitmap.Pixels, Cloud2.Bitmap.PitchBytes, MapWidthMask, Cloud2MapOffset, RotatedLightBuffer, CloudPalette2.PaletteData,
          HitTestBounds.Left + (HitTestBounds.Right - HitTestBounds.Left) div 2,
          HitTestBounds.Top + (HitTestBounds.Bottom - HitTestBounds.Top) div 2, ClipRect);
      if HasCloud3 then
        Ex_OKGR_Planet4_DrawAndLightClip_16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, Template.TemplateData,
          Cloud3.Bitmap.Pixels, Cloud3.Bitmap.PitchBytes, MapWidthMask, Cloud3MapOffset, RotatedLightBuffer, CloudPalette3.PaletteData,
          HitTestBounds.Left + (HitTestBounds.Right - HitTestBounds.Left) div 2,
          HitTestBounds.Top + (HitTestBounds.Bottom - HitTestBounds.Top) div 2, ClipRect);
      if not AtmosphereImageCache.HasEmptyCacheKey and AtmosphereDirty and (AtmosphereColor <> 0) then
      begin
        AtmosphereDirty := False;
        RebuildAtmosphereImage;
      end;
      if not AtmosphereImageCache.HasEmptyCacheKey and (AtmosphereBuffer.Pixels <> nil) and (AtmosphereColor <> 0) then
        BlendPaletteBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
          HitTestBounds.Left + (HitTestBounds.Right - HitTestBounds.Left) div 2 - (AtmosphereBuffer.Width shr 1),
          HitTestBounds.Top + (HitTestBounds.Bottom - HitTestBounds.Top) div 2 - (AtmosphereBuffer.Height shr 1),
          AtmosphereBuffer, ClipRect);
    end;
  finally
    if Template <> nil then TemplateCache.Release;
    if Image <> nil then SurfaceImageCache.Release;
    if Palette <> nil then SurfacePaletteCache.Release;
    if Cloud1 <> nil then Cloud1ImageCache.Release;
    if CloudPalette1 <> nil then Cloud1PaletteCache.Release;
    if Cloud2 <> nil then Cloud2ImageCache.Release;
    if CloudPalette2 <> nil then Cloud2PaletteCache.Release;
    { Native code omits the third cloud layer's two releases. }
  end;
end;
{ @end $4A899C }

{ @routine $4A97EC TPlanetGI_RenderSurfaceToBuffer }
procedure TPlanetGI.RenderSurfaceToBuffer(Buffer: TGraphBufGR);
var
  Image: TCPalBitmapEC;
  Palette: TCLightPalEC;
  Template: TCPlanetTemplEC;
begin
  Image := nil;
  Palette := nil;
  Template := nil;
  try
    Template := AcquireOrCreatePlanetTemplate(TemplateCache);
    Image := AcquireOrCreatePalBitmap(SurfaceImageCache);
    Palette := AcquireOrCreateLightPalette(SurfacePaletteCache);
    Buffer.AllocateRgbaTight(Template.ImageHeight + 4, Template.ImageHeight + 4);
    Buffer.ClearPixels;
    if Image.Bitmap.BytesPerPixel = 2 then
      Ex_OKGR_Planet3_DrawAndLight_32(Buffer.GetPixels, Buffer.PitchBytes, Template.TemplateData,
        Image.Bitmap.Pixels, Image.Bitmap.PitchBytes, MapWidthMask, SurfaceMapOffset,
        RotatedLightBuffer, Palette.PaletteData, Buffer.Width shr 1, Buffer.Height shr 1)
    else
      Ex_OKGR_Planet2_DrawAndLight_32(Buffer.GetPixels, Buffer.PitchBytes, Template.TemplateData,
        Image.Bitmap.Pixels, Image.Bitmap.PitchBytes, MapWidthMask, SurfaceMapOffset,
        RotatedLightBuffer, Palette.PaletteData, Buffer.Width shr 1, Buffer.Height shr 1);
  finally
    if Template <> nil then TemplateCache.Release;
    if Image <> nil then SurfaceImageCache.Release;
    if Palette <> nil then SurfacePaletteCache.Release;
  end;
end;
{ @end $4A97EC }

{ @routine $4A9998 TPlanetGI_QueueImageLoad }
procedure TPlanetGI.QueueImageLoad(PendingLoads: TList);
begin
  TemplateCache.QueueLoadIfMissing(PendingLoads);
  SurfaceImageCache.QueueLoadIfMissing(PendingLoads);
  SurfacePaletteCache.QueueLoadIfMissing(PendingLoads);
  LightRotationCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4A9998 }

end.
