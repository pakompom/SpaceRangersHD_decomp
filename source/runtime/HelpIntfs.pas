unit HelpIntfs;
// Unit bracket (inferred): .text 0x0041E190..0x0041F3ED; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x0087529C..0x008752A3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  THelpManager = class(TInterfacedObject) // @size 0x30
  public
    constructor Create; // @ida "THelpManager * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);" @note "DCC32 MAP HelpIntfs.THelpManager.Create. Source rtl/common/HelpIntfs.pas:322."
    destructor Destroy; // @ida "void __usercall $name(THelpManager *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP HelpIntfs.THelpManager.Destroy. Source rtl/common/HelpIntfs.pas:331."
    procedure DoSoftShutDown; // @ida "void __usercall $name(THelpManager *Self@<eax>);" @note "DCC32 MAP HelpIntfs.THelpManager.DoSoftShutDown. Source rtl/common/HelpIntfs.pas:368."
    function CallSpecialWinHelp(Handle: LongInt; const HelpFile: AnsiString; Command: Word; Data: LongInt): Boolean; // @ida "bool __userpurge $name@<al>(THelpManager *Self@<eax>, __int32 Handle@<edx>, char * HelpFile@<ecx>, unsigned __int16 Command@<^4>, __int32 Data@<^0>);" @note "DCC32 MAP HelpIntfs.THelpManager.CallSpecialWinHelp. Source rtl/common/HelpIntfs.pas:419."
    procedure ShowContextHelp(const ContextID: Longint; const HelpFileName: AnsiString); // @ida "void __usercall $name(THelpManager *Self@<eax>, __int32 ContextID@<edx>, char * HelpFileName@<ecx>);" @note "DCC32 MAP HelpIntfs.THelpManager.ShowContextHelp. Source rtl/common/HelpIntfs.pas:547."
    procedure Release(const ViewerID: Integer); // @ida "void __usercall $name(THelpManager *Self@<eax>, __int32 ViewerID@<edx>);" @note "DCC32 MAP HelpIntfs.THelpManager.Release. Source rtl/common/HelpIntfs.pas:760."
  end;

procedure EnsureHelpManager; // @ida "void __usercall $name(void);" @note "DCC32 MAP HelpIntfs.EnsureHelpManager. Source rtl/common/HelpIntfs.pas:284."

procedure GetHelpSystem; // @nameonly @note "DCC32 MAP HelpIntfs.GetHelpSystem. Prototype pending: no unique source declaration."

procedure DefaultContextHelp(const ContextId: LongInt; const HelpFileName: AnsiString); // @nameonly @note "DCC32 MAP HelpIntfs.DefaultContextHelp. Source rtl/common/HelpIntfs.pas:559. Prototype pending: nested routine has a parent-frame parameter."

implementation
end.
