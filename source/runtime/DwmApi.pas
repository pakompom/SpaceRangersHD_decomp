unit DwmApi;

interface

uses Windows, UxTheme;

// These are Delphi register-convention wrappers around lazily loaded stdcall
// DLL entry points. An unavailable entry point returns E_NOTIMPL.
function DwmExtendFrameIntoClientArea(hWnd: Cardinal; const pMarInset: TMargins): HResult; // @ida "HResult __usercall $name@<eax>(unsigned __int32 hWnd@<eax>, const TMargins *pMarInset@<edx>);"
function DwmIsCompositionEnabled(out pfEnabled: LongBool): HResult;
function DwmCompositionEnabled: Boolean;

procedure FinalizeDwmApi; // @nameonly

implementation
end.
