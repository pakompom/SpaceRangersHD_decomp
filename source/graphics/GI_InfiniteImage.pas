unit GI_InfiniteImage;

interface

uses Classes, EC_BlockPar, EC_CacheBitmap, GI_MessageLoop, Types;

type
  TInfiniteImageGI = class(TObjectGI) // @size 0x124
  public
    ImageCache: TCBitmapControlEC; // @offset 0x120

    constructor Create(Owner: TObjectGI); // @addr 0x004B6E64
    destructor Destroy; override; // @addr 0x004B6EC4
    procedure SetImagePath(Path: WideString); // @addr 0x004B6EFC @note "Resets size to two billion pixels on each axis and centers the origin."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004B6F90
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004B6FBC
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x004B6FD8
    procedure Draw(ClipRect: TRect); override; // @addr 0x004B7098 @note "The hardware drawing path is unimplemented."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x004B71F4
  end;

implementation

uses Math, GR_Main, GI_Main, EC_Cache;
{ @routine $4B6E64 TInfiniteImageGI_Create }
constructor TInfiniteImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
end;
{ @end $4B6E64 }

{ @routine $4B6EC4 TInfiniteImageGI_Destroy }
destructor TInfiniteImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $4B6EC4 }

{ @routine $4B6EFC TInfiniteImageGI_SetImagePath }
procedure TInfiniteImageGI.SetImagePath(Path: WideString);
begin
  SetSize(Classes.Point(2000000000, 2000000000));
  SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y div 2));
  ImageCache.SetCacheKey(Path);
end;
{ @end $4B6EFC }

{ @routine $4B6F90 TInfiniteImageGI_LoadFromConfigPath }
procedure TInfiniteImageGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B6F90 }

{ @routine $4B6FBC TInfiniteImageGI_LoadFromBlock }
procedure TInfiniteImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $4B6FBC }

{ @routine $4B6FD8 TInfiniteImageGI_LoadImageProperties }
procedure TInfiniteImageGI.LoadImageProperties(Block: TBlockParEC);
begin
  SetSize(Classes.Point(2000000000, 2000000000));
  SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y div 2));
  if Block.CountParams('Image') > 0 then SetImagePath(Block.GetParam('Image'));
end;
{ @end $4B6FD8 }

{ @routine $4B7098 TInfiniteImageGI_Draw }
procedure TInfiniteImageGI.Draw(ClipRect: TRect);
var
  TileOrigin: TPoint;
  Image: TCBitmapEC;
  Width, Height, X, Y: Integer;
begin
  Image := AcquireOrCreateBitmap(ImageCache);
  try
    Width := Image.Bitmap.Width;
    Height := Image.Bitmap.Height;
    TileOrigin.X := Floor((ClipRect.Left - AbsolutePosition.X) / Width) * Width + AbsolutePosition.X;
    TileOrigin.Y := Floor((ClipRect.Top - AbsolutePosition.Y) / Height) * Height + AbsolutePosition.Y;
    if HardwareRenderingEnabled then
    begin
      Y := TileOrigin.Y;
      while Y < ClipRect.Bottom do
      begin
        X := TileOrigin.X;
        while X < ClipRect.Right do
        begin
          { This native path only logs; it does not draw a hardware tile. }
          AppendLogLineThreadSafe('InfiniteImageDraw');
          Inc(X, Width);
        end;
        Inc(Y, Height);
      end;
    end
    else
    begin
      Y := TileOrigin.Y;
      while Y < ClipRect.Bottom do
      begin
        X := TileOrigin.X;
        while X < ClipRect.Right do
        begin
          CopyGraphBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
            X, Y, Image.Bitmap, ClipRect, False, False);
          Inc(X, Width);
        end;
        Inc(Y, Height);
      end;
    end;
  finally
    ImageCache.Release;
  end;
end;
{ @end $4B7098 }

{ @routine $4B71F4 TInfiniteImageGI_QueueImageLoad }
procedure TInfiniteImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4B71F4 }

end.
