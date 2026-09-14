unit TextQuestInterface;
// Unit bracket (inferred): .text 0x004D8BA8..0x004D8EDB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct;

type
  TQuestOutcome = (qoNone = 0, qoFailure = 1, qoSuccess = 2,
    qoDeath = 3); // @size 0x04

  TTextQuestInterface = class(TObjectEx) // @size 0x04
  public
    constructor Create; // @addr 0x4D8C40 @ida "TTextQuestInterface *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4D8C78 @ida "void __usercall $name(TTextQuestInterface *Self@<eax>, __int8 DestroyFlags@<dl>);"

    procedure ShowText(Text: WideString); virtual; // @addr 0x4D8C9C @slot 0x00 @calls "0x4E8197"
    procedure ShowPicture(Name: WideString); virtual; // @addr 0x4D8CE0 @slot 0x04 @calls "0x4E81D9"
    procedure PlayMusic(Name: WideString); virtual; // @addr 0x4D8D24 @slot 0x08 @calls "0x4E8215"
    procedure PlaySound(Name: WideString); virtual; // @addr 0x4D8D68 @slot 0x0C @calls "0x4E8251"
    procedure ShowParameters(Text: WideString); virtual; // @addr 0x4D8DAC @slot 0x10 @calls "0x4E8450"
    procedure AddContinueAction; virtual; // @addr 0x4D8DF0 @slot 0x14 @calls "0x4E7843 0x4E80BD"
    procedure AddSuccessAction; virtual; // @addr 0x4D8DFC @slot 0x18 @calls "0x4E7869 0x4E82D0"
    procedure AddDeathAction; virtual; // @addr 0x4D8E08 @slot 0x1C @calls "0x4E7882 0x4E82DD"
    procedure AddFailureAction; virtual; // @addr 0x4D8E14 @slot 0x20 @calls "0x4E789B 0x4E82C3"
    procedure AddPathAction(Text: WideString; PathId: Integer); virtual; // @addr 0x4D8E20 @slot 0x24 @calls "0x4E7EAF"
    procedure AddDisabledPath(Text: WideString); virtual; // @addr 0x4D8E68 @slot 0x28 @calls "0x4E7EBF"
    procedure AddPathContinueAction(PathId: Integer); virtual; // @addr 0x4D8EAC @slot 0x2C @calls "0x4E802E"
    procedure AddLocationContinueAction(LocationId: Integer); virtual; // @addr 0x4D8EBC @slot 0x30 @calls "0x4E7769"
    procedure AdvanceDays(Days: Integer); virtual; // @addr 0x4D8ECC @slot 0x34 @calls "0x4E7796 0x4E805B"
  end;

implementation

{ @routine $4D8C40 TTextQuestInterface_Create }
constructor TTextQuestInterface.Create;
begin
end;
{ @end $4D8C40 }

{ @routine $4D8C78 TTextQuestInterface_Destroy }
destructor TTextQuestInterface.Destroy;
begin
end;
{ @end $4D8C78 }

{ @routine $4D8C9C TTextQuestInterface_ShowText }
procedure TTextQuestInterface.ShowText(Text: WideString);
begin
end;
{ @end $4D8C9C }

{ @routine $4D8CE0 TTextQuestInterface_ShowPicture }
procedure TTextQuestInterface.ShowPicture(Name: WideString);
begin
end;
{ @end $4D8CE0 }

{ @routine $4D8D24 TTextQuestInterface_PlayMusic }
procedure TTextQuestInterface.PlayMusic(Name: WideString);
begin
end;
{ @end $4D8D24 }

{ @routine $4D8D68 TTextQuestInterface_PlaySound }
procedure TTextQuestInterface.PlaySound(Name: WideString);
begin
end;
{ @end $4D8D68 }

{ @routine $4D8DAC TTextQuestInterface_ShowParameters }
procedure TTextQuestInterface.ShowParameters(Text: WideString);
begin
end;
{ @end $4D8DAC }

{ @routine $4D8DF0 TTextQuestInterface_AddContinueAction }
procedure TTextQuestInterface.AddContinueAction;
begin
end;
{ @end $4D8DF0 }

{ @routine $4D8DFC TTextQuestInterface_AddSuccessAction }
procedure TTextQuestInterface.AddSuccessAction;
begin
end;
{ @end $4D8DFC }

{ @routine $4D8E08 TTextQuestInterface_AddDeathAction }
procedure TTextQuestInterface.AddDeathAction;
begin
end;
{ @end $4D8E08 }

{ @routine $4D8E14 TTextQuestInterface_AddFailureAction }
procedure TTextQuestInterface.AddFailureAction;
begin
end;
{ @end $4D8E14 }

{ @routine $4D8E20 TTextQuestInterface_AddPathAction }
procedure TTextQuestInterface.AddPathAction(Text: WideString; PathId: Integer);
begin
end;
{ @end $4D8E20 }

{ @routine $4D8E68 TTextQuestInterface_AddDisabledPath }
procedure TTextQuestInterface.AddDisabledPath(Text: WideString);
begin
end;
{ @end $4D8E68 }

{ @routine $4D8EAC TTextQuestInterface_AddPathContinueAction }
procedure TTextQuestInterface.AddPathContinueAction(PathId: Integer);
begin
end;
{ @end $4D8EAC }

{ @routine $4D8EBC TTextQuestInterface_AddLocationContinueAction }
procedure TTextQuestInterface.AddLocationContinueAction(LocationId: Integer);
begin
end;
{ @end $4D8EBC }

{ @routine $4D8ECC TTextQuestInterface_AdvanceDays }
procedure TTextQuestInterface.AdvanceDays(Days: Integer);
begin
end;
{ @end $4D8ECC }

end.
