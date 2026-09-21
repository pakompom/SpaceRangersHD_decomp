unit fPanelPlanet;
// Unit bracket (inferred): .text 0x0081294C..0x008137D7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, GI_MessageLoop;

type
  TfPanelPlanet = class(TObjectEx) // @size 0x8
  public
    Screen: TMessageLoopGI; // @offset 0x4

    constructor Create; // @addr 0x8129A8
    destructor Destroy; override; // @addr 0x8129EC
    procedure InitializeLayout(Screen: TMessageLoopGI); // @addr 0x812A20
    procedure OnOpen; // @addr $812C28 Native no-op lifecycle hook.
    procedure OnClose; // @addr $812C34 Native no-op lifecycle hook.
    procedure ProcessKeyDown(Key: Integer); // @addr $8136EC
    procedure Show; // @addr 0x812C40
    procedure Hide; // @addr 0x812C80
    procedure HangarClicked(Sender: TObjectGI); // @addr 0x812CC0
    procedure EquipmentShopClicked(Sender: TObjectGI); // @addr 0x812D64
    procedure GoodsShopClicked(Sender: TObjectGI); // @addr 0x813024
    procedure GovernmentClicked(Sender: TObjectGI); // @addr 0x8132E4
    procedure InformationClicked(Sender: TObjectGI); // @addr 0x813388
    procedure PlanetClicked(Sender: TObjectGI); // @addr 0x813648
  end;

implementation

uses Classes, Windows, GR_Main, Globals, GI_GraphButton, GI_MessageBox,
  aConst, aGalaxyStruct, aMyFunction, aPlanet, aPlayer, aScript, fGov, fPanelLoad;

{ @routine $8129A8 TfPanelPlanet_Create }
constructor TfPanelPlanet.Create;
begin
  inherited Create;
end;
{ @end $8129A8 }

{ @routine $8129EC TfPanelPlanet_Destroy }
destructor TfPanelPlanet.Destroy;
begin
  inherited Destroy;
end;
{ @end $8129EC }

{ @routine $812A20 TfPanelPlanet_InitializeLayout }
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
{ @end $812A20 }

{ @routine $812C28 TfPanelPlanet_OnOpen }
procedure TfPanelPlanet.OnOpen;
begin
end;
{ @end $812C28 }

{ @routine $812C34 TfPanelPlanet_OnClose }
procedure TfPanelPlanet.OnClose;
begin
end;
{ @end $812C34 }

{ @routine $812C40 TfPanelPlanet_Show }
procedure TfPanelPlanet.Show;
begin
  Screen.GetByName('PanelPlanet').SetActive(True);
end;
{ @end $812C40 }

{ @routine $812C80 TfPanelPlanet_Hide }
procedure TfPanelPlanet.Hide;
begin
  Screen.GetByName('PanelPlanet').SetActive(False);
end;
{ @end $812C80 }


{ @routine $812CC0 TfPanelPlanet_HangarClicked }
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
{ @end $812CC0 }

{ @routine $812D64 TfPanelPlanet_EquipmentShopClicked }
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
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
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
{ @end $812D64 }

{ @routine $813024 TfPanelPlanet_GoodsShopClicked }
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
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
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
{ @end $813024 }

{ @routine $8132E4 TfPanelPlanet_GovernmentClicked }
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
{ @end $8132E4 }

{ @routine $813388 TfPanelPlanet_InformationClicked }
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
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
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
{ @end $813388 }

{ @routine $813648 TfPanelPlanet_PlanetClicked }
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
{ @end $813648 }

{ @routine $8136EC TfPanelPlanet_ProcessKeyDown }
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
{ @end $8136EC }

end.
