unit fPanelRuins;

interface

uses EC_Struct, GI_MessageLoop;

type
  TfPanelRuins = class(TObjectEx) // @size 0x8
  public
    Screen: TMessageLoopGI; // @offset 0x4

    constructor Create; // @addr 0x0067D6E8
    destructor Destroy; override; // @addr 0x0067D720
    procedure InitializeLayout(Screen: TMessageLoopGI); // @addr 0x0067D748
    procedure OnOpen; // @addr $67D914
    procedure OnClose; // @addr $67D958 Native no-op lifecycle hook.
    procedure TakeOffForStationTravel; // @addr $67DE38
    procedure ProcessKeyDown(Key: Integer); // @addr $67E020
    procedure Show; // @addr 0x0067D95C
    procedure Hide; // @addr 0x0067D994
    procedure ServicesClicked(Sender: TObjectGI); // @addr 0x0067D9CC
    procedure EquipmentShopClicked(Sender: TObjectGI); // @addr 0x0067DA2C
    procedure GoodsShopClicked(Sender: TObjectGI); // @addr 0x0067DB5C
    procedure InformationClicked(Sender: TObjectGI); // @addr 0x0067DC8C
    procedure HangarClicked(Sender: TObjectGI); // @addr 0x0067DDBC
  end;

implementation

uses Classes, Windows, GR_Main, GR_Music, Globals, GlobalsV, GI_GraphButton, GI_MessageBox,
  aConst, aGalaxy, aGalaxyStruct, aMyFunction, aPlayer, aSaveLoad, aScript,
  fRuinsTalk, fPanelLoad, fSaveManager, fStarMap, ThreadCalc, aCalc;


{ @routine $67D6E8 TfPanelRuins_Create }
constructor TfPanelRuins.Create;
begin
  inherited Create;
end;
{ @end $67D6E8 }

{ @routine $67D720 TfPanelRuins_Destroy }
destructor TfPanelRuins.Destroy;
begin
  inherited Destroy;
end;
{ @end $67D720 }

{ @routine $67D748 TfPanelRuins_InitializeLayout }
procedure TfPanelRuins.InitializeLayout(Screen: TMessageLoopGI);
begin
  Self.Screen := Screen;
  AppendLogTextThreadSafe('fPanelRuins... ');
  with Self.Screen.GetByName('PanelRuins') do
    SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
  AppendLogLineThreadSafe('ok');
  (Self.Screen.GetByName('PR_Gov') as TGraphButtonGI).UpCallback := ServicesClicked;
  (Self.Screen.GetByName('PR_Shop') as TGraphButtonGI).UpCallback := EquipmentShopClicked;
  (Self.Screen.GetByName('PR_Goods') as TGraphButtonGI).UpCallback := GoodsShopClicked;
  (Self.Screen.GetByName('PR_Info') as TGraphButtonGI).UpCallback := InformationClicked;
  (Self.Screen.GetByName('PR_Hangar') as TGraphButtonGI).UpCallback := HangarClicked;
end;
{ @end $67D748 }

{ @routine $67D914 TfPanelRuins_OnOpen }
procedure TfPanelRuins.OnOpen;
begin
  with Screen.GetByName('PanelRuins') do SetActive(GetPlayer.RuinsMode = 0);
end;
{ @end $67D914 }

{ @routine $67D958 TfPanelRuins_OnClose }
procedure TfPanelRuins.OnClose;
begin
end;
{ @end $67D958 }

{ @routine $67D95C TfPanelRuins_Show }
procedure TfPanelRuins.Show;
begin
  Screen.GetByName('PanelRuins').SetActive(True);
end;
{ @end $67D95C }

{ @routine $67D994 TfPanelRuins_Hide }
procedure TfPanelRuins.Hide;
begin
  Screen.GetByName('PanelRuins').SetActive(False);
end;
{ @end $67D994 }

{ @routine $67D9CC TfPanelRuins_ServicesClicked }
procedure TfPanelRuins.ServicesClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
    RequestedScreenId := screen_ruins_talk;
    Screen.RequestClose(1);
end;
{ @end $67D9CC }

{ @routine $67DA2C TfPanelRuins_EquipmentShopClicked }
procedure TfPanelRuins.EquipmentShopClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if (GetPlayer.RuinsMode > 0) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.DockedTo.TypeId = station_business_center) and (GetPlayer.DebtDefaultCount > 1) then
    ShowMessageBoxGI(Screen, LocalizedColorText('FormRuins.BK.DebtNoAccess'), messagebox_cancel or messagebox_warning)
  else
  begin
    RequestedScreenId := screen_equipment_shop;
    Screen.RequestClose(1);
  end;
end;
{ @end $67DA2C }

{ @routine $67DB5C TfPanelRuins_GoodsShopClicked }
procedure TfPanelRuins.GoodsShopClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if (GetPlayer.RuinsMode > 0) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.DockedTo.TypeId = station_business_center) and (GetPlayer.DebtDefaultCount > 1) then
    ShowMessageBoxGI(Screen, LocalizedColorText('FormRuins.BK.DebtNoAccess'), messagebox_cancel or messagebox_warning)
  else
  begin
    RequestedScreenId := screen_goods_shop;
    Screen.RequestClose(1);
  end;
end;
{ @end $67DB5C }

{ @routine $67DC8C TfPanelRuins_InformationClicked }
procedure TfPanelRuins.InformationClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if (GetPlayer.RuinsMode > 0) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.DockedTo.TypeId = station_business_center) and (GetPlayer.DebtDefaultCount > 1) then
    ShowMessageBoxGI(Screen, LocalizedColorText('FormRuins.BK.DebtNoAccess'), messagebox_cancel or messagebox_warning)
  else
  begin
    RequestedScreenId := screen_info;
    Screen.RequestClose(1);
  end;
end;
{ @end $67DC8C }

{ @routine $67DDBC TfPanelRuins_HangarClicked }
procedure TfPanelRuins.HangarClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if (GetPlayer.RuinsMode > 0) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
    RequestedScreenId := screen_hangar;
    Screen.RequestClose(1);
end;
{ @end $67DDBC }

{ @routine $67DE38 TfPanelRuins_TakeOffForStationTravel }
procedure TfPanelRuins.TakeOffForStationTravel;
var Index: Integer;
begin
  Galaxy.CheckIntegrityChecksum(189);
  CaptureSavePreview;
  CaptureGalaxyPreview(Screen);
  SaveManagerReturnScreenId := FormToId(Screen);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  if MusicManager.CategoryOverride = '' then MusicManager.RequestFadeOut;
  PlayerAutomaticControl := False;
  PruneExpiredPersistentPlayerMessages;
  GetPlayer.OrderTakeoff;
  for Index := 0 to Galaxy.Scripts.Count - 1 do TScript(Galaxy.Scripts[Index]).RunTurnCode;
  StarMapWeaponPanelOpen := False;
  FilmCameraFollow := True;
  PlayerStar.RefreshSpaceObjectPositions;
  RestoreTemporaryShopStock;
  RunGlobalScriptsForContext(GetPlayer.CurrentStar, 1);
  if (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(disease_holy_fanaticism) then Galaxy.EnableDominatorSurfaces
  else Galaxy.DisableDominatorSurfaces;
  CalculatePlayerStarTurnAndWait;
  if ExitScreenLoop then Exit;
  QueueGalaxyTurnCalculation;
  StarMapWeaponPanelOpen := False;
  StarMapScreen.ResumeMode := map_resume_playback;
  ScreenLoadMode := 2;
  PostLoadScreenId := screen_star_map;
  RequestedScreenId := screen_asset_loading;
  if ActiveLoadPanel <> nil then
  begin
    ActiveLoadPanel.SelectBackgroundStyle(0);
    ActiveLoadPanel.RefreshBackgroundImages;
    ActiveLoadPanel.StartClosingShutters;
  end
  else Screen.RequestClose(1);
end;
{ @end $67DE38 }

{ @routine $67E020 TfPanelRuins_ProcessKeyDown }
procedure TfPanelRuins.ProcessKeyDown(Key: Integer);
begin
  if Screen.ExitCode <> 0 then Exit;
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if not GetPlayer.IsDockedToShip then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (Key = Ord('G')) and Screen.GetByName('PR_Gov').Active then ServicesClicked(nil)
  else if (Key = Ord('E')) and Screen.GetByName('PR_Shop').Active then EquipmentShopClicked(nil)
  else if (Key = Ord('T')) and Screen.GetByName('PR_Goods').Active then GoodsShopClicked(nil)
  else if (Key = Ord('I')) and Screen.GetByName('PR_Info').Active then InformationClicked(nil)
  else if (Key = Ord('H')) and Screen.GetByName('PR_Hangar').Active then HangarClicked(nil);
end;
{ @end $67E020 }
end.
