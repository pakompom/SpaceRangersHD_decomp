unit ParameterDeltaClass;
// Unit bracket (inferred): .text 0x004E0E10..0x004E186C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create; // @addr 0x4E0E6C @ida "TParameterDelta *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4E0F00 @ida "void __usercall $name(TParameterDelta *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Reset; // @addr 0x4E0F88
    procedure ClearValueConstraints; // @addr 0x4E0FAC
    procedure ClearChange; // @addr 0x4E0FE0
    function HasNoValueConstraint(Parameters: TList): Boolean; // @addr 0x4E1030
    function HasNoChange(Parameters: TList): Boolean; // @addr 0x4E10B0
    procedure EvaluateChangeExpression(var Parameters: TList); // @addr 0x4E115C @note "An empty or invalid expression preserves the current parameter value."
    procedure ApplyChange(var Parameters: TList); // @addr 0x4E1278
    function AcceptsParameter(Parameters: TList): Boolean; // @addr 0x4E13D8 @note "Invalid indices and disabled parameters pass; full noncritical bounds impose no constraint."
    // Legacy readers leave ParameterIndex zero; the location/path reader assigns it.
    procedure LoadLegacyV0FromReader(Reader: TBufEC); // @addr 0x4E1498 @note "Quest versions 1111111111..1111111115."
    procedure LoadLegacyV1FromReader(Reader: TBufEC); // @addr 0x4E1520 @note "Quest version 1111111116."
    procedure LoadLegacyV2FromReader(Reader: TBufEC); // @addr 0x4E15CC @note "Quest versions 1111111117..1111111118."
    procedure LoadLegacyV3FromReader(Reader: TBufEC); // @addr 0x4E1688 @note "Quest versions 1111111119..1111111124."
    procedure LoadValueConstraintsFromReader(Reader: TBufEC); // @addr 0x4E1760
    procedure LoadChangeFromReader(Reader: TBufEC); // @addr 0x4E17B0
  end;

implementation

uses CalcParseClass, EC_Str, ParameterClass, TextQuestInterface;

{ @routine $4E0E6C TParameterDelta_Create }
constructor TParameterDelta.Create;
begin
  inherited Create;
  CriticalEvent := TEvent.Create;
  ValueConstraint := TValuesList.Create;
  MultipleConstraint := TValuesList.Create;
  ExpressionText := TTextField.Create;
  Reset;
end;
{ @end $4E0E6C }

{ @routine $4E0F00 TParameterDelta_Destroy }
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
{ @end $4E0F00 }

{ @routine $4E0F88 TParameterDelta_Reset }
procedure TParameterDelta.Reset;
begin
  ParameterIndex := 0;
  ClearValueConstraints;
  ClearChange;
end;
{ @end $4E0F88 }

{ @routine $4E0FAC TParameterDelta_ClearValueConstraints }
procedure TParameterDelta.ClearValueConstraints;
begin
  MinValue := 0;
  MaxValue := 1;
  ValueConstraint.Clear;
  MultipleConstraint.Clear;
end;
{ @end $4E0FAC }

{ @routine $4E0FE0 TParameterDelta_ClearChange }
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
{ @end $4E0FE0 }

{ @routine $4E1030 TParameterDelta_HasNoValueConstraint }
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
{ @end $4E1030 }

{ @routine $4E10B0 TParameterDelta_HasNoChange }
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
{ @end $4E10B0 }

{ @routine $4E115C TParameterDelta_EvaluateChangeExpression }
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
{ @end $4E115C }

{ @routine $4E1278 TParameterDelta_ApplyChange }
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
{ @end $4E1278 }

{ @routine $4E13D8 TParameterDelta_AcceptsParameter }
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
{ @end $4E13D8 }

{ @routine $4E1498 TParameterDelta_LoadLegacyV0FromReader }
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
{ @end $4E1498 }

{ @routine $4E1520 TParameterDelta_LoadLegacyV1FromReader }
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
{ @end $4E1520 }

{ @routine $4E15CC TParameterDelta_LoadLegacyV2FromReader }
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
{ @end $4E15CC }

{ @routine $4E1688 TParameterDelta_LoadLegacyV3FromReader }
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
{ @end $4E1688 }

{ @routine $4E1760 TParameterDelta_LoadValueConstraintsFromReader }
procedure TParameterDelta.LoadValueConstraintsFromReader(Reader: TBufEC);
begin
  ClearValueConstraints;
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  ValueConstraint.LoadFromReader(Reader);
  MultipleConstraint.LoadFromReader(Reader);
end;
{ @end $4E1760 }

{ @routine $4E17B0 TParameterDelta_LoadChangeFromReader }
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
{ @end $4E17B0 }

end.
