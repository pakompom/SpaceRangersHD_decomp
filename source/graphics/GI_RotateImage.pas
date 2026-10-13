unit GI_RotateImage;

interface

uses Classes, EC_BlockPar, EC_CacheBitmap, EC_CacheRotateBuf, GI_MessageLoop, Types;

type
  TRotateImageGI = class(TObjectGI) // @size 0x12C
  public
    ImageCache: TCBitmapControlEC; // @offset 0x120
    RotationCache: TCRotateBufControlEC; // @offset 0x124
    Angle: Byte; // @offset 0x128

    constructor Create(Owner: TObjectGI); // @addr 0x004BAE18
    destructor Destroy; override; // @addr 0x004BAE9C
    procedure Clear; override; // @addr 0x004BAEE8 @note "Preserves both cache keys."
    procedure SetAngle(Value: Byte); // @addr 0x004BAEF8 @note "A full turn has 256 steps."
    procedure UpdateHitTestBounds; override; // @addr 0x004BAF40 @note "Leaves bounds unchanged when the rotation cache key is empty."
    function GetLocalBounds: TRect; override; // @addr 0x004BAFD0 @note "Leaves Result unwritten when the rotation cache key is empty."
    procedure SetImage(Path: WideString; ImageSize: TPoint); // @addr 0x004BB058 @note "Uses the current Origin as the rotation pivot."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004BB1E0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004BB310
    procedure Draw(ClipRect: TRect); override; // @addr 0x004BB420
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x004BB580
  end;

implementation

uses SysUtils, GR_Main, GI_Main, GlobalsV;

{ @routine $4BAE18 TRotateImageGI_Create }
constructor TRotateImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  RotationCache := TCRotateBufControlEC.Create;
  GlobalCache.ResetControl(RotationCache);
end;
{ @end $4BAE18 }

{ @routine $4BAE9C TRotateImageGI_Destroy }
destructor TRotateImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  RotationCache.Free;
  RotationCache := nil;
  inherited Destroy;
end;
{ @end $4BAE9C }

{ @routine $4BAEE8 TRotateImageGI_Clear }
procedure TRotateImageGI.Clear;
begin
  Angle := 0;
  inherited Clear;
end;
{ @end $4BAEE8 }

{ @routine $4BAEF8 TRotateImageGI_SetAngle }
procedure TRotateImageGI.SetAngle(Value: Byte);
begin
  if Value = Angle then Exit;
  if not Active then Angle := Value
  else
  begin
    Invalidate;
    Angle := Value;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
  end;
end;
{ @end $4BAEF8 }

{ @routine $4BAF40 TRotateImageGI_UpdateHitTestBounds }
procedure TRotateImageGI.UpdateHitTestBounds;
var Rotation: TCRotateBufEC;
begin
  if RotationCache.HasEmptyCacheKey then Exit;
  Rotation := AcquireOrCreateRotateBuf(RotationCache);
  try
    Ex_OKGR_RotateBuf_Size(AbsolutePosition.X, AbsolutePosition.Y, Angle, Rotation.Buffer, HitTestBounds);
    Inc(HitTestBounds.Right);
    Inc(HitTestBounds.Bottom);
  finally
    RotationCache.Release;
  end;
end;
{ @end $4BAF40 }

{ @routine $4BAFD0 TRotateImageGI_GetLocalBounds }
function TRotateImageGI.GetLocalBounds: TRect;
var Rotation: TCRotateBufEC;
begin
  if RotationCache.HasEmptyCacheKey then Exit;
  Rotation := AcquireOrCreateRotateBuf(RotationCache);
  try
    Ex_OKGR_RotateBuf_Size(LocalPosition.X, LocalPosition.Y, Angle, Rotation.Buffer, Result);
    Inc(Result.Right);
    Inc(Result.Bottom);
  finally
    RotationCache.Release;
  end;
end;
{ @end $4BAFD0 }

{ @routine $4BB058 TRotateImageGI_SetImage }
procedure TRotateImageGI.SetImage(Path: WideString; ImageSize: TPoint);
var Bitmap: TCBitmapEC;
begin
  ImageCache.SetCacheKey(Path);
  Bitmap := AcquireOrCreateBitmap(ImageCache);
  try
    RotationCache.SetCacheKey(IntToStr(ImageSize.X) + ',' + IntToStr(ImageSize.Y) + ',' + IntToStr(Bitmap.Bitmap.Width) + ',' +
      IntToStr(Bitmap.Bitmap.Height) + ',' + IntToStr(OriginPoint.X) + ',' + IntToStr(OriginPoint.Y));
    SetSize(ImageSize);
  finally
    ImageCache.Release;
  end;
end;
{ @end $4BB058 }

{ @routine $4BB1E0 TRotateImageGI_LoadFromConfigPath }
procedure TRotateImageGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if (Block.CountParams('Image') > 0) and (Block.CountParams('Size') > 0) then
    SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')));
  if Block.CountParams('Angle') > 0 then Angle := StrToInt(Block.GetParam('Angle'));
end;
{ @end $4BB1E0 }

{ @routine $4BB310 TRotateImageGI_LoadFromBlock }
procedure TRotateImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Angle := 1;
  SetAngle(0);
  SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')));
  if Block.CountParams('Angle') > 0 then Angle := StrToInt(Block.GetParam('Angle'));
end;
{ @end $4BB310 }

{ @routine $4BB420 TRotateImageGI_Draw }
procedure TRotateImageGI.Draw(ClipRect: TRect);
var Bitmap: TCBitmapEC; Rotation: TCRotateBufEC; Rect: TRect;
begin
  if HitTestBounds.Left + ClientSize.X < 0 then Exit;
  if HitTestBounds.Left - ClientSize.X div 2 > Integer(GameScreenWidth) then Exit;
  if HitTestBounds.Top + ClientSize.Y < 0 then Exit;
  if HitTestBounds.Top - ClientSize.Y div 2 > Integer(GameScreenHeight) then Exit;
  Bitmap := nil;
  Rotation := nil;
  try
    Bitmap := AcquireOrCreateBitmap(ImageCache);
    Rotation := AcquireOrCreateRotateBuf(RotationCache);
    Rect.Left := ClipRect.Left;
    Rect.Top := ClipRect.Top;
    Rect.Right := ClipRect.Right - 1;
    Rect.Bottom := ClipRect.Bottom - 1;
    Ex_OKGR_RotateBuf_DrawTransClip_WORD(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, Bitmap.Bitmap.GetPixels,
      Bitmap.Bitmap.PitchBytes, AbsolutePosition.X, AbsolutePosition.Y, Angle, Rotation.Buffer, Rect);
  finally
    if Bitmap <> nil then ImageCache.Release;
    if Rotation <> nil then RotationCache.Release;
  end;
end;
{ @end $4BB420 }

{ @routine $4BB580 TRotateImageGI_QueueImageLoad }
procedure TRotateImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
  RotationCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4BB580 }

end.
