program ShapeProbe;
{$APPTYPE CONSOLE}
{$O-}{$R-}{$Q-}{$INLINE OFF}

function BranchSpills(X, Lo, Hi: Integer): Integer;
var T: Integer;
begin
  if X < Lo then T := Lo
  else if X > Hi then T := Hi
  else T := X;
  Result := T;
end;

function CountedSum(N: Integer): Integer;
var I, S: Integer;
begin
  S := 0;
  for I := 0 to N - 1 do
    S := S + I;
  Result := S;
end;

function WhileSum(N: Integer): Integer;
var I, S: Integer;
begin
  S := 0;
  I := 0;
  while I < N do
  begin
    S := S + I;
    Inc(I);
  end;
  Result := S;
end;

function LocalRounding(A, B, C: Double): Double;
var T: Double;
begin
  T := A + B;
  Result := T * C;
end;

function FloatEQ(A, B: Double): Double;
begin
  if A = B then Result := A else Result := B;
end;

function FloatNE(A, B: Double): Double;
begin
  if A <> B then Result := A else Result := B;
end;

function FloatLT(A, B: Double): Double;
begin
  if A < B then Result := A else Result := B;
end;

function FloatLE(A, B: Double): Double;
begin
  if A <= B then Result := A else Result := B;
end;

function FloatGT(A, B: Double): Double;
begin
  if A > B then Result := A else Result := B;
end;

function FloatGE(A, B: Double): Double;
begin
  if A >= B then Result := A else Result := B;
end;

procedure ManagedTry(var Text: WideString);
var S: WideString;
begin
  S := Text;
  try
    Text := S + '!';
  finally
    S := '';
  end;
end;

var N: Integer; F: Double; Text: WideString;
begin
  N := BranchSpills(2, 0, 4);
  N := CountedSum(N);
  N := WhileSum(N);
  F := LocalRounding(N, 1.5, 2.5);
  F := FloatEQ(F, 1);
  F := FloatNE(F, 1);
  F := FloatLT(F, 1);
  F := FloatLE(F, 1);
  F := FloatGT(F, 1);
  F := FloatGE(F, 1);
  ManagedTry(Text);
  Writeln(N, F, Text);
end.
