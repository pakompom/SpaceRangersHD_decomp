unit DateUtils;

interface

uses System;

function DateTimeToUnix(const AValue: TDateTime): Int64; // @note "Round((AValue - 25569) * 86400), using the current x87 rounding mode."
function UnixToDateTime(const AValue: Int64): TDateTime;

implementation
end.
