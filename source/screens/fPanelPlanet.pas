unit fPanelPlanet;
// Unit bracket (inferred): .text 0x0059BCD4..0x0059CB5F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, GI_MessageLoop;

type
  TfPanelPlanet = class(TObjectEx) // @size 0x8
  public
    Screen: TMessageLoopGI; // @offset 0x4

    constructor Create; // @addr 0x59BD30 @ida "TfPanelPlanet *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x59BD74 @ida "void __usercall $name(TfPanelPlanet *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitializeLayout(Screen: TMessageLoopGI); // @addr 0x59BDA8
    procedure OnOpen; // @addr $59BFB0 Native no-op lifecycle hook.
    procedure OnClose; // @addr $59BFBC Native no-op lifecycle hook.
    procedure ProcessKeyDown(Key: Integer); // @addr $59CA74
    procedure Show; // @addr 0x59BFC8
    procedure Hide; // @addr 0x59C008
    procedure HangarClicked(Sender: TObjectGI); // @addr 0x59C048
    procedure EquipmentShopClicked(Sender: TObjectGI); // @addr 0x59C0EC
    procedure GoodsShopClicked(Sender: TObjectGI); // @addr 0x59C3AC
    procedure GovernmentClicked(Sender: TObjectGI); // @addr 0x59C66C
    procedure InformationClicked(Sender: TObjectGI); // @addr 0x59C710
    procedure PlanetClicked(Sender: TObjectGI); // @addr 0x59C9D0
  end;

implementation

uses Classes, Windows, GR_Main, Globals, GI_GraphButton, GI_MessageBox,
  aConst, aGalaxyStruct, aMyFunction, aPlanet, aPlayer, aScript, fGov, fPanelLoad;

{ @routine $59BD30 TfPanelPlanet_Create }
constructor TfPanelPlanet.Create;
begin
  inherited Create;
end;
{ @end $59BD30 }

{ @routine $59BD74 TfPanelPlanet_Destroy }
destructor TfPanelPlanet.Destroy;
begin
  inherited Destroy;
end;
{ @end $59BD74 }

{ @routine $59BDA8 TfPanelPlanet_InitializeLayout }
procedure TfPanelPlanet.InitializeLayout(Screen: TMessageLoopGI);
var
  Panel: TObjectGI;
begin
  Self.Screen := Screen;
  AppendLogTextThreadSafe('fPanelPlanet... ');
  Panel := Self.Screen.GetByName('PanelPlanet');
  Panel.SetPosition(Classes.Point(Panel.LocalPosition.X + ExtraScreenWidth,
    Panel.LocalPosition.Y + ExtraScreenHeight));
  AppendLogLineThreadSafe('ok');
  (Self.Screen.GetByName('PP_Hangar') as TGraphButtonGI).UpCallback := HangarClicked;
  (Self.Screen.GetByName('PP_Shop') as TGraphButtonGI).UpCallback := EquipmentShopClicked;
  (Self.Screen.GetByName('PP_Goods') as TGraphButtonGI).UpCallback := GoodsShopClicked;
  (Self.Screen.GetByName('PP_Gov') as TGraphButtonGI).UpCallback := GovernmentClicked;
  (Self.Screen.GetByName('PP_Info') as TGraphButtonGI).UpCallback := InformationClicked;
end;
{ @end $59BDA8 }

{ @routine $59BFB0 TfPanelPlanet_OnOpen }
procedure TfPanelPlanet.OnOpen;
begin
end;
{ @end $59BFB0 }

{ @routine $59BFBC TfPanelPlanet_OnClose }
procedure TfPanelPlanet.OnClose;
begin
end;
{ @end $59BFBC }

{ @routine $59BFC8 TfPanelPlanet_Show }
procedure TfPanelPlanet.Show;
begin
  Screen.GetByName('PanelPlanet').SetActive(True);
end;
{ @end $59BFC8 }

{ @routine $59C008 TfPanelPlanet_Hide }
procedure TfPanelPlanet.Hide;
begin
  Screen.GetByName('PanelPlanet').SetActive(False);
end;
{ @end $59C008 }


{ @routine $59C048 TfPanelPlanet_HangarClicked }
procedure TfPanelPlanet.HangarClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  RequestedScreenId := screenHangar;
  Screen.RequestClose(1);
end;
{ @end $59C048 }

{ @routine $59C0EC TfPanelPlanet_EquipmentShopClicked }
procedure TfPanelPlanet.EquipmentShopClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and
     not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>'), mbgCancel or mbgWarning)
    else
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>'), mbgCancel or mbgWarning);
  end
  else
  begin
    RequestedScreenId := screenEquipmentShop;
    Screen.RequestClose(1);
  end;
end;
{ @end $59C0EC }

{ @routine $59C3AC TfPanelPlanet_GoodsShopClicked }
procedure TfPanelPlanet.GoodsShopClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and
     not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>'), mbgCancel or mbgWarning)
    else
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>'), mbgCancel or mbgWarning);
  end
  else
  begin
    RequestedScreenId := screenGoodsShop;
    Screen.RequestClose(1);
  end;
end;
{ @end $59C3AC }

{ @routine $59C66C TfPanelPlanet_GovernmentClicked }
procedure TfPanelPlanet.GovernmentClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  RequestedScreenId := screenGovernment;
  Screen.RequestClose(1);
end;
{ @end $59C66C }

{ @routine $59C710 TfPanelPlanet_InformationClicked }
procedure TfPanelPlanet.InformationClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlBad) and
     not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>'), mbgCancel or mbgWarning)
    else
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>'), mbgCancel or mbgWarning);
  end
  else
  begin
    RequestedScreenId := screenInfo;
    Screen.RequestClose(1);
  end;
end;
{ @end $59C710 }

{ @routine $59C9D0 TfPanelPlanet_PlanetClicked }
procedure TfPanelPlanet.PlanetClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  RequestedScreenId := screenPlanet;
  Screen.RequestClose(1);
end;
{ @end $59C9D0 }

{ @routine $59CA74 TfPanelPlanet_ProcessKeyDown }
procedure TfPanelPlanet.ProcessKeyDown(Key: Integer);
begin
  if Screen.ExitCode <> 0 then Exit;
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or
     IsVirtualKeyDown(VK_MENU) then Exit;
  if not GetPlayer.IsOnPlanet then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if Key = Ord('H') then HangarClicked(nil)
  else if Key = Ord('E') then EquipmentShopClicked(nil)
  else if Key = Ord('T') then GoodsShopClicked(nil)
  else if Key = Ord('G') then GovernmentClicked(nil)
  else if Key = Ord('I') then InformationClicked(nil)
  else if Key = Ord('P') then PlanetClicked(nil);
end;
{ @end $59CA74 }

end.
