unit ValueListClass;

interface

uses EC_Buf, EC_Struct;

type
  TValuesList = class(TObjectEx) // @size 0x10
  public
    AcceptListed: Boolean; // @offset 0x04
    // Delphi dynamic array; entries 1..Count are used.
    Values: array of Integer; // @offset 0x08
    Count: Integer; // @offset 0x0C

    constructor Create; // @addr 0x004DA914
    destructor Destroy; override; // @addr 0x004DA950
    procedure Clear; // @addr 0x004DA9E0
    procedure LoadFromReader(Reader: TBufEC); // @addr 0x004DA984
    function NormalizeSemicolonText(Text: WideString): WideString; // @addr 0x004DA634 @note "The initial character filter is overwritten; unrelated characters survive. Does not modify Self."
    procedure LoadFromSemicolonText(Text: WideString); // @addr 0x004DAA08
    function AcceptsValue(Value: Integer): Boolean; // @addr 0x004DAB58 @note "An empty list accepts every value, regardless of AcceptListed."
    function AcceptsMultiple(Value: Integer): Boolean; // @addr 0x004DAB88 @note "Zero divisors are unchecked."
  end;

implementation

uses EC_Str;

{ @routine $4DA634 TValuesList_NormalizeSemicolonText }
function TValuesList.NormalizeSemicolonText(Text: WideString): WideString;
var
  i: Integer;
  Normalized: WideString;
begin
  Normalized := '';
  for i := 1 to Length(Text) do
    if ((Text[i] >= '0') and (Text[i] <= '9')) or (Text[i] = ';') or (Text[i] = ',') or (Text[i] = '-') then
      Normalized := Normalized + Text[i];
  Result := Normalized;
  // The native routine discards the character-filtered string here.
  Normalized := '(' + Text + ')';
  repeat
    Result := Normalized;
    Normalized := ReplaceAllWideString(Normalized, ',', ';');
    Normalized := ReplaceAllWideString(Normalized, ';;', ';');
    Normalized := ReplaceAllWideString(Normalized, '-;', ';');
    Normalized := ReplaceAllWideString(Normalized, '--', '');
    Normalized := ReplaceAllWideString(Normalized, '(-;', '(');
    Normalized := ReplaceAllWideString(Normalized, '(-)', '(');
    Normalized := ReplaceAllWideString(Normalized, '(;', '(');
    Normalized := ReplaceAllWideString(Normalized, ';-)', ')');
    Normalized := ReplaceAllWideString(Normalized, ';)', ')');
  until Result = Normalized;
  Result := ReplaceAllWideString(Result, '(', '');
  Result := ReplaceAllWideString(Result, ')', '');
end;
{ @end $4DA634 }

{ @routine $4DA914 TValuesList_Create }
constructor TValuesList.Create;
begin
  inherited Create;
  Clear;
end;
{ @end $4DA914 }

{ @routine $4DA950 TValuesList_Destroy }
destructor TValuesList.Destroy;
begin
  Values := nil;
  inherited Destroy;
end;
{ @end $4DA950 }

{ @routine $4DA984 TValuesList_LoadFromReader }
procedure TValuesList.LoadFromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Count := Reader.GetInt32;
  AcceptListed := Reader.GetBoolean;
  SetLength(Values, Count + 2);
  for i := 1 to Count do Values[i] := Reader.GetInt32;
end;
{ @end $4DA984 }

{ @routine $4DA9E0 TValuesList_Clear }
procedure TValuesList.Clear;
begin
  SetLength(Values, 1);
  Count := 0;
  AcceptListed := True;
end;
{ @end $4DA9E0 }

{ @routine $4DAA08 TValuesList_LoadFromSemicolonText }
procedure TValuesList.LoadFromSemicolonText(Text: WideString);
var
  i: Integer;
  NumberText: WideString;
begin
  Clear;
  i := 1;
  Count := 0;
  NumberText := '';
  Text := TrimWideString(NormalizeSemicolonText(Text));
  if Length(Text) = 0 then Exit;
  while i <= Length(Text) do
  begin
    if (i = Length(Text)) or (Text[i + 1] = ';') then Inc(Count);
    Inc(i);
  end;
  SetLength(Values, Count + 2);
  Count := 0;
  // Native parsing starts at zero, including Text[0].
  i := 0;
  while i <= Length(Text) do
  begin
    if Text[i] <> ';' then NumberText := NumberText + Text[i];
    if (i = Length(Text)) or (Text[i + 1] = ';') then
    begin
      Inc(Count);
      Values[Count] := ExtractSignedDigitsToIntW(NumberText);
      NumberText := '';
    end;
    Inc(i);
  end;
end;
{ @end $4DAA08 }

{ @routine $4DAB58 TValuesList_AcceptsValue }
function TValuesList.AcceptsValue(Value: Integer): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Count = 0 then Exit;
  Result := AcceptListed;
  for i := 1 to Count do
    if Values[i] = Value then Exit;
  Result := not Result;
end;
{ @end $4DAB58 }

{ @routine $4DAB88 TValuesList_AcceptsMultiple }
function TValuesList.AcceptsMultiple(Value: Integer): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Count = 0 then Exit;
  Result := AcceptListed;
  for i := 1 to Count do
    if Value mod Values[i] = 0 then Exit;
  Result := not Result;
end;
{ @end $4DAB88 }

end.
