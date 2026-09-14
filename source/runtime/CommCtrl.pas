unit CommCtrl;
// Unit bracket (inferred): .text 0x0041FB64..0x0041FCE3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Windows;

type
  HImageList = Cardinal;

procedure ResolveCommonControlsExports; // @addr 0x41FB64 @note "Finds the loaded comctl32 module and resolves InitCommonControlsEx."
function CallTaskDialogIndirect(Config: Pointer; Button, RadioButton: ^Integer; VerificationChecked: ^LongBool): HResult; // @addr 0x41FC6C @note "Resolves TaskDialogIndirect lazily; returns E_NOTIMPL if unavailable."

implementation
end.
