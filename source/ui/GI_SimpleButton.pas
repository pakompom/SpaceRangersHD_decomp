unit GI_SimpleButton;
// Unit bracket (inferred): .text 0x004A9954..0x004AA009; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class ownership follows reference/unit_ownership.json.


interface

uses Classes, EC_BlockPar, EC_CacheBitmap, GI_MessageLoop, Types;

type
  TSimpleButtonGI = class(TObjectGI) // @size $12C
  public
    CurrentImage: TCBitmapControlEC; // @offset $120
    NormalImage: TCBitmapControlEC; // @offset $124
    ActiveImage: TCBitmapControlEC; // @offset $128
    constructor Create(Owner: TObjectGI); // @addr $4A9A78 @ida "TSimpleButtonGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $4A9B14 @ida "void __usercall $name(TSimpleButtonGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr $4A9B78
    procedure OnMouseEnter; override; // @addr $4A9B8C
    procedure OnMouseLeave; override; // @addr $4A9BBC
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4A9BEC @ida "void __usercall $name(TSimpleButtonGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4A9C2C @ida "void __usercall $name(TSimpleButtonGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4A9C6C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4A9DD0
    procedure Draw(ClipRect: TRect); override; // @addr $4A9F10 @ida "void __usercall $name(TSimpleButtonGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr $4A9FD8
  end;

implementation

uses GR_Main, GI_Main;

{ @routine $4A9A78 TSimpleButtonGI_Create }
constructor TSimpleButtonGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  NormalImage := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(NormalImage);
  ActiveImage := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ActiveImage);
end;
{ @end $4A9A78 }

{ @routine $4A9B14 TSimpleButtonGI_Destroy }
destructor TSimpleButtonGI.Destroy;
begin
  NormalImage.Free;
  NormalImage := nil;
  ActiveImage.Free;
  ActiveImage := nil;
  inherited Destroy;
end;
{ @end $4A9B14 }

{ @routine $4A9B78 TSimpleButtonGI_Clear }
procedure TSimpleButtonGI.Clear;
begin
  inherited Clear;
end;
{ @end $4A9B78 }

{ @routine $4A9B8C TSimpleButtonGI_OnMouseEnter }
procedure TSimpleButtonGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  CurrentImage := ActiveImage;
  Invalidate;
end;
{ @end $4A9B8C }

{ @routine $4A9BBC TSimpleButtonGI_OnMouseLeave }
procedure TSimpleButtonGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  CurrentImage := NormalImage;
  Invalidate;
end;
{ @end $4A9BBC }

{ @routine $4A9BEC TSimpleButtonGI_ProcessLeftButtonDown }
procedure TSimpleButtonGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  DispatchNamedEvent(1, Point.X, Point.Y);
end;
{ @end $4A9BEC }

{ @routine $4A9C2C TSimpleButtonGI_ProcessLeftButtonUp }
procedure TSimpleButtonGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  DispatchNamedEvent(2, Point.X, Point.Y);
end;
{ @end $4A9C2C }

{ @routine $4A9C6C TSimpleButtonGI_LoadFromConfigPath }
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
      SetSize(Classes.Point(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height));
    finally
      NormalImage.Release;
    end;
  end;
  if Block.CountParams('ImageActive') > 0 then
    ActiveImage.SetCacheKey(Block.GetParam('ImageActive'));
end;
{ @end $4A9C6C }

{ @routine $4A9DD0 TSimpleButtonGI_LoadFromBlock }
procedure TSimpleButtonGI.LoadFromBlock(Block: TBlockParEC);
var Bitmap: TCBitmapEC;
begin
  inherited LoadFromBlock(Block);
    NormalImage.SetCacheKey(Block.GetParam('Image'));
    Bitmap := AcquireOrCreateBitmap(NormalImage);
    try
      SetSize(Classes.Point(Bitmap.Bitmap.Width, Bitmap.Bitmap.Height));
    finally
      NormalImage.Release;
    end;
    ActiveImage.SetCacheKey(Block.GetParam('ImageActive'));
  CurrentImage := NormalImage;
end;
{ @end $4A9DD0 }

{ @routine $4A9F10 TSimpleButtonGI_Draw }
procedure TSimpleButtonGI.Draw(ClipRect: TRect);
var Bitmap: TCBitmapEC;
begin
  if CurrentImage <> nil then
  begin
    Bitmap := AcquireOrCreateBitmap(CurrentImage);
    try
      Ex_OKGR_Copy_XY_XY_WORD(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, ClipRect.Left, ClipRect.Top,
        Bitmap.Bitmap.GetPixels, Bitmap.Bitmap.PitchBytes, ClipRect.Left - HitTestBounds.Left, ClipRect.Top - HitTestBounds.Top,
        ClipRect.Right - ClipRect.Left, ClipRect.Bottom - ClipRect.Top);
    finally
      CurrentImage.Release;
    end;
  end;
end;
{ @end $4A9F10 }

{ @routine $4A9FD8 TSimpleButtonGI_QueueImageLoad }
procedure TSimpleButtonGI.QueueImageLoad(PendingLoads: TList);
begin
  NormalImage.QueueLoadIfMissing(PendingLoads);
  ActiveImage.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4A9FD8 }

end.
