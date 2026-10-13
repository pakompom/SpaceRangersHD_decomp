unit EC_Struct;

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
    constructor Create; // @addr 0x0045EDDC
    destructor Destroy; override; // @addr 0x0045EE14
  end;

function MakeVector3D(X, Y, Z: Double): TVector3D; // @addr 0x0045EBAC @ida "void __userpurge $name(TVector3D *Result@<eax>, double X@<^16>, double Y@<^8>, double Z@<^0>);"
function MakePointF(X, Y: Single): TPointF; // @addr 0x0045EB98 @ida "void __userpurge $name(TPointF *Result@<eax>, float X@<^4>, float Y@<^0>);"
function TruncatePointF(Point: TPointF): TPoint; // @addr 0x0045EBD8 @note "Truncates each coordinate toward zero."
function RoundPointF(Point: TPointF): TPoint; // @addr $45EC04
function PointToPointF(Point: TPoint): TPointF; // @addr 0x0045EC30
function HalfPoint(Point: TPoint): TPoint; // @addr 0x0045EC50 @note "Integer division rounds toward zero."
function AddPoints(Left, Right: TPoint): TPoint; // @addr 0x0045EC7C
function SubtractPoints(Left, Right: TPoint): TPoint; // @addr 0x0045ECAC
function HalfPointF(Point: TPointF): TPointF; // @addr $45ECDC
function AddPointsF(Left, Right: TPointF): TPointF; // @addr $45ED0C
function SubtractPointsF(Left, Right: TPointF): TPointF; // @addr $45ED3C
function SquaredDistanceToPoint(const Point: TPoint; X, Y: Integer): Integer; inline;
function IntersectRects(out Intersection: TRect; const First, Second: TRect): Boolean; // @addr 0x0045ED6C @ida "bool __usercall $name@<al>(TRect *Intersection@<eax>, const TRect *First@<edx>, const TRect *Second@<ecx>);" @note "Returns false without writing Intersection when the rectangles do not overlap."

var
  StartupCleanupObject: TObject; // @addr $819E04 @note "Freed on both startup shutdown paths; concrete class unresolved."

implementation

function SquaredDistanceToPoint(const Point: TPoint; X, Y: Integer): Integer; inline;
begin
  Result := Sqr(Point.X - X) + Sqr(Point.Y - Y);
end;

{ @routine $45EB98 MakePointF }
function MakePointF(X, Y: Single): TPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;
{ @end $45EB98 }

{ @routine $45EBAC MakeVector3D }
function MakeVector3D(X, Y, Z: Double): TVector3D;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;
{ @end $45EBAC }

{ @routine $45EBD8 TruncatePointF }
function TruncatePointF(Point: TPointF): TPoint;
begin
  Result.X := Trunc(Point.X);
  Result.Y := Trunc(Point.Y);
end;
{ @end $45EBD8 }

{ @routine $45EC04 RoundPointF }
function RoundPointF(Point: TPointF): TPoint;
begin
  Result.X := Round(Point.X);
  Result.Y := Round(Point.Y);
end;
{ @end $45EC04 }

{ @routine $45EC30 PointToPointF }
function PointToPointF(Point: TPoint): TPointF;
begin
  Result.X := Point.X;
  Result.Y := Point.Y;
end;
{ @end $45EC30 }

{ @routine $45EC50 HalfPoint }
function HalfPoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X div 2;
  Result.Y := Point.Y div 2;
end;
{ @end $45EC50 }

{ @routine $45EC7C AddPoints }
function AddPoints(Left, Right: TPoint): TPoint;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;
{ @end $45EC7C }

{ @routine $45ECAC SubtractPoints }
function SubtractPoints(Left, Right: TPoint): TPoint;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;
{ @end $45ECAC }

{ @routine $45ECDC HalfPointF }
function HalfPointF(Point: TPointF): TPointF;
begin
  Result.X := Point.X / 2;
  Result.Y := Point.Y / 2;
end;
{ @end $45ECDC }

{ @routine $45ED0C AddPointsF }
function AddPointsF(Left, Right: TPointF): TPointF;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;
{ @end $45ED0C }

{ @routine $45ED3C SubtractPointsF }
function SubtractPointsF(Left, Right: TPointF): TPointF;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;
{ @end $45ED3C }

{ @routine $45ED6C IntersectRects }
function IntersectRects(out Intersection: TRect; const First, Second: TRect): Boolean;
// Leave Intersection untouched on failure, including when it aliases an input.
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
{ @end $45ED6C }

{ @routine $45EDDC TObjectEx_Create }
constructor TObjectEx.Create;
begin
  inherited Create;
end;
{ @end $45EDDC }

{ @routine $45EE14 TObjectEx_Destroy }
destructor TObjectEx.Destroy;
begin
  inherited Destroy;
end;
{ @end $45EE14 }

end.
