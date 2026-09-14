unit MMSystem;

interface

type
  TFNTimeCallBack = procedure(TimerId, Message, User, Param1, Param2: Cardinal); stdcall;

const
  TIME_PERIODIC = $0001;
  TIME_CALLBACK_EVENT_SET = $0010;

function timeBeginPeriod(Period: Cardinal): Cardinal; stdcall;
  external 'winmm.dll' name 'timeBeginPeriod'; // @addr $45E7C0
function timeEndPeriod(Period: Cardinal): Cardinal; stdcall;
  external 'winmm.dll' name 'timeEndPeriod'; // @addr $45E7C8
function timeGetTime: Cardinal; stdcall;
  external 'winmm.dll' name 'timeGetTime'; // @addr 0x45E7D0
function timeKillEvent(TimerId: Cardinal): Cardinal; stdcall;
  external 'winmm.dll' name 'timeKillEvent'; // @addr $45E7D8
function timeSetEvent(Delay, Resolution: Cardinal; Callback: TFNTimeCallBack; User, Flags: Cardinal): Cardinal; stdcall;
  external 'winmm.dll' name 'timeSetEvent'; // @addr $45E7E0

implementation
end.
