unit ExceptionInfo;
// Hex helpers in the inferred ExceptionInfo region. Wider unit ownership remains inferred.

interface

uses SysUtils;

type
  TRaiseExceptionCallback = procedure(Code, Flags, ArgumentCount: Cardinal; Arguments: Pointer); stdcall;


function ExceptionLogTimestamp: AnsiString; // @addr $5E74F0
procedure ReportUnhandledException(E: Exception; var Handled: Boolean); // @addr $5E7574
procedure RaiseExceptionWithLogging(Code, Flags, ArgumentCount: Cardinal; Arguments: Pointer); stdcall; // @addr $5E7804

function HexDigit(Value: Byte): WideChar; // @addr $5E74A4
function ByteToHexText(Value: Byte): WideString; // @addr $5E74B4

const
  ExportHexDigits: array[0..15] of WideChar = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'); // @addr $80F620
var
  ReportingException: Boolean = False; // @addr $80F640
  PreviousRaiseException: TRaiseExceptionCallback = nil; // @addr $80F644

implementation

// @unit-initialization $8068D8
// @unit-finalization $5E78C4

uses Windows, GR_Main, BlockParException, BreakMessageGIException;

{ @routine $5E74A4 HexDigit }
function HexDigit(Value: Byte): WideChar;
begin
  Result := ExportHexDigits[Value and $F];
end;
{ @end $5E74A4 }

function HexDigitAt(Value: Byte; Index: Integer): WideChar; inline;
begin
  Result := HexDigit(Value shr (Index * 4));
end;

{ @routine $5E74B4 ByteToHexText }
function ByteToHexText(Value: Byte): WideString;
begin
  SetLength(Result, 2);
  Result[1] := HexDigitAt(Value, 1);
  Result[2] := HexDigitAt(Value, 0);
end;
{ @end $5E74B4 }

{ @routine $5E74F0 ExceptionLogTimestamp }
function ExceptionLogTimestamp: AnsiString;
var Time: TDateTime; Text: AnsiString;
begin
  Time := Now;
  DateTimeToString(Text, 'yyyy.mm.dd hh.nn.ss.zzz', Time);
  Result := Text;
end;
{ @end $5E74F0 }

{ @routine $5E7574 ReportUnhandledException }
procedure ReportUnhandledException(E: Exception; var Handled: Boolean);
var TargetName, SourceName: WideString;
begin
  if E is EBreakMessageGI then Handled := False
  else begin
    if E is EBlockPar then
      if not (E as EBlockPar).IsReportable then Handled := False;
    AppendLogLineThreadSafe('Exception ' + E.ClassName + ' with message ' + E.Message);
    Handled := False;
    if SuppressExceptionLogCopy then SuppressExceptionLogCopy := False
    else begin
      CreateDir(GetGameUserDirectory + 'Errors');
      TargetName := GetGameUserDirectory + 'Errors\' + ExceptionLogTimestamp + '.log';
      SourceName := GetGameUserDirectory + '########.log';
      CopyFileW(PWideChar(SourceName), PWideChar(TargetName), False);
    end;
  end;
end;
{ @end $5E7574 }

{ @routine $5E7804 RaiseExceptionWithLogging }
procedure RaiseExceptionWithLogging(Code, Flags, ArgumentCount: Cardinal; Arguments: Pointer); stdcall;
var Handled: Boolean;
begin
  if not Assigned(PreviousRaiseException) then Exit;
    if ReportingException then PreviousRaiseException(Code, Flags, ArgumentCount, Arguments)
    else begin
      ReportingException := True;
      try
        try
          PreviousRaiseException(Code, Flags, ArgumentCount, Arguments);
        except
          on E: Exception do begin
            Handled := False;
            ReportUnhandledException(E, Handled);
            if not Handled then raise;
          end;
        end;
      finally
        ReportingException := False;
      end;
    end;
end;
{ @end $5E7804 }

initialization
  PreviousRaiseException := TRaiseExceptionCallback(System.RaiseExceptionProc);
  System.RaiseExceptionProc := @RaiseExceptionWithLogging;
end.
