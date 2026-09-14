program SignatureProbe;
{ Compile-only ABI distinguishability fixture. The root retains every routine;
  it contains a nil method call and must not be executed. }
{$APPTYPE CONSOLE}
{$O-}{$R-}{$Q-}
type
  TByteEnum = (beZero, beOne);
  TRec = packed record A, B: Integer end;
  TProbe = class
    Value: Integer;
    procedure SetValue(A: Integer);
  end;
var Sink: Integer; PtrSink: Pointer;
procedure Empty0; begin end;
procedure Empty1(A: Integer); begin end;
procedure Empty3(A: Integer; B: Byte; C: Word); begin end;
procedure Empty4(A, B, C, D: Integer); begin end;
procedure SignedValue(A: Integer); begin Sink := A end;
procedure UnsignedValue(A: Cardinal); begin Sink := A end;
procedure ConstValue(const A: Integer); begin Sink := A end;
procedure VarValue(var A: Integer); begin A := 7 end;
procedure OutValue(out A: Integer); begin A := 7 end;
procedure PointerValue(A: PInteger); begin A^ := 7 end;
procedure ByteValue(A: Byte); begin Sink := A end;
procedure BoolValue(A: Boolean); begin Sink := Ord(A) end;
procedure EnumValue(A: TByteEnum); begin Sink := Ord(A) end;
procedure TProbe.SetValue(A: Integer); begin Value := A end;
procedure ExplicitSelf(Self: TProbe; A: Integer); begin Self.Value := A end;
function IntegerResult(A: Integer): Integer; begin Result := A end;
function CardinalResult(A: Cardinal): Cardinal; begin Result := A end;
function SingleResult(A: Single): Single; begin Result := A end;
function DoubleResult(A: Double): Double; begin Result := A end;
function ExtendedResult(A: Extended): Extended; begin Result := A end;
function Int64Result(A: Int64): Int64; begin Result := A end;
function StringResult(A: Integer): AnsiString; begin Result := '' end;
procedure MixedFirst(var Seed: Cardinal; A, B: Double); begin Sink := Seed + Round(A+B) end;
procedure MixedLast(A, B: Double; var Seed: Cardinal); begin Sink := Seed + Round(A+B) end;
procedure RecordValue(A: TRec); begin Sink := A.A end;
procedure RecordConst(const A: TRec); begin Sink := A.A end;
procedure OpenArray(const A: array of Integer); begin Sink := Length(A) end;
begin
  PtrSink:=@Empty0; PtrSink:=@Empty1; PtrSink:=@Empty3; PtrSink:=@Empty4;
  PtrSink:=@SignedValue; PtrSink:=@UnsignedValue; PtrSink:=@ConstValue;
  PtrSink:=@VarValue; PtrSink:=@OutValue; PtrSink:=@PointerValue;
  PtrSink:=@ByteValue; PtrSink:=@BoolValue; PtrSink:=@EnumValue;
  TProbe(nil).SetValue(0); PtrSink:=@ExplicitSelf;
  PtrSink:=@IntegerResult; PtrSink:=@CardinalResult;
  PtrSink:=@SingleResult; PtrSink:=@DoubleResult; PtrSink:=@ExtendedResult;
  PtrSink:=@Int64Result; PtrSink:=@StringResult;
  PtrSink:=@MixedFirst; PtrSink:=@MixedLast;
  PtrSink:=@RecordValue; PtrSink:=@RecordConst; PtrSink:=@OpenArray;
end.
