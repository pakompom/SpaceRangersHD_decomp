program InlineExpressionChecks;
// Compile-only DCC32 controls. See EC_Expression compiler helpers.
// Whole predicates preserve branches; partial inlining introduces a Boolean temporary.
// Node initialization via var changes load order; returning a node adds a temporary.
{$APPTYPE CONSOLE}
{$O-}{$R-}{$Q-}{$B-}
type
  TKind = (kA, kB, kC, kD, kE, kF, kG, kH);
  TNode = class
    Start, Len: Integer;
    Next: TNode;
    Kind: TKind;
    Value: Integer;
  end;
  TBuilder = class
    function AddNode: TNode;
  end;
function TBuilder.AddNode: TNode;
begin Result := TNode.Create end;
procedure AddByVar(var Builder: TBuilder; var Item: TNode; const Token: TNode; Kind: TKind); inline;
begin
  Item := Builder.AddNode;
  Item.Start := Token.Start;
  Item.Len := Token.Len;
  Item.Kind := Kind;
end;
function AddByResult(var Builder: TBuilder; const Token: TNode; Kind: TKind): TNode; inline;
begin
  Result := Builder.AddNode;
  Result.Start := Token.Start;
  Result.Len := Token.Len;
  Result.Kind := Kind;
end;
function Raw(Builder: TBuilder; Token: TNode; Value: Integer): Integer;
var Item: TNode;
begin
  Item := Builder.AddNode;
  Item.Start := Token.Start;
  Item.Len := Token.Len;
  Item.Kind := kB;
  Item.Value := Value;
  Result := Item.Value;
end;
function ByVar(Builder: TBuilder; Token: TNode; Value: Integer): Integer;
var Item: TNode;
begin
  AddByVar(Builder, Item, Token, kB);
  Item.Value := Value;
  Result := Item.Value;
end;
function ByResult(Builder: TBuilder; Token: TNode; Value: Integer): Integer;
var Item: TNode;
begin
  Item := AddByResult(Builder, Token, kB);
  Item.Value := Value;
  Result := Item.Value;
end;
function IsOperand(const Item: TNode): Boolean; inline;
begin Result := (Item.Kind = kA) or (Item.Kind = kB) or (Item.Kind = kD) or (Item.Kind = kF) end;
function RawPredicate(Item: TNode): Integer;
begin
  if (Item.Kind = kA) or (Item.Kind = kB) or (Item.Kind = kD) or (Item.Kind = kF) then Result := 1
  else Result := 2;
end;
function InlinePredicate(Item: TNode): Integer;
begin
  if IsOperand(Item) then Result := 1
  else Result := 2;
end;
function RawNextPredicate(Item: TNode): Integer;
begin
  if (Item.Next = nil) or not ((Item.Next.Kind = kA) or (Item.Next.Kind = kB) or (Item.Next.Kind = kD) or (Item.Next.Kind = kF)) then Result := 1
  else Result := 2;
end;
function InlineNextPredicate(Item: TNode): Integer;
begin
  if (Item.Next = nil) or not IsOperand(Item.Next) then Result := 1
  else Result := 2;
end;
function InvalidNext(const Item: TNode): Boolean; inline;
begin Result := (Item.Next = nil) or not ((Item.Next.Kind = kA) or (Item.Next.Kind = kB) or (Item.Next.Kind = kD) or (Item.Next.Kind = kF)) end;
function InlineWholePredicate(Item: TNode): Integer;
begin
  if InvalidNext(Item) then Result := 1 else Result := 2;
end;
var Builder: TBuilder; Token: TNode;
begin
  Builder := TBuilder.Create; Token := TNode.Create;
  Writeln(Raw(Builder, Token, 1), ByVar(Builder, Token, 1), ByResult(Builder, Token, 1));
  Writeln(RawPredicate(Token), InlinePredicate(Token));
  Writeln(RawNextPredicate(Token), InlineNextPredicate(Token));
  Writeln(InlineWholePredicate(Token));
end.
