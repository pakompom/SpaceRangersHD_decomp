unit ParameterClass;

interface

uses CPDiapClass, EC_Buf, EC_Struct, EventClass, ParViewStringClass, TextFieldClass, TextQuestInterface;

type
  TParameter = class(TObjectEx) // @size 0x3C
  public
    MinValue: Integer; // @offset 0x04
    MaxValue: Integer; // @offset 0x08
    Value: Integer; // @offset 0x0C
    NameText: TTextField; // @offset 0x10
    CriticalEvent: TEvent; // @offset 0x14
    CriticalEventOverride: TEvent; // @offset 0x18
    CriticalOutcome: TQuestOutcome; // @offset 0x1C
    Hidden: Boolean; // @offset 0x20
    ShowWhenZero: Boolean; // @offset 0x21
    CriticalAtMinimum: Boolean; // @offset 0x22
    Enabled: Boolean; // @offset 0x23
    IsMoney: Boolean; // @offset 0x24
    ValueText: TTextField; // @offset 0x28
    // Delphi dynamic array of owned entries, indexed from one.
    ViewStrings: array of TParViewString; // @offset 0x2C
    ViewStringCount: Integer; // @offset 0x30
    ViewStringCapacity: Integer; // @offset 0x34
    InitialRange: TCPDiapazone; // @offset 0x38

    constructor Create(Index: Integer); // @addr 0x004DB900
    destructor Destroy; override; // @addr 0x004DB9A8
    procedure Reset(Index: Integer); // @addr 0x004DBA40
    procedure EnsureViewStringCapacity(RequiredCapacity, ParameterIndex: Integer); // @addr 0x004DBC44 @note "ParameterIndex labels new entries; ViewStringCount is unchanged."
    function GetNonCriticalMinimum: Integer; // @addr 0x004DBDBC
    function GetNonCriticalMaximum: Integer; // @addr 0x004DBDD8
    procedure SetValue(NewValue: Integer); // @addr 0x004DBDF4 @note "Clamps ordinary parameters to their bounds; money is only clamped at zero."
    procedure LoadFromReader(Reader: TBufEC); // @addr 0x004DBE28 @note "Parameter format used by quest versions 1111111125 and later."
    procedure LoadLegacyV0FromReader(Reader: TBufEC); // @addr 0x004DC334 @note "Quest versions 1111111111..1111111112."
    procedure LoadLegacyV1FromReader(Reader: TBufEC); // @addr 0x004DC238 @note "Quest versions 1111111113..1111111117."
    procedure LoadLegacyV2FromReader(Reader: TBufEC); // @addr 0x004DC134 @note "Quest version 1111111118."
    procedure LoadLegacyV3FromReader(Reader: TBufEC); // @addr 0x004DC018 @note "Quest versions 1111111119..1111111120."
    procedure LoadLegacyV4FromReader(Reader: TBufEC); // @addr 0x004DBF28 @note "Quest versions 1111111121..1111111124."
    function GetValueText(Value: Integer): WideString; // @addr 0x004DBD50
  end;

implementation

uses EC_Str, ValueListClass, MessageText;

{ @routine $4DB900 TParameter_Create }
constructor TParameter.Create(Index: Integer);
begin
  inherited Create;
  ViewStringCount := 0;
  ViewStringCapacity := 0;
  SetLength(ViewStrings, 0);
  NameText := TTextField.Create;
  ValueText := TTextField.Create;
  CriticalEvent := TEvent.Create;
  CriticalEventOverride := nil;
  InitialRange := TCPDiapazone.Create;
  Reset(Index);
end;
{ @end $4DB900 }

{ @routine $4DB9A8 TParameter_Destroy }
destructor TParameter.Destroy;
var
  i: Integer;
begin
  for i := 1 to ViewStringCapacity do
  begin
    ViewStrings[i].Free;
    ViewStrings[i] := nil;
  end;
  SetLength(ViewStrings, 0);
  NameText.Free;
  NameText := nil;
  ValueText.Free;
  ValueText := nil;
  CriticalEvent.Free;
  CriticalEvent := nil;
  InitialRange.Free;
  InitialRange := nil;
  inherited Destroy;
end;
{ @end $4DB9A8 }

{ @routine $4DBA40 TParameter_Reset }
procedure TParameter.Reset(Index: Integer);
begin
  IsMoney := False;
  Enabled := False;
  Hidden := False;
  ShowWhenZero := True;
  CriticalAtMinimum := True;
  MinValue := 0;
  MaxValue := 1;
  InitialRange.Clear;
  ViewStringCount := 1;
  EnsureViewStringCapacity(1, Index);
  ViewStrings[1].MinValue := MinValue;
  ViewStrings[1].MaxValue := MaxValue;
  Value := 0;
  CriticalOutcome := qoNone;
  NameText.Text := QuestMessages.GetTextOrKey('ParameterDefaultName') + ' ' + IntToWideString(Index);
  ValueText.Text := QuestMessages.GetTextOrKey('ParameterDefaultName') + ' ' + IntToWideString(Index) + ': <>';
  ViewStrings[1].Text.Text := ValueText.Text;
  CriticalEvent.ClearTextFields;
  CriticalEventOverride := nil;
  CriticalEvent.Text.Text := QuestMessages.GetTextOrKey('ParameterDefaultCriticalMessage') + ' ' + IntToWideString(Index);
end;
{ @end $4DBA40 }

{ @routine $4DBC44 TParameter_EnsureViewStringCapacity }
procedure TParameter.EnsureViewStringCapacity(RequiredCapacity: Integer; ParameterIndex: Integer);
begin
  while RequiredCapacity > ViewStringCapacity do
  begin
    Inc(ViewStringCapacity);
    SetLength(ViewStrings, ViewStringCapacity + 1);
    ViewStrings[ViewStringCapacity] := TParViewString.Create(
      QuestMessages.GetTextOrKey('ParameterDefaultName') + ' ' + IntToWideString(ParameterIndex) + ': <>');
  end;
end;
{ @end $4DBC44 }

{ @routine $4DBD50 TParameter_GetValueText }
function TParameter.GetValueText(Value: Integer): WideString;
var
  i: Integer;
begin
  for i := 1 to ViewStringCount do
  begin
    if (ViewStrings[i].MinValue > Value) or (ViewStrings[i].MaxValue < Value) then Continue;
    Result := TrimWideString(ViewStrings[i].Text.Text);
    Exit;
  end;
  if ViewStrings[ViewStringCount].MaxValue < Value then Result := ViewStrings[ViewStringCount].Text.Text
  else Result := ViewStrings[1].Text.Text;
end;
{ @end $4DBD50 }

{ @routine $4DBDBC TParameter_GetNonCriticalMinimum }
function TParameter.GetNonCriticalMinimum: Integer;
begin
  Result := MinValue;
  if (CriticalOutcome <> qoNone) and (CriticalOutcome <> qoSuccess) and CriticalAtMinimum then Inc(Result);
end;
{ @end $4DBDBC }

{ @routine $4DBDD8 TParameter_GetNonCriticalMaximum }
function TParameter.GetNonCriticalMaximum: Integer;
begin
  Result := MaxValue;
  if (CriticalOutcome <> qoNone) and (CriticalOutcome <> qoSuccess) and not CriticalAtMinimum then Dec(Result);
end;
{ @end $4DBDD8 }

{ @routine $4DBDF4 TParameter_SetValue }
procedure TParameter.SetValue(NewValue: Integer);
begin
  if IsMoney then
  begin
    if NewValue < 0 then Value := 0
    else Value := NewValue;
  end
  else if NewValue > MaxValue then Value := MaxValue
  else if NewValue < MinValue then Value := MinValue
  else Value := NewValue;
end;
{ @end $4DBDF4 }

{ @routine $4DBE28 TParameter_LoadFromReader }
procedure TParameter.LoadFromReader(Reader: TBufEC);
var
  i: Integer;
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  CriticalOutcome := TQuestOutcome(Reader.GetInt32);
  Hidden := False;
  ShowWhenZero := Reader.GetBoolean;
  CriticalAtMinimum := Reader.GetBoolean;
  Enabled := Reader.GetBoolean;
  ViewStringCount := Reader.GetInt32;
  IsMoney := Reader.GetBoolean;
  NameText.LoadTextLinesFromReader(Reader);
  EnsureViewStringCapacity(ViewStringCount, 0);
  for i := 1 to ViewStringCount do ViewStrings[i].LoadFromReader(Reader);
  if ViewStringCount <= 0 then
  begin
    ViewStringCount := 1;
    EnsureViewStringCapacity(1, 0);
    ViewStrings[1].MinValue := MinValue;
    ViewStrings[1].MaxValue := MaxValue;
  end;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
  CriticalEvent.Picture.LoadTextLinesFromReader(Reader);
  CriticalEvent.Sound.LoadTextLinesFromReader(Reader);
  CriticalEvent.Music.LoadTextLinesFromReader(Reader);
  InitialRange.LoadFromReader(Reader);
end;
{ @end $4DBE28 }

{ @routine $4DBF28 TParameter_LoadLegacyV4FromReader }
procedure TParameter.LoadLegacyV4FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  Value := Reader.GetInt32;
  CriticalOutcome := TQuestOutcome(Reader.GetInt32);
  Hidden := Reader.GetBoolean;
  ShowWhenZero := Reader.GetBoolean;
  CriticalAtMinimum := Reader.GetBoolean;
  Enabled := Reader.GetBoolean;
  ViewStringCount := Reader.GetInt32;
  IsMoney := Reader.GetBoolean;
  NameText.LoadTextLinesFromReader(Reader);
  EnsureViewStringCapacity(ViewStringCount, 0);
  for i := 1 to ViewStringCount do ViewStrings[i].LoadFromReader(Reader);
  if ViewStringCount <= 0 then
  begin
    ViewStringCount := 1;
    EnsureViewStringCapacity(1, 0);
    ViewStrings[1].MinValue := MinValue;
    ViewStrings[1].MaxValue := MaxValue;
  end;
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
  InitialRange.LoadFromReader(Reader);
end;
{ @end $4DBF28 }

{ @routine $4DC018 TParameter_LoadLegacyV3FromReader }
procedure TParameter.LoadLegacyV3FromReader(Reader: TBufEC);
var
  i: Integer;
  Values: TValuesList;
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  Value := Reader.GetInt32;
  CriticalOutcome := TQuestOutcome(Reader.GetInt32);
  Hidden := Reader.GetBoolean;
  ShowWhenZero := Reader.GetBoolean;
  CriticalAtMinimum := Reader.GetBoolean;
  Enabled := Reader.GetBoolean;
  ViewStringCount := Reader.GetInt32;
  IsMoney := Reader.GetBoolean;
  NameText.LoadTextLinesFromReader(Reader);
  EnsureViewStringCapacity(ViewStringCount, 0);
  for i := 1 to ViewStringCount do ViewStrings[i].LoadFromReader(Reader);
  if ViewStringCount <= 0 then
  begin
    ViewStringCount := 1;
    EnsureViewStringCapacity(1, 0);
    ViewStrings[1].MinValue := MinValue;
    ViewStrings[1].MaxValue := MaxValue;
  end;
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
  Values := TValuesList.Create;
  Values.LoadFromReader(Reader);
  InitialRange.LoadFromValues(Values);
  Values.Clear;
  Values.Free;
end;
{ @end $4DC018 }

{ @routine $4DC134 TParameter_LoadLegacyV2FromReader }
procedure TParameter.LoadLegacyV2FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  Value := Reader.GetInt32;
  CriticalOutcome := TQuestOutcome(Reader.GetInt32);
  Hidden := Reader.GetBoolean;
  ShowWhenZero := Reader.GetBoolean;
  CriticalAtMinimum := Reader.GetBoolean;
  Enabled := Reader.GetBoolean;
  ViewStringCount := Reader.GetInt32;
  IsMoney := Reader.GetBoolean;
  NameText.LoadTextLinesFromReader(Reader);
  EnsureViewStringCapacity(ViewStringCount, 0);
  for i := 1 to ViewStringCount do ViewStrings[i].LoadFromReader(Reader);
  if ViewStringCount <= 0 then
  begin
    ViewStringCount := 1;
    EnsureViewStringCapacity(1, 0);
    ViewStrings[1].MinValue := MinValue;
    ViewStrings[1].MaxValue := MaxValue;
  end;
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
  InitialRange.Clear;
  InitialRange.AddRange(Value, Value);
end;
{ @end $4DC134 }

{ @routine $4DC238 TParameter_LoadLegacyV1FromReader }
procedure TParameter.LoadLegacyV1FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  Value := Reader.GetInt32;
  CriticalOutcome := TQuestOutcome(Reader.GetInt32);
  Hidden := Reader.GetBoolean;
  ShowWhenZero := Reader.GetBoolean;
  CriticalAtMinimum := Reader.GetBoolean;
  Enabled := Reader.GetBoolean;
  ViewStringCount := Reader.GetInt32;
  IsMoney := False;
  NameText.LoadTextLinesFromReader(Reader);
  EnsureViewStringCapacity(ViewStringCount, 0);
  for i := 1 to ViewStringCount do ViewStrings[i].LoadFromReader(Reader);
  if ViewStringCount <= 0 then
  begin
    ViewStringCount := 1;
    EnsureViewStringCapacity(1, 0);
    ViewStrings[1].MinValue := MinValue;
    ViewStrings[1].MaxValue := MaxValue;
  end;
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
  InitialRange.Clear;
  InitialRange.AddRange(Value, Value);
end;
{ @end $4DC238 }

{ @routine $4DC334 TParameter_LoadLegacyV0FromReader }
procedure TParameter.LoadLegacyV0FromReader(Reader: TBufEC);
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  Value := Reader.GetInt32;
  CriticalOutcome := TQuestOutcome(Reader.GetInt32);
  Hidden := Reader.GetBoolean;
  ShowWhenZero := Reader.GetBoolean;
  CriticalAtMinimum := Reader.GetBoolean;
  Enabled := Reader.GetBoolean;
  ViewStringCount := 1;
  IsMoney := False;
  NameText.LoadTextLinesFromReader(Reader);
  ValueText.LoadTextLinesFromReader(Reader);
  EnsureViewStringCapacity(ViewStringCount, 0);
  ViewStrings[1].MaxValue := MaxValue;
  ViewStrings[1].MinValue := MinValue;
  ViewStrings[1].Text.Text := TrimWideString(ValueText.Text);
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
  InitialRange.Clear;
  InitialRange.AddRange(Value, Value);
end;
{ @end $4DC334 }

end.
