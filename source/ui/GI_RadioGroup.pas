unit GI_RadioGroup;
// Unit bracket (inferred): .text 0x0049B9E8..0x0049C0F3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TRadioGroupGI = class(TObjectGI) // @size 0x128
  public
    SelectionChangedCallback: TObjectNotifyEventGI; // @offset $120

    constructor Create(Owner: TObjectGI); // @addr 0x49BB0C @ida "TRadioGroupGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x49BB54 @ida "void __usercall $name(TRadioGroupGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x49BB88 @note "Empty implementation."
    procedure SetConfigPath(const Path: WideString); override; // @addr 0x49BB94
    procedure SetSize(Size: TPoint); override; // @addr 0x49BBC4 @ida "void __usercall $name(TRadioGroupGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure AddItem(Name: WideString; Position: TPoint); // @addr 0x49BBE8 @ida "void __usercall $name(TRadioGroupGI *Self@<eax>, unsigned __int16 *Name@<edx>, TPoint *Position@<ecx>);"
    procedure RefreshItemImages; // @addr 0x49BCE8
    procedure ClearSelection; // @addr 0x49BDE4
    procedure SelectItem(Name: WideString); // @addr 0x49BE34
    procedure ItemClick(Sender: TObjectGI; MouseState: Cardinal; Point: TPoint); // @addr 0x49BEF4 @ida "void __userpurge $name(TRadioGroupGI *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int MouseState@<ecx>, TPoint *Point@<^0>);"
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x49BF44
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x49BF60
  end;

implementation

uses Classes, SysUtils, EC_Str, GI_TransImage;

{ @routine $49BB0C TRadioGroupGI_Create }
constructor TRadioGroupGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $49BB0C }

{ @routine $49BB54 TRadioGroupGI_Destroy }
destructor TRadioGroupGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $49BB54 }

{ @routine $49BB88 TRadioGroupGI_Clear }
procedure TRadioGroupGI.Clear;
begin

end;
{ @end $49BB88 }

{ @routine $49BB94 TRadioGroupGI_SetConfigPath }
procedure TRadioGroupGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  RefreshItemImages;
  Invalidate;
end;
{ @end $49BB94 }

{ @routine $49BBC4 TRadioGroupGI_SetSize }
procedure TRadioGroupGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
end;
{ @end $49BBC4 }

{ @routine $49BBE8 TRadioGroupGI_AddItem }
procedure TRadioGroupGI.AddItem(Name: WideString; Position: TPoint);
var Image: TTransImageGI;
begin
  Image := TTransImageGI.Create(Self);
  Image.SetPosition(Position);
  Image.SetName(Name);
  Image.UserValue := 0;
  Image.SetActive(True);
  Image.LeftButtonDownCallback := ItemClick;
  Image := TTransImageGI.Create(Self);
  Image.SetPosition(Position);
  Image.SetName(Name);
  Image.UserValue := 1;
  Image.SetActive(False);
  Image.LeftButtonDownCallback := ItemClick;
  RefreshItemImages;
end;
{ @end $49BBE8 }

{ @routine $49BCE8 TRadioGroupGI_RefreshItemImages }
procedure TRadioGroupGI.RefreshItemImages;
var Item: TObjectGI;
begin
  Item := FirstChild;
  while Item <> nil do
  begin
    if Item.UserValue = 0 then (Item as TTransImageGI).SetImagePath(ConfigPath + '.IUnchecked')
    else (Item as TTransImageGI).SetImagePath(ConfigPath + '.IChecked');
    Item := Item.NextSibling;
  end;
end;
{ @end $49BCE8 }

{ @routine $49BDE4 TRadioGroupGI_ClearSelection }
procedure TRadioGroupGI.ClearSelection;
var Item: TObjectGI;
begin
  Item := FirstChild;
  while Item <> nil do
  begin
    if Item.UserValue = 0 then Item.SetActive(True)
    else Item.SetActive(False);
    Item := Item.NextSibling;
  end;
end;
{ @end $49BDE4 }

{ @routine $49BE34 TRadioGroupGI_SelectItem }
procedure TRadioGroupGI.SelectItem(Name: WideString);
var Item: TObjectGI;
begin
  ClearSelection;
  Item := FirstChild;
  while Item <> nil do
  begin
    if Item.ControlName = Name then
    begin
      if Item.UserValue = 0 then Item.SetActive(False)
      else Item.SetActive(True);
    end
    else
    begin
      if Item.UserValue = 0 then Item.SetActive(True)
      else Item.SetActive(False);
    end;
    Item := Item.NextSibling;
  end;
end;
{ @end $49BE34 }

{ @routine $49BEF4 TRadioGroupGI_ItemClick }
procedure TRadioGroupGI.ItemClick(Sender: TObjectGI; MouseState: Cardinal; Point: TPoint);
begin
  SelectItem(Sender.ControlName);
  if Assigned(SelectionChangedCallback) then SelectionChangedCallback(Self);
end;
{ @end $49BEF4 }

{ @routine $49BF44 TRadioGroupGI_LoadFromConfigPath }
procedure TRadioGroupGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
end;
{ @end $49BF44 }

{ @routine $49BF60 TRadioGroupGI_LoadFromBlock }
procedure TRadioGroupGI.LoadFromBlock(Block: TBlockParEC);
var
  Items: TBlockParEC;
  Index, Count: Integer;
  Text: WideString;
begin
  inherited LoadFromBlock(Block);
  if Block.CountBlocks('RadioButton') > 0 then
  begin
    Items := Block.GetBlock('RadioButton');
    Count := Items.GetParamCount;
    for Index := 0 to Count - 1 do
    begin
      Text := Items.GetParamValue(Index);
      AddItem(Items.GetParamName(Index), Classes.Point(
        StrToInt(AnsiString(ExtractDelimitedPartW(Text, 0, ','))),
        StrToInt(AnsiString(ExtractDelimitedPartW(Text, 1, ',')))));
    end;
  end;
  if Block.CountParams('Checked') > 0 then SelectItem(TrimWideString(Block.GetParam('Checked')));
end;
{ @end $49BF60 }

end.
