unit CPDiapClass;
// Unit bracket (inferred): .text 0x004DD770..0x004DE488; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Struct, ValueListClass;

type
  TCPDiapazone = class(TObjectEx) // @size 0x10
  public
    // Owned Delphi dynamic arrays, indexed 0..RangeCount-1; inclusive bounds.
    RangeStarts: array of Int64; // @offset 0x04
    RangeEnds: array of Int64; // @offset 0x08
    RangeCount: Integer; // @offset 0x0C

    constructor Create; // @addr 0x4DD828
    destructor Destroy; override; // @addr 0x4DD874
    procedure Clear; // @addr 0x4DD8B0
    procedure LoadFromReader(Reader: TBufEC); // @addr 0x4DD904
    procedure LoadFromText(Text: WideString); // @addr 0x4DE214 @note "Accepts [a..b;c] or [ahb;c]. Endpoints beyond +/-200000000 can expand intervals unexpectedly; '..' normalization can overread."
    procedure LoadFromValues(var Source: TValuesList); // @addr 0x4DDDF0 @note "Ignores Source.AcceptListed."
    procedure Assign(var Source: TCPDiapazone); // @addr 0x4DDEB0
    procedure Append(var Source: TCPDiapazone); // @addr 0x4DDF74 @note "Preserves overlapping and duplicate ranges."
    procedure AddRange(MinValue, MaxValue: Int64); // @addr 0x4DE068 @note "Swaps reversed bounds; does not merge ranges."
    procedure AddValue(Value: Extended); // @addr 0x4DE12C @note "Truncates to Int64; caught conversion errors preserve existing ranges."
    function GetMinimum: Int64; // @addr 0x4DD948 @note "Requires at least one range."
    function GetMaximum: Int64; // @addr 0x4DD9C0 @note "Requires at least one range."
    function Contains(Value: Extended): Boolean; // @addr 0x4DDC10 @note "Rounds with System.Round first."
    function GetRandomValue: Integer; // @addr 0x4DDA5C @note "Zero when empty. Sampling weights overlaps repeatedly; lengths and results are 32-bit."
    function ToText: WideString; // @addr 0x4DDC94 @note "Uses [ahb;c] and signed low 32-bit endpoints; empty output is '['."
  end;

implementation

uses EC_Str, SysUtils, TextFieldClass;

{ @routine $4DD828 TCPDiapazone_Create }
constructor TCPDiapazone.Create;
begin
  inherited Create;
  Clear;
end;
{ @end $4DD828 }

{ @routine $4DD874 TCPDiapazone_Destroy }
destructor TCPDiapazone.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $4DD874 }

{ @routine $4DD8B0 TCPDiapazone_Clear }
procedure TCPDiapazone.Clear;
begin
  RangeCount := 0;
  SetLength(RangeStarts, RangeCount);
  SetLength(RangeEnds, RangeCount);
end;
{ @end $4DD8B0 }

{ @routine $4DD904 TCPDiapazone_LoadFromReader }
procedure TCPDiapazone.LoadFromReader(Reader: TBufEC);
var
  Text: TTextField;
begin
  Text := TTextField.Create;
  Text.LoadTextLinesFromReader(Reader);
  LoadFromText(Text.Text);
  Text.Destroy;
end;
{ @end $4DD904 }

{ @routine $4DD948 TCPDiapazone_GetMinimum }
function TCPDiapazone.GetMinimum: Int64;
var
  i: Integer;
begin
  Result := RangeStarts[0];
  for i := 0 to RangeCount - 1 do
    if RangeStarts[i] <= Result then Result := RangeStarts[i];
end;
{ @end $4DD948 }

{ @routine $4DD9C0 TCPDiapazone_GetMaximum }
function TCPDiapazone.GetMaximum: Int64;
var
  i: Integer;
begin
  Result := RangeEnds[0];
  for i := 0 to RangeCount - 1 do
    if RangeEnds[i] >= Result then Result := RangeEnds[i];
end;
{ @end $4DD9C0 }

{ @routine $4DDA5C TCPDiapazone_GetRandomValue }
function TCPDiapazone.GetRandomValue: Integer;
var
  i, RandomValue: Integer;
  Ends, Starts: array of Int64;
begin
  Result := 0;
  if RangeCount > 0 then
  begin
    SetLength(Ends, RangeCount);
    SetLength(Starts, RangeCount);
    RandomValue := 0;
    for i := 0 to RangeCount - 1 do
    begin
      Starts[i] := RandomValue;
      Ends[i] := RangeEnds[i] - RangeStarts[i] + Starts[i];
      RandomValue := RandomValue + RangeEnds[i] - RangeStarts[i] + 1;
    end;
    RandomValue := System.Random(RandomValue);
    // Native scan includes RangeCount and draws again within the selected range.
    for i := 0 to RangeCount do
      if (RandomValue >= Starts[i]) and (RandomValue <= Ends[i]) then
      begin
        Result := System.Random(RangeEnds[i] - RangeStarts[i] + 1) + RangeStarts[i];
        Break;
      end;
  end;
end;
{ @end $4DDA5C }

{ @routine $4DDC10 TCPDiapazone_Contains }
function TCPDiapazone.Contains(Value: Extended): Boolean;
var
  i: Integer;
  Rounded: Int64;
begin
  Rounded := System.Round(Value);
  Result := True;
  for i := 0 to RangeCount - 1 do
    if (RangeStarts[i] <= Rounded) and (RangeEnds[i] >= Rounded) then Exit;
  Result := False;
end;
{ @end $4DDC10 }

{ @routine $4DDC94 TCPDiapazone_ToText }
function TCPDiapazone.ToText: WideString;
var
  i: Integer;
begin
  Result := '[';
  for i := 0 to RangeCount - 1 do
  begin
    if RangeStarts[i] = RangeEnds[i] then Result := Result + IntToWideString(RangeStarts[i])
    else Result := Result + IntToWideString(RangeStarts[i]) + 'h' + IntToWideString(RangeEnds[i]);
    if i < RangeCount - 1 then Result := Result + ';'
    else Result := Result + ']';
  end;
end;
{ @end $4DDC94 }

{ @routine $4DDDF0 TCPDiapazone_LoadFromValues }
procedure TCPDiapazone.LoadFromValues(var Source: TValuesList);
var
  i: Integer;
begin
  RangeCount := Source.Count;
  SetLength(RangeStarts, RangeCount);
  SetLength(RangeEnds, RangeCount);
  for i := 0 to RangeCount - 1 do
  begin
    RangeStarts[i] := Source.Values[i + 1];
    RangeEnds[i] := Source.Values[i + 1];
  end;
end;
{ @end $4DDDF0 }

{ @routine $4DDEB0 TCPDiapazone_Assign }
procedure TCPDiapazone.Assign(var Source: TCPDiapazone);
var
  i: Integer;
begin
  RangeCount := Source.RangeCount;
  SetLength(RangeStarts, RangeCount);
  SetLength(RangeEnds, RangeCount);
  for i := 0 to RangeCount - 1 do
  begin
    RangeStarts[i] := Source.RangeStarts[i];
    RangeEnds[i] := Source.RangeEnds[i];
  end;
end;
{ @end $4DDEB0 }

{ @routine $4DDF74 TCPDiapazone_Append }
procedure TCPDiapazone.Append(var Source: TCPDiapazone);
var
  i: Integer;
begin
  if Source.RangeCount > 0 then
  begin
    SetLength(RangeStarts, RangeCount + Source.RangeCount);
    SetLength(RangeEnds, RangeCount + Source.RangeCount);
    for i := 0 to Source.RangeCount - 1 do
    begin
      RangeStarts[RangeCount + i] := Source.RangeStarts[i];
      RangeEnds[RangeCount + i] := Source.RangeEnds[i];
    end;
    RangeCount := RangeCount + Source.RangeCount;
  end;
end;
{ @end $4DDF74 }

{ @routine $4DE068 TCPDiapazone_AddRange }
procedure TCPDiapazone.AddRange(MinValue, MaxValue: Int64);
var
  Temporary: Int64;
begin
  Inc(RangeCount);
  SetLength(RangeStarts, RangeCount);
  SetLength(RangeEnds, RangeCount);
  if MinValue > MaxValue then
  begin
    Temporary := MinValue;
    MinValue := MaxValue;
    MaxValue := Temporary;
  end;
  RangeStarts[RangeCount - 1] := MinValue;
  RangeEnds[RangeCount - 1] := MaxValue;
end;
{ @end $4DE068 }

{ @routine $4DE12C TCPDiapazone_AddValue }
procedure TCPDiapazone.AddValue(Value: Extended);
var
  IntegerValue: Int64;
  Failed: Boolean;
begin
  IntegerValue := 0;
  Failed := False;
  try
    IntegerValue := Trunc(Value);
  except
    on EMathError do Failed := True;
  end;
  if not Failed then
  begin
    Inc(RangeCount);
    SetLength(RangeStarts, RangeCount);
    SetLength(RangeEnds, RangeCount);
    RangeStarts[RangeCount - 1] := IntegerValue;
    RangeEnds[RangeCount - 1] := IntegerValue;
  end;
end;
{ @end $4DE12C }

{ @routine $4DE214 TCPDiapazone_LoadFromText }
procedure TCPDiapazone.LoadFromText(Text: WideString);
var
  i, Count: Integer;
  Value, Minimum, Maximum: Int64;
  NumberText, Normalized: WideString;
  Failed: Boolean;
begin
  Clear;
  Count := Length(Text);
  if Text <> ';' then
  begin
    // Native parsing retains the original Count after this shortening replacement.
    Normalized := ReplaceAllWideString(Text, '..', 'h');
    i := 1;
    NumberText := '';
    Minimum := 200000000;
    Maximum := -200000000;
    Failed := False;
    while i <= Count do
    begin
      if ((Normalized[i] >= '0') and (Normalized[i] <= '9')) or (Normalized[i] = '-') then
      begin
        NumberText := NumberText + Normalized[i];
        Inc(i);
      end
      else if (Normalized[i] = 'h') or (Normalized[i] = ';') or (Normalized[i] = ']') then
      begin
        Value := 0;
        try
          Value := ExtractSignedDigitsToIntW(NumberText);
        except
          on EMathError do Failed := True;
          on EConvertError do Failed := True;
        end;
        if not Failed then
        begin
          if Minimum > Value then Minimum := Value;
          if Maximum < Value then Maximum := Value;
        end;
        Failed := False;
        NumberText := '';
        if (Normalized[i] = ';') or (Normalized[i] = ']') then
        begin
          AddRange(Minimum, Maximum);
          Minimum := 200000000;
          Maximum := -200000000;
          NumberText := '';
        end;
        Inc(i);
      end
      else Inc(i);
    end;
  end;
end;
{ @end $4DE214 }

end.
