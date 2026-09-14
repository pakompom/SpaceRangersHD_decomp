unit DateUtils;
// Unit bracket (inferred): .text 0x004B8730..0x004B8785; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses System;

// Shipped Delphi 2007 source and native instructions agree on the epoch,
// scale, stack arguments, and return registers.
function DateTimeToUnix(const AValue: TDateTime): Int64; // @ida "__int64 __userpurge $name@<edx:eax>(double AValue@<^0>);" @note "Round((AValue - 25569) * 86400), using the current x87 rounding mode."
function UnixToDateTime(const AValue: Int64): TDateTime; // @ida "double __userpurge $name@<st0>(__int64 AValue@<^0>);"

implementation
end.
