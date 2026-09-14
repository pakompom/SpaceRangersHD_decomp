unit EC_Thread;
// Unit bracket (inferred): .text 0x007F851C..0x007F8C27; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, SyncObjs;

type
  TThreadEC = class(TObjectEx) // @size 0x2C
  public
    Lock: TCriticalSection; // @offset 0x4
    ThreadHandle: Cardinal; // @offset 0x8
    ThreadId: Cardinal; // @offset 0xC
    Priority: Byte; // @offset 0x10
    StopRequested: Boolean; // @offset 0x11
    StopEvent: Cardinal; // @offset 0x14
    // Set/cleared by two helpers; its purpose is unresolved.
    Flag18: Boolean; // @offset $18
    ShutdownEvent: Cardinal; // @offset 0x1C
    StartEvent: Cardinal; // @offset 0x20
    RunningEvent: Cardinal; // @offset 0x24
    IdleEvent: Cardinal; // @offset 0x28

    constructor Create; // @addr 0x7F85E0 @ida "TThreadEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7F8790 @ida "void __usercall $name(TThreadEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure ProcessRequests; // @addr 0x7F8880
    procedure Execute; virtual; // @addr 0x7F89F0 @slot 0x00
    procedure SetPriority(Value: Byte); // @addr 0x7F8A10
    procedure SetFlag18; // @addr $7F8A4C
    procedure ClearFlag18; // @addr $7F8A60
    procedure RequestStop; // @addr 0x7F8A74
    function IsStopRequested: Boolean; // @addr 0x7F8AA8
    procedure SetStopRequested(Value: Boolean); // @addr 0x7F8AD8
    procedure Start; // @addr 0x7F8B24 @note "Schedules Execute on the existing OS thread; does nothing while a run is pending or active."
    function IsRunning: Boolean; // @addr 0x7F8BB4
    function WaitForIdle(TimeoutMs: Cardinal): Boolean; // @addr 0x7F8BF4 @note "False only on timeout; a wait failure also returns true."
  end;

function ThreadEntryEC(Thread: Pointer): Integer; // @addr 0x7F8578

const
  // Indices into ThreadPriorityValues, not Win32 priority values.
  ThreadPriorityLowest = 1;
  ThreadPriorityAboveNormal = 4;

  ThreadPriorityValues: array[0..6] of Integer = (-15, -2, -1, 0, 1, 2, 15); // @addr $881C24

implementation

uses Windows, SysUtils, GR_Main;

{ @routine $7F8578 ThreadEntryEC }
function ThreadEntryEC(Thread: Pointer): Integer;
begin
  try
    TThreadEC(Thread).ProcessRequests;
  finally
    if TThreadEC(Thread).ThreadHandle <> 0 then
    begin
      CloseHandle(TThreadEC(Thread).ThreadHandle);
      TThreadEC(Thread).ThreadHandle := 0;
    end;
    TThreadEC(Thread).ThreadId := 0;
  end;
  Result := 0;
end;
{ @end $7F8578 }

{ @routine $7F85E0 TThreadEC_Create }
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
{ @end $7F85E0 }

{ @routine $7F8790 TThreadEC_Destroy }
destructor TThreadEC.Destroy;
begin
  if ShutdownEvent <> 0 then
  begin
    SetEvent(ShutdownEvent);
    WaitForSingleObject(ThreadHandle, INFINITE);
  end;
  if IdleEvent <> 0 then
  begin CloseHandle(IdleEvent); IdleEvent := 0 end;
  if StartEvent <> 0 then
  begin CloseHandle(StartEvent); StartEvent := 0 end;
  if RunningEvent <> 0 then
  begin CloseHandle(RunningEvent); RunningEvent := 0 end;
  if ShutdownEvent <> 0 then
  begin CloseHandle(ShutdownEvent); ShutdownEvent := 0 end;
  if StopEvent <> 0 then
  begin CloseHandle(StopEvent); StopEvent := 0 end;
  Lock.Free;
  inherited Destroy;
end;
{ @end $7F8790 }

{ @routine $7F8880 TThreadEC_ProcessRequests }
procedure TThreadEC.ProcessRequests;
var Events: array[0..1] of THandle;
    WaitResult: Cardinal;
begin
  Events[0] := ShutdownEvent;
  Events[1] := StartEvent;
  while True do
  begin
    WaitResult := WaitForMultipleObjects(Length(Events), @Events, False, INFINITE);
    if WaitResult <> WAIT_OBJECT_0 + 1 then Break;
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
{ @end $7F8880 }

{ @routine $7F89F0 TThreadEC_Execute }
procedure TThreadEC.Execute;
begin
  while not IsStopRequested do SysUtils.Sleep(100);
end;
{ @end $7F89F0 }

{ @routine $7F8A10 TThreadEC_SetPriority }
procedure TThreadEC.SetPriority(Value: Byte);
begin
  Priority := Value;
  if ThreadHandle <> 0 then SetThreadPriority(ThreadHandle, ThreadPriorityValues[Value]);
end;
{ @end $7F8A10 }

{ @routine $7F8A4C TThreadEC_SetFlag18 }
procedure TThreadEC.SetFlag18;
begin
  Flag18 := True;
end;
{ @end $7F8A4C }

{ @routine $7F8A60 TThreadEC_ClearFlag18 }
procedure TThreadEC.ClearFlag18;
begin
  Flag18 := False;
end;
{ @end $7F8A60 }

{ @routine $7F8A74 TThreadEC_RequestStop }
procedure TThreadEC.RequestStop;
begin
  Lock.Enter;
  StopRequested := True;
  SetEvent(StopEvent);
  Lock.Leave;
end;
{ @end $7F8A74 }

{ @routine $7F8AA8 TThreadEC_IsStopRequested }
function TThreadEC.IsStopRequested: Boolean;
begin
  Lock.Enter;
  Result := StopRequested;
  Lock.Leave;
end;
{ @end $7F8AA8 }

{ @routine $7F8AD8 TThreadEC_SetStopRequested }
procedure TThreadEC.SetStopRequested(Value: Boolean);
begin
  if Value then RequestStop
  else
  begin
    Lock.Enter;
    StopRequested := False;
    ResetEvent(StopEvent);
    Lock.Leave;
  end;
end;
{ @end $7F8AD8 }

{ @routine $7F8B24 TThreadEC_Start }
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
{ @end $7F8B24 }

{ @routine $7F8BB4 TThreadEC_IsRunning }
function TThreadEC.IsRunning: Boolean;
begin
  Lock.Enter;
  Result := WaitForSingleObject(IdleEvent, 0) = WAIT_TIMEOUT;
  Lock.Leave;
end;
{ @end $7F8BB4 }

{ @routine $7F8BF4 TThreadEC_WaitForIdle }
function TThreadEC.WaitForIdle(TimeoutMs: Cardinal): Boolean;
begin
  if WaitForSingleObject(IdleEvent, TimeoutMs) = WAIT_TIMEOUT then Result := False
  else Result := True;
end;
{ @end $7F8BF4 }

end.
