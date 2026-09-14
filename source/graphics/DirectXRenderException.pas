unit DirectXRenderException;
// Unit bracket (inferred): .text 0x004B8594..0x004B8722; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses SysUtils;

type
  EDirectXRender = class(Exception) // @size $10
  public
    ErrorCode: Integer; // @offset $0C
    constructor Create(Message: AnsiString); // @addr $4B85F0 @ida "EDirectXRender * __usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, char *Message@<ecx>);"
    constructor CreateCode(Message: AnsiString; Code: Integer); // @addr $4B866C @ida "EDirectXRender * __userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, char *Message@<ecx>, int Code@<^0>);"
  end;

implementation

uses GR_Main;

{ @routine $4B85F0 EDirectXRender_Create }
constructor EDirectXRender.Create(Message: AnsiString);
begin
  inherited Create(Message);
end;
{ @end $4B85F0 }

{ @routine $4B866C EDirectXRender_CreateCode }
constructor EDirectXRender.CreateCode(Message: AnsiString; Code: Integer);
begin
  inherited Create(Message + ' = ' + Direct3DErrorText(Code));
  ErrorCode := Code;
end;
{ @end $4B866C }

end.
