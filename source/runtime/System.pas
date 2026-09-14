unit System;
// Unit bracket (inferred): .text 0x004010EC..0x00407AF0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00875000..0x00875000; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    constructor Create; // @ida "TObject *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; virtual; // @addr 0x40459C @ida "void __usercall $name(TObject *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Free; // @addr 0x4045AC @note "Accepts nil."
    class function NewInstance: TObject; virtual; // @addr 0x404544
    class function InitInstance(Instance: Pointer): TObject; // @note "Instance must point to caller-provided storage."
    function ClassType: TClass;
    class function InstanceSize: Integer; // @addr 0x404574
    class function InheritsFrom(Ancestor: TClass): Boolean; // @addr 0x4047D8 @note "Includes equality with the class itself."
    procedure CleanupInstance;
    procedure FreeInstance; virtual; // @addr 0x404560
    procedure AfterConstruction; virtual; // @addr 0x404800 @ida "void __usercall __spoils<> $name(TObject *Self@<eax>);" @note "Empty base implementation."
    procedure BeforeDestruction; virtual; // @addr 0x404804 @ida "void __usercall __spoils<> $name(TObject *Self@<eax>);" @note "Empty base implementation."
  public
    procedure ClassName; // @nameonly @note "DCC32 MAP System.TObject.ClassName. Source rtl/sys/System.pas:8714. Prototype pending: source type not found: ShortString."
    class function ClassNameIs(const Name: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(void *Self@<eax>, char * Name@<edx>);" @note "DCC32 MAP System.TObject.ClassNameIs. Source rtl/sys/System.pas:8736."
    function GetInterface(const IID: TGUID; Obj: Pointer): Boolean; // @ida "bool __usercall $name@<al>(TObject *Self@<eax>, TGUID *IID@<edx>, void * Obj@<ecx>);" @note "DCC32 MAP System.TObject.GetInterface. Source rtl/sys/System.pas:8992."
    class function GetInterfaceEntry(const IID: TGUID): PInterfaceEntry; // @ida "PInterfaceEntry __usercall $name@<eax>(void *Self@<eax>, TGUID *IID@<edx>);" @note "DCC32 MAP System.TObject.GetInterfaceEntry. Source rtl/sys/System.pas:9011."
    procedure Dispatch(Message: Pointer); // @nameonly @note "DCC32 MAP System.TObject.Dispatch. Source rtl/sys/System.pas:9274. Prototype pending: RET mismatch: expected 0, native []."
    procedure MethodAddress; // @nameonly @note "DCC32 MAP System.TObject.MethodAddress. Source rtl/sys/System.pas:9298. Prototype pending: source type not found: ShortString."
    procedure FieldAddress; // @nameonly @note "DCC32 MAP System.TObject.FieldAddress. Source rtl/sys/System.pas:9404. Prototype pending: source type not found: ShortString."
  end;

var
  RandSeed: Dword; // @addr 0x878008
  Default8087CW: Word; // @addr $878024
  IsMultiThread: Boolean; // @addr $884049
  SystemThreadFuncProc: TSystemThreadFuncProc; // @addr $878038

procedure InitializeFpu; // @note "Resets x87 state and loads Default8087CW."
function ThreadWrapper(Parameter: Pointer): Integer; stdcall;
function BeginThread(SecurityAttributes: Pointer; StackSize: Cardinal; ThreadFunc: TThreadFunc; Parameter: Pointer; CreationFlags: Cardinal; var ThreadId: Cardinal): Integer;
procedure Randomize;
procedure InitializeWideStringConstants(Table: Pointer); // @note "DCC32 unit initializer: count followed by destination/source pointer pairs."
function RandomRange(Limit: Integer): Integer;
// IDA signatures use double for x87 registers; native values remain Extended. See README.
function RandomUnitExtended: Extended; // @ida "double __usercall $name@<st0>(void);" @note "Result is in [0,1); shares RandSeed with RandomRange."
function Get8087CW: Word; // @addr 0x4034B0
procedure Set8087CW(ControlWord: Word); // @addr 0x4034A0 @note "Also clears pending x87 exceptions."
function Frac(Value: Extended): Extended; // @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function Exp(Value: Extended): Extended; // @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function Cos(Value: Extended): Extended; // @addr 0x403508 @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function Sin(Value: Extended): Extended; // @addr 0x403518 @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function Ln(Value: Extended): Extended; // @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function ArcTan(Value: Extended): Extended; // @addr 0x40353C @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function Sqrt(Value: Extended): Extended; // @addr 0x40354C @ida "double __userpurge $name@<st0>(_TBYTE Value@<^0>);"
function Round(Value: Extended): Int64; // @addr 0x40355C @ida "__int64 __usercall $name@<edx:eax>(double Value@<st0>);" @note "Uses the current x87 rounding mode, normally nearest with ties to even."
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
procedure _SetExpand(Source, Dest: Pointer; ByteRange: Word); // @addr 0x404068 @note "Expands a packed set to 32 bytes. EAX source, EDX destination; CL first source-byte index, CH exclusive end. RTL System.pas:7598 and native instructions agree."
procedure _SetElem(Dest: Pointer; Element, ByteCount: Byte); // @addr 0x403FEC @note "DCC32 singleton-set helper. Clears ByteCount bytes, then sets Element when in range. RTL System.pas:7337; native EAX/DL/CL ABI verified."

function AnsiStringToPAnsiChar(Value: AnsiString): PAnsiChar; // @addr 0x40592C @note "Nil maps to a static empty string."
function RetainAnsiString(Value: AnsiString): AnsiString; // @ida "char *__usercall $name@<eax>(char *Value@<eax>);" @note "Compiler parameter-retention helper; EAX is the string value, not a var-parameter address. Returns it unchanged."
function AnsiStringLength(Value: AnsiString): Integer;
function StringOfChar(Value: AnsiChar; Count: Integer): AnsiString; // @addr $405C20 @ida "void __usercall $name(char Value@<al>, int Count@<edx>, char **Result@<ecx>);" @note "Verified 42-byte RTL body: ClearAnsiString, AllocateAnsiStringBuffer, FillBytes; nonpositive Count returns empty."
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
function WideCharToString(Source: PWideChar): AnsiString; // @ida "void __usercall $name(unsigned __int16 *Source@<eax>, char **Result@<edx>);"
procedure ConvertShortStringToAnsiString(var Dest: AnsiString; Source: Pointer); // @note "EDX addresses a length-prefixed ShortString; tail-calls SetAnsiStringFromBuffer. RTL System.pas:12743 and native instructions agree."
procedure ConvertShortStringToWideString(var Dest: WideString; Source: Pointer); // @note "EDX addresses a length-prefixed ShortString; tail-calls SetWideStringFromAnsiBuffer. RTL System.pas:14257."
procedure ConvertWideStringToAnsiString(var Dest: AnsiString; Source: WideString);
procedure AppendAnsiString(var Dest: AnsiString; Source: AnsiString); // @addr 0x405768
procedure ConcatAnsiStrings(var Dest: AnsiString; Left, Right: AnsiString);
procedure ConcatManyAnsiStrings(var Dest: AnsiString; Count: Integer); // @ida "void __usercall $name(char **Dest@<eax>, int Count@<edx>, ...);" @countedstack "Count:AnsiString" @note "Compiler helper for at least two strings. Count additional AnsiStrings are pushed left to right and removed by the callee. Sources may alias Dest."
procedure SetAnsiStringLength(var Value: AnsiString; CharCount: Integer); // @note "Preserves the existing prefix; nonpositive lengths clear the string."
function AnsiStringPos(Needle, Haystack: AnsiString): Integer; // @note "Case-sensitive, one-based index; zero for no match or an empty needle."

function WideStringToPWideChar(Value: WideString): PWideChar; // @addr 0x405F10 @note "Nil maps to a static empty string."
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
procedure SetWideStringFromWideArray(var Dest: WideString; Source: PWideChar; MaxChars: Integer); // @note "Bounds the NUL scan by MaxChars, then tail-calls SetWideStringFromBuffer. Verified via fLoadRobot.RebuildEntries. RTL System.@WStrFromWArray."
procedure SetWideStringFromPWideChar(var Dest: WideString; Source: PWideChar);
procedure SetWideStringFromChar(var Dest: WideString; Value: WideChar);
function CopyWideString(Source: WideString; Index, Count: Integer): WideString; // @ida "void __userpurge $name(unsigned __int16 *Source@<eax>, int Index@<edx>, int Count@<ecx>, unsigned __int16 **Result@<^0>);" @note "One-based Index is clamped to the source; negative Count produces an empty string."
procedure DeleteWideString(var Value: WideString; Index, Count: Integer);
procedure SetWideStringFromAnsiBuffer(var Dest: WideString; Source: PAnsiChar; CharCount: Integer); // @note "Converts through the RTL's current ANSI code page."
procedure SetWideStringFromAnsiArray(var Dest: WideString; Source: PAnsiChar; Capacity: Integer); // @note "Scans up to Capacity bytes for NUL, then tail-calls SetWideStringFromAnsiBuffer. Verified against DCC32 @WStrFromArray at $405ECC."
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

function GetCmdShow: Integer; // @ida "__int32 __usercall $name@<eax>(void);" @note "DCC32 MAP System.GetCmdShow. Source rtl/sys/System.pas:2483."

procedure Move12; // @nameonly @note "DCC32 MAP System.Move12. Prototype pending: no unique source declaration."

procedure Move20; // @nameonly @note "DCC32 MAP System.Move20. Prototype pending: no unique source declaration."

procedure Move28; // @nameonly @note "DCC32 MAP System.Move28. Prototype pending: no unique source declaration."

procedure Move36; // @nameonly @note "DCC32 MAP System.Move36. Prototype pending: no unique source declaration."

procedure Move44; // @nameonly @note "DCC32 MAP System.Move44. Prototype pending: no unique source declaration."

procedure Move52; // @nameonly @note "DCC32 MAP System.Move52. Prototype pending: no unique source declaration."

procedure Move60; // @nameonly @note "DCC32 MAP System.Move60. Prototype pending: no unique source declaration."

procedure Move68; // @nameonly @note "DCC32 MAP System.Move68. Prototype pending: no unique source declaration."

procedure MoveX16L4; // @nameonly @note "DCC32 MAP System.MoveX16L4. Prototype pending: no unique source declaration."

procedure MoveX8L4; // @nameonly @note "DCC32 MAP System.MoveX8L4. Prototype pending: no unique source declaration."

procedure InsertMediumBlockIntoBin; // @nameonly @note "DCC32 MAP System.InsertMediumBlockIntoBin. Prototype pending: no unique source declaration."

procedure AllocNewSequentialFeedMediumPool; // @nameonly @note "DCC32 MAP System.AllocNewSequentialFeedMediumPool. Prototype pending: no unique source declaration."

procedure LockLargeBlocks; // @nameonly @note "DCC32 MAP System.LockLargeBlocks. Prototype pending: no unique source declaration."

procedure AllocateLargeBlock; // @nameonly @note "DCC32 MAP System.AllocateLargeBlock. Prototype pending: no unique source declaration."

procedure FreeLargeBlock; // @nameonly @note "DCC32 MAP System.FreeLargeBlock. Prototype pending: no unique source declaration."

procedure ReallocateLargeBlock; // @nameonly @note "DCC32 MAP System.ReallocateLargeBlock. Prototype pending: no unique source declaration."

function SysGetMem(Size: Integer): Pointer; // @ida "void * __usercall $name@<eax>(__int32 Size@<eax>);" @note "DCC32 MAP System.SysGetMem. Source rtl/sys/System.pas:2510."

function SysFreeMem(P: Pointer): Integer; // @ida "__int32 __usercall $name@<eax>(void * P@<eax>);" @note "DCC32 MAP System.SysFreeMem. Source rtl/sys/System.pas:2515."

function SysReallocMem(P: Pointer; Size: Integer): Pointer; // @ida "void * __usercall $name@<eax>(void * P@<eax>, __int32 Size@<edx>);" @note "DCC32 MAP System.SysReallocMem. Source rtl/sys/System.pas:2521."

procedure SysAllocMem; // @nameonly @note "DCC32 MAP System.SysAllocMem. Prototype pending: no unique source declaration."

procedure NextMediumBlock; // @nameonly @note "DCC32 MAP System.NextMediumBlock. Prototype pending: no unique source declaration."

procedure GetFirstMediumBlockInPool; // @nameonly @note "DCC32 MAP System.GetFirstMediumBlockInPool. Prototype pending: no unique source declaration."

procedure GetFirstAndLastSmallBlockInPool; // @nameonly @note "DCC32 MAP System.GetFirstAndLastSmallBlockInPool. Prototype pending: no unique source declaration."

procedure CardinalToStrBuf; // @nameonly @note "DCC32 MAP System.CardinalToStrBuf. Prototype pending: no unique source declaration."

procedure AppendStringToBuffer; // @nameonly @note "DCC32 MAP System.AppendStringToBuffer. Prototype pending: no unique source declaration."

procedure IsValidVMTAddress; // @nameonly @note "DCC32 MAP System.IsValidVMTAddress. Prototype pending: no unique source declaration."

procedure InternalIsValidClass; // @nameonly @note "DCC32 MAP System.InternalIsValidClass. Prototype pending: no unique source declaration."

procedure GetObjectClass; // @nameonly @note "DCC32 MAP System.GetObjectClass. Prototype pending: no unique source declaration."

procedure LockExpectedMemoryLeaksList; // @nameonly @note "DCC32 MAP System.LockExpectedMemoryLeaksList. Prototype pending: no unique source declaration."

procedure SysRegisterExpectedMemoryLeak; // @nameonly @note "DCC32 MAP System.SysRegisterExpectedMemoryLeak. Prototype pending: no unique source declaration."

procedure SysUnregisterExpectedMemoryLeak; // @nameonly @note "DCC32 MAP System.SysUnregisterExpectedMemoryLeak. Prototype pending: no unique source declaration."

procedure CheckSmallBlockPoolForLeaks; // @nameonly @note "DCC32 MAP System.CheckSmallBlockPoolForLeaks. Prototype pending: no unique source declaration."

procedure ScanForMemoryLeaks; // @nameonly @note "DCC32 MAP System.ScanForMemoryLeaks. Prototype pending: no unique source declaration."

procedure BuildBlockTypeLookupTable; // @nameonly @note "DCC32 MAP System.BuildBlockTypeLookupTable. Prototype pending: no unique source declaration."

procedure InitializeMemoryManager; // @nameonly @note "DCC32 MAP System.InitializeMemoryManager. Prototype pending: no unique source declaration."

procedure FreeAllMemory; // @nameonly @note "DCC32 MAP System.FreeAllMemory. Prototype pending: no unique source declaration."

procedure FinalizeMemoryManager; // @nameonly @note "DCC32 MAP System.FinalizeMemoryManager. Prototype pending: no unique source declaration."

function AllocMem(Size: Cardinal): Pointer; // @ida "void * __usercall $name@<eax>(unsigned __int32 Size@<eax>);" @note "DCC32 MAP System.AllocMem. Source rtl/sys/System.pas:2536."

procedure ExceptObject; // @nameonly @note "DCC32 MAP System.ExceptObject. Prototype pending: no unique source declaration."

procedure ExceptAddr; // @nameonly @note "DCC32 MAP System.ExceptAddr. Prototype pending: no unique source declaration."

procedure AcquireExceptionObject; // @nameonly @note "DCC32 MAP System.AcquireExceptionObject. Prototype pending: no unique source declaration."

procedure ErrorAt(ErrorCode: Byte; ErrorAddr: Pointer); // @nameonly @note "DCC32 MAP System.ErrorAt. Source rtl/sys/System.pas:3248. Prototype pending: RET mismatch: expected 0, native []."

procedure __IOTest; // @nameonly @note "DCC32 MAP System.@_IOTest. Source rtl/sys/System.pas:3306. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _Copy; // @nameonly @note "DCC32 MAP System.@Copy. Source rtl/sys/System.pas:3349. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _LGetDir(D: Byte; var S: AnsiString); // @nameonly @note "DCC32 MAP System.@LGetDir. Source rtl/sys/System.pas:3455. Prototype pending: compiler-helper ABI needs explicit analysis."

function IOResult: Integer; // @ida "__int32 __usercall $name@<eax>(void);" @note "DCC32 MAP System.IOResult. Source rtl/sys/System.pas:3575."

function GetParamStr(P: PAnsiChar; var Param: AnsiString): PAnsiChar; // @ida "PAnsiChar __usercall $name@<eax>(PAnsiChar P@<eax>, char * *Param@<edx>);" @note "DCC32 MAP System.GetParamStr. Source rtl/sys/System.pas:3744."

function ParamCount: Integer; // @ida "__int32 __usercall $name@<eax>(void);" @note "DCC32 MAP System.ParamCount. Source rtl/sys/System.pas:3817."

function ParamStr(Index: Integer): AnsiString; // @ida "void __usercall $name(__int32 Index@<eax>, char * *Result@<edx>);" @note "DCC32 MAP System.ParamStr. Source rtl/sys/System.pas:3843."

function OpenText(var t: TTextRec; Mode: Word): Integer; // @ida "__int32 __usercall $name@<eax>(TTextRec *t@<eax>, unsigned __int16 Mode@<dx>);" @note "DCC32 MAP System.OpenText. Source rtl/sys/System.pas:4241."
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

function TextIn(var t: TTextRec): Integer; // @ida "__int32 __usercall $name@<eax>(TTextRec *t@<eax>);" @note "DCC32 MAP System.TextIn. Source rtl/sys/System.pas:4271."

function TextOut(var t: TTextRec): Integer; // @ida "__int32 __usercall $name@<eax>(TTextRec *t@<eax>);" @note "DCC32 MAP System.TextOut. Source rtl/sys/System.pas:4304."

function TextClose(var t: TTextRec): Integer; // @ida "__int32 __usercall $name@<eax>(TTextRec *t@<eax>);" @note "DCC32 MAP System.TextClose. Source rtl/sys/System.pas:4337."

procedure TextOpen; // @nameonly @note "DCC32 MAP System.TextOpen. Prototype pending: no unique source declaration."

procedure InternalFlush; // @nameonly @note "DCC32 MAP System.InternalFlush. Source rtl/sys/System.pas:4812. Prototype pending: unsupported source type TTextIOFunc: function (var F: TTextRec): Integer."

function _Close(var t: TTextRec): Integer; // @addr $403944 @note "Compiler CloseFile; EAX addresses the file record and returns the RTL status. Native registers agree with System.pas:4906."

procedure PStrCpy(Dest, Source: Pointer); // @addr $4039CC DCC32 System.@PStrCpy; copies Source[0]+1 bytes, including the short-string length byte.
procedure PStrNCat(Dest, Source: Pointer; MaximumLength: Byte); // @addr $40399C DCC32 System.@PStrNCat; appends a length-prefixed short string with CL as the capacity.

procedure PStrNCpy; // @nameonly @note "DCC32 MAP System.@PStrNCpy. Source rtl/sys/System.pas:5038. Prototype pending: source type not found: ShortString."

procedure _PStrCmp; // @nameonly @note "DCC32 MAP System.@PStrCmp. Source rtl/sys/System.pas:5046. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _AStrCmp; // @nameonly @note "DCC32 MAP System.@AStrCmp. Source rtl/sys/System.pas:5133. Prototype pending: compiler-helper ABI needs explicit analysis."

function _ValLong(const s: AnsiString; var code: Integer): Longint; // @nameonly @note "DCC32 MAP System.@ValLong. Source rtl/sys/System.pas:6622. Prototype pending: compiler-helper ABI needs explicit analysis."

function TryOpenForOutput(var t: TTextRec): Boolean; // @ida "bool __usercall $name@<al>(TTextRec *t@<eax>);" @note "DCC32 MAP System.TryOpenForOutput. Source rtl/sys/System.pas:6896."

function _WriteBytes(var t: TTextRec; b: Pointer; cnt: Longint): Pointer; // @nameonly @note "DCC32 MAP System.@WriteBytes. Source rtl/sys/System.pas:6909. Prototype pending: compiler-helper ABI needs explicit analysis."

function _WriteSpaces(var t: TTextRec; cnt: Longint): Pointer; // @nameonly @note "DCC32 MAP System.@WriteSpaces. Source rtl/sys/System.pas:7011. Prototype pending: compiler-helper ABI needs explicit analysis."

function _WriteLn(var t: TTextRec): Pointer; // @nameonly @note "DCC32 MAP System.@WriteLn. Source rtl/sys/System.pas:7256. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _CLenToPasStr; // @nameonly @note "DCC32 MAP System.@_CLenToPasStr. Source rtl/sys/System.pas:7279. Prototype pending: source type not found: ShortString."

procedure _Pow10; // @nameonly @note "DCC32 MAP System.@Pow10. Source rtl/sys/System.pas:8273. Prototype pending: compiler-helper ABI needs explicit analysis."

function _isNECWindows: Boolean; // @nameonly @note "DCC32 MAP System.@isNECWindows. Source rtl/sys/System.pas:8644. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _FpuMaskInit; // @nameonly @note "DCC32 MAP System.@FpuMaskInit. Source rtl/sys/System.pas:8661. Prototype pending: compiler-helper ABI needs explicit analysis."

function InvokeImplGetter(Self: TObject; ImplGetter: Cardinal): IInterface; // @nameonly @note "DCC32 MAP System.InvokeImplGetter. Source rtl/sys/System.pas:8947. Prototype pending: RET mismatch: expected 0, native []."

procedure GetDynaMethod; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.GetDynaMethod. Source rtl/sys/System.pas:9117."

procedure NotifyReRaise; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.NotifyReRaise. Source rtl/sys/System.pas:9642."

procedure NotifyNonDelphiException; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.NotifyNonDelphiException. Source rtl/sys/System.pas:9669."

procedure CheckJmp; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.CheckJmp. Source rtl/sys/System.pas:9751."

procedure NotifyExceptFinally; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.NotifyExceptFinally. Source rtl/sys/System.pas:9773."

procedure NotifyTerminate; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.NotifyTerminate. Source rtl/sys/System.pas:9810."

procedure NotifyUnhandled; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.NotifyUnhandled. Source rtl/sys/System.pas:9827."

procedure _HandleAnyException; // @nameonly @note "DCC32 MAP System.@HandleAnyException. Source rtl/sys/System.pas:9918. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _HandleOnException; // @addr 0x404BB8 @nameonly @note "DCC32 typed-exception dispatch through an inline class/handler table; shared runtime code, not part of each caller's body."

procedure _HandleFinally; // @nameonly @note "DCC32 MAP System.@HandleFinally. Source rtl/sys/System.pas:10451. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure HandleFinallyInternal; // @nameonly @note "DCC32 MAP System.@HandleFinallyInternal. Prototype pending: no unique source declaration."

procedure _RaiseAgain; // @ida "void __noreturn __usercall $name(void);" @note "Reraises the active exception; consumes the runtime exception frame."

procedure _DoneExcept; // @nameonly @note "DCC32 MAP System.@DoneExcept. Source rtl/sys/System.pas:10985. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _TryFinallyExit(PreviousFrame, Handler, SavedFrame: Pointer); stdcall; // @addr $404ECC @note "Compiler helper: unlinks the current exception frame, calls Handler+5, and removes the three frame words. The arguments are the existing SEH frame, not newly pushed source arguments."

procedure MapToRunError(P: PExceptionRecord); // @nameonly @note "DCC32 MAP System.MapToRunError. Source rtl/sys/System.pas:11060. Prototype pending: RET mismatch: expected 4, native []."

procedure _ExceptionHandler; // @nameonly @note "DCC32 MAP System.@ExceptionHandler. Source rtl/sys/System.pas:11099. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure SetExceptionHandler; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.SetExceptionHandler. Source rtl/sys/System.pas:11163."

procedure UnsetExceptionHandler; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.UnsetExceptionHandler. Source rtl/sys/System.pas:11186."

procedure FinalizeUnits; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.FinalizeUnits. Source rtl/sys/System.pas:11231."

procedure InitUnits; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.InitUnits. Source rtl/sys/System.pas:11371."

procedure StartExe; // @nameonly @note "DCC32 MAP System.@StartExe. Prototype pending: no unique source declaration."

procedure _InitResStringImports; // @nameonly @note "DCC32 MAP System.@InitResStringImports. Source rtl/sys/System.pas:11648. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _InitImports; // @nameonly @note "DCC32 MAP System.@InitImports. Source rtl/sys/System.pas:11685. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure MakeErrorMessage; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.MakeErrorMessage. Source rtl/sys/System.pas:11771."

procedure ExitDll; // @nameonly @note "DCC32 MAP System.ExitDll. Source rtl/sys/System.pas:11796. Prototype pending: RET mismatch: expected 0, native [12]."

procedure WriteErrorMessage; // @ida "void __usercall $name(void);" @note "DCC32 MAP System.WriteErrorMessage. Source rtl/sys/System.pas:11843."

procedure _Halt0; // @ida "void __noreturn __usercall $name();" @note "Compiler program termination: finalizes units and exits the process. RTL System._Halt0, no parameters."

procedure AssignAnsiStringAlias(var Dest: AnsiString; Source: AnsiString); // @note "DCC32 System.@LStrLAsg: retains Source, replaces Dest and releases its previous storage."

procedure CharFromWChar; // @nameonly @note "DCC32 MAP System.CharFromWChar. Prototype pending: no unique source declaration."

procedure WCharFromChar; // @nameonly @note "DCC32 MAP System.WCharFromChar. Prototype pending: no unique source declaration."

procedure _LStrToString; // @nameonly @note "DCC32 MAP System.@LStrToString. Source rtl/sys/System.pas:12802. Prototype pending: compiler-helper ABI needs explicit analysis."

function CompareAnsiStrings(Left, Right: AnsiString): TStringComparisonFlags; // @ida "TStringComparisonFlags __usercall $name@<zf:cf>(char *Left@<eax>, char *Right@<edx>);" @note "System.@LStrCmp returns unsigned byte-string ordering in ZF and CF; nil equals empty."

function InternalUniqueString(str: Pointer): Pointer; // @ida "void * __usercall $name@<eax>(void * str@<eax>);" @note "DCC32 MAP System.InternalUniqueString. Source rtl/sys/System.pas:13242."

procedure _LStrCopy; // @nameonly @note "DCC32 MAP System.@LStrCopy. Source rtl/sys/System.pas:13309. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _LStrDelete; // @nameonly @note "DCC32 MAP System.@LStrDelete. Source rtl/sys/System.pas:13366. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _LStrInsert; // @nameonly @note "DCC32 MAP System.@LStrInsert. Source rtl/sys/System.pas:13427. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _InitializeArray(p: Pointer; typeInfo: Pointer; elemCount: Cardinal); // @nameonly @note "DCC32 MAP System.@InitializeArray. Source rtl/sys/System.pas:14857. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure InitializeRecord(Data, TypeInfo: Pointer); // @addr $406258 @note "System.@InitializeRecord: visits managed fields described by record RTTI."
procedure _FinalizeRecord(p: Pointer; typeInfo: Pointer); // @note "System.@FinalizeRecord: finalizes managed fields described by record RTTI; EAX retains the record address."
procedure _Dispose(Data, TypeInfo: Pointer); // @addr $4067B4 @note "System.@Dispose: finalizes a managed record, then frees its allocation."

procedure AddRefRecord(Data, TypeInfo: Pointer); // @addr $40646C @note "System.@AddRefRecord: retains each managed field in a copied record using RTTI and AddRefArray. Verified against the linked Delphi 2007 RTL (47-byte body)."

procedure _CopyRecord; // @nameonly @note "DCC32 MAP System.@CopyRecord. Source rtl/sys/System.pas:15456. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _CopyArray; // @nameonly @note "DCC32 MAP System.@CopyArray. Source rtl/sys/System.pas:15613. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure __llmul; // @nameonly @note "DCC32 MAP System.@_llmul. Source rtl/sys/System.pas:15890. Prototype pending: compiler-helper ABI needs explicit analysis."
function ShiftLeftInt64(Value: Int64; Count: Integer): Int64; // @ida "__int64 __usercall $name@<edx:eax>(__int64 Value@<edx:eax>, int Count@<ecx>);"
function ShiftRightInt64(Value: Int64; Count: Integer): Int64; // @ida "__int64 __usercall $name@<edx:eax>(__int64 Value@<edx:eax>, int Count@<ecx>);"
function DivideInt64(Dividend, Divisor: Int64): Int64; // @ida "__int64 __userpurge $name@<edx:eax>(__int64 Dividend@<edx:eax>, __int64 Divisor@<^0>);"
function Int64Remainder(Dividend, Divisor: Int64): Int64; // @ida "__int64 __userpurge $name@<edx:eax>(__int64 Dividend@<edx:eax>, __int64 Divisor@<^0>);" @note "Signed Int64 remainder, RTL System.__llmod. Divisor is stack-passed; callee pops eight bytes. Sign follows dividend."

function __lludiv(Dividend, Divisor: UInt64): UInt64; // @addr $406894 @ida "unsigned __int64 __userpurge $name@<edx:eax>(unsigned __int64 Dividend@<edx:eax>, unsigned __int64 Divisor@<^0>);" @note "Unsigned 64-bit division; numerator in EDX:EAX, divisor on stack, RET 8."

function _ValInt64(const s: AnsiString; var code: Integer): Int64; // @nameonly @note "DCC32 MAP System.@ValInt64. Source rtl/sys/System.pas:16701. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _DynArrayCopyRange(a: Pointer; typeInfo: Pointer; index, count: Integer; var Result: Pointer); // @nameonly @note "DCC32 MAP System.@DynArrayCopyRange. Source rtl/sys/System.pas:16918. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _DynArrayAsg; // @nameonly @note "DCC32 MAP System.@DynArrayAsg. Source rtl/sys/System.pas:17025. Prototype pending: compiler-helper ABI needs explicit analysis."

function FindHInstance(Address: Pointer): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(void * Address@<eax>);" @note "DCC32 MAP System.FindHInstance. Source rtl/sys/System.pas:17280."

function DelayLoadResourceModule(Module: PLibModule): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(PLibModule Module@<eax>);" @note "DCC32 MAP System.DelayLoadResourceModule. Source rtl/sys/System.pas:17458."

function FindResourceHInstance(Instance: Cardinal): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(unsigned __int32 Instance@<eax>);" @note "DCC32 MAP System.FindResourceHInstance. Source rtl/sys/System.pas:17472."

function FindBS(Current: PAnsiChar): PAnsiChar; // @nameonly @note "DCC32 MAP System.FindBS. Source rtl/sys/System.pas:17563. Prototype pending: nested routine has a parent-frame parameter."

function ToLongPath(AFileName: PAnsiChar; BufSize: Integer): PAnsiChar; // @nameonly @note "DCC32 MAP System.ToLongPath. Source rtl/sys/System.pas:17570. Prototype pending: nested routine has a parent-frame parameter."

function LoadResourceModule(ModuleName: PAnsiChar; CheckOwner: Boolean): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(PAnsiChar ModuleName@<eax>, bool CheckOwner@<dl>);" @note "DCC32 MAP System.LoadResourceModule. Source rtl/sys/System.pas:17491."

procedure RemoveModuleUnloadProc; // @nameonly @note "DCC32 MAP System.RemoveModuleUnloadProc. Prototype pending: no unique source declaration."

procedure NotifyModuleUnload(HInstance: Cardinal); // @ida "void __usercall $name(unsigned __int32 HInstance@<eax>);" @note "DCC32 MAP System.NotifyModuleUnload. Source rtl/sys/System.pas:17752."

procedure UnregisterModule(LibModule: PLibModule); // @ida "void __usercall $name(PLibModule LibModule@<eax>);" @note "DCC32 MAP System.UnregisterModule. Source rtl/sys/System.pas:17777."

procedure _IntfCast(var Dest: IInterface; const Source: IInterface; const IID: TGUID); // @nameonly @note "DCC32 MAP System.@IntfCast. Source rtl/sys/System.pas:17892. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure UnicodeToUtf8; // @nameonly @note "DCC32 MAP System.UnicodeToUtf8. Prototype pending: no unique source declaration."

procedure Utf8ToUnicode; // @nameonly @note "DCC32 MAP System.Utf8ToUnicode. Prototype pending: no unique source declaration."

function UTF8Encode(const WS: WideString): AnsiString; // @ida "void __usercall $name(unsigned __int16 * WS@<eax>, char * *Result@<edx>);" @note "DCC32 MAP System.UTF8Encode. Source rtl/sys/System.pas:18265."

function UTF8Decode(const S: AnsiString): WideString; // @ida "void __usercall $name(char * S@<eax>, unsigned __int16 * *Result@<edx>);" @note "DCC32 MAP System.UTF8Decode. Source rtl/sys/System.pas:18282."

function AnsiToUtf8(const S: AnsiString): AnsiString; // @ida "void __usercall $name(char * S@<eax>, char * *Result@<edx>);" @note "DCC32 MAP System.AnsiToUtf8. Source rtl/sys/System.pas:18299."

procedure LoadResString; // @nameonly @note "DCC32 MAP System.LoadResString. Prototype pending: no unique source declaration."

procedure FinalizeSystem; // @nameonly @note "DCC32 MAP System.Finalization. Prototype pending: no unique source declaration."

procedure SetRange; // @addr 0x404010 @nameonly @note "DCC32 set-range helper: AL lower bound, DL upper bound, AH storage bytes, ECX destination. Compiler intrinsic, not an ordinary Pascal-call ABI."

procedure SetAnsiStringFromWideChar(var Dest: AnsiString; Source: WideChar);
procedure SetAnsiStringFromChar(var Dest: AnsiString; Source: Char);
procedure SetWideStringFromAnsiChar(var Dest: WideString; Source: AnsiChar);

var
  RaiseExceptionProc: Pointer; // @addr $884014 RTL hook, called with the Windows RaiseException stdcall ABI.
  HInstance: Cardinal; // @addr $8867F4
  DefaultTextLineBreakStyle: Byte; // @addr $878034 @note "RTL TTextLineBreakStyle ordinal: LF=0, CRLF=1."

implementation
end.
