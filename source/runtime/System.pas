unit System;

interface

type
  TDateTime = Double;
  TThreadFunc = function(Parameter: Pointer): Integer;
  TSystemThreadFuncProc = function(ThreadFunc: TThreadFunc; Parameter: Pointer): Pointer;
  IInterface = interface
    function QueryInterface(const IID: TGUID; out Obj): LongInt; stdcall; // @ida "__int32 __stdcall $name(IInterface *Self, const TGUID *IID, void *Obj);"
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;
  AnsiChar = Char;
  PAnsiChar = ^AnsiChar;
  PWideChar = ^WideChar;
  PInteger = ^Integer;
  PSingle = ^Single;
  PPointer = ^Pointer;
  PBoolean = ^Boolean;
  PByte = ^Byte;
  PShortInt = ^ShortInt;
  PWord = ^Word;
  PCardinal = ^Cardinal;
  PAnsiString = ^AnsiString;
  PWideString = ^WideString;
  TObject = class;
  TClass = class of TObject;
  // Native comparison returns CPU flags; fields follow IDA's CF/ZF ordering.
  TStringComparisonFlags = packed record // @size 0x2
    Below: Boolean; // @offset 0x0
    Equal: Boolean; // @offset 0x1
  end;
  TObject = class // @size 0x04
  public
    constructor Create;
    destructor Destroy; virtual; // @addr 0x0040459C
    procedure Free; // @addr 0x004045AC @note "Accepts nil."
    class function NewInstance: TObject; virtual; // @addr 0x00404544
    class function InitInstance(Instance: Pointer): TObject; // @note "Instance must point to caller-provided storage."
    function ClassType: TClass;
    class function InstanceSize: Integer; // @addr 0x00404574
    class function InheritsFrom(Ancestor: TClass): Boolean; // @addr 0x004047D8 @note "Includes equality with the class itself."
    procedure CleanupInstance;
    procedure FreeInstance; virtual; // @addr 0x00404560
    procedure AfterConstruction; virtual; // @addr 0x00404800 @ida "void __usercall __spoils<> $name(TObject *Self@<eax>);" @note "Empty base implementation."
    procedure BeforeDestruction; virtual; // @addr 0x00404804 @ida "void __usercall __spoils<> $name(TObject *Self@<eax>);" @note "Empty base implementation."
  public
    procedure ClassName; // @nameonly
    class function ClassNameIs(const Name: AnsiString): Boolean;
    function GetInterface(const IID: TGUID; Obj: Pointer): Boolean;
    class function GetInterfaceEntry(const IID: TGUID): PInterfaceEntry;
    procedure Dispatch(Message: Pointer); // @nameonly
    procedure MethodAddress; // @nameonly
    procedure FieldAddress; // @nameonly
  end;

var
  RandSeed: Dword; // @addr 0x00809008
  Default8087CW: Word; // @addr $809024
  IsMultiThread: Boolean; // @addr $815049
  SystemThreadFuncProc: TSystemThreadFuncProc; // @addr $809038

procedure InitializeFpu; // @note "Resets x87 state and loads Default8087CW."
function ThreadWrapper(Parameter: Pointer): Integer; stdcall;
function BeginThread(SecurityAttributes: Pointer; StackSize: Cardinal; ThreadFunc: TThreadFunc; Parameter: Pointer; CreationFlags: Cardinal; var ThreadId: Cardinal): Integer;
procedure Randomize;
procedure InitializeWideStringConstants(Table: Pointer); // @note "DCC32 unit initializer: count followed by destination/source pointer pairs."
function RandomRange(Limit: Integer): Integer;
// IDA signatures use double for x87 registers; native values remain Extended.
// See docs/declarations.md#calling-conventions.
function RandomUnitExtended: Extended; // @note "Result is in [0,1); shares RandSeed with RandomRange."
function Get8087CW: Word; // @addr 0x004034B0
procedure Set8087CW(ControlWord: Word); // @addr 0x004034A0 @note "Also clears pending x87 exceptions."
function Frac(Value: Extended): Extended;
function Exp(Value: Extended): Extended;
function Cos(Value: Extended): Extended; // @addr 0x00403508
function Sin(Value: Extended): Extended; // @addr 0x00403518
function Ln(Value: Extended): Extended;
function ArcTan(Value: Extended): Extended; // @addr 0x0040353C
function Sqrt(Value: Extended): Extended; // @addr 0x0040354C
function Round(Value: Extended): Int64; // @addr 0x0040355C @ida "__int64 __usercall $name@<edx:eax>(double Value@<st0>);" @note "Uses the current x87 rounding mode, normally nearest with ties to even."
function Trunc(Value: Extended): Int64; // @ida "__int64 __usercall $name@<edx:eax>(double Value@<st0>);" @note "Independent of the current x87 rounding mode; preserves it."

function IsInstanceOf(Instance: TObject; TargetClass: TClass): Boolean; // @note "Compiler is helper; nil returns False."
function CastInstance(Instance: TObject; TargetClass: TClass): TObject; // @note "Compiler as helper; nil passes through, incompatible classes raise an invalid-cast error."
procedure RaiseExceptionObject(Instance: TObject); // @ida "void __noreturn __usercall $name(TObject *Instance@<eax>);" @note "Delphi raise helper; nil triggers runtime error 216."
function BeginClassConstruction(SelfOrClass: Pointer; ConstructionFlags: ShortInt): Pointer; // @ida "void *__usercall __spoils<eax> $name@<eax>(void *SelfOrClass@<eax>, __int8 ConstructionFlags@<dl>);" @note "Nonnegative flags allocate through NewInstance; negative flags use the supplied instance. Caller must reserve 16 writable bytes above the return address for a constructor exception frame and unlink it after successful construction."
function FinishClassConstruction(Instance: Pointer): Pointer; // @note "Invokes AfterConstruction and returns Instance; exceptions enter the constructor cleanup path. Does not unlink the caller's constructor exception frame."
procedure BeginClassDestruction(Instance: TObject; DestroyFlags: ShortInt); // @ida "void __usercall __spoils<ecx> $name(TObject *Instance@<eax>, __int8 DestroyFlags@<dl>);" @note "Invokes BeforeDestruction only for positive DestroyFlags."
procedure FreeClassInstance(Instance: TObject); // @note "Dispatches FreeInstance without invoking the destructor."
procedure InitializeTypedMemory(Storage, TypeInfo: Pointer);
function AllocateTypedMemory(ByteCount: Integer; TypeInfo: Pointer): Pointer;
function AllocateMemory(ByteCount: Integer): Pointer; // @note "Nonpositive sizes return nil; allocation failure raises."
function FreeMemory(Block: Pointer): Integer; // @note "Nil is a no-op; returns zero on success and raises on a memory-manager error."
procedure ReallocateMemory(var Block: Pointer; ByteCount: Integer); // @note "Nil allocates; zero size frees and clears the pointer."
procedure MoveBytes(Source, Dest: Pointer; ByteCount: Integer); // @note "Supports overlapping ranges; nonpositive counts do nothing."
procedure FillBytes(Dest: Pointer; ByteCount: Integer; Value: Byte); // @note "Nonpositive counts do nothing."
procedure _SetExpand(Source, Dest: Pointer; ByteRange: Word); // @addr 0x00404068 @note "Expands a packed set to 32 bytes. EAX source, EDX destination; CL first source-byte index, CH exclusive end. RTL System.pas:7598 and native instructions agree."
procedure _SetElem(Dest: Pointer; Element, ByteCount: Byte); // @addr 0x00403FEC @note "DCC32 singleton-set helper. Clears ByteCount bytes, then sets Element when in range. RTL System.pas:7337; native EAX/DL/CL ABI."

function AnsiStringToPAnsiChar(Value: AnsiString): PAnsiChar; // @addr 0x0040592C @note "Nil maps to a static empty string."
function RetainAnsiString(Value: AnsiString): AnsiString; // @ida "char *__usercall $name@<eax>(char *Value@<eax>);" @note "Compiler parameter-retention helper; EAX is the string value, not a var-parameter address. Returns it unchanged."
function AnsiStringLength(Value: AnsiString): Integer;
function StringOfChar(Value: AnsiChar; Count: Integer): AnsiString; // @addr $405C20 @note "Nonpositive Count returns an empty string."
procedure SetAnsiStringFromArray(var Dest: AnsiString; Source: PAnsiChar; CharCount: Integer); // @note "Stops at NUL or CharCount, whichever comes first."
procedure ClearAnsiString(var Value: AnsiString);
procedure ClearAnsiStrings(Values: PAnsiString; Count: Integer); // @note "Count must be positive."
procedure AssignAnsiString(var Dest: AnsiString; Source: AnsiString); // @note "Copies constant strings rather than retaining them."
function AllocateAnsiStringBuffer(CharCount: Integer): PAnsiChar; // @note "Returns character storage with a preceding length/refcount header; initial refcount is 1. Nonpositive lengths return nil."
procedure SetAnsiStringFromBuffer(var Dest: AnsiString; Source: PAnsiChar; CharCount: Integer);
procedure SetAnsiStringFromWideBuffer(var Dest: AnsiString; Source: PWideChar; CharCount: Integer); // @note "Converts through the RTL's current ANSI code page."
procedure SetAnsiStringFromPAnsiChar(var Dest: AnsiString; Source: PAnsiChar);
procedure SetAnsiStringFromPWideChar(var Dest: AnsiString; Source: PWideChar);
procedure WideCharToStrVar(Source: PWideChar; var Dest: AnsiString);
function WideCharToString(Source: PWideChar): AnsiString;
procedure ConvertShortStringToAnsiString(var Dest: AnsiString; Source: Pointer); // @note "EDX addresses a length-prefixed ShortString; tail-calls SetAnsiStringFromBuffer. RTL System.pas:12743 and native instructions agree."
procedure ConvertShortStringToWideString(var Dest: WideString; Source: Pointer); // @note "EDX addresses a length-prefixed ShortString; tail-calls SetWideStringFromAnsiBuffer. RTL System.pas:14257."
procedure ConvertWideStringToAnsiString(var Dest: AnsiString; Source: WideString);
procedure AppendAnsiString(var Dest: AnsiString; Source: AnsiString); // @addr 0x00405768
procedure ConcatAnsiStrings(var Dest: AnsiString; Left, Right: AnsiString);
procedure ConcatManyAnsiStrings(var Dest: AnsiString; Count: Integer); // @ida "void __usercall $name(char **Dest@<eax>, int Count@<edx>, ...);" @countedstack "Count:AnsiString" @note "Compiler helper for at least two strings. Count additional AnsiStrings are pushed left to right and removed by the callee. Sources may alias Dest."
procedure SetAnsiStringLength(var Value: AnsiString; CharCount: Integer); // @note "Preserves the existing prefix; nonpositive lengths clear the string."
function AnsiStringPos(Needle, Haystack: AnsiString): Integer; // @note "Case-sensitive, one-based index; zero for no match or an empty needle."

function WideStringToPWideChar(Value: WideString): PWideChar; // @addr 0x00405F10 @note "Nil maps to a static empty string."
function WideStringLength(Value: WideString): Integer;
function WideStringPos(Needle, Haystack: WideString): Integer; // @note "Case-sensitive, one-based index; zero for no match or an empty needle."
procedure CloneWideStringParameter(var Value: WideString); // @note "Does not free the original borrowed BSTR; raises on allocation failure."
procedure ClearWideString(var Value: WideString);
procedure ClearWideStrings(Values: PWideString; Count: Integer); // @note "Count must be positive."
procedure AssignWideString(var Dest: WideString; Source: WideString);
procedure AssignWideStringAlias(var Dest: WideString; Source: WideString);
function AllocateWideStringBuffer(CharCount: Integer): PWideChar; // @note "Allocates a BSTR without initializing its characters; zero returns nil, allocation failure raises."
procedure AdoptWideStringBuffer(var Dest: WideString; Buffer: PWideChar); // @note "Takes ownership without copying; Buffer must not alias Dest's current value."
procedure SetWideStringFromBuffer(var Dest: WideString; Source: PWideChar; CharCount: Integer);
procedure SetWideStringFromPAnsiChar(var Dest: WideString; Source: PAnsiChar); // @addr $405E54
procedure SetWideStringFromWideArray(var Dest: WideString; Source: PWideChar; MaxChars: Integer); // @note "Bounds the NUL scan by MaxChars, then tail-calls SetWideStringFromBuffer. RTL System.@WStrFromWArray."
procedure SetWideStringFromPWideChar(var Dest: WideString; Source: PWideChar);
procedure SetWideStringFromChar(var Dest: WideString; Value: WideChar);
function CopyWideString(Source: WideString; Index, Count: Integer): WideString; // @note "One-based Index is clamped to the source; negative Count produces an empty string."
procedure DeleteWideString(var Value: WideString; Index, Count: Integer);
procedure SetWideStringFromAnsiBuffer(var Dest: WideString; Source: PAnsiChar; CharCount: Integer); // @note "Converts through the RTL's current ANSI code page."
procedure SetWideStringFromAnsiArray(var Dest: WideString; Source: PAnsiChar; Capacity: Integer); // @note "Scans up to Capacity bytes for NUL, then tail-calls SetWideStringFromAnsiBuffer. RTL System.@WStrFromArray ($405ECC)."
procedure ConvertAnsiStringToWideString(var Dest: WideString; Source: AnsiString);
procedure AppendWideString(var Dest: WideString; Source: WideString);
procedure ConcatWideStrings(var Dest: WideString; Left, Right: WideString);
procedure ConcatManyWideStrings(var Dest: WideString; Count: Integer); // @ida "void __usercall $name(unsigned __int16 **Dest@<eax>, int Count@<edx>, ...);" @countedstack "Count:WideString" @note "Count must be positive; Count additional WideStrings are pushed left to right and removed by the callee. Sources may alias Dest."
function CompareWideStrings(Left, Right: WideString): TStringComparisonFlags; // @ida "TStringComparisonFlags __usercall $name@<zf:cf>(unsigned __int16 *Left@<eax>, unsigned __int16 *Right@<edx>);" @note "Case-sensitive UTF-16 ordering; nil equals empty. Equal is ZF and Below is CF; EAX is not a comparison result."
procedure SetWideStringLength(var Value: WideString; CharCount: Integer); // @note "Nonpositive lengths clear the string; retained characters are preserved."
procedure AddRefInterface(const Value: IInterface);
procedure ClearInterface(var Value: IInterface);
procedure AssignInterface(var Dest: IInterface; Source: IInterface);

function DynamicArrayLength(Value: Pointer): Integer; // @ida "int __usercall __spoils<eax> $name@<eax>(void *Value@<eax>);" @note "Nil has length zero; Value points to the first element, after the reference-count and length header."
function DynamicArrayHigh(Value: Pointer): Integer; // @ida "int __usercall __spoils<eax> $name@<eax>(void *Value@<eax>);" @note "Nil returns -1."
procedure SetDynamicArrayLength(var Value: Pointer; TypeInfo: Pointer; DimensionCount: Integer); // @ida "void __usercall $name(void **Value@<eax>, void *TypeInfo@<edx>, int DimensionCount@<ecx>, ...);" @countedstack "DimensionCount:Integer:caller" @note "Requires dynamic-array RTTI and a positive DimensionCount. Additional stack arguments are dimension lengths, with the first dimension nearest the return address; the caller removes them."
procedure SetDynamicArrayLengthFromVector(var Value: Pointer; TypeInfo: Pointer; DimensionCount: Integer; Lengths: PInteger); // @note "Lengths contains DimensionCount nonnegative values. Resizing to a positive length detaches shared storage and zeroes added elements; zero clears the array. Requires dynamic-array RTTI."
procedure ClearDynamicArray(var Value: Pointer; TypeInfo: Pointer); // @ida "void __usercall __spoils<edx,ecx> $name(void **Value@<eax>, void *TypeInfo@<edx>);" @note "Sets Value to nil and releases its reference; finalizes elements and frees storage only at the last reference. Requires dynamic-array RTTI."
procedure FinalizeManagedArray(Data, TypeInfo: Pointer; Count: Integer); // @ida "void __usercall __spoils<edx,ecx> $name(void *Data@<eax>, void *TypeInfo@<edx>, int Count@<ecx>);" @note "Requires managed-type RTTI and a nonnegative Count; retains the outer storage."

type
  TTextRec = packed record // @size 460
    Handle: Integer; // @offset 0
    Mode: Word; // @offset 4
    Flags: Word; // @offset 6
    BufSize: Cardinal; // @offset 8
    BufPos: Cardinal; // @offset 12
    BufEnd: Cardinal; // @offset 16
    BufPtr: PAnsiChar; // @offset 20
    OpenFunc: Pointer; // @offset 24
    InOutFunc: Pointer; // @offset 28
    FlushFunc: Pointer; // @offset 32
    CloseFunc: Pointer; // @offset 36
    UserData: array[1..32] of Byte; // @offset 40
    Name: array[0..259] of Char; // @offset 72
    Buffer: array[0..127] of Char; // @offset 332
  end;
  TextFile = TTextRec;

  // Common TVarRec storage; VType selects the interpretation of the first four bytes.
  TVarRec = record // @size 8
    VInteger: Integer; // @offset 0
    VType: Byte; // @offset 4
  end;
  TGUID = record // @size 16
    D1: Cardinal; // @offset 0
    D2: Word; // @offset 4
    D3: Word; // @offset 6
    D4: array[0..7] of Byte; // @offset 8
  end;

  TInterfaceEntry = record;

  PInterfaceEntry = ^TInterfaceEntry;

  PExceptionRecord = record;

  TLibModule = record;

  PLibModule = ^TLibModule;

  TResStringRec = record;

  PResStringRec = ^TResStringRec;

  TRuntimeError = (reNone, reOutOfMemory, reInvalidPtr, reDivByZero, reRangeError, reIntOverflow, reInvalidOp, reZeroDivide, reOverflow, reUnderflow, reInvalidCast, reAccessViolation, rePrivInstruction, reControlBreak, reStackOverflow, reVarTypeCast, reVarInvalidOp, reVarDispatch, reVarArrayCreate, reVarNotArray, reVarArrayBounds, reAssertionFailed, reExternalException, reIntfCastError, reSafeCallError , reQuit, reCodesetConversion ); // @size 0x1

  TInterfacedObject = class(TObject) // @size 0xC
  end;

  TVarData = record;

  TVarOp = Integer;

  TMethod = record;

  PLongint = ^Longint;

function GetCmdShow: Integer;

procedure Move12; // @nameonly

procedure Move20; // @nameonly

procedure Move28; // @nameonly

procedure Move36; // @nameonly

procedure Move44; // @nameonly

procedure Move52; // @nameonly

procedure Move60; // @nameonly

procedure Move68; // @nameonly

procedure MoveX16L4; // @nameonly

procedure MoveX8L4; // @nameonly

procedure InsertMediumBlockIntoBin; // @nameonly

procedure AllocNewSequentialFeedMediumPool; // @nameonly

procedure LockLargeBlocks; // @nameonly

procedure AllocateLargeBlock; // @nameonly

procedure FreeLargeBlock; // @nameonly

procedure ReallocateLargeBlock; // @nameonly

function SysGetMem(Size: Integer): Pointer;

function SysFreeMem(P: Pointer): Integer;

function SysReallocMem(P: Pointer; Size: Integer): Pointer;

procedure SysAllocMem; // @nameonly

procedure NextMediumBlock; // @nameonly

procedure GetFirstMediumBlockInPool; // @nameonly

procedure GetFirstAndLastSmallBlockInPool; // @nameonly

procedure CardinalToStrBuf; // @nameonly

procedure AppendStringToBuffer; // @nameonly

procedure IsValidVMTAddress; // @nameonly

procedure InternalIsValidClass; // @nameonly

procedure GetObjectClass; // @nameonly

procedure LockExpectedMemoryLeaksList; // @nameonly

procedure SysRegisterExpectedMemoryLeak; // @nameonly

procedure SysUnregisterExpectedMemoryLeak; // @nameonly

procedure CheckSmallBlockPoolForLeaks; // @nameonly

procedure ScanForMemoryLeaks; // @nameonly

procedure BuildBlockTypeLookupTable; // @nameonly

procedure InitializeMemoryManager; // @nameonly

procedure FreeAllMemory; // @nameonly

procedure FinalizeMemoryManager; // @nameonly

function AllocMem(Size: Cardinal): Pointer;

procedure ExceptObject; // @nameonly

procedure ExceptAddr; // @nameonly

procedure AcquireExceptionObject; // @nameonly

procedure ErrorAt(ErrorCode: Byte; ErrorAddr: Pointer); // @nameonly

procedure __IOTest; // @nameonly

procedure _Copy; // @nameonly

procedure _LGetDir(D: Byte; var S: AnsiString); // @nameonly

function IOResult: Integer;

function GetParamStr(P: PAnsiChar; var Param: AnsiString): PAnsiChar;

function ParamCount: Integer;

function ParamStr(Index: Integer): AnsiString;

function OpenText(var t: TTextRec; Mode: Word): Integer;
function AssignTextFile(var t: TTextRec; const FileName: AnsiString): Integer; // @addr $40387C
function ResetTextFile(var t: TTextRec): Integer; // @addr $403600 @note "Compiler Reset(TextFile), RTL System._ResetText."
function EndOfTextFile(var t: TTextRec): Boolean; // @addr $403AE8 @note "Compiler Eof(TextFile); respects Ctrl-Z when enabled in the text flags."
procedure ReadAnsiText(var t: TTextRec; var Text: AnsiString); // @addr $403CF0 @note "Compiler Read(TextFile, AnsiString); leaves the line ending unread."
procedure ReadTextLineEnd(var t: TTextRec); // @addr $403D5C @note "Compiler Readln tail consumes the remainder of the line."
procedure ConvertPAnsiCharToShortString(Dest: Pointer; Source: PAnsiChar); // @addr $403FBC @note "Compiler CStrToPasStr: EAX points to a 256-byte ShortString, EDX to NUL-terminated text; caps at 255 characters."
function RewriteTextFile(var t: TTextRec): Integer; // @addr $40360C
function AppendText(var t: TTextRec): Integer;
function FlushText(var t: TextFile): Integer;
function WriteAnsiText(var t: TTextRec; const Text: AnsiString): Pointer;
function WritePaddedAnsiText(var t: TTextRec; const Text: AnsiString; Width: Integer): Pointer;
function WriteWideText(var t: TTextRec; const Text: WideString): Pointer; // @addr $405C74 @note "Compiler Write(TextFile, WideString), System.@Write0WString."
function WritePaddedWideText(var t: TTextRec; const Text: WideString; Width: Integer): Pointer; // @addr $405C7C @note "Compiler padded WideString text output, System.@WriteWString."

function TextIn(var t: TTextRec): Integer;

function TextOut(var t: TTextRec): Integer;

function TextClose(var t: TTextRec): Integer;

procedure TextOpen; // @nameonly

procedure InternalFlush; // @nameonly

function _Close(var t: TTextRec): Integer; // @addr $403944 @note "Compiler CloseFile; EAX addresses the file record and returns the RTL status. Native registers agree with System.pas:4906."

procedure PStrCpy(Dest, Source: Pointer); // @addr $4039CC DCC32 System.@PStrCpy; copies Source[0]+1 bytes, including the short-string length byte.
procedure PStrNCat(Dest, Source: Pointer; MaximumLength: Byte); // @addr $40399C DCC32 System.@PStrNCat; appends a length-prefixed short string with CL as the capacity.

procedure PStrNCpy; // @nameonly

procedure _PStrCmp; // @nameonly

procedure _AStrCmp; // @nameonly

function _ValLong(const s: AnsiString; var code: Integer): Longint; // @nameonly

function TryOpenForOutput(var t: TTextRec): Boolean;

function _WriteBytes(var t: TTextRec; b: Pointer; cnt: Longint): Pointer; // @nameonly

function _WriteSpaces(var t: TTextRec; cnt: Longint): Pointer; // @nameonly

function _WriteLn(var t: TTextRec): Pointer; // @nameonly

procedure _CLenToPasStr; // @nameonly

procedure _Pow10; // @nameonly

function _isNECWindows: Boolean; // @nameonly

procedure _FpuMaskInit; // @nameonly

function InvokeImplGetter(Self: TObject; ImplGetter: Cardinal): IInterface; // @nameonly

procedure GetDynaMethod;

procedure NotifyReRaise;

procedure NotifyNonDelphiException;

procedure CheckJmp;

procedure NotifyExceptFinally;

procedure NotifyTerminate;

procedure NotifyUnhandled;

procedure _HandleAnyException; // @nameonly

procedure _HandleOnException; // @addr 0x00404BB8 @nameonly @note "DCC32 typed-exception dispatch through an inline class/handler table; shared runtime code, not part of each caller's body."

procedure _HandleFinally; // @nameonly

procedure HandleFinallyInternal; // @nameonly

procedure _RaiseAgain; // @ida "void __noreturn __usercall $name(void);" @note "Reraises the active exception; consumes the runtime exception frame."

procedure _DoneExcept; // @nameonly

procedure _TryFinallyExit(PreviousFrame, Handler, SavedFrame: Pointer); stdcall; // @addr $404ECC @note "Compiler helper: unlinks the current exception frame, calls Handler+5, and removes the three frame words. The arguments are the existing SEH frame, not newly pushed source arguments."

procedure MapToRunError(P: PExceptionRecord); // @nameonly

procedure _ExceptionHandler; // @nameonly

procedure SetExceptionHandler;

procedure UnsetExceptionHandler;

procedure FinalizeUnits;

procedure InitUnits;

procedure StartExe; // @nameonly

procedure _InitResStringImports; // @nameonly

procedure _InitImports; // @nameonly

procedure MakeErrorMessage;

procedure ExitDll; // @nameonly

procedure WriteErrorMessage;

procedure _Halt0; // @ida "void __noreturn __usercall $name();" @note "Compiler program termination: finalizes units and exits the process. RTL System._Halt0, no parameters."

procedure AssignAnsiStringAlias(var Dest: AnsiString; Source: AnsiString); // @note "DCC32 System.@LStrLAsg: retains Source, replaces Dest and releases its previous storage."

procedure CharFromWChar; // @nameonly

procedure WCharFromChar; // @nameonly

procedure _LStrToString; // @nameonly

function CompareAnsiStrings(Left, Right: AnsiString): TStringComparisonFlags; // @ida "TStringComparisonFlags __usercall $name@<zf:cf>(char *Left@<eax>, char *Right@<edx>);" @note "System.@LStrCmp returns unsigned byte-string ordering in ZF and CF; nil equals empty."

function InternalUniqueString(str: Pointer): Pointer;

procedure _LStrCopy; // @nameonly

procedure _LStrDelete; // @nameonly

procedure _LStrInsert; // @nameonly

procedure _InitializeArray(p: Pointer; typeInfo: Pointer; elemCount: Cardinal); // @nameonly

procedure InitializeRecord(Data, TypeInfo: Pointer); // @addr $406258 @note "System.@InitializeRecord: visits managed fields described by record RTTI."
procedure _FinalizeRecord(p: Pointer; typeInfo: Pointer); // @note "System.@FinalizeRecord: finalizes managed fields described by record RTTI; EAX retains the record address."
procedure _Dispose(Data, TypeInfo: Pointer); // @addr $4067B4 @note "System.@Dispose: finalizes a managed record, then frees its allocation."

procedure AddRefRecord(Data, TypeInfo: Pointer); // @addr $40646C @note "System.@AddRefRecord: retains each managed field in a copied record using RTTI and AddRefArray."

procedure _CopyRecord; // @nameonly

procedure _CopyArray; // @nameonly

procedure __llmul; // @nameonly
function ShiftLeftInt64(Value: Int64; Count: Integer): Int64; // @ida "__int64 __usercall $name@<edx:eax>(__int64 Value@<edx:eax>, int Count@<ecx>);"
function ShiftRightInt64(Value: Int64; Count: Integer): Int64; // @ida "__int64 __usercall $name@<edx:eax>(__int64 Value@<edx:eax>, int Count@<ecx>);"
function DivideInt64(Dividend, Divisor: Int64): Int64; // @ida "__int64 __userpurge $name@<edx:eax>(__int64 Dividend@<edx:eax>, __int64 Divisor@<^0>);"
function Int64Remainder(Dividend, Divisor: Int64): Int64; // @ida "__int64 __userpurge $name@<edx:eax>(__int64 Dividend@<edx:eax>, __int64 Divisor@<^0>);" @note "Signed Int64 remainder, RTL System.__llmod. Divisor is stack-passed; callee pops eight bytes. Sign follows dividend."

function __lludiv(Dividend, Divisor: UInt64): UInt64; // @addr $406894 @ida "unsigned __int64 __userpurge $name@<edx:eax>(unsigned __int64 Dividend@<edx:eax>, unsigned __int64 Divisor@<^0>);" @note "Unsigned 64-bit division; numerator in EDX:EAX, divisor on stack, RET 8."

function _ValInt64(const s: AnsiString; var code: Integer): Int64; // @nameonly

procedure _DynArrayCopyRange(a: Pointer; typeInfo: Pointer; index, count: Integer; var Result: Pointer); // @nameonly

procedure _DynArrayAsg; // @nameonly

function FindHInstance(Address: Pointer): Cardinal;

function DelayLoadResourceModule(Module: PLibModule): Cardinal;

function FindResourceHInstance(Instance: Cardinal): Cardinal;

function FindBS(Current: PAnsiChar): PAnsiChar; // @nameonly

function ToLongPath(AFileName: PAnsiChar; BufSize: Integer): PAnsiChar; // @nameonly

function LoadResourceModule(ModuleName: PAnsiChar; CheckOwner: Boolean): Cardinal;

procedure RemoveModuleUnloadProc; // @nameonly

procedure NotifyModuleUnload(HInstance: Cardinal);

procedure UnregisterModule(LibModule: PLibModule);

procedure _IntfCast(var Dest: IInterface; const Source: IInterface; const IID: TGUID); // @nameonly

procedure UnicodeToUtf8; // @nameonly

procedure Utf8ToUnicode; // @nameonly

function UTF8Encode(const WS: WideString): AnsiString;

function UTF8Decode(const S: AnsiString): WideString;

function AnsiToUtf8(const S: AnsiString): AnsiString;

procedure LoadResString; // @nameonly

procedure FinalizeSystem; // @nameonly

procedure SetRange; // @addr 0x00404010 @nameonly @note "DCC32 set-range helper: AL lower bound, DL upper bound, AH storage bytes, ECX destination. Compiler intrinsic, not an ordinary Pascal-call ABI."

procedure SetAnsiStringFromWideChar(var Dest: AnsiString; Source: WideChar);
procedure SetAnsiStringFromChar(var Dest: AnsiString; Source: Char);
procedure SetWideStringFromAnsiChar(var Dest: WideString; Source: AnsiChar);

var
  RaiseExceptionProc: Pointer; // @addr $815014 RTL hook, called with the Windows RaiseException stdcall ABI.
  HInstance: Cardinal; // @addr $8177F4
  DefaultTextLineBreakStyle: Byte; // @addr $809034 @note "RTL TTextLineBreakStyle ordinal: LF=0, CRLF=1."

implementation
end.
