unit CommCtrl;

interface

uses Windows;

type
  HImageList = Cardinal;

procedure ResolveCommonControlsExports; // @addr 0x0041FB64 @note "Finds the loaded comctl32 module and resolves InitCommonControlsEx."
function CallTaskDialogIndirect(Config: Pointer; Button, RadioButton: ^Integer; VerificationChecked: ^LongBool): HResult; // @addr 0x0041FC6C @note "Resolves TaskDialogIndirect lazily; returns E_NOTIMPL if unavailable."

implementation
end.
