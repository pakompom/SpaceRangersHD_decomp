library ControlFlow;
{$O-}{$R-}{$Q-}{$B-}

type
  TNode = class
    Value: Integer;
  end;

function Probe(State: PInteger; Bound: Integer): Integer;
begin
  Inc(State^);
  Result := State^ mod Bound;
end;

function SharedGate(State: PInteger; Capacity, Count: Integer; Pirate: Boolean): Integer;
var Attempts: Integer;
begin
  Result := -1;
  if ((Capacity >= Count) and (Probe(State, Probe(State, 2) + 1) = 0)) or
    (Probe(State, 100) < 30) or Pirate then
  begin
    Attempts := 0;
    repeat
      Inc(Attempts);
    until (Attempts > 3) or (Probe(State, 5) = 0);
    Result := Attempts;
  end;
end;

function ContinueLoop(Count: Integer): Integer;
var I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    if I = 2 then Continue;
    Inc(Result, I);
  end;
end;

function ConditionalLoop(State: PInteger; Limit: Integer): Integer;
var Attempts, Choice: Integer;
begin
  Attempts := 0;
  Choice := -1;
  while True do
  begin
    if Attempts > Limit then Break;
    Inc(Attempts);
    Choice := Probe(State, 5);
    if (Choice = 1) and (Probe(State, 3) <> 0) then Continue;
    if Choice = 2 then Continue;
    Break;
  end;
  Result := Choice;
end;

function NestedBounds(Count: Integer): Integer;
var I, J: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    for J := I + 1 to Count - 1 do
    begin
      if J = 2 then Continue;
      Inc(Result, J);
    end;
end;

function OpaqueNode(Value: Pointer): Pointer;
begin
  Result := Value;
end;

procedure TouchNode(Value: TNode);
begin
  Inc(Value.Value);
end;

function PointerField(Value: Pointer): Integer;
var Node: TNode;
begin
  Node := TNode(OpaqueNode(Value));
  Result := Node.Value;
  TouchNode(Node);
end;

exports Probe, SharedGate, ContinueLoop, ConditionalLoop, NestedBounds, OpaqueNode, TouchNode, PointerField;
begin
end.
