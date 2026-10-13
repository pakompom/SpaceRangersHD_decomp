unit MessageText;

interface

uses EC_BlockPar;

type
  TQuestMessages = class(TObject) // @size 0x08
  public
    constructor Create; // @addr $482340
    destructor Destroy; override; // @addr $482384
    Entries: TBlockParEC; // @offset 0x04
    function GetTextOrKey(Key: WideString): WideString; // @addr $482498 @note "Looks up a direct parameter; returns Key when absent."
    function GetText(Path: WideString): WideString; // @addr 0x004823BC @note "Returns Path when an intermediate block is missing; a missing final string parameter raises."
  end;

var
  QuestMessages: TQuestMessages; // @addr $819E68

implementation

uses EC_Str;

{ @routine $482340 TQuestMessages_Create }
constructor TQuestMessages.Create;
begin
  inherited Create;
  Entries := TBlockParEC.Create;
end;
{ @end $482340 }

{ @routine $482384 TQuestMessages_Destroy }
destructor TQuestMessages.Destroy;
begin
  if Entries <> nil then
  begin
    Entries.Free;
    Entries := nil;
  end;
  inherited Destroy;
end;
{ @end $482384 }

{ @routine $4823BC TQuestMessages_GetText }
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
{ @end $4823BC }

{ @routine $482498 TQuestMessages_GetTextOrKey }
function TQuestMessages.GetTextOrKey(Key: WideString): WideString;
begin
  if Entries.CountParams(Key) > 0 then
    Result := Entries.GetParam(Key)
  else
    Result := Key;
end;
{ @end $482498 }

end.
