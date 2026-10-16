unit GI_PlanetButton;

interface

uses EC_BlockPar, GI_Label, GI_MessageLoop, GI_Panel, GI_Planet, Types;

type
  TPlanetButtonGI = class(TPanelGI) // @size 0x14C
  public
    NormalPlanet: TPlanetGI; // @offset 0x140
    HoverPlanet: TPlanetGI; // @offset 0x144
    TextLabel: TLabelGI; // @offset 0x148

    constructor Create(Owner: TObjectGI); // @addr 0x004ABAEC
    destructor Destroy; override; // @addr 0x004ABBA4
    procedure Clear; override; // @addr 0x004ABBEC @note "The native implementation is empty; it does not reset panel or child state."
    procedure OnMouseEnter; override; // @addr 0x004ABBF0
    procedure OnMouseLeave; override; // @addr 0x004ABC18
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr 0x004ABC40
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004ABC74
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004ABC7C
  end;

implementation

{ @routine $4ABAEC TPlanetButtonGI_Create }
constructor TPlanetButtonGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  NormalPlanet := TPlanetGI.Create(Self);
  NormalPlanet.SetDepth(2);
  HoverPlanet := TPlanetGI.Create(Self);
  HoverPlanet.SetDepth(2);
  HoverPlanet.IsActive := False;
  TextLabel := TLabelGI.Create(Self);
  TextLabel.SetDepth(1);
end;
{ @end $4ABAEC }

{ @routine $4ABBA4 TPlanetButtonGI_Destroy }
destructor TPlanetButtonGI.Destroy;
begin
  NormalPlanet.Free;
  HoverPlanet.Free;
  TextLabel.Free;
  inherited Destroy;
end;
{ @end $4ABBA4 }

{ @routine $4ABBEC TPlanetButtonGI_Clear }
procedure TPlanetButtonGI.Clear;
begin

end;
{ @end $4ABBEC }

{ @routine $4ABBF0 TPlanetButtonGI_OnMouseEnter }
procedure TPlanetButtonGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  NormalPlanet.IsActive := False;
  HoverPlanet.IsActive := True;
end;
{ @end $4ABBF0 }

{ @routine $4ABC18 TPlanetButtonGI_OnMouseLeave }
procedure TPlanetButtonGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  NormalPlanet.IsActive := True;
  HoverPlanet.IsActive := False;
end;
{ @end $4ABC18 }

{ @routine $4ABC40 TPlanetButtonGI_ProcessLeftButtonDown }
procedure TPlanetButtonGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  DispatchNamedEvent(control_event_button_down, Point.X, Point.Y);
end;
{ @end $4ABC40 }

{ @routine $4ABC74 TPlanetButtonGI_LoadFromConfigPath }
procedure TPlanetButtonGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
end;
{ @end $4ABC74 }

{ @routine $4ABC7C TPlanetButtonGI_LoadFromBlock }
procedure TPlanetButtonGI.LoadFromBlock(Block: TBlockParEC);
begin
  TextLabel.IsActive := False;
  inherited LoadFromBlock(Block);
  NormalPlanet.SetImage(Block.GetParam('PN_Mask'), Block.GetParam('PN_Image'), Block.GetParam('PN_ImageLight'));
  ObjectSize := NormalPlanet.ClientSize;
  HoverPlanet.SetImage(Block.GetParam('PN_Mask'), Block.GetParam('PA_Image'), Block.GetParam('PA_ImageLight'));
  if Block.CountParams('Font') > 0 then TextLabel.SetFontName(Block.GetParam('Font'));
  if Block.CountParams('Text') > 0 then
  begin
    TextLabel.Text := Block.GetParam('Text');
    TextLabel.IsActive := True;
    TextLabel.ObjectSize := ClientSize;
  end;
end;
{ @end $4ABC7C }

end.
