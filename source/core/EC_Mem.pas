unit EC_Mem;

interface

function AllocEC(ByteCount: Integer): Pointer; // @addr 0x007B0E74 @note "Uses the process heap; allocation failure can evict texture caches before raising."
function AllocClearEC(ByteCount: Integer): Pointer; // @addr 0x007B0FB8
function ReAllocREC(Data: Pointer; ByteCount: Integer): Pointer; // @addr 0x007B1100 @note "Nonpositive sizes free Data and return nil; allocation failure can evict texture caches."
procedure FreeEC(Data: Pointer); // @addr 0x007B1314
procedure FreeFromHeapEC(Heap: Cardinal; Data: Pointer); // @addr 0x007B1568
function AllocFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer; // @addr 0x007B1328 @note "Raises on allocation failure; does not evict caches."
function AllocClearFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer; // @addr 0x007B13C0 @note "Raises on allocation failure; does not evict caches."
function ReAllocFromHeapREC(Heap: Cardinal; Data: Pointer; ByteCount: Integer): Pointer; // @addr 0x007B145C @note "Nonpositive sizes free Data and return nil. Raises on allocation failure; does not evict caches."
// These stack-ABI accessors are handwritten assembly in the native unit.
// Integer(@PRecord(ByteOffset).Field) in callers derives a relative field offset
// without reading memory, preserving these native calls and their argument order.
function AddPointerOffset(Data: Pointer; ByteOffset: Integer): Pointer; cdecl; // @addr 0x007B1574
procedure WriteByteEC(Dest: Pointer; Value: Byte); cdecl; // @addr 0x007B1580
procedure WriteWordEC(Dest: Pointer; Value: Word); cdecl; // @addr 0x007B1590
procedure WriteIntegerEC(Dest: Pointer; Value: Integer); cdecl; // @addr 0x007B15A0
procedure WriteInt32EC(Dest: Pointer; Value: Integer); cdecl; // @addr 0x007B15B0
procedure WriteSingleEC(Dest: Pointer; Value: Single); cdecl; // @addr 0x007B15C0
procedure WriteDoubleEC(Dest: Pointer; Value: Double); cdecl; // @addr 0x007B15D0
function ReadByteEC(Source: Pointer): Byte; cdecl; // @addr 0x007B15E8
function ReadWideCharEC(Source: Pointer): WideChar; cdecl; // @addr 0x007B15F4
function ReadWordEC(Source: Pointer): Word; cdecl; // @addr 0x007B1600
function ReadDWordEC(Source: Pointer): Cardinal; cdecl; // @addr 0x007B160C
function ReadIntegerEC(Source: Pointer): Integer; cdecl; // @addr 0x007B1618
function ReadSingleEC(Source: Pointer): Single; cdecl; // @addr 0x007B1624
function ReadDoubleEC(Source: Pointer): Double; cdecl; // @addr 0x007B1630

implementation

uses GR_DX, GR_Main, SysUtils, Windows;

{ @routine $7B0E74 AllocEC }
function AllocEC(ByteCount: Integer): Pointer;
begin
  Result := HeapAlloc(GetProcessHeap, 0, ByteCount);
  if Result <> nil then Exit;
  AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
  EvictTextureCaches(True);
  Result := HeapAlloc(GetProcessHeap, 0, ByteCount);
  if Result <> nil then
  begin
    AppendLogLineThreadSafe('success');
    Exit;
  end;
  AppendLogLineThreadSafe('fail');
  LogMemoryUsage;
  raise Exception.Create('AllocEC. size=' + SysUtils.IntToStr(ByteCount));
end;
{ @end $7B0E74 }

{ @routine $7B0FB8 AllocClearEC }
function AllocClearEC(ByteCount: Integer): Pointer;
begin
  Result := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, ByteCount);
  if Result <> nil then Exit;
  AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
  EvictTextureCaches(True);
  Result := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, ByteCount);
  if Result <> nil then
  begin
    AppendLogLineThreadSafe('success');
    Exit;
  end;
  AppendLogLineThreadSafe('fail');
  LogMemoryUsage;
  raise Exception.Create('AllocClearEC. size=' + SysUtils.IntToStr(ByteCount));
end;
{ @end $7B0FB8 }

{ @routine $7B1100 ReAllocREC }
function ReAllocREC(Data: Pointer; ByteCount: Integer): Pointer;
var Memory: Pointer;
begin
  if (ByteCount <= 0) and (Data <> nil) then
  begin
    HeapFree(GetProcessHeap, 0, Data);
    Memory := nil;
  end
  else if ByteCount <= 0 then Memory := nil
  else if (ByteCount > 0) and (Data <> nil) then
  begin
    Memory := HeapReAlloc(GetProcessHeap, 0, Data, ByteCount);
    if Memory = nil then
    begin
      AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
      EvictTextureCaches(True);
      Memory := HeapReAlloc(GetProcessHeap, 0, Data, ByteCount);
      if Memory <> nil then AppendLogLineThreadSafe('success')
      else
      begin
        AppendLogLineThreadSafe('fail');
        LogMemoryUsage;
        raise Exception.Create('ReAllocREC. size=' + SysUtils.IntToStr(ByteCount));
      end;
    end;
  end
  else
  begin
    Memory := HeapAlloc(GetProcessHeap, 0, ByteCount);
    if Memory = nil then
    begin
      AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
      EvictTextureCaches(True);
      Memory := HeapAlloc(GetProcessHeap, 0, ByteCount);
      if Memory <> nil then AppendLogLineThreadSafe('success')
      else
      begin
        AppendLogLineThreadSafe('fail');
        LogMemoryUsage;
        raise Exception.Create('ReAllocREC. size=' + SysUtils.IntToStr(ByteCount));
      end;
    end;
  end;
  Result := Memory;
end;
{ @end $7B1100 }

{ @routine $7B1314 FreeEC }
procedure FreeEC(Data: Pointer);
begin HeapFree(GetProcessHeap, 0, Data) end;
{ @end $7B1314 }

{ @routine $7B1328 AllocFromHeapEC }
function AllocFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(Heap, 0, ByteCount);
  if Memory = nil then raise Exception.Create('AllocEC. size=' + SysUtils.IntToStr(ByteCount));
  Result := Memory;
end;
{ @end $7B1328 }

{ @routine $7B13C0 AllocClearFromHeapEC }
function AllocClearFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(Heap, HEAP_ZERO_MEMORY, ByteCount);
  if Memory = nil then raise Exception.Create('AllocClearEC. size=' + SysUtils.IntToStr(ByteCount));
  Result := Memory;
end;
{ @end $7B13C0 }

{ @routine $7B145C ReAllocFromHeapREC }
function ReAllocFromHeapREC(Heap: Cardinal; Data: Pointer; ByteCount: Integer): Pointer;

begin
  if (ByteCount <= 0) and (Data <> nil) then
  begin
    HeapFree(Heap, 0, Data);
    Data := nil;
  end
  else if ByteCount <= 0 then Data := nil
  else if (ByteCount > 0) and (Data <> nil) then
  begin
    Data := HeapReAlloc(Heap, 0, Data, ByteCount);
    if Data = nil then
    begin
      raise Exception.Create('ReAllocREC. size=' + SysUtils.IntToStr(ByteCount));
    end;
  end
  else
  begin
    Data := HeapAlloc(Heap, 0, ByteCount);
    if Data = nil then
    begin
      raise Exception.Create('ReAllocREC. size=' + SysUtils.IntToStr(ByteCount));
    end;
  end;
  Result := Data;
end;
{ @end $7B145C }

{ @routine $7B1568 FreeFromHeapEC }
procedure FreeFromHeapEC(Heap: Cardinal; Data: Pointer);
begin HeapFree(Heap, 0, Data) end;
{ @end $7B1568 }

{ @routine $7B1574 AddPointerOffset }
function AddPointerOffset(Data: Pointer; ByteOffset: Integer): Pointer; cdecl;
asm
  MOV EAX, Data
  ADD EAX, ByteOffset
end;
{ @end $7B1574 }

{ @routine $7B1580 WriteByteEC }
procedure WriteByteEC(Dest: Pointer; Value: Byte); cdecl;
asm
  MOV EDX, Dest
  MOV AL, Value
  MOV [EDX], AL
end;
{ @end $7B1580 }

{ @routine $7B1590 WriteWordEC }
procedure WriteWordEC(Dest: Pointer; Value: Word); cdecl;
asm
  MOV EDX, Dest
  MOV AX, Value
  MOV [EDX], AX
end;
{ @end $7B1590 }

{ @routine $7B15A0 WriteIntegerEC }
procedure WriteIntegerEC(Dest: Pointer; Value: Integer); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $7B15A0 }

{ @routine $7B15B0 WriteInt32EC }
procedure WriteInt32EC(Dest: Pointer; Value: Integer); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $7B15B0 }

{ @routine $7B15C0 WriteSingleEC }
procedure WriteSingleEC(Dest: Pointer; Value: Single); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $7B15C0 }

{ @routine $7B15D0 WriteDoubleEC }
procedure WriteDoubleEC(Dest: Pointer; Value: Double); cdecl;
asm
  PUSH EBX
  MOV EBX, Dest
  LEA EDX, Value
  MOV EAX, [EDX]
  MOV [EBX], EAX
  MOV EAX, [EDX + 4]
  MOV [EBX + 4], EAX
  POP EBX
end;
{ @end $7B15D0 }

{ @routine $7B15E8 ReadByteEC }
function ReadByteEC(Source: Pointer): Byte; cdecl;
asm
  MOV EAX, Source
  MOV AL, [EAX]
end;
{ @end $7B15E8 }

{ @routine $7B15F4 ReadWideCharEC }
function ReadWideCharEC(Source: Pointer): WideChar; cdecl;
asm
  MOV EAX, Source
  MOV AX, [EAX]
end;
{ @end $7B15F4 }

{ @routine $7B1600 ReadWordEC }
function ReadWordEC(Source: Pointer): Word; cdecl;
asm
  MOV EAX, Source
  MOV AX, [EAX]
end;
{ @end $7B1600 }

{ @routine $7B160C ReadDWordEC }
function ReadDWordEC(Source: Pointer): Cardinal; cdecl;
asm
  MOV EAX, Source
  MOV EAX, [EAX]
end;
{ @end $7B160C }

{ @routine $7B1618 ReadIntegerEC }
function ReadIntegerEC(Source: Pointer): Integer; cdecl;
asm
  MOV EAX, Source
  MOV EAX, [EAX]
end;
{ @end $7B1618 }

{ @routine $7B1624 ReadSingleEC }
function ReadSingleEC(Source: Pointer): Single; cdecl;
asm
  MOV EAX, Source
  FLD DWORD PTR [EAX]
end;
{ @end $7B1624 }

{ @routine $7B1630 ReadDoubleEC }
function ReadDoubleEC(Source: Pointer): Double; cdecl;
asm
  MOV EAX, Source
  FLD QWORD PTR [EAX]
end;
{ @end $7B1630 }

end.
