unit EC_CacheFont;
// Unit bracket (inferred): .text 0x0048AD20..0x0048FB3B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, Direct3D9, EC_Buf, EC_Cache, EC_Str, Types;

type
  TAftHeaderEC = packed record // @size 0x20
    Magic: array[0..3] of AnsiChar; // @offset 0x00
    Version: Integer; // @offset 0x04
    GlyphCount: Integer; // @offset 0x08
    CenteringHeight: Integer; // @offset 0x0C
    LineHeight: Integer; // @offset 0x14
    // Remaining header metrics have not been identified.
  end;
  PAftHeaderEC = ^TAftHeaderEC;
  TAftGlyphPlaneEC = packed record // @size 0x18
    Left: Integer; // @offset 0x00
    Top: Integer; // @offset 0x04
    Width: Integer; // @offset 0x08
    Height: Integer; // @offset 0x0C
    DataOffset: Integer; // @offset 0x10
    DataSize: Integer; // @offset 0x14  Encoded buffer size including its 16-byte header.
  end;
  TAftGlyphEC = packed record // @size 0x40
    CharCode: Cardinal; // @offset 0x00
    AdvanceA: Integer; // @offset 0x04
    AdvanceB: Integer; // @offset 0x08
    AdvanceC: Integer; // @offset 0x0C
    OpaqueMaskPlane: TAftGlyphPlaneEC; // @offset 0x10
    AlphaMaskPlane: TAftGlyphPlaneEC; // @offset 0x28
  end;
  PAftGlyphEC = ^TAftGlyphEC;
  TFontObjectEC = packed record // @size 0x18
    ObjectId: Integer; // @offset 0x00
    Width: Integer; // @offset 0x04
    Height: Integer; // @offset 0x08
    VerticalMode: Integer; // @offset 0x0C
    X: Integer; // @offset 0x10
    Y: Integer; // @offset 0x14
    // VerticalMode zero centers the object within the measured text bounds.
  end;
  PFontObjectEC = ^TFontObjectEC;
  TFontGlyphLookupEC = array[0..65535] of Word;
  PFontGlyphLookupEC = ^TFontGlyphLookupEC;

  TCFontControlEC = class;
  TCFontEC = class;

  TCFontControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x48AE2C
    function CreateData: TCacheDataEC; override; // @addr 0x48AEB0
    function AcquireData: TCacheDataEC; override; // @addr 0x48AF14
  end;

  TCFontEC = class(TCacheDataEC) // @size 0x5C
  public
    FontData: PAftHeaderEC; // @offset 0x20
    GlyphCount: Integer; // @offset 0x24
    Glyphs: PAftGlyphEC; // @offset 0x28
    AboveBaseline: Integer; // @offset 0x2C
    BelowBaseline: Integer; // @offset 0x30
    MaxGlyphAdvance: Integer; // @offset 0x34
    GlyphLookup: PFontGlyphLookupEC; // @offset 0x38
    DefaultColor: Cardinal; // @offset 0x3C
    UseARGBColors: Boolean; // @offset 0x40
    ColorTagsEnabled: Boolean; // @offset 0x41
    ObjectCount: Integer; // @offset 0x44
    ObjectCapacity: Integer; // @offset 0x48
    Objects: array of TFontObjectEC; // @offset 0x4C
    ColorStackCount: Integer; // @offset 0x50
    ColorStack: PCardinal; // @offset 0x54
    FixedWidthDepth: Integer; // @offset 0x58
    // ColorStack is a separately allocated buffer.

    constructor Create; // @addr 0x48AF30 @ida "TCFontEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x48AF78 @ida "void __usercall $name(TCFontEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure ClearLoadedFontData; // @addr 0x48AFB4
    function GetCenteringHeight: Integer; // @addr 0x48B030
    function GetLineHeight: Integer; // @addr 0x48B04C @note "Includes two extra pixels beyond the stored line height."
    procedure ResetTextMeasureState; // @addr 0x48B06C @note "Preserves allocated storage."
    function GetEmbeddedObject(Index: Integer): PFontObjectEC; // @addr 0x48B088
    function MeasureTaggedTextBounds(const Text: WideString; X, Y: Integer; TopAdjustment: PInteger): TRect; // @addr 0x48B0B0 @ida "void __userpurge $name(TCFontEC *Self@<eax>, unsigned __int16 *Text@<edx>, int X@<ecx>, int Y@<^8>, int *TopAdjustment@<^4>, TRect *Result@<^0>);" @note "Restores ObjectCount; FixedWidthDepth remains affected by the processed tags."
    // The native implementation is handwritten assembly.
    function GetGlyphAdvance(CharCode: WideChar): Integer; cdecl; // @addr 0x48B95C @ida "int __cdecl $name(TCFontEC *Self, unsigned __int16 CharCode);" @note "Returns zero for an absent character."
    function HasGlyph(CharCode: WideChar): Boolean; // @addr 0x48B990
    procedure WrapTaggedTextIntoLines(Lines: TStringsEC; const Text: WideString; MaxWidth: Integer); // @addr 0x48B9C8 @note "Replaces Lines, preserves tags in its output, and restores ObjectCount."
    procedure DrawTaggedText16(Destination: Pointer; PitchBytes, X, Y: Integer; const Text: WideString; ClipRect: TRect); // @addr 0x48BF80 @ida "void __userpurge $name(TCFontEC *Self@<eax>, void *Destination@<edx>, int PitchBytes@<ecx>, int X@<^12>, int Y@<^8>, unsigned __int16 *Text@<^4>, TRect *ClipRect@<^0>);"
    procedure DrawTaggedText32(Destination: Pointer; PitchBytes, X, Y: Integer; const Text: WideString; ClipRect: TRect); // @addr 0x48C524 @ida "void __userpurge $name(TCFontEC *Self@<eax>, void *Destination@<edx>, int PitchBytes@<ecx>, int X@<^12>, int Y@<^8>, unsigned __int16 *Text@<^4>, TRect *ClipRect@<^0>);"
    procedure DrawJustifiedTaggedText16(Destination: Pointer; PitchBytes, X, Y: Integer; const Text: WideString; Width: Integer; ClipRect: TRect); // @addr 0x48CAC8 @ida "void __userpurge $name(TCFontEC *Self@<eax>, void *Destination@<edx>, int PitchBytes@<ecx>, int X@<^16>, int Y@<^12>, unsigned __int16 *Text@<^8>, int Width@<^4>, TRect *ClipRect@<^0>);"
    procedure DrawJustifiedTaggedText32(Destination: Pointer; PitchBytes, X, Y: Integer; const Text: WideString; Width: Integer; ClipRect: TRect); // @addr 0x48D368 @ida "void __userpurge $name(TCFontEC *Self@<eax>, void *Destination@<edx>, int PitchBytes@<ecx>, int X@<^16>, int Y@<^12>, unsigned __int16 *Text@<^8>, int Width@<^4>, TRect *ClipRect@<^0>);"
    function GetTaggedTextTokenLength(Text: PWideChar; CharCount: Integer): Integer; // @addr 0x48DC30 @note "Returns zero for incomplete tokens or a doubled opening bracket."
    function ParseTabTagAndAdjustX(Text: PWideChar; CharCount: Integer; var X: Integer): Integer; // @addr 0x48DCA4 @note "For td=n, raises X to at least n and returns the token length."
    function ParseAlignTagAndAdjustX(Text: PWideChar; CharCount: Integer; var X: Integer): Integer; // @addr 0x48DDA4 @note "Handles align=right/center and restores ObjectCount. Uppercase value checks use incorrect source positions in the native code."
    function MatchAlignEndTag(Text: PWideChar; CharCount: Integer): Integer; // @addr 0x48E13C
    function MatchFixTag(Text: PWideChar; CharCount: Integer): Integer; // @addr 0x48E1EC
    function MatchFixEndTag(Text: PWideChar; CharCount: Integer): Integer; // @addr 0x48E264
    function ParseFormatTag(Text: PWideChar; CharCount: Integer; out FieldWidth, Alignment: Integer): Integer; // @addr 0x48E2E8 @note "Returns the token length; Alignment is -1 for left, 0 for center, 1 for right. FieldWidth counts characters."
    function MatchFormatEndTag(Text: PWideChar; CharCount: Integer): Integer; // @addr 0x48E670
    function CountVisibleTaggedCharsUntilFormatEnd(Text: PWideChar; CharCount: Integer): Integer; // @addr 0x48E73C @note "Only characters present in GlyphLookup count."
    function ParseObjectTagCached(Text: PWideChar; CharCount: Integer; out ObjectIndex: Integer): Integer; // @addr 0x48E800 @note "Native capacity check is reversed: it reallocates when ObjectCount <= ObjectCapacity."
    function ParseObjectTag(Text: PWideChar; CharCount: Integer; out Item: TFontObjectEC): Integer; // @addr 0x48E89C @note "Parses object=id,width,height,verticalMode; leaves X and Y unchanged."
    function ParseColorTag(Text: PWideChar; CharCount: Integer; out Color: Cardinal): Integer; // @addr 0x48EB44 @note "Parses color=r,g,b; emits ARGB or the current packed pixel format according to UseARGBColors."
    function MatchColorEndTag(Text: PWideChar; CharCount: Integer): Integer; // @addr 0x48ED90
    procedure ApplyColorTag(Text: PWideChar; CharCount: Integer); // @addr 0x48EE40 @note "Pushes or pops a color only while ColorTagsEnabled is true."
    procedure ClearColorStack; // @addr 0x48EEA4
    procedure PushColor(Color: Cardinal); // @addr 0x48EED4
    function PopColor: Cardinal; // @addr 0x48EF2C @note "Returns zero when empty."
    function GetCurrentColor: Cardinal; // @addr 0x48EF78 @note "Returns DefaultColor when tags are disabled or the stack is empty."
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x48EFCC @note "Requires aft version 1 and at least 0x20 bytes; glyph offsets and counts are trusted. Ignores LoadOption; ResidentBytes remains zero."
    procedure RenderTaggedTextToTexture(const Text: WideString; Width, Height, AlignX, AlignY: Integer; WordWrap: Boolean; ActualSize: PPoint; var Texture: IDirect3DTexture9); // @addr 0x48F58C @note "Zero dimensions use measured text size. ActualSize may be nil. Enables UseARGBColors on the shared font."
  end;

function AcquireCachedFont(Control: TCacheControlEC): TCFontEC; // @addr 0x48AED0 @note "Also clears the shared font's color stack, disables ARGB colors and enables color tags."

// Nested helper of RenderTaggedTextToTexture; ParentFrame is compiler supplied.

implementation

uses EC_Mem, GR_DX, GR_Main, Math, SysUtils, Windows;

type
  TFontTextCharsEC = array[0..MaxInt div SizeOf(WideChar) - 1] of WideChar;
  PFontTextCharsEC = ^TFontTextCharsEC;

// The + 0 expressions below, including those in Self casts, preserve DCC32's
// native operand evaluation order. They emit no additional instructions.
procedure IncludeGlyphBounds(var Bounds: TRect; var X, Y: Integer; var Glyph: PAftGlyphEC); inline;
begin
  if Glyph.AlphaMaskPlane.DataOffset <> 0 then
  begin
    if (X + 0) + Glyph.AlphaMaskPlane.Left < Bounds.Left then Bounds.Left := (X + 0) + Glyph.AlphaMaskPlane.Left;
    if (Y + 0) + Glyph.AlphaMaskPlane.Top < Bounds.Top then Bounds.Top := (Y + 0) + Glyph.AlphaMaskPlane.Top;
    if (X + 0) + Glyph.AlphaMaskPlane.Left + Glyph.AlphaMaskPlane.Width > Bounds.Right then Bounds.Right := (X + 0) + Glyph.AlphaMaskPlane.Left + Glyph.AlphaMaskPlane.Width;
    if (Y + 0) + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height > Bounds.Bottom then Bounds.Bottom := (Y + 0) + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height;
  end;
  if Glyph.OpaqueMaskPlane.DataOffset <> 0 then
  begin
    if (X + 0) + Glyph.OpaqueMaskPlane.Left < Bounds.Left then Bounds.Left := (X + 0) + Glyph.OpaqueMaskPlane.Left;
    if (Y + 0) + Glyph.OpaqueMaskPlane.Top < Bounds.Top then Bounds.Top := (Y + 0) + Glyph.OpaqueMaskPlane.Top;
    if (X + 0) + Glyph.OpaqueMaskPlane.Left + Glyph.OpaqueMaskPlane.Width > Bounds.Right then Bounds.Right := (X + 0) + Glyph.OpaqueMaskPlane.Left + Glyph.OpaqueMaskPlane.Width;
    if (Y + 0) + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height > Bounds.Bottom then Bounds.Bottom := (Y + 0) + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height;
  end;
end;

{ @routine $48AE2C TCFontControlEC_QueueLoadIfMissing }
procedure TCFontControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCFontControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCFontEC) = nil then
  begin
    Control := TCFontControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $48AE2C }

{ @routine $48AEB0 TCFontControlEC_CreateData }
function TCFontControlEC.CreateData: TCacheDataEC;
begin
  Result := TCFontEC.Create;
end;
{ @end $48AEB0 }

{ @routine $48AED0 AcquireCachedFont }
function AcquireCachedFont(Control: TCacheControlEC): TCFontEC;
begin
  Result := Control.AcquireDataFromConfig(TCFontEC) as TCFontEC;
  Result.ClearColorStack;
  Result.UseARGBColors := False;
  Result.ColorTagsEnabled := True;
end;
{ @end $48AED0 }

{ @routine $48AF14 TCFontControlEC_AcquireData }
function TCFontControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedFont(Self);
end;
{ @end $48AF14 }

{ @routine $48AF30 TCFontEC_Create }
constructor TCFontEC.Create;
begin
  inherited Create;
  ColorTagsEnabled := True;
end;
{ @end $48AF30 }

{ @routine $48AF78 TCFontEC_Destroy }
destructor TCFontEC.Destroy;
begin
  ClearLoadedFontData;
  inherited Destroy;
end;
{ @end $48AF78 }

{ @routine $48AFB4 TCFontEC_ClearLoadedFontData }
procedure TCFontEC.ClearLoadedFontData;
begin
  ObjectCount := 0; ObjectCapacity := 0; Objects := nil;
  if FontData <> nil then begin FreeEC(FontData); FontData := nil; end;
  Glyphs := nil; GlyphCount := 0;
  if GlyphLookup <> nil then begin FreeEC(GlyphLookup); GlyphLookup := nil; end;
  ClearColorStack;
end;
{ @end $48AFB4 }

{ @routine $48B030 TCFontEC_GetCenteringHeight }
function TCFontEC.GetCenteringHeight: Integer;
begin
  Result := FontData.CenteringHeight;
end;
{ @end $48B030 }

{ @routine $48B04C TCFontEC_GetLineHeight }
function TCFontEC.GetLineHeight: Integer;
begin
  Result := FontData.LineHeight + 2;
end;
{ @end $48B04C }

{ @routine $48B06C TCFontEC_ResetTextMeasureState }
procedure TCFontEC.ResetTextMeasureState;
begin
  ObjectCount := 0; FixedWidthDepth := 0;
end;
{ @end $48B06C }

{ @routine $48B088 TCFontEC_GetEmbeddedObject }
function TCFontEC.GetEmbeddedObject(Index: Integer): PFontObjectEC;
begin
  Result := @Objects[Index];
end;
{ @end $48B088 }

{ @routine $48B0B0 TCFontEC_MeasureTaggedTextBounds }
function TCFontEC.MeasureTaggedTextBounds(const Text: WideString; X, Y: Integer; TopAdjustment: PInteger): TRect;
var
  Index, GlyphIndex, CharCount, PosX, TokenLength, MiddleY: Integer;
  Ch: WideChar;
  Glyph: PAftGlyphEC;
  ObjectIndex, SavedObjectCount, FieldWidth, Alignment: Integer;
begin
  SavedObjectCount := ObjectCount;
  CharCount := Length(Text);
  PosX := X;
  Result.Left := 999999999; Result.Right := -999999999;
  Result.Top := 999999999; Result.Bottom := -999999999;
  Index := 0;
  while Index < CharCount do
  begin
    Ch := Text[Index + 1]; Inc(Index);
    TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index - 1, CharCount - Index + 1);
    if TokenLength > 0 then
    begin
      if ParseObjectTagCached(PWideChar(Text) + Index - 1, CharCount - Index + 1, ObjectIndex) > 0 then
        Inc(PosX, Objects[ObjectIndex].Width)
      else if MatchFixTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then Inc(FixedWidthDepth)
      else if MatchFixEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
        TCFontEC(PAnsiChar(Self) + 0).FixedWidthDepth := Max(FixedWidthDepth - 1, 0)
      else if ParseFormatTag(PWideChar(Text) + Index - 1, CharCount - Index + 1, FieldWidth, Alignment) > 0 then
      begin
        Index := Index + TokenLength - 1;
        while Index < CharCount do
        begin
          Ch := Text[Index + 1]; Inc(Index);
          TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index - 1, CharCount - Index + 1);
          if TokenLength > 0 then
          begin
            if MatchFixTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then Inc(FixedWidthDepth)
            else if MatchFixEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
              TCFontEC(PAnsiChar(Self) + 0).FixedWidthDepth := Max(FixedWidthDepth - 1, 0)
            else if MatchFormatEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
            begin
              Index := Index + TokenLength - 1;
              Break;
            end;
            Index := Index + TokenLength - 1;
            Continue;
          end;
          GlyphIndex := ReadWordEC(AddPointerOffset(GlyphLookup, Ord(Ch) * 2));
          if GlyphIndex <> 0 then
          begin
            Glyph := AddPointerOffset(Glyphs, (GlyphIndex - 1) * SizeOf(TAftGlyphEC));
            IncludeGlyphBounds(Result, PosX, Y, Glyph);
            if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance
            else PosX := (PosX + 0) + Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC;
            Dec(FieldWidth);
          end;
        end;
        if FieldWidth > 0 then
        begin
          GlyphIndex := ReadWordEC(AddPointerOffset(GlyphLookup, Ord(' ') * 2));
          if GlyphIndex <> 0 then
          begin
            Glyph := AddPointerOffset(Glyphs, (GlyphIndex - 1) * SizeOf(TAftGlyphEC));
            if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * FieldWidth
            else PosX := PosX + (Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC) * FieldWidth;
          end;
        end;
        Continue;
      end;
      Index := Index + TokenLength - 1;
      Continue;
    end;
    GlyphIndex := ReadWordEC(AddPointerOffset(GlyphLookup, Ord(Ch) * 2));
    if GlyphIndex <> 0 then
    begin
      Glyph := AddPointerOffset(Glyphs, (GlyphIndex - 1) * SizeOf(TAftGlyphEC));
      IncludeGlyphBounds(Result, PosX, Y, Glyph);
      if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance
      else PosX := (PosX + 0) + Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC;
    end;
  end;
  Result.Right := Max(Result.Right, PosX);
  if TopAdjustment <> nil then TopAdjustment^ := 0;
  if ObjectCount - SavedObjectCount > 0 then
  begin
    MiddleY := (Result.Top + Result.Bottom) div 2;
    for Index := SavedObjectCount to ObjectCount - 1 do
      if Objects[Index].VerticalMode = 0 then
      begin
        if (TopAdjustment <> nil) and (MiddleY - Objects[Index].Height div 2 < Result.Top) then
          TopAdjustment^ := TopAdjustment^ + Result.Top - (MiddleY - Objects[Index].Height div 2);
        Result.Top := Min(Result.Top, MiddleY - Objects[Index].Height div 2);
        Result.Bottom := Max(Result.Bottom, MiddleY - Objects[Index].Height div 2 + Objects[Index].Height);
      end;
  end;
  TCFontEC(PAnsiChar(Self) + 0).ObjectCount := SavedObjectCount;
end;
{ @end $48B0B0 }

{ @routine $48B95C TCFontEC_GetGlyphAdvance }
function TCFontEC.GetGlyphAdvance(CharCode: WideChar): Integer; cdecl;
asm
  PUSH EBX
  MOV EBX, Self
  XOR EAX, EAX
  MOV AX, CharCode
  SHL EAX, 1
  ADD EAX, [EBX].TCFontEC.GlyphLookup
  MOV AX, [EAX]
  AND EAX, $FFFF
  TEST EAX, EAX
  JZ @@Done
  DEC EAX
  SHL EAX, 6
  ADD EAX, [EBX].TCFontEC.Glyphs
  MOV EBX, EAX
  MOV EAX, [EBX].TAftGlyphEC.AdvanceA
  ADD EAX, [EBX].TAftGlyphEC.AdvanceB
  ADD EAX, [EBX].TAftGlyphEC.AdvanceC
@@Done:
  POP EBX
end;
{ @end $48B95C }

{ @routine $48B990 TCFontEC_HasGlyph }
function TCFontEC.HasGlyph(CharCode: WideChar): Boolean;
begin
  Result := ReadWordEC(AddPointerOffset(GlyphLookup, Ord(CharCode) * 2)) > 0;
end;
{ @end $48B990 }

{ @routine $48B9C8 TCFontEC_WrapTaggedTextIntoLines }
procedure TCFontEC.WrapTaggedTextIntoLines(Lines: TStringsEC; const Text: WideString; MaxWidth: Integer);
var
  TokenLength, WordStart, Index, CharCount, WordLength, FitEnd, WordWidth,
    LineWidth, LineStart, LineLength: Integer;
  FirstLine, SeenCharacter: Boolean;
  ObjectIndex, SavedObjectCount, FieldWidth, Alignment: Integer;
  Ch: WideChar;
begin
  SavedObjectCount := ObjectCount;
  Lines.Clear;
  LineWidth := 0; WordStart := 0; LineStart := 0; LineLength := 0;
  CharCount := Length(Text);
  FirstLine := True;
  while WordStart < CharCount do
  begin
    SeenCharacter := False;
    for Index := WordStart to CharCount - 1 do
    begin
      if PFontTextCharsEC(Pointer(Text))^[Index] = ' ' then
        if SeenCharacter then Break;
      SeenCharacter := True;
    end;
    WordLength := Index - WordStart;
    WordWidth := 0; Index := WordStart; FitEnd := 0;
    while Index <= WordStart + WordLength - 1 do
    begin
      Ch := PFontTextCharsEC(Pointer(Text))^[Index]; Inc(Index);
      TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index - 1, WordLength - (Index - 1 - WordStart));
      if TokenLength > 0 then
      begin
        if ParseObjectTagCached(PWideChar(Text) + Index - 1, WordLength - (Index - 1 - WordStart), ObjectIndex) > 0 then
        begin
          Inc(WordWidth, Objects[ObjectIndex].Width);
          if WordWidth <= MaxWidth then FitEnd := Index - 1 + TokenLength - 1;
        end
        else if MatchFixTag(PWideChar(Text) + Index - 1, WordLength - (Index - 1 - WordStart)) > 0 then Inc(FixedWidthDepth)
        else if MatchFixEndTag(PWideChar(Text) + Index - 1, WordLength - (Index - 1 - WordStart)) > 0 then
          FixedWidthDepth := Max(FixedWidthDepth - 1, 0) + 0
        else if ParseFormatTag(PWideChar(Text) + Index - 1, WordLength - (Index - 1 - WordStart), FieldWidth, Alignment) > 0 then
        begin
          Index := Index + TokenLength - 1;
          while Index < CharCount do
          begin
            Ch := PFontTextCharsEC(Pointer(Text))^[Index]; Inc(Index);
            TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index - 1, CharCount - Index + 1);
            if TokenLength > 0 then
            begin
              if MatchFixTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then Inc(FixedWidthDepth)
              else if MatchFixEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
                FixedWidthDepth := Max(FixedWidthDepth - 1, 0) + 0
              else if MatchFormatEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
              begin
                Index := Index + TokenLength - 1;
                if FieldWidth > 0 then
                begin
                  if FixedWidthDepth > 0 then WordWidth := WordWidth + MaxGlyphAdvance * FieldWidth
                  else WordWidth := WordWidth + GetGlyphAdvance(' ') * FieldWidth;
                end;
                Break;
              end;
              Index := Index + TokenLength - 1;
            end
            else
            begin
              Dec(FieldWidth);
              if FixedWidthDepth > 0 then WordWidth := WordWidth + MaxGlyphAdvance
              else WordWidth := WordWidth + GetGlyphAdvance(Ch);
            end;
          end;
          WordLength := Index - WordStart;
          if WordWidth <= MaxWidth then FitEnd := Index - 1 - 1;
          Continue;
        end;
        Index := Index + TokenLength - 1;
      end
      else
      begin
        if FixedWidthDepth > 0 then WordWidth := WordWidth + MaxGlyphAdvance
        else WordWidth := WordWidth + GetGlyphAdvance(Ch);
        if WordWidth <= MaxWidth then FitEnd := Index - 1 - 1;
      end;
    end;
    if LineWidth = 0 then
    begin
      if WordWidth > MaxWidth then
      begin
        TokenLength := 0;
        if not FirstLine then
          while Text[LineStart + 1 + TokenLength] = ' ' do Inc(TokenLength);
        if LineLength - TokenLength > 0 then
          Lines.AddSlice(PWideChar(Text) + LineStart + TokenLength, LineLength - TokenLength)
        else
        begin
          Lines.AddSlice(PWideChar(Text) + LineStart + TokenLength, FitEnd + 1 - WordStart);
          WordStart := FitEnd + 1; WordLength := 0; WordWidth := 0;
        end;
        FirstLine := False;
      end;
      LineStart := WordStart; WordStart := WordStart + WordLength;
      LineWidth := WordWidth; LineLength := WordLength;
    end
    else if LineWidth + WordWidth <= MaxWidth then
    begin
      WordStart := WordStart + WordLength;
      LineWidth := LineWidth + WordWidth; LineLength := LineLength + WordLength;
    end
    else
    begin
      TokenLength := 0;
      if not FirstLine then
        while Text[LineStart + 1 + TokenLength] = ' ' do Inc(TokenLength);
      Lines.AddSlice(PWideChar(Text) + LineStart + TokenLength, LineLength - TokenLength);
      FirstLine := False;
      LineStart := WordStart; WordStart := WordStart + WordLength;
      LineWidth := WordWidth; LineLength := WordLength;
    end;
  end;
  TokenLength := 0; LineLength := CharCount - LineStart;
  if not FirstLine then
    while Text[LineStart + 1 + TokenLength] = ' ' do Inc(TokenLength);
  if LineLength - TokenLength > 0 then
    Lines.AddSlice(PWideChar(Text) + LineStart + TokenLength, LineLength - TokenLength);
  ObjectCount := SavedObjectCount + 0;
end;
{ @end $48B9C8 }

{ @routine $48BF80 TCFontEC_DrawTaggedText16 }
procedure TCFontEC.DrawTaggedText16(Destination: Pointer; PitchBytes, X, Y: Integer; const Text: WideString; ClipRect: TRect);
var
  Index, GlyphIndex, CharCount, TokenLength, PosX: Integer;
  Ch: WideChar;
  Glyph: PAftGlyphEC;
  ObjectIndex, SavedObjectCount, Top, Bottom, MiddleY, FieldWidth, Alignment: Integer;
  Clip: TRect;
begin
  Top := 999999999; Bottom := -999999999;
  SavedObjectCount := ObjectCount;
  Clip.Left := ClipRect.Left; Clip.Top := ClipRect.Top;
  Clip.Right := ClipRect.Right - 1; Clip.Bottom := ClipRect.Bottom - 1;
  CharCount := Length(Text);
  if CharCount < 1 then Exit;
  Index := 0; PosX := 0; FieldWidth := -1;
  while Index < CharCount do
  begin
    Ch := Text[Index + 1]; Inc(Index);
    TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index - 1, CharCount - Index + 1);
    if TokenLength > 0 then
    begin
      ApplyColorTag(PWideChar(Text) + Index - 1, CharCount - Index + 1);
      ParseTabTagAndAdjustX(PWideChar(Text) + Index - 1, CharCount - Index + 1, PosX);
      ParseAlignTagAndAdjustX(PWideChar(Text) + Index - 1, CharCount - Index + 1, PosX);
      if ParseObjectTagCached(PWideChar(Text) + Index - 1, CharCount - Index + 1, ObjectIndex) > 0 then
      begin
        Objects[ObjectIndex].X := X + PosX;
        Inc(PosX, Objects[ObjectIndex].Width);
      end
      else if MatchFixTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then Inc(FixedWidthDepth)
      else if MatchFixEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
        TCFontEC(PAnsiChar(Self) + 0).FixedWidthDepth := Max(FixedWidthDepth - 1, 0)
      else if (FieldWidth < 0) and
        (ParseFormatTag(PWideChar(Text) + Index - 1, CharCount - Index + 1, FieldWidth, Alignment) > 0) then
      begin
        Index := Index + TokenLength - 1;
        Dec(FieldWidth, CountVisibleTaggedCharsUntilFormatEnd(PWideChar(Text) + Index, CharCount - Index));
        if FieldWidth > 0 then
        begin
        if Alignment = 0 then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + (MaxGlyphAdvance + 0) * (FieldWidth shr 1)
          else PosX := PosX + GetGlyphAdvance(' ') * (FieldWidth shr 1);
          FieldWidth := FieldWidth - (FieldWidth shr 1);
        end
        else if Alignment > 0 then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * FieldWidth
          else PosX := PosX + GetGlyphAdvance(' ') * FieldWidth;
          FieldWidth := -1;
        end;
        end
        else FieldWidth := -1;
        Continue;
      end
      else if MatchFormatEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
      begin
        if FieldWidth > 0 then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * FieldWidth
          else PosX := PosX + GetGlyphAdvance(' ') * FieldWidth;
          FieldWidth := -1;
        end;
      end;
      Index := Index + TokenLength - 1;
    end
    else
    begin
      GlyphIndex := ReadWordEC(AddPointerOffset(GlyphLookup, Ord(Ch) * 2));
      if GlyphIndex <> 0 then
      begin
        Glyph := AddPointerOffset(Glyphs, (GlyphIndex - 1) * SizeOf(TAftGlyphEC));
        if Glyph.OpaqueMaskPlane.DataOffset <> 0 then
        begin
          if (Y + 0) + Glyph.OpaqueMaskPlane.Top < Top then Top := (Y + 0) + Glyph.OpaqueMaskPlane.Top;
          if (Y + 0) + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height > Bottom then
            Bottom := (Y + 0) + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height;
          Ex_OKGR_MaskBuf_DrawClip_WORD(Destination, PitchBytes, X + PosX + Glyph.OpaqueMaskPlane.Left,
            (Y + 0) + Glyph.OpaqueMaskPlane.Top, AddPointerOffset(FontData, Glyph.OpaqueMaskPlane.DataOffset), GetCurrentColor, Clip);
        end;
        if Glyph.AlphaMaskPlane.DataOffset <> 0 then
        begin
          if (Y + 0) + Glyph.AlphaMaskPlane.Top < Top then Top := (Y + 0) + Glyph.AlphaMaskPlane.Top;
          if (Y + 0) + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height > Bottom then
            Bottom := (Y + 0) + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height;
          Ex_OKGR_TransBuf_FillAlphaClip_16(Destination, PitchBytes, X + PosX + Glyph.AlphaMaskPlane.Left,
            (Y + 0) + Glyph.AlphaMaskPlane.Top, AddPointerOffset(FontData, Glyph.AlphaMaskPlane.DataOffset), Clip, GetCurrentColor);
        end;
        if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance
        else PosX := (PosX + 0) + Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC;
      end;
    end;
  end;
  if ObjectCount - SavedObjectCount > 0 then
  begin
    MiddleY := (Top + Bottom) div 2;
    for Index := SavedObjectCount to ObjectCount - 1 do
      if Objects[Index].VerticalMode = 0 then
        Objects[Index].Y := MiddleY - Objects[Index].Height div 2;
  end;
end;
{ @end $48BF80 }

{ @routine $48C524 TCFontEC_DrawTaggedText32 }
procedure TCFontEC.DrawTaggedText32(Destination: Pointer; PitchBytes, X, Y: Integer; const Text: WideString; ClipRect: TRect);
var
  Index, GlyphIndex, CharCount, TokenLength, PosX: Integer;
  Ch: WideChar;
  Glyph: PAftGlyphEC;
  ObjectIndex, SavedObjectCount, Top, Bottom, MiddleY, FieldWidth, Alignment: Integer;
  Clip: TRect;
begin
  Top := 999999999; Bottom := -999999999;
  SavedObjectCount := ObjectCount;
  Clip.Left := ClipRect.Left; Clip.Top := ClipRect.Top;
  Clip.Right := ClipRect.Right - 1; Clip.Bottom := ClipRect.Bottom - 1;
  CharCount := Length(Text);
  if CharCount < 1 then Exit;
  Index := 0; PosX := 0; FieldWidth := -1;
  while Index < CharCount do
  begin
    Ch := Text[Index + 1]; Inc(Index);
    TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index - 1, CharCount - Index + 1);
    if TokenLength > 0 then
    begin
      ApplyColorTag(PWideChar(Text) + Index - 1, CharCount - Index + 1);
      ParseTabTagAndAdjustX(PWideChar(Text) + Index - 1, CharCount - Index + 1, PosX);
      ParseAlignTagAndAdjustX(PWideChar(Text) + Index - 1, CharCount - Index + 1, PosX);
      if ParseObjectTagCached(PWideChar(Text) + Index - 1, CharCount - Index + 1, ObjectIndex) > 0 then
      begin
        Objects[ObjectIndex].X := X + PosX;
        Inc(PosX, Objects[ObjectIndex].Width);
      end
      else if MatchFixTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then Inc(FixedWidthDepth)
      else if MatchFixEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
        TCFontEC(PAnsiChar(Self) + 0).FixedWidthDepth := Max(FixedWidthDepth - 1, 0)
      else if (FieldWidth < 0) and
        (ParseFormatTag(PWideChar(Text) + Index - 1, CharCount - Index + 1, FieldWidth, Alignment) > 0) then
      begin
        Index := Index + TokenLength - 1;
        Dec(FieldWidth, CountVisibleTaggedCharsUntilFormatEnd(PWideChar(Text) + Index, CharCount - Index));
        if FieldWidth > 0 then
        begin
        if Alignment = 0 then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + (MaxGlyphAdvance + 0) * (FieldWidth shr 1)
          else PosX := PosX + GetGlyphAdvance(' ') * (FieldWidth shr 1);
          FieldWidth := FieldWidth - (FieldWidth shr 1);
        end
        else if Alignment > 0 then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * FieldWidth
          else PosX := PosX + GetGlyphAdvance(' ') * FieldWidth;
          FieldWidth := -1;
        end;
        end
        else FieldWidth := -1;
        Continue;
      end
      else if MatchFormatEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
      begin
        if FieldWidth > 0 then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * FieldWidth
          else PosX := PosX + GetGlyphAdvance(' ') * FieldWidth;
          FieldWidth := -1;
        end;
      end;
      Index := Index + TokenLength - 1;
    end
    else
    begin
      GlyphIndex := ReadWordEC(AddPointerOffset(GlyphLookup, Ord(Ch) * 2));
      if GlyphIndex <> 0 then
      begin
        Glyph := AddPointerOffset(Glyphs, (GlyphIndex - 1) * SizeOf(TAftGlyphEC));
        if Glyph.OpaqueMaskPlane.DataOffset <> 0 then
        begin
          if (Y + 0) + Glyph.OpaqueMaskPlane.Top < Top then Top := (Y + 0) + Glyph.OpaqueMaskPlane.Top;
          if (Y + 0) + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height > Bottom then
            Bottom := (Y + 0) + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height;
          Ex_OKGR_MaskBuf_DrawClip_DWORD(Destination, PitchBytes, X + PosX + Glyph.OpaqueMaskPlane.Left,
            (Y + 0) + Glyph.OpaqueMaskPlane.Top, AddPointerOffset(FontData, Glyph.OpaqueMaskPlane.DataOffset), GetCurrentColor, Clip);
        end;
        if Glyph.AlphaMaskPlane.DataOffset <> 0 then
        begin
          if (Y + 0) + Glyph.AlphaMaskPlane.Top < Top then Top := (Y + 0) + Glyph.AlphaMaskPlane.Top;
          if (Y + 0) + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height > Bottom then
            Bottom := (Y + 0) + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height;
          Ex_OKGR_TransBuf_FillAlphaClip_RGBA(Destination, PitchBytes, X + PosX + Glyph.AlphaMaskPlane.Left,
            (Y + 0) + Glyph.AlphaMaskPlane.Top, AddPointerOffset(FontData, Glyph.AlphaMaskPlane.DataOffset), Clip, GetCurrentColor);
        end;
        if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance
        else PosX := (PosX + 0) + Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC;
      end;
    end;
  end;
  if ObjectCount - SavedObjectCount > 0 then
  begin
    MiddleY := (Top + Bottom) div 2;
    for Index := SavedObjectCount to ObjectCount - 1 do
      if Objects[Index].VerticalMode = 0 then
        Objects[Index].Y := MiddleY - Objects[Index].Height div 2;
  end;
end;
{ @end $48C524 }

{ @routine $48CAC8 TCFontEC_DrawJustifiedTaggedText16 }
procedure TCFontEC.DrawJustifiedTaggedText16(Destination: Pointer; PitchBytes, X, Y: Integer; const Text: WideString; Width: Integer; ClipRect: TRect);
var
  Character: WideChar;
  Lookup: PFontGlyphLookupEC;
  GlyphIndex: Integer;
  GlyphBase, Glyph: PAftGlyphEC;
  ContentWidth, CharCount, Index, SpaceCount: Integer;
  SpaceWidth, PosX: Double;
  Leading: Boolean;
  TokenLength, ObjectIndex, SavedObjectCount, Top, Bottom, MiddleY,
    FieldWidth, Alignment, ParsedWidth, ParsedAlignment: Integer;
  Clip: TRect;
begin
  Top := 999999999; Bottom := -999999999;
  SavedObjectCount := ObjectCount;
  Clip.Left := ClipRect.Left; Clip.Top := ClipRect.Top;
  Clip.Right := ClipRect.Right - 1; Clip.Bottom := ClipRect.Bottom - 1;
  CharCount := Length(Text);
  if CharCount < 1 then Exit;
  ContentWidth := 0; SpaceCount := 0; Leading := True; Index := 0;
  FieldWidth := -1; ParsedWidth := -1;
  while Index < CharCount do
  begin
    TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index, CharCount - Index);
    if TokenLength > 0 then
    begin
      if ParseObjectTagCached(PWideChar(Text) + Index, CharCount - Index, ObjectIndex) > 0 then
      begin
        Inc(ContentWidth, Objects[ObjectIndex].Width); Leading := False;
      end
      else if MatchFixTag(PWideChar(Text) + Index, CharCount - Index) > 0 then Inc(FixedWidthDepth)
      else if MatchFixEndTag(PWideChar(Text) + Index, CharCount - Index) > 0 then
        FixedWidthDepth := Max(FixedWidthDepth - 1, 0)
      else if (FieldWidth < 0) and
        (ParseFormatTag(PWideChar(Text) + Index, CharCount - Index, ParsedWidth, ParsedAlignment) > 0) then
      begin
      end
      else if MatchFormatEndTag(PWideChar(Text) + Index, CharCount - Index) > 0 then ParsedWidth := -1;
      Inc(Index, TokenLength);
    end
    else
    begin
      if (Text[Index + 1] <> ' ') or (FieldWidth > 0) or (FixedWidthDepth > 0) then
      begin
        if FixedWidthDepth > 0 then Inc(ContentWidth, MaxGlyphAdvance)
        else Inc(ContentWidth, GetGlyphAdvance(Text[Index + 1]));
        Leading := False;
      end
      else if Leading = True then Inc(ContentWidth, GetGlyphAdvance(Text[Index + 1]))
      else Inc(SpaceCount);
      Inc(Index);
    end;
  end;
  if SpaceCount < 1 then
  begin
    DrawTaggedText16(Destination, PitchBytes, X, Y, Text, ClipRect); Exit;
  end;
  SpaceWidth := (Width - ContentWidth) / SpaceCount;
  if SpaceWidth < 2.0 then
  begin
    DrawTaggedText16(Destination, PitchBytes, X, Y, Text, ClipRect); Exit;
  end;
  ObjectCount := SavedObjectCount;
  Lookup := GlyphLookup; GlyphBase := Glyphs;
  PosX := X; Leading := True; Index := 0;
  while Index < CharCount do
  begin
    Character := Text[Index + 1]; Inc(Index);
    TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index - 1, CharCount - Index + 1);
    if TokenLength > 0 then
    begin
      ApplyColorTag(PWideChar(Text) + Index - 1, CharCount - Index + 1);
      if ParseObjectTagCached(PWideChar(Text) + Index - 1, CharCount - Index + 1, ObjectIndex) > 0 then
      begin
        Objects[ObjectIndex].X := Trunc(PosX);
        PosX := PosX + Objects[ObjectIndex].Width; Leading := False;
      end
      else if MatchFixTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then Inc(FixedWidthDepth)
      else if MatchFixEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
        FixedWidthDepth := Max(FixedWidthDepth - 1, 0)
      else if (FieldWidth < 0) and
        (ParseFormatTag(PWideChar(Text) + Index - 1, CharCount - Index + 1, ParsedWidth, ParsedAlignment) > 0) then
      begin
        FieldWidth := ParsedWidth; Alignment := ParsedAlignment;
        Index := Index + TokenLength - 1;
        Dec(FieldWidth, CountVisibleTaggedCharsUntilFormatEnd(PWideChar(Text) + Index, CharCount - Index));
        if FieldWidth > 0 then
        begin
          if Alignment = 0 then
          begin
            if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * (FieldWidth shr 1)
            else PosX := PosX + GetGlyphAdvance(' ') * (FieldWidth shr 1);
            Dec(FieldWidth, FieldWidth shr 1);
          end
          else if Alignment > 0 then
          begin
            PosX := PosX + GetGlyphAdvance(' ') * FieldWidth;
            FieldWidth := -1;
          end;
        end
        else FieldWidth := -1;
        Continue;
      end
      else if MatchFormatEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
      begin
        ParsedWidth := -1;
        if FieldWidth > 0 then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * FieldWidth
          else PosX := PosX + GetGlyphAdvance(' ') * FieldWidth;
          FieldWidth := -1;
        end;
      end;
      Index := Index + TokenLength - 1;
    end
    else
    begin
      asm
        XOR EAX, EAX
        MOV AX, Character
        SHL EAX, 1
        ADD EAX, Lookup
        MOV AX, [EAX]
        AND EAX, $FFFF
        MOV GlyphIndex, EAX
      end;
      if GlyphIndex <> 0 then
      begin
        asm
          MOV EAX, GlyphIndex
          DEC EAX
          SHL EAX, 6
          ADD EAX, GlyphBase
          MOV Glyph, EAX
        end;
        if Glyph.OpaqueMaskPlane.DataOffset <> 0 then
        begin
          if Y + Glyph.OpaqueMaskPlane.Top < Top then Top := Y + Glyph.OpaqueMaskPlane.Top;
          if Y + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height > Bottom then Bottom := Y + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height;
          Ex_OKGR_MaskBuf_DrawClip_WORD(Destination, PitchBytes, Integer(Trunc(PosX)) + Glyph.OpaqueMaskPlane.Left,
            Y + Glyph.OpaqueMaskPlane.Top, AddPointerOffset(FontData, Glyph.OpaqueMaskPlane.DataOffset), GetCurrentColor, Clip);
        end;
        if Glyph.AlphaMaskPlane.DataOffset <> 0 then
        begin
          if Y + Glyph.AlphaMaskPlane.Top < Top then Top := Y + Glyph.AlphaMaskPlane.Top;
          if Y + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height > Bottom then Bottom := Y + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height;
          Ex_OKGR_TransBuf_FillAlphaClip_16(Destination, PitchBytes, Integer(Trunc(PosX)) + Glyph.AlphaMaskPlane.Left,
            Y + Glyph.AlphaMaskPlane.Top, AddPointerOffset(FontData, Glyph.AlphaMaskPlane.DataOffset), Clip, GetCurrentColor);
        end;
        if (Character <> ' ') or (FieldWidth > 0) or (FixedWidthDepth > 0) then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance
          else PosX := PosX + Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC;
          Leading := False;
        end
        else if Leading = True then PosX := PosX + Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC
        else PosX := PosX + SpaceWidth;
      end;
    end;
  end;
  if ObjectCount - SavedObjectCount > 0 then
  begin
    MiddleY := (Top + Bottom) div 2;
    for Index := SavedObjectCount to ObjectCount - 1 do
      if Objects[Index].VerticalMode = 0 then
        Objects[Index].Y := MiddleY - Objects[Index].Height div 2;
  end;
end;
{ @end $48CAC8 }

{ @routine $48D368 TCFontEC_DrawJustifiedTaggedText32 }
procedure TCFontEC.DrawJustifiedTaggedText32(Destination: Pointer; PitchBytes, X, Y: Integer; const Text: WideString; Width: Integer; ClipRect: TRect);
var
  Character: WideChar;
  Lookup: PFontGlyphLookupEC;
  GlyphIndex: Integer;
  GlyphBase, Glyph: PAftGlyphEC;
  ContentWidth, CharCount, Index, SpaceCount: Integer;
  SpaceWidth, PosX: Double;
  Leading: Boolean;
  TokenLength, ObjectIndex, SavedObjectCount, Top, Bottom, MiddleY,
    FieldWidth, Alignment, ParsedWidth, ParsedAlignment: Integer;
  Clip: TRect;
begin
  Top := 999999999; Bottom := -999999999;
  SavedObjectCount := ObjectCount;
  Clip.Left := ClipRect.Left; Clip.Top := ClipRect.Top;
  Clip.Right := ClipRect.Right - 1; Clip.Bottom := ClipRect.Bottom - 1;
  CharCount := Length(Text);
  if CharCount < 1 then Exit;
  ContentWidth := 0; SpaceCount := 0; Leading := True; Index := 0;
  FieldWidth := -1; ParsedWidth := -1;
  while Index < CharCount do
  begin
    TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index, CharCount - Index);
    if TokenLength > 0 then
    begin
      if ParseObjectTagCached(PWideChar(Text) + Index, CharCount - Index, ObjectIndex) > 0 then
      begin
        Inc(ContentWidth, Objects[ObjectIndex].Width); Leading := False;
      end
      else if MatchFixTag(PWideChar(Text) + Index, CharCount - Index) > 0 then Inc(FixedWidthDepth)
      else if MatchFixEndTag(PWideChar(Text) + Index, CharCount - Index) > 0 then
        FixedWidthDepth := Max(FixedWidthDepth - 1, 0)
      else if (FieldWidth < 0) and
        (ParseFormatTag(PWideChar(Text) + Index, CharCount - Index, ParsedWidth, ParsedAlignment) > 0) then
      begin
      end
      else if MatchFormatEndTag(PWideChar(Text) + Index, CharCount - Index) > 0 then ParsedWidth := -1;
      Inc(Index, TokenLength);
    end
    else
    begin
      if (Text[Index + 1] <> ' ') or (FieldWidth > 0) or (FixedWidthDepth > 0) then
      begin
        if FixedWidthDepth > 0 then Inc(ContentWidth, MaxGlyphAdvance)
        else Inc(ContentWidth, GetGlyphAdvance(Text[Index + 1]));
        Leading := False;
      end
      else if Leading = True then Inc(ContentWidth, GetGlyphAdvance(Text[Index + 1]))
      else Inc(SpaceCount);
      Inc(Index);
    end;
  end;
  if SpaceCount < 1 then
  begin
    DrawTaggedText32(Destination, PitchBytes, X, Y, Text, ClipRect); Exit;
  end;
  SpaceWidth := (Width - ContentWidth) / SpaceCount;
  if SpaceWidth < 2.0 then
  begin
    DrawTaggedText32(Destination, PitchBytes, X, Y, Text, ClipRect); Exit;
  end;
  ObjectCount := SavedObjectCount;
  Lookup := GlyphLookup; GlyphBase := Glyphs;
  PosX := X; Leading := True; Index := 0;
  while Index < CharCount do
  begin
    Character := Text[Index + 1]; Inc(Index);
    TokenLength := GetTaggedTextTokenLength(PWideChar(Text) + Index - 1, CharCount - Index + 1);
    if TokenLength > 0 then
    begin
      ApplyColorTag(PWideChar(Text) + Index - 1, CharCount - Index + 1);
      if ParseObjectTagCached(PWideChar(Text) + Index - 1, CharCount - Index + 1, ObjectIndex) > 0 then
      begin
        Objects[ObjectIndex].X := Trunc(PosX);
        PosX := PosX + Objects[ObjectIndex].Width; Leading := False;
      end
      else if MatchFixTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then Inc(FixedWidthDepth)
      else if MatchFixEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
        FixedWidthDepth := Max(FixedWidthDepth - 1, 0)
      else if (FieldWidth < 0) and
        (ParseFormatTag(PWideChar(Text) + Index - 1, CharCount - Index + 1, ParsedWidth, ParsedAlignment) > 0) then
      begin
        FieldWidth := ParsedWidth; Alignment := ParsedAlignment;
        Index := Index + TokenLength - 1;
        Dec(FieldWidth, CountVisibleTaggedCharsUntilFormatEnd(PWideChar(Text) + Index, CharCount - Index));
        if FieldWidth > 0 then
        begin
          if Alignment = 0 then
          begin
            if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * (FieldWidth shr 1)
            else PosX := PosX + GetGlyphAdvance(' ') * (FieldWidth shr 1);
            Dec(FieldWidth, FieldWidth shr 1);
          end
          else if Alignment > 0 then
          begin
            if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * FieldWidth
            else PosX := PosX + GetGlyphAdvance(' ') * FieldWidth;
            FieldWidth := -1;
          end;
        end
        else FieldWidth := -1;
        Continue;
      end
      else if MatchFormatEndTag(PWideChar(Text) + Index - 1, CharCount - Index + 1) > 0 then
      begin
        ParsedWidth := -1;
        if FieldWidth > 0 then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance * FieldWidth
          else PosX := PosX + GetGlyphAdvance(' ') * FieldWidth;
          FieldWidth := -1;
        end;
      end;
      Index := Index + TokenLength - 1;
    end
    else
    begin
      asm
        XOR EAX, EAX
        MOV AX, Character
        SHL EAX, 1
        ADD EAX, Lookup
        MOV AX, [EAX]
        AND EAX, $FFFF
        MOV GlyphIndex, EAX
      end;
      if GlyphIndex <> 0 then
      begin
        asm
          MOV EAX, GlyphIndex
          DEC EAX
          SHL EAX, 6
          ADD EAX, GlyphBase
          MOV Glyph, EAX
        end;
        if Glyph.OpaqueMaskPlane.DataOffset <> 0 then
        begin
          if Y + Glyph.OpaqueMaskPlane.Top < Top then Top := Y + Glyph.OpaqueMaskPlane.Top;
          if Y + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height > Bottom then Bottom := Y + Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height;
          Ex_OKGR_MaskBuf_DrawClip_DWORD(Destination, PitchBytes, Integer(Trunc(PosX)) + Glyph.OpaqueMaskPlane.Left,
            Y + Glyph.OpaqueMaskPlane.Top, AddPointerOffset(FontData, Glyph.OpaqueMaskPlane.DataOffset), GetCurrentColor, Clip);
        end;
        if Glyph.AlphaMaskPlane.DataOffset <> 0 then
        begin
          if Y + Glyph.AlphaMaskPlane.Top < Top then Top := Y + Glyph.AlphaMaskPlane.Top;
          if Y + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height > Bottom then Bottom := Y + Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height;
          Ex_OKGR_TransBuf_FillAlphaClip_RGBA(Destination, PitchBytes, Integer(Trunc(PosX)) + Glyph.AlphaMaskPlane.Left,
            Y + Glyph.AlphaMaskPlane.Top, AddPointerOffset(FontData, Glyph.AlphaMaskPlane.DataOffset), Clip, GetCurrentColor);
        end;
        if (Character <> ' ') or (FieldWidth > 0) or (FixedWidthDepth > 0) then
        begin
          if FixedWidthDepth > 0 then PosX := PosX + MaxGlyphAdvance
          else PosX := PosX + Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC;
          Leading := False;
        end
        else if Leading = True then PosX := PosX + Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC
        else PosX := PosX + SpaceWidth;
      end;
    end;
  end;
  if ObjectCount - SavedObjectCount > 0 then
  begin
    MiddleY := (Top + Bottom) div 2;
    for Index := SavedObjectCount to ObjectCount - 1 do
      if Objects[Index].VerticalMode = 0 then
        Objects[Index].Y := MiddleY - Objects[Index].Height div 2;
  end;
end;
{ @end $48D368 }

{ @routine $48DC30 TCFontEC_GetTaggedTextTokenLength }
function TCFontEC.GetTaggedTextTokenLength(Text: PWideChar; CharCount: Integer): Integer;
var Index: Integer;
begin
  Result := 0;
  if CharCount < 2 then Exit;
  if Text[0] <> '<' then Exit;
  if Text[1] = '<' then begin Result := 0; Exit; end;
  Index := 1;
  while Index < CharCount do
  begin
    if Text[Index] = '>' then Break;
    Inc(Index);
  end;
  if Index < CharCount then Result := Index + 1;
end;
{ @end $48DC30 }

{ @routine $48DCA4 TCFontEC_ParseTabTagAndAdjustX }
function TCFontEC.ParseTabTagAndAdjustX(Text: PWideChar; CharCount: Integer; var X: Integer): Integer;
var Value, Index: Integer;
begin
  Result := 0;
  if CharCount < 4 then Exit;
  if Text[0] <> '<' then Exit;
  if (Text[1] <> 't') and (Text[1] <> 'T') then Exit;
  if (Text[2] <> 'd') and (Text[2] <> 'D') then Exit;
  if (Text[3] <> '=') and (Text[3] <> '=') then Exit;
  Value := 0; Index := 4;
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    Value := Value * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if (Index < CharCount) and (Text[Index] = '>') then
  begin
    Result := Index + 1;
    if X < Value then X := Value;
  end;
end;
{ @end $48DCA4 }

{ @routine $48DDA4 TCFontEC_ParseAlignTagAndAdjustX }
function TCFontEC.ParseAlignTagAndAdjustX(Text: PWideChar; CharCount: Integer; var X: Integer): Integer;
var
  Ch: WideChar;
  AlignRight: Boolean;
  Index, GlyphIndex, Width, TextLength, TokenLength: Integer;
  Glyph: PAftGlyphEC;
  ObjectIndex, SavedObjectCount: Integer;
  TextCopy: WideString;
begin
  SavedObjectCount := ObjectCount;
  Result := 0;
  if CharCount < 7 then Exit;
  if Text[0] <> '<' then Exit;
  if (Text[1] <> 'a') and (Text[1] <> 'A') then Exit;
  if (Text[2] <> 'l') and (Text[2] <> 'L') then Exit;
  if (Text[3] <> 'i') and (Text[3] <> 'I') then Exit;
  if (Text[4] <> 'g') and (Text[4] <> 'G') then Exit;
  if (Text[5] <> 'n') and (Text[5] <> 'N') then Exit;
  if (Text[6] <> '=') and (Text[6] <> '=') then Exit;
  Index := 0; AlignRight := False;
  if CharCount >= 13 then
  begin
    AlignRight := ((Text[7] = 'r') or (Text[1] = 'R')) and
      ((Text[8] = 'i') or (Text[2] = 'I')) and
      ((Text[9] = 'g') or (Text[3] = 'G')) and
      ((Text[10] = 'h') or (Text[4] = 'H')) and
      ((Text[11] = 't') or (Text[5] = 'T')) and (Text[12] = '>');
    Index := 13;
  end;
  if not AlignRight then
  begin
    if CharCount < 14 then Exit;
    if (Text[7] <> 'c') and (Text[1] <> 'C') then Exit;
    if (Text[8] <> 'e') and (Text[2] <> 'E') then Exit;
    if (Text[9] <> 'n') and (Text[3] <> 'N') then Exit;
    if (Text[10] <> 't') and (Text[4] <> 'T') then Exit;
    if (Text[11] <> 'e') and (Text[5] <> 'E') then Exit;
    if (Text[12] <> 'r') and (Text[5] <> 'R') then Exit;
    if Text[13] <> '>' then Exit;
    Index := 14;
  end;
  Result := Index;
  TextCopy := Text;
  TextLength := Length(TextCopy);
  Width := 0;
  while Index < TextLength do
  begin
    Ch := Text[Index]; Inc(Index);
    TokenLength := GetTaggedTextTokenLength(Text + Index - 1, TextLength - Index + 1);
    if TokenLength > 0 then
    begin
      if MatchAlignEndTag(Text + Index - 1, TextLength - Index + 1) > 0 then Break;
      if ParseObjectTagCached(Text + Index - 1, TextLength - Index + 1, ObjectIndex) > 0 then
        Inc(Width, Objects[ObjectIndex].Width);
      Index := Index + TokenLength - 1;
    end
    else
    begin
      GlyphIndex := ReadWordEC(AddPointerOffset(GlyphLookup, Ord(Ch) * 2));
      if GlyphIndex <> 0 then
      begin
        Glyph := AddPointerOffset(Glyphs, (GlyphIndex - 1) * SizeOf(TAftGlyphEC));
        Width := Glyph.AdvanceA + Width + Glyph.AdvanceB + Glyph.AdvanceC;
      end;
    end;
  end;
  if AlignRight then X := X - Width else X := X - Width div 2;
  ObjectCount := SavedObjectCount;
end;
{ @end $48DDA4 }

{ @routine $48E13C TCFontEC_MatchAlignEndTag }
function TCFontEC.MatchAlignEndTag(Text: PWideChar; CharCount: Integer): Integer;
begin
  Result := 0;
  if CharCount < 8 then Exit;
  if Text[0] <> '<' then Exit;
  if Text[1] <> '/' then Exit;
  if (Text[2] <> 'a') and (Text[2] <> 'A') then Exit;
  if (Text[3] <> 'l') and (Text[3] <> 'L') then Exit;
  if (Text[4] <> 'i') and (Text[4] <> 'I') then Exit;
  if (Text[5] <> 'g') and (Text[5] <> 'G') then Exit;
  if (Text[6] <> 'n') and (Text[6] <> 'N') then Exit;
  if Text[7] = '>' then Result := 8;
end;
{ @end $48E13C }

{ @routine $48E1EC TCFontEC_MatchFixTag }
function TCFontEC.MatchFixTag(Text: PWideChar; CharCount: Integer): Integer;
begin
  Result := 0;
  if CharCount < 5 then Exit;
  if Text[0] <> '<' then Exit;
  if (Text[1] <> 'f') and (Text[1] <> 'F') then Exit;
  if (Text[2] <> 'i') and (Text[2] <> 'I') then Exit;
  if (Text[3] <> 'x') and (Text[3] <> 'X') then Exit;
  if Text[4] = '>' then Result := 5;
end;
{ @end $48E1EC }

{ @routine $48E264 TCFontEC_MatchFixEndTag }
function TCFontEC.MatchFixEndTag(Text: PWideChar; CharCount: Integer): Integer;
begin
  Result := 0;
  if CharCount < 6 then Exit;
  if Text[0] <> '<' then Exit;
  if Text[1] <> '/' then Exit;
  if (Text[2] <> 'f') and (Text[2] <> 'F') then Exit;
  if (Text[3] <> 'i') and (Text[3] <> 'I') then Exit;
  if (Text[4] <> 'x') and (Text[4] <> 'X') then Exit;
  if Text[5] = '>' then Result := 6;
end;
{ @end $48E264 }

{ @routine $48E2E8 TCFontEC_ParseFormatTag }
function TCFontEC.ParseFormatTag(Text: PWideChar; CharCount: Integer; out FieldWidth, Alignment: Integer): Integer;
var Index: Integer;
begin
  Result := 0;
  if CharCount < 13 then Exit;
  if Text[0] <> '<' then Exit;
  if (Text[1] <> 'f') and (Text[1] <> 'F') then Exit;
  if (Text[2] <> 'o') and (Text[2] <> 'O') then Exit;
  if (Text[3] <> 'r') and (Text[3] <> 'R') then Exit;
  if (Text[4] <> 'm') and (Text[4] <> 'M') then Exit;
  if (Text[5] <> 'a') and (Text[5] <> 'A') then Exit;
  if (Text[6] <> 't') and (Text[6] <> 'T') then Exit;
  if (Text[7] <> '=') and (Text[7] <> '=') then Exit;
  FieldWidth := 0; Alignment := 0; Index := 8;
  if (Index + 5 <= CharCount) and ((Text[Index] = 'r') or (Text[Index] = 'R')) and
     ((Text[Index + 1] = 'i') or (Text[Index + 1] = 'I')) and
     ((Text[Index + 2] = 'g') or (Text[Index + 2] = 'G')) and
     ((Text[Index + 3] = 'h') or (Text[Index + 3] = 'H')) and
     ((Text[Index + 4] = 't') or (Text[Index + 4] = 'T')) then
  begin
    Alignment := 1; Inc(Index, 5);
  end
  else if (Index + 4 <= CharCount) and ((Text[Index] = 'l') or (Text[Index] = 'L')) and
     ((Text[Index + 1] = 'e') or (Text[Index + 1] = 'E')) and
     ((Text[Index + 2] = 'f') or (Text[Index + 2] = 'F')) and
     ((Text[Index + 3] = 't') or (Text[Index + 3] = 'T')) then
  begin
    Alignment := -1; Inc(Index, 4);
  end
  else if (Index + 6 <= CharCount) and ((Text[Index] = 'c') or (Text[Index] = 'C')) and
     ((Text[Index + 1] = 'e') or (Text[Index + 1] = 'E')) and
     ((Text[Index + 2] = 'n') or (Text[Index + 2] = 'N')) and
     ((Text[Index + 3] = 't') or (Text[Index + 3] = 'T')) and
     ((Text[Index + 4] = 'e') or (Text[Index + 4] = 'E')) and
     ((Text[Index + 5] = 'r') or (Text[Index + 5] = 'R')) then
  begin
    Alignment := 0; Inc(Index, 6);
  end
  else Exit;
  if Index >= CharCount then Exit;
  if Text[Index] <> ',' then Exit;
  Inc(Index);
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    FieldWidth := FieldWidth * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if (Index < CharCount) and (Text[Index] = '>') then Result := Index + 1;
end;
{ @end $48E2E8 }

{ @routine $48E670 TCFontEC_MatchFormatEndTag }
function TCFontEC.MatchFormatEndTag(Text: PWideChar; CharCount: Integer): Integer;
begin
  Result := 0;
  if CharCount < 9 then Exit;
  if Text[0] <> '<' then Exit;
  if Text[1] <> '/' then Exit;
  if (Text[2] <> 'f') and (Text[2] <> 'F') then Exit;
  if (Text[3] <> 'o') and (Text[3] <> 'O') then Exit;
  if (Text[4] <> 'r') and (Text[4] <> 'R') then Exit;
  if (Text[5] <> 'm') and (Text[5] <> 'M') then Exit;
  if (Text[6] <> 'a') and (Text[6] <> 'A') then Exit;
  if (Text[7] <> 't') and (Text[7] <> 'T') then Exit;
  if Text[8] = '>' then Result := 9;
end;
{ @end $48E670 }

{ @routine $48E73C TCFontEC_CountVisibleTaggedCharsUntilFormatEnd }
function TCFontEC.CountVisibleTaggedCharsUntilFormatEnd(Text: PWideChar; CharCount: Integer): Integer;
var Index, GlyphIndex, TokenLength: Integer; Ch: WideChar;
begin
  Result := 0;
  Index := 0;
  while Index < CharCount do
  begin
    Ch := PFontTextCharsEC(Text)^[Index]; Inc(Index);
    TokenLength := GetTaggedTextTokenLength(Text + Index - 1, CharCount - Index + 1);
    if TokenLength > 0 then
    begin
      if MatchFormatEndTag(Text + Index - 1, CharCount - Index + 1) > 0 then Break;
      Index := Index + TokenLength - 1;
    end
    else
    begin
      GlyphIndex := ReadWordEC(AddPointerOffset(GlyphLookup, Ord(Ch) * 2));
      if GlyphIndex <> 0 then Inc(Result);
    end;
  end;
end;
{ @end $48E73C }

{ @routine $48E800 TCFontEC_ParseObjectTagCached }
function TCFontEC.ParseObjectTagCached(Text: PWideChar; CharCount: Integer; out ObjectIndex: Integer): Integer;
begin
  if ObjectCount <= ObjectCapacity then
  begin
    ObjectCapacity := ObjectCount + 4;
    SetLength(Objects, ObjectCapacity);
  end;
  ObjectIndex := -1;
  Result := ParseObjectTag(Text, CharCount, Objects[ObjectCount]);
  if Result > 0 then begin ObjectIndex := ObjectCount; Inc(ObjectCount); end;
end;
{ @end $48E800 }

{ @routine $48E89C TCFontEC_ParseObjectTag }
function TCFontEC.ParseObjectTag(Text: PWideChar; CharCount: Integer; out Item: TFontObjectEC): Integer;
var Index: Integer;
begin
  Result := 0;
  if CharCount < 13 then Exit;
  if Text[0] <> '<' then Exit;
  if (Text[1] <> 'o') and (Text[1] <> 'O') then Exit;
  if (Text[2] <> 'b') and (Text[2] <> 'B') then Exit;
  if (Text[3] <> 'j') and (Text[3] <> 'J') then Exit;
  if (Text[4] <> 'e') and (Text[4] <> 'E') then Exit;
  if (Text[5] <> 'c') and (Text[5] <> 'C') then Exit;
  if (Text[6] <> 't') and (Text[6] <> 'T') then Exit;
  if (Text[7] <> '=') and (Text[7] <> '=') then Exit;
  Item.ObjectId := 0; Item.Width := 0; Item.Height := 0; Item.VerticalMode := 0;
  Index := 8;
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    Item.ObjectId := Item.ObjectId * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if Index >= CharCount then Exit;
  if Text[Index] <> ',' then Exit;
  Inc(Index);
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    Item.Width := Item.Width * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if Index >= CharCount then Exit;
  if Text[Index] <> ',' then Exit;
  Inc(Index);
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    Item.Height := Item.Height * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if Index >= CharCount then Exit;
  if Text[Index] <> ',' then Exit;
  Inc(Index);
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    Item.VerticalMode := Item.VerticalMode * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if (Index < CharCount) and (Text[Index] = '>') then Result := Index + 1;
end;
{ @end $48E89C }

{ @routine $48EB44 TCFontEC_ParseColorTag }
function TCFontEC.ParseColorTag(Text: PWideChar; CharCount: Integer; out Color: Cardinal): Integer;
var Red, Green, Blue, Index: Integer;
begin
  Result := 0;
  if CharCount < 13 then Exit;
  if Text[0] <> '<' then Exit;
  if (Text[1] <> 'c') and (Text[1] <> 'C') then Exit;
  if (Text[2] <> 'o') and (Text[2] <> 'O') then Exit;
  if (Text[3] <> 'l') and (Text[3] <> 'L') then Exit;
  if (Text[4] <> 'o') and (Text[4] <> 'O') then Exit;
  if (Text[5] <> 'r') and (Text[5] <> 'R') then Exit;
  if (Text[6] <> '=') and (Text[6] <> '=') then Exit;
  Red := 0; Green := 0; Blue := 0; Index := 7;
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    Red := Red * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if Index >= CharCount then Exit;
  if Text[Index] <> ',' then Exit;
  Inc(Index);
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    Green := Green * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if Index >= CharCount then Exit;
  if Text[Index] <> ',' then Exit;
  Inc(Index);
  while Index < CharCount do
  begin
    if (Text[Index] < '0') or (Text[Index] > '9') then Break;
    Blue := Blue * 10 + Ord(Text[Index]) - Ord('0');
    Inc(Index);
  end;
  if Index >= CharCount then Exit;
  if Text[Index] <> '>' then Exit;
  Result := Index + 1;
  if not UseARGBColors then Color := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue)
  else Color := (Red shl 16) or (Green shl 8) or Blue or $FF000000;
end;
{ @end $48EB44 }

{ @routine $48ED90 TCFontEC_MatchColorEndTag }
function TCFontEC.MatchColorEndTag(Text: PWideChar; CharCount: Integer): Integer;
begin
  Result := 0;
  if CharCount < 8 then Exit;
  if Text[0] <> '<' then Exit;
  if Text[1] <> '/' then Exit;
  if (Text[2] <> 'c') and (Text[2] <> 'C') then Exit;
  if (Text[3] <> 'o') and (Text[3] <> 'O') then Exit;
  if (Text[4] <> 'l') and (Text[4] <> 'L') then Exit;
  if (Text[5] <> 'o') and (Text[5] <> 'O') then Exit;
  if (Text[6] <> 'r') and (Text[6] <> 'R') then Exit;
  if Text[7] = '>' then Result := 8;
end;
{ @end $48ED90 }

{ @routine $48EE40 TCFontEC_ApplyColorTag }
procedure TCFontEC.ApplyColorTag(Text: PWideChar; CharCount: Integer);
var Color: Cardinal;
begin
  if ParseColorTag(Text, CharCount, Color) > 0 then
  begin
    if ColorTagsEnabled then PushColor(Color);
  end
  else if MatchColorEndTag(Text, CharCount) > 0 then
  begin
    if ColorTagsEnabled then PopColor;
  end;
end;
{ @end $48EE40 }

{ @routine $48EEA4 TCFontEC_ClearColorStack }
procedure TCFontEC.ClearColorStack;
begin
  if ColorStack <> nil then begin FreeEC(ColorStack); ColorStack := nil; end;
  ColorStackCount := 0;
end;
{ @end $48EEA4 }

{ @routine $48EED4 TCFontEC_PushColor }
procedure TCFontEC.PushColor(Color: Cardinal);
begin
  Inc(ColorStackCount);
  ColorStack := ReAllocREC(ColorStack, ColorStackCount * SizeOf(Cardinal));
  WriteIntegerEC(AddPointerOffset(ColorStack, (ColorStackCount - 1) * SizeOf(Cardinal)), Color);
end;
{ @end $48EED4 }

{ @routine $48EF2C TCFontEC_PopColor }
function TCFontEC.PopColor: Cardinal;
begin
  if ColorStackCount < 1 then begin Result := 0; Exit; end;
  Result := ReadDWordEC(AddPointerOffset(ColorStack, (ColorStackCount - 1) * SizeOf(Cardinal)));
  Dec(ColorStackCount);
end;
{ @end $48EF2C }

{ @routine $48EF78 TCFontEC_GetCurrentColor }
function TCFontEC.GetCurrentColor: Cardinal;
begin
  if not ColorTagsEnabled or (ColorStackCount < 1) then Result := DefaultColor
  else Result := ReadDWordEC(AddPointerOffset(ColorStack, (ColorStackCount - 1) * SizeOf(Cardinal)));
end;
{ @end $48EF78 }

{ @routine $48EFCC TCFontEC_LoadFromConfigBuffer }
procedure TCFontEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
var Index: Integer; Glyph: PAftGlyphEC;
begin
  ClearLoadedFontData;
  if SourceBuffer.DataSize < SizeOf(TAftHeaderEC) then raise Exception.Create('TCFontEC.Load. Error format file.');
  FontData := AllocEC(SourceBuffer.DataSize);
  CopyMemory(FontData, SourceBuffer.Data, SourceBuffer.DataSize);
  Glyphs := AddPointerOffset(FontData, SizeOf(TAftHeaderEC));
  if (FontData.Magic[0] <> 'a') or (FontData.Magic[1] <> 'f') or (FontData.Magic[2] <> 't') then
    raise Exception.Create('TCFontEC.Load. Error format file.');
  if FontData.Version <> 1 then raise Exception.Create('TCFontEC.Load. Unknown version of font.');
  GlyphCount := FontData.GlyphCount;
  GlyphLookup := AllocClearEC(SizeOf(TFontGlyphLookupEC));
  AboveBaseline := 0; BelowBaseline := 0; MaxGlyphAdvance := 0;
  Glyph := Glyphs;
  for Index := 0 to GlyphCount - 1 do
  begin
    WriteWordEC(AddPointerOffset(GlyphLookup, Glyph.CharCode * 2), Word(Index) + 1);
    if Glyph.OpaqueMaskPlane.DataOffset <> 0 then
    begin
      if (Glyph.OpaqueMaskPlane.Top <= 0) and (-Glyph.OpaqueMaskPlane.Top + 1 > AboveBaseline) then
        AboveBaseline := -Glyph.OpaqueMaskPlane.Top + 1;
      if (Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height > 0) and
         (Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height - 1 > BelowBaseline) then
        BelowBaseline := Glyph.OpaqueMaskPlane.Top + Glyph.OpaqueMaskPlane.Height - 1;
    end;
    if Glyph.AlphaMaskPlane.DataOffset <> 0 then
    begin
      if (Glyph.AlphaMaskPlane.Top <= 0) and (-Glyph.AlphaMaskPlane.Top + 1 > AboveBaseline) then
        AboveBaseline := -Glyph.AlphaMaskPlane.Top + 1;
      if (Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height > 0) and
         (Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height - 1 > BelowBaseline) then
        BelowBaseline := Glyph.AlphaMaskPlane.Top + Glyph.AlphaMaskPlane.Height - 1;
    end;
    MaxGlyphAdvance := Max(MaxGlyphAdvance, Glyph.AdvanceA + Glyph.AdvanceB + Glyph.AdvanceC);
    Glyph := AddPointerOffset(Glyph, SizeOf(TAftGlyphEC));
  end;
  ResidentBytes := 0;
end;
{ @end $48EFCC }

{ @routine $48F58C TCFontEC_RenderTaggedTextToTexture }
procedure TCFontEC.RenderTaggedTextToTexture(const Text: WideString; Width, Height, AlignX, AlignY: Integer; WordWrap: Boolean; ActualSize: PPoint; var Texture: IDirect3DTexture9);
var
  TopAdjustment, CurrentY: Integer;
  Lines: TStringsEC;
  Bounds: TRect;
  WrappedLines: TStringsEC;
  DrawX, DrawY: Integer;
  SavedColorTags, CenteredTabs: Boolean;
  ImageSize: TPoint;
  Image: IDirect3DTexture9;
  Locked: TD3DLockedRect;
  Clip: TRect;

  // @nested $48F2B8 MeasureFontTextureTextSize
  function MeasureFontTextureTextSize: TPoint; // @addr 0x48F2B8 @ida "void __usercall $name(TPoint *Result@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x0048F674"
  var
    First: Boolean;
    ExtraHeight: Integer;
    MergedBounds: TRect;
  begin
    MergedBounds.Left := 0; MergedBounds.Right := 0;
    MergedBounds.Top := 0; MergedBounds.Bottom := 0;
    CurrentY := 0; ExtraHeight := 0;
    Lines.First;
    if not WordWrap then
    begin
      if not Lines.IsAtEnd then
      begin
        MergedBounds := MeasureTaggedTextBounds(Lines.GetCurrentText, 0, CurrentY, @TopAdjustment);
        Inc(CurrentY, GetLineHeight);
        Lines.Next;
      end;
      while not Lines.IsAtEnd do
      begin
        Bounds := MeasureTaggedTextBounds(Lines.GetCurrentText, 0, CurrentY, nil);
        Windows.UnionRect(MergedBounds, MergedBounds, Bounds);
        Inc(CurrentY, GetLineHeight);
        Lines.Next;
      end;
    end
    else
    begin
      First := True;
      while not Lines.IsAtEnd do
      begin
        WrapTaggedTextIntoLines(WrappedLines, Lines.GetCurrentText, Width - 4);
        if not WrappedLines.IsEmpty then
        begin
          WrappedLines.First;
          if First then
          begin
            MergedBounds := MeasureTaggedTextBounds(WrappedLines.GetCurrentText, 0, CurrentY, @TopAdjustment);
            First := False;
            Inc(CurrentY, GetLineHeight);
            WrappedLines.Next;
          end;
          while not WrappedLines.IsAtEnd do
          begin
            Bounds := MeasureTaggedTextBounds(WrappedLines.GetCurrentText, 0, CurrentY, nil);
            Windows.UnionRect(MergedBounds, MergedBounds, Bounds);
            Inc(CurrentY, GetLineHeight);
            WrappedLines.Next;
          end;
        end;
        Lines.Next;
      end;
      ExtraHeight := 2;
    end;
    Result := Classes.Point(MergedBounds.Right - MergedBounds.Left,
      ExtraHeight + MergedBounds.Bottom - MergedBounds.Top);
  end;

begin
  Lines := nil; WrappedLines := nil; Image := nil;
  try
    Lines := TStringsEC.Create;
    Lines.SetText(Text);
    UseARGBColors := True;
    SavedColorTags := ColorTagsEnabled; ColorTagsEnabled := False;
    CenteredTabs := (AlignX = 1) and (Pos(WideString('<td='), Text) > 0);
    if WordWrap then WrappedLines := TStringsEC.Create;
    if (Width = 0) and WordWrap then RaiseWideMessage('draw text to texture 1');
    ImageSize := MeasureFontTextureTextSize;
    if Width = 0 then Width := ImageSize.X;
    if Height = 0 then Height := ImageSize.Y;
    DrawX := 0; DrawY := 0;
    if (AlignX = 0) or WordWrap or CenteredTabs then DrawX := 2
    else if AlignX = 2 then DrawX := Width - ImageSize.X - 2
    else if AlignX = 1 then DrawX := Width div 2 - ImageSize.X div 2
    else if AlignX = 3 then begin DrawX := 2; Width := ImageSize.X + 4; end;
    if AlignY = 0 then DrawY := TopAdjustment + 2
    else if AlignY = 3 then DrawY := Height - ImageSize.Y - 2 + TopAdjustment
    else if AlignY = 1 then DrawY := Height div 2 - ImageSize.Y div 2 + TopAdjustment
    else if AlignY = 2 then DrawY := Height div 2 - ImageSize.Y div 2 + TopAdjustment
    else if AlignY = 4 then begin DrawY := TopAdjustment + 2; Height := ImageSize.Y + 4; end;
    Clip := Classes.Rect(0, 0, Width, Height);
    Image := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
    if Image = nil then RaiseWideMessage('draw text to texture 2');
    Image.LockRect(0, Locked, nil, 0);
    ColorTagsEnabled := SavedColorTags;
    if not WordWrap then
    begin
      if AlignY = 2 then
        CurrentY := Height div 2 - (GetLineHeight * (Lines.GetCount - 1) + GetCenteringHeight) div 2 + GetCenteringHeight
      else CurrentY := AboveBaseline + DrawY - 2;
      Lines.First;
      while not Lines.IsAtEnd do
      begin
        DrawTaggedText32(Locked.Bits, Locked.Pitch, DrawX, CurrentY, Lines.GetCurrentText, Clip);
        Inc(CurrentY, GetLineHeight);
        Lines.Next;
      end;
    end
    else
    begin
      CurrentY := AboveBaseline + DrawY - 2;
      Lines.First;
      while not Lines.IsAtEnd do
      begin
        WrapTaggedTextIntoLines(WrappedLines, Lines.GetCurrentText, Width - 4);
        WrappedLines.First;
        while not WrappedLines.IsAtEnd do
        begin
          if (AlignX = 0) or CenteredTabs then
            DrawTaggedText32(Locked.Bits, Locked.Pitch, DrawX, CurrentY, WrappedLines.GetCurrentText, Clip)
          else if AlignX = 2 then
          begin
            Bounds := MeasureTaggedTextBounds(WrappedLines.GetCurrentText, 0, 0, nil);
            DrawTaggedText32(Locked.Bits, Locked.Pitch, Width - (Bounds.Right - Bounds.Left), CurrentY, WrappedLines.GetCurrentText, Clip);
          end
          else if AlignX = 1 then
          begin
            Bounds := MeasureTaggedTextBounds(WrappedLines.GetCurrentText, 0, 0, nil);
            DrawTaggedText32(Locked.Bits, Locked.Pitch, Width div 2 - (Bounds.Right - Bounds.Left) div 2, CurrentY, WrappedLines.GetCurrentText, Clip);
          end
          else if (AlignX = 3) and not WrappedLines.IsAtLast then
            DrawJustifiedTaggedText32(Locked.Bits, Locked.Pitch, DrawX, CurrentY, WrappedLines.GetCurrentText, Width - 4, Clip)
          else
            DrawTaggedText32(Locked.Bits, Locked.Pitch, DrawX, CurrentY, WrappedLines.GetCurrentText, Clip);
          Inc(CurrentY, GetLineHeight);
          WrappedLines.Next;
        end;
        Lines.Next;
      end;
    end;
    Image.UnlockRect(0);
  finally
    if Lines <> nil then Lines.Free;
    if WrappedLines <> nil then WrappedLines.Free;
  end;
  if ActualSize <> nil then ActualSize^ := Classes.Point(Width, Height);
  Texture := Image;
end;
{ @end $48F58C }

end.
