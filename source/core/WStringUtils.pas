unit WStringUtils;
// Shared string helpers before NoSteamAchievemens. WStringUtils is the native
// linked unit in this dependency family; attribution is inferred from that context.

interface

type PStartupWideString = ^WideString;

function AllocateStartupWideString(Length: Integer): PStartupWideString; // @addr $4D3F54
function FreeStartupWideString(var Text: PStartupWideString): Boolean; // @addr $4D3FC4 Does not clear the disposed pointer.

function TruncateStartupWideString(var Text: PStartupWideString): PStartupWideString; // @addr $4D3F84 @note "Shrinks a caller-provided WideString to its first zero. Requires a valid pointer and a terminator within the buffer."

implementation

{ @routine $4D3F54 AllocateStartupWideString }
function AllocateStartupWideString(Length: Integer): PStartupWideString;
begin
  New(Result);
  SetLength(Result^, Length);
end;
{ @end $4D3F54 }

{ @routine $4D3F84 TruncateStartupWideString }
function TruncateStartupWideString(var Text: PStartupWideString): PStartupWideString;
var Count: Integer;
begin
  Count := 0;
  while Text^[Count + 1] <> #0 do Inc(Count);
  SetLength(Text^, Count);
  Result := Text;
end;
{ @end $4D3F84 }

{ @routine $4D3FC4 FreeStartupWideString }
function FreeStartupWideString(var Text: PStartupWideString): Boolean;
begin
  Result := False;
  if Text <> nil then
  begin
    Dispose(Text);
    Result := True;
  end;
end;
{ @end $4D3FC4 }

end.
