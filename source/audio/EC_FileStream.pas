unit EC_FileStream;
// Unit bracket (inferred): .text 0x004725F4..0x00472C10; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Thread, EC_File, SyncObjs;

type
  TFileStreamEC = class(TThreadEC) // @size $58
  public
    BlockSize: Integer; // @offset $2C
    BufferCapacity: Integer; // @offset $30
    ReadBuffer: Pointer; // @offset $34
    ReadAvailable: Integer; // @offset $38
    ReadPosition: Integer; // @offset $3C
    FillBuffer: Pointer; // @offset $40
    FillAvailable: Integer; // @offset $44
    SourceFile: TFileEC; // @offset $48
    FileSize: Integer; // @offset $4C
    EndOfFile: Boolean; // @offset $50
    BufferLock: TCriticalSection; // @offset $54
    constructor Create(BufferBytes: Integer; const FileName: WideString); // @addr $472654 @ida "TFileStreamEC *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, int BufferBytes@<ecx>, unsigned __int16 *FileName@<^0>);"
    destructor Destroy; override; // @addr $472750 @ida "void __usercall $name(TFileStreamEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SwapBuffers; // @addr $472820
    function Read(Destination: Pointer; ByteCount: Integer): Integer; // @addr $47297C
    procedure Execute; override; // @addr $472874
  end;

implementation

uses SysUtils, EC_Mem, Windows;

{ @routine $472654 TFileStreamEC_Create }
constructor TFileStreamEC.Create(BufferBytes: Integer; const FileName: WideString);
begin
  inherited Create;
  BufferLock := TCriticalSection.Create;
  SourceFile := TFileEC.Create;
  SourceFile.SetFileName(FileName);
  SourceFile.AcquireReadHandle(False);
  EndOfFile := False;
  FileSize := SourceFile.GetSize;
  BlockSize := 4096;
  BufferCapacity := (BufferBytes div BlockSize) * BlockSize + BlockSize;
  ReadBuffer := AllocEC(BufferCapacity);
  FillBuffer := AllocEC(BufferCapacity);
  SetPriority(ThreadPriorityLowest);
  Start;
end;
{ @end $472654 }

{ @routine $472750 TFileStreamEC_Destroy }
destructor TFileStreamEC.Destroy;
begin
  RequestStop;
  if IsRunning then WaitForIdle(INFINITE);
  if SourceFile <> nil then
  begin
    SourceFile.Free;
    SourceFile := nil;
  end;
  if ReadBuffer <> nil then
  begin
    FreeEC(ReadBuffer);
    ReadBuffer := nil;
  end;
  if FillBuffer <> nil then
  begin
    FreeEC(FillBuffer);
    FillBuffer := nil;
  end;
  BlockSize := 0;
  BufferCapacity := 0;
  if BufferLock <> nil then
  begin
    BufferLock.Free;
    BufferLock := nil;
  end;
  inherited Destroy;
end;
{ @end $472750 }

{ @routine $472820 TFileStreamEC_SwapBuffers }
procedure TFileStreamEC.SwapBuffers;
var
  Buffer: Pointer;
  Available: Integer;
begin
  Buffer := ReadBuffer;
  ReadBuffer := FillBuffer;
  FillBuffer := Buffer;
  Available := ReadAvailable;
  ReadAvailable := FillAvailable;
  FillAvailable := Available;
  ReadPosition := 0;
end;
{ @end $472820 }

{ @routine $472874 TFileStreamEC_Execute }
procedure TFileStreamEC.Execute;
var
  ByteCount: Integer;
begin
  while not IsStopRequested and not EndOfFile do
  begin
    if FillAvailable >= BufferCapacity then
    begin
      BufferLock.Enter;
      if ReadAvailable > 0 then
      begin
        BufferLock.Leave;
        Exit;
      end;
      SwapBuffers;
      BufferLock.Leave;
    end;
    ByteCount := BlockSize;
    if FileSize - Integer(SourceFile.GetPointer) < ByteCount then
      ByteCount := FileSize - Integer(SourceFile.GetPointer);
    if ByteCount <= 0 then
    begin
      EndOfFile := True;
      Exit;
    end;
    SourceFile.ReadBuffer(AddPointerOffset(FillBuffer, FillAvailable), ByteCount);
    Inc(FillAvailable, ByteCount);
    if Integer(SourceFile.GetPointer) > FileSize then EndOfFile := True;
    SysUtils.Sleep(0);
  end;
end;
{ @end $472874 }

{ @routine $47297C TFileStreamEC_Read }
function TFileStreamEC.Read(Destination: Pointer; ByteCount: Integer): Integer;
var
  Chunk, Total: Integer;
begin
  Total := 0;
  BufferLock.Enter;
  Chunk := ByteCount;
  if Chunk > ReadAvailable then Chunk := ReadAvailable;
  if Chunk > 0 then
  begin
    CopyMemory(Destination, AddPointerOffset(ReadBuffer, ReadPosition), Chunk);
    Inc(ReadPosition, Chunk);
    Dec(ReadAvailable, Chunk);
    Destination := AddPointerOffset(Destination, Chunk);
    Dec(ByteCount, Chunk);
    Inc(Total, Chunk);
  end;
  BufferLock.Leave;
  if ByteCount <= 0 then
  begin
    Result := Total;
    Exit;
  end;
  if IsRunning then
  begin
    RequestStop;
    WaitForIdle(INFINITE);
  end;
  while True do
  begin
    Chunk := ByteCount;
    if Chunk > ReadAvailable then Chunk := ReadAvailable;
    if Chunk > 0 then
    begin
      CopyMemory(Destination, AddPointerOffset(ReadBuffer, ReadPosition), Chunk);
      Inc(ReadPosition, Chunk);
      Dec(ReadAvailable, Chunk);
      Destination := AddPointerOffset(Destination, Chunk);
      Dec(ByteCount, Chunk);
      Inc(Total, Chunk);
    end;
    if ByteCount <= 0 then Break;
    SwapBuffers;
    Chunk := ByteCount;
    if Chunk > ReadAvailable then Chunk := ReadAvailable;
    if Chunk > 0 then
    begin
      CopyMemory(Destination, AddPointerOffset(ReadBuffer, ReadPosition), Chunk);
      Inc(ReadPosition, Chunk);
      Dec(ReadAvailable, Chunk);
      Destination := AddPointerOffset(Destination, Chunk);
      Dec(ByteCount, Chunk);
      Inc(Total, Chunk);
    end;
    if (ByteCount <= 0) or EndOfFile then Break;
    Chunk := BufferCapacity;
    if FileSize - Integer(SourceFile.GetPointer) < Chunk then
      Chunk := FileSize - Integer(SourceFile.GetPointer);
    if Chunk <= 0 then
    begin
      EndOfFile := True;
      Break;
    end;
    SourceFile.ReadBuffer(AddPointerOffset(FillBuffer, FillAvailable), Chunk);
    Inc(FillAvailable, Chunk);
    if Integer(SourceFile.GetPointer) > FileSize then EndOfFile := True;
  end;
  if not EndOfFile then Start;
  Result := Total;
end;
{ @end $47297C }

end.
