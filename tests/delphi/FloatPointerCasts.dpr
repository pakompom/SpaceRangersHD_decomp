program FloatPointerCasts;
// DCC32 Pointer/Single hard casts move raw bits; no integer/real conversion.
// Native use: TGalaxy.HideSpecialConstellation stores Single coordinates in TList.
{$O-}
function BitsToSingle(P: Pointer): Single;
begin
  Result := Single(P);
end;
function SingleToBits(Value: Single): Pointer;
begin
  Result := Pointer(Value);
end;
begin
  Writeln(BitsToSingle(SingleToBits(1.0)));
end.
