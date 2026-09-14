unit TextFieldClass;
// Unit bracket (inferred): .text 0x004D8EDC..0x004D909A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Struct;

type
  TTextField = class(TObjectEx) // @size 0x08
  public
    Text: WideString; // @offset 0x04

    procedure ClearText; // @addr 0x4D8F48
    procedure LoadTextLinesFromReader(Reader: TBufEC); // @addr 0x4D8F60 @note "Int32 line and character counts, UTF-16 text; trims lines and joins with CRLF."
  end;

implementation

uses EC_Str;

{ @routine $4D8F48 TTextField_ClearText }
procedure TTextField.ClearText;
begin
  Text := '';
end;
{ @end $4D8F48 }

{ @routine $4D8F60 TTextField_LoadTextLinesFromReader }
procedure TTextField.LoadTextLinesFromReader(Reader: TBufEC);
var
  Line: WideString;
  i, j, LineCount, CharCount: Integer;
begin
  ClearText;
  LineCount := Reader.GetInt32;
  for j := 1 to LineCount do
  begin
    CharCount := Reader.GetInt32;
    SetLength(Line, CharCount);
    for i := 1 to CharCount do Line[i] := Reader.GetWideChar;
    if Text <> '' then Text := Text + #13#10 + TrimWideString(Line)
    else Text := TrimWideString(Line);
  end;
  Text := TrimWideString(Text);
end;
{ @end $4D8F60 }

end.
