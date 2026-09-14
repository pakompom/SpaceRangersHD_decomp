unit GI_CheckBox;
// Unit bracket (inferred): .text 0x0049C12C..0x0049C88F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, GI_TransImage, Types;

type
  TCheckBoxGI = class(TObjectGI) // @size 0x138
  public
    CheckedImage: TTransImageGI; // @offset 0x120
    UncheckedImage: TTransImageGI; // @offset 0x124
    Checked: Boolean; // @offset 0x128
    ChangedCallback: TObjectNotifyEventGI; // @offset $130

    constructor Create(Owner: TObjectGI); // @addr 0x49C24C @ida "TCheckBoxGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x49C330 @ida "void __usercall $name(TCheckBoxGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x49C380 @note "Does not refresh child activation or call inherited Clear."
    procedure SetConfigPath(const Path: WideString); override; // @addr 0x49C394
    procedure SetSize(Size: TPoint); override; // @addr 0x49C3C4 @ida "void __usercall $name(TCheckBoxGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure RefreshStateImages; // @addr 0x49C498
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $49C65C @ida "void __usercall $name(TCheckBoxGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x49C708
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x49C7E4
  end;

implementation

uses Classes, EC_Str, GI_Main;

{ @routine $49C24C TCheckBoxGI_Create }
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
{ @end $49C24C }

{ @routine $49C330 TCheckBoxGI_Destroy }
destructor TCheckBoxGI.Destroy;
begin
  CheckedImage.Free;
  UncheckedImage.Free;
  inherited Destroy;
end;
{ @end $49C330 }

{ @routine $49C380 TCheckBoxGI_Clear }
procedure TCheckBoxGI.Clear;
begin
  Checked := False;
end;
{ @end $49C380 }

{ @routine $49C394 TCheckBoxGI_SetConfigPath }
procedure TCheckBoxGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  RefreshStateImages;
  Invalidate;
end;
{ @end $49C394 }

{ @routine $49C3C4 TCheckBoxGI_SetSize }
procedure TCheckBoxGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  CheckedImage.SetPosition(Classes.Point(Size.X div 2 - CheckedImage.ClientSize.X div 2, Size.Y div 2 - CheckedImage.ClientSize.Y div 2));
  UncheckedImage.SetPosition(Classes.Point(Size.X div 2 - UncheckedImage.ClientSize.X div 2, Size.Y div 2 - UncheckedImage.ClientSize.Y div 2));
end;
{ @end $49C3C4 }

{ @routine $49C498 TCheckBoxGI_RefreshStateImages }
procedure TCheckBoxGI.RefreshStateImages;
begin
  CheckedImage.SetImagePath(ConfigPath + '.IChecked');
  CheckedImage.SetSize(CheckedImage.GetContentSize);
  UncheckedImage.SetImagePath(ConfigPath + '.IUnchecked');
  UncheckedImage.SetSize(UncheckedImage.GetContentSize);
  CheckedImage.SetPosition(Classes.Point(ClientSize.X div 2 - CheckedImage.ClientSize.X div 2, ClientSize.Y div 2 - CheckedImage.ClientSize.Y div 2));
  UncheckedImage.SetPosition(Classes.Point(ClientSize.X div 2 - UncheckedImage.ClientSize.X div 2, ClientSize.Y div 2 - UncheckedImage.ClientSize.Y div 2));
end;
{ @end $49C498 }

{ @routine $49C65C TCheckBoxGI_ProcessLeftButtonDown }
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
{ @end $49C65C }

{ @routine $49C708 TCheckBoxGI_LoadFromConfigPath }
procedure TCheckBoxGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Checked') > 0 then
    if TrimWideString(Block.GetParam('Checked')) = 'True' then Checked := True
    else Checked := False;
end;
{ @end $49C708 }

{ @routine $49C7E4 TCheckBoxGI_LoadFromBlock }
procedure TCheckBoxGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  if Block.CountParams('Checked') > 0 then
    if TrimWideString(Block.GetParam('Checked')) = 'True' then Checked := True
    else Checked := False;
  RefreshStateImages;
end;
{ @end $49C7E4 }

end.
