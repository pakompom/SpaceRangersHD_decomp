unit GI_CheckBox;
// Unit bracket (inferred): .text 0x004A9F58..0x004AA6BB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, GI_TransImage, Types;

type
  TCheckBoxGI = class(TObjectGI) // @size 0x138
  public
    CheckedImage: TTransImageGI; // @offset 0x120
    UncheckedImage: TTransImageGI; // @offset 0x124
    Checked: Boolean; // @offset 0x128
    ChangedCallback: TObjectNotifyEventGI; // @offset $130

    constructor Create(Owner: TObjectGI); // @addr 0x4AA078
    destructor Destroy; override; // @addr 0x4AA15C
    procedure Clear; override; // @addr 0x4AA1AC @note "Does not refresh child activation or call inherited Clear."
    procedure SetConfigPath(const Path: WideString); override; // @addr 0x4AA1C0
    procedure SetSize(Size: TPoint); override; // @addr 0x4AA1F0
    procedure RefreshStateImages; // @addr 0x4AA2C4
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4AA488
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4AA534
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4AA610
  end;

implementation

uses Classes, EC_Str, GI_Main;

{ @routine $4AA078 TCheckBoxGI_Create }
constructor TCheckBoxGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  CheckedImage := TTransImageGI.Create(Self);
  CheckedImage.SetImageKindX(ikxCenter);
  CheckedImage.SetImageKindY(ikyCenter);
  CheckedImage.SetActive(False);
  UncheckedImage := TTransImageGI.Create(Self);
  UncheckedImage.SetImageKindX(ikxCenter);
  UncheckedImage.SetImageKindY(ikyCenter);
  UncheckedImage.SetActive(True);
  Checked := False;
end;
{ @end $4AA078 }

{ @routine $4AA15C TCheckBoxGI_Destroy }
destructor TCheckBoxGI.Destroy;
begin
  CheckedImage.Free;
  UncheckedImage.Free;
  inherited Destroy;
end;
{ @end $4AA15C }

{ @routine $4AA1AC TCheckBoxGI_Clear }
procedure TCheckBoxGI.Clear;
begin
  Checked := False;
end;
{ @end $4AA1AC }

{ @routine $4AA1C0 TCheckBoxGI_SetConfigPath }
procedure TCheckBoxGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  RefreshStateImages;
  Invalidate;
end;
{ @end $4AA1C0 }

{ @routine $4AA1F0 TCheckBoxGI_SetSize }
procedure TCheckBoxGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  CheckedImage.SetPosition(Classes.Point(Size.X div 2 - CheckedImage.ClientSize.X div 2, Size.Y div 2 - CheckedImage.ClientSize.Y div 2));
  UncheckedImage.SetPosition(Classes.Point(Size.X div 2 - UncheckedImage.ClientSize.X div 2, Size.Y div 2 - UncheckedImage.ClientSize.Y div 2));
end;
{ @end $4AA1F0 }

{ @routine $4AA2C4 TCheckBoxGI_RefreshStateImages }
procedure TCheckBoxGI.RefreshStateImages;
begin
  CheckedImage.SetImagePath(ConfigPath + '.IChecked');
  CheckedImage.SetSize(CheckedImage.GetContentSize);
  UncheckedImage.SetImagePath(ConfigPath + '.IUnchecked');
  UncheckedImage.SetSize(UncheckedImage.GetContentSize);
  CheckedImage.SetPosition(Classes.Point(ClientSize.X div 2 - CheckedImage.ClientSize.X div 2, ClientSize.Y div 2 - CheckedImage.ClientSize.Y div 2));
  UncheckedImage.SetPosition(Classes.Point(ClientSize.X div 2 - UncheckedImage.ClientSize.X div 2, ClientSize.Y div 2 - UncheckedImage.ClientSize.Y div 2));
end;
{ @end $4AA2C4 }

{ @routine $4AA488 TCheckBoxGI_ProcessLeftButtonDown }
procedure TCheckBoxGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if Checked = True then
  begin
    Checked := False;
    CheckedImage.SetActive(False);
    UncheckedImage.SetActive(True);
  end
  else
  begin
    Checked := True;
    CheckedImage.SetActive(True);
    UncheckedImage.SetActive(False);
  end;
  if Assigned(ChangedCallback) then ChangedCallback(Self);
end;
{ @end $4AA488 }

{ @routine $4AA534 TCheckBoxGI_LoadFromConfigPath }
procedure TCheckBoxGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Checked') > 0 then
    if TrimWideString(Block.GetParam('Checked')) = 'True' then Checked := True
    else Checked := False;
end;
{ @end $4AA534 }

{ @routine $4AA610 TCheckBoxGI_LoadFromBlock }
procedure TCheckBoxGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  if Block.CountParams('Checked') > 0 then
    if TrimWideString(Block.GetParam('Checked')) = 'True' then Checked := True
    else Checked := False;
  RefreshStateImages;
end;
{ @end $4AA610 }

end.
