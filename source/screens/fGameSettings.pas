unit fGameSettings;
// The native thread contribution ends before TfGameSettings2 metadata at $56CEA0.
// Ownership by the linked fGameSettings unit is inferred from that boundary and
// PACKAGEINFO's adjacent fGameSettings2/fGameSettings dependency entries.

interface

uses EC_Thread, aGalaxyStruct;

type
  TThreadCreateNewGame = class(TThreadEC) // @size 0x4C
  public
    PlayerRace: TOwnerId; // @offset 0x2C
    DifficultyLevels: TGalaxyDifficultyLevels; // @offset 0x2D
    CaptainPortraitIndex: Integer; // @offset 0x38
    PlayerName: WideString; // @offset 0x3C
    CharacterPreset: Integer; // @offset 0x40
    StartingItemTypes: array[0..1] of Byte; // @offset 0x44
    StartingSkills: array[0..1] of TPilotSkill; // @offset 0x46
    IronWill: Boolean; // @offset 0x48

    procedure Execute; override; // @addr 0x8183AC
  end;

implementation

uses Classes, Windows, SysUtils, Math, EC_Str, EC_Struct, GI_GraphButton,
  GI_Edit, GI_PanelScrollBar, GI_Main, GR_Main, Globals, GlobalsV, aConst,
  aMyFunction, fFilmFile, GI_gai, GR_DX, aGalaxy, aPlayer, aPlanet, aRanger,
  aShip, aItem, aKling, aRuins, fIntroduction, ThreadCalc, aCalc, aScript;

{ @routine $8183AC TThreadCreateNewGame_Execute }
procedure TThreadCreateNewGame.Execute;
const
  InitialDominatorShipMask = [0];
var
  ControlWord: Word;
  I, J, K, N: Integer;
  Star, OtherStar: TStar;
  Planet: TPlanet;
  Constellation: TConstellation;
  Ship: TShip;
  Ranger: TRanger;
  SpecialStar: TStar;
  HomePlanet: TPlanet;
  Distance, MaximumDistance: Integer;
  EdgeDistance, OtherEdgeDistance: Single;
  Skill: Byte;
  Entry: PStorageEntry;
  Item: TEquipment;
  Player: TPlayer;
  Stage, Value: Integer;
  Center: TPointF;
  Score: Single;
  StartStar: TStar;
  OwnerId: TOwnerId;
  NameLists: array[TOwnerId] of TList;
begin
  Stage := 0;
  try
    // Each generation thread establishes the native x87 precision and exception mask.
    asm
      mov ControlWord, $133F
      fclex
      and ControlWord, $FCFF
      fldcw ControlWord
    end;
    NewGameGenerationStage := 0;
    PlayerStarDayPrepared := True;
    Galaxy := TGalaxy.Create;
    for Skill := 0 to 7 do Galaxy.DifficultyLevels[Skill] := DifficultyLevels[Skill];
    Galaxy.CustomRules.Enabled := (NewGameSettingsConfig.CountParamsByPath('UseCustomRules') > 0) and
      ParseEnabledNameGI(NewGameSettingsConfig.GetParamByPathOrMarker('UseCustomRules'));
    if Galaxy.CustomRules.Enabled and (NewGameSeedText <> '') then
    begin
      Galaxy.GenerationSeed := ExtractDigitsToIntW(NewGameSeedText);
      Galaxy.RandomState := Galaxy.GenerationSeed;
    end;
    NewGameSeedText := '';
    Galaxy.SetCheatPoints(0);
    if not Galaxy.CustomRules.Enabled then
    begin
      Galaxy.CustomRules.DominatorStrength := 0;
      Galaxy.CustomRules.DominatorAggression := 0;
      Galaxy.CustomRules.DominatorSpawn := 0;
      Galaxy.CustomRules.PirateAggression := 0;
      Galaxy.CustomRules.CoalitionAggression := 0;
      Galaxy.CustomRules.AsteroidModifier := 8;
      Galaxy.CustomRules.SunDamageModifier := 8;
      Galaxy.CustomRules.ExtraInventions := 0;
      Galaxy.CustomRules.AcrynModifier := 16;
      Galaxy.CustomRules.NodeDropModifier := 8;
      Galaxy.CustomRules.ArcadeDropValueModifier := 8;
      Galaxy.CustomRules.DropValueModifier := 8;
      Galaxy.CustomRules.AgriculturalPlanetWeight := 1;
      Galaxy.CustomRules.MixedPlanetWeight := 1;
      Galaxy.CustomRules.IndustrialPlanetWeight := 1;
      Galaxy.CustomRules.ExtraRangers := 0;
      Galaxy.CustomRules.ArcadeHitpointsModifier := 8;
      Galaxy.CustomRules.ArcadeDamageModifier := 8;
      Galaxy.CustomRules.AIJunkTolerance := 7;
      Galaxy.CustomRules.ChaoticRandom := False;
      Galaxy.CustomRules.UnrestrictedEquipmentKnowledge := False;
      Galaxy.CustomRules.StationsNearStars := False;
      Galaxy.CustomRules.FullStationTargeting := False;
      Galaxy.CustomRules.SpecialShips := False;
      Galaxy.CustomRules.ZeroStartingExperience := False;
      Galaxy.CustomRules.ArcadeBattleRoyale := False;
      Galaxy.CustomRules.DominatorRacialWeapons := False;
      Galaxy.CustomRules.MaxRangeMissiles := False;
      Galaxy.CustomRules.OldHyperspace := False;
      Galaxy.CustomRules.PirateNodes := False;
      Galaxy.CustomRules.AIUseShops := False;
      Galaxy.CustomRules.StationsUseShop := False;
      Galaxy.CustomRules.DuplicateArtefacts := False;
      Galaxy.CustomRules.HullGrowth := 0;
      Galaxy.CustomRules.ArcadeEquipmentChange := False;
      Galaxy.CustomRules.OldSpeedCalculation := False;
      Galaxy.CustomRules.OldMissileBonuses := False;
    end
    else
    begin
      with NewGameSettingsConfig.GetBlockByPath('CustomRules') do
      begin
        Value := StrToInt(GetParamByPath('KlingStrength'));
        if Value < 0 then
        begin
          Value := 0;
          for Skill := 0 to 7 do Value := Value + Galaxy.DifficultyLevels[Skill];
        end;
        Galaxy.CustomRules.DominatorStrength := Value;
        Value := StrToInt(GetParamByPath('KlingAggro'));
        if Value < 0 then
        begin
          Value := 0;
          for Skill := 0 to 7 do Value := Value + Galaxy.DifficultyLevels[Skill];
        end;
        Galaxy.CustomRules.DominatorAggression := Value;
        Value := StrToInt(GetParamByPath('KlingSpawn'));
        if Value < 0 then
        begin
          Value := 0;
          for Skill := 0 to 7 do Value := Value + Galaxy.DifficultyLevels[Skill];
        end;
        Galaxy.CustomRules.DominatorSpawn := Value;
        Value := StrToInt(GetParamByPath('PirateAggro'));
        if Value < 0 then Galaxy.CustomRules.PirateAggression := Galaxy.DifficultyLevels[0] * 8
        else Galaxy.CustomRules.PirateAggression := Value;
        Galaxy.CustomRules.CoalitionAggression := StrToInt(GetParamByPath('CoalAggro'));
        Galaxy.CustomRules.AsteroidModifier := StrToInt(GetParamByPath('AsteroidMod'));
        Galaxy.CustomRules.SunDamageModifier := StrToInt(GetParamByPath('SunDamageMod'));
        Galaxy.CustomRules.ExtraInventions := StrToInt(GetParamByPath('ExtraInventions'));
        Galaxy.CustomRules.AcrynModifier := StrToInt(GetParamByPath('AkrinMod'));
        Galaxy.CustomRules.NodeDropModifier := StrToInt(GetParamByPath('NodeDropMod'));
        Galaxy.CustomRules.ArcadeDropValueModifier := StrToInt(GetParamByPath('ABDropValueMod'));
        Galaxy.CustomRules.DropValueModifier := StrToInt(GetParamByPath('DropValueMod'));
        Galaxy.CustomRules.AgriculturalPlanetWeight := StrToInt(GetParamByPath('AgPlanets'));
        Galaxy.CustomRules.MixedPlanetWeight := StrToInt(GetParamByPath('MiPlanets'));
        Galaxy.CustomRules.IndustrialPlanetWeight := StrToInt(GetParamByPath('InPlanets'));
        Galaxy.CustomRules.ExtraRangers := StrToInt(GetParamByPath('ExtraRangers'));
        Galaxy.CustomRules.ArcadeHitpointsModifier := StrToInt(GetParamByPath('ABHitpointsMod'));
        Galaxy.CustomRules.ArcadeDamageModifier := StrToInt(GetParamByPath('ABDamageMod'));
        Galaxy.CustomRules.AIJunkTolerance := StrToInt(GetParamByPath('AITolerateJunk'));
        Galaxy.CustomRules.ChaoticRandom := ParseEnabledNameGI(GetParamByPathOrMarker('RndChaotic'));
        Galaxy.CustomRules.UnrestrictedEquipmentKnowledge := ParseEnabledNameGI(GetParamByPathOrMarker('EqKnowledgeUnRestricted'));
        Galaxy.CustomRules.StationsNearStars := ParseEnabledNameGI(GetParamByPathOrMarker('RuinsNearStars'));
        Galaxy.CustomRules.FullStationTargeting := ParseEnabledNameGI(GetParamByPathOrMarker('RuinsTargettingFull'));
        Galaxy.CustomRules.SpecialShips := ParseEnabledNameGI(GetParamByPathOrMarker('SpecialShipsInGame'));
        Galaxy.CustomRules.ZeroStartingExperience := ParseEnabledNameGI(GetParamByPathOrMarker('ZeroStartExp'));
        Galaxy.CustomRules.ArcadeBattleRoyale := ParseEnabledNameGI(GetParamByPathOrMarker('ABattleRoyale'));
        Galaxy.CustomRules.DominatorRacialWeapons := ParseEnabledNameGI(GetParamByPathOrMarker('KlingRacialWeapons'));
        Galaxy.CustomRules.StartInCenter := ParseEnabledNameGI(GetParamByPathOrMarker('StartCenter'));
        Galaxy.CustomRules.MaxRangeMissiles := ParseEnabledNameGI(GetParamByPathOrMarker('MaxRangeMissiles'));
        Galaxy.CustomRules.OldHyperspace := ParseEnabledNameGI(GetParamByPathOrMarker('OldHyper'));
        Galaxy.CustomRules.PirateNodes := ParseEnabledNameGI(GetParamByPathOrMarker('PirateNodes'));
        Galaxy.CustomRules.AIUseShops := ParseEnabledNameGI(GetParamByPathOrMarker('AIUseShops'));
        Galaxy.CustomRules.StationsUseShop := ParseEnabledNameGI(GetParamByPathOrMarker('RuinsUseShop'));
        Galaxy.CustomRules.DuplicateArtefacts := ParseEnabledNameGI(GetParamByPathOrMarker('DuplicateArts'));
        Galaxy.CustomRules.HullGrowth := StrToInt(GetParamByPathOrMarker('HullGrowth'));
        Galaxy.CustomRules.ArcadeEquipmentChange := ParseEnabledNameGI(GetParamByPathOrMarker('ABChangeEq'));
        Galaxy.CustomRules.OldSpeedCalculation := ParseEnabledNameGI(GetParamByPathOrMarker('OldSpeedCalc'));
        Galaxy.CustomRules.OldMissileBonuses := ParseEnabledNameGI(GetParamByPathOrMarker('OldMissileBonuses'));
      end;
    end;
    Galaxy.GenerationMachineHash := ComputeMachineFingerprintCRC;
    Galaxy.InitializeCampaignState;
    NewGameGenerationStage := 1;
    PlayerStar := nil;
    Stage := 1;
    for I := 1 to GalaxyStarCount do
    begin
      Star := TStar.Create;
      Galaxy.Stars.Add(Star);
    end;
    Galaxy.GenerateGalaxyLayout(PlayerRace);
    Stage := 2;
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Galaxy.Stars[I];
      Star.BackgroundImage := -1;
    end;
    Stage := 3;
    TStar(Galaxy.Stars[0]).BackgroundImage := 14;
    TStar(Galaxy.Stars[1]).BackgroundImage := 5;
    TStar(Galaxy.Stars[2]).BackgroundImage := 70;
    TStar(Galaxy.Stars[3]).BackgroundImage := 11;
    TStar(Galaxy.Stars[4]).BackgroundImage := 3;
    TStar(Galaxy.Stars[70]).BackgroundImage := 72;
    TStar(Galaxy.Stars[71]).BackgroundImage := 72;
    for I := 0 to 5 do
    begin
      repeat
        J := NextRandomIntRange(0, Galaxy.Stars.Count - 1, Galaxy.RandomState);
        Star := Galaxy.Stars[J];
      until Star.BackgroundImage < 0;
      Star.BackgroundImage := 50 + I;
    end;
    Stage := 4;
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Galaxy.Stars[I];
      if Star.BackgroundImage < 0 then Star.BackgroundImage := NextRandomIntRange(0,15,Galaxy.RandomState);
    end;
    Stage := 5;
    NewGameGenerationStage := 2;
    SpecialStar := nil;
    HomePlanet := nil;
    MaximumDistance := 0;
    N := 0;
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Galaxy.Stars[I];
      if Star <> SpecialStar then Star.GenerateSystemContents(False)
      else
      begin
        Star.BackgroundImage := 71;
        Star.GenerateSystemContents(True);
      end;
      if HomePlanet = nil then
        for J := 0 to Star.Planets.Count - 1 do
        begin
          Planet := Star.Planets[J];
          if RaceToOwner(PlayerRace) = Planet.OwnerId then
          begin
            HomePlanet := Planet;
            Inc(N);
            if N = 1 then Continue;
            for K := I + 1 to Galaxy.Stars.Count - 1 do
            begin
              OtherStar := Galaxy.Stars[K];
              Distance := Round(PointDistance(OtherStar.Position, HomePlanet.CurrentStar.Position));
              if Distance > MaximumDistance then
              begin
                MaximumDistance := Distance;
                SpecialStar := OtherStar;
              end
              else if Distance = MaximumDistance then
              begin
                EdgeDistance := Sqr(Min(GalaxySizeX - SpecialStar.Position.X, SpecialStar.Position.X)) +
                  Sqr(Min(GalaxySizeY - SpecialStar.Position.Y, SpecialStar.Position.Y));
                OtherEdgeDistance := Sqr(Min(GalaxySizeX - OtherStar.Position.X, OtherStar.Position.X)) +
                  Sqr(Min(GalaxySizeY - OtherStar.Position.Y, OtherStar.Position.Y));
                if OtherEdgeDistance < EdgeDistance then SpecialStar := OtherStar;
              end;
            end;
            Break;
          end;
        end;
    end;
    TStar(Galaxy.Stars[Galaxy.Stars.Count - 1]).Name := SpecialStar.Name;
    for OwnerId := oiMaloc to oiPirate do
    begin
      NameLists[OwnerId] := TList.Create;
      if LanguageDataConfig.GetBlock('PlanetName').CountBlocks(OwnerInfo[OwnerId].InternalName) > 0 then
      begin
        J := LanguageDataConfig.GetBlock('PlanetName').GetBlock(OwnerInfo[OwnerId].InternalName).GetParamCount;
        for K := 0 to J - 1 do NameLists[OwnerId].Add(Pointer(K));
      end;
    end;
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Galaxy.Stars[I];
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        if Planet.Name = '' then
        begin
          OwnerId := Planet.OwnerId;
          if I < 5 then K := 0
          else if NameLists[OwnerId].Count > 0 then K := NextRandomIntRange(0,NameLists[OwnerId].Count - 1,Galaxy.RandomState)
          else K := -1;
          if K >= 0 then
          begin
            Planet.Name := LanguageDataConfig.GetBlock('PlanetName').GetBlock(OwnerInfo[OwnerId].InternalName).GetParamValue(Integer(NameLists[OwnerId][K]));
            NameLists[OwnerId].Delete(K);
          end
          else Planet.Name := Star.Name + '-' + IntToStr(J + 1);
        end;
      end;
    end;
    for OwnerId := oiMaloc to oiPirate do NameLists[OwnerId].Free;
    if Galaxy.CustomRules.StartInCenter then
    begin
      Center.X := GalaxySizeX * 0.5;
      Center.Y := GalaxySizeY * 0.5;
      StartStar := HomePlanet.CurrentStar;
      Score := PointDistanceSquared(Center,StartStar.Position) - (StartStar.Planets.Count - StartStar.CountPlanetsByOwner(oiUninhabited)) * 10 - PointDistanceSquared(SpecialStar.Position,StartStar.Position) * 0.25;
      for I := 0 to Galaxy.Stars.Count - 1 do
      begin
        Star := Galaxy.Stars[I];
        if (Star <> SpecialStar) and (Star <> StartStar) and (Star.CountPlanetsByOwner(RaceToOwner(PlayerRace)) >= 2) then
          if PointDistanceSquared(Center,Star.Position) - (Star.Planets.Count - Star.CountPlanetsByOwner(oiUninhabited)) * 10 - PointDistanceSquared(SpecialStar.Position,Star.Position) * 0.25 < Score then
          begin
            StartStar := Star;
            Score := PointDistanceSquared(Center,Star.Position) - (Star.Planets.Count - Star.CountPlanetsByOwner(oiUninhabited)) * 10 - PointDistanceSquared(SpecialStar.Position,Star.Position) * 0.25;
          end;
      end;
      if StartStar <> HomePlanet.CurrentStar then
        for I := 0 to StartStar.Planets.Count - 1 do
          if TPlanet(StartStar.Planets[I]).OwnerId = RaceToOwner(PlayerRace) then
          begin
            HomePlanet := StartStar.Planets[I];
            Break;
          end;
    end;
    Galaxy.HideSpecialConstellation;
    Stage := 6;
    Galaxy.RefreshTechLevel;
    Galaxy.RebuildStarDistances;
    Stage := 7;
    Player := TPlayer.Create;
    Player.PortraitFaceId := CaptainPortraitIndex;
    Planet := HomePlanet;
    PlayerStar := Planet.CurrentStar;
    case CharacterPreset of
      1:
        begin
          Player.PreferredCareer := rcWarrior;
          Player.CareerStatus[rcWarrior] := NextRandomIntRange(70,90,Galaxy.RandomState);
          Player.CareerStatus[rcPirate] := (100 - Player.CareerStatus[rcWarrior]) div NextRandomIntRange(2,3,Galaxy.RandomState);
          Player.CareerStatus[rcTrader] := 100 - Player.CareerStatus[rcWarrior] - Player.CareerStatus[rcPirate];
        end;
      2:
        begin
          Player.PreferredCareer := rcWarrior;
          Player.CareerStatus[rcWarrior] := NextRandomIntRange(60,70,Galaxy.RandomState);
          Player.CareerStatus[rcPirate] := (100 - Player.CareerStatus[rcWarrior]) div NextRandomIntRange(3,4,Galaxy.RandomState);
          Player.CareerStatus[rcTrader] := 100 - Player.CareerStatus[rcWarrior] - Player.CareerStatus[rcPirate];
        end;
      3:
        begin
          Player.PreferredCareer := rcTrader;
          Player.CareerStatus[rcTrader] := NextRandomIntRange(70,90,Galaxy.RandomState);
          Player.CareerStatus[rcPirate] := (100 - Player.CareerStatus[rcTrader]) div NextRandomIntRange(2,3,Galaxy.RandomState);
          Player.CareerStatus[rcWarrior] := 100 - Player.CareerStatus[rcTrader] - Player.CareerStatus[rcPirate];
        end;
      4:
        begin
          Player.PreferredCareer := rcPirate;
          Player.CareerStatus[rcPirate] := NextRandomIntRange(60,70,Galaxy.RandomState);
          Player.CareerStatus[rcTrader] := (100 - Player.CareerStatus[rcPirate]) div NextRandomIntRange(2,3,Galaxy.RandomState);
          Player.CareerStatus[rcWarrior] := 100 - Player.CareerStatus[rcPirate] - Player.CareerStatus[rcTrader];
        end;
      5:
        begin
          Player.PreferredCareer := rcPirate;
          Player.CareerStatus[rcPirate] := NextRandomIntRange(70,90,Galaxy.RandomState);
          Player.CareerStatus[rcTrader] := (100 - Player.CareerStatus[rcPirate]) div NextRandomIntRange(2,3,Galaxy.RandomState);
          Player.CareerStatus[rcWarrior] := 100 - Player.CareerStatus[rcPirate] - Player.CareerStatus[rcTrader];
        end;
    end;
    Player.InitializePlayerAtPlanet(Planet,GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].StartingPlayerMoney,CharacterPreset);
    case CharacterPreset of
      1:
        begin
          Player.PreferredCareer := rcWarrior;
          Player.CareerStatus[rcWarrior] := NextRandomIntRange(70,90,Galaxy.RandomState);
          Player.CareerStatus[rcPirate] := (100 - Player.CareerStatus[rcWarrior]) div NextRandomIntRange(2,3,Galaxy.RandomState);
          Player.CareerStatus[rcTrader] := 100 - Player.CareerStatus[rcWarrior] - Player.CareerStatus[rcPirate];
        end;
      2:
        begin
          Player.PreferredCareer := rcWarrior;
          Player.CareerStatus[rcWarrior] := NextRandomIntRange(60,70,Galaxy.RandomState);
          Player.CareerStatus[rcPirate] := (100 - Player.CareerStatus[rcWarrior]) div NextRandomIntRange(3,4,Galaxy.RandomState);
          Player.CareerStatus[rcTrader] := 100 - Player.CareerStatus[rcWarrior] - Player.CareerStatus[rcPirate];
        end;
      3:
        begin
          Player.PreferredCareer := rcTrader;
          Player.CareerStatus[rcTrader] := NextRandomIntRange(70,90,Galaxy.RandomState);
          Player.CareerStatus[rcPirate] := (100 - Player.CareerStatus[rcTrader]) div NextRandomIntRange(2,3,Galaxy.RandomState);
          Player.CareerStatus[rcWarrior] := 100 - Player.CareerStatus[rcTrader] - Player.CareerStatus[rcPirate];
        end;
      4:
        begin
          Player.PreferredCareer := rcPirate;
          Player.CareerStatus[rcPirate] := NextRandomIntRange(60,70,Galaxy.RandomState);
          Player.CareerStatus[rcTrader] := (100 - Player.CareerStatus[rcPirate]) div NextRandomIntRange(2,3,Galaxy.RandomState);
          Player.CareerStatus[rcWarrior] := 100 - Player.CareerStatus[rcPirate] - Player.CareerStatus[rcTrader];
        end;
      5:
        begin
          Player.PreferredCareer := rcPirate;
          Player.CareerStatus[rcPirate] := NextRandomIntRange(70,90,Galaxy.RandomState);
          Player.CareerStatus[rcTrader] := (100 - Player.CareerStatus[rcPirate]) div NextRandomIntRange(2,3,Galaxy.RandomState);
          Player.CareerStatus[rcWarrior] := 100 - Player.CareerStatus[rcPirate] - Player.CareerStatus[rcTrader];
        end;
    end;
    SetPlayer(Player,Galaxy);
    GetPlayer.HomePlanet.ChangeRelationToRanger(GetPlayer,100);
    GetPlayer.Name := PlayerName;
    PlayerOldQuests := aMyFunction.TObjectList.Create;
    LastLoadedPlayerName := PlayerName;
    Stage := 8;
    Galaxy.RefreshRangerWealthStats;
    Galaxy.RefreshRangerStrengthStats;
    Stage := 9;
    Star := TObject(GetPlayer.CurrentStar.StarDistances[Galaxy.Stars.Count - 1].Star) as TStar;
    Galaxy.CreateDominatorSpawnProxy(Star);
    I := 0;
    while I < Galaxy.Stars.Count do
    begin
      Star := SpecialStar.StarDistances[I].Star;
      if GetPlayer.CurrentStar = Star then Inc(I)
      else
      begin
        TerronShip := TKling.Create;
        TerronShip.InitTerron(Star);
        PieceCreatorTargetStarId := Star.Id;
        Inc(I);
        Break;
      end;
    end;
    while I < Galaxy.Stars.Count do
    begin
      Star := SpecialStar.StarDistances[I].Star;
      if GetPlayer.CurrentStar = Star then Inc(I)
      else
      begin
        BlazerShip := TKling.Create;
        BlazerShip.InitBlazer(Star);
        Inc(I);
        Break;
      end;
    end;
    while I < Galaxy.Stars.Count do
    begin
      Star := SpecialStar.StarDistances[I].Star;
      if GetPlayer.CurrentStar = Star then Inc(I)
      else
      begin
        KellerShip := TKling.Create;
        KellerShip.InitKeller(Star);
        Break;
      end;
    end;
    Stage := 10;
    N := Round(Galaxy.GetInitialDominatorControlPercent * (Galaxy.Stars.Count / 100));
    if N > Galaxy.Stars.Count - 1 then N := Galaxy.Stars.Count - 1;
    for I := 0 to N do
    begin
      Star := TObject(BlazerShip.CurrentStar.StarDistances[I].Star) as TStar;
      if (GetPlayer.CurrentStar.Constellation <> Star.Constellation) and
        (GetPlayer.CurrentStar.StarDistances[1].Star <> Star) and
        (Star.Constellation.Id <> 20) then
      begin
        if (BlazerShip.CurrentStar = Star) or (KellerShip.CurrentStar = Star) or
          (TerronShip.CurrentStar = Star) then Star.ControlFaction := sfDominators;
        if ((Galaxy.Constellations.IndexOf(Star.Constellation) >= 5) or
          (NextRandomUnitFloat(Galaxy.RandomState) >= 0.4)) and
          ((N div 2 > I) or (NextRandomUnitFloat(Galaxy.RandomState) < 0.8)) then
          Star.ControlFaction := sfDominators;
      end;
    end;
    Stage := 11;
    N := Round((Galaxy.Stars.Count / 100) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[0]].InitialPirateControlPercent);
    for I := 0 to N do
    begin
      Star := Galaxy.Stars[70];
      Star := TObject(Star.StarDistances[I].Star) as TStar;
      if (GetPlayer.CurrentStar.Constellation <> Star.Constellation) and
        (GetPlayer.CurrentStar.StarDistances[1].Star <> Star) and
        (Star.Constellation.Id <> 20) and
        ((Galaxy.Constellations.IndexOf(Star.Constellation) >= 5) or
          (NextRandomUnitFloat(Galaxy.RandomState) >= 0.4)) and
          ((N div 2 > I) or (NextRandomUnitFloat(Galaxy.RandomState) < 0.8)) then
          Star.ControlFaction := sfPirates;
    end;
    TStar(Galaxy.Stars[70]).ControlFaction := sfPirates;
    TStar(Galaxy.Stars[71]).ControlFaction := sfPirates;
    Stage := 12;
    NewGameGenerationStage := 3;
    Galaxy.AssignTextQuestsToPlanets;
    Galaxy.InitializeConstellationDistanceTiers;
    for I := 0 to Galaxy.Constellations.Count - 1 do
    begin
      Constellation := Galaxy.Constellations[I];
      if Constellation.SharesOutlineSegment(GetPlayer.HomePlanet.CurrentStar.Constellation) then
        Constellation.Visible := True else Constellation.Visible := False;
    end;
    Stage := 13;
    NewGameGenerationStage := 4;
    for I := 0 to Galaxy.Planets.Count - 1 do
    begin
      Planet := Galaxy.Planets[I];
      if (Planet.IsCoalitionOwned or (Planet.OwnerId = oiPirate)) and
        (Planet.CurrentStar.ControlFaction = sfDominators) then
      begin
        Planet.OwnerId := oiDominator;
        Planet.UpdateOwnerFlags;
      end;
      if (Planet.OwnerId <> oiUninhabited) and (Planet.CurrentStar.ControlFaction = sfPirates) then
      begin
        Planet.OwnerId := oiPirate;
        Planet.UpdateOwnerFlags;
      end;
      case Planet.OwnerId of
        oiMaloc..oiGaal:
          begin
            Planet.SpawnTransport(0,100);
            Planet.SpawnTransport(0,100);
            Planet.BuyWarrior(100);
            if Galaxy.Rangers.Count < Galaxy.CountFactionStars(sfCoalition) * 1.2 then
            begin
              Planet.BuyRanger(100);
              Galaxy.RefreshRangerStrengthStats;
            end;
          end;
        oiDominator:
          while (Planet.CurrentStar.ShipTypeCounts[stKling] < 10) and
            ((Planet.CurrentStar.SumBestRangerRelativeStrength(InitialDominatorShipMask) <
              DominatorRetreatStrengthByTier[Planet.CurrentStar.Constellation.HomeDistanceTier]) or
              (Planet.CurrentStar.ShipTypeCounts[stKling] < 8)) do
            Planet.SpawnWeightedDominatorShip;
        oiPirate:
          begin
            Planet.BuyPirate(100);
            Planet.BuyPirate(100);
            Planet.BuyWarrior(100);
            Planet.BuyWarrior(100);
            Planet.BuyWarrior(100);
          end;
      end;
    end;
    Stage := 14;
    NewGameGenerationStage := 5;
    TRuins.Create.Init(rstRangerCenter,GetPlayer.CurrentStar,'');
    TRuins.Create.Init(rstScienceBase,GetPlayer.CurrentStar,'');
    TRuins.Create.Init(rstMedicalBase,GetPlayer.CurrentStar,'');
    TRuins.Create.Init(rstPirateBase,TObject(GetPlayer.CurrentStar.StarDistances[3].Star) as TStar,'');
    TRuins.Create.Init(rstBusinessCenter,TObject(GetPlayer.CurrentStar.StarDistances[1].Star) as TStar,'');
    TRuins.Create.Init(rstMilitaryBase,TObject(GetPlayer.CurrentStar.StarDistances[2].Star) as TStar,'');
    Galaxy.UpdateConstellationMilitaryStats;
    Stage := 15;
    for I := 1 to Galaxy.Rangers.Count - 1 do
    begin
      Ranger := Galaxy.Rangers[I];
      for N := 1 to Round(RemapClamped(NextRandomIntRange(0,1000,Ranger.RandomState),0,1000,5,50)) do
        Ranger.SimulateUnseenProgression;
    end;
    Stage := 16;
    Galaxy.RunConfigOnStartHandlers;
    Galaxy.AppendIntegritySnapshot;
    NewGameGenerationStage := 6;
    Stage := 17;
    CalculateGalaxyTurnAndWait;
    if ExitScreenLoop then Exit;
    for I := 1 to GalaxyWarmupTurns do
    begin
      if I mod 20 = 0 then SysUtils.Sleep(1);
      CalculatePlayerStarTurnAndWait;
      if ExitScreenLoop then Exit;
      CalculateGalaxyTurnAndWait;
      if ExitScreenLoop then Exit;
    end;
    Stage := 18;
    GetPlayer.CurrentPlanet := nil;
    GetPlayer.DockedTo := nil;
    for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
    begin
      Ship := GetPlayer.CurrentStar.Ships[I];
      if Ship.TypeId = Byte(rstRangerCenter) then
      begin
        GetPlayer.DockedTo := Ship;
        Break;
      end;
    end;
    if GetPlayer.DockedTo = nil then
    begin
      AppendLogLineThreadSafe('Galaxy create exception, not found rc, seed = ' + IntToStr(Integer(Galaxy.GenerationSeed)));
      if GetPlayer.CurrentStar.ControlFaction <> sfDominators then
        for I := 0 to GetPlayer.CurrentStar.Planets.Count - 1 do
          if TPlanet(GetPlayer.CurrentStar.Planets[I]).OwnerId <> oiUninhabited then
          begin
            GetPlayer.CurrentPlanet := GetPlayer.CurrentStar.Planets[I];
            Break;
          end;
      if GetPlayer.CurrentPlanet = nil then
        for I := 0 to GetPlayer.CurrentStar.Planets.Count - 1 do
          if TPlanet(GetPlayer.CurrentStar.Planets[I]).OwnerId = oiUninhabited then
          begin
            GetPlayer.CurrentPlanet := GetPlayer.CurrentStar.Planets[I];
            Break;
          end;
      if GetPlayer.CurrentPlanet = nil then GetPlayer.CurrentPlanet := GetPlayer.CurrentStar.Planets[0];
    end;
    Galaxy.IronWill := NewGameGenerationThread.IronWill;
    for I := 0 to 1 do Inc(GetPlayer.BaseSkills[StartingSkills[I]]);
    for I := 0 to 1 do
    begin
      case StartingItemTypes[I] of
        43:
          begin
            Item := TFuelTanks.Create;
            (Item as TFuelTanks).Init(Round(FuelTanksBaseSize * EquipmentSizeFactors[4]),2,GetPlayer.OwnerId);
          end;
        44:
          begin
            Item := TEngine.Create;
            (Item as TEngine).Init(Round(EngineBaseSize * EquipmentSizeFactors[3]),2,GetPlayer.OwnerId);
          end;
        45:
          begin
            Item := TRadar.Create;
            (Item as TRadar).Init(Round(RadarBaseSize * EquipmentSizeFactors[3]),2,GetPlayer.OwnerId);
          end;
        46:
          begin
            Item := TScaner.Create;
            (Item as TScaner).Init(Round(ScannerBaseSize * EquipmentSizeFactors[4]),2,GetPlayer.OwnerId);
          end;
        47:
          begin
            Item := TRepairRobot.Create;
            (Item as TRepairRobot).Init(Round(RepairRobotBaseSize * EquipmentSizeFactors[3]),2,GetPlayer.OwnerId);
          end;
        48:
          begin
            Item := TCargoHook.Create;
            (Item as TCargoHook).Init(Round(CargoHookBaseSize * EquipmentSizeFactors[3]),2,GetPlayer.OwnerId);
          end;
        49:
          begin
            Item := TDefGenerator.Create;
            (Item as TDefGenerator).Init(Round(DefGeneratorBaseSize * EquipmentSizeFactors[3]),2,GetPlayer.OwnerId);
          end;
        50:
          begin
            Item := TWeapon.Create;
            (Item as TWeapon).Init(t_Weapon1,Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[4]),3,GetPlayer.OwnerId);
          end;
        51:
          begin
            Item := TWeapon.Create;
            (Item as TWeapon).Init(t_Weapon2,Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[3]),2,GetPlayer.OwnerId);
          end;
        52:
          begin
            Item := TWeapon.Create;
            (Item as TWeapon).Init(t_Weapon3,Round(WeaponInfos[t_Weapon3].AverageSize * EquipmentSizeFactors[2]),2,GetPlayer.OwnerId);
          end;
        53:
          begin
            Item := TWeapon.Create;
            (Item as TWeapon).Init(t_Weapon4,Round(WeaponInfos[t_Weapon4].AverageSize * EquipmentSizeFactors[3]),1,GetPlayer.OwnerId);
          end;
        54:
          begin
            Item := TWeapon.Create;
            (Item as TWeapon).Init(t_Weapon5,Round(WeaponInfos[t_Weapon5].AverageSize * EquipmentSizeFactors[4]),1,GetPlayer.OwnerId);
          end;
      else
        Item := TRadar.Create;
        (Item as TRadar).Init(Round(RadarBaseSize * EquipmentSizeFactors[4]),2,GetPlayer.OwnerId);
      end;
      case Galaxy.DifficultyLevels[7] of
        0: Item.Improve(ikMajor);
        1: Item.Improve(ikMedium);
        2: Item.Improve(ikMinor);
      end;
      GetMem(Entry,12);
      GetPlayer.StorageEntries.Add(Entry);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.Item := Item;
      Entry.SlotIndex := 0;
    end;
    Stage := 19;
    // Native code passes the last planet visited by the population loop above.
    GetPlayer.ApplyCharacterPreset(Planet,GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].StartingPlayerMoney,CharacterPreset);
    GetPlayer.RefreshStorageBubbles;
    RunGlobalScriptsForContext(GetPlayer.CurrentStar,0);
    NewGameGenerationStage := 8;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('Galaxy create exception, label = ' + IntToStr(Stage) + ' seed = ' + IntToStr(Integer(Galaxy.GenerationSeed)));
    end;
  end;
end;

{ @end $8183AC }

end.
