unit AlignedClasses;
interface
type
  TAlignedBase = class // @size 20
    Depth: Double; // @offset 8
    Flag: Byte; // @offset 16
  end;
  TAlignedChild = class(TAlignedBase) // @size 28
    Value: Integer; // @offset 24
    function ReadValue: Integer; // @addr $1000
  end;
  TAlignedGrandchild = class(TAlignedChild) // @size 36
    NextValue: Integer; // @offset 32
    function ReadNextValue: Integer; // @addr $1100
  end;
implementation
{ @routine $1000 TAlignedChild_ReadValue }
function TAlignedChild.ReadValue: Integer;
begin
  Result := Value;
end;
{ @end $1000 }
{ @routine $1100 TAlignedGrandchild_ReadNextValue }
function TAlignedGrandchild.ReadNextValue: Integer;
begin
  Result := NextValue;
end;
{ @end $1100 }
end.
