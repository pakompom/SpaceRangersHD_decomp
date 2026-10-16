unit CPVarClass;

interface

uses CPDiapClass, EC_Struct;

const
  // Arithmetic saturation and numeric-conversion limit; also used on zero division.
  QuestNumericLimit = 2000000000;

type
  TQuestNumberKind = (number_ranges = 0, number_float = 1,
    number_integer = 2); // @size 0x01

  TCPVariant = class(TObjectEx) // @size 0x1C
  public
    Range: TCPDiapazone; // @offset 0x04  Owned for every ValueKind.
    FloatValue: Extended; // @offset 0x08
    IntValue: Integer; // @offset 0x14
    ValueKind: TQuestNumberKind; // @offset 0x18

    constructor Create; // @addr 0x004DC4A8
    destructor Destroy; override; // @addr 0x004DC4F4
    procedure Reset; // @addr 0x004DC530 @note "Resets to integer zero; retains the range object."
    procedure Assign(Source: TCPVariant; FreeSource: Boolean); // @addr 0x004DC554 @note "Deep-copies the range."
    function TryLoadFromText(Text: WideString): Boolean; // @addr 0x004DC598 @note "Comma decimals use Single precision; uppercase E is ignored. Ranges require h, not '..'. Failure preserves the value; empty text becomes zero."
    function HasNumericChars(var Text: WideString; TextLength: Integer): Boolean; // @addr 0x004DC6F0 @note "Permits digits, comma and uppercase E; not a syntax check."
    function HasIntegerChars(var Text: WideString; TextLength: Integer): Boolean; // @addr 0x004DC72C @note "Permits digits and uppercase E; not a syntax check."
    // Numeric conversions resample ranges; unknown tags return zero.
    function AsExtended: Extended; // @addr 0x004DC764
    function AsInteger: Integer; // @addr 0x004DC7C8 @note "Float conversion clamps at +/-2000000000; within bounds, uses System.Round(value + 1E-11)."
  end;

implementation

uses EC_Str;

{ @routine $4DC4A8 TCPVariant_Create }
constructor TCPVariant.Create;
begin
  inherited Create;
  Range := TCPDiapazone.Create;
  Reset;
end;
{ @end $4DC4A8 }

{ @routine $4DC4F4 TCPVariant_Destroy }
destructor TCPVariant.Destroy;
begin
  Reset;
  Range.Free;
  Range := nil;
  inherited Destroy;
end;
{ @end $4DC4F4 }

{ @routine $4DC530 TCPVariant_Reset }
procedure TCPVariant.Reset;
begin
  FloatValue := 0;
  IntValue := 0;
  Range.Clear;
  ValueKind := number_integer;
end;
{ @end $4DC530 }

{ @routine $4DC554 TCPVariant_Assign }
procedure TCPVariant.Assign(Source: TCPVariant; FreeSource: Boolean);
begin
  Range.Assign(Source.Range);
  FloatValue := Source.FloatValue;
  IntValue := Source.IntValue;
  ValueKind := Source.ValueKind;
  if FreeSource then Source.Free;
end;
{ @end $4DC554 }

{ @routine $4DC598 TCPVariant_TryLoadFromText }
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
      ValueKind := number_integer;
      Range.Clear;
      IntValue := ExtractDigitsToIntW(Text);
      FloatValue := 0;
      Result := True;
    end
    else
    begin
      ValueKind := number_float;
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
    ValueKind := number_ranges;
    Range.LoadFromText(Text);
    FloatValue := 0;
    IntValue := 0;
    Result := True;
  end;
end;
{ @end $4DC598 }

{ @routine $4DC6F0 TCPVariant_HasNumericChars }
function TCPVariant.HasNumericChars(var Text: WideString; TextLength: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to TextLength do
    if ((Text[i] < '0') or (Text[i] > '9')) and (Text[i] <> ',') and (Text[i] <> 'E') then Exit;
  Result := True;
end;
{ @end $4DC6F0 }

{ @routine $4DC72C TCPVariant_HasIntegerChars }
function TCPVariant.HasIntegerChars(var Text: WideString; TextLength: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to TextLength do
    if ((Text[i] < '0') or (Text[i] > '9')) and (Text[i] <> 'E') then Exit;
  Result := True;
end;
{ @end $4DC72C }

{ @routine $4DC764 TCPVariant_AsExtended }
function TCPVariant.AsExtended: Extended;
begin
  Result := 0;
  if ValueKind = number_ranges then Result := Range.GetRandomValue
  else if ValueKind = number_float then Result := FloatValue
  else if ValueKind = number_integer then Result := IntValue;
end;
{ @end $4DC764 }

{ @routine $4DC7C8 TCPVariant_AsInteger }
function TCPVariant.AsInteger: Integer;
begin
  Result := 0;
  if ValueKind = number_ranges then Result := Range.GetRandomValue
  else if ValueKind = number_float then
  begin
    if FloatValue < -QuestNumericLimit then Result := -QuestNumericLimit
    else if FloatValue > QuestNumericLimit then Result := QuestNumericLimit
    else Result := System.Round(FloatValue + 1E-11);
  end
  else if ValueKind = number_integer then Result := IntValue;
end;
{ @end $4DC7C8 }

end.
