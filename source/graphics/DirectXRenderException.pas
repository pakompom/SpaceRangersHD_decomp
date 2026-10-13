unit DirectXRenderException;

interface

uses SysUtils;

type
  EDirectXRender = class(Exception) // @size $10
  public
    ErrorCode: Integer; // @offset $0C
    constructor Create(Message: AnsiString); // @addr $4828A0
    constructor CreateCode(Message: AnsiString; Code: Integer); // @addr $482914
  end;

implementation

uses GR_Main;

{ @routine $4828A0 EDirectXRender_Create }
constructor EDirectXRender.Create(Message: AnsiString);
begin
  inherited Create(Message);
end;
{ @end $4828A0 }

{ @routine $482914 EDirectXRender_CreateCode }
constructor EDirectXRender.CreateCode(Message: AnsiString; Code: Integer);
begin
  inherited Create(Message + ' = ' + Direct3DErrorText(Code));
  ErrorCode := Code;
end;
{ @end $482914 }

end.
