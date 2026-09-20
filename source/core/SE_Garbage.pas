unit SE_Garbage;
// Memory diagnostics at $86E0F0..$86E456. SE_Garbage ownership is inferred
// from the native aGalaxy dependency family beside FGInt/FGIntRSA and the
// process API units; the original discarded declarations remain unknown.
interface
procedure CheckMemoryUsage; // @addr $86E158
var
  PreviousVirtualUsageMB: Int64 = 0; // @addr $883074
  PreviousPhysicalUsageMB: Int64 = 0; // @addr $88307C
  CheckingMemoryUsage: Boolean = False; // @addr $883084 Recursive checks return immediately.
  LowMemoryWarningShown: Boolean = False; // @addr $883088 At most one warning per process.

implementation
uses AclAPI, AccCtrl, PsAPI, TlHelp32, Windows, GR_Main, SysUtils, aGalaxy;





{ @routine $86E158 CheckMemoryUsage }
procedure CheckMemoryUsage;
var Usage: Int64;
  Changed: Boolean;
  Reserved: array[0..6] of Byte; // Native local storage between the flag and the status record.
  Status: TMemoryStatusEx;

  // @nested $86E0F0 ShowLowMemoryWarning
  procedure ShowLowMemoryWarning(TextKey: WideString); // @addr $86E0F0 @note "Nested in CheckMemoryUsage; unused caller-popped static link."
  begin
    if (not LowMemoryWarningShown) and (Galaxy <> nil) then begin
      LowMemoryWarningShown := True;
      Galaxy.ShowLocalizedWarning(TextKey);
    end;
  end;
begin
  if not CheckingMemoryUsage then begin
    CheckingMemoryUsage := True;
    Changed := False;
    Status.Length := SizeOf(Status);
    GlobalMemoryStatusEx(Status);
    Usage := (Status.TotalVirtual - Status.AvailVirtual) shr 20;
    if (Usage > 512) and (Abs(Usage - PreviousVirtualUsageMB) > 256) then begin
      if PreviousVirtualUsageMB <> 0 then begin
        Changed := True;
        if Usage > PreviousVirtualUsageMB then AppendLogLineThreadSafe('Virtual memory usage is increasing (' + IntToStr(Usage) + ' MB)')
        else AppendLogLineThreadSafe('Virtual memory usage is decreasing (' + IntToStr(Usage) + ' MB)');
      end;
      PreviousVirtualUsageMB := Usage;
    end;
    if Status.AvailVirtual shr 20 < 100 then ShowLowMemoryWarning('Warning.LowVirtualMemory');
    Usage := (Status.TotalPhys - Status.AvailPhys) shr 20;
    if (Usage > 512) and (Abs(Usage - PreviousPhysicalUsageMB) > 256) then begin
      if PreviousPhysicalUsageMB <> 0 then begin
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
end;
{ @end $86E158 }

end.
