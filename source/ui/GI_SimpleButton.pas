unit GI_SimpleButton;
// Unit bracket (inferred): .text 0x0049BE3C..0x0049C4F1; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class ownership follows reference/unit_ownership.json.


interface

uses Classes, EC_BlockPar, EC_CacheBitmap, GI_MessageLoop, Types;

type
  TSimpleButtonGI = class(TObjectGI) // @size $12C
  public
    CurrentImage: TCBitmapControlEC; // @offset $120
    NormalImage: TCBitmapControlEC; // @offset $124
    ActiveImage: TCBitmapControlEC; // @offset $128
    constructor Create(Owner: TObjectGI); // @addr $49BF60
    destructor Destroy; override; // @addr $49BFFC
    procedure Clear; override; // @addr $49C060
    procedure OnMouseEnter; override; // @addr $49C074
    procedure OnMouseLeave; override; // @addr $49C0A4
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $49C0D4
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $49C114
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $49C154
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $49C2B8
    procedure Draw(ClipRect: TRect); override; // @addr $49C3F8
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr $49C4C0
  end;

implementation

uses GR_Main, GI_Main;

{ @routine $49BF60 TSimpleButtonGI_Create }
constructor TSimpleButtonGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  NormalImage := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(NormalImage);
  ActiveImage := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ActiveImage);
end;
{ @end $49BF60 }

{ @routine $49BFFC TSimpleButtonGI_Destroy }
destructor TSimpleButtonGI.Destroy;
begin
  NormalImage.Free;
  NormalImage := nil;
  ActiveImage.Free;
  ActiveImage := nil;
  inherited Destroy;
end;
{ @end $49BFFC }

{ @routine $49C060 TSimpleButtonGI_Clear }
procedure TSimpleButtonGI.Clear;
begin
  inherited Clear;
end;
{ @end $49C060 }

{ @routine $49C074 TSimpleButtonGI_OnMouseEnter }
procedure TSimpleButtonGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  CurrentImage := ActiveImage;
  Invalidate;
end;
{ @end $49C074 }

{ @routine $49C0A4 TSimpleButtonGI_OnMouseLeave }
procedure TSimpleButtonGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  CurrentImage := NormalImage;
  Invalidate;
end;
{ @end $49C0A4 }

{ @routine $49C0D4 TSimpleButtonGI_ProcessLeftButtonDown }
procedure TSimpleButtonGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  DispatchNamedEvent(1, Point.X, Point.Y);
end;
{ @end $49C0D4 }

{ @routine $49C114 TSimpleButtonGI_ProcessLeftButtonUp }
procedure TSimpleButtonGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  DispatchNamedEvent(2, Point.X, Point.Y);
end;
{ @end $49C114 }

{ @routine $49C154 TSimpleButtonGI_LoadFromConfigPath }
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
{ @end $49C154 }

{ @routine $49C2B8 TSimpleButtonGI_LoadFromBlock }
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
{ @end $49C2B8 }

{ @routine $49C3F8 TSimpleButtonGI_Draw }
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
{ @end $49C3F8 }

{ @routine $49C4C0 TSimpleButtonGI_QueueImageLoad }
procedure TSimpleButtonGI.QueueImageLoad(PendingLoads: TList);
begin
  NormalImage.QueueLoadIfMissing(PendingLoads);
  ActiveImage.QueueLoadIfMissing(PendingLoads);
end;
{ @end $49C4C0 }

end.
