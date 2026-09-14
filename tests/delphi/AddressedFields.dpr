program AddressedFields;
{$APPTYPE CONSOLE}
{$O-}{$R-}{$Q-}{$B-}
type
  TPixel = packed record B, G, R, A: Byte end;
  PPixel = ^TPixel;
  TWords = packed record Low, High: Cardinal end;
  PWords = ^TWords;
function RawChannel(P: Pointer): Byte;
begin Result := PByte(PAnsiChar(P) + 1)^ end;
function FieldChannel(P: Pointer): Byte;
begin Result := PPixel(P).G end;
function AddressChannel(P: Pointer): Byte;
begin Result := PByte(@PPixel(P).G)^ end;
procedure RawStore(P: Pointer; V: Byte);
begin PByte(PAnsiChar(P) + 3)^ := V end;
procedure FieldStore(P: Pointer; V: Byte);
begin PPixel(P).A := V end;
procedure AddressStore(P: Pointer; V: Byte);
begin PByte(@PPixel(P).A)^ := V end;
procedure RawXor(var V: UInt64; Mask: Cardinal);
begin PCardinal(PAnsiChar(@V) + 4)^ := PCardinal(PAnsiChar(@V) + 4)^ xor Mask end;
procedure FieldXor(var V: UInt64; Mask: Cardinal);
begin TWords(V).High := TWords(V).High xor Mask end;
procedure AddressXor(var V: UInt64; Mask: Cardinal);
begin PCardinal(@TWords(V).High)^ := PCardinal(@TWords(V).High)^ xor Mask end;
var P: TPixel; V: UInt64;
begin
  RawStore(@P, 1); FieldStore(@P, 1); AddressStore(@P, 1);
  RawXor(V, 1); FieldXor(V, 1); AddressXor(V, 1);
  Writeln(RawChannel(@P), FieldChannel(@P), AddressChannel(@P));
end.
