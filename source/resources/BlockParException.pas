unit BlockParException;

interface

uses SysUtils;

type
  EBlockPar = class(Exception) // @size $10
  private
    Reportable: Boolean; // @offset $0C
  public
    constructor Create(Message: AnsiString; AReportable: Boolean); // @addr $4CC288
    function IsReportable: Boolean; // @addr $4CC308 @note "False suppresses the reporting flag in ExceptionInfo."
  end;

implementation

{ @routine $4CC288 EBlockPar_Create }
constructor EBlockPar.Create(Message: AnsiString; AReportable: Boolean);
begin
  inherited Create(Message);
  Reportable := AReportable;
end;
{ @end $4CC288 }

{ @routine $4CC308 EBlockPar_IsReportable }
function EBlockPar.IsReportable: Boolean;
begin Result := Reportable end;
{ @end $4CC308 }

end.
