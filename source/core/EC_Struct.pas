unit EC_Struct;
// Unit bracket (inferred): .text 0x0045EB5C..0x0045EF00; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types;

type
  TPointF = record // @size 0x08
    X: Single; // @offset 0x00
    Y: Single; // @offset 0x04
  end;
  PPointF = ^TPointF;

  TVector3D = record // @size 0x18
    X: Double; // @offset 0x00
    Y: Double; // @offset 0x08
    Z: Double; // @offset 0x10
  end;

  TObjectEx = class // @size 0x04
  public
    constructor Create; // @addr 0x45EE8C @ida "TObjectEx *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x45EED0 @ida "void __usercall $name(TObjectEx *Self@<eax>, __int8 DestroyFlags@<dl>);"
  end;

function MakeVector3D(X, Y, Z: Double): TVector3D; // @addr 0x45EBFC @ida "void __userpurge $name(TVector3D *Result@<eax>, double X@<^16>, double Y@<^8>, double Z@<^0>);"
function MakePointF(X, Y: Single): TPointF; // @addr 0x45EBDC @ida "void __userpurge $name(TPointF *Result@<eax>, float X@<^4>, float Y@<^0>);"
function TruncatePointF(Point: TPointF): TPoint; // @addr 0x45EC34 @ida "void __usercall $name(TPointF *Point@<eax>, TPoint *Result@<edx>);" @note "Truncates each coordinate toward zero."
function RoundPointF(Point: TPointF): TPoint; // @addr $45EC68 @ida "void __usercall $name(TPointF *Point@<eax>, TPoint *Result@<edx>);"
function PointToPointF(Point: TPoint): TPointF; // @addr 0x45EC9C @ida "void __usercall $name(TPoint *Point@<eax>, TPointF *Result@<edx>);"
function HalfPoint(Point: TPoint): TPoint; // @addr 0x45ECC8 @ida "void __usercall $name(TPoint *Point@<eax>, TPoint *Result@<edx>);" @note "Integer division rounds toward zero."
function AddPoints(Left, Right: TPoint): TPoint; // @addr 0x45ED00 @ida "void __usercall $name(TPoint *Left@<eax>, TPoint *Right@<edx>, TPoint *Result@<ecx>);"
function SubtractPoints(Left, Right: TPoint): TPoint; // @addr 0x45ED38 @ida "void __usercall $name(TPoint *Left@<eax>, TPoint *Right@<edx>, TPoint *Result@<ecx>);"
function HalfPointF(Point: TPointF): TPointF; // @addr $45ED70 @ida "void __usercall $name(TPointF *Point@<eax>, TPointF *Result@<edx>);"
function AddPointsF(Left, Right: TPointF): TPointF; // @addr $45EDAC @ida "void __usercall $name(TPointF *Left@<eax>, TPointF *Right@<edx>, TPointF *Result@<ecx>);"
function SubtractPointsF(Left, Right: TPointF): TPointF; // @addr $45EDE4 @ida "void __usercall $name(TPointF *Left@<eax>, TPointF *Right@<edx>, TPointF *Result@<ecx>);"
function IntersectRects(out Intersection: TRect; const First, Second: TRect): Boolean; // @addr 0x45EE1C @ida "bool __usercall $name@<al>(TRect *Intersection@<eax>, const TRect *First@<edx>, const TRect *Second@<ecx>);" @note "Returns false without writing Intersection when the rectangles do not overlap."

var
  StartupCleanupObject: TObject; // @addr $888E04 @note "Freed on both startup shutdown paths; concrete class unresolved."

implementation

{ @routine $45EBDC MakePointF }
function MakePointF(X, Y: Single): TPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;
{ @end $45EBDC }

{ @routine $45EBFC MakeVector3D }
function MakeVector3D(X, Y, Z: Double): TVector3D;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;
{ @end $45EBFC }

{ @routine $45EC34 TruncatePointF }
function TruncatePointF(Point: TPointF): TPoint;
begin
  Result.X := Trunc(Point.X);
  Result.Y := Trunc(Point.Y);
end;
{ @end $45EC34 }

{ @routine $45EC68 RoundPointF }
function RoundPointF(Point: TPointF): TPoint;
begin
  Result.X := Round(Point.X);
  Result.Y := Round(Point.Y);
end;
{ @end $45EC68 }

{ @routine $45EC9C PointToPointF }
function PointToPointF(Point: TPoint): TPointF;
begin
  Result.X := Point.X;
  Result.Y := Point.Y;
end;
{ @end $45EC9C }

{ @routine $45ECC8 HalfPoint }
function HalfPoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X div 2;
  Result.Y := Point.Y div 2;
end;
{ @end $45ECC8 }

{ @routine $45ED00 AddPoints }
function AddPoints(Left, Right: TPoint): TPoint;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;
{ @end $45ED00 }

{ @routine $45ED38 SubtractPoints }
function SubtractPoints(Left, Right: TPoint): TPoint;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;
{ @end $45ED38 }

{ @routine $45ED70 HalfPointF }
function HalfPointF(Point: TPointF): TPointF;
begin
  Result.X := Point.X / 2;
  Result.Y := Point.Y / 2;
end;
{ @end $45ED70 }

{ @routine $45EDAC AddPointsF }
function AddPointsF(Left, Right: TPointF): TPointF;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;
{ @end $45EDAC }

{ @routine $45EDE4 SubtractPointsF }
function SubtractPointsF(Left, Right: TPointF): TPointF;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;
{ @end $45EDE4 }

{ @routine $45EE1C IntersectRects }
function IntersectRects(out Intersection: TRect; const First, Second: TRect): Boolean;
// The native routine is handwritten assembly. Preserve its register saves and
// leave Intersection untouched on failure, including when it aliases an input.
asm
  PUSH ESI
  PUSH EDI
  PUSH ECX
  PUSH EBX
  MOV ESI, EDX
  MOV EDI, ECX
  MOV EBX, EAX
  MOV EAX, [EDI].TRect.Left
  CMP EAX, [ESI].TRect.Right
  JGE @@Empty
  MOV EAX, [EDI].TRect.Right
  CMP EAX, [ESI].TRect.Left
  JLE @@Empty
  MOV EAX, [EDI].TRect.Top
  CMP EAX, [ESI].TRect.Bottom
  JGE @@Empty
  MOV EAX, [EDI].TRect.Bottom
  CMP EAX, [ESI].TRect.Top
  JLE @@Empty
  MOV EAX, [EDI].TRect.Left
  MOV ECX, [ESI].TRect.Left
  CMP EAX, ECX
  JGE @@Left
  MOV EAX, ECX
@@Left:
  MOV [EBX].TRect.Left, EAX
  MOV EAX, [EDI].TRect.Right
  MOV ECX, [ESI].TRect.Right
  CMP EAX, ECX
  JLE @@Right
  MOV EAX, ECX
@@Right:
  MOV [EBX].TRect.Right, EAX
  MOV EAX, [EDI].TRect.Top
  MOV ECX, [ESI].TRect.Top
  CMP EAX, ECX
  JGE @@Top
  MOV EAX, ECX
@@Top:
  MOV [EBX].TRect.Top, EAX
  MOV EAX, [EDI].TRect.Bottom
  MOV ECX, [ESI].TRect.Bottom
  CMP EAX, ECX
  JLE @@Bottom
  MOV EAX, ECX
@@Bottom:
  MOV [EBX].TRect.Bottom, EAX
  XOR EAX, EAX
  INC EAX
  JMP @@Done
@@Empty:
  XOR EAX, EAX
@@Done:
  POP EBX
  POP ECX
  POP EDI
  POP ESI
end;
{ @end $45EE1C }

{ @routine $45EE8C TObjectEx_Create }
constructor TObjectEx.Create;
begin
  inherited Create;
end;
{ @end $45EE8C }

{ @routine $45EED0 TObjectEx_Destroy }
destructor TObjectEx.Destroy;
begin
  inherited Destroy;
end;
{ @end $45EED0 }

end.
