program FileExistsFallback;

uses Windows, SysUtils;

{$R-}{$Q-}{$B-}

// Native RTL optimization, with a frame for the search-data record.
{$O+}{$W+}
function RecoveredExistsLockedOrShared(const FileName: AnsiString): Boolean;
var FindData: TWin32FindData; Handle: THandle;
begin
  Handle := Windows.FindFirstFileA(PAnsiChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    Result := (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0;
  end
  else Result := False;
end;
{$W-}

function RecoveredFileExists(const FileName: AnsiString): Boolean;
var Attributes, Error: Cardinal;
begin
  Attributes := Windows.GetFileAttributesA(PAnsiChar(FileName));
  if Attributes <> $FFFFFFFF then
  begin
    Result := (Attributes and FILE_ATTRIBUTE_DIRECTORY) = 0;
    Exit;
  end;
  Error := Windows.GetLastError;
  Result := (Error <> ERROR_FILE_NOT_FOUND) and (Error <> ERROR_PATH_NOT_FOUND) and
    (Error <> ERROR_INVALID_NAME) and RecoveredExistsLockedOrShared(FileName);
end;
{$O-}

function LibraryFileExists(const FileName: AnsiString): Boolean;
begin
  Result := SysUtils.FileExists(FileName);
end;

exports RecoveredFileExists, LibraryFileExists;
begin
end.
