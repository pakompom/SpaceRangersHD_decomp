unit SysUtils;

interface

uses System, Windows;

type
  Exception = class(TObject) // @size 0x0C
  public
    Message: AnsiString; // @offset 0x04

    constructor Create(Message: AnsiString);
  public
    procedure CreateFmt; // @nameonly
    procedure CreateRes; // @nameonly
    procedure CreateResFmt; // @nameonly
  end;

  EAbort = class(Exception) // @size $0C
  end;

  EExternal = class(Exception) // @size 0x10
  end;
  EIntError = class(EExternal) // @size 0x10
  end;
  EDivByZero = class(EIntError) // @size 0x10
  end;
  EMathError = class(EExternal) // @size 0x10
  end;
  EInvalidOp = class(EMathError) // @size 0x10
  end;
  EZeroDivide = class(EMathError) // @size 0x10
  end;
  EOverflow = class(EMathError) // @size 0x10
  end;
  EConvertError = class(Exception) // @size 0x0C
  end;

function IntToStr(Value: Integer): AnsiString;
function Int64ToStr(Value: Int64): AnsiString; // @ida "void __userpurge $name(char **Result@<eax>, __int64 Value@<^0>);"
function IntToHex64(Value: Int64; Digits: Integer): AnsiString; // @addr $40A1C8 @ida "void __userpurge $name(int Digits@<eax>, char **Result@<edx>, __int64 Value@<^0>);"
function IntToHex(Value, Digits: Integer): AnsiString;
function StrToInt(Value: AnsiString): Integer; // @note "Parses signed decimal or hexadecimal text; raises a conversion exception on invalid input."
procedure Abort; // @addr $40DB9C @note "Raises EAbort with SOperationAborted at the caller's return address."
function RtlTrimWideString(const Text: WideString): WideString; // @addr $409EF0
function TrimRightWideString(Text: WideString): WideString; // @addr 0x00409F40 @note "Trims trailing UTF-16 code units <= #32."
function CompareMem(Buffer1, Buffer2: Pointer; ByteCount: Integer): Boolean; // @note "Zero length returns True."

type
  TSearchRec = record // @size $160
    Time: Integer; // @offset $00
    Size: Int64; // @offset $08
    Attr: Integer; // @offset $10
    Name: AnsiString; // @offset $14
    ExcludeAttr: Integer; // @offset $18
    FindHandle: Cardinal; // @offset $1C
    FindData: TWin32FindDataA; // @offset $20
  end;

  TFloatRec = record;

  TFloatValue = (fvExtended, fvCurrency); // @size 0x1

  TTimeStamp = record;

  TDateOrder = (doMDY, doDMY, doYMD); // @size 0x1

  EInOutError = class(Exception) // @size 0x10
  end;

  TMbcsByteType = (mbSingleByte, mbLeadByte, mbTrailByte); // @size 0x1

  TReplaceFlagsElement = (rfReplaceAll, rfIgnoreCase); // @size 0x1

  TReplaceFlags = set of TReplaceFlagsElement; // @size 0x1

  TThreadLocalCounter = class(TObject) // @size 0x44
  public
    destructor Destroy;
    function HashIndex: Byte;
    procedure Open(var Thread: PThreadInfo);
    function Recycle: PThreadInfo;
  end;

  TThreadInfo = record;

  PThreadInfo = ^TThreadInfo;

  TMultiReadExclusiveWriteSynchronizer = class(TInterfacedObject) // @size 0x30
  public
    constructor Create;
    destructor Destroy;
    function BeginWrite: Boolean;
    procedure EndWrite;
    procedure BeginRead;
    procedure EndRead;
  end;

procedure ConvertErrorFmt; // @nameonly

function UpperCase(const S: AnsiString): AnsiString;
function StrComp(Left, Right: PAnsiChar): Integer;

function AnsiLowerCase(const S: AnsiString): AnsiString; // @addr $409D68
function GetCurrentDir: AnsiString; // @addr $40A958

function LowerCase(const S: AnsiString): AnsiString;

procedure CompareStr; // @nameonly

procedure SameText; // @nameonly

function AnsiCompareText(const S1, S2: AnsiString): Integer;

function AnsiStrLIComp(S1, S2: PAnsiChar; MaxLen: Cardinal): Integer;

function WideLowerCase(const S: WideString): WideString;

function Trim(const S: AnsiString): AnsiString; // @addr $409E9C

function IsValidIdent(const Ident: AnsiString; AllowDots: Boolean): Boolean;

procedure CvtInt;

procedure CvtInt64;

function StrToIntDef(const S: AnsiString; Default: Integer): Integer;

function TryStrToInt(const S: AnsiString; out Value: Integer): Boolean;

function StrToInt64(const S: AnsiString): Int64;

procedure VerifyBoolStrArray;

function CompareWith(const aArray: array of AnsiString): Boolean; // @nameonly

function TryStrToBool(const S: AnsiString; out Value: Boolean): Boolean;

function BoolToStr(B: Boolean; UseBoolStrs: Boolean): AnsiString;

function FileOpen(const FileName: AnsiString; Mode: Cardinal): Integer;

procedure FileSeek; // @nameonly

function DirectoryExists(const Directory: AnsiString): Boolean;

function FindMatchingFile(var F: TSearchRec): Integer;

function FindFirst(const Path: AnsiString; Attr: Integer; var F: TSearchRec): Integer;

function FindNext(var F: TSearchRec): Integer;

procedure FindClose_40A750(var F: TSearchRec);

function AnsiLastChar(const S: AnsiString): PAnsiChar;

function LastDelimiter(const Delimiters, S: AnsiString): Integer;

function ExtractFilePath(const FileName: AnsiString): AnsiString;

function ExtractFileName(const FileName: AnsiString): AnsiString;

function ExtractFileExt(const FileName: AnsiString): AnsiString;

function ExpandFileName(const FileName: AnsiString): AnsiString;

function BackfillGetDiskFreeSpaceEx(Directory: PAnsiChar; var FreeAvailable, TotalSpace: TLargeInteger; TotalFree: PLargeInteger): LongBool; stdcall;

function SetCurrentDir(const Dir: AnsiString): Boolean;

function CreateDir(const Dir: AnsiString): Boolean;

function StrLen(const Str: PAnsiChar): Cardinal;

function StrEnd(const Str: PAnsiChar): PAnsiChar;

function StrCopy(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar;

function StrLCopy(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar;

function StrPCopy(Dest: PAnsiChar; const Source: AnsiString): PAnsiChar;

function StrLIComp(const Str1, Str2: PAnsiChar; MaxLen: Cardinal): Integer;

function StrPos(const Str1, Str2: PAnsiChar): PAnsiChar;

function StrAlloc(Size: Cardinal): PAnsiChar;

procedure FormatError(ErrorCode: Integer; Format: PAnsiChar; FmtLen: Cardinal); // @nameonly

procedure FormatBuf; // @nameonly

procedure StrFmt; // @nameonly

procedure StrLFmt; // @nameonly

function Format(const Fmt: AnsiString; const Args: array of const): AnsiString;

procedure FmtStr; // @nameonly

procedure PutExponent;

procedure FloatToText; // @nameonly

procedure FloatToDecimal(var Result: TFloatRec; Value: Pointer; ValueType: TFloatValue; Precision, Decimals: Integer);

procedure TextToFloat; // @nameonly

function FloatToStr(Value: Extended): AnsiString; // @ida "void __userpurge $name(char **Result@<eax>, _TBYTE Value@<^0>);" @note "RTL SysUtils.pas:11294. Uses global format settings, ffGeneral and precision 15; Extended occupies twelve stack bytes, removed by the callee."

procedure CurrToStr; // @nameonly

procedure FloatToStrF; // @nameonly

function StrToFloat(const Text: AnsiString): Extended; // @note "Parses using the global format settings; raises EConvertError on invalid input. Native return is loaded from ten-byte storage."

procedure TryStrToFloat; // @nameonly

procedure TryStrToFloat_40B900; // @nameonly

procedure TryStrToFloat_40B92C; // @nameonly

procedure TryStrToCurr; // @nameonly

function DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp; // @ida "void __userpurge $name(TDateTime DateTime@<^0>, TTimeStamp *Result@<eax>);"

function TryEncodeTime(Hour, Min, Sec, MSec: Word; out Time: TDateTime): Boolean;

function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;

procedure DecodeTime(const DateTime: TDateTime; var Hour, Min, Sec, MSec: Word);

function IsLeapYear(Year: Word): Boolean;

function TryEncodeDate(Year, Month, Day: Word; out Date: TDateTime): Boolean;

function EncodeDate(Year, Month, Day: Word): TDateTime;

function DecodeDateFully(const DateTime: TDateTime; var Year, Month, Day, DOW: Word): Boolean;

procedure DecodeDate(const DateTime: TDateTime; var Year, Month, Day: Word);

procedure SystemTimeToDateTime; // @nameonly

function DayOfWeek(const DateTime: TDateTime): Word;

function Now: TDateTime;

procedure AppendChars; // @nameonly

procedure AppendString; // @nameonly

procedure AppendNumber; // @nameonly

procedure GetCount; // @nameonly

procedure GetDate; // @nameonly

procedure GetTime; // @nameonly

procedure ConvertEraString; // @nameonly

procedure ConvertYearString; // @nameonly

procedure AppendFormat; // @nameonly

procedure DateTimeToString; // @nameonly

procedure ScanBlanks(const S: AnsiString; var Pos: Integer);

function ScanNumber(const S: AnsiString; var Pos: Integer; var Number: Word; var CharCount: Byte): Boolean;

function ScanString(const S: AnsiString; var Pos: Integer; const Symbol: AnsiString): Boolean;

function ScanChar(const S: AnsiString; var Pos: Integer; Ch: Char): Boolean;

function GetDateOrder(const DateFormat: AnsiString): TDateOrder;

procedure ScanToNumber(const S: AnsiString; var Pos: Integer);

function GetEraYearOffset(const Name: AnsiString): Integer;

procedure EraToYear; // @nameonly

procedure ScanDate; // @nameonly

procedure ScanTime; // @nameonly

procedure TryStrToTime; // @nameonly

procedure TryStrToDateTime; // @nameonly

function SysErrorMessage(ErrorCode: Integer): AnsiString;

procedure GetLocaleStr; // @nameonly

function GetLocaleChar(Locale, LocaleType: Integer; Default: Char): Char;

procedure LocalGetLocaleStr; // @nameonly

procedure GetMonthDayNames;

function EnumEraNames(Names: PAnsiChar): Integer; stdcall;

function EnumEraYearOffsets(YearOffsets: PAnsiChar): Integer; stdcall;

procedure GetEraNamesAndYearOffsets;

function TranslateDateFormat(const FormatStr: AnsiString): AnsiString;

function ExceptionErrorMessage(ExceptObject: TObject; ExceptAddr: Pointer; Buffer: PAnsiChar; Size: Integer): Integer;

procedure ShowException(ExceptObject: TObject; ExceptAddr: Pointer);

function CreateInOutError: EInOutError;

procedure ErrorHandler(ErrorCode: Byte; ErrorAddr: Pointer); // @nameonly

function CreateAssertException(const Message, Filename: AnsiString; LineNumber: Integer): Exception;

procedure AssertErrorHandler(const Message, Filename: AnsiString; LineNumber: Integer; ErrorAddr: Pointer); // @nameonly

function MapException(P: PExceptionRecord): TRuntimeError; // @ida "TRuntimeError __usercall $name@<al>(PExceptionRecord *P@<eax>);"

function CreateAVObject: Exception; // @nameonly

procedure GetExceptionObject; // @nameonly

procedure InitExceptions;

procedure InitPlatformId;

function GetFileVersion(const AFileName: AnsiString): Cardinal;

function ByteTypeTest(P: PAnsiChar; Index: Integer): TMbcsByteType;

function ByteType(const S: AnsiString; Index: Integer): TMbcsByteType;

function ByteToCharLen(const S: AnsiString; MaxLen: Integer): Integer;

function ByteToCharIndex(const S: AnsiString; Index: Integer): Integer;

procedure CountChars(const S: AnsiString; MaxChars: Integer; var CharCount, ByteCount: Integer);

function CharToByteIndex(const S: AnsiString; Index: Integer): Integer;

function CharToByteLen(const S: AnsiString; MaxLen: Integer): Integer;

function CharLength(const S: AnsiString; Index: Integer): Integer;

function NextCharIndex(const S: AnsiString; Index: Integer): Integer;

function AnsiPos(const Substr, S: AnsiString): Integer;

function AnsiLowerCaseFileName(const S: AnsiString): AnsiString;

function AnsiStrPos(Str, SubStr: PAnsiChar): PAnsiChar;

function AnsiStrRScan(Str: PAnsiChar; Chr: Char): PAnsiChar;

function AnsiStrScan(Str: PAnsiChar; Chr: Char): PAnsiChar;

procedure InitLeadBytes; // @nameonly

procedure InitSysLocale;

procedure GetFormatSettings;

function StringReplace(const S, OldPattern, NewPattern: AnsiString; Flags: TReplaceFlags): AnsiString; // @ida "void __userpurge $name(char * S@<eax>, char * OldPattern@<edx>, char * NewPattern@<ecx>, TReplaceFlags *Flags@<^4>, char * *Result@<^0>);"

function HashName(Name: PAnsiChar): Cardinal;

procedure ModuleUnloaded(Module: Cardinal);

procedure RaiseLastOSError; // @nameonly

function CallTerminateProcs: Boolean;

procedure FreeTerminateProcs;

procedure InitDriveSpacePtr;

procedure Supports; // @nameonly

procedure Supports_40F7B0; // @nameonly

procedure SafeLoadLibrary; // @nameonly

procedure ClearHashTables;

procedure FinalizeSysUtils; // @nameonly

var
  DecimalSeparator: AnsiChar; // @addr $81780B

function StrPas(const Str: PAnsiChar): AnsiString; // @addr $40ABD8
procedure StrDispose(Str: PAnsiChar); // @addr $40AC38

// Delphi 2007 Update 4 supplies the native locked/shared-file fallback.
function FileExists(const FileName: AnsiString): Boolean; // @addr $40A5EC
function ExistsLockedOrShared(const FileName: AnsiString): Boolean; // @addr $40A5AC @note "Private helper inside FileExists; no captured frame."

implementation
end.
