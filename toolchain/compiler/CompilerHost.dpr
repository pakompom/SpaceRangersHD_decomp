program CompilerHost;

{$APPTYPE CONSOLE}

uses Windows;

var
  Directory, CommandLine, LogName: string;
  Startup: TStartupInfo;
  Process: TProcessInformation;
  Security: TSecurityAttributes;
  LogFile: THandle;
  Status: DWORD;
begin
  Writeln('READY');
  Flush(Output);
  while not Eof(Input) do
  begin
    Readln(Directory);
    if Directory = '' then Break;
    Readln(CommandLine);
    Readln(LogName);
    FillChar(Security, SizeOf(Security), 0);
    Security.nLength := SizeOf(Security);
    Security.bInheritHandle := True;
    LogFile := CreateFile(PChar(LogName), GENERIC_WRITE, FILE_SHARE_READ,
      @Security, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if LogFile = INVALID_HANDLE_VALUE then
      Status := GetLastError
    else
    begin
      FillChar(Startup, SizeOf(Startup), 0);
      Startup.cb := SizeOf(Startup);
      Startup.dwFlags := STARTF_USESTDHANDLES;
      Startup.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
      Startup.hStdOutput := LogFile;
      Startup.hStdError := LogFile;
      if CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil,
        PChar(Directory), Startup, Process) then
      begin
        if WaitForSingleObject(Process.hProcess, 120000) = WAIT_TIMEOUT then
        begin
          TerminateProcess(Process.hProcess, 124);
          WaitForSingleObject(Process.hProcess, INFINITE);
        end;
        GetExitCodeProcess(Process.hProcess, Status);
        CloseHandle(Process.hThread);
        CloseHandle(Process.hProcess);
      end
      else Status := GetLastError;
      CloseHandle(LogFile);
    end;
    Writeln(Status);
    Flush(Output);
  end;
end.
