unit TextQuestInterface;

interface

uses EC_Struct;

type
  TQuestOutcome = (quest_outcome_none = 0, quest_outcome_failure = 1, quest_outcome_success = 2,
    quest_outcome_death = 3); // @size 0x04

  TTextQuestInterface = class(TObjectEx) // @size 0x04
  public
    constructor Create; // @addr 0x004DA048
    destructor Destroy; override; // @addr 0x004DA068

    procedure ShowText(Text: WideString); virtual; // @addr 0x004DA078 @slot 0x00
    procedure ShowPicture(Name: WideString); virtual; // @addr 0x004DA0A0 @slot 0x04
    procedure PlayMusic(Name: WideString); virtual; // @addr 0x004DA0C8 @slot 0x08
    procedure PlaySound(Name: WideString); virtual; // @addr 0x004DA0F0 @slot 0x0C
    procedure ShowParameters(Text: WideString); virtual; // @addr 0x004DA118 @slot 0x10
    procedure AddContinueAction; virtual; // @addr 0x004DA140 @slot 0x14
    procedure AddSuccessAction; virtual; // @addr 0x004DA144 @slot 0x18
    procedure AddDeathAction; virtual; // @addr 0x004DA148 @slot 0x1C
    procedure AddFailureAction; virtual; // @addr 0x004DA14C @slot 0x20
    procedure AddPathAction(Text: WideString; PathId: Integer); virtual; // @addr 0x004DA150 @slot 0x24
    procedure AddDisabledPath(Text: WideString); virtual; // @addr 0x004DA178 @slot 0x28
    procedure AddPathContinueAction(PathId: Integer); virtual; // @addr 0x004DA1A0 @slot 0x2C
    procedure AddLocationContinueAction(LocationId: Integer); virtual; // @addr 0x004DA1A4 @slot 0x30
    procedure AdvanceDays(Days: Integer); virtual; // @addr 0x004DA1A8 @slot 0x34
  end;

implementation

{ @routine $4DA048 TTextQuestInterface_Create }
constructor TTextQuestInterface.Create;
begin
end;
{ @end $4DA048 }

{ @routine $4DA068 TTextQuestInterface_Destroy }
destructor TTextQuestInterface.Destroy;
begin
end;
{ @end $4DA068 }

{ @routine $4DA078 TTextQuestInterface_ShowText }
procedure TTextQuestInterface.ShowText(Text: WideString);
begin
end;
{ @end $4DA078 }

{ @routine $4DA0A0 TTextQuestInterface_ShowPicture }
procedure TTextQuestInterface.ShowPicture(Name: WideString);
begin
end;
{ @end $4DA0A0 }

{ @routine $4DA0C8 TTextQuestInterface_PlayMusic }
procedure TTextQuestInterface.PlayMusic(Name: WideString);
begin
end;
{ @end $4DA0C8 }

{ @routine $4DA0F0 TTextQuestInterface_PlaySound }
procedure TTextQuestInterface.PlaySound(Name: WideString);
begin
end;
{ @end $4DA0F0 }

{ @routine $4DA118 TTextQuestInterface_ShowParameters }
procedure TTextQuestInterface.ShowParameters(Text: WideString);
begin
end;
{ @end $4DA118 }

{ @routine $4DA140 TTextQuestInterface_AddContinueAction }
procedure TTextQuestInterface.AddContinueAction;
begin
end;
{ @end $4DA140 }

{ @routine $4DA144 TTextQuestInterface_AddSuccessAction }
procedure TTextQuestInterface.AddSuccessAction;
begin
end;
{ @end $4DA144 }

{ @routine $4DA148 TTextQuestInterface_AddDeathAction }
procedure TTextQuestInterface.AddDeathAction;
begin
end;
{ @end $4DA148 }

{ @routine $4DA14C TTextQuestInterface_AddFailureAction }
procedure TTextQuestInterface.AddFailureAction;
begin
end;
{ @end $4DA14C }

{ @routine $4DA150 TTextQuestInterface_AddPathAction }
procedure TTextQuestInterface.AddPathAction(Text: WideString; PathId: Integer);
begin
end;
{ @end $4DA150 }

{ @routine $4DA178 TTextQuestInterface_AddDisabledPath }
procedure TTextQuestInterface.AddDisabledPath(Text: WideString);
begin
end;
{ @end $4DA178 }

{ @routine $4DA1A0 TTextQuestInterface_AddPathContinueAction }
procedure TTextQuestInterface.AddPathContinueAction(PathId: Integer);
begin
end;
{ @end $4DA1A0 }

{ @routine $4DA1A4 TTextQuestInterface_AddLocationContinueAction }
procedure TTextQuestInterface.AddLocationContinueAction(LocationId: Integer);
begin
end;
{ @end $4DA1A4 }

{ @routine $4DA1A8 TTextQuestInterface_AdvanceDays }
procedure TTextQuestInterface.AdvanceDays(Days: Integer);
begin
end;
{ @end $4DA1A8 }

end.
