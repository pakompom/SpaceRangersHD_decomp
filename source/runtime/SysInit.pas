unit SysInit;
// Unit bracket (inferred): .text 0x00407B28..0x00407BF8; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

procedure InitThreadTLS; // @note "Allocates this thread's Delphi TLS block when the module has TLS data; raises the RTL error on failure."

function _GetTls: Pointer; // @note "DCC32 MAP SysInit.@GetTls. Source rtl/sys/SysInit.pas:341."

procedure InitExe(InitTable: Pointer); // @note "Compiler executable startup; EAX is the unit initialization table. Native $407BB8 forwards it to System.StartExe after module/TLS setup."

implementation
end.
