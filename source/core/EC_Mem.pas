unit EC_Mem;
// Unit bracket (inferred): .text 0x00813D74..0x00814639; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

function AllocEC(ByteCount: Integer): Pointer; // @addr 0x813D74 @note "Uses the process heap; allocation failure can evict texture caches before raising."
function AllocClearEC(ByteCount: Integer): Pointer; // @addr 0x813ED0
function ReAllocREC(Data: Pointer; ByteCount: Integer): Pointer; // @addr 0x814030 @note "Nonpositive sizes free Data and return nil; allocation failure can evict texture caches."
procedure FreeEC(Data: Pointer); // @addr 0x814284
procedure FreeFromHeapEC(Heap: Cardinal; Data: Pointer); // @addr 0x814554
// The diagnostics retain AllocEC/AllocClearEC/ReAllocREC for these explicit-heap variants.
function AllocFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer; // @addr 0x8142A0 @note "Raises on allocation failure; does not evict caches."
function AllocClearFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer; // @addr 0x814350 @note "Raises on allocation failure; does not evict caches."
function ReAllocFromHeapREC(Heap: Cardinal; Data: Pointer; ByteCount: Integer): Pointer; // @addr 0x814404 @note "Nonpositive sizes free Data and return nil. Raises on allocation failure; does not evict caches."
// These stack-ABI accessors are handwritten assembly in the native unit.
function AddPointerOffset(Data: Pointer; ByteOffset: Integer): Pointer; cdecl; // @addr 0x814574
procedure WriteByteEC(Dest: Pointer; Value: Byte); cdecl; // @addr 0x814580
procedure WriteWordEC(Dest: Pointer; Value: Word); cdecl; // @addr 0x814590
procedure WriteIntegerEC(Dest: Pointer; Value: Integer); cdecl; // @addr 0x8145A0
procedure WriteInt32EC(Dest: Pointer; Value: Integer); cdecl; // @addr 0x8145B0
procedure WriteSingleEC(Dest: Pointer; Value: Single); cdecl; // @addr 0x8145C0
procedure WriteDoubleEC(Dest: Pointer; Value: Double); cdecl; // @addr 0x8145D0
function ReadByteEC(Source: Pointer): Byte; cdecl; // @addr 0x8145E8
function ReadWideCharEC(Source: Pointer): WideChar; cdecl; // @addr 0x8145F4
function ReadWordEC(Source: Pointer): Word; cdecl; // @addr 0x814600
function ReadDWordEC(Source: Pointer): Cardinal; cdecl; // @addr 0x81460C
function ReadIntegerEC(Source: Pointer): Integer; cdecl; // @addr 0x814618
function ReadSingleEC(Source: Pointer): Single; cdecl; // @addr 0x814624
function ReadDoubleEC(Source: Pointer): Double; cdecl; // @addr 0x814630

implementation

uses GR_DX, GR_Main, SysUtils, Windows;

{ @routine $813D74 AllocEC }
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
{ @end $813D74 }

{ @routine $813ED0 AllocClearEC }
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
{ @end $813ED0 }

{ @routine $814030 ReAllocREC }
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
{ @end $814030 }

{ @routine $814284 FreeEC }
procedure FreeEC(Data: Pointer);
begin HeapFree(GetProcessHeap, 0, Data) end;
{ @end $814284 }

{ @routine $8142A0 AllocFromHeapEC }
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
{ @end $8142A0 }

{ @routine $814350 AllocClearFromHeapEC }
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
{ @end $814350 }

{ @routine $814404 ReAllocFromHeapREC }
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
{ @end $814404 }

{ @routine $814554 FreeFromHeapEC }
procedure FreeFromHeapEC(Heap: Cardinal; Data: Pointer);
begin HeapFree(Heap, 0, Data) end;
{ @end $814554 }

{ @routine $814574 AddPointerOffset }
function AddPointerOffset(Data: Pointer; ByteOffset: Integer): Pointer; cdecl;
asm
  MOV EAX, Data
  ADD EAX, ByteOffset
end;
{ @end $814574 }

{ @routine $814580 WriteByteEC }
procedure WriteByteEC(Dest: Pointer; Value: Byte); cdecl;
asm
  MOV EDX, Dest
  MOV AL, Value
  MOV [EDX], AL
end;
{ @end $814580 }

{ @routine $814590 WriteWordEC }
procedure WriteWordEC(Dest: Pointer; Value: Word); cdecl;
asm
  MOV EDX, Dest
  MOV AX, Value
  MOV [EDX], AX
end;
{ @end $814590 }

{ @routine $8145A0 WriteIntegerEC }
procedure WriteIntegerEC(Dest: Pointer; Value: Integer); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $8145A0 }

{ @routine $8145B0 WriteInt32EC }
procedure WriteInt32EC(Dest: Pointer; Value: Integer); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $8145B0 }

{ @routine $8145C0 WriteSingleEC }
procedure WriteSingleEC(Dest: Pointer; Value: Single); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;
{ @end $8145C0 }

{ @routine $8145D0 WriteDoubleEC }
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
{ @end $8145D0 }

{ @routine $8145E8 ReadByteEC }
function ReadByteEC(Source: Pointer): Byte; cdecl;
asm
  MOV EAX, Source
  MOV AL, [EAX]
end;
{ @end $8145E8 }

{ @routine $8145F4 ReadWideCharEC }
function ReadWideCharEC(Source: Pointer): WideChar; cdecl;
asm
  MOV EAX, Source
  MOV AX, [EAX]
end;
{ @end $8145F4 }

{ @routine $814600 ReadWordEC }
function ReadWordEC(Source: Pointer): Word; cdecl;
asm
  MOV EAX, Source
  MOV AX, [EAX]
end;
{ @end $814600 }

{ @routine $81460C ReadDWordEC }
function ReadDWordEC(Source: Pointer): Cardinal; cdecl;
asm
  MOV EAX, Source
  MOV EAX, [EAX]
end;
{ @end $81460C }

{ @routine $814618 ReadIntegerEC }
function ReadIntegerEC(Source: Pointer): Integer; cdecl;
asm
  MOV EAX, Source
  MOV EAX, [EAX]
end;
{ @end $814618 }

{ @routine $814624 ReadSingleEC }
function ReadSingleEC(Source: Pointer): Single; cdecl;
asm
  MOV EAX, Source
  FLD DWORD PTR [EAX]
end;
{ @end $814624 }

{ @routine $814630 ReadDoubleEC }
function ReadDoubleEC(Source: Pointer): Double; cdecl;
asm
  MOV EAX, Source
  FLD QWORD PTR [EAX]
end;
{ @end $814630 }

end.
