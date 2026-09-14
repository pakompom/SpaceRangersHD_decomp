unit ZeroMask;
interface
type TMask = set of 0..19;
const Empty = [0..19] - [0..19];
function Take(Flags: TMask = []): Single;
implementation
function Take(Flags: TMask): Single;
begin Result := 1; end;
end.
