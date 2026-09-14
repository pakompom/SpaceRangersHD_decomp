unit Rangers;
// Declaration companion for the program in Rangers.dpr; no linked Delphi unit.
interface
uses SysUtils;
procedure start; // @addr $876AB4 @ida "void __noreturn __usercall $name();"
var
  StartupException: Exception; // @addr $88C4B8 Compiler-created on-exception variable in Rangers.dpr; not separate storage.
implementation
end.
