program SetMembershipPools;
{$O-}
{ Compile-only control for the ten-byte native item mask. Literal parsing trims
  zero edge bytes; folded set differences retain their operand storage range. }
type TItemMask = set of 0..79;
var Sink: Boolean;
procedure StoredMask(Value: Byte);
const Mask: TItemMask = [8, 10..22, 26..34, 39..41, 43..68, 73];
begin
  Sink := Value in Mask;
end;
procedure TrimmedLiteral(Value: Byte);
const Mask = [8, 10..22, 26..34, 39..41, 43..68, 73];
begin
  Sink := Value in Mask;
end;
procedure FullRangeDifference(Value: Byte);
const Mask = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
begin
  Sink := Value in Mask;
end;
exports StoredMask, TrimmedLiteral, FullRangeDifference;
begin
end.
