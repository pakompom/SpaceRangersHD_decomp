unit MaskConsumer;
interface
uses MaskTypes;
procedure Probe(Value: Integer); // @addr $1000
var ObservedAddress: Pointer; // @addr $2000
implementation
procedure Observe(P: Pointer);
begin
  ObservedAddress := P;
end;
{ @routine $1000 Probe }
procedure Probe(Value: Integer);
var
  Marker: Byte;
  Mask: TMask;
  Tail: Byte;
begin
  Marker := 1;
  Mask := [0];
  Tail := 2;
  Observe(@Marker);
  Observe(@Mask);
  Observe(@Tail);
end;
{ @end $1000 }
end.
