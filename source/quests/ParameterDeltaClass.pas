unit ParameterDeltaClass;

interface

uses Classes, EC_Buf, EC_Struct, EventClass, TextFieldClass, ValueListClass;

type
  TParameterVisibilityChange = (pvcUnchanged = 0, pvcShow = 1,
    pvcHide = 2); // @size 0x04
  TParameterDelta = class(TObjectEx) // @size 0x30
  public
    ParameterIndex: Integer; // @offset 0x04
    ValueConstraint: TValuesList; // @offset 0x08
    MultipleConstraint: TValuesList; // @offset 0x0C
    MinValue: Integer; // @offset 0x10
    MaxValue: Integer; // @offset 0x14
    ChangeValue: Integer; // @offset 0x18
    ChangeByPercent: Boolean; // @offset 0x1C
    SetValue: Boolean; // @offset 0x1D
    UseExpression: Boolean; // @offset 0x1E
    ExpressionText: TTextField; // @offset 0x20
    CriticalEvent: TEvent; // @offset 0x24
    VisibilityChange: TParameterVisibilityChange; // @offset 0x28
    // Loaded and cleared, but not read by the execution routines.
    LegacyFlag: Boolean; // @offset 0x2C

    constructor Create; // @addr 0x004E10AC
    destructor Destroy; override; // @addr 0x004E1124
    procedure Reset; // @addr 0x004E1184
    procedure ClearValueConstraints; // @addr 0x004E119C
    procedure ClearChange; // @addr 0x004E11C0
    function HasNoValueConstraint(Parameters: TList): Boolean; // @addr 0x004E11F4
    function HasNoChange(Parameters: TList): Boolean; // @addr 0x004E124C
    procedure EvaluateChangeExpression(var Parameters: TList); // @addr 0x004E12D0 @note "An empty or invalid expression preserves the current parameter value."
    procedure ApplyChange(var Parameters: TList); // @addr 0x004E13B4
    function AcceptsParameter(Parameters: TList): Boolean; // @addr 0x004E14C4 @note "Invalid indices and disabled parameters pass; full noncritical bounds impose no constraint."
    // Legacy readers leave ParameterIndex zero; the location/path reader assigns it.
    procedure LoadLegacyV0FromReader(Reader: TBufEC); // @addr 0x004E153C @note "Quest versions 1111111111..1111111115."
    procedure LoadLegacyV1FromReader(Reader: TBufEC); // @addr 0x004E15A0 @note "Quest version 1111111116."
    procedure LoadLegacyV2FromReader(Reader: TBufEC); // @addr 0x004E161C @note "Quest versions 1111111117..1111111118."
    procedure LoadLegacyV3FromReader(Reader: TBufEC); // @addr 0x004E16A4 @note "Quest versions 1111111119..1111111124."
    procedure LoadValueConstraintsFromReader(Reader: TBufEC); // @addr 0x004E1740
    procedure LoadChangeFromReader(Reader: TBufEC); // @addr 0x004E1778
  end;

implementation

uses CalcParseClass, EC_Str, ParameterClass, TextQuestInterface;

{ @routine $4E10AC TParameterDelta_Create }
constructor TParameterDelta.Create;
begin
  inherited Create;
  CriticalEvent := TEvent.Create;
  ValueConstraint := TValuesList.Create;
  MultipleConstraint := TValuesList.Create;
  ExpressionText := TTextField.Create;
  Reset;
end;
{ @end $4E10AC }

{ @routine $4E1124 TParameterDelta_Destroy }
destructor TParameterDelta.Destroy;
begin
  Reset;
  CriticalEvent.Free;
  CriticalEvent := nil;
  ValueConstraint.Free;
  ValueConstraint := nil;
  MultipleConstraint.Free;
  MultipleConstraint := nil;
  ExpressionText.Free;
  ExpressionText := nil;
  inherited Destroy;
end;
{ @end $4E1124 }

{ @routine $4E1184 TParameterDelta_Reset }
procedure TParameterDelta.Reset;
begin
  ParameterIndex := 0;
  ClearValueConstraints;
  ClearChange;
end;
{ @end $4E1184 }

{ @routine $4E119C TParameterDelta_ClearValueConstraints }
procedure TParameterDelta.ClearValueConstraints;
begin
  MinValue := 0;
  MaxValue := 1;
  ValueConstraint.Clear;
  MultipleConstraint.Clear;
end;
{ @end $4E119C }

{ @routine $4E11C0 TParameterDelta_ClearChange }
procedure TParameterDelta.ClearChange;
begin
  ChangeValue := 0;
  VisibilityChange := pvcUnchanged;
  CriticalEvent.ClearTextFields;
  LegacyFlag := False;
  ChangeByPercent := False;
  SetValue := False;
  UseExpression := False;
  ExpressionText.Text := '';
end;
{ @end $4E11C0 }

{ @routine $4E11F4 TParameterDelta_HasNoValueConstraint }
function TParameterDelta.HasNoValueConstraint(Parameters: TList): Boolean;
var
  Parameter: TParameter;
begin
  Result := True;
  if (ParameterIndex <= 0) or (Parameters.Count < ParameterIndex) then Exit;
  Parameter := Parameters[ParameterIndex - 1];
  Result := False;
  if Parameter.GetNonCriticalMinimum < MinValue then Exit;
  if Parameter.GetNonCriticalMaximum > MaxValue then Exit;
  if ValueConstraint.Count > 0 then Exit;
  if MultipleConstraint.Count > 0 then Exit;
  Result := True;
end;
{ @end $4E11F4 }

{ @routine $4E124C TParameterDelta_HasNoChange }
function TParameterDelta.HasNoChange(Parameters: TList): Boolean;
begin
  if (ParameterIndex <= 0) or (Parameters.Count < ParameterIndex) then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  if VisibilityChange <> pvcUnchanged then Exit;
  if UseExpression then
  begin
    if TrimWideString(ExpressionText.Text) <> '' then Exit;
  end
  else if SetValue or (ChangeValue <> 0) then Exit;
  Result := True;
end;
{ @end $4E124C }

{ @routine $4E12D0 TParameterDelta_EvaluateChangeExpression }
procedure TParameterDelta.EvaluateChangeExpression(var Parameters: TList);
var
  Text: WideString;
  Calc: TCalcParse;
  Parameter: TParameter;
begin
  if (ParameterIndex <= 0) or (Parameters.Count < ParameterIndex) then Exit;
  Parameter := Parameters[ParameterIndex - 1];
  if not Parameter.Enabled or not UseExpression then Exit;
  ChangeValue := Parameter.Value;
  Text := TrimWideString(ExpressionText.Text);
  if Text <> '' then
  begin
    Calc := TCalcParse.Create;
    Calc.Expression := Calc.NormalizeTokens(Text);
    Calc.Evaluate(Parameters);
    if not Calc.HasError then ChangeValue := Calc.ResultValue;
    Calc.Destroy;
  end;
end;
{ @end $4E12D0 }

{ @routine $4E13B4 TParameterDelta_ApplyChange }
procedure TParameterDelta.ApplyChange(var Parameters: TList);
var
  Parameter: TParameter;
  NewValue: Integer;
begin
  if (ParameterIndex <= 0) or (Parameters.Count < ParameterIndex) then Exit;
  Parameter := Parameters[ParameterIndex - 1];
  if not Parameter.Enabled then Exit;
  if UseExpression then NewValue := ChangeValue
  else if SetValue then NewValue := ChangeValue
  else if ChangeByPercent then NewValue := System.Round(Parameter.Value * 0.01 * ChangeValue) + Parameter.Value
  else NewValue := Parameter.Value + ChangeValue;
  Parameter.SetValue(NewValue);
  if Parameter.CriticalOutcome <> qoNone then
  begin
    if TrimWideString(CriticalEvent.Text.Text) <> '' then Parameter.CriticalEventOverride := CriticalEvent
    else Parameter.CriticalEventOverride := nil;
  end;
  if VisibilityChange = pvcShow then Parameter.Hidden := False
  else if VisibilityChange = pvcHide then Parameter.Hidden := True;
end;
{ @end $4E13B4 }

{ @routine $4E14C4 TParameterDelta_AcceptsParameter }
function TParameterDelta.AcceptsParameter(Parameters: TList): Boolean;
var
  Parameter: TParameter;
begin
  Result := True;
  if (ParameterIndex <= 0) or (Parameters.Count < ParameterIndex) then Exit;
  Parameter := Parameters[ParameterIndex - 1];
  if Parameter.Enabled then
  begin
    Result := False;
    if (Parameter.GetNonCriticalMaximum > MaxValue) and (Parameter.Value > MaxValue) then Exit;
    if (Parameter.GetNonCriticalMinimum < MinValue) and (Parameter.Value < MinValue) then Exit;
    if not ValueConstraint.AcceptsValue(Parameter.Value) then Exit;
    if not MultipleConstraint.AcceptsMultiple(Parameter.Value) then Exit;
    Result := True;
  end;
end;
{ @end $4E14C4 }

{ @routine $4E153C TParameterDelta_LoadLegacyV0FromReader }
procedure TParameterDelta.LoadLegacyV0FromReader(Reader: TBufEC);
begin
  Reset;
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  ChangeValue := Reader.GetInt32;
  VisibilityChange := TParameterVisibilityChange(Reader.GetInt32);
  LegacyFlag := Reader.GetBoolean;
  ChangeByPercent := Reader.GetBoolean;
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4E153C }

{ @routine $4E15A0 TParameterDelta_LoadLegacyV1FromReader }
procedure TParameterDelta.LoadLegacyV1FromReader(Reader: TBufEC);
begin
  Reset;
  Reader.GetInt32;
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  ChangeValue := Reader.GetInt32;
  VisibilityChange := TParameterVisibilityChange(Reader.GetInt32);
  LegacyFlag := Reader.GetBoolean;
  ChangeByPercent := Reader.GetBoolean;
  ValueConstraint.LoadFromReader(Reader);
  MultipleConstraint.LoadFromReader(Reader);
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4E15A0 }

{ @routine $4E161C TParameterDelta_LoadLegacyV2FromReader }
procedure TParameterDelta.LoadLegacyV2FromReader(Reader: TBufEC);
begin
  Reset;
  Reader.GetInt32;
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  ChangeValue := Reader.GetInt32;
  VisibilityChange := TParameterVisibilityChange(Reader.GetInt32);
  LegacyFlag := Reader.GetBoolean;
  ChangeByPercent := Reader.GetBoolean;
  SetValue := Reader.GetBoolean;
  ValueConstraint.LoadFromReader(Reader);
  MultipleConstraint.LoadFromReader(Reader);
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4E161C }

{ @routine $4E16A4 TParameterDelta_LoadLegacyV3FromReader }
procedure TParameterDelta.LoadLegacyV3FromReader(Reader: TBufEC);
begin
  Reset;
  Reader.GetInt32;
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  ChangeValue := Reader.GetInt32;
  VisibilityChange := TParameterVisibilityChange(Reader.GetInt32);
  LegacyFlag := Reader.GetBoolean;
  ChangeByPercent := Reader.GetBoolean;
  SetValue := Reader.GetBoolean;
  UseExpression := Reader.GetBoolean;
  ExpressionText.LoadTextLinesFromReader(Reader);
  ValueConstraint.LoadFromReader(Reader);
  MultipleConstraint.LoadFromReader(Reader);
  CriticalEvent.ClearTextFields;
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4E16A4 }

{ @routine $4E1740 TParameterDelta_LoadValueConstraintsFromReader }
procedure TParameterDelta.LoadValueConstraintsFromReader(Reader: TBufEC);
begin
  ClearValueConstraints;
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  ValueConstraint.LoadFromReader(Reader);
  MultipleConstraint.LoadFromReader(Reader);
end;
{ @end $4E1740 }

{ @routine $4E1778 TParameterDelta_LoadChangeFromReader }
procedure TParameterDelta.LoadChangeFromReader(Reader: TBufEC);
const
  ChangeSetValue = 0;
  ChangeByPercentage = 2;
  ChangeFromExpression = 3;
var
  ChangeKind: Byte;
begin
  ClearChange;
  ChangeValue := Reader.GetInt32;
  VisibilityChange := TParameterVisibilityChange(Reader.GetByte);
  ChangeKind := Reader.GetByte;
  SetValue := ChangeKind = ChangeSetValue;
  ChangeByPercent := ChangeKind = ChangeByPercentage;
  UseExpression := ChangeKind = ChangeFromExpression;
  ExpressionText.LoadTextLinesFromReader(Reader);
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
  CriticalEvent.Picture.LoadTextLinesFromReader(Reader);
  CriticalEvent.Sound.LoadTextLinesFromReader(Reader);
  CriticalEvent.Music.LoadTextLinesFromReader(Reader);
end;
{ @end $4E1778 }

end.
