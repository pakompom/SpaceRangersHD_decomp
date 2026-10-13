unit SE_Garbage;
// Memory diagnostics. SE_Garbage ownership is inferred
// from the native aGalaxy dependency family beside FGInt/FGIntRSA and the
// process API units; the original discarded declarations remain unknown.
interface
procedure CheckMemoryUsage; // @addr $7B0A48
var
  PreviousVirtualUsageMB: Int64 = 0; // @addr $812EEC
  PreviousPhysicalUsageMB: Int64 = 0; // @addr $812EF4
  CheckingMemoryUsage: Boolean = False; // @addr $812EFC Recursive checks return immediately.
  LowMemoryWarningShown: Boolean = False; // @addr $812F00 At most one warning per process.

implementation
uses AclAPI, AccCtrl, PsAPI, TlHelp32, Windows, GR_Main, SysUtils, aGalaxy;

{ @routine $7B0A48 CheckMemoryUsage }
procedure CheckMemoryUsage;
var Usage: Int64;
  Changed: Boolean;
  Status: TMemoryStatusEx;

  // @nested $7B09E0 ShowLowMemoryWarning
  procedure ShowLowMemoryWarning(TextKey: WideString); // @addr $7B09E0 @note "Nested in CheckMemoryUsage; unused caller-popped static link."
  begin
    if LowMemoryWarningShown then Exit;
    if Galaxy = nil then Exit;
    LowMemoryWarningShown := True;
    Galaxy.ShowLocalizedWarning(TextKey);
  end;
begin
  if CheckingMemoryUsage then Exit;
  CheckingMemoryUsage := True;
  Changed := False;
  Status.Length := SizeOf(Status);
  GlobalMemoryStatusEx(Status);
  Usage := (Status.TotalVirtual - Status.AvailVirtual) shr 20;
  if (Usage > 512) and (Abs(Usage - PreviousVirtualUsageMB) > 256) then
  begin
    if PreviousVirtualUsageMB <> 0 then
    begin
      Changed := True;
      if Usage > PreviousVirtualUsageMB then AppendLogLineThreadSafe('Virtual memory usage is increasing (' + IntToStr(Usage) + ' MB)')
      else AppendLogLineThreadSafe('Virtual memory usage is decreasing (' + IntToStr(Usage) + ' MB)');
    end;
    PreviousVirtualUsageMB := Usage;
  end;
  if Status.AvailVirtual shr 20 < 100 then ShowLowMemoryWarning('Warning.LowVirtualMemory');
  Usage := (Status.TotalPhys - Status.AvailPhys) shr 20;
  if (Usage > 512) and (Abs(Usage - PreviousPhysicalUsageMB) > 256) then
  begin
    if PreviousPhysicalUsageMB <> 0 then
    begin
      Changed := True;
      if Usage > PreviousPhysicalUsageMB then AppendLogLineThreadSafe('Physical memory usage is increasing (' + IntToStr(Usage) + ' MB)')
      else AppendLogLineThreadSafe('Physical memory usage is decreasing (' + IntToStr(Usage) + ' MB)');
    end;
    PreviousPhysicalUsageMB := Usage;
  end;
  if Status.AvailPhys shr 20 < 100 then ShowLowMemoryWarning('Warning.LowPhysicalMemory');
  if Changed then LogMemoryUsage;
  CheckingMemoryUsage := False;
end;
{ @end $7B0A48 }

end.
