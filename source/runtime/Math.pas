unit Math;
// Unit bracket (inferred): .text 0x0041DC54..0x0041DFF6; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

function IntPower(Base: Extended; Exponent: Integer): Extended; // @ida "double __userpurge $name@<st0>(_TBYTE Base@<^0>, int Exponent@<eax>);"
function ArcCosExtended(Value: Extended): Extended; // @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function ArcCosDouble(Value: Double): Double; // @addr 0x41DCE8 @ida "double __userpurge $name@<st0>(double Value@<^0>);"
function ArcSinExtended(Value: Extended): Extended; // @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function ArcTan2(Y, X: Extended): Extended; // @ida "double __userpurge $name@<st0>(_TBYTE Y@<^12>, _TBYTE X@<^0>);"
function Ceil(Value: Extended): Integer; // @ida "int __userpurge $name@<eax>(_TBYTE Value@<^0>);"
function Floor(Value: Extended): Integer; // @ida "int __userpurge $name@<eax>(_TBYTE Value@<^0>);"
function Power(Base, Exponent: Extended): Extended; // @ida "double __userpurge $name@<st0>(_TBYTE Base@<^12>, _TBYTE Exponent@<^0>);"
function SignInteger(Value: Integer): ShortInt;
function SignDouble(Value: Double): ShortInt; // @ida "signed __int8 __userpurge $name@<al>(double Value@<^0>);" @note "Both signed zeros return zero; other values use the sign bit, including NaNs."

procedure RoundTo; // @nameonly @note "DCC32 MAP Math.RoundTo. Source rtl/common/Math.pas:467. Prototype pending: unsupported source type TRoundToRange: -37..37."

function IsNan(Value: Single): Boolean; // @ida "bool __userpurge $name@<al>(float Value@<^0>);"
function IsNanDouble(Value: Double): Boolean; // @ida "bool __userpurge $name@<al>(double Value@<^0>);"

function PowerDouble(Base, Exponent: Double): Double; // @ida "double __userpurge $name@<st0>(double Base@<^8>, double Exponent@<^0>);"

function PowerSingle(Base, Exponent: Single): Single; // @ida "float __userpurge $name@<st0>(float Base@<^4>, float Exponent@<^0>);"

implementation
end.
