unit fPanelPlanet;

interface

uses EC_Struct, GI_MessageLoop;

type
  TfPanelPlanet = class(TObjectEx) // @size 0x8
  public
    Screen: TMessageLoopGI; // @offset 0x4

    constructor Create; // @addr 0x0058ADB8
    destructor Destroy; override; // @addr 0x0058ADF0
    procedure InitializeLayout(Screen: TMessageLoopGI); // @addr 0x0058AE18
    procedure OnOpen; // @addr $58AFE8 Native no-op lifecycle hook.
    procedure OnClose; // @addr $58AFEC Native no-op lifecycle hook.
    procedure ProcessKeyDown(Key: Integer); // @addr $58B9F0
    procedure Show; // @addr 0x0058AFF0
    procedure Hide; // @addr 0x0058B028
    procedure HangarClicked(Sender: TObjectGI); // @addr 0x0058B060
    procedure EquipmentShopClicked(Sender: TObjectGI); // @addr 0x0058B0E8
    procedure GoodsShopClicked(Sender: TObjectGI); // @addr 0x0058B390
    procedure GovernmentClicked(Sender: TObjectGI); // @addr 0x0058B638
    procedure InformationClicked(Sender: TObjectGI); // @addr 0x0058B6C0
    procedure PlanetClicked(Sender: TObjectGI); // @addr 0x0058B968
  end;

implementation

uses Classes, Windows, GR_Main, Globals, GI_GraphButton, GI_MessageBox,
  aConst, aGalaxyStruct, aMyFunction, aPlanet, aPlayer, aScript, fGov, fPanelLoad;

{ @routine $58ADB8 TfPanelPlanet_Create }
constructor TfPanelPlanet.Create;
begin
  inherited Create;
end;
{ @end $58ADB8 }

{ @routine $58ADF0 TfPanelPlanet_Destroy }
destructor TfPanelPlanet.Destroy;
begin
  inherited Destroy;
end;
{ @end $58ADF0 }

{ @routine $58AE18 TfPanelPlanet_InitializeLayout }
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
{ @end $58AE18 }

{ @routine $58AFE8 TfPanelPlanet_OnOpen }
procedure TfPanelPlanet.OnOpen;
begin
end;
{ @end $58AFE8 }

{ @routine $58AFEC TfPanelPlanet_OnClose }
procedure TfPanelPlanet.OnClose;
begin
end;
{ @end $58AFEC }

{ @routine $58AFF0 TfPanelPlanet_Show }
procedure TfPanelPlanet.Show;
begin
  Screen.GetByName('PanelPlanet').SetActive(True);
end;
{ @end $58AFF0 }

{ @routine $58B028 TfPanelPlanet_Hide }
procedure TfPanelPlanet.Hide;
begin
  Screen.GetByName('PanelPlanet').SetActive(False);
end;
{ @end $58B028 }


{ @routine $58B060 TfPanelPlanet_HangarClicked }
procedure TfPanelPlanet.HangarClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  RequestedScreenId := screen_hangar;
  Screen.RequestClose(1);
end;
{ @end $58B060 }

{ @routine $58B0E8 TfPanelPlanet_EquipmentShopClicked }
procedure TfPanelPlanet.EquipmentShopClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= relation_level_bad) and
     not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = owner_pirate then
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, TextHighlightColorTag), messagebox_cancel or messagebox_warning)
    else
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, TextHighlightColorTag), messagebox_cancel or messagebox_warning);
  end
  else
  begin
    RequestedScreenId := screen_equipment_shop;
    Screen.RequestClose(1);
  end;
end;
{ @end $58B0E8 }

{ @routine $58B390 TfPanelPlanet_GoodsShopClicked }
procedure TfPanelPlanet.GoodsShopClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= relation_level_bad) and
     not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = owner_pirate then
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, TextHighlightColorTag), messagebox_cancel or messagebox_warning)
    else
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, TextHighlightColorTag), messagebox_cancel or messagebox_warning);
  end
  else
  begin
    RequestedScreenId := screen_goods_shop;
    Screen.RequestClose(1);
  end;
end;
{ @end $58B390 }

{ @routine $58B638 TfPanelPlanet_GovernmentClicked }
procedure TfPanelPlanet.GovernmentClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  RequestedScreenId := screen_government;
  Screen.RequestClose(1);
end;
{ @end $58B638 }

{ @routine $58B6C0 TfPanelPlanet_InformationClicked }
procedure TfPanelPlanet.InformationClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= relation_level_bad) and
     not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = owner_pirate then
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPiratePlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, TextHighlightColorTag), messagebox_cancel or messagebox_warning)
    else
      ShowMessageBoxGI(Screen, ReplaceColoredToken(
        LocalizedColorText('FormShip.SellOrBuyInPlanetAndBadRelations'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, TextHighlightColorTag), messagebox_cancel or messagebox_warning);
  end
  else
  begin
    RequestedScreenId := screen_info;
    Screen.RequestClose(1);
  end;
end;
{ @end $58B6C0 }

{ @routine $58B968 TfPanelPlanet_PlanetClicked }
procedure TfPanelPlanet.PlanetClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile) and
     (GovernmentScreen = Screen) then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (GovernmentScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  RequestedScreenId := screen_planet;
  Screen.RequestClose(1);
end;
{ @end $58B968 }

{ @routine $58B9F0 TfPanelPlanet_ProcessKeyDown }
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
{ @end $58B9F0 }

end.
