unit SyncObjs;
// Unit bracket (inferred): .text 0x0042951C..0x00429685; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TCriticalSection = class // @size 0x1C
  public
    // The Win32 critical-section record at +0x04 is left opaque.
    constructor Create;
    destructor Destroy; override;
    procedure Enter; // @addr 0x429678
    procedure Leave; // @addr $429680
  end;

implementation
end.
