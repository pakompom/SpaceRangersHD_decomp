unit EC_File;
// Unit bracket (inferred): .text 0x0082DE84..0x0082EA5A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct;

type
  TFileEC = class(TObjectEx) // @size 0x10
  public
    // Package index * 16 + open-entry slot; -1 while closed.
    Handle: Integer; // @offset 0x04
    OpenDepth: Integer; // @offset 0x08
    FileName: WideString; // @offset 0x0C

    constructor Create; // @addr 0x82DEEC @ida "TFileEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x82DF38 @ida "void __usercall $name(TFileEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Reset; // @addr 0x82DF74 @note "Closes even when OpenDepth is nonzero."
    procedure SetFileName(NewFileName: WideString); // @addr 0x82DFD0 @note "Closes the current entry regardless of OpenDepth."
    function GetFileName: WideString; // @addr $82E568 @ida "void __usercall $name(TFileEC *Self@<eax>, unsigned __int16 **Result@<edx>);"
    // Nested acquisitions reuse the existing handle and access mode.
    // Opening converts FileName to ANSI for the package collection.
    procedure AcquireReadWriteHandle; // @addr 0x82E02C
    procedure AcquireReadHandle(FirstPackageOnly: Boolean); // @addr 0x82E134
    function TryAcquireReadHandle(FirstPackageOnly: Boolean): Boolean; // @addr 0x82E244 @note "False when the package lookup cannot open the file. A successful call acquires one handle reference, including when already open."
    procedure ReleaseHandle; // @addr 0x82E404 @note "FileName is retained after closing."
    procedure CreateNew; // @addr 0x82E2F0 @note "Truncates an existing file; ignores prior OpenDepth and leaves it at one."

    function GetSize: Cardinal; // @addr 0x82E464 @note "If closed, opens for read/write and releases that acquisition on success."
    function SetPointer(Offset: Cardinal; Origin: Integer): Cardinal; // @addr 0x82E588 @note "Requires an open entry. Origin 0 is absolute, 1 adds Offset to the current position, 2 subtracts Offset from the size; returns the new position."
    function GetPointer: Cardinal; // @addr 0x82E6B4 @note "Returns 0xFFFFFFFF when no entry is open."
    procedure ReadBuffer(Dest: Pointer; ByteCount: Cardinal); // @addr 0x82E6F4 @note "Requires an open entry; raises on backend read failure, including short uncompressed reads."
    function ReadWideString: WideString; // @addr 0x82E9E0 @ida "void __usercall $name(TFileEC *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Consumes UTF-16 code units through the terminating NUL; requires an open entry."
    procedure WriteBuffer(Source: Pointer; ByteCount: Cardinal); // @addr 0x82E890 @note "Requires an open writable uncompressed entry; raises on backend failure or a short write. Zero count does nothing."
  end;

implementation

uses EC_HsFile, SyncObjs, SysUtils, Windows;

{ @routine $82DEEC TFileEC_Create }
constructor TFileEC.Create;
begin
  inherited Create;
  Handle := -1;
end;
{ @end $82DEEC }

{ @routine $82DF38 TFileEC_Destroy }
destructor TFileEC.Destroy;
begin
  Reset;
  inherited Destroy;
end;
{ @end $82DF38 }

{ @routine $82DF74 TFileEC_Reset }
procedure TFileEC.Reset;
begin
  if Handle <> -1 then
  begin
    PackageFileLock.Enter;
    PackageCollection.CloseEntryHandle(Handle);
    PackageFileLock.Leave;
  end;
  OpenDepth := 0;
  Handle := -1;
  FileName := '';
end;
{ @end $82DF74 }

{ @routine $82DFD0 TFileEC_SetFileName }
procedure TFileEC.SetFileName(NewFileName: WideString);
begin
  Reset;
  FileName := NewFileName;
end;
{ @end $82DFD0 }

{ @routine $82E02C TFileEC_AcquireReadWriteHandle }
procedure TFileEC.AcquireReadWriteHandle;
begin
  if OpenDepth = 0 then
  begin
    PackageFileLock.Enter;
    Handle := PackageCollection.OpenEntryByPathAcrossPackages(AnsiString(FileName), GENERIC_READ or GENERIC_WRITE, False);
    PackageFileLock.Leave;
    if Handle = -1 then raise Exception.Create('TFileEC.Open. FileName=' + FileName);
  end;
  Inc(OpenDepth);
end;
{ @end $82E02C }

{ @routine $82E134 TFileEC_AcquireReadHandle }
procedure TFileEC.AcquireReadHandle(FirstPackageOnly: Boolean);
begin
  if OpenDepth = 0 then
  begin
    PackageFileLock.Enter;
    Handle := PackageCollection.OpenEntryByPathAcrossPackages(AnsiString(FileName), GENERIC_READ, FirstPackageOnly);
    PackageFileLock.Leave;
    if Handle = -1 then raise Exception.Create('TFileEC.Open. FileName=' + FileName);
  end;
  Inc(OpenDepth);
end;
{ @end $82E134 }

{ @routine $82E244 TFileEC_TryAcquireReadHandle }
function TFileEC.TryAcquireReadHandle(FirstPackageOnly: Boolean): Boolean;
begin
  if OpenDepth = 0 then
  begin
    PackageFileLock.Enter;
    Handle := PackageCollection.OpenEntryByPathAcrossPackages(AnsiString(FileName), GENERIC_READ, FirstPackageOnly);
    PackageFileLock.Leave;
    if Handle = -1 then begin Result := False; Exit end;
  end;
  Inc(OpenDepth);
  Result := True;
end;
{ @end $82E244 }

{ @routine $82E2F0 TFileEC_CreateNew }
procedure TFileEC.CreateNew;
begin
  OpenDepth := 1;
  ReleaseHandle;
  PackageFileLock.Enter;
  Handle := PackageCollection.CreateLooseFile(FileName);
  PackageFileLock.Leave;
  if Handle = -1 then
  begin
    Handle := -1;
    raise Exception.Create('TFileEC.CreateNew. FileName=' + FileName);
  end;
  OpenDepth := 1;
end;
{ @end $82E2F0 }

{ @routine $82E404 TFileEC_ReleaseHandle }
procedure TFileEC.ReleaseHandle;
begin
  Dec(OpenDepth);
  if OpenDepth <= 0 then
  begin
    if Handle <> -1 then
    begin
      PackageFileLock.Enter;
      PackageCollection.CloseEntryHandle(Handle);
      PackageFileLock.Leave;
    end;
    Handle := -1;
    OpenDepth := 0;
  end;
end;
{ @end $82E404 }

{ @routine $82E464 TFileEC_GetSize }
function TFileEC.GetSize: Cardinal;
var Size: Cardinal;
begin
  AcquireReadWriteHandle;
  PackageFileLock.Enter;
  Size := PackageCollection.GetEntryHandleSize(Handle);
  PackageFileLock.Leave;
  if Size = $FFFFFFFF then raise Exception.Create('TFileEC.GetSize. FileName=' + FileName);
  ReleaseHandle;
  Result := Size;
end;
{ @end $82E464 }

{ @routine $82E568 TFileEC_GetFileName }
function TFileEC.GetFileName: WideString;
begin
  Result := FileName;
end;
{ @end $82E568 }

{ @routine $82E588 TFileEC_SetPointer }
function TFileEC.SetPointer(Offset: Cardinal; Origin: Integer): Cardinal;
var Success: Boolean;
begin
  PackageFileLock.Enter;
  Success := PackageCollection.SeekEntryHandle(Handle, Offset, Origin);
  PackageFileLock.Leave;
  if not Success then raise Exception.Create('TFileEC.SetPointer. FileName=' + FileName);
  PackageFileLock.Enter;
  Result := PackageCollection.GetEntryHandlePosition(Handle);
  PackageFileLock.Leave;
end;
{ @end $82E588 }

{ @routine $82E6B4 TFileEC_GetPointer }
function TFileEC.GetPointer: Cardinal;
begin
  PackageFileLock.Enter;
  Result := PackageCollection.GetEntryHandlePosition(Handle);
  PackageFileLock.Leave;
end;
{ @end $82E6B4 }

{ @routine $82E6F4 TFileEC_ReadBuffer }
procedure TFileEC.ReadBuffer(Dest: Pointer; ByteCount: Cardinal);
var Success: Boolean;
begin
  PackageFileLock.Enter;
  Success := PackageCollection.ReadEntryHandle(Handle, Dest^, ByteCount);
  PackageFileLock.Leave;
  if not Success then raise Exception.Create('TFileEC.Read. FileName=' + FileName +
    ' kolbyte=' + SysUtils.IntToStr(ByteCount) + ' GetLastError=' + SysUtils.IntToStr(Windows.GetLastError));
end;
{ @end $82E6F4 }

{ @routine $82E890 TFileEC_WriteBuffer }
procedure TFileEC.WriteBuffer(Source: Pointer; ByteCount: Cardinal);
var Success: Boolean;
begin
  if ByteCount > 0 then
  begin
    PackageFileLock.Enter;
    Success := PackageCollection.WriteEntryHandle(Handle, Source^, ByteCount);
    PackageFileLock.Leave;
    if not Success then raise Exception.Create('TFileEC.Write. FileName=' + FileName + ' kolbyte=' + SysUtils.IntToStr(ByteCount));
  end;
end;
{ @end $82E890 }

{ @routine $82E9E0 TFileEC_ReadWideString }
function TFileEC.ReadWideString: WideString;
var Ch: WideChar;
begin
  Result := '';
  while True do
  begin
    ReadBuffer(@Ch, SizeOf(Ch));
    if Ch = #0 then Break;
    Result := Result + Ch;
  end;
end;
{ @end $82E9E0 }

end.
