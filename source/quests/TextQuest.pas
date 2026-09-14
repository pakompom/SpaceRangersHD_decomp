unit TextQuest;
// Unit bracket (inferred): .text 0x004E4C58..0x004E8485; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Struct, EventClass, LocationClass, ParameterClass, PathClass, TextFieldClass, TextQuestInterface;

type
  TTextQuest = class(TObjectEx) // @size 0x80
  public
    Locations: TList; // @offset 0x04
    Paths: TList; // @offset 0x08
    FormatVersion: Integer; // @offset 0x0C
    MajorVersion: Integer; // @offset 0x10
    MinorVersion: Integer; // @offset 0x14
    ChangeLogText: TTextField; // @offset 0x18
    EditorScreenWidth: Integer; // @offset 0x1C
    EditorScreenHeight: Integer; // @offset 0x20
    EditorGridWidth: Integer; // @offset 0x24
    EditorGridHeight: Integer; // @offset 0x28
    Difficulty: Integer; // @offset 0x2C
    CompleteOnFinish: Boolean; // @offset 0x30
    IssuerRaceMask: Byte; // @offset 0x31
    TargetOwnerMask: Byte; // @offset 0x32 // Empty requires matching issuer and target owners; bit 6 selects owner 6.
    PlayerCareerMask: Byte; // @offset 0x33 // Bits 0..2 follow TRangerCareer.
    PlayerRaceMask: Byte; // @offset 0x34
    SuccessRelationDelta: Integer; // @offset 0x38
    DefaultTraversalLimit: Integer; // @offset 0x3C // Serialized editor default; not applied by this runtime.
    QuestDescriptionText: TTextField; // @offset 0x40
    QuestSuccessGovMessageText: TTextField; // @offset 0x44
    ToStarText: TTextField; // @offset 0x48
    ToPlanetText: TTextField; // @offset 0x4C
    DateText: TTextField; // @offset 0x50
    MoneyText: TTextField; // @offset 0x54
    FromPlanetText: TTextField; // @offset 0x58
    FromStarText: TTextField; // @offset 0x5C
    RangerText: TTextField; // @offset 0x60
    PlayerInterface: TTextQuestInterface; // @offset 0x64
    TextShown: Boolean; // @offset 0x68
    DisplayedEvent: TEvent; // @offset 0x6C
    OutcomeEvent: TEvent; // @offset 0x70
    Outcome: TQuestOutcome; // @offset 0x74
    Parameters: TList; // @offset 0x78
    LastEventSource: WideString; // @offset 0x7C // Diagnostic location/path label; Reset preserves it.

    constructor Create; // @addr 0x4E4CC4 @ida "TTextQuest *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4E4E50 @ida "void __usercall $name(TTextQuest *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Reset; // @addr 0x4E4FF8 @note "Retains PlayerInterface and the owned text/event containers."
    function GetLocationCount: Integer; // @addr 0x4E54B4
    function GetPathCount: Integer; // @addr 0x4E54D0
    function GetLocation(Index: Integer): TLocation; // @addr 0x4E54EC @note "Index is one-based."
    function GetPath(Index: Integer): TPath; // @addr 0x4E5514 @note "Index is one-based."
    function GetParameterCount: Integer; // @addr 0x4E553C
    function GetParameter(Index: Integer): TParameter; // @addr 0x4E5558 @note "Index is one-based; the list includes an extra trailing parameter."
    function FindLocationIndex(LocationId: Integer): Integer; // @addr 0x4E64C0 @note "Returns the last matching one-based index; displays a message and returns zero when absent."
    function FindPathIndex(PathId: Integer): Integer; // @addr 0x4E65E4 @note "Returns the last matching one-based index; displays a message and returns zero when absent."
    procedure LoadFromReader(Reader: TBufEC; HeaderOnly: Boolean); // @addr 0x4E5580 @note "HeaderOnly still loads parameters and quest text."
    procedure BuildLegacySequences; // @addr 0x4E6850 @note "Used before quest version 1111111126."
    procedure InferLegacyVisitLimits; // @addr 0x4E6944 @note "Skips success and death locations; ordinary failure locations still participate."
    procedure FreeLegacySequences; // @addr 0x4E68F4
    procedure ResetEventIndices; // @addr 0x4E6480
    procedure Start(Money: Integer; PreserveExternalParameters: Boolean); // @addr 0x4E74CC @note "External names begin with ext_; negative Money uses the initial range. Requires PlayerInterface."
    procedure EnterLocation(LocationId: Integer); // @addr 0x4E76FC
    procedure FollowPath(PathId: Integer); // @addr 0x4E7FAC
    function ExpandText(Text: WideString; Colorize: Boolean): WideString; // @addr 0x4E6A54 @ida "void __userpurge $name(TTextQuest *Self@<eax>, unsigned __int16 *Text@<edx>, bool Colorize@<cl>, unsigned __int16 **Result@<^0>);" @note "Supports {formula}, [pN], [dN], and [dN:formula], including parameter-name aliases. Recursive display expansion has no cycle guard."
    procedure ShowEvent(Event: TEvent); // @addr 0x4E8110
    procedure ShowParameters; // @addr 0x4E8314
    function CheckCriticalParameters: Boolean; // @addr 0x4E7284 @note "Outcome precedence: death, failure, success."
    procedure ShowOutcome; // @addr 0x4E827C
  end;

// Nested helpers of TTextQuest.BuildLegacySequences; ParentFrame is compiler supplied.

implementation

uses CPDiapClass, CalcParseClass, Dialogs, EC_Str, MessageText, SequenceClass;

{ @routine $4E4CC4 TTextQuest_Create }
constructor TTextQuest.Create;
begin
  PlayerInterface := nil;
  TextShown := False;
  OutcomeEvent := TEvent.Create;
  Outcome := qoNone;
  DisplayedEvent := nil;
  MajorVersion := 1;
  MinorVersion := 0;
  ChangeLogText := TTextField.Create;
  QuestSuccessGovMessageText := TTextField.Create;
  QuestDescriptionText := TTextField.Create;
  ToStarText := TTextField.Create;
  ToPlanetText := TTextField.Create;
  DateText := TTextField.Create;
  MoneyText := TTextField.Create;
  FromPlanetText := TTextField.Create;
  FromStarText := TTextField.Create;
  RangerText := TTextField.Create;
  Locations := TList.Create;
  Paths := TList.Create;
  Parameters := TList.Create;
  Reset;
  Parameters.Add(TParameter.Create(1));
end;
{ @end $4E4CC4 }

{ @routine $4E4E50 TTextQuest_Destroy }
destructor TTextQuest.Destroy;
begin
  Reset;
  if ChangeLogText <> nil then
  begin
    ChangeLogText.Free;
    ChangeLogText := nil;
  end;
  if QuestSuccessGovMessageText <> nil then
  begin
    QuestSuccessGovMessageText.Free;
    QuestSuccessGovMessageText := nil;
  end;
  if QuestDescriptionText <> nil then
  begin
    QuestDescriptionText.Free;
    QuestDescriptionText := nil;
  end;
  if OutcomeEvent <> nil then
  begin
    OutcomeEvent.Free;
    OutcomeEvent := nil;
  end;
  if ToStarText <> nil then
  begin
    ToStarText.Free;
    ToStarText := nil;
  end;
  if ToPlanetText <> nil then
  begin
    ToPlanetText.Free;
    ToPlanetText := nil;
  end;
  if DateText <> nil then
  begin
    DateText.Free;
    DateText := nil;
  end;
  if MoneyText <> nil then
  begin
    MoneyText.Free;
    MoneyText := nil;
  end;
  if FromPlanetText <> nil then
  begin
    FromPlanetText.Free;
    FromPlanetText := nil;
  end;
  if FromStarText <> nil then
  begin
    FromStarText.Free;
    FromStarText := nil;
  end;
  if RangerText <> nil then
  begin
    RangerText.Free;
    RangerText := nil;
  end;
  Locations.Free;
  Locations := nil;
  Paths.Free;
  Paths := nil;
  Parameters.Free;
  Parameters := nil;
  inherited Destroy;
end;
{ @end $4E4E50 }

{ @routine $4E4FF8 TTextQuest_Reset }
procedure TTextQuest.Reset;
type
  TFlagBits = set of 0..7;
var
  i: Integer;
begin
  FormatVersion := 1111111127;
  MajorVersion := 1;
  MinorVersion := 0;
  ChangeLogText.ClearText;
  CompleteOnFinish := True;
  TFlagBits(IssuerRaceMask) := [0..4];
  TFlagBits(TargetOwnerMask) := [6];
  TFlagBits(PlayerRaceMask) := [0..4];
  TFlagBits(PlayerCareerMask) := [0..2];
  EditorScreenWidth := 0;
  EditorScreenHeight := 0;
  DefaultTraversalLimit := 0;
  Difficulty := 50;
  SuccessRelationDelta := 0;
  EditorGridWidth := 10;
  EditorGridHeight := 8;
  QuestSuccessGovMessageText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.QuestSuccessGovMessage');
  QuestDescriptionText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.QuestDecription');
  ToStarText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.RToStar');
  ToPlanetText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.RToPlanet');
  DateText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.RDate');
  MoneyText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.RMoney');
  FromPlanetText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.RFromPLanet');
  FromStarText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.RFromStar');
  RangerText.Text := TQuestMessages(MessageText.QuestMessages).GetText('GameContent.RRanger');
  for i := GetLocationCount downto 1 do GetLocation(i).Free;
  Locations.Clear;
  for i := GetPathCount downto 1 do GetPath(i).Free;
  Paths.Clear;
  for i := GetParameterCount downto 1 do GetParameter(i).Free;
  Parameters.Clear;
  OutcomeEvent.ClearTextFields;
  Outcome := qoNone;
  DisplayedEvent := nil;
end;
{ @end $4E4FF8 }

{ @routine $4E54B4 TTextQuest_GetLocationCount }
function TTextQuest.GetLocationCount: Integer;
begin
  Result := Locations.Count;
end;
{ @end $4E54B4 }

{ @routine $4E54D0 TTextQuest_GetPathCount }
function TTextQuest.GetPathCount: Integer;
begin
  Result := Paths.Count;
end;
{ @end $4E54D0 }

{ @routine $4E54EC TTextQuest_GetLocation }
function TTextQuest.GetLocation(Index: Integer): TLocation;
begin
  Result := TLocation(Locations[Index - 1]);
end;
{ @end $4E54EC }

{ @routine $4E5514 TTextQuest_GetPath }
function TTextQuest.GetPath(Index: Integer): TPath;
begin
  Result := TPath(Paths[Index - 1]);
end;
{ @end $4E5514 }

{ @routine $4E553C TTextQuest_GetParameterCount }
function TTextQuest.GetParameterCount: Integer;
begin
  Result := Parameters.Count;
end;
{ @end $4E553C }

{ @routine $4E5558 TTextQuest_GetParameter }
function TTextQuest.GetParameter(Index: Integer): TParameter;
begin
  Result := TParameter(Parameters[Index - 1]);
end;
{ @end $4E5558 }

{ @routine $4E5580 TTextQuest_LoadFromReader }
procedure TTextQuest.LoadFromReader(Reader: TBufEC; HeaderOnly: Boolean);
type
  TFlagBits = set of 0..7;
var
  i, ParameterCount, LocationCount, PathCount: Integer;
  TemporaryText: TTextField;
begin
  Reset;
  FormatVersion := Reader.GetInt32;
  if FormatVersion >= 1111111127 then
  begin
    MajorVersion := Reader.GetInt32;
    MinorVersion := Reader.GetInt32;
    ChangeLogText.LoadTextLinesFromReader(Reader);
  end
  else
  begin
    MajorVersion := 1;
    MinorVersion := 0;
    ChangeLogText.ClearText;
  end;
  i := 0;
  if FormatVersion <= 1111111111 then
  begin
    i := FormatVersion;
    FormatVersion := 1111111111;
  end
  else if FormatVersion < 1111111125 then i := Reader.GetInt32;
  if FormatVersion >= 1111111119 then Reader.ReadBytes(@IssuerRaceMask, 1)
  else
    case i of
      -1: TFlagBits(IssuerRaceMask) := [6];
      0: TFlagBits(IssuerRaceMask) := [0];
      1: TFlagBits(IssuerRaceMask) := [1];
      2: TFlagBits(IssuerRaceMask) := [2];
      3: TFlagBits(IssuerRaceMask) := [3];
      4: TFlagBits(IssuerRaceMask) := [4];
    else TFlagBits(IssuerRaceMask) := [];
    end;
  if FormatVersion >= 1111111112 then CompleteOnFinish := Reader.GetBoolean;
  if FormatVersion < 1111111125 then i := Reader.GetInt32;
  if FormatVersion >= 1111111119 then Reader.ReadBytes(@TargetOwnerMask, 1)
  else
    case i of
      -1: TFlagBits(TargetOwnerMask) := [6];
      0: TFlagBits(TargetOwnerMask) := [0];
      1: TFlagBits(TargetOwnerMask) := [1];
      2: TFlagBits(TargetOwnerMask) := [2];
      3: TFlagBits(TargetOwnerMask) := [3];
      4: TFlagBits(TargetOwnerMask) := [4];
    else TFlagBits(TargetOwnerMask) := [];
    end;
  if FormatVersion < 1111111125 then i := Reader.GetInt32;
  if FormatVersion >= 1111111120 then Reader.ReadBytes(@PlayerCareerMask, 1)
  else
    case i of
      -1: TFlagBits(PlayerCareerMask) := [0..2];
      0: TFlagBits(PlayerCareerMask) := [0];
      1: TFlagBits(PlayerCareerMask) := [1];
      2: TFlagBits(PlayerCareerMask) := [2];
    else TFlagBits(PlayerCareerMask) := [];
    end;
  if FormatVersion < 1111111125 then i := Reader.GetInt32;
  if FormatVersion >= 1111111120 then Reader.ReadBytes(@PlayerRaceMask, 1)
  else
    case i of
      -1: TFlagBits(PlayerRaceMask) := [0..4];
      0: TFlagBits(PlayerRaceMask) := [0];
      1: TFlagBits(PlayerRaceMask) := [1];
      2: TFlagBits(PlayerRaceMask) := [2];
      3: TFlagBits(PlayerRaceMask) := [3];
      4: TFlagBits(PlayerRaceMask) := [4];
    else TFlagBits(PlayerRaceMask) := [];
    end;
  SuccessRelationDelta := Reader.GetInt32;
  EditorScreenWidth := Reader.GetInt32;
  EditorScreenHeight := Reader.GetInt32;
  EditorGridWidth := Reader.GetInt32;
  EditorGridHeight := Reader.GetInt32;
  if FormatVersion < 1111111125 then Reader.GetInt32;
  if FormatVersion >= 1111111120 then DefaultTraversalLimit := Reader.GetInt32;
  if FormatVersion >= 1111111121 then Difficulty := Reader.GetInt32;
  if FormatVersion >= 1111111125 then ParameterCount := Reader.GetInt32
  else if FormatVersion >= 1111111124 then ParameterCount := 96
  else if FormatVersion >= 1111111123 then ParameterCount := 48
  else if FormatVersion >= 1111111121 then ParameterCount := 24
  else if FormatVersion >= 1111111119 then ParameterCount := 24
  else if FormatVersion >= 1111111118 then ParameterCount := 12
  else if FormatVersion >= 1111111115 then ParameterCount := 12
  else if FormatVersion >= 1111111113 then ParameterCount := 9
  else ParameterCount := 9;
  for i := 1 to ParameterCount do Parameters.Add(TParameter.Create(i));
  if FormatVersion >= 1111111125 then
    for i := 1 to ParameterCount do GetParameter(i).LoadFromReader(Reader)
  else if FormatVersion >= 1111111124 then
    for i := 1 to ParameterCount do GetParameter(i).LoadLegacyV4FromReader(Reader)
  else if FormatVersion >= 1111111123 then
    for i := 1 to ParameterCount do GetParameter(i).LoadLegacyV4FromReader(Reader)
  else if FormatVersion >= 1111111121 then
    for i := 1 to ParameterCount do GetParameter(i).LoadLegacyV4FromReader(Reader)
  else if FormatVersion >= 1111111119 then
    for i := 1 to ParameterCount do GetParameter(i).LoadLegacyV3FromReader(Reader)
  else if FormatVersion >= 1111111118 then
    for i := 1 to ParameterCount do GetParameter(i).LoadLegacyV2FromReader(Reader)
  else if FormatVersion >= 1111111115 then
    for i := 1 to ParameterCount do GetParameter(i).LoadLegacyV1FromReader(Reader)
  else if FormatVersion >= 1111111113 then
    for i := 1 to ParameterCount do GetParameter(i).LoadLegacyV1FromReader(Reader)
  else
    for i := 1 to ParameterCount do GetParameter(i).LoadLegacyV0FromReader(Reader);
  Parameters.Add(TParameter.Create(ParameterCount + 1));
  ToStarText.LoadTextLinesFromReader(Reader);
  if FormatVersion < 1111111125 then
  begin
    TemporaryText := TTextField.Create;
    TemporaryText.LoadTextLinesFromReader(Reader);
    TemporaryText.ClearText;
    TemporaryText.LoadTextLinesFromReader(Reader);
    TemporaryText.Free;
  end;
  ToPlanetText.LoadTextLinesFromReader(Reader);
  DateText.LoadTextLinesFromReader(Reader);
  MoneyText.LoadTextLinesFromReader(Reader);
  FromPlanetText.LoadTextLinesFromReader(Reader);
  FromStarText.LoadTextLinesFromReader(Reader);
  RangerText.LoadTextLinesFromReader(Reader);
  LocationCount := Reader.GetInt32;
  PathCount := Reader.GetInt32;
  QuestSuccessGovMessageText.LoadTextLinesFromReader(Reader);
  QuestDescriptionText.LoadTextLinesFromReader(Reader);
  if not HeaderOnly then
  begin
    if FormatVersion < 1111111125 then
    begin
      TemporaryText := TTextField.Create;
      TemporaryText.LoadTextLinesFromReader(Reader);
      TemporaryText.Free;
    end;
    for i := 1 to PathCount do Paths.Add(TPath.Create);
    for i := 1 to LocationCount do Locations.Add(TLocation.Create);
    if FormatVersion >= 1111111126 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadFromReader(Reader)
    else if FormatVersion >= 1111111125 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV8FromReader(Reader)
    else if FormatVersion >= 1111111124 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV7FromReader(Reader)
    else if FormatVersion >= 1111111123 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV6FromReader(Reader)
    else if FormatVersion >= 1111111121 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV5FromReader(Reader)
    else if FormatVersion >= 1111111119 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV4FromReader(Reader)
    else if FormatVersion >= 1111111117 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV3FromReader(Reader)
    else if FormatVersion >= 1111111116 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV2FromReader(Reader)
    else if FormatVersion >= 1111111115 then
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV1FromReader(Reader)
    else
      for i := 1 to GetLocationCount do GetLocation(i).LoadLegacyV0FromReader(Reader);
    if FormatVersion >= 1111111125 then
      for i := 1 to GetPathCount do GetPath(i).LoadFromReader(Reader, Parameters)
    else if FormatVersion >= 1111111124 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV9FromReader(Reader)
    else if FormatVersion >= 1111111123 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV8FromReader(Reader)
    else if FormatVersion >= 1111111122 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV7FromReader(Reader)
    else if FormatVersion >= 1111111119 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV6FromReader(Reader)
    else if FormatVersion >= 1111111117 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV5FromReader(Reader)
    else if FormatVersion >= 1111111116 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV4FromReader(Reader)
    else if FormatVersion >= 1111111115 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV3FromReader(Reader)
    else if FormatVersion >= 1111111114 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV2FromReader(Reader)
    else if FormatVersion >= 1111111112 then
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV1FromReader(Reader)
    else
      for i := 1 to GetPathCount do GetPath(i).LoadLegacyV0FromReader(Reader);
    for i := 1 to GetPathCount do GetPath(i).PruneParameterChanges(Parameters);
    for i := 1 to GetLocationCount do GetLocation(i).PruneParameterChanges(Parameters);
    if FormatVersion < 1111111126 then
    begin
      BuildLegacySequences;
      InferLegacyVisitLimits;
      FreeLegacySequences;
    end;
  end;
end;
{ @end $4E5580 }

{ @routine $4E6480 TTextQuest_ResetEventIndices }
procedure TTextQuest.ResetEventIndices;
var
  i: Integer;
begin
  for i := 1 to GetLocationCount do
    GetLocation(i).NextEventIndex := 1;
end;
{ @end $4E6480 }

{ @routine $4E64C0 TTextQuest_FindLocationIndex }
function TTextQuest.FindLocationIndex(LocationId: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to GetLocationCount do
    if GetLocation(i).Id = LocationId then Result := i;
  if Result = 0 then Dialogs.ShowMessage(AnsiString('Cannot find Location with Location Number ' + IntToWideString(LocationId)));
end;
{ @end $4E64C0 }

{ @routine $4E65E4 TTextQuest_FindPathIndex }
function TTextQuest.FindPathIndex(PathId: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to GetPathCount do
    if GetPath(i).Id = PathId then Result := i;
  if Result = 0 then Dialogs.ShowMessage('Cannot find Path by Path Number - error');
end;
{ @end $4E65E4 }

{ @routine $4E6850 TTextQuest_BuildLegacySequences }
procedure TTextQuest.BuildLegacySequences;
var
  Sequence: TSequence;
  i, IncomingCount, OutgoingCount: Integer;
  Location: TLocation;
  IncomingPath, OutgoingPath: TPath;

  // @nested $4E6674 CountLegacySequenceConnections
  procedure CountLegacySequenceConnections(Location: TLocation; // @addr 0x4E6674 @ida "void __userpurge $name(TLocation *Location@<eax>, int *IncomingCount@<edx>, int *OutgoingCount@<ecx>, TPath **OutgoingPath@<^0>, TPath **IncomingPath@<^4>, void *ParentFrame@<^8>);" @stackpop 0x8 @calls "0x4E679D 0x4E681D 0x4E6893" @note "Returns zero counts for start, success, failure, or already grouped locations. Callee pops 8 bytes; caller pops ParentFrame."
    var IncomingCount, OutgoingCount: Integer; var IncomingPath, OutgoingPath: TPath);
  var
    i: Integer;
    Path: TPath;
  begin
    IncomingCount := 0;
    OutgoingCount := 0;
    IncomingPath := nil;
    OutgoingPath := nil;
    if Location.IsStart then Exit;
    if Location.IsSuccess then Exit;
    if Location.IsFailure then Exit;
    if Location.Sequence <> nil then Exit;
    for i := 1 to GetPathCount do
    begin
      Path := GetPath(i);
      if Path.ToLocationId = Location.Id then
      begin
        IncomingPath := Path;
        Inc(IncomingCount);
      end;
      if Path.FromLocationId = Location.Id then
      begin
        OutgoingPath := Path;
        Inc(OutgoingCount);
      end;
      if (IncomingCount > 1) and (OutgoingCount > 1) then Exit;
    end;
  end;

  // @nested $4E6750 PrependLegacySequencePaths
  procedure PrependLegacySequencePaths(Path: TPath); // @addr 0x4E6750 @ida "void __usercall $name(TPath *Path@<eax>, void *ParentFrame@<^0>);"
  var
    IncomingCount, OutgoingCount: Integer;
    Location: TLocation;
    IncomingPath, OutgoingPath: TPath;
  begin
    Sequence.PrependPath(Path);
    Location := GetLocation(FindLocationIndex(Path.FromLocationId));
    CountLegacySequenceConnections(Location, IncomingCount, OutgoingCount, IncomingPath, OutgoingPath);
    if OutgoingCount = 1 then
    begin
      Sequence.AddLocation(Location);
      if IncomingCount = 1 then PrependLegacySequencePaths(IncomingPath);
    end;
  end;

  // @nested $4E67D0 AppendLegacySequencePaths
  procedure AppendLegacySequencePaths(Path: TPath); // @addr 0x4E67D0 @ida "void __usercall $name(TPath *Path@<eax>, void *ParentFrame@<^0>);"
  var
    IncomingCount, OutgoingCount: Integer;
    Location: TLocation;
    IncomingPath, OutgoingPath: TPath;
  begin
    Sequence.AddPath(Path);
    Location := GetLocation(FindLocationIndex(Path.ToLocationId));
    CountLegacySequenceConnections(Location, IncomingCount, OutgoingCount, IncomingPath, OutgoingPath);
    if IncomingCount = 1 then
    begin
      Sequence.AddLocation(Location);
      if OutgoingCount = 1 then AppendLegacySequencePaths(OutgoingPath);
    end;
  end;

begin
  for i := 1 to GetLocationCount do
  begin
    Location := GetLocation(i);
    CountLegacySequenceConnections(Location, IncomingCount, OutgoingCount, IncomingPath, OutgoingPath);
    if (IncomingCount = 1) or (OutgoingCount = 1) then
    begin
      Sequence := TSequence.Create;
      Sequence.AddLocation(Location);
      if IncomingCount = 1 then PrependLegacySequencePaths(IncomingPath);
      if OutgoingCount = 1 then AppendLegacySequencePaths(OutgoingPath);
      Sequence.RecomputeTraversalLimit;
    end;
  end;
end;
{ @end $4E6850 }

{ @routine $4E68F4 TTextQuest_FreeLegacySequences }
procedure TTextQuest.FreeLegacySequences;
var
  i: Integer;
  Location: TLocation;
begin
  for i := 1 to GetLocationCount do
  begin
    Location := GetLocation(i);
    if Location.Sequence <> nil then Location.Sequence.Free;
  end;
end;
{ @end $4E68F4 }

{ @routine $4E6944 TTextQuest_InferLegacyVisitLimits }
procedure TTextQuest.InferLegacyVisitLimits;
var
  i, j, Limit: Integer;
  Unlimited, HasIncoming: Boolean;
  Location: TLocation;
  Path: TPath;
begin
  for i := 1 to GetLocationCount do
  begin
    Location := GetLocation(i);
    if not Location.IsSuccess and not Location.IsDeath then
    begin
      Limit := 0;
      HasIncoming := False;
      Unlimited := False;
      for j := 1 to GetPathCount do
      begin
        Path := GetPath(j);
        if Path.ToLocationId = Location.Id then HasIncoming := True;
        if Path.FromLocationId = Location.Id then
        begin
          if Path.TraversalLimit <= 0 then
          begin
            Unlimited := True;
            Break;
          end
          else Limit := Limit + Path.TraversalLimit;
        end;
      end;
      if not Unlimited then
        if HasIncoming then
      begin
        if Location.Sequence = nil then Location.VisitLimit := Limit
        else if (Location.VisitLimit = 0) or (Location.VisitLimit > Limit) then
          Location.Sequence.SetTraversalLimit(Limit);
      end;
    end;
  end;
end;
{ @end $4E6944 }

{ @routine $4E6A54 TTextQuest_ExpandText }
function TTextQuest.ExpandText(Text: WideString; Colorize: Boolean): WideString;
var
  i, Position, ContentStart, ContentLength, Depth, Count: Integer;
  Output, ValueText, Fragment: WideString;
  Calc: TCalcParse;
  ColorEnd, ColorStart: WideString;
begin
  if not Colorize then
  begin
    ColorStart := '';
    ColorEnd := '';
  end
  else
  begin
    ColorStart := '<clr>';
    ColorEnd := '<clrEnd>';
  end;
  Calc := TCalcParse.Create;
  Output := '';
  i := 1;
  Count := Length(Text);
  while i <= Count do
  begin
    if Text[i] <> '{' then
    begin
      Output := Output + Text[i];
      Inc(i);
    end
    else
    begin
      Inc(i);
      ValueText := '';
      while (i <= Count) and (Text[i] <> '}') do
      begin
        ValueText := ValueText + Text[i];
        Inc(i);
      end;
      if ValueText <> '' then
      begin
        Calc.Reset;
        Calc.Prepare(ValueText, 0);
        if not Calc.HasError and not Calc.UsesDefaultParameter then
        begin
          Calc.Evaluate(Parameters);
          if not Calc.HasError then
            Output := Output + ColorStart + IntToWideString(Calc.ResultValue) + ColorEnd
          else Output := Output + '{' + ValueText;
        end
        else Output := Output + '{' + ValueText;
      end;
      Inc(i);
    end;
  end;
  Text := Output;
  for i := 1 to GetParameterCount do
  begin
    Text := ReplaceAllWideString(Text, '[' + TrimWideString(GetParameter(i).NameText.Text) + ']', '[p' + IntToWideString(i) + ']');
    Text := ReplaceAllWideString(Text, '[' + TrimWideString(GetParameter(i).NameText.Text) + ':', '[d' + IntToWideString(i) + ':');
  end;
  for i := 1 to GetParameterCount do
  begin
    Position := System.Pos('[d' + IntToWideString(i) + ':', Text);
    while Position > 0 do
    begin
      ContentStart := Position + 3 + Length(IntToWideString(i));
      ContentLength := 0;
      Depth := 1;
      while ContentStart + ContentLength < Length(Text) do
      begin
        if Text[ContentStart + ContentLength] = ']' then Dec(Depth);
        if Text[ContentStart + ContentLength] = '[' then Inc(Depth);
        if Depth = 0 then Break;
        Inc(ContentLength);
      end;
      if ContentStart >= Length(Text) then Break;
      ValueText := ColorStart + 'err' + ColorEnd;
      Fragment := Copy(Text, ContentStart, ContentLength + 1);
      if Fragment <> '' then
      begin
        Calc.Reset;
        Calc.Prepare(Fragment, 1);
        if not Calc.HasError then
          if not Calc.UsesDefaultParameter then
          begin
            Calc.Evaluate(Parameters);
            if not Calc.HasError then
            begin
              ValueText := GetParameter(i).GetValueText(Calc.ResultValue);
              ValueText := ReplaceAllWideString(ValueText, '<>', IntToWideString(Calc.ResultValue));
              ValueText := ExpandText(ValueText, True);
            end;
          end;
      end;
      Fragment := Copy(Text, Position, ContentStart - Position + ContentLength + 1);
      Text := ReplaceAllWideString(Text, Fragment, ColorStart + ValueText + ColorEnd);
      Position := System.Pos('[d' + IntToWideString(i) + ':', Text);
    end;
  end;
  for i := 1 to GetParameterCount do
  begin
    Text := ReplaceAllWideString(Text, '[p' + IntToWideString(i) + ']', ColorStart + IntToWideString(GetParameter(i).Value) + ColorEnd);
    if System.Pos('[d' + IntToWideString(i) + ']', Text) > 0 then
    begin
      ValueText := GetParameter(i).GetValueText(GetParameter(i).Value);
      ValueText := ReplaceAllWideString(ValueText, '<>', IntToWideString(GetParameter(i).Value));
      ValueText := ExpandText(ValueText, True);
      Text := ReplaceAllWideString(Text, '[d' + IntToWideString(i) + ']', ColorStart + ValueText + ColorEnd);
    end;
  end;
  Calc.Free;
  Result := Text;
end;
{ @end $4E6A54 }

{ @routine $4E7284 TTextQuest_CheckCriticalParameters }
function TTextQuest.CheckCriticalParameters: Boolean;
var
  i, Selected: Integer;
  Parameter: TParameter;
  Event: TEvent;
  Outcomes: array[1..3] of Integer;
begin
  Result := False;
  for i := 1 to 3 do Outcomes[i] := -1;
  for i := 1 to GetParameterCount do
  begin
    Parameter := GetParameter(i);
    if Parameter.Enabled and (Parameter.CriticalOutcome <> qoNone) and
      (not Parameter.CriticalAtMinimum or (Parameter.Value <= Parameter.MinValue)) and
      (Parameter.CriticalAtMinimum or (Parameter.Value >= Parameter.MaxValue)) then
      if Outcomes[Integer(Parameter.CriticalOutcome)] < 0 then Outcomes[Integer(Parameter.CriticalOutcome)] := i;
  end;
  if Outcomes[3] >= 0 then Selected := Outcomes[3]
  else if Outcomes[1] >= 0 then Selected := Outcomes[1]
  else if Outcomes[2] >= 0 then Selected := Outcomes[2]
  else Exit;
  Result := True;
  OutcomeEvent.Assign(GetParameter(Selected).CriticalEvent);
  Outcome := GetParameter(Selected).CriticalOutcome;
  Event := GetParameter(Selected).CriticalEventOverride;
  if Event <> nil then
  begin
    if TrimWideString(Event.Text.Text) <> '' then OutcomeEvent.Text.Text := Event.Text.Text;
    if TrimWideString(Event.Picture.Text) <> '' then OutcomeEvent.Picture.Text := Event.Picture.Text;
    if TrimWideString(Event.Sound.Text) <> '' then OutcomeEvent.Sound.Text := Event.Sound.Text;
    if TrimWideString(Event.Music.Text) <> '' then OutcomeEvent.Music.Text := Event.Music.Text;
  end;
end;
{ @end $4E7284 }

{ @routine $4E74CC TTextQuest_Start }
procedure TTextQuest.Start(Money: Integer; PreserveExternalParameters: Boolean);
var
  i, StartId: Integer;
begin
  if PlayerInterface <> nil then
  begin
    TextShown := False;
    OutcomeEvent.ClearTextFields;
    Outcome := qoNone;
    DisplayedEvent := nil;
    StartId := -1;
    for i := 1 to GetLocationCount do
      if GetLocation(i).IsStart then
      begin
        StartId := GetLocation(i).Id;
        Break;
      end;
    if StartId < 0 then
    begin
      Dialogs.ShowMessage('Cant find starting location');
      Exit;
    end;
    for i := 1 to GetParameterCount do
      if GetParameter(i).Enabled then
      begin
        GetParameter(i).Hidden := False;
        GetParameter(i).CriticalEventOverride := nil;
        if GetParameter(i).IsMoney and (Money >= 0) then GetParameter(i).Value := Money
        else if not PreserveExternalParameters or
          (FindTextPosW('ext_', GetParameter(i).NameText.Text) <> 1) then
          if GetParameter(i).InitialRange.RangeCount > 0 then
            GetParameter(i).Value := Trunc(GetParameter(i).InitialRange.GetRandomValue);
      end;
    for i := 1 to GetLocationCount do GetLocation(i).VisitCount := 0;
    ResetEventIndices;
    for i := 1 to GetPathCount do GetPath(i).TraversalCount := 0;
    EnterLocation(StartId);
  end;
end;
{ @end $4E74CC }

{ @routine $4E76FC TTextQuest_EnterLocation }
procedure TTextQuest.EnterLocation(LocationId: Integer);
var
  Location, Target: TLocation;
  Caption, GroupCaption: WideString;
  i, j, Selected: Integer;
  Critical: Boolean;
  Pending, Group, Chosen: TList;
  Path, Other: TPath;
  Eligible: Boolean;
  MaxPriority, TotalPriority, RandomPriority: Double;
  Event: TEvent;
begin
  if PlayerInterface <> nil then
  begin
    Location := GetLocation(FindLocationIndex(LocationId));
    if TextShown and not Location.IsEmpty then
    begin
      TextShown := False;
      // The folded +0 makes DCC32 evaluate the receiver before simple arguments.
      TTextQuestInterface(Pointer(PAnsiChar(PlayerInterface) + 0)).AddLocationContinueAction(LocationId);
    end
    else
    begin
      Location.ApplyParameterChanges(Parameters);
      if Location.Days > 0 then PlayerInterface.AdvanceDays(Location.Days);
      Inc(Location.VisitCount);
      GroupCaption := '';
      ShowParameters;
      Critical := CheckCriticalParameters;
      Event := Location.SelectEvent(Parameters);
      if Event <> nil then
        if not TextShown or not Location.IsEmpty then
        begin
          ShowEvent(Event);
          if TrimWideString(Event.Text.Text) <> '' then LastEventSource := 'Location ' + IntToWideString(Location.Id);
        end;
      if Critical then
      begin
        if TextShown then PlayerInterface.AddContinueAction
        else ShowOutcome;
      end
      else if Location.IsSuccess then PlayerInterface.AddSuccessAction
      else if Location.IsDeath then PlayerInterface.AddDeathAction
      else if Location.IsFailure then PlayerInterface.AddFailureAction
      else
      begin
        Pending := TList.Create;
        Group := TList.Create;
        Chosen := TList.Create;
        for i := 1 to GetPathCount do
        begin
          Path := GetPath(i);
          if (Location.Id <> Path.FromLocationId) or
            ((Path.TraversalLimit > 0) and (Path.TraversalCount >= Path.TraversalLimit)) then Continue;
          Eligible := False;
          for j := 1 to GetLocationCount do
          begin
            Target := GetLocation(j);
            if Target.Id = Path.ToLocationId then
            begin
              Eligible := (Target.VisitLimit = 0) or (Target.VisitLimit > Target.VisitCount);
              Break;
            end;
          end;
          if not Eligible then Continue;
          Path.CheckAvailable(Parameters);
          if not Path.Available then
          begin
            if not Path.AlwaysShow then Continue;
            if TrimWideString(Path.Caption.Text) = '' then Continue;
          end;
          Pending.Add(Path);
        end;
        while Pending.Count > 0 do
        begin
          Path := TPath(Pending[0]);
          GroupCaption := ExpandText(TrimWideString(Path.Caption.Text), False);
          Group.Add(Path);
          Pending.Delete(0);
          for i := Pending.Count - 1 downto 0 do
          begin
            Path := TPath(Pending[i]);
            if GroupCaption = ExpandText(TrimWideString(Path.Caption.Text), False) then
            begin
              Pending.Delete(i);
              if Path.Available or (Group.Count <= 0) then
              begin
                Group.Add(Path);
                if Group.Count > 1 then
                begin
                  Path := TPath(Group[0]);
                  if not Path.Available then Group.Delete(0);
                end;
              end;
            end;
          end;
          MaxPriority := 0;
          for i := 0 to Group.Count - 1 do
          begin
            Path := TPath(Group[i]);
            if MaxPriority < Path.Priority then MaxPriority := Path.Priority;
          end;
          if Group.Count = 1 then
          begin
            if System.Random <= MaxPriority then Chosen.Add(Group[0]);
          end
          else
          begin
            for i := Group.Count - 1 downto 0 do
            begin
              Path := TPath(Group[i]);
              if Path.Priority <= MaxPriority * 0.01 then Group.Delete(i);
            end;
            TotalPriority := 0;
            for i := 0 to Group.Count - 1 do
            begin
              Path := TPath(Group[i]);
              TotalPriority := TotalPriority + Path.Priority;
            end;
            RandomPriority := System.Random * TotalPriority;
            Selected := Group.Count - 1;
            for i := 0 to Group.Count - 1 do
            begin
              Path := TPath(Group[i]);
              if Path.Priority > RandomPriority then
              begin
                Selected := i;
                Break;
              end;
              RandomPriority := RandomPriority - Path.Priority;
            end;
            Chosen.Add(Group[Selected]);
          end;
          Group.Clear;
        end;
        if Chosen.Count = 0 then
        begin
          Chosen.Free;
          Group.Free;
          Pending.Free;
          Dialogs.ShowMessage(AnsiString('No available answers from location ' + IntToWideString(Location.Id)));
          Exit;
        end;
        if Chosen.Count = 1 then
        begin
          Path := TPath(Chosen[0]);
          if TrimWideString(Path.Caption.Text) = '' then
          begin
            Chosen.Free;
            Group.Free;
            Pending.Free;
            FollowPath(Path.Id);
            Exit;
          end;
        end;
        for i := 1 to Chosen.Count * 2 do
        begin
          Selected := System.Random(Chosen.Count);
          Path := TPath(Chosen[Selected]);
          j := System.Random(Chosen.Count);
          Chosen[Selected] := Chosen[j];
          Chosen[j] := Path;
        end;
        for i := 2 to Chosen.Count do
          for j := 0 to Chosen.Count - i do
          begin
            Path := TPath(Chosen[j]);
            Other := TPath(Chosen[j + 1]);
            if Other.DisplayOrder < Path.DisplayOrder then
            begin
              Chosen[j] := Other;
              Chosen[j + 1] := Path;
            end;
          end;
        for i := 0 to Chosen.Count - 1 do
        begin
          Path := TPath(Chosen[i]);
          Caption := TrimWideString(Path.Caption.Text);
          if Caption <> '' then
          begin
            Caption := ExpandText(Caption, True);
            if Path.Available then TTextQuestInterface(Pointer(PAnsiChar(PlayerInterface) + 0)).AddPathAction(Caption, Path.Id)
            else TTextQuestInterface(Pointer(PAnsiChar(PlayerInterface) + 0)).AddDisabledPath(Caption);
          end;
        end;
        Chosen.Free;
        Group.Free;
        Pending.Free;
        TextShown := False;
      end;
    end;
  end;
end;
{ @end $4E76FC }

{ @routine $4E7FAC TTextQuest_FollowPath }
procedure TTextQuest.FollowPath(PathId: Integer);
var
  Path: TPath;
  Critical: Boolean;
begin
  if PlayerInterface <> nil then
  begin
    Path := GetPath(FindPathIndex(PathId));
    if TextShown and (TrimWideString(Path.Event.Text.Text) <> '') then
    begin
      TextShown := False;
      PlayerInterface.AddPathContinueAction(PathId);
    end
    else
    begin
      Path.ApplyParameterChanges(Parameters);
      if Path.Days > 0 then PlayerInterface.AdvanceDays(Path.Days);
      Inc(Path.TraversalCount);
      ShowParameters;
      Critical := CheckCriticalParameters;
      ShowEvent(Path.Event);
      LastEventSource := 'Path ' + IntToWideString(Path.Id);
      if Critical then
      begin
        if TextShown then PlayerInterface.AddContinueAction
        else ShowOutcome;
      end
      else EnterLocation(Path.ToLocationId);
    end;
  end;
end;
{ @end $4E7FAC }

{ @routine $4E8110 TTextQuest_ShowEvent }
procedure TTextQuest.ShowEvent(Event: TEvent);
var
  Text: WideString;
begin
  if (PlayerInterface <> nil) and (Event <> nil) then
  begin
    DisplayedEvent := Event;
    Text := TrimWideString(Event.Text.Text);
    if Text <> '' then
    begin
      Text := ExpandText(Text, True);
      PlayerInterface.ShowText(Text);
      TextShown := True;
    end;
    if TrimWideString(Event.Picture.Text) <> '' then PlayerInterface.ShowPicture(TrimWideString(Event.Picture.Text));
    if TrimWideString(Event.Music.Text) <> '' then PlayerInterface.PlayMusic(TrimWideString(Event.Music.Text));
    if TrimWideString(Event.Sound.Text) <> '' then PlayerInterface.PlaySound(TrimWideString(Event.Sound.Text));
  end;
end;
{ @end $4E8110 }

{ @routine $4E827C TTextQuest_ShowOutcome }
procedure TTextQuest.ShowOutcome;
begin
  if PlayerInterface <> nil then
  begin
    ShowEvent(OutcomeEvent);
    LastEventSource := 'Critical param value';
    case Outcome of
      qoFailure: PlayerInterface.AddFailureAction;
      qoSuccess: PlayerInterface.AddSuccessAction;
      qoDeath: PlayerInterface.AddDeathAction;
    end;
  end;
end;
{ @end $4E827C }

{ @routine $4E8314 TTextQuest_ShowParameters }
procedure TTextQuest.ShowParameters;
var
  ValueText, Text: WideString;
  i: Integer;
begin
  if PlayerInterface <> nil then
  begin
    Text := '';
    for i := 1 to GetParameterCount do
      if GetParameter(i).Enabled and not GetParameter(i).Hidden and
        ((GetParameter(i).Value <> 0) or GetParameter(i).ShowWhenZero) then
      begin
        ValueText := GetParameter(i).GetValueText(GetParameter(i).Value);
        ValueText := ReplaceAllWideString(ValueText, '<>', IntToWideString(GetParameter(i).Value));
        Text := Text + ValueText + #13#10;
      end;
    Text := ExpandText(Text, True);
    PlayerInterface.ShowParameters(Text);
  end;
end;
{ @end $4E8314 }

end.
