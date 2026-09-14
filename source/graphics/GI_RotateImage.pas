unit GI_RotateImage;
// Unit bracket (inferred): .text 0x004B1B34..0x004B24A9; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheBitmap, EC_CacheRotateBuf, GI_MessageLoop, Types;

type
  TRotateImageGI = class(TObjectGI) // @size 0x12C
  public
    ImageCache: TCBitmapControlEC; // @offset 0x120
    RotationCache: TCRotateBufControlEC; // @offset 0x124
    Angle: Byte; // @offset 0x128

    constructor Create(Owner: TObjectGI); // @addr 0x4B1C58 @ida "TRotateImageGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4B1CF4 @ida "void __usercall $name(TRotateImageGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4B1D58 @note "Preserves both cache keys."
    procedure SetAngle(Value: Byte); // @addr 0x4B1D74 @note "A full turn has 256 steps."
    procedure UpdateHitTestBounds; override; // @addr 0x4B1DDC @note "Leaves bounds unchanged when the rotation cache key is empty."
    function GetLocalBounds: TRect; override; // @addr 0x4B1E74 @ida "void __usercall $name(TRotateImageGI *Self@<eax>, TRect *Result@<edx>);" @note "Leaves Result unwritten when the rotation cache key is empty."
    procedure SetImage(Path: WideString; ImageSize: TPoint); // @addr 0x4B1F0C @ida "void __usercall $name(TRotateImageGI *Self@<eax>, unsigned __int16 *Path@<edx>, TPoint *ImageSize@<ecx>);" @note "Uses the current Origin as the rotation pivot."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4B2098
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4B21E0
    procedure Draw(ClipRect: TRect); override; // @addr 0x4B2308 @ida "void __usercall $name(TRotateImageGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x4B2478
  end;

implementation

uses SysUtils, GR_Main, GI_Main, GlobalsV;

{ @routine $4B1C58 TRotateImageGI_Create }
constructor TRotateImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  RotationCache := TCRotateBufControlEC.Create;
  GlobalCache.ResetControl(RotationCache);
end;
{ @end $4B1C58 }

{ @routine $4B1CF4 TRotateImageGI_Destroy }
destructor TRotateImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  RotationCache.Free;
  RotationCache := nil;
  inherited Destroy;
end;
{ @end $4B1CF4 }

{ @routine $4B1D58 TRotateImageGI_Clear }
procedure TRotateImageGI.Clear;
begin
  Angle := 0;
  inherited Clear;
end;
{ @end $4B1D58 }

{ @routine $4B1D74 TRotateImageGI_SetAngle }
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
{ @end $4B1D74 }

{ @routine $4B1DDC TRotateImageGI_UpdateHitTestBounds }
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
{ @end $4B1DDC }

{ @routine $4B1E74 TRotateImageGI_GetLocalBounds }
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
{ @end $4B1E74 }

{ @routine $4B1F0C TRotateImageGI_SetImage }
procedure TRotateImageGI.SetImage(Path: WideString; ImageSize: TPoint);
var Bitmap: TCBitmapEC;
begin
  ImageCache.SetCacheKey(Path);
  Bitmap := AcquireOrCreateBitmap(ImageCache);
  try
    RotationCache.SetCacheKey(IntToStr(ImageSize.X) + ',' + IntToStr(ImageSize.Y) + ',' + IntToStr(Cardinal(Bitmap.Bitmap.Width)) + ',' +
      IntToStr(Cardinal(Bitmap.Bitmap.Height)) + ',' + IntToStr(OriginPoint.X) + ',' + IntToStr(OriginPoint.Y));
    SetSize(ImageSize);
  finally
    ImageCache.Release;
  end;
end;
{ @end $4B1F0C }

{ @routine $4B2098 TRotateImageGI_LoadFromConfigPath }
procedure TRotateImageGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if (Block.CountParams('Image') > 0) and (Block.CountParams('Size') > 0) then
    SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')));
  if Block.CountParams('Angle') > 0 then Angle := StrToInt(Block.GetParam('Angle'));
end;
{ @end $4B2098 }

{ @routine $4B21E0 TRotateImageGI_LoadFromBlock }
procedure TRotateImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Angle := 1;
  SetAngle(0);
  SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')));
  if Block.CountParams('Angle') > 0 then Angle := StrToInt(Block.GetParam('Angle'));
end;
{ @end $4B21E0 }

{ @routine $4B2308 TRotateImageGI_Draw }
procedure TRotateImageGI.Draw(ClipRect: TRect);
var Bitmap: TCBitmapEC; Rotation: TCRotateBufEC; Rect: TRect;
begin
  if HitTestBounds.Left + ClientSize.X < 0 then Exit;
  if HitTestBounds.Left - ClientSize.X div 2 > GameScreenWidth then Exit;
  if HitTestBounds.Top + ClientSize.Y < 0 then Exit;
  if HitTestBounds.Top - ClientSize.Y div 2 > GameScreenHeight then Exit;
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
{ @end $4B2308 }

{ @routine $4B2478 TRotateImageGI_QueueImageLoad }
procedure TRotateImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
  RotationCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4B2478 }

end.
