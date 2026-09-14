unit PathClass;
// Unit bracket (inferred): .text 0x004E36A8..0x004E4C55; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Struct, EventClass, ParameterDeltaClass, SequenceClass, TextFieldClass;

type
  TPath = class(TObjectEx) // @size 0xE8
  public
    ParameterChanges: TList; // @offset 0x04
    Priority: Double; // @offset 0x08
    IsAutomatic: Boolean; // @offset 0x10
    UnknownFlag: Byte; // @offset 0x11  Only reset; its purpose is unresolved.
    AlwaysShow: Boolean; // @offset 0x12
    Available: Boolean; // @offset 0x13
    Days: Integer; // @offset 0x14
    DisplayOrder: Integer; // @offset 0x18
    Id: Integer; // @offset 0x1C
    TraversalLimit: Integer; // @offset 0x20
    TraversalCount: Integer; // @offset 0x24
    FromLocationId: Integer; // @offset 0x28
    ToLocationId: Integer; // @offset 0x2C
    Caption: TTextField; // @offset 0x30
    Event: TEvent; // @offset 0x34
    ConditionExpression: TTextField; // @offset 0x38
    // No recovered routine accesses +0x3C..+0xE3.
    Sequence: TSequence; // @offset 0xE4

    constructor Create; // @addr 0x4E36FC @ida "TPath *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4E37B0 @ida "void __usercall $name(TPath *Self@<eax>, __int8 DestroyFlags@<dl>);" @note "Frees the sequence and containers without calling Reset."
    procedure Reset; // @addr 0x4E3848
    function GetParameterChangeCount: Integer; // @addr 0x4E394C
    function GetParameterChange(Index: Integer): TParameterDelta; // @addr 0x4E3968 @note "Index is one-based."
    procedure AddParameterChange(Change: TParameterDelta); // @addr 0x4E3990
    function FindParameterChange(ParameterIndex: Integer): TParameterDelta; // @addr 0x4E3BF8
    procedure PruneParameterChanges(Parameters: TList); // @addr 0x4E3A24 @note "Removed entries are not freed."
    procedure ApplyParameterChanges(var Parameters: TList); // @addr 0x4E39B0 @note "Evaluates every expression before applying any change."
    function CheckAvailable(Parameters: TList): Boolean; // @addr 0x4E3AC8 @note "Updates Available. Invalid condition expressions are ignored; parameter constraints still apply."
    procedure LoadFromReader(Reader: TBufEC; Parameters: TList); // @addr 0x4E3C54 @note "Path format used by quest versions 1111111125 and later."

    // Legacy readers derive IsAutomatic from the trimmed caption.
    procedure LoadLegacyV0FromReader(Reader: TBufEC); // @addr 0x4E4B30 @note "Quest version 1111111111."
    procedure LoadLegacyV1FromReader(Reader: TBufEC); // @addr 0x4E49FC @note "Quest versions 1111111112..1111111113."
    procedure LoadLegacyV2FromReader(Reader: TBufEC); // @addr 0x4E48B8 @note "Quest version 1111111114."
    procedure LoadLegacyV3FromReader(Reader: TBufEC); // @addr 0x4E4774 @note "Quest version 1111111115."
    procedure LoadLegacyV4FromReader(Reader: TBufEC); // @addr 0x4E4614 @note "Quest version 1111111116."
    procedure LoadLegacyV5FromReader(Reader: TBufEC); // @addr 0x4E44B4 @note "Quest versions 1111111117..1111111118."
    procedure LoadLegacyV6FromReader(Reader: TBufEC); // @addr 0x4E4344 @note "Quest versions 1111111119..1111111121."
    procedure LoadLegacyV7FromReader(Reader: TBufEC); // @addr 0x4E41C8 @note "Quest version 1111111122."
    procedure LoadLegacyV8FromReader(Reader: TBufEC); // @addr 0x4E404C @note "Quest version 1111111123."
    procedure LoadLegacyV9FromReader(Reader: TBufEC); // @addr 0x4E3ED0 @note "Quest version 1111111124."
  end;

implementation

uses CalcParseClass, EC_Str, ParameterClass;

{ @routine $4E36FC TPath_Create }
constructor TPath.Create;
begin
  inherited Create;
  Caption := TTextField.Create;
  Event := TEvent.Create;
  ConditionExpression := TTextField.Create;
  ParameterChanges := TList.Create;
  Sequence := nil;
  Reset;
  Id := 0;
  ToLocationId := 0;
  FromLocationId := 0;
end;
{ @end $4E36FC }

{ @routine $4E37B0 TPath_Destroy }
destructor TPath.Destroy;
begin
  if Sequence <> nil then Sequence.Free;
  Caption.Free;
  Caption := nil;
  Event.Free;
  Event := nil;
  ConditionExpression.Free;
  ConditionExpression := nil;
  // Native destruction frees the list without resetting its owned entries.
  ParameterChanges.Free;
  ParameterChanges := nil;
  inherited Destroy;
end;
{ @end $4E37B0 }

{ @routine $4E3848 TPath_Reset }
procedure TPath.Reset;
var
  i: Integer;
begin
  Days := 0;
  DisplayOrder := 5;
  Priority := 1;
  TraversalLimit := 0;
  TraversalCount := 0;
  Id := 0;
  FromLocationId := 0;
  ToLocationId := 0;
  Caption.Text := '';
  Event.Text.Text := '';
  Event.Picture.Text := '';
  Event.Sound.Text := '';
  Event.Music.Text := '';
  ConditionExpression.Text := '';
  for i := 1 to GetParameterChangeCount do GetParameterChange(i).Free;
  ParameterChanges.Clear;
  IsAutomatic := True;
  UnknownFlag := 0;
  AlwaysShow := False;
end;
{ @end $4E3848 }

{ @routine $4E394C TPath_GetParameterChangeCount }
function TPath.GetParameterChangeCount: Integer;
begin
  Result := ParameterChanges.Count;
end;
{ @end $4E394C }

{ @routine $4E3968 TPath_GetParameterChange }
function TPath.GetParameterChange(Index: Integer): TParameterDelta;
begin
  Result := TParameterDelta(ParameterChanges[Index - 1]);
end;
{ @end $4E3968 }

{ @routine $4E3990 TPath_AddParameterChange }
procedure TPath.AddParameterChange(Change: TParameterDelta);
begin
  ParameterChanges.Add(Change);
end;
{ @end $4E3990 }

{ @routine $4E39B0 TPath_ApplyParameterChanges }
procedure TPath.ApplyParameterChanges(var Parameters: TList);
var
  i: Integer;
begin
  for i := 1 to GetParameterChangeCount do
    GetParameterChange(i).EvaluateChangeExpression(Parameters);
  for i := 1 to GetParameterChangeCount do
    GetParameterChange(i).ApplyChange(Parameters);
end;
{ @end $4E39B0 }

{ @routine $4E3A24 TPath_PruneParameterChanges }
procedure TPath.PruneParameterChanges(Parameters: TList);
var
  i: Integer;
begin
  for i := GetParameterChangeCount downto 1 do
    if (GetParameterChange(i).ParameterIndex < 1) or (GetParameterChange(i).ParameterIndex > Parameters.Count) then
      ParameterChanges.Delete(i - 1)
    else if GetParameterChange(i).HasNoChange(Parameters) then
      if GetParameterChange(i).HasNoValueConstraint(Parameters) then
      ParameterChanges.Delete(i - 1);
end;
{ @end $4E3A24 }

{ @routine $4E3AC8 TPath_CheckAvailable }
function TPath.CheckAvailable(Parameters: TList): Boolean;
var
  Calc: TCalcParse;
  i: Integer;
begin
  Available := False;
  Result := False;
  if TrimWideString(ConditionExpression.Text) <> '' then
  begin
    Calc := TCalcParse.Create;
    Calc.Reset;
    Calc.Prepare(TrimWideString(ConditionExpression.Text), 0);
    // Native cleanup occurs only after a successfully prepared expression.
    if not Calc.HasError and not Calc.UsesDefaultParameter then
    begin
      Calc.Evaluate(Parameters);
      if not Calc.HasError and (Calc.ResultValue = 0) then
      begin
        Calc.Destroy;
        Exit;
      end
      else Calc.Destroy;
    end;
  end;
  for i := 1 to GetParameterChangeCount do
    if not GetParameterChange(i).AcceptsParameter(Parameters) then Exit;
  Available := True;
  Result := True;
end;
{ @end $4E3AC8 }

{ @routine $4E3BF8 TPath_FindParameterChange }
function TPath.FindParameterChange(ParameterIndex: Integer): TParameterDelta;
var
  i: Integer;
begin
  for i := 1 to GetParameterChangeCount do
    if GetParameterChange(i).ParameterIndex = ParameterIndex then
    begin
      Result := GetParameterChange(i);
      Exit;
    end;
  Result := nil;
end;
{ @end $4E3BF8 }

{ @routine $4E3C54 TPath_LoadFromReader }
procedure TPath.LoadFromReader(Reader: TBufEC; Parameters: TList);
var
  i, ParameterIndex, Count: Integer;
  Change: TParameterDelta;
  Parameter: TParameter;
begin
  Reset;
  Priority := Reader.GetDouble;
  Days := Reader.GetInt32;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  DisplayOrder := Reader.GetInt32;
  Count := Reader.GetInt32;
  for i := 1 to Count do
  begin
    ParameterIndex := Reader.GetInt32;
    Change := FindParameterChange(ParameterIndex);
    if Change = nil then
    begin
      Change := TParameterDelta.Create;
      Change.ParameterIndex := ParameterIndex;
      Parameter := TParameter(Parameters[ParameterIndex - 1]);
      Change.MinValue := Parameter.MinValue;
      Change.MaxValue := Parameter.MaxValue;
      AddParameterChange(Change);
    end;
    Change.LoadValueConstraintsFromReader(Reader);
  end;
  Count := Reader.GetInt32;
  for i := 1 to Count do
  begin
    ParameterIndex := Reader.GetInt32;
    Change := FindParameterChange(ParameterIndex);
    if Change = nil then
    begin
      Change := TParameterDelta.Create;
      Change.ParameterIndex := ParameterIndex;
      Parameter := TParameter(Parameters[ParameterIndex - 1]);
      Change.MinValue := Parameter.MinValue;
      Change.MaxValue := Parameter.MaxValue;
      AddParameterChange(Change);
    end;
    Change.LoadChangeFromReader(Reader);
  end;
  ConditionExpression.LoadTextLinesFromReader(Reader);
  Caption.LoadTextLinesFromReader(Reader);
  Event.Text.LoadTextLinesFromReader(Reader);
  Event.Picture.LoadTextLinesFromReader(Reader);
  Event.Sound.LoadTextLinesFromReader(Reader);
  Event.Music.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E3C54 }

{ @routine $4E3ED0 TPath_LoadLegacyV9FromReader }
procedure TPath.LoadLegacyV9FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Priority := Reader.GetDouble;
  Days := Reader.GetInt32;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  DisplayOrder := Reader.GetInt32;
  for i := 1 to 96 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV3FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  ConditionExpression.LoadTextLinesFromReader(Reader);
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E3ED0 }

{ @routine $4E404C TPath_LoadLegacyV8FromReader }
procedure TPath.LoadLegacyV8FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Priority := Reader.GetDouble;
  Days := Reader.GetInt32;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  DisplayOrder := Reader.GetInt32;
  for i := 1 to 48 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV3FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  ConditionExpression.LoadTextLinesFromReader(Reader);
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E404C }

{ @routine $4E41C8 TPath_LoadLegacyV7FromReader }
procedure TPath.LoadLegacyV7FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Priority := Reader.GetDouble;
  Days := Reader.GetInt32;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  DisplayOrder := Reader.GetInt32;
  for i := 1 to 24 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV3FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  ConditionExpression.LoadTextLinesFromReader(Reader);
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E41C8 }

{ @routine $4E4344 TPath_LoadLegacyV6FromReader }
procedure TPath.LoadLegacyV6FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Priority := Reader.GetDouble;
  Days := Reader.GetInt32;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  for i := 1 to 24 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV3FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  ConditionExpression.LoadTextLinesFromReader(Reader);
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E4344 }

{ @routine $4E44B4 TPath_LoadLegacyV5FromReader }
procedure TPath.LoadLegacyV5FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Priority := Reader.GetDouble;
  Days := Reader.GetInt32;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  for i := 1 to 12 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV2FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E44B4 }

{ @routine $4E4614 TPath_LoadLegacyV4FromReader }
procedure TPath.LoadLegacyV4FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Priority := Reader.GetDouble;
  Days := Reader.GetInt32;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  for i := 1 to 12 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV1FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E4614 }

{ @routine $4E4774 TPath_LoadLegacyV3FromReader }
procedure TPath.LoadLegacyV3FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  for i := 1 to 12 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV0FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E4774 }

{ @routine $4E48B8 TPath_LoadLegacyV2FromReader }
procedure TPath.LoadLegacyV2FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  TraversalLimit := Reader.GetInt32;
  for i := 1 to 9 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV0FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E48B8 }

{ @routine $4E49FC TPath_LoadLegacyV1FromReader }
procedure TPath.LoadLegacyV1FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  AlwaysShow := Reader.GetBoolean;
  for i := 1 to 9 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV0FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E49FC }

{ @routine $4E4B30 TPath_LoadLegacyV0FromReader }
procedure TPath.LoadLegacyV0FromReader(Reader: TBufEC);
var
  i: Integer;
begin
  Reset;
  Id := Reader.GetInt32;
  FromLocationId := Reader.GetInt32;
  ToLocationId := Reader.GetInt32;
  IsAutomatic := Reader.GetBoolean;
  for i := 1 to 9 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV0FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  Caption.LoadTextLinesFromReader(Reader);
  Event.ClearTextFields;
  Event.Text.LoadTextLinesFromReader(Reader);
  IsAutomatic := TrimWideString(Caption.Text) = '';
end;
{ @end $4E4B30 }

end.
