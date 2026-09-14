program GraphUtilInit;
uses Classes, GraphUtil;
{ Retain Classes.GlobalLoaded as in Rangers, preserving the native TLS prefix. }
procedure Probe(Component: TComponent);
begin
  InitInheritedComponent(Component, TComponent);
end;
exports Probe;
begin
end.
