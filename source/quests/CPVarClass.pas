unit CPVarClass;
// Unit bracket (inferred): .text 0x004DB9A4..0x004DBEC2; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses CPDiapClass, EC_Struct;

type
  TCPValueKind = (cpvkRange = 0, cpvkFloat = 1,
    cpvkInteger = 2); // @size 0x01

  TCPVariant = class(TObjectEx) // @size 0x1C
  public
    Range: TCPDiapazone; // @offset 0x04  Owned for every ValueKind.
    FloatValue: Extended; // @offset 0x08
    IntValue: Integer; // @offset 0x14
    ValueKind: TCPValueKind; // @offset 0x18

    constructor Create; // @addr 0x4DB9FC @ida "TCPVariant *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4DBA58 @ida "void __usercall $name(TCPVariant *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Reset; // @addr 0x4DBAA4 @note "Resets to integer zero; retains the range object."
    procedure Assign(Source: TCPVariant; FreeSource: Boolean); // @addr 0x4DBAD8 @note "Deep-copies the range."
    function TryLoadFromText(Text: WideString): Boolean; // @addr 0x4DBB3C @note "Comma decimals use Single precision; uppercase E is ignored. Ranges require h, not '..'. Failure preserves the value; empty text becomes zero."
    function HasNumericChars(var Text: WideString; TextLength: Integer): Boolean; // @addr 0x4DBCD8 @note "Permits digits, comma and uppercase E; not a syntax check."
    function HasIntegerChars(var Text: WideString; TextLength: Integer): Boolean; // @addr 0x4DBD50 @note "Permits digits and uppercase E; not a syntax check."
    // Numeric conversions resample ranges; unknown tags return zero.
    function AsExtended: Extended; // @addr 0x4DBDB8 @ida "double __usercall $name@<st0>(TCPVariant *Self@<eax>);"
    function AsInteger: Integer; // @addr 0x4DBE2C @note "Float conversion clamps at +/-2000000000; within bounds, uses System.Round(value + 1E-11)."
  end;

implementation

uses EC_Str;

{ @routine $4DB9FC TCPVariant_Create }
constructor TCPVariant.Create;
begin
  inherited Create;
  Range := TCPDiapazone.Create;
  Reset;
end;
{ @end $4DB9FC }

{ @routine $4DBA58 TCPVariant_Destroy }
destructor TCPVariant.Destroy;
begin
  Reset;
  Range.Free;
  Range := nil;
  inherited Destroy;
end;
{ @end $4DBA58 }

{ @routine $4DBAA4 TCPVariant_Reset }
procedure TCPVariant.Reset;
begin
  FloatValue := 0;
  IntValue := 0;
  Range.Clear;
  ValueKind := cpvkInteger;
end;
{ @end $4DBAA4 }

{ @routine $4DBAD8 TCPVariant_Assign }
procedure TCPVariant.Assign(Source: TCPVariant; FreeSource: Boolean);
begin
  Range.Assign(Source.Range);
  FloatValue := Source.FloatValue;
  IntValue := Source.IntValue;
  ValueKind := Source.ValueKind;
  if FreeSource then Source.Free;
end;
{ @end $4DBAD8 }

{ @routine $4DBB3C TCPVariant_TryLoadFromText }
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
{ @end $4DBB3C }

{ @routine $4DBCD8 TCPVariant_HasNumericChars }
function TCPVariant.HasNumericChars(var Text: WideString; TextLength: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to TextLength do
    if ((Text[i] < '0') or (Text[i] > '9')) and (Text[i] <> ',') and (Text[i] <> 'E') then Exit;
  Result := True;
end;
{ @end $4DBCD8 }

{ @routine $4DBD50 TCPVariant_HasIntegerChars }
function TCPVariant.HasIntegerChars(var Text: WideString; TextLength: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to TextLength do
    if ((Text[i] < '0') or (Text[i] > '9')) and (Text[i] <> 'E') then Exit;
  Result := True;
end;
{ @end $4DBD50 }

{ @routine $4DBDB8 TCPVariant_AsExtended }
function TCPVariant.AsExtended: Extended;
begin
  Result := 0;
  if ValueKind = cpvkRange then Result := Range.GetRandomValue
  else if ValueKind = cpvkFloat then Result := FloatValue
  else if ValueKind = cpvkInteger then Result := IntValue;
end;
{ @end $4DBDB8 }

{ @routine $4DBE2C TCPVariant_AsInteger }
function TCPVariant.AsInteger: Integer;
begin
  Result := 0;
  if ValueKind = cpvkRange then Result := Range.GetRandomValue
  else if ValueKind = cpvkFloat then
  begin
    if FloatValue < -2000000000 then Result := -2000000000
    else if FloatValue > 2000000000 then Result := 2000000000
    else Result := System.Round(FloatValue + 1E-11);
  end
  else if ValueKind = cpvkInteger then Result := IntValue;
end;
{ @end $4DBE2C }

end.
