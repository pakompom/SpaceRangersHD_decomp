unit ab_ShipAI;
// Unit bracket (inferred): .text 0x0067E7DC..0x00681B31; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_Tail, ab_Global, ab_Object, ab_Ship, ab_Zone, ab_Item, aItem;

const
  // Native DecideActions ($67FF34) selects and dispatches these maneuvers.
  amUnselected = -1;
  amApproach = 0;
  amCloseEvasion = 1;
  amFlank = 2;
  amReverseTurn = 3;
  amFollowReverse = 4;

type
  TabShipAI = class(TabShip) // @size $388
  public
    CurrentZone: PabZone; // @offset $2E0
    InsideCurrentZone: Boolean; // @offset $2E4
    CurrentZoneBearing: Double; // @offset $2E8
    CurrentZoneAngularRadius: Double; // @offset $2F0
    HeadingInsideCurrentZone: Boolean; // @offset $2F8
    TargetShip: TabShip; // @offset $2FC
    TargetBearing: TSphericalBearingDistance; // @offset $300
    ReverseTargetBearing: TSphericalBearingDistance; // @offset $310
    TargetPathClear: Boolean; // @offset $320
    RouteZone: PabZone; // @offset $324
    RouteBearing: Double; // @offset $328
    RouteAngularRadius: Double; // @offset $330
    HeadingInsideRoute: Boolean; // @offset $338
    DirectPathClear: Boolean; // @offset $339
    DirectBearing: TSphericalBearingDistance; // @offset $340
    DirectTargetLongitude: Double; // @offset $350
    DirectTargetPolarAngle: Double; // @offset $358
    Intent: Integer; // @offset $360 Native numeric intent; used by scripted/campaign steering.
    CombatManeuver: Integer; // @offset $364 am* selector; negative values request a new choice.
    ManeuverUntilTick: Integer; // @offset $368
    TargetBonus: TabItem; // @offset $36C
    BonusRouteZone: PabZone; // @offset $370
    AvoidanceZone: PabZone; // @offset $374
    DamagingZone: PabZone; // @offset $378
    LastDamageTick: Integer; // @offset $37C
    RecentHitCount: Integer; // @offset $380
    IncomingThreat: Boolean; // @offset $384
    RetreatRequested: Boolean; // @offset $385
    AIEnabled: Boolean; // @offset $386
    constructor Create; // @addr $67E848 @ida "TabShipAI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $67E8A0 @ida "void __usercall $name(TabShipAI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function GetRewardItem(Preview: Boolean): TItem; // @addr $67E8F8
    procedure ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean); override; // @addr $67EE3C
    procedure UpdateState; override; // @addr $67FA68
    procedure Advance; override; // @addr $67FB04
    procedure ResetIntent; // @addr $67FED0
    procedure DecideActions; // @addr $67FF34
    procedure SetDirectDestination(Longitude, PolarAngle: Single); // @addr $680AF8 @ida "void __userpurge $name(TabShipAI *Self@<eax>, float Longitude@<^4>, float PolarAngle@<^0>);"
    procedure FollowDirectDestination; // @addr $680BEC
    procedure AvoidImmediateObstacle; // @addr $680C74
    procedure ClearRoute; // @addr $680D00
    procedure SetRoute(Target: PabZone); // @addr $680D20
    procedure FollowRoute; // @addr $680D90
    function TryMoveToDestination(Zone: PabZone; Longitude, PolarAngle: Double): Boolean; // @addr $681674 @ida "bool __userpurge $name@<al>(TabShipAI *Self@<eax>, TabZone *Zone@<edx>, double Longitude@<^8>, double PolarAngle@<^0>);"
    procedure SetAndFollowRoute(Target: PabZone); // @addr $681790
    procedure FollowDestinationRoute; // @addr $68181C
    procedure ApproachTarget; // @addr $6810B4
    function ScoreApproach: Integer; // @addr $681188
    procedure EvadeCloseTarget; // @addr $6811B4
    function ScoreCloseEvasion: Integer; // @addr $681224
    procedure FlankTarget; // @addr $681298
    function ScoreFlanking: Integer; // @addr $681350
    procedure ReverseTowardTarget; // @addr $681498
    function ScoreReverseTurn: Integer; // @addr $6814D0
    procedure MatchReversingTarget; // @addr $68159C
    function ScoreReverseFollowing: Integer; // @addr $6815B0
    procedure NoticeCollision; // @addr $67FE58
    procedure NoticeDamagingZone(Zone: PabZone); // @addr $67FEA4
  end;

implementation

uses Math, aMyFunction, ab_StopLine, GlobalsV, Globals, aGalaxy, aGalaxyEvent, aGalaxyStruct, aPlayer, aShip, aConst, aTranclucator, ab_Space, fShip2, Achievements, aNormalShip;

{ @routine $67E848 TabShipAI_Create }
constructor TabShipAI.Create;
begin
  inherited Create;
  CombatManeuver := amUnselected;
  AIEnabled := True;
end;
{ @end $67E848 }

{ @routine $67E8A0 TabShipAI_Destroy }
destructor TabShipAI.Destroy;
begin
  if RewardObject <> nil then
  begin
    RewardObject.Free;
    RewardObject := nil;
  end;
  inherited Destroy;
end;
{ @end $67E8A0 }

{ @routine $67E8F8 TabShipAI_GetRewardItem }
function TabShipAI.GetRewardItem(Preview: Boolean): TItem;
var
  Reward: TItem;
  LivingEnemies, Index, RepeatPenalty: Integer;
  SavedRandomState, SavedNextItemId: Cardinal;
  KellerPresent, UsedSubportal: Boolean;
  Event: TGalaxyEvent;
  Hole: THole;
  SavedChaoticRandom: Boolean;
begin
  Result := nil;
  if (GetPlayer <> nil) and (PlayerArcadeShip <> nil) then
    if RewardObject <> nil then
    begin
      if (RewardObject is TArtefact) and not Preview then
      begin
        Result := TItem(RewardObject);
        RewardObject := nil;
      end;
    end
    else if not RandomRewardsDisabled then
    begin
      UsedSubportal := False;
      RepeatPenalty := 0;
      if (GetPlayer.Order = soJumpHole) and (GetPlayer.OrderTarget <> nil) and (GetPlayer.OrderTarget is THole) then
      begin
        Hole := GetPlayer.OrderTarget as THole;
        for Index := Galaxy.GalaxyEvents.Count - 1 downto 0 do
        begin
          Event := TGalaxyEvent(Galaxy.GalaxyEvents[Index]);
          if (Event.EventType = 'PlayerUsesSubportal') and (Event.GetData(0) = Integer(Hole.Id)) and (Event.GetData(1) = Hole.CreatedTurn) then
          begin
            UsedSubportal := True;
            Break;
          end;
        end;
      end;
      if UsedSubportal then
        for Index := Galaxy.GalaxyEvents.Count - 1 downto 0 do
        begin
          Event := TGalaxyEvent(Galaxy.GalaxyEvents[Index]);
          if Event.Turn + SubportalRewardPenaltyTurns < Galaxy.CurrentTurn then Break;
          if Event.EventType = 'PlayerJumpsThroughSubportal' then Inc(RepeatPenalty, SubportalRewardPenalty);
        end;
      Reward := nil;
      LivingEnemies := 0;
      KellerPresent := False;
      for Index := 0 to PlayerArcadeShip.Enemies.Count - 1 do
      begin
        if (KellerArcadeShip <> nil) and (PlayerArcadeShip.Enemies[Index] = KellerArcadeShip) and (KellerArcadeShip <> Self) then KellerPresent := True;
        if (TObject(PlayerArcadeShip.Enemies[Index]) is TabShip) and (TabShip(PlayerArcadeShip.Enemies[Index]).Health > 0) then Inc(LivingEnemies);
      end;
      Index := 0;
      SavedRandomState := RandomState;
      RandomState := InitialRandomSeed;
      SavedChaoticRandom := False;
      SavedNextItemId := 0;
      if Galaxy <> nil then
      begin
        SavedChaoticRandom := Galaxy.CustomRules.ChaoticRandom;
        Galaxy.CustomRules.ChaoticRandom := False;
        SavedNextItemId := Galaxy.NextItemId;
      end;
      if (ArcadeKellerDefeats = 0) and not KellerPresent and (GetPlayer.Order = soJumpHole) and
        ((LivingEnemies = 0) or Preview) and
        ((LivingEnemies + GetPlayer.BlackHoleKillCount < 20) or (RandomRange(0, 100) > RepeatPenalty + 30)) then
      begin
        while Reward = nil do
        begin
          Inc(Index);
          Reward := CreateRandomLootItem(ilpArcadeBattle, 6, AdvanceRandomSeed(RandomState));
          if GetPlayer.HasMatchingArtefactOrCustomItem(Reward) and (Index < 5) then
          begin
            Reward.Free;
            Reward := nil;
            Galaxy.NextItemId := SavedNextItemId;
          end
          else if (GetPlayer.GetBaseCargoHookPower > 0) and (GetPlayer.GetBaseCargoHookPower < Reward.Weight) and
            (LivingEnemies + GetPlayer.BlackHoleKillCount < 5) and (Index < 5) then
          begin
            Reward.Free;
            Reward := nil;
            Galaxy.NextItemId := SavedNextItemId;
          end
          else Break;
        end;
        if Reward is TArtefactTranclucator then
          (TObject((Reward as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := GetPlayer;
      end;
      RandomState := SavedRandomState;
      if Galaxy <> nil then
      begin
        Galaxy.CustomRules.ChaoticRandom := SavedChaoticRandom;
        if Preview then Galaxy.NextItemId := SavedNextItemId;
      end;
      if UsedSubportal and not Preview and (LivingEnemies = 0) then AddGalaxyEvent('PlayerJumpsThroughSubportal');
      Result := Reward;
    end;
end;
{ @end $67E8F8 }

{ @routine $67EE3C TabShipAI_ApplyDamage }
procedure TabShipAI.ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean);
var
  Index, Attempts: Integer;
  Item: TEquipment;
  Reward: TItem;
  // Native has 16 unreferenced bytes between Reward and LivingEnemies,
  // and another 16 between RewardScale and SavedNextItemId. Original
  // local types and allocation remain unresolved.
  Unused20, Unused24, Unused28, Unused2C: Integer;
  LivingEnemies: Integer;
  RewardScale: Single;
  Unused38, Unused3C, Unused40, Unused44: Integer;
  SavedNextItemId: Cardinal;
  Event: TGalaxyEvent;
  ItemType: Byte;
  Weight, Level: Integer;
  Info: PWeaponInfo;
  MinSize, MaxSize: Single;
  MinLevel, MaxLevel, WeaponTech: Integer;

  // @nested $67EE1C AddArcadeRewardToList
  procedure AddArcadeRewardToList(Item: TObject); // @addr $67EE1C @ida "void __usercall $name(TObject *Item@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x67f152,0x67f1e3,0x67f716,0x67f8ec"
  begin
    ArcadeBattleScreen.ListedObjects.Add(Item);
  end;

begin
  if Health > 0 then
  begin
    if (Galaxy <> nil) and (Galaxy.KellerLeaveTurn > 0) and (KellerArcadeShip = Self) then Exit;
    inherited ApplyDamage(Amount, Source, Disrupt);
    LastDamageTick := ArcadeTickCount;
    Inc(RecentHitCount);
    if (GetPlayer <> nil) and (Health <= 0) and (PlayerArcadeShip <> nil) and (Enemies.IndexOf(PlayerArcadeShip) < 0) then
    begin
      if Galaxy <> nil then
        if ScriptLabel <> '' then
        begin
          Event := AddGalaxyEvent('LabeledShipKilledInAB');
          Event.AddTextData(ScriptLabel);
        end;
    end
    else if (GetPlayer <> nil) and (Health <= 0) and (PlayerArcadeShip <> nil) and (Enemies.IndexOf(PlayerArcadeShip) >= 0) then
    begin
      Galaxy.CheckIntegrityChecksum1(619);
      LivingEnemies := 0;
      for Index := 0 to PlayerArcadeShip.Enemies.Count - 1 do
        if (TObject(PlayerArcadeShip.Enemies[Index]) is TabShip) and (TabShip(PlayerArcadeShip.Enemies[Index]).Health > 0) then Inc(LivingEnemies);
      RandomState := InitialRandomSeed;
      if GetPlayer.Order = soJumpHole then
      begin
        Inc(GetPlayer.BlackHoleKillCount);
        TryAddAchievementProgress('HOLEMAN', 1);
      end
      else
      begin
        Inc(GetPlayer.HyperspaceKillCount);
        TryAddAchievementProgress('HOLEMAN', 1);
        if GetPlayer.InHyperspace and (GetPlayer.OwnerId <> Byte(oiPirate)) then GetPlayer.AddRankPoints(2);
      end;
      if (Galaxy <> nil) and (ScriptLabel <> '') then
      begin
        Event := AddGalaxyEvent('LabeledShipKilledInAB');
        Event.AddTextData(ScriptLabel);
      end;
      Reward := GetRewardItem(False);
      if Reward <> nil then
      begin
        if KellerArcadeShip = Self then
        begin
          GetPlayer.ScriptItemsAct(satOnABItemDrop, Reward, nil, 0);
          ArcadeKellerReward := Reward;
        end
        else
        begin
          ClearPlayerHoldEntries;
          GetPlayer.ScriptItemsAct(satOnABItemDrop, Reward, nil, 0);
          if Reward is TArtefact then GetPlayer.Artefacts.Insert(0, Reward)
          else GetPlayer.Inventory.Add(Reward);
        end;
        AddArcadeRewardToList(Reward);
      end
      else if RewardObject <> nil then
      begin
        ClearPlayerHoldEntries;
        GetPlayer.ScriptItemsAct(satOnABItemDrop, RewardObject, nil, 0);
        if RewardObject is TArtefact then GetPlayer.Artefacts.Insert(0, RewardObject)
        else GetPlayer.Inventory.Add(RewardObject);
        AddArcadeRewardToList(RewardObject);
        RewardObject := nil;
        GetPlayer.RefreshDerivedStats(True);
      end
      else if ((LivingEnemies = 0) or
        ((LivingEnemies = 1) and (RandomRange(0, 100) * LuckScale > 50)) or
        ((LivingEnemies >= 2) and (RandomRange(0, 100) * LuckScale > 60))) and not RandomRewardsDisabled then
      begin
        Attempts := 0;
        RewardScale := Galaxy.GetArcadeDropValueModifier * RemapClamped(LivingEnemies, 0, 5, 1.56, 0.26) *
          GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].ArcadeRewardScale;
        if GetPlayer.Order = soJumpHole then
        begin
          if LivingEnemies = 0 then RewardScale := RewardScale * 3
          else RewardScale := 1.2 * RewardScale;
        end
        else RewardScale := RemapClamped(CurrentArcadeSpace.Danger + CurrentArcadeSpace.ApproachDanger, 50, 250, 0.3, 2) * RewardScale;
        MinSize := RemapClamped(Galaxy.TechLevel, 3, 8, EquipmentSizeFactors[4], EquipmentSizeFactors[5]);
        MaxSize := RemapClamped(Galaxy.TechLevel, 3, 8, EquipmentSizeFactors[2], EquipmentSizeFactors[4]);
        MinLevel := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 0.75) * 7 + 1);
        MaxLevel := Round(RemapClamped(Galaxy.TechLevel, 1, 7, 0.5, 1) * 7 + 1);
        SavedNextItemId := Galaxy.NextItemId;
        while True do
        begin
          if RandomRange(1, 110) > 70 then
          begin
            WeaponTech := RandomRange(Max(1, Galaxy.TechLevel - 1), Min(8, Galaxy.TechLevel + 1));
            Info := Galaxy.SelectWeaponInfo(RandomRange(1, 100000), [0],
              Min(WeaponTech + 1, 8), Max(1, WeaponTech - 1));
            Weight := RandomRange(Round(Info.AverageSize * MinSize), Round(Info.AverageSize * MaxSize));
            Level := RandomRange(MinLevel, MaxLevel);
            Item := CreateGeneratedWeapon(Info, Weight, Level, 6);
          end
          else
          begin
            ItemType := PickRandomItemType([Ord(t_FuelTanks)..Ord(t_DefGenerator)]);
            Weight := RandomRange(Round(GetAverageItemSize(ItemType) * MinSize), Round(GetAverageItemSize(ItemType) * MaxSize));
            Level := RandomRange(MinLevel, MaxLevel);
            Item := CreateGeneratedEquipment(TItemType(ItemType), Weight, Level, 6);
          end;
          Item.ConditionPercent := SeededRandomFloatRange(Item.Id * (Attempts + 11) * 123, 10, 100);
          Inc(Attempts);
          if Attempts > 10000 then
          begin
            ClearPlayerHoldEntries;
            GetPlayer.ScriptItemsAct(satOnABItemDrop, Item, nil, 0);
            GetPlayer.Inventory.Insert(1, Item);
            GetPlayer.RefreshDerivedStats(True);
            AddArcadeRewardToList(Item);
            Break;
          end;
          if (GetPlayer.GetBaseCargoHookPower > 0) and (GetPlayer.GetBaseCargoHookPower < Item.Weight) and
            (GetPlayer.BlackHoleKillCount + GetPlayer.HyperspaceKillCount < 17) then
          begin
            Item.Free;
            Galaxy.NextItemId := SavedNextItemId;
            Continue;
          end;
          if ((Item.GetConditionAdjustedCost < Max(800, GetPlayer.Wealth * RemapClamped(Attempts, 0, 500, 0.01 * RewardScale, 0.03 * RewardScale))) and
            ((Item.GetConditionAdjustedCost > GetPlayer.Wealth * 0.008 * RewardScale) or (Attempts > 500))) <> False then
          begin
            ClearPlayerHoldEntries;
            GetPlayer.ScriptItemsAct(satOnABItemDrop, Item, nil, 0);
            GetPlayer.Inventory.Insert(1, Item);
            GetPlayer.RefreshDerivedStats(True);
            AddArcadeRewardToList(Item);
            Break;
          end;
          Item.Free;
          Galaxy.NextItemId := SavedNextItemId;
        end;
      end;
      if KellerArcadeShip = Self then Inc(ArcadeKellerDefeats);
      Galaxy.PrimeIntegrityChecksum1(620);
    end
    else if Source <> nil then
      if (TargetShip <> Source) and (Source is TabShip) and (Enemies.IndexOf(Source) >= 0) then
        if (TargetShip = nil) or (DistanceTo(TargetShip) > MaximumWeaponRange) then TargetShip := Source as TabShip;
  end;
end;
{ @end $67EE3C }

{ @routine $67FA68 TabShipAI_UpdateState }
procedure TabShipAI.UpdateState;
begin
  inherited UpdateState;
  InsideCurrentZone := ab_Zone_FindContainingOrNearest(State.LongitudeDegrees, State.PolarAngleDegrees, CurrentZone);
  HeadingInsideCurrentZone := False;
  CurrentZoneBearing := 0;
  if CurrentZone <> nil then
    if not InsideCurrentZone then
      HeadingInsideCurrentZone := ab_Zone_IsHeadingInside(State, CurrentZone, CurrentZoneBearing, CurrentZoneAngularRadius);
end;
{ @end $67FA68 }

{ @routine $67FB04 TabShipAI_Advance }
procedure TabShipAI.Advance;
var
  ForwardDistance, BackwardDistance: Double;
  Attempt, Index: Integer;
begin
  inherited Advance;
  if AIEnabled and (Health > 0) then
  begin
    if (ArcadeTickCount and 31) = 0 then RecentHitCount := 0;
    if (PlayerArcadeShip <> Self) or ArcadeAutopilotEnabled then
    begin
      if (WeaponCount > 1) and ((ArcadeTickCount and 31) = 0) and
        (Weapons[PrimaryWeapon].Ammo < Weapons[PrimaryWeapon].MaxAmmo / 4) then
        for Attempt := 0 to WeaponCount - 2 do
        begin
          Index := RandomRange(0, WeaponCount - 1);
          if (Weapons[Index].Ammo > Weapons[Index].MaxAmmo * 0.9) or
            (((Weapons[Index].Kind = 13) or (Weapons[Index].Kind = 14)) and
            (Weapons[Index].Ammo > Weapons[Index].MaxAmmo * 0.7)) then
          begin
            SelectWeapon(Index);
            Break;
          end;
        end;
      if (TargetShip <> nil) and (Enemies.IndexOf(TargetShip) < 0) then TargetShip := nil;
      if (TargetShip <> nil) and (TargetShip.Health <= 0) then TargetShip := nil;
      if (TargetShip <> nil) and (TargetShip.BonusTicks[abkInvisibility] > 0) and (TargetShip.RevealTicks <= 0) then TargetShip := nil;
      if TargetShip = nil then TargetShip := FindNearestEnemy(Self);
      if TargetShip <> nil then
      begin
        TargetBearing := BearingAndDistanceTo(TargetShip);
        ReverseTargetBearing := TargetShip.BearingAndDistanceTo(Self);
      end;
      TargetPathClear := False;
      if TargetShip <> nil then
      begin
        ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees,
          WrapHeadingDegrees(State.BearingDegrees + TargetBearing.BearingDeltaDegrees)), ForwardDistance, BackwardDistance);
        TargetPathClear := TargetBearing.Distance < ForwardDistance;
      end;
      DecideActions;
    end;
  end;
end;
{ @end $67FB04 }

{ @routine $67FE58 TabShipAI_NoticeCollision }
procedure TabShipAI.NoticeCollision;
begin
  if (PlayerArcadeShip = Self) or (CurrentZone = nil) then
  begin
    AvoidanceZone := nil;
    Exit;
  end;
  AvoidanceZone := ab_Zone_RandomRoute(CurrentZone, 2);
end;
{ @end $67FE58 }

{ @routine $67FEA4 TabShipAI_NoticeDamagingZone }
procedure TabShipAI.NoticeDamagingZone(Zone: PabZone);
begin
  if RandomIntRange(0, 10) = 0 then DamagingZone := Zone;
end;
{ @end $67FEA4 }

{ @routine $67FED0 TabShipAI_ResetIntent }
procedure TabShipAI.ResetIntent;
begin
  Intent := 0;
  TargetShip := nil;
  TargetBonus := nil;
  BonusRouteZone := nil;
  AvoidanceZone := nil;
  DamagingZone := nil;
  LastDamageTick := 0;
  RetreatRequested := False;
end;
{ @end $67FED0 }

{ @routine $67FF34 TabShipAI_DecideActions }
procedure TabShipAI.DecideActions;
var
  Index, Score, BestScore: Integer;
  Enemy: TabObject;
  Bonus: TabItem;
  Zone: PabZone;
  Obj: TabObject;
  NearestDistance: Double;
  Info, ZoneInfo: TSphericalBearingDistance;
begin
  DirectPathClear := False;
  IncomingThreat := False;
  if PlayerArcadeShip = Self then
  begin
    NearestDistance := 1E30;
    for Index := 0 to Enemies.Count - 1 do
    begin
      Enemy := TabObject(Enemies[Index]);
      Info := Enemy.BearingAndDistanceTo(Self);
      with Info do
      begin
        NearestDistance := Min(NearestDistance, Distance);
        if (Enemy <> TargetShip) and (Abs(BearingDeltaDegrees) < 5) and (Distance < 400) then IncomingThreat := True;
      end;
    end;
  end;
  ClearRoute;
  if TargetShip <> nil then SetRoute((TargetShip as TabShipAI).CurrentZone);
  FollowDirectDestination;
  if TargetPathClear then
  begin
    if ArcadeTickCount > ManeuverUntilTick then CombatManeuver := amUnselected;
    if (CombatManeuver = amApproach) and (ScoreApproach < 0) then CombatManeuver := amUnselected;
    if (CombatManeuver = amCloseEvasion) and (ScoreCloseEvasion < 0) then CombatManeuver := amUnselected;
    if (CombatManeuver = amFlank) and (ScoreFlanking < 0) then CombatManeuver := amUnselected;
    if (CombatManeuver = amReverseTurn) and (ScoreReverseTurn < 0) then CombatManeuver := amUnselected;
    if (CombatManeuver = amFollowReverse) and (ScoreReverseFollowing < 0) then CombatManeuver := amUnselected;
    if CombatManeuver < 0 then
    begin
      BestScore := 0;
      Score := ScoreApproach;
      if Score > BestScore then
      begin
        BestScore := Score;
        CombatManeuver := amApproach;
        ManeuverUntilTick := ArcadeTickCount + 100;
      end;
      Score := ScoreCloseEvasion;
      if Score > BestScore then
      begin
        BestScore := Score;
        CombatManeuver := amCloseEvasion;
        ManeuverUntilTick := ArcadeTickCount + 100;
      end;
      Score := ScoreFlanking;
      if Score > BestScore then
      begin
        BestScore := Score;
        CombatManeuver := amFlank;
        ManeuverUntilTick := ArcadeTickCount + 100;
      end;
      Score := ScoreReverseTurn;
      if Score > BestScore then
      begin
        BestScore := Score;
        CombatManeuver := amReverseTurn;
        ManeuverUntilTick := ArcadeTickCount + 100;
      end;
      Score := ScoreReverseFollowing;
      if Score > BestScore then
      begin
        CombatManeuver := amFollowReverse;
        ManeuverUntilTick := ArcadeTickCount + 500;
      end;
    end;
    if CombatManeuver = amApproach then ApproachTarget
    else if CombatManeuver = amCloseEvasion then EvadeCloseTarget
    else if CombatManeuver = amFlank then FlankTarget
    else if CombatManeuver = amReverseTurn then ReverseTowardTarget
    else if CombatManeuver = amFollowReverse then MatchReversingTarget;
  end
  else
  begin
    CombatManeuver := amUnselected;
    ManeuverUntilTick := 0;
    FollowRoute;
  end;
  if (AvoidanceZone = nil) and (ArcadeTickCount - LastDamageTick < 100) and
    ((RandomIntRange(0, 120) = 0) or
     ((BonusTicks[abkWeaponLock] > 0) and (RandomIntRange(0, 20) = 0)) or
     ((TargetShip = nil) and (RandomIntRange(0, 20) = 0)) or
     ((PlayerArcadeShip = Self) and (Health < MaxHealth * 0.3) and (RandomIntRange(0, 20) = 0))) then
    AvoidanceZone := ab_Zone_RandomRoute(CurrentZone, 2);
  if (AvoidanceZone <> nil) and
    ((AvoidanceZone = CurrentZone) or IncomingThreat or (RandomIntRange(0, 100) = 0) or (RecentHitCount >= 3) or
     not TryMoveToDestination(AvoidanceZone, AvoidanceZone.Longitude, AvoidanceZone.PolarAngle)) then AvoidanceZone := nil;
  if RetreatRequested and (RandomIntRange(0, 50) = 0) then
  begin
    repeat
      Zone := ab_Zone_RandomRoute(CurrentZone, RandomIntRange(3, 4));
    until Zone <> AvoidanceZone;
    AvoidanceZone := Zone;
  end;
  if (TargetBonus = nil) and not RetreatRequested and
    (((TargetShip = nil) and (RandomIntRange(0, 20) = 0)) or
     ((BonusTicks[abkWeaponLock] > 0) and (RandomIntRange(0, 20) = 0)) or
     ((PlayerArcadeShip <> Self) and (RandomIntRange(0, 500) = 0)) or
     ((Health < MaxHealth * 0.4) and (RandomIntRange(0, 80) = 0))) then
  begin
    if PlayerArcadeShip = Self then
    begin
      TargetBonus := ab_Item_FindRepairRoute(CurrentZone, BonusRouteZone);
      if TargetBonus = nil then TargetBonus := ab_Item_FindBonusRoute(CurrentZone, BonusRouteZone);
    end
    else
    begin
      TargetBonus := ab_Item_FindBonusRoute(CurrentZone, BonusRouteZone);
      if TargetBonus <> nil then
      begin
        Obj := FirstArcadeObject;
        while Obj <> nil do
        begin
          if (Obj <> Self) and (Obj is TabShipAI) and (TabShipAI(Obj).TargetBonus = TargetBonus) then
          begin
            TargetBonus := nil;
            Break;
          end;
          Obj := Obj.Next;
        end;
      end;
    end;
  end;
  if (TargetBonus <> nil) and
    ((RecentHitCount >= 3) or (IncomingThreat and (RandomIntRange(0, 50) = 0)) or
     not TryMoveToDestination(BonusRouteZone, TargetBonus.State.LongitudeDegrees, TargetBonus.State.PolarAngleDegrees)) then TargetBonus := nil;
  if RouteZone <> nil then
  begin
    Bonus := ab_Item_FindNearestBonus(RouteZone);
    if Bonus <> nil then
      with BearingAndDistanceTo(Bonus) do
        if Abs(BearingDeltaDegrees) < 75 then
        begin
          SetDirectDestination(Bonus.State.LongitudeDegrees, Bonus.State.PolarAngleDegrees);
          FollowDirectDestination;
        end;
  end;
  if (Enemies.Count <= 1) and (KellerArcadeShip <> nil) and (KellerArcadeShip.Health = 0) then
  begin
    SetDirectDestination(KellerArcadeShip.State.LongitudeDegrees, KellerArcadeShip.State.PolarAngleDegrees);
    FollowDirectDestination;
  end;
  if DamagingZone <> nil then
  begin
    ComputeSphericalBearingAndDistance(ZoneInfo.BearingDeltaDegrees, ZoneInfo.Distance, State.LongitudeDegrees, State.PolarAngleDegrees,
      State.BearingDegrees, DamagingZone.Longitude, DamagingZone.PolarAngle, SphereRadius);
    if Abs(ZoneInfo.BearingDeltaDegrees) < 90 then StopThrust else StartThrust;
    if ZoneInfo.Distance > (DamagingZone.Radius + ZoneRadius) * 1.4 then DamagingZone := nil
    else SetTurnInput(-ZoneInfo.BearingDeltaDegrees);
  end;
  AvoidImmediateObstacle;
  for Index := 0 to Enemies.Count - 1 do
  begin
    Enemy := TabObject(Enemies[Index]);
    Info := BearingAndDistanceTo(Enemy);
    with Info do
    begin
      if PrimaryWeapon >= 0 then
      begin
        if Weapons[PrimaryWeapon].Kind = 13 then FirePrimary
        else if Weapons[PrimaryWeapon].Kind = 14 then FirePrimaryAt(Enemy)
        else if Weapons[PrimaryWeapon].Kind = 12 then FirePrimaryAt(Enemy)
        else if Weapons[PrimaryWeapon].Kind = 17 then FirePrimary
        else if Abs(BearingDeltaDegrees) < 5 then
          if not (Weapons[PrimaryWeapon].Kind in [1, 2, 6, 8]) or (Thrust <= 1.25) or (Abs(TurnInput) >= 0.01) then FirePrimaryAt(Enemy);
      end;
      if SecondaryWeapon >= 0 then
      begin
        if Weapons[SecondaryWeapon].Kind = 13 then FireSecondary
        else if Weapons[SecondaryWeapon].Kind = 14 then FireSecondaryAt(Enemy)
        else if Weapons[SecondaryWeapon].Kind = 12 then FireSecondaryAt(Enemy)
        else if Abs(BearingDeltaDegrees) < 5 then
          if not (Weapons[SecondaryWeapon].Kind in [1, 2, 6, 8]) or (Thrust <= 1.25) or (Abs(TurnInput) >= 0.01) then FireSecondaryAt(Enemy);
      end;
    end;
  end;
end;
{ @end $67FF34 }

{ @routine $680AF8 TabShipAI_SetDirectDestination }
procedure TabShipAI.SetDirectDestination(Longitude, PolarAngle: Single);
var
  ForwardDistance, BackwardDistance: Double;
begin
  DirectTargetLongitude := Longitude;
  DirectTargetPolarAngle := PolarAngle;
  DirectPathClear := False;
  ComputeSphericalBearingAndDistance(DirectBearing.BearingDeltaDegrees, DirectBearing.Distance,
    State.LongitudeDegrees, State.PolarAngleDegrees, State.BearingDegrees,
    DirectTargetLongitude, DirectTargetPolarAngle, SphereRadius);
  ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees,
    WrapHeadingDegrees(State.BearingDegrees + DirectBearing.BearingDeltaDegrees)), ForwardDistance, BackwardDistance);
  DirectPathClear := DirectBearing.Distance < ForwardDistance;
end;
{ @end $680AF8 }

{ @routine $680BEC TabShipAI_FollowDirectDestination }
procedure TabShipAI.FollowDirectDestination;
begin
  if DirectPathClear then
  begin
    SetTurnInput(DirectBearing.BearingDeltaDegrees);
    if Abs(DirectBearing.BearingDeltaDegrees) < 45 then
      Thrust := RemapClamped(Abs(DirectBearing.BearingDeltaDegrees), 0, 45, 2.5, 0)
    else StopThrust;
  end;
end;
{ @end $680BEC }

{ @routine $680C74 TabShipAI_AvoidImmediateObstacle }
procedure TabShipAI.AvoidImmediateObstacle;
begin
  if (Thrust > 0) and ((ObstacleLevels[0] >= 3) or (ObstacleLevels[1] >= 3) or (ObstacleLevels[7] >= 3)) then
  begin
    if ObstacleLevels[1] < ObstacleLevels[7] then SetTurnInput(100)
    else if ObstacleLevels[7] < ObstacleLevels[1] then SetTurnInput(-100);
  end;
end;
{ @end $680C74 }

{ @routine $680D00 TabShipAI_ClearRoute }
procedure TabShipAI.ClearRoute;
begin
  RouteZone := nil;
  HeadingInsideRoute := False;
end;
{ @end $680D00 }

{ @routine $680D20 TabShipAI_SetRoute }
procedure TabShipAI.SetRoute(Target: PabZone);
begin
  RouteZone := ab_Zone_GetRoute(CurrentZone, Target);
  HeadingInsideRoute := False;
  if RouteZone <> nil then
    HeadingInsideRoute := ab_Zone_IsHeadingInside(State, RouteZone, RouteBearing, RouteAngularRadius);
end;
{ @end $680D20 }

{ @routine $680D90 TabShipAI_FollowRoute }
procedure TabShipAI.FollowRoute;
begin
  if RouteZone <> nil then
  begin
    if HeadingInsideRoute and (RouteZone <> nil) then
    begin
      StartThrust;
      if Abs(RouteBearing) < RouteAngularRadius / 2 then SetTurnInput(0)
      else if RouteBearing < 0 then SetTurnInput(-100)
      else if RouteBearing > 0 then SetTurnInput(100);
      Exit;
    end;
    if (RouteZone <> nil) and not ab_StopLine_IsBlocked(State.LongitudeDegrees,
      State.PolarAngleDegrees, RouteZone.Longitude, RouteZone.PolarAngle) then
    begin
      if RouteBearing < 45 then StartThrust else StopThrust;
      if Abs(RouteBearing) < RouteAngularRadius / 2 then SetTurnInput(0)
      else if RouteBearing < 0 then SetTurnInput(-100)
      else if RouteBearing > 0 then SetTurnInput(100);
      Exit;
    end;
    if not InsideCurrentZone then
    begin
      if HeadingInsideCurrentZone then
      begin
        StartThrust;
        if Abs(CurrentZoneBearing) < CurrentZoneAngularRadius / 2 then SetTurnInput(0)
        else if CurrentZoneBearing < 0 then SetTurnInput(-100)
        else if CurrentZoneBearing > 0 then SetTurnInput(100);
        Exit;
      end;
      if CurrentZoneBearing < 0 then SetTurnInput(-100)
      else if CurrentZoneBearing > 0 then SetTurnInput(100);
      Exit;
    end;
    if RouteZone <> nil then
    begin
      if RouteBearing < 0 then SetTurnInput(-100)
      else if RouteBearing > 0 then SetTurnInput(100);
    end;
  end;
end;
{ @end $680D90 }

{ @routine $6810B4 TabShipAI_ApproachTarget }
procedure TabShipAI.ApproachTarget;
begin
  CombatManeuver := amApproach;
  SetTurnInput(TargetBearing.BearingDeltaDegrees);
  if MinimumWeaponRange * 0.8 < TargetBearing.Distance then
  begin
    Thrust := RemapClamped(Abs(TargetBearing.BearingDeltaDegrees), 0, 180, 2.5, 0);
    Thrust := RemapClamped(TargetBearing.Distance, 100, 1000, 0.5, 1) * Thrust;
    Exit;
  end;
  StartReverseThrust;
end;
{ @end $6810B4 }

{ @routine $681188 TabShipAI_ScoreApproach }
function TabShipAI.ScoreApproach: Integer;
begin
  Result := 1;
  Inc(Result, RandomRange(-1, 1));
end;
{ @end $681188 }

{ @routine $6811B4 TabShipAI_EvadeCloseTarget }
procedure TabShipAI.EvadeCloseTarget;
begin
  CombatManeuver := amCloseEvasion;
  if Abs(ReverseTargetBearing.BearingDeltaDegrees) < 20 then SetTurnInput(-TargetBearing.BearingDeltaDegrees)
  else SetTurnInput(TargetBearing.BearingDeltaDegrees);
  StartReverseThrust;
end;
{ @end $6811B4 }

{ @routine $681224 TabShipAI_ScoreCloseEvasion }
function TabShipAI.ScoreCloseEvasion: Integer;
begin
  Result := 0;
  if (TargetBearing.Distance < 200) and (Abs(TargetBearing.BearingDeltaDegrees) < 40) then
  begin
    Inc(Result);
    Inc(Result);
  end
  else if Abs(TargetBearing.BearingDeltaDegrees) > 90 then Result := -1;
end;
{ @end $681224 }

{ @routine $681298 TabShipAI_FlankTarget }
procedure TabShipAI.FlankTarget;
begin
  CombatManeuver := amFlank;
  if TargetBearing.BearingDeltaDegrees > 0 then SetTurnInput(TargetBearing.BearingDeltaDegrees - 65)
  else SetTurnInput(TargetBearing.BearingDeltaDegrees + 65);
  StartThrust;
  Thrust := RemapClamped(TargetBearing.Distance, 100, 1000, 0.5, 1) * Thrust;
end;
{ @end $681298 }

{ @routine $681350 TabShipAI_ScoreFlanking }
function TabShipAI.ScoreFlanking: Integer;
begin
  Result := RandomRange(0, 2);
  if (Abs(ReverseTargetBearing.BearingDeltaDegrees) < 30) and (TargetBearing.Distance < 500) then
  begin
    Inc(Result);
    if Abs(TargetBearing.BearingDeltaDegrees) > Abs(ReverseTargetBearing.BearingDeltaDegrees) then Inc(Result);
    if (PlayerArcadeShip = Self) and (Health < Round(MaxHealth * 0.4)) then Inc(Result);
    if IncomingThreat then Inc(Result);
    Inc(Result, RandomRange(-1, 1));
  end;
  if TargetBearing.Distance > 500 then Dec(Result);
  if Health > MaxHealth * 0.7 then Dec(Result, 2);
end;
{ @end $681350 }

{ @routine $681498 TabShipAI_ReverseTowardTarget }
procedure TabShipAI.ReverseTowardTarget;
begin
  CombatManeuver := amReverseTurn;
  SetTurnInput(TargetBearing.BearingDeltaDegrees);
  StartReverseThrust;
end;
{ @end $681498 }

{ @routine $6814D0 TabShipAI_ScoreReverseTurn }
function TabShipAI.ScoreReverseTurn: Integer;
begin
  Result := 0;
  if (Abs(TargetBearing.BearingDeltaDegrees) > 120) and
    ((ObstacleLevels[3] = 0) or (ObstacleLevels[4] = 0) or (ObstacleLevels[5] = 0)) then
  begin
    Inc(Result, 3);
    if (PlayerArcadeShip = Self) and (Health < Round(MaxHealth * 0.4)) then Inc(Result);
    Inc(Result, RandomRange(-2, 2));
  end
  else Result := -1;
end;
{ @end $6814D0 }

{ @routine $68159C TabShipAI_MatchReversingTarget }
procedure TabShipAI.MatchReversingTarget;
begin
  StartReverseThrust;
end;
{ @end $68159C }

{ @routine $6815B0 TabShipAI_ScoreReverseFollowing }
function TabShipAI.ScoreReverseFollowing: Integer;
begin
  Result := 0;
  if (Abs(TargetBearing.BearingDeltaDegrees) < 20) and (Abs(ReverseTargetBearing.BearingDeltaDegrees) < 30)
    and (ObstacleLevels[4] <= 1) and (TargetShip.Thrust < 0) then
  begin
    Inc(Result, 2);
    if MaximumWeaponRange * 0.7 < TargetBearing.Distance then Inc(Result, 2);
    Inc(Result, RandomRange(-1, 1));
  end
  else Result := -1;
end;
{ @end $6815B0 }

{ @routine $681674 TabShipAI_TryMoveToDestination }
function TabShipAI.TryMoveToDestination(Zone: PabZone; Longitude, PolarAngle: Double): Boolean;
var
  ForwardDistance, BackwardDistance, Distance, Bearing: Double;
begin
  SetAndFollowRoute(Zone);
  ComputeSphericalBearingAndDistance(Bearing, Distance, State.LongitudeDegrees,
    State.PolarAngleDegrees, State.BearingDegrees, Longitude, PolarAngle, SphereRadius);
  ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees,
    WrapHeadingDegrees(State.BearingDegrees + Bearing)), ForwardDistance, BackwardDistance);
  if Distance >= ForwardDistance then Result := RouteZone <> nil
  else
  begin
    SetTurnInput(Bearing);
    if Abs(Bearing) < 45 then Thrust := RemapClamped(Abs(Bearing), 0, 45, 2.5, 0)
    else StopThrust;
    Result := True;
  end;
end;
{ @end $681674 }

{ @routine $681790 TabShipAI_SetAndFollowRoute }
procedure TabShipAI.SetAndFollowRoute(Target: PabZone);
begin
  if Target = nil then RouteZone := nil
  else RouteZone := ab_Zone_GetRoute(CurrentZone, Target);
  HeadingInsideRoute := False;
  if RouteZone <> nil then
    HeadingInsideRoute := ab_Zone_IsHeadingInside(State, RouteZone, RouteBearing, RouteAngularRadius);
  FollowDestinationRoute;
end;
{ @end $681790 }

{ @routine $68181C TabShipAI_FollowDestinationRoute }
procedure TabShipAI.FollowDestinationRoute;
begin
  if RouteZone <> nil then
  begin
    if HeadingInsideRoute and (RouteZone <> nil) then
    begin
      StartThrust;
      if Abs(RouteBearing) < RouteAngularRadius / 2 then SetTurnInput(0)
      else if RouteBearing < 0 then SetTurnInput(-100)
      else if RouteBearing > 0 then SetTurnInput(100);
      Exit;
    end;
    if (RouteZone <> nil) and not ab_StopLine_IsBlocked(State.LongitudeDegrees,
      State.PolarAngleDegrees, RouteZone.Longitude, RouteZone.PolarAngle) then
    begin
      if RouteBearing < 45 then StartThrust else StopThrust;
      if Abs(RouteBearing) < RouteAngularRadius / 2 then SetTurnInput(0)
      else if RouteBearing < 0 then SetTurnInput(-100)
      else if RouteBearing > 0 then SetTurnInput(100);
      Exit;
    end;
    if not InsideCurrentZone then
    begin
      if HeadingInsideCurrentZone then
      begin
        StartThrust;
        if Abs(CurrentZoneBearing) < CurrentZoneAngularRadius / 2 then SetTurnInput(0)
        else if CurrentZoneBearing < 0 then SetTurnInput(-100)
        else if CurrentZoneBearing > 0 then SetTurnInput(100);
        Exit;
      end;
      if CurrentZoneBearing < 0 then SetTurnInput(-100)
      else if CurrentZoneBearing > 0 then SetTurnInput(100);
      Exit;
    end;
    if RouteZone <> nil then
    begin
      if RouteBearing < 0 then SetTurnInput(-100)
      else if RouteBearing > 0 then SetTurnInput(100);
    end;
  end;
end;
{ @end $68181C }

end.
