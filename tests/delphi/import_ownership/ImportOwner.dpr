program ImportOwner; uses A, B; var Sink: Integer; begin Sink := A.SharedExternal(1); Sink := B.SharedExternal(Sink); end.
