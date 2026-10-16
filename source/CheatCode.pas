unit CheatCode;

interface

uses ab_Global, Classes;

type
  TCheatCallback = procedure;
  PCheatEntry = ^TCheatEntry;
  TCheatEntry = record // @size 8
    Text: WideString; // @offset 0
    Callback: TCheatCallback; // @offset 4
  end;
  TCheatList = class(TList) // @size $10
  public
    destructor Destroy; override; // @addr $684970
    function AddEntry(Entry: PCheatEntry): Integer; // @addr $684968
    function AddCheat(Text: WideString; Callback: TCheatCallback): Integer; // @addr $6849D0
    function GetEntry(Index: Integer): PCheatEntry; // @addr $6849BC
  end;

var
  CheatCandidateIndex: Integer = 0; // @addr $80F7F8
  CheatPrefixLength: Integer = 0; // @addr $80F7FC
  CheatPrefixSum: Integer = 0; // @addr $80F800

function IsCheatMessageBoxOpen: Boolean; // @addr $689318
procedure HandleDebugKey(Key: Word); // @addr $68939C @note "Ctrl+Shift key callback installed by Rangers. Ignores input during message boxes, disabled cheats and active calculation phases."

procedure AddCheatPoints(Points: Integer); // @addr $684A44
procedure ReportCheat(Points: Integer; const Name: WideString); // @addr $684A7C
procedure CheatRepair; // @addr $684D78
procedure CheatKlissanmax; // @addr $684ED8
procedure CheatPiratemax; // @addr $684FFC
procedure CheatWarriormax; // @addr $685164
procedure CheatKlissancall; // @addr $6852F4
procedure CheatPiratecall; // @addr $685500
procedure CheatRangerpoints; // @addr $6856E8
procedure CheatNextrank; // @addr $6857C4
procedure CheatCoolweapon; // @addr $6858D0
procedure CheatLowcostweapon; // @addr $685A48
procedure CheatBomb; // @addr $685BDC
procedure CheatRobotforce; // @addr $685D18
procedure CheatArtefact; // @addr $685E88
procedure CheatMoney; // @addr $685F94
procedure CheatDrop; // @addr $686100
procedure CheatPacking; // @addr $6862B8
procedure CheatKlissanitem; // @addr $686468
procedure CheatWeaponstrength; // @addr $68665C
procedure CheatTenbomb; // @addr $68693C
procedure CheatRangersdream; // @addr $686AF0
procedure CheatRndbase; // @addr $686CF0
procedure CheatMapsector; // @addr $686E50
procedure CheatHugemoney; // @addr $686F6C
procedure CheatPelengsurprise; // @addr $6870F0
procedure CheatSuperhull; // @addr $687240
procedure CheatBoom; // @addr $6873C0
procedure CheatHaterangers; // @addr $687524
procedure CheatPirates; // @addr $687650
procedure CheatGun; // @addr $6877A4
procedure CheatVertix; // @addr $687938
procedure CheatDevice; // @addr $6879F0
procedure CheatArts; // @addr $687AC8
procedure CheatModule; // @addr $687C90
procedure CheatSkill; // @addr $687D60
procedure CheatProgram; // @addr $687E94
procedure CheatIllness; // @addr $687F38
procedure CheatStimulant; // @addr $688008
procedure CheatIdeal; // @addr $6880E0
procedure CheatShowmap; // @addr $6881BC
procedure CheatMedal; // @addr $688294
procedure SetCheatDominatorLevel(Level: Integer); // @addr $688400
procedure CheatHorror; // @addr $68852C
procedure CheatNightmare; // @addr $688538
procedure CheatHell; // @addr $688544
procedure CheatTechnic; // @addr $688550
procedure CheatAmmo; // @addr $68860C
procedure CheatGod; // @addr $6886BC
procedure CheatHole; // @addr $6887CC
procedure CheatWin; // @addr $688C70
procedure CheatHweapon; // @addr $688CE4
procedure CheatUltrascan; // @addr $688E68
procedure CheatTentm; // @addr $688F2C
procedure CheatEncharge; // @addr $688FD8
procedure CheatExpa; // @addr $6890A8
procedure CheatMadeinchina; // @addr $689128
procedure CheatZawarudo; // @addr $6891EC
procedure ShowCheatFeedback(Text: WideString); // @addr $6892A4
procedure CheatMakedump; // @addr $6894A4
procedure CheatFitness; // @addr $6895B8
procedure CheatExtraone; // @addr $6898E8
procedure CheatSudo; // @addr $689A9C
procedure CheatEvents; // @addr $689DC8
procedure CheatSeed; // @addr $68A058
procedure CheatInfos; // @addr $68A178

implementation

// @unit-initialization $806920
// @unit-finalization $68A43C

uses aKling, GI_MessageLoop, GI_MessageBox, aGalaxy, ThreadCalc, aPlayer, aShip,
  aItem, aConst, aMyFunction, fStarMap, Globals, GlobalsV, aPlanet, aGalaxyEvent, SysUtils, GR_Main, fShip2, fRating2, EC_Mem, Math, ab_Ship, ab_Hit, ab_Object, fPanelMain, aGalaxyStruct, fEquipmentShop, fScore, fAbout, fHangar, fScaner, fGoodsShop2, fPlanet, fPlanetNO, fInfo, aRanger, aTranclucator, aRuins, aNormalShip, SE_Space, SE_Process, EC_Struct, fRuinsTalk, EC_BlockPar, fListBox, fTextBox, SE_Hole, aScript, fGameSettings2, GI_GraphButton, fGalaxy2, fSaveManager, EC_Str;

var
  CheatEntries: TCheatList; // @addr $81B8E8

{ @routine $684968 TCheatList_AddEntry }
function TCheatList.AddEntry(Entry: PCheatEntry): Integer;
begin
  Result := inherited Add(Entry);
end;
{ @end $684968 }

{ @routine $684970 TCheatList_Destroy }
destructor TCheatList.Destroy;
var
  Index: Integer;
begin
  for Index := 0 to Count - 1 do Dispose(GetEntry(Index));
  inherited;
end;
{ @end $684970 }

{ @routine $6849BC TCheatList_GetEntry }
function TCheatList.GetEntry(Index: Integer): PCheatEntry;
begin
  Result := PCheatEntry(inherited Items[Index]);
end;
{ @end $6849BC }

{ @routine $6849D0 TCheatList_AddCheat }
function TCheatList.AddCheat(Text: WideString; Callback: TCheatCallback): Integer;
var
  Entry: PCheatEntry;
begin
  New(Entry);
  Entry.Text := Text;
  Entry.Callback := Callback;
  Result := AddEntry(Entry);
end;
{ @end $6849D0 }

{ @routine $684A44 AddCheatPoints }
procedure AddCheatPoints(Points: Integer);
var
  PreviousPoints: Integer;
begin
  PreviousPoints := Galaxy.GetCheatPoints;
  Galaxy.SetCheatPoints(PreviousPoints + Points);
  if (PreviousPoints = 0) and (Points > 0) then Galaxy.AppendIntegritySnapshot;
end;
{ @end $684A44 }

{ @routine $684A7C ReportCheat }
procedure ReportCheat(Points: Integer; const Name: WideString);
var
  Text: WideString;
  Parent: TMessageLoopGI;
  Event: TGalaxyEvent;
begin
  Text := LocalizedColorText('Cheat.Info');
  ReplaceTextToken(Text, '<Name>', Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<CheatPoints>', IntToStr(Points), TextHighlightColorTag);
  if Galaxy <> nil then
  begin
    AddCheatPoints(Points);
    Event := AddGalaxyEvent('PlayerEntersCheatCode');
    Event.AddTextData(CheatEntries.GetEntry(CheatCandidateIndex).Text);
    Event.AddData(Points);
  end;
  Text := Text + #13#10 + LocalizedColorText('Cheat.Ok');
  // Native code reads the total without a nil-galaxy guard.
  ReplaceTextToken(Text, '<AllPoints>', IntToStr(Galaxy.GetCheatPoints), TextHighlightColorTag);
  if ShipScreen.IsOpen then Parent := ShipScreen
  else if RangerRatingScreen.IsOpen then Parent := RangerRatingScreen
  else Parent := RegisteredScreens[CurrentScreenId] as TMessageLoopGI;
  ShowMessageBoxGI(Parent, Text, mbgCancel);
  FullFrameRedrawRequested := True;
  Parent.InvalidateViewport;
  Parent.DrawQueuedUpdateRects;
  if ShipScreen.IsOpen then
  begin
    ShipScreen.ShipStateChanged := True;
    ShipScreen.ReopenRequested := True;
    ShipScreen.PlayTransitionSounds := False;
    ShipScreen.CloseClicked(nil);
  end;
end;
{ @end $684A7C }

{ @routine $684D78 CheatRepair }
procedure CheatRepair;
var
  I: Integer;
  Item: TEquipment;
begin
  if (Galaxy = nil) or
    (CurrentScreenId <> screen_star_map) or (StarMapScreen.Mode <> map_mode_orders) or (GetPlayer = nil) or not GetPlayer.InNormalSpace then Exit;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.ItemType = item_hull) or ((Item.EquippedFlag <> 0) and (Item.ConditionPercent < 90)) then Item.Repair;
  end;
  for I := 0 to GetPlayer.Artefacts.Count - 1 do
  begin
    Item := GetPlayer.Artefacts[I];
    if (Item.EquippedFlag <> 0) and (Item.ConditionPercent < 90) then Item.Repair;
  end;
  ReportCheat(40, DecodeTextW('ROEMPOAYIURU')); // 'REPAIR'
end;
{ @end $684D78 }

{ @routine $684ED8 CheatKlissanmax }
procedure CheatKlissanmax;
var
  PlanetIndex, StarIndex: Integer;
  Planet: TPlanet;
  Star: TStar;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for StarIndex := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[StarIndex];
    if not ((Star.ControlFaction = faction_dominators) and (Star.Status.CustomFaction = '')) then Continue;
    PlanetIndex := -1;
    while True do
    begin
      if Star.ShipTypeCounts[ship_dominator] >= 12 then Break;
      Planet := nil;
      while True do
      begin
        Inc(PlanetIndex);
        if PlanetIndex >= Star.Planets.Count then PlanetIndex := 0;
        Planet := Star.Planets[PlanetIndex];
        if Planet.OwnerId <> owner_uninhabited then Break;
      end;
      Planet.SpawnWeightedDominatorShip;
    end;
  end;
  ReportCheat(20, DecodeTextW('KULTIZSOSOASNOMEANXI')); // 'KLISSANMAX'
end;
{ @end $684ED8 }

{ @routine $684FFC CheatPiratemax }
procedure CheatPiratemax;
var
  PlanetIndex, StarIndex: Integer;
  Planet: TPlanet;
  Star: TStar;
  Created: Integer;
begin
  Created := 0;
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for StarIndex := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[StarIndex];
    if not ((Star.ControlFaction = faction_pirates) and (Star.Status.CustomFaction = '')) then Continue;
    PlanetIndex := -1;
    while True do
    begin
      if Star.CountPirateShips(True) >= 12 then Break;
      Planet := nil;
      while True do
      begin
        Inc(PlanetIndex);
        if PlanetIndex >= Star.Planets.Count then PlanetIndex := 0;
        Planet := Star.Planets[PlanetIndex];
        if Planet.OwnerId <> owner_uninhabited then Break;
      end;
      Planet.BuyWarrior(100);
      Inc(Created);
      if Created >= 500 then
      begin
        ShowCheatFeedback('Sudden break');
        Break;
      end;
    end;
  end;
  ReportCheat(20, DecodeTextW('PVISREAXTMETMOARX9')); // 'PIRATEMAX'
end;
{ @end $684FFC }

{ @routine $685164 CheatWarriormax }
procedure CheatWarriormax;
var
  PlanetIndex, StarIndex: Integer;
  Planet: TPlanet;
  Star: TStar;
  Created: Integer;
begin
  Created := 0;
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for StarIndex := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[StarIndex];
    if (Star.ControlFaction <> faction_coalition) or (Star.Status.CustomFaction <> '') then Continue;
    for PlanetIndex := 0 to Star.Planets.Count - 1 do
    begin
      Planet := Star.Planets[PlanetIndex];
      if Planet.OwnerId = owner_uninhabited then Continue;
      while (Planet.Warriors.Count < RemapClamped(Planet.Radius, 60, 100, 2, 6)) and (Created < 500) do
      begin
        Planet.BuyWarrior(100);
        Inc(Created);
      end;
    end;
  end;
  ReportCheat(20, DecodeTextW('WIAGRARUILOIRAMOARX9')); // 'WARRIORMAX'
end;
{ @end $685164 }

{ @routine $6852F4 CheatKlissancall }
procedure CheatKlissancall;
var
  DistanceIndex, ShipIndex, Sent, Eligible: Integer;
  Star: TStar;
  Ship: TShip;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  Sent := 0;
  for DistanceIndex := 1 to Galaxy.Stars.Count - 1 do
  begin
    Star := GetPlayer.CurrentStar.StarDistances[DistanceIndex].Star as TStar;
    if not ((Star.ControlFaction = faction_dominators) and (Star.Battle = 0) and Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]) and (Star.Status.CustomFaction = '')) then Continue;
    Eligible := 0;
    for ShipIndex := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[ShipIndex];
      if (Ship.OwnerId = owner_dominator) and (Ship.Order = order_none) and Ship.InNormalSpace and not Ship.HasIndependentScriptFaction then
        Inc(Eligible);
    end;
    if Eligible > 2 then
      for ShipIndex := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[ShipIndex];
        if (Ship.OwnerId = owner_dominator) and (Ship.Order = order_none) and Ship.InNormalSpace and not Ship.HasIndependentScriptFaction then
        begin
          Ship.OrderJump(GetPlayer.CurrentStar, True);
          Inc(Sent);
          Dec(Eligible);
          if Eligible <= 2 then Break;
        end;
      end;
    if Sent > 20 then Break;
  end;
  ReportCheat(20, DecodeTextW('KOLEINSOSUAINOCRABLELS')); // 'KLISSANCALL'
end;
{ @end $6852F4 }

{ @routine $685500 CheatPiratecall }
procedure CheatPiratecall;
var
  DistanceIndex, ShipIndex, Sent, Eligible: Integer;
  Star: TStar;
  Ship: TShip;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  Sent := 0;
  for DistanceIndex := 1 to Galaxy.Stars.Count - 1 do
  begin
    Star := GetPlayer.CurrentStar.StarDistances[DistanceIndex].Star as TStar;
    if not ((Star.ControlFaction = faction_pirates) and (Star.Battle = 0) and (Star.Status.CustomFaction = '')) then Continue;
    Eligible := 0;
    for ShipIndex := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[ShipIndex];
      if (Ship.OwnerId = owner_pirate) and (Ship.Order = order_none) and Ship.InNormalSpace and not Ship.HasIndependentScriptFaction then
        Inc(Eligible);
    end;
    if Eligible > 2 then
      for ShipIndex := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[ShipIndex];
        if (Ship.OwnerId = owner_pirate) and (Ship.Order = order_none) and Ship.InNormalSpace and not Ship.HasIndependentScriptFaction then
        begin
          Ship.OrderJump(GetPlayer.CurrentStar, True);
          Inc(Sent);
          Dec(Eligible);
          if Eligible <= 2 then Break;
        end;
      end;
    if Sent > 20 then Break;
  end;
  ReportCheat(20, DecodeTextW('PAIORNAMTZEXCOASLOL')); // 'PIRATECALL'
end;
{ @end $685500 }

{ @routine $6856E8 CheatRangerpoints }
procedure CheatRangerpoints;
begin
  if Galaxy = nil then Exit;
  if CurrentScreenId = screen_ship then Exit;
  if GetPlayer = nil then Exit;
  if not GetPlayer.IsDockedToShip then Exit;
  if GetPlayer.DockedTo.TypeId <> station_ranger_center then Exit;
  if GetPlayer.FreeExperience >= 1000 then Exit;
  GetPlayer.GainExperience(1000, experience_unscaled);
  ReportCheat(150, DecodeTextW('RIALNOGDEPROPRONIHNITIS')); // 'RANGERPOINTS'
end;
{ @end $6856E8 }

{ @routine $6857C4 CheatNextrank }
procedure CheatNextrank;
begin
  ReportCheat(90, DecodeTextW('NIETXATARNARNAK')); // 'NEXTRANK'
  if (Galaxy <> nil) and (GetPlayer <> nil) and (CurrentScreenId <> screen_ship) then
  begin
    if GetPlayer.Rank <> High(TShipRank) then GetPlayer.AddRankPoints(GetPlayer.GetRankPointsToNextRank);
    if GetPlayer.PirateClanReal and (GetPlayer.PirateRank <> High(TShipRank)) then
      GetPlayer.AddPirateRankPoints(GetPlayer.GetPirateRankPointsToNextRank);
  end;
  if CurrentScreenId = screen_ruins_talk then
  begin
    RuinsTalkScreen.I_Start;
    RuinsTalkScreen.RestartTextPresentation;
  end;
end;
{ @end $6857C4 }

{ @routine $6858D0 CheatCoolweapon }
procedure CheatCoolweapon;
var
  Item: TEquipment;
begin
  if (Galaxy = nil) or
    (CurrentScreenId = screen_ship) or (GetPlayer = nil) or not GetPlayer.IsOnPlanet then Exit;
  RestoreTemporaryShopStock;
  Item := TWeapon.Create;
  GetPlayer.CurrentPlanet.EquipmentShop.Add(Item);
  (Item as TWeapon).Init(TItemType(RandomIntRange(Ord(item_multiresonator), Ord(item_turbogravitron))), RandomIntRange(50, 100),
    RandomIntRange(4, 8), RaceToOwner(GetPlayer.CurrentPlanet.RaceId));
  (Item as TWeapon).Improve(upgrade_random);
  BuildTemporaryShopSlotGrid;
  if CurrentScreenId = screen_equipment_shop then
  begin
    EquipmentShopScreen.BuildGoodsControls;
    EquipmentShopScreen.UpdateScrollButtons;
  end;
  ReportCheat(100, DecodeTextW('CRONOBLAWSENAIPROSN')); // 'COOLWEAPON'
end;
{ @end $6858D0 }

{ @routine $685A48 CheatLowcostweapon }
procedure CheatLowcostweapon;
var
  Item: TWeapon;
  Info: PWeaponInfo;
begin
  if (Galaxy = nil) or
    (CurrentScreenId = screen_ship) or (GetPlayer = nil) or not GetPlayer.IsOnPlanet then Exit;
  RestoreTemporaryShopStock;
  Info := Galaxy.SelectWeaponInfo(RandomIntRange(1, 100000), [availability_unrestricted], 8, 1);
  Item := CreateGeneratedWeapon(Info, RandomIntRange(14, 200), RandomIntRange(1, 8), RaceToOwner(GetPlayer.CurrentPlanet.RaceId));
  GetPlayer.CurrentPlanet.EquipmentShop.Add(Item);
  Item.Cost := RandomIntRange(1, 10);
  if Item.Weight > 100 then Item.Improve(upgrade_major);
  BuildTemporaryShopSlotGrid;
  if CurrentScreenId = screen_equipment_shop then
  begin
    EquipmentShopScreen.BuildGoodsControls;
    EquipmentShopScreen.UpdateScrollButtons;
  end;
  ReportCheat(20, DecodeTextW('LLOYWACSONSETIWIEFAIPROLNO')); // 'LOWCOSTWEAPON'
end;
{ @end $685A48 }

{ @routine $685BDC CheatBomb }
procedure CheatBomb;
var
  Item: TArtefact;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.InNormalSpace or (CurrentScreenId <> screen_star_map) or (StarMapScreen.Mode <> map_mode_orders) then Exit;
  Item := TArtefact.Create;
  Item.Init(GetPlayer.HomePlanet.OwnerId, artefact_bomb);
  GetPlayer.Artefacts.Add(Item);
  Item := TArtefact.Create;
  Item.Init(GetPlayer.HomePlanet.OwnerId, artefact_bomb);
  GetPlayer.Artefacts.Add(Item);
  GetPlayer.RefreshDerivedStats(True);
  StarMapScreen.MainPanel.RefreshMoneyAndCargo;
  ReportCheat(60, DecodeTextW('BRODMEB')); // 'BOMB'
end;
{ @end $685BDC }

{ @routine $685D18 CheatRobotforce }
procedure CheatRobotforce;
begin
  if (Galaxy = nil) or (GetPlayer = nil) or GetPlayer.InHyperspace then Exit;
  GetPlayer.Artefacts.Add(CreateConfiguredArtefactByItemType(artefact_tranclucator, owner_maloc));
  GetPlayer.Artefacts.Add(CreateConfiguredArtefactByItemType(artefact_tranclucator, owner_peleng));
  GetPlayer.Artefacts.Add(CreateConfiguredArtefactByItemType(artefact_tranclucator, owner_human));
  GetPlayer.Artefacts.Add(CreateConfiguredArtefactByItemType(artefact_tranclucator, owner_feyan));
  GetPlayer.Artefacts.Add(CreateConfiguredArtefactByItemType(artefact_tranclucator, owner_gaal));
  GetPlayer.Artefacts.Add(CreateConfiguredArtefactByItemType(artefact_tranclucator, owner_uninhabited));
  GetPlayer.Artefacts.Add(CreateConfiguredArtefactByItemType(artefact_tranclucator, owner_pirate));
  GetPlayer.RefreshDerivedStats(True);
  ReportCheat(60, DecodeTextW('RFOCBIOLTQFNOCROCRE')); // 'ROBOTFORCE'
end;
{ @end $685D18 }

{ @routine $685E88 CheatArtefact }
procedure CheatArtefact;
var
  Item: TItem;
begin
  if (Galaxy = nil) or (GetPlayer = nil) or (CurrentScreenId <> screen_arcade_battle) then Exit;
  Item := CreateRandomLootItem(loot_any_available, RaceToOwner(GetPlayer.HomePlanet.RaceId), RandomIntRange(1, 1000000000));
  if Item is TArtefact then GetPlayer.Artefacts.Add(Item)
  else GetPlayer.Inventory.Add(Item);
  GetPlayer.RefreshDerivedStats(True);
  ReportCheat(40, DecodeTextW('ASRATIENFOARCAT')); // 'ARTEFACT'
end;
{ @end $685E88 }

{ @routine $685F94 CheatMoney }
procedure CheatMoney;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  if not ((GetPlayer.InNormalSpace and (CurrentScreenId = screen_star_map) and (StarMapScreen.Mode = map_mode_orders)) or
    (CurrentScreenId = screen_planet) or (CurrentScreenId = screen_uninhabited_planet) or
    (CurrentScreenId = screen_goods_shop) or (CurrentScreenId = screen_equipment_shop)) then Exit;
  GetPlayer.SetMoney(GetPlayer.Money + 10000);
  if CurrentScreenId = screen_star_map then StarMapScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_planet then PlanetScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_uninhabited_planet then UninhabitedPlanetScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_goods_shop then
  begin
    GoodsShopScreen.MainPanel.RefreshMoneyAndCargo;
    GoodsShopScreen.RefreshGoodsDisplay;
  end
  else if CurrentScreenId = screen_equipment_shop then EquipmentShopScreen.MainPanel.RefreshMoneyAndCargo;
  ReportCheat(40, DecodeTextW('MEOLNIERYE'));
end;
{ @end $685F94 }

{ @routine $686100 CheatDrop }
procedure CheatDrop;
var
  Ship, Nearest: TShip;
  I: Integer;
  Distance, BestDistance: Single;
  Item: TEquipment;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.InNormalSpace or (CurrentScreenId <> screen_star_map) or (StarMapScreen.Mode <> map_mode_orders) then Exit;
  BestDistance := 1.0e30;
  Nearest := nil;
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if (GetPlayer = Ship) or (BlazerShip = Ship) or (KellerShip = Ship) or (TerronShip = Ship) or
      not (Ship.TypeId in [ship_dominator..ship_warrior]) or Ship.IsOutsideStarSpace then Continue;
    Distance := PointDistanceSquared(Ship.Position, GetPlayer.Position);
    if Distance < BestDistance then
    begin
      BestDistance := Distance;
      Nearest := Ship;
    end;
  end;
  if Nearest = nil then Exit;
  Ship := Nearest;
  for I := Ship.Inventory.Count - 1 downto 0 do
  begin
    Item := Ship.Inventory[I];
    if Item.ItemType = item_hull then Continue;
    if (Item.ItemType = item_engine) and (Item.EquippedFlag <> 0) then Continue;
    if (Item.ItemType = item_fuel_tanks) and (Item.EquippedFlag <> 0) then Continue;
    Ship.DropCarriedItemAsMovingLoot(Item);
  end;
  Ship.RefreshDerivedStats(True);
  ReportCheat(60, DecodeTextW('DIRIOSPA')); // 'DROP'
end;
{ @end $686100 }

{ @routine $6862B8 CheatPacking }
procedure CheatPacking;
var
  Item: TItem;
  I: Integer;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or GetPlayer.InHyperspace or ((CurrentScreenId = screen_star_map) and (StarMapScreen.Mode <> map_mode_orders)) then Exit;
  for I := 1 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.ItemType <> item_hull then Item.Weight := Max(1, Item.Weight div 2);
  end;
  for I := 0 to GetPlayer.Artefacts.Count - 1 do
  begin
    Item := GetPlayer.Artefacts[I];
    if Item.ItemType = artefact_tranclucator then
      TTranclucator((Item as TArtefactTranclucator).Ship).ArtefactSize := Max(1, Item.Weight div 2);
    Item.Weight := Max(1, Item.Weight div 2);
  end;
  GetPlayer.RefreshDerivedStats(True);
  StarMapScreen.MainPanel.RefreshMoneyAndCargo;
  ReportCheat(300, DecodeTextW('PRANCIKCIINEG')); // 'PACKING'
end;
{ @end $6862B8 }

{ @routine $686468 CheatKlissanitem }
procedure CheatKlissanitem;
var
  Item: TWeapon;
  Info: PWeaponInfo;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.IsDockedToShip or (CurrentScreenId = screen_ship) or (GetPlayer.DockedTo.TypeId <> station_science_base) then Exit;
  Info := Galaxy.SelectWeaponInfo(RandomIntRange(1, 100000), [availability_not_sold_node_repair], 8, 1);
  Item := CreateGeneratedWeapon(Info, RandomIntRange(77, 200), RandomIntRange(1, 8), owner_dominator);
  case RandomIntRange(1, 3) of
    1: Item.DominatorSeries := series_blazer;
    2: Item.DominatorSeries := series_keller;
    3: Item.DominatorSeries := series_terron;
  end;
  GetPlayer.Inventory.Add(Item);
  GetPlayer.RefreshDerivedStats(True);
  if CurrentScreenId = screen_ruins_talk then StarMapScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_goods_shop then
  begin
    GoodsShopScreen.MainPanel.RefreshMoneyAndCargo;
    GoodsShopScreen.RefreshGoodsDisplay;
  end
  else if CurrentScreenId = screen_equipment_shop then EquipmentShopScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_info then InfoScreen.MainPanel.RefreshMoneyAndCargo;
  ReportCheat(160, DecodeTextW('KALKINSOSUANNIINTHEMM')); // 'KLISSANITEM'
end;
{ @end $686468 }

{ @routine $68665C CheatWeaponstrength }
procedure CheatWeaponstrength;
var
  I, J, K: Integer;
  Star: TStar;
  Ship: TShip;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.IsDockedToShip or (CurrentScreenId = screen_ship) or (GetPlayer.DockedTo.TypeId <> station_pirate_base) then Exit;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if Ship.TypeId in [ship_dominator, ship_tranclucator..station_custom] then Continue;
      if not ((Ship.TypeId = ship_pirate) or (GetPlayer = Ship) or
        ((Ship.TypeId = ship_ranger) and ((Ship as TRanger).PreferredCareer = career_pirate))) then
      begin
        if GetPlayer <> Ship.PartnerShip then Ship.ChangeRelationToRanger(GetPlayer, -60);
        Continue;
      end;
      for K := 1 to Ship.WeaponCount do
      begin
        Ship.Weapons[K].MaxDamage := Min(255, Ship.Weapons[K].MaxDamage + RandomIntRange(10, 20));
        if GetPlayer <> Ship then Ship.ChangeRelationToRanger(GetPlayer, 50);
      end;
      Ship.RefreshDerivedStats(True);
    end;
  end;
  GetPlayer.CareerStatus[career_pirate] := 100;
  GetPlayer.ChangePlanetRelations(nil, relation_change_subtract, 60, [owner_maloc, owner_human, owner_feyan, owner_gaal]);
  if CurrentScreenId = screen_ruins_talk then StarMapScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_goods_shop then
  begin
    GoodsShopScreen.MainPanel.RefreshMoneyAndCargo;
    GoodsShopScreen.RefreshGoodsDisplay;
  end
  else if CurrentScreenId = screen_equipment_shop then EquipmentShopScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_info then InfoScreen.MainPanel.RefreshMoneyAndCargo;
  ReportCheat(200, DecodeTextW('WRENARPBOSNASOTERLEINAGATOHE')); // 'WEAPONSTRENGTH'
end;
{ @end $68665C }

{ @routine $68693C CheatTenbomb }
procedure CheatTenbomb;
var
  Item: TArtefact;
  Radius, Angle: Single;
  I: Integer;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.InNormalSpace or (CurrentScreenId <> screen_star_map) or (StarMapScreen.Mode <> map_mode_orders) then Exit;
  for I := 0 to 9 do
  begin
    Item := TArtefact.Create;
    Item.Init(GetPlayer.HomePlanet.OwnerId, artefact_bomb);
    Radius := RandomIntRange(300, 700);
    Angle := HeadingDegreesToRadians(RandomIntRange(0, 360));
    Item.Position.X := GetPlayer.Position.X + Sin(Angle) * Radius;
    Item.Position.Y := GetPlayer.Position.Y - Cos(Angle) * Radius;
    GetPlayer.CurrentStar.Items.Add(Item);
    Item.GetGraphObject.AttachToSpace(SpaceProcess.Space);
    Item.DestroyFlag := 2;
  end;
  ReportCheat(140, DecodeTextW('TIECN0BEOAMOB')); // 'TENBOMB'
end;
{ @end $68693C }

{ @routine $686AF0 CheatRangersdream }
procedure CheatRangersdream;
var
  Item: TProtoplasm;
  Count, Total: Integer;
  X, Y: Single;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.InNormalSpace or (CurrentScreenId <> screen_star_map) or (StarMapScreen.Mode <> map_mode_orders) then Exit;
  Total := 0;
  while Total < 10000 do
  begin
    Item := TProtoplasm.Create;
    if 10000 - Total < 100 then Count := 10000 - Total
    else Count := RandomIntRange(10, 100);
    Item.Init(Count, 1);
    Inc(Total, Count);
    Item.DominatorSeries := TDominatorSeries(RandomIntRange(0, 2));
    repeat
      X := RandomIntRange(-250, 250);
      Y := RandomIntRange(-250, 250);
    until (Sqr(X) + Sqr(Y) > Sqr(50)) and (Sqr(X) + Sqr(Y) < Sqr(250));
    Item.Position.X := GetPlayer.Position.X + X;
    Item.Position.Y := GetPlayer.Position.Y + Y;
    GetPlayer.CurrentStar.Items.Add(Item);
    Item.GetGraphObject.AttachToSpace(SpaceProcess.Space);
  end;
  ReportCheat(140, DecodeTextW('RIALNEGREFRESIDUREEKALMA')); // 'RANGERSDREAM'
end;
{ @end $686AF0 }

{ @routine $686CF0 CheatRndbase }
procedure CheatRndbase;
var
  Station: TRuins;
  Ship: TShip;
  I, TotalKinds, Remaining, Choice: Integer;
  Kind: TStationType;
  Kinds: TShipTypeMask;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  TotalKinds := 7;
  Remaining := TotalKinds;
  Kinds := [station_ranger_center..station_dominion];
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if not (Ship is TRuins) then Continue;
    Dec(Remaining);
    Exclude(Kinds, Ship.TypeId);
  end;
  if TotalKinds - Remaining >= 3 then Exit;
  Choice := RandomIntRange(1, Remaining);
  I := 0;
  for Kind := station_ranger_center to station_dominion do
    if Kind in Kinds then
    begin
      Inc(I);
      if I = Choice then
      begin
        Station := TRuins.Create;
        Station.Init(Kind, GetPlayer.CurrentStar, '');
        Break;
      end;
    end;
  ReportCheat(30, DecodeTextW('RONNDOBNASSAEY')); // 'RNDBASE'
end;
{ @end $686CF0 }

{ @routine $686E50 CheatMapsector }
procedure CheatMapsector;
var
  I: Integer;
  Constellation: TConstellation;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.IsDockedToShip or (CurrentScreenId = screen_ship) or (GetPlayer.DockedTo.TypeId <> station_pirate_base) then Exit;
  I := 0;
  // Native search skips hidden sectors here, then randomly seeks a hidden one.
  while I < Galaxy.Constellations.Count do
  begin
    if TConstellation(Galaxy.Constellations[I]).Visible then Break;
    Inc(I);
  end;
  if I >= Galaxy.Constellations.Count then Exit;
  while True do
  begin
    Constellation := Galaxy.Constellations[RandomIntRange(0, Galaxy.Constellations.Count - 1)];
    if not Constellation.Visible then
    begin
      Constellation.Visible := True;
      ReportCheat(20, DecodeTextW('MOARPESHESCOTROLR2')); // 'MAPSECTOR'
      Break;
    end;
  end;
end;
{ @end $686E50 }

{ @routine $686F6C CheatHugemoney }
procedure CheatHugemoney;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  if not ((GetPlayer.InNormalSpace and (CurrentScreenId = screen_star_map) and (StarMapScreen.Mode = map_mode_orders)) or
    (CurrentScreenId = screen_planet) or (CurrentScreenId = screen_uninhabited_planet) or
    (CurrentScreenId = screen_goods_shop) or (CurrentScreenId = screen_equipment_shop)) then Exit;
  GetPlayer.SetMoney((GetPlayer.Money div 1000000 + 1) * 1000000);
  if CurrentScreenId = screen_star_map then StarMapScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_planet then PlanetScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_uninhabited_planet then UninhabitedPlanetScreen.MainPanel.RefreshMoneyAndCargo
  else if CurrentScreenId = screen_goods_shop then
  begin
    GoodsShopScreen.MainPanel.RefreshMoneyAndCargo;
    GoodsShopScreen.RefreshGoodsDisplay;
  end
  else if CurrentScreenId = screen_equipment_shop then EquipmentShopScreen.MainPanel.RefreshMoneyAndCargo;
  ReportCheat(300, DecodeTextW('HAUNGLESMIOMNEELYS'));
end;
{ @end $686F6C }

{ @routine $6870F0 CheatPelengsurprise }
procedure CheatPelengsurprise;
var
  Item: TItem;
  I: Integer;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.IsOnPlanet or (GetPlayer.CurrentPlanet.OwnerId <> owner_peleng) or (CurrentScreenId = screen_ship) then Exit;
  for I := 0 to TemporaryShopSlots.Count - 1 do
  begin
    Item := TShopSlot(TemporaryShopSlots[I]).Item;
    if (Item <> nil) and (Item is TWeapon) then
      (Item as TWeapon).Range := (Item as TWeapon).Range * 2;
  end;
  GetPlayer.ChangePlanetRelations(nil, relation_change_subtract, 50, [owner_maloc, owner_human, owner_feyan, owner_gaal]);
  ReportCheat(100, DecodeTextW('PLEVLIESNOGASRUEROPTROINSAEN')); // 'PELENGSURPRISE'
end;
{ @end $6870F0 }

{ @routine $687240 CheatSuperhull }
procedure CheatSuperhull;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or GetPlayer.InHyperspace or ((CurrentScreenId = screen_star_map) and (StarMapScreen.Mode <> map_mode_orders)) then Exit;
  GetPlayer.GetHull.Weight := Min(2000, Round(GetPlayer.GetHull.Weight * 1.3));
  GetPlayer.GetHull.HullPoints := GetPlayer.GetHull.Weight;
  GetPlayer.RefreshDerivedStats(True);
  GetPlayer.RefreshGraphicSize;
  StarMapScreen.MainPanel.RefreshMoneyAndCargo;
  ReportCheat(250, DecodeTextW('SRUNPRESROHLUALELS')); // 'SUPERHULL'
end;
{ @end $687240 }

{ @routine $6873C0 CheatBoom }
procedure CheatBoom;
var
  I: Integer;
  Ship: TShip;
begin
  if Galaxy = nil then Exit;
  if GetPlayer = nil then Exit;
  if CurrentScreenId = screen_arcade_battle then
    if KellerArcadeShip = nil then
      for I := PlayerArcadeShip.Enemies.Count - 1 downto 0 do
        TabHit(PlayerArcadeShip.Enemies[I]).ApplyDamage(
          Round(TabHit(PlayerArcadeShip.Enemies[I]).Health * 2 / ShieldDamageScale), nil, False);
  if CurrentScreenId = screen_star_map then
    for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
    begin
      Ship := GetPlayer.CurrentStar.Ships[I];
      if GetPlayer <> Ship then
        if not Ship.InHyperspace then
          if (Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> owner_uninhabited) then
            Ship.DestroyQueued := True;
    end;
  ReportCheat(30, DecodeTextW('BLOSOMM')); // 'BOOM'
end;
{ @end $6873C0 }

{ @routine $687524 CheatHaterangers }
procedure CheatHaterangers;
const
  ShipTypes = [hull_pirate..hull_diplomat];
  Owners = [owner_maloc..owner_pirate];
var
  I: Integer;
  Ship: TShip;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.InNormalSpace or (CurrentScreenId <> screen_star_map) or (StarMapScreen.Mode <> map_mode_orders) then Exit;
  ReportCheat(10, DecodeTextW('HEAVTIERROASNAGZEOROST')); // 'HATERANGERS'
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ship := Galaxy.Rangers[I];
    (Ship as TRanger).ChangeShipRelations(nil, relation_change_subtract, 80, ShipTypes, Owners);
  end;
end;
{ @end $687524 }

{ @routine $687650 CheatPirates }
procedure CheatPirates;
var
  I, Attempts: Integer;
  Star: TStar;
  Planet: TPlanet;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.IsDockedToShip or (CurrentScreenId = screen_ship) or (GetPlayer.DockedTo.TypeId <> station_pirate_base) then Exit;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if not (Star.ControlFaction in [faction_coalition, faction_pirates]) then Continue;
    if Star.Status.CustomFaction <> '' then Continue;
    for Attempts := 1 to 6 do
    begin
      Planet := Star.Planets[RandomIntRange(0, Star.Planets.Count - 1)];
      if Planet.OwnerId in [owner_maloc..owner_gaal, owner_pirate] then
      begin
        Planet.BuyPirate(100);
        Break;
      end;
    end;
  end;
  ReportCheat(100, DecodeTextW('PRIVRVATTIERS')); // 'PIRATES'
end;
{ @end $687650 }

{ @routine $6877A4 CheatGun }
procedure CheatGun;
var
  Kind: TItemType;
  I: Integer;
  Info: PWeaponInfo;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for I := 1 to CountItemTypesInMask([item_industrial_laser..item_lirecron]) do
  begin
    Kind := GetItemTypeFromMask([item_industrial_laser..item_lirecron], I);
    GetPlayer.Inventory.Add(CreateGeneratedEquipment(Kind,
      Round(WeaponInfos[Kind].AverageSize * EquipmentSizeFactors[5]), Galaxy.TechLevel, GetPlayer.OwnerId));
  end;
  for I := 0 to Galaxy.CustomWeaponTypes.Count - 1 do
  begin
    Info := Galaxy.CustomWeaponTypes[I];
    if Info.Availability = availability_system_only then Continue;
    GetPlayer.Inventory.Add(CreateGeneratedWeapon(Info, Round(Info.AverageSize * EquipmentSizeFactors[5]), Galaxy.TechLevel, GetPlayer.OwnerId));
  end;
  ReportCheat(10, DecodeTextW('GOUMNO')); // 'GUN'
end;
{ @end $6877A4 }

{ @routine $687938 CheatVertix }
procedure CheatVertix;
var
  Owner: TOwnerId;
  Item: TEquipment;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for Owner := owner_maloc to owner_gaal do
  begin
    Item := CreateGeneratedEquipment(item_vertix, 20, Galaxy.TechLevel, Owner);
    GetPlayer.Inventory.Add(Item);
  end;
  ReportCheat(10, DecodeTextW('VREVRETOIYX')); // 'VERTIX'
end;
{ @end $687938 }

{ @routine $6879F0 CheatDevice }
procedure CheatDevice;
var
  Kind: TItemType;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for Kind := item_fuel_tanks to item_defense_generator do
    GetPlayer.Inventory.Add(CreateGeneratedEquipment(Kind,
      Round(GetAverageItemSize(Kind) * EquipmentSizeFactors[5]), 8, GetPlayer.OwnerId));
  ReportCheat(10, DecodeTextW('DREAVNIYCHER')); // 'DEVICE'
end;
{ @end $6879F0 }

{ @routine $687AC8 CheatArts }
procedure CheatArts;
var
  I: Integer;
  Item: TEquipment;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for I := 0 to Length(ArtefactLootPools[loot_any_available]) - 1 do
  begin
    Item := TObject(CreateConfiguredArtefactByItemType(ArtefactLootPools[loot_any_available][I], GetPlayer.OwnerId)) as TEquipmentWithActCode;
    GetPlayer.Artefacts.Add(Item);
  end;
  for I := 0 to Length(CustomArtefactLootPools[loot_any_available]) - 1 do
  begin
    Item := TArtefactCustom.Create;
    with TArtefactCustom(Item) do
    begin
      ConfigBlockName := CustomArtefactLootPools[loot_any_available][I];
      LoadConfig(True);
      Init(GetPlayer.OwnerId, ItemType);
    end;
    GetPlayer.Artefacts.Add(Item);
  end;
  for I := 0 to Length(UselessItemLootPools[loot_any_available]) - 1 do
  begin
    Item := TUselessItem.Create;
    TUselessItem(Item).Init(UselessItemLootPools[loot_any_available][I], series_blazer, 0, False);
    Item.OwnerId := GetPlayer.OwnerId;
    GetPlayer.Inventory.Add(Item);
  end;
  ReportCheat(10, DecodeTextW('ANROTOS')); // 'ARTS'
end;
{ @end $687AC8 }

{ @routine $687C90 CheatModule }
procedure CheatModule;
var
  I: Integer;
  Item: TMicroModule;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    if MicroModuleTemplates[I].SpecialOnly then Continue;
    Item := TMicroModule.Create;
    Item.Init(I);
    GetPlayer.Inventory.Add(Item);
  end;
  ReportCheat(10, DecodeTextW('MAOZDEUNLHE')); // 'MODULE'
end;
{ @end $687C90 }

{ @routine $687D60 CheatSkill }
procedure CheatSkill;
var
  Skill: TPilotSkill;
  Ship: TShip;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  Ship := nil;
  if GetInnermostScreenLoop = HangarScreen then Ship := HangarScreen.SelectedShip
  else if GetInnermostScreenLoop = ScannerScreen then Ship := ScannerScreen.ShipToInspect
  else if GetInnermostScreenLoop = ShipScreen then Ship := PlayerHoldShip;
  if Ship = nil then Ship := GetPlayer;
  ReportCheat(10, DecodeTextW('SXKOINLAL0')); // 'SKILL'
  for Skill := Low(TPilotSkill) to High(TPilotSkill) do Ship.BaseSkills[Skill] := High(TPilotSkillLevel);
  if GetInnermostScreenLoop = ScannerScreen then ScannerScreen.CloseClicked(nil)
  else if GetInnermostScreenLoop = ShipScreen then ShipScreen.CloseClicked(nil);
end;
{ @end $687D60 }

{ @routine $687E94 CheatProgram }
procedure CheatProgram;
var
  I: TProgramIndex;
begin
  if Galaxy = nil then Exit;
  if GetPlayer = nil then Exit;
  for I := Low(ProgramNames) to High(ProgramNames) do GetPlayer.ProgramCounts[I] := 100;
  ReportCheat(10, DecodeTextW('PARZONG3ROALMS')); // 'PROGRAM'
end;
{ @end $687E94 }

{ @routine $687F38 CheatIllness }
procedure CheatIllness;
var
  I: TCaptainHealthEffect;
  Player: TPlayer;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  Player := GetPlayer;
  for I := Low(TCaptainDisease) to High(TCaptainDisease) do
  begin
    Player.CaptainHealth[I].Progress := 100;
    Player.CaptainHealth[I].AppliedTurn := Galaxy.CurrentTurn;
    Player.CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn + TurnsPerYear;
  end;
  ReportCheat(10, DecodeTextW('IALALENOERSASH'));
end;
{ @end $687F38 }

{ @routine $688008 CheatStimulant }
procedure CheatStimulant;
var
  I: TCaptainHealthEffect;
  Player: TPlayer;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  Player := GetPlayer;
  for I := Low(TCaptainStimulant) to High(TCaptainStimulant) do
  begin
    Player.CaptainHealth[I].Progress := 100;
    Player.CaptainHealth[I].AppliedTurn := Galaxy.CurrentTurn;
    Player.CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn + TurnsPerYear;
  end;
  ReportCheat(10, DecodeTextW('SATAISMAUILOAONOTS'));
end;
{ @end $688008 }

{ @routine $6880E0 CheatIdeal }
procedure CheatIdeal;
var
  I: Integer;
begin
  if (Galaxy <> nil) and (GetPlayer <> nil) and (GetPlayer.GetHull <> nil) then
    for I := 0 to HullSeriesCount - 1 do
      if HullSeriesDefinitions[I].SystemName = '99' then
      begin
        GetPlayer.GetHull.HullSeries := I;
        ReportCheat(10, DecodeTextW('INDFENAELE')); // 'IDEAL'
        Break;
      end;
end;
{ @end $6880E0 }

{ @routine $6881BC CheatShowmap }
procedure CheatShowmap;
var
  I: Integer;
  Constellation: TConstellation;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  for I := 0 to Galaxy.Constellations.Count - 1 do
  begin
    Constellation := Galaxy.Constellations[I];
    if (MainPiratePlanet = nil) or (MainPiratePlanet.CurrentStar.Constellation <> Constellation) then
      Constellation.Visible := True;
  end;
  ReportCheat(10, DecodeTextW('SIHSONWEMEANPA'));
end;
{ @end $6881BC }

{ @routine $688294 CheatMedal }
procedure CheatMedal;
var
  I, J, LastAward: Integer;
  Award: Byte;
  Found: Boolean;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  ReportCheat(10, DecodeTextW('MIELDOAELI')); // 'MEDAL'
  LastAward := StrToInt(LookupLocalizedTextByKey('Reward.Count')) - 1;
  if GetPlayer.AwardIds = nil then GetPlayer.AwardIds := TList.Create;
  for I := 0 to LastAward do
  begin
    Found := False;
    for J := 0 to GetPlayer.AwardIds.Count - 1 do
    begin
      Award := Byte(GetPlayer.AwardIds[J]);
      if Award = I then
      begin
        Found := True;
        Break;
      end;
    end;
    if not Found then GetPlayer.AddAward(I);
  end;
end;
{ @end $688294 }

{ @routine $688400 SetCheatDominatorLevel }
procedure SetCheatDominatorLevel(Level: Integer);
var
  Name: WideString;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  case Level of
    1: Name := DecodeTextW('HRONRERGOLR'); // 'HORROR'
    2: Name := DecodeTextW('NGISGIHATRMOAERE'); // 'NIGHTMAR'
    3: Name := DecodeTextW('HAESLOL'); // 'HELL'
  end;
  if Galaxy.DominatorModLevel <> Level then Galaxy.DominatorModLevel := Level
  else Galaxy.DominatorModLevel := 0;
  ReportCheat(10, Name);
  StarMapScreen.RefreshScoreModsLabel;
end;
{ @end $688400 }

{ @routine $68852C CheatHorror }
procedure CheatHorror;
begin
  SetCheatDominatorLevel(1);
end;
{ @end $68852C }

{ @routine $688538 CheatNightmare }
procedure CheatNightmare;
begin
  SetCheatDominatorLevel(2);
end;
{ @end $688538 }

{ @routine $688544 CheatHell }
procedure CheatHell;
begin
  SetCheatDominatorLevel(3);
end;
{ @end $688544 }

{ @routine $688550 CheatTechnic }
procedure CheatTechnic;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  if Galaxy.TechnicModEnabled <> 1 then Galaxy.TechnicModEnabled := 1
  else Galaxy.TechnicModEnabled := 0;
  ReportCheat(10, DecodeTextW('TOESCAHENOINC')); // 'TECHNIC'
  StarMapScreen.RefreshScoreModsLabel;
end;
{ @end $688550 }

{ @routine $68860C CheatAmmo }
procedure CheatAmmo;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  if Galaxy.AmmoModEnabled <> 1 then Galaxy.AmmoModEnabled := 1
  else Galaxy.AmmoModEnabled := 0;
  ReportCheat(10, DecodeTextW('ACMEMEO')); // 'AMMO'
  StarMapScreen.RefreshScoreModsLabel;
end;
{ @end $68860C }

{ @routine $6886BC CheatGod }
procedure CheatGod;
begin
  if (Galaxy <> nil) then
    if (GetPlayer <> nil) then
    if (Galaxy.GodModEnabled in [0, 1]) then
  begin
    Galaxy.GodModEnabled := 1 - Galaxy.GodModEnabled;
    ReportCheat(10, DecodeTextW('GHOID')); // 'GOD'
    StarMapScreen.RefreshScoreModsLabel;
  end;
end;
{ @end $6886BC }

{ @routine $6887CC CheatHole }
procedure CheatHole;
var
  Items: TList;
  Index, Count: Integer;
  Hole: THole;
  Angle, Radius: Single;
  MapName: WideString;
  Parent: TMessageLoopGI;
  Block: TBlockParEC;
  Event: TGalaxyEvent;
  // @nested $688764 CheatHoleAddName
  procedure CheatHoleAddName(Text: WideString); // @addr $688764 @calls "0x006888B5,0x006888C3" @note "Nested in CheatHole; appends an owned PWideString to the list at ParentFrame-4. Caller removes the static link."
  var Cell: PWideString;
  begin
    New(Cell);
    Cell^ := Text;
    Items.Add(Cell);
  end;
begin
  if (Galaxy = nil) or
    (GetPlayer = nil) or not GetPlayer.InNormalSpace or (CurrentScreenId <> screen_star_map) or (StarMapScreen.Mode <> map_mode_orders) then Exit;
  Parent := RegisteredScreens[CurrentScreenId] as TMessageLoopGI;
  Items := TList.Create;
  Block := GameDataConfig.GetBlock('ABMap');
  Count := Block.BlockCount;
  for Index := 0 to Count do
    if Index < Count then CheatHoleAddName(Block.Blocks[Index].Params['Path'])
    else CheatHoleAddName('ABMap.map_boss');
  if ShowListDialog(Parent, Index, LocalizedColorText('Cheat.SelectABMap'), Items, 0, 0) = 1 then
  begin
    MapName := PWideString(Items[Index])^;
    AddCheatPoints(10);
    if Galaxy <> nil then
    begin
      Event := AddGalaxyEvent('PlayerEntersCheatCode');
      Event.AddTextData('Hole');
      Event.AddData(10);
    end;
    Hole := THole.Create;
    Hole.InitializeGraphic('');
    THoleSE(Hole.Graphic).SetState(1);
    Hole.Star1 := GetPlayer.CurrentStar;
    Hole.Star2 := GetPlayer.CurrentStar;
    Hole.ArcadeMapName := MapName;
    Angle := ArcTan2(GetPlayer.Position.X, -GetPlayer.Position.Y);
    Radius := Max(GetPlayer.CurrentStar.SafeRadius + 100, Sqrt(PointDistanceSquared(GetPlayer.Position, MakePointF(0, 0))) + 200);
    Hole.Position1 := MakePointF(Sin(Angle) * Radius, -Cos(Angle) * Radius);
    Angle := HeadingDegreesToRadians(RandomIntRange(0, 359));
    Radius := RandomIntRange(1000, 2000);
    Hole.Position2 := MakePointF(Sin(Angle) * Radius, -Cos(Angle) * Radius);
    Hole.CreatedTurn := Galaxy.CurrentTurn;
    Hole.HoleType := 1;
    StarMapScreen.PendingHoleRefresh := Hole;
    Galaxy.Holes.Add(Hole);
  end;
  while Items.Count > 0 do
  begin
    // Native cleanup frees only the cell, leaving its string allocation intact.
    Dispose(Items[0]);
    Items.Delete(0);
  end;
  Items.Free;
  RequestedScreenId := CurrentScreenId;
  Parent.RequestClose(1);
end;
{ @end $6887CC }

{ @routine $688C70 CheatWin }
procedure CheatWin;
begin
  if (Galaxy = nil) or (GetPlayer = nil) or (CurrentScreenId = screen_arcade_battle) then Exit;
  AddCheatPoints(10);
  ScoreScreen.RecordPlayerResult(True);
  AboutScreen.ReturnToScores := True;
  RequestedScreenId := screen_about;
  (RegisteredScreens[CurrentScreenId] as TMessageLoopGI).RequestClose(1);
end;
{ @end $688C70 }

{ @routine $688CE4 CheatHweapon }
procedure CheatHweapon;
var
  I: Integer;
  Item: TEquipment;
begin
  if GetPlayer = nil then Exit;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.EquippedFlag <> 0) and (Item is TWeapon) then
    with Item as TWeapon do
    begin
      TechLevel := 8;
      MinDamage := CalculateGeneratedMinDamage;
      MaxDamage := CalculateStandardMaxDamage;
      Range := CalculateStandardRange;
      Cost := CalculateGeneratedWeaponCost(GetWeaponInfo, Weight, TechLevel, OwnerId);
      if GetWeaponInfo.ShotType in [shot_torpedo, shot_missile, shot_rocket] then
      begin
        AmmoCapacity := CalculateGeneratedAmmoCapacity;
        if MicroModuleIndex <> 0 then
          Inc(AmmoCapacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_ammo_capacity]);
        if SpecialModuleIndex <> 0 then
          Inc(AmmoCapacity, MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[bonus_ammo_capacity]);
      end;
    end;
  end;
  ReportCheat(10, DecodeTextW('HOWIETANPEOLN')); // 'HWEAPON'
end;
{ @end $688CE4 }

{ @routine $688E68 CheatUltrascan }
procedure CheatUltrascan;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  if Galaxy.UltraScanModEnabled <> 1 then Galaxy.UltraScanModEnabled := 1
  else Galaxy.UltraScanModEnabled := 0;
  ReportCheat(10, DecodeTextW('USLATOREAMSACRAWN')); // 'ULTRASCAN'
  StarMapScreen.RefreshScoreModsLabel;
end;
{ @end $688E68 }

{ @routine $688F2C CheatTentm }
procedure CheatTentm;
var
  I: Integer;
  Item: TArtefactTransmitter;
begin
  if GetPlayer = nil then Exit;
  for I := 1 to 10 do
  begin
    Item := TArtefactTransmitter(CreateConfiguredArtefactByItemType(artefact_transmitter, GetPlayer.OwnerId));
    Item.Power := 100;
    GetPlayer.Artefacts.Add(Item);
  end;
  ReportCheat(10, DecodeTextW('TREANTTIME')); // 'TENTM'
end;
{ @end $688F2C }

{ @routine $688FD8 CheatEncharge }
procedure CheatEncharge;
var
  I: Integer;
  Item: TArtefact;
begin
  if GetPlayer = nil then Exit;
  for I := 0 to GetPlayer.Artefacts.Count - 1 do
  begin
    Item := GetPlayer.Artefacts[I];
    if (Item is TArtefactTransmitter) then
      if (TArtefactTransmitter(Item).Power <= 1000) then
        Inc(TArtefactTransmitter(Item).Power, 100);
  end;
  ReportCheat(10, DecodeTextW('ECNDCAHAALRIGEE')); // 'ENCHARGE'
end;
{ @end $688FD8 }

{ @routine $6890A8 CheatExpa }
procedure CheatExpa;
begin
  if GetPlayer <> nil then
  begin
    Inc(GetPlayer.FreeExperience, 1000000);
    ReportCheat(10, DecodeTextW('ELXIPOAN')); // 'EXPA'
  end;
end;
{ @end $6890A8 }

{ @routine $689128 CheatMadeinchina }
procedure CheatMadeinchina;
var
  I: Integer;
  Item: TEquipment;
begin
  if GetPlayer = nil then Exit;
  // The native loop deliberately starts at one.
  for I := 1 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.EquippedFlag <> 0 then Item.OwnerId := owner_uninhabited;
  end;
  ReportCheat(10, DecodeTextW('MRALDIETISNOCIHSIMNIA')); // 'MADEINCHINA'
end;
{ @end $689128 }

{ @routine $6891EC CheatZawarudo }
procedure CheatZawarudo;
begin
  if GetPlayer = nil then Exit;
  if Galaxy.StasisModEnabled <> 1 then Galaxy.StasisModEnabled := 1
  else Galaxy.StasisModEnabled := 0;
  ReportCheat(10, DecodeTextW('ZIANWRASRIUNDAOL')); // 'ZAWARUDO'
  StarMapScreen.RefreshScoreModsLabel;
end;
{ @end $6891EC }

{ @routine $6892A4 ShowCheatFeedback }
procedure ShowCheatFeedback(Text: WideString);
begin
  if Galaxy = nil then ShowMessageBoxGI(nil, Text, mbgOK)
  else AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, Text, '');
end;
{ @end $6892A4 }

{ @routine $689318 IsCheatMessageBoxOpen }
function IsCheatMessageBoxOpen: Boolean;
var
  Instance: TObject;
  Index: Integer;
begin
  Result := False;
  for Index := MessageLoopStack.Count - 1 downto 0 do
  begin
    Instance := MessageLoopStack[Index];
    if Instance is TMessageBoxGI then
    begin
      Result := True;
      Exit;
    end;
  end;
end;
{ @end $689318 }

{ @routine $68939C HandleDebugKey }
procedure HandleDebugKey(Key: Word);

  // @nested $689360 SumCheatPrefix
  function SumCheatPrefix(Index, Count: Integer): Integer; // @addr $689360 @calls "0x00689446"
  var Position: Integer;
  begin
    Result := 0;
    for Position := 1 to Count do
      Inc(Result, Ord(CheatEntries.GetEntry(Index).Text[Position]));
  end;

begin
  if IsCheatMessageBoxOpen then Exit;
  if (Galaxy <> nil) and Galaxy.CheatsDisabled then Exit;
  if not (TurnCalculationPhase in [turn_idle, turn_galaxy_finished, turn_player_star_finished, turn_player_star_prepared])
    then Exit;
  while True do
  begin
    if CheatEntries.Count - 1 < CheatCandidateIndex then
    begin
      CheatCandidateIndex := 0;
      CheatPrefixLength := 0;
      CheatPrefixSum := 0;
      Exit;
    end;
    if Length(CheatEntries.GetEntry(CheatCandidateIndex).Text) >= CheatPrefixLength + 1 then
      if (Key = Word(CheatEntries.GetEntry(CheatCandidateIndex).Text[CheatPrefixLength + 1])) and
        (SumCheatPrefix(CheatCandidateIndex, CheatPrefixLength) = CheatPrefixSum) then Break;
    Inc(CheatCandidateIndex);
  end;
  Inc(CheatPrefixLength);
  Inc(CheatPrefixSum, Key);
  if Length(CheatEntries.GetEntry(CheatCandidateIndex).Text) <> CheatPrefixLength then Exit;
  if CheatEntries.Count > CheatCandidateIndex then
    CheatEntries.GetEntry(CheatCandidateIndex).Callback;
  CheatCandidateIndex := 0;
  CheatPrefixLength := 0;
  CheatPrefixSum := 0;
end;
{ @end $68939C }

{ @routine $6894A4 CheatMakedump }
procedure CheatMakedump;
begin
  if (GetPlayer = nil) or Galaxy.IronWill or GetPlayer.InHyperspace or (Galaxy.FinalizationNameEncoded <> '')
    or not (CurrentScreenId in [screen_hangar, screen_planet, screen_uninhabited_planet, screen_equipment_shop,
      screen_government, screen_star_map, screen_ruins_talk, screen_info, screen_goods_shop]) or
    (TMessageLoopGI(RegisteredScreens[CurrentScreenId]).ChildLoop <> nil) then Exit;
  Galaxy.CheckIntegrityChecksum(888);
  Galaxy.CampaignFlag183 := 1;
  CaptureSavePreview;
  CaptureGalaxyPreview(TMessageLoopGI(RegisteredScreens[CurrentScreenId]));
  Galaxy.PrimeIntegrityChecksum(889);
  SaveManagerReturnScreenId := CurrentScreenId;
  SaveManagerMode := save_dialog_save;
  RequestedScreenId := screen_save_manager;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $6894A4 }

{ @routine $6895B8 CheatFitness }
procedure CheatFitness;
var
  Block: TBlockParEC;
  FileName: WideString;
  Index, Number: Integer;
  Path: WideString;
  Item: TEquipment;
begin
  if (Galaxy = nil) or (GetPlayer = nil) then Exit;
  FileName := GetGameUserDirectory + DecodeTextW('PaliatyseoraFainta.Atoxita'); // 'PlayerFit.txt'
  Block := TBlockParEC.Create;
  Number := 1;
  Block.AddParam(DecodeTextW('GraemlenVoenrusSimoun'), GameVersionText); // 'GameVersion'
  Block.AddParam(GetPlayer.GetLocalizedTypeName, GetPlayer.GetName);
  for Index := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[Index];
    if (Item is THull) or (Item.EquippedFlag <> 0) then
    begin
      if Item is TWeapon then
      begin
        Path := 'Weapon' + IntToStr(Number);
        Inc(Number);
      end
      else Path := ItemTypeNames[Item.ItemType];
      Item.SaveToBlock(Block.AddBlockByPath(Path));
    end;
  end;
  Number := 1;
  for Index := 0 to GetPlayer.Artefacts.Count - 1 do
  begin
    Item := GetPlayer.Artefacts[Index];
    if Item.EquippedFlag <> 0 then
    begin
      Path := 'Artefact' + IntToStr(Number);
      Inc(Number);
      Item.SaveToBlock(Block.AddBlockByPath(Path));
    end;
  end;
  Block.SaveTextFile(PWideChar(FileName), True, False);
  Block.Free;
  ReportCheat(0, DecodeTextW('FLITTONLEISES')); // 'FITNESS'
end;
{ @end $6895B8 }

{ @routine $6898E8 CheatExtraone }
procedure CheatExtraone;
var
  I, Count: Integer;
  Good: Byte;
  Item: TEquipment;
begin
  if GetPlayer = nil then Exit;
  Count := GetPlayer.Inventory.Count;
  for I := 1 to Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.EquippedFlag = 0) and (Item.ScriptItem = nil) and not (Item is TTreasureMap) then
    begin
      if Item is TCountableItem then
      begin
        (Item as TCountableItem).StackCount := (Item as TCountableItem).StackCount * 2;
        Item.Weight := Item.Weight * 2;
      end
      else
      begin
        Item := TEquipment(Item.Clone);
        if Item <> nil then GetPlayer.Inventory.Add(Item);
      end;
    end;
  end;
  Count := GetPlayer.Artefacts.Count;
  for I := 0 to Count - 1 do
  begin
    Item := GetPlayer.Artefacts[I];
    if (Item.EquippedFlag = 0) and (Item.ScriptItem = nil) then
    begin
      Item := TEquipment(Item.Clone);
      if Item <> nil then GetPlayer.Artefacts.Add(Item);
    end;
  end;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do GetPlayer.CargoGoods[Good].Count := GetPlayer.CargoGoods[Good].Count * 2;
  GetPlayer.RefreshDerivedStats(True);
  ReportCheat(10, DecodeTextW('EIXATIRIANORNAEL')); // 'EXTRAONE'
end;
{ @end $6898E8 }

{ @routine $689A9C CheatSudo }
procedure CheatSudo;
var
  Value, ScriptName: WideString;
  Quote: WideChar;
  Index, Count: Integer;
  Script: TScript;
  Found: Boolean;
begin
  if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(888);
  Value := '';
  if ShowTextInputDialog(RegisteredScreens[CurrentScreenId] as TMessageLoopGI, 'Enter script command', Value, 255, 0, 0) = 1 then
  try
    Count := Length(Value);
    if Count > 0 then
    begin
      Quote := Value[1];
      // The native double-quote test compares against two characters.
      if (Quote = #39) or (WideString(Quote) = '""') then
      begin
        for Index := 2 to Count do if Value[Index] = Quote then Break;
        if Index < Count then
        begin
          ScriptName := CopyWideStringUnchecked(Value, 2, Index - 2);
          Value := CopyWideStringUnchecked(Value, Index + 1, Count - Index);
          Found := False;
          if Galaxy <> nil then
            for Index := 0 to Galaxy.Scripts.Count - 1 do
            begin
              Script := Galaxy.Scripts[Index];
              if Script.ScriptFileName = ScriptName then
              begin
                Found := True;
                ExecuteScriptText(Value, Script.InitCode.LocalVar);
                Break;
              end;
            end;
          if not Found then raise Exception.Create('Error, script with name ' + ScriptName + 'is not found');
        end;
      end
      else ExecuteScriptText(Value, nil);
    end;
  except
    on E: Exception do ShowMessageBoxGI(RegisteredScreens[CurrentScreenId] as TMessageLoopGI, E.Message, mbgCancel);
  end;
  if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum(889);
end;
{ @end $689A9C }

{ @routine $689DC8 CheatEvents }
procedure CheatEvents;
var
  Event: TGalaxyEvent;
  Index, I: Integer;
begin
  if Galaxy = nil then Exit;
  Index := Galaxy.GalaxyEvents.Count - 1;
  AppendLogLineThreadSafe('----------------------------------------');
  AppendLogLineThreadSafe('Events:');
  AppendLogLineThreadSafe('----------------------------------------');
  while Index >= 0 do
  begin
    Event := Galaxy.GalaxyEvents[Index];
    AppendLogLineThreadSafe(Event.EventType);
    AppendLogLineThreadSafe(FormatGameTurnDate(Event.Turn) + ' (' + IntToStr(Event.Turn) + ')');
    if Event.TextData <> nil then
    begin
      AppendLogLineThreadSafe('  Text data:');
      for I := 0 to Event.TextData.Count - 1 do AppendLogLineThreadSafe('  ' + PWideString(Event.TextData[I])^);
    end;
    if Event.Data <> nil then
    begin
      AppendLogLineThreadSafe('  Data:');
      for I := 0 to Event.Data.Count - 1 do AppendLogLineThreadSafe('  ' + IntToStr(Integer(Event.Data[I])));
      AppendLogLineThreadSafe('');
    end;
    Dec(Index);
  end;
  AppendLogLineThreadSafe('----------------------------------------');
end;
{ @end $689DC8 }

{ @routine $68A058 CheatSeed }
procedure CheatSeed;
var
  Value: WideString;
begin
  if TMessageLoopGI(RegisteredScreens[CurrentScreenId]) = NewGameScreen then
    if (NewGameScreen.GetByName('ButExtended') as TGraphButtonGI).Down then
    begin
      if NewGameSeedText = '' then
      begin
        Randomize;
        NewGameSeedText := IntToWideString(RandomIntRange(100000, MaxInt));
      end;
      Value := NewGameSeedText;
      if ShowTextInputDialog(NewGameScreen, 'SEED', Value, 30, 0, 0) = 1 then NewGameSeedText := Value;
    end;
end;
{ @end $68A058 }

{ @routine $68A178 CheatInfos }
procedure CheatInfos;
var
  Star: TStar;
  Ship: TShip;
  Info: PCustomShipInfo;
  I, J, K: Integer;
  PrintedHeader: Boolean;
begin
  if Galaxy = nil then Exit;
  AppendLogLineThreadSafe('----------------------------------------');
  AppendLogLineThreadSafe('ShipInfos:');
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      PrintedHeader := False;
      for K := 0 to Ship.CustomShipInfos.Count - 1 do
      begin
        Info := Ship.CustomShipInfos[K];
        if not Info.DeleteQueued then
        begin
          if not PrintedHeader then
          begin
            AppendLogLineThreadSafe('----------------------------------------');
            AppendLogLineThreadSafe(Ship.GetFullName(' '));
          end;
          PrintedHeader := True;
          AppendLogLineThreadSafe(Info.TypeName + ' ' + IntToStr(Info.Data[1]) + ',' +
            IntToStr(Info.Data[2]) + ',' + IntToStr(Info.Data[3]) + ',"' + Info.TextData1 + '","' +
            Info.TextData2 + '","' + Info.TextData3 + '"');
        end;
      end;
    end;
  end;
  AppendLogLineThreadSafe('----------------------------------------');
end;
{ @end $68A178 }

initialization
  CheatEntries := TCheatList.Create;
  CheatEntries.AddCheat(DecodeTextW('ROEMPOAYIURU'), CheatRepair); // 'REPAIR'
  CheatEntries.AddCheat(DecodeTextW('KULTIZSOSOASNOMEANXI'), CheatKlissanmax); // 'KLISSANMAX'
  CheatEntries.AddCheat(DecodeTextW('PVISREAXTMETMOARX9'), CheatPiratemax); // 'PIRATEMAX'
  CheatEntries.AddCheat(DecodeTextW('WIAGRARUILOIRAMOARX9'), CheatWarriormax); // 'WARRIORMAX'
  CheatEntries.AddCheat(DecodeTextW('KOLEINSOSUAINOCRABLELS'), CheatKlissancall); // 'KLISSANCALL'
  CheatEntries.AddCheat(DecodeTextW('PAIORNAMTZEXCOASLOL'), CheatPiratecall); // 'PIRATECALL'
  CheatEntries.AddCheat(DecodeTextW('RIALNOGDEPROPRONIHNITIS'), CheatRangerpoints); // 'RANGERPOINTS'
  CheatEntries.AddCheat(DecodeTextW('NIETXATARNARNAK'), CheatNextrank); // 'NEXTRANK'
  CheatEntries.AddCheat(DecodeTextW('CRONOBLAWSENAIPROSN'), CheatCoolweapon); // 'COOLWEAPON'
  CheatEntries.AddCheat(DecodeTextW('LLOYWACSONSETIWIEFAIPROLNO'), CheatLowcostweapon); // 'LOWCOSTWEAPON'
  CheatEntries.AddCheat(DecodeTextW('BRODMEB'), CheatBomb); // 'BOMB'
  CheatEntries.AddCheat(DecodeTextW('ASRATIENFOARCAT'), CheatArtefact); // 'ARTEFACT'
  CheatEntries.AddCheat(DecodeTextW('MEOLNIERYE'), CheatMoney); // 'MONEY'
  CheatEntries.AddCheat(DecodeTextW('DIRIOSPA'), CheatDrop); // 'DROP'
  CheatEntries.AddCheat(DecodeTextW('PRANCIKCIINEG'), CheatPacking); // 'PACKING'
  CheatEntries.AddCheat(DecodeTextW('KALKINSOSUANNIINTHEMM'), CheatKlissanitem); // 'KLISSANITEM'
  CheatEntries.AddCheat(DecodeTextW('WRENARPBOSNASOTERLEINAGATOHE'), CheatWeaponstrength); // 'WEAPONSTRENGTH'
  CheatEntries.AddCheat(DecodeTextW('TIECN0BEOAMOB'), CheatTenbomb); // 'TENBOMB'
  CheatEntries.AddCheat(DecodeTextW('RONNDOBNASSAEY'), CheatRndbase); // 'RNDBASE'
  CheatEntries.AddCheat(DecodeTextW('MOARPESHESCOTROLR2'), CheatMapsector); // 'MAPSECTOR'
  CheatEntries.AddCheat(DecodeTextW('HAUNGLESMIOMNEELYS'), CheatHugemoney); // 'HUGEMONEY'
  CheatEntries.AddCheat(DecodeTextW('PLEVLIESNOGASRUEROPTROINSAEN'), CheatPelengsurprise); // 'PELENGSURPRISE'
  CheatEntries.AddCheat(DecodeTextW('SRUNPRESROHLUALELS'), CheatSuperhull); // 'SUPERHULL'
  CheatEntries.AddCheat(DecodeTextW('BLOSOMM'), CheatBoom); // 'BOOM'
  CheatEntries.AddCheat(DecodeTextW('HEAVTIERROASNAGZEOROST'), CheatHaterangers); // 'HATERANGERS'
  CheatEntries.AddCheat(DecodeTextW('PRIVRVATTIERS'), CheatPirates); // 'PIRATES'
  CheatEntries.AddCheat(DecodeTextW('GOUMNO'), CheatGun); // 'GUN'
  CheatEntries.AddCheat(DecodeTextW('VREVRETOIYX'), CheatVertix); // 'VERTIX'
  CheatEntries.AddCheat(DecodeTextW('DREAVNIYCHER'), CheatDevice); // 'DEVICE'
  CheatEntries.AddCheat(DecodeTextW('ANROTOS'), CheatArts); // 'ARTS'
  CheatEntries.AddCheat(DecodeTextW('MAOZDEUNLHE'), CheatModule); // 'MODULE'
  CheatEntries.AddCheat(DecodeTextW('SXKOINLAL0'), CheatSkill); // 'SKILL'
  CheatEntries.AddCheat(DecodeTextW('PARZONG3ROALMS'), CheatProgram); // 'PROGRAM'
  CheatEntries.AddCheat(DecodeTextW('IALALENOERSASH'), CheatIllness); // 'ILLNESS'
  CheatEntries.AddCheat(DecodeTextW('SATAISMAUILOAONOTS'), CheatStimulant); // 'STIMULANT'
  CheatEntries.AddCheat(DecodeTextW('INDFENAELE'), CheatIdeal); // 'IDEAL'
  CheatEntries.AddCheat(DecodeTextW('SIHSONWEMEANPA'), CheatShowmap); // 'SHOWMAP'
  CheatEntries.AddCheat(DecodeTextW('MIELDOAELI'), CheatMedal); // 'MEDAL'
  CheatEntries.AddCheat(DecodeTextW('HRONRERGOLR'), CheatHorror); // 'HORROR'
  CheatEntries.AddCheat(DecodeTextW('NGISGIHATRMOAEREE'), CheatNightmare); // 'NIGHTMARE'
  CheatEntries.AddCheat(DecodeTextW('HAESLOL'), CheatHell); // 'HELL'
  CheatEntries.AddCheat(DecodeTextW('TOESCAHENOINC'), CheatTechnic); // 'TECHNIC'
  CheatEntries.AddCheat(DecodeTextW('ACMEMEO'), CheatAmmo); // 'AMMO'
  CheatEntries.AddCheat(DecodeTextW('GHOID'), CheatGod); // 'GOD'
  CheatEntries.AddCheat(DecodeTextW('HLOILAEN'), CheatHole); // 'HOLE'
  CheatEntries.AddCheat(DecodeTextW('WHINNE'), CheatWin); // 'WIN'
  CheatEntries.AddCheat(DecodeTextW('HOWIETANPEOLN'), CheatHweapon); // 'HWEAPON'
  CheatEntries.AddCheat(DecodeTextW('USLATOREAMSACRAWN'), CheatUltrascan); // 'ULTRASCAN'
  CheatEntries.AddCheat(DecodeTextW('TREANTTIME'), CheatTentm); // 'TENTM'
  CheatEntries.AddCheat(DecodeTextW('ECNDCAHAALRIGEE'), CheatEncharge); // 'ENCHARGE'
  CheatEntries.AddCheat(DecodeTextW('ELXIPOAN'), CheatExpa); // 'EXPA'
  CheatEntries.AddCheat(DecodeTextW('MRALDIETISNOCIHSIMNIA'), CheatMadeinchina); // 'MADEINCHINA'
  CheatEntries.AddCheat(DecodeTextW('ZIANWRASRIUNDAOL'), CheatZawarudo); // 'ZAWARUDO'
  CheatEntries.AddCheat(DecodeTextW('FLITTONLEISES'), CheatFitness); // 'FITNESS'
  CheatEntries.AddCheat(DecodeTextW('EIXATIRIANORNAEL'), CheatExtraone); // 'EXTRAONE'
  CheatEntries.AddCheat(DecodeTextW('RFOCBIOLTQFNOCROCRE'), CheatRobotforce); // 'ROBOTFORCE'
  CheatEntries.AddCheat(DecodeTextW('RIALNEGREFRESIDUREEKALMA'), CheatRangersdream); // 'RANGERSDREAM'
  CheatEntries.AddCheat(DecodeTextW('MOABKREIDLUCMEPT'), CheatMakedump); // 'MAKEDUMP'
  CheatEntries.AddCheat(DecodeTextW('SAENEEDO'), CheatSeed); // 'SEED'
  CheatEntries.AddCheat('SUDO', CheatSudo);
  CheatEntries.AddCheat('EVENTS', CheatEvents);
  CheatEntries.AddCheat(DecodeTextW('IONOFROSS'), CheatInfos); // 'INFOS'
finalization
  CheatEntries.Destroy;
end.
