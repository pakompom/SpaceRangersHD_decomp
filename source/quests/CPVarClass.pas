unit CPVarClass;
// Unit bracket (inferred): .text 0x004DF774..0x004DFC92; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses CPDiapClass, EC_Struct;

const
  // Arithmetic saturation and numeric-conversion limit; also used on zero division.
  QuestNumericLimit = 2000000000;

type
  TCPValueKind = (cpvkRange = 0, cpvkFloat = 1,
    cpvkInteger = 2); // @size 0x01

  TCPVariant = class(TObjectEx) // @size 0x1C
  public
    Range: TCPDiapazone; // @offset 0x04  Owned for every ValueKind.
    FloatValue: Extended; // @offset 0x08
    IntValue: Integer; // @offset 0x14
    ValueKind: TCPValueKind; // @offset 0x18

    constructor Create; // @addr 0x4DF7CC
    destructor Destroy; override; // @addr 0x4DF828
    procedure Reset; // @addr 0x4DF874 @note "Resets to integer zero; retains the range object."
    procedure Assign(Source: TCPVariant; FreeSource: Boolean); // @addr 0x4DF8A8 @note "Deep-copies the range."
    function TryLoadFromText(Text: WideString): Boolean; // @addr 0x4DF90C @note "Comma decimals use Single precision; uppercase E is ignored. Ranges require h, not '..'. Failure preserves the value; empty text becomes zero."
    function HasNumericChars(var Text: WideString; TextLength: Integer): Boolean; // @addr 0x4DFAA8 @note "Permits digits, comma and uppercase E; not a syntax check."
    function HasIntegerChars(var Text: WideString; TextLength: Integer): Boolean; // @addr 0x4DFB20 @note "Permits digits and uppercase E; not a syntax check."
    // Numeric conversions resample ranges; unknown tags return zero.
    function AsExtended: Extended; // @addr 0x4DFB88
    function AsInteger: Integer; // @addr 0x4DFBFC @note "Float conversion clamps at +/-2000000000; within bounds, uses System.Round(value + 1E-11)."
  end;

implementation

uses EC_Str;

{ @routine $4DF7CC TCPVariant_Create }
constructor TCPVariant.Create;
begin
  inherited Create;
  Range := TCPDiapazone.Create;
  Reset;
end;
{ @end $4DF7CC }

{ @routine $4DF828 TCPVariant_Destroy }
destructor TCPVariant.Destroy;
begin
  Reset;
  Range.Free;
  Range := nil;
  inherited Destroy;
end;
{ @end $4DF828 }

{ @routine $4DF874 TCPVariant_Reset }
procedure TCPVariant.Reset;
begin
  FloatValue := 0;
  IntValue := 0;
  Range.Clear;
  ValueKind := cpvkInteger;
end;
{ @end $4DF874 }

{ @routine $4DF8A8 TCPVariant_Assign }
procedure TCPVariant.Assign(Source: TCPVariant; FreeSource: Boolean);
begin
  Range.Assign(Source.Range);
  FloatValue := Source.FloatValue;
  IntValue := Source.IntValue;
  ValueKind := Source.ValueKind;
  if FreeSource then Source.Free;
end;
{ @end $4DF8A8 }

{ @routine $4DF90C TCPVariant_TryLoadFromText }
function TCPVariant.TryLoadFromText(Text: WideString): Boolean;
var
  i, Count: Integer;
begin
  Result := False;
  Count := Length(Text);
  if Count = 0 then Text := '0';
  if HasNumericChars(Text, Count) then
  begin
    if HasIntegerChars(Text, Count) then
    begin
      ValueKind := cpvkInteger;
      Range.Clear;
      IntValue := ExtractDigitsToIntW(Text);
      FloatValue := 0;
      Result := True;
    end
    else
    begin
      ValueKind := cpvkFloat;
      Range.Clear;
      FloatValue := ExtractDecimalToSingleW(Text);
      IntValue := 0;
      Result := True;
    end;
  end
  else if (Count > 1) and (Text[1] = '[') and (Text[Count] = ']') then
  begin
    for i := 1 to Count do
      case Text[i] of
        '0'..'9', '[', ']', 'h', ';', '-': ;
      else Exit;
      end;
    ValueKind := cpvkRange;
    Range.LoadFromText(Text);
    FloatValue := 0;
    IntValue := 0;
    Result := True;
  end;
end;
{ @end $4DF90C }

{ @routine $4DFAA8 TCPVariant_HasNumericChars }
function TCPVariant.HasNumericChars(var Text: WideString; TextLength: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to TextLength do
    if ((Text[i] < '0') or (Text[i] > '9')) and (Text[i] <> ',') and (Text[i] <> 'E') then Exit;
  Result := True;
end;
{ @end $4DFAA8 }

{ @routine $4DFB20 TCPVariant_HasIntegerChars }
function TCPVariant.HasIntegerChars(var Text: WideString; TextLength: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to TextLength do
    if ((Text[i] < '0') or (Text[i] > '9')) and (Text[i] <> 'E') then Exit;
  Result := True;
end;
{ @end $4DFB20 }

{ @routine $4DFB88 TCPVariant_AsExtended }
function TCPVariant.AsExtended: Extended;
begin
  Result := 0;
  if ValueKind = cpvkRange then Result := Range.GetRandomValue
  else if ValueKind = cpvkFloat then Result := FloatValue
  else if ValueKind = cpvkInteger then Result := IntValue;
end;
{ @end $4DFB88 }

{ @routine $4DFBFC TCPVariant_AsInteger }
function TCPVariant.AsInteger: Integer;
begin
  Result := 0;
  if ValueKind = cpvkRange then Result := Range.GetRandomValue
  else if ValueKind = cpvkFloat then
  begin
    if FloatValue < -QuestNumericLimit then Result := -QuestNumericLimit
    else if FloatValue > QuestNumericLimit then Result := QuestNumericLimit
    else Result := System.Round(FloatValue + 1E-11);
  end
  else if ValueKind = cpvkInteger then Result := IntValue;
end;
{ @end $4DFBFC }

end.
