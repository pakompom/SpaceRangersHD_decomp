unit GI_SimpleButton;


interface

uses Classes, EC_BlockPar, EC_CacheBitmap, GI_MessageLoop, Types;

type
  TSimpleButtonGI = class(TObjectGI) // @size $12C
  public
    CurrentImage: TCBitmapControlEC; // @offset $120
    NormalImage: TCBitmapControlEC; // @offset $124
    ActiveImage: TCBitmapControlEC; // @offset $128
    constructor Create(Owner: TObjectGI); // @addr $4B3E8C
    destructor Destroy; override; // @addr $4B3F10
    procedure Clear; override; // @addr $4B3F5C
    procedure OnMouseEnter; override; // @addr $4B3F64
    procedure OnMouseLeave; override; // @addr $4B3F88
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4B3FAC
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4B3FE0
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4B4014
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4B416C
    procedure Draw(ClipRect: TRect); override; // @addr $4B42A4
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr $4B4360
  end;

implementation

uses GR_Main, GI_Main;

{ @routine $4B3E8C TSimpleButtonGI_Create }
constructor TSimpleButtonGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  NormalImage := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(NormalImage);
  ActiveImage := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ActiveImage);
end;
{ @end $4B3E8C }

{ @routine $4B3F10 TSimpleButtonGI_Destroy }
destructor TSimpleButtonGI.Destroy;
begin
  NormalImage.Free;
  NormalImage := nil;
  ActiveImage.Free;
  ActiveImage := nil;
  inherited Destroy;
end;
{ @end $4B3F10 }

{ @routine $4B3F5C TSimpleButtonGI_Clear }
procedure TSimpleButtonGI.Clear;
begin
  inherited Clear;
end;
{ @end $4B3F5C }

{ @routine $4B3F64 TSimpleButtonGI_OnMouseEnter }
procedure TSimpleButtonGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  CurrentImage := ActiveImage;
  Invalidate;
end;
{ @end $4B3F64 }

{ @routine $4B3F88 TSimpleButtonGI_OnMouseLeave }
procedure TSimpleButtonGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  CurrentImage := NormalImage;
  Invalidate;
end;
{ @end $4B3F88 }

{ @routine $4B3FAC TSimpleButtonGI_ProcessLeftButtonDown }
procedure TSimpleButtonGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  DispatchNamedEvent(nceButtonDown, Point.X, Point.Y);
end;
{ @end $4B3FAC }

{ @routine $4B3FE0 TSimpleButtonGI_ProcessLeftButtonUp }
procedure TSimpleButtonGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  DispatchNamedEvent(nceButtonUp, Point.X, Point.Y);
end;
{ @end $4B3FE0 }

{ @routine $4B4014 TSimpleButtonGI_LoadFromConfigPath }
procedure TSimpleButtonGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC; Bitmap: TCBitmapEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Image') > 0 then
  begin
    NormalImage.SetCacheKey(Block.GetParam('Image'));
    Bitmap := AcquireOrCreateBitmap(NormalImage);
    try
      ObjectSize := Classes.Point(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height);
    finally
      NormalImage.Release;
    end;
  end;
  if Block.CountParams('ImageActive') > 0 then
    ActiveImage.SetCacheKey(Block.GetParam('ImageActive'));
end;
{ @end $4B4014 }

{ @routine $4B416C TSimpleButtonGI_LoadFromBlock }
procedure TSimpleButtonGI.LoadFromBlock(Block: TBlockParEC);
var Bitmap: TCBitmapEC;
begin
  inherited LoadFromBlock(Block);
    NormalImage.SetCacheKey(Block.GetParam('Image'));
    Bitmap := AcquireOrCreateBitmap(NormalImage);
    try
      ObjectSize := Classes.Point(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height);
    finally
      NormalImage.Release;
    end;
    ActiveImage.SetCacheKey(Block.GetParam('ImageActive'));
  CurrentImage := NormalImage;
end;
{ @end $4B416C }

{ @routine $4B42A4 TSimpleButtonGI_Draw }
procedure TSimpleButtonGI.Draw(ClipRect: TRect);
var Bitmap: TCBitmapEC;
begin
  if CurrentImage = nil then Exit;
  Bitmap := AcquireOrCreateBitmap(CurrentImage);
  try
    Ex_OKGR_Copy_XY_XY_WORD(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, ClipRect.Left, ClipRect.Top,
      Bitmap.Bitmap.GetPixels, Bitmap.Bitmap.PitchBytes, ClipRect.Left - HitTestBounds.Left, ClipRect.Top - HitTestBounds.Top,
      ClipRect.Right - ClipRect.Left, ClipRect.Bottom - ClipRect.Top);
  finally
    CurrentImage.Release;
  end;
end;
{ @end $4B42A4 }

{ @routine $4B4360 TSimpleButtonGI_QueueImageLoad }
procedure TSimpleButtonGI.QueueImageLoad(PendingLoads: TList);
begin
  NormalImage.QueueLoadIfMissing(PendingLoads);
  ActiveImage.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4B4360 }

end.
