unit Dialogs;

interface

type
  TCommonDialog = class(TComponent) // @size 0x60
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    function MessageHook(var Msg: TMessage): Boolean; virtual; // @slot 0x34
    procedure DefaultHandler(Message: Pointer);
    procedure MainWndProc(var Message: TMessage);
    procedure WMInitDialog(var Message: TWMInitDialog);
    procedure WMNCDestroy(var Message: TWMNCDestroy);
    function TaskModalDialog(DialogFunc: Pointer; DialogData: Pointer): LongBool; virtual; // @slot 0x38
    procedure DoClose;
    procedure DoShow;
  end;

procedure ShowMessage(const Message: AnsiString); // @addr 0x0042F7E0 @note "Calls the message-dialog implementation with default X/Y positions (-1, -1). Returns after the dialog closes."

procedure InitGlobals;

procedure FinalizeDialogs; // @nameonly

implementation
end.
