unit Types;

interface

type
  TPoint = packed record // @size 0x08
    X: Integer; // @offset 0x00
    Y: Integer; // @offset 0x04
  end;
  PPoint = ^TPoint;
  // Flattened RTL layout: TopLeft aliases Left/Top; BottomRight aliases Right/Bottom.
  TRect = packed record // @size 0x10
    Left: Integer; // @offset 0x00
    Top: Integer; // @offset 0x04
    Right: Integer; // @offset 0x08
    Bottom: Integer; // @offset 0x0C
  end;
  PRect = ^TRect;

function MakePoint(X, Y: Integer): TPoint;
function MakeRect(Left, Top, Right, Bottom: Integer): TRect;

procedure SmallPoint; // @nameonly

function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;

implementation
end.
