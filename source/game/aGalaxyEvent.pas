unit aGalaxyEvent;
// Unit bracket (inferred): .text 0x004F3480..0x004F3ABE; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Struct, aGalaxy;

// Unit attribution is inferred from the native class name and implementation group.
type
  TGalaxyEvent = class(TObjectEx) // @size 0x14
  public
    EventType: WideString; // @offset 0x04
    Turn: Integer; // @offset 0x08
    Data: TList; // @offset 0x0C  Owned list of Integer payloads stored in pointer slots; may be nil.
    TextData: TList; // @offset 0x10  Owned list of separately allocated PWideString cells; may be nil.

    constructor Create(EventType: WideString); // @addr 0x4F34EC
    destructor Destroy; override; // @addr 0x4F3580
    procedure AddData(Value: Integer); // @addr 0x4F35B4
    procedure AddTextData(Value: WideString); // @addr 0x4F35F0 @note "Copies Value into a separately allocated string cell."
    function GetData(Index: Integer): Integer; // @addr 0x4F367C @note "Zero-based; returns zero for a missing list or an out-of-range index."
    function GetTextData(Index: Integer): WideString; // @addr 0x4F36C4 @note "Zero-based; returns a copy, or empty for a missing list or an out-of-range index."
    procedure ClearData; // @addr 0x4F3714
    procedure ClearTextData; // @addr 0x4F3748 @note "Frees the string cells and list without finalizing the cells' WideStrings, leaking their BSTR storage."
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x4F37B8 @note "Overwrites existing payload lists without freeing them; nonpositive stored counts produce nil lists."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x4F3900
  end;

function AddGalaxyEvent(EventType: WideString; Galaxy: TGalaxy = nil): TGalaxyEvent; // @addr 0x4F39EC @note "Nil Galaxy selects the current galaxy; returns nil if none exists. The galaxy owns the result, dated with its CurrentTurn. Trims the oldest events to retain at most 9999 entries."

implementation

{ @routine $4F34EC TGalaxyEvent_Create }
constructor TGalaxyEvent.Create(EventType: WideString);
begin
  Self.EventType := EventType;
  Turn := 0;
  Data := nil;
  TextData := nil;
end;
{ @end $4F34EC }

{ @routine $4F3580 TGalaxyEvent_Destroy }
destructor TGalaxyEvent.Destroy;
begin
  ClearData;
  ClearTextData;
end;
{ @end $4F3580 }

{ @routine $4F35B4 TGalaxyEvent_AddData }
procedure TGalaxyEvent.AddData(Value: Integer);
begin
  if Data = nil then Data := TList.Create;
  Data.Add(Pointer(Value));
end;
{ @end $4F35B4 }

{ @routine $4F35F0 TGalaxyEvent_AddTextData }
procedure TGalaxyEvent.AddTextData(Value: WideString);
var
  Cell: PWideString;
begin
  if TextData = nil then TextData := TList.Create;
  New(Cell);
  Cell^ := Value;
  TextData.Add(Cell);
end;
{ @end $4F35F0 }

{ @routine $4F367C TGalaxyEvent_GetData }
function TGalaxyEvent.GetData(Index: Integer): Integer;
begin
  Result := 0;
  if Data = nil then Exit;
  if Index < 0 then Exit;
  if Data.Count <= Index then Exit;
  Result := Integer(Data[Index]);
end;
{ @end $4F367C }

{ @routine $4F36C4 TGalaxyEvent_GetTextData }
function TGalaxyEvent.GetTextData(Index: Integer): WideString;
begin
  Result := '';
  if TextData = nil then Exit;
  if Index < 0 then Exit;
  if TextData.Count <= Index then Exit;
  Result := PWideString(TextData[Index])^;
end;
{ @end $4F36C4 }

{ @routine $4F3714 TGalaxyEvent_ClearData }
procedure TGalaxyEvent.ClearData;
begin
  if Data <> nil then
  begin
    Data.Clear;
    Data.Free;
    Data := nil;
  end;
end;
{ @end $4F3714 }

{ @routine $4F3748 TGalaxyEvent_ClearTextData }
procedure TGalaxyEvent.ClearTextData;
var
  i, Count: Integer;
begin
  if TextData <> nil then
  begin
    Count := TextData.Count;
    for i := 0 to Count - 1 do
      Dispose(TextData[i]);
    TextData.Clear;
    TextData.Free;
    TextData := nil;
  end;
end;
{ @end $4F3748 }

{ @routine $4F37B8 TGalaxyEvent_LoadFromBuffer }
procedure TGalaxyEvent.LoadFromBuffer(Buffer: TBufEC);
var
  i, Count: Integer;
  Cell: PWideString;
begin
  EventType := Buffer.ReadWideString;
  Turn := Buffer.GetInt32;
  Data := nil;
  Count := Buffer.GetInt32;
  if Count > 0 then
  begin
    Data := TList.Create;
    for i := 0 to Count - 1 do
      Data.Add(Pointer(Buffer.GetInt32));
  end;
  TextData := nil;
  Count := Buffer.GetInt32;
  if Count > 0 then
  begin
    TextData := TList.Create;
    for i := 0 to Count - 1 do
    begin
      New(Cell);
      Cell^ := Buffer.ReadWideString;
      TextData.Add(Cell);
    end;
  end;
end;
{ @end $4F37B8 }

{ @routine $4F3900 TGalaxyEvent_SaveToBuffer }
procedure TGalaxyEvent.SaveToBuffer(Buffer: TBufEC);
var
  i, Count: Integer;
begin
  Buffer.AddWideStringZ(EventType);
  Buffer.AddIntegerValue(Turn);
  if Data = nil then Buffer.AddIntegerValue(0)
  else
  begin
    Count := Data.Count;
    Buffer.AddIntegerValue(Count);
    for i := 0 to Count - 1 do Buffer.AddIntegerValue(Integer(Data[i]));
  end;
  if TextData = nil then Buffer.AddIntegerValue(0)
  else
  begin
    Count := TextData.Count;
    Buffer.AddIntegerValue(Count);
    for i := 0 to Count - 1 do Buffer.AddWideStringZ(PWideString(TextData[i])^);
  end;
end;
{ @end $4F3900 }

{ @routine $4F39EC AddGalaxyEvent }
function AddGalaxyEvent(EventType: WideString; Galaxy: TGalaxy): TGalaxyEvent;
var
  Target: TGalaxy;
begin
  if Galaxy <> nil then Target := Galaxy
  else Target := aGalaxy.Galaxy;
  if Target = nil then
  begin
    Result := nil;
    Exit;
  end;
  Result := TGalaxyEvent.Create(EventType);
  Result.Turn := Target.CurrentTurn;
  Target.GalaxyEvents.Add(Result);
  while Target.GalaxyEvents.Count >= 10000 do
  begin
    TObject(Target.GalaxyEvents[0]).Free;
    Target.GalaxyEvents.Delete(0);
  end;
end;
{ @end $4F39EC }

end.
