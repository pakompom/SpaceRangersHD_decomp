unit GI_PlanetButton;
// Unit bracket (inferred): .text 0x0049FE38..0x004A02FF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_Label, GI_MessageLoop, GI_Panel, GI_Planet, Types;

type
  TPlanetButtonGI = class(TPanelGI) // @size 0x14C
  public
    NormalPlanet: TPlanetGI; // @offset 0x140
    HoverPlanet: TPlanetGI; // @offset 0x144
    TextLabel: TLabelGI; // @offset 0x148

    constructor Create(Owner: TObjectGI); // @addr 0x49FF60 @ida "TPlanetButtonGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4A0040 @ida "void __usercall $name(TPlanetButtonGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4A009C @note "The native implementation is empty; it does not reset panel or child state."
    procedure OnMouseEnter; override; // @addr 0x4A00A8
    procedure OnMouseLeave; override; // @addr 0x4A00DC
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr 0x4A0110 @ida "void __usercall $name(TPlanetButtonGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4A0150
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4A016C
  end;

implementation

{ @routine $49FF60 TPlanetButtonGI_Create }
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
{ @end $49FF60 }

{ @routine $4A0040 TPlanetButtonGI_Destroy }
destructor TPlanetButtonGI.Destroy;
begin
  NormalPlanet.Free;
  HoverPlanet.Free;
  TextLabel.Free;
  inherited Destroy;
end;
{ @end $4A0040 }

{ @routine $4A009C TPlanetButtonGI_Clear }
procedure TPlanetButtonGI.Clear;
begin

end;
{ @end $4A009C }

{ @routine $4A00A8 TPlanetButtonGI_OnMouseEnter }
procedure TPlanetButtonGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  NormalPlanet.SetActive(False);
  HoverPlanet.SetActive(True);
end;
{ @end $4A00A8 }

{ @routine $4A00DC TPlanetButtonGI_OnMouseLeave }
procedure TPlanetButtonGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  NormalPlanet.SetActive(True);
  HoverPlanet.SetActive(False);
end;
{ @end $4A00DC }

{ @routine $4A0110 TPlanetButtonGI_ProcessLeftButtonDown }
procedure TPlanetButtonGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  DispatchNamedEvent(1, Point.X, Point.Y);
end;
{ @end $4A0110 }

{ @routine $4A0150 TPlanetButtonGI_LoadFromConfigPath }
procedure TPlanetButtonGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
end;
{ @end $4A0150 }

{ @routine $4A016C TPlanetButtonGI_LoadFromBlock }
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
{ @end $4A016C }

end.
