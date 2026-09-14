unit ab_Space;
// Unit bracket (inferred): .text 0x0067A488..0x0067E7DB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabSpace VMT at $67A4D4; field recovery is incomplete.

interface

uses Classes, EC_Struct, GI_GAI, Types;

type
  TabSpace = class(TObjectEx) // @size $6C
  public
    Prev: TabSpace; // @offset $04
    Next: TabSpace; // @offset $08
    GridPosition: TPoint; // @offset $0C
    MapPosition: TPoint; // @offset $14
    IncomingCount: Integer; // @offset $20
    OutgoingCount: Integer; // @offset $24
    Color28: Cardinal; // @offset $28 Map rendering color; precise role pending.
    Color2C: Cardinal; // @offset $2C
    Color30: Cardinal; // @offset $30
    Color34: Cardinal; // @offset $34
    MapPath: WideString; // @offset $3C Arena resource path.
    BoundaryKind: Integer; // @offset $40 1 for the synthetic start/end nodes.
    PortalSlotCount: Integer; // @offset $44 Used by exit-index shuffling; initializer still under review.
    AppearanceIndex: Integer; // @offset $38 Six difficulty/visual variants, each with six palette entries.
    Danger: Double; // @offset $48 Local encounter difficulty, used for danger text, visuals and rewards.
    ApproachDanger: Double; // @offset $50 Minimum accumulated predecessor danger, followed by graph pruning.
    RouteCost: Double; // @offset $58 Temporary reverse-search cost for the selected route.
    Objects: TList; // @offset $60 Owned objects associated with this space.
    ImageActive: Boolean; // @offset $64
    Image: TgaiGI; // @offset $68
    constructor Create; // @addr $67A4F0 @ida "TabSpace *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $67A57C @ida "void __usercall $name(TabSpace *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure UpdateVisuals; // @addr $67A5E4 Empty native update hook.
    procedure Update; // @addr $67A8F8
    procedure ClearVisuals; // @addr $67A5D0
    procedure ClearImage; // @addr $67A8C8
    procedure ClearObjects; // @addr $67A90C
    procedure UpdateApproachDanger; // @addr $67D5B8
    procedure PruneApproachDanger; // @addr $67D5FC Native instance receiver is unused; visits the complete graph.
    function GetDangerText: WideString; // @addr $67D6F4 @ida "void __usercall $name(TabSpace *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure CreateImage; // @addr $67A5F0
    procedure PopulateObjects; // @addr $67A958
    procedure PopulateHoleEncounter; // @addr $67B6B8
    procedure PopulateScriptedEncounter; // @addr $67CB90
    procedure PopulateKellerEncounter; // @addr $67CD38
    procedure RecountLinks; // @addr $67DAE0
  end;

  PabSpaceLink = ^TabSpaceLink;
  TabSpaceLink = record // @size $6C Allocation size verified at $67DBAC; remaining fields unresolved.
    Prev: PabSpaceLink; // @offset $00
    Next: PabSpaceLink; // @offset $04
    First: TabSpace; // @offset $08
    Last: TabSpace; // @offset $0C
    ExitIndex: Integer; // @offset $10
    Points: array[0..10] of TPoint; // @offset $14 Arrow outline and halo geometry.
  end;

procedure ab_Space_UpdateApproachDanger; // @addr $67DB40
procedure ab_Space_CreateImages; // @addr $67D9D0
procedure ab_Space_ClearImages; // @addr $67D9FC
procedure ab_SpaceLink_Invalidate; // @addr $67DD60
procedure ab_SpaceLink_BuildGeometry; // @addr $67DEC0
procedure ab_SpaceLink_Draw; // @addr $67E350
procedure ab_SpaceLink_ClearImages; // @addr $67E32C
procedure ab_Space_Clear; // @addr $67D884
function ab_Space_Add: TabSpace; // @addr $67D8BC
procedure ab_Space_Delete(Space: TabSpace); // @addr $67D920
function ab_Space_Find(GridPosition: TPoint): TabSpace; // @addr $67DA5C @ida "TabSpace *__usercall $name@<eax>(TPoint *GridPosition@<eax>);"
procedure ab_Space_RecountLinks; // @addr $67DAB4
procedure ab_SpaceLink_Clear; // @addr $67DB94
function ab_SpaceLink_Add: PabSpaceLink; // @addr $67DBAC
procedure ab_SpaceLink_Delete(Link: PabSpaceLink); // @addr $67DC0C
procedure ab_SpaceLink_Connect(First, Last: TabSpace); // @addr $67DC74
function ab_SpaceLink_Find(First, Last: TabSpace): PabSpaceLink; // @addr $67DCA0
function ab_SpaceLink_FindExit(First: TabSpace; ExitIndex: Integer): PabSpaceLink; // @addr $67DD0C

var
  FirstArcadeSpace: TabSpace = nil; // @addr $87B7D4
  LastArcadeSpace: TabSpace = nil; // @addr $87B7D8
  CurrentArcadeSpace: TabSpace = nil; // @addr $87B7DC
  NextArcadeSpace: TabSpace = nil; // @addr $87B7E0 Destination selected before entering a space.
  StartArcadeSpace: TabSpace = nil; // @addr $87B7E4
  EndArcadeSpace: TabSpace = nil; // @addr $87B7E8
  HoveredArcadeSpace: TabSpace = nil; // @addr $87B7EC
  FirstArcadeSpaceLink: PabSpaceLink = nil; // @addr $87B7F0
  LastArcadeSpaceLink: PabSpaceLink = nil; // @addr $87B7F4

procedure ab_Space_Update; // @addr $67DA30

var
  ArcadeKellerEncounter: Boolean; // @addr $889C78

implementation

uses aKling, SysUtils, Math, EC_Mem, GR_Main, GR_DX, Globals, GlobalsV, GI_Tail, ab_Global, aConst, aMyFunction, aPlayer, aGalaxy, aItem, aGalaxyStruct, ab_ShipAI, ab_Item, ab_Ship, ab_W, ab_MainForm, ab_Hit;

{ @routine $67A4F0 TabSpace_Create }
constructor TabSpace.Create;
begin
  inherited Create;
  Color28 := CurrentPixelFormat.PackRgbBytes(255, 255, 0);
  Color2C := CurrentPixelFormat.PackRgbBytes(155, 155, 0);
  Objects := TList.Create;
  ImageActive := False;
end;
{ @end $67A4F0 }

{ @routine $67A57C TabSpace_Destroy }
destructor TabSpace.Destroy;
begin
  ClearVisuals;
  ClearObjects;
  Objects.Free;
  Objects := nil;
  inherited Destroy;
end;
{ @end $67A57C }

{ @routine $67A5D0 TabSpace_ClearVisuals }
procedure TabSpace.ClearVisuals;
begin
  ClearImage;
end;
{ @end $67A5D0 }

{ @routine $67A5E4 TabSpace_UpdateVisuals }
procedure TabSpace.UpdateVisuals;
begin
end;
{ @end $67A5E4 }

{ @routine $67A5F0 TabSpace_CreateImage }
procedure TabSpace.CreateImage;
begin
  ImageActive := True;
  if (Image = nil) and (Self <> StartArcadeSpace) and (Self <> EndArcadeSpace) then
  begin
    Image := TgaiGI.Create(ArcadeBattleScreen.WorldPanel);
    Image.SetDepth(30);
    if Danger <= 0 then
      Image.SetImagePath('Bm.ABClot.' + GiResourceSuffix + '0_' + IntToStr(RandomIntRange(0, 1)))
    else if Danger + ApproachDanger < ArcadeHighDangerThreshold then
      Image.SetImagePath('Bm.ABClot.' + GiResourceSuffix + '1_' + IntToStr(RandomIntRange(0, 3)))
    else
      Image.SetImagePath('Bm.ABClot.' + GiResourceSuffix + '2_' + IntToStr(RandomIntRange(0, 1)));
    Image.SetSize(Image.GetContentSize);
    Image.SetOrigin(HalfPoint(Image.ClientSize));
    Image.SequenceIndex := 0;
    Image.UpdateAutoGeometry;
    Image.SetSequenceFrame(RandomIntRange(0, Image.SequenceFrameCount - 1));
    Image.SetActive(True);
    Image.RestartPlayback;
  end;
end;
{ @end $67A5F0 }

{ @routine $67A8C8 TabSpace_ClearImage }
procedure TabSpace.ClearImage;
begin
  if Image <> nil then
  begin
    Image.Free;
    Image := nil;
  end;
  ImageActive := False;
end;
{ @end $67A8C8 }

{ @routine $67A8F8 TabSpace_Update }
procedure TabSpace.Update;
begin
  UpdateVisuals;
end;
{ @end $67A8F8 }

{ @routine $67A90C TabSpace_ClearObjects }
procedure TabSpace.ClearObjects;
var
  Index: Integer;
begin
  for Index := 0 to Objects.Count - 1 do TObject(Objects[Index]).Free;
  Objects.Clear;
end;
{ @end $67A90C }

{ @routine $67A958 TabSpace_PopulateObjects }
procedure TabSpace.PopulateObjects;
var
  Ship: TabShipAI;
  Index, Count, MineralBudget, Minimum, Maximum, Kind, VisualIndex, Hitpoints, WeaponIndex: Integer;
  Item: TItem;
  ArcadeItem: TabItem;
  Scale: Single;
begin
  ClearObjects;
  if GetPlayer = nil then Exit;
  case Integer(Round(Danger)) of
    0: if ArcadeBattleScreen.RandomRange(0, 100) > 90 then Count := ArcadeBattleScreen.RandomRange(1, 2) else Count := 0;
    1..20: if ArcadeBattleScreen.RandomRange(0, 100) > 80 then Count := ArcadeBattleScreen.RandomRange(2, 3) else Count := 0;
    21..30: if ArcadeBattleScreen.RandomRange(0, 100) > 50 then Count := ArcadeBattleScreen.RandomRange(2, 3) else Count := 0;
    31..60: if ArcadeBattleScreen.RandomRange(0, 100) > 10 then Count := ArcadeBattleScreen.RandomRange(2, 4) else Count := 0;
    61..90: if ArcadeBattleScreen.RandomRange(0, 100) > 5 then Count := ArcadeBattleScreen.RandomRange(2, 5) else Count := 0;
    91..100: Count := ArcadeBattleScreen.RandomRange(4, 5);
  else Count := ArcadeBattleScreen.RandomRange(4, 5);
  end;
  if Count > 0 then
    if ArcadeBattleScreen.RandomRange(0, 100) < RemapClamped(GetPlayer.HyperspaceKillCount, 20, 300, 0, 90) then Count := 0;
  if GetPlayer.HyperspaceKillCount < 4 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor then Count := Min(Count, 2)
  else if GetPlayer.HyperspaceKillCount < 10 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor then Count := Min(Count, 3);
  if GetPlayer.HyperspaceKillCount = 0 then Count := 1;
  Minimum := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 6));
  Maximum := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 5, 11));
  VisualIndex := ArcadeBattleScreen.RandomRange(1, 5);
  for Index := 0 to Count - 1 do
  begin
    Ship := TabShipAI.Create;
    case GetPlayer.HyperspaceKillCount of
      0: Scale := 0.2;
      1..4: Scale := RemapClamped(GetPlayer.HyperspaceKillCount, 1, 4, 0.3, 0.5);
      5..12: Scale := RemapClamped(GetPlayer.HyperspaceKillCount, 5, 12, 0.5, 0.8);
      13..30: Scale := RemapClamped(GetPlayer.HyperspaceKillCount, 13, 30, 0.8, 1);
      31..80: Scale := RemapClamped(GetPlayer.HyperspaceKillCount, 31, 80, 1, 1.3);
    else Scale := RemapClamped(GetPlayer.HyperspaceKillCount, 81, 100, 1.3, 1.6);
    end;
    Scale := RemapClamped(Danger, 0, 100, 0.8, 1.2) * Scale;
    Scale := RemapClamped(GetPlayer.Wealth, Galaxy.AverageRangerCapital / 2, Galaxy.MaxRangerWealth, 0.8, 1.1) * Scale;
    Scale := RemapClamped(GetPlayer.StrengthInBestRanger, 0.2, 1, 0.5, 1.2) * Scale;
    Scale := Scale * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    if Index = 0 then Scale := ArcadeBattleScreen.RandomFloat(1, 1.3) * Scale
    else if Index = 1 then Scale := ArcadeBattleScreen.RandomFloat(0.7, 1.1) * Scale
    else Scale := ArcadeBattleScreen.RandomFloat(0.2, 0.6) * Scale;
    Hitpoints := Round(Max(150, Min(GetPlayer.GetHull.Weight * 1.2, 525 * Scale)));
    Ship.CreateShipVisual('Ship.HS.' + IntToStr(IncrementWrapped(VisualIndex, 1, 5)), Round(RemapClamped(Hitpoints, 150, 900, 50, 80)));
    Hitpoints := Round(Galaxy.GetArcadeHitpointsModifier * Hitpoints);
    Ship.MaxHealth := Hitpoints;
    Ship.Health := Hitpoints;
    Ship.MaxSpeed := RemapClamped(Ship.VisualDiameter, 50, 80, 7, 5);
    Ship.MaxSpeed := Ship.MaxSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Ship.TurnSpeed := RemapClamped(Ship.VisualDiameter, 50, 80, 3, 2);
    Ship.TurnSpeed := Ship.TurnSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Ship.Thrust := 0;
    Ship.WeaponCount := 0;
    Kind := ArcadeBattleScreen.RandomRange(Minimum, Maximum);
    Ship.AddWeapon(Kind);
    if Index = 0 then
    begin
      Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
      if (GetPlayer.StrengthInBestRanger > 0.9) or (GetPlayer.WealthInBestRanger > 0.9) then Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
    end;
    if (GetPlayer.StrengthInBestRanger > 0.7) or (GetPlayer.WealthInBestRanger > 0.7) then Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
    if ArcadeBattleScreen.RandomRange(0, Round(Danger)) < Danger then Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
    for WeaponIndex := 0 to Ship.WeaponCount - 1 do Ship.Weapons[WeaponIndex].Damage := Round(Galaxy.GetArcadeDamageModifier * Ship.Weapons[WeaponIndex].Damage);
    Ship.PrimaryWeapon := 0;
    Ship.EncounterTag := 1;
    Objects.Add(Ship);
  end;
  Kind := 0;
  MineralBudget := Min(CargoHookLevelStats[8].PickupPower, GetPlayer.Wealth div 40 div GoodsMarket[4].AveragePrice);
  MineralBudget := Round(RemapClamped(Danger + ApproachDanger, 0, 250, 0.2, 1.2) * MineralBudget);
  MineralBudget := Round(RemapClamped(Count, 0, 4, 0.8, 1.2) * MineralBudget);
  for Index := 1 to 8 do
  begin
    Item := TGoods.Create;
    with Item as TGoods do
    begin
      Count := Min(Round(ArcadeBattleScreen.RandomFloat(0.6, 1.3) * CargoHookLevelStats[Galaxy.TechLevel].PickupPower), ArcadeBattleScreen.RandomRange(MineralBudget div 8, MineralBudget div 2)) + 1;
      Inc(Kind, Count);
      Init(t_Minerals, Count);
      NaturalFlag := True;
    end;
    ArcadeItem := TabItem.Create;
    ArcadeItem.SetItem(Item);
    Objects.Add(ArcadeItem);
    if Kind > MineralBudget then Break;
  end;
end;
{ @end $67A958 }

{ @routine $67B6B8 TabSpace_PopulateHoleEncounter }
procedure TabSpace.PopulateHoleEncounter;
var
  Item: TItem;
  ArcadeItem: TabItem;
  Index, WeaponIndex, Count, MineralBudget, Minimum, Maximum, Kind, VisualIndex, Hitpoints: Integer;
  Ship: TabShipAI;
  Scale: Single;
begin
  if GetPlayer = nil then Exit;
  Count := ArcadeBattleScreen.RandomRange(2, 4);
  Count := Min(6, Count + Round(RemapClamped(Galaxy.TechLevel, 4, 8, 0, 2)));
  if GetPlayer.BlackHoleKillCount = 0 then Count := 1
  else if GetPlayer.BlackHoleKillCount < 5 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor then Count := Min(Count, 2);
  Minimum := Round(RemapClamped(Galaxy.RefreshTechLevel, 3, 8, 0, 6));
  Maximum := Round(RemapClamped(Galaxy.RefreshTechLevel, 3, 8, 6, 15));
  VisualIndex := ArcadeBattleScreen.RandomRange(0, 2);
  for Index := 0 to Count - 1 do
  begin
    Ship := TabShipAI.Create;
    case GetPlayer.BlackHoleKillCount of
      0: Scale := 0.1;
      1..5: Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 1, 5, 0.5, 0.6);
      6..12: Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 6, 12, 0.6, 0.8);
      13..23: Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 13, 23, 0.8, 1);
      24..40: Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 24, 40, 1, 1.3);
    else Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 41, 100, 1.3, 1.6);
    end;
    Scale := Scale * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Scale := RemapClamped(GetPlayer.Wealth, Galaxy.AverageRangerCapital / 2, Galaxy.MaxRangerWealth, 0.8, 1.1) * Scale;
    Scale := RemapClamped(GetPlayer.StrengthInBestRanger, 0.2, 1, 0.5, 1.1) * Scale;
    if Index = 0 then Scale := ArcadeBattleScreen.RandomFloat(1, 1.5) * Scale
    else if Index = 1 then Scale := ArcadeBattleScreen.RandomFloat(0.7, 1.1) * Scale
    else Scale := ArcadeBattleScreen.RandomFloat(0.2, 0.6) * Scale;
    if GetPlayer.BlackHoleKillCount = 0 then Hitpoints := 150
    else Hitpoints := Round(Max(150, Min(GetPlayer.GetHull.Weight * 1.2, 525 * Scale)));
    Ship.CreateShipVisual('Ship.X.' + IntToStr(IncrementWrapped(VisualIndex, 0, 2)), Round(RemapClamped(Hitpoints, 150, 900, 50, 80)));
    if Galaxy <> nil then Hitpoints := Round(Galaxy.GetArcadeHitpointsModifier * Hitpoints);
    Ship.MaxHealth := Hitpoints;
    Ship.Health := Hitpoints;
    Ship.MaxSpeed := RemapClamped(Ship.VisualDiameter, 50, 80, 7, 5);
    Ship.MaxSpeed := RemapClamped(GetPlayer.BlackHoleKillCount, 0, 30, 0.6, 1) * Ship.MaxSpeed;
    Ship.MaxSpeed := Ship.MaxSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Ship.TurnSpeed := RemapClamped(Ship.VisualDiameter, 50, 80, 4, 3);
    Ship.TurnSpeed := RemapClamped(GetPlayer.BlackHoleKillCount, 0, 30, 0.6, 1) * Ship.TurnSpeed;
    Ship.TurnSpeed := Ship.TurnSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Ship.Thrust := 0;
    Ship.WeaponCount := 0;
    Kind := ArcadeBattleScreen.RandomRange(Minimum, Maximum);
    Ship.AddWeapon(Kind);
    Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
    if Index = 0 then
    begin
      Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
      if ((GetPlayer.BlackHoleKillCount > 0) and (GetPlayer.StrengthInBestRanger > 0.9)) or (GetPlayer.WealthInBestRanger > 0.9) then
        Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
    end;
    if GetPlayer.BlackHoleKillCount > 0 then
    begin
      if (GetPlayer.StrengthInBestRanger > 0.7) or (GetPlayer.WealthInBestRanger > 0.7) then Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
      if ArcadeBattleScreen.RandomRange(0, Round(Danger)) < Danger then Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
    end;
    if Galaxy <> nil then
      for WeaponIndex := 0 to Ship.WeaponCount - 1 do Ship.Weapons[WeaponIndex].Damage := Round(Galaxy.GetArcadeDamageModifier * Ship.Weapons[WeaponIndex].Damage);
    Ship.PrimaryWeapon := 0;
    Ship.EncounterTag := 1;
    Objects.Add(Ship);
  end;
  Kind := 0;
  MineralBudget := Min(CargoHookLevelStats[8].PickupPower, GetPlayer.Wealth div 40 div GoodsMarket[4].AveragePrice);
  MineralBudget := Round(RemapClamped(Count, 2, 4, 0.8, 1.2) * MineralBudget);
  for Index := 1 to 8 do
  begin
    Item := TGoods.Create;
    with Item as TGoods do
    begin
      Count := Min(Round(ArcadeBattleScreen.RandomFloat(0.6, 1.3) * CargoHookLevelStats[Galaxy.TechLevel].PickupPower), ArcadeBattleScreen.RandomRange(MineralBudget div 8, MineralBudget div 2)) + 1;
      Inc(Kind, Count);
      Init(t_Minerals, Count);
      NaturalFlag := True;
    end;
    ArcadeItem := TabItem.Create;
    ArcadeItem.SetItem(Item);
    Objects.Add(ArcadeItem);
    if Kind > MineralBudget then Break;
  end;
end;
{ @end $67B6B8 }

{ @routine $67CB90 TabSpace_PopulateScriptedEncounter }
procedure TabSpace.PopulateScriptedEncounter;
var
  Kind: Integer;
  Scale: Single;
  Index: Integer;
  Ship: TabShipAI;
  Minimum, Maximum, J: Integer;
  OtherShip: TabShip;
  // @nested $67C2D0 InitializeScriptedEncounterShip
  procedure InitializeScriptedEncounterShip; // @addr $67C2D0 @ida "void __cdecl $name(void *ParentFrame);"
  var
    WeaponIndex, Hitpoints: Integer;
  begin
    case GetPlayer.BlackHoleKillCount of
      0: Scale := 0.1;
      1..5: Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 1, 5, 0.5, 0.6);
      6..12: Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 6, 12, 0.6, 0.8);
      13..23: Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 13, 23, 0.8, 1);
      24..40: Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 24, 40, 1, 1.3);
    else Scale := RemapClamped(GetPlayer.BlackHoleKillCount, 41, 100, 1.3, 1.6);
    end;
    Scale := Scale * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Scale := RemapClamped(GetPlayer.Wealth, Galaxy.AverageRangerCapital / 2, Galaxy.MaxRangerWealth, 0.8, 1.1) * Scale;
    Scale := RemapClamped(GetPlayer.StrengthInBestRanger, 0.2, 1, 0.5, 1.1) * Scale;
    if Index = 0 then Scale := ArcadeBattleScreen.RandomFloat(1, 1.5) * Scale
    else if Index = 1 then Scale := ArcadeBattleScreen.RandomFloat(0.7, 1.1) * Scale
    else Scale := ArcadeBattleScreen.RandomFloat(0.2, 0.6) * Scale;
    if Ship.ConvertedFromGameShip then
    begin
      Ship.Health := Ship.Health * Ship.HealthScalePercent div 100;
      Ship.MaxHealth := Ship.MaxHealth * Ship.HealthScalePercent div 100;
    end
    else
    begin
      Hitpoints := Round(Max(150, Min(GetPlayer.GetHull.Weight * 1.2, 525 * Scale)));
      Hitpoints := Ship.HealthScalePercent * Hitpoints div 100;
      if Ship.SpawnGraphKey[1] = 'R' then Ship.CreateRuinsVisual(Ship.SpawnGraphKey, 128)
      else Ship.CreateShipVisual(Ship.SpawnGraphKey, Round(RemapClamped(Hitpoints, 150, 900, 50, 80)));
      Ship.MaxHealth := Hitpoints;
      Ship.Health := Hitpoints;
    end;
    Ship.MaxSpeed := RemapClamped(Ship.VisualDiameter, 50, 80, 7, 5);
    Ship.MaxSpeed := RemapClamped(GetPlayer.BlackHoleKillCount, 0, 30, 0.6, 1) * Ship.MaxSpeed;
    Ship.MaxSpeed := Ship.MaxSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Ship.TurnSpeed := RemapClamped(Ship.VisualDiameter, 50, 80, 4, 3);
    Ship.TurnSpeed := RemapClamped(GetPlayer.BlackHoleKillCount, 0, 30, 0.6, 1) * Ship.TurnSpeed;
    Ship.TurnSpeed := Ship.TurnSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Ship.Thrust := 0;
    if not Ship.ConvertedFromGameShip then
    begin
      Ship.WeaponCount := 0;
      Kind := ArcadeBattleScreen.RandomRange(Minimum, Maximum);
      Ship.AddWeapon(Kind);
      Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
      if Index = 0 then
      begin
        Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
        if ((GetPlayer.BlackHoleKillCount > 0) and (GetPlayer.StrengthInBestRanger > 0.9)) or (GetPlayer.WealthInBestRanger > 0.9) then
          Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
      end;
      if GetPlayer.BlackHoleKillCount > 0 then
      begin
        if (GetPlayer.StrengthInBestRanger > 0.7) or (GetPlayer.WealthInBestRanger > 0.7) then Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
        if ArcadeBattleScreen.RandomRange(0, Round(Danger)) < Danger then Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
      end;
    end;
    for WeaponIndex := 0 to Ship.WeaponCount - 1 do
      Ship.Weapons[WeaponIndex].Damage := Ship.Weapons[WeaponIndex].Damage * Ship.DamageScalePercent div 100;
    Ship.PrimaryWeapon := 0;
    Ship.EncounterTag := 1;
  end;
begin
  if (GetPlayer = nil) or (ActiveArcadeRequestShips = nil) then Exit;
  Minimum := Round(RemapClamped(Galaxy.RefreshTechLevel, 3, 8, 0, 6));
  Maximum := Round(RemapClamped(Galaxy.RefreshTechLevel, 3, 8, 6, 15));
  for Index := 0 to ActiveArcadeRequestShips.Count - 1 do
  begin
    Ship := TabShipAI(ActiveArcadeRequestShips[Index]);
    InitializeScriptedEncounterShip;
    if Ship.Team = 1 then PlayerArcadeShip.AddTrackedShip(Ship)
    else
    begin
      PlayerArcadeShip.AddEnemy(Ship);
      Ship.AddEnemy(PlayerArcadeShip);
    end;
    for J := 0 to ActiveArcadeRequestShips.Count - 1 do
      if J <> Index then
      begin
        OtherShip := TabShip(ActiveArcadeRequestShips[J]);
        if Ship.Team <> OtherShip.Team then Ship.AddEnemy(OtherShip);
      end;
    Objects.Add(Ship);
  end;
  ActiveArcadeRequestShips.Clear;
end;
{ @end $67CB90 }

{ @routine $67CD38 TabSpace_PopulateKellerEncounter }
procedure TabSpace.PopulateKellerEncounter;
var
  Ship: TabShipAI;
  I, VisualIndex, Minimum, Maximum, Kind: Integer;
  UnusedLocal: Integer; // Native unused scalar precedes managed temporaries.
begin
  Ship := TabShipAI.Create;
  Ship.CreateRuinsVisual('Ruins.Keller', 128);
  case GetPlayer.BlackHoleKillCount + GetPlayer.HyperspaceKillCount of
    0..10: Ship.MaxHealth := Max(2000, RoundAndTruncateToHundreds(KellerShip.GetHull.Weight / 2));
    11..20: Ship.MaxHealth := Max(2000, RoundAndTruncateToHundreds(KellerShip.GetHull.Weight / 1.6));
    21..52: Ship.MaxHealth := Max(2000, RoundAndTruncateToHundreds(KellerShip.GetHull.Weight / 1.3));
  else Ship.MaxHealth := Max(2000, RoundAndTruncateToHundreds(KellerShip.GetHull.Weight / 1));
  end;
  case GetPlayer.BlackHoleKillCount + GetPlayer.HyperspaceKillCount of
    0..10: Ship.Health := Max(1000, RoundAndTruncateToHundreds(KellerShip.GetHull.HullPoints / 2));
    11..20: Ship.Health := Max(1000, RoundAndTruncateToHundreds(KellerShip.GetHull.HullPoints / 1.5));
    21..52: Ship.Health := Max(1000, RoundAndTruncateToHundreds(KellerShip.GetHull.HullPoints / 1.3));
  else Ship.Health := Max(1000, RoundAndTruncateToHundreds(KellerShip.GetHull.HullPoints / 1));
  end;
  Ship.Health := Round(Ship.Health * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor);
  if Ship.Health > Ship.MaxHealth then Ship.Health := Ship.MaxHealth;
  Ship.MaxSpeed := 6;
  Ship.MaxSpeed := Ship.MaxSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
  Ship.TurnSpeed := 3;
  Ship.TurnSpeed := Ship.TurnSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
  Ship.Thrust := 0;
  Ship.WeaponCount := KellerShip.WeaponCount;
  for I := 0 to KellerShip.WeaponCount - 1 do ab_Weapon_InitializeFromInfo(@Ship.Weapons[I], KellerShip.Weapons[I + 1].GetWeaponInfo);
  Ship.PrimaryWeapon := 0;
  Ship.EncounterTag := 1;
  Objects.Add(Ship);
  KellerArcadeShip := Ship;
  for I := 0 to 3 do
  begin
    KellerFragments[I] := nil;
    KellerFragmentDistances[I] := 0;
    KellerFragmentValuesAC[I] := 0;
  end;
  KellerBreakupTicks := 0;
  KellerSplitActive := False;
  for I := 0 to Galaxy.DifficultyLevels[6] do
  begin
    Ship := TabShipAI.Create;
    if I = 0 then
    begin
      Ship.CreateShipVisual('Ship.Keller.K1', 100);
      Ship.Health := KellerArcadeShip.Health div 2;
    end
    else
    begin
      VisualIndex := ArcadeBattleScreen.RandomRange(3, 5);
      Ship.CreateShipVisual('Ship.Keller.K' + IntToStr(VisualIndex), 90 - 10 * VisualIndex + ArcadeBattleScreen.RandomRange(0, 10));
      Ship.Health := Round((100 * (8 - VisualIndex)) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor);
    end;
    Ship.MaxHealth := Ship.Health;
    Ship.MaxSpeed := 7;
    Ship.MaxSpeed := Ship.MaxSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Ship.TurnSpeed := 4;
    Ship.TurnSpeed := Ship.TurnSpeed * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[6]].QuestTimeAndExperienceFactor;
    Ship.Thrust := 0;
    Ship.WeaponCount := 0;
    if I = 0 then begin Minimum := 8; Maximum := 13; end
    else begin Minimum := 5; Maximum := 10; end;
    Kind := ArcadeBattleScreen.RandomRange(Minimum, Maximum);
    Ship.AddWeapon(Kind);
    Ship.AddWeapon(IncrementWrapped(Kind, Minimum, Maximum));
    Ship.PrimaryWeapon := 0;
    Ship.EncounterTag := 1;
    Objects.Add(Ship);
  end;
end;
{ @end $67CD38 }

{ @routine $67D5B8 TabSpace_UpdateApproachDanger }
procedure TabSpace.UpdateApproachDanger;

  // @nested $67D4F4 FindApproachDanger
  function FindApproachDanger(Space: TabSpace; Accumulated: Single): Single; // @addr $67D4F4 @ida "float __userpurge $name@<st0>(TabSpace *Space@<eax>, float Accumulated@<^0>, void *ParentFrame@<^4>);" @stackpop 4 @calls "0x67d57f,0x67d5e5"
  var
    Link: PabSpaceLink;
    Candidate: Single;
  begin
    Link := FirstArcadeSpaceLink;
    while Link <> nil do
    begin
      if (Link.Last = Space) and (Link.First.Danger <= 0) then
      begin
        Result := Accumulated;
        Exit;
      end;
      Link := Link.Next;
    end;
    Result := 1E20;
    Link := FirstArcadeSpaceLink;
    while Link <> nil do
    begin
      if Link.Last = Space then
      begin
        Candidate := FindApproachDanger(Link.First, Accumulated + Link.First.Danger);
        if Candidate < Result then Result := Candidate;
      end;
      Link := Link.Next;
    end;
  end;

begin
  if Danger <= 0 then
  begin
    ApproachDanger := 0;
    Exit;
  end;
  ApproachDanger := FindApproachDanger(Self, 0);
end;
{ @end $67D5B8 }

{ @routine $67D5FC TabSpace_PruneApproachDanger }
procedure TabSpace.PruneApproachDanger;
var
  Changed: Boolean;
  Link: PabSpaceLink;
  Space: TabSpace;
begin
  Changed := True;
  while Changed do
  begin
    Changed := False;
    Space := FirstArcadeSpace;
    while Space <> nil do
    begin
      if Space.ApproachDanger > 0 then
      begin
        Link := FirstArcadeSpaceLink;
        while Link <> nil do
        begin
          if (Link.First = Space) and (Link.Last.ApproachDanger > 0) then Break;
          Link := Link.Next;
        end;
        if Link <> nil then
        begin
          Link := FirstArcadeSpaceLink;
          while Link <> nil do
          begin
            if (Link.Last = Space) and (Link.First.ApproachDanger > 0) then Break;
            Link := Link.Next;
          end;
          if Link = nil then
          begin
            Space.ApproachDanger := 0;
            Changed := True;
          end;
        end;
      end;
      Space := Space.Next;
    end;
  end;
end;
{ @end $67D5FC }

{ @routine $67D6F4 TabSpace_GetDangerText }
function TabSpace.GetDangerText: WideString;
begin
  Result := '';
  if Danger = 0 then Result := LocalizedColorText('FormAB.DangerMini')
  else if Danger < 40 then Result := LocalizedColorText('FormAB.DangerSmall')
  else if Danger < 70 then Result := LocalizedColorText('FormAB.DangerAverage')
  else if Danger < 90 then Result := LocalizedColorText('FormAB.DangerBig')
  else Result := LocalizedColorText('FormAB.DangerHuge');
end;
{ @end $67D6F4 }

{ @routine $67D884 ab_Space_Clear }
procedure ab_Space_Clear;
begin
  ab_SpaceLink_Clear;
  while not (FirstArcadeSpace = nil) do ab_Space_Delete(LastArcadeSpace);
  CurrentArcadeSpace := nil;
  NextArcadeSpace := nil;
  StartArcadeSpace := nil;
  EndArcadeSpace := nil;
end;
{ @end $67D884 }

{ @routine $67D8BC ab_Space_Add }
function ab_Space_Add: TabSpace;
var
  Space: TabSpace;
begin
  Space := TabSpace.Create;
  if LastArcadeSpace <> nil then LastArcadeSpace.Next := Space;
  Space.Prev := LastArcadeSpace;
  Space.Next := nil;
  LastArcadeSpace := Space;
  if FirstArcadeSpace = nil then FirstArcadeSpace := Space;
  Result := Space;
end;
{ @end $67D8BC }

{ @routine $67D920 ab_Space_Delete }
procedure ab_Space_Delete(Space: TabSpace);
var
  Link, Removing: PabSpaceLink;
begin
  if Space.Prev <> nil then Space.Prev.Next := Space.Next;
  if Space.Next <> nil then Space.Next.Prev := Space.Prev;
  if LastArcadeSpace = Space then LastArcadeSpace := Space.Prev;
  if FirstArcadeSpace = Space then FirstArcadeSpace := Space.Next;
  Link := FirstArcadeSpaceLink;
  while Link <> nil do
  begin
    Removing := Link;
    Link := Link.Next;
    if (Removing.First = Space) or (Removing.Last = Space) then
      ab_SpaceLink_Delete(Removing);
  end;
  Space.Free;
end;
{ @end $67D920 }

{ @routine $67D9D0 ab_Space_CreateImages }
procedure ab_Space_CreateImages;
var
  Space: TabSpace;
begin
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    Space.CreateImage;
    Space := Space.Next;
  end;
end;
{ @end $67D9D0 }

{ @routine $67D9FC ab_Space_ClearImages }
procedure ab_Space_ClearImages;
var
  Space: TabSpace;
begin
  ab_SpaceLink_ClearImages;
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    Space.ClearImage;
    Space := Space.Next;
  end;
end;
{ @end $67D9FC }

{ @routine $67DA30 ab_Space_Update }
procedure ab_Space_Update;
var
  Space: TabSpace;
begin
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    Space.Update;
    Space := Space.Next;
  end;
end;
{ @end $67DA30 }

{ @routine $67DA5C ab_Space_Find }
function ab_Space_Find(GridPosition: TPoint): TabSpace;
var
  Space: TabSpace;
begin
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    if (Space.GridPosition.X = GridPosition.X) and (Space.GridPosition.Y = GridPosition.Y) then
    begin
      Result := Space;
      Exit;
    end;
    Space := Space.Next;
  end;
  Result := nil;
end;
{ @end $67DA5C }

{ @routine $67DAB4 ab_Space_RecountLinks }
procedure ab_Space_RecountLinks;
var
  Space: TabSpace;
begin
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    Space.RecountLinks;
    Space := Space.Next;
  end;
end;
{ @end $67DAB4 }

{ @routine $67DAE0 TabSpace_RecountLinks }
procedure TabSpace.RecountLinks;
var
  Link: PabSpaceLink;
begin
  IncomingCount := 0;
  OutgoingCount := 0;
  Link := FirstArcadeSpaceLink;
  while Link <> nil do
  begin
    if Link.First = Self then Inc(OutgoingCount)
    else if Link.Last = Self then Inc(IncomingCount);
    Link := Link.Next;
  end;
end;
{ @end $67DAE0 }

{ @routine $67DB40 ab_Space_UpdateApproachDanger }
procedure ab_Space_UpdateApproachDanger;
var
  Space: TabSpace;
begin
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    Space.UpdateApproachDanger;
    Space := Space.Next;
  end;
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    Space.PruneApproachDanger;
    Space := Space.Next;
  end;
end;
{ @end $67DB40 }

{ @routine $67DB94 ab_SpaceLink_Clear }
procedure ab_SpaceLink_Clear;
begin
  while not (FirstArcadeSpaceLink = nil) do ab_SpaceLink_Delete(LastArcadeSpaceLink);
end;
{ @end $67DB94 }

{ @routine $67DBAC ab_SpaceLink_Add }
function ab_SpaceLink_Add: PabSpaceLink;
var
  Link: PabSpaceLink;
begin
  Link := AllocClearEC(SizeOf(TabSpaceLink));
  if LastArcadeSpaceLink <> nil then LastArcadeSpaceLink.Next := Link;
  Link.Prev := LastArcadeSpaceLink;
  Link.Next := nil;
  LastArcadeSpaceLink := Link;
  if FirstArcadeSpaceLink = nil then FirstArcadeSpaceLink := Link;
  Result := Link;
end;
{ @end $67DBAC }

{ @routine $67DC0C ab_SpaceLink_Delete }
procedure ab_SpaceLink_Delete(Link: PabSpaceLink);
begin
  if Link.Prev <> nil then Link.Prev.Next := Link.Next;
  if Link.Next <> nil then Link.Next.Prev := Link.Prev;
  if LastArcadeSpaceLink = Link then LastArcadeSpaceLink := Link.Prev;
  if FirstArcadeSpaceLink = Link then FirstArcadeSpaceLink := Link.Next;
  FreeEC(Link);
end;
{ @end $67DC0C }

{ @routine $67DC74 ab_SpaceLink_Connect }
procedure ab_SpaceLink_Connect(First, Last: TabSpace);
var
  Link: PabSpaceLink;
begin
  Link := ab_SpaceLink_Add;
  Link.First := First;
  Link.Last := Last;
end;
{ @end $67DC74 }

{ @routine $67DCA0 ab_SpaceLink_Find }
function ab_SpaceLink_Find(First, Last: TabSpace): PabSpaceLink;
var
  Link: PabSpaceLink;
begin
  Link := FirstArcadeSpaceLink;
  while Link <> nil do
  begin
    if ((Link.First = First) and (Link.Last = Last)) or
       ((Link.First = Last) and (Link.Last = First)) then
    begin
      Result := Link;
      Exit;
    end;
    Link := Link.Next;
  end;
  Result := nil;
end;
{ @end $67DCA0 }

{ @routine $67DD0C ab_SpaceLink_FindExit }
function ab_SpaceLink_FindExit(First: TabSpace; ExitIndex: Integer): PabSpaceLink;
var
  Link: PabSpaceLink;
begin
  Link := FirstArcadeSpaceLink;
  while Link <> nil do
  begin
    if (Link.First = First) and (Link.ExitIndex = ExitIndex) then
    begin
      Result := Link;
      Exit;
    end;
    Link := Link.Next;
  end;
  Result := nil;
end;
{ @end $67DD0C }

{ @routine $67DD60 ab_SpaceLink_Invalidate }
procedure ab_SpaceLink_Invalidate;
var
  Link: PabSpaceLink;
  OffsetY, OffsetX, Index: Integer;
  Bounds: TRect;
begin
  OffsetX := ArcadeBattleScreen.WorldCenterX - ArcadeMapViewPosition.X;
  OffsetY := ArcadeBattleScreen.WorldCenterY - ArcadeMapViewPosition.Y;
  Link := FirstArcadeSpaceLink;
  while Link <> nil do
  begin
    Bounds.Left := 1000000000;
    Bounds.Right := -1000000000;
    Bounds.Top := 1000000000;
    Bounds.Bottom := -1000000000;
    for Index := 0 to 10 do
    begin
      Bounds.Left := Min(Bounds.Left, Link.Points[Index].X);
      Bounds.Top := Min(Bounds.Top, Link.Points[Index].Y);
      Bounds.Right := Max(Bounds.Right, Link.Points[Index].X);
      Bounds.Bottom := Max(Bounds.Bottom, Link.Points[Index].Y);
    end;
    Inc(Bounds.Left, OffsetX);
    Inc(Bounds.Top, OffsetY);
    Inc(Bounds.Right, OffsetX);
    Inc(Bounds.Bottom, OffsetY);
    ArcadeBattleScreen.QueueUpdateRect(Bounds);
    Link := Link.Next;
  end;
end;
{ @end $67DD60 }

{ @routine $67DEC0 ab_SpaceLink_BuildGeometry }
procedure ab_SpaceLink_BuildGeometry;
var
  First, Last: TPointF;
  DirectionY, DirectionX, WidthY, WidthX, InverseLength, ArrowLength: Single;
  Link: PabSpaceLink;
begin
  Link := FirstArcadeSpaceLink;
  while Link <> nil do
  begin
    First := PointToPointF(Link.First.MapPosition);
    Last := PointToPointF(Link.Last.MapPosition);
    DirectionX := Last.X - First.X;
    DirectionY := Last.Y - First.Y;
    InverseLength := 1 / Sqrt(Sqr(DirectionX) + Sqr(DirectionY));
    DirectionX := DirectionX * InverseLength;
    DirectionY := DirectionY * InverseLength;
    ArrowLength := GiScalePixels(ArcadeMapNodeRadius) * 0.5;
    First.X := GiScalePixels(ArcadeMapNodeRadius) * DirectionX * 1.1 + First.X;
    First.Y := GiScalePixels(ArcadeMapNodeRadius) * DirectionY * 1.1 + First.Y;
    Last.X := Last.X - (GiScalePixels(ArcadeMapNodeRadius) * 1.1 + ArrowLength) * DirectionX;
    Last.Y := Last.Y - (GiScalePixels(ArcadeMapNodeRadius) * 1.1 + ArrowLength) * DirectionY;
    WidthX := GiScalePixels(7) * DirectionX;
    WidthY := GiScalePixels(7) * DirectionY;
    Link.Points[0] := Classes.Point(Round(First.X - WidthY), Round(First.Y + WidthX));
    Link.Points[1] := Classes.Point(Round(First.X + WidthY), Round(First.Y - WidthX));
    Link.Points[2] := Classes.Point(Round(Last.X + WidthY - DirectionX * 2), Round(Last.Y - WidthX - DirectionY * 2));
    Link.Points[3] := Classes.Point(Round(Last.X - WidthY - DirectionX * 2), Round(Last.Y + WidthX - DirectionY * 2));
    Link.Points[7] := Classes.Point(Round(First.X - 0.7 * WidthY), Round(0.7 * WidthX + First.Y));
    Link.Points[8] := Classes.Point(Round(0.7 * WidthY + First.X), Round(First.Y - 0.7 * WidthX));
    Link.Points[9] := Classes.Point(Round(0.7 * WidthY + Last.X - DirectionX * 2), Round(Last.Y - 0.7 * WidthX - DirectionY * 2));
    Link.Points[10] := Classes.Point(Round(Last.X - 0.7 * WidthY - DirectionX * 2), Round(0.7 * WidthX + Last.Y - DirectionY * 2));
    WidthX := DirectionX * ArrowLength * 0.4;
    WidthY := DirectionY * ArrowLength * 0.4;
    Link.Points[4] := Classes.Point(Round(Last.X - WidthY), Round(Last.Y + WidthX));
    Link.Points[5] := Classes.Point(Round(DirectionX * ArrowLength + Last.X), Round(DirectionY * ArrowLength + Last.Y));
    Link.Points[6] := Classes.Point(Round(Last.X + WidthY), Round(Last.Y - WidthX));
    Link := Link.Next;
  end;
end;
{ @end $67DEC0 }

{ @routine $67E32C ab_SpaceLink_ClearImages }
procedure ab_SpaceLink_ClearImages;
var
  Link: PabSpaceLink;
begin
  { The native routine retains this traversal without any per-link action. }
  Link := FirstArcadeSpaceLink;
  while Link <> nil do Link := Link.Next;
end;
{ @end $67E32C }

{ @routine $67E350 ab_SpaceLink_Draw }
procedure ab_SpaceLink_Draw;
var
  Link: PabSpaceLink;
  ColorOffset, OffsetY, OffsetX: Integer;
begin
  OffsetX := ArcadeBattleScreen.WorldCenterX - ArcadeMapViewPosition.X;
  OffsetY := ArcadeBattleScreen.WorldCenterY - ArcadeMapViewPosition.Y;
  Link := FirstArcadeSpaceLink;
  while Link <> nil do
  begin
    ColorOffset := Link.Last.AppearanceIndex * 6;
    if HardwareRenderingEnabled then
    begin
      DrawGradientLine(Link.Points[7].X + OffsetX, Link.Points[7].Y + OffsetY, $40FFFFFF,
        Link.Points[10].X + OffsetX, Link.Points[10].Y + OffsetY, $C0FFFFFF, @GameScreenRect);
      DrawGradientLine(Link.Points[8].X + OffsetX, Link.Points[8].Y + OffsetY, $40FFFFFF,
        Link.Points[9].X + OffsetX, Link.Points[9].Y + OffsetY, $C0FFFFFF, @GameScreenRect);
      DrawColoredTriangle(
        Link.Points[0].X + OffsetX, Link.Points[0].Y + OffsetY, ArcadeMapPalette[ColorOffset + 3],
        Link.Points[1].X + OffsetX, Link.Points[1].Y + OffsetY, ArcadeMapPalette[ColorOffset + 3],
        Link.Points[2].X + OffsetX, Link.Points[2].Y + OffsetY, ArcadeMapPalette[ColorOffset + 2], True, @GameScreenRect);
      DrawColoredTriangle(
        Link.Points[2].X + OffsetX, Link.Points[2].Y + OffsetY, ArcadeMapPalette[ColorOffset + 2],
        Link.Points[3].X + OffsetX, Link.Points[3].Y + OffsetY, ArcadeMapPalette[ColorOffset + 2],
        Link.Points[0].X + OffsetX, Link.Points[0].Y + OffsetY, ArcadeMapPalette[ColorOffset + 3], True, @GameScreenRect);
      DrawColoredTriangle(
        Link.Points[4].X + OffsetX, Link.Points[4].Y + OffsetY, ArcadeMapPalette[ColorOffset + 1],
        Link.Points[5].X + OffsetX, Link.Points[5].Y + OffsetY, ArcadeMapPalette[ColorOffset],
        Link.Points[6].X + OffsetX, Link.Points[6].Y + OffsetY, ArcadeMapPalette[ColorOffset + 1], True, @GameScreenRect);
    end
    else
    begin
      DrawGradientLine16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
        Link.Points[7].X + OffsetX, Link.Points[7].Y + OffsetY, $40FFFFFF,
        Link.Points[10].X + OffsetX, Link.Points[10].Y + OffsetY, $C0FFFFFF, GameScreenRect);
      DrawGradientLine16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
        Link.Points[8].X + OffsetX, Link.Points[8].Y + OffsetY, $40FFFFFF,
        Link.Points[9].X + OffsetX, Link.Points[9].Y + OffsetY, $C0FFFFFF, GameScreenRect);
      TriangleRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
        Link.Points[0].X + OffsetX, Link.Points[0].Y + OffsetY, ArcadeMapPalette[ColorOffset + 3],
        Link.Points[1].X + OffsetX, Link.Points[1].Y + OffsetY, ArcadeMapPalette[ColorOffset + 3],
        Link.Points[2].X + OffsetX, Link.Points[2].Y + OffsetY, ArcadeMapPalette[ColorOffset + 2], @GameScreenRect);
      TriangleRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
        Link.Points[2].X + OffsetX, Link.Points[2].Y + OffsetY, ArcadeMapPalette[ColorOffset + 2],
        Link.Points[3].X + OffsetX, Link.Points[3].Y + OffsetY, ArcadeMapPalette[ColorOffset + 2],
        Link.Points[0].X + OffsetX, Link.Points[0].Y + OffsetY, ArcadeMapPalette[ColorOffset + 3], @GameScreenRect);
      TriangleRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
        Link.Points[4].X + OffsetX, Link.Points[4].Y + OffsetY, ArcadeMapPalette[ColorOffset + 1],
        Link.Points[5].X + OffsetX, Link.Points[5].Y + OffsetY, ArcadeMapPalette[ColorOffset],
        Link.Points[6].X + OffsetX, Link.Points[6].Y + OffsetY, ArcadeMapPalette[ColorOffset + 1], @GameScreenRect);
    end;
    Link := Link.Next;
  end;
end;
{ @end $67E350 }

end.
