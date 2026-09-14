unit Types;
// Unit bracket (inferred): .text 0x00407BFC..0x00407C53; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TPoint = packed record // @size 0x08
    X: Integer; // @offset 0x00
    Y: Integer; // @offset 0x04
  end;
  PPoint = ^TPoint;
  // Flattened RTL layout: TopLeft aliases Left/Top; BottomRight aliases Right/Bottom.
  // Generated builds use the RTL TRect, including those TPoint variant members.
  TRect = packed record // @size 0x10
    Left: Integer; // @offset 0x00
    Top: Integer; // @offset 0x04
    Right: Integer; // @offset 0x08
    Bottom: Integer; // @offset 0x0C
  end;
  PRect = ^TRect;

function MakePoint(X, Y: Integer): TPoint; // @ida "void __usercall $name(int X@<eax>, int Y@<edx>, TPoint *Result@<ecx>);"
function MakeRect(Left, Top, Right, Bottom: Integer): TRect; // @ida "void __userpurge $name(int Left@<eax>, int Top@<edx>, int Right@<ecx>, int Bottom@<^4>, TRect *Result@<^0>);"

procedure SmallPoint; // @nameonly @note "DCC32 MAP Types.SmallPoint. Prototype pending: no unique source declaration."

function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect; // @ida "void __userpurge $name(__int32 ALeft@<eax>, __int32 ATop@<edx>, __int32 AWidth@<ecx>, __int32 AHeight@<^4>, TRect *Result@<^0>);" @note "DCC32 MAP Types.Bounds. Source rtl/sys/Types.pas:545."

implementation
end.
