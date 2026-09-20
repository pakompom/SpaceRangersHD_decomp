unit HelpIntfs;
// Unit bracket (inferred): .text 0x0041E190..0x0041F3ED; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x0087629C..0x008762A3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  THelpManager = class(TInterfacedObject) // @size 0x30
  public
    constructor Create; // @note "DCC32 MAP HelpIntfs.THelpManager.Create. Source rtl/common/HelpIntfs.pas:322."
    destructor Destroy; // @note "DCC32 MAP HelpIntfs.THelpManager.Destroy. Source rtl/common/HelpIntfs.pas:331."
    procedure DoSoftShutDown; // @note "DCC32 MAP HelpIntfs.THelpManager.DoSoftShutDown. Source rtl/common/HelpIntfs.pas:368."
    function CallSpecialWinHelp(Handle: LongInt; const HelpFile: AnsiString; Command: Word; Data: LongInt): Boolean; // @note "DCC32 MAP HelpIntfs.THelpManager.CallSpecialWinHelp. Source rtl/common/HelpIntfs.pas:419."
    procedure ShowContextHelp(const ContextID: Longint; const HelpFileName: AnsiString); // @note "DCC32 MAP HelpIntfs.THelpManager.ShowContextHelp. Source rtl/common/HelpIntfs.pas:547."
    procedure Release(const ViewerID: Integer); // @note "DCC32 MAP HelpIntfs.THelpManager.Release. Source rtl/common/HelpIntfs.pas:760."
  end;

procedure EnsureHelpManager; // @note "DCC32 MAP HelpIntfs.EnsureHelpManager. Source rtl/common/HelpIntfs.pas:284."

procedure GetHelpSystem; // @nameonly @note "DCC32 MAP HelpIntfs.GetHelpSystem. Prototype pending: no unique source declaration."

procedure DefaultContextHelp(const ContextId: LongInt; const HelpFileName: AnsiString); // @nameonly @note "DCC32 MAP HelpIntfs.DefaultContextHelp. Source rtl/common/HelpIntfs.pas:559. Prototype pending: nested routine has a parent-frame parameter."

implementation
end.
