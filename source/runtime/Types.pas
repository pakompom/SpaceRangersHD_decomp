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

function MakePoint(X, Y: Integer): TPoint;
function MakeRect(Left, Top, Right, Bottom: Integer): TRect;

procedure SmallPoint; // @nameonly @note "DCC32 MAP Types.SmallPoint. Prototype pending: no unique source declaration."

function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect; // @note "DCC32 MAP Types.Bounds. Source rtl/sys/Types.pas:545."

implementation
end.
