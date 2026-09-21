unit EC_Mem;
// Unit bracket (inferred): .text 0x0086E598..0x0086EE5D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

function AllocEC(ByteCount: Integer): Pointer; // @addr 0x86E598 @note "Uses the process heap; allocation failure can evict texture caches before raising."
function AllocClearEC(ByteCount: Integer): Pointer; // @addr 0x86E6F4
function ReAllocREC(Data: Pointer; ByteCount: Integer): Pointer; // @addr 0x86E854 @note "Nonpositive sizes free Data and return nil; allocation failure can evict texture caches."
procedure FreeEC(Data: Pointer); // @addr 0x86EAA8
procedure FreeFromHeapEC(Heap: Cardinal; Data: Pointer); // @addr 0x86ED78
// The diagnostics retain AllocEC/AllocClearEC/ReAllocREC for these explicit-heap variants.
function AllocFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer; // @addr 0x86EAC4 @note "Raises on allocation failure; does not evict caches."
function AllocClearFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer; // @addr 0x86EB74 @note "Raises on allocation failure; does not evict caches."
function ReAllocFromHeapREC(Heap: Cardinal; Data: Pointer; ByteCount: Integer): Pointer; // @addr 0x86EC28 @note "Nonpositive sizes free Data and return nil. Raises on allocation failure; does not evict caches."
// These stack-ABI accessors are handwritten assembly in the native unit.
// Integer(@PRecord(ByteOffset).Field) in callers derives a relative field offset
// without reading memory, preserving these native calls and their argument order.
function AddPointerOffset(Data: Pointer; ByteOffset: Integer): Pointer; cdecl; // @addr 0x86ED98
procedure WriteByteEC(Dest: Pointer; Value: Byte); cdecl; // @addr 0x86EDA4
procedure WriteWordEC(Dest: Pointer; Value: Word); cdecl; // @addr 0x86EDB4
procedure WriteIntegerEC(Dest: Pointer; Value: Integer); cdecl; // @addr 0x86EDC4
procedure WriteInt32EC(Dest: Pointer; Value: Integer); cdecl; // @addr 0x86EDD4
procedure WriteSingleEC(Dest: Pointer; Value: Single); cdecl; // @addr 0x86EDE4
procedure WriteDoubleEC(Dest: Pointer; Value: Double); cdecl; // @addr 0x86EDF4
function ReadByteEC(Source: Pointer): Byte; cdecl; // @addr 0x86EE0C
function ReadWideCharEC(Source: Pointer): WideChar; cdecl; // @addr 0x86EE18
function ReadWordEC(Source: Pointer): Word; cdecl; // @addr 0x86EE24
function ReadDWordEC(Source: Pointer): Cardinal; cdecl; // @addr 0x86EE30
function ReadIntegerEC(Source: Pointer): Integer; cdecl; // @addr 0x86EE3C
function ReadSingleEC(Source: Pointer): Single; cdecl; // @addr 0x86EE48
function ReadDoubleEC(Source: Pointer): Double; cdecl; // @addr 0x86EE54

implementation

uses GR_DX, GR_Main, SysUtils, Windows;

{ @routine $86E598 AllocEC }
function AllocEC(ByteCount: Integer): Pointer;
var
  Memory: Pointer;
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
      raise Exception.Create('AllocEC. size=' + SysUtils.IntToStr(ByteCount));
    end;
  end;
  Result := Memory;
end;
{ @end $86E598 }

{ @routine $86E6F4 AllocClearEC }
function AllocClearEC(ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, ByteCount);
  if Memory = nil then
  begin
    AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
    EvictTextureCaches(True);
    Memory := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, ByteCount);
    if Memory <> nil then AppendLogLineThreadSafe('success')
    else
    begin
      AppendLogLineThreadSafe('fail');
      LogMemoryUsage;
      raise Exception.Create('AllocClearEC. size=' + SysUtils.IntToStr(ByteCount));
    end;
  end;
  Result := Memory;
end;
{ @end $86E6F4 }

{ @routine $86E854 ReAllocREC }
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
{ @end $86E854 }

{ @routine $86EAA8 FreeEC }
procedure FreeEC(Data: Pointer);
begin HeapFree(GetProcessHeap, 0, Data) end;
{ @end $86EAA8 }

{ @routine $86EAC4 AllocFromHeapEC }
function AllocFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(Heap, 0, ByteCount);
  if Memory = nil then
  begin
    raise Exception.Create('AllocEC. size=' + SysUtils.IntToStr(ByteCount));
  end;
  Result := Memory;
end;
{ @end $86EAC4 }

{ @routine $86EB74 AllocClearFromHeapEC }
function AllocClearFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(Heap, HEAP_ZERO_MEMORY, ByteCount);
  if Memory = nil then
  begin
    raise Exception.Create('AllocClearEC. size=' + SysUtils.IntToStr(ByteCount));
  end;
  Result := Memory;
end;
{ @end $86EB74 }

{ @routine $86EC28 ReAllocFromHeapREC }
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
{ @end $86EC28 }

{ @routine $86ED78 FreeFromHeapEC }
procedure FreeFromHeapEC(Heap: Cardinal; Data: Pointer);
begin HeapFree(Heap, 0, Data) end;
{ @end $86ED78 }

{ @routine $86ED98 AddPointerOffset }
function AddPointerOffset(Data: Pointer; ByteOffset: Integer): Pointer; cdecl;
asm
  MOV EAX, Data
  ADD EAX, ByteOffset
end;
{ @end $86ED98 }

{ @routine $86EDA4 WriteByteEC }
procedure WriteByteEC(Dest: Pointer; Value: Byte); cdecl;
asm
  MOV EDX, Dest
  MOV AL, Value
  MOV [EDX], AL
end;
{ @end $86EDA4 }

{ @routine $86EDB4 WriteWordEC }
procedure WriteWordEC(Dest: Pointer; Value: Word); cdecl;
asm
  MOV EDX, Dest
  MOV AX, Value
  MOV [EDX], AX
end;
{ @end $86EDB4 }

{ @routine $86EDC4 WriteIntegerEC }
procedure WriteIntegerEC(Dest: Pointer; Value: Integer); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $86EDC4 }

{ @routine $86EDD4 WriteInt32EC }
procedure WriteInt32EC(Dest: Pointer; Value: Integer); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $86EDD4 }

{ @routine $86EDE4 WriteSingleEC }
procedure WriteSingleEC(Dest: Pointer; Value: Single); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $86EDE4 }

{ @routine $86EDF4 WriteDoubleEC }
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
{ @end $86EDF4 }

{ @routine $86EE0C ReadByteEC }
function ReadByteEC(Source: Pointer): Byte; cdecl;
asm
  MOV EAX, Source
  MOV AL, [EAX]
end;
{ @end $86EE0C }

{ @routine $86EE18 ReadWideCharEC }
function ReadWideCharEC(Source: Pointer): WideChar; cdecl;
asm
  MOV EAX, Source
  MOV AX, [EAX]
end;
{ @end $86EE18 }

{ @routine $86EE24 ReadWordEC }
function ReadWordEC(Source: Pointer): Word; cdecl;
asm
  MOV EAX, Source
  MOV AX, [EAX]
end;
{ @end $86EE24 }

{ @routine $86EE30 ReadDWordEC }
function ReadDWordEC(Source: Pointer): Cardinal; cdecl;
asm
  MOV EAX, Source
  MOV EAX, [EAX]
end;
{ @end $86EE30 }

{ @routine $86EE3C ReadIntegerEC }
function ReadIntegerEC(Source: Pointer): Integer; cdecl;
asm
  MOV EAX, Source
  MOV EAX, [EAX]
end;
{ @end $86EE3C }

{ @routine $86EE48 ReadSingleEC }
function ReadSingleEC(Source: Pointer): Single; cdecl;
asm
  MOV EAX, Source
  FLD DWORD PTR [EAX]
end;
{ @end $86EE48 }

{ @routine $86EE54 ReadDoubleEC }
function ReadDoubleEC(Source: Pointer): Double; cdecl;
asm
  MOV EAX, Source
  FLD QWORD PTR [EAX]
end;
{ @end $86EE54 }

end.
