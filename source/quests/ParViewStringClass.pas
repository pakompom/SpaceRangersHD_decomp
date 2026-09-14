unit ParViewStringClass;
// Unit bracket (inferred): .text 0x004DA7F0..0x004DA999; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Struct, TextFieldClass;

type
  TParViewString = class(TObjectEx) // @size 0x10
  public
    MinValue: Integer; // @offset 0x04
    MaxValue: Integer; // @offset 0x08
    Text: TTextField; // @offset 0x0C

    constructor Create(Value: WideString); // @addr 0x4DA880 @ida "TParViewString *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int16 *Value@<ecx>);"
    destructor Destroy; override; // @addr 0x4DA91C @ida "void __usercall $name(TParViewString *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromReader(Reader: TBufEC); // @addr 0x4DA960
  end;

implementation

{ @routine $4DA880 TParViewString_Create }
constructor TParViewString.Create(Value: WideString);
begin
  inherited Create;
  Text := TTextField.Create;
  Text.Text := Value;
end;
{ @end $4DA880 }

{ @routine $4DA91C TParViewString_Destroy }
destructor TParViewString.Destroy;
begin
  Text.Free;
  Text := nil;
  inherited Destroy;
end;
{ @end $4DA91C }

{ @routine $4DA960 TParViewString_LoadFromReader }
procedure TParViewString.LoadFromReader(Reader: TBufEC);
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4DA960 }

end.
