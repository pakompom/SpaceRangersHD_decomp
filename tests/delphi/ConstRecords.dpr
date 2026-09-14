library ConstRecords;
{$O-}
type
  TOne = packed record Value: Byte; end;
  TTwo = packed record Value: Word; end;
  TFour = packed record Value: Cardinal; end;
  TEight = packed record Value: Cardinal; Other: Cardinal; end;
  TArr = array[0..0] of Byte;
function One(const R: TOne): Byte; begin Result := R.Value; end;
function Two(const R: TTwo): Word; begin Result := R.Value; end;
function Four(const R: TFour): Cardinal; begin Result := R.Value; end;
function Eight(const R: TEight): Cardinal; begin Result := R.Value; end;
function Arr(const R: TArr): Byte; begin Result := R[0]; end;
function FourStd(const R: TFour): Cardinal; stdcall; begin Result := R.Value; end;
function EightStd(const R: TEight): Cardinal; stdcall; begin Result := R.Value; end;
exports FourStd, EightStd, One, Two, Four, Eight, Arr;
begin end.
