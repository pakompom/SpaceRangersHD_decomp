unit DwmApi;
// Unit bracket (inferred): .text 0x0042A244..0x0042A3D7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008753CC..0x008753D3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Windows, UxTheme;

// These are Delphi register-convention wrappers around lazily loaded stdcall
// DLL entry points. An unavailable entry point returns E_NOTIMPL.
function DwmExtendFrameIntoClientArea(hWnd: Cardinal; const pMarInset: TMargins): HResult; // @ida "HResult __usercall $name@<eax>(unsigned __int32 hWnd@<eax>, const TMargins *pMarInset@<edx>);"
function DwmIsCompositionEnabled(out pfEnabled: LongBool): HResult;
function DwmCompositionEnabled: Boolean;

procedure FinalizeDwmApi; // @nameonly @note "DCC32 MAP DwmApi.Finalization. Prototype pending: no unique source declaration."

implementation
end.
