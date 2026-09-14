unit ExceptionInfo;
// Hex helpers in the inferred ExceptionInfo region. Wider unit ownership remains inferred.

interface

uses SysUtils;

type
  TRaiseExceptionCallback = procedure(Code, Flags, ArgumentCount: Cardinal; Arguments: Pointer); stdcall;


function ExceptionLogTimestamp: AnsiString; // @addr $602800 @ida "void __usercall $name(char **Result@<eax>);"
procedure ReportUnhandledException(E: Exception; var Handled: Boolean); // @addr $602884
procedure RaiseExceptionWithLogging(Code, Flags, ArgumentCount: Cardinal; Arguments: Pointer); stdcall; // @addr $602B24

function HexDigit(Value: Byte): WideChar; // @addr $602794
function ByteToHexText(Value: Byte): WideString; // @addr $6027B8 @ida "void __usercall $name(unsigned __int8 Value@<al>, unsigned __int16 **Result@<edx>);"

const
  ExportHexDigits: array[0..15] of WideChar = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'); // @addr $87B6C0
var
  ReportingException: Boolean = False; // @addr $87B6E0
  PreviousRaiseException: TRaiseExceptionCallback = nil; // @addr $87B6E4

implementation

// @unit-initialization $8758BC
// @unit-finalization $602BFC

uses Windows, GR_Main, BlockParException, BreakMessageGIException;

{ @routine $602794 HexDigit }
function HexDigit(Value: Byte): WideChar;
begin
  Result := ExportHexDigits[Value and $F];
end;
{ @end $602794 }

{ @routine $6027B8 ByteToHexText }
function ByteToHexText(Value: Byte): WideString;
begin
  SetLength(Result, 2);
  Result[1] := HexDigit(Value shr 4);
  Result[2] := HexDigit(Value shr 0);
end;
{ @end $6027B8 }

{ @routine $602800 ExceptionLogTimestamp }
function ExceptionLogTimestamp: AnsiString;
var Time: TDateTime; Text: AnsiString;
begin
  Time := Now;
  DateTimeToString(Text, 'yyyy.mm.dd hh.nn.ss.zzz', Time);
  Result := Text;
end;
{ @end $602800 }

{ @routine $602884 ReportUnhandledException }
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
{ @end $602884 }

{ @routine $602B24 RaiseExceptionWithLogging }
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
{ @end $602B24 }

// Native initializer $8758BC saves and replaces the RTL raise hook.
initialization
  PreviousRaiseException := TRaiseExceptionCallback(System.RaiseExceptionProc);
  System.RaiseExceptionProc := @RaiseExceptionWithLogging;
end.
