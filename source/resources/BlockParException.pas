unit BlockParException;
// Unit bracket (inferred): .text 0x00471F9C..0x00472094; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses SysUtils;

type
  EBlockPar = class(Exception) // @size $10
  private
    Reportable: Boolean; // @offset $0C
  public
    constructor Create(Message: AnsiString; AReportable: Boolean); // @addr $471FF4
    function IsReportable: Boolean; // @addr $47207C @note "False suppresses the reporting flag in ExceptionInfo."
  end;

implementation

{ @routine $471FF4 EBlockPar_Create }
constructor EBlockPar.Create(Message: AnsiString; AReportable: Boolean);
begin
  inherited Create(Message);
  Reportable := AReportable;
end;
{ @end $471FF4 }

{ @routine $47207C EBlockPar_IsReportable }
function EBlockPar.IsReportable: Boolean;
begin Result := Reportable end;
{ @end $47207C }

end.
