unit Classes;
// Unit bracket (inferred): .text 0x00413860..0x0041D518; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008751F8..0x00875289; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses System, SysUtils, Types;

type
  TNotifyEvent = procedure(Sender: TObject) of object;
  TPersistent = class(TObject) // @size 0x04
  public
    procedure AssignError(Source: TPersistent); // @ida "void __usercall $name(TPersistent *Self@<eax>, TPersistent *Source@<edx>);" @note "DCC32 MAP Classes.TPersistent.AssignError. Source rtl/common/Classes.pas:3722."
    function GetNamePath: AnsiString; // @ida "void __usercall $name(TPersistent *Self@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Classes.TPersistent.GetNamePath. Source rtl/common/Classes.pas:3741."
  end;
  TInterfacedPersistent = class(TPersistent) // @size 0x0C
  public
    OwnerInterface: IInterface; // @offset 0x04
  public
    procedure AfterConstruction; // @ida "void __usercall $name(TInterfacedPersistent *Self@<eax>);" @note "DCC32 MAP Classes.TInterfacedPersistent.AfterConstruction. Source rtl/common/Classes.pas:3761."
    function _AddRef: Integer; // @nameonly @note "DCC32 MAP Classes.TInterfacedPersistent._AddRef. Source rtl/common/Classes.pas:3768. Prototype pending: RET mismatch: expected 0, native [4]."
    function _Release: Integer; // @nameonly @note "DCC32 MAP Classes.TInterfacedPersistent._Release. Source rtl/common/Classes.pas:3775. Prototype pending: RET mismatch: expected 0, native [4]."
  end;

  TSeekOrigin = (soBeginning = 0, soCurrent = 1, soEnd = 2); // @size 0x01

  TStream = class(TObject) // @size 0x04
  public
    function GetPosition: Int64; // @ida "__int64 __usercall $name@<edx:eax>(TStream *Self@<eax>);"
    procedure SetPosition(Position: Int64); // @ida "void __userpurge $name(TStream *Self@<eax>, __int64 Position);"
    function GetSize: Int64; virtual; // @slot 0x00 @ida "__int64 __usercall $name@<edx:eax>(TStream *Self@<eax>);" @note "Seeks to the end and restores the original position."
    procedure SetSize32(NewSize: Integer); virtual; // @addr 0x418264 @slot 0x04 @note "The base implementation does nothing."
    procedure SetSize(NewSize: Int64); virtual; // @slot 0x08 @ida "void __userpurge $name(TStream *Self@<eax>, __int64 NewSize);" @note "Requires a signed 32-bit size and dispatches to SetSize32."
    procedure SetSize64(NewSize: Int64); // @ida "void __userpurge $name(TStream *Self@<eax>, __int64 NewSize);"
    function Seek32(Offset: Integer; Origin: Word): Integer; virtual; // @slot 0x14 @note "Delegates to an overridden Seek; raises when neither seek overload is implemented."
    function Seek(Offset: Int64; Origin: TSeekOrigin): Int64; virtual; // @slot 0x18 @ida "__int64 __userpurge $name@<edx:eax>(TStream *Self@<eax>, __int64 Offset@<^0>, TSeekOrigin Origin@<dl>);" @note "The base implementation requires a signed 32-bit offset and dispatches to Seek32."
    procedure ReadBuffer(Buffer: Pointer; Count: Integer); // @note "Raises on a short read; zero count does nothing."
    procedure WriteBuffer(Buffer: Pointer; Count: Integer); // @note "Raises on a short write; zero count does nothing."
    function CopyFrom(Source: TStream; Count: Int64): Int64; // @ida "__int64 __userpurge $name@<edx:eax>(TStream *Self@<eax>, TStream *Source@<edx>, __int64 Count);" @note "Count=0 rewinds Source and copies its entire contents. Positive counts copy from its current position."
  public
    function ReadComponent(Instance: TComponent): TComponent; // @ida "TComponent * __usercall $name@<eax>(TStream *Self@<eax>, TComponent *Instance@<edx>);" @note "DCC32 MAP Classes.TStream.ReadComponent. Source rtl/common/Classes.pas:5335."
  end;

  TCustomMemoryStream = class(TStream) // @size 0x10
  public
    Memory: Pointer; // @offset 0x04
    Size: Integer; // @offset 0x08
    Position: Integer; // @offset 0x0C

    procedure SetPointer(Buffer: Pointer; BufferSize: Integer); // @addr 0x418884 @note "Borrows Buffer without freeing previous storage or changing Position."
    function Read(Buffer: Pointer; Count: Integer): Integer; virtual; // @slot 0x0C @note "Returns bytes read; negative counts or positions read nothing."
    function Seek32(Offset: Integer; Origin: Word): Integer; override; // @slot 0x14 @note "Does not clamp the resulting position to the buffer."
  end;

  TMemoryStream = class(TCustomMemoryStream) // @size 0x14
  public
    Capacity: Integer; // @offset 0x10

    destructor Destroy; override; // @addr 0x4188E8 @ida "void __usercall $name(TMemoryStream *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear;
    procedure LoadFromStream(Source: TStream); // @note "Rewinds Source and replaces the entire payload."
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetSize32(NewSize: Integer); override; // @slot 0x04 @note "Clamps Position when shrinking; newly allocated bytes are not initialized."
    function Realloc(var NewCapacity: Integer): Pointer; virtual; // @slot 0x1C @note "May round NewCapacity up to an 8 KiB boundary."
    function Write(Buffer: Pointer; Count: Integer): Integer; virtual; // @slot 0x10 @note "Extends the stream; gaps before Position are not initialized."
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

    destructor Destroy; override; // @ida "void __usercall $name(TList *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Grow; virtual; // @slot 0x00 @calls "0x4161D3 0x416357 0x416411"
    procedure Notify(Item: Pointer; Action: Byte); virtual; // @addr 0x41657C @slot 0x04 @calls "0x4161EA 0x416261 0x416449 0x416496 0x4164A5" @note "Action 0 denotes addition, 2 deletion; the base implementation is empty."
    procedure Clear; virtual; // @addr 0x4161F4 @slot 0x08 @calls "0x4161AF 0x87127F" @note "The base list does not own item pointers."
    class procedure Error(Message: AnsiString; Data: Integer); virtual; // @addr 0x41626C @slot 0x0C @note "Raises EListError."
    function Add(Item: Pointer): Integer;
    procedure Delete(Index: Integer);
    function Get(Index: Integer): Pointer;
    function IndexOf(Item: Pointer): Integer; // @note "Returns -1 when absent."
    procedure Insert(Index: Integer; Item: Pointer);
    procedure Exchange(Index1, Index2: Integer); // @addr 0x4162F8
    function Expand: TList; // @note "Grows capacity only when full; returns Self."
    function First: Pointer; // @addr 0x416360 @note "Raises when empty."
    function Last: Pointer; // @addr 0x416450 @note "Raises when empty."
    procedure Put(Index: Integer; Item: Pointer);
    property Items[Index: Integer]: Pointer read Get write Put; default;
    function Remove(Item: Pointer): Integer; // @note "Removes the first match and returns its previous index, or -1 when absent."
    procedure SetCapacity(NewCapacity: Integer); // @note "Must be at least Count and no greater than 0x07FFFFFF."
    procedure SetCount(NewCount: Integer); // @note "New entries are zeroed."
  public
    procedure Error_4162A4; // @nameonly @note "DCC32 MAP Classes.TList.Error. Prototype pending: no unique source declaration."
  end;

function ClassesPoint(X, Y: Integer): TPoint; // @ida "void __usercall $name(int X@<eax>, int Y@<edx>, TPoint *Result@<ecx>);"
function ClassesRect(Left, Top, Right, Bottom: Integer): TRect; // @ida "void __userpurge $name(int Left@<eax>, int Top@<edx>, int Right@<ecx>, int Bottom@<^4>, TRect *Result@<^0>);"

type
  TRegGroup = class(TObject) // @size 0x14
  public
    function BestClass(AClass: TPersistentClass): TPersistentClass; // @ida "TPersistentClass __usercall $name@<eax>(TRegGroup *Self@<eax>, TPersistentClass AClass@<edx>);" @note "DCC32 MAP Classes.TRegGroup.BestClass. Source rtl/common/Classes.pas:1850."
    class function BestGroup(Group1, Group2: TRegGroup; AClass: TPersistentClass): TRegGroup; // @ida "TRegGroup * __userpurge $name@<eax>(void *Self@<eax>, TRegGroup *Group1@<edx>, TRegGroup *Group2@<ecx>, TPersistentClass AClass@<^0>);" @note "DCC32 MAP Classes.TRegGroup.BestGroup. Source rtl/common/Classes.pas:1865."
    constructor Create(AClass: TPersistentClass); // @ida "TRegGroup * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TPersistentClass AClass@<ecx>);" @note "DCC32 MAP Classes.TRegGroup.Create. Source rtl/common/Classes.pas:1896."
    destructor Destroy; // @ida "void __usercall $name(TRegGroup *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TRegGroup.Destroy. Source rtl/common/Classes.pas:1903."
    function GetClass(const AClassName: AnsiString): TPersistentClass; // @ida "TPersistentClass __usercall $name@<eax>(TRegGroup *Self@<eax>, char * AClassName@<edx>);" @note "DCC32 MAP Classes.TRegGroup.GetClass. Source rtl/common/Classes.pas:1911."
    function InGroup(AClass: TPersistentClass): Boolean; // @ida "bool __usercall $name@<al>(TRegGroup *Self@<eax>, TPersistentClass AClass@<edx>);" @note "DCC32 MAP Classes.TRegGroup.InGroup. Source rtl/common/Classes.pas:1942."
    procedure RegisterClass(AClass: TPersistentClass); // @ida "void __usercall $name(TRegGroup *Self@<eax>, TPersistentClass AClass@<edx>);" @note "DCC32 MAP Classes.TRegGroup.RegisterClass. Source rtl/common/Classes.pas:1952."
    function Registered(AClass: TPersistentClass): Boolean; // @ida "bool __usercall $name@<al>(TRegGroup *Self@<eax>, TPersistentClass AClass@<edx>);" @note "DCC32 MAP Classes.TRegGroup.Registered. Source rtl/common/Classes.pas:1973."
    procedure UnregisterModuleClasses(Module: Cardinal); // @ida "void __usercall $name(TRegGroup *Self@<eax>, unsigned __int32 Module@<edx>);" @note "DCC32 MAP Classes.TRegGroup.UnregisterModuleClasses. Source rtl/common/Classes.pas:1998."
  end;

  TPersistentClass = class of TPersistent;

  TRegGroups = class(TObject) // @size 0x24
  public
    procedure Activate(AClass: TPersistentClass); // @ida "void __usercall $name(TRegGroups *Self@<eax>, TPersistentClass AClass@<edx>);" @note "DCC32 MAP Classes.TRegGroups.Activate. Source rtl/common/Classes.pas:2024."
    constructor Create; // @ida "TRegGroups * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);" @note "DCC32 MAP Classes.TRegGroups.Create. Source rtl/common/Classes.pas:2042."
    destructor Destroy; // @ida "void __usercall $name(TRegGroups *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TRegGroups.Destroy. Source rtl/common/Classes.pas:2055."
    function FindGroup(AClass: TPersistentClass): TRegGroup; // @ida "TRegGroup * __usercall $name@<eax>(TRegGroups *Self@<eax>, TPersistentClass AClass@<edx>);" @note "DCC32 MAP Classes.TRegGroups.FindGroup. Source rtl/common/Classes.pas:2067."
    function GetClass(const AClassName: AnsiString): TPersistentClass; // @ida "TPersistentClass __usercall $name@<eax>(TRegGroups *Self@<eax>, char * AClassName@<edx>);" @note "DCC32 MAP Classes.TRegGroups.GetClass. Source rtl/common/Classes.pas:2080."
    procedure GroupWith(AClass, AGroupClass: TPersistentClass); // @ida "void __usercall $name(TRegGroups *Self@<eax>, TPersistentClass AClass@<edx>, TPersistentClass AGroupClass@<ecx>);" @note "DCC32 MAP Classes.TRegGroups.GroupWith. Source rtl/common/Classes.pas:2103."
    function Registered(AClass: TPersistentClass): Boolean; // @ida "bool __usercall $name@<al>(TRegGroups *Self@<eax>, TPersistentClass AClass@<edx>);" @note "DCC32 MAP Classes.TRegGroups.Registered. Source rtl/common/Classes.pas:2174."
    procedure StartGroup(AClass: TPersistentClass); // @ida "void __usercall $name(TRegGroups *Self@<eax>, TPersistentClass AClass@<edx>);" @note "DCC32 MAP Classes.TRegGroups.StartGroup. Source rtl/common/Classes.pas:2184."
    procedure UnregisterModuleClasses(Module: Cardinal); // @ida "void __usercall $name(TRegGroups *Self@<eax>, unsigned __int32 Module@<edx>);" @note "DCC32 MAP Classes.TRegGroups.UnregisterModuleClasses. Source rtl/common/Classes.pas:2209."
  end;

  TClassFinder = class(TObject) // @size 0x8
  public
    constructor Create(AClass: TPersistentClass; AIncludeActiveGroups: Boolean); // @ida "TClassFinder * __userpurge $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TPersistentClass AClass@<ecx>, bool AIncludeActiveGroups@<^0>);" @note "DCC32 MAP Classes.TClassFinder.Create. Source rtl/common/Classes.pas:2228."
    function GetClass(const AClassName: AnsiString): TPersistentClass; // @ida "TPersistentClass __usercall $name@<eax>(TClassFinder *Self@<eax>, char * AClassName@<edx>);" @note "DCC32 MAP Classes.TClassFinder.GetClass. Source rtl/common/Classes.pas:2263."
  end;

  TIntConst = class(TObject) // @size 0x10
  public
    procedure Create; // @nameonly @note "DCC32 MAP Classes.TIntConst.Create. Source rtl/common/Classes.pas:2502. Prototype pending: unsupported source type TIdentToInt: function(const Ident: string; var Int: Longint): Boolean."
  end;

  TIdentMapEntry = record;

  TComponent = class(TPersistent) // @size 0x30
  public
    constructor Create(AOwner: TComponent); virtual; // @ida "TComponent * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TComponent *AOwner@<ecx>);" @note "DCC32 MAP Classes.TComponent.Create. Source rtl/common/Classes.pas:10351." @slot 0x2C
    destructor Destroy; // @ida "void __usercall $name(TComponent *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TComponent.Destroy. Source rtl/common/Classes.pas:10357."
    procedure FreeNotification(AComponent: TComponent); // @ida "void __usercall $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>);" @note "DCC32 MAP Classes.TComponent.FreeNotification. Source rtl/common/Classes.pas:10377."
    procedure ReadLeft(Reader: TReader); // @ida "void __usercall $name(TComponent *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Classes.TComponent.ReadLeft. Source rtl/common/Classes.pas:10393."
    procedure ReadTop(Reader: TReader); // @ida "void __usercall $name(TComponent *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Classes.TComponent.ReadTop. Source rtl/common/Classes.pas:10398."
    procedure Insert(AComponent: TComponent); // @ida "void __usercall $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>);" @note "DCC32 MAP Classes.TComponent.Insert. Source rtl/common/Classes.pas:10413."
    procedure Remove(AComponent: TComponent); // @ida "void __usercall $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>);" @note "DCC32 MAP Classes.TComponent.Remove. Source rtl/common/Classes.pas:10420."
    procedure InsertComponent(AComponent: TComponent); // @ida "void __usercall $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>);" @note "DCC32 MAP Classes.TComponent.InsertComponent. Source rtl/common/Classes.pas:10431."
    procedure RemoveComponent(AComponent: TComponent); // @ida "void __usercall $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>);" @note "DCC32 MAP Classes.TComponent.RemoveComponent. Source rtl/common/Classes.pas:10444."
    procedure DestroyComponents; // @ida "void __usercall $name(TComponent *Self@<eax>);" @note "DCC32 MAP Classes.TComponent.DestroyComponents. Source rtl/common/Classes.pas:10452."
    procedure Destroying; // @ida "void __usercall $name(TComponent *Self@<eax>);" @note "DCC32 MAP Classes.TComponent.Destroying. Source rtl/common/Classes.pas:10468."
    procedure RemoveNotification(AComponent: TComponent); // @ida "void __usercall $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>);" @note "DCC32 MAP Classes.TComponent.RemoveNotification. Source rtl/common/Classes.pas:10481."
    procedure RemoveFreeNotification(AComponent: TComponent); // @ida "void __usercall $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>);" @note "DCC32 MAP Classes.TComponent.RemoveFreeNotification. Source rtl/common/Classes.pas:10494."
    procedure Notification(AComponent: TComponent; Operation: TOperation); virtual; // @ida "void __usercall $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>, TOperation Operation@<cl>);" @note "DCC32 MAP Classes.TComponent.Notification. Source rtl/common/Classes.pas:10500." @slot 0x10
    procedure DefineProperties(Filer: TFiler); virtual; // @ida "void __usercall $name(TComponent *Self@<eax>, TFiler *Filer@<edx>);" @note "DCC32 MAP Classes.TComponent.DefineProperties. Source rtl/common/Classes.pas:10520." @slot 0x4
    procedure ValidateRename(AComponent: TComponent; const CurName, NewName: AnsiString); virtual; // @ida "void __userpurge $name(TComponent *Self@<eax>, TComponent *AComponent@<edx>, char * CurName@<ecx>, char * NewName@<^0>);" @note "DCC32 MAP Classes.TComponent.ValidateRename. Source rtl/common/Classes.pas:10611." @slot 0x20
    function FindComponent(const AName: AnsiString): TComponent; // @ida "TComponent * __usercall $name@<eax>(TComponent *Self@<eax>, char * AName@<edx>);" @note "DCC32 MAP Classes.TComponent.FindComponent. Source rtl/common/Classes.pas:10630."
    procedure SetName(const NewName: TComponentName); virtual; // @ida "void __usercall $name(TComponent *Self@<eax>, TComponentName NewName@<edx>);" @note "DCC32 MAP Classes.TComponent.SetName. Source rtl/common/Classes.pas:10643." @slot 0x18
    function GetComponent(AIndex: Integer): TComponent; // @ida "TComponent * __usercall $name@<eax>(TComponent *Self@<eax>, __int32 AIndex@<edx>);" @note "DCC32 MAP Classes.TComponent.GetComponent. Source rtl/common/Classes.pas:10670."
    procedure SetComponentIndex(Value: Integer); // @ida "void __usercall $name(TComponent *Self@<eax>, __int32 Value@<edx>);" @note "DCC32 MAP Classes.TComponent.SetComponentIndex. Source rtl/common/Classes.pas:10683."
    procedure SetDesigning(Value, SetChildren: Boolean); // @ida "void __usercall $name(TComponent *Self@<eax>, bool Value@<dl>, bool SetChildren@<cl>);" @note "DCC32 MAP Classes.TComponent.SetDesigning. Source rtl/common/Classes.pas:10715."
    procedure SetReference(Enable: Boolean); // @ida "void __usercall $name(TComponent *Self@<eax>, bool Enable@<dl>);" @note "DCC32 MAP Classes.TComponent.SetReference. Source rtl/common/Classes.pas:10740."
    function ExecuteAction(Action: TBasicAction): Boolean; // @ida "bool __usercall $name@<al>(TComponent *Self@<eax>, TBasicAction *Action@<edx>);" @note "DCC32 MAP Classes.TComponent.ExecuteAction. Source rtl/common/Classes.pas:10752."
    function UpdateAction(Action: TBasicAction): Boolean; // @ida "bool __usercall $name@<al>(TComponent *Self@<eax>, TBasicAction *Action@<edx>);" @note "DCC32 MAP Classes.TComponent.UpdateAction. Source rtl/common/Classes.pas:10759."
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; // @ida "HResult __usercall $name@<eax>(TComponent *Self@<eax>, TObject *ExceptObject@<edx>, void * ExceptAddr@<ecx>);" @note "DCC32 MAP Classes.TComponent.SafeCallException. Source rtl/common/Classes.pas:10786."
    function QueryInterface(const IID: TGUID; Obj: Pointer): HResult; // @nameonly @note "DCC32 MAP Classes.TComponent.QueryInterface. Source rtl/common/Classes.pas:10819. Prototype pending: RET mismatch: expected 0, native [12]."
  end;

  TThreadList = class(TObject) // @size 0x24
  public
    constructor Create; // @ida "TThreadList * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);" @note "DCC32 MAP Classes.TThreadList.Create. Source rtl/common/Classes.pas:3297."
    destructor Destroy; // @ida "void __usercall $name(TThreadList *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TThreadList.Destroy. Source rtl/common/Classes.pas:3305."
    procedure Add(Item: Pointer); // @ida "void __usercall $name(TThreadList *Self@<eax>, void * Item@<edx>);" @note "DCC32 MAP Classes.TThreadList.Add. Source rtl/common/Classes.pas:3317."
    procedure Remove(Item: Pointer); // @ida "void __usercall $name(TThreadList *Self@<eax>, void * Item@<edx>);" @note "DCC32 MAP Classes.TThreadList.Remove. Source rtl/common/Classes.pas:3347."
  end;

  TBits = class(TObject) // @size 0xC
  public
    procedure SetSize(Value: Integer); // @ida "void __usercall $name(TBits *Self@<eax>, __int32 Value@<edx>);" @note "DCC32 MAP Classes.TBits.SetSize. Source rtl/common/Classes.pas:3609."
    procedure SetBit(Index: Integer; Value: Boolean); // @ida "void __usercall $name(TBits *Self@<eax>, __int32 Index@<edx>, bool Value@<cl>);" @note "DCC32 MAP Classes.TBits.SetBit. Source rtl/common/Classes.pas:3647."
    function OpenBit: Integer; // @ida "__int32 __usercall $name@<eax>(TBits *Self@<eax>);" @note "DCC32 MAP Classes.TBits.OpenBit. Source rtl/common/Classes.pas:3684."
  end;

  TCollection = class(TPersistent) // @partial
  public
    function Add: TCollectionItem; // @ida "TCollectionItem * __usercall $name@<eax>(TCollection *Self@<eax>);" @note "DCC32 MAP Classes.TCollection.Add. Source rtl/common/Classes.pas:3989."
    procedure Clear; // @ida "void __usercall $name(TCollection *Self@<eax>);" @note "DCC32 MAP Classes.TCollection.Clear. Source rtl/common/Classes.pas:4024."
  end;

  TCollectionItem = class(TPersistent) // @partial
  end;

  TStrings = class(TPersistent) // @size 0x18
  public
    function Add(const S: AnsiString): Integer; virtual; // @ida "__int32 __usercall $name@<eax>(TStrings *Self@<eax>, char * S@<edx>);" @note "DCC32 MAP Classes.TStrings.Add. Source rtl/common/Classes.pas:4274." @slot 0x38
    function AddObject(const S: AnsiString; AObject: TObject): Integer; virtual; // @ida "__int32 __usercall $name@<eax>(TStrings *Self@<eax>, char * S@<edx>, TObject *AObject@<ecx>);" @note "DCC32 MAP Classes.TStrings.AddObject. Source rtl/common/Classes.pas:4280." @slot 0x3C
    procedure AddStrings(Strings: TStrings); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, TStrings *Strings@<edx>);" @note "DCC32 MAP Classes.TStrings.AddStrings. Source rtl/common/Classes.pas:4291." @slot 0x40
    procedure Assign(Source: TPersistent); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, TPersistent *Source@<edx>);" @note "DCC32 MAP Classes.TStrings.Assign. Source rtl/common/Classes.pas:4304." @slot 0x8
    procedure BeginUpdate; // @ida "void __usercall $name(TStrings *Self@<eax>);" @note "DCC32 MAP Classes.TStrings.BeginUpdate. Source rtl/common/Classes.pas:4326."
    procedure DefineProperties(Filer: TFiler); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, TFiler *Filer@<edx>);" @note "DCC32 MAP Classes.TStrings.DefineProperties. Source rtl/common/Classes.pas:4332." @slot 0x4
    procedure EndUpdate; // @ida "void __usercall $name(TStrings *Self@<eax>);" @note "DCC32 MAP Classes.TStrings.EndUpdate. Source rtl/common/Classes.pas:4349."
    function Equals(Strings: TStrings): Boolean; // @ida "bool __usercall $name@<al>(TStrings *Self@<eax>, TStrings *Strings@<edx>);" @note "DCC32 MAP Classes.TStrings.Equals. Source rtl/common/Classes.pas:4355."
    procedure Error; // @nameonly @note "DCC32 MAP Classes.TStrings.Error. Prototype pending: no unique source declaration."
    procedure Exchange(Index1, Index2: Integer); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, __int32 Index1@<edx>, __int32 Index2@<ecx>);" @note "DCC32 MAP Classes.TStrings.Exchange. Source rtl/common/Classes.pas:4382." @slot 0x4C
    function GetText: PAnsiChar; virtual; // @ida "PAnsiChar __usercall $name@<eax>(TStrings *Self@<eax>);" @note "DCC32 MAP Classes.TStrings.GetText. Source rtl/common/Classes.pas:4484." @slot 0x50
    function GetTextStr: AnsiString; virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Classes.TStrings.GetTextStr. Source rtl/common/Classes.pas:4489." @slot 0x1C
    function IndexOf(const S: AnsiString): Integer; virtual; // @ida "__int32 __usercall $name@<eax>(TStrings *Self@<eax>, char * S@<edx>);" @note "DCC32 MAP Classes.TStrings.IndexOf. Source rtl/common/Classes.pas:4529." @slot 0x54
    function IndexOfName(const Name: AnsiString): Integer; virtual; // @ida "__int32 __usercall $name@<eax>(TStrings *Self@<eax>, char * Name@<edx>);" @note "DCC32 MAP Classes.TStrings.IndexOfName. Source rtl/common/Classes.pas:4536." @slot 0x58
    function IndexOfObject(AObject: TObject): Integer; virtual; // @ida "__int32 __usercall $name@<eax>(TStrings *Self@<eax>, TObject *AObject@<edx>);" @note "DCC32 MAP Classes.TStrings.IndexOfObject. Source rtl/common/Classes.pas:4550." @slot 0x5C
    procedure InsertObject(Index: Integer; const S: AnsiString; AObject: TObject); virtual; // @ida "void __userpurge $name(TStrings *Self@<eax>, __int32 Index@<edx>, char * S@<ecx>, TObject *AObject@<^0>);" @note "DCC32 MAP Classes.TStrings.InsertObject. Source rtl/common/Classes.pas:4557." @slot 0x64
    procedure LoadFromFile(const FileName: AnsiString); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, char * FileName@<edx>);" @note "DCC32 MAP Classes.TStrings.LoadFromFile. Source rtl/common/Classes.pas:4564." @slot 0x68
    procedure LoadFromStream(Stream: TStream); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, TStream *Stream@<edx>);" @note "DCC32 MAP Classes.TStrings.LoadFromStream. Source rtl/common/Classes.pas:4576." @slot 0x6C
    procedure Move(CurIndex, NewIndex: Integer); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, __int32 CurIndex@<edx>, __int32 NewIndex@<ecx>);" @note "DCC32 MAP Classes.TStrings.Move. Source rtl/common/Classes.pas:4592." @slot 0x70
    procedure Put(Index: Integer; const S: AnsiString); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, __int32 Index@<edx>, char * S@<ecx>);" @note "DCC32 MAP Classes.TStrings.Put. Source rtl/common/Classes.pas:4611." @slot 0x20
    procedure ReadData(Reader: TReader); // @ida "void __usercall $name(TStrings *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Classes.TStrings.ReadData. Source rtl/common/Classes.pas:4624."
    procedure SaveToFile(const FileName: AnsiString); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, char * FileName@<edx>);" @note "DCC32 MAP Classes.TStrings.SaveToFile. Source rtl/common/Classes.pas:4637." @slot 0x74
    procedure SaveToStream(Stream: TStream); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, TStream *Stream@<edx>);" @note "DCC32 MAP Classes.TStrings.SaveToStream. Source rtl/common/Classes.pas:4649." @slot 0x78
    procedure SetStringsAdapter(const Value: IStringsAdapter); // @ida "void __usercall $name(TStrings *Self@<eax>, IStringsAdapter *Value@<edx>);" @note "DCC32 MAP Classes.TStrings.SetStringsAdapter. Source rtl/common/Classes.pas:4669."
    procedure SetText(Text: PAnsiChar); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, PAnsiChar Text@<edx>);" @note "DCC32 MAP Classes.TStrings.SetText. Source rtl/common/Classes.pas:4676." @slot 0x7C
    procedure SetTextStr(const Value: AnsiString); virtual; // @ida "void __usercall $name(TStrings *Self@<eax>, char * Value@<edx>);" @note "DCC32 MAP Classes.TStrings.SetTextStr. Source rtl/common/Classes.pas:4681." @slot 0x2C
    procedure WriteData(Writer: TWriter); // @ida "void __usercall $name(TStrings *Self@<eax>, TWriter *Writer@<edx>);" @note "DCC32 MAP Classes.TStrings.WriteData. Source rtl/common/Classes.pas:4751."
    function GetLineBreak: AnsiString; // @ida "void __usercall $name(TStrings *Self@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Classes.TStrings.GetLineBreak. Source rtl/common/Classes.pas:4832."
    procedure SetLineBreak(const Value: AnsiString); // @ida "void __usercall $name(TStrings *Self@<eax>, char * Value@<edx>);" @note "DCC32 MAP Classes.TStrings.SetLineBreak. Source rtl/common/Classes.pas:4862."
    function CompareStrings(const S1, S2: AnsiString): Integer; virtual; // @ida "__int32 __usercall $name@<eax>(TStrings *Self@<eax>, char * S1@<edx>, char * S2@<ecx>);" @note "DCC32 MAP Classes.TStrings.CompareStrings. Source rtl/common/Classes.pas:4889." @slot 0x34
    function GetNameValueSeparator: Char; // @ida "char __usercall $name@<al>(TStrings *Self@<eax>);" @note "DCC32 MAP Classes.TStrings.GetNameValueSeparator. Source rtl/common/Classes.pas:4894."
    procedure SetNameValueSeparator(const Value: Char); // @ida "void __usercall $name(TStrings *Self@<eax>, char Value@<dl>);" @note "DCC32 MAP Classes.TStrings.SetNameValueSeparator. Source rtl/common/Classes.pas:4901."
  end;

  TFiler = class(TObject) // @size 0x28
  public
    constructor Create(Stream: TStream; BufSize: Integer); // @ida "TFiler * __userpurge $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TStream *Stream@<ecx>, __int32 BufSize@<^0>);" @note "DCC32 MAP Classes.TFiler.Create. Source rtl/common/Classes.pas:5761."
    destructor Destroy; // @ida "void __usercall $name(TFiler *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TFiler.Destroy. Source rtl/common/Classes.pas:5768."
  end;

  TReader = class(TFiler) // @size 0x8C
  public
    destructor Destroy; // @ida "void __usercall $name(TReader *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TReader.Destroy. Source rtl/common/Classes.pas:6102."
    procedure CheckValue(Value: TValueType); // @ida "void __usercall $name(TReader *Self@<eax>, TValueType Value@<dl>);" @note "DCC32 MAP Classes.TReader.CheckValue. Source rtl/common/Classes.pas:6119."
    procedure DefineProperty; // @nameonly @note "DCC32 MAP Classes.TReader.DefineProperty. Source rtl/common/Classes.pas:6129. Prototype pending: unsupported source type TReaderProc: procedure(Reader: TReader) of object."
    procedure DefineBinaryProperty; // @nameonly @note "DCC32 MAP Classes.TReader.DefineBinaryProperty. Source rtl/common/Classes.pas:6139. Prototype pending: unsupported source type TStreamProc: procedure(Stream: TStream) of object."
    function EndOfList: Boolean; // @ida "bool __usercall $name@<al>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.EndOfList. Source rtl/common/Classes.pas:6168."
    function Error(const Message: AnsiString): Boolean; virtual; // @ida "bool __usercall $name@<al>(TReader *Self@<eax>, char * Message@<edx>);" @note "DCC32 MAP Classes.TReader.Error. Source rtl/common/Classes.pas:6181." @slot 0x10
    function FindMethodInstance(Root: TComponent; const MethodName: AnsiString): TMethod; virtual; // @ida "void __userpurge $name(TReader *Self@<eax>, TComponent *Root@<edx>, char * MethodName@<ecx>, TMethod *Result@<^0>);" @note "DCC32 MAP Classes.TReader.FindMethodInstance. Source rtl/common/Classes.pas:6187." @slot 0x18
    function FindMethod(Root: TComponent; const MethodName: AnsiString): Pointer; virtual; // @ida "void * __usercall $name@<eax>(TReader *Self@<eax>, TComponent *Root@<edx>, char * MethodName@<ecx>);" @note "DCC32 MAP Classes.TReader.FindMethod. Source rtl/common/Classes.pas:6206." @slot 0x1C
    procedure DoFixupReferences; // @ida "void __usercall $name(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.DoFixupReferences. Source rtl/common/Classes.pas:6235."
    procedure FlushBuffer; virtual; // @ida "void __usercall $name(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.FlushBuffer. Source rtl/common/Classes.pas:6279." @slot 0xC
    procedure FreeFixups; // @ida "void __usercall $name(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.FreeFixups. Source rtl/common/Classes.pas:6286."
    function GetFieldClass(Instance: TObject; const ClassName: AnsiString): TPersistentClass; // @ida "TPersistentClass __usercall $name@<eax>(TReader *Self@<eax>, TObject *Instance@<edx>, char * ClassName@<ecx>);" @note "DCC32 MAP Classes.TReader.GetFieldClass. Source rtl/common/Classes.pas:6298."
    function GetPosition: Longint; // @ida "__int32 __usercall $name@<eax>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.GetPosition. Source rtl/common/Classes.pas:6322."
    procedure Read(Buf: Pointer; Count: Longint); // @ida "void __usercall $name(TReader *Self@<eax>, void * Buf@<edx>, __int32 Count@<ecx>);" @note "DCC32 MAP Classes.TReader.Read. Source rtl/common/Classes.pas:6339."
    procedure ReadBuffer; // @ida "void __usercall $name(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadBuffer. Source rtl/common/Classes.pas:6378."
    function ReadChar: Char; // @ida "char __usercall $name@<al>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadChar. Source rtl/common/Classes.pas:6390."
    function ReadWideChar: WideChar; // @ida "unsigned __int16 __usercall $name@<ax>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadWideChar. Source rtl/common/Classes.pas:6400."
    procedure ReadCollection(Collection: TCollection); // @ida "void __usercall $name(TReader *Self@<eax>, TCollection *Collection@<edx>);" @note "DCC32 MAP Classes.TReader.ReadCollection. Source rtl/common/Classes.pas:6410."
    function ReadComponent(Component: TComponent): TComponent; // @ida "TComponent * __usercall $name@<eax>(TReader *Self@<eax>, TComponent *Component@<edx>);" @note "DCC32 MAP Classes.TReader.ReadComponent. Source rtl/common/Classes.pas:6431."
    procedure ReadData(Instance: TComponent); // @ida "void __usercall $name(TReader *Self@<eax>, TComponent *Instance@<edx>);" @note "DCC32 MAP Classes.TReader.ReadData. Source rtl/common/Classes.pas:6588."
    procedure ReadDataInner(Instance: TComponent); // @ida "void __usercall $name(TReader *Self@<eax>, TComponent *Instance@<edx>);" @note "DCC32 MAP Classes.TReader.ReadDataInner. Source rtl/common/Classes.pas:6603."
    function ReadFloat: Extended; // @nameonly @note "DCC32 MAP Classes.TReader.ReadFloat. Source rtl/common/Classes.pas:6623. Prototype pending: structured result ABI."
    function ReadDouble: Double; // @ida "double __usercall $name@<st0>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadDouble. Source rtl/common/Classes.pas:6634."
    function ReadSingle: Single; // @ida "float __usercall $name@<st0>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadSingle. Source rtl/common/Classes.pas:6645."
    procedure ReadCurrency; // @nameonly @note "DCC32 MAP Classes.TReader.ReadCurrency. Source rtl/common/Classes.pas:6654. Prototype pending: source type not found: Currency."
    function ReadDate: TDateTime; // @ida "TDateTime __usercall $name@<st0>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadDate. Source rtl/common/Classes.pas:6663."
    function ReadIdent: AnsiString; // @ida "void __usercall $name(TReader *Self@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Classes.TReader.ReadIdent. Source rtl/common/Classes.pas:6672."
    function ReadInteger: Longint; // @ida "__int32 __usercall $name@<eax>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadInteger. Source rtl/common/Classes.pas:6696."
    function ReadInt64: Int64; // @ida "__int64 __usercall $name@<edx:eax>(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadInt64. Source rtl/common/Classes.pas:6719."
    procedure ReadPrefix(var Flags: TFilerFlags; var AChildPos: Integer); virtual; // @ida "void __usercall $name(TReader *Self@<eax>, TFilerFlags *Flags@<edx>, __int32 *AChildPos@<ecx>);" @note "DCC32 MAP Classes.TReader.ReadPrefix. Source rtl/common/Classes.pas:6740." @slot 0x28
    procedure ReadProperty(AInstance: TPersistent); // @ida "void __usercall $name(TReader *Self@<eax>, TPersistent *AInstance@<edx>);" @note "DCC32 MAP Classes.TReader.ReadProperty. Source rtl/common/Classes.pas:6753."
    procedure ReadPropValue(Instance: TPersistent; PropInfo: Pointer); // @ida "void __usercall $name(TReader *Self@<eax>, TPersistent *Instance@<edx>, void * PropInfo@<ecx>);" @note "DCC32 MAP Classes.TReader.ReadPropValue. Source rtl/common/Classes.pas:6832."
    function ReadRootComponent(Root: TComponent): TComponent; // @ida "TComponent * __usercall $name@<eax>(TReader *Self@<eax>, TComponent *Root@<edx>);" @note "DCC32 MAP Classes.TReader.ReadRootComponent. Source rtl/common/Classes.pas:6940."
    function ReadSet(SetType: Pointer): Integer; // @ida "__int32 __usercall $name@<eax>(TReader *Self@<eax>, void * SetType@<edx>);" @note "DCC32 MAP Classes.TReader.ReadSet. Source rtl/common/Classes.pas:7055."
    procedure ReadSignature; // @ida "void __usercall $name(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.ReadSignature. Source rtl/common/Classes.pas:7076."
    function ReadStr: AnsiString; // @ida "void __usercall $name(TReader *Self@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Classes.TReader.ReadStr. Source rtl/common/Classes.pas:7084."
    function ReadString: AnsiString; // @ida "void __usercall $name(TReader *Self@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Classes.TReader.ReadString. Source rtl/common/Classes.pas:7093."
    function ReadWideString: WideString; // @ida "void __usercall $name(TReader *Self@<eax>, unsigned __int16 * *Result@<edx>);" @note "DCC32 MAP Classes.TReader.ReadWideString. Source rtl/common/Classes.pas:7115."
    procedure SkipSetBody; // @ida "void __usercall $name(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.SkipSetBody. Source rtl/common/Classes.pas:7157."
    procedure SkipValue; // @ida "void __usercall $name(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.SkipValue. Source rtl/common/Classes.pas:7162."
    procedure SkipProperty; // @ida "void __usercall $name(TReader *Self@<eax>);" @note "DCC32 MAP Classes.TReader.SkipProperty. Source rtl/common/Classes.pas:7296."
    procedure SkipComponent(SkipHeader: Boolean); // @ida "void __usercall $name(TReader *Self@<eax>, bool SkipHeader@<dl>);" @note "DCC32 MAP Classes.TReader.SkipComponent. Source rtl/common/Classes.pas:7302."
    function FindAncestorComponent(const Name: AnsiString; ComponentClass: TPersistentClass): TComponent; virtual; // @ida "TComponent * __usercall $name@<eax>(TReader *Self@<eax>, char * Name@<edx>, TPersistentClass ComponentClass@<ecx>);" @note "DCC32 MAP Classes.TReader.FindAncestorComponent. Source rtl/common/Classes.pas:7319." @slot 0x14
    procedure ReferenceName(var Name: AnsiString); virtual; // @ida "void __usercall $name(TReader *Self@<eax>, char * *Name@<edx>);" @note "DCC32 MAP Classes.TReader.ReferenceName. Source rtl/common/Classes.pas:7337." @slot 0x24
    procedure SetName(Component: TComponent; var Name: AnsiString); virtual; // @ida "void __usercall $name(TReader *Self@<eax>, TComponent *Component@<edx>, char * *Name@<ecx>);" @note "DCC32 MAP Classes.TReader.SetName. Source rtl/common/Classes.pas:7342." @slot 0x20
    function FindComponentClass(const ClassName: AnsiString): TComponentClass; // @ida "TComponentClass __usercall $name@<eax>(TReader *Self@<eax>, char * ClassName@<edx>);" @note "DCC32 MAP Classes.TReader.FindComponentClass. Source rtl/common/Classes.pas:7348."
    procedure SkipBytes(Count: Integer); // @ida "void __usercall $name(TReader *Self@<eax>, __int32 Count@<edx>);" @note "DCC32 MAP Classes.TReader.SkipBytes. Source rtl/common/Classes.pas:7359."
    procedure ReadVariant; // @nameonly @note "DCC32 MAP Classes.TReader.ReadVariant. Source rtl/common/Classes.pas:7376. Prototype pending: source type not found: Variant."
  end;

  IStringsAdapter = interface;

  TWriter = class(TFiler) // @partial
  public
    procedure Write(Buf: Pointer; Count: Longint); // @ida "void __usercall $name(TWriter *Self@<eax>, void * Buf@<edx>, __int32 Count@<ecx>);" @note "DCC32 MAP Classes.TWriter.Write. Source rtl/common/Classes.pas:7516."
    procedure WriteBuffer; // @ida "void __usercall $name(TWriter *Self@<eax>);" @note "DCC32 MAP Classes.TWriter.WriteBuffer. Source rtl/common/Classes.pas:7572."
    procedure WriteInteger; // @nameonly @note "DCC32 MAP Classes.TWriter.WriteInteger. Prototype pending: no unique source declaration."
    procedure WriteMinStr(const LocaleStr: AnsiString; const UTF8Str: AnsiString); // @ida "void __usercall $name(TWriter *Self@<eax>, char * LocaleStr@<edx>, char * UTF8Str@<ecx>);" @note "DCC32 MAP Classes.TWriter.WriteMinStr. Source rtl/common/Classes.pas:8466."
    procedure WriteString(const Value: AnsiString); // @ida "void __usercall $name(TWriter *Self@<eax>, char * Value@<edx>);" @note "DCC32 MAP Classes.TWriter.WriteString. Source rtl/common/Classes.pas:8493."
  end;

  TStringList = class(TStrings) // @size 0x38
  public
    destructor Destroy; // @ida "void __usercall $name(TStringList *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TStringList.Destroy. Source rtl/common/Classes.pas:4930."
    function Add(const S: AnsiString): Integer; override; // @ida "__int32 __usercall $name@<eax>(TStringList *Self@<eax>, char * S@<edx>);" @note "DCC32 MAP Classes.TStringList.Add. Source rtl/common/Classes.pas:4940." @slot 0x38
    function AddObject(const S: AnsiString; AObject: TObject): Integer; override; // @ida "__int32 __usercall $name@<eax>(TStringList *Self@<eax>, char * S@<edx>, TObject *AObject@<ecx>);" @note "DCC32 MAP Classes.TStringList.AddObject. Source rtl/common/Classes.pas:4945." @slot 0x3C
    procedure Changed; virtual; // @ida "void __usercall $name(TStringList *Self@<eax>);" @note "DCC32 MAP Classes.TStringList.Changed. Source rtl/common/Classes.pas:4958." @slot 0x80
    procedure Changing; virtual; // @ida "void __usercall $name(TStringList *Self@<eax>);" @note "DCC32 MAP Classes.TStringList.Changing. Source rtl/common/Classes.pas:4964." @slot 0x84
    procedure Clear; virtual; // @ida "void __usercall $name(TStringList *Self@<eax>);" @note "DCC32 MAP Classes.TStringList.Clear. Source rtl/common/Classes.pas:4970." @slot 0x44
    procedure Delete(Index: Integer); virtual; // @ida "void __usercall $name(TStringList *Self@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP Classes.TStringList.Delete. Source rtl/common/Classes.pas:4982." @slot 0x48
    procedure Exchange(Index1, Index2: Integer); override; // @ida "void __usercall $name(TStringList *Self@<eax>, __int32 Index1@<edx>, __int32 Index2@<ecx>);" @note "DCC32 MAP Classes.TStringList.Exchange. Source rtl/common/Classes.pas:4994." @slot 0x4C
    procedure ExchangeItems(Index1, Index2: Integer); // @ida "void __usercall $name(TStringList *Self@<eax>, __int32 Index1@<edx>, __int32 Index2@<ecx>);" @note "DCC32 MAP Classes.TStringList.ExchangeItems. Source rtl/common/Classes.pas:5003."
    function Find(const S: AnsiString; var Index: Integer): Boolean; virtual; // @ida "bool __usercall $name@<al>(TStringList *Self@<eax>, char * S@<edx>, __int32 *Index@<ecx>);" @note "DCC32 MAP Classes.TStringList.Find. Source rtl/common/Classes.pas:5018." @slot 0x8C
    function Get(Index: Integer): AnsiString; virtual; // @ida "void __usercall $name(TStringList *Self@<eax>, __int32 Index@<edx>, char * *Result@<ecx>);" @note "DCC32 MAP Classes.TStringList.Get. Source rtl/common/Classes.pas:5042." @slot 0xC
    function GetObject(Index: Integer): TObject; virtual; // @ida "TObject * __usercall $name@<eax>(TStringList *Self@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP Classes.TStringList.GetObject. Source rtl/common/Classes.pas:5058." @slot 0x18
    procedure Grow; // @ida "void __usercall $name(TStringList *Self@<eax>);" @note "DCC32 MAP Classes.TStringList.Grow. Source rtl/common/Classes.pas:5064."
    function IndexOf(const S: AnsiString): Integer; override; // @ida "__int32 __usercall $name@<eax>(TStringList *Self@<eax>, char * S@<edx>);" @note "DCC32 MAP Classes.TStringList.IndexOf. Source rtl/common/Classes.pas:5074." @slot 0x54
    procedure Insert(Index: Integer; const S: AnsiString); virtual; // @ida "void __usercall $name(TStringList *Self@<eax>, __int32 Index@<edx>, char * S@<ecx>);" @note "DCC32 MAP Classes.TStringList.Insert. Source rtl/common/Classes.pas:5080." @slot 0x60
    procedure InsertObject(Index: Integer; const S: AnsiString; AObject: TObject); override; // @ida "void __userpurge $name(TStringList *Self@<eax>, __int32 Index@<edx>, char * S@<ecx>, TObject *AObject@<^0>);" @note "DCC32 MAP Classes.TStringList.InsertObject. Source rtl/common/Classes.pas:5085." @slot 0x64
    procedure InsertItem(Index: Integer; const S: AnsiString; AObject: TObject); virtual; // @ida "void __userpurge $name(TStringList *Self@<eax>, __int32 Index@<edx>, char * S@<ecx>, TObject *AObject@<^0>);" @note "DCC32 MAP Classes.TStringList.InsertItem. Source rtl/common/Classes.pas:5093." @slot 0x88
    procedure Put(Index: Integer; const S: AnsiString); override; // @ida "void __usercall $name(TStringList *Self@<eax>, __int32 Index@<edx>, char * S@<ecx>);" @note "DCC32 MAP Classes.TStringList.Put. Source rtl/common/Classes.pas:5110." @slot 0x20
    procedure PutObject(Index: Integer; AObject: TObject); virtual; // @ida "void __usercall $name(TStringList *Self@<eax>, __int32 Index@<edx>, TObject *AObject@<ecx>);" @note "DCC32 MAP Classes.TStringList.PutObject. Source rtl/common/Classes.pas:5119." @slot 0x24
    procedure QuickSort; // @nameonly @note "DCC32 MAP Classes.TStringList.QuickSort. Source rtl/common/Classes.pas:5127. Prototype pending: unsupported source type TStringListSortCompare: function(List: TStringList; Index1, Index2: Integer): Integer."
    procedure SetCapacity(NewCapacity: Integer); virtual; // @ida "void __usercall $name(TStringList *Self@<eax>, __int32 NewCapacity@<edx>);" @note "DCC32 MAP Classes.TStringList.SetCapacity. Source rtl/common/Classes.pas:5154." @slot 0x28
    procedure SetSorted(Value: Boolean); // @ida "void __usercall $name(TStringList *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Classes.TStringList.SetSorted. Source rtl/common/Classes.pas:5160."
    procedure CustomSort; // @nameonly @note "DCC32 MAP Classes.TStringList.CustomSort. Source rtl/common/Classes.pas:5185. Prototype pending: unsupported source type TStringListSortCompare: function(List: TStringList; Index1, Index2: Integer): Integer."
    function CompareStrings(const S1, S2: AnsiString): Integer; override; // @ida "__int32 __usercall $name@<eax>(TStringList *Self@<eax>, char * S1@<edx>, char * S2@<ecx>);" @note "DCC32 MAP Classes.TStringList.CompareStrings. Source rtl/common/Classes.pas:5195." @slot 0x34
  end;

  THandleStream = class(TStream) // @size 0x8
  public
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; // @nameonly @note "DCC32 MAP Classes.THandleStream.Seek. Source rtl/common/Classes.pas:5442. Prototype pending: const wide scalar ABI."
    procedure SetSize; // @nameonly @note "DCC32 MAP Classes.THandleStream.SetSize. Prototype pending: no unique source declaration."
    procedure SetSize_418670; // @nameonly @note "DCC32 MAP Classes.THandleStream.SetSize. Prototype pending: no unique source declaration."
  end;

  TFileStream = class(THandleStream) // @size 0xC
  public
    procedure Create; // @nameonly @note "DCC32 MAP Classes.TFileStream.Create. Prototype pending: no unique source declaration."
    procedure Create_4186DC; // @nameonly @note "DCC32 MAP Classes.TFileStream.Create. Prototype pending: no unique source declaration."
    destructor Destroy; // @ida "void __usercall $name(TFileStream *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TFileStream.Destroy. Source rtl/common/Classes.pas:5491."
  end;

  TResourceStream = class(TCustomMemoryStream) // @size 0x18
  public
    constructor Create(Instance: Cardinal; const ResName: AnsiString; ResType: PAnsiChar); // @ida "TResourceStream * __userpurge $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int32 Instance@<ecx>, char * ResName@<^4>, PAnsiChar ResType@<^0>);" @note "DCC32 MAP Classes.TResourceStream.Create. Source rtl/common/Classes.pas:5711."
    procedure Initialize(Instance: Cardinal; Name, ResType: PAnsiChar; FromID: Boolean); // @ida "void __userpurge $name(TResourceStream *Self@<eax>, unsigned __int32 Instance@<edx>, PAnsiChar Name@<ecx>, PAnsiChar ResType@<^4>, bool FromID@<^0>);" @note "DCC32 MAP Classes.TResourceStream.Initialize. Source rtl/common/Classes.pas:5725."
    destructor Destroy; // @ida "void __usercall $name(TResourceStream *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TResourceStream.Destroy. Source rtl/common/Classes.pas:5747."
  end;

  TPropFixup = class(TObject) // @size 0x18
  public
    constructor Create(Instance: TPersistent; InstanceRoot: TComponent; PropInfo: PPropInfo; const RootName, Name: AnsiString); // @ida "TPropFixup * __userpurge $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TPersistent *Instance@<ecx>, TComponent *InstanceRoot@<^12>, PPropInfo PropInfo@<^8>, char * RootName@<^4>, char * Name@<^0>);" @note "DCC32 MAP Classes.TPropFixup.Create. Source rtl/common/Classes.pas:5800."
    function MakeGlobalReference: Boolean; // @ida "bool __usercall $name@<al>(TPropFixup *Self@<eax>);" @note "DCC32 MAP Classes.TPropFixup.MakeGlobalReference. Source rtl/common/Classes.pas:5810."
  end;

  TPropIntfFixup = class(TPropFixup) // @size 0x18
  public
    procedure ResolveReference(Reference: Pointer); virtual; // @ida "void __usercall $name(TPropIntfFixup *Self@<eax>, void * Reference@<edx>);" @note "DCC32 MAP Classes.TPropIntfFixup.ResolveReference. Source rtl/common/Classes.pas:5830." @slot 0x0
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
    constructor Create(AOwner: TComponent); override; // @ida "TBasicAction * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TComponent *AOwner@<ecx>);" @note "DCC32 MAP Classes.TBasicAction.Create. Source rtl/common/Classes.pas:11039." @slot 0x2C
    destructor Destroy; // @ida "void __usercall $name(TBasicAction *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TBasicAction.Destroy. Source rtl/common/Classes.pas:11045."
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @ida "void __usercall $name(TBasicAction *Self@<eax>, TComponent *AComponent@<edx>, TOperation Operation@<cl>);" @note "DCC32 MAP Classes.TBasicAction.Notification. Source rtl/common/Classes.pas:11065." @slot 0x10
    function Execute: Boolean; // @ida "bool __usercall $name@<al>(TBasicAction *Self@<eax>);" @note "DCC32 MAP Classes.TBasicAction.Execute. Source rtl/common/Classes.pas:11077."
    function Update: Boolean; virtual; // @ida "bool __usercall $name@<al>(TBasicAction *Self@<eax>);" @note "DCC32 MAP Classes.TBasicAction.Update. Source rtl/common/Classes.pas:11087." @slot 0x44
    procedure SetOnExecute; // @nameonly @note "DCC32 MAP Classes.TBasicAction.SetOnExecute. Source rtl/common/Classes.pas:11097. Prototype pending: unsupported source type TNotifyEvent: procedure(Sender: TObject) of object."
    procedure UnRegisterChanges(Value: TBasicActionLink); // @ida "void __usercall $name(TBasicAction *Self@<eax>, TBasicActionLink *Value@<edx>);" @note "DCC32 MAP Classes.TBasicAction.UnRegisterChanges. Source rtl/common/Classes.pas:11122."
    procedure SetActionComponent(const Value: TComponent); // @ida "void __usercall $name(TBasicAction *Self@<eax>, TComponent *Value@<edx>);" @note "DCC32 MAP Classes.TBasicAction.SetActionComponent. Source rtl/common/Classes.pas:11135."
  end;

  TBasicActionLink = class(TObject) // @size 0x14
  public
    constructor Create(AClient: TObject); virtual; // @ida "TBasicActionLink * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObject *AClient@<ecx>);" @note "DCC32 MAP Classes.TBasicActionLink.Create. Source rtl/common/Classes.pas:10986." @slot 0x14
    destructor Destroy; // @ida "void __usercall $name(TBasicActionLink *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TBasicActionLink.Destroy. Source rtl/common/Classes.pas:10996."
    procedure Change; virtual; // @ida "void __usercall $name(TBasicActionLink *Self@<eax>);" @note "DCC32 MAP Classes.TBasicActionLink.Change. Source rtl/common/Classes.pas:11002." @slot 0x4
    function Execute(AComponent: TComponent): Boolean; virtual; // @ida "bool __usercall $name@<al>(TBasicActionLink *Self@<eax>, TComponent *AComponent@<edx>);" @note "DCC32 MAP Classes.TBasicActionLink.Execute. Source rtl/common/Classes.pas:11007." @slot 0x18
    procedure SetAction(Value: TBasicAction); virtual; // @ida "void __usercall $name(TBasicActionLink *Self@<eax>, TBasicAction *Value@<edx>);" @note "DCC32 MAP Classes.TBasicActionLink.SetAction. Source rtl/common/Classes.pas:11013." @slot 0xC
  end;

  TStreamAdapter = class(TInterfacedObject) // @size 0x18
  public
    constructor Create(Stream: TStream; Ownership: TStreamOwnership); // @ida "TStreamAdapter * __userpurge $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TStream *Stream@<ecx>, TStreamOwnership Ownership@<^0>);" @note "DCC32 MAP Classes.TStreamAdapter.Create. Source rtl/common/Classes.pas:11149."
    destructor Destroy; // @ida "void __usercall $name(TStreamAdapter *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Classes.TStreamAdapter.Destroy. Source rtl/common/Classes.pas:11157."
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult; // @nameonly @note "DCC32 MAP Classes.TStreamAdapter.Read. Source rtl/common/Classes.pas:11167. Prototype pending: RET mismatch: expected 4, native [16]."
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult; // @nameonly @note "DCC32 MAP Classes.TStreamAdapter.Write. Source rtl/common/Classes.pas:11185. Prototype pending: RET mismatch: expected 4, native [16]."
    function Seek(dlibMove: Int64; dwOrigin: Longint; out libNewPosition: Int64): HResult; // @nameonly @note "DCC32 MAP Classes.TStreamAdapter.Seek. Source rtl/common/Classes.pas:11203. Prototype pending: RET mismatch: expected 8, native [20]."
    function SetSize(libNewSize: Int64): HResult; // @nameonly @note "DCC32 MAP Classes.TStreamAdapter.SetSize. Source rtl/common/Classes.pas:11222. Prototype pending: RET mismatch: expected 8, native [12]."
    procedure CopyTo; // @nameonly @note "DCC32 MAP Classes.TStreamAdapter.CopyTo. Source rtl/common/Classes.pas:11235. Prototype pending: ambiguous source type: IStream."
    procedure Stat; // @nameonly @note "DCC32 MAP Classes.TStreamAdapter.Stat. Source rtl/common/Classes.pas:11307. Prototype pending: ambiguous source type: TStatStg."
    procedure Clone; // @nameonly @note "DCC32 MAP Classes.TStreamAdapter.Clone. Source rtl/common/Classes.pas:11329. Prototype pending: ambiguous source type: IStream."
  end;

  TStreamOwnership = (soReference, soOwned); // @size 0x1

  TShiftStateElement = (ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble); // @size 0x1

  TShiftState = set of TShiftStateElement; // @size 0x1

  TShortCut = Word;

  THelpContext = Integer;

  THelpType = (htKeyword, htContext); // @size 0x1

  TBiDiMode = (bdLeftToRight, bdRightToLeft, bdRightToLeftNoAlign, bdRightToLeftReadingOnly); // @size 0x1

function PointerInModule(Ptr: Pointer; Module: Cardinal): Boolean; // @ida "bool __usercall $name@<al>(void * Ptr@<eax>, unsigned __int32 Module@<edx>);" @note "DCC32 MAP Classes.PointerInModule. Source rtl/common/Classes.pas:1993."

procedure Error; // @nameonly @note "DCC32 MAP Classes.Error. Prototype pending: no unique source declaration."

procedure ClassNotFound(const ClassName: AnsiString); // @ida "void __usercall $name(char * ClassName@<eax>);" @note "DCC32 MAP Classes.ClassNotFound. Source rtl/common/Classes.pas:2312."

procedure GetClass; // @nameonly @note "DCC32 MAP Classes.GetClass. Prototype pending: no unique source declaration."

function FindClass(const ClassName: AnsiString): TPersistentClass; // @ida "TPersistentClass __usercall $name@<eax>(char * ClassName@<eax>);" @note "DCC32 MAP Classes.FindClass. Source rtl/common/Classes.pas:2327."

procedure RegisterClass; // @nameonly @note "DCC32 MAP Classes.RegisterClass. Prototype pending: no unique source declaration."

procedure GroupDescendentsWith(AClass, AClassGroup: TPersistentClass); // @ida "void __usercall $name(TPersistentClass AClass@<eax>, TPersistentClass AClassGroup@<edx>);" @note "DCC32 MAP Classes.GroupDescendentsWith. Source rtl/common/Classes.pas:2402."

function ActivateClassGroup(AClass: TPersistentClass): TPersistentClass; // @ida "TPersistentClass __usercall $name@<eax>(TPersistentClass AClass@<eax>);" @note "DCC32 MAP Classes.ActivateClassGroup. Source rtl/common/Classes.pas:2412."

procedure RegisterIntegerConsts; // @nameonly @note "DCC32 MAP Classes.RegisterIntegerConsts. Source rtl/common/Classes.pas:2510. Prototype pending: unsupported source type TIdentToInt: function(const Ident: string; var Int: Longint): Boolean."

procedure FindIdentToInt; // @nameonly @note "DCC32 MAP Classes.FindIdentToInt. Source rtl/common/Classes.pas:2553. Prototype pending: unsupported source type TIdentToInt: function(const Ident: string; var Int: Longint): Boolean."

function IdentToInt(const Ident: AnsiString; var Int: Longint; const Map: array of TIdentMapEntry): Boolean; // @nameonly @note "DCC32 MAP Classes.IdentToInt. Source rtl/common/Classes.pas:2572. Prototype pending: open-array ABI needs expansion."

function IntToIdent(Int: Longint; var Ident: AnsiString; const Map: array of TIdentMapEntry): Boolean; // @nameonly @note "DCC32 MAP Classes.IntToIdent. Source rtl/common/Classes.pas:2586. Prototype pending: open-array ABI needs expansion."

procedure RegisterFindGlobalComponentProc; // @nameonly @note "DCC32 MAP Classes.RegisterFindGlobalComponentProc. Source rtl/common/Classes.pas:2603. Prototype pending: unsupported source type TFindGlobalComponent: function(const Name: string): TComponent."

function FindGlobalComponent(const Name: AnsiString): TComponent; // @ida "TComponent * __usercall $name@<eax>(char * Name@<eax>);" @note "DCC32 MAP Classes.FindGlobalComponent. Source rtl/common/Classes.pas:2617."

function InternalReadComponentRes(const ResName: AnsiString; HInst: Cardinal; var Instance: TComponent): Boolean; // @ida "bool __usercall $name@<al>(char * ResName@<eax>, unsigned __int32 HInst@<edx>, TComponent **Instance@<ecx>);" @note "DCC32 MAP Classes.InternalReadComponentRes. Source rtl/common/Classes.pas:2639."

procedure BeginGlobalLoading; // @ida "void __usercall $name(void);" @note "DCC32 MAP Classes.BeginGlobalLoading. Source rtl/common/Classes.pas:2660."

procedure NotifyGlobalLoading; // @ida "void __usercall $name(void);" @note "DCC32 MAP Classes.NotifyGlobalLoading. Source rtl/common/Classes.pas:2674."

procedure EndGlobalLoading; // @ida "void __usercall $name(void);" @note "DCC32 MAP Classes.EndGlobalLoading. Source rtl/common/Classes.pas:2684."

function InitComponent(ClassType: TClass): Boolean; // @nameonly @note "DCC32 MAP Classes.InitComponent. Source rtl/common/Classes.pas:2701. Prototype pending: nested routine has a parent-frame parameter."

function InitInheritedComponent(Instance: TComponent; RootAncestor: TClass): Boolean; // @ida "bool __usercall $name@<al>(TComponent *Instance@<eax>, TClass RootAncestor@<edx>);" @note "DCC32 MAP Classes.InitInheritedComponent. Source rtl/common/Classes.pas:2699."

function DoWrite: Boolean; // @nameonly @note "DCC32 MAP Classes.DoWrite. Source rtl/common/Classes.pas:4334. Prototype pending: nested routine has a parent-frame parameter."

function StringListCompareStrings(List: TStringList; Index1, Index2: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(TStringList *List@<eax>, __int32 Index1@<edx>, __int32 Index2@<ecx>);" @note "DCC32 MAP Classes.StringListCompareStrings. Source rtl/common/Classes.pas:5174."

procedure RaiseException_4182D0; // @nameonly @note "DCC32 MAP Classes.RaiseException. Source rtl/common/Classes.pas:5258. Prototype pending: nested routine has a parent-frame parameter."

procedure Error_418AE0; // @nameonly @note "DCC32 MAP Classes.Error. Prototype pending: no unique source declaration."

function FindNestedComponent(Root: TComponent; const NamePath: AnsiString): TComponent; // @ida "TComponent * __usercall $name@<eax>(TComponent *Root@<eax>, char * NamePath@<edx>);" @note "DCC32 MAP Classes.FindNestedComponent. Source rtl/common/Classes.pas:5841."

procedure AddFinished(Instance: TPersistent); // @nameonly @note "DCC32 MAP Classes.AddFinished. Source rtl/common/Classes.pas:5878. Prototype pending: nested routine has a parent-frame parameter."

procedure AddNotFinished(Instance: TPersistent); // @nameonly @note "DCC32 MAP Classes.AddNotFinished. Source rtl/common/Classes.pas:5885. Prototype pending: nested routine has a parent-frame parameter."

procedure GlobalFixupReferences; // @ida "void __usercall $name(void);" @note "DCC32 MAP Classes.GlobalFixupReferences. Source rtl/common/Classes.pas:5868."

procedure RemoveFixupReferences(Root: TComponent; const RootName: AnsiString); // @ida "void __usercall $name(TComponent *Root@<eax>, char * RootName@<edx>);" @note "DCC32 MAP Classes.RemoveFixupReferences. Source rtl/common/Classes.pas:6007."

procedure RemoveFixups(Instance: TPersistent); // @ida "void __usercall $name(TPersistent *Instance@<eax>);" @note "DCC32 MAP Classes.RemoveFixups. Source rtl/common/Classes.pas:6030."

procedure RemoveGlobalFixup(Fixup: TPropFixup); // @ida "void __usercall $name(TPropFixup *Fixup@<eax>);" @note "DCC32 MAP Classes.RemoveGlobalFixup. Source rtl/common/Classes.pas:6217."

procedure AddSubComponentsToLoaded(Component: TComponent); // @nameonly @note "DCC32 MAP Classes.AddSubComponentsToLoaded. Source rtl/common/Classes.pas:6439. Prototype pending: nested routine has a parent-frame parameter."

procedure CheckSubComponents(Component: TComponent); // @nameonly @note "DCC32 MAP Classes.CheckSubComponents. Source rtl/common/Classes.pas:6447. Prototype pending: nested routine has a parent-frame parameter."

procedure SetSubComponentState(State: TComponentState; Add: Boolean); // @nameonly @note "DCC32 MAP Classes.SetSubComponentState. Source rtl/common/Classes.pas:6459. Prototype pending: nested routine has a parent-frame parameter."

function ComponentCreated: Boolean; // @nameonly @note "DCC32 MAP Classes.ComponentCreated. Source rtl/common/Classes.pas:6470. Prototype pending: nested routine has a parent-frame parameter."

function Recover(var Component: TComponent): Boolean; // @nameonly @note "DCC32 MAP Classes.Recover. Source rtl/common/Classes.pas:6475. Prototype pending: nested routine has a parent-frame parameter."

procedure CreateComponent; // @nameonly @note "DCC32 MAP Classes.CreateComponent. Source rtl/common/Classes.pas:6485. Prototype pending: nested routine has a parent-frame parameter."

procedure SetCompName; // @nameonly @note "DCC32 MAP Classes.SetCompName. Source rtl/common/Classes.pas:6515. Prototype pending: nested routine has a parent-frame parameter."

procedure FindExistingComponent; // @nameonly @note "DCC32 MAP Classes.FindExistingComponent. Source rtl/common/Classes.pas:6527. Prototype pending: nested routine has a parent-frame parameter."

procedure HandleException(E: Exception); // @nameonly @note "DCC32 MAP Classes.HandleException. Source rtl/common/Classes.pas:6761. Prototype pending: nested routine has a parent-frame parameter."

procedure SetIntIdent(Instance: TPersistent; PropInfo: Pointer; const Ident: AnsiString); // @nameonly @note "DCC32 MAP Classes.SetIntIdent. Source rtl/common/Classes.pas:6839. Prototype pending: nested routine has a parent-frame parameter."

procedure SetObjectIdent(Instance: TPersistent; PropInfo: Pointer; const Ident: AnsiString); // @nameonly @note "DCC32 MAP Classes.SetObjectIdent. Source rtl/common/Classes.pas:6852. Prototype pending: nested routine has a parent-frame parameter."

procedure SetVariantReference; // @nameonly @note "DCC32 MAP Classes.SetVariantReference. Source rtl/common/Classes.pas:6859. Prototype pending: nested routine has a parent-frame parameter."

procedure SetInterfaceReference; // @nameonly @note "DCC32 MAP Classes.SetInterfaceReference. Source rtl/common/Classes.pas:6864. Prototype pending: nested routine has a parent-frame parameter."

function FindUniqueName(const Name: AnsiString): AnsiString; // @nameonly @note "DCC32 MAP Classes.FindUniqueName. Source rtl/common/Classes.pas:6942. Prototype pending: nested routine has a parent-frame parameter."

procedure SkipList; // @nameonly @note "DCC32 MAP Classes.SkipList. Source rtl/common/Classes.pas:7164. Prototype pending: nested routine has a parent-frame parameter."

procedure SkipBinary(BytesPerUnit: Integer); // @nameonly @note "DCC32 MAP Classes.SkipBinary. Source rtl/common/Classes.pas:7170. Prototype pending: nested routine has a parent-frame parameter."

procedure SkipCollection; // @nameonly @note "DCC32 MAP Classes.SkipCollection. Source rtl/common/Classes.pas:7178. Prototype pending: nested routine has a parent-frame parameter."

procedure ReadCustomVariant; // @nameonly @note "DCC32 MAP Classes.ReadCustomVariant. Source rtl/common/Classes.pas:7378. Prototype pending: source type not found: Variant."

procedure InitThreadSynchronization; // @ida "void __usercall $name(void);" @note "DCC32 MAP Classes.InitThreadSynchronization. Source rtl/common/Classes.pas:9724."

function CheckSynchronize(Timeout: Integer): Boolean; // @ida "bool __usercall $name@<al>(__int32 Timeout@<eax>);" @note "DCC32 MAP Classes.CheckSynchronize. Source rtl/common/Classes.pas:9809."

procedure FreeIntConstList; // @ida "void __usercall $name(void);" @note "DCC32 MAP Classes.FreeIntConstList. Source rtl/common/Classes.pas:11334."

function StdWndProc(Window: Cardinal; Message, WParam: Longint; LParam: Longint): Longint; stdcall; // @ida "__int32 __stdcall $name(unsigned __int32 Window, __int32 Message, __int32 WParam, __int32 LParam);" @note "DCC32 MAP Classes.StdWndProc. Source rtl/common/Classes.pas:11573."

procedure MakeObjectInstance; // @nameonly @note "DCC32 MAP Classes.MakeObjectInstance. Source rtl/common/Classes.pas:11595. Prototype pending: unsupported source type TWndMethod: procedure(var Message: TMessage) of object."

procedure AllocateHWnd; // @nameonly @note "DCC32 MAP Classes.AllocateHWnd. Source rtl/common/Classes.pas:11651. Prototype pending: unsupported source type TWndMethod: procedure(var Message: TMessage) of object."

procedure DeallocateHWnd(Wnd: Cardinal); // @ida "void __usercall $name(unsigned __int32 Wnd@<eax>);" @note "DCC32 MAP Classes.DeallocateHWnd. Source rtl/common/Classes.pas:11674."

procedure FinalizeClasses; // @nameonly @note "DCC32 MAP Classes.Finalization. Prototype pending: no unique source declaration."

implementation
end.
