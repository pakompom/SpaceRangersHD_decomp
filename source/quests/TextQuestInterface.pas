unit TextQuestInterface;
// Unit bracket (inferred): .text 0x004E8A28..0x004E8D5B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct;

type
  TQuestOutcome = (qoNone = 0, qoFailure = 1, qoSuccess = 2,
    qoDeath = 3); // @size 0x04

  TTextQuestInterface = class(TObjectEx) // @size 0x04
  public
    constructor Create; // @addr 0x4E8AC0
    destructor Destroy; override; // @addr 0x4E8AF8

    procedure ShowText(Text: WideString); virtual; // @addr 0x4E8B1C @slot 0x00 @calls "0x4EC29B"
    procedure ShowPicture(Name: WideString); virtual; // @addr 0x4E8B60 @slot 0x04 @calls "0x4EC2DD"
    procedure PlayMusic(Name: WideString); virtual; // @addr 0x4E8BA4 @slot 0x08 @calls "0x4EC319"
    procedure PlaySound(Name: WideString); virtual; // @addr 0x4E8BE8 @slot 0x0C @calls "0x4EC355"
    procedure ShowParameters(Text: WideString); virtual; // @addr 0x4E8C2C @slot 0x10 @calls "0x4EC554"
    procedure AddContinueAction; virtual; // @addr 0x4E8C70 @slot 0x14 @calls "0x4EB947 0x4EC1C1"
    procedure AddSuccessAction; virtual; // @addr 0x4E8C7C @slot 0x18 @calls "0x4EB96D 0x4EC3D4"
    procedure AddDeathAction; virtual; // @addr 0x4E8C88 @slot 0x1C @calls "0x4EB986 0x4EC3E1"
    procedure AddFailureAction; virtual; // @addr 0x4E8C94 @slot 0x20 @calls "0x4EB99F 0x4EC3C7"
    procedure AddPathAction(Text: WideString; PathId: Integer); virtual; // @addr 0x4E8CA0 @slot 0x24 @calls "0x4EBFB3"
    procedure AddDisabledPath(Text: WideString); virtual; // @addr 0x4E8CE8 @slot 0x28 @calls "0x4EBFC3"
    procedure AddPathContinueAction(PathId: Integer); virtual; // @addr 0x4E8D2C @slot 0x2C @calls "0x4EC132"
    procedure AddLocationContinueAction(LocationId: Integer); virtual; // @addr 0x4E8D3C @slot 0x30 @calls "0x4EB86D"
    procedure AdvanceDays(Days: Integer); virtual; // @addr 0x4E8D4C @slot 0x34 @calls "0x4EB89A 0x4EC15F"
  end;

implementation

{ @routine $4E8AC0 TTextQuestInterface_Create }
constructor TTextQuestInterface.Create;
begin
end;
{ @end $4E8AC0 }

{ @routine $4E8AF8 TTextQuestInterface_Destroy }
destructor TTextQuestInterface.Destroy;
begin
end;
{ @end $4E8AF8 }

{ @routine $4E8B1C TTextQuestInterface_ShowText }
procedure TTextQuestInterface.ShowText(Text: WideString);
begin
end;
{ @end $4E8B1C }

{ @routine $4E8B60 TTextQuestInterface_ShowPicture }
procedure TTextQuestInterface.ShowPicture(Name: WideString);
begin
end;
{ @end $4E8B60 }

{ @routine $4E8BA4 TTextQuestInterface_PlayMusic }
procedure TTextQuestInterface.PlayMusic(Name: WideString);
begin
end;
{ @end $4E8BA4 }

{ @routine $4E8BE8 TTextQuestInterface_PlaySound }
procedure TTextQuestInterface.PlaySound(Name: WideString);
begin
end;
{ @end $4E8BE8 }

{ @routine $4E8C2C TTextQuestInterface_ShowParameters }
procedure TTextQuestInterface.ShowParameters(Text: WideString);
begin
end;
{ @end $4E8C2C }

{ @routine $4E8C70 TTextQuestInterface_AddContinueAction }
procedure TTextQuestInterface.AddContinueAction;
begin
end;
{ @end $4E8C70 }

{ @routine $4E8C7C TTextQuestInterface_AddSuccessAction }
procedure TTextQuestInterface.AddSuccessAction;
begin
end;
{ @end $4E8C7C }

{ @routine $4E8C88 TTextQuestInterface_AddDeathAction }
procedure TTextQuestInterface.AddDeathAction;
begin
end;
{ @end $4E8C88 }

{ @routine $4E8C94 TTextQuestInterface_AddFailureAction }
procedure TTextQuestInterface.AddFailureAction;
begin
end;
{ @end $4E8C94 }

{ @routine $4E8CA0 TTextQuestInterface_AddPathAction }
procedure TTextQuestInterface.AddPathAction(Text: WideString; PathId: Integer);
begin
end;
{ @end $4E8CA0 }

{ @routine $4E8CE8 TTextQuestInterface_AddDisabledPath }
procedure TTextQuestInterface.AddDisabledPath(Text: WideString);
begin
end;
{ @end $4E8CE8 }

{ @routine $4E8D2C TTextQuestInterface_AddPathContinueAction }
procedure TTextQuestInterface.AddPathContinueAction(PathId: Integer);
begin
end;
{ @end $4E8D2C }

{ @routine $4E8D3C TTextQuestInterface_AddLocationContinueAction }
procedure TTextQuestInterface.AddLocationContinueAction(LocationId: Integer);
begin
end;
{ @end $4E8D3C }

{ @routine $4E8D4C TTextQuestInterface_AdvanceDays }
procedure TTextQuestInterface.AdvanceDays(Days: Integer);
begin
end;
{ @end $4E8D4C }

end.
