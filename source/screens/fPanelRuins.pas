unit fPanelRuins;
// Unit bracket (inferred): .text 0x006A98A0..0x006AA140; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, GI_MessageLoop;

type
  TfPanelRuins = class(TObjectEx) // @size 0x8
  public
    Screen: TMessageLoopGI; // @offset 0x4

    constructor Create; // @addr 0x6A98FC @ida "TfPanelRuins *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x6A9940 @ida "void __usercall $name(TfPanelRuins *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitializeLayout(Screen: TMessageLoopGI); // @addr 0x6A9974
    procedure OnOpen; // @addr $6A9B78
    procedure OnClose; // @addr $6A9BCC Native no-op lifecycle hook.
    procedure TakeOffForStationTravel; // @addr $6AA144
    procedure ProcessKeyDown(Key: Integer); // @addr $6AA344
    procedure Show; // @addr 0x6A9BD8
    procedure Hide; // @addr 0x6A9C18
    procedure ServicesClicked(Sender: TObjectGI); // @addr 0x6A9C58
    procedure EquipmentShopClicked(Sender: TObjectGI); // @addr 0x6A9CCC
    procedure GoodsShopClicked(Sender: TObjectGI); // @addr 0x6A9E18
    procedure InformationClicked(Sender: TObjectGI); // @addr 0x6A9F64
    procedure HangarClicked(Sender: TObjectGI); // @addr 0x6AA0B0
  end;

implementation

uses Classes, Windows, GR_Main, GR_Music, Globals, GlobalsV, GI_GraphButton, GI_MessageBox,
  aConst, aGalaxy, aGalaxyStruct, aMyFunction, aPlayer, aSaveLoad, aScript,
  fRuinsTalk, fPanelLoad, fSaveManager, fStarMap, ThreadCalc, aCalc;


{ @routine $6A98FC TfPanelRuins_Create }
constructor TfPanelRuins.Create;
begin
  inherited Create;
end;
{ @end $6A98FC }

{ @routine $6A9940 TfPanelRuins_Destroy }
destructor TfPanelRuins.Destroy;
begin
  inherited Destroy;
end;
{ @end $6A9940 }

{ @routine $6A9974 TfPanelRuins_InitializeLayout }
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
{ @end $6A9974 }

{ @routine $6A9B78 TfPanelRuins_OnOpen }
procedure TfPanelRuins.OnOpen;
begin
  with Screen.GetByName('PanelRuins') do SetActive(GetPlayer.RuinsMode = 0);
end;
{ @end $6A9B78 }

{ @routine $6A9BCC TfPanelRuins_OnClose }
procedure TfPanelRuins.OnClose;
begin
end;
{ @end $6A9BCC }

{ @routine $6A9BD8 TfPanelRuins_Show }
procedure TfPanelRuins.Show;
begin
  Screen.GetByName('PanelRuins').SetActive(True);
end;
{ @end $6A9BD8 }

{ @routine $6A9C18 TfPanelRuins_Hide }
procedure TfPanelRuins.Hide;
begin
  Screen.GetByName('PanelRuins').SetActive(False);
end;
{ @end $6A9C18 }

{ @routine $6A9C58 TfPanelRuins_ServicesClicked }
procedure TfPanelRuins.ServicesClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
    RequestedScreenId := screenRuinsTalk;
    Screen.RequestClose(1);
end;
{ @end $6A9C58 }

{ @routine $6A9CCC TfPanelRuins_EquipmentShopClicked }
procedure TfPanelRuins.EquipmentShopClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if (GetPlayer.RuinsMode > 0) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.DockedTo.TypeId = Byte(rstBusinessCenter)) and (GetPlayer.DebtDefaultCount > 1) then
    ShowMessageBoxGI(Screen, LocalizedColorText('FormRuins.BK.DebtNoAccess'), mbgCancel or mbgWarning)
  else
  begin
    RequestedScreenId := screenEquipmentShop;
    Screen.RequestClose(1);
  end;
end;
{ @end $6A9CCC }

{ @routine $6A9E18 TfPanelRuins_GoodsShopClicked }
procedure TfPanelRuins.GoodsShopClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if (GetPlayer.RuinsMode > 0) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.DockedTo.TypeId = Byte(rstBusinessCenter)) and (GetPlayer.DebtDefaultCount > 1) then
    ShowMessageBoxGI(Screen, LocalizedColorText('FormRuins.BK.DebtNoAccess'), mbgCancel or mbgWarning)
  else
  begin
    RequestedScreenId := screenGoodsShop;
    Screen.RequestClose(1);
  end;
end;
{ @end $6A9E18 }

{ @routine $6A9F64 TfPanelRuins_InformationClicked }
procedure TfPanelRuins.InformationClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if (GetPlayer.RuinsMode > 0) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
  if (GetPlayer.DockedTo.TypeId = Byte(rstBusinessCenter)) and (GetPlayer.DebtDefaultCount > 1) then
    ShowMessageBoxGI(Screen, LocalizedColorText('FormRuins.BK.DebtNoAccess'), mbgCancel or mbgWarning)
  else
  begin
    RequestedScreenId := screenInfo;
    Screen.RequestClose(1);
  end;
end;
{ @end $6A9F64 }

{ @routine $6AA0B0 TfPanelRuins_HangarClicked }
procedure TfPanelRuins.HangarClicked(Sender: TObjectGI);
begin
  if Screen.ExitCode <> 0 then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if (GetPlayer.PendingDockDialogue > 1) and (RuinsTalkScreen = Screen) then Exit;
  if (GetPlayer.RuinsMode > 0) and (RuinsTalkScreen = Screen) then Exit;
  if HasPendingScriptRequests then Exit;
    RequestedScreenId := screenHangar;
    Screen.RequestClose(1);
end;
{ @end $6AA0B0 }

{ @routine $6AA144 TfPanelRuins_TakeOffForStationTravel }
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
  if (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(3) then Galaxy.EnableDominatorSurfaces
  else Galaxy.DisableDominatorSurfaces;
  CalculatePlayerStarTurnAndWait;
  if ExitScreenLoop then Exit;
  QueueGalaxyTurnCalculation;
  StarMapWeaponPanelOpen := False;
  StarMapScreen.ResumeMode := smrTurnFilm;
  ScreenLoadMode := 2;
  PostLoadScreenId := screenStarMap;
  RequestedScreenId := screenLoad;
  if ActiveLoadPanel <> nil then
  begin
    ActiveLoadPanel.SelectBackgroundStyle(0);
    ActiveLoadPanel.RefreshBackgroundImages;
    ActiveLoadPanel.StartClosingShutters;
  end
  else Screen.RequestClose(1);
end;
{ @end $6AA144 }

{ @routine $6AA344 TfPanelRuins_ProcessKeyDown }
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
{ @end $6AA344 }
end.
