unit ParViewStringClass;
// Unit bracket (inferred): .text 0x004DCE78..0x004DD021; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Struct, TextFieldClass;

type
  TParViewString = class(TObjectEx) // @size 0x10
  public
    MinValue: Integer; // @offset 0x04
    MaxValue: Integer; // @offset 0x08
    Text: TTextField; // @offset 0x0C

    constructor Create(Value: WideString); // @addr 0x4DCF08
    destructor Destroy; override; // @addr 0x4DCFA4
    procedure LoadFromReader(Reader: TBufEC); // @addr 0x4DCFE8
  end;

implementation

{ @routine $4DCF08 TParViewString_Create }
constructor TParViewString.Create(Value: WideString);
begin
  inherited Create;
  Text := TTextField.Create;
  Text.Text := Value;
end;
{ @end $4DCF08 }

{ @routine $4DCFA4 TParViewString_Destroy }
destructor TParViewString.Destroy;
begin
  Text.Free;
  Text := nil;
  inherited Destroy;
end;
{ @end $4DCFA4 }

{ @routine $4DCFE8 TParViewString_LoadFromReader }
procedure TParViewString.LoadFromReader(Reader: TBufEC);
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4DCFE8 }

end.
