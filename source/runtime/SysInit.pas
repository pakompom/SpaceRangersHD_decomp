unit SysInit;

interface

procedure InitThreadTLS; // @note "Allocates this thread's Delphi TLS block when the module has TLS data; raises the RTL error on failure."

function _GetTls: Pointer;

procedure InitExe(InitTable: Pointer); // @note "Compiler executable startup; EAX is the unit initialization table. Native $407BB8 forwards it to System.StartExe after module/TLS setup."

implementation
end.
