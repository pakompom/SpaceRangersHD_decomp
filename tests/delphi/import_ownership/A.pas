unit A; interface
function SharedExternal(Value: Integer): Integer; stdcall; external 'probe.dll' name 'SharedExternal';
implementation end.
