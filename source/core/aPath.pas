unit aPath;
// Unit bracket (inferred): .text 0x004D75EC..0x004D8567; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008757E8..0x008757EF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, SyncObjs;

type
  PSPathNode = ^TSPathNode;
  TSPathNode = packed record // @size 0x14
    Prev: PSPathNode; // @offset 0x00
    Next: PSPathNode; // @offset 0x04
    Position: TPointF; // @offset 0x08
    Heading: Single; // @offset 0x10
  end;

  TSPath = class(TObject) // @size 0x18
  public
    ActiveHead: PSPathNode; // @offset 0x04
    ActiveTail: PSPathNode; // @offset 0x08
    FreeHead: PSPathNode; // @offset 0x0C
    FreeTail: PSPathNode; // @offset 0x10
    NodeCount: Integer; // @offset 0x14  Active nodes only.

    constructor Create; // @addr 0x4D79B8 @ida "TSPath *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4D7A04 @ida "void __usercall $name(TSPath *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure AllocateNodeUnit; // @addr 0x4D7AD4 @note "Acquires 24 nodes from the shared pool; raises on allocation failure."
    function PopFreeNode: PSPathNode; // @addr 0x4D7C40 @note "Increments NodeCount without linking into the active list. May allocate; payload is uninitialized."
    procedure AppendNode; // @addr 0x4D7E3C @note "New node is ActiveTail; payload is uninitialized."
    procedure AppendWaypoint(Position: TPointF; Heading: Single); // @addr 0x4D7E98 @ida "void __userpurge $name(TSPath *Self@<eax>, TPointF *Position@<edx>, float Heading@<^0>);"
    function InsertNodeBefore(Node: PSPathNode): PSPathNode; // @addr 0x4D7F18 @note "Nil appends. Payload is uninitialized."
    procedure RemoveNode(Node: PSPathNode); // @addr 0x4D7C9C @note "Node must belong to this path; it is recycled."
    procedure RemoveNodeRange(FirstNode, LastNode: PSPathNode); // @addr 0x4D7D50 @note "Inclusive range must be ordered and belong to this path; nodes are recycled."
    procedure Clear; // @addr 0x4D7E14 @note "Recycles active nodes into this path's free list."
    function GetFollowingNode(Node: PSPathNode; SkipCount: Integer): PSPathNode; // @addr 0x4D7F98 @note "Starts at Node.Next; nonpositive SkipCount selects that immediate successor. Node must be non-nil."
    function FindNearestFollowingNode(Node: PSPathNode; Position: TPointF): PSPathNode; // @addr 0x4D7FE4 @ida "TSPathNode *__usercall $name@<eax>(TSPath *Self@<eax>, TSPathNode *Node@<edx>, TPointF *Position@<ecx>);" @note "Excludes Node itself, which must be non-nil. Ties keep the earlier node."
    procedure ResampleBezierRange(FirstNode, LastNode: PSPathNode; SampleCount: Integer); // @addr $4D813C @note "Uses the inclusive nodes as Bezier controls, unwraps headings, inserts samples and recycles the controls."
    function GetLength: Single; // @addr 0x4D8058
    function CountNodeRangeInclusive(FirstNode, LastNode: PSPathNode): Integer; // @addr 0x4D80B4 @note "Returns zero for nil endpoints or when LastNode is not reachable from FirstNode."
  end;

var
  PathNodeHeap: Cardinal = 0; // @addr $87A814
  PathPoolHead: PSPathNode = nil; // @addr $87A818
  PathPoolTail: PSPathNode = nil; // @addr $87A81C
  PathPoolLock: TCriticalSection = nil; // @addr $87A820
  PathGrowthBlockCount: Integer = -1; // @addr $87A824

procedure InitializePathNodePool; // @addr $4D7660
procedure EnsurePathGrowthBlockSlot; // @addr $4D7788
procedure FreePathGrowthBlocks; // @addr $4D77D0
function ReservePathGrowthBlock: Boolean; // @addr $4D7850
function GrowPathNodePool: Boolean; // @addr $4D7878 @note "Native growth increments the free count before allocation and never records the allocated block in PathGrowthBlocks."
procedure FinalizePathNodePool; // @addr $4D7958

implementation

// @unit-initialization $8757E8
// @unit-finalization $4D8528

uses EC_Mem, GR_Main, Math, SysUtils, Windows;

var
  PathInitialBlock: Pointer; // @addr $889220
  PathPoolFreeCount: Integer; // @addr $889224
  PathGrowthBlocks: array of Pointer; // @addr $889228

{ @routine $4D7660 InitializePathNodePool }
procedure InitializePathNodePool;
var Index: Integer; Node, Prev: PSPathNode;
begin
  PathPoolLock := TCriticalSection.Create;
  PathPoolFreeCount := 200000;
  PathNodeHeap := HeapCreate(0, 16, 0);
  PathInitialBlock := HeapAlloc(PathNodeHeap, 0, PathPoolFreeCount * SizeOf(TSPathNode));
  if PathInitialBlock = nil then raise Exception.Create('Error: HeapAlloc');
  ZeroMemory(PathInitialBlock, PathPoolFreeCount * SizeOf(TSPathNode));
  Node := PathInitialBlock; PathPoolHead := Node; Prev := nil;
  for Index := 0 to PathPoolFreeCount - 1 do
  begin
    Node.Prev := Prev;
    Node.Next := AddPointerOffset(Node, SizeOf(TSPathNode));
    Prev := Node; Node := AddPointerOffset(Node, SizeOf(TSPathNode));
  end;
  PathPoolTail := Prev; PathPoolTail.Next := nil;
end;
{ @end $4D7660 }

{ @routine $4D7788 EnsurePathGrowthBlockSlot }
procedure EnsurePathGrowthBlockSlot;
var Count: Integer;
begin
  Count := Length(PathGrowthBlocks);
  if PathGrowthBlockCount >= Count then
  begin
    SetLength(PathGrowthBlocks, Count + 1);
    PathGrowthBlocks[Count] := nil;
  end;
end;
{ @end $4D7788 }

{ @routine $4D77D0 FreePathGrowthBlocks }
procedure FreePathGrowthBlocks;
var Index: Integer;
begin
  for Index := 0 to High(PathGrowthBlocks) do
    if PathGrowthBlocks[Index] <> nil then
    begin
      HeapFree(PathNodeHeap, 0, PathGrowthBlocks[Index]);
      PathGrowthBlocks[Index] := nil;
    end;
  SetLength(PathGrowthBlocks, 0);
  PathGrowthBlockCount := 0;
end;
{ @end $4D77D0 }

{ @routine $4D7850 ReservePathGrowthBlock }
function ReservePathGrowthBlock: Boolean;
begin
  Result := False;
  if PathGrowEnabled then
  begin
    Inc(PathGrowthBlockCount); EnsurePathGrowthBlockSlot; Result := True;
  end;
end;
{ @end $4D7850 }

{ @routine $4D7878 GrowPathNodePool }
function GrowPathNodePool: Boolean;
var Index, Count, ByteCount: Integer; Node, Prev: PSPathNode; Block: Pointer;
begin
  Result := False;
  if PathPoolTail = nil then Exit;
  if not ReservePathGrowthBlock then Exit;
  Count := 100000;
  Inc(PathPoolFreeCount, Count);
  ByteCount := Count * SizeOf(TSPathNode);
  Block := HeapAlloc(PathNodeHeap, HEAP_ZERO_MEMORY, ByteCount);
  if Block = nil then Exit;
  Node := Block; PathPoolTail.Next := Node; Prev := PathPoolTail;
  for Index := 0 to Count - 1 do
  begin
    Node.Prev := Prev;
    Node.Next := AddPointerOffset(Node, SizeOf(TSPathNode));
    Prev := Node; Node := AddPointerOffset(Node, SizeOf(TSPathNode));
  end;
  PathPoolTail := Prev; PathPoolTail.Next := nil;
  Result := True;
end;
{ @end $4D7878 }

{ @routine $4D7958 FinalizePathNodePool }
procedure FinalizePathNodePool;
begin
  FreePathGrowthBlocks;
  if PathInitialBlock <> nil then
  begin
    HeapFree(PathNodeHeap, 0, PathInitialBlock); PathInitialBlock := nil;
  end;
  if PathNodeHeap <> 0 then
  begin
    HeapDestroy(PathNodeHeap); PathNodeHeap := 0;
  end;
  if PathPoolLock <> nil then
  begin
    PathPoolLock.Free; PathPoolLock := nil;
  end;
end;
{ @end $4D7958 }

{ @routine $4D79B8 TSPath_Create }
constructor TSPath.Create;
begin
  inherited Create;
  AllocateNodeUnit;
end;
{ @end $4D79B8 }

{ @routine $4D7A04 TSPath_Destroy }
destructor TSPath.Destroy;
begin
  Clear;
  PathPoolLock.Enter;
  Inc(PathPoolFreeCount, CountNodeRangeInclusive(FreeHead, FreeTail));
  if PathPoolTail <> nil then PathPoolTail.Next := FreeHead;
  FreeHead.Prev := PathPoolTail;
  FreeTail.Next := nil; PathPoolTail := FreeTail;
  if PathPoolHead = nil then PathPoolHead := FreeHead;
  PathPoolLock.Leave;
  FreeHead := nil; FreeTail := nil; NodeCount := 0;
  inherited Destroy;
end;
{ @end $4D7A04 }

{ @routine $4D7AD4 TSPath_AllocateNodeUnit }
procedure TSPath.AllocateNodeUnit;
var Index: Integer; First, Last: PSPathNode; Count: Integer;
begin
  Count := 24;
  PathPoolLock.Enter;
  if Count >= PathPoolFreeCount then
    if not GrowPathNodePool then
    begin
      PathPoolLock.Leave;
      raise Exception.Create('Error: Path.AllocUnit  UnitCount=' + IntToStr(Count));
    end;
  First := PathPoolHead; Last := PathPoolHead;
  for Index := 1 to Count - 1 do Last := Last.Next;
  PathPoolHead := Last.Next; PathPoolHead.Prev := nil;
  Dec(PathPoolFreeCount, Count);
  PathPoolLock.Leave;
  if FreeTail <> nil then FreeTail.Next := First;
  First.Prev := FreeTail; Last.Next := nil; FreeTail := Last;
  if FreeHead = nil then FreeHead := First;
end;
{ @end $4D7AD4 }

{ @routine $4D7C40 TSPath_PopFreeNode }
function TSPath.PopFreeNode: PSPathNode;
var Node: PSPathNode;
begin
  if (FreeHead = FreeTail) or (FreeHead = nil) then AllocateNodeUnit;
  Node := FreeHead; Node.Next.Prev := nil;
  FreeHead := Node.Next; Inc(NodeCount);
  Result := Node;
end;
{ @end $4D7C40 }

{ @routine $4D7C9C TSPath_RemoveNode }
procedure TSPath.RemoveNode(Node: PSPathNode);
begin
  if Node.Prev <> nil then Node.Prev.Next := Node.Next;
  if Node.Next <> nil then Node.Next.Prev := Node.Prev;
  if ActiveTail = Node then ActiveTail := Node.Prev;
  if ActiveHead = Node then ActiveHead := Node.Next;
  if FreeTail <> nil then FreeTail.Next := Node;
  Node.Prev := FreeTail; Node.Next := nil; FreeTail := Node;
  if FreeHead = nil then FreeHead := Node;
  Dec(NodeCount);
end;
{ @end $4D7C9C }

{ @routine $4D7D50 TSPath_RemoveNodeRange }
procedure TSPath.RemoveNodeRange(FirstNode, LastNode: PSPathNode);
begin
  Dec(NodeCount, CountNodeRangeInclusive(FirstNode, LastNode));
  if FirstNode.Prev <> nil then FirstNode.Prev.Next := LastNode.Next;
  if LastNode.Next <> nil then LastNode.Next.Prev := FirstNode.Prev;
  if LastNode = ActiveTail then ActiveTail := FirstNode.Prev;
  if FirstNode = ActiveHead then ActiveHead := LastNode.Next;
  if FreeTail <> nil then FreeTail.Next := FirstNode;
  FirstNode.Prev := FreeTail; LastNode.Next := nil; FreeTail := LastNode;
  if FreeHead = nil then FreeHead := FirstNode;
end;
{ @end $4D7D50 }

{ @routine $4D7E14 TSPath_Clear }
procedure TSPath.Clear;
begin
  if ActiveHead <> nil then RemoveNodeRange(ActiveHead, ActiveTail);
end;
{ @end $4D7E14 }

{ @routine $4D7E3C TSPath_AppendNode }
procedure TSPath.AppendNode;
var Node: PSPathNode;
begin
  Node := PopFreeNode;
  if ActiveTail <> nil then ActiveTail.Next := Node;
  Node.Prev := ActiveTail; Node.Next := nil; ActiveTail := Node;
  if ActiveHead = nil then ActiveHead := Node;
end;
{ @end $4D7E3C }

{ @routine $4D7E98 TSPath_AppendWaypoint }
procedure TSPath.AppendWaypoint(Position: TPointF; Heading: Single);
var Node: PSPathNode;
begin
  Node := PopFreeNode;
  if ActiveTail <> nil then ActiveTail.Next := Node;
  Node.Prev := ActiveTail; Node.Next := nil; ActiveTail := Node;
  if ActiveHead = nil then ActiveHead := Node;
  Node.Position := Position; Node.Heading := Heading;
end;
{ @end $4D7E98 }

{ @routine $4D7F18 TSPath_InsertNodeBefore }
function TSPath.InsertNodeBefore(Node: PSPathNode): PSPathNode;
var NewNode: PSPathNode;
begin
  if Node = nil then
  begin
    AppendNode; Result := ActiveTail; Exit;
  end;
  NewNode := PopFreeNode;
  // Value expressions preserve DCC32's native address/value evaluation order;
  // the + 0 operations themselves emit no instructions.
  PSPathNode(PAnsiChar(NewNode) + 0).Prev := Node.Prev;
  PSPathNode(PAnsiChar(NewNode) + 0).Next := Node;
  if Node.Prev <> nil then Node.Prev.Next := NewNode;
  Node.Prev := NewNode;
  if PSPathNode(PAnsiChar(Node) + 0) = ActiveHead then ActiveHead := PSPathNode(PAnsiChar(NewNode) + 0);
  Result := NewNode;
end;
{ @end $4D7F18 }

{ @routine $4D7F98 TSPath_GetFollowingNode }
function TSPath.GetFollowingNode(Node: PSPathNode; SkipCount: Integer): PSPathNode;
begin
  Node := Node.Next;
  while Node <> nil do
  begin
    if SkipCount <= 0 then begin Result := Node; Exit; end;
    Dec(SkipCount); Node := Node.Next;
  end;
  Result := nil;
end;
{ @end $4D7F98 }

{ @routine $4D7FE4 TSPath_FindNearestFollowingNode }
function TSPath.FindNearestFollowingNode(Node: PSPathNode; Position: TPointF): PSPathNode;
var BestDistance, Distance: Single;
begin
  Result := nil; BestDistance := 1.0e20;
  Node := Node.Next;
  while Node <> nil do
  begin
    Distance := PointDistanceSquared(Node.Position, Position);
    if Distance < BestDistance then begin Result := Node; BestDistance := Distance; end;
    Node := Node.Next;
  end;
end;
{ @end $4D7FE4 }

{ @routine $4D8058 TSPath_GetLength }
function TSPath.GetLength: Single;
var Node: PSPathNode;
begin
  Result := 0;
  if ActiveHead = nil then Exit;
  Node := ActiveHead.Next;
  while Node <> nil do
  begin
    Result := Result + PointDistance(Node.Position, Node.Prev.Position);
    Node := Node.Next;
  end;
end;
{ @end $4D8058 }

{ @routine $4D80B4 TSPath_CountNodeRangeInclusive }
function TSPath.CountNodeRangeInclusive(FirstNode, LastNode: PSPathNode): Integer;
var Count: Integer; Node: PSPathNode;
begin
  if (FirstNode = nil) or (LastNode = nil) then begin Result := 0; Exit; end;
  Count := 1; Node := FirstNode;
  while (Node <> nil) and (Node <> LastNode) do begin Inc(Count); Node := Node.Next; end;
  if Node = nil then Result := 0 else Result := Count;
end;
{ @end $4D80B4 }

{ @routine $4D813C TSPath_ResampleBezierRange }
procedure TSPath.ResampleBezierRange(FirstNode, LastNode: PSPathNode; SampleCount: Integer);
var
  Coefficients: array of Double;
  Count: Integer;
  Node, NewNode, AfterNode: PSPathNode;
  Index, Sample: Integer;
  Heading, Weight, X, Y, Angle, T: Double;
  TPower, InvRemaining, RemainingPower: Extended;
begin
  Count := CountNodeRangeInclusive(FirstNode, LastNode);
  if Count < 2 then Exit;
  if SampleCount < 2 then Exit;
  AfterNode := LastNode.Next;
  SetLength(Coefficients, Count);
  Coefficients[0] := 1; Coefficients[Count - 1] := 1;
  for Index := 1 to (Count - 1) div 2 do
  begin
    Coefficients[Index] := (Count - Index) * Coefficients[Index - 1] / Index;
    Coefficients[Count - 1 - Index] := Coefficients[Index];
  end;
  Heading := FirstNode.Heading;
  Node := LastNode;
  while Node <> FirstNode do
  begin
    Node.Heading := HeadingDifferenceDegrees(Node.Prev.Heading, Node.Heading);
    Node := Node.Prev;
  end;
  FirstNode.Heading := 0;
  Node := FirstNode;
  while Node <> LastNode do
  begin
    Heading := Heading + Node.Heading; Node.Heading := Heading; Node := Node.Next;
  end;
  Heading := Heading + LastNode.Heading; LastNode.Heading := Heading;
  T := 0;
  for Sample := 0 to SampleCount - 1 do
  begin
    X := 0; Y := 0; Angle := 0;
    Node := FirstNode; Index := 0;
    TPower := 1;
    InvRemaining := 1 / (1 - T);
    RemainingPower := Power(1 - T, Count - 1 - Index);
    while Node <> LastNode do
    begin
      Weight := TPower * Coefficients[Index] * RemainingPower;
      X := X + Weight * Node.Position.X;
      Y := Y + Weight * Node.Position.Y;
      Angle := Angle + Weight * Node.Heading;
      Inc(Index);
      TPower := TPower * T;
      RemainingPower := RemainingPower * InvRemaining;
      Node := Node.Next;
    end;
    Weight := TPower * Coefficients[Index];
    X := X + Weight * Node.Position.X;
    Y := Y + Weight * Node.Position.Y;
    Angle := Angle + Weight * Node.Heading;
    NewNode := InsertNodeBefore(AfterNode);
    NewNode.Position.X := X; NewNode.Position.Y := Y;
    NewNode.Heading := WrapHeadingDegrees(Angle);
    T := T + 1 / (SampleCount - 1);
  end;
  if AfterNode = nil then NewNode := ActiveTail else NewNode := AfterNode.Prev;
  NewNode.Position := LastNode.Position; NewNode.Heading := LastNode.Heading;
  RemoveNodeRange(FirstNode, LastNode);
  Coefficients := nil;
end;
{ @end $4D813C }

end.
