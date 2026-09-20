unit GI_RadioGroup;
// Unit bracket (inferred): .text 0x004AA6E0..0x004AADEB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TRadioGroupGI = class(TObjectGI) // @size 0x128
  public
    SelectionChangedCallback: TObjectNotifyEventGI; // @offset $120

    constructor Create(Owner: TObjectGI); // @addr 0x4AA804
    destructor Destroy; override; // @addr 0x4AA84C
    procedure Clear; override; // @addr 0x4AA880 @note "Empty implementation."
    procedure SetConfigPath(const Path: WideString); override; // @addr 0x4AA88C
    procedure SetSize(Size: TPoint); override; // @addr 0x4AA8BC
    procedure AddItem(Name: WideString; Position: TPoint); // @addr 0x4AA8E0
    procedure RefreshItemImages; // @addr 0x4AA9E0
    procedure ClearSelection; // @addr 0x4AAADC
    procedure SelectItem(Name: WideString); // @addr 0x4AAB2C
    procedure ItemClick(Sender: TObjectGI; MouseState: Cardinal; Point: TPoint); // @addr 0x4AABEC
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4AAC3C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4AAC58
  end;

implementation

uses Classes, SysUtils, EC_Str, GI_TransImage;

{ @routine $4AA804 TRadioGroupGI_Create }
constructor TRadioGroupGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $4AA804 }

{ @routine $4AA84C TRadioGroupGI_Destroy }
destructor TRadioGroupGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4AA84C }

{ @routine $4AA880 TRadioGroupGI_Clear }
procedure TRadioGroupGI.Clear;
begin

end;
{ @end $4AA880 }

{ @routine $4AA88C TRadioGroupGI_SetConfigPath }
procedure TRadioGroupGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  RefreshItemImages;
  Invalidate;
end;
{ @end $4AA88C }

{ @routine $4AA8BC TRadioGroupGI_SetSize }
procedure TRadioGroupGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
end;
{ @end $4AA8BC }

{ @routine $4AA8E0 TRadioGroupGI_AddItem }
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
{ @end $4AA8E0 }

{ @routine $4AA9E0 TRadioGroupGI_RefreshItemImages }
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
{ @end $4AA9E0 }

{ @routine $4AAADC TRadioGroupGI_ClearSelection }
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
{ @end $4AAADC }

{ @routine $4AAB2C TRadioGroupGI_SelectItem }
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
{ @end $4AAB2C }

{ @routine $4AABEC TRadioGroupGI_ItemClick }
procedure TRadioGroupGI.ItemClick(Sender: TObjectGI; MouseState: Cardinal; Point: TPoint);
begin
  SelectItem(Sender.ControlName);
  if Assigned(SelectionChangedCallback) then SelectionChangedCallback(Self);
end;
{ @end $4AABEC }

{ @routine $4AAC3C TRadioGroupGI_LoadFromConfigPath }
procedure TRadioGroupGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
end;
{ @end $4AAC3C }

{ @routine $4AAC58 TRadioGroupGI_LoadFromBlock }
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
{ @end $4AAC58 }

end.
