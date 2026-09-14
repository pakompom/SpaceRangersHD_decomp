unit GI_Label;
// Unit bracket (inferred): .text 0x0048FBB4..0x00493A6B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create(Owner: TObjectGI); // @addr 0x48FCD4 @ida "TLabelGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x48FE08 @ida "void __usercall $name(TLabelGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x48FE90
    procedure SetFontName(const FontName: WideString); // @addr 0x48FF80
    procedure SetTextBorderWidth(Value: Integer); // @addr 0x48FFD4
    procedure SetTextBorderColor(Value: Cardinal); // @addr 0x490024
    procedure SetShadowOffset(Value: Integer); // @addr 0x490074
    procedure SetShadowColor(Value: Cardinal); // @addr 0x4900CC
    procedure SetText(const Text: WideString); // @addr 0x490104
    procedure LoadTextLinesFromBlockParam(Block: TBlockParEC; const ParamName: WideString); // @addr 0x4901B4
    function GetText: WideString; // @addr 0x4903A8 @ida "void __usercall $name(TLabelGI *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure SetTextAlignX(Value: TTextAlignXGI); // @addr 0x4903CC
    procedure SetTextAlignY(Value: TTextAlignYGI); // @addr 0x49042C
    procedure SetWordWrapEnabled(Value: Boolean); // @addr 0x49048C
    procedure SetAutoHeightPadding(Value: Integer); // @addr 0x4904EC
    procedure SetEmbeddedImagePath(const ImagePath: WideString); // @addr 0x49054C @note "An empty path frees the embedded child."
    procedure SetEmbeddedImageKindX(Value: TImageKindXGI); // @addr 0x49060C
    procedure SetEmbeddedImageKindY(Value: TImageKindYGI); // @addr 0x49063C
    procedure SetEmbeddedImageHalfAlpha(Value: Boolean); // @addr 0x49066C
    procedure SetTextColor(Value: Cardinal); // @addr 0x49069C
    procedure SetBorderLightColor(Value: Cardinal); // @addr 0x4906F0
    procedure SetBorderDarkColor(Value: Cardinal); // @addr 0x490728
    function MeasureContentSize(TopAdjustment: PInteger): TPoint; // @addr 0x490760 @ida "void __usercall $name(TLabelGI *Self@<eax>, PInteger TopAdjustment@<edx>, TPoint *Result@<ecx>);" @note "TopAdjustment is optional; includes text outline/shadow padding."
    function GetLineHeight: Integer; // @addr 0x490ADC
    function GetRenderedLineCount: Integer; // @addr 0x490B44 @note "Includes word wrapping when enabled."
    procedure UpdateHitTestBounds; override; // @addr 0x490C80 @note "May resize the control to fit its text."
    procedure SetSize(Size: TPoint); override; // @addr 0x490E58 @ida "void __usercall $name(TLabelGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure UpdateEmbeddedControls(Font: TCFontEC); // @addr 0x490E98 @note "Missing embedded controls are requested through the creation callback."
    procedure RemoveUnusedEmbeddedControls(Font: TCFontEC); // @addr 0x491000
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x49118C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4915A0
    procedure Draw(ClipRect: TRect); override; // @addr 0x491B64 @ida "void __usercall $name(TLabelGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure OnMouseEnter; override; // @addr $491084
    procedure OnMouseLeave; override; // @addr $4910E4
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $491134 @ida "void __usercall $name(TLabelGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $491160 @ida "void __usercall $name(TLabelGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x4933D4
  end;

function MeasureLabelTextBounds(const Text, FontName: WideString): TRect; // @addr $4933F8 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, unsigned __int16 *FontName@<edx>, TRect *Result@<ecx>);" Includes the native right/bottom padding.
function MeasureWrappedLabelBounds(Width: Integer; TextLines: TStringsEC; Font: TCFontEC): TRect; // @addr $4934C4 @ida "void __userpurge $name(int Width@<eax>, TStringsEC *TextLines@<edx>, TCFontEC *Font@<ecx>, TRect *Result@<^0>);"
procedure DrawWrappedLabelLines(Buffer: TGraphBufGR; Width, X, Y: Integer; TextLines: TStringsEC; Font: TCFontEC); // @addr $493670
procedure RenderLabelTextToBuffer(Buffer: TGraphBufGR; Width, BorderWidth, ShadowOffset: Integer; const Text, FontName: WideString; TextColor, BorderColor, ShadowColor: Cardinal); // @addr $493808

implementation

uses EC_Cache, GR_Main, Math, Windows, SysUtils, GlobalsV, Direct3D9;

{ @routine $48FCD4 TLabelGI_Create }
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
{ @end $48FCD4 }

{ @routine $48FE08 TLabelGI_Destroy }
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
{ @end $48FE08 }

{ @routine $48FE90 TLabelGI_Clear }
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
{ @end $48FE90 }

{ @routine $48FF80 TLabelGI_SetFontName }
procedure TLabelGI.SetFontName(const FontName: WideString);
begin
  Invalidate;
  FontCache.SetCacheKey(FontName);
  Invalidate;
  if TextTexture <> nil then TextTexture.ReleaseSurfaces;
end;
{ @end $48FF80 }

{ @routine $48FFD4 TLabelGI_SetTextBorderWidth }
procedure TLabelGI.SetTextBorderWidth(Value: Integer);
begin
  if Value <> TextBorderWidth then
  begin
    TextBorderWidth := Value;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $48FFD4 }

{ @routine $490024 TLabelGI_SetTextBorderColor }
procedure TLabelGI.SetTextBorderColor(Value: Cardinal);
begin
  if Value <> TextBorderColor then
  begin
    TextBorderColor := Value;
    Invalidate;
    if TextTexture <> nil then TextTexture.ReleaseSurfaces;
  end;
end;
{ @end $490024 }

{ @routine $490074 TLabelGI_SetShadowOffset }
procedure TLabelGI.SetShadowOffset(Value: Integer);
begin
  if Value <> TextShadowOffset then
  begin
    TextShadowOffset := Value;
    Invalidate;
    if TextTexture <> nil then TextTexture.SetSurface(nil, 1);
  end;
end;
{ @end $490074 }

{ @routine $4900CC TLabelGI_SetShadowColor }
procedure TLabelGI.SetShadowColor(Value: Cardinal);
begin
  if Value <> TextShadowColor then
  begin
    TextShadowColor := Value;
    Invalidate;
  end;
end;
{ @end $4900CC }

{ @routine $490104 TLabelGI_SetText }
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
{ @end $490104 }

{ @routine $4901B4 TLabelGI_LoadTextLinesFromBlockParam }
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
{ @end $4901B4 }

{ @routine $4903A8 TLabelGI_GetText }
function TLabelGI.GetText: WideString;
begin
  Result := TextLines.GetText;
end;
{ @end $4903A8 }

{ @routine $4903CC TLabelGI_SetTextAlignX }
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
{ @end $4903CC }

{ @routine $49042C TLabelGI_SetTextAlignY }
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
{ @end $49042C }

{ @routine $49048C TLabelGI_SetWordWrapEnabled }
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
{ @end $49048C }

{ @routine $4904EC TLabelGI_SetAutoHeightPadding }
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
{ @end $4904EC }

{ @routine $49054C TLabelGI_SetEmbeddedImagePath }
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
{ @end $49054C }

{ @routine $49060C TLabelGI_SetEmbeddedImageKindX }
procedure TLabelGI.SetEmbeddedImageKindX(Value: TImageKindXGI);
begin
  if EmbeddedImage <> nil then EmbeddedImage.SetImageKindX(Value);
end;
{ @end $49060C }

{ @routine $49063C TLabelGI_SetEmbeddedImageKindY }
procedure TLabelGI.SetEmbeddedImageKindY(Value: TImageKindYGI);
begin
  if EmbeddedImage <> nil then EmbeddedImage.SetImageKindY(Value);
end;
{ @end $49063C }

{ @routine $49066C TLabelGI_SetEmbeddedImageHalfAlpha }
procedure TLabelGI.SetEmbeddedImageHalfAlpha(Value: Boolean);
begin
  if EmbeddedImage <> nil then EmbeddedImage.SetHalfAlpha(Value);
end;
{ @end $49066C }

{ @routine $49069C TLabelGI_SetTextColor }
procedure TLabelGI.SetTextColor(Value: Cardinal);
begin
  if TextColor <> Value then
  begin
    TextColor := Value;
    Invalidate;
    if TextTexture <> nil then TextTexture.SetSurface(nil, 0);
  end;
end;
{ @end $49069C }

{ @routine $4906F0 TLabelGI_SetBorderLightColor }
procedure TLabelGI.SetBorderLightColor(Value: Cardinal);
begin
  if BorderLightColor <> Value then
  begin
    BorderLightColor := Value;
    Invalidate;
  end;
end;
{ @end $4906F0 }

{ @routine $490728 TLabelGI_SetBorderDarkColor }
procedure TLabelGI.SetBorderDarkColor(Value: Cardinal);
begin
  if BorderDarkColor <> Value then
  begin
    BorderDarkColor := Value;
    Invalidate;
  end;
end;
{ @end $490728 }

{ @routine $490760 TLabelGI_MeasureContentSize }
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
{ @end $490760 }

{ @routine $490ADC TLabelGI_GetLineHeight }
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
{ @end $490ADC }

{ @routine $490B44 TLabelGI_GetRenderedLineCount }
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
{ @end $490B44 }

{ @routine $490C80 TLabelGI_UpdateHitTestBounds }
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
{ @end $490C80 }

{ @routine $490E58 TLabelGI_SetSize }
procedure TLabelGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if EmbeddedImage <> nil then EmbeddedImage.SetSize(Size);
end;
{ @end $490E58 }

{ @routine $490E98 TLabelGI_UpdateEmbeddedControls }
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
{ @end $490E98 }

{ @routine $491000 TLabelGI_RemoveUnusedEmbeddedControls }
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
{ @end $491000 }

{ @routine $491084 TLabelGI_OnMouseEnter }
procedure TLabelGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  if (HelpText <> '') and (MessageLoop.HoveredControl <> Self) then
  begin
    MessageLoop.SetHoveredControl(Self);
    if Assigned(HelpCallback) then HelpCallback(Self, True);
  end;
end;
{ @end $491084 }

{ @routine $4910E4 TLabelGI_OnMouseLeave }
procedure TLabelGI.OnMouseLeave;
begin
  if MessageLoop.HoveredControl = Self then
  begin
    MessageLoop.SetHoveredControl(nil);
    if Assigned(HelpCallback) then HelpCallback(Self, False);
  end;
  inherited OnMouseLeave;
end;
{ @end $4910E4 }

{ @routine $491134 TLabelGI_ProcessLeftButtonDown }
procedure TLabelGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
end;
{ @end $491134 }

{ @routine $491160 TLabelGI_ProcessLeftButtonUp }
procedure TLabelGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
end;
{ @end $491160 }

{ @routine $49118C TLabelGI_LoadFromConfigPath }
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
{ @end $49118C }

{ @routine $4915A0 TLabelGI_LoadFromBlock }
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
{ @end $4915A0 }

{ @routine $491B64 TLabelGI_Draw }
procedure TLabelGI.Draw(ClipRect: TRect);
var Font: TCFontEC; Y: Integer; Lines: TStringsEC; Color: Cardinal; Texture: IDirect3DTexture9; Bounds: TRect;

  // @nested $491AF0 SwitchLabelDrawFont
  procedure SwitchLabelDrawFont(FontName: WideString); // @addr 0x491AF0 @ida "void __usercall $name(unsigned __int16 *FontName@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x491BD7,0x491C05,0x491C33,0x491C65,0x491C93,0x491CBE,0x491CE9,0x491D14" @note "Nested Draw helper; caller removes the parent-frame argument."
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
{ @end $491B64 }

{ @routine $4933D4 TLabelGI_QueueImageLoad }
procedure TLabelGI.QueueImageLoad(PendingLoads: TList);
begin
  FontCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4933D4 }

{ @routine $4933F8 MeasureLabelTextBounds }
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
{ @end $4933F8 }

{ @routine $4934C4 MeasureWrappedLabelBounds }
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
{ @end $4934C4 }

{ @routine $493670 DrawWrappedLabelLines }
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
{ @end $493670 }

{ @routine $493808 RenderLabelTextToBuffer }
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
{ @end $493808 }

end.
