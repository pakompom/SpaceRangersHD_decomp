unit SyncObjs;
// Unit bracket (inferred): .text 0x0042951C..0x00429685; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TCriticalSection = class // @size 0x1C
  public
    // The Win32 critical-section record at +0x04 is left opaque.
    constructor Create; // @ida "TCriticalSection *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @ida "void __usercall $name(TCriticalSection *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Enter; // @addr 0x429678
    procedure Leave; // @addr $429680
  end;

implementation
end.
