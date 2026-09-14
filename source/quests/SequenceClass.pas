unit SequenceClass;
// Unit bracket (inferred): .text 0x004E32EC..0x004E36A5; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Struct;

type
  TSequence = class(TObjectEx) // @size 0x14
  public
    // Initialized to zero; its purpose remains unresolved.
    UnknownFlag: Byte; // @offset 0x04
    TraversalLimit: Integer; // @offset 0x08
    Locations: TList; // @offset 0x0C // Owns the list, not its TLocation entries.
    Paths: TList; // @offset 0x10 // Owns the list, not its TPath entries.

    constructor Create; // @addr 0x4E3344 @ida "TSequence *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4E33B8 @ida "void __usercall $name(TSequence *Self@<eax>, __int8 DestroyFlags@<dl>);" @note "Clears member Sequence links without freeing the members."
    procedure SetTraversalLimit(Value: Integer); // @addr 0x4E349C @note "Also updates every member's visit or traversal limit."
    procedure RecomputeTraversalLimit; // @addr 0x4E3534 @note "Propagates the minimum positive member limit, or zero if none."
    procedure AddLocation(Location: Pointer); // @addr 0x4E3614
    procedure AddPath(Path: Pointer); // @addr 0x4E3644
    procedure PrependPath(Path: Pointer); // @addr 0x4E3674
  end;

implementation

uses LocationClass, PathClass;

{ @routine $4E3344 TSequence_Create }
constructor TSequence.Create;
begin
  inherited Create;
  Locations := TList.Create;
  Paths := TList.Create;
  TraversalLimit := 0;
  UnknownFlag := 0;
end;
{ @end $4E3344 }

{ @routine $4E33B8 TSequence_Destroy }
destructor TSequence.Destroy;
var
  i: Integer;
  Location: TLocation;
  Path: TPath;
begin
  for i := 0 to Locations.Count - 1 do
  begin
    Location := TLocation(Locations[i]);
    Location.Sequence := nil;
  end;
  for i := 0 to Paths.Count - 1 do
  begin
    Path := TPath(Paths[i]);
    Path.Sequence := nil;
  end;
  Locations.Clear;
  Locations.Free;
  Locations := nil;
  Paths.Clear;
  Paths.Free;
  Paths := nil;
  inherited Destroy;
end;
{ @end $4E33B8 }

{ @routine $4E349C TSequence_SetTraversalLimit }
procedure TSequence.SetTraversalLimit(Value: Integer);
var
  i: Integer;
  Location: TLocation;
  Path: TPath;
begin
  TraversalLimit := Value;
  for i := 0 to Locations.Count - 1 do
  begin
    Location := TLocation(Locations[i]);
    Location.VisitLimit := TraversalLimit;
  end;
  for i := 0 to Paths.Count - 1 do
  begin
    Path := TPath(Paths[i]);
    Path.TraversalLimit := TraversalLimit;
  end;
end;
{ @end $4E349C }

{ @routine $4E3534 TSequence_RecomputeTraversalLimit }
procedure TSequence.RecomputeTraversalLimit;
var
  i: Integer;
  Location: TLocation;
  Path: TPath;
begin
  TraversalLimit := 0;
  for i := 0 to Locations.Count - 1 do
  begin
    Location := TLocation(Locations[i]);
    if Location.VisitLimit > 0 then
      if (TraversalLimit = 0) or (Location.VisitLimit < TraversalLimit) then TraversalLimit := Location.VisitLimit;
  end;
  for i := 0 to Paths.Count - 1 do
  begin
    Path := TPath(Paths[i]);
    if Path.TraversalLimit > 0 then
      if (TraversalLimit = 0) or (Path.TraversalLimit < TraversalLimit) then TraversalLimit := Path.TraversalLimit;
  end;
  SetTraversalLimit(TraversalLimit);
end;
{ @end $4E3534 }

{ @routine $4E3614 TSequence_AddLocation }
procedure TSequence.AddLocation(Location: Pointer);
var
  Member: TLocation;
begin
  Member := Location;
  Locations.Add(Location);
  Member.Sequence := Self;
end;
{ @end $4E3614 }

{ @routine $4E3644 TSequence_AddPath }
procedure TSequence.AddPath(Path: Pointer);
var
  Member: TPath;
begin
  Member := Path;
  Paths.Add(Path);
  Member.Sequence := Self;
end;
{ @end $4E3644 }

{ @routine $4E3674 TSequence_PrependPath }
procedure TSequence.PrependPath(Path: Pointer);
var
  Member: TPath;
begin
  Member := Path;
  Paths.Insert(0, Path);
  Member.Sequence := Self;
end;
{ @end $4E3674 }

end.
