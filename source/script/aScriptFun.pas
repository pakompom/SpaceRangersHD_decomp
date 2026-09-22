unit aScriptFun;
// Unit bracket (inferred): .text 0x00605480..0x00645D50; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, EC_Expression, aItem, aShip;

// av[0] holds the script result.

procedure SF_GRun(av: array of TVarEC; code: TCodeEC); // @addr 0x605480
procedure SF_GCntRun(av: array of TVarEC; code: TCodeEC); // @addr 0x6054B4
procedure SF_GLastTurnRun(av: array of TVarEC; code: TCodeEC); // @addr 0x6055C8
procedure SF_GAllCntRun(av: array of TVarEC; code: TCodeEC); // @addr 0x605714
procedure SF_IsScriptActive(av: array of TVarEC; code: TCodeEC); // @addr 0x6057C8
procedure SF_GetValueFromScript(av: array of TVarEC; code: TCodeEC); // @addr 0x6058B0
procedure SF_RunFunctionFromScript(av: array of TVarEC; code: TCodeEC); // @addr 0x605D18
procedure SF_GetVariableName(av: array of TVarEC; code: TCodeEC); // @addr 0x6061E4
procedure SF_GetVariableType(av: array of TVarEC; code: TCodeEC); // @addr 0x606268
procedure SF_StatusPlayer(av: array of TVarEC; code: TCodeEC); // @addr 0x6075FC
procedure SF_AddPlanetNews(av: array of TVarEC; code: TCodeEC); // @addr 0x6062F0
procedure SF_AddJournalRecord(av: array of TVarEC; code: TCodeEC); // @addr 0x6063E8
procedure SF_AutoBattle(av: array of TVarEC; code: TCodeEC); // @addr 0x6065B4
procedure SF_GetOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x606630
procedure SF_GiveReward(av: array of TVarEC; code: TCodeEC); // @addr 0x6066C0
procedure SF_GiveRewardByNom(av: array of TVarEC; code: TCodeEC); // @addr 0x6067F0
procedure SF_CountReward(av: array of TVarEC; code: TCodeEC); // @addr 0x606884
procedure SF_CountRewardByNom(av: array of TVarEC; code: TCodeEC); // @addr 0x606B08
procedure SF_DeleteRewardByNom(av: array of TVarEC; code: TCodeEC); // @addr 0x606C00
procedure SF_Rnd(av: array of TVarEC; code: TCodeEC); // @addr 0x607420
procedure SF_GameDateTxtByTurn(av: array of TVarEC; code: TCodeEC); // @addr 0x60753C
procedure SF_Id(av: array of TVarEC; code: TCodeEC); // @addr 0x607668
procedure SF_SetName(av: array of TVarEC; code: TCodeEC); // @addr 0x60799C
procedure SF_UseTranclucator(av: array of TVarEC; code: TCodeEC); // @addr 0x607B10
procedure SF_HullDamage(av: array of TVarEC; code: TCodeEC); // @addr 0x607DE8
procedure SF_Hitpoints(av: array of TVarEC; code: TCodeEC); // @addr 0x607ECC
procedure SF_Hit(av: array of TVarEC; code: TCodeEC); // @addr 0x607F94
procedure SF_ChangeGlobalRelationsShips(av: array of TVarEC; code: TCodeEC); // @addr 0x608098
procedure SF_ChangeGlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC); // @addr 0x608230
procedure SF_GlobalRelationsShips(av: array of TVarEC; code: TCodeEC); // @addr 0x6083A4
procedure SF_GlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC); // @addr 0x6084EC
procedure SF_SetRelationGroup(av: array of TVarEC; code: TCodeEC); // @addr 0x608620
procedure SF_SetRelationPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x6086C0
procedure SF_GetRelationPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x608760
procedure SF_CurTurn(av: array of TVarEC; code: TCodeEC); // @addr 0x608800
procedure SF_ShipType(av: array of TVarEC; code: TCodeEC); // @addr 0x60885C
procedure SF_ConName(av: array of TVarEC; code: TCodeEC); // @addr 0x608A98
procedure SF_StarName(av: array of TVarEC; code: TCodeEC); // @addr 0x608B98
procedure SF_StarMapLabel(av: array of TVarEC; code: TCodeEC); // @addr 0x608C1C
procedure SF_PlanetName(av: array of TVarEC; code: TCodeEC); // @addr 0x608CFC
procedure SF_IdToPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x608D80
procedure SF_IdToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x608E10
procedure SF_IdToItem(av: array of TVarEC; code: TCodeEC); // @addr 0x608EB8
procedure SF_PlanetSetGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x608F48
procedure SF_ShipName(av: array of TVarEC; code: TCodeEC); // @addr 0x608FE8
procedure SF_ShipRank(av: array of TVarEC; code: TCodeEC); // @addr 0x6090A4
procedure SF_ShipRankPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x609138
procedure SF_ShipNextRankPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x6091EC
procedure SF_ShipRaiseRank(av: array of TVarEC; code: TCodeEC); // @addr 0x609294
procedure SF_ShipStar(av: array of TVarEC; code: TCodeEC); // @addr 0x609348
procedure SF_StarToCon(av: array of TVarEC; code: TCodeEC); // @addr 0x6093CC
procedure SF_ConNear(av: array of TVarEC; code: TCodeEC); // @addr 0x609450
procedure SF_ConStars(av: array of TVarEC; code: TCodeEC); // @addr 0x609558
procedure SF_ConStar(av: array of TVarEC; code: TCodeEC); // @addr 0x6095E0
procedure SF_GalaxyStars(av: array of TVarEC; code: TCodeEC); // @addr 0x6096A0
procedure SF_GalaxyStar(av: array of TVarEC; code: TCodeEC); // @addr 0x6096E4
procedure SF_StarAngleBetween(av: array of TVarEC; code: TCodeEC); // @addr 0x60979C
procedure SF_FindPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x6098C4
procedure SF_IsPlayer(av: array of TVarEC; code: TCodeEC); // @addr 0x60B804
procedure SF_GroupCount(av: array of TVarEC; code: TCodeEC); // @addr 0x60B890
procedure SF_GroupIn(av: array of TVarEC; code: TCodeEC); // @addr 0x60B964
procedure SF_CountIn(av: array of TVarEC; code: TCodeEC); // @addr 0x60BD4C
procedure SF_ChangeState(av: array of TVarEC; code: TCodeEC); // @addr 0x60C320
procedure SF_NearestGroup(av: array of TVarEC; code: TCodeEC); // @addr 0x60C1A8
procedure SF_StarAngle(av: array of TVarEC; code: TCodeEC); // @addr 0x60C52C
procedure SF_NewsAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x60C5D0
procedure SF_MsgAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x60C68C
procedure SF_Ether(av: array of TVarEC; code: TCodeEC); // @addr 0x60C800
procedure SF_CustomEther(av: array of TVarEC; code: TCodeEC); // @addr 0x60CBA0
procedure SF_EtherDelete(av: array of TVarEC; code: TCodeEC); // @addr 0x60CF60
procedure SF_EtherIdAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x60D010
procedure SF_EtherIdDelete(av: array of TVarEC; code: TCodeEC); // @addr 0x60D0C8
procedure SF_EtherState(av: array of TVarEC; code: TCodeEC); // @addr 0x60D1A0
procedure SF_ConChangeRelationToRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x60D278
procedure SF_GetData(av: array of TVarEC; code: TCodeEC); // @addr 0x60D3A0
procedure SF_SetData(av: array of TVarEC; code: TCodeEC); // @addr 0x60D464
procedure SF_ShipData(av: array of TVarEC; code: TCodeEC); // @addr 0x60D568
procedure SF_Format(av: array of TVarEC; code: TCodeEC); // @addr 0x60D5E8
procedure SF_DeleteTags(av: array of TVarEC; code: TCodeEC); // @addr 0x60D8EC
procedure SF_Dialog(av: array of TVarEC; code: TCodeEC); // @addr 0x60D9B0
procedure SF_DText(av: array of TVarEC; code: TCodeEC); // @addr 0x60DD84
procedure SF_DAddText(av: array of TVarEC; code: TCodeEC); // @addr 0x60DFA0
procedure SF_DAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x60E1CC
procedure SF_DChange(av: array of TVarEC; code: TCodeEC); // @addr 0x610478
procedure SF_DAnswer(av: array of TVarEC; code: TCodeEC); // @addr 0x60E248
procedure SF_Player(av: array of TVarEC; code: TCodeEC); // @addr 0x6104F4
procedure SF_ItemExist(av: array of TVarEC; code: TCodeEC); // @addr 0x610530
procedure SF_ItemIn(av: array of TVarEC; code: TCodeEC); // @addr 0x6105CC
procedure SF_ItemCost(av: array of TVarEC; code: TCodeEC); // @addr 0x6197F4
procedure SF_ItemCount(av: array of TVarEC; code: TCodeEC); // @addr 0x610898
procedure SF_ShipPicksItem(av: array of TVarEC; code: TCodeEC); // @addr 0x606D34
procedure SF_DropItem(av: array of TVarEC; code: TCodeEC); // @addr 0x606ED0
procedure SF_DropScriptItem(av: array of TVarEC; code: TCodeEC); // @addr 0x607224
procedure SF_DeleteEquipment(av: array of TVarEC; code: TCodeEC); // @addr 0x60732C
procedure SF_DecayGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x6109B0
procedure SF_UpsurgeGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x610A6C
procedure SF_GoodsAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x610B04
procedure SF_GoodsCount(av: array of TVarEC; code: TCodeEC); // @addr 0x610C58
procedure SF_GoodsCost(av: array of TVarEC; code: TCodeEC); // @addr 0x610CF4
procedure SF_GoodsRuinsForBuy(av: array of TVarEC; code: TCodeEC); // @addr 0x610D90
procedure SF_ShipGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x610E30
procedure SF_ShipGoodsIllegalOnPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x610F80
procedure SF_GoodsDrop(av: array of TVarEC; code: TCodeEC); // @addr 0x6110A4
procedure SF_UselessItemCreate(av: array of TVarEC; code: TCodeEC); // @addr 0x61134C
procedure SF_GoodsSellPrice(av: array of TVarEC; code: TCodeEC); // @addr 0x61158C
procedure SF_GoodsBuyPrice(av: array of TVarEC; code: TCodeEC); // @addr 0x6116B0
procedure SF_CountTurn(av: array of TVarEC; code: TCodeEC); // @addr 0x6117D4
procedure SF_ShipSetBad(av: array of TVarEC; code: TCodeEC); // @addr 0x611C34
procedure SF_GroupSetBad(av: array of TVarEC; code: TCodeEC); // @addr 0x611CC8
procedure SF_ShipSetPartner(av: array of TVarEC; code: TCodeEC); // @addr 0x611DA4
procedure SF_ShipJoin(av: array of TVarEC; code: TCodeEC); // @addr 0x611EAC
procedure SF_ShipOut(av: array of TVarEC; code: TCodeEC); // @addr 0x61231C
procedure SF_AllShipOut(av: array of TVarEC; code: TCodeEC); // @addr 0x6123AC
procedure SF_ShipInScript(av: array of TVarEC; code: TCodeEC); // @addr 0x6123E4
procedure SF_ShipInGameEvent(av: array of TVarEC; code: TCodeEC); // @addr 0x6124A8
procedure SF_ShipInCurScript(av: array of TVarEC; code: TCodeEC); // @addr 0x6125A0
procedure SF_ShipInNormalSpace(av: array of TVarEC; code: TCodeEC); // @addr 0x612664
procedure SF_ShipInHole(av: array of TVarEC; code: TCodeEC); // @addr 0x612714
procedure SF_ShipIsTakeoff(av: array of TVarEC; code: TCodeEC); // @addr 0x6127E8
procedure SF_ShipCntWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x61288C
procedure SF_ShipWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x612914
procedure SF_ShipEqInSlot(av: array of TVarEC; code: TCodeEC); // @addr 0x6129D0
procedure SF_ArtefactTypeInUse(av: array of TVarEC; code: TCodeEC); // @addr 0x612AB8
procedure SF_ArtefactTypeBoosted(av: array of TVarEC; code: TCodeEC); // @addr 0x612CAC
procedure SF_ShipSpeed(av: array of TVarEC; code: TCodeEC); // @addr 0x612E38
procedure SF_EnginePower(av: array of TVarEC; code: TCodeEC); // @addr 0x612EBC
procedure SF_ShipJump(av: array of TVarEC; code: TCodeEC); // @addr 0x61300C
procedure SF_ShipArmor(av: array of TVarEC; code: TCodeEC); // @addr 0x613090
procedure SF_ShipProtectability(av: array of TVarEC; code: TCodeEC); // @addr 0x613114
procedure SF_ShipDroidRepair(av: array of TVarEC; code: TCodeEC); // @addr 0x6131B8
procedure SF_ShipRadarRange(av: array of TVarEC; code: TCodeEC); // @addr 0x613274
procedure SF_ShipScanerPower(av: array of TVarEC; code: TCodeEC); // @addr 0x6132FC
procedure SF_ShipHookPower(av: array of TVarEC; code: TCodeEC); // @addr 0x613388
procedure SF_ShipHookRange(av: array of TVarEC; code: TCodeEC); // @addr 0x613440
procedure SF_ShipAverageDamage(av: array of TVarEC; code: TCodeEC); // @addr 0x6134F0
procedure SF_ShipHealthFactor(av: array of TVarEC; code: TCodeEC); // @addr 0x6136E4
procedure SF_ShipHealthFactorStatus(av: array of TVarEC; code: TCodeEC); // @addr 0x6139B4
procedure SF_PlayerImmunity(av: array of TVarEC; code: TCodeEC); // @addr 0x613AE4
procedure SF_ShipStatusEffect(av: array of TVarEC; code: TCodeEC); // @addr 0x613B44
procedure SF_ShipGroup(av: array of TVarEC; code: TCodeEC); // @addr 0x612D90
procedure SF_ShipCanJump(av: array of TVarEC; code: TCodeEC); // @addr 0x609C88
procedure SF_ShipInStar(av: array of TVarEC; code: TCodeEC); // @addr 0x609E14
procedure SF_ShipInPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x609EC4
procedure SF_ShipStatistic(av: array of TVarEC; code: TCodeEC); // @addr 0x609F68
procedure SF_PlayerDominatorStatistic(av: array of TVarEC; code: TCodeEC); // @addr 0x60A494
procedure SF_ShipMoney(av: array of TVarEC; code: TCodeEC); // @addr 0x60A564
procedure SF_ShipFuel(av: array of TVarEC; code: TCodeEC); // @addr 0x60A620
procedure SF_ShipFuelLow(av: array of TVarEC; code: TCodeEC); // @addr 0x60A710
procedure SF_ShipStrengthInBestRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x60A7E0
procedure SF_ShipStrengthInAverageRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x60A880
procedure SF_ChanceToWin(av: array of TVarEC; code: TCodeEC); // @addr 0x60A91C
procedure SF_ShipFind(av: array of TVarEC; code: TCodeEC); // @addr 0x60AF68
procedure SF_RangerStatus(av: array of TVarEC; code: TCodeEC); // @addr 0x60A9F0
procedure SF_RangerPlaceInRating(av: array of TVarEC; code: TCodeEC); // @addr 0x60ACF8
procedure SF_RangerExcludedFromRating(av: array of TVarEC; code: TCodeEC); // @addr 0x60ADEC
procedure SF_GalaxyMoney(av: array of TVarEC; code: TCodeEC); // @addr 0x607840
procedure SF_ShipDestroy(av: array of TVarEC; code: TCodeEC); // @addr 0x60B048 @note "Queues destruction without removing the ship immediately; returns the previous flag. An omitted second argument queues destruction, a negative one only queries."
procedure SF_ShipDestroyType(av: array of TVarEC; code: TCodeEC); // @addr 0x60B134
procedure SF_ItemDestroy(av: array of TVarEC; code: TCodeEC); // @addr 0x60B264
procedure SF_RangersCapital(av: array of TVarEC; code: TCodeEC); // @addr 0x60B344
procedure SF_GroupToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x60B384
procedure SF_OrderLanding(av: array of TVarEC; code: TCodeEC); // @addr 0x60B6D0
procedure SF_OrderJump(av: array of TVarEC; code: TCodeEC); // @addr 0x60B47C
procedure SF_GroupIs(av: array of TVarEC; code: TCodeEC); // @addr 0x613C94
procedure SF_StateIs(av: array of TVarEC; code: TCodeEC); // @addr 0x613D9C
procedure SF_Dist(av: array of TVarEC; code: TCodeEC); // @addr 0x613EE8
procedure SF_Angle(av: array of TVarEC; code: TCodeEC); // @addr 0x614390
procedure SF_Dist2Star(av: array of TVarEC; code: TCodeEC); // @addr 0x614838
procedure SF_BuyPirate(av: array of TVarEC; code: TCodeEC); // @addr 0x6148D4
procedure SF_BuyTransport(av: array of TVarEC; code: TCodeEC); // @addr 0x6149A8
procedure SF_Name(av: array of TVarEC; code: TCodeEC); // @addr 0x614A98
procedure SF_ShortName(av: array of TVarEC; code: TCodeEC); // @addr 0x614C9C
procedure SF_FirstGiveMoney(av: array of TVarEC; code: TCodeEC); // @addr 0x614E60
procedure SF_HaveProgramm(av: array of TVarEC; code: TCodeEC); // @addr 0x614EC4
procedure SF_GetProgramm(av: array of TVarEC; code: TCodeEC); // @addr 0x614F54
procedure SF_SetProgramm(av: array of TVarEC; code: TCodeEC); // @addr 0x614FE4
procedure SF_DomikProgramm(av: array of TVarEC; code: TCodeEC); // @addr 0x6150A0
procedure SF_DomikProgrammDate(av: array of TVarEC; code: TCodeEC); // @addr 0x6151C4
procedure SF_HoleMamaCreate(av: array of TVarEC; code: TCodeEC); // @addr 0x615270
procedure SF_HoleCreate(av: array of TVarEC; code: TCodeEC); // @addr 0x615668
procedure SF_TerronWeaponLock(av: array of TVarEC; code: TCodeEC); // @addr 0x615A04
procedure SF_TerronGrowLock(av: array of TVarEC; code: TCodeEC); // @addr 0x615A48
procedure SF_TerronLandingLock(av: array of TVarEC; code: TCodeEC); // @addr 0x615A8C
procedure SF_TerronToStar(av: array of TVarEC; code: TCodeEC); // @addr 0x615AD0
procedure SF_KellerLeave(av: array of TVarEC; code: TCodeEC); // @addr 0x615B14
procedure SF_KellerNewResearch(av: array of TVarEC; code: TCodeEC); // @addr 0x615B58
procedure SF_KellerKill(av: array of TVarEC; code: TCodeEC); // @addr 0x615B9C
procedure SF_BlazerLanding(av: array of TVarEC; code: TCodeEC); // @addr 0x615BD0
procedure SF_BlazerSelfDestruction(av: array of TVarEC; code: TCodeEC); // @addr 0x615CC4
procedure SF_GalaxyShipId(av: array of TVarEC; code: TCodeEC); // @addr 0x615D08
procedure SF_NearCivilPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x615D48
procedure SF_SkipGreeting(av: array of TVarEC; code: TCodeEC); // @addr 0x615E54
procedure SF_Sound(av: array of TVarEC; code: TCodeEC); // @addr 0x615E8C
procedure SF_Tips(av: array of TVarEC; code: TCodeEC); // @addr 0x615F3C
procedure SF_TipsState(av: array of TVarEC; code: TCodeEC); // @addr 0x615FB0
procedure SF_CT(av: array of TVarEC; code: TCodeEC); // @addr 0x6161B4
procedure SF_BlockExist(av: array of TVarEC; code: TCodeEC); // @addr 0x6164F4
procedure SF_GetMainData(av: array of TVarEC; code: TCodeEC); // @addr 0x616930
procedure SF_GetGameOptions(av: array of TVarEC; code: TCodeEC); // @addr 0x616B90
procedure SF_ResourceExist(av: array of TVarEC; code: TCodeEC); // @addr 0x616D34
procedure SF_SFT(av: array of TVarEC; code: TCodeEC); // @addr 0x61EE08
procedure SF_CurrentMods(av: array of TVarEC; code: TCodeEC); // @addr 0x616DFC
procedure SF_RobotSupport(av: array of TVarEC; code: TCodeEC); // @addr 0x616F4C
procedure SF_StarShips(av: array of TVarEC; code: TCodeEC); // @addr 0x616FA4
procedure SF_StarPlanets(av: array of TVarEC; code: TCodeEC); // @addr 0x617084
procedure SF_StarMissiles(av: array of TVarEC; code: TCodeEC); // @addr 0x617168
procedure SF_StarAsteroids(av: array of TVarEC; code: TCodeEC); // @addr 0x61724C
procedure SF_GroupShip(av: array of TVarEC; code: TCodeEC); // @addr 0x617330
procedure SF_ShipItems(av: array of TVarEC; code: TCodeEC); // @addr 0x61742C
procedure SF_ShipArts(av: array of TVarEC; code: TCodeEC); // @addr 0x617518
procedure SF_PlayerTranclucators(av: array of TVarEC; code: TCodeEC); // @addr 0x617604
procedure SF_ArtTranclucatorToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x61771C
procedure SF_TranclucatorData(av: array of TVarEC; code: TCodeEC); // @addr 0x61780C
procedure SF_LinkItemToScript(av: array of TVarEC; code: TCodeEC); // @addr 0x6182B4
procedure SF_ReleaseItemFromScript(av: array of TVarEC; code: TCodeEC); // @addr 0x6184B0
procedure SF_ScriptItemData(av: array of TVarEC; code: TCodeEC); // @addr 0x618584
procedure SF_ScriptItemTextData(av: array of TVarEC; code: TCodeEC); // @addr 0x61871C
procedure SF_ScriptItemToItem(av: array of TVarEC; code: TCodeEC); // @addr 0x618918
procedure SF_GetShipPirateRank(av: array of TVarEC; code: TCodeEC); // @addr 0x6189EC
procedure SF_ShipPirateRankPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x618A80
procedure SF_ShipNextPirateRankPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x618B38
procedure SF_ShipInPirateClan(av: array of TVarEC; code: TCodeEC); // @addr 0x618BE8
procedure SF_ShipOnSidePirateClan(av: array of TVarEC; code: TCodeEC); // @addr 0x618CA0
procedure SF_RaisePirateRank(av: array of TVarEC; code: TCodeEC); // @addr 0x618D38
procedure SF_ItemType(av: array of TVarEC; code: TCodeEC); // @addr 0x618E0C
procedure SF_CustomWeaponType(av: array of TVarEC; code: TCodeEC); // @addr 0x618EDC
procedure SF_ItemName(av: array of TVarEC; code: TCodeEC); // @addr 0x618FD4
procedure SF_ItemFullName(av: array of TVarEC; code: TCodeEC); // @addr 0x6190D8
procedure SF_ItemSize(av: array of TVarEC; code: TCodeEC); // @addr 0x6191E0
procedure SF_ItemOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x619618
procedure SF_ItemSubrace(av: array of TVarEC; code: TCodeEC); // @addr 0x619700
procedure SF_ItemIsInUse(av: array of TVarEC; code: TCodeEC); // @addr 0x6198D8
procedure SF_ItemIsInSet(av: array of TVarEC; code: TCodeEC); // @addr 0x619B78
procedure SF_PlayerEqSet(av: array of TVarEC; code: TCodeEC); // @addr 0x619D38
procedure SF_ItemIsBroken(av: array of TVarEC; code: TCodeEC); // @addr 0x619E40
procedure SF_ShipCanUseEq(av: array of TVarEC; code: TCodeEC); // @addr 0x619F6C
procedure SF_ShipCanRepairEq(av: array of TVarEC; code: TCodeEC); // @addr 0x61A06C
procedure SF_ShipTechLevelKnowledge(av: array of TVarEC; code: TCodeEC); // @addr 0x61A170
procedure SF_WeaponTarget(av: array of TVarEC; code: TCodeEC); // @addr 0x61A220
procedure SF_GetEquipmentStats(av: array of TVarEC; code: TCodeEC); // @addr 0x61A348
procedure SF_SetEquipmentStats(av: array of TVarEC; code: TCodeEC); // @addr 0x61AAB8
procedure SF_CreateHull(av: array of TVarEC; code: TCodeEC); // @addr 0x61AED8
procedure SF_CreateEquipment(av: array of TVarEC; code: TCodeEC); // @addr 0x61AFE8
procedure SF_CreateArt(av: array of TVarEC; code: TCodeEC); // @addr 0x61B0DC
procedure SF_CreateCustomWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x61B17C
procedure SF_CreateCustomArt(av: array of TVarEC; code: TCodeEC); // @addr 0x61B288
procedure SF_CustomArtData(av: array of TVarEC; code: TCodeEC); // @addr 0x61B3C8
procedure SF_CustomArtTextData(av: array of TVarEC; code: TCodeEC); // @addr 0x61B5C0
procedure SF_CreateMM(av: array of TVarEC; code: TCodeEC); // @addr 0x61B828
procedure SF_CreateNodes(av: array of TVarEC; code: TCodeEC); // @addr 0x61B8C4
procedure SF_CreateCustomCountableItem(av: array of TVarEC; code: TCodeEC); // @addr 0x61B9A4
procedure SF_CreateZond(av: array of TVarEC; code: TCodeEC); // @addr 0x61BAC0
procedure SF_ExistingZonds(av: array of TVarEC; code: TCodeEC); // @addr 0x61BBC0
procedure SF_FreeItem(av: array of TVarEC; code: TCodeEC); // @addr 0x61BC98
procedure SF_ShipJoinsClan(av: array of TVarEC; code: TCodeEC); // @addr 0x61BD74
procedure SF_AddItemToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x61BE30
procedure SF_GetItemFromShip(av: array of TVarEC; code: TCodeEC); // @addr 0x61C07C
procedure SF_GetArtFromShip(av: array of TVarEC; code: TCodeEC); // @addr 0x61C424
procedure SF_ArrangeItems(av: array of TVarEC; code: TCodeEC); // @addr 0x61C55C
procedure SF_AddItemToPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x61C5F4
procedure SF_GetItemFromPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x61C6BC
procedure SF_AddItemToShop(av: array of TVarEC; code: TCodeEC); // @addr 0x61C7C8
procedure SF_GetItemFromShop(av: array of TVarEC; code: TCodeEC); // @addr 0x61C984
procedure SF_AddItemToStorage(av: array of TVarEC; code: TCodeEC); // @addr 0x61CB64
procedure SF_GetItemFromStorage(av: array of TVarEC; code: TCodeEC); // @addr 0x61CDA4
procedure SF_FindItemInStorage(av: array of TVarEC; code: TCodeEC); // @addr 0x61CE98
procedure SF_PutItemInVault(av: array of TVarEC; code: TCodeEC); // @addr 0x61CF78
procedure SF_GetItemFromVault(av: array of TVarEC; code: TCodeEC); // @addr 0x61D088
procedure SF_DropItemInSystem(av: array of TVarEC; code: TCodeEC); // @addr 0x61D16C
procedure SF_StopMovingItem(av: array of TVarEC; code: TCodeEC); // @addr 0x61D37C
procedure SF_StarItems(av: array of TVarEC; code: TCodeEC); // @addr 0x61D524
procedure SF_GetItemFromStar(av: array of TVarEC; code: TCodeEC); // @addr 0x61D614
procedure SF_PlanetItems(av: array of TVarEC; code: TCodeEC); // @addr 0x61D7AC
procedure SF_StorageItems(av: array of TVarEC; code: TCodeEC); // @addr 0x61D8BC
procedure SF_StorageItemLocation(av: array of TVarEC; code: TCodeEC); // @addr 0x61D95C
procedure SF_ShopItems(av: array of TVarEC; code: TCodeEC); // @addr 0x61DA20
procedure SF_AddDialogOverride(av: array of TVarEC; code: TCodeEC); // @addr 0x61DD10
procedure SF_AddDialogInject(av: array of TVarEC; code: TCodeEC); // @addr 0x61DF10
procedure SF_InjectAnswer(av: array of TVarEC; code: TCodeEC); // @addr 0x61E1B4
procedure SF_AddDialogBlock(av: array of TVarEC; code: TCodeEC); // @addr 0x61E658
procedure SF_GotoGov(av: array of TVarEC; code: TCodeEC); // @addr 0x61E804
procedure SF_GetShipPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x61E864
procedure SF_GetShipHomePlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x61E914
procedure SF_GetShipRuins(av: array of TVarEC; code: TCodeEC); // @addr 0x61E9A0
procedure SF_GetTalkShip(av: array of TVarEC; code: TCodeEC); // @addr 0x61EA50
procedure SF_GetTalkType(av: array of TVarEC; code: TCodeEC); // @addr 0x61EAE0
procedure SF_TalkByAI(av: array of TVarEC; code: TCodeEC); // @addr 0x61EA8C
procedure SF_ScriptRun(av: array of TVarEC; code: TCodeEC); // @addr 0x61EB20
procedure SF_CreateABShip(av: array of TVarEC; code: TCodeEC); // @addr 0x61F088
procedure SF_ConvertToABShip(av: array of TVarEC; code: TCodeEC); // @addr 0x61F2C0
procedure SF_ABShipModifiers(av: array of TVarEC; code: TCodeEC); // @addr 0x61F670
procedure SF_StartAB(av: array of TVarEC; code: TCodeEC); // @addr 0x61F944
procedure SF_StartTextQuest(av: array of TVarEC; code: TCodeEC); // @addr 0x61EF04 @note "No arguments returns queue length; otherwise queues name and optional success/failure captions, setting GQuestStatus to 1."
procedure SF_StartRobots(av: array of TVarEC; code: TCodeEC); // @addr 0x61FB3C
procedure SF_MarkRobotsMapAsUsed(av: array of TVarEC; code: TCodeEC); // @addr 0x61FD54
procedure SF_ShipOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x61FFE4
procedure SF_ShipPilotRace(av: array of TVarEC; code: TCodeEC); // @addr 0x620114
procedure SF_ShipSkill(av: array of TVarEC; code: TCodeEC); // @addr 0x6201D0
procedure SF_ShipFace(av: array of TVarEC; code: TCodeEC); // @addr 0x620768
procedure SF_ShipFreeExp(av: array of TVarEC; code: TCodeEC); // @addr 0x620A24
procedure SF_GetShipExpByType(av: array of TVarEC; code: TCodeEC); // @addr 0x620AD0
procedure SF_CoordX(av: array of TVarEC; code: TCodeEC); // @addr 0x620C6C @note "Moving a star updates its drawn StarLinks, but not distance caches, sector boundaries or adjacency."
procedure SF_CoordY(av: array of TVarEC; code: TCodeEC); // @addr 0x621204 @note "Moving a star updates its drawn StarLinks, but not distance caches, sector boundaries or adjacency."
procedure SF_ShipSetCoords(av: array of TVarEC; code: TCodeEC); // @addr 0x62179C
procedure SF_ShipAngle(av: array of TVarEC; code: TCodeEC); // @addr 0x621860
procedure SF_ObjectType(av: array of TVarEC; code: TCodeEC); // @addr 0x621934
procedure SF_ShipInHyperSpace(av: array of TVarEC; code: TCodeEC); // @addr 0x621AD8
procedure SF_ShipStatus(av: array of TVarEC; code: TCodeEC); // @addr 0x621BA4
procedure SF_BuyRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x621CC0
procedure SF_BuyWarrior(av: array of TVarEC; code: TCodeEC); // @addr 0x621D70
procedure SF_BuyBigWarrior(av: array of TVarEC; code: TCodeEC); // @addr 0x621E20
procedure SF_BuyDomik(av: array of TVarEC; code: TCodeEC); // @addr 0x621ED4
procedure SF_BuyDomikExtremal(av: array of TVarEC; code: TCodeEC); // @addr 0x621F68
procedure SF_BuyTranclucator(av: array of TVarEC; code: TCodeEC); // @addr 0x622074
procedure SF_TransferShip(av: array of TVarEC; code: TCodeEC); // @addr 0x622124
procedure SF_OrderForsage(av: array of TVarEC; code: TCodeEC); // @addr 0x6224B8
procedure SF_OrderNone(av: array of TVarEC; code: TCodeEC); // @addr 0x62261C
procedure SF_OrderMove(av: array of TVarEC; code: TCodeEC); // @addr 0x622724
procedure SF_OrderTeleport(av: array of TVarEC; code: TCodeEC); // @addr 0x62294C
procedure SF_OrderTakeOff(av: array of TVarEC; code: TCodeEC); // @addr 0x622AF4
procedure SF_OrderFollowShip(av: array of TVarEC; code: TCodeEC); // @addr 0x622B9C
procedure SF_OrderJumpHole(av: array of TVarEC; code: TCodeEC); // @addr 0x622D04
procedure SF_RelationToRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x622E48
procedure SF_RelationToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x623098
procedure SF_StarOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x623188
procedure SF_StarBattle(av: array of TVarEC; code: TCodeEC); // @addr 0x623238
procedure SF_StarSeries(av: array of TVarEC; code: TCodeEC); // @addr 0x6232D0
procedure SF_StarHoles(av: array of TVarEC; code: TCodeEC); // @addr 0x623380
procedure SF_StarNearbyStars(av: array of TVarEC; code: TCodeEC); // @addr 0x6234A0
procedure SF_StarNearbyStarsDist(av: array of TVarEC; code: TCodeEC); // @addr 0x623570
procedure SF_StarSetGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x623644
procedure SF_CreatePlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x623790
procedure SF_PlanetSetGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x6238F0
procedure SF_PlanetGetGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x623AEC
procedure SF_PlanetPopulation(av: array of TVarEC; code: TCodeEC); // @addr 0x623B78
procedure SF_PlanetOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x623C24 @note "Updates planet ownership flags, not the containing star's faction or its other planets."
procedure SF_PlanetRace(av: array of TVarEC; code: TCodeEC); // @addr 0x623CD4
procedure SF_PlanetGov(av: array of TVarEC; code: TCodeEC); // @addr 0x623D78
procedure SF_PlanetEco(av: array of TVarEC; code: TCodeEC); // @addr 0x623E1C
procedure SF_PlanetTerrain(av: array of TVarEC; code: TCodeEC); // @addr 0x623EC0
procedure SF_PlanetTerrainExplored(av: array of TVarEC; code: TCodeEC); // @addr 0x62409C
procedure SF_PlanetOrbitRadius(av: array of TVarEC; code: TCodeEC); // @addr 0x624218
procedure SF_PlanetOrbitalVelocity(av: array of TVarEC; code: TCodeEC); // @addr 0x6242CC
procedure SF_PlanetSize(av: array of TVarEC; code: TCodeEC); // @addr 0x6243A0
procedure SF_PlanetCurInvention(av: array of TVarEC; code: TCodeEC); // @addr 0x62443C
procedure SF_PlanetCurInventionPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x6244E4
procedure SF_PlanetInventionLevel(av: array of TVarEC; code: TCodeEC); // @addr 0x624598
procedure SF_PlanetBoostInventions(av: array of TVarEC; code: TCodeEC); // @addr 0x62465C
procedure SF_PlanetWarriors(av: array of TVarEC; code: TCodeEC); // @addr 0x62471C
procedure SF_GalaxySectors(av: array of TVarEC; code: TCodeEC); // @addr 0x624804
procedure SF_GalaxyTechLevel(av: array of TVarEC; code: TCodeEC); // @addr 0x6248A8
procedure SF_GalaxyDominatorResearchPercent(av: array of TVarEC; code: TCodeEC); // @addr 0x6248EC
procedure SF_GalaxyDominatorResearchMaterial(av: array of TVarEC; code: TCodeEC); // @addr 0x6249C4
procedure SF_GalaxyDiffLevels(av: array of TVarEC; code: TCodeEC); // @addr 0x624A9C
procedure SF_SectorVisible(av: array of TVarEC; code: TCodeEC); // @addr 0x624B44
procedure SF_HullHP(av: array of TVarEC; code: TCodeEC); // @addr 0x624C68
procedure SF_HullDamageSuspectibility(av: array of TVarEC; code: TCodeEC); // @addr 0x6250FC
procedure SF_HullType(av: array of TVarEC; code: TCodeEC); // @addr 0x625268
procedure SF_HullSpecial(av: array of TVarEC; code: TCodeEC); // @addr 0x62539C
procedure SF_HullSeries(av: array of TVarEC; code: TCodeEC); // @addr 0x6254D4
procedure SF_GalaxyHoles(av: array of TVarEC; code: TCodeEC); // @addr 0x625608
procedure SF_HoleCreate2(av: array of TVarEC; code: TCodeEC); // @addr 0x6256A4
procedure SF_HoleStar1(av: array of TVarEC; code: TCodeEC); // @addr 0x6259B4
procedure SF_HoleStar2(av: array of TVarEC; code: TCodeEC); // @addr 0x625A58
procedure SF_HoleX1(av: array of TVarEC; code: TCodeEC); // @addr 0x625AFC
procedure SF_HoleY1(av: array of TVarEC; code: TCodeEC); // @addr 0x625BA8
procedure SF_HoleX2(av: array of TVarEC; code: TCodeEC); // @addr 0x625C54
procedure SF_HoleY2(av: array of TVarEC; code: TCodeEC); // @addr 0x625D00
procedure SF_HoleTurnCreate(av: array of TVarEC; code: TCodeEC); // @addr 0x625DAC
procedure SF_HoleMap(av: array of TVarEC; code: TCodeEC); // @addr 0x625E60
procedure SF_HoleGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x625F4C
procedure SF_StarRuins(av: array of TVarEC; code: TCodeEC); // @addr 0x626098
procedure SF_CreateQuestItem(av: array of TVarEC; code: TCodeEC); // @addr 0x626300
procedure SF_ShipOrder(av: array of TVarEC; code: TCodeEC); // @addr 0x62649C
procedure SF_ShipTurnBeforeEndOrder(av: array of TVarEC; code: TCodeEC); // @addr 0x626408
procedure SF_ShipOrderData1(av: array of TVarEC; code: TCodeEC); // @addr 0x626728
procedure SF_ShipOrderData2(av: array of TVarEC; code: TCodeEC); // @addr 0x6267F8
procedure SF_ShipOrderObj(av: array of TVarEC; code: TCodeEC); // @addr 0x6268C8
procedure SF_ShipDestination(av: array of TVarEC; code: TCodeEC); // @addr 0x6269C4
procedure SF_BuildRuins(av: array of TVarEC; code: TCodeEC); // @addr 0x626B9C
procedure SF_BuildCustomRuins(av: array of TVarEC; code: TCodeEC); // @addr 0x626C60
procedure SF_RuinsChangeType(av: array of TVarEC; code: TCodeEC); // @addr 0x626D74
procedure SF_ShipStanding(av: array of TVarEC; code: TCodeEC); // @addr 0x626EAC
procedure SF_ShipSlots(av: array of TVarEC; code: TCodeEC); // @addr 0x626F5C
procedure SF_MissileStar(av: array of TVarEC; code: TCodeEC); // @addr 0x6270EC
procedure SF_MissileType(av: array of TVarEC; code: TCodeEC); // @addr 0x627170
procedure SF_CustomMissileType(av: array of TVarEC; code: TCodeEC); // @addr 0x6271F4
procedure SF_MissileOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x627280
procedure SF_MissileWeaponID(av: array of TVarEC; code: TCodeEC); // @addr 0x627324
procedure SF_MissileTarget(av: array of TVarEC; code: TCodeEC); // @addr 0x6273AC
procedure SF_MissileMaxDamage(av: array of TVarEC; code: TCodeEC); // @addr 0x627470
procedure SF_MissileMinDamage(av: array of TVarEC; code: TCodeEC); // @addr 0x627518
procedure SF_MissileLive(av: array of TVarEC; code: TCodeEC); // @addr 0x6275C0
procedure SF_MissileSpeed(av: array of TVarEC; code: TCodeEC); // @addr 0x627664
procedure SF_MissileAngle(av: array of TVarEC; code: TCodeEC); // @addr 0x627718
procedure SF_AsteroidMinerals(av: array of TVarEC; code: TCodeEC); // @addr 0x6277CC
procedure SF_AsteroidGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x627874
procedure SF_AsteroidRespawn(av: array of TVarEC; code: TCodeEC); // @addr 0x6279B0
procedure SF_ArrayAdd(Args: array of TVarEC; Code: TCodeEC); // @addr 0x627A3C
procedure SF_ArrayDelete(Args: array of TVarEC; Code: TCodeEC); // @addr 0x627BA4
procedure SF_ArrayClear(Args: array of TVarEC; Code: TCodeEC); // @addr 0x627D1C
procedure SF_ArrayDim(Args: array of TVarEC; Code: TCodeEC); // @addr 0x627E04
procedure SF_ArraySort(Args: array of TVarEC; Code: TCodeEC); // @addr 0x627ED4
procedure SF_ArraySortPartial(Args: array of TVarEC; Code: TCodeEC); // @addr 0x628178
procedure SF_ArrayRandomize(Args: array of TVarEC; Code: TCodeEC); // @addr 0x628430
procedure SF_ArrayFind(Args: array of TVarEC; Code: TCodeEC); // @addr 0x62874C
procedure SF_ArrayFindInSorted(Args: array of TVarEC; Code: TCodeEC); // @addr 0x628A30
procedure SF_DistToNearestEnemySystem(av: array of TVarEC; code: TCodeEC); // @addr 0x628D54
procedure SF_StarEnemyThreatLevel(av: array of TVarEC; code: TCodeEC); // @addr 0x628E64
procedure SF_BuildListOfQuestPossibleLocations(av: array of TVarEC; code: TCodeEC); // @addr 0x629190
procedure SF_FindItemInShip(av: array of TVarEC; code: TCodeEC); // @addr 0x629624
procedure SF_GalaxyRangers(av: array of TVarEC; code: TCodeEC); // @addr 0x629740
procedure SF_MakeShipEnterStar(av: array of TVarEC; code: TCodeEC); // @addr 0x6297DC
procedure SF_ShipGetBad(av: array of TVarEC; code: TCodeEC); // @addr 0x6299B0
procedure SF_ShipAddDropItem(av: array of TVarEC; code: TCodeEC); // @addr 0x629A40
procedure SF_OrderLock(av: array of TVarEC; code: TCodeEC); // @addr 0x62240C
procedure SF_BonusCount(av: array of TVarEC; code: TCodeEC); // @addr 0x629AF4
procedure SF_SeriesCount(av: array of TVarEC; code: TCodeEC); // @addr 0x629B30
procedure SF_BonusPriority(av: array of TVarEC; code: TCodeEC); // @addr 0x629B6C
procedure SF_BonusIsSpecial(av: array of TVarEC; code: TCodeEC); // @addr 0x629C74
procedure SF_BonusName(av: array of TVarEC; code: TCodeEC); // @addr 0x629D78
procedure SF_BonusNumInCfg(av: array of TVarEC; code: TCodeEC); // @addr 0x629E74
procedure SF_SeriesNumInCfg(av: array of TVarEC; code: TCodeEC); // @addr 0x629F98
procedure SF_BonusValue(av: array of TVarEC; code: TCodeEC); // @addr 0x62A0BC
procedure SF_FindBonusByName(av: array of TVarEC; code: TCodeEC); // @addr 0x62A1CC
procedure SF_FindSeriesByName(av: array of TVarEC; code: TCodeEC); // @addr 0x62A2D4
procedure SF_FindBonusByCustomTag(av: array of TVarEC; code: TCodeEC); // @addr 0x62A3E0
procedure SF_FindBonusByNameInCfg(av: array of TVarEC; code: TCodeEC); // @addr 0x62A50C
procedure SF_BonusCustomTag(av: array of TVarEC; code: TCodeEC); // @addr 0x62A618
procedure SF_CreateEquipmentWithSpecial(av: array of TVarEC; code: TCodeEC); // @addr 0x62A76C
procedure SF_SpecialToEquipment(av: array of TVarEC; code: TCodeEC); // @addr 0x62A904
procedure SF_ModuleToEquipment(av: array of TVarEC; code: TCodeEC); // @addr 0x62AD24
procedure SF_EqSpecial(av: array of TVarEC; code: TCodeEC); // @addr 0x62B008
procedure SF_EqModule(av: array of TVarEC; code: TCodeEC); // @addr 0x62B160
procedure SF_MayAddBonusToEq(av: array of TVarEC; code: TCodeEC); // @addr 0x62B2B8
procedure SF_BuildListOfMMByPriority(av: array of TVarEC; code: TCodeEC); // @addr 0x62B458
procedure SF_BuildListOfNewShips(av: array of TVarEC; code: TCodeEC); // @addr 0x62B930
procedure SF_PlanetToStar(av: array of TVarEC; code: TCodeEC); // @addr 0x62C044
procedure SF_Chameleon(av: array of TVarEC; code: TCodeEC); // @addr 0x62C0C8
procedure SF_IsChameleon(av: array of TVarEC; code: TCodeEC); // @addr 0x62C370
procedure SF_PlayerChameleonCharges(av: array of TVarEC; code: TCodeEC); // @addr 0x62C420
procedure SF_PlayerChameleonCurType(av: array of TVarEC; code: TCodeEC); // @addr 0x62C4E4
procedure SF_PlayerChameleonDetected(av: array of TVarEC; code: TCodeEC); // @addr 0x62C58C
procedure SF_PlayerLogicChameleon(av: array of TVarEC; code: TCodeEC); // @addr 0x62C658
procedure SF_SwitchToMirrorImage(av: array of TVarEC; code: TCodeEC); // @addr 0x62C71C
procedure SF_EquipmentImageName(av: array of TVarEC; code: TCodeEC); // @addr 0x62C9C4
procedure SF_StarFonImage(av: array of TVarEC; code: TCodeEC); // @addr 0x62CCCC
procedure SF_ExtremalTakeOff(av: array of TVarEC; code: TCodeEC); // @addr 0x62CD6C
procedure SF_ForceNextDay(av: array of TVarEC; code: TCodeEC); // @addr 0x62CDA0
procedure SF_ScriptActionsRun(av: array of TVarEC; code: TCodeEC); // @addr 0x62CDD4
procedure SF_StarListToPlanetList(av: array of TVarEC; code: TCodeEC); // @addr 0x62CE0C
procedure SF_EndGame(av: array of TVarEC; code: TCodeEC); // @addr 0x62D368
procedure SF_CustomWin(av: array of TVarEC; code: TCodeEC); // @addr 0x62D418
procedure SF_CustomLose(av: array of TVarEC; code: TCodeEC); // @addr 0x62D550
procedure SF_PirateWin(av: array of TVarEC; code: TCodeEC); // @addr 0x62D68C @note "Returns the previous ending; accepts only 1..5 when setting. Does not remove clan objects. Calling at turn zero leaves the ending timestamp zero."
procedure SF_StartVideo(av: array of TVarEC; code: TCodeEC); // @addr 0x62D724
procedure SF_StartMusic(av: array of TVarEC; code: TCodeEC); // @addr 0x62DA84
procedure SF_NoComeKlingToStar(av: array of TVarEC; code: TCodeEC); // @addr 0x62DE78
procedure SF_NoDropToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x62DF44
procedure SF_NoTargetToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x62E00C
procedure SF_NoTalkToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x62E0BC
procedure SF_NoScanToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x62E1C0
procedure SF_NoJump(av: array of TVarEC; code: TCodeEC); // @addr 0x62E2C4
procedure SF_NoLanding(av: array of TVarEC; code: TCodeEC); // @addr 0x62E33C
procedure SF_NoShopUpdate(av: array of TVarEC; code: TCodeEC); // @addr 0x62E488
procedure SF_PlanetExtraFlags(av: array of TVarEC; code: TCodeEC); // @addr 0x62E5C0
procedure SF_NoDropItem(av: array of TVarEC; code: TCodeEC); // @addr 0x62E6AC
procedure SF_CanSellItem(av: array of TVarEC; code: TCodeEC); // @addr 0x62E794
procedure SF_TruceBetweenShips(av: array of TVarEC; code: TCodeEC); // @addr 0x62E88C
procedure SF_ShipInPrison(av: array of TVarEC; code: TCodeEC); // @addr 0x62E9DC
procedure SF_ShipPartners(av: array of TVarEC; code: TCodeEC); // @addr 0x62EB3C
procedure SF_PlayerPirates(av: array of TVarEC; code: TCodeEC); // @addr 0x62EC58
procedure SF_ShipIsPartner(av: array of TVarEC; code: TCodeEC); // @addr 0x62ED08
procedure SF_ShipFreeSpace(av: array of TVarEC; code: TCodeEC); // @addr 0x62EDC4
procedure SF_ShipWealth(av: array of TVarEC; code: TCodeEC); // @addr 0x62EE58
procedure SF_DomiksDefeated(av: array of TVarEC; code: TCodeEC); // @addr 0x62EEE8
procedure SF_CoalitionDefeated(av: array of TVarEC; code: TCodeEC); // @addr 0x62F100
procedure SF_ShipRefuel(av: array of TVarEC; code: TCodeEC); // @addr 0x62F194
procedure SF_ShipRepairEq(av: array of TVarEC; code: TCodeEC); // @addr 0x62F234
procedure SF_ItemInScript(av: array of TVarEC; code: TCodeEC); // @addr 0x62F338
procedure SF_FindPlanetByAdvancement(av: array of TVarEC; code: TCodeEC); // @addr 0x62F480
procedure SF_StarListToTransitPlanetList(av: array of TVarEC; code: TCodeEC); // @addr 0x62F740
procedure SF_GalaxyEvents(av: array of TVarEC; code: TCodeEC); // @addr 0x62FD0C
procedure SF_GalaxyEventDate(av: array of TVarEC; code: TCodeEC); // @addr 0x62FD50
procedure SF_GalaxyEventType(av: array of TVarEC; code: TCodeEC); // @addr 0x62FE18
procedure SF_GalaxyEventData(av: array of TVarEC; code: TCodeEC); // @addr 0x62FEE0
procedure SF_GalaxyEventsTextData(av: array of TVarEC; code: TCodeEC); // @addr 0x62FFE8
procedure SF_PlanetNews(av: array of TVarEC; code: TCodeEC); // @addr 0x630128
procedure SF_PlanetNewsDate(av: array of TVarEC; code: TCodeEC); // @addr 0x63016C
procedure SF_PlanetNewsType(av: array of TVarEC; code: TCodeEC); // @addr 0x630230
procedure SF_PlanetNewsText(av: array of TVarEC; code: TCodeEC); // @addr 0x6302F4
procedure SF_ControlledSystems(av: array of TVarEC; code: TCodeEC); // @addr 0x63041C
procedure SF_DeltaWin(av: array of TVarEC; code: TCodeEC); // @addr 0x630504
procedure SF_ShipInFear(av: array of TVarEC; code: TCodeEC); // @addr 0x6305BC
procedure SF_CreateGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x630660
procedure SF_GetNodesFromShip(av: array of TVarEC; code: TCodeEC); // @addr 0x630724
procedure SF_GetNodesFromStorage(av: array of TVarEC; code: TCodeEC); // @addr 0x6308E0
procedure SF_RangerBaseNodes(av: array of TVarEC; code: TCodeEC); // @addr 0x630A94
procedure SF_RuinsAllowModernization(av: array of TVarEC; code: TCodeEC); // @addr 0x630B44
procedure SF_RuinsMicromoduleChain(av: array of TVarEC; code: TCodeEC); // @addr 0x630C14
procedure SF_DomikKilledInCurSystem(av: array of TVarEC; code: TCodeEC); // @addr 0x630DA4
procedure SF_ShipTypeN(av: array of TVarEC; code: TCodeEC); // @addr 0x630E08
procedure SF_ShipSubType(av: array of TVarEC; code: TCodeEC); // @addr 0x630E90
procedure SF_ShipChangeStar(av: array of TVarEC; code: TCodeEC); // @addr 0x6310BC
procedure SF_IsFilm(av: array of TVarEC; code: TCodeEC); // @addr 0x63119C
procedure SF_FilmFlags(av: array of TVarEC; code: TCodeEC); // @addr 0x6311FC
procedure SF_ShowEffect(av: array of TVarEC; code: TCodeEC); // @addr 0x6313B8
procedure SF_ShowStaticEffect(av: array of TVarEC; code: TCodeEC); // @addr 0x631C5C
procedure SF_ShipConnect(av: array of TVarEC; code: TCodeEC); // @addr 0x631F38
procedure SF_FilmSound(av: array of TVarEC; code: TCodeEC); // @addr 0x632118
procedure SF_FireWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x63236C
procedure SF_WeaponHit(av: array of TVarEC; code: TCodeEC); // @addr 0x6324A4
procedure SF_DealDamageToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x632650
procedure SF_LaunchMissile(av: array of TVarEC; code: TCodeEC); // @addr 0x63278C
procedure SF_SpawnMissile(av: array of TVarEC; code: TCodeEC); // @addr 0x63292C
procedure SF_BonusText(av: array of TVarEC; code: TCodeEC); // @addr 0x632B68
procedure SF_PlanetPirateClan(av: array of TVarEC; code: TCodeEC); // @addr 0x632F38
procedure SF_Blazer(av: array of TVarEC; code: TCodeEC); // @addr 0x632F74
procedure SF_Keller(av: array of TVarEC; code: TCodeEC); // @addr 0x632FB0
procedure SF_Terron(av: array of TVarEC; code: TCodeEC); // @addr 0x632FEC
procedure SF_PirateType(av: array of TVarEC; code: TCodeEC); // @addr 0x633028
procedure SF_PlayerQuestInProgress(av: array of TVarEC; code: TCodeEC); // @addr 0x6330D4
procedure SF_PlayerQuestsCompleted(av: array of TVarEC; code: TCodeEC); // @addr 0x6331A0
procedure SF_QuestsStatusByNom(av: array of TVarEC; code: TCodeEC); // @addr 0x63325C
procedure SF_PlayerPlanetaryBattlesCompleted(av: array of TVarEC; code: TCodeEC); // @addr 0x63342C
procedure SF_PlayerMayTakeSubCrack(av: array of TVarEC; code: TCodeEC); // @addr 0x63346C
procedure SF_SubCrackCost(av: array of TVarEC; code: TCodeEC); // @addr 0x6334C4
procedure SF_ShipCalcParam(av: array of TVarEC; code: TCodeEC); // @addr 0x633504
procedure SF_ShipRefit(av: array of TVarEC; code: TCodeEC); // @addr 0x633580
procedure SF_ShipImproveItems(av: array of TVarEC; code: TCodeEC); // @addr 0x6336A4
procedure SF_ItemImprovement(av: array of TVarEC; code: TCodeEC); // @addr 0x6337F0
procedure SF_ShipFreeFlight(av: array of TVarEC; code: TCodeEC); // @addr 0x633970
procedure SF_ShipKillFactionInCurSystem(av: array of TVarEC; code: TCodeEC); // @addr 0x633A88
procedure SF_CapitalShipStats(av: array of TVarEC; code: TCodeEC); // @addr 0x633C04
procedure SF_PlayerBridge(av: array of TVarEC; code: TCodeEC); // @addr 0x633DB0
procedure SF_PlayerDebt(av: array of TVarEC; code: TCodeEC); // @addr 0x633E90
procedure SF_PlayerDebtDate(av: array of TVarEC; code: TCodeEC); // @addr 0x633EF0
procedure SF_PlayerDebtCnt(av: array of TVarEC; code: TCodeEC); // @addr 0x633F50
procedure SF_PlayerDeposit(av: array of TVarEC; code: TCodeEC); // @addr 0x633FB0
procedure SF_PlayerDepositDate(av: array of TVarEC; code: TCodeEC); // @addr 0x634010
procedure SF_PlayerDepositDay(av: array of TVarEC; code: TCodeEC); // @addr 0x634070
procedure SF_PlayerDepositPercent(av: array of TVarEC; code: TCodeEC); // @addr 0x6340D0
procedure SF_PlayerMedPolicy(av: array of TVarEC; code: TCodeEC); // @addr 0x63415C
procedure SF_ShipCustomShipInfosCount(av: array of TVarEC; code: TCodeEC); // @addr 0x6341BC
procedure SF_ShipAddCustomShipInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x634298
procedure SF_ShipDeleteCustomShipInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x63457C
procedure SF_ShipFindCustomShipInfoByType(av: array of TVarEC; code: TCodeEC); // @addr 0x634784
procedure SF_ShipCustomShipInfoDescription(av: array of TVarEC; code: TCodeEC); // @addr 0x6348C0
procedure SF_ShipCustomShipInfoData(av: array of TVarEC; code: TCodeEC); // @addr 0x634C18
procedure SF_ShipCustomShipInfoTextData(av: array of TVarEC; code: TCodeEC); // @addr 0x634F34
procedure SF_StarCustomStarInfosCount(av: array of TVarEC; code: TCodeEC); // @addr 0x635280
procedure SF_StarAddCustomStarInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x635314
procedure SF_StarDeleteCustomStarInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x6354AC
procedure SF_StarFindCustomStarInfoByType(av: array of TVarEC; code: TCodeEC); // @addr 0x635638
procedure SF_StarCustomStarInfoData(av: array of TVarEC; code: TCodeEC); // @addr 0x635764
procedure SF_ItemCanBeBroken(av: array of TVarEC; code: TCodeEC); // @addr 0x635A40
procedure SF_ItemFragility(av: array of TVarEC; code: TCodeEC); // @addr 0x635B44
procedure SF_ItemDurability(av: array of TVarEC; code: TCodeEC); // @addr 0x635C40
procedure SF_ItemLevel(av: array of TVarEC; code: TCodeEC); // @addr 0x635D98
procedure SF_ContainerFuel(av: array of TVarEC; code: TCodeEC); // @addr 0x63621C
procedure SF_ItemCharge(av: array of TVarEC; code: TCodeEC); // @addr 0x636318
procedure SF_MissilesToRearm(av: array of TVarEC; code: TCodeEC); // @addr 0x6363D4
procedure SF_WeaponAmmunition(av: array of TVarEC; code: TCodeEC); // @addr 0x63655C
procedure SF_WeaponMaxAmmunition(av: array of TVarEC; code: TCodeEC); // @addr 0x636670
procedure SF_ShipSpecialBonuses(av: array of TVarEC; code: TCodeEC); // @addr 0x636784
procedure SF_ItemExtraSpecials(av: array of TVarEC; code: TCodeEC); // @addr 0x6368D4
procedure SF_ItemExtraSpecialsCountByType(av: array of TVarEC; code: TCodeEC); // @addr 0x6369F4
procedure SF_ItemExtraSpecialsAddByType(av: array of TVarEC; code: TCodeEC); // @addr 0x636B18
procedure SF_ItemExtraSpecialsDeleteByType(av: array of TVarEC; code: TCodeEC); // @addr 0x636D2C
procedure SF_ExecuteCodeFromString(av: array of TVarEC; code: TCodeEC); // @addr 0x636EA0
procedure SF_GenerateCodeStringFromBlock(av: array of TVarEC; code: TCodeEC); // @addr 0x637264
procedure SF_ItemOnUseCode(av: array of TVarEC; code: TCodeEC); // @addr 0x6375DC
procedure SF_ItemOnActCode(av: array of TVarEC; code: TCodeEC); // @addr 0x637704
procedure SF_CreateActCodeEvent(av: array of TVarEC; code: TCodeEC); // @addr 0x637908
procedure SF_CurItem(av: array of TVarEC; code: TCodeEC); // @addr 0x637D40
procedure SF_CurInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x637DB0
procedure SF_ScriptItemActShip(av: array of TVarEC; code: TCodeEC); // @addr 0x637E18
procedure SF_ScriptItemActObject1(av: array of TVarEC; code: TCodeEC); // @addr 0x637E80
procedure SF_ScriptItemActObject2(av: array of TVarEC; code: TCodeEC); // @addr 0x637EE8
procedure SF_ScriptItemActParam(av: array of TVarEC; code: TCodeEC); // @addr 0x638034
procedure SF_ScriptItemActionType(av: array of TVarEC; code: TCodeEC); // @addr 0x637F50
procedure SF_OnUseCodeTranclucator(av: array of TVarEC; code: TCodeEC); // @addr 0x6380C8
procedure SF_OnUseCodeTransmitter(av: array of TVarEC; code: TCodeEC); // @addr 0x638654
procedure SF_OnUseCodeBlackHole(av: array of TVarEC; code: TCodeEC); // @addr 0x6389F4
procedure SF_OnUseCodeMissileDef(av: array of TVarEC; code: TCodeEC); // @addr 0x638FAC
procedure SF_MessageBox(av: array of TVarEC; code: TCodeEC); // @addr 0x639168
procedure SF_MessageBoxYesNo(av: array of TVarEC; code: TCodeEC); // @addr 0x63927C
procedure SF_CountBox(av: array of TVarEC; code: TCodeEC); // @addr 0x6393C0
procedure SF_NumberBox(av: array of TVarEC; code: TCodeEC); // @addr 0x6395E0
procedure SF_TextBox(av: array of TVarEC; code: TCodeEC); // @addr 0x6398F8
procedure SF_ListBox(av: array of TVarEC; code: TCodeEC); // @addr 0x639A4C
procedure SF_FormCurShip(av: array of TVarEC; code: TCodeEC); // @addr 0x639C90
procedure SF_UselessItemText(av: array of TVarEC; code: TCodeEC); // @addr 0x639D3C
procedure SF_UselessItemData(av: array of TVarEC; code: TCodeEC); // @addr 0x639EA0
procedure SF_GetAchievementSHU(av: array of TVarEC; code: TCodeEC); // @addr 0x639FDC
procedure SF_GetAchievementGIRLSHIRE(av: array of TVarEC; code: TCodeEC); // @addr 0x63A01C
procedure SF_GetAchievementGIRLSQUEST(av: array of TVarEC; code: TCodeEC); // @addr 0x63A068
procedure SF_GetAchievementPIRATEWIN(av: array of TVarEC; code: TCodeEC); // @addr 0x63A0B8
procedure SF_GetAchievementCOALLITION(av: array of TVarEC; code: TCodeEC); // @addr 0x63A104
procedure SF_GetAchievementHULL(av: array of TVarEC; code: TCodeEC); // @addr 0x63A154
procedure SF_UICheckElement(av: array of TVarEC; code: TCodeEC); // @addr 0x63A198
procedure SF_InterfaceState(av: array of TVarEC; code: TCodeEC); // @addr 0x63AE2C
procedure SF_InterfaceText(av: array of TVarEC; code: TCodeEC); // @addr 0x63B1D0
procedure SF_InterfaceImage(av: array of TVarEC; code: TCodeEC); // @addr 0x63B5B0
procedure SF_InterfacePos(av: array of TVarEC; code: TCodeEC); // @addr 0x63BC64
procedure SF_InterfaceSize(av: array of TVarEC; code: TCodeEC); // @addr 0x63BF80
procedure SF_ButtonClick(av: array of TVarEC; code: TCodeEC); // @addr 0x63C264
procedure SF_SetFocus(av: array of TVarEC; code: TCodeEC); // @addr 0x63C580
procedure SF_CurrentForm(av: array of TVarEC; code: TCodeEC); // @addr 0x63CEEC
procedure SF_FormShipCurItem(av: array of TVarEC; code: TCodeEC); // @addr 0x63C710
procedure SF_UpdateFormShip(av: array of TVarEC; code: TCodeEC); // @addr 0x63CE78
procedure SF_FormChange(av: array of TVarEC; code: TCodeEC); // @addr 0x63CF28
procedure SF_RunChildForm(av: array of TVarEC; code: TCodeEC); // @addr 0x63D1D4
procedure SF_OpenCustomForm(av: array of TVarEC; code: TCodeEC); // @addr 0x63D54C
procedure SF_CloseCustomForm(av: array of TVarEC; code: TCodeEC); // @addr 0x63D610
procedure SF_CustomInterfaceState(av: array of TVarEC; code: TCodeEC); // @addr 0x63D6C0
procedure SF_CustomInterfaceText(av: array of TVarEC; code: TCodeEC); // @addr 0x63D8C8
procedure SF_CustomInterfaceImage(av: array of TVarEC; code: TCodeEC); // @addr 0x63DC48
procedure SF_CustomInterfacePos(av: array of TVarEC; code: TCodeEC); // @addr 0x63E1DC
procedure SF_CustomInterfacePosZ(av: array of TVarEC; code: TCodeEC); // @addr 0x63E37C
procedure SF_CustomInterfaceSize(av: array of TVarEC; code: TCodeEC); // @addr 0x63E514
procedure SF_StarMapCenterView(av: array of TVarEC; code: TCodeEC); // @addr 0x63E6B4
procedure SF_StarMapCurPosX(av: array of TVarEC; code: TCodeEC); // @addr 0x63E85C
procedure SF_StarMapCurPosY(av: array of TVarEC; code: TCodeEC); // @addr 0x63E8A4
procedure SF_StarMapCustomSelectionMode(av: array of TVarEC; code: TCodeEC); // @addr 0x63E8EC
procedure SF_StarMapBlinkingMessage(av: array of TVarEC; code: TCodeEC); // @addr 0x63EB30
procedure SF_CustomWeaponTypes(av: array of TVarEC; code: TCodeEC); // @addr 0x63EDEC
procedure SF_InventNewCustomWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x63EE94
procedure SF_GetCustomWeaponInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x63F1BC
procedure SF_GetCustomWeaponData(av: array of TVarEC; code: TCodeEC); // @addr 0x63F288
procedure SF_GetCustomWeaponPrimaryDamageType(av: array of TVarEC; code: TCodeEC); // @addr 0x63FB94
procedure SF_SetCustomWeaponAvailability(av: array of TVarEC; code: TCodeEC); // @addr 0x63FCB4
procedure SF_SetCustomWeaponSE(av: array of TVarEC; code: TCodeEC); // @addr 0x640850
procedure SF_SetCustomWeaponPrimaryData(av: array of TVarEC; code: TCodeEC); // @addr 0x63FFD0
procedure SF_SetCustomWeaponSizeAndCost(av: array of TVarEC; code: TCodeEC); // @addr 0x640114
procedure SF_SetCustomWeaponDamageData(av: array of TVarEC; code: TCodeEC); // @addr 0x6401C8
procedure SF_SetCustomWeaponShotData(av: array of TVarEC; code: TCodeEC); // @addr 0x640484
procedure SF_SetCustomMissileWeaponStats(av: array of TVarEC; code: TCodeEC); // @addr 0x640774
procedure SF_StarCustomFaction(av: array of TVarEC; code: TCodeEC); // @addr 0x64097C
procedure SF_ShipCustomFaction(av: array of TVarEC; code: TCodeEC); // @addr 0x640A84
procedure SF_EqCustomFaction(av: array of TVarEC; code: TCodeEC); // @addr 0x640C4C
procedure SF_PlanetCustomFaction(av: array of TVarEC; code: TCodeEC); // @addr 0x640D2C
procedure SF_ImportedFunction(av: array of TVarEC; code: TCodeEC); // @addr 0x640E14
procedure SF_ImportAll(av: array of TVarEC; code: TCodeEC); // @addr 0x640F44
procedure SF_GalaxyPtr(av: array of TVarEC; code: TCodeEC); // @addr 0x641030

procedure SF_MusicControls(av: array of TVarEC; code: TCodeEC); // @addr 0x62DC14
procedure SF_BlinkingWarning(av: array of TVarEC; code: TCodeEC); // @addr 0x63EBF0
procedure InitializeScriptBuiltinsAndConstants(Scope: TVarArrayEC); // @addr 0x641194

// Nested helpers; ParentFrame is the compiler-supplied, caller-popped static link.

implementation

uses Classes, SysUtils, aMyFunction, aConst, aScript, aGalaxy, Globals,
  GlobalsV, GI_MessageLoop, aPlanet, aPlayer, aNormalShip, aGalaxyStruct,
  aMissile, aAsteroid, aWarrior, aRuins, EC_Str, GR_Main, ThreadCalc,
  fTalk, fGov, fRuinsTalk, aRanger, fShip2, GI_XviD,
  GR_Music, Windows, MMSystem, Math, aKling, SE_Space, SE_Planet, EC_Struct, SE_Hole, aEFilm, fStarMap, fEquipmentShop, GR_Sound, aTranclucator, aPirate, aGalaxyEvent, aTransport, Robot, EC_Mem, GI_MessageBox, Achievements, fHangar, fScaner,
  aEFilmEnd, SE_Weapon, SE_GAIEffect, SE_Process, ab_Ship, ab_ShipAI, ab_W, SE_Ruins, GI_GraphButton, GI_Label, GI_Edit, GI_GAI, GI_GI, GI_Image, fTextBox, fListBox, fCount1, fCount2, fCustom, SE_Ship2, fScore, fAbout, fPanelMain, fGoodsShop2, fGalaxy2, GI_GraphBuf;

{ @routine $605480 SF_GRun }
procedure SF_GRun(av: array of TVarEC; code: TCodeEC);
begin
  ScriptTemplateStartRequested := True;
end;
{ @end $605480 }

{ @routine $6054B4 SF_GCntRun }
procedure SF_GCntRun(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script SF_GCntRun');
  Index := FindScriptTemplateIndex(av[1].GetString);
  if Index < 0 then raise Exception.Create('Error.Script.NotFound SF_GCntRun');
  av[0].SetInt(TScriptTemplUnit(ScriptTemplates[Index]).UseCount);
end;
{ @end $6054B4 }

{ @routine $6055C8 SF_GLastTurnRun }
procedure SF_GLastTurnRun(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_GCntRun');
  Index := FindScriptTemplateIndex(av[1].GetString);
  if Index < 0 then raise Exception.Create('Error.Script.NotFound SF_GLastTurnRun');
  if (High(av) >= 2) and (TScriptTemplUnit(ScriptTemplates[Index]).UseCount < 1) then
    av[0].SetInt(av[2].GetInt)
  else
    av[0].SetInt(TScriptTemplUnit(ScriptTemplates[Index]).LastTurn);
end;
{ @end $6055C8 }

{ @routine $605714 SF_GAllCntRun }
procedure SF_GAllCntRun(av: array of TVarEC; code: TCodeEC);
var
  Count, ClassId, I: Integer;
begin
  if High(av) >= 1 then
  begin
    ClassId := av[1].GetInt;
    Count := 0;
    for I := 0 to Galaxy.Scripts.Count - 1 do
      if TScript(Galaxy.Scripts[I]).ClassId = ClassId then Inc(Count);
    av[0].SetInt(Count);
  end
  else av[0].SetInt(Galaxy.Scripts.Count);
end;
{ @end $605714 }

{ @routine $6057C8 SF_IsScriptActive }
procedure SF_IsScriptActive(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script IsScriptActive');
  av[0].SetInt(0);
  Index := FindScriptTemplateIndex(av[1].GetString);
  if Index >= 0 then
    av[0].SetInt(Ord(TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex >= 0));
end;
{ @end $6057C8 }

{ @routine $6058B0 SF_GetValueFromScript }
procedure SF_GetValueFromScript(av: array of TVarEC; code: TCodeEC);
var
  Index, LastArg: Integer;
  Script: TScript;
  Value: TVarEC;
begin
  LastArg := High(av);
  if LastArg < 2 then raise Exception.Create('Error.Script GetValueFromScript');
  if av[1].GetString = '' then
  begin
    Value := ScriptFunctionScope.GetVarNE(av[2].GetString);
    if Value = nil then
      raise Exception.Create('Error.Script GetValueFromScript - var ' + av[2].GetString + ' not found');
  end
  else
  begin
    Index := FindScriptTemplateIndex(av[1].GetString);
    if Index < 0 then Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then Exit;
    Script := TScript(Galaxy.Scripts[Index]);
    Value := Script.InitCode.LocalVar.GetVarNE(av[2].GetString);
    if Value = nil then Value := Script.TurnCode.LocalVar.GetVarNE(av[2].GetString);
    if Value = nil then Value := ScriptFunctionScope.GetVarNE(av[2].GetString);
    if Value = nil then
      raise Exception.Create('Error.Script GetValueFromScript - var ' + av[2].GetString +
        ' not found in script ' + av[1].GetString);
  end;
  Index := 2;
  while (Value.RealVType = vkArray) and (Index < LastArg) do
  begin
    Inc(Index);
    if av[Index].RealVType = vkString then
      Value := Value.GetArray.GetVar(av[Index].GetString)
    else
      Value := Value.GetArray.GetItem(av[Index].GetInt);
  end;
  case Value.RealVType of
    vkInt: av[0].SetInt(Value.GetInt);
    vkDword: av[0].SetDword(Value.GetDword);
    vkFloat: av[0].SetFloat(Value.GetFloat);
    vkString: av[0].SetString(Value.GetString);
    vkArray: av[0].SetInt(Value.GetArray.Count);
  end;
end;
{ @end $6058B0 }

{ @routine $605D18 SF_RunFunctionFromScript }
procedure SF_RunFunctionFromScript(av: array of TVarEC; code: TCodeEC);
var
  Index, LastArg, I: Integer;
  Script, SavedScript: TScript;
  Value: TVarEC;
  Name: WideString;
  CallCode: TCodeEC;
begin
  LastArg := High(av);
  if LastArg < 2 then raise Exception.Create('Error.Script RunFunctionFromScript');
  Index := FindScriptTemplateIndex(av[1].GetString);
  if Index < 0 then Exit;
  Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
  if Index < 0 then Exit;
  Script := TScript(Galaxy.Scripts[Index]);
  Name := 'g_' + av[2].GetString;
  Value := Script.InitCode.LocalVar.GetVarNE(Name);
  if Value = nil then Value := Script.TurnCode.LocalVar.GetVarNE(Name);
  if (Value = nil) or (Value.RealVType <> vkFunction) then
    raise Exception.Create('Error.Script RunFunctionFromScript - function ' + Name +
      ' not found in script ' + av[1].GetString);
  CallCode := TCodeEC.Create;
  CallCode.CopyFromFast(Value.GetFunction);
  for I := 3 to LastArg do
    if CallCode.LocalVar.GetItem(I - 3).Kind = vkRef then
      CallCode.LocalVar.GetItem(I - 3).SetRef(av[I])
    else
      CallCode.LocalVar.GetItem(I - 3).Assume(av[I], False);
  SavedScript := CurrentScript;
  try
    CallCode.LocalVar.GetVar('result').SetRef(av[0]);
    CurrentScript := Script;
    CallCode.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do
    begin
      CallCode.Free;
      raise;
    end;
    on E: Exception do
      raise ExceptionExpressionEC.Create('Error in function ' + Value.Name +
        ' (' + E.ClassName + ' ' + E.Message + ')');
  end;
  { Native exceptions bypass context restoration; only EBreakMessageGI frees CallCode. }
  CurrentScript := SavedScript;
  CallCode.Free;
end;
{ @end $605D18 }

{ @routine $6061E4 SF_GetVariableName }
procedure SF_GetVariableName(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetVariableName');
  av[0].SetString(av[1].Name);
end;
{ @end $6061E4 }

{ @routine $606268 SF_GetVariableType }
procedure SF_GetVariableType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetVariableType');
  av[0].SetInt(Ord(av[1].RealVType));
end;
{ @end $606268 }

{ @routine $6062F0 SF_AddPlanetNews }
procedure SF_AddPlanetNews(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AddPlanetNews');
  if High(av) > 1 then Galaxy.AddPlanetNews(TGalaxyNewsKind(av[2].GetInt), av[1].GetString)
  else Galaxy.AddPlanetNews(gnScript, av[1].GetString);
end;
{ @end $6062F0 }

{ @routine $6063E8 SF_AddJournalRecord }
procedure SF_AddJournalRecord(av: array of TVarEC; code: TCodeEC);
var
  Entry: TJournalRecord;
  I, Turn: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AddJournalRecord');
  if High(av) = 1 then GetPlayer.AddJournalRecord(av[1].GetString)
  else
  begin
    Turn := av[2].GetInt;
    Entry := TJournalRecord.Create;
    Entry.Text := av[1].GetString;
    Entry.DateTurn := Turn;
    if (GetPlayer.JournalRecords.Count <= 0) or
      (TJournalRecord(GetPlayer.JournalRecords[GetPlayer.JournalRecords.Count - 1]).DateTurn <= Turn) then
    begin
      GetPlayer.JournalRecords.Add(Entry);
      Exit;
    end;
    for I := GetPlayer.JournalRecords.Count - 2 downto 0 do
      if TJournalRecord(GetPlayer.JournalRecords[I]).DateTurn <= Turn then
      begin
        GetPlayer.JournalRecords.Insert(I + 1, Entry);
        Exit;
      end;
    GetPlayer.JournalRecords.Insert(0, Entry);
  end;
end;
{ @end $6063E8 }

{ @routine $6065B4 SF_AutoBattle }
procedure SF_AutoBattle(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script AutoBattle');
  PendingPlayerFollowTarget := TShip(av[1].GetDword);
end;
{ @end $6065B4 }

{ @routine $606630 SF_GetOwner }
procedure SF_GetOwner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Owner: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script SF_GetOwner');
  Ship := TShip(av[1].GetDword);
  Owner := Ord(Ship.OwnerId);
  av[0].SetInt(Owner);
end;
{ @end $606630 }

{ @routine $6066C0 SF_GiveReward }
procedure SF_GiveReward(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Owner: TOwnerId; Kind: TAwardKind;
  Award: Integer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script SF_GiveReward');
  Ship := TShip(av[1].GetDword);
  Owner := TOwnerId(av[2].GetInt);
  Kind := TAwardKind(av[3].GetInt);
  Award := (Ship as TNormalShip).SelectAward(Owner, [Kind], [stKling..Ord(rstCustomStation)]);
  if Award = AwardNotFound then RaiseWideMessage('Error RewardNumber=255');
  Ship.AddAward(Award);
  av[0].SetInt(Award);
end;
{ @end $6066C0 }

{ @routine $6067F0 SF_GiveRewardByNom }
procedure SF_GiveRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_GiveRewardByNom');
  Ship := TShip(av[1].GetDword);
  Ship.AddAward(av[2].GetInt);
end;
{ @end $6067F0 }

{ @routine $606884 SF_CountReward }
procedure SF_CountReward(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TAwardKind;
  Index, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_CountReward');
  Ship := TShip(av[1].GetDword);
  if High(av) = 1 then
  begin
    if (Ship.AwardIds = nil) or (Ship.AwardIds.Count = 0) then
    begin
      av[0].SetString('');
      Exit;
    end;
    av[0].SetString(IntToWideString(Integer(Ship.AwardIds[0])));
    for Index := 1 to Ship.AwardIds.Count - 1 do
      av[0].SetString(av[0].GetString + ',' + IntToWideString(Integer(Ship.AwardIds[Index])));
  end
  else
  begin
    Kind := TAwardKind(av[2].GetInt);
    if Ship.AwardIds = nil then
    begin
      av[0].SetInt(0);
      Exit;
    end;
    Count := 0;
    for Index := 0 to Ship.AwardIds.Count - 1 do
      if SysToReward(LookupLocalizedTextByKey('Reward.' + SysUtils.IntToStr(Integer(Ship.AwardIds[Index])) + '.Type')) = Kind then Inc(Count);
    av[0].SetInt(Count);
  end;
end;
{ @end $606884 }

{ @routine $606B08 SF_CountRewardByNom }
procedure SF_CountRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Count, Award: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_CountRewardByNom');
  Ship := TShip(av[1].GetDword);
  Award := av[2].GetInt;
  if Ship.AwardIds = nil then
  begin
    av[0].SetInt(0);
    Exit;
  end;
  Count := 0;
  for Index := 0 to Ship.AwardIds.Count - 1 do
    if Integer(Ship.AwardIds[Index]) = Award then Inc(Count);
  av[0].SetInt(Count);
end;
{ @end $606B08 }

{ @routine $606C00 SF_DeleteRewardByNom }
procedure SF_DeleteRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Count, Award: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_DeleteRewardByNom');
  Ship := TShip(av[1].GetDword);
  Award := av[2].GetInt;
  if High(av) > 2 then Count := av[3].GetInt else Count := 1;
  av[0].SetInt(0);
  if Ship.AwardIds <> nil then
    for Index := Ship.AwardIds.Count - 1 downto 0 do
      if (Integer(Ship.AwardIds[Index]) = Award) or (Award = -1) then
      begin
        Ship.AwardIds.Delete(Index);
        av[0].SetInt(av[0].GetInt + 1);
        if av[0].GetInt >= Count then Break;
      end;
end;
{ @end $606C00 }

{ @routine $606D34 SF_ShipPicksItem }
procedure SF_ShipPicksItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ShipPicksItem');
  Ship := TShip(av[1].GetDword);
  Item := TItem(av[2].GetDword);
  if High(av) = 2 then
  begin
    if Ship.HasPickupTarget(Item) then av[0].SetInt(1)
    else if Ship.IsRecentlyDroppedItem(Item) then av[0].SetInt(-1)
    else av[0].SetInt(0);
  end
  else if av[3].GetInt > 0 then
  begin
    Ship.AddPickupTarget(Item, False);
    if Ship.IsRecentlyDroppedItem(Item) then Ship.RecentlyDroppedItemIds.Delete(Ship.RecentlyDroppedItemIds.IndexOf(Item));
  end
  else if av[3].GetInt < 0 then
  begin
    Ship.RemovePickupTarget(Item);
    Ship.AddRecentlyDroppedItem(Item);
  end
  else
  begin
    Ship.RemovePickupTarget(Item);
    if Ship.IsRecentlyDroppedItem(Item) then Ship.RecentlyDroppedItemIds.Delete(Ship.RecentlyDroppedItemIds.IndexOf(Item));
  end;
end;
{ @end $606D34 }

{ @routine $606ED0 SF_DropItem }
procedure SF_DropItem(av: array of TVarEC; code: TCodeEC);
label Done;
var
  Ship: TShip;
  Item: TEquipment;
  Kind: Byte;
  Index, SavedNoDrop: Integer;
  Found: Boolean;
  Equipped: Byte;
  Binding: TScriptItem;
begin
  Found := False;
  if High(av) < 2 then raise Exception.Create('Error.Script SF_DropItem');
  Ship := TShip(av[1].GetDword);
  if (av[2].RealVType = vkDword) and (av[2].GetDword > $10000) then
  begin
    Item := TEquipment(av[2].GetDword);
    if High(av) >= 3 then
    begin
      Binding := TScriptItem(av[3].GetDword);
      if Binding.Item <> nil then Binding.Item.ScriptItem := nil;
      Binding.Item := Item;
      Item.ScriptItem := Binding;
    end;
    SavedNoDrop := Item.NoDropFlag;
    Item.NoDropFlag := 0;
    Ship.DropItemIntoStar(Item);
    if Ship.CurrentStar.Items.IndexOf(Item) >= 0 then Item.NoDropFlag := SavedNoDrop;
    Found := True;
  end
  else
  begin
    Kind := av[2].GetInt;
    Equipped := 0;
    if High(av) >= 3 then Equipped := av[3].GetInt;
    for Index := 0 to Ship.Inventory.Count - 1 do
    begin
      Item := TEquipment(Ship.Inventory[Index]);
      if (Byte(Item.ItemType) = Kind) and (Item.EquippedFlag = Equipped) then
      begin
        if High(av) >= 4 then
        begin
          Binding := TScriptItem(av[4].GetDword);
          if Binding.Item <> nil then Binding.Item.ScriptItem := nil;
          Binding.Item := Item;
          Item.ScriptItem := Binding;
        end;
        SavedNoDrop := Item.NoDropFlag;
        Item.NoDropFlag := 0;
        Ship.DropItemIntoStar(Item);
        if Ship.CurrentStar.Items.IndexOf(Item) >= 0 then Item.NoDropFlag := SavedNoDrop;
        Found := True;
        goto Done;
      end;
    end;
    for Index := 0 to Ship.Artefacts.Count - 1 do
    begin
      Item := TEquipment(Ship.Artefacts[Index]);
      if (Byte(Item.ItemType) = Kind) and (Item.EquippedFlag = Equipped) then
      begin
        if High(av) >= 4 then
        begin
          Binding := TScriptItem(av[4].GetDword);
          if Binding.Item <> nil then Binding.Item.ScriptItem := nil;
          Binding.Item := Item;
          Item.ScriptItem := Binding;
        end;
        SavedNoDrop := Item.NoDropFlag;
        Item.NoDropFlag := 0;
        Ship.DropItemIntoStar(Item);
        if Ship.CurrentStar.Items.IndexOf(Item) >= 0 then Item.NoDropFlag := SavedNoDrop;
        Found := True;
        Break;
      end;
    end;
  end;
  Done:
  if not Found then raise Exception.Create('Error.Script SF_DropItem - item not found');
end;
{ @end $606ED0 }

{ @routine $607224 SF_DropScriptItem }
procedure SF_DropScriptItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptItem;
  SavedNoDrop: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script DropScriptItem');
  Ship := TShip(av[1].GetDword);
  Binding := TScriptItem(av[2].GetDword);
  if (Binding.Item <> nil) and ((Ship.Inventory.IndexOf(Binding.Item) >= 0) or (Ship.Artefacts.IndexOf(Binding.Item) >= 0)) and Ship.InNormalSpace then
  begin
    SavedNoDrop := Binding.Item.NoDropFlag;
    Binding.Item.NoDropFlag := 0;
    Ship.DropItemIntoStar(Binding.Item);
    if Binding.Item <> nil then Binding.Item.NoDropFlag := SavedNoDrop;
  end;
end;
{ @end $607224 }

{ @routine $60732C SF_DeleteEquipment }
procedure SF_DeleteEquipment(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
  Item: TItem;
  Kind: Byte;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script SF_DeleteEquipment');
  Ship := TShip(av[1].GetDword);
  Index := 0;
  Kind := av[2].GetInt;
  while Index < Ship.Inventory.Count do
  begin
    Item := TItem(Ship.Inventory[Index]);
    if (Item.ScriptItem = nil) and (Byte(Item.ItemType) = Kind) then
    begin
      Ship.Inventory.Delete(Index);
      Item.Free;
    end
    else Inc(Index);
  end;
  Ship.RefreshDerivedStats(True);
end;
{ @end $60732C }

{ @routine $607420 SF_Rnd }
procedure SF_Rnd(av: array of TVarEC; code: TCodeEC);
var
  LowValue, HighValue: Integer;
  Seed: Cardinal;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script Rnd');
  if High(av) > 2 then
  begin
    Seed := av[3].GetDword;
    av[0].SetInt(NextRandomIntRange(av[1].GetInt, av[2].GetInt, Seed));
  end
  else if Galaxy <> nil then
    av[0].SetInt(NextRandomIntRange(av[1].GetInt, av[2].GetInt, Galaxy.RandomState))
  else
  begin
    LowValue := av[1].GetInt;
    HighValue := av[2].GetInt;
    av[0].SetInt(LowValue + Random(HighValue - LowValue + 1));
  end;
end;
{ @end $607420 }

{ @routine $60753C SF_GameDateTxtByTurn }
procedure SF_GameDateTxtByTurn(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GameDateTxtByTurn');
  av[0].SetString(FormatGameTurnDate(av[1].GetInt));
end;
{ @end $60753C }

{ @routine $6075FC SF_StatusPlayer }
procedure SF_StatusPlayer(av: array of TVarEC; code: TCodeEC);
begin
  case GetPlayer.GetDominantCareer of
    rcTrader: av[0].SetInt(1);
    rcWarrior: av[0].SetInt(0);
    rcPirate: av[0].SetInt(-1);
  end;
end;
{ @end $6075FC }

{ @routine $607668 SF_Id }
procedure SF_Id(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script SF_Id');
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then av[0].SetDword(TShip(Obj).Id)
  else if Obj is TPlanet then av[0].SetDword(TPlanet(Obj).Id)
  else if Obj is TStar then av[0].SetDword(TStar(Obj).Id)
  else if Obj is TConstellation then av[0].SetDword(TConstellation(Obj).Id)
  else if Obj is TItem then av[0].SetDword(TItem(Obj).Id)
  else if Obj is THole then av[0].SetDword(THole(Obj).Id)
  else if Obj is TMissile then av[0].SetDword(TMissile(Obj).Id)
  else if Obj is TAsteroid then av[0].SetDword(TAsteroid(Obj).Id)
  else raise Exception.Create('Error.Script SF_Id 2');
end;
{ @end $607668 }

{ @routine $607840 SF_GalaxyMoney }
procedure SF_GalaxyMoney(av: array of TVarEC; code: TCodeEC);
var
  Owner: TOwnerId;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_GalaxyMoney');
  Owner := oiHuman;
  if High(av) >= 2 then Owner := TOwnerId(av[2].GetInt);
  case av[1].GetInt of
    0: av[0].SetInt(Galaxy.ComputeScaledMiniMoney(Owner));
    1: av[0].SetInt(Galaxy.ComputeScaledSmallMoney(Owner));
    2: av[0].SetInt(Galaxy.ComputeScaledAverageMoney(Owner));
    3: av[0].SetInt(Galaxy.ComputeScaledBigMoney(Owner));
    4: av[0].SetInt(Galaxy.ComputeScaledHugeMoney(Owner));
  else raise Exception.Create('Error.Script SF_GalaxyMoney');
  end;
end;
{ @end $607840 }

{ @routine $60799C SF_SetName }
procedure SF_SetName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script SF_SetName');
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then TShip(Obj).Name := av[2].GetString
  else if Obj is TPlanet then TPlanet(Obj).Name := av[2].GetString
  else if Obj is TStar then TStar(Obj).Name := av[2].GetString
  else if Obj is TItem then TItem(Obj).NameOverride := av[2].GetString;
end;
{ @end $60799C }

{ @routine $607B10 SF_UseTranclucator }
procedure SF_UseTranclucator(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Obj: TObject;
  Artefact: TArtefactTranclucator;
  Drone: TTranclucator;
  Index: Integer;
  Angle: Single;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_UseTranclucator');
  av[0].SetDword(0);
  Ship := TShip(av[1].GetDword);
  if not Ship.InHyperspace then
  begin
    Obj := nil;
    if High(av) > 1 then Obj := TObject(av[2].GetDword)
    else
      for Index := 0 to Ship.Artefacts.Count - 1 do
      begin
        Obj := Ship.Artefacts[Index];
        if (Obj is TArtefactTranclucator) and (TArtefactTranclucator(Obj).BrokenFlag = 0) then Break;
      end;
    if (Obj <> nil) and (Obj is TArtefactTranclucator) then
    begin
      Artefact := Obj as TArtefactTranclucator;
      Drone := Artefact.Ship;
      Artefact.Ship := nil;
      Drone.CurrentStar := Ship.CurrentStar;
      Ship.CurrentStar.Ships.Add(Drone);
      if Ship.InNormalSpace then
      begin
        Angle := SeededRandomIntRange(0, 360, Drone.Id * (Ship.CurrentStar.GenerationSeed * Cardinal(Galaxy.CurrentTurn))) * Pi / 180;
        Drone.Position.X := Sin(Angle) * 100 + Ship.Position.X;
        Drone.Position.Y := Ship.Position.Y - Cos(Angle) * 100;
      end
      else if Ship.CurrentPlanet <> nil then Drone.CurrentPlanet := Ship.CurrentPlanet
      else if Ship.DockedTo <> nil then Drone.DockedTo := Ship.DockedTo;
      Drone.Graphic.SetPosition(Drone.Position);
      Drone.OwnerShip := Ship;
      Index := Ship.Artefacts.IndexOf(Artefact);
      if Index >= 0 then Ship.Artefacts.Delete(Index);
      Index := Ship.Inventory.IndexOf(Artefact);
      if Index >= 0 then Ship.Inventory.Delete(Index);
      Artefact.Free;
      Ship.RefreshDerivedStats(True);
      Drone.NextDay;
      av[0].SetDword(Cardinal(Drone));
    end;
  end;
end;
{ @end $607B10 }

{ @routine $607DE8 SF_HullDamage }
procedure SF_HullDamage(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script HullDamage');
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is TScriptItem then Hull := THull(TScriptItem(Obj).Item)
  else Hull := THull(Obj);
  av[0].SetInt(100 - Round(Hull.HullPoints / Hull.Weight * 100));
end;
{ @end $607DE8 }

{ @routine $607ECC SF_Hitpoints }
procedure SF_Hitpoints(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Hitpoints');
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is TScriptItem then Hull := THull(TScriptItem(Obj).Item)
  else Hull := THull(Obj);
  av[0].SetInt(Hull.HullPoints);
end;
{ @end $607ECC }

{ @routine $607F94 SF_Hit }
procedure SF_Hit(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
begin
  if High(av) < 1 then Ship := CurrentScript.CurrentShip else Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    Binding := GetScriptShipBindingForContext(Ship, CurrentScript);
    if High(av) < 2 then av[0].SetInt(Ord(Binding.Hit or Binding.HitPlayer))
    else if av[2].GetInt <> 0 then
    begin
      av[0].SetInt(Ord(Binding.HitPlayer));
      if High(av) > 2 then Binding.HitPlayer := av[3].GetInt <> 0;
    end
    else
    begin
      av[0].SetInt(Ord(Binding.Hit));
      if High(av) > 2 then Binding.Hit := av[3].GetInt <> 0;
    end;
  end;
end;
{ @end $607F94 }

{ @routine $608098 SF_ChangeGlobalRelationsShips }
procedure SF_ChangeGlobalRelationsShips(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Mode: TRelationChangeMode;
  ShipTypes: THullShipTypeMask;
  Owners: TOwnerMask;
begin
  if High(av) <> 6 then raise Exception.Create('Error.Script ChangeGlobalRelationsShips');
  if av[1].GetDword = 0 then Exit;
  Ranger := TObject(av[1].GetDword);
  if (Ranger <> nil) and (Ranger is TRanger) then
  begin
    if (av[2].GetDword > 0) and (av[2].GetDword < $FF) then
      Scope := TScriptConstellation(CurrentScript.Constellations[av[2].GetDword]).Constellation
    else if av[2].GetDword <> 0 then Scope := TObject(av[2].GetDword)
    else Scope := nil;
    case av[3].GetDword of
      0: Mode := rcmCapAt;
      1: Mode := rcmRaiseTo;
      2: Mode := rcmIncrease;
      3: Mode := rcmDecrease;
    else Mode := rcmCapAt;
    end;
    ShipTypes := THullShipTypeMask(Word(av[5].GetDword));
    Owners := TOwnerMask(Byte(av[6].GetDword));
    TRanger(Ranger).ChangeShipRelations(Scope, Mode, av[4].GetInt, ShipTypes, Owners);
  end;
end;
{ @end $608098 }

{ @routine $608230 SF_ChangeGlobalRelationsPlanets }
procedure SF_ChangeGlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Mode: TRelationChangeMode;
  Owners: TOwnerMask;
begin
  if High(av) <> 5 then raise Exception.Create('Error.Script ChangeGlobalRelationsPlanets');
  Ranger := TObject(av[1].GetDword);
  if (Ranger <> nil) and (Ranger is TRanger) then
  begin
    if (av[2].GetDword > 0) and (av[2].GetDword < $FF) then
      Scope := TScriptConstellation(CurrentScript.Constellations[av[2].GetDword]).Constellation
    else if av[2].GetDword <> 0 then Scope := TObject(av[2].GetDword)
    else Scope := nil;
    case av[3].GetDword of
      0: Mode := rcmCapAt;
      1: Mode := rcmRaiseTo;
      2: Mode := rcmIncrease;
      3: Mode := rcmDecrease;
    else Mode := rcmCapAt;
    end;
    Owners := TOwnerMask(Byte(av[5].GetDword));
    TRanger(Ranger).ChangePlanetRelations(Scope, Mode, av[4].GetInt, Owners);
  end;
end;
{ @end $608230 }

{ @routine $6083A4 SF_GlobalRelationsShips }
procedure SF_GlobalRelationsShips(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  ShipTypes: THullShipTypeMask;
  Owners: TOwnerMask;
begin
  if High(av) <> 4 then raise Exception.Create('Error.Script GlobalRelationsShips');
  Ranger := TObject(av[1].GetDword);
  if (Ranger <> nil) and (Ranger is TRanger) then
  begin
    if (av[2].GetDword > 0) and (av[2].GetDword < $FF) then
      Scope := TScriptConstellation(CurrentScript.Constellations[av[2].GetDword]).Constellation
    else if av[2].GetDword <> 0 then Scope := TObject(av[2].GetDword)
    else Scope := nil;
    ShipTypes := THullShipTypeMask(Word(av[3].GetDword));
    Owners := TOwnerMask(Byte(av[4].GetDword));
    av[0].SetInt(TRanger(Ranger).GlobalRelationsShips(Scope, ShipTypes, Owners));
  end;
end;
{ @end $6083A4 }

{ @routine $6084EC SF_GlobalRelationsPlanets }
procedure SF_GlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Owners: TOwnerMask;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script GlobalRelationsPlanets');
  Ranger := TObject(av[1].GetDword);
  if (Ranger <> nil) and (Ranger is TRanger) then
  begin
    if (av[2].GetDword > 0) and (av[2].GetDword < $FF) then
      Scope := TScriptConstellation(CurrentScript.Constellations[av[2].GetDword]).Constellation
    else if av[2].GetDword <> 0 then Scope := TObject(av[2].GetDword)
    else Scope := nil;
    Owners := TOwnerMask(Byte(av[3].GetDword));
    av[0].SetInt(TRanger(Ranger).GlobalRelationsPlanets(Scope, Owners));
  end;
end;
{ @end $6084EC }

{ @routine $608620 SF_SetRelationGroup }
procedure SF_SetRelationGroup(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script SetRelationGroup');
  CurrentScript.SetGroupRelation(av[1].GetInt, av[2].GetInt, TRelationLevel(av[3].GetInt));
end;
{ @end $608620 }

{ @routine $6086C0 SF_SetRelationPlanet }
procedure SF_SetRelationPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script SetRelationPlanet');
  CurrentScript.SetPlanetRelation(av[2].GetInt, TPlanet(av[1].GetDword), TRelationLevel(av[3].GetInt));
end;
{ @end $6086C0 }

{ @routine $608760 SF_GetRelationPlanet }
procedure SF_GetRelationPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GetRelationPlanet');
  Planet := TPlanet(av[1].GetDword);
  av[0].SetDword(Planet.RelationToShip(Pointer(av[2].GetDword)));
end;
{ @end $608760 }

{ @routine $608800 SF_CurTurn }
procedure SF_CurTurn(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Galaxy.CurrentTurn);
  if High(av) > 0 then Galaxy.CurrentTurn := av[1].GetInt;
end;
{ @end $608800 }

{ @routine $60885C SF_ShipType }
procedure SF_ShipType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipType');
  Ship := TShip(av[1].GetDword);
  if GetPlayer.RuinsProxy = Ship then av[0].SetString('PlayerBridge')
  else if Ship.TypeNameOverrideKey <> '' then av[0].SetString(Ship.TypeNameOverrideKey)
  else if (Ship.ScriptShip <> nil) and
    (TScriptShip(Ship.ScriptShip).Script.ScriptFileName = 'Script.PC_fem_rangers') and
    (TScriptShip(Ship.ScriptShip).GetGroup.Name = 'GroupFem') then av[0].SetString('FemRanger')
  else av[0].SetString(Ship.GetTypeNameKey);
  if High(av) > 1 then
  begin
    if av[2].GetString = Ship.GetTypeNameKey then Ship.TypeNameOverrideKey := ''
    else Ship.TypeNameOverrideKey := av[2].GetString;
  end;
end;
{ @end $60885C }

{ @routine $608A98 SF_ConName }
procedure SF_ConName(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ConName');
  if av[1].GetDword < Cardinal(Galaxy.Constellations.Count) then
    Constellation := TConstellation(Galaxy.Constellations[av[1].GetDword])
  else Constellation := TConstellation(av[1].GetDword);
  av[0].SetString(Constellation.GetName);
end;
{ @end $608A98 }

{ @routine $608B98 SF_StarName }
procedure SF_StarName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TStar;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script StarName');
  Obj := TStar(av[1].GetDword);
  av[0].SetString(Obj.Name);
end;
{ @end $608B98 }

{ @routine $608C1C SF_StarMapLabel }
procedure SF_StarMapLabel(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarMapLabel');
  Star := TStar(av[1].GetDword);
  av[0].SetString(Star.MapLabel);
  if High(av) > 1 then Star.MapLabel := av[2].GetString;
end;
{ @end $608C1C }

{ @routine $608CFC SF_PlanetName }
procedure SF_PlanetName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TPlanet;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script PlanetName');
  Obj := TPlanet(av[1].GetDword);
  av[0].SetString(Obj.Name);
end;
{ @end $608CFC }

{ @routine $608D80 SF_IdToPlanet }
procedure SF_IdToPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script IdToPlanet');
  av[0].SetDword(Cardinal(Galaxy.IdToPlanet(av[1].GetDword)));
end;
{ @end $608D80 }

{ @routine $608E10 SF_IdToShip }
procedure SF_IdToShip(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script IdToShip');
  av[0].SetDword(Cardinal(Galaxy.IdToShip(av[1].GetDword, (High(av) > 1) and (av[2].GetInt <> 0))));
end;
{ @end $608E10 }

{ @routine $608EB8 SF_IdToItem }
procedure SF_IdToItem(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script IdToItem');
  av[0].SetDword(Cardinal(Galaxy.IdToItem(av[1].GetDword, False)));
end;
{ @end $608EB8 }

{ @routine $608F48 SF_PlanetSetGoods }
procedure SF_PlanetSetGoods(av: array of TVarEC; code: TCodeEC);
var
  GoodsIndex: Byte;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script PlanetSetGoods');
  GoodsIndex := av[2].GetInt;
  TPlanet(av[1].GetDword).Goods[GoodsIndex].Count := av[3].GetInt;
end;
{ @end $608F48 }

{ @routine $608FE8 SF_ShipName }
procedure SF_ShipName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipName');
  Obj := TShip(av[1].GetDword);
  av[0].SetString(Obj.GetName);
end;
{ @end $608FE8 }

{ @routine $6090A4 SF_ShipRank }
procedure SF_ShipRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipRank');
  Ship := TObject(av[1].GetDword) as TNormalShip;
  av[0].SetInt(Ship.Rank);
end;
{ @end $6090A4 }

{ @routine $609138 SF_ShipRankPoints }
procedure SF_ShipRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRankPoints');
  Ship := TObject(av[1].GetDword) as TNormalShip;
  av[0].SetInt(Ship.RankPoints);
  if High(av) > 1 then Ship.RankPoints := av[2].GetInt;
end;
{ @end $609138 }

{ @routine $6091EC SF_ShipNextRankPoints }
procedure SF_ShipNextRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipNextRankPoints');
  Ship := TObject(av[1].GetDword) as TNormalShip;
  av[0].SetInt(CoalitionRankPointThresholds[Ship.Rank]);
end;
{ @end $6091EC }

{ @routine $609294 SF_ShipRaiseRank }
procedure SF_ShipRaiseRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRaiseRank');
  Ship := TObject(av[1].GetDword) as TNormalShip;
  if High(av) > 1 then
  begin
    Ship.Rank := av[2].GetInt;
    Ship.RankPoints := 0;
  end
  else Ship.TryPromoteRank;
end;
{ @end $609294 }

{ @routine $609348 SF_ShipStar }
procedure SF_ShipStar(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipStar');
  Ship := TShip(av[1].GetDword);
  av[0].SetDword(Cardinal(Ship.CurrentStar));
end;
{ @end $609348 }

{ @routine $6093CC SF_StarToCon }
procedure SF_StarToCon(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script StarToCon');
  av[0].SetDword(Cardinal(TStar(av[1].GetDword).Constellation));
end;
{ @end $6093CC }

{ @routine $609450 SF_ConNear }
procedure SF_ConNear(av: array of TVarEC; code: TCodeEC);
var
  I, Count, J, ArgCount: Integer;
  Constellation, Neighbor, Candidate: TConstellation;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ConNear');
  Constellation := TConstellation(av[1].GetDword);
  Count := Constellation.AdjacentConstellations.Count;
  ArgCount := High(av) - 1;
  for I := 0 to Count - 1 do
  begin
    Neighbor := TConstellation(Constellation.AdjacentConstellations[I]);
    for J := 0 to ArgCount - 1 do
    begin
      Candidate := TConstellation(av[2 + J].GetDword);
      if Neighbor = Candidate then
      begin
        av[0].SetInt(1);
        Exit;
      end;
    end;
  end;
  av[0].SetInt(0);
end;
{ @end $609450 }

{ @routine $609558 SF_ConStars }
procedure SF_ConStars(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ConStars');
  Constellation := TConstellation(av[1].GetDword);
  av[0].SetInt(Constellation.Stars.Count);
end;
{ @end $609558 }

{ @routine $6095E0 SF_ConStar }
procedure SF_ConStar(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
  Index: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ConStar');
  Constellation := TConstellation(av[1].GetDword);
  Index := av[2].GetInt;
  if (Index < 0) or (Index >= Constellation.Stars.Count) then av[0].SetDword(0)
  else av[0].SetDword(Cardinal(Constellation.Stars[Index]));
end;
{ @end $6095E0 }

{ @routine $6096A0 SF_GalaxyStars }
procedure SF_GalaxyStars(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Galaxy.Stars.Count);
end;
{ @end $6096A0 }

{ @routine $6096E4 SF_GalaxyStar }
procedure SF_GalaxyStar(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GalaxyStar');
  Index := av[1].GetInt;
  if (Index < 0) or (Index >= Galaxy.Stars.Count) then av[0].SetDword(0)
  else av[0].SetDword(Cardinal(Galaxy.Stars[Index]));
end;
{ @end $6096E4 }

{ @routine $60979C SF_StarAngleBetween }
procedure SF_StarAngleBetween(av: array of TVarEC; code: TCodeEC);
var
  Star1, CenterStar, Star2: TStar;
  MinAngle, MaxAngle, Angle: Single;
begin
  if High(av) <> 5 then raise Exception.Create('Error.Script StarAngleBetween');
  Star1 := TStar(av[1].GetDword);
  CenterStar := TStar(av[2].GetDword);
  Star2 := TStar(av[3].GetDword);
  MinAngle := av[4].GetFloat;
  MaxAngle := av[5].GetFloat;
  Angle := Abs(HeadingDifferenceDegrees(PointBearingDegrees(CenterStar.Position, Star1.Position),
    PointBearingDegrees(CenterStar.Position, Star2.Position)));
  if (Angle >= MinAngle) and (Angle <= MaxAngle) then av[0].SetInt(1)
  else av[0].SetInt(0);
end;
{ @end $60979C }

{ @routine $6098C4 SF_FindPlanet }
procedure SF_FindPlanet(av: array of TVarEC; code: TCodeEC);
var Star: TStar; Planet: TPlanet; Filters, Filter: WideString; MinFraction, MaxFraction: Single; I, Count, J, FilterCount: Integer; Planets: TList;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script FindPlanet');
  Star := TStar(av[1].GetDword);
  Filters := av[2].GetString;
  if High(av) >= 3 then MinFraction := av[3].GetFloat / 100 else MinFraction := 0;
  if High(av) >= 4 then MaxFraction := av[4].GetFloat / 100 else MaxFraction := 1;
  Planets := TList.Create;
  Count := Star.Planets.Count;
  FilterCount := CountDelimitedPartsW(Filters, ',');
  for I := 0 to Count - 1 do
  begin
    Planet := TPlanet(Star.Planets[I]);
    for J := 0 to FilterCount - 1 do
    begin
      Filter := ExtractDelimitedPartW(Filters, J, ',');
      if (Filter = 'NotMaloc') and (Planet.OwnerId = oiMaloc) then Break;
      if (Filter = 'NotPeleng') and (Planet.OwnerId = oiPeleng) then Break;
      if (Filter = 'NotPeople') and (Planet.OwnerId = oiHuman) then Break;
      if (Filter = 'NotFei') and (Planet.OwnerId = oiFeyan) then Break;
      if (Filter = 'NotGaal') and (Planet.OwnerId = oiGaal) then Break;
      if (Filter = 'NotKling') and (Planet.OwnerId = oiDominator) then Break;
      if (Filter = 'NotPirateClan') and (Planet.OwnerId = oiPirate) then Break;
      if (Filter = 'NotNone') and (Planet.OwnerId = oiUninhabited) then Break;
    end;
    if J >= FilterCount then Planets.Add(Planet);
  end;
  if Planets.Count < 1 then
  begin
    av[0].SetDword(0);
    Planets.Free;
    Exit;
  end;
  begin
    I := Round((Planets.Count - 1) * MinFraction);
    J := Round((Planets.Count - 1) * MaxFraction);
    I := I + NextRandomIntRange(0, J - I, Star.RandomState);
    av[0].SetDword(Cardinal(Planets[I]));
  end;
  Planets.Free;
end;
{ @end $6098C4 }

{ @routine $609C88 SF_ShipCanJump }
procedure SF_ShipCanJump(av: array of TVarEC; code: TCodeEC);
var
  FromStar, ToStar: TStar;
  I, Count, JumpRange, Fuel, Distance: Integer;
  CheckFuel: Boolean;
  Ship: TShip;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script CanJump');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(0);
  if (Ship.GetFuelTanks = nil) or (Ship.GetEngine = nil) then Exit;
  JumpRange := Ship.GetJumpRange;
  Count := High(av) - 1;
  Fuel := 0;
  CheckFuel := False;
  if (av[Count + 1].RealVType = vkInt) and (av[Count + 1].GetInt = 1) then
  begin
    CheckFuel := True;
    Fuel := Ship.GetFuelTanks.Fuel;
    Dec(Count);
  end;
  for I := 2 to Count do
  begin
    FromStar := TStar(av[I].GetDword);
    ToStar := TStar(av[I + 1].GetDword);
    Distance := Round(PointDistance(ToStar.Position, FromStar.Position));
    if CheckFuel then
    begin
      JumpRange := Min(JumpRange, Fuel);
      Dec(Fuel, Distance);
    end;
    if Distance > JumpRange then Exit;
  end;
  av[0].SetInt(1);
end;
{ @end $609C88 }

{ @routine $609E14 SF_ShipInStar }
procedure SF_ShipInStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ShipInStar');
  if (av[1].GetDword <> 0) and (TShip(av[1].GetDword).CurrentStar = TStar(av[2].GetDword)) then av[0].SetInt(1)
  else av[0].SetInt(0);
end;
{ @end $609E14 }

{ @routine $609EC4 SF_ShipInPlanet }
procedure SF_ShipInPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ShipInPlanet');
  if TShip(av[1].GetDword).CurrentPlanet = TPlanet(av[2].GetDword) then av[0].SetInt(1)
  else av[0].SetInt(0);
end;
{ @end $609EC4 }

{ @routine $609F68 SF_ShipStatistic }
procedure SF_ShipStatistic(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  NormalShip: TNormalShip;
  Ship: TShip;
  I: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipStatistic');
  Obj := TObject(av[1].GetDword);
  NormalShip := nil;
  if Obj is TNormalShip then
  begin
    NormalShip := TNormalShip(Obj);
    Ship := NormalShip;
  end
  else if (Obj is TShip) and (av[2].GetInt in [10, 11]) then Ship := TShip(Obj)
  else raise Exception.Create('Error.Script ShipStatistic - illegal object type');
  case av[2].GetInt of
    0:
      begin
        av[0].SetInt(NormalShip.TotalShipKillCount);
        if High(av) > 2 then NormalShip.TotalShipKillCount := av[3].GetInt;
      end;
    1:
      begin
        av[0].SetInt(NormalShip.PirateKillCount);
        if High(av) > 2 then NormalShip.PirateKillCount := av[3].GetInt;
      end;
    2:
      begin
        av[0].SetInt(NormalShip.DominatorKillCount);
        if High(av) > 2 then NormalShip.DominatorKillCount := av[3].GetInt;
      end;
    3:
      begin
        av[0].SetInt(NormalShip.LiberatedSystemCount);
        if High(av) > 2 then NormalShip.LiberatedSystemCount := av[3].GetInt;
      end;
    4:
      begin
        av[0].SetInt(NormalShip.CivilianKillCount);
        if High(av) > 2 then NormalShip.CivilianKillCount := av[3].GetInt;
      end;
    5:
      begin
        av[0].SetInt(NormalShip.MilitaryKillCount);
        if High(av) > 2 then NormalShip.MilitaryKillCount := av[3].GetInt;
      end;
    6:
      begin
        av[0].SetInt(NormalShip.RangerKillCount);
        if High(av) > 2 then NormalShip.RangerKillCount := av[3].GetInt;
      end;
    7:
      if GetPlayer = NormalShip then
      begin
        av[0].SetInt(GetPlayer.BlackHoleKillCount);
        if High(av) > 2 then GetPlayer.BlackHoleKillCount := av[3].GetInt;
      end;
    8:
      if GetPlayer = NormalShip then
      begin
        av[0].SetInt(GetPlayer.HyperspaceKillCount);
        if High(av) > 2 then GetPlayer.HyperspaceKillCount := av[3].GetInt;
      end;
    9:
      begin
        av[0].SetInt(NormalShip.TradeLossBalance);
        if High(av) > 2 then NormalShip.TradeLossBalance := av[3].GetInt;
      end;
    10:
      begin
        av[0].SetDword(Cardinal(Ship.HomePlanet));
        if High(av) > 2 then
        begin
          if Ship is TWarrior then
          begin
            I := Ship.HomePlanet.Warriors.IndexOf(Ship);
            if I >= 0 then Ship.HomePlanet.Warriors.Delete(I);
            TPlanet(av[3].GetDword).Warriors.Add(Ship);
          end
          else if Ship is TTransport then
          begin
            Dec(Ship.HomePlanet.HomeTransportCount);
            Inc(TPlanet(av[3].GetDword).HomeTransportCount);
          end
          else if Ship is TRanger then
          begin
            Dec(Ship.HomePlanet.HomeRangerCount);
            Inc(TPlanet(av[3].GetDword).HomeRangerCount);
          end;
          Ship.HomePlanet := TPlanet(av[3].GetDword);
        end;
      end;
    11:
      begin
        av[0].SetInt(Ship.CreationTurn);
        if High(av) > 2 then Ship.CreationTurn := av[3].GetInt;
      end;
    12: av[0].SetInt(NormalShip.CalculateMass);
    13:
      begin
        av[0].SetInt(NormalShip.ContrabandProfit);
        if High(av) > 2 then NormalShip.ContrabandProfit := av[3].GetInt;
      end;
  else raise Exception.Create('Error.Script ShipStatistic');
  end;
end;
{ @end $609F68 }

{ @routine $60A494 SF_PlayerDominatorStatistic }
procedure SF_PlayerDominatorStatistic(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlayerDominatorStatistic');
  av[0].SetInt(GetPlayer.DominatorKillsByType[Ord(TKlingType(av[1].GetInt))]);
  if High(av) > 1 then GetPlayer.DominatorKillsByType[Ord(TKlingType(av[1].GetInt))] := av[2].GetInt;
end;
{ @end $60A494 }

{ @routine $60A564 SF_ShipMoney }
procedure SF_ShipMoney(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipMoney');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(Ship.Money);
  if High(av) >= 2 then Ship.SetMoney(Max(0, av[2].GetInt));
end;
{ @end $60A564 }

{ @routine $60A620 SF_ShipFuel }
procedure SF_ShipFuel(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipFuel');
  Ship := TShip(av[1].GetDword);
  if (Ship = nil) or (Ship.GetFuelTanks = nil) then av[0].SetInt(0)
  else av[0].SetInt(Ship.GetFuelTanks.Fuel);
  if (High(av) >= 2) and (Ship.GetFuelTanks <> nil) then
  begin
    Ship.GetFuelTanks.Fuel := av[2].GetInt;
    if Ship.GetFuelTanks.Fuel < 0 then Ship.GetFuelTanks.Fuel := 0;
  end;
end;
{ @end $60A620 }

{ @routine $60A710 SF_ShipFuelLow }
procedure SF_ShipFuelLow(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipFuelLow');
  Ship := TShip(av[1].GetDword);
  if Ship.GetFuelTanks = nil then av[0].SetInt(1)
  else if Ship.GetFuelTanks.Fuel < Ship.GetFuelTanks.Capacity then av[0].SetInt(1)
  else av[0].SetInt(0);
end;
{ @end $60A710 }

{ @routine $60A7E0 SF_ShipStrengthInBestRanger }
procedure SF_ShipStrengthInBestRanger(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipStrengthInBestRanger');
  Ship := TShip(av[1].GetDword);
  av[0].SetFloat(Ship.StrengthInBestRanger);
end;
{ @end $60A7E0 }

{ @routine $60A880 SF_ShipStrengthInAverageRanger }
procedure SF_ShipStrengthInAverageRanger(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipStrength');
  Ship := TShip(av[1].GetDword);
  av[0].SetFloat(Ship.Strength / Galaxy.AverageRangerStrength);
end;
{ @end $60A880 }

{ @routine $60A91C SF_ChanceToWin }
procedure SF_ChanceToWin(av: array of TVarEC; code: TCodeEC);
var Ship, Target: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ChanceToWin');
  Ship := TShip(av[1].GetDword);
  Target := TShip(av[2].GetDword);
  if (High(av) > 2) and (av[3].GetInt <> 0) then av[0].SetFloat(Ship.ChanceToWin(Target))
  else av[0].SetInt(Ship.GetWinChancePercent(Target));
end;
{ @end $60A91C }

{ @routine $60A9F0 SF_RangerStatus }
procedure SF_RangerStatus(av: array of TVarEC; code: TCodeEC);
var Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RangerStatus');
  Obj := TObject(av[1].GetDword);
  if High(av) > 1 then
  begin
    if av[2].GetString = 'EminentWarrior' then av[0].SetInt(Ord(Galaxy.EminentCareerShips[rcWarrior] = Obj))
    else if av[2].GetString = 'EminentTrader' then av[0].SetInt(Ord(Galaxy.EminentCareerShips[rcTrader] = Obj))
    else if av[2].GetString = 'EminentPirate' then av[0].SetInt(Ord(Galaxy.EminentCareerShips[rcPirate] = Obj))
    else raise Exception.Create(AnsiString('Error.Script RangerStatus - unknown keyword ' + av[2].GetString));
  end
  else
  begin
    if not (Obj is TRanger) then raise Exception.Create('Error.Script RangerStatus 2');
    av[0].SetInt(Ord((Obj as TRanger).GetDominantCareer));
  end;
end;
{ @end $60A9F0 }

{ @routine $60ACF8 SF_RangerPlaceInRating }
procedure SF_RangerPlaceInRating(av: array of TVarEC; code: TCodeEC);
var Obj: TObject;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script RangerPlaceInRating');
  Obj := TObject(av[1].GetDword);
  if not (Obj is TRanger) then raise Exception.Create('Error.Script RangerPlaceInRating 2');
  av[0].SetInt((Obj as TRanger).PlaceInRating);
end;
{ @end $60ACF8 }

{ @routine $60ADEC SF_RangerExcludedFromRating }
procedure SF_RangerExcludedFromRating(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RangerExcludedFromRating');
  Obj := TObject(av[1].GetDword);
  if not (Obj is TRanger) then raise Exception.Create('Error.Script RangerExcludedFromRating 2');
  Ranger := TRanger(Obj);
  av[0].SetInt(Ord(Ranger.ExcludedFromRating));
  if High(av) > 1 then
  begin
    Ranger.ExcludedFromRating := av[2].GetInt <> 0;
    if Ranger.ExcludedFromRating then
    begin
      if Galaxy.EminentCareerShips[rcTrader] = Ranger then Galaxy.EminentCareerShips[rcTrader] := nil;
      if Galaxy.EminentCareerShips[rcPirate] = Ranger then Galaxy.EminentCareerShips[rcPirate] := nil;
      if Galaxy.EminentCareerShips[rcWarrior] = Ranger then Galaxy.EminentCareerShips[rcWarrior] := nil;
    end;
  end;
end;
{ @end $60ADEC }

{ @routine $60AF68 SF_ShipFind }
procedure SF_ShipFind(av: array of TVarEC; code: TCodeEC);
var Kind: Byte; Star: TStar; Ship: TShip; I: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipFind');
  av[0].SetDword(0);
  if GetPlayer <> nil then
  begin
    Kind := av[1].GetInt;
    Star := GetPlayer.CurrentStar;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[I]);
      if Ship.TypeId = Kind then
      begin
        av[0].SetDword(Cardinal(Ship));
        Exit;
      end;
    end;
  end;
end;
{ @end $60AF68 }

{ @routine $60B048 SF_ShipDestroy }
procedure SF_ShipDestroy(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipDestroy');
  if av[1].GetDword = 0 then
  begin
    av[0].SetInt(0);
    Exit;
  end;

  av[0].SetInt(Ord(TShip(av[1].GetDword).DestroyQueued));
  if High(av) <= 1 then TShip(av[1].GetDword).DestroyQueued := True
  else if av[2].GetInt >= 0 then TShip(av[1].GetDword).DestroyQueued := Boolean(av[2].GetInt);
end;
{ @end $60B048 }

{ @routine $60B134 SF_ShipDestroyType }
procedure SF_ShipDestroyType(av: array of TVarEC; code: TCodeEC);
var
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
  Kind: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipDestroyType');
  Kind := av[1].GetInt;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if (Kind = 1) and (Ship.TypeId = stKling) and (TKling(Ship).DominatorSeries = dsBlazer) and
        (TKling(Ship).KlingType <> ktBoss) and not Ship.HasIndependentScriptFaction then Ship.DestroyQueued := True;
    end;
  end;
end;
{ @end $60B134 }

{ @routine $60B264 SF_ItemDestroy }
procedure SF_ItemDestroy(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemDestroy');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    av[0].SetInt(Item.DestroyFlag);
    if High(av) > 1 then Item.DestroyFlag := av[2].GetInt;
  end;
end;
{ @end $60B264 }

{ @routine $60B344 SF_RangersCapital }
procedure SF_RangersCapital(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Galaxy.AverageRangerCapital);
end;
{ @end $60B344 }

{ @routine $60B384 SF_GroupToShip }
procedure SF_GroupToShip(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
  Binding: TScriptShip;
  I, GroupIndex: Integer;
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GroupToShip');
  GroupIndex := av[1].GetInt;
  Ship := nil;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := TScriptShip(CurrentScript.Ships[I]);
    if Binding.GroupIndex = GroupIndex then
    begin
      Ship := Binding.Ship;
      if Ship <> GetPlayer then
      begin
        av[0].SetDword(Cardinal(Ship));
        Exit;
      end;
    end;
  end;
  av[0].SetDword(Cardinal(Ship));
end;
{ @end $60B384 }

{ @routine $60B47C SF_OrderJump }
procedure SF_OrderJump(av: array of TVarEC; code: TCodeEC);
var Absolute: Boolean; SavedOrderLock: Byte; Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderJump');
  Absolute := False;
  if High(av) >= 3 then Absolute := Boolean(av[3].GetInt);
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if Ship.CurrentPlanet <> nil then AppendLogLineThreadSafe(AnsiString('Warning! ' + GetScriptContextDescription + ' orders ship ' + Ship.GetFullName(' ') + ' to jump while landed on planet!'));
    SavedOrderLock := Ship.AbsoluteScriptOrder;
    Ship.AbsoluteScriptOrder := 0;
    Ship.OrderJump(TStar(av[2].GetDword), Absolute);
    Ship.AbsoluteScriptOrder := SavedOrderLock;
    if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
    if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
    begin
      StarMapScreen.ClearPathOverlay(True);
      StarMapScreen.BuildShipPathOverlay(Ship, False, '');
    end;
  end;
end;
{ @end $60B47C }

{ @routine $60B6D0 SF_OrderLanding }
procedure SF_OrderLanding(av: array of TVarEC; code: TCodeEC);
var Absolute: Boolean; SavedOrderLock: Byte; Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderLanding');
  Absolute := False;
  if High(av) >= 3 then Absolute := Boolean(av[3].GetInt);
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    SavedOrderLock := Ship.AbsoluteScriptOrder;
    Ship.AbsoluteScriptOrder := 0;
    Ship.OrderLanding(TObject(av[2].GetDword), Absolute);
    Ship.AbsoluteScriptOrder := SavedOrderLock;
    if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
    if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
    begin
      StarMapScreen.ClearPathOverlay(True);
      StarMapScreen.BuildShipPathOverlay(Ship, False, '');
    end;
  end;
end;
{ @end $60B6D0 }

{ @routine $60B804 SF_IsPlayer }
procedure SF_IsPlayer(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script IsPlayer');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(Ord(GetPlayer = Ship));
end;
{ @end $60B804 }

{ @routine $60B890 SF_GroupCount }
procedure SF_GroupCount(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
  I, ShipCount, GroupIndex, Count: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GroupCount');
  GroupIndex := av[1].GetInt;
  Count := 0;
  ShipCount := CurrentScript.Ships.Count;
  for I := 0 to ShipCount - 1 do
  begin
    Binding := TScriptShip(CurrentScript.Ships[I]);
    if Binding.GroupIndex = GroupIndex then Inc(Count);
  end;
  av[0].SetInt(Count);
end;
{ @end $60B890 }

{ @routine $60B964 SF_GroupIn }
procedure SF_GroupIn(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex: Integer;
  Location: TObject;
  I, Count: Integer;
  Binding: TScriptShip;
  Found: Boolean;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GroupIn');
  GroupIndex := av[1].GetInt;
  Location := TObject(av[2].GetDword);
  Found := False;
  if Location is TConstellation then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := TScriptShip(CurrentScript.Ships[I]);
      if Binding.GroupIndex = GroupIndex then
      begin
        if Binding.Ship.CurrentStar.Constellation <> Location then
        begin
          av[0].SetInt(0);
          Exit;
        end;
        Found := True;
      end;
    end;
  end
  else if Location is TStar then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := TScriptShip(CurrentScript.Ships[I]);
      if Binding.GroupIndex = GroupIndex then
      begin
        if Binding.Ship.CurrentStar <> Location then
        begin
          av[0].SetInt(0);
          Exit;
        end;
        Found := True;
      end;
    end;
  end
  else if Location is TPlanet then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := TScriptShip(CurrentScript.Ships[I]);
      if Binding.GroupIndex = GroupIndex then
      begin
        if (Binding.Ship = GetPlayer) and (GetPlayer.RuinsMode <> 0) then
        begin
          if GetPlayer.RuinsSavedPlanet <> Location then
          begin
            av[0].SetInt(0);
            Exit;
          end;
        end
        else
        begin
          if not Binding.Ship.IsOnPlanet or (Binding.Ship.CurrentPlanet <> Location) then
          begin
            av[0].SetInt(0);
            Exit;
          end;
          Found := True;
        end;
      end;
    end;
  end
  else if Location is TShip then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := TScriptShip(CurrentScript.Ships[I]);
      if Binding.GroupIndex = GroupIndex then
      begin
        if (Binding.Ship = GetPlayer) and (GetPlayer.RuinsMode <> 0) then
        begin
          if GetPlayer.RuinsSavedDockedTo <> Location then
          begin
            av[0].SetInt(0);
            Exit;
          end;
        end
        else
        begin
          if not Binding.Ship.IsDockedToShip or (Binding.Ship.DockedTo <> Location) then
          begin
            av[0].SetInt(0);
            Exit;
          end;
          Found := True;
        end;
      end;
    end;
  end
  else if Location is TScriptPlace then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := TScriptShip(CurrentScript.Ships[I]);
      if Binding.GroupIndex = GroupIndex then
      begin
        if not TScriptPlace(Location).ShipInPlace(Binding.Ship) then
        begin
          av[0].SetInt(0);
          Exit;
        end;
        Found := True;
      end;
    end;
  end;
  av[0].SetInt(Ord(Found));
end;
{ @end $60B964 }

{ @routine $60BD4C SF_CountIn }
procedure SF_CountIn(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex: Integer;
  Location: TObject;
  I, Count, FoundCount: Integer;
  Binding: TScriptShip;
  ExcludeHyperspace: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CountIn');
  GroupIndex := av[1].GetInt;
  { Native code reads argument 2 both as this flag and as the location below. }
  ExcludeHyperspace := (High(av) > 1) and (av[2].GetInt <> 0);
  FoundCount := 0;
  if High(av) = 1 then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := TScriptShip(CurrentScript.Ships[I]);
      if Binding.GroupIndex = GroupIndex then Inc(FoundCount);
    end;
  end
  else
  begin
    Location := TObject(av[2].GetDword);
    if Location is TConstellation then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := TScriptShip(CurrentScript.Ships[I]);
        if ExcludeHyperspace and Binding.Ship.InHyperspace then Continue;
        if (Binding.GroupIndex = GroupIndex) and (Binding.Ship.CurrentStar.Constellation = Location) then Inc(FoundCount);
      end;
    end
    else if Location is TStar then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := TScriptShip(CurrentScript.Ships[I]);
        if ExcludeHyperspace and Binding.Ship.InHyperspace then Continue;
        if ExcludeHyperspace and (Binding.Ship.DockedTo <> nil) and Binding.Ship.DockedTo.InHyperspace then Continue;
        if (Binding.GroupIndex = GroupIndex) and (Binding.Ship.CurrentStar = Location) then Inc(FoundCount);
      end;
    end
    else if Location is TPlanet then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := TScriptShip(CurrentScript.Ships[I]);
        if (Binding.GroupIndex = GroupIndex) and (Binding.Ship = GetPlayer) and
          (GetPlayer.RuinsMode <> 0) and (GetPlayer.RuinsSavedPlanet = Location) then Inc(FoundCount)
        else if (Binding.GroupIndex = GroupIndex) and Binding.Ship.IsOnPlanet and
          (Binding.Ship.CurrentPlanet = Location) then Inc(FoundCount);
      end;
    end
    else if Location is TShip then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := TScriptShip(CurrentScript.Ships[I]);
        if (Binding.GroupIndex = GroupIndex) and (Binding.Ship = GetPlayer) and
          (GetPlayer.RuinsMode <> 0) and (GetPlayer.RuinsSavedDockedTo = Location) then Inc(FoundCount)
        else if (Binding.GroupIndex = GroupIndex) and Binding.Ship.IsDockedToShip and
          (Binding.Ship.DockedTo = Location) then Inc(FoundCount);
      end;
    end
    else if Location is TScriptPlace then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := TScriptShip(CurrentScript.Ships[I]);
        if (Binding.GroupIndex = GroupIndex) and TScriptPlace(Location).ShipInPlace(Binding.Ship) then Inc(FoundCount);
      end;
    end;
  end;
  av[0].SetInt(FoundCount);
end;
{ @end $60BD4C }

{ @routine $60C1A8 SF_NearestGroup }
procedure SF_NearestGroup(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  I, ShipCount, J, GroupCount, GroupIndex: Integer;
  Distance, BestDistance: Single;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script NearestGroup');
  Ship := TShip(av[1].GetDword);
  GroupIndex := av[2].GetInt;
  BestDistance := 1e15;
  ShipCount := CurrentScript.Ships.Count;
  GroupCount := High(av) - 1;
  for I := 0 to ShipCount - 1 do
  begin
    Binding := TScriptShip(CurrentScript.Ships[I]);
    for J := 0 to GroupCount - 1 do
      if av[2 + J].GetInt = Binding.GroupIndex then Break;
    if J >= GroupCount then Continue;
    if (Binding.Ship.CurrentStar = Ship.CurrentStar) and Binding.Ship.InNormalSpace then
    begin
      Distance := PointDistanceSquared(Ship.Position, Binding.Ship.Position);
      if Distance < BestDistance then
      begin
        BestDistance := Distance;
        GroupIndex := Binding.GroupIndex;
      end;
    end;
  end;
  av[0].SetInt(GroupIndex);
end;
{ @end $60C1A8 }

{ @routine $60C320 SF_ChangeState }
procedure SF_ChangeState(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ChangeState');
  if av[1].RealVType <> vkString then Index := av[1].GetInt
  else
  begin
    for Index := 0 to CurrentScript.States.Count - 1 do
      if TScriptState(CurrentScript.States[Index]).Name = av[1].GetString then Break;
    if Index >= CurrentScript.States.Count then
      raise Exception.Create('Error.Script ChangeState ' + av[1].GetString);
  end;
  ScriptSnap(Snapshot);
  if High(av) >= 2 then Ship := TShip(av[2].GetDword)
  else Ship := CurrentScript.CurrentShip;
  CurrentScript.ChangeState(GetScriptShipBindingForContext(Ship, CurrentScript), Index);
  ScriptUnSnap(Snapshot);
end;
{ @end $60C320 }

{ @routine $60C52C SF_StarAngle }
procedure SF_StarAngle(av: array of TVarEC; code: TCodeEC);
var
  First, Second: TStar;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script StarAngle');
  First := TStar(av[1].GetDword);
  Second := TStar(av[2].GetDword);
  av[0].SetFloat(PointBearingDegrees(First.Position, Second.Position));
end;
{ @end $60C52C }

{ @routine $60C5D0 SF_NewsAdd }
procedure SF_NewsAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script NewsAdd');
  AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, av[1].GetString, '');
end;
{ @end $60C5D0 }

{ @routine $60C68C SF_MsgAdd }
procedure SF_MsgAdd(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  GroupIndex, I, Count: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script NewsAdd');
  Ship := nil;
  GroupIndex := av[2].GetInt;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := TScriptShip(CurrentScript.Ships[I]);
    if Binding.GroupIndex = GroupIndex then
    begin
      Ship := Binding.Ship;
      Break;
    end;
  end;
  if (Ship = nil) or GetPlayer.InHyperspace or (GetPlayer.CurrentStar <> Ship.CurrentStar) then
    av[0].SetInt(0)
  else
  begin
    with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, av[1].GetString, '') do
      Targets[0].ShipId := Ship.Id;
    av[0].SetInt(1);
  end;
end;
{ @end $60C68C }

{ @routine $60C800 SF_Ether }
procedure SF_Ether(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  InPlayerSystem: Boolean;
  Key: WideString;
  Kind: Byte;
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script Ether');
  av[0].SetInt(0);
  Kind := av[1].GetInt;
  Key := av[2].GetString;
  Obj := nil;
  InPlayerSystem := False;
  if High(av) >= 4 then
  begin
    Obj := TObject(av[4].GetDword);
    if Obj = nil then Exit;
    if Obj is TShip then
    begin
      if TShip(Obj).InNormalSpace then
        if GetPlayer.InNormalSpace then InPlayerSystem := GetPlayer.CurrentStar = TShip(Obj).CurrentStar;
    end
    else if Obj is TPlanet then
    begin
      if GetPlayer.InNormalSpace then InPlayerSystem := GetPlayer.CurrentStar = TPlanet(Obj).CurrentStar;
    end
    // Native constructs but does not raise this exception.
    else Exception.Create('Error.Script Ether objtype');
  end;
  if not (Kind in [1, 10]) or (Obj = nil) or InPlayerSystem then
  begin
    if (Kind = 3) and (Key <> '') and (CurrentScript <> nil) and (CurrentScript.EtherIds.IndexOf(Key) < 0) then
      CurrentScript.EtherIds.Add(Key);
    MessageEntry := AddOrUpdatePlayerBubble(Kind, Galaxy.CurrentTurn,
      ReplaceAllWideString(ReplaceAllWideString(av[3].GetString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag), Key);
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[0].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[0].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 5 then Obj := TObject(av[5].GetDword) else Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[1].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[1].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 6 then Obj := TObject(av[6].GetDword) else Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[2].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[2].PlanetId := TPlanet(Obj).Id;
    end;
    av[0].SetInt(1);
  end;
end;
{ @end $60C800 }

{ @routine $60CBA0 SF_CustomEther }
procedure SF_CustomEther(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  InPlayerSystem: Boolean;
  Key: WideString;
  Kind: Byte;
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script Ether');
  av[0].SetInt(0);
  Kind := av[2].GetInt;
  Key := av[3].GetString;
  Obj := nil;
  InPlayerSystem := False;
  if High(av) >= 5 then
  begin
    Obj := TObject(av[5].GetDword);
    if Obj = nil then Exit;
    if Obj is TShip then
    begin
      if TShip(Obj).InNormalSpace then
        if GetPlayer.InNormalSpace then InPlayerSystem := GetPlayer.CurrentStar = TShip(Obj).CurrentStar;
    end
    else if Obj is TPlanet then
    begin
      if GetPlayer.InNormalSpace then InPlayerSystem := GetPlayer.CurrentStar = TPlanet(Obj).CurrentStar;
    end
    // Native constructs but does not raise this exception.
    else Exception.Create('Error.Script Ether objtype');
  end;
  if not (Kind in [1, 10]) or (Obj = nil) or InPlayerSystem then
  begin
    if (Kind = 3) and (Key <> '') and (CurrentScript <> nil) and (CurrentScript.EtherIds.IndexOf(Key) < 0) then
      CurrentScript.EtherIds.Add(Key);
    MessageEntry := AddOrUpdatePlayerBubble(Kind, Galaxy.CurrentTurn,
      ReplaceAllWideString(ReplaceAllWideString(av[4].GetString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag), Key);
    MessageEntry.ImageNameOverride := av[1].GetString;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[0].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[0].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 6 then Obj := TObject(av[6].GetDword) else Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[1].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[1].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 7 then Obj := TObject(av[7].GetDword) else Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[2].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[2].PlanetId := TPlanet(Obj).Id;
    end;
    av[0].SetInt(1);
  end;
end;
{ @end $60CBA0 }

{ @routine $60CF60 SF_EtherDelete }
procedure SF_EtherDelete(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script EtherDelete');
  RemovePlayerBubbleByKey(av[1].GetString);
end;
{ @end $60CF60 }

{ @routine $60D010 SF_EtherIdAdd }
procedure SF_EtherIdAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script EtherIdAdd');
  CurrentScript.EtherIds.Add(av[1].GetString);
end;
{ @end $60D010 }

{ @routine $60D0C8 SF_EtherIdDelete }
procedure SF_EtherIdDelete(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script EtherIdDelete');
  while True do
  begin
    Index := CurrentScript.EtherIds.IndexOf(av[1].GetString);
    if Index < 0 then Break;
    CurrentScript.EtherIds.Delete(Index);
  end;
end;
{ @end $60D0C8 }

{ @routine $60D1A0 SF_EtherState }
procedure SF_EtherState(av: array of TVarEC; code: TCodeEC);
var
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EtherState');
  MessageEntry := FindPlayerBubbleByKey(av[1].GetString, False);
  if MessageEntry = nil then av[0].SetInt(-1) else av[0].SetInt(MessageEntry.Kind);
end;
{ @end $60D1A0 }

{ @routine $60D278 SF_ConChangeRelationToRanger }
procedure SF_ConChangeRelationToRanger(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TRanger;
  Sector: TConstellation;
  Amount: Integer;
  Star: TStar;
  Planet: TPlanet;
  StarIndex, PlanetIndex, StarCount, PlanetCount: Integer;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script ConChangeRelationToRanger');
  Sector := TConstellation(av[1].GetDword);
  Ranger := TRanger(av[2].GetDword);
  Amount := av[3].GetInt;
  StarCount := Sector.Stars.Count;
  for StarIndex := 0 to StarCount - 1 do
  begin
    Star := TStar(Sector.Stars[StarIndex]);
    PlanetCount := Star.Planets.Count;
    for PlanetIndex := 0 to PlanetCount - 1 do
    begin
      Planet := TPlanet(Star.Planets[PlanetIndex]);
      if Planet.OwnerId <> oiUninhabited then Planet.ChangeRelationToRanger(Ranger, Amount);
    end;
  end;
end;
{ @end $60D278 }

{ @routine $60D3A0 SF_GetData }
procedure SF_GetData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
begin
  Index := 0;
  if High(av) >= 1 then Index := av[1].GetInt;
  if High(av) >= 2 then
  begin
    Ship := TShip(av[2].GetDword);
    if (Ship = GetPlayer) and (CurrentScript = nil) then Exit;
  end
  else Ship := CurrentScript.CurrentShip;
  if Ship = GetPlayer then
    av[0].SetDword(GetScriptShipBindingForContext(Ship, CurrentScript).Data[Index])
  else av[0].SetDword(TScriptShip(Ship.ScriptShip).Data[Index]);
end;
{ @end $60D3A0 }

{ @routine $60D464 SF_SetData }
procedure SF_SetData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SetData');
  Index := 0;
  if High(av) >= 2 then Index := av[2].GetInt;
  if High(av) >= 3 then
  begin
    Ship := TShip(av[3].GetDword);
    if (Ship = GetPlayer) and (CurrentScript = nil) then Exit;
  end
  else Ship := CurrentScript.CurrentShip;
  if Ship = GetPlayer then
    GetScriptShipBindingForContext(Ship, CurrentScript).Data[Index] := av[1].GetDword
  else TScriptShip(Ship.ScriptShip).Data[Index] := av[1].GetDword;
end;
{ @end $60D464 }

{ @routine $60D568 SF_ShipData }
procedure SF_ShipData(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetDword(GetScriptShipBindingForContext(CurrentScript.CurrentShip, CurrentScript).Data[0]);
  if High(av) >= 1 then
    GetScriptShipBindingForContext(CurrentScript.CurrentShip, CurrentScript).Data[0] := av[1].GetDword;
end;
{ @end $60D568 }

{ @routine $60D5E8 SF_Format }
procedure SF_Format(av: array of TVarEC; code: TCodeEC);
var Text, Color: WideString; I, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script Format');
  if High(av) = 1 then
  begin
    Text := av[1].GetString;
    Text := ReplaceAllWideString(Text, '<br>', #13#10);
    Text := ReplaceAllWideString(Text, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then Text := ReplaceAllWideString(Text, '<Player>', TextHighlightColorTag + GetPlayer.Name + EndColorTag);
    av[0].SetString(Text);
  end
  else
  begin
    Text := av[1].GetString;
    Count := (High(av) - 1) div 2;
    if Count * 2 + 1 < High(av) then
    begin
      Color := av[High(av)].GetString;
      if Color <> '' then Color := '<color=' + Color + '>';
    end
    else Color := TextHighlightColorTag;
    for I := 0 to Count - 1 do
      Text := ReplaceAllWideString(Text, av[2 + I * 2].GetString, WrapTextInColor(av[2 + I * 2 + 1].GetString, Color));
    av[0].SetString(Text);
  end;
end;
{ @end $60D5E8 }

{ @routine $60D8EC SF_DeleteTags }
procedure SF_DeleteTags(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DeleteTags');
  av[0].SetString(RemoveTextTagsW(av[1].GetString));
end;
{ @end $60D8EC }

{ @routine $60D9B0 SF_Dialog }
procedure SF_Dialog(av: array of TVarEC; code: TCodeEC);
var
  I, Count, J, ShipCount: Integer;
  Obj: TObject;
  Binding: TScriptShip;
  Immediate: Boolean;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script Dialog');
  av[0].SetInt(0);
  if ExitScreenLoop then Exit;
  if GetPlayer = nil then Exit;
  if (High(av) = 1) and (av[1].GetDword = 0) then Exit;
  if not GetPlayer.InNormalSpace then Exit;
  if CurrentScreenId <> screenStarMap then Exit;
  if TalkDialogActive then Exit;
  Immediate := TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared];
  ScriptSnap(Snapshot);
  if High(av) = 1 then
  begin
    if Immediate then
    begin
      TalkShip := TShip(av[1].GetDword);
      TalkScripted := False;
      ScriptDialogIndex := -1;
      StarMapScreen.RunTalkDialogs;
      av[0].SetInt(1);
    end
    else if TShip(av[1].GetDword).OpenPlayerConversation(False) then av[0].SetInt(1);
    ScriptUnSnap(Snapshot);
    Exit;
  end;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
  begin
    Obj := TObject(av[2 + I].GetDword);
    if Cardinal(Obj) < $10000 then
    begin
      ShipCount := CurrentScript.Ships.Count;
      for J := 0 to ShipCount - 1 do
      begin
        Binding := TScriptShip(CurrentScript.Ships[J]);
        if (Binding.GroupIndex = Integer(Obj)) and (GetPlayer <> Binding.Ship) then
        begin
          ScriptDialogIndex := -1;
          CurrentScript.CallDialog(av[1].GetInt);
          if ScriptDialogIndex >= 0 then
          begin
            if Immediate then
            begin
              TalkShip := Binding.Ship;
              TalkScripted := False;
              StarMapScreen.RunTalkDialogs;
              av[0].SetInt(1);
            end
            else if Binding.Ship.OpenPlayerConversation(False) then av[0].SetInt(1);
            ScriptUnSnap(Snapshot);
            Exit;
          end;
        end;
      end;
    end
    else if Obj is TShip then
    begin
      ScriptDialogIndex := -1;
      CurrentScript.CallDialog(av[1].GetInt);
      if ScriptDialogIndex >= 0 then
      begin
        if Immediate then
        begin
          TalkShip := TShip(Obj);
          TalkScripted := False;
          StarMapScreen.RunTalkDialogs;
          av[0].SetInt(1);
        end
        else if TShip(Obj).OpenPlayerConversation(False) then av[0].SetInt(1);
        ScriptUnSnap(Snapshot);
        Exit;
      end;
    end
    else if Obj is TPlanet then
    begin
      ScriptDialogIndex := -1;
      CurrentScript.CallDialog(av[1].GetInt);
      if (ScriptDialogIndex >= 0) and TPlanet(Obj).RequestDialog then
      begin
        av[0].SetInt(1);
        ScriptUnSnap(Snapshot);
        Exit;
      end;
    end;
  end;
end;
{ @end $60D9B0 }

{ @routine $60DD84 SF_DText }
procedure SF_DText(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DText');
  if GetPlayer.IsDockedToShip then
    RuinsTalkScreen.DialogText := ReplaceAllWideString(ReplaceAllWideString(av[1].GetString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else if not GetPlayer.IsOnPlanet then
    TalkScreen.DialogText := ReplaceAllWideString(ReplaceAllWideString(av[1].GetString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else
    GovernmentScreen.DialogText := ReplaceAllWideString(ReplaceAllWideString(av[1].GetString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag);
end;
{ @end $60DD84 }

{ @routine $60DFA0 SF_DAddText }
procedure SF_DAddText(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DAddText');
  if GetPlayer.IsDockedToShip then
    RuinsTalkScreen.DialogText := RuinsTalkScreen.DialogText + ReplaceAllWideString(ReplaceAllWideString(av[1].GetString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else if not GetPlayer.IsOnPlanet then
    TalkScreen.DialogText := TalkScreen.DialogText + ReplaceAllWideString(ReplaceAllWideString(av[1].GetString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else
    GovernmentScreen.DialogText := GovernmentScreen.DialogText + ReplaceAllWideString(ReplaceAllWideString(av[1].GetString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag);
end;
{ @end $60DFA0 }

{ @routine $60E1CC SF_DAdd }
procedure SF_DAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script DAdd');
  CurrentScript.BuildDialogAnswer(av[1].GetInt);
end;
{ @end $60E1CC }

{ @routine $60E248 SF_DAnswer }
procedure SF_DAnswer(av: array of TVarEC; code: TCodeEC);
var Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DAnswer');
  if GetPlayer.IsDockedToShip then
  begin
    if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'takeoff' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptTakeoffChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptTakeoffChoice('');
    end
    else if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'exit') or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'fastexit') then
    begin
      if GetPlayer.RuinsMode > 0 then GetPlayer.CloseRuinsModeScreen
      else RuinsTalkScreen.ContinueScriptDialog;
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'continue' then
    begin
      RuinsTalkScreen.ContinueScriptDialog;
    end
    else if LowerCase(AnsiString(av[1].GetString)) = 'main' then
    begin
      RuinsTalkScreen.M_Main(False);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'exit_news' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptNewsExitChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptNewsExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'exit_end' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptGameEndChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptGameEndChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'hangar' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptHangarChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptHangarChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'goods' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptGoodsChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptGoodsChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback)
      else
        RuinsTalkScreen.AddChoice('', 0, ScriptDialogBlockCallback);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'), CurrentScript.CurrentAnswer, RuinsTalkScreen.RunScriptAnswerKeepingScroll)
      else
        RuinsTalkScreen.AddChoice('', CurrentScript.CurrentAnswer, RuinsTalkScreen.RunScriptAnswerKeepingScroll);
    end
    else
      RuinsTalkScreen.AddChoice('- ' + av[1].GetString, CurrentScript.CurrentAnswer, RuinsTalkScreen.RunScriptAnswer);
  end
  else if not GetPlayer.IsOnPlanet then
  begin
    if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'exit') or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'takeoff') then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        TalkScreen.AddScriptExitChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'fastexit' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        TalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'), 0, TalkScreen.FastExit, 0)
      else
        TalkScreen.AddChoice('', 0, TalkScreen.FastExit, 0);
    end
    else if LowerCase(AnsiString(av[1].GetString)) = 'main' then
    begin
      ScriptDialogIndex := -1;
      TalkScreen.CodeMsgOut(True);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'exit_end' then
    begin
      GameEndReason := gerTerronConversion;
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        TalkScreen.AddScriptExitChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        TalkScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        TalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback, 0)
      else
        TalkScreen.AddChoice('', 0, ScriptDialogBlockCallback, 0);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        TalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'), CurrentScript.CurrentAnswer, TalkScreen.RunScriptAnswerKeepingScroll, 0)
      else
        TalkScreen.AddChoice('', CurrentScript.CurrentAnswer, TalkScreen.RunScriptAnswerKeepingScroll, 0);
    end
    else
      TalkScreen.AddChoice('- ' + av[1].GetString, CurrentScript.CurrentAnswer, TalkScreen.RunScriptAnswer, 0);
  end
  else
  begin
    if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'takeoff' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptTakeoffChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptTakeoffChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'planet' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptPlanetChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptPlanetChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'goods' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptGoodsChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptGoodsChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'shop' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptShopChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptShopChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'hangar' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptHangarChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptHangarChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'exit_news' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptNewsExitChoice(ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptNewsExitChoice('');
    end
    else if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'exit') or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'fastexit') then
    begin
      GovernmentScreen.ContinueScriptDialog;
    end
    else if LowerCase(AnsiString(av[1].GetString)) = 'main' then
    begin
      GovernmentScreen.BuildGovernmentChoices(False);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback)
      else
        GovernmentScreen.AddChoice('', 0, ScriptDialogBlockCallback);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].GetString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].GetString, '~');
      if Count > 1 then
        GovernmentScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].GetString, 1, Count - 1, '~'), CurrentScript.CurrentAnswer, GovernmentScreen.RunScriptAnswerKeepingScroll)
      else
        GovernmentScreen.AddChoice('', CurrentScript.CurrentAnswer, GovernmentScreen.RunScriptAnswerKeepingScroll);
    end
    else
      GovernmentScreen.AddChoice('- ' + av[1].GetString, CurrentScript.CurrentAnswer, GovernmentScreen.RunScriptAnswer);
  end;
end;
{ @end $60E248 }

{ @routine $610478 SF_DChange }
procedure SF_DChange(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script DChange');
  ScriptDialogIndex := av[1].GetInt;
end;
{ @end $610478 }

{ @routine $6104F4 SF_Player }
procedure SF_Player(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetDword(Cardinal(GetPlayer));
end;
{ @end $6104F4 }

{ @routine $610530 SF_ItemExist }
procedure SF_ItemExist(av: array of TVarEC; code: TCodeEC);
var
  Item: TScriptItem;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ItemExist');
  Item := TScriptItem(av[1].GetDword);
  if Item.Item = nil then av[0].SetInt(0) else av[0].SetInt(1);
end;
{ @end $610530 }

{ @routine $6105CC SF_ItemIn }
procedure SF_ItemIn(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Ship: TShip;
  Planet: TPlanet;
  Obj: TObject;
  Item: TItem;
  Binding: TScriptShip;
  I: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ItemInStar');
  Obj := TObject(av[1].GetDword);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item else Item := TItem(Obj);
  if Item = nil then
  begin
    av[0].SetInt(0);
    Exit;
  end;

  Obj := TObject(av[2].GetDword);
  if Cardinal(Obj) < $10000 then
  begin
    for I := 0 to CurrentScript.Ships.Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      { Native group lookup excludes inventory slot zero. }
      if (Binding.GroupIndex = Integer(Obj)) and
        ((Binding.Ship.Inventory.IndexOf(Item) > 0) or (Binding.Ship.Artefacts.IndexOf(Item) > 0)) then
      begin
        av[0].SetInt(1);
        Exit;
      end;
    end;
    av[0].SetInt(0);
  end
  else if Obj is TStar then
  begin
    Star := Obj as TStar;
    if Star.Items.IndexOf(Item) < 0 then av[0].SetInt(0) else av[0].SetInt(1);
  end
  else if Obj is TShip then
  begin
    Ship := Obj as TShip;
    if (Ship.Inventory.IndexOf(Item) < 0) and (Ship.Artefacts.IndexOf(Item) < 0) then av[0].SetInt(0)
    else av[0].SetInt(1);
  end
  else if Obj is TPlanet then
  begin
    Planet := Obj as TPlanet;
    if (GetPlayer.CurrentPlanet = Planet) and (TemporaryShopSlots <> nil) then
    begin
      if FindShopSlotByItem(Item) = nil then av[0].SetInt(0) else av[0].SetInt(1);
    end
    else if Planet.EquipmentShop.IndexOf(Item) < 0 then av[0].SetInt(0) else av[0].SetInt(1);
  end;
end;
{ @end $6105CC }

{ @routine $610898 SF_ItemCount }
procedure SF_ItemCount(av: array of TVarEC; code: TCodeEC);
var
  Kind: Byte;
  Ship: TShip;
  I, Count: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script SF_ItemCount');
  Ship := TShip(av[1].GetDword);
  Kind := av[2].GetInt;
  Count := 0;
  for I := 0 to Ship.Inventory.Count - 1 do
    if TItem(Ship.Inventory[I]).ItemType = TItemType(Kind) then Inc(Count);
  for I := 0 to Ship.Artefacts.Count - 1 do
    if TItem(Ship.Artefacts[I]).ItemType = TItemType(Kind) then Inc(Count);
  av[0].SetInt(Count);
end;
{ @end $610898 }

{ @routine $6109B0 SF_DecayGoods }
procedure SF_DecayGoods(av: array of TVarEC; code: TCodeEC);
var
  Kind: Byte;
  Obj: TObject;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script DecayGoods');
  Kind := av[2].GetInt;
  Obj := TObject(av[1].GetDword);
  if Obj is TPlanet then (Obj as TPlanet).ForceGoodsScarcity(True, [Kind]);
end;
{ @end $6109B0 }

{ @routine $610A6C SF_UpsurgeGoods }
procedure SF_UpsurgeGoods(av: array of TVarEC; code: TCodeEC);
var
  Kind: Byte;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script DecayGoods');
  Kind := av[2].GetInt;
  TPlanet(av[1].GetDword).ForceGoodsSurplus(True, [Kind]);
end;
{ @end $610A6C }

{ @routine $610B04 SF_GoodsAdd }
procedure SF_GoodsAdd(av: array of TVarEC; code: TCodeEC);
var
  Kind: Byte;
  Obj: TObject;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script GoodsAdd');
  Kind := av[2].GetInt;
  Obj := TObject(av[1].GetDword);
  if Obj is TPlanet then
    with TPlanet(Obj).Goods[Kind] do
    begin
      Inc(Count, av[3].GetInt);
      av[0].SetInt(Count);
    end
  else if Obj is TRuins then
    with TRuins(Obj).ShopGoods[Kind] do
    begin
      Inc(Count, av[3].GetInt);
      av[0].SetInt(Count);
    end
  else if Obj is TShip then
    with TShip(Obj).CargoGoods[Kind] do
    begin
      Inc(Count, av[3].GetInt);
      av[0].SetInt(Count);
    end;
end;
{ @end $610B04 }

{ @routine $610C58 SF_GoodsCount }
procedure SF_GoodsCount(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: Byte;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GoodsCount');
  Ship := TShip(av[1].GetDword);
  Kind := av[2].GetInt;
  av[0].SetInt(Ship.CargoGoods[Kind].Count);
end;
{ @end $610C58 }

{ @routine $610CF4 SF_GoodsCost }
procedure SF_GoodsCost(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: Byte;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GoodsCost');
  Ship := TShip(av[1].GetDword);
  Kind := av[2].GetInt;
  av[0].SetInt(Ship.CargoGoods[Kind].TotalCost);
end;
{ @end $610CF4 }

{ @routine $610D90 SF_GoodsRuinsForBuy }
procedure SF_GoodsRuinsForBuy(av: array of TVarEC; code: TCodeEC);
var
  Kind: Byte;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GoodsRuinsForBuy');
  Kind := av[2].GetInt;
  TRuins(av[1].GetDword).ForceGoodsForSale([Kind]);
end;
{ @end $610D90 }

{ @routine $610E30 SF_ShipGoods }
procedure SF_ShipGoods(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: Byte;
  Quantity, Cost: Integer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipGoods');
  Ship := TShip(av[1].GetDword);
  Kind := av[2].GetInt;
  Quantity := av[3].GetInt;
  Quantity := Max(Quantity, -Ship.CargoGoods[Kind].Count);
  if High(av) > 3 then Cost := av[4].GetInt
  else if Quantity > 0 then Cost := Quantity * GoodsMarket[Kind].AveragePrice
  else Cost := Round(Quantity * Ship.CargoGoods[Kind].TotalCost / Ship.CargoGoods[Kind].Count);
  Inc(Ship.CargoGoods[Kind].Count, Quantity);
  Inc(Ship.CargoGoods[Kind].TotalCost, Cost);
end;
{ @end $610E30 }

{ @routine $610F80 SF_ShipGoodsIllegalOnPlanet }
procedure SF_ShipGoodsIllegalOnPlanet(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Planet: TPlanet;
  Kind: Byte;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipGoodsIllegalOnPlanet');
  Ship := TShip(av[1].GetDword);
  Kind := av[2].GetInt;
  Planet := TPlanet(av[3].GetDword);
  av[0].SetInt(0);
  if (Kind in [Ord(t_Food)..Ord(t_Narcotics)]) and (Planet.OwnerId <> oiPirate) then
  begin
    if not GoodsLegalOnPlanet[Kind, Planet.RaceId, Planet.Government] then av[0].SetInt(1)
    else if (Kind in [Ord(t_Food), Ord(t_Medicine)]) and Ship.IsHealthEffectActive(12) then av[0].SetInt(1);
  end;
end;
{ @end $610F80 }

{ @routine $6110A4 SF_GoodsDrop }
procedure SF_GoodsDrop(av: array of TVarEC; code: TCodeEC);
var
  Kind: Byte;
  Ship: TShip;
  Quantity: Integer;
  Item: TItem;
  ScriptItem: TScriptItem;
  Goods: TGoods;
  Angle: Single;
  Star: TStar;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script GoodsDrop');
  Ship := TShip(av[1].GetDword);
  Kind := av[2].GetInt;
  Quantity := Min(Ship.CargoGoods[Kind].Count, av[3].GetInt);
  if Quantity < 1 then
  begin
    av[0].SetInt(0);
    Exit;
  end;

  if GetPlayer <> Ship then
  begin
    Ship.DropGoodsIntoSpace(Kind, Quantity);
    Item := PMovingDropItemEntry(Ship.CurrentStar.MovingDropItems[Ship.CurrentStar.MovingDropItems.Count - 1]).Payload as TItem;
  end
  else
  begin
    SoundManager.PlaySound('Sound.Drop');
    Dec(Ship.CargoGoods[Kind].Count, Quantity);
    Star := GetPlayer.CurrentStar;
    Goods := TGoods.Create;
    Goods.Init(TItemType(Kind), Quantity);
    Star.Items.Add(Goods);
    Angle := SeededRandomIntRange(0, 360, Kind * (Cardinal(Galaxy.CurrentTurn) * GetPlayer.CurrentStar.GenerationSeed)) * Pi / 180;
    Goods.Position.X := GetPlayer.Position.X + Sin(Angle) * 100;
    Goods.Position.Y := GetPlayer.Position.Y - Cos(Angle) * 100;
    Goods.GetGraphObject.SetPosition(Goods.Position);
    Item := Goods;
  end;
  if High(av) >= 4 then
  begin
    ScriptItem := TScriptItem(av[4].GetDword);
    if ScriptItem.Item <> nil then ScriptItem.Item.ScriptItem := nil;
    ScriptItem.Item := Item;
    Item.ScriptItem := ScriptItem;
  end;
  av[0].SetInt(1);
end;
{ @end $6110A4 }

{ @routine $61134C SF_UselessItemCreate }
procedure SF_UselessItemCreate(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  ScriptItem: TScriptItem;
  Place: TScriptPlace;
  Angle: Single;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script UselessItemCreate');
  Item := TUselessItem.Create;
  (Item as TUselessItem).Init(av[1].GetString, TDominatorSeries(RandomIntRange(0, 2)), 0, False);
  ScriptItem := TScriptItem(av[2].GetDword);
  if ScriptItem.Item <> nil then ScriptItem.Item.ScriptItem := nil;
  ScriptItem.Item := Item;
  Item.ScriptItem := ScriptItem;
  Place := TScriptPlace(av[3].GetDword);
  if not (Place.PlaceKind in [spkPolar, spkPlanetPosition, spkStarDirection, spkGroupCentroid, spkCoordinates]) then RaiseWideMessage('Error.Script UselessItemCreate place');
  Place.OriginStar.Items.Add(Item);
  Item.Position := Place.GetPoint;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Item.Id * Place.OriginStar.GenerationSeed));
  Item.Position.X := Item.Position.X + Sin(Angle) * Place.Radius;
  Item.Position.Y := Item.Position.Y - Cos(Angle) * Place.Radius;
end;
{ @end $61134C }

{ @routine $61158C SF_GoodsSellPrice }
procedure SF_GoodsSellPrice(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Kind: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GoodsSellPrice');
  Obj := TObject(av[1].GetDword);
  Kind := av[2].GetInt;
  if Obj is TRuins then av[0].SetInt(TRuins(Obj).ShopGoods[Kind].BaseSalePrice)
  else av[0].SetInt(TPlanet(Obj).Goods[Kind].BaseSalePrice);
  if High(av) > 2 then
  begin
    if Obj is TRuins then TRuins(Obj).ShopGoods[Kind].BaseSalePrice := av[3].GetInt
    else TPlanet(Obj).Goods[Kind].BaseSalePrice := av[3].GetInt;
  end;
end;
{ @end $61158C }

{ @routine $6116B0 SF_GoodsBuyPrice }
procedure SF_GoodsBuyPrice(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Kind: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GoodsSellPrice');
  Obj := TObject(av[1].GetDword);
  Kind := av[2].GetInt;
  if Obj is TRuins then av[0].SetInt(TRuins(Obj).ShopGoods[Kind].PurchasePrice)
  else av[0].SetInt(TPlanet(Obj).Goods[Kind].PurchasePrice);
  if High(av) > 2 then
  begin
    if Obj is TRuins then TRuins(Obj).ShopGoods[Kind].PurchasePrice := av[3].GetInt
    else TPlanet(Obj).Goods[Kind].PurchasePrice := av[3].GetInt;
  end;
end;
{ @end $6116B0 }

{ @routine $6117D4 SF_CountTurn }
procedure SF_CountTurn(av: array of TVarEC; code: TCodeEC);
var
  Ship, OtherShip: TShip;
  Turns: Integer;
  Obj: TObject;
  Planet: TPlanet;
  Place: TScriptPlace;
  Landed: Boolean;
  Position: TPointF;
  Star: TStar;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script CountTurn');
  Turns := 0;
  Ship := TShip(av[1].GetDword);
  Obj := TObject(av[2].GetDword);
  if Obj is TScriptPlace then
  begin
    Place := Obj as TScriptPlace;
    if (Place.PlaceKind = spkPlanetPosition) or (Place.PlaceKind = spkDockedPlanet) then
    begin
      Planet := TObject(Place.TargetValue) as TPlanet;
      Position := Planet.GetPosition;
    end
    else
    begin
      Planet := nil;
      Position := Place.GetPoint;
    end;
    Landed := Place.PlaceKind = spkDockedPlanet;
    Star := Place.OriginStar;
  end
  else if Obj is TPlanet then
  begin
    Planet := Obj as TPlanet;
    Landed := False;
    Position := Planet.GetPosition;
    Star := Planet.CurrentStar;
  end
  else if Obj is TShip then
  begin
    Landed := False;
    Planet := nil;
    OtherShip := Obj as TShip;
    while OtherShip.DockedTo <> nil do OtherShip := OtherShip.DockedTo;
    if OtherShip.CurrentPlanet <> nil then
    begin
      Planet := OtherShip.CurrentPlanet;
      Landed := True;
      Position := Planet.GetPosition;
      Star := Planet.CurrentStar;
    end
    else
    begin
      Position := OtherShip.Position;
      Star := OtherShip.CurrentStar;
      if OtherShip.InHyperspace then Position := OtherShip.GetArrivalPosition(OtherShip.TransitOriginStar);
    end;
  end
  else raise Exception.Create('Error.Script CountTurn 1');
  if (Ship.CurrentPlanet = Planet) and Landed then
  begin
    av[0].SetInt(0);
    Exit;
  end;
  if Ship.CurrentPlanet <> nil then Inc(Turns);
  if Landed then Inc(Turns);
  if (Ship.CurrentPlanet <> nil) and (Ship.CurrentPlanet = Planet) then
  begin
    av[0].SetInt(Turns);
    Exit;
  end;
  if Star = Ship.CurrentStar then
  begin
    if Ship.CurrentPlanet = nil then Inc(Turns, Ceil(PointDistance(Position, Ship.Position) / Max(1, Ship.Speed)))
    else Inc(Turns, Ceil(PointDistance(Position, Ship.CurrentPlanet.GetPosition) / Max(1, Ship.Speed)));
  end
  else
  begin
    if Ship.CurrentPlanet = nil then Inc(Turns, Ceil(PointDistance(Ship.GetJumpDeparturePoint(Star), Ship.Position) / Max(1, Ship.Speed)))
    else Inc(Turns, Ceil(PointDistance(Ship.GetJumpDeparturePoint(Star), Ship.CurrentPlanet.GetPosition) / Max(1, Ship.Speed)));
    Inc(Turns, Ship.CalculateJumpTravelDays(Ship.CurrentStar, Star));
    Inc(Turns, Ceil(PointDistance(Position, Ship.GetArrivalPosition(Star)) / Max(1, Ship.Speed)));
  end;
  av[0].SetInt(Turns);
end;
{ @end $6117D4 }

{ @routine $611C34 SF_ShipSetBad }
procedure SF_ShipSetBad(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ShipSetBad');
  if av[1].GetDword <> 0 then TShip(av[1].GetDword).EnemyShip := TShip(av[2].GetDword);
end;
{ @end $611C34 }

{ @routine $611CC8 SF_GroupSetBad }
procedure SF_GroupSetBad(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex, I, Count: Integer;
  Binding: TScriptShip;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GroupSetBad');
  GroupIndex := av[1].GetInt;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := TScriptShip(CurrentScript.Ships[I]);
    if Binding.GroupIndex = GroupIndex then Binding.Ship.EnemyShip := TShip(av[2].GetDword);
  end;
end;
{ @end $611CC8 }

{ @routine $611DA4 SF_ShipSetPartner }
procedure SF_ShipSetPartner(av: array of TVarEC; code: TCodeEC);
var
  Ship, Partner: TShip;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script ShipSetPartner');
  Ship := TShip(av[1].GetDword);
  Partner := TShip(av[2].GetDword);
  if (Ship is TPirate) and (Ship.PartnerShip <> Partner) then
  begin
    if GetPlayer = Ship.PartnerShip then GetPlayer.PiratePartners.Remove(Ship);
    if GetPlayer = Partner then GetPlayer.PiratePartners.Add(Ship);
  end;
  Ship.PartnerShip := Partner;
  Ship.PartnershipDaysRemaining := av[3].GetInt;
end;
{ @end $611DA4 }

{ @routine $611EAC SF_ShipJoin }
procedure SF_ShipJoin(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  StateIndex, I: Integer;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipJoin');
  Ship := TShip(av[2].GetDword);
  if Ship = nil then Exit;
  if (Ship <> GetPlayer) and (Ship.ScriptShip <> nil) then
  begin
    if TScriptShip(Ship.ScriptShip).Script <> CurrentScript then
      AppendLogLineThreadSafe(AnsiString('Warning.Script ShipJoin (' + CurrentScript.ScriptFileName +
        '): ship ' + Ship.GetFullName(' ') + ' was already in another script (' +
        TScriptShip(Ship.ScriptShip).Script.ScriptFileName + ')'));
    TScriptShip(Ship.ScriptShip).Script.UnbindShip(Ship);
    Ship.ScriptShip := nil;
  end;
  ScriptSnap(Snapshot);
  CurrentScript.BindShip(av[1].GetInt, Ship);
  Binding := GetScriptShipBindingForContext(Ship, CurrentScript);
  if (High(av) >= 3) and (av[3].RealVType = vkString) then
  begin
    StateIndex := -1;
    if av[3].GetString = '' then
      StateIndex := TScriptGroup(CurrentScript.Groups[Binding.GroupIndex]).InitialStateIndex
    else
      for I := 0 to CurrentScript.States.Count - 1 do
        if TScriptState(CurrentScript.States[I]).Name = av[3].GetString then
        begin
          StateIndex := I;
          Break;
        end;
    if StateIndex < 0 then
      raise Exception.Create('Error.Script ShipJoin cant find state ' + av[3].GetString);
  end
  { A nonstring third argument suppresses the state change; it is not a state index. }
  else if High(av) >= 3 then StateIndex := -1
  else StateIndex := TScriptGroup(CurrentScript.Groups[Binding.GroupIndex]).InitialStateIndex;
  if High(av) >= 4 then Binding.Data[0] := av[4].GetDword;
  if High(av) >= 5 then Binding.Data[1] := av[5].GetDword;
  if High(av) >= 6 then Binding.Data[2] := av[6].GetDword;
  if High(av) >= 7 then Binding.Data[3] := av[7].GetDword;
  if StateIndex >= 0 then CurrentScript.ChangeState(Binding, StateIndex);
  ScriptUnSnap(Snapshot);
end;
{ @end $611EAC }

{ @routine $61231C SF_ShipOut }
procedure SF_ShipOut(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then Ship := CurrentScript.CurrentShip
  else Ship := TShip(av[1].GetDword);
  if Ship = nil then Exit;
  if Ship = GetPlayer then CurrentScript.UnbindShip(Ship)
  else if Ship.ScriptShip <> nil then TScriptShip(Ship.ScriptShip).Script.UnbindShip(Ship);
end;
{ @end $61231C }

{ @routine $6123AC SF_AllShipOut }
procedure SF_AllShipOut(av: array of TVarEC; code: TCodeEC);
begin
  CurrentScript.ClearShipBindings;
end;
{ @end $6123AC }

{ @routine $6123E4 SF_ShipInScript }
procedure SF_ShipInScript(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInScript');
  if TShip(av[1].GetDword).HasScriptBindings or
    (((High(av) <= 1) or (av[2].GetInt <> 0)) and (TShip(av[1].GetDword).AbsoluteScriptOrder > 0)) then
    av[0].SetInt(1)
  else av[0].SetInt(0);
end;
{ @end $6123E4 }

{ @routine $6124A8 SF_ShipInGameEvent }
procedure SF_ShipInGameEvent(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipInGameEvent');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(0);
  if (Ship is TWarrior) and ((Ship as TWarrior).LiberationGroup <> nil) then av[0].SetInt(1);
  if (Ship is TRuins) and ((Ship as TRuins).FlyToStar <> nil) then av[0].SetInt(1);
end;
{ @end $6124A8 }

{ @routine $6125A0 SF_ShipInCurScript }
procedure SF_ShipInCurScript(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipInCurScript');
  if TShip(av[1].GetDword).HasScriptBindings and
    (GetScriptShipBindingForContext(TShip(av[1].GetDword), CurrentScript).Script = CurrentScript) then
    av[0].SetInt(1)
  else av[0].SetInt(0);
end;
{ @end $6125A0 }

{ @routine $612664 SF_ShipInNormalSpace }
procedure SF_ShipInNormalSpace(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipInNormalSpace');
  if (av[1].GetDword <> 0) and TShip(av[1].GetDword).InNormalSpace then av[0].SetInt(1)
  else av[0].SetInt(0);
end;
{ @end $612664 }

{ @routine $612714 SF_ShipInHole }
procedure SF_ShipInHole(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInHole');
  Ship := TShip(av[1].GetDword);
  if (High(av) > 1) and (av[2].GetInt <> 0) then
    while Ship.DockedTo <> nil do Ship := Ship.DockedTo;
  if Ship.InHyperspace and (Ship.Order = soJumpHole) then av[0].SetInt(1)
  else av[0].SetInt(0);
end;
{ @end $612714 }

{ @routine $6127E8 SF_ShipIsTakeoff }
procedure SF_ShipIsTakeoff(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipIsTakeoff');
  Ship := TShip(av[1].GetDword);
  if Ship.Order = soTakeoff then av[0].SetInt(1) else av[0].SetInt(0);
end;
{ @end $6127E8 }

{ @routine $61288C SF_ShipCntWeapon }
procedure SF_ShipCntWeapon(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipCntWeapon');
  av[0].SetInt(TShip(av[1].GetDword).WeaponCount);
end;
{ @end $61288C }

{ @routine $612914 SF_ShipWeapon }
procedure SF_ShipWeapon(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  I: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ShipWeapon');
  Ship := TShip(av[1].GetDword);
  I := av[2].GetInt;
  if (I <= 0) or (Ship.WeaponCount < I) then av[0].SetDword(0)
  else av[0].SetDword(Cardinal(Ship.Weapons[I]));
end;
{ @end $612914 }

{ @routine $6129D0 SF_ShipEqInSlot }
procedure SF_ShipEqInSlot(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  ItemType: TItemType;
  SlotIndex: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipEqInSlot');
  Ship := TShip(av[1].GetDword);
  ItemType := TItemType(av[2].GetInt);
  if ItemType in [t_Hull..t_DefGenerator] then av[0].SetDword(Cardinal(PShipEquipmentCacheView(Ship).Slots[ItemType]))
  else
  begin
    if High(av) < 3 then SlotIndex := 0 else SlotIndex := av[3].GetInt - 1;
    Ship.RefreshAssignedItemSlots;
    av[0].SetDword(Cardinal(Ship.FindEquippedItemInSlot(ItemType, SlotIndex)));
  end;
end;
{ @end $6129D0 }

{ @routine $612AB8 SF_ArtefactTypeInUse }
procedure SF_ArtefactTypeInUse(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TArtefact;
  ItemType: TItemType;
  Name: WideString;
  I, Count: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ArtefactTypeInUse');
  Ship := TShip(av[1].GetDword);
  Item := nil;
  if (av[2].RealVType = vkDword) and (av[2].GetDword > $FFFF) then Item := TArtefact(av[2].GetDword);
  Name := '';
  if (Item <> nil) and (Item.GetEffectiveType in [t_Artefact, t_Artefact2]) then Name := Item.ConfigBlockName
  else if av[2].RealVType = vkString then Name := av[2].GetString;
  if Name <> '' then
  begin
    Count := 0;
    for I := 0 to Ship.Artefacts.Count - 1 do
    begin
      Item := TArtefact(Ship.Artefacts[I]);
      if (Item.ItemType in [t_Artefact, t_Artefact2]) and (Item.ConfigBlockName = Name) and
        (Item.BrokenFlag = 0) and (Item.EquippedFlag <> 0) then Inc(Count);
    end;
    av[0].SetInt(Count);
  end
  else
  begin
    if Item <> nil then ItemType := TArtefact(av[2].GetDword).GetEffectiveType
    else ItemType := TItemType(av[2].GetInt);
    av[0].SetInt(Ship.CountActiveArtefacts(ItemType));
  end;
end;
{ @end $612AB8 }

{ @routine $612CAC SF_ArtefactTypeBoosted }
procedure SF_ArtefactTypeBoosted(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  ItemType: TItemType;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ArtefactTypeBoosted');
  Ship := TShip(av[1].GetDword);
  if (av[2].RealVType = vkDword) and (av[2].GetDword > $FF) then
    ItemType := TArtefact(av[2].GetDword).GetEffectiveType
  else ItemType := TItemType(av[2].GetInt);
  av[0].SetInt(Ord(Ship.CanBoostArtefact(ItemType, nil, False)));
end;
{ @end $612CAC }

{ @routine $612D90 SF_ShipGroup }
procedure SF_ShipGroup(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipGroup');
  Binding := GetScriptShipBindingForContext(TShip(av[1].GetDword), CurrentScript);
  if Binding <> nil then av[0].SetInt(Binding.GroupIndex)
  else av[0].SetInt(-1);
end;
{ @end $612D90 }

{ @routine $612E38 SF_ShipSpeed }
procedure SF_ShipSpeed(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipSpeed');
  av[0].SetInt(TShip(av[1].GetDword).Speed);
end;
{ @end $612E38 }

{ @routine $612EBC SF_EnginePower }
procedure SF_EnginePower(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Engine: TEngine;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EnginePower');
  Obj := TObject(av[1].GetDword);
  Engine := nil;
  if Obj is TEngine then Engine := TEngine(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item <> nil) and ((Obj as TScriptItem).Item is TEngine) then
    Engine := TEngine((Obj as TScriptItem).Item)
  else if Obj is TShip then Engine := TShip(Obj).GetEngine;
  if Engine <> nil then
  begin
    av[0].SetInt(Engine.OutputPercent);
    if High(av) > 1 then Engine.OutputPercent := av[2].GetInt;
  end
  else av[0].SetInt(0);
end;
{ @end $612EBC }

{ @routine $61300C SF_ShipJump }
procedure SF_ShipJump(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipJump');
  av[0].SetInt(TShip(av[1].GetDword).GetJumpRange);
end;
{ @end $61300C }

{ @routine $613090 SF_ShipArmor }
procedure SF_ShipArmor(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipArmor');
  av[0].SetInt(TShip(av[1].GetDword).GetArmor);
end;
{ @end $613090 }

{ @routine $613114 SF_ShipProtectability }
procedure SF_ShipProtectability(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipProtectability');
  av[0].SetInt(Round((1 - TShip(av[1].GetDword).GetDefenseDamageFactor) * 100));
end;
{ @end $613114 }

{ @routine $6131B8 SF_ShipDroidRepair }
procedure SF_ShipDroidRepair(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipDroidRepair');
  av[0].SetInt(0);
  Ship := TShip(av[1].GetDword);
  if Ship.IsEquipmentUsable(Ship.GetRepairRobot) then av[0].SetInt(Ship.CalculateRepairPoints(Ship.GetRepairRobot));
end;
{ @end $6131B8 }

{ @routine $613274 SF_ShipRadarRange }
procedure SF_ShipRadarRange(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipRadarRange');
  av[0].SetInt(TShip(av[1].GetDword).GetRadarRange);
end;
{ @end $613274 }

{ @routine $6132FC SF_ShipScanerPower }
procedure SF_ShipScanerPower(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipScanerPower');
  av[0].SetInt(TShip(av[1].GetDword).GetScannerPower);
end;
{ @end $6132FC }

{ @routine $613388 SF_ShipHookPower }
procedure SF_ShipHookPower(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipHookPower');
  av[0].SetInt(0);
  Ship := TShip(av[1].GetDword);
  if Ship.IsEquipmentUsable(Ship.GetCargoHook) then av[0].SetInt(Ship.CalculateCargoHookPower(Ship.GetCargoHook));
end;
{ @end $613388 }

{ @routine $613440 SF_ShipHookRange }
procedure SF_ShipHookRange(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipHookRange');
  av[0].SetInt(0);
  Ship := TShip(av[1].GetDword);
  if Ship.IsEquipmentUsable(Ship.GetCargoHook) then av[0].SetInt(Ship.GetCargoHookRange);
end;
{ @end $613440 }

{ @routine $6134F0 SF_ShipAverageDamage }
procedure SF_ShipAverageDamage(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  I, MinDamage, MaxDamage: Integer;
  Weapon: TWeapon;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipAverageDamage');
  Ship := TShip(av[1].GetDword);
  MinDamage := 0;
  MaxDamage := 0;
  for I := 1 to Ship.WeaponCount do
  begin
    Weapon := Ship.Weapons[I];
    if Ship.IsEquipmentUsable(Weapon) then
    begin
      if Weapon.GetWeaponInfo.ShotType in [wstMissile, wstRocket] then
      begin
        MinDamage := MinDamage + Ship.GetWeaponMinDamage(Weapon) * Weapon.GetAttackCount * Weapon.GetShotCount;
        MaxDamage := MaxDamage + Ship.GetWeaponMaxDamage(Weapon) * Weapon.GetAttackCount * Weapon.GetShotCount;
      end
      else
      begin
        MinDamage := MinDamage + Ship.GetWeaponMinDamage(Weapon) * Weapon.GetAttackCount;
        MaxDamage := MaxDamage + Ship.GetWeaponMaxDamage(Weapon) * Weapon.GetAttackCount;
      end;
    end;
  end;
  if High(av) > 1 then
  begin
    if av[2].GetInt = 0 then av[0].SetInt(MinDamage)
    else if av[2].GetInt = 1 then av[0].SetInt(MaxDamage)
    else av[0].SetInt(Round((MinDamage + MaxDamage) * 0.5));
  end
  else av[0].SetInt(Round((MinDamage + MaxDamage) * 0.5));
end;
{ @end $6134F0 }

{ @routine $6136E4 SF_ShipHealthFactor }
procedure SF_ShipHealthFactor(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Remaining, Duration: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipHealthFactor');
  Ship := TShip(av[1].GetDword);
  Index := av[2].GetInt;
  Remaining := 0;
  if Ship = nil then
  begin
    if Index = 0 then av[0].SetInt(RadiationHealthDefinitions[1].Duration)
    else av[0].SetInt(CaptainHealthDefinitions[Index].Duration);
    Exit;
  end;
  if Index = 0 then
  begin
    if Ship.HasRadiationSickness then Remaining := Ship.RadiationHealth[1].ExpireTurn - Galaxy.CurrentTurn;
    if High(av) > 2 then
    begin
      Duration := av[3].GetInt;
      if Duration = -1 then Duration := RadiationHealthDefinitions[1].Duration;
      if Duration = 0 then
      begin
        Ship.RadiationHealth[1].Progress := 0;
        Ship.RadiationHealth[1].ExpireTurn := 0;
      end;
      if (Remaining = 0) and (Duration > 0) then
      begin
        Ship.RadiationHealth[1].Progress := 0.5;
        Ship.RadiationHealth[1].ExpireTurn := Galaxy.CurrentTurn + Duration;
      end;
      if (Remaining > 0) and (Duration > 0) then Ship.RadiationHealth[1].ExpireTurn := Galaxy.CurrentTurn + Duration;
    end;
  end
  else if (Index > 0) and (Index <= 24) then
  begin
    if Ship.IsHealthEffectActive(Index) then Remaining := Ship.CaptainHealth[Index].ExpireTurn - Galaxy.CurrentTurn;
    if High(av) > 2 then
    begin
      Duration := av[3].GetInt;
      if Duration = -1 then Duration := CaptainHealthDefinitions[Index].Duration;
      if Duration = 0 then
      begin
        Ship.CaptainHealth[Index].Progress := 0;
        Ship.CaptainHealth[Index].ExpireTurn := 0;
      end;
      if (Remaining = 0) and (Duration > 0) then
      begin
        Ship.CaptainHealth[Index].Progress := 100;
        Ship.CaptainHealth[Index].ExpireTurn := Galaxy.CurrentTurn + Duration;
      end;
      if (Remaining > 0) and (Duration > 0) then Ship.CaptainHealth[Index].ExpireTurn := Galaxy.CurrentTurn + Duration;
    end;
  end;
  av[0].SetInt(Remaining);
end;
{ @end $6136E4 }

{ @routine $6139B4 SF_ShipHealthFactorStatus }
procedure SF_ShipHealthFactorStatus(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipHealthFactorStatus');
  Ship := TShip(av[1].GetDword);
  Index := av[2].GetInt;
  if Index = 0 then
  begin
    av[0].SetFloat(Ship.RadiationHealth[1].Progress);
    if High(av) > 2 then Ship.RadiationHealth[1].Progress := av[3].GetFloat;
  end
  else if (Index > 0) and (Index <= 24) then
  begin
    av[0].SetInt(Round(Ship.CaptainHealth[Index].Progress));
    if High(av) > 2 then Ship.CaptainHealth[Index].Progress := av[3].GetInt;
  end
  else av[0].SetInt(0);
end;
{ @end $6139B4 }

{ @routine $613AE4 SF_PlayerImmunity }
procedure SF_PlayerImmunity(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.DiseaseImmunity);
  if High(av) >= 1 then GetPlayer.DiseaseImmunity := av[1].GetInt;
end;
{ @end $613AE4 }

{ @routine $613B44 SF_ShipStatusEffect }
procedure SF_ShipStatusEffect(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  EffectType: TCombatStatusEffectType;
  Index: Integer;
  Strength: Single;
  Source: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipStatusEffect');
  Ship := TShip(av[1].GetDword);
  EffectType := TCombatStatusEffectType(av[2].GetInt);
  Index := Ship.FindCombatStatusEffect(EffectType);
  if Index < 0 then av[0].SetFloat(0)
  else av[0].SetFloat(PCombatStatusEffect(Ship.CombatStatusEffects[Index]).Strength);
  if High(av) > 2 then
  begin
    Strength := av[3].GetFloat;
    if High(av) > 3 then Source := TShip(av[4].GetDword) else Source := nil;
    if Strength > 0 then Ship.AddCombatStatusStrength(EffectType, Strength, Source)
    else if Strength < 0 then Ship.ReduceCombatStatusStrength(EffectType, -Strength);
  end;
end;
{ @end $613B44 }

{ @routine $613C94 SF_GroupIs }
procedure SF_GroupIs(av: array of TVarEC; code: TCodeEC);
var
  I, Count, GroupIndex: Integer;
  Binding: TScriptShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GroupIs');
  Binding := GetScriptShipBindingForContext(TShip(av[1].GetDword), CurrentScript);
  if (Binding = nil) or (Binding.Script <> CurrentScript) then
  begin
    av[0].SetInt(0);
    Exit;
  end;
  GroupIndex := Binding.GroupIndex;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
    if av[2 + I].GetInt = GroupIndex then
    begin
      av[0].SetInt(1);
      Exit;
    end;
  av[0].SetInt(0);
end;
{ @end $613C94 }

{ @routine $613D9C SF_StateIs }
procedure SF_StateIs(av: array of TVarEC; code: TCodeEC);
var
  I, Count: Integer;
  State: TScriptState;
  Binding: TScriptShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StateIs');
  Binding := GetScriptShipBindingForContext(TShip(av[1].GetDword), CurrentScript);
  if Binding = nil then
  begin
    av[0].SetInt(0);
    Exit;
  end;
  State := Binding.State;
  if State = nil then
  begin
    av[0].SetInt(0);
    Exit;
  end;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
    if State.Name = av[2 + I].GetString then
    begin
      av[0].SetInt(1);
      Exit;
    end;
  av[0].SetInt(0);
end;
{ @end $613D9C }

{ @routine $613EE8 SF_Dist }
procedure SF_Dist(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Point1, Point2: TPointF;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script Dist');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj <> nil then
  begin
    if Obj is TShip then Point1 := (Obj as TShip).Position
    else if Obj is TItem then Point1 := (Obj as TItem).Position
    else if Obj is TScriptItem then
    begin
      if (Obj as TScriptItem).Item <> nil then Point1 := (Obj as TScriptItem).Item.Position
      else raise Exception.Create('Error.Script Dist 1');
    end
    else if Obj is TScriptPlace then Point1 := (Obj as TScriptPlace).GetPoint
    else if Obj is TPlanet then Point1 := (Obj as TPlanet).GetPosition
    else if Obj is TStar then Point1 := (Obj as TStar).Position
    else if Obj is TAsteroid then Point1 := (Obj as TAsteroid).Position
    else if Obj is TMissile then Point1 := (Obj as TMissile).Position
    else raise Exception.Create('Error.Script Dist 2');
    Obj := TObject(av[2].GetDword);
    if Obj <> nil then
    begin
      if Obj is TShip then Point2 := (Obj as TShip).Position
      else if Obj is TItem then Point2 := (Obj as TItem).Position
      else if Obj is TScriptItem then
      begin
        if (Obj as TScriptItem).Item <> nil then Point2 := (Obj as TScriptItem).Item.Position
        else raise Exception.Create('Error.Script Dist 3');
      end
      else if Obj is TScriptPlace then Point2 := (Obj as TScriptPlace).GetPoint
      else if Obj is TPlanet then Point2 := (Obj as TPlanet).GetPosition
      else if Obj is TStar then Point2 := (Obj as TStar).Position
      else if Obj is TAsteroid then Point2 := (Obj as TAsteroid).Position
      else if Obj is TMissile then Point2 := (Obj as TMissile).Position
      else raise Exception.Create('Error.Script Dist 4');
      av[0].SetInt(Round(PointDistance(Point1, Point2)));
    end;
  end;
end;
{ @end $613EE8 }

{ @routine $614390 SF_Angle }
procedure SF_Angle(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Point1, Point2: TPointF;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script Angle');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj <> nil then
  begin
    if Obj is TShip then Point1 := (Obj as TShip).Position
    else if Obj is TItem then Point1 := (Obj as TItem).Position
    else if Obj is TScriptItem then
    begin
      if (Obj as TScriptItem).Item <> nil then Point1 := (Obj as TScriptItem).Item.Position
      else raise Exception.Create('Error.Script Dist 1');
    end
    else if Obj is TScriptPlace then Point1 := (Obj as TScriptPlace).GetPoint
    else if Obj is TPlanet then Point1 := (Obj as TPlanet).GetPosition
    else if Obj is TStar then Point1 := (Obj as TStar).Position
    else if Obj is TAsteroid then Point1 := (Obj as TAsteroid).Position
    else if Obj is TMissile then Point1 := (Obj as TMissile).Position
    else raise Exception.Create('Error.Script Dist 2');
    Obj := TObject(av[2].GetDword);
    if Obj <> nil then
    begin
      if Obj is TShip then Point2 := (Obj as TShip).Position
      else if Obj is TItem then Point2 := (Obj as TItem).Position
      else if Obj is TScriptItem then
      begin
        if (Obj as TScriptItem).Item <> nil then Point2 := (Obj as TScriptItem).Item.Position
        else raise Exception.Create('Error.Script Dist 3');
      end
      else if Obj is TScriptPlace then Point2 := (Obj as TScriptPlace).GetPoint
      else if Obj is TPlanet then Point2 := (Obj as TPlanet).GetPosition
      else if Obj is TStar then Point2 := (Obj as TStar).Position
      else if Obj is TAsteroid then Point2 := (Obj as TAsteroid).Position
      else if Obj is TMissile then Point2 := (Obj as TMissile).Position
      else raise Exception.Create('Error.Script Dist 4');
      av[0].SetInt(Round(PointBearingDegrees(Point2, Point1)));
    end;
  end;
end;
{ @end $614390 }

{ @routine $614838 SF_Dist2Star }
procedure SF_Dist2Star(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script DistStar');
  av[0].SetFloat(PointDistanceSquared(TStar(av[1].GetDword).Position, TStar(av[2].GetDword).Position));
end;
{ @end $614838 }

{ @routine $6148D4 SF_BuyPirate }
procedure SF_BuyPirate(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TPirate;
  MoneyPercent: Integer;
  WasMainPiratePlanet: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyPirate');
  MoneyPercent := 100;
  if High(av) > 1 then MoneyPercent := av[2].GetInt;
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    WasMainPiratePlanet := Planet.IsMainPiratePlanet;
    Planet.IsMainPiratePlanet := False;
    Ship := Planet.BuyPirate(MoneyPercent);
    Planet.IsMainPiratePlanet := WasMainPiratePlanet;
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $6148D4 }

{ @routine $6149A8 SF_BuyTransport }
procedure SF_BuyTransport(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TTransport;
  Kind: Byte;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyTransport');
  Planet := TPlanet(av[1].GetDword);
  MoneyPercent := 100;
  if High(av) > 2 then MoneyPercent := av[3].GetInt;
  if Planet <> nil then
  begin
    if High(av) > 1 then
      case av[2].GetInt of
        0: Kind := 3;
        1: Kind := 4;
        2: Kind := 5;
      else Kind := 0;
      end
    else Kind := 0;
    Ship := Planet.SpawnTransport(Kind, MoneyPercent);
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $6149A8 }

{ @routine $614A98 SF_Name }
procedure SF_Name(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Name');
  Obj := TObject(av[1].GetDword);
  if Obj is TStar then av[0].SetString(TStar(Obj).Name)
  else if Obj is TConstellation then av[0].SetString(TConstellation(Obj).GetName)
  else if Obj is TPlanet then av[0].SetString(TPlanet(Obj).Name)
  else if Obj is TShip then av[0].SetString(TShip(Obj).GetFullName(' '))
  else if Obj is TScriptItem then
  begin
    if TScriptItem(Obj).Item = nil then av[0].SetString('NameError')
    else av[0].SetString(TScriptItem(Obj).Item.GetDisplayName);
  end
  else if Obj is TItem then av[0].SetString(TItem(Obj).GetDisplayName)
  else av[0].SetString('NameError');
end;
{ @end $614A98 }

{ @routine $614C9C SF_ShortName }
procedure SF_ShortName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Name');
  Obj := TObject(av[1].GetDword);
  if Obj is TStar then av[0].SetString(TStar(Obj).Name)
  else if Obj is TPlanet then av[0].SetString(TPlanet(Obj).Name)
  else if Obj is TShip then av[0].SetString(TShip(Obj).GetName)
  else if Obj is TScriptItem then
  begin
    if TScriptItem(Obj).Item = nil then av[0].SetString('NameError')
    else av[0].SetString(TScriptItem(Obj).Item.GetShortName);
  end
  else if Obj is TItem then av[0].SetString(TItem(Obj).GetShortName)
  else av[0].SetString('NameError');
end;
{ @end $614C9C }

{ @routine $614E60 SF_FirstGiveMoney }
procedure SF_FirstGiveMoney(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Round(300 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].ArcadeRewardScale));
end;
{ @end $614E60 }

{ @routine $614EC4 SF_HaveProgramm }
procedure SF_HaveProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script HaveProgramm');
  av[0].SetInt(Ord(GetPlayer.HasProgram(TProgramIndex(av[1].GetDword))));
end;
{ @end $614EC4 }

{ @routine $614F54 SF_GetProgramm }
procedure SF_GetProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetProgramm');
  av[0].SetInt(GetPlayer.ProgramCounts[TProgramIndex(av[1].GetDword)]);
end;
{ @end $614F54 }

{ @routine $614FE4 SF_SetProgramm }
procedure SF_SetProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetProgramm');
  av[0].SetInt(Ord(GetPlayer.HasProgram(TProgramIndex(av[1].GetDword))));
  GetPlayer.ProgramCounts[TProgramIndex(av[1].GetDword)] := av[2].GetInt;
end;
{ @end $614FE4 }

{ @routine $6150A0 SF_DomikProgramm }
procedure SF_DomikProgramm(av: array of TVarEC; code: TCodeEC);
var
  Ship: TKling;
  ProgramId: TProgramIndex;
  Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DomikProgramm');
  Ship := TKling(av[1].GetDword);
  av[0].SetInt(Ord(Ship.ActiveProgramId));
  if High(av) > 1 then
  begin
    ProgramId := TProgramIndex(av[2].GetDword);
    Ship.ActiveProgramId := ProgramId;
    case ProgramId of
      prgShipwreck: begin
        if High(av) > 2 then Count := av[3].GetInt else Count := SeededRandomIntRange(1, 3, Galaxy.CurrentTurn);
        Ship.DropItemsForDominatorProgram(Count);
      end;
      prgSelfDestruction: Ship.DestroyQueued := True;
      prgDisconnection: begin
        Ship.OrderNone(False);
        Ship.ClearWeaponTargets(nil);
      end;
    end;
  end;
end;
{ @end $6150A0 }

{ @routine $6151C4 SF_DomikProgrammDate }
procedure SF_DomikProgrammDate(av: array of TVarEC; code: TCodeEC);
var
  Ship: TKling;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DomikProgrammDate');
  Ship := TKling(av[1].GetDword);
  av[0].SetInt(Ship.ActiveProgramAppliedTurn);
  if High(av) > 1 then Ship.ActiveProgramAppliedTurn := av[2].GetInt;
end;
{ @end $6151C4 }

{ @routine $615270 SF_HoleMamaCreate }
procedure SF_HoleMamaCreate(av: array of TVarEC; code: TCodeEC);
var Angle, Scale: Single; Hole: THole; I: Integer; Film: TEFilmObj;
begin
  Hole := THole.Create;
  Hole.InitializeGraphic('');
  THoleSE(Hole.Graphic).SetState(1);
  Hole.Star1 := BlazerShip.CurrentStar;
  Hole.Position1.X := BlazerShip.Position.X - GetPlayer.Position.X;
  Hole.Position1.Y := BlazerShip.Position.Y - GetPlayer.Position.Y;
  Scale := 1 / Sqrt(Sqr(Hole.Position1.X) + Sqr(Hole.Position1.Y));
  Hole.Position2.X := Hole.Position1.X * Scale;
  Hole.Position2.Y := Hole.Position1.Y * Scale;
  Hole.Position1.X := BlazerShip.Position.X + Hole.Position2.X * 200;
  Hole.Position1.Y := BlazerShip.Position.Y + Hole.Position2.Y * 200;
  Scale := Sqrt(Sqr(Hole.Position1.X) + Sqr(Hole.Position1.Y));
  if Scale < BlazerShip.CurrentStar.SafeRadius then
  begin
    Hole.Position1.X := BlazerShip.Position.X - Hole.Position2.Y * 200;
    Hole.Position1.Y := BlazerShip.Position.Y + Hole.Position2.X * 200;
    Scale := Sqrt(Sqr(Hole.Position1.X) + Sqr(Hole.Position1.Y));
    if Scale < BlazerShip.CurrentStar.SafeRadius then
    begin
      Hole.Position1.X := BlazerShip.Position.X + Hole.Position2.Y * 200;
      Hole.Position1.Y := BlazerShip.Position.Y - Hole.Position2.X * 200;
    end;
  end;
  Hole.Star2 := nil;
  Angle := 1E20;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Scale := PointDistanceSquared(BlazerShip.CurrentStar.Position, TStar(Galaxy.Stars[I]).Position);
    if (Scale > 5) and (Scale < Angle) then
    begin
      Angle := Scale;
      Hole.Star2 := TStar(Galaxy.Stars[I]);
    end;
  end;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
  Scale := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
  Hole.Position2 := MakePointF(Sin(Angle) * Scale, -Cos(Angle) * Scale);
  Hole.CreatedTurn := Galaxy.CurrentTurn;
  Hole.HoleType := 2;
  Galaxy.Holes.Add(Hole);
  if Hole.Star1.RecordingTurnFilm or Hole.Star2.RecordingTurnFilm then
  begin
    Film := PrimaryFilm.AddObject(Hole.Id, Hole.Graphic);
    PrimaryFilm.SetObjectPosition(0, Film, Hole.Position1);
    PrimaryFilm.SetHoleState(0, Film, 1);
    PrimaryFilm.AttachObject(0, Film);
  end;
end;
{ @end $615270 }

{ @routine $615668 SF_HoleCreate }
procedure SF_HoleCreate(av: array of TVarEC; code: TCodeEC);
var Hole: THole; Angle: Single; Place: TScriptPlace; Film: TEFilmObj;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script HoleCreate');
  Hole := THole.Create;
  Hole.InitializeGraphic('');
  THoleSE(Hole.Graphic).SetState(1);
  Hole.CreatedTurn := Galaxy.CurrentTurn;
  Hole.HoleType := 1;
  Place := TScriptPlace(av[1].GetDword);
  if not (Place.PlaceKind in [spkPolar, spkPlanetPosition, spkStarDirection, spkGroupCentroid, spkCoordinates]) then RaiseWideMessage('Error.Script HoleCreate place 1');
  Hole.Star1 := Place.OriginStar;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Hole.Id * Hole.Star1.GenerationSeed));
  Hole.Position1 := Place.GetPoint;
  Hole.Position1.X := Hole.Position1.X + Sin(Angle) * Place.Radius;
  Hole.Position1.Y := Hole.Position1.Y - Cos(Angle) * Place.Radius;
  Place := TScriptPlace(av[2].GetDword);
  if not (Place.PlaceKind in [spkPolar, spkPlanetPosition, spkStarDirection, spkGroupCentroid, spkCoordinates]) then RaiseWideMessage('Error.Script HoleCreate place 2');
  Hole.Star2 := Place.OriginStar;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Hole.Id * Hole.Star2.GenerationSeed));
  Hole.Position2 := Place.GetPoint;
  Hole.Position2.X := Hole.Position2.X + Sin(Angle) * Place.Radius;
  Hole.Position2.Y := Hole.Position2.Y - Cos(Angle) * Place.Radius;
  Galaxy.Holes.Add(Hole);
  if Hole.Star1.RecordingTurnFilm or Hole.Star2.RecordingTurnFilm then
  begin
    Film := PrimaryFilm.AddObject(Hole.Id, Hole.Graphic);
    PrimaryFilm.SetObjectPosition(0, Film, Hole.Position1);
    PrimaryFilm.SetHoleState(0, Film, 1);
    PrimaryFilm.AttachObject(0, Film);
  end
  else if GetPlayer.InNormalSpace and ((GetPlayer.CurrentStar = Hole.Star1) or (GetPlayer.CurrentStar = Hole.Star2)) then
    StarMapScreen.PendingHoleRefresh := Hole;
end;
{ @end $615668 }

{ @routine $615A04 SF_TerronWeaponLock }
procedure SF_TerronWeaponLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronWeaponLockTurn := Galaxy.CurrentTurn;
end;
{ @end $615A04 }

{ @routine $615A48 SF_TerronGrowLock }
procedure SF_TerronGrowLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronGrowLockTurn := Galaxy.CurrentTurn;
end;
{ @end $615A48 }

{ @routine $615A8C SF_TerronLandingLock }
procedure SF_TerronLandingLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronLandingLockTurn := Galaxy.CurrentTurn;
end;
{ @end $615A8C }

{ @routine $615AD0 SF_TerronToStar }
procedure SF_TerronToStar(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronToStarTurn := Galaxy.CurrentTurn;
end;
{ @end $615AD0 }

{ @routine $615B14 SF_KellerLeave }
procedure SF_KellerLeave(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.KellerLeaveTurn := Galaxy.CurrentTurn;
end;
{ @end $615B14 }

{ @routine $615B58 SF_KellerNewResearch }
procedure SF_KellerNewResearch(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.KellerResearchTargetStarId := av[1].GetDword;
end;
{ @end $615B58 }

{ @routine $615B9C SF_KellerKill }
procedure SF_KellerKill(av: array of TVarEC; code: TCodeEC);
begin
  KellerFinishRequested := True;
end;
{ @end $615B9C }

{ @routine $615BD0 SF_BlazerLanding }
procedure SF_BlazerLanding(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Weapon: TWeapon;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script BlazerLanding');
  Galaxy.BlazerLandingPlanetId := av[1].GetDword;
  if BlazerShip <> nil then
  begin
    BlazerShip.RefreshCurrentStanding;
    BlazerShip.EnemyShip := nil;
    for Index := 1 to BlazerShip.WeaponCount do
    begin
      Weapon := BlazerShip.Weapons[Index];
      if Weapon <> nil then Weapon.Target := nil;
    end;
  end;
end;
{ @end $615BD0 }

{ @routine $615CC4 SF_BlazerSelfDestruction }
procedure SF_BlazerSelfDestruction(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.BlazerSelfDestructTurn := Galaxy.CurrentTurn;
end;
{ @end $615CC4 }

{ @routine $615D08 SF_GalaxyShipId }
procedure SF_GalaxyShipId(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Galaxy.NextShipId);
end;
{ @end $615D08 }

{ @routine $615D48 SF_NearCivilPlanet }
procedure SF_NearCivilPlanet(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Distance, BestDistance: Single;
  Ship: TShip;
  Planet: TPlanet;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script NearCivilPlanet');
  Ship := TShip(av[1].GetDword);
  av[0].SetDword(0);
  BestDistance := 1E30;
  for Index := 0 to Ship.CurrentStar.Planets.Count - 1 do
  begin
    Planet := TPlanet(Ship.CurrentStar.Planets[Index]);
    if Planet.OwnerId <> oiUninhabited then
    begin
      Distance := PointDistanceSquared(Ship.Position, Planet.GetPosition);
      if Distance < BestDistance then
      begin
        BestDistance := Distance;
        av[0].SetDword(Cardinal(Planet));
      end;
    end;
  end;
end;
{ @end $615D48 }

{ @routine $615E54 SF_SkipGreeting }
procedure SF_SkipGreeting(av: array of TVarEC; code: TCodeEC);
begin
  CurrentScript.SkipGreeting := True;
end;
{ @end $615E54 }

{ @routine $615E8C SF_Sound }
procedure SF_Sound(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Sound');
  SoundManager.PlaySound(av[1].GetString);
end;
{ @end $615E8C }

{ @routine $615F3C SF_Tips }
procedure SF_Tips(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Tips');
  ShowPlayerTipOnce(av[1].GetInt);
end;
{ @end $615F3C }

{ @routine $615FB0 SF_TipsState }
procedure SF_TipsState(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script TipsState');
  av[0].SetInt(Ord(HasShownPlayerTip(av[1].GetInt)));
end;
{ @end $615FB0 }

{ @routine $6161B4 SF_CT }
procedure SF_CT(av: array of TVarEC; code: TCodeEC);
var Text: WideString; Block: TBlockParEC;
  // @nested $616034 AddConfigBlock
  procedure AddConfigBlock(Block: TBlockParEC; Dest: TVarEC); // @addr 0x616034 @note "Nested in SF_CT. Appends to Dest's existing array; empty child blocks contain one vkEmpty placeholder."
  var I: Integer; Value: TVarEC;
  begin
    for I := 0 to Block.GetParamCount - 1 do
    begin
      Value := TVarEC.Create(vkString);
      Value.SetString(Block.GetParamValue(I));
      Value.Name := Block.GetParamName(I);
      Dest.GetArray.AddItem(Value);
    end;
    for I := 0 to Block.GetBlockCount - 1 do
    begin
      Value := TVarEC.Create(vkArray);
      Value.SetArray(TVarArrayEC.Create);
      Value.Name := Block.GetBlockNameByIndex(I);
      AddConfigBlock(Block.GetBlockByIndex(I), Value);
      if Value.GetArray.Count = 0 then Value.GetArray.AddItem(TVarEC.Create(vkEmpty));
      Dest.GetArray.AddItem(Value);
    end;
  end;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CT');
  if High(av) > 1 then
  begin
    if av[2].RealVType = vkEmpty then
    begin
      av[2].ConvertToKind(vkArray);
      av[2].SetArray(TVarArrayEC.Create);
    end
    else if av[2].RealVType <> vkArray then raise Exception.Create('Error.Script CT - 2nd argument is not an array');
    av[2].GetArray.Clear;
    if av[1].GetString = '' then Block := LanguageDataConfig
    else Block := LanguageDataConfig.FindBlockByPath(av[1].GetString);
    if Block <> nil then AddConfigBlock(Block, av[2]);
    av[0].SetInt(av[2].GetArray.Count);
    if av[2].GetArray.Count = 0 then av[2].GetArray.AddItem(TVarEC.Create(vkEmpty));
  end
  else
  begin
    Text := LocalizedColorText(av[1].GetString);
    if FindTextOffsetW(Text, '<') >= 0 then
    begin
      Text := ReplaceAllWideString(Text, '<br>', #13#10);
      if GetPlayer <> nil then Text := ReplaceAllWideString(Text, '<PlayerFull>', WrapTextInColor(GetPlayer.GetFullName(' '), TextHighlightColorTag));
    end;
    av[0].SetString(ReplaceAllWideString(Text, #13#10' ', #13#10));
  end;
end;
{ @end $6161B4 }

{ @routine $6164F4 SF_BlockExist }
procedure SF_BlockExist(av: array of TVarEC; code: TCodeEC);
var Path: WideString; I, Count: Integer; Block: TBlockParEC;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BlockExist');
  Path := av[1].GetString;
  Count := CountDelimitedPartsW(Path, '.');
  if High(av) < 2 then Block := LanguageDataConfig
  else if av[2].GetString = 'Lang' then Block := LanguageDataConfig
  else if av[2].GetString = 'Main' then Block := MainDataConfig
  else if av[2].GetString = 'Config' then Block := UserSettingsConfig
  else raise Exception.Create('Error.Script BlockExist - unknown type ' + av[2].GetString);
  av[0].SetInt(0);
  for I := 0 to Count - 1 do
  begin
    if Block.CountBlocks(ExtractDelimitedPartW(Path, I, '.')) = 0 then Exit;
    Block := Block.GetBlock(ExtractDelimitedPartW(Path, I, '.'));
  end;
  av[0].SetInt(1);
end;
{ @end $6164F4 }

{ @routine $616930 SF_GetMainData }
procedure SF_GetMainData(av: array of TVarEC; code: TCodeEC);
var Block: TBlockParEC;
  // @nested $6167B0 AddMainDataBlock
  procedure AddMainDataBlock(Block: TBlockParEC; Dest: TVarEC); // @addr 0x6167B0 @note "Nested in SF_GetMainData. Appends to Dest's existing array; empty child blocks contain one vkEmpty placeholder."
  var I: Integer; Value: TVarEC;
  begin
    for I := 0 to Block.GetParamCount - 1 do
    begin
      Value := TVarEC.Create(vkString);
      Value.SetString(Block.GetParamValue(I));
      Value.Name := Block.GetParamName(I);
      Dest.GetArray.AddItem(Value);
    end;
    for I := 0 to Block.GetBlockCount - 1 do
    begin
      Value := TVarEC.Create(vkArray);
      Value.SetArray(TVarArrayEC.Create);
      Value.Name := Block.GetBlockNameByIndex(I);
      AddMainDataBlock(Block.GetBlockByIndex(I), Value);
      if Value.GetArray.Count = 0 then Value.GetArray.AddItem(TVarEC.Create(vkEmpty));
      Dest.GetArray.AddItem(Value);
    end;
  end;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetMainData');
  if High(av) > 1 then
  begin
    if av[2].RealVType = vkEmpty then
    begin
      av[2].ConvertToKind(vkArray);
      av[2].SetArray(TVarArrayEC.Create);
    end
    else if av[2].RealVType <> vkArray then raise Exception.Create('Error.Script GetMainData - 2nd argument is not an array');
    av[2].GetArray.Clear;
    if av[1].GetString = '' then Block := MainDataConfig
    else Block := MainDataConfig.FindBlockByPath(av[1].GetString);
    if Block <> nil then AddMainDataBlock(Block, av[2]);
    av[0].SetInt(av[2].GetArray.Count);
    if av[2].GetArray.Count = 0 then av[2].GetArray.AddItem(TVarEC.Create(vkEmpty));
  end
  else
    if MainDataConfig.CountParamsByPath(av[1].GetString) > 0 then av[0].SetString(MainDataConfig.GetParamByPath(av[1].GetString))
    else av[0].SetString('');
end;
{ @end $616930 }

{ @routine $616B90 SF_GetGameOptions }
procedure SF_GetGameOptions(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GetGameOptions');
  if av[1].GetString = 'ResolutionX' then av[0].SetInt(GameScreenWidth)
  else if av[1].GetString = 'ResolutionY' then av[0].SetInt(GameScreenHeight)
  else
    try
      av[0].SetString(UserSettingsConfig.GetParam(av[1].GetString));
    except
      av[0].SetString('');
    end;
end;
{ @end $616B90 }

{ @routine $616D34 SF_ResourceExist }
procedure SF_ResourceExist(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ResourceExist');
  av[0].SetInt(Ord(CacheDataRoot.FileExistsByPath(av[1].GetString)));
end;
{ @end $616D34 }

{ @routine $616DFC SF_CurrentMods }
procedure SF_CurrentMods(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then av[0].SetInt(CountDelimitedPartsW(SelectedMods, ','))
  else if av[1].RealVType = vkString then
    av[0].SetInt(Ord(FindTextOffsetW(SelectedModsDisplaySuffix, ', ' + av[1].GetString + ',') >= 0))
  else if av[1].GetInt = -1 then av[0].SetString(SelectedMods)
  else av[0].SetString(ExtractDelimitedPartW(SelectedMods, av[1].GetInt, ','));
end;
{ @end $616DFC }

{ @routine $616F4C SF_RobotSupport }
procedure SF_RobotSupport(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Ord((RobotInterface <> nil) and (RobotInterface.Support() = 0)));
end;
{ @end $616F4C }

{ @routine $616FA4 SF_StarShips }
procedure SF_StarShips(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarShips');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    if High(av) = 1 then av[0].SetInt(Star.Ships.Count)
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Star.Ships.Count) then av[0].SetDword(Cardinal(Star.Ships[Index]))
      else av[0].SetDword(0);
    end;
  end;
end;
{ @end $616FA4 }

{ @routine $617084 SF_StarPlanets }
procedure SF_StarPlanets(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarPlanets');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    if High(av) = 1 then av[0].SetInt(Star.Planets.Count)
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Star.Planets.Count) then av[0].SetDword(Cardinal(Star.Planets[Index]))
      else av[0].SetDword(0);
    end;
  end;
end;
{ @end $617084 }

{ @routine $617168 SF_StarMissiles }
procedure SF_StarMissiles(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarMissiles');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    if High(av) = 1 then av[0].SetInt(Star.Missiles.Count)
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Star.Missiles.Count) then av[0].SetDword(Cardinal(Star.Missiles[Index]))
      else av[0].SetDword(0);
    end;
  end;
end;
{ @end $617168 }

{ @routine $61724C SF_StarAsteroids }
procedure SF_StarAsteroids(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarAsteroids');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    if High(av) = 1 then av[0].SetInt(Star.Asteroids.Count)
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Star.Asteroids.Count) then av[0].SetDword(Cardinal(Star.Asteroids[Index]))
      else av[0].SetDword(0);
    end;
  end;
end;
{ @end $61724C }

{ @routine $617330 SF_GroupShip }
procedure SF_GroupShip(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
  I, Count, GroupIndex, FoundCount, WantedCount: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GroupShip');
  GroupIndex := av[1].GetInt;
  WantedCount := av[2].GetInt + 1;
  FoundCount := 0;
  av[0].SetDword(0);
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := TScriptShip(CurrentScript.Ships[I]);
    if Binding.GroupIndex = GroupIndex then
    begin
      Inc(FoundCount);
      if FoundCount = WantedCount then av[0].SetDword(Cardinal(Binding.Ship));
    end;
  end;
end;
{ @end $617330 }

{ @routine $61742C SF_ShipItems }
procedure SF_ShipItems(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ShipItems');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if High(av) = 1 then av[0].SetInt(Ship.Inventory.Count)
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Ship.Inventory.Count) then av[0].SetDword(Cardinal(Ship.Inventory[Index]))
      else av[0].SetDword(0);
    end;
  end;
end;
{ @end $61742C }

{ @routine $617518 SF_ShipArts }
procedure SF_ShipArts(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ShipArts');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if High(av) = 1 then av[0].SetInt(Ship.Artefacts.Count)
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Ship.Artefacts.Count) then av[0].SetDword(Cardinal(Ship.Artefacts[Index]))
      else av[0].SetDword(0);
    end;
  end;
end;
{ @end $617518 }

{ @routine $617604 SF_PlayerTranclucators }
procedure SF_PlayerTranclucators(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Ship: TShip;
  I, J, Count, Wanted: Integer;
begin
  Count := -1;
  Wanted := -1;
  if High(av) >= 1 then Wanted := av[1].GetInt;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if Ship is TTranclucator then
        if (Ship as TTranclucator).OwnerShip = GetPlayer then
        begin
          Inc(Count);
          if Count = Wanted then
          begin
            av[0].SetDword(Cardinal(Ship));
            Exit;
          end;
        end;
    end;
  end;
  av[0].SetInt(Count + 1);
end;
{ @end $617604 }

{ @routine $61771C SF_ArtTranclucatorToShip }
procedure SF_ArtTranclucatorToShip(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ArtTranclucatorToShip');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item is TArtefactTranclucator then av[0].SetDword(Cardinal((Item as TArtefactTranclucator).Ship));
end;
{ @end $61771C }

{ @routine $61780C SF_TranclucatorData }
procedure SF_TranclucatorData(av: array of TVarEC; code: TCodeEC);
var
  Ship: TTranclucator;
  WriteValue: Boolean;
  Kind: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_TranclucatorData');
  Ship := TTranclucator(av[1].GetDword);
  if av[2].RealVType = vkString then
  begin
    if av[2].GetString = 'Proprietor' then Kind := 0
    else if av[2].GetString = 'ArtSize' then Kind := 1
    else if av[2].GetString = 'ArtSysName' then Kind := 2
    else if av[2].GetString = 'Docking' then Kind := 3
    else if av[2].GetString = 'SeekItems' then Kind := 4
    else if av[2].GetString = 'AutoArrange' then Kind := 5
    else if av[2].GetString = 'LandStorage' then Kind := 6
    else if av[2].GetString = 'LandPermitPlanets' then Kind := 7
    else if av[2].GetString = 'LandPermitRuins' then Kind := 8
    else if av[2].GetString = 'SeekPermitNone' then Kind := 9
    else if av[2].GetString = 'SeekPermitArtefact' then Kind := 10
    else if av[2].GetString = 'SeekPermitMicromodule' then Kind := 11
    else if av[2].GetString = 'SeekPermitEquipment' then Kind := 12
    else if av[2].GetString = 'SeekPermitUseless' then Kind := 13
    else if av[2].GetString = 'SeekPermitGoods' then Kind := 14
    else if av[2].GetString = 'SeekPermitNode' then Kind := 15
    else raise Exception.Create('Error.Script SF_TranclucatorData - unknown property ' + av[2].GetString);
  end
  else Kind := av[2].GetInt;
  WriteValue := High(av) > 2;
  case Kind of
    0: begin
      av[0].SetDword(Cardinal(Ship.OwnerShip));
      if WriteValue then Ship.OwnerShip := TShip(av[3].GetDword);
    end;
    1: begin
      av[0].SetInt(Ship.ArtefactSize);
      if WriteValue then Ship.ArtefactSize := av[3].GetInt;
    end;
    2: begin
      av[0].SetString(Ship.ArtefactSystemName);
      if WriteValue then Ship.ArtefactSystemName := av[3].GetString;
    end;
    3: begin
      av[0].SetInt(Ord(Ship.FollowOwner));
      if WriteValue then Ship.FollowOwner := av[3].GetInt <> 0;
    end;
    4: begin
      av[0].SetInt(Ord(Ship.SeekItems));
      if WriteValue then Ship.SeekItems := av[3].GetInt <> 0;
    end;
    5: begin
      av[0].SetInt(Ord(Ship.AutoArrange));
      if WriteValue then Ship.AutoArrange := av[3].GetInt <> 0;
    end;
    6: begin
      av[0].SetInt(Ord(Ship.StoreOnLanding));
      if WriteValue then Ship.StoreOnLanding := av[3].GetInt <> 0;
    end;
    7: begin
      av[0].SetInt(Ord(Ship.StoragePermissions[tskPlanet]));
      if WriteValue then Ship.StoragePermissions[tskPlanet] := av[3].GetInt <> 0;
    end;
    8: begin
      av[0].SetInt(Ord(Ship.StoragePermissions[tskStation]));
      if WriteValue then Ship.StoragePermissions[tskStation] := av[3].GetInt <> 0;
    end;
    9: begin
      av[0].SetInt(Ord(Ship.CollectionPermissions[tckOther]));
      if WriteValue then Ship.CollectionPermissions[tckOther] := av[3].GetInt <> 0;
    end;
    10: begin
      av[0].SetInt(Ord(Ship.CollectionPermissions[tckArtefact]));
      if WriteValue then Ship.CollectionPermissions[tckArtefact] := av[3].GetInt <> 0;
    end;
    11: begin
      av[0].SetInt(Ord(Ship.CollectionPermissions[tckMicroModule]));
      if WriteValue then Ship.CollectionPermissions[tckMicroModule] := av[3].GetInt <> 0;
    end;
    12: begin
      av[0].SetInt(Ord(Ship.CollectionPermissions[tckEquipment]));
      if WriteValue then Ship.CollectionPermissions[tckEquipment] := av[3].GetInt <> 0;
    end;
    13: begin
      av[0].SetInt(Ord(Ship.CollectionPermissions[tckUseless]));
      if WriteValue then Ship.CollectionPermissions[tckUseless] := av[3].GetInt <> 0;
    end;
    14: begin
      av[0].SetInt(Ord(Ship.CollectionPermissions[tckGoods]));
      if WriteValue then Ship.CollectionPermissions[tckGoods] := av[3].GetInt <> 0;
    end;
    15: begin
      av[0].SetInt(Ord(Ship.CollectionPermissions[tckCountable]));
      if WriteValue then Ship.CollectionPermissions[tckCountable] := av[3].GetInt <> 0;
    end;
  else raise Exception.Create('Error.Script SF_TranclucatorData - unknown property ' + IntToWideString(Kind));
  end;
end;
{ @end $61780C }

{ @routine $6182B4 SF_LinkItemToScript }
procedure SF_LinkItemToScript(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptItem;
  Item: TItem;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_LinkItemToScript');
  Item := TItem(av[1].GetDword);
  if Item.ScriptItem <> nil then (Item.ScriptItem as TScriptItem).Item := nil;
  if High(av) < 2 then
  begin
    if CurrentScript = nil then raise Exception.Create('Error.Script SF_LinkItemToScript - no script');
    Binding := nil;
    for I := 0 to CurrentScript.Items.Count - 1 do
    begin
      Binding := TScriptItem(CurrentScript.Items[I]);
      if (Binding.Name = '') and (Binding.Item = nil) then Break;
      Binding := nil;
    end;
    if Binding = nil then
    begin
      Binding := TScriptItem.Create;
      Binding.Script := CurrentScript;
      CurrentScript.Items.Add(Binding);
    end;
    if Binding.ActionCode <> nil then Binding.ActionCode.Free;
    Binding.ActionCode := nil;
    Binding.ActionCodeInitialized := False;
    Binding.OnActionText := '';
    Binding.CanSell := True;
  end
  else Binding := TScriptItem(av[2].GetDword);
  if Binding.Item <> nil then Binding.Item.ScriptItem := nil;
  Binding.Item := Item;
  Item.ScriptItem := Binding;
end;
{ @end $6182B4 }

{ @routine $6184B0 SF_ReleaseItemFromScript }
procedure SF_ReleaseItemFromScript(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ReleaseItemFromScript');
  Obj := TObject(av[1].GetDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  if Binding.Item <> nil then Binding.Item.ScriptItem := nil;
  Binding.Item := nil;
end;
{ @end $6184B0 }

{ @routine $618584 SF_ScriptItemData }
procedure SF_ScriptItemData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ScriptItemData');
  Obj := TObject(av[1].GetDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  av[0].SetInt(0);
  Index := av[2].GetInt;
  case Index of
    1: av[0].SetInt(Binding.Data[1]);
    2: av[0].SetInt(Binding.Data[2]);
    3: av[0].SetInt(Binding.Data[3]);
  else raise Exception.Create('Error.Script ScriptItemData no');
  end;
  if High(av) > 2 then
    case Index of
      1: Binding.Data[1] := av[3].GetInt;
      2: Binding.Data[2] := av[3].GetInt;
      3: Binding.Data[3] := av[3].GetInt;
    end;
end;
{ @end $618584 }

{ @routine $61871C SF_ScriptItemTextData }
procedure SF_ScriptItemTextData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ScriptItemTextData');
  Obj := TObject(av[1].GetDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  av[0].SetString('');
  Index := av[2].GetInt;
  case Index of
    1: av[0].SetString(Binding.TextData1);
    2: av[0].SetString(Binding.TextData2);
    3: av[0].SetString(Binding.TextData3);
  else raise Exception.Create('Error.Script ScriptItemTextData no');
  end;
  if High(av) > 2 then
    case Index of
      1: Binding.TextData1 := av[3].GetString;
      2: Binding.TextData2 := av[3].GetString;
      3: Binding.TextData3 := av[3].GetString;
    end;
end;
{ @end $61871C }

{ @routine $618918 SF_ScriptItemToItem }
procedure SF_ScriptItemToItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ScriptItemToItem');
  Obj := TObject(av[1].GetDword);
  av[0].SetDword(0);
  if Obj <> nil then
  begin
    if Obj is TItem then av[0].SetDword(Cardinal(Obj))
    else if Obj is TScriptItem then av[0].SetDword(Cardinal(TScriptItem(Obj).Item));
  end;
end;
{ @end $618918 }

{ @routine $6189EC SF_GetShipPirateRank }
procedure SF_GetShipPirateRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipPirateRank');
  Ship := TNormalShip(av[1].GetDword);
  av[0].SetDword(Ship.PirateRank);
end;
{ @end $6189EC }

{ @routine $618A80 SF_ShipPirateRankPoints }
procedure SF_ShipPirateRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipPirateRankPoints');
  Ship := TObject(av[1].GetDword) as TNormalShip;
  av[0].SetDword(Ship.PirateRankPoints);
  if High(av) > 1 then Ship.PirateRankPoints := av[2].GetDword;
end;
{ @end $618A80 }

{ @routine $618B38 SF_ShipNextPirateRankPoints }
procedure SF_ShipNextPirateRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipNextPirateRankPoints');
  Ship := TObject(av[1].GetDword) as TNormalShip;
  av[0].SetInt(PirateRankPointThresholds[Ship.PirateRank]);
end;
{ @end $618B38 }

{ @routine $618BE8 SF_ShipInPirateClan }
procedure SF_ShipInPirateClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInPirateClan');
  Ship := TShip(av[1].GetDword);
  if GetPlayer = Ship then av[0].SetDword(Ord(GetPlayer.PirateClanReal))
  else av[0].SetDword(Ord(Ship.OwnerId = oiPirate));
end;
{ @end $618BE8 }

{ @routine $618CA0 SF_ShipOnSidePirateClan }
procedure SF_ShipOnSidePirateClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOnSidePirateClan');
  Ship := TShip(av[1].GetDword);
  av[0].SetDword(Ord(Ship.OwnerId = oiPirate));
end;
{ @end $618CA0 }

{ @routine $618D38 SF_RaisePirateRank }
procedure SF_RaisePirateRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
  Rank: Cardinal;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RaisePirateRank');
  Ship := TNormalShip(av[1].GetDword);
  if High(av) > 1 then Ship.PirateRank := av[2].GetInt
  else
  begin
    Rank := Ship.PirateRank;
    if Rank < 7 then Ship.PirateRank := Rank + 1;
  end;
  if GetPlayer = Ship then GetPlayer.AchievementStats.CheckBaronAchievement;
end;
{ @end $618D38 }

{ @routine $618E0C SF_ItemType }
procedure SF_ItemType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemType');
  Value := 0;
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Ord(Item.ItemType);
  end;
  av[0].SetDword(Value);
end;
{ @end $618E0C }

{ @routine $618EDC SF_CustomWeaponType }
procedure SF_CustomWeaponType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomWeaponType');
  av[0].SetString('');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item is TCustomWeapon then av[0].SetString((Item as TCustomWeapon).GetWeaponInfo.ConfigName);
end;
{ @end $618EDC }

{ @routine $618FD4 SF_ItemName }
procedure SF_ItemName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Text: WideString;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemName');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  Text := '';
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then Text := Item.GetShortName;
  av[0].SetString(Text);
end;
{ @end $618FD4 }

{ @routine $6190D8 SF_ItemFullName }
procedure SF_ItemFullName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Text: WideString;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemFullName');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  Text := '';
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then Text := Item.GetDisplayName;
  av[0].SetString(Text);
end;
{ @end $6190D8 }

{ @routine $6191E0 SF_ItemSize }
procedure SF_ItemSize(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Integer;
  IsCountable, IsGoods: Boolean;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemSize');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    IsGoods := Item.ItemType in [t_Food..t_Narcotics];
    IsCountable := not IsGoods and (Item is TCountableItem);
    if (IsCountable or IsGoods) and (High(av) > 1) and (av[2].RealVType = vkString) and (av[2].GetString = 'Count') then
    begin
      if IsCountable then av[0].SetDword(TCountableItem(Item).StackCount)
      else av[0].SetDword(TGoods(Item).Quantity);
    end
    else av[0].SetDword(Item.Weight);
    if (High(av) > 1) and (av[2].RealVType <> vkString) then
    begin
      Value := av[2].GetInt;
      if IsCountable then
      begin
        if (High(av) > 2) and (av[3].RealVType = vkString) and (av[3].GetString = 'Count') then
        begin
          Item.Cost := Round(Item.Cost * Value / Max(1, TCountableItem(Item).StackCount));
          TCountableItem(Item).StackCount := Value;
          Item.Weight := Value * TCountableItem(Item).GetUnitSize;
        end
        else
        begin
          Item.Cost := Round(Item.Cost * Value / Max(1, Item.Weight));
          Item.Weight := Value;
          TCountableItem(Item).StackCount := Max(1, Value div TCountableItem(Item).GetUnitSize);
        end;
      end
      else if IsGoods then
      begin
        { Native Count-mode goods handling reads the countable-item offset, then
          rescales Cost again below. Preserve both operations for byte matching. }
        if (High(av) > 2) and (av[3].RealVType = vkString) and (av[3].GetString = 'Count') then
          Item.Cost := Round(Item.Cost * Value / Max(1, TCountableItem(Item).StackCount))
        else Item.Cost := Round(Item.Cost * Value / Max(1, Item.Weight));
        Item.Cost := Round(Item.Cost * Value / Max(1, Item.Weight));
        TGoods(Item).Quantity := Value;
        Item.Weight := Value;
      end
      else Item.Weight := Value;
    end;
  end
  else if Obj is TTranclucator then
  begin
    av[0].SetDword(TTranclucator(Obj).ArtefactSize);
    if High(av) > 1 then TTranclucator(Obj).ArtefactSize := av[2].GetInt;
  end;
end;
{ @end $6191E0 }

{ @routine $619618 SF_ItemOwner }
procedure SF_ItemOwner(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemOwner');
  Value := 0;
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Ord(Item.OwnerId);
    if High(av) > 1 then Item.OwnerId := TOwnerId(av[2].GetDword);
  end;
  av[0].SetDword(Value);
end;
{ @end $619618 }

{ @routine $619700 SF_ItemSubrace }
procedure SF_ItemSubrace(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TEquipment;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemSubrace');
  Value := 0;
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TEquipment(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item as TEquipment;
  if Item <> nil then
  begin
    Value := Ord(Item.DominatorSeries);
    if High(av) > 1 then Item.DominatorSeries := TDominatorSeries(av[2].GetDword);
  end;
  av[0].SetDword(Value);
end;
{ @end $619700 }

{ @routine $6197F4 SF_ItemCost }
procedure SF_ItemCost(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Cardinal;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemCost');
  Value := 0;
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Item.Cost;
    if High(av) > 1 then Item.Cost := av[2].GetInt;
  end;
  av[0].SetDword(Value);
end;
{ @end $6197F4 }

{ @routine $6198D8 SF_ItemIsInUse }
procedure SF_ItemIsInUse(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemIsInUse');
  Obj := TObject(av[1].GetDword);
  av[0].SetInt(0);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    if (Item is TEquipment) and ((Item as TEquipment).EquippedFlag <> 0) then
      av[0].SetInt(Integer((Item as TEquipment).AssignedSlotData) + 1);
    if (High(av) > 2) and (Item is TEquipment) then
    begin
      Ship := TShip(av[2].GetDword);
      if Ship <> nil then
      begin
        if Item is TArtefact then
        begin
          if av[3].GetInt <> 0 then
          begin
            TEquipment(Item).Equip;
            if High(av) > 3 then TEquipment(Item).AssignedSlotData := av[4].GetInt - 1;
          end
          else (Item as TArtefact).Unequip;
        end
        else if Item is TWeapon then
        begin
          if av[3].GetInt <> 0 then
          begin
            Ship.EquipItem(TEquipment(Item));
            if High(av) > 3 then TEquipment(Item).AssignedSlotData := av[4].GetInt - 1;
          end
          else
            for I := 1 to Ship.WeaponCount do
              if Ship.Weapons[I] = Item then Ship.UnequipSlot(Item.ItemType, I);
        end
        else
        begin
          if av[3].GetInt <> 0 then
          begin
            Ship.EquipItem(TEquipment(Item));
            if High(av) > 3 then TEquipment(Item).AssignedSlotData := av[4].GetInt - 1;
          end
          else Ship.UnequipSlot(Item.ItemType, 0);
        end;
        Ship.RefreshAssignedItemSlots;
        Ship.RefreshDerivedStats(True);
        Ship.ScriptItemsAct(satOnNonStandartEqChange, nil, nil, 0);
      end;
    end;
  end;
end;
{ @end $6198D8 }

{ @routine $619B78 SF_ItemIsInSet }
procedure SF_ItemIsInSet(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  SetIndex: Integer;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemIsInSet');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  av[0].SetInt(0);
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    if High(av) > 1 then
    begin
      SetIndex := av[2].GetInt - 1;
      if (SetIndex >= 0) and (SetIndex <= 9) then
        for I := 0 to 11 do
          if GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds[I] = Item.Id then
          begin
            av[0].SetInt(1);
            Exit;
          end;
    end
    else
      for SetIndex := 0 to 9 do
      begin
        for I := 0 to 11 do
          if GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds[I] = Item.Id then
          begin
            av[0].SetInt(SetIndex + 1);
            Exit;
          end;
        for I := 0 to 31 do
          if GetPlayer.EquipmentConfigurations[SetIndex].ArtefactIds[I] = Item.Id then
          begin
            av[0].SetInt(SetIndex + 1);
            Exit;
          end;
      end;
  end;
end;
{ @end $619B78 }

{ @routine $619D38 SF_PlayerEqSet }
procedure SF_PlayerEqSet(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then av[0].SetInt(GetPlayer.SelectedEquipmentConfiguration + 1)
  else
  begin
    Index := av[1].GetInt - 1;
    if GetPlayer.SelectedEquipmentConfiguration = Index then av[0].SetInt(2)
    else if GetPlayer.HasEquipmentConfiguration(Index) then av[0].SetInt(1)
    else av[0].SetInt(0);
    if High(av) > 1 then
    begin
      if av[2].GetInt = 2 then
      begin
        GetPlayer.ApplyEquipmentConfiguration(Index);
        GetPlayer.SelectedEquipmentConfiguration := Index;
      end
      else if av[2].GetInt = 1 then
      begin
        GetPlayer.SaveEquipmentConfiguration(Index);
        GetPlayer.SelectedEquipmentConfiguration := Index;
      end;
    end;
  end;
end;
{ @end $619D38 }

{ @routine $619E40 SF_ItemIsBroken }
procedure SF_ItemIsBroken(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Broken: Byte;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemIsBroken');
  Obj := TObject(av[1].GetDword);
  Broken := 0;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    if Item is TEquipment then Broken := (Item as TEquipment).BrokenFlag;
    if Item is TArtefact then Broken := (Item as TArtefact).BrokenFlag;
  end;
  if Broken <> 0 then av[0].SetInt(1) else av[0].SetInt(0);
end;
{ @end $619E40 }

{ @routine $619F6C SF_ShipCanUseEq }
procedure SF_ShipCanUseEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipCanUseEq');
  Ship := TShip(av[1].GetDword);
  Obj := TObject(av[2].GetDword);
  if Obj is TItem then Item := TItem(Obj)
  else if Obj is TScriptItem then Item := TScriptItem(Obj).Item
  else Item := nil;
  av[0].SetInt(0);
  if Item <> nil then
    if Item is TEquipment then av[0].SetInt(Ord(Ship.CanUseEquipmentTech(TEquipment(Item))));
end;
{ @end $619F6C }

{ @routine $61A06C SF_ShipCanRepairEq }
procedure SF_ShipCanRepairEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipCanRepairEq');
  Ship := TShip(av[1].GetDword);
  Obj := TObject(av[2].GetDword);
  if Obj is TItem then Item := TItem(Obj)
  else if Obj is TScriptItem then Item := TScriptItem(Obj).Item
  else Item := nil;
  av[0].SetInt(0);
  if Item <> nil then
    if Item is TEquipment then av[0].SetInt(Ord(Ship.CanRepairEquipmentTech(TEquipment(Item))));
end;
{ @end $61A06C }

{ @routine $61A170 SF_ShipTechLevelKnowledge }
procedure SF_ShipTechLevelKnowledge(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipTechLevelKnowledge');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(Ship.TechKnowledge);
  if High(av) > 1 then Ship.TechKnowledge := av[2].GetInt;
end;
{ @end $61A170 }

{ @routine $61A220 SF_WeaponTarget }
procedure SF_WeaponTarget(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script WeaponTarget');
  Obj := TObject(av[1].GetDword);
  av[0].SetDword(0);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TWeapon) and ((Item as TWeapon).EquippedFlag <> 0) then
  begin
    av[0].SetDword(Cardinal((Item as TWeapon).Target));
    if High(av) > 1 then (Item as TWeapon).Target := TObject(av[2].GetDword);
  end;
end;
{ @end $61A220 }

{ @routine $61A348 SF_GetEquipmentStats }
procedure SF_GetEquipmentStats(av: array of TVarEC; code: TCodeEC);
var Obj: TObject; Item: TItem; Stat: Integer; Text: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetEquipmentStats');
  Obj := TObject(av[1].GetDword);
  Stat := 0;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    if High(av) > 1 then
    begin
      if av[2].RealVType = vkString then
      begin
        if Item is TEquipment then
        begin
          Text := av[2].GetString;
          TEquipment(Item).ReplaceInfoTokens(Text, '', nil);
          av[0].SetString(Text);
        end
        else av[0].SetString('');
        Exit;
      end;
      Stat := av[2].GetInt;
    end;
    if Item.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
      case Stat of
        0: av[0].SetInt((Item as TWeapon).MaxDamage);
        1: av[0].SetInt((Item as TWeapon).MinDamage);
        2: av[0].SetInt((Item as TWeapon).Range);
        3: av[0].SetInt(Ord(ClassifyWeaponDamageFlags((Item as TWeapon).GetWeaponInfo.DamageFlags)));
        4: av[0].SetInt((Item as TWeapon).GetAttackCount);
        5: av[0].SetInt((Item as TWeapon).GetShotCount);
        6: av[0].SetDword(Dword((Item as TWeapon).GetDamageFlags));
    end
    else case Item.ItemType of
      t_Hull: case Stat of
        0: av[0].SetInt((Item as THull).Armor);
        1: av[0].SetInt((Item as THull).GetSlotCount(sskWeapon));
        2: av[0].SetInt((Item as THull).GetSlotCount(sskArtefact));
        3: av[0].SetInt((Item as THull).GetSlotCount(sskRadar));
        4: av[0].SetInt((Item as THull).GetSlotCount(sskScanner));
        5: av[0].SetInt((Item as THull).GetSlotCount(sskRepairRobot));
        6: av[0].SetInt((Item as THull).GetSlotCount(sskCargoHook));
        7: av[0].SetInt((Item as THull).GetSlotCount(sskDefGenerator));
        8: av[0].SetInt((Item as THull).GetSlotCount(sskAfterburner));
      end;
      t_FuelTanks: case Stat of
        0: av[0].SetInt((Item as TFuelTanks).Capacity);
        1: av[0].SetInt((Item as TFuelTanks).Fuel);
      end;
      t_Engine: case Stat of
        0: av[0].SetInt((Item as TEngine).Speed);
        1: av[0].SetInt((Item as TEngine).JumpRange);
      end;
      t_Radar: av[0].SetInt((Item as TRadar).Range);
      t_Scaner: av[0].SetInt((Item as TScaner).ScanPower);
      t_RepairRobot: av[0].SetInt((Item as TRepairRobot).RepairPoints);
      t_CargoHook: case Stat of
        0: av[0].SetInt((Item as TCargoHook).PickupPower);
        1: av[0].SetInt((Item as TCargoHook).Range);
        2: av[0].SetFloat((Item as TCargoHook).MinPullSpeed);
        3: av[0].SetFloat((Item as TCargoHook).MaxPullSpeed);
      end;
      t_DefGenerator: av[0].SetInt(Round(100 - (Item as TDefGenerator).DamageFactor * 100));
      t_Cistern: case Stat of
        0: av[0].SetInt((Item as TCistern).Capacity);
        1: av[0].SetInt((Item as TCistern).Fuel);
      end;
      t_Satellite: case Stat of
        0: av[0].SetInt((Item as TSatellite).WaterExplorationRate);
        1: av[0].SetInt((Item as TSatellite).LandExplorationRate);
        2: av[0].SetInt((Item as TSatellite).HillExplorationRate);
        3: av[0].SetFloat((Item as TSatellite).WearPerTurn);
      end;
    end;
    if av[0].RealVType = vkEmpty then av[0].SetInt(0);
  end;
end;
{ @end $61A348 }

{ @routine $61AAB8 SF_SetEquipmentStats }
procedure SF_SetEquipmentStats(av: array of TVarEC; code: TCodeEC);
var Obj: TObject; Item: TItem; Stat: Integer; Value: Cardinal;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetEquipmentStats');
  Obj := TObject(av[1].GetDword);
  Value := av[2].GetDword;
  Stat := 0;
  if High(av) > 2 then Stat := av[3].GetInt;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    if Item.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
      case Stat of
        0: (Item as TWeapon).MaxDamage := Value;
        1: (Item as TWeapon).MinDamage := Value;
        2: (Item as TWeapon).Range := Value;
    end
    else case Item.ItemType of
      t_Hull: (Item as THull).Armor := Value;
      t_FuelTanks: case Stat of
        0: (Item as TFuelTanks).Capacity := Value;
        1: (Item as TFuelTanks).Fuel := Value;
      end;
      t_Engine: case Stat of
        0: (Item as TEngine).Speed := Value;
        1: (Item as TEngine).JumpRange := Value;
      end;
      t_Radar: (Item as TRadar).Range := Value;
      t_Scaner: (Item as TScaner).ScanPower := Value;
      t_RepairRobot: (Item as TRepairRobot).RepairPoints := Value;
      t_CargoHook: case Stat of
        0: (Item as TCargoHook).PickupPower := Value;
        1: (Item as TCargoHook).Range := Value;
        2: (Item as TCargoHook).MinPullSpeed := av[2].GetFloat;
        3: (Item as TCargoHook).MaxPullSpeed := av[2].GetFloat;
      end;
      t_DefGenerator: (Item as TDefGenerator).DamageFactor := Integer(100 - Value) * 0.01;
      t_Cistern: case Stat of
        0: (Item as TCistern).Capacity := Value;
        1: (Item as TCistern).Fuel := Value;
      end;
      t_Satellite: case Stat of
        0: (Item as TSatellite).WaterExplorationRate := Value;
        1: (Item as TSatellite).LandExplorationRate := Value;
        2: (Item as TSatellite).HillExplorationRate := Value;
        3: (Item as TSatellite).WearPerTurn := av[2].GetFloat;
      end;
    end;
  end;
end;
{ @end $61AAB8 }

{ @routine $61AED8 SF_CreateHull }
procedure SF_CreateHull(av: array of TVarEC; code: TCodeEC);
var
  Hull: THull;
  HullType: Byte; Owner: TOwnerId;
  Level, Capacity, Series: Integer;
  PirateBuilt: Boolean;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CreateHull');
  HullType := av[1].GetDword;
  Capacity := av[2].GetInt;
  Level := av[3].GetInt;
  Owner := TOwnerId(av[4].GetDword);
  Series := -1;
  PirateBuilt := False;
  if High(av) > 4 then Series := av[5].GetInt;
  if High(av) > 5 then PirateBuilt := av[6].GetInt <> 0;
  Hull := THull.Create;
  Hull.Init(Capacity, Level, Owner, HullType, Series, PirateBuilt);
  av[0].SetDword(Cardinal(Hull));
end;
{ @end $61AED8 }

{ @routine $61AFE8 SF_CreateEquipment }
procedure SF_CreateEquipment(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Kind: TItemType;
  Owner: TOwnerId;
  Weight, Level: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CreateEquipment');
  Kind := TItemType(av[1].GetDword);
  Weight := av[2].GetInt;
  Level := av[3].GetInt;
  Owner := TOwnerId(av[4].GetDword);
  if Kind = t_Cistern then
  begin
    Item := TCistern.Create;
    TCistern(Item).Init(Level, Weight, Owner);
  end
  else Item := CreateGeneratedEquipment(Kind, Weight, Byte(Level), Owner);
  av[0].SetDword(Cardinal(Item));
end;
{ @end $61AFE8 }

{ @routine $61B0DC SF_CreateArt }
procedure SF_CreateArt(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefact;
  Kind: TItemType;
  Owner: TOwnerId;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CreateArt');
  Kind := TItemType(av[1].GetDword);
  Owner := TOwnerId(av[2].GetDword);
  Item := CreateConfiguredArtefactByItemType(Kind, Owner);
  av[0].SetDword(Cardinal(Item));
end;
{ @end $61B0DC }

{ @routine $61B17C SF_CreateCustomWeapon }
procedure SF_CreateCustomWeapon(av: array of TVarEC; code: TCodeEC);
var
  Item: TWeapon;
  Owner: TOwnerId;
  Weight, Level: Integer;
  Info: PWeaponInfo;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CreateEquipment');
  Info := Galaxy.RequireCustomWeaponInfo(av[1].GetString);
  Weight := av[2].GetInt;
  Level := av[3].GetInt;
  Owner := TOwnerId(av[4].GetDword);
  Item := CreateGeneratedWeapon(Info, Weight, Byte(Level), Owner);
  av[0].SetDword(Cardinal(Item));
end;
{ @end $61B17C }

{ @routine $61B288 SF_CreateCustomArt }
procedure SF_CreateCustomArt(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefactCustom;
  ConfigName: WideString;
  Owner: TOwnerId;
  Weight, Cost: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CreateCustomArt');
  ConfigName := av[1].GetString;
  Weight := av[2].GetInt;
  Cost := av[3].GetInt;
  Owner := TOwnerId(av[4].GetDword);
  Item := TArtefactCustom.Create;
  Item.ConfigBlockName := ConfigName;
  Item.LoadConfig(True);
  Item.Data[1] := 0;
  Item.Data[2] := 0;
  Item.Data[3] := 0;
  Item.Weight := Weight;
  Item.Cost := Cost;
  Item.OwnerId := Owner;
  av[0].SetDword(Cardinal(Item));
end;
{ @end $61B288 }

{ @routine $61B3C8 SF_CustomArtData }
procedure SF_CustomArtData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CustomArtData');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].SetInt(0);
  if Item is TArtefactCustom then
  begin
    Index := av[2].GetInt;
    case Index of
      1: av[0].SetInt((Item as TArtefactCustom).Data[1]);
      2: av[0].SetInt((Item as TArtefactCustom).Data[2]);
      3: av[0].SetInt((Item as TArtefactCustom).Data[3]);
    else raise Exception.Create('Error.Script CustomArtData no');
    end;
    if High(av) > 2 then
      case Index of
        1: (Item as TArtefactCustom).Data[1] := av[3].GetInt;
        2: (Item as TArtefactCustom).Data[2] := av[3].GetInt;
        3: (Item as TArtefactCustom).Data[3] := av[3].GetInt;
      end;
  end;
end;
{ @end $61B3C8 }

{ @routine $61B5C0 SF_CustomArtTextData }
procedure SF_CustomArtTextData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CustomArtTextData');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].SetString('');
  if Item is TArtefactCustom then
  begin
    Index := av[2].GetInt;
    case Index of
      1: av[0].SetString((Item as TArtefactCustom).TextData1);
      2: av[0].SetString((Item as TArtefactCustom).TextData2);
      3: av[0].SetString((Item as TArtefactCustom).TextData3);
    else raise Exception.Create('Error.Script CustomArtTextData no');
    end;
    if High(av) > 2 then
      case Index of
        1: (Item as TArtefactCustom).TextData1 := av[3].GetString;
        2: (Item as TArtefactCustom).TextData2 := av[3].GetString;
        3: (Item as TArtefactCustom).TextData3 := av[3].GetString;
      end;
  end;
end;
{ @end $61B5C0 }

{ @routine $61B828 SF_CreateMM }
procedure SF_CreateMM(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Item: TMicroModule;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateMM');
  Index := av[1].GetInt;
  Item := TMicroModule.Create;
  Item.Init(Index);
  av[0].SetDword(Cardinal(Item));
end;
{ @end $61B828 }

{ @routine $61B8C4 SF_CreateNodes }
procedure SF_CreateNodes(av: array of TVarEC; code: TCodeEC);
var
  Item: TProtoplasm;
  DropFlag: Boolean;
  Series: TDominatorSeries;
  Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateNodes');
  Count := av[1].GetInt;
  DropFlag := False;
  Series := dsBlazer;
  if High(av) > 1 then Series := TDominatorSeries(av[2].GetInt);
  if High(av) > 2 then DropFlag := av[3].GetInt <> 0;
  Item := TProtoplasm.Create;
  Item.Init(Count, Ord(DropFlag));
  Item.DominatorSeries := Series;
  av[0].SetDword(Cardinal(Item));
end;
{ @end $61B8C4 }

{ @routine $61B9A4 SF_CreateCustomCountableItem }
procedure SF_CreateCustomCountableItem(av: array of TVarEC; code: TCodeEC);
var
  ConfigName: WideString;
  Count: Integer;
  DropFlag: Boolean;
  Item: TCountableItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateCustomCountableItem');
  ConfigName := av[1].GetString;
  if High(av) > 1 then Count := av[2].GetInt else Count := 1;
  if High(av) > 2 then DropFlag := av[3].GetInt <> 0 else DropFlag := False;
  Item := TCountableItem.Create;
  Item.Init(ConfigName, Count, Ord(DropFlag));
  av[0].SetDword(Cardinal(Item));
end;
{ @end $61B9A4 }

{ @routine $61BAC0 SF_CreateZond }
procedure SF_CreateZond(av: array of TVarEC; code: TCodeEC);
var
  Item: TSatellite;
  Owner: TOwnerId; Kind: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CreateZond');
  Kind := av[1].GetDword;
  Owner := TOwnerId(av[2].GetDword);
  Item := TSatellite.Create;
  Item.InitGenerated(Kind, Owner, NextRandomIntRange(1, 10000, Galaxy.RandomState));
  if High(av) > 4 then
  begin
    Item.WaterExplorationRate := av[3].GetInt;
    Item.LandExplorationRate := av[4].GetInt;
    Item.HillExplorationRate := av[5].GetInt;
  end;
  av[0].SetDword(Cardinal(Item));
end;
{ @end $61BAC0 }

{ @routine $61BBC0 SF_ExistingZonds }
procedure SF_ExistingZonds(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then av[0].SetInt(Galaxy.CountExistingSatellites)
  else
  begin
    Index := av[1].GetInt;
    if (Index >= 0) and (Index < GetPlayer.Satellites.Count) then
    begin
      if (High(av) > 1) and (av[2].GetInt = 1) then av[0].SetDword(Cardinal(TSatellite(GetPlayer.Satellites[Index]).TargetPlanet))
      else av[0].SetDword(Cardinal(GetPlayer.Satellites[Index]));
    end
    else av[0].SetDword(0);
  end;
end;
{ @end $61BBC0 }

{ @routine $61BC98 SF_FreeItem }
procedure SF_FreeItem(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FreeItem');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    if Item.ScriptItem <> nil then (Item.ScriptItem as TScriptItem).Item := nil;
    Item.Free;
  end;
end;
{ @end $61BC98 }

{ @routine $61BD74 SF_ShipJoinsClan }
procedure SF_ShipJoinsClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipJoinsClan');
  Ship := TShip(av[1].GetDword);
  if (Ship.TypeId = stPirate) and (Ship.OwnerId <> oiPirate) then
  begin
    Inc(Galaxy.PirateClanCount);
    Dec(Galaxy.PirateCount);
  end;
  Ship.OwnerId := oiPirate;
  if GetPlayer = Ship then GetPlayer.PirateClanReal := True;
end;
{ @end $61BD74 }

{ @routine $61BE30 SF_AddItemToShip }
procedure SF_AddItemToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item, Other: TItem;
  GoodsKind: Byte;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddItemToShip');
  Ship := TShip(av[1].GetDword);
  Item := TItem(av[2].GetDword);
  if Item is TGoods then
  begin
    GoodsKind := Byte((Item as TGoods).ItemType);
    Inc(Ship.CargoGoods[GoodsKind].Count, (Item as TGoods).Weight);
    Inc(Ship.CargoGoods[GoodsKind].TotalCost, Item.Cost);
    Item.Free;
  end
  else if Item is TCountableItem then
  begin
    for Index := 1 to Ship.Inventory.Count - 1 do
    begin
      Other := TItem(Ship.Inventory[Index]);
      if (Item as TCountableItem).CanMerge(Other) then
      begin
        (Other as TCountableItem).Merge(Item);
        Item.Free;
        Item := nil;
        Break;
      end;
    end;
    if Item <> nil then Ship.Inventory.Add(Item);
  end
  else if (Item is THull) and (Ship.GetHull = nil) then
  begin
    Ship.Inventory.Insert(0, Item);
    Ship.EquipItem(TEquipment(Item));
    THull(Item).OwnerShip := Ship;
    Ship.RefreshAssignedItemSlots;
    Ship.RefreshDerivedStats(True);
    Ship.ScriptItemsAct(satOnNonStandartEqChange, nil, nil, 0);
  end
  else if Item is TArtefact then Ship.Artefacts.Add(Item)
  else if Item is TEquipment then Ship.Inventory.Add(Item);
end;
{ @end $61BE30 }

{ @routine $61C07C SF_GetItemFromShip }
procedure SF_GetItemFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
  Index, WeaponIndex: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetItemFromShip');
  Ship := TShip(av[1].GetDword);
  av[0].SetDword(0);
  if Ship <> nil then
  begin
    if (av[2].RealVType = vkDword) and (av[2].GetDword > $10000) then
    begin
      Item := TItem(av[2].GetDword);
      Index := Ship.Inventory.IndexOf(Item);
      if Index < 0 then Exit;
    end
    else
    begin
      Index := av[2].GetInt;
      if (Index < 0) or (Index >= Ship.Inventory.Count) then Exit;
      Item := TItem(Ship.Inventory[Index]);
      if (av[2].RealVType = vkDword) and (av[2].GetDword = 0) and (Item is THull) then
        AppendLogLineThreadSafe('Warning, GetItemFromShip received 0 from dword-type variable and will remove hull from ship ' + Ship.GetFullName(' ') + ' (' + GetScriptContextDescription + ')');
    end;
    av[0].SetDword(Cardinal(Item));
    if Ship.GetHull = Item then
    begin
      Ship.GetHull.OwnerShip := nil;
      Ship.UnequipSlot(t_Hull, 0);
    end
    else if (Item is TEquipment) and ((Item as TEquipment).EquippedFlag <> 0) then
    begin
      if Item.ItemType in [t_FuelTanks..t_DefGenerator] then Ship.UnequipSlot(Item.ItemType, 0);
      if Item is TWeapon then
        for WeaponIndex := 1 to Ship.CountEquippedWeapons do
          if Ship.Weapons[WeaponIndex] = Item then
          begin
            Ship.UnequipSlot(WeaponCategoryItemType, WeaponIndex);
            Break;
          end;
    end;
    Ship.Inventory.Delete(Index);
  end;
end;
{ @end $61C07C }

{ @routine $61C424 SF_GetArtFromShip }
procedure SF_GetArtFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TEquipment;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetArtFromShip');
  Ship := TShip(av[1].GetDword);
  av[0].SetDword(0);
  if Ship <> nil then
  begin
    if (av[2].RealVType = vkDword) and (av[2].GetDword > $10000) then
    begin
      Item := TEquipment(av[2].GetDword);
      Index := Ship.Artefacts.IndexOf(Item);
      if Index < 0 then Exit;
    end
    else
    begin
      Index := av[2].GetInt;
      if (Index < 0) or (Index >= Ship.Artefacts.Count) then Exit;
      Item := TEquipment(Ship.Artefacts[Index]);
    end;
    Item.Unequip;
    av[0].SetDword(Cardinal(Item));
    Ship.Artefacts.Delete(Index);
  end;
end;
{ @end $61C424 }

{ @routine $61C55C SF_ArrangeItems }
procedure SF_ArrangeItems(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ArrangeItems');
  Ship := TShip(av[1].GetDword);
  Ship.AutoEquipInventory;
  Ship.AutoEquipArtefacts;
  Ship.DropCargoUntilNotOverloaded;
  Ship.RefreshAssignedItemSlots;
end;
{ @end $61C55C }

{ @routine $61C5F4 SF_AddItemToPlanet }
procedure SF_AddItemToPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Item: TItem;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddItemToPlanet');
  Planet := TPlanet(av[1].GetDword);
  Item := TItem(av[2].GetDword);
  av[0].SetInt(0);
  if (Planet <> nil) and (Item <> nil) and Planet.AddSurfaceLootEntry(Item) then
  begin
    Planet.NormalizeSurfaceLootEntries;
    av[0].SetInt(1);
  end;
end;
{ @end $61C5F4 }

{ @routine $61C6BC SF_GetItemFromPlanet }
procedure SF_GetItemFromPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Entry: PPlanetSurfaceLootEntry;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetItemFromPlanet');
  Planet := TPlanet(av[1].GetDword);
  Index := av[2].GetInt;
  av[0].SetDword(0);
  if (Planet <> nil) and (Planet.SurfaceLootEntries <> nil) and (Index >= 0) and (Index < Planet.SurfaceLootEntries.Count) then
  begin
    Entry := Planet.SurfaceLootEntries[Index];
    av[0].SetDword(Cardinal(Entry.Item));
    Planet.SurfaceLootEntries.Delete(Index);
    Entry.Item := nil;
    Dispose(Entry);
  end;
end;
{ @end $61C6BC }

{ @routine $61C7C8 SF_AddItemToShop }
procedure SF_AddItemToShop(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Item: TItem;
  Refresh: Boolean;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddItemToShop');
  Shop := TObject(av[1].GetDword);
  Item := TItem(av[2].GetDword);
  av[0].SetInt(0);
  Refresh := (TemporaryShopSlots <> nil) and ((TemporaryShopPlanet = Shop) or (TemporaryShopStation = Shop));
  if Item <> nil then
  begin
    if Shop is TPlanet then
    begin
      if Refresh then RestoreTemporaryShopStock;
      (Shop as TPlanet).EquipmentShop.Add(Item);
      av[0].SetInt(1);
      if Refresh then
      begin
        BuildTemporaryShopSlotGrid;
        EquipmentShopScreen.ClearGoodsControls;
        EquipmentShopScreen.BuildGoodsControls;
        EquipmentShopScreen.UpdateScrollButtons;
      end;
    end
    else if Shop is TRuins then
    begin
      if Refresh then RestoreTemporaryShopStock;
      (Shop as TRuins).EquipmentShop.Add(Item);
      av[0].SetInt(1);
      if Refresh then
      begin
        BuildTemporaryShopSlotGrid;
        EquipmentShopScreen.ClearGoodsControls;
        EquipmentShopScreen.BuildGoodsControls;
        EquipmentShopScreen.UpdateScrollButtons;
      end;
    end;
  end;
end;
{ @end $61C7C8 }

{ @routine $61C984 SF_GetItemFromShop }
procedure SF_GetItemFromShop(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Index: Integer;
  Refresh: Boolean;
  Items: TList;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetItemFromShop');
  Shop := TObject(av[1].GetDword);
  av[0].SetDword(0);
  if Shop <> nil then
  begin
    Refresh := (TemporaryShopSlots <> nil) and ((TemporaryShopPlanet = Shop) or (TemporaryShopStation = Shop));
    if Refresh then RestoreTemporaryShopStock;
    if Shop is TPlanet then Items := TPlanet(Shop).EquipmentShop
    else if Shop is TRuins then Items := TRuins(Shop).EquipmentShop
    else Exit;
    if (av[2].RealVType = vkDword) and (av[2].GetDword > $10000) then
    begin
      Index := Items.IndexOf(Pointer(av[2].GetDword));
      if Index >= 0 then
      begin
        av[0].SetDword(av[2].GetDword);
        Items.Delete(Index);
      end;
    end
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Items.Count) then
      begin
        av[0].SetDword(Cardinal(Items[Index]));
        Items.Delete(Index);
      end;
    end;
    if Refresh then
    begin
      BuildTemporaryShopSlotGrid;
      EquipmentShopScreen.ClearGoodsControls;
      EquipmentShopScreen.BuildGoodsControls;
      EquipmentShopScreen.UpdateScrollButtons;
    end;
  end;
end;
{ @end $61C984 }

{ @routine $61CB64 SF_AddItemToStorage }
procedure SF_AddItemToStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Location: TObject;
  Item: TItem;
  Entry: PStorageEntry;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddItemToStorage');
  Location := TObject(av[1].GetDword);
  Item := TItem(av[2].GetDword);
  if Item is TGoods then
    for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
    begin
      Entry := GetPlayer.StorageEntries[Index];
      // Early guards retain DCC32's native operand weighting for the additions.
      if Entry.LocationOwner <> Location then Continue;
      if not (Entry.Item is TGoods) then Continue;
      with Entry.Item as TGoods do
      begin
        if ItemType = Item.ItemType then
        begin
          Inc(Quantity, TGoods(Item).Quantity);
          Inc(Weight, Item.Weight);
          Inc(Cost, Item.Cost);
          Item.Free;
          GetPlayer.RefreshStorageBubbles;
          Exit;
        end;
      end;
    end;
  if Item is TCountableItem then
    for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
    begin
      Entry := GetPlayer.StorageEntries[Index];
      if Entry.LocationOwner = Location then
        if Entry.Item is TCountableItem then
          with Entry.Item as TCountableItem do
            if CanMerge(Item) then
            begin
              Merge(Item);
              Item.Free;
              GetPlayer.RefreshStorageBubbles;
              Exit;
            end;
    end;
  if (Location <> nil) and (Item <> nil) then
  begin
    GetPlayer.AddItemToPlayerStorage(Item, Location, -1);
    GetPlayer.RefreshStorageBubbles;
  end;
end;
{ @end $61CB64 }

{ @routine $61CDA4 SF_GetItemFromStorage }
procedure SF_GetItemFromStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Entry: PStorageEntry;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetItemFromStorage');
  Index := av[1].GetInt;
  av[0].SetDword(0);
  if (Index >= 0) and (Index < GetPlayer.StorageEntries.Count) then
  begin
    Entry := GetPlayer.StorageEntries[Index];
    GetPlayer.StorageEntries.Delete(Index);
    GetPlayer.RefreshStorageBubbles;
    av[0].SetDword(Cardinal(Entry.Item));
    Dispose(Entry);
  end;
end;
{ @end $61CDA4 }

{ @routine $61CE98 SF_FindItemInStorage }
procedure SF_FindItemInStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Item: TItem;
  Entry: PStorageEntry;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindItemInStorage');
  Item := TItem(av[1].GetDword);
  av[0].SetInt(-1);
  for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
  begin
    Entry := GetPlayer.StorageEntries[Index];
    if Entry.Item = Item then
    begin
      av[0].SetInt(Index);
      Break;
    end;
  end;
end;
{ @end $61CE98 }

{ @routine $61CF78 SF_PutItemInVault }
procedure SF_PutItemInVault(av: array of TVarEC; code: TCodeEC);
var
  Item: TObject;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PutItemInVault');
  if av[2].GetDword = 0 then
  begin
    Item := Galaxy.GetStoredItem(av[1].GetString, True);
    if Item <> nil then Item.Free;
  end
  else Galaxy.StoreItem(av[1].GetString, TObject(av[2].GetDword));
end;
{ @end $61CF78 }

{ @routine $61D088 SF_GetItemFromVault }
procedure SF_GetItemFromVault(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetItemFromVault');
  av[0].SetDword(Cardinal(Galaxy.GetStoredItem(av[1].GetString, (High(av) < 2) or (av[2].GetInt <> 0))));
end;
{ @end $61D088 }

{ @routine $61D16C SF_DropItemInSystem }
procedure SF_DropItemInSystem(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Obj: TObject;
  Item: TItem;
  Destination, Position: TPointF;
  Entry: PMovingDropItemEntry;
  StepIndex: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script DropItemInSystem');
  Star := TStar(av[1].GetDword);
  Obj := TObject(av[2].GetDword);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item else Item := TItem(Obj);
  Position.X := av[3].GetInt;
  Position.Y := av[4].GetInt;
  if High(av) < 6 then
  begin
    Item.Position := Position;
    Star.Items.Add(Item);
    if Star.RecordingTurnFilm then
    begin
      StepIndex := Star.CurrentStepIndex;
      Item.FilmObject := TEFilm(PrimaryFilm).AddObject(Item.Id, Item.GetGraphObject);
      TEFilm(PrimaryFilm).SetObjectPosition(StepIndex, Item.FilmObject, Item.Position);
      TEFilm(PrimaryFilm).AttachObject(StepIndex, Item.FilmObject);
    end;
  end
  else
  begin
    Destination.X := av[5].GetFloat;
    Destination.Y := av[6].GetFloat;
    av[0].SetInt(0);
    if (Star <> nil) and (Item <> nil) then
    begin
      Item.Position := Position;
      Entry := AllocEC(SizeOf(TMovingDropItemEntry));
      Entry.Payload := Item;
      Entry.Destination := Destination;
      Entry.SourceShipId := 0;
      Entry.InsertedIntoStar := False;
      Entry.DeployTranclucator := 0;
      av[0].SetInt(Star.MovingDropItems.Add(Entry));
    end;
  end;
end;
{ @end $61D16C }

{ @routine $61D37C SF_StopMovingItem }
procedure SF_StopMovingItem(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Obj: TObject;
  Item: TItem;
  Entry: PMovingDropItemEntry;
  Index, StepIndex: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StopMovingItem');
  Star := TStar(av[1].GetDword);
  Obj := TObject(av[2].GetDword);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item else Item := TItem(Obj);
  av[0].SetInt(0);
  for Index := 0 to Star.MovingDropItems.Count - 1 do
  begin
    Entry := Star.MovingDropItems[Index];
    if Entry.Payload = Item then
    begin
      Entry.Payload := nil;
      Star.MovingDropItems.Delete(Index);
      FreeEC(Entry);
      Star.Items.Add(Item);
      if Star.RecordingTurnFilm then
      begin
        StepIndex := Star.CurrentStepIndex;
        Item.FilmObject := TEFilm(PrimaryFilm).AddObject(Item.Id, Item.GetGraphObject);
        TEFilm(PrimaryFilm).SetObjectPosition(StepIndex, Item.FilmObject, Item.Position);
        TEFilm(PrimaryFilm).AttachObject(StepIndex, Item.FilmObject);
      end;
      av[0].SetInt(1);
      Break;
    end;
  end;
end;
{ @end $61D37C }

{ @routine $61D524 SF_StarItems }
procedure SF_StarItems(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarItems');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    if High(av) = 1 then av[0].SetInt(Star.Items.Count)
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Star.Items.Count) then av[0].SetDword(Cardinal(Star.Items[Index]))
      else av[0].SetDword(0);
    end;
  end
  else av[0].SetInt(0);
end;
{ @end $61D524 }

{ @routine $61D614 SF_GetItemFromStar }
procedure SF_GetItemFromStar(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetItemFromStar');
  Star := TStar(av[1].GetDword);
  av[0].SetDword(0);
  if Star <> nil then
  begin
    if (av[2].RealVType = vkDword) and (av[2].GetDword > $10000) then
    begin
      Item := TItem(av[2].GetDword);
      Index := Star.Items.IndexOf(Item);
      if Index < 0 then Exit;
    end
    else
    begin
      Index := av[2].GetInt;
      if (Index < 0) or (Index >= Star.Items.Count) then Exit;
      Item := TItem(Star.Items[Index]);
    end;
    if not Star.RecordingTurnFilm then Item.ReleaseGraphObject
    else
    begin
      if Item.GraphObject <> nil then
      begin
        TEFilm(PrimaryFilm).DetachObject(Star.CurrentStepIndex, Item.FilmObject);
        Star.PendingFilmObjectRemovals.Add(Item.FilmObject);
        ReleaseSpaceObject(Item.GraphObject);
      end;
    end;
    Star.Items.Delete(Index);
    Star.ClearItemReferences(Item);
    av[0].SetDword(Cardinal(Item));
  end;
end;
{ @end $61D614 }

{ @routine $61D7AC SF_PlanetItems }
procedure SF_PlanetItems(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetItems');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    if Planet.SurfaceLootEntries <> nil then Count := Planet.SurfaceLootEntries.Count else Count := 0;
    if High(av) = 1 then av[0].SetInt(Count)
    else
    begin
      Index := av[2].GetInt;
      if (Index >= 0) and (Index < Count) then av[0].SetDword(Cardinal(PPlanetSurfaceLootEntry(Planet.SurfaceLootEntries[Index]).Item))
      else av[0].SetDword(0);
    end;
  end
  else av[0].SetDword(0);
end;
{ @end $61D7AC }

{ @routine $61D8BC SF_StorageItems }
procedure SF_StorageItems(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then av[0].SetInt(GetPlayer.StorageEntries.Count)
  else
  begin
    Index := av[1].GetInt;
    if (Index >= 0) and (Index < GetPlayer.StorageEntries.Count) then av[0].SetDword(Cardinal(PStorageEntry(GetPlayer.StorageEntries[Index]).Item))
    else av[0].SetDword(0);
  end;
end;
{ @end $61D8BC }

{ @routine $61D95C SF_StorageItemLocation }
procedure SF_StorageItemLocation(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StorageItemLocation');
  Index := av[1].GetInt;
  av[0].SetDword(0);
  if (Index >= 0) and (Index < GetPlayer.StorageEntries.Count) then av[0].SetDword(Cardinal(PStorageEntry(GetPlayer.StorageEntries[Index]).LocationOwner));
end;
{ @end $61D95C }

{ @routine $61DA20 SF_ShopItems }
procedure SF_ShopItems(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Wanted, Index, Count: Integer;
  Items: TList;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShopItems');
  Shop := TObject(av[1].GetDword);
  if Shop = nil then raise Exception.Create('Error.Script ShopItems shop=nil');
  if Shop is TPlanet then Items := TPlanet(Shop).EquipmentShop
  else if Shop is TRuins then Items := TRuins(Shop).EquipmentShop
  else raise Exception.Create('Error.Script ShopItems obj not a shop');
  if High(av) = 1 then
  begin
    Count := 0;
    if (TemporaryShopSlots <> nil) and ((GetPlayer.CurrentPlanet = Shop) or (GetPlayer.DockedTo = Shop)) then
    begin
      for Index := 0 to TemporaryShopSlots.Count - 1 do
        if TemporaryShopSlots[Index] <> nil then
          if TShopSlot(TemporaryShopSlots[Index]).Item <> nil then Inc(Count);
    end
    else
      for Index := 0 to Items.Count - 1 do
        if Items[Index] <> nil then Inc(Count);
    av[0].SetInt(Count);
  end
  else
  begin
    Wanted := av[2].GetInt;
    av[0].SetDword(0);
    if (TemporaryShopSlots <> nil) and ((GetPlayer.CurrentPlanet = Shop) or (GetPlayer.DockedTo = Shop)) then
    begin
      Count := -1;
      for Index := 0 to TemporaryShopSlots.Count - 1 do
        if TemporaryShopSlots[Index] <> nil then
          if TShopSlot(TemporaryShopSlots[Index]).Item <> nil then
          begin
            Inc(Count);
            if Count = Wanted then
            begin
              av[0].SetDword(Cardinal(TShopSlot(TemporaryShopSlots[Index]).Item));
              Break;
            end;
          end;
    end
    else if (Wanted >= 0) and (Wanted < Items.Count) then av[0].SetDword(Cardinal(Items[Wanted]));
  end;
end;
{ @end $61DA20 }

{ @routine $61DD10 SF_AddDialogOverride }
procedure SF_AddDialogOverride(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogOverride;
  DialogName: WideString;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddDialogOverride');
  DialogName := av[1].GetString;
  if CountDelimitedPartsW(DialogName, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(DialogName, 0, ':'));
    if Index < 0 then Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then Exit;
    New(Entry);
    Entry.Script := TScript(Galaxy.Scripts[Index]);
    Entry.DialogName := ExtractDelimitedPartW(DialogName, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := DialogName;
  end;
  Entry.Priority := av[2].GetInt;
  if High(av) > 2 then Entry.AnswerData := av[3].GetDword else Entry.AnswerData := 0;
  if ScriptDialogOverrides = nil then ScriptDialogOverrides := TObjectList.Create;
  ScriptDialogOverrides.Add(Entry);
end;
{ @end $61DD10 }

{ @routine $61DF10 SF_AddDialogInject }
procedure SF_AddDialogInject(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogInjection;
  DialogName: WideString;
  Index: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script AddDialogInject');
  DialogName := av[1].GetString;
  if CountDelimitedPartsW(DialogName, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(DialogName, 0, ':'));
    if Index < 0 then Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then Exit;
    New(Entry);
    Entry.Script := TScript(Galaxy.Scripts[Index]);
    Entry.DialogName := ExtractDelimitedPartW(DialogName, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := DialogName;
  end;
  Entry.Text := av[2].GetString;
  Entry.Answer := av[3].GetString;
  Entry.Priority := av[4].GetInt;
  if High(av) > 4 then Entry.ReplaceGreeting := av[5].GetInt <> 0 else Entry.ReplaceGreeting := False;
  if High(av) > 5 then Entry.AnswerData := av[6].GetDword else Entry.AnswerData := 0;
  if High(av) > 6 then
  begin
    Entry.ActionCode := av[7].GetString;
    Entry.ActionScript := CurrentScript;
  end
  else
  begin
    Entry.ActionCode := '';
    Entry.ActionScript := nil;
  end;
  if ScriptDialogInjections = nil then ScriptDialogInjections := TObjectList.Create;
  ScriptDialogInjections.Add(Entry);
end;
{ @end $61DF10 }

{ @routine $61E1B4 SF_InjectAnswer }
procedure SF_InjectAnswer(av: array of TVarEC; code: TCodeEC);
var Text, Mode: WideString; Count, Index: Integer; Entry: PScriptDialogInjection;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script InjectAnswer');
  Text := av[1].GetString;
  if CountDelimitedPartsW(Text, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(Text, 0, ':'));
    if Index < 0 then Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then Exit;
    New(Entry);
    Entry.Script := TScript(Galaxy.Scripts[Index]);
    Entry.DialogName := ExtractDelimitedPartW(Text, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := Text;
  end;
  Entry.Text := '';
  Entry.Answer := av[2].GetString;
  Entry.Priority := 0;
  Entry.AnswerData := av[3].GetDword;
  Entry.ReplaceGreeting := False;
  if High(av) > 3 then
  begin
    Entry.ActionCode := av[4].GetString;
    Entry.ActionScript := CurrentScript;
  end
  else
  begin
    Entry.ActionCode := '';
    Entry.ActionScript := nil;
  end;
  if ScriptDialogInjections = nil then ScriptDialogInjections := TObjectList.Create;
  ScriptDialogInjections.Add(Entry);
  Text := Entry.Answer;
  Mode := '';
  Count := CountDelimitedPartsW(Text, '~');
  if Count > 1 then
  begin
    Mode := ExtractDelimitedPartW(Text, 0, '~');
    Text := ExtractDelimitedRangeW(Text, 1, Count - 1, '~');
  end;
  if GetPlayer.IsDockedToShip then
  begin
    if Mode = 'block' then RuinsTalkScreen.AddChoice(Text, 0, ScriptDialogBlockCallback)
    else if Mode = 'snap' then RuinsTalkScreen.AddChoice(Text, Integer(Entry), RuinsTalkScreen.RunInjectedDialogKeepingScroll)
    else RuinsTalkScreen.AddChoice(Entry.Answer, Integer(Entry), RuinsTalkScreen.RunInjectedDialog);
  end
  else if GetPlayer.IsOnPlanet then
  begin
    if Mode = 'block' then GovernmentScreen.AddChoice(Text, 0, ScriptDialogBlockCallback)
    else if Mode = 'snap' then GovernmentScreen.AddChoice(Text, Integer(Entry), GovernmentScreen.RunInjectedAnswerKeepingScroll)
    else GovernmentScreen.AddChoice(Entry.Answer, Integer(Entry), GovernmentScreen.RunInjectedAnswer);
  end
  else if Mode = 'block' then TalkScreen.AddChoice(Text, 0, ScriptDialogBlockCallback, 0)
  else if Mode = 'snap' then TalkScreen.AddChoice(Text, Integer(Entry), TalkScreen.RunInjectedAnswerKeepingScroll, 0)
  else TalkScreen.AddChoice(Entry.Answer, Integer(Entry), TalkScreen.RunInjectedAnswer, 0);
end;
{ @end $61E1B4 }

{ @routine $61E658 SF_AddDialogBlock }
procedure SF_AddDialogBlock(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogBlock;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AddDialogBlock');
  if ScriptDialogBlocks = nil then ScriptDialogBlocks := TObjectList.Create;
  for I := 0 to ScriptDialogBlocks.Count - 1 do
  begin
    Entry := PScriptDialogBlock(ScriptDialogBlocks[I]);
    if (Entry.Script = CurrentScript) and (Entry.Text = av[1].GetString) then
    begin
      if High(av) > 1 then Entry.Mode := av[2].GetInt else Entry.Mode := 2;
      Exit;
    end;
  end;
  New(Entry);
  Entry.Text := av[1].GetString;
  Entry.Script := CurrentScript;
  if High(av) > 1 then Entry.Mode := av[2].GetInt else Entry.Mode := 2;
  ScriptDialogBlocks.Add(Entry);
end;
{ @end $61E658 }

{ @routine $61E804 SF_GotoGov }
procedure SF_GotoGov(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.PendingDockDialogue);
  if High(av) >= 1 then GetPlayer.PendingDockDialogue := av[1].GetInt;
end;
{ @end $61E804 }

{ @routine $61E864 SF_GetShipPlanet }
procedure SF_GetShipPlanet(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipPlanet');
  Ship := TShip(av[1].GetDword);
  if GetPlayer.RuinsProxy = Ship then av[0].SetDword(Cardinal(GetPlayer.RuinsSavedPlanet))
  else av[0].SetDword(Cardinal(Ship.CurrentPlanet));
end;
{ @end $61E864 }

{ @routine $61E914 SF_GetShipHomePlanet }
procedure SF_GetShipHomePlanet(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipHomePlanet');
  Ship := TShip(av[1].GetDword);
  av[0].SetDword(Cardinal(Ship.HomePlanet));
end;
{ @end $61E914 }

{ @routine $61E9A0 SF_GetShipRuins }
procedure SF_GetShipRuins(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipRuins');
  Ship := TShip(av[1].GetDword);
  if GetPlayer.RuinsProxy = Ship then av[0].SetDword(Cardinal(GetPlayer.RuinsSavedDockedTo))
  else av[0].SetDword(Cardinal(Ship.DockedTo));
end;
{ @end $61E9A0 }

{ @routine $61EA50 SF_GetTalkShip }
procedure SF_GetTalkShip(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetDword(Cardinal(TalkShip));
end;
{ @end $61EA50 }

{ @routine $61EA8C SF_TalkByAI }
procedure SF_TalkByAI(av: array of TVarEC; code: TCodeEC);
begin
  if TalkScripted then av[0].SetInt(1) else av[0].SetInt(0);
end;
{ @end $61EA8C }

{ @routine $61EAE0 SF_GetTalkType }
procedure SF_GetTalkType(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Ord(TalkType));
end;
{ @end $61EAE0 }

{ @routine $61EB20 SF_ScriptRun }
procedure SF_ScriptRun(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Planet: TPlanet;
  Name: WideString;
  I: Integer;
  Script: TScript;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ScriptRun');
  Star := TStar(av[1].GetDword);
  Planet := TPlanet(av[2].GetDword);
  Name := av[3].GetString;
  av[0].SetInt(0);
  for I := 0 to Galaxy.Scripts.Count - 1 do
  begin
    Script := TScript(Galaxy.Scripts[I]);
    if Script.ScriptFileName = Name then
    begin
      if Script.Ships.Count > 0 then Exit;
      if TryRestartScript(Script, Star, Planet) then av[0].SetInt(1);
      Exit;
    end;
  end;
  if TryStartScriptByName(Star, Planet, Name) then av[0].SetInt(1);
end;
{ @end $61EB20 }

{ @routine $61EE08 SF_SFT }
procedure SF_SFT(av: array of TVarEC; code: TCodeEC);
var I: Integer;
  // @nested $61EC8C LogArray
  procedure LogArray(Prefix: WideString; Value: TVarEC); // @addr 0x61EC8C @note "Nested in SF_SFT; Value must resolve to an array."
  var I: Integer; Item: TVarEC; Path: WideString;
  begin
    for I := 0 to Value.GetArray.Count - 1 do
    begin
      Item := Value.GetArray.GetItem(I);
      if Item.Name <> '' then Path := Prefix + '''' + Item.Name + ''''
      else Path := Prefix + IntToWideString(I);
      if Item.RealVType <> vkArray then AppendLogLineThreadSafe(AnsiString(Path + ']=' + Item.GetString))
      else LogArray(Path + ',', Item);
    end;
  end;
begin
  if High(av) < 1 then Exit;
  for I := 1 to High(av) do
    if av[I].RealVType = vkArray then LogArray(av[I].Name + '[', av[I])
    else AppendLogLineThreadSafe(AnsiString(av[I].GetString));
end;
{ @end $61EE08 }

{ @routine $61EF04 SF_StartTextQuest }
procedure SF_StartTextQuest(av: array of TVarEC; code: TCodeEC);
var Request: PQueuedTextQuest;
begin
  if High(av) = 0 then
  begin
    av[0].SetInt(QueuedTextQuests.Count);
    Exit;
  end;

  New(Request);
  Request.Name := av[1].GetString;
  if High(av) > 1 then Request.SuccessCaption := av[2].GetString else Request.SuccessCaption := '';
  if High(av) > 2 then Request.FailureCaption := av[3].GetString else Request.FailureCaption := '';
  Request.Script := CurrentScript;
  QueuedTextQuests.Add(Request);
  if CurrentScript <> nil then CurrentScript.InitCode.LocalVar.GetVar('GQuestStatus').SetInt(1);
  av[0].SetInt(1);
end;
{ @end $61EF04 }

{ @routine $61F088 SF_CreateABShip }
procedure SF_CreateABShip(av: array of TVarEC; code: TCodeEC);
var Ship: TabShipAI; Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateABShip');
  if CurrentScript <> StagedArcadeShipScript then StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  Ship := TabShipAI.Create;
  Ship.SpawnGraphKey := av[1].GetString;
  Ship.RandomRewardsDisabled := True;
  if High(av) > 1 then Ship.Team := av[2].GetInt else Ship.Team := 0;
  if High(av) > 2 then Ship.HealthScalePercent := av[3].GetInt else Ship.HealthScalePercent := 100;
  if High(av) > 3 then Ship.DamageScalePercent := av[4].GetInt else Ship.DamageScalePercent := 100;
  if High(av) > 4 then Ship.ScriptLabel := av[5].GetString else Ship.ScriptLabel := '';
  if High(av) > 5 then
  begin
    Obj := TObject(av[6].GetDword);
    if av[6].GetInt = -1 then Ship.RandomRewardsDisabled := False
    else if Obj is TScriptItem then Ship.RewardObject := TScriptItem(Obj).Item
    else Ship.RewardObject := Obj;
  end
  else Ship.RewardObject := nil;
  StagedArcadeShips.Add(Ship);
  av[0].SetDword(Cardinal(Ship));
end;
{ @end $61F088 }

{ @routine $61F2C0 SF_ConvertToABShip }
procedure SF_ConvertToABShip(av: array of TVarEC; code: TCodeEC);
var I: Integer; Source: TShip; Ship: TabShipAI; Weapon: TWeapon; Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ConvertToABShip');
  if CurrentScript <> StagedArcadeShipScript then StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  Source := TShip(av[1].GetDword);
  if Source <> nil then
  begin
    Ship := TabShipAI.Create;
    Ship.RandomRewardsDisabled := True;
    if Source.Graphic is TRuinsSE then
      Ship.CreateRuinsVisual(Source.Graphic.GraphKey, Max(Source.Graphic.Size.X, Source.Graphic.Size.Y))
    else Ship.CreateShipVisual(Source.Graphic.GraphKey, Source.Graphic.Size.X);
    Ship.ConvertedFromGameShip := True;
    Ship.MaxHealth := Source.GetHull.Weight;
    Ship.Health := Source.GetHull.HullPoints;
    Ship.WeaponCount := 0;
    Source.RefreshAssignedItemSlots;
    for I := 0 to 4 do
    begin
      Weapon := Source.FindEquippedItemInSlot(WeaponCategoryItemType, I) as TWeapon;
      if Source.IsEquipmentUsable(Weapon) then
      begin
        if Weapon.ItemType <> t_CustomWeapon then ab_Weapon_Initialize(@Ship.Weapons[I], Ord(Weapon.ItemType))
        else ab_Weapon_Initialize(@Ship.Weapons[I], Weapon.GetWeaponInfo.ArcadeWeaponType);
        Ship.Weapons[I].SlotData := Weapon.AssignedSlotData;
        Inc(Ship.WeaponCount);
      end;
    end;
    Ship.PrimaryWeapon := 0;
    if High(av) > 1 then Ship.Team := av[2].GetInt else Ship.Team := 0;
    if High(av) > 2 then Ship.HealthScalePercent := av[3].GetInt else Ship.HealthScalePercent := 100;
    if High(av) > 3 then Ship.DamageScalePercent := av[4].GetInt else Ship.DamageScalePercent := 100;
    if High(av) > 4 then Ship.ScriptLabel := av[5].GetString else Ship.ScriptLabel := '';
    if High(av) > 5 then
    begin
      Obj := TObject(av[6].GetDword);
      if av[6].GetInt = -1 then Ship.RandomRewardsDisabled := False
      else if Obj is TScriptItem then Ship.RewardObject := TScriptItem(Obj).Item
      else Ship.RewardObject := Obj;
    end
    else Ship.RewardObject := nil;
    StagedArcadeShips.Add(Ship);
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $61F2C0 }

{ @routine $61F670 SF_ABShipModifiers }
procedure SF_ABShipModifiers(av: array of TVarEC; code: TCodeEC);
var Ship: TabShip; Value: PSingle; Name: WideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlayerABDamageMod');
  if TPlayer(av[1].GetDword) = GetPlayer then Ship := PlayerArcadeShip else Ship := TabShip(av[1].GetDword);
  if Ship = nil then
  begin
    av[0].SetInt(0);
    Exit;
  end;

  Name := LowerCase(AnsiString(av[2].GetString));
  if Name = 'damage' then Value := @Ship.WeaponDamageScale
  else if Name = 'recharge' then Value := @Ship.AmmoRechargeScale
  else if Name = 'speed' then Value := @Ship.MovementScale
  else if Name = 'gravity' then Value := @Ship.GravityScale
  else if Name = 'regen' then Value := @Ship.RegenerationRate
  else if Name = 'fragility' then Value := @Ship.DamageTakenScale
  else if Name = 'luck' then Value := @Ship.LuckScale
  else Exit;
  av[0].SetInt(Round(100 * Value^));
  if High(av) > 2 then Value^ := av[3].GetInt * 0.01;
end;
{ @end $61F670 }

{ @routine $61F944 SF_StartAB }
procedure SF_StartAB(av: array of TVarEC; code: TCodeEC);
var Request: PScriptABRequest;
begin
  if High(av) = 0 then
  begin
    av[0].SetInt(QueuedArcadeBattles.Count);
    Exit;
  end;

  if CurrentScript <> StagedArcadeShipScript then StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  New(Request);
  Request.MapName := av[1].GetString;
  Request.BackgroundId := 0;
  Request.BackgroundMapName := '';
  Request.Script := CurrentScript;
  Request.Ships := TObjectList.Create;
  while StagedArcadeShips.Count > 0 do
  begin
    Request.Ships.Add(StagedArcadeShips[0]);
    StagedArcadeShips.Delete(0);
  end;
  if High(av) > 1 then
  begin
    if av[2].RealVType = vkInt then Request.BackgroundId := av[2].GetInt
    else if av[2].RealVType = vkString then Request.BackgroundMapName := av[2].GetString;
  end;
  QueuedArcadeBattles.Add(Request);
  if CurrentScript <> nil then CurrentScript.InitCode.LocalVar.GetVar('GABStatus').SetInt(1);
  av[0].SetInt(1);
end;
{ @end $61F944 }

{ @routine $61FB3C SF_StartRobots }
procedure SF_StartRobots(av: array of TVarEC; code: TCodeEC);
var Request: PScriptPBRequest;
begin
  if High(av) = 0 then
  begin
    av[0].SetInt(QueuedPlanetaryBattles.Count);
    Exit;
  end;

  if High(av) < 5 then raise Exception.Create('Error.Script StartRobots');
  New(Request);
  Request.MapName := av[1].GetString;
  Request.StartText := av[2].GetString;
  Request.SuccessText := av[3].GetString;
  Request.FailureText := av[4].GetString;
  Request.PlaceText := av[5].GetString;
  if High(av) > 5 then Request.StartText := av[6].GetString + Request.StartText
  else Request.StartText := '621' + Request.StartText;
  Request.Script := CurrentScript;
  QueuedPlanetaryBattles.Add(Request);
  if CurrentScript <> nil then CurrentScript.InitCode.LocalVar.GetVar('GRobotStatus').SetInt(1);
end;
{ @end $61FB3C }

{ @routine $61FD54 SF_MarkRobotsMapAsUsed }
procedure SF_MarkRobotsMapAsUsed(av: array of TVarEC; code: TCodeEC);
var I: Integer; Name: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MarkRobotsMapAsUsed');
  Name := av[1].GetString;
  for I := 0 to High(RobotMapDefinitions) do
    if RobotMapDefinitions[I].Map = Name then
    begin
      SetLength(GetPlayer.PlanetBattleHistory, High(GetPlayer.PlanetBattleHistory) + 2);
      with GetPlayer.PlanetBattleHistory[High(GetPlayer.PlanetBattleHistory)] do
      begin
        MapId := RobotMapDefinitions[I].Id;
        Statistics.SignedTimeMs := 0;
        Statistics.RobotsBuilt := 0;
        Statistics.RobotsDestroyed := 0;
        Statistics.TurretsBuilt := 0;
        Statistics.TurretsDestroyed := 0;
        Statistics.BuildingsDestroyed := 0;
        ResultCode := 1;
        CompletionMode := 0;
        DateTurn := Galaxy.CurrentTurn;
      end;
      if High(av) > 1 then
        if av[2].GetInt <> 0 then GetPlayer.LastPlanetBattleTurn := Galaxy.CurrentTurn;
    end;
  // Native $61FEE2 falls through after matches; the error is unconditional.
  raise Exception.Create(AnsiString('Error.Script MarkRobotsMapAsUsed map not found ' + Name));
end;
{ @end $61FD54 }

{ @routine $61FFE4 SF_ShipOwner }
procedure SF_ShipOwner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  WasPirateClan, IsPirateClan: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOwner');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    av[0].SetInt(Ord(Ship.OwnerId));
    if High(av) > 1 then
    begin
      WasPirateClan := (Ship.TypeId = stPirate) and (Ship.OwnerId = oiPirate);
      Ship.OwnerId := TOwnerId(av[2].GetInt);
      IsPirateClan := (Ship.TypeId = stPirate) and (Ship.OwnerId = oiPirate);
      if WasPirateClan and not IsPirateClan then
      begin
        Dec(Galaxy.PirateClanCount);
        Inc(Galaxy.PirateCount);
      end;
      if IsPirateClan and not WasPirateClan then
      begin
        Inc(Galaxy.PirateClanCount);
        Dec(Galaxy.PirateCount);
      end;
    end;
  end
  else av[0].SetInt(-1);
end;
{ @end $61FFE4 }

{ @routine $620114 SF_ShipPilotRace }
procedure SF_ShipPilotRace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipPilotRace');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    av[0].SetInt(Ord(Ship.PilotRace));
    if High(av) > 1 then Ship.PilotRace := TOwnerId(av[2].GetInt);
  end
  else av[0].SetInt(-1);
end;
{ @end $620114 }

{ @routine $6201D0 SF_ShipSkill }
procedure SF_ShipSkill(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Skill, Value: Integer;
  Current: Boolean;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipSkill');
  Ship := TShip(av[1].GetDword);
  if Ship = nil then Exit;
  Current := False;
  if av[2].RealVType = vkString then
  begin
    if av[2].GetString = 'Accuracy' then Skill := 0
    else if av[2].GetString = 'AccuracyCur' then begin Skill := 0; Current := True; end
    else if av[2].GetString = 'Mobility' then Skill := 1
    else if av[2].GetString = 'MobilityCur' then begin Skill := 1; Current := True; end
    else if av[2].GetString = 'Technical' then Skill := 2
    else if av[2].GetString = 'TechnicalCur' then begin Skill := 2; Current := True; end
    else if av[2].GetString = 'Trader' then Skill := 3
    else if av[2].GetString = 'TraderCur' then begin Skill := 3; Current := True; end
    else if av[2].GetString = 'Charm' then Skill := 4
    else if av[2].GetString = 'CharmCur' then begin Skill := 4; Current := True; end
    else if av[2].GetString = 'Leadership' then Skill := 5
    else if av[2].GetString = 'LeadershipCur' then begin Skill := 5; Current := True; end
    else raise Exception.Create('Error.Script ShipSkill unknown query ' + av[2].GetString);
  end
  else
  begin
    Skill := av[2].GetInt;
    if (Skill < 0) or (Skill > 5) then raise Exception.Create('Error.Script ShipSkill - invalid skill index');
  end;
  if Current then av[0].SetInt(Ship.GetEffectiveSkillLevel(TPilotSkill(Skill)))
  else av[0].SetInt(Ship.BaseSkills[TPilotSkill(Skill)]);
  if High(av) > 2 then
  begin
    Value := av[3].GetInt;
    Ship.BaseSkills[TPilotSkill(Skill)] := Max(0, Min(6, Value));
  end;
end;
{ @end $6201D0 }

{ @routine $620768 SF_ShipFace }
procedure SF_ShipFace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipFace');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if High(av) > 1 then
    begin
      if av[2].RealVType = vkString then
      begin
        if av[2].GetString = 'Init' then
        begin
          if Ship.PortraitFaceId = -1 then Ship.GetCaptainPortraitResourceBase;
          av[0].SetInt(Ship.PortraitFaceId);
        end
        else if av[2].GetString = 'New' then
        begin
          Ship.PortraitFaceId := -1;
          Ship.GetCaptainPortraitResourceBase;
          av[0].SetInt(Ship.PortraitFaceId);
        end
        else if av[2].GetString = 'Path' then av[0].SetString(Ship.GetCaptainPortraitResourceBase)
        else raise Exception.Create('Error.Script ShipFace unknown keyword - ' + av[2].GetString);
      end
      else
      begin
        av[0].SetInt(Ship.PortraitFaceId);
        Ship.PortraitFaceId := av[2].GetInt;
      end;
    end
    else av[0].SetInt(Ship.PortraitFaceId);
  end;
end;
{ @end $620768 }

{ @routine $620A24 SF_ShipFreeExp }
procedure SF_ShipFreeExp(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipFreeExp');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    av[0].SetInt(Ship.FreeExperience);
    if High(av) > 1 then Ship.FreeExperience := av[2].GetInt;
  end;
end;
{ @end $620A24 }

{ @routine $620AD0 SF_GetShipExpByType }
procedure SF_GetShipExpByType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipExpByType');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if (High(av) = 1) or (GetPlayer <> Ship) then av[0].SetInt(Ship.TotalExperience)
    else
      case av[2].GetInt of
        1: av[0].SetInt(GetPlayer.ExperienceByDominators);
        2: av[0].SetInt(GetPlayer.ExperienceByPirates);
        3: av[0].SetInt(GetPlayer.ExperienceByNormals);
        4: av[0].SetInt(GetPlayer.ExperienceByTraderCareer);
        5: av[0].SetInt(GetPlayer.TotalExperience - GetPlayer.ExperienceByDominators - GetPlayer.ExperienceByPirates - GetPlayer.ExperienceByNormals - GetPlayer.ExperienceByTraderCareer);
      else av[0].SetInt(Ship.TotalExperience);
      end;
  end;
end;
{ @end $620AD0 }

{ @routine $620C6C SF_CoordX }
procedure SF_CoordX(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Position: TPointF;
  Link: PConstellationStarLink;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CoordX');
  Obj := TObject(av[1].GetDword);
  av[0].SetInt(0);
  if Obj <> nil then
  begin
    if Obj is TShip then Position := (Obj as TShip).Position
    else if Obj is TItem then Position := (Obj as TItem).Position
    else if Obj is TScriptItem then
    begin
      if (Obj as TScriptItem).Item <> nil then Position := (Obj as TScriptItem).Item.Position
      else raise Exception.Create('Error.Script CoordX - script item does not exist');
    end
    else if Obj is TScriptPlace then Position := (Obj as TScriptPlace).GetPoint
    else if Obj is TPlanet then Position := (Obj as TPlanet).GetPosition
    else if Obj is TStar then Position := (Obj as TStar).Position
    else if Obj is TAsteroid then Position := (Obj as TAsteroid).Position
    else if Obj is TMissile then Position := (Obj as TMissile).Position
    else raise Exception.Create('Error.Script CoordX - Object type not supported');
    av[0].SetInt(Round(Position.X));
    if High(av) > 1 then
    begin
      Position.X := av[2].GetInt;
      if Obj is TShip then (Obj as TShip).Position := Position
      else if Obj is TItem then (Obj as TItem).Position := Position
      else if Obj is TScriptItem then (Obj as TScriptItem).Item.Position := Position
      else if Obj is TScriptPlace then
      begin
        with IntegerPointToPolar(Classes.Point(Round(Position.X), Round(Position.Y))) do
        begin
          (Obj as TScriptPlace).Radius := Round(Radius);
          (Obj as TScriptPlace).AngleOffset := AngleRadians;
        end;
      end
      else if Obj is TPlanet then
      begin
        (Obj as TPlanet).Orbit := TPolarPoint(IntegerPointToPolar(Classes.Point(Round(Position.X), Round(Position.Y))));
        (Obj as TPlanet).Graphic.SetPosition(Position);
      end
      else if Obj is TStar then
      begin
        with TStar(Obj).Constellation.StarLinks do
          for Index := 0 to Count - 1 do
          begin
            Link := PConstellationStarLink(Items[Index]);
            if (Link.StartPoint.X = TStar(Obj).Position.X) and (Link.StartPoint.Y = TStar(Obj).Position.Y) then
          begin
            Link.StartPoint.X := Position.X;
            Link.StartPoint.Y := Position.Y;
          end;
            if (Link.EndPoint.X = TStar(Obj).Position.X) and (Link.EndPoint.Y = TStar(Obj).Position.Y) then
          begin
            Link.EndPoint.X := Position.X;
            Link.EndPoint.Y := Position.Y;
          end;
          end;
        (Obj as TStar).Position := Position;
      end
      else if Obj is TAsteroid then (Obj as TAsteroid).Position := Position
      else if Obj is TMissile then (Obj as TMissile).Position := Position;
    end;
  end;
end;
{ @end $620C6C }

{ @routine $621204 SF_CoordY }
procedure SF_CoordY(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Position: TPointF;
  Link: PConstellationStarLink;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CoordY');
  Obj := TObject(av[1].GetDword);
  av[0].SetInt(0);
  if Obj <> nil then
  begin
    if Obj is TShip then Position := (Obj as TShip).Position
    else if Obj is TItem then Position := (Obj as TItem).Position
    else if Obj is TScriptItem then
    begin
      if (Obj as TScriptItem).Item <> nil then Position := (Obj as TScriptItem).Item.Position
      else raise Exception.Create('Error.Script CoordY - script item does not exist');
    end
    else if Obj is TScriptPlace then Position := (Obj as TScriptPlace).GetPoint
    else if Obj is TPlanet then Position := (Obj as TPlanet).GetPosition
    else if Obj is TStar then Position := (Obj as TStar).Position
    else if Obj is TAsteroid then Position := (Obj as TAsteroid).Position
    else if Obj is TMissile then Position := (Obj as TMissile).Position
    else raise Exception.Create('Error.Script CoordY - Object type not supported');
    av[0].SetInt(Round(Position.Y));
    if High(av) > 1 then
    begin
      Position.Y := av[2].GetInt;
      if Obj is TShip then (Obj as TShip).Position := Position
      else if Obj is TItem then (Obj as TItem).Position := Position
      else if Obj is TScriptItem then (Obj as TScriptItem).Item.Position := Position
      else if Obj is TScriptPlace then
      begin
        with IntegerPointToPolar(Classes.Point(Round(Position.X), Round(Position.Y))) do
        begin
          (Obj as TScriptPlace).Radius := Round(Radius);
          (Obj as TScriptPlace).AngleOffset := AngleRadians;
        end;
      end
      else if Obj is TPlanet then
      begin
        (Obj as TPlanet).Orbit := TPolarPoint(IntegerPointToPolar(Classes.Point(Round(Position.X), Round(Position.Y))));
        (Obj as TPlanet).Graphic.SetPosition(Position);
      end
      else if Obj is TStar then
      begin
        with TStar(Obj).Constellation.StarLinks do
          for Index := 0 to Count - 1 do
          begin
            Link := PConstellationStarLink(Items[Index]);
            if (Link.StartPoint.X = TStar(Obj).Position.X) and (Link.StartPoint.Y = TStar(Obj).Position.Y) then
          begin
            Link.StartPoint.X := Position.X;
            Link.StartPoint.Y := Position.Y;
          end;
            if (Link.EndPoint.X = TStar(Obj).Position.X) and (Link.EndPoint.Y = TStar(Obj).Position.Y) then
          begin
            Link.EndPoint.X := Position.X;
            Link.EndPoint.Y := Position.Y;
          end;
          end;
        (Obj as TStar).Position := Position;
      end
      else if Obj is TAsteroid then (Obj as TAsteroid).Position := Position
      else if Obj is TMissile then (Obj as TMissile).Position := Position;
    end;
  end;
end;
{ @end $621204 }

{ @routine $62179C SF_ShipSetCoords }
procedure SF_ShipSetCoords(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipSetCoords');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    Ship.Position.X := av[2].GetInt;
    Ship.Position.Y := av[3].GetInt;
    Ship.Graphic.SetPosition(Ship.Position);
  end;
end;
{ @end $62179C }

{ @routine $621860 SF_ShipAngle }
procedure SF_ShipAngle(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipAngle');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    av[0].SetFloat(Ship.MovementDirection);
    if High(av) > 1 then
    begin
      Ship.MovementDirection := av[2].GetFloat;
      Ship.Graphic.SetAngle(HeadingDegreesToByte(Ship.MovementDirection));
    end;
  end;
end;
{ @end $621860 }

{ @routine $621934 SF_ObjectType }
procedure SF_ObjectType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ObjectType');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TStar then av[0].SetInt(1)
  else if Obj is THole then av[0].SetInt(2)
  else if Obj is TPlanet then av[0].SetInt(3)
  else if Obj is TRuins then av[0].SetInt(4)
  else if Obj is TShip then av[0].SetInt(5)
  else if Obj is TItem then av[0].SetInt(6)
  else if Obj is TMissile then av[0].SetInt(7)
  else if Obj is TAsteroid then av[0].SetInt(8);
end;
{ @end $621934 }

{ @routine $621AD8 SF_ShipInHyperSpace }
procedure SF_ShipInHyperSpace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInHyperSpace');
  av[0].SetInt(0);
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if (High(av) > 1) and (av[2].GetInt <> 0) then
      while Ship.DockedTo <> nil do Ship := Ship.DockedTo;
    av[0].SetInt(Ord(Ship.InHyperspace));
  end;
end;
{ @end $621AD8 }

{ @routine $621BA4 SF_ShipStatus }
procedure SF_ShipStatus(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
  Career: TRangerCareer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipStatus');
  Obj := TObject(av[1].GetDword);
  if Obj is TRanger then Ranger := TRanger(Obj)
  else raise Exception.Create('Error.Script ShipStatus - not Ranger');
  Career := TRangerCareer(av[2].GetInt);
  av[0].SetInt(Ranger.CareerStatus[Career]);
  if High(av) > 2 then Ranger.CareerStatus[Career] := av[3].GetInt;
end;
{ @end $621BA4 }

{ @routine $621CC0 SF_BuyRanger }
procedure SF_BuyRanger(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyRanger');
  MoneyPercent := 100;
  if High(av) > 1 then MoneyPercent := av[2].GetInt;
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    Ship := TShip(Planet.BuyRanger(MoneyPercent));
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $621CC0 }

{ @routine $621D70 SF_BuyWarrior }
procedure SF_BuyWarrior(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyWarrior');
  MoneyPercent := 100;
  if High(av) > 1 then MoneyPercent := av[2].GetInt;
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    Ship := TShip(Planet.BuyWarrior(MoneyPercent));
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $621D70 }

{ @routine $621E20 SF_BuyBigWarrior }
procedure SF_BuyBigWarrior(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyBigWarrior');
  MoneyPercent := 100;
  if High(av) > 1 then MoneyPercent := av[2].GetInt;
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    Ship := TShip(Planet.BuyFlagship(MoneyPercent));
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $621E20 }

{ @routine $621ED4 SF_BuyDomik }
procedure SF_BuyDomik(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyDomik');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    Ship := TShip(Planet.SpawnWeightedDominatorShip);
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $621ED4 }

{ @routine $621F68 SF_BuyDomikExtremal }
procedure SF_BuyDomikExtremal(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  SavedSeries: TDominatorSeries;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyDomikExtremal');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    if High(av) = 1 then Ship := TShip(Planet.SpawnWeightedDominatorShip)
    else if High(av) = 2 then Ship := TShip(Planet.SpawnDominatorShip(TKlingType(av[2].GetInt)))
    else
    begin
      SavedSeries := Planet.CurrentStar.DominatorSeries;
      Planet.CurrentStar.DominatorSeries := TDominatorSeries(av[3].GetInt);
      Ship := TShip(Planet.SpawnDominatorShip(TKlingType(av[2].GetInt)));
      Planet.CurrentStar.DominatorSeries := SavedSeries;
    end;
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $621F68 }

{ @routine $622074 SF_BuyTranclucator }
procedure SF_BuyTranclucator(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  BasicEquipment: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyTrank');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    BasicEquipment := True;
    if High(av) > 1 then BasicEquipment := av[2].GetInt <> 0;
    Ship := TShip(Planet.SpawnTranclucator(BasicEquipment));
    av[0].SetDword(Cardinal(Ship));
  end;
end;
{ @end $622074 }

{ @routine $622124 SF_TransferShip }
procedure SF_TransferShip(av: array of TVarEC; code: TCodeEC);
var
  Destination: TObject;
  OldStar, NewStar: TStar;
  Planet: TPlanet;
  Ship, Station: TShip;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script TransferShip');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    OldStar := Ship.CurrentStar;
    if OldStar <> nil then
    begin
      Destination := TObject(av[2].GetDword);
      if Destination <> nil then
      begin
        if not (Destination is TStar) and not (Destination is TPlanet) and not (Destination is TShip) then
          raise Exception.Create('Error.Script TransferShip - invalid destination');
        Planet := nil;
        Station := nil;
        if Destination is TPlanet then
        begin
          Planet := TPlanet(Destination);
          NewStar := Planet.CurrentStar;
        end
        else if Destination is TShip then
        begin
          Station := TShip(Destination);
          NewStar := Station.CurrentStar;
        end
        else NewStar := TStar(Destination);
        Index := OldStar.Ships.IndexOf(Ship);
        if (Index >= 0) and (OldStar.Ships.Count > Index) then OldStar.Ships.Delete(Index);
        NewStar.Ships.Add(Ship);
        Ship.CurrentStar := NewStar;
        if Ship.CurrentPlanet <> nil then
        begin
          if Ship is TNormalShip then (Ship as TNormalShip).LastDockedPlanet := Ship.CurrentPlanet;
        end
        else if (Ship.DockedTo <> nil) and (Ship is TRanger) then (Ship as TRanger).LastDockedNonPlanetLocation := Ship.DockedTo;
        if (GetPlayer = Ship) and (TemporaryShopSlots <> nil) then RestoreTemporaryShopStock;
        Ship.CurrentPlanet := Planet;
        Ship.DockedTo := Station;
        Ship.Order := soNone;
        Ship.OrderStateData := 0;
        Ship.OrderTarget := nil;
        Ship.OrderDestination.X := 0;
        Ship.OrderDestination.Y := 0;
        Ship.OrderAbsolute := False;
        Ship.InHyperspace := False;
        if GetPlayer = Ship then
          if GetPlayer.IsDocked then
          begin
            BuildTemporaryShopSlotGrid;
            EquipmentShopScreen.ClearGoodsControls;
            EquipmentShopScreen.BuildGoodsControls;
          end;
      end;
    end;
  end;
end;
{ @end $622124 }

{ @routine $62240C SF_OrderLock }
procedure SF_OrderLock(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OrderLock');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    av[0].SetInt(Ship.AbsoluteScriptOrder);
    if High(av) > 1 then Ship.AbsoluteScriptOrder := av[2].GetInt;
  end;
end;
{ @end $62240C }

{ @routine $6224B8 SF_OrderForsage }
procedure SF_OrderForsage(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OrderForsage');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(0);
  if Ship <> nil then
  begin
    if Ship.AfterburnerActive then av[0].SetInt(1);
    if High(av) > 1 then
    begin
      if av[2].GetInt <> 0 then Ship.AfterburnerActive := (Ship.GetSlotCount(sskAfterburner) > 0) and Ship.IsEquipmentUsable(Ship.GetEngine)
      else Ship.AfterburnerActive := False;
      Ship.RefreshDerivedStats(True);
      if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
      begin
        StarMapScreen.ClearPathOverlay(True);
        GetPlayer.BuildOrderMovementPath(FullPathNodeLimit);
        StarMapScreen.BuildShipPathOverlay(Ship, False, '');
      end;
    end;
  end;
end;
{ @end $6224B8 }

{ @routine $62261C SF_OrderNone }
procedure SF_OrderNone(av: array of TVarEC; code: TCodeEC);
var
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OrderNone');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    SavedOrderLock := Ship.AbsoluteScriptOrder;
    Ship.AbsoluteScriptOrder := 0;
    Ship.OrderNone(False);
    Ship.AbsoluteScriptOrder := SavedOrderLock;
    if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
    if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
    begin
      StarMapScreen.ClearPathOverlay(True);
      StarMapScreen.BuildShipPathOverlay(Ship, False, '');
    end;
  end;
end;
{ @end $62261C }

{ @routine $622724 SF_OrderMove }
procedure SF_OrderMove(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  Destination: TPointF;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderMove');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    SavedOrderLock := Ship.AbsoluteScriptOrder;
    Ship.AbsoluteScriptOrder := 0;
    if High(av) > 2 then
    begin
      Absolute := False;
      if High(av) > 3 then Absolute := av[4].GetInt <> 0;
      Destination.X := av[2].GetInt;
      Destination.Y := av[3].GetInt;
      Ship.OrderMove(Destination, Absolute);
    end
    else
    begin
      if (av[2].RealVType = vkDword) and (TObject(av[2].GetDword) is TScriptPlace) then
      begin
        Absolute := False;
        if High(av) > 2 then Absolute := av[3].GetInt <> 0;
        Ship.OrderMove(TScriptPlace(av[2].GetDword).GetRandomPoint((Ship.Seed + Ship.CurrentStar.GenerationSeed) * Cardinal(Galaxy.CurrentTurn)), Absolute);
      end
      else raise Exception.Create('Error.Script OrderMove invalid place');
    end;
    Ship.AbsoluteScriptOrder := SavedOrderLock;
    if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
    if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
    begin
      StarMapScreen.ClearPathOverlay(True);
      StarMapScreen.BuildShipPathOverlay(Ship, False, '');
    end;
  end;
end;
{ @end $622724 }

{ @routine $62294C SF_OrderTeleport }
procedure SF_OrderTeleport(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  Destination: TPointF;
  SavedOrderLock: Byte;
  Ship: TShip;
  TransitionData: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script OrderTeleport');
  Absolute := False;
  if High(av) > 4 then Absolute := av[5].GetInt <> 0;
  Destination.X := av[3].GetInt;
  Destination.Y := av[4].GetInt;
  TransitionData := 10;
  if High(av) > 5 then TransitionData := av[6].GetInt;
  if av[1].GetDword <> 0 then
    if av[2].GetDword <> 0 then
    begin
      Ship := TShip(av[1].GetDword);
      if Ship <> nil then
      begin
        SavedOrderLock := Ship.AbsoluteScriptOrder;
        Ship.AbsoluteScriptOrder := 0;
        Ship.OrderTeleport(TStar(av[2].GetDword), Destination, TransitionData, Absolute);
        Ship.AbsoluteScriptOrder := SavedOrderLock;
        if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
        if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
        begin
          StarMapScreen.ClearPathOverlay(True);
          StarMapScreen.BuildShipPathOverlay(Ship, False, '');
        end;
      end;
    end;
end;
{ @end $62294C }

{ @routine $622AF4 SF_OrderTakeOff }
procedure SF_OrderTakeOff(av: array of TVarEC; code: TCodeEC);
var
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OrderTakeOff');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    SavedOrderLock := Ship.AbsoluteScriptOrder;
    Ship.AbsoluteScriptOrder := 0;
    Ship.OrderTakeoff;
    Ship.AbsoluteScriptOrder := SavedOrderLock;
  end;
end;
{ @end $622AF4 }

{ @routine $622B9C SF_OrderFollowShip }
procedure SF_OrderFollowShip(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  FollowMode, SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderFollowShip');
  Absolute := False;
  FollowMode := 0;
  if High(av) > 2 then FollowMode := av[3].GetInt;
  if High(av) > 3 then Absolute := av[4].GetInt <> 0;
  if av[1].GetDword <> 0 then
    if av[2].GetDword <> 0 then
    begin
      Ship := TShip(av[1].GetDword);
      if Ship <> nil then
      begin
        SavedOrderLock := Ship.AbsoluteScriptOrder;
        Ship.AbsoluteScriptOrder := 0;
        Ship.OrderFollowShip(TShip(av[2].GetDword), FollowMode, Absolute);
        Ship.AbsoluteScriptOrder := SavedOrderLock;
        if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
        begin
          StarMapScreen.ClearPathOverlay(True);
          StarMapScreen.BuildShipPathOverlay(Ship, False, '');
        end;
      end;
    end;
end;
{ @end $622B9C }

{ @routine $622D04 SF_OrderJumpHole }
procedure SF_OrderJumpHole(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  Ship: TShip;
  Hole: THole;
  SavedOrderLock: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderJumpHole');
  Ship := TShip(av[1].GetDword);
  Hole := THole(av[2].GetDword);
  if (Ship <> nil) and (Hole <> nil) then
  begin
    Absolute := False;
    if High(av) > 2 then Absolute := av[3].GetInt <> 0;
    SavedOrderLock := Ship.AbsoluteScriptOrder;
    Ship.AbsoluteScriptOrder := 0;
    Ship.OrderJumpHole(Hole, Absolute);
    Ship.AbsoluteScriptOrder := SavedOrderLock;
    if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
    if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
    begin
      StarMapScreen.ClearPathOverlay(True);
      StarMapScreen.BuildShipPathOverlay(Ship, False, '');
    end;
  end;
end;
{ @end $622D04 }

{ @routine $622E48 SF_RelationToRanger }
procedure SF_RelationToRanger(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
  Relation: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script RelationToRanger');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  Ranger := TRanger(av[2].GetDword);
  if Ranger <> nil then
  begin
    if Obj is TPlanet then
    begin
      av[0].SetInt(Integer(TPlanet(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)]));
      if High(av) > 2 then
      begin
        if av[3].GetInt < 0 then Relation := 0
        else if av[3].GetInt > 100 then Relation := 100
        else Relation := av[3].GetInt;
        TPlanet(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)] := Pointer(Relation);
      end;
    end
    else if Obj is TShip then
    begin
      if (TShip(Obj).RangerRelations <> nil) and (TShip(Obj).RangerRelations.Count > 0) then
        av[0].SetInt(Integer(TShip(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)]))
      else av[0].SetInt(TShip(Obj).RelationToShip(Ranger));
      if (High(av) > 2) and (TShip(Obj).RangerRelations <> nil) and (TShip(Obj).RangerRelations.Count > 0) then
      begin
        if av[3].GetInt < 0 then Relation := 0
        else if av[3].GetInt > 100 then Relation := 100
        else Relation := av[3].GetInt;
        TShip(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)] := Pointer(Relation);
      end;
    end;
  end;
end;
{ @end $622E48 }

{ @routine $623098 SF_RelationToShip }
procedure SF_RelationToShip(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script RelationToShip');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  Ship := TShip(av[2].GetDword);
  if Ship <> nil then
  begin
    if Obj is TPlanet then av[0].SetInt(TPlanet(Obj).RelationToShip(Ship))
    else if Obj is TShip then av[0].SetInt(TShip(Obj).RelationToShip(Ship));
  end;
end;
{ @end $623098 }

{ @routine $623188 SF_StarOwner }
procedure SF_StarOwner(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarOwner');
  Star := TStar(av[1].GetDword);
  av[0].SetInt(0);
  if Star <> nil then
  begin
    av[0].SetInt(Ord(Star.ControlFaction));
    if High(av) > 1 then Star.ControlFaction := TStarFaction(av[2].GetInt);
  end;
end;
{ @end $623188 }

{ @routine $623238 SF_StarBattle }
procedure SF_StarBattle(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarBattle');
  Star := TStar(av[1].GetDword);
  av[0].SetInt(0);
  if Star <> nil then
  begin
    av[0].SetInt(Star.Battle);
  end;
end;
{ @end $623238 }

{ @routine $6232D0 SF_StarSeries }
procedure SF_StarSeries(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarSeries');
  Star := TStar(av[1].GetDword);
  av[0].SetInt(0);
  if Star <> nil then
  begin
    av[0].SetInt(Ord(Star.DominatorSeries));
    if High(av) > 1 then Star.DominatorSeries := TDominatorSeries(av[2].GetInt);
  end;
end;
{ @end $6232D0 }

{ @routine $623380 SF_StarHoles }
procedure SF_StarHoles(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Hole: THole;
  I, Wanted, Found: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarSeries');
  Star := TStar(av[1].GetDword);
  Wanted := -1;
  Found := -1;
  av[0].SetDword(0);
  if High(av) > 1 then Wanted := av[2].GetInt;
  for I := 0 to Galaxy.Holes.Count - 1 do
  begin
    Hole := THole(Galaxy.Holes[I]);
    if (Hole.Star1 = Star) or (Hole.Star2 = Star) then
    begin
      Inc(Found);
      if Found = Wanted then
      begin
        av[0].SetDword(Cardinal(Hole));
        Exit;
      end;
    end;
  end;
  if High(av) = 1 then av[0].SetInt(Found + 1);
end;
{ @end $623380 }

{ @routine $6234A0 SF_StarNearbyStars }
procedure SF_StarNearbyStars(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarNearbyStars');
  av[0].SetDword(0);
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    Index := av[2].GetInt;
    if (Index >= 0) and (Index < Galaxy.Stars.Count) then av[0].SetDword(Cardinal(Star.StarDistances[Index].Star));
  end;
end;
{ @end $6234A0 }

{ @routine $623570 SF_StarNearbyStarsDist }
procedure SF_StarNearbyStarsDist(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarNearbyStarsDist');
  av[0].SetDword(0);
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    Index := av[2].GetInt;
    if (Index >= 0) and (Index < Galaxy.Stars.Count) then av[0].SetInt(Star.StarDistances[Index].Distance);
  end;
end;
{ @end $623570 }

{ @routine $623644 SF_StarSetGraph }
procedure SF_StarSetGraph(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarSetGraph');
  Star := TStar(av[1].GetDword);
  ReleaseSpaceObject(Star.Graphic);
  RetainSpaceObject(Star.Graphic, CreateSpaceObjectByName('Star', av[2].GetString, Point(0, 0)));
  Star.SystemProcessName := 'Process.Normal';
  Star.Graphic.SetPosition(MakePointF(0, 0));
end;
{ @end $623644 }

{ @routine $623790 SF_CreatePlanet }
procedure SF_CreatePlanet(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Planet: TPlanet;
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreatePlanet');
  Star := TStar(av[1].GetDword);
  Planet := TPlanet.Create;
  Planet.InitGeneratedUninhabited(Star);
  Galaxy.Planets.Add(Planet);
  av[0].SetDword(Cardinal(Planet));
  if High(av) < 2 then Star.Planets.Add(Planet)
  else
  begin
    Planet.Orbit.Radius := av[2].GetInt;
    if TPlanet(Star.Planets.Last).Orbit.Radius < Planet.Orbit.Radius then Star.Planets.Add(Planet)
    else
      for I := 0 to Star.Planets.Count - 1 do
        if TPlanet(Star.Planets[I]).Orbit.Radius > Planet.Orbit.Radius then
        begin
          Star.Planets.Insert(I, Planet);
          Exit;
        end;
  end;
end;
{ @end $623790 }

{ @routine $6238F0 SF_PlanetSetGraph }
procedure SF_PlanetSetGraph(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  RotationInterval: Word;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlanetSetGraph');
  Planet := TPlanet(av[1].GetDword);
  if av[2].RealVType = vkString then
  begin
    Planet.GraphName := av[2].GetString;
    RotationInterval := Planet.Graphic.RotationTimerInterval;
    ReleaseSpaceObject(TObjectSE(Planet.Graphic));
    RetainSpaceObject(TObjectSE(Planet.Graphic), CreateSpaceObjectByName('Planet', Planet.GraphName, Point(0, 0)));
    Planet.Graphic.SetRotationTimerInterval(RotationInterval);
  end
  else
  begin
    Planet.SpriteTemplateIndex := av[2].GetInt;
    ReleaseSpaceObject(TObjectSE(Planet.Graphic));
    RetainSpaceObject(TObjectSE(Planet.Graphic), TPlanetSE.Create);
    PlanetSpaceTemplates[Planet.SpriteTemplateIndex].SpaceObject.CopyTo(Planet.Graphic);
    Planet.GraphName := Planet.Graphic.GraphKey;
  end;
  Planet.Graphic.SetPosition(PolarToPoint(Planet.Orbit));
  Planet.GraphicRadius := Planet.Graphic.Radius;
end;
{ @end $6238F0 }

{ @routine $623AEC SF_PlanetGetGraph }
procedure SF_PlanetGetGraph(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetGetGraph');
  Planet := TPlanet(av[1].GetDword);
  av[0].SetString(Planet.GraphName);
end;
{ @end $623AEC }

{ @routine $623B78 SF_PlanetPopulation }
procedure SF_PlanetPopulation(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetPopulation');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    av[0].SetInt(Planet.Population);
    if High(av) > 1 then Planet.Population := av[2].GetInt;
  end;
end;
{ @end $623B78 }

{ @routine $623C24 SF_PlanetOwner }
procedure SF_PlanetOwner(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetOwner');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    av[0].SetInt(Ord(Planet.OwnerId));
    if High(av) > 1 then
    begin
      Planet.OwnerId := TOwnerId(av[2].GetInt);
      Planet.UpdateOwnerFlags;
    end;
  end;
end;
{ @end $623C24 }

{ @routine $623CD4 SF_PlanetRace }
procedure SF_PlanetRace(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetRace');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    av[0].SetInt(Ord(Planet.RaceId));
    if High(av) > 1 then Planet.RaceId := TOwnerId(av[2].GetInt);
  end;
end;
{ @end $623CD4 }

{ @routine $623D78 SF_PlanetGov }
procedure SF_PlanetGov(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetGov');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    av[0].SetInt(Ord(Planet.Government));
    if High(av) > 1 then Planet.Government := TPlanetGovernment(av[2].GetInt);
  end;
end;
{ @end $623D78 }

{ @routine $623E1C SF_PlanetEco }
procedure SF_PlanetEco(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetEco');
  Planet := TPlanet(av[1].GetDword);
  if Planet <> nil then
  begin
    av[0].SetInt(Ord(Planet.Economy));
    if High(av) > 1 then Planet.Economy := TPlanetEconomy(av[2].GetInt);
  end;
end;
{ @end $623E1C }

{ @routine $623EC0 SF_PlanetTerrain }
procedure SF_PlanetTerrain(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Terrain: TPlanetTerrainKind;
  Value, I: Integer;
  Entry: PPlanetSurfaceLootEntry;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlanetTerrain');
  Planet := TPlanet(av[1].GetDword);
  Terrain := TPlanetTerrainKind(av[2].GetInt);
  case Terrain of
    ptWater: av[0].SetInt(Planet.WaterTiles);
    ptLand: av[0].SetInt(Planet.LandTiles);
    ptHill: av[0].SetInt(Planet.HillTiles);
  else raise Exception.Create('Error.Script PlanetTerrain ttype');
  end;
  if High(av) <= 2 then Exit;
  Value := av[3].GetInt;
  case Terrain of
    ptWater: Planet.WaterTiles := Value;
    ptLand: Planet.LandTiles := Value;
    ptHill: Planet.HillTiles := Value;
  end;
  if Planet.SurfaceLootEntries <> nil then
    for I := 0 to Planet.SurfaceLootEntries.Count - 1 do
    begin
      Entry := Planet.SurfaceLootEntries[I];
      if Entry.TerrainKind = Terrain then Entry.SurfaceTileIndex := Min(Entry.SurfaceTileIndex, Value);
    end;
end;
{ @end $623EC0 }

{ @routine $62409C SF_PlanetTerrainExplored }
procedure SF_PlanetTerrainExplored(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Terrain: TPlanetTerrainKind;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlanetTerrainExplored');
  Planet := TPlanet(av[1].GetDword);
  Terrain := TPlanetTerrainKind(av[2].GetInt);
  case Terrain of
    ptWater: av[0].SetInt(Planet.WaterExplored);
    ptLand: av[0].SetInt(Planet.LandExplored);
    ptHill: av[0].SetInt(Planet.HillExplored);
  else raise Exception.Create('Error.Script PlanetTerrainExplored ttype');
  end;
  if High(av) > 2 then
  begin
    case Terrain of
      ptWater: Planet.WaterExplored := av[3].GetInt;
      ptLand: Planet.LandExplored := av[3].GetInt;
      ptHill: Planet.HillExplored := av[3].GetInt;
    end;
  end;
end;
{ @end $62409C }

{ @routine $624218 SF_PlanetOrbitRadius }
procedure SF_PlanetOrbitRadius(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetOrbitRadius');
  Planet := TPlanet(av[1].GetDword);
  av[0].SetInt(Round(Planet.Orbit.Radius));
  if High(av) > 1 then Planet.Orbit.Radius := av[2].GetInt;
end;
{ @end $624218 }

{ @routine $6242CC SF_PlanetOrbitalVelocity }
procedure SF_PlanetOrbitalVelocity(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetOrbitalVelocity');
  Planet := TPlanet(av[1].GetDword);
  av[0].SetInt(Round(10 * Planet.OrbitalVelocity));
  if High(av) > 1 then Planet.OrbitalVelocity := av[2].GetInt * 0.1;
end;
{ @end $6242CC }

{ @routine $6243A0 SF_PlanetSize }
procedure SF_PlanetSize(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetSize');
  Planet := TPlanet(av[1].GetDword);
  av[0].SetInt(Planet.Radius);
  if High(av) > 1 then Planet.Radius := av[2].GetInt;
end;
{ @end $6243A0 }

{ @routine $62443C SF_PlanetCurInvention }
procedure SF_PlanetCurInvention(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetCurInvention');
  Planet := TPlanet(av[1].GetDword);
  av[0].SetInt(Ord(Planet.CurrentInvention));
  if High(av) > 1 then Planet.CurrentInvention := TPlanetInvention(av[2].GetInt);
end;
{ @end $62443C }

{ @routine $6244E4 SF_PlanetCurInventionPoints }
procedure SF_PlanetCurInventionPoints(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetCurInventionPoints');
  Planet := TPlanet(av[1].GetDword);
  av[0].SetFloat(Planet.CurrentInventionPoints);
  if High(av) > 1 then Planet.CurrentInventionPoints := av[2].GetFloat;
end;
{ @end $6244E4 }

{ @routine $624598 SF_PlanetInventionLevel }
procedure SF_PlanetInventionLevel(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index: TPlanetInvention;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlanetInventionLevel');
  Planet := TPlanet(av[1].GetDword);
  Index := TPlanetInvention(av[2].GetInt);
  av[0].SetInt(Planet.InventionLevels[Index]);
  if High(av) > 2 then Planet.InventionLevels[Index] := av[3].GetInt;
end;
{ @end $624598 }

{ @routine $62465C SF_PlanetBoostInventions }
procedure SF_PlanetBoostInventions(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Count, I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetBoostInventions');
  Planet := TPlanet(av[1].GetDword);
  if High(av) > 1 then Count := av[2].GetInt else Count := 1;
  for I := 1 to Count do Planet.AdvanceInventionProgress;
end;
{ @end $62465C }

{ @routine $62471C SF_PlanetWarriors }
procedure SF_PlanetWarriors(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetWarriors');
  Planet := TPlanet(av[1].GetDword);
  if High(av) = 1 then av[0].SetInt(Planet.Warriors.Count)
  else
  begin
    Index := av[2].GetInt;
    if (Index >= 0) and (Index < Planet.Warriors.Count) then av[0].SetDword(Cardinal(Planet.Warriors[Index]))
    else av[0].SetDword(0);
  end;
end;
{ @end $62471C }

{ @routine $624804 SF_GalaxySectors }
procedure SF_GalaxySectors(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then av[0].SetInt(Galaxy.Constellations.Count)
  else
  begin
    Index := av[1].GetInt;
    if (Index >= 0) and (Index < Galaxy.Constellations.Count) then av[0].SetDword(Cardinal(Galaxy.Constellations[Index]))
    else av[0].SetDword(0);
  end;
end;
{ @end $624804 }

{ @routine $6248A8 SF_GalaxyTechLevel }
procedure SF_GalaxyTechLevel(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Galaxy.TechLevel);
end;
{ @end $6248A8 }

{ @routine $6248EC SF_GalaxyDominatorResearchPercent }
procedure SF_GalaxyDominatorResearchPercent(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    av[0].SetFloat((Galaxy.DominatorResearch[0].Progress + Galaxy.DominatorResearch[1].Progress + Galaxy.DominatorResearch[2].Progress) / 3)
  else
  begin
    av[0].SetFloat(Galaxy.DominatorResearch[Ord(TDominatorSeries(av[1].GetInt))].Progress);
    if High(av) > 1 then Galaxy.DominatorResearch[Ord(TDominatorSeries(av[1].GetInt))].Progress := av[2].GetFloat;
  end;
end;
{ @end $6248EC }

{ @routine $6249C4 SF_GalaxyDominatorResearchMaterial }
procedure SF_GalaxyDominatorResearchMaterial(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyDominatorResearchMaterial');
  av[0].SetInt(Galaxy.DominatorResearch[Ord(TDominatorSeries(av[1].GetInt))].Material);
  if High(av) > 1 then Galaxy.DominatorResearch[Ord(TDominatorSeries(av[1].GetInt))].Material := av[2].GetInt;
end;
{ @end $6249C4 }

{ @routine $624A9C SF_GalaxyDiffLevels }
procedure SF_GalaxyDiffLevels(av: array of TVarEC; code: TCodeEC);
var
  I, Total: Integer;
begin
  if High(av) > 0 then av[0].SetInt((Galaxy.DifficultyLevels[TGalaxyDifficultyIndex(av[1].GetInt)] + 1) * 50)
  else
  begin
    Total := 0;
    for I := 0 to 7 do Inc(Total, (Galaxy.DifficultyLevels[Byte(I)] + 1) * 50);
    av[0].SetInt(Round(Total * 0.125));
  end;
end;
{ @end $624A9C }

{ @routine $624B44 SF_SectorVisible }
procedure SF_SectorVisible(av: array of TVarEC; code: TCodeEC);
var
  Sector: TConstellation;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SectorVisible');
  Sector := TConstellation(av[1].GetDword);
  if Sector <> nil then
  begin
    av[0].SetInt(Ord(Sector.Visible));
    if High(av) > 1 then Sector.Visible := av[2].GetInt <> 0;
  end;
  if (High(av) > 1) and (av[2].GetInt = 1) and (MainPiratePlanet <> nil) and
    (MainPiratePlanet.CurrentStar.Constellation = Sector) then
    for I := 0 to Galaxy.Constellations.Count - 1 do TConstellation(Galaxy.Constellations[I]).RestoreHiddenForm;
end;
{ @end $624B44 }

{ @routine $624C68 SF_HullHP }
procedure SF_HullHP(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
  Ship: TShip;
  Amount: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HullHP');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].SetInt(Hull.HullPoints);
  if High(av) > 1 then
  begin
    if av[2].RealVType = vkString then
    begin
      Amount := Round(av[2].GetInt * 0.01 * Hull.Weight);
      if Pos('UpTo', av[2].GetString) = 1 then Hull.HullPoints := Max(Hull.HullPoints, Amount)
      else if Pos('DownTo', av[2].GetString) = 1 then Hull.HullPoints := Min(Hull.HullPoints, Amount)
      else if Pos('To', av[2].GetString) = 1 then Hull.HullPoints := Amount
      else if Pos('Plus', av[2].GetString) = 1 then Hull.HullPoints := Max(Hull.HullPoints, Min(Hull.Weight, Hull.HullPoints + Amount))
      else if Pos('Minus', av[2].GetString) = 1 then Dec(Hull.HullPoints, Amount)
      else raise Exception.Create('Error.Script HullHP - unknown key ' + av[2].GetString);
    end
    else Hull.HullPoints := av[2].GetInt;
    if Obj is TShip then Ship := TShip(Obj) else Ship := TShip(Hull.OwnerShip);
    if (Ship <> nil) and Ship.IsHullDestroyed and not Ship.DestroyQueued then
    begin
      if av[0].GetInt > 0 then Ship.ScriptItemsAct(satOnDeath, nil, nil, 0);
      if (Ship.CurrentStar <> nil) and Ship.CurrentStar.RecordingTurnFilm then Ship.CurrentStar.ClearShipReferences(Obj);
    end;
  end;
end;
{ @end $624C68 }

{ @routine $6250FC SF_HullDamageSuspectibility }
procedure SF_HullDamageSuspectibility(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script HullDamageSuspectibility');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].SetInt(Round(Hull.GetFragilityFactor([TDamageKind(av[2].GetDword)]) * 100));
end;
{ @end $6250FC }

{ @routine $625268 SF_HullType }
procedure SF_HullType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HullType');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].SetInt(Hull.HullType);
  if High(av) > 1 then Hull.HullType := av[2].GetInt;
end;
{ @end $625268 }

{ @routine $62539C SF_HullSpecial }
procedure SF_HullSpecial(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HullSpecial');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].SetInt(Hull.SpecialModuleIndex - 1);
  if High(av) > 1 then Hull.SpecialModuleIndex := av[2].GetInt + 1;
end;
{ @end $62539C }

{ @routine $6254D4 SF_HullSeries }
procedure SF_HullSeries(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HullSeries');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].SetInt(Hull.HullSeries);
  if High(av) > 1 then Hull.HullSeries := av[2].GetInt;
end;
{ @end $6254D4 }

{ @routine $625608 SF_GalaxyHoles }
procedure SF_GalaxyHoles(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then av[0].SetInt(Galaxy.Holes.Count)
  else
  begin
    Index := av[1].GetInt;
    if (Index >= 0) and (Index < Galaxy.Holes.Count) then av[0].SetDword(Cardinal(Galaxy.Holes[Index]))
    else av[0].SetDword(0);
  end;
end;
{ @end $625608 }

{ @routine $6256A4 SF_HoleCreate2 }
procedure SF_HoleCreate2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
  Angle, Radius: Single;
  Star1, Star2: TStar;
  FilmObject: TEFilmObj;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script HoleCreate2');
  Star1 := TStar(av[1].GetDword);
  Star2 := TStar(av[2].GetDword);
  Hole := THole.Create;
  if High(av) < 3 then Hole.InitializeGraphic('')
  else Hole.InitializeGraphic(av[3].GetString);
  THoleSE(Hole.Graphic).SetState(1);
  Hole.CreatedTurn := Galaxy.CurrentTurn;
  Hole.HoleType := 1;
  Hole.Star1 := Star1;
  Hole.Star2 := Star2;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
  Radius := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
  Hole.Position1.X := Sin(Angle) * Radius;
  Hole.Position1.Y := Cos(Angle) * -Radius;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
  Radius := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
  Hole.Position2.X := Sin(Angle) * Radius;
  Hole.Position2.Y := Cos(Angle) * -Radius;
  Galaxy.Holes.Add(Hole);
  av[0].SetDword(Cardinal(Hole));
  if Hole.Star1.RecordingTurnFilm or Hole.Star2.RecordingTurnFilm then
  begin
    FilmObject := TEFilm(PrimaryFilm).AddObject(Hole.Id, Hole.Graphic);
    TEFilm(PrimaryFilm).SetObjectPosition(0, FilmObject, Hole.Position1);
    TEFilm(PrimaryFilm).SetHoleState(0, FilmObject, 1);
    TEFilm(PrimaryFilm).AttachObject(0, FilmObject);
  end
  else if GetPlayer.InNormalSpace and ((GetPlayer.CurrentStar = Hole.Star1) or (GetPlayer.CurrentStar = Hole.Star2)) then
    StarMapScreen.PendingHoleRefresh := Hole;
end;
{ @end $6256A4 }

{ @routine $6259B4 SF_HoleStar1 }
procedure SF_HoleStar1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleStar1');
  Hole := THole(av[1].GetDword);
  if Hole <> nil then
  begin
    av[0].SetDword(Cardinal(Hole.Star1));
    if High(av) > 1 then Hole.Star1 := TStar(av[2].GetDword);
  end;
end;
{ @end $6259B4 }

{ @routine $625A58 SF_HoleStar2 }
procedure SF_HoleStar2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleStar2');
  Hole := THole(av[1].GetDword);
  if Hole <> nil then
  begin
    av[0].SetDword(Cardinal(Hole.Star2));
    if High(av) > 1 then Hole.Star2 := TStar(av[2].GetDword);
  end;
end;
{ @end $625A58 }

{ @routine $625AFC SF_HoleX1 }
procedure SF_HoleX1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleX1');
  Hole := THole(av[1].GetDword);
  if Hole <> nil then
  begin
    av[0].SetInt(Round(Hole.Position1.X));
    if High(av) > 1 then Hole.Position1.X := av[2].GetInt;
  end;
end;
{ @end $625AFC }

{ @routine $625BA8 SF_HoleY1 }
procedure SF_HoleY1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleY1');
  Hole := THole(av[1].GetDword);
  if Hole <> nil then
  begin
    av[0].SetInt(Round(Hole.Position1.Y));
    if High(av) > 1 then Hole.Position1.Y := av[2].GetInt;
  end;
end;
{ @end $625BA8 }

{ @routine $625C54 SF_HoleX2 }
procedure SF_HoleX2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleX2');
  Hole := THole(av[1].GetDword);
  if Hole <> nil then
  begin
    av[0].SetInt(Round(Hole.Position2.X));
    if High(av) > 1 then Hole.Position2.X := av[2].GetInt;
  end;
end;
{ @end $625C54 }

{ @routine $625D00 SF_HoleY2 }
procedure SF_HoleY2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleY2');
  Hole := THole(av[1].GetDword);
  if Hole <> nil then
  begin
    av[0].SetInt(Round(Hole.Position2.Y));
    if High(av) > 1 then Hole.Position2.Y := av[2].GetInt;
  end;
end;
{ @end $625D00 }

{ @routine $625DAC SF_HoleTurnCreate }
procedure SF_HoleTurnCreate(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleTurnCreate');
  Hole := THole(av[1].GetDword);
  av[0].SetInt(0);
  if Hole <> nil then
  begin
    av[0].SetInt(Hole.CreatedTurn);
    if High(av) > 1 then Hole.CreatedTurn := av[2].GetInt;
  end;
end;
{ @end $625DAC }

{ @routine $625E60 SF_HoleMap }
procedure SF_HoleMap(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleMap');
  Hole := THole(av[1].GetDword);
  if Hole <> nil then
  begin
    av[0].SetString(Hole.ArcadeMapName);
    if High(av) > 1 then Hole.ArcadeMapName := av[2].GetString;
  end
  else av[0].SetString('');
end;
{ @end $625E60 }

{ @routine $625F4C SF_HoleGraph }
procedure SF_HoleGraph(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleGraph');
  Hole := THole(av[1].GetDword);
  if Hole <> nil then
  begin
    av[0].SetString(Hole.Graphic.GraphKey);
    if High(av) > 1 then
    begin
      if Hole.Graphic <> nil then ReleaseSpaceObject(Hole.Graphic);
      RetainSpaceObject(Hole.Graphic, CreateSpaceObjectByName('Hole', av[2].GetString, Point(0, 0)));
      Hole.Graphic.SetPosition(MakePointF(0, 0));
    end;
  end
  else av[0].SetString('');
end;
{ @end $625F4C }

{ @routine $626098 SF_StarRuins }
procedure SF_StarRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Ship: TShip;
  I, Found: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarRuins');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    Found := -1;
    if High(av) = 1 then
    begin
      for I := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[I];
        if Ship is TRuins then Inc(Found);
      end;
      av[0].SetInt(Found + 1);
      Exit;
    end;
    if av[2].RealVType = vkString then
    begin
      for I := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[I];
        if Ship is TRuins then
        begin
          if ((Ship.TypeNameOverrideKey <> '') and (Ship.TypeNameOverrideKey = av[2].GetString)) or
            ((Ship.TypeNameOverrideKey = '') and (ShipTypeNames[Ship.TypeId].Name = av[2].GetString)) then
          begin
            av[0].SetDword(Cardinal(Ship));
            Exit;
          end;
        end;
      end;
    end
    else
      for I := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[I];
        if Ship is TRuins then
        begin
          Inc(Found);
          if Found = av[2].GetInt then
          begin
            av[0].SetDword(Cardinal(Ship));
            Exit;
          end;
        end;
      end;
    av[0].SetDword(0);
  end;
end;
{ @end $626098 }

{ @routine $626300 SF_CreateQuestItem }
procedure SF_CreateQuestItem(av: array of TVarEC; code: TCodeEC);
var
  Item: TUselessItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateQuestItem');
  Item := TUselessItem.Create;
  Item.Init(av[1].GetString, dsBlazer, 0, False);
  if High(av) = 1 then Item.OwnerId := oiUninhabited
  else if av[2].GetInt >= 0 then Item.OwnerId := TOwnerId(av[2].GetInt);
  av[0].SetDword(Cardinal(Item));
end;
{ @end $626300 }

{ @routine $626408 SF_ShipTurnBeforeEndOrder }
procedure SF_ShipTurnBeforeEndOrder(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipTurnBeforeEndOrder');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(Ship.EstimateOrderTravelTurns);
end;
{ @end $626408 }

{ @routine $62649C SF_ShipOrder }
procedure SF_ShipOrder(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOrder');
  Ship := TShip(av[1].GetDword);
  if (High(av) > 1) and (av[2].RealVType = vkString) then
  begin
    if av[2].GetString = 'X' then
    begin
      av[0].SetFloat(Ship.OrderDestination.X);
      if High(av) > 2 then Ship.OrderDestination.X := av[3].GetFloat;
    end
    else if av[2].GetString = 'Y' then
    begin
      av[0].SetFloat(Ship.OrderDestination.Y);
      if High(av) > 2 then Ship.OrderDestination.Y := av[3].GetFloat;
    end
    else raise Exception.Create('Error.Script ShipOrder - unknown key ' + av[2].GetString);
  end
  else
  begin
    if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then av[0].SetInt(-1)
    else av[0].SetInt(Ord(Ship.Order));
    if High(av) > 1 then Ship.Order := TShipOrder(av[2].GetDword);
  end;
end;
{ @end $62649C }

{ @routine $626728 SF_ShipOrderData1 }
procedure SF_ShipOrderData1(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  LowWord, HighWord: Word;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOrderData1');
  Ship := TShip(av[1].GetDword);
  HighWord := Ship.OrderStateData shr 16;
  LowWord := Ship.OrderStateData and $FFFF;
  av[0].SetInt(LowWord);
  if High(av) > 1 then Ship.OrderStateData := (Integer(HighWord) shl 16) + (av[2].GetInt and $FFFF);
end;
{ @end $626728 }

{ @routine $6267F8 SF_ShipOrderData2 }
procedure SF_ShipOrderData2(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  LowWord, HighWord: Word;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOrderData2');
  Ship := TShip(av[1].GetDword);
  HighWord := Ship.OrderStateData shr 16;
  LowWord := Ship.OrderStateData and $FFFF;
  av[0].SetInt(HighWord);
  if High(av) > 1 then Ship.OrderStateData := Integer(LowWord) + ((av[2].GetInt and $FFFF) shl 16);
end;
{ @end $6267F8 }

{ @routine $6268C8 SF_ShipOrderObj }
procedure SF_ShipOrderObj(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOrderObj');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then av[0].SetDword(Cardinal(PendingPlayerFollowTarget))
    else av[0].SetDword(Cardinal(Ship.OrderTarget));
    if High(av) > 1 then
    begin
      if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then PendingPlayerFollowTarget := TShip(av[2].GetDword)
      else Ship.OrderTarget := TObject(av[2].GetDword);
    end;
  end;
end;
{ @end $6268C8 }

{ @routine $6269C4 SF_ShipDestination }
procedure SF_ShipDestination(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipDestination');
  Obj := TObject(av[1].GetDword);
  if Obj <> nil then
  begin
    if GetPlayer = Obj then
    begin
      av[0].SetDword(Cardinal(GetPlayer.QueuedTravelTarget));
      if High(av) > 1 then GetPlayer.QueuedTravelTarget := TStar(av[2].GetDword);
    end
    else if Obj is TRuins then
    begin
      if (High(av) > 1) and (av[2].RealVType = vkString) and (av[2].GetString = 'Date') then
      begin
        // Native Date query reads the target pointer at +558, while its setter writes FlyDate at +55C.
        av[0].SetInt(Integer(TRuins(Obj).FlyToStar));
        if High(av) > 2 then TRuins(Obj).FlyDate := av[3].GetInt;
      end
      else
      begin
        av[0].SetDword(Cardinal(TRuins(Obj).FlyToStar));
        if High(av) > 1 then TRuins(Obj).FlyToStar := TStar(av[2].GetDword);
        if High(av) > 2 then TRuins(Obj).FlyDate := av[3].GetInt;
      end;
    end
    else av[0].SetDword(0);
  end;
end;
{ @end $6269C4 }

{ @routine $626B9C SF_BuildRuins }
procedure SF_BuildRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Station: TRuins;
  Kind: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script BuildRuins');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    Station := nil;
    Kind := av[2].GetInt;
    if Byte(Kind) in [Ord(rstRangerCenter)..Ord(rstCustomStation)] then
    begin
      Station := TRuins.Create;
      Station.Init(TStationType(Kind), Star, '');
    end;
    av[0].SetDword(Cardinal(Station));
  end;
end;
{ @end $626B9C }

{ @routine $626C60 SF_BuildCustomRuins }
procedure SF_BuildCustomRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Station: TRuins;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script BuildCustomRuins');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    Station := TRuins.Create;
    av[0].SetDword(Cardinal(Station));
    Station.Init(rstCustomStation, Star, av[2].GetString);
    if High(av) > 2 then Station.CurrentStanding := TShipStanding(av[3].GetInt)
    else Station.CurrentStanding := ssUnaligned;
  end;
end;
{ @end $626C60 }

{ @routine $626D74 SF_RuinsChangeType }
procedure SF_RuinsChangeType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Station: TRuins;
  Kind: Integer;
  Index: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script RuinsChangeType');
  Obj := TObject(av[1].GetDword);
  if Obj is TRuins then
  begin
    Station := TRuins(Obj);
    if av[2].RealVType = vkString then
      for Index := Ord(rstRangerCenter) to Ord(rstCustomStation) do
        if av[2].GetString = ShipTypeNames[Index].Name then
        begin
          Station.TypeId := Index;
          Exit;
        end;
    Kind := av[2].GetInt;
    Index := Kind;
    if Index in [Ord(rstRangerCenter)..Ord(rstCustomStation)] then Station.TypeId := Index;
  end;
end;
{ @end $626D74 }

{ @routine $626EAC SF_ShipStanding }
procedure SF_ShipStanding(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipStanding');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    av[0].SetInt(Ord(Ship.CurrentStanding));
    if High(av) > 1 then Ship.CurrentStanding := TShipStanding(av[2].GetInt);
  end;
end;
{ @end $626EAC }

{ @routine $626F5C SF_ShipSlots }
procedure SF_ShipSlots(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipSlots');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(0);
  if Ship <> nil then
    case av[2].GetInt of
      1: av[0].SetInt(Ship.GetSlotCount(sskWeapon));
      2: av[0].SetInt(Ship.GetSlotCount(sskArtefact));
      3: av[0].SetInt(Ship.GetSlotCount(sskRadar));
      4: av[0].SetInt(Ship.GetSlotCount(sskScanner));
      5: av[0].SetInt(Ship.GetSlotCount(sskRepairRobot));
      6: av[0].SetInt(Ship.GetSlotCount(sskCargoHook));
      7: av[0].SetInt(Ship.GetSlotCount(sskDefGenerator));
      8: av[0].SetInt(Ship.GetSlotCount(sskAfterburner));
    end;
end;
{ @end $626F5C }

{ @routine $6270EC SF_MissileStar }
procedure SF_MissileStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileStar');
  av[0].SetDword(Cardinal(TMissile(av[1].GetDword).CurrentStar));
end;
{ @end $6270EC }

{ @routine $627170 SF_MissileType }
procedure SF_MissileType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileType');
  av[0].SetInt(TMissile(av[1].GetDword).ItemType);
end;
{ @end $627170 }

{ @routine $6271F4 SF_CustomMissileType }
procedure SF_CustomMissileType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomMissileType');
  av[0].SetString(TMissile(av[1].GetDword).GetWeaponInfo.ConfigName);
end;
{ @end $6271F4 }

{ @routine $627280 SF_MissileOwner }
procedure SF_MissileOwner(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileOwner');
  av[0].SetDword(Cardinal(TMissile(av[1].GetDword).OwnerShip));
  if High(av) > 1 then TMissile(av[1].GetDword).OwnerShip := TShip(av[2].GetDword);
end;
{ @end $627280 }

{ @routine $627324 SF_MissileWeaponID }
procedure SF_MissileWeaponID(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileWeaponID');
  av[0].SetDword(Cardinal(TMissile(av[1].GetDword).WeaponId));
end;
{ @end $627324 }

{ @routine $6273AC SF_MissileTarget }
procedure SF_MissileTarget(av: array of TVarEC; code: TCodeEC);
var
  Missile: TMissile;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileTarget');
  Missile := TMissile(av[1].GetDword);
  if Missile.Target <> nil then av[0].SetDword(Cardinal(Missile.Target))
  else av[0].SetDword(Cardinal(Missile.PreviousTarget));
  if High(av) > 1 then TMissile(av[1].GetDword).Target := TObject(av[2].GetDword);
end;
{ @end $6273AC }

{ @routine $627470 SF_MissileMaxDamage }
procedure SF_MissileMaxDamage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileMaxDamage');
  av[0].SetInt(TMissile(av[1].GetDword).MaxDamage);
  if High(av) > 1 then TMissile(av[1].GetDword).MaxDamage := av[2].GetInt;
end;
{ @end $627470 }

{ @routine $627518 SF_MissileMinDamage }
procedure SF_MissileMinDamage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileMinDamage');
  av[0].SetInt(TMissile(av[1].GetDword).MinDamage);
  if High(av) > 1 then TMissile(av[1].GetDword).MinDamage := av[2].GetInt;
end;
{ @end $627518 }

{ @routine $6275C0 SF_MissileLive }
procedure SF_MissileLive(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileLive');
  av[0].SetInt(TMissile(av[1].GetDword).FlightTicks);
  if High(av) > 1 then TMissile(av[1].GetDword).FlightTicks := av[2].GetInt;
end;
{ @end $6275C0 }

{ @routine $627664 SF_MissileSpeed }
procedure SF_MissileSpeed(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileSpeed');
  av[0].SetInt(Round(TMissile(av[1].GetDword).Speed));
  if High(av) > 1 then TMissile(av[1].GetDword).Speed := av[2].GetInt;
end;
{ @end $627664 }

{ @routine $627718 SF_MissileAngle }
procedure SF_MissileAngle(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileAngle');
  av[0].SetInt(Round(TMissile(av[1].GetDword).Direction));
  if High(av) > 1 then TMissile(av[1].GetDword).Direction := av[2].GetInt;
end;
{ @end $627718 }

{ @routine $6277CC SF_AsteroidMinerals }
procedure SF_AsteroidMinerals(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AsteroidMinerals');
  av[0].SetInt(TAsteroid(av[1].GetDword).MineralCount);
  if High(av) > 1 then TAsteroid(av[1].GetDword).MineralCount := av[2].GetInt;
end;
{ @end $6277CC }

{ @routine $627874 SF_AsteroidGraph }
procedure SF_AsteroidGraph(av: array of TVarEC; code: TCodeEC);
var
  Asteroid: TAsteroid;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AsteroidGraph');
  Asteroid := TAsteroid(av[1].GetDword);
  av[0].SetString(Asteroid.GraphObject.GraphKey);
  if High(av) > 1 then
  begin
    ReleaseSpaceObject(Asteroid.GraphObject);
    RetainSpaceObject(Asteroid.GraphObject, CreateSpaceObjectByName(ExtractDelimitedPartW(av[2].GetString, 0, '.'), av[2].GetString, Point(0, 0)));
  end;
end;
{ @end $627874 }

{ @routine $6279B0 SF_AsteroidRespawn }
procedure SF_AsteroidRespawn(av: array of TVarEC; code: TCodeEC);
var
  Asteroid: TAsteroid;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AsteroidRespawn');
  Asteroid := TAsteroid(av[1].GetDword);
  if Asteroid <> nil then Asteroid.Respawn;
end;
{ @end $6279B0 }

{ @routine $627A3C SF_ArrayAdd }
procedure SF_ArrayAdd(Args: array of TVarEC; Code: TCodeEC);
var
  NewValue, SourceValue: TVarEC;
begin
  if High(Args) < 2 then raise Exception.Create('Error.Script ArrayAdd');
  if Args[1].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArrayAdd - not array');
  SourceValue := Args[2].Resolve;
  NewValue := TVarEC.Create(SourceValue.RealVType);
  NewValue.AssignFrom(SourceValue, False);
  if High(Args) > 2 then NewValue.Name := Args[3].GetString;
  Args[1].GetArray.AddItem(NewValue);
  Args[0].SetInt(Args[1].GetArray.Count);
end;
{ @end $627A3C }

{ @routine $627BA4 SF_ArrayDelete }
procedure SF_ArrayDelete(Args: array of TVarEC; Code: TCodeEC);
var
  ElementIndex: Integer;
begin
  if High(Args) < 2 then raise Exception.Create('Error.Script ArrayDelete');
  if Args[1].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArrayDelete - not array');
  if Args[2].RealVType = vkString then Args[1].GetArray.DeleteByName(Args[2].GetString)
  else
  begin
    ElementIndex := Args[2].GetInt;
    if (ElementIndex >= 0) and (ElementIndex < Args[1].GetArray.Count) then Args[1].GetArray.Delete(ElementIndex);
  end;
  Args[0].SetInt(Args[1].GetArray.Count);
end;
{ @end $627BA4 }

{ @routine $627D1C SF_ArrayClear }
procedure SF_ArrayClear(Args: array of TVarEC; Code: TCodeEC);
begin
  if High(Args) < 1 then raise Exception.Create('Error.Script ArrayClear');
  if Args[1].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArrayClear - not array');
  Args[1].GetArray.Clear;
  { Native arrays retain one empty placeholder after this operation. }
  Args[1].GetArray.AddItem(TVarEC.Create(vkEmpty));
end;
{ @end $627D1C }

{ @routine $627E04 SF_ArrayDim }
procedure SF_ArrayDim(Args: array of TVarEC; Code: TCodeEC);
begin
  if High(Args) < 1 then raise Exception.Create('Error.Script ArrayDim');
  if Args[1].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArrayDim - not array');
  Args[0].SetInt(Args[1].GetArray.Count);
end;
{ @end $627E04 }

{ @routine $627ED4 SF_ArraySort }
procedure SF_ArraySort(Args: array of TVarEC; Code: TCodeEC);
var
  ArrayCount, ElementCount, I, ElementIndex, ArrayIndex: Integer;
  SwapValue: TVarEC;
begin
  ArrayCount := High(Args);
  if ArrayCount < 1 then raise Exception.Create('Error.Script ArraySort');
  if Args[1].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArraySort - not array');
  ElementCount := Args[1].GetArray.Count;
  if ElementCount < 2 then Exit;
  if ArrayCount > 1 then
    for I := 2 to ArrayCount do
    begin
      if Args[I].RealVType <> vkArray then
        raise Exception.Create('Error.Script ArraySort - type mismatch');
      if Args[I].GetArray.Count <> ElementCount then
        raise Exception.Create('Error.Script ArraySort - size mismatch');
    end;
  for I := 1 to ElementCount - 1 do
    for ElementIndex := ElementCount - 1 downto I do
      if Args[1].GetArray.GetItem(ElementIndex).GetInt < Args[1].GetArray.GetItem(ElementIndex - 1).GetInt then
        for ArrayIndex := 1 to ArrayCount do
        begin
          SwapValue := Args[ArrayIndex].GetArray.GetItem(ElementIndex);
          Args[ArrayIndex].GetArray.SetItem(ElementIndex, Args[ArrayIndex].GetArray.GetItem(ElementIndex - 1));
          Args[ArrayIndex].GetArray.SetItem(ElementIndex - 1, SwapValue);
        end;
end;
{ @end $627ED4 }

{ @routine $628178 SF_ArraySortPartial }
procedure SF_ArraySortPartial(Args: array of TVarEC; Code: TCodeEC);
var
  ArrayCount, ElementCount, I, ElementIndex, ArrayIndex, MinIndex: Integer;
  SwapValue: TVarEC;
begin
  ArrayCount := High(Args) - 1;
  if ArrayCount < 1 then raise Exception.Create('Error.Script ArraySortPartial');
  if Args[2].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArraySortPartial - not array');
  ElementCount := Args[2].GetArray.Count;
  MinIndex := Args[1].GetInt;
  if ElementCount < 2 then Exit;
  if ArrayCount > 1 then
    for I := 2 to ArrayCount do
    begin
      if Args[I + 1].RealVType <> vkArray then
        raise Exception.Create('Error.Script ArraySortPartial - type mismatch');
      if Args[I + 1].GetArray.Count <> ElementCount then
        raise Exception.Create('Error.Script ArraySortPartial - size mismatch');
    end;
  // Native operation: one backward adjacent-swap pass. MinIndex is unchecked;
  // each comparison also reads ElementIndex - 1.
  for ElementIndex := ElementCount - 1 downto MinIndex do
    if Args[2].GetArray.GetItem(ElementIndex).GetInt < Args[2].GetArray.GetItem(ElementIndex - 1).GetInt then
      for ArrayIndex := 1 to ArrayCount do
      begin
        SwapValue := Args[ArrayIndex + 1].GetArray.GetItem(ElementIndex);
        Args[ArrayIndex + 1].GetArray.SetItem(ElementIndex, Args[ArrayIndex + 1].GetArray.GetItem(ElementIndex - 1));
        Args[ArrayIndex + 1].GetArray.SetItem(ElementIndex - 1, SwapValue);
      end;
end;
{ @end $628178 }

{ @routine $628430 SF_ArrayRandomize }
procedure SF_ArrayRandomize(Args: array of TVarEC; Code: TCodeEC);
var
  LastArgIndex, ElementCount, I, SwapIndex1, SwapIndex2, ArrayArgIndex, SwapCount: Integer;
  Seed: Cardinal;
  SwapValue: TVarEC;
  HasSeed: Boolean;
begin
  LastArgIndex := High(Args);
  if LastArgIndex < 2 then raise Exception.Create('Error.Script ArrayRandomize');
  if Args[2].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArrayRandomize - not array');
  ElementCount := Args[2].GetArray.Count;
  if ElementCount < 2 then Exit;
  SwapCount := Args[1].GetInt;
  HasSeed := False;
  if Args[LastArgIndex].RealVType <> vkArray then
  begin
    Seed := Args[LastArgIndex].GetDword;
    HasSeed := True;
    Dec(LastArgIndex);
  end;
  for I := 3 to LastArgIndex do
  begin
    if Args[I].RealVType <> vkArray then
      raise Exception.Create('Error.Script ArrayRandomize - type mismatch');
    if Args[I].GetArray.Count <> ElementCount then
      raise Exception.Create('Error.Script ArrayRandomize - size mismatch');
  end;
  for I := 1 to SwapCount do
  begin
    if HasSeed then
    begin
      SwapIndex1 := NextRandomIntRange(0, ElementCount - 1, Seed);
      SwapIndex2 := NextRandomIntRange(0, ElementCount - 1, Seed);
    end
    else if Galaxy = nil then
    begin
      SwapIndex1 := RandomIntRange(0, ElementCount - 1);
      SwapIndex2 := RandomIntRange(0, ElementCount - 1);
    end
    else
    begin
      SwapIndex1 := NextRandomIntRange(0, ElementCount - 1, Galaxy.RandomState);
      SwapIndex2 := NextRandomIntRange(0, ElementCount - 1, Galaxy.RandomState);
    end;
    if SwapIndex1 <> SwapIndex2 then
      for ArrayArgIndex := 2 to LastArgIndex do
      begin
        SwapValue := Args[ArrayArgIndex].GetArray.GetItem(SwapIndex1);
        Args[ArrayArgIndex].GetArray.SetItem(SwapIndex1, Args[ArrayArgIndex].GetArray.GetItem(SwapIndex2));
        Args[ArrayArgIndex].GetArray.SetItem(SwapIndex2, SwapValue);
      end;
  end;
end;
{ @end $628430 }

{ @routine $62874C SF_ArrayFind }
procedure SF_ArrayFind(Args: array of TVarEC; Code: TCodeEC);
var
  ElementIndex: Integer;
begin
  if High(Args) < 2 then raise Exception.Create('Error.Script ArrayFind');
  if Args[1].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArrayFind - not array');
  Args[0].SetInt(-1);
  if Args[2].RealVType = vkInt then
  begin
    for ElementIndex := 0 to Args[1].GetArray.Count - 1 do
      if Args[1].GetArray.GetItem(ElementIndex).GetInt = Args[2].GetInt then
      begin
        Args[0].SetInt(ElementIndex);
        Exit;
      end;
  end
  else if Args[2].RealVType = vkDword then
  begin
    for ElementIndex := 0 to Args[1].GetArray.Count - 1 do
      if Args[1].GetArray.GetItem(ElementIndex).GetDword = Args[2].GetDword then
      begin
        Args[0].SetInt(ElementIndex);
        Exit;
      end;
  end
  else if Args[2].RealVType = vkString then
  begin
    for ElementIndex := 0 to Args[1].GetArray.Count - 1 do
      if Args[1].GetArray.GetItem(ElementIndex).GetString = Args[2].GetString then
      begin
        Args[0].SetInt(ElementIndex);
        Exit;
      end;
  end
  else if Args[2].RealVType = vkFloat then
  begin
    for ElementIndex := 0 to Args[1].GetArray.Count - 1 do
      if Args[1].GetArray.GetItem(ElementIndex).GetFloat = Args[2].GetFloat then
      begin
        Args[0].SetInt(ElementIndex);
        Exit;
      end;
  end;
end;
{ @end $62874C }

{ @routine $628A30 SF_ArrayFindInSorted }
procedure SF_ArrayFindInSorted(Args: array of TVarEC; Code: TCodeEC);
var
  ElementCount, TargetValue, HighValue, LowValue, HighIndex, LowIndex: Integer;
  ProbeValue, ProbeIndex, Pass, InterpolationPassCount, ScanDirection: Integer;
begin
  if High(Args) < 2 then raise Exception.Create('Error.Script ArrayFindInSorted');
  if Args[1].RealVType <> vkArray then
    raise Exception.Create('Error.Script ArrayFindInSorted - not array');
  ProbeIndex := 0;
  ElementCount := Args[1].GetArray.Count;
  TargetValue := Args[2].GetInt;
  LowIndex := 0;
  { The native search reads both endpoints without an empty-array check. }
  LowValue := Args[1].GetArray.GetItem(0).GetInt;
  HighIndex := ElementCount - 1;
  HighValue := Args[1].GetArray.GetItem(ElementCount - 1).GetInt;
  InterpolationPassCount := 3;
  if (TargetValue > HighValue) or (TargetValue < LowValue) then
  begin
    Args[0].SetInt(-1);
    Exit;
  end;
  if TargetValue = HighValue then
  begin
    Args[0].SetInt(HighIndex);
    Exit;
  end;
  if TargetValue = LowValue then
  begin
    Args[0].SetInt(LowIndex);
    Exit;
  end;
  if HighValue = LowValue then
  begin
    Args[0].SetInt(-1);
    Exit;
  end;
  for Pass := 1 to InterpolationPassCount do
  begin
    ProbeIndex := Round((TargetValue - LowValue) * (HighIndex - LowIndex) /
      (HighValue - LowValue) + LowIndex);
    ProbeValue := Args[1].GetArray.GetItem(ProbeIndex).GetInt;
    if ProbeValue > TargetValue then
    begin
      HighIndex := ProbeIndex;
      HighValue := ProbeValue;
    end
    else
    begin
      LowIndex := ProbeIndex;
      LowValue := ProbeValue;
    end;
    if TargetValue = HighValue then
    begin
      Args[0].SetInt(HighIndex);
      Exit;
    end;
    if TargetValue = LowValue then
    begin
      Args[0].SetInt(LowIndex);
      Exit;
    end;
    if HighValue = LowValue then
    begin
      Args[0].SetInt(-1);
      Exit;
    end;
  end;
  if ProbeIndex = HighIndex then ScanDirection := -1 else ScanDirection := 1;
  Inc(ProbeIndex, ScanDirection);
  ProbeValue := Args[1].GetArray.GetItem(ProbeIndex).GetInt;
  while (ProbeValue <> TargetValue) and (ProbeIndex < HighIndex) and (ProbeIndex > LowIndex) and
    ((TargetValue - ProbeValue) * ScanDirection > 0) do
  begin
    Inc(ProbeIndex, ScanDirection);
    ProbeValue := Args[1].GetArray.GetItem(ProbeIndex).GetInt;
  end;
  if ProbeValue = TargetValue then Args[0].SetInt(ProbeIndex)
  else Args[0].SetInt(-1);
end;
{ @end $628A30 }

{ @routine $628D54 SF_DistToNearestEnemySystem }
procedure SF_DistToNearestEnemySystem(av: array of TVarEC; code: TCodeEC);
var I: Integer; Star, Other: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DistToNearestEnemySystem');
  Star := TStar(av[1].GetDword);
  I := 0;
  while I < Galaxy.Stars.Count do
  begin
    Other := TObject(Star.StarDistances[I].Star) as TStar;
    if (Other.ControlFaction = sfDominators) or (Other.Status.CustomFaction <> '') then Break;
    Inc(I);
  end;
  if I = Galaxy.Stars.Count then av[0].SetInt(-1)
  else av[0].SetInt(Star.StarDistances[I].Distance);
end;
{ @end $628D54 }

{ @routine $628E64 SF_StarEnemyThreatLevel }
procedure SF_StarEnemyThreatLevel(av: array of TVarEC; code: TCodeEC);
var Star, Other: TStar; Ship: TShip; I, J: Integer; Standings: TShipStandings; IncludePirates: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarEnemyThreatLeve');
  Star := TStar(av[1].GetDword);
  IncludePirates := (High(av) > 1) and (av[2].GetInt = 1);
  if Star = nil then raise Exception.Create('Error.Script StarEnemyThreatLevel');
  if (Star.ControlFaction = sfDominators) or (Star.Status.CustomFaction <> '') or (IncludePirates and (Star.ControlFaction = sfPirates)) then
  begin
    av[0].SetInt(3);
    Exit;
  end;
  if Star.Battle <> 0 then
  begin
    av[0].SetInt(2);
    Exit;
  end;
  if Galaxy.KellerTargetStar = Star then
  begin
    av[0].SetInt(1);
    Exit;
  end;
  Standings := [ssDominator, ssCustom];
  if IncludePirates then Standings := Standings + [ssPirateActive, ssPirateMilitary];
  for J := 0 to Star.Ships.Count - 1 do
  begin
    Ship := TShip(Star.Ships[J]);
    if ((Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> oiUninhabited)) and (Ship.CurrentStanding in Standings) then
    begin
      av[0].SetInt(1);
      Exit;
    end;
  end;
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    Other := Star.StarDistances[I].Star;
    // Native code tests the original star's custom/pirate fields here.
    if (Other.ControlFaction = sfDominators) or (Star.Status.CustomFaction <> '') or (IncludePirates and (Star.ControlFaction = sfPirates)) then
      for J := 0 to Other.Ships.Count - 1 do
      begin
        Ship := TShip(Other.Ships[J]);
        if (Ship.OrderTarget = Star) and (Ship.CurrentStanding in Standings) then
        begin
          av[0].SetInt(1);
          Exit;
        end;
        if (Ship is TRuins) and (TRuins(Ship).FlyToStar = Star) and (Ship.CurrentStanding in Standings) then
        begin
          av[0].SetInt(1);
          Exit;
        end;
      end;
  end;
  av[0].SetInt(0);
end;
{ @end $628E64 }

{ @routine $629190 SF_BuildListOfQuestPossibleLocations }
procedure SF_BuildListOfQuestPossibleLocations(av: array of TVarEC; code: TCodeEC);
var I, J, K, MinDistance, MaxDistance, Count: Integer; Star, Candidate: TStar; Allowed: Boolean; Value: TVarEC;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script BuildListOfQuestPossibleLocations');
  if av[1].RealVType = vkEmpty then
  begin
    av[1].ConvertToKind(vkArray);
    av[1].SetArray(TVarArrayEC.Create);
  end
  else if av[1].RealVType <> vkArray then raise Exception.Create('Error.Script BuildListOfQuestPossibleLocations - not array');
  Star := TStar(av[2].GetDword);
  MinDistance := av[3].GetInt;
  MaxDistance := av[4].GetInt;
  av[1].GetArray.Clear;
  I := 1;
  while (I < Galaxy.Stars.Count) and (Star.StarDistances[I].Distance <= MaxDistance) do
  begin
    Candidate := Star.StarDistances[I].Star;
    if (Star.StarDistances[I].Distance >= MinDistance) and
      (Candidate.ControlFaction = sfCoalition) and (Candidate.Status.CustomFaction = '') and
      (Candidate.Battle = 0) and (Galaxy.KellerTargetStar <> Candidate) and Candidate.IsConstellationVisible then
    begin
      Allowed := True;
      if High(av) > 4 then
        for J := 5 to High(av) do
          if TStar(av[J].GetDword) = Candidate then Allowed := False;
      if Allowed then
      begin
        Value := TVarEC.Create(vkDword);
        Value.SetDword(Cardinal(Candidate));
        av[1].GetArray.AddItem(Value);
      end;
    end;
    Inc(I);
  end;
  Count := av[1].GetArray.Count;
  for I := Count - 1 downto 0 do
  begin
    Star := TStar(av[1].GetArray.GetItem(I).GetDword);
    J := 0;
    Allowed := True;
    while Allowed and (J < Star.Ships.Count) do
      if TShip(Star.Ships[J]).TypeId = stKling then
      begin
        Allowed := False;
        av[1].GetArray.Delete(I);
      end
      else Inc(J);
  end;
  Count := av[1].GetArray.Count;
  I := 0;
  while (I < Galaxy.Stars.Count) and (Count > 0) do
  begin
    Star := TStar(Galaxy.Stars[I]);
    if Star.ControlFaction = sfDominators then
      for J := 0 to Star.Ships.Count - 1 do
        if (TShip(Star.Ships[J]).TypeId = stKling) and (TShip(Star.Ships[J]).OrderTarget is TStar) then
        begin
          Candidate := TShip(Star.Ships[J]).OrderTarget as TStar;
          for K := av[1].GetArray.Count - 1 downto 0 do
            if TStar(av[1].GetArray.GetItem(K).GetDword) = Candidate then
            begin
              av[1].GetArray.Delete(K);
              Count := av[1].GetArray.Count;
            end;
        end;
    Inc(I);
  end;
  Count := av[1].GetArray.Count;
  av[0].SetInt(Count);
  if Count = 0 then av[1].GetArray.AddItem(TVarEC.Create(vkEmpty));
end;
{ @end $629190 }

{ @routine $629624 SF_FindItemInShip }
procedure SF_FindItemInShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script FindItemInShip');
  Ship := TShip(av[1].GetDword);
  Obj := TObject(av[2].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].SetInt(-1);
  if Item <> nil then
  begin
    av[0].SetInt(Ship.Inventory.IndexOf(Item));
    if av[0].GetInt < 0 then av[0].SetInt(Ship.Artefacts.IndexOf(Item));
  end;
end;
{ @end $629624 }

{ @routine $629740 SF_GalaxyRangers }
procedure SF_GalaxyRangers(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then av[0].SetInt(Galaxy.Rangers.Count)
  else
  begin
    Index := av[1].GetInt;
    if (Index >= 0) and (Index < Galaxy.Rangers.Count) then av[0].SetDword(Cardinal(Galaxy.Rangers[Index]))
    else av[0].SetDword(0);
  end;
end;
{ @end $629740 }

{ @routine $6297DC SF_MakeShipEnterStar }
procedure SF_MakeShipEnterStar(av: array of TVarEC; code: TCodeEC);
var Ship: TShip; Star, Origin: TStar; State: Word; I: Integer; SavedOrderLock: Byte;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script MakeShipEnterStar');
  Ship := TShip(av[1].GetDword);
  Star := TStar(av[2].GetDword);
  Origin := TStar(av[3].GetDword);
  State := av[4].GetDword;
  if (GetPlayer = Ship) and (TemporaryShopSlots <> nil) then RestoreTemporaryShopStock;
  I := Ship.CurrentStar.Ships.IndexOf(Ship);
  if I >= 0 then Ship.CurrentStar.Ships.Delete(I);
  Ship.CurrentStar := Origin;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderJump(Star, True);
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  Star.Ships.Add(Ship);
  Ship.CurrentStar := Star;
  Ship.OrderStateData := State;
  Ship.InHyperspace := True;
  Ship.TransitOriginStar := Origin;
  Ship.MovementDirection := PointBearingDegrees(Origin.Position, Star.Position);
  if (Ship is TNormalShip) and ((Ship as TNormalShip).LastDockedPlanet = nil) then
    (Ship as TNormalShip).LastDockedPlanet := (Ship as TNormalShip).HomePlanet;
  Ship.CurrentPlanet := nil;
  Ship.DockedTo := nil;
end;
{ @end $6297DC }

{ @routine $6299B0 SF_ShipGetBad }
procedure SF_ShipGetBad(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipGetBad');
  if av[1].GetDword <> 0 then av[0].SetDword(Cardinal(TShip(av[1].GetDword).EnemyShip));
end;
{ @end $6299B0 }

{ @routine $629A40 SF_ShipAddDropItem }
procedure SF_ShipAddDropItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipAddDropItem');
  Ship := TShip(av[1].GetDword);
  Item := TItem(av[2].GetDword);
  if (Ship <> nil) and (Item <> nil) then av[0].SetInt(Ship.GuaranteedDeathDropItems.Add(Item));
end;
{ @end $629A40 }

{ @routine $629AF4 SF_BonusCount }
procedure SF_BonusCount(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(MicroModuleTemplateCount);
end;
{ @end $629AF4 }

{ @routine $629B30 SF_SeriesCount }
procedure SF_SeriesCount(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(HullSeriesCount);
end;
{ @end $629B30 }

{ @routine $629B6C SF_BonusPriority }
procedure SF_BonusPriority(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusPriority');
  if (av[1].GetInt < 0) or (av[1].GetInt >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusPriority - number out of range');
  av[0].SetInt(MicroModuleTemplates[av[1].GetInt].Priority);
end;
{ @end $629B6C }

{ @routine $629C74 SF_BonusIsSpecial }
procedure SF_BonusIsSpecial(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusIsSpecial');
  if (av[1].GetInt < 0) or (av[1].GetInt >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusIsSpecial - number out of range');
  av[0].SetInt(Ord(MicroModuleTemplates[av[1].GetInt].SpecialOnly));
end;
{ @end $629C74 }

{ @routine $629D78 SF_BonusName }
procedure SF_BonusName(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusName');
  if (av[1].GetInt < 0) or (av[1].GetInt >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusName - number out of range');
  av[0].SetString(MicroModuleTemplates[av[1].GetInt].Name);
end;
{ @end $629D78 }

{ @routine $629E74 SF_BonusNumInCfg }
procedure SF_BonusNumInCfg(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusNumInCfg');
  if av[1].GetInt = -1 then av[0].SetString('')
  else
  begin
    if (av[1].GetInt < 0) or (av[1].GetInt >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusNumInCfg - number out of range');
    av[0].SetString(MicroModuleTemplates[av[1].GetInt].ConfigName);
  end;
end;
{ @end $629E74 }

{ @routine $629F98 SF_SeriesNumInCfg }
procedure SF_SeriesNumInCfg(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SeriesNumInCfg');
  if av[1].GetInt = -1 then av[0].SetString('')
  else
  begin
    if (av[1].GetInt < 0) or (av[1].GetInt >= HullSeriesCount) then raise Exception.Create('Error.Script SeriesNumInCfg - number out of range');
    av[0].SetString(HullSeriesDefinitions[av[1].GetInt].SystemName);
  end;
end;
{ @end $629F98 }

{ @routine $62A0BC SF_BonusValue }
procedure SF_BonusValue(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then raise Exception.Create('Error.Script BonusValue');
  if (av[1].GetInt < 0) or (av[1].GetInt >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusValue - number out of range');
  av[0].SetInt(MicroModuleTemplates[av[1].GetInt].StatBonuses[TEquipmentBonusKind(av[2].GetInt)]);
end;
{ @end $62A0BC }

{ @routine $62A1CC SF_FindBonusByName }
procedure SF_FindBonusByName(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindBonusByName');
  av[0].SetInt(-1);
  for Index := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[Index].Name = av[1].GetString then
    begin
      av[0].SetInt(Index);
      Break;
    end;
end;
{ @end $62A1CC }

{ @routine $62A2D4 SF_FindSeriesByName }
procedure SF_FindSeriesByName(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindSeriesByName');
  av[0].SetInt(-1);
  for Index := 0 to High(HullSeriesDefinitions) do
    if HullSeriesDefinitions[Index].Name = av[1].GetString then
    begin
      av[0].SetInt(Index);
      Break;
    end;
end;
{ @end $62A2D4 }

{ @routine $62A3E0 SF_FindBonusByCustomTag }
procedure SF_FindBonusByCustomTag(av: array of TVarEC; code: TCodeEC);
var
  Index, Occurrence: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindBonusByCustomTag');
  av[0].SetInt(-1);
  Occurrence := 0;
  if High(av) > 1 then Occurrence := av[2].GetInt;
  for Index := 0 to MicroModuleTemplateCount - 1 do
    if MicroModuleTemplates[Index].CustomTag = av[1].GetString then
    begin
      if Occurrence = 0 then
      begin
        av[0].SetInt(Index);
        Break;
      end;
      Dec(Occurrence);
    end;
end;
{ @end $62A3E0 }

{ @routine $62A50C SF_FindBonusByNameInCfg }
procedure SF_FindBonusByNameInCfg(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindBonusByNameInCfg');
  av[0].SetInt(-1);
  for Index := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[Index].ConfigName = av[1].GetString then
    begin
      av[0].SetInt(Index);
      Break;
    end;
end;
{ @end $62A50C }

{ @routine $62A618 SF_BonusCustomTag }
procedure SF_BonusCustomTag(av: array of TVarEC; code: TCodeEC);
var
  Block: TBlockParEC;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusCustomTag');
  Block := LanguageDataConfig.GetBlockByPath('MicroModuls.' + MicroModuleTemplates[av[1].GetInt].ConfigName);
  if Block.CountParams('CustomTag') <= 0 then av[0].SetString('')
  else av[0].SetString(Block.GetParamByPath('CustomTag'));
end;
{ @end $62A618 }

{ @routine $62A76C SF_CreateEquipmentWithSpecial }
procedure SF_CreateEquipmentWithSpecial(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Kind: Byte;
  Mask: TItemTypeMask;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateEquipmentWithSpecial');
  if not MicroModuleTemplates[av[1].GetInt].SpecialOnly then raise Exception.Create('Error.Script CreateEquipmentWithSpecial - not special');
  Mask := MicroModuleTemplates[av[1].GetInt].AllowedItemTypes;
  Kind := PickRandomItemTypeFromSeed(Mask, Galaxy.RandomState);
  if High(av) > 3 then Item := CreateGeneratedEquipment(TItemType(Kind), av[2].GetInt, av[3].GetInt, TOwnerId(av[4].GetInt))
  else Item := TEquipment(CreateDefaultItemByType(TItemType(Kind)));
  ApplySpecialMicroModule(av[1].GetInt, Item);
  av[0].SetDword(Cardinal(Item));
end;
{ @end $62A76C }

{ @routine $62A904 SF_SpecialToEquipment }
procedure SF_SpecialToEquipment(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  RawItem: TItem;
  Item: TEquipment;
  Level, PriorityLimit, Chosen, Count, MinimumPriority, BestPriority, Index: Integer;
  Template: PMicroModuleTemplate;
  RandomMode, IsHull, IsWeapon, IsOther: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SpecialToEquipment');
  RandomMode := (High(av) = 1) or ((av[1].RealVType = vkDword) and (av[1].GetDword > $FFFF));
  if RandomMode then Obj := TObject(av[1].GetDword) else Obj := TObject(av[2].GetDword);
  RawItem := nil;
  if Obj is TItem then RawItem := TItem(Obj);
  if Obj is TScriptItem then RawItem := TScriptItem(Obj).Item;
  if (RawItem <> nil) and (RawItem is TEquipment) then Item := TEquipment(RawItem)
  else raise Exception.Create('Error.Script SpecialToEquipment - not eq');
  if RandomMode then
  begin
    IsWeapon := Item is TWeapon;
    IsHull := not IsWeapon and (Item is THull);
    IsOther := not IsHull and not IsWeapon;
    if High(av) > 1 then Level := av[2].GetInt else Level := Galaxy.TechLevel;
    PriorityLimit := Round(100 * Level / 8);
    BestPriority := 0;
    Count := 0;
    Template := Pointer(MicroModuleTemplates);
    for Index := 0 to MicroModuleTemplateCount - 1 do
    begin
      if Template.SpecialOnly and ((Template.OfferStationTypes <> []) or (Template.OfferStationNames <> '<>') or Template.OnPlanets) and
        (not IsWeapon or IsBonusCompatibleWithWeapon(Index, TWeapon(Item))) and
        (not IsHull or IsBonusCompatibleWithHull(Index, THull(Item))) and
        (not IsOther or IsBonusCompatibleWithEquipment(Index, Item)) and (Template.Priority <= PriorityLimit) then
      begin
        if Count = 0 then BestPriority := Template.Priority else BestPriority := Max(BestPriority, Template.Priority);
        MicroModuleCandidateIndices[Count] := Index;
        Inc(Count);
      end;
      Template := PMicroModuleTemplate(Integer(Template) + SizeOf(TMicroModuleInfo));
    end;
    if Count <= 0 then av[0].SetInt(-1)
    else
    begin
      MinimumPriority := Max(0, BestPriority - 40);
      for Index := 0 to 100 do
      begin
        Chosen := NextRandomIntRange(0, Count - 1, Galaxy.RandomState);
        if MicroModuleTemplates[MicroModuleCandidateIndices[Chosen]].Priority >= MinimumPriority then Break;
      end;
      Item.SpecialModuleIndex := 0;
      ApplySpecialMicroModule(MicroModuleCandidateIndices[Chosen], Item);
      av[0].SetInt(MicroModuleCandidateIndices[Chosen]);
    end;
  end
  else if av[1].GetInt >= 0 then
  begin
    Item.SpecialModuleIndex := 0;
    ApplySpecialMicroModule(av[1].GetInt, Item);
  end
  else RemoveSpecialMicroModule(Item);
end;
{ @end $62A904 }

{ @routine $62AD24 SF_ModuleToEquipment }
procedure SF_ModuleToEquipment(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  RawItem: TItem;
  Item: TEquipment;
  Attempts, BasePriority, Step, Index, Level: Integer;
  RandomMode: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ModuleToEquipment');
  RandomMode := (High(av) = 1) or ((av[1].RealVType = vkDword) and (av[1].GetDword > $FFFF));
  if RandomMode then Obj := TObject(av[1].GetDword) else Obj := TObject(av[2].GetDword);
  RawItem := nil;
  if Obj is TItem then RawItem := TItem(Obj);
  if Obj is TScriptItem then RawItem := TScriptItem(Obj).Item;
  if (RawItem <> nil) and (RawItem is TEquipment) then Item := TEquipment(RawItem)
  else raise Exception.Create('Error.Script ModuleToEquipment - not eq');
  if RandomMode then
  begin
    if High(av) > 1 then Obj := TObject(av[2].GetDword) else Obj := nil;
    if High(av) > 2 then Level := av[3].GetInt else Level := Galaxy.TechLevel;
    Attempts := 0;
    Step := 0;
    repeat
      BasePriority := Round(RemapClamped(Level, 3, 7, 70, 0));
      Index := Galaxy.SelectMicroModuleForEquipment(BasePriority + 5 * Step, Min(BasePriority + 40 + 20 * Step, 100), AdvanceRandomSeed(Galaxy.RandomState), Obj, Item);
      if CanInstallMicroModule(Index, Item) then
      begin
        Item.MicroModuleIndex := 0;
        ApplyMicroModule(Index, Item);
        av[0].SetInt(Index);
        Exit;
      end;
      Inc(Attempts);
      if Attempts mod 10 = 0 then Inc(Step);
    until Attempts > 50;
    av[0].SetInt(-1);
  end
  else if av[1].GetInt >= 0 then
  begin
    Item.MicroModuleIndex := 0;
    ApplyMicroModule(av[1].GetInt, Item);
  end
  else RemoveMicroModule(Item);
end;
{ @end $62AD24 }

{ @routine $62B008 SF_EqSpecial }
procedure SF_EqSpecial(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Missile: TMissile;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EqSpecial');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TMissile then
  begin
    Missile := TMissile(Obj);
    av[0].SetInt(Missile.SpecialModuleIndex - 1);
    if High(av) > 1 then Missile.SpecialModuleIndex := av[2].GetInt + 1;
  end;
  if Obj is TEquipment then Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then Item := (Obj as TScriptItem).Item as TEquipment
  else Exit;
  av[0].SetInt(Item.SpecialModuleIndex - 1);
  if High(av) > 1 then Item.SpecialModuleIndex := av[2].GetInt + 1;
end;
{ @end $62B008 }

{ @routine $62B160 SF_EqModule }
procedure SF_EqModule(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Missile: TMissile;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EqModule');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TMissile then
  begin
    Missile := TMissile(Obj);
    av[0].SetInt(Missile.MicroModuleIndex - 1);
    if High(av) > 1 then Missile.MicroModuleIndex := av[2].GetInt + 1;
  end;
  if Obj is TEquipment then Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then Item := (Obj as TScriptItem).Item as TEquipment
  else Exit;
  av[0].SetInt(Item.MicroModuleIndex - 1);
  if High(av) > 1 then Item.MicroModuleIndex := av[2].GetInt + 1;
end;
{ @end $62B160 }

{ @routine $62B2B8 SF_MayAddBonusToEq }
procedure SF_MayAddBonusToEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script MayAddModuleToEq');
  av[0].SetInt(0);
  Index := av[1].GetInt;
  Obj := TObject(av[2].GetDword);
  if Obj is TEquipment then Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then Item := (Obj as TScriptItem).Item as TEquipment
  else Exit;
  if (Item.SpecialModuleIndex = 0) or not MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then
  begin
    if Item is TWeapon then av[0].SetInt(Ord(IsBonusCompatibleWithWeapon(Index, TWeapon(Item))))
    else if Item is THull then av[0].SetInt(Ord(IsBonusCompatibleWithHull(Index, THull(Item))))
    else av[0].SetInt(Ord(IsBonusCompatibleWithEquipment(Index, Item)));
  end;
end;
{ @end $62B2B8 }

{ @routine $62B458 SF_BuildListOfMMByPriority }
procedure SF_BuildListOfMMByPriority(av: array of TVarEC; code: TCodeEC);
var I, LowPriority, HighPriority, Count: Integer; Value: TVarEC; ExcludeRacial: Boolean;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script BuildListOfMMByPriority');
  if av[1].RealVType = vkEmpty then
  begin
    av[1].ConvertToKind(vkArray);
    av[1].SetArray(TVarArrayEC.Create);
  end
  else if av[1].RealVType <> vkArray then raise Exception.Create('Error.Script BuildListOfMMByPriority - not array');
  if High(av) > 3 then ExcludeRacial := av[4].GetInt <> 0 else ExcludeRacial := True;
  if av[2].GetInt < av[3].GetInt then
  begin
    HighPriority := av[3].GetInt;
    LowPriority := av[2].GetInt;
  end
  else
  begin
    HighPriority := av[2].GetInt;
    LowPriority := av[3].GetInt;
  end;
  av[1].GetArray.Clear;
  for I := 0 to MicroModuleTemplateCount - 1 do
    if not MicroModuleTemplates[I].SpecialOnly and
      (MicroModuleTemplates[I].Priority <= HighPriority) and
      (MicroModuleTemplates[I].Priority >= LowPriority) and
      ((Byte(ExcludeRacial) and Byte(MicroModuleTemplates[I].RacialRestriction)) = 0) then
    begin
      Value := TVarEC.Create(vkInt);
      Value.SetInt(I);
      av[1].GetArray.AddItem(Value);
    end;
  Count := av[1].GetArray.Count;
  av[0].SetInt(Count);
  if Count = 0 then av[1].GetArray.AddItem(TVarEC.Create(vkEmpty));
end;
{ @end $62B458 }

{ @routine $62B930 SF_BuildListOfNewShips }
procedure SF_BuildListOfNewShips(av: array of TVarEC; code: TCodeEC);
var MinimumId: Cardinal; Mask: TShipTypeMask; IncludeScripted: Boolean;
  FactionCount: Integer; Factions: array of WideString;
  TypeCount: Integer; CustomTypes: array of WideString; Text: WideString; Value: TVarEC;
  I, J, K, L, Count: Integer; Star: TStar; Planet: TPlanet; Ship: TShip; OwnerMask: TOwnerMask;

  // @nested $62B728 CheckShip
  procedure CheckShip(Ship: TShip); // @addr 0x62B728 @note "Requires SF_BuildListOfNewShips' live frame. The custom-type filter is applied only when the faction filter is enabled."
  var Found: Boolean; I: Integer;
  begin
    if Cardinal(Ship.Id) < MinimumId then Exit;
    if not (Ship.TypeId in Mask) then Exit;
    if ((Ship.ScriptShip <> nil) or (Ship.AbsoluteScriptOrder <> 0)) and not IncludeScripted then Exit;
    if FactionCount >= 0 then
    begin
      if Ship.ScriptShip <> nil then Text := TScriptShip(Ship.ScriptShip).StateText else Text := '';
      if (FactionCount = 0) and (Text <> '') then Exit;
      Found := FactionCount = 0;
      for I := 0 to FactionCount - 1 do
        if Text = Factions[I] then begin Found := True; Break; end;
      if not Found then Exit;
      // The native custom-type filter is nested inside the enabled faction filter.
      if TypeCount >= 0 then
      begin
        Text := Ship.TypeNameOverrideKey;
        if (TypeCount = 0) and (Text <> '') then Exit;
        Found := TypeCount = 0;
        for I := 0 to TypeCount - 1 do
          if Text = CustomTypes[I] then begin Found := True; Break; end;
        if not Found then Exit;
      end;
    end;
    Value := TVarEC.Create(vkInt);
    Value.SetDword(Cardinal(Ship));
    av[1].GetArray.AddItem(Value);
  end;

  // @nested $62B8F0 CheckItem
  procedure CheckItem(Item: TItem); // @addr 0x62B8F0 @note "Requires SF_BuildListOfNewShips' live frame. Ignores nil and non-Tranclucator artefacts."
  begin
    if Item <> nil then
      if Item is TArtefactTranclucator then
        CheckShip(TObject(TArtefactTranclucator(Item).Ship) as TShip);
  end;

begin
  if High(av) < 2 then raise Exception.Create('Error.Script BuildListOfNewShips');
  if av[1].RealVType = vkEmpty then
  begin
    av[1].ConvertToKind(vkArray);
    av[1].SetArray(TVarArrayEC.Create);
  end
  else if av[1].RealVType <> vkArray then raise Exception.Create('Error.Script BuildListOfNewShips - not array');
  av[1].GetArray.Clear;
  MinimumId := av[2].GetDword;
  if (High(av) > 2) and (av[3].GetDword <> 0) then Word(Mask) := av[3].GetDword else Mask := [stKling..stWarrior, Ord(rstRangerCenter)..Ord(rstCustomStation)];
  // Parsed by the native routine but never consulted.
  if (High(av) > 3) and (av[4].GetDword <> 0) then Byte(OwnerMask) := av[4].GetDword else OwnerMask := [oiMaloc..oiPirate];
  IncludeScripted := False;
  if (High(av) > 4) and (av[5].GetInt <> 0) then IncludeScripted := True;
  if High(av) > 5 then
  begin
    Text := av[6].GetString;
    if Text = '' then begin FactionCount := 0; Factions := nil; end
    else
    begin
      FactionCount := CountDelimitedPartsW(Text, ',');
      SetLength(Factions, FactionCount);
      for I := 0 to FactionCount - 1 do Factions[I] := ExtractDelimitedPartW(Text, I, ',');
    end;
    if High(av) > 6 then
    begin
      Text := av[7].GetString;
      if Text = '' then begin TypeCount := 0; CustomTypes := nil; end
      else
      begin
        TypeCount := CountDelimitedPartsW(Text, ',');
        SetLength(CustomTypes, TypeCount);
        for I := 0 to TypeCount - 1 do CustomTypes[I] := ExtractDelimitedPartW(Text, I, ',');
      end;
    end
    else begin CustomTypes := nil; TypeCount := -1; end;
  end
  else
  begin
    Factions := nil; FactionCount := -1;
    CustomTypes := nil; TypeCount := -1;
  end;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if Ship.TypeId <> stWarrior then CheckShip(Ship);
    end;
    if 4 in Mask then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := TPlanet(Star.Planets[J]);
        for K := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := TShip(Planet.Warriors[K]);
          CheckShip(Ship);
        end;
      end;
  end;
  if 5 in Mask then
  begin
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := TStar(Galaxy.Stars[I]);
      for J := 0 to Star.Ships.Count - 1 do
      begin
        Ship := TShip(Star.Ships[J]);
        if Ship.TypeId <> stWarrior then
          for K := 0 to Ship.Artefacts.Count - 1 do CheckItem(TItem(Ship.Artefacts[K]));
      end;
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := TPlanet(Star.Planets[J]);
        for K := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := TShip(Planet.Warriors[K]);
          for L := 0 to Ship.Artefacts.Count - 1 do CheckItem(TItem(Ship.Artefacts[L]));
        end;
      end;
      for J := 0 to Star.Items.Count - 1 do CheckItem(TItem(Star.Items[J]));
      for J := 0 to Star.MovingDropItems.Count - 1 do
        CheckItem(PMovingDropItemEntry(Star.MovingDropItems[J]).Payload as TItem);
    end;
    for I := 0 to GetPlayer.StorageEntries.Count - 1 do
      CheckItem(PStorageEntry(GetPlayer.StorageEntries[I]).Item);
  end;
  Count := av[1].GetArray.Count;
  av[0].SetInt(Count);
  if Count = 0 then av[1].GetArray.AddItem(TVarEC.Create(vkEmpty));
end;
{ @end $62B930 }

{ @routine $62C044 SF_PlanetToStar }
procedure SF_PlanetToStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetToStar');
  av[0].SetDword(Cardinal(TPlanet(av[1].GetDword).CurrentStar));
end;
{ @end $62C044 }

{ @routine $62C0C8 SF_Chameleon }
procedure SF_Chameleon(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script Chameleon');
  Ship := TShip(av[1].GetDword);
  if Ship = nil then Ship := GetPlayer;
  if (High(av) > 1) and (av[2].GetString <> '') then
  begin
    if av[2].GetString = 'GraphName' then
    begin
      av[0].SetString(Ship.GraphName);
      Exit;
    end;
    ReleaseSpaceObject(Ship.Graphic);
    RetainSpaceObject(Ship.Graphic, CreateSpaceObjectByName(ExtractDelimitedPartW(av[2].GetString, 0, '.'), av[2].GetString, Point(0, 0)));
    Ship.GraphName := av[2].GetString;
    Ship.Graphic.SetPosition(Ship.Position);
    Ship.Graphic.SetAngle(HeadingDegreesToByte(Ship.MovementDirection));
    Ship.Graphic.SetAlpha(0);
    Ship.ScriptChameleon := True;
    Ship.ChameleonActive := False;
    Ship.RefreshDerivedStats(True);
    Ship.RefreshGraphicSize;
  end
  else
  begin
    Ship.ScriptChameleon := False;
    ReleaseSpaceObject(Ship.Graphic);
    Ship.RefreshGraphic;
  end;
  if (High(av) > 2) and (av[3].GetInt <> 0) and (CurrentScreenId = screenStarMap) then
  begin
    RequestedScreenId := screenStarMap;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;
{ @end $62C0C8 }

{ @routine $62C370 SF_IsChameleon }
procedure SF_IsChameleon(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script IsChameleon');
  Ship := TShip(av[1].GetDword);
  if Ship = nil then Ship := GetPlayer;
  if Ship.ScriptChameleon then av[0].SetInt(1) else av[0].SetInt(0);
end;
{ @end $62C370 }

{ @routine $62C420 SF_PlayerChameleonCharges }
procedure SF_PlayerChameleonCharges(av: array of TVarEC; code: TCodeEC);
var Index: Byte;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlayerChameleonCharges');
  Index := av[1].GetInt;
  av[0].SetInt(GetPlayer.ChameleonCharges[Index]);
  if High(av) > 1 then GetPlayer.ChameleonCharges[Index] := av[2].GetInt;
end;
{ @end $62C420 }

{ @routine $62C4E4 SF_PlayerChameleonCurType }
procedure SF_PlayerChameleonCurType(av: array of TVarEC; code: TCodeEC);
begin
  if not GetPlayer.ChameleonActive then av[0].SetInt(-1)
  else av[0].SetInt(Ord(GetPlayer.ChameleonSeries));
  if High(av) > 0 then
    if av[1].GetInt < 0 then GetPlayer.ChameleonActive := False
    else
    begin
      GetPlayer.ChameleonActive := True;
      GetPlayer.ChameleonSeries := TDominatorSeries(av[1].GetInt);
    end;
end;
{ @end $62C4E4 }

{ @routine $62C58C SF_PlayerChameleonDetected }
procedure SF_PlayerChameleonDetected(av: array of TVarEC; code: TCodeEC);
var Index: Byte;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlayerChameleonDetected');
  Index := av[1].GetInt;
  av[0].SetInt(Ord(GetPlayer.ChameleonDetected[Index]));
  if High(av) > 1 then GetPlayer.ChameleonDetected[Index] := av[2].GetInt <> 0;
end;
{ @end $62C58C }

{ @routine $62C658 SF_PlayerLogicChameleon }
procedure SF_PlayerLogicChameleon(av: array of TVarEC; code: TCodeEC);
var Index: Byte;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlayerLogicChameleon');
  Index := av[1].GetInt;
  av[0].SetInt(GetPlayer.ChameleonLogic[Index]);
  if High(av) > 1 then GetPlayer.ChameleonLogic[Index] := av[2].GetInt;
end;
{ @end $62C658 }

{ @routine $62C71C SF_SwitchToMirrorImage }
procedure SF_SwitchToMirrorImage(av: array of TVarEC; code: TCodeEC);
var Ship: TShip; Hull: THull; Mirror: TShip2SE;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SwitchToMirrorImage');
  Ship := TShip(av[1].GetDword);
  if Ship = nil then Ship := GetPlayer;
  if Ship.ScriptChameleon and (av[2].RealVType = vkString) then
  begin
    Mirror := CreateSpaceObjectByName('Ship2', av[2].GetString, Point(0, 0)) as TShip2SE;
    Mirror.CopyDataFromMirrorImage(Ship.Graphic);
    Mirror.Free;
    Ship.GraphName := Ship.Graphic.GraphKey;
  end
  else
  begin
    Hull := Ship.GetHull;
    if Hull.HullType <> htSpecial then raise Exception.Create('Error.Script SwitchToMirrorImage: Not a special hull');
    Hull.SpecialModuleIndex := av[2].GetInt + 1;
    if not Ship.ScriptChameleon and not Ship.ChameleonActive and not Ship.GraphDominator then
    begin
      Mirror := CreateSpaceObjectByName('Ship2', 'Ship.Akrin.' + Hull.GetSpecialKindGraph, Point(0, 0)) as TShip2SE;
      Mirror.CopyDataFromMirrorImage(Ship.Graphic);
      Mirror.Free;
      Ship.GraphName := Ship.Graphic.GraphKey;
    end;
  end;
end;
{ @end $62C71C }

{ @routine $62C9C4 SF_EquipmentImageName }
procedure SF_EquipmentImageName(av: array of TVarEC; code: TCodeEC);
var Kind: Cardinal; Obj: TObject; Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EquipmentImageName');
  if (av[1].RealVType = vkString) and (av[1].GetString = 'GetImagePath') then
  begin
    if High(av) < 2 then raise Exception.Create('Error.Script EquipmentImageName 2');
    Item := TItem(av[2].GetDword);
    av[0].SetString(Item.GetBitmapResourceName);
  end
  else
  begin
    Kind := av[1].GetDword;
    if Kind < 256 then av[0].SetString(ItemTypeNames[TItemType(Kind)])
    else
    begin
      Obj := TObject(Kind);
      av[0].SetString('');
      Item := nil;
      if Obj is TItem then Item := TItem(Obj);
      if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
      if (Item <> nil) and (Item is TEquipment) then
      begin
        av[0].SetString((Item as TEquipment).ConfigBlockName);
        if High(av) > 1 then
        begin
          TEquipment(Item).ConfigBlockName := av[2].GetString;
          if Item is TEquipmentWithActCode then
          begin
            TEquipmentWithActCode(Item).ActionCode := nil;
            TEquipmentWithActCode(Item).ActCodeInitialized := False;
            if Item is TUselessItem then TUselessItem(Item).CheckIfWeDisplayAsArtefact;
            if Item is TArtefactCustom then TArtefactCustom(Item).LoadConfig(False);
          end;
        end;
      end
      else if Obj is TTranclucator then
      begin
        av[0].SetString((Obj as TTranclucator).ArtefactSystemName);
        if High(av) > 1 then (Obj as TTranclucator).ArtefactSystemName := av[2].GetString;
      end;
    end;
  end;
end;
{ @end $62C9C4 }

{ @routine $62CCCC SF_StarFonImage }
procedure SF_StarFonImage(av: array of TVarEC; code: TCodeEC);
var Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarFonImage');
  Star := TStar(av[1].GetDword);
  av[0].SetInt(Star.BackgroundImage);
  if High(av) > 1 then Star.BackgroundImage := av[2].GetInt;
end;
{ @end $62CCCC }

{ @routine $62CD6C SF_ExtremalTakeOff }
procedure SF_ExtremalTakeOff(av: array of TVarEC; code: TCodeEC);
begin
  ScriptTakeoffRequested := True;
end;
{ @end $62CD6C }

{ @routine $62CDA0 SF_ForceNextDay }
procedure SF_ForceNextDay(av: array of TVarEC; code: TCodeEC);
begin
  ScriptEndTurnRequested := True;
end;
{ @end $62CDA0 }

{ @routine $62CDD4 SF_ScriptActionsRun }
procedure SF_ScriptActionsRun(av: array of TVarEC; code: TCodeEC);
begin
  ScriptRequestThread.Execute;
end;
{ @end $62CDD4 }

{ @routine $62CE0C SF_StarListToPlanetList }
procedure SF_StarListToPlanetList(av: array of TVarEC; code: TCodeEC);
var I, J, Priority, Count, EnemyDistance: Integer; Score, Penalty: Double; Star: TStar; Planet, BestPlanet: TPlanet; Temp: TVarEC; ScorePtr: PDouble; Scores: TList; Weights: array[oiMaloc..oiGaal] of Integer;
begin
  if High(av) < 6 then raise Exception.Create('Error.Script StarListToPlanetList');
  if av[1].RealVType <> vkArray then raise Exception.Create('Error.Script StarListToPlanetList - not array');
  if (High(av) > 6) and (av[7].RealVType <> vkArray) then raise Exception.Create('Error.Script StarListToPlanetList - not array');
  Penalty := 0;
  if High(av) > 7 then Penalty := av[8].GetInt / 100;
  Weights[oiMaloc] := av[2].GetInt;
  Weights[oiPeleng] := av[3].GetInt;
  Weights[oiHuman] := av[4].GetInt;
  Weights[oiFeyan] := av[5].GetInt;
  Weights[oiGaal] := av[6].GetInt;
  Count := av[1].GetArray.Count;
  for I := Count - 1 downto 0 do
  begin
    Star := TStar(av[1].GetArray.GetItem(I).GetDword);
    Priority := 0;
    BestPlanet := nil;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[J]);
      if (Planet.OwnerId in [oiMaloc..oiGaal]) and (Weights[Planet.OwnerId] > Priority) then
      begin
        BestPlanet := Planet;
        Priority := Weights[Planet.OwnerId];
      end;
    end;
    if Priority > 0 then av[1].GetArray.GetItem(I).SetDword(Cardinal(BestPlanet))
    else av[1].GetArray.Delete(I);
  end;
  Count := av[1].GetArray.Count;
  if Count > 0 then
  begin
    Scores := TList.Create;
    for I := 0 to Count - 1 do
    begin
      Planet := TPlanet(av[1].GetArray.GetItem(I).GetDword);
      Star := Planet.CurrentStar;
      J := 0;
      while (J < Galaxy.Stars.Count) and
        ((TObject(Star.StarDistances[J].Star) as TStar).ControlFaction <> sfDominators) and
        ((TObject(Star.StarDistances[J].Star) as TStar).Status.CustomFaction = '') do Inc(J);
      if J = Galaxy.Stars.Count then EnemyDistance := 1 else EnemyDistance := Star.StarDistances[J].Distance;
      Score := EnemyDistance * Weights[Planet.OwnerId];
      if High(av) > 6 then
        for J := 0 to av[7].GetArray.Count - 1 do
          if (TStar(av[7].GetArray.GetItem(J).GetDword) = Star) or
            (av[7].GetArray.GetItem(J).GetDword = Star.Id) then Score := Score * Penalty;
      New(ScorePtr);
      ScorePtr^ := Score;
      Scores.Add(ScorePtr);
    end;
    for I := 1 to Count - 1 do
      for J := Count - 1 downto I do
        if PDouble(Scores[J])^ > PDouble(Scores[J - 1])^ then
        begin
          Temp := av[1].GetArray.GetItem(J);
          av[1].GetArray.SetItem(J, av[1].GetArray.GetItem(J - 1));
          av[1].GetArray.SetItem(J - 1, Temp);
          Score := PDouble(Scores[J])^;
          PDouble(Scores[J])^ := PDouble(Scores[J - 1])^;
          PDouble(Scores[J - 1])^ := Score;
        end;
    // The native routine leaves the allocated score cells unreleased.
    Scores.Free;
  end;
  av[0].SetInt(Count);
  if Count = 0 then av[1].GetArray.AddItem(TVarEC.Create(vkEmpty));
end;
{ @end $62CE0C }

{ @routine $62D368 SF_EndGame }
procedure SF_EndGame(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) > 0 then
  begin
    GameEndReason := av[1].GetInt;
    RequestedScreenId := screenGameEnd;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end
  else
  begin
    ScoreScreen.RecordPlayerResult(GetPlayer <> nil);
    AboutScreen.ReturnToScores := True;
    RequestedScreenId := screenAbout;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;
{ @end $62D368 }

{ @routine $62D418 SF_CustomWin }
procedure SF_CustomWin(av: array of TVarEC; code: TCodeEC);
var Event: TGalaxyEvent;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomWin');
  Event := AddGalaxyEvent('CustomWin');
  Event.AddTextData(av[1].GetString);
  if High(av) > 1 then Event.AddTextData(av[2].GetString)
  else Event.AddTextData('');
  GameEndReason := gerDefault;
  RequestedScreenId := screenGameEnd;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $62D418 }

{ @routine $62D550 SF_CustomLose }
procedure SF_CustomLose(av: array of TVarEC; code: TCodeEC);
var Event: TGalaxyEvent;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomLose');
  Event := AddGalaxyEvent('CustomLose');
  Event.AddTextData(av[1].GetString);
  if High(av) > 1 then Event.AddTextData(av[2].GetString)
  else Event.AddTextData('');
  GameEndReason := gerDefault;
  RequestedScreenId := screenGameEnd;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $62D550 }

{ @routine $62D68C SF_PirateWin }
procedure SF_PirateWin(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Galaxy.PirateWinType);
  if (High(av) > 0) and (av[1].GetInt >= 1) and (av[1].GetInt <= 5) then
  begin
    Galaxy.PirateWinTurn := Galaxy.CurrentTurn;
    Galaxy.PirateWinType := av[1].GetInt;
  end;
end;
{ @end $62D68C }

{ @routine $62D724 SF_StartVideo }
procedure SF_StartVideo(av: array of TVarEC; code: TCodeEC);
var
  Request: PScriptVDRequest;
  SavedCategory: WideString;
  Video: TxvidGI;
begin
  if High(av) = 0 then
  begin
    av[0].SetInt(QueuedVideos.Count);
    Exit;
  end;

  if High(av) < 2 then raise Exception.Create('Error.Script StartVideo');
  if GetInnermostScreenLoop = ShipScreen then
  begin
    ShipScreen.ShipLoopSound.SetVolume(0);
    Video := ShipScreen.GetByName('Film') as TxvidGI;
    Video.SetActive(True);
    if not Video.ImageOpen(av[1].GetString, False) then
    begin
      ShipScreen.StopScriptVideo;
      Exit;
    end;

    if MusicEnabled then
    begin
      MusicManager.StopImmediately;
      while MusicManager.IsPlaying do SysUtils.Sleep(1);
    end;
    if MusicEnabled then
    begin
      SavedCategory := MusicManager.CategoryOverride;
      MusicManager.CategoryOverride := '';
      MusicManager.PlayCategory(av[2].GetString);
      while not MusicManager.IsPlaying do SysUtils.Sleep(1);
      MusicManager.CategoryOverride := SavedCategory;
    end;
    ShipScreen.ScriptVideoStartedAt := timeGetTime;
    if ShipScreen.ScriptVideoTimer <> nil then
    begin
      ShipScreen.CancelCallbackTimer(ShipScreen.ScriptVideoTimer);
      ShipScreen.ScriptVideoTimer := nil;
    end;
    ShipScreen.ScriptVideoTimer := ShipScreen.ScheduleCallbackTimer(5, 5, ShipScreen.AdvanceScriptVideo);
  end
  else
  begin
    New(Request);
    Request.Video := av[1].GetString;
    Request.Soundtrack := av[2].GetString;
    Request.Script := CurrentScript;
    QueuedVideos.Add(Request);
    if CurrentScript <> nil then CurrentScript.InitCode.LocalVar.GetVar('GVideoStatus').SetInt(1);
    RequestedScreenId := CurrentScreenId;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;
{ @end $62D724 }

{ @routine $62DA84 SF_StartMusic }
procedure SF_StartMusic(av: array of TVarEC; code: TCodeEC);
var SavedCategory: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StartMusic');
  if MusicEnabled then
  begin
    if GetInnermostScreenLoop = StarMapScreen then StarMapScreen.BattleMusicSelected := True;
    MusicManager.StopImmediately;
    while MusicManager.IsPlaying do SysUtils.Sleep(1);
    if CountDelimitedPartsW(av[1].GetString, '.') > 1 then MusicManager.PlayFile(av[1].GetString)
    else
    begin
      SavedCategory := MusicManager.CategoryOverride;
      MusicManager.CategoryOverride := '';
      MusicManager.PlayCategory(av[1].GetString);
      MusicManager.CategoryOverride := SavedCategory;
    end;
  end;
end;
{ @end $62DA84 }

{ @routine $62DC14 SF_MusicControls }
procedure SF_MusicControls(av: array of TVarEC; code: TCodeEC);
var Command: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MusicControls');
  Command := av[1].GetString;
  if Command = 'SetPlayListOverride' then
  begin
    if High(av) < 2 then raise Exception.Create('Error.Script MusicControls 2');
    MusicManager.CategoryOverride := av[2].GetString;
    if MusicEnabled and (MusicManager.CategoryOverride <> '') then MusicManager.PlayCategory('');
  end
  else if Command = 'GetPlayListOverride' then av[0].SetString(MusicManager.CategoryOverride)
  else if Command = 'GetCurFile' then av[0].SetString(MusicManager.Current.GetFileName)
  else if Command = 'StopCurFile' then MusicManager.RequestFadeOut;
end;
{ @end $62DC14 }

{ @routine $62DE78 SF_NoComeKlingToStar }
procedure SF_NoComeKlingToStar(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoComeKlingToStar');
  Star := TStar(av[1].GetDword);
  if Star <> nil then
  begin
    if Star.NoComeKling then av[0].SetInt(1) else av[0].SetInt(0);
    if High(av) > 1 then Star.NoComeKling := av[2].GetInt <> 0;
  end;
end;
{ @end $62DE78 }

{ @routine $62DF44 SF_NoDropToShip }
procedure SF_NoDropToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoDropToShip');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if Ship.NoDrop then av[0].SetInt(1) else av[0].SetInt(0);
    if High(av) > 1 then Ship.NoDrop := av[2].GetInt <> 0;
  end;
end;
{ @end $62DF44 }

{ @routine $62E00C SF_NoTargetToShip }
procedure SF_NoTargetToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoTargetToShip');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    av[0].SetInt(Ship.TargetingRestriction);
    if High(av) > 1 then Ship.TargetingRestriction := av[2].GetInt;
  end;
end;
{ @end $62E00C }

{ @routine $62E0BC SF_NoTalkToShip }
procedure SF_NoTalkToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then av[0].SetInt(Ord(GetPlayer.TalkLocked))
  else if (High(av) = 1) and ((av[1].RealVType <> vkDword) or (av[1].GetDword < $FF)) then
  begin
    av[0].SetInt(Ord(GetPlayer.TalkLocked));
    GetPlayer.TalkLocked := av[1].GetInt <> 0;
  end
  else
  begin
    Ship := TShip(av[1].GetDword);
    if Ship <> nil then
    begin
      if Ship.NoTalk then av[0].SetInt(1) else av[0].SetInt(0);
      if High(av) > 1 then Ship.NoTalk := av[2].GetInt <> 0;
    end;
  end;
end;
{ @end $62E0BC }

{ @routine $62E1C0 SF_NoScanToShip }
procedure SF_NoScanToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then av[0].SetInt(Ord(GetPlayer.ScanLocked))
  else if (High(av) = 1) and ((av[1].RealVType <> vkDword) or (av[1].GetDword < $FF)) then
  begin
    av[0].SetInt(Ord(GetPlayer.ScanLocked));
    GetPlayer.ScanLocked := av[1].GetInt <> 0;
  end
  else
  begin
    Ship := TShip(av[1].GetDword);
    if Ship <> nil then
    begin
      if Ship.NoScan then av[0].SetInt(1) else av[0].SetInt(0);
      if High(av) > 1 then Ship.NoScan := av[2].GetInt <> 0;
    end;
  end;
end;
{ @end $62E1C0 }

{ @routine $62E2C4 SF_NoJump }
procedure SF_NoJump(av: array of TVarEC; code: TCodeEC);
begin
  if GetPlayer.NoJump then av[0].SetInt(1) else av[0].SetInt(0);
  if High(av) > 0 then GetPlayer.NoJump := av[1].GetInt <> 0;
end;
{ @end $62E2C4 }

{ @routine $62E33C SF_NoLanding }
procedure SF_NoLanding(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoLanding');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TPlanet then
  begin
    if (Obj as TPlanet).NoLanding then av[0].SetInt(1);
    if High(av) > 1 then (Obj as TPlanet).NoLanding := av[2].GetInt <> 0;
  end
  else if Obj is TRuins then
  begin
    if (Obj as TRuins).NoLanding then av[0].SetInt(1);
    if High(av) > 1 then (Obj as TRuins).NoLanding := av[2].GetInt <> 0;
  end;
end;
{ @end $62E33C }

{ @routine $62E488 SF_NoShopUpdate }
procedure SF_NoShopUpdate(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoShopUpdate');
  av[0].SetInt(0);
  Obj := TObject(av[1].GetDword);
  if Obj is TPlanet then
  begin
    av[0].SetInt((Obj as TPlanet).ShopUpdateMode);
    if High(av) > 1 then (Obj as TPlanet).ShopUpdateMode := av[2].GetInt;
  end
  else if Obj is TRuins then
  begin
    av[0].SetInt(Ord((Obj as TRuins).ShopUpdateMode));
    if High(av) > 1 then (Obj as TRuins).ShopUpdateMode := TShopUpdateMode(av[2].GetInt);
  end;
end;
{ @end $62E488 }

{ @routine $62E5C0 SF_PlanetExtraFlags }
procedure SF_PlanetExtraFlags(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetExtraFlags');
  av[0].SetInt(0);
  Planet := TPlanet(av[1].GetDword);
  av[0].SetInt(Ord(Planet.NoAutomaticShipSpawning) + 2 * Ord(Planet.NoRandomEvents));
  if High(av) > 1 then
  begin
    Planet.NoAutomaticShipSpawning := av[2].GetInt and 1 > 0;
    Planet.NoRandomEvents := av[2].GetInt and 2 > 0;
  end;
end;
{ @end $62E5C0 }

{ @routine $62E6AC SF_NoDropItem }
procedure SF_NoDropItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoDropItem');
  av[0].SetInt(0);
  Item := nil;
  Obj := TObject(av[1].GetDword);
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    av[0].SetInt(Item.NoDropFlag);
    if High(av) > 1 then Item.NoDropFlag := av[2].GetInt;
  end;
end;
{ @end $62E6AC }

{ @routine $62E794 SF_CanSellItem }
procedure SF_CanSellItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CanSellItem');
  av[0].SetInt(1);
  Binding := nil;
  Obj := TObject(av[1].GetDword);
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    if not Binding.CanSell then av[0].SetInt(0);
    if High(av) > 1 then Binding.CanSell := av[2].GetInt <> 0;
  end;
end;
{ @end $62E794 }

{ @routine $62E88C SF_TruceBetweenShips }
procedure SF_TruceBetweenShips(av: array of TVarEC; code: TCodeEC);
var
  Ship1, Ship2, Partner1, Partner2: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script TruceBetweenShips');
  Ship1 := TShip(av[1].GetDword);
  Ship2 := TShip(av[2].GetDword);
  if (Ship1 <> nil) and (Ship2 <> nil) then
  begin
    Partner1 := Ship1.PartnerShip;
    Partner2 := Ship2.PartnerShip;
    if (Partner1 <> nil) and (Partner2 <> nil) and
       ((Partner1.EnemyShip = Partner2) or (Partner2.EnemyShip = Partner1)) then Partner1.TruceWithShip(Partner2);
    if (Partner1 <> nil) and ((Partner1.EnemyShip = Ship2) or (Ship2.EnemyShip = Partner1)) then Partner1.TruceWithShip(Ship2);
    if (Partner2 <> nil) and ((Ship1.EnemyShip = Partner2) or (Partner2.EnemyShip = Ship1)) then Ship1.TruceWithShip(Partner2);
    Ship1.TruceWithShip(Ship2);
  end;
end;
{ @end $62E88C }

{ @routine $62E9DC SF_ShipInPrison }
procedure SF_ShipInPrison(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInPrison');
  av[0].SetInt(0);
  Ship := TShip(av[1].GetDword);
  if Ship.CurrentPlanet <> nil then
  begin
    if GetPlayer = Ship then
    begin
      if GetPlayer.InPrison then av[0].SetInt(1);
    end
    else
      case Ship.TypeId of
        stRanger:
          begin
            av[0].SetInt((Ship as TRanger).PrisonTermRemaining);
            if High(av) > 1 then (Ship as TRanger).PrisonTermRemaining := av[2].GetInt;
          end;
        stPirate:
          begin
            av[0].SetInt((Ship as TPirate).PrisonTermRemaining);
            if High(av) > 1 then (Ship as TPirate).PrisonTermRemaining := av[2].GetInt;
          end;
      end;
  end;
end;
{ @end $62E9DC }

{ @routine $62EB3C SF_ShipPartners }
procedure SF_ShipPartners(av: array of TVarEC; code: TCodeEC);
var
  Ship, Partner: TShip;
  Index, Wanted, Found: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipPartners');
  Ship := TShip(av[1].GetDword);
  Wanted := -1;
  Found := -1;
  av[0].SetDword(0);
  if High(av) > 1 then Wanted := av[2].GetInt;
  for Index := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Partner := TShip(Galaxy.Rangers[Index]);
    if Partner.PartnerShip = Ship then
    begin
      Inc(Found);
      if Found = Wanted then
      begin
        av[0].SetDword(Cardinal(Partner));
        Exit;
      end;
    end;
  end;
  if High(av) = 1 then av[0].SetInt(Found + 1);
end;
{ @end $62EB3C }

{ @routine $62EC58 SF_PlayerPirates }
procedure SF_PlayerPirates(av: array of TVarEC; code: TCodeEC);
var
  Index, Count: Integer;
begin
  if GetPlayer.PiratePartners = nil then Count := 0 else Count := GetPlayer.PiratePartners.Count;
  if High(av) < 1 then av[0].SetInt(Count)
  else
  begin
    Index := av[1].GetInt;
    if (Index < 0) or (Index >= Count) then av[0].SetDword(0)
    else av[0].SetDword(Cardinal(GetPlayer.PiratePartners[Index]));
  end;
end;
{ @end $62EC58 }

{ @routine $62ED08 SF_ShipIsPartner }
procedure SF_ShipIsPartner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipIsPartner');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
  begin
    if (High(av) > 1) and (av[2].GetInt <> 0) then av[0].SetInt(Ship.PartnershipDaysRemaining)
    else av[0].SetDword(Cardinal(Ship.PartnerShip));
  end;
end;
{ @end $62ED08 }

{ @routine $62EDC4 SF_ShipFreeSpace }
procedure SF_ShipFreeSpace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipFreeSpace');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then av[0].SetInt(Ship.CargoFreeSpace);
end;
{ @end $62EDC4 }

{ @routine $62EE58 SF_ShipWealth }
procedure SF_ShipWealth(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipWealth');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then av[0].SetInt(Ship.Wealth);
end;
{ @end $62EE58 }

{ @routine $62EEE8 SF_DomiksDefeated }
procedure SF_DomiksDefeated(av: array of TVarEC; code: TCodeEC);
var
  Kind: Byte;
begin
  if High(av) < 1 then
  begin
    if not Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron]) then av[0].SetInt(1)
    else av[0].SetInt(0);
  end
  else
  begin
    Kind := av[1].GetInt;
    case Kind of
      0:
        if Galaxy.BlazerSeriesResolvedTurn = 0 then av[0].SetInt(0)
        else if (Galaxy.BlazerLandingPlanetId <> 0) and (BlazerShip <> nil) then av[0].SetInt(3)
        else if Galaxy.BlazerSelfDestructTurn <> 0 then av[0].SetInt(2)
        else av[0].SetInt(1);
      1:
        if Galaxy.KellerSeriesResolvedTurn = 0 then av[0].SetInt(0)
        else if Galaxy.KellerLeaveTurn <> 0 then av[0].SetInt(2)
        else if Galaxy.KellerResearchTargetStarId <> 0 then av[0].SetInt(3)
        else av[0].SetInt(1);
      2:
        if Galaxy.TerronSeriesResolvedTurn = 0 then av[0].SetInt(0)
        else if Galaxy.TerronToStarTurn <> 0 then av[0].SetInt(2)
        else if Galaxy.TerronLandingLockTurn <> 0 then av[0].SetInt(3)
        else av[0].SetInt(1);
    else av[0].SetInt(0);
    end;
  end;
end;
{ @end $62EEE8 }

{ @routine $62F100 SF_CoalitionDefeated }
procedure SF_CoalitionDefeated(av: array of TVarEC; code: TCodeEC);
begin
  if Galaxy.CoalitionDefeatedTurn <> 0 then av[0].SetInt(1) else av[0].SetInt(0);
  if High(av) > 0 then
  begin
    if av[1].GetInt = 1 then Galaxy.CoalitionDefeatedTurn := Galaxy.CurrentTurn
    else Galaxy.CoalitionDefeatedTurn := 0;
  end;
end;
{ @end $62F100 }

{ @routine $62F194 SF_ShipRefuel }
procedure SF_ShipRefuel(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRefuel');
  Ship := TShip(av[1].GetDword);
  if Ship <> nil then
    if Ship.GetFuelTanks <> nil then Ship.GetFuelTanks.Fuel := Ship.GetFuelTanks.Capacity;
end;
{ @end $62F194 }

{ @routine $62F234 SF_ShipRepairEq }
procedure SF_ShipRepairEq(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Equipment: TEquipment;
  Artefact: TArtefact;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRepairEq');
  Ship := TShip(av[1].GetDword);
  for Index := Ship.Inventory.Count - 1 downto 1 do
  begin
    Equipment := TEquipment(Ship.Inventory[Index]);
    if Equipment.EquippedFlag <> 0 then Equipment.Repair;
  end;
  for Index := 0 to Ship.Artefacts.Count - 1 do
  begin
    Artefact := TArtefact(Ship.Artefacts[Index]);
    if Artefact.EquippedFlag <> 0 then Artefact.Repair;
  end;
end;
{ @end $62F234 }

{ @routine $62F338 SF_ItemInScript }
procedure SF_ItemInScript(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemInScript');
  Item := TItem(av[1].GetDword);
  if (Item <> nil) and (Item.ScriptItem <> nil) then
    av[0].SetInt(Ord(TScriptItem(Item.ScriptItem).Name = '') + 1)
  else av[0].SetInt(0);
end;
{ @end $62F338 }

{ @routine $62F480 SF_FindPlanetByAdvancement }
procedure SF_FindPlanetByAdvancement(av: array of TVarEC; code: TCodeEC);
var Score: Integer; Planet: TPlanet; MaxScore, MinScore, TargetScore, BestDistance, Percent, I, J, Faction: Integer; Star: TStar; BestPlanet: TPlanet;
  // @nested $62F3F0 CalcValue
  procedure CalcValue; // @addr 0x62F3F0 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested in SF_FindPlanetByAdvancement; reads its selected planet and writes its local score."
  var I: TPlanetInvention;
  begin
    Score := 0;
    for I := Low(TPlanetInvention) to High(TPlanetInvention) do Score := Score + Planet.InventionLevels[I];
    for I := piHull to piMainTech do Score := Score + 2 * Planet.InventionLevels[I];
    Score := Score + 8 * Planet.InventionLevels[piMainTech] + 4 * Planet.InventionLevels[piHull] + 2 * Planet.InventionLevels[piRepairRobot];
  end;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindPlanetByAdvancement');
  Faction := 0;
  if High(av) > 1 then Faction := av[2].GetInt;
  Percent := Max(Min(av[1].GetInt, 100), 0);
  MaxScore := 0;
  MinScore := 1000;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    if (Faction < 0) or ((TStarFaction(Faction) = Star.ControlFaction) and (Star.Status.CustomFaction = '')) then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := TPlanet(Star.Planets[J]);
        if Planet.OwnerId <> oiUninhabited then
        begin
          CalcValue;
          MaxScore := Max(Score, MaxScore);
          MinScore := Min(Score, MinScore);
        end;
      end;
  end;
  TargetScore := MinScore + Round(Percent * (MaxScore - MinScore) / 100);
  BestDistance := 0;
  BestPlanet := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    if (Faction < 0) or ((TStarFaction(Faction) = Star.ControlFaction) and (Star.Status.CustomFaction = '')) then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := TPlanet(Star.Planets[J]);
        if Planet.OwnerId <> oiUninhabited then
        begin
          CalcValue;
          if (BestPlanet = nil) or (Abs(Score - TargetScore) < BestDistance) then
          begin
            BestPlanet := Planet;
            BestDistance := Abs(Score - TargetScore);
          end;
        end;
      end;
  end;
  av[0].SetDword(Cardinal(BestPlanet));
end;
{ @end $62F480 }

{ @routine $62F740 SF_StarListToTransitPlanetList }
procedure SF_StarListToTransitPlanetList(av: array of TVarEC; code: TCodeEC);
var I, J, K, Unused, Count, DirectDistance, Detour, Limit, BaseDistance: Integer; Score, BestScore, Penalty: Double; Star, Origin, Destination: TStar; Planet, BestPlanet: TPlanet; Temp: TVarEC; ScorePtr: PDouble; Scores: TList; Weights: array[0..5] of Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script StarListToTransitPlanetList');
  BaseDistance := 10;
  Origin := TStar(av[2].GetDword);
  Destination := TStar(av[3].GetDword);
  Limit := BaseDistance + av[4].GetInt;
  DirectDistance := Round(PointDistance(Origin.Position, Destination.Position));
  if av[1].RealVType <> vkArray then raise Exception.Create('Error.Script StarListToTransitPlanetList - not array');
  if High(av) > 8 then
    for I := 0 to 4 do Weights[I] := av[I + 5].GetInt
  else
    for I := 0 to 4 do Weights[I] := 100;
  if (High(av) > 10) and (av[10].RealVType <> vkArray) then raise Exception.Create('Error.Script StarListToTransitPlanetList - not array2');
  Penalty := 0;
  if High(av) > 10 then Penalty := av[11].GetInt / 100;
  Scores := TList.Create;
  I := 0;
  while I < av[1].GetArray.Count do
  begin
    Star := TStar(av[1].GetArray.GetItem(I).GetDword);
    Detour := Round(PointDistance(Star.Position, Destination.Position)) + Round(PointDistance(Star.Position, Origin.Position)) - DirectDistance + BaseDistance;
    Unused := 0;
    BestPlanet := nil;
    BestScore := 0;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[J]);
      if Integer(Planet.OwnerId) < 5 then
      begin
        Score := Detour * Weights[Ord(Planet.OwnerId)] / 100;
        if High(av) > 10 then
          for K := 0 to av[10].GetArray.Count - 1 do
            if (TPlanet(av[10].GetArray.GetItem(K).GetDword) = Planet) or
              (av[10].GetArray.GetItem(K).GetDword = Planet.Id) then Score := Score * Penalty;
        if ((BestPlanet = nil) and (Limit >= Score) and (Score > 0)) or ((Score < BestScore) and (Score > 0)) then
        begin
          BestPlanet := Planet;
          BestScore := Score;
        end;
      end;
    end;
    if (Star = Origin) or (Star = Destination) or (BestPlanet = nil) then av[1].GetArray.Delete(I)
    else
    begin
      av[1].GetArray.GetItem(I).SetDword(Cardinal(BestPlanet));
      New(ScorePtr);
      ScorePtr^ := BestScore;
      Scores.Add(ScorePtr);
      Inc(I);
    end;
  end;
  Count := av[1].GetArray.Count;
  if Count > 0 then
  begin
    for I := 1 to Count - 1 do
      for J := Count - 1 downto I do
        if PDouble(Scores[J])^ < PDouble(Scores[J - 1])^ then
        begin
          Temp := av[1].GetArray.GetItem(J);
          av[1].GetArray.SetItem(J, av[1].GetArray.GetItem(J - 1));
          av[1].GetArray.SetItem(J - 1, Temp);
          Score := PDouble(Scores[J])^;
          PDouble(Scores[J])^ := PDouble(Scores[J - 1])^;
          PDouble(Scores[J - 1])^ := Score;
        end;
    // The native routine leaves the allocated score cells unreleased.
    Scores.Free;
  end;
  av[0].SetInt(Count);
  if Count = 0 then av[1].GetArray.AddItem(TVarEC.Create(vkEmpty));
end;
{ @end $62F740 }

{ @routine $62FD0C SF_GalaxyEvents }
procedure SF_GalaxyEvents(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Galaxy.GalaxyEvents.Count);
end;
{ @end $62FD0C }

{ @routine $62FD50 SF_GalaxyEventDate }
procedure SF_GalaxyEventDate(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyEventDate');
  av[0].SetInt(0);
  Index := av[1].GetInt;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
    av[0].SetInt(TGalaxyEvent(Galaxy.GalaxyEvents[Index]).Turn);
end;
{ @end $62FD50 }

{ @routine $62FE18 SF_GalaxyEventType }
procedure SF_GalaxyEventType(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyEventType');
  av[0].SetString('');
  Index := av[1].GetInt;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
    av[0].SetString(TGalaxyEvent(Galaxy.GalaxyEvents[Index]).EventType);
end;
{ @end $62FE18 }

{ @routine $62FEE0 SF_GalaxyEventData }
procedure SF_GalaxyEventData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyEventData');
  av[0].SetInt(0);
  Index := av[1].GetInt;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
  begin
    if High(av) > 1 then av[0].SetInt(TGalaxyEvent(Galaxy.GalaxyEvents[Index]).GetData(av[2].GetInt))
    else av[0].SetInt(TGalaxyEvent(Galaxy.GalaxyEvents[Index]).Data.Count);
  end;
end;
{ @end $62FEE0 }

{ @routine $62FFE8 SF_GalaxyEventsTextData }
procedure SF_GalaxyEventsTextData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyEventTextData');
  Index := av[1].GetInt;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
  begin
    if High(av) > 1 then av[0].SetString(TGalaxyEvent(Galaxy.GalaxyEvents[Index]).GetTextData(av[2].GetInt))
    else av[0].SetInt(TGalaxyEvent(Galaxy.GalaxyEvents[Index]).TextData.Count);
  end
  else av[0].SetInt(0);
end;
{ @end $62FFE8 }

{ @routine $630128 SF_PlanetNews }
procedure SF_PlanetNews(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Galaxy.PlanetNews.Count);
end;
{ @end $630128 }

{ @routine $63016C SF_PlanetNewsDate }
procedure SF_PlanetNewsDate(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetNewsDate');
  av[0].SetInt(0);
  Index := av[1].GetInt;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
    av[0].SetInt(PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Turn);
end;
{ @end $63016C }

{ @routine $630230 SF_PlanetNewsType }
procedure SF_PlanetNewsType(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetNewsType');
  av[0].SetInt(0);
  Index := av[1].GetInt;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
    av[0].SetInt(Ord(PPlanetNewsEntry(Galaxy.PlanetNews[Index]).NewsType));
end;
{ @end $630230 }

{ @routine $6302F4 SF_PlanetNewsText }
procedure SF_PlanetNewsText(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetNewsText');
  av[0].SetString('');
  Index := av[1].GetInt;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
  begin
    av[0].SetString(PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Text);
    if High(av) > 1 then PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Text := av[2].GetString;
  end;
end;
{ @end $6302F4 }

{ @routine $63041C SF_ControlledSystems }
procedure SF_ControlledSystems(av: array of TVarEC; code: TCodeEC);
var
  Index, Count: Integer;
  Faction: TStarFaction;
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ControlledSystems');
  Faction := TStarFaction(av[1].GetInt);
  Count := 0;
  for Index := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[Index]);
    if (Star.Status.CustomFaction = '') and (Star.ControlFaction = Faction) then Inc(Count);
  end;
  av[0].SetInt(Count);
end;
{ @end $63041C }

{ @routine $630504 SF_DeltaWin }
procedure SF_DeltaWin(av: array of TVarEC; code: TCodeEC);
var
  Faction: Byte;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DeltaWin');
  Faction := av[1].GetInt;
  av[0].SetInt(Galaxy.WarDeltaWin[Faction]);
  if High(av) > 1 then Galaxy.WarDeltaWin[Faction] := av[2].GetInt;
end;
{ @end $630504 }

{ @routine $6305BC SF_ShipInFear }
procedure SF_ShipInFear(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInFear');
  Ship := TShip(av[1].GetDword);
  if (Ship <> nil) and Ship.InFear then av[0].SetInt(1) else av[0].SetInt(0);
end;
{ @end $6305BC }

{ @routine $630660 SF_CreateGoods }
procedure SF_CreateGoods(av: array of TVarEC; code: TCodeEC);
var
  Item: TGoods;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CreateGoods');
  Item := TGoods.Create;
  Item.Init(TItemType(av[1].GetInt), av[2].GetInt);
  av[0].SetDword(Cardinal(Item));
  if High(av) > 2 then Item.NaturalFlag := av[3].GetInt <> 0;
end;
{ @end $630660 }

{ @routine $630724 SF_GetNodesFromShip }
procedure SF_GetNodesFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Remaining, Total: Integer;
  Item: TItem;
  Nodes: TProtoplasm;
  Series: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetNodesFromShip');
  Ship := TShip(av[1].GetDword);
  Remaining := 0;
  Total := 0;
  Series := -1;
  if High(av) > 1 then Remaining := av[2].GetInt;
  if High(av) > 2 then Series := av[3].GetInt;
  for Index := Ship.Inventory.Count - 1 downto 0 do
  begin
    Item := TItem(Ship.Inventory[Index]);
    if not (Item is TProtoplasm) then Continue;
    Nodes := Item as TProtoplasm;
    if (Series < 0) or (Ord(Nodes.DominatorSeries) = Series) then
    begin
      Inc(Total, Nodes.StackCount);
      if Remaining >= Nodes.StackCount then
      begin
        Dec(Remaining, Nodes.StackCount);
        Ship.Inventory.Delete(Index);
        Nodes.Free;
      end
      else
      begin
        Dec(Nodes.StackCount, Remaining);
        Nodes.Weight := Nodes.StackCount;
        Nodes.Cost := 10 * Nodes.StackCount;
        Remaining := 0;
      end;
    end;
  end;
  if (High(av) > 1) and (av[2].GetInt > 0) then av[0].SetInt(Remaining) else av[0].SetInt(Total);
end;
{ @end $630724 }

{ @routine $6308E0 SF_GetNodesFromStorage }
procedure SF_GetNodesFromStorage(av: array of TVarEC; code: TCodeEC);
var
  Index, Remaining, NewCount: Integer;
  Entry: PStorageEntry;
  Nodes: TProtoplasm;
  Location: TObject;
  Series: Integer;
begin
  Location := nil;
  if High(av) >= 1 then Location := TObject(av[1].GetDword);
  av[0].SetInt(0);
  Remaining := 0;
  Series := -1;
  if High(av) > 1 then Remaining := av[2].GetInt;
  if High(av) > 2 then Series := av[3].GetInt;
  Index := 0;
  while Index < GetPlayer.StorageEntries.Count do
  begin
    Entry := GetPlayer.StorageEntries[Index];
    if ((Entry.LocationOwner = Location) or (Location = nil)) and (Byte(Entry.Item.ItemType) = Byte(t_Protoplasm)) then
    begin
      Nodes := TProtoplasm(Entry.Item);
      // Native does not advance Index when the series differs.
      if not ((Series < 0) or (Ord(Nodes.DominatorSeries) = Series)) then Continue;
      av[0].SetInt(av[0].GetInt + Nodes.Weight);
      if Remaining <= 0 then begin Inc(Index); Continue; end;
      if Remaining < Nodes.StackCount then
      begin
        NewCount := Nodes.StackCount - Remaining;
        Nodes.Cost := Round(Nodes.Cost / Nodes.StackCount * NewCount);
        Nodes.StackCount := NewCount;
        Nodes.Weight := NewCount;
        Remaining := 0;
        Inc(Index);
      end
      else
      begin
        Dec(Remaining, Nodes.Weight);
        GetPlayer.StorageEntries.Delete(Index);
        Entry.Item.Free;
        Dispose(Entry);
      end;
    end
    else Inc(Index);
  end;
end;
{ @end $6308E0 }

{ @routine $630A94 SF_RangerBaseNodes }
procedure SF_RangerBaseNodes(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RangerBaseNodes');
  av[0].SetInt(TRanger(av[1].GetDword).BaseNodes);
  if High(av) > 1 then TRanger(av[1].GetDword).BaseNodes := av[2].GetInt;
end;
{ @end $630A94 }

{ @routine $630B44 SF_RuinsAllowModernization }
procedure SF_RuinsAllowModernization(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RuinsAllowModernization');
  if TRuins(av[1].GetDword).ModernizationSponsor then av[0].SetInt(1) else av[0].SetInt(0);
  if High(av) > 1 then TRuins(av[1].GetDword).ModernizationSponsor := av[2].GetInt <> 0;
end;
{ @end $630B44 }

{ @routine $630C14 SF_RuinsMicromoduleChain }
procedure SF_RuinsMicromoduleChain(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Station: TRuins;
  Kind, Index: Integer;
  InvertRarity: Boolean;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script RuinsMicromoduleChain');
  Obj := TObject(av[1].GetDword);
  if not (Obj is TRuins) then raise Exception.Create('Error.Script RuinsMicromoduleChain - not a ruins');
  Station := TRuins(Obj);
  Kind := av[2].GetInt;
  if High(av) = 2 then
  begin
    for Index := 0 to 50 do
    begin
      av[0].SetInt(Station.SelectServiceMicroModule(Kind, Index, False));
      if GetPlayer.NeedsMicroModule(av[0].GetInt + 1) then Break;
    end;
  end
  else
  begin
    Index := av[3].GetInt;
    if High(av) > 3 then InvertRarity := av[4].GetInt <> 0 else InvertRarity := False;
    av[0].SetInt(Station.SelectServiceMicroModule(Kind, Index, InvertRarity));
  end;
end;
{ @end $630C14 }

{ @routine $630DA4 SF_DomikKilledInCurSystem }
procedure SF_DomikKilledInCurSystem(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then av[0].SetInt(GetPlayer.CurrentSystemKills.Dominator)
  else av[0].SetInt(TNormalShip(av[1].GetDword).CurrentSystemKills.Dominator);
end;
{ @end $630DA4 }

{ @routine $630E08 SF_ShipTypeN }
procedure SF_ShipTypeN(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipTypeN');
  Ship := TShip(av[1].GetDword);
  av[0].SetInt(Ship.TypeId);
end;
{ @end $630E08 }

{ @routine $630E90 SF_ShipSubType }
procedure SF_ShipSubType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipSubType');
  Ship := TShip(av[1].GetDword);
  if Ship is TKling then av[0].SetInt(Ord(TKling(Ship).KlingType))
  else if Ship is TTransport then av[0].SetInt(Ord(TTransport(Ship).TransportType))
  else if Ship is TWarrior then av[0].SetInt(TWarrior(Ship).WarriorType)
  else if Ship is TPirate then av[0].SetInt(TPirate(Ship).PirateType)
  else if Ship is TRanger then av[0].SetInt(Ord(TRanger(Ship).PreferredCareer))
  else av[0].SetInt(0);
  if High(av) > 1 then
  begin
    if Ship is TKling then TKling(Ship).KlingType := TKlingType(av[2].GetInt)
    else if Ship is TTransport then TTransport(Ship).TransportType := TTransportType(av[2].GetInt)
    else if Ship is TWarrior then TWarrior(Ship).WarriorType := av[2].GetInt
    else if Ship is TPirate then TPirate(Ship).PirateType := av[2].GetInt
    else if Ship is TRanger then TRanger(Ship).PreferredCareer := TRangerCareer(av[2].GetInt);
  end;
end;
{ @end $630E90 }

{ @routine $6310BC SF_ShipChangeStar }
procedure SF_ShipChangeStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipChangeStar');
  if (TShip(av[1].GetDword) = GetPlayer) and (TemporaryShopSlots <> nil) then RestoreTemporaryShopStock;
  TShip(av[1].GetDword).TransferToStar(TStar(av[2].GetDword));
  if TShip(av[1].GetDword) = GetPlayer then
  begin
    PlayerStar := GetPlayer.CurrentStar;
    PlayerStar.RefreshMovementStepParameters;
  end;
end;
{ @end $6310BC }

{ @routine $63119C SF_IsFilm }
procedure SF_IsFilm(av: array of TVarEC; code: TCodeEC);
begin
  if StarMapScreen.Mode = smmTurnFilm then av[0].SetInt(1) else av[0].SetInt(0);
  SysUtils.Sleep(1);
end;
{ @end $63119C }

{ @routine $6311FC SF_FilmFlags }
procedure SF_FilmFlags(av: array of TVarEC; code: TCodeEC);
var Kind: Cardinal; Arg: Integer; Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FilmFlags');
  if av[1].GetDword <= 3 then
  begin
    Star := PlayerStar;
    Kind := av[1].GetDword;
    Arg := 2;
  end
  else
  begin
    if High(av) < 2 then raise Exception.Create('Error.Script FilmFlags');
    Star := TStar(av[1].GetDword);
    Kind := av[2].GetDword;
    Arg := 3;
  end;
  case Kind of
    0: av[0].SetInt(Ord(Star.RecordingTurnFilm));
    1: begin
      av[0].SetInt(Ord(Star.PlayerCombatOccurred));
      if High(av) >= Arg then Star.PlayerCombatOccurred := av[Arg].GetInt <> 0;
    end;
    2: begin
      av[0].SetInt(Ord(Star.InterruptLongTravel));
      if High(av) >= Arg then Star.InterruptLongTravel := av[Arg].GetInt <> 0;
    end;
    3: begin
      av[0].SetInt(Ord(Star.KeepFilmRunning));
      if High(av) >= Arg then Star.KeepFilmRunning := av[Arg].GetInt <> 0;
    end;
  end;
end;
{ @end $6311FC }

{ @routine $6313B8 SF_ShowEffect }
procedure SF_ShowEffect(av: array of TVarEC; code: TCodeEC);
var Effect: TWeaponSE; Entry: PEFilmEndEntry; TargetGraphic, SourceGraphic: TObjectSE; TargetFilm, SourceFilm: TEFilmObj; Name: WideString; Target, Source: TObject; Item: TItem; Damage, ShotVisual, Variant, Destruction: Integer; Destroyed, PlaySound: Boolean; Color: Cardinal; Film: TEFilmObj; Step: Integer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShowEffect');
  Name := av[1].GetString;
  ShotVisual := av[2].GetInt;
  Target := TObject(av[3].GetDword);
  Source := nil;
  if High(av) > 3 then Source := TObject(av[4].GetDword);
  Damage := 0;
  if High(av) > 4 then Damage := av[5].GetInt;
  Destroyed := False;
  if High(av) > 5 then Destroyed := av[6].GetInt <> 0;
  PlaySound := True;
  if High(av) > 6 then PlaySound := av[7].GetInt <> 0;
  if High(av) >= 10 then Color := CurrentPixelFormat.PackRgb(av[8].GetInt, av[9].GetInt, av[10].GetInt)
  else if Target is TShip then
  begin
    if GetPlayer = Target then Color := OwnerToFilmColor(RaceToOwner(GetPlayer.PilotRace))
    else if TShip(Target).HasNamedScriptFaction then Color := CustomFactionToFilmColor(TScriptShip(TShip(Target).ScriptShip).StateText)
    else Color := OwnerToFilmColor(TShip(Target).OwnerId);
  end
  else Color := 0;
  Variant := -1;
  if High(av) >= 11 then Variant := av[11].GetInt;
  Effect := TWeaponSE.Create(Name, Point(0, 0), ShotVisual, Variant);
  if (PlayerStar <> nil) and PlayerStar.RecordingTurnFilm then
  begin
    if PrimaryFilm <> nil then
    begin
      TargetFilm := nil;
      if Target is TShip then TargetFilm := TShip(Target).FilmObject
      else if Target is TPlanet then TargetFilm := TPlanet(Target).FilmObject
      else if Target is TStar then TargetFilm := PrimaryFilm.FindObject(ClassSEtoName(TStar(Target).Graphic), TStar(Target).Graphic.GraphKey, TStar(Target).Id)
      else if Target is THole then TargetFilm := TEFilmObj(THole(Target).FilmObjectId)
      else if Target is TMissile then TargetFilm := TMissile(Target).FilmObject
      else if Target is TAsteroid then TargetFilm := TAsteroid(Target).FilmObject
      else
      begin
        Item := nil;
        if Target is TItem then Item := Target as TItem
        else if Target is TScriptItem then Item := TScriptItem(Target).Item;
        if Item <> nil then TargetFilm := Item.FilmObject;
      end;
      SourceFilm := nil;
      if Source <> nil then
      begin
      if Source is TShip then SourceFilm := TShip(Source).FilmObject
      else if Source is TPlanet then SourceFilm := TPlanet(Source).FilmObject
      else if Source is TStar then SourceFilm := PrimaryFilm.FindObject(ClassSEtoName(TStar(Source).Graphic), TStar(Source).Graphic.GraphKey, TStar(Source).Id)
      else if Source is THole then SourceFilm := TEFilmObj(THole(Source).FilmObjectId)
      else if Source is TMissile then SourceFilm := TMissile(Source).FilmObject
      else if Source is TAsteroid then SourceFilm := TAsteroid(Source).FilmObject
      else
      begin
        Item := nil;
        if Source is TItem then Item := Source as TItem
        else if Source is TScriptItem then Item := TScriptItem(Source).Item;
        if Item <> nil then SourceFilm := Item.FilmObject;
      end;
      end;
      Step := PlayerStar.CurrentStepIndex;
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(Step, Film, SourceFilm, TargetFilm);
      PrimaryFilm.SetWeaponHit(Step, Film, Word(Color), Damage, Destroyed, PlaySound);
      if Destroyed and (av[6].GetInt > 1) then
      begin
        Destruction := av[6].GetInt - 1;
        PrimaryFilm.SetDestructionEffect(Step, Film, Destruction);
        if Destruction = 5 then PrimaryFilm.SetObjectAlpha(Step, TargetFilm, 0);
      end;
      PrimaryFilm.AttachObject(Step, Film);
    end;
  end
  else
  begin
      TargetGraphic := nil;
      if Target is TShip then TargetGraphic := TShip(Target).Graphic
      else if Target is TPlanet then TargetGraphic := TPlanet(Target).Graphic
      else if Target is TStar then TargetGraphic := TStar(Target).Graphic
      else if Target is THole then TargetGraphic := THole(Target).Graphic
      else if Target is TMissile then TargetGraphic := TMissile(Target).Graphic
      else if Target is TAsteroid then TargetGraphic := TAsteroid(Target).GraphObject
      else
      begin
        Item := nil;
        if Target is TItem then Item := Target as TItem
        else if Target is TScriptItem then Item := TScriptItem(Target).Item;
        if Item <> nil then TargetGraphic := Item.GetGraphObject;
      end;
    if TargetGraphic <> nil then
    begin
      SourceGraphic := nil;
      if Source <> nil then
      begin
      if Source is TShip then SourceGraphic := TShip(Source).Graphic
      else if Source is TPlanet then SourceGraphic := TPlanet(Source).Graphic
      else if Source is TStar then SourceGraphic := TStar(Source).Graphic
      else if Source is THole then SourceGraphic := THole(Source).Graphic
      else if Source is TMissile then SourceGraphic := TMissile(Source).Graphic
      else if Source is TAsteroid then SourceGraphic := TAsteroid(Source).GraphObject
      else
      begin
        Item := nil;
        if Source is TItem then Item := Source as TItem
        else if Source is TScriptItem then Item := TScriptItem(Source).Item;
        if Item <> nil then SourceGraphic := Item.GetGraphObject;
      end;
      end;
      Effect.SetEndpoints(SourceGraphic, TargetGraphic);
      Effect.SetHit(Color, Damage, Destroyed, PlaySound);
      if GetInnermostScreenLoop = StarMapScreen then
      begin
        if TrailingFilmEffects = nil then TrailingFilmEffects := TEFilmEnd.Create;
        Entry := TrailingFilmEffects.AppendEntry;
        RetainSpaceObject(Entry.SceneObject, Effect);
        RetainSpaceObject(Entry.RelatedObject1, nil);
        Entry.SceneObject.AttachToSpace(SpaceProcess.Space);
      end
      else StarMapScreen.PendingSceneObjects.Add(Effect);
    end;
  end;
end;
{ @end $6313B8 }

{ @routine $631C5C SF_ShowStaticEffect }
procedure SF_ShowStaticEffect(av: array of TVarEC; code: TCodeEC);
var X, Y: Integer; Effect: TGAIEffectSE; Name: WideString; Scale: Single; Film: TEFilmObj; Step: Integer; Entry: PEFilmEndEntry;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShowStaticEffect');
  Name := av[1].GetString;
  X := av[2].GetInt;
  Y := av[3].GetInt;
  if High(av) > 3 then Scale := av[4].GetInt * 0.01 else Scale := 1;
  if (PlayerStar <> nil) and PlayerStar.RecordingTurnFilm then
  begin
    if PrimaryFilm <> nil then
    begin
      Effect := TGAIEffectSE.Create('Effect.' + Name, Point(0, 0));
      Step := PlayerStar.CurrentStepIndex;
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetEffectImagePosition(Step, Film, Point(X, Y));
      PrimaryFilm.SetEffectDurationScale(Step, Film, Scale);
      PrimaryFilm.AttachObject(Step, Film);
    end;
  end
  else
  begin
    Effect := TGAIEffectSE.Create('Effect.' + Name, Point(0, 0));
    Effect.SetImagePosition(Point(X, Y));
    Effect.SetDurationScale(Scale);
      if GetInnermostScreenLoop = StarMapScreen then
      begin
        if TrailingFilmEffects = nil then TrailingFilmEffects := TEFilmEnd.Create;
        Entry := TrailingFilmEffects.AppendEntry;
        RetainSpaceObject(Entry.SceneObject, Effect);
        RetainSpaceObject(Entry.RelatedObject1, nil);
        Entry.SceneObject.AttachToSpace(SpaceProcess.Space);
      end
      else StarMapScreen.PendingSceneObjects.Add(Effect);
  end;
end;
{ @end $631C5C }

{ @routine $631F38 SF_ShipConnect }
procedure SF_ShipConnect(av: array of TVarEC; code: TCodeEC);
var Ship: TShip; Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipConnect');
  Ship := TShip(av[1].GetDword);
  if Ship = nil then raise Exception.Create('Error.Script ShipConnect ship=nil');
  Star := Ship.CurrentStar;
  if Star = nil then raise Exception.Create('Error.Script ShipConnect ship.FCurStar=nil');
  Ship.PrepareTurnMovement(Star.CurrentStepIndex, True);
  Ship.FilmAlpha := 0;
  if Star.MovementStepCount - 1 <= Star.CurrentStepIndex then Ship.FilmAlpha := 255
  else
  begin
    if (Star.MovementStepCount - Star.CurrentStepIndex - 1) * Ship.FilmAlphaStep < 255 then
      Ship.FilmAlphaStep := 255 / (Star.MovementStepCount - Star.CurrentStepIndex - 1);
  end;
  if Ship.MovementPath.ActiveHead <> nil then Ship.ClearMovementPath;
  Ship.BuildOrderMovementPath(Star.MovementStepCount);
end;
{ @end $631F38 }

{ @routine $632118 SF_FilmSound }
procedure SF_FilmSound(av: array of TVarEC; code: TCodeEC);
var FilmObject: TEFilmObj; Text: WideString; Obj: TObject; Item: TItem; Step: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script FilmSound');
  if (PlayerStar <> nil) and PlayerStar.RecordingTurnFilm and (PrimaryFilm <> nil) then
  begin
    Text := av[1].GetString;
    Obj := TObject(av[2].GetDword);
    FilmObject := nil;
    if Obj is TShip then FilmObject := TShip(Obj).FilmObject
    else if Obj is TPlanet then FilmObject := TPlanet(Obj).FilmObject
    else if Obj is TStar then FilmObject := PrimaryFilm.FindObject(ClassSEtoName(TStar(Obj).Graphic), TStar(Obj).Graphic.GraphKey, TStar(Obj).Id)
    else if Obj is THole then FilmObject := TEFilmObj(THole(Obj).FilmObjectId)
    else if Obj is TMissile then FilmObject := TMissile(Obj).FilmObject
    else if Obj is TAsteroid then FilmObject := TAsteroid(Obj).FilmObject
    else
    begin
      Item := nil;
      if Obj is TItem then Item := Obj as TItem
      else if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
      if Item <> nil then FilmObject := Item.FilmObject;
    end;
    Step := PlayerStar.CurrentStepIndex;
    PrimaryFilm.PlayObjectSound(Step, FilmObject, Text);
  end;
end;
{ @end $632118 }

{ @routine $63236C SF_FireWeapon }
procedure SF_FireWeapon(av: array of TVarEC; code: TCodeEC);
var Target: TObject; Ship: TShip; Weapon: TWeapon; RecordFilm: Boolean;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script FireWeapon');
  Ship := TShip(av[1].GetDword);
  Target := TObject(av[2].GetDword);
  Weapon := TWeapon(av[3].GetDword);
  RecordFilm := Ship.CurrentStar.RecordingTurnFilm;
  if Target is TMissile then Ship.FireWeaponAtMissile(Weapon, Target, RecordFilm)
  else if Target is TShip then Ship.FireWeaponAtShip(Weapon, TShip(Target), RecordFilm)
  else if Target is TItem then Ship.FireWeaponAtItem(Weapon, TItem(Target), RecordFilm)
  else if Target is TAsteroid then Ship.FireWeaponAtAsteroid(Weapon, Target, RecordFilm);
end;
{ @end $63236C }

{ @routine $6324A4 SF_WeaponHit }
procedure SF_WeaponHit(av: array of TVarEC; code: TCodeEC);
var Target: TObject; Ship: TShip; Weapon: TWeapon; Range: Integer; Color: Cardinal; Hit: Boolean; Missile: TMissile; Star: TStar; Flags: TDamageFlagSet;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script WeaponHit');
  Ship := TShip(av[1].GetDword);
  Target := TObject(av[2].GetDword);
  Weapon := TWeapon(av[3].GetDword);
  Range := -1;
  if High(av) > 3 then Range := av[4].GetInt;
  if Target is TShip then av[0].SetInt(TShip(Target).ApplyWeaponHit(Ship, Weapon, Range, Color, Flags, 1, 0))
  else if Target is TMissile then
  begin
    Missile := TMissile(Target);
    Hit := Missile.CanBeHit(Ship, Weapon);
    Hit := Ship.ScriptItemsAct(satOnWeaponShot, Missile, Weapon, Ord(Hit)) <> 0;
    if Hit then
    begin
      Star := Missile.CurrentStar;
      if Star.RecordingTurnFilm then
      begin
        PrimaryFilm.DetachObject(Star.CurrentStepIndex, Missile.FilmObject);
        Star.PendingFilmObjectRemovals.Add(Missile.FilmObject);
        ReleaseSpaceObject(Missile.Graphic);
      end;
      Missile.Free;
    end;
    av[0].SetInt(Ord(Hit));
  end;
end;
{ @end $6324A4 }

{ @routine $632650 SF_DealDamageToShip }
procedure SF_DealDamageToShip(av: array of TVarEC; code: TCodeEC);
var Source: TObject; Ship: TShip; Damage: Integer; Flags: TDamageFlagSet; Range: Integer; Color: Cardinal;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script DealDamageToShip');
  Ship := TShip(av[1].GetDword);
  Source := TObject(av[2].GetDword);
  Damage := av[3].GetInt;
  if (Source <> nil) and (Source is TItem) then av[0].SetInt(Ship.ApplyExplosionDamage(nil, Source, Damage, nil))
  else
  begin
    if High(av) > 3 then Dword(Flags) := av[4].GetDword else Flags := [dkEnergy];
    if High(av) > 4 then Range := av[5].GetInt else Range := -1;
    av[0].SetInt(Ship.ApplyDamage(Source, Damage, Range, Color, Flags));
  end;
end;
{ @end $632650 }

{ @routine $63278C SF_LaunchMissile }
procedure SF_LaunchMissile(av: array of TVarEC; code: TCodeEC);
var Target, Obj: TObject; Ship: TShip; Weapon: TWeapon; Shot: Integer; Missile: TMissile; Step: Integer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script LaunchMissile');
  Ship := TShip(av[1].GetDword);
  Target := TObject(av[2].GetDword);
  Obj := TObject(av[3].GetDword);
  if Obj is TScriptItem then Weapon := TWeapon(TScriptItem(Obj).Item) else Weapon := TWeapon(Obj);
  Shot := 0;
  if High(av) > 3 then Shot := av[4].GetInt;
  if Weapon is TCustomWeapon then
  begin
    Missile := TCustomMissile.Create;
    TCustomMissile(Missile).InitializeShot(Ship.CurrentStar, Ship, Weapon, Target, Shot);
  end
  else
  begin
    Missile := TMissile.Create;
    Missile.InitializeShot(Ship.CurrentStar, Ship, Weapon, Target, Shot);
  end;
  Ship.ScriptItemsAct(satOnMissileShot, Missile, Weapon, 0);
  av[0].SetDword(Cardinal(Missile));
  if Ship.CurrentStar.RecordingTurnFilm then
  begin
    Step := Ship.CurrentStar.CurrentStepIndex;
    Missile.PrepareTurnMovement(Step, True, True);
    PrimaryFilm.DetachObject(0, Missile.FilmObject);
  end;
end;
{ @end $63278C }

{ @routine $63292C SF_SpawnMissile }
procedure SF_SpawnMissile(av: array of TVarEC; code: TCodeEC);
var Star: TStar; Target: TObject; X, Y: Integer; Direction: Single; MinDamage, MaxDamage: Integer; Speed: Single; Kind: Byte; Module, Special: Integer; Missile: TMissile; Step: Integer;
begin
  if High(av) < 9 then raise Exception.Create('Error.Script SpawnMissile');
  Star := TStar(av[1].GetDword);
  Target := TObject(av[2].GetDword);
  X := av[3].GetInt;
  Y := av[4].GetInt;
  Direction := av[5].GetInt;
  MinDamage := av[6].GetInt;
  MaxDamage := av[7].GetInt;
  Speed := av[8].GetInt;
  if High(av) > 9 then
  begin
    Module := av[10].GetInt + 1;
    Special := av[11].GetInt + 1;
  end
  else
  begin
    Module := 0;
    Special := 0;
  end;
  if av[9].RealVType = vkString then
  begin
    Missile := TCustomMissile.Create;
    TCustomMissile(Missile).InitializeUnownedShot(Star, Target, X, Y, Direction, MinDamage, MaxDamage, Speed, av[9].GetString, Module, Special);
  end
  else
  begin
    Kind := av[9].GetInt;
    Missile := TMissile.Create;
    Missile.InitializeUnownedShot(Star, Target, X, Y, Direction, MinDamage, MaxDamage, Speed, Kind, Module, Special);
  end;
  av[0].SetDword(Cardinal(Missile));
  if Star.RecordingTurnFilm then
  begin
    Step := Star.CurrentStepIndex;
    Missile.PrepareTurnMovement(Step, True, True);
    PrimaryFilm.DetachObject(0, Missile.FilmObject);
  end;
end;
{ @end $63292C }

{ @routine $632B68 SF_BonusText }
procedure SF_BonusText(av: array of TVarEC; code: TCodeEC);
var Index, Count: Integer; Text: WideString; Bonus: TEquipmentBonusKind; Value: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusText');
  Index := av[1].GetInt;
  if (Index < 0) or (Index >= MicroModuleTemplateCount) then
  begin
    av[0].SetString('');
    Exit;
  end;

  if High(av) < 2 then
  begin
    av[0].SetString(GetMicroModuleInfoText(Index, TextHighlightColorTag));
    Exit;
  end;

  Count := av[2].GetInt;
  Text := LocalizedColorText('MicroModuls.' + MicroModuleTemplates[Index].ConfigName + '.ExText');
  if Text <> '' then
  begin
    ReplaceTextToken(Text, '<ExCount>', IntToStr(Count), TextHighlightColorTag);
    if MicroModuleTemplates[Index].SeparatedNumbers then
      for Bonus := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
      begin
        Value := Count * MicroModuleTemplates[Index].StatBonuses[Bonus];
        if Value > 0 then ReplaceTextToken(Text, '<' + EquipmentBonusNames[Bonus] + '>', '+' + IntToStr(Value), TextHighlightColorTag)
        else if Value < 0 then ReplaceTextToken(Text, '<' + EquipmentBonusNames[Bonus] + '>', IntToStr(Value), TextHighlightColorTag)
        else ReplaceTextToken(Text, '<' + EquipmentBonusNames[Bonus] + '>', '--', TextHighlightColorTag);
      end;
  end;
  av[0].SetString(WrapTextInColor(Text, GetMicroModuleTextColorTag(Index)));
end;
{ @end $632B68 }

{ @routine $632F38 SF_PlanetPirateClan }
procedure SF_PlanetPirateClan(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetDword(Cardinal(MainPiratePlanet));
end;
{ @end $632F38 }

{ @routine $632F74 SF_Blazer }
procedure SF_Blazer(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetDword(Cardinal(BlazerShip));
end;
{ @end $632F74 }

{ @routine $632FB0 SF_Keller }
procedure SF_Keller(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetDword(Cardinal(KellerShip));
end;
{ @end $632FB0 }

{ @routine $632FEC SF_Terron }
procedure SF_Terron(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetDword(Cardinal(TerronShip));
end;
{ @end $632FEC }

{ @routine $633028 SF_PirateType }
procedure SF_PirateType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PirateType');
  Ship := TShip(av[1].GetDword);
  if Ship is TPirate then av[0].SetInt(TPirate(Ship).PirateType) else av[0].SetInt(0);
end;
{ @end $633028 }

{ @routine $6330D4 SF_PlayerQuestInProgress }
procedure SF_PlayerQuestInProgress(av: array of TVarEC; code: TCodeEC);
var
  Quest: PQuest;
  Index: Integer;
  Planet: TPlanet;
begin
  if GetPlayer.Quests <> nil then
  begin
    if High(av) > 0 then Planet := TPlanet(av[1].GetDword) else Planet := nil;
    for Index := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := PQuest(GetPlayer.Quests[Index]);
      if ((Planet = nil) or (Quest.Planet = Planet)) and not Quest.Successful then
      begin
        av[0].SetInt(1);
        Exit;
      end;
    end;
  end;
  av[0].SetInt(0);
end;
{ @end $6330D4 }

{ @routine $6331A0 SF_PlayerQuestsCompleted }
procedure SF_PlayerQuestsCompleted(av: array of TVarEC; code: TCodeEC);
var
  Quest: PPlayerOldQuest;
  Index: Integer;
begin
  av[0].SetInt(0);
  if (PlayerOldQuests <> nil) and (PlayerOldQuests.Count > 0) then
    for Index := 0 to PlayerOldQuests.Count - 1 do
    begin
      Quest := PPlayerOldQuest(PlayerOldQuests[Index]);
      if (High(av) < 1) or (TQuestType(av[1].GetInt) = Quest.QuestType) then
        if Quest.Successful then av[0].SetInt(av[0].GetInt + 1);
    end;
end;
{ @end $6331A0 }

{ @routine $63325C SF_QuestsStatusByNom }
procedure SF_QuestsStatusByNom(av: array of TVarEC; code: TCodeEC);
var
  Kind: TQuestType;
  Number, Index: Integer;
  OldQuest: PPlayerOldQuest;
  Quest: PQuest;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script QuestsStatusByNom');
  Kind := TQuestType(av[1].GetInt);
  Number := av[2].GetInt;
  if (PlayerOldQuests <> nil) and (PlayerOldQuests.Count > 0) then
    for Index := 0 to PlayerOldQuests.Count - 1 do
    begin
      OldQuest := PPlayerOldQuest(PlayerOldQuests[Index]);
      if (OldQuest.QuestType = Kind) and (OldQuest.QuestNumber = Number) then
      begin
        if OldQuest.Successful then av[0].SetInt(3) else av[0].SetInt(4);
        Exit;
      end;
    end;
  if (GetPlayer.Quests <> nil) and (GetPlayer.Quests.Count > 0) then
    for Index := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := PQuest(GetPlayer.Quests[Index]);
      if (Quest.QuestType = Kind) and (Quest.QuestNumber = Number) then
      begin
        if Quest.Successful then av[0].SetInt(2) else av[0].SetInt(1);
        Exit;
      end;
    end;
  av[0].SetInt(0);
end;
{ @end $63325C }

{ @routine $63342C SF_PlayerPlanetaryBattlesCompleted }
procedure SF_PlayerPlanetaryBattlesCompleted(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.PlanetBattles);
end;
{ @end $63342C }

{ @routine $63346C SF_PlayerMayTakeSubCrack }
procedure SF_PlayerMayTakeSubCrack(av: array of TVarEC; code: TCodeEC);
begin
  if GetPlayer.MayTakeSubCrack then av[0].SetInt(1) else av[0].SetInt(0);
end;
{ @end $63346C }

{ @routine $6334C4 SF_SubCrackCost }
procedure SF_SubCrackCost(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.GetSubCrackCost);
end;
{ @end $6334C4 }

{ @routine $633504 SF_ShipCalcParam }
procedure SF_ShipCalcParam(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipCalcParam');
  TShip(av[1].GetDword).RefreshDerivedStats(True);
end;
{ @end $633504 }

{ @routine $633580 SF_ShipRefit }
procedure SF_ShipRefit(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRefit');
  av[0].SetInt(0);
  Ship := TShip(av[1].GetDword);
  if High(av) > 2 then
    if av[3].GetInt > Ship.Money then Ship.SetMoney(av[3].GetInt);
  Ship.BuyEquipmentAtLocation(True);
  if High(av) > 1 then
    if Ship.GetHull.Weight < av[2].GetInt then
    begin
      Ship.GetHull.Weight := av[2].GetInt;
      Ship.GetHull.HullPoints := av[2].GetInt;
    end;
  Ship.RefreshDerivedStats(True);
  av[0].SetInt(1);
end;
{ @end $633580 }

{ @routine $6336A4 SF_ShipImproveItems }
procedure SF_ShipImproveItems(av: array of TVarEC; code: TCodeEC);
var Ship: TShip; I, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipImproveItems');
  av[0].SetInt(0);
  Ship := TShip(av[1].GetDword);
  Count := 1;
  if High(av) > 1 then Count := av[2].GetInt;
  for I := 1 to Count do Ship.ImproveRandomEquipment(False);
  Ship.RefreshDerivedStats(True);
  if Ship.GetDesiredCargoFreeSpace > Ship.CargoFreeSpace then
  begin
    Ship.GetHull.Weight := Ship.GetHull.Weight - Ship.CargoFreeSpace + Ship.GetDesiredCargoFreeSpace;
    if (Ship.CurrentPlanet <> nil) or (Ship.DockedTo <> nil) or (Ship.CurrentStar = nil) then
      Ship.GetHull.HullPoints := Ship.GetHull.Weight;
  end;
  Ship.RefreshDerivedStats(True);
end;
{ @end $6336A4 }

{ @routine $6337F0 SF_ItemImprovement }
procedure SF_ItemImprovement(av: array of TVarEC; code: TCodeEC);
var Obj: TObject; Item: TItem; Equipment: TEquipment; SavedId, Kind: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ItemImprovement');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].SetInt(0);
  if Item.ItemType in [t_Hull..t_CustomWeapon] then
  begin
    Equipment := TEquipment(Item);
    if not Equipment.HasStandardStats then av[0].SetInt(1);
    if High(av) > 1 then
    begin
      Kind := av[2].GetInt;
      if (Kind < 0) or (Kind > 3) then Kind := 3;
      if High(av) > 2 then Equipment.DetailImprovement := av[3].GetInt
      else Equipment.DetailImprovement := 0;
      if High(av) > 3 then
      begin
        SavedId := Equipment.Id;
        Equipment.Id := av[4].GetDword;
        Equipment.Improve(TImprovementKind(Kind));
        Equipment.Id := SavedId;
      end
      else Equipment.Improve(TImprovementKind(Kind));
    end;
  end;
end;
{ @end $6337F0 }

{ @routine $633970 SF_ShipFreeFlight }
procedure SF_ShipFreeFlight(av: array of TVarEC; code: TCodeEC);
var Ship: TShip; Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ShipFreeFlight');
  Ship := TShip(av[1].GetDword);
  ScriptSnap(Snapshot);
  if (High(av) < 2) or (av[2].GetInt = 0) then Ship.NextDayLogic
  else
    case av[2].GetInt of
      1: Ship.AssignWeaponTargetsInStar;
      2: Ship.SelectEnemyShipInStar;
      3: Ship.EngageEnemyShip;
      4: Ship.DropCargoUntilNotOverloaded;
      5: Ship.AutoApplyMicroModules;
      6: Ship.QueueItemsWithinPickupRange;
    end;
  ScriptUnSnap(Snapshot);
end;
{ @end $633970 }

{ @routine $633A88 SF_ShipKillFactionInCurSystem }
procedure SF_ShipKillFactionInCurSystem(av: array of TVarEC; code: TCodeEC);
type
  TKillFactionIndex = 0..3;
  TKillCounts = array[0..3] of Word;
var Obj: TObject;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ShipKillFactionInCurSystem');
  Obj := TObject(av[1].GetDword);
  if not (Obj is TNormalShip) then
  begin
    av[0].SetInt(0);
    Exit;
  end;

  if av[2].GetInt = -1 then
  begin
    av[0].SetInt((Obj as TNormalShip).CurrentSystemKills.Custom);
    if High(av) > 2 then (Obj as TNormalShip).CurrentSystemKills.Custom := av[3].GetInt;
  end
  else
  begin
    av[0].SetInt(TKillCounts((Obj as TNormalShip).CurrentSystemKills)[TKillFactionIndex(av[2].GetInt)]);
    if High(av) > 2 then
    begin
      TKillCounts((Obj as TNormalShip).CurrentSystemKills)[TKillFactionIndex(av[2].GetInt)] := av[3].GetInt;
      TShip(Obj).RefreshCurrentStanding;
    end;
  end;
end;
{ @end $633A88 }

{ @routine $633C04 SF_CapitalShipStats }
procedure SF_CapitalShipStats(av: array of TVarEC; code: TCodeEC);
var Obj: TObject; Ship: TShip; Hull: THull;
begin
  av[0].SetInt(0);
  if High(av) < 1 then raise Exception.Create('Error.Script SF_CapitalShipStats');
  Obj := TObject(av[1].GetDword);
  Ship := nil;
  Hull := nil;
  if Obj is TScriptShip then Ship := (Obj as TScriptShip).Ship;
  if Obj is TShip then Ship := TShip(Obj);
  if Ship <> nil then Hull := Ship.GetHull;
  if Obj is THull then Hull := THull(Obj);
  if Hull <> nil then
  begin
    av[0].SetInt(Hull.CapitalShip);
    if High(av) > 1 then
    begin
      Hull.CapitalShip := av[2].GetInt;
      if Hull.CapitalShip = 1 then
      begin
        Hull.InterceptorsEnabled := True;
        if High(av) > 2 then Hull.EnergyMax := av[3].GetInt
        else Hull.EnergyMax := 1000;
        Hull.Energy := Min(Hull.Energy, Hull.EnergyMax);
      end
      else
      begin
        Hull.InterceptorsEnabled := False;
        Hull.EnergyMax := 0;
        Hull.Energy := 0;
      end;
    end;
  end;
end;
{ @end $633C04 }

{ @routine $633DB0 SF_PlayerBridge }
procedure SF_PlayerBridge(av: array of TVarEC; code: TCodeEC);
var
  Mode: Integer;
begin
  av[0].SetInt(GetPlayer.RuinsMode);
  if High(av) > 0 then
  begin
    Mode := av[1].GetInt;
    if High(av) > 1 then GetPlayer.RuinsStatusText := av[2].GetString else GetPlayer.RuinsStatusText := '';
    if Mode > 0 then GetPlayer.EnterRuinsMode(Mode) else GetPlayer.CloseRuinsModeScreen;
  end;
end;
{ @end $633DB0 }

{ @routine $633E90 SF_PlayerDebt }
procedure SF_PlayerDebt(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.DebtAmount);
  if High(av) > 0 then GetPlayer.DebtAmount := av[1].GetInt;
end;
{ @end $633E90 }

{ @routine $633EF0 SF_PlayerDebtDate }
procedure SF_PlayerDebtDate(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.DebtDueTurn);
  if High(av) > 0 then GetPlayer.DebtDueTurn := av[1].GetInt;
end;
{ @end $633EF0 }

{ @routine $633F50 SF_PlayerDebtCnt }
procedure SF_PlayerDebtCnt(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.DebtDefaultCount);
  if High(av) > 0 then GetPlayer.DebtDefaultCount := av[1].GetInt;
end;
{ @end $633F50 }

{ @routine $633FB0 SF_PlayerDeposit }
procedure SF_PlayerDeposit(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.DepositAmount);
  if High(av) > 0 then GetPlayer.DepositAmount := av[1].GetInt;
end;
{ @end $633FB0 }

{ @routine $634010 SF_PlayerDepositDate }
procedure SF_PlayerDepositDate(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.DepositStartTurn);
  if High(av) > 0 then GetPlayer.DepositStartTurn := av[1].GetInt;
end;
{ @end $634010 }

{ @routine $634070 SF_PlayerDepositDay }
procedure SF_PlayerDepositDay(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.DepositDayCount);
  if High(av) > 0 then GetPlayer.DepositDayCount := av[1].GetInt;
end;
{ @end $634070 }

{ @routine $6340D0 SF_PlayerDepositPercent }
procedure SF_PlayerDepositPercent(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Round(GetPlayer.DepositInterestRate * 100));
  if High(av) > 0 then GetPlayer.DepositInterestRate := av[1].GetInt * 0.01;
end;
{ @end $6340D0 }

{ @routine $63415C SF_PlayerMedPolicy }
procedure SF_PlayerMedPolicy(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(GetPlayer.MedicalPolicyTicks);
  if High(av) > 0 then GetPlayer.MedicalPolicyTicks := av[1].GetInt;
end;
{ @end $63415C }

{ @routine $6341BC SF_ShipCustomShipInfosCount }
procedure SF_ShipCustomShipInfosCount(av: array of TVarEC; code: TCodeEC);
var
  I, Count: Integer;
  Ship: TShip;
  Info: PCustomShipInfo;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipCustomShipInfosCount');
  Ship := TShip(av[1].GetDword);
  Count := 0;
  for I := 0 to Ship.CustomShipInfos.Count - 1 do
  begin
    Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
    if not Info.DeleteQueued then Inc(Count);
  end;
  av[0].SetInt(Count);
end;
{ @end $6341BC }

{ @routine $634298 SF_ShipAddCustomShipInfo }
procedure SF_ShipAddCustomShipInfo(av: array of TVarEC; code: TCodeEC);
var
  Info: PCustomShipInfo;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipAddCustomShipInfo');
  New(Info);
  TShip(av[1].GetDword).CustomShipInfos.Add(Info);
  Info.ActionCode := nil;
  Info.TypeName := av[2].GetString;
  Info.ActionCodeInitialized := False;
  Info.DeleteQueued := False;
  if High(av) > 2 then Info.Description := av[3].GetString else Info.Description := '';
  if High(av) > 3 then Info.Data[1] := av[4].GetInt else Info.Data[1] := 0;
  if High(av) > 4 then Info.Data[2] := av[5].GetInt else Info.Data[2] := 0;
  if High(av) > 5 then Info.Data[3] := av[6].GetInt else Info.Data[3] := 0;
  if High(av) > 6 then Info.TextData1 := av[7].GetString else Info.TextData1 := '';
  if High(av) > 7 then Info.TextData2 := av[8].GetString else Info.TextData2 := '';
  if High(av) > 8 then Info.TextData3 := av[9].GetString else Info.TextData3 := '';
  Info.StatusEffect := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').GetBlock(Info.TypeName).CountParams('StatusEffect') > 0;
  av[0].SetDword(Cardinal(Info));
end;
{ @end $634298 }

{ @routine $63457C SF_ShipDeleteCustomShipInfo }
procedure SF_ShipDeleteCustomShipInfo(av: array of TVarEC; code: TCodeEC);
var
  Index, I: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipDeleteCustomShipInfo');
  Ship := TShip(av[1].GetDword);
  if av[2].RealVType = vkString then
  begin
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued and (Info.TypeName = av[2].GetString) then
      begin
        Info.DeleteQueued := True;
        Exit;
      end;
    end;
  end
  { Native pointer/index discrimination; deletion is deferred to the ship. }
  else if (av[2].GetDword > 10000) and (av[2].GetInt <> -1) then
  begin
    if (Ship = nil) or (Ship.CustomShipInfos.IndexOf(Pointer(av[2].GetDword)) >= 0) then
      PCustomShipInfo(av[2].GetDword).DeleteQueued := True;
  end
  else
  begin
    Index := av[2].GetInt;
    if Index < 0 then Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued then
      begin
        Dec(Index);
        if Index < 0 then Break;
      end;
    end;
    if (Index < 0) and (Info <> nil) then Info.DeleteQueued := True;
  end;
end;
{ @end $63457C }

{ @routine $634784 SF_ShipFindCustomShipInfoByType }
procedure SF_ShipFindCustomShipInfoByType(av: array of TVarEC; code: TCodeEC);
var
  I, Index: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipFindCustomShipInfoByType');
  Ship := TShip(av[1].GetDword);
  Index := 0;
  for I := 0 to Ship.CustomShipInfos.Count - 1 do
  begin
    Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
    if not Info.DeleteQueued then
    begin
      if Info.TypeName = av[2].GetString then
      begin
        av[0].SetInt(Index);
        Exit;
      end;
      Inc(Index);
    end;
  end;
  av[0].SetInt(-1);
end;
{ @end $634784 }

{ @routine $6348C0 SF_ShipCustomShipInfoDescription }
procedure SF_ShipCustomShipInfoDescription(av: array of TVarEC; code: TCodeEC);
var
  I, Index: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
  Block: TBlockParEC;
begin
  { Native validation accepts one argument even though lookup below reads av[2]. }
  if High(av) < 1 then raise Exception.Create('Error.Script ShipCustomShipInfoDescription');
  av[0].SetString('');
  Ship := TShip(av[1].GetDword);
  if av[2].RealVType = vkString then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued and (Info.TypeName = av[2].GetString) then Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].GetString) then Exit;
  end
  else if (av[2].GetDword > 10000) and (av[2].GetInt <> -1) then
  begin
    Info := PCustomShipInfo(av[2].GetDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then Exit;
  end
  else
  begin
    Index := av[2].GetInt;
    if Index < 0 then Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued then
      begin
        Dec(Index);
        if Index < 0 then Break;
      end;
    end;
    if (Index >= 0) or (Info = nil) then Exit;
  end;
  av[0].SetString(Info.Description);
  if av[0].GetString = '' then
  begin
    Block := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').GetBlock(Info.TypeName);
    if Block.CountParams('Description') <> 0 then av[0].SetString(Block.GetParam('Description'));
  end;
  if High(av) > 2 then Info.Description := av[3].GetString;
end;
{ @end $6348C0 }

{ @routine $634C18 SF_ShipCustomShipInfoData }
procedure SF_ShipCustomShipInfoData(av: array of TVarEC; code: TCodeEC);
var
  I, Index, DataIndex: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipCustomShipInfoData');
  av[0].SetInt(0);
  Ship := TShip(av[1].GetDword);
  if av[2].RealVType = vkString then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued and (Info.TypeName = av[2].GetString) then Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].GetString) then Exit;
  end
  else if (av[2].GetDword > 10000) and (av[2].GetInt <> -1) then
  begin
    Info := PCustomShipInfo(av[2].GetDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then Exit;
  end
  else
  begin
    Index := av[2].GetInt;
    if Index < 0 then Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued then
      begin
        Dec(Index);
        if Index < 0 then Break;
      end;
    end;
    if (Index >= 0) or (Info = nil) then Exit;
  end;
  DataIndex := av[3].GetInt;
  case DataIndex of
    1: av[0].SetInt(Info.Data[1]);
    2: av[0].SetInt(Info.Data[2]);
    3: av[0].SetInt(Info.Data[3]);
  else raise Exception.Create('Error.Script ShipCustomShipInfoData ind');
  end;
  if High(av) > 3 then
    case DataIndex of
      1: Info.Data[1] := av[4].GetInt;
      2: Info.Data[2] := av[4].GetInt;
      3: Info.Data[3] := av[4].GetInt;
    end;
end;
{ @end $634C18 }

{ @routine $634F34 SF_ShipCustomShipInfoTextData }
procedure SF_ShipCustomShipInfoTextData(av: array of TVarEC; code: TCodeEC);
var
  I, Index, DataIndex: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipCustomShipInfoTextData');
  av[0].SetString('');
  Ship := TShip(av[1].GetDword);
  if av[2].RealVType = vkString then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued and (Info.TypeName = av[2].GetString) then Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].GetString) then Exit;
  end
  else if (av[2].GetDword > 10000) and (av[2].GetInt <> -1) then
  begin
    Info := PCustomShipInfo(av[2].GetDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then Exit;
  end
  else
  begin
    Index := av[2].GetInt;
    if Index < 0 then Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued then
      begin
        Dec(Index);
        if Index < 0 then Break;
      end;
    end;
    if (Index >= 0) or (Info = nil) then Exit;
  end;
  DataIndex := av[3].GetInt;
  case DataIndex of
    1: av[0].SetString(Info.TextData1);
    2: av[0].SetString(Info.TextData2);
    3: av[0].SetString(Info.TextData3);
  else raise Exception.Create('Error.Script ShipCustomShipInfoData ind');
  end;
  if High(av) > 3 then
    case DataIndex of
      1: Info.TextData1 := av[4].GetString;
      2: Info.TextData2 := av[4].GetString;
      3: Info.TextData3 := av[4].GetString;
    end;
end;
{ @end $634F34 }

{ @routine $635280 SF_StarCustomStarInfosCount }
procedure SF_StarCustomStarInfosCount(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarCustomStarInfosCount');
  av[0].SetInt(TStar(av[1].GetDword).CustomSystemInfos.Count);
end;
{ @end $635280 }

{ @routine $635314 SF_StarAddCustomStarInfo }
procedure SF_StarAddCustomStarInfo(av: array of TVarEC; code: TCodeEC);
var
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script StarAddCustomStarInfo');
  Star := TStar(av[1].GetDword);
  Info := TCustomSystemInfo.Create;
  Star.CustomSystemInfos.Add(Info);
  Info.TypeTag := av[2].GetString;
  Info.Name := av[3].GetString;
  if High(av) > 3 then Info.Distance := av[4].GetInt else Info.Distance := 0;
  if High(av) > 4 then Info.Icon := av[5].GetString else Info.Icon := '';
  if High(av) > 5 then Info.Info := av[6].GetString else Info.Info := '';
end;
{ @end $635314 }

{ @routine $6354AC SF_StarDeleteCustomStarInfo }
procedure SF_StarDeleteCustomStarInfo(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarDeleteCustomStarInfo');
  Star := TStar(av[1].GetDword);
  if av[2].RealVType = vkString then
  begin
    for I := 0 to Star.CustomSystemInfos.Count - 1 do
    begin
      Info := TCustomSystemInfo(Star.CustomSystemInfos[I]);
      if Info.TypeTag = av[2].GetString then
      begin
        Star.CustomSystemInfos.Delete(I);
        Info.Free;
        Break;
      end;
    end;
    Exit;
  end;
  I := av[2].GetInt;
  if I < 0 then Exit;
  if Star.CustomSystemInfos.Count <= I then Exit;
  Info := TCustomSystemInfo(Star.CustomSystemInfos[I]);
  Star.CustomSystemInfos.Delete(I);
  Info.Free;
end;
{ @end $6354AC }

{ @routine $635638 SF_StarFindCustomStarInfoByType }
procedure SF_StarFindCustomStarInfoByType(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarFindCustomStarInfoByType');
  Star := TStar(av[1].GetDword);
  for I := 0 to Star.CustomSystemInfos.Count - 1 do
  begin
    Info := TCustomSystemInfo(Star.CustomSystemInfos[I]);
    if Info.TypeTag = av[2].GetString then
    begin
      av[0].SetInt(I);
      Exit;
    end;
  end;
  av[0].SetInt(-1);
end;
{ @end $635638 }

{ @routine $635764 SF_StarCustomStarInfoData }
procedure SF_StarCustomStarInfoData(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script StarCustomStarInfoData');
  av[0].SetString('');
  Star := TStar(av[1].GetDword);
  I := av[2].GetInt;
  if (I >= 0) and (Star.CustomSystemInfos.Count > I) then
  begin
    Info := TCustomSystemInfo(Star.CustomSystemInfos[I]);
    if av[3].GetString = 'Name' then
    begin
      av[0].SetString(Info.Name);
      if High(av) > 3 then Info.Name := av[4].GetString;
    end
    else if av[3].GetString = 'Dist' then
    begin
      av[0].SetInt(Info.Distance);
      if High(av) > 3 then Info.Distance := av[4].GetInt;
    end
    else if av[3].GetString = 'Icon' then
    begin
      av[0].SetString(Info.Icon);
      if High(av) > 3 then Info.Icon := av[4].GetString;
    end
    else if av[3].GetString = 'Info' then
    begin
      av[0].SetString(Info.Info);
      if High(av) > 3 then Info.Info := av[4].GetString;
    end
    else raise Exception.Create('Error.Script StarCustomStarInfoData 2');
  end;
end;
{ @end $635764 }

{ @routine $635A40 SF_ItemCanBeBroken }
procedure SF_ItemCanBeBroken(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  CanBreak: Boolean;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemCanBeBroken');
  CanBreak := False;
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then CanBreak := (Item.ItemType in [t_FuelTanks..t_CustomWeapon, t_Satellite]) or (Item.ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks]);
  av[0].SetDword(Ord(CanBreak));
end;
{ @end $635A40 }

{ @routine $635B44 SF_ItemFragility }
procedure SF_ItemFragility(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemFragility');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].SetFloat(1);
  if Item <> nil then
    if Item is TEquipment then av[0].SetFloat(TEquipment(Item).GetFragilityFactor([]));
end;
{ @end $635B44 }

{ @routine $635C40 SF_ItemDurability }
procedure SF_ItemDurability(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  OldValue, NewValue: Integer;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemDurability');
  OldValue := 100;
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item is TEquipment then
    begin
      OldValue := Round((Item as TEquipment).ConditionPercent);
      if High(av) > 1 then
      begin
        NewValue := Min(av[2].GetInt, 100);
        (Item as TEquipment).ConditionPercent := NewValue;
        (Item as TEquipment).BrokenFlag := Ord(NewValue <= 0);
      end;
    end;
  av[0].SetInt(OldValue);
end;
{ @end $635C40 }

{ @routine $635D98 SF_ItemLevel }
procedure SF_ItemLevel(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  OldLevel, NewLevel: Integer;
  Item: TItem;
  OldBase, NewBase: TEquipment;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemLevel');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  OldLevel := 0;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item.ItemType in [t_Hull..t_CustomWeapon] then
    begin
      OldLevel := (Item as TEquipment).GetLevel;
      if High(av) > 1 then
      begin
        NewLevel := Max(1, av[2].GetInt);
        if Item is TWeapon then
        begin
          OldBase := CreateGeneratedWeapon(TWeapon(Item).GetWeaponInfo, Item.Weight, OldLevel, Item.OwnerId);
          NewBase := CreateGeneratedWeapon(TWeapon(Item).GetWeaponInfo, Item.Weight, NewLevel, Item.OwnerId);
        end
        else
        begin
          OldBase := CreateGeneratedEquipment(Item.ItemType, Item.Weight, OldLevel, Item.OwnerId);
          NewBase := CreateGeneratedEquipment(Item.ItemType, Item.Weight, NewLevel, Item.OwnerId);
        end;
        case Item.ItemType of
          t_Hull: begin
            THull(Item).TechLevel := NewLevel;
            THull(Item).Armor := THull(Item).Armor + THull(NewBase).Armor - THull(OldBase).Armor;
          end;
          t_FuelTanks: begin
            TFuelTanks(Item).TechLevel := NewLevel;
            TFuelTanks(Item).Capacity := TFuelTanks(Item).Capacity + TFuelTanks(NewBase).Capacity - TFuelTanks(OldBase).Capacity;
            TFuelTanks(Item).Fuel := Max(0, Min(TFuelTanks(Item).Fuel, TFuelTanks(Item).Capacity));
          end;
          t_Engine: begin
            TEngine(Item).TechLevel := NewLevel;
            TEngine(Item).Speed := TEngine(Item).Speed + TEngine(NewBase).Speed - TEngine(OldBase).Speed;
            TEngine(Item).JumpRange := TEngine(Item).JumpRange + TEngine(NewBase).JumpRange - TEngine(OldBase).JumpRange;
          end;
          t_Radar: begin
            TRadar(Item).TechLevel := NewLevel;
            TRadar(Item).Range := TRadar(Item).Range + TRadar(NewBase).Range - TRadar(OldBase).Range;
          end;
          t_Scaner: begin
            TScaner(Item).TechLevel := NewLevel;
            TScaner(Item).ScanPower := TScaner(Item).ScanPower + TScaner(NewBase).ScanPower - TScaner(OldBase).ScanPower;
          end;
          t_RepairRobot: begin
            TRepairRobot(Item).TechLevel := NewLevel;
            TRepairRobot(Item).RepairPoints := TRepairRobot(Item).RepairPoints + TRepairRobot(NewBase).RepairPoints - TRepairRobot(OldBase).RepairPoints;
          end;
          t_CargoHook: begin
            TCargoHook(Item).TechLevel := NewLevel;
            TCargoHook(Item).PickupPower := TCargoHook(Item).PickupPower + TCargoHook(NewBase).PickupPower - TCargoHook(OldBase).PickupPower;
            TCargoHook(Item).Range := TCargoHook(Item).Range + TCargoHook(NewBase).Range - TCargoHook(OldBase).Range;
            TCargoHook(Item).MinPullSpeed := TCargoHook(Item).MinPullSpeed + TCargoHook(NewBase).MinPullSpeed - TCargoHook(OldBase).MinPullSpeed;
            TCargoHook(Item).MaxPullSpeed := TCargoHook(Item).MaxPullSpeed + TCargoHook(NewBase).MaxPullSpeed - TCargoHook(OldBase).MaxPullSpeed;
          end;
          t_DefGenerator: begin
            TDefGenerator(Item).TechLevel := NewLevel;
            TDefGenerator(Item).DamageFactor := TDefGenerator(Item).DamageFactor + TDefGenerator(NewBase).DamageFactor - TDefGenerator(OldBase).DamageFactor;
          end;
        else
          if Item.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
          begin
            TWeapon(Item).TechLevel := NewLevel;
            TWeapon(Item).Range := TWeapon(Item).Range + TWeapon(NewBase).Range - TWeapon(OldBase).Range;
            TWeapon(Item).MinDamage := TWeapon(Item).MinDamage + TWeapon(NewBase).MinDamage - TWeapon(OldBase).MinDamage;
            TWeapon(Item).MaxDamage := TWeapon(Item).MaxDamage + TWeapon(NewBase).MaxDamage - TWeapon(OldBase).MaxDamage;
            TWeapon(Item).AmmoCapacity := TWeapon(Item).AmmoCapacity + TWeapon(NewBase).AmmoCapacity - TWeapon(OldBase).AmmoCapacity;
            TWeapon(Item).Ammo := Max(0, TWeapon(Item).Ammo + TWeapon(NewBase).Ammo - TWeapon(OldBase).Ammo);
          end;
        end;
        OldBase.Free;
        NewBase.Free;
      end;
    end;
  av[0].SetInt(OldLevel);
end;
{ @end $635D98 }

{ @routine $63621C SF_ContainerFuel }
procedure SF_ContainerFuel(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ContainerFuel');
  Obj := TObject(av[1].GetDword);
  if Obj is TFuelTanks then
  begin
    av[0].SetInt(TFuelTanks(Obj).Fuel);
    if High(av) > 1 then TFuelTanks(Obj).Fuel := av[2].GetInt;
  end
  else if Obj is TCistern then
  begin
    av[0].SetInt(TCistern(Obj).Fuel);
    if High(av) > 1 then TCistern(Obj).Fuel := av[2].GetInt;
  end
  else av[0].SetInt(0);
end;
{ @end $63621C }

{ @routine $636318 SF_ItemCharge }
procedure SF_ItemCharge(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemCharge');
  Obj := TObject(av[1].GetDword);
  if Obj is TArtefactTransmitter then
  begin
    av[0].SetInt(TArtefactTransmitter(Obj).Power);
    if High(av) > 1 then TArtefactTransmitter(Obj).Power := av[2].GetInt;
  end
  else av[0].SetInt(0);
end;
{ @end $636318 }

{ @routine $6363D4 SF_MissilesToRearm }
procedure SF_MissilesToRearm(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Needed, Count: Integer;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissilesToRearm');
  Obj := TObject(av[1].GetDword);
  Needed := 0;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
    begin
      // Native checks the base equipment class here, then accesses weapon fields.
      Needed := TWeapon(Item as TEquipment).AmmoCapacity - TWeapon(Item as TEquipment).Ammo;
      if High(av) > 1 then
      begin
        Count := av[2].GetInt;
        TWeapon(Item as TEquipment).Ammo := Max(0, Min(TWeapon(Item as TEquipment).AmmoCapacity, TWeapon(Item as TEquipment).Ammo + Count));
      end;
    end;
  av[0].SetInt(Needed);
end;
{ @end $6363D4 }

{ @routine $63655C SF_WeaponAmmunition }
procedure SF_WeaponAmmunition(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Weapon: TWeapon;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script WeaponAmmunition');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item = nil) or not (Item is TWeapon) then av[0].SetInt(0)
  else
  begin
    Weapon := Item as TWeapon;
    av[0].SetInt(Weapon.Ammo);
    if High(av) > 1 then Weapon.Ammo := av[2].GetInt;
  end;
end;
{ @end $63655C }

{ @routine $636670 SF_WeaponMaxAmmunition }
procedure SF_WeaponMaxAmmunition(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Weapon: TWeapon;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script WeaponAmmunition');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item = nil) or not (Item is TWeapon) then
  begin
    av[0].SetInt(0);
    Exit;
  end;

  Weapon := Item as TWeapon;
  av[0].SetInt(Weapon.AmmoCapacity);
  if High(av) > 1 then Weapon.AmmoCapacity := av[2].GetInt;
end;
{ @end $636670 }

{ @routine $636784 SF_ShipSpecialBonuses }
procedure SF_ShipSpecialBonuses(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TEquipmentBonusKind;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ShipSpecialBonuses');
  Ship := TShip(av[1].GetDword);
  Kind := TEquipmentBonusKind(av[2].GetInt);
  if (High(av) > 2) and (av[3].RealVType = vkString) and (av[3].GetString = 'Total') then
    av[0].SetInt(Ship.GetTotalStatBonus(Kind))
  else
  begin
    av[0].SetInt(Ship.GetOwnStatBonus(Kind));
    if High(av) > 2 then Ship.SetStatBonus(Kind, av[3].GetInt);
  end;
end;
{ @end $636784 }

{ @routine $6368D4 SF_ItemExtraSpecials }
procedure SF_ItemExtraSpecials(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Index, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ItemExtraSpecials');
  if (High(av) = 1) and (TItem(av[1].GetDword).ItemType in [t_Food..t_Narcotics]) then
  begin
    av[0].SetInt(0);
    Exit;
  end;

  Item := TEquipment(av[1].GetDword);
  if Item.ExtraSpecials = nil then Count := 0 else Count := Item.ExtraSpecials.Count;
  if High(av) < 2 then av[0].SetInt(Count)
  else
  begin
    Index := av[2].GetInt;
    if (Index < 0) or (Index >= Count) then av[0].SetInt(-1)
    else av[0].SetInt(PExtraSpecial(Item.ExtraSpecials[Index]).ModuleIndexPlusOne - 1);
  end;
end;
{ @end $6368D4 }

{ @routine $6369F4 SF_ItemExtraSpecialsCountByType }
procedure SF_ItemExtraSpecialsCountByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ItemExtraSpecialsCountByType');
  if TItem(av[1].GetDword).ItemType in [t_Food..t_Narcotics] then
  begin
    av[0].SetInt(0);
    Exit;
  end;

  Item := TEquipment(av[1].GetDword);
  ModuleIndex := av[2].GetInt + 1;
  av[0].SetInt(0);
  if Item.ExtraSpecials <> nil then
    for Index := 0 to Item.ExtraSpecials.Count - 1 do
    begin
      Entry := PExtraSpecial(Item.ExtraSpecials[Index]);
      if Entry.ModuleIndexPlusOne = ModuleIndex then
      begin
        av[0].SetInt(Entry.Count);
        Exit;
      end;
    end;
end;
{ @end $6369F4 }

{ @routine $636B18 SF_ItemExtraSpecialsAddByType }
procedure SF_ItemExtraSpecialsAddByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index, Found, Count: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ItemExtraSpecialsAddByType');
  Item := TEquipment(av[1].GetDword);
  ModuleIndex := av[2].GetInt + 1;
  if ModuleIndex <= 0 then raise Exception.Create('Error.Script SF_ItemExtraSpecialsAddByType invalid bonus');
  if High(av) > 2 then Count := av[3].GetInt else Count := 1;
  if Item.ExtraSpecials = nil then
  begin
    if Count <= 0 then Exit;
    Item.ExtraSpecials := TList.Create;
  end;
  Entry := nil;
  Found := -1;
  for Index := 0 to Item.ExtraSpecials.Count - 1 do
    if PExtraSpecial(Item.ExtraSpecials[Index]).ModuleIndexPlusOne = ModuleIndex then
    begin
      Entry := PExtraSpecial(Item.ExtraSpecials[Index]);
      Found := Index;
      Break;
    end;
  if Entry <> nil then
  begin
    Inc(Entry.Count, Count);
    if Entry.Count <= 0 then
    begin
      Dispose(Entry);
      Item.ExtraSpecials.Delete(Found);
      if Item.ExtraSpecials.Count = 0 then
      begin
        Item.ExtraSpecials.Free;
        Item.ExtraSpecials := nil;
      end;
    end;
  end
  else
  begin
    New(Entry);
    Item.ExtraSpecials.Add(Entry);
    Entry.ModuleIndexPlusOne := ModuleIndex;
    Entry.Count := Count;
  end;
end;
{ @end $636B18 }

{ @routine $636D2C SF_ItemExtraSpecialsDeleteByType }
procedure SF_ItemExtraSpecialsDeleteByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index, Found, Count: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ItemExtraSpecialsDeleteByType');
  Item := TEquipment(av[1].GetDword);
  ModuleIndex := av[2].GetInt + 1;
  if High(av) > 2 then Count := av[3].GetInt else Count := 1;
  if Item.ExtraSpecials = nil then Exit;
  Entry := nil;
  Found := -1;
  for Index := 0 to Item.ExtraSpecials.Count - 1 do
    if PExtraSpecial(Item.ExtraSpecials[Index]).ModuleIndexPlusOne = ModuleIndex then
    begin
      Entry := PExtraSpecial(Item.ExtraSpecials[Index]);
      Found := Index;
      Break;
    end;
  if Entry <> nil then
  begin
    Dec(Entry.Count, Count);
    if Entry.Count <= 0 then
    begin
      Dispose(Entry);
      Item.ExtraSpecials.Delete(Found);
      if Item.ExtraSpecials.Count = 0 then
      begin
        Item.ExtraSpecials.Free;
        Item.ExtraSpecials := nil;
      end;
    end;
  end;
end;
{ @end $636D2C }

{ @routine $636EA0 SF_ExecuteCodeFromString }
procedure SF_ExecuteCodeFromString(av: array of TVarEC; code: TCodeEC);
var
  SourceText: WideString;
  RunCode: TCodeEC;
  SavedScript: TScript;
  I, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ExecuteCodeFromString');
  SourceText := av[1].GetString;
  if High(av) = 1 then
  begin
    if code <> nil then ExecuteScriptText(SourceText, code.LocalVar)
    else ExecuteScriptText(SourceText, nil);
  end
  else
  begin
    SavedScript := CurrentScript;
    RunCode := CompileScriptText(SourceText);
    RunCode.LinkAll(SharedScriptVariables, False);
    RunCode.LinkAll(ScriptFunctionScope, False);
    RunCode.ScriptFunLinked := True;
    if code <> nil then RunCode.LinkAll(code.LocalVar, False);
    Count := (High(av) - 1) div 2;
    for I := 1 to Count do
      RunCode.LocalVar.Add(av[I * 2].GetString, av[I * 2 + 1].RealVType).Assume(av[I * 2 + 1], True);
    try
      RunCode.Run(ScriptProcess);
    except
      on E: EBreakMessageGI do ;
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        LogScriptCallHistory;
        AppendLogLineThreadSafe('Error while executing code from string: ');
        if Length(SourceText) <= 256 then AppendLogLineThreadSafe(AnsiString(SourceText))
        else AppendLogLineThreadSafe(AnsiString(Copy(SourceText, 1, 256) + ' ...'));
        raise;
      end;
    end;
    if High(av) mod 2 = 0 then
      av[0].Assume(RunCode.LocalVar.GetVar(av[High(av)].GetString), True);
    CurrentScript := SavedScript;
    RunCode.Free;
  end;
end;
{ @end $636EA0 }

{ @routine $637264 SF_GenerateCodeStringFromBlock }
procedure SF_GenerateCodeStringFromBlock(av: array of TVarEC; code: TCodeEC);
var
  Path: WideString;
  I, Count: Integer;
  Block: TBlockParEC;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_GenerateCodeStringFromBlock');
  av[0].SetString('');
  Path := av[1].GetString;
  Count := CountDelimitedPartsW(Path, '.');
  if (High(av) > 1) and (av[2].GetInt <> 0) then Block := MainDataConfig
  else Block := LanguageDataConfig;
  for I := 0 to Count - 1 do
  begin
    Block := Block.FindBlockByPath(ExtractDelimitedPartW(Path, I, '.'));
    if Block = nil then
    begin
      AppendLogLineThreadSafe(AnsiString('Warning.Script SF_GenerateCodeStringFromBlock - cant find block ' +
        av[1].GetString + ' [' + IntToStr(I) + ']'));
      Exit;
    end;
  end;
  av[0].SetString(Block.ConcatenateValues);
  if av[0].GetString = '' then
    AppendLogLineThreadSafe(AnsiString('Warning.Script SF_GenerateCodeStringFromBlock - no code at ' + av[1].GetString));
end;
{ @end $637264 }

{ @routine $6375DC SF_ItemOnUseCode }
procedure SF_ItemOnUseCode(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemOnUseCode');
  Obj := TObject(av[1].GetDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    av[0].SetString(Binding.OnUseText);
    if High(av) > 1 then Binding.OnUseText := av[2].GetString;
  end
  else av[0].SetString('');
end;
{ @end $6375DC }

{ @routine $637704 SF_ItemOnActCode }
procedure SF_ItemOnActCode(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemOnActCode');
  Obj := TObject(av[1].GetDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    av[0].SetString(Binding.OnActionText);
    if High(av) > 1 then
    begin
      Binding.ActionCodeInitialized := False;
      if High(av) > 3 then
        Binding.OnActionText := '[' + av[3].GetString + '|' + av[4].GetString + ']' + av[2].GetString
      else if High(av) = 3 then
        Binding.OnActionText := '[' + av[3].GetString + '|]' + av[2].GetString
      else Binding.OnActionText := av[2].GetString;
    end;
  end
  else av[0].SetString('');
end;
{ @end $637704 }

{ @routine $637908 SF_CreateActCodeEvent }
procedure SF_CreateActCodeEvent(av: array of TVarEC; code: TCodeEC);
var
  ActionType: TScriptActionType;
  Obj, Object1, Object2: TObject;
  Info: PCustomShipInfo;
  Ship: TShip;
  Param, I: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CreateActCodeEvent');
  ActionType := TScriptActionType(av[1].GetInt);
  if av[2].RealVType = vkString then
  begin
    if High(av) < 3 then raise Exception.Create('Error.Script CreateActCodeEvent cant call info without ship');
    Obj := TObject(av[3].GetDword);
    if not (Obj is TShip) then raise Exception.Create('Error.Script CreateActCodeEvent cant call info - not a ship');
    Ship := TShip(Obj);
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := PCustomShipInfo(Ship.CustomShipInfos[I]);
      if not Info.DeleteQueued and (Info.TypeName = av[2].GetString) then
      begin
        if High(av) >= 4 then Object1 := TObject(av[4].GetDword) else Object1 := nil;
        if High(av) >= 5 then Object2 := TObject(av[5].GetDword) else Object2 := nil;
        if High(av) >= 6 then Param := av[6].GetInt else Param := 0;
        av[0].SetInt(RunCustomShipInfoActionCode(Info, ActionType, Ship, Object1, Object2, Param));
        Exit;
      end;
    end;
    av[0].SetInt(0);
  end
  else
  begin
    Obj := TObject(av[2].GetDword);
    av[0].SetInt(0);
    if Obj is TShip then
    begin
      if High(av) >= 3 then Object1 := TObject(av[3].GetDword) else Object1 := nil;
      if High(av) >= 4 then Object2 := TObject(av[4].GetDword) else Object2 := nil;
      if High(av) >= 5 then Param := av[5].GetInt else Param := 0;
      av[0].SetInt((Obj as TShip).ScriptItemsAct(ActionType, Object1, Object2, Param));
    end
    else if Obj is TItem then
    begin
      if High(av) >= 3 then Ship := TShip(av[3].GetDword) else Ship := nil;
      if High(av) >= 4 then Object1 := TObject(av[4].GetDword) else Object1 := nil;
      if High(av) >= 5 then Object2 := TObject(av[5].GetDword) else Object2 := nil;
      if High(av) >= 6 then Param := av[6].GetInt else Param := 0;
      if TItem(Obj).ScriptItem <> nil then
        av[0].SetInt(TScriptItem(TItem(Obj).ScriptItem).RunActionCode(ActionType, Ship, Object1, Object2, Param));
      if Obj is TEquipmentWithActCode then
        av[0].SetInt(RunItemConfigActionCode(TItem(Obj), ActionType, Ship, Object1, Object2, Param));
    end;
  end;
end;
{ @end $637908 }

{ @routine $637D40 SF_CurItem }
procedure SF_CurItem(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptItemContextStack.Count < 1 then av[0].SetDword(Cardinal(ScriptUseItem))
  else av[0].SetDword(Cardinal(ScriptItemContextStack[ScriptItemContextStack.Count - 1]));
end;
{ @end $637D40 }

{ @routine $637DB0 SF_CurInfo }
procedure SF_CurInfo(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptItemInfoContextStack.Count < 1 then av[0].SetDword(0)
  else av[0].SetDword(Cardinal(ScriptItemInfoContextStack[ScriptItemInfoContextStack.Count - 1]));
end;
{ @end $637DB0 }

{ @routine $637E18 SF_ScriptItemActShip }
procedure SF_ScriptItemActShip(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionShipStack.Count < 1 then av[0].SetDword(0)
  else av[0].SetDword(Cardinal(ScriptActionShipStack[ScriptActionShipStack.Count - 1]));
end;
{ @end $637E18 }

{ @routine $637E80 SF_ScriptItemActObject1 }
procedure SF_ScriptItemActObject1(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionObject1Stack.Count < 1 then av[0].SetDword(0)
  else av[0].SetDword(Cardinal(ScriptActionObject1Stack[ScriptActionObject1Stack.Count - 1]));
end;
{ @end $637E80 }

{ @routine $637EE8 SF_ScriptItemActObject2 }
procedure SF_ScriptItemActObject2(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionObject2Stack.Count < 1 then av[0].SetDword(0)
  else av[0].SetDword(Cardinal(ScriptActionObject2Stack[ScriptActionObject2Stack.Count - 1]));
end;
{ @end $637EE8 }

{ @routine $637F50 SF_ScriptItemActionType }
procedure SF_ScriptItemActionType(av: array of TVarEC; code: TCodeEC);
var
  Matches: Boolean;
begin
  if ScriptActionTypeStack.Count < 1 then av[0].SetDword(0)
  else if High(av) <= 0 then
    av[0].SetDword(Cardinal(ScriptActionTypeStack[ScriptActionTypeStack.Count - 1]))
  else
  begin
    Matches := Integer(ScriptActionTypeStack[ScriptActionTypeStack.Count - 1]) = av[1].GetInt;
    if Matches and (High(av) > 1) then
      Matches := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]) = av[2].GetInt;
    av[0].SetDword(Ord(Matches));
  end;
end;
{ @end $637F50 }

{ @routine $638034 SF_ScriptItemActParam }
procedure SF_ScriptItemActParam(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionParamStack.Count < 1 then av[0].SetInt(0)
  else
  begin
    av[0].SetInt(Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]));
    if High(av) > 0 then ScriptActionParamStack[ScriptActionParamStack.Count - 1] := Pointer(av[1].GetInt);
  end;
end;
{ @end $638034 }

{ @routine $6380C8 SF_OnUseCodeTranclucator }
procedure SF_OnUseCodeTranclucator(av: array of TVarEC; code: TCodeEC);
var Item: TArtefactTranclucator; Ship: TTranclucator; Index: Integer; Angle: Single;
  Entry: PStorageEntry; Star: TStar; Other: TObject;
begin
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefactTranclucator) then Item := TArtefactTranclucator(ScriptUseItem)
  else
  begin
    if High(av) < 1 then Exit;
    if av[1].GetDword = 0 then Exit;
    if not (TObject(av[1].GetDword) is TArtefactTranclucator) then Exit;
    Item := TArtefactTranclucator(av[1].GetDword);
  end;
  if GetPlayer <> nil then
  begin
    Ship := TObject(Item.Ship) as TTranclucator;
    av[0].SetDword(Cardinal(Ship));
    if GetPlayer.InNormalSpace then
    begin
      SoundManager.PlaySound('Sound.UseATranc');
      Item.Ship := nil;
      Ship.CurrentStar := GetPlayer.CurrentStar;
      GetPlayer.CurrentStar.Ships.Add(Ship);
      Angle := SeededRandomIntRange(0, 360, Cardinal(Ship.Id) * (Cardinal(Galaxy.CurrentTurn) * GetPlayer.CurrentStar.GenerationSeed)) * Pi / 180;
      Ship.Position.X := GetPlayer.Position.X + Sin(Angle) * 100;
      Ship.Position.Y := GetPlayer.Position.Y - Cos(Angle) * 100;
      Ship.Graphic.SetPosition(Ship.Position);
      Ship.OwnerShip := GetPlayer;
      Index := GetPlayer.Artefacts.IndexOf(Item);
      if Index >= 0 then GetPlayer.Artefacts.Delete(Index);
      Index := GetPlayer.Inventory.IndexOf(Item);
      if Index >= 0 then GetPlayer.Inventory.Delete(Index);
      Item.Free;
      if ScriptUseItem = Item then ScriptUseItem := nil;
      GetPlayer.RefreshDerivedStats(True);
      Ship.NextDay;
      GetPlayer.AchievementStats.CheckTranclucatorFleetAchievement;
      Star := GetPlayer.CurrentStar;
      if GetPlayer.ChameleonActive then
        for Index := 0 to Star.Ships.Count - 1 do
        begin
          Other := TObject(Star.Ships[Index]);
          if (Other is TKling) and not TShip(Other).HasIndependentScriptFaction then TKling(Other).DetectAttackingPlayer(GetPlayer);
        end;
    end
    else if ShipScreen.TryDeployTranclucator(Ship) then
    begin
      Item.Ship := nil;
      Index := GetPlayer.Artefacts.IndexOf(Item);
      if Index >= 0 then GetPlayer.Artefacts.Delete(Index);
      Index := GetPlayer.Inventory.IndexOf(Item);
      if Index >= 0 then GetPlayer.Inventory.Delete(Index);
      for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
      begin
        Entry := PStorageEntry(GetPlayer.StorageEntries[Index]);
        if Entry.Item = Item then
        begin
          GetPlayer.StorageEntries.Delete(Index);
          GetPlayer.RefreshStorageBubbles;
          Dispose(Entry);
          Break;
        end;
      end;
      Item.Free;
      if ScriptUseItem = Item then ScriptUseItem := nil;
      GetPlayer.RefreshDerivedStats(True);
      SoundManager.PlaySound('Sound.UseATranc');
      ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseTranclucator'), mbgOK or mbgUnused04);
    end
    else
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.NotUseTranclucator'), mbgCancel or mbgUnused04);
    end;
  end;
end;
{ @end $6380C8 }

{ @routine $638654 SF_OnUseCodeTransmitter }
procedure SF_OnUseCodeTransmitter(av: array of TVarEC; code: TCodeEC);
var Artefact: TArtefactTransmitter; ShowFeedback: Boolean;
begin
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefactTransmitter) then Artefact := TArtefactTransmitter(ScriptUseItem)
  else
  begin
    if High(av) < 1 then Exit;
    if av[1].GetDword = 0 then Exit;
    if not (TObject(av[1].GetDword) is TArtefactTransmitter) then Exit;
    Artefact := TArtefactTransmitter(av[1].GetDword);
  end;
  if High(av) > 1 then ShowFeedback := av[2].GetInt <> 0 else ShowFeedback := True;
  if not (GetPlayer.InNormalSpace or not ShowFeedback) then
  begin
    SoundManager.PlaySound('Sound.NoMoney');
    ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseOnlyInSpace'), mbgCancel or mbgUnused04);
  end
  else if GetPlayer.UseDominatorTransmitter(Artefact) then
  begin
    if ShowFeedback then
    begin
      SoundManager.PlaySound('Sound.UseATranc');
      ShowMessageBoxGI(ShipScreen, FormatText1(LocalizedColorText('FormShip.UseTransmitter'), TextHighlightColorTag, '<Star>', GetPlayer.CurrentStar.Name), mbgCancel or mbgUnused04);
    end;
  end
  else if ShowFeedback then
  begin
    SoundManager.PlaySound('Sound.NoMoney');
    // The native failure message reads ScriptUseItem even when an explicit artefact was supplied.
    ShowMessageBoxGI(ShipScreen, FormatText1(LocalizedColorText('FormShip.NotUseTransmitter'), TextHighlightColorTag, '<Count>', WideString(IntToStr(MinTransmitterPower - (ScriptUseItem as TArtefactTransmitter).Power))), mbgCancel or mbgUnused04);
  end;
end;
{ @end $638654 }

{ @routine $6389F4 SF_OnUseCodeBlackHole }
procedure SF_OnUseCodeBlackHole(av: array of TVarEC; code: TCodeEC);
var Item: TArtefact; Index: Integer; Angle, Distance: Single; Hole: THole; Event: TGalaxyEvent;
begin
  av[0].SetDword(0);
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefact) then Item := TArtefact(ScriptUseItem)
  else
  begin
    if High(av) < 1 then Exit;
    if av[1].GetDword = 0 then Exit;
    if not (TObject(av[1].GetDword) is TArtefact) then Exit;
    Item := TArtefact(av[1].GetDword);
  end;
  if GetPlayer <> nil then
  begin
    if not GetPlayer.InNormalSpace then
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseOnlyInSpace'), mbgCancel or mbgUnused04);
    end
    else
    begin
      Index := GetPlayer.Artefacts.IndexOf(Item);
      if Index >= 0 then GetPlayer.Artefacts.Delete(Index);
      Index := GetPlayer.Inventory.IndexOf(Item);
      if Index >= 0 then GetPlayer.Inventory.Delete(Index);
      Item.Free;
      if ScriptUseItem = Item then ScriptUseItem := nil;
      GetPlayer.RefreshDerivedStats(True);
      Hole := THole.Create;
      av[0].SetDword(Cardinal(Hole));
      Hole.InitializeGraphic('');
      THoleSE(Hole.Graphic).SetState(1);
      Hole.Star1 := GetPlayer.CurrentStar;
      Angle := ArcTan2(GetPlayer.Position.X, -GetPlayer.Position.Y);
      Distance := Max(GetPlayer.CurrentStar.SafeRadius + 100, Sqrt(PointDistanceSquared(GetPlayer.Position, MakePointF(0, 0))) + 200);
      Hole.Position1 := MakePointF(Sin(Angle) * Distance, -Cos(Angle) * Distance);
      Hole.Star2 := nil;
      for Index := 0 to Galaxy.Stars.Count - 1 do
        if TStar(Galaxy.Stars[Index]).IsConstellationVisible then
        begin
          Distance := PointDistanceSquared(GetPlayer.CurrentStar.Position, TStar(Galaxy.Stars[Index]).Position);
          if (Distance > 400) and (Distance < 2500) then
            if (Hole.Star2 = nil) or (NextRandomIntRange(0, 100, GetPlayer.RandomState) < 50) then
            begin
              Hole.Star2 := TStar(Galaxy.Stars[Index]);
              if NextRandomIntRange(0, 100, GetPlayer.RandomState) < 20 then Break;
            end;
        end;
      if Hole.Star2 = nil then Hole.Star2 := GetPlayer.CurrentStar;
      Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
      Distance := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
      Hole.Position2 := MakePointF(Sin(Angle) * Distance, -Cos(Angle) * Distance);
      Hole.CreatedTurn := Galaxy.CurrentTurn;
      Hole.HoleType := 1;
      StarMapScreen.PendingHoleRefresh := Hole;
      Galaxy.Holes.Add(Hole);
      Event := AddGalaxyEvent('PlayerUsesSubportal');
      Event.AddData(Hole.Id);
      Event.AddData(Hole.CreatedTurn);
      Galaxy.PrimeIntegrityChecksum1(523);
      ShipScreen.CloseClicked(nil);
    end;
  end;
end;
{ @end $6389F4 }

{ @routine $638FAC SF_OnUseCodeMissileDef }
procedure SF_OnUseCodeMissileDef(av: array of TVarEC; code: TCodeEC);
var I: Integer;
begin
  if GetPlayer <> nil then
  begin
    if not GetPlayer.InNormalSpace then
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseOnlyInSpace'), mbgCancel or mbgUnused04);
    end
    else
    begin
      for I := 0 to GetPlayer.CurrentStar.Missiles.Count - 1 do
        with TMissile(GetPlayer.CurrentStar.Missiles[I]) do
          if GetPlayer = OwnerShip then FlightTicks := 10000;
      ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseMissileDef'), mbgCancel or mbgUnused04);
    end;
  end;
end;
{ @end $638FAC }

{ @routine $639168 SF_MessageBox }
procedure SF_MessageBox(av: array of TVarEC; code: TCodeEC);
var
  Options: Cardinal;
  OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MessageBox');
  if High(av) < 2 then Options := mbgCancel or mbgUnused04 else Options := av[2].GetInt;
  if High(av) < 3 then OffsetX := 0 else OffsetX := av[3].GetInt;
  if High(av) < 4 then OffsetY := 0 else OffsetY := av[4].GetInt;
  ShowMessageBoxGI(GetInnermostScreenLoop, av[1].GetString, Options, 0, OffsetX, OffsetY);
end;
{ @end $639168 }

{ @routine $63927C SF_MessageBoxYesNo }
procedure SF_MessageBoxYesNo(av: array of TVarEC; code: TCodeEC);
var
  Options: Cardinal;
  OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MessageBoxYesNo');
  if High(av) < 2 then Options := mbgOK or mbgCancel or mbgQuestion else Options := av[2].GetInt or mbgOK or mbgCancel;
  if High(av) < 3 then OffsetX := 0 else OffsetX := av[3].GetInt;
  if High(av) < 4 then OffsetY := 0 else OffsetY := av[4].GetInt;
  av[0].SetInt(0);
  if ShowMessageBoxGI(GetInnermostScreenLoop, av[1].GetString, Options, 0, OffsetX, OffsetY) = mbgResultOK then av[0].SetInt(1);
end;
{ @end $63927C }

{ @routine $6393C0 SF_CountBox }
procedure SF_CountBox(av: array of TVarEC; code: TCodeEC);
var
  Value: Integer;
  Caption, Description: WideString;
  Minimum, Maximum, Limit, UnitValue, Available, TotalLimit: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CountBox');
  // The native routine reads these strings here, then reads them again for the dialog call.
  Caption := av[1].GetString;
  Description := av[2].GetString;
  Minimum := av[3].GetInt;
  Maximum := av[4].GetInt;
  if High(av) > 4 then UnitValue := av[5].GetInt else UnitValue := 0;
  if High(av) > 6 then Limit := av[7].GetInt else Limit := Maximum;
  if High(av) > 7 then Available := av[8].GetInt else Available := Maximum;
  if High(av) > 8 then TotalLimit := av[9].GetInt else TotalLimit := 100000000;
  if High(av) > 9 then Value := av[10].GetInt else Value := Minimum;
  if ShowCountDialog(GetInnermostScreenLoop, 'GI,' + av[1].GetString, av[2].GetString, Minimum, Maximum, Limit, UnitValue, Available, TotalLimit, Value) = 1 then av[0].SetInt(Value)
  else av[0].SetString('Cancel');
end;
{ @end $6393C0 }

{ @routine $6395E0 SF_NumberBox }
procedure SF_NumberBox(av: array of TVarEC; code: TCodeEC);
var
  Value, Index: Integer;
  Caption, AlternateCaption, Description: WideString;
  Minimum, Maximum, Limit: Integer;
  Choices: TList;
  Entry: PWideString;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script NumberBox');
  Caption := 'GI,' + av[1].GetString;
  Description := av[2].GetString;
  Minimum := av[3].GetInt;
  Maximum := av[4].GetInt;
  if High(av) > 4 then Limit := av[5].GetInt else Limit := Maximum;
  if (High(av) > 5) and (av[6].GetString <> '') then AlternateCaption := 'GI,' + av[6].GetString
  else AlternateCaption := '';
  if High(av) > 6 then Value := av[7].GetInt else Value := Minimum;
  Choices := nil;
  if High(av) > 7 then
  begin
    Choices := TList.Create;
    if av[8].RealVType = vkArray then
      for Index := 0 to av[8].GetArray.Count - 1 do
      begin
        New(Entry);
        Entry^ := av[8].GetArray.GetItem(Index).GetString;
        Choices.Add(Entry);
      end
    else
      for Index := 8 to High(av) do
      begin
        New(Entry);
        Entry^ := av[Index].GetString;
        Choices.Add(Entry);
      end;
  end;
  if ShowNumberDialog(GetInnermostScreenLoop, Caption, AlternateCaption, Description, Minimum, Maximum, Limit, Choices, Value) = 1 then av[0].SetInt(Value)
  else av[0].SetString('Cancel');
  if Choices <> nil then
  begin
    while Choices.Count > 0 do
    begin
      // Native frees the pointer cell without finalizing its WideString.
      Dispose(Pointer(Choices[0]));
      Choices.Delete(0);
    end;
    Choices.Free;
  end;
end;
{ @end $6395E0 }

{ @routine $6398F8 SF_TextBox }
procedure SF_TextBox(av: array of TVarEC; code: TCodeEC);
var
  Caption, Value: WideString;
  MaximumLength, OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script TextBox');
  Caption := av[1].GetString;
  Value := '';
  if High(av) > 1 then Value := av[2].GetString;
  MaximumLength := 30;
  if High(av) > 2 then MaximumLength := av[3].GetInt;
  if High(av) < 4 then OffsetX := 0 else OffsetX := av[4].GetInt;
  if High(av) < 5 then OffsetY := 0 else OffsetY := av[5].GetInt;
  av[0].SetString(Value);
  if ShowTextInputDialog(GetInnermostScreenLoop, Caption, Value, MaximumLength, OffsetX, OffsetY) = 1 then av[0].SetString(Value);
end;
{ @end $6398F8 }

{ @routine $639A4C SF_ListBox }
procedure SF_ListBox(av: array of TVarEC; code: TCodeEC);
var
  Caption: WideString;
  Choices: TList;
  Index, OffsetX, OffsetY: Integer;
  Entry: PWideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ListBox');
  Caption := av[1].GetString;
  Choices := TList.Create;
  Index := -1;
  if av[2].RealVType = vkArray then
    for Index := 0 to av[2].GetArray.Count - 1 do
    begin
      New(Entry);
      Entry^ := av[2].GetArray.GetItem(Index).GetString;
      Choices.Add(Entry);
    end
  else
    for Index := 2 to High(av) do
    begin
      New(Entry);
      Entry^ := av[Index].GetString;
      Choices.Add(Entry);
    end;
  // The original scalar form also treats these argument positions as choices.
  if High(av) < 3 then OffsetX := 0 else OffsetX := av[3].GetInt;
  if High(av) < 4 then OffsetY := 0 else OffsetY := av[4].GetInt;
  if ShowListDialog(GetInnermostScreenLoop, Index, Caption, Choices, OffsetX, OffsetY) = 1 then av[0].SetInt(Index)
  else av[0].SetInt(-1);
  while Choices.Count > 0 do
  begin
    // Native frees the pointer cell without finalizing its WideString.
    Dispose(Pointer(Choices[0]));
    Choices.Delete(0);
  end;
  Choices.Free;
end;
{ @end $639A4C }

{ @routine $639C90 SF_FormCurShip }
procedure SF_FormCurShip(av: array of TVarEC; code: TCodeEC);
begin
  if GetInnermostScreenLoop = HangarScreen then av[0].SetDword(Cardinal(HangarScreen.SelectedShip))
  else if GetInnermostScreenLoop = ScannerScreen then av[0].SetDword(Cardinal(ScannerScreen.ShipToInspect))
  else if GetInnermostScreenLoop = ShipScreen then av[0].SetDword(Cardinal(PlayerHoldShip))
  else av[0].SetDword(0);
end;
{ @end $639C90 }

{ @routine $639D3C SF_UselessItemText }
procedure SF_UselessItemText(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Text: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script UselessItemText');
  Obj := TObject(av[1].GetDword);
  Item := nil;
  Text := '';
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item is TUselessItem then
    begin
      Text := (Item as TUselessItem).CustomText;
      if High(av) > 1 then (Item as TUselessItem).CustomText := av[2].GetString;
    end;
  av[0].SetString(Text);
end;
{ @end $639D3C }

{ @routine $639EA0 SF_UselessItemData }
procedure SF_UselessItemData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Value, Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script UselessItemData');
  Obj := TObject(av[1].GetDword);
  Index := av[2].GetInt;
  Item := nil;
  Value := 0;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if (Item is TUselessItem) and (Index > 0) and (Index <= 3) then
    begin
      Value := (Item as TUselessItem).Data[Index - 1];
      if High(av) > 2 then (Item as TUselessItem).Data[Index - 1] := av[3].GetInt;
    end;
  av[0].SetInt(Value);
end;
{ @end $639EA0 }

{ @routine $639FDC SF_GetAchievementSHU }
procedure SF_GetAchievementSHU(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('SHU');
end;
{ @end $639FDC }

{ @routine $63A01C SF_GetAchievementGIRLSHIRE }
procedure SF_GetAchievementGIRLSHIRE(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('GIRLSHIRE');
end;
{ @end $63A01C }

{ @routine $63A068 SF_GetAchievementGIRLSQUEST }
procedure SF_GetAchievementGIRLSQUEST(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('GIRLSQUEST');
end;
{ @end $63A068 }

{ @routine $63A0B8 SF_GetAchievementPIRATEWIN }
procedure SF_GetAchievementPIRATEWIN(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('PIRATEWIN');
end;
{ @end $63A0B8 }

{ @routine $63A104 SF_GetAchievementCOALLITION }
procedure SF_GetAchievementCOALLITION(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('COALLITION');
end;
{ @end $63A104 }

{ @routine $63A154 SF_GetAchievementHULL }
procedure SF_GetAchievementHULL(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('HULL');
end;
{ @end $63A154 }

{ @routine $63A198 SF_UICheckElement }
procedure SF_UICheckElement(av: array of TVarEC; code: TCodeEC);
var FormName, Path, Query: WideString; Form: TMessageLoopGI; Control: TObjectGI;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script UICheckElement');
  FormName := av[1].GetString;
  Path := av[2].GetString;
  Control := nil;
  if FormName = '' then Form := GetInnermostScreenLoop else Form := FindMessageLoop(FormName);
  if Form <> nil then Control := Form.FindControlByPath(Path);
  if Control = nil then raise Exception.Create('Error.Script UICheckElement - cant find ' + Path + ' (' + FormName + ')');
  Query := av[3].GetString;
  if Query = 'IsActive' then av[0].SetInt(Ord(Control.Active))
  else if Query = 'PosX' then av[0].SetInt(Control.LocalPosition.X)
  else if Query = 'PosY' then av[0].SetInt(Control.LocalPosition.Y)
  else if Query = 'SizeX' then av[0].SetInt(Control.ClientSize.X)
  else if Query = 'SizeY' then av[0].SetInt(Control.ClientSize.Y)
  else if Query = 'IsDisable' then
  begin
    if not (Control is TGraphButtonGI) then raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a button');
    av[0].SetInt(Ord(TGraphButtonGI(Control).Disabled));
  end
  else if Query = 'Text' then
  begin
    if Control is TEditGI then
    begin
      av[0].SetString(TEditGI(Control).Text);
      if High(av) > 3 then TEditGI(Control).SetText(av[4].GetString);
    end
    else if Control is TLabelGI then av[0].SetString(TLabelGI(Control).GetText)
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a label or edit');
  end
  else if Query = 'Help' then
  begin
    av[0].SetString(Control.HelpText);
    if High(av) > 3 then Control.HelpText := av[4].GetString;
  end
  else if Query = 'CursorPos' then
  begin
    if Control is TEditGI then
    begin
      av[0].SetInt(TEditGI(Control).CaretPosition);
      if High(av) > 3 then TEditGI(Control).SetCaretPosition(av[4].GetInt);
    end
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not an edit');
  end
  else if Query = 'IsFocused' then av[0].SetInt(Ord(Form.FocusedControl = Control))
  else if Query = 'Image' then
  begin
    if Control is TgaiGI then
    begin
      av[0].SetString(TgaiGI(Control).GetImagePath);
      if TgaiGI(Control).GetFirstFrameImagePath <> '' then
        av[0].SetString(av[0].GetString + '|' + TgaiGI(Control).GetFirstFrameImagePath);
    end
    else if Control is TgiGI then av[0].SetString(TgiGI(Control).GetImagePath)
    else if Control is TImageGI then av[0].SetString(TImageGI(Control).GetImagePath)
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a image');
  end
  else if Query = 'CurFrame' then
  begin
    if not (Control is TgaiGI) then raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a gai');
    av[0].SetInt(TgaiGI(Control).SequenceFrame);
    if High(av) > 3 then TgaiGI(Control).SetSequenceFrame(av[4].GetInt);
  end
  else if Query = 'IsDown' then
  begin
    if Control is TGraphButtonGI then
    begin
      av[0].SetInt(Ord(TGraphButtonGI(Control).Down));
      if High(av) > 3 then TGraphButtonGI(Control).SetDown(av[4].GetInt <> 0);
    end
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a button');
  end
  else if Query = 'Rescale' then
  begin
    if Control is TGraphBufGI then
    begin
      if High(av) < 4 then raise Exception.Create('Error.Script UICheckElement - Rescale option can not be used without image path');
      if (High(av) > 4) and (av[5].GetString = 'GI') then TGraphBufGI(Control).LoadScaledGiPath(av[4].GetString)
      else TGraphBufGI(Control).LoadScaledBitmapPathAsRgba(av[4].GetString);
    end
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a graph buffer');
  end
  else raise Exception.Create('Error.Script UICheckElement - query not recognized - ' + Query);
end;
{ @end $63A198 }

{ @routine $63AE2C SF_InterfaceState }
procedure SF_InterfaceState(av: array of TVarEC; code: TCodeEC);
var FormName, Path: WideString; I: Integer; Entry: TInterfaceStateOverride; Form: TMessageLoopGI; Control: TObjectGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script InterfaceState');
  FormName := av[1].GetString;
  Path := av[2].GetString;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      av[0].SetInt(Ord(Control.Active));
      if (Control is TGraphButtonGI) and TGraphButtonGI(Control).Disabled and Control.Active then av[0].SetInt(2);
      if High(av) > 2 then
      begin
        Control.SetActive(av[3].GetInt > 0);
        if (av[3].GetInt > 1) and (Control is TGraphButtonGI) then TGraphButtonGI(Control).SetDisabled(av[3].GetInt = 2);
      end;
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceStateOverrides.Count - 1 do
  begin
    Entry := TInterfaceStateOverride(Galaxy.InterfaceStateOverrides[I]);
    if (Entry.FormName = FormName) and (Entry.ControlPath = Path) then
    begin
      av[0].SetInt(Entry.GetState);
      if High(av) > 2 then
      begin
        if av[3].GetInt < 0 then
        begin
          Galaxy.InterfaceStateOverrides.Delete(I);
          Entry.Free;
        end
        else Entry.SetState(av[3].GetInt);
      end;
      Exit;
    end;
  end;
  av[0].SetInt(-1);
  if (High(av) > 2) and (av[3].GetInt >= 0) then
  begin
    Entry := TInterfaceStateOverride.Create;
    Galaxy.InterfaceStateOverrides.Add(Entry);
    Entry.Initialize(FormName, Path, av[3].GetInt);
  end;
end;
{ @end $63AE2C }

{ @routine $63B1D0 SF_InterfaceText }
procedure SF_InterfaceText(av: array of TVarEC; code: TCodeEC);
var FormName, Path: WideString; I: Integer; Entry: TInterfaceTextOverride; Form: TMessageLoopGI; Control: TObjectGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script InterfaceText');
  FormName := av[1].GetString;
  Path := av[2].GetString;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      if not (Control is TLabelGI) then raise Exception.Create('Object is not a label - ' + Path);
      av[0].SetString(TLabelGI(Control).GetText);
      if High(av) > 2 then TLabelGI(Control).SetText(av[3].GetString);
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceTextOverrides.Count - 1 do
  begin
    Entry := TInterfaceTextOverride(Galaxy.InterfaceTextOverrides[I]);
    if (Entry.FormName = FormName) and (Entry.ControlPath = Path) then
    begin
      av[0].SetString(Entry.GetText);
      if High(av) > 2 then
      begin
        if av[3].GetString = '' then
        begin
          Galaxy.InterfaceTextOverrides.Delete(I);
          Entry.Free;
        end
        else Entry.SetText(av[3].GetString);
      end;
      Exit;
    end;
  end;
  av[0].SetString('');
  if (High(av) > 2) and (av[3].GetString <> '') then
  begin
    Entry := TInterfaceTextOverride.Create;
    Galaxy.InterfaceTextOverrides.Add(Entry);
    Entry.Initialize(FormName, Path, av[3].GetString);
  end;
end;
{ @end $63B1D0 }

{ @routine $63B5B0 SF_InterfaceImage }
procedure SF_InterfaceImage(av: array of TVarEC; code: TCodeEC);
var FormName, Path: WideString; I: Integer; Entry: TInterfaceImageOverride; Form: TMessageLoopGI; Control: TObjectGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script InterfaceImage');
  FormName := av[1].GetString;
  Path := av[2].GetString;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      if Control is TgaiGI then
    begin
      av[0].SetString(TgaiGI(Control).GetImagePath);
      if TgaiGI(Control).GetFirstFrameImagePath <> '' then
        av[0].SetString(av[0].GetString + '|' + TgaiGI(Control).GetFirstFrameImagePath);
    end
      else if Control is TgiGI then av[0].SetString(TgiGI(Control).GetImagePath)
      else if Control is TImageGI then av[0].SetString(TImageGI(Control).GetImagePath)
      else av[0].SetString(Control.ConfigPath);
      if High(av) > 2 then
      begin
        if (CountDelimitedPartsW(av[3].GetString, ':') > 1) and
          (ExtractDelimitedPartW(av[3].GetString, 0, ':') = 'Style') then
          Control.SetConfigPath(ExtractDelimitedPartW(av[3].GetString, 1, ':'))
        else if Control is TgaiGI then begin
          if CountDelimitedPartsW(av[3].GetString, '|') < 2 then
            TgaiGI(Control).SetImagePath(av[3].GetString)
          else
          begin
            TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(av[3].GetString, 1, '|'));
            TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(av[3].GetString, 0, '|'));
          end;
          TgaiGI(Control).PrimeImageCaches;
          TgaiGI(Control).SequenceIndex := 0;
          TgaiGI(Control).UpdateAutoGeometry;
          TgaiGI(Control).RestartPlayback;
        end
        else if Control is TgiGI then TgiGI(Control).SetImagePath(av[3].GetString)
        else if Control is TImageGI then TImageGI(Control).SetImagePath(av[3].GetString)
        else raise Exception.Create('Object is not an image - ' + Path);
      end;
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceImageOverrides.Count - 1 do
  begin
    Entry := TInterfaceImageOverride(Galaxy.InterfaceImageOverrides[I]);
    if (Entry.FormName = FormName) and (Entry.ControlPath = Path) then
    begin
      av[0].SetString(Entry.GetImagePath);
      if High(av) > 2 then
      begin
        if av[3].GetString = '' then
        begin
          Galaxy.InterfaceImageOverrides.Delete(I);
          Entry.Free;
        end
        else Entry.SetImagePath(av[3].GetString);
      end;
      Exit;
    end;
  end;
  av[0].SetString('');
  if (High(av) > 2) and (av[3].GetString <> '') then
  begin
    Entry := TInterfaceImageOverride.Create;
    Galaxy.InterfaceImageOverrides.Add(Entry);
    Entry.Initialize(FormName, Path, av[3].GetString);
  end;
end;
{ @end $63B5B0 }

{ @routine $63BC64 SF_InterfacePos }
procedure SF_InterfacePos(av: array of TVarEC; code: TCodeEC);
var FormName, Path: WideString; I: Integer; X, Y, Z: Integer; Entry: TInterfacePosOverride; Form: TMessageLoopGI; Control: TObjectGI;
begin
  if High(av) < 5 then raise Exception.Create('Error.Script InterfacePos');
  FormName := av[1].GetString;
  Path := av[2].GetString;
  X := av[3].GetInt;
  Y := av[4].GetInt;
  Z := av[5].GetInt;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      Control.SetPosition(Point(X, Y));
      Control.SetDepth(Z);
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfacePositionOverrides.Count - 1 do
  begin
    Entry := TInterfacePosOverride(Galaxy.InterfacePositionOverrides[I]);
    if (Entry.FormName = FormName) and (Entry.ControlPath = Path) then
    begin
      if (X = 0) and (Y = 0) and (Z = 0) then
      begin
        Galaxy.InterfacePositionOverrides.Delete(I);
        Entry.Free;
      end
      else Entry.SetPosition(X, Y, Z);
      Exit;
    end;
  end;
  if (X <> 0) or (Y <> 0) or (Z <> 0) then
  begin
    Entry := TInterfacePosOverride.Create;
    Galaxy.InterfacePositionOverrides.Add(Entry);
    Entry.Initialize(FormName, Path, X, Y, Z);
  end;
end;
{ @end $63BC64 }

{ @routine $63BF80 SF_InterfaceSize }
procedure SF_InterfaceSize(av: array of TVarEC; code: TCodeEC);
var FormName, Path: WideString; I: Integer; X, Y: Integer; Entry: TInterfaceSizeOverride; Form: TMessageLoopGI; Control: TObjectGI;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script InterfaceSize');
  FormName := av[1].GetString;
  Path := av[2].GetString;
  X := av[3].GetInt;
  Y := av[4].GetInt;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      Control.SetSize(Point(X, Y));
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceSizeOverrides.Count - 1 do
  begin
    Entry := TInterfaceSizeOverride(Galaxy.InterfaceSizeOverrides[I]);
    if (Entry.FormName = FormName) and (Entry.ControlPath = Path) then
    begin
      if (X = 0) and (Y = 0) then
      begin
        Galaxy.InterfaceSizeOverrides.Delete(I);
        Entry.Free;
      end
      else Entry.SetSize(X, Y);
      Exit;
    end;
  end;
  if (X <> 0) or (Y <> 0) then
  begin
    Entry := TInterfaceSizeOverride.Create;
    Galaxy.InterfaceSizeOverrides.Add(Entry);
    Entry.Initialize(FormName, Path, X, Y);
  end;
end;
{ @end $63BF80 }

{ @routine $63C264 SF_ButtonClick }
procedure SF_ButtonClick(av: array of TVarEC; code: TCodeEC);
var FormName, Path: WideString; Control: TObjectGI; Form: TMessageLoopGI; Button: TGraphButtonGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ButtonClick');
  FormName := av[1].GetString;
  Path := av[2].GetString;
  if FormName = '' then Form := GetInnermostScreenLoop else Form := FindMessageLoop(FormName);
  if Form = nil then raise Exception.Create('Error.Script ButtonClick - ML not found');
  Control := Form.FindControlByPath(Path);
  if Control = nil then raise Exception.Create('Error.Script ButtonClick - Object not found');
  if not (Control is TGraphButtonGI) then raise Exception.Create('Error.Script ButtonClick - Object not a button');
  Button := Control as TGraphButtonGI;
  if (High(av) < 3) or (av[3].RealVType <> vkString) or (av[3].GetString = 'AllCode') then
  begin
    if Assigned(Button.UpCallback) then Button.UpCallback(Button)
    else if Assigned(Button.DownCallback) then Button.DownCallback(Button);
  end;
  if (High(av) > 2) and ((av[3].GetString = 'ScriptCode') or (av[3].GetString = 'AllCode')) then
    if Button.OnPressCode <> nil then
    begin
      Form.ExecuteUiCode(Button.OnPressCode, 0);
      Form.RefreshMouseDispatch;
    end;
end;
{ @end $63C264 }

{ @routine $63C580 SF_SetFocus }
procedure SF_SetFocus(av: array of TVarEC; code: TCodeEC);
var FormName, Path: WideString; Control: TObjectGI; Form: TMessageLoopGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetFocus');
  FormName := av[1].GetString;
  Path := av[2].GetString;
  if FormName = '' then Form := GetInnermostScreenLoop else Form := FindMessageLoop(FormName);
  if Form = nil then raise Exception.Create('Error.Script SetFocus - ML not found');
  Control := Form.FindControlByPath(Path);
  if Control = nil then raise Exception.Create('Error.Script SetFocus - Object not found');
  Form.SetFocusedControl(Control);
end;
{ @end $63C580 }

{ @routine $63C710 SF_FormShipCurItem }
procedure SF_FormShipCurItem(av: array of TVarEC; code: TCodeEC);
var Query: Integer; Item: TObject;
begin
  if GetInnermostScreenLoop <> ShipScreen then raise Exception.Create('Error.Script FormShipCurItem');
  if High(av) < 1 then
  begin
    if not (ShipScreen.SelectedHoldKind in [phkEquipment, phkArtefact]) then av[0].SetDword(0)
    else av[0].SetDword(Cardinal(ShipScreen.SelectedHoldItem));
    Exit;
  end;

  if av[1].RealVType = vkString then
  begin
    if av[1].GetString = 'MoveType' then Query := 0
    else if av[1].GetString = 'StackableType' then Query := 1
    else if av[1].GetString = 'StackableCount' then Query := 2
    else if av[1].GetString = 'StackableCost' then Query := 3
    else if av[1].GetString = 'PutBack' then Query := 4
    else if av[1].GetString = 'Destroy' then Query := 5
    else if av[1].GetString = 'Detach' then Query := 6
    else if av[1].GetString = 'Replace' then Query := 7
    else raise Exception.Create('Error.Script FormShipCurItem - query not recognized: ' + av[1].GetString);
  end
  // The native numeric-query path reads argument 3, without an additional arity check.
  else Query := av[3].GetInt;
  case Query of
    0: av[0].SetInt(Integer(ShipScreen.SelectedHoldKind));
    1: av[0].SetInt(ShipScreen.SelectedGoodsIndex);
    2: av[0].SetInt(ShipScreen.SelectedGoodsQuantity);
    3: av[0].SetInt(ShipScreen.SelectedGoodsCost);
    4: ShipScreen.ReturnSelectedHoldEntry;
    5: begin
      if ShipScreen.SelectedHoldItem <> nil then ShipScreen.SelectedHoldItem.Free;
      ShipScreen.SelectedHoldItem := nil;
      ShipScreen.SelectedHoldKind := phkEmpty;
      PlayerHoldShip.RefreshDerivedStats(True);
      if not ShipScreen.IsCursorImageSelected('Main') then ShipScreen.SetCursorByName('Main');
      ShipScreen.RefreshShipView;
    end;
    6: begin
      av[0].SetDword(Cardinal(ShipScreen.SelectedHoldItem));
      ShipScreen.SelectedHoldItem := nil;
      ShipScreen.SelectedHoldKind := phkEmpty;
      PlayerHoldShip.RefreshDerivedStats(True);
      if not ShipScreen.IsCursorImageSelected('Main') then ShipScreen.SetCursorByName('Main');
      ShipScreen.RefreshShipView;
    end;
    7: begin
      if (High(av) < 2) or (av[2].GetDword = 0) then raise Exception.Create('Error.Script FormShipCurItem no replacing item');
      if (ShipScreen.SelectedHoldItem = nil) or not (ShipScreen.SelectedHoldKind in [phkEquipment, phkArtefact]) then
        raise Exception.Create('Error.Script FormShipCurItem no item to replace');
      Item := TObject(av[2].GetDword);
      av[0].SetDword(Cardinal(ShipScreen.SelectedHoldItem));
      ShipScreen.SelectedHoldItem := TItem(Item);
      if Item is TArtefact then ShipScreen.SelectedHoldKind := phkArtefact else ShipScreen.SelectedHoldKind := phkEquipment;
      PlayerHoldShip.RefreshDerivedStats(True);
      ShipScreen.UpdateActionCursor(True);
      ShipScreen.RefreshShipView;
    end;
  else
    // Native creates this exception without raising or freeing it.
    Exception.Create('Error.Script FormShipCurItem - query not recognized: ' + IntToWideString(Query));
  end;
end;
{ @end $63C710 }

{ @routine $63CE78 SF_UpdateFormShip }
procedure SF_UpdateFormShip(av: array of TVarEC; code: TCodeEC);
begin
  if GetInnermostScreenLoop = ShipScreen then
  begin
    ShipScreen.ShipStateChanged := True;
    ShipScreen.ReopenRequested := True;
    ShipScreen.PlayTransitionSounds := False;
    ShipScreen.CloseClicked(nil);
  end;
end;
{ @end $63CE78 }

{ @routine $63CEEC SF_CurrentForm }
procedure SF_CurrentForm(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetString(GetInnermostScreenLoop.RegisteredLoopName);
end;
{ @end $63CEEC }

{ @routine $63CF28 SF_FormChange }
procedure SF_FormChange(av: array of TVarEC; code: TCodeEC);
var Id: TGameScreenId; Name: WideString;
begin
  if High(av) < 1 then
  begin
    if TMessageLoopGI(RegisteredScreens[RequestedScreenId]) = nil then av[0].SetString('')
    else av[0].SetString(TMessageLoopGI(RegisteredScreens[RequestedScreenId]).RegisteredLoopName);
    Exit;
  end;

  Name := av[1].GetString;
  for Id := screenNone to screenAchievements do
    if (TMessageLoopGI(RegisteredScreens[Id]) <> nil) and
      (TObject(RegisteredScreens[Id]) is TMessageLoopGI) and
      ((TObject(RegisteredScreens[Id]) as TMessageLoopGI).RegisteredLoopName = Name) then
    begin
      RequestedScreenId := Id;
      if TMessageLoopGI(RegisteredScreens[Id]) = ShipScreen then
      begin
        if High(av) >= 2 then ShipScreen.ShipToInspect := TShip(av[2].GetDword);
        ShipReturnScreenId := CurrentScreenId;
        if not ((CurrentScreenId <> screenStarMap) and
          (TMessageLoopGI(RegisteredScreens[CurrentScreenId]) is TMessageLoopGIWithMainPanel) and
          (TMessageLoopGIWithMainPanel(TMessageLoopGI(RegisteredScreens[CurrentScreenId])).MainPanel <> nil)) then
        begin
          ShipReturnScreenId := CurrentScreenId;
          GetInnermostScreenLoop.RequestClose(1);
        end
        else TMessageLoopGIWithMainPanel(TMessageLoopGI(RegisteredScreens[CurrentScreenId])).MainPanel.ShipClicked(nil);
      end
      else
      begin
        if TMessageLoopGI(RegisteredScreens[Id]) = ScannerScreen then
        begin
          if High(av) >= 2 then ScannerTarget := TObject(av[2].GetDword) else ScannerTarget := nil;
          ScannerReturnScreenId := FormToId(GetInnermostScreenLoop);
        end;
        GetInnermostScreenLoop.RequestClose(1);
      end;
      Exit;
    end;
  raise Exception.Create('Error.Script FormChange - ML not found');
end;
{ @end $63CF28 }

{ @routine $63D1D4 SF_RunChildForm }
procedure SF_RunChildForm(av: array of TVarEC; code: TCodeEC);
var Id: TGameScreenId; Name: WideString; Parent, Root, Child: TMessageLoopGI;
  Background, ChildBackground: TObjectGI; State: TCursorStateGI;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RunChildForm');
  Name := av[1].GetString;
  for Id := screenNone to screenAchievements do
  begin
    if not ((TMessageLoopGI(RegisteredScreens[Id]) <> nil) and
      (TObject(RegisteredScreens[Id]) is TMessageLoopGI) and
      ((TObject(RegisteredScreens[Id]) as TMessageLoopGI).RegisteredLoopName = Name)) then Continue;
    Child := TMessageLoopGI(RegisteredScreens[Id]);
    Parent := GetInnermostScreenLoop;
    ChildBackground := nil;
    Background := Child.FindControlByPath('BGBuf');
    if Background <> nil then
    begin
      CaptureScreenBackground(True, 0);
      (Background as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
    end
    else
    begin
      ChildBackground := Child.FindControlByPath('BGBufChild');
      if ChildBackground <> nil then
      begin
        CaptureScreenBackground(True, 0);
        (ChildBackground as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
        ChildBackground.SetActive(True);
      end;
    end;
    Parent.RootUiObject.OnModalSuspend;
    Parent.CaptureCursorState(@State);
    Parent.SetCursorActive(False);
    Parent.DrawQueuedUpdateRects;
    Child.ParentLoop := Parent;
    Parent.ChildLoop := Child;
    if (Child = GalaxyScreen) and (High(av) >= 2) then GalaxyScreen.ViewMode := av[2].GetInt;
    if Child.Run = 1 then av[0].SetInt(1) else av[0].SetInt(0);
    if ChildBackground <> nil then ChildBackground.SetActive(False);
    Child.ParentLoop := nil;
    Parent.ChildLoop := nil;
    if ((Background <> nil) or (ChildBackground <> nil)) and (Parent.ParentLoop <> nil) then
    begin
      Root := Parent.ParentLoop;
      while Root.ParentLoop <> nil do Root := Root.ParentLoop;
      FullFrameRedrawRequested := True;
      Root.DrawFrame;
      CaptureScreenBackground(True, 0);
    end;
    Parent.InvalidateViewport;
    Parent.RestoreCursorState(@State);
    Parent.UpdateCursorPosition;
    Parent.RootUiObject.OnModalResume;
    Parent.Present;
    PostMouseMoveMessage;
    Exit;
  end;
  raise Exception.Create('Error.Script RunChildForm - ML not found');
end;
{ @end $63D1D4 }

{ @routine $63D54C SF_OpenCustomForm }
procedure SF_OpenCustomForm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OpenCustomForm');
  av[0].SetInt(ShowCustomDialog(GetInnermostScreenLoop, av[1].GetString));
end;
{ @end $63D54C }

{ @routine $63D610 SF_CloseCustomForm }
procedure SF_CloseCustomForm(av: array of TVarEC; code: TCodeEC);
var
  ResultCode: Integer;
begin
  if CurrentCustomDialog = nil then raise Exception.Create('Error.Script CloseCustomForm - no custom form');
  if High(av) > 0 then ResultCode := av[1].GetInt else ResultCode := 1;
  CurrentCustomDialog.RequestClose(ResultCode);
end;
{ @end $63D610 }

{ @routine $63D6C0 SF_CustomInterfaceState }
procedure SF_CustomInterfaceState(av: array of TVarEC; code: TCodeEC);
var Control: TObjectGI; Form: TMessageLoopGI;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomInterfaceState');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfaceState - no custom form');
  Control := Form.FindControlByPath(av[1].GetString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfaceState - object not found');
  av[0].SetInt(Ord(Control.Active));
  if High(av) > 1 then Control.SetActive(av[2].GetInt > 0);
  if Control is TGraphButtonGI then
  begin
    if Control.Active then av[0].SetInt(Ord(TGraphButtonGI(Control).Disabled) + av[0].GetInt);
    if High(av) > 1 then TGraphButtonGI(Control).SetDisabled(av[2].GetInt = 2);
  end;
end;
{ @end $63D6C0 }

{ @routine $63D8C8 SF_CustomInterfaceText }
procedure SF_CustomInterfaceText(av: array of TVarEC; code: TCodeEC);
var Control: TObjectGI; Form: TMessageLoopGI;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomInterfaceText');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfaceText - no custom form');
  Control := Form.FindControlByPath(av[1].GetString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfaceText - object not found: ' + av[1].GetString);
  if Control is TLabelGI then av[0].SetString(TLabelGI(Control).GetText)
  else if Control is TEditGI then av[0].SetString(TEditGI(Control).Text)
  else raise Exception.Create('Error.Script CustomInterfaceText - object is not a label or edit: ' + av[1].GetString);
  if High(av) > 1 then
  begin
    if Control is TLabelGI then TLabelGI(Control).SetText(av[2].GetString)
    else if Control is TEditGI then TEditGI(Control).SetText(av[2].GetString);
  end;
end;
{ @end $63D8C8 }

{ @routine $63DC48 SF_CustomInterfaceImage }
procedure SF_CustomInterfaceImage(av: array of TVarEC; code: TCodeEC);
var Control: TObjectGI; Form: TMessageLoopGI;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomInterfaceImage');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfaceImage - no custom form');
  Control := Form.FindControlByPath(av[1].GetString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfaceImage - object not found: ' + av[1].GetString);
  if Control is TgaiGI then
    begin
      av[0].SetString(TgaiGI(Control).GetImagePath);
      if TgaiGI(Control).GetFirstFrameImagePath <> '' then
        av[0].SetString(av[0].GetString + '|' + TgaiGI(Control).GetFirstFrameImagePath);
    end
      else if Control is TgiGI then av[0].SetString(TgiGI(Control).GetImagePath)
      else if Control is TImageGI then av[0].SetString(TImageGI(Control).GetImagePath)
      else av[0].SetString(Control.ConfigPath);
  if High(av) > 1 then
  begin
    if (CountDelimitedPartsW(av[2].GetString, ':') > 1) and
          (ExtractDelimitedPartW(av[2].GetString, 0, ':') = 'Style') then
          Control.SetConfigPath(ExtractDelimitedPartW(av[2].GetString, 1, ':'))
        else if Control is TgaiGI then begin
          if CountDelimitedPartsW(av[2].GetString, '|') < 2 then
            TgaiGI(Control).SetImagePath(av[2].GetString)
          else
          begin
            TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(av[2].GetString, 1, '|'));
            TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(av[2].GetString, 0, '|'));
          end;
          TgaiGI(Control).PrimeImageCaches;
          TgaiGI(Control).SequenceIndex := 0;
          TgaiGI(Control).UpdateAutoGeometry;
          TgaiGI(Control).RestartPlayback;
        end
        else if Control is TgiGI then TgiGI(Control).SetImagePath(av[2].GetString)
        else if Control is TImageGI then TImageGI(Control).SetImagePath(av[2].GetString)
        else raise Exception.Create('Error.Script CustomInterfaceImage - object is not a image: ' + av[1].GetString);
  end;
end;
{ @end $63DC48 }

{ @routine $63E1DC SF_CustomInterfacePos }
procedure SF_CustomInterfacePos(av: array of TVarEC; code: TCodeEC);
var Control: TObjectGI; Form: TMessageLoopGI;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script CustomInterfacePos');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfacePos - no custom form');
  Control := Form.FindControlByPath(av[1].GetString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfacePos - object not found');
  Control.SetPosition(Point(av[2].GetInt, av[3].GetInt));
end;
{ @end $63E1DC }

{ @routine $63E37C SF_CustomInterfacePosZ }
procedure SF_CustomInterfacePosZ(av: array of TVarEC; code: TCodeEC);
var Control: TObjectGI; Form: TMessageLoopGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CustomInterfacePosZ');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfacePosZ - no custom form');
  Control := Form.FindControlByPath(av[1].GetString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfacePosZ - object not found');
  Control.SetDepth(av[2].GetInt);
end;
{ @end $63E37C }

{ @routine $63E514 SF_CustomInterfaceSize }
procedure SF_CustomInterfaceSize(av: array of TVarEC; code: TCodeEC);
var Control: TObjectGI; Form: TMessageLoopGI;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script CustomInterfacePos');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfacePos - no custom form');
  Control := Form.FindControlByPath(av[1].GetString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfacePos - object not found');
  Control.SetSize(Point(av[2].GetInt, av[3].GetInt));
end;
{ @end $63E514 }

{ @routine $63E6B4 SF_StarMapCenterView }
procedure SF_StarMapCenterView(av: array of TVarEC; code: TCodeEC);
var
  Position: TPointF;
  Index, Count: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarMapCenterView');
  Position.X := av[1].GetInt;
  Position.Y := av[2].GetInt;
  StarMapScreen.SetMapCenterManually(TruncatePointF(Position));
  SpaceViewPosition := Position;
  if (High(av) >= 3) and (TMessageLoopGI(RegisteredScreens[CurrentScreenId]) = StarMapScreen) then
  begin
    Count := av[3].GetInt;
    for Index := 0 to Count - 1 do
      StarMapScreen.AddMapAnimation(Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 200 * Index);
  end;
end;
{ @end $63E6B4 }

{ @routine $63E85C SF_StarMapCurPosX }
procedure SF_StarMapCurPosX(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(StarMapScreen.GetMapCenter.X);
end;
{ @end $63E85C }

{ @routine $63E8A4 SF_StarMapCurPosY }
procedure SF_StarMapCurPosY(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(StarMapScreen.GetMapCenter.Y);
end;
{ @end $63E8A4 }

{ @routine $63E8EC SF_StarMapCustomSelectionMode }
procedure SF_StarMapCustomSelectionMode(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 10 then raise Exception.Create('Error.Script StarMapCustomSelectionMode');
  if GetInnermostScreenLoop = StarMapScreen then
  begin
    if av[1].RealVType = vkString then
    begin
      StarMapScreen.CustomSelectionInfoName := av[1].GetString;
      StarMapScreen.CustomSelectionItem := nil;
    end
    else
    begin
      StarMapScreen.CustomSelectionInfoName := '';
      StarMapScreen.CustomSelectionItem := TItem(av[1].GetDword);
    end;
    StarMapScreen.CustomSelectionRadius := av[2].GetInt;
    StarMapScreen.CustomSelectionAllowedCursor := av[3].GetString;
    StarMapScreen.CustomSelectionDeniedCursor := av[4].GetString;
    StarMapScreen.CustomSelectionSuccessText := av[5].GetString;
    StarMapScreen.CustomSelectionOutOfRangeText := av[6].GetString;
    StarMapScreen.CustomSelectionFailureText := av[7].GetString;
    StarMapScreen.CustomSelectionColor := CurrentPixelFormat.PackRgb(av[8].GetInt, av[9].GetInt, av[10].GetInt);
    StarMapScreen.BeginCustomSelection;
  end;
end;
{ @end $63E8EC }

{ @routine $63EB30 SF_StarMapBlinkingMessage }
procedure SF_StarMapBlinkingMessage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script StarMapBlinkingMessage');
  StarMapScreen.ShowLargeHelp(av[1].GetString);
end;
{ @end $63EB30 }

{ @routine $63EBF0 SF_BlinkingWarning }
procedure SF_BlinkingWarning(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script BlinkingWarning');
  if av[1].GetString = 'Money' then
  begin
    if CurrentScreenId = screenShip then ShipScreen.StartMoneyWarning
    else if (CurrentScreenId = screenGoodsShop) and GetPlayer.InNormalSpace then GoodsShopScreen.FlashMoneyWarning
    else if TMessageLoopGI(RegisteredScreens[CurrentScreenId]) is TMessageLoopGIWithMainPanel then
      TMessageLoopGIWithMainPanel(TMessageLoopGI(RegisteredScreens[CurrentScreenId])).MainPanel.FlashMoneyWarning;
  end
  else if (av[1].GetString = 'Space') and (CurrentScreenId <> screenShip) then
  begin
    if (CurrentScreenId = screenGoodsShop) and GetPlayer.InNormalSpace then GoodsShopScreen.FlashCargoWarning
    else if TMessageLoopGI(RegisteredScreens[CurrentScreenId]) is TMessageLoopGIWithMainPanel then
      TMessageLoopGIWithMainPanel(TMessageLoopGI(RegisteredScreens[CurrentScreenId])).MainPanel.FlashCargoWarning;
  end;
end;
{ @end $63EBF0 }

{ @routine $63EDEC SF_CustomWeaponTypes }
procedure SF_CustomWeaponTypes(av: array of TVarEC; code: TCodeEC);
var Index: Integer;
begin
  if High(av) < 1 then av[0].SetInt(Galaxy.CustomWeaponTypes.Count)
  else
  begin
    Index := av[1].GetInt;
    if (Index >= 0) and (Galaxy.CustomWeaponTypes.Count > Index) then
      av[0].SetString(PWeaponInfo(Galaxy.CustomWeaponTypes[Index]).ConfigName)
    else av[0].SetString('');
  end;
end;
{ @end $63EDEC }

{ @routine $63EE94 SF_InventNewCustomWeapon }
procedure SF_InventNewCustomWeapon(av: array of TVarEC; code: TCodeEC);
var Info, Base: PWeaponInfo; Kind: Byte; I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script InventNewCustomWeapon');
  Info := Galaxy.GetOrCreateCustomWeaponInfo(av[1].GetString);
  av[0].SetDword(Cardinal(Info));
  if High(av) > 1 then Kind := av[2].GetInt else Kind := Ord(t_IndustrialLaser);
  if not (Kind in [Ord(t_IndustrialLaser)..Ord(t_Lirecron)]) then raise Exception.Create(AnsiString('Error.Script InventNewCustomWeapon - invalid type ' + av[2].GetString));
  Base := @WeaponInfos[TItemType(Kind)];
  Info.TechLevel := Base.TechLevel;
  Info.InventionIndex := Base.InventionIndex;
  Info.CostFactor := Base.CostFactor;
  Info.MinDamage := Base.MinDamage;
  Info.MaxDamage := Base.MaxDamage;
  Info.AverageSize := Base.AverageSize;
  Info.AverageRange := Base.AverageRange;
  Info.ShotSpeedPercent := Base.ShotSpeedPercent;
  Info.MissileRange := Base.MissileRange;
  Info.MissileMaxSpeed := Base.MissileMaxSpeed;
  Info.MissileMinSpeed := Base.MissileMinSpeed;
  Info.MissileChanceToBeHit := Base.MissileChanceToBeHit;
  Info.DamageFlags := Base.DamageFlags;
  Info.ShotType := Base.ShotType;
  Info.ShotCount := Base.ShotCount;
  Info.AttackCount := Base.AttackCount;
  Info.SecondaryDamageRadius := Base.SecondaryDamageRadius;
  Info.MiningFactor := Base.MiningFactor;
  Info.PrimarySE := Base.PrimarySE;
  Info.SecondarySE := Base.SecondarySE;
  Info.AreaSE := Base.AreaSE;
  Info.DefaultPalette := Base.DefaultPalette;
  Info.Availability := Base.Availability;
  Info.ArcadeWeaponType := Base.ArcadeWeaponType;
  for I := 1 to 8 do Info.DamageScaleByLevel[I] := Base.DamageScaleByLevel[I];
end;
{ @end $63EE94 }

{ @routine $63F1BC SF_GetCustomWeaponInfo }
procedure SF_GetCustomWeaponInfo(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetCustomWeaponInfo');
  av[0].SetDword(Cardinal(Galaxy.RequireCustomWeaponInfo(av[1].GetString)));
end;
{ @end $63F1BC }

{ @routine $63F288 SF_GetCustomWeaponData }
procedure SF_GetCustomWeaponData(av: array of TVarEC; code: TCodeEC);
var Info: PWeaponInfo; Key: WideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetCustomWeaponStats');
  if av[1].RealVType = vkString then Info := Galaxy.RequireCustomWeaponInfo(av[1].GetString)
  else Info := @WeaponInfos[TItemType(av[1].GetInt)];
  Key := av[2].GetString;
  if Key = 'TechLevel' then av[0].SetInt(Info.TechLevel)
  else if Key = 'AverageSize' then av[0].SetInt(Info.AverageSize)
  else if Key = 'AverageRadius' then av[0].SetInt(Info.AverageRange)
  else if Key = 'MissileRadius' then av[0].SetInt(Info.MissileRange)
  else if Key = 'SecondaryDamageRadius' then av[0].SetFloat(Info.SecondaryDamageRadius)
  else if Key = 'MaxDamage' then av[0].SetInt(Info.MaxDamage)
  else if Key = 'MinDamage' then av[0].SetInt(Info.MinDamage)
  else if Key = 'DamageType' then av[0].SetDword(Dword(Info.DamageFlags))
  else if Key = 'kCost' then av[0].SetFloat(Info.CostFactor)
  else if Key = 'AttackCount' then av[0].SetInt(Info.AttackCount)
  else if Key = 'ShotCount' then av[0].SetInt(Info.ShotCount)
  else if Key = 'ShotType' then
    case Info.ShotType of
      wstNormal: av[0].SetString('Normal');
      wstSplash: av[0].SetString('Splash');
      wstExploder: av[0].SetString('Exploder');
      wstAreaDamage: av[0].SetString('AreaDamage');
      wstTorpedo: av[0].SetString('Torpedo');
      wstMissile: av[0].SetString('Missile');
      wstRocket: av[0].SetString('Rocket');
      wstChain: av[0].SetString('Chain');
    end
  else if Key = 'Availability' then
    case Info.Availability of
      waFree: av[0].SetString('Free');
      waCoalitionOnly: av[0].SetString('CoalitionOnly');
      waPirateOnly: av[0].SetString('PirateOnly');
      waNotSold: av[0].SetString('NotSold');
      waNotSoldAndNodeRepair: av[0].SetString('NotSoldAndNodeRepair');
      waMalocOnly: av[0].SetString('MalocOnly');
      waPelengOnly: av[0].SetString('PelengOnly');
      waPeopleOnly: av[0].SetString('PeopleOnly');
      waFeiOnly: av[0].SetString('FeiOnly');
      waGaalOnly: av[0].SetString('GaalOnly');
      waSystemOnly: av[0].SetString('SystemOnly');
    else raise Exception.Create('Error.Script GetCustomWeaponStats - unknown availability type');
    end
  else raise Exception.Create(AnsiString('Error.Script GetCustomWeaponStats - unknown stat ' + Key));
end;
{ @end $63F288 }

{ @routine $63FB94 SF_GetCustomWeaponPrimaryDamageType }
procedure SF_GetCustomWeaponPrimaryDamageType(av: array of TVarEC; code: TCodeEC);
var Info: PWeaponInfo;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetCustomWeaponPrimaryDamageType');
  if av[1].RealVType = vkString then Info := Galaxy.RequireCustomWeaponInfo(av[1].GetString)
  else Info := @WeaponInfos[TItemType(av[1].GetInt)];
  av[0].SetInt(Ord(ClassifyWeaponDamageFlags(Info.DamageFlags)));
end;
{ @end $63FB94 }

{ @routine $63FCB4 SF_SetCustomWeaponAvailability }
procedure SF_SetCustomWeaponAvailability(av: array of TVarEC; code: TCodeEC);
var Info: PWeaponInfo; Text: WideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetCustomWeaponAvailability');
  Info := PWeaponInfo(av[1].GetDword);
  av[0].SetDword(Cardinal(Info));
  Text := av[2].GetString;
  if Text = 'Free' then Info.Availability := waFree
  else if Text = 'CoalitionOnly' then Info.Availability := waCoalitionOnly
  else if Text = 'PirateOnly' then Info.Availability := waPirateOnly
  else if Text = 'NotSold' then Info.Availability := waNotSold
  else if Text = 'NotSoldAndNodeRepair' then Info.Availability := waNotSoldAndNodeRepair
  else if Text = 'MalocOnly' then Info.Availability := waMalocOnly
  else if Text = 'PelengOnly' then Info.Availability := waPelengOnly
  else if Text = 'PeopleOnly' then Info.Availability := waPeopleOnly
  else if Text = 'FeiOnly' then Info.Availability := waFeiOnly
  else if Text = 'GaalOnly' then Info.Availability := waGaalOnly
  else if Text = 'SystemOnly' then Info.Availability := waSystemOnly
  else Info.Availability := waFree;
end;
{ @end $63FCB4 }

{ @routine $63FFD0 SF_SetCustomWeaponPrimaryData }
procedure SF_SetCustomWeaponPrimaryData(av: array of TVarEC; code: TCodeEC);
var Info: PWeaponInfo;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script SetCustomWeaponPrimaryData');
  Info := PWeaponInfo(av[1].GetDword);
  av[0].SetDword(Cardinal(Info));
  Info.TechLevel := av[2].GetInt;
  if not (TItemType(av[3].GetInt) in [t_IndustrialLaser..t_Lirecron]) then
    raise Exception.Create('Error.Script SetCustomWeaponPrimaryData invalid tech');
  Info.InventionIndex := WeaponInfos[TItemType(av[3].GetInt)].InventionIndex;
  Info.ArcadeWeaponType := av[4].GetInt;
end;
{ @end $63FFD0 }

{ @routine $640114 SF_SetCustomWeaponSizeAndCost }
procedure SF_SetCustomWeaponSizeAndCost(av: array of TVarEC; code: TCodeEC);
var Info: PWeaponInfo;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script SetCustomWeaponSizeAndCost');
  Info := PWeaponInfo(av[1].GetDword);
  av[0].SetDword(Cardinal(Info));
  Info.CostFactor := av[2].GetFloat;
  Info.AverageSize := av[3].GetInt;

end;
{ @end $640114 }

{ @routine $6401C8 SF_SetCustomWeaponDamageData }
procedure SF_SetCustomWeaponDamageData(av: array of TVarEC; code: TCodeEC);
const EmptyFlags = [];
var Info: PWeaponInfo; Flag: Byte; Flags: TDamageFlagSet; I, Count: Integer; Text: WideString;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script SetCustomWeaponDamageData');
  Info := PWeaponInfo(av[1].GetDword);
  av[0].SetDword(Cardinal(Info));
  Info.MinDamage := av[2].GetInt;
  Info.MaxDamage := av[3].GetInt;
  Flags := EmptyFlags;
  if av[4].RealVType = vkString then
  begin
    Text := ',' + av[4].GetString + ',';
    for Flag := Low(WeaponDamageFlagNames) to High(WeaponDamageFlagNames) do
      if Pos(',' + WeaponDamageFlagNames[Flag] + ',', Text) > 0 then Include(Flags, TDamageKind(Flag));
  end
  else Dword(Flags) := av[4].GetDword;
  Info.DamageFlags := Flags;
  if (High(av) > 4) and (av[5].RealVType = vkString) then
  begin
    Text := av[5].GetString;
    Count := CountDelimitedPartsW(Text, ',');
    for I := 1 to Min(8, Count) do
      Info.DamageScaleByLevel[I] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, I - 1, ','));
  end
  else
    for I := 1 to Min(8, High(av) - 4) do
      if not (av[4 + I].RealVType in [vkInt, vkDword]) or (av[4 + I].GetInt <> 0) then
        Info.DamageScaleByLevel[I] := av[4 + I].GetFloat;
end;
{ @end $6401C8 }

{ @routine $640484 SF_SetCustomWeaponShotData }
procedure SF_SetCustomWeaponShotData(av: array of TVarEC; code: TCodeEC);
var Info: PWeaponInfo; Text: WideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetCustomWeaponShotData');
  Info := PWeaponInfo(av[1].GetDword);
  av[0].SetDword(Cardinal(Info));
  Text := av[2].GetString;
  Info.ShotType := wstNormal;
  Info.ShotCount := 1;
  if Pos('Normal', Text) <= 0 then
  begin
    if Pos('Splash', Text) > 0 then Info.ShotType := wstSplash
    else if Pos('Exploder', Text) > 0 then Info.ShotType := wstExploder
    else if Pos('AreaDamage', Text) > 0 then Info.ShotType := wstAreaDamage
    else if Pos('Torpedo', Text) > 0 then Info.ShotType := wstTorpedo
    else if Pos('Missile', Text) > 0 then Info.ShotType := wstMissile
    else if Pos('Rocket', Text) > 0 then Info.ShotType := wstRocket
    else if Pos('Chain', Text) > 0 then Info.ShotType := wstChain;
  end;
  if Info.ShotType in [wstChain, wstMissile, wstRocket] then Info.ShotCount := ExtractDigitsToIntW(Text);
  if High(av) > 2 then Info.ShotSpeedPercent := av[3].GetInt;
  if High(av) > 3 then Info.AverageRange := av[4].GetInt;
  if High(av) > 4 then Info.SecondaryDamageRadius := av[5].GetInt;
  if High(av) > 5 then Info.MiningFactor := av[6].GetFloat;
  if High(av) > 6 then Info.AttackCount := av[7].GetInt;

end;
{ @end $640484 }

{ @routine $640774 SF_SetCustomMissileWeaponStats }
procedure SF_SetCustomMissileWeaponStats(av: array of TVarEC; code: TCodeEC);
var Info: PWeaponInfo;
begin
  if High(av) < 5 then raise Exception.Create('Error.Script SetCustomMissileWeaponStats');
  Info := PWeaponInfo(av[1].GetDword);
  av[0].SetDword(Cardinal(Info));
  Info.MissileRange := av[2].GetInt;
  Info.MissileMaxSpeed := av[3].GetInt;
  Info.MissileMinSpeed := av[4].GetInt;
  Info.MissileChanceToBeHit := av[5].GetInt;

end;
{ @end $640774 }

{ @routine $640850 SF_SetCustomWeaponSE }
procedure SF_SetCustomWeaponSE(av: array of TVarEC; code: TCodeEC);
var Info: PWeaponInfo;
begin
  if High(av) < 5 then raise Exception.Create('Error.Script SetCustomWeaponSE');
  Info := PWeaponInfo(av[1].GetDword);
  av[0].SetDword(Cardinal(Info));
  Info.PrimarySE := av[2].GetString;
  Info.SecondarySE := av[3].GetString;
  Info.AreaSE := av[4].GetString;
  Info.DefaultPalette := av[5].GetInt;

end;
{ @end $640850 }

{ @routine $64097C SF_StarCustomFaction }
procedure SF_StarCustomFaction(av: array of TVarEC; code: TCodeEC);
var Obj: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarCustomFaction');
  Obj := TStar(av[1].GetDword);
  av[0].SetString(Obj.Status.CustomFaction);
  if High(av) > 1 then
  begin
    Obj.Status.CustomFaction := av[2].GetString;
    if av[2].GetString = '' then Obj.ResetControlFaction;
  end;
end;
{ @end $64097C }

{ @routine $640A84 SF_ShipCustomFaction }
procedure SF_ShipCustomFaction(av: array of TVarEC; code: TCodeEC);
var Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipCustomFaction');
  Ship := TShip(av[1].GetDword);
  if GetPlayer = Ship then
  begin
    if High(av) > 1 then raise Exception.Create('Error.Script ShipCustomFaction Player');
    av[0].SetString('');
  end
  else if Ship.ScriptShip = nil then
  begin
    if High(av) > 1 then raise Exception.Create('Error.Script ShipCustomFaction non-script ship');
    av[0].SetString('');
  end
  else
  begin
    av[0].SetString(TScriptShip(Ship.ScriptShip).StateText);
    if High(av) > 1 then
    begin
      TScriptShip(Ship.ScriptShip).StateText := av[2].GetString;
      Ship.RefreshCurrentStanding;
    end;
  end;
end;
{ @end $640A84 }

{ @routine $640C4C SF_EqCustomFaction }
procedure SF_EqCustomFaction(av: array of TVarEC; code: TCodeEC);
var Obj: TEquipment;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EqCustomFaction');
  Obj := TEquipment(av[1].GetDword);
  av[0].SetString(Obj.CustomFaction);
  if High(av) > 1 then
  begin
    Obj.CustomFaction := av[2].GetString;
  end;
end;
{ @end $640C4C }

{ @routine $640D2C SF_PlanetCustomFaction }
procedure SF_PlanetCustomFaction(av: array of TVarEC; code: TCodeEC);
var Obj: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetCustomFaction');
  Obj := TPlanet(av[1].GetDword);
  av[0].SetString(Obj.CustomFaction);
  if High(av) > 1 then
  begin
    Obj.CustomFaction := av[2].GetString;
  end;
end;
{ @end $640D2C }

{ @routine $640E14 SF_ImportedFunction }
procedure SF_ImportedFunction(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ImportedFunction');
  av[0].ConvertToKind(vkLibraryFun);
  av[0].SetString(av[1].GetString + ',' + av[2].GetString);
  if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
  ScriptLibraryCache.InitFunction(av[0]);
end;
{ @end $640E14 }

{ @routine $640F44 SF_ImportAll }
procedure SF_ImportAll(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ImportAll');
  if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
  ScriptLibraryCache.GetLib(av[1].GetString).InitAllFunctions(code.LocalVar);
  code.LinkAll(code.LocalVar, False);
end;
{ @end $640F44 }

{ @routine $641030 SF_GalaxyPtr }
procedure SF_GalaxyPtr(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then av[0].SetDword(Cardinal(Galaxy))
  else if av[1].GetString = 'StarCnt' then av[0].SetDword(Cardinal(@GalaxyStarCount))
  else raise Exception.Create('Error.Script GalaxyPtr, unknown value ' + av[1].GetString);
end;
{ @end $641030 }

{ @routine $641194 InitializeScriptBuiltinsAndConstants }
procedure InitializeScriptBuiltinsAndConstants(Scope: TVarArrayEC);
var
  WeaponIndex: Integer;
  ActionIndex: TScriptActionType;
  BonusIndex: TEquipmentBonusKind;
begin
  RegisterExpressionBuiltins(Scope);
  Scope.Add('GRun', vkExternFun).SetExternFun(@SF_GRun);
  Scope.Add('GCntRun', vkExternFun).SetExternFun(@SF_GCntRun);
  Scope.Add('GLastTurnRun', vkExternFun).SetExternFun(@SF_GLastTurnRun);
  Scope.Add('GAllCntRun', vkExternFun).SetExternFun(@SF_GAllCntRun);
  Scope.Add('IsScriptActive', vkExternFun).SetExternFun(@SF_IsScriptActive);
  Scope.Add('GetValueFromScript', vkExternFun).SetExternFun(@SF_GetValueFromScript);
  Scope.Add('RunFunctionFromScript', vkExternFun).SetExternFun(@SF_RunFunctionFromScript);
  Scope.Add('GetVariableName', vkExternFun).SetExternFun(@SF_GetVariableName);
  Scope.Add('GetVariableType', vkExternFun).SetExternFun(@SF_GetVariableType);
  Scope.Add('StatusPlayer', vkExternFun).SetExternFun(@SF_StatusPlayer);
  Scope.Add('AddPlanetNews', vkExternFun).SetExternFun(@SF_AddPlanetNews);
  Scope.Add('AddJournalRecord', vkExternFun).SetExternFun(@SF_AddJournalRecord);
  Scope.Add('AutoBattle', vkExternFun).SetExternFun(@SF_AutoBattle);
  Scope.Add('GetOwner', vkExternFun).SetExternFun(@SF_GetOwner);
  Scope.Add('GiveReward', vkExternFun).SetExternFun(@SF_GiveReward);
  Scope.Add('GiveRewardByNom', vkExternFun).SetExternFun(@SF_GiveRewardByNom);
  Scope.Add('CountReward', vkExternFun).SetExternFun(@SF_CountReward);
  Scope.Add('CountRewardByNom', vkExternFun).SetExternFun(@SF_CountRewardByNom);
  Scope.Add('DeleteRewardByNom', vkExternFun).SetExternFun(@SF_DeleteRewardByNom);
  Scope.Add('Rnd', vkExternFun).SetExternFun(@SF_Rnd);
  Scope.Add('GameDateTxtByTurn', vkExternFun).SetExternFun(@SF_GameDateTxtByTurn);
  Scope.Add('Id', vkExternFun).SetExternFun(@SF_Id);
  Scope.Add('SetName', vkExternFun).SetExternFun(@SF_SetName);
  Scope.Add('UseTranclucator', vkExternFun).SetExternFun(@SF_UseTranclucator);
  Scope.Add('HullDamage', vkExternFun).SetExternFun(@SF_HullDamage);
  Scope.Add('Hitpoints', vkExternFun).SetExternFun(@SF_Hitpoints);
  Scope.Add('Hit', vkExternFun).SetExternFun(@SF_Hit);
  Scope.Add('ChangeGlobalRelationsShips', vkExternFun).SetExternFun(@SF_ChangeGlobalRelationsShips);
  Scope.Add('ChangeGlobalRelationsPlanets', vkExternFun).SetExternFun(@SF_ChangeGlobalRelationsPlanets);
  Scope.Add('GlobalRelationsShips', vkExternFun).SetExternFun(@SF_GlobalRelationsShips);
  Scope.Add('GlobalRelationsPlanets', vkExternFun).SetExternFun(@SF_GlobalRelationsPlanets);
  Scope.Add('SetRelationGroup', vkExternFun).SetExternFun(@SF_SetRelationGroup);
  Scope.Add('SetRelationPlanet', vkExternFun).SetExternFun(@SF_SetRelationPlanet);
  Scope.Add('GetRelationPlanet', vkExternFun).SetExternFun(@SF_GetRelationPlanet);
  Scope.Add('CurTurn', vkExternFun).SetExternFun(@SF_CurTurn);
  Scope.Add('ShipType', vkExternFun).SetExternFun(@SF_ShipType);
  Scope.Add('ConName', vkExternFun).SetExternFun(@SF_ConName);
  Scope.Add('StarName', vkExternFun).SetExternFun(@SF_StarName);
  Scope.Add('StarMapLabel', vkExternFun).SetExternFun(@SF_StarMapLabel);
  Scope.Add('PlanetName', vkExternFun).SetExternFun(@SF_PlanetName);
  Scope.Add('IdToPlanet', vkExternFun).SetExternFun(@SF_IdToPlanet);
  Scope.Add('IdToShip', vkExternFun).SetExternFun(@SF_IdToShip);
  Scope.Add('IdToItem', vkExternFun).SetExternFun(@SF_IdToItem);
  Scope.Add('PlanetSetGoods', vkExternFun).SetExternFun(@SF_PlanetSetGoods);
  Scope.Add('ShipName', vkExternFun).SetExternFun(@SF_ShipName);
  Scope.Add('ShipRank', vkExternFun).SetExternFun(@SF_ShipRank);
  Scope.Add('ShipRankPoints', vkExternFun).SetExternFun(@SF_ShipRankPoints);
  Scope.Add('ShipNextRankPoints', vkExternFun).SetExternFun(@SF_ShipNextRankPoints);
  Scope.Add('ShipRaiseRank', vkExternFun).SetExternFun(@SF_ShipRaiseRank);
  Scope.Add('ShipStar', vkExternFun).SetExternFun(@SF_ShipStar);
  Scope.Add('StarToCon', vkExternFun).SetExternFun(@SF_StarToCon);
  Scope.Add('ConNear', vkExternFun).SetExternFun(@SF_ConNear);
  Scope.Add('ConStars', vkExternFun).SetExternFun(@SF_ConStars);
  Scope.Add('ConStar', vkExternFun).SetExternFun(@SF_ConStar);
  Scope.Add('GalaxyStars', vkExternFun).SetExternFun(@SF_GalaxyStars);
  Scope.Add('GalaxyStar', vkExternFun).SetExternFun(@SF_GalaxyStar);
  Scope.Add('StarAngleBetween', vkExternFun).SetExternFun(@SF_StarAngleBetween);
  Scope.Add('FindPlanet', vkExternFun).SetExternFun(@SF_FindPlanet);
  Scope.Add('IsPlayer', vkExternFun).SetExternFun(@SF_IsPlayer);
  Scope.Add('GroupCount', vkExternFun).SetExternFun(@SF_GroupCount);
  Scope.Add('GroupIn', vkExternFun).SetExternFun(@SF_GroupIn);
  Scope.Add('CountIn', vkExternFun).SetExternFun(@SF_CountIn);
  Scope.Add('ChangeState', vkExternFun).SetExternFun(@SF_ChangeState);
  Scope.Add('NearestGroup', vkExternFun).SetExternFun(@SF_NearestGroup);
  Scope.Add('StarAngle', vkExternFun).SetExternFun(@SF_StarAngle);
  Scope.Add('NewsAdd', vkExternFun).SetExternFun(@SF_NewsAdd);
  Scope.Add('MsgAdd', vkExternFun).SetExternFun(@SF_MsgAdd);
  Scope.Add('Ether', vkExternFun).SetExternFun(@SF_Ether);
  Scope.Add('CustomEther', vkExternFun).SetExternFun(@SF_CustomEther);
  Scope.Add('EtherDelete', vkExternFun).SetExternFun(@SF_EtherDelete);
  Scope.Add('EtherIdAdd', vkExternFun).SetExternFun(@SF_EtherIdAdd);
  Scope.Add('EtherIdDelete', vkExternFun).SetExternFun(@SF_EtherIdDelete);
  Scope.Add('EtherState', vkExternFun).SetExternFun(@SF_EtherState);
  Scope.Add('ConChangeRelationToRanger', vkExternFun).SetExternFun(@SF_ConChangeRelationToRanger);
  Scope.Add('GetData', vkExternFun).SetExternFun(@SF_GetData);
  Scope.Add('SetData', vkExternFun).SetExternFun(@SF_SetData);
  Scope.Add('ShipData', vkExternFun).SetExternFun(@SF_ShipData);
  Scope.Add('Format', vkExternFun).SetExternFun(@SF_Format);
  Scope.Add('DeleteTags', vkExternFun).SetExternFun(@SF_DeleteTags);
  Scope.Add('Dialog', vkExternFun).SetExternFun(@SF_Dialog);
  Scope.Add('DText', vkExternFun).SetExternFun(@SF_DText);
  Scope.Add('DAddText', vkExternFun).SetExternFun(@SF_DAddText);
  Scope.Add('DAdd', vkExternFun).SetExternFun(@SF_DAdd);
  Scope.Add('DChange', vkExternFun).SetExternFun(@SF_DChange);
  Scope.Add('DAnswer', vkExternFun).SetExternFun(@SF_DAnswer);
  Scope.Add('Player', vkExternFun).SetExternFun(@SF_Player);
  Scope.Add('ItemExist', vkExternFun).SetExternFun(@SF_ItemExist);
  Scope.Add('ItemIn', vkExternFun).SetExternFun(@SF_ItemIn);
  Scope.Add('ItemCost', vkExternFun).SetExternFun(@SF_ItemCost);
  Scope.Add('ItemCount', vkExternFun).SetExternFun(@SF_ItemCount);
  Scope.Add('ShipPicksItem', vkExternFun).SetExternFun(@SF_ShipPicksItem);
  Scope.Add('DropItem', vkExternFun).SetExternFun(@SF_DropItem);
  Scope.Add('DropScriptItem', vkExternFun).SetExternFun(@SF_DropScriptItem);
  Scope.Add('DeleteEquipment', vkExternFun).SetExternFun(@SF_DeleteEquipment);
  Scope.Add('DecayGoods', vkExternFun).SetExternFun(@SF_DecayGoods);
  Scope.Add('UpsurgeGoods', vkExternFun).SetExternFun(@SF_UpsurgeGoods);
  Scope.Add('GoodsAdd', vkExternFun).SetExternFun(@SF_GoodsAdd);
  Scope.Add('GoodsCount', vkExternFun).SetExternFun(@SF_GoodsCount);
  Scope.Add('GoodsCost', vkExternFun).SetExternFun(@SF_GoodsCost);
  Scope.Add('GoodsRuinsForBuy', vkExternFun).SetExternFun(@SF_GoodsRuinsForBuy);
  Scope.Add('ShipGoods', vkExternFun).SetExternFun(@SF_ShipGoods);
  Scope.Add('ShipGoodsIllegalOnPlanet', vkExternFun).SetExternFun(@SF_ShipGoodsIllegalOnPlanet);
  Scope.Add('GoodsDrop', vkExternFun).SetExternFun(@SF_GoodsDrop);
  Scope.Add('UselessItemCreate', vkExternFun).SetExternFun(@SF_UselessItemCreate);
  Scope.Add('GoodsSellPrice', vkExternFun).SetExternFun(@SF_GoodsSellPrice);
  Scope.Add('GoodsBuyPrice', vkExternFun).SetExternFun(@SF_GoodsBuyPrice);
  Scope.Add('CountTurn', vkExternFun).SetExternFun(@SF_CountTurn);
  Scope.Add('ShipSetBad', vkExternFun).SetExternFun(@SF_ShipSetBad);
  Scope.Add('GroupSetBad', vkExternFun).SetExternFun(@SF_GroupSetBad);
  Scope.Add('ShipSetPartner', vkExternFun).SetExternFun(@SF_ShipSetPartner);
  Scope.Add('ShipJoin', vkExternFun).SetExternFun(@SF_ShipJoin);
  Scope.Add('ShipOut', vkExternFun).SetExternFun(@SF_ShipOut);
  Scope.Add('AllShipOut', vkExternFun).SetExternFun(@SF_AllShipOut);
  Scope.Add('ShipInScript', vkExternFun).SetExternFun(@SF_ShipInScript);
  Scope.Add('ShipInGameEvent', vkExternFun).SetExternFun(@SF_ShipInGameEvent);
  Scope.Add('ShipInCurScript', vkExternFun).SetExternFun(@SF_ShipInCurScript);
  Scope.Add('ShipInNormalSpace', vkExternFun).SetExternFun(@SF_ShipInNormalSpace);
  Scope.Add('ShipInHole', vkExternFun).SetExternFun(@SF_ShipInHole);
  Scope.Add('ShipIsTakeoff', vkExternFun).SetExternFun(@SF_ShipIsTakeoff);
  Scope.Add('ShipCntWeapon', vkExternFun).SetExternFun(@SF_ShipCntWeapon);
  Scope.Add('ShipWeapon', vkExternFun).SetExternFun(@SF_ShipWeapon);
  Scope.Add('ShipEqInSlot', vkExternFun).SetExternFun(@SF_ShipEqInSlot);
  Scope.Add('ArtefactTypeInUse', vkExternFun).SetExternFun(@SF_ArtefactTypeInUse);
  Scope.Add('ArtefactTypeBoosted', vkExternFun).SetExternFun(@SF_ArtefactTypeBoosted);
  Scope.Add('ShipSpeed', vkExternFun).SetExternFun(@SF_ShipSpeed);
  Scope.Add('EnginePower', vkExternFun).SetExternFun(@SF_EnginePower);
  Scope.Add('ShipJump', vkExternFun).SetExternFun(@SF_ShipJump);
  Scope.Add('ShipArmor', vkExternFun).SetExternFun(@SF_ShipArmor);
  Scope.Add('ShipProtectability', vkExternFun).SetExternFun(@SF_ShipProtectability);
  Scope.Add('ShipDroidRepair', vkExternFun).SetExternFun(@SF_ShipDroidRepair);
  Scope.Add('ShipRadarRange', vkExternFun).SetExternFun(@SF_ShipRadarRange);
  Scope.Add('ShipScanerPower', vkExternFun).SetExternFun(@SF_ShipScanerPower);
  Scope.Add('ShipHookPower', vkExternFun).SetExternFun(@SF_ShipHookPower);
  Scope.Add('ShipHookRange', vkExternFun).SetExternFun(@SF_ShipHookRange);
  Scope.Add('ShipAverageDamage', vkExternFun).SetExternFun(@SF_ShipAverageDamage);
  Scope.Add('ShipHealthFactor', vkExternFun).SetExternFun(@SF_ShipHealthFactor);
  Scope.Add('ShipHealthFactorStatus', vkExternFun).SetExternFun(@SF_ShipHealthFactorStatus);
  Scope.Add('PlayerImmunity', vkExternFun).SetExternFun(@SF_PlayerImmunity);
  Scope.Add('ShipStatusEffect', vkExternFun).SetExternFun(@SF_ShipStatusEffect);
  Scope.Add('ShipGroup', vkExternFun).SetExternFun(@SF_ShipGroup);
  Scope.Add('ShipCanJump', vkExternFun).SetExternFun(@SF_ShipCanJump);
  Scope.Add('ShipInStar', vkExternFun).SetExternFun(@SF_ShipInStar);
  Scope.Add('ShipInPlanet', vkExternFun).SetExternFun(@SF_ShipInPlanet);
  Scope.Add('ShipStatistic', vkExternFun).SetExternFun(@SF_ShipStatistic);
  Scope.Add('PlayerDominatorStatistic', vkExternFun).SetExternFun(@SF_PlayerDominatorStatistic);
  Scope.Add('ShipMoney', vkExternFun).SetExternFun(@SF_ShipMoney);
  Scope.Add('ShipFuel', vkExternFun).SetExternFun(@SF_ShipFuel);
  Scope.Add('ShipFuelLow', vkExternFun).SetExternFun(@SF_ShipFuelLow);
  Scope.Add('ShipStrengthInBestRanger', vkExternFun).SetExternFun(@SF_ShipStrengthInBestRanger);
  Scope.Add('ShipStrengthInAverageRanger', vkExternFun).SetExternFun(@SF_ShipStrengthInAverageRanger);
  Scope.Add('ChanceToWin', vkExternFun).SetExternFun(@SF_ChanceToWin);
  Scope.Add('ShipFind', vkExternFun).SetExternFun(@SF_ShipFind);
  Scope.Add('RangerStatus', vkExternFun).SetExternFun(@SF_RangerStatus);
  Scope.Add('RangerPlaceInRating', vkExternFun).SetExternFun(@SF_RangerPlaceInRating);
  Scope.Add('RangerExcludedFromRating', vkExternFun).SetExternFun(@SF_RangerExcludedFromRating);
  Scope.Add('GalaxyMoney', vkExternFun).SetExternFun(@SF_GalaxyMoney);
  Scope.Add('ShipDestroy', vkExternFun).SetExternFun(@SF_ShipDestroy);
  Scope.Add('ShipDestroyType', vkExternFun).SetExternFun(@SF_ShipDestroyType);
  Scope.Add('ItemDestroy', vkExternFun).SetExternFun(@SF_ItemDestroy);
  Scope.Add('RangersCapital', vkExternFun).SetExternFun(@SF_RangersCapital);
  Scope.Add('GroupToShip', vkExternFun).SetExternFun(@SF_GroupToShip);
  Scope.Add('OrderLanding', vkExternFun).SetExternFun(@SF_OrderLanding);
  Scope.Add('OrderJump', vkExternFun).SetExternFun(@SF_OrderJump);
  Scope.Add('GroupIs', vkExternFun).SetExternFun(@SF_GroupIs);
  Scope.Add('StateIs', vkExternFun).SetExternFun(@SF_StateIs);
  Scope.Add('Dist', vkExternFun).SetExternFun(@SF_Dist);
  Scope.Add('Angle', vkExternFun).SetExternFun(@SF_Angle);
  Scope.Add('Dist2Star', vkExternFun).SetExternFun(@SF_Dist2Star);
  Scope.Add('BuyPirate', vkExternFun).SetExternFun(@SF_BuyPirate);
  Scope.Add('BuyTransport', vkExternFun).SetExternFun(@SF_BuyTransport);
  Scope.Add('Name', vkExternFun).SetExternFun(@SF_Name);
  Scope.Add('ShortName', vkExternFun).SetExternFun(@SF_ShortName);
  Scope.Add('FirstGiveMoney', vkExternFun).SetExternFun(@SF_FirstGiveMoney);
  Scope.Add('HaveProgramm', vkExternFun).SetExternFun(@SF_HaveProgramm);
  Scope.Add('GetProgramm', vkExternFun).SetExternFun(@SF_GetProgramm);
  Scope.Add('SetProgramm', vkExternFun).SetExternFun(@SF_SetProgramm);
  Scope.Add('DomikProgramm', vkExternFun).SetExternFun(@SF_DomikProgramm);
  Scope.Add('DomikProgrammDate', vkExternFun).SetExternFun(@SF_DomikProgrammDate);
  Scope.Add('HoleMamaCreate', vkExternFun).SetExternFun(@SF_HoleMamaCreate);
  Scope.Add('HoleCreate', vkExternFun).SetExternFun(@SF_HoleCreate);
  Scope.Add('TerronWeaponLock', vkExternFun).SetExternFun(@SF_TerronWeaponLock);
  Scope.Add('TerronGrowLock', vkExternFun).SetExternFun(@SF_TerronGrowLock);
  Scope.Add('TerronLandingLock', vkExternFun).SetExternFun(@SF_TerronLandingLock);
  Scope.Add('TerronToStar', vkExternFun).SetExternFun(@SF_TerronToStar);
  Scope.Add('KellerLeave', vkExternFun).SetExternFun(@SF_KellerLeave);
  Scope.Add('KellerNewResearch', vkExternFun).SetExternFun(@SF_KellerNewResearch);
  Scope.Add('KellerKill', vkExternFun).SetExternFun(@SF_KellerKill);
  Scope.Add('BlazerLanding', vkExternFun).SetExternFun(@SF_BlazerLanding);
  Scope.Add('BlazerSelfDestruction', vkExternFun).SetExternFun(@SF_BlazerSelfDestruction);
  Scope.Add('GalaxyShipId', vkExternFun).SetExternFun(@SF_GalaxyShipId);
  Scope.Add('NearCivilPlanet', vkExternFun).SetExternFun(@SF_NearCivilPlanet);
  Scope.Add('SkipGreeting', vkExternFun).SetExternFun(@SF_SkipGreeting);
  Scope.Add('Sound', vkExternFun).SetExternFun(@SF_Sound);
  Scope.Add('Tips', vkExternFun).SetExternFun(@SF_Tips);
  Scope.Add('TipsState', vkExternFun).SetExternFun(@SF_TipsState);
  Scope.Add('CT', vkExternFun).SetExternFun(@SF_CT);
  Scope.Add('BlockExist', vkExternFun).SetExternFun(@SF_BlockExist);
  Scope.Add('GetMainData', vkExternFun).SetExternFun(@SF_GetMainData);
  Scope.Add('GetGameOptions', vkExternFun).SetExternFun(@SF_GetGameOptions);
  Scope.Add('ResourceExist', vkExternFun).SetExternFun(@SF_ResourceExist);
  Scope.Add('SFT', vkExternFun).SetExternFun(@SF_SFT);
  Scope.Add('CurrentMods', vkExternFun).SetExternFun(@SF_CurrentMods);
  Scope.Add('RobotSupport', vkExternFun).SetExternFun(@SF_RobotSupport);
  Scope.Add('UselessItem', vkInt).SetInt(Ord(t_UselessItem));
  Scope.Add('ForLiberationSystem', vkInt).SetInt(Ord(atLiberation));
  Scope.Add('ForAccomplishment', vkInt).SetInt(Ord(atAccomplishment));
  Scope.Add('ForSecretMission', vkInt).SetInt(Ord(atSecretMission));
  Scope.Add('ForCowardice', vkInt).SetInt(Ord(atCowardice));
  Scope.Add('ForPerfidy', vkInt).SetInt(Ord(atPerfidy));
  Scope.Add('ForPlanetBattle', vkInt).SetInt(Ord(atPlanetBattle));
  Scope.Add('Maloc', vkInt).SetInt(Ord(oiMaloc));
  Scope.Add('Peleng', vkInt).SetInt(Ord(oiPeleng));
  Scope.Add('People', vkInt).SetInt(Ord(oiHuman));
  Scope.Add('Fei', vkInt).SetInt(Ord(oiFeyan));
  Scope.Add('Gaal', vkInt).SetInt(Ord(oiGaal));
  Scope.Add('Kling', vkInt).SetInt(Ord(oiDominator));
  Scope.Add('None', vkInt).SetInt(Ord(oiUninhabited));
  Scope.Add('PirateClan', vkInt).SetInt(Ord(oiPirate));
  Scope.Add('t_Food', vkInt).SetInt(Ord(t_Food));
  Scope.Add('t_Medicine', vkInt).SetInt(Ord(t_Medicine));
  Scope.Add('t_Technics', vkInt).SetInt(Ord(t_Technics));
  Scope.Add('t_Luxury', vkInt).SetInt(Ord(t_Luxury));
  Scope.Add('t_Minerals', vkInt).SetInt(Ord(t_Minerals));
  Scope.Add('t_Alcohol', vkInt).SetInt(Ord(t_Alcohol));
  Scope.Add('t_Arms', vkInt).SetInt(Ord(t_Arms));
  Scope.Add('t_Narcotics', vkInt).SetInt(Ord(t_Narcotics));
  Scope.Add('t_Artefact', vkInt).SetInt(Ord(t_Artefact));
  Scope.Add('t_Artefact2', vkInt).SetInt(Ord(t_Artefact2));
  Scope.Add('t_ArtefactHull', vkInt).SetInt(Ord(t_ArtefactHull));
  Scope.Add('t_ArtefactFuel', vkInt).SetInt(Ord(t_ArtefactFuel));
  Scope.Add('t_ArtefactSpeed', vkInt).SetInt(Ord(t_ArtefactSpeed));
  Scope.Add('t_ArtefactPower', vkInt).SetInt(Ord(t_ArtefactPower));
  Scope.Add('t_ArtefactRadar', vkInt).SetInt(Ord(t_ArtefactRadar));
  Scope.Add('t_ArtefactScaner', vkInt).SetInt(Ord(t_ArtefactScaner));
  Scope.Add('t_ArtefactDroid', vkInt).SetInt(Ord(t_ArtefactDroid));
  Scope.Add('t_ArtefactNano', vkInt).SetInt(Ord(t_ArtefactNano));
  Scope.Add('t_ArtefactHook', vkInt).SetInt(Ord(t_ArtefactHook));
  Scope.Add('t_ArtefactDef', vkInt).SetInt(Ord(t_ArtefactDef));
  Scope.Add('t_ArtefactAnalyzer', vkInt).SetInt(Ord(t_ArtefactAnalyzer));
  Scope.Add('t_ArtefactMiniExpl', vkInt).SetInt(Ord(t_ArtefactMiniExpl));
  Scope.Add('t_ArtefactAntigrav', vkInt).SetInt(Ord(t_ArtefactAntigrav));
  Scope.Add('t_ArtefactTransmitter', vkInt).SetInt(Ord(t_ArtefactTransmitter));
  Scope.Add('t_ArtefactBomb', vkInt).SetInt(Ord(t_ArtefactBomb));
  Scope.Add('t_ArtefactTranclucator', vkInt).SetInt(Ord(t_ArtefactTranclucator));
  Scope.Add('t_Hull', vkInt).SetInt(Ord(t_Hull));
  Scope.Add('t_FuelTanks', vkInt).SetInt(Ord(t_FuelTanks));
  Scope.Add('t_Engine', vkInt).SetInt(Ord(t_Engine));
  Scope.Add('t_Radar', vkInt).SetInt(Ord(t_Radar));
  Scope.Add('t_Scaner', vkInt).SetInt(Ord(t_Scaner));
  Scope.Add('t_RepairRobot', vkInt).SetInt(Ord(t_RepairRobot));
  Scope.Add('t_CargoHook', vkInt).SetInt(Ord(t_CargoHook));
  Scope.Add('t_DefGenerator', vkInt).SetInt(Ord(t_DefGenerator));
  for WeaponIndex := 1 to CountItemTypesInMask([Ord(t_IndustrialLaser)..Ord(t_Lirecron)]) do
    Scope.Add('t_Weapon' + IntToStr(WeaponIndex), vkInt).SetInt(GetItemTypeFromMask([Ord(t_IndustrialLaser)..Ord(t_Lirecron)], WeaponIndex));
  Scope.Add('t_CustomWeapon', vkInt).SetInt(Ord(t_CustomWeapon));
  Scope.Add('t_Protoplasm', vkInt).SetInt(Ord(t_Protoplasm));
  Scope.Add('t_UselessItem', vkInt).SetInt(Ord(t_UselessItem));
  Scope.Add('ReWar', vkInt).SetInt(Ord(rlHostile));
  Scope.Add('ReBad', vkInt).SetInt(Ord(rlBad));
  Scope.Add('ReNormal', vkInt).SetInt(Ord(rlNormal));
  Scope.Add('ReGood', vkInt).SetInt(Ord(rlGood));
  Scope.Add('ReBest', vkInt).SetInt(Ord(rlExcellent));
  Scope.Add('Trader', vkInt).SetInt(Ord(rcTrader));
  Scope.Add('Pirate', vkInt).SetInt(Ord(rcPirate));
  Scope.Add('Warrior', vkInt).SetInt(Ord(rcWarrior));
  Scope.Add('t_Kling', vkInt).SetInt(stKling);
  Scope.Add('t_Ranger', vkInt).SetInt(stRanger);
  Scope.Add('t_Transport', vkInt).SetInt(stTransport);
  Scope.Add('t_Pirate', vkInt).SetInt(stPirate);
  Scope.Add('t_Warrior', vkInt).SetInt(stWarrior);
  Scope.Add('t_Tranclucator', vkInt).SetInt(stTranclucator);
  Scope.Add('t_RC', vkInt).SetInt(Ord(rstRangerCenter));
  Scope.Add('t_PB', vkInt).SetInt(Ord(rstPirateBase));
  Scope.Add('t_WB', vkInt).SetInt(Ord(rstMilitaryBase));
  Scope.Add('t_SB', vkInt).SetInt(Ord(rstScienceBase));
  Scope.Add('t_BK', vkInt).SetInt(Ord(rstBusinessCenter));
  Scope.Add('t_MC', vkInt).SetInt(Ord(rstMedicalBase));
  Scope.Add('t_CB', vkInt).SetInt(Ord(rstDominion));
  Scope.Add('t_UB', vkInt).SetInt(Ord(rstCustomStation));
  Scope.Add('progKellerCall', vkInt).SetInt(Ord(prgKellerCall));
  Scope.Add('progLogicalNegation', vkInt).SetInt(Ord(prgLogicalNegation));
  Scope.Add('progDematerial', vkInt).SetInt(Ord(prgDematerial));
  Scope.Add('progEnergotron', vkInt).SetInt(Ord(prgEnergotron));
  Scope.Add('progSabCrack', vkInt).SetInt(Ord(prgSabCrack));
  Scope.Add('progIntercom', vkInt).SetInt(Ord(prgIntercom));
  Scope.Add('StarShips', vkExternFun).SetExternFun(@SF_StarShips);
  Scope.Add('StarPlanets', vkExternFun).SetExternFun(@SF_StarPlanets);
  Scope.Add('StarMissiles', vkExternFun).SetExternFun(@SF_StarMissiles);
  Scope.Add('StarAsteroids', vkExternFun).SetExternFun(@SF_StarAsteroids);
  Scope.Add('GroupShip', vkExternFun).SetExternFun(@SF_GroupShip);
  Scope.Add('ShipItems', vkExternFun).SetExternFun(@SF_ShipItems);
  Scope.Add('ShipArts', vkExternFun).SetExternFun(@SF_ShipArts);
  Scope.Add('PlayerTranclucators', vkExternFun).SetExternFun(@SF_PlayerTranclucators);
  Scope.Add('ArtTranclucatorToShip', vkExternFun).SetExternFun(@SF_ArtTranclucatorToShip);
  Scope.Add('TranclucatorData', vkExternFun).SetExternFun(@SF_TranclucatorData);
  Scope.Add('LinkItemToScript', vkExternFun).SetExternFun(@SF_LinkItemToScript);
  Scope.Add('ReleaseItemFromScript', vkExternFun).SetExternFun(@SF_ReleaseItemFromScript);
  Scope.Add('ScriptItemData', vkExternFun).SetExternFun(@SF_ScriptItemData);
  Scope.Add('ScriptItemTextData', vkExternFun).SetExternFun(@SF_ScriptItemTextData);
  Scope.Add('ScriptItemToItem', vkExternFun).SetExternFun(@SF_ScriptItemToItem);
  Scope.Add('GetShipPirateRank', vkExternFun).SetExternFun(@SF_GetShipPirateRank);
  Scope.Add('ShipPirateRankPoints', vkExternFun).SetExternFun(@SF_ShipPirateRankPoints);
  Scope.Add('ShipNextPirateRankPoints', vkExternFun).SetExternFun(@SF_ShipNextPirateRankPoints);
  Scope.Add('ShipInPirateClan', vkExternFun).SetExternFun(@SF_ShipInPirateClan);
  Scope.Add('ShipOnSidePirateClan', vkExternFun).SetExternFun(@SF_ShipOnSidePirateClan);
  Scope.Add('RaisePirateRank', vkExternFun).SetExternFun(@SF_RaisePirateRank);
  Scope.Add('ItemType', vkExternFun).SetExternFun(@SF_ItemType);
  Scope.Add('CustomWeaponType', vkExternFun).SetExternFun(@SF_CustomWeaponType);
  Scope.Add('ItemName', vkExternFun).SetExternFun(@SF_ItemName);
  Scope.Add('ItemFullName', vkExternFun).SetExternFun(@SF_ItemFullName);
  Scope.Add('ItemSize', vkExternFun).SetExternFun(@SF_ItemSize);
  Scope.Add('ItemOwner', vkExternFun).SetExternFun(@SF_ItemOwner);
  Scope.Add('ItemSubrace', vkExternFun).SetExternFun(@SF_ItemSubrace);
  Scope.Add('ItemIsInUse', vkExternFun).SetExternFun(@SF_ItemIsInUse);
  Scope.Add('ItemIsInSet', vkExternFun).SetExternFun(@SF_ItemIsInSet);
  Scope.Add('PlayerEqSet', vkExternFun).SetExternFun(@SF_PlayerEqSet);
  Scope.Add('ItemIsBroken', vkExternFun).SetExternFun(@SF_ItemIsBroken);
  Scope.Add('ShipCanUseEq', vkExternFun).SetExternFun(@SF_ShipCanUseEq);
  Scope.Add('ShipCanRepairEq', vkExternFun).SetExternFun(@SF_ShipCanRepairEq);
  Scope.Add('ShipTechLevelKnowledge', vkExternFun).SetExternFun(@SF_ShipTechLevelKnowledge);
  Scope.Add('WeaponTarget', vkExternFun).SetExternFun(@SF_WeaponTarget);
  Scope.Add('GetEquipmentStats', vkExternFun).SetExternFun(@SF_GetEquipmentStats);
  Scope.Add('SetEquipmentStats', vkExternFun).SetExternFun(@SF_SetEquipmentStats);
  Scope.Add('CreateHull', vkExternFun).SetExternFun(@SF_CreateHull);
  Scope.Add('CreateEquipment', vkExternFun).SetExternFun(@SF_CreateEquipment);
  Scope.Add('CreateArt', vkExternFun).SetExternFun(@SF_CreateArt);
  Scope.Add('CreateCustomWeapon', vkExternFun).SetExternFun(@SF_CreateCustomWeapon);
  Scope.Add('CreateCustomArt', vkExternFun).SetExternFun(@SF_CreateCustomArt);
  Scope.Add('CustomArtData', vkExternFun).SetExternFun(@SF_CustomArtData);
  Scope.Add('CustomArtTextData', vkExternFun).SetExternFun(@SF_CustomArtTextData);
  Scope.Add('CreateMM', vkExternFun).SetExternFun(@SF_CreateMM);
  Scope.Add('CreateNodes', vkExternFun).SetExternFun(@SF_CreateNodes);
  Scope.Add('CreateCustomCountableItem', vkExternFun).SetExternFun(@SF_CreateCustomCountableItem);
  Scope.Add('CreateZond', vkExternFun).SetExternFun(@SF_CreateZond);
  Scope.Add('ExistingZonds', vkExternFun).SetExternFun(@SF_ExistingZonds);
  Scope.Add('FreeItem', vkExternFun).SetExternFun(@SF_FreeItem);
  Scope.Add('ShipJoinsClan', vkExternFun).SetExternFun(@SF_ShipJoinsClan);
  Scope.Add('AddItemToShip', vkExternFun).SetExternFun(@SF_AddItemToShip);
  Scope.Add('GetItemFromShip', vkExternFun).SetExternFun(@SF_GetItemFromShip);
  Scope.Add('GetArtFromShip', vkExternFun).SetExternFun(@SF_GetArtFromShip);
  Scope.Add('ArrangeItems', vkExternFun).SetExternFun(@SF_ArrangeItems);
  Scope.Add('AddItemToPlanet', vkExternFun).SetExternFun(@SF_AddItemToPlanet);
  Scope.Add('GetItemFromPlanet', vkExternFun).SetExternFun(@SF_GetItemFromPlanet);
  Scope.Add('AddItemToShop', vkExternFun).SetExternFun(@SF_AddItemToShop);
  Scope.Add('GetItemFromShop', vkExternFun).SetExternFun(@SF_GetItemFromShop);
  Scope.Add('AddItemToStorage', vkExternFun).SetExternFun(@SF_AddItemToStorage);
  Scope.Add('GetItemFromStorage', vkExternFun).SetExternFun(@SF_GetItemFromStorage);
  Scope.Add('FindItemInStorage', vkExternFun).SetExternFun(@SF_FindItemInStorage);
  Scope.Add('PutItemInVault', vkExternFun).SetExternFun(@SF_PutItemInVault);
  Scope.Add('GetItemFromVault', vkExternFun).SetExternFun(@SF_GetItemFromVault);
  Scope.Add('DropItemInSystem', vkExternFun).SetExternFun(@SF_DropItemInSystem);
  Scope.Add('StopMovingItem', vkExternFun).SetExternFun(@SF_StopMovingItem);
  Scope.Add('StarItems', vkExternFun).SetExternFun(@SF_StarItems);
  Scope.Add('GetItemFromStar', vkExternFun).SetExternFun(@SF_GetItemFromStar);
  Scope.Add('PlanetItems', vkExternFun).SetExternFun(@SF_PlanetItems);
  Scope.Add('StorageItems', vkExternFun).SetExternFun(@SF_StorageItems);
  Scope.Add('StorageItemLocation', vkExternFun).SetExternFun(@SF_StorageItemLocation);
  Scope.Add('ShopItems', vkExternFun).SetExternFun(@SF_ShopItems);
  Scope.Add('AddDialogOverride', vkExternFun).SetExternFun(@SF_AddDialogOverride);
  Scope.Add('AddDialogInject', vkExternFun).SetExternFun(@SF_AddDialogInject);
  Scope.Add('InjectAnswer', vkExternFun).SetExternFun(@SF_InjectAnswer);
  Scope.Add('AddDialogBlock', vkExternFun).SetExternFun(@SF_AddDialogBlock);
  Scope.Add('GotoGov', vkExternFun).SetExternFun(@SF_GotoGov);
  Scope.Add('GetShipPlanet', vkExternFun).SetExternFun(@SF_GetShipPlanet);
  Scope.Add('GetShipHomePlanet', vkExternFun).SetExternFun(@SF_GetShipHomePlanet);
  Scope.Add('GetShipRuins', vkExternFun).SetExternFun(@SF_GetShipRuins);
  Scope.Add('GetTalkShip', vkExternFun).SetExternFun(@SF_GetTalkShip);
  Scope.Add('GetTalkType', vkExternFun).SetExternFun(@SF_GetTalkType);
  Scope.Add('TalkByAI', vkExternFun).SetExternFun(@SF_TalkByAI);
  Scope.Add('ScriptRun', vkExternFun).SetExternFun(@SF_ScriptRun);
  Scope.Add('CreateABShip', vkExternFun).SetExternFun(@SF_CreateABShip);
  Scope.Add('ConvertToABShip', vkExternFun).SetExternFun(@SF_ConvertToABShip);
  Scope.Add('ABShipModifiers', vkExternFun).SetExternFun(@SF_ABShipModifiers);
  Scope.Add('StartAB', vkExternFun).SetExternFun(@SF_StartAB);
  Scope.Add('StartTextQuest', vkExternFun).SetExternFun(@SF_StartTextQuest);
  Scope.Add('StartRobots', vkExternFun).SetExternFun(@SF_StartRobots);
  Scope.Add('MarkRobotsMapAsUsed', vkExternFun).SetExternFun(@SF_MarkRobotsMapAsUsed);
  Scope.Add('ShipOwner', vkExternFun).SetExternFun(@SF_ShipOwner);
  Scope.Add('ShipPilotRace', vkExternFun).SetExternFun(@SF_ShipPilotRace);
  Scope.Add('ShipSkill', vkExternFun).SetExternFun(@SF_ShipSkill);
  Scope.Add('ShipFace', vkExternFun).SetExternFun(@SF_ShipFace);
  Scope.Add('ShipFreeExp', vkExternFun).SetExternFun(@SF_ShipFreeExp);
  Scope.Add('GetShipExpByType', vkExternFun).SetExternFun(@SF_GetShipExpByType);
  Scope.Add('CoordX', vkExternFun).SetExternFun(@SF_CoordX);
  Scope.Add('CoordY', vkExternFun).SetExternFun(@SF_CoordY);
  Scope.Add('ShipSetCoords', vkExternFun).SetExternFun(@SF_ShipSetCoords);
  Scope.Add('ShipAngle', vkExternFun).SetExternFun(@SF_ShipAngle);
  Scope.Add('ObjectType', vkExternFun).SetExternFun(@SF_ObjectType);
  Scope.Add('ShipInHyperSpace', vkExternFun).SetExternFun(@SF_ShipInHyperSpace);
  Scope.Add('ShipStatus', vkExternFun).SetExternFun(@SF_ShipStatus);
  Scope.Add('BuyRanger', vkExternFun).SetExternFun(@SF_BuyRanger);
  Scope.Add('BuyWarrior', vkExternFun).SetExternFun(@SF_BuyWarrior);
  Scope.Add('BuyBigWarrior', vkExternFun).SetExternFun(@SF_BuyBigWarrior);
  Scope.Add('BuyDomik', vkExternFun).SetExternFun(@SF_BuyDomik);
  Scope.Add('BuyDomikExtremal', vkExternFun).SetExternFun(@SF_BuyDomikExtremal);
  Scope.Add('BuyTranclucator', vkExternFun).SetExternFun(@SF_BuyTranclucator);
  Scope.Add('TransferShip', vkExternFun).SetExternFun(@SF_TransferShip);
  Scope.Add('OrderForsage', vkExternFun).SetExternFun(@SF_OrderForsage);
  Scope.Add('OrderNone', vkExternFun).SetExternFun(@SF_OrderNone);
  Scope.Add('OrderMove', vkExternFun).SetExternFun(@SF_OrderMove);
  Scope.Add('OrderTeleport', vkExternFun).SetExternFun(@SF_OrderTeleport);
  Scope.Add('OrderTakeOff', vkExternFun).SetExternFun(@SF_OrderTakeOff);
  Scope.Add('OrderFollowShip', vkExternFun).SetExternFun(@SF_OrderFollowShip);
  Scope.Add('OrderJumpHole', vkExternFun).SetExternFun(@SF_OrderJumpHole);
  Scope.Add('RelationToRanger', vkExternFun).SetExternFun(@SF_RelationToRanger);
  Scope.Add('RelationToShip', vkExternFun).SetExternFun(@SF_RelationToShip);
  Scope.Add('StarOwner', vkExternFun).SetExternFun(@SF_StarOwner);
  Scope.Add('StarBattle', vkExternFun).SetExternFun(@SF_StarBattle);
  Scope.Add('StarSeries', vkExternFun).SetExternFun(@SF_StarSeries);
  Scope.Add('StarHoles', vkExternFun).SetExternFun(@SF_StarHoles);
  Scope.Add('StarNearbyStars', vkExternFun).SetExternFun(@SF_StarNearbyStars);
  Scope.Add('StarNearbyStarsDist', vkExternFun).SetExternFun(@SF_StarNearbyStarsDist);
  Scope.Add('StarSetGraph', vkExternFun).SetExternFun(@SF_StarSetGraph);
  Scope.Add('CreatePlanet', vkExternFun).SetExternFun(@SF_CreatePlanet);
  Scope.Add('PlanetSetGraph', vkExternFun).SetExternFun(@SF_PlanetSetGraph);
  Scope.Add('PlanetGetGraph', vkExternFun).SetExternFun(@SF_PlanetGetGraph);
  Scope.Add('PlanetPopulation', vkExternFun).SetExternFun(@SF_PlanetPopulation);
  Scope.Add('PlanetOwner', vkExternFun).SetExternFun(@SF_PlanetOwner);
  Scope.Add('PlanetRace', vkExternFun).SetExternFun(@SF_PlanetRace);
  Scope.Add('PlanetGov', vkExternFun).SetExternFun(@SF_PlanetGov);
  Scope.Add('PlanetEco', vkExternFun).SetExternFun(@SF_PlanetEco);
  Scope.Add('PlanetTerrain', vkExternFun).SetExternFun(@SF_PlanetTerrain);
  Scope.Add('PlanetTerrainExplored', vkExternFun).SetExternFun(@SF_PlanetTerrainExplored);
  Scope.Add('PlanetOrbitRadius', vkExternFun).SetExternFun(@SF_PlanetOrbitRadius);
  Scope.Add('PlanetOrbitalVelocity', vkExternFun).SetExternFun(@SF_PlanetOrbitalVelocity);
  Scope.Add('PlanetSize', vkExternFun).SetExternFun(@SF_PlanetSize);
  Scope.Add('PlanetCurInvention', vkExternFun).SetExternFun(@SF_PlanetCurInvention);
  Scope.Add('PlanetCurInventionPoints', vkExternFun).SetExternFun(@SF_PlanetCurInventionPoints);
  Scope.Add('PlanetInventionLevel', vkExternFun).SetExternFun(@SF_PlanetInventionLevel);
  Scope.Add('PlanetBoostInventions', vkExternFun).SetExternFun(@SF_PlanetBoostInventions);
  Scope.Add('PlanetWarriors', vkExternFun).SetExternFun(@SF_PlanetWarriors);
  Scope.Add('GalaxySectors', vkExternFun).SetExternFun(@SF_GalaxySectors);
  Scope.Add('GalaxyTechLevel', vkExternFun).SetExternFun(@SF_GalaxyTechLevel);
  Scope.Add('GalaxyDominatorResearchPercent', vkExternFun).SetExternFun(@SF_GalaxyDominatorResearchPercent);
  Scope.Add('GalaxyDominatorResearchMaterial', vkExternFun).SetExternFun(@SF_GalaxyDominatorResearchMaterial);
  Scope.Add('GalaxyDiffLevels', vkExternFun).SetExternFun(@SF_GalaxyDiffLevels);
  Scope.Add('SectorVisible', vkExternFun).SetExternFun(@SF_SectorVisible);
  Scope.Add('HullHP', vkExternFun).SetExternFun(@SF_HullHP);
  Scope.Add('HullDamageSuspectibility', vkExternFun).SetExternFun(@SF_HullDamageSuspectibility);
  Scope.Add('HullType', vkExternFun).SetExternFun(@SF_HullType);
  Scope.Add('HullSpecial', vkExternFun).SetExternFun(@SF_HullSpecial);
  Scope.Add('HullSeries', vkExternFun).SetExternFun(@SF_HullSeries);
  Scope.Add('GalaxyHoles', vkExternFun).SetExternFun(@SF_GalaxyHoles);
  Scope.Add('HoleCreate2', vkExternFun).SetExternFun(@SF_HoleCreate2);
  Scope.Add('HoleStar1', vkExternFun).SetExternFun(@SF_HoleStar1);
  Scope.Add('HoleStar2', vkExternFun).SetExternFun(@SF_HoleStar2);
  Scope.Add('HoleX1', vkExternFun).SetExternFun(@SF_HoleX1);
  Scope.Add('HoleY1', vkExternFun).SetExternFun(@SF_HoleY1);
  Scope.Add('HoleX2', vkExternFun).SetExternFun(@SF_HoleX2);
  Scope.Add('HoleY2', vkExternFun).SetExternFun(@SF_HoleY2);
  Scope.Add('HoleTurnCreate', vkExternFun).SetExternFun(@SF_HoleTurnCreate);
  Scope.Add('HoleMap', vkExternFun).SetExternFun(@SF_HoleMap);
  Scope.Add('HoleGraph', vkExternFun).SetExternFun(@SF_HoleGraph);
  Scope.Add('StarRuins', vkExternFun).SetExternFun(@SF_StarRuins);
  Scope.Add('CreateQuestItem', vkExternFun).SetExternFun(@SF_CreateQuestItem);
  Scope.Add('ShipOrder', vkExternFun).SetExternFun(@SF_ShipOrder);
  Scope.Add('ShipTurnBeforeEndOrder', vkExternFun).SetExternFun(@SF_ShipTurnBeforeEndOrder);
  Scope.Add('ShipOrderData1', vkExternFun).SetExternFun(@SF_ShipOrderData1);
  Scope.Add('ShipOrderData2', vkExternFun).SetExternFun(@SF_ShipOrderData2);
  Scope.Add('ShipOrderObj', vkExternFun).SetExternFun(@SF_ShipOrderObj);
  Scope.Add('ShipDestination', vkExternFun).SetExternFun(@SF_ShipDestination);
  Scope.Add('BuildRuins', vkExternFun).SetExternFun(@SF_BuildRuins);
  Scope.Add('BuildCustomRuins', vkExternFun).SetExternFun(@SF_BuildCustomRuins);
  Scope.Add('RuinsChangeType', vkExternFun).SetExternFun(@SF_RuinsChangeType);
  Scope.Add('ShipStanding', vkExternFun).SetExternFun(@SF_ShipStanding);
  Scope.Add('ShipSlots', vkExternFun).SetExternFun(@SF_ShipSlots);
  Scope.Add('MissileStar', vkExternFun).SetExternFun(@SF_MissileStar);
  Scope.Add('MissileType', vkExternFun).SetExternFun(@SF_MissileType);
  Scope.Add('CustomMissileType', vkExternFun).SetExternFun(@SF_CustomMissileType);
  Scope.Add('MissileOwner', vkExternFun).SetExternFun(@SF_MissileOwner);
  Scope.Add('MissileWeaponID', vkExternFun).SetExternFun(@SF_MissileWeaponID);
  Scope.Add('MissileTarget', vkExternFun).SetExternFun(@SF_MissileTarget);
  Scope.Add('MissileMaxDamage', vkExternFun).SetExternFun(@SF_MissileMaxDamage);
  Scope.Add('MissileMinDamage', vkExternFun).SetExternFun(@SF_MissileMinDamage);
  Scope.Add('MissileLive', vkExternFun).SetExternFun(@SF_MissileLive);
  Scope.Add('MissileSpeed', vkExternFun).SetExternFun(@SF_MissileSpeed);
  Scope.Add('MissileAngle', vkExternFun).SetExternFun(@SF_MissileAngle);
  Scope.Add('AsteroidMinerals', vkExternFun).SetExternFun(@SF_AsteroidMinerals);
  Scope.Add('AsteroidGraph', vkExternFun).SetExternFun(@SF_AsteroidGraph);
  Scope.Add('AsteroidRespawn', vkExternFun).SetExternFun(@SF_AsteroidRespawn);
  Scope.Add('ArrayAdd', vkExternFun).SetExternFun(@SF_ArrayAdd);
  Scope.Add('ArrayDelete', vkExternFun).SetExternFun(@SF_ArrayDelete);
  Scope.Add('ArrayClear', vkExternFun).SetExternFun(@SF_ArrayClear);
  Scope.Add('ArrayDim', vkExternFun).SetExternFun(@SF_ArrayDim);
  Scope.Add('ArraySort', vkExternFun).SetExternFun(@SF_ArraySort);
  Scope.Add('ArraySortPartial', vkExternFun).SetExternFun(@SF_ArraySortPartial);
  Scope.Add('ArrayRandomize', vkExternFun).SetExternFun(@SF_ArrayRandomize);
  Scope.Add('ArrayFind', vkExternFun).SetExternFun(@SF_ArrayFind);
  Scope.Add('ArrayFindInSorted', vkExternFun).SetExternFun(@SF_ArrayFindInSorted);
  Scope.Add('DistToNearestEnemySystem', vkExternFun).SetExternFun(@SF_DistToNearestEnemySystem);
  Scope.Add('StarEnemyThreatLevel', vkExternFun).SetExternFun(@SF_StarEnemyThreatLevel);
  Scope.Add('BuildListOfQuestPossibleLocations', vkExternFun).SetExternFun(@SF_BuildListOfQuestPossibleLocations);
  Scope.Add('FindItemInShip', vkExternFun).SetExternFun(@SF_FindItemInShip);
  Scope.Add('GalaxyRangers', vkExternFun).SetExternFun(@SF_GalaxyRangers);
  Scope.Add('MakeShipEnterStar', vkExternFun).SetExternFun(@SF_MakeShipEnterStar);
  Scope.Add('ShipGetBad', vkExternFun).SetExternFun(@SF_ShipGetBad);
  Scope.Add('ShipAddDropItem', vkExternFun).SetExternFun(@SF_ShipAddDropItem);
  Scope.Add('OrderLock', vkExternFun).SetExternFun(@SF_OrderLock);
  Scope.Add('BonusCount', vkExternFun).SetExternFun(@SF_BonusCount);
  Scope.Add('SeriesCount', vkExternFun).SetExternFun(@SF_SeriesCount);
  Scope.Add('BonusPriority', vkExternFun).SetExternFun(@SF_BonusPriority);
  Scope.Add('BonusIsSpecial', vkExternFun).SetExternFun(@SF_BonusIsSpecial);
  Scope.Add('BonusName', vkExternFun).SetExternFun(@SF_BonusName);
  Scope.Add('BonusNumInCfg', vkExternFun).SetExternFun(@SF_BonusNumInCfg);
  Scope.Add('SeriesNumInCfg', vkExternFun).SetExternFun(@SF_SeriesNumInCfg);
  Scope.Add('BonusValue', vkExternFun).SetExternFun(@SF_BonusValue);
  Scope.Add('FindBonusByName', vkExternFun).SetExternFun(@SF_FindBonusByName);
  Scope.Add('FindSeriesByName', vkExternFun).SetExternFun(@SF_FindSeriesByName);
  Scope.Add('FindBonusByCustomTag', vkExternFun).SetExternFun(@SF_FindBonusByCustomTag);
  Scope.Add('FindBonusByNameInCfg', vkExternFun).SetExternFun(@SF_FindBonusByNameInCfg);
  Scope.Add('BonusCustomTag', vkExternFun).SetExternFun(@SF_BonusCustomTag);
  Scope.Add('CreateEquipmentWithSpecial', vkExternFun).SetExternFun(@SF_CreateEquipmentWithSpecial);
  Scope.Add('SpecialToEquipment', vkExternFun).SetExternFun(@SF_SpecialToEquipment);
  Scope.Add('ModuleToEquipment', vkExternFun).SetExternFun(@SF_ModuleToEquipment);
  Scope.Add('EqSpecial', vkExternFun).SetExternFun(@SF_EqSpecial);
  Scope.Add('EqModule', vkExternFun).SetExternFun(@SF_EqModule);
  Scope.Add('MayAddBonusToEq', vkExternFun).SetExternFun(@SF_MayAddBonusToEq);
  Scope.Add('BuildListOfMMByPriority', vkExternFun).SetExternFun(@SF_BuildListOfMMByPriority);
  Scope.Add('BuildListOfNewShips', vkExternFun).SetExternFun(@SF_BuildListOfNewShips);
  Scope.Add('PlanetToStar', vkExternFun).SetExternFun(@SF_PlanetToStar);
  Scope.Add('Chameleon', vkExternFun).SetExternFun(@SF_Chameleon);
  Scope.Add('IsChameleon', vkExternFun).SetExternFun(@SF_IsChameleon);
  Scope.Add('PlayerChameleonCharges', vkExternFun).SetExternFun(@SF_PlayerChameleonCharges);
  Scope.Add('PlayerChameleonCurType', vkExternFun).SetExternFun(@SF_PlayerChameleonCurType);
  Scope.Add('PlayerChameleonDetected', vkExternFun).SetExternFun(@SF_PlayerChameleonDetected);
  Scope.Add('PlayerLogicChameleon', vkExternFun).SetExternFun(@SF_PlayerLogicChameleon);
  Scope.Add('SwitchToMirrorImage', vkExternFun).SetExternFun(@SF_SwitchToMirrorImage);
  Scope.Add('EquipmentImageName', vkExternFun).SetExternFun(@SF_EquipmentImageName);
  Scope.Add('StarFonImage', vkExternFun).SetExternFun(@SF_StarFonImage);
  Scope.Add('ExtremalTakeOff', vkExternFun).SetExternFun(@SF_ExtremalTakeOff);
  Scope.Add('ForceNextDay', vkExternFun).SetExternFun(@SF_ForceNextDay);
  Scope.Add('ScriptActionsRun', vkExternFun).SetExternFun(@SF_ScriptActionsRun);
  Scope.Add('StarListToPlanetList', vkExternFun).SetExternFun(@SF_StarListToPlanetList);
  Scope.Add('EndGame', vkExternFun).SetExternFun(@SF_EndGame);
  Scope.Add('CustomWin', vkExternFun).SetExternFun(@SF_CustomWin);
  Scope.Add('CustomLose', vkExternFun).SetExternFun(@SF_CustomLose);
  Scope.Add('PirateWin', vkExternFun).SetExternFun(@SF_PirateWin);
  Scope.Add('StartVideo', vkExternFun).SetExternFun(@SF_StartVideo);
  Scope.Add('StartMusic', vkExternFun).SetExternFun(@SF_StartMusic);
  Scope.Add('MusicControls', vkExternFun).SetExternFun(@SF_MusicControls);
  Scope.Add('NoComeKlingToStar', vkExternFun).SetExternFun(@SF_NoComeKlingToStar);
  Scope.Add('NoDropToShip', vkExternFun).SetExternFun(@SF_NoDropToShip);
  Scope.Add('NoTargetToShip', vkExternFun).SetExternFun(@SF_NoTargetToShip);
  Scope.Add('NoTalkToShip', vkExternFun).SetExternFun(@SF_NoTalkToShip);
  Scope.Add('NoScanToShip', vkExternFun).SetExternFun(@SF_NoScanToShip);
  Scope.Add('NoJump', vkExternFun).SetExternFun(@SF_NoJump);
  Scope.Add('NoLanding', vkExternFun).SetExternFun(@SF_NoLanding);
  Scope.Add('NoShopUpdate', vkExternFun).SetExternFun(@SF_NoShopUpdate);
  Scope.Add('PlanetExtraFlags', vkExternFun).SetExternFun(@SF_PlanetExtraFlags);
  Scope.Add('NoDropItem', vkExternFun).SetExternFun(@SF_NoDropItem);
  Scope.Add('CanSellItem', vkExternFun).SetExternFun(@SF_CanSellItem);
  Scope.Add('TruceBetweenShips', vkExternFun).SetExternFun(@SF_TruceBetweenShips);
  Scope.Add('ShipInPrison', vkExternFun).SetExternFun(@SF_ShipInPrison);
  Scope.Add('ShipPartners', vkExternFun).SetExternFun(@SF_ShipPartners);
  Scope.Add('PlayerPirates', vkExternFun).SetExternFun(@SF_PlayerPirates);
  Scope.Add('ShipIsPartner', vkExternFun).SetExternFun(@SF_ShipIsPartner);
  Scope.Add('ShipFreeSpace', vkExternFun).SetExternFun(@SF_ShipFreeSpace);
  Scope.Add('ShipWealth', vkExternFun).SetExternFun(@SF_ShipWealth);
  Scope.Add('DomiksDefeated', vkExternFun).SetExternFun(@SF_DomiksDefeated);
  Scope.Add('CoalitionDefeated', vkExternFun).SetExternFun(@SF_CoalitionDefeated);
  Scope.Add('ShipRefuel', vkExternFun).SetExternFun(@SF_ShipRefuel);
  Scope.Add('ShipRepairEq', vkExternFun).SetExternFun(@SF_ShipRepairEq);
  Scope.Add('ItemInScript', vkExternFun).SetExternFun(@SF_ItemInScript);
  Scope.Add('FindPlanetByAdvancement', vkExternFun).SetExternFun(@SF_FindPlanetByAdvancement);
  Scope.Add('StarListToTransitPlanetList', vkExternFun).SetExternFun(@SF_StarListToTransitPlanetList);
  Scope.Add('GalaxyEvents', vkExternFun).SetExternFun(@SF_GalaxyEvents);
  Scope.Add('GalaxyEventDate', vkExternFun).SetExternFun(@SF_GalaxyEventDate);
  Scope.Add('GalaxyEventType', vkExternFun).SetExternFun(@SF_GalaxyEventType);
  Scope.Add('GalaxyEventData', vkExternFun).SetExternFun(@SF_GalaxyEventData);
  Scope.Add('GalaxyEventsTextData', vkExternFun).SetExternFun(@SF_GalaxyEventsTextData);
  Scope.Add('PlanetNews', vkExternFun).SetExternFun(@SF_PlanetNews);
  Scope.Add('PlanetNewsDate', vkExternFun).SetExternFun(@SF_PlanetNewsDate);
  Scope.Add('PlanetNewsType', vkExternFun).SetExternFun(@SF_PlanetNewsType);
  Scope.Add('PlanetNewsText', vkExternFun).SetExternFun(@SF_PlanetNewsText);
  Scope.Add('ControlledSystems', vkExternFun).SetExternFun(@SF_ControlledSystems);
  Scope.Add('DeltaWin', vkExternFun).SetExternFun(@SF_DeltaWin);
  Scope.Add('ShipInFear', vkExternFun).SetExternFun(@SF_ShipInFear);
  Scope.Add('CreateGoods', vkExternFun).SetExternFun(@SF_CreateGoods);
  Scope.Add('GetNodesFromShip', vkExternFun).SetExternFun(@SF_GetNodesFromShip);
  Scope.Add('GetNodesFromStorage', vkExternFun).SetExternFun(@SF_GetNodesFromStorage);
  Scope.Add('RangerBaseNodes', vkExternFun).SetExternFun(@SF_RangerBaseNodes);
  Scope.Add('RuinsAllowModernization', vkExternFun).SetExternFun(@SF_RuinsAllowModernization);
  Scope.Add('RuinsMicromoduleChain', vkExternFun).SetExternFun(@SF_RuinsMicromoduleChain);
  Scope.Add('DomikKilledInCurSystem', vkExternFun).SetExternFun(@SF_DomikKilledInCurSystem);
  Scope.Add('ShipTypeN', vkExternFun).SetExternFun(@SF_ShipTypeN);
  Scope.Add('ShipSubType', vkExternFun).SetExternFun(@SF_ShipSubType);
  Scope.Add('ShipChangeStar', vkExternFun).SetExternFun(@SF_ShipChangeStar);
  Scope.Add('IsFilm', vkExternFun).SetExternFun(@SF_IsFilm);
  Scope.Add('FilmFlags', vkExternFun).SetExternFun(@SF_FilmFlags);
  Scope.Add('ShowEffect', vkExternFun).SetExternFun(@SF_ShowEffect);
  Scope.Add('ShowStaticEffect', vkExternFun).SetExternFun(@SF_ShowStaticEffect);
  Scope.Add('ShipConnect', vkExternFun).SetExternFun(@SF_ShipConnect);
  Scope.Add('FilmSound', vkExternFun).SetExternFun(@SF_FilmSound);
  Scope.Add('FireWeapon', vkExternFun).SetExternFun(@SF_FireWeapon);
  Scope.Add('WeaponHit', vkExternFun).SetExternFun(@SF_WeaponHit);
  Scope.Add('DealDamageToShip', vkExternFun).SetExternFun(@SF_DealDamageToShip);
  Scope.Add('LaunchMissile', vkExternFun).SetExternFun(@SF_LaunchMissile);
  Scope.Add('SpawnMissile', vkExternFun).SetExternFun(@SF_SpawnMissile);
  Scope.Add('BonusText', vkExternFun).SetExternFun(@SF_BonusText);
  Scope.Add('PlanetPirateClan', vkExternFun).SetExternFun(@SF_PlanetPirateClan);
  Scope.Add('Blazer', vkExternFun).SetExternFun(@SF_Blazer);
  Scope.Add('Keller', vkExternFun).SetExternFun(@SF_Keller);
  Scope.Add('Terron', vkExternFun).SetExternFun(@SF_Terron);
  Scope.Add('PirateType', vkExternFun).SetExternFun(@SF_PirateType);
  Scope.Add('PlayerQuestInProgress', vkExternFun).SetExternFun(@SF_PlayerQuestInProgress);
  Scope.Add('PlayerQuestsCompleted', vkExternFun).SetExternFun(@SF_PlayerQuestsCompleted);
  Scope.Add('QuestsStatusByNom', vkExternFun).SetExternFun(@SF_QuestsStatusByNom);
  Scope.Add('PlayerPlanetaryBattlesCompleted', vkExternFun).SetExternFun(@SF_PlayerPlanetaryBattlesCompleted);
  Scope.Add('PlayerMayTakeSubCrack', vkExternFun).SetExternFun(@SF_PlayerMayTakeSubCrack);
  Scope.Add('SubCrackCost', vkExternFun).SetExternFun(@SF_SubCrackCost);
  Scope.Add('ShipCalcParam', vkExternFun).SetExternFun(@SF_ShipCalcParam);
  Scope.Add('ShipRefit', vkExternFun).SetExternFun(@SF_ShipRefit);
  Scope.Add('ShipImproveItems', vkExternFun).SetExternFun(@SF_ShipImproveItems);
  Scope.Add('ItemImprovement', vkExternFun).SetExternFun(@SF_ItemImprovement);
  Scope.Add('ShipFreeFlight', vkExternFun).SetExternFun(@SF_ShipFreeFlight);
  Scope.Add('ShipKillFactionInCurSystem', vkExternFun).SetExternFun(@SF_ShipKillFactionInCurSystem);
  Scope.Add('CapitalShipStats', vkExternFun).SetExternFun(@SF_CapitalShipStats);
  Scope.Add('PlayerBridge', vkExternFun).SetExternFun(@SF_PlayerBridge);
  Scope.Add('PlayerDebt', vkExternFun).SetExternFun(@SF_PlayerDebt);
  Scope.Add('PlayerDebtDate', vkExternFun).SetExternFun(@SF_PlayerDebtDate);
  Scope.Add('PlayerDebtCnt', vkExternFun).SetExternFun(@SF_PlayerDebtCnt);
  Scope.Add('PlayerDeposit', vkExternFun).SetExternFun(@SF_PlayerDeposit);
  Scope.Add('PlayerDepositDate', vkExternFun).SetExternFun(@SF_PlayerDepositDate);
  Scope.Add('PlayerDepositDay', vkExternFun).SetExternFun(@SF_PlayerDepositDay);
  Scope.Add('PlayerDepositPercent', vkExternFun).SetExternFun(@SF_PlayerDepositPercent);
  Scope.Add('PlayerMedPolicy', vkExternFun).SetExternFun(@SF_PlayerMedPolicy);
  Scope.Add('ShipCustomShipInfosCount', vkExternFun).SetExternFun(@SF_ShipCustomShipInfosCount);
  Scope.Add('ShipAddCustomShipInfo', vkExternFun).SetExternFun(@SF_ShipAddCustomShipInfo);
  Scope.Add('ShipDeleteCustomShipInfo', vkExternFun).SetExternFun(@SF_ShipDeleteCustomShipInfo);
  Scope.Add('ShipFindCustomShipInfoByType', vkExternFun).SetExternFun(@SF_ShipFindCustomShipInfoByType);
  Scope.Add('ShipCustomShipInfoDescription', vkExternFun).SetExternFun(@SF_ShipCustomShipInfoDescription);
  Scope.Add('ShipCustomShipInfoData', vkExternFun).SetExternFun(@SF_ShipCustomShipInfoData);
  Scope.Add('ShipCustomShipInfoTextData', vkExternFun).SetExternFun(@SF_ShipCustomShipInfoTextData);
  Scope.Add('StarCustomStarInfosCount', vkExternFun).SetExternFun(@SF_StarCustomStarInfosCount);
  Scope.Add('StarAddCustomStarInfo', vkExternFun).SetExternFun(@SF_StarAddCustomStarInfo);
  Scope.Add('StarDeleteCustomStarInfo', vkExternFun).SetExternFun(@SF_StarDeleteCustomStarInfo);
  Scope.Add('StarFindCustomStarInfoByType', vkExternFun).SetExternFun(@SF_StarFindCustomStarInfoByType);
  Scope.Add('StarCustomStarInfoData', vkExternFun).SetExternFun(@SF_StarCustomStarInfoData);
  Scope.Add('ItemCanBeBroken', vkExternFun).SetExternFun(@SF_ItemCanBeBroken);
  Scope.Add('ItemFragility', vkExternFun).SetExternFun(@SF_ItemFragility);
  Scope.Add('ItemDurability', vkExternFun).SetExternFun(@SF_ItemDurability);
  Scope.Add('ItemLevel', vkExternFun).SetExternFun(@SF_ItemLevel);
  Scope.Add('ContainerFuel', vkExternFun).SetExternFun(@SF_ContainerFuel);
  Scope.Add('ItemCharge', vkExternFun).SetExternFun(@SF_ItemCharge);
  Scope.Add('MissilesToRearm', vkExternFun).SetExternFun(@SF_MissilesToRearm);
  Scope.Add('WeaponAmmunition', vkExternFun).SetExternFun(@SF_WeaponAmmunition);
  Scope.Add('WeaponMaxAmmunition', vkExternFun).SetExternFun(@SF_WeaponMaxAmmunition);
  Scope.Add('ShipSpecialBonuses', vkExternFun).SetExternFun(@SF_ShipSpecialBonuses);
  Scope.Add('ItemExtraSpecials', vkExternFun).SetExternFun(@SF_ItemExtraSpecials);
  Scope.Add('ItemExtraSpecialsCountByType', vkExternFun).SetExternFun(@SF_ItemExtraSpecialsCountByType);
  Scope.Add('ItemExtraSpecialsAddByType', vkExternFun).SetExternFun(@SF_ItemExtraSpecialsAddByType);
  Scope.Add('ItemExtraSpecialsDeleteByType', vkExternFun).SetExternFun(@SF_ItemExtraSpecialsDeleteByType);
  Scope.Add('ExecuteCodeFromString', vkExternFun).SetExternFun(@SF_ExecuteCodeFromString);
  Scope.Add('GenerateCodeStringFromBlock', vkExternFun).SetExternFun(@SF_GenerateCodeStringFromBlock);
  Scope.Add('ItemOnUseCode', vkExternFun).SetExternFun(@SF_ItemOnUseCode);
  Scope.Add('ItemOnActCode', vkExternFun).SetExternFun(@SF_ItemOnActCode);
  Scope.Add('CreateActCodeEvent', vkExternFun).SetExternFun(@SF_CreateActCodeEvent);
  Scope.Add('CurItem', vkExternFun).SetExternFun(@SF_CurItem);
  Scope.Add('CurInfo', vkExternFun).SetExternFun(@SF_CurInfo);
  Scope.Add('ScriptItemActShip', vkExternFun).SetExternFun(@SF_ScriptItemActShip);
  Scope.Add('ScriptItemActObject1', vkExternFun).SetExternFun(@SF_ScriptItemActObject1);
  Scope.Add('ScriptItemActObject2', vkExternFun).SetExternFun(@SF_ScriptItemActObject2);
  Scope.Add('ScriptItemActParam', vkExternFun).SetExternFun(@SF_ScriptItemActParam);
  Scope.Add('ScriptItemActionType', vkExternFun).SetExternFun(@SF_ScriptItemActionType);
  Scope.Add('OnUseCodeTranclucator', vkExternFun).SetExternFun(@SF_OnUseCodeTranclucator);
  Scope.Add('OnUseCodeTransmitter', vkExternFun).SetExternFun(@SF_OnUseCodeTransmitter);
  Scope.Add('OnUseCodeBlackHole', vkExternFun).SetExternFun(@SF_OnUseCodeBlackHole);
  Scope.Add('OnUseCodeMissileDef', vkExternFun).SetExternFun(@SF_OnUseCodeMissileDef);
  Scope.Add('MessageBox', vkExternFun).SetExternFun(@SF_MessageBox);
  Scope.Add('MessageBoxYesNo', vkExternFun).SetExternFun(@SF_MessageBoxYesNo);
  Scope.Add('CountBox', vkExternFun).SetExternFun(@SF_CountBox);
  Scope.Add('NumberBox', vkExternFun).SetExternFun(@SF_NumberBox);
  Scope.Add('TextBox', vkExternFun).SetExternFun(@SF_TextBox);
  Scope.Add('ListBox', vkExternFun).SetExternFun(@SF_ListBox);
  Scope.Add('FormCurShip', vkExternFun).SetExternFun(@SF_FormCurShip);
  Scope.Add('UselessItemText', vkExternFun).SetExternFun(@SF_UselessItemText);
  Scope.Add('UselessItemData', vkExternFun).SetExternFun(@SF_UselessItemData);
  Scope.Add('GetAchievementSHU', vkExternFun).SetExternFun(@SF_GetAchievementSHU);
  Scope.Add('GetAchievementGIRLSHIRE', vkExternFun).SetExternFun(@SF_GetAchievementGIRLSHIRE);
  Scope.Add('GetAchievementGIRLSQUEST', vkExternFun).SetExternFun(@SF_GetAchievementGIRLSQUEST);
  Scope.Add('GetAchievementPIRATEWIN', vkExternFun).SetExternFun(@SF_GetAchievementPIRATEWIN);
  Scope.Add('GetAchievementCOALLITION', vkExternFun).SetExternFun(@SF_GetAchievementCOALLITION);
  Scope.Add('GetAchievementHULL', vkExternFun).SetExternFun(@SF_GetAchievementHULL);
  Scope.Add('UICheckElement', vkExternFun).SetExternFun(@SF_UICheckElement);
  Scope.Add('InterfaceState', vkExternFun).SetExternFun(@SF_InterfaceState);
  Scope.Add('InterfaceText', vkExternFun).SetExternFun(@SF_InterfaceText);
  Scope.Add('InterfaceImage', vkExternFun).SetExternFun(@SF_InterfaceImage);
  Scope.Add('InterfacePos', vkExternFun).SetExternFun(@SF_InterfacePos);
  Scope.Add('InterfaceSize', vkExternFun).SetExternFun(@SF_InterfaceSize);
  Scope.Add('ButtonClick', vkExternFun).SetExternFun(@SF_ButtonClick);
  Scope.Add('SetFocus', vkExternFun).SetExternFun(@SF_SetFocus);
  Scope.Add('CurrentForm', vkExternFun).SetExternFun(@SF_CurrentForm);
  Scope.Add('FormShipCurItem', vkExternFun).SetExternFun(@SF_FormShipCurItem);
  Scope.Add('UpdateFormShip', vkExternFun).SetExternFun(@SF_UpdateFormShip);
  Scope.Add('FormChange', vkExternFun).SetExternFun(@SF_FormChange);
  Scope.Add('RunChildForm', vkExternFun).SetExternFun(@SF_RunChildForm);
  Scope.Add('OpenCustomForm', vkExternFun).SetExternFun(@SF_OpenCustomForm);
  Scope.Add('CloseCustomForm', vkExternFun).SetExternFun(@SF_CloseCustomForm);
  Scope.Add('CustomInterfaceState', vkExternFun).SetExternFun(@SF_CustomInterfaceState);
  Scope.Add('CustomInterfaceText', vkExternFun).SetExternFun(@SF_CustomInterfaceText);
  Scope.Add('CustomInterfaceImage', vkExternFun).SetExternFun(@SF_CustomInterfaceImage);
  Scope.Add('CustomInterfacePos', vkExternFun).SetExternFun(@SF_CustomInterfacePos);
  Scope.Add('CustomInterfacePosZ', vkExternFun).SetExternFun(@SF_CustomInterfacePosZ);
  Scope.Add('CustomInterfaceSize', vkExternFun).SetExternFun(@SF_CustomInterfaceSize);
  Scope.Add('StarMapCenterView', vkExternFun).SetExternFun(@SF_StarMapCenterView);
  Scope.Add('StarMapCurPosX', vkExternFun).SetExternFun(@SF_StarMapCurPosX);
  Scope.Add('StarMapCurPosY', vkExternFun).SetExternFun(@SF_StarMapCurPosY);
  Scope.Add('StarMapCustomSelectionMode', vkExternFun).SetExternFun(@SF_StarMapCustomSelectionMode);
  Scope.Add('StarMapBlinkingMessage', vkExternFun).SetExternFun(@SF_StarMapBlinkingMessage);
  Scope.Add('BlinkingWarning', vkExternFun).SetExternFun(@SF_BlinkingWarning);
  Scope.Add('CustomWeaponTypes', vkExternFun).SetExternFun(@SF_CustomWeaponTypes);
  Scope.Add('InventNewCustomWeapon', vkExternFun).SetExternFun(@SF_InventNewCustomWeapon);
  Scope.Add('GetCustomWeaponInfo', vkExternFun).SetExternFun(@SF_GetCustomWeaponInfo);
  Scope.Add('GetCustomWeaponData', vkExternFun).SetExternFun(@SF_GetCustomWeaponData);
  Scope.Add('GetCustomWeaponPrimaryDamageType', vkExternFun).SetExternFun(@SF_GetCustomWeaponPrimaryDamageType);
  Scope.Add('SetCustomWeaponAvailability', vkExternFun).SetExternFun(@SF_SetCustomWeaponAvailability);
  Scope.Add('SetCustomWeaponSE', vkExternFun).SetExternFun(@SF_SetCustomWeaponSE);
  Scope.Add('SetCustomWeaponPrimaryData', vkExternFun).SetExternFun(@SF_SetCustomWeaponPrimaryData);
  Scope.Add('SetCustomWeaponSizeAndCost', vkExternFun).SetExternFun(@SF_SetCustomWeaponSizeAndCost);
  Scope.Add('SetCustomWeaponDamageData', vkExternFun).SetExternFun(@SF_SetCustomWeaponDamageData);
  Scope.Add('SetCustomWeaponShotData', vkExternFun).SetExternFun(@SF_SetCustomWeaponShotData);
  Scope.Add('SetCustomMissileWeaponStats', vkExternFun).SetExternFun(@SF_SetCustomMissileWeaponStats);
  Scope.Add('StarCustomFaction', vkExternFun).SetExternFun(@SF_StarCustomFaction);
  Scope.Add('ShipCustomFaction', vkExternFun).SetExternFun(@SF_ShipCustomFaction);
  Scope.Add('EqCustomFaction', vkExternFun).SetExternFun(@SF_EqCustomFaction);
  Scope.Add('PlanetCustomFaction', vkExternFun).SetExternFun(@SF_PlanetCustomFaction);
  Scope.Add('ImportedFunction', vkExternFun).SetExternFun(@SF_ImportedFunction);
  Scope.Add('ImportAll', vkExternFun).SetExternFun(@SF_ImportAll);
  Scope.Add('GalaxyPtr', vkExternFun).SetExternFun(@SF_GalaxyPtr);
  Scope.Add('t_ArtDefToEnergy', vkInt).SetInt(Ord(t_ArtDefToEnergy));
  Scope.Add('t_ArtEnergyPulse', vkInt).SetInt(Ord(t_ArtEnergyPulse));
  Scope.Add('t_ArtEnergyDef', vkInt).SetInt(Ord(t_ArtEnergyDef));
  Scope.Add('t_ArtSplinter', vkInt).SetInt(Ord(t_ArtSplinter));
  Scope.Add('t_ArtDecelerate', vkInt).SetInt(Ord(t_ArtDecelerate));
  Scope.Add('t_ArtMissileDef', vkInt).SetInt(Ord(t_ArtMissileDef));
  Scope.Add('t_ArtForsage', vkInt).SetInt(Ord(t_ArtForsage));
  Scope.Add('t_ArtWeaponToSpeed', vkInt).SetInt(Ord(t_ArtWeaponToSpeed));
  Scope.Add('t_ArtGiperJump', vkInt).SetInt(Ord(t_ArtGiperJump));
  Scope.Add('t_ArtBlackHole', vkInt).SetInt(Ord(t_ArtBlackHole));
  Scope.Add('t_ArtDefToArms1', vkInt).SetInt(Ord(t_ArtDefToArms1));
  Scope.Add('t_ArtDefToArms2', vkInt).SetInt(Ord(t_ArtDefToArms2));
  Scope.Add('t_ArtArtefactor', vkInt).SetInt(Ord(t_ArtArtefactor));
  Scope.Add('t_ArtBio', vkInt).SetInt(Ord(t_ArtBio));
  Scope.Add('t_ArtPDTurret', vkInt).SetInt(Ord(t_ArtPDTurret));
  Scope.Add('t_ArtFastRacks', vkInt).SetInt(Ord(t_ArtFastRacks));
  Scope.Add('t_Cistern', vkInt).SetInt(Ord(t_Cistern));
  Scope.Add('t_Satellite', vkInt).SetInt(Ord(t_Satellite));
  Scope.Add('t_MicroModule', vkInt).SetInt(Ord(t_MicroModule));
  Scope.Add('t_UselessCountableItem', vkInt).SetInt(Ord(t_UselessCountableItem));
  Scope.Add('TalkMoney', vkInt).SetInt(Ord(tkMoneyDemand));
  Scope.Add('TalkGoods', vkInt).SetInt(Ord(tkGoodsDemand));
  Scope.Add('TalkTruce', vkInt).SetInt(Ord(tkTruceOffer));
  Scope.Add('TalkAttack', vkInt).SetInt(Ord(tkAttack));
  Scope.Add('TalkBreakPartner', vkInt).SetInt(Ord(tkPartnerBreak));
  Scope.Add('TalkPartnerTheEnd', vkInt).SetInt(Ord(tkPartnerEnd));
  Scope.Add('TalkPartnerRiot', vkInt).SetInt(Ord(tkPartnerRiot));
  for BonusIndex := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
    Scope.Add(EquipmentBonusNames[BonusIndex], vkInt).SetInt(Ord(BonusIndex));
  for ActionIndex := Low(TScriptActionType) to High(TScriptActionType) do
    Scope.Add(ScriptActionTypeNames[ActionIndex], vkInt).SetInt(Ord(ActionIndex));
  ScriptRequestThread := TScriptThread.Create;
  ScriptRequestThread.SetPriority(2);
  ScriptItemContextStack := TList.Create;
  ScriptItemInfoContextStack := TList.Create;
  ScriptActionShipStack := TList.Create;
  ScriptActionObject1Stack := TList.Create;
  ScriptActionObject2Stack := TList.Create;
  ScriptActionParamStack := TList.Create;
  ScriptActionTypeStack := TList.Create;
  QueuedTextQuests := TList.Create;
  QueuedArcadeBattles := TList.Create;
  QueuedPlanetaryBattles := TList.Create;
  QueuedVideos := TList.Create;
  StagedArcadeShips := TObjectList.Create;
end;
{ @end $641194 }

end.
