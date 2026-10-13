unit MultiMon;

interface

type
  TMultiMonApi = (mmGetSystemMetrics, mmMonitorFromWindow, mmMonitorFromRect, mmMonitorFromPoint, mmGetMonitorInfo, mmGetMonitorInfoA, mmGetMonitorInfoW, mmEnumDisplayMonitors); // @size 0x1

  TWinMonitorInfoA = record;

  TWinMonitorInfo = TWinMonitorInfoA;

  PMonitorInfoA = ^TWinMonitorInfo;

  PMonitorInfo = PMonitorInfoA;

  PMonitorInfoW = ^TWinMonitorInfo;

function InitAnApi(mmAPI: TMultiMonApi; ApiStub: Pointer; ApiName: AnsiString): Pointer;

function _GetSystemMetrics(nIndex: Integer): Integer; stdcall;

function xMonitorFromRect(lprcScreenCoords: PRect; dwFlags: DWord): Cardinal; stdcall;

function xMonitorFromWindow(hWnd: Cardinal; dwFlags: DWord): Cardinal; stdcall;

function xMonitorFromPoint(ptScreenCoords: TPoint; dwFlags: DWord): Cardinal; // @nameonly

function xGetMonitorInfo(hMonitor: Cardinal; lpMonitorInfo: PMonitorInfo): Boolean; stdcall;

function xGetMonitorInfoA(hMonitor: Cardinal; lpMonitorInfo: PMonitorInfoA): Boolean; stdcall;

function xGetMonitorInfoW(hMonitor: Cardinal; lpMonitorInfo: PMonitorInfoW): Boolean; stdcall;

procedure xEnumDisplayMonitors; // @nameonly

procedure InitMultiMonStubs;

implementation
end.
