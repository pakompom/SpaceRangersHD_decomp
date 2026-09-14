unit RefConsumer;
interface
uses RefOwner;
function ReadOther: Integer;
implementation
function ReadOther: Integer;
begin Result := Shared.Value; end;
end.
