unit EC_File;

interface

uses EC_Struct;

type
  TFileEC = class(TObjectEx) // @size 0x10
  public
    // Package index * 16 + open-entry slot; -1 while closed.
    Handle: Integer; // @offset 0x04
    OpenDepth: Integer; // @offset 0x08
    FileName: WideString; // @offset 0x0C

    constructor Create; // @addr 0x007B6D54
    destructor Destroy; override; // @addr 0x007B6D90
    procedure Reset; // @addr 0x007B6DBC @note "Closes even when OpenDepth is nonzero."
    procedure SetFileName(NewFileName: WideString); // @addr 0x007B6E04 @note "Closes the current entry regardless of OpenDepth."
    function GetFileName: WideString; // @addr $7B7314
    // Nested acquisitions reuse the existing handle and access mode.
    // Opening converts FileName to ANSI for the package collection.
    procedure AcquireReadWriteHandle; // @addr 0x007B6E58
    procedure AcquireReadHandle(FirstPackageOnly: Boolean); // @addr 0x007B6F50
    function TryAcquireReadHandle(FirstPackageOnly: Boolean): Boolean; // @addr 0x007B704C @note "False when the package lookup cannot open the file. A successful call acquires one handle reference, including when already open."
    procedure ReleaseHandle; // @addr 0x007B71DC @note "FileName is retained after closing."
    procedure CreateNew; // @addr 0x007B70DC @note "Truncates an existing file; ignores prior OpenDepth and leaves it at one."

    function GetSize: Cardinal; // @addr 0x007B7224 @note "If closed, opens for read/write and releases that acquisition on success."
    function SetPointer(Offset: Cardinal; Origin: Integer): Cardinal; // @addr 0x007B7328 @note "Requires an open entry. Origin 0 is absolute, 1 adds Offset to the current position, 2 subtracts Offset from the size; returns the new position."
    function GetPointer: Cardinal; // @addr 0x007B743C @note "Returns 0xFFFFFFFF when no entry is open."
    procedure ReadBuffer(Dest: Pointer; ByteCount: Cardinal); // @addr 0x007B746C @note "Requires an open entry; raises on backend read failure, including short uncompressed reads."
    function ReadWideString: WideString; // @addr 0x007B772C @note "Consumes UTF-16 code units through the terminating NUL; requires an open entry."
    procedure WriteBuffer(Source: Pointer; ByteCount: Cardinal); // @addr 0x007B75F4 @note "Requires an open writable uncompressed entry; raises on backend failure or a short write. Zero count does nothing."
  end;

implementation

uses EC_HsFile, SyncObjs, SysUtils, Windows;

{ @routine $7B6D54 TFileEC_Create }
constructor TFileEC.Create;
begin
  inherited Create;
  Handle := -1;
end;
{ @end $7B6D54 }

{ @routine $7B6D90 TFileEC_Destroy }
destructor TFileEC.Destroy;
begin
  Reset;
  inherited Destroy;
end;
{ @end $7B6D90 }

{ @routine $7B6DBC TFileEC_Reset }
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
{ @end $7B6DBC }

{ @routine $7B6E04 TFileEC_SetFileName }
procedure TFileEC.SetFileName(NewFileName: WideString);
begin
  Reset;
  FileName := NewFileName;
end;
{ @end $7B6E04 }

{ @routine $7B6E58 TFileEC_AcquireReadWriteHandle }
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
{ @end $7B6E58 }

{ @routine $7B6F50 TFileEC_AcquireReadHandle }
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
{ @end $7B6F50 }

{ @routine $7B704C TFileEC_TryAcquireReadHandle }
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
{ @end $7B704C }

{ @routine $7B70DC TFileEC_CreateNew }
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
{ @end $7B70DC }

{ @routine $7B71DC TFileEC_ReleaseHandle }
procedure TFileEC.ReleaseHandle;
begin
  Dec(OpenDepth);
  if OpenDepth > 0 then Exit;
  if Handle <> -1 then
  begin
    PackageFileLock.Enter;
    PackageCollection.CloseEntryHandle(Handle);
    PackageFileLock.Leave;
  end;
  Handle := -1;
  OpenDepth := 0;
end;
{ @end $7B71DC }

{ @routine $7B7224 TFileEC_GetSize }
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
{ @end $7B7224 }

{ @routine $7B7314 TFileEC_GetFileName }
function TFileEC.GetFileName: WideString;
begin
  Result := FileName;
end;
{ @end $7B7314 }

{ @routine $7B7328 TFileEC_SetPointer }
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
{ @end $7B7328 }

{ @routine $7B743C TFileEC_GetPointer }
function TFileEC.GetPointer: Cardinal;
begin
  PackageFileLock.Enter;
  Result := PackageCollection.GetEntryHandlePosition(Handle);
  PackageFileLock.Leave;
end;
{ @end $7B743C }

{ @routine $7B746C TFileEC_ReadBuffer }
procedure TFileEC.ReadBuffer(Dest: Pointer; ByteCount: Cardinal);
var Success: Boolean;
begin
  PackageFileLock.Enter;
  Success := PackageCollection.ReadEntryHandle(Handle, Dest^, ByteCount);
  PackageFileLock.Leave;
  if not Success then raise Exception.Create('TFileEC.Read. FileName=' + FileName +
    ' kolbyte=' + SysUtils.IntToStr(ByteCount) + ' GetLastError=' + SysUtils.IntToStr(Windows.GetLastError));
end;
{ @end $7B746C }

{ @routine $7B75F4 TFileEC_WriteBuffer }
procedure TFileEC.WriteBuffer(Source: Pointer; ByteCount: Cardinal);
var Success: Boolean;
begin
  if ByteCount <= 0 then Exit;
  PackageFileLock.Enter;
  Success := PackageCollection.WriteEntryHandle(Handle, Source^, ByteCount);
  PackageFileLock.Leave;
  if not Success then raise Exception.Create('TFileEC.Write. FileName=' + FileName + ' kolbyte=' + SysUtils.IntToStr(ByteCount));
end;
{ @end $7B75F4 }

{ @routine $7B772C TFileEC_ReadWideString }
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
{ @end $7B772C }

end.
