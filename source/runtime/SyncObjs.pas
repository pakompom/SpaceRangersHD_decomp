unit SyncObjs;

interface

type
  TCriticalSection = class // @size 0x1C
  public
    // The Win32 critical-section record at +0x04 is left opaque.
    constructor Create;
    destructor Destroy; override;
    procedure Enter; // @addr 0x00429678
    procedure Leave; // @addr $429680
  end;

implementation
end.
