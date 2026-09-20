unit GI_InfiniteImage;
// Unit bracket (inferred): .text 0x0049844C..0x004989A0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheBitmap, GI_MessageLoop, Types;

type
  TInfiniteImageGI = class(TObjectGI) // @size 0x124
  public
    ImageCache: TCBitmapControlEC; // @offset 0x120

    constructor Create(Owner: TObjectGI); // @addr 0x498574
    destructor Destroy; override; // @addr 0x4985E8
    procedure SetImagePath(Path: WideString); // @addr 0x498634 @note "Resets size to two billion pixels on each axis and centers the origin."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4986D4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x498708
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x498730
    procedure Draw(ClipRect: TRect); override; // @addr 0x4987F8 @note "The hardware drawing path is unimplemented."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x498980
  end;

implementation

uses Math, GR_Main, GI_Main, EC_Cache;
{ @routine $498574 TInfiniteImageGI_Create }
constructor TInfiniteImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
end;
{ @end $498574 }

{ @routine $4985E8 TInfiniteImageGI_Destroy }
destructor TInfiniteImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $4985E8 }

{ @routine $498634 TInfiniteImageGI_SetImagePath }
procedure TInfiniteImageGI.SetImagePath(Path: WideString);
begin
  SetSize(Classes.Point(2000000000, 2000000000));
  SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y div 2));
  ImageCache.SetCacheKey(Path);
end;
{ @end $498634 }

{ @routine $4986D4 TInfiniteImageGI_LoadFromConfigPath }
procedure TInfiniteImageGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4986D4 }

{ @routine $498708 TInfiniteImageGI_LoadFromBlock }
procedure TInfiniteImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $498708 }

{ @routine $498730 TInfiniteImageGI_LoadImageProperties }
procedure TInfiniteImageGI.LoadImageProperties(Block: TBlockParEC);
begin
  SetSize(Classes.Point(2000000000, 2000000000));
  SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y div 2));
  if Block.CountParams('Image') > 0 then SetImagePath(Block.GetParam('Image'));
end;
{ @end $498730 }

{ @routine $4987F8 TInfiniteImageGI_Draw }
procedure TInfiniteImageGI.Draw(ClipRect: TRect);
var
  StartY, StartX: Integer;
  Image: TCBitmapEC;
  Width, Height, X, Y: Integer;
begin
  Image := AcquireOrCreateBitmap(ImageCache);
  try
    Width := Image.Bitmap.Width;
    Height := Image.Bitmap.Height;
    StartX := Floor((ClipRect.Left - AbsolutePosition.X) / Width) * Width + AbsolutePosition.X;
    StartY := Floor((ClipRect.Top - AbsolutePosition.Y) / Height) * Height + AbsolutePosition.Y;
    if HardwareRenderingEnabled then
    begin
      Y := StartY;
      while Y < ClipRect.Bottom do
      begin
        X := StartX;
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
      Y := StartY;
      while Y < ClipRect.Bottom do
      begin
        X := StartX;
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
{ @end $4987F8 }

{ @routine $498980 TInfiniteImageGI_QueueImageLoad }
procedure TInfiniteImageGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $498980 }

end.
