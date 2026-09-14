unit SysUtils;
// Unit bracket (inferred): .text 0x00408E1C..0x0040FD58; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008750AC..0x00875126; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses System, Windows;

type
  Exception = class(TObject) // @size 0x0C
  public
    Message: AnsiString; // @offset 0x04

    constructor Create(Message: AnsiString); // @ida "Exception *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, char *Message@<ecx>);"
  public
    procedure CreateFmt; // @nameonly @note "DCC32 MAP SysUtils.Exception.CreateFmt. Source rtl/sys/SysUtils.pas:13888. Prototype pending: source type not found: const."
    procedure CreateRes; // @nameonly @note "DCC32 MAP SysUtils.Exception.CreateRes. Prototype pending: no unique source declaration."
    procedure CreateResFmt; // @nameonly @note "DCC32 MAP SysUtils.Exception.CreateResFmt. Prototype pending: no unique source declaration."
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

function IntToStr(Value: Integer): AnsiString; // @ida "void __usercall $name(int Value@<eax>, char **Result@<edx>);"
function Int64ToStr(Value: Int64): AnsiString; // @ida "void __userpurge $name(char **Result@<eax>, __int64 Value@<^0>);"
function IntToHex64(Value: Int64; Digits: Integer): AnsiString; // @addr $40A1C8 @ida "void __userpurge $name(int Digits@<eax>, char **Result@<edx>, __int64 Value@<^0>);"
function IntToHex(Value, Digits: Integer): AnsiString; // @ida "void __usercall $name(int Value@<eax>, int Digits@<edx>, char **Result@<ecx>);"
function StrToInt(Value: AnsiString): Integer; // @note "Parses signed decimal or hexadecimal text; raises a conversion exception on invalid input."
procedure Abort; // @addr $40DB9C @note "Raises EAbort with SOperationAborted at the caller's return address."
function RtlTrimWideString(const Text: WideString): WideString; // @addr $409EF0 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, unsigned __int16 **Result@<edx>);"
function TrimRightWideString(Text: WideString): WideString; // @addr 0x409F40 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, unsigned __int16 **Result@<edx>);" @note "Trims trailing UTF-16 code units <= #32."
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
    destructor Destroy; // @ida "void __usercall $name(TThreadLocalCounter *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP SysUtils.TThreadLocalCounter.Destroy. Source rtl/sys/SysUtils.pas:16575."
    function HashIndex: Byte; // @ida "unsigned __int8 __usercall $name@<al>(TThreadLocalCounter *Self@<eax>);" @note "DCC32 MAP SysUtils.TThreadLocalCounter.HashIndex. Source rtl/sys/SysUtils.pas:16594."
    procedure Open(var Thread: PThreadInfo); // @ida "void __usercall $name(TThreadLocalCounter *Self@<eax>, PThreadInfo *Thread@<edx>);" @note "DCC32 MAP SysUtils.TThreadLocalCounter.Open. Source rtl/sys/SysUtils.pas:16602."
    function Recycle: PThreadInfo; // @ida "PThreadInfo __usercall $name@<eax>(TThreadLocalCounter *Self@<eax>);" @note "DCC32 MAP SysUtils.TThreadLocalCounter.Recycle. Source rtl/sys/SysUtils.pas:16646."
  end;

  TThreadInfo = record;

  PThreadInfo = ^TThreadInfo;

  TMultiReadExclusiveWriteSynchronizer = class(TInterfacedObject) // @size 0x30
  public
    constructor Create; // @ida "TMultiReadExclusiveWriteSynchronizer * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);" @note "DCC32 MAP SysUtils.TMultiReadExclusiveWriteSynchronizer.Create. Source rtl/sys/SysUtils.pas:16673."
    destructor Destroy; // @ida "void __usercall $name(TMultiReadExclusiveWriteSynchronizer *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP SysUtils.TMultiReadExclusiveWriteSynchronizer.Destroy. Source rtl/sys/SysUtils.pas:16683."
    function BeginWrite: Boolean; // @ida "bool __usercall $name@<al>(TMultiReadExclusiveWriteSynchronizer *Self@<eax>);" @note "DCC32 MAP SysUtils.TMultiReadExclusiveWriteSynchronizer.BeginWrite. Source rtl/sys/SysUtils.pas:16728."
    procedure EndWrite; // @ida "void __usercall $name(TMultiReadExclusiveWriteSynchronizer *Self@<eax>);" @note "DCC32 MAP SysUtils.TMultiReadExclusiveWriteSynchronizer.EndWrite. Source rtl/sys/SysUtils.pas:16820."
    procedure BeginRead; // @ida "void __usercall $name(TMultiReadExclusiveWriteSynchronizer *Self@<eax>);" @note "DCC32 MAP SysUtils.TMultiReadExclusiveWriteSynchronizer.BeginRead. Source rtl/sys/SysUtils.pas:16850."
    procedure EndRead; // @ida "void __usercall $name(TMultiReadExclusiveWriteSynchronizer *Self@<eax>);" @note "DCC32 MAP SysUtils.TMultiReadExclusiveWriteSynchronizer.EndRead. Source rtl/sys/SysUtils.pas:16911."
  end;

procedure ConvertErrorFmt; // @nameonly @note "DCC32 MAP SysUtils.ConvertErrorFmt. Source rtl/sys/SysUtils.pas:3243. Prototype pending: source type not found: const."

function UpperCase(const S: AnsiString): AnsiString; // @ida "void __usercall $name(char *S@<eax>, char **Result@<edx>);"
function StrComp(Left, Right: PAnsiChar): Integer;

function AnsiLowerCase(const S: AnsiString): AnsiString; // @addr $409D68 @ida "void __usercall $name(char *S@<eax>, char **Result@<edx>);"
function GetCurrentDir: AnsiString; // @addr $40A958 @ida "void __usercall $name(char **Result@<eax>);"

function LowerCase(const S: AnsiString): AnsiString; // @ida "void __usercall $name(char *S@<eax>, char **Result@<edx>);" @note "DCC32 MAP SysUtils.LowerCase; native ASCII conversion allocates a same-length AnsiString."

procedure CompareStr; // @nameonly @note "DCC32 MAP SysUtils.CompareStr. Prototype pending: no unique source declaration."

procedure SameText; // @nameonly @note "DCC32 MAP SysUtils.SameText. Prototype pending: no unique source declaration."

function AnsiCompareText(const S1, S2: AnsiString): Integer; // @ida "__int32 __usercall $name@<eax>(char * S1@<eax>, char * S2@<edx>);" @note "DCC32 MAP SysUtils.AnsiCompareText. Source rtl/sys/SysUtils.pas:4041."

function AnsiStrLIComp(S1, S2: PAnsiChar; MaxLen: Cardinal): Integer; // @ida "__int32 __usercall $name@<eax>(PAnsiChar S1@<eax>, PAnsiChar S2@<edx>, unsigned __int32 MaxLen@<ecx>);" @note "DCC32 MAP SysUtils.AnsiStrLIComp. Source rtl/sys/SysUtils.pas:4164."

function WideLowerCase(const S: WideString): WideString; // @ida "void __usercall $name(unsigned __int16 * S@<eax>, unsigned __int16 * *Result@<edx>);" @note "DCC32 MAP SysUtils.WideLowerCase. Source rtl/sys/SysUtils.pas:4254."

function Trim(const S: AnsiString): AnsiString; // @addr $409E9C @ida "void __usercall $name(char *S@<eax>, char **Result@<edx>);"

function IsValidIdent(const Ident: AnsiString; AllowDots: Boolean): Boolean; // @ida "bool __usercall $name@<al>(char * Ident@<eax>, bool AllowDots@<dl>);" @note "DCC32 MAP SysUtils.IsValidIdent. Source rtl/sys/SysUtils.pas:4605."

procedure CvtInt; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.CvtInt. Source rtl/sys/SysUtils.pas:4625."

procedure CvtInt64; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.CvtInt64. Source rtl/sys/SysUtils.pas:4853."

function StrToIntDef(const S: AnsiString; Default: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(char * S@<eax>, __int32 Default@<edx>);" @note "DCC32 MAP SysUtils.StrToIntDef. Source rtl/sys/SysUtils.pas:5019."

function TryStrToInt(const S: AnsiString; out Value: Integer): Boolean; // @ida "bool __usercall $name@<al>(char * S@<eax>, __int32 *Value@<edx>);" @note "DCC32 MAP SysUtils.TryStrToInt. Source rtl/sys/SysUtils.pas:5027."

function StrToInt64(const S: AnsiString): Int64; // @ida "__int64 __usercall $name@<edx:eax>(char * S@<eax>);" @note "DCC32 MAP SysUtils.StrToInt64. Source rtl/sys/SysUtils.pas:5035."

procedure VerifyBoolStrArray; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.VerifyBoolStrArray. Source rtl/sys/SysUtils.pas:5059."

function CompareWith(const aArray: array of AnsiString): Boolean; // @nameonly @note "DCC32 MAP SysUtils.CompareWith. Source rtl/sys/SysUtils.pas:5086. Prototype pending: nested routine has a parent-frame parameter."

function TryStrToBool(const S: AnsiString; out Value: Boolean): Boolean; // @ida "bool __usercall $name@<al>(char * S@<eax>, bool *Value@<edx>);" @note "DCC32 MAP SysUtils.TryStrToBool. Source rtl/sys/SysUtils.pas:5085."

function BoolToStr(B: Boolean; UseBoolStrs: Boolean): AnsiString; // @ida "void __usercall $name(bool B@<al>, bool UseBoolStrs@<dl>, char * *Result@<ecx>);" @note "DCC32 MAP SysUtils.BoolToStr. Source rtl/sys/SysUtils.pas:5119."

function FileOpen(const FileName: AnsiString; Mode: Cardinal): Integer; // @ida "__int32 __usercall $name@<eax>(char * FileName@<eax>, unsigned __int32 Mode@<edx>);" @note "DCC32 MAP SysUtils.FileOpen. Source rtl/sys/SysUtils.pas:5193."

procedure FileSeek; // @nameonly @note "DCC32 MAP SysUtils.FileSeek. Prototype pending: no unique source declaration."

function DirectoryExists(const Directory: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(char * Directory@<eax>);" @note "DCC32 MAP SysUtils.DirectoryExists. Source rtl/sys/SysUtils.pas:5448."

function FindMatchingFile(var F: TSearchRec): Integer; // @ida "__int32 __usercall $name@<eax>(TSearchRec *F@<eax>);" @note "DCC32 MAP SysUtils.FindMatchingFile. Source rtl/sys/SysUtils.pas:5607."

function FindFirst(const Path: AnsiString; Attr: Integer; var F: TSearchRec): Integer; // @ida "__int32 __usercall $name@<eax>(char * Path@<eax>, __int32 Attr@<edx>, TSearchRec *F@<ecx>);" @note "DCC32 MAP SysUtils.FindFirst. Source rtl/sys/SysUtils.pas:5698."

function FindNext(var F: TSearchRec): Integer; // @ida "__int32 __usercall $name@<eax>(TSearchRec *F@<eax>);" @note "DCC32 MAP SysUtils.FindNext. Source rtl/sys/SysUtils.pas:5734."

procedure FindClose_40A750(var F: TSearchRec); // @ida "void __usercall $name(TSearchRec *F@<eax>);" @note "DCC32 MAP SysUtils.FindClose. Source rtl/sys/SysUtils.pas:5746."

function AnsiLastChar(const S: AnsiString): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(char * S@<eax>);" @note "DCC32 MAP SysUtils.AnsiLastChar. Source rtl/sys/SysUtils.pas:5830."

function LastDelimiter(const Delimiters, S: AnsiString): Integer; // @ida "__int32 __usercall $name@<eax>(char * Delimiters@<eax>, char * S@<edx>);" @note "DCC32 MAP SysUtils.LastDelimiter. Source rtl/sys/SysUtils.pas:5844."

function ExtractFilePath(const FileName: AnsiString): AnsiString; // @ida "void __usercall $name(char * FileName@<eax>, char * *Result@<edx>);" @note "DCC32 MAP SysUtils.ExtractFilePath. Source rtl/sys/SysUtils.pas:5885."

function ExtractFileName(const FileName: AnsiString): AnsiString; // @ida "void __usercall $name(char * FileName@<eax>, char * *Result@<edx>);" @note "DCC32 MAP SysUtils.ExtractFileName. Source rtl/sys/SysUtils.pas:5931."

function ExtractFileExt(const FileName: AnsiString): AnsiString; // @ida "void __usercall $name(char * FileName@<eax>, char * *Result@<edx>);" @note "DCC32 MAP SysUtils.ExtractFileExt. Source rtl/sys/SysUtils.pas:5939."

function ExpandFileName(const FileName: AnsiString): AnsiString; // @ida "void __usercall $name(char * FileName@<eax>, char * *Result@<edx>);" @note "DCC32 MAP SysUtils.ExpandFileName. Source rtl/sys/SysUtils.pas:5949."

function BackfillGetDiskFreeSpaceEx(Directory: PAnsiChar; var FreeAvailable, TotalSpace: TLargeInteger; TotalFree: PLargeInteger): LongBool; stdcall; // @ida "__int32 __stdcall $name(PAnsiChar Directory, TLargeInteger *FreeAvailable, TLargeInteger *TotalSpace, PLargeInteger TotalFree);" @note "DCC32 MAP SysUtils.BackfillGetDiskFreeSpaceEx. Source rtl/sys/SysUtils.pas:6351."

function SetCurrentDir(const Dir: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(char * Dir@<eax>);" @note "DCC32 MAP SysUtils.SetCurrentDir. Source rtl/sys/SysUtils.pas:6475."

function CreateDir(const Dir: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(char * Dir@<eax>);" @note "DCC32 MAP SysUtils.CreateDir. Source rtl/sys/SysUtils.pas:6485."

function StrLen(const Str: PAnsiChar): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(PAnsiChar Str@<eax>);" @note "DCC32 MAP SysUtils.StrLen. Source rtl/sys/SysUtils.pas:6519."

function StrEnd(const Str: PAnsiChar): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar Str@<eax>);" @note "DCC32 MAP SysUtils.StrEnd. Source rtl/sys/SysUtils.pas:6548."

function StrCopy(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar Dest@<eax>, PAnsiChar Source@<edx>);" @note "DCC32 MAP SysUtils.StrCopy. Source rtl/sys/SysUtils.pas:6577."

function StrLCopy(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar Dest@<eax>, PAnsiChar Source@<edx>, unsigned __int32 MaxLen@<ecx>);" @note "DCC32 MAP SysUtils.StrLCopy. Source rtl/sys/SysUtils.pas:6628."

function StrPCopy(Dest: PAnsiChar; const Source: AnsiString): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar Dest@<eax>, char * Source@<edx>);" @note "DCC32 MAP SysUtils.StrPCopy. Source rtl/sys/SysUtils.pas:6659."

function StrLIComp(const Str1, Str2: PAnsiChar; MaxLen: Cardinal): Integer; // @ida "__int32 __usercall $name@<eax>(PAnsiChar Str1@<eax>, PAnsiChar Str2@<edx>, unsigned __int32 MaxLen@<ecx>);" @note "DCC32 MAP SysUtils.StrLIComp. Source rtl/sys/SysUtils.pas:6829."

function StrPos(const Str1, Str2: PAnsiChar): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar Str1@<eax>, PAnsiChar Str2@<edx>);" @note "DCC32 MAP SysUtils.StrPos. Source rtl/sys/SysUtils.pas:6905."

function StrAlloc(Size: Cardinal): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(unsigned __int32 Size@<eax>);" @note "DCC32 MAP SysUtils.StrAlloc. Source rtl/sys/SysUtils.pas:6993."

procedure FormatError(ErrorCode: Integer; Format: PAnsiChar; FmtLen: Cardinal); // @nameonly @note "DCC32 MAP SysUtils.FormatError. Source rtl/sys/SysUtils.pas:7032. Prototype pending: RET mismatch: expected 0, native []."

procedure FormatBuf; // @nameonly @note "DCC32 MAP SysUtils.FormatBuf. Prototype pending: no unique source declaration."

procedure StrFmt; // @nameonly @note "DCC32 MAP SysUtils.StrFmt. Prototype pending: no unique source declaration."

procedure StrLFmt; // @nameonly @note "DCC32 MAP SysUtils.StrLFmt. Prototype pending: no unique source declaration."

function Format(const Fmt: AnsiString; const Args: array of const): AnsiString; // @ida "void __userpurge $name(char *Fmt@<eax>, TVarRec *Args@<edx>, int Args_high@<ecx>, char **Result@<^0>);"

procedure FmtStr; // @nameonly @note "DCC32 MAP SysUtils.FmtStr. Prototype pending: no unique source declaration."

procedure PutExponent; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.PutExponent. Source rtl/sys/SysUtils.pas:9252."

procedure FloatToText; // @nameonly @note "DCC32 MAP SysUtils.FloatToText. Prototype pending: no unique source declaration."

procedure FloatToDecimal(var Result: TFloatRec; Value: Pointer; ValueType: TFloatValue; Precision, Decimals: Integer); // @ida "void __userpurge $name(TFloatRec *Result@<eax>, void * Value@<edx>, TFloatValue ValueType@<cl>, __int32 Precision@<^4>, __int32 Decimals@<^0>);" @note "DCC32 MAP SysUtils.FloatToDecimal. Source rtl/sys/SysUtils.pas:10731."

procedure TextToFloat; // @nameonly @note "DCC32 MAP SysUtils.TextToFloat. Prototype pending: no unique source declaration."

function FloatToStr(Value: Extended): AnsiString; // @ida "void __userpurge $name(char **Result@<eax>, _TBYTE Value@<^0>);" @note "RTL SysUtils.pas:11294. Uses global format settings, ffGeneral and precision 15; Extended occupies twelve stack bytes, removed by the callee."

procedure CurrToStr; // @nameonly @note "DCC32 MAP SysUtils.CurrToStr. Prototype pending: no unique source declaration."

procedure FloatToStrF; // @nameonly @note "DCC32 MAP SysUtils.FloatToStrF. Prototype pending: no unique source declaration."

function StrToFloat(const Text: AnsiString): Extended; // @ida "double __usercall $name@<st0>(char *Text@<eax>);" @note "Parses using the global format settings; raises EConvertError on invalid input. Native return is loaded from ten-byte storage."

procedure TryStrToFloat; // @nameonly @note "DCC32 MAP SysUtils.TryStrToFloat. Prototype pending: no unique source declaration."

procedure TryStrToFloat_40B900; // @nameonly @note "DCC32 MAP SysUtils.TryStrToFloat. Prototype pending: no unique source declaration."

procedure TryStrToFloat_40B92C; // @nameonly @note "DCC32 MAP SysUtils.TryStrToFloat. Prototype pending: no unique source declaration."

procedure TryStrToCurr; // @nameonly @note "DCC32 MAP SysUtils.TryStrToCurr. Prototype pending: no unique source declaration."

function DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp; // @ida "void __userpurge $name(TDateTime DateTime@<^0>, TTimeStamp *Result@<eax>);" @note "DCC32 MAP SysUtils.DateTimeToTimeStamp. Source rtl/sys/SysUtils.pas:11533."

function TryEncodeTime(Hour, Min, Sec, MSec: Word; out Time: TDateTime): Boolean; // @ida "bool __userpurge $name@<al>(unsigned __int16 Hour@<ax>, unsigned __int16 Min@<dx>, unsigned __int16 Sec@<cx>, unsigned __int16 MSec@<^4>, TDateTime *Time@<^0>);" @note "DCC32 MAP SysUtils.TryEncodeTime. Source rtl/sys/SysUtils.pas:11648."

function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime; // @ida "TDateTime __userpurge $name@<st0>(unsigned __int16 Hour@<ax>, unsigned __int16 Min@<dx>, unsigned __int16 Sec@<cx>, unsigned __int16 MSec@<^0>);" @note "DCC32 MAP SysUtils.EncodeTime. Source rtl/sys/SysUtils.pas:11661."

procedure DecodeTime(const DateTime: TDateTime; var Hour, Min, Sec, MSec: Word); // @ida "void __userpurge $name(TDateTime DateTime@<^4>, unsigned __int16 *Hour@<eax>, unsigned __int16 *Min@<edx>, unsigned __int16 *Sec@<ecx>, unsigned __int16 *MSec@<^0>);" @note "DCC32 MAP SysUtils.DecodeTime. Source rtl/sys/SysUtils.pas:11667."

function IsLeapYear(Year: Word): Boolean; // @ida "bool __usercall $name@<al>(unsigned __int16 Year@<ax>);" @note "DCC32 MAP SysUtils.IsLeapYear. Source rtl/sys/SysUtils.pas:11678."

function TryEncodeDate(Year, Month, Day: Word; out Date: TDateTime): Boolean; // @ida "bool __userpurge $name@<al>(unsigned __int16 Year@<ax>, unsigned __int16 Month@<dx>, unsigned __int16 Day@<cx>, TDateTime *Date@<^0>);" @note "DCC32 MAP SysUtils.TryEncodeDate. Source rtl/sys/SysUtils.pas:11683."

function EncodeDate(Year, Month, Day: Word): TDateTime; // @ida "TDateTime __usercall $name@<st0>(unsigned __int16 Year@<ax>, unsigned __int16 Month@<dx>, unsigned __int16 Day@<cx>);" @note "DCC32 MAP SysUtils.EncodeDate. Source rtl/sys/SysUtils.pas:11700."

function DecodeDateFully(const DateTime: TDateTime; var Year, Month, Day, DOW: Word): Boolean; // @ida "bool __userpurge $name@<al>(TDateTime DateTime@<^4>, unsigned __int16 *Year@<eax>, unsigned __int16 *Month@<edx>, unsigned __int16 *Day@<ecx>, unsigned __int16 *DOW@<^0>);" @note "DCC32 MAP SysUtils.DecodeDateFully. Source rtl/sys/SysUtils.pas:11706."

procedure DecodeDate(const DateTime: TDateTime; var Year, Month, Day: Word); // @ida "void __userpurge $name(TDateTime DateTime@<^0>, unsigned __int16 *Year@<eax>, unsigned __int16 *Month@<edx>, unsigned __int16 *Day@<ecx>);" @note "DCC32 MAP SysUtils.DecodeDate. Source rtl/sys/SysUtils.pas:11773."

procedure SystemTimeToDateTime; // @nameonly @note "DCC32 MAP SysUtils.SystemTimeToDateTime. Source rtl/sys/SysUtils.pas:11791. Prototype pending: ambiguous source type: TSystemTime."

function DayOfWeek(const DateTime: TDateTime): Word; // @ida "unsigned __int16 __userpurge $name@<ax>(TDateTime DateTime@<^0>);" @note "DCC32 MAP SysUtils.DayOfWeek. Source rtl/sys/SysUtils.pas:11804."

function Now: TDateTime; // @ida "TDateTime __usercall $name@<st0>(void);" @note "DCC32 MAP SysUtils.Now. Source rtl/sys/SysUtils.pas:11857."

procedure AppendChars; // @nameonly @note "DCC32 MAP SysUtils.AppendChars. Prototype pending: no unique source declaration."

procedure AppendString; // @nameonly @note "DCC32 MAP SysUtils.AppendString. Prototype pending: no unique source declaration."

procedure AppendNumber; // @nameonly @note "DCC32 MAP SysUtils.AppendNumber. Prototype pending: no unique source declaration."

procedure GetCount; // @nameonly @note "DCC32 MAP SysUtils.GetCount. Prototype pending: no unique source declaration."

procedure GetDate; // @nameonly @note "DCC32 MAP SysUtils.GetDate. Prototype pending: no unique source declaration."

procedure GetTime; // @nameonly @note "DCC32 MAP SysUtils.GetTime. Prototype pending: no unique source declaration."

procedure ConvertEraString; // @nameonly @note "DCC32 MAP SysUtils.ConvertEraString. Prototype pending: no unique source declaration."

procedure ConvertYearString; // @nameonly @note "DCC32 MAP SysUtils.ConvertYearString. Prototype pending: no unique source declaration."

procedure AppendFormat; // @nameonly @note "DCC32 MAP SysUtils.AppendFormat. Prototype pending: no unique source declaration."

procedure DateTimeToString; // @nameonly @note "DCC32 MAP SysUtils.DateTimeToString. Prototype pending: no unique source declaration."

procedure ScanBlanks(const S: AnsiString; var Pos: Integer); // @ida "void __usercall $name(char * S@<eax>, __int32 *Pos@<edx>);" @note "DCC32 MAP SysUtils.ScanBlanks. Source rtl/sys/SysUtils.pas:12816."

function ScanNumber(const S: AnsiString; var Pos: Integer; var Number: Word; var CharCount: Byte): Boolean; // @ida "bool __userpurge $name@<al>(char * S@<eax>, __int32 *Pos@<edx>, unsigned __int16 *Number@<ecx>, unsigned __int8 *CharCount@<^0>);" @note "DCC32 MAP SysUtils.ScanNumber. Source rtl/sys/SysUtils.pas:12825."

function ScanString(const S: AnsiString; var Pos: Integer; const Symbol: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(char * S@<eax>, __int32 *Pos@<edx>, char * Symbol@<ecx>);" @note "DCC32 MAP SysUtils.ScanString. Source rtl/sys/SysUtils.pas:12850."

function ScanChar(const S: AnsiString; var Pos: Integer; Ch: Char): Boolean; // @ida "bool __usercall $name@<al>(char * S@<eax>, __int32 *Pos@<edx>, char Ch@<cl>);" @note "DCC32 MAP SysUtils.ScanChar. Source rtl/sys/SysUtils.pas:12865."

function GetDateOrder(const DateFormat: AnsiString): TDateOrder; // @ida "TDateOrder __usercall $name@<al>(char * DateFormat@<eax>);" @note "DCC32 MAP SysUtils.GetDateOrder. Source rtl/sys/SysUtils.pas:12876."

procedure ScanToNumber(const S: AnsiString; var Pos: Integer); // @ida "void __usercall $name(char * S@<eax>, __int32 *Pos@<edx>);" @note "DCC32 MAP SysUtils.ScanToNumber. Source rtl/sys/SysUtils.pas:12898."

function GetEraYearOffset(const Name: AnsiString): Integer; // @ida "__int32 __usercall $name@<eax>(char * Name@<eax>);" @note "DCC32 MAP SysUtils.GetEraYearOffset. Source rtl/sys/SysUtils.pas:12909."

procedure EraToYear; // @nameonly @note "DCC32 MAP SysUtils.EraToYear. Prototype pending: no unique source declaration."

procedure ScanDate; // @nameonly @note "DCC32 MAP SysUtils.ScanDate. Prototype pending: no unique source declaration."

procedure ScanTime; // @nameonly @note "DCC32 MAP SysUtils.ScanTime. Prototype pending: no unique source declaration."

procedure TryStrToTime; // @nameonly @note "DCC32 MAP SysUtils.TryStrToTime. Prototype pending: no unique source declaration."

procedure TryStrToDateTime; // @nameonly @note "DCC32 MAP SysUtils.TryStrToDateTime. Prototype pending: no unique source declaration."

function SysErrorMessage(ErrorCode: Integer): AnsiString; // @ida "void __usercall $name(__int32 ErrorCode@<eax>, char * *Result@<edx>);" @note "DCC32 MAP SysUtils.SysErrorMessage. Source rtl/sys/SysUtils.pas:13352."

procedure GetLocaleStr; // @nameonly @note "DCC32 MAP SysUtils.GetLocaleStr. Prototype pending: no unique source declaration."

function GetLocaleChar(Locale, LocaleType: Integer; Default: Char): Char; // @ida "char __usercall $name@<al>(__int32 Locale@<eax>, __int32 LocaleType@<edx>, char Default@<cl>);" @note "DCC32 MAP SysUtils.GetLocaleChar. Source rtl/sys/SysUtils.pas:13391."

procedure LocalGetLocaleStr; // @nameonly @note "DCC32 MAP SysUtils.LocalGetLocaleStr. Prototype pending: no unique source declaration."

procedure GetMonthDayNames; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.GetMonthDayNames. Source rtl/sys/SysUtils.pas:13428."

function EnumEraNames(Names: PAnsiChar): Integer; stdcall; // @ida "__int32 __stdcall $name(PAnsiChar Names);" @note "DCC32 MAP SysUtils.EnumEraNames. Source rtl/sys/SysUtils.pas:13542."

function EnumEraYearOffsets(YearOffsets: PAnsiChar): Integer; stdcall; // @ida "__int32 __stdcall $name(PAnsiChar YearOffsets);" @note "DCC32 MAP SysUtils.EnumEraYearOffsets. Source rtl/sys/SysUtils.pas:13556."

procedure GetEraNamesAndYearOffsets; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.GetEraNamesAndYearOffsets. Source rtl/sys/SysUtils.pas:13570."

function TranslateDateFormat(const FormatStr: AnsiString): AnsiString; // @ida "void __usercall $name(char * FormatStr@<eax>, char * *Result@<edx>);" @note "DCC32 MAP SysUtils.TranslateDateFormat. Source rtl/sys/SysUtils.pas:13588."

function ExceptionErrorMessage(ExceptObject: TObject; ExceptAddr: Pointer; Buffer: PAnsiChar; Size: Integer): Integer; // @ida "__int32 __userpurge $name@<eax>(TObject *ExceptObject@<eax>, void * ExceptAddr@<edx>, PAnsiChar Buffer@<ecx>, __int32 Size@<^0>);" @note "DCC32 MAP SysUtils.ExceptionErrorMessage. Source rtl/sys/SysUtils.pas:13750."

procedure ShowException(ExceptObject: TObject; ExceptAddr: Pointer); // @ida "void __usercall $name(TObject *ExceptObject@<eax>, void * ExceptAddr@<edx>);" @note "DCC32 MAP SysUtils.ShowException. Source rtl/sys/SysUtils.pas:13827."

function CreateInOutError: EInOutError; // @ida "EInOutError * __usercall $name@<eax>(void);" @note "DCC32 MAP SysUtils.CreateInOutError. Source rtl/sys/SysUtils.pas:13968."

procedure ErrorHandler(ErrorCode: Byte; ErrorAddr: Pointer); // @nameonly @note "DCC32 MAP SysUtils.ErrorHandler. Source rtl/sys/SysUtils.pas:14035. Prototype pending: RET mismatch: expected 0, native []."

function CreateAssertException(const Message, Filename: AnsiString; LineNumber: Integer): Exception; // @ida "Exception * __usercall $name@<eax>(char * Message@<eax>, char * Filename@<edx>, __int32 LineNumber@<ecx>);" @note "DCC32 MAP SysUtils.CreateAssertException. Source rtl/sys/SysUtils.pas:14065."

procedure AssertErrorHandler(const Message, Filename: AnsiString; LineNumber: Integer; ErrorAddr: Pointer); // @nameonly @note "DCC32 MAP SysUtils.AssertErrorHandler. Source rtl/sys/SysUtils.pas:14090. Prototype pending: RET mismatch: expected 4, native []."

function MapException(P: PExceptionRecord): TRuntimeError; // @ida "TRuntimeError __usercall $name@<al>(PExceptionRecord *P@<eax>);" @note "DCC32 MAP SysUtils.MapException. Source rtl/sys/SysUtils.pas:14211."

function CreateAVObject: Exception; // @nameonly @note "DCC32 MAP SysUtils.CreateAVObject. Source rtl/sys/SysUtils.pas:14256. Prototype pending: nested routine has a parent-frame parameter."

procedure GetExceptionObject; // @nameonly @note "DCC32 MAP SysUtils.GetExceptionObject. Prototype pending: no unique source declaration."

procedure InitExceptions; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.InitExceptions. Source rtl/sys/SysUtils.pas:14606."

procedure InitPlatformId; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.InitPlatformId. Source rtl/sys/SysUtils.pas:14670."

function GetFileVersion(const AFileName: AnsiString): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(char * AFileName@<eax>);" @note "DCC32 MAP SysUtils.GetFileVersion. Source rtl/sys/SysUtils.pas:14696."

function ByteTypeTest(P: PAnsiChar; Index: Integer): TMbcsByteType; // @ida "TMbcsByteType __usercall $name@<al>(PAnsiChar P@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP SysUtils.ByteTypeTest. Source rtl/sys/SysUtils.pas:14754."

function ByteType(const S: AnsiString; Index: Integer): TMbcsByteType; // @ida "TMbcsByteType __usercall $name@<al>(char * S@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP SysUtils.ByteType. Source rtl/sys/SysUtils.pas:14798."

function ByteToCharLen(const S: AnsiString; MaxLen: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(char * S@<eax>, __int32 MaxLen@<edx>);" @note "DCC32 MAP SysUtils.ByteToCharLen. Source rtl/sys/SysUtils.pas:14812."

function ByteToCharIndex(const S: AnsiString; Index: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(char * S@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP SysUtils.ByteToCharIndex. Source rtl/sys/SysUtils.pas:14818."

procedure CountChars(const S: AnsiString; MaxChars: Integer; var CharCount, ByteCount: Integer); // @ida "void __userpurge $name(char * S@<eax>, __int32 MaxChars@<edx>, __int32 *CharCount@<ecx>, __int32 *ByteCount@<^0>);" @note "DCC32 MAP SysUtils.CountChars. Source rtl/sys/SysUtils.pas:14838."

function CharToByteIndex(const S: AnsiString; Index: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(char * S@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP SysUtils.CharToByteIndex. Source rtl/sys/SysUtils.pas:14859."

function CharToByteLen(const S: AnsiString; MaxLen: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(char * S@<eax>, __int32 MaxLen@<edx>);" @note "DCC32 MAP SysUtils.CharToByteLen. Source rtl/sys/SysUtils.pas:14877."

function CharLength(const S: AnsiString; Index: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(char * S@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP SysUtils.CharLength. Source rtl/sys/SysUtils.pas:14920."

function NextCharIndex(const S: AnsiString; Index: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(char * S@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP SysUtils.NextCharIndex. Source rtl/sys/SysUtils.pas:14928."

function AnsiPos(const Substr, S: AnsiString): Integer; // @ida "__int32 __usercall $name@<eax>(char * Substr@<eax>, char * S@<edx>);" @note "DCC32 MAP SysUtils.AnsiPos. Source rtl/sys/SysUtils.pas:14973."

function AnsiLowerCaseFileName(const S: AnsiString): AnsiString; // @ida "void __usercall $name(char * S@<eax>, char * *Result@<edx>);" @note "DCC32 MAP SysUtils.AnsiLowerCaseFileName. Source rtl/sys/SysUtils.pas:14998."

function AnsiStrPos(Str, SubStr: PAnsiChar): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar Str@<eax>, PAnsiChar SubStr@<edx>);" @note "DCC32 MAP SysUtils.AnsiStrPos. Source rtl/sys/SysUtils.pas:15064."

function AnsiStrRScan(Str: PAnsiChar; Chr: Char): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar Str@<eax>, char Chr@<dl>);" @note "DCC32 MAP SysUtils.AnsiStrRScan. Source rtl/sys/SysUtils.pas:15092."

function AnsiStrScan(Str: PAnsiChar; Chr: Char): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar Str@<eax>, char Chr@<dl>);" @note "DCC32 MAP SysUtils.AnsiStrScan. Source rtl/sys/SysUtils.pas:15107."

procedure InitLeadBytes; // @nameonly @note "DCC32 MAP SysUtils.InitLeadBytes. Source rtl/sys/SysUtils.pas:15143. Prototype pending: nested routine has a parent-frame parameter."

procedure InitSysLocale; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.InitSysLocale. Source rtl/sys/SysUtils.pas:15136."

procedure GetFormatSettings; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.GetFormatSettings. Source rtl/sys/SysUtils.pas:15205."

function StringReplace(const S, OldPattern, NewPattern: AnsiString; Flags: TReplaceFlags): AnsiString; // @ida "void __userpurge $name(char * S@<eax>, char * OldPattern@<edx>, char * NewPattern@<ecx>, TReplaceFlags *Flags@<^4>, char * *Result@<^0>);" @note "DCC32 MAP SysUtils.StringReplace. Source rtl/sys/SysUtils.pas:15448."

function HashName(Name: PAnsiChar): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(PAnsiChar Name@<eax>);" @note "DCC32 MAP SysUtils.HashName. Source rtl/sys/SysUtils.pas:15697."

procedure ModuleUnloaded(Module: Cardinal); // @ida "void __usercall $name(unsigned __int32 Module@<eax>);" @note "DCC32 MAP SysUtils.ModuleUnloaded. Source rtl/sys/SysUtils.pas:15734."

procedure RaiseLastOSError; // @nameonly @note "DCC32 MAP SysUtils.RaiseLastOSError. Prototype pending: no unique source declaration."

function CallTerminateProcs: Boolean; // @ida "bool __usercall $name@<al>(void);" @note "DCC32 MAP SysUtils.CallTerminateProcs. Source rtl/sys/SysUtils.pas:16362."

procedure FreeTerminateProcs; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.FreeTerminateProcs. Source rtl/sys/SysUtils.pas:16375."

procedure InitDriveSpacePtr; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.InitDriveSpacePtr. Source rtl/sys/SysUtils.pas:16491."

procedure Supports; // @nameonly @note "DCC32 MAP SysUtils.Supports. Prototype pending: no unique source declaration."

procedure Supports_40F7B0; // @nameonly @note "DCC32 MAP SysUtils.Supports. Prototype pending: no unique source declaration."

procedure SafeLoadLibrary; // @nameonly @note "DCC32 MAP SysUtils.SafeLoadLibrary. Prototype pending: no unique source declaration."

procedure ClearHashTables; // @ida "void __usercall $name(void);" @note "DCC32 MAP SysUtils.ClearHashTables. Source rtl/sys/SysUtils.pas:17254."

procedure FinalizeSysUtils; // @nameonly @note "DCC32 MAP SysUtils.Finalization. Prototype pending: no unique source declaration."

var
  DecimalSeparator: AnsiChar; // @addr $88680B

function StrPas(const Str: PAnsiChar): AnsiString; // @addr $40ABD8 @ida "void __usercall $name(char *Str@<eax>, char **Result@<edx>);"
procedure StrDispose(Str: PAnsiChar); // @addr $40AC38

// Delphi 2007 Update 4 supplies the native locked/shared-file fallback.
function FileExists(const FileName: AnsiString): Boolean; // @addr $40A5EC
function ExistsLockedOrShared(const FileName: AnsiString): Boolean; // @addr $40A5AC @note "Private helper inside FileExists; no captured frame."

implementation
end.
