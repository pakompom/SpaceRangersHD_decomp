unit DirectXRenderException;
// Unit bracket (inferred): .text 0x004C5900..0x004C5A8E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses SysUtils;

type
  EDirectXRender = class(Exception) // @size $10
  public
    ErrorCode: Integer; // @offset $0C
    constructor Create(Message: AnsiString); // @addr $4C595C
    constructor CreateCode(Message: AnsiString; Code: Integer); // @addr $4C59D8
  end;

implementation

uses GR_Main;

{ @routine $4C595C EDirectXRender_Create }
constructor EDirectXRender.Create(Message: AnsiString);
begin
  inherited Create(Message);
end;
{ @end $4C595C }

{ @routine $4C59D8 EDirectXRender_CreateCode }
constructor EDirectXRender.CreateCode(Message: AnsiString; Code: Integer);
begin
  inherited Create(Message + ' = ' + Direct3DErrorText(Code));
  ErrorCode := Code;
end;
{ @end $4C59D8 }

end.
