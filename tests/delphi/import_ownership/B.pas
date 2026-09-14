unit B; interface
function SharedExternal(Value: Integer): Integer; stdcall; external 'probe.dll' name 'SharedExternal';
implementation end.
