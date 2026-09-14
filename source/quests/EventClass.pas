unit EventClass;
// Unit bracket (inferred): .text 0x004D90A8..0x004D9368; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, TextFieldClass;

type
  TEvent = class(TObjectEx) // @size 0x14
  public
    Text: TTextField; // @offset 0x04
    Picture: TTextField; // @offset 0x08
    Music: TTextField; // @offset 0x0C
    Sound: TTextField; // @offset 0x10

    constructor Create; // @addr 0x4D9120 @ida "TEvent *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4D91D8 @ida "void __usercall $name(TEvent *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure ClearTextFields; // @addr 0x4D9258
    procedure Assign(Source: TEvent); // @addr 0x4D929C @note "Trims the copied text."
  end;

implementation

uses EC_Str;

{ @routine $4D9120 TEvent_Create }
constructor TEvent.Create;
begin
  inherited Create;
  Text := TTextField.Create;
  Text.ClearText;
  Picture := TTextField.Create;
  Picture.ClearText;
  Music := TTextField.Create;
  Music.ClearText;
  Sound := TTextField.Create;
  Sound.ClearText;
end;
{ @end $4D9120 }

{ @routine $4D91D8 TEvent_Destroy }
destructor TEvent.Destroy;
begin
  Text.Free;
  Text := nil;
  Picture.Free;
  Picture := nil;
  Music.Free;
  Music := nil;
  Sound.Free;
  Sound := nil;
  inherited Destroy;
end;
{ @end $4D91D8 }

{ @routine $4D9258 TEvent_ClearTextFields }
procedure TEvent.ClearTextFields;
begin
  Text.Text := '';
  Picture.Text := '';
  Music.Text := '';
  Sound.Text := '';
end;
{ @end $4D9258 }

{ @routine $4D929C TEvent_Assign }
procedure TEvent.Assign(Source: TEvent);
begin
  Text.Text := TrimWideString(Source.Text.Text);
  Picture.Text := TrimWideString(Source.Picture.Text);
  Music.Text := TrimWideString(Source.Music.Text);
  Sound.Text := TrimWideString(Source.Sound.Text);
end;
{ @end $4D929C }

end.
