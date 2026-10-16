unit GI_TextButton;


interface

uses Classes, EC_BlockPar, EC_CacheBitmap, EC_CacheFont, GI_MessageLoop, Types;

type
  TTextButtonKindGI = (text_button_push, text_button_toggle); // @size $04

  TTextButtonGI = class(TObjectGI) // @size $158
  public
    FontCache: TCFontControlEC; // @offset $120
    ImageCache: TCBitmapControlEC; // @offset $124
    Kind: TTextButtonKindGI; // @offset $128
    Caption: WideString; // @offset $12C
    CaptionColor: Cardinal; // @offset $130
    CaptionActiveColor: Cardinal; // @offset $134
    BorderLightColor: Cardinal; // @offset $138
    BorderDarkColor: Cardinal; // @offset $13C
    Hover: Boolean; // @offset $140
    Down: Boolean; // @offset $141
    DownCallback: TObjectNotifyEventGI; // @offset $148
    UpCallback: TObjectNotifyEventGI; // @offset $150
    constructor Create(Owner: TObjectGI); // @addr $4B2920
    destructor Destroy; override; // @addr $4B2A10
    procedure Clear; override; // @addr $4B2A5C
    procedure OnActivate; override; // @addr $4B2AE0
    procedure OnDeactivate; override; // @addr $4B2B24
    procedure OnMouseEnter; override; // @addr $4B2B48
    procedure OnMouseLeave; override; // @addr $4B2B74
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4B2BD4
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4B2CC4
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4B2D44
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4B3380
    procedure Draw(ClipRect: TRect); override; // @addr $4B39AC
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr $4B3D40
  end;

implementation

uses SysUtils, EC_Str, GR_Main, GI_Main;

{ @routine $4B2920 TTextButtonGI_Create }
constructor TTextButtonGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  FontCache := TCFontControlEC.Create;
  GlobalCache.ResetControl(FontCache);
  ImageCache := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  CaptionColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  CaptionActiveColor := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
  BorderLightColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderDarkColor := CurrentPixelFormat.PackRgbBytes(55, 55, 55);
  Kind := text_button_push;
end;
{ @end $4B2920 }

{ @routine $4B2A10 TTextButtonGI_Destroy }
destructor TTextButtonGI.Destroy;
begin
  FontCache.Free;
  FontCache := nil;
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $4B2A10 }

{ @routine $4B2A5C TTextButtonGI_Clear }
procedure TTextButtonGI.Clear;
begin
  inherited Clear;
  CaptionColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  CaptionActiveColor := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
  BorderLightColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderDarkColor := CurrentPixelFormat.PackRgbBytes(55, 55, 55);
  Caption := '';
  MouseBlocking := True;
end;
{ @end $4B2A5C }

{ @routine $4B2AE0 TTextButtonGI_OnActivate }
procedure TTextButtonGI.OnActivate;
begin
  inherited OnActivate;
  if HitTestCursor then Hover := True else Hover := False;
  if Kind = text_button_push then Down := False;
  Invalidate;
end;
{ @end $4B2AE0 }

{ @routine $4B2B24 TTextButtonGI_OnDeactivate }
procedure TTextButtonGI.OnDeactivate;
begin
  inherited OnDeactivate;
  Hover := False;
  Down := False;
  Invalidate;
end;
{ @end $4B2B24 }

{ @routine $4B2B48 TTextButtonGI_OnMouseEnter }
procedure TTextButtonGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  if IsOccludedAtPoint(AbsolutePosition) then Exit;
  Hover := True;
  Invalidate;
end;
{ @end $4B2B48 }

{ @routine $4B2B74 TTextButtonGI_OnMouseLeave }
procedure TTextButtonGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if Kind = text_button_push then
  begin
    if Down then
    begin
      Down := False;
      DispatchNamedEvent(control_event_button_up, 0, 0);
      if Assigned(UpCallback) then UpCallback(Self);
    end;
  end;
  Hover := False;
  Invalidate;
end;
{ @end $4B2B74 }

{ @routine $4B2BD4 TTextButtonGI_ProcessLeftButtonDown }
procedure TTextButtonGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if IsOccludedAtPoint(Point) then Exit;
  if Kind = text_button_push then
  begin
    Down := True;
    DispatchNamedEvent(control_event_button_down, Point.X, Point.Y);
    if Assigned(DownCallback) then DownCallback(Self);
  end else
  begin
    if Down then
    begin
      Down := False;
      DispatchNamedEvent(control_event_button_up, Point.X, Point.Y);
      if Assigned(UpCallback) then UpCallback(Self);
    end else
    begin
      Down := True;
      DispatchNamedEvent(control_event_button_down, Point.X, Point.Y);
      if Assigned(DownCallback) then DownCallback(Self);
    end;
  end;
  Invalidate;
end;
{ @end $4B2BD4 }

{ @routine $4B2CC4 TTextButtonGI_ProcessLeftButtonUp }
procedure TTextButtonGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  if IsOccludedAtPoint(Point) then Exit;
  if Kind <> text_button_push then Exit;
  Down := False;
  Invalidate;
  DispatchNamedEvent(control_event_button_up, Point.X, Point.Y);
  if Assigned(UpCallback) then
    if MessageLoop.ConsumeTimerTickChange then UpCallback(Self);
end;
{ @end $4B2CC4 }

{ @routine $4B2D44 TTextButtonGI_LoadFromConfigPath }
procedure TTextButtonGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC; Text: WideString; Red, Green, Blue: Byte;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Font') > 0 then FontCache.SetCacheKey(Block.GetParam('Font'));
  if Block.CountParams('Caption') > 0 then
  begin
    Caption := Block.GetParam('Caption');
    if LanguageDataConfig.CountParamsByPath(Caption) > 0 then
      Caption := LanguageDataConfig.GetParamByPathOrMarker(Caption);
  end;
  if Block.CountParams('Image') > 0 then ImageCache.SetCacheKey(Block.GetParam('Image'));
  if Block.CountParams('CaptionColor') > 0 then
  begin
    Text := Block.GetParam('CaptionColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    CaptionColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('CaptionActiveColor') > 0 then
  begin
    Text := Block.GetParam('CaptionActiveColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    CaptionActiveColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('BorderLightColor') > 0 then
  begin
    Text := Block.GetParam('BorderLightColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    BorderLightColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('BorderDarkColor') > 0 then
  begin
    Text := Block.GetParam('BorderDarkColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    BorderDarkColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('Kind') > 0 then
  begin
    if Block.GetParam('Kind') = 'Normal' then Kind := text_button_push else Kind := text_button_toggle;
  end;
end;
{ @end $4B2D44 }

{ @routine $4B3380 TTextButtonGI_LoadFromBlock }
procedure TTextButtonGI.LoadFromBlock(Block: TBlockParEC);
var Text: WideString; Red, Green, Blue: Byte;
begin
  inherited LoadFromBlock(Block);
  if Block.CountParams('Font') > 0 then FontCache.SetCacheKey(Block.GetParam('Font'));
  if Block.CountParams('Caption') > 0 then
  begin
    Caption := Block.GetParam('Caption');
    if LanguageDataConfig.CountParamsByPath(Caption) > 0 then
      Caption := LanguageDataConfig.GetParamByPathOrMarker(Caption);
  end;
  if Block.CountParams('Image') > 0 then ImageCache.SetCacheKey(Block.GetParam('Image'));
  if Block.CountParams('CaptionColor') > 0 then
  begin
    Text := Block.GetParam('CaptionColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    CaptionColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('CaptionActiveColor') > 0 then
  begin
    Text := Block.GetParam('CaptionActiveColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    CaptionActiveColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('BorderLightColor') > 0 then
  begin
    Text := Block.GetParam('BorderLightColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    BorderLightColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('BorderDarkColor') > 0 then
  begin
    Text := Block.GetParam('BorderDarkColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    BorderDarkColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('Kind') > 0 then
  begin
    if Block.GetParam('Kind') = 'Normal' then Kind := text_button_push else Kind := text_button_toggle;
  end;
end;
{ @end $4B3380 }

{ @routine $4B39AC TTextButtonGI_Draw }
procedure TTextButtonGI.Draw(ClipRect: TRect);
var Font: TCFontEC; Bitmap: TCBitmapEC; Bounds: TRect;
begin
  Font := nil;
  Bitmap := nil;
  if FontCache <> nil then
  begin
    try
      Font := AcquireCachedFont(FontCache);
      Font.ResetTextMeasureState;
      if (ImageCache <> nil) and (ImageCache.CacheKey <> '') then Bitmap := AcquireOrCreateBitmap(ImageCache);
      Bounds := Font.MeasureTaggedTextBounds(Caption, 0, 0, nil);
      if Bitmap <> nil then
        Ex_OKGR_Copy_XY_XY_WORD(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, ClipRect.Left, ClipRect.Top,
          Bitmap.Bitmap.GetPixels, Bitmap.Bitmap.PitchBytes, ClipRect.Left - HitTestBounds.Left, ClipRect.Top - HitTestBounds.Top,
          ClipRect.Right - ClipRect.Left, ClipRect.Bottom - ClipRect.Top);
      if Hover = True then Font.DefaultColor := CaptionActiveColor else Font.DefaultColor := CaptionColor;
      Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
        (HitTestBounds.Left + HitTestBounds.Right) div 2 - (Bounds.Right - Bounds.Left) div 2,
        (HitTestBounds.Top + HitTestBounds.Bottom) div 2 - (Bounds.Bottom - Bounds.Top) div 2 - Bounds.Top, Caption, ClipRect);
      if not Down then
      begin
        ScreenRenderBuffer.DrawHorizontalLine16Clipped(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - HitTestBounds.Left, BorderLightColor, ClipRect);
        ScreenRenderBuffer.DrawVerticalLine16Clipped(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Bottom - HitTestBounds.Top, BorderLightColor, ClipRect);
        ScreenRenderBuffer.DrawHorizontalLine16Clipped(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, -(HitTestBounds.Right - HitTestBounds.Left - 1), BorderDarkColor, ClipRect);
        ScreenRenderBuffer.DrawVerticalLine16Clipped(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, -(HitTestBounds.Bottom - HitTestBounds.Top - 1), BorderDarkColor, ClipRect);
      end else
      begin
        ScreenRenderBuffer.DrawHorizontalLine16Clipped(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - HitTestBounds.Left - 1, BorderDarkColor, ClipRect);
        ScreenRenderBuffer.DrawVerticalLine16Clipped(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Bottom - HitTestBounds.Top - 1, BorderDarkColor, ClipRect);
        ScreenRenderBuffer.DrawHorizontalLine16Clipped(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, -(HitTestBounds.Right - HitTestBounds.Left), BorderLightColor, ClipRect);
        ScreenRenderBuffer.DrawVerticalLine16Clipped(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, -(HitTestBounds.Bottom - HitTestBounds.Top), BorderLightColor, ClipRect);
      end;
    finally
      if Font <> nil then FontCache.Release;
      if Bitmap <> nil then ImageCache.Release;
    end;
  end;
  inherited Draw(ClipRect);
end;
{ @end $4B39AC }

{ @routine $4B3D40 TTextButtonGI_QueueImageLoad }
procedure TTextButtonGI.QueueImageLoad(PendingLoads: TList);
begin
  FontCache.QueueLoadIfMissing(PendingLoads);
  if ImageCache <> nil then ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4B3D40 }

end.
