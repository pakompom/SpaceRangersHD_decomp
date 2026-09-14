unit GR_Rect;
// Unit bracket (inferred): .text 0x004C87DC..0x004C900E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, Types;

type
  TRectGR = class(TObject) // @size 0x1C
  public
    Prev: TRectGR; // @offset 0x04
    Next: TRectGR; // @offset 0x08
    Bounds: TRect; // @offset 0x0C

    constructor Create; // @addr 0x4C888C @ida "TRectGR *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4C88D0 @ida "void __usercall $name(TRectGR *Self@<eax>, __int8 DestroyFlags@<dl>);"
  end;

  TArrayRectGR = class(TObjectEx) // @size 0x0C
  public
    FirstRect: TRectGR; // @offset 0x04
    LastRect: TRectGR; // @offset 0x08

    constructor Create; // @addr 0x4C8904 @ida "TArrayRectGR *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4C8948 @ida "void __usercall $name(TArrayRectGR *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr 0x4C8984
    function AllocateRectNode: TRectGR; // @addr 0x4C89D0
    procedure RemoveRectNode(RectNode: TRectGR); // @addr 0x4C8A3C
    procedure AddRect(Rect: TRect); // @addr 0x4C8AB4 @ida "void __usercall $name(TArrayRectGR *Self@<eax>, TRect *Rect@<edx>);" @note "Maintains nonoverlapping coverage."
    procedure InsertRectFragment(Left, Top, Right, Bottom: Integer); // @addr 0x4C8BA8
    procedure AddScreenClippedRect(Rect: TRect; UnusedPoint1, UnusedPoint2: TPoint); // @addr 0x4C8FC4 @ida "void __userpurge $name(TArrayRectGR *Self@<eax>, TRect *Rect@<edx>, TPoint *UnusedPoint1@<ecx>, TPoint *UnusedPoint2@<^0>);"
  end;

implementation

uses GR_Main;

{ @routine $4C888C TRectGR_Create }
constructor TRectGR.Create;
begin
  inherited Create;
end;
{ @end $4C888C }

{ @routine $4C88D0 TRectGR_Destroy }
destructor TRectGR.Destroy;
begin
  inherited Destroy;
end;
{ @end $4C88D0 }

{ @routine $4C8904 TArrayRectGR_Create }
constructor TArrayRectGR.Create;
begin
  inherited Create;
end;
{ @end $4C8904 }

{ @routine $4C8948 TArrayRectGR_Destroy }
destructor TArrayRectGR.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $4C8948 }

{ @routine $4C8984 TArrayRectGR_Clear }
procedure TArrayRectGR.Clear;
var
  Node, Removed: TRectGR;
begin
  Node := FirstRect;
  while Node <> nil do
  begin
    Removed := Node;
    Node := Node.Next;
    Removed.Free;
  end;
  FirstRect := nil;
  LastRect := nil;
end;
{ @end $4C8984 }

{ @routine $4C89D0 TArrayRectGR_AllocateRectNode }
function TArrayRectGR.AllocateRectNode: TRectGR;
var
  Node: TRectGR;
begin
  Node := TRectGR.Create;
  if LastRect <> nil then
    LastRect.Next := Node;
  Node.Prev := LastRect;
  Node.Next := nil;
  LastRect := Node;
  if FirstRect = nil then
    FirstRect := Node;
  Result := Node;
end;
{ @end $4C89D0 }

{ @routine $4C8A3C TArrayRectGR_RemoveRectNode }
procedure TArrayRectGR.RemoveRectNode(RectNode: TRectGR);
begin
  if RectNode.Prev <> nil then
    RectNode.Prev.Next := RectNode.Next;
  if RectNode.Next <> nil then
    RectNode.Next.Prev := RectNode.Prev;
  if LastRect = RectNode then
    LastRect := RectNode.Prev;
  if FirstRect = RectNode then
    FirstRect := RectNode.Next;
  RectNode.Free;
end;
{ @end $4C8A3C }

{ @routine $4C8AB4 TArrayRectGR_AddRect }
procedure TArrayRectGR.AddRect(Rect: TRect);
var
  Node, Removed: TRectGR;
begin
  Node := LastRect;
  while Node <> nil do
  begin
    with Node.Bounds do
      if (Rect.Left >= Left) and (Rect.Right <= Right) and
         (Rect.Top >= Top) and (Rect.Bottom <= Bottom) then
        Exit;
    Node := Node.Prev;
  end;
  Node := LastRect;
  while Node <> nil do
  begin
    with Node.Bounds do
      if (Left >= Rect.Left) and (Right <= Rect.Right) and
         (Top >= Rect.Top) and (Bottom <= Rect.Bottom) then
      begin
        Removed := Node;
        Node := Node.Prev;
        RemoveRectNode(Removed);
      end
      else
        Node := Node.Prev;
  end;
  InsertRectFragment(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
end;
{ @end $4C8AB4 }

{ @routine $4C8BA8 TArrayRectGR_InsertRectFragment }
procedure TArrayRectGR.InsertRectFragment(Left, Top, Right, Bottom: Integer);
var
  Node: TRectGR;
  OutsideEdges: Integer;
  ExistingLeft, ExistingTop, ExistingRight, ExistingBottom: Integer;
begin
  Node := LastRect;
  while Node <> nil do
  begin
    ExistingLeft := Node.Bounds.Left;
    ExistingRight := Node.Bounds.Right;
    ExistingTop := Node.Bounds.Top;
    ExistingBottom := Node.Bounds.Bottom;
    if (Left >= ExistingLeft) and (Right <= ExistingRight) and
       (Top >= ExistingTop) and (Bottom <= ExistingBottom) then
      Exit;
    if (Left < ExistingRight) and (Right > ExistingLeft) and
       (Top < ExistingBottom) and (Bottom > ExistingTop) then
      Break;
    Node := Node.Prev;
  end;
  if Node = nil then
  begin
    Node := AllocateRectNode;
    Node.Bounds.Left := Left;
    Node.Bounds.Top := Top;
    Node.Bounds.Right := Right;
    Node.Bounds.Bottom := Bottom;
    Exit;
  end;
  OutsideEdges := 0;
  if Left < ExistingLeft then OutsideEdges := OutsideEdges or 1;
  if Right > ExistingRight then OutsideEdges := OutsideEdges or 8;
  if Top < ExistingTop then OutsideEdges := OutsideEdges or 16;
  if Bottom > ExistingBottom then OutsideEdges := OutsideEdges or 128;
  if (OutsideEdges = 1) then
  begin
    InsertRectFragment(Left, Top, ExistingLeft, Bottom);
  end
  else if (OutsideEdges = 8) then
  begin
    InsertRectFragment(ExistingRight, Top, Right, Bottom);
  end
  else if (OutsideEdges = 16) then
  begin
    InsertRectFragment(Left, Top, Right, ExistingTop);
  end
  else if (OutsideEdges = 128) then
  begin
    InsertRectFragment(Left, ExistingBottom, Right, Bottom);
  end
  else if (OutsideEdges = 9) then
  begin
    InsertRectFragment(Left, Top, ExistingLeft, Bottom);
    InsertRectFragment(ExistingRight, Top, Right, Bottom);
  end
  else if (OutsideEdges = 144) then
  begin
    InsertRectFragment(Left, Top, Right, ExistingTop);
    InsertRectFragment(Left, ExistingBottom, Right, Bottom);
  end
  else if (OutsideEdges = 17) then
  begin
    InsertRectFragment(Left, Top, Right, ExistingTop);
    InsertRectFragment(Left, ExistingTop, ExistingLeft, Bottom);
  end
  else if (OutsideEdges = 24) then
  begin
    InsertRectFragment(Left, Top, Right, ExistingTop);
    InsertRectFragment(ExistingRight, ExistingTop, Right, Bottom);
  end
  else if (OutsideEdges = 129) then
  begin
    InsertRectFragment(Left, ExistingBottom, Right, Bottom);
    InsertRectFragment(Left, Top, ExistingLeft, ExistingBottom);
  end
  else if (OutsideEdges = 136) then
  begin
    InsertRectFragment(Left, ExistingBottom, Right, Bottom);
    InsertRectFragment(ExistingRight, Top, Right, ExistingBottom);
  end
  else if (OutsideEdges = 145) then
  begin
    InsertRectFragment(Left, Top, Right, ExistingTop);
    InsertRectFragment(Left, ExistingTop, ExistingLeft, ExistingBottom);
    InsertRectFragment(Left, ExistingBottom, Right, Bottom);
  end
  else if (OutsideEdges = 152) then
  begin
    InsertRectFragment(Left, Top, Right, ExistingTop);
    InsertRectFragment(ExistingRight, ExistingTop, Right, ExistingBottom);
    InsertRectFragment(Left, ExistingBottom, Right, Bottom);
  end
  else if (OutsideEdges = 25) then
  begin
    InsertRectFragment(Left, Top, Right, ExistingTop);
    InsertRectFragment(Left, ExistingTop, ExistingLeft, Bottom);
    InsertRectFragment(ExistingRight, ExistingTop, Right, Bottom);
  end
  else if (OutsideEdges = 137) then
  begin
    InsertRectFragment(Left, ExistingBottom, Right, Bottom);
    InsertRectFragment(Left, Top, ExistingLeft, ExistingBottom);
    InsertRectFragment(ExistingRight, Top, Right, ExistingBottom);
  end;
end;
{ @end $4C8BA8 }

{ @routine $4C8FC4 TArrayRectGR_AddScreenClippedRect }
procedure TArrayRectGR.AddScreenClippedRect(Rect: TRect; UnusedPoint1, UnusedPoint2: TPoint);
var
  Clipped: TRect;
begin
  if IntersectRects(Clipped, Rect, GameScreenRect) then
    AddRect(Clipped);
end;
{ @end $4C8FC4 }

end.
