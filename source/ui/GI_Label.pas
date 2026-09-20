unit GI_Label;
// Unit bracket (inferred): .text 0x00488920..0x0048C7D7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheFont, EC_Str, GI_Image, GI_Main, GI_MessageLoop, GR_DX, GR_GraphBuf, Types;

type
  TLabelGI = class;
  TCreateLabelControlEventGI = function(Sender: TLabelGI; Item: PFontObjectEC): TObjectGI of object;

  TLabelGI = class(TObjectGI) // @size 0x16C
  public
    FontCache: TCFontControlEC; // @offset 0x120
    EmbeddedImage: TImageGI; // @offset 0x124
    TextLines: TStringsEC; // @offset 0x128
    TextColor: Cardinal; // @offset 0x12C
    TextBorderWidth: Integer; // @offset 0x130
    TextBorderColor: Cardinal; // @offset 0x134
    TextShadowOffset: Integer; // @offset 0x138
    TextShadowColor: Cardinal; // @offset 0x13C
    BorderEnabled: Boolean; // @offset 0x140
    BorderLightColor: Cardinal; // @offset 0x144
    BorderDarkColor: Cardinal; // @offset 0x148
    TextAlignX: TTextAlignXGI; // @offset 0x14C
    TextAlignY: TTextAlignYGI; // @offset 0x14D
    TextLeft: Integer; // @offset 0x150
    TextTop: Integer; // @offset 0x154
    WordWrapEnabled: Boolean; // @offset 0x158
    AutoHeightPadding: Integer; // @offset 0x15C
    CreateEmbeddedControl: TCreateLabelControlEventGI; // @offset $160
    TextTexture: TTextureGR; // @offset 0x168

    constructor Create(Owner: TObjectGI); // @addr 0x488A40
    destructor Destroy; override; // @addr 0x488B74
    procedure Clear; override; // @addr 0x488BFC
    procedure SetFontName(const FontName: WideString); // @addr 0x488CEC
    procedure SetTextBorderWidth(Value: Integer); // @addr 0x488D40
    procedure SetTextBorderColor(Value: Cardinal); // @addr 0x488D90
    procedure SetShadowOffset(Value: Integer); // @addr 0x488DE0
    procedure SetShadowColor(Value: Cardinal); // @addr 0x488E38
    procedure SetText(const Text: WideString); // @addr 0x488E70
    procedure LoadTextLinesFromBlockParam(Block: TBlockParEC; const ParamName: WideString); // @addr 0x488F20
    function GetText: WideString; // @addr 0x489114
    procedure SetTextAlignX(Value: TTextAlignXGI); // @addr 0x489138
    procedure SetTextAlignY(Value: TTextAlignYGI); // @addr 0x489198
    procedure SetWordWrapEnabled(Value: Boolean); // @addr 0x4891F8
    procedure SetAutoHeightPadding(Value: Integer); // @addr 0x489258
    procedure SetEmbeddedImagePath(const ImagePath: WideString); // @addr 0x4892B8 @note "An empty path frees the embedded child."
    procedure SetEmbeddedImageKindX(Value: TImageKindXGI); // @addr 0x489378
    procedure SetEmbeddedImageKindY(Value: TImageKindYGI); // @addr 0x4893A8
    procedure SetEmbeddedImageHalfAlpha(Value: Boolean); // @addr 0x4893D8
    procedure SetTextColor(Value: Cardinal); // @addr 0x489408
    procedure SetBorderLightColor(Value: Cardinal); // @addr 0x48945C
    procedure SetBorderDarkColor(Value: Cardinal); // @addr 0x489494
    function MeasureContentSize(TopAdjustment: PInteger): TPoint; // @addr 0x4894CC @note "TopAdjustment is optional; includes text outline/shadow padding."
    function GetLineHeight: Integer; // @addr 0x489848
    function GetRenderedLineCount: Integer; // @addr 0x4898B0 @note "Includes word wrapping when enabled."
    procedure UpdateHitTestBounds; override; // @addr 0x4899EC @note "May resize the control to fit its text."
    procedure SetSize(Size: TPoint); override; // @addr 0x489BC4
    procedure UpdateEmbeddedControls(Font: TCFontEC); // @addr 0x489C04 @note "Missing embedded controls are requested through the creation callback."
    procedure RemoveUnusedEmbeddedControls(Font: TCFontEC); // @addr 0x489D6C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x489EF8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x48A30C
    procedure Draw(ClipRect: TRect); override; // @addr 0x48A8D0
    procedure OnMouseEnter; override; // @addr $489DF0
    procedure OnMouseLeave; override; // @addr $489E50
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $489EA0
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $489ECC
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x48C140
  end;

function MeasureLabelTextBounds(const Text, FontName: WideString): TRect; // @addr $48C164 Includes the native right/bottom padding.
function MeasureWrappedLabelBounds(Width: Integer; TextLines: TStringsEC; Font: TCFontEC): TRect; // @addr $48C230
procedure DrawWrappedLabelLines(Buffer: TGraphBufGR; Width, X, Y: Integer; TextLines: TStringsEC; Font: TCFontEC); // @addr $48C3DC
procedure RenderLabelTextToBuffer(Buffer: TGraphBufGR; Width, BorderWidth, ShadowOffset: Integer; const Text, FontName: WideString; TextColor, BorderColor, ShadowColor: Cardinal); // @addr $48C574

implementation

uses EC_Cache, GR_Main, Math, Windows, SysUtils, GlobalsV, Direct3D9;

{ @routine $488A40 TLabelGI_Create }
constructor TLabelGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  FontCache := TCFontControlEC.Create;
  GlobalCache.ResetControl(FontCache);
  EmbeddedImage := nil;
  TextLines := TStringsEC.Create;
  TextColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderLightColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderDarkColor := CurrentPixelFormat.PackRgbBytes(55, 55, 55);
  TextBorderWidth := 0;
  TextBorderColor := 0;
  BorderEnabled := False;
  TextAlignX := taxCenter;
  TextAlignY := tayCenter;
  AutoHeightPadding := 4;
  TextTexture := nil;
end;
{ @end $488A40 }

{ @routine $488B74 TLabelGI_Destroy }
destructor TLabelGI.Destroy;
begin
  FontCache.Free;
  FontCache := nil;
  TextLines.Free;
  TextLines := nil;
  if TextTexture <> nil then
  begin
    FreeTextureCache(TextTexture);
    TextTexture := nil;
  end;
  inherited Destroy;
end;
{ @end $488B74 }

{ @routine $488BFC TLabelGI_Clear }
procedure TLabelGI.Clear;
begin
  inherited Clear;
  TextColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderLightColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BorderDarkColor := CurrentPixelFormat.PackRgbBytes(55, 55, 55);
  BorderEnabled := False;
  TextAlignX := taxCenter;
  TextAlignY := tayCenter;
  if TextLines <> nil then TextLines.Clear;
  if EmbeddedImage <> nil then
  begin
    FreeOwnedChild(EmbeddedImage);
    EmbeddedImage := nil;
  end;
  if TextTexture <> nil then
  begin
    FreeTextureCache(TextTexture);
    TextTexture := nil;
  end;
end;
{ @end $488BFC }

{ @routine $488CEC TLabelGI_SetFontName }
procedure TLabelGI.SetFontName(const FontName: WideString);
begin
  Invalidate;
  FontCache.SetCacheKey(FontName);
  Invalidate;
  if TextTexture <> nil then TextTexture.ReleaseSurfaces;
end;
{ @end $488CEC }

{ @routine $488D40 TLabelGI_SetTextBorderWidth }
procedure TLabelGI.SetTextBorderWidth(Value: Integer);
begin
  if Value <> TextBorderWidth then
  begin
    TextBorderWidth := Value;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $488D40 }

{ @routine $488D90 TLabelGI_SetTextBorderColor }
procedure TLabelGI.SetTextBorderColor(Value: Cardinal);
begin
  if Value <> TextBorderColor then
  begin
    TextBorderColor := Value;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $488D90 }

{ @routine $488DE0 TLabelGI_SetShadowOffset }
procedure TLabelGI.SetShadowOffset(Value: Integer);
begin
  if Value <> TextShadowOffset then
  begin
    TextShadowOffset := Value;
    Invalidate;
    if TextTexture <> nil then TextTexture.SetSurface(nil, 1);
  end;
end;
{ @end $488DE0 }

{ @routine $488E38 TLabelGI_SetShadowColor }
procedure TLabelGI.SetShadowColor(Value: Cardinal);
begin
  if Value <> TextShadowColor then
  begin
    TextShadowColor := Value;
    Invalidate;
  end;
end;
{ @end $488E38 }

{ @routine $488E70 TLabelGI_SetText }
procedure TLabelGI.SetText(const Text: WideString);
begin
  if TextLines.GetText <> Text then
  begin
    Invalidate;
    TextLines.SetText(Text);
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $488E70 }

{ @routine $488F20 TLabelGI_LoadTextLinesFromBlockParam }
procedure TLabelGI.LoadTextLinesFromBlockParam(Block: TBlockParEC; const ParamName: WideString);
var Index, Count: Integer; Key: WideString;
begin
  TextLines.Clear;
  Count := Block.CountParams(ParamName);
  for Index := 0 to Count - 1 do
    TextLines.Add(Block.GetParamByPath(ParamName + ':' + IntToStr(Index)));
  if Count > 0 then
  begin
    Key := TrimWideString(TextLines.GetText);
    Count := LanguageDataConfig.CountParamsByPath(Key);
    if Count > 0 then
    begin
      TextLines.Clear;
      for Index := 0 to Count - 1 do
        TextLines.Add(LanguageDataConfig.GetParamByPathOrMarker(Key + ':' + IntToStr(Index)));
    end;
  end;
  UpdateAbsolutePosition;
  UpdateSubtreeHitBounds;
  Invalidate;
  if TextTexture <> nil then TextTexture.ReleaseSurfaces;
end;
{ @end $488F20 }

{ @routine $489114 TLabelGI_GetText }
function TLabelGI.GetText: WideString;
begin
  Result := TextLines.GetText;
end;
{ @end $489114 }

{ @routine $489138 TLabelGI_SetTextAlignX }
procedure TLabelGI.SetTextAlignX(Value: TTextAlignXGI);
begin
  if TextAlignX <> Value then
  begin
    TextAlignX := Value;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $489138 }

{ @routine $489198 TLabelGI_SetTextAlignY }
procedure TLabelGI.SetTextAlignY(Value: TTextAlignYGI);
begin
  if TextAlignY <> Value then
  begin
    TextAlignY := Value;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $489198 }

{ @routine $4891F8 TLabelGI_SetWordWrapEnabled }
procedure TLabelGI.SetWordWrapEnabled(Value: Boolean);
begin
  if WordWrapEnabled <> Value then
  begin
    WordWrapEnabled := Value;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $4891F8 }

{ @routine $489258 TLabelGI_SetAutoHeightPadding }
procedure TLabelGI.SetAutoHeightPadding(Value: Integer);
begin
  if AutoHeightPadding <> Value then
  begin
    AutoHeightPadding := Value;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $489258 }

{ @routine $4892B8 TLabelGI_SetEmbeddedImagePath }
procedure TLabelGI.SetEmbeddedImagePath(const ImagePath: WideString);
begin
  Invalidate;
  if ImagePath = '' then
  begin
    if EmbeddedImage <> nil then
    begin
      FreeOwnedChild(EmbeddedImage);
      EmbeddedImage := nil;
    end;
  end
  else
  begin
    if EmbeddedImage = nil then EmbeddedImage := TImageGI.Create(Self);
    EmbeddedImage.SetImagePath(ImagePath);
    EmbeddedImage.SetImageKindX(ikxLeftFill);
    EmbeddedImage.SetImageKindY(ikyTopFill);
    EmbeddedImage.SetSize(ClientSize);
  end;
end;
{ @end $4892B8 }

{ @routine $489378 TLabelGI_SetEmbeddedImageKindX }
procedure TLabelGI.SetEmbeddedImageKindX(Value: TImageKindXGI);
begin
  if EmbeddedImage <> nil then EmbeddedImage.SetImageKindX(Value);
end;
{ @end $489378 }

{ @routine $4893A8 TLabelGI_SetEmbeddedImageKindY }
procedure TLabelGI.SetEmbeddedImageKindY(Value: TImageKindYGI);
begin
  if EmbeddedImage <> nil then EmbeddedImage.SetImageKindY(Value);
end;
{ @end $4893A8 }

{ @routine $4893D8 TLabelGI_SetEmbeddedImageHalfAlpha }
procedure TLabelGI.SetEmbeddedImageHalfAlpha(Value: Boolean);
begin
  if EmbeddedImage <> nil then EmbeddedImage.SetHalfAlpha(Value);
end;
{ @end $4893D8 }

{ @routine $489408 TLabelGI_SetTextColor }
procedure TLabelGI.SetTextColor(Value: Cardinal);
begin
  if TextColor <> Value then
  begin
    TextColor := Value;
    Invalidate;
    if TextTexture <> nil then TextTexture.SetSurface(nil, 0);
  end;
end;
{ @end $489408 }

{ @routine $48945C TLabelGI_SetBorderLightColor }
procedure TLabelGI.SetBorderLightColor(Value: Cardinal);
begin
  if BorderLightColor <> Value then
  begin
    BorderLightColor := Value;
    Invalidate;
  end;
end;
{ @end $48945C }

{ @routine $489494 TLabelGI_SetBorderDarkColor }
procedure TLabelGI.SetBorderDarkColor(Value: Cardinal);
begin
  if BorderDarkColor <> Value then
  begin
    BorderDarkColor := Value;
    Invalidate;
  end;
end;
{ @end $489494 }

{ @routine $4894CC TLabelGI_MeasureContentSize }
function TLabelGI.MeasureContentSize(TopAdjustment: PInteger): TPoint;
var Font: TCFontEC; Y: Integer; Lines: TStringsEC; FirstLine: Boolean; Padding: Integer; Bounds, LineBounds: TRect;
begin
  if TopAdjustment <> nil then TopAdjustment^ := 0;
  Bounds.Left := 0;
  Bounds.Right := 0;
  Bounds.Top := 0;
  Bounds.Bottom := 0;
  Padding := 0;
  if not FontCache.HasEmptyCacheKey then
  begin
    Font := AcquireCachedFont(FontCache);
    try
      Font.ResetTextMeasureState;
      Y := 0;
      TextLines.First;
      if not WordWrapEnabled then
      begin
        if not TextLines.IsAtEnd then
        begin
          Bounds := Font.MeasureTaggedTextBounds(TextLines.GetCurrentText, 0, Y, TopAdjustment);
          Inc(Y, Font.GetLineHeight);
          TextLines.Next;
        end;
        while not TextLines.IsAtEnd do
        begin
          LineBounds := Font.MeasureTaggedTextBounds(TextLines.GetCurrentText, 0, Y, nil);
          UnionRect(Bounds, Bounds, LineBounds);
          Inc(Y, Font.GetLineHeight);
          TextLines.Next;
        end;
      end
      else
      begin
        Lines := TStringsEC.Create;
        FirstLine := True;
        while not TextLines.IsAtEnd do
        begin
          Font.WrapTaggedTextIntoLines(Lines, TextLines.GetCurrentText, ClientSize.X - 4);
          if not Lines.IsEmpty then
          begin
            Lines.First;
            if FirstLine then
            begin
              Bounds := Font.MeasureTaggedTextBounds(Lines.GetCurrentText, 0, Y, TopAdjustment);
              FirstLine := False;
              Inc(Y, Font.GetLineHeight);
              Lines.Next;
            end;
            while not Lines.IsAtEnd do
            begin
              LineBounds := Font.MeasureTaggedTextBounds(Lines.GetCurrentText, 0, Y, nil);
              UnionRect(Bounds, Bounds, LineBounds);
              Inc(Y, Font.GetLineHeight);
              Lines.Next;
            end;
          end;
          TextLines.Next;
        end;
        Lines.Free;
      end;
      Inc(Result.Y, 2);
      Padding := 2;
    finally
      FontCache.Release;
    end;
  end;
  Result := Classes.Point(Bounds.Right - Bounds.Left + TextBorderWidth + Max(TextBorderWidth, TextShadowOffset),
    Padding + Bounds.Bottom - Bounds.Top + TextBorderWidth + Max(TextBorderWidth, TextShadowOffset));
end;
{ @end $4894CC }

{ @routine $489848 TLabelGI_GetLineHeight }
function TLabelGI.GetLineHeight: Integer;
var Font: TCFontEC;
begin
  Font := AcquireCachedFont(FontCache);
  try
    Font.ResetTextMeasureState;
    Result := Font.GetLineHeight;
  finally
    FontCache.Release;
  end;
end;
{ @end $489848 }

{ @routine $4898B0 TLabelGI_GetRenderedLineCount }
function TLabelGI.GetRenderedLineCount: Integer;
var Font: TCFontEC; Lines: TStringsEC;
begin
  Result := 0;
  Font := nil;
  if FontCache <> nil then
  begin
    try
      Font := AcquireCachedFont(FontCache);
      if not WordWrapEnabled then Result := TextLines.GetCount
      else
      begin
        Lines := TStringsEC.Create;
        TextLines.First;
        while not TextLines.IsAtEnd do
        begin
          Font.WrapTaggedTextIntoLines(Lines, TextLines.GetCurrentText, ClientSize.X - 4);
          Inc(Result, Lines.GetCount);
          TextLines.Next;
        end;
        Lines.Free;
      end;
    finally
      if Font <> nil then FontCache.Release;
    end;
  end;
end;
{ @end $4898B0 }

{ @routine $4899EC TLabelGI_UpdateHitTestBounds }
procedure TLabelGI.UpdateHitTestBounds;
var Size: TPoint; TopAdjustment: Integer;
begin
  Size := MeasureContentSize(@TopAdjustment);
  if (TextAlignX = taxLeft) or (WordWrapEnabled = True) then TextLeft := AbsolutePosition.X + 2
  else if TextAlignX = taxRight then TextLeft := AbsolutePosition.X + ClientSize.X - Size.X - 2
  else if TextAlignX = taxCenter then TextLeft := ClientSize.X div 2 + AbsolutePosition.X - Size.X div 2
  else if TextAlignX = taxAuto then
  begin
    TextLeft := AbsolutePosition.X + 2;
    ClientSize.X := Size.X + 4;
  end;
  if TextAlignY = tayTop then TextTop := AbsolutePosition.Y + 2 + TopAdjustment
  else if TextAlignY = tayBottom then TextTop := AbsolutePosition.Y + ClientSize.Y - Size.Y - 2 + TopAdjustment
  else if TextAlignY = tayCenter then TextTop := ClientSize.Y div 2 + AbsolutePosition.Y - Size.Y div 2 + TopAdjustment
  else if TextAlignY = tayCenterEx then TextTop := ClientSize.Y div 2 + AbsolutePosition.Y - Size.Y div 2 + TopAdjustment
  else if TextAlignY = tayAuto then
  begin
    TextTop := AbsolutePosition.Y + 2 + TopAdjustment;
    ClientSize.Y := Size.Y + AutoHeightPadding;
  end;
  inherited UpdateHitTestBounds;
end;
{ @end $4899EC }

{ @routine $489BC4 TLabelGI_SetSize }
procedure TLabelGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if EmbeddedImage <> nil then EmbeddedImage.SetSize(Size);
end;
{ @end $489BC4 }

{ @routine $489C04 TLabelGI_UpdateEmbeddedControls }
procedure TLabelGI.UpdateEmbeddedControls(Font: TCFontEC);
var Index: Integer; Child: TObjectGI; Item: PFontObjectEC; Position: TPoint;
begin
  for Index := 0 to Font.ObjectCount - 1 do
  begin
    Item := Font.GetEmbeddedObject(Index);
    if HardwareRenderingEnabled then Position := Classes.Point(Item.X, Item.Y)
    else Position := ToLocalPoint(Classes.Point(Item.X, Item.Y));
    Child := FirstChild;
    while Child <> nil do
    begin
      if (Child.UserValue = Item.ObjectId) and (Child.UserIndex = Index) then
      begin
        Child.SetPosition(Position);
        Child.SetSize(Classes.Point(Item.Width, Item.Height));
        Break;
      end;
      Child := Child.NextSibling;
    end;
    if (Child = nil) and Assigned(CreateEmbeddedControl) then
    begin
      Child := CreateEmbeddedControl(Self, Item);
      if Child <> nil then
      begin
        Child.UserValue := Item.ObjectId;
        Child.UserIndex := Index;
        Child.SetPosition(Position);
        Child.SetSize(Classes.Point(Item.Width, Item.Height));
      end;
    end;
  end;
end;
{ @end $489C04 }

{ @routine $489D6C TLabelGI_RemoveUnusedEmbeddedControls }
procedure TLabelGI.RemoveUnusedEmbeddedControls(Font: TCFontEC);
var Index: Integer; Child, Previous: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    Index := 0;
    while Index < Font.ObjectCount do
    begin
      if (Child.UserIndex = Index) and (Child.UserValue = Font.GetEmbeddedObject(Index).ObjectId) then Break;
      Inc(Index);
    end;
    Previous := Child;
    Child := Child.NextSibling;
    if Index >= Font.ObjectCount then Previous.Free;
  end;
end;
{ @end $489D6C }

{ @routine $489DF0 TLabelGI_OnMouseEnter }
procedure TLabelGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  if (HelpText <> '') and (MessageLoop.HoveredControl <> Self) then
  begin
    MessageLoop.SetHoveredControl(Self);
    if Assigned(HelpCallback) then HelpCallback(Self, True);
  end;
end;
{ @end $489DF0 }

{ @routine $489E50 TLabelGI_OnMouseLeave }
procedure TLabelGI.OnMouseLeave;
begin
  if MessageLoop.HoveredControl = Self then
  begin
    MessageLoop.SetHoveredControl(nil);
    if Assigned(HelpCallback) then HelpCallback(Self, False);
  end;
  inherited OnMouseLeave;
end;
{ @end $489E50 }

{ @routine $489EA0 TLabelGI_ProcessLeftButtonDown }
procedure TLabelGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
end;
{ @end $489EA0 }

{ @routine $489ECC TLabelGI_ProcessLeftButtonUp }
procedure TLabelGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
end;
{ @end $489ECC }

{ @routine $489EF8 TLabelGI_LoadFromConfigPath }
procedure TLabelGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC; Alignment: WideString;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Font') > 0 then FontCache.SetCacheKey(Block.GetParam('Font'));
  LoadTextLinesFromBlockParam(Block, 'Text');
  if Block.CountParams('Image') > 0 then SetEmbeddedImagePath(Block.GetParam('Image'));
  if Block.CountParams('ImageKindX') > 0 then SetEmbeddedImageKindX(ParseImageKindXName(Block.GetParam('ImageKindX')));
  if Block.CountParams('ImageKindY') > 0 then SetEmbeddedImageKindY(ParseImageKindYName(Block.GetParam('ImageKindY')));
  if Block.CountParams('TextColor') > 0 then SetTextColor(GetColorGI(Block.GetParam('TextColor')));
  if Block.CountParams('Border') > 0 then
  begin
    if Block.GetParam('Border') = 'True' then BorderEnabled := True
    else BorderEnabled := False;
  end;
  if Block.CountParams('BorderLightColor') > 0 then
  begin
    SetBorderLightColor(GetColorGI(Block.GetParam('BorderLightColor')));
    SetBorderDarkColor(BorderLightColor);
  end;
  if Block.CountParams('BorderDarkColor') > 0 then SetBorderDarkColor(GetColorGI(Block.GetParam('BorderDarkColor')));
  if Block.CountParams('WordWrap') > 0 then SetWordWrapEnabled(ParseEnabledNameGI(TrimWideString(Block.GetParam('WordWrap'))));
  if Block.CountParams('AlignY') > 0 then
  begin
    Alignment := TrimWideString(Block.GetParam('AlignY'));
    SetTextAlignY(ParseTextAlignYName(Alignment));
  end;
  if Block.CountParams('AlignX') > 0 then
  begin
    Alignment := TrimWideString(Block.GetParam('AlignX'));
    SetTextAlignX(ParseTextAlignXName(Alignment));
  end;
end;
{ @end $489EF8 }

{ @routine $48A30C TLabelGI_LoadFromBlock }
procedure TLabelGI.LoadFromBlock(Block: TBlockParEC);
var Alignment: WideString;
begin
  inherited LoadFromBlock(Block);
  if Block.CountParams('Font') > 0 then FontCache.SetCacheKey(Block.GetParam('Font'));
  LoadTextLinesFromBlockParam(Block, 'Text');
  if Block.CountParams('Image') > 0 then SetEmbeddedImagePath(Block.GetParam('Image'));
  if Block.CountParams('ImageKindX') > 0 then SetEmbeddedImageKindX(ParseImageKindXName(Block.GetParam('ImageKindX')));
  if Block.CountParams('ImageKindY') > 0 then SetEmbeddedImageKindY(ParseImageKindYName(Block.GetParam('ImageKindY')));
  if Block.CountParams('TextColor') > 0 then SetTextColor(GetColorGI(Block.GetParam('TextColor')));
  if Block.CountParams('Border') > 0 then
  begin
    if Block.GetParam('Border') = 'True' then BorderEnabled := True
    else BorderEnabled := False;
  end;
  if Block.CountParams('BorderLightColor') > 0 then
  begin
    SetBorderLightColor(GetColorGI(Block.GetParam('BorderLightColor')));
    SetBorderDarkColor(BorderLightColor);
  end;
  if Block.CountParams('BorderDarkColor') > 0 then SetBorderDarkColor(GetColorGI(Block.GetParam('BorderDarkColor')));
  if Block.CountParams('WordWrap') > 0 then SetWordWrapEnabled(ParseEnabledNameGI(TrimWideString(Block.GetParam('WordWrap'))));
  if Block.CountParams('AlignY') > 0 then
  begin
    Alignment := TrimWideString(Block.GetParam('AlignY'));
    SetTextAlignY(ParseTextAlignYName(Alignment));
  end;
  if Block.CountParams('AlignX') > 0 then
  begin
    Alignment := TrimWideString(Block.GetParam('AlignX'));
    SetTextAlignX(ParseTextAlignXName(Alignment));
  end;
  if Block.CountParams('TextBorderColor') > 0 then SetTextBorderColor(GetColorGI(Block.GetParam('TextBorderColor')));
  if Block.CountParams('TextShadowColor') > 0 then SetShadowColor(GetColorGI(Block.GetParam('TextShadowColor')));
  if Block.CountParams('TextBorder') > 0 then SetTextBorderWidth(ExtractDigitsToIntW(Block.GetParam('TextBorder')));
  if Block.CountParams('TextShadow') > 0 then SetShadowOffset(ExtractDigitsToIntW(Block.GetParam('TextShadow')));
end;
{ @end $48A30C }

{ @routine $48A8D0 TLabelGI_Draw }
procedure TLabelGI.Draw(ClipRect: TRect);
var Font: TCFontEC; Y: Integer; Lines: TStringsEC; Color: Cardinal; Texture: IDirect3DTexture9; Bounds: TRect;

  // @nested $48A85C SwitchLabelDrawFont
  procedure SwitchLabelDrawFont(FontName: WideString); // @addr 0x48A85C @calls "0x48A943,0x48A971,0x48A99F,0x48A9D1,0x48A9FF,0x48AA2A,0x48AA55,0x48AA80" @note "Nested Draw helper; caller removes the parent-frame argument."
  begin
    FontCache.SetCacheKey(FontName);
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;

begin
  Font := nil;
  if FontCache <> nil then
  begin
    if FontSmoothingEnabled then
    begin
      if FontCache.CacheKey = SmallFontName then SwitchLabelDrawFont(SmoothSmallFontName)
      else if FontCache.CacheKey = SmallBoldFontName then SwitchLabelDrawFont(SmoothSmallBoldFontName)
      else if FontCache.CacheKey = NormalFontName then SwitchLabelDrawFont(SmoothNormalFontName)
      else if FontCache.CacheKey = NormalBoldFontName then SwitchLabelDrawFont(SmoothNormalBoldFontName);
    end
    else
    begin
      if FontCache.CacheKey = SmoothSmallFontName then SwitchLabelDrawFont(SmallFontName)
      else if FontCache.CacheKey = SmoothSmallBoldFontName then SwitchLabelDrawFont(SmallBoldFontName)
      else if FontCache.CacheKey = SmoothNormalFontName then SwitchLabelDrawFont(NormalFontName)
      else if FontCache.CacheKey = SmoothNormalBoldFontName then SwitchLabelDrawFont(NormalBoldFontName);
    end;
    try
      Font := AcquireCachedFont(FontCache);
      Font.ResetTextMeasureState;
      if HardwareRenderingEnabled then
      begin
        if TextTexture = nil then TextTexture := CreateTextureCache;
        Texture := TextTexture.GetSurface(1);
        if (Texture = nil) and ((TextShadowOffset > 0) or (TextBorderWidth > 0)) then
        begin
          Font.ColorTagsEnabled := False;
          Font.DefaultColor := $FFFFFFFF;
          Font.RenderTaggedTextToTexture(TextLines.GetText, ClientSize.X, ClientSize.Y, Ord(TextAlignX), Ord(TextAlignY), WordWrapEnabled, nil, Texture);
          TextTexture.SetSurface(Texture, 1);
        end;
        if TextShadowOffset > 0 then
          DrawTexture(Texture, AbsolutePosition.X + TextShadowOffset, AbsolutePosition.Y + TextShadowOffset, 255,
            Color565ToArgb(TextShadowColor), @ClipRect, False, False);
        if TextBorderWidth > 0 then
        begin
          Color := Color565ToArgb(TextBorderColor);
          DrawTexture(Texture, AbsolutePosition.X - TextBorderWidth, AbsolutePosition.Y - TextBorderWidth, 255, Color, @ClipRect, False, False);
          DrawTexture(Texture, AbsolutePosition.X + TextBorderWidth, AbsolutePosition.Y - TextBorderWidth, 255, Color, @ClipRect, False, False);
          DrawTexture(Texture, AbsolutePosition.X - TextBorderWidth, AbsolutePosition.Y + TextBorderWidth, 255, Color, @ClipRect, False, False);
          DrawTexture(Texture, AbsolutePosition.X + TextBorderWidth, AbsolutePosition.Y + TextBorderWidth, 255, Color, @ClipRect, False, False);
        end;
        Texture := TextTexture.GetSurface(0);
        if Texture = nil then
        begin
          Font.ColorTagsEnabled := True;
          Font.DefaultColor := Color565ToArgb(TextColor);
          Font.RenderTaggedTextToTexture(TextLines.GetText, ClientSize.X, ClientSize.Y, Ord(TextAlignX), Ord(TextAlignY), WordWrapEnabled, nil, Texture);
          UpdateEmbeddedControls(Font);
          RemoveUnusedEmbeddedControls(Font);
          TextTexture.SetSurface(Texture, 0);
        end;
        DrawTexture(Texture, AbsolutePosition.X, AbsolutePosition.Y, 255, $FFFFFF, @ClipRect, False, False);
        if BorderEnabled then
        begin
          Color := Color565ToArgb(BorderLightColor);
          DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - 1, HitTestBounds.Top, Color, 255, @ClipRect);
          DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Left, HitTestBounds.Bottom - 1, Color, 255, @ClipRect);
          Color := Color565ToArgb(BorderDarkColor);
          DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Bottom - 1, HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, Color, 255, @ClipRect);
          DrawAlphaLine(HitTestBounds.Right - 1, HitTestBounds.Top, HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, Color, 255, @ClipRect);
        end;
      end
      else
      begin
        if not WordWrapEnabled then
        begin
          if TextAlignY = tayCenterEx then
            Y := HitTestBounds.Top + ClientSize.Y div 2 - (Font.GetLineHeight * (TextLines.GetCount - 1) + Font.GetCenteringHeight) div 2 + Font.GetCenteringHeight
          else Y := TextTop + Font.AboveBaseline - 2;
          TextLines.First;
          while not TextLines.IsAtEnd do
          begin
            Font.ColorTagsEnabled := False;
            if TextShadowOffset > 0 then
            begin
              Font.DefaultColor := TextShadowColor;
              Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextShadowOffset, Y + TextShadowOffset, TextLines.GetCurrentText, ClipRect);
            end;
            if TextBorderWidth > 0 then
            begin
              Font.DefaultColor := TextBorderColor;
              Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft - TextBorderWidth, Y - TextBorderWidth, TextLines.GetCurrentText, ClipRect);
              Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextBorderWidth, Y - TextBorderWidth, TextLines.GetCurrentText, ClipRect);
              Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft - TextBorderWidth, Y + TextBorderWidth, TextLines.GetCurrentText, ClipRect);
              Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextBorderWidth, Y + TextBorderWidth, TextLines.GetCurrentText, ClipRect);
            end;
            Font.ColorTagsEnabled := True;
            Font.DefaultColor := TextColor;
            Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft, Y, TextLines.GetCurrentText, ClipRect);
            Inc(Y, Font.GetLineHeight);
            TextLines.Next;
          end;
        end
        else
        begin
          Lines := TStringsEC.Create;
          Y := TextTop + Font.AboveBaseline - 2;
          TextLines.First;
          while not TextLines.IsAtEnd do
          begin
            Font.WrapTaggedTextIntoLines(Lines, TextLines.GetCurrentText, ClientSize.X - 4);
            Lines.First;
            while not Lines.IsAtEnd do
            begin
              if TextAlignX = taxLeft then
              begin
                Font.ColorTagsEnabled := False;
                if TextShadowOffset > 0 then
                begin
                  Font.DefaultColor := TextShadowColor;
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextShadowOffset, Y + TextShadowOffset, Lines.GetCurrentText, ClipRect);
                end;
                if TextBorderWidth > 0 then
                begin
                  Font.DefaultColor := TextBorderColor;
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft - TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft - TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClipRect);
                end;
                Font.ColorTagsEnabled := True;
                Font.DefaultColor := TextColor;
                Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft, Y, Lines.GetCurrentText, ClipRect);
              end
              else if TextAlignX = taxRight then
              begin
                Font.ColorTagsEnabled := False;
                Bounds := Font.MeasureTaggedTextBounds(Lines.GetCurrentText, 0, 0, nil);
                if TextShadowOffset > 0 then
                begin
                  Font.DefaultColor := TextShadowColor;
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, HitTestBounds.Right - (Bounds.Right - Bounds.Left) - 2 + TextShadowOffset, Y + TextShadowOffset, Lines.GetCurrentText, ClipRect);
                end;
                if TextBorderWidth > 0 then
                begin
                  Font.DefaultColor := TextBorderColor;
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, HitTestBounds.Right - (Bounds.Right - Bounds.Left) - 2 - TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, HitTestBounds.Right - (Bounds.Right - Bounds.Left) - 2 + TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, HitTestBounds.Right - (Bounds.Right - Bounds.Left) - 2 - TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, HitTestBounds.Right - (Bounds.Right - Bounds.Left) - 2 + TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClipRect);
                end;
                Font.ColorTagsEnabled := True;
                Font.DefaultColor := TextColor;
                Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, HitTestBounds.Right - (Bounds.Right - Bounds.Left) - 2, Y, Lines.GetCurrentText, ClipRect);
              end
              else if TextAlignX = taxCenter then
              begin
                Font.ColorTagsEnabled := False;
                Bounds := Font.MeasureTaggedTextBounds(Lines.GetCurrentText, 0, 0, nil);
                if TextShadowOffset > 0 then
                begin
                  Font.DefaultColor := TextShadowColor;
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - (Bounds.Right - Bounds.Left) div 2 + TextShadowOffset, Y + TextShadowOffset, Lines.GetCurrentText, ClipRect);
                end;
                if TextBorderWidth > 0 then
                begin
                  Font.DefaultColor := TextBorderColor;
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - (Bounds.Right - Bounds.Left) div 2 - TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - (Bounds.Right - Bounds.Left) div 2 + TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - (Bounds.Right - Bounds.Left) div 2 - TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - (Bounds.Right - Bounds.Left) div 2 + TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClipRect);
                end;
                Font.ColorTagsEnabled := True;
                Font.DefaultColor := TextColor;
                Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, (HitTestBounds.Right - HitTestBounds.Left) div 2 + HitTestBounds.Left - (Bounds.Right - Bounds.Left) div 2, Y, Lines.GetCurrentText, ClipRect);
              end
              else if (TextAlignX = taxAuto) and (not Lines.IsAtLast) then
              begin
                Font.ColorTagsEnabled := False;
                if TextShadowOffset > 0 then
                begin
                  Font.DefaultColor := TextShadowColor;
                  Font.DrawJustifiedTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextShadowOffset, Y + TextShadowOffset, Lines.GetCurrentText, ClientSize.X - 4, ClipRect);
                end;
                if TextBorderWidth > 0 then
                begin
                  Font.DefaultColor := TextBorderColor;
                  Font.DrawJustifiedTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft - TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClientSize.X - 4, ClipRect);
                  Font.DrawJustifiedTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClientSize.X - 4, ClipRect);
                  Font.DrawJustifiedTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft - TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClientSize.X - 4, ClipRect);
                  Font.DrawJustifiedTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClientSize.X - 4, ClipRect);
                end;
                Font.ColorTagsEnabled := True;
                Font.DefaultColor := TextColor;
                Font.DrawJustifiedTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft, Y, Lines.GetCurrentText, ClientSize.X - 4, ClipRect);
              end
              else
              begin
                Font.ColorTagsEnabled := False;
                if TextShadowOffset > 0 then
                begin
                  Font.DefaultColor := TextShadowColor;
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextShadowOffset, Y + TextShadowOffset, Lines.GetCurrentText, ClipRect);
                end;
                if TextBorderWidth > 0 then
                begin
                  Font.DefaultColor := TextBorderColor;
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft - TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextBorderWidth, Y - TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft - TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClipRect);
                  Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft + TextBorderWidth, Y + TextBorderWidth, Lines.GetCurrentText, ClipRect);
                end;
                Font.ColorTagsEnabled := True;
                Font.DefaultColor := TextColor;
                Font.DrawTaggedText16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes, TextLeft, Y, Lines.GetCurrentText, ClipRect);
              end;
              Inc(Y, Font.GetLineHeight);
              Lines.Next;
            end;
            TextLines.Next;
          end;
          Lines.Free;
        end;
        if BorderEnabled then
        begin
          ScreenRenderBuffer.DrawHorizontalLine16Clipped(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - HitTestBounds.Left, BorderLightColor, ClipRect);
          ScreenRenderBuffer.DrawVerticalLine16Clipped(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Bottom - HitTestBounds.Top, BorderLightColor, ClipRect);
          ScreenRenderBuffer.DrawHorizontalLine16Clipped(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, -(HitTestBounds.Right - HitTestBounds.Left - 1), BorderDarkColor, ClipRect);
          ScreenRenderBuffer.DrawVerticalLine16Clipped(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1, -(HitTestBounds.Bottom - HitTestBounds.Top - 1), BorderDarkColor, ClipRect);
        end;
        UpdateEmbeddedControls(Font);
        RemoveUnusedEmbeddedControls(Font);
      end;
    finally
      if Font <> nil then FontCache.Release;
    end;
  end;
  inherited Draw(ClipRect);
end;
{ @end $48A8D0 }

{ @routine $48C140 TLabelGI_QueueImageLoad }
procedure TLabelGI.QueueImageLoad(PendingLoads: TList);
begin
  FontCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $48C140 }

{ @routine $48C164 MeasureLabelTextBounds }
function MeasureLabelTextBounds(const Text, FontName: WideString): TRect;
var
  Control: TCFontControlEC;
  Font: TCFontEC;
begin
  Control := nil;
  Font := nil;
  try
    Control := TCFontControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(FontName);
    Font := AcquireCachedFont(Control);
    Font.ResetTextMeasureState;
    Font.UseARGBColors := True;
    Font.ColorTagsEnabled := False;
    Result := Font.MeasureTaggedTextBounds(Text, 0, 0, nil);
  finally
    if Font <> nil then Control.Release;
    if Control <> nil then Control.Free;
  end;
  Inc(Result.Bottom, 2);
  Inc(Result.Right, 4);
end;
{ @end $48C164 }

{ @routine $48C230 MeasureWrappedLabelBounds }
function MeasureWrappedLabelBounds(Width: Integer; TextLines: TStringsEC; Font: TCFontEC): TRect;
var
  Lines: TStringsEC;
  FirstLine: Boolean;
  Y: Integer;
  Bounds, LineBounds: TRect;
begin
  TextLines.First;
  Bounds.Left := 0;
  Bounds.Right := 0;
  Bounds.Top := 0;
  Bounds.Bottom := 0;
  Y := 0;
  Lines := TStringsEC.Create;
  FirstLine := True;
  while not TextLines.IsAtEnd do
  begin
    Font.ResetTextMeasureState;
    Font.WrapTaggedTextIntoLines(Lines, TextLines.GetCurrentText, Width - 4);
    if not Lines.IsEmpty then
    begin
      Lines.First;
      if FirstLine then
      begin
        Font.ResetTextMeasureState;
        Bounds := Font.MeasureTaggedTextBounds(Lines.GetCurrentText, 0, Y, nil);
        FirstLine := False;
        Inc(Y, Font.GetLineHeight);
        Lines.Next;
      end;
      while not Lines.IsAtEnd do
      begin
        Font.ResetTextMeasureState;
        LineBounds := Font.MeasureTaggedTextBounds(Lines.GetCurrentText, 0, Y, nil);
        UnionRect(Bounds, Bounds, LineBounds);
        Inc(Y, Font.GetLineHeight);
        Lines.Next;
      end;
    end;
    TextLines.Next;
  end;
  Lines.Free;
  Inc(Bounds.Bottom, 2);
  Inc(Bounds.Right, 4);
  Result := Bounds;
end;
{ @end $48C230 }

{ @routine $48C3DC DrawWrappedLabelLines }
procedure DrawWrappedLabelLines(Buffer: TGraphBufGR; Width, X, Y: Integer; TextLines: TStringsEC; Font: TCFontEC);
var
  Lines: TStringsEC;
  CurrentY: Integer;
  ClipRect: TRect;
begin
  Lines := TStringsEC.Create;
  ClipRect := Classes.Rect(0, 0, Buffer.Width, Buffer.Height);
  CurrentY := Y + 2 + Font.AboveBaseline - 2;
  TextLines.First;
  while not TextLines.IsAtEnd do
  begin
    Font.ResetTextMeasureState;
    Font.WrapTaggedTextIntoLines(Lines, TextLines.GetCurrentText, Width - 4);
    Lines.First;
    while not Lines.IsAtEnd do
    begin
      Font.ResetTextMeasureState;
      if not Lines.IsAtLast then
        Font.DrawJustifiedTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, X, CurrentY, Lines.GetCurrentText, Width - 4, ClipRect)
      else
        Font.DrawTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, X, CurrentY, Lines.GetCurrentText, ClipRect);
      Inc(CurrentY, Font.GetLineHeight);
      Lines.Next;
    end;
    TextLines.Next;
  end;
  Lines.Free;
end;
{ @end $48C3DC }

{ @routine $48C574 RenderLabelTextToBuffer }
procedure RenderLabelTextToBuffer(Buffer: TGraphBufGR; Width, BorderWidth, ShadowOffset: Integer; const Text, FontName: WideString; TextColor, BorderColor, ShadowColor: Cardinal);
var
  Control: TCFontControlEC;
  Font: TCFontEC;
  Lines: TStringsEC;
  InnerWidth, X, Y: Integer;
begin
  Control := nil;
  Font := nil;
  Lines := nil;
  try
    Lines := TStringsEC.Create;
    Lines.SetText(Text);
    Control := TCFontControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(FontName);
    Font := AcquireCachedFont(Control);
    Font.ResetTextMeasureState;
    Font.UseARGBColors := True;
    Font.ColorTagsEnabled := False;
    InnerWidth := Width - BorderWidth - Max(BorderWidth, ShadowOffset);
    with MeasureWrappedLabelBounds(InnerWidth, Lines, Font) do
    begin
      Dec(Left, BorderWidth);
      Dec(Top, BorderWidth);
      Inc(Right, Max(BorderWidth, ShadowOffset));
      Bottom := Bottom + Max(BorderWidth, ShadowOffset) + 4;
      Buffer.AllocateRgbaTight(InnerWidth, Bottom - Top);
    end;
    Buffer.ClearPixels;
    X := BorderWidth;
    Y := BorderWidth;
    if ShadowOffset <> 0 then
    begin
      Font.DefaultColor := ShadowColor;
      DrawWrappedLabelLines(Buffer, InnerWidth, X + ShadowOffset, Y + ShadowOffset, Lines, Font);
    end;
    if BorderWidth > 0 then
    begin
      Font.DefaultColor := BorderColor;
      DrawWrappedLabelLines(Buffer, InnerWidth, X - BorderWidth, Y - BorderWidth, Lines, Font);
      DrawWrappedLabelLines(Buffer, InnerWidth, X + BorderWidth, Y - BorderWidth, Lines, Font);
      DrawWrappedLabelLines(Buffer, InnerWidth, X - BorderWidth, Y + BorderWidth, Lines, Font);
      DrawWrappedLabelLines(Buffer, InnerWidth, X + BorderWidth, Y + BorderWidth, Lines, Font);
    end;
    Font.ColorTagsEnabled := True;
    Font.DefaultColor := TextColor;
    DrawWrappedLabelLines(Buffer, InnerWidth, X, Y, Lines, Font);
  finally
    if Font <> nil then Control.Release;
    if Control <> nil then Control.Free;
    if Lines <> nil then Lines.Free;
  end;
end;
{ @end $48C574 }

end.
