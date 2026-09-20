unit ExtCtrls;
// Unit bracket (inferred): .text 0x0042D5B0..0x0042E58B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TTimer = class(TComponent) // @size 0x44
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP ExtCtrls.TTimer.Create. Source vcl/ExtCtrls.pas:2208." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP ExtCtrls.TTimer.Destroy. Source vcl/ExtCtrls.pas:2221."
    procedure WndProc(var Msg: TMessage); // @note "DCC32 MAP ExtCtrls.TTimer.WndProc. Source vcl/ExtCtrls.pas:2234."
    procedure UpdateTimer; // @note "DCC32 MAP ExtCtrls.TTimer.UpdateTimer. Source vcl/ExtCtrls.pas:2247."
    procedure SetOnTimer; // @nameonly @note "DCC32 MAP ExtCtrls.TTimer.SetOnTimer. Source vcl/ExtCtrls.pas:2273. Prototype pending: unsupported source type TNotifyEvent: procedure(Sender: TObject) of object."
  end;

implementation
end.
