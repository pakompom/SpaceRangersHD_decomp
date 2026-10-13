unit EC_Expression;

interface

uses Classes, EC_Buf, SysUtils, Windows;

type
  ExceptionExpressionEC = class;
  TVarEC = class;
  TVarArrayEC = class;
  TCodeAnalyzerUnitEC = class;
  TCodeAnalyzerEC = class;
  TExpressionInstrEC = class;
  TExpressionVarEC = class;
  TExpressionEC = class;
  TCodeUnitEC = class;
  TCodeProcessEC = class;
  TCodeEC = class;
  TCompilerUnitEC = class;
  TCompilerEC = class;
  TScriptDebugState = class;

  ExceptionExpressionEC = class(Exception) // @size $0C
  end;

  TLibrarySignature = array of Dword;
  TScriptStepCallback = procedure(StatementCount: Integer);

  TVarKind = (vkEmpty = 0, vkInt = 1, vkDword = 2, vkFloat = 3,
    vkString = 4, vkExternFun = 5, vkLibraryFun = 6, vkFunction = 7,
    vkClass = 8, vkArray = 9, vkRef = 10); // @size 0x1

  // DLL signature words use a separate numbering from TVarKind.
  TLibraryValueKind = (lvVoid = 0, lvInt = 1, lvDword = 2,
    lvFloat = 3, lvString = 4, lvRef = 5, lvCode = 6); // @size 0x4

  TCodeTokenKind = (ctNewline = 0, ctOpenParen = 1, ctCloseParen = 2,
    ctOpenBrace = 3, ctCloseBrace = 4, ctOpenBracket = 5, ctCloseBracket = 6,
    ctBlockCommentStart = 7, ctBlockCommentEnd = 8, ctLineComment = 9,
    ctDot = 10, ctArrow = 11, ctAdd = 12, ctSubtract = 13,
    ctMultiply = 14, ctDivide = 15, ctModulo = 16, ctBitAnd = 17,
    ctBitOr = 18, ctBitXor = 19, ctBitNot = 20, ctAnd = 21,
    ctOr = 22, ctNot = 23, ctShiftLeft = 24, ctShiftRight = 25,
    ctAssign = 26, ctEqual = 27, ctNotEqual = 28, ctLess = 29,
    ctGreater = 30, ctLessEqual = 31, ctGreaterEqual = 32,
    ctSemicolon = 33, ctColon = 34, ctComma = 35, ctWhitespace = 36,
    ctStringLiteral = 37, ctText = 38); // @size 0x1

  TCompilerUnitKind = (cuIntLiteral = 0, cuDwordLiteral = 1,
    cuFloatLiteral = 2, cuStringLiteral = 3, cuBinaryOperator = 4,
    cuUnaryOperator = 5, cuOpenParen = 6, cuCloseParen = 7,
    cuOpenBracket = 8, cuCloseBracket = 9, cuName = 10, cuCall = 11,
    cuIndex = 12, cuVariable = 13, cuComma = 14, cuAssignment = 15); // @size 0x1

  TExpressionOpcode = (eoNegate = 0, eoAdd = 1, eoSubtract = 2,
    eoMultiply = 3, eoDivide = 4, eoModulo = 5, eoBitAnd = 6,
    eoBitOr = 7, eoBitXor = 8, eoBitNot = 9, eoAnd = 10, eoOr = 11,
    eoNot = 12, eoShiftLeft = 13, eoShiftRight = 14, eoLess = 15,
    eoGreater = 16, eoEqual = 17, eoNotEqual = 18, eoLessEqual = 19,
    eoGreaterEqual = 20, eoAssign = 21, eoCall = 22, eoIndex = 23); // @size 0x1

  TExpressionVarKind = (evNamed = 0, evOwned = 1, evIndexed = 2); // @size 0x1

  TCodeOpcode = (coLabel = 0, coExpression = 1, coBranchFalse = 2,
    coJump = 3, coExit = 4, coPushHandler = 5, coPopHandler = 6,
    coThrow = 7); // @size 0x1

  PCodeAnalyzerUnitEC = ^TCodeAnalyzerUnitEC;

  TVarEC = class(TObject) // @size 0x38
  public
    Name: WideString; // @offset 0x04
    Kind: TVarKind; // @offset 0x08
    IntValue: Integer; // @offset 0x0C
    DwordValue: Dword; // @offset 0x10
    StringValue: WideString; // @offset 0x14
    FloatValue: Double; // @offset 0x18
    ExternFunValue: Pointer; // @offset 0x20
    // Delphi dynamic array: TLibraryValueKind return kind, native address,
    // then TLibraryValueKind argument kinds. Address word is not an enum.
    LibraryFunData: array of Dword; // @offset 0x24
    FunctionValue: TCodeEC; // @offset 0x28
    ClassValue: TCodeEC; // @offset 0x2C
    ArrayValue: TVarArrayEC; // @offset 0x30
    RefValue: TVarEC; // @offset 0x34

    function GetInt: Integer; // @addr 0x00460A74
    function GetDword: Dword; // @addr 0x00460B1C @note "Reference cells delegate to GetInt, then reinterpret its bits."
    function GetFloat: Double; // @addr 0x00460BC4
    function GetExternFun: Pointer; // @addr 0x00460E2C
    function GetFunction: TCodeEC; // @addr 0x00460ED0
    function GetClass: TCodeEC; // @addr 0x00460F74 @note "Reference cells delegate to GetFunction in the native code."
    function GetArray: TVarArrayEC; // @addr 0x00461018
    function Resolve: TVarEC; // @addr 0x004618F0 @note "May return nil."
    function RealVType: TVarKind; // @addr 0x00460910 @note "Returns vkRef for an unresolved reference."
    function IsTrue: Boolean; // @addr 0x00464528
    procedure ResetKind(NewKind: TVarKind); // @addr 0x00460884
    procedure AssignFrom(Source: TVarEC; CopyArrays: Boolean); // @addr 0x00460924
    procedure Assume(Source: TVarEC; CopyArrays: Boolean); // @addr 0x00463E28 @note "Assigns through references, converting to the destination kind."
    procedure SetInt(Value: Integer); // @addr 0x004610BC
    procedure SetDword(Value: Dword); // @addr 0x004611D4 @note "Reference cells delegate to SetInt with the same bits."
    procedure SetExternFun(Value: Pointer); // @addr 0x00461510
    procedure SetFunction(Value: TCodeEC); // @addr $4615DC @note "Native leaves empty and function cells unchanged; other kinds clear their payload or delegate through a reference."
    procedure SetRef(Value: TVarEC); // @addr 0x00461830

    procedure OMinus(Value: TVarEC); // @addr 0x00463A8C
    procedure OBitNot(Value: TVarEC); // @addr 0x00463BE8
    procedure ONot(Value: TVarEC); // @addr 0x00463CF0
    procedure OAdd(Left, Right: TVarEC); // @addr 0x00461D88
    procedure OSub(Left, Right: TVarEC); // @addr 0x00461F24
    procedure OMul(Left, Right: TVarEC); // @addr 0x004620C0
    procedure ODiv(Left, Right: TVarEC); // @addr 0x0046225C
    procedure OMod(Left, Right: TVarEC); // @addr 0x00462404
    procedure OBitAnd(Left, Right: TVarEC); // @addr 0x00462560
    procedure OBitOr(Left, Right: TVarEC); // @addr 0x004626BC
    procedure OBitXor(Left, Right: TVarEC); // @addr 0x00462818
    procedure OAnd(Left, Right: TVarEC); // @addr 0x00462974
    procedure OOr(Left, Right: TVarEC); // @addr 0x00462AEC
    procedure OShl(Left, Right: TVarEC); // @addr 0x00462C60
    procedure OShr(Left, Right: TVarEC); // @addr 0x00462DB8
    procedure OEqual(Left, Right: TVarEC); // @addr 0x00462F10
    procedure ONotEqual(Left, Right: TVarEC); // @addr 0x004630F8
    procedure OLess(Left, Right: TVarEC); // @addr 0x004632E4
    procedure OMore(Left, Right: TVarEC); // @addr 0x004634CC
    procedure OLessEqual(Left, Right: TVarEC); // @addr 0x004636B4
    procedure OMoreEqual(Left, Right: TVarEC); // @addr 0x004638A0

    constructor Create(InitialKind: TVarKind); // @addr 0x00460150
    destructor Destroy; override; // @addr 0x004601A8

    function IsEmpty: Boolean; // @addr 0x00460A6C @note "Tests this cell's tag without dereferencing."
    function GetString: WideString; // @addr 0x00460CE0 @note "Library cells return their import specification string."
    procedure ConvertToKind(NewKind: TVarKind); // @addr 0x004601EC @note "Preserves the value where conversion is supported; ResetKind discards it."
    procedure SetFloat(Value: Double); // @addr 0x004612F8
    procedure SetString(const Value: WideString); // @addr 0x0046142C @note "Assigns through references and converts to an existing destination kind; an empty cell becomes a string."
    procedure SetClass(Value: TCodeEC); // @addr 0x00461698 @note "Value is borrowed; vkRef assignment uses the function-value setter."
    procedure SetArray(Value: TVarArrayEC); // @addr 0x00461764 @note "Value is borrowed; follows references."
    procedure SetLibrarySignature(Signature: array of Dword); // @addr 0x0046E030 @note "Does not change Kind."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x00464658 @note "Only scalar, string and array kinds have serialized payloads."
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x004646E4
    function EqualsValue(Other: TVarEC): Boolean; // @addr 0x004640F0
    function LessThan(Other: TVarEC): Boolean; // @addr 0x00464268
    function GreaterThan(Other: TVarEC): Boolean; // @addr 0x004643C8
    procedure PackAnsiString; // @addr 0x00461900 @note "Stores ANSI bytes inside StringValue's UTF-16 allocation."
    procedure UnpackAnsiString; // @addr 0x004619AC @note "Non-string cells are converted to string without unpacking."
    procedure CreateArray(Dimensions: array of Integer); // @addr 0x00461CB0 @note "Requires at least one dimension."
    procedure FreeArray; // @addr 0x00461D58 @note "Frees nested arrays; retains vkArray with a nil pointer."
    procedure ResizeArray(Count, Dimension: Integer); // @addr $461D04 @note "Nonpositive Count frees the array; positive Count resizes only when Dimension <= 0."

    // Converted views follow references and retain the existing cell-kind rules.
    property AsInteger: Integer read GetInt write SetInt;
    property AsDword: Dword read GetDword write SetDword;
    property AsFloat: Double read GetFloat write SetFloat;
    property AsString: WideString read GetString write SetString;
    property AsExternFun: Pointer read GetExternFun write SetExternFun;
    property AsFunction: TCodeEC read GetFunction write SetFunction;
    property AsClass: TCodeEC read GetClass write SetClass;
    property AsArray: TVarArrayEC read GetArray write SetArray;
    property ValueKind: TVarKind read RealVType;
  end;

  TVarArrayEC = class(TObject) // @size 0x10
  public
    Count: Integer; // @offset 0x04
    Data: PVarEC; // @offset 0x08
    NameOrder: ^Integer; // @offset 0x0C

    procedure Clear; // @addr 0x0046487C
    procedure CopyFrom(Source: TVarArrayEC; CopyArrays: Boolean); // @addr 0x004648E0
    function GetItem(Index: Integer): TVarEC; // @addr 0x00464B48
    function GetItemNE(Index: Integer): TVarEC; // @addr 0x00464B6C @note "Returns nil for an out-of-range index."
    function GetVar(const Name: WideString): TVarEC; // @addr 0x00464BB4
    function GetVarNE(const Name: WideString): TVarEC; // @addr 0x00464C5C @note "Returns nil when absent."
    function Add(const Name: WideString; Kind: TVarKind): TVarEC; // @addr 0x00464FA4

    constructor Create; // @addr 0x004647D4
    destructor Destroy; override; // @addr 0x0046480C

    procedure ClearStorage; // @addr 0x00464838 @note "Does not free cells; use Clear for owned entries."
    function FindNameOrderIndex(const Name: WideString): Integer; // @addr 0x004649AC @note "Returns -1 when absent."
    function FindNameInsertionIndex(const Name: WideString): Integer; // @addr 0x00464A40
    procedure SetNameOrderIndex(Index, DataIndex: Integer); // @addr 0x00464AD8 @note "Does not validate either index."
    function GetNameOrderIndex(Index: Integer): Integer; // @addr 0x00464AEC
    function GetItemByNameOrder(Index: Integer): TVarEC; // @addr 0x00464AFC
    function FindNameOrderForDataIndex(DataIndex: Integer): Integer; // @addr 0x00464B14
    procedure SetItem(Index: Integer; Value: TVarEC); // @addr 0x00464B58 @note "Does not validate Index, free the old cell, or update NameOrder."
    function IndexOf(Value: TVarEC): Integer; // @addr 0x00464B80
    procedure AddItem(Value: TVarEC); // @addr 0x00464E98 @note "Takes ownership of Value."
    procedure Delete(Index: Integer); // @addr 0x00464D00 @note "Frees the cell; ignores invalid indexes."
    procedure Remove(Value: TVarEC); // @addr 0x00464DC0
    procedure DeleteByName(const Name: WideString); // @addr 0x00464DDC
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x00465010
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x00465048 @note "Clears existing cells before reading."
    procedure AppendFromBuffer(Buffer: TBufEC); // @addr 0x00465090

    property Items[Index: Integer]: TVarEC read GetItem write SetItem; default;
    // NamedItems creates a missing cell; GetVarNE remains an explicit lookup.
    property NamedItems[const Name: WideString]: TVarEC read GetVar;
  end;

  TCodeAnalyzerUnitEC = class(TObject) // @size 0x1C
  public
    Prev: TCodeAnalyzerUnitEC; // @offset 0x04
    Next: TCodeAnalyzerUnitEC; // @offset 0x08
    TokenKind: TCodeTokenKind; // @offset 0x0C
    SourceStart: Integer; // @offset 0x10
    SourceLength: Integer; // @offset 0x14
    Text: WideString; // @offset 0x18
  end;

  TCodeAnalyzerEC = class(TObject) // @size 0x14
  public
    FirstFree: TCodeAnalyzerUnitEC; // @offset 0x04
    LastFree: TCodeAnalyzerUnitEC; // @offset 0x08
    First: TCodeAnalyzerUnitEC; // @offset 0x0C
    Last: TCodeAnalyzerUnitEC; // @offset 0x10
    constructor Create; // @addr 0x004650D4
    destructor Destroy; override; // @addr 0x0046510C
    procedure Clear; // @addr 0x00465138 @note "Also frees pooled nodes."
    procedure ReserveTokens(Count: Integer); // @addr 0x00465184
    function AcquireToken: TCodeAnalyzerUnitEC; // @addr 0x004651C4
    procedure RecycleToken(Token: TCodeAnalyzerUnitEC); // @addr 0x00465210
    procedure ClearTokens; // @addr 0x00465234 @note "Retains token storage for reuse."
    function AddToken: TCodeAnalyzerUnitEC; // @addr 0x0046524C
    procedure DeleteToken(Token: TCodeAnalyzerUnitEC); // @addr 0x0046527C
    procedure AppendText(Text: WideString; SourceOffset, NewlineOffset: Integer); // @addr 0x004652B4 @note "NewlineOffset is added to the source-position base at each newline."
    procedure Tokenize(Text: WideString; NewlineOffset: Integer = 0); // @addr 0x004669F0 @note "Replaces existing tokens; source offsets start at zero."
    function ValidateDelimiters: WideString; // @addr 0x00466A74 @note "Returns an empty string on success."
    procedure RemoveWhitespace; // @addr 0x00466D34
    procedure RemoveNewlines; // @addr 0x00466D5C
    procedure RemoveComments; // @addr 0x00466D84 @note "Supports nested block comments."
  end;

  TScriptIncludeResolver = function(SourceContext: Pointer; const Name: WideString;
    InsertSource: Boolean; var IncludedContext: Pointer; Analyzer: TCodeAnalyzerEC): Integer;
  TExpressionCallback = procedure(av: array of TVarEC; Code: TCodeEC);
  PVarEC = ^TVarEC;

  TExpressionInstrEC = class(TObject) // @size 0x10
  public
    Opcode: TExpressionOpcode; // @offset 0x04
    OperandCount: Integer; // @offset 0x08
    // Indices into TExpressionEC.Variables: destination first, then sources.
    // eoCall uses destination, callee, arguments; eoIndex uses destination, array, indices.
    Operands: array of Integer; // @offset 0x0C

    procedure CopyFrom(Source: TExpressionInstrEC); // @addr 0x00466F64

    destructor Destroy; override; // @addr 0x00466E0C
  end;

  TExpressionVarEC = class(TObject) // @size 0x14
  public
    Kind: TExpressionVarKind; // @offset 0x04
    Name: WideString; // @offset 0x08
    MemberPath: array of WideString; // @offset 0x0C
    Value: TVarEC; // @offset 0x10

    procedure CopyFrom(Source: TExpressionVarEC); // @addr 0x00467010
    function Resolve(InitialKind: TVarKind): TVarEC; // @addr 0x0046722C @note "Only evOwned slots allocate values."

    destructor Destroy; override; // @addr 0x00466FC8

    function SplitMemberPath: Boolean; // @addr 0x004670B4 @note "Replaces Name with its root component. Always returns true."
    function GetFullName: WideString; // @addr 0x004671D8
  end;

  TExpressionEC = class(TObject) // @size 0x1C
  public
    VariableCount: Integer; // @offset 0x04
    Variables: ^TExpressionVarEC; // @offset 0x08
    InstructionCount: Integer; // @offset 0x0C
    Instructions: ^TExpressionInstrEC; // @offset 0x10
    SharedInstructions: Boolean; // @offset 0x14
    ResultIndex: Integer; // @offset 0x18

    procedure Clear; // @addr 0x0046747C
    procedure CopyFrom(Source: TExpressionEC); // @addr 0x004674BC
    procedure CopyFromFast(Source: TExpressionEC); // @addr 0x00467538 @note "Borrows Source's instruction array."
    function GetVariable(Index: Integer): TExpressionVarEC; cdecl; // @addr 0x00467664 @ida "TExpressionVarEC *__cdecl $name(TExpressionEC *Self, int Index);"
    function GetInstruction(Index: Integer): TExpressionInstrEC; cdecl; // @addr 0x00467768 @ida "TExpressionInstrEC *__cdecl $name(TExpressionEC *Self, int Index);"
    procedure Link(Scope: TVarArrayEC; OnlyUnlinked: Boolean); // @addr 0x00468874
    procedure Evaluate(Process: TCodeProcessEC; Code: TCodeEC; DebugContext: TScriptDebugState); // @addr 0x004688F4
    function GetResult: TVarEC; // @addr 0x00469B7C

    constructor Create; // @addr 0x00467418
    destructor Destroy; override; // @addr 0x00467450

    function AddVariable: Integer; // @addr 0x00467594 @note "Returns a zero-based index; the new slot starts with zero-initialized evNamed kind."
    procedure DeleteVariable(Index: Integer); // @addr 0x004675F8
    procedure SetVariable(Index: Integer; Value: TExpressionVarEC); cdecl; // @addr 0x0046767C @ida "void __cdecl $name(TExpressionEC *Self, int Index, TExpressionVarEC *Value);"
    function AddInstruction: Integer; // @addr 0x00467698
    procedure DeleteInstruction(Index: Integer); // @addr 0x004676FC
    procedure SetInstruction(Index: Integer; Value: TExpressionInstrEC); cdecl; // @addr 0x00467780 @ida "void __cdecl $name(TExpressionEC *Self, int Index, TExpressionInstrEC *Value);"
    function Compile(Analyzer: TCodeAnalyzerEC; FirstToken, EndToken: TCodeAnalyzerUnitEC; NextToken: PCodeAnalyzerUnitEC): WideString; // @addr 0x0046779C @note "EndToken is exclusive; nil FirstToken starts at Analyzer.First. NextToken may be nil. Clears the previous expression before compiling."
  end;

  TCodeUnitEC = class(TObject) // @size 0x2C
  public
    Prev: TCodeUnitEC; // @offset 0x04
    Next: TCodeUnitEC; // @offset 0x08
    Opcode: TCodeOpcode; // @offset 0x0C
    Expression: TExpressionEC; // @offset 0x10
    Target: TCodeUnitEC; // @offset 0x14
    ExceptionVar: TVarEC; // @offset 0x18
    SourceStart: Integer; // @offset 0x1C
    SourceLength: Integer; // @offset 0x20
    SourceContext: Pointer; // @offset 0x24  Compiler-supplied source/debug identity.
    Breakpoint: Boolean; // @offset 0x28

    destructor Destroy; override; // @addr 0x00469F64
  end;

  TCodeProcessEC = class(TObject) // @size 0x0C
  public
    Handlers: TList; // @offset 0x04
    Exceptions: TList; // @offset 0x08

    procedure Clear; // @addr 0x0046A038
    procedure PushHandler(Code: TCodeEC; Handler: TCodeUnitEC); // @addr 0x0046A0BC
    procedure PopHandler; // @addr 0x0046A0E8
    function GetHandler: PCodeExceptionHandler; // @addr 0x0046A124
    procedure RaiseUnhandledExceptions; // @addr $46A1DC
    procedure PushException(Value: TVarEC); // @addr 0x0046A13C
    procedure PopException; // @addr 0x0046A188 @note "Does not free the exception value; the caller assumes ownership."
    function GetException: PVarEC; // @addr 0x0046A1C4

    constructor Create; // @addr 0x00469F9C
    destructor Destroy; override; // @addr 0x00469FF0
  end;

  TCodeEC = class(TObject) // @size 0x28
  public
    Parent: TCodeEC; // @offset 0x04
    IsClassDefinition: Boolean; // @offset 0x08
    Name: WideString; // @offset 0x0C
    First: TCodeUnitEC; // @offset 0x10
    Last: TCodeUnitEC; // @offset 0x14
    LocalVar: TVarArrayEC; // @offset 0x18
    Process: TCodeProcessEC; // @offset 0x1C
    DebugContext: TScriptDebugState; // @offset 0x20
    ScriptFunLinked: Boolean; // @offset 0x24

    procedure Clear; // @addr 0x0046A35C
    procedure CopyFrom(Source: TCodeEC); // @addr 0x0046A380
    procedure CopyFromFast(Source: TCodeEC); // @addr 0x0046A474 @note "Expression instructions remain shared with Source."
    function FindVar(Name: WideString): TVarEC; // @addr 0x0046A574
    procedure DeleteCodeUnit(CodeUnit: TCodeUnitEC); // @addr 0x0046A614
    function AddCodeUnit: TCodeUnitEC; // @addr 0x0046A650
    procedure LinkAll(Scope: TVarArrayEC; OnlyUnlinked: Boolean); // @addr 0x0046CA80
    procedure Run(Process: TCodeProcessEC); // @addr 0x0046CB84
    procedure RunDebug(Process: TCodeProcessEC; DebugContext: TScriptDebugState); // @addr 0x0046CDD8

    constructor Create; // @addr 0x0046A2E0
    destructor Destroy; override; // @addr 0x0046A328

    function InsertCodeUnitBefore(BeforeUnit: TCodeUnitEC): TCodeUnitEC; // @addr 0x0046A684 @note "Inserts before BeforeUnit; nil appends."
    function Compile(Analyzer: TCodeAnalyzerEC; SourceContext: Pointer; IncludeResolver: TScriptIncludeResolver; FirstToken: TCodeAnalyzerUnitEC; NextToken: PCodeAnalyzerUnitEC): WideString; // @addr 0x0046A6C8 @note "NextToken may be nil."
    function CompileBlock(Analyzer: TCodeAnalyzerEC; SourceContext: Pointer; IncludeResolver: TScriptIncludeResolver; Token: TCodeAnalyzerUnitEC; BeforeUnit: TCodeUnitEC; NextToken, StatementEnd: PCodeAnalyzerUnitEC; BreakTarget, ContinueTarget: TCodeUnitEC): WideString; // @addr $46AB74
    procedure LinkLocalScopes; // @addr 0x0046CB28
  end;

  TCodeExceptionHandler = packed record // @size 0x08
    Code: TCodeEC; // @offset 0x00
    Handler: TCodeUnitEC; // @offset 0x04
  end;
  PCodeExceptionHandler = ^TCodeExceptionHandler;

  TCompilerUnitEC = class(TObject) // @size 0x30
  public
    Prev: TCompilerUnitEC; // @offset 0x04
    Next: TCompilerUnitEC; // @offset 0x08
    Kind: TCompilerUnitKind; // @offset 0x0C
    OperatorToken: TCodeTokenKind; // @offset 0x0D
    Text: WideString; // @offset 0x10
    VariableIndex: Integer; // @offset 0x14
    IntValue: Integer; // @offset 0x18
    DwordValue: Dword; // @offset 0x1C
    FloatValue: Double; // @offset 0x20
    SourceStart: Integer; // @offset 0x28
    SourceLength: Integer; // @offset 0x2C
  end;

  TCompilerEC = class(TObject) // @size 0x0C
  public
    First: TCompilerUnitEC; // @offset 0x04
    Last: TCompilerUnitEC; // @offset 0x08
    constructor Create; // @addr 0x00469BDC
    destructor Destroy; override; // @addr 0x00469C14
    procedure Clear; // @addr 0x00469C40
    function AddUnit: TCompilerUnitEC; // @addr 0x00469C58
    procedure DeleteUnit(UnitNode: TCompilerUnitEC); // @addr 0x00469C8C
    function FindReducibleOperator: TCompilerUnitEC; // @addr 0x00469CC8 @note "Returns nil when no operator qualifies."
    function FindReducibleIndex: TCompilerUnitEC; // @addr 0x00469EDC
    function FindReducibleCall: TCompilerUnitEC; // @addr 0x00469F20
  end;

  // Class declaration inferred from the first field at +4; no retained VMT is known.
  TScriptDebugState = class(TObject) // @partial
  public
    Paused: Boolean; // @offset $04
    StopEvent: Dword; // @offset $08
    ResumeEvent: Dword; // @offset $0C
    StepMode: Byte; // @offset $10
    CurrentUnit: TCodeUnitEC; // @offset $14
    CurrentCode: TCodeEC; // @offset $18
  end;

procedure SetScriptStepCallback(Callback: TScriptStepCallback; Interval: Integer); // @addr 0x0046CB78 @note "Callback is a Delphi register procedure taking the cumulative statement count."

procedure FreeScriptArrayTree(Values: TVarArrayEC); // @addr 0x00461A20 @note "Requires an acyclic ownership tree."
procedure GrowScriptArray(Values: TVarArrayEC; Dimensions: array of Integer; DimensionIndex: Integer); // @addr 0x00461A74 @note "Does not shrink or resize existing children."
procedure ResizeScriptArray(Values: TVarArrayEC; Count: Integer); // @addr 0x00461BB8 @note "Only the outer dimension changes; new children inherit the first child's dimensions."
procedure RegisterExpressionBuiltins(Scope: TVarArrayEC); // @addr 0x0046E4AC

function CompareScriptNames(Left, Right: PWideChar): Integer; cdecl; // @addr 0x0045F6E0 @note "Case-sensitive ordinal comparison; accepts nil and returns -1, 0 or 1."
function TrimScriptString(Text: WideString): WideString; // @addr 0x0045F738
function ScriptStringToInt(Text: WideString): Integer; // @addr 0x0045F81C @note "Collects decimal digits while ignoring other characters; negative only for a leading minus."
function ScriptFloatToString(Value: Double): WideString; // @addr 0x0045F8C4 @ida "void __userpurge $name(unsigned __int16 **Result@<eax>, double Value@<^0>);" @note "Uses a dot decimal separator."
function ScriptDwordToHex(Value: Dword): WideString; // @addr 0x0045F934
function ScriptStringToFloat(Text: WideString): Double; // @addr 0x0045F9D4 @note "Ignores nonnumeric characters; not a strict literal validator."
function IsScriptIntegerText(Text: WideString): Boolean; // @addr 0x0045FAF8 @note "Also accepts empty text and a lone minus."
function IsNonIntegerScriptText(Text: WideString): Boolean; // @addr 0x0045FB78
function TryReadFloatLiteral(var Token: TCodeAnalyzerUnitEC; out Value: Double): Boolean; // @addr 0x0045FC54 @note "Requires a decimal point and fractional digits; supports an exponent suffix. Token advances only on success; Value may change on failure."
function TryReadIntegerLiteral(var Token: TCodeAnalyzerUnitEC; out Value: Integer): Boolean; // @addr 0x0045FF14
function TryReadStringLiteral(var Token: TCodeAnalyzerUnitEC; var Value: WideString): Boolean; // @addr 0x0045FF74
function TryReadDwordLiteral(var Token: TCodeAnalyzerUnitEC; out Value: Dword): Boolean; // @addr 0x0045FFA0 @note "Reads h/H hexadecimal and b/B binary suffixes. Token advances only on success; Value may change on failure."
function TryReadMemberName(var Token: TCodeAnalyzerUnitEC; var Name: WideString): Boolean; // @addr 0x004600BC @note "Requires a nonnil initial Token."

// Native expression callbacks: av[0] is the script result; code is the caller.
procedure EF_Min(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D0BC
procedure EF_Max(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D174
procedure EF_NewArray(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D254
procedure EF_ArrayChange(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D350
procedure EF_Free(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D39C
procedure EF_Count(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D3EC
procedure EF_Copy(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D488
procedure EF_Abs(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D4D8
procedure EF_ArcTan(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D53C
procedure EF_Exp(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D588
procedure EF_Ln(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D5D4
procedure EF_Round(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D620
procedure EF_Sin(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D6BC
procedure EF_Cos(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D708
procedure EF_Sqr(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D754
procedure EF_Sqrt(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D7C4
procedure EF_Frac(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D810
procedure EF_Int(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D85C
procedure EF_Ord(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D89C
procedure EF_Rnd(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D914
procedure EF_Randomize(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D954
procedure EF_RandSeed(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D978
procedure EF_SubStr(av: array of TVarEC; code: TCodeEC); // @addr 0x0046D9C4
procedure EF_FindSubStr(av: array of TVarEC; code: TCodeEC); // @addr 0x0046DAA8
procedure EF_Trim(av: array of TVarEC; code: TCodeEC); // @addr 0x0046DBC4
procedure EF_ToAnsi(av: array of TVarEC; code: TCodeEC); // @addr 0x0046DC40
procedure EF_ToUnicode(av: array of TVarEC; code: TCodeEC); // @addr 0x0046DCB4
procedure EF_LowerCase(av: array of TVarEC; code: TCodeEC); // @addr 0x0046DD28
procedure EF_UpperCase(av: array of TVarEC; code: TCodeEC); // @addr 0x0046DE54
procedure EF_LoadLibrary(av: array of TVarEC; code: TCodeEC); // @addr 0x0046DF80
procedure EF_FreeLibrary(av: array of TVarEC; code: TCodeEC); // @addr 0x0046DFF4
procedure EF_LibraryFunction(av: array of TVarEC; code: TCodeEC); // @addr 0x0046E090 @note "av[1..3] are the module handle, return-kind name and export name; later arguments name parameter kinds."
procedure EF_New(av: array of TVarEC; code: TCodeEC); // @addr 0x0046E3A0 @note "Looks up class definitions in the root scope; the instance shares their expression instructions."
procedure EF_Delete(av: array of TVarEC; code: TCodeEC); // @addr 0x0046E464 @note "Also resets av[1]."

procedure InitInstr(Instruction: TExpressionInstrEC; Token: TCodeTokenKind); // @addr 0x00466E40 @note "Sets Opcode only. Accepts arithmetic, logical and comparison tokens; other tokens raise."

function FormatScriptError(Code, Position: Integer): WideString; // @addr $45FBC8 @note "Encodes error code and source position as a comma-separated decimal pair."

var
  ScriptCallTrace: array[0..19] of TVarEC; // @addr $819E0C

var
  ScriptCallTracePosition: Integer = 0; // @addr $80ADC0
  ScriptCallTraceCount: Integer = 0; // @addr $80ADC4
const
  ScriptHexDigits: array[0..15] of WideChar = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'); // @addr $80ADC8
var
  ScriptStepInterval: Integer = 0; // @addr $80ADE8
  ScriptStepCallback: TScriptStepCallback = nil; // @addr $80ADEC

implementation

uses Math;

{ @routine $45F6E0 CompareScriptNames }
function CompareScriptNames(Left, Right: PWideChar): Integer; cdecl;
asm
  PUSH ESI
  PUSH EDI
  PUSH EBX
  PUSH EDX
  MOV ESI, Left
  MOV EDI, Right
  TEST ESI, ESI
  JNZ @@LeftPresent
  MOV EAX, -1
  TEST EDI, EDI
  JNZ @@Done
  XOR EAX, EAX
  JMP @@Done
@@LeftPresent:
  TEST EDI, EDI
  JNZ @@Compare
  MOV EAX, 1
  JMP @@Done
@@Compare:
  MOV BX, [ESI]
  MOV DX, [EDI]
  ADD ESI, 2
  ADD EDI, 2
  CMP BX, DX
  JNZ @@Different
  XOR EAX, EAX
  TEST DX, DX
  JNZ @@Compare
  JMP @@Done
@@Different:
  MOV EAX, 1
  JA @@Done
  MOV EAX, -1
@@Done:
  POP EDX
  POP EBX
  POP EDI
  POP ESI
end;
{ @end $45F6E0 }

{ @routine $45F738 TrimScriptString }
function TrimScriptString(Text: WideString): WideString;
var
  C, Count, First, Last: Integer;
begin
  Count := Length(Text);
  First := 0;
  while First < Count do
  begin
    C := Ord(Text[First + 1]);
    if (C = Ord(' ')) or (C = 9) or (C = 13) or (C = 10) or (C = 0) then Inc(First)
    else Break;
  end;
  if First >= Count then
  begin
    Result := '';
    Exit;
  end;
  Last := Count - 1;
  while Last >= 0 do
  begin
    C := Ord(Text[Last + 1]);
    if (C = Ord(' ')) or (C = 9) or (C = 13) or (C = 10) or (C = 0) then Dec(Last)
    else Break;
  end;
  if Last < First then
  begin
    Result := '';
    Exit;
  end;
  SetLength(Result, Last - First + 1);
  Result := Copy(Text, First + 1, Last - First + 1);
end;
{ @end $45F738 }

{ @routine $45F81C ScriptStringToInt }
function ScriptStringToInt(Text: WideString): Integer;
var
  Count, i, Sign: Integer;
begin
  Result := 0;
  Count := Length(Text);
  Sign := 1;
  for i := 1 to Count do
    if (Integer(Text[i]) >= Ord('0')) and (Integer(Text[i]) <= Ord('9')) then Result := Result * 10 + (Ord(Text[i]) - Ord('0'))
    else if (Text[i] = '-') and (i = 1) then Sign := Sign * -1;
  Result := Sign * Result;
end;
{ @end $45F81C }

{ @routine $45F8C4 ScriptFloatToString }
function ScriptFloatToString(Value: Double): WideString;
var
  SavedSeparator: AnsiChar;
begin
  SavedSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  Result := FloatToStr(Value);
  DecimalSeparator := SavedSeparator;
end;
{ @end $45F8C4 }

{ @routine $45F934 ScriptDwordToHex }
function ScriptDwordToHex(Value: Dword): WideString;
begin
  Result := '';
  while Value <> 0 do
  begin
    Result := ScriptHexDigits[Value - (Value shr 4) shl 4] + Result;
    Value := Value div 16;
  end;
  if Result = '' then Result := '0';
end;
{ @end $45F934 }

{ @routine $45F9D4 ScriptStringToFloat }
function ScriptStringToFloat(Text: WideString): Double;
var
  i, Count: Integer;
  Value, Divisor: Double;
  C: Integer;
begin
  Count := Length(Text);
  if Count < 1 then
  begin
    Result := 0;
    Exit;
  end;
  Value := 0;
  for i := 0 to Count - 1 do
  begin
    C := Ord(Text[i + 1]);
    if (C >= Ord('0')) and (C <= Ord('9')) then Value := Value * 10 + (C - Ord('0'))
    else if C = Ord('.') then Break;
  end;
  Inc(i);
  Divisor := 10;
  while i < Count do
  begin
    C := Ord(Text[i + 1]);
    if (C >= Ord('0')) and (C <= Ord('9')) then
    begin
      Value := (C - Ord('0')) / Divisor + Value;
      Divisor := Divisor * 10;
    end;
    Inc(i);
  end;
  for i := 0 to Count - 1 do
    if Integer(Text[i + 1]) = Ord('-') then
    begin
      Value := -Value;
      Break;
    end;
  Result := Value;
end;
{ @end $45F9D4 }

{ @routine $45FAF8 IsScriptIntegerText }
function IsScriptIntegerText(Text: WideString): Boolean;
var
  i, Count: Integer;
begin
  Count := Length(Text);
  for i := 0 to Count - 1 do
    if ((Text[i + 1] < '0') or (Text[i + 1] > '9')) and
      ((Text[i + 1] <> '-') or (i > 0)) then
    begin
      Result := False;
      Exit;
    end;
  Result := True;
end;
{ @end $45FAF8 }

{ @routine $45FB78 IsNonIntegerScriptText }
function IsNonIntegerScriptText(Text: WideString): Boolean;
begin
  Result := not IsScriptIntegerText(Text);
end;
{ @end $45FB78 }

{ @routine $45FBC8 FormatScriptError }
function FormatScriptError(Code, Position: Integer): WideString;
begin
  Result := IntToStr(Code) + ',' + IntToStr(Position);
end;
{ @end $45FBC8 }

{ @routine $45FC54 TryReadFloatLiteral }
function TryReadFloatLiteral(var Token: TCodeAnalyzerUnitEC; out Value: Double): Boolean;
var
  Sign, Fraction, Exponent: Double;
  Current: TCodeAnalyzerUnitEC;
  C: WideChar;
  i, Count: Integer;
  ExponentText: WideString;
begin
  Current := Token;
  Result := False;
  Sign := 1;
  if Current = nil then Exit;
  if Current.TokenKind = ctSubtract then
  begin
    Sign := -1;
    Current := Current.Next;
    if Current = nil then Exit;
  end;
  if Current.TokenKind <> ctText then Exit;
  if not IsScriptIntegerText(Current.Text) then Exit;
  Value := ScriptStringToInt(Current.Text);
  Current := Current.Next;
  if Current = nil then Exit;
  if Current.TokenKind <> ctDot then Exit;
  Current := Current.Next;
  if Current = nil then Exit;
  if Current.TokenKind <> ctText then Exit;
  Count := Length(Current.Text);
  Fraction := 0;
  i := 0;
  while i < Count do
  begin
    C := Current.Text[i + 1];
    if (C >= '0') and (C <= '9') then Fraction := Fraction * 10 + (Ord(C) - Ord('0'))
    else if (C = 'e') or (C = 'E') then Break
    else Exit;
    Inc(i);
  end;
  if i < 1 then Exit;
  Value := Fraction / Power(10, i) + Value;
  Exponent := 0;
  if Count - 1 > i then
  begin
    ExponentText := Copy(Current.Text, i + 2, Count - i - 1);
    if not IsScriptIntegerText(ExponentText) then Exit;
    Exponent := ScriptStringToInt(ExponentText);
    Current := Current.Next;
  end
  else if i = Count - 1 then
  begin
    Current := Current.Next;
    if (Current = nil) or (Current.Next = nil) or
       (Current.Next.TokenKind <> ctText) then Exit;
    if not IsScriptIntegerText(Current.Next.Text) then Exit;
    if Current.TokenKind = ctSubtract then Exponent := -ScriptStringToInt(Current.Next.Text)
    else if Current.TokenKind = ctAdd then Exponent := ScriptStringToInt(Current.Next.Text)
    else Exit;
    Current := Current.Next.Next;
  end
  else Current := Current.Next;
  if Exponent > 0 then Value := Power(10, Exponent) * Value
  else if Exponent < 0 then Value := Value / Power(10, -Exponent);
  Value := Value * Sign;
  Token := Current;
  Result := True;
end;
{ @end $45FC54 }

{ @routine $45FF14 TryReadIntegerLiteral }
function TryReadIntegerLiteral(var Token: TCodeAnalyzerUnitEC; out Value: Integer): Boolean;
var
  Sign: Integer;
  Current: TCodeAnalyzerUnitEC;
begin
  Current := Token;
  Result := False;
  Sign := 1;
  if Current = nil then Exit;
  if Current.TokenKind = ctSubtract then
  begin
    Sign := -1;
    Current := Current.Next;
    if Current = nil then Exit;
  end;
  if Current.TokenKind <> ctText then Exit;
  if not IsScriptIntegerText(Current.Text) then Exit;
  Value := ScriptStringToInt(Current.Text);
  Current := Current.Next;
  Value := Sign * Value;
  Token := Current;
  Result := True;
end;
{ @end $45FF14 }

{ @routine $45FF74 TryReadStringLiteral }
function TryReadStringLiteral(var Token: TCodeAnalyzerUnitEC; var Value: WideString): Boolean;
var
  Current: TCodeAnalyzerUnitEC;
begin
  Current := Token;
  Result := False;
  if Current = nil then Exit;
  if Current.TokenKind <> ctStringLiteral then Exit;
  Value := Current.Text;
  Current := Current.Next;
  Token := Current;
  Result := True;
end;
{ @end $45FF74 }

{ @routine $45FFA0 TryReadDwordLiteral }
function TryReadDwordLiteral(var Token: TCodeAnalyzerUnitEC; out Value: Dword): Boolean;
var
  Current: TCodeAnalyzerUnitEC;
  C: WideChar;
  Count, i: Integer;
begin
  Value := 0;
  Current := Token;
  Result := False;
  if Current = nil then Exit;
  if Current.TokenKind <> ctText then Exit;
  Count := Length(Current.Text);
  if Count < 2 then Exit;
  C := Current.Text[Count];
  if (C = 'h') or (C = 'H') then
    for i := 0 to Count - 2 do
    begin
      C := Current.Text[i + 1];
      if (C >= '0') and (C <= '9') then Value := Value * 16 + Dword(Ord(C) - Ord('0'))
      else if (C >= 'a') and (C <= 'f') then Value := Value * 16 + Dword(Ord(C) + 10 - Ord('a'))
      else if (C >= 'A') and (C <= 'F') then Value := Value * 16 + Dword(Ord(C) + 10 - Ord('A'))
      else Exit;
    end
  else if (C = 'b') or (C = 'B') then
    for i := 0 to Count - 2 do
    begin
      C := Current.Text[i + 1];
      if (C >= '0') and (C <= '1') then Value := Value * 2 + Dword(Ord(C) - Ord('0'))
      else Exit;
    end
  else Exit;
  Current := Current.Next;
  Token := Current;
  Result := True;
end;
{ @end $45FFA0 }

{ @routine $4600BC TryReadMemberName }
function TryReadMemberName(var Token: TCodeAnalyzerUnitEC; var Name: WideString): Boolean;
begin
  Name := '';
  while (Token.TokenKind = ctText) and IsNonIntegerScriptText(Token.Text) do
  begin
    Name := Name + Token.Text;
    Token := Token.Next;
    if (Token = nil) or (Token.TokenKind <> ctDot) then Break;
    Name := Name + '.';
    Token := Token.Next;
    if (Token = nil) or (Token.TokenKind <> ctText) or not IsNonIntegerScriptText(Token.Text) then
    begin
      Name := '';
      Break;
    end;
  end;
  Result := Name <> '';
end;
{ @end $4600BC }

{ @routine $460150 TVarEC_Create }
constructor TVarEC.Create(InitialKind: TVarKind);
begin
  inherited Create;
  Kind := InitialKind;
  if InitialKind = vkFunction then FunctionValue := TCodeEC.Create;
end;
{ @end $460150 }

{ @routine $4601A8 TVarEC_Destroy }
destructor TVarEC.Destroy;
begin
  if FunctionValue <> nil then
  begin
    FunctionValue.Free;
    FunctionValue := nil;
  end;
  LibraryFunData := nil;
  inherited Destroy;
end;
{ @end $4601A8 }

{ @routine $4601EC TVarEC_ConvertToKind }
procedure TVarEC.ConvertToKind(NewKind: TVarKind);
begin
  if FunctionValue <> nil then
  begin
    FunctionValue.Free;
    FunctionValue := nil;
  end;
  if NewKind = vkInt then
  begin
    if Kind <> vkInt then
    begin
      if Kind = vkDword then IntValue := Integer(DwordValue)
      else if Kind = vkFloat then IntValue := Trunc(FloatValue)
      else if Kind = vkString then IntValue := ScriptStringToInt(StringValue)
      else IntValue := 0;
    end;
    DwordValue := 0;
    FloatValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    LibraryFunData := nil;
    FunctionValue := nil;
    ClassValue := nil;
    ArrayValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkDword then
  begin
    if Kind = vkInt then DwordValue := Dword(IntValue)
    else if Kind <> vkDword then
    begin
      if Kind = vkFloat then DwordValue := Dword(Trunc(FloatValue))
      else if Kind = vkString then DwordValue := Dword(ScriptStringToInt(StringValue))
      else DwordValue := 0;
    end;
    IntValue := 0;
    FloatValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    LibraryFunData := nil;
    FunctionValue := nil;
    ClassValue := nil;
    ArrayValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkFloat then
  begin
    if Kind = vkInt then FloatValue := IntValue
    else if Kind = vkDword then FloatValue := DwordValue
    else if Kind <> vkFloat then
    begin
      if Kind = vkString then FloatValue := ScriptStringToFloat(StringValue)
      else FloatValue := 0;
    end;
    IntValue := 0;
    DwordValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    LibraryFunData := nil;
    FunctionValue := nil;
    ClassValue := nil;
    ArrayValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkString then
  begin
    if Kind = vkInt then StringValue := IntToStr(IntValue)
    else if Kind = vkDword then StringValue := IntToStr(Int64(DwordValue))
    else if Kind = vkFloat then
    begin
      try
        StringValue := ScriptFloatToString(FloatValue);
      except
        StringValue := '';
      end;
    end
    else if Kind <> vkString then StringValue := '';
    IntValue := 0;
    DwordValue := 0;
    FloatValue := 0;
    ExternFunValue := nil;
    LibraryFunData := nil;
    FunctionValue := nil;
    ClassValue := nil;
    ArrayValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkExternFun then
  begin
    if Kind <> vkExternFun then ExternFunValue := nil;
    IntValue := 0;
    DwordValue := 0;
    FloatValue := 0;
    StringValue := '';
    LibraryFunData := nil;
    FunctionValue := nil;
    ClassValue := nil;
    ArrayValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkLibraryFun then
  begin
    if Kind <> vkLibraryFun then LibraryFunData := nil;
    IntValue := 0;
    DwordValue := 0;
    FloatValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    FunctionValue := nil;
    ClassValue := nil;
    ArrayValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkFunction then
  begin
    IntValue := 0;
    DwordValue := 0;
    FloatValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    LibraryFunData := nil;
    if FunctionValue <> nil then FunctionValue.Free;
    FunctionValue := TCodeEC.Create;
    ClassValue := nil;
    ArrayValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkClass then
  begin
    if (Kind <> vkClass) and (ClassValue <> nil) then
    begin
      ClassValue.Free;
      ClassValue := nil;
    end;
    IntValue := 0;
    DwordValue := 0;
    FloatValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    LibraryFunData := nil;
    FunctionValue := nil;
    ArrayValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkArray then
  begin
    if Kind <> vkArray then ArrayValue := nil;
    IntValue := 0;
    DwordValue := 0;
    FloatValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    LibraryFunData := nil;
    FunctionValue := nil;
    ClassValue := nil;
    RefValue := nil;
  end
  else if NewKind = vkRef then
  begin
    if Kind <> vkRef then RefValue := nil;
    IntValue := 0;
    DwordValue := 0;
    FloatValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    LibraryFunData := nil;
    FunctionValue := nil;
    ClassValue := nil;
    ArrayValue := nil;
  end;
  Kind := NewKind;
end;
{ @end $4601EC }

{ @routine $460884 TVarEC_ResetKind }
procedure TVarEC.ResetKind(NewKind: TVarKind);
begin
  if FunctionValue <> nil then
  begin
    FunctionValue.Free;
    FunctionValue := nil;
  end;
  if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.ResetKind(NewKind);
  end
  else
  begin
    Kind := NewKind;
    IntValue := 0;
    DwordValue := 0;
    FloatValue := 0;
    StringValue := '';
    ExternFunValue := nil;
    LibraryFunData := nil;
    FunctionValue := nil;
    ClassValue := nil;
    ArrayValue := nil;
    RefValue := nil;
    if NewKind = vkFunction then FunctionValue := TCodeEC.Create;
  end;
end;
{ @end $460884 }

{ @routine $460910 TVarEC_RealVType }
function TVarEC.RealVType: TVarKind;
var
  Value: TVarEC;
begin
  Value := Resolve;
  if Value = nil then Result := vkRef
  else Result := Value.Kind;
end;
{ @end $460910 }

{ @routine $460924 TVarEC_AssignFrom }
procedure TVarEC.AssignFrom(Source: TVarEC; CopyArrays: Boolean);
var
  i: Integer;
begin
  if FunctionValue <> nil then
  begin
    FunctionValue.Free;
    FunctionValue := nil;
  end;
  Name := Source.Name;
  Kind := Source.Kind;
  IntValue := Source.IntValue;
  DwordValue := Source.DwordValue;
  FloatValue := Source.FloatValue;
  StringValue := Source.StringValue;
  ExternFunValue := Source.ExternFunValue;
  ClassValue := Source.ClassValue;
  RefValue := Source.RefValue;
  if (Source.ArrayValue <> nil) and CopyArrays then
  begin
    if GetArray = nil then SetArray(TVarArrayEC.Create);
    if GetArray.Count > 0 then GetArray.Clear;
    GetArray.CopyFrom(Source.AsArray, True);
  end
  else ArrayValue := Source.ArrayValue;
  LibraryFunData := nil;
  if Source.LibraryFunData <> nil then
  begin
    SetLength(LibraryFunData, High(Source.LibraryFunData) + 1);
    for i := 0 to High(LibraryFunData) do LibraryFunData[i] := Source.LibraryFunData[i];
  end;
  FunctionValue := nil;
  if Source.FunctionValue <> nil then
  begin
    FunctionValue := TCodeEC.Create;
    FunctionValue.CopyFrom(Source.FunctionValue);
  end;
end;
{ @end $460924 }

{ @routine $460A6C TVarEC_IsEmpty }
function TVarEC.IsEmpty: Boolean;
begin
  Result := Kind = vkEmpty;
end;
{ @end $460A6C }

{ @routine $460A74 TVarEC_GetInt }
function TVarEC.GetInt: Integer;
begin
  if Kind = vkEmpty then Result := 0
  else if Kind = vkInt then Result := IntValue
  else if Kind = vkDword then Result := Integer(DwordValue)
  else if Kind = vkFloat then Result := Trunc(FloatValue)
  else if Kind = vkString then Result := ScriptStringToInt(StringValue)
  else if Kind = vkExternFun then Result := 0
  else if Kind = vkLibraryFun then Result := 0
  else if Kind = vkFunction then Result := 0
  else if Kind = vkClass then Result := 0
  else if Kind = vkArray then Result := 0
  else if Kind = vkRef then
  begin
    if RefValue = nil then Result := 0
    else Result := RefValue.AsInteger;
  end
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $460A74 }

{ @routine $460B1C TVarEC_GetDword }
function TVarEC.GetDword: Dword;
begin
  if Kind = vkEmpty then Result := 0
  else if Kind = vkInt then Result := Dword(IntValue)
  else if Kind = vkDword then Result := DwordValue
  else if Kind = vkFloat then Result := Dword(Trunc(FloatValue))
  else if Kind = vkString then Result := Dword(ScriptStringToInt(StringValue))
  else if Kind = vkExternFun then Result := 0
  else if Kind = vkLibraryFun then Result := 0
  else if Kind = vkFunction then Result := 0
  else if Kind = vkClass then Result := 0
  else if Kind = vkArray then Result := 0
  else if Kind = vkRef then
  begin
    if RefValue = nil then Result := 0
    else Result := RefValue.AsInteger;
  end
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $460B1C }

{ @routine $460BC4 TVarEC_GetFloat }
function TVarEC.GetFloat: Double;
begin
  if Kind = vkEmpty then Result := 0
  else if Kind = vkInt then Result := IntValue
  else if Kind = vkDword then Result := DwordValue
  else if Kind = vkFloat then Result := FloatValue
  else if Kind = vkString then Result := ScriptStringToFloat(StringValue)
  else if Kind = vkExternFun then Result := 0
  else if Kind = vkLibraryFun then Result := 0
  else if Kind = vkFunction then Result := 0
  else if Kind = vkClass then Result := 0
  else if Kind = vkArray then Result := 0
  else if Kind = vkRef then
  begin
    if RefValue = nil then Result := 0
    else Result := RefValue.AsFloat;
  end
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $460BC4 }

{ @routine $460CE0 TVarEC_GetString }
function TVarEC.GetString: WideString;
begin
  if Kind = vkEmpty then Result := ''
  else if Kind = vkInt then Result := IntToStr(IntValue)
  else if Kind = vkDword then Result := IntToStr(Int64(DwordValue))
  else if Kind = vkFloat then Result := ScriptFloatToString(FloatValue)
  else if Kind = vkString then Result := StringValue
  else if Kind = vkExternFun then Result := ''
  else if Kind = vkLibraryFun then Result := StringValue
  else if Kind = vkFunction then Result := ''
  else if Kind = vkClass then Result := ''
  else if Kind = vkArray then Result := ''
  else if Kind = vkRef then
  begin
    if RefValue = nil then Result := ''
    else Result := RefValue.AsString;
  end
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $460CE0 }

{ @routine $460E2C TVarEC_GetExternFun }
function TVarEC.GetExternFun: Pointer;
begin
  if Kind = vkEmpty then Result := nil
  else if Kind = vkInt then Result := nil
  else if Kind = vkDword then Result := nil
  else if Kind = vkFloat then Result := nil
  else if Kind = vkString then Result := nil
  else if Kind = vkExternFun then Result := ExternFunValue
  else if Kind = vkLibraryFun then Result := nil
  else if Kind = vkFunction then Result := nil
  else if Kind = vkClass then Result := nil
  else if Kind = vkArray then Result := nil
  else if Kind = vkRef then
  begin
    if RefValue = nil then Result := nil
    else Result := RefValue.AsExternFun;
  end
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $460E2C }

{ @routine $460ED0 TVarEC_GetFunction }
function TVarEC.GetFunction: TCodeEC;
begin
  if Kind = vkEmpty then Result := nil
  else if Kind = vkInt then Result := nil
  else if Kind = vkDword then Result := nil
  else if Kind = vkFloat then Result := nil
  else if Kind = vkString then Result := nil
  else if Kind = vkExternFun then Result := nil
  else if Kind = vkLibraryFun then Result := nil
  else if Kind = vkFunction then Result := FunctionValue
  else if Kind = vkClass then Result := nil
  else if Kind = vkArray then Result := nil
  else if Kind = vkRef then
  begin
    if RefValue = nil then Result := nil
    else Result := RefValue.AsFunction;
  end
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $460ED0 }

{ @routine $460F74 TVarEC_GetClass }
function TVarEC.GetClass: TCodeEC;
begin
  if Kind = vkEmpty then Result := nil
  else if Kind = vkInt then Result := nil
  else if Kind = vkDword then Result := nil
  else if Kind = vkFloat then Result := nil
  else if Kind = vkString then Result := nil
  else if Kind = vkExternFun then Result := nil
  else if Kind = vkLibraryFun then Result := nil
  else if Kind = vkFunction then Result := nil
  else if Kind = vkClass then Result := ClassValue
  else if Kind = vkArray then Result := nil
  else if Kind = vkRef then
  begin
    if RefValue = nil then Result := nil
    else Result := RefValue.AsFunction;
  end
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $460F74 }

{ @routine $461018 TVarEC_GetArray }
function TVarEC.GetArray: TVarArrayEC;
begin
  if Kind = vkEmpty then Result := nil
  else if Kind = vkInt then Result := nil
  else if Kind = vkDword then Result := nil
  else if Kind = vkFloat then Result := nil
  else if Kind = vkString then Result := nil
  else if Kind = vkExternFun then Result := nil
  else if Kind = vkLibraryFun then Result := nil
  else if Kind = vkFunction then Result := nil
  else if Kind = vkClass then Result := nil
  else if Kind = vkArray then Result := ArrayValue
  else if Kind = vkRef then
  begin
    if RefValue = nil then Result := nil
    else Result := RefValue.AsArray;
  end
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $461018 }

{ @routine $4610BC TVarEC_SetInt }
procedure TVarEC.SetInt(Value: Integer);
begin
  if Kind = vkEmpty then
  begin
    ResetKind(vkInt);
    IntValue := Value;
  end
  else if Kind = vkInt then
    IntValue := Value
  else if Kind = vkDword then
    DwordValue := Dword(Value)
  else if Kind = vkFloat then
    FloatValue := Value
  else if Kind = vkString then
    StringValue := IntToStr(Value)
  else if Kind = vkExternFun then
    ExternFunValue := nil
  else if Kind = vkLibraryFun then
    LibraryFunData := nil
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := nil
  else if Kind = vkArray then
    ArrayValue := nil
  else if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.AsInteger := Value
    else raise ExceptionExpressionEC.Create('Type error');
  end;
end;
{ @end $4610BC }

{ @routine $4611D4 TVarEC_SetDword }
procedure TVarEC.SetDword(Value: Dword);
begin
  if Kind = vkEmpty then
  begin
    ResetKind(vkDword);
    DwordValue := Value;
  end
  else if Kind = vkInt then
    IntValue := Integer(Value)
  else if Kind = vkDword then
    DwordValue := Value
  else if Kind = vkFloat then
    FloatValue := Value
  else if Kind = vkString then
    StringValue := IntToStr(Int64(Value))
  else if Kind = vkExternFun then
    ExternFunValue := nil
  else if Kind = vkLibraryFun then
    LibraryFunData := nil
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := nil
  else if Kind = vkArray then
    ArrayValue := nil
  else if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.AsInteger := Integer(Value)
    else raise ExceptionExpressionEC.Create('Type error');
  end;
end;
{ @end $4611D4 }

{ @routine $4612F8 TVarEC_SetFloat }
procedure TVarEC.SetFloat(Value: Double);
begin
  if Kind = vkEmpty then
  begin
    ResetKind(vkFloat);
    FloatValue := Value;
  end
  else if Kind = vkInt then
    IntValue := Trunc(Value)
  else if Kind = vkDword then
    DwordValue := Dword(Trunc(Value))
  else if Kind = vkFloat then
    FloatValue := Value
  else if Kind = vkString then
    StringValue := ScriptFloatToString(Value)
  else if Kind = vkExternFun then
    ExternFunValue := nil
  else if Kind = vkLibraryFun then
    LibraryFunData := nil
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := nil
  else if Kind = vkArray then
    ArrayValue := nil
  else if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.AsFloat := Value
    else raise ExceptionExpressionEC.Create('Type error');
  end;
end;
{ @end $4612F8 }

{ @routine $46142C TVarEC_SetString }
procedure TVarEC.SetString(const Value: WideString);
begin
  if Kind = vkEmpty then
  begin
    ResetKind(vkString);
    StringValue := Value;
  end
  else if Kind = vkInt then
    IntValue := ScriptStringToInt(Value)
  else if Kind = vkDword then
    DwordValue := Dword(ScriptStringToInt(Value))
  else if Kind = vkFloat then
    FloatValue := ScriptStringToFloat(Value)
  else if Kind = vkString then
    StringValue := Value
  else if Kind = vkExternFun then
    ExternFunValue := nil
  else if Kind = vkLibraryFun then
    StringValue := Value
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := nil
  else if Kind = vkArray then
    ArrayValue := nil
  else if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.AsString := Value
    else raise ExceptionExpressionEC.Create('Type error');
  end;
end;
{ @end $46142C }

{ @routine $461510 TVarEC_SetExternFun }
procedure TVarEC.SetExternFun(Value: Pointer);
begin
  if Kind = vkEmpty then
  begin
    ResetKind(vkExternFun);
    ExternFunValue := Value;
  end
  else if Kind = vkInt then
    IntValue := 0
  else if Kind = vkDword then
    DwordValue := 0
  else if Kind = vkFloat then
    FloatValue := 0
  else if Kind = vkString then
    StringValue := ''
  else if Kind = vkExternFun then
    ExternFunValue := Value
  else if Kind = vkLibraryFun then
    LibraryFunData := nil
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := nil
  else if Kind = vkArray then
    ArrayValue := nil
  else if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.AsExternFun := Value
    else raise ExceptionExpressionEC.Create('Type error');
  end;
end;
{ @end $461510 }

{ @routine $4615DC TVarEC_SetFunction }
procedure TVarEC.SetFunction(Value: TCodeEC);
begin
  if Kind = vkEmpty then
  begin
  end
  else if Kind = vkInt then
    IntValue := 0
  else if Kind = vkDword then
    DwordValue := 0
  else if Kind = vkFloat then
    FloatValue := 0
  else if Kind = vkString then
    StringValue := ''
  else if Kind = vkExternFun then
    ExternFunValue := nil
  else if Kind = vkLibraryFun then
    LibraryFunData := nil
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := nil
  else if Kind = vkArray then
    ArrayValue := nil
  else if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.AsFunction := Value
    else raise ExceptionExpressionEC.Create('Type error');
  end;
end;
{ @end $4615DC }

{ @routine $461698 TVarEC_SetClass }
procedure TVarEC.SetClass(Value: TCodeEC);
begin
  if Kind = vkEmpty then
  begin
    ResetKind(vkClass);
    ClassValue := Value;
  end
  else if Kind = vkInt then
    IntValue := 0
  else if Kind = vkDword then
    DwordValue := 0
  else if Kind = vkFloat then
    FloatValue := 0
  else if Kind = vkString then
    StringValue := ''
  else if Kind = vkExternFun then
    ExternFunValue := nil
  else if Kind = vkLibraryFun then
    LibraryFunData := nil
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := Value
  else if Kind = vkArray then
    ArrayValue := nil
  else if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.AsFunction := Value
    else raise ExceptionExpressionEC.Create('Type error');
  end;
end;
{ @end $461698 }

{ @routine $461764 TVarEC_SetArray }
procedure TVarEC.SetArray(Value: TVarArrayEC);
begin
  if Kind = vkEmpty then
  begin
    ResetKind(vkArray);
    ArrayValue := Value;
  end
  else if Kind = vkInt then
    IntValue := 0
  else if Kind = vkDword then
    DwordValue := 0
  else if Kind = vkFloat then
    FloatValue := 0
  else if Kind = vkString then
    StringValue := ''
  else if Kind = vkExternFun then
    ExternFunValue := nil
  else if Kind = vkLibraryFun then
    LibraryFunData := nil
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := nil
  else if Kind = vkArray then
    ArrayValue := Value
  else if Kind = vkRef then
  begin
    if RefValue <> nil then RefValue.AsArray := Value
    else raise ExceptionExpressionEC.Create('Type error');
  end;
end;
{ @end $461764 }

{ @routine $461830 TVarEC_SetRef }
procedure TVarEC.SetRef(Value: TVarEC);
begin
  if Kind = vkEmpty then
  begin
    ResetKind(vkRef);
    RefValue := Value;
  end
  else if Kind = vkInt then
    IntValue := 0
  else if Kind = vkDword then
    DwordValue := 0
  else if Kind = vkFloat then
    FloatValue := 0
  else if Kind = vkString then
    StringValue := ''
  else if Kind = vkExternFun then
    ExternFunValue := nil
  else if Kind = vkLibraryFun then
    LibraryFunData := nil
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
    ClassValue := nil
  else if Kind = vkArray then
    ArrayValue := nil
  else if Kind = vkRef then
    RefValue := Value
  else raise ExceptionExpressionEC.Create('Type error');
end;
{ @end $461830 }

{ @routine $4618F0 TVarEC_Resolve }
function TVarEC.Resolve: TVarEC;
begin
  Result := Self;
  while (Result <> nil) and (Result.Kind = vkRef) do Result := Result.RefValue;
end;
{ @end $4618F0 }

{ @routine $461900 TVarEC_PackAnsiString }
procedure TVarEC.PackAnsiString;
var
  Text: AnsiString;
  i, Count: Integer;
  Dest: PAnsiChar;
begin
  ConvertToKind(vkString);
  Count := Length(StringValue);
  if Count > 0 then
  begin
    Text := StringValue;
    Dest := PAnsiChar(PWideChar(StringValue));
    for i := 0 to Count - 1 + 1 do
    begin
      Dest^ := Text[i + 1];
      Inc(Dest);
    end;
    if Odd(Count) then SetLength(StringValue, (Count shr 1) + 1)
    else SetLength(StringValue, Count shr 1);
  end;
end;
{ @end $461900 }

{ @routine $4619AC TVarEC_UnpackAnsiString }
procedure TVarEC.UnpackAnsiString;
var
  Text: AnsiString;
  Count: Integer;
begin
  if Kind <> vkString then ConvertToKind(vkString)
  else
  begin
    Count := Length(StringValue);
    if Count > 0 then
    begin
      Text := PAnsiChar(PWideChar(StringValue));
      StringValue := Text;
    end;
  end;
end;
{ @end $4619AC }

{ @routine $461A20 FreeScriptArrayTree }
procedure FreeScriptArrayTree(Values: TVarArrayEC);
var
  i, Count: Integer;
  Item: TVarEC;
begin
  Count := Values.Count;
  for i := 0 to Count - 1 do
  begin
    Item := Values[i];
    if (Item.Kind = vkArray) and (Item.AsArray <> nil) then
    begin
      FreeScriptArrayTree(Item.AsArray);
      Item.AsArray := nil;
    end;
  end;
  Values.Free;
end;
{ @end $461A20 }

{ @routine $461A74 GrowScriptArray }
procedure GrowScriptArray(Values: TVarArrayEC; Dimensions: array of Integer; DimensionIndex: Integer);
var
  i, Count: Integer;
  Item: TVarEC;
begin
  Count := Dimensions[DimensionIndex];
  if High(Dimensions) = DimensionIndex then
  begin
    for i := Values.Count to Count - 1 do Values.Add('', vkEmpty);
  end
  else
  begin
    for i := Values.Count to Count - 1 do
    begin
      Item := Values.Add('', vkArray);
      Item.AsArray := TVarArrayEC.Create;
      GrowScriptArray(Item.AsArray, Dimensions, DimensionIndex + 1);
    end;
  end;
end;
{ @end $461A74 }

{ @routine $461BB8 ResizeScriptArray }
procedure ResizeScriptArray(Values: TVarArrayEC; Count: Integer);
var
  i, OldCount: Integer;
  Item: TVarEC;
  Dimensions: array of Integer;

  // @nested $461B40 CollectScriptArrayDimensions
  procedure CollectScriptArrayDimensions(Values: TVarArrayEC); // @addr $461B40 @note "Nested in ResizeScriptArray; collects dimensions by following each first child."
  begin
    SetLength(Dimensions, High(Dimensions) + 1 + 1);
    Dimensions[High(Dimensions)] := Values.Count;
    if (Values.Count > 0) and (Values[0].ValueKind = vkArray) then
      CollectScriptArrayDimensions(Values[0].AsArray);
  end;

begin
  OldCount := Values.Count;
  if Count = OldCount then Exit;
  if Count < OldCount then
  begin
    for i := Count to OldCount - 1 do
    begin
      Item := Values[i];
      if (Item.Kind = vkArray) and (Item.AsArray <> nil) then FreeScriptArrayTree(Item.AsArray);
    end;
    for i := OldCount - 1 downto Count do Values.Delete(i);
  end
  else
  begin
    Dimensions := nil;
    CollectScriptArrayDimensions(Values);
    Dimensions[0] := Count;
    GrowScriptArray(Values, Dimensions, 0);
  end;
end;
{ @end $461BB8 }

{ @routine $461CB0 TVarEC_CreateArray }
procedure TVarEC.CreateArray(Dimensions: array of Integer);
begin
  ResetKind(vkArray);
  ArrayValue := TVarArrayEC.Create;
  GrowScriptArray(ArrayValue, Dimensions, 0);
end;
{ @end $461CB0 }

{ @routine $461D04 TVarEC_ResizeArray }
procedure TVarEC.ResizeArray(Count, Dimension: Integer);
begin
  if RealVType = vkArray then
  begin
    if Count <= 0 then FreeArray
    else if Dimension <= 0 then
    begin
      if GetArray = nil then CreateArray([Count])
      else ResizeScriptArray(GetArray, Count);
    end;
  end;
end;
{ @end $461D04 }

{ @routine $461D58 TVarEC_FreeArray }
procedure TVarEC.FreeArray;
begin
  if (RealVType = vkArray) and (GetArray <> nil) then
  begin
    FreeScriptArrayTree(GetArray);
    SetArray(nil);
  end;
end;
{ @end $461D58 }

{ @routine $461D88 TVarEC_OAdd }
procedure TVarEC.OAdd(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger + Right.AsInteger);
      vkDword: SetDword(Left.AsDword + Right.AsDword);
      vkFloat: SetFloat(Left.AsFloat + Right.AsFloat);
      vkString: SetString(Left.AsString + Right.AsString);
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OAdd');
    end;
  end;
end;
{ @end $461D88 }

{ @routine $461F24 TVarEC_OSub }
procedure TVarEC.OSub(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger - Right.AsInteger);
      vkDword: SetDword(Left.AsDword - Right.AsDword);
      vkFloat: SetFloat(Left.AsFloat - Right.AsFloat);
      vkString: SetString(Left.AsString + Right.AsString);
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OSub');
    end;
  end;
end;
{ @end $461F24 }

{ @routine $4620C0 TVarEC_OMul }
procedure TVarEC.OMul(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger * Right.AsInteger);
      vkDword: SetDword(Left.AsDword * Right.AsDword);
      vkFloat: SetFloat(Left.AsFloat * Right.AsFloat);
      vkString: SetString(Left.AsString + Right.AsString);
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OMul');
    end;
  end;
end;
{ @end $4620C0 }

{ @routine $46225C TVarEC_ODiv }
procedure TVarEC.ODiv(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger div Right.AsInteger);
      vkDword: SetDword(Left.AsDword div Right.AsDword);
      vkFloat: SetFloat(Left.AsFloat / Right.AsFloat);
      vkString: SetString(Left.AsString + Right.AsString);
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('ODiv');
    end;
  end;
end;
{ @end $46225C }

{ @routine $462404 TVarEC_OMod }
procedure TVarEC.OMod(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger mod Right.AsInteger);
      vkDword: SetDword(Left.AsDword mod Right.AsDword);
      vkFloat: SetFloat(Trunc(Left.AsFloat) mod Trunc(Right.AsFloat));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OMod');
    end;
  end;
end;
{ @end $462404 }

{ @routine $462560 TVarEC_OBitAnd }
procedure TVarEC.OBitAnd(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger and Right.AsInteger);
      vkDword: SetDword(Left.AsDword and Right.AsDword);
      vkFloat: SetFloat(Trunc(Left.AsFloat) and Trunc(Right.AsFloat));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OBitAnd');
    end;
  end;
end;
{ @end $462560 }

{ @routine $4626BC TVarEC_OBitOr }
procedure TVarEC.OBitOr(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger or Right.AsInteger);
      vkDword: SetDword(Left.AsDword or Right.AsDword);
      vkFloat: SetFloat(Trunc(Left.AsFloat) or Trunc(Right.AsFloat));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OBitOr');
    end;
  end;
end;
{ @end $4626BC }

{ @routine $462818 TVarEC_OBitXor }
procedure TVarEC.OBitXor(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger xor Right.AsInteger);
      vkDword: SetDword(Left.AsDword xor Right.AsDword);
      vkFloat: SetFloat(Trunc(Left.AsFloat) xor Trunc(Right.AsFloat));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OBitXor');
    end;
  end;
end;
{ @end $462818 }

{ @routine $462974 TVarEC_OAnd }
procedure TVarEC.OAnd(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Ord((Left.AsInteger <> 0) and (Right.AsInteger <> 0)));
      vkDword: SetDword(Ord((Left.AsDword <> 0) and (Right.AsDword <> 0)));
      vkFloat: SetFloat(Integer((Left.AsFloat <> 0) and (Right.AsFloat <> 0)));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OAnd');
    end;
  end;
end;
{ @end $462974 }

{ @routine $462AEC TVarEC_OOr }
procedure TVarEC.OOr(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Ord((Left.AsInteger <> 0) or (Right.AsInteger <> 0)));
      vkDword: SetDword(Ord((Left.AsDword <> 0) or (Right.AsDword <> 0)));
      vkFloat: SetFloat(Integer((Left.AsFloat <> 0) or (Right.AsFloat <> 0)));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OOr');
    end;
  end;
end;
{ @end $462AEC }

{ @routine $462C60 TVarEC_OShl }
procedure TVarEC.OShl(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger shl Right.AsInteger);
      vkDword: SetDword(Left.AsDword shl Right.AsDword);
      vkFloat: SetFloat(Trunc(Left.AsFloat) shl Trunc(Right.AsFloat));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OShl');
    end;
  end;
end;
{ @end $462C60 }

{ @routine $462DB8 TVarEC_OShr }
procedure TVarEC.OShr(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Left.AsInteger shr Right.AsInteger);
      vkDword: SetDword(Left.AsDword shr Right.AsDword);
      vkFloat: SetFloat(Trunc(Left.AsFloat) shr Trunc(Right.AsFloat));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OShr');
    end;
  end;
end;
{ @end $462DB8 }

{ @routine $462F10 TVarEC_OEqual }
procedure TVarEC.OEqual(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Ord(Left.AsInteger = Right.AsInteger));
      vkDword: SetDword(Ord(Left.AsDword = Right.AsDword));
      vkFloat: SetFloat(Integer(Left.AsFloat = Right.AsFloat));
      vkString: SetString(IntToStr(Ord(Left.AsString = Right.AsString)));
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OEqual');
    end;
  end;
end;
{ @end $462F10 }

{ @routine $4630F8 TVarEC_ONotEqual }
procedure TVarEC.ONotEqual(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Ord(Left.AsInteger <> Right.AsInteger));
      vkDword: SetDword(Ord(Left.AsDword <> Right.AsDword));
      vkFloat: SetFloat(Integer(Left.AsFloat <> Right.AsFloat));
      vkString: SetString(IntToStr(Ord(Left.AsString <> Right.AsString)));
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('ONotEqual');
    end;
  end;
end;
{ @end $4630F8 }

{ @routine $4632E4 TVarEC_OLess }
procedure TVarEC.OLess(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Ord(Left.AsInteger < Right.AsInteger));
      vkDword: SetDword(Ord(Left.AsDword < Right.AsDword));
      vkFloat: SetFloat(Integer(Left.AsFloat < Right.AsFloat));
      vkString: SetString(IntToStr(Ord(Left.AsString < Right.AsString)));
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OLess');
    end;
  end;
end;
{ @end $4632E4 }

{ @routine $4634CC TVarEC_OMore }
procedure TVarEC.OMore(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Ord(Left.AsInteger > Right.AsInteger));
      vkDword: SetDword(Ord(Left.AsDword > Right.AsDword));
      vkFloat: SetFloat(Integer(Left.AsFloat > Right.AsFloat));
      vkString: SetString(IntToStr(Ord(Left.AsString > Right.AsString)));
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OMore');
    end;
  end;
end;
{ @end $4634CC }

{ @routine $4636B4 TVarEC_OLessEqual }
procedure TVarEC.OLessEqual(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Ord(Left.AsInteger <= Right.AsInteger));
      vkDword: SetDword(Ord(Left.AsDword <= Right.AsDword));
      vkFloat: SetFloat(Integer(Left.AsFloat <= Right.AsFloat));
      vkString: SetString(IntToStr(Ord(Left.AsString <= Right.AsString)));
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OLessEqual');
    end;
  end;
end;
{ @end $4636B4 }

{ @routine $4638A0 TVarEC_OMoreEqual }
procedure TVarEC.OMoreEqual(Left, Right: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Left.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Left.ValueKind of
      vkInt: SetInt(Ord(Left.AsInteger >= Right.AsInteger));
      vkDword: SetDword(Ord(Left.AsDword >= Right.AsDword));
      vkFloat: SetFloat(Integer(Left.AsFloat >= Right.AsFloat));
      vkString: SetString(IntToStr(Ord(Left.AsString >= Right.AsString)));
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OMoreEqual');
    end;
  end;
end;
{ @end $4638A0 }

{ @routine $463A8C TVarEC_OMinus }
procedure TVarEC.OMinus(Value: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Value.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Value.ValueKind of
      vkInt: SetInt(-Value.AsInteger);
      vkDword: SetDword(Dword(-Int64(Value.AsDword)));
      vkFloat: SetFloat(-Value.AsFloat);
      vkString: SetString(Value.AsString);
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OMinus');
    end;
  end;
end;
{ @end $463A8C }

{ @routine $463BE8 TVarEC_OBitNot }
procedure TVarEC.OBitNot(Value: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Value.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Value.ValueKind of
      vkInt: SetInt(not Value.AsInteger);
      vkDword: SetDword(not Value.AsDword);
      vkFloat: SetFloat(0);
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('OBitNot');
    end;
  end;
end;
{ @end $463BE8 }

{ @routine $463CF0 TVarEC_ONot }
procedure TVarEC.ONot(Value: TVarEC);
begin
  if RealVType = vkEmpty then ResetKind(Value.ValueKind);
  if RealVType <> vkEmpty then
  begin
    case Value.ValueKind of
      vkInt: SetInt(Ord(Value.AsInteger = 0));
      vkDword: SetDword(Ord(Value.AsInteger = 0));
      vkFloat: SetFloat(Integer(Value.AsFloat = 0));
      vkString: SetString('');
      vkExternFun: SetExternFun(nil);
      vkFunction: SetFunction(nil);
      vkClass: SetClass(nil);
      vkArray: SetArray(nil);
    else raise ExceptionExpressionEC.Create('ONot');
    end;
  end;
end;
{ @end $463CF0 }

{ @routine $463E28 TVarEC_Assume }
procedure TVarEC.Assume(Source: TVarEC; CopyArrays: Boolean);
var
  Dest: TVarEC;
  i: Integer;
begin
  Dest := Self;
  if Kind = vkRef then
  begin
    Dest := Resolve;
    if Dest = nil then Exit;
  end;
  if (Dest.Kind = vkExternFun) and (Source.Kind <> vkExternFun) then
    raise Exception.Create('Error assigning to function ' + Dest.Name);
  if Dest.Kind = vkEmpty then Dest.ResetKind(Source.ValueKind);
  if Dest.Kind = vkEmpty then
  begin
  end
  else if Dest.Kind = vkInt then Dest.AsInteger := Source.AsInteger
  else if Dest.Kind = vkDword then Dest.AsDword := Source.AsDword
  else if Dest.Kind = vkFloat then Dest.AsFloat := Source.AsFloat
  else if Dest.Kind = vkString then Dest.AsString := Source.AsString
  else if Dest.Kind = vkExternFun then Dest.AsExternFun := Source.AsExternFun
  else if Dest.Kind = vkLibraryFun then
  begin
    Dest.LibraryFunData := nil;
    if Source.LibraryFunData <> nil then
    begin
      SetLength(Dest.LibraryFunData, High(Source.LibraryFunData) + 1);
      for i := 0 to High(Dest.LibraryFunData) do Dest.LibraryFunData[i] := Source.LibraryFunData[i];
    end;
    Dest.AsString := Source.AsString;
  end
  else if Dest.Kind = vkFunction then Dest.AsFunction := Source.AsFunction
  else if Dest.Kind = vkClass then Dest.AsClass := Source.AsClass
  else if Dest.Kind = vkArray then
  begin
    if not CopyArrays then Dest.AsArray := Source.AsArray
    else
    begin
      if Dest.AsArray = nil then Dest.AsArray := TVarArrayEC.Create;
      if Dest.AsArray.Count > 0 then Dest.AsArray.Clear;
      Dest.AsArray.CopyFrom(Source.AsArray, True);
    end;
  end
  else raise ExceptionExpressionEC.Create('OAssume');
end;
{ @end $463E28 }

{ @routine $4640F0 TVarEC_EqualsValue }
function TVarEC.EqualsValue(Other: TVarEC): Boolean;
begin
  case RealVType of
    vkEmpty: Result := IsEmpty = Other.IsEmpty;
    vkInt: Result := GetInt = Other.AsInteger;
    vkDword: Result := GetDword = Other.AsDword;
    vkFloat: Result := GetFloat = Other.AsFloat;
    vkString: Result := GetString = Other.AsString;
    vkExternFun: Result := False;
    vkFunction: Result := False;
    vkClass: Result := GetClass = Other.AsClass;
    vkArray: Result := False;
  else raise ExceptionExpressionEC.Create('Equal');
  end;
end;
{ @end $4640F0 }

{ @routine $464268 TVarEC_LessThan }
function TVarEC.LessThan(Other: TVarEC): Boolean;
begin
  case RealVType of
    vkEmpty: Result := IsEmpty < Other.IsEmpty;
    vkInt: Result := GetInt < Other.AsInteger;
    vkDword: Result := GetDword < Other.AsDword;
    vkFloat: Result := GetFloat < Other.AsFloat;
    vkString: Result := GetString < Other.AsString;
    vkExternFun: Result := False;
    vkFunction: Result := False;
    vkClass: Result := False;
    vkArray: Result := False;
  else raise ExceptionExpressionEC.Create('Less');
  end;
end;
{ @end $464268 }

{ @routine $4643C8 TVarEC_GreaterThan }
function TVarEC.GreaterThan(Other: TVarEC): Boolean;
begin
  case RealVType of
    vkEmpty: Result := IsEmpty > Other.IsEmpty;
    vkInt: Result := GetInt > Other.AsInteger;
    vkDword: Result := GetDword > Other.AsDword;
    vkFloat: Result := GetFloat > Other.AsFloat;
    vkString: Result := GetString > Other.AsString;
    vkExternFun: Result := False;
    vkFunction: Result := False;
    vkClass: Result := False;
    vkArray: Result := False;
  else raise ExceptionExpressionEC.Create('More');
  end;
end;
{ @end $4643C8 }

{ @routine $464528 TVarEC_IsTrue }
function TVarEC.IsTrue: Boolean;
begin
  case RealVType of
    vkEmpty: Result := False;
    vkInt: Result := GetInt <> 0;
    vkDword: Result := GetDword <> 0;
    vkFloat: Result := GetFloat <> 0;
    vkString: Result := GetString <> '';
    vkExternFun: Result := False;
    vkLibraryFun: Result := Resolve.LibraryFunData <> nil;
    vkFunction: Result := False;
    vkClass: Result := GetClass <> nil;
    vkArray: Result := False;
  else raise ExceptionExpressionEC.Create('IsTrue');
  end;
end;
{ @end $464528 }

{ @routine $464658 TVarEC_SaveToBuffer }
procedure TVarEC.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(Name);
  Buffer.AddAnsiChar(AnsiChar(Kind));
  if Kind = vkEmpty then
  begin
  end
  else if Kind = vkInt then
  begin
    Buffer.AddIntegerValue(IntValue);
  end
  else if Kind = vkDword then
  begin
    Buffer.AddDWord(DwordValue);
  end
  else if Kind = vkFloat then
  begin
    Buffer.AddDouble(FloatValue);
  end
  else if Kind = vkString then
  begin
    Buffer.AddWideStringZ(StringValue);
  end
  else if Kind = vkExternFun then
  begin
  end
  else if Kind = vkLibraryFun then
  begin
  end
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
  begin
  end
  else if Kind = vkArray then
  begin
    ArrayValue.SaveToBuffer(Buffer);
  end
  else if Kind = vkRef then
  begin
  end;
end;
{ @end $464658 }

{ @routine $4646E4 TVarEC_LoadFromBuffer }
procedure TVarEC.LoadFromBuffer(Buffer: TBufEC);
begin
  Name := Buffer.ReadWideString;
  ResetKind(TVarKind(Buffer.GetByte));
  if Kind = vkEmpty then
  begin
  end
  else if Kind = vkInt then
  begin
    IntValue := Buffer.GetInt32;
  end
  else if Kind = vkDword then
  begin
    DwordValue := Buffer.GetUInt32;
  end
  else if Kind = vkFloat then
  begin
    FloatValue := Buffer.GetDouble;
  end
  else if Kind = vkString then
  begin
    StringValue := Buffer.ReadWideString;
  end
  else if Kind = vkExternFun then
  begin
  end
  else if Kind = vkLibraryFun then
  begin
  end
  else if Kind = vkFunction then
  begin
  end
  else if Kind = vkClass then
  begin
  end
  else if Kind = vkArray then
  begin
    ArrayValue := TVarArrayEC.Create;
    ArrayValue.LoadFromBuffer(Buffer);
  end
  else if Kind = vkRef then
  begin
  end;
end;
{ @end $4646E4 }

{ @routine $4647D4 TVarArrayEC_Create }
constructor TVarArrayEC.Create;
begin
  inherited Create;
end;
{ @end $4647D4 }

{ @routine $46480C TVarArrayEC_Destroy }
destructor TVarArrayEC.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $46480C }

{ @routine $464838 TVarArrayEC_ClearStorage }
procedure TVarArrayEC.ClearStorage;
begin
  if Data <> nil then
  begin
    HeapFree(GetProcessHeap, 0, Data);
    Data := nil;
  end;
  if NameOrder <> nil then
  begin
    HeapFree(GetProcessHeap, 0, NameOrder);
    NameOrder := nil;
  end;
  Count := 0;
end;
{ @end $464838 }

{ @routine $46487C TVarArrayEC_Clear }
procedure TVarArrayEC.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if (GetItem(i).Kind = vkArray) and (GetItem(i).AsArray <> nil) then GetItem(i).AsArray.Clear;
    GetItem(i).Free;
  end;
  ClearStorage;
end;
{ @end $46487C }

{ @routine $4648E0 TVarArrayEC_CopyFrom }
procedure TVarArrayEC.CopyFrom(Source: TVarArrayEC; CopyArrays: Boolean);
var
  Item, SourceItem: TVarEC;
  i: Integer;
begin
  Clear;
  Count := Source.Count;
  if Count < 1 then Exit;
  Data := HeapAlloc(GetProcessHeap, 0, Count * SizeOf(TVarEC));
  NameOrder := HeapAlloc(GetProcessHeap, 0, Count * SizeOf(Integer));
  CopyMemory(NameOrder, Source.NameOrder, Count * SizeOf(Integer));
  for i := 0 to Count - 1 do
  begin
    SourceItem := Source[i];
    Item := TVarEC.Create(vkEmpty);
    SetItem(i, Item);
    Item.Name := SourceItem.Name;
    Item.AssignFrom(SourceItem, CopyArrays);
  end;
end;
{ @end $4648E0 }

{ @routine $4649AC TVarArrayEC_FindNameOrderIndex }
function TVarArrayEC.FindNameOrderIndex(const Name: WideString): Integer;
var
  Low, High, Middle, Comparison: Integer;
  Item: TVarEC;
begin
  if Count < 1 then
  begin
    Result := -1;
    Exit;
  end;
  Low := 0;
  High := Count - 1;
  while True do
  begin
    Middle := (High - Low) div 2 + Low;
    Item := GetItemByNameOrder(Middle);
    Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Item.Name));
    if Comparison = 0 then
    begin
      Result := Middle;
      Exit;
    end
    else if Comparison < 0 then High := Middle - 1
    else Low := Middle + 1;
    if High < Low then Break;
  end;
  Result := -1;
end;
{ @end $4649AC }

{ @routine $464A40 TVarArrayEC_FindNameInsertionIndex }
function TVarArrayEC.FindNameInsertionIndex(const Name: WideString): Integer;
var
  Low, High, Middle, Comparison: Integer;
  Item: TVarEC;
begin
  if Count <= 0 then
  begin
    Result := 0;
    Exit;
  end;
  Low := 0;
  High := Count - 1;
  while True do
  begin
    Middle := (High - Low) div 2 + Low;
    Item := GetItemByNameOrder(Middle);
    Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Item.Name));
    if Comparison = 0 then
    begin
      Result := Middle;
      Exit;
    end;
    if Comparison < 0 then High := Middle - 1
    else Low := Middle + 1;
    if High < Low then Break;
  end;
  if Comparison < 0 then Result := Middle
  else Result := Middle + 1;
end;
{ @end $464A40 }

{ @routine $464AD8 TVarArrayEC_SetNameOrderIndex }
procedure TVarArrayEC.SetNameOrderIndex(Index: Integer; DataIndex: Integer);
asm
  PUSH EAX
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TVarArrayEC.NameOrder
  MOV EBX, DataIndex
  MOV [EAX], EBX
  POP EBX
  POP EAX
end;
{ @end $464AD8 }

{ @routine $464AEC TVarArrayEC_GetNameOrderIndex }
function TVarArrayEC.GetNameOrderIndex(Index: Integer): Integer;
asm
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TVarArrayEC.NameOrder
  MOV EAX, [EAX]
  POP EBX
end;
{ @end $464AEC }

{ @routine $464AFC TVarArrayEC_GetItemByNameOrder }
function TVarArrayEC.GetItemByNameOrder(Index: Integer): TVarEC;
asm
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TVarArrayEC.NameOrder
  MOV EAX, [EAX]
  MOV EBX, [EBX].TVarArrayEC.Data
  MOV EAX, [EBX + EAX * 4]
  POP EBX
end;
{ @end $464AFC }

{ @routine $464B14 TVarArrayEC_FindNameOrderForDataIndex }
function TVarArrayEC.FindNameOrderForDataIndex(DataIndex: Integer): Integer;
asm
  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  MOV EBX, DataIndex
  MOV EAX, Self
  MOV ECX, [EAX].TVarArrayEC.Count
  XOR EDX, EDX
  MOV ESI, [EAX].TVarArrayEC.NameOrder
  MOV EAX, -1
  TEST ECX, ECX
  JZ @@Done
@@Next:
  MOV EAX, [ESI]
  CMP EAX, EBX
  JZ @@Found
  ADD ESI, 4
  INC EDX
  DEC ECX
  JNZ @@Next
  MOV EAX, -1
  JMP @@Done
@@Found:
  MOV EAX, EDX
@@Done:
  POP ESI
  POP EDX
  POP ECX
  POP EBX
end;
{ @end $464B14 }

{ @routine $464B48 TVarArrayEC_GetItem }
function TVarArrayEC.GetItem(Index: Integer): TVarEC;
asm
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TVarArrayEC.Data
  MOV EAX, [EAX]
  POP EBX
end;
{ @end $464B48 }

{ @routine $464B58 TVarArrayEC_SetItem }
procedure TVarArrayEC.SetItem(Index: Integer; Value: TVarEC);
asm
  PUSH EAX
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TVarArrayEC.Data
  MOV EBX, Value
  MOV [EAX], EBX
  POP EBX
  POP EAX
end;
{ @end $464B58 }

{ @routine $464B6C TVarArrayEC_GetItemNE }
function TVarArrayEC.GetItemNE(Index: Integer): TVarEC;
begin
  if (Index < 0) or (Index >= Count) then Result := nil
  else Result := GetItem(Index);
end;
{ @end $464B6C }

{ @routine $464B80 TVarArrayEC_IndexOf }
function TVarArrayEC.IndexOf(Value: TVarEC): Integer;
asm
  PUSH ESI
  PUSH EDX
  PUSH ECX
  PUSH EBX
  MOV EBX, Value
  MOV EAX, Self
  MOV ECX, [EAX].TVarArrayEC.Count
  XOR EDX, EDX
  MOV ESI, [EAX].TVarArrayEC.Data
  MOV EAX, -1
  TEST ECX, ECX
  JZ @@Done
@@Next:
  MOV EAX, [ESI]
  CMP EAX, EBX
  JZ @@Found
  ADD ESI, 4
  INC EDX
  DEC ECX
  JNZ @@Next
  MOV EAX, -1
  JMP @@Done
@@Found:
  MOV EAX, EDX
@@Done:
  POP EBX
  POP ECX
  POP EDX
  POP ESI
end;
{ @end $464B80 }

{ @routine $464BB4 TVarArrayEC_GetVar }
function TVarArrayEC.GetVar(const Name: WideString): TVarEC;
begin
  Result := GetVarNE(Name);
  if Result = nil then raise ExceptionExpressionEC.Create('Var not found:' + Name);
end;
{ @end $464BB4 }

{ @routine $464C5C TVarArrayEC_GetVarNE }
function TVarArrayEC.GetVarNE(const Name: WideString): TVarEC;
var
  Low, High, Middle, Comparison: Integer;
  Item: TVarEC;
begin
  if Count < 1 then
  begin
    Result := nil;
    Exit;
  end;
  Low := 0;
  High := Count - 1;
  while True do
  begin
    Middle := (High - Low) div 2 + Low;
    Item := GetItemByNameOrder(Middle);
    Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Item.Name));
    if Comparison = 0 then
    begin
      Result := GetItem(GetNameOrderIndex(Middle));
      Exit;
    end
    else if Comparison < 0 then High := Middle - 1
    else Low := Middle + 1;
    if High < Low then Break;
  end;
  Result := nil;
end;
{ @end $464C5C }

{ @routine $464D00 TVarArrayEC_Delete }
procedure TVarArrayEC.Delete(Index: Integer);
var
  i, NameIndex, DataIndex: Integer;
  Item: TVarEC;
begin
  if Index < 0 then Exit;
  if Index >= Count then Exit;
  Item := GetItem(Index);
  if Item <> nil then Item.Free;
  NameIndex := FindNameOrderForDataIndex(Index);
  for i := NameIndex to Count - 2 do SetNameOrderIndex(i, GetNameOrderIndex(i + 1));
  for i := Index to Count - 2 do SetItem(i, GetItem(i + 1));
  Dec(Count);
  for i := 0 to Count - 1 do
  begin
    DataIndex := GetNameOrderIndex(i);
    if DataIndex > Index then SetNameOrderIndex(i, DataIndex - 1);
  end;
  if Count < 1 then Clear;
end;
{ @end $464D00 }

{ @routine $464DC0 TVarArrayEC_Remove }
procedure TVarArrayEC.Remove(Value: TVarEC);
begin
  Delete(IndexOf(Value));
end;
{ @end $464DC0 }

{ @routine $464DDC TVarArrayEC_DeleteByName }
procedure TVarArrayEC.DeleteByName(const Name: WideString);
var
  Index, i, NameIndex, DataIndex: Integer;
  Item: TVarEC;
begin
  NameIndex := FindNameOrderIndex(Name);
  if NameIndex < 0 then Exit;
  Index := GetNameOrderIndex(NameIndex);
  Item := GetItem(Index);
  if Item <> nil then Item.Free;
  for i := NameIndex to Count - 2 do SetNameOrderIndex(i, GetNameOrderIndex(i + 1));
  for i := Index to Count - 2 do SetItem(i, GetItem(i + 1));
  Dec(Count);
  for i := 0 to Count - 1 do
  begin
    DataIndex := GetNameOrderIndex(i);
    if DataIndex > Index then SetNameOrderIndex(i, DataIndex - 1);
  end;
  if Count < 1 then Clear;
end;
{ @end $464DDC }

{ @routine $464E98 TVarArrayEC_AddItem }
procedure TVarArrayEC.AddItem(Value: TVarEC);
var
  i, InsertionIndex: Integer;
begin
  if Data = nil then Data := HeapAlloc(GetProcessHeap, 0, (Count + 1) * SizeOf(TVarEC))
  else Data := HeapReAlloc(GetProcessHeap, 0, Data, (Count + 1) * SizeOf(TVarEC));
  SetItem(Count, Value);
  InsertionIndex := FindNameInsertionIndex(Value.Name);
  if InsertionIndex >= Count then
  begin
    Inc(Count);
    if NameOrder = nil then NameOrder := HeapAlloc(GetProcessHeap, 0, Count * SizeOf(Integer))
    else NameOrder := HeapReAlloc(GetProcessHeap, 0, NameOrder, Count * SizeOf(Integer));
    SetNameOrderIndex(Count - 1, Count - 1);
  end
  else
  begin
    Inc(Count);
    NameOrder := HeapReAlloc(GetProcessHeap, 0, NameOrder, Count * SizeOf(Integer));
    for i := Count - 1 downto InsertionIndex + 1 do SetNameOrderIndex(i, GetNameOrderIndex(i - 1));
    SetNameOrderIndex(InsertionIndex, Count - 1);
  end;
end;
{ @end $464E98 }

{ @routine $464FA4 TVarArrayEC_Add }
function TVarArrayEC.Add(const Name: WideString; Kind: TVarKind): TVarEC;
var
  Item: TVarEC;
begin
  Item := TVarEC.Create(Kind);
  Item.Name := Name;
  try
    AddItem(Item);
  except
    Item.Free;
    raise;
  end;
  Result := Item;
end;
{ @end $464FA4 }

{ @routine $465010 TVarArrayEC_SaveToBuffer }
procedure TVarArrayEC.SaveToBuffer(Buffer: TBufEC);
var
  i: Integer;
begin
  Buffer.AddIntegerValue(Count);
  for i := 0 to Count - 1 do GetItem(i).SaveToBuffer(Buffer);
end;
{ @end $465010 }

{ @routine $465048 TVarArrayEC_LoadFromBuffer }
procedure TVarArrayEC.LoadFromBuffer(Buffer: TBufEC);
var
  ItemCount, i: Integer;
  Item: TVarEC;
begin
  Clear;
  ItemCount := Buffer.GetInt32;
  for i := 0 to ItemCount - 1 do
  begin
    Item := TVarEC.Create(vkEmpty);
    Item.LoadFromBuffer(Buffer);
    AddItem(Item);
  end;
end;
{ @end $465048 }

{ @routine $465090 TVarArrayEC_AppendFromBuffer }
procedure TVarArrayEC.AppendFromBuffer(Buffer: TBufEC);
var
  ItemCount, i: Integer;
  Item: TVarEC;
begin
  ItemCount := Buffer.GetInt32;
  for i := 0 to ItemCount - 1 do
  begin
    Item := TVarEC.Create(vkEmpty);
    Item.LoadFromBuffer(Buffer);
    AddItem(Item);
  end;
end;
{ @end $465090 }

{ @routine $4650D4 TCodeAnalyzerEC_Create }
constructor TCodeAnalyzerEC.Create;
begin
  inherited Create;
end;
{ @end $4650D4 }

{ @routine $46510C TCodeAnalyzerEC_Destroy }
destructor TCodeAnalyzerEC.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $46510C }

{ @routine $465138 TCodeAnalyzerEC_Clear }
procedure TCodeAnalyzerEC.Clear;
var
  Token, Previous: TCodeAnalyzerUnitEC;
begin
  Token := First;
  while Token <> nil do
  begin
    Previous := Token;
    Token := Token.Next;
    Previous.Free;
  end;
  First := nil;
  Last := nil;
  Token := FirstFree;
  while Token <> nil do
  begin
    Previous := Token;
    Token := Token.Next;
    Previous.Free;
  end;
  FirstFree := nil;
  LastFree := nil;
end;
{ @end $465138 }

{ @routine $465184 TCodeAnalyzerEC_ReserveTokens }
procedure TCodeAnalyzerEC.ReserveTokens(Count: Integer);
var
  Token: TCodeAnalyzerUnitEC;
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Token := TCodeAnalyzerUnitEC.Create;
    if LastFree <> nil then LastFree.Next := Token;
    Token.Prev := LastFree;
    Token.Next := nil;
    LastFree := Token;
    if FirstFree = nil then FirstFree := Token;
  end;
end;
{ @end $465184 }

{ @routine $4651C4 TCodeAnalyzerEC_AcquireToken }
function TCodeAnalyzerEC.AcquireToken: TCodeAnalyzerUnitEC;
var
  Token: TCodeAnalyzerUnitEC;
begin
  if FirstFree = nil then ReserveTokens(64);
  Token := LastFree;
  if Token.Prev <> nil then Token.Prev.Next := Token.Next;
  if Token.Next <> nil then Token.Next.Prev := Token.Prev;
  if LastFree = Token then LastFree := Token.Prev;
  if FirstFree = Token then FirstFree := Token.Next;
  Result := Token;
end;
{ @end $4651C4 }

{ @routine $465210 TCodeAnalyzerEC_RecycleToken }
procedure TCodeAnalyzerEC.RecycleToken(Token: TCodeAnalyzerUnitEC);
begin
  if LastFree <> nil then LastFree.Next := Token;
  Token.Prev := LastFree;
  Token.Next := nil;
  LastFree := Token;
  if FirstFree = nil then FirstFree := Token;
end;
{ @end $465210 }

{ @routine $465234 TCodeAnalyzerEC_ClearTokens }
procedure TCodeAnalyzerEC.ClearTokens;
begin
  while First <> nil do DeleteToken(Last);
end;
{ @end $465234 }

{ @routine $46524C TCodeAnalyzerEC_AddToken }
function TCodeAnalyzerEC.AddToken: TCodeAnalyzerUnitEC;
var
  Token: TCodeAnalyzerUnitEC;
begin
  Token := AcquireToken;
  if Last <> nil then Last.Next := Token;
  Token.Prev := Last;
  Token.Next := nil;
  Last := Token;
  if First = nil then First := Token;
  Result := Token;
end;
{ @end $46524C }

{ @routine $46527C TCodeAnalyzerEC_DeleteToken }
procedure TCodeAnalyzerEC.DeleteToken(Token: TCodeAnalyzerUnitEC);
begin
  if Token.Prev <> nil then Token.Prev.Next := Token.Next;
  if Token.Next <> nil then Token.Next.Prev := Token.Prev;
  if Last = Token then Last := Token.Prev;
  if First = Token then First := Token.Next;
  RecycleToken(Token);
end;
{ @end $46527C }

{ @routine $4652B4 TCodeAnalyzerEC_AppendText }
procedure TCodeAnalyzerEC.AppendText(Text: WideString; SourceOffset, NewlineOffset: Integer);
var
  C: WideChar;
  Index: Integer;
  Token: TCodeAnalyzerUnitEC;
  TextLength, QuoteStart, RunStart, RunLength, HexValue, HexDigits: Integer;
begin
  TextLength := Length(Text);
  QuoteStart := -1;
  RunStart := -1;
  RunLength := 0;
  Index := 0;
  while Index < TextLength do
  begin
    C := Text[Index + 1];
    if QuoteStart = -1 then
    begin
      if (C = '(') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctOpenParen;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = ')') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctCloseParen;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '{') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctOpenBrace;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '}') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctCloseBrace;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '[') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctOpenBracket;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = ']') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctCloseBracket;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '/') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '*') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctBlockCommentStart;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '*') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '/') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctBlockCommentEnd;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '/') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '/') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctLineComment;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '.') then
      begin
        // The native tokenizer counts a dot as two source characters.
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctDot;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
      end
      else if (C = '-') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '>') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctArrow;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '&') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '&') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctAnd;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '|') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '|') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctOr;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '+') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctAdd;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '-') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctSubtract;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '*') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctMultiply;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '/') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctDivide;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '%') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctModulo;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '&') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctBitAnd;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '|') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctBitOr;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '^') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctBitXor;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '~') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctBitNot;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '!') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '=') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctNotEqual;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '!') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctNot;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '<') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '<') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctShiftLeft;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '>') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '>') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctShiftRight;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '=') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '=') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctEqual;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '=') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctAssign;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '<') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '=') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctLessEqual;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '>') and (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '=') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctGreaterEqual;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 2;
        Inc(Index);
      end
      else if (C = '<') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctLess;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = '>') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctGreater;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = ';') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctSemicolon;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = ':') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctColon;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = ',') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctComma;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
      end
      else if (C = ' ') or (C = #9) then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        if (Last = nil) or ((Last <> nil) and (Last.TokenKind <> ctWhitespace)) then
        begin
          Token := AddToken;
          Token.TokenKind := ctWhitespace;
          Token.SourceStart := Index + SourceOffset;
          Token.SourceLength := 1;
        end
        else Inc(Last.SourceLength);
      end
      else if (C = #13) or (C = #10) then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        RunStart := -1;
        Token := AddToken;
        Token.TokenKind := ctNewline;
        Token.SourceStart := Index + SourceOffset;
        Token.SourceLength := 1;
        Inc(SourceOffset, NewlineOffset);
        if (Index + 1 < TextLength) and ((Text[(Index + 1) + 1] = #13) or
          (Text[(Index + 1) + 1] = #10)) then
        begin
          Inc(Index);
          Inc(Token.SourceLength);
        end;
      end
      else if (C = '"') or (C = '''') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
          Inc(Last.SourceLength, RunLength);
        end;
        Token := AddToken;
        Token.TokenKind := ctStringLiteral;
        QuoteStart := Index;
        Last.SourceStart := Index + SourceOffset;
        Last.SourceLength := 2;
        Last.Text := '';
        RunStart := Index + 1;
        RunLength := 0;
      end
      else if C > ' ' then
      begin
        if (Last = nil) or (Last.TokenKind <> ctText) then
        begin
          Token := AddToken;
          Token.TokenKind := ctText;
          Last.SourceStart := Index + SourceOffset;
          Last.SourceLength := 0;
          Last.Text := '';
          RunStart := Index;
          RunLength := 1;
        end
        else Inc(RunLength);
      end;
    end
    else if Last.TokenKind = ctStringLiteral then
    begin
      Inc(RunLength);
      if C = '\' then
      begin
        if (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '\') then
        begin
          if (RunStart >= 0) and (RunLength > 0) then
          begin
            Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength - 1);
            Inc(Last.SourceLength, RunLength - 1);
          end;
          Last.Text := Last.Text + C;
          Inc(Last.SourceLength, 2);
          Inc(Index);
          RunStart := Index + 1;
          RunLength := 0;
        end
        else if (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '"') then
        begin
          if (RunStart >= 0) and (RunLength > 0) then
          begin
            Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength - 1);
            Inc(Last.SourceLength, RunLength - 1);
          end;
          Last.Text := Last.Text + '"';
          Inc(Last.SourceLength, 2);
          Inc(Index);
          RunStart := Index + 1;
          RunLength := 0;
        end
        else if (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = '''') then
        begin
          if (RunStart >= 0) and (RunLength > 0) then
          begin
            Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength - 1);
            Inc(Last.SourceLength, RunLength - 1);
          end;
          Last.Text := Last.Text + '''';
          Inc(Last.SourceLength, 2);
          Inc(Index);
          RunStart := Index + 1;
          RunLength := 0;
        end
        else if (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = 'n') then
        begin
          if (RunStart >= 0) and (RunLength > 0) then
          begin
            Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength - 1);
            Inc(Last.SourceLength, RunLength - 1);
          end;
          Last.Text := Last.Text + #13#10;
          Inc(Last.SourceLength, 2);
          Inc(Index);
          RunStart := Index + 1;
          RunLength := 0;
        end
        else if (Index + 1 < TextLength) and (Text[(Index + 1) + 1] = 'x') then
        begin
          if (RunStart >= 0) and (RunLength > 0) then
          begin
            Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength - 1);
            Inc(Last.SourceLength, RunLength - 1);
          end;
          Inc(Last.SourceLength, 2);
          Inc(Index, 2);
          HexValue := 0;
          HexDigits := 0;
          while (Index < TextLength) and (HexDigits < 4) do
          begin
            C := Text[Index + 1];
            if (C >= '0') and (C <= '9') then HexValue := HexValue * 16 + Ord(C) - Ord('0')
            else if (C >= 'a') and (C <= 'f') then HexValue := HexValue * 16 + Ord(C) - Ord('a') + 10
            else if (C >= 'A') and (C <= 'F') then HexValue := HexValue * 16 + Ord(C) - Ord('A') + 10
            else Break;
            Inc(HexDigits);
            Inc(Last.SourceLength);
            Inc(Index);
          end;
          Last.Text := Last.Text + WideChar(HexValue);
          Dec(Index);
          RunStart := Index + 1;
          RunLength := 0;
        end;
      end
      // Either quote closes the native string, regardless of its opener.
      else if (C = '"') or (C = '''') then
      begin
        if (RunStart >= 0) and (RunLength > 0) then
        begin
          Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength - 1);
          Inc(Last.SourceLength, RunLength - 1);
        end;
        RunStart := -1;
        QuoteStart := -1;
      end;
    end;
    Inc(Index);
  end;
  if (RunStart >= 0) and (RunLength > 0) then
    Last.Text := Last.Text + Copy(Text, RunStart + 1, RunLength);
end;
{ @end $4652B4 }

{ @routine $4669F0 TCodeAnalyzerEC_Tokenize }
procedure TCodeAnalyzerEC.Tokenize(Text: WideString; NewlineOffset: Integer);
begin
  ClearTokens;
  AppendText(Text, 0, NewlineOffset);
end;
{ @end $4669F0 }

{ @routine $466A74 TCodeAnalyzerEC_ValidateDelimiters }
function TCodeAnalyzerEC.ValidateDelimiters: WideString;
var
  Depth, OpenCount, CloseCount: Integer;
  Token: TCodeAnalyzerUnitEC;
  Stack: array of Byte;
begin
  Result := '';
  OpenCount := 0;
  CloseCount := 0;
  Token := First;
  while Token <> nil do
  begin
    if (Token.TokenKind = ctOpenParen) or (Token.TokenKind = ctOpenBrace) or
      (Token.TokenKind = ctOpenBracket) or (Token.TokenKind = ctBlockCommentStart) then Inc(OpenCount);
    if (Token.TokenKind = ctCloseParen) or (Token.TokenKind = ctCloseBrace) or
      (Token.TokenKind = ctCloseBracket) or (Token.TokenKind = ctBlockCommentEnd) then Inc(CloseCount);
    Token := Token.Next;
  end;
  if OpenCount <> CloseCount then
  begin
    Result := FormatScriptError(0, Last.SourceStart + Last.SourceLength);
    Exit;
  end;
  if OpenCount < 1 then Exit;
  SetLength(Stack, OpenCount);
  try
    Depth := 0;
    Token := First;
    while Token <> nil do
    begin
      if Token.TokenKind = ctOpenParen then
      begin
        Stack[Depth] := 1;
        Inc(Depth);
      end
      else if Token.TokenKind = ctOpenBrace then
      begin
        Stack[Depth] := 2;
        Inc(Depth);
      end
      else if Token.TokenKind = ctOpenBracket then
      begin
        Stack[Depth] := 3;
        Inc(Depth);
      end
      else if Token.TokenKind = ctBlockCommentStart then
      begin
        Stack[Depth] := 4;
        Inc(Depth);
      end
      else if Token.TokenKind = ctCloseParen then
      begin
        // Native checks total openings here, not the current stack depth.
        if (OpenCount < 1) or (Stack[Depth - 1] <> 1) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Stack := nil;
          Exit;
        end;
        Dec(Depth);
      end
      else if Token.TokenKind = ctCloseBrace then
      begin
        if (OpenCount < 1) or (Stack[Depth - 1] <> 2) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Stack := nil;
          Exit;
        end;
        Dec(Depth);
      end
      else if Token.TokenKind = ctCloseBracket then
      begin
        if (OpenCount < 1) or (Stack[Depth - 1] <> 3) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Stack := nil;
          Exit;
        end;
        Dec(Depth);
      end
      else if Token.TokenKind = ctBlockCommentEnd then
      begin
        if (OpenCount < 1) or (Stack[Depth - 1] <> 4) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Stack := nil;
          Exit;
        end;
        Dec(Depth);
      end;
      Token := Token.Next;
    end;
    if Depth > 0 then
    begin
      Result := FormatScriptError(0, Last.SourceStart + Last.SourceLength);
      Stack := nil;
      Exit;
    end;
  except
    Stack := nil;
    raise;
  end;
  Stack := nil;
end;
{ @end $466A74 }

{ @routine $466D34 TCodeAnalyzerEC_RemoveWhitespace }
procedure TCodeAnalyzerEC.RemoveWhitespace;
var
  Token, Previous: TCodeAnalyzerUnitEC;
begin
  Token := First;
  while Token <> nil do
  begin
    Previous := Token;
    Token := Token.Next;
    if Previous.TokenKind = ctWhitespace then DeleteToken(Previous);
  end;
end;
{ @end $466D34 }

{ @routine $466D5C TCodeAnalyzerEC_RemoveNewlines }
procedure TCodeAnalyzerEC.RemoveNewlines;
var
  Token, Previous: TCodeAnalyzerUnitEC;
begin
  Token := First;
  while Token <> nil do
  begin
    Previous := Token;
    Token := Token.Next;
    if Previous.TokenKind = ctNewline then DeleteToken(Previous);
  end;
end;
{ @end $466D5C }

{ @routine $466D84 TCodeAnalyzerEC_RemoveComments }
procedure TCodeAnalyzerEC.RemoveComments;
var
  Token, Previous: TCodeAnalyzerUnitEC;
  LineComment: Boolean;
  CommentDepth: Integer;
begin
  LineComment := False;
  CommentDepth := 0;
  Token := First;
  while Token <> nil do
  begin
    Previous := Token;
    Token := Token.Next;
    if not LineComment and (CommentDepth = 0) then
    begin
      if Previous.TokenKind = ctBlockCommentStart then
      begin
        CommentDepth := 1;
        DeleteToken(Previous);
      end
      else if Previous.TokenKind = ctLineComment then
      begin
        LineComment := True;
        DeleteToken(Previous);
      end;
    end
    else
    begin
      if (CommentDepth <> 0) and (Previous.TokenKind = ctBlockCommentStart) then Inc(CommentDepth)
      else if LineComment and (Previous.TokenKind = ctNewline) then LineComment := False
      else if (CommentDepth <> 0) and (Previous.TokenKind = ctBlockCommentEnd) then Dec(CommentDepth);
      DeleteToken(Previous);
    end;
  end;
end;
{ @end $466D84 }

{ @routine $466E0C TExpressionInstrEC_Destroy }
destructor TExpressionInstrEC.Destroy;
begin
  Operands := nil;
  inherited Destroy;
end;
{ @end $466E0C }

{ @routine $466E40 InitInstr }
procedure InitInstr(Instruction: TExpressionInstrEC; Token: TCodeTokenKind);
begin
  if Token = ctAdd then Instruction.Opcode := eoAdd
  else if Token = ctSubtract then Instruction.Opcode := eoSubtract
  else if Token = ctMultiply then Instruction.Opcode := eoMultiply
  else if Token = ctDivide then Instruction.Opcode := eoDivide
  else if Token = ctModulo then Instruction.Opcode := eoModulo
  else if Token = ctBitAnd then Instruction.Opcode := eoBitAnd
  else if Token = ctBitOr then Instruction.Opcode := eoBitOr
  else if Token = ctBitXor then Instruction.Opcode := eoBitXor
  else if Token = ctBitNot then Instruction.Opcode := eoBitNot
  else if Token = ctAnd then Instruction.Opcode := eoAnd
  else if Token = ctOr then Instruction.Opcode := eoOr
  else if Token = ctNot then Instruction.Opcode := eoNot
  else if Token = ctShiftLeft then Instruction.Opcode := eoShiftLeft
  else if Token = ctShiftRight then Instruction.Opcode := eoShiftRight
  else if Token = ctEqual then Instruction.Opcode := eoEqual
  else if Token = ctNotEqual then Instruction.Opcode := eoNotEqual
  else if Token = ctLess then Instruction.Opcode := eoLess
  else if Token = ctGreater then Instruction.Opcode := eoGreater
  else if Token = ctLessEqual then Instruction.Opcode := eoLessEqual
  else if Token = ctGreaterEqual then Instruction.Opcode := eoGreaterEqual
  else raise ExceptionExpressionEC.Create('InitInstr');
end;
{ @end $466E40 }

{ @routine $466F64 TExpressionInstrEC_CopyFrom }
procedure TExpressionInstrEC.CopyFrom(Source: TExpressionInstrEC);
var
  i: Integer;
begin
  Opcode := Source.Opcode;
  OperandCount := Source.OperandCount;
  Operands := nil;
  if Source.Operands <> nil then
  begin
    SetLength(Operands, OperandCount);
    for i := 0 to OperandCount - 1 do Operands[i] := Source.Operands[i];
  end;
end;
{ @end $466F64 }

{ @routine $466FC8 TExpressionVarEC_Destroy }
destructor TExpressionVarEC.Destroy;
begin
  if Kind = evOwned then Value.Free;
  Value := nil;
  MemberPath := nil;
  inherited Destroy;
end;
{ @end $466FC8 }

{ @routine $467010 TExpressionVarEC_CopyFrom }
procedure TExpressionVarEC.CopyFrom(Source: TExpressionVarEC);
var
  i, Count: Integer;
begin
  Name := Source.Name;
  Kind := Source.Kind;
  Value := nil;
  if Kind = evNamed then Value := Source.Value
  else if (Kind = evOwned) and (Source.Value <> nil) then
  begin
    Value := TVarEC.Create(vkEmpty);
    Value.AssignFrom(Source.Value, False);
  end;
  if Source.MemberPath <> nil then
  begin
    Count := High(Source.MemberPath) + 1;
    SetLength(MemberPath, Count);
    for i := 0 to Count - 1 do MemberPath[i] := Source.MemberPath[i];
  end;
end;
{ @end $467010 }

{ @routine $4670B4 TExpressionVarEC_SplitMemberPath }
function TExpressionVarEC.SplitMemberPath: Boolean;
var
  Start, Stop, Count, i, Parts: Integer;
  Text: WideString;
begin
  Result := True;
  Text := Name;
  Count := Length(Text);
  Start := 0;
  Stop := Start;
  while Stop < Count do
  begin
    if Text[Stop + 1] = '.' then Break;
    Inc(Stop);
  end;
  if Stop >= Count then Exit;
  Name := Copy(Text, Start + 1, Stop - Start);
  Parts := 1;
  for i := Stop + 1 to Count - 1 do
    if Text[i + 1] = '.' then Inc(Parts);
  SetLength(MemberPath, Parts);
  i := 0;
  while Stop + 1 < Count do
  begin
    Start := Stop + 1;
    Stop := Start;
    while Stop < Count do
    begin
      if Text[Stop + 1] = '.' then Break;
      Inc(Stop);
    end;
    MemberPath[i] := Copy(Text, Start + 1, Stop - Start);
    Inc(i);
  end;
  Result := True;
end;
{ @end $4670B4 }

{ @routine $4671D8 TExpressionVarEC_GetFullName }
function TExpressionVarEC.GetFullName: WideString;
var
  i: Integer;
begin
  Result := Name;
  if MemberPath <> nil then
    for i := 0 to High(MemberPath) do Result := Result + '.' + MemberPath[i];
end;
{ @end $4671D8 }

{ @routine $46722C TExpressionVarEC_Resolve }
function TExpressionVarEC.Resolve(InitialKind: TVarKind): TVarEC;
var
  i: Integer;
begin
  if Value <> nil then
  begin
    if MemberPath = nil then Result := Value
    else
    begin
      Result := Value;
      i := 0;
      while i <= High(MemberPath) do
      begin
        if Result.ValueKind = vkClass then Result := Result.AsClass.FindVar(MemberPath[i])
        else if Result.ValueKind = vkFunction then Result := Result.AsFunction.FindVar(MemberPath[i])
        else raise ExceptionExpressionEC.Create('Not link var :' + GetFullName);
        if Result = nil then raise ExceptionExpressionEC.Create('Not link var :' + GetFullName);
        Inc(i);
      end;
    end;
  end
  else
  begin
    if Kind = evOwned then Value := TVarEC.Create(InitialKind)
    else raise ExceptionExpressionEC.Create('Not link var :' + GetFullName);
    Result := Value;
  end;
end;
{ @end $46722C }

{ @routine $467418 TExpressionEC_Create }
constructor TExpressionEC.Create;
begin
  inherited Create;
end;
{ @end $467418 }

{ @routine $467450 TExpressionEC_Destroy }
destructor TExpressionEC.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $467450 }

{ @routine $46747C TExpressionEC_Clear }
procedure TExpressionEC.Clear;
begin
  while VariableCount > 0 do DeleteVariable(VariableCount - 1);
  if not SharedInstructions then
    while InstructionCount > 0 do DeleteInstruction(InstructionCount - 1);
  ResultIndex := -1;
  SharedInstructions := False;
end;
{ @end $46747C }

{ @routine $4674BC TExpressionEC_CopyFrom }
procedure TExpressionEC.CopyFrom(Source: TExpressionEC);
var
  i: Integer;
begin
  Clear;
  for i := 0 to Source.VariableCount - 1 do GetVariable(AddVariable).CopyFrom(Source.GetVariable(i));
  for i := 0 to Source.InstructionCount - 1 do GetInstruction(AddInstruction).CopyFrom(Source.GetInstruction(i));
  ResultIndex := Source.ResultIndex;
end;
{ @end $4674BC }

{ @routine $467538 TExpressionEC_CopyFromFast }
procedure TExpressionEC.CopyFromFast(Source: TExpressionEC);
var
  i: Integer;
begin
  Clear;
  for i := 0 to Source.VariableCount - 1 do GetVariable(AddVariable).CopyFrom(Source.GetVariable(i));
  InstructionCount := Source.InstructionCount;
  Instructions := Source.Instructions;
  SharedInstructions := True;
  ResultIndex := Source.ResultIndex;
end;
{ @end $467538 }

{ @routine $467594 TExpressionEC_AddVariable }
function TExpressionEC.AddVariable: Integer;
begin
  Inc(VariableCount);
  if Variables = nil then Variables := HeapAlloc(GetProcessHeap, 0, VariableCount * SizeOf(TExpressionVarEC))
  else Variables := HeapReAlloc(GetProcessHeap, 0, Variables, VariableCount * SizeOf(TExpressionVarEC));
  SetVariable(VariableCount - 1, TExpressionVarEC.Create);
  Result := VariableCount - 1;
end;
{ @end $467594 }

{ @routine $4675F8 TExpressionEC_DeleteVariable }
procedure TExpressionEC.DeleteVariable(Index: Integer);
var
  i: Integer;
begin
  if (Index < 0) or (Index >= VariableCount) then Exit;
  GetVariable(Index).Free;
  for i := Index to VariableCount - 2 do SetVariable(i, GetVariable(i + 1));
  Dec(VariableCount);
  if VariableCount <= 0 then
  begin
    HeapFree(GetProcessHeap, 0, Variables);
    Variables := nil;
  end;
end;
{ @end $4675F8 }

{ @routine $467664 TExpressionEC_GetVariable }
function TExpressionEC.GetVariable(Index: Integer): TExpressionVarEC; cdecl;
asm
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TExpressionEC.Variables
  MOV EAX, [EAX]
  POP EBX
end;
{ @end $467664 }

{ @routine $46767C TExpressionEC_SetVariable }
procedure TExpressionEC.SetVariable(Index: Integer; Value: TExpressionVarEC); cdecl;
asm
  PUSH EAX
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TExpressionEC.Variables
  MOV EBX, Value
  MOV [EAX], EBX
  POP EBX
  POP EAX
end;
{ @end $46767C }

{ @routine $467698 TExpressionEC_AddInstruction }
function TExpressionEC.AddInstruction: Integer;
begin
  Inc(InstructionCount);
  if Instructions = nil then Instructions := HeapAlloc(GetProcessHeap, 0, InstructionCount * SizeOf(TExpressionInstrEC))
  else Instructions := HeapReAlloc(GetProcessHeap, 0, Instructions, InstructionCount * SizeOf(TExpressionInstrEC));
  SetInstruction(InstructionCount - 1, TExpressionInstrEC.Create);
  Result := InstructionCount - 1;
end;
{ @end $467698 }

{ @routine $4676FC TExpressionEC_DeleteInstruction }
procedure TExpressionEC.DeleteInstruction(Index: Integer);
var
  i: Integer;
begin
  if (Index < 0) or (Index >= InstructionCount) then Exit;
  GetInstruction(Index).Free;
  for i := Index to InstructionCount - 2 do SetInstruction(i, GetInstruction(i + 1));
  Dec(InstructionCount);
  if InstructionCount <= 0 then
  begin
    HeapFree(GetProcessHeap, 0, Instructions);
    Instructions := nil;
  end;
end;
{ @end $4676FC }

{ @routine $467768 TExpressionEC_GetInstruction }
function TExpressionEC.GetInstruction(Index: Integer): TExpressionInstrEC; cdecl;
asm
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TExpressionEC.Instructions
  MOV EAX, [EAX]
  POP EBX
end;
{ @end $467768 }

{ @routine $467780 TExpressionEC_SetInstruction }
procedure TExpressionEC.SetInstruction(Index: Integer; Value: TExpressionInstrEC); cdecl;
asm
  PUSH EAX
  PUSH EBX
  MOV EBX, Self
  MOV EAX, Index
  SHL EAX, 2
  ADD EAX, [EBX].TExpressionEC.Instructions
  MOV EBX, Value
  MOV [EAX], EBX
  POP EBX
  POP EAX
end;
{ @end $467780 }

{ @routine $46779C TExpressionEC_Compile }
function TExpressionEC.Compile(Analyzer: TCodeAnalyzerEC; FirstToken, EndToken: TCodeAnalyzerUnitEC; NextToken: PCodeAnalyzerUnitEC): WideString;
var
  Token, Next: TCodeAnalyzerUnitEC;
  Compiler: TCompilerEC;
  Item, Reduced, Closing: TCompilerUnitEC;
  ResultSlot, Depth, ArgumentCount, OperandIndex: Integer;
  Slot: TExpressionVarEC;
  Instruction: TExpressionInstrEC;
  IntValue: Integer;
  DwordValue: Dword;
  FloatValue: Double;
  Text: WideString;
begin
  Clear;
  Result := '';
  if FirstToken = nil then FirstToken := Analyzer.First;
  if FirstToken = nil then
  begin
    Result := FormatScriptError(0, 0);
    Exit;
  end;
  Compiler := TCompilerEC.Create;
  Depth := 0;
  Token := FirstToken;
  while Token <> EndToken do
  begin
    if (Token.TokenKind <> ctBlockCommentStart) and (Token.TokenKind <> ctLineComment) then
    begin
      if Token.TokenKind = ctStringLiteral then
      begin
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuStringLiteral;
        Item.Text := Token.Text;
      end
      else if Token.TokenKind = ctComma then
      begin
        if Depth <= 0 then Break;
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuComma;
      end
      else if Token.TokenKind = ctAssign then
      begin
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuAssignment;
      end
      else if Token.TokenKind = ctOpenParen then
      begin
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuOpenParen;
        Inc(Depth);
      end
      else if Token.TokenKind = ctCloseParen then
      begin
        Dec(Depth);
        if Depth < 0 then Break;
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuCloseParen;
      end
      else if Token.TokenKind = ctOpenBracket then
      begin
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuOpenBracket;
        Inc(Depth);
      end
      else if Token.TokenKind = ctCloseBracket then
      begin
        Dec(Depth);
        if Depth < 0 then Break;
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuCloseBracket;
      end
      else if Token.TokenKind = ctAssign then
      begin
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuAssignment;
      end
      else if (Token.TokenKind = ctBitNot) or (Token.TokenKind = ctNot) then
      begin
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuUnaryOperator;
        Item.OperatorToken := Token.TokenKind;
      end
      // The original binary tests ctSubtract twice in this condition.
      else if (Token.TokenKind = ctAdd) or (Token.TokenKind = ctSubtract) or (Token.TokenKind = ctMultiply)
        or (Token.TokenKind = ctDivide) or (Token.TokenKind = ctModulo) or (Token.TokenKind = ctSubtract)
        or (Token.TokenKind = ctBitAnd) or (Token.TokenKind = ctBitOr) or (Token.TokenKind = ctBitXor)
        or (Token.TokenKind = ctAnd) or (Token.TokenKind = ctOr) or (Token.TokenKind = ctShiftLeft)
        or (Token.TokenKind = ctShiftRight) or (Token.TokenKind = ctEqual) or (Token.TokenKind = ctNotEqual)
        or (Token.TokenKind = ctLess) or (Token.TokenKind = ctGreater) or (Token.TokenKind = ctLessEqual)
        or (Token.TokenKind = ctGreaterEqual) then
      begin
        Item := Compiler.AddUnit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.SourceLength;
        Item.Kind := cuBinaryOperator;
        Item.OperatorToken := Token.TokenKind;
      end
      else if Token.TokenKind = ctText then
      begin
        Next := Token;
        if TryReadFloatLiteral(Next, FloatValue) then
        begin
          Item := Compiler.AddUnit;
          Item.SourceStart := Token.SourceStart;
          if Next = nil then Item.SourceLength := Analyzer.Last.SourceStart + Analyzer.Last.SourceLength - Token.SourceStart
          else Item.SourceLength := Next.Prev.SourceStart + Next.Prev.SourceLength - Token.SourceStart;
          Item.Kind := cuFloatLiteral;
          Item.FloatValue := FloatValue;
          Token := Next;
          Continue;
        end
        else if TryReadDwordLiteral(Next, DwordValue) then
        begin
          Item := Compiler.AddUnit;
          Item.SourceStart := Token.SourceStart;
          if Next = nil then Item.SourceLength := Analyzer.Last.SourceStart + Analyzer.Last.SourceLength - Token.SourceStart
          else Item.SourceLength := Next.Prev.SourceStart + Next.Prev.SourceLength - Token.SourceStart;
          Item.Kind := cuDwordLiteral;
          Item.DwordValue := DwordValue;
          Token := Next;
          Continue;
        end
        else if TryReadIntegerLiteral(Next, IntValue) then
        begin
          Item := Compiler.AddUnit;
          Item.SourceStart := Token.SourceStart;
          if Next = nil then Item.SourceLength := Analyzer.Last.SourceStart + Analyzer.Last.SourceLength - Token.SourceStart
          else Item.SourceLength := Next.Prev.SourceStart + Next.Prev.SourceLength - Token.SourceStart;
          Item.Kind := cuIntLiteral;
          Item.IntValue := IntValue;
          Token := Next;
          Continue;
        end
        else if TryReadStringLiteral(Next, Text) then
        begin
          Item := Compiler.AddUnit;
          Item.SourceStart := Token.SourceStart;
          if Next = nil then Item.SourceLength := Analyzer.Last.SourceStart + Analyzer.Last.SourceLength - Token.SourceStart
          else Item.SourceLength := Next.Prev.SourceStart + Next.Prev.SourceLength - Token.SourceStart;
          Item.Kind := cuStringLiteral;
          Item.Text := Text;
          Token := Next;
          Continue;
        end
        else if TryReadMemberName(Next, Text) then
        begin
          Item := Compiler.AddUnit;
          Item.SourceStart := Token.SourceStart;
          if Next = nil then Item.SourceLength := Analyzer.Last.SourceStart + Analyzer.Last.SourceLength - Token.SourceStart
          else Item.SourceLength := Next.Prev.SourceStart + Next.Prev.SourceLength - Token.SourceStart;
          Item.Kind := cuName;
          Item.Text := Text;
          Token := Next;
          Continue;
        end
        else
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Compiler.Free;
          Exit;
        end;
      end
      else
      begin
        if Token.TokenKind = ctSemicolon then Break;
        if (Token.TokenKind <> ctNewline) and (Token.TokenKind <> ctWhitespace) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Compiler.Free;
          Exit;
        end;
      end;
    end;
    Token := Token.Next;
  end;
  if NextToken <> nil then NextToken^ := Token;
  Depth := 0;
  Item := Compiler.First;
  while Item <> nil do
  begin
    if (Item.Kind = cuOpenParen) and (Item.Prev <> nil) and (Item.Prev.Kind = cuName) then
    begin
      Item.Kind := cuCall;
      Item.Text := Item.Prev.Text;
      Compiler.DeleteUnit(Item.Prev);
      Inc(Depth);
    end
    else if Item.Kind = cuOpenBracket then
    begin
      if (Item.Prev <> nil) and (Item.Prev.Kind = cuName) then
      begin
        Item.Kind := cuIndex;
        Item.Text := Item.Prev.Text;
        Compiler.DeleteUnit(Item.Prev);
        Inc(Depth);
      end
      else
      begin
        Result := FormatScriptError(0, Item.SourceStart);
        Compiler.Free;
        Exit;
      end;
    end
    else if Item.Kind = cuOpenParen then Inc(Depth)
    else if Item.Kind = cuCloseParen then Dec(Depth)
    else if Item.Kind = cuCloseBracket then Dec(Depth);
    Item := Item.Next;
  end;
  if Depth <> 0 then
  begin
    if Token = nil then Token := Analyzer.Last;
    Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
    Compiler.Free;
    Exit;
  end;
  Item := Compiler.First;
  while Item <> nil do
  begin
    if (Item.Kind = cuBinaryOperator) and (Item.OperatorToken = ctSubtract) and
      (Item.Next <> nil) and ((Item.Next.Kind = cuIntLiteral) or (Item.Next.Kind = cuFloatLiteral)) then
    begin
      if (Item.Prev = nil) or ((Item.Prev.Kind <> cuIntLiteral) and (Item.Prev.Kind <> cuDwordLiteral) and
        (Item.Prev.Kind <> cuFloatLiteral) and (Item.Prev.Kind <> cuCloseParen) and
        (Item.Prev.Kind <> cuCloseBracket) and (Item.Prev.Kind <> cuName)) then
      begin
        Item := Item.Next;
        Compiler.DeleteUnit(Item.Prev);
        Item.IntValue := -Item.IntValue;
        Item.FloatValue := -Item.FloatValue;
      end;
    end
    else if (Item.Kind = cuBinaryOperator) and (Item.OperatorToken = ctSubtract) and
      (Item.Next <> nil) and ((Item.Next.Kind = cuIntLiteral) or (Item.Next.Kind = cuDwordLiteral) or
      (Item.Next.Kind = cuFloatLiteral) or (Item.Next.Kind = cuOpenParen) or (Item.Next.Kind = cuCall) or
      (Item.Next.Kind = cuIndex) or (Item.Next.Kind = cuName)) then
    begin
      if (Item.Prev = nil) or ((Item.Prev.Kind <> cuIntLiteral) and (Item.Prev.Kind <> cuDwordLiteral) and
        (Item.Prev.Kind <> cuFloatLiteral) and (Item.Prev.Kind <> cuCloseParen) and
        (Item.Prev.Kind <> cuCloseBracket) and (Item.Prev.Kind <> cuName)) then Item.Kind := cuUnaryOperator;
    end;
    Item := Item.Next;
  end;
  Item := Compiler.First;
  while Item <> nil do
  begin
    if Item.Kind = cuBinaryOperator then
    begin
      if (Item.Prev = nil) or (Item.Next = nil) or
        not ((Item.Prev.Kind = cuName) or (Item.Prev.Kind = cuIntLiteral) or (Item.Prev.Kind = cuDwordLiteral)
          or (Item.Prev.Kind = cuFloatLiteral) or (Item.Prev.Kind = cuStringLiteral)
          or (Item.Prev.Kind = cuCloseParen) or (Item.Prev.Kind = cuCloseBracket)) or
        not ((Item.Next.Kind = cuName) or (Item.Next.Kind = cuIntLiteral) or (Item.Next.Kind = cuDwordLiteral)
          or (Item.Next.Kind = cuFloatLiteral) or (Item.Next.Kind = cuStringLiteral) or (Item.Next.Kind = cuOpenParen)
          or (Item.Next.Kind = cuCall) or (Item.Next.Kind = cuIndex) or (Item.Next.Kind = cuUnaryOperator)) then
      begin
        Result := FormatScriptError(0, Item.SourceStart);
        Compiler.Free;
        Exit;
      end;
    end
    else if Item.Kind = cuAssignment then
    begin
      if (Item.Prev = nil) or (Item.Next = nil) or
        not ((Item.Prev.Kind = cuName) or (Item.Prev.Kind = cuCloseBracket)) or
        not ((Item.Next.Kind = cuName) or (Item.Next.Kind = cuIntLiteral) or (Item.Next.Kind = cuDwordLiteral)
          or (Item.Next.Kind = cuFloatLiteral) or (Item.Next.Kind = cuStringLiteral) or (Item.Next.Kind = cuOpenParen)
          or (Item.Next.Kind = cuCall) or (Item.Next.Kind = cuIndex) or (Item.Next.Kind = cuUnaryOperator)) then
      begin
        Result := FormatScriptError(0, Item.SourceStart);
        Compiler.Free;
        Exit;
      end;
    end
    else if (Item.Kind = cuUnaryOperator) and ((Item.Next = nil) or
      not ((Item.Next.Kind = cuName) or (Item.Next.Kind = cuIntLiteral) or (Item.Next.Kind = cuDwordLiteral)
        or (Item.Next.Kind = cuFloatLiteral) or (Item.Next.Kind = cuStringLiteral) or (Item.Next.Kind = cuOpenParen)
        or (Item.Next.Kind = cuCall) or (Item.Next.Kind = cuIndex) or (Item.Next.Kind = cuUnaryOperator))) then
    begin
      Result := FormatScriptError(0, Item.SourceStart);
      Compiler.Free;
      Exit;
    end;
    Item := Item.Next;
  end;
  Item := Compiler.First;
  while Item <> nil do
  begin
    if Item.Kind = cuIntLiteral then
    begin
      Item.Kind := cuVariable;
      Item.VariableIndex := AddVariable;
      Slot := GetVariable(Item.VariableIndex);
      Slot.Kind := evOwned;
      Slot.Value := TVarEC.Create(vkInt);
      Slot.Value.AsInteger := Item.IntValue;
    end
    else if Item.Kind = cuDwordLiteral then
    begin
      Item.Kind := cuVariable;
      Item.VariableIndex := AddVariable;
      Slot := GetVariable(Item.VariableIndex);
      Slot.Kind := evOwned;
      Slot.Value := TVarEC.Create(vkDword);
      Slot.Value.AsDword := Item.DwordValue;
    end
    else if Item.Kind = cuFloatLiteral then
    begin
      Item.Kind := cuVariable;
      Item.VariableIndex := AddVariable;
      Slot := GetVariable(Item.VariableIndex);
      Slot.Kind := evOwned;
      Slot.Value := TVarEC.Create(vkFloat);
      Slot.Value.AsFloat := Item.FloatValue;
    end
    else if Item.Kind = cuStringLiteral then
    begin
      Item.Kind := cuVariable;
      Item.VariableIndex := AddVariable;
      Slot := GetVariable(Item.VariableIndex);
      Slot.Kind := evOwned;
      Slot.Value := TVarEC.Create(vkString);
      Slot.Value.AsString := Item.Text;
    end
    else if Item.Kind = cuName then
    begin
      Item.Kind := cuVariable;
      Item.VariableIndex := AddVariable;
      Slot := GetVariable(Item.VariableIndex);
      Slot.Kind := evNamed;
      Slot.Name := Item.Text;
      if not Slot.SplitMemberPath then
      begin
        Result := FormatScriptError(0, Item.SourceStart);
        Compiler.Free;
        Exit;
      end;
    end
    else if Item.Kind = cuCall then
    begin
      Item.VariableIndex := AddVariable;
      Slot := GetVariable(Item.VariableIndex);
      Slot.Kind := evNamed;
      Slot.Name := Item.Text;
      if not Slot.SplitMemberPath then
      begin
        Result := FormatScriptError(0, Item.SourceStart);
        Compiler.Free;
        Exit;
      end;
    end
    else if Item.Kind = cuIndex then
    begin
      Item.VariableIndex := AddVariable;
      Slot := GetVariable(Item.VariableIndex);
      Slot.Kind := evNamed;
      Slot.Name := Item.Text;
      if not Slot.SplitMemberPath then
      begin
        Result := FormatScriptError(0, Item.SourceStart);
        Compiler.Free;
        Exit;
      end;
    end;
    Item := Item.Next;
  end;
  if Compiler.First = nil then
  begin
    Result := FormatScriptError(0, 0);
    Compiler.Free;
    Exit;
  end;
  while Compiler.First.Next <> nil do
  begin
    Item := Compiler.FindReducibleIndex;
    if Item = nil then Item := Compiler.FindReducibleCall;
    if Item = nil then Item := Compiler.FindReducibleOperator;
    if Item = nil then
    begin
      Clear;
      if Compiler.First = nil then Result := 'Unknown error'
      else Result := FormatScriptError(0, Compiler.First.SourceStart);
      Compiler.Free;
      Exit;
      // Unreachable raise.
      raise ExceptionExpressionEC.Create('Unknown error');
    end;
    if (Item.Kind = cuCall) or (Item.Kind = cuIndex) then
    begin
      ArgumentCount := 0;
      Closing := Item.Next;
      while Closing <> nil do
      begin
        if Closing.Kind = cuVariable then Inc(ArgumentCount)
        else if (Closing.Kind = cuCloseParen) or (Closing.Kind = cuCloseBracket) then Break;
        Closing := Closing.Next;
      end;
      if (Item.Kind = cuIndex) and (ArgumentCount < 1) then
      begin
        Clear;
        Result := FormatScriptError(0, Item.SourceStart);
        Compiler.Free;
        Exit;
        // Unreachable raise.
        raise ExceptionExpressionEC.Create('Unknown error');
      end;
      ResultSlot := AddVariable;
      if Item.Kind = cuCall then GetVariable(ResultSlot).Kind := evOwned
      else GetVariable(ResultSlot).Kind := evIndexed;
      Instruction := GetInstruction(AddInstruction);
      if Item.Kind = cuCall then Instruction.Opcode := eoCall
      else Instruction.Opcode := eoIndex;
      Instruction.OperandCount := ArgumentCount + 2;
      SetLength(Instruction.Operands, ArgumentCount + 2);
      Instruction.Operands[0] := ResultSlot;
      Instruction.Operands[1] := Item.VariableIndex;
      OperandIndex := 2;
      Reduced := Item.Next;
      while Reduced <> nil do
      begin
        if Reduced.Kind = cuVariable then
        begin
          Instruction.Operands[OperandIndex] := Reduced.VariableIndex;
          Inc(OperandIndex);
        end
        else if (Reduced.Kind = cuCloseParen) or (Reduced.Kind = cuCloseBracket) then Break;
        Reduced := Reduced.Next;
      end;
      Item.Kind := cuVariable;
      Item.Text := '';
      Item.VariableIndex := ResultSlot;
      Reduced := Item;
      while Closing <> Reduced do
      begin
        Item := Closing;
        Closing := Closing.Prev;
        Compiler.DeleteUnit(Item);
      end;
    end
    else if Item.Kind = cuUnaryOperator then
    begin
      ResultSlot := AddVariable;
      GetVariable(ResultSlot).Kind := evOwned;
      Instruction := GetInstruction(AddInstruction);
      if Item.OperatorToken = ctSubtract then Instruction.Opcode := eoNegate
      else InitInstr(Instruction, Item.OperatorToken);
      Instruction.OperandCount := 2;
      SetLength(Instruction.Operands, 2);
      Instruction.Operands[0] := ResultSlot;
      Instruction.Operands[1] := Item.Next.VariableIndex;
      Item.Next.VariableIndex := ResultSlot;
      Reduced := Item.Next;
      Compiler.DeleteUnit(Item);
    end
    else if Item.Kind = cuAssignment then
    begin
      Instruction := GetInstruction(AddInstruction);
      Instruction.Opcode := eoAssign;
      Instruction.OperandCount := 2;
      SetLength(Instruction.Operands, 2);
      Instruction.Operands[0] := Item.Prev.VariableIndex;
      Instruction.Operands[1] := Item.Next.VariableIndex;
      Reduced := Item.Prev;
      Compiler.DeleteUnit(Item.Next);
      Compiler.DeleteUnit(Item);
    end
    else
    begin
      ResultSlot := AddVariable;
      GetVariable(ResultSlot).Kind := evOwned;
      Instruction := GetInstruction(AddInstruction);
      InitInstr(Instruction, Item.OperatorToken);
      Instruction.OperandCount := 3;
      SetLength(Instruction.Operands, 3);
      Instruction.Operands[0] := ResultSlot;
      Instruction.Operands[1] := Item.Prev.VariableIndex;
      Instruction.Operands[2] := Item.Next.VariableIndex;
      Item.Prev.VariableIndex := ResultSlot;
      Reduced := Item.Prev;
      Compiler.DeleteUnit(Item.Next);
      Compiler.DeleteUnit(Item);
    end;
    while (Reduced <> nil) and (Reduced.Prev <> nil) and (Reduced.Prev.Kind = cuOpenParen) and
      (Reduced.Next <> nil) and (Reduced.Next.Kind = cuCloseParen) do
    begin
      Compiler.DeleteUnit(Reduced.Prev);
      Compiler.DeleteUnit(Reduced.Next);
    end;
  end;
  ResultIndex := Compiler.First.VariableIndex;
  Compiler.Free;
end;
{ @end $46779C }

{ @routine $468874 TExpressionEC_Link }
procedure TExpressionEC.Link(Scope: TVarArrayEC; OnlyUnlinked: Boolean);
var
  i: Integer;
  Slot: TExpressionVarEC;
  Found: TVarEC;
begin
  for i := 0 to VariableCount - 1 do
  begin
    Slot := GetVariable(i);
    if OnlyUnlinked and (Slot.Value <> nil) then Continue;
    if Slot.Kind = evNamed then
    begin
      Found := Scope.GetVarNE(Slot.Name);
      if Found <> nil then Slot.Value := Found;
    end;
  end;
end;
{ @end $468874 }

{ @routine $4688F4 TExpressionEC_Evaluate }
procedure TExpressionEC.Evaluate(Process: TCodeProcessEC; Code: TCodeEC; DebugContext: TScriptDebugState);
var
  LibraryWord: Dword;
  i, j: Integer;
  Instruction: TExpressionInstrEC;
  Dest, Left, Right: TExpressionVarEC;
  Arguments: array of TVarEC;
  Value, IndexValue, Callee, Argument: TVarEC;
  Invocation: TCodeEC;
  LibraryArgumentCount: Integer;
  ResultKind: TVarKind;
  SingleValue: Single;
begin
  i := 0;
  while i < VariableCount do
  begin
    Dest := GetVariable(i);
    if Dest.Kind = evIndexed then Dest.Value := nil;
    Inc(i);
  end;
  i := 0;
  while i < InstructionCount do
  begin
    Instruction := GetInstruction(i);
    if (Instruction.Opcode = eoNegate) or (Instruction.Opcode = eoBitNot) or
      (Instruction.Opcode = eoNot) then
    begin
      Dest := GetVariable(Instruction.Operands[0]);
      Left := GetVariable(Instruction.Operands[1]);
      case Instruction.Opcode of
        eoNegate: Dest.Resolve(Left.Value.ValueKind).OMinus(Left.Resolve(vkEmpty));
        eoBitNot: Dest.Resolve(Left.Value.ValueKind).OBitNot(Left.Resolve(vkEmpty));
        eoNot: Dest.Resolve(Left.Value.ValueKind).ONot(Left.Resolve(vkEmpty));
      end;
    end
    else if (Instruction.Opcode <> eoCall) and (Instruction.Opcode <> eoAssign) and
      (Instruction.Opcode <> eoIndex) then
    begin
      Dest := GetVariable(Instruction.Operands[0]);
      Left := GetVariable(Instruction.Operands[1]);
      Right := GetVariable(Instruction.Operands[2]);
      ResultKind := vkEmpty;
      if (Dest.Value = nil) and (Dest.Kind = evOwned) then
      begin
        if (Instruction.Opcode = eoAdd) or (Instruction.Opcode = eoSubtract) or
          (Instruction.Opcode = eoMultiply) or (Instruction.Opcode = eoDivide) then
          ResultKind := Left.Resolve(vkEmpty).ValueKind
        else ResultKind := vkInt;
      end;
      case Instruction.Opcode of
        eoAdd: Dest.Resolve(ResultKind).OAdd(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoSubtract: Dest.Resolve(ResultKind).OSub(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoMultiply: Dest.Resolve(ResultKind).OMul(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoDivide: Dest.Resolve(ResultKind).ODiv(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoModulo: Dest.Resolve(ResultKind).OMod(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoBitAnd: Dest.Resolve(ResultKind).OBitAnd(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoBitOr: Dest.Resolve(ResultKind).OBitOr(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoBitXor: Dest.Resolve(ResultKind).OBitXor(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoAnd: Dest.Resolve(ResultKind).OAnd(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoOr: Dest.Resolve(ResultKind).OOr(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoShiftLeft: Dest.Resolve(ResultKind).OShl(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoShiftRight: Dest.Resolve(ResultKind).OShr(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoEqual: Dest.Resolve(ResultKind).OEqual(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoNotEqual: Dest.Resolve(ResultKind).ONotEqual(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoLess: Dest.Resolve(ResultKind).OLess(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoGreater: Dest.Resolve(ResultKind).OMore(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoLessEqual: Dest.Resolve(ResultKind).OLessEqual(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
        eoGreaterEqual: Dest.Resolve(ResultKind).OMoreEqual(Left.Resolve(vkEmpty), Right.Resolve(vkEmpty));
      end;
    end
    else if Instruction.Opcode = eoAssign then
    begin
      Dest := GetVariable(Instruction.Operands[0]);
      Left := GetVariable(Instruction.Operands[1]);
      Dest.Resolve(vkEmpty).Assume(Left.Resolve(vkEmpty), False);
    end
    else if Instruction.Opcode = eoIndex then
    begin
      Dest := GetVariable(Instruction.Operands[0]);
      Left := GetVariable(Instruction.Operands[1]);
      Value := Left.Resolve(vkEmpty);
      if Value.ValueKind <> vkArray then
        raise ExceptionExpressionEC.Create('Not array:' + Left.Name);
      for j := 2 to Instruction.OperandCount - 1 do
      begin
        Right := GetVariable(Instruction.Operands[j]);
        IndexValue := Right.Resolve(vkEmpty);
        if IndexValue.ValueKind = vkString then
        begin
          Value := Value.AsArray.GetVarNE(IndexValue.AsString);
          if Value = nil then
            raise ExceptionExpressionEC.Create('Error array. name=' + Left.Resolve(vkEmpty).Name +
              ' index=' + Right.Value.AsString + ' level=' + IntToStr(j - 1));
        end
        else
        begin
          Value := Value.AsArray.GetItemNE(IndexValue.AsInteger);
          if Value = nil then
            raise ExceptionExpressionEC.Create('Error array. name=' + Left.Resolve(vkEmpty).Name +
              ' index=' + IntToStr(Right.Value.AsInteger) + ' level=' + IntToStr(j - 1));
        end;
        if (j <> Instruction.OperandCount - 1) and (Value.ValueKind <> vkArray) then
          raise ExceptionExpressionEC.Create('Error array:' + Left.Name);
      end;
      Dest.Value := Value;
    end
    else
    begin
      Dest := GetVariable(Instruction.Operands[0]);
      Left := GetVariable(Instruction.Operands[1]);
      Dest.Resolve(vkEmpty);
      Callee := Left.Resolve(vkEmpty);
      if Callee.ValueKind = vkLibraryFun then
      begin
        Value := Callee.Resolve;
        if High(Value.LibraryFunData) + 1 - 2 <> Instruction.OperandCount - 2 then
          raise ExceptionExpressionEC.Create('Count variable : ' + Left.Name);
        LibraryArgumentCount := Instruction.OperandCount - 2;
        for j := LibraryArgumentCount - 1 downto 0 do
        begin
          Argument := GetVariable(Instruction.Operands[j + 2]).Resolve(vkEmpty);
          case TLibraryValueKind(Value.LibraryFunData[2 + j]) of
            lvInt: LibraryWord := Argument.AsInteger;
            lvDword: LibraryWord := Argument.AsDword;
            lvFloat:
              begin
                SingleValue := Argument.AsFloat;
                LibraryWord := PDword(@SingleValue)^;
              end;
            lvString:
              begin
                IndexValue := Argument.Resolve;
                if IndexValue.Kind <> vkString then
                  raise ExceptionExpressionEC.Create('Variable not string');
                if Length(IndexValue.StringValue) <= 0 then LibraryWord := 0
                else LibraryWord := Dword(PWideChar(IndexValue.StringValue));
              end;
            lvRef: LibraryWord := Dword(Argument);
            lvCode: LibraryWord := Dword(Code);
          else
            LibraryWord := 0;
          end;
          // The caller releases this dynamically built argument stack.
          asm
            push LibraryWord
          end;
        end;
        ScriptCallTrace[ScriptCallTracePosition] := Callee;
        ScriptCallTraceCount := Min(20, ScriptCallTraceCount + 1);
        ScriptCallTracePosition := (ScriptCallTracePosition + 1) mod 20;
        LibraryWord := Value.LibraryFunData[1];
        asm
          call LibraryWord
          mov LibraryWord, eax
        end;
        for j := 0 to LibraryArgumentCount - 1 do
          asm
            pop eax
          end;
        if Value.LibraryFunData[0] = 1 then Dest.Value.AsInteger := LibraryWord
        else if Value.LibraryFunData[0] = 2 then Dest.Value.AsDword := LibraryWord
        else if Value.LibraryFunData[0] = 3 then Dest.Value.AsFloat := PSingle(@LibraryWord)^
        else if Value.LibraryFunData[0] = 4 then
          Dest.Value.AsString := AnsiString('') + PWideChar(LibraryWord);
      end
      else if Callee.ValueKind = vkExternFun then
      begin
        SetLength(Arguments, Instruction.OperandCount - 1);
        Arguments[0] := Dest.Value;
        Dest.Value.ResetKind(vkEmpty);
        for j := 2 to Instruction.OperandCount - 1 do
        begin
          Argument := GetVariable(Instruction.Operands[j]).Resolve(vkEmpty);
          Arguments[j - 1] := Argument;
        end;
        if Code <> nil then
        begin
          Code.Process := Process;
          Code.DebugContext := DebugContext;
        end;
        ScriptCallTrace[ScriptCallTracePosition] := Callee;
        ScriptCallTraceCount := Min(20, ScriptCallTraceCount + 1);
        ScriptCallTracePosition := (ScriptCallTracePosition + 1) mod 20;
        TExpressionCallback(Callee.AsExternFun)(Arguments, Code);
      end
      else if Callee.ValueKind = vkFunction then
      begin
        if Callee.AsFunction.LocalVar.NamedItems['funBaseVarCount'].AsInteger < Instruction.OperandCount - 2 then
          raise ExceptionExpressionEC.Create('Count var error. fun:' + Left.Name);
        Invocation := TCodeEC.Create;
        Invocation.Parent := Callee.AsFunction;
        Invocation.CopyFromFast(Callee.AsFunction);
        for j := 2 to Instruction.OperandCount - 1 do
        begin
          Argument := GetVariable(Instruction.Operands[j]).Resolve(vkEmpty);
          if Invocation.LocalVar[j - 2].Kind = vkRef then
            Invocation.LocalVar[j - 2].SetRef(Argument)
          else Invocation.LocalVar[j - 2].Assume(Argument, False);
        end;
        try
          Invocation.LocalVar.NamedItems['result'].SetRef(Dest.Value);
          if DebugContext = nil then Invocation.Run(Process)
          else Invocation.RunDebug(Process, DebugContext);
          ScriptCallTrace[ScriptCallTracePosition] := Callee;
          ScriptCallTraceCount := Min(20, ScriptCallTraceCount + 1);
          ScriptCallTracePosition := (ScriptCallTracePosition + 1) mod 20;
        except
          on E: Exception do
          begin
            Invocation.Free;
            if E.ClassName = 'EBreakMessageGI' then raise;
            ScriptCallTrace[ScriptCallTracePosition] := Callee;
            ScriptCallTraceCount := Min(20, ScriptCallTraceCount + 1);
            ScriptCallTracePosition := (ScriptCallTracePosition + 1) mod 20;
            raise ExceptionExpressionEC.Create('Error in function ' + Callee.Name +
              ' (' + E.ClassName + ' ' + E.Message + ')');
          end;
        end;
        Invocation.Free;
      end
      else raise ExceptionExpressionEC.Create('Not fun:' + Left.Name);
    end;
    Inc(i);
  end;
end;
{ @end $4688F4 }

{ @routine $469B7C TExpressionEC_GetResult }
function TExpressionEC.GetResult: TVarEC;
begin
  if (ResultIndex < 0) or (GetVariable(ResultIndex).Value = nil) then
    raise ExceptionExpressionEC.Create('Not link var return');
  Result := GetVariable(ResultIndex).Value;
end;
{ @end $469B7C }

{ @routine $469BDC TCompilerEC_Create }
constructor TCompilerEC.Create;
begin
  inherited Create;
end;
{ @end $469BDC }

{ @routine $469C14 TCompilerEC_Destroy }
destructor TCompilerEC.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $469C14 }

{ @routine $469C40 TCompilerEC_Clear }
procedure TCompilerEC.Clear;
begin
  while First <> nil do DeleteUnit(Last);
end;
{ @end $469C40 }

{ @routine $469C58 TCompilerEC_AddUnit }
function TCompilerEC.AddUnit: TCompilerUnitEC;
var
  Item: TCompilerUnitEC;
begin
  Item := TCompilerUnitEC.Create;
  if Last <> nil then Last.Next := Item;
  Item.Prev := Last;
  Item.Next := nil;
  Last := Item;
  if First = nil then First := Item;
  Result := Item;
end;
{ @end $469C58 }

{ @routine $469C8C TCompilerEC_DeleteUnit }
procedure TCompilerEC.DeleteUnit(UnitNode: TCompilerUnitEC);
begin
  if UnitNode.Prev <> nil then UnitNode.Prev.Next := UnitNode.Next;
  if UnitNode.Next <> nil then UnitNode.Next.Prev := UnitNode.Prev;
  if Last = UnitNode then Last := UnitNode.Prev;
  if First = UnitNode then First := UnitNode.Next;
  UnitNode.Free;
end;
{ @end $469C8C }

{ @routine $469CC8 TCompilerEC_FindReducibleOperator }
function TCompilerEC.FindReducibleOperator: TCompilerUnitEC;
const
  PrecedenceUnary = 0;
  PrecedenceMultiply = 1;
  PrecedenceAdd = 2;
  PrecedenceShift = 3;
  PrecedenceCompare = 4;
  PrecedenceBitAnd = 5;
  PrecedenceBitXor = 6;
  PrecedenceBitOr = 7;
  PrecedenceAnd = 8;
  PrecedenceOr = 9;
  PrecedenceAssign = 10;
var
  i: Integer;
  Item, Following: TCompilerUnitEC;
  Candidates: array[PrecedenceUnary..PrecedenceAssign] of TCompilerUnitEC;
begin
  for i := Low(Candidates) to High(Candidates) do Candidates[i] := nil;
  Item := First;
  while Item <> nil do
  begin
    if Item.Kind = cuUnaryOperator then
    begin
      if (Item.Next <> nil) and (Item.Next.Kind = cuVariable) and (Candidates[PrecedenceUnary] = nil) then Candidates[PrecedenceUnary] := Item;
    end
    else if Item.Kind = cuBinaryOperator then
    begin
      if (Item.Prev.Kind = cuVariable) and (Item.Next.Kind = cuVariable) then
      begin
        Following := Item.Next.Next;
        while Following <> nil do
        begin
          if (Following.Kind = cuOpenParen) or (Following.Kind = cuOpenBracket) or
            (Following.Kind = cuCall) then Break;
          if (Following.Kind = cuCloseParen) or (Following.Kind = cuCloseBracket) then Break;
          Following := Following.Next;
        end;
        if (Following = nil) or ((Following.Kind <> cuOpenParen) and
          (Following.Kind <> cuOpenBracket) and (Following.Kind <> cuCall)) then
        begin
          if (Item.OperatorToken = ctMultiply) or (Item.OperatorToken = ctDivide) or
            (Item.OperatorToken = ctModulo) then
          begin
            if Candidates[PrecedenceMultiply] = nil then Candidates[PrecedenceMultiply] := Item;
          end
          else if (Item.OperatorToken = ctAdd) or (Item.OperatorToken = ctSubtract) then
          begin
            if Candidates[PrecedenceAdd] = nil then Candidates[PrecedenceAdd] := Item;
          end
          else if (Item.OperatorToken = ctShiftLeft) or (Item.OperatorToken = ctShiftRight) then
          begin
            if Candidates[PrecedenceShift] = nil then Candidates[PrecedenceShift] := Item;
          end
          else if (Item.OperatorToken = ctEqual) or (Item.OperatorToken = ctNotEqual) or
            (Item.OperatorToken = ctLess) or (Item.OperatorToken = ctGreater) or
            (Item.OperatorToken = ctLessEqual) or (Item.OperatorToken = ctGreaterEqual) then
          begin
            if Candidates[PrecedenceCompare] = nil then Candidates[PrecedenceCompare] := Item;
          end
          else if Item.OperatorToken = ctBitAnd then
          begin
            if Candidates[PrecedenceBitAnd] = nil then Candidates[PrecedenceBitAnd] := Item;
          end
          else if Item.OperatorToken = ctBitXor then
          begin
            if Candidates[PrecedenceBitXor] = nil then Candidates[PrecedenceBitXor] := Item;
          end
          else if Item.OperatorToken = ctBitOr then
          begin
            if Candidates[PrecedenceBitOr] = nil then Candidates[PrecedenceBitOr] := Item;
          end
          else if Item.OperatorToken = ctAnd then
          begin
            if Candidates[PrecedenceAnd] = nil then Candidates[PrecedenceAnd] := Item;
          end
          else if Item.OperatorToken = ctOr then
          begin
            if Candidates[PrecedenceOr] = nil then Candidates[PrecedenceOr] := Item;
          end;
        end;
      end;
    end
    else if Item.Kind = cuAssignment then
    begin
      if (Item.Prev.Kind = cuVariable) and (Item.Next.Kind = cuVariable) and
        (Candidates[PrecedenceAssign] = nil) then Candidates[PrecedenceAssign] := Item;
    end;
    Item := Item.Next;
  end;
  for i := Low(Candidates) to High(Candidates) do
    if Candidates[i] <> nil then
    begin
      Result := Candidates[i];
      Exit;
    end;
  Result := nil;
end;
{ @end $469CC8 }

{ @routine $469EDC TCompilerEC_FindReducibleIndex }
function TCompilerEC.FindReducibleIndex: TCompilerUnitEC;
var
  Item, Following: TCompilerUnitEC;
begin
  Item := First;
  while Item <> nil do
  begin
    if Item.Kind = cuIndex then
    begin
      Following := Item.Next;
      while Following <> nil do
      begin
        if Following.Kind = cuCloseBracket then
        begin
          Result := Item;
          Exit;
        end;
        if (Following.Kind <> cuComma) and (Following.Kind <> cuVariable) then Break;
        Following := Following.Next;
      end;
    end;
    Item := Item.Next;
  end;
  Result := nil;
end;
{ @end $469EDC }

{ @routine $469F20 TCompilerEC_FindReducibleCall }
function TCompilerEC.FindReducibleCall: TCompilerUnitEC;
var
  Item, Following: TCompilerUnitEC;
begin
  Item := First;
  while Item <> nil do
  begin
    if Item.Kind = cuCall then
    begin
      Following := Item.Next;
      while Following <> nil do
      begin
        if Following.Kind = cuCloseParen then
        begin
          Result := Item;
          Exit;
        end;
        if (Following.Kind <> cuComma) and (Following.Kind <> cuVariable) then Break;
        Following := Following.Next;
      end;
    end;
    Item := Item.Next;
  end;
  Result := nil;
end;
{ @end $469F20 }

{ @routine $469F64 TCodeUnitEC_Destroy }
destructor TCodeUnitEC.Destroy;
begin
  if Expression <> nil then
  begin
    Expression.Free;
    Expression := nil;
  end;
  inherited Destroy;
end;
{ @end $469F64 }

{ @routine $469F9C TCodeProcessEC_Create }
constructor TCodeProcessEC.Create;
begin
  inherited Create;
  Handlers := TList.Create;
  Exceptions := TList.Create;
end;
{ @end $469F9C }

{ @routine $469FF0 TCodeProcessEC_Destroy }
destructor TCodeProcessEC.Destroy;
begin
  Clear;
  Handlers.Free;
  Handlers := nil;
  Exceptions.Free;
  Exceptions := nil;
  inherited Destroy;
end;
{ @end $469FF0 }

{ @routine $46A038 TCodeProcessEC_Clear }
procedure TCodeProcessEC.Clear;
var
  Handler: PCodeExceptionHandler;
  Value: PVarEC;
  i: Integer;
begin
  for i := 0 to Handlers.Count - 1 do
  begin
    Handler := Handlers[i];
    HeapFree(GetProcessHeap, 0, Handler);
  end;
  Handlers.Clear;
  for i := 0 to Exceptions.Count - 1 do
  begin
    Value := Exceptions[i];
    if Value^ <> nil then
    begin
      Value^.Free;
      Value^ := nil;
    end;
    HeapFree(GetProcessHeap, 0, Value);
  end;
  Exceptions.Clear;
end;
{ @end $46A038 }

{ @routine $46A0BC TCodeProcessEC_PushHandler }
procedure TCodeProcessEC.PushHandler(Code: TCodeEC; Handler: TCodeUnitEC);
var
  Entry: PCodeExceptionHandler;
begin
  Entry := HeapAlloc(GetProcessHeap, 0, SizeOf(TCodeExceptionHandler));
  Entry.Code := Code;
  Entry.Handler := Handler;
  Handlers.Add(Entry);
end;
{ @end $46A0BC }

{ @routine $46A0E8 TCodeProcessEC_PopHandler }
procedure TCodeProcessEC.PopHandler;
var
  Entry: PCodeExceptionHandler;
  Count: Integer;
begin
  Count := Handlers.Count;
  if Count < 1 then Exit;
  Entry := Handlers[Count - 1];
  HeapFree(GetProcessHeap, 0, Entry);
  Handlers.Delete(Count - 1);
end;
{ @end $46A0E8 }

{ @routine $46A124 TCodeProcessEC_GetHandler }
function TCodeProcessEC.GetHandler: PCodeExceptionHandler;
var
  Count: Integer;
begin
  Count := Handlers.Count;
  if Count < 1 then Result := nil
  else Result := Handlers[Count - 1];
end;
{ @end $46A124 }

{ @routine $46A13C TCodeProcessEC_PushException }
procedure TCodeProcessEC.PushException(Value: TVarEC);
var
  Entry: PVarEC;
begin
  Entry := HeapAlloc(GetProcessHeap, 0, SizeOf(TVarEC));
  Entry^ := TVarEC.Create(Value.ValueKind);
  Entry^.Assume(Value, False);
  Exceptions.Add(Entry);
end;
{ @end $46A13C }

{ @routine $46A188 TCodeProcessEC_PopException }
procedure TCodeProcessEC.PopException;
var
  Entry: PVarEC;
  Count: Integer;
begin
  Count := Exceptions.Count;
  if Count < 1 then Exit;
  Entry := Exceptions[Count - 1];
  HeapFree(GetProcessHeap, 0, Entry);
  Exceptions.Delete(Count - 1);
end;
{ @end $46A188 }

{ @routine $46A1C4 TCodeProcessEC_GetException }
function TCodeProcessEC.GetException: PVarEC;
var
  Count: Integer;
begin
  Count := Exceptions.Count;
  if Count < 1 then Result := nil
  else Result := Exceptions[Count - 1];
end;
{ @end $46A1C4 }

{ @routine $46A1DC TCodeProcessEC_RaiseUnhandledExceptions }
procedure TCodeProcessEC.RaiseUnhandledExceptions;
var
  Entry: PVarEC;
  Text: WideString;
  i: Integer;
begin
  Text := '';
  for i := 0 to Exceptions.Count - 1 do
  begin
    Entry := Exceptions[i];
    if i > 0 then Text := Text + #13#10;
    Text := Text + 'Exception: ' + Entry^.AsString;
  end;
  if Text <> '' then raise ExceptionExpressionEC.Create(Text);
end;
{ @end $46A1DC }

{ @routine $46A2E0 TCodeEC_Create }
constructor TCodeEC.Create;
begin
  inherited Create;
  LocalVar := TVarArrayEC.Create;
  ScriptFunLinked := False;
end;
{ @end $46A2E0 }

{ @routine $46A328 TCodeEC_Destroy }
destructor TCodeEC.Destroy;
begin
  Clear;
  LocalVar.Free;
  inherited Destroy;
end;
{ @end $46A328 }

{ @routine $46A35C TCodeEC_Clear }
procedure TCodeEC.Clear;
begin
  while First <> nil do DeleteCodeUnit(Last);
  LocalVar.Clear;
  ScriptFunLinked := False;
end;
{ @end $46A35C }

{ @routine $46A380 TCodeEC_CopyFrom }
procedure TCodeEC.CopyFrom(Source: TCodeEC);
var
  Dest, Src, DestTarget, SrcTarget: TCodeUnitEC;
begin
  Clear;
  IsClassDefinition := Source.IsClassDefinition;
  Name := Source.Name;
  Parent := Source.Parent;
  Src := Source.First;
  while Src <> nil do
  begin
    Dest := AddCodeUnit;
    Dest.Opcode := Src.Opcode;
    Dest.SourceStart := Src.SourceStart;
    Dest.SourceLength := Src.SourceLength;
    Dest.SourceContext := Src.SourceContext;
    Dest.Target := Src.Target;
    Dest.Breakpoint := Src.Breakpoint;
    Dest.Expression := nil;
    if Src.Expression <> nil then
    begin
      Dest.Expression := TExpressionEC.Create;
      Dest.Expression.CopyFrom(Src.Expression);
    end;
    Src := Src.Next;
  end;
  Src := Source.First;
  Dest := First;
  while Src <> nil do
  begin
    if Src.Target <> nil then
    begin
      SrcTarget := Source.First;
      DestTarget := First;
      while SrcTarget <> nil do
      begin
        if Src.Target = SrcTarget then Dest.Target := DestTarget;
        SrcTarget := SrcTarget.Next;
        DestTarget := DestTarget.Next;
      end;
    end;
    Src := Src.Next;
    Dest := Dest.Next;
  end;
  LocalVar.CopyFrom(Source.LocalVar, False);
  ScriptFunLinked := Source.ScriptFunLinked;
end;
{ @end $46A380 }

{ @routine $46A474 TCodeEC_CopyFromFast }
procedure TCodeEC.CopyFromFast(Source: TCodeEC);
var
  Dest, Src, DestTarget, SrcTarget: TCodeUnitEC;
begin
  Clear;
  Src := Source.First;
  while Src <> nil do
  begin
    Dest := AddCodeUnit;
    Dest.Opcode := Src.Opcode;
    Dest.SourceStart := Src.SourceStart;
    Dest.SourceLength := Src.SourceLength;
    Dest.SourceContext := Src.SourceContext;
    Dest.Target := Src.Target;
    Dest.Breakpoint := Src.Breakpoint;
    Dest.Expression := nil;
    if Src.Expression <> nil then
    begin
      Dest.Expression := TExpressionEC.Create;
      Dest.Expression.CopyFromFast(Src.Expression);
    end;
    Src := Src.Next;
  end;
  Src := Source.First;
  Dest := First;
  while Src <> nil do
  begin
    if Src.Target <> nil then
    begin
      SrcTarget := Source.First;
      DestTarget := First;
      while SrcTarget <> nil do
      begin
        if Src.Target = SrcTarget then Dest.Target := DestTarget;
        SrcTarget := SrcTarget.Next;
        DestTarget := DestTarget.Next;
      end;
    end;
    Src := Src.Next;
    Dest := Dest.Next;
  end;
  LocalVar.CopyFrom(Source.LocalVar, False);
  Src := Source.First;
  Dest := First;
  while Src <> nil do
  begin
    if Src.ExceptionVar <> nil then Dest.ExceptionVar := LocalVar.GetVarNE(Src.ExceptionVar.Name);
    Src := Src.Next;
    Dest := Dest.Next;
  end;
  ScriptFunLinked := Source.ScriptFunLinked;
end;
{ @end $46A474 }

{ @routine $46A574 TCodeEC_FindVar }
function TCodeEC.FindVar(Name: WideString): TVarEC;
var
  Item: TVarEC;
  i: Integer;
begin
  Result := LocalVar.GetVarNE(Name);
  if Result <> nil then Exit
  else for i := 0 to LocalVar.Count - 1 do
  begin
    Item := LocalVar[i];
    if (Item.Kind = vkFunction) and Item.FunctionValue.IsClassDefinition then
    begin
      Result := Item.FunctionValue.FindVar(Name);
      if Result <> nil then Exit;
    end;
  end;
end;
{ @end $46A574 }

{ @routine $46A614 TCodeEC_DeleteCodeUnit }
procedure TCodeEC.DeleteCodeUnit(CodeUnit: TCodeUnitEC);
begin
  if CodeUnit.Prev <> nil then CodeUnit.Prev.Next := CodeUnit.Next;
  if CodeUnit.Next <> nil then CodeUnit.Next.Prev := CodeUnit.Prev;
  if Last = CodeUnit then Last := CodeUnit.Prev;
  if First = CodeUnit then First := CodeUnit.Next;
  CodeUnit.Free;
end;
{ @end $46A614 }

{ @routine $46A650 TCodeEC_AddCodeUnit }
function TCodeEC.AddCodeUnit: TCodeUnitEC;
var
  Item: TCodeUnitEC;
begin
  Item := TCodeUnitEC.Create;
  if Last <> nil then Last.Next := Item;
  Item.Prev := Last;
  Item.Next := nil;
  Last := Item;
  if First = nil then First := Item;
  Result := Item;
end;
{ @end $46A650 }

{ @routine $46A684 TCodeEC_InsertCodeUnitBefore }
function TCodeEC.InsertCodeUnitBefore(BeforeUnit: TCodeUnitEC): TCodeUnitEC;
var
  Item: TCodeUnitEC;
begin
  if BeforeUnit = nil then
  begin
    Result := AddCodeUnit;
    Exit;
  end;
  Item := TCodeUnitEC.Create;
  Item.Prev := BeforeUnit.Prev;
  Item.Next := BeforeUnit;
  if BeforeUnit.Prev <> nil then BeforeUnit.Prev.Next := Item;
  BeforeUnit.Prev := Item;
  if First = BeforeUnit then First := Item;
  Result := Item;
end;
{ @end $46A684 }

{ @routine $46A6C8 TCodeEC_Compile }
function TCodeEC.Compile(Analyzer: TCodeAnalyzerEC; SourceContext: Pointer; IncludeResolver: TScriptIncludeResolver; FirstToken: TCodeAnalyzerUnitEC; NextToken: PCodeAnalyzerUnitEC): WideString;
begin
  Result := '';
  if FirstToken = nil then FirstToken := Analyzer.First;
  Result := CompileBlock(Analyzer, SourceContext, IncludeResolver, FirstToken, nil, NextToken, nil, nil, nil);
end;
{ @end $46A6C8 }

{ @routine $46AB74 TCodeEC_CompileBlock }
function TCodeEC.CompileBlock(Analyzer: TCodeAnalyzerEC; SourceContext: Pointer; IncludeResolver: TScriptIncludeResolver; Token: TCodeAnalyzerUnitEC; BeforeUnit: TCodeUnitEC; NextToken, StatementEnd: PCodeAnalyzerUnitEC; BreakTarget, ContinueTarget: TCodeUnitEC): WideString;
var
  Included: TCodeAnalyzerEC;
  IncludedContext: Pointer;
  Next: TCodeAnalyzerUnitEC;
  Keyword: WideString;
  Item, LoopStart, StepStart, EndLabel, Branch: TCodeUnitEC;
  Depth: Integer;
  Value, BaseValue: TVarEC;
  Definition: TCodeEC;
  ParameterCount: Integer;
  FloatValue: Double;
  DwordValue: Dword;
  IntValue: Integer;
  Text: WideString;
  InsertSource: Boolean;

  // @nested $46A718 AddScriptLocal
  procedure AddScriptLocal(TypeName, Name: WideString); // @addr $46A718
  begin
    if TypeName = 'unknown' then LocalVar.Add(Name, vkEmpty)
    else if TypeName = 'int' then LocalVar.Add(Name, vkInt)
    else if TypeName = 'dword' then LocalVar.Add(Name, vkDword)
    else if TypeName = 'float' then LocalVar.Add(Name, vkFloat)
    else if TypeName = 'str' then LocalVar.Add(Name, vkString)
    else if TypeName = 'ref' then LocalVar.Add(Name, vkRef)
    else if TypeName = 'array' then LocalVar.Add(Name, vkArray);
  end;

  // @nested $46A8D4 IsScriptLocalDeclaration
  function IsScriptLocalDeclaration(Token: TCodeAnalyzerUnitEC): Boolean; // @addr $46A8D4
  begin
    Result := (Token <> nil) and (Token.Next <> nil) and
      (Token.Next.TokenKind = ctText) and (Token.TokenKind = ctText) and
      ((Token.Text = 'unknown') or (Token.Text = 'int') or (Token.Text = 'dword') or
       (Token.Text = 'float') or (Token.Text = 'str') or (Token.Text = 'ref') or
       (Token.Text = 'array')) and IsNonIntegerScriptText(Token.Next.Text);
  end;

  // @nested $46A9E0 CompileScriptLocals
  function CompileScriptLocals(var Token: TCodeAnalyzerUnitEC): WideString; // @addr $46A9E0
  var
    Item: TCodeUnitEC;
    Next: TCodeAnalyzerUnitEC;
    TypeName: WideString;
  begin
    Result := '';
    TypeName := Token.Text;
    Token := Token.Next;
    while (Token.TokenKind = ctText) and IsNonIntegerScriptText(Token.Text) do
    begin
      if LocalVar.GetVarNE(Token.Text) <> nil then
      begin
        Result := FormatScriptError(0, Token.SourceStart);
        Exit;
      end;
      AddScriptLocal(TypeName, Token.Text);
      if Token.Next = nil then
      begin
        Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
        Exit;
      end;
      Token := Token.Next;
      if Token.TokenKind = ctComma then
      begin
        Token := Token.Next;
        Continue;
      end;
      if Token.TokenKind = ctAssign then
      begin
        Item := InsertCodeUnitBefore(BeforeUnit);
        Item.Opcode := coExpression;
        Item.Expression := TExpressionEC.Create;
        Item.SourceStart := Token.Prev.SourceStart;
        Item.SourceLength := 0;
        Item.SourceContext := SourceContext;
        Result := Item.Expression.Compile(Analyzer, Token.Prev, nil, @Next);
        if Result <> '' then Exit;
        Item.SourceLength := Next.Prev.SourceStart + Next.Prev.SourceLength - Item.SourceStart;
        Token := Next;
        if Token.TokenKind = ctComma then Token := Token.Next;
      end;
    end;
  end;

begin
  Result := '';
  Depth := 0;
  while Token <> nil do
  begin
    if Token.TokenKind = ctText then
    begin
      Keyword := LowerCase(AnsiString(Token.Text));
      if IsScriptLocalDeclaration(Token) then
      begin
        Result := CompileScriptLocals(Token);
        if Result <> '' then Exit;
        if Token.TokenKind <> ctSemicolon then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        Token := Token.Next;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Token;
          Exit;
        end;
        Continue;
      end
      else if Keyword = 'if' then
      begin
        EndLabel := InsertCodeUnitBefore(BeforeUnit);
        EndLabel.Opcode := coLabel;
        EndLabel.SourceStart := 0;
        EndLabel.SourceLength := 0;
        EndLabel.SourceContext := SourceContext;
        while True do
        begin
          if Token.Next = nil then
          begin
            Result := FormatScriptError(0, Token.SourceStart);
            Exit;
          end;
          if (Token.Next.TokenKind <> ctOpenParen) or (Token.Next.Next = nil) then
          begin
            Result := FormatScriptError(0, Token.Next.SourceStart);
            Exit;
          end;
          Item := InsertCodeUnitBefore(EndLabel);
          Item.Opcode := coBranchFalse;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := 0;
          Item.SourceContext := SourceContext;
          Item.Target := EndLabel;
          Item.Expression := TExpressionEC.Create;
          Result := Item.Expression.Compile(Analyzer, Token.Next.Next, nil, @Next);
          if Result <> '' then Exit;
          if Next = nil then
          begin
            Result := FormatScriptError(0, Token.SourceStart);
            Exit;
          end;
          if Next.TokenKind <> ctCloseParen then
          begin
            Result := FormatScriptError(0, Next.SourceStart);
            Exit;
          end;
          Token := Next.Next;
          Item.SourceLength := Next.SourceStart - Item.SourceStart + Next.SourceLength;
          Branch := Item;
          if Token = nil then raise ExceptionExpressionEC.Create('Compiler error, code ends abruptly');
          Item := InsertCodeUnitBefore(EndLabel);
          Item.Opcode := coJump;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := 0;
          Item.SourceContext := SourceContext;
          Item.Target := EndLabel;
          LoopStart := Item;
          if Token.TokenKind = ctSemicolon then Token := Token.Next
          else
          begin
            Result := CompileBlock(Analyzer, SourceContext, IncludeResolver, Token, LoopStart,
              NextToken, @Token, BreakTarget, ContinueTarget);
            if Result <> '' then Exit;
          end;
          if Token = nil then Exit;
          if Token.TokenKind <> ctText then Break;
          Keyword := LowerCase(AnsiString(Token.Text));
          if Keyword <> 'else' then Break;
          Item := InsertCodeUnitBefore(EndLabel);
          Item.Opcode := coLabel;
          Item.SourceStart := 0;
          Item.SourceLength := 0;
          Item.SourceContext := SourceContext;
          Branch.Target := Item;
          if (Token.Next <> nil) and (Token.Next.TokenKind = ctText) and
            (LowerCase(AnsiString(Token.Next.Text)) = 'if') then
          begin
            Token := Token.Next;
            Continue;
          end;
          if Token.Next = nil then
          begin
            Result := FormatScriptError(0, Token.SourceStart);
            Exit;
          end;
          if Token.Next.TokenKind = ctSemicolon then Continue;
          Result := CompileBlock(Analyzer, SourceContext, IncludeResolver, Token.Next, EndLabel,
            NextToken, @Token, BreakTarget, ContinueTarget);
          if Result <> '' then Exit;
          if (StatementEnd <> nil) and (Depth = 0) then
          begin
            StatementEnd^ := Token;
            Exit;
          end;
          Break;
        end;
        Continue;
      end
      else if Keyword = 'while' then
      begin
        EndLabel := InsertCodeUnitBefore(BeforeUnit);
        EndLabel.Opcode := coLabel;
        EndLabel.SourceStart := 0;
        EndLabel.SourceLength := 0;
        EndLabel.SourceContext := SourceContext;
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        if (Token.Next.TokenKind <> ctOpenParen) or (Token.Next.Next = nil) then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        Item := InsertCodeUnitBefore(EndLabel);
        Item.Opcode := coBranchFalse;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := 0;
        Item.SourceContext := SourceContext;
        Item.Target := EndLabel;
        Item.Expression := TExpressionEC.Create;
        Result := Item.Expression.Compile(Analyzer, Token.Next.Next, nil, @Next);
        if Result <> '' then Exit;
        if Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        if Next.TokenKind <> ctCloseParen then
        begin
          Result := FormatScriptError(0, Next.SourceStart);
          Exit;
        end;
        Token := Next.Next;
        Item.SourceLength := Next.SourceStart - Item.SourceStart + Next.SourceLength;
        LoopStart := Item;
        Item := InsertCodeUnitBefore(EndLabel);
        Item.Opcode := coJump;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := 0;
        Item.SourceContext := SourceContext;
        Item.Target := LoopStart;
        if Token.TokenKind = ctSemicolon then Token := Token.Next
        else
        begin
          Result := CompileBlock(Analyzer, SourceContext, IncludeResolver, Token, Item,
            NextToken, @Token, EndLabel, LoopStart);
          if Result <> '' then Exit;
        end;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Token;
          Exit;
        end;
        Continue;
      end
      else if Keyword = 'for' then
      begin
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        if Token.Next.TokenKind <> ctOpenParen then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        if Token.Next.Next = nil then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart + Token.Next.SourceLength);
          Exit;
        end;
        Token := Token.Next.Next;
        if Token.TokenKind <> ctSemicolon then
        begin
          if IsScriptLocalDeclaration(Token) then
          begin
            Result := CompileScriptLocals(Token);
            if Result <> '' then Exit;
          end
          else
          begin
            while True do
            begin
              Item := InsertCodeUnitBefore(BeforeUnit);
              Item.Opcode := coExpression;
              Item.SourceStart := Token.SourceStart;
              Item.SourceLength := 0;
              Item.SourceContext := SourceContext;
              Item.Expression := TExpressionEC.Create;
              Result := Item.Expression.Compile(Analyzer, Token, nil, @Next);
              if Result <> '' then Exit;
              if Next = nil then
              begin
                Result := FormatScriptError(0, Token.SourceStart);
                Exit;
              end;
              Item.SourceLength := Next.SourceStart - Item.SourceStart + Next.SourceLength;
              if Next.TokenKind = ctSemicolon then
              begin
                Token := Next;
                Break;
              end
              else if Next.TokenKind = ctComma then Token := Next.Next
              else
              begin
                Result := FormatScriptError(0, Next.SourceStart);
                Exit;
              end;
            end;
          end;
        end;
        if Token.TokenKind <> ctSemicolon then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        Token := Token.Next;
        EndLabel := InsertCodeUnitBefore(BeforeUnit);
        EndLabel.Opcode := coLabel;
        EndLabel.SourceStart := 0;
        EndLabel.SourceLength := 0;
        EndLabel.SourceContext := SourceContext;
        if Token.TokenKind = ctSemicolon then
        begin
          Item := InsertCodeUnitBefore(EndLabel);
          Item.Opcode := coLabel;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := 0;
          Item.SourceContext := SourceContext;
          Token := Token.Next;
        end
        else
        begin
          Item := InsertCodeUnitBefore(EndLabel);
          Item.Opcode := coBranchFalse;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := 0;
          Item.SourceContext := SourceContext;
          Item.Target := EndLabel;
          Item.Expression := TExpressionEC.Create;
          Result := Item.Expression.Compile(Analyzer, Token, nil, @Next);
          if Result <> '' then Exit;
          if Next = nil then
          begin
            Result := FormatScriptError(0, Token.SourceStart);
            Exit;
          end;
          if Next.TokenKind <> ctSemicolon then
          begin
            Result := FormatScriptError(0, Next.SourceStart);
            Exit;
          end;
          if Next.Next = nil then
          begin
            Result := FormatScriptError(0, Next.SourceStart + Next.SourceLength);
            Exit;
          end;
          Token := Next.Next;
          Item.SourceLength := Next.Prev.SourceStart - Item.SourceStart + Next.Prev.SourceLength;
        end;
        LoopStart := Item;
        Item := InsertCodeUnitBefore(LoopStart);
        Item.Opcode := coJump;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := 0;
        Item.SourceContext := SourceContext;
        Item.Target := LoopStart;
        StepStart := nil;
        if Token.TokenKind = ctCloseParen then
        begin
          Item := InsertCodeUnitBefore(LoopStart);
          Item.Opcode := coLabel;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := 0;
          Item.SourceContext := SourceContext;
          StepStart := Item;
          Token := Token.Next;
        end
        else
        begin
          while True do
          begin
            Item := InsertCodeUnitBefore(LoopStart);
            Item.Opcode := coExpression;
            Item.SourceStart := Token.SourceStart;
            Item.SourceLength := 0;
            Item.SourceContext := SourceContext;
            Item.Expression := TExpressionEC.Create;
            Result := Item.Expression.Compile(Analyzer, Token, nil, @Next);
            if Result <> '' then Exit;
            if Next = nil then
            begin
              Result := FormatScriptError(0, Token.SourceStart);
              Exit;
            end;
            Item.SourceLength := Next.Prev.SourceStart - Item.SourceStart + Next.Prev.SourceLength;
            if StepStart = nil then StepStart := Item;
            if Next.TokenKind = ctCloseParen then
            begin
              Token := Next.Next;
              Break;
            end
            else if Next.TokenKind = ctComma then Token := Next.Next
            else
            begin
              Result := FormatScriptError(0, Next.SourceStart);
              Exit;
            end;
          end;
        end;
        Item := InsertCodeUnitBefore(EndLabel);
        Item.Opcode := coJump;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := 0;
        Item.SourceContext := SourceContext;
        Item.Target := StepStart;
        if Token.TokenKind = ctSemicolon then Token := Token.Next
        else
        begin
          Result := CompileBlock(Analyzer, SourceContext, IncludeResolver, Token, Item,
            NextToken, @Token, EndLabel, StepStart);
          if Result <> '' then Exit;
        end;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Token;
          Exit;
        end;
        Continue;
      end
      else if Keyword = 'break' then
      begin
        if (BreakTarget = nil) or (Token.Next = nil) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        if Token.Next.TokenKind <> ctSemicolon then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        Item := InsertCodeUnitBefore(BeforeUnit);
        Item.Opcode := coJump;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.Next.SourceStart - Token.SourceStart + Token.Next.SourceLength;
        Item.SourceContext := SourceContext;
        Item.Target := BreakTarget;
        Token := Token.Next.Next;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Token;
          Exit;
        end;
        Continue;
      end
      else if Keyword = 'continue' then
      begin
        if (ContinueTarget = nil) or (Token.Next = nil) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        if Token.Next.TokenKind <> ctSemicolon then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        Item := InsertCodeUnitBefore(BeforeUnit);
        Item.Opcode := coJump;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.Next.SourceStart - Token.SourceStart + Token.Next.SourceLength;
        Item.SourceContext := SourceContext;
        Item.Target := ContinueTarget;
        Token := Token.Next.Next;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Token;
          Exit;
        end;
        Continue;
      end
      else if Keyword = 'exit' then
      begin
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        if Token.Next.TokenKind <> ctSemicolon then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        Item := InsertCodeUnitBefore(BeforeUnit);
        Item.Opcode := coExit;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := Token.Next.SourceStart - Token.SourceStart + Token.Next.SourceLength;
        Item.SourceContext := SourceContext;
        Token := Token.Next.Next;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Token;
          Exit;
        end;
        Continue;
      end
      else if (Keyword = '#include') or (Keyword = '#insert') then
      begin
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        if Token.Next.TokenKind <> ctStringLiteral then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        if not Assigned(IncludeResolver) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        InsertSource := Keyword = '#insert';
        Included := TCodeAnalyzerEC.Create;
        IntValue := IncludeResolver(SourceContext, Token.Next.Text, InsertSource, IncludedContext, Included);
        if (IntValue = 2) or (IntValue = 3) then
        begin
          Included.Free;
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        if IntValue = 0 then
        begin
          Text := Included.ValidateDelimiters;
          if Text <> '' then
          begin
            Included.Free;
            Result := FormatScriptError(0, Token.Next.SourceStart);
            Exit;
          end;
          Result := CompileBlock(Included, IncludedContext, IncludeResolver, Included.First, BeforeUnit,
            nil, nil, nil, nil);
          if Result <> '' then
          begin
            Included.Free;
            Exit;
          end;
        end;
        Included.Free;
        Token := Token.Next.Next;
        Continue;
      end
      else if Keyword = 'function' then
      begin
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        if (Token.Next.TokenKind <> ctText) or not IsNonIntegerScriptText(Token.Next.Text) or
          (Token.Next.Next = nil) then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        if (Token.Next.Next.TokenKind <> ctOpenParen) or (Token.Next.Next.Next = nil) then
        begin
          Result := FormatScriptError(0, Token.Next.Next.SourceStart);
          Exit;
        end;
        Value := LocalVar.Add(Token.Next.Text, vkFunction);
        Definition := Value.AsFunction;
        Definition.Parent := Self;
        Next := Token.Next.Next.Next;
        while (Next <> nil) and (Next.TokenKind = ctText) and IsNonIntegerScriptText(Next.Text) do
        begin
          Keyword := LowerCase(AnsiString(Next.Text));
          if (Keyword = 'unknown') or (Keyword = 'int') or (Keyword = 'dword') or
            (Keyword = 'float') or (Keyword = 'str') or (Keyword = 'ref') or (Keyword = 'array') then
            Next := Next.Next
          else Keyword := 'unknown';
          if (Next = nil) or (Next.TokenKind <> ctText) or not IsNonIntegerScriptText(Next.Text) then Break;
          Value := nil;
          if Keyword = 'unknown' then Value := Definition.LocalVar.Add(Next.Text, vkEmpty)
          else if Keyword = 'int' then Value := Definition.LocalVar.Add(Next.Text, vkInt)
          else if Keyword = 'dword' then Value := Definition.LocalVar.Add(Next.Text, vkDword)
          else if Keyword = 'float' then Value := Definition.LocalVar.Add(Next.Text, vkFloat)
          else if Keyword = 'str' then Value := Definition.LocalVar.Add(Next.Text, vkString)
          else if Keyword = 'ref' then Value := Definition.LocalVar.Add(Next.Text, vkRef)
          else if Keyword = 'array' then Value := Definition.LocalVar.Add(Next.Text, vkArray);
          Next := Next.Next;
          if Next = nil then
          begin
            Result := FormatScriptError(0, Analyzer.Last.SourceStart + Analyzer.Last.SourceLength);
            Exit;
          end;
          if (Keyword <> 'ref') and (Next.TokenKind = ctAssign) then
          begin
            if Next.Next = nil then
            begin
              Result := FormatScriptError(0, Analyzer.Last.SourceStart + Analyzer.Last.SourceLength);
              Exit;
            end;
            Next := Next.Next;
            if TryReadFloatLiteral(Next, FloatValue) then Value.AsFloat := FloatValue
            else if TryReadDwordLiteral(Next, DwordValue) then Value.AsDword := DwordValue
            else if TryReadIntegerLiteral(Next, IntValue) then Value.AsInteger := IntValue
            else if TryReadStringLiteral(Next, Text) then Value.AsString := Text
            else
            begin
              Result := FormatScriptError(0, Next.SourceStart);
              Exit;
            end;
          end;
          if (Next = nil) or (Next.TokenKind <> ctComma) then Break;
          Next := Next.Next;
        end;
        if (Next = nil) or (Next.TokenKind <> ctCloseParen) then
        begin
          Result := FormatScriptError(0, Token.Next.Next.Next.SourceStart);
          Exit;
        end;
        Token := Next.Next;
        if Token = nil then
        begin
          Result := FormatScriptError(0, Next.SourceStart);
          Exit;
        end;
        if (Token.TokenKind <> ctOpenBrace) or (Token.Next = nil) then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        ParameterCount := Definition.LocalVar.Count;
        Definition.LocalVar.Add('funBaseVarCount', vkInt).AsInteger := ParameterCount;
        Definition.LocalVar.Add('result', vkRef);
        Next := nil;
        Result := Definition.Compile(Analyzer, SourceContext, IncludeResolver, Token.Next, @Next);
        if Result <> '' then Exit;
        if Next = nil then
        begin
          Result := FormatScriptError(0, Analyzer.Last.SourceStart + Analyzer.Last.SourceLength);
          Exit;
        end;
        if Next.TokenKind <> ctCloseBrace then
        begin
          Result := FormatScriptError(0, Next.SourceStart);
          Exit;
        end;
        Token := Next.Next;
        Continue;
      end
      else if Keyword = 'class' then
      begin
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        if (Token.Next.TokenKind <> ctText) or not IsNonIntegerScriptText(Token.Next.Text) then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        if Token.Next.Next = nil then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart + Token.Next.SourceLength);
          Exit;
        end;
        Value := LocalVar.Add(Token.Next.Text, vkFunction);
        Definition := Value.AsFunction;
        Definition.Parent := Self;
        Definition.IsClassDefinition := True;
        Definition.Name := Token.Next.Text;
        Token := Token.Next.Next;
        if Token.TokenKind = ctColon then
        begin
          Token := Token.Next;
          while True do
          begin
            if Token.TokenKind <> ctText then Break;
            BaseValue := LocalVar.GetVarNE(Token.Text);
            if (BaseValue = nil) or (BaseValue.ValueKind <> vkFunction) then
            begin
              Result := FormatScriptError(0, Token.SourceStart);
              Exit;
            end;
            Definition.LocalVar.Add(Token.Text, vkFunction).AsFunction.CopyFrom(BaseValue.AsFunction);
            Token := Token.Next;
            if Token.TokenKind <> ctComma then Break;
            Token := Token.Next;
          end;
        end;
        if Token.TokenKind <> ctOpenBrace then
        begin
          Result := FormatScriptError(0, Token.SourceStart);
          Exit;
        end;
        Next := nil;
        Result := Definition.Compile(Analyzer, SourceContext, IncludeResolver, Token.Next, @Next);
        if Result <> '' then Exit;
        if Next = nil then
        begin
          Result := FormatScriptError(0, Analyzer.Last.SourceStart + Analyzer.Last.SourceLength);
          Exit;
        end;
        if Next.TokenKind <> ctCloseBrace then
        begin
          Result := FormatScriptError(0, Next.SourceStart);
          Exit;
        end;
        Token := Next.Next;
        Continue;
      end
      else if Keyword = 'try' then
      begin
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        if Token.Next.TokenKind <> ctOpenBrace then
        begin
          Result := FormatScriptError(0, Token.Next.SourceStart);
          Exit;
        end;
        LoopStart := InsertCodeUnitBefore(BeforeUnit);
        LoopStart.Opcode := coPushHandler;
        LoopStart.SourceStart := Token.SourceStart;
        LoopStart.SourceLength := 0;
        LoopStart.SourceContext := SourceContext;
        Result := CompileBlock(Analyzer, SourceContext, IncludeResolver, Token.Next, BeforeUnit,
          NextToken, @Token, nil, nil);
        if Result <> '' then Exit;
        Item := InsertCodeUnitBefore(BeforeUnit);
        Item.Opcode := coPopHandler;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := 0;
        Item.SourceContext := SourceContext;
        if Token = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        if Token.TokenKind <> ctText then
        begin
          Result := FormatScriptError(1001, Token.SourceStart);
          Exit;
        end;
        if (Token.Text <> 'catch') and (Token.Text <> 'finally') then
        begin
          Result := FormatScriptError(1001, Token.SourceStart);
          Exit;
        end;
        if Token.Next = nil then
        begin
          Result := FormatScriptError(1001, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        if Token.Text = 'catch' then IntValue := 0
        else IntValue := 1;
        Token := Token.Next;
        Value := nil;
        if Token.TokenKind = ctOpenParen then
        begin
          if Token.Next = nil then
          begin
            Result := FormatScriptError(1001, Token.SourceStart + Token.SourceLength);
            Exit;
          end;
          Token := Token.Next;
          if Token.TokenKind <> ctText then
          begin
            Result := FormatScriptError(1001, Token.SourceStart);
            Exit;
          end;
          Value := LocalVar.Add(Token.Text, vkEmpty);
          if Token.Next = nil then
          begin
            Result := FormatScriptError(1001, Token.SourceStart + Token.SourceLength);
            Exit;
          end;
          Token := Token.Next;
          if Token.TokenKind <> ctCloseParen then
          begin
            Result := FormatScriptError(1001, Token.SourceStart);
            Exit;
          end;
          if Token.Next = nil then
          begin
            Result := FormatScriptError(1001, Token.SourceStart + Token.SourceLength);
            Exit;
          end;
          Token := Token.Next;
        end;
        if Token.TokenKind <> ctOpenBrace then
        begin
          Result := FormatScriptError(1001, Token.SourceStart);
          Exit;
        end;
        EndLabel := InsertCodeUnitBefore(BeforeUnit);
        EndLabel.Opcode := coLabel;
        EndLabel.SourceStart := 0;
        EndLabel.SourceLength := 0;
        EndLabel.SourceContext := SourceContext;
        if IntValue = 0 then
        begin
          Item := InsertCodeUnitBefore(EndLabel);
          Item.Opcode := coJump;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := 0;
          Item.SourceContext := SourceContext;
          Item.Target := EndLabel;
        end;
        Item := InsertCodeUnitBefore(EndLabel);
        Item.Opcode := coLabel;
        Item.SourceStart := 0;
        Item.SourceLength := 0;
        Item.SourceContext := SourceContext;
        LoopStart.Target := Item;
        Item.ExceptionVar := Value;
        Item := EndLabel;
        if IntValue = 1 then
        begin
          Item := InsertCodeUnitBefore(Item);
          Item.Opcode := coThrow;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := 0;
          Item.SourceContext := SourceContext;
        end;
        Result := CompileBlock(Analyzer, SourceContext, IncludeResolver, Token, Item,
          NextToken, @Token, nil, nil);
        if Result <> '' then Exit;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Token;
          Exit;
        end;
        Continue;
      end
      else if Keyword = 'throw' then
      begin
        if Token.Next = nil then
        begin
          Result := FormatScriptError(0, Token.SourceStart + Token.SourceLength);
          Exit;
        end;
        if Token.Next.TokenKind = ctSemicolon then
        begin
          Item := InsertCodeUnitBefore(BeforeUnit);
          Item.Opcode := coThrow;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := Token.Next.SourceStart - Token.SourceStart + Token.Next.SourceLength;
          Item.SourceContext := SourceContext;
          Token := Token.Next.Next;
        end
        else
        begin
          Item := InsertCodeUnitBefore(BeforeUnit);
          Item.Opcode := coThrow;
          Item.SourceStart := Token.SourceStart;
          Item.SourceLength := Token.Next.SourceStart - Token.SourceStart + Token.Next.SourceLength;
          Item.SourceContext := SourceContext;
          Item.Expression := TExpressionEC.Create;
          Result := Item.Expression.Compile(Analyzer, Token.Next, nil, @Next);
          if Result <> '' then Exit;
          if Next = nil then
          begin
            Result := FormatScriptError(0, Token.SourceStart);
            Exit;
          end;
          if Next.TokenKind <> ctSemicolon then
          begin
            Result := FormatScriptError(0, Next.SourceStart);
            Exit;
          end;
          Token := Next.Next;
          Item.SourceLength := Next.SourceStart - Item.SourceStart + Next.SourceLength;
        end;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Token;
          Exit;
        end;
        Continue;
      end
      else
      begin
        Item := InsertCodeUnitBefore(BeforeUnit);
        Item.Opcode := coExpression;
        Item.Expression := TExpressionEC.Create;
        Item.SourceStart := Token.SourceStart;
        Item.SourceLength := 0;
        Item.SourceContext := SourceContext;
        Result := Item.Expression.Compile(Analyzer, Token, nil, @Next);
        if Result <> '' then Exit;
        if Next = nil then
        begin
          Result := FormatScriptError(0, Analyzer.Last.SourceStart + Analyzer.Last.SourceLength);
          Exit;
        end;
        if Next.TokenKind <> ctSemicolon then
        begin
          Result := FormatScriptError(0, Next.SourceStart);
          Exit;
        end;
        Item.SourceLength := Next.SourceStart + Next.SourceLength - Item.SourceStart;
        if (StatementEnd <> nil) and (Depth = 0) then
        begin
          StatementEnd^ := Next.Next;
          Exit;
        end;
        Token := Next.Next;
        Continue;
      end;
    end
    else if Token.TokenKind = ctOpenBrace then Inc(Depth)
    else if Token.TokenKind = ctCloseBrace then
    begin
      Dec(Depth);
      if (StatementEnd <> nil) and (Depth = 0) then
      begin
        StatementEnd^ := Token.Next;
        Exit;
      end;
      if Depth = -1 then
      begin
        if NextToken <> nil then NextToken^ := Token;
        Exit;
      end;
    end
    else
    begin
      Result := FormatScriptError(0, Token.SourceStart);
      Exit;
    end;
    if Token = nil then Exit;
    Token := Token.Next;
  end;
end;
{ @end $46AB74 }

{ @routine $46CA80 TCodeEC_LinkAll }
procedure TCodeEC.LinkAll(Scope: TVarArrayEC; OnlyUnlinked: Boolean);
var
  Item: TCodeUnitEC;
  i: Integer;
begin
  Item := First;
  while Item <> nil do
  begin
    if Item.Expression <> nil then Item.Expression.Link(Scope, OnlyUnlinked);
    Item := Item.Next;
  end;
  for i := 0 to LocalVar.Count - 1 do
  begin
    with LocalVar[i] do
    begin
      if (Kind = vkFunction) and (GetFunction <> nil) then
        GetFunction.LinkAll(Scope, OnlyUnlinked)
      else if Kind = vkClass then
      begin
        if GetClass <> nil then GetClass.LinkAll(Scope, OnlyUnlinked);
      end;
    end;
  end;
end;
{ @end $46CA80 }

{ @routine $46CB28 TCodeEC_LinkLocalScopes }
procedure TCodeEC.LinkLocalScopes;
var
  i: Integer;
begin
  for i := 0 to LocalVar.Count - 1 do
  begin
    with LocalVar[i] do
    begin
      if (Kind = vkFunction) and
        (FunctionValue <> nil) and
        FunctionValue.IsClassDefinition then
        FunctionValue.LinkLocalScopes;
    end;
  end;
  LinkAll(LocalVar, False);
end;
{ @end $46CB28 }

{ @routine $46CB78 SetScriptStepCallback }
procedure SetScriptStepCallback(Callback: TScriptStepCallback; Interval: Integer);
begin
  ScriptStepCallback := Callback;
  ScriptStepInterval := Interval;
end;
{ @end $46CB78 }

{ @routine $46CB84 TCodeEC_Run }
procedure TCodeEC.Run(Process: TCodeProcessEC);
var
  Item: TCodeUnitEC;
  Handler: PCodeExceptionHandler;
  Pending: PVarEC;
  Caught: TVarEC;
  Steps, TotalSteps: Integer;
begin
  ScriptCallTracePosition := 0;
  ScriptCallTraceCount := 0;
  LinkAll(LocalVar, False);
  Caught := nil;
  Item := First;
  Steps := 0;
  TotalSteps := 0;
  while Item <> nil do
  begin
    Inc(Steps);
    if (Steps > ScriptStepInterval) and (ScriptStepInterval > 0) then
    begin
      Inc(TotalSteps, ScriptStepInterval);
      Dec(Steps, ScriptStepInterval);
      if Assigned(ScriptStepCallback) then ScriptStepCallback(TotalSteps);
    end;
    if Item.Opcode = coExpression then
    begin
      try
        Item.Expression.Evaluate(Process, Self, nil);
      except
        raise;
      end;
    end
    else if Item.Opcode = coJump then
    begin
      Item := Item.Target;
      Continue;
    end
    else if Item.Opcode = coBranchFalse then
    begin
      try
        Item.Expression.Evaluate(Process, Self, nil);
      except
        raise;
      end;
      if not Item.Expression.GetResult.IsTrue then
      begin
        Item := Item.Target;
        Continue;
      end;
    end
    else if Item.Opcode = coExit then
    begin
      while True do
      begin
        Handler := Process.GetHandler;
        if (Handler = nil) or (Handler.Code <> Self) then Break;
        Process.PopHandler;
      end;
      Break;
    end
    else if Item.Opcode = coPushHandler then Process.PushHandler(Self, Item.Target)
    else if Item.Opcode = coPopHandler then Process.PopHandler
    else if Item.Opcode = coThrow then
    begin
      if Item.Expression <> nil then
      begin
        Item.Expression.Evaluate(Process, Self, nil);
        Process.PushException(Item.Expression.GetResult);
      end
      else if Caught <> nil then
      begin
        Process.PushException(Caught);
        Caught := nil;
      end;
    end;
    Pending := Process.GetException;
    if Pending <> nil then
    begin
      Handler := Process.GetHandler;
      if Handler <> nil then
      begin
        if Handler.Code <> Self then Break;
        Item := Handler.Handler;
        Caught := Pending^;
        Pending^ := nil;
        if Item.ExceptionVar <> nil then Item.ExceptionVar.Assume(Caught, False);
        Process.PopHandler;
        Process.PopException;
        Continue;
      end
      else Process.RaiseUnhandledExceptions;
    end;
    Item := Item.Next;
  end;
  if Caught <> nil then Caught.Free;
  ScriptCallTracePosition := 0;
  ScriptCallTraceCount := 0;
end;
{ @end $46CB84 }

{ @routine $46CDD8 TCodeEC_RunDebug }
procedure TCodeEC.RunDebug(Process: TCodeProcessEC; DebugContext: TScriptDebugState);
var
  Item: TCodeUnitEC;
  Events: array[0..1] of Dword;
  WaitResult: Dword;
  Handler: PCodeExceptionHandler;
  Pending: PVarEC;
  Caught: TVarEC;
begin
  ScriptCallTracePosition := 0;
  ScriptCallTraceCount := 0;
  LinkAll(LocalVar, False);
  Caught := nil;
  Events[0] := DebugContext.StopEvent;
  Events[1] := DebugContext.ResumeEvent;
  Item := First;
  while Item <> nil do
  begin
    WaitResult := WaitForSingleObject(DebugContext.StopEvent, 0);
    if (WaitResult = WAIT_FAILED) or (WaitResult = WAIT_OBJECT_0) or
      (WaitResult = WAIT_ABANDONED_0) then Break;
    if (DebugContext.Paused and (Item.SourceLength > 0)) or Item.Breakpoint then
    begin
      DebugContext.CurrentUnit := Item;
      ResetEvent(DebugContext.ResumeEvent);
      WaitResult := WaitForMultipleObjects(Length(Events), @Events, False, INFINITE);
      if (WaitResult = WAIT_FAILED) or (WaitResult = WAIT_OBJECT_0) or
        ((WaitResult >= WAIT_ABANDONED_0) and (WaitResult < WAIT_ABANDONED_0 + Length(Events))) then Break;
      DebugContext.CurrentCode := Self;
      if DebugContext.StepMode = 1 then DebugContext.Paused := True;
    end;
    if Item.Opcode = coExpression then
    begin
      try
        Item.Expression.Evaluate(Process, Self, DebugContext);
      except
        raise;
      end;
    end
    else if Item.Opcode = coJump then
    begin
      Item := Item.Target;
      Continue;
    end
    else if Item.Opcode = coBranchFalse then
    begin
      try
        Item.Expression.Evaluate(Process, Self, DebugContext);
      except
        raise;
      end;
      if not Item.Expression.GetResult.IsTrue then
      begin
        Item := Item.Target;
        Continue;
      end;
    end
    else if Item.Opcode = coExit then
    begin
      while True do
      begin
        Handler := Process.GetHandler;
        if (Handler = nil) or (Handler.Code <> Self) then Break;
        Process.PopHandler;
      end;
      Break;
    end
    else if Item.Opcode = coPushHandler then Process.PushHandler(Self, Item.Target)
    else if Item.Opcode = coPopHandler then Process.PopHandler
    else if Item.Opcode = coThrow then
    begin
      if Item.Expression <> nil then
      begin
        Item.Expression.Evaluate(Process, Self, nil);
        Process.PushException(Item.Expression.GetResult);
      end
      else if Caught <> nil then
      begin
        Process.PushException(Caught);
        Caught := nil;
      end;
    end;
    Pending := Process.GetException;
    if Pending <> nil then
    begin
      Handler := Process.GetHandler;
      if Handler <> nil then
      begin
        if Handler.Code <> Self then Break;
        Item := Handler.Handler;
        Caught := Pending^;
        Pending^ := nil;
        if Item.ExceptionVar <> nil then Item.ExceptionVar.Assume(Caught, False);
        Process.PopHandler;
        Process.PopException;
        Continue;
      end
      else Break;
    end;
    if (DebugContext.StepMode = 2) and (DebugContext.CurrentCode = Self) then
      DebugContext.Paused := True;
    Item := Item.Next;
  end;
  if ((DebugContext.StepMode = 2) or (DebugContext.StepMode = 3)) and
    (DebugContext.CurrentCode = Self) then DebugContext.Paused := True;
  if Caught <> nil then Caught.Free;
  ScriptCallTracePosition := 0;
  ScriptCallTraceCount := 0;
end;
{ @end $46CDD8 }

{ @routine $46D0BC EF_Min }
procedure EF_Min(av: array of TVarEC; code: TCodeEC);
var
  i, Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].Assume(av[1], False);
  for i := 2 to Count - 1 do
  begin
    if (av[0].ValueKind = vkString) and (av[i].ValueKind in [vkInt, vkDword, vkFloat]) then
      av[0].ConvertToKind(av[i].ValueKind)
    else if (av[i].ValueKind = vkFloat) and (av[0].ValueKind in [vkInt, vkDword]) then begin
       av[0].ConvertToKind(av[i].ValueKind);
    end;
    if av[0].GreaterThan(av[i]) then av[0].Assume(av[i], False);
  end;
end;
{ @end $46D0BC }

{ @routine $46D174 EF_Max }
procedure EF_Max(av: array of TVarEC; code: TCodeEC);
var
  i, Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].Assume(av[1], False);
  for i := 2 to Count - 1 do
  begin
    if (av[0].ValueKind = vkString) and (av[i].ValueKind in [vkInt, vkDword, vkFloat]) then
      av[0].ConvertToKind(av[i].ValueKind)
    else if (av[i].ValueKind = vkFloat) and (av[0].ValueKind in [vkInt, vkDword]) then begin
       av[0].ConvertToKind(av[i].ValueKind);
    end;
    if av[0].LessThan(av[i]) then av[0].Assume(av[i], False);
  end;
end;
{ @end $46D174 }

{ @routine $46D254 EF_NewArray }
procedure EF_NewArray(av: array of TVarEC; code: TCodeEC);
var
  i, Count: Integer;
  Dimensions: array of Integer;
begin
  Count := High(av) + 1;
  av[0].ResetKind(vkArray);
  if Count < 2 then Exit;
  Dec(Count);
  SetLength(Dimensions, Count);
  for i := 0 to Count - 1 do
  begin
    if (av[i + 1].ValueKind <> vkInt) or (av[i + 1].AsInteger < 1) then
    begin
      Dimensions := nil;
      Exit;
    end;
    Dimensions[i] := av[i + 1].AsInteger;
  end;
  av[0].CreateArray(Dimensions);
  Dimensions := nil;
end;
{ @end $46D254 }

{ @routine $46D350 EF_ArrayChange }
procedure EF_ArrayChange(av: array of TVarEC; code: TCodeEC);
var
  Dimension: Integer;
begin
  if High(av) < 2 then Exit;
  Dimension := 0;
  if High(av) >= 3 then Dimension := av[3].AsInteger;
  av[1].ResizeArray(av[2].AsInteger, Dimension);
end;
{ @end $46D350 }

{ @routine $46D39C EF_Free }
procedure EF_Free(av: array of TVarEC; code: TCodeEC);
var
  Count, i: Integer;
begin
  Count := High(av) + 1 - 1;
  if Count < 1 then Exit;
  av[0].Assume(av[1], False);
  for i := 0 to Count - 1 do av[i + 1].FreeArray;
end;
{ @end $46D39C }

{ @routine $46D3EC EF_Count }
procedure EF_Count(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1 - 1;
  if Count < 1 then Exit;
  if av[1].ValueKind = vkArray then av[0].AsInteger := av[1].AsArray.Count;
  if av[1].ValueKind = vkString then av[0].AsInteger := Length(av[1].AsString);
end;
{ @end $46D3EC }

{ @routine $46D488 EF_Copy }
procedure EF_Copy(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1 - 1;
  if Count < 2 then Exit;
  av[1].ResetKind(av[2].ValueKind);
  av[1].Assume(av[2], True);
end;
{ @end $46D488 }

{ @routine $46D4D8 EF_Abs }
procedure EF_Abs(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  if av[1].ValueKind = vkInt then av[0].AsInteger := Abs(av[1].AsInteger)
  else av[0].AsFloat := Abs(av[1].AsFloat);
end;
{ @end $46D4D8 }

{ @routine $46D53C EF_ArcTan }
procedure EF_ArcTan(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsFloat := ArcTan(av[1].AsFloat);
end;
{ @end $46D53C }

{ @routine $46D588 EF_Exp }
procedure EF_Exp(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsFloat := Exp(av[1].AsFloat);
end;
{ @end $46D588 }

{ @routine $46D5D4 EF_Ln }
procedure EF_Ln(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsFloat := Ln(av[1].AsFloat);
end;
{ @end $46D5D4 }

{ @routine $46D620 EF_Round }
procedure EF_Round(av: array of TVarEC; code: TCodeEC);
var
  Count, Step: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  if Count >= 3 then Step := av[2].AsInteger else Step := 1;
  if av[1].ValueKind = vkFloat then av[0].AsInteger := Integer(Round(av[1].AsFloat / Step)) * Step
  else av[0].AsInteger := Integer(Round(av[1].AsInteger / Step)) * Step;
end;
{ @end $46D620 }

{ @routine $46D6BC EF_Sin }
procedure EF_Sin(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsFloat := Sin(av[1].AsFloat);
end;
{ @end $46D6BC }

{ @routine $46D708 EF_Cos }
procedure EF_Cos(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsFloat := Cos(av[1].AsFloat);
end;
{ @end $46D708 }

{ @routine $46D754 EF_Sqr }
procedure EF_Sqr(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  if av[1].ValueKind = vkInt then av[0].AsInteger := av[1].AsInteger * av[1].AsInteger
  else av[0].AsFloat := Sqr(av[1].AsFloat);
end;
{ @end $46D754 }

{ @routine $46D7C4 EF_Sqrt }
procedure EF_Sqrt(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsFloat := Sqrt(av[1].AsFloat);
end;
{ @end $46D7C4 }

{ @routine $46D810 EF_Frac }
procedure EF_Frac(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsFloat := Frac(av[1].AsFloat);
end;
{ @end $46D810 }

{ @routine $46D85C EF_Int }
procedure EF_Int(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsInteger := Trunc(av[1].AsFloat);
end;
{ @end $46D85C }

{ @routine $46D89C EF_Ord }
procedure EF_Ord(av: array of TVarEC; code: TCodeEC);
var
  Text: WideString;
begin
  if High(av) < 1 then Exit;
  Text := av[1].AsString;
  if Length(Text) > 0 then av[0].AsInteger := Ord(Text[1]);
end;
{ @end $46D89C }

{ @routine $46D914 EF_Rnd }
procedure EF_Rnd(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsInteger := Random(av[1].AsInteger);
end;
{ @end $46D914 }

{ @routine $46D954 EF_Randomize }
procedure EF_Randomize(av: array of TVarEC; code: TCodeEC);
begin
  Randomize;
end;
{ @end $46D954 }

{ @routine $46D978 EF_RandSeed }
procedure EF_RandSeed(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 1 then Exit;
  av[0].AsInteger := RandSeed;
  if Count >= 2 then RandSeed := av[1].AsInteger;
end;
{ @end $46D978 }

{ @routine $46D9C4 EF_SubStr }
procedure EF_SubStr(av: array of TVarEC; code: TCodeEC);
var
  Count, Start, Size, TextLength: Integer;
begin
  Count := High(av) + 1;
  if Count < 3 then Exit;
  TextLength := Length(av[1].AsString);
  Start := av[2].AsInteger;
  if Count >= 4 then Size := av[3].AsInteger else Size := 1999999999;
  if (Start < 0) or (Start >= TextLength) then
  begin
    av[0].AsString := '';
    Exit;
  end;
  if Start + Size > TextLength then Size := TextLength - Start;
  av[0].AsString := Copy(av[1].AsString, Start + 1, Size);
end;
{ @end $46D9C4 }

{ @routine $46DAA8 EF_FindSubStr }
procedure EF_FindSubStr(av: array of TVarEC; code: TCodeEC);
var
  Start, TextLength, SearchLength: Integer;
  Text, Search: WideString;
begin
  if High(av) < 2 then Exit;
  Text := av[1].AsString;
  Search := av[2].AsString;
  Start := 0;
  if High(av) >= 3 then Start := av[3].AsInteger;
  TextLength := Length(Text);
  SearchLength := Length(Search);
  if TextLength - Start < SearchLength then
  begin
    av[0].AsInteger := -1;
    Exit;
  end;
  if (TextLength < 1) and (SearchLength < 1) then
  begin
    av[0].AsInteger := -1;
    Exit;
  end;
  while Start <= TextLength - SearchLength do
  begin
    if CompareMem(Pointer(PAnsiChar(Text) + Start * SizeOf(WideChar)), PWideChar(Search), SearchLength * 2) then
    begin
      av[0].AsInteger := Start;
      Exit;
    end;
    Inc(Start);
  end;
  av[0].AsInteger := -1;
end;
{ @end $46DAA8 }

{ @routine $46DBC4 EF_Trim }
procedure EF_Trim(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsString := TrimScriptString(av[1].AsString);
end;
{ @end $46DBC4 }

{ @routine $46DC40 EF_ToAnsi }
procedure EF_ToAnsi(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsString := av[1].AsString;
  av[0].PackAnsiString;
end;
{ @end $46DC40 }

{ @routine $46DCB4 EF_ToUnicode }
procedure EF_ToUnicode(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  Count := High(av) + 1;
  if Count < 2 then Exit;
  av[0].AsString := av[1].AsString;
  av[0].UnpackAnsiString;
end;
{ @end $46DCB4 }

{ @routine $46DD28 EF_LowerCase }
procedure EF_LowerCase(av: array of TVarEC; code: TCodeEC);
var
  Text: WideString;
  AnsiText: AnsiString;
  Start, Count: Integer;
begin
  if High(av) < 1 then Exit;
  Text := av[1].AsString;
  Start := 0;
  if High(av) >= 2 then Start := av[2].AsInteger;
  if High(av) >= 3 then Count := av[3].AsInteger else Count := Length(Text) - Start;
  if (Start < 0) or (Start + Count > Length(Text)) or (Count < 1) then
  begin
    av[0].AsString := Text;
    Exit;
  end;
  if GetVersion < $80000000 then
  begin
    CharLowerBuffW(PWideChar(Text) + Start, Count);
    av[0].AsString := Text;
  end
  else
  begin
    AnsiText := Text;
    CharLowerBuffA(PAnsiChar(Cardinal(PAnsiChar(AnsiText)) + Cardinal(Start)), Count);
    av[0].AsString := AnsiText;
  end;
end;
{ @end $46DD28 }

{ @routine $46DE54 EF_UpperCase }
procedure EF_UpperCase(av: array of TVarEC; code: TCodeEC);
var
  Text: WideString;
  AnsiText: AnsiString;
  Start, Count: Integer;
begin
  if High(av) < 1 then Exit;
  Text := av[1].AsString;
  Start := 0;
  if High(av) >= 2 then Start := av[2].AsInteger;
  if High(av) >= 3 then Count := av[3].AsInteger else Count := Length(Text) - Start;
  if (Start < 0) or (Start + Count > Length(Text)) or (Count < 1) then
  begin
    av[0].AsString := Text;
    Exit;
  end;
  if GetVersion < $80000000 then
  begin
    CharUpperBuffW(PWideChar(Text) + Start, Count);
    av[0].AsString := Text;
  end
  else
  begin
    AnsiText := Text;
    // Native ANSI fallback lowercases even for UpperCase.
    CharLowerBuffA(PAnsiChar(Cardinal(PAnsiChar(AnsiText)) + Cardinal(Start)), Count);
    av[0].AsString := AnsiText;
  end;
end;
{ @end $46DE54 }

{ @routine $46DF80 EF_LoadLibrary }
procedure EF_LoadLibrary(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then Exit;
  av[0].AsDword := LoadLibraryW(PWideChar(av[1].AsString));
end;
{ @end $46DF80 }

{ @routine $46DFF4 EF_FreeLibrary }
procedure EF_FreeLibrary(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then Exit;
  av[0].AsInteger := Integer(FreeLibrary(av[1].AsDword));
end;
{ @end $46DFF4 }

{ @routine $46E030 TVarEC_SetLibrarySignature }
procedure TVarEC.SetLibrarySignature(Signature: array of Dword);
var
  i, Last: Integer;
begin
  Last := High(Signature);
  SetLength(LibraryFunData, Last + 1);
  for i := 0 to Last do LibraryFunData[i] := Signature[i];
end;
{ @end $46E030 }

{ @routine $46E090 EF_LibraryFunction }
procedure EF_LibraryFunction(av: array of TVarEC; code: TCodeEC);
var
  i: Integer;
  Proc: Pointer;
  KindName: WideString;
begin
  if High(av) < 3 then Exit;
  Proc := GetProcAddress(av[1].AsDword, PAnsiChar(AnsiString(av[3].AsString)));
  if Proc = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  av[0].ConvertToKind(vkLibraryFun);
  SetLength(av[0].LibraryFunData, 2 + High(av) - 3);
  if av[2].AsString = 'int' then av[0].LibraryFunData[0] := 1
  else if av[2].AsString = 'dword' then av[0].LibraryFunData[0] := 2
  else if av[2].AsString = 'float' then av[0].LibraryFunData[0] := 3
  else if av[2].AsString = 'str' then av[0].LibraryFunData[0] := 4
  else av[0].LibraryFunData[0] := 0;
  av[0].LibraryFunData[1] := Dword(Proc);
  for i := 0 to High(av) - 3 - 1 do
  begin
    KindName := av[4 + i].AsString;
    if KindName = 'int' then av[0].LibraryFunData[2 + i] := 1
    else if KindName = 'dword' then av[0].LibraryFunData[2 + i] := 2
    else if KindName = 'float' then av[0].LibraryFunData[2 + i] := 3
    else if KindName = 'str' then av[0].LibraryFunData[2 + i] := 4
    else if KindName = 'ref' then av[0].LibraryFunData[2 + i] := 5
    else if KindName = 'code' then av[0].LibraryFunData[2 + i] := 6
    else raise ExceptionExpressionEC.Create('LibraryFunction. Unknown type');
  end;
end;
{ @end $46E090 }

{ @routine $46E3A0 EF_New }
procedure EF_New(av: array of TVarEC; code: TCodeEC);
var
  Found: TVarEC;
  Definition, Instance: TCodeEC;
begin
  if High(av) <> 1 then Exit;
  if code = nil then Exit;
  while (code <> nil) and (code.Parent <> nil) do code := code.Parent;
  Found := code.LocalVar.NamedItems[av[1].AsString];
  if Found.ValueKind = vkFunction then
  begin
    Definition := Found.AsFunction;
    if not Definition.IsClassDefinition then Exit;
    Instance := TCodeEC.Create;
    Instance.CopyFromFast(Definition);
    Instance.LinkLocalScopes;
    av[0].AsClass := Instance;
  end;
end;
{ @end $46E3A0 }

{ @routine $46E464 EF_Delete }
procedure EF_Delete(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then Exit;
  if av[1].ValueKind = vkClass then
  begin
    av[1].AsClass.Free;
    av[1].ResetKind(vkEmpty);
  end;
end;
{ @end $46E464 }

{ @routine $46E4AC RegisterExpressionBuiltins }
procedure RegisterExpressionBuiltins(Scope: TVarArrayEC);
begin
  Scope.Add('pi', vkFloat).AsFloat := Pi;
  Scope.Add('min', vkExternFun).AsExternFun := @EF_Min;
  Scope.Add('max', vkExternFun).AsExternFun := @EF_Max;
  Scope.Add('newarray', vkExternFun).AsExternFun := @EF_NewArray;
  Scope.Add('arraychange', vkExternFun).AsExternFun := @EF_ArrayChange;
  Scope.Add('free', vkExternFun).AsExternFun := @EF_Free;
  Scope.Add('count', vkExternFun).AsExternFun := @EF_Count;
  Scope.Add('copy', vkExternFun).AsExternFun := @EF_Copy;
  Scope.Add('abs', vkExternFun).AsExternFun := @EF_Abs;
  Scope.Add('arctan', vkExternFun).AsExternFun := @EF_ArcTan;
  Scope.Add('exp', vkExternFun).AsExternFun := @EF_Exp;
  Scope.Add('ln', vkExternFun).AsExternFun := @EF_Ln;
  Scope.Add('round', vkExternFun).AsExternFun := @EF_Round;
  Scope.Add('sin', vkExternFun).AsExternFun := @EF_Sin;
  Scope.Add('cos', vkExternFun).AsExternFun := @EF_Cos;
  Scope.Add('sqr', vkExternFun).AsExternFun := @EF_Sqr;
  Scope.Add('sqrt', vkExternFun).AsExternFun := @EF_Sqrt;
  Scope.Add('frac', vkExternFun).AsExternFun := @EF_Frac;
  Scope.Add('int', vkExternFun).AsExternFun := @EF_Int;
  Scope.Add('ord', vkExternFun).AsExternFun := @EF_Ord;
  Scope.Add('rnd', vkExternFun).AsExternFun := @EF_Rnd;
  Scope.Add('randomize', vkExternFun).AsExternFun := @EF_Randomize;
  Scope.Add('randseed', vkExternFun).AsExternFun := @EF_RandSeed;
  Scope.Add('substr', vkExternFun).AsExternFun := @EF_SubStr;
  Scope.Add('findsubstr', vkExternFun).AsExternFun := @EF_FindSubStr;
  Scope.Add('trim', vkExternFun).AsExternFun := @EF_Trim;
  Scope.Add('toansi', vkExternFun).AsExternFun := @EF_ToAnsi;
  Scope.Add('tounicode', vkExternFun).AsExternFun := @EF_ToUnicode;
  Scope.Add('lowercase', vkExternFun).AsExternFun := @EF_LowerCase;
  Scope.Add('uppercase', vkExternFun).AsExternFun := @EF_UpperCase;
  Scope.Add('loadlibrary', vkExternFun).AsExternFun := @EF_LoadLibrary;
  Scope.Add('freelibrary', vkExternFun).AsExternFun := @EF_FreeLibrary;
  Scope.Add('libraryfunction', vkExternFun).AsExternFun := @EF_LibraryFunction;
  Scope.Add('new', vkExternFun).AsExternFun := @EF_New;
  Scope.Add('delete', vkExternFun).AsExternFun := @EF_Delete;
end;
{ @end $46E4AC }

end.
