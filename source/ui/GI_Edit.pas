unit GI_Edit;
// Unit bracket (inferred): .text 0x004A18D0..0x004A3DBD; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheBitmap, EC_CacheFont, GI_Main, GI_MessageLoop, Types;

type
  TEditAcceptCharEventGI = function(Sender: TObjectGI; Character: WideChar): Boolean of object;

  TEditGI = class(TObjectGI) // @size 0x16C
  public
    FontCache: TCFontControlEC; // @offset 0x120
    BackgroundCache: TCBitmapControlEC; // @offset 0x124
    Text: WideString; // @offset 0x128
    TextColor: Cardinal; // @offset 0x12C
    CaretColor: Cardinal; // @offset 0x130
    BorderEnabled: Boolean; // @offset 0x134
    BorderLightColor: Cardinal; // @offset 0x138
    BorderDarkColor: Cardinal; // @offset 0x13C
    MaxLength: Integer; // @offset 0x140
    HasFocus: Boolean; // @offset 0x144
    CaretPosition: Integer; // @offset 0x148
    AutoScrollText: Boolean; // @offset 0x14C
    TextAlignX: TTextAlignXGI; // @offset 0x14D
    ChangedCallback: TObjectNotifyEventGI; // @offset $150
    FocusLostCallback: TObjectNotifyEventGI; // @offset $158
    AcceptCharCallback: TEditAcceptCharEventGI; // @offset $160
    ClearFocusOnEnter: Boolean; // @offset 0x168

    constructor Create(Owner: TObjectGI); // @addr 0x4A1A00
    destructor Destroy; override; // @addr 0x4A1B1C
    procedure Clear; override; // @addr 0x4A1B80
    procedure SetFontName(FontName: WideString); // @addr 0x4A1C34
    procedure SetBorderEnabled(Value: Boolean); // @addr 0x4A1C94
    procedure SetText(Value: WideString); // @addr 0x4A1CCC @note "Resets CaretPosition on change; does not clamp to MaxLength or invoke ChangedCallback."
    function HasGlyph(Character: WideChar): Boolean; // @addr 0x4A1D48
    procedure SetTextColor(Value: Cardinal); // @addr 0x4A1DB8
    procedure SetBorderLightColor(Value: Cardinal); // @addr 0x4A1DF0
    procedure SetBorderDarkColor(Value: Cardinal); // @addr 0x4A1E28
    procedure SetTextAlignX(Value: TTextAlignXGI); // @addr 0x4A1E60 @note "Only Left and Center are accepted; other values raise."
    procedure SetCaretPosition(Value: Integer); // @addr 0x4A1EE8 @note "Clamps to 0..Length(Text)."
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4A1F50
    procedure OnCaretBlink; override; // @addr $4A24F4
    procedure OnFocusGained; override; // @addr 0x4A1F90
    procedure OnFocusLost; override; // @addr 0x4A1FD0
    procedure ProcessKeyDown(Key: Integer); override; // @addr 0x4A2018
    procedure ProcessCharacter(Character: WideChar); override; // @addr 0x4A23C8 @note "Requires a font glyph, acceptance by the optional callback, and length below MaxLength."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4A250C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4A2C74
    procedure Draw(ClipRect: TRect); override; // @addr 0x4A3428
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x4A3D80
  end;

implementation

uses SysUtils, Windows, EC_Cache, GR_Main, GR_GraphBuf, GR_DX, EC_Str;

{ @routine $4A1A00 TEditGI_Create }
constructor TEditGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  FontCache := TCFontControlEC.Create;
  GlobalCache.ResetControl(FontCache);
  BackgroundCache := nil;
  TextColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderLightColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderDarkColor := CurrentPixelFormat.PackRgbBytes(55, 55, 55);
  CaretColor := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
  BorderEnabled := False;
  TextAlignX := taxLeft;
  MaxLength := 256;
  ClearFocusOnEnter := True;
end;
{ @end $4A1A00 }

{ @routine $4A1B1C TEditGI_Destroy }
destructor TEditGI.Destroy;
begin
  FontCache.Free;
  FontCache := nil;
  BackgroundCache.Free;
  BackgroundCache := nil;
  inherited Destroy;
end;
{ @end $4A1B1C }

{ @routine $4A1B80 TEditGI_Clear }
procedure TEditGI.Clear;
begin
  inherited Clear;
  HasFocus := False;
  MaxLength := 256;
  TextColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderLightColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderDarkColor := CurrentPixelFormat.PackRgbBytes(55, 55, 55);
  CaretColor := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
  AutoScrollText := False;
  Text := '';
end;
{ @end $4A1B80 }

{ @routine $4A1C34 TEditGI_SetFontName }
procedure TEditGI.SetFontName(FontName: WideString);
begin
  FontCache.SetCacheKey(FontName);
  Invalidate;
end;
{ @end $4A1C34 }

{ @routine $4A1C94 TEditGI_SetBorderEnabled }
procedure TEditGI.SetBorderEnabled(Value: Boolean);
begin
  if Value <> BorderEnabled then
  begin
    BorderEnabled := Value;
    Invalidate;
  end;
end;
{ @end $4A1C94 }

{ @routine $4A1CCC TEditGI_SetText }
procedure TEditGI.SetText(Value: WideString);
begin
  if Text <> Value then
  begin
    Text := Value;
    CaretPosition := 0;
    Invalidate;
  end;
end;
{ @end $4A1CCC }

{ @routine $4A1D48 TEditGI_HasGlyph }
function TEditGI.HasGlyph(Character: WideChar): Boolean;
var Font: TCFontEC;
begin
  try
    Font := AcquireCachedFont(FontCache);
    Font.ResetTextMeasureState;
    Result := Font.HasGlyph(Character);
  finally
    FontCache.Release;
  end;
end;
{ @end $4A1D48 }

{ @routine $4A1DB8 TEditGI_SetTextColor }
procedure TEditGI.SetTextColor(Value: Cardinal);
begin
  if TextColor <> Value then
  begin
    TextColor := Value;
    Invalidate;
  end;
end;
{ @end $4A1DB8 }

{ @routine $4A1DF0 TEditGI_SetBorderLightColor }
procedure TEditGI.SetBorderLightColor(Value: Cardinal);
begin
  if BorderLightColor <> Value then
  begin
    BorderLightColor := Value;
    Invalidate;
  end;
end;
{ @end $4A1DF0 }

{ @routine $4A1E28 TEditGI_SetBorderDarkColor }
procedure TEditGI.SetBorderDarkColor(Value: Cardinal);
begin
  if BorderDarkColor <> Value then
  begin
    BorderDarkColor := Value;
    Invalidate;
  end;
end;
{ @end $4A1E28 }

{ @routine $4A1E60 TEditGI_SetTextAlignX }
procedure TEditGI.SetTextAlignX(Value: TTextAlignXGI);
begin
  if (Value <> taxLeft) and (Value <> taxCenter) then raise Exception.Create('Error TEditGI. This align not support.');
  if TextAlignX <> Value then
  begin
    TextAlignX := Value;
    Invalidate;
  end;
end;
{ @end $4A1E60 }

{ @routine $4A1EE8 TEditGI_SetCaretPosition }
procedure TEditGI.SetCaretPosition(Value: Integer);
begin
  if Value > Length(Text) then CaretPosition := Length(Text)
  else if Value < 0 then CaretPosition := 0
  else CaretPosition := Value;
  Invalidate;
end;
{ @end $4A1EE8 }

{ @routine $4A1F50 TEditGI_ProcessLeftButtonDown }
procedure TEditGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if Active = True then MessageLoop.SetFocusedControl(Self);
end;
{ @end $4A1F50 }

{ @routine $4A1F90 TEditGI_OnFocusGained }
procedure TEditGI.OnFocusGained;
begin
  inherited OnFocusGained;
  HasFocus := True;
  CaretPosition := Length(Text);
  Invalidate;
end;
{ @end $4A1F90 }

{ @routine $4A1FD0 TEditGI_OnFocusLost }
procedure TEditGI.OnFocusLost;
begin
  inherited OnFocusLost;
  HasFocus := False;
  if Assigned(FocusLostCallback) then FocusLostCallback(Self);
  Invalidate;
end;
{ @end $4A1FD0 }

{ @routine $4A2018 TEditGI_ProcessKeyDown }
procedure TEditGI.ProcessKeyDown(Key: Integer);
var
  I, N: Integer;
  Control: TObjectGI;
begin
  if (Key = VK_BACK) and not IsVirtualKeyDown(VK_SHIFT) then
  begin
    if CaretPosition > 0 then
    begin
      N := Length(Text);
      I := CaretPosition;
      while I < N do
      begin
        Text[I] := Text[I + 1];
        Inc(I);
      end;
      SetLength(Text, N - 1);
      Dec(CaretPosition);
      Invalidate;
      DispatchNamedEvent(4, 0, 0);
      if Assigned(ChangedCallback) then ChangedCallback(Self);
    end;
  end
  else if (Key = VK_BACK) and IsVirtualKeyDown(VK_SHIFT) then
  begin
    Text := '';
    CaretPosition := 0;
    Invalidate;
    DispatchNamedEvent(4, 0, 0);
    if Assigned(ChangedCallback) then ChangedCallback(Self);
  end
  else if Key = VK_DELETE then
  begin
    N := Length(Text);
    if CaretPosition < N then
    begin
      I := CaretPosition + 1;
      while I < N do
      begin
        Text[I] := Text[I + 1];
        Inc(I);
      end;
      SetLength(Text, N - 1);
      Invalidate;
      DispatchNamedEvent(4, 0, 0);
      if Assigned(ChangedCallback) then ChangedCallback(Self);
    end;
  end
  else if Key = VK_LEFT then
  begin
    if CaretPosition > 0 then
    begin
      Dec(CaretPosition);
      Invalidate;
    end;
  end
  else if Key = VK_RIGHT then
  begin
    if CaretPosition < Length(Text) then
    begin
      Inc(CaretPosition);
      Invalidate;
    end;
  end
  else if Key = VK_HOME then
  begin
    CaretPosition := 0;
    Invalidate;
  end
  else if Key = VK_END then
  begin
    CaretPosition := Length(Text);
    Invalidate;
  end
  else if (Key = VK_RETURN) and ClearFocusOnEnter then MessageLoop.SetFocusedControl(nil)
  else if (Key = VK_TAB) and IsVirtualKeyDown(VK_SHIFT) then
  begin
    Control := NextSibling;
    while Control <> nil do
    begin
      if (Control is TEditGI) and Control.Active then
      begin
        MessageLoop.SetFocusedControl(Control);
        Break;
      end;
      Control := Control.NextSibling;
    end;
  end
  else if Key = VK_TAB then
  begin
    Control := PrevSibling;
    while Control <> nil do
    begin
      if (Control is TEditGI) and Control.Active then
      begin
        MessageLoop.SetFocusedControl(Control);
        Break;
      end;
      Control := Control.PrevSibling;
    end;
  end;
end;
{ @end $4A2018 }

{ @routine $4A23C8 TEditGI_ProcessCharacter }
procedure TEditGI.ProcessCharacter(Character: WideChar);
var I, N: Integer;
begin
  inherited ProcessCharacter(Character);
  if HasGlyph(Character) then
    if not Assigned(AcceptCharCallback) or AcceptCharCallback(Self, Character) then
    begin
      N := Length(Text);
      if N < MaxLength then
      begin
        SetLength(Text, N + 1);
        I := N;
        while I >= CaretPosition do
        begin
          Text[I + 1] := Text[I];
          Dec(I);
        end;
        Text[CaretPosition + 1] := Character;
        Inc(CaretPosition);
        Invalidate;
        DispatchNamedEvent(4, 0, 0);
        if Assigned(ChangedCallback) then ChangedCallback(Self);
      end;
    end;
end;
{ @end $4A23C8 }

{ @routine $4A24F4 TEditGI_OnCaretBlink }
procedure TEditGI.OnCaretBlink;
begin
  Invalidate;
end;
{ @end $4A24F4 }

{ @routine $4A250C TEditGI_LoadFromConfigPath }
procedure TEditGI.LoadFromConfigPath(const Path: WideString);
var
  Block: TBlockParEC;
  ColorText: WideString;
  Red, Green, Blue: Byte;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Font') > 0 then FontCache.SetCacheKey(Block.GetParam('Font'));
  if Block.CountParams('Text') > 0 then
  begin
    Text := Block.GetParam('Text');
    if LanguageDataConfig.CountParamsByPath(Text) > 0 then Text := LanguageDataConfig.GetParamByPathOrMarker(Text);
  end;
  if Block.CountParams('Image') > 0 then
  begin
    BackgroundCache := TCBitmapControlEC.Create;
    GlobalCache.ResetControl(BackgroundCache);
    BackgroundCache.SetCacheKey(Block.GetParam('Image'));
  end;
  if Block.CountParams('TextColor') > 0 then
  begin
    ColorText := Block.GetParam('TextColor');
    Red := StrToInt(ExtractDelimitedPartW(ColorText, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(ColorText, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(ColorText, 2, ','));
    TextColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('Border') > 0 then
    if Block.GetParam('Border') = 'True' then BorderEnabled := True else BorderEnabled := False;
  if Block.CountParams('BorderLightColor') > 0 then
  begin
    ColorText := Block.GetParam('BorderLightColor');
    Red := StrToInt(ExtractDelimitedPartW(ColorText, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(ColorText, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(ColorText, 2, ','));
    BorderLightColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
    BorderDarkColor := BorderLightColor;
  end;
  if Block.CountParams('BorderDarkColor') > 0 then
  begin
    ColorText := Block.GetParam('BorderDarkColor');
    Red := StrToInt(ExtractDelimitedPartW(ColorText, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(ColorText, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(ColorText, 2, ','));
    BorderDarkColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('CursorColor') > 0 then
  begin
    ColorText := Block.GetParam('CursorColor');
    Red := StrToInt(ExtractDelimitedPartW(ColorText, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(ColorText, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(ColorText, 2, ','));
    CaretColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('MaxLen') > 0 then MaxLength := StrToInt(Block.GetParam('MaxLen'));
  if Block.CountParams('AlignX') > 0 then SetTextAlignX(ParseTextAlignXName(TrimWideString(Block.GetParam('AlignX'))));
end;
{ @end $4A250C }

{ @routine $4A2C74 TEditGI_LoadFromBlock }
procedure TEditGI.LoadFromBlock(Block: TBlockParEC);
var
  ColorText: WideString;
  Red, Green, Blue: Byte;
begin
  inherited LoadFromBlock(Block);
  FontCache.SetCacheKey(Block.GetParam('Font'));
  if Block.CountParams('ReturnFocusLeave') > 0 then ClearFocusOnEnter := ParseEnabledNameGI(TrimWideString(Block.GetParam('ReturnFocusLeave')));
  if Block.CountParams('Text') > 0 then
  begin
    Text := Block.GetParam('Text');
    if LanguageDataConfig.CountParamsByPath(Text) > 0 then Text := LanguageDataConfig.GetParamByPathOrMarker(Text);
  end;
  if Block.CountParams('Image') > 0 then
  begin
    BackgroundCache := TCBitmapControlEC.Create;
    GlobalCache.ResetControl(BackgroundCache);
    BackgroundCache.SetCacheKey(Block.GetParam('Image'));
  end;
  if Block.CountParams('TextColor') > 0 then
  begin
    ColorText := Block.GetParam('TextColor');
    Red := StrToInt(ExtractDelimitedPartW(ColorText, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(ColorText, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(ColorText, 2, ','));
    TextColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('Border') > 0 then
    if Block.GetParam('Border') = 'True' then BorderEnabled := True else BorderEnabled := False;
  if Block.CountParams('BorderLightColor') > 0 then
  begin
    ColorText := Block.GetParam('BorderLightColor');
    Red := StrToInt(ExtractDelimitedPartW(ColorText, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(ColorText, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(ColorText, 2, ','));
    BorderLightColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
    BorderDarkColor := BorderLightColor;
  end;
  if Block.CountParams('BorderDarkColor') > 0 then
  begin
    ColorText := Block.GetParam('BorderDarkColor');
    Red := StrToInt(ExtractDelimitedPartW(ColorText, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(ColorText, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(ColorText, 2, ','));
    BorderDarkColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('CursorColor') > 0 then
  begin
    ColorText := Block.GetParam('CursorColor');
    Red := StrToInt(ExtractDelimitedPartW(ColorText, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(ColorText, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(ColorText, 2, ','));
    CaretColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('MaxLen') > 0 then MaxLength := StrToInt(Block.GetParam('MaxLen'));
  if Block.CountParams('AlignX') > 0 then SetTextAlignX(ParseTextAlignXName(TrimWideString(Block.GetParam('AlignX'))));
end;
{ @end $4A2C74 }

{ @routine $4A3428 TEditGI_Draw }
procedure TEditGI.Draw(ClipRect: TRect);
var
  Font: TCFontEC;
  Bitmap: TCBitmapEC;
  X, Y, N, I, Advance, FirstCharacter, Width: Integer;
  Fits: Boolean;
  CharacterText: WideString;
  Buffer: TGraphBufGR;
begin
  Font := nil;
  Bitmap := nil;
  if FontCache = nil then Exit;
  if FontSmoothingEnabled then
  begin
    if FontCache.CacheKey = SmallFontName then FontCache.SetCacheKey(SmoothSmallFontName)
    else if FontCache.CacheKey = SmallBoldFontName then FontCache.SetCacheKey(SmoothSmallBoldFontName)
    else if FontCache.CacheKey = NormalFontName then FontCache.SetCacheKey(SmoothNormalFontName)
    else if FontCache.CacheKey = NormalBoldFontName then FontCache.SetCacheKey(SmoothNormalBoldFontName);
  end
  else
  begin
    if FontCache.CacheKey = SmoothSmallFontName then FontCache.SetCacheKey(SmallFontName)
    else if FontCache.CacheKey = SmoothSmallBoldFontName then FontCache.SetCacheKey(SmallBoldFontName)
    else if FontCache.CacheKey = SmoothNormalFontName then FontCache.SetCacheKey(NormalFontName)
    else if FontCache.CacheKey = SmoothNormalBoldFontName then FontCache.SetCacheKey(NormalBoldFontName);
  end;
  try
    Font := AcquireCachedFont(FontCache);
    Font.ResetTextMeasureState;
    Font.DefaultColor := TextColor;
    if BackgroundCache <> nil then
    begin
      Bitmap := AcquireOrCreateBitmap(BackgroundCache);
      if HardwareRenderingEnabled then
        DrawTexture(Bitmap.Bitmap.GetTexture, HitTestBounds.Left, HitTestBounds.Top, 255, RgbWhite, @ClipRect, False, False)
      else
        Ex_OKGR_Copy_XY_XY_WORD(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, ClipRect.Left, ClipRect.Top, Bitmap.Bitmap.GetPixels, Bitmap.Bitmap.PitchBytes, ClipRect.Left - HitTestBounds.Left, ClipRect.Top - HitTestBounds.Top, ClipRect.Right - ClipRect.Left, ClipRect.Bottom - ClipRect.Top);
    end;
    X := HitTestBounds.Left + 2;
    with Font.MeasureTaggedTextBounds(Text, 0, 0, nil) do
      if TextAlignX = taxCenter then X := HitTestBounds.Left + (HitTestBounds.Right - HitTestBounds.Left) div 2 - (Right - Left) div 2;
    Y := (HitTestBounds.Top + HitTestBounds.Bottom) div 2 - (Font.AboveBaseline + Font.BelowBaseline) div 2 + Font.AboveBaseline;
    N := Length(Text);
    FirstCharacter := 0;
    if AutoScrollText then
      repeat
        Fits := True;
        Width := 0;
        for I := FirstCharacter to N - 1 do
        begin
          Inc(Width, Font.GetGlyphAdvance(Text[I + 1]));
          if (CaretPosition >= I) and (Width >= ClientSize.X - 2) then
          begin
            Inc(FirstCharacter);
            Fits := False;
            Break;
          end;
        end;
      until Fits;
    if FirstCharacter > N then FirstCharacter := N;
    Buffer := TGraphBufGR.Create(True);
    if HardwareRenderingEnabled then
    begin
      Buffer.AllocateRgbaTight(HitTestBounds.Right - HitTestBounds.Left, HitTestBounds.Bottom - HitTestBounds.Top);
      Font.UseARGBColors := True;
      Font.DefaultColor := ColorWithAlpha(Color565ToArgb(TextColor), 255);
    end;
    SetLength(CharacterText, 1);
    for I := FirstCharacter to N do
    begin
      Advance := 0;
      if I < N then
      begin
        Advance := Font.GetGlyphAdvance(Text[I + 1]);
        CharacterText[1] := Text[I + 1];
        if HardwareRenderingEnabled then
        begin
          Buffer.ClearPixels;
          Font.DrawTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, X - HitTestBounds.Left, Y - HitTestBounds.Top, CharacterText, Classes.Rect(0, 0, Buffer.Width, Buffer.Height));
          DrawTexture(Buffer.GetTexture, HitTestBounds.Left, HitTestBounds.Top, 255, RgbWhite, @ClipRect, False, False);
        end
        else Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, X, Y, CharacterText, ClipRect);
      end;
      if (HasFocus = True) and (CaretPosition = I) and (MessageLoop.CaretBlinkOn = True) then
      begin
        if HardwareRenderingEnabled then
        begin
          DrawAlphaLine(X, Y - (Font.AboveBaseline - 1), X, Y - (Font.AboveBaseline - 1) + Font.AboveBaseline + Font.BelowBaseline, Color565ToArgb(CaretColor), 255, @ClipRect);
          DrawAlphaLine(X + 1, Y - (Font.AboveBaseline - 1), X + 1, Y - (Font.AboveBaseline - 1) + Font.AboveBaseline + Font.BelowBaseline, Color565ToArgb(CaretColor), 255, @ClipRect);
        end
        else
        begin
          ScreenRenderBuffer.DrawVerticalLine16Clipped(X, Y - (Font.AboveBaseline - 1), Font.AboveBaseline + Font.BelowBaseline, CaretColor, ClipRect);
          ScreenRenderBuffer.DrawVerticalLine16Clipped(X + 1, Y - (Font.AboveBaseline - 1), Font.AboveBaseline + Font.BelowBaseline, CaretColor, ClipRect);
        end;
      end;
      Inc(X, Advance);
    end;
    if Buffer <> nil then Buffer.Free;
    if BorderEnabled then
    begin
      if HardwareRenderingEnabled then
      begin
        DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - 1, HitTestBounds.Top, Color565ToArgb(BorderLightColor), 255, @ClipRect);
        DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Left, HitTestBounds.Bottom - 1, Color565ToArgb(BorderLightColor), 255, @ClipRect);
        DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Bottom - 1, HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, Color565ToArgb(BorderDarkColor), 255, @ClipRect);
        DrawAlphaLine(HitTestBounds.Right - 1, HitTestBounds.Top, HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, Color565ToArgb(BorderDarkColor), 255, @ClipRect);
      end
      else
      begin
        ScreenRenderBuffer.DrawHorizontalLine16Clipped(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - HitTestBounds.Left, BorderLightColor, ClipRect);
        ScreenRenderBuffer.DrawVerticalLine16Clipped(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Bottom - HitTestBounds.Top, BorderLightColor, ClipRect);
        ScreenRenderBuffer.DrawHorizontalLine16Clipped(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, -(HitTestBounds.Right - HitTestBounds.Left - 1), BorderDarkColor, ClipRect);
        ScreenRenderBuffer.DrawVerticalLine16Clipped(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, -(HitTestBounds.Bottom - HitTestBounds.Top - 1), BorderDarkColor, ClipRect);
      end;
    end;
  finally
    if Font <> nil then FontCache.Release;
    if Bitmap <> nil then BackgroundCache.Release;
  end;
end;
{ @end $4A3428 }

{ @routine $4A3D80 TEditGI_QueueImageLoad }
procedure TEditGI.QueueImageLoad(PendingLoads: TList);
begin
  FontCache.QueueLoadIfMissing(PendingLoads);
  if BackgroundCache <> nil then BackgroundCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4A3D80 }

end.
