unit ParViewStringClass;

interface

uses EC_Buf, EC_Struct, TextFieldClass;

type
  TParViewString = class(TObjectEx) // @size 0x10
  public
    MinValue: Integer; // @offset 0x04
    MaxValue: Integer; // @offset 0x08
    Text: TTextField; // @offset 0x0C

    constructor Create(Value: WideString); // @addr 0x004DB780
    destructor Destroy; override; // @addr 0x004DB810
    procedure LoadFromReader(Reader: TBufEC); // @addr 0x004DB844
  end;

implementation

{ @routine $4DB780 TParViewString_Create }
constructor TParViewString.Create(Value: WideString);
begin
  inherited Create;
  Text := TTextField.Create;
  Text.Text := Value;
end;
{ @end $4DB780 }

{ @routine $4DB810 TParViewString_Destroy }
destructor TParViewString.Destroy;
begin
  Text.Free;
  Text := nil;
  inherited Destroy;
end;
{ @end $4DB810 }

{ @routine $4DB844 TParViewString_LoadFromReader }
procedure TParViewString.LoadFromReader(Reader: TBufEC);
begin
  MinValue := Reader.GetInt32;
  MaxValue := Reader.GetInt32;
  Text.LoadTextLinesFromReader(Reader);
end;
{ @end $4DB844 }

end.
