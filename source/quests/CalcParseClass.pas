unit CalcParseClass;
// Unit bracket (inferred): .text 0x004DFCA8..0x004E4B9C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses CPVarClass, Classes, EC_Struct;

type
  TCalcParse = class(TObjectEx) // @size 0x1C
  public
    SourceText: WideString; // @offset 0x04
    Expression: WideString; // @offset 0x08  Internal tokens; parameters not yet substituted.
    ResultValue: Integer; // @offset 0x0C
    ResetValue10: Integer; // @offset 0x10  Reset to zero; purpose remains unresolved.
    UsesDefaultParameter: Boolean; // @offset 0x14  Processed text was empty or exactly the fallback [pN].
    SourceWasChanged: Boolean; // @offset 0x15  Compared against the readable form, not internal tokens.
    UnbalancedParentheses: Boolean; // @offset 0x16
    InvalidNumericLiteral: Boolean; // @offset 0x17  EConvertError during preparation.
    InvalidParameterReference: Boolean; // @offset 0x18
    InvalidRangeLiteral: Boolean; // @offset 0x19
    EvaluationError: Boolean; // @offset 0x1A
    HasError: Boolean; // @offset 0x1B  Also set for empty parentheses.

    constructor Create; // @addr 0x4E4634
    procedure Reset; // @addr 0x4E4674

    // External spellings -> internal tokens: pct %, div f, mod g, in #,
    // to $, or |, and &, <> e, >= c, <= b, .. h, and decimal dot -> comma.
    function NormalizeTokens(var Text: WideString): WideString; // @addr 0x4E1194 @note "Text is read-only despite var. Uses ANSI lowercase and boundary-free substitutions; always wraps the result in parentheses."
    function FormatTokens(var Text: WideString): WideString; // @addr 0x4E1768 @note "Text is read-only despite var. Removes at most one enclosing parenthesis pair; leaves outer whitespace."
    // Lower ranks bind tighter; -1 means not an operator.
    // 1: ^ / f g; 2: * %; 3: -; 4: +; 5: $; 6: #;
    // 7: < > = b c e; 8: &; 9: |.
    function GetOperatorRank(Token: WideChar): Integer; // @addr 0x4E1B7C
    function CollapseOperatorRun(const Text: WideString): WideString; // @addr 0x4E1D0C @note "Requires a nonempty operator run. Minus parity controls the sign; ties choose the leftmost weakest operator."
    function NormalizeParameterReference(Text: WideString): WideString; // @addr 0x4E310C @note "Uses only the first three digits; zero/missing digits produce [err]. Does not check parameter-list bounds."
    function FindTopLevelOperator(const Text: WideString; TextLength: Integer): Integer; // @addr 0x4E3C40 @note "One-based; zero when absent. Rightmost ties give left associativity. Delimiter balance is unchecked."
    function HasBalancedParenthesesInSlice(const Text: WideString; FirstIndex, LastIndex: Integer): Boolean; // @addr 0x4E46DC @note "One-based inclusive bounds, unchecked. Empty slices pass; square brackets are ignored."
    function HasBalancedParentheses(const Text: WideString): Boolean; // @addr 0x4E48EC @note "Empty text passes."

    procedure Prepare(Text: WideString; DefaultParameterIndex: Integer); // @addr 0x4E43E0 @note "Resets state; stores Expression even on error. Empty input becomes (), not the default parameter."
    function NormalizeFragments(const Text: WideString): WideString; // @addr 0x4E1E98 @note "Square brackets do not nest. An unmatched opening bracket silently discards the remaining suffix."
    function NormalizeScalarFragment(Text: WideString): WideString; // @addr 0x4E2068 @note "Silently discards unsupported characters, including decimal dots; call NormalizeTokens first."
    function NormalizeBracketFragment(Text: WideString): WideString; // @addr 0x4E3070 @note "Any lowercase p selects parameter parsing, even outside the [pN] form."
    function NormalizeRangeLiteral(Text: WideString): WideString; // @addr 0x4E327C @note "Requires internal h notation, not '..'. Empty or rejected input yields [err]; existing errors remain set."
    function InsertImplicitMultiplication(Text: WideString): WideString; // @addr 0x4E35A4
    function ClampNumericLiterals(Text: WideString): WideString; // @addr 0x4E4924 @note "Nonzero limits: 0.0001..999999999. The lower clamp emits a dot-decimal literal that evaluation rejects. Drops trailing numbers; conversion errors set flags and leave the caller's result storage unchanged."

    // Parameters: borrowed, non-nil TList of TParameter; [pN] is one-based.
    function SubstituteParameters(Parameters: TList): WideString; // @addr 0x4E4754 @note "Unmatched references remain unchanged; negative values are parenthesized."
    function EvaluateExpression(Text: WideString): TCPVariant; // @addr 0x4E3D0C @note "Caller owns the result. Evaluates right before left without short-circuiting. EvaluationError blocks evaluation; HasError alone does not. Native recursive intermediates leak."
    procedure Evaluate(Parameters: TList); // @addr 0x4E42C4 @note "Existing HasError preserves ResultValue; flags are not reset. Native scratch and returned variants leak."

    // Operators borrow operands; OutValue must be an existing, distinct object.
    // Power/add/subtract/multiply promote floats; integer results saturate at +/-2000000000.
    procedure ApplyPower(var Left, Right, OutValue: TCPVariant); // @addr 0x4DFD1C @note "Negative bases stay negative even for even exponents; integer results round."
    procedure ApplyAdd(var Left, Right, OutValue: TCPVariant); // @addr 0x4DFF3C
    procedure ApplySubtract(var Left, Right, OutValue: TCPVariant); // @addr 0x4E00A8
    procedure ApplyMultiply(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0214
    procedure ApplyPercentChange(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0380 @note "Returns float Left * (1 + Right * 0.01)."
    procedure ApplyDivide(var Left, Right, OutValue: TCPVariant); // @addr 0x4E03EC @note "Exact integer quotients stay integer. Zero divisor: +/-2000000000 for integers; float operands incorrectly leave integer zero."
    procedure ApplyIntDivide(var Left, Right, OutValue: TCPVariant); // @addr 0x4E05B0 @note "Truncates toward zero; zero-divisor behavior matches ApplyDivide."
    procedure ApplyModulo(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0704 @note "Float operands produce a float remainder after truncation. Zero-divisor behavior matches ApplyDivide."
    procedure ApplyRange(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0934 @note "Uses operand extrema, rounds floats and swaps reversed bounds. Range operands must be nonempty."
    procedure ApplyMembership(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0A48 @note "Two ranges sample Left once; scalar/range membership rounds the scalar."
    // Comparisons return integer 0 or 1 and sample each range operand once.
    procedure ApplyLessThan(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0BCC
    procedure ApplyGreaterThan(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0C30
    procedure ApplyLessOrEqual(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0C94
    procedure ApplyGreaterOrEqual(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0CF8
    procedure ApplyEqual(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0D5C
    procedure ApplyNotEqual(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0DC0
    procedure ApplyAnd(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0E24 @note "Range operands concatenate rather than intersect; duplicates remain."
    procedure ApplyOr(var Left, Right, OutValue: TCPVariant); // @addr 0x4E0FE0 @note "Range operands concatenate; duplicates remain."
  end;

implementation

uses CPDiapClass, EC_Str, Math, ParameterClass, SysUtils;

{ @routine $4DFD1C TCalcParse_ApplyPower }
procedure TCalcParse.ApplyPower(var Left, Right, OutValue: TCPVariant);
var
  A, B: Integer;
  X, Y: Extended;
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkFloat;
  if (Left.ValueKind = cpvkFloat) and (Right.ValueKind = cpvkFloat) then
    OutValue.FloatValue := Math.Sign(Left.AsExtended) *
      Math.Power(Abs(Left.AsExtended), Right.AsExtended)
  else if Left.ValueKind = cpvkFloat then
    OutValue.FloatValue := Math.Sign(Left.AsExtended) *
      Math.IntPower(Abs(Left.AsExtended), Right.AsInteger)
  else if Right.ValueKind = cpvkFloat then
  begin
    A := Left.AsInteger;
    OutValue.FloatValue := Math.Power(Abs(A), Right.AsExtended) * Math.Sign(A);
  end
  else
  begin
    OutValue.ValueKind := cpvkInteger;
    A := Left.AsInteger;
    B := Right.AsInteger;
    X := A;
    Y := B;
    if Math.Power(Abs(X), Y) > QuestNumericLimit then OutValue.IntValue := Math.Sign(A) * QuestNumericLimit
    else OutValue.IntValue := Integer(System.Round(Math.IntPower(Abs(A), B))) * Math.Sign(A);
  end;
end;
{ @end $4DFD1C }

{ @routine $4DFF3C TCalcParse_ApplyAdd }
procedure TCalcParse.ApplyAdd(var Left, Right, OutValue: TCPVariant);
var
  A, B: Integer;
  X, Y: Extended;
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkFloat;
  if (Left.ValueKind = cpvkFloat) and (Right.ValueKind = cpvkFloat) then
    OutValue.FloatValue := Left.AsExtended + Right.AsExtended
  else if Left.ValueKind = cpvkFloat then
    OutValue.FloatValue := Left.AsExtended + Right.AsInteger
  else if Right.ValueKind = cpvkFloat then
    OutValue.FloatValue := Left.AsInteger + Right.AsExtended
  else
  begin
    OutValue.ValueKind := cpvkInteger;
    A := Left.AsInteger;
    B := Right.AsInteger;
    X := A;
    Y := B;
    if X + Y > QuestNumericLimit then OutValue.IntValue := QuestNumericLimit
    else if X + Y < -QuestNumericLimit then OutValue.IntValue := -QuestNumericLimit
    else OutValue.IntValue := A + B;
  end;
end;
{ @end $4DFF3C }

{ @routine $4E00A8 TCalcParse_ApplySubtract }
procedure TCalcParse.ApplySubtract(var Left, Right, OutValue: TCPVariant);
var
  A, B: Integer;
  X, Y: Extended;
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkFloat;
  if (Left.ValueKind = cpvkFloat) and (Right.ValueKind = cpvkFloat) then
    OutValue.FloatValue := Left.AsExtended - Right.AsExtended
  else if Left.ValueKind = cpvkFloat then
    OutValue.FloatValue := Left.AsExtended - Right.AsInteger
  else if Right.ValueKind = cpvkFloat then
    OutValue.FloatValue := Left.AsInteger - Right.AsExtended
  else
  begin
    OutValue.ValueKind := cpvkInteger;
    A := Left.AsInteger;
    B := Right.AsInteger;
    X := A;
    Y := B;
    if X - Y > QuestNumericLimit then OutValue.IntValue := QuestNumericLimit
    else if X - Y < -QuestNumericLimit then OutValue.IntValue := -QuestNumericLimit
    else OutValue.IntValue := A - B;
  end;
end;
{ @end $4E00A8 }

{ @routine $4E0214 TCalcParse_ApplyMultiply }
procedure TCalcParse.ApplyMultiply(var Left, Right, OutValue: TCPVariant);
var
  A, B: Integer;
  X, Y: Extended;
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkFloat;
  if (Left.ValueKind = cpvkFloat) and (Right.ValueKind = cpvkFloat) then
    OutValue.FloatValue := Left.AsExtended * Right.AsExtended
  else if Left.ValueKind = cpvkFloat then
    OutValue.FloatValue := Left.AsExtended * Right.AsInteger
  else if Right.ValueKind = cpvkFloat then
    OutValue.FloatValue := Left.AsInteger * Right.AsExtended
  else
  begin
    OutValue.ValueKind := cpvkInteger;
    A := Left.AsInteger;
    B := Right.AsInteger;
    X := A;
    Y := B;
    if X * Y > QuestNumericLimit then OutValue.IntValue := QuestNumericLimit
    else if X * Y < -QuestNumericLimit then OutValue.IntValue := -QuestNumericLimit
    else OutValue.IntValue := A * B;
  end;
end;
{ @end $4E0214 }

{ @routine $4E0380 TCalcParse_ApplyPercentChange }
procedure TCalcParse.ApplyPercentChange(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkFloat;
  OutValue.FloatValue := Left.AsExtended * (1 + Right.AsExtended * 0.01);
end;
{ @end $4E0380 }

{ @routine $4E03EC TCalcParse_ApplyDivide }
procedure TCalcParse.ApplyDivide(var Left, Right, OutValue: TCPVariant);
var
  A, B: Integer;
  X, Y: Extended;
begin
  OutValue.Reset;
  if (Left.ValueKind <> cpvkFloat) and (Right.ValueKind <> cpvkFloat) then
  begin
    A := Left.AsInteger;
    B := Right.AsInteger;
    if B = 0 then
    begin
      OutValue.ValueKind := cpvkInteger;
      if A < 0 then OutValue.IntValue := -QuestNumericLimit
      else OutValue.IntValue := QuestNumericLimit;
    end
    else if A mod B = 0 then
    begin
      OutValue.ValueKind := cpvkInteger;
      OutValue.IntValue := A div B;
    end
    else
      try
        OutValue.ValueKind := cpvkFloat;
        OutValue.FloatValue := A / B;
      except
        on EDivByZero do begin end;
      end;
  end
  else
  begin
    X := Left.AsExtended;
    Y := Right.AsExtended;
    if Y = 0 then
    begin
      if X < 0 then OutValue.FloatValue := -QuestNumericLimit
      else OutValue.FloatValue := QuestNumericLimit;
    end
    else
      try
      OutValue.ValueKind := cpvkFloat;
      OutValue.FloatValue := X / Y;
      except
        on EDivByZero do begin end;
      end;
  end;
end;
{ @end $4E03EC }

{ @routine $4E05B0 TCalcParse_ApplyIntDivide }
procedure TCalcParse.ApplyIntDivide(var Left, Right, OutValue: TCPVariant);
var
  A, B: Integer;
  X, Y: Extended;
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkInteger;
  if (Left.ValueKind <> cpvkFloat) and (Right.ValueKind <> cpvkFloat) then
  begin
    A := Left.AsInteger;
    B := Right.AsInteger;
    if B = 0 then
    begin
      if A < 0 then OutValue.IntValue := -QuestNumericLimit
      else OutValue.IntValue := QuestNumericLimit;
    end
    else OutValue.IntValue := A div B;
  end
  else
  begin
    X := Left.AsExtended;
    Y := Right.AsExtended;
    if Y = 0 then
    begin
      if X < 0 then OutValue.FloatValue := -QuestNumericLimit
      else OutValue.FloatValue := QuestNumericLimit;
    end
    else
      try
      OutValue.IntValue := Trunc(X / Y);
      except
        on EDivByZero do begin end;
      end;
  end;
end;
{ @end $4E05B0 }

{ @routine $4E0704 TCalcParse_ApplyModulo }
procedure TCalcParse.ApplyModulo(var Left, Right, OutValue: TCPVariant);
var
  X, Y: Extended;
  A, B: Integer;
  Negative: Boolean;
begin
  OutValue.Reset;
  Negative := False;
  if (Left.ValueKind <> cpvkFloat) and (Right.ValueKind <> cpvkFloat) then
  begin
    A := Left.AsInteger;
    B := Right.AsInteger;
    OutValue.ValueKind := cpvkInteger;
    Negative := A < 0;
    if B = 0 then
    begin
      if Negative then OutValue.IntValue := -QuestNumericLimit
      else OutValue.IntValue := QuestNumericLimit;
    end
    else
    begin
      OutValue.IntValue := Abs(A) mod Abs(B);
      if Negative then OutValue.IntValue := OutValue.IntValue * -1;
    end;
  end
  else
  begin
    X := Left.AsExtended;
    Y := Trunc(Right.AsExtended);
    if Y = 0 then
    begin
      if X < 0 then OutValue.FloatValue := -QuestNumericLimit
      else OutValue.FloatValue := QuestNumericLimit;
    end
    else
      try
        if Y < 0 then Y := Y * -1;
        if X < 0 then
        begin
          X := X * -1;
          Negative := True;
        end;
        OutValue.ValueKind := cpvkFloat;
        OutValue.FloatValue := Trunc(X - Trunc(X / Y) * Y);
        if Negative then OutValue.FloatValue := OutValue.FloatValue * -1;
      except
        on EDivByZero do begin end;
      end;
  end;
end;
{ @end $4E0704 }

{ @routine $4E0934 TCalcParse_ApplyRange }
procedure TCalcParse.ApplyRange(var Left, Right, OutValue: TCPVariant);
var
  Minimum, Maximum: Int64;
begin
  OutValue.Reset;
  Maximum := 0;
  Minimum := 0;
  if Left.ValueKind = cpvkFloat then Minimum := System.Round(Left.FloatValue)
  else if Left.ValueKind = cpvkInteger then Minimum := Left.IntValue
  else if Left.ValueKind = cpvkRange then Minimum := TCPDiapazone(Left.Range).GetMinimum;
  if Right.ValueKind = cpvkFloat then Maximum := System.Round(Right.FloatValue)
  else if Right.ValueKind = cpvkInteger then Maximum := Right.IntValue
  else if Right.ValueKind = cpvkRange then Maximum := TCPDiapazone(Right.Range).GetMaximum;
  OutValue.ValueKind := cpvkRange;
  TCPDiapazone(OutValue.Range).AddRange(Minimum, Maximum);
end;
{ @end $4E0934 }

{ @routine $4E0A48 TCalcParse_ApplyMembership }
procedure TCalcParse.ApplyMembership(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkInteger;
  if (Left.ValueKind <> cpvkRange) and (Right.ValueKind <> cpvkRange) then
  begin
    if Left.AsExtended = Right.AsExtended then OutValue.IntValue := 1
    else OutValue.IntValue := 0;
  end
  else if (Left.ValueKind = cpvkRange) and (Right.ValueKind <> cpvkRange) then
  begin
    if TCPDiapazone(Left.Range).Contains(Right.AsExtended) then OutValue.IntValue := 1
    else OutValue.IntValue := 0;
  end
  else if (Left.ValueKind <> cpvkRange) and (Right.ValueKind = cpvkRange) then
  begin
    if TCPDiapazone(Right.Range).Contains(Left.AsExtended) then OutValue.IntValue := 1
    else OutValue.IntValue := 0;
  end
  else if (Left.ValueKind = cpvkRange) and (Right.ValueKind = cpvkRange) then
  begin
    if TCPDiapazone(Right.Range).Contains(Left.AsInteger) then OutValue.IntValue := 1
    else OutValue.IntValue := 0;
  end;
end;
{ @end $4E0A48 }

{ @routine $4E0BCC TCalcParse_ApplyLessThan }
procedure TCalcParse.ApplyLessThan(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkInteger;
  if Left.AsExtended < Right.AsExtended then
    OutValue.IntValue := 1
  else
    OutValue.IntValue := 0;
end;
{ @end $4E0BCC }

{ @routine $4E0C30 TCalcParse_ApplyGreaterThan }
procedure TCalcParse.ApplyGreaterThan(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkInteger;
  if Left.AsExtended > Right.AsExtended then
    OutValue.IntValue := 1
  else
    OutValue.IntValue := 0;
end;
{ @end $4E0C30 }

{ @routine $4E0C94 TCalcParse_ApplyLessOrEqual }
procedure TCalcParse.ApplyLessOrEqual(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkInteger;
  if Left.AsExtended <= Right.AsExtended then
    OutValue.IntValue := 1
  else
    OutValue.IntValue := 0;
end;
{ @end $4E0C94 }

{ @routine $4E0CF8 TCalcParse_ApplyGreaterOrEqual }
procedure TCalcParse.ApplyGreaterOrEqual(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkInteger;
  if Left.AsExtended >= Right.AsExtended then
    OutValue.IntValue := 1
  else
    OutValue.IntValue := 0;
end;
{ @end $4E0CF8 }

{ @routine $4E0D5C TCalcParse_ApplyEqual }
procedure TCalcParse.ApplyEqual(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkInteger;
  if Left.AsExtended = Right.AsExtended then
    OutValue.IntValue := 1
  else
    OutValue.IntValue := 0;
end;
{ @end $4E0D5C }

{ @routine $4E0DC0 TCalcParse_ApplyNotEqual }
procedure TCalcParse.ApplyNotEqual(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  OutValue.ValueKind := cpvkInteger;
  if Left.AsExtended <> Right.AsExtended then
    OutValue.IntValue := 1
  else
    OutValue.IntValue := 0;
end;
{ @end $4E0DC0 }

{ @routine $4E0E24 TCalcParse_ApplyAnd }
procedure TCalcParse.ApplyAnd(var Left, Right, OutValue: TCPVariant);
begin
  OutValue.Reset;
  if (Left.ValueKind <> cpvkRange) and (Right.ValueKind > cpvkRange) then
  begin
    OutValue.ValueKind := cpvkInteger;
    if (Left.AsExtended <> 0) and (Right.AsExtended <> 0) then OutValue.IntValue := 1
    else OutValue.IntValue := 0;
  end
  else if (Left.ValueKind = cpvkRange) and (Right.ValueKind = cpvkRange) then
  begin
    OutValue.Assign(Left, False);
    TCPDiapazone(OutValue.Range).Append(Right.Range);
  end
  else if (Left.ValueKind <> cpvkRange) and (Right.ValueKind = cpvkRange) then
  begin
    OutValue.Assign(Right, False);
    if Left.ValueKind = cpvkInteger then TCPDiapazone(OutValue.Range).AddRange(Left.IntValue, Left.IntValue)
    else TCPDiapazone(OutValue.Range).AddValue(Left.FloatValue);
  end
  else if (Left.ValueKind = cpvkRange) and (Right.ValueKind <> cpvkRange) then
  begin
    OutValue.Assign(Left, False);
    if Right.ValueKind = cpvkInteger then TCPDiapazone(OutValue.Range).AddRange(Right.IntValue, Right.IntValue)
    else TCPDiapazone(OutValue.Range).AddValue(Right.FloatValue);
  end;
end;
{ @end $4E0E24 }

{ @routine $4E0FE0 TCalcParse_ApplyOr }
procedure TCalcParse.ApplyOr(var Left, Right, OutValue: TCPVariant);
begin
  if (Left.ValueKind <> cpvkRange) and (Right.ValueKind > cpvkRange) then
  begin
    OutValue.ValueKind := cpvkInteger;
    if (Left.AsExtended <> 0) or (Right.AsExtended <> 0) then OutValue.IntValue := 1
    else OutValue.IntValue := 0;
  end
  else if (Left.ValueKind = cpvkRange) and (Right.ValueKind = cpvkRange) then
  begin
    OutValue.Assign(Left, False);
    TCPDiapazone(OutValue.Range).Append(Right.Range);
  end
  else if (Left.ValueKind <> cpvkRange) and (Right.ValueKind = cpvkRange) then
  begin
    OutValue.Assign(Right, False);
    if Left.ValueKind = cpvkInteger then TCPDiapazone(OutValue.Range).AddRange(Left.IntValue, Left.IntValue)
    else TCPDiapazone(OutValue.Range).AddValue(Left.FloatValue);
  end
  else if (Left.ValueKind = cpvkRange) and (Right.ValueKind <> cpvkRange) then
  begin
    OutValue.Assign(Left, False);
    if Right.ValueKind = cpvkInteger then TCPDiapazone(OutValue.Range).AddRange(Right.IntValue, Right.IntValue)
    else TCPDiapazone(OutValue.Range).AddValue(Right.FloatValue);
  end;
end;
{ @end $4E0FE0 }

{ @routine $4E1194 TCalcParse_NormalizeTokens }
function TCalcParse.NormalizeTokens(var Text: WideString): WideString;
var
  Previous, Current: WideString;
  Index: Integer;
begin
  Current := WideString(SysUtils.LowerCase(AnsiString(TrimWideString(Text))));
  repeat
    Previous := Current;
    Current := ReplaceAllWideString(Current, 'pct', '%');
    Current := ReplaceAllWideString(Current, 'div', 'f');
    Current := ReplaceAllWideString(Current, 'mod', 'g');
    Current := ReplaceAllWideString(Current, 'in', '#');
    Current := ReplaceAllWideString(Current, 'to', '$');
    Current := ReplaceAllWideString(Current, 'or', '|');
    Current := ReplaceAllWideString(Current, 'and', '&');
    Current := ReplaceAllWideString(Current, '<>', 'e');
    Current := ReplaceAllWideString(Current, '>=', 'c');
    Current := ReplaceAllWideString(Current, '<=', 'b');
    Current := ReplaceAllWideString(Current, '..', 'h');
    Current := ReplaceAllWideString(Current, '.', ',');
    Current := ReplaceAllWideString(Current, '  ', ' ');
    Current := ReplaceAllWideString(Current, 'd', '');
    Current := ReplaceAllWideString(Current, 'm', '');
    Current := ReplaceAllWideString(Current, 'o', '');
    Current := ReplaceAllWideString(Current, 't', '');
    Current := ReplaceAllWideString(Current, 'i', '');
    Current := ReplaceAllWideString(Current, 'a', '');
    Current := ReplaceAllWideString(Current, 'n', '');
  until Current = Previous;
  repeat
    Previous := Current;
    Index := FindTextOffsetW(Current, ' ');
    while Index > 0 do
    begin
      if (FindTextOffsetW('%fg#$|&ecbh*+/-()><=[]{}', WideString(Current[Index])) < 0) and
        (FindTextOffsetW('%fg#$|&ecbh*+/-()><=[]{}', WideString(Current[Index + 2])) < 0) then
        Index := FindTextOffsetW(Current, ' ', Index + 1)
      else
      begin
        Current := CopyWideStringUnchecked(Current, 1, Index) +
          CopyWideStringUnchecked(Current, Index + 2, Length(Current) - Index - 1);
        Index := FindTextOffsetW(Current, ' ', Index);
      end;
    end;
  until Current = Previous;
  Result := '(' + Previous + ')';
end;
{ @end $4E1194 }

{ @routine $4E1768 TCalcParse_FormatTokens }
function TCalcParse.FormatTokens(var Text: WideString): WideString;
var
  Previous, Current, Inner: WideString;
  Count, i: Integer;
begin
  Current := WideString(SysUtils.LowerCase(AnsiString(Text)));
  Current := ReplaceAllWideString(Current, '$', ' to ');
  Current := ReplaceAllWideString(Current, '#', ' in ');
  Current := ReplaceAllWideString(Current, '|', ' or ');
  Current := ReplaceAllWideString(Current, '&', ' and ');
  Current := ReplaceAllWideString(Current, 'e', '<>');
  Current := ReplaceAllWideString(Current, 'c', '>=');
  Current := ReplaceAllWideString(Current, 'b', '<=');
  Current := ReplaceAllWideString(Current, 'f', ' div ');
  Current := ReplaceAllWideString(Current, 'g', ' mod ');
  Current := ReplaceAllWideString(Current, 'h', '..');
  Current := ReplaceAllWideString(Current, '%', ' pct ');
  repeat
    Previous := Current;
    Current := ReplaceAllWideString(Current, '  ', ' ');
    Current := ReplaceAllWideString(Current, '(0-', '(-');
  until Current = Previous;
  Count := Length(Current);
  Inner := '';
  if (Count >= 2) and (Current[1] = '(') and (Current[Count] = ')') then
  begin
    for i := 2 to Count - 1 do Inner := Inner + Current[i];
    if HasBalancedParenthesesInSlice(Current, 2, Count - 1) then Previous := Inner;
  end;
  Result := Previous;
end;
{ @end $4E1768 }

{ @routine $4E1B7C TCalcParse_GetOperatorRank }
function TCalcParse.GetOperatorRank(Token: WideChar): Integer;
var
  Rank: Integer;
begin
  Rank := -1;
  case Token of
    '^': Rank := 1;
    '/': Rank := 1;
    'f': Rank := 1;
    'g': Rank := 1;
    '*': Rank := 2;
    '%': Rank := 2;
    '-': Rank := 3;
    '+': Rank := 4;
    '$': Rank := 5;
    '#': Rank := 6;
    'c': Rank := 7;
    'b': Rank := 7;
    'e': Rank := 7;
    '>': Rank := 7;
    '<': Rank := 7;
    '=': Rank := 7;
    '&': Rank := 8;
    '|': Rank := 9;
  end;
  Result := Rank;
end;
{ @end $4E1B7C }

{ @routine $4E1D0C TCalcParse_CollapseOperatorRun }
function TCalcParse.CollapseOperatorRun(const Text: WideString): WideString;
var
  i, MinusCount, PlusCount, Count: Integer;
  Operators: WideString;
begin
  Count := Length(Text);
  MinusCount := 0;
  PlusCount := 0;
  for i := 1 to Count do
  begin
    if Text[i] = '-' then Inc(MinusCount);
    if Text[i] = '+' then Inc(PlusCount);
  end;
  Operators := ReplaceAllWideString(Text, '-', '');
  Operators := ReplaceAllWideString(Operators, '+', '');
  if MinusCount mod 2 = 1 then Operators := Operators + '-'
  else if (PlusCount > 0) or (MinusCount > 0) then Operators := Operators + '+';
  Count := Length(Operators);
  MinusCount := 0;
  PlusCount := 0;
  for i := Count downto 1 do
    if GetOperatorRank(Operators[i]) >= MinusCount then
    begin
      PlusCount := i;
      MinusCount := GetOperatorRank(Operators[i]);
    end;
  Result := Operators[PlusCount];
end;
{ @end $4E1D0C }

{ @routine $4E1E98 TCalcParse_NormalizeFragments }
function TCalcParse.NormalizeFragments(const Text: WideString): WideString;
var
  Index, Count: Integer;
  Fragment, Output: WideString;
  Outside: Boolean;
begin
  Output := '';
  Index := 1;
  Count := Length(Text);
  Fragment := '';
  Outside := True;
  while Index <= Count do
  begin
    if Outside then
    begin
      if Text[Index] = '[' then
      begin
        Output := Output + NormalizeScalarFragment(Fragment);
        Fragment := '[';
        Outside := False;
        Inc(Index);
        Continue;
      end
      else if Text[Index] <> '[' then
      begin
        Fragment := Fragment + Text[Index];
        Inc(Index);
        if Index > Count then Output := Output + NormalizeScalarFragment(Fragment);
        Continue;
      end;
    end;
    if not Outside then
    begin
      if (Index > Count) or (Text[Index] = ']') then
      begin
        Output := Output + NormalizeBracketFragment(Fragment + ']');
        Fragment := '';
        Outside := True;
      end
      else Fragment := Fragment + Text[Index];
      Inc(Index);
    end;
  end;
  Result := Output;
end;
{ @end $4E1E98 }

{ @routine $4E2068 TCalcParse_NormalizeScalarFragment }
function TCalcParse.NormalizeScalarFragment(Text: WideString): WideString;
var
  Previous, Working, Output: WideString;
  i, Count: Integer;
begin
  Previous := '';
  Count := Length(Text);
  for i := 1 to Count do
  begin
    case Text[i] of
      '^': ;
      '+': ;
      '-': ;
      '*': ;
      '/': ;
      '#': ;
      '%': ;
      '$': ;
      'c': ;
      'b': ;
      'e': ;
      'f': ;
      'g': ;
      '=': ;
      '>': ;
      '<': ;
      '&': ;
      '|': ;
      '0'..'9': ;
      ',': ;
      '(': ;
      ')': ;
      ' ': ;
    else Continue;
    end;
    Previous := Previous + Text[i];
  end;
  Text := Previous;
  repeat
    Previous := Text;
    Working := Text;
    repeat
      Text := Working;
      Working := ReplaceAllWideString(Working, ')(', ')*(');
      Working := ReplaceAllWideString(Working, '.', ',');
      Working := ReplaceAllWideString(Working, ',,', ',');
      Working := ReplaceAllWideString(Working, '(,', '(0,');
      Working := ReplaceAllWideString(Working, '),', ')*0,');
      Working := ReplaceAllWideString(Working, ')0', ')*0');
      Working := ReplaceAllWideString(Working, ')1', ')*1');
      Working := ReplaceAllWideString(Working, ')2', ')*2');
      Working := ReplaceAllWideString(Working, ')3', ')*3');
      Working := ReplaceAllWideString(Working, ')4', ')*4');
      Working := ReplaceAllWideString(Working, ')5', ')*5');
      Working := ReplaceAllWideString(Working, ')6', ')*6');
      Working := ReplaceAllWideString(Working, ')7', ')*7');
      Working := ReplaceAllWideString(Working, ')8', ')*8');
      Working := ReplaceAllWideString(Working, ')9', ')*9');
      Working := ReplaceAllWideString(Working, ',(', ',*(');
      Working := ReplaceAllWideString(Working, '0(', '0*(');
      Working := ReplaceAllWideString(Working, '1(', '1*(');
      Working := ReplaceAllWideString(Working, '2(', '2*(');
      Working := ReplaceAllWideString(Working, '3(', '3*(');
      Working := ReplaceAllWideString(Working, '4(', '4*(');
      Working := ReplaceAllWideString(Working, '5(', '5*(');
      Working := ReplaceAllWideString(Working, '6(', '6*(');
      Working := ReplaceAllWideString(Working, '7(', '7*(');
      Working := ReplaceAllWideString(Working, '8(', '8*(');
      Working := ReplaceAllWideString(Working, '9(', '9*(');
    until Text = Working;
    Count := Length(Text);
    Working := '';
    Output := '';
    i := 1;
    while i <= Count do
    begin
      if (GetOperatorRank(Text[i]) > 0) and (i <= Count) then
      begin
        Working := '';
        while (GetOperatorRank(Text[i]) > 0) and (i <= Count) do
        begin
          Working := Working + Text[i];
          Inc(i);
        end;
        Output := Output + CollapseOperatorRun(Working);
      end;
      if GetOperatorRank(Text[i]) < 0 then
      begin
        Working := '';
        while (GetOperatorRank(Text[i]) < 0) and (i <= Count) do
        begin
          Working := Working + Text[i];
          Inc(i);
        end;
        Output := Output + Working;
      end;
    end;
    Text := Output;
    Working := Text;
    repeat
      Text := Working;
      Working := ReplaceAllWideString(Working, '(+', '(');
      Working := ReplaceAllWideString(Working, '(*', '(');
      Working := ReplaceAllWideString(Working, '(/', '(');
      Working := ReplaceAllWideString(Working, '(&', '(');
      Working := ReplaceAllWideString(Working, '(|', '(');
      Working := ReplaceAllWideString(Working, '(#', '(');
      Working := ReplaceAllWideString(Working, '($', '(');
      Working := ReplaceAllWideString(Working, '(%', '(');
      Working := ReplaceAllWideString(Working, '(c', '(');
      Working := ReplaceAllWideString(Working, '(b', '(');
      Working := ReplaceAllWideString(Working, '(e', '(');
      Working := ReplaceAllWideString(Working, '(f', '(');
      Working := ReplaceAllWideString(Working, '(g', '(');
      Working := ReplaceAllWideString(Working, '(<', '(');
      Working := ReplaceAllWideString(Working, '(>', '(');
      Working := ReplaceAllWideString(Working, '(=', '(');
      Working := ReplaceAllWideString(Working, '-)', ')');
      Working := ReplaceAllWideString(Working, '+)', ')');
      Working := ReplaceAllWideString(Working, '*)', ')');
      Working := ReplaceAllWideString(Working, '/)', ')');
      Working := ReplaceAllWideString(Working, '&)', ')');
      Working := ReplaceAllWideString(Working, '%)', ')');
      Working := ReplaceAllWideString(Working, '|)', ')');
      Working := ReplaceAllWideString(Working, '$)', ')');
      Working := ReplaceAllWideString(Working, '#)', ')');
      Working := ReplaceAllWideString(Working, 'c)', ')');
      Working := ReplaceAllWideString(Working, 'b)', ')');
      Working := ReplaceAllWideString(Working, 'e)', ')');
      Working := ReplaceAllWideString(Working, 'f)', ')');
      Working := ReplaceAllWideString(Working, 'g)', ')');
      Working := ReplaceAllWideString(Working, '>)', ')');
      Working := ReplaceAllWideString(Working, '<)', ')');
      Working := ReplaceAllWideString(Working, '=)', ')');
      Working := ReplaceAllWideString(Working, ')(', ')*(');
    until Text = Working;
  until Previous = Text;
  Result := Text;
end;
{ @end $4E2068 }

{ @routine $4E3070 TCalcParse_NormalizeBracketFragment }
function TCalcParse.NormalizeBracketFragment(Text: WideString): WideString;
begin
  if ReplaceAllWideString(Text, 'p', '') <> Text then
    Result := NormalizeParameterReference(Text)
  else Result := NormalizeRangeLiteral(Text);
end;
{ @end $4E3070 }

{ @routine $4E310C TCalcParse_NormalizeParameterReference }
function TCalcParse.NormalizeParameterReference(Text: WideString): WideString;
var
  Count, i: Integer;
  Digits: WideString;
begin
  Count := Length(Text);
  Digits := '';
  for i := 1 to Count do
  begin
    if Length(Digits) > 2 then Break;
    if (Text[i] >= '0') and (Text[i] <= '9') then Digits := Digits + Text[i];
  end;
  i := ExtractDigitsToIntW('0' + Digits);
  if i > 0 then Result := '[p' + IntToWideString(i) + ']'
  else
  begin
    Result := '[err]';
    InvalidParameterReference := True;
    HasError := True;
  end;
end;
{ @end $4E310C }

{ @routine $4E327C TCalcParse_NormalizeRangeLiteral }
function TCalcParse.NormalizeRangeLiteral(Text: WideString): WideString;
var
  i, Count: Integer;
  Clean: WideString;
  Range: TCPDiapazone;
begin
  Clean := '';
  Count := Length(Text);
  for i := 1 to Count do
  begin
    case Text[i] of
      '[', ']': Continue;
      '0'..'9', '-', 'h', ';': ;
    else
      Result := '[err]';
      InvalidRangeLiteral := True;
      HasError := True;
      Exit;
    end;
    Clean := Clean + Text[i];
  end;
  Text := ';' + Clean + ';';
  Clean := Text;
  repeat
    Text := Clean;
    Clean := ReplaceAllWideString(Clean, '--', '');
    Clean := ReplaceAllWideString(Clean, ';;', ';');
    Clean := ReplaceAllWideString(Clean, 'h;', ';');
    Clean := ReplaceAllWideString(Clean, ';h', ';');
    Clean := ReplaceAllWideString(Clean, '-;', ';');
    Clean := ReplaceAllWideString(Clean, '-h', 'h');
    Clean := ReplaceAllWideString(Clean, 'hh', 'h');
  until Text = Clean;
  if (Clean <> ';') and (Length(Text) > 0) then
  begin
    Text[1] := '[';
    Text[Length(Text)] := ']';
    Range := TCPDiapazone.Create;
    Range.LoadFromText(Text);
    Text := Range.ToText;
    Range.Destroy;
    Result := Text;
  end
  else
  begin
    Result := '[err]';
    InvalidRangeLiteral := True;
    HasError := True;
  end;
end;
{ @end $4E327C }

{ @routine $4E35A4 TCalcParse_InsertImplicitMultiplication }
function TCalcParse.InsertImplicitMultiplication(Text: WideString): WideString;
var
  Current: WideString;
begin
  Current := Text;
  repeat
    Text := Current;
    Current := ReplaceAllWideString(Current, '-,', '-0,');
    Current := ReplaceAllWideString(Current, ')[', ')*[');
    Current := ReplaceAllWideString(Current, '](', ']*(');
    Current := ReplaceAllWideString(Current, ')(', ')*(');
    Current := ReplaceAllWideString(Current, '][', ']*[');
    Current := ReplaceAllWideString(Current, '],', ']*0,');
    Current := ReplaceAllWideString(Current, ']0', ']*0');
    Current := ReplaceAllWideString(Current, ']1', ']*1');
    Current := ReplaceAllWideString(Current, ']2', ']*2');
    Current := ReplaceAllWideString(Current, ']3', ']*3');
    Current := ReplaceAllWideString(Current, ']4', ']*4');
    Current := ReplaceAllWideString(Current, ']5', ']*5');
    Current := ReplaceAllWideString(Current, ']6', ']*6');
    Current := ReplaceAllWideString(Current, ']7', ']*7');
    Current := ReplaceAllWideString(Current, ']8', ']*8');
    Current := ReplaceAllWideString(Current, ']9', ']*9');
    Current := ReplaceAllWideString(Current, ',[', ',*[');
    Current := ReplaceAllWideString(Current, '0[', '0*[');
    Current := ReplaceAllWideString(Current, '1[', '1*[');
    Current := ReplaceAllWideString(Current, '2[', '2*[');
    Current := ReplaceAllWideString(Current, '3[', '3*[');
    Current := ReplaceAllWideString(Current, '4[', '4*[');
    Current := ReplaceAllWideString(Current, '5[', '5*[');
    Current := ReplaceAllWideString(Current, '6[', '6*[');
    Current := ReplaceAllWideString(Current, '7[', '7*[');
    Current := ReplaceAllWideString(Current, '8[', '8*[');
    Current := ReplaceAllWideString(Current, '9[', '9*[');
  until Text = Current;
  Result := Text;
end;
{ @end $4E35A4 }

{ @routine $4E3C40 TCalcParse_FindTopLevelOperator }
function TCalcParse.FindTopLevelOperator(const Text: WideString; TextLength: Integer): Integer;
var
  Rank, BestRank, BestIndex, i, BracketDepth, ParenthesisDepth: Integer;
begin
  BestRank := 0;
  BestIndex := 0;
  BracketDepth := 0;
  ParenthesisDepth := 0;
  for i := 1 to TextLength do
  begin
    if Text[i] = '(' then Inc(ParenthesisDepth);
    if Text[i] = '[' then Inc(BracketDepth);
    if Text[i] = ')' then Dec(ParenthesisDepth);
    if Text[i] = ']' then Dec(BracketDepth);
    if (ParenthesisDepth = 0) and (BracketDepth = 0) then
    begin
      Rank := GetOperatorRank(Text[i]);
      if BestRank <= Rank then
      begin
        BestRank := Rank;
        BestIndex := i;
      end;
    end;
  end;
  Result := BestIndex;
end;
{ @end $4E3C40 }

{ @routine $4E3D0C TCalcParse_EvaluateExpression }
function TCalcParse.EvaluateExpression(Text: WideString): TCPVariant;
var
  Count: Integer;
  Inner, LeftText, RightText: WideString;
  i, Index: Integer;
  Left, Right, Value: TCPVariant;
begin
  Value := TCPVariant.Create;
  Left := TCPVariant.Create;
  Right := TCPVariant.Create;
  if not EvaluationError then
  begin
    Count := Length(Text);
    if not Value.TryLoadFromText(Text) then
    begin
      if (Text[1] = '(') and (Text[Count] = ')') and HasBalancedParenthesesInSlice(Text, 2, Count - 1) then
      begin
        Inner := '';
        for i := 2 to Count - 1 do Inner := Inner + Text[i];
        if Length(Inner) = 0 then HasError := True
        else Value.Assign(EvaluateExpression(Inner), False);
      end
      else
      begin
        Index := FindTopLevelOperator(Text, Count);
        if Index < 1 then EvaluationError := True
        else
        begin
          LeftText := '';
          for i := 1 to Index - 1 do LeftText := LeftText + Text[i];
          RightText := '';
          for i := Index + 1 to Count do RightText := RightText + Text[i];
          Right.Assign(EvaluateExpression(RightText), False);
          if not EvaluationError then
          begin
            Left.Assign(EvaluateExpression(LeftText), False);
            if not EvaluationError then
              try
                  if Text[Index] = '^' then ApplyPower(Left, Right, Value)
                  else if Text[Index] = '+' then ApplyAdd(Left, Right, Value)
                  else if Text[Index] = '-' then ApplySubtract(Left, Right, Value)
                  else if Text[Index] = '*' then ApplyMultiply(Left, Right, Value)
                  else if Text[Index] = '/' then ApplyDivide(Left, Right, Value)
                  else if Text[Index] = 'f' then ApplyIntDivide(Left, Right, Value)
                  else if Text[Index] = 'g' then ApplyModulo(Left, Right, Value)
                  else if Text[Index] = '%' then ApplyPercentChange(Left, Right, Value)
                  else if Text[Index] = '$' then ApplyRange(Left, Right, Value)
                  else if Text[Index] = '#' then ApplyMembership(Left, Right, Value)
                  else if Text[Index] = '>' then ApplyGreaterThan(Left, Right, Value)
                  else if Text[Index] = '<' then ApplyLessThan(Left, Right, Value)
                  else if Text[Index] = 'c' then ApplyGreaterOrEqual(Left, Right, Value)
                  else if Text[Index] = 'b' then ApplyLessOrEqual(Left, Right, Value)
                  else if Text[Index] = 'e' then ApplyNotEqual(Left, Right, Value)
                  else if Text[Index] = '=' then ApplyEqual(Left, Right, Value)
                  else if Text[Index] = '&' then ApplyAnd(Left, Right, Value)
                  else if Text[Index] = '|' then ApplyOr(Left, Right, Value);
              except
                  on EMathError do
                  begin
                    EvaluationError := True;
                    HasError := True;
                  end;
                  on EInvalidOp do
                  begin
                    EvaluationError := True;
                    HasError := True;
                  end;
                  on EOverflow do
                  begin
                    EvaluationError := True;
                    HasError := True;
                  end;
                  on EZeroDivide do
                  begin
                    EvaluationError := True;
                    HasError := True;
                  end;
              end;
          end;
        end;
      end;
    end;
  end;
  Result := TCPVariant.Create;
  Result.Assign(Value, False);
  Value.Destroy;
  Right.Destroy;
  Left.Destroy;
end;
{ @end $4E3D0C }

{ @routine $4E42C4 TCalcParse_Evaluate }
procedure TCalcParse.Evaluate(Parameters: TList);
var
  Value: TCPVariant;
begin
  Value := TCPVariant.Create;
  if not HasError then
  begin
    Value.Assign(EvaluateExpression('(' + SubstituteParameters(Parameters) + ')'), False);
    try
      ResultValue := Value.AsInteger;
    except
      on EInvalidOp do
      begin
        EvaluationError := True;
        HasError := True;
        ResultValue := 0;
      end;
    end;
    if EvaluationError then HasError := True;
  end;
end;
{ @end $4E42C4 }

{ @routine $4E43E0 TCalcParse_Prepare }
procedure TCalcParse.Prepare(Text: WideString; DefaultParameterIndex: Integer);
var
  Count, i: Integer;
  Readable: WideString;
begin
  Reset;
  SourceText := Text;
  Text := NormalizeTokens(Text);
  Text := NormalizeFragments(Text);
  Text := InsertImplicitMultiplication(Text);
  Text := ClampNumericLiterals(Text);
  UnbalancedParentheses := not HasBalancedParentheses(Text);
  if UnbalancedParentheses then HasError := True;
  Readable := Text;
  if not HasError then
  begin
    Count := Length(Text);
    if (Count >= 2) and (Text[1] = '(') and (Text[Count] = ')') and
      HasBalancedParenthesesInSlice(Text, 2, Count - 1) then
    begin
      Readable := '';
      for i := 2 to Count - 1 do Readable := Readable + Text[i];
    end;
  end;
  if SourceText <> FormatTokens(Readable) then SourceWasChanged := True;
  if (Text = '') or (Text = '[p' + IntToWideString(DefaultParameterIndex) + ']') then
  begin
    UsesDefaultParameter := True;
    Text := '[p' + IntToWideString(DefaultParameterIndex) + ']';
  end;
  Expression := Text;
end;
{ @end $4E43E0 }

{ @routine $4E4634 TCalcParse_Create }
constructor TCalcParse.Create;
begin
  Reset;
end;
{ @end $4E4634 }

{ @routine $4E4674 TCalcParse_Reset }
procedure TCalcParse.Reset;
begin
  SourceText := '';
  Expression := '';
  ResultValue := 0;
  ResetValue10 := 0;
  SourceWasChanged := False;
  UnbalancedParentheses := False;
  InvalidNumericLiteral := False;
  InvalidParameterReference := False;
  InvalidRangeLiteral := False;
  EvaluationError := False;
  UsesDefaultParameter := False;
  HasError := False;
end;
{ @end $4E4674 }

{ @routine $4E46DC TCalcParse_HasBalancedParenthesesInSlice }
function TCalcParse.HasBalancedParenthesesInSlice(const Text: WideString; FirstIndex, LastIndex: Integer): Boolean;
var
  Depth, i: Integer;
  Balanced: Boolean;
begin
  Depth := 0;
  Balanced := True;
  for i := FirstIndex to LastIndex do
  begin
    if Text[i] = '(' then Inc(Depth);
    if Text[i] = ')' then Dec(Depth);
    if Depth < 0 then
    begin
      Balanced := False;
      Break;
    end;
  end;
  if Depth <> 0 then Balanced := False;
  Result := Balanced;
end;
{ @end $4E46DC }

{ @routine $4E4754 TCalcParse_SubstituteParameters }
function TCalcParse.SubstituteParameters(Parameters: TList): WideString;
var
  i: Integer;
  Text: WideString;
  Parameter: TParameter;
begin
  Text := Expression;
  for i := 1 to Parameters.Count do
  begin
    Parameter := TParameter(Parameters[i - 1]);
    if Parameter.Value < 0 then
      Text := ReplaceAllWideString(Text, '[p' + IntToWideString(i) + ']', '(0' + IntToWideString(Parameter.Value) + ')')
    else Text := ReplaceAllWideString(Text, '[p' + IntToWideString(i) + ']', IntToWideString(Parameter.Value));
  end;
  Result := Text;
end;
{ @end $4E4754 }

{ @routine $4E48EC TCalcParse_HasBalancedParentheses }
function TCalcParse.HasBalancedParentheses(const Text: WideString): Boolean;
var
  Balanced: Boolean;
begin
  Balanced := HasBalancedParenthesesInSlice(Text, 1, Length(Text));
  Result := Balanced;
end;
{ @end $4E48EC }

{ @routine $4E4924 TCalcParse_ClampNumericLiterals }
function TCalcParse.ClampNumericLiterals(Text: WideString): WideString;
var
  Index, Count: Integer;
  Value: Extended;
  Output: WideString;
  Digits, Replacement: AnsiString;
  SavedSeparator: AnsiChar;
begin
  Index := 1;
  Count := Length(Text);
  Digits := '';
  Output := '';
  Value := 0;
  while Index <= Count do
  begin
    if ((Text[Index] >= '0') and (Text[Index] <= '9')) or (Text[Index] = ',') then
      Digits := AnsiString(WideString(Digits) + Text[Index])
    else if Digits <> '' then
    begin
      SavedSeparator := SysUtils.DecimalSeparator;
      try
        SysUtils.DecimalSeparator := ',';
        Value := SysUtils.StrToFloat(Digits);
        SysUtils.DecimalSeparator := SavedSeparator;
      except
        on EConvertError do
        begin
          HasError := True;
          InvalidNumericLiteral := True;
          SysUtils.DecimalSeparator := SavedSeparator;
          Exit;
        end;
      end;
        if Value > 999999999 then Replacement := '999999999'
        else if (Value < 0.0001) and (Value <> 0) then Replacement := '0.0001'
        else Replacement := Digits;
        Output := Output + WideString(Replacement) + Text[Index];
        Digits := '';
    end
    else Output := Output + Text[Index];
    Inc(Index);
  end;
  Result := Output;
end;
{ @end $4E4924 }

end.
