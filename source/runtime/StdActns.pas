unit StdActns;
// Unit bracket (inferred): .text 0x004306B0..0x004307DC; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  THintAction = class(TCustomAction) // @size 0xA0
  public
    constructor Create(AOwner: TComponent); override; // @ida "THintAction * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TComponent *AOwner@<ecx>);" @note "DCC32 MAP StdActns.THintAction.Create. Source vcl/StdActns.pas:560." @slot 0x2C
  end;

implementation
end.
