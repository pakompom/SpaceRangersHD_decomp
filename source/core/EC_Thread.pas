unit EC_Thread;

interface

uses EC_Struct, SyncObjs;

type
  // Indices into ThreadPriorityValues, in ascending Win32 scheduling priority.
  TThreadPriorityEC = (
    priority_idle, priority_lowest, priority_below_normal,
    priority_normal, priority_above_normal, priority_highest,
    priority_time_critical
  ); // @size $01

  TThreadEC = class(TObjectEx) // @size 0x2C
  public
    Lock: TCriticalSection; // @offset 0x4
    ThreadHandle: Cardinal; // @offset 0x8
    ThreadId: Cardinal; // @offset 0xC
    Priority: TThreadPriorityEC; // @offset 0x10
    StopRequested: Boolean; // @offset 0x11
    StopEvent: Cardinal; // @offset 0x14
    // TCacheLoader.Execute checks this between loads; the base scheduler does not.
    PauseRequested: Boolean; // @offset $18 Cooperative pause request, not OS thread suspension.
    ShutdownEvent: Cardinal; // @offset 0x1C
    StartEvent: Cardinal; // @offset 0x20
    RunningEvent: Cardinal; // @offset 0x24
    IdleEvent: Cardinal; // @offset 0x28

    constructor Create; // @addr 0x004D41FC
    destructor Destroy; override; // @addr 0x004D4374
    procedure ProcessRequests; // @addr 0x004D4414
    procedure Execute; virtual; // @addr 0x004D4580 @slot 0x00
    procedure SetPriority(Value: TThreadPriorityEC); // @addr 0x004D459C
    procedure RequestPause; // @addr $4D45B8
    procedure ClearPauseRequest; // @addr $4D45C0
    procedure RequestStop; // @addr 0x004D45C8
    function IsStopRequested: Boolean; // @addr 0x004D45EC
    procedure SetStopRequested(Value: Boolean); // @addr 0x004D460C
    procedure Start; // @addr 0x004D463C @note "Schedules Execute on the existing OS thread; does nothing while a run is pending or active."
    function IsRunning: Boolean; // @addr 0x004D46CC
    function WaitForIdle(TimeoutMs: Cardinal): Boolean; // @addr 0x004D46F8 @note "False only on timeout; a wait failure also returns true."
  end;

function ThreadEntryEC(Thread: Pointer): Integer; // @addr 0x004D4194

const
  ThreadPriorityValues: array[TThreadPriorityEC] of Integer = (-15, -2, -1, 0, 1, 2, 15); // @addr $80E74C

implementation

uses Windows, SysUtils, GR_Main;

{ @routine $4D4194 ThreadEntryEC }
function ThreadEntryEC(Thread: Pointer): Integer;
var Worker: TThreadEC absolute Thread;
begin
  try
    Worker.ProcessRequests;
  except
    on E: Exception do ;
  end;
  if Worker.ThreadHandle <> 0 then
  begin
    CloseHandle(Worker.ThreadHandle);
    Worker.ThreadHandle := 0;
  end;
  Worker.ThreadId := 0;
  Result := 0;
end;
{ @end $4D4194 }

{ @routine $4D41FC TThreadEC_Create }
constructor TThreadEC.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
  StopEvent := CreateEvent(nil, True, False, nil);
  if StopEvent = 0 then raise Exception.Create('TThreadEC.Create CreateEvent');
  ShutdownEvent := CreateEvent(nil, False, False, nil);
  if ShutdownEvent = 0 then raise Exception.Create('TThreadEC.Create CreateEvent');
  StartEvent := CreateEvent(nil, False, False, nil);
  if StartEvent = 0 then raise Exception.Create('TThreadEC.Create CreateEvent');
  RunningEvent := CreateEvent(nil, True, False, nil);
  if RunningEvent = 0 then raise Exception.Create('TThreadEC.Create CreateEvent');
  IdleEvent := CreateEvent(nil, True, True, nil);
  if IdleEvent = 0 then raise Exception.Create('TThreadEC.Create CreateEvent');
  ThreadHandle := BeginThread(nil, 0, @ThreadEntryEC, Self, CREATE_SUSPENDED, ThreadId);
  SetThreadPriority(ThreadHandle, THREAD_PRIORITY_NORMAL);
  ResumeThread(ThreadHandle);
end;
{ @end $4D41FC }

{ @routine $4D4374 TThreadEC_Destroy }
destructor TThreadEC.Destroy;
begin
  if ShutdownEvent <> 0 then
  begin
    SetEvent(ShutdownEvent);
    WaitForSingleObject(ThreadHandle, INFINITE);
  end;
  if IdleEvent <> 0 then
  begin
    CloseHandle(IdleEvent);
    IdleEvent := 0;
  end;
  if StartEvent <> 0 then
  begin
    CloseHandle(StartEvent);
    StartEvent := 0;
  end;
  if RunningEvent <> 0 then
  begin
    CloseHandle(RunningEvent);
    RunningEvent := 0;
  end;
  if ShutdownEvent <> 0 then
  begin
    CloseHandle(ShutdownEvent);
    ShutdownEvent := 0;
  end;
  if StopEvent <> 0 then
  begin
    CloseHandle(StopEvent);
    StopEvent := 0;
  end;
  Lock.Free;
  inherited Destroy;
end;
{ @end $4D4374 }

{ @routine $4D4414 TThreadEC_ProcessRequests }
procedure TThreadEC.ProcessRequests;
const
  ShutdownEventIndex = 0;
  StartEventIndex = 1;
var
  Events: array[0..1] of THandle;
  WaitResult: Cardinal;
begin
  Events[ShutdownEventIndex] := ShutdownEvent;
  Events[StartEventIndex] := StartEvent;
  while True do
  begin
    WaitResult := WaitForMultipleObjects(Length(Events), @Events, False, INFINITE);
    if WaitResult <> WAIT_OBJECT_0 + StartEventIndex then Break;
    Lock.Enter;
    try
      if not IsRunning then
      begin
        ResetEvent(StopEvent);
        StopRequested := False;
        ResetEvent(IdleEvent);
        SetEvent(RunningEvent);
      end;
    finally
      Lock.Leave;
    end;
    try
      Execute;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.Message);
        AppendLogLineThreadSafe('Thread exception');
        raise;
      end;
    end;
    Lock.Enter;
    try
      ResetEvent(RunningEvent);
      SetEvent(IdleEvent);
    finally
      Lock.Leave;
    end;
  end;
end;
{ @end $4D4414 }

{ @routine $4D4580 TThreadEC_Execute }
procedure TThreadEC.Execute;
begin
  while not IsStopRequested do SysUtils.Sleep(100);
end;
{ @end $4D4580 }

{ @routine $4D459C TThreadEC_SetPriority }
procedure TThreadEC.SetPriority(Value: TThreadPriorityEC);
begin
  Priority := Value;
  if ThreadHandle <> 0 then SetThreadPriority(ThreadHandle, ThreadPriorityValues[Value]);
end;
{ @end $4D459C }

{ @routine $4D45B8 TThreadEC_RequestPause }
procedure TThreadEC.RequestPause;
begin
  PauseRequested := True;
end;
{ @end $4D45B8 }

{ @routine $4D45C0 TThreadEC_ClearPauseRequest }
procedure TThreadEC.ClearPauseRequest;
begin
  PauseRequested := False;
end;
{ @end $4D45C0 }

{ @routine $4D45C8 TThreadEC_RequestStop }
procedure TThreadEC.RequestStop;
begin
  Lock.Enter;
  StopRequested := True;
  SetEvent(StopEvent);
  Lock.Leave;
end;
{ @end $4D45C8 }

{ @routine $4D45EC TThreadEC_IsStopRequested }
function TThreadEC.IsStopRequested: Boolean;
begin
  Lock.Enter;
  Result := StopRequested;
  Lock.Leave;
end;
{ @end $4D45EC }

{ @routine $4D460C TThreadEC_SetStopRequested }
procedure TThreadEC.SetStopRequested(Value: Boolean);
begin
  if Value then
  begin
    RequestStop;
    Exit;
  end;
  Lock.Enter;
  StopRequested := False;
  ResetEvent(StopEvent);
  Lock.Leave;
end;
{ @end $4D460C }

{ @routine $4D463C TThreadEC_Start }
procedure TThreadEC.Start;
begin
  Lock.Enter;
  try
    if IsRunning then Exit;
    ResetEvent(StopEvent);
    StopRequested := False;
    ResetEvent(IdleEvent);
    SetEvent(RunningEvent);
    SetEvent(StartEvent);
  finally
    Lock.Leave;
  end;
end;
{ @end $4D463C }

{ @routine $4D46CC TThreadEC_IsRunning }
function TThreadEC.IsRunning: Boolean;
begin
  Lock.Enter;
  Result := WaitForSingleObject(IdleEvent, 0) = WAIT_TIMEOUT;
  Lock.Leave;
end;
{ @end $4D46CC }

{ @routine $4D46F8 TThreadEC_WaitForIdle }
function TThreadEC.WaitForIdle(TimeoutMs: Cardinal): Boolean;
begin
  if WaitForSingleObject(IdleEvent, TimeoutMs) = WAIT_TIMEOUT then Result := False
  else Result := True;
end;
{ @end $4D46F8 }

end.
