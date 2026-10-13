unit Classes;

interface

uses System, SysUtils, Types;

type
  TNotifyEvent = procedure(Sender: TObject) of object;
  TPersistent = class(TObject) // @size 0x04
  public
    procedure AssignError(Source: TPersistent);
    function GetNamePath: AnsiString;
  end;
  TInterfacedPersistent = class(TPersistent) // @size 0x0C
  public
    OwnerInterface: IInterface; // @offset 0x04
  public
    procedure AfterConstruction;
    function _AddRef: Integer; // @nameonly
    function _Release: Integer; // @nameonly
  end;

  TSeekOrigin = (soBeginning = 0, soCurrent = 1, soEnd = 2); // @size 0x01

  TStream = class(TObject) // @size 0x04
  public
    function GetPosition: Int64;
    procedure SetPosition(Position: Int64); // @ida "void __userpurge $name(TStream *Self@<eax>, __int64 Position);"
    function GetSize: Int64; virtual; // @slot 0x00 @note "Seeks to the end and restores the original position."
    procedure SetSize32(NewSize: Integer); virtual; // @addr 0x00418264 @slot 0x04 @note "The base implementation does nothing."
    procedure SetSize(NewSize: Int64); virtual; // @slot 0x08 @ida "void __userpurge $name(TStream *Self@<eax>, __int64 NewSize);" @note "Requires a signed 32-bit size and dispatches to SetSize32."
    procedure SetSize64(NewSize: Int64); // @ida "void __userpurge $name(TStream *Self@<eax>, __int64 NewSize);"
    function Seek32(Offset: Integer; Origin: Word): Integer; virtual; // @slot 0x14 @note "Delegates to an overridden Seek; raises when neither seek overload is implemented."
    function Seek(Offset: Int64; Origin: TSeekOrigin): Int64; virtual; // @slot 0x18 @note "The base implementation requires a signed 32-bit offset and dispatches to Seek32."
    procedure ReadBuffer(Buffer: Pointer; Count: Integer); // @note "Raises on a short read; zero count does nothing."
    procedure WriteBuffer(Buffer: Pointer; Count: Integer); // @note "Raises on a short write; zero count does nothing."
    function CopyFrom(Source: TStream; Count: Int64): Int64; // @ida "__int64 __userpurge $name@<edx:eax>(TStream *Self@<eax>, TStream *Source@<edx>, __int64 Count);" @note "Count=0 rewinds Source and copies its entire contents. Positive counts copy from its current position."
  public
    function ReadComponent(Instance: TComponent): TComponent;
  end;

  TCustomMemoryStream = class(TStream) // @size 0x10
  public
    Memory: Pointer; // @offset 0x04
    Size: Integer; // @offset 0x08
    Position: Integer; // @offset 0x0C

    procedure SetPointer(Buffer: Pointer; BufferSize: Integer); // @addr 0x00418884 @note "Borrows Buffer without freeing previous storage or changing Position."
    function Read(Buffer: Pointer; Count: Integer): Integer; virtual; // @slot 0x0C @note "Returns bytes read; negative counts or positions read nothing."
    function Seek32(Offset: Integer; Origin: Word): Integer; override; // @slot 0x14 @note "Does not clamp the resulting position to the buffer."
  end;

  TMemoryStream = class(TCustomMemoryStream) // @size 0x14
  public
    Capacity: Integer; // @offset 0x10

    destructor Destroy; override; // @addr 0x004188E8
    procedure Clear;
    procedure LoadFromStream(Source: TStream); // @note "Rewinds Source and replaces the entire payload."
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetSize32(NewSize: Integer); override; // @slot 0x04 @note "Clamps Position when shrinking; newly allocated bytes are not initialized."
    function Write(Buffer: Pointer; Count: Integer): Integer; virtual; // @slot 0x10 @note "Extends the stream; gaps before Position are not initialized."
    function Realloc(var NewCapacity: Integer): Pointer; virtual; // @slot 0x1C @note "May round NewCapacity up to an 8 KiB boundary."
  end;

  EListError = class(Exception) // @size 0x0C
  end;

  TPointerList = array[0..65535] of Pointer; // Indexing view; allocated storage is governed by TList.Capacity.
  PPointerList = ^TPointerList;

  TList = class(TObject) // @size 0x10
  public
    List: PPointerList; // @offset 0x04
    Count: Integer; // @offset 0x08
    Capacity: Integer; // @offset 0x0C

    destructor Destroy; override;
    procedure Grow; virtual; // @slot 0x00
    procedure Notify(Item: Pointer; Action: Byte); virtual; // @addr 0x0041657C @slot 0x04 @note "Action 0 denotes addition, 2 deletion; the base implementation is empty."
    procedure Clear; virtual; // @addr 0x004161F4 @slot 0x08 @note "The base list does not own item pointers."
    class procedure Error(Message: AnsiString; Data: Integer); virtual; // @addr 0x0041626C @slot 0x0C @note "Raises EListError."
    function Add(Item: Pointer): Integer;
    procedure Delete(Index: Integer);
    function Get(Index: Integer): Pointer;
    function IndexOf(Item: Pointer): Integer; // @note "Returns -1 when absent."
    procedure Insert(Index: Integer; Item: Pointer);
    procedure Exchange(Index1, Index2: Integer); // @addr 0x004162F8
    function Expand: TList; // @note "Grows capacity only when full; returns Self."
    function First: Pointer; // @addr 0x00416360 @note "Raises when empty."
    function Last: Pointer; // @addr 0x00416450 @note "Raises when empty."
    procedure Put(Index: Integer; Item: Pointer);
    property Items[Index: Integer]: Pointer read Get write Put; default;
    function Remove(Item: Pointer): Integer; // @note "Removes the first match and returns its previous index, or -1 when absent."
    procedure SetCapacity(NewCapacity: Integer); // @note "Must be at least Count and no greater than 0x07FFFFFF."
    procedure SetCount(NewCount: Integer); // @note "New entries are zeroed."
  public
    procedure Error_4162A4; // @nameonly
  end;

function ClassesPoint(X, Y: Integer): TPoint;
function ClassesRect(Left, Top, Right, Bottom: Integer): TRect;

type
  TRegGroup = class(TObject) // @size 0x14
  public
    function BestClass(AClass: TPersistentClass): TPersistentClass;
    class function BestGroup(Group1, Group2: TRegGroup; AClass: TPersistentClass): TRegGroup;
    constructor Create(AClass: TPersistentClass);
    destructor Destroy;
    function GetClass(const AClassName: AnsiString): TPersistentClass;
    function InGroup(AClass: TPersistentClass): Boolean;
    procedure RegisterClass(AClass: TPersistentClass);
    function Registered(AClass: TPersistentClass): Boolean;
    procedure UnregisterModuleClasses(Module: Cardinal);
  end;

  TPersistentClass = class of TPersistent;

  TRegGroups = class(TObject) // @size 0x24
  public
    procedure Activate(AClass: TPersistentClass);
    constructor Create;
    destructor Destroy;
    function FindGroup(AClass: TPersistentClass): TRegGroup;
    function GetClass(const AClassName: AnsiString): TPersistentClass;
    procedure GroupWith(AClass, AGroupClass: TPersistentClass);
    function Registered(AClass: TPersistentClass): Boolean;
    procedure StartGroup(AClass: TPersistentClass);
    procedure UnregisterModuleClasses(Module: Cardinal);
  end;

  TClassFinder = class(TObject) // @size 0x8
  public
    constructor Create(AClass: TPersistentClass; AIncludeActiveGroups: Boolean);
    function GetClass(const AClassName: AnsiString): TPersistentClass;
  end;

  TIntConst = class(TObject) // @size 0x10
  public
    procedure Create; // @nameonly
  end;

  TIdentMapEntry = record;

  TComponent = class(TPersistent) // @size 0x30
  public
    procedure DefineProperties(Filer: TFiler); virtual; // @slot 0x4
    destructor Destroy;
    procedure FreeNotification(AComponent: TComponent);
    procedure ReadLeft(Reader: TReader);
    procedure ReadTop(Reader: TReader);
    procedure Insert(AComponent: TComponent);
    procedure Remove(AComponent: TComponent);
    procedure InsertComponent(AComponent: TComponent);
    procedure RemoveComponent(AComponent: TComponent);
    procedure DestroyComponents;
    procedure Destroying;
    procedure RemoveNotification(AComponent: TComponent);
    procedure RemoveFreeNotification(AComponent: TComponent);
    procedure Notification(AComponent: TComponent; Operation: TOperation); virtual; // @slot 0x10
    procedure SetName(const NewName: TComponentName); virtual; // @slot 0x18
    procedure ValidateRename(AComponent: TComponent; const CurName, NewName: AnsiString); virtual; // @slot 0x20
    function FindComponent(const AName: AnsiString): TComponent;
    constructor Create(AOwner: TComponent); virtual; // @slot 0x2C
    function GetComponent(AIndex: Integer): TComponent;
    procedure SetComponentIndex(Value: Integer);
    procedure SetDesigning(Value, SetChildren: Boolean);
    procedure SetReference(Enable: Boolean);
    function ExecuteAction(Action: TBasicAction): Boolean;
    function UpdateAction(Action: TBasicAction): Boolean;
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult;
    function QueryInterface(const IID: TGUID; Obj: Pointer): HResult; // @nameonly
  end;

  TThreadList = class(TObject) // @size 0x24
  public
    constructor Create;
    destructor Destroy;
    procedure Add(Item: Pointer);
    procedure Remove(Item: Pointer);
  end;

  TBits = class(TObject) // @size 0xC
  public
    procedure SetSize(Value: Integer);
    procedure SetBit(Index: Integer; Value: Boolean);
    function OpenBit: Integer;
  end;

  TCollection = class(TPersistent) // @partial
  public
    function Add: TCollectionItem;
    procedure Clear;
  end;

  TCollectionItem = class(TPersistent) // @partial
  end;

  TStrings = class(TPersistent) // @size 0x18
  public
    procedure DefineProperties(Filer: TFiler); virtual; // @slot 0x4
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    function GetTextStr: AnsiString; virtual; // @slot 0x1C
    procedure Put(Index: Integer; const S: AnsiString); virtual; // @slot 0x20
    procedure BeginUpdate;
    procedure SetTextStr(const Value: AnsiString); virtual; // @slot 0x2C
    procedure EndUpdate;
    function Equals(Strings: TStrings): Boolean;
    procedure Error; // @nameonly
    function CompareStrings(const S1, S2: AnsiString): Integer; virtual; // @slot 0x34
    function Add(const S: AnsiString): Integer; virtual; // @slot 0x38
    function AddObject(const S: AnsiString; AObject: TObject): Integer; virtual; // @slot 0x3C
    procedure AddStrings(Strings: TStrings); virtual; // @slot 0x40
    procedure Exchange(Index1, Index2: Integer); virtual; // @slot 0x4C
    function GetText: PAnsiChar; virtual; // @slot 0x50
    function IndexOf(const S: AnsiString): Integer; virtual; // @slot 0x54
    function IndexOfName(const Name: AnsiString): Integer; virtual; // @slot 0x58
    function IndexOfObject(AObject: TObject): Integer; virtual; // @slot 0x5C
    procedure InsertObject(Index: Integer; const S: AnsiString; AObject: TObject); virtual; // @slot 0x64
    procedure LoadFromFile(const FileName: AnsiString); virtual; // @slot 0x68
    procedure ReadData(Reader: TReader);
    procedure LoadFromStream(Stream: TStream); virtual; // @slot 0x6C
    procedure Move(CurIndex, NewIndex: Integer); virtual; // @slot 0x70
    procedure SetStringsAdapter(const Value: IStringsAdapter);
    procedure SaveToFile(const FileName: AnsiString); virtual; // @slot 0x74
    procedure SaveToStream(Stream: TStream); virtual; // @slot 0x78
    procedure WriteData(Writer: TWriter);
    function GetLineBreak: AnsiString;
    procedure SetLineBreak(const Value: AnsiString);
    procedure SetText(Text: PAnsiChar); virtual; // @slot 0x7C
    function GetNameValueSeparator: Char;
    procedure SetNameValueSeparator(const Value: Char);
  end;

  TFiler = class(TObject) // @size 0x28
  public
    constructor Create(Stream: TStream; BufSize: Integer);
    destructor Destroy;
  end;

  TReader = class(TFiler) // @size 0x8C
  public
    destructor Destroy;
    procedure CheckValue(Value: TValueType);
    procedure DefineProperty; // @nameonly
    procedure DefineBinaryProperty; // @nameonly
    function EndOfList: Boolean;
    procedure FlushBuffer; virtual; // @slot 0xC
    function Error(const Message: AnsiString): Boolean; virtual; // @slot 0x10
    function FindAncestorComponent(const Name: AnsiString; ComponentClass: TPersistentClass): TComponent; virtual; // @slot 0x14
    procedure DoFixupReferences;
    function FindMethodInstance(Root: TComponent; const MethodName: AnsiString): TMethod; virtual; // @ida "void __userpurge $name(TReader *Self@<eax>, TComponent *Root@<edx>, char * MethodName@<ecx>, TMethod *Result@<^0>);" @slot 0x18
    procedure FreeFixups;
    function GetFieldClass(Instance: TObject; const ClassName: AnsiString): TPersistentClass;
    function GetPosition: Longint;
    procedure Read(Buf: Pointer; Count: Longint);
    procedure ReadBuffer;
    function ReadChar: Char;
    function ReadWideChar: WideChar;
    procedure ReadCollection(Collection: TCollection);
    function ReadComponent(Component: TComponent): TComponent;
    procedure ReadData(Instance: TComponent);
    procedure ReadDataInner(Instance: TComponent);
    function ReadFloat: Extended; // @nameonly
    function ReadDouble: Double;
    function ReadSingle: Single;
    procedure ReadCurrency; // @nameonly
    function ReadDate: TDateTime;
    function ReadIdent: AnsiString;
    function ReadInteger: Longint;
    function ReadInt64: Int64;
    function FindMethod(Root: TComponent; const MethodName: AnsiString): Pointer; virtual; // @slot 0x1C
    procedure ReadProperty(AInstance: TPersistent);
    procedure ReadPropValue(Instance: TPersistent; PropInfo: Pointer);
    function ReadRootComponent(Root: TComponent): TComponent;
    function ReadSet(SetType: Pointer): Integer;
    procedure ReadSignature;
    function ReadStr: AnsiString;
    function ReadString: AnsiString;
    function ReadWideString: WideString;
    procedure SkipSetBody;
    procedure SkipValue;
    procedure SkipProperty;
    procedure SkipComponent(SkipHeader: Boolean);
    procedure SetName(Component: TComponent; var Name: AnsiString); virtual; // @slot 0x20
    procedure ReferenceName(var Name: AnsiString); virtual; // @slot 0x24
    procedure ReadPrefix(var Flags: TFilerFlags; var AChildPos: Integer); virtual; // @slot 0x28
    function FindComponentClass(const ClassName: AnsiString): TComponentClass;
    procedure SkipBytes(Count: Integer);
    procedure ReadVariant; // @nameonly
  end;

  IStringsAdapter = interface;

  TWriter = class(TFiler) // @partial
  public
    procedure Write(Buf: Pointer; Count: Longint);
    procedure WriteBuffer;
    procedure WriteInteger; // @nameonly
    procedure WriteMinStr(const LocaleStr: AnsiString; const UTF8Str: AnsiString);
    procedure WriteString(const Value: AnsiString);
  end;

  TStringList = class(TStrings) // @size 0x38
  public
    destructor Destroy;
    function Add(const S: AnsiString): Integer; override; // @slot 0x38
    function AddObject(const S: AnsiString; AObject: TObject): Integer; override; // @slot 0x3C
    function Get(Index: Integer): AnsiString; virtual; // @slot 0xC
    function GetObject(Index: Integer): TObject; virtual; // @slot 0x18
    procedure PutObject(Index: Integer; AObject: TObject); virtual; // @slot 0x24
    procedure SetCapacity(NewCapacity: Integer); virtual; // @slot 0x28
    procedure Exchange(Index1, Index2: Integer); override; // @slot 0x4C
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure Clear; virtual; // @slot 0x44
    procedure Delete(Index: Integer); virtual; // @slot 0x48
    procedure Insert(Index: Integer; const S: AnsiString); virtual; // @slot 0x60
    procedure Grow;
    function IndexOf(const S: AnsiString): Integer; override; // @slot 0x54
    procedure Changed; virtual; // @slot 0x80
    procedure InsertObject(Index: Integer; const S: AnsiString; AObject: TObject); override; // @slot 0x64
    procedure Changing; virtual; // @slot 0x84
    procedure Put(Index: Integer; const S: AnsiString); override; // @slot 0x20
    procedure InsertItem(Index: Integer; const S: AnsiString; AObject: TObject); virtual; // @slot 0x88
    procedure QuickSort; // @nameonly
    function Find(const S: AnsiString; var Index: Integer): Boolean; virtual; // @slot 0x8C
    procedure SetSorted(Value: Boolean);
    procedure CustomSort; // @nameonly
    function CompareStrings(const S1, S2: AnsiString): Integer; override; // @slot 0x34
  end;

  THandleStream = class(TStream) // @size 0x8
  public
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; // @nameonly
    procedure SetSize; // @nameonly
    procedure SetSize_418670; // @nameonly
  end;

  TFileStream = class(THandleStream) // @size 0xC
  public
    procedure Create; // @nameonly
    procedure Create_4186DC; // @nameonly
    destructor Destroy;
  end;

  TResourceStream = class(TCustomMemoryStream) // @size 0x18
  public
    constructor Create(Instance: Cardinal; const ResName: AnsiString; ResType: PAnsiChar);
    procedure Initialize(Instance: Cardinal; Name, ResType: PAnsiChar; FromID: Boolean);
    destructor Destroy;
  end;

  TPropFixup = class(TObject) // @size 0x18
  public
    constructor Create(Instance: TPersistent; InstanceRoot: TComponent; PropInfo: PPropInfo; const RootName, Name: AnsiString);
    function MakeGlobalReference: Boolean;
  end;

  TPropIntfFixup = class(TPropFixup) // @size 0x18
  public
    procedure ResolveReference(Reference: Pointer); virtual; // @slot 0x0
  end;

  TValueType = (vaNull, vaList, vaInt8, vaInt16, vaInt32, vaExtended, vaString, vaIdent, vaFalse, vaTrue, vaBinary, vaSet, vaLString, vaNil, vaCollection, vaSingle, vaCurrency, vaDate, vaWString, vaInt64, vaUTF8String, vaDouble); // @size 0x1

  TComponentStateElement = (csLoading, csReading, csWriting, csDestroying, csDesigning, csAncestor, csUpdating, csFixups, csFreeNotification, csInline, csDesignInstance); // @size 0x1

  TComponentState = set of TComponentStateElement; // @size 0x2

  TFilerFlag = (ffInherited, ffChildPos, ffInline); // @size 0x1

  TFilerFlags = set of TFilerFlag; // @size 0x1

  TComponentClass = class of TComponent;

  TOperation = (opInsert, opRemove); // @size 0x1

  TComponentName = AnsiString;

  TBasicAction = class(TComponent) // @size 0x54
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @slot 0x10
    function Execute: Boolean;
    function Update: Boolean; virtual; // @slot 0x44
    procedure SetOnExecute; // @nameonly
    procedure UnRegisterChanges(Value: TBasicActionLink);
    procedure SetActionComponent(const Value: TComponent);
  end;

  TBasicActionLink = class(TObject) // @size 0x14
  public
    procedure Change; virtual; // @slot 0x4
    destructor Destroy;
    procedure SetAction(Value: TBasicAction); virtual; // @slot 0xC
    constructor Create(AClient: TObject); virtual; // @slot 0x14
    function Execute(AComponent: TComponent): Boolean; virtual; // @slot 0x18
  end;

  TStreamAdapter = class(TInterfacedObject) // @size 0x18
  public
    constructor Create(Stream: TStream; Ownership: TStreamOwnership);
    destructor Destroy;
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult; // @nameonly
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult; // @nameonly
    function Seek(dlibMove: Int64; dwOrigin: Longint; out libNewPosition: Int64): HResult; // @nameonly
    function SetSize(libNewSize: Int64): HResult; // @nameonly
    procedure CopyTo; // @nameonly
    procedure Stat; // @nameonly
    procedure Clone; // @nameonly
  end;

  TStreamOwnership = (soReference, soOwned); // @size 0x1

  TShiftStateElement = (ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble); // @size 0x1

  TShiftState = set of TShiftStateElement; // @size 0x1

  TShortCut = Word;

  THelpContext = Integer;

  THelpType = (htKeyword, htContext); // @size 0x1

  TBiDiMode = (bdLeftToRight, bdRightToLeft, bdRightToLeftNoAlign, bdRightToLeftReadingOnly); // @size 0x1

function PointerInModule(Ptr: Pointer; Module: Cardinal): Boolean;

procedure Error; // @nameonly

procedure ClassNotFound(const ClassName: AnsiString);

procedure GetClass; // @nameonly

function FindClass(const ClassName: AnsiString): TPersistentClass;

procedure RegisterClass; // @nameonly

procedure GroupDescendentsWith(AClass, AClassGroup: TPersistentClass);

function ActivateClassGroup(AClass: TPersistentClass): TPersistentClass;

procedure RegisterIntegerConsts; // @nameonly

procedure FindIdentToInt; // @nameonly

function IdentToInt(const Ident: AnsiString; var Int: Longint; const Map: array of TIdentMapEntry): Boolean; // @nameonly

function IntToIdent(Int: Longint; var Ident: AnsiString; const Map: array of TIdentMapEntry): Boolean; // @nameonly

procedure RegisterFindGlobalComponentProc; // @nameonly

function FindGlobalComponent(const Name: AnsiString): TComponent;

function InternalReadComponentRes(const ResName: AnsiString; HInst: Cardinal; var Instance: TComponent): Boolean;

procedure BeginGlobalLoading;

procedure NotifyGlobalLoading;

procedure EndGlobalLoading;

function InitComponent(ClassType: TClass): Boolean; // @nameonly

function InitInheritedComponent(Instance: TComponent; RootAncestor: TClass): Boolean;

function DoWrite: Boolean; // @nameonly

function StringListCompareStrings(List: TStringList; Index1, Index2: Integer): Integer;

procedure RaiseException_4182D0; // @nameonly

procedure Error_418AE0; // @nameonly

function FindNestedComponent(Root: TComponent; const NamePath: AnsiString): TComponent;

procedure AddFinished(Instance: TPersistent); // @nameonly

procedure AddNotFinished(Instance: TPersistent); // @nameonly

procedure GlobalFixupReferences;

procedure RemoveFixupReferences(Root: TComponent; const RootName: AnsiString);

procedure RemoveFixups(Instance: TPersistent);

procedure RemoveGlobalFixup(Fixup: TPropFixup);

procedure AddSubComponentsToLoaded(Component: TComponent); // @nameonly

procedure CheckSubComponents(Component: TComponent); // @nameonly

procedure SetSubComponentState(State: TComponentState; Add: Boolean); // @nameonly

function ComponentCreated: Boolean; // @nameonly

function Recover(var Component: TComponent): Boolean; // @nameonly

procedure CreateComponent; // @nameonly

procedure SetCompName; // @nameonly

procedure FindExistingComponent; // @nameonly

procedure HandleException(E: Exception); // @nameonly

procedure SetIntIdent(Instance: TPersistent; PropInfo: Pointer; const Ident: AnsiString); // @nameonly

procedure SetObjectIdent(Instance: TPersistent; PropInfo: Pointer; const Ident: AnsiString); // @nameonly

procedure SetVariantReference; // @nameonly

procedure SetInterfaceReference; // @nameonly

function FindUniqueName(const Name: AnsiString): AnsiString; // @nameonly

procedure SkipList; // @nameonly

procedure SkipBinary(BytesPerUnit: Integer); // @nameonly

procedure SkipCollection; // @nameonly

procedure ReadCustomVariant; // @nameonly

procedure InitThreadSynchronization;

function CheckSynchronize(Timeout: Integer): Boolean;

procedure FreeIntConstList;

function StdWndProc(Window: Cardinal; Message, WParam: Longint; LParam: Longint): Longint; stdcall;

procedure MakeObjectInstance; // @nameonly

procedure AllocateHWnd; // @nameonly

procedure DeallocateHWnd(Wnd: Cardinal);

procedure FinalizeClasses; // @nameonly

implementation
end.
