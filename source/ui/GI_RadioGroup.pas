unit GI_RadioGroup;

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TRadioGroupGI = class(TObjectGI) // @size 0x128
  public
    SelectionChangedCallback: TObjectNotifyEventGI; // @offset $120

    constructor Create(Owner: TObjectGI); // @addr 0x004A7DCC
    destructor Destroy; override; // @addr 0x004A7E04
    procedure Clear; override; // @addr 0x004A7E2C @note "Empty implementation."
    procedure SetConfigPath(const Path: WideString); override; // @addr 0x004A7E30
    procedure SetSize(Size: TPoint); override; // @addr 0x004A7E50
    procedure AddItem(Name: WideString; Position: TPoint); // @addr 0x004A7E68
    procedure RefreshItemImages; // @addr 0x004A7F4C
    procedure ClearSelection; // @addr 0x004A8028
    procedure SelectItem(Name: WideString); // @addr 0x004A8058
    procedure ItemClick(Sender: TObjectGI; MouseState: Cardinal; Point: TPoint); // @addr 0x004A80F8
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004A8138
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004A8140
  end;

implementation

uses Classes, SysUtils, EC_Str, GI_TransImage;

{ @routine $4A7DCC TRadioGroupGI_Create }
constructor TRadioGroupGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $4A7DCC }

{ @routine $4A7E04 TRadioGroupGI_Destroy }
destructor TRadioGroupGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4A7E04 }

{ @routine $4A7E2C TRadioGroupGI_Clear }
procedure TRadioGroupGI.Clear;
begin

end;
{ @end $4A7E2C }

{ @routine $4A7E30 TRadioGroupGI_SetConfigPath }
procedure TRadioGroupGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  RefreshItemImages;
  Invalidate;
end;
{ @end $4A7E30 }

{ @routine $4A7E50 TRadioGroupGI_SetSize }
procedure TRadioGroupGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
end;
{ @end $4A7E50 }

{ @routine $4A7E68 TRadioGroupGI_AddItem }
procedure TRadioGroupGI.AddItem(Name: WideString; Position: TPoint);
var Image: TTransImageGI;
begin
  Image := TTransImageGI.Create(Self);
  Image.Pos := Position;
  Image.SetName(Name);
  Image.UserValue := 0;
  Image.IsActive := True;
  Image.LeftButtonDownCallback := ItemClick;
  Image := TTransImageGI.Create(Self);
  Image.Pos := Position;
  Image.SetName(Name);
  Image.UserValue := 1;
  Image.IsActive := False;
  Image.LeftButtonDownCallback := ItemClick;
  RefreshItemImages;
end;
{ @end $4A7E68 }

{ @routine $4A7F4C TRadioGroupGI_RefreshItemImages }
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
{ @end $4A7F4C }

{ @routine $4A8028 TRadioGroupGI_ClearSelection }
procedure TRadioGroupGI.ClearSelection;
var Item: TObjectGI;
begin
  Item := FirstChild;
  while Item <> nil do
  begin
    if Item.UserValue = 0 then Item.IsActive := True
    else Item.IsActive := False;
    Item := Item.NextSibling;
  end;
end;
{ @end $4A8028 }

{ @routine $4A8058 TRadioGroupGI_SelectItem }
procedure TRadioGroupGI.SelectItem(Name: WideString);
var Item: TObjectGI;
begin
  ClearSelection;
  Item := FirstChild;
  while Item <> nil do
  begin
    if Item.ControlName = Name then
    begin
      if Item.UserValue = 0 then Item.IsActive := False
      else Item.IsActive := True;
    end
    else
    begin
      if Item.UserValue = 0 then Item.IsActive := True
      else Item.IsActive := False;
    end;
    Item := Item.NextSibling;
  end;
end;
{ @end $4A8058 }

{ @routine $4A80F8 TRadioGroupGI_ItemClick }
procedure TRadioGroupGI.ItemClick(Sender: TObjectGI; MouseState: Cardinal; Point: TPoint);
begin
  SelectItem(Sender.ControlName);
  if Assigned(SelectionChangedCallback) then SelectionChangedCallback(Self);
end;
{ @end $4A80F8 }

{ @routine $4A8138 TRadioGroupGI_LoadFromConfigPath }
procedure TRadioGroupGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
end;
{ @end $4A8138 }

{ @routine $4A8140 TRadioGroupGI_LoadFromBlock }
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
{ @end $4A8140 }

end.
