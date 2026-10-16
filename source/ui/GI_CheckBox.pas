unit GI_CheckBox;

interface

uses EC_BlockPar, GI_MessageLoop, GI_TransImage, Types;

type
  TCheckBoxGI = class(TObjectGI) // @size 0x138
  public
    CheckedImage: TTransImageGI; // @offset 0x120
    UncheckedImage: TTransImageGI; // @offset 0x124
    Checked: Boolean; // @offset 0x128
    ChangedCallback: TObjectNotifyEventGI; // @offset $130

    constructor Create(Owner: TObjectGI); // @addr 0x004A840C
    destructor Destroy; override; // @addr 0x004A84C4
    procedure Clear; override; // @addr 0x004A8500 @note "Does not refresh child activation or call inherited Clear."
    procedure SetConfigPath(const Path: WideString); override; // @addr 0x004A8508
    procedure SetSize(Size: TPoint); override; // @addr 0x004A8528
    procedure RefreshStateImages; // @addr 0x004A85D8
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4A8750
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004A87D4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004A88A0
  end;

implementation

uses Classes, EC_Str, GI_Main;

{ @routine $4A840C TCheckBoxGI_Create }
constructor TCheckBoxGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  CheckedImage := TTransImageGI.Create(Self);
  CheckedImage.KindX := image_x_center;
  CheckedImage.KindY := image_y_center;
  CheckedImage.IsActive := False;
  UncheckedImage := TTransImageGI.Create(Self);
  UncheckedImage.KindX := image_x_center;
  UncheckedImage.KindY := image_y_center;
  UncheckedImage.IsActive := True;
  Checked := False;
end;
{ @end $4A840C }

{ @routine $4A84C4 TCheckBoxGI_Destroy }
destructor TCheckBoxGI.Destroy;
begin
  CheckedImage.Free;
  UncheckedImage.Free;
  inherited Destroy;
end;
{ @end $4A84C4 }

{ @routine $4A8500 TCheckBoxGI_Clear }
procedure TCheckBoxGI.Clear;
begin
  Checked := False;
end;
{ @end $4A8500 }

{ @routine $4A8508 TCheckBoxGI_SetConfigPath }
procedure TCheckBoxGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  RefreshStateImages;
  Invalidate;
end;
{ @end $4A8508 }

{ @routine $4A8528 TCheckBoxGI_SetSize }
procedure TCheckBoxGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  CheckedImage.Pos := Classes.Point(Size.X div 2 - CheckedImage.ClientSize.X div 2, Size.Y div 2 - CheckedImage.ClientSize.Y div 2);
  UncheckedImage.Pos := Classes.Point(Size.X div 2 - UncheckedImage.ClientSize.X div 2, Size.Y div 2 - UncheckedImage.ClientSize.Y div 2);
end;
{ @end $4A8528 }

{ @routine $4A85D8 TCheckBoxGI_RefreshStateImages }
procedure TCheckBoxGI.RefreshStateImages;
begin
  CheckedImage.SetImagePath(ConfigPath + '.IChecked');
  CheckedImage.ObjectSize := CheckedImage.GetContentSize;
  UncheckedImage.SetImagePath(ConfigPath + '.IUnchecked');
  UncheckedImage.ObjectSize := UncheckedImage.GetContentSize;
  CheckedImage.Pos := Classes.Point(ClientSize.X div 2 - CheckedImage.ClientSize.X div 2, ClientSize.Y div 2 - CheckedImage.ClientSize.Y div 2);
  UncheckedImage.Pos := Classes.Point(ClientSize.X div 2 - UncheckedImage.ClientSize.X div 2, ClientSize.Y div 2 - UncheckedImage.ClientSize.Y div 2);
end;
{ @end $4A85D8 }

{ @routine $4A8750 TCheckBoxGI_ProcessLeftButtonDown }
procedure TCheckBoxGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if Checked = True then
  begin
    Checked := False;
    CheckedImage.IsActive := False;
    UncheckedImage.IsActive := True;
  end
  else
  begin
    Checked := True;
    CheckedImage.IsActive := True;
    UncheckedImage.IsActive := False;
  end;
  if Assigned(ChangedCallback) then ChangedCallback(Self);
end;
{ @end $4A8750 }

{ @routine $4A87D4 TCheckBoxGI_LoadFromConfigPath }
procedure TCheckBoxGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Checked') > 0 then
    if TrimWideString(Block.GetParam('Checked')) = 'True' then Checked := True
    else Checked := False;
end;
{ @end $4A87D4 }

{ @routine $4A88A0 TCheckBoxGI_LoadFromBlock }
procedure TCheckBoxGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  if Block.CountParams('Checked') > 0 then
    if TrimWideString(Block.GetParam('Checked')) = 'True' then Checked := True
    else Checked := False;
  RefreshStateImages;
end;
{ @end $4A88A0 }

end.
