program SetLiteralPools;
{$O-}
{ Compile-only control: identical mask loads target .text for literal/untyped
  sets, but .data for typed constants. See docs/development.md. }
type TMask = set of 0..15;
     TOwners = set of 0..7;
var Sink: Integer;
procedure TakeMask(Value: TMask);
begin Sink := Word(Value); end;
procedure TakeOwners(Value: TOwners);
begin Sink := Byte(Value); end;
procedure LiteralMask;
begin TakeMask([6..12]); end;
procedure NamedMask;
const Mask = [6..12];
begin TakeMask(Mask); end;
procedure TypedMask;
const Mask: TMask = [6..12];
begin TakeMask(Mask); end;
procedure LiteralOwners;
begin TakeOwners([0..7]); end;
exports LiteralMask, NamedMask, TypedMask, LiteralOwners;
begin end.
