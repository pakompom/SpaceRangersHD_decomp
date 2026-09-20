unit EventClass;
// Unit bracket (inferred): .text 0x004DE4A8..0x004DE768; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, TextFieldClass;

type
  TEvent = class(TObjectEx) // @size 0x14
  public
    Text: TTextField; // @offset 0x04
    Picture: TTextField; // @offset 0x08
    Music: TTextField; // @offset 0x0C
    Sound: TTextField; // @offset 0x10

    constructor Create; // @addr 0x4DE520
    destructor Destroy; override; // @addr 0x4DE5D8
    procedure ClearTextFields; // @addr 0x4DE658
    procedure Assign(Source: TEvent); // @addr 0x4DE69C @note "Trims the copied text."
  end;

implementation

uses EC_Str;

{ @routine $4DE520 TEvent_Create }
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
{ @end $4DE520 }

{ @routine $4DE5D8 TEvent_Destroy }
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
{ @end $4DE5D8 }

{ @routine $4DE658 TEvent_ClearTextFields }
procedure TEvent.ClearTextFields;
begin
  Text.Text := '';
  Picture.Text := '';
  Music.Text := '';
  Sound.Text := '';
end;
{ @end $4DE658 }

{ @routine $4DE69C TEvent_Assign }
procedure TEvent.Assign(Source: TEvent);
begin
  Text.Text := TrimWideString(Source.Text.Text);
  Picture.Text := TrimWideString(Source.Picture.Text);
  Music.Text := TrimWideString(Source.Music.Text);
  Sound.Text := TrimWideString(Source.Sound.Text);
end;
{ @end $4DE69C }

end.
