unit Math;

interface

function IntPower(Base: Extended; Exponent: Integer): Extended;
function ArcCosExtended(Value: Extended): Extended;
function ArcCosDouble(Value: Double): Double; // @addr 0x0041DCE8
function ArcSinExtended(Value: Extended): Extended;
function ArcTan2(Y, X: Extended): Extended;
function Ceil(Value: Extended): Integer;
function Floor(Value: Extended): Integer;
function Power(Base, Exponent: Extended): Extended;
function SignInteger(Value: Integer): ShortInt;
function SignDouble(Value: Double): ShortInt; // @note "Both signed zeros return zero; other values use the sign bit, including NaNs."

procedure RoundTo; // @nameonly

function IsNan(Value: Single): Boolean;
function IsNanDouble(Value: Double): Boolean;

function PowerDouble(Base, Exponent: Double): Double;

function PowerSingle(Base, Exponent: Single): Single;

implementation
end.
