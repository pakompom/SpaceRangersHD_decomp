unit Dialogs;
// Unit bracket (inferred): .text 0x0042E5BC..0x004300E3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008754B8..0x008754B8; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TCommonDialog = class(TComponent) // @size 0x60
  public
    constructor Create(AOwner: TComponent); override; // @ida "TCommonDialog * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TComponent *AOwner@<ecx>);" @note "DCC32 MAP Dialogs.TCommonDialog.Create. Source vcl/Dialogs.pas:1090." @slot 0x2C
    destructor Destroy; // @ida "void __usercall $name(TCommonDialog *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Dialogs.TCommonDialog.Destroy. Source vcl/Dialogs.pas:1102."
    function MessageHook(var Msg: TMessage): Boolean; virtual; // @ida "bool __usercall $name@<al>(TCommonDialog *Self@<eax>, TMessage *Msg@<edx>);" @note "DCC32 MAP Dialogs.TCommonDialog.MessageHook. Source vcl/Dialogs.pas:1131." @slot 0x34
    procedure DefaultHandler(Message: Pointer); // @ida "void __usercall $name(TCommonDialog *Self@<eax>, void * Message@<edx>);" @note "DCC32 MAP Dialogs.TCommonDialog.DefaultHandler. Source vcl/Dialogs.pas:1141."
    procedure MainWndProc(var Message: TMessage); // @ida "void __usercall $name(TCommonDialog *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Dialogs.TCommonDialog.MainWndProc. Source vcl/Dialogs.pas:1149."
    procedure WMInitDialog(var Message: TWMInitDialog); // @ida "void __usercall $name(TCommonDialog *Self@<eax>, TWMInitDialog *Message@<edx>);" @note "DCC32 MAP Dialogs.TCommonDialog.WMInitDialog. Source vcl/Dialogs.pas:1169."
    procedure WMNCDestroy(var Message: TWMNCDestroy); // @ida "void __usercall $name(TCommonDialog *Self@<eax>, TWMNCDestroy *Message@<edx>);" @note "DCC32 MAP Dialogs.TCommonDialog.WMNCDestroy. Source vcl/Dialogs.pas:1177."
    function TaskModalDialog(DialogFunc: Pointer; DialogData: Pointer): LongBool; virtual; // @ida "__int32 __usercall $name@<eax>(TCommonDialog *Self@<eax>, void * DialogFunc@<edx>, void * DialogData@<ecx>);" @note "DCC32 MAP Dialogs.TCommonDialog.TaskModalDialog. Source vcl/Dialogs.pas:1183." @slot 0x38
    procedure DoClose; // @ida "void __usercall $name(TCommonDialog *Self@<eax>);" @note "DCC32 MAP Dialogs.TCommonDialog.DoClose. Source vcl/Dialogs.pas:1217."
    procedure DoShow; // @ida "void __usercall $name(TCommonDialog *Self@<eax>);" @note "DCC32 MAP Dialogs.TCommonDialog.DoShow. Source vcl/Dialogs.pas:1222."
  end;

procedure ShowMessage(const Message: AnsiString); // @addr 0x42F7E0 @note "Calls the message-dialog implementation with default X/Y positions (-1, -1). Returns after the dialog closes."

procedure InitGlobals; // @ida "void __usercall $name(void);" @note "DCC32 MAP Dialogs.InitGlobals. Source vcl/Dialogs.pas:4835."

procedure FinalizeDialogs; // @nameonly @note "DCC32 MAP Dialogs.Finalization. Prototype pending: no unique source declaration."

implementation
end.
