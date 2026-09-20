unit LocationClass;
// Unit bracket (inferred): .text 0x004E6BF4..0x004E8669; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Struct, EventClass, ParameterDeltaClass, SequenceClass, TextFieldClass;

type
  TLocation = class(TObjectEx) // @size 0x40
  public
    ParameterChanges: TList; // @offset 0x04  Owns its TParameterDelta entries.
    EditorX: Integer; // @offset 0x08
    EditorY: Integer; // @offset 0x0C
    Days: Integer; // @offset 0x10
    Id: Integer; // @offset 0x14
    EventCount: Integer; // @offset 0x18
    Events: array of TEvent; // @offset 0x1C  Owned, one-based dynamic array.
    UseEventExpression: Boolean; // @offset 0x20
    NextEventIndex: Integer; // @offset 0x24
    EventExpression: TTextField; // @offset 0x28
    IsDeath: Boolean; // @offset 0x2C
    IsEmpty: Boolean; // @offset 0x2D
    IsStart: Boolean; // @offset 0x2E
    IsSuccess: Boolean; // @offset 0x2F
    IsFailure: Boolean; // @offset 0x30
    VisitLimit: Integer; // @offset 0x34
    VisitCount: Integer; // @offset 0x38
    Sequence: TSequence; // @offset 0x3C

    constructor Create; // @addr 0x4E6C80
    destructor Destroy; override; // @addr 0x4E6D30
    procedure Reset; // @addr 0x4E6DD8 @note "Retains the first event; frees parameter changes and Sequence."
    function GetParameterChangeCount: Integer; // @addr 0x4E6F10
    function GetParameterChange(Index: Integer): TParameterDelta; // @addr 0x4E6F2C @note "Index is one-based."
    procedure AddParameterChange(Change: TParameterDelta); // @addr 0x4E6F54
    function FindParameterChange(ParameterIndex: Integer): TParameterDelta; // @addr 0x4E7070
    procedure PruneParameterChanges(Parameters: TList); // @addr 0x4E6FE8 @note "Removed entries are not freed."
    procedure ApplyParameterChanges(var Parameters: TList); // @addr 0x4E6F74 @note "Evaluates every expression before applying any change."
    procedure AddEvent; // @addr 0x4E70CC
    procedure RemoveLastEvent; // @addr 0x4E730C @note "Retains at least one event."
    function SelectEvent(var Parameters: TList): TEvent; // @addr 0x4E83A0 @note "Expression selection falls back to random choice."
    procedure LoadFromReader(Reader: TBufEC); // @addr 0x4E735C @note "Location format used by quest versions 1111111126 and later."
    procedure LoadLegacyV0FromReader(Reader: TBufEC); // @addr 0x4E826C @note "Quest versions 1111111111..1111111114."
    procedure LoadLegacyV1FromReader(Reader: TBufEC); // @addr 0x4E8138 @note "Quest version 1111111115."
    procedure LoadLegacyV2FromReader(Reader: TBufEC); // @addr 0x4E7FA0 @note "Quest version 1111111116."
    procedure LoadLegacyV3FromReader(Reader: TBufEC); // @addr 0x4E7E08 @note "Quest versions 1111111117..1111111118."
    procedure LoadLegacyV4FromReader(Reader: TBufEC); // @addr 0x4E7C60 @note "Quest versions 1111111119..1111111120."
    procedure LoadLegacyV5FromReader(Reader: TBufEC); // @addr 0x4E7AAC @note "Quest versions 1111111121..1111111122."
    procedure LoadLegacyV6FromReader(Reader: TBufEC); // @addr 0x4E78F8 @note "Quest version 1111111123."
    procedure LoadLegacyV7FromReader(Reader: TBufEC); // @addr 0x4E7744 @note "Quest version 1111111124."
    procedure LoadLegacyV8FromReader(Reader: TBufEC); // @addr 0x4E7554 @note "Quest version 1111111125; repeated parameter indices overwrite earlier changes."
  end;

implementation

uses CalcParseClass, EC_Str, Math;

{ @routine $4E6C80 TLocation_Create }
constructor TLocation.Create;
begin
  inherited Create;
  EventCount := 1;
  SetLength(Events, 2);
  Events[1] := TEvent.Create;
  Sequence := nil;
  EventExpression := TTextField.Create;
  ParameterChanges := TList.Create;
  Reset;
end;
{ @end $4E6C80 }

{ @routine $4E6D30 TLocation_Destroy }
destructor TLocation.Destroy;
var
  i: Integer;
begin
  Reset;
  // Reset retains only the first event; the native loop indexes that slot.
  for i := 1 to EventCount do
  begin
    Events[1].Free;
    Events[1] := nil;
  end;
  Events := nil;
  EventExpression.Free;
  EventExpression := nil;
  ParameterChanges.Free;
  ParameterChanges := nil;
  inherited Destroy;
end;
{ @end $4E6D30 }

{ @routine $4E6DD8 TLocation_Reset }
procedure TLocation.Reset;
var
  i: Integer;
begin
  EditorX := 100;
  EditorY := 100;
  Days := 0;
  VisitLimit := 0;
  VisitCount := 0;
  if Sequence <> nil then Sequence.Free;
  Sequence := nil;
  for i := 1 to GetParameterChangeCount do GetParameterChange(i).Free;
  ParameterChanges.Clear;
  for i := 2 to EventCount do Events[i].Free;
  SetLength(Events, 2);
  EventCount := 1;
  Events[1].ClearTextFields;
  UseEventExpression := False;
  NextEventIndex := 1;
  EventExpression.ClearText;
  Id := 0;
  IsStart := False;
  IsSuccess := False;
  IsFailure := False;
  IsDeath := False;
  IsEmpty := False;
end;
{ @end $4E6DD8 }

{ @routine $4E6F10 TLocation_GetParameterChangeCount }
function TLocation.GetParameterChangeCount: Integer;
begin
  Result := ParameterChanges.Count;
end;
{ @end $4E6F10 }

{ @routine $4E6F2C TLocation_GetParameterChange }
function TLocation.GetParameterChange(Index: Integer): TParameterDelta;
begin
  Result := TParameterDelta(ParameterChanges[Index - 1]);
end;
{ @end $4E6F2C }

{ @routine $4E6F54 TLocation_AddParameterChange }
procedure TLocation.AddParameterChange(Change: TParameterDelta);
begin
  ParameterChanges.Add(Change);
end;
{ @end $4E6F54 }

{ @routine $4E6F74 TLocation_ApplyParameterChanges }
procedure TLocation.ApplyParameterChanges(var Parameters: TList);
var
  i: Integer;
begin
  for i := 1 to GetParameterChangeCount do
    GetParameterChange(i).EvaluateChangeExpression(Parameters);
  for i := 1 to GetParameterChangeCount do
    GetParameterChange(i).ApplyChange(Parameters);
end;
{ @end $4E6F74 }

{ @routine $4E6FE8 TLocation_PruneParameterChanges }
procedure TLocation.PruneParameterChanges(Parameters: TList);
var
  i: Integer;
begin
  for i := GetParameterChangeCount downto 1 do
    if (GetParameterChange(i).ParameterIndex < 1) or (GetParameterChange(i).ParameterIndex > Parameters.Count) then
      ParameterChanges.Delete(i - 1)
    else if GetParameterChange(i).HasNoChange(Parameters) then
      ParameterChanges.Delete(i - 1);
end;
{ @end $4E6FE8 }

{ @routine $4E7070 TLocation_FindParameterChange }
function TLocation.FindParameterChange(ParameterIndex: Integer): TParameterDelta;
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
{ @end $4E7070 }

{ @routine $4E70CC TLocation_AddEvent }
procedure TLocation.AddEvent;
var
  Text: WideString;
  Different: Boolean;
  i: Integer;
begin
  Inc(EventCount);
  SetLength(Events, EventCount + 1);
  Events[EventCount] := TEvent.Create;
  if EventCount <> 1 then
  begin
    Text := TrimWideString(Events[1].Picture.Text);
    Different := False;
    for i := 2 to EventCount - 1 do
      if TrimWideString(Events[i].Picture.Text) <> Text then
      begin
        Different := True;
        Break;
      end;
    if not Different then Events[EventCount].Picture.Text := Text;
    Text := TrimWideString(Events[1].Sound.Text);
    Different := False;
    for i := 2 to EventCount - 1 do
      if TrimWideString(Events[i].Sound.Text) <> Text then
      begin
        Different := True;
        Break;
      end;
    if not Different then Events[EventCount].Sound.Text := Text;
    Text := TrimWideString(Events[1].Music.Text);
    Different := False;
    for i := 2 to EventCount - 1 do
      if TrimWideString(Events[i].Music.Text) <> Text then
      begin
        Different := True;
        Break;
      end;
    if not Different then Events[EventCount].Music.Text := Text;
  end;
end;
{ @end $4E70CC }

{ @routine $4E730C TLocation_RemoveLastEvent }
procedure TLocation.RemoveLastEvent;
begin
  if EventCount >= 2 then
  begin
    Events[EventCount].Free;
    Dec(EventCount);
    SetLength(Events, EventCount + 1);
  end;
end;
{ @end $4E730C }

{ @routine $4E735C TLocation_LoadFromReader }
procedure TLocation.LoadFromReader(Reader: TBufEC);
var
  i, ParameterIndex, Count: Integer;
  Change: TParameterDelta;
  LocationType: Byte;
begin
  Reset;
  Days := Reader.GetInt32;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := Reader.GetInt32;
  LocationType := Reader.GetByte;
  IsStart := LocationType = 1;
  IsEmpty := LocationType = 2;
  IsSuccess := LocationType = 3;
  IsFailure := (LocationType = 4) or (LocationType = 5);
  IsDeath := LocationType = 5;
  Count := Reader.GetInt32;
  for i := 1 to Count do
  begin
    ParameterIndex := Reader.GetInt32;
    Change := FindParameterChange(ParameterIndex);
    if Change = nil then
    begin
      Change := TParameterDelta.Create;
      Change.ParameterIndex := ParameterIndex;
      AddParameterChange(Change);
    end;
    Change.LoadChangeFromReader(Reader);
  end;
  Count := Reader.GetInt32;
  while Count > EventCount do AddEvent;
  while (Count < EventCount) and (EventCount > 1) do RemoveLastEvent;
  for i := 1 to Count do
  begin
    Events[i].Text.LoadTextLinesFromReader(Reader);
    Events[i].Picture.LoadTextLinesFromReader(Reader);
    Events[i].Sound.LoadTextLinesFromReader(Reader);
    Events[i].Music.LoadTextLinesFromReader(Reader);
  end;
  UseEventExpression := Reader.GetBoolean;
  EventExpression.LoadTextLinesFromReader(Reader);
end;
{ @end $4E735C }

{ @routine $4E7554 TLocation_LoadLegacyV8FromReader }
procedure TLocation.LoadLegacyV8FromReader(Reader: TBufEC);
var
  i, ParameterIndex, Count: Integer;
  Change: TParameterDelta;
  LocationType: Byte;
begin
  Reset;
  Days := Reader.GetInt32;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  LocationType := Reader.GetByte;
  IsStart := LocationType = 1;
  IsEmpty := LocationType = 2;
  IsSuccess := LocationType = 3;
  IsFailure := (LocationType = 4) or (LocationType = 5);
  IsDeath := LocationType = 5;
  Count := Reader.GetInt32;
  for i := 1 to Count do
  begin
    ParameterIndex := Reader.GetInt32;
    Change := FindParameterChange(ParameterIndex);
    if Change = nil then
    begin
      Change := TParameterDelta.Create;
      Change.ParameterIndex := ParameterIndex;
      AddParameterChange(Change);
    end;
    Change.LoadChangeFromReader(Reader);
  end;
  Count := Reader.GetInt32;
  while Count > EventCount do AddEvent;
  while (Count < EventCount) and (EventCount > 1) do RemoveLastEvent;
  for i := 1 to Count do
  begin
    Events[i].Text.LoadTextLinesFromReader(Reader);
    Events[i].Picture.LoadTextLinesFromReader(Reader);
    Events[i].Sound.LoadTextLinesFromReader(Reader);
    Events[i].Music.LoadTextLinesFromReader(Reader);
  end;
  UseEventExpression := Reader.GetBoolean;
  EventExpression.LoadTextLinesFromReader(Reader);
end;
{ @end $4E7554 }

{ @routine $4E7744 TLocation_LoadLegacyV7FromReader }
procedure TLocation.LoadLegacyV7FromReader(Reader: TBufEC);
var
  i: Integer;
  DiscardedText: TTextField;
begin
  Reset;
  Days := Reader.GetInt32;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  IsStart := Reader.GetBoolean;
  IsSuccess := Reader.GetBoolean;
  IsFailure := Reader.GetBoolean;
  IsDeath := Reader.GetBoolean;
  IsEmpty := Reader.GetBoolean;
  for i := 1 to 96 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV3FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  while EventCount < 10 do AddEvent;
  while EventCount > 10 do RemoveLastEvent;
  for i := 1 to 10 do
  begin
    Events[i].ClearTextFields;
    Events[i].Text.LoadTextLinesFromReader(Reader);
  end;
  UseEventExpression := Reader.GetBoolean;
  NextEventIndex := Reader.GetInt32;
  DiscardedText := TTextField.Create;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.ClearText;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.Free;
  EventExpression.LoadTextLinesFromReader(Reader);
end;
{ @end $4E7744 }

{ @routine $4E78F8 TLocation_LoadLegacyV6FromReader }
procedure TLocation.LoadLegacyV6FromReader(Reader: TBufEC);
var
  i: Integer;
  DiscardedText: TTextField;
begin
  Reset;
  Days := Reader.GetInt32;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  IsStart := Reader.GetBoolean;
  IsSuccess := Reader.GetBoolean;
  IsFailure := Reader.GetBoolean;
  IsDeath := Reader.GetBoolean;
  IsEmpty := Reader.GetBoolean;
  for i := 1 to 48 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV3FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  while EventCount < 10 do AddEvent;
  while EventCount > 10 do RemoveLastEvent;
  for i := 1 to 10 do
  begin
    Events[i].ClearTextFields;
    Events[i].Text.LoadTextLinesFromReader(Reader);
  end;
  UseEventExpression := Reader.GetBoolean;
  NextEventIndex := Reader.GetInt32;
  DiscardedText := TTextField.Create;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.ClearText;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.Free;
  EventExpression.LoadTextLinesFromReader(Reader);
end;
{ @end $4E78F8 }

{ @routine $4E7AAC TLocation_LoadLegacyV5FromReader }
procedure TLocation.LoadLegacyV5FromReader(Reader: TBufEC);
var
  i: Integer;
  DiscardedText: TTextField;
begin
  Reset;
  Days := Reader.GetInt32;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  IsStart := Reader.GetBoolean;
  IsSuccess := Reader.GetBoolean;
  IsFailure := Reader.GetBoolean;
  IsDeath := Reader.GetBoolean;
  IsEmpty := Reader.GetBoolean;
  for i := 1 to 24 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV3FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  while EventCount < 10 do AddEvent;
  while EventCount > 10 do RemoveLastEvent;
  for i := 1 to 10 do
  begin
    Events[i].ClearTextFields;
    Events[i].Text.LoadTextLinesFromReader(Reader);
  end;
  UseEventExpression := Reader.GetBoolean;
  NextEventIndex := Reader.GetInt32;
  DiscardedText := TTextField.Create;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.ClearText;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.Free;
  EventExpression.LoadTextLinesFromReader(Reader);
end;
{ @end $4E7AAC }

{ @routine $4E7C60 TLocation_LoadLegacyV4FromReader }
procedure TLocation.LoadLegacyV4FromReader(Reader: TBufEC);
var
  i: Integer;
  DiscardedText: TTextField;
begin
  Reset;
  Days := Reader.GetInt32;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  IsStart := Reader.GetBoolean;
  IsSuccess := Reader.GetBoolean;
  IsFailure := Reader.GetBoolean;
  IsDeath := Reader.GetBoolean;
  IsEmpty := Reader.GetBoolean;
  for i := 1 to 24 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV3FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  while EventCount < 10 do AddEvent;
  while EventCount > 10 do RemoveLastEvent;
  for i := 1 to 10 do
  begin
    Events[i].ClearTextFields;
    Events[i].Text.LoadTextLinesFromReader(Reader);
  end;
  UseEventExpression := Reader.GetBoolean;
  NextEventIndex := Reader.GetInt32;
  DiscardedText := TTextField.Create;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.ClearText;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.Free;
end;
{ @end $4E7C60 }

{ @routine $4E7E08 TLocation_LoadLegacyV3FromReader }
procedure TLocation.LoadLegacyV3FromReader(Reader: TBufEC);
var
  i: Integer;
  DiscardedText: TTextField;
begin
  Reset;
  Days := Reader.GetInt32;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  IsStart := Reader.GetBoolean;
  IsSuccess := Reader.GetBoolean;
  IsFailure := Reader.GetBoolean;
  IsDeath := Reader.GetBoolean;
  for i := 1 to 12 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV2FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  while EventCount < 10 do AddEvent;
  while EventCount > 10 do RemoveLastEvent;
  for i := 1 to 10 do
  begin
    Events[i].ClearTextFields;
    Events[i].Text.LoadTextLinesFromReader(Reader);
  end;
  UseEventExpression := Reader.GetBoolean;
  NextEventIndex := Reader.GetInt32;
  DiscardedText := TTextField.Create;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.ClearText;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.Free;
end;
{ @end $4E7E08 }

{ @routine $4E7FA0 TLocation_LoadLegacyV2FromReader }
procedure TLocation.LoadLegacyV2FromReader(Reader: TBufEC);
var
  i: Integer;
  DiscardedText: TTextField;
begin
  Reset;
  Days := Reader.GetInt32;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  IsStart := Reader.GetBoolean;
  IsSuccess := Reader.GetBoolean;
  IsFailure := Reader.GetBoolean;
  IsDeath := Reader.GetBoolean;
  for i := 1 to 12 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV1FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  while EventCount < 10 do AddEvent;
  while EventCount > 10 do RemoveLastEvent;
  for i := 1 to 10 do
  begin
    Events[i].ClearTextFields;
    Events[i].Text.LoadTextLinesFromReader(Reader);
  end;
  UseEventExpression := Reader.GetBoolean;
  NextEventIndex := Reader.GetInt32;
  DiscardedText := TTextField.Create;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.ClearText;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.Free;
end;
{ @end $4E7FA0 }

{ @routine $4E8138 TLocation_LoadLegacyV1FromReader }
procedure TLocation.LoadLegacyV1FromReader(Reader: TBufEC);
var
  i: Integer;
  DiscardedText: TTextField;
begin
  Reset;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  IsStart := Reader.GetBoolean;
  IsSuccess := Reader.GetBoolean;
  IsFailure := Reader.GetBoolean;
  IsDeath := Reader.GetBoolean;
  for i := 1 to 12 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV0FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  while EventCount > 1 do RemoveLastEvent;
  DiscardedText := TTextField.Create;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.Free;
  Events[1].ClearTextFields;
  Events[1].Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4E8138 }

{ @routine $4E826C TLocation_LoadLegacyV0FromReader }
procedure TLocation.LoadLegacyV0FromReader(Reader: TBufEC);
var
  i: Integer;
  DiscardedText: TTextField;
begin
  Reset;
  EditorX := Reader.GetInt32;
  EditorY := Reader.GetInt32;
  Id := Reader.GetInt32;
  VisitLimit := 0;
  IsStart := Reader.GetBoolean;
  IsSuccess := Reader.GetBoolean;
  IsFailure := Reader.GetBoolean;
  IsDeath := Reader.GetBoolean;
  for i := 1 to 9 do
  begin
    AddParameterChange(TParameterDelta.Create);
    GetParameterChange(GetParameterChangeCount).LoadLegacyV0FromReader(Reader);
    GetParameterChange(GetParameterChangeCount).ParameterIndex := i;
  end;
  while EventCount > 1 do RemoveLastEvent;
  DiscardedText := TTextField.Create;
  DiscardedText.LoadTextLinesFromReader(Reader);
  DiscardedText.Free;
  Events[1].ClearTextFields;
  Events[1].Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4E826C }

{ @routine $4E83A0 TLocation_SelectEvent }
function TLocation.SelectEvent(var Parameters: TList): TEvent;
var
  i, j, Attempts: Integer;
  Found: Boolean;
  Text: WideString;
  Calc: TCalcParse;
  Valid: Boolean;
begin
  Result := nil;
  Found := False;
  if UseEventExpression then
  begin
    Valid := True;
    Calc := TCalcParse.Create;
    if TrimWideString(EventExpression.Text) <> '' then
    begin
      Calc.Prepare(EventExpression.Text, 1);
      if Calc.HasError or Calc.UsesDefaultParameter then Valid := False;
    end
    else Valid := False;
    if Valid then
    begin
      Calc.Evaluate(Parameters);
      if Calc.EvaluationError then Valid := False;
    end;
    if Valid then
    begin
      if (Calc.ResultValue <= EventCount) and (Calc.ResultValue >= 1) then Result := Events[Calc.ResultValue];
    end
    else
    begin
      Attempts := 0;
      while not Found do
      begin
        i := System.Random(EventCount) + 1;
        Text := TrimWideString(Events[i].Text.Text);
        if Text <> '' then
        begin
          Found := True;
          Result := Events[i];
        end
        else if Attempts > Max(20, EventCount * 2) then
        begin
          for j := i + 1 to i + EventCount do
          begin
            Text := TrimWideString(Events[1 + j mod EventCount].Text.Text);
            if Text <> '' then Break;
          end;
          Found := True;
          Result := Events[1 + j mod EventCount];
        end
        else Inc(Attempts);
      end;
    end;
    Calc.Destroy;
  end
  else
  begin
    i := NextEventIndex;
    Attempts := 0;
    while not Found do
    begin
      Text := TrimWideString(Events[i].Text.Text);
      if (Text <> '') or (Attempts > EventCount) then
      begin
        Found := True;
        Result := Events[i];
        NextEventIndex := i + 1;
        if NextEventIndex > EventCount then NextEventIndex := 1;
      end
      else Inc(Attempts);
      Inc(i);
      if i > EventCount then i := 1;
    end;
  end;
end;
{ @end $4E83A0 }

end.
