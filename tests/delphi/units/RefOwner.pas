unit RefOwner;
interface
type
  TEntry = class
    Value: Integer;
  end;
var Shared: TEntry;
function ReadOwn: Integer;
implementation
function ReadOwn: Integer;
begin Result := Shared.Value + 1; end;
end.
