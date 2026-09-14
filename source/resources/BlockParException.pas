unit BlockParException;
// Unit bracket (inferred): .text 0x00602698..0x00602790; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses SysUtils;

type
  EBlockPar = class(Exception) // @size $10
  private
    Reportable: Boolean; // @offset $0C
  public
    constructor Create(Message: AnsiString; AReportable: Boolean); // @addr $6026F0 @ida "EBlockPar *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, char *Message@<ecx>, bool AReportable@<^0>);"
    function IsReportable: Boolean; // @addr $602778 @note "False suppresses the reporting flag in ExceptionInfo."
  end;

implementation

{ @routine $6026F0 EBlockPar_Create }
constructor EBlockPar.Create(Message: AnsiString; AReportable: Boolean);
begin
  inherited Create(Message);
  Reportable := AReportable;
end;
{ @end $6026F0 }

{ @routine $602778 EBlockPar_IsReportable }
function EBlockPar.IsReportable: Boolean;
begin Result := Reportable end;
{ @end $602778 }

end.
