unit MultiMon;
// Unit bracket (inferred): .text 0x0041F3F0..0x0041FB27; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TMultiMonApi = (mmGetSystemMetrics, mmMonitorFromWindow, mmMonitorFromRect, mmMonitorFromPoint, mmGetMonitorInfo, mmGetMonitorInfoA, mmGetMonitorInfoW, mmEnumDisplayMonitors); // @size 0x1

  TWinMonitorInfoA = record;

  TWinMonitorInfo = TWinMonitorInfoA;

  PMonitorInfoA = ^TWinMonitorInfo;

  PMonitorInfo = PMonitorInfoA;

  PMonitorInfoW = ^TWinMonitorInfo;

function InitAnApi(mmAPI: TMultiMonApi; ApiStub: Pointer; ApiName: AnsiString): Pointer; // @note "DCC32 MAP MultiMon.InitAnApi. Source rtl/win/MultiMon.pas:210."

function _GetSystemMetrics(nIndex: Integer): Integer; stdcall; // @note "DCC32 MAP MultiMon._GetSystemMetrics. Source rtl/win/MultiMon.pas:233."

function xMonitorFromRect(lprcScreenCoords: PRect; dwFlags: DWord): Cardinal; stdcall; // @note "DCC32 MAP MultiMon.xMonitorFromRect. Source rtl/win/MultiMon.pas:259."

function xMonitorFromWindow(hWnd: Cardinal; dwFlags: DWord): Cardinal; stdcall; // @note "DCC32 MAP MultiMon.xMonitorFromWindow. Source rtl/win/MultiMon.pas:277."

function xMonitorFromPoint(ptScreenCoords: TPoint; dwFlags: DWord): Cardinal; // @nameonly @note "DCC32 MAP MultiMon.xMonitorFromPoint. Source rtl/win/MultiMon.pas:300. Prototype pending: RET mismatch: expected 8, native [12]."

function xGetMonitorInfo(hMonitor: Cardinal; lpMonitorInfo: PMonitorInfo): Boolean; stdcall; // @note "DCC32 MAP MultiMon.xGetMonitorInfo. Source rtl/win/MultiMon.pas:318."

function xGetMonitorInfoA(hMonitor: Cardinal; lpMonitorInfo: PMonitorInfoA): Boolean; stdcall; // @note "DCC32 MAP MultiMon.xGetMonitorInfoA. Source rtl/win/MultiMon.pas:345."

function xGetMonitorInfoW(hMonitor: Cardinal; lpMonitorInfo: PMonitorInfoW): Boolean; stdcall; // @note "DCC32 MAP MultiMon.xGetMonitorInfoW. Source rtl/win/MultiMon.pas:372."

procedure xEnumDisplayMonitors; // @nameonly @note "DCC32 MAP MultiMon.xEnumDisplayMonitors. Source rtl/win/MultiMon.pas:400. Prototype pending: unsupported source type TMonitorEnumProc: function(hm: HMONITOR; dc: HDC; r: PRect; l: LPARAM): Boolean."

procedure InitMultiMonStubs; // @note "DCC32 MAP MultiMon.InitMultiMonStubs. Source rtl/win/MultiMon.pas:444."

implementation
end.
