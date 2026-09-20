unit GI_PlanetButton;
// Unit bracket (inferred): .text 0x004A99EC..0x004A9EB3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_Label, GI_MessageLoop, GI_Panel, GI_Planet, Types;

type
  TPlanetButtonGI = class(TPanelGI) // @size 0x14C
  public
    NormalPlanet: TPlanetGI; // @offset 0x140
    HoverPlanet: TPlanetGI; // @offset 0x144
    TextLabel: TLabelGI; // @offset 0x148

    constructor Create(Owner: TObjectGI); // @addr 0x4A9B14
    destructor Destroy; override; // @addr 0x4A9BF4
    procedure Clear; override; // @addr 0x4A9C50 @note "The native implementation is empty; it does not reset panel or child state."
    procedure OnMouseEnter; override; // @addr 0x4A9C5C
    procedure OnMouseLeave; override; // @addr 0x4A9C90
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr 0x4A9CC4
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4A9D04
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4A9D20
  end;

implementation

{ @routine $4A9B14 TPlanetButtonGI_Create }
constructor TPlanetButtonGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  NormalPlanet := TPlanetGI.Create(Self);
  NormalPlanet.SetDepth(2);
  HoverPlanet := TPlanetGI.Create(Self);
  HoverPlanet.SetDepth(2);
  HoverPlanet.SetActive(False);
  TextLabel := TLabelGI.Create(Self);
  TextLabel.SetDepth(1);
end;
{ @end $4A9B14 }

{ @routine $4A9BF4 TPlanetButtonGI_Destroy }
destructor TPlanetButtonGI.Destroy;
begin
  NormalPlanet.Free;
  HoverPlanet.Free;
  TextLabel.Free;
  inherited Destroy;
end;
{ @end $4A9BF4 }

{ @routine $4A9C50 TPlanetButtonGI_Clear }
procedure TPlanetButtonGI.Clear;
begin

end;
{ @end $4A9C50 }

{ @routine $4A9C5C TPlanetButtonGI_OnMouseEnter }
procedure TPlanetButtonGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  NormalPlanet.SetActive(False);
  HoverPlanet.SetActive(True);
end;
{ @end $4A9C5C }

{ @routine $4A9C90 TPlanetButtonGI_OnMouseLeave }
procedure TPlanetButtonGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  NormalPlanet.SetActive(True);
  HoverPlanet.SetActive(False);
end;
{ @end $4A9C90 }

{ @routine $4A9CC4 TPlanetButtonGI_ProcessLeftButtonDown }
procedure TPlanetButtonGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  DispatchNamedEvent(1, Point.X, Point.Y);
end;
{ @end $4A9CC4 }

{ @routine $4A9D04 TPlanetButtonGI_LoadFromConfigPath }
procedure TPlanetButtonGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
end;
{ @end $4A9D04 }

{ @routine $4A9D20 TPlanetButtonGI_LoadFromBlock }
procedure TPlanetButtonGI.LoadFromBlock(Block: TBlockParEC);
begin
  TextLabel.SetActive(False);
  inherited LoadFromBlock(Block);
  NormalPlanet.SetImage(Block.GetParam('PN_Mask'), Block.GetParam('PN_Image'), Block.GetParam('PN_ImageLight'));
  SetSize(NormalPlanet.ClientSize);
  HoverPlanet.SetImage(Block.GetParam('PN_Mask'), Block.GetParam('PA_Image'), Block.GetParam('PA_ImageLight'));
  if Block.CountParams('Font') > 0 then TextLabel.SetFontName(Block.GetParam('Font'));
  if Block.CountParams('Text') > 0 then
  begin
    TextLabel.SetText(Block.GetParam('Text'));
    TextLabel.SetActive(True);
    TextLabel.SetSize(ClientSize);
  end;
end;
{ @end $4A9D20 }

end.
