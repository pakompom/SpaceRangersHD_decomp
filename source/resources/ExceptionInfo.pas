unit ExceptionInfo;
// Hex helpers in the inferred ExceptionInfo region. Wider unit ownership remains inferred.

interface

uses SysUtils;

type
  TRaiseExceptionCallback = procedure(Code, Flags, ArgumentCount: Cardinal; Arguments: Pointer); stdcall;


function ExceptionLogTimestamp: AnsiString; // @addr $57ABC0
procedure ReportUnhandledException(E: Exception; var Handled: Boolean); // @addr $57AC44
procedure RaiseExceptionWithLogging(Code, Flags, ArgumentCount: Cardinal; Arguments: Pointer); stdcall; // @addr $57AEE4

function HexDigit(Value: Byte): WideChar; // @addr $57AB54
function ByteToHexText(Value: Byte): WideString; // @addr $57AB78

const
  ExportHexDigits: array[0..15] of WideChar = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'); // @addr $87B024
var
  ReportingException: Boolean = False; // @addr $87B044
  PreviousRaiseException: TRaiseExceptionCallback = nil; // @addr $87B048

implementation

// @unit-initialization $877884
// @unit-finalization $57AFBC

uses Windows, GR_Main, BlockParException, BreakMessageGIException;

{ @routine $57AB54 HexDigit }
function HexDigit(Value: Byte): WideChar;
begin
  Result := ExportHexDigits[Value and $F];
end;
{ @end $57AB54 }

{ @routine $57AB78 ByteToHexText }
function ByteToHexText(Value: Byte): WideString;
begin
  SetLength(Result, 2);
  Result[1] := HexDigit(Value shr 4);
  Result[2] := HexDigit(Value shr 0);
end;
{ @end $57AB78 }

{ @routine $57ABC0 ExceptionLogTimestamp }
function ExceptionLogTimestamp: AnsiString;
var Time: TDateTime; Text: AnsiString;
begin
  Time := Now;
  DateTimeToString(Text, 'yyyy.mm.dd hh.nn.ss.zzz', Time);
  Result := Text;
end;
{ @end $57ABC0 }

{ @routine $57AC44 ReportUnhandledException }
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
      CreateDir(AnsiString(GetGameUserDirectory + 'Errors'));
      TargetName := GetGameUserDirectory + 'Errors\' + WideString(ExceptionLogTimestamp) + '.log';
      SourceName := GetGameUserDirectory + '########.log';
      CopyFileW(PWideChar(SourceName), PWideChar(TargetName), False);
    end;
  end;
end;
{ @end $57AC44 }

{ @routine $57AEE4 RaiseExceptionWithLogging }
procedure RaiseExceptionWithLogging(Code, Flags, ArgumentCount: Cardinal; Arguments: Pointer); stdcall;
var Handled: Boolean;
begin
  if Assigned(PreviousRaiseException) then begin
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
end;
{ @end $57AEE4 }

// Native initializer $877884 saves and replaces the RTL raise hook.
initialization
  PreviousRaiseException := TRaiseExceptionCallback(System.RaiseExceptionProc);
  System.RaiseExceptionProc := @RaiseExceptionWithLogging;
end.
