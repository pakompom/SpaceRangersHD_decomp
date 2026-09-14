unit ParameterClass;
// Unit bracket (inferred): .text 0x004DA9A0..0x004DB9A0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create(Index: Integer); // @addr 0x4DAA30 @ida "TParameter *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, int Index@<ecx>);"
    destructor Destroy; override; // @addr 0x4DAAFC @ida "void __usercall $name(TParameter *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Reset(Index: Integer); // @addr 0x4DABD0
    procedure EnsureViewStringCapacity(RequiredCapacity, ParameterIndex: Integer); // @addr 0x4DAE20 @note "ParameterIndex labels new entries; ViewStringCount is unchanged."
    function GetNonCriticalMinimum: Integer; // @addr 0x4DB010
    function GetNonCriticalMaximum: Integer; // @addr 0x4DB048
    procedure SetValue(NewValue: Integer); // @addr 0x4DB080 @note "Clamps ordinary parameters to their bounds; money is only clamped at zero."
    procedure LoadFromReader(Reader: TBufEC); // @addr 0x4DB0F0 @note "Parameter format used by quest versions 1111111125 and later."
    procedure LoadLegacyV0FromReader(Reader: TBufEC); // @addr 0x4DB824 @note "Quest versions 1111111111..1111111112."
    procedure LoadLegacyV1FromReader(Reader: TBufEC); // @addr 0x4DB6B4 @note "Quest versions 1111111113..1111111117."
    procedure LoadLegacyV2FromReader(Reader: TBufEC); // @addr 0x4DB540 @note "Quest version 1111111118."
    procedure LoadLegacyV3FromReader(Reader: TBufEC); // @addr 0x4DB3BC @note "Quest versions 1111111119..1111111120."
    procedure LoadLegacyV4FromReader(Reader: TBufEC); // @addr 0x4DB260 @note "Quest versions 1111111121..1111111124."
    function GetValueText(Value: Integer): WideString; // @addr 0x4DAF50 @ida "void __usercall $name(TParameter *Self@<eax>, int Value@<edx>, unsigned __int16 **Result@<ecx>);"
  end;

implementation

uses EC_Str, ValueListClass, MessageText;

{ @routine $4DAA30 TParameter_Create }
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
{ @end $4DAA30 }

{ @routine $4DAAFC TParameter_Destroy }
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
{ @end $4DAAFC }

{ @routine $4DABD0 TParameter_Reset }
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
{ @end $4DABD0 }

{ @routine $4DAE20 TParameter_EnsureViewStringCapacity }
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
{ @end $4DAE20 }

{ @routine $4DAF50 TParameter_GetValueText }
function TParameter.GetValueText(Value: Integer): WideString;
var
  i: Integer;
begin
  for i := 1 to ViewStringCount do
    if (ViewStrings[i].MinValue <= Value) and (ViewStrings[i].MaxValue >= Value) then
    begin
      Result := TrimWideString(ViewStrings[i].Text.Text);
      Exit;
    end;
  if ViewStrings[ViewStringCount].MaxValue < Value then Result := ViewStrings[ViewStringCount].Text.Text
  else Result := ViewStrings[1].Text.Text;
end;
{ @end $4DAF50 }

{ @routine $4DB010 TParameter_GetNonCriticalMinimum }
function TParameter.GetNonCriticalMinimum: Integer;
begin
  Result := MinValue;
  if (CriticalOutcome <> qoNone) and (CriticalOutcome <> qoSuccess) and CriticalAtMinimum then Inc(Result);
end;
{ @end $4DB010 }

{ @routine $4DB048 TParameter_GetNonCriticalMaximum }
function TParameter.GetNonCriticalMaximum: Integer;
begin
  Result := MaxValue;
  if (CriticalOutcome <> qoNone) and (CriticalOutcome <> qoSuccess) and not CriticalAtMinimum then Dec(Result);
end;
{ @end $4DB048 }

{ @routine $4DB080 TParameter_SetValue }
procedure TParameter.SetValue(NewValue: Integer);
begin
  if IsMoney then
  begin
    if NewValue < 0 then Value := 0
    else Value := NewValue;
  end
  else
  begin
    if NewValue > MaxValue then Value := MaxValue
    else if NewValue < MinValue then Value := MinValue
    else Value := NewValue;
  end;
end;
{ @end $4DB080 }

{ @routine $4DB0F0 TParameter_LoadFromReader }
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
  for i := 1 to ViewStringCount do TParViewString(ViewStrings[i]).LoadFromReader(Reader);
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
{ @end $4DB0F0 }

{ @routine $4DB260 TParameter_LoadLegacyV4FromReader }
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
  for i := 1 to ViewStringCount do TParViewString(ViewStrings[i]).LoadFromReader(Reader);
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
{ @end $4DB260 }

{ @routine $4DB3BC TParameter_LoadLegacyV3FromReader }
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
  for i := 1 to ViewStringCount do TParViewString(ViewStrings[i]).LoadFromReader(Reader);
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
{ @end $4DB3BC }

{ @routine $4DB540 TParameter_LoadLegacyV2FromReader }
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
  for i := 1 to ViewStringCount do TParViewString(ViewStrings[i]).LoadFromReader(Reader);
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
{ @end $4DB540 }

{ @routine $4DB6B4 TParameter_LoadLegacyV1FromReader }
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
  for i := 1 to ViewStringCount do TParViewString(ViewStrings[i]).LoadFromReader(Reader);
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
{ @end $4DB6B4 }

{ @routine $4DB824 TParameter_LoadLegacyV0FromReader }
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
{ @end $4DB824 }

end.
