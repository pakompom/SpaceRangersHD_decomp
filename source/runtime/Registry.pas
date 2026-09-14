unit Registry;
// Unit bracket (inferred): .text 0x0041D5DC..0x0041DBF0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TRegistry = class(TObject) // @size 0x1C
  public
    constructor Create; // @addr $41D6AC @ida "TRegistry *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);" @note "No-argument overload: HKCU, KEY_ALL_ACCESS and lazy writes."
    property RootKey: Cardinal write SetRootKey;
    function KeyExists(const Key: AnsiString): Boolean; // @addr $41DB7C
    function GetKey(const Key: AnsiString): Cardinal; // @addr $41DAE4 @note "Private SDK helper used by KeyExists; preserves the current key."
    function GetBaseKey(Relative: Boolean): Cardinal; // @addr $41D79C
    procedure CloseKey; // @ida "void __usercall $name(TRegistry *Self@<eax>);" @note "DCC32 MAP Registry.TRegistry.CloseKey. Source rtl/common/Registry.pas:214."
    procedure SetRootKey(Value: Cardinal); // @ida "void __usercall $name(TRegistry *Self@<eax>, unsigned __int32 Value@<edx>);" @note "DCC32 MAP Registry.TRegistry.SetRootKey. Source rtl/common/Registry.pas:226."
    procedure ChangeKey(Value: Cardinal; const Path: AnsiString); // @ida "void __usercall $name(TRegistry *Self@<eax>, unsigned __int32 Value@<edx>, char * Path@<ecx>);" @note "DCC32 MAP Registry.TRegistry.ChangeKey. Source rtl/common/Registry.pas:240."
    function OpenKeyReadOnly(const Key: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(TRegistry *Self@<eax>, char * Key@<edx>);" @note "DCC32 MAP Registry.TRegistry.OpenKeyReadOnly. Source rtl/common/Registry.pas:302."
    function GetDataInfo(const ValueName: AnsiString; var Value: TRegDataInfo): Boolean; // @ida "bool __usercall $name@<al>(TRegistry *Self@<eax>, char * ValueName@<edx>, TRegDataInfo *Value@<ecx>);" @note "DCC32 MAP Registry.TRegistry.GetDataInfo. Source rtl/common/Registry.pas:443."
    function GetDataSize(const ValueName: AnsiString): Integer; // @ida "__int32 __usercall $name@<eax>(TRegistry *Self@<eax>, char * ValueName@<edx>);" @note "DCC32 MAP Registry.TRegistry.GetDataSize. Source rtl/common/Registry.pas:453."
    function ReadString(const Name: AnsiString): AnsiString; // @ida "void __usercall $name(TRegistry *Self@<eax>, char * Name@<edx>, char * *Result@<ecx>);" @note "DCC32 MAP Registry.TRegistry.ReadString. Source rtl/common/Registry.pas:481."
    function GetData(const Name: AnsiString; Buffer: Pointer; BufSize: Integer; var RegData: TRegDataType): Integer; // @ida "__int32 __userpurge $name@<eax>(TRegistry *Self@<eax>, char * Name@<edx>, void * Buffer@<ecx>, __int32 BufSize@<^4>, TRegDataType *RegData@<^0>);" @note "DCC32 MAP Registry.TRegistry.GetData. Source rtl/common/Registry.pas:618."
  end;

  TRegDataInfo = record;

  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary); // @size 0x1

function IsRelative(const Value: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(char * Value@<eax>);" @note "DCC32 MAP Registry.IsRelative. Source rtl/common/Registry.pas:169."

implementation
end.
