unit EC_Str;

interface

type
  THexDigits = array[0..15] of WideChar; // @size 32

  TWideCasePair = record // @size 0x04
    LowerChar: WideChar; // @offset 0x00
    UpperChar: WideChar; // @offset 0x02
  end;
  TWideCaseTable = array of TWideCasePair;

  TStringsElEC = class(TObject) // @size 0x14
  public
    Prev: TStringsElEC; // @offset 0x04
    Next: TStringsElEC; // @offset 0x08
    Text: WideString; // @offset 0x0C
    Data: Pointer; // @offset 0x10
  end;

  TStringsEC = class(TObject) // @size 0x10
  public
    FirstElement: TStringsElEC; // @offset 0x04
    LastElement: TStringsElEC; // @offset 0x08
    CurrentElement: TStringsElEC; // @offset 0x0C

    constructor Create; // @addr 0x007998B4
    destructor Destroy; override; // @addr 0x007998EC
    procedure Clear; // @addr 0x00799918
    function AddEmptyElement: TStringsElEC; // @addr 0x00799934
    procedure AppendElement(Item: TStringsElEC); // @addr 0x00799954
    procedure RemoveAndFreeElement(Item: TStringsElEC); // @addr 0x00799978 @note "Does not adjust CurrentElement."
    function GetElement(Index: Integer): TStringsElEC; // @addr 0x007999B4 @note "Raises when the index is outside the list."
    function EnsureElement(Index: Integer): TStringsElEC; // @addr 0x00799A5C @note "Creates missing entries; negative indexes raise."
    function GetCount: Integer; // @addr 0x00799B20
    function GetTextAt(Index: Integer): WideString; // @addr 0x00799B34 @note "Reading beyond the end extends the list."
    function GetDataAt(Index: Integer): Pointer; // @addr 0x00799B54 @note "Reading beyond the end extends the list."
    procedure SetDataAt(Index: Integer; Data: Pointer); // @addr 0x00799B6C @note "Creates missing entries; Data is borrowed."
    function IndexOf(const Text: WideString): Integer; // @addr 0x00799B88 @note "Case-sensitive comparison; returns -1 when absent."
    procedure Add(const Text: WideString); // @addr 0x00799BBC
    procedure AddSlice(Text: PWideChar; CharCount: Integer); // @addr 0x00799BD8 @note "Nonpositive CharCount still appends an empty element."
    procedure Delete(Index: Integer); // @addr 0x00799C0C @note "If deleting CurrentElement, moves it to the next element or otherwise the previous one."
    function GetCurrentText: WideString; // @addr 0x00799C38 @note "Raises when CurrentElement is nil."
    function GetCurrentData: Pointer; // @addr 0x00799C84 @note "Raises when CurrentElement is nil."
    function IsAtEnd: Boolean; // @addr 0x00799CC4
    function IsAtLast: Boolean; // @addr 0x00799CD0 @note "Requires nonnil CurrentElement."
    procedure First; // @addr 0x00799CE0
    procedure Next; // @addr 0x00799CE8 @note "Requires nonnil CurrentElement."
    function IsEmpty: Boolean; // @addr 0x00799CF4
    procedure SetText(const Text: WideString); // @addr 0x00799CFC @note "Splits CR, LF and CRLF lines; does not append an empty line after a trailing separator."
    function GetText: WideString; // @addr 0x00799D68 @note "Joins elements with CRLF, without a trailing separator."
    property Text: WideString read GetText write SetText;
    property Count: Integer read GetCount;
    property Strings[Index: Integer]: WideString read GetTextAt;
    property Data[Index: Integer]: Pointer read GetDataAt write SetDataAt;
    property Elements[Index: Integer]: TStringsElEC read GetElement;
    property CurrentText: WideString read GetCurrentText;
    property CurrentData: Pointer read GetCurrentData;
  end;

function CountDelimitedPartsW(const Text: WideString; const Delimiters: WideString): Integer; // @addr 0x00799DC4 @note "Delimiters is a set of separator characters, not a substring. Counts empty parts; empty Text returns zero."
function GetDelimitedPartStartIndexW(const Text: WideString; PartIndex: Integer; const Delimiters: WideString): Integer; // @addr 0x00799E34 @note "Zero-based part index, one-based character result. Nonpositive PartIndex returns 1; missing positive indexes raise."
function GetCharDelimitedPartStartIndexW(const Text: WideString; PartIndex: Integer; Delimiter: WideChar): Integer; // @addr 0x00799FA4 @note "One-based character result. Nonpositive PartIndex returns 1; 1 returns the position after the first delimiter or -1. Native early exit makes every PartIndex above 1 return -1."
function GetDelimitedPartLengthW(const Text: WideString; StartIndex: Integer; const Delimiters: WideString): Integer; // @addr 0x00799FE4 @note "StartIndex is a one-based character position, not a part index."
function ExtractDelimitedPartW(const Text: WideString; PartIndex: Integer; const Delimiters: WideString): WideString; // @addr 0x0079A054
function ExtractDelimitedRangeW(const Text: WideString; FirstPart: Integer; LastPart: Integer; const Delimiters: WideString): WideString; // @addr 0x0079A094 @note "Includes both zero-based part indexes and the separators between them."
function ExtractNextDelimitedPartW(var Text: WideString; Delimiter: WideChar): WideString; // @addr 0x0079A0EC @note "Removes the returned prefix and first delimiter from Text; without a delimiter returns all of Text and clears it."
function ExtractLineCommentW(const Text: WideString): WideString; // @addr 0x0079A17C @note "Returns the first // and following text, including immediately preceding spaces, tabs, CR and LF. Empty when absent; does not recognize quoting."
function RemoveLineCommentW(const Text: WideString): WideString; // @addr 0x0079A1F0 @note "Removes the first // and following text, then trims trailing characters <= #32. Without // returns Text unchanged; does not recognize quoting."
function ReplaceAllWideString(const Text: WideString; const Search: WideString; const Replacement: WideString): WideString; // @addr 0x0079A654 @note "Case-sensitive, non-overlapping replacement; empty Search returns Text unchanged."
function FindTextOffsetW(const Text: WideString; const Search: WideString; StartIndex: Integer = 0): Integer; // @addr 0x0079AF58 @note "Zero-based start and result; starts at a nonnegative character offset and returns -1 when absent."
function FindTextPosW(const Search: WideString; const Text: WideString): Integer; // @addr 0x0079B01C @note "One-based result, with Search before Text as in Pos; returns zero when absent."
function ExtractDigitsToIntW(const Text: WideString): Integer; // @addr 0x0079A2CC @note "Ignores signs and other nondigits; unchecked 32-bit arithmetic."
function IsIntegerTextW(const Text: WideString): Boolean; // @addr 0x0079A284 @note "True for any nonempty string containing only digits and minus signs, including '-' and '1--2'; does not validate numeric syntax or range."
function ExtractSignedDigitsToIntW(const Text: WideString): Integer; // @addr 0x0079A360 @note "Ignores nondigits; a minus sign encountered while the accumulated value is zero makes the result negative. Unchecked 32-bit arithmetic."
function ExtractDecimalToSingleW(const Text: WideString): Single; // @addr 0x0079A414 @note "Accepts '.' or ','; ignores other nondigits and treats any '-' as negative. No exponent syntax."
function ParseDecimalToSingleW(const Text: WideString): Single; // @addr 0x0079A4FC @note "Same permissive conversion as ExtractDecimalToSingleW; all accumulation and the result use Single precision."
function FloatToWideString(Value: Double): WideString; // @addr 0x0079A5E4 @ida "void __userpurge $name(unsigned __int16 **Result@<eax>, double Value@<^0>);" @note "Uses a decimal point by temporarily changing the RTL's global separator; not thread-safe, and an exception can leave the separator changed."
function CardinalToHexWideString(Value: Cardinal): WideString; // @addr 0x0079A76C @note "Lowercase hexadecimal without a prefix or padding; zero becomes '0'."
function IntToFixedWidthWideString(Value: Integer; Width: Integer): WideString; // @addr 0x0079A80C @note "Left-pads with zeros or keeps only the leftmost Width digits. Nonpositive Value produces zeros; nonpositive Width produces an empty string."
function IntToWideString(Value: Integer): WideString; // @addr 0x0079A8D0 @note "Low(Integer) incorrectly produces '-0'."
function BoolToWideString(Value: Boolean): WideString; // @addr 0x0079A98C @ida "void __usercall $name(unsigned __int8 Value@<al>, unsigned __int16 **Result@<edx>);" @note "Returns 'True' or 'False'."
function TrimWideString(const Text: WideString): WideString; // @addr 0x0079A9D0 @note "Trims only spaces, tabs, CR, LF and NUL characters at both ends."
function UpperCaseWideString(const Text: WideString): WideString; // @addr 0x0079AA88 @note "Uses the language CaseConv table; characters absent from it remain unchanged."
function LowerCaseWideString(const Text: WideString): WideString; // @addr 0x0079AB04 @note "Uses the language CaseConv table in reverse; characters absent from it remain unchanged."
function RemoveWideStringChars(const Text: WideString; Chars: WideString): WideString; // @addr 0x0079AB7C @note "Chars is a set of individual characters, not a substring."
function GetTextTagLengthW(Text: PWideChar; CharCount: Integer): Integer; // @addr 0x0079AC90 @note "Returns the leading <...> token length, 1 for leading <<, or zero when no complete tag is present."
function MatchTextTagPrefixW(Text: PWideChar; CharCount: Integer; const Pattern: WideString; const AlternatePattern: WideString): Boolean; // @addr 0x0079ACCC @note "Requires leading < and equal-length patterns. Each character may match either pattern; no closing > or name boundary is required."
function RemoveTextTagsW(const Text: WideString): WideString; // @addr 0x0079AD4C @note "Removes complete <...> tokens; leading << consumes one character and scanning resumes at the second <. Incomplete tags remain."
function RemoveMatchingTextTagsW(Text: WideString; const Pattern: WideString; const AlternatePattern: WideString): WideString; // @addr 0x0079ADEC @note "Uses MatchTextTagPrefixW; opening and closing tags require separate patterns."
function CompareWideChars(Left: PWideChar; Right: PWideChar): Integer; cdecl; // @addr 0x0079AF00 @note "Case-sensitive NUL-terminated comparison returning -1, 0 or 1. Nil sorts before every nonnil pointer, including an empty string."

// Original unit ownership of these standalone helpers is unresolved.
function ExtractFileNameNoExtW(const Path: WideString): WideString; // @addr 0x0079B034 @note "Accepts slash and backslash; strips only the final dot and suffix from the last path component."
function ExtractFileExtNoDotW(const Path: WideString): WideString; // @addr 0x0079B0D8 @note "Accepts slash and backslash; returns text after the last dot in the final component, or empty when absent."
function ExtractFileDirW(const Path: WideString): WideString; // @addr 0x0079B180 @note "Accepts slash and backslash; excludes the final separator and component."
// Game text obfuscation: EncodeTextW inserts a random character after each input
// character; DecodeTextW discards those interleaved characters.
function DecodeTextW(Text: WideString): WideString; // @addr 0x0079B2B4 @note "Keeps characters 1, 3, 5, ... using Delphi's one-based string indexing."
function CopyWideStringUnchecked(Text: WideString; Index: Integer; Count: Integer): WideString; // @addr 0x0079C1B8 @note "One-based Index; unlike the RTL Copy helper, does not clamp Index or Count to the source. Requires a valid source span and nonnegative Count."

procedure WriteRegistryStringLegacy(RootKey: Cardinal; KeyPath, ValueName, Value: WideString); // @addr $79B1C8 @note "Creates with KEY_WRITE. Passes an ANSI-converted buffer and ANSI byte count to RegSetValueExW; preserves this native encoding mismatch."
function EncodeTextW(Text: WideString): WideString; // @addr $79B340 @note "Inserts a random language-table character after each input character; requires a nonempty WideCaseTable."
function TransliterateCyrillicToLatin(Text: WideString): WideString; // @addr $79B440 @note "Applies the native ordered replacement table, including its unusual letter mappings."

const
  HexDigits: THexDigits = ('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'); // @addr $812AF0

implementation

uses EC_Mem, GR_Main, SysUtils, Windows;

{ @routine $7998B4 TStringsEC_Create }
constructor TStringsEC.Create;
begin
  inherited Create;
end;
{ @end $7998B4 }

{ @routine $7998EC TStringsEC_Destroy }
destructor TStringsEC.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $7998EC }

{ @routine $799918 TStringsEC_Clear }
procedure TStringsEC.Clear;
begin
  while FirstElement <> nil do RemoveAndFreeElement(LastElement);
  CurrentElement := nil;
end;
{ @end $799918 }

{ @routine $799934 TStringsEC_AddEmptyElement }
function TStringsEC.AddEmptyElement: TStringsElEC;
var Item: TStringsElEC;
begin
  Item := TStringsElEC.Create;
  AppendElement(Item);
  Result := Item;
end;
{ @end $799934 }

{ @routine $799954 TStringsEC_AppendElement }
procedure TStringsEC.AppendElement(Item: TStringsElEC);
begin
  if LastElement <> nil then LastElement.Next := Item;
  Item.Prev := LastElement;
  Item.Next := nil;
  LastElement := Item;
  if FirstElement = nil then FirstElement := Item;
end;
{ @end $799954 }

{ @routine $799978 TStringsEC_RemoveAndFreeElement }
procedure TStringsEC.RemoveAndFreeElement(Item: TStringsElEC);
begin
  if Item.Prev <> nil then Item.Prev.Next := Item.Next;
  if Item.Next <> nil then Item.Next.Prev := Item.Prev;
  if LastElement = Item then LastElement := Item.Prev;
  if FirstElement = Item then FirstElement := Item.Next;
  Item.Free;
end;
{ @end $799978 }

{ @routine $7999B4 TStringsEC_GetElement }
function TStringsEC.GetElement(Index: Integer): TStringsElEC;
var Item: TStringsElEC;
begin
  Item := FirstElement;
  while Item <> nil do
  begin
    if Index = 0 then
    begin
      Result := Item;
      Exit;
    end;
    Dec(Index);
    Item := Item.Next;
  end;
  raise Exception.Create('TStringsEC.El_Get. i=' + SysUtils.IntToStr(Index));
end;
{ @end $7999B4 }

{ @routine $799A5C TStringsEC_EnsureElement }
function TStringsEC.EnsureElement(Index: Integer): TStringsElEC;
var Item: TStringsElEC;
begin
  if Index < 0 then raise Exception.Create('TStringsEC.El_GetEx. i=' + SysUtils.IntToStr(Index));
  Item := FirstElement;
  while Item <> nil do
  begin
    if Index = 0 then
    begin
      Result := Item;
      Exit;
    end;
    Dec(Index);
    Item := Item.Next;
  end;
  while Index >= 0 do
  begin
    AddEmptyElement;
    Dec(Index);
  end;
  Result := LastElement;
end;
{ @end $799A5C }

{ @routine $799B20 TStringsEC_GetCount }
function TStringsEC.GetCount: Integer;
var Item: TStringsElEC;
begin
  Item := FirstElement;
  Result := 0;
  while Item <> nil do
  begin
    Inc(Result);
    Item := Item.Next;
  end;
end;
{ @end $799B20 }

{ @routine $799B34 TStringsEC_GetTextAt }
function TStringsEC.GetTextAt(Index: Integer): WideString;
begin
  Result := EnsureElement(Index).Text;
end;
{ @end $799B34 }

{ @routine $799B54 TStringsEC_GetDataAt }
function TStringsEC.GetDataAt(Index: Integer): Pointer;
begin
  Result := EnsureElement(Index).Data;
end;
{ @end $799B54 }

{ @routine $799B6C TStringsEC_SetDataAt }
procedure TStringsEC.SetDataAt(Index: Integer; Data: Pointer);
begin
  EnsureElement(Index).Data := Data;
end;
{ @end $799B6C }

{ @routine $799B88 TStringsEC_IndexOf }
function TStringsEC.IndexOf(const Text: WideString): Integer;
var Item: TStringsElEC; i: Integer;
begin
  Item := FirstElement;
  i := 0;
  while Item <> nil do
  begin
    if Item.Text = Text then
    begin
      Result := i;
      Exit;
    end;
    Inc(i);
    Item := Item.Next;
  end;
  Result := -1;
end;
{ @end $799B88 }

{ @routine $799BBC TStringsEC_Add }
procedure TStringsEC.Add(const Text: WideString);
begin
  AddEmptyElement.Text := Text;
end;
{ @end $799BBC }

{ @routine $799BD8 TStringsEC_AddSlice }
procedure TStringsEC.AddSlice(Text: PWideChar; CharCount: Integer);
var Item: TStringsElEC;
begin
  Item := AddEmptyElement;
  if CharCount > 0 then
  begin
    SetLength(Item.Text, CharCount);
    CopyMemory(PWideChar(Item.Text), Text, CharCount * SizeOf(WideChar));
  end;
end;
{ @end $799BD8 }

{ @routine $799C0C TStringsEC_Delete }
procedure TStringsEC.Delete(Index: Integer);
var Item: TStringsElEC;
begin
  Item := GetElement(Index);
  if Item = CurrentElement then
  begin
    CurrentElement := Item.Next;
    if CurrentElement = nil then CurrentElement := Item.Prev;
  end;
  RemoveAndFreeElement(Item);
end;
{ @end $799C0C }

{ @routine $799C38 TStringsEC_GetCurrentText }
function TStringsEC.GetCurrentText: WideString;
begin
  if CurrentElement = nil then raise Exception.Create('TStringsEC.Get.');
  Result := CurrentElement.Text;
end;
{ @end $799C38 }

{ @routine $799C84 TStringsEC_GetCurrentData }
function TStringsEC.GetCurrentData: Pointer;
begin
  if CurrentElement = nil then raise Exception.Create('TStringsEC.GetData.');
  Result := CurrentElement.Data;
end;
{ @end $799C84 }

{ @routine $799CC4 TStringsEC_IsAtEnd }
function TStringsEC.IsAtEnd: Boolean;
begin
  if CurrentElement <> nil then Result := False else Result := True;
end;
{ @end $799CC4 }

{ @routine $799CD0 TStringsEC_IsAtLast }
function TStringsEC.IsAtLast: Boolean;
begin
  if CurrentElement.Next <> nil then Result := False else Result := True;
end;
{ @end $799CD0 }

{ @routine $799CE0 TStringsEC_First }
procedure TStringsEC.First;
begin
  CurrentElement := FirstElement;
end;
{ @end $799CE0 }

{ @routine $799CE8 TStringsEC_Next }
procedure TStringsEC.Next;
begin
  CurrentElement := CurrentElement.Next;
end;
{ @end $799CE8 }

{ @routine $799CF4 TStringsEC_IsEmpty }
function TStringsEC.IsEmpty: Boolean;
begin
  Result := FirstElement = nil;
end;
{ @end $799CF4 }

{ @routine $799CFC TStringsEC_SetText }
procedure TStringsEC.SetText(const Text: WideString);
var Cursor, Start: PWideChar;
begin
  Clear;
  Cursor := PWideChar(Text);
  if Cursor = nil then Exit;
  while Cursor^ <> #0 do
  begin
    Start := Cursor;
    while (Cursor^ <> #0) and (Cursor^ <> #10) and (Cursor^ <> #13) do Inc(Cursor);
    AddSlice(Start, Cursor - Start);
    if Cursor^ = #13 then Inc(Cursor);
    if Cursor^ = #10 then Inc(Cursor);
  end;
end;
{ @end $799CFC }

{ @routine $799D68 TStringsEC_GetText }
function TStringsEC.GetText: WideString;
var Item: TStringsElEC;
begin
  Item := FirstElement;
  Result := '';
  while Item <> nil do
  begin
    if Item.Next = nil then Result := Result + Item.Text
    else Result := Result + Item.Text + #13 + #10;
    Item := Item.Next;
  end;
end;
{ @end $799D68 }

{ @routine $799DC4 CountDelimitedPartsW }
function CountDelimitedPartsW(const Text: WideString; const Delimiters: WideString): Integer;
var TextLength, DelimiterCount, i, j, Count: Integer;
begin
  Count := 1;
  TextLength := Length(Text);
  DelimiterCount := Length(Delimiters);
  if Cardinal(TextLength) < 1 then
  begin
    Result := 0;
    Exit;
  end;
  for i := 1 to TextLength do
    for j := 1 to DelimiterCount do
      if Text[i] = Delimiters[j] then
      begin
        Inc(Count);
        Break;
      end;
  Result := Count;
end;
{ @end $799DC4 }

{ @routine $799E34 GetDelimitedPartStartIndexW }
function GetDelimitedPartStartIndexW(const Text: WideString; PartIndex: Integer; const Delimiters: WideString): Integer;
var TextLength, DelimiterCount, i, j: Integer;
begin
  if PartIndex > 0 then
  begin
    TextLength := Length(Text);
    DelimiterCount := Length(Delimiters);
    for i := 1 to TextLength do
      for j := 1 to DelimiterCount do
        if Text[i] = Delimiters[j] then
        begin
          Dec(PartIndex);
          if PartIndex = 0 then
          begin
            Result := i + 1;
            Exit;
          end;
          Break;
        end;
    raise Exception.Create('GetSmeParEC. Str=' + Text + ' np=' + SysUtils.IntToStr(PartIndex) + ' raz=' + Delimiters);
  end;
  Result := 1;
end;
{ @end $799E34 }

{ @routine $799FA4 GetCharDelimitedPartStartIndexW }
function GetCharDelimitedPartStartIndexW(const Text: WideString; PartIndex: Integer; Delimiter: WideChar): Integer;
var TextLength, i: Integer;
begin
  if PartIndex > 0 then
  begin
    TextLength := Length(Text);
    for i := 1 to TextLength do
      if Text[i] = Delimiter then
      begin
        Dec(PartIndex);
        if PartIndex = 0 then
        begin
          Result := i + 1;
          Exit;
        end;
        Break;
      end;
    Result := -1;
    Exit;
  end;
  Result := 1;
end;
{ @end $799FA4 }

{ @routine $799FE4 GetDelimitedPartLengthW }
function GetDelimitedPartLengthW(const Text: WideString; StartIndex: Integer; const Delimiters: WideString): Integer;
var TextLength, DelimiterCount, i, j: Integer;
begin
  TextLength := Length(Text);
  DelimiterCount := Length(Delimiters);
  for i := StartIndex to TextLength do
    for j := 1 to DelimiterCount do
      if Text[i] = Delimiters[j] then
      begin
        Result := i - StartIndex;
        Exit;
      end;
  Result := TextLength - StartIndex + 1;
end;
{ @end $799FE4 }

{ @routine $79A054 ExtractDelimitedPartW }
function ExtractDelimitedPartW(const Text: WideString; PartIndex: Integer; const Delimiters: WideString): WideString;
var StartIndex: Integer;
begin
  StartIndex := GetDelimitedPartStartIndexW(Text, PartIndex, Delimiters);
  Result := Copy(Text, StartIndex, GetDelimitedPartLengthW(Text, StartIndex, Delimiters));
end;
{ @end $79A054 }

{ @routine $79A094 ExtractDelimitedRangeW }
function ExtractDelimitedRangeW(const Text: WideString; FirstPart: Integer; LastPart: Integer; const Delimiters: WideString): WideString;
var StartIndex, EndIndex: Integer;
begin
  StartIndex := GetDelimitedPartStartIndexW(Text, FirstPart, Delimiters);
  EndIndex := GetDelimitedPartStartIndexW(Text, LastPart, Delimiters);
  Inc(EndIndex, GetDelimitedPartLengthW(Text, EndIndex, Delimiters));
  Result := Copy(Text, StartIndex, EndIndex - StartIndex);
end;
{ @end $79A094 }

{ @routine $79A0EC ExtractNextDelimitedPartW }
function ExtractNextDelimitedPartW(var Text: WideString; Delimiter: WideChar): WideString;
var StartIndex, i, TextLength: Integer;
begin
  StartIndex := GetCharDelimitedPartStartIndexW(Text, 1, Delimiter);
  if StartIndex < 0 then
  begin
    Result := Text;
    Text := '';
    Exit;
  end;
  if StartIndex >= 3 then Result := Copy(Text, 1, StartIndex - 2)
  else Result := '';
  TextLength := Length(Text);
  for i := StartIndex to TextLength do Text[i - (StartIndex - 1)] := Text[i];
  SetLength(Text, TextLength - (StartIndex - 1));
end;
{ @end $79A0EC }

{ @routine $79A17C ExtractLineCommentW }
function ExtractLineCommentW(const Text: WideString): WideString;
var Position, i: Integer;
begin
  Position := Pos('//', Text);
  if Position < 1 then
  begin
    Result := '';
    Exit;
  end;
  i := Position - 1;
  while i >= 1 do
  begin
    if (Text[i] <> ' ') and (Text[i] <> #9) and (Text[i] <> #13) and (Text[i] <> #10) then Break;
    Dec(i);
  end;
  Result := Copy(Text, i + 1, Length(Text) - i);
end;
{ @end $79A17C }

{ @routine $79A1F0 RemoveLineCommentW }
function RemoveLineCommentW(const Text: WideString): WideString;
var Position: Integer;
begin
  Position := Pos('//', Text);
  if Position < 1 then
  begin
    Result := Text;
    Exit;
  end;
  if Position = 1 then
  begin
    Result := '';
    Exit;
  end;
  Result := SysUtils.TrimRight(Copy(Text, 1, Position - 1));
end;
{ @end $79A1F0 }

{ @routine $79A284 IsIntegerTextW }
function IsIntegerTextW(const Text: WideString): Boolean;
var TextLength, i: Integer;
begin
  TextLength := Length(Text);
  if TextLength < 1 then
  begin
    Result := False;
    Exit;
  end;
  for i := 1 to TextLength do
    if ((Text[i] < '0') or (Text[i] > '9')) and (Text[i] <> '-') then
    begin
      Result := False;
      Exit;
    end;
  Result := True;
end;
{ @end $79A284 }

{ @routine $79A2CC ExtractDigitsToIntW }
function ExtractDigitsToIntW(const Text: WideString): Integer;
var TextLength, i: Integer;
begin
  Result := 0;
  TextLength := Length(Text);
  for i := 1 to TextLength do
    if (Integer(Text[i]) >= Ord('0')) and (Integer(Text[i]) <= Ord('9')) then
      Result := SysUtils.StrToInt(Text[i]) + Result * 10;
end;
{ @end $79A2CC }

{ @routine $79A360 ExtractSignedDigitsToIntW }
function ExtractSignedDigitsToIntW(const Text: WideString): Integer;
var TextLength, i: Integer; Negative: Boolean;
begin
  Result := 0;
  TextLength := Length(Text);
  Negative := False;
  for i := 1 to TextLength do
    if (Integer(Text[i]) >= Ord('0')) and (Integer(Text[i]) <= Ord('9')) then
      Result := SysUtils.StrToInt(Text[i]) + Result * 10
    else if (Integer(Text[i]) = Ord('-')) and (Result = 0) then Negative := True;
  if Negative then Result := -Result;
end;
{ @end $79A360 }

{ @routine $79A414 ExtractDecimalToSingleW }
function ExtractDecimalToSingleW(const Text: WideString): Single;
var i, TextLength: Integer; Value, Divisor: Single; Code: Integer;
begin
  TextLength := Length(Text);
  if TextLength < 1 then
  begin
    Result := 0;
    Exit;
  end;
  Value := 0;
  for i := 0 to TextLength - 1 do
  begin
    Code := Ord(Text[i + 1]);
    if (Code >= Ord('0')) and (Code <= Ord('9')) then Value := Value * 10 + (Code - Ord('0'))
    else if (Code = Ord('.')) or (Code = Ord(',')) then Break;
  end;
  Inc(i);
  Divisor := 10;
  while i < TextLength do
  begin
    Code := Ord(Text[i + 1]);
    if (Code >= Ord('0')) and (Code <= Ord('9')) then
    begin
      Value := (Code - Ord('0')) / Divisor + Value;
      Divisor := Divisor * 10;
    end;
    Inc(i);
  end;
  for i := 0 to TextLength - 1 do
    if Integer(Text[i + 1]) = Ord('-') then
    begin
      Value := -Value;
      Break;
    end;
  Result := Value;
end;
{ @end $79A414 }

{ @routine $79A4FC ParseDecimalToSingleW }
function ParseDecimalToSingleW(const Text: WideString): Single;
var i, TextLength: Integer; Value, Divisor: Single; Code: Integer;
begin
  TextLength := Length(Text);
  if TextLength < 1 then
  begin
    Result := 0;
    Exit;
  end;
  Value := 0;
  for i := 0 to TextLength - 1 do
  begin
    Code := Ord(Text[i + 1]);
    if (Code >= Ord('0')) and (Code <= Ord('9')) then Value := Value * 10 + (Code - Ord('0'))
    else if (Code = Ord('.')) or (Code = Ord(',')) then Break;
  end;
  Inc(i);
  Divisor := 10;
  while i < TextLength do
  begin
    Code := Ord(Text[i + 1]);
    if (Code >= Ord('0')) and (Code <= Ord('9')) then
    begin
      Value := (Code - Ord('0')) / Divisor + Value;
      Divisor := Divisor * 10;
    end;
    Inc(i);
  end;
  for i := 0 to TextLength - 1 do
    if Integer(Text[i + 1]) = Ord('-') then
    begin
      Value := -Value;
      Break;
    end;
  Result := Value;
end;
{ @end $79A4FC }

{ @routine $79A5E4 FloatToWideString }
function FloatToWideString(Value: Double): WideString;
var SavedSeparator: AnsiChar;
begin
  SavedSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  Result := SysUtils.FloatToStr(Value);
  DecimalSeparator := SavedSeparator;
end;
{ @end $79A5E4 }

{ @routine $79A654 ReplaceAllWideString }
function ReplaceAllWideString(const Text, Search, Replacement: WideString): WideString;
var TextLength, SearchLength, i, j: Integer;
begin
  Result := '';
  TextLength := Length(Text);
  SearchLength := Length(Search);
  if (TextLength < SearchLength) or (TextLength < 1) or (SearchLength < 1) then
  begin
    Result := Text;
    Exit;
  end;
  i := 0;
  while i <= TextLength - SearchLength do
  begin
    j := 0;
    while j < SearchLength do
    begin
      if Text[i + j + 1] <> Search[j + 1] then Break;
      Inc(j);
    end;
    if j >= SearchLength then
    begin
      Result := Result + Replacement;
      Inc(i, SearchLength);
    end
    else
    begin
      Result := Result + Text[i + 1];
      Inc(i);
    end;
  end;
  if i < TextLength then Result := Result + Copy(Text, i + 1, TextLength - i);
end;
{ @end $79A654 }

{ @routine $79A76C CardinalToHexWideString }
function CardinalToHexWideString(Value: Cardinal): WideString;
begin
  Result := '';
  while Value <> 0 do
  begin
    Result := HexDigits[Value - (Value div 16) * 16] + Result;
    Value := Value div 16;
  end;
  if Result = '' then Result := '0';
end;
{ @end $79A76C }

{ @routine $79A80C IntToFixedWidthWideString }
function IntToFixedWidthWideString(Value, Width: Integer): WideString;
var Digit, i, TextLength: Integer;
begin
  Result := '';
  while Value > 0 do
  begin
    Digit := Value;
    Value := Value div 10;
    Dec(Digit, Value * 10);
    Result := Chr(Digit + Ord('0')) + Result;
  end;
  TextLength := Length(Result);
  if TextLength < Width then
    for i := 0 to Width - TextLength - 1 do Result := '0' + Result
  else Result := Copy(Result, 0, Width);
end;
{ @end $79A80C }

{ @routine $79A8D0 IntToWideString }
function IntToWideString(Value: Integer): WideString;
var Magnitude: Integer;
begin
  Result := '';
  Magnitude := Abs(Value);
  while Magnitude > 0 do
  begin
    Result := Chr(Magnitude mod 10 + Ord('0')) + Result;
    Magnitude := Magnitude div 10;
  end;
  if Result = '' then Result := '0';
  if Value < 0 then Result := '-' + Result;
end;
{ @end $79A8D0 }

{ @routine $79A98C BoolToWideString }
function BoolToWideString(Value: Boolean): WideString;
begin
  if not Value then Result := 'False' else Result := 'True';
end;
{ @end $79A98C }

{ @routine $79A9D0 TrimWideString }
function TrimWideString(const Text: WideString): WideString;
var Code, TextLength, FirstIndex, LastIndex: Integer;
begin
  TextLength := Length(Text);
  FirstIndex := 0;
  while FirstIndex < TextLength do
  begin
    Code := Ord(Text[FirstIndex + 1]);
    if (Code <> Ord(' ')) and (Code <> 9) and (Code <> 13) and (Code <> 10) and (Code <> 0) then Break;
    Inc(FirstIndex);
  end;
  if FirstIndex >= TextLength then
  begin
    Result := '';
    Exit;
  end;
  LastIndex := TextLength - 1;
  while LastIndex >= 0 do
  begin
    Code := Ord(Text[LastIndex + 1]);
    if (Code <> Ord(' ')) and (Code <> 9) and (Code <> 13) and (Code <> 10) and (Code <> 0) then Break;
    Dec(LastIndex);
  end;
  if LastIndex < FirstIndex then
  begin
    Result := '';
    Exit;
  end;
  SetLength(Result, LastIndex - FirstIndex + 1);
  CopyMemory(PWideChar(Result), AddPointerOffset(PWideChar(Text), FirstIndex * SizeOf(WideChar)), (LastIndex - FirstIndex + 1) * SizeOf(WideChar));
end;
{ @end $79A9D0 }

{ @routine $79AA88 UpperCaseWideString }
function UpperCaseWideString(const Text: WideString): WideString;
var TextLength, PairCount, i, j: Integer;
begin
  Result := Text;
  TextLength := Length(Result);
  PairCount := High(WideCaseTable) + 1;
  for i := 0 to TextLength - 1 do
    for j := 0 to PairCount - 1 do
      if Result[i + 1] = WideCaseTable[j].LowerChar then
      begin
        Result[i + 1] := WideCaseTable[j].UpperChar;
        Break;
      end;
end;
{ @end $79AA88 }

{ @routine $79AB04 LowerCaseWideString }
function LowerCaseWideString(const Text: WideString): WideString;
var TextLength, PairCount, i, j: Integer;
begin
  Result := Text;
  TextLength := Length(Result);
  PairCount := High(WideCaseTable) + 1;
  for i := 0 to TextLength - 1 do
    for j := 0 to PairCount - 1 do
      if Result[i + 1] = WideCaseTable[j].UpperChar then
      begin
        Result[i + 1] := WideCaseTable[j].LowerChar;
        Break;
      end;
end;
{ @end $79AB04 }

{ @routine $79AB7C RemoveWideStringChars }
function RemoveWideStringChars(const Text: WideString; Chars: WideString): WideString;
var TextLength, CharsLength, i, j, Count: Integer;
  Changed, Found: Boolean;
  Current: WideChar;
begin
  Changed := False;
  Result := Text;
  TextLength := Length(Result);
  CharsLength := Length(Chars);
  Count := 0;
  for i := 1 to TextLength do
  begin
    Current := Result[i];
    Found := False;
    for j := 1 to CharsLength do
      if Chars[j] = Current then
      begin
        Found := True;
        Break;
      end;
    if Found then Changed := True
    else
    begin
      Inc(Count);
      if Changed then Result[Count] := Current;
    end;
  end;
  if Changed then
    if Count > 0 then Result := CopyWideStringUnchecked(Result, 1, Count)
    else Result := '';
end;
{ @end $79AB7C }

{ @routine $79AC90 GetTextTagLengthW }
function GetTextTagLengthW(Text: PWideChar; CharCount: Integer): Integer;
var i: Integer;
begin
  Result := 0;
  if (CharCount < 2) or (Text[0] <> '<') then Exit;
  if Text[1] = '<' then
  begin
    Result := 1;
    Exit;
  end;
  i := 1;
  while i < CharCount do
  begin
    if Text[i] = '>' then Break;
    Inc(i);
  end;
  if i < CharCount then Result := i + 1;
end;
{ @end $79AC90 }

{ @routine $79ACCC MatchTextTagPrefixW }
function MatchTextTagPrefixW(Text: PWideChar; CharCount: Integer; const Pattern, AlternatePattern: WideString): Boolean;
var i, PatternLength: Integer;
begin
  Result := False;
  PatternLength := Length(Pattern);
  if Length(AlternatePattern) <> PatternLength then Exit;
  if PatternLength + 1 > CharCount then Exit;
  if Text[0] <> '<' then Exit;
  for i := 0 to PatternLength - 1 do
    if (Text[1 + i] <> Pattern[1 + i]) and (Text[1 + i] <> AlternatePattern[1 + i]) then Exit;
  Result := True;
end;
{ @end $79ACCC }

{ @routine $79AD4C RemoveTextTagsW }
function RemoveTextTagsW(const Text: WideString): WideString;
var i, TagLength: Integer;
begin
  Result := '';
  i := 0;
  while i < Length(Text) do
  begin
    TagLength := GetTextTagLengthW(PWideChar(Text) + i, Length(Text) - i);
    if TagLength > 0 then Inc(i, TagLength)
    else
    begin
      Result := Result + Text[Succ(i)];
      Inc(i);
    end;
  end;
end;
{ @end $79AD4C }

{ @routine $79ADEC RemoveMatchingTextTagsW }
function RemoveMatchingTextTagsW(Text: WideString; const Pattern, AlternatePattern: WideString): WideString;
var i, TagLength: Integer;
begin
  Result := '';
  i := 0;
  while i < Length(Text) do
  begin
    TagLength := GetTextTagLengthW(PWideChar(Text) + i, Length(Text) - i);
    if TagLength > 0 then
    begin
      if MatchTextTagPrefixW(PWideChar(Text) + i, Length(Text) - i, Pattern, AlternatePattern) then Inc(i, TagLength)
      else
      begin
        Result := Result + Copy(Text, i + 1, TagLength);
        Inc(i, TagLength);
      end;
    end
    else
    begin
      Result := Result + Text[i + 1];
      Inc(i);
    end;
  end;
end;
{ @end $79ADEC }

{ @routine $79AF00 CompareWideChars }
function CompareWideChars(Left, Right: PWideChar): Integer; cdecl;
asm
  PUSH ESI
  PUSH EDI
  PUSH EBX
  PUSH EDX
  MOV ESI, Left
  MOV EDI, Right
  TEST ESI, ESI
  JNZ @@HaveLeft
  MOV EAX, -1
  TEST EDI, EDI
  JNZ @@Done
  XOR EAX, EAX
  JMP @@Done
@@HaveLeft:
  TEST EDI, EDI
  JNZ @@Next
  MOV EAX, 1
  JMP @@Done
@@Next:
  MOV BX, [ESI]
  MOV DX, [EDI]
  ADD ESI, 2
  ADD EDI, 2
  CMP BX, DX
  JNZ @@Different
  XOR EAX, EAX
  TEST DX, DX
  JNZ @@Next
  JMP @@Done
@@Different:
  MOV EAX, 1
  JA @@Done
  MOV EAX, -1
@@Done:
  POP EDX
  POP EBX
  POP EDI
  POP ESI
end;
{ @end $79AF00 }

{ @routine $79AF58 FindTextOffsetW }
function FindTextOffsetW(const Text, Search: WideString; StartIndex: Integer): Integer;
var TextLength, SearchLength: Integer; TextPtr, SearchPtr: PWideChar;
begin
  TextLength := Length(Text);
  SearchLength := Length(Search);
  if TextLength - StartIndex < SearchLength then
  begin
    Result := -1;
    Exit;
  end;
  if (TextLength < 1) and (SearchLength < 1) then
  begin
    Result := -1;
    Exit;
  end;
  TextPtr := PWideChar(Text);
  SearchPtr := PWideChar(Search);
  if SearchLength = 1 then
  begin
    while StartIndex <= TextLength - SearchLength do
    begin
      if PWideChar(StartIndex * SizeOf(WideChar) + PAnsiChar(TextPtr))^ = SearchPtr^ then
      begin
        Result := StartIndex;
        Exit;
      end;
      Inc(StartIndex);
    end;
  end
  else
    while StartIndex <= TextLength - SearchLength do
    begin
      if SysUtils.CompareMem(Pointer(StartIndex * SizeOf(WideChar) + PAnsiChar(TextPtr)), SearchPtr, SearchLength * SizeOf(WideChar)) then
      begin
        Result := StartIndex;
        Exit;
      end;
      Inc(StartIndex);
    end;
  Result := -1;
end;
{ @end $79AF58 }

{ @routine $79B01C FindTextPosW }
function FindTextPosW(const Search, Text: WideString): Integer;
begin
  Result := FindTextOffsetW(Text, Search) + 1;
end;
{ @end $79B01C }

{ @routine $79B034 ExtractFileNameNoExtW }
function ExtractFileNameNoExtW(const Path: WideString): WideString;
var Count: Integer;
begin
  Count := CountDelimitedPartsW(Path, '\/');
  Result := ExtractDelimitedPartW(Path, Count - 1, '\/');
  Count := CountDelimitedPartsW(Result, '.');
  if Count > 1 then Result := ExtractDelimitedRangeW(Result, 0, Count - 2, '.');
end;
{ @end $79B034 }

{ @routine $79B0D8 ExtractFileExtNoDotW }
function ExtractFileExtNoDotW(const Path: WideString): WideString;
var Count: Integer;
begin
  Count := CountDelimitedPartsW(Path, '\/');
  Result := ExtractDelimitedPartW(Path, Count - 1, '\/');
  Count := CountDelimitedPartsW(Result, '.');
  if Count > 1 then Result := ExtractDelimitedPartW(Result, Count - 1, '.')
  else Result := '';
end;
{ @end $79B0D8 }

{ @routine $79B180 ExtractFileDirW }
function ExtractFileDirW(const Path: WideString): WideString;
var Count: Integer;
begin
  Count := CountDelimitedPartsW(Path, '\/');
  if Count <= 1 then
  begin
    Result := '';
    Exit;
  end;
  Result := ExtractDelimitedRangeW(Path, 0, Count - 2, '\/');
end;
{ @end $79B180 }

{ @routine $79B1C8 WriteRegistryStringLegacy }
procedure WriteRegistryStringLegacy(RootKey: Cardinal; KeyPath, ValueName, Value: WideString);
var Key: HKEY;
    Disposition: Cardinal;
    AnsiValue: AnsiString;
begin
  if Windows.RegCreateKeyExW(RootKey, PWideChar(KeyPath), 0, nil, 0, KEY_WRITE, nil, Key, @Disposition) <> ERROR_SUCCESS then Exit;
  AnsiValue := Value;
  if Windows.RegSetValueExW(Key, PWideChar(ValueName), 0, REG_SZ, PAnsiChar(AnsiValue), Length(AnsiValue) + 1) <> ERROR_SUCCESS then
  begin
    Windows.RegCloseKey(Key);
    Exit;
  end;
  Windows.RegCloseKey(Key);
end;
{ @end $79B1C8 }

{ @routine $79B2B4 DecodeTextW }
function DecodeTextW(Text: WideString): WideString;
var i, TextLength: Integer;
begin
  TextLength := Length(Text);
  Result := '';
  i := 0;
  while i < TextLength do
  begin
    Result := Result + Text[i + 1];
    Inc(i, 2);
  end;
end;
{ @end $79B2B4 }

{ @routine $79B340 EncodeTextW }
function EncodeTextW(Text: WideString): WideString;
var i, TextLength, LastPair: Integer;
begin
  TextLength := Length(Text);
  LastPair := High(WideCaseTable);
  Result := '';
  i := 0;
  while i < TextLength do
  begin
    Result := Result + Text[i + 1];
    if Random(10) >= 8 then Result := Result + WideCaseTable[Random(LastPair + 1)].UpperChar
    else Result := Result + WideCaseTable[Random(LastPair + 1)].LowerChar;
    Inc(i);
  end;
end;
{ @end $79B340 }

{ @routine $79B440 TransliterateCyrillicToLatin }
function TransliterateCyrillicToLatin(Text: WideString): WideString;
begin
  Result := Text;
  Result := ReplaceAllWideString(Result, 'А', 'A');
  Result := ReplaceAllWideString(Result, 'а', 'a');
  Result := ReplaceAllWideString(Result, 'Б', 'B');
  Result := ReplaceAllWideString(Result, 'б', 'b');
  Result := ReplaceAllWideString(Result, 'В', 'V');
  Result := ReplaceAllWideString(Result, 'в', 'v');
  Result := ReplaceAllWideString(Result, 'Г', 'G');
  Result := ReplaceAllWideString(Result, 'г', 'g');
  Result := ReplaceAllWideString(Result, 'Д', 'D');
  Result := ReplaceAllWideString(Result, 'д', 'd');
  Result := ReplaceAllWideString(Result, 'Е', 'E');
  Result := ReplaceAllWideString(Result, 'е', 'e');
  Result := ReplaceAllWideString(Result, 'Ё', 'Yo');
  Result := ReplaceAllWideString(Result, 'ё', 'yo');
  Result := ReplaceAllWideString(Result, 'Ж', 'Zh');
  Result := ReplaceAllWideString(Result, 'ж', 'zh');
  Result := ReplaceAllWideString(Result, 'З', 'Z');
  Result := ReplaceAllWideString(Result, 'з', 'z');
  Result := ReplaceAllWideString(Result, 'И', 'I');
  Result := ReplaceAllWideString(Result, 'и', 'i');
  Result := ReplaceAllWideString(Result, 'Й', 'J');
  Result := ReplaceAllWideString(Result, 'й', 'j');
  Result := ReplaceAllWideString(Result, 'К', 'K');
  Result := ReplaceAllWideString(Result, 'к', 'k');
  Result := ReplaceAllWideString(Result, 'Л', 'L');
  Result := ReplaceAllWideString(Result, 'л', 'l');
  Result := ReplaceAllWideString(Result, 'М', 'M');
  Result := ReplaceAllWideString(Result, 'м', 'm');
  Result := ReplaceAllWideString(Result, 'Н', 'N');
  Result := ReplaceAllWideString(Result, 'н', 'n');
  Result := ReplaceAllWideString(Result, 'О', 'O');
  Result := ReplaceAllWideString(Result, 'о', 'o');
  Result := ReplaceAllWideString(Result, 'П', 'P');
  Result := ReplaceAllWideString(Result, 'п', 'p');
  Result := ReplaceAllWideString(Result, 'Р', 'R');
  Result := ReplaceAllWideString(Result, 'р', 'r');
  Result := ReplaceAllWideString(Result, 'С', 'S');
  Result := ReplaceAllWideString(Result, 'с', 's');
  Result := ReplaceAllWideString(Result, 'Т', 'T');
  Result := ReplaceAllWideString(Result, 'т', 't');
  Result := ReplaceAllWideString(Result, 'У', 'U');
  Result := ReplaceAllWideString(Result, 'у', 'u');
  Result := ReplaceAllWideString(Result, 'Ф', 'F');
  Result := ReplaceAllWideString(Result, 'ф', 'f');
  Result := ReplaceAllWideString(Result, 'Х', 'Kh');
  Result := ReplaceAllWideString(Result, 'х', 'kh');
  Result := ReplaceAllWideString(Result, 'Ц', 'Ts');
  Result := ReplaceAllWideString(Result, 'ц', 'ts');
  Result := ReplaceAllWideString(Result, 'Ч', 'Ch');
  Result := ReplaceAllWideString(Result, 'ч', 'ch');
  Result := ReplaceAllWideString(Result, 'Ш', 'Sh');
  Result := ReplaceAllWideString(Result, 'ш', 'sh');
  Result := ReplaceAllWideString(Result, 'Щ', 'Shh');
  Result := ReplaceAllWideString(Result, 'щ', 'shh');
  Result := ReplaceAllWideString(Result, 'Ъ', '"');
  Result := ReplaceAllWideString(Result, 'ъ', '"');
  Result := ReplaceAllWideString(Result, 'Ы', 'Y');
  Result := ReplaceAllWideString(Result, 'ы', 'y');
  Result := ReplaceAllWideString(Result, 'Ь', '`');
  Result := ReplaceAllWideString(Result, 'ь', '`');
  Result := ReplaceAllWideString(Result, 'Э', 'E');
  Result := ReplaceAllWideString(Result, 'э', 'e');
  Result := ReplaceAllWideString(Result, 'Ю', 'Yu');
  Result := ReplaceAllWideString(Result, 'ю', 'yu');
  Result := ReplaceAllWideString(Result, 'Я', 'Ya');
  Result := ReplaceAllWideString(Result, 'я', 'ya');
end;
{ @end $79B440 }

{ @routine $79C1B8 CopyWideStringUnchecked }
function CopyWideStringUnchecked(Text: WideString; Index, Count: Integer): WideString;
begin
  SetLength(Result, Count);
  CopyMemory(PWideChar(Result), AddPointerOffset(PWideChar(Text), Index * SizeOf(WideChar) - SizeOf(WideChar)), Count * SizeOf(WideChar));
end;
{ @end $79C1B8 }

end.
