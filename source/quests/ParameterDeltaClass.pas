unit ParameterDeltaClass;
// Unit bracket (inferred): .text 0x004E4BE0..0x004E563C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create; // @addr 0x4E4C3C
    destructor Destroy; override; // @addr 0x4E4CD0
    procedure Reset; // @addr 0x4E4D58
    procedure ClearValueConstraints; // @addr 0x4E4D7C
    procedure ClearChange; // @addr 0x4E4DB0
    function HasNoValueConstraint(Parameters: TList): Boolean; // @addr 0x4E4E00
    function HasNoChange(Parameters: TList): Boolean; // @addr 0x4E4E80
    procedure EvaluateChangeExpression(var Parameters: TList); // @addr 0x4E4F2C @note "An empty or invalid expression preserves the current parameter value."
    procedure ApplyChange(var Parameters: TList); // @addr 0x4E5048
    function AcceptsParameter(Parameters: TList): Boolean; // @addr 0x4E51A8 @note "Invalid indices and disabled parameters pass; full noncritical bounds impose no constraint."
    // Legacy readers leave ParameterIndex zero; the location/path reader assigns it.
    procedure LoadLegacyV0FromReader(Reader: TBufEC); // @addr 0x4E5268 @note "Quest versions 1111111111..1111111115."
    procedure LoadLegacyV1FromReader(Reader: TBufEC); // @addr 0x4E52F0 @note "Quest version 1111111116."
    procedure LoadLegacyV2FromReader(Reader: TBufEC); // @addr 0x4E539C @note "Quest versions 1111111117..1111111118."
    procedure LoadLegacyV3FromReader(Reader: TBufEC); // @addr 0x4E5458 @note "Quest versions 1111111119..1111111124."
    procedure LoadValueConstraintsFromReader(Reader: TBufEC); // @addr 0x4E5530
    procedure LoadChangeFromReader(Reader: TBufEC); // @addr 0x4E5580
  end;

implementation

uses CalcParseClass, EC_Str, ParameterClass, TextQuestInterface;

{ @routine $4E4C3C TParameterDelta_Create }
constructor TParameterDelta.Create;
begin
  inherited Create;
  CriticalEvent := TEvent.Create;
  ValueConstraint := TValuesList.Create;
  MultipleConstraint := TValuesList.Create;
  ExpressionText := TTextField.Create;
  Reset;
end;
{ @end $4E4C3C }

{ @routine $4E4CD0 TParameterDelta_Destroy }
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
{ @end $4E4CD0 }

{ @routine $4E4D58 TParameterDelta_Reset }
procedure TParameterDelta.Reset;
begin
  ParameterIndex := 0;
  ClearValueConstraints;
  ClearChange;
end;
{ @end $4E4D58 }

{ @routine $4E4D7C TParameterDelta_ClearValueConstraints }
procedure TParameterDelta.ClearValueConstraints;
begin
  MinValue := 0;
  MaxValue := 1;
  ValueConstraint.Clear;
  MultipleConstraint.Clear;
end;
{ @end $4E4D7C }

{ @routine $4E4DB0 TParameterDelta_ClearChange }
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
{ @end $4E4DB0 }

{ @routine $4E4E00 TParameterDelta_HasNoValueConstraint }
function TParameterDelta.HasNoValueConstraint(Parameters: TList): Boolean;
var
  Parameter: TParameter;
begin
  Result := True;
  if (ParameterIndex <= 0) or (Parameters.Count < ParameterIndex) then Exit;
  Parameter := TParameter(Parameters[ParameterIndex - 1]);
  Result := False;
  if (Parameter.GetNonCriticalMinimum >= MinValue) and
     (Parameter.GetNonCriticalMaximum <= MaxValue) and
     (ValueConstraint.Count <= 0) and (MultipleConstraint.Count <= 0) then Result := True;
end;
{ @end $4E4E00 }

{ @routine $4E4E80 TParameterDelta_HasNoChange }
function TParameterDelta.HasNoChange(Parameters: TList): Boolean;
// The native branches share one assignment before managed-string cleanup.
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
  else if not (not SetValue and (ChangeValue = 0)) then Exit;
  Result := True;
end;
{ @end $4E4E80 }

{ @routine $4E4F2C TParameterDelta_EvaluateChangeExpression }
procedure TParameterDelta.EvaluateChangeExpression(var Parameters: TList);
var
  Text: WideString;
  Calc: TCalcParse;
  Parameter: TParameter;
begin
  if (ParameterIndex > 0) and (Parameters.Count >= ParameterIndex) then
  begin
    Parameter := TParameter(Parameters[ParameterIndex - 1]);
    if Parameter.Enabled and UseExpression then
    begin
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
  end;
end;
{ @end $4E4F2C }

{ @routine $4E5048 TParameterDelta_ApplyChange }
procedure TParameterDelta.ApplyChange(var Parameters: TList);
var
  Parameter: TParameter;
  NewValue: Integer;
begin
  if (ParameterIndex > 0) and (Parameters.Count >= ParameterIndex) then
  begin
    Parameter := TParameter(Parameters[ParameterIndex - 1]);
    if Parameter.Enabled then
    begin
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
  end;
end;
{ @end $4E5048 }

{ @routine $4E51A8 TParameterDelta_AcceptsParameter }
function TParameterDelta.AcceptsParameter(Parameters: TList): Boolean;
var
  Parameter: TParameter;
begin
  Result := True;
  if (ParameterIndex <= 0) or (Parameters.Count < ParameterIndex) then Exit;
  Parameter := TParameter(Parameters[ParameterIndex - 1]);
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
{ @end $4E51A8 }

{ @routine $4E5268 TParameterDelta_LoadLegacyV0FromReader }
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
{ @end $4E5268 }

{ @routine $4E52F0 TParameterDelta_LoadLegacyV1FromReader }
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
{ @end $4E52F0 }

{ @routine $4E539C TParameterDelta_LoadLegacyV2FromReader }
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
{ @end $4E539C }

{ @routine $4E5458 TParameterDelta_LoadLegacyV3FromReader }
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
{ @end $4E5458 }

{ @routine $4E5530 TParameterDelta_LoadValueConstraintsFromReader }
procedure TParameterDelta.LoadValueConstraintsFromReader(Reader: TBufEC);
begin
  ClearValueConstraints;
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  ValueConstraint.LoadFromReader(Reader);
  MultipleConstraint.LoadFromReader(Reader);
end;
{ @end $4E5530 }

{ @routine $4E5580 TParameterDelta_LoadChangeFromReader }
procedure TParameterDelta.LoadChangeFromReader(Reader: TBufEC);
var
  ChangeKind: Byte;
begin
  ClearChange;
  ChangeValue := Reader.GetInt32;
  VisibilityChange := TParameterVisibilityChange(Reader.GetByte);
  ChangeKind := Reader.GetByte;
  SetValue := (ChangeKind = 0);
  ChangeByPercent := (ChangeKind = 2);
  UseExpression := (ChangeKind = 3);
  ExpressionText.LoadTextLinesFromReader(Reader);
  CriticalEvent.Text.LoadTextLinesFromReader(Reader);
  CriticalEvent.Picture.LoadTextLinesFromReader(Reader);
  CriticalEvent.Sound.LoadTextLinesFromReader(Reader);
  CriticalEvent.Music.LoadTextLinesFromReader(Reader);
end;
{ @end $4E5580 }

end.
