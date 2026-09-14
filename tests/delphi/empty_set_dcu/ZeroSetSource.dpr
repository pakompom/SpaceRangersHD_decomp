program ZeroSetSource;
{$O-}
uses ZeroMask;
function Imported(X: Single): Single;
begin Result := Take(Empty); if X < 0 then Result := 0; end;
function DefaultArgument(X: Single): Single;
begin Result := Take; if X < 0 then Result := 0; end;
function Literal(X: Single): Single;
begin Result := Take([]); if X < 0 then Result := 0; end;
exports Imported, DefaultArgument, Literal;
begin end.
