unit SE_Garbage;
// Memory diagnostics at $8138CC..$813C32. SE_Garbage ownership is inferred
// from the native aGalaxy dependency family beside FGInt/FGIntRSA and the
// process API units; the original discarded declarations remain unknown.
interface
procedure CheckMemoryUsage; // @addr $813934
var
  PreviousVirtualUsageMB: Int64 = 0; // @addr $88203C
  PreviousPhysicalUsageMB: Int64 = 0; // @addr $882044
  CheckingMemoryUsage: Boolean = False; // @addr $88204C Recursive checks return immediately.
  LowMemoryWarningShown: Boolean = False; // @addr $882050 At most one warning per process.

implementation
uses AclAPI, AccCtrl, PsAPI, TlHelp32, Windows, GR_Main, SysUtils, aGalaxy;





{ @routine $813934 CheckMemoryUsage }
procedure CheckMemoryUsage;
var Usage: Int64;
  Changed: Boolean;
  Reserved: array[0..6] of Byte; // Native local storage between the flag and the status record.
  Status: TMemoryStatusEx;

  // @nested $8138CC ShowLowMemoryWarning
  procedure ShowLowMemoryWarning(TextKey: WideString); // @addr $8138CC @ida "void __usercall $name(unsigned __int16 *TextKey@<eax>, void *ParentFrame@<^0>);" @note "Nested in CheckMemoryUsage; unused caller-popped static link."
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
{ @end $813934 }

end.
