unit MessageText;
// Unit bracket (inferred): .text 0x004B8A6C..0x004B8CD5; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar;

type
  TQuestMessages = class(TObject) // @size 0x08
  public
    constructor Create; // @addr $4B8AC8 @ida "TQuestMessages * __usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $4B8B1C @ida "void __usercall $name(TQuestMessages *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);"
    Entries: TBlockParEC; // @offset 0x04
    function GetTextOrKey(Key: WideString): WideString; // @addr $4B8C60 @ida "void __usercall $name(TQuestMessages *Self@<eax>, unsigned __int16 *Key@<edx>, unsigned __int16 **Result@<ecx>);" @note "Looks up a direct parameter; returns Key when absent."
    function GetText(Path: WideString): WideString; // @addr 0x4B8B6C @ida "void __usercall $name(TQuestMessages *Self@<eax>, unsigned __int16 *Path@<edx>, unsigned __int16 **Result@<ecx>);" @note "Returns Path when an intermediate block is missing; a missing final string parameter raises."
  end;

var
  QuestMessages: TQuestMessages; // @addr $888E5C

implementation

uses EC_Str;

{ @routine $4B8AC8 TQuestMessages_Create }
constructor TQuestMessages.Create;
begin
  inherited Create;
  Entries := TBlockParEC.Create;
end;
{ @end $4B8AC8 }

{ @routine $4B8B1C TQuestMessages_Destroy }
destructor TQuestMessages.Destroy;
begin
  if Entries <> nil then
  begin
    Entries.Free;
    Entries := nil;
  end;
  inherited Destroy;
end;
{ @end $4B8B1C }

{ @routine $4B8B6C TQuestMessages_GetText }
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
{ @end $4B8B6C }

{ @routine $4B8C60 TQuestMessages_GetTextOrKey }
function TQuestMessages.GetTextOrKey(Key: WideString): WideString;
begin
  if Entries.CountParams(Key) > 0 then
    Result := Entries.GetParam(Key)
  else
    Result := Key;
end;
{ @end $4B8C60 }

end.
