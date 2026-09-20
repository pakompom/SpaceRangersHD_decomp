unit MessageText;
// Unit bracket (inferred): .text 0x004C5DD8..0x004C6041; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar;

type
  TQuestMessages = class(TObject) // @size 0x08
  public
    constructor Create; // @addr $4C5E34
    destructor Destroy; override; // @addr $4C5E88
    Entries: TBlockParEC; // @offset 0x04
    function GetTextOrKey(Key: WideString): WideString; // @addr $4C5FCC @note "Looks up a direct parameter; returns Key when absent."
    function GetText(Path: WideString): WideString; // @addr 0x4C5ED8 @note "Returns Path when an intermediate block is missing; a missing final string parameter raises."
  end;

var
  QuestMessages: TQuestMessages; // @addr $889EC0

implementation

uses EC_Str;

{ @routine $4C5E34 TQuestMessages_Create }
constructor TQuestMessages.Create;
begin
  inherited Create;
  Entries := TBlockParEC.Create;
end;
{ @end $4C5E34 }

{ @routine $4C5E88 TQuestMessages_Destroy }
destructor TQuestMessages.Destroy;
begin
  if Entries <> nil then
  begin
    Entries.Free;
    Entries := nil;
  end;
  inherited Destroy;
end;
{ @end $4C5E88 }

{ @routine $4C5ED8 TQuestMessages_GetText }
function TQuestMessages.GetText(Path: WideString): WideString;
var
  i, PartCount: Integer;
  Name: WideString;
  Block: TBlockParEC;
begin
  Result := Path;
  PartCount := CountDelimitedPartsW(Path, '.');
  Block := Entries;
  for i := 0 to PartCount - 2 do
  begin
    Name := ExtractDelimitedPartW(Path, i, '.');
    if Block.CountBlocks(Name) <= 0 then Exit;
    Block := Block.GetBlock(Name);
  end;
  Name := ExtractDelimitedPartW(Path, PartCount - 1, '.');
  Result := Block.GetParam(Name);
end;
{ @end $4C5ED8 }

{ @routine $4C5FCC TQuestMessages_GetTextOrKey }
function TQuestMessages.GetTextOrKey(Key: WideString): WideString;
begin
  if Entries.CountParams(Key) > 0 then
    Result := Entries.GetParam(Key)
  else
    Result := Key;
end;
{ @end $4C5FCC }

end.
