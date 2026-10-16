unit aScriptFun;

interface

uses EC_BlockPar, EC_Expression, aItem, aShip;

// av[0] holds the script result.

procedure SF_GRun(av: array of TVarEC; code: TCodeEC); // @addr 0x00605B50
procedure SF_GCntRun(av: array of TVarEC; code: TCodeEC); // @addr 0x00605B78
procedure SF_GLastTurnRun(av: array of TVarEC; code: TCodeEC); // @addr 0x00605C74
procedure SF_GAllCntRun(av: array of TVarEC; code: TCodeEC); // @addr 0x00605DA8
procedure SF_IsScriptActive(av: array of TVarEC; code: TCodeEC); // @addr 0x00605E48
procedure SF_GetValueFromScript(av: array of TVarEC; code: TCodeEC); // @addr 0x00605F1C
procedure SF_RunFunctionFromScript(av: array of TVarEC; code: TCodeEC); // @addr 0x00606318
procedure SF_GetVariableName(av: array of TVarEC; code: TCodeEC); // @addr 0x006067AC
procedure SF_GetVariableType(av: array of TVarEC; code: TCodeEC); // @addr 0x0060681C
procedure SF_StatusPlayer(av: array of TVarEC; code: TCodeEC); // @addr 0x006078D4
procedure SF_AddPlanetNews(av: array of TVarEC; code: TCodeEC); // @addr 0x00606894
procedure SF_AddJournalRecord(av: array of TVarEC; code: TCodeEC); // @addr 0x00606970
procedure SF_AutoBattle(av: array of TVarEC; code: TCodeEC); // @addr 0x00606B0C
procedure SF_GetOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x00606B78
procedure SF_GiveReward(av: array of TVarEC; code: TCodeEC); // @addr 0x00606BEC
procedure SF_GiveRewardByNom(av: array of TVarEC; code: TCodeEC); // @addr 0x00606D04
procedure SF_CountReward(av: array of TVarEC; code: TCodeEC); // @addr 0x00606D84
procedure SF_CountRewardByNom(av: array of TVarEC; code: TCodeEC); // @addr 0x00606FC0
procedure SF_DeleteRewardByNom(av: array of TVarEC; code: TCodeEC); // @addr 0x006070A0
procedure SF_Rnd(av: array of TVarEC; code: TCodeEC); // @addr 0x00607734
procedure SF_GameDateTxtByTurn(av: array of TVarEC; code: TCodeEC); // @addr 0x00607828
procedure SF_Id(av: array of TVarEC; code: TCodeEC); // @addr 0x00607930
procedure SF_SetName(av: array of TVarEC; code: TCodeEC); // @addr 0x00607BFC
procedure SF_UseTranclucator(av: array of TVarEC; code: TCodeEC); // @addr 0x00607D3C
procedure SF_HullDamage(av: array of TVarEC; code: TCodeEC); // @addr 0x00607F98
procedure SF_Hitpoints(av: array of TVarEC; code: TCodeEC); // @addr 0x00608054
procedure SF_Hit(av: array of TVarEC; code: TCodeEC); // @addr 0x006080F8
procedure SF_ChangeGlobalRelationsShips(av: array of TVarEC; code: TCodeEC); // @addr 0x006081C0
procedure SF_ChangeGlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC); // @addr 0x00608324
procedure SF_GlobalRelationsShips(av: array of TVarEC; code: TCodeEC); // @addr 0x0060846C
procedure SF_GlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC); // @addr 0x00608584
procedure SF_SetRelationGroup(av: array of TVarEC; code: TCodeEC); // @addr 0x00608688
procedure SF_SetRelationPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x00608714
procedure SF_GetRelationPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x006087A0
procedure SF_CurTurn(av: array of TVarEC; code: TCodeEC); // @addr 0x00608828
procedure SF_ShipType(av: array of TVarEC; code: TCodeEC); // @addr 0x00608874
procedure SF_ConName(av: array of TVarEC; code: TCodeEC); // @addr 0x00608A74
procedure SF_StarName(av: array of TVarEC; code: TCodeEC); // @addr 0x00608B54
procedure SF_StarMapLabel(av: array of TVarEC; code: TCodeEC); // @addr 0x00608BC4
procedure SF_PlanetName(av: array of TVarEC; code: TCodeEC); // @addr 0x00608C8C
procedure SF_IdToPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x00608CFC
procedure SF_IdToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00608D78
procedure SF_IdToItem(av: array of TVarEC; code: TCodeEC); // @addr 0x00608E10
procedure SF_PlanetSetGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x00608E8C
procedure SF_ShipName(av: array of TVarEC; code: TCodeEC); // @addr 0x00608F18
procedure SF_ShipRank(av: array of TVarEC; code: TCodeEC); // @addr 0x00608FC0
procedure SF_ShipRankPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x0060903C
procedure SF_ShipNextRankPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x006090D8
procedure SF_ShipRaiseRank(av: array of TVarEC; code: TCodeEC); // @addr 0x00609168
procedure SF_ShipStar(av: array of TVarEC; code: TCodeEC); // @addr 0x00609208
procedure SF_StarToCon(av: array of TVarEC; code: TCodeEC); // @addr 0x00609278
procedure SF_ConNear(av: array of TVarEC; code: TCodeEC); // @addr 0x006092E8
procedure SF_ConStars(av: array of TVarEC; code: TCodeEC); // @addr 0x006093C4
procedure SF_ConStar(av: array of TVarEC; code: TCodeEC); // @addr 0x00609434
procedure SF_GalaxyStars(av: array of TVarEC; code: TCodeEC); // @addr 0x006094D4
procedure SF_GalaxyStar(av: array of TVarEC; code: TCodeEC); // @addr 0x00609508
procedure SF_StarAngleBetween(av: array of TVarEC; code: TCodeEC); // @addr 0x006095A8
procedure SF_FindPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x006096AC
procedure SF_IsPlayer(av: array of TVarEC; code: TCodeEC); // @addr 0x0060B238
procedure SF_GroupCount(av: array of TVarEC; code: TCodeEC); // @addr 0x0060B2B4
procedure SF_GroupIn(av: array of TVarEC; code: TCodeEC); // @addr 0x0060B36C
procedure SF_CountIn(av: array of TVarEC; code: TCodeEC); // @addr 0x0060B6C8
procedure SF_ChangeState(av: array of TVarEC; code: TCodeEC); // @addr 0x0060BBB0
procedure SF_NearestGroup(av: array of TVarEC; code: TCodeEC); // @addr 0x0060BA64
procedure SF_StarAngle(av: array of TVarEC; code: TCodeEC); // @addr 0x0060BD94
procedure SF_NewsAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x0060BE20
procedure SF_MsgAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x0060BECC
procedure SF_Ether(av: array of TVarEC; code: TCodeEC); // @addr 0x0060C018
procedure SF_CustomEther(av: array of TVarEC; code: TCodeEC); // @addr 0x0060C36C
procedure SF_EtherDelete(av: array of TVarEC; code: TCodeEC); // @addr 0x0060C6D8
procedure SF_EtherIdAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x0060C778
procedure SF_EtherIdDelete(av: array of TVarEC; code: TCodeEC); // @addr 0x0060C820
procedure SF_EtherState(av: array of TVarEC; code: TCodeEC); // @addr 0x0060C8E4
procedure SF_ConChangeRelationToRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x0060C99C
procedure SF_GetData(av: array of TVarEC; code: TCodeEC); // @addr 0x0060CA94
procedure SF_SetData(av: array of TVarEC; code: TCodeEC); // @addr 0x0060CB30
procedure SF_ShipData(av: array of TVarEC; code: TCodeEC); // @addr 0x0060CC0C
procedure SF_Format(av: array of TVarEC; code: TCodeEC); // @addr 0x0060CC7C
procedure SF_DeleteTags(av: array of TVarEC; code: TCodeEC); // @addr 0x0060CF40
procedure SF_Dialog(av: array of TVarEC; code: TCodeEC); // @addr 0x0060CFF0
procedure SF_DText(av: array of TVarEC; code: TCodeEC); // @addr 0x0060D39C
procedure SF_DAddText(av: array of TVarEC; code: TCodeEC); // @addr 0x0060D5A4
procedure SF_DAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x0060D7C0
procedure SF_DChange(av: array of TVarEC; code: TCodeEC); // @addr 0x0060F890
procedure SF_DAnswer(av: array of TVarEC; code: TCodeEC); // @addr 0x0060D830
procedure SF_Player(av: array of TVarEC; code: TCodeEC); // @addr 0x0060F8FC
procedure SF_ItemExist(av: array of TVarEC; code: TCodeEC); // @addr 0x0060F92C
procedure SF_ItemIn(av: array of TVarEC; code: TCodeEC); // @addr 0x0060F9AC
procedure SF_ItemCost(av: array of TVarEC; code: TCodeEC); // @addr 0x00617974
procedure SF_ItemCount(av: array of TVarEC; code: TCodeEC); // @addr 0x0060FC38
procedure SF_ShipPicksItem(av: array of TVarEC; code: TCodeEC); // @addr 0x006071A4
procedure SF_DropItem(av: array of TVarEC; code: TCodeEC); // @addr 0x00607300
procedure SF_DropScriptItem(av: array of TVarEC; code: TCodeEC); // @addr 0x0060759C
procedure SF_DeleteEquipment(av: array of TVarEC; code: TCodeEC); // @addr 0x00607668
procedure SF_DecayGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x0060FD28
procedure SF_UpsurgeGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x0060FDD4
procedure SF_GoodsAdd(av: array of TVarEC; code: TCodeEC); // @addr 0x0060FE60
procedure SF_GoodsCount(av: array of TVarEC; code: TCodeEC); // @addr 0x0060FF68
procedure SF_GoodsCost(av: array of TVarEC; code: TCodeEC); // @addr 0x0060FFE8
procedure SF_GoodsRuinsForBuy(av: array of TVarEC; code: TCodeEC); // @addr 0x00610068
procedure SF_ShipGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x006100FC
procedure SF_ShipGoodsIllegalOnPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x00610218
procedure SF_GoodsDrop(av: array of TVarEC; code: TCodeEC); // @addr 0x00610318
procedure SF_UselessItemCreate(av: array of TVarEC; code: TCodeEC); // @addr 0x0061054C
procedure SF_GoodsSellPrice(av: array of TVarEC; code: TCodeEC); // @addr 0x00610740
procedure SF_GoodsBuyPrice(av: array of TVarEC; code: TCodeEC); // @addr 0x00610838
procedure SF_CountTurn(av: array of TVarEC; code: TCodeEC); // @addr 0x00610930
procedure SF_ShipSetBad(av: array of TVarEC; code: TCodeEC); // @addr 0x00610D0C
procedure SF_GroupSetBad(av: array of TVarEC; code: TCodeEC); // @addr 0x00610D90
procedure SF_ShipSetPartner(av: array of TVarEC; code: TCodeEC); // @addr 0x00610E50
procedure SF_ShipJoin(av: array of TVarEC; code: TCodeEC); // @addr 0x00610F30
procedure SF_ShipOut(av: array of TVarEC; code: TCodeEC); // @addr 0x00611334
procedure SF_AllShipOut(av: array of TVarEC; code: TCodeEC); // @addr 0x006113A0
procedure SF_ShipInScript(av: array of TVarEC; code: TCodeEC); // @addr 0x006113CC
procedure SF_ShipInGameEvent(av: array of TVarEC; code: TCodeEC); // @addr 0x00611478
procedure SF_ShipInCurScript(av: array of TVarEC; code: TCodeEC); // @addr 0x00611554
procedure SF_ShipInNormalSpace(av: array of TVarEC; code: TCodeEC); // @addr 0x00611604
procedure SF_ShipInHole(av: array of TVarEC; code: TCodeEC); // @addr 0x0061169C
procedure SF_ShipIsTakeoff(av: array of TVarEC; code: TCodeEC); // @addr 0x0061174C
procedure SF_ShipCntWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x006117D4
procedure SF_ShipWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x0061184C
procedure SF_ShipEqInSlot(av: array of TVarEC; code: TCodeEC); // @addr 0x006118E4
procedure SF_ArtefactTypeInUse(av: array of TVarEC; code: TCodeEC); // @addr 0x006119AC
procedure SF_ArtefactTypeBoosted(av: array of TVarEC; code: TCodeEC); // @addr 0x00611B60
procedure SF_ShipSpeed(av: array of TVarEC; code: TCodeEC); // @addr 0x00611CB4
procedure SF_EnginePower(av: array of TVarEC; code: TCodeEC); // @addr 0x00611D24
procedure SF_ShipJump(av: array of TVarEC; code: TCodeEC); // @addr 0x00611E48
procedure SF_ShipArmor(av: array of TVarEC; code: TCodeEC); // @addr 0x00611EBC
procedure SF_ShipProtectability(av: array of TVarEC; code: TCodeEC); // @addr 0x00611F30
procedure SF_ShipDroidRepair(av: array of TVarEC; code: TCodeEC); // @addr 0x00611FC4
procedure SF_ShipRadarRange(av: array of TVarEC; code: TCodeEC); // @addr 0x00612070
procedure SF_ShipScanerPower(av: array of TVarEC; code: TCodeEC); // @addr 0x006120E8
procedure SF_ShipHookPower(av: array of TVarEC; code: TCodeEC); // @addr 0x00612164
procedure SF_ShipHookRange(av: array of TVarEC; code: TCodeEC); // @addr 0x0061220C
procedure SF_ShipAverageDamage(av: array of TVarEC; code: TCodeEC); // @addr 0x006122A8
procedure SF_ShipHealthFactor(av: array of TVarEC; code: TCodeEC); // @addr 0x00612484
procedure SF_ShipHealthFactorStatus(av: array of TVarEC; code: TCodeEC); // @addr 0x006126D8
procedure SF_PlayerImmunity(av: array of TVarEC; code: TCodeEC); // @addr 0x006127D8
procedure SF_ShipStatusEffect(av: array of TVarEC; code: TCodeEC); // @addr 0x00612828
procedure SF_ShipGroup(av: array of TVarEC; code: TCodeEC); // @addr 0x00611C28
procedure SF_ShipCanJump(av: array of TVarEC; code: TCodeEC); // @addr 0x00609A34
procedure SF_ShipInStar(av: array of TVarEC; code: TCodeEC); // @addr 0x00609B80
procedure SF_ShipInPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x00609C18
procedure SF_ShipStatistic(av: array of TVarEC; code: TCodeEC); // @addr 0x00609CA8
procedure SF_PlayerDominatorStatistic(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A0F8
procedure SF_ShipMoney(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A1B4
procedure SF_ShipFuel(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A248
procedure SF_ShipFuelLow(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A31C
procedure SF_ShipStrengthInBestRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A3D4
procedure SF_ShipStrengthInAverageRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A45C
procedure SF_ChanceToWin(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A4E4
procedure SF_ShipFind(av: array of TVarEC; code: TCodeEC); // @addr 0x0060AAA4
procedure SF_RangerStatus(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A5A0
procedure SF_RangerPlaceInRating(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A874
procedure SF_RangerExcludedFromRating(av: array of TVarEC; code: TCodeEC); // @addr 0x0060A954
procedure SF_GalaxyMoney(av: array of TVarEC; code: TCodeEC); // @addr 0x00607ABC
procedure SF_ShipDestroy(av: array of TVarEC; code: TCodeEC); // @addr 0x0060AB64 @note "Queues destruction without removing the ship immediately; returns the previous flag. An omitted second argument queues destruction, a negative one only queries."
procedure SF_ShipDestroyType(av: array of TVarEC; code: TCodeEC); // @addr 0x0060AC30
procedure SF_ItemDestroy(av: array of TVarEC; code: TCodeEC); // @addr 0x0060AD34
procedure SF_RangersCapital(av: array of TVarEC; code: TCodeEC); // @addr 0x0060ADF0
procedure SF_GroupToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0060AE20
procedure SF_OrderLanding(av: array of TVarEC; code: TCodeEC); // @addr 0x0060B128
procedure SF_OrderJump(av: array of TVarEC; code: TCodeEC); // @addr 0x0060AEF4
procedure SF_GroupIs(av: array of TVarEC; code: TCodeEC); // @addr 0x00612958
procedure SF_StateIs(av: array of TVarEC; code: TCodeEC); // @addr 0x00612A2C
procedure SF_Dist(av: array of TVarEC; code: TCodeEC); // @addr 0x00612B44
procedure SF_Angle(av: array of TVarEC; code: TCodeEC); // @addr 0x00612FB0
procedure SF_Dist2Star(av: array of TVarEC; code: TCodeEC); // @addr 0x0061341C
procedure SF_BuyPirate(av: array of TVarEC; code: TCodeEC); // @addr 0x006134A4
procedure SF_BuyTransport(av: array of TVarEC; code: TCodeEC); // @addr 0x00613554
procedure SF_Name(av: array of TVarEC; code: TCodeEC); // @addr 0x00613620
procedure SF_ShortName(av: array of TVarEC; code: TCodeEC); // @addr 0x006137E8
procedure SF_FirstGiveMoney(av: array of TVarEC; code: TCodeEC); // @addr 0x00613974
procedure SF_HaveProgramm(av: array of TVarEC; code: TCodeEC); // @addr 0x006139CC
procedure SF_GetProgramm(av: array of TVarEC; code: TCodeEC); // @addr 0x00613A4C
procedure SF_SetProgramm(av: array of TVarEC; code: TCodeEC); // @addr 0x00613ACC
procedure SF_DomikProgramm(av: array of TVarEC; code: TCodeEC); // @addr 0x00613B70
procedure SF_DomikProgrammDate(av: array of TVarEC; code: TCodeEC); // @addr 0x00613C5C
procedure SF_HoleMamaCreate(av: array of TVarEC; code: TCodeEC); // @addr 0x00613CF0
procedure SF_HoleCreate(av: array of TVarEC; code: TCodeEC); // @addr 0x00614064
procedure SF_TerronWeaponLock(av: array of TVarEC; code: TCodeEC); // @addr 0x00614384
procedure SF_TerronGrowLock(av: array of TVarEC; code: TCodeEC); // @addr 0x006143BC
procedure SF_TerronLandingLock(av: array of TVarEC; code: TCodeEC); // @addr 0x006143F4
procedure SF_TerronToStar(av: array of TVarEC; code: TCodeEC); // @addr 0x0061442C
procedure SF_KellerLeave(av: array of TVarEC; code: TCodeEC); // @addr 0x00614464
procedure SF_KellerNewResearch(av: array of TVarEC; code: TCodeEC); // @addr 0x0061449C
procedure SF_KellerKill(av: array of TVarEC; code: TCodeEC); // @addr 0x006144D4
procedure SF_BlazerLanding(av: array of TVarEC; code: TCodeEC); // @addr 0x006144FC
procedure SF_BlazerSelfDestruction(av: array of TVarEC; code: TCodeEC); // @addr 0x006145CC
procedure SF_GalaxyShipId(av: array of TVarEC; code: TCodeEC); // @addr 0x00614604
procedure SF_NearCivilPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x00614634
procedure SF_SkipGreeting(av: array of TVarEC; code: TCodeEC); // @addr 0x00614728
procedure SF_Sound(av: array of TVarEC; code: TCodeEC); // @addr 0x00614754
procedure SF_Tips(av: array of TVarEC; code: TCodeEC); // @addr 0x006147F4
procedure SF_TipsState(av: array of TVarEC; code: TCodeEC); // @addr 0x00614858
procedure SF_CT(av: array of TVarEC; code: TCodeEC); // @addr 0x00614A24
procedure SF_BlockExist(av: array of TVarEC; code: TCodeEC); // @addr 0x00614D1C
procedure SF_GetMainData(av: array of TVarEC; code: TCodeEC); // @addr 0x00615110
procedure SF_GetGameOptions(av: array of TVarEC; code: TCodeEC); // @addr 0x00615328
procedure SF_ResourceExist(av: array of TVarEC; code: TCodeEC); // @addr 0x006154C0
procedure SF_SFT(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C520
procedure SF_CurrentMods(av: array of TVarEC; code: TCodeEC); // @addr 0x00615570
procedure SF_RobotSupport(av: array of TVarEC; code: TCodeEC); // @addr 0x00615698
procedure SF_StarShips(av: array of TVarEC; code: TCodeEC); // @addr 0x006156E0
procedure SF_StarPlanets(av: array of TVarEC; code: TCodeEC); // @addr 0x00615798
procedure SF_StarMissiles(av: array of TVarEC; code: TCodeEC); // @addr 0x00615854
procedure SF_StarAsteroids(av: array of TVarEC; code: TCodeEC); // @addr 0x00615910
procedure SF_GroupShip(av: array of TVarEC; code: TCodeEC); // @addr 0x006159CC
procedure SF_ShipItems(av: array of TVarEC; code: TCodeEC); // @addr 0x00615AA4
procedure SF_ShipArts(av: array of TVarEC; code: TCodeEC); // @addr 0x00615B68
procedure SF_PlayerTranclucators(av: array of TVarEC; code: TCodeEC); // @addr 0x00615C2C
procedure SF_ArtTranclucatorToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00615D30
procedure SF_TranclucatorData(av: array of TVarEC; code: TCodeEC); // @addr 0x00615E00
procedure SF_LinkItemToScript(av: array of TVarEC; code: TCodeEC); // @addr 0x00616768
procedure SF_ReleaseItemFromScript(av: array of TVarEC; code: TCodeEC); // @addr 0x00616910
procedure SF_ScriptItemData(av: array of TVarEC; code: TCodeEC); // @addr 0x006169BC
procedure SF_ScriptItemTextData(av: array of TVarEC; code: TCodeEC); // @addr 0x00616B10
procedure SF_ScriptItemToItem(av: array of TVarEC; code: TCodeEC); // @addr 0x00616CC4
procedure SF_GetShipPirateRank(av: array of TVarEC; code: TCodeEC); // @addr 0x00616D7C
procedure SF_ShipPirateRankPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x00616DF8
procedure SF_ShipNextPirateRankPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x00616E9C
procedure SF_ShipInPirateClan(av: array of TVarEC; code: TCodeEC); // @addr 0x00616F34
procedure SF_ShipOnSidePirateClan(av: array of TVarEC; code: TCodeEC); // @addr 0x00616FD0
procedure SF_RaisePirateRank(av: array of TVarEC; code: TCodeEC); // @addr 0x00617050
procedure SF_ItemType(av: array of TVarEC; code: TCodeEC); // @addr 0x00617104
procedure SF_CustomWeaponType(av: array of TVarEC; code: TCodeEC); // @addr 0x006171B4
procedure SF_ItemName(av: array of TVarEC; code: TCodeEC); // @addr 0x00617288
procedure SF_ItemFullName(av: array of TVarEC; code: TCodeEC); // @addr 0x00617374
procedure SF_ItemSize(av: array of TVarEC; code: TCodeEC); // @addr 0x00617464
procedure SF_ItemOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x006177D0
procedure SF_ItemSubrace(av: array of TVarEC; code: TCodeEC); // @addr 0x00617898
procedure SF_ItemIsInUse(av: array of TVarEC; code: TCodeEC); // @addr 0x00617A3C
procedure SF_ItemIsInSet(av: array of TVarEC; code: TCodeEC); // @addr 0x00617C70
procedure SF_PlayerEqSet(av: array of TVarEC; code: TCodeEC); // @addr 0x00617DDC
procedure SF_ItemIsBroken(av: array of TVarEC; code: TCodeEC); // @addr 0x00617EBC
procedure SF_ShipCanUseEq(av: array of TVarEC; code: TCodeEC); // @addr 0x00617FC4
procedure SF_ShipCanRepairEq(av: array of TVarEC; code: TCodeEC); // @addr 0x00618098
procedure SF_ShipTechLevelKnowledge(av: array of TVarEC; code: TCodeEC); // @addr 0x00618170
procedure SF_WeaponTarget(av: array of TVarEC; code: TCodeEC); // @addr 0x00618208
procedure SF_GetEquipmentStats(av: array of TVarEC; code: TCodeEC); // @addr 0x00618310
procedure SF_SetEquipmentStats(av: array of TVarEC; code: TCodeEC); // @addr 0x006189C4
procedure SF_CreateHull(av: array of TVarEC; code: TCodeEC); // @addr 0x00618DB0
procedure SF_CreateEquipment(av: array of TVarEC; code: TCodeEC); // @addr 0x00618EA0
procedure SF_CreateArt(av: array of TVarEC; code: TCodeEC); // @addr 0x00618F7C
procedure SF_CreateCustomWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x00619000
procedure SF_CreateCustomArt(av: array of TVarEC; code: TCodeEC); // @addr 0x006190EC
procedure SF_CustomArtData(av: array of TVarEC; code: TCodeEC); // @addr 0x006191FC
procedure SF_CustomArtTextData(av: array of TVarEC; code: TCodeEC); // @addr 0x006193B8
procedure SF_CreateMM(av: array of TVarEC; code: TCodeEC); // @addr 0x006195E0
procedure SF_CreateNodes(av: array of TVarEC; code: TCodeEC); // @addr 0x0061966C
procedure SF_CreateCustomCountableItem(av: array of TVarEC; code: TCodeEC); // @addr 0x00619734
procedure SF_CreateZond(av: array of TVarEC; code: TCodeEC); // @addr 0x0061983C
procedure SF_ExistingZonds(av: array of TVarEC; code: TCodeEC); // @addr 0x0061991C
procedure SF_FreeItem(av: array of TVarEC; code: TCodeEC); // @addr 0x006199D0
procedure SF_ShipJoinsClan(av: array of TVarEC; code: TCodeEC); // @addr 0x00619A84
procedure SF_AddItemToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00619B28
procedure SF_GetItemFromShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00619D2C
procedure SF_GetArtFromShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A08C
procedure SF_ArrangeItems(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A190
procedure SF_AddItemToPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A218
procedure SF_GetItemFromPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A2C4
procedure SF_AddItemToShop(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A3A4
procedure SF_GetItemFromShop(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A53C
procedure SF_AddItemToStorage(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A6DC
procedure SF_GetItemFromStorage(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A8C0
procedure SF_FindItemInStorage(av: array of TVarEC; code: TCodeEC); // @addr 0x0061A994
procedure SF_PutItemInVault(av: array of TVarEC; code: TCodeEC); // @addr 0x0061AA58
procedure SF_GetItemFromVault(av: array of TVarEC; code: TCodeEC); // @addr 0x0061AB48
procedure SF_DropItemInSystem(av: array of TVarEC; code: TCodeEC); // @addr 0x0061AC18
procedure SF_StopMovingItem(av: array of TVarEC; code: TCodeEC); // @addr 0x0061ADCC
procedure SF_StarItems(av: array of TVarEC; code: TCodeEC); // @addr 0x0061AF30
procedure SF_GetItemFromStar(av: array of TVarEC; code: TCodeEC); // @addr 0x0061AFF4
procedure SF_PlanetItems(av: array of TVarEC; code: TCodeEC); // @addr 0x0061B140
procedure SF_StorageItems(av: array of TVarEC; code: TCodeEC); // @addr 0x0061B21C
procedure SF_StorageItemLocation(av: array of TVarEC; code: TCodeEC); // @addr 0x0061B2A0
procedure SF_ShopItems(av: array of TVarEC; code: TCodeEC); // @addr 0x0061B34C
procedure SF_AddDialogOverride(av: array of TVarEC; code: TCodeEC); // @addr 0x0061B5DC
procedure SF_AddDialogInject(av: array of TVarEC; code: TCodeEC); // @addr 0x0061B7AC
procedure SF_InjectAnswer(av: array of TVarEC; code: TCodeEC); // @addr 0x0061BA04
procedure SF_AddDialogBlock(av: array of TVarEC; code: TCodeEC); // @addr 0x0061BE50
procedure SF_GotoGov(av: array of TVarEC; code: TCodeEC); // @addr 0x0061BFD8
procedure SF_GetShipPlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C028
procedure SF_GetShipHomePlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C0BC
procedure SF_GetShipRuins(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C134
procedure SF_GetTalkShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C1C8
procedure SF_GetTalkType(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C238
procedure SF_TalkByAI(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C1F8
procedure SF_ScriptRun(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C268
procedure SF_CreateABShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C740
procedure SF_ConvertToABShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C920
procedure SF_ABShipModifiers(av: array of TVarEC; code: TCodeEC); // @addr 0x0061CC28
procedure SF_StartAB(av: array of TVarEC; code: TCodeEC); // @addr 0x0061CEC0
procedure SF_StartTextQuest(av: array of TVarEC; code: TCodeEC); // @addr 0x0061C5E8 @note "No arguments returns queue length; otherwise queues name and optional success/failure captions, setting GQuestStatus to 1."
procedure SF_StartRobots(av: array of TVarEC; code: TCodeEC); // @addr 0x0061D078
procedure SF_MarkRobotsMapAsUsed(av: array of TVarEC; code: TCodeEC); // @addr 0x0061D254
procedure SF_ShipOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x0061D4B0
procedure SF_ShipPilotRace(av: array of TVarEC; code: TCodeEC); // @addr 0x0061D5B0
procedure SF_ShipSkill(av: array of TVarEC; code: TCodeEC); // @addr 0x0061D650
procedure SF_ShipFace(av: array of TVarEC; code: TCodeEC); // @addr 0x0061DB5C
procedure SF_ShipFreeExp(av: array of TVarEC; code: TCodeEC); // @addr 0x0061DDD4
procedure SF_GetShipExpByType(av: array of TVarEC; code: TCodeEC); // @addr 0x0061DE68
procedure SF_CoordX(av: array of TVarEC; code: TCodeEC); // @addr 0x0061DFD8 @note "Moving a star updates its drawn StarLinks, but not distance caches, sector boundaries or adjacency."
procedure SF_CoordY(av: array of TVarEC; code: TCodeEC); // @addr 0x0061E508 @note "Moving a star updates its drawn StarLinks, but not distance caches, sector boundaries or adjacency."
procedure SF_ShipSetCoords(av: array of TVarEC; code: TCodeEC); // @addr 0x0061EA38
procedure SF_ShipAngle(av: array of TVarEC; code: TCodeEC); // @addr 0x0061EAD8
procedure SF_ObjectType(av: array of TVarEC; code: TCodeEC); // @addr 0x0061EB8C
procedure SF_ShipInHyperSpace(av: array of TVarEC; code: TCodeEC); // @addr 0x0061ED00
procedure SF_ShipStatus(av: array of TVarEC; code: TCodeEC); // @addr 0x0061EDAC
procedure SF_BuyRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x0061EEA8
procedure SF_BuyWarrior(av: array of TVarEC; code: TCodeEC); // @addr 0x0061EF3C
procedure SF_BuyBigWarrior(av: array of TVarEC; code: TCodeEC); // @addr 0x0061EFD0
procedure SF_BuyDomik(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F068
procedure SF_BuyDomikExtremal(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F0E0
procedure SF_BuyTranclucator(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F1BC
procedure SF_TransferShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F258
procedure SF_OrderForsage(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F550
procedure SF_OrderNone(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F690
procedure SF_OrderMove(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F770
procedure SF_OrderTeleport(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F968
procedure SF_OrderTakeOff(av: array of TVarEC; code: TCodeEC); // @addr 0x0061FAE4
procedure SF_OrderFollowShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0061FB6C
procedure SF_OrderJumpHole(av: array of TVarEC; code: TCodeEC); // @addr 0x0061FCAC
procedure SF_RelationToRanger(av: array of TVarEC; code: TCodeEC); // @addr 0x0061FDD0
procedure SF_RelationToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0061FFC8
procedure SF_StarOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x00620098
procedure SF_StarBattle(av: array of TVarEC; code: TCodeEC); // @addr 0x0062012C
procedure SF_StarSeries(av: array of TVarEC; code: TCodeEC); // @addr 0x006201B0
procedure SF_StarHoles(av: array of TVarEC; code: TCodeEC); // @addr 0x00620244
procedure SF_StarNearbyStars(av: array of TVarEC; code: TCodeEC); // @addr 0x00620348
procedure SF_StarNearbyStarsDist(av: array of TVarEC; code: TCodeEC); // @addr 0x006203F0
procedure SF_StarSetGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x0062049C
procedure SF_CreatePlanet(av: array of TVarEC; code: TCodeEC); // @addr 0x006205CC
procedure SF_PlanetSetGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x006206F0
procedure SF_PlanetGetGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x006208A4
procedure SF_PlanetPopulation(av: array of TVarEC; code: TCodeEC); // @addr 0x0062091C
procedure SF_PlanetOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x006209B0 @note "Updates planet ownership flags, not the containing star's faction or its other planets."
procedure SF_PlanetRace(av: array of TVarEC; code: TCodeEC); // @addr 0x00620A48
procedure SF_PlanetGov(av: array of TVarEC; code: TCodeEC); // @addr 0x00620AD4
procedure SF_PlanetEco(av: array of TVarEC; code: TCodeEC); // @addr 0x00620B60
procedure SF_PlanetTerrain(av: array of TVarEC; code: TCodeEC); // @addr 0x00620BEC
procedure SF_PlanetTerrainExplored(av: array of TVarEC; code: TCodeEC); // @addr 0x00620D68
procedure SF_PlanetOrbitRadius(av: array of TVarEC; code: TCodeEC); // @addr 0x00620EB8
procedure SF_PlanetOrbitalVelocity(av: array of TVarEC; code: TCodeEC); // @addr 0x00620F54
procedure SF_PlanetSize(av: array of TVarEC; code: TCodeEC); // @addr 0x00621014
procedure SF_PlanetCurInvention(av: array of TVarEC; code: TCodeEC); // @addr 0x0062109C
procedure SF_PlanetCurInventionPoints(av: array of TVarEC; code: TCodeEC); // @addr 0x0062112C
procedure SF_PlanetInventionLevel(av: array of TVarEC; code: TCodeEC); // @addr 0x006211CC
procedure SF_PlanetBoostInventions(av: array of TVarEC; code: TCodeEC); // @addr 0x00621274
procedure SF_PlanetWarriors(av: array of TVarEC; code: TCodeEC); // @addr 0x00621310
procedure SF_GalaxySectors(av: array of TVarEC; code: TCodeEC); // @addr 0x006213D0
procedure SF_GalaxyTechLevel(av: array of TVarEC; code: TCodeEC); // @addr 0x00621458
procedure SF_GalaxyDominatorResearchPercent(av: array of TVarEC; code: TCodeEC); // @addr 0x0062148C
procedure SF_GalaxyDominatorResearchMaterial(av: array of TVarEC; code: TCodeEC); // @addr 0x00621550
procedure SF_GalaxyDiffLevels(av: array of TVarEC; code: TCodeEC); // @addr 0x00621618
procedure SF_SectorVisible(av: array of TVarEC; code: TCodeEC); // @addr 0x006216A0
procedure SF_HullHP(av: array of TVarEC; code: TCodeEC); // @addr 0x00621794
procedure SF_HullDamageSuspectibility(av: array of TVarEC; code: TCodeEC); // @addr 0x00621B5C
procedure SF_HullType(av: array of TVarEC; code: TCodeEC); // @addr 0x00621CA0
procedure SF_HullSpecial(av: array of TVarEC; code: TCodeEC); // @addr 0x00621DAC
procedure SF_HullSeries(av: array of TVarEC; code: TCodeEC); // @addr 0x00621EBC
procedure SF_GalaxyHoles(av: array of TVarEC; code: TCodeEC); // @addr 0x00621FC4
procedure SF_HoleCreate2(av: array of TVarEC; code: TCodeEC); // @addr 0x00622040
procedure SF_HoleStar1(av: array of TVarEC; code: TCodeEC); // @addr 0x00622304
procedure SF_HoleStar2(av: array of TVarEC; code: TCodeEC); // @addr 0x00622390
procedure SF_HoleX1(av: array of TVarEC; code: TCodeEC); // @addr 0x0062241C
procedure SF_HoleY1(av: array of TVarEC; code: TCodeEC); // @addr 0x006224B0
procedure SF_HoleX2(av: array of TVarEC; code: TCodeEC); // @addr 0x00622544
procedure SF_HoleY2(av: array of TVarEC; code: TCodeEC); // @addr 0x006225D8
procedure SF_HoleTurnCreate(av: array of TVarEC; code: TCodeEC); // @addr 0x0062266C
procedure SF_HoleMap(av: array of TVarEC; code: TCodeEC); // @addr 0x00622704
procedure SF_HoleGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x006227D0
procedure SF_StarRuins(av: array of TVarEC; code: TCodeEC); // @addr 0x006228F8
procedure SF_CreateQuestItem(av: array of TVarEC; code: TCodeEC); // @addr 0x00622B20
procedure SF_ShipOrder(av: array of TVarEC; code: TCodeEC); // @addr 0x00622C90
procedure SF_ShipTurnBeforeEndOrder(av: array of TVarEC; code: TCodeEC); // @addr 0x00622C0C
procedure SF_ShipOrderData1(av: array of TVarEC; code: TCodeEC); // @addr 0x00622ED4
procedure SF_ShipOrderData2(av: array of TVarEC; code: TCodeEC); // @addr 0x00622F88
procedure SF_ShipOrderObj(av: array of TVarEC; code: TCodeEC); // @addr 0x0062303C
procedure SF_ShipDestination(av: array of TVarEC; code: TCodeEC); // @addr 0x00623118
procedure SF_BuildRuins(av: array of TVarEC; code: TCodeEC); // @addr 0x006232B0
procedure SF_BuildCustomRuins(av: array of TVarEC; code: TCodeEC); // @addr 0x0062335C
procedure SF_RuinsChangeType(av: array of TVarEC; code: TCodeEC); // @addr 0x00623458
procedure SF_ShipStanding(av: array of TVarEC; code: TCodeEC); // @addr 0x00623568
procedure SF_ShipSlots(av: array of TVarEC; code: TCodeEC); // @addr 0x006235FC
procedure SF_MissileStar(av: array of TVarEC; code: TCodeEC); // @addr 0x00623758
procedure SF_MissileType(av: array of TVarEC; code: TCodeEC); // @addr 0x006237CC
procedure SF_CustomMissileType(av: array of TVarEC; code: TCodeEC); // @addr 0x00623840
procedure SF_MissileOwner(av: array of TVarEC; code: TCodeEC); // @addr 0x006238BC
procedure SF_MissileWeaponID(av: array of TVarEC; code: TCodeEC); // @addr 0x00623950
procedure SF_MissileTarget(av: array of TVarEC; code: TCodeEC); // @addr 0x006239C8
procedure SF_MissileMaxDamage(av: array of TVarEC; code: TCodeEC); // @addr 0x00623A70
procedure SF_MissileMinDamage(av: array of TVarEC; code: TCodeEC); // @addr 0x00623B08
procedure SF_MissileLive(av: array of TVarEC; code: TCodeEC); // @addr 0x00623BA0
procedure SF_MissileSpeed(av: array of TVarEC; code: TCodeEC); // @addr 0x00623C34
procedure SF_MissileAngle(av: array of TVarEC; code: TCodeEC); // @addr 0x00623CD8
procedure SF_AsteroidMinerals(av: array of TVarEC; code: TCodeEC); // @addr 0x00623D7C
procedure SF_AsteroidGraph(av: array of TVarEC; code: TCodeEC); // @addr 0x00623E14
procedure SF_AsteroidRespawn(av: array of TVarEC; code: TCodeEC); // @addr 0x00623F34
procedure SF_ArrayAdd(Args: array of TVarEC; Code: TCodeEC); // @addr 0x00623FA8
procedure SF_ArrayDelete(Args: array of TVarEC; Code: TCodeEC); // @addr 0x006240F8
procedure SF_ArrayClear(Args: array of TVarEC; Code: TCodeEC); // @addr 0x00624244
procedure SF_ArrayDim(Args: array of TVarEC; Code: TCodeEC); // @addr 0x00624318
procedure SF_ArraySort(Args: array of TVarEC; Code: TCodeEC); // @addr 0x006243D4
procedure SF_ArraySortPartial(Args: array of TVarEC; Code: TCodeEC); // @addr 0x00624638
procedure SF_ArrayRandomize(Args: array of TVarEC; Code: TCodeEC); // @addr 0x006248A0
procedure SF_ArrayFind(Args: array of TVarEC; Code: TCodeEC); // @addr 0x00624B6C
procedure SF_ArrayFindInSorted(Args: array of TVarEC; Code: TCodeEC); // @addr 0x00624DD0
procedure SF_DistToNearestEnemySystem(av: array of TVarEC; code: TCodeEC); // @addr 0x0062509C
procedure SF_StarEnemyThreatLevel(av: array of TVarEC; code: TCodeEC); // @addr 0x00625188
procedure SF_BuildListOfQuestPossibleLocations(av: array of TVarEC; code: TCodeEC); // @addr 0x00625460
procedure SF_FindItemInShip(av: array of TVarEC; code: TCodeEC); // @addr 0x006258AC
procedure SF_GalaxyRangers(av: array of TVarEC; code: TCodeEC); // @addr 0x0062599C
procedure SF_MakeShipEnterStar(av: array of TVarEC; code: TCodeEC); // @addr 0x00625A18
procedure SF_ShipGetBad(av: array of TVarEC; code: TCodeEC); // @addr 0x00625B9C
procedure SF_ShipAddDropItem(av: array of TVarEC; code: TCodeEC); // @addr 0x00625C1C
procedure SF_OrderLock(av: array of TVarEC; code: TCodeEC); // @addr 0x0061F4C0
procedure SF_BonusCount(av: array of TVarEC; code: TCodeEC); // @addr 0x00625CB8
procedure SF_SeriesCount(av: array of TVarEC; code: TCodeEC); // @addr 0x00625CE8
procedure SF_BonusPriority(av: array of TVarEC; code: TCodeEC); // @addr 0x00625D18
procedure SF_BonusIsSpecial(av: array of TVarEC; code: TCodeEC); // @addr 0x00625E0C
procedure SF_BonusName(av: array of TVarEC; code: TCodeEC); // @addr 0x00625EFC
procedure SF_BonusNumInCfg(av: array of TVarEC; code: TCodeEC); // @addr 0x00625FE4
procedure SF_SeriesNumInCfg(av: array of TVarEC; code: TCodeEC); // @addr 0x006260EC
procedure SF_BonusValue(av: array of TVarEC; code: TCodeEC); // @addr 0x006261F4
procedure SF_FindBonusByName(av: array of TVarEC; code: TCodeEC); // @addr 0x006262EC
procedure SF_FindSeriesByName(av: array of TVarEC; code: TCodeEC); // @addr 0x006263D4
procedure SF_FindBonusByCustomTag(av: array of TVarEC; code: TCodeEC); // @addr 0x006264BC
procedure SF_FindBonusByNameInCfg(av: array of TVarEC; code: TCodeEC); // @addr 0x006265D0
procedure SF_BonusCustomTag(av: array of TVarEC; code: TCodeEC); // @addr 0x006266C0
procedure SF_CreateEquipmentWithSpecial(av: array of TVarEC; code: TCodeEC); // @addr 0x006267F8
procedure SF_SpecialToEquipment(av: array of TVarEC; code: TCodeEC); // @addr 0x00626978
procedure SF_ModuleToEquipment(av: array of TVarEC; code: TCodeEC); // @addr 0x00626D18
procedure SF_EqSpecial(av: array of TVarEC; code: TCodeEC); // @addr 0x00626FB8
procedure SF_EqModule(av: array of TVarEC; code: TCodeEC); // @addr 0x006270E0
procedure SF_MayAddBonusToEq(av: array of TVarEC; code: TCodeEC); // @addr 0x00627208
procedure SF_BuildListOfMMByPriority(av: array of TVarEC; code: TCodeEC); // @addr 0x00627370
procedure SF_BuildListOfNewShips(av: array of TVarEC; code: TCodeEC); // @addr 0x006277A4
procedure SF_PlanetToStar(av: array of TVarEC; code: TCodeEC); // @addr 0x00627E80
procedure SF_Chameleon(av: array of TVarEC; code: TCodeEC); // @addr 0x00627EF4
procedure SF_IsChameleon(av: array of TVarEC; code: TCodeEC); // @addr 0x00628150
procedure SF_PlayerChameleonCharges(av: array of TVarEC; code: TCodeEC); // @addr 0x006281E0
procedure SF_PlayerChameleonCurType(av: array of TVarEC; code: TCodeEC); // @addr 0x00628290
procedure SF_PlayerChameleonDetected(av: array of TVarEC; code: TCodeEC); // @addr 0x00628320
procedure SF_PlayerLogicChameleon(av: array of TVarEC; code: TCodeEC); // @addr 0x006283D8
procedure SF_SwitchToMirrorImage(av: array of TVarEC; code: TCodeEC); // @addr 0x00628488
procedure SF_EquipmentImageName(av: array of TVarEC; code: TCodeEC); // @addr 0x006286E8
procedure SF_StarFonImage(av: array of TVarEC; code: TCodeEC); // @addr 0x0062899C
procedure SF_ExtremalTakeOff(av: array of TVarEC; code: TCodeEC); // @addr 0x00628A28
procedure SF_ForceNextDay(av: array of TVarEC; code: TCodeEC); // @addr 0x00628A50
procedure SF_ScriptActionsRun(av: array of TVarEC; code: TCodeEC); // @addr 0x00628A78
procedure SF_StarListToPlanetList(av: array of TVarEC; code: TCodeEC); // @addr 0x00628AA4
procedure SF_EndGame(av: array of TVarEC; code: TCodeEC); // @addr 0x00628FC4
procedure SF_CustomWin(av: array of TVarEC; code: TCodeEC); // @addr 0x00629064
procedure SF_CustomLose(av: array of TVarEC; code: TCodeEC); // @addr 0x00629188
procedure SF_PirateWin(av: array of TVarEC; code: TCodeEC); // @addr 0x006292B0 @note "Returns the previous ending; accepts only 1..5 when setting. Does not remove clan objects. Calling at turn zero leaves the ending timestamp zero."
procedure SF_StartVideo(av: array of TVarEC; code: TCodeEC); // @addr 0x00629330
procedure SF_StartMusic(av: array of TVarEC; code: TCodeEC); // @addr 0x00629654
procedure SF_NoComeKlingToStar(av: array of TVarEC; code: TCodeEC); // @addr 0x006299E8
procedure SF_NoDropToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00629A98
procedure SF_NoTargetToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00629B44
procedure SF_NoTalkToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00629BD8
procedure SF_NoScanToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00629CB4
procedure SF_NoJump(av: array of TVarEC; code: TCodeEC); // @addr 0x00629D90
procedure SF_NoLanding(av: array of TVarEC; code: TCodeEC); // @addr 0x00629DF8
procedure SF_NoShopUpdate(av: array of TVarEC; code: TCodeEC); // @addr 0x00629F24
procedure SF_PlanetExtraFlags(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A03C
procedure SF_NoDropItem(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A108
procedure SF_CanSellItem(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A1C8
procedure SF_TruceBetweenShips(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A298
procedure SF_ShipInPrison(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A3AC
procedure SF_ShipPartners(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A4E4
procedure SF_PlayerPirates(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A5E4
procedure SF_ShipIsPartner(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A674
procedure SF_ShipFreeSpace(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A714
procedure SF_ShipWealth(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A790
procedure SF_DomiksDefeated(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A808
procedure SF_CoalitionDefeated(av: array of TVarEC; code: TCodeEC); // @addr 0x0062A9DC
procedure SF_ShipRefuel(av: array of TVarEC; code: TCodeEC); // @addr 0x0062AA60
procedure SF_ShipRepairEq(av: array of TVarEC; code: TCodeEC); // @addr 0x0062AAEC
procedure SF_ItemInScript(av: array of TVarEC; code: TCodeEC); // @addr 0x0062ABB4
procedure SF_FindPlanetByAdvancement(av: array of TVarEC; code: TCodeEC); // @addr 0x0062ACBC
procedure SF_StarListToTransitPlanetList(av: array of TVarEC; code: TCodeEC); // @addr 0x0062AF14
procedure SF_GalaxyEvents(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B49C
procedure SF_GalaxyEventDate(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B4D4
procedure SF_GalaxyEventType(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B580
procedure SF_GalaxyEventData(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B62C
procedure SF_GalaxyEventsTextData(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B714
procedure SF_PlanetNews(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B834
procedure SF_PlanetNewsDate(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B86C
procedure SF_PlanetNewsType(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B914
procedure SF_PlanetNewsText(av: array of TVarEC; code: TCodeEC); // @addr 0x0062B9BC
procedure SF_ControlledSystems(av: array of TVarEC; code: TCodeEC); // @addr 0x0062BAC8
procedure SF_DeltaWin(av: array of TVarEC; code: TCodeEC); // @addr 0x0062BB98
procedure SF_ShipInFear(av: array of TVarEC; code: TCodeEC); // @addr 0x0062BC3C
procedure SF_CreateGoods(av: array of TVarEC; code: TCodeEC); // @addr 0x0062BCC4
procedure SF_GetNodesFromShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0062BD70
procedure SF_GetNodesFromStorage(av: array of TVarEC; code: TCodeEC); // @addr 0x0062BEF0
procedure SF_RangerBaseNodes(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C060
procedure SF_RuinsAllowModernization(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C0FC
procedure SF_RuinsMicromoduleChain(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C1B8
procedure SF_DomikKilledInCurSystem(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C324
procedure SF_ShipTypeN(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C374
procedure SF_ShipSubType(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C3E4
procedure SF_ShipChangeStar(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C5B4
procedure SF_IsFilm(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C680
procedure SF_FilmFlags(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C6D0
procedure SF_ShowEffect(av: array of TVarEC; code: TCodeEC); // @addr 0x0062C830
procedure SF_ShowStaticEffect(av: array of TVarEC; code: TCodeEC); // @addr 0x0062D004
procedure SF_ShipConnect(av: array of TVarEC; code: TCodeEC); // @addr 0x0062D2B4
procedure SF_FilmSound(av: array of TVarEC; code: TCodeEC); // @addr 0x0062D44C
procedure SF_FireWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x0062D640
procedure SF_WeaponHit(av: array of TVarEC; code: TCodeEC); // @addr 0x0062D758
procedure SF_DealDamageToShip(av: array of TVarEC; code: TCodeEC); // @addr 0x0062D8C4
procedure SF_LaunchMissile(av: array of TVarEC; code: TCodeEC); // @addr 0x0062D9E0
procedure SF_SpawnMissile(av: array of TVarEC; code: TCodeEC); // @addr 0x0062DB48
procedure SF_BonusText(av: array of TVarEC; code: TCodeEC); // @addr 0x0062DD44
procedure SF_PlanetPirateClan(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E0D4
procedure SF_Blazer(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E104
procedure SF_Keller(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E134
procedure SF_Terron(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E164
procedure SF_PirateType(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E194
procedure SF_PlayerQuestInProgress(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E224
procedure SF_PlayerQuestsCompleted(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E2C8
procedure SF_QuestsStatusByNom(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E36C
procedure SF_PlayerPlanetaryBattlesCompleted(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E4EC
procedure SF_PlayerMayTakeSubCrack(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E520
procedure SF_SubCrackCost(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E568
procedure SF_ShipCalcParam(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E59C
procedure SF_ShipRefit(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E60C
procedure SF_ShipImproveItems(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E70C
procedure SF_ItemImprovement(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E818
procedure SF_ShipFreeFlight(av: array of TVarEC; code: TCodeEC); // @addr 0x0062E94C
procedure SF_ShipKillFactionInCurSystem(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EA50
procedure SF_CapitalShipStats(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EBA4
procedure SF_PlayerBridge(av: array of TVarEC; code: TCodeEC); // @addr 0x0062ECF0
procedure SF_PlayerDebt(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EDB8
procedure SF_PlayerDebtDate(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EE08
procedure SF_PlayerDebtCnt(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EE58
procedure SF_PlayerDeposit(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EEA8
procedure SF_PlayerDepositDate(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EEF8
procedure SF_PlayerDepositDay(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EF48
procedure SF_PlayerDepositPercent(av: array of TVarEC; code: TCodeEC); // @addr 0x0062EF98
procedure SF_PlayerMedPolicy(av: array of TVarEC; code: TCodeEC); // @addr 0x0062F014
procedure SF_ShipCustomShipInfosCount(av: array of TVarEC; code: TCodeEC); // @addr 0x0062F064
procedure SF_ShipAddCustomShipInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x0062F124
procedure SF_ShipDeleteCustomShipInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x0062F39C
procedure SF_ShipFindCustomShipInfoByType(av: array of TVarEC; code: TCodeEC); // @addr 0x0062F56C
procedure SF_ShipCustomShipInfoDescription(av: array of TVarEC; code: TCodeEC); // @addr 0x0062F68C
procedure SF_ShipCustomShipInfoData(av: array of TVarEC; code: TCodeEC); // @addr 0x0062F990
procedure SF_ShipCustomShipInfoTextData(av: array of TVarEC; code: TCodeEC); // @addr 0x0062FC3C
procedure SF_StarCustomStarInfosCount(av: array of TVarEC; code: TCodeEC); // @addr 0x0062FF14
procedure SF_StarAddCustomStarInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x0062FF98
procedure SF_StarDeleteCustomStarInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x006300F8
procedure SF_StarFindCustomStarInfoByType(av: array of TVarEC; code: TCodeEC); // @addr 0x00630258
procedure SF_StarCustomStarInfoData(av: array of TVarEC; code: TCodeEC); // @addr 0x00630364
procedure SF_ItemCanBeBroken(av: array of TVarEC; code: TCodeEC); // @addr 0x006305E8
procedure SF_ItemFragility(av: array of TVarEC; code: TCodeEC); // @addr 0x006306CC
procedure SF_ItemDurability(av: array of TVarEC; code: TCodeEC); // @addr 0x006307AC
procedure SF_ItemLevel(av: array of TVarEC; code: TCodeEC); // @addr 0x006308D4
procedure SF_ContainerFuel(av: array of TVarEC; code: TCodeEC); // @addr 0x00630C4C
procedure SF_ItemCharge(av: array of TVarEC; code: TCodeEC); // @addr 0x00630D20
procedure SF_MissilesToRearm(av: array of TVarEC; code: TCodeEC); // @addr 0x00630DC4
procedure SF_WeaponAmmunition(av: array of TVarEC; code: TCodeEC); // @addr 0x00630F1C
procedure SF_WeaponMaxAmmunition(av: array of TVarEC; code: TCodeEC); // @addr 0x00631008
procedure SF_ShipSpecialBonuses(av: array of TVarEC; code: TCodeEC); // @addr 0x006310F4
procedure SF_ItemExtraSpecials(av: array of TVarEC; code: TCodeEC); // @addr 0x00631228
procedure SF_ItemExtraSpecialsCountByType(av: array of TVarEC; code: TCodeEC); // @addr 0x00631318
procedure SF_ItemExtraSpecialsAddByType(av: array of TVarEC; code: TCodeEC); // @addr 0x00631414
procedure SF_ItemExtraSpecialsDeleteByType(av: array of TVarEC; code: TCodeEC); // @addr 0x006315EC
procedure SF_ExecuteCodeFromString(av: array of TVarEC; code: TCodeEC); // @addr 0x00631724
procedure SF_GenerateCodeStringFromBlock(av: array of TVarEC; code: TCodeEC); // @addr 0x00631AC0
procedure SF_ItemOnUseCode(av: array of TVarEC; code: TCodeEC); // @addr 0x00631E20
procedure SF_ItemOnActCode(av: array of TVarEC; code: TCodeEC); // @addr 0x00631F24
procedure SF_CreateActCodeEvent(av: array of TVarEC; code: TCodeEC); // @addr 0x006320EC
procedure SF_CurItem(av: array of TVarEC; code: TCodeEC); // @addr 0x006324A0
procedure SF_CurInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x00632500
procedure SF_ScriptItemActShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00632558
procedure SF_ScriptItemActObject1(av: array of TVarEC; code: TCodeEC); // @addr 0x006325B0
procedure SF_ScriptItemActObject2(av: array of TVarEC; code: TCodeEC); // @addr 0x00632608
procedure SF_ScriptItemActParam(av: array of TVarEC; code: TCodeEC); // @addr 0x00632720
procedure SF_ScriptItemActionType(av: array of TVarEC; code: TCodeEC); // @addr 0x00632660
procedure SF_OnUseCodeTranclucator(av: array of TVarEC; code: TCodeEC); // @addr 0x006327A4
procedure SF_OnUseCodeTransmitter(av: array of TVarEC; code: TCodeEC); // @addr 0x00632CBC
procedure SF_OnUseCodeBlackHole(av: array of TVarEC; code: TCodeEC); // @addr 0x00633040
procedure SF_OnUseCodeMissileDef(av: array of TVarEC; code: TCodeEC); // @addr 0x00633598
procedure SF_MessageBox(av: array of TVarEC; code: TCodeEC); // @addr 0x00633734
procedure SF_MessageBoxYesNo(av: array of TVarEC; code: TCodeEC); // @addr 0x0063382C
procedure SF_CountBox(av: array of TVarEC; code: TCodeEC); // @addr 0x0063394C
procedure SF_NumberBox(av: array of TVarEC; code: TCodeEC); // @addr 0x00633B34
procedure SF_TextBox(av: array of TVarEC; code: TCodeEC); // @addr 0x00633DF4
procedure SF_ListBox(av: array of TVarEC; code: TCodeEC); // @addr 0x00633F1C
procedure SF_FormCurShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00634140
procedure SF_UselessItemText(av: array of TVarEC; code: TCodeEC); // @addr 0x006341D4
procedure SF_UselessItemData(av: array of TVarEC; code: TCodeEC); // @addr 0x00634318
procedure SF_GetAchievementSHU(av: array of TVarEC; code: TCodeEC); // @addr 0x00634434
procedure SF_GetAchievementGIRLSHIRE(av: array of TVarEC; code: TCodeEC); // @addr 0x00634468
procedure SF_GetAchievementGIRLSQUEST(av: array of TVarEC; code: TCodeEC); // @addr 0x006344A8
procedure SF_GetAchievementPIRATEWIN(av: array of TVarEC; code: TCodeEC); // @addr 0x006344EC
procedure SF_GetAchievementCOALLITION(av: array of TVarEC; code: TCodeEC); // @addr 0x0063452C
procedure SF_GetAchievementHULL(av: array of TVarEC; code: TCodeEC); // @addr 0x00634570
procedure SF_UICheckElement(av: array of TVarEC; code: TCodeEC); // @addr 0x006345A8
procedure SF_InterfaceState(av: array of TVarEC; code: TCodeEC); // @addr 0x00635174
procedure SF_InterfaceText(av: array of TVarEC; code: TCodeEC); // @addr 0x006354C0
procedure SF_InterfaceImage(av: array of TVarEC; code: TCodeEC); // @addr 0x00635864
procedure SF_InterfacePos(av: array of TVarEC; code: TCodeEC); // @addr 0x00635E6C
procedure SF_InterfaceSize(av: array of TVarEC; code: TCodeEC); // @addr 0x00636140
procedure SF_ButtonClick(av: array of TVarEC; code: TCodeEC); // @addr 0x006363E4
procedure SF_SetFocus(av: array of TVarEC; code: TCodeEC); // @addr 0x006366CC
procedure SF_CurrentForm(av: array of TVarEC; code: TCodeEC); // @addr 0x00636FA4
procedure SF_FormShipCurItem(av: array of TVarEC; code: TCodeEC); // @addr 0x0063683C
procedure SF_UpdateFormShip(av: array of TVarEC; code: TCodeEC); // @addr 0x00636F3C
procedure SF_FormChange(av: array of TVarEC; code: TCodeEC); // @addr 0x00636FD4
procedure SF_RunChildForm(av: array of TVarEC; code: TCodeEC); // @addr 0x00637240
procedure SF_OpenCustomForm(av: array of TVarEC; code: TCodeEC); // @addr 0x00637540
procedure SF_CloseCustomForm(av: array of TVarEC; code: TCodeEC); // @addr 0x006375F0
procedure SF_CustomInterfaceState(av: array of TVarEC; code: TCodeEC); // @addr 0x00637688
procedure SF_CustomInterfaceText(av: array of TVarEC; code: TCodeEC); // @addr 0x00637860
procedure SF_CustomInterfaceImage(av: array of TVarEC; code: TCodeEC); // @addr 0x00637BB8
procedure SF_CustomInterfacePos(av: array of TVarEC; code: TCodeEC); // @addr 0x006380E4
procedure SF_CustomInterfacePosZ(av: array of TVarEC; code: TCodeEC); // @addr 0x0063826C
procedure SF_CustomInterfaceSize(av: array of TVarEC; code: TCodeEC); // @addr 0x006383F0
procedure SF_StarMapCenterView(av: array of TVarEC; code: TCodeEC); // @addr 0x00638578
procedure SF_StarMapCurPosX(av: array of TVarEC; code: TCodeEC); // @addr 0x006386F8
procedure SF_StarMapCurPosY(av: array of TVarEC; code: TCodeEC); // @addr 0x00638734
procedure SF_StarMapCustomSelectionMode(av: array of TVarEC; code: TCodeEC); // @addr 0x00638770
procedure SF_StarMapBlinkingMessage(av: array of TVarEC; code: TCodeEC); // @addr 0x00638948
procedure SF_CustomWeaponTypes(av: array of TVarEC; code: TCodeEC); // @addr 0x00638BD8
procedure SF_InventNewCustomWeapon(av: array of TVarEC; code: TCodeEC); // @addr 0x00638C60
procedure SF_GetCustomWeaponInfo(av: array of TVarEC; code: TCodeEC); // @addr 0x00638ECC
procedure SF_GetCustomWeaponData(av: array of TVarEC; code: TCodeEC); // @addr 0x00638F84
procedure SF_GetCustomWeaponPrimaryDamageType(av: array of TVarEC; code: TCodeEC); // @addr 0x006397E8
procedure SF_SetCustomWeaponAvailability(av: array of TVarEC; code: TCodeEC); // @addr 0x006398E8
procedure SF_SetCustomWeaponSE(av: array of TVarEC; code: TCodeEC); // @addr 0x0063A314
procedure SF_SetCustomWeaponPrimaryData(av: array of TVarEC; code: TCodeEC); // @addr 0x00639BC4
procedure SF_SetCustomWeaponSizeAndCost(av: array of TVarEC; code: TCodeEC); // @addr 0x00639CE4
procedure SF_SetCustomWeaponDamageData(av: array of TVarEC; code: TCodeEC); // @addr 0x00639D7C
procedure SF_SetCustomWeaponShotData(av: array of TVarEC; code: TCodeEC); // @addr 0x00639FC8
procedure SF_SetCustomMissileWeaponStats(av: array of TVarEC; code: TCodeEC); // @addr 0x0063A264
procedure SF_StarCustomFaction(av: array of TVarEC; code: TCodeEC); // @addr 0x0063A410
procedure SF_ShipCustomFaction(av: array of TVarEC; code: TCodeEC); // @addr 0x0063A4FC
procedure SF_EqCustomFaction(av: array of TVarEC; code: TCodeEC); // @addr 0x0063A6A0
procedure SF_PlanetCustomFaction(av: array of TVarEC; code: TCodeEC); // @addr 0x0063A768
procedure SF_ImportedFunction(av: array of TVarEC; code: TCodeEC); // @addr 0x0063A838
procedure SF_ImportAll(av: array of TVarEC; code: TCodeEC); // @addr 0x0063A948
procedure SF_GalaxyPtr(av: array of TVarEC; code: TCodeEC); // @addr 0x0063AA20

procedure SF_MusicControls(av: array of TVarEC; code: TCodeEC); // @addr 0x006297AC
procedure SF_BlinkingWarning(av: array of TVarEC; code: TCodeEC); // @addr 0x006389F8
procedure InitializeScriptBuiltinsAndConstants(Scope: TVarArrayEC); // @addr 0x0063AB6C

implementation

uses Classes, SysUtils, aMyFunction, aConst, aScript, aGalaxy, Globals,
  GlobalsV, GI_MessageLoop, aPlanet, aPlayer, aNormalShip, aGalaxyStruct,
  aMissile, aAsteroid, aWarrior, aRuins, EC_Str, GR_Main, ThreadCalc,
  fTalk, fGov, fRuinsTalk, aRanger, fShip2, GI_XviD,
  GR_Music, Windows, MMSystem, Math, aKling, SE_Space, SE_Planet, EC_Struct, SE_Hole, aEFilm, fStarMap, fEquipmentShop, GR_Sound, aTranclucator, aPirate, aGalaxyEvent, aTransport, Robot, EC_Mem, GI_MessageBox, Achievements, fHangar, fScaner,
  aEFilmEnd, SE_Weapon, SE_GAIEffect, SE_Process, ab_Ship, ab_ShipAI, ab_W, SE_Ruins, GI_GraphButton, GI_Label, GI_Edit, GI_GAI, GI_GI, GI_Image, fTextBox, fListBox, fCount1, fCount2, fCustom, SE_Ship2, fScore, fAbout, fPanelMain, fGoodsShop2, fGalaxy2, GI_GraphBuf;

{ @routine $605B50 SF_GRun }
procedure SF_GRun(av: array of TVarEC; code: TCodeEC);
begin
  ScriptTemplateStartRequested := True;
end;
{ @end $605B50 }

{ @routine $605B78 SF_GCntRun }
procedure SF_GCntRun(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script SF_GCntRun');
  Index := FindScriptTemplateIndex(av[1].AsString);
  if Index < 0 then raise Exception.Create('Error.Script.NotFound SF_GCntRun');
  av[0].AsInteger := TScriptTemplUnit(ScriptTemplates[Index]).UseCount;
end;
{ @end $605B78 }

{ @routine $605C74 SF_GLastTurnRun }
procedure SF_GLastTurnRun(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_GCntRun');
  Index := FindScriptTemplateIndex(av[1].AsString);
  if Index < 0 then raise Exception.Create('Error.Script.NotFound SF_GLastTurnRun');
  if (High(av) >= 2) and (TScriptTemplUnit(ScriptTemplates[Index]).UseCount < 1) then
    av[0].AsInteger := av[2].AsInteger
  else
    av[0].AsInteger := TScriptTemplUnit(ScriptTemplates[Index]).LastTurn;
end;
{ @end $605C74 }

{ @routine $605DA8 SF_GAllCntRun }
procedure SF_GAllCntRun(av: array of TVarEC; code: TCodeEC);
var
  Count, ClassId, I: Integer;
begin
  if High(av) >= 1 then
  begin
    ClassId := av[1].AsInteger;
    Count := 0;
    for I := 0 to Galaxy.Scripts.Count - 1 do
      if TScript(Galaxy.Scripts[I]).ClassId = ClassId then Inc(Count);
    av[0].AsInteger := Count;
  end
  else av[0].AsInteger := Galaxy.Scripts.Count;
end;
{ @end $605DA8 }

{ @routine $605E48 SF_IsScriptActive }
procedure SF_IsScriptActive(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script IsScriptActive');
  av[0].AsInteger := 0;
  Index := FindScriptTemplateIndex(av[1].AsString);
  if Index >= 0 then
    av[0].AsInteger := Ord(TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex >= 0);
end;
{ @end $605E48 }

{ @routine $605F1C SF_GetValueFromScript }
procedure SF_GetValueFromScript(av: array of TVarEC; code: TCodeEC);
var
  Index, LastArg: Integer;
  Script: TScript;
  Value: TVarEC;
begin
  LastArg := High(av);
  if LastArg < 2 then raise Exception.Create('Error.Script GetValueFromScript');
  if av[1].AsString = '' then
  begin
    Value := ScriptFunctionScope.GetVarNE(av[2].AsString);
    if Value = nil then
      raise Exception.Create('Error.Script GetValueFromScript - var ' + av[2].AsString + ' not found');
  end
  else
  begin
    Index := FindScriptTemplateIndex(av[1].AsString);
    if Index < 0 then Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then Exit;
    Script := Galaxy.Scripts[Index];
    Value := Script.InitCode.LocalVar.GetVarNE(av[2].AsString);
    if Value = nil then Value := Script.TurnCode.LocalVar.GetVarNE(av[2].AsString);
    if Value = nil then Value := ScriptFunctionScope.GetVarNE(av[2].AsString);
    if Value = nil then
      raise Exception.Create('Error.Script GetValueFromScript - var ' + av[2].AsString +
        ' not found in script ' + av[1].AsString);
  end;
  Index := 2;
  while (Value.ValueKind = value_array) and (Index < LastArg) do
  begin
    Inc(Index);
    if av[Index].ValueKind = value_string then
      Value := Value.AsArray.NamedItems[av[Index].AsString]
    else
      Value := Value.AsArray[av[Index].AsInteger];
  end;
  case Value.ValueKind of
    value_int32: av[0].AsInteger := Value.AsInteger;
    value_uint32: av[0].AsDword := Value.AsDword;
    value_float64: av[0].AsFloat := Value.AsFloat;
    value_string: av[0].AsString := Value.AsString;
    value_array: av[0].AsInteger := Value.AsArray.Count;
  end;
end;
{ @end $605F1C }

{ @routine $606318 SF_RunFunctionFromScript }
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
  Index := FindScriptTemplateIndex(av[1].AsString);
  if Index < 0 then Exit;
  Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
  if Index < 0 then Exit;
  Script := Galaxy.Scripts[Index];
  Name := 'g_' + av[2].AsString;
  Value := Script.InitCode.LocalVar.GetVarNE(Name);
  if Value = nil then Value := Script.TurnCode.LocalVar.GetVarNE(Name);
  if (Value = nil) or (Value.ValueKind <> value_script_function) then
    raise Exception.Create('Error.Script RunFunctionFromScript - function ' + Name +
      ' not found in script ' + av[1].AsString);
  CallCode := TCodeEC.Create;
  CallCode.CopyFromFast(Value.AsFunction);
  for I := 3 to LastArg do
    if CallCode.LocalVar[I - 3].Kind = value_reference then
      CallCode.LocalVar[I - 3].SetRef(av[I])
    else
      CallCode.LocalVar[I - 3].Assume(av[I], False);
  SavedScript := CurrentScript;
  try
    CallCode.LocalVar.NamedItems['result'].SetRef(av[0]);
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
{ @end $606318 }

{ @routine $6067AC SF_GetVariableName }
procedure SF_GetVariableName(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetVariableName');
  av[0].AsString := av[1].Name;
end;
{ @end $6067AC }

{ @routine $60681C SF_GetVariableType }
procedure SF_GetVariableType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetVariableType');
  av[0].AsInteger := Ord(av[1].ValueKind);
end;
{ @end $60681C }

{ @routine $606894 SF_AddPlanetNews }
procedure SF_AddPlanetNews(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AddPlanetNews');
  if High(av) > 1 then Galaxy.AddPlanetNews(TGalaxyNewsKind(av[2].AsInteger), av[1].AsString)
  else Galaxy.AddPlanetNews(news_script, av[1].AsString);
end;
{ @end $606894 }

{ @routine $606970 SF_AddJournalRecord }
procedure SF_AddJournalRecord(av: array of TVarEC; code: TCodeEC);
var
  Entry: TJournalRecord;
  I, Turn: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AddJournalRecord');
  if High(av) = 1 then GetPlayer.AddJournalRecord(av[1].AsString)
  else
  begin
    Turn := av[2].AsInteger;
    Entry := TJournalRecord.Create;
    Entry.Text := av[1].AsString;
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
{ @end $606970 }

{ @routine $606B0C SF_AutoBattle }
procedure SF_AutoBattle(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script AutoBattle');
  PendingPlayerFollowTarget := TShip(av[1].AsDword);
end;
{ @end $606B0C }

{ @routine $606B78 SF_GetOwner }
procedure SF_GetOwner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Owner: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script SF_GetOwner');
  Ship := TShip(av[1].AsDword);
  Owner := Ord(Ship.OwnerId);
  av[0].AsInteger := Owner;
end;
{ @end $606B78 }

{ @routine $606BEC SF_GiveReward }
procedure SF_GiveReward(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Owner: TOwnerId; Kind: TAwardKind;
  Award: Integer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script SF_GiveReward');
  Ship := TShip(av[1].AsDword);
  Owner := TOwnerId(av[2].AsInteger);
  Kind := TAwardKind(av[3].AsInteger);
  Award := (Ship as TNormalShip).SelectAward(Owner, [Kind], [ship_dominator..station_custom]);
  if Award = AwardNotFound then RaiseWideMessage('Error RewardNumber=255');
  Ship.AddAward(Award);
  av[0].AsInteger := Award;
end;
{ @end $606BEC }

{ @routine $606D04 SF_GiveRewardByNom }
procedure SF_GiveRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_GiveRewardByNom');
  Ship := TShip(av[1].AsDword);
  Ship.AddAward(av[2].AsInteger);
end;
{ @end $606D04 }

{ @routine $606D84 SF_CountReward }
procedure SF_CountReward(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TAwardKind;
  Index, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_CountReward');
  Ship := TShip(av[1].AsDword);
  if High(av) = 1 then
  begin
    if (Ship.AwardIds = nil) or (Ship.AwardIds.Count = 0) then
    begin
      av[0].AsString := '';
      Exit;
    end;
    av[0].AsString := IntToWideString(Integer(Ship.AwardIds[0]));
    for Index := 1 to Ship.AwardIds.Count - 1 do
      av[0].AsString := av[0].AsString + ',' + IntToWideString(Integer(Ship.AwardIds[Index]));
  end
  else
  begin
    Kind := TAwardKind(av[2].AsInteger);
    if Ship.AwardIds = nil then
    begin
      av[0].AsInteger := 0;
      Exit;
    end;
    Count := 0;
    for Index := 0 to Ship.AwardIds.Count - 1 do
      if SysToReward(LookupLocalizedTextByKey('Reward.' + SysUtils.IntToStr(Integer(Ship.AwardIds[Index])) + '.Type')) = Kind then Inc(Count);
    av[0].AsInteger := Count;
  end;
end;
{ @end $606D84 }

{ @routine $606FC0 SF_CountRewardByNom }
procedure SF_CountRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Count, Award: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_CountRewardByNom');
  Ship := TShip(av[1].AsDword);
  Award := av[2].AsInteger;
  if Ship.AwardIds = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  Count := 0;
  for Index := 0 to Ship.AwardIds.Count - 1 do
    if Integer(Ship.AwardIds[Index]) = Award then Inc(Count);
  av[0].AsInteger := Count;
end;
{ @end $606FC0 }

{ @routine $6070A0 SF_DeleteRewardByNom }
procedure SF_DeleteRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Count, Award: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_DeleteRewardByNom');
  Ship := TShip(av[1].AsDword);
  Award := av[2].AsInteger;
  if High(av) > 2 then Count := av[3].AsInteger else Count := 1;
  av[0].AsInteger := 0;
  if Ship.AwardIds <> nil then
    for Index := Ship.AwardIds.Count - 1 downto 0 do
      if (Integer(Ship.AwardIds[Index]) = Award) or (Award = -1) then
      begin
        Ship.AwardIds.Delete(Index);
        av[0].AsInteger := av[0].AsInteger + 1;
        if av[0].AsInteger >= Count then Break;
      end;
end;
{ @end $6070A0 }

{ @routine $6071A4 SF_ShipPicksItem }
procedure SF_ShipPicksItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ShipPicksItem');
  Ship := TShip(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  if High(av) = 2 then
  begin
    if Ship.HasPickupTarget(Item) then av[0].AsInteger := 1
    else if Ship.IsRecentlyDroppedItem(Item) then av[0].AsInteger := -1
    else av[0].AsInteger := 0;
    Exit;
  end;
  if av[3].AsInteger > 0 then
  begin
    Ship.AddPickupTarget(Item, False);
    if Ship.IsRecentlyDroppedItem(Item) then Ship.RecentlyDroppedItemIds.Delete(Ship.RecentlyDroppedItemIds.IndexOf(Item));
    Exit;
  end;
  if av[3].AsInteger < 0 then
  begin
    Ship.RemovePickupTarget(Item);
    Ship.AddRecentlyDroppedItem(Item);
    Exit;
  end;
  Ship.RemovePickupTarget(Item);
  if Ship.IsRecentlyDroppedItem(Item) then Ship.RecentlyDroppedItemIds.Delete(Ship.RecentlyDroppedItemIds.IndexOf(Item));
end;
{ @end $6071A4 }

{ @routine $607300 SF_DropItem }
procedure SF_DropItem(av: array of TVarEC; code: TCodeEC);
label Done;
var
  Ship: TShip;
  Item: TEquipment;
  Kind: TItemType;
  Index, SavedNoDrop: Integer;
  Found: Boolean;
  Equipped: Byte;
  Binding: TScriptItem;
begin
  Found := False;
  if High(av) < 2 then raise Exception.Create('Error.Script SF_DropItem');
  Ship := TShip(av[1].AsDword);
  if (av[2].ValueKind = value_uint32) and (av[2].AsDword > $10000) then
  begin
    Item := TEquipment(av[2].AsDword);
    if High(av) >= 3 then
    begin
      Binding := TScriptItem(av[3].AsDword);
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
    Kind := TItemType(av[2].AsInteger);
    Equipped := 0;
    if High(av) >= 3 then Equipped := av[3].AsInteger;
    for Index := 0 to Ship.Inventory.Count - 1 do
    begin
      Item := Ship.Inventory[Index];
      if Item.ItemType <> Kind then Continue;
      if Item.EquippedFlag <> Equipped then Continue;
      if High(av) >= 4 then
      begin
        Binding := TScriptItem(av[4].AsDword);
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
    for Index := 0 to Ship.Artefacts.Count - 1 do
    begin
      Item := Ship.Artefacts[Index];
      if Item.ItemType <> Kind then Continue;
      if Item.EquippedFlag <> Equipped then Continue;
      if High(av) >= 4 then
      begin
        Binding := TScriptItem(av[4].AsDword);
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
  Done:
  if not Found then raise Exception.Create('Error.Script SF_DropItem - item not found');
end;
{ @end $607300 }

{ @routine $60759C SF_DropScriptItem }
procedure SF_DropScriptItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptItem;
  SavedNoDrop: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script DropScriptItem');
  Ship := TShip(av[1].AsDword);
  Binding := TScriptItem(av[2].AsDword);
  if (Binding.Item = nil) or ((Ship.Inventory.IndexOf(Binding.Item) < 0) and (Ship.Artefacts.IndexOf(Binding.Item) < 0)) or not Ship.InNormalSpace then Exit;
  SavedNoDrop := Binding.Item.NoDropFlag;
  Binding.Item.NoDropFlag := 0;
  Ship.DropItemIntoStar(Binding.Item);
  if Binding.Item <> nil then Binding.Item.NoDropFlag := SavedNoDrop;
end;
{ @end $60759C }

{ @routine $607668 SF_DeleteEquipment }
procedure SF_DeleteEquipment(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
  Item: TItem;
  Kind: TItemType;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script SF_DeleteEquipment');
  Ship := TShip(av[1].AsDword);
  Index := 0;
  Kind := TItemType(av[2].AsInteger);
  while Index < Ship.Inventory.Count do
  begin
    Item := Ship.Inventory[Index];
    if (Item.ScriptItem = nil) and (Item.ItemType = Kind) then
    begin
      Ship.Inventory.Delete(Index);
      Item.Free;
    end
    else Inc(Index);
  end;
  Ship.RefreshDerivedStats(True);
end;
{ @end $607668 }

{ @routine $607734 SF_Rnd }
procedure SF_Rnd(av: array of TVarEC; code: TCodeEC);
var
  LowValue, HighValue: Integer;
  Seed: Cardinal;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script Rnd');
  if High(av) > 2 then
  begin
    Seed := av[3].AsDword;
    av[0].AsInteger := NextRandomIntRange(av[1].AsInteger, av[2].AsInteger, Seed);
  end
  else if Galaxy <> nil then
    av[0].AsInteger := NextRandomIntRange(av[1].AsInteger, av[2].AsInteger, Galaxy.RandomState)
  else
  begin
    LowValue := av[1].AsInteger;
    HighValue := av[2].AsInteger;
    av[0].AsInteger := LowValue + Random(HighValue - LowValue + 1);
  end;
end;
{ @end $607734 }

{ @routine $607828 SF_GameDateTxtByTurn }
procedure SF_GameDateTxtByTurn(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GameDateTxtByTurn');
  av[0].AsString := FormatGameTurnDate(av[1].AsInteger);
end;
{ @end $607828 }

{ @routine $6078D4 SF_StatusPlayer }
procedure SF_StatusPlayer(av: array of TVarEC; code: TCodeEC);
begin
  case GetPlayer.GetDominantCareer of
    career_trader: av[0].AsInteger := 1;
    career_warrior: av[0].AsInteger := 0;
    career_pirate: av[0].AsInteger := -1;
  end;
end;
{ @end $6078D4 }

{ @routine $607930 SF_Id }
procedure SF_Id(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script SF_Id');
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then av[0].AsDword := TShip(Obj).Id
  else if Obj is TPlanet then av[0].AsDword := TPlanet(Obj).Id
  else if Obj is TStar then av[0].AsDword := TStar(Obj).Id
  else if Obj is TConstellation then av[0].AsDword := TConstellation(Obj).Id
  else if Obj is TItem then av[0].AsDword := TItem(Obj).Id
  else if Obj is THole then av[0].AsDword := THole(Obj).Id
  else if Obj is TMissile then av[0].AsDword := TMissile(Obj).Id
  else if Obj is TAsteroid then av[0].AsDword := TAsteroid(Obj).Id
  else raise Exception.Create('Error.Script SF_Id 2');
end;
{ @end $607930 }

{ @routine $607ABC SF_GalaxyMoney }
procedure SF_GalaxyMoney(av: array of TVarEC; code: TCodeEC);
var
  Owner: TOwnerId;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_GalaxyMoney');
  Owner := owner_human;
  if High(av) >= 2 then Owner := TOwnerId(av[2].AsInteger);
  case av[1].AsInteger of
    0: av[0].AsInteger := Galaxy.ComputeScaledMiniMoney(Owner);
    1: av[0].AsInteger := Galaxy.ComputeScaledSmallMoney(Owner);
    2: av[0].AsInteger := Galaxy.ComputeScaledAverageMoney(Owner);
    3: av[0].AsInteger := Galaxy.ComputeScaledBigMoney(Owner);
    4: av[0].AsInteger := Galaxy.ComputeScaledHugeMoney(Owner);
  else raise Exception.Create('Error.Script SF_GalaxyMoney');
  end;
end;
{ @end $607ABC }

{ @routine $607BFC SF_SetName }
procedure SF_SetName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script SF_SetName');
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then TShip(Obj).Name := av[2].AsString
  else if Obj is TPlanet then TPlanet(Obj).Name := av[2].AsString
  else if Obj is TStar then TStar(Obj).Name := av[2].AsString
  else if Obj is TItem then TItem(Obj).NameOverride := av[2].AsString;
end;
{ @end $607BFC }

{ @routine $607D3C SF_UseTranclucator }
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
  av[0].AsDword := 0;
  Ship := TShip(av[1].AsDword);
  if not Ship.InHyperspace then
  begin
    Obj := nil;
    if High(av) > 1 then Obj := TObject(av[2].AsDword)
    else
      for Index := 0 to Ship.Artefacts.Count - 1 do
      begin
        Obj := Ship.Artefacts[Index];
        if (Obj is TArtefactTranclucator) and (TArtefactTranclucator(Obj).BrokenFlag = 0) then Break;
      end;
    if (Obj <> nil) and (Obj is TArtefactTranclucator) then
    begin
      Artefact := Obj as TArtefactTranclucator;
      Drone := TTranclucator(Artefact.Ship);
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
      av[0].AsDword := Cardinal(Drone);
    end;
  end;
end;
{ @end $607D3C }

{ @routine $607F98 SF_HullDamage }
procedure SF_HullDamage(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script HullDamage');
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is TScriptItem then Hull := THull(TScriptItem(Obj).Item)
  else Hull := THull(Obj);
  av[0].AsInteger := 100 - Round(Hull.HullPoints / Hull.Weight * 100);
end;
{ @end $607F98 }

{ @routine $608054 SF_Hitpoints }
procedure SF_Hitpoints(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Hitpoints');
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is TScriptItem then Hull := THull(TScriptItem(Obj).Item)
  else Hull := THull(Obj);
  av[0].AsInteger := Hull.HullPoints;
end;
{ @end $608054 }

{ @routine $6080F8 SF_Hit }
procedure SF_Hit(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
begin
  if High(av) < 1 then Ship := CurrentScript.CurrentShip else Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  Binding := GetScriptShipBindingForContext(Ship, CurrentScript);
  if High(av) < 2 then av[0].AsInteger := Ord(Binding.Hit or Binding.HitPlayer)
  else if av[2].AsInteger <> 0 then
  begin
    av[0].AsInteger := Ord(Binding.HitPlayer);
    if High(av) > 2 then Binding.HitPlayer := av[3].AsInteger <> 0;
  end
  else
  begin
    av[0].AsInteger := Ord(Binding.Hit);
    if High(av) > 2 then Binding.Hit := av[3].AsInteger <> 0;
  end;
end;
{ @end $6080F8 }

{ @routine $6081C0 SF_ChangeGlobalRelationsShips }
procedure SF_ChangeGlobalRelationsShips(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Mode: TRelationChangeMode;
  ShipTypes: THullShipTypeMask;
  Owners: TOwnerMask;
begin
  if High(av) <> 6 then raise Exception.Create('Error.Script ChangeGlobalRelationsShips');
  if av[1].AsDword = 0 then Exit;
  Ranger := TObject(av[1].AsDword);
  if (Ranger = nil) or not (Ranger is TRanger) then Exit;
  if (av[2].AsDword > 0) and (av[2].AsDword < $FF) then
    Scope := TScriptConstellation(CurrentScript.Constellations[av[2].AsDword]).Constellation
  else if av[2].AsDword <> 0 then Scope := TObject(av[2].AsDword)
  else Scope := nil;
  case av[3].AsDword of
    0: Mode := relation_change_cap;
    1: Mode := relation_change_floor;
    2: Mode := relation_change_add;
    3: Mode := relation_change_subtract;
  else Mode := relation_change_cap;
  end;
  ShipTypes := THullShipTypeMask(Word(av[5].AsDword));
  Owners := TOwnerMask(Byte(av[6].AsDword));
  TRanger(Ranger).ChangeShipRelations(Scope, Mode, av[4].AsInteger, ShipTypes, Owners);
end;
{ @end $6081C0 }

{ @routine $608324 SF_ChangeGlobalRelationsPlanets }
procedure SF_ChangeGlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Mode: TRelationChangeMode;
  Owners: TOwnerMask;
begin
  if High(av) <> 5 then raise Exception.Create('Error.Script ChangeGlobalRelationsPlanets');
  Ranger := TObject(av[1].AsDword);
  if (Ranger = nil) or not (Ranger is TRanger) then Exit;
  if (av[2].AsDword > 0) and (av[2].AsDword < $FF) then
    Scope := TScriptConstellation(CurrentScript.Constellations[av[2].AsDword]).Constellation
  else if av[2].AsDword <> 0 then Scope := TObject(av[2].AsDword)
  else Scope := nil;
  case av[3].AsDword of
    0: Mode := relation_change_cap;
    1: Mode := relation_change_floor;
    2: Mode := relation_change_add;
    3: Mode := relation_change_subtract;
  else Mode := relation_change_cap;
  end;
  Owners := TOwnerMask(Byte(av[5].AsDword));
  TRanger(Ranger).ChangePlanetRelations(Scope, Mode, av[4].AsInteger, Owners);
end;
{ @end $608324 }

{ @routine $60846C SF_GlobalRelationsShips }
procedure SF_GlobalRelationsShips(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  ShipTypes: THullShipTypeMask;
  Owners: TOwnerMask;
begin
  if High(av) <> 4 then raise Exception.Create('Error.Script GlobalRelationsShips');
  Ranger := TObject(av[1].AsDword);
  if (Ranger = nil) or not (Ranger is TRanger) then Exit;
  if (av[2].AsDword > 0) and (av[2].AsDword < $FF) then
    Scope := TScriptConstellation(CurrentScript.Constellations[av[2].AsDword]).Constellation
  else if av[2].AsDword <> 0 then Scope := TObject(av[2].AsDword)
  else Scope := nil;
  ShipTypes := THullShipTypeMask(Word(av[3].AsDword));
  Owners := TOwnerMask(Byte(av[4].AsDword));
  av[0].AsInteger := TRanger(Ranger).GlobalRelationsShips(Scope, ShipTypes, Owners);
end;
{ @end $60846C }

{ @routine $608584 SF_GlobalRelationsPlanets }
procedure SF_GlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Owners: TOwnerMask;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script GlobalRelationsPlanets');
  Ranger := TObject(av[1].AsDword);
  if (Ranger = nil) or not (Ranger is TRanger) then Exit;
  if (av[2].AsDword > 0) and (av[2].AsDword < $FF) then
    Scope := TScriptConstellation(CurrentScript.Constellations[av[2].AsDword]).Constellation
  else if av[2].AsDword <> 0 then Scope := TObject(av[2].AsDword)
  else Scope := nil;
  Owners := TOwnerMask(Byte(av[3].AsDword));
  av[0].AsInteger := TRanger(Ranger).GlobalRelationsPlanets(Scope, Owners);
end;
{ @end $608584 }

{ @routine $608688 SF_SetRelationGroup }
procedure SF_SetRelationGroup(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script SetRelationGroup');
  CurrentScript.SetGroupRelation(av[1].AsInteger, av[2].AsInteger, TRelationLevel(av[3].AsInteger));
end;
{ @end $608688 }

{ @routine $608714 SF_SetRelationPlanet }
procedure SF_SetRelationPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script SetRelationPlanet');
  CurrentScript.SetPlanetRelation(av[2].AsInteger, TPlanet(av[1].AsDword), TRelationLevel(av[3].AsInteger));
end;
{ @end $608714 }

{ @routine $6087A0 SF_GetRelationPlanet }
procedure SF_GetRelationPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GetRelationPlanet');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsDword := Planet.RelationToShip(TShip(av[2].AsDword));
end;
{ @end $6087A0 }

{ @routine $608828 SF_CurTurn }
procedure SF_CurTurn(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.CurrentTurn;
  if High(av) > 0 then Galaxy.CurrentTurn := av[1].AsInteger;
end;
{ @end $608828 }

{ @routine $608874 SF_ShipType }
procedure SF_ShipType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipType');
  Ship := TShip(av[1].AsDword);
  if GetPlayer.RuinsProxy = Ship then av[0].AsString := 'PlayerBridge'
  else if Ship.TypeNameOverrideKey <> '' then av[0].AsString := Ship.TypeNameOverrideKey
  else if (Ship.ScriptShip <> nil) and
    (TScriptShip(Ship.ScriptShip).Script.ScriptFileName = 'Script.PC_fem_rangers') and
    (TScriptShip(Ship.ScriptShip).GetGroup.Name = 'GroupFem') then av[0].AsString := 'FemRanger'
  else av[0].AsString := Ship.GetTypeNameKey;
  if High(av) > 1 then
  begin
    if av[2].AsString = Ship.GetTypeNameKey then Ship.TypeNameOverrideKey := ''
    else Ship.TypeNameOverrideKey := av[2].AsString;
  end;
end;
{ @end $608874 }

{ @routine $608A74 SF_ConName }
procedure SF_ConName(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ConName');
  if av[1].AsDword < Cardinal(Galaxy.Constellations.Count) then
    Constellation := Galaxy.Constellations[av[1].AsDword]
  else Constellation := TConstellation(av[1].AsDword);
  av[0].AsString := Constellation.GetName;
end;
{ @end $608A74 }

{ @routine $608B54 SF_StarName }
procedure SF_StarName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TStar;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script StarName');
  Obj := TStar(av[1].AsDword);
  av[0].AsString := Obj.Name;
end;
{ @end $608B54 }

{ @routine $608BC4 SF_StarMapLabel }
procedure SF_StarMapLabel(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarMapLabel');
  Star := TStar(av[1].AsDword);
  av[0].AsString := Star.MapLabel;
  if High(av) > 1 then Star.MapLabel := av[2].AsString;
end;
{ @end $608BC4 }

{ @routine $608C8C SF_PlanetName }
procedure SF_PlanetName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TPlanet;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script PlanetName');
  Obj := TPlanet(av[1].AsDword);
  av[0].AsString := Obj.Name;
end;
{ @end $608C8C }

{ @routine $608CFC SF_IdToPlanet }
procedure SF_IdToPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script IdToPlanet');
  av[0].AsDword := Cardinal(Galaxy.IdToPlanet(av[1].AsDword));
end;
{ @end $608CFC }

{ @routine $608D78 SF_IdToShip }
procedure SF_IdToShip(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script IdToShip');
  av[0].AsDword := Cardinal(Galaxy.IdToShip(av[1].AsDword, (High(av) > 1) and (av[2].AsInteger <> 0)));
end;
{ @end $608D78 }

{ @routine $608E10 SF_IdToItem }
procedure SF_IdToItem(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script IdToItem');
  av[0].AsDword := Cardinal(Galaxy.IdToItem(av[1].AsDword, False));
end;
{ @end $608E10 }

{ @routine $608E8C SF_PlanetSetGoods }
procedure SF_PlanetSetGoods(av: array of TVarEC; code: TCodeEC);
var
  GoodsIndex: TGoodsIndex;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script PlanetSetGoods');
  GoodsIndex := av[2].AsInteger;
  TPlanet(av[1].AsDword).Goods[GoodsIndex].Count := av[3].AsInteger;
end;
{ @end $608E8C }

{ @routine $608F18 SF_ShipName }
procedure SF_ShipName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipName');
  Obj := TShip(av[1].AsDword);
  av[0].AsString := Obj.GetName;
end;
{ @end $608F18 }

{ @routine $608FC0 SF_ShipRank }
procedure SF_ShipRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipRank');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsInteger := Ship.Rank;
end;
{ @end $608FC0 }

{ @routine $60903C SF_ShipRankPoints }
procedure SF_ShipRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRankPoints');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsInteger := Ship.RankPoints;
  if High(av) > 1 then Ship.RankPoints := av[2].AsInteger;
end;
{ @end $60903C }

{ @routine $6090D8 SF_ShipNextRankPoints }
procedure SF_ShipNextRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipNextRankPoints');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsInteger := CoalitionRankPointThresholds[Ship.Rank];
end;
{ @end $6090D8 }

{ @routine $609168 SF_ShipRaiseRank }
procedure SF_ShipRaiseRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRaiseRank');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  if High(av) > 1 then
  begin
    Ship.Rank := av[2].AsInteger;
    Ship.RankPoints := 0;
  end
  else Ship.TryPromoteRank;
end;
{ @end $609168 }

{ @routine $609208 SF_ShipStar }
procedure SF_ShipStar(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipStar');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := Cardinal(Ship.CurrentStar);
end;
{ @end $609208 }

{ @routine $609278 SF_StarToCon }
procedure SF_StarToCon(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script StarToCon');
  av[0].AsDword := Cardinal(TStar(av[1].AsDword).Constellation);
end;
{ @end $609278 }

{ @routine $6092E8 SF_ConNear }
procedure SF_ConNear(av: array of TVarEC; code: TCodeEC);
var
  I, Count, J, ArgCount: Integer;
  Constellation, Neighbor, Candidate: TConstellation;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ConNear');
  Constellation := TConstellation(av[1].AsDword);
  Count := Constellation.AdjacentConstellations.Count;
  ArgCount := High(av) - 1;
  for I := 0 to Count - 1 do
  begin
    Neighbor := Constellation.AdjacentConstellations[I];
    for J := 0 to ArgCount - 1 do
    begin
      Candidate := TConstellation(av[2 + J].AsDword);
      if Neighbor = Candidate then
      begin
        av[0].AsInteger := 1;
        Exit;
      end;
    end;
  end;
  av[0].AsInteger := 0;
end;
{ @end $6092E8 }

{ @routine $6093C4 SF_ConStars }
procedure SF_ConStars(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ConStars');
  Constellation := TConstellation(av[1].AsDword);
  av[0].AsInteger := Constellation.Stars.Count;
end;
{ @end $6093C4 }

{ @routine $609434 SF_ConStar }
procedure SF_ConStar(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
  Index: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ConStar');
  Constellation := TConstellation(av[1].AsDword);
  Index := av[2].AsInteger;
  if (Index < 0) or (Index >= Constellation.Stars.Count) then av[0].AsDword := 0
  else av[0].AsDword := Cardinal(Constellation.Stars[Index]);
end;
{ @end $609434 }

{ @routine $6094D4 SF_GalaxyStars }
procedure SF_GalaxyStars(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.Stars.Count;
end;
{ @end $6094D4 }

{ @routine $609508 SF_GalaxyStar }
procedure SF_GalaxyStar(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GalaxyStar');
  Index := av[1].AsInteger;
  if (Index < 0) or (Index >= Galaxy.Stars.Count) then av[0].AsDword := 0
  else av[0].AsDword := Cardinal(Galaxy.Stars[Index]);
end;
{ @end $609508 }

{ @routine $6095A8 SF_StarAngleBetween }
procedure SF_StarAngleBetween(av: array of TVarEC; code: TCodeEC);
var
  Star1, CenterStar, Star2: TStar;
  MinAngle, MaxAngle, Angle: Single;
begin
  if High(av) <> 5 then raise Exception.Create('Error.Script StarAngleBetween');
  Star1 := TStar(av[1].AsDword);
  CenterStar := TStar(av[2].AsDword);
  Star2 := TStar(av[3].AsDword);
  MinAngle := av[4].AsFloat;
  MaxAngle := av[5].AsFloat;
  Angle := Abs(HeadingDifferenceDegrees(PointBearingDegrees(CenterStar.Position, Star1.Position),
    PointBearingDegrees(CenterStar.Position, Star2.Position)));
  if (Angle >= MinAngle) and (Angle <= MaxAngle) then av[0].AsInteger := 1
  else av[0].AsInteger := 0;
end;
{ @end $6095A8 }

{ @routine $6096AC SF_FindPlanet }
procedure SF_FindPlanet(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Planet: TPlanet;
  Filters, Filter: WideString;
  MinFraction, MaxFraction: Single;
  I, Count, J, FilterCount: Integer;
  Planets: TList;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script FindPlanet');
  Star := TStar(av[1].AsDword);
  Filters := av[2].AsString;
  if High(av) >= 3 then MinFraction := av[3].AsFloat / 100 else MinFraction := 0;
  if High(av) >= 4 then MaxFraction := av[4].AsFloat / 100 else MaxFraction := 1;
  Planets := TList.Create;
  Count := Star.Planets.Count;
  FilterCount := CountDelimitedPartsW(Filters, ',');
  for I := 0 to Count - 1 do
  begin
    Planet := Star.Planets[I];
    for J := 0 to FilterCount - 1 do
    begin
      Filter := ExtractDelimitedPartW(Filters, J, ',');
      if (Filter = 'NotMaloc') and (Planet.OwnerId = owner_maloc) then Break
      else if (Filter = 'NotPeleng') and (Planet.OwnerId = owner_peleng) then Break
      else if (Filter = 'NotPeople') and (Planet.OwnerId = owner_human) then Break
      else if (Filter = 'NotFei') and (Planet.OwnerId = owner_feyan) then Break
      else if (Filter = 'NotGaal') and (Planet.OwnerId = owner_gaal) then Break
      else if (Filter = 'NotKling') and (Planet.OwnerId = owner_dominator) then Break
      else if (Filter = 'NotPirateClan') and (Planet.OwnerId = owner_pirate) then Break
      else if (Filter = 'NotNone') and (Planet.OwnerId = owner_uninhabited) then Break;
    end;
    if J < FilterCount then Continue;
    Planets.Add(Planet);
  end;
  if Planets.Count < 1 then
  begin
    av[0].AsDword := 0;
    Planets.Free;
    Exit;
  end;
  I := Round((Planets.Count - 1) * MinFraction);
  J := Round((Planets.Count - 1) * MaxFraction);
  I := I + NextRandomIntRange(0, J - I, Star.RandomState);
  av[0].AsDword := Cardinal(Planets[I]);
  Planets.Free;
end;
{ @end $6096AC }

{ @routine $609A34 SF_ShipCanJump }
procedure SF_ShipCanJump(av: array of TVarEC; code: TCodeEC);
var
  FromStar, ToStar: TStar;
  I, Count, JumpRange, Fuel, Distance: Integer;
  CheckFuel: Boolean;
  Ship: TShip;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script CanJump');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := 0;
  if (Ship.GetFuelTanks = nil) or (Ship.GetEngine = nil) then Exit;
  JumpRange := Ship.GetJumpRange;
  Count := High(av) - 1;
  Fuel := 0;
  CheckFuel := False;
  if (av[Count + 1].ValueKind = value_int32) and (av[Count + 1].AsInteger = 1) then
  begin
    CheckFuel := True;
    Fuel := Ship.GetFuelTanks.Fuel;
    Dec(Count);
  end;
  for I := 2 to Count do
  begin
    FromStar := TStar(av[I].AsDword);
    ToStar := TStar(av[I + 1].AsDword);
    Distance := Round(PointDistance(ToStar.Position, FromStar.Position));
    if CheckFuel then
    begin
      JumpRange := Min(JumpRange, Fuel);
      Dec(Fuel, Distance);
    end;
    if Distance > JumpRange then Exit;
  end;
  av[0].AsInteger := 1;
end;
{ @end $609A34 }

{ @routine $609B80 SF_ShipInStar }
procedure SF_ShipInStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ShipInStar');
  if (av[1].AsDword <> 0) and (TShip(av[1].AsDword).CurrentStar = TStar(av[2].AsDword)) then av[0].AsInteger := 1
  else av[0].AsInteger := 0;
end;
{ @end $609B80 }

{ @routine $609C18 SF_ShipInPlanet }
procedure SF_ShipInPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ShipInPlanet');
  if TShip(av[1].AsDword).CurrentPlanet = TPlanet(av[2].AsDword) then av[0].AsInteger := 1
  else av[0].AsInteger := 0;
end;
{ @end $609C18 }

{ @routine $609CA8 SF_ShipStatistic }
procedure SF_ShipStatistic(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  NormalShip: TNormalShip;
  Ship: TShip;
  I: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipStatistic');
  Obj := TObject(av[1].AsDword);
  NormalShip := nil;
  if Obj is TNormalShip then
  begin
    NormalShip := TNormalShip(Obj);
    Ship := NormalShip;
  end
  else if (Obj is TShip) and (av[2].AsInteger in [10, 11]) then Ship := TShip(Obj)
  else raise Exception.Create('Error.Script ShipStatistic - illegal object type');
  case av[2].AsInteger of
    0:
      begin
        av[0].AsInteger := NormalShip.TotalShipKillCount;
        if High(av) > 2 then NormalShip.TotalShipKillCount := av[3].AsInteger;
      end;
    1:
      begin
        av[0].AsInteger := NormalShip.PirateKillCount;
        if High(av) > 2 then NormalShip.PirateKillCount := av[3].AsInteger;
      end;
    2:
      begin
        av[0].AsInteger := NormalShip.DominatorKillCount;
        if High(av) > 2 then NormalShip.DominatorKillCount := av[3].AsInteger;
      end;
    3:
      begin
        av[0].AsInteger := NormalShip.LiberatedSystemCount;
        if High(av) > 2 then NormalShip.LiberatedSystemCount := av[3].AsInteger;
      end;
    4:
      begin
        av[0].AsInteger := NormalShip.CivilianKillCount;
        if High(av) > 2 then NormalShip.CivilianKillCount := av[3].AsInteger;
      end;
    5:
      begin
        av[0].AsInteger := NormalShip.MilitaryKillCount;
        if High(av) > 2 then NormalShip.MilitaryKillCount := av[3].AsInteger;
      end;
    6:
      begin
        av[0].AsInteger := NormalShip.RangerKillCount;
        if High(av) > 2 then NormalShip.RangerKillCount := av[3].AsInteger;
      end;
    7:
      if GetPlayer = NormalShip then
      begin
        av[0].AsInteger := GetPlayer.BlackHoleKillCount;
        if High(av) > 2 then GetPlayer.BlackHoleKillCount := av[3].AsInteger;
      end;
    8:
      if GetPlayer = NormalShip then
      begin
        av[0].AsInteger := GetPlayer.HyperspaceKillCount;
        if High(av) > 2 then GetPlayer.HyperspaceKillCount := av[3].AsInteger;
      end;
    9:
      begin
        av[0].AsInteger := NormalShip.TradeLossBalance;
        if High(av) > 2 then NormalShip.TradeLossBalance := av[3].AsInteger;
      end;
    10:
      begin
        av[0].AsDword := Cardinal(Ship.HomePlanet);
        if High(av) > 2 then
        begin
          if Ship is TWarrior then
          begin
            I := Ship.HomePlanet.Warriors.IndexOf(Ship);
            if I >= 0 then Ship.HomePlanet.Warriors.Delete(I);
            TPlanet(av[3].AsDword).Warriors.Add(Ship);
          end
          else if Ship is TTransport then
          begin
            Dec(Ship.HomePlanet.HomeTransportCount);
            Inc(TPlanet(av[3].AsDword).HomeTransportCount);
          end
          else if Ship is TRanger then
          begin
            Dec(Ship.HomePlanet.HomeRangerCount);
            Inc(TPlanet(av[3].AsDword).HomeRangerCount);
          end;
          Ship.HomePlanet := TPlanet(av[3].AsDword);
        end;
      end;
    11:
      begin
        av[0].AsInteger := Ship.CreationTurn;
        if High(av) > 2 then Ship.CreationTurn := av[3].AsInteger;
      end;
    12: av[0].AsInteger := NormalShip.CalculateMass;
    13:
      begin
        av[0].AsInteger := NormalShip.ContrabandProfit;
        if High(av) > 2 then NormalShip.ContrabandProfit := av[3].AsInteger;
      end;
  else raise Exception.Create('Error.Script ShipStatistic');
  end;
end;
{ @end $609CA8 }

{ @routine $60A0F8 SF_PlayerDominatorStatistic }
procedure SF_PlayerDominatorStatistic(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlayerDominatorStatistic');
  av[0].AsInteger := GetPlayer.DominatorKillsByType[TDominatorKind(av[1].AsInteger)];
  if High(av) > 1 then GetPlayer.DominatorKillsByType[TDominatorKind(av[1].AsInteger)] := av[2].AsInteger;
end;
{ @end $60A0F8 }

{ @routine $60A1B4 SF_ShipMoney }
procedure SF_ShipMoney(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipMoney');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ship.Money;
  if High(av) >= 2 then Ship.SetMoney(Max(0, av[2].AsInteger));
end;
{ @end $60A1B4 }

{ @routine $60A248 SF_ShipFuel }
procedure SF_ShipFuel(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipFuel');
  Ship := TShip(av[1].AsDword);
  if (Ship = nil) or (Ship.GetFuelTanks = nil) then av[0].AsInteger := 0
  else av[0].AsInteger := Ship.GetFuelTanks.Fuel;
  if (High(av) >= 2) and (Ship.GetFuelTanks <> nil) then
  begin
    Ship.GetFuelTanks.Fuel := av[2].AsInteger;
    if Ship.GetFuelTanks.Fuel < 0 then Ship.GetFuelTanks.Fuel := 0;
  end;
end;
{ @end $60A248 }

{ @routine $60A31C SF_ShipFuelLow }
procedure SF_ShipFuelLow(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipFuelLow');
  Ship := TShip(av[1].AsDword);
  if Ship.GetFuelTanks = nil then av[0].AsInteger := 1
  else if Ship.GetFuelTanks.Fuel < Ship.GetFuelTanks.Capacity then av[0].AsInteger := 1
  else av[0].AsInteger := 0;
end;
{ @end $60A31C }

{ @routine $60A3D4 SF_ShipStrengthInBestRanger }
procedure SF_ShipStrengthInBestRanger(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipStrengthInBestRanger');
  Ship := TShip(av[1].AsDword);
  av[0].AsFloat := Ship.StrengthInBestRanger;
end;
{ @end $60A3D4 }

{ @routine $60A45C SF_ShipStrengthInAverageRanger }
procedure SF_ShipStrengthInAverageRanger(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipStrength');
  Ship := TShip(av[1].AsDword);
  av[0].AsFloat := Ship.Strength / Galaxy.AverageRangerStrength;
end;
{ @end $60A45C }

{ @routine $60A4E4 SF_ChanceToWin }
procedure SF_ChanceToWin(av: array of TVarEC; code: TCodeEC);
var
  Ship, Target: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ChanceToWin');
  Ship := TShip(av[1].AsDword);
  Target := TShip(av[2].AsDword);
  if (High(av) > 2) and (av[3].AsInteger <> 0) then av[0].AsFloat := Ship.ChanceToWin(Target)
  else av[0].AsInteger := Ship.GetWinChancePercent(Target);
end;
{ @end $60A4E4 }

{ @routine $60A5A0 SF_RangerStatus }
procedure SF_RangerStatus(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RangerStatus');
  Obj := TObject(av[1].AsDword);
  if High(av) > 1 then
  begin
    if av[2].AsString = 'EminentWarrior' then av[0].AsInteger := Ord(Galaxy.EminentCareerShips[career_warrior] = Obj)
    else if av[2].AsString = 'EminentTrader' then av[0].AsInteger := Ord(Galaxy.EminentCareerShips[career_trader] = Obj)
    else if av[2].AsString = 'EminentPirate' then av[0].AsInteger := Ord(Galaxy.EminentCareerShips[career_pirate] = Obj)
    else raise Exception.Create(AnsiString('Error.Script RangerStatus - unknown keyword ' + av[2].AsString));
    Exit;
  end;
  if not (Obj is TRanger) then raise Exception.Create('Error.Script RangerStatus 2');
  av[0].AsInteger := Ord((Obj as TRanger).GetDominantCareer);
end;
{ @end $60A5A0 }

{ @routine $60A874 SF_RangerPlaceInRating }
procedure SF_RangerPlaceInRating(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script RangerPlaceInRating');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TRanger) then raise Exception.Create('Error.Script RangerPlaceInRating 2');
  av[0].AsInteger := (Obj as TRanger).PlaceInRating;
end;
{ @end $60A874 }

{ @routine $60A954 SF_RangerExcludedFromRating }
procedure SF_RangerExcludedFromRating(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RangerExcludedFromRating');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TRanger) then raise Exception.Create('Error.Script RangerExcludedFromRating 2');
  Ranger := TRanger(Obj);
  av[0].AsInteger := Ord(Ranger.ExcludedFromRating);
  if High(av) <= 1 then Exit;
  Ranger.ExcludedFromRating := av[2].AsInteger <> 0;
  if Ranger.ExcludedFromRating then
  begin
    if Galaxy.EminentCareerShips[career_trader] = Ranger then Galaxy.EminentCareerShips[career_trader] := nil;
    if Galaxy.EminentCareerShips[career_pirate] = Ranger then Galaxy.EminentCareerShips[career_pirate] := nil;
    if Galaxy.EminentCareerShips[career_warrior] = Ranger then Galaxy.EminentCareerShips[career_warrior] := nil;
  end;
end;
{ @end $60A954 }

{ @routine $60AAA4 SF_ShipFind }
procedure SF_ShipFind(av: array of TVarEC; code: TCodeEC);
var
  Kind: TShipType;
  Star: TStar;
  Ship: TShip;
  I: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipFind');
  av[0].AsDword := 0;
  if GetPlayer = nil then Exit;
  Kind := TShipType(av[1].AsInteger);
  Star := GetPlayer.CurrentStar;
  for I := 0 to Star.Ships.Count - 1 do
  begin
    Ship := Star.Ships[I];
    if Ship.TypeId = Kind then
    begin
      av[0].AsDword := Cardinal(Ship);
      Exit;
    end;
  end;
end;
{ @end $60AAA4 }

{ @routine $60AB64 SF_ShipDestroy }
procedure SF_ShipDestroy(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipDestroy');
  if av[1].AsDword = 0 then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  av[0].AsInteger := Ord(TShip(av[1].AsDword).DestroyQueued);
  if High(av) <= 1 then TShip(av[1].AsDword).DestroyQueued := True
  else if av[2].AsInteger >= 0 then TShip(av[1].AsDword).DestroyQueued := Boolean(av[2].AsInteger);
end;
{ @end $60AB64 }

{ @routine $60AC30 SF_ShipDestroyType }
procedure SF_ShipDestroyType(av: array of TVarEC; code: TCodeEC);
var
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
  Kind: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipDestroyType');
  Kind := av[1].AsInteger;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if (Kind = 1) and (Ship.TypeId = ship_dominator) and (TKling(Ship).DominatorSeries = series_blazer) and
        (TKling(Ship).KlingType <> dominator_boss) and not Ship.HasIndependentScriptFaction then Ship.DestroyQueued := True;
    end;
  end;
end;
{ @end $60AC30 }

{ @routine $60AD34 SF_ItemDestroy }
procedure SF_ItemDestroy(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemDestroy');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    av[0].AsInteger := Item.DestroyFlag;
    if High(av) > 1 then Item.DestroyFlag := av[2].AsInteger;
  end;
end;
{ @end $60AD34 }

{ @routine $60ADF0 SF_RangersCapital }
procedure SF_RangersCapital(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.AverageRangerCapital;
end;
{ @end $60ADF0 }

{ @routine $60AE20 SF_GroupToShip }
procedure SF_GroupToShip(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
  Binding: TScriptShip;
  I, GroupIndex: Integer;
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GroupToShip');
  GroupIndex := av[1].AsInteger;
  Ship := nil;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then
    begin
      Ship := Binding.Ship;
      if Ship <> GetPlayer then
      begin
        av[0].AsDword := Cardinal(Ship);
        Exit;
      end;
    end;
  end;
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $60AE20 }

{ @routine $60AEF4 SF_OrderJump }
procedure SF_OrderJump(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderJump');
  Absolute := False;
  if High(av) >= 3 then Absolute := Boolean(av[3].AsInteger);
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if Ship.CurrentPlanet <> nil then AppendLogLineThreadSafe(AnsiString('Warning! ' + GetScriptContextDescription + ' orders ship ' + Ship.GetFullName(' ') + ' to jump while landed on planet!'));
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderJump(TStar(av[2].AsDword), Absolute);
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = map_mode_orders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;
{ @end $60AEF4 }

{ @routine $60B128 SF_OrderLanding }
procedure SF_OrderLanding(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderLanding');
  Absolute := False;
  if High(av) >= 3 then Absolute := Boolean(av[3].AsInteger);
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderLanding(TObject(av[2].AsDword), Absolute);
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = map_mode_orders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;
{ @end $60B128 }

{ @routine $60B238 SF_IsPlayer }
procedure SF_IsPlayer(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script IsPlayer');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ord(GetPlayer = Ship);
end;
{ @end $60B238 }

{ @routine $60B2B4 SF_GroupCount }
procedure SF_GroupCount(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
  I, ShipCount, GroupIndex, Count: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GroupCount');
  GroupIndex := av[1].AsInteger;
  Count := 0;
  ShipCount := CurrentScript.Ships.Count;
  for I := 0 to ShipCount - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then Inc(Count);
  end;
  av[0].AsInteger := Count;
end;
{ @end $60B2B4 }

{ @routine $60B36C SF_GroupIn }
procedure SF_GroupIn(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex: Integer;
  Location: TObject;
  I, Count: Integer;
  Binding: TScriptShip;
  Found: Boolean;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GroupIn');
  GroupIndex := av[1].AsInteger;
  Location := TObject(av[2].AsDword);
  Found := False;
  if Location is TConstellation then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then Continue;
      if Binding.Ship.CurrentStar.Constellation <> Location then
      begin
        av[0].AsInteger := 0;
        Exit;
      end;
      Found := True;
    end;
  end
  else if Location is TStar then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then Continue;
      if Binding.Ship.CurrentStar <> Location then
      begin
        av[0].AsInteger := 0;
        Exit;
      end;
      Found := True;
    end;
  end
  else if Location is TPlanet then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then Continue;
      if (Binding.Ship = GetPlayer) and (GetPlayer.RuinsMode <> 0) then
      begin
        if GetPlayer.RuinsSavedPlanet <> Location then
        begin
          av[0].AsInteger := 0;
          Exit;
        end;
      end
      else
      begin
        if not Binding.Ship.IsOnPlanet or (Binding.Ship.CurrentPlanet <> Location) then
        begin
          av[0].AsInteger := 0;
          Exit;
        end;
        Found := True;
      end;
    end;
  end
  else if Location is TShip then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then Continue;
      if (Binding.Ship = GetPlayer) and (GetPlayer.RuinsMode <> 0) then
      begin
        if GetPlayer.RuinsSavedDockedTo <> Location then
        begin
          av[0].AsInteger := 0;
          Exit;
        end;
      end
      else
      begin
        if not Binding.Ship.IsDockedToShip or (Binding.Ship.DockedTo <> Location) then
        begin
          av[0].AsInteger := 0;
          Exit;
        end;
        Found := True;
      end;
    end;
  end
  else if Location is TScriptPlace then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then Continue;
      if not TScriptPlace(Location).ShipInPlace(Binding.Ship) then
      begin
        av[0].AsInteger := 0;
        Exit;
      end;
      Found := True;
    end;
  end;
  av[0].AsInteger := Ord(Found);
end;
{ @end $60B36C }

{ @routine $60B6C8 SF_CountIn }
procedure SF_CountIn(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex: Integer;
  Location: TObject;
  I, Count, FoundCount: Integer;
  Binding: TScriptShip;
  ExcludeHyperspace: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CountIn');
  GroupIndex := av[1].AsInteger;
  { Native code reads argument 2 both as this flag and as the location below. }
  ExcludeHyperspace := (High(av) > 1) and (av[2].AsInteger <> 0);
  FoundCount := 0;
  if High(av) = 1 then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex = GroupIndex then Inc(FoundCount);
    end;
  end
  else
  begin
    Location := TObject(av[2].AsDword);
    if Location is TConstellation then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := CurrentScript.Ships[I];
        if ExcludeHyperspace and Binding.Ship.InHyperspace then Continue;
        if (Binding.GroupIndex = GroupIndex) and (Binding.Ship.CurrentStar.Constellation = Location) then Inc(FoundCount);
      end;
    end
    else if Location is TStar then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := CurrentScript.Ships[I];
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
        Binding := CurrentScript.Ships[I];
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
        Binding := CurrentScript.Ships[I];
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
        Binding := CurrentScript.Ships[I];
        if (Binding.GroupIndex = GroupIndex) and TScriptPlace(Location).ShipInPlace(Binding.Ship) then Inc(FoundCount);
      end;
    end;
  end;
  av[0].AsInteger := FoundCount;
end;
{ @end $60B6C8 }

{ @routine $60BA64 SF_NearestGroup }
procedure SF_NearestGroup(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  I, ShipCount, J, GroupCount, GroupIndex: Integer;
  Distance, BestDistance: Single;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script NearestGroup');
  Ship := TShip(av[1].AsDword);
  GroupIndex := av[2].AsInteger;
  BestDistance := 1e15;
  ShipCount := CurrentScript.Ships.Count;
  GroupCount := High(av) - 1;
  for I := 0 to ShipCount - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    for J := 0 to GroupCount - 1 do
      if av[2 + J].AsInteger = Binding.GroupIndex then Break;
    if (J < GroupCount) and (Binding.Ship.CurrentStar = Ship.CurrentStar) and
      Binding.Ship.InNormalSpace then
    begin
      Distance := PointDistanceSquared(Ship.Position, Binding.Ship.Position);
      if Distance < BestDistance then
      begin
        BestDistance := Distance;
        GroupIndex := Binding.GroupIndex;
      end;
    end;
  end;
  av[0].AsInteger := GroupIndex;
end;
{ @end $60BA64 }

{ @routine $60BBB0 SF_ChangeState }
procedure SF_ChangeState(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ChangeState');
  if av[1].ValueKind <> value_string then Index := av[1].AsInteger
  else
  begin
    for Index := 0 to CurrentScript.States.Count - 1 do
      if TScriptState(CurrentScript.States[Index]).Name = av[1].AsString then Break;
    if Index >= CurrentScript.States.Count then
      raise Exception.Create('Error.Script ChangeState ' + av[1].AsString);
  end;
  ScriptSnap(Snapshot);
  if High(av) >= 2 then Ship := TShip(av[2].AsDword)
  else Ship := CurrentScript.CurrentShip;
  CurrentScript.ChangeState(GetScriptShipBindingForContext(Ship, CurrentScript), Index);
  ScriptUnSnap(Snapshot);
end;
{ @end $60BBB0 }

{ @routine $60BD94 SF_StarAngle }
procedure SF_StarAngle(av: array of TVarEC; code: TCodeEC);
var
  First, Second: TStar;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script StarAngle');
  First := TStar(av[1].AsDword);
  Second := TStar(av[2].AsDword);
  av[0].AsFloat := PointBearingDegrees(First.Position, Second.Position);
end;
{ @end $60BD94 }

{ @routine $60BE20 SF_NewsAdd }
procedure SF_NewsAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script NewsAdd');
  AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, av[1].AsString, '');
end;
{ @end $60BE20 }

{ @routine $60BECC SF_MsgAdd }
procedure SF_MsgAdd(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  GroupIndex, I, Count: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script NewsAdd');
  Ship := nil;
  GroupIndex := av[2].AsInteger;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then
    begin
      Ship := Binding.Ship;
      Break;
    end;
  end;
  if (Ship = nil) or GetPlayer.InHyperspace or (GetPlayer.CurrentStar <> Ship.CurrentStar) then
    av[0].AsInteger := 0
  else
  begin
    with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, av[1].AsString, '') do
      Targets[0].ShipId := Ship.Id;
    av[0].AsInteger := 1;
  end;
end;
{ @end $60BECC }

{ @routine $60C018 SF_Ether }
procedure SF_Ether(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  InPlayerSystem: Boolean;
  Key: WideString;
  Kind: TPlayerMessageKind;
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script Ether');
  av[0].AsInteger := 0;
  Kind := TPlayerMessageKind(av[1].AsInteger);
  Key := av[2].AsString;
  Obj := nil;
  InPlayerSystem := False;
  if High(av) >= 4 then
  begin
    Obj := TObject(av[4].AsDword);
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
    else raise Exception.Create('Error.Script Ether objtype');
  end;
  if not (Kind in [message_radio, message_radio_with_player]) or (Obj = nil) or InPlayerSystem then
  begin
    if (Kind = message_quest_active) and (Key <> '') and (CurrentScript <> nil) and (CurrentScript.EtherIds.IndexOf(Key) < 0) then
      CurrentScript.EtherIds.Add(Key);
    MessageEntry := AddOrUpdatePlayerBubble(Kind, Galaxy.CurrentTurn,
      ReplaceAllWideString(ReplaceAllWideString(av[3].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag), Key);
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[0].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[0].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 5 then Obj := TObject(av[5].AsDword) else Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[1].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[1].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 6 then Obj := TObject(av[6].AsDword) else Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[2].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[2].PlanetId := TPlanet(Obj).Id;
    end;
    av[0].AsInteger := 1;
  end;
end;
{ @end $60C018 }

{ @routine $60C36C SF_CustomEther }
procedure SF_CustomEther(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  InPlayerSystem: Boolean;
  Key: WideString;
  Kind: TPlayerMessageKind;
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script Ether');
  av[0].AsInteger := 0;
  Kind := TPlayerMessageKind(av[2].AsInteger);
  Key := av[3].AsString;
  Obj := nil;
  InPlayerSystem := False;
  if High(av) >= 5 then
  begin
    Obj := TObject(av[5].AsDword);
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
    else raise Exception.Create('Error.Script Ether objtype');
  end;
  if not (Kind in [message_radio, message_radio_with_player]) or (Obj = nil) or InPlayerSystem then
  begin
    if (Kind = message_quest_active) and (Key <> '') and (CurrentScript <> nil) and (CurrentScript.EtherIds.IndexOf(Key) < 0) then
      CurrentScript.EtherIds.Add(Key);
    MessageEntry := AddOrUpdatePlayerBubble(Kind, Galaxy.CurrentTurn,
      ReplaceAllWideString(ReplaceAllWideString(av[4].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag), Key);
    MessageEntry.ImageNameOverride := av[1].AsString;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[0].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[0].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 6 then Obj := TObject(av[6].AsDword) else Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[1].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[1].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 7 then Obj := TObject(av[7].AsDword) else Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then MessageEntry.Targets[2].ShipId := TShip(Obj).Id
      else MessageEntry.Targets[2].PlanetId := TPlanet(Obj).Id;
    end;
    av[0].AsInteger := 1;
  end;
end;
{ @end $60C36C }

{ @routine $60C6D8 SF_EtherDelete }
procedure SF_EtherDelete(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script EtherDelete');
  RemovePlayerBubbleByKey(av[1].AsString);
end;
{ @end $60C6D8 }

{ @routine $60C778 SF_EtherIdAdd }
procedure SF_EtherIdAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script EtherIdAdd');
  CurrentScript.EtherIds.Add(av[1].AsString);
end;
{ @end $60C778 }

{ @routine $60C820 SF_EtherIdDelete }
procedure SF_EtherIdDelete(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script EtherIdDelete');
  while True do
  begin
    Index := CurrentScript.EtherIds.IndexOf(av[1].AsString);
    if Index < 0 then Break;
    CurrentScript.EtherIds.Delete(Index);
  end;
end;
{ @end $60C820 }

{ @routine $60C8E4 SF_EtherState }
procedure SF_EtherState(av: array of TVarEC; code: TCodeEC);
var
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EtherState');
  MessageEntry := FindPlayerBubbleByKey(av[1].AsString, False);
  if MessageEntry = nil then av[0].AsInteger := -1 else av[0].AsInteger := Ord(MessageEntry.Kind);
end;
{ @end $60C8E4 }

{ @routine $60C99C SF_ConChangeRelationToRanger }
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
  Sector := TConstellation(av[1].AsDword);
  Ranger := TRanger(av[2].AsDword);
  Amount := av[3].AsInteger;
  StarCount := Sector.Stars.Count;
  for StarIndex := 0 to StarCount - 1 do
  begin
    Star := Sector.Stars[StarIndex];
    PlanetCount := Star.Planets.Count;
    for PlanetIndex := 0 to PlanetCount - 1 do
    begin
      Planet := Star.Planets[PlanetIndex];
      if Planet.OwnerId <> owner_uninhabited then Planet.ChangeRelationToRanger(Ranger, Amount);
    end;
  end;
end;
{ @end $60C99C }

{ @routine $60CA94 SF_GetData }
procedure SF_GetData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
begin
  Index := 0;
  if High(av) >= 1 then Index := av[1].AsInteger;
  if High(av) >= 2 then
  begin
    Ship := TShip(av[2].AsDword);
    if (Ship = GetPlayer) and (CurrentScript = nil) then Exit;
  end
  else Ship := CurrentScript.CurrentShip;
  if Ship = GetPlayer then
    av[0].AsDword := GetScriptShipBindingForContext(Ship, CurrentScript).Data[Index]
  else av[0].AsDword := TScriptShip(Ship.ScriptShip).Data[Index];
end;
{ @end $60CA94 }

{ @routine $60CB30 SF_SetData }
procedure SF_SetData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SetData');
  Index := 0;
  if High(av) >= 2 then Index := av[2].AsInteger;
  if High(av) >= 3 then
  begin
    Ship := TShip(av[3].AsDword);
    if (Ship = GetPlayer) and (CurrentScript = nil) then Exit;
  end
  else Ship := CurrentScript.CurrentShip;
  if Ship = GetPlayer then
    GetScriptShipBindingForContext(Ship, CurrentScript).Data[Index] := av[1].AsDword
  else TScriptShip(Ship.ScriptShip).Data[Index] := av[1].AsDword;
end;
{ @end $60CB30 }

{ @routine $60CC0C SF_ShipData }
procedure SF_ShipData(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := GetScriptShipBindingForContext(CurrentScript.CurrentShip, CurrentScript).Data[0];
  if High(av) >= 1 then
    GetScriptShipBindingForContext(CurrentScript.CurrentShip, CurrentScript).Data[0] := av[1].AsDword;
end;
{ @end $60CC0C }

{ @routine $60CC7C SF_Format }
procedure SF_Format(av: array of TVarEC; code: TCodeEC);
var
  Text, Color: WideString;
  I, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script Format');
  if High(av) = 1 then
  begin
    Text := av[1].AsString;
    Text := ReplaceAllWideString(Text, '<br>', #13#10);
    Text := ReplaceAllWideString(Text, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then Text := ReplaceAllWideString(Text, '<Player>', TextHighlightColorTag + GetPlayer.Name + EndColorTag);
    av[0].AsString := Text;
    Exit;
  end;
  Text := av[1].AsString;
  Count := (High(av) - 1) div 2;
  if Count * 2 + 1 < High(av) then
  begin
    Color := av[High(av)].AsString;
    if Color <> '' then Color := '<color=' + Color + '>';
  end
  else Color := TextHighlightColorTag;
  for I := 0 to Count - 1 do
    Text := ReplaceAllWideString(Text, av[2 + I * 2].AsString, WrapTextInColor(av[2 + I * 2 + 1].AsString, Color));
  av[0].AsString := Text;
end;
{ @end $60CC7C }

{ @routine $60CF40 SF_DeleteTags }
procedure SF_DeleteTags(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DeleteTags');
  av[0].AsString := RemoveTextTagsW(av[1].AsString);
end;
{ @end $60CF40 }

{ @routine $60CFF0 SF_Dialog }
procedure SF_Dialog(av: array of TVarEC; code: TCodeEC);
var
  I, Count, J, ShipCount: Integer;
  Obj, Target: TObject;
  Binding: TScriptShip;
  Immediate: Boolean;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script Dialog');
  av[0].AsInteger := 0;
  if ExitScreenLoop then Exit;
  if GetPlayer = nil then Exit;
  if (High(av) = 1) and (av[1].AsDword = 0) then Exit;
  if not GetPlayer.InNormalSpace then Exit;
  if CurrentScreenId <> screen_star_map then Exit;
  if TalkDialogActive then Exit;
  Immediate := TurnCalculationPhase in [turn_idle, turn_galaxy_finished, turn_player_star_finished, turn_player_star_prepared];
  ScriptSnap(Snapshot);
  if High(av) = 1 then
  begin
    if Immediate then
    begin
      TalkShip := TShip(av[1].AsDword);
      TalkScripted := False;
      ScriptDialogIndex := -1;
      StarMapScreen.RunTalkDialogs;
      av[0].AsInteger := 1;
    end
    else if TShip(av[1].AsDword).OpenPlayerConversation(False) then av[0].AsInteger := 1;
    ScriptUnSnap(Snapshot);
    Exit;
  end;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
  begin
    Obj := TObject(av[2 + I].AsDword);
    if Cardinal(Obj) < $10000 then
    begin
      ShipCount := CurrentScript.Ships.Count;
      for J := 0 to ShipCount - 1 do
      begin
        Binding := CurrentScript.Ships[J];
        if (Binding.GroupIndex = Integer(Obj)) and (GetPlayer <> Binding.Ship) then
        begin
          ScriptDialogIndex := -1;
          CurrentScript.CallDialog(av[1].AsInteger);
          if ScriptDialogIndex >= 0 then
          begin
            if Immediate then
            begin
              TalkShip := Binding.Ship;
              TalkScripted := False;
              StarMapScreen.RunTalkDialogs;
              av[0].AsInteger := 1;
            end
            else if Binding.Ship.OpenPlayerConversation(False) then av[0].AsInteger := 1;
            ScriptUnSnap(Snapshot);
            Exit;
          end;
        end;
      end;
    end
    else
    begin
      Target := Obj;
      if Target is TShip then
      begin
        ScriptDialogIndex := -1;
        CurrentScript.CallDialog(av[1].AsInteger);
        if ScriptDialogIndex >= 0 then
        begin
          if Immediate then
          begin
            TalkShip := TShip(Target);
            TalkScripted := False;
            StarMapScreen.RunTalkDialogs;
            av[0].AsInteger := 1;
          end
          else if TShip(Target).OpenPlayerConversation(False) then av[0].AsInteger := 1;
          ScriptUnSnap(Snapshot);
          Exit;
        end;
      end
      else if Target is TPlanet then
      begin
        ScriptDialogIndex := -1;
        CurrentScript.CallDialog(av[1].AsInteger);
        if (ScriptDialogIndex >= 0) and TPlanet(Target).RequestDialog then
        begin
          av[0].AsInteger := 1;
          ScriptUnSnap(Snapshot);
          Exit;
        end;
      end;
    end;
  end;
end;
{ @end $60CFF0 }

{ @routine $60D39C SF_DText }
procedure SF_DText(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DText');
  if GetPlayer.IsDockedToShip then
    RuinsTalkScreen.DialogText := ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else if not GetPlayer.IsOnPlanet then
    TalkScreen.DialogText := ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else
    GovernmentScreen.DialogText := ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag);
end;
{ @end $60D39C }

{ @routine $60D5A4 SF_DAddText }
procedure SF_DAddText(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DAddText');
  if GetPlayer.IsDockedToShip then
    RuinsTalkScreen.DialogText := RuinsTalkScreen.DialogText + ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else if not GetPlayer.IsOnPlanet then
    TalkScreen.DialogText := TalkScreen.DialogText + ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else
    GovernmentScreen.DialogText := GovernmentScreen.DialogText + ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag);
end;
{ @end $60D5A4 }

{ @routine $60D7C0 SF_DAdd }
procedure SF_DAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script DAdd');
  CurrentScript.BuildDialogAnswer(av[1].AsInteger);
end;
{ @end $60D7C0 }

{ @routine $60D830 SF_DAnswer }
procedure SF_DAnswer(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DAnswer');
  if GetPlayer.IsDockedToShip then
  begin
    if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'takeoff' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptTakeoffChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptTakeoffChoice('');
    end
    else if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit') or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'fastexit') then
    begin
      if GetPlayer.RuinsMode > 0 then GetPlayer.CloseRuinsModeScreen
      else RuinsTalkScreen.ContinueScriptDialog;
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'continue' then
    begin
      RuinsTalkScreen.ContinueScriptDialog;
    end
    else if LowerCase(AnsiString(av[1].AsString)) = 'main' then
    begin
      RuinsTalkScreen.M_Main(False);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit_news' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptNewsExitChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptNewsExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit_end' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptGameEndChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptGameEndChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'hangar' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptHangarChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptHangarChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'goods' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptGoodsChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptGoodsChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback)
      else
        RuinsTalkScreen.AddChoice('', 0, ScriptDialogBlockCallback);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), CurrentScript.CurrentAnswer, RuinsTalkScreen.RunScriptAnswerKeepingScroll)
      else
        RuinsTalkScreen.AddChoice('', CurrentScript.CurrentAnswer, RuinsTalkScreen.RunScriptAnswerKeepingScroll);
    end
    else
      RuinsTalkScreen.AddChoice('- ' + av[1].AsString, CurrentScript.CurrentAnswer, RuinsTalkScreen.RunScriptAnswer);
  end
  else if not GetPlayer.IsOnPlanet then
  begin
    if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit') or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'takeoff') then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddScriptExitChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'fastexit' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), 0, TalkScreen.FastExit, 0)
      else
        TalkScreen.AddChoice('', 0, TalkScreen.FastExit, 0);
    end
    else if LowerCase(AnsiString(av[1].AsString)) = 'main' then
    begin
      ScriptDialogIndex := -1;
      TalkScreen.CodeMsgOut(True);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit_end' then
    begin
      GameEndReason := game_end_terron_conversion;
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddScriptExitChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback, 0)
      else
        TalkScreen.AddChoice('', 0, ScriptDialogBlockCallback, 0);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), CurrentScript.CurrentAnswer, TalkScreen.RunScriptAnswerKeepingScroll, 0)
      else
        TalkScreen.AddChoice('', CurrentScript.CurrentAnswer, TalkScreen.RunScriptAnswerKeepingScroll, 0);
    end
    else
      TalkScreen.AddChoice('- ' + av[1].AsString, CurrentScript.CurrentAnswer, TalkScreen.RunScriptAnswer, 0);
  end
  else
  begin
    if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'takeoff' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptTakeoffChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptTakeoffChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'planet' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptPlanetChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptPlanetChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'goods' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptGoodsChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptGoodsChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'shop' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptShopChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptShopChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'hangar' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptHangarChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptHangarChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit_news' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptNewsExitChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptNewsExitChoice('');
    end
    else if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit') or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'fastexit') then
    begin
      GovernmentScreen.ContinueScriptDialog;
    end
    else if LowerCase(AnsiString(av[1].AsString)) = 'main' then
    begin
      GovernmentScreen.BuildGovernmentChoices(False);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback)
      else
        GovernmentScreen.AddChoice('', 0, ScriptDialogBlockCallback);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), CurrentScript.CurrentAnswer, GovernmentScreen.RunScriptAnswerKeepingScroll)
      else
        GovernmentScreen.AddChoice('', CurrentScript.CurrentAnswer, GovernmentScreen.RunScriptAnswerKeepingScroll);
    end
    else
      GovernmentScreen.AddChoice('- ' + av[1].AsString, CurrentScript.CurrentAnswer, GovernmentScreen.RunScriptAnswer);
  end;
end;
{ @end $60D830 }

{ @routine $60F890 SF_DChange }
procedure SF_DChange(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script DChange');
  ScriptDialogIndex := av[1].AsInteger;
end;
{ @end $60F890 }

{ @routine $60F8FC SF_Player }
procedure SF_Player(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := Cardinal(GetPlayer);
end;
{ @end $60F8FC }

{ @routine $60F92C SF_ItemExist }
procedure SF_ItemExist(av: array of TVarEC; code: TCodeEC);
var
  Item: TScriptItem;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ItemExist');
  Item := TScriptItem(av[1].AsDword);
  if Item.Item = nil then av[0].AsInteger := 0 else av[0].AsInteger := 1;
end;
{ @end $60F92C }

{ @routine $60F9AC SF_ItemIn }
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
  Obj := TObject(av[1].AsDword);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item else Item := TItem(Obj);
  if Item = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Obj := TObject(av[2].AsDword);
  if Cardinal(Obj) < $10000 then
  begin
    for I := 0 to CurrentScript.Ships.Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      { Native group lookup excludes inventory slot zero. }
      if (Binding.GroupIndex = Integer(Obj)) and
        ((Binding.Ship.Inventory.IndexOf(Item) > 0) or (Binding.Ship.Artefacts.IndexOf(Item) > 0)) then
      begin
        av[0].AsInteger := 1;
        Exit;
      end;
    end;
    av[0].AsInteger := 0;
  end
  else if Obj is TStar then
  begin
    Star := Obj as TStar;
    if Star.Items.IndexOf(Item) < 0 then av[0].AsInteger := 0 else av[0].AsInteger := 1;
  end
  else if Obj is TShip then
  begin
    Ship := Obj as TShip;
    if (Ship.Inventory.IndexOf(Item) < 0) and (Ship.Artefacts.IndexOf(Item) < 0) then av[0].AsInteger := 0
    else av[0].AsInteger := 1;
  end
  else if Obj is TPlanet then
  begin
    Planet := Obj as TPlanet;
    if (GetPlayer.CurrentPlanet = Planet) and (TemporaryShopSlots <> nil) then
    begin
      if FindShopSlotByItem(Item) = nil then av[0].AsInteger := 0 else av[0].AsInteger := 1;
    end
    else if Planet.EquipmentShop.IndexOf(Item) < 0 then av[0].AsInteger := 0 else av[0].AsInteger := 1;
  end;
end;
{ @end $60F9AC }

{ @routine $60FC38 SF_ItemCount }
procedure SF_ItemCount(av: array of TVarEC; code: TCodeEC);
var
  Kind: TItemType;
  Ship: TShip;
  I, Count: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script SF_ItemCount');
  Ship := TShip(av[1].AsDword);
  Kind := TItemType(av[2].AsInteger);
  Count := 0;
  for I := 0 to Ship.Inventory.Count - 1 do
    if TItem(Ship.Inventory[I]).ItemType = Kind then Inc(Count);
  for I := 0 to Ship.Artefacts.Count - 1 do
    if TItem(Ship.Artefacts[I]).ItemType = Kind then Inc(Count);
  av[0].AsInteger := Count;
end;
{ @end $60FC38 }

{ @routine $60FD28 SF_DecayGoods }
procedure SF_DecayGoods(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
  Obj: TObject;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script DecayGoods');
  Kind := av[2].AsInteger;
  Obj := TObject(av[1].AsDword);
  if Obj is TPlanet then (Obj as TPlanet).ForceGoodsScarcity(True, [Kind]);
end;
{ @end $60FD28 }

{ @routine $60FDD4 SF_UpsurgeGoods }
procedure SF_UpsurgeGoods(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script DecayGoods');
  Kind := av[2].AsInteger;
  TPlanet(av[1].AsDword).ForceGoodsSurplus(True, [Kind]);
end;
{ @end $60FDD4 }

{ @routine $60FE60 SF_GoodsAdd }
procedure SF_GoodsAdd(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
  Obj: TObject;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script GoodsAdd');
  Kind := av[2].AsInteger;
  Obj := TObject(av[1].AsDword);
  if Obj is TPlanet then
    with TPlanet(Obj).Goods[Kind] do
    begin
      Inc(Count, av[3].AsInteger);
      av[0].AsInteger := Count;
    end
  else if Obj is TRuins then
    with TRuins(Obj).ShopGoods[Kind] do
    begin
      Inc(Count, av[3].AsInteger);
      av[0].AsInteger := Count;
    end
  else if Obj is TShip then
    with TShip(Obj).CargoGoods[Kind] do
    begin
      Inc(Count, av[3].AsInteger);
      av[0].AsInteger := Count;
    end;
end;
{ @end $60FE60 }

{ @routine $60FF68 SF_GoodsCount }
procedure SF_GoodsCount(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TGoodsIndex;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GoodsCount');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  av[0].AsInteger := Ship.CargoGoods[Kind].Count;
end;
{ @end $60FF68 }

{ @routine $60FFE8 SF_GoodsCost }
procedure SF_GoodsCost(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TGoodsIndex;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GoodsCost');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  av[0].AsInteger := Ship.CargoGoods[Kind].TotalCost;
end;
{ @end $60FFE8 }

{ @routine $610068 SF_GoodsRuinsForBuy }
procedure SF_GoodsRuinsForBuy(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GoodsRuinsForBuy');
  Kind := av[2].AsInteger;
  TRuins(av[1].AsDword).ForceGoodsForSale([Kind]);
end;
{ @end $610068 }

{ @routine $6100FC SF_ShipGoods }
procedure SF_ShipGoods(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TGoodsIndex;
  Quantity, Cost: Integer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipGoods');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  Quantity := av[3].AsInteger;
  Quantity := Max(Quantity, -Ship.CargoGoods[Kind].Count);
  if High(av) > 3 then Cost := av[4].AsInteger
  else if Quantity > 0 then Cost := Quantity * GoodsMarket[Kind].AveragePrice
  else Cost := Round(Quantity * Ship.CargoGoods[Kind].TotalCost / Ship.CargoGoods[Kind].Count);
  Inc(Ship.CargoGoods[Kind].Count, Quantity);
  Inc(Ship.CargoGoods[Kind].TotalCost, Cost);
end;
{ @end $6100FC }

{ @routine $610218 SF_ShipGoodsIllegalOnPlanet }
procedure SF_ShipGoodsIllegalOnPlanet(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Planet: TPlanet;
  Kind: Byte;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipGoodsIllegalOnPlanet');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  Planet := TPlanet(av[3].AsDword);
  av[0].AsInteger := 0;
  if (Kind in [Ord(item_food)..Ord(item_narcotics)]) and (Planet.OwnerId <> owner_pirate) then
  begin
    if not GoodsLegalOnPlanet[Kind, Planet.RaceId, Planet.Government] then av[0].AsInteger := 1
    else if (Kind in [Ord(item_food), Ord(item_medicine)]) and Ship.IsHealthEffectActive(disease_new_molizone) then av[0].AsInteger := 1;
  end;
end;
{ @end $610218 }

{ @routine $610318 SF_GoodsDrop }
procedure SF_GoodsDrop(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
  Ship: TShip;
  Quantity: Integer;
  Item: TItem;
  ScriptItem: TScriptItem;
  Goods: TGoods;
  Angle: Single;
  Star: TStar;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script GoodsDrop');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  Quantity := Min(Ship.CargoGoods[Kind].Count, av[3].AsInteger);
  if Quantity < 1 then
  begin
    av[0].AsInteger := 0;
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
    ScriptItem := TScriptItem(av[4].AsDword);
    if ScriptItem.Item <> nil then ScriptItem.Item.ScriptItem := nil;
    ScriptItem.Item := Item;
    Item.ScriptItem := ScriptItem;
  end;
  av[0].AsInteger := 1;
end;
{ @end $610318 }

{ @routine $61054C SF_UselessItemCreate }
procedure SF_UselessItemCreate(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  ScriptItem: TScriptItem;
  Place: TScriptPlace;
  Angle: Single;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script UselessItemCreate');
  Item := TUselessItem.Create;
  (Item as TUselessItem).Init(av[1].AsString, TDominatorSeries(RandomIntRange(0, 2)), 0, False);
  ScriptItem := TScriptItem(av[2].AsDword);
  if ScriptItem.Item <> nil then ScriptItem.Item.ScriptItem := nil;
  ScriptItem.Item := Item;
  Item.ScriptItem := ScriptItem;
  Place := TScriptPlace(av[3].AsDword);
  if not (Place.PlaceKind in ScriptSpawnPlaceKinds) then RaiseWideMessage('Error.Script UselessItemCreate place');
  Place.OriginStar.Items.Add(Item);
  Item.Position := Place.GetPoint;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Item.Id * Place.OriginStar.GenerationSeed));
  Item.Position.X := Item.Position.X + Sin(Angle) * Place.Radius;
  Item.Position.Y := Item.Position.Y - Cos(Angle) * Place.Radius;
end;
{ @end $61054C }

{ @routine $610740 SF_GoodsSellPrice }
procedure SF_GoodsSellPrice(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Kind: TGoodsIndex;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GoodsSellPrice');
  Obj := TObject(av[1].AsDword);
  Kind := av[2].AsInteger;
  if Obj is TRuins then av[0].AsInteger := TRuins(Obj).ShopGoods[Kind].BaseSalePrice
  else av[0].AsInteger := TPlanet(Obj).Goods[Kind].BaseSalePrice;
  if High(av) > 2 then
  begin
    if Obj is TRuins then TRuins(Obj).ShopGoods[Kind].BaseSalePrice := av[3].AsInteger
    else TPlanet(Obj).Goods[Kind].BaseSalePrice := av[3].AsInteger;
  end;
end;
{ @end $610740 }

{ @routine $610838 SF_GoodsBuyPrice }
procedure SF_GoodsBuyPrice(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Kind: TGoodsIndex;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GoodsSellPrice');
  Obj := TObject(av[1].AsDword);
  Kind := av[2].AsInteger;
  if Obj is TRuins then av[0].AsInteger := TRuins(Obj).ShopGoods[Kind].PurchasePrice
  else av[0].AsInteger := TPlanet(Obj).Goods[Kind].PurchasePrice;
  if High(av) > 2 then
  begin
    if Obj is TRuins then TRuins(Obj).ShopGoods[Kind].PurchasePrice := av[3].AsInteger
    else TPlanet(Obj).Goods[Kind].PurchasePrice := av[3].AsInteger;
  end;
end;
{ @end $610838 }

{ @routine $610930 SF_CountTurn }
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
  Ship := TShip(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TScriptPlace then
  begin
    Place := Obj as TScriptPlace;
    if (Place.PlaceKind = place_planet_position) or (Place.PlaceKind = place_docked_at_planet) then
    begin
      Planet := TObject(Place.TargetValue) as TPlanet;
      Position := Planet.GetPosition;
    end
    else
    begin
      Planet := nil;
      Position := Place.GetPoint;
    end;
    Landed := Place.PlaceKind = place_docked_at_planet;
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
    av[0].AsInteger := 0;
    Exit;
  end;
  if Ship.CurrentPlanet <> nil then Inc(Turns);
  if Landed then Inc(Turns);
  if (Ship.CurrentPlanet <> nil) and (Ship.CurrentPlanet = Planet) then
  begin
    av[0].AsInteger := Turns;
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
  av[0].AsInteger := Turns;
end;
{ @end $610930 }

{ @routine $610D0C SF_ShipSetBad }
procedure SF_ShipSetBad(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ShipSetBad');
  if av[1].AsDword <> 0 then TShip(av[1].AsDword).EnemyShip := TShip(av[2].AsDword);
end;
{ @end $610D0C }

{ @routine $610D90 SF_GroupSetBad }
procedure SF_GroupSetBad(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex, I, Count: Integer;
  Binding: TScriptShip;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script GroupSetBad');
  GroupIndex := av[1].AsInteger;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then Binding.Ship.EnemyShip := TShip(av[2].AsDword);
  end;
end;
{ @end $610D90 }

{ @routine $610E50 SF_ShipSetPartner }
procedure SF_ShipSetPartner(av: array of TVarEC; code: TCodeEC);
var
  Ship, Partner: TShip;
begin
  if High(av) <> 3 then raise Exception.Create('Error.Script ShipSetPartner');
  Ship := TShip(av[1].AsDword);
  Partner := TShip(av[2].AsDword);
  if (Ship is TPirate) and (Ship.PartnerShip <> Partner) then
  begin
    if GetPlayer = Ship.PartnerShip then GetPlayer.PiratePartners.Remove(Ship);
    if GetPlayer = Partner then GetPlayer.PiratePartners.Add(Ship);
  end;
  Ship.PartnerShip := Partner;
  Ship.PartnershipDaysRemaining := av[3].AsInteger;
end;
{ @end $610E50 }

{ @routine $610F30 SF_ShipJoin }
procedure SF_ShipJoin(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  StateIndex, I: Integer;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipJoin');
  Ship := TShip(av[2].AsDword);
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
  CurrentScript.BindShip(av[1].AsInteger, Ship);
  Binding := GetScriptShipBindingForContext(Ship, CurrentScript);
  if (High(av) >= 3) and (av[3].ValueKind = value_string) then
  begin
    StateIndex := -1;
    if av[3].AsString = '' then
      StateIndex := TScriptGroup(CurrentScript.Groups[Binding.GroupIndex]).InitialStateIndex
    else
      for I := 0 to CurrentScript.States.Count - 1 do
        if TScriptState(CurrentScript.States[I]).Name = av[3].AsString then
        begin
          StateIndex := I;
          Break;
        end;
    if StateIndex < 0 then
      raise Exception.Create('Error.Script ShipJoin cant find state ' + av[3].AsString);
  end
  { A nonstring third argument suppresses the state change; it is not a state index. }
  else if High(av) >= 3 then StateIndex := -1
  else StateIndex := TScriptGroup(CurrentScript.Groups[Binding.GroupIndex]).InitialStateIndex;
  if High(av) >= 4 then Binding.Data[0] := av[4].AsDword;
  if High(av) >= 5 then Binding.Data[1] := av[5].AsDword;
  if High(av) >= 6 then Binding.Data[2] := av[6].AsDword;
  if High(av) >= 7 then Binding.Data[3] := av[7].AsDword;
  if StateIndex >= 0 then CurrentScript.ChangeState(Binding, StateIndex);
  ScriptUnSnap(Snapshot);
end;
{ @end $610F30 }

{ @routine $611334 SF_ShipOut }
procedure SF_ShipOut(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then Ship := CurrentScript.CurrentShip
  else Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if Ship = GetPlayer then CurrentScript.UnbindShip(Ship)
  else if Ship.ScriptShip <> nil then TScriptShip(Ship.ScriptShip).Script.UnbindShip(Ship);
end;
{ @end $611334 }

{ @routine $6113A0 SF_AllShipOut }
procedure SF_AllShipOut(av: array of TVarEC; code: TCodeEC);
begin
  CurrentScript.ClearShipBindings;
end;
{ @end $6113A0 }

{ @routine $6113CC SF_ShipInScript }
procedure SF_ShipInScript(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInScript');
  if TShip(av[1].AsDword).HasScriptBindings or
    (((High(av) <= 1) or (av[2].AsInteger <> 0)) and (TShip(av[1].AsDword).AbsoluteScriptOrder > 0)) then
    av[0].AsInteger := 1
  else av[0].AsInteger := 0;
end;
{ @end $6113CC }

{ @routine $611478 SF_ShipInGameEvent }
procedure SF_ShipInGameEvent(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipInGameEvent');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := 0;
  if (Ship is TWarrior) and ((Ship as TWarrior).LiberationGroup <> nil) then av[0].AsInteger := 1;
  if (Ship is TRuins) and ((Ship as TRuins).FlyToStar <> nil) then av[0].AsInteger := 1;
end;
{ @end $611478 }

{ @routine $611554 SF_ShipInCurScript }
procedure SF_ShipInCurScript(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipInCurScript');
  if TShip(av[1].AsDword).HasScriptBindings and
    (GetScriptShipBindingForContext(TShip(av[1].AsDword), CurrentScript).Script = CurrentScript) then
    av[0].AsInteger := 1
  else av[0].AsInteger := 0;
end;
{ @end $611554 }

{ @routine $611604 SF_ShipInNormalSpace }
procedure SF_ShipInNormalSpace(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipInNormalSpace');
  if (av[1].AsDword <> 0) and TShip(av[1].AsDword).InNormalSpace then av[0].AsInteger := 1
  else av[0].AsInteger := 0;
end;
{ @end $611604 }

{ @routine $61169C SF_ShipInHole }
procedure SF_ShipInHole(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInHole');
  Ship := TShip(av[1].AsDword);
  if (High(av) > 1) and (av[2].AsInteger <> 0) then
    while Ship.DockedTo <> nil do Ship := Ship.DockedTo;
  if Ship.InHyperspace and (Ship.Order = order_black_hole) then av[0].AsInteger := 1
  else av[0].AsInteger := 0;
end;
{ @end $61169C }

{ @routine $61174C SF_ShipIsTakeoff }
procedure SF_ShipIsTakeoff(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipIsTakeoff');
  Ship := TShip(av[1].AsDword);
  if Ship.Order = order_takeoff then av[0].AsInteger := 1 else av[0].AsInteger := 0;
end;
{ @end $61174C }

{ @routine $6117D4 SF_ShipCntWeapon }
procedure SF_ShipCntWeapon(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipCntWeapon');
  av[0].AsInteger := TShip(av[1].AsDword).WeaponCount;
end;
{ @end $6117D4 }

{ @routine $61184C SF_ShipWeapon }
procedure SF_ShipWeapon(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  I: Integer;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script ShipWeapon');
  Ship := TShip(av[1].AsDword);
  I := av[2].AsInteger;
  if (I <= 0) or (Ship.WeaponCount < I) then av[0].AsDword := 0
  else av[0].AsDword := Cardinal(Ship.Weapons[I]);
end;
{ @end $61184C }

{ @routine $6118E4 SF_ShipEqInSlot }
procedure SF_ShipEqInSlot(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  ItemType: TItemType;
  SlotIndex: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipEqInSlot');
  Ship := TShip(av[1].AsDword);
  ItemType := TItemType(av[2].AsInteger);
  if ItemType in [item_hull..item_defense_generator] then av[0].AsDword := Cardinal(Ship.EquipmentCache.Slots[ItemType])
  else
  begin
    if High(av) < 3 then SlotIndex := 0 else SlotIndex := av[3].AsInteger - 1;
    Ship.RefreshAssignedItemSlots;
    av[0].AsDword := Cardinal(Ship.FindEquippedItemInSlot(ItemType, SlotIndex));
  end;
end;
{ @end $6118E4 }

{ @routine $6119AC SF_ArtefactTypeInUse }
procedure SF_ArtefactTypeInUse(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TArtefact;
  ItemType: TItemType;
  Name: WideString;
  I, Count: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ArtefactTypeInUse');
  Ship := TShip(av[1].AsDword);
  Item := nil;
  if (av[2].ValueKind = value_uint32) and (av[2].AsDword > $FFFF) then Item := TArtefact(av[2].AsDword);
  Name := '';
  if (Item <> nil) and (Item.GetEffectiveType in [item_custom_artefact, item_custom_artefact_no_wear]) then Name := Item.ConfigBlockName
  else if av[2].ValueKind = value_string then Name := av[2].AsString;
  if Name <> '' then
  begin
    Count := 0;
    for I := 0 to Ship.Artefacts.Count - 1 do
    begin
      Item := Ship.Artefacts[I];
      if (Item.ItemType in [item_custom_artefact, item_custom_artefact_no_wear]) and (Item.ConfigBlockName = Name) and
        (Item.BrokenFlag = 0) and (Item.EquippedFlag <> 0) then Inc(Count);
    end;
    av[0].AsInteger := Count;
  end
  else
  begin
    if Item <> nil then ItemType := TArtefact(av[2].AsDword).GetEffectiveType
    else ItemType := TItemType(av[2].AsInteger);
    av[0].AsInteger := Ship.CountActiveArtefacts(ItemType);
  end;
end;
{ @end $6119AC }

{ @routine $611B60 SF_ArtefactTypeBoosted }
procedure SF_ArtefactTypeBoosted(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  ItemType: TItemType;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ArtefactTypeBoosted');
  Ship := TShip(av[1].AsDword);
  if (av[2].ValueKind = value_uint32) and (av[2].AsDword > $FF) then
    ItemType := TArtefact(av[2].AsDword).GetEffectiveType
  else ItemType := TItemType(av[2].AsInteger);
  av[0].AsInteger := Ord(Ship.CanBoostArtefact(ItemType, nil, False));
end;
{ @end $611B60 }

{ @routine $611C28 SF_ShipGroup }
procedure SF_ShipGroup(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipGroup');
  Binding := GetScriptShipBindingForContext(TShip(av[1].AsDword), CurrentScript);
  if Binding <> nil then av[0].AsInteger := Binding.GroupIndex
  else av[0].AsInteger := -1;
end;
{ @end $611C28 }

{ @routine $611CB4 SF_ShipSpeed }
procedure SF_ShipSpeed(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipSpeed');
  av[0].AsInteger := TShip(av[1].AsDword).Speed;
end;
{ @end $611CB4 }

{ @routine $611D24 SF_EnginePower }
procedure SF_EnginePower(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Engine: TEngine;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EnginePower');
  Obj := TObject(av[1].AsDword);
  Engine := nil;
  if Obj is TEngine then Engine := TEngine(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item <> nil) and ((Obj as TScriptItem).Item is TEngine) then
    Engine := TEngine((Obj as TScriptItem).Item)
  else if Obj is TShip then Engine := TShip(Obj).GetEngine;
  if Engine <> nil then
  begin
    av[0].AsInteger := Engine.OutputPercent;
    if High(av) > 1 then Engine.OutputPercent := av[2].AsInteger;
  end
  else av[0].AsInteger := 0;
end;
{ @end $611D24 }

{ @routine $611E48 SF_ShipJump }
procedure SF_ShipJump(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipJump');
  av[0].AsInteger := TShip(av[1].AsDword).GetJumpRange;
end;
{ @end $611E48 }

{ @routine $611EBC SF_ShipArmor }
procedure SF_ShipArmor(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipArmor');
  av[0].AsInteger := TShip(av[1].AsDword).GetArmor;
end;
{ @end $611EBC }

{ @routine $611F30 SF_ShipProtectability }
procedure SF_ShipProtectability(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipProtectability');
  av[0].AsInteger := Round((1 - TShip(av[1].AsDword).GetDefenseDamageFactor) * 100);
end;
{ @end $611F30 }

{ @routine $611FC4 SF_ShipDroidRepair }
procedure SF_ShipDroidRepair(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipDroidRepair');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship.IsEquipmentUsable(Ship.GetRepairRobot) then av[0].AsInteger := Ship.CalculateRepairPoints(Ship.GetRepairRobot);
end;
{ @end $611FC4 }

{ @routine $612070 SF_ShipRadarRange }
procedure SF_ShipRadarRange(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipRadarRange');
  av[0].AsInteger := TShip(av[1].AsDword).GetRadarRange;
end;
{ @end $612070 }

{ @routine $6120E8 SF_ShipScanerPower }
procedure SF_ShipScanerPower(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipScanerPower');
  av[0].AsInteger := TShip(av[1].AsDword).GetScannerPower;
end;
{ @end $6120E8 }

{ @routine $612164 SF_ShipHookPower }
procedure SF_ShipHookPower(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipHookPower');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship.IsEquipmentUsable(Ship.GetCargoHook) then av[0].AsInteger := Ship.CalculateCargoHookPower(Ship.GetCargoHook);
end;
{ @end $612164 }

{ @routine $61220C SF_ShipHookRange }
procedure SF_ShipHookRange(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipHookRange');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship.IsEquipmentUsable(Ship.GetCargoHook) then av[0].AsInteger := Ship.GetCargoHookRange;
end;
{ @end $61220C }

{ @routine $6122A8 SF_ShipAverageDamage }
procedure SF_ShipAverageDamage(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  I, MinDamage, MaxDamage: Integer;
  Weapon: TWeapon;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipAverageDamage');
  Ship := TShip(av[1].AsDword);
  MinDamage := 0;
  MaxDamage := 0;
  for I := 1 to Ship.WeaponCount do
  begin
    Weapon := Ship.Weapons[I];
    if not Ship.IsEquipmentUsable(Weapon) then Continue;
    if Weapon.GetWeaponInfo.ShotType in [shot_missile, shot_rocket] then
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
  if High(av) > 1 then
  begin
    if av[2].AsInteger = 0 then av[0].AsInteger := MinDamage
    else if av[2].AsInteger = 1 then av[0].AsInteger := MaxDamage
    else av[0].AsInteger := Round((MinDamage + MaxDamage) * 0.5);
  end
  else av[0].AsInteger := Round((MinDamage + MaxDamage) * 0.5);
end;
{ @end $6122A8 }

{ @routine $612484 SF_ShipHealthFactor }
procedure SF_ShipHealthFactor(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Remaining, Duration: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipHealthFactor');
  Ship := TShip(av[1].AsDword);
  Index := av[2].AsInteger;
  Remaining := 0;
  if Ship = nil then
  begin
    if Index = 0 then av[0].AsInteger := RadiationHealthDefinitions[1].Duration
    else av[0].AsInteger := CaptainHealthDefinitions[Index].Duration;
    Exit;
  end;
  if Index = 0 then
  begin
    if Ship.HasRadiationSickness then Remaining := Ship.RadiationHealth[1].ExpireTurn - Galaxy.CurrentTurn;
    if High(av) > 2 then
    begin
      Duration := av[3].AsInteger;
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
      Duration := av[3].AsInteger;
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
  av[0].AsInteger := Remaining;
end;
{ @end $612484 }

{ @routine $6126D8 SF_ShipHealthFactorStatus }
procedure SF_ShipHealthFactorStatus(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipHealthFactorStatus');
  Ship := TShip(av[1].AsDword);
  Index := av[2].AsInteger;
  if Index = 0 then
  begin
    av[0].AsFloat := Ship.RadiationHealth[1].Progress;
    if High(av) > 2 then Ship.RadiationHealth[1].Progress := av[3].AsFloat;
  end
  else if (Index > 0) and (Index <= 24) then
  begin
    av[0].AsInteger := Round(Ship.CaptainHealth[Index].Progress);
    if High(av) > 2 then Ship.CaptainHealth[Index].Progress := av[3].AsInteger;
  end
  else av[0].AsInteger := 0;
end;
{ @end $6126D8 }

{ @routine $6127D8 SF_PlayerImmunity }
procedure SF_PlayerImmunity(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DiseaseImmunity;
  if High(av) >= 1 then GetPlayer.DiseaseImmunity := av[1].AsInteger;
end;
{ @end $6127D8 }

{ @routine $612828 SF_ShipStatusEffect }
procedure SF_ShipStatusEffect(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  EffectType: TCombatEffectKind;
  Index: Integer;
  Strength: Single;
  Source: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipStatusEffect');
  Ship := TShip(av[1].AsDword);
  EffectType := TCombatEffectKind(av[2].AsInteger);
  Index := Ship.FindCombatStatusEffect(EffectType);
  if Index < 0 then av[0].AsFloat := 0
  else av[0].AsFloat := PCombatStatusEffect(Ship.CombatStatusEffects[Index]).Strength;
  if High(av) <= 2 then Exit;
  Strength := av[3].AsFloat;
  if High(av) > 3 then Source := TShip(av[4].AsDword) else Source := nil;
  if Strength > 0 then Ship.AddCombatStatusStrength(EffectType, Strength, Source)
  else if Strength < 0 then Ship.ReduceCombatStatusStrength(EffectType, -Strength);
end;
{ @end $612828 }

{ @routine $612958 SF_GroupIs }
procedure SF_GroupIs(av: array of TVarEC; code: TCodeEC);
var
  I, Count, GroupIndex: Integer;
  Binding: TScriptShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GroupIs');
  Binding := GetScriptShipBindingForContext(TShip(av[1].AsDword), CurrentScript);
  if (Binding = nil) or (Binding.Script <> CurrentScript) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  GroupIndex := Binding.GroupIndex;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
    if av[2 + I].AsInteger = GroupIndex then
    begin
      av[0].AsInteger := 1;
      Exit;
    end;
  av[0].AsInteger := 0;
end;
{ @end $612958 }

{ @routine $612A2C SF_StateIs }
procedure SF_StateIs(av: array of TVarEC; code: TCodeEC);
var
  I, Count: Integer;
  State: TScriptState;
  Binding: TScriptShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StateIs');
  Binding := GetScriptShipBindingForContext(TShip(av[1].AsDword), CurrentScript);
  if Binding = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  State := Binding.State;
  if State = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
    if State.Name = av[2 + I].AsString then
    begin
      av[0].AsInteger := 1;
      Exit;
    end;
  av[0].AsInteger := 0;
end;
{ @end $612A2C }

{ @routine $612B44 SF_Dist }
procedure SF_Dist(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Point1, Point2: TPointF;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script Dist');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj = nil then Exit;
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
  Obj := TObject(av[2].AsDword);
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
    av[0].AsInteger := Round(PointDistance(Point1, Point2));
  end;
end;
{ @end $612B44 }

{ @routine $612FB0 SF_Angle }
procedure SF_Angle(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Point1, Point2: TPointF;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script Angle');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj = nil then Exit;
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
  Obj := TObject(av[2].AsDword);
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
    av[0].AsInteger := Round(PointBearingDegrees(Point2, Point1));
  end;
end;
{ @end $612FB0 }

{ @routine $61341C SF_Dist2Star }
procedure SF_Dist2Star(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script DistStar');
  av[0].AsFloat := PointDistanceSquared(TStar(av[1].AsDword).Position, TStar(av[2].AsDword).Position);
end;
{ @end $61341C }

{ @routine $6134A4 SF_BuyPirate }
procedure SF_BuyPirate(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TPirate;
  MoneyPercent: Integer;
  WasMainPiratePlanet: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyPirate');
  MoneyPercent := 100;
  if High(av) > 1 then MoneyPercent := av[2].AsInteger;
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  WasMainPiratePlanet := Planet.IsMainPiratePlanet;
  Planet.IsMainPiratePlanet := False;
  Ship := Planet.BuyPirate(MoneyPercent);
  Planet.IsMainPiratePlanet := WasMainPiratePlanet;
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $6134A4 }

{ @routine $613554 SF_BuyTransport }
procedure SF_BuyTransport(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TTransport;
  Kind: Byte;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyTransport');
  Planet := TPlanet(av[1].AsDword);
  MoneyPercent := 100;
  if High(av) > 2 then MoneyPercent := av[3].AsInteger;
  if Planet <> nil then
  begin
    if High(av) > 1 then
      case av[2].AsInteger of
        0: Kind := Byte(hull_transport);
        1: Kind := Byte(hull_liner);
        2: Kind := Byte(hull_diplomat);
      else Kind := 0;
      end
    else Kind := 0;
    Ship := Planet.SpawnTransport(Kind, MoneyPercent);
    av[0].AsDword := Cardinal(Ship);
  end;
end;
{ @end $613554 }

{ @routine $613620 SF_Name }
procedure SF_Name(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Name');
  Obj := TObject(av[1].AsDword);
  if Obj is TStar then av[0].AsString := TStar(Obj).Name
  else if Obj is TConstellation then av[0].AsString := TConstellation(Obj).GetName
  else if Obj is TPlanet then av[0].AsString := TPlanet(Obj).Name
  else if Obj is TShip then av[0].AsString := TShip(Obj).GetFullName(' ')
  else if Obj is TScriptItem then
  begin
    if TScriptItem(Obj).Item = nil then av[0].AsString := 'NameError'
    else av[0].AsString := TScriptItem(Obj).Item.GetDisplayName;
  end
  else if Obj is TItem then av[0].AsString := TItem(Obj).GetDisplayName
  else av[0].AsString := 'NameError';
end;
{ @end $613620 }

{ @routine $6137E8 SF_ShortName }
procedure SF_ShortName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Name');
  Obj := TObject(av[1].AsDword);
  if Obj is TStar then av[0].AsString := TStar(Obj).Name
  else if Obj is TPlanet then av[0].AsString := TPlanet(Obj).Name
  else if Obj is TShip then av[0].AsString := TShip(Obj).GetName
  else if Obj is TScriptItem then
  begin
    if TScriptItem(Obj).Item = nil then av[0].AsString := 'NameError'
    else av[0].AsString := TScriptItem(Obj).Item.GetShortName;
  end
  else if Obj is TItem then av[0].AsString := TItem(Obj).GetShortName
  else av[0].AsString := 'NameError';
end;
{ @end $6137E8 }

{ @routine $613974 SF_FirstGiveMoney }
procedure SF_FirstGiveMoney(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Round(300 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].ArcadeRewardScale);
end;
{ @end $613974 }

{ @routine $6139CC SF_HaveProgramm }
procedure SF_HaveProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script HaveProgramm');
  av[0].AsInteger := Ord(GetPlayer.HasProgram(TProgramIndex(av[1].AsDword)));
end;
{ @end $6139CC }

{ @routine $613A4C SF_GetProgramm }
procedure SF_GetProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetProgramm');
  av[0].AsInteger := GetPlayer.ProgramCounts[TProgramIndex(av[1].AsDword)];
end;
{ @end $613A4C }

{ @routine $613ACC SF_SetProgramm }
procedure SF_SetProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetProgramm');
  av[0].AsInteger := Ord(GetPlayer.HasProgram(TProgramIndex(av[1].AsDword)));
  GetPlayer.ProgramCounts[TProgramIndex(av[1].AsDword)] := av[2].AsInteger;
end;
{ @end $613ACC }

{ @routine $613B70 SF_DomikProgramm }
procedure SF_DomikProgramm(av: array of TVarEC; code: TCodeEC);
var
  Ship: TKling;
  ProgramId: TProgramIndex;
  Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DomikProgramm');
  Ship := TKling(av[1].AsDword);
  av[0].AsInteger := Ord(Ship.ActiveProgramId);
  if High(av) <= 1 then Exit;
  ProgramId := TProgramIndex(av[2].AsDword);
  Ship.ActiveProgramId := ProgramId;
  case ProgramId of
    program_shipwreck: begin
      if High(av) > 2 then Count := av[3].AsInteger else Count := SeededRandomIntRange(1, 3, Galaxy.CurrentTurn);
      Ship.DropItemsForDominatorProgram(Count);
    end;
    program_self_destruction: Ship.DestroyQueued := True;
    program_disconnection: begin
      Ship.OrderNone(False);
      Ship.ClearWeaponTargets(nil);
    end;
  end;
end;
{ @end $613B70 }

{ @routine $613C5C SF_DomikProgrammDate }
procedure SF_DomikProgrammDate(av: array of TVarEC; code: TCodeEC);
var
  Ship: TKling;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DomikProgrammDate');
  Ship := TKling(av[1].AsDword);
  av[0].AsInteger := Ship.ActiveProgramAppliedTurn;
  if High(av) > 1 then Ship.ActiveProgramAppliedTurn := av[2].AsInteger;
end;
{ @end $613C5C }

{ @routine $613CF0 SF_HoleMamaCreate }
procedure SF_HoleMamaCreate(av: array of TVarEC; code: TCodeEC);
var
  Angle, Scale: Single;
  Hole: THole;
  I: Integer;
  Film: TEFilmObj;
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
      Hole.Star2 := Galaxy.Stars[I];
    end;
  end;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
  Scale := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
  Hole.Position2 := MakePointF(Sin(Angle) * Scale, -Cos(Angle) * Scale);
  Hole.CreatedTurn := Galaxy.CurrentTurn;
  Hole.HoleType := 2;
  Galaxy.Holes.Add(Hole);
  if not Hole.Star1.RecordingTurnFilm and not Hole.Star2.RecordingTurnFilm then Exit;
  Film := PrimaryFilm.AddObject(Hole.Id, Hole.Graphic);
  PrimaryFilm.SetObjectPosition(0, Film, Hole.Position1);
  PrimaryFilm.SetHoleState(0, Film, 1);
  PrimaryFilm.AttachObject(0, Film);
end;
{ @end $613CF0 }

{ @routine $614064 SF_HoleCreate }
procedure SF_HoleCreate(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
  Angle: Single;
  Place: TScriptPlace;
  Film: TEFilmObj;
begin
  if High(av) <> 2 then raise Exception.Create('Error.Script HoleCreate');
  Hole := THole.Create;
  Hole.InitializeGraphic('');
  THoleSE(Hole.Graphic).SetState(1);
  Hole.CreatedTurn := Galaxy.CurrentTurn;
  Hole.HoleType := 1;
  Place := TScriptPlace(av[1].AsDword);
  if not (Place.PlaceKind in ScriptSpawnPlaceKinds) then RaiseWideMessage('Error.Script HoleCreate place 1');
  Hole.Star1 := Place.OriginStar;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Hole.Id * Hole.Star1.GenerationSeed));
  Hole.Position1 := Place.GetPoint;
  Hole.Position1.X := Hole.Position1.X + Sin(Angle) * Place.Radius;
  Hole.Position1.Y := Hole.Position1.Y - Cos(Angle) * Place.Radius;
  Place := TScriptPlace(av[2].AsDword);
  if not (Place.PlaceKind in ScriptSpawnPlaceKinds) then RaiseWideMessage('Error.Script HoleCreate place 2');
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
{ @end $614064 }

{ @routine $614384 SF_TerronWeaponLock }
procedure SF_TerronWeaponLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronWeaponLockTurn := Galaxy.CurrentTurn;
end;
{ @end $614384 }

{ @routine $6143BC SF_TerronGrowLock }
procedure SF_TerronGrowLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronGrowLockTurn := Galaxy.CurrentTurn;
end;
{ @end $6143BC }

{ @routine $6143F4 SF_TerronLandingLock }
procedure SF_TerronLandingLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronLandingLockTurn := Galaxy.CurrentTurn;
end;
{ @end $6143F4 }

{ @routine $61442C SF_TerronToStar }
procedure SF_TerronToStar(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronToStarTurn := Galaxy.CurrentTurn;
end;
{ @end $61442C }

{ @routine $614464 SF_KellerLeave }
procedure SF_KellerLeave(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.KellerLeaveTurn := Galaxy.CurrentTurn;
end;
{ @end $614464 }

{ @routine $61449C SF_KellerNewResearch }
procedure SF_KellerNewResearch(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.KellerResearchTargetStarId := av[1].AsDword;
end;
{ @end $61449C }

{ @routine $6144D4 SF_KellerKill }
procedure SF_KellerKill(av: array of TVarEC; code: TCodeEC);
begin
  KellerFinishRequested := True;
end;
{ @end $6144D4 }

{ @routine $6144FC SF_BlazerLanding }
procedure SF_BlazerLanding(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Weapon: TWeapon;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script BlazerLanding');
  Galaxy.BlazerLandingPlanetId := av[1].AsDword;
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
{ @end $6144FC }

{ @routine $6145CC SF_BlazerSelfDestruction }
procedure SF_BlazerSelfDestruction(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.BlazerSelfDestructTurn := Galaxy.CurrentTurn;
end;
{ @end $6145CC }

{ @routine $614604 SF_GalaxyShipId }
procedure SF_GalaxyShipId(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.NextShipId;
end;
{ @end $614604 }

{ @routine $614634 SF_NearCivilPlanet }
procedure SF_NearCivilPlanet(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Distance, BestDistance: Single;
  Ship: TShip;
  Planet: TPlanet;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script NearCivilPlanet');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := 0;
  BestDistance := 1E30;
  for Index := 0 to Ship.CurrentStar.Planets.Count - 1 do
  begin
    Planet := Ship.CurrentStar.Planets[Index];
    if Planet.OwnerId = owner_uninhabited then Continue;
    Distance := PointDistanceSquared(Ship.Position, Planet.GetPosition);
    if Distance < BestDistance then
    begin
      BestDistance := Distance;
      av[0].AsDword := Cardinal(Planet);
    end;
  end;
end;
{ @end $614634 }

{ @routine $614728 SF_SkipGreeting }
procedure SF_SkipGreeting(av: array of TVarEC; code: TCodeEC);
begin
  CurrentScript.SkipGreeting := True;
end;
{ @end $614728 }

{ @routine $614754 SF_Sound }
procedure SF_Sound(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Sound');
  SoundManager.PlaySound(av[1].AsString);
end;
{ @end $614754 }

{ @routine $6147F4 SF_Tips }
procedure SF_Tips(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script Tips');
  ShowPlayerTipOnce(av[1].AsInteger);
end;
{ @end $6147F4 }

{ @routine $614858 SF_TipsState }
procedure SF_TipsState(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script TipsState');
  av[0].AsInteger := Ord(HasShownPlayerTip(av[1].AsInteger));
end;
{ @end $614858 }

{ @routine $614A24 SF_CT }
procedure SF_CT(av: array of TVarEC; code: TCodeEC);
var
  Text: WideString;
  Block: TBlockParEC;
  // @nested $6148CC AddConfigBlock
  procedure AddConfigBlock(Block: TBlockParEC; Dest: TVarEC); // @addr 0x006148CC @note "Nested in SF_CT. Appends to Dest's existing array; empty child blocks contain one value_empty placeholder."
  var
    I: Integer;
    Value: TVarEC;
  begin
    for I := 0 to Block.GetParamCount - 1 do
    begin
      Value := TVarEC.Create(value_string);
      Value.AsString := Block.GetParamValue(I);
      Value.Name := Block.GetParamName(I);
      Dest.AsArray.AddItem(Value);
    end;
    for I := 0 to Block.GetBlockCount - 1 do
    begin
      Value := TVarEC.Create(value_array);
      Value.AsArray := TVarArrayEC.Create;
      Value.Name := Block.GetBlockNameByIndex(I);
      AddConfigBlock(Block.GetBlockByIndex(I), Value);
      if Value.AsArray.Count = 0 then Value.AsArray.AddItem(TVarEC.Create(value_empty));
      Dest.AsArray.AddItem(Value);
    end;
  end;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CT');
  if High(av) > 1 then
  begin
    if av[2].ValueKind = value_empty then
    begin
      av[2].ConvertToKind(value_array);
      av[2].AsArray := TVarArrayEC.Create;
    end
    else if av[2].ValueKind <> value_array then raise Exception.Create('Error.Script CT - 2nd argument is not an array');
    av[2].AsArray.Clear;
    if av[1].AsString = '' then Block := LanguageDataConfig
    else Block := LanguageDataConfig.FindBlockByPath(av[1].AsString);
    if Block <> nil then AddConfigBlock(Block, av[2]);
    av[0].AsInteger := av[2].AsArray.Count;
    if av[2].AsArray.Count = 0 then av[2].AsArray.AddItem(TVarEC.Create(value_empty));
  end
  else
  begin
    Text := LocalizedColorText(av[1].AsString);
    if FindTextOffsetW(Text, '<') >= 0 then
    begin
      Text := ReplaceAllWideString(Text, '<br>', #13#10);
      if GetPlayer <> nil then Text := ReplaceAllWideString(Text, '<PlayerFull>', WrapTextInColor(GetPlayer.GetFullName(' '), TextHighlightColorTag));
    end;
    av[0].AsString := ReplaceAllWideString(Text, #13#10' ', #13#10);
  end;
end;
{ @end $614A24 }

{ @routine $614D1C SF_BlockExist }
procedure SF_BlockExist(av: array of TVarEC; code: TCodeEC);
var
  Path: WideString;
  I, Count: Integer;
  Block: TBlockParEC;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BlockExist');
  Path := av[1].AsString;
  Count := CountDelimitedPartsW(Path, '.');
  if High(av) < 2 then Block := LanguageDataConfig
  else if av[2].AsString = 'Lang' then Block := LanguageDataConfig
  else if av[2].AsString = 'Main' then Block := MainDataConfig
  else if av[2].AsString = 'Config' then Block := UserSettingsConfig
  else raise Exception.Create('Error.Script BlockExist - unknown type ' + av[2].AsString);
  av[0].AsInteger := 0;
  for I := 0 to Count - 1 do
  begin
    if Block.CountBlocks(ExtractDelimitedPartW(Path, I, '.')) = 0 then Exit;
    Block := Block.GetBlock(ExtractDelimitedPartW(Path, I, '.'));
  end;
  av[0].AsInteger := 1;
end;
{ @end $614D1C }

{ @routine $615110 SF_GetMainData }
procedure SF_GetMainData(av: array of TVarEC; code: TCodeEC);
var
  Block: TBlockParEC;
  // @nested $614FB8 AddMainDataBlock
  procedure AddMainDataBlock(Block: TBlockParEC; Dest: TVarEC); // @addr 0x00614FB8 @note "Nested in SF_GetMainData. Appends to Dest's existing array; empty child blocks contain one value_empty placeholder."
  var
    I: Integer;
    Value: TVarEC;
  begin
    for I := 0 to Block.GetParamCount - 1 do
    begin
      Value := TVarEC.Create(value_string);
      Value.AsString := Block.GetParamValue(I);
      Value.Name := Block.GetParamName(I);
      Dest.AsArray.AddItem(Value);
    end;
    for I := 0 to Block.GetBlockCount - 1 do
    begin
      Value := TVarEC.Create(value_array);
      Value.AsArray := TVarArrayEC.Create;
      Value.Name := Block.GetBlockNameByIndex(I);
      AddMainDataBlock(Block.GetBlockByIndex(I), Value);
      if Value.AsArray.Count = 0 then Value.AsArray.AddItem(TVarEC.Create(value_empty));
      Dest.AsArray.AddItem(Value);
    end;
  end;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetMainData');
  if High(av) > 1 then
  begin
    if av[2].ValueKind = value_empty then
    begin
      av[2].ConvertToKind(value_array);
      av[2].AsArray := TVarArrayEC.Create;
    end
    else if av[2].ValueKind <> value_array then raise Exception.Create('Error.Script GetMainData - 2nd argument is not an array');
    av[2].AsArray.Clear;
    if av[1].AsString = '' then Block := MainDataConfig
    else Block := MainDataConfig.FindBlockByPath(av[1].AsString);
    if Block <> nil then AddMainDataBlock(Block, av[2]);
    av[0].AsInteger := av[2].AsArray.Count;
    if av[2].AsArray.Count = 0 then av[2].AsArray.AddItem(TVarEC.Create(value_empty));
  end
  else
    if MainDataConfig.CountParamsByPath(av[1].AsString) > 0 then av[0].AsString := MainDataConfig.GetParamByPath(av[1].AsString)
    else av[0].AsString := '';
end;
{ @end $615110 }

{ @routine $615328 SF_GetGameOptions }
procedure SF_GetGameOptions(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script GetGameOptions');
  if av[1].AsString = 'ResolutionX' then av[0].AsInteger := GameScreenWidth
  else if av[1].AsString = 'ResolutionY' then av[0].AsInteger := GameScreenHeight
  else
    try
      av[0].AsString := UserSettingsConfig.GetParam(av[1].AsString);
    except
      av[0].AsString := '';
    end;
end;
{ @end $615328 }

{ @routine $6154C0 SF_ResourceExist }
procedure SF_ResourceExist(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ResourceExist');
  av[0].AsInteger := Ord(CacheDataRoot.FileExistsByPath(av[1].AsString));
end;
{ @end $6154C0 }

{ @routine $615570 SF_CurrentMods }
procedure SF_CurrentMods(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then av[0].AsInteger := CountDelimitedPartsW(SelectedMods, ',')
  else if av[1].ValueKind = value_string then
    av[0].AsInteger := Ord(FindTextOffsetW(SelectedModsDisplaySuffix, ', ' + av[1].AsString + ',') >= 0)
  else if av[1].AsInteger = -1 then av[0].AsString := SelectedMods
  else av[0].AsString := ExtractDelimitedPartW(SelectedMods, av[1].AsInteger, ',');
end;
{ @end $615570 }

{ @routine $615698 SF_RobotSupport }
procedure SF_RobotSupport(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Ord((RobotInterface <> nil) and (RobotInterface.Support() = 0));
end;
{ @end $615698 }

{ @routine $6156E0 SF_StarShips }
procedure SF_StarShips(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarShips');
  Star := TStar(av[1].AsDword);
  if Star = nil then Exit;
  if High(av) = 1 then av[0].AsInteger := Star.Ships.Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Star.Ships.Count) then av[0].AsDword := Cardinal(Star.Ships[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $6156E0 }

{ @routine $615798 SF_StarPlanets }
procedure SF_StarPlanets(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarPlanets');
  Star := TStar(av[1].AsDword);
  if Star = nil then Exit;
  if High(av) = 1 then av[0].AsInteger := Star.Planets.Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Star.Planets.Count) then av[0].AsDword := Cardinal(Star.Planets[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $615798 }

{ @routine $615854 SF_StarMissiles }
procedure SF_StarMissiles(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarMissiles');
  Star := TStar(av[1].AsDword);
  if Star = nil then Exit;
  if High(av) = 1 then av[0].AsInteger := Star.Missiles.Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Star.Missiles.Count) then av[0].AsDword := Cardinal(Star.Missiles[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $615854 }

{ @routine $615910 SF_StarAsteroids }
procedure SF_StarAsteroids(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarAsteroids');
  Star := TStar(av[1].AsDword);
  if Star = nil then Exit;
  if High(av) = 1 then av[0].AsInteger := Star.Asteroids.Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Star.Asteroids.Count) then av[0].AsDword := Cardinal(Star.Asteroids[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $615910 }

{ @routine $6159CC SF_GroupShip }
procedure SF_GroupShip(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
  I, Count, GroupIndex, FoundCount, WantedCount: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GroupShip');
  GroupIndex := av[1].AsInteger;
  WantedCount := av[2].AsInteger + 1;
  FoundCount := 0;
  av[0].AsDword := 0;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then
    begin
      Inc(FoundCount);
      if FoundCount = WantedCount then av[0].AsDword := Cardinal(Binding.Ship);
    end;
  end;
end;
{ @end $6159CC }

{ @routine $615AA4 SF_ShipItems }
procedure SF_ShipItems(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ShipItems');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if High(av) = 1 then av[0].AsInteger := Ship.Inventory.Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Ship.Inventory.Count) then av[0].AsDword := Cardinal(Ship.Inventory[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $615AA4 }

{ @routine $615B68 SF_ShipArts }
procedure SF_ShipArts(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ShipArts');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if High(av) = 1 then av[0].AsInteger := Ship.Artefacts.Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Ship.Artefacts.Count) then av[0].AsDword := Cardinal(Ship.Artefacts[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $615B68 }

{ @routine $615C2C SF_PlayerTranclucators }
procedure SF_PlayerTranclucators(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Ship: TShip;
  I, J, Count, Wanted: Integer;
begin
  Count := -1;
  Wanted := -1;
  if High(av) >= 1 then Wanted := av[1].AsInteger;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if not (Ship is TTranclucator) then Continue;
      if (Ship as TTranclucator).OwnerShip <> GetPlayer then Continue;
          Inc(Count);
          if Count = Wanted then
          begin
            av[0].AsDword := Cardinal(Ship);
            Exit;
          end;
    end;
  end;
  av[0].AsInteger := Count + 1;
end;
{ @end $615C2C }

{ @routine $615D30 SF_ArtTranclucatorToShip }
procedure SF_ArtTranclucatorToShip(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ArtTranclucatorToShip');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item = nil then Exit;
  if not (Item is TArtefactTranclucator) then Exit;
  av[0].AsDword := Cardinal((Item as TArtefactTranclucator).Ship);
end;
{ @end $615D30 }

{ @routine $615E00 SF_TranclucatorData }
procedure SF_TranclucatorData(av: array of TVarEC; code: TCodeEC);
var
  Ship: TTranclucator;
  WriteValue: Boolean;
  Kind: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_TranclucatorData');
  Ship := TTranclucator(av[1].AsDword);
  if av[2].ValueKind = value_string then
  begin
    if av[2].AsString = 'Proprietor' then Kind := 0
    else if av[2].AsString = 'ArtSize' then Kind := 1
    else if av[2].AsString = 'ArtSysName' then Kind := 2
    else if av[2].AsString = 'Docking' then Kind := 3
    else if av[2].AsString = 'SeekItems' then Kind := 4
    else if av[2].AsString = 'AutoArrange' then Kind := 5
    else if av[2].AsString = 'LandStorage' then Kind := 6
    else if av[2].AsString = 'LandPermitPlanets' then Kind := 7
    else if av[2].AsString = 'LandPermitRuins' then Kind := 8
    else if av[2].AsString = 'SeekPermitNone' then Kind := 9
    else if av[2].AsString = 'SeekPermitArtefact' then Kind := 10
    else if av[2].AsString = 'SeekPermitMicromodule' then Kind := 11
    else if av[2].AsString = 'SeekPermitEquipment' then Kind := 12
    else if av[2].AsString = 'SeekPermitUseless' then Kind := 13
    else if av[2].AsString = 'SeekPermitGoods' then Kind := 14
    else if av[2].AsString = 'SeekPermitNode' then Kind := 15
    else raise Exception.Create('Error.Script SF_TranclucatorData - unknown property ' + av[2].AsString);
  end
  else Kind := av[2].AsInteger;
  WriteValue := High(av) > 2;
  case Kind of
    0: begin
      av[0].AsDword := Cardinal(Ship.OwnerShip);
      if WriteValue then Ship.OwnerShip := TShip(av[3].AsDword);
    end;
    1: begin
      av[0].AsInteger := Ship.ArtefactSize;
      if WriteValue then Ship.ArtefactSize := av[3].AsInteger;
    end;
    2: begin
      av[0].AsString := Ship.ArtefactSystemName;
      if WriteValue then Ship.ArtefactSystemName := av[3].AsString;
    end;
    3: begin
      av[0].AsInteger := Ord(Ship.FollowOwner);
      if WriteValue then Ship.FollowOwner := av[3].AsInteger <> 0;
    end;
    4: begin
      av[0].AsInteger := Ord(Ship.SeekItems);
      if WriteValue then Ship.SeekItems := av[3].AsInteger <> 0;
    end;
    5: begin
      av[0].AsInteger := Ord(Ship.AutoArrange);
      if WriteValue then Ship.AutoArrange := av[3].AsInteger <> 0;
    end;
    6: begin
      av[0].AsInteger := Ord(Ship.StoreOnLanding);
      if WriteValue then Ship.StoreOnLanding := av[3].AsInteger <> 0;
    end;
    7: begin
      av[0].AsInteger := Ord(Ship.StoragePermissions[storage_planet]);
      if WriteValue then Ship.StoragePermissions[storage_planet] := av[3].AsInteger <> 0;
    end;
    8: begin
      av[0].AsInteger := Ord(Ship.StoragePermissions[storage_station]);
      if WriteValue then Ship.StoragePermissions[storage_station] := av[3].AsInteger <> 0;
    end;
    9: begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[collect_other]);
      if WriteValue then Ship.CollectionPermissions[collect_other] := av[3].AsInteger <> 0;
    end;
    10: begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[collect_artefacts]);
      if WriteValue then Ship.CollectionPermissions[collect_artefacts] := av[3].AsInteger <> 0;
    end;
    11: begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[collect_micromodules]);
      if WriteValue then Ship.CollectionPermissions[collect_micromodules] := av[3].AsInteger <> 0;
    end;
    12: begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[collect_equipment]);
      if WriteValue then Ship.CollectionPermissions[collect_equipment] := av[3].AsInteger <> 0;
    end;
    13: begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[collect_misc_items]);
      if WriteValue then Ship.CollectionPermissions[collect_misc_items] := av[3].AsInteger <> 0;
    end;
    14: begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[collect_goods]);
      if WriteValue then Ship.CollectionPermissions[collect_goods] := av[3].AsInteger <> 0;
    end;
    15: begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[collect_stackables]);
      if WriteValue then Ship.CollectionPermissions[collect_stackables] := av[3].AsInteger <> 0;
    end;
  else raise Exception.Create('Error.Script SF_TranclucatorData - unknown property ' + IntToWideString(Kind));
  end;
end;
{ @end $615E00 }

{ @routine $616768 SF_LinkItemToScript }
procedure SF_LinkItemToScript(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptItem;
  Item: TItem;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_LinkItemToScript');
  Item := TItem(av[1].AsDword);
  if Item.ScriptItem <> nil then (Item.ScriptItem as TScriptItem).Item := nil;
  if High(av) < 2 then
  begin
    if CurrentScript = nil then raise Exception.Create('Error.Script SF_LinkItemToScript - no script');
    Binding := nil;
    for I := 0 to CurrentScript.Items.Count - 1 do
    begin
      Binding := CurrentScript.Items[I];
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
  else Binding := TScriptItem(av[2].AsDword);
  if Binding.Item <> nil then Binding.Item.ScriptItem := nil;
  Binding.Item := Item;
  Item.ScriptItem := Binding;
end;
{ @end $616768 }

{ @routine $616910 SF_ReleaseItemFromScript }
procedure SF_ReleaseItemFromScript(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ReleaseItemFromScript');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  if Binding.Item <> nil then Binding.Item.ScriptItem := nil;
  Binding.Item := nil;
end;
{ @end $616910 }

{ @routine $6169BC SF_ScriptItemData }
procedure SF_ScriptItemData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ScriptItemData');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  av[0].AsInteger := 0;
  Index := av[2].AsInteger;
  case Index of
    1: av[0].AsInteger := Binding.Data[1];
    2: av[0].AsInteger := Binding.Data[2];
    3: av[0].AsInteger := Binding.Data[3];
  else raise Exception.Create('Error.Script ScriptItemData no');
  end;
  if High(av) > 2 then
    case Index of
      1: Binding.Data[1] := av[3].AsInteger;
      2: Binding.Data[2] := av[3].AsInteger;
      3: Binding.Data[3] := av[3].AsInteger;
    end;
end;
{ @end $6169BC }

{ @routine $616B10 SF_ScriptItemTextData }
procedure SF_ScriptItemTextData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ScriptItemTextData');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  av[0].AsString := '';
  Index := av[2].AsInteger;
  case Index of
    1: av[0].AsString := Binding.TextData1;
    2: av[0].AsString := Binding.TextData2;
    3: av[0].AsString := Binding.TextData3;
  else raise Exception.Create('Error.Script ScriptItemTextData no');
  end;
  if High(av) > 2 then
    case Index of
      1: Binding.TextData1 := av[3].AsString;
      2: Binding.TextData2 := av[3].AsString;
      3: Binding.TextData3 := av[3].AsString;
    end;
end;
{ @end $616B10 }

{ @routine $616CC4 SF_ScriptItemToItem }
procedure SF_ScriptItemToItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ScriptItemToItem');
  Obj := TObject(av[1].AsDword);
  av[0].AsDword := 0;
  if Obj = nil then Exit;
  if Obj is TItem then av[0].AsDword := Cardinal(Obj)
  else if Obj is TScriptItem then av[0].AsDword := Cardinal(TScriptItem(Obj).Item);
end;
{ @end $616CC4 }

{ @routine $616D7C SF_GetShipPirateRank }
procedure SF_GetShipPirateRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipPirateRank');
  Ship := TNormalShip(av[1].AsDword);
  av[0].AsDword := Ship.PirateRank;
end;
{ @end $616D7C }

{ @routine $616DF8 SF_ShipPirateRankPoints }
procedure SF_ShipPirateRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipPirateRankPoints');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsDword := Ship.PirateRankPoints;
  if High(av) > 1 then Ship.PirateRankPoints := av[2].AsDword;
end;
{ @end $616DF8 }

{ @routine $616E9C SF_ShipNextPirateRankPoints }
procedure SF_ShipNextPirateRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipNextPirateRankPoints');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsInteger := PirateRankPointThresholds[Ship.PirateRank];
end;
{ @end $616E9C }

{ @routine $616F34 SF_ShipInPirateClan }
procedure SF_ShipInPirateClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInPirateClan');
  Ship := TShip(av[1].AsDword);
  if GetPlayer = Ship then av[0].AsDword := Ord(GetPlayer.PirateClanReal)
  else av[0].AsDword := Ord(Ship.OwnerId = owner_pirate);
end;
{ @end $616F34 }

{ @routine $616FD0 SF_ShipOnSidePirateClan }
procedure SF_ShipOnSidePirateClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOnSidePirateClan');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := Ord(Ship.OwnerId = owner_pirate);
end;
{ @end $616FD0 }

{ @routine $617050 SF_RaisePirateRank }
procedure SF_RaisePirateRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
  Rank: Cardinal;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RaisePirateRank');
  Ship := TNormalShip(av[1].AsDword);
  if High(av) > 1 then Ship.PirateRank := av[2].AsInteger
  else
  begin
    Rank := Ship.PirateRank;
    if Rank < 7 then Ship.PirateRank := Rank + 1;
  end;
  if GetPlayer = Ship then GetPlayer.AchievementStats.CheckBaronAchievement;
end;
{ @end $617050 }

{ @routine $617104 SF_ItemType }
procedure SF_ItemType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemType');
  Value := 0;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Ord(Item.ItemType);
  end;
  av[0].AsDword := Value;
end;
{ @end $617104 }

{ @routine $6171B4 SF_CustomWeaponType }
procedure SF_CustomWeaponType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomWeaponType');
  av[0].AsString := '';
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item = nil then Exit;
  if not (Item is TCustomWeapon) then Exit;
  av[0].AsString := (Item as TCustomWeapon).GetWeaponInfo.ConfigName;
end;
{ @end $6171B4 }

{ @routine $617288 SF_ItemName }
procedure SF_ItemName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Text: WideString;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemName');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  Text := '';
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then Text := Item.GetShortName;
  av[0].AsString := Text;
end;
{ @end $617288 }

{ @routine $617374 SF_ItemFullName }
procedure SF_ItemFullName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Text: WideString;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemFullName');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  Text := '';
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then Text := Item.GetDisplayName;
  av[0].AsString := Text;
end;
{ @end $617374 }

{ @routine $617464 SF_ItemSize }
procedure SF_ItemSize(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Integer;
  IsCountable, IsGoods: Boolean;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemSize');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    IsGoods := Item.ItemType in [item_food..item_narcotics];
    IsCountable := not IsGoods and (Item is TCountableItem);
    if (IsCountable or IsGoods) and (High(av) > 1) and (av[2].ValueKind = value_string) and (av[2].AsString = 'Count') then
    begin
      if IsCountable then av[0].AsDword := TCountableItem(Item).StackCount
      else av[0].AsDword := TGoods(Item).Quantity;
    end
    else av[0].AsDword := Item.Weight;
    if (High(av) > 1) and (av[2].ValueKind <> value_string) then
    begin
      Value := av[2].AsInteger;
      if IsCountable then
      begin
        if (High(av) > 2) and (av[3].ValueKind = value_string) and (av[3].AsString = 'Count') then
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
        { Count-mode goods handling reads the countable-item offset, then rescales Cost again below. }
        if (High(av) > 2) and (av[3].ValueKind = value_string) and (av[3].AsString = 'Count') then
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
    av[0].AsDword := TTranclucator(Obj).ArtefactSize;
    if High(av) > 1 then TTranclucator(Obj).ArtefactSize := av[2].AsInteger;
  end;
end;
{ @end $617464 }

{ @routine $6177D0 SF_ItemOwner }
procedure SF_ItemOwner(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemOwner');
  Value := 0;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Ord(Item.OwnerId);
    if High(av) > 1 then Item.OwnerId := TOwnerId(av[2].AsDword);
  end;
  av[0].AsDword := Value;
end;
{ @end $6177D0 }

{ @routine $617898 SF_ItemSubrace }
procedure SF_ItemSubrace(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TEquipment;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemSubrace');
  Value := 0;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TEquipment(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item as TEquipment;
  if Item <> nil then
  begin
    Value := Ord(Item.DominatorSeries);
    if High(av) > 1 then Item.DominatorSeries := TDominatorSeries(av[2].AsDword);
  end;
  av[0].AsDword := Value;
end;
{ @end $617898 }

{ @routine $617974 SF_ItemCost }
procedure SF_ItemCost(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Cardinal;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemCost');
  Value := 0;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Item.Cost;
    if High(av) > 1 then Item.Cost := av[2].AsInteger;
  end;
  av[0].AsDword := Value;
end;
{ @end $617974 }

{ @routine $617A3C SF_ItemIsInUse }
procedure SF_ItemIsInUse(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemIsInUse');
  Obj := TObject(av[1].AsDword);
  av[0].AsInteger := 0;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item = nil then Exit;
  if (Item is TEquipment) and ((Item as TEquipment).EquippedFlag <> 0) then
    av[0].AsInteger := Integer((Item as TEquipment).AssignedSlotData) + 1;
  if (High(av) <= 2) or not (Item is TEquipment) then Exit;
  Ship := TShip(av[2].AsDword);
  if Ship <> nil then
  begin
    if Item is TArtefact then
    begin
      if av[3].AsInteger <> 0 then
      begin
        TEquipment(Item).Equip;
        if High(av) > 3 then TEquipment(Item).AssignedSlotData := av[4].AsInteger - 1;
      end
      else (Item as TArtefact).Unequip;
    end
    else if Item is TWeapon then
    begin
      if av[3].AsInteger <> 0 then
      begin
        Ship.EquipItem(TEquipment(Item));
        if High(av) > 3 then TEquipment(Item).AssignedSlotData := av[4].AsInteger - 1;
      end
      else
        for I := 1 to Ship.WeaponCount do
          if Ship.Weapons[I] = Item then Ship.UnequipSlot(Item.ItemType, I);
    end
    else
    begin
      if av[3].AsInteger <> 0 then
      begin
        Ship.EquipItem(TEquipment(Item));
        if High(av) > 3 then TEquipment(Item).AssignedSlotData := av[4].AsInteger - 1;
      end
      else Ship.UnequipSlot(Item.ItemType, 0);
    end;
    Ship.RefreshAssignedItemSlots;
    Ship.RefreshDerivedStats(True);
    Ship.ScriptItemsAct(event_nonstandard_equipment_change, nil, nil, 0);
  end;
end;
{ @end $617A3C }

{ @routine $617C70 SF_ItemIsInSet }
procedure SF_ItemIsInSet(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  SetIndex: Integer;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemIsInSet');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  av[0].AsInteger := 0;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item = nil then Exit;
  if High(av) > 1 then
  begin
    SetIndex := av[2].AsInteger - 1;
    if (SetIndex >= 0) and (SetIndex <= 9) then
      for I := Low(GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds) to
        High(GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds) do
        if GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds[I] = Item.Id then
        begin
          av[0].AsInteger := 1;
          Exit;
        end;
  end
  else
    for SetIndex := Low(GetPlayer.EquipmentConfigurations) to High(GetPlayer.EquipmentConfigurations) do
    begin
      for I := Low(GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds) to
        High(GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds) do
        if GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds[I] = Item.Id then
        begin
          av[0].AsInteger := SetIndex + 1;
          Exit;
        end;
      for I := Low(GetPlayer.EquipmentConfigurations[SetIndex].ArtefactIds) to
        High(GetPlayer.EquipmentConfigurations[SetIndex].ArtefactIds) do
        if GetPlayer.EquipmentConfigurations[SetIndex].ArtefactIds[I] = Item.Id then
        begin
          av[0].AsInteger := SetIndex + 1;
          Exit;
        end;
    end;
end;
{ @end $617C70 }

{ @routine $617DDC SF_PlayerEqSet }
procedure SF_PlayerEqSet(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then av[0].AsInteger := GetPlayer.SelectedEquipmentConfiguration + 1
  else
  begin
    Index := av[1].AsInteger - 1;
    if GetPlayer.SelectedEquipmentConfiguration = Index then av[0].AsInteger := 2
    else if GetPlayer.HasEquipmentConfiguration(Index) then av[0].AsInteger := 1
    else av[0].AsInteger := 0;
    if High(av) > 1 then
    begin
      if av[2].AsInteger = 2 then
      begin
        GetPlayer.ApplyEquipmentConfiguration(Index);
        GetPlayer.SelectedEquipmentConfiguration := Index;
      end
      else if av[2].AsInteger = 1 then
      begin
        GetPlayer.SaveEquipmentConfiguration(Index);
        GetPlayer.SelectedEquipmentConfiguration := Index;
      end;
    end;
  end;
end;
{ @end $617DDC }

{ @routine $617EBC SF_ItemIsBroken }
procedure SF_ItemIsBroken(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Broken: Byte;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemIsBroken');
  Obj := TObject(av[1].AsDword);
  Broken := 0;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    if Item is TEquipment then Broken := (Item as TEquipment).BrokenFlag;
    if Item is TArtefact then Broken := (Item as TArtefact).BrokenFlag;
  end;
  if Broken <> 0 then av[0].AsInteger := 1 else av[0].AsInteger := 0;
end;
{ @end $617EBC }

{ @routine $617FC4 SF_ShipCanUseEq }
procedure SF_ShipCanUseEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipCanUseEq');
  Ship := TShip(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TItem then Item := TItem(Obj)
  else if Obj is TScriptItem then Item := TScriptItem(Obj).Item
  else Item := nil;
  av[0].AsInteger := 0;
  if Item <> nil then
    if Item is TEquipment then av[0].AsInteger := Ord(Ship.CanUseEquipmentTech(TEquipment(Item)));
end;
{ @end $617FC4 }

{ @routine $618098 SF_ShipCanRepairEq }
procedure SF_ShipCanRepairEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipCanRepairEq');
  Ship := TShip(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TItem then Item := TItem(Obj)
  else if Obj is TScriptItem then Item := TScriptItem(Obj).Item
  else Item := nil;
  av[0].AsInteger := 0;
  if Item <> nil then
    if Item is TEquipment then av[0].AsInteger := Ord(Ship.CanRepairEquipmentTech(TEquipment(Item)));
end;
{ @end $618098 }

{ @routine $618170 SF_ShipTechLevelKnowledge }
procedure SF_ShipTechLevelKnowledge(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipTechLevelKnowledge');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ship.TechKnowledge;
  if High(av) > 1 then Ship.TechKnowledge := av[2].AsInteger;
end;
{ @end $618170 }

{ @routine $618208 SF_WeaponTarget }
procedure SF_WeaponTarget(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script WeaponTarget');
  Obj := TObject(av[1].AsDword);
  av[0].AsDword := 0;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TWeapon) then
    if (Item as TWeapon).EquippedFlag <> 0 then
  begin
    av[0].AsDword := Cardinal((Item as TWeapon).Target);
    if High(av) > 1 then (Item as TWeapon).Target := TObject(av[2].AsDword);
  end;
end;
{ @end $618208 }

{ @routine $618310 SF_GetEquipmentStats }
procedure SF_GetEquipmentStats(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Stat: Integer;
  Text: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetEquipmentStats');
  Obj := TObject(av[1].AsDword);
  Stat := 0;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item = nil then Exit;
  if High(av) > 1 then
  begin
    if av[2].ValueKind = value_string then
    begin
      if Item is TEquipment then
      begin
        Text := av[2].AsString;
        TEquipment(Item).ReplaceInfoTokens(Text, '', nil);
        av[0].AsString := Text;
      end
      else av[0].AsString := '';
      Exit;
    end;
    Stat := av[2].AsInteger;
  end;
  if Item.ItemType in WeaponItemTypes then
    case Stat of
      0: av[0].AsInteger := (Item as TWeapon).MaxDamage;
      1: av[0].AsInteger := (Item as TWeapon).MinDamage;
      2: av[0].AsInteger := (Item as TWeapon).Range;
      3: av[0].AsInteger := Ord(ClassifyWeaponDamageFlags((Item as TWeapon).GetWeaponInfo.DamageFlags));
      4: av[0].AsInteger := (Item as TWeapon).GetAttackCount;
      5: av[0].AsInteger := (Item as TWeapon).GetShotCount;
      6: av[0].AsDword := Dword((Item as TWeapon).GetDamageFlags);
  end
  else case Item.ItemType of
    item_hull: case Stat of
      0: av[0].AsInteger := (Item as THull).Armor;
      1: av[0].AsInteger := (Item as THull).GetSlotCount(slot_weapon);
      2: av[0].AsInteger := (Item as THull).GetSlotCount(slot_artefact);
      3: av[0].AsInteger := (Item as THull).GetSlotCount(slot_radar);
      4: av[0].AsInteger := (Item as THull).GetSlotCount(slot_scanner);
      5: av[0].AsInteger := (Item as THull).GetSlotCount(slot_repair_robot);
      6: av[0].AsInteger := (Item as THull).GetSlotCount(slot_cargo_hook);
      7: av[0].AsInteger := (Item as THull).GetSlotCount(slot_defense_generator);
      8: av[0].AsInteger := (Item as THull).GetSlotCount(slot_afterburner);
    end;
    item_fuel_tanks: case Stat of
      0: av[0].AsInteger := (Item as TFuelTanks).Capacity;
      1: av[0].AsInteger := (Item as TFuelTanks).Fuel;
    end;
    item_engine: case Stat of
      0: av[0].AsInteger := (Item as TEngine).Speed;
      1: av[0].AsInteger := (Item as TEngine).JumpRange;
    end;
    item_radar: av[0].AsInteger := (Item as TRadar).Range;
    item_scanner: av[0].AsInteger := (Item as TScaner).ScanPower;
    item_repair_robot: av[0].AsInteger := (Item as TRepairRobot).RepairPoints;
    item_cargo_hook: case Stat of
      0: av[0].AsInteger := (Item as TCargoHook).PickupPower;
      1: av[0].AsInteger := (Item as TCargoHook).Range;
      2: av[0].AsFloat := (Item as TCargoHook).MinPullSpeed;
      3: av[0].AsFloat := (Item as TCargoHook).MaxPullSpeed;
    end;
    item_defense_generator: av[0].AsInteger := Round(100 - (Item as TDefGenerator).DamageFactor * 100);
    item_fuel_container: case Stat of
      0: av[0].AsInteger := (Item as TCistern).Capacity;
      1: av[0].AsInteger := (Item as TCistern).Fuel;
    end;
    item_satellite: case Stat of
      0: av[0].AsInteger := (Item as TSatellite).WaterExplorationRate;
      1: av[0].AsInteger := (Item as TSatellite).LandExplorationRate;
      2: av[0].AsInteger := (Item as TSatellite).HillExplorationRate;
      3: av[0].AsFloat := (Item as TSatellite).WearPerTurn;
    end;
  end;
  if av[0].ValueKind = value_empty then av[0].AsInteger := 0;
end;
{ @end $618310 }

{ @routine $6189C4 SF_SetEquipmentStats }
procedure SF_SetEquipmentStats(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Stat: Integer;
  Value: Cardinal;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetEquipmentStats');
  Obj := TObject(av[1].AsDword);
  Value := av[2].AsDword;
  Stat := 0;
  if High(av) > 2 then Stat := av[3].AsInteger;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item = nil then Exit;
  if Item.ItemType in WeaponItemTypes then
    case Stat of
      0: (Item as TWeapon).MaxDamage := Value;
      1: (Item as TWeapon).MinDamage := Value;
      2: (Item as TWeapon).Range := Value;
  end
  else case Item.ItemType of
    item_hull: (Item as THull).Armor := Value;
    item_fuel_tanks: case Stat of
      0: (Item as TFuelTanks).Capacity := Value;
      1: (Item as TFuelTanks).Fuel := Value;
    end;
    item_engine: case Stat of
      0: (Item as TEngine).Speed := Value;
      1: (Item as TEngine).JumpRange := Value;
    end;
    item_radar: (Item as TRadar).Range := Value;
    item_scanner: (Item as TScaner).ScanPower := Value;
    item_repair_robot: (Item as TRepairRobot).RepairPoints := Value;
    item_cargo_hook: case Stat of
      0: (Item as TCargoHook).PickupPower := Value;
      1: (Item as TCargoHook).Range := Value;
      2: (Item as TCargoHook).MinPullSpeed := av[2].AsFloat;
      3: (Item as TCargoHook).MaxPullSpeed := av[2].AsFloat;
    end;
    item_defense_generator: (Item as TDefGenerator).DamageFactor := Integer(100 - Value) * 0.01;
    item_fuel_container: case Stat of
      0: (Item as TCistern).Capacity := Value;
      1: (Item as TCistern).Fuel := Value;
    end;
    item_satellite: case Stat of
      0: (Item as TSatellite).WaterExplorationRate := Value;
      1: (Item as TSatellite).LandExplorationRate := Value;
      2: (Item as TSatellite).HillExplorationRate := Value;
      3: (Item as TSatellite).WearPerTurn := av[2].AsFloat;
    end;
  end;
end;
{ @end $6189C4 }

{ @routine $618DB0 SF_CreateHull }
procedure SF_CreateHull(av: array of TVarEC; code: TCodeEC);
var
  Hull: THull;
  HullType: THullType; Owner: TOwnerId;
  Level, Capacity, Series: Integer;
  PirateBuilt: Boolean;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CreateHull');
  HullType := THullType(av[1].AsDword);
  Capacity := av[2].AsInteger;
  Level := av[3].AsInteger;
  Owner := TOwnerId(av[4].AsDword);
  Series := -1;
  PirateBuilt := False;
  if High(av) > 4 then Series := av[5].AsInteger;
  if High(av) > 5 then PirateBuilt := av[6].AsInteger <> 0;
  Hull := THull.Create;
  Hull.Init(Capacity, Level, Owner, HullType, Series, PirateBuilt);
  av[0].AsDword := Cardinal(Hull);
end;
{ @end $618DB0 }

{ @routine $618EA0 SF_CreateEquipment }
procedure SF_CreateEquipment(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Kind: TItemType;
  Owner: TOwnerId;
  Weight, Level: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CreateEquipment');
  Kind := TItemType(av[1].AsDword);
  Weight := av[2].AsInteger;
  Level := av[3].AsInteger;
  Owner := TOwnerId(av[4].AsDword);
  if Kind = item_fuel_container then
  begin
    Item := TCistern.Create;
    TCistern(Item).Init(Level, Weight, Owner);
  end
  else Item := CreateGeneratedEquipment(Kind, Weight, Byte(Level), Owner);
  av[0].AsDword := Cardinal(Item);
end;
{ @end $618EA0 }

{ @routine $618F7C SF_CreateArt }
procedure SF_CreateArt(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefact;
  Kind: TItemType;
  Owner: TOwnerId;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CreateArt');
  Kind := TItemType(av[1].AsDword);
  Owner := TOwnerId(av[2].AsDword);
  Item := CreateConfiguredArtefactByItemType(Kind, Owner);
  av[0].AsDword := Cardinal(Item);
end;
{ @end $618F7C }

{ @routine $619000 SF_CreateCustomWeapon }
procedure SF_CreateCustomWeapon(av: array of TVarEC; code: TCodeEC);
var
  Item: TWeapon;
  Owner: TOwnerId;
  Weight, Level: Integer;
  Info: PWeaponInfo;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CreateEquipment');
  Info := Galaxy.RequireCustomWeaponInfo(av[1].AsString);
  Weight := av[2].AsInteger;
  Level := av[3].AsInteger;
  Owner := TOwnerId(av[4].AsDword);
  Item := CreateGeneratedWeapon(Info, Weight, TTechLevel(Level), Owner);
  av[0].AsDword := Cardinal(Item);
end;
{ @end $619000 }

{ @routine $6190EC SF_CreateCustomArt }
procedure SF_CreateCustomArt(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefactCustom;
  ConfigName: WideString;
  Owner: TOwnerId;
  Weight, Cost: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CreateCustomArt');
  ConfigName := av[1].AsString;
  Weight := av[2].AsInteger;
  Cost := av[3].AsInteger;
  Owner := TOwnerId(av[4].AsDword);
  Item := TArtefactCustom.Create;
  Item.ConfigBlockName := ConfigName;
  Item.LoadConfig(True);
  Item.Data[1] := 0;
  Item.Data[2] := 0;
  Item.Data[3] := 0;
  Item.Weight := Weight;
  Item.Cost := Cost;
  Item.OwnerId := Owner;
  av[0].AsDword := Cardinal(Item);
end;
{ @end $6190EC }

{ @routine $6191FC SF_CustomArtData }
procedure SF_CustomArtData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CustomArtData');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].AsInteger := 0;
  if not (Item is TArtefactCustom) then Exit;
  Index := av[2].AsInteger;
  case Index of
    1: av[0].AsInteger := (Item as TArtefactCustom).Data[1];
    2: av[0].AsInteger := (Item as TArtefactCustom).Data[2];
    3: av[0].AsInteger := (Item as TArtefactCustom).Data[3];
  else raise Exception.Create('Error.Script CustomArtData no');
  end;
  if High(av) > 2 then
    case Index of
      1: (Item as TArtefactCustom).Data[1] := av[3].AsInteger;
      2: (Item as TArtefactCustom).Data[2] := av[3].AsInteger;
      3: (Item as TArtefactCustom).Data[3] := av[3].AsInteger;
    end;
end;
{ @end $6191FC }

{ @routine $6193B8 SF_CustomArtTextData }
procedure SF_CustomArtTextData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CustomArtTextData');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].AsString := '';
  if not (Item is TArtefactCustom) then Exit;
  Index := av[2].AsInteger;
  case Index of
    1: av[0].AsString := (Item as TArtefactCustom).TextData1;
    2: av[0].AsString := (Item as TArtefactCustom).TextData2;
    3: av[0].AsString := (Item as TArtefactCustom).TextData3;
  else raise Exception.Create('Error.Script CustomArtTextData no');
  end;
  if High(av) > 2 then
    case Index of
      1: (Item as TArtefactCustom).TextData1 := av[3].AsString;
      2: (Item as TArtefactCustom).TextData2 := av[3].AsString;
      3: (Item as TArtefactCustom).TextData3 := av[3].AsString;
    end;
end;
{ @end $6193B8 }

{ @routine $6195E0 SF_CreateMM }
procedure SF_CreateMM(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Item: TMicroModule;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateMM');
  Index := av[1].AsInteger;
  Item := TMicroModule.Create;
  Item.Init(Index);
  av[0].AsDword := Cardinal(Item);
end;
{ @end $6195E0 }

{ @routine $61966C SF_CreateNodes }
procedure SF_CreateNodes(av: array of TVarEC; code: TCodeEC);
var
  Item: TProtoplasm;
  DropFlag: Boolean;
  Series: TDominatorSeries;
  Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateNodes');
  Count := av[1].AsInteger;
  DropFlag := False;
  Series := series_blazer;
  if High(av) > 1 then Series := TDominatorSeries(av[2].AsInteger);
  if High(av) > 2 then DropFlag := av[3].AsInteger <> 0;
  Item := TProtoplasm.Create;
  Item.Init(Count, Ord(DropFlag));
  Item.DominatorSeries := Series;
  av[0].AsDword := Cardinal(Item);
end;
{ @end $61966C }

{ @routine $619734 SF_CreateCustomCountableItem }
procedure SF_CreateCustomCountableItem(av: array of TVarEC; code: TCodeEC);
var
  ConfigName: WideString;
  Count: Integer;
  DropFlag: Boolean;
  Item: TCountableItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateCustomCountableItem');
  ConfigName := av[1].AsString;
  if High(av) > 1 then Count := av[2].AsInteger else Count := 1;
  if High(av) > 2 then DropFlag := av[3].AsInteger <> 0 else DropFlag := False;
  Item := TCountableItem.Create;
  Item.Init(ConfigName, Count, Ord(DropFlag));
  av[0].AsDword := Cardinal(Item);
end;
{ @end $619734 }

{ @routine $61983C SF_CreateZond }
procedure SF_CreateZond(av: array of TVarEC; code: TCodeEC);
var
  Item: TSatellite;
  Owner: TOwnerId; Kind: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CreateZond');
  Kind := av[1].AsDword;
  Owner := TOwnerId(av[2].AsDword);
  Item := TSatellite.Create;
  Item.InitGenerated(Kind, Owner, NextRandomIntRange(1, 10000, Galaxy.RandomState));
  if High(av) > 4 then
  begin
    Item.WaterExplorationRate := av[3].AsInteger;
    Item.LandExplorationRate := av[4].AsInteger;
    Item.HillExplorationRate := av[5].AsInteger;
  end;
  av[0].AsDword := Cardinal(Item);
end;
{ @end $61983C }

{ @routine $61991C SF_ExistingZonds }
procedure SF_ExistingZonds(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
  begin
    av[0].AsInteger := Galaxy.CountExistingSatellites;
    Exit;
  end;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < GetPlayer.Satellites.Count) then
  begin
    if (High(av) > 1) and (av[2].AsInteger = 1) then av[0].AsDword := Cardinal(TSatellite(GetPlayer.Satellites[Index]).TargetPlanet)
    else av[0].AsDword := Cardinal(GetPlayer.Satellites[Index]);
  end
  else av[0].AsDword := 0;
end;
{ @end $61991C }

{ @routine $6199D0 SF_FreeItem }
procedure SF_FreeItem(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FreeItem');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item = nil then Exit;
  if Item.ScriptItem <> nil then (Item.ScriptItem as TScriptItem).Item := nil;
  Item.Free;
end;
{ @end $6199D0 }

{ @routine $619A84 SF_ShipJoinsClan }
procedure SF_ShipJoinsClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipJoinsClan');
  Ship := TShip(av[1].AsDword);
  if (Ship.TypeId = ship_pirate) and (Ship.OwnerId <> owner_pirate) then
  begin
    Inc(Galaxy.PirateClanCount);
    Dec(Galaxy.PirateCount);
  end;
  Ship.OwnerId := owner_pirate;
  if GetPlayer = Ship then GetPlayer.PirateClanReal := True;
end;
{ @end $619A84 }

{ @routine $619B28 SF_AddItemToShip }
procedure SF_AddItemToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item, Other: TItem;
  GoodsKind: TGoodsIndex;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddItemToShip');
  Ship := TShip(av[1].AsDword);
  Item := TItem(av[2].AsDword);
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
      Other := Ship.Inventory[Index];
      if not (Item as TCountableItem).CanMerge(Other) then Continue;
      (Other as TCountableItem).Merge(Item);
      Item.Free;
      Item := nil;
      Break;
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
    Ship.ScriptItemsAct(event_nonstandard_equipment_change, nil, nil, 0);
  end
  else if Item is TArtefact then Ship.Artefacts.Add(Item)
  else if Item is TEquipment then Ship.Inventory.Add(Item);
end;
{ @end $619B28 }

{ @routine $619D2C SF_GetItemFromShip }
procedure SF_GetItemFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
  Index, WeaponIndex: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetItemFromShip');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := 0;
  if Ship = nil then Exit;
  if (av[2].ValueKind = value_uint32) and (av[2].AsDword > $10000) then
  begin
    Item := TItem(av[2].AsDword);
    Index := Ship.Inventory.IndexOf(Item);
    if Index < 0 then Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if (Index < 0) or (Index >= Ship.Inventory.Count) then Exit;
    Item := Ship.Inventory[Index];
    if (av[2].ValueKind = value_uint32) and (av[2].AsDword = 0) and (Item is THull) then
      AppendLogLineThreadSafe('Warning, GetItemFromShip received 0 from dword-type variable and will remove hull from ship ' + Ship.GetFullName(' ') + ' (' + GetScriptContextDescription + ')');
  end;
  av[0].AsDword := Cardinal(Item);
  if Ship.GetHull = Item then
  begin
    Ship.GetHull.OwnerShip := nil;
    Ship.UnequipSlot(item_hull, 0);
  end
  else if (Item is TEquipment) and ((Item as TEquipment).EquippedFlag <> 0) then
  begin
    if Item.ItemType in UtilityEquipmentTypes then Ship.UnequipSlot(Item.ItemType, 0);
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
{ @end $619D2C }

{ @routine $61A08C SF_GetArtFromShip }
procedure SF_GetArtFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TEquipment;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetArtFromShip');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := 0;
  if Ship = nil then Exit;
  if (av[2].ValueKind = value_uint32) and (av[2].AsDword > $10000) then
  begin
    Item := TEquipment(av[2].AsDword);
    Index := Ship.Artefacts.IndexOf(Item);
    if Index < 0 then Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if (Index < 0) or (Index >= Ship.Artefacts.Count) then Exit;
    Item := Ship.Artefacts[Index];
  end;
  Item.Unequip;
  av[0].AsDword := Cardinal(Item);
  Ship.Artefacts.Delete(Index);
end;
{ @end $61A08C }

{ @routine $61A190 SF_ArrangeItems }
procedure SF_ArrangeItems(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ArrangeItems');
  Ship := TShip(av[1].AsDword);
  Ship.AutoEquipInventory;
  Ship.AutoEquipArtefacts;
  Ship.DropCargoUntilNotOverloaded;
  Ship.RefreshAssignedItemSlots;
end;
{ @end $61A190 }

{ @routine $61A218 SF_AddItemToPlanet }
procedure SF_AddItemToPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Item: TItem;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddItemToPlanet');
  Planet := TPlanet(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  av[0].AsInteger := 0;
  if (Planet <> nil) and (Item <> nil) and Planet.AddSurfaceLootEntry(Item) then
  begin
    Planet.NormalizeSurfaceLootEntries;
    av[0].AsInteger := 1;
  end;
end;
{ @end $61A218 }

{ @routine $61A2C4 SF_GetItemFromPlanet }
procedure SF_GetItemFromPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Entry: PPlanetSurfaceLootEntry;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetItemFromPlanet');
  Planet := TPlanet(av[1].AsDword);
  Index := av[2].AsInteger;
  av[0].AsDword := 0;
  if (Planet <> nil) and (Planet.SurfaceLootEntries <> nil) then
    if (Index >= 0) and (Index < Planet.SurfaceLootEntries.Count) then
    begin
      Entry := Planet.SurfaceLootEntries[Index];
      av[0].AsDword := Cardinal(Entry.Item);
      Planet.SurfaceLootEntries.Delete(Index);
      Entry.Item := nil;
      Dispose(Entry);
    end;
end;
{ @end $61A2C4 }

{ @routine $61A3A4 SF_AddItemToShop }
procedure SF_AddItemToShop(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Item: TItem;
  Refresh: Boolean;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddItemToShop');
  Shop := TObject(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  av[0].AsInteger := 0;
  Refresh := (TemporaryShopSlots <> nil) and ((TemporaryShopPlanet = Shop) or (TemporaryShopStation = Shop));
  if Item = nil then Exit;
  if Shop is TPlanet then
  begin
    if Refresh then RestoreTemporaryShopStock;
    (Shop as TPlanet).EquipmentShop.Add(Item);
    av[0].AsInteger := 1;
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
    av[0].AsInteger := 1;
    if Refresh then
    begin
      BuildTemporaryShopSlotGrid;
      EquipmentShopScreen.ClearGoodsControls;
      EquipmentShopScreen.BuildGoodsControls;
      EquipmentShopScreen.UpdateScrollButtons;
    end;
  end;
end;
{ @end $61A3A4 }

{ @routine $61A53C SF_GetItemFromShop }
procedure SF_GetItemFromShop(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Index: Integer;
  Refresh: Boolean;
  Items: TList;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetItemFromShop');
  Shop := TObject(av[1].AsDword);
  av[0].AsDword := 0;
  if Shop = nil then Exit;
  Refresh := (TemporaryShopSlots <> nil) and ((TemporaryShopPlanet = Shop) or (TemporaryShopStation = Shop));
  if Refresh then RestoreTemporaryShopStock;
  if Shop is TPlanet then Items := TPlanet(Shop).EquipmentShop
  else if Shop is TRuins then Items := TRuins(Shop).EquipmentShop
  else Exit;
  if (av[2].ValueKind = value_uint32) and (av[2].AsDword > $10000) then
  begin
    Index := Items.IndexOf(TItem(av[2].AsDword));
    if Index >= 0 then
    begin
      av[0].AsDword := av[2].AsDword;
      Items.Delete(Index);
    end;
  end
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Items.Count) then
    begin
      av[0].AsDword := Cardinal(Items[Index]);
      Items.Delete(Index);
    end;
  end;
  if not Refresh then Exit;
  BuildTemporaryShopSlotGrid;
  EquipmentShopScreen.ClearGoodsControls;
  EquipmentShopScreen.BuildGoodsControls;
  EquipmentShopScreen.UpdateScrollButtons;
end;
{ @end $61A53C }

{ @routine $61A6DC SF_AddItemToStorage }
procedure SF_AddItemToStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Location: TObject;
  Item: TItem;
  Entry: PStorageEntry;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddItemToStorage');
  Location := TObject(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  if Item is TGoods then
    for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
    begin
      Entry := GetPlayer.StorageEntries[Index];
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
      if Entry.LocationOwner <> Location then Continue;
      if not (Entry.Item is TCountableItem) then Continue;
      with Entry.Item as TCountableItem do
      begin
        if not CanMerge(Item) then Continue;
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
{ @end $61A6DC }

{ @routine $61A8C0 SF_GetItemFromStorage }
procedure SF_GetItemFromStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Entry: PStorageEntry;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetItemFromStorage');
  Index := av[1].AsInteger;
  av[0].AsDword := 0;
  if (Index < 0) or (Index >= GetPlayer.StorageEntries.Count) then Exit;
  Entry := GetPlayer.StorageEntries[Index];
  GetPlayer.StorageEntries.Delete(Index);
  GetPlayer.RefreshStorageBubbles;
  av[0].AsDword := Cardinal(Entry.Item);
  Dispose(Entry);
end;
{ @end $61A8C0 }

{ @routine $61A994 SF_FindItemInStorage }
procedure SF_FindItemInStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Item: TItem;
  Entry: PStorageEntry;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindItemInStorage');
  Item := TItem(av[1].AsDword);
  av[0].AsInteger := -1;
  for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
  begin
    Entry := GetPlayer.StorageEntries[Index];
    if Entry.Item <> Item then Continue;
    av[0].AsInteger := Index;
    Break;
  end;
end;
{ @end $61A994 }

{ @routine $61AA58 SF_PutItemInVault }
procedure SF_PutItemInVault(av: array of TVarEC; code: TCodeEC);
var
  Item: TObject;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PutItemInVault');
  if av[2].AsDword = 0 then
  begin
    Item := Galaxy.GetStoredItem(av[1].AsString, True);
    if Item <> nil then Item.Free;
  end
  else Galaxy.StoreItem(av[1].AsString, TObject(av[2].AsDword));
end;
{ @end $61AA58 }

{ @routine $61AB48 SF_GetItemFromVault }
procedure SF_GetItemFromVault(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetItemFromVault');
  av[0].AsDword := Cardinal(Galaxy.GetStoredItem(av[1].AsString, (High(av) < 2) or (av[2].AsInteger <> 0)));
end;
{ @end $61AB48 }

{ @routine $61AC18 SF_DropItemInSystem }
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
  Star := TStar(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item else Item := TItem(Obj);
  Position.X := av[3].AsInteger;
  Position.Y := av[4].AsInteger;
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
    Destination.X := av[5].AsFloat;
    Destination.Y := av[6].AsFloat;
    av[0].AsInteger := 0;
    if (Star <> nil) and (Item <> nil) then
    begin
      Item.Position := Position;
      Entry := AllocEC(SizeOf(TMovingDropItemEntry));
      Entry.Payload := Item;
      Entry.Destination := Destination;
      Entry.SourceShipId := 0;
      Entry.InsertedIntoStar := False;
      Entry.DeployTranclucator := 0;
      av[0].AsInteger := Star.MovingDropItems.Add(Entry);
    end;
  end;
end;
{ @end $61AC18 }

{ @routine $61ADCC SF_StopMovingItem }
procedure SF_StopMovingItem(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Obj: TObject;
  Item: TItem;
  Entry: PMovingDropItemEntry;
  Index, StepIndex: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StopMovingItem');
  Star := TStar(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item else Item := TItem(Obj);
  av[0].AsInteger := 0;
  for Index := 0 to Star.MovingDropItems.Count - 1 do
  begin
    Entry := Star.MovingDropItems[Index];
    if Entry.Payload <> Item then Continue;
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
    av[0].AsInteger := 1;
    Break;
  end;
end;
{ @end $61ADCC }

{ @routine $61AF30 SF_StarItems }
procedure SF_StarItems(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarItems');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    if High(av) = 1 then av[0].AsInteger := Star.Items.Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Star.Items.Count) then av[0].AsDword := Cardinal(Star.Items[Index])
      else av[0].AsDword := 0;
    end;
  end
  else av[0].AsInteger := 0;
end;
{ @end $61AF30 }

{ @routine $61AFF4 SF_GetItemFromStar }
procedure SF_GetItemFromStar(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetItemFromStar');
  Star := TStar(av[1].AsDword);
  av[0].AsDword := 0;
  if Star = nil then Exit;
  if (av[2].ValueKind = value_uint32) and (av[2].AsDword > $10000) then
  begin
    Item := TItem(av[2].AsDword);
    Index := Star.Items.IndexOf(Item);
    if Index < 0 then Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if (Index < 0) or (Index >= Star.Items.Count) then Exit;
    Item := Star.Items[Index];
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
  av[0].AsDword := Cardinal(Item);
end;
{ @end $61AFF4 }

{ @routine $61B140 SF_PlanetItems }
procedure SF_PlanetItems(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetItems');
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    if Planet.SurfaceLootEntries <> nil then Count := Planet.SurfaceLootEntries.Count else Count := 0;
    if High(av) = 1 then av[0].AsInteger := Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Count) then av[0].AsDword := Cardinal(PPlanetSurfaceLootEntry(Planet.SurfaceLootEntries[Index]).Item)
      else av[0].AsDword := 0;
    end;
  end
  else av[0].AsDword := 0;
end;
{ @end $61B140 }

{ @routine $61B21C SF_StorageItems }
procedure SF_StorageItems(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then av[0].AsInteger := GetPlayer.StorageEntries.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < GetPlayer.StorageEntries.Count) then av[0].AsDword := Cardinal(PStorageEntry(GetPlayer.StorageEntries[Index]).Item)
    else av[0].AsDword := 0;
  end;
end;
{ @end $61B21C }

{ @routine $61B2A0 SF_StorageItemLocation }
procedure SF_StorageItemLocation(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StorageItemLocation');
  Index := av[1].AsInteger;
  av[0].AsDword := 0;
  if (Index >= 0) and (Index < GetPlayer.StorageEntries.Count) then av[0].AsDword := Cardinal(PStorageEntry(GetPlayer.StorageEntries[Index]).LocationOwner);
end;
{ @end $61B2A0 }

{ @routine $61B34C SF_ShopItems }
procedure SF_ShopItems(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Wanted, Index, Count: Integer;
  Items: TList;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShopItems');
  Shop := TObject(av[1].AsDword);
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
        if (TemporaryShopSlots[Index] <> nil) and (TShopSlot(TemporaryShopSlots[Index]).Item <> nil) then Inc(Count);
    end
    else
      for Index := 0 to Items.Count - 1 do
        if Items[Index] <> nil then Inc(Count);
    av[0].AsInteger := Count;
  end
  else
  begin
    Wanted := av[2].AsInteger;
    av[0].AsDword := 0;
    if (TemporaryShopSlots <> nil) and ((GetPlayer.CurrentPlanet = Shop) or (GetPlayer.DockedTo = Shop)) then
    begin
      Count := -1;
      for Index := 0 to TemporaryShopSlots.Count - 1 do
        if (TemporaryShopSlots[Index] <> nil) and (TShopSlot(TemporaryShopSlots[Index]).Item <> nil) then
          begin
            Inc(Count);
            if Count = Wanted then
            begin
              av[0].AsDword := Cardinal(TShopSlot(TemporaryShopSlots[Index]).Item);
              Break;
            end;
          end;
    end
    else if (Wanted >= 0) and (Wanted < Items.Count) then av[0].AsDword := Cardinal(Items[Wanted]);
  end;
end;
{ @end $61B34C }

{ @routine $61B5DC SF_AddDialogOverride }
procedure SF_AddDialogOverride(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogOverride;
  DialogName: WideString;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script AddDialogOverride');
  DialogName := av[1].AsString;
  if CountDelimitedPartsW(DialogName, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(DialogName, 0, ':'));
    if Index < 0 then Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then Exit;
    New(Entry);
    Entry.Script := Galaxy.Scripts[Index];
    Entry.DialogName := ExtractDelimitedPartW(DialogName, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := DialogName;
  end;
  Entry.Priority := av[2].AsInteger;
  if High(av) > 2 then Entry.AnswerData := av[3].AsDword else Entry.AnswerData := 0;
  if ScriptDialogOverrides = nil then ScriptDialogOverrides := TObjectList.Create;
  ScriptDialogOverrides.Add(Entry);
end;
{ @end $61B5DC }

{ @routine $61B7AC SF_AddDialogInject }
procedure SF_AddDialogInject(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogInjection;
  DialogName: WideString;
  Index: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script AddDialogInject');
  DialogName := av[1].AsString;
  if CountDelimitedPartsW(DialogName, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(DialogName, 0, ':'));
    if Index < 0 then Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then Exit;
    New(Entry);
    Entry.Script := Galaxy.Scripts[Index];
    Entry.DialogName := ExtractDelimitedPartW(DialogName, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := DialogName;
  end;
  Entry.Text := av[2].AsString;
  Entry.Answer := av[3].AsString;
  Entry.Priority := av[4].AsInteger;
  if High(av) > 4 then Entry.ReplaceGreeting := av[5].AsInteger <> 0 else Entry.ReplaceGreeting := False;
  if High(av) > 5 then Entry.AnswerData := av[6].AsDword else Entry.AnswerData := 0;
  if High(av) > 6 then
  begin
    Entry.ActionCode := av[7].AsString;
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
{ @end $61B7AC }

{ @routine $61BA04 SF_InjectAnswer }
procedure SF_InjectAnswer(av: array of TVarEC; code: TCodeEC);
var
  Text, Mode: WideString;
  Count, Index: Integer;
  Entry: PScriptDialogInjection;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script InjectAnswer');
  Text := av[1].AsString;
  if CountDelimitedPartsW(Text, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(Text, 0, ':'));
    if Index < 0 then Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then Exit;
    New(Entry);
    Entry.Script := Galaxy.Scripts[Index];
    Entry.DialogName := ExtractDelimitedPartW(Text, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := Text;
  end;
  Entry.Text := '';
  Entry.Answer := av[2].AsString;
  Entry.Priority := 0;
  Entry.AnswerData := av[3].AsDword;
  Entry.ReplaceGreeting := False;
  if High(av) > 3 then
  begin
    Entry.ActionCode := av[4].AsString;
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
{ @end $61BA04 }

{ @routine $61BE50 SF_AddDialogBlock }
procedure SF_AddDialogBlock(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogBlock;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AddDialogBlock');
  if ScriptDialogBlocks = nil then ScriptDialogBlocks := TObjectList.Create;
  for I := 0 to ScriptDialogBlocks.Count - 1 do
  begin
    Entry := ScriptDialogBlocks[I];
    if (Entry.Script = CurrentScript) and (Entry.Text = av[1].AsString) then
    begin
      if High(av) > 1 then Entry.Mode := av[2].AsInteger else Entry.Mode := 2;
      Exit;
    end;
  end;
  New(Entry);
  Entry.Text := av[1].AsString;
  Entry.Script := CurrentScript;
  if High(av) > 1 then Entry.Mode := av[2].AsInteger else Entry.Mode := 2;
  ScriptDialogBlocks.Add(Entry);
end;
{ @end $61BE50 }

{ @routine $61BFD8 SF_GotoGov }
procedure SF_GotoGov(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.PendingDockDialogue;
  if High(av) >= 1 then GetPlayer.PendingDockDialogue := av[1].AsInteger;
end;
{ @end $61BFD8 }

{ @routine $61C028 SF_GetShipPlanet }
procedure SF_GetShipPlanet(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipPlanet');
  Ship := TShip(av[1].AsDword);
  if GetPlayer.RuinsProxy = Ship then av[0].AsDword := Cardinal(GetPlayer.RuinsSavedPlanet)
  else av[0].AsDword := Cardinal(Ship.CurrentPlanet);
end;
{ @end $61C028 }

{ @routine $61C0BC SF_GetShipHomePlanet }
procedure SF_GetShipHomePlanet(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipHomePlanet');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := Cardinal(Ship.HomePlanet);
end;
{ @end $61C0BC }

{ @routine $61C134 SF_GetShipRuins }
procedure SF_GetShipRuins(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipRuins');
  Ship := TShip(av[1].AsDword);
  if GetPlayer.RuinsProxy = Ship then av[0].AsDword := Cardinal(GetPlayer.RuinsSavedDockedTo)
  else av[0].AsDword := Cardinal(Ship.DockedTo);
end;
{ @end $61C134 }

{ @routine $61C1C8 SF_GetTalkShip }
procedure SF_GetTalkShip(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := Cardinal(TalkShip);
end;
{ @end $61C1C8 }

{ @routine $61C1F8 SF_TalkByAI }
procedure SF_TalkByAI(av: array of TVarEC; code: TCodeEC);
begin
  if TalkScripted then av[0].AsInteger := 1 else av[0].AsInteger := 0;
end;
{ @end $61C1F8 }

{ @routine $61C238 SF_GetTalkType }
procedure SF_GetTalkType(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Ord(TalkType);
end;
{ @end $61C238 }

{ @routine $61C268 SF_ScriptRun }
procedure SF_ScriptRun(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Planet: TPlanet;
  Name: WideString;
  I: Integer;
  Script: TScript;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ScriptRun');
  Star := TStar(av[1].AsDword);
  Planet := TPlanet(av[2].AsDword);
  Name := av[3].AsString;
  av[0].AsInteger := 0;
  for I := 0 to Galaxy.Scripts.Count - 1 do
  begin
    Script := Galaxy.Scripts[I];
    if Script.ScriptFileName = Name then
    begin
      if Script.Ships.Count > 0 then Exit;
      if TryRestartScript(Script, Star, Planet) then av[0].AsInteger := 1;
      Exit;
    end;
  end;
  if TryStartScriptByName(Star, Planet, Name) then av[0].AsInteger := 1;
end;
{ @end $61C268 }

{ @routine $61C520 SF_SFT }
procedure SF_SFT(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  // @nested $61C3BC LogArray
  procedure LogArray(Prefix: WideString; Value: TVarEC); // @addr 0x0061C3BC @note "Nested in SF_SFT; Value must resolve to an array."
  var
    I: Integer;
    Item: TVarEC;
    Path: WideString;
  begin
    for I := 0 to Value.AsArray.Count - 1 do
    begin
      Item := Value.AsArray[I];
      if Item.Name <> '' then Path := Prefix + '''' + Item.Name + ''''
      else Path := Prefix + IntToWideString(I);
      if Item.ValueKind <> value_array then AppendLogLineThreadSafe(AnsiString(Path + ']=' + Item.AsString))
      else LogArray(Path + ',', Item);
    end;
  end;
begin
  if High(av) < 1 then Exit;
  for I := 1 to High(av) do
    if av[I].ValueKind = value_array then LogArray(av[I].Name + '[', av[I])
    else AppendLogLineThreadSafe(AnsiString(av[I].AsString));
end;
{ @end $61C520 }

{ @routine $61C5E8 SF_StartTextQuest }
procedure SF_StartTextQuest(av: array of TVarEC; code: TCodeEC);
var
  Request: PQueuedTextQuest;
begin
  if High(av) = 0 then
  begin
    av[0].AsInteger := QueuedTextQuests.Count;
    Exit;
  end;

  New(Request);
  Request.Name := av[1].AsString;
  if High(av) > 1 then Request.SuccessCaption := av[2].AsString else Request.SuccessCaption := '';
  if High(av) > 2 then Request.FailureCaption := av[3].AsString else Request.FailureCaption := '';
  Request.Script := CurrentScript;
  QueuedTextQuests.Add(Request);
  if CurrentScript <> nil then CurrentScript.InitCode.LocalVar.NamedItems['GQuestStatus'].AsInteger := Ord(quest_status_queued);
  av[0].AsInteger := 1;
end;
{ @end $61C5E8 }

{ @routine $61C740 SF_CreateABShip }
procedure SF_CreateABShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TabShipAI;
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateABShip');
  if CurrentScript <> StagedArcadeShipScript then StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  Ship := TabShipAI.Create;
  Ship.SpawnGraphKey := av[1].AsString;
  Ship.RandomRewardsDisabled := True;
  if High(av) > 1 then Ship.Team := av[2].AsInteger else Ship.Team := 0;
  if High(av) > 2 then Ship.HealthScalePercent := av[3].AsInteger else Ship.HealthScalePercent := 100;
  if High(av) > 3 then Ship.DamageScalePercent := av[4].AsInteger else Ship.DamageScalePercent := 100;
  if High(av) > 4 then Ship.ScriptLabel := av[5].AsString else Ship.ScriptLabel := '';
  if High(av) > 5 then
  begin
    Obj := TObject(av[6].AsDword);
    if av[6].AsInteger = -1 then Ship.RandomRewardsDisabled := False
    else if Obj is TScriptItem then Ship.RewardObject := TScriptItem(Obj).Item
    else Ship.RewardObject := Obj;
  end
  else Ship.RewardObject := nil;
  StagedArcadeShips.Add(Ship);
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $61C740 }

{ @routine $61C920 SF_ConvertToABShip }
procedure SF_ConvertToABShip(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Source: TShip;
  Ship: TabShipAI;
  Weapon: TWeapon;
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ConvertToABShip');
  if CurrentScript <> StagedArcadeShipScript then StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  Source := TShip(av[1].AsDword);
  if Source = nil then Exit;
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
  for I := Low(Ship.Weapons) to High(Ship.Weapons) do
  begin
    Weapon := Source.FindEquippedItemInSlot(WeaponCategoryItemType, I) as TWeapon;
    if not Source.IsEquipmentUsable(Weapon) then Continue;
    if Weapon.ItemType <> item_custom_weapon then ab_Weapon_Initialize(@Ship.Weapons[I], Ord(Weapon.ItemType))
    else ab_Weapon_Initialize(@Ship.Weapons[I], Weapon.GetWeaponInfo.ArcadeWeaponType);
    Ship.Weapons[I].SlotData := Weapon.AssignedSlotData;
    Inc(Ship.WeaponCount);
  end;
  Ship.PrimaryWeapon := 0;
  if High(av) > 1 then Ship.Team := av[2].AsInteger else Ship.Team := 0;
  if High(av) > 2 then Ship.HealthScalePercent := av[3].AsInteger else Ship.HealthScalePercent := 100;
  if High(av) > 3 then Ship.DamageScalePercent := av[4].AsInteger else Ship.DamageScalePercent := 100;
  if High(av) > 4 then Ship.ScriptLabel := av[5].AsString else Ship.ScriptLabel := '';
  if High(av) > 5 then
  begin
    Obj := TObject(av[6].AsDword);
    if av[6].AsInteger = -1 then Ship.RandomRewardsDisabled := False
    else if Obj is TScriptItem then Ship.RewardObject := TScriptItem(Obj).Item
    else Ship.RewardObject := Obj;
  end
  else Ship.RewardObject := nil;
  StagedArcadeShips.Add(Ship);
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $61C920 }

{ @routine $61CC28 SF_ABShipModifiers }
procedure SF_ABShipModifiers(av: array of TVarEC; code: TCodeEC);
var
  Ship: TabShip;
  Value: PSingle;
  Name: WideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlayerABDamageMod');
  if TPlayer(av[1].AsDword) = GetPlayer then Ship := PlayerArcadeShip else Ship := TabShip(av[1].AsDword);
  if Ship = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Name := LowerCase(AnsiString(av[2].AsString));
  if Name = 'damage' then Value := @Ship.WeaponDamageScale
  else if Name = 'recharge' then Value := @Ship.AmmoRechargeScale
  else if Name = 'speed' then Value := @Ship.MovementScale
  else if Name = 'gravity' then Value := @Ship.GravityScale
  else if Name = 'regen' then Value := @Ship.RegenerationRate
  else if Name = 'fragility' then Value := @Ship.DamageTakenScale
  else if Name = 'luck' then Value := @Ship.LuckScale
  else Exit;
  av[0].AsInteger := Round(100 * Value^);
  if High(av) > 2 then Value^ := av[3].AsInteger * 0.01;
end;
{ @end $61CC28 }

{ @routine $61CEC0 SF_StartAB }
procedure SF_StartAB(av: array of TVarEC; code: TCodeEC);
var
  Request: PScriptABRequest;
begin
  if High(av) = 0 then
  begin
    av[0].AsInteger := QueuedArcadeBattles.Count;
    Exit;
  end;

  if CurrentScript <> StagedArcadeShipScript then StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  New(Request);
  Request.MapName := av[1].AsString;
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
    if av[2].ValueKind = value_int32 then Request.BackgroundId := av[2].AsInteger
    else if av[2].ValueKind = value_string then Request.BackgroundMapName := av[2].AsString;
  end;
  QueuedArcadeBattles.Add(Request);
  if CurrentScript <> nil then CurrentScript.InitCode.LocalVar.NamedItems['GABStatus'].AsInteger := 1;
  av[0].AsInteger := 1;
end;
{ @end $61CEC0 }

{ @routine $61D078 SF_StartRobots }
procedure SF_StartRobots(av: array of TVarEC; code: TCodeEC);
var
  Request: PScriptPBRequest;
begin
  if High(av) = 0 then
  begin
    av[0].AsInteger := QueuedPlanetaryBattles.Count;
    Exit;
  end;

  if High(av) < 5 then raise Exception.Create('Error.Script StartRobots');
  New(Request);
  Request.MapName := av[1].AsString;
  Request.StartText := av[2].AsString;
  Request.SuccessText := av[3].AsString;
  Request.FailureText := av[4].AsString;
  Request.PlaceText := av[5].AsString;
  if High(av) > 5 then Request.StartText := av[6].AsString + Request.StartText
  else Request.StartText := '621' + Request.StartText;
  Request.Script := CurrentScript;
  QueuedPlanetaryBattles.Add(Request);
  if CurrentScript <> nil then CurrentScript.InitCode.LocalVar.NamedItems['GRobotStatus'].AsInteger := 1;
end;
{ @end $61D078 }

{ @routine $61D254 SF_MarkRobotsMapAsUsed }
procedure SF_MarkRobotsMapAsUsed(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Name: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MarkRobotsMapAsUsed');
  Name := av[1].AsString;
  for I := 0 to High(RobotMapDefinitions) do
  begin
    if RobotMapDefinitions[I].Map <> Name then Continue;
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
      if av[2].AsInteger <> 0 then GetPlayer.LastPlanetBattleTurn := Galaxy.CurrentTurn;
  end;
  // Falls through after matches; the error is unconditional.
  raise Exception.Create(AnsiString('Error.Script MarkRobotsMapAsUsed map not found ' + Name));
end;
{ @end $61D254 }

{ @routine $61D4B0 SF_ShipOwner }
procedure SF_ShipOwner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  WasPirateClan, IsPirateClan: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOwner');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    av[0].AsInteger := Ord(Ship.OwnerId);
    if High(av) > 1 then
    begin
      WasPirateClan := (Ship.TypeId = ship_pirate) and (Ship.OwnerId = owner_pirate);
      Ship.OwnerId := TOwnerId(av[2].AsInteger);
      IsPirateClan := (Ship.TypeId = ship_pirate) and (Ship.OwnerId = owner_pirate);
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
  else av[0].AsInteger := -1;
end;
{ @end $61D4B0 }

{ @routine $61D5B0 SF_ShipPilotRace }
procedure SF_ShipPilotRace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipPilotRace');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    av[0].AsInteger := Ord(Ship.PilotRace);
    if High(av) > 1 then Ship.PilotRace := TOwnerId(av[2].AsInteger);
  end
  else av[0].AsInteger := -1;
end;
{ @end $61D5B0 }

{ @routine $61D650 SF_ShipSkill }
procedure SF_ShipSkill(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Skill, Value: Integer;
  Current: Boolean;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipSkill');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  Current := False;
  if av[2].ValueKind = value_string then
  begin
    if av[2].AsString = 'Accuracy' then Skill := 0
    else if av[2].AsString = 'AccuracyCur' then begin Skill := 0; Current := True; end
    else if av[2].AsString = 'Mobility' then Skill := 1
    else if av[2].AsString = 'MobilityCur' then begin Skill := 1; Current := True; end
    else if av[2].AsString = 'Technical' then Skill := 2
    else if av[2].AsString = 'TechnicalCur' then begin Skill := 2; Current := True; end
    else if av[2].AsString = 'Trader' then Skill := 3
    else if av[2].AsString = 'TraderCur' then begin Skill := 3; Current := True; end
    else if av[2].AsString = 'Charm' then Skill := 4
    else if av[2].AsString = 'CharmCur' then begin Skill := 4; Current := True; end
    else if av[2].AsString = 'Leadership' then Skill := 5
    else if av[2].AsString = 'LeadershipCur' then begin Skill := 5; Current := True; end
    else raise Exception.Create('Error.Script ShipSkill unknown query ' + av[2].AsString);
  end
  else
  begin
    Skill := av[2].AsInteger;
    if (Skill < 0) or (Skill > 5) then raise Exception.Create('Error.Script ShipSkill - invalid skill index');
  end;
  if Current then av[0].AsInteger := Ship.GetEffectiveSkillLevel(TPilotSkill(Skill))
  else av[0].AsInteger := Ship.BaseSkills[TPilotSkill(Skill)];
  if High(av) > 2 then
  begin
    Value := av[3].AsInteger;
    Ship.BaseSkills[TPilotSkill(Skill)] := Max(0, Min(6, Value));
  end;
end;
{ @end $61D650 }

{ @routine $61DB5C SF_ShipFace }
procedure SF_ShipFace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipFace');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if High(av) > 1 then
  begin
    if av[2].ValueKind = value_string then
    begin
      if av[2].AsString = 'Init' then
      begin
        if Ship.PortraitFaceId = -1 then Ship.GetCaptainPortraitResourceBase;
        av[0].AsInteger := Ship.PortraitFaceId;
      end
      else if av[2].AsString = 'New' then
      begin
        Ship.PortraitFaceId := -1;
        Ship.GetCaptainPortraitResourceBase;
        av[0].AsInteger := Ship.PortraitFaceId;
      end
      else if av[2].AsString = 'Path' then av[0].AsString := Ship.GetCaptainPortraitResourceBase
      else raise Exception.Create('Error.Script ShipFace unknown keyword - ' + av[2].AsString);
    end
    else
    begin
      av[0].AsInteger := Ship.PortraitFaceId;
      Ship.PortraitFaceId := av[2].AsInteger;
    end;
  end
  else av[0].AsInteger := Ship.PortraitFaceId;
end;
{ @end $61DB5C }

{ @routine $61DDD4 SF_ShipFreeExp }
procedure SF_ShipFreeExp(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipFreeExp');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  av[0].AsInteger := Ship.FreeExperience;
  if High(av) > 1 then Ship.FreeExperience := av[2].AsInteger;
end;
{ @end $61DDD4 }

{ @routine $61DE68 SF_GetShipExpByType }
procedure SF_GetShipExpByType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetShipExpByType');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if (High(av) = 1) or (GetPlayer <> Ship) then av[0].AsInteger := Ship.TotalExperience
  else
    case av[2].AsInteger of
      1: av[0].AsInteger := GetPlayer.ExperienceByDominators;
      2: av[0].AsInteger := GetPlayer.ExperienceByPirates;
      3: av[0].AsInteger := GetPlayer.ExperienceByNormals;
      4: av[0].AsInteger := GetPlayer.ExperienceByTraderCareer;
      5: av[0].AsInteger := GetPlayer.TotalExperience - GetPlayer.ExperienceByDominators - GetPlayer.ExperienceByPirates - GetPlayer.ExperienceByNormals - GetPlayer.ExperienceByTraderCareer;
    else av[0].AsInteger := Ship.TotalExperience;
    end;
end;
{ @end $61DE68 }

{ @routine $61DFD8 SF_CoordX }
procedure SF_CoordX(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Position: TPointF;
  Link: PConstellationStarLink;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CoordX');
  Obj := TObject(av[1].AsDword);
  av[0].AsInteger := 0;
  if Obj = nil then Exit;
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
  av[0].AsInteger := Round(Position.X);
  if High(av) <= 1 then Exit;
  Position.X := av[2].AsInteger;
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
    (Obj as TPlanet).Graphic.Pos := Position;
  end
  else if Obj is TStar then
  begin
    with TStar(Obj).Constellation.StarLinks do
      for Index := 0 to Count - 1 do
      begin
        Link := Items[Index];
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
{ @end $61DFD8 }

{ @routine $61E508 SF_CoordY }
procedure SF_CoordY(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Position: TPointF;
  Link: PConstellationStarLink;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CoordY');
  Obj := TObject(av[1].AsDword);
  av[0].AsInteger := 0;
  if Obj = nil then Exit;
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
  av[0].AsInteger := Round(Position.Y);
  if High(av) <= 1 then Exit;
  Position.Y := av[2].AsInteger;
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
    (Obj as TPlanet).Graphic.Pos := Position;
  end
  else if Obj is TStar then
  begin
    with TStar(Obj).Constellation.StarLinks do
      for Index := 0 to Count - 1 do
      begin
        Link := Items[Index];
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
{ @end $61E508 }

{ @routine $61EA38 SF_ShipSetCoords }
procedure SF_ShipSetCoords(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipSetCoords');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  Ship.Position.X := av[2].AsInteger;
  Ship.Position.Y := av[3].AsInteger;
  Ship.Graphic.SetPosition(Ship.Position);
end;
{ @end $61EA38 }

{ @routine $61EAD8 SF_ShipAngle }
procedure SF_ShipAngle(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipAngle');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  av[0].AsFloat := Ship.MovementDirection;
  if High(av) > 1 then
  begin
    Ship.MovementDirection := av[2].AsFloat;
    Ship.Graphic.SetAngle(HeadingDegreesToByte(Ship.MovementDirection));
  end;
end;
{ @end $61EAD8 }

{ @routine $61EB8C SF_ObjectType }
procedure SF_ObjectType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ObjectType');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TStar then av[0].AsInteger := 1
  else if Obj is THole then av[0].AsInteger := 2
  else if Obj is TPlanet then av[0].AsInteger := 3
  else if Obj is TRuins then av[0].AsInteger := 4
  else if Obj is TShip then av[0].AsInteger := 5
  else if Obj is TItem then av[0].AsInteger := 6
  else if Obj is TMissile then av[0].AsInteger := 7
  else if Obj is TAsteroid then av[0].AsInteger := 8;
end;
{ @end $61EB8C }

{ @routine $61ED00 SF_ShipInHyperSpace }
procedure SF_ShipInHyperSpace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInHyperSpace');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if (High(av) > 1) and (av[2].AsInteger <> 0) then
    while Ship.DockedTo <> nil do Ship := Ship.DockedTo;
  av[0].AsInteger := Ord(Ship.InHyperspace);
end;
{ @end $61ED00 }

{ @routine $61EDAC SF_ShipStatus }
procedure SF_ShipStatus(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
  Career: TRangerCareer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipStatus');
  Obj := TObject(av[1].AsDword);
  if Obj is TRanger then Ranger := TRanger(Obj)
  else raise Exception.Create('Error.Script ShipStatus - not Ranger');
  Career := TRangerCareer(av[2].AsInteger);
  av[0].AsInteger := Ranger.CareerStatus[Career];
  if High(av) > 2 then Ranger.CareerStatus[Career] := av[3].AsInteger;
end;
{ @end $61EDAC }

{ @routine $61EEA8 SF_BuyRanger }
procedure SF_BuyRanger(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyRanger');
  MoneyPercent := 100;
  if High(av) > 1 then MoneyPercent := av[2].AsInteger;
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  Ship := TShip(Planet.BuyRanger(MoneyPercent));
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $61EEA8 }

{ @routine $61EF3C SF_BuyWarrior }
procedure SF_BuyWarrior(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyWarrior');
  MoneyPercent := 100;
  if High(av) > 1 then MoneyPercent := av[2].AsInteger;
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  Ship := TShip(Planet.BuyWarrior(MoneyPercent));
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $61EF3C }

{ @routine $61EFD0 SF_BuyBigWarrior }
procedure SF_BuyBigWarrior(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyBigWarrior');
  MoneyPercent := 100;
  if High(av) > 1 then MoneyPercent := av[2].AsInteger;
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  Ship := TShip(Planet.BuyFlagship(MoneyPercent));
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $61EFD0 }

{ @routine $61F068 SF_BuyDomik }
procedure SF_BuyDomik(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyDomik');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  Ship := TShip(Planet.SpawnWeightedDominatorShip);
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $61F068 }

{ @routine $61F0E0 SF_BuyDomikExtremal }
procedure SF_BuyDomikExtremal(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  SavedSeries: TDominatorSeries;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyDomikExtremal');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  if High(av) = 1 then Ship := TShip(Planet.SpawnWeightedDominatorShip)
  else if High(av) = 2 then Ship := TShip(Planet.SpawnDominatorShip(TDominatorKind(av[2].AsInteger)))
  else
  begin
    SavedSeries := Planet.CurrentStar.DominatorSeries;
    Planet.CurrentStar.DominatorSeries := TDominatorSeries(av[3].AsInteger);
    Ship := TShip(Planet.SpawnDominatorShip(TDominatorKind(av[2].AsInteger)));
    Planet.CurrentStar.DominatorSeries := SavedSeries;
  end;
  av[0].AsDword := Cardinal(Ship);
end;
{ @end $61F0E0 }

{ @routine $61F1BC SF_BuyTranclucator }
procedure SF_BuyTranclucator(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  BasicEquipment: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BuyTrank');
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    BasicEquipment := True;
    if High(av) > 1 then BasicEquipment := av[2].AsInteger <> 0;
    Ship := TShip(Planet.SpawnTranclucator(BasicEquipment));
    av[0].AsDword := Cardinal(Ship);
  end;
end;
{ @end $61F1BC }

{ @routine $61F258 SF_TransferShip }
procedure SF_TransferShip(av: array of TVarEC; code: TCodeEC);
var
  Destination: TObject;
  OldStar, NewStar: TStar;
  Planet: TPlanet;
  Ship, Station: TShip;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script TransferShip');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  OldStar := Ship.CurrentStar;
  if OldStar <> nil then
  begin
    Destination := TObject(av[2].AsDword);
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
      Ship.Order := order_none;
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
{ @end $61F258 }

{ @routine $61F4C0 SF_OrderLock }
procedure SF_OrderLock(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OrderLock');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  av[0].AsInteger := Ship.AbsoluteScriptOrder;
  if High(av) > 1 then Ship.AbsoluteScriptOrder := av[2].AsInteger;
end;
{ @end $61F4C0 }

{ @routine $61F550 SF_OrderForsage }
procedure SF_OrderForsage(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OrderForsage');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := 0;
  if Ship = nil then Exit;
  if Ship.AfterburnerActive then av[0].AsInteger := 1;
  if High(av) <= 1 then Exit;
  if av[2].AsInteger <> 0 then Ship.AfterburnerActive := (Ship.GetSlotCount(slot_afterburner) > 0) and Ship.IsEquipmentUsable(Ship.GetEngine)
  else Ship.AfterburnerActive := False;
  Ship.RefreshDerivedStats(True);
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = map_mode_orders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    GetPlayer.BuildOrderMovementPath(FullPathNodeLimit);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;
{ @end $61F550 }

{ @routine $61F690 SF_OrderNone }
procedure SF_OrderNone(av: array of TVarEC; code: TCodeEC);
var
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OrderNone');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderNone(False);
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = map_mode_orders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;
{ @end $61F690 }

{ @routine $61F770 SF_OrderMove }
procedure SF_OrderMove(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  Destination: TPointF;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderMove');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  if High(av) > 2 then
  begin
    Absolute := False;
    if High(av) > 3 then Absolute := av[4].AsInteger <> 0;
    Destination.X := av[2].AsInteger;
    Destination.Y := av[3].AsInteger;
    Ship.OrderMove(Destination, Absolute);
  end
  else
  begin
    if (av[2].ValueKind = value_uint32) and (TObject(av[2].AsDword) is TScriptPlace) then
    begin
      Absolute := False;
      if High(av) > 2 then Absolute := av[3].AsInteger <> 0;
      Ship.OrderMove(TScriptPlace(av[2].AsDword).GetRandomPoint((Ship.Seed + Ship.CurrentStar.GenerationSeed) * Cardinal(Galaxy.CurrentTurn)), Absolute);
    end
    else raise Exception.Create('Error.Script OrderMove invalid place');
  end;
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = map_mode_orders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;
{ @end $61F770 }

{ @routine $61F968 SF_OrderTeleport }
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
  if High(av) > 4 then Absolute := av[5].AsInteger <> 0;
  Destination.X := av[3].AsInteger;
  Destination.Y := av[4].AsInteger;
  TransitionData := 10;
  if High(av) > 5 then TransitionData := av[6].AsInteger;
  if av[1].AsDword <> 0 then
    if av[2].AsDword <> 0 then
    begin
      Ship := TShip(av[1].AsDword);
      if Ship <> nil then
      begin
        SavedOrderLock := Ship.AbsoluteScriptOrder;
        Ship.AbsoluteScriptOrder := 0;
        Ship.OrderTeleport(TStar(av[2].AsDword), Destination, TransitionData, Absolute);
        Ship.AbsoluteScriptOrder := SavedOrderLock;
        if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
        if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = map_mode_orders) then
        begin
          StarMapScreen.ClearPathOverlay(True);
          StarMapScreen.BuildShipPathOverlay(Ship, False, '');
        end;
      end;
    end;
end;
{ @end $61F968 }

{ @routine $61FAE4 SF_OrderTakeOff }
procedure SF_OrderTakeOff(av: array of TVarEC; code: TCodeEC);
var
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OrderTakeOff');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderTakeoff;
  Ship.AbsoluteScriptOrder := SavedOrderLock;
end;
{ @end $61FAE4 }

{ @routine $61FB6C SF_OrderFollowShip }
procedure SF_OrderFollowShip(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  FollowMode: TFollowMode;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderFollowShip');
  Absolute := False;
  FollowMode := follow_close;
  if High(av) > 2 then FollowMode := TFollowMode(Byte(av[3].AsInteger));
  if High(av) > 3 then Absolute := av[4].AsInteger <> 0;
  if (av[1].AsDword <> 0) and (av[2].AsDword <> 0) then
    begin
      Ship := TShip(av[1].AsDword);
      if Ship <> nil then
      begin
        SavedOrderLock := Ship.AbsoluteScriptOrder;
        Ship.AbsoluteScriptOrder := 0;
        Ship.OrderFollowShip(TShip(av[2].AsDword), FollowMode, Absolute);
        Ship.AbsoluteScriptOrder := SavedOrderLock;
        if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = map_mode_orders) then
        begin
          StarMapScreen.ClearPathOverlay(True);
          StarMapScreen.BuildShipPathOverlay(Ship, False, '');
        end;
      end;
    end;
end;
{ @end $61FB6C }

{ @routine $61FCAC SF_OrderJumpHole }
procedure SF_OrderJumpHole(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  Ship: TShip;
  Hole: THole;
  SavedOrderLock: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script OrderJumpHole');
  Ship := TShip(av[1].AsDword);
  Hole := THole(av[2].AsDword);
  if (Ship <> nil) and (Hole <> nil) then
  begin
    Absolute := False;
    if High(av) > 2 then Absolute := av[3].AsInteger <> 0;
    SavedOrderLock := Ship.AbsoluteScriptOrder;
    Ship.AbsoluteScriptOrder := 0;
    Ship.OrderJumpHole(Hole, Absolute);
    Ship.AbsoluteScriptOrder := SavedOrderLock;
    if GetPlayer = Ship then PendingPlayerFollowTarget := nil;
    if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = map_mode_orders) then
    begin
      StarMapScreen.ClearPathOverlay(True);
      StarMapScreen.BuildShipPathOverlay(Ship, False, '');
    end;
  end;
end;
{ @end $61FCAC }

{ @routine $61FDD0 SF_RelationToRanger }
procedure SF_RelationToRanger(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
  Relation: Byte;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script RelationToRanger');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  Ranger := TRanger(av[2].AsDword);
  if Ranger <> nil then
  begin
    if Obj is TPlanet then
    begin
      av[0].AsInteger := Integer(TPlanet(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)]);
      if High(av) > 2 then
      begin
        if av[3].AsInteger < 0 then Relation := 0
        else if av[3].AsInteger > 100 then Relation := 100
        else Relation := av[3].AsInteger;
        TPlanet(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)] := Pointer(Relation);
      end;
    end
    else if Obj is TShip then
    begin
      if (TShip(Obj).RangerRelations <> nil) and (TShip(Obj).RangerRelations.Count > 0) then
        av[0].AsInteger := Integer(TShip(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)])
      else av[0].AsInteger := TShip(Obj).RelationToShip(Ranger);
      if (High(av) > 2) and (TShip(Obj).RangerRelations <> nil) and (TShip(Obj).RangerRelations.Count > 0) then
      begin
        if av[3].AsInteger < 0 then Relation := 0
        else if av[3].AsInteger > 100 then Relation := 100
        else Relation := av[3].AsInteger;
        TShip(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)] := Pointer(Relation);
      end;
    end;
  end;
end;
{ @end $61FDD0 }

{ @routine $61FFC8 SF_RelationToShip }
procedure SF_RelationToShip(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script RelationToShip');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  Ship := TShip(av[2].AsDword);
  if Ship <> nil then
  begin
    if Obj is TPlanet then av[0].AsInteger := TPlanet(Obj).RelationToShip(Ship)
    else if Obj is TShip then av[0].AsInteger := TShip(Obj).RelationToShip(Ship);
  end;
end;
{ @end $61FFC8 }

{ @routine $620098 SF_StarOwner }
procedure SF_StarOwner(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarOwner');
  Star := TStar(av[1].AsDword);
  av[0].AsInteger := 0;
  if Star = nil then Exit;
  av[0].AsInteger := Ord(Star.ControlFaction);
  if High(av) > 1 then Star.ControlFaction := TStarFaction(av[2].AsInteger);
end;
{ @end $620098 }

{ @routine $62012C SF_StarBattle }
procedure SF_StarBattle(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarBattle');
  Star := TStar(av[1].AsDword);
  av[0].AsInteger := 0;
  if Star = nil then Exit;
  av[0].AsInteger := Star.Battle;
end;
{ @end $62012C }

{ @routine $6201B0 SF_StarSeries }
procedure SF_StarSeries(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarSeries');
  Star := TStar(av[1].AsDword);
  av[0].AsInteger := 0;
  if Star = nil then Exit;
  av[0].AsInteger := Ord(Star.DominatorSeries);
  if High(av) > 1 then Star.DominatorSeries := TDominatorSeries(av[2].AsInteger);
end;
{ @end $6201B0 }

{ @routine $620244 SF_StarHoles }
procedure SF_StarHoles(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Hole: THole;
  I, Wanted, Found: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarSeries');
  Star := TStar(av[1].AsDword);
  Wanted := -1;
  Found := -1;
  av[0].AsDword := 0;
  if High(av) > 1 then Wanted := av[2].AsInteger;
  for I := 0 to Galaxy.Holes.Count - 1 do
  begin
    Hole := Galaxy.Holes[I];
    if (Hole.Star1 = Star) or (Hole.Star2 = Star) then
    begin
      Inc(Found);
      if Found = Wanted then
      begin
        av[0].AsDword := Cardinal(Hole);
        Exit;
      end;
    end;
  end;
  if High(av) = 1 then av[0].AsInteger := Found + 1;
end;
{ @end $620244 }

{ @routine $620348 SF_StarNearbyStars }
procedure SF_StarNearbyStars(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarNearbyStars');
  av[0].AsDword := 0;
  Star := TStar(av[1].AsDword);
  if Star = nil then Exit;
  Index := av[2].AsInteger;
  if (Index >= 0) and (Index < Galaxy.Stars.Count) then av[0].AsDword := Cardinal(Star.StarDistances[Index].Star);
end;
{ @end $620348 }

{ @routine $6203F0 SF_StarNearbyStarsDist }
procedure SF_StarNearbyStarsDist(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarNearbyStarsDist');
  av[0].AsDword := 0;
  Star := TStar(av[1].AsDword);
  if Star = nil then Exit;
  Index := av[2].AsInteger;
  if (Index >= 0) and (Index < Galaxy.Stars.Count) then av[0].AsInteger := Star.StarDistances[Index].Distance;
end;
{ @end $6203F0 }

{ @routine $62049C SF_StarSetGraph }
procedure SF_StarSetGraph(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarSetGraph');
  Star := TStar(av[1].AsDword);
  ReleaseSpaceObject(Star.Graphic);
  RetainSpaceObject(Star.Graphic, CreateSpaceObjectByName('Star', av[2].AsString, Point(0, 0)));
  Star.SystemProcessName := 'Process.Normal';
  Star.Graphic.SetPosition(MakePointF(0, 0));
end;
{ @end $62049C }

{ @routine $6205CC SF_CreatePlanet }
procedure SF_CreatePlanet(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Planet: TPlanet;
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreatePlanet');
  Star := TStar(av[1].AsDword);
  Planet := TPlanet.Create;
  Planet.InitGeneratedUninhabited(Star);
  Galaxy.Planets.Add(Planet);
  av[0].AsDword := Cardinal(Planet);
  if High(av) < 2 then Star.Planets.Add(Planet)
  else
  begin
    Planet.Orbit.Radius := av[2].AsInteger;
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
{ @end $6205CC }

{ @routine $6206F0 SF_PlanetSetGraph }
procedure SF_PlanetSetGraph(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  RotationInterval: Word;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlanetSetGraph');
  Planet := TPlanet(av[1].AsDword);
  if av[2].ValueKind = value_string then
  begin
    Planet.GraphName := av[2].AsString;
    RotationInterval := Planet.Graphic.RotationTimerInterval;
    ReleaseSpaceObject(TObjectSE(Planet.Graphic));
    RetainSpaceObject(TObjectSE(Planet.Graphic), CreateSpaceObjectByName('Planet', Planet.GraphName, Point(0, 0)));
    Planet.Graphic.SetRotationTimerInterval(RotationInterval);
  end
  else
  begin
    Planet.SpriteTemplateIndex := av[2].AsInteger;
    ReleaseSpaceObject(TObjectSE(Planet.Graphic));
    RetainSpaceObject(TObjectSE(Planet.Graphic), TPlanetSE.Create);
    PlanetSpaceTemplates[Planet.SpriteTemplateIndex].SpaceObject.CopyTo(Planet.Graphic);
    Planet.GraphName := Planet.Graphic.GraphKey;
  end;
  Planet.Graphic.SetPosition(PolarToPoint(Planet.Orbit));
  Planet.GraphicRadius := Planet.Graphic.Radius;
end;
{ @end $6206F0 }

{ @routine $6208A4 SF_PlanetGetGraph }
procedure SF_PlanetGetGraph(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetGetGraph');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsString := Planet.GraphName;
end;
{ @end $6208A4 }

{ @routine $62091C SF_PlanetPopulation }
procedure SF_PlanetPopulation(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetPopulation');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  av[0].AsInteger := Planet.Population;
  if High(av) > 1 then Planet.Population := av[2].AsInteger;
end;
{ @end $62091C }

{ @routine $6209B0 SF_PlanetOwner }
procedure SF_PlanetOwner(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetOwner');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  av[0].AsInteger := Ord(Planet.OwnerId);
  if High(av) > 1 then
  begin
    Planet.OwnerId := TOwnerId(av[2].AsInteger);
    Planet.UpdateOwnerFlags;
  end;
end;
{ @end $6209B0 }

{ @routine $620A48 SF_PlanetRace }
procedure SF_PlanetRace(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetRace');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  av[0].AsInteger := Ord(Planet.RaceId);
  if High(av) > 1 then Planet.RaceId := TOwnerId(av[2].AsInteger);
end;
{ @end $620A48 }

{ @routine $620AD4 SF_PlanetGov }
procedure SF_PlanetGov(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetGov');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  av[0].AsInteger := Ord(Planet.Government);
  if High(av) > 1 then Planet.Government := TPlanetGovernment(av[2].AsInteger);
end;
{ @end $620AD4 }

{ @routine $620B60 SF_PlanetEco }
procedure SF_PlanetEco(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetEco');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then Exit;
  av[0].AsInteger := Ord(Planet.Economy);
  if High(av) > 1 then Planet.Economy := TPlanetEconomy(av[2].AsInteger);
end;
{ @end $620B60 }

{ @routine $620BEC SF_PlanetTerrain }
procedure SF_PlanetTerrain(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Terrain: TPlanetTerrainKind;
  Value, I: Integer;
  Entry: PPlanetSurfaceLootEntry;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlanetTerrain');
  Planet := TPlanet(av[1].AsDword);
  Terrain := TPlanetTerrainKind(av[2].AsInteger);
  case Terrain of
    terrain_water: av[0].AsInteger := Planet.WaterTiles;
    terrain_land: av[0].AsInteger := Planet.LandTiles;
    terrain_hills: av[0].AsInteger := Planet.HillTiles;
  else raise Exception.Create('Error.Script PlanetTerrain ttype');
  end;
  if High(av) <= 2 then Exit;
  Value := av[3].AsInteger;
  case Terrain of
    terrain_water: Planet.WaterTiles := Value;
    terrain_land: Planet.LandTiles := Value;
    terrain_hills: Planet.HillTiles := Value;
  end;
  if Planet.SurfaceLootEntries <> nil then
    for I := 0 to Planet.SurfaceLootEntries.Count - 1 do
    begin
      Entry := Planet.SurfaceLootEntries[I];
      if Entry.TerrainKind = Terrain then Entry.SurfaceTileIndex := Min(Entry.SurfaceTileIndex, Value);
    end;
end;
{ @end $620BEC }

{ @routine $620D68 SF_PlanetTerrainExplored }
procedure SF_PlanetTerrainExplored(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Terrain: TPlanetTerrainKind;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlanetTerrainExplored');
  Planet := TPlanet(av[1].AsDword);
  Terrain := TPlanetTerrainKind(av[2].AsInteger);
  case Terrain of
    terrain_water: av[0].AsInteger := Planet.WaterExplored;
    terrain_land: av[0].AsInteger := Planet.LandExplored;
    terrain_hills: av[0].AsInteger := Planet.HillExplored;
  else raise Exception.Create('Error.Script PlanetTerrainExplored ttype');
  end;
  if High(av) <= 2 then Exit;
  case Terrain of
    terrain_water: Planet.WaterExplored := av[3].AsInteger;
    terrain_land: Planet.LandExplored := av[3].AsInteger;
    terrain_hills: Planet.HillExplored := av[3].AsInteger;
  end;
end;
{ @end $620D68 }

{ @routine $620EB8 SF_PlanetOrbitRadius }
procedure SF_PlanetOrbitRadius(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetOrbitRadius');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Round(Planet.Orbit.Radius);
  if High(av) > 1 then Planet.Orbit.Radius := av[2].AsInteger;
end;
{ @end $620EB8 }

{ @routine $620F54 SF_PlanetOrbitalVelocity }
procedure SF_PlanetOrbitalVelocity(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetOrbitalVelocity');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Round(10 * Planet.OrbitalVelocity);
  if High(av) > 1 then Planet.OrbitalVelocity := av[2].AsInteger * 0.1;
end;
{ @end $620F54 }

{ @routine $621014 SF_PlanetSize }
procedure SF_PlanetSize(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetSize');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Planet.Radius;
  if High(av) > 1 then Planet.Radius := av[2].AsInteger;
end;
{ @end $621014 }

{ @routine $62109C SF_PlanetCurInvention }
procedure SF_PlanetCurInvention(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetCurInvention');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Ord(Planet.CurrentInvention);
  if High(av) > 1 then Planet.CurrentInvention := TResearchTrack(av[2].AsInteger);
end;
{ @end $62109C }

{ @routine $62112C SF_PlanetCurInventionPoints }
procedure SF_PlanetCurInventionPoints(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetCurInventionPoints');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsFloat := Planet.CurrentInventionPoints;
  if High(av) > 1 then Planet.CurrentInventionPoints := av[2].AsFloat;
end;
{ @end $62112C }

{ @routine $6211CC SF_PlanetInventionLevel }
procedure SF_PlanetInventionLevel(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index: TResearchTrack;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script PlanetInventionLevel');
  Planet := TPlanet(av[1].AsDword);
  Index := TResearchTrack(av[2].AsInteger);
  av[0].AsInteger := Planet.InventionLevels[Index];
  if High(av) > 2 then Planet.InventionLevels[Index] := av[3].AsInteger;
end;
{ @end $6211CC }

{ @routine $621274 SF_PlanetBoostInventions }
procedure SF_PlanetBoostInventions(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Count, I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetBoostInventions');
  Planet := TPlanet(av[1].AsDword);
  if High(av) > 1 then Count := av[2].AsInteger else Count := 1;
  for I := 1 to Count do Planet.AdvanceInventionProgress;
end;
{ @end $621274 }

{ @routine $621310 SF_PlanetWarriors }
procedure SF_PlanetWarriors(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetWarriors');
  Planet := TPlanet(av[1].AsDword);
  if High(av) = 1 then av[0].AsInteger := Planet.Warriors.Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Planet.Warriors.Count) then av[0].AsDword := Cardinal(Planet.Warriors[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $621310 }

{ @routine $6213D0 SF_GalaxySectors }
procedure SF_GalaxySectors(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then av[0].AsInteger := Galaxy.Constellations.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < Galaxy.Constellations.Count) then av[0].AsDword := Cardinal(Galaxy.Constellations[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $6213D0 }

{ @routine $621458 SF_GalaxyTechLevel }
procedure SF_GalaxyTechLevel(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.TechLevel;
end;
{ @end $621458 }

{ @routine $62148C SF_GalaxyDominatorResearchPercent }
procedure SF_GalaxyDominatorResearchPercent(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    av[0].AsFloat := (Galaxy.DominatorResearch[series_blazer].Progress + Galaxy.DominatorResearch[series_keller].Progress + Galaxy.DominatorResearch[series_terron].Progress) / 3
  else
  begin
    av[0].AsFloat := Galaxy.DominatorResearch[TDominatorSeries(av[1].AsInteger)].Progress;
    if High(av) > 1 then Galaxy.DominatorResearch[TDominatorSeries(av[1].AsInteger)].Progress := av[2].AsFloat;
  end;
end;
{ @end $62148C }

{ @routine $621550 SF_GalaxyDominatorResearchMaterial }
procedure SF_GalaxyDominatorResearchMaterial(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyDominatorResearchMaterial');
  av[0].AsInteger := Galaxy.DominatorResearch[TDominatorSeries(av[1].AsInteger)].Material;
  if High(av) > 1 then Galaxy.DominatorResearch[TDominatorSeries(av[1].AsInteger)].Material := av[2].AsInteger;
end;
{ @end $621550 }

{ @routine $621618 SF_GalaxyDiffLevels }
procedure SF_GalaxyDiffLevels(av: array of TVarEC; code: TCodeEC);
var
  I, Total: Integer;
begin
  if High(av) > 0 then av[0].AsInteger := (Galaxy.DifficultyLevels[TGalaxyDifficultyIndex(av[1].AsInteger)] + 1) * 50
  else
  begin
    Total := 0;
    for I := 0 to 7 do Inc(Total, (Galaxy.DifficultyLevels[Byte(I)] + 1) * 50);
    av[0].AsInteger := Round(Total * 0.125);
  end;
end;
{ @end $621618 }

{ @routine $6216A0 SF_SectorVisible }
procedure SF_SectorVisible(av: array of TVarEC; code: TCodeEC);
var
  Sector: TConstellation;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SectorVisible');
  Sector := TConstellation(av[1].AsDword);
  if Sector <> nil then
  begin
    av[0].AsInteger := Ord(Sector.Visible);
    if High(av) > 1 then Sector.Visible := av[2].AsInteger <> 0;
  end;
  if (High(av) > 1) and (av[2].AsInteger = 1) and (MainPiratePlanet <> nil) and
    (MainPiratePlanet.CurrentStar.Constellation = Sector) then
    for I := 0 to Galaxy.Constellations.Count - 1 do TConstellation(Galaxy.Constellations[I]).RestoreHiddenForm;
end;
{ @end $6216A0 }

{ @routine $621794 SF_HullHP }
procedure SF_HullHP(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
  Ship: TShip;
  Amount: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HullHP');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].AsInteger := Hull.HullPoints;
  if High(av) > 1 then
  begin
    if av[2].ValueKind = value_string then
    begin
      Amount := Round(av[2].AsInteger * 0.01 * Hull.Weight);
      if Pos('UpTo', av[2].AsString) = 1 then Hull.HullPoints := Max(Hull.HullPoints, Amount)
      else if Pos('DownTo', av[2].AsString) = 1 then Hull.HullPoints := Min(Hull.HullPoints, Amount)
      else if Pos('To', av[2].AsString) = 1 then Hull.HullPoints := Amount
      else if Pos('Plus', av[2].AsString) = 1 then Hull.HullPoints := Max(Hull.HullPoints, Min(Hull.Weight, Hull.HullPoints + Amount))
      else if Pos('Minus', av[2].AsString) = 1 then Dec(Hull.HullPoints, Amount)
      else raise Exception.Create('Error.Script HullHP - unknown key ' + av[2].AsString);
    end
    else Hull.HullPoints := av[2].AsInteger;
    if Obj is TShip then Ship := TShip(Obj) else Ship := TShip(Hull.OwnerShip);
    if (Ship <> nil) and Ship.IsHullDestroyed and not Ship.DestroyQueued then
    begin
      if av[0].AsInteger > 0 then Ship.ScriptItemsAct(event_death, nil, nil, 0);
      if (Ship.CurrentStar <> nil) and Ship.CurrentStar.RecordingTurnFilm then Ship.CurrentStar.ClearShipReferences(Obj);
    end;
  end;
end;
{ @end $621794 }

{ @routine $621B5C SF_HullDamageSuspectibility }
procedure SF_HullDamageSuspectibility(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script HullDamageSuspectibility');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].AsInteger := Round(Hull.GetFragilityFactor([TDamageFlag(av[2].AsDword)]) * 100);
end;
{ @end $621B5C }

{ @routine $621CA0 SF_HullType }
procedure SF_HullType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HullType');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].AsInteger := Ord(Hull.HullType);
  if High(av) > 1 then Hull.HullType := THullType(av[2].AsInteger);
end;
{ @end $621CA0 }

{ @routine $621DAC SF_HullSpecial }
procedure SF_HullSpecial(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HullSpecial');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].AsInteger := Hull.SpecialModuleIndex - 1;
  if High(av) > 1 then Hull.SpecialModuleIndex := av[2].AsInteger + 1;
end;
{ @end $621DAC }

{ @routine $621EBC SF_HullSeries }
procedure SF_HullSeries(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HullSeries');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then Hull := TShip(Obj).GetHull
  else if Obj is THull then Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then Hull := (Obj as TScriptItem).Item as THull
  else Exit;
  av[0].AsInteger := Hull.HullSeries;
  if High(av) > 1 then Hull.HullSeries := av[2].AsInteger;
end;
{ @end $621EBC }

{ @routine $621FC4 SF_GalaxyHoles }
procedure SF_GalaxyHoles(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then av[0].AsInteger := Galaxy.Holes.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < Galaxy.Holes.Count) then av[0].AsDword := Cardinal(Galaxy.Holes[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $621FC4 }

{ @routine $622040 SF_HoleCreate2 }
procedure SF_HoleCreate2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
  Angle, Radius: Single;
  Star1, Star2: TStar;
  FilmObject: TEFilmObj;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script HoleCreate2');
  Star1 := TStar(av[1].AsDword);
  Star2 := TStar(av[2].AsDword);
  Hole := THole.Create;
  if High(av) < 3 then Hole.InitializeGraphic('')
  else Hole.InitializeGraphic(av[3].AsString);
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
  av[0].AsDword := Cardinal(Hole);
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
{ @end $622040 }

{ @routine $622304 SF_HoleStar1 }
procedure SF_HoleStar1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleStar1');
  Hole := THole(av[1].AsDword);
  if Hole = nil then Exit;
  av[0].AsDword := Cardinal(Hole.Star1);
  if High(av) > 1 then Hole.Star1 := TStar(av[2].AsDword);
end;
{ @end $622304 }

{ @routine $622390 SF_HoleStar2 }
procedure SF_HoleStar2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleStar2');
  Hole := THole(av[1].AsDword);
  if Hole = nil then Exit;
  av[0].AsDword := Cardinal(Hole.Star2);
  if High(av) > 1 then Hole.Star2 := TStar(av[2].AsDword);
end;
{ @end $622390 }

{ @routine $62241C SF_HoleX1 }
procedure SF_HoleX1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleX1');
  Hole := THole(av[1].AsDword);
  if Hole = nil then Exit;
  av[0].AsInteger := Round(Hole.Position1.X);
  if High(av) > 1 then Hole.Position1.X := av[2].AsInteger;
end;
{ @end $62241C }

{ @routine $6224B0 SF_HoleY1 }
procedure SF_HoleY1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleY1');
  Hole := THole(av[1].AsDword);
  if Hole = nil then Exit;
  av[0].AsInteger := Round(Hole.Position1.Y);
  if High(av) > 1 then Hole.Position1.Y := av[2].AsInteger;
end;
{ @end $6224B0 }

{ @routine $622544 SF_HoleX2 }
procedure SF_HoleX2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleX2');
  Hole := THole(av[1].AsDword);
  if Hole = nil then Exit;
  av[0].AsInteger := Round(Hole.Position2.X);
  if High(av) > 1 then Hole.Position2.X := av[2].AsInteger;
end;
{ @end $622544 }

{ @routine $6225D8 SF_HoleY2 }
procedure SF_HoleY2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleY2');
  Hole := THole(av[1].AsDword);
  if Hole = nil then Exit;
  av[0].AsInteger := Round(Hole.Position2.Y);
  if High(av) > 1 then Hole.Position2.Y := av[2].AsInteger;
end;
{ @end $6225D8 }

{ @routine $62266C SF_HoleTurnCreate }
procedure SF_HoleTurnCreate(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleTurnCreate');
  Hole := THole(av[1].AsDword);
  av[0].AsInteger := 0;
  if Hole = nil then Exit;
  av[0].AsInteger := Hole.CreatedTurn;
  if High(av) > 1 then Hole.CreatedTurn := av[2].AsInteger;
end;
{ @end $62266C }

{ @routine $622704 SF_HoleMap }
procedure SF_HoleMap(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleMap');
  Hole := THole(av[1].AsDword);
  if Hole <> nil then
  begin
    av[0].AsString := Hole.ArcadeMapName;
    if High(av) > 1 then Hole.ArcadeMapName := av[2].AsString;
  end
  else av[0].AsString := '';
end;
{ @end $622704 }

{ @routine $6227D0 SF_HoleGraph }
procedure SF_HoleGraph(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script HoleGraph');
  Hole := THole(av[1].AsDword);
  if Hole <> nil then
  begin
    av[0].AsString := Hole.Graphic.GraphKey;
    if High(av) > 1 then
    begin
      if Hole.Graphic <> nil then ReleaseSpaceObject(Hole.Graphic);
      RetainSpaceObject(Hole.Graphic, CreateSpaceObjectByName('Hole', av[2].AsString, Point(0, 0)));
      Hole.Graphic.SetPosition(MakePointF(0, 0));
    end;
  end
  else av[0].AsString := '';
end;
{ @end $6227D0 }

{ @routine $6228F8 SF_StarRuins }
procedure SF_StarRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Ship: TShip;
  I, Found: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarRuins');
  Star := TStar(av[1].AsDword);
  if Star = nil then Exit;
  Found := -1;
  if High(av) = 1 then
  begin
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship is TRuins then Inc(Found);
    end;
    av[0].AsInteger := Found + 1;
    Exit;
  end;
  if av[2].ValueKind = value_string then
  begin
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if not (Ship is TRuins) then Continue;
      if ((Ship.TypeNameOverrideKey <> '') and (Ship.TypeNameOverrideKey = av[2].AsString)) or
        ((Ship.TypeNameOverrideKey = '') and (ShipTypeNames[Ship.TypeId].Name = av[2].AsString)) then
      begin
        av[0].AsDword := Cardinal(Ship);
        Exit;
      end;
    end;
  end
  else
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if not (Ship is TRuins) then Continue;
      Inc(Found);
      if Found = av[2].AsInteger then
      begin
        av[0].AsDword := Cardinal(Ship);
        Exit;
      end;
    end;
  av[0].AsDword := 0;
end;
{ @end $6228F8 }

{ @routine $622B20 SF_CreateQuestItem }
procedure SF_CreateQuestItem(av: array of TVarEC; code: TCodeEC);
var
  Item: TUselessItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateQuestItem');
  Item := TUselessItem.Create;
  Item.Init(av[1].AsString, series_blazer, 0, False);
  if High(av) = 1 then Item.OwnerId := owner_uninhabited
  else if av[2].AsInteger >= 0 then Item.OwnerId := TOwnerId(av[2].AsInteger);
  av[0].AsDword := Cardinal(Item);
end;
{ @end $622B20 }

{ @routine $622C0C SF_ShipTurnBeforeEndOrder }
procedure SF_ShipTurnBeforeEndOrder(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipTurnBeforeEndOrder');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ship.EstimateOrderTravelTurns;
end;
{ @end $622C0C }

{ @routine $622C90 SF_ShipOrder }
procedure SF_ShipOrder(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOrder');
  Ship := TShip(av[1].AsDword);
  if (High(av) > 1) and (av[2].ValueKind = value_string) then
  begin
    if av[2].AsString = 'X' then
    begin
      av[0].AsFloat := Ship.OrderDestination.X;
      if High(av) > 2 then Ship.OrderDestination.X := av[3].AsFloat;
    end
    else if av[2].AsString = 'Y' then
    begin
      av[0].AsFloat := Ship.OrderDestination.Y;
      if High(av) > 2 then Ship.OrderDestination.Y := av[3].AsFloat;
    end
    else raise Exception.Create('Error.Script ShipOrder - unknown key ' + av[2].AsString);
    Exit;
  end;
  if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then av[0].AsInteger := -1
  else av[0].AsInteger := Ord(Ship.Order);
  if High(av) > 1 then Ship.Order := TShipOrder(av[2].AsDword);
end;
{ @end $622C90 }

{ @routine $622ED4 SF_ShipOrderData1 }
procedure SF_ShipOrderData1(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  LowWord, HighWord: Word;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOrderData1');
  Ship := TShip(av[1].AsDword);
  HighWord := Ship.OrderStateData shr 16;
  LowWord := Ship.OrderStateData and $FFFF;
  av[0].AsInteger := LowWord;
  if High(av) > 1 then Ship.OrderStateData := (Integer(HighWord) shl 16) + (av[2].AsInteger and $FFFF);
end;
{ @end $622ED4 }

{ @routine $622F88 SF_ShipOrderData2 }
procedure SF_ShipOrderData2(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  LowWord, HighWord: Word;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOrderData2');
  Ship := TShip(av[1].AsDword);
  HighWord := Ship.OrderStateData shr 16;
  LowWord := Ship.OrderStateData and $FFFF;
  av[0].AsInteger := HighWord;
  if High(av) > 1 then Ship.OrderStateData := Integer(LowWord) + ((av[2].AsInteger and $FFFF) shl 16);
end;
{ @end $622F88 }

{ @routine $62303C SF_ShipOrderObj }
procedure SF_ShipOrderObj(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipOrderObj');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then av[0].AsDword := Cardinal(PendingPlayerFollowTarget)
  else av[0].AsDword := Cardinal(Ship.OrderTarget);
  if High(av) > 1 then
  begin
    if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then PendingPlayerFollowTarget := TShip(av[2].AsDword)
    else Ship.OrderTarget := TObject(av[2].AsDword);
  end;
end;
{ @end $62303C }

{ @routine $623118 SF_ShipDestination }
procedure SF_ShipDestination(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipDestination');
  Obj := TObject(av[1].AsDword);
  if Obj = nil then Exit;
  if GetPlayer = Obj then
  begin
    av[0].AsDword := Cardinal(GetPlayer.QueuedTravelTarget);
    if High(av) > 1 then GetPlayer.QueuedTravelTarget := TStar(av[2].AsDword);
  end
  else if Obj is TRuins then
  begin
    if (High(av) > 1) and (av[2].ValueKind = value_string) and (av[2].AsString = 'Date') then
    begin
      // Native Date query reads the target pointer at +558, while its setter writes FlyDate at +55C.
      av[0].AsInteger := Integer(TRuins(Obj).FlyToStar);
      if High(av) > 2 then TRuins(Obj).FlyDate := av[3].AsInteger;
    end
    else
    begin
      av[0].AsDword := Cardinal(TRuins(Obj).FlyToStar);
      if High(av) > 1 then TRuins(Obj).FlyToStar := TStar(av[2].AsDword);
      if High(av) > 2 then TRuins(Obj).FlyDate := av[3].AsInteger;
    end;
  end
  else av[0].AsDword := 0;
end;
{ @end $623118 }

{ @routine $6232B0 SF_BuildRuins }
procedure SF_BuildRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Station: TRuins;
  Kind: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script BuildRuins');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    Station := nil;
    Kind := av[2].AsInteger;
    if TShipType(Kind) in [station_ranger_center..station_custom] then
    begin
      Station := TRuins.Create;
      Station.Init(TStationType(Kind), Star, '');
    end;
    av[0].AsDword := Cardinal(Station);
  end;
end;
{ @end $6232B0 }

{ @routine $62335C SF_BuildCustomRuins }
procedure SF_BuildCustomRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Station: TRuins;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script BuildCustomRuins');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    Station := TRuins.Create;
    av[0].AsDword := Cardinal(Station);
    Station.Init(station_custom, Star, av[2].AsString);
    if High(av) > 2 then Station.CurrentStanding := TShipStanding(av[3].AsInteger)
    else Station.CurrentStanding := standing_unaligned;
  end;
end;
{ @end $62335C }

{ @routine $623458 SF_RuinsChangeType }
procedure SF_RuinsChangeType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Station: TRuins;
  Index: TShipType;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script RuinsChangeType');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TRuins) then Exit;
  Station := TRuins(Obj);
  if av[2].ValueKind = value_string then
    for Index := station_ranger_center to station_custom do
      if av[2].AsString = ShipTypeNames[Index].Name then
      begin
        Station.TypeId := Index;
        Exit;
      end;
  Index := TShipType(av[2].AsInteger);
  if Index in [station_ranger_center..station_custom] then Station.TypeId := Index;
end;
{ @end $623458 }

{ @routine $623568 SF_ShipStanding }
procedure SF_ShipStanding(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipStanding');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  av[0].AsInteger := Ord(Ship.CurrentStanding);
  if High(av) > 1 then Ship.CurrentStanding := TShipStanding(av[2].AsInteger);
end;
{ @end $623568 }

{ @routine $6235FC SF_ShipSlots }
procedure SF_ShipSlots(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipSlots');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := 0;
  if Ship <> nil then
    case av[2].AsInteger of
      1: av[0].AsInteger := Ship.GetSlotCount(slot_weapon);
      2: av[0].AsInteger := Ship.GetSlotCount(slot_artefact);
      3: av[0].AsInteger := Ship.GetSlotCount(slot_radar);
      4: av[0].AsInteger := Ship.GetSlotCount(slot_scanner);
      5: av[0].AsInteger := Ship.GetSlotCount(slot_repair_robot);
      6: av[0].AsInteger := Ship.GetSlotCount(slot_cargo_hook);
      7: av[0].AsInteger := Ship.GetSlotCount(slot_defense_generator);
      8: av[0].AsInteger := Ship.GetSlotCount(slot_afterburner);
    end;
end;
{ @end $6235FC }

{ @routine $623758 SF_MissileStar }
procedure SF_MissileStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileStar');
  av[0].AsDword := Cardinal(TMissile(av[1].AsDword).CurrentStar);
end;
{ @end $623758 }

{ @routine $6237CC SF_MissileType }
procedure SF_MissileType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileType');
  av[0].AsInteger := Ord(TMissile(av[1].AsDword).ItemType);
end;
{ @end $6237CC }

{ @routine $623840 SF_CustomMissileType }
procedure SF_CustomMissileType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomMissileType');
  av[0].AsString := TMissile(av[1].AsDword).GetWeaponInfo.ConfigName;
end;
{ @end $623840 }

{ @routine $6238BC SF_MissileOwner }
procedure SF_MissileOwner(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileOwner');
  av[0].AsDword := Cardinal(TMissile(av[1].AsDword).OwnerShip);
  if High(av) > 1 then TMissile(av[1].AsDword).OwnerShip := TShip(av[2].AsDword);
end;
{ @end $6238BC }

{ @routine $623950 SF_MissileWeaponID }
procedure SF_MissileWeaponID(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileWeaponID');
  av[0].AsDword := Cardinal(TMissile(av[1].AsDword).WeaponId);
end;
{ @end $623950 }

{ @routine $6239C8 SF_MissileTarget }
procedure SF_MissileTarget(av: array of TVarEC; code: TCodeEC);
var
  Missile: TMissile;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileTarget');
  Missile := TMissile(av[1].AsDword);
  if Missile.Target <> nil then av[0].AsDword := Cardinal(Missile.Target)
  else av[0].AsDword := Cardinal(Missile.PreviousTarget);
  if High(av) > 1 then TMissile(av[1].AsDword).Target := TObject(av[2].AsDword);
end;
{ @end $6239C8 }

{ @routine $623A70 SF_MissileMaxDamage }
procedure SF_MissileMaxDamage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileMaxDamage');
  av[0].AsInteger := TMissile(av[1].AsDword).MaxDamage;
  if High(av) > 1 then TMissile(av[1].AsDword).MaxDamage := av[2].AsInteger;
end;
{ @end $623A70 }

{ @routine $623B08 SF_MissileMinDamage }
procedure SF_MissileMinDamage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileMinDamage');
  av[0].AsInteger := TMissile(av[1].AsDword).MinDamage;
  if High(av) > 1 then TMissile(av[1].AsDword).MinDamage := av[2].AsInteger;
end;
{ @end $623B08 }

{ @routine $623BA0 SF_MissileLive }
procedure SF_MissileLive(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileLive');
  av[0].AsInteger := TMissile(av[1].AsDword).FlightTicks;
  if High(av) > 1 then TMissile(av[1].AsDword).FlightTicks := av[2].AsInteger;
end;
{ @end $623BA0 }

{ @routine $623C34 SF_MissileSpeed }
procedure SF_MissileSpeed(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileSpeed');
  av[0].AsInteger := Round(TMissile(av[1].AsDword).Speed);
  if High(av) > 1 then TMissile(av[1].AsDword).Speed := av[2].AsInteger;
end;
{ @end $623C34 }

{ @routine $623CD8 SF_MissileAngle }
procedure SF_MissileAngle(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissileAngle');
  av[0].AsInteger := Round(TMissile(av[1].AsDword).Direction);
  if High(av) > 1 then TMissile(av[1].AsDword).Direction := av[2].AsInteger;
end;
{ @end $623CD8 }

{ @routine $623D7C SF_AsteroidMinerals }
procedure SF_AsteroidMinerals(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AsteroidMinerals');
  av[0].AsInteger := TAsteroid(av[1].AsDword).MineralCount;
  if High(av) > 1 then TAsteroid(av[1].AsDword).MineralCount := av[2].AsInteger;
end;
{ @end $623D7C }

{ @routine $623E14 SF_AsteroidGraph }
procedure SF_AsteroidGraph(av: array of TVarEC; code: TCodeEC);
var
  Asteroid: TAsteroid;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AsteroidGraph');
  Asteroid := TAsteroid(av[1].AsDword);
  av[0].AsString := Asteroid.GraphObject.GraphKey;
  if High(av) > 1 then
  begin
    ReleaseSpaceObject(Asteroid.GraphObject);
    RetainSpaceObject(Asteroid.GraphObject, CreateSpaceObjectByName(ExtractDelimitedPartW(av[2].AsString, 0, '.'), av[2].AsString, Point(0, 0)));
  end;
end;
{ @end $623E14 }

{ @routine $623F34 SF_AsteroidRespawn }
procedure SF_AsteroidRespawn(av: array of TVarEC; code: TCodeEC);
var
  Asteroid: TAsteroid;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script AsteroidRespawn');
  Asteroid := TAsteroid(av[1].AsDword);
  if Asteroid <> nil then Asteroid.Respawn;
end;
{ @end $623F34 }

{ @routine $623FA8 SF_ArrayAdd }
procedure SF_ArrayAdd(Args: array of TVarEC; Code: TCodeEC);
var
  NewValue, SourceValue: TVarEC;
begin
  if High(Args) < 2 then raise Exception.Create('Error.Script ArrayAdd');
  if Args[1].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArrayAdd - not array');
  SourceValue := Args[2].Resolve;
  NewValue := TVarEC.Create(SourceValue.ValueKind);
  NewValue.AssignFrom(SourceValue, False);
  if High(Args) > 2 then NewValue.Name := Args[3].AsString;
  Args[1].AsArray.AddItem(NewValue);
  Args[0].AsInteger := Args[1].AsArray.Count;
end;
{ @end $623FA8 }

{ @routine $6240F8 SF_ArrayDelete }
procedure SF_ArrayDelete(Args: array of TVarEC; Code: TCodeEC);
var
  ElementIndex: Integer;
begin
  if High(Args) < 2 then raise Exception.Create('Error.Script ArrayDelete');
  if Args[1].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArrayDelete - not array');
  if Args[2].ValueKind = value_string then Args[1].AsArray.DeleteByName(Args[2].AsString)
  else
  begin
    ElementIndex := Args[2].AsInteger;
    if (ElementIndex >= 0) and (ElementIndex < Args[1].AsArray.Count) then Args[1].AsArray.Delete(ElementIndex);
  end;
  Args[0].AsInteger := Args[1].AsArray.Count;
end;
{ @end $6240F8 }

{ @routine $624244 SF_ArrayClear }
procedure SF_ArrayClear(Args: array of TVarEC; Code: TCodeEC);
begin
  if High(Args) < 1 then raise Exception.Create('Error.Script ArrayClear');
  if Args[1].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArrayClear - not array');
  Args[1].AsArray.Clear;
  { Native arrays retain one empty placeholder after this operation. }
  Args[1].AsArray.AddItem(TVarEC.Create(value_empty));
end;
{ @end $624244 }

{ @routine $624318 SF_ArrayDim }
procedure SF_ArrayDim(Args: array of TVarEC; Code: TCodeEC);
begin
  if High(Args) < 1 then raise Exception.Create('Error.Script ArrayDim');
  if Args[1].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArrayDim - not array');
  Args[0].AsInteger := Args[1].AsArray.Count;
end;
{ @end $624318 }

{ @routine $6243D4 SF_ArraySort }
procedure SF_ArraySort(Args: array of TVarEC; Code: TCodeEC);
var
  ArrayCount, ElementCount, I, ElementIndex, ArrayIndex: Integer;
  SwapValue: TVarEC;
begin
  ArrayCount := High(Args);
  if ArrayCount < 1 then raise Exception.Create('Error.Script ArraySort');
  if Args[1].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArraySort - not array');
  ElementCount := Args[1].AsArray.Count;
  if ElementCount < 2 then Exit;
  if ArrayCount > 1 then
    for I := 2 to ArrayCount do
    begin
      if Args[I].ValueKind <> value_array then
        raise Exception.Create('Error.Script ArraySort - type mismatch');
      if Args[I].AsArray.Count <> ElementCount then
        raise Exception.Create('Error.Script ArraySort - size mismatch');
    end;
  for I := 1 to ElementCount - 1 do
    for ElementIndex := ElementCount - 1 downto I do
      if Args[1].AsArray[ElementIndex].AsInteger < Args[1].AsArray[ElementIndex - 1].AsInteger then
        for ArrayIndex := 1 to ArrayCount do
        begin
          SwapValue := Args[ArrayIndex].AsArray[ElementIndex];
          Args[ArrayIndex].AsArray[ElementIndex] := Args[ArrayIndex].AsArray[ElementIndex - 1];
          Args[ArrayIndex].AsArray[ElementIndex - 1] := SwapValue;
        end;
end;
{ @end $6243D4 }

{ @routine $624638 SF_ArraySortPartial }
procedure SF_ArraySortPartial(Args: array of TVarEC; Code: TCodeEC);
var
  ArrayCount, ElementCount, I, ElementIndex, ArrayIndex, MinIndex: Integer;
  SwapValue: TVarEC;
begin
  ArrayCount := High(Args) - 1;
  if ArrayCount < 1 then raise Exception.Create('Error.Script ArraySortPartial');
  if Args[2].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArraySortPartial - not array');
  ElementCount := Args[2].AsArray.Count;
  MinIndex := Args[1].AsInteger;
  if ElementCount < 2 then Exit;
  if ArrayCount > 1 then
    for I := 2 to ArrayCount do
    begin
      if Args[I + 1].ValueKind <> value_array then
        raise Exception.Create('Error.Script ArraySortPartial - type mismatch');
      if Args[I + 1].AsArray.Count <> ElementCount then
        raise Exception.Create('Error.Script ArraySortPartial - size mismatch');
    end;
  // Native operation: one backward adjacent-swap pass. MinIndex is unchecked;
  // each comparison also reads ElementIndex - 1.
  for ElementIndex := ElementCount - 1 downto MinIndex do
    if Args[2].AsArray[ElementIndex].AsInteger < Args[2].AsArray[ElementIndex - 1].AsInteger then
      for ArrayIndex := 1 to ArrayCount do
      begin
        SwapValue := Args[ArrayIndex + 1].AsArray[ElementIndex];
        Args[ArrayIndex + 1].AsArray[ElementIndex] := Args[ArrayIndex + 1].AsArray[ElementIndex - 1];
        Args[ArrayIndex + 1].AsArray[ElementIndex - 1] := SwapValue;
      end;
end;
{ @end $624638 }

{ @routine $6248A0 SF_ArrayRandomize }
procedure SF_ArrayRandomize(Args: array of TVarEC; Code: TCodeEC);
var
  LastArgIndex, ElementCount, I, SwapIndex1, SwapIndex2, ArrayArgIndex, SwapCount: Integer;
  Seed: Cardinal;
  SwapValue: TVarEC;
  HasSeed: Boolean;
begin
  LastArgIndex := High(Args);
  if LastArgIndex < 2 then raise Exception.Create('Error.Script ArrayRandomize');
  if Args[2].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArrayRandomize - not array');
  ElementCount := Args[2].AsArray.Count;
  if ElementCount < 2 then Exit;
  SwapCount := Args[1].AsInteger;
  HasSeed := False;
  if Args[LastArgIndex].ValueKind <> value_array then
  begin
    Seed := Args[LastArgIndex].AsDword;
    HasSeed := True;
    Dec(LastArgIndex);
  end;
  for I := 3 to LastArgIndex do
  begin
    if Args[I].ValueKind <> value_array then
      raise Exception.Create('Error.Script ArrayRandomize - type mismatch');
    if Args[I].AsArray.Count <> ElementCount then
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
        SwapValue := Args[ArrayArgIndex].AsArray[SwapIndex1];
        Args[ArrayArgIndex].AsArray[SwapIndex1] := Args[ArrayArgIndex].AsArray[SwapIndex2];
        Args[ArrayArgIndex].AsArray[SwapIndex2] := SwapValue;
      end;
  end;
end;
{ @end $6248A0 }

{ @routine $624B6C SF_ArrayFind }
procedure SF_ArrayFind(Args: array of TVarEC; Code: TCodeEC);
var
  ElementIndex: Integer;
begin
  if High(Args) < 2 then raise Exception.Create('Error.Script ArrayFind');
  if Args[1].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArrayFind - not array');
  Args[0].AsInteger := -1;
  if Args[2].ValueKind = value_int32 then
  begin
    for ElementIndex := 0 to Args[1].AsArray.Count - 1 do
      if Args[1].AsArray[ElementIndex].AsInteger = Args[2].AsInteger then
      begin
        Args[0].AsInteger := ElementIndex;
        Exit;
      end;
  end
  else if Args[2].ValueKind = value_uint32 then
  begin
    for ElementIndex := 0 to Args[1].AsArray.Count - 1 do
      if Args[1].AsArray[ElementIndex].AsDword = Args[2].AsDword then
      begin
        Args[0].AsInteger := ElementIndex;
        Exit;
      end;
  end
  else if Args[2].ValueKind = value_string then
  begin
    for ElementIndex := 0 to Args[1].AsArray.Count - 1 do
      if Args[1].AsArray[ElementIndex].AsString = Args[2].AsString then
      begin
        Args[0].AsInteger := ElementIndex;
        Exit;
      end;
  end
  else if Args[2].ValueKind = value_float64 then
  begin
    for ElementIndex := 0 to Args[1].AsArray.Count - 1 do
      if Args[1].AsArray[ElementIndex].AsFloat = Args[2].AsFloat then
      begin
        Args[0].AsInteger := ElementIndex;
        Exit;
      end;
  end;
end;
{ @end $624B6C }

{ @routine $624DD0 SF_ArrayFindInSorted }
procedure SF_ArrayFindInSorted(Args: array of TVarEC; Code: TCodeEC);
var
  ElementCount, TargetValue, HighValue, LowValue, HighIndex, LowIndex: Integer;
  ProbeValue, ProbeIndex, Pass, InterpolationPassCount, ScanDirection: Integer;
begin
  if High(Args) < 2 then raise Exception.Create('Error.Script ArrayFindInSorted');
  if Args[1].ValueKind <> value_array then
    raise Exception.Create('Error.Script ArrayFindInSorted - not array');
  ProbeIndex := 0;
  ElementCount := Args[1].AsArray.Count;
  TargetValue := Args[2].AsInteger;
  LowIndex := 0;
  { The native search reads both endpoints without an empty-array check. }
  LowValue := Args[1].AsArray[0].AsInteger;
  HighIndex := ElementCount - 1;
  HighValue := Args[1].AsArray[ElementCount - 1].AsInteger;
  InterpolationPassCount := 3;
  if (TargetValue > HighValue) or (TargetValue < LowValue) then
  begin
    Args[0].AsInteger := -1;
    Exit;
  end;
  if TargetValue = HighValue then
  begin
    Args[0].AsInteger := HighIndex;
    Exit;
  end;
  if TargetValue = LowValue then
  begin
    Args[0].AsInteger := LowIndex;
    Exit;
  end;
  if HighValue = LowValue then
  begin
    Args[0].AsInteger := -1;
    Exit;
  end;
  for Pass := 1 to InterpolationPassCount do
  begin
    ProbeIndex := Round((TargetValue - LowValue) * (HighIndex - LowIndex) /
      (HighValue - LowValue) + LowIndex);
    ProbeValue := Args[1].AsArray[ProbeIndex].AsInteger;
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
      Args[0].AsInteger := HighIndex;
      Exit;
    end;
    if TargetValue = LowValue then
    begin
      Args[0].AsInteger := LowIndex;
      Exit;
    end;
    if HighValue = LowValue then
    begin
      Args[0].AsInteger := -1;
      Exit;
    end;
  end;
  if ProbeIndex = HighIndex then ScanDirection := -1 else ScanDirection := 1;
  Inc(ProbeIndex, ScanDirection);
  ProbeValue := Args[1].AsArray[ProbeIndex].AsInteger;
  while (ProbeValue <> TargetValue) and (ProbeIndex < HighIndex) and (ProbeIndex > LowIndex) and
    ((TargetValue - ProbeValue) * ScanDirection > 0) do
  begin
    Inc(ProbeIndex, ScanDirection);
    ProbeValue := Args[1].AsArray[ProbeIndex].AsInteger;
  end;
  if ProbeValue = TargetValue then Args[0].AsInteger := ProbeIndex
  else Args[0].AsInteger := -1;
end;
{ @end $624DD0 }

{ @routine $62509C SF_DistToNearestEnemySystem }
procedure SF_DistToNearestEnemySystem(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Star, Other: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DistToNearestEnemySystem');
  Star := TStar(av[1].AsDword);
  I := 0;
  while I < Galaxy.Stars.Count do
  begin
    Other := Star.StarDistances[I].Star as TStar;
    if (Other.ControlFaction = faction_dominators) or (Other.Status.CustomFaction <> '') then Break;
    Inc(I);
  end;
  if I = Galaxy.Stars.Count then av[0].AsInteger := -1
  else av[0].AsInteger := Star.StarDistances[I].Distance;
end;
{ @end $62509C }

{ @routine $625188 SF_StarEnemyThreatLevel }
procedure SF_StarEnemyThreatLevel(av: array of TVarEC; code: TCodeEC);
var
  Star, Other: TStar;
  Ship: TShip;
  I, J: Integer;
  Standings: TShipStandings;
  IncludePirates: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarEnemyThreatLeve');
  Star := TStar(av[1].AsDword);
  IncludePirates := (High(av) > 1) and (av[2].AsInteger = 1);
  if Star = nil then raise Exception.Create('Error.Script StarEnemyThreatLevel');
  if (Star.ControlFaction = faction_dominators) or (Star.Status.CustomFaction <> '') or (IncludePirates and (Star.ControlFaction = faction_pirates)) then
  begin
    av[0].AsInteger := 3;
    Exit;
  end;
  if Star.Battle <> 0 then
  begin
    av[0].AsInteger := 2;
    Exit;
  end;
  if Galaxy.KellerTargetStar = Star then
  begin
    av[0].AsInteger := 1;
    Exit;
  end;
  Standings := [standing_dominator, standing_custom];
  if IncludePirates then Standings := Standings + [standing_pirate_active, standing_pirate_military];
  for J := 0 to Star.Ships.Count - 1 do
  begin
    Ship := Star.Ships[J];
    if ((Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> owner_uninhabited)) and (Ship.CurrentStanding in Standings) then
    begin
      av[0].AsInteger := 1;
      Exit;
    end;
  end;
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    Other := TStar(Star.StarDistances[I].Star);
    // Native code tests the original star's custom/pirate fields here.
    if (Other.ControlFaction = faction_dominators) or (Star.Status.CustomFaction <> '') or (IncludePirates and (Star.ControlFaction = faction_pirates)) then
      for J := 0 to Other.Ships.Count - 1 do
      begin
        Ship := Other.Ships[J];
        if (Ship.OrderTarget = Star) and (Ship.CurrentStanding in Standings) then
        begin
          av[0].AsInteger := 1;
          Exit;
        end;
        if (Ship is TRuins) and (TRuins(Ship).FlyToStar = Star) and (Ship.CurrentStanding in Standings) then
        begin
          av[0].AsInteger := 1;
          Exit;
        end;
      end;
  end;
  av[0].AsInteger := 0;
end;
{ @end $625188 }

{ @routine $625460 SF_BuildListOfQuestPossibleLocations }
procedure SF_BuildListOfQuestPossibleLocations(av: array of TVarEC; code: TCodeEC);
var
  I, J, K, MinDistance, MaxDistance, Count: Integer;
  Star, Candidate: TStar;
  Allowed: Boolean;
  Value: TVarEC;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script BuildListOfQuestPossibleLocations');
  if av[1].ValueKind = value_empty then
  begin
    av[1].ConvertToKind(value_array);
    av[1].AsArray := TVarArrayEC.Create;
  end
  else if av[1].ValueKind <> value_array then raise Exception.Create('Error.Script BuildListOfQuestPossibleLocations - not array');
  Star := TStar(av[2].AsDword);
  MinDistance := av[3].AsInteger;
  MaxDistance := av[4].AsInteger;
  av[1].AsArray.Clear;
  I := 1;
  while (I < Galaxy.Stars.Count) and (Star.StarDistances[I].Distance <= MaxDistance) do
  begin
    Candidate := TStar(Star.StarDistances[I].Star);
    if (Star.StarDistances[I].Distance >= MinDistance) and
      (Candidate.ControlFaction = faction_coalition) and (Candidate.Status.CustomFaction = '') and
      (Candidate.Battle = 0) and (Galaxy.KellerTargetStar <> Candidate) and Candidate.IsConstellationVisible then
    begin
      Allowed := True;
      if High(av) > 4 then
        for J := 5 to High(av) do
          if TStar(av[J].AsDword) = Candidate then Allowed := False;
      if Allowed then
      begin
        Value := TVarEC.Create(value_uint32);
        Value.AsDword := Cardinal(Candidate);
        av[1].AsArray.AddItem(Value);
      end;
    end;
    Inc(I);
  end;
  Count := av[1].AsArray.Count;
  for I := Count - 1 downto 0 do
  begin
    Star := TStar(av[1].AsArray[I].AsDword);
    J := 0;
    Allowed := True;
    while Allowed and (J < Star.Ships.Count) do
      if TShip(Star.Ships[J]).TypeId = ship_dominator then
      begin
        Allowed := False;
        av[1].AsArray.Delete(I);
      end
      else Inc(J);
  end;
  Count := av[1].AsArray.Count;
  I := 0;
  while (I < Galaxy.Stars.Count) and (Count > 0) do
  begin
    Star := Galaxy.Stars[I];
    if Star.ControlFaction = faction_dominators then
      for J := 0 to Star.Ships.Count - 1 do
        if (TShip(Star.Ships[J]).TypeId = ship_dominator) and (TShip(Star.Ships[J]).OrderTarget is TStar) then
        begin
          Candidate := TShip(Star.Ships[J]).OrderTarget as TStar;
          for K := av[1].AsArray.Count - 1 downto 0 do
            if TStar(av[1].AsArray[K].AsDword) = Candidate then
            begin
              av[1].AsArray.Delete(K);
              Count := av[1].AsArray.Count;
            end;
        end;
    Inc(I);
  end;
  Count := av[1].AsArray.Count;
  av[0].AsInteger := Count;
  if Count = 0 then av[1].AsArray.AddItem(TVarEC.Create(value_empty));
end;
{ @end $625460 }

{ @routine $6258AC SF_FindItemInShip }
procedure SF_FindItemInShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script FindItemInShip');
  Ship := TShip(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].AsInteger := -1;
  if Item <> nil then
  begin
    av[0].AsInteger := Ship.Inventory.IndexOf(Item);
    if av[0].AsInteger < 0 then av[0].AsInteger := Ship.Artefacts.IndexOf(Item);
  end;
end;
{ @end $6258AC }

{ @routine $62599C SF_GalaxyRangers }
procedure SF_GalaxyRangers(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then av[0].AsInteger := Galaxy.Rangers.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < Galaxy.Rangers.Count) then av[0].AsDword := Cardinal(Galaxy.Rangers[Index])
    else av[0].AsDword := 0;
  end;
end;
{ @end $62599C }

{ @routine $625A18 SF_MakeShipEnterStar }
procedure SF_MakeShipEnterStar(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Star, Origin: TStar;
  State: Word;
  I: Integer;
  SavedOrderLock: Byte;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script MakeShipEnterStar');
  Ship := TShip(av[1].AsDword);
  Star := TStar(av[2].AsDword);
  Origin := TStar(av[3].AsDword);
  State := av[4].AsDword;
  if (GetPlayer = Ship) then
    if (TemporaryShopSlots <> nil) then RestoreTemporaryShopStock;
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
  if (Ship is TNormalShip) then
    if ((Ship as TNormalShip).LastDockedPlanet = nil) then
    (Ship as TNormalShip).LastDockedPlanet := (Ship as TNormalShip).HomePlanet;
  Ship.CurrentPlanet := nil;
  Ship.DockedTo := nil;
end;
{ @end $625A18 }

{ @routine $625B9C SF_ShipGetBad }
procedure SF_ShipGetBad(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipGetBad');
  if av[1].AsDword <> 0 then av[0].AsDword := Cardinal(TShip(av[1].AsDword).EnemyShip);
end;
{ @end $625B9C }

{ @routine $625C1C SF_ShipAddDropItem }
procedure SF_ShipAddDropItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipAddDropItem');
  Ship := TShip(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  if (Ship <> nil) and (Item <> nil) then av[0].AsInteger := Ship.GuaranteedDeathDropItems.Add(Item);
end;
{ @end $625C1C }

{ @routine $625CB8 SF_BonusCount }
procedure SF_BonusCount(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := MicroModuleTemplateCount;
end;
{ @end $625CB8 }

{ @routine $625CE8 SF_SeriesCount }
procedure SF_SeriesCount(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := HullSeriesCount;
end;
{ @end $625CE8 }

{ @routine $625D18 SF_BonusPriority }
procedure SF_BonusPriority(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusPriority');
  if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusPriority - number out of range');
  av[0].AsInteger := MicroModuleTemplates[av[1].AsInteger].Priority;
end;
{ @end $625D18 }

{ @routine $625E0C SF_BonusIsSpecial }
procedure SF_BonusIsSpecial(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusIsSpecial');
  if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusIsSpecial - number out of range');
  av[0].AsInteger := Ord(MicroModuleTemplates[av[1].AsInteger].SpecialOnly);
end;
{ @end $625E0C }

{ @routine $625EFC SF_BonusName }
procedure SF_BonusName(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusName');
  if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusName - number out of range');
  av[0].AsString := MicroModuleTemplates[av[1].AsInteger].Name;
end;
{ @end $625EFC }

{ @routine $625FE4 SF_BonusNumInCfg }
procedure SF_BonusNumInCfg(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusNumInCfg');
  if av[1].AsInteger = -1 then av[0].AsString := ''
  else
  begin
    if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusNumInCfg - number out of range');
    av[0].AsString := MicroModuleTemplates[av[1].AsInteger].ConfigName;
  end;
end;
{ @end $625FE4 }

{ @routine $6260EC SF_SeriesNumInCfg }
procedure SF_SeriesNumInCfg(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SeriesNumInCfg');
  if av[1].AsInteger = -1 then av[0].AsString := ''
  else
  begin
    if (av[1].AsInteger < 0) or (av[1].AsInteger >= HullSeriesCount) then raise Exception.Create('Error.Script SeriesNumInCfg - number out of range');
    av[0].AsString := HullSeriesDefinitions[av[1].AsInteger].SystemName;
  end;
end;
{ @end $6260EC }

{ @routine $6261F4 SF_BonusValue }
procedure SF_BonusValue(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then raise Exception.Create('Error.Script BonusValue');
  if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then raise Exception.Create('Error.Script BonusValue - number out of range');
  av[0].AsInteger := MicroModuleTemplates[av[1].AsInteger].StatBonuses[TEquipmentBonusKind(av[2].AsInteger)];
end;
{ @end $6261F4 }

{ @routine $6262EC SF_FindBonusByName }
procedure SF_FindBonusByName(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindBonusByName');
  av[0].AsInteger := -1;
  for Index := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[Index].Name = av[1].AsString then
    begin
      av[0].AsInteger := Index;
      Break;
    end;
end;
{ @end $6262EC }

{ @routine $6263D4 SF_FindSeriesByName }
procedure SF_FindSeriesByName(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindSeriesByName');
  av[0].AsInteger := -1;
  for Index := 0 to High(HullSeriesDefinitions) do
    if HullSeriesDefinitions[Index].Name = av[1].AsString then
    begin
      av[0].AsInteger := Index;
      Break;
    end;
end;
{ @end $6263D4 }

{ @routine $6264BC SF_FindBonusByCustomTag }
procedure SF_FindBonusByCustomTag(av: array of TVarEC; code: TCodeEC);
var
  Index, Occurrence: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindBonusByCustomTag');
  av[0].AsInteger := -1;
  Occurrence := 0;
  if High(av) > 1 then Occurrence := av[2].AsInteger;
  for Index := 0 to MicroModuleTemplateCount - 1 do
  begin
    if MicroModuleTemplates[Index].CustomTag <> av[1].AsString then Continue;
      if Occurrence = 0 then
      begin
        av[0].AsInteger := Index;
        Break;
      end;
      Dec(Occurrence);
    end;
end;
{ @end $6264BC }

{ @routine $6265D0 SF_FindBonusByNameInCfg }
procedure SF_FindBonusByNameInCfg(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindBonusByNameInCfg');
  av[0].AsInteger := -1;
  for Index := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[Index].ConfigName = av[1].AsString then
    begin
      av[0].AsInteger := Index;
      Break;
    end;
end;
{ @end $6265D0 }

{ @routine $6266C0 SF_BonusCustomTag }
procedure SF_BonusCustomTag(av: array of TVarEC; code: TCodeEC);
var
  Block: TBlockParEC;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusCustomTag');
  Block := LanguageDataConfig.GetBlockByPath('MicroModuls.' + MicroModuleTemplates[av[1].AsInteger].ConfigName);
  if Block.CountParams('CustomTag') <= 0 then av[0].AsString := ''
  else av[0].AsString := Block.GetParamByPath('CustomTag');
end;
{ @end $6266C0 }

{ @routine $6267F8 SF_CreateEquipmentWithSpecial }
procedure SF_CreateEquipmentWithSpecial(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Kind: TItemType;
  Mask: TItemTypeSelection;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CreateEquipmentWithSpecial');
  if not MicroModuleTemplates[av[1].AsInteger].SpecialOnly then raise Exception.Create('Error.Script CreateEquipmentWithSpecial - not special');
  Mask := MicroModuleTemplates[av[1].AsInteger].AllowedItemTypes;
  Kind := TItemType(PickRandomItemTypeFromSeed(Mask, Galaxy.RandomState));
  if High(av) > 3 then Item := CreateGeneratedEquipment(Kind, av[2].AsInteger, av[3].AsInteger, TOwnerId(av[4].AsInteger))
  else Item := TEquipment(CreateDefaultItemByType(Kind));
  ApplySpecialMicroModule(av[1].AsInteger, Item);
  av[0].AsDword := Cardinal(Item);
end;
{ @end $6267F8 }

{ @routine $626978 SF_SpecialToEquipment }
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
  RandomMode := (High(av) = 1) or ((av[1].ValueKind = value_uint32) and (av[1].AsDword > $FFFF));
  if RandomMode then Obj := TObject(av[1].AsDword) else Obj := TObject(av[2].AsDword);
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
    if High(av) > 1 then Level := av[2].AsInteger else Level := Galaxy.TechLevel;
    PriorityLimit := Round(100 * Level / 8);
    BestPriority := 0;
    Count := 0;
    Template := @MicroModuleTemplates[0];
    for Index := 0 to MicroModuleTemplateCount - 1 do
    begin
      while True do
      begin
        if not Template.SpecialOnly or
          ((Template.OfferStationTypes = []) and (Template.OfferStationNames = '<>') and not Template.OnPlanets) or
          (IsWeapon and not IsBonusCompatibleWithWeapon(Index, TWeapon(Item))) or
          (IsHull and not IsBonusCompatibleWithHull(Index, THull(Item))) or
          (IsOther and not IsBonusCompatibleWithEquipment(Index, Item)) or
          (Template.Priority > PriorityLimit) then Break;
        if Count = 0 then BestPriority := Template.Priority else BestPriority := Max(BestPriority, Template.Priority);
        MicroModuleCandidateIndices[Count] := Index;
        Inc(Count);
        Break;
      end;
      Inc(Template);
    end;
    if Count <= 0 then av[0].AsInteger := -1
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
      av[0].AsInteger := MicroModuleCandidateIndices[Chosen];
    end;
  end
  else if av[1].AsInteger >= 0 then
  begin
    Item.SpecialModuleIndex := 0;
    ApplySpecialMicroModule(av[1].AsInteger, Item);
  end
  else RemoveSpecialMicroModule(Item);
end;
{ @end $626978 }

{ @routine $626D18 SF_ModuleToEquipment }
procedure SF_ModuleToEquipment(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  RawItem: TItem;
  Item: TEquipment;
  Attempts, BasePriority, Step, Index, Level: Integer;
  RandomMode: Boolean;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ModuleToEquipment');
  RandomMode := (High(av) = 1) or ((av[1].ValueKind = value_uint32) and (av[1].AsDword > $FFFF));
  if RandomMode then Obj := TObject(av[1].AsDword) else Obj := TObject(av[2].AsDword);
  RawItem := nil;
  if Obj is TItem then RawItem := TItem(Obj);
  if Obj is TScriptItem then RawItem := TScriptItem(Obj).Item;
  if (RawItem <> nil) and (RawItem is TEquipment) then Item := TEquipment(RawItem)
  else raise Exception.Create('Error.Script ModuleToEquipment - not eq');
  if RandomMode then
  begin
    if High(av) > 1 then Obj := TObject(av[2].AsDword) else Obj := nil;
    if High(av) > 2 then Level := av[3].AsInteger else Level := Galaxy.TechLevel;
    Attempts := 0;
    Step := 0;
    repeat
      BasePriority := Round(RemapClamped(Level, 3, 7, 70, 0));
      Index := Galaxy.SelectMicroModuleForEquipment(BasePriority + 5 * Step, Min(BasePriority + 40 + 20 * Step, 100), AdvanceRandomSeed(Galaxy.RandomState), Obj, Item);
      if CanInstallMicroModule(Index, Item) then
      begin
        Item.MicroModuleIndex := 0;
        ApplyMicroModule(Index, Item);
        av[0].AsInteger := Index;
        Exit;
      end;
      Inc(Attempts);
      if Attempts mod 10 = 0 then Inc(Step);
    until Attempts > 50;
    av[0].AsInteger := -1;
  end
  else if av[1].AsInteger >= 0 then
  begin
    Item.MicroModuleIndex := 0;
    ApplyMicroModule(av[1].AsInteger, Item);
  end
  else RemoveMicroModule(Item);
end;
{ @end $626D18 }

{ @routine $626FB8 SF_EqSpecial }
procedure SF_EqSpecial(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Missile: TMissile;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EqSpecial');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TMissile then
  begin
    Missile := TMissile(Obj);
    av[0].AsInteger := Missile.SpecialModuleIndex - 1;
    if High(av) > 1 then Missile.SpecialModuleIndex := av[2].AsInteger + 1;
  end;
  if Obj is TEquipment then Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then Item := (Obj as TScriptItem).Item as TEquipment
  else Exit;
  av[0].AsInteger := Item.SpecialModuleIndex - 1;
  if High(av) > 1 then Item.SpecialModuleIndex := av[2].AsInteger + 1;
end;
{ @end $626FB8 }

{ @routine $6270E0 SF_EqModule }
procedure SF_EqModule(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Missile: TMissile;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EqModule');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TMissile then
  begin
    Missile := TMissile(Obj);
    av[0].AsInteger := Missile.MicroModuleIndex - 1;
    if High(av) > 1 then Missile.MicroModuleIndex := av[2].AsInteger + 1;
  end;
  if Obj is TEquipment then Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then Item := (Obj as TScriptItem).Item as TEquipment
  else Exit;
  av[0].AsInteger := Item.MicroModuleIndex - 1;
  if High(av) > 1 then Item.MicroModuleIndex := av[2].AsInteger + 1;
end;
{ @end $6270E0 }

{ @routine $627208 SF_MayAddBonusToEq }
procedure SF_MayAddBonusToEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script MayAddModuleToEq');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  Obj := TObject(av[2].AsDword);
  if Obj is TEquipment then Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then Item := (Obj as TScriptItem).Item as TEquipment
  else Exit;
  if (Item.SpecialModuleIndex <> 0) and MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then Exit;
  if Item is TWeapon then av[0].AsInteger := Ord(IsBonusCompatibleWithWeapon(Index, TWeapon(Item)))
  else if Item is THull then av[0].AsInteger := Ord(IsBonusCompatibleWithHull(Index, THull(Item)))
  else av[0].AsInteger := Ord(IsBonusCompatibleWithEquipment(Index, Item));
end;
{ @end $627208 }

{ @routine $627370 SF_BuildListOfMMByPriority }
procedure SF_BuildListOfMMByPriority(av: array of TVarEC; code: TCodeEC);
var
  I, LowPriority, HighPriority, Count: Integer;
  Value: TVarEC;
  ExcludeRacial: Boolean;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script BuildListOfMMByPriority');
  if av[1].ValueKind = value_empty then
  begin
    av[1].ConvertToKind(value_array);
    av[1].AsArray := TVarArrayEC.Create;
  end
  else if av[1].ValueKind <> value_array then raise Exception.Create('Error.Script BuildListOfMMByPriority - not array');
  if High(av) > 3 then ExcludeRacial := av[4].AsInteger <> 0 else ExcludeRacial := True;
  if av[2].AsInteger < av[3].AsInteger then
  begin
    HighPriority := av[3].AsInteger;
    LowPriority := av[2].AsInteger;
  end
  else
  begin
    HighPriority := av[2].AsInteger;
    LowPriority := av[3].AsInteger;
  end;
  av[1].AsArray.Clear;
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    if MicroModuleTemplates[I].SpecialOnly then Continue;
    if (MicroModuleTemplates[I].Priority > HighPriority) or
      (MicroModuleTemplates[I].Priority < LowPriority) or
      ((Byte(ExcludeRacial) and Byte(MicroModuleTemplates[I].RacialRestriction)) <> 0) then Continue;
    Value := TVarEC.Create(value_int32);
    Value.AsInteger := I;
    av[1].AsArray.AddItem(Value);
  end;
  Count := av[1].AsArray.Count;
  av[0].AsInteger := Count;
  if Count = 0 then av[1].AsArray.AddItem(TVarEC.Create(value_empty));
end;
{ @end $627370 }

{ @routine $6277A4 SF_BuildListOfNewShips }
procedure SF_BuildListOfNewShips(av: array of TVarEC; code: TCodeEC);
var
  MinimumId: Cardinal;
  Mask: TShipTypeMask;
  IncludeScripted: Boolean;
  FactionCount: Integer;
  Factions: array of WideString;
  TypeCount: Integer;
  CustomTypes: array of WideString;
  Text: WideString;
  Value: TVarEC;
  I, J, K, L, Count: Integer;
  Star: TStar;
  Planet: TPlanet;
  Ship: TShip;
  OwnerMask: TOwnerMask;

  // @nested $6275E0 CheckShip
  procedure CheckShip(Ship: TShip); // @addr 0x006275E0 @note "Requires SF_BuildListOfNewShips' live frame. The custom-type filter is applied only when the faction filter is enabled."
  var
    Found: Boolean;
    I: Integer;
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
    Value := TVarEC.Create(value_int32);
    Value.AsDword := Cardinal(Ship);
    av[1].AsArray.AddItem(Value);
  end;

  // @nested $62776C CheckItem
  procedure CheckItem(Item: TItem); // @addr 0x0062776C @note "Requires SF_BuildListOfNewShips' live frame. Ignores nil and non-Tranclucator artefacts."
  begin
    if Item = nil then Exit;
    if not (Item is TArtefactTranclucator) then Exit;
    CheckShip(TArtefactTranclucator(Item).Ship as TShip);
  end;

begin
  if High(av) < 2 then raise Exception.Create('Error.Script BuildListOfNewShips');
  if av[1].ValueKind = value_empty then
  begin
    av[1].ConvertToKind(value_array);
    av[1].AsArray := TVarArrayEC.Create;
  end
  else if av[1].ValueKind <> value_array then raise Exception.Create('Error.Script BuildListOfNewShips - not array');
  av[1].AsArray.Clear;
  MinimumId := av[2].AsDword;
  if (High(av) > 2) and (av[3].AsDword <> 0) then Word(Mask) := av[3].AsDword else Mask := [ship_dominator..ship_warrior, station_ranger_center..station_custom];
  // Parsed by the native routine but never consulted.
  if (High(av) > 3) and (av[4].AsDword <> 0) then OwnerMask := TOwnerMask(Byte(av[4].AsDword)) else OwnerMask := [owner_maloc..owner_pirate];
  IncludeScripted := False;
  if (High(av) > 4) and (av[5].AsInteger <> 0) then IncludeScripted := True;
  if High(av) > 5 then
  begin
    Text := av[6].AsString;
    if Text = '' then begin FactionCount := 0; Factions := nil; end
    else
    begin
      FactionCount := CountDelimitedPartsW(Text, ',');
      SetLength(Factions, FactionCount);
      for I := 0 to FactionCount - 1 do Factions[I] := ExtractDelimitedPartW(Text, I, ',');
    end;
    if High(av) > 6 then
    begin
      Text := av[7].AsString;
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
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if Ship.TypeId <> ship_warrior then CheckShip(Ship);
    end;
    if ship_warrior in Mask then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        for K := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := Planet.Warriors[K];
          CheckShip(Ship);
        end;
      end;
  end;
  if ship_tranclucator in Mask then
  begin
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Galaxy.Stars[I];
      for J := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[J];
        if Ship.TypeId <> ship_warrior then
          for K := 0 to Ship.Artefacts.Count - 1 do CheckItem(TItem(Ship.Artefacts[K]));
      end;
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        for K := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := Planet.Warriors[K];
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
  Count := av[1].AsArray.Count;
  av[0].AsInteger := Count;
  if Count = 0 then av[1].AsArray.AddItem(TVarEC.Create(value_empty));
end;
{ @end $6277A4 }

{ @routine $627E80 SF_PlanetToStar }
procedure SF_PlanetToStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetToStar');
  av[0].AsDword := Cardinal(TPlanet(av[1].AsDword).CurrentStar);
end;
{ @end $627E80 }

{ @routine $627EF4 SF_Chameleon }
procedure SF_Chameleon(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script Chameleon');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Ship := GetPlayer;
  if (High(av) > 1) and (av[2].AsString <> '') then
  begin
    if av[2].AsString = 'GraphName' then
    begin
      av[0].AsString := Ship.GraphName;
      Exit;
    end;
    ReleaseSpaceObject(Ship.Graphic);
    RetainSpaceObject(Ship.Graphic, CreateSpaceObjectByName(ExtractDelimitedPartW(av[2].AsString, 0, '.'), av[2].AsString, Point(0, 0)));
    Ship.GraphName := av[2].AsString;
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
  if (High(av) > 2) and (av[3].AsInteger <> 0) and (CurrentScreenId = screen_star_map) then
  begin
    RequestedScreenId := screen_star_map;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;
{ @end $627EF4 }

{ @routine $628150 SF_IsChameleon }
procedure SF_IsChameleon(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script IsChameleon');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Ship := GetPlayer;
  if Ship.ScriptChameleon then av[0].AsInteger := 1 else av[0].AsInteger := 0;
end;
{ @end $628150 }

{ @routine $6281E0 SF_PlayerChameleonCharges }
procedure SF_PlayerChameleonCharges(av: array of TVarEC; code: TCodeEC);
var
  Index: TDominatorSeries;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlayerChameleonCharges');
  Index := TDominatorSeries(av[1].AsInteger);
  av[0].AsInteger := GetPlayer.ChameleonCharges[Index];
  if High(av) > 1 then GetPlayer.ChameleonCharges[Index] := av[2].AsInteger;
end;
{ @end $6281E0 }

{ @routine $628290 SF_PlayerChameleonCurType }
procedure SF_PlayerChameleonCurType(av: array of TVarEC; code: TCodeEC);
begin
  if not GetPlayer.ChameleonActive then av[0].AsInteger := -1
  else av[0].AsInteger := Ord(GetPlayer.ChameleonSeries);
  if High(av) > 0 then
    if av[1].AsInteger < 0 then GetPlayer.ChameleonActive := False
    else
    begin
      GetPlayer.ChameleonActive := True;
      GetPlayer.ChameleonSeries := TDominatorSeries(av[1].AsInteger);
    end;
end;
{ @end $628290 }

{ @routine $628320 SF_PlayerChameleonDetected }
procedure SF_PlayerChameleonDetected(av: array of TVarEC; code: TCodeEC);
var
  Index: TDominatorSeries;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlayerChameleonDetected');
  Index := TDominatorSeries(av[1].AsInteger);
  av[0].AsInteger := Ord(GetPlayer.ChameleonDetected[Index]);
  if High(av) > 1 then GetPlayer.ChameleonDetected[Index] := av[2].AsInteger <> 0;
end;
{ @end $628320 }

{ @routine $6283D8 SF_PlayerLogicChameleon }
procedure SF_PlayerLogicChameleon(av: array of TVarEC; code: TCodeEC);
var
  Index: TDominatorSeries;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlayerLogicChameleon');
  Index := TDominatorSeries(av[1].AsInteger);
  av[0].AsInteger := GetPlayer.ChameleonLogic[Index];
  if High(av) > 1 then GetPlayer.ChameleonLogic[Index] := av[2].AsInteger;
end;
{ @end $6283D8 }

{ @routine $628488 SF_SwitchToMirrorImage }
procedure SF_SwitchToMirrorImage(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Hull: THull;
  Mirror: TShip2SE;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SwitchToMirrorImage');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Ship := GetPlayer;
  if Ship.ScriptChameleon and (av[2].ValueKind = value_string) then
  begin
    Mirror := CreateSpaceObjectByName('Ship2', av[2].AsString, Point(0, 0)) as TShip2SE;
    Mirror.CopyDataFromMirrorImage(Ship.Graphic);
    Mirror.Free;
    Ship.GraphName := Ship.Graphic.GraphKey;
    Exit;
  end;
  Hull := Ship.GetHull;
  if Hull.HullType <> hull_special then raise Exception.Create('Error.Script SwitchToMirrorImage: Not a special hull');
  Hull.SpecialModuleIndex := av[2].AsInteger + 1;
  if Ship.ScriptChameleon or Ship.ChameleonActive or Ship.GraphDominator then Exit;
  Mirror := CreateSpaceObjectByName('Ship2', 'Ship.Akrin.' + Hull.GetSpecialKindGraph, Point(0, 0)) as TShip2SE;
  Mirror.CopyDataFromMirrorImage(Ship.Graphic);
  Mirror.Free;
  Ship.GraphName := Ship.Graphic.GraphKey;
end;
{ @end $628488 }

{ @routine $6286E8 SF_EquipmentImageName }
procedure SF_EquipmentImageName(av: array of TVarEC; code: TCodeEC);
var
  TypeOrItem: Cardinal;
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EquipmentImageName');
  if (av[1].ValueKind = value_string) and (av[1].AsString = 'GetImagePath') then
  begin
    if High(av) < 2 then raise Exception.Create('Error.Script EquipmentImageName 2');
    Item := TItem(av[2].AsDword);
    av[0].AsString := Item.GetBitmapResourceName;
    Exit;
  end;
  TypeOrItem := av[1].AsDword;
  if TypeOrItem < 256 then
  begin
    av[0].AsString := ItemTypeNames[TItemType(TypeOrItem)];
    Exit;
  end;
  Obj := TObject(TypeOrItem);
  av[0].AsString := '';
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TEquipment) then
  begin
    av[0].AsString := (Item as TEquipment).ConfigBlockName;
    if High(av) > 1 then
    begin
      TEquipment(Item).ConfigBlockName := av[2].AsString;
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
    av[0].AsString := (Obj as TTranclucator).ArtefactSystemName;
    if High(av) > 1 then (Obj as TTranclucator).ArtefactSystemName := av[2].AsString;
  end;
end;
{ @end $6286E8 }

{ @routine $62899C SF_StarFonImage }
procedure SF_StarFonImage(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarFonImage');
  Star := TStar(av[1].AsDword);
  av[0].AsInteger := Star.BackgroundImage;
  if High(av) > 1 then Star.BackgroundImage := av[2].AsInteger;
end;
{ @end $62899C }

{ @routine $628A28 SF_ExtremalTakeOff }
procedure SF_ExtremalTakeOff(av: array of TVarEC; code: TCodeEC);
begin
  ScriptTakeoffRequested := True;
end;
{ @end $628A28 }

{ @routine $628A50 SF_ForceNextDay }
procedure SF_ForceNextDay(av: array of TVarEC; code: TCodeEC);
begin
  ScriptEndTurnRequested := True;
end;
{ @end $628A50 }

{ @routine $628A78 SF_ScriptActionsRun }
procedure SF_ScriptActionsRun(av: array of TVarEC; code: TCodeEC);
begin
  ScriptRequestThread.Execute;
end;
{ @end $628A78 }

{ @routine $628AA4 SF_StarListToPlanetList }
procedure SF_StarListToPlanetList(av: array of TVarEC; code: TCodeEC);
var
  I, J, Priority, Count, EnemyDistance: Integer;
  Score, Penalty: Double;
  Star: TStar;
  Planet, BestPlanet: TPlanet;
  Temp: TVarEC;
  ScorePtr: PDouble;
  Scores: TList;
  Weights: array[owner_maloc..owner_gaal] of Integer;
begin
  if High(av) < 6 then raise Exception.Create('Error.Script StarListToPlanetList');
  if av[1].ValueKind <> value_array then raise Exception.Create('Error.Script StarListToPlanetList - not array');
  if (High(av) > 6) and (av[7].ValueKind <> value_array) then raise Exception.Create('Error.Script StarListToPlanetList - not array');
  Penalty := 0;
  if High(av) > 7 then Penalty := av[8].AsInteger / 100;
  Weights[owner_maloc] := av[2].AsInteger;
  Weights[owner_peleng] := av[3].AsInteger;
  Weights[owner_human] := av[4].AsInteger;
  Weights[owner_feyan] := av[5].AsInteger;
  Weights[owner_gaal] := av[6].AsInteger;
  Count := av[1].AsArray.Count;
  for I := Count - 1 downto 0 do
  begin
    Star := TStar(av[1].AsArray[I].AsDword);
    Priority := 0;
    BestPlanet := nil;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := Star.Planets[J];
      if Planet.OwnerId in [owner_maloc..owner_gaal] then
        if Weights[Planet.OwnerId] > Priority then
        begin
          BestPlanet := Planet;
          Priority := Weights[Planet.OwnerId];
        end;
    end;
    if Priority > 0 then av[1].AsArray[I].AsDword := Cardinal(BestPlanet)
    else av[1].AsArray.Delete(I);
  end;
  Count := av[1].AsArray.Count;
  if Count > 0 then
  begin
    Scores := TList.Create;
    for I := 0 to Count - 1 do
    begin
      Planet := TPlanet(av[1].AsArray[I].AsDword);
      Star := Planet.CurrentStar;
      J := 0;
      while (J < Galaxy.Stars.Count) and
        ((Star.StarDistances[J].Star as TStar).ControlFaction <> faction_dominators) and
        ((Star.StarDistances[J].Star as TStar).Status.CustomFaction = '') do Inc(J);
      if J = Galaxy.Stars.Count then EnemyDistance := 1 else EnemyDistance := Star.StarDistances[J].Distance;
      Score := EnemyDistance * Weights[Planet.OwnerId];
      if High(av) > 6 then
        for J := 0 to av[7].AsArray.Count - 1 do
          if (TStar(av[7].AsArray[J].AsDword) = Star) or
            (av[7].AsArray[J].AsDword = Star.Id) then Score := Score * Penalty;
      New(ScorePtr);
      ScorePtr^ := Score;
      Scores.Add(ScorePtr);
    end;
    for I := 1 to Count - 1 do
      for J := Count - 1 downto I do
        if PDouble(Scores[J])^ > PDouble(Scores[J - 1])^ then
        begin
          Temp := av[1].AsArray[J];
          av[1].AsArray[J] := av[1].AsArray[J - 1];
          av[1].AsArray[J - 1] := Temp;
          Score := PDouble(Scores[J])^;
          PDouble(Scores[J])^ := PDouble(Scores[J - 1])^;
          PDouble(Scores[J - 1])^ := Score;
        end;
    for I := 0 to Scores.Count - 1 do Dispose(PDouble(Scores[I]));
    Scores.Free;
  end;
  av[0].AsInteger := Count;
  if Count = 0 then av[1].AsArray.AddItem(TVarEC.Create(value_empty));
end;
{ @end $628AA4 }

{ @routine $628FC4 SF_EndGame }
procedure SF_EndGame(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) > 0 then
  begin
    GameEndReason := av[1].AsInteger;
    RequestedScreenId := screen_game_end;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end
  else
  begin
    ScoreScreen.RecordPlayerResult(GetPlayer <> nil);
    AboutScreen.ReturnToScores := True;
    RequestedScreenId := screen_about;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;
{ @end $628FC4 }

{ @routine $629064 SF_CustomWin }
procedure SF_CustomWin(av: array of TVarEC; code: TCodeEC);
var
  Event: TGalaxyEvent;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomWin');
  Event := AddGalaxyEvent('CustomWin');
  Event.AddTextData(av[1].AsString);
  if High(av) > 1 then Event.AddTextData(av[2].AsString)
  else Event.AddTextData('');
  GameEndReason := game_end_default;
  RequestedScreenId := screen_game_end;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $629064 }

{ @routine $629188 SF_CustomLose }
procedure SF_CustomLose(av: array of TVarEC; code: TCodeEC);
var
  Event: TGalaxyEvent;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomLose');
  Event := AddGalaxyEvent('CustomLose');
  Event.AddTextData(av[1].AsString);
  if High(av) > 1 then Event.AddTextData(av[2].AsString)
  else Event.AddTextData('');
  GameEndReason := game_end_default;
  RequestedScreenId := screen_game_end;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $629188 }

{ @routine $6292B0 SF_PirateWin }
procedure SF_PirateWin(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.PirateWinType;
  if (High(av) > 0) then
    if (av[1].AsInteger >= 1) then
    if (av[1].AsInteger <= 5) then
  begin
    Galaxy.PirateWinTurn := Galaxy.CurrentTurn;
    Galaxy.PirateWinType := av[1].AsInteger;
  end;
end;
{ @end $6292B0 }

{ @routine $629330 SF_StartVideo }
procedure SF_StartVideo(av: array of TVarEC; code: TCodeEC);
var
  Request: PScriptVDRequest;
  SavedCategory: WideString;
  Video: TxvidGI;
begin
  if High(av) = 0 then
  begin
    av[0].AsInteger := QueuedVideos.Count;
    Exit;
  end;

  if High(av) < 2 then raise Exception.Create('Error.Script StartVideo');
  if GetInnermostScreenLoop = ShipScreen then
  begin
    ShipScreen.ShipLoopSound.SetVolume(0);
    Video := ShipScreen.GetByName('Film') as TxvidGI;
    Video.SetActive(True);
    if not Video.ImageOpen(av[1].AsString, False) then
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
      MusicManager.PlayCategory(av[2].AsString);
      while not MusicManager.IsPlaying do SysUtils.Sleep(1);
      MusicManager.CategoryOverride := SavedCategory;
    end;
    ShipScreen.ScriptVideoStartedAt := timeGetTime;
    if ShipScreen.ScriptVideoTimer <> 0 then
    begin
      ShipScreen.CancelCallbackTimer(ShipScreen.ScriptVideoTimer);
      ShipScreen.ScriptVideoTimer := 0;
    end;
    ShipScreen.ScriptVideoTimer := ShipScreen.ScheduleCallbackTimer(5, 5, ShipScreen.AdvanceScriptVideo);
  end
  else
  begin
    New(Request);
    Request.Video := av[1].AsString;
    Request.Soundtrack := av[2].AsString;
    Request.Script := CurrentScript;
    QueuedVideos.Add(Request);
    if CurrentScript <> nil then CurrentScript.InitCode.LocalVar.NamedItems['GVideoStatus'].AsInteger := 1;
    RequestedScreenId := CurrentScreenId;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;
{ @end $629330 }

{ @routine $629654 SF_StartMusic }
procedure SF_StartMusic(av: array of TVarEC; code: TCodeEC);
var
  SavedCategory: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StartMusic');
  if not MusicEnabled then Exit;
  if GetInnermostScreenLoop = StarMapScreen then StarMapScreen.BattleMusicSelected := True;
  MusicManager.StopImmediately;
  while MusicManager.IsPlaying do SysUtils.Sleep(1);
  if CountDelimitedPartsW(av[1].AsString, '.') > 1 then MusicManager.PlayFile(av[1].AsString)
  else
  begin
    SavedCategory := MusicManager.CategoryOverride;
    MusicManager.CategoryOverride := '';
    MusicManager.PlayCategory(av[1].AsString);
    MusicManager.CategoryOverride := SavedCategory;
  end;
end;
{ @end $629654 }

{ @routine $6297AC SF_MusicControls }
procedure SF_MusicControls(av: array of TVarEC; code: TCodeEC);
var
  Command: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MusicControls');
  Command := av[1].AsString;
  if Command = 'SetPlayListOverride' then
  begin
    if High(av) < 2 then raise Exception.Create('Error.Script MusicControls 2');
    MusicManager.CategoryOverride := av[2].AsString;
    if MusicEnabled and (MusicManager.CategoryOverride <> '') then MusicManager.PlayCategory('');
  end
  else if Command = 'GetPlayListOverride' then av[0].AsString := MusicManager.CategoryOverride
  else if Command = 'GetCurFile' then av[0].AsString := MusicManager.Current.GetFileName
  else if Command = 'StopCurFile' then MusicManager.RequestFadeOut;
end;
{ @end $6297AC }

{ @routine $6299E8 SF_NoComeKlingToStar }
procedure SF_NoComeKlingToStar(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoComeKlingToStar');
  Star := TStar(av[1].AsDword);
  if Star = nil then Exit;
  if Star.NoComeKling then av[0].AsInteger := 1 else av[0].AsInteger := 0;
  if High(av) > 1 then Star.NoComeKling := av[2].AsInteger <> 0;
end;
{ @end $6299E8 }

{ @routine $629A98 SF_NoDropToShip }
procedure SF_NoDropToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoDropToShip');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if Ship.NoDrop then av[0].AsInteger := 1 else av[0].AsInteger := 0;
  if High(av) > 1 then Ship.NoDrop := av[2].AsInteger <> 0;
end;
{ @end $629A98 }

{ @routine $629B44 SF_NoTargetToShip }
procedure SF_NoTargetToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoTargetToShip');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  av[0].AsInteger := Ship.TargetingRestriction;
  if High(av) > 1 then Ship.TargetingRestriction := av[2].AsInteger;
end;
{ @end $629B44 }

{ @routine $629BD8 SF_NoTalkToShip }
procedure SF_NoTalkToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
  begin
    av[0].AsInteger := Ord(GetPlayer.TalkLocked);
    Exit;
  end;
  if (High(av) = 1) and ((av[1].ValueKind <> value_uint32) or (av[1].AsDword < $FF)) then
  begin
    av[0].AsInteger := Ord(GetPlayer.TalkLocked);
    GetPlayer.TalkLocked := av[1].AsInteger <> 0;
    Exit;
  end;
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if Ship.NoTalk then av[0].AsInteger := 1 else av[0].AsInteger := 0;
  if High(av) > 1 then Ship.NoTalk := av[2].AsInteger <> 0;
end;
{ @end $629BD8 }

{ @routine $629CB4 SF_NoScanToShip }
procedure SF_NoScanToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
  begin
    av[0].AsInteger := Ord(GetPlayer.ScanLocked);
    Exit;
  end;
  if (High(av) = 1) and ((av[1].ValueKind <> value_uint32) or (av[1].AsDword < $FF)) then
  begin
    av[0].AsInteger := Ord(GetPlayer.ScanLocked);
    GetPlayer.ScanLocked := av[1].AsInteger <> 0;
    Exit;
  end;
  Ship := TShip(av[1].AsDword);
  if Ship = nil then Exit;
  if Ship.NoScan then av[0].AsInteger := 1 else av[0].AsInteger := 0;
  if High(av) > 1 then Ship.NoScan := av[2].AsInteger <> 0;
end;
{ @end $629CB4 }

{ @routine $629D90 SF_NoJump }
procedure SF_NoJump(av: array of TVarEC; code: TCodeEC);
begin
  if GetPlayer.NoJump then av[0].AsInteger := 1 else av[0].AsInteger := 0;
  if High(av) > 0 then GetPlayer.NoJump := av[1].AsInteger <> 0;
end;
{ @end $629D90 }

{ @routine $629DF8 SF_NoLanding }
procedure SF_NoLanding(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoLanding');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TPlanet then
  begin
    if (Obj as TPlanet).NoLanding then av[0].AsInteger := 1;
    if High(av) > 1 then (Obj as TPlanet).NoLanding := av[2].AsInteger <> 0;
  end
  else if Obj is TRuins then
  begin
    if (Obj as TRuins).NoLanding then av[0].AsInteger := 1;
    if High(av) > 1 then (Obj as TRuins).NoLanding := av[2].AsInteger <> 0;
  end;
end;
{ @end $629DF8 }

{ @routine $629F24 SF_NoShopUpdate }
procedure SF_NoShopUpdate(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoShopUpdate');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TPlanet then
  begin
    av[0].AsInteger := (Obj as TPlanet).ShopUpdateMode;
    if High(av) > 1 then (Obj as TPlanet).ShopUpdateMode := av[2].AsInteger;
  end
  else if Obj is TRuins then
  begin
    av[0].AsInteger := Ord((Obj as TRuins).ShopUpdateMode);
    if High(av) > 1 then (Obj as TRuins).ShopUpdateMode := TShopUpdateMode(av[2].AsInteger);
  end;
end;
{ @end $629F24 }

{ @routine $62A03C SF_PlanetExtraFlags }
procedure SF_PlanetExtraFlags(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetExtraFlags');
  av[0].AsInteger := 0;
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Ord(Planet.NoAutomaticShipSpawning) + 2 * Ord(Planet.NoRandomEvents);
  if High(av) > 1 then
  begin
    Planet.NoAutomaticShipSpawning := av[2].AsInteger and 1 > 0;
    Planet.NoRandomEvents := av[2].AsInteger and 2 > 0;
  end;
end;
{ @end $62A03C }

{ @routine $62A108 SF_NoDropItem }
procedure SF_NoDropItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script NoDropItem');
  av[0].AsInteger := 0;
  Item := nil;
  Obj := TObject(av[1].AsDword);
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    av[0].AsInteger := Item.NoDropFlag;
    if High(av) > 1 then Item.NoDropFlag := av[2].AsInteger;
  end;
end;
{ @end $62A108 }

{ @routine $62A1C8 SF_CanSellItem }
procedure SF_CanSellItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CanSellItem');
  av[0].AsInteger := 1;
  Binding := nil;
  Obj := TObject(av[1].AsDword);
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    if not Binding.CanSell then av[0].AsInteger := 0;
    if High(av) > 1 then Binding.CanSell := av[2].AsInteger <> 0;
  end;
end;
{ @end $62A1C8 }

{ @routine $62A298 SF_TruceBetweenShips }
procedure SF_TruceBetweenShips(av: array of TVarEC; code: TCodeEC);
var
  Ship1, Ship2, Partner1, Partner2: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script TruceBetweenShips');
  Ship1 := TShip(av[1].AsDword);
  Ship2 := TShip(av[2].AsDword);
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
{ @end $62A298 }

{ @routine $62A3AC SF_ShipInPrison }
procedure SF_ShipInPrison(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInPrison');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship.CurrentPlanet <> nil then
  begin
    if GetPlayer = Ship then
    begin
      if GetPlayer.InPrison then av[0].AsInteger := 1;
    end
    else
      case Ship.TypeId of
        ship_ranger:
          begin
            av[0].AsInteger := (Ship as TRanger).PrisonTermRemaining;
            if High(av) > 1 then (Ship as TRanger).PrisonTermRemaining := av[2].AsInteger;
          end;
        ship_pirate:
          begin
            av[0].AsInteger := (Ship as TPirate).PrisonTermRemaining;
            if High(av) > 1 then (Ship as TPirate).PrisonTermRemaining := av[2].AsInteger;
          end;
      end;
  end;
end;
{ @end $62A3AC }

{ @routine $62A4E4 SF_ShipPartners }
procedure SF_ShipPartners(av: array of TVarEC; code: TCodeEC);
var
  Ship, Partner: TShip;
  Index, Wanted, Found: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipPartners');
  Ship := TShip(av[1].AsDword);
  Wanted := -1;
  Found := -1;
  av[0].AsDword := 0;
  if High(av) > 1 then Wanted := av[2].AsInteger;
  for Index := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Partner := Galaxy.Rangers[Index];
    if Partner.PartnerShip = Ship then
    begin
      Inc(Found);
      if Found = Wanted then
      begin
        av[0].AsDword := Cardinal(Partner);
        Exit;
      end;
    end;
  end;
  if High(av) = 1 then av[0].AsInteger := Found + 1;
end;
{ @end $62A4E4 }

{ @routine $62A5E4 SF_PlayerPirates }
procedure SF_PlayerPirates(av: array of TVarEC; code: TCodeEC);
var
  Index, Count: Integer;
begin
  if GetPlayer.PiratePartners = nil then Count := 0 else Count := GetPlayer.PiratePartners.Count;
  if High(av) < 1 then
  begin
    av[0].AsInteger := Count;
    Exit;
  end;
    Index := av[1].AsInteger;
    if (Index < 0) or (Index >= Count) then av[0].AsDword := 0
    else av[0].AsDword := Cardinal(GetPlayer.PiratePartners[Index]);
end;
{ @end $62A5E4 }

{ @routine $62A674 SF_ShipIsPartner }
procedure SF_ShipIsPartner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipIsPartner');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    if (High(av) > 1) and (av[2].AsInteger <> 0) then av[0].AsInteger := Ship.PartnershipDaysRemaining
    else av[0].AsDword := Cardinal(Ship.PartnerShip);
  end;
end;
{ @end $62A674 }

{ @routine $62A714 SF_ShipFreeSpace }
procedure SF_ShipFreeSpace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipFreeSpace');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then av[0].AsInteger := Ship.CargoFreeSpace;
end;
{ @end $62A714 }

{ @routine $62A790 SF_ShipWealth }
procedure SF_ShipWealth(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script ShipWealth');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then av[0].AsInteger := Ship.Wealth;
end;
{ @end $62A790 }

{ @routine $62A808 SF_DomiksDefeated }
procedure SF_DomiksDefeated(av: array of TVarEC; code: TCodeEC);
var
  Series: TDominatorSeries;
begin
  if High(av) < 1 then
  begin
    if not Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]) then av[0].AsInteger := 1
    else av[0].AsInteger := 0;
  end
  else
  begin
    Series := TDominatorSeries(av[1].AsInteger);
    case Series of
      series_blazer:
        if Galaxy.BlazerSeriesResolvedTurn = 0 then av[0].AsInteger := 0
        else if (Galaxy.BlazerLandingPlanetId <> 0) and (BlazerShip <> nil) then av[0].AsInteger := 3
        else if Galaxy.BlazerSelfDestructTurn <> 0 then av[0].AsInteger := 2
        else av[0].AsInteger := 1;
      series_keller:
        if Galaxy.KellerSeriesResolvedTurn = 0 then av[0].AsInteger := 0
        else if Galaxy.KellerLeaveTurn <> 0 then av[0].AsInteger := 2
        else if Galaxy.KellerResearchTargetStarId <> 0 then av[0].AsInteger := 3
        else av[0].AsInteger := 1;
      series_terron:
        if Galaxy.TerronSeriesResolvedTurn = 0 then av[0].AsInteger := 0
        else if Galaxy.TerronToStarTurn <> 0 then av[0].AsInteger := 2
        else if Galaxy.TerronLandingLockTurn <> 0 then av[0].AsInteger := 3
        else av[0].AsInteger := 1;
    else av[0].AsInteger := 0;
    end;
  end;
end;
{ @end $62A808 }

{ @routine $62A9DC SF_CoalitionDefeated }
procedure SF_CoalitionDefeated(av: array of TVarEC; code: TCodeEC);
begin
  if Galaxy.CoalitionDefeatedTurn <> 0 then av[0].AsInteger := 1 else av[0].AsInteger := 0;
  if High(av) > 0 then
  begin
    if av[1].AsInteger = 1 then Galaxy.CoalitionDefeatedTurn := Galaxy.CurrentTurn
    else Galaxy.CoalitionDefeatedTurn := 0;
  end;
end;
{ @end $62A9DC }

{ @routine $62AA60 SF_ShipRefuel }
procedure SF_ShipRefuel(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRefuel');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
    if Ship.GetFuelTanks <> nil then Ship.GetFuelTanks.Fuel := Ship.GetFuelTanks.Capacity;
end;
{ @end $62AA60 }

{ @routine $62AAEC SF_ShipRepairEq }
procedure SF_ShipRepairEq(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Equipment: TEquipment;
  Artefact: TArtefact;
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRepairEq');
  Ship := TShip(av[1].AsDword);
  for Index := Ship.Inventory.Count - 1 downto 1 do
  begin
    Equipment := Ship.Inventory[Index];
    if Equipment.EquippedFlag <> 0 then Equipment.Repair;
  end;
  for Index := 0 to Ship.Artefacts.Count - 1 do
  begin
    Artefact := Ship.Artefacts[Index];
    if Artefact.EquippedFlag <> 0 then Artefact.Repair;
  end;
end;
{ @end $62AAEC }

{ @routine $62ABB4 SF_ItemInScript }
procedure SF_ItemInScript(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemInScript');
  Item := TItem(av[1].AsDword);
  if (Item <> nil) and (Item.ScriptItem <> nil) then
    av[0].AsInteger := Ord(TScriptItem(Item.ScriptItem).Name = '') + 1
  else av[0].AsInteger := 0;
end;
{ @end $62ABB4 }

{ @routine $62ACBC SF_FindPlanetByAdvancement }
procedure SF_FindPlanetByAdvancement(av: array of TVarEC; code: TCodeEC);
var
  Score: Integer;
  Planet: TPlanet;
  MaxScore, MinScore, TargetScore, BestDistance, Percent, I, J, Faction: Integer;
  Star: TStar;
  BestPlanet: TPlanet;
  // @nested $62AC50 CalcValue
  procedure CalcValue; // @addr 0x0062AC50 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested in SF_FindPlanetByAdvancement; reads its selected planet and writes its local score."
  var
    I: TResearchTrack;
  begin
    Score := 0;
    for I := Low(TResearchTrack) to High(TResearchTrack) do Score := Score + Planet.InventionLevels[I];
    for I := research_hull to research_main_technology do Score := Score + 2 * Planet.InventionLevels[I];
    Score := Score + 8 * Planet.InventionLevels[research_main_technology] + 4 * Planet.InventionLevels[research_hull] + 2 * Planet.InventionLevels[research_repair_robot];
  end;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FindPlanetByAdvancement');
  Faction := 0;
  if High(av) > 1 then Faction := av[2].AsInteger;
  Percent := Max(Min(av[1].AsInteger, 100), 0);
  MaxScore := 0;
  MinScore := 1000;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if (Faction < 0) or ((TStarFaction(Faction) = Star.ControlFaction) and (Star.Status.CustomFaction = '')) then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        if Planet.OwnerId = owner_uninhabited then Continue;
        CalcValue;
        MaxScore := Max(Score, MaxScore);
        MinScore := Min(Score, MinScore);
      end;
  end;
  TargetScore := MinScore + Round(Percent * (MaxScore - MinScore) / 100);
  BestDistance := 0;
  BestPlanet := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if (Faction < 0) or ((TStarFaction(Faction) = Star.ControlFaction) and (Star.Status.CustomFaction = '')) then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        if Planet.OwnerId = owner_uninhabited then Continue;
        CalcValue;
        if (BestPlanet = nil) or (Abs(Score - TargetScore) < BestDistance) then
        begin
          BestPlanet := Planet;
          BestDistance := Abs(Score - TargetScore);
        end;
      end;
  end;
  av[0].AsDword := Cardinal(BestPlanet);
end;
{ @end $62ACBC }

{ @routine $62AF14 SF_StarListToTransitPlanetList }
procedure SF_StarListToTransitPlanetList(av: array of TVarEC; code: TCodeEC);
var
  I, J, K, Unused, Count, DirectDistance, Detour, Limit, BaseDistance: Integer;
  Score, BestScore, Penalty: Double;
  Star: TStar;
  // Unused four-byte slot; original type is unknown.
  UnknownLocal: array[0..3] of Byte;
  Origin, Destination: TStar;
  Planet, BestPlanet: TPlanet;
  Temp: TVarEC;
  ScorePtr: PDouble;
  Scores: TList;
  Weights: array[0..4] of Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script StarListToTransitPlanetList');
  BaseDistance := 10;
  Origin := TStar(av[2].AsDword);
  Destination := TStar(av[3].AsDword);
  Limit := BaseDistance + av[4].AsInteger;
  DirectDistance := Round(PointDistance(Origin.Position, Destination.Position));
  if av[1].ValueKind <> value_array then raise Exception.Create('Error.Script StarListToTransitPlanetList - not array');
  if High(av) > 8 then
    for I := Low(Weights) to High(Weights) do Weights[I] := av[I + 5].AsInteger
  else
    for I := Low(Weights) to High(Weights) do Weights[I] := 100;
  if (High(av) > 10) and (av[10].ValueKind <> value_array) then raise Exception.Create('Error.Script StarListToTransitPlanetList - not array2');
  Penalty := 0;
  if High(av) > 10 then Penalty := av[11].AsInteger / 100;
  Scores := TList.Create;
  I := 0;
  while I < av[1].AsArray.Count do
  begin
    Star := TStar(av[1].AsArray[I].AsDword);
    Detour := Round(PointDistance(Star.Position, Destination.Position)) + Round(PointDistance(Star.Position, Origin.Position)) - DirectDistance + BaseDistance;
    // Native explicitly clears this otherwise unread local at EBP-$14.
    Unused := 0;
    BestPlanet := nil;
    BestScore := 0;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := Star.Planets[J];
      if Integer(Planet.OwnerId) < 5 then
      begin
        Score := Detour * Weights[Ord(Planet.OwnerId)] / 100;
        if High(av) > 10 then
          for K := 0 to av[10].AsArray.Count - 1 do
            if (av[10].AsArray[K].AsDword = Cardinal(Planet)) or
              (av[10].AsArray[K].AsDword = Planet.Id) then Score := Score * Penalty;
        if ((BestPlanet = nil) and (Limit >= Score) and (Score > 0)) or ((Score < BestScore) and (Score > 0)) then
        begin
          BestPlanet := Planet;
          BestScore := Score;
        end;
      end;
    end;
    if (Star = Origin) or (Star = Destination) or (BestPlanet = nil) then av[1].AsArray.Delete(I)
    else
    begin
      av[1].AsArray[I].AsDword := Cardinal(BestPlanet);
      New(ScorePtr);
      ScorePtr^ := BestScore;
      Scores.Add(ScorePtr);
      Inc(I);
    end;
  end;
  Count := av[1].AsArray.Count;
  if Count > 0 then
  begin
    for I := 1 to Count - 1 do
      for J := Count - 1 downto I do
        if PDouble(Scores[J])^ < PDouble(Scores[J - 1])^ then
        begin
          Temp := av[1].AsArray[J];
          av[1].AsArray[J] := av[1].AsArray[J - 1];
          av[1].AsArray[J - 1] := Temp;
          Score := PDouble(Scores[J])^;
          PDouble(Scores[J])^ := PDouble(Scores[J - 1])^;
          PDouble(Scores[J - 1])^ := Score;
        end;
    for I := 0 to Scores.Count - 1 do Dispose(PDouble(Scores[I]));
    Scores.Free;
  end;
  av[0].AsInteger := Count;
  if Count = 0 then av[1].AsArray.AddItem(TVarEC.Create(value_empty));
end;
{ @end $62AF14 }

{ @routine $62B49C SF_GalaxyEvents }
procedure SF_GalaxyEvents(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.GalaxyEvents.Count;
end;
{ @end $62B49C }

{ @routine $62B4D4 SF_GalaxyEventDate }
procedure SF_GalaxyEventDate(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyEventDate');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
    av[0].AsInteger := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).Turn;
end;
{ @end $62B4D4 }

{ @routine $62B580 SF_GalaxyEventType }
procedure SF_GalaxyEventType(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyEventType');
  av[0].AsString := '';
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
    av[0].AsString := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).EventType;
end;
{ @end $62B580 }

{ @routine $62B62C SF_GalaxyEventData }
procedure SF_GalaxyEventData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyEventData');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
  begin
    if High(av) > 1 then av[0].AsInteger := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).GetData(av[2].AsInteger)
    else av[0].AsInteger := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).Data.Count;
  end;
end;
{ @end $62B62C }

{ @routine $62B714 SF_GalaxyEventsTextData }
procedure SF_GalaxyEventsTextData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GalaxyEventTextData');
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
  begin
    if High(av) > 1 then av[0].AsString := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).GetTextData(av[2].AsInteger)
    else av[0].AsInteger := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).TextData.Count;
  end
  else av[0].AsInteger := 0;
end;
{ @end $62B714 }

{ @routine $62B834 SF_PlanetNews }
procedure SF_PlanetNews(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.PlanetNews.Count;
end;
{ @end $62B834 }

{ @routine $62B86C SF_PlanetNewsDate }
procedure SF_PlanetNewsDate(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetNewsDate');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
    av[0].AsInteger := PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Turn;
end;
{ @end $62B86C }

{ @routine $62B914 SF_PlanetNewsType }
procedure SF_PlanetNewsType(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetNewsType');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
    av[0].AsInteger := Ord(PPlanetNewsEntry(Galaxy.PlanetNews[Index]).NewsType);
end;
{ @end $62B914 }

{ @routine $62B9BC SF_PlanetNewsText }
procedure SF_PlanetNewsText(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetNewsText');
  av[0].AsString := '';
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
  begin
    av[0].AsString := PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Text;
    if High(av) > 1 then PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Text := av[2].AsString;
  end;
end;
{ @end $62B9BC }

{ @routine $62BAC8 SF_ControlledSystems }
procedure SF_ControlledSystems(av: array of TVarEC; code: TCodeEC);
var
  Index, Count: Integer;
  Faction: TStarFaction;
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ControlledSystems');
  Faction := TStarFaction(av[1].AsInteger);
  Count := 0;
  for Index := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[Index];
    if (Star.Status.CustomFaction = '') and (Star.ControlFaction = Faction) then Inc(Count);
  end;
  av[0].AsInteger := Count;
end;
{ @end $62BAC8 }

{ @routine $62BB98 SF_DeltaWin }
procedure SF_DeltaWin(av: array of TVarEC; code: TCodeEC);
var
  Faction: TStarFaction;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script DeltaWin');
  Faction := TStarFaction(av[1].AsInteger);
  av[0].AsInteger := Galaxy.WarDeltaWin[Faction];
  if High(av) > 1 then Galaxy.WarDeltaWin[Faction] := av[2].AsInteger;
end;
{ @end $62BB98 }

{ @routine $62BC3C SF_ShipInFear }
procedure SF_ShipInFear(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipInFear');
  Ship := TShip(av[1].AsDword);
  if (Ship <> nil) and Ship.InFear then av[0].AsInteger := 1 else av[0].AsInteger := 0;
end;
{ @end $62BC3C }

{ @routine $62BCC4 SF_CreateGoods }
procedure SF_CreateGoods(av: array of TVarEC; code: TCodeEC);
var
  Item: TGoods;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CreateGoods');
  Item := TGoods.Create;
  Item.Init(TItemType(av[1].AsInteger), av[2].AsInteger);
  av[0].AsDword := Cardinal(Item);
  if High(av) > 2 then Item.NaturalFlag := av[3].AsInteger <> 0;
end;
{ @end $62BCC4 }

{ @routine $62BD70 SF_GetNodesFromShip }
procedure SF_GetNodesFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Remaining, Total: Integer;
  Item: TItem;
  Nodes: TProtoplasm;
  Series: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetNodesFromShip');
  Ship := TShip(av[1].AsDword);
  Remaining := 0;
  Total := 0;
  Series := -1;
  if High(av) > 1 then Remaining := av[2].AsInteger;
  if High(av) > 2 then Series := av[3].AsInteger;
  for Index := Ship.Inventory.Count - 1 downto 0 do
  begin
    Item := Ship.Inventory[Index];
    if not (Item is TProtoplasm) then Continue;
    Nodes := Item as TProtoplasm;
    if (Series >= 0) and (Ord(Nodes.DominatorSeries) <> Series) then Continue;
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
  if (High(av) > 1) and (av[2].AsInteger > 0) then av[0].AsInteger := Remaining else av[0].AsInteger := Total;
end;
{ @end $62BD70 }

{ @routine $62BEF0 SF_GetNodesFromStorage }
procedure SF_GetNodesFromStorage(av: array of TVarEC; code: TCodeEC);
var
  Index, Remaining, NewCount: Integer;
  Entry: PStorageEntry;
  Nodes: TProtoplasm;
  Location: TObject;
  Series: Integer;
begin
  Location := nil;
  if High(av) >= 1 then Location := TObject(av[1].AsDword);
  av[0].AsInteger := 0;
  Remaining := 0;
  Series := -1;
  if High(av) > 1 then Remaining := av[2].AsInteger;
  if High(av) > 2 then Series := av[3].AsInteger;
  Index := 0;
  while Index < GetPlayer.StorageEntries.Count do
  begin
    Entry := GetPlayer.StorageEntries[Index];
    if ((Entry.LocationOwner = Location) or (Location = nil)) and (Entry.Item.ItemType = item_nodes) then
    begin
      Nodes := TProtoplasm(Entry.Item);
      // Native does not advance Index when the series differs.
      if (Series >= 0) and (Ord(Nodes.DominatorSeries) <> Series) then Continue;
      av[0].AsInteger := av[0].AsInteger + Nodes.Weight;
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
{ @end $62BEF0 }

{ @routine $62C060 SF_RangerBaseNodes }
procedure SF_RangerBaseNodes(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RangerBaseNodes');
  av[0].AsInteger := TRanger(av[1].AsDword).BaseNodes;
  if High(av) > 1 then TRanger(av[1].AsDword).BaseNodes := av[2].AsInteger;
end;
{ @end $62C060 }

{ @routine $62C0FC SF_RuinsAllowModernization }
procedure SF_RuinsAllowModernization(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RuinsAllowModernization');
  if TRuins(av[1].AsDword).ModernizationSponsor then av[0].AsInteger := 1 else av[0].AsInteger := 0;
  if High(av) > 1 then TRuins(av[1].AsDword).ModernizationSponsor := av[2].AsInteger <> 0;
end;
{ @end $62C0FC }

{ @routine $62C1B8 SF_RuinsMicromoduleChain }
procedure SF_RuinsMicromoduleChain(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Station: TRuins;
  Kind, Index: Integer;
  InvertRarity: Boolean;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script RuinsMicromoduleChain');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TRuins) then raise Exception.Create('Error.Script RuinsMicromoduleChain - not a ruins');
  Station := TRuins(Obj);
  Kind := av[2].AsInteger;
  if High(av) = 2 then
  begin
    for Index := 0 to 50 do
    begin
      av[0].AsInteger := Station.SelectServiceMicroModule(Kind, Index, False);
      if GetPlayer.NeedsMicroModule(av[0].AsInteger + 1) then Break;
    end;
  end
  else
  begin
    Index := av[3].AsInteger;
    if High(av) > 3 then InvertRarity := av[4].AsInteger <> 0 else InvertRarity := False;
    av[0].AsInteger := Station.SelectServiceMicroModule(Kind, Index, InvertRarity);
  end;
end;
{ @end $62C1B8 }

{ @routine $62C324 SF_DomikKilledInCurSystem }
procedure SF_DomikKilledInCurSystem(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then av[0].AsInteger := GetPlayer.CurrentSystemKills.Dominator
  else av[0].AsInteger := TNormalShip(av[1].AsDword).CurrentSystemKills.Dominator;
end;
{ @end $62C324 }

{ @routine $62C374 SF_ShipTypeN }
procedure SF_ShipTypeN(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipTypeN');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ord(Ship.TypeId);
end;
{ @end $62C374 }

{ @routine $62C3E4 SF_ShipSubType }
procedure SF_ShipSubType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipSubType');
  Ship := TShip(av[1].AsDword);
  if Ship is TKling then av[0].AsInteger := Ord(TKling(Ship).KlingType)
  else if Ship is TTransport then av[0].AsInteger := Ord(TTransport(Ship).TransportType)
  else if Ship is TWarrior then av[0].AsInteger := Ord(TWarrior(Ship).WarriorType)
  else if Ship is TPirate then av[0].AsInteger := TPirate(Ship).PirateType
  else if Ship is TRanger then av[0].AsInteger := Ord(TRanger(Ship).PreferredCareer)
  else av[0].AsInteger := 0;
  if High(av) <= 1 then Exit;
  if Ship is TKling then TKling(Ship).KlingType := TDominatorKind(av[2].AsInteger)
  else if Ship is TTransport then TTransport(Ship).TransportType := TTransportType(av[2].AsInteger)
  else if Ship is TWarrior then TWarrior(Ship).WarriorType := TWarriorType(av[2].AsInteger)
  else if Ship is TPirate then TPirate(Ship).PirateType := av[2].AsInteger
  else if Ship is TRanger then TRanger(Ship).PreferredCareer := TRangerCareer(av[2].AsInteger);
end;
{ @end $62C3E4 }

{ @routine $62C5B4 SF_ShipChangeStar }
procedure SF_ShipChangeStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipChangeStar');
  if (TShip(av[1].AsDword) = GetPlayer) and (TemporaryShopSlots <> nil) then RestoreTemporaryShopStock;
  TShip(av[1].AsDword).TransferToStar(TStar(av[2].AsDword));
  if TShip(av[1].AsDword) = GetPlayer then
  begin
    PlayerStar := GetPlayer.CurrentStar;
    PlayerStar.RefreshMovementStepParameters;
  end;
end;
{ @end $62C5B4 }

{ @routine $62C680 SF_IsFilm }
procedure SF_IsFilm(av: array of TVarEC; code: TCodeEC);
begin
  if StarMapScreen.Mode = map_mode_playback then av[0].AsInteger := 1 else av[0].AsInteger := 0;
  SysUtils.Sleep(1);
end;
{ @end $62C680 }

{ @routine $62C6D0 SF_FilmFlags }
procedure SF_FilmFlags(av: array of TVarEC; code: TCodeEC);
var
  Kind: Cardinal;
  Arg: Integer;
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script FilmFlags');
  if av[1].AsDword <= 3 then
  begin
    Star := PlayerStar;
    Kind := av[1].AsDword;
    Arg := 2;
  end
  else
  begin
    if High(av) < 2 then raise Exception.Create('Error.Script FilmFlags');
    Star := TStar(av[1].AsDword);
    Kind := av[2].AsDword;
    Arg := 3;
  end;
  case Kind of
    0: av[0].AsInteger := Ord(Star.RecordingTurnFilm);
    1: begin
      av[0].AsInteger := Ord(Star.PlayerCombatOccurred);
      if High(av) >= Arg then Star.PlayerCombatOccurred := av[Arg].AsInteger <> 0;
    end;
    2: begin
      av[0].AsInteger := Ord(Star.InterruptLongTravel);
      if High(av) >= Arg then Star.InterruptLongTravel := av[Arg].AsInteger <> 0;
    end;
    3: begin
      av[0].AsInteger := Ord(Star.KeepFilmRunning);
      if High(av) >= Arg then Star.KeepFilmRunning := av[Arg].AsInteger <> 0;
    end;
  end;
end;
{ @end $62C6D0 }

{ @routine $62C830 SF_ShowEffect }
procedure SF_ShowEffect(av: array of TVarEC; code: TCodeEC);
var
  Effect: TWeaponSE;
  Entry: PEFilmEndEntry;
  TargetGraphic, SourceGraphic: TObjectSE;
  TargetFilm, SourceFilm: TEFilmObj;
  Name: WideString;
  Target, Source: TObject;
  Item: TItem;
  Damage, ShotVisual, Variant, Destruction: Integer;
  Destroyed, PlaySound: Boolean;
  Color: Cardinal;
  Film: TEFilmObj;
  Step: Integer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShowEffect');
  Name := av[1].AsString;
  ShotVisual := av[2].AsInteger;
  Target := TObject(av[3].AsDword);
  Source := nil;
  if High(av) > 3 then Source := TObject(av[4].AsDword);
  Damage := 0;
  if High(av) > 4 then Damage := av[5].AsInteger;
  Destroyed := False;
  if High(av) > 5 then Destroyed := av[6].AsInteger <> 0;
  PlaySound := True;
  if High(av) > 6 then PlaySound := av[7].AsInteger <> 0;
  if High(av) >= 10 then Color := CurrentPixelFormat.PackRgb(av[8].AsInteger, av[9].AsInteger, av[10].AsInteger)
  else if Target is TShip then
  begin
    if GetPlayer = Target then Color := OwnerToFilmColor(RaceToOwner(GetPlayer.PilotRace))
    else if TShip(Target).HasNamedScriptFaction then Color := CustomFactionToFilmColor(TScriptShip(TShip(Target).ScriptShip).StateText)
    else Color := OwnerToFilmColor(TShip(Target).OwnerId);
  end
  else Color := 0;
  Variant := -1;
  if High(av) >= 11 then Variant := av[11].AsInteger;
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
      if Destroyed and (av[6].AsInteger > 1) then
      begin
        Destruction := av[6].AsInteger - 1;
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
{ @end $62C830 }

{ @routine $62D004 SF_ShowStaticEffect }
procedure SF_ShowStaticEffect(av: array of TVarEC; code: TCodeEC);
var
  X, Y: Integer;
  Effect: TGAIEffectSE;
  Name: WideString;
  Scale: Single;
  Film: TEFilmObj;
  Step: Integer;
  Entry: PEFilmEndEntry;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShowStaticEffect');
  Name := av[1].AsString;
  X := av[2].AsInteger;
  Y := av[3].AsInteger;
  if High(av) > 3 then Scale := av[4].AsInteger * 0.01 else Scale := 1;
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
{ @end $62D004 }

{ @routine $62D2B4 SF_ShipConnect }
procedure SF_ShipConnect(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Star: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipConnect');
  Ship := TShip(av[1].AsDword);
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
{ @end $62D2B4 }

{ @routine $62D44C SF_FilmSound }
procedure SF_FilmSound(av: array of TVarEC; code: TCodeEC);
var
  FilmObject: TEFilmObj;
  Text: WideString;
  Obj: TObject;
  Item: TItem;
  Step: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script FilmSound');
  if (PlayerStar = nil) or not PlayerStar.RecordingTurnFilm or (PrimaryFilm = nil) then Exit;
  Text := av[1].AsString;
  Obj := TObject(av[2].AsDword);
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
{ @end $62D44C }

{ @routine $62D640 SF_FireWeapon }
procedure SF_FireWeapon(av: array of TVarEC; code: TCodeEC);
var
  Target: TObject;
  Ship: TShip;
  Weapon: TWeapon;
  RecordFilm: Boolean;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script FireWeapon');
  Ship := TShip(av[1].AsDword);
  Target := TObject(av[2].AsDword);
  Weapon := TWeapon(av[3].AsDword);
  RecordFilm := Ship.CurrentStar.RecordingTurnFilm;
  if Target is TMissile then Ship.FireWeaponAtMissile(Weapon, Target, RecordFilm)
  else if Target is TShip then Ship.FireWeaponAtShip(Weapon, TShip(Target), RecordFilm)
  else if Target is TItem then Ship.FireWeaponAtItem(Weapon, TItem(Target), RecordFilm)
  else if Target is TAsteroid then Ship.FireWeaponAtAsteroid(Weapon, Target, RecordFilm);
end;
{ @end $62D640 }

{ @routine $62D758 SF_WeaponHit }
procedure SF_WeaponHit(av: array of TVarEC; code: TCodeEC);
var
  Target: TObject;
  Ship: TShip;
  Weapon: TWeapon;
  Range: Integer;
  Color: Cardinal;
  Hit: Boolean;
  Missile: TMissile;
  Star: TStar;
  Flags: TDamageFlagSet;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script WeaponHit');
  Ship := TShip(av[1].AsDword);
  Target := TObject(av[2].AsDword);
  Weapon := TWeapon(av[3].AsDword);
  Range := -1;
  if High(av) > 3 then Range := av[4].AsInteger;
  if Target is TShip then av[0].AsInteger := TShip(Target).ApplyWeaponHit(Ship, Weapon, Range, Color, Flags, 1, 0)
  else if Target is TMissile then
  begin
    Missile := TMissile(Target);
    Hit := Missile.CanBeHit(Ship, Weapon);
    Hit := Ship.ScriptItemsAct(event_weapon_shot, Missile, Weapon, Ord(Hit)) <> 0;
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
    av[0].AsInteger := Ord(Hit);
  end;
end;
{ @end $62D758 }

{ @routine $62D8C4 SF_DealDamageToShip }
procedure SF_DealDamageToShip(av: array of TVarEC; code: TCodeEC);
var
  Source: TObject;
  Ship: TShip;
  Damage: Integer;
  Flags: TDamageFlagSet;
  Range: Integer;
  Color: Cardinal;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script DealDamageToShip');
  Ship := TShip(av[1].AsDword);
  Source := TObject(av[2].AsDword);
  Damage := av[3].AsInteger;
  if (Source <> nil) and (Source is TItem) then av[0].AsInteger := Ship.ApplyExplosionDamage(nil, Source, Damage, nil)
  else
  begin
    if High(av) > 3 then Dword(Flags) := av[4].AsDword else Flags := [damage_flag_energy];
    if High(av) > 4 then Range := av[5].AsInteger else Range := -1;
    av[0].AsInteger := Ship.ApplyDamage(Source, Damage, Range, Color, Flags);
  end;
end;
{ @end $62D8C4 }

{ @routine $62D9E0 SF_LaunchMissile }
procedure SF_LaunchMissile(av: array of TVarEC; code: TCodeEC);
var
  Target, Obj: TObject;
  Ship: TShip;
  Weapon: TWeapon;
  Shot: Integer;
  Missile: TMissile;
  Step: Integer;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script LaunchMissile');
  Ship := TShip(av[1].AsDword);
  Target := TObject(av[2].AsDword);
  Obj := TObject(av[3].AsDword);
  if Obj is TScriptItem then Weapon := TWeapon(TScriptItem(Obj).Item) else Weapon := TWeapon(Obj);
  Shot := 0;
  if High(av) > 3 then Shot := av[4].AsInteger;
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
  Ship.ScriptItemsAct(event_missile_shot, Missile, Weapon, 0);
  av[0].AsDword := Cardinal(Missile);
  if not Ship.CurrentStar.RecordingTurnFilm then Exit;
  Step := Ship.CurrentStar.CurrentStepIndex;
  Missile.PrepareTurnMovement(Step, True, True);
  PrimaryFilm.DetachObject(0, Missile.FilmObject);
end;
{ @end $62D9E0 }

{ @routine $62DB48 SF_SpawnMissile }
procedure SF_SpawnMissile(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Target: TObject;
  X, Y: Integer;
  Direction: Single;
  MinDamage, MaxDamage: Integer;
  Speed: Single;
  Kind: TItemType;
  Module, Special: Integer;
  Missile: TMissile;
  Step: Integer;
begin
  if High(av) < 9 then raise Exception.Create('Error.Script SpawnMissile');
  Star := TStar(av[1].AsDword);
  Target := TObject(av[2].AsDword);
  X := av[3].AsInteger;
  Y := av[4].AsInteger;
  Direction := av[5].AsInteger;
  MinDamage := av[6].AsInteger;
  MaxDamage := av[7].AsInteger;
  Speed := av[8].AsInteger;
  if High(av) > 9 then
  begin
    Module := av[10].AsInteger + 1;
    Special := av[11].AsInteger + 1;
  end
  else
  begin
    Module := 0;
    Special := 0;
  end;
  if av[9].ValueKind = value_string then
  begin
    Missile := TCustomMissile.Create;
    TCustomMissile(Missile).InitializeUnownedShot(Star, Target, X, Y, Direction, MinDamage, MaxDamage, Speed, av[9].AsString, Module, Special);
  end
  else
  begin
    Kind := TItemType(av[9].AsInteger);
    Missile := TMissile.Create;
    Missile.InitializeUnownedShot(Star, Target, X, Y, Direction, MinDamage, MaxDamage, Speed, Kind, Module, Special);
  end;
  av[0].AsDword := Cardinal(Missile);
  if not Star.RecordingTurnFilm then Exit;
  Step := Star.CurrentStepIndex;
  Missile.PrepareTurnMovement(Step, True, True);
  PrimaryFilm.DetachObject(0, Missile.FilmObject);
end;
{ @end $62DB48 }

{ @routine $62DD44 SF_BonusText }
procedure SF_BonusText(av: array of TVarEC; code: TCodeEC);
var
  Index, Count: Integer;
  Text: WideString;
  Bonus: TEquipmentBonusKind;
  Value: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script BonusText');
  Index := av[1].AsInteger;
  if (Index < 0) or (Index >= MicroModuleTemplateCount) then
  begin
    av[0].AsString := '';
    Exit;
  end;

  if High(av) < 2 then av[0].AsString := GetMicroModuleInfoText(Index, TextHighlightColorTag)
  else
  begin
  Count := av[2].AsInteger;
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
  av[0].AsString := WrapTextInColor(Text, GetMicroModuleTextColorTag(Index));
  end;
end;
{ @end $62DD44 }

{ @routine $62E0D4 SF_PlanetPirateClan }
procedure SF_PlanetPirateClan(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := Cardinal(MainPiratePlanet);
end;
{ @end $62E0D4 }

{ @routine $62E104 SF_Blazer }
procedure SF_Blazer(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := Cardinal(BlazerShip);
end;
{ @end $62E104 }

{ @routine $62E134 SF_Keller }
procedure SF_Keller(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := Cardinal(KellerShip);
end;
{ @end $62E134 }

{ @routine $62E164 SF_Terron }
procedure SF_Terron(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := Cardinal(TerronShip);
end;
{ @end $62E164 }

{ @routine $62E194 SF_PirateType }
procedure SF_PirateType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PirateType');
  Ship := TShip(av[1].AsDword);
  if Ship is TPirate then av[0].AsInteger := TPirate(Ship).PirateType else av[0].AsInteger := 0;
end;
{ @end $62E194 }

{ @routine $62E224 SF_PlayerQuestInProgress }
procedure SF_PlayerQuestInProgress(av: array of TVarEC; code: TCodeEC);
var
  Quest: PQuest;
  Index: Integer;
  Planet: TPlanet;
begin
  if GetPlayer.Quests <> nil then
  begin
    if High(av) > 0 then Planet := TPlanet(av[1].AsDword) else Planet := nil;
    for Index := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[Index];
      if ((Planet = nil) or (Quest.Planet = Planet)) and not Quest.Successful then
      begin
        av[0].AsInteger := 1;
        Exit;
      end;
    end;
  end;
  av[0].AsInteger := 0;
end;
{ @end $62E224 }

{ @routine $62E2C8 SF_PlayerQuestsCompleted }
procedure SF_PlayerQuestsCompleted(av: array of TVarEC; code: TCodeEC);
var
  Quest: PPlayerOldQuest;
  Index: Integer;
begin
  av[0].AsInteger := 0;
  if (PlayerOldQuests <> nil) and (PlayerOldQuests.Count > 0) then
    for Index := 0 to PlayerOldQuests.Count - 1 do
    begin
      Quest := PlayerOldQuests[Index];
      if ((High(av) < 1) or (TQuestKind(av[1].AsInteger) = Quest.QuestType)) and (Quest.Successful) then av[0].AsInteger := av[0].AsInteger + 1;
    end;
end;
{ @end $62E2C8 }

{ @routine $62E36C SF_QuestsStatusByNom }
procedure SF_QuestsStatusByNom(av: array of TVarEC; code: TCodeEC);
var
  Kind: TQuestKind;
  Number, Index: Integer;
  OldQuest: PPlayerOldQuest;
  Quest: PQuest;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script QuestsStatusByNom');
  Kind := TQuestKind(av[1].AsInteger);
  Number := av[2].AsInteger;
  if (PlayerOldQuests <> nil) and (PlayerOldQuests.Count > 0) then
    for Index := 0 to PlayerOldQuests.Count - 1 do
    begin
      OldQuest := PlayerOldQuests[Index];
      if (OldQuest.QuestType = Kind) and (OldQuest.QuestNumber = Number) then
      begin
        if OldQuest.Successful then av[0].AsInteger := 3 else av[0].AsInteger := 4;
        Exit;
      end;
    end;
  if (GetPlayer.Quests <> nil) and (GetPlayer.Quests.Count > 0) then
    for Index := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[Index];
      if (Quest.QuestType = Kind) and (Quest.QuestNumber = Number) then
      begin
        if Quest.Successful then av[0].AsInteger := 2 else av[0].AsInteger := 1;
        Exit;
      end;
    end;
  av[0].AsInteger := 0;
end;
{ @end $62E36C }

{ @routine $62E4EC SF_PlayerPlanetaryBattlesCompleted }
procedure SF_PlayerPlanetaryBattlesCompleted(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.PlanetBattles;
end;
{ @end $62E4EC }

{ @routine $62E520 SF_PlayerMayTakeSubCrack }
procedure SF_PlayerMayTakeSubCrack(av: array of TVarEC; code: TCodeEC);
begin
  if GetPlayer.MayTakeSubCrack then av[0].AsInteger := 1 else av[0].AsInteger := 0;
end;
{ @end $62E520 }

{ @routine $62E568 SF_SubCrackCost }
procedure SF_SubCrackCost(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.GetSubCrackCost;
end;
{ @end $62E568 }

{ @routine $62E59C SF_ShipCalcParam }
procedure SF_ShipCalcParam(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipCalcParam');
  TShip(av[1].AsDword).RefreshDerivedStats(True);
end;
{ @end $62E59C }

{ @routine $62E60C SF_ShipRefit }
procedure SF_ShipRefit(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipRefit');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if High(av) > 2 then
    if av[3].AsInteger > Ship.Money then Ship.SetMoney(av[3].AsInteger);
  Ship.BuyEquipmentAtLocation(True);
  if High(av) > 1 then
    if Ship.GetHull.Weight < av[2].AsInteger then
    begin
      Ship.GetHull.Weight := av[2].AsInteger;
      Ship.GetHull.HullPoints := av[2].AsInteger;
    end;
  Ship.RefreshDerivedStats(True);
  av[0].AsInteger := 1;
end;
{ @end $62E60C }

{ @routine $62E70C SF_ShipImproveItems }
procedure SF_ShipImproveItems(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  I, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipImproveItems');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  Count := 1;
  if High(av) > 1 then Count := av[2].AsInteger;
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
{ @end $62E70C }

{ @routine $62E818 SF_ItemImprovement }
procedure SF_ItemImprovement(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Equipment: TEquipment;
  SavedId, Kind: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ItemImprovement');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].AsInteger := 0;
  if Item.ItemType in [item_hull..item_custom_weapon] then
  begin
    Equipment := TEquipment(Item);
    if not Equipment.HasStandardStats then av[0].AsInteger := 1;
    if High(av) > 1 then
    begin
      Kind := av[2].AsInteger;
      if (Kind < 0) or (Kind > 3) then Kind := 3;
      if High(av) > 2 then Equipment.DetailImprovement := av[3].AsInteger
      else Equipment.DetailImprovement := 0;
      if High(av) > 3 then
      begin
        SavedId := Equipment.Id;
        Equipment.Id := av[4].AsDword;
        Equipment.Improve(TUpgradeKind(Kind));
        Equipment.Id := SavedId;
      end
      else Equipment.Improve(TUpgradeKind(Kind));
    end;
  end;
end;
{ @end $62E818 }

{ @routine $62E94C SF_ShipFreeFlight }
procedure SF_ShipFreeFlight(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ShipFreeFlight');
  Ship := TShip(av[1].AsDword);
  ScriptSnap(Snapshot);
  if (High(av) < 2) or (av[2].AsInteger = 0) then Ship.NextDayLogic
  else
    case av[2].AsInteger of
      1: Ship.AssignWeaponTargetsInStar;
      2: Ship.SelectEnemyShipInStar;
      3: Ship.EngageEnemyShip;
      4: Ship.DropCargoUntilNotOverloaded;
      5: Ship.AutoApplyMicroModules;
      6: Ship.QueueItemsWithinPickupRange;
    end;
  ScriptUnSnap(Snapshot);
end;
{ @end $62E94C }

{ @routine $62EA50 SF_ShipKillFactionInCurSystem }
procedure SF_ShipKillFactionInCurSystem(av: array of TVarEC; code: TCodeEC);
type
  TKillFactionIndex = 0..3;
  TKillCounts = array[0..3] of Word;
var
  Obj: TObject;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ShipKillFactionInCurSystem');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TNormalShip) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  if av[2].AsInteger = -1 then
  begin
    av[0].AsInteger := (Obj as TNormalShip).CurrentSystemKills.Custom;
    if High(av) > 2 then (Obj as TNormalShip).CurrentSystemKills.Custom := av[3].AsInteger;
  end
  else
  begin
    av[0].AsInteger := TKillCounts((Obj as TNormalShip).CurrentSystemKills)[TKillFactionIndex(av[2].AsInteger)];
    if High(av) > 2 then
    begin
      TKillCounts((Obj as TNormalShip).CurrentSystemKills)[TKillFactionIndex(av[2].AsInteger)] := av[3].AsInteger;
      TShip(Obj).RefreshCurrentStanding;
    end;
  end;
end;
{ @end $62EA50 }

{ @routine $62EBA4 SF_CapitalShipStats }
procedure SF_CapitalShipStats(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ship: TShip;
  Hull: THull;
begin
  av[0].AsInteger := 0;
  if High(av) < 1 then raise Exception.Create('Error.Script SF_CapitalShipStats');
  Obj := TObject(av[1].AsDword);
  Ship := nil;
  Hull := nil;
  if Obj is TScriptShip then Ship := (Obj as TScriptShip).Ship;
  if Obj is TShip then Ship := TShip(Obj);
  if Ship <> nil then Hull := Ship.GetHull;
  if Obj is THull then Hull := THull(Obj);
  if Hull = nil then Exit;
  av[0].AsInteger := Hull.CapitalShip;
  if High(av) <= 1 then Exit;
  Hull.CapitalShip := av[2].AsInteger;
  if Hull.CapitalShip = 1 then
  begin
    Hull.InterceptorsEnabled := True;
    if High(av) > 2 then Hull.EnergyMax := av[3].AsInteger
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
{ @end $62EBA4 }

{ @routine $62ECF0 SF_PlayerBridge }
procedure SF_PlayerBridge(av: array of TVarEC; code: TCodeEC);
var
  Mode: Integer;
begin
  av[0].AsInteger := GetPlayer.RuinsMode;
  if High(av) > 0 then
  begin
    Mode := av[1].AsInteger;
    if High(av) > 1 then GetPlayer.RuinsStatusText := av[2].AsString else GetPlayer.RuinsStatusText := '';
    if Mode > 0 then GetPlayer.EnterRuinsMode(Mode) else GetPlayer.CloseRuinsModeScreen;
  end;
end;
{ @end $62ECF0 }

{ @routine $62EDB8 SF_PlayerDebt }
procedure SF_PlayerDebt(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DebtAmount;
  if High(av) > 0 then GetPlayer.DebtAmount := av[1].AsInteger;
end;
{ @end $62EDB8 }

{ @routine $62EE08 SF_PlayerDebtDate }
procedure SF_PlayerDebtDate(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DebtDueTurn;
  if High(av) > 0 then GetPlayer.DebtDueTurn := av[1].AsInteger;
end;
{ @end $62EE08 }

{ @routine $62EE58 SF_PlayerDebtCnt }
procedure SF_PlayerDebtCnt(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DebtDefaultCount;
  if High(av) > 0 then GetPlayer.DebtDefaultCount := av[1].AsInteger;
end;
{ @end $62EE58 }

{ @routine $62EEA8 SF_PlayerDeposit }
procedure SF_PlayerDeposit(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DepositAmount;
  if High(av) > 0 then GetPlayer.DepositAmount := av[1].AsInteger;
end;
{ @end $62EEA8 }

{ @routine $62EEF8 SF_PlayerDepositDate }
procedure SF_PlayerDepositDate(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DepositStartTurn;
  if High(av) > 0 then GetPlayer.DepositStartTurn := av[1].AsInteger;
end;
{ @end $62EEF8 }

{ @routine $62EF48 SF_PlayerDepositDay }
procedure SF_PlayerDepositDay(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DepositDayCount;
  if High(av) > 0 then GetPlayer.DepositDayCount := av[1].AsInteger;
end;
{ @end $62EF48 }

{ @routine $62EF98 SF_PlayerDepositPercent }
procedure SF_PlayerDepositPercent(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Round(GetPlayer.DepositInterestRate * 100);
  if High(av) > 0 then GetPlayer.DepositInterestRate := av[1].AsInteger * 0.01;
end;
{ @end $62EF98 }

{ @routine $62F014 SF_PlayerMedPolicy }
procedure SF_PlayerMedPolicy(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.MedicalPolicyTicks;
  if High(av) > 0 then GetPlayer.MedicalPolicyTicks := av[1].AsInteger;
end;
{ @end $62F014 }

{ @routine $62F064 SF_ShipCustomShipInfosCount }
procedure SF_ShipCustomShipInfosCount(av: array of TVarEC; code: TCodeEC);
var
  I, Count: Integer;
  Ship: TShip;
  Info: PCustomShipInfo;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipCustomShipInfosCount');
  Ship := TShip(av[1].AsDword);
  Count := 0;
  for I := 0 to Ship.CustomShipInfos.Count - 1 do
  begin
    Info := Ship.CustomShipInfos[I];
    if not Info.DeleteQueued then Inc(Count);
  end;
  av[0].AsInteger := Count;
end;
{ @end $62F064 }

{ @routine $62F124 SF_ShipAddCustomShipInfo }
procedure SF_ShipAddCustomShipInfo(av: array of TVarEC; code: TCodeEC);
var
  Info: PCustomShipInfo;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipAddCustomShipInfo');
  New(Info);
  TShip(av[1].AsDword).CustomShipInfos.Add(Info);
  Info.ActionCode := nil;
  Info.TypeName := av[2].AsString;
  Info.ActionCodeInitialized := False;
  Info.DeleteQueued := False;
  if High(av) > 2 then Info.Description := av[3].AsString else Info.Description := '';
  if High(av) > 3 then Info.Data[1] := av[4].AsInteger else Info.Data[1] := 0;
  if High(av) > 4 then Info.Data[2] := av[5].AsInteger else Info.Data[2] := 0;
  if High(av) > 5 then Info.Data[3] := av[6].AsInteger else Info.Data[3] := 0;
  if High(av) > 6 then Info.TextData1 := av[7].AsString else Info.TextData1 := '';
  if High(av) > 7 then Info.TextData2 := av[8].AsString else Info.TextData2 := '';
  if High(av) > 8 then Info.TextData3 := av[9].AsString else Info.TextData3 := '';
  Info.StatusEffect := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').GetBlock(Info.TypeName).CountParams('StatusEffect') > 0;
  av[0].AsDword := Cardinal(Info);
end;
{ @end $62F124 }

{ @routine $62F39C SF_ShipDeleteCustomShipInfo }
procedure SF_ShipDeleteCustomShipInfo(av: array of TVarEC; code: TCodeEC);
var
  Index, I: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipDeleteCustomShipInfo');
  Ship := TShip(av[1].AsDword);
  if av[2].ValueKind = value_string then begin
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then Continue;
      if Info.TypeName <> av[2].AsString then Continue;
      Info.DeleteQueued := True;
      Exit;
    end;
    Exit;
  end;
  if (av[2].AsDword > 10000) and (av[2].AsInteger <> -1) then begin
    if (Ship = nil) or (Ship.CustomShipInfos.IndexOf(PCustomShipInfo(av[2].AsDword)) >= 0) then
      PCustomShipInfo(av[2].AsDword).DeleteQueued := True;
    Exit;
  end;
  Index := av[2].AsInteger;
  if Index < 0 then Exit;
  Info := nil;
  for I := 0 to Ship.CustomShipInfos.Count - 1 do
  begin
    Info := Ship.CustomShipInfos[I];
    if Info.DeleteQueued then Continue;
    Dec(Index);
    if Index < 0 then Break;
  end;
  if (Index < 0) and (Info <> nil) then Info.DeleteQueued := True;
end;
{ @end $62F39C }

{ @routine $62F56C SF_ShipFindCustomShipInfoByType }
procedure SF_ShipFindCustomShipInfoByType(av: array of TVarEC; code: TCodeEC);
var
  I, Index: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ShipFindCustomShipInfoByType');
  Ship := TShip(av[1].AsDword);
  Index := 0;
  for I := 0 to Ship.CustomShipInfos.Count - 1 do
  begin
    Info := Ship.CustomShipInfos[I];
    if Info.DeleteQueued then Continue;
      if Info.TypeName = av[2].AsString then
      begin
        av[0].AsInteger := Index;
        Exit;
      end;
      Inc(Index);
  end;
  av[0].AsInteger := -1;
end;
{ @end $62F56C }

{ @routine $62F68C SF_ShipCustomShipInfoDescription }
procedure SF_ShipCustomShipInfoDescription(av: array of TVarEC; code: TCodeEC);
var
  I, Index: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
  Block: TBlockParEC;
begin
  { Native validation accepts one argument even though lookup below reads av[2]. }
  if High(av) < 1 then raise Exception.Create('Error.Script ShipCustomShipInfoDescription');
  av[0].AsString := '';
  Ship := TShip(av[1].AsDword);
  if av[2].ValueKind = value_string then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if not Info.DeleteQueued and (Info.TypeName = av[2].AsString) then Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].AsString) then Exit;
  end
  else if (av[2].AsDword > 10000) and (av[2].AsInteger <> -1) then
  begin
    Info := PCustomShipInfo(av[2].AsDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if Index < 0 then Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then Continue;
      Dec(Index);
      if Index < 0 then Break;
    end;
    if (Index >= 0) or (Info = nil) then Exit;
  end;
  av[0].AsString := Info.Description;
  if av[0].AsString = '' then
  begin
    Block := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').GetBlock(Info.TypeName);
    if Block.CountParams('Description') <> 0 then av[0].AsString := Block.GetParam('Description');
  end;
  if High(av) > 2 then Info.Description := av[3].AsString;
end;
{ @end $62F68C }

{ @routine $62F990 SF_ShipCustomShipInfoData }
procedure SF_ShipCustomShipInfoData(av: array of TVarEC; code: TCodeEC);
var
  I, Index, DataIndex: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipCustomShipInfoData');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if av[2].ValueKind = value_string then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if not Info.DeleteQueued and (Info.TypeName = av[2].AsString) then Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].AsString) then Exit;
  end
  else if (av[2].AsDword > 10000) and (av[2].AsInteger <> -1) then
  begin
    Info := PCustomShipInfo(av[2].AsDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if Index < 0 then Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then Continue;
      Dec(Index);
      if Index < 0 then Break;
    end;
    if (Index >= 0) or (Info = nil) then Exit;
  end;
  DataIndex := av[3].AsInteger;
  case DataIndex of
    1: av[0].AsInteger := Info.Data[1];
    2: av[0].AsInteger := Info.Data[2];
    3: av[0].AsInteger := Info.Data[3];
  else raise Exception.Create('Error.Script ShipCustomShipInfoData ind');
  end;
  if High(av) > 3 then
    case DataIndex of
      1: Info.Data[1] := av[4].AsInteger;
      2: Info.Data[2] := av[4].AsInteger;
      3: Info.Data[3] := av[4].AsInteger;
    end;
end;
{ @end $62F990 }

{ @routine $62FC3C SF_ShipCustomShipInfoTextData }
procedure SF_ShipCustomShipInfoTextData(av: array of TVarEC; code: TCodeEC);
var
  I, Index, DataIndex: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script ShipCustomShipInfoTextData');
  av[0].AsString := '';
  Ship := TShip(av[1].AsDword);
  if av[2].ValueKind = value_string then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if not Info.DeleteQueued and (Info.TypeName = av[2].AsString) then Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].AsString) then Exit;
  end
  else if (av[2].AsDword > 10000) and (av[2].AsInteger <> -1) then
  begin
    Info := PCustomShipInfo(av[2].AsDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if Index < 0 then Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then Continue;
      Dec(Index);
      if Index < 0 then Break;
    end;
    if (Index >= 0) or (Info = nil) then Exit;
  end;
  DataIndex := av[3].AsInteger;
  case DataIndex of
    1: av[0].AsString := Info.TextData1;
    2: av[0].AsString := Info.TextData2;
    3: av[0].AsString := Info.TextData3;
  else raise Exception.Create('Error.Script ShipCustomShipInfoData ind');
  end;
  if High(av) > 3 then
    case DataIndex of
      1: Info.TextData1 := av[4].AsString;
      2: Info.TextData2 := av[4].AsString;
      3: Info.TextData3 := av[4].AsString;
    end;
end;
{ @end $62FC3C }

{ @routine $62FF14 SF_StarCustomStarInfosCount }
procedure SF_StarCustomStarInfosCount(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarCustomStarInfosCount');
  av[0].AsInteger := TStar(av[1].AsDword).CustomSystemInfos.Count;
end;
{ @end $62FF14 }

{ @routine $62FF98 SF_StarAddCustomStarInfo }
procedure SF_StarAddCustomStarInfo(av: array of TVarEC; code: TCodeEC);
var
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script StarAddCustomStarInfo');
  Star := TStar(av[1].AsDword);
  Info := TCustomSystemInfo.Create;
  Star.CustomSystemInfos.Add(Info);
  Info.TypeTag := av[2].AsString;
  Info.Name := av[3].AsString;
  if High(av) > 3 then Info.Distance := av[4].AsInteger else Info.Distance := 0;
  if High(av) > 4 then Info.Icon := av[5].AsString else Info.Icon := '';
  if High(av) > 5 then Info.Info := av[6].AsString else Info.Info := '';
end;
{ @end $62FF98 }

{ @routine $6300F8 SF_StarDeleteCustomStarInfo }
procedure SF_StarDeleteCustomStarInfo(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarDeleteCustomStarInfo');
  Star := TStar(av[1].AsDword);
  if av[2].ValueKind = value_string then
  begin
    for I := 0 to Star.CustomSystemInfos.Count - 1 do
    begin
      Info := Star.CustomSystemInfos[I];
      if Info.TypeTag <> av[2].AsString then Continue;
      Star.CustomSystemInfos.Delete(I);
      Info.Free;
      Break;
    end;
    Exit;
  end;
  I := av[2].AsInteger;
  if (I < 0) or (Star.CustomSystemInfos.Count <= I) then Exit;
  Info := Star.CustomSystemInfos[I];
  Star.CustomSystemInfos.Delete(I);
  Info.Free;
end;
{ @end $6300F8 }

{ @routine $630258 SF_StarFindCustomStarInfoByType }
procedure SF_StarFindCustomStarInfoByType(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarFindCustomStarInfoByType');
  Star := TStar(av[1].AsDword);
  for I := 0 to Star.CustomSystemInfos.Count - 1 do
  begin
    Info := Star.CustomSystemInfos[I];
    if Info.TypeTag <> av[2].AsString then Continue;
    av[0].AsInteger := I;
    Exit;
  end;
  av[0].AsInteger := -1;
end;
{ @end $630258 }

{ @routine $630364 SF_StarCustomStarInfoData }
procedure SF_StarCustomStarInfoData(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script StarCustomStarInfoData');
  av[0].AsString := '';
  Star := TStar(av[1].AsDword);
  I := av[2].AsInteger;
  if (I < 0) or (Star.CustomSystemInfos.Count <= I) then Exit;
  Info := Star.CustomSystemInfos[I];
  if av[3].AsString = 'Name' then
  begin
    av[0].AsString := Info.Name;
    if High(av) > 3 then Info.Name := av[4].AsString;
  end
  else if av[3].AsString = 'Dist' then
  begin
    av[0].AsInteger := Info.Distance;
    if High(av) > 3 then Info.Distance := av[4].AsInteger;
  end
  else if av[3].AsString = 'Icon' then
  begin
    av[0].AsString := Info.Icon;
    if High(av) > 3 then Info.Icon := av[4].AsString;
  end
  else if av[3].AsString = 'Info' then
  begin
    av[0].AsString := Info.Info;
    if High(av) > 3 then Info.Info := av[4].AsString;
  end
  else raise Exception.Create('Error.Script StarCustomStarInfoData 2');
end;
{ @end $630364 }

{ @routine $6305E8 SF_ItemCanBeBroken }
procedure SF_ItemCanBeBroken(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  CanBreak: Boolean;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemCanBeBroken');
  CanBreak := False;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then CanBreak := (Item.ItemType in [item_fuel_tanks..item_custom_weapon, item_satellite]) or (Item.ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles]);
  av[0].AsDword := Ord(CanBreak);
end;
{ @end $6305E8 }

{ @routine $6306CC SF_ItemFragility }
procedure SF_ItemFragility(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemFragility');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  av[0].AsFloat := 1;
  if (Item = nil) or not (Item is TEquipment) then Exit;
  av[0].AsFloat := TEquipment(Item).GetFragilityFactor([]);
end;
{ @end $6306CC }

{ @routine $6307AC SF_ItemDurability }
procedure SF_ItemDurability(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  OldValue, NewValue: Integer;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemDurability');
  OldValue := 100;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item is TEquipment then
    begin
      OldValue := Round((Item as TEquipment).ConditionPercent);
      if High(av) > 1 then
      begin
        NewValue := Min(av[2].AsInteger, 100);
        (Item as TEquipment).ConditionPercent := NewValue;
        (Item as TEquipment).BrokenFlag := Ord(NewValue <= 0);
      end;
    end;
  av[0].AsInteger := OldValue;
end;
{ @end $6307AC }

{ @routine $6308D4 SF_ItemLevel }
procedure SF_ItemLevel(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  OldLevel, NewLevel: Integer;
  Item: TItem;
  OldBase, NewBase: TEquipment;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemLevel');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  OldLevel := 0;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item.ItemType in [item_hull..item_custom_weapon] then
    begin
      OldLevel := (Item as TEquipment).GetLevel;
      if High(av) > 1 then
      begin
        NewLevel := Max(1, av[2].AsInteger);
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
          item_hull: begin
            THull(Item).TechLevel := NewLevel;
            THull(Item).Armor := THull(Item).Armor + THull(NewBase).Armor - THull(OldBase).Armor;
          end;
          item_fuel_tanks: begin
            TFuelTanks(Item).TechLevel := NewLevel;
            TFuelTanks(Item).Capacity := TFuelTanks(Item).Capacity + TFuelTanks(NewBase).Capacity - TFuelTanks(OldBase).Capacity;
            TFuelTanks(Item).Fuel := Max(0, Min(TFuelTanks(Item).Fuel, TFuelTanks(Item).Capacity));
          end;
          item_engine: begin
            TEngine(Item).TechLevel := NewLevel;
            TEngine(Item).Speed := TEngine(Item).Speed + TEngine(NewBase).Speed - TEngine(OldBase).Speed;
            TEngine(Item).JumpRange := TEngine(Item).JumpRange + TEngine(NewBase).JumpRange - TEngine(OldBase).JumpRange;
          end;
          item_radar: begin
            TRadar(Item).TechLevel := NewLevel;
            TRadar(Item).Range := TRadar(Item).Range + TRadar(NewBase).Range - TRadar(OldBase).Range;
          end;
          item_scanner: begin
            TScaner(Item).TechLevel := NewLevel;
            TScaner(Item).ScanPower := TScaner(Item).ScanPower + TScaner(NewBase).ScanPower - TScaner(OldBase).ScanPower;
          end;
          item_repair_robot: begin
            TRepairRobot(Item).TechLevel := NewLevel;
            TRepairRobot(Item).RepairPoints := TRepairRobot(Item).RepairPoints + TRepairRobot(NewBase).RepairPoints - TRepairRobot(OldBase).RepairPoints;
          end;
          item_cargo_hook: begin
            TCargoHook(Item).TechLevel := NewLevel;
            TCargoHook(Item).PickupPower := TCargoHook(Item).PickupPower + TCargoHook(NewBase).PickupPower - TCargoHook(OldBase).PickupPower;
            TCargoHook(Item).Range := TCargoHook(Item).Range + TCargoHook(NewBase).Range - TCargoHook(OldBase).Range;
            TCargoHook(Item).MinPullSpeed := TCargoHook(Item).MinPullSpeed + TCargoHook(NewBase).MinPullSpeed - TCargoHook(OldBase).MinPullSpeed;
            TCargoHook(Item).MaxPullSpeed := TCargoHook(Item).MaxPullSpeed + TCargoHook(NewBase).MaxPullSpeed - TCargoHook(OldBase).MaxPullSpeed;
          end;
          item_defense_generator: begin
            TDefGenerator(Item).TechLevel := NewLevel;
            TDefGenerator(Item).DamageFactor := TDefGenerator(Item).DamageFactor + TDefGenerator(NewBase).DamageFactor - TDefGenerator(OldBase).DamageFactor;
          end;
        else
          if Item.ItemType in WeaponItemTypes then
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
  av[0].AsInteger := OldLevel;
end;
{ @end $6308D4 }

{ @routine $630C4C SF_ContainerFuel }
procedure SF_ContainerFuel(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ContainerFuel');
  Obj := TObject(av[1].AsDword);
  if Obj is TFuelTanks then
  begin
    av[0].AsInteger := TFuelTanks(Obj).Fuel;
    if High(av) > 1 then TFuelTanks(Obj).Fuel := av[2].AsInteger;
  end
  else if Obj is TCistern then
  begin
    av[0].AsInteger := TCistern(Obj).Fuel;
    if High(av) > 1 then TCistern(Obj).Fuel := av[2].AsInteger;
  end
  else av[0].AsInteger := 0;
end;
{ @end $630C4C }

{ @routine $630D20 SF_ItemCharge }
procedure SF_ItemCharge(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemCharge');
  Obj := TObject(av[1].AsDword);
  if Obj is TArtefactTransmitter then
  begin
    av[0].AsInteger := TArtefactTransmitter(Obj).Power;
    if High(av) > 1 then TArtefactTransmitter(Obj).Power := av[2].AsInteger;
  end
  else av[0].AsInteger := 0;
end;
{ @end $630D20 }

{ @routine $630DC4 SF_MissilesToRearm }
procedure SF_MissilesToRearm(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Needed, Count: Integer;
  Item: TItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MissilesToRearm');
  Obj := TObject(av[1].AsDword);
  Needed := 0;
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if TWeapon(Item).GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
    begin
      // Native checks the base equipment class here, then accesses weapon fields.
      Needed := TWeapon(Item as TEquipment).AmmoCapacity - TWeapon(Item as TEquipment).Ammo;
      if High(av) > 1 then
      begin
        Count := av[2].AsInteger;
        TWeapon(Item as TEquipment).Ammo := Max(0, Min(TWeapon(Item as TEquipment).AmmoCapacity, TWeapon(Item as TEquipment).Ammo + Count));
      end;
    end;
  av[0].AsInteger := Needed;
end;
{ @end $630DC4 }

{ @routine $630F1C SF_WeaponAmmunition }
procedure SF_WeaponAmmunition(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Weapon: TWeapon;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script WeaponAmmunition');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item = nil) or not (Item is TWeapon) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  Weapon := Item as TWeapon;
  av[0].AsInteger := Weapon.Ammo;
  if High(av) > 1 then Weapon.Ammo := av[2].AsInteger;
end;
{ @end $630F1C }

{ @routine $631008 SF_WeaponMaxAmmunition }
procedure SF_WeaponMaxAmmunition(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Weapon: TWeapon;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script WeaponAmmunition');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item = nil) or not (Item is TWeapon) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Weapon := Item as TWeapon;
  av[0].AsInteger := Weapon.AmmoCapacity;
  if High(av) > 1 then Weapon.AmmoCapacity := av[2].AsInteger;
end;
{ @end $631008 }

{ @routine $6310F4 SF_ShipSpecialBonuses }
procedure SF_ShipSpecialBonuses(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TEquipmentBonusKind;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ShipSpecialBonuses');
  Ship := TShip(av[1].AsDword);
  Kind := TEquipmentBonusKind(av[2].AsInteger);
  if (High(av) > 2) and (av[3].ValueKind = value_string) and (av[3].AsString = 'Total') then
    av[0].AsInteger := Ship.GetTotalStatBonus(Kind)
  else
  begin
    av[0].AsInteger := Ship.GetOwnStatBonus(Kind);
    if High(av) > 2 then Ship.SetStatBonus(Kind, av[3].AsInteger);
  end;
end;
{ @end $6310F4 }

{ @routine $631228 SF_ItemExtraSpecials }
procedure SF_ItemExtraSpecials(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Index, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ItemExtraSpecials');
  if (High(av) = 1) and (TItem(av[1].AsDword).ItemType in [item_food..item_narcotics]) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Item := TEquipment(av[1].AsDword);
  if Item.ExtraSpecials = nil then Count := 0 else Count := Item.ExtraSpecials.Count;
  if High(av) < 2 then av[0].AsInteger := Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index < 0) or (Index >= Count) then av[0].AsInteger := -1
    else av[0].AsInteger := PExtraSpecial(Item.ExtraSpecials[Index]).ModuleIndexPlusOne - 1;
  end;
end;
{ @end $631228 }

{ @routine $631318 SF_ItemExtraSpecialsCountByType }
procedure SF_ItemExtraSpecialsCountByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ItemExtraSpecialsCountByType');
  if TItem(av[1].AsDword).ItemType in [item_food..item_narcotics] then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Item := TEquipment(av[1].AsDword);
  ModuleIndex := av[2].AsInteger + 1;
  av[0].AsInteger := 0;
  if Item.ExtraSpecials = nil then Exit;
  for Index := 0 to Item.ExtraSpecials.Count - 1 do
    begin
      Entry := Item.ExtraSpecials[Index];
      if Entry.ModuleIndexPlusOne = ModuleIndex then
      begin
        av[0].AsInteger := Entry.Count;
        Exit;
      end;
    end;
end;
{ @end $631318 }

{ @routine $631414 SF_ItemExtraSpecialsAddByType }
procedure SF_ItemExtraSpecialsAddByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index, Found, Count: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ItemExtraSpecialsAddByType');
  Item := TEquipment(av[1].AsDword);
  ModuleIndex := av[2].AsInteger + 1;
  if ModuleIndex <= 0 then raise Exception.Create('Error.Script SF_ItemExtraSpecialsAddByType invalid bonus');
  if High(av) > 2 then Count := av[3].AsInteger else Count := 1;
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
      Entry := Item.ExtraSpecials[Index];
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
{ @end $631414 }

{ @routine $6315EC SF_ItemExtraSpecialsDeleteByType }
procedure SF_ItemExtraSpecialsDeleteByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index, Found, Count: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SF_ItemExtraSpecialsDeleteByType');
  Item := TEquipment(av[1].AsDword);
  ModuleIndex := av[2].AsInteger + 1;
  if High(av) > 2 then Count := av[3].AsInteger else Count := 1;
  if Item.ExtraSpecials = nil then Exit;
  Entry := nil;
  Found := -1;
  for Index := 0 to Item.ExtraSpecials.Count - 1 do
    if PExtraSpecial(Item.ExtraSpecials[Index]).ModuleIndexPlusOne = ModuleIndex then
    begin
      Entry := Item.ExtraSpecials[Index];
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
{ @end $6315EC }

{ @routine $631724 SF_ExecuteCodeFromString }
procedure SF_ExecuteCodeFromString(av: array of TVarEC; code: TCodeEC);
var
  SourceText: WideString;
  RunCode: TCodeEC;
  SavedScript: TScript;
  I, Count: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_ExecuteCodeFromString');
  SourceText := av[1].AsString;
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
      RunCode.LocalVar.Add(av[2 * I].AsString, av[2 * I + 1].ValueKind).Assume(av[2 * I + 1], True);
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
      av[0].Assume(RunCode.LocalVar.NamedItems[av[High(av)].AsString], True);
    CurrentScript := SavedScript;
    RunCode.Free;
  end;
end;
{ @end $631724 }

{ @routine $631AC0 SF_GenerateCodeStringFromBlock }
procedure SF_GenerateCodeStringFromBlock(av: array of TVarEC; code: TCodeEC);
var
  Path: WideString;
  I, Count: Integer;
  Block: TBlockParEC;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script SF_GenerateCodeStringFromBlock');
  av[0].AsString := '';
  Path := av[1].AsString;
  Count := CountDelimitedPartsW(Path, '.');
  if (High(av) > 1) and (av[2].AsInteger <> 0) then Block := MainDataConfig
  else Block := LanguageDataConfig;
  for I := 0 to Count - 1 do
  begin
    Block := Block.FindBlockByPath(ExtractDelimitedPartW(Path, I, '.'));
    if Block = nil then
    begin
      AppendLogLineThreadSafe(AnsiString('Warning.Script SF_GenerateCodeStringFromBlock - cant find block ' +
        av[1].AsString + ' [' + IntToStr(I) + ']'));
      Exit;
    end;
  end;
  av[0].AsString := Block.ConcatenateValues;
  if av[0].AsString = '' then
    AppendLogLineThreadSafe(AnsiString('Warning.Script SF_GenerateCodeStringFromBlock - no code at ' + av[1].AsString));
end;
{ @end $631AC0 }

{ @routine $631E20 SF_ItemOnUseCode }
procedure SF_ItemOnUseCode(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemOnUseCode');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    av[0].AsString := Binding.OnUseText;
    if High(av) > 1 then Binding.OnUseText := av[2].AsString;
  end
  else av[0].AsString := '';
end;
{ @end $631E20 }

{ @routine $631F24 SF_ItemOnActCode }
procedure SF_ItemOnActCode(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ItemOnActCode');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    av[0].AsString := Binding.OnActionText;
    if High(av) > 1 then
    begin
      Binding.ActionCodeInitialized := False;
      if High(av) > 3 then
        Binding.OnActionText := '[' + av[3].AsString + '|' + av[4].AsString + ']' + av[2].AsString
      else if High(av) = 3 then
        Binding.OnActionText := '[' + av[3].AsString + '|]' + av[2].AsString
      else Binding.OnActionText := av[2].AsString;
    end;
  end
  else av[0].AsString := '';
end;
{ @end $631F24 }

{ @routine $6320EC SF_CreateActCodeEvent }
procedure SF_CreateActCodeEvent(av: array of TVarEC; code: TCodeEC);
var
  ActionType: TScriptEventKind;
  Obj, Object1, Object2: TObject;
  Info: PCustomShipInfo;
  Ship: TShip;
  Param, I: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CreateActCodeEvent');
  ActionType := TScriptEventKind(av[1].AsInteger);
  if av[2].ValueKind = value_string then
  begin
    if High(av) < 3 then raise Exception.Create('Error.Script CreateActCodeEvent cant call info without ship');
    Obj := TObject(av[3].AsDword);
    if not (Obj is TShip) then raise Exception.Create('Error.Script CreateActCodeEvent cant call info - not a ship');
    Ship := TShip(Obj);
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then Continue;
      if Info.TypeName <> av[2].AsString then Continue;
      if High(av) >= 4 then Object1 := TObject(av[4].AsDword) else Object1 := nil;
      if High(av) >= 5 then Object2 := TObject(av[5].AsDword) else Object2 := nil;
      if High(av) >= 6 then Param := av[6].AsInteger else Param := 0;
      av[0].AsInteger := RunCustomShipInfoActionCode(Info, ActionType, Ship, Object1, Object2, Param);
      Exit;
    end;
    av[0].AsInteger := 0;
    Exit;
  end;
  Obj := TObject(av[2].AsDword);
  av[0].AsInteger := 0;
  if Obj is TShip then
  begin
    if High(av) >= 3 then Object1 := TObject(av[3].AsDword) else Object1 := nil;
    if High(av) >= 4 then Object2 := TObject(av[4].AsDword) else Object2 := nil;
    if High(av) >= 5 then Param := av[5].AsInteger else Param := 0;
    av[0].AsInteger := (Obj as TShip).ScriptItemsAct(ActionType, Object1, Object2, Param);
  end
  else if Obj is TItem then
  begin
    if High(av) >= 3 then Ship := TShip(av[3].AsDword) else Ship := nil;
    if High(av) >= 4 then Object1 := TObject(av[4].AsDword) else Object1 := nil;
    if High(av) >= 5 then Object2 := TObject(av[5].AsDword) else Object2 := nil;
    if High(av) >= 6 then Param := av[6].AsInteger else Param := 0;
    if TItem(Obj).ScriptItem <> nil then
      av[0].AsInteger := TScriptItem(TItem(Obj).ScriptItem).RunActionCode(ActionType, Ship, Object1, Object2, Param);
    if Obj is TEquipmentWithActCode then
      av[0].AsInteger := RunItemConfigActionCode(TItem(Obj), ActionType, Ship, Object1, Object2, Param);
  end;
end;
{ @end $6320EC }

{ @routine $6324A0 SF_CurItem }
procedure SF_CurItem(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptItemContextStack.Count < 1 then av[0].AsDword := Cardinal(ScriptUseItem)
  else av[0].AsDword := Cardinal(ScriptItemContextStack[ScriptItemContextStack.Count - 1]);
end;
{ @end $6324A0 }

{ @routine $632500 SF_CurInfo }
procedure SF_CurInfo(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptItemInfoContextStack.Count < 1 then av[0].AsDword := 0
  else av[0].AsDword := Cardinal(ScriptItemInfoContextStack[ScriptItemInfoContextStack.Count - 1]);
end;
{ @end $632500 }

{ @routine $632558 SF_ScriptItemActShip }
procedure SF_ScriptItemActShip(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionShipStack.Count < 1 then av[0].AsDword := 0
  else av[0].AsDword := Cardinal(ScriptActionShipStack[ScriptActionShipStack.Count - 1]);
end;
{ @end $632558 }

{ @routine $6325B0 SF_ScriptItemActObject1 }
procedure SF_ScriptItemActObject1(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionObject1Stack.Count < 1 then av[0].AsDword := 0
  else av[0].AsDword := Cardinal(ScriptActionObject1Stack[ScriptActionObject1Stack.Count - 1]);
end;
{ @end $6325B0 }

{ @routine $632608 SF_ScriptItemActObject2 }
procedure SF_ScriptItemActObject2(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionObject2Stack.Count < 1 then av[0].AsDword := 0
  else av[0].AsDword := Cardinal(ScriptActionObject2Stack[ScriptActionObject2Stack.Count - 1]);
end;
{ @end $632608 }

{ @routine $632660 SF_ScriptItemActionType }
procedure SF_ScriptItemActionType(av: array of TVarEC; code: TCodeEC);
var
  Matches: Boolean;
begin
  if ScriptActionTypeStack.Count < 1 then av[0].AsDword := 0
  else if High(av) <= 0 then
    av[0].AsDword := Cardinal(ScriptActionTypeStack[ScriptActionTypeStack.Count - 1])
  else
  begin
    Matches := Integer(ScriptActionTypeStack[ScriptActionTypeStack.Count - 1]) = av[1].AsInteger;
    if Matches and (High(av) > 1) then
      Matches := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]) = av[2].AsInteger;
    av[0].AsDword := Ord(Matches);
  end;
end;
{ @end $632660 }

{ @routine $632720 SF_ScriptItemActParam }
procedure SF_ScriptItemActParam(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionParamStack.Count < 1 then av[0].AsInteger := 0
  else
  begin
    av[0].AsInteger := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]);
    if High(av) > 0 then ScriptActionParamStack[ScriptActionParamStack.Count - 1] := Pointer(av[1].AsInteger);
  end;
end;
{ @end $632720 }

{ @routine $6327A4 SF_OnUseCodeTranclucator }
procedure SF_OnUseCodeTranclucator(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefactTranclucator;
  Ship: TTranclucator;
  Index: Integer;
  Angle: Single;
  Entry: PStorageEntry;
  Star: TStar;
  Other: TObject;
begin
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefactTranclucator) then Item := TArtefactTranclucator(ScriptUseItem)
  else
  begin
    if (High(av) < 1) or (av[1].AsDword = 0) or
      not (TObject(av[1].AsDword) is TArtefactTranclucator) then Exit;
    Item := TArtefactTranclucator(av[1].AsDword);
  end;
  if GetPlayer = nil then Exit;
  Ship := Item.Ship as TTranclucator;
  av[0].AsDword := Cardinal(Ship);
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
        Other := Star.Ships[Index];
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
      Entry := GetPlayer.StorageEntries[Index];
      if Entry.Item <> Item then Continue;
      GetPlayer.StorageEntries.Delete(Index);
      GetPlayer.RefreshStorageBubbles;
      Dispose(Entry);
      Break;
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
{ @end $6327A4 }

{ @routine $632CBC SF_OnUseCodeTransmitter }
procedure SF_OnUseCodeTransmitter(av: array of TVarEC; code: TCodeEC);
var
  Artefact: TArtefactTransmitter;
  ShowFeedback: Boolean;
begin
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefactTransmitter) then Artefact := TArtefactTransmitter(ScriptUseItem)
  else
  begin
    if (High(av) < 1) or (av[1].AsDword = 0) or
      not (TObject(av[1].AsDword) is TArtefactTransmitter) then Exit;
    Artefact := TArtefactTransmitter(av[1].AsDword);
  end;
  if High(av) > 1 then ShowFeedback := av[2].AsInteger <> 0 else ShowFeedback := True;
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
{ @end $632CBC }

{ @routine $633040 SF_OnUseCodeBlackHole }
procedure SF_OnUseCodeBlackHole(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefact;
  Index: Integer;
  Angle, Distance: Single;
  Hole: THole;
  Event: TGalaxyEvent;
begin
  av[0].AsDword := 0;
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefact) then Item := TArtefact(ScriptUseItem)
  else
  begin
    if (High(av) < 1) or (av[1].AsDword = 0) or
      not (TObject(av[1].AsDword) is TArtefact) then Exit;
    Item := TArtefact(av[1].AsDword);
  end;
  if GetPlayer = nil then Exit;
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
    av[0].AsDword := Cardinal(Hole);
    Hole.InitializeGraphic('');
    THoleSE(Hole.Graphic).SetState(1);
    Hole.Star1 := GetPlayer.CurrentStar;
    Angle := ArcTan2(GetPlayer.Position.X, -GetPlayer.Position.Y);
    Distance := Max(GetPlayer.CurrentStar.SafeRadius + 100, Sqrt(PointDistanceSquared(GetPlayer.Position, MakePointF(0, 0))) + 200);
    Hole.Position1 := MakePointF(Sin(Angle) * Distance, -Cos(Angle) * Distance);
    Hole.Star2 := nil;
    for Index := 0 to Galaxy.Stars.Count - 1 do
    begin
      if not TStar(Galaxy.Stars[Index]).IsConstellationVisible then Continue;
      Distance := PointDistanceSquared(GetPlayer.CurrentStar.Position, TStar(Galaxy.Stars[Index]).Position);
      if (Distance > 400) and (Distance < 2500) then
        if (Hole.Star2 = nil) or (NextRandomIntRange(0, 100, GetPlayer.RandomState) < 50) then
        begin
          Hole.Star2 := Galaxy.Stars[Index];
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
{ @end $633040 }

{ @routine $633598 SF_OnUseCodeMissileDef }
procedure SF_OnUseCodeMissileDef(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
begin
  if GetPlayer = nil then Exit;
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
{ @end $633598 }

{ @routine $633734 SF_MessageBox }
procedure SF_MessageBox(av: array of TVarEC; code: TCodeEC);
var
  Options: Cardinal;
  OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MessageBox');
  if High(av) < 2 then Options := mbgCancel or mbgUnused04 else Options := av[2].AsInteger;
  if High(av) < 3 then OffsetX := 0 else OffsetX := av[3].AsInteger;
  if High(av) < 4 then OffsetY := 0 else OffsetY := av[4].AsInteger;
  ShowMessageBoxGI(GetInnermostScreenLoop, av[1].AsString, Options, 0, OffsetX, OffsetY);
end;
{ @end $633734 }

{ @routine $63382C SF_MessageBoxYesNo }
procedure SF_MessageBoxYesNo(av: array of TVarEC; code: TCodeEC);
var
  Options: Cardinal;
  OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script MessageBoxYesNo');
  if High(av) < 2 then Options := mbgOK or mbgCancel or mbgQuestion else Options := av[2].AsInteger or mbgOK or mbgCancel;
  if High(av) < 3 then OffsetX := 0 else OffsetX := av[3].AsInteger;
  if High(av) < 4 then OffsetY := 0 else OffsetY := av[4].AsInteger;
  av[0].AsInteger := 0;
  if ShowMessageBoxGI(GetInnermostScreenLoop, av[1].AsString, Options, 0, OffsetX, OffsetY) = mbgResultOK then av[0].AsInteger := 1;
end;
{ @end $63382C }

{ @routine $63394C SF_CountBox }
procedure SF_CountBox(av: array of TVarEC; code: TCodeEC);
var
  Value: Integer;
  Caption, Description: WideString;
  Minimum, Maximum, Limit, UnitValue, Available, TotalLimit: Integer;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script CountBox');
  // The native routine reads these strings here, then reads them again for the dialog call.
  Caption := av[1].AsString;
  Description := av[2].AsString;
  Minimum := av[3].AsInteger;
  Maximum := av[4].AsInteger;
  if High(av) > 4 then UnitValue := av[5].AsInteger else UnitValue := 0;
  if High(av) > 6 then Limit := av[7].AsInteger else Limit := Maximum;
  if High(av) > 7 then Available := av[8].AsInteger else Available := Maximum;
  if High(av) > 8 then TotalLimit := av[9].AsInteger else TotalLimit := 100000000;
  if High(av) > 9 then Value := av[10].AsInteger else Value := Minimum;
  if ShowCountDialog(GetInnermostScreenLoop, 'GI,' + av[1].AsString, av[2].AsString, Minimum, Maximum, Limit, UnitValue, Available, TotalLimit, Value) = 1 then av[0].AsInteger := Value
  else av[0].AsString := 'Cancel';
end;
{ @end $63394C }

{ @routine $633B34 SF_NumberBox }
procedure SF_NumberBox(av: array of TVarEC; code: TCodeEC);
var
  Value, Index: Integer;
  Caption, AlternateCaption, Description: WideString;
  Minimum, Maximum, Limit: Integer;
  Choices: TList;
  Entry: PWideString;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script NumberBox');
  Caption := 'GI,' + av[1].AsString;
  Description := av[2].AsString;
  Minimum := av[3].AsInteger;
  Maximum := av[4].AsInteger;
  if High(av) > 4 then Limit := av[5].AsInteger else Limit := Maximum;
  if (High(av) > 5) and (av[6].AsString <> '') then AlternateCaption := 'GI,' + av[6].AsString
  else AlternateCaption := '';
  if High(av) > 6 then Value := av[7].AsInteger else Value := Minimum;
  Choices := nil;
  if High(av) > 7 then
  begin
    Choices := TList.Create;
    if av[8].ValueKind = value_array then
      for Index := 0 to av[8].AsArray.Count - 1 do
      begin
        New(Entry);
        Entry^ := av[8].AsArray[Index].AsString;
        Choices.Add(Entry);
      end
    else
      for Index := 8 to High(av) do
      begin
        New(Entry);
        Entry^ := av[Index].AsString;
        Choices.Add(Entry);
      end;
  end;
  if ShowNumberDialog(GetInnermostScreenLoop, Caption, AlternateCaption, Description, Minimum, Maximum, Limit, Choices, Value) = 1 then av[0].AsInteger := Value
  else av[0].AsString := 'Cancel';
  if Choices = nil then Exit;
  while Choices.Count > 0 do
  begin
    // Native frees the pointer cell without finalizing its WideString.
    Dispose(Choices[0]);
    Choices.Delete(0);
  end;
  Choices.Free;
end;
{ @end $633B34 }

{ @routine $633DF4 SF_TextBox }
procedure SF_TextBox(av: array of TVarEC; code: TCodeEC);
var
  Caption, Value: WideString;
  MaximumLength, OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script TextBox');
  Caption := av[1].AsString;
  Value := '';
  if High(av) > 1 then Value := av[2].AsString;
  MaximumLength := 30;
  if High(av) > 2 then MaximumLength := av[3].AsInteger;
  if High(av) < 4 then OffsetX := 0 else OffsetX := av[4].AsInteger;
  if High(av) < 5 then OffsetY := 0 else OffsetY := av[5].AsInteger;
  av[0].AsString := Value;
  if ShowTextInputDialog(GetInnermostScreenLoop, Caption, Value, MaximumLength, OffsetX, OffsetY) = 1 then av[0].AsString := Value;
end;
{ @end $633DF4 }

{ @routine $633F1C SF_ListBox }
procedure SF_ListBox(av: array of TVarEC; code: TCodeEC);
var
  Caption: WideString;
  Choices: TList;
  Index, OffsetX, OffsetY: Integer;
  Entry: PWideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ListBox');
  Caption := av[1].AsString;
  Choices := TList.Create;
  Index := -1;
  if av[2].ValueKind = value_array then
    for Index := 0 to av[2].AsArray.Count - 1 do
    begin
      New(Entry);
      Entry^ := av[2].AsArray[Index].AsString;
      Choices.Add(Entry);
    end
  else
    for Index := 2 to High(av) do
    begin
      New(Entry);
      Entry^ := av[Index].AsString;
      Choices.Add(Entry);
    end;
  // The original scalar form also treats these argument positions as choices.
  if High(av) < 3 then OffsetX := 0 else OffsetX := av[3].AsInteger;
  if High(av) < 4 then OffsetY := 0 else OffsetY := av[4].AsInteger;
  if ShowListDialog(GetInnermostScreenLoop, Index, Caption, Choices, OffsetX, OffsetY) = 1 then av[0].AsInteger := Index
  else av[0].AsInteger := -1;
  while Choices.Count > 0 do
  begin
    // Native frees the pointer cell without finalizing its WideString.
    Dispose(Choices[0]);
    Choices.Delete(0);
  end;
  Choices.Free;
end;
{ @end $633F1C }

{ @routine $634140 SF_FormCurShip }
procedure SF_FormCurShip(av: array of TVarEC; code: TCodeEC);
begin
  if GetInnermostScreenLoop = HangarScreen then av[0].AsDword := Cardinal(HangarScreen.SelectedShip)
  else if GetInnermostScreenLoop = ScannerScreen then av[0].AsDword := Cardinal(ScannerScreen.ShipToInspect)
  else if GetInnermostScreenLoop = ShipScreen then av[0].AsDword := Cardinal(PlayerHoldShip)
  else av[0].AsDword := 0;
end;
{ @end $634140 }

{ @routine $6341D4 SF_UselessItemText }
procedure SF_UselessItemText(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Text: WideString;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script UselessItemText');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  Text := '';
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TUselessItem) then
  begin
    Text := (Item as TUselessItem).CustomText;
    if High(av) > 1 then (Item as TUselessItem).CustomText := av[2].AsString;
  end;
  av[0].AsString := Text;
end;
{ @end $6341D4 }

{ @routine $634318 SF_UselessItemData }
procedure SF_UselessItemData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Value, Index: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script UselessItemData');
  Obj := TObject(av[1].AsDword);
  Index := av[2].AsInteger;
  Item := nil;
  Value := 0;
  if Obj is TItem then Item := TItem(Obj);
  if Obj is TScriptItem then Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TUselessItem) and (Index > 0) and (Index <= 3) then
  begin
    Value := (Item as TUselessItem).Data[Index - 1];
    if High(av) > 2 then (Item as TUselessItem).Data[Index - 1] := av[3].AsInteger;
  end;
  av[0].AsInteger := Value;
end;
{ @end $634318 }

{ @routine $634434 SF_GetAchievementSHU }
procedure SF_GetAchievementSHU(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('SHU');
end;
{ @end $634434 }

{ @routine $634468 SF_GetAchievementGIRLSHIRE }
procedure SF_GetAchievementGIRLSHIRE(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('GIRLSHIRE');
end;
{ @end $634468 }

{ @routine $6344A8 SF_GetAchievementGIRLSQUEST }
procedure SF_GetAchievementGIRLSQUEST(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('GIRLSQUEST');
end;
{ @end $6344A8 }

{ @routine $6344EC SF_GetAchievementPIRATEWIN }
procedure SF_GetAchievementPIRATEWIN(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('PIRATEWIN');
end;
{ @end $6344EC }

{ @routine $63452C SF_GetAchievementCOALLITION }
procedure SF_GetAchievementCOALLITION(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('COALLITION');
end;
{ @end $63452C }

{ @routine $634570 SF_GetAchievementHULL }
procedure SF_GetAchievementHULL(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('HULL');
end;
{ @end $634570 }

{ @routine $6345A8 SF_UICheckElement }
procedure SF_UICheckElement(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path, Query: WideString;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script UICheckElement');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  Control := nil;
  if FormName = '' then Form := GetInnermostScreenLoop else Form := FindMessageLoop(FormName);
  if Form <> nil then Control := Form.FindControlByPath(Path);
  if Control = nil then raise Exception.Create('Error.Script UICheckElement - cant find ' + Path + ' (' + FormName + ')');
  Query := av[3].AsString;
  if Query = 'IsActive' then
  begin
    av[0].AsInteger := Ord(Control.Active);
    Exit;
  end;
  if Query = 'PosX' then
  begin
    av[0].AsInteger := Control.LocalPosition.X;
    Exit;
  end;
  if Query = 'PosY' then
  begin
    av[0].AsInteger := Control.LocalPosition.Y;
    Exit;
  end;
  if Query = 'SizeX' then
  begin
    av[0].AsInteger := Control.ClientSize.X;
    Exit;
  end;
  if Query = 'SizeY' then
  begin
    av[0].AsInteger := Control.ClientSize.Y;
    Exit;
  end;
  if Query = 'IsDisable' then
  begin
    if not (Control is TGraphButtonGI) then raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a button');
    av[0].AsInteger := Ord(TGraphButtonGI(Control).Disabled);
    Exit;
  end;
  if Query = 'Text' then
  begin
    if Control is TEditGI then
    begin
      av[0].AsString := TEditGI(Control).Text;
      if High(av) > 3 then TEditGI(Control).SetText(av[4].AsString);
    end
    else if Control is TLabelGI then av[0].AsString := TLabelGI(Control).GetText
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a label or edit');
    Exit;
  end;
  if Query = 'Help' then
  begin
    av[0].AsString := Control.HelpText;
    if High(av) > 3 then Control.HelpText := av[4].AsString;
    Exit;
  end;
  if Query = 'CursorPos' then
  begin
    if Control is TEditGI then
    begin
      av[0].AsInteger := TEditGI(Control).CaretPosition;
      if High(av) > 3 then TEditGI(Control).SetCaretPosition(av[4].AsInteger);
    end
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not an edit');
    Exit;
  end;
  if Query = 'IsFocused' then
  begin
    av[0].AsInteger := Ord(Form.FocusedControl = Control);
    Exit;
  end;
  if Query = 'Image' then
  begin
    if Control is TgaiGI then
    begin
      av[0].AsString := TgaiGI(Control).GetImagePath;
      if TgaiGI(Control).GetFirstFrameImagePath <> '' then
        av[0].AsString := av[0].AsString + '|' + TgaiGI(Control).GetFirstFrameImagePath;
    end
    else if Control is TgiGI then av[0].AsString := TgiGI(Control).GetImagePath
    else if Control is TImageGI then av[0].AsString := TImageGI(Control).GetImagePath
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a image');
    Exit;
  end;
  if Query = 'CurFrame' then
  begin
    if not (Control is TgaiGI) then raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a gai');
    av[0].AsInteger := TgaiGI(Control).SequenceFrame;
    if High(av) > 3 then TgaiGI(Control).SetSequenceFrame(av[4].AsInteger);
    Exit;
  end;
  if Query = 'IsDown' then
  begin
    if Control is TGraphButtonGI then
    begin
      av[0].AsInteger := Ord(TGraphButtonGI(Control).Down);
      if High(av) > 3 then TGraphButtonGI(Control).SetDown(av[4].AsInteger <> 0);
    end
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a button');
    Exit;
  end;
  if Query = 'Rescale' then
  begin
    if Control is TGraphBufGI then
    begin
      if High(av) < 4 then raise Exception.Create('Error.Script UICheckElement - Rescale option can not be used without image path');
      if (High(av) > 4) and (av[5].AsString = 'GI') then TGraphBufGI(Control).LoadScaledGiPath(av[4].AsString)
      else TGraphBufGI(Control).LoadScaledBitmapPathAsRgba(av[4].AsString);
    end
    else raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a graph buffer');
    Exit;
  end;
  raise Exception.Create('Error.Script UICheckElement - query not recognized - ' + Query);
end;
{ @end $6345A8 }

{ @routine $635174 SF_InterfaceState }
procedure SF_InterfaceState(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  Entry: TInterfaceStateOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script InterfaceState');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      av[0].AsInteger := Ord(Control.Active);
      if (Control is TGraphButtonGI) and TGraphButtonGI(Control).Disabled and Control.Active then av[0].AsInteger := 2;
      if High(av) > 2 then
      begin
        Control.SetActive(av[3].AsInteger > 0);
        if (av[3].AsInteger > 1) and (Control is TGraphButtonGI) then TGraphButtonGI(Control).SetDisabled(av[3].AsInteger = 2);
      end;
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceStateOverrides.Count - 1 do
  begin
    Entry := Galaxy.InterfaceStateOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then Continue;
    av[0].AsInteger := Entry.GetState;
    if High(av) > 2 then
    begin
      if av[3].AsInteger < 0 then
      begin
        Galaxy.InterfaceStateOverrides.Delete(I);
        Entry.Free;
      end
      else Entry.SetState(av[3].AsInteger);
    end;
    Exit;
  end;
  av[0].AsInteger := -1;
  if (High(av) <= 2) or (av[3].AsInteger < 0) then Exit;
  Entry := TInterfaceStateOverride.Create;
  Galaxy.InterfaceStateOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, av[3].AsInteger);
end;
{ @end $635174 }

{ @routine $6354C0 SF_InterfaceText }
procedure SF_InterfaceText(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  Entry: TInterfaceTextOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script InterfaceText');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      if not (Control is TLabelGI) then raise Exception.Create('Object is not a label - ' + Path);
      av[0].AsString := TLabelGI(Control).GetText;
      if High(av) > 2 then TLabelGI(Control).SetText(av[3].AsString);
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceTextOverrides.Count - 1 do
  begin
    Entry := Galaxy.InterfaceTextOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then Continue;
    av[0].AsString := Entry.GetText;
    if High(av) > 2 then
    begin
      if av[3].AsString = '' then
      begin
        Galaxy.InterfaceTextOverrides.Delete(I);
        Entry.Free;
      end
      else Entry.SetText(av[3].AsString);
    end;
    Exit;
  end;
  av[0].AsString := '';
  if (High(av) <= 2) or (av[3].AsString = '') then Exit;
  Entry := TInterfaceTextOverride.Create;
  Galaxy.InterfaceTextOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, av[3].AsString);
end;
{ @end $6354C0 }

{ @routine $635864 SF_InterfaceImage }
procedure SF_InterfaceImage(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  Entry: TInterfaceImageOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script InterfaceImage');
  FormName := av[1].AsString;
  Path := av[2].AsString;
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
      av[0].AsString := TgaiGI(Control).GetImagePath;
      if TgaiGI(Control).GetFirstFrameImagePath <> '' then
        av[0].AsString := av[0].AsString + '|' + TgaiGI(Control).GetFirstFrameImagePath;
    end
      else if Control is TgiGI then av[0].AsString := TgiGI(Control).GetImagePath
      else if Control is TImageGI then av[0].AsString := TImageGI(Control).GetImagePath
      else av[0].AsString := Control.ConfigPath;
      if High(av) > 2 then
      begin
        if (CountDelimitedPartsW(av[3].AsString, ':') > 1) and
          (ExtractDelimitedPartW(av[3].AsString, 0, ':') = 'Style') then
          Control.SetConfigPath(ExtractDelimitedPartW(av[3].AsString, 1, ':'))
        else if Control is TgaiGI then begin
          if CountDelimitedPartsW(av[3].AsString, '|') < 2 then
            TgaiGI(Control).SetImagePath(av[3].AsString)
          else
          begin
            TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(av[3].AsString, 1, '|'));
            TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(av[3].AsString, 0, '|'));
          end;
          TgaiGI(Control).PrimeImageCaches;
          TgaiGI(Control).SequenceIndex := 0;
          TgaiGI(Control).UpdateAutoGeometry;
          TgaiGI(Control).RestartPlayback;
        end
        else if Control is TgiGI then TgiGI(Control).SetImagePath(av[3].AsString)
        else if Control is TImageGI then TImageGI(Control).SetImagePath(av[3].AsString)
        else raise Exception.Create('Object is not an image - ' + Path);
      end;
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceImageOverrides.Count - 1 do
  begin
    Entry := Galaxy.InterfaceImageOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then Continue;
    av[0].AsString := Entry.GetImagePath;
    if High(av) > 2 then
    begin
      if av[3].AsString = '' then
      begin
        Galaxy.InterfaceImageOverrides.Delete(I);
        Entry.Free;
      end
      else Entry.SetImagePath(av[3].AsString);
    end;
    Exit;
  end;
  av[0].AsString := '';
  if (High(av) <= 2) or (av[3].AsString = '') then Exit;
  Entry := TInterfaceImageOverride.Create;
  Galaxy.InterfaceImageOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, av[3].AsString);
end;
{ @end $635864 }

{ @routine $635E6C SF_InterfacePos }
procedure SF_InterfacePos(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  X, Y, Z: Integer;
  Entry: TInterfacePosOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 5 then raise Exception.Create('Error.Script InterfacePos');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  X := av[3].AsInteger;
  Y := av[4].AsInteger;
  Z := av[5].AsInteger;
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
    Entry := Galaxy.InterfacePositionOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then Continue;
    if (X = 0) and (Y = 0) and (Z = 0) then
    begin
      Galaxy.InterfacePositionOverrides.Delete(I);
      Entry.Free;
    end
    else Entry.SetPosition(X, Y, Z);
    Exit;
  end;
  if (X = 0) and (Y = 0) and (Z = 0) then Exit;
  Entry := TInterfacePosOverride.Create;
  Galaxy.InterfacePositionOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, X, Y, Z);
end;
{ @end $635E6C }

{ @routine $636140 SF_InterfaceSize }
procedure SF_InterfaceSize(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  X, Y: Integer;
  Entry: TInterfaceSizeOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script InterfaceSize');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  X := av[3].AsInteger;
  Y := av[4].AsInteger;
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
    Entry := Galaxy.InterfaceSizeOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then Continue;
    if (X = 0) and (Y = 0) then
    begin
      Galaxy.InterfaceSizeOverrides.Delete(I);
      Entry.Free;
    end
    else Entry.SetSize(X, Y);
    Exit;
  end;
  if (X = 0) and (Y = 0) then Exit;
  Entry := TInterfaceSizeOverride.Create;
  Galaxy.InterfaceSizeOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, X, Y);
end;
{ @end $636140 }

{ @routine $6363E4 SF_ButtonClick }
procedure SF_ButtonClick(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  Control: TObjectGI;
  Form: TMessageLoopGI;
  Button: TGraphButtonGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ButtonClick');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if FormName = '' then Form := GetInnermostScreenLoop else Form := FindMessageLoop(FormName);
  if Form = nil then raise Exception.Create('Error.Script ButtonClick - ML not found');
  Control := Form.FindControlByPath(Path);
  if Control = nil then raise Exception.Create('Error.Script ButtonClick - Object not found');
  if not (Control is TGraphButtonGI) then raise Exception.Create('Error.Script ButtonClick - Object not a button');
  Button := Control as TGraphButtonGI;
  if (High(av) < 3) or (av[3].ValueKind <> value_string) or (av[3].AsString = 'AllCode') then
  begin
    if Assigned(Button.UpCallback) then Button.UpCallback(Button)
    else if Assigned(Button.DownCallback) then Button.DownCallback(Button);
  end;
  if (High(av) > 2) and ((av[3].AsString = 'ScriptCode') or (av[3].AsString = 'AllCode')) then
    if Button.OnPressCode <> nil then
    begin
      Form.ExecuteUiCode(Button.OnPressCode, 0);
      Form.RefreshMouseDispatch;
    end;
end;
{ @end $6363E4 }

{ @routine $6366CC SF_SetFocus }
procedure SF_SetFocus(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetFocus');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if FormName = '' then Form := GetInnermostScreenLoop else Form := FindMessageLoop(FormName);
  if Form = nil then raise Exception.Create('Error.Script SetFocus - ML not found');
  Control := Form.FindControlByPath(Path);
  if Control = nil then raise Exception.Create('Error.Script SetFocus - Object not found');
  Form.SetFocusedControl(Control);
end;
{ @end $6366CC }

{ @routine $63683C SF_FormShipCurItem }
procedure SF_FormShipCurItem(av: array of TVarEC; code: TCodeEC);
var
  Query: Integer;
  Item: TObject;
begin
  if GetInnermostScreenLoop <> ShipScreen then raise Exception.Create('Error.Script FormShipCurItem');
  if High(av) < 1 then
  begin
    if not (ShipScreen.SelectedHoldKind in [hold_equipment, hold_artefact]) then av[0].AsDword := 0
    else av[0].AsDword := Cardinal(ShipScreen.SelectedHoldItem);
    Exit;
  end;

  if av[1].ValueKind = value_string then
  begin
    if av[1].AsString = 'MoveType' then Query := 0
    else if av[1].AsString = 'StackableType' then Query := 1
    else if av[1].AsString = 'StackableCount' then Query := 2
    else if av[1].AsString = 'StackableCost' then Query := 3
    else if av[1].AsString = 'PutBack' then Query := 4
    else if av[1].AsString = 'Destroy' then Query := 5
    else if av[1].AsString = 'Detach' then Query := 6
    else if av[1].AsString = 'Replace' then Query := 7
    else raise Exception.Create('Error.Script FormShipCurItem - query not recognized: ' + av[1].AsString);
  end
  // The native numeric-query path reads argument 3, without an additional arity check.
  else Query := av[3].AsInteger;
  case Query of
    0: av[0].AsInteger := Integer(ShipScreen.SelectedHoldKind);
    1: av[0].AsInteger := ShipScreen.SelectedGoodsIndex;
    2: av[0].AsInteger := ShipScreen.SelectedGoodsQuantity;
    3: av[0].AsInteger := ShipScreen.SelectedGoodsCost;
    4: ShipScreen.ReturnSelectedHoldEntry;
    5: begin
      if ShipScreen.SelectedHoldItem <> nil then ShipScreen.SelectedHoldItem.Free;
      ShipScreen.SelectedHoldItem := nil;
      ShipScreen.SelectedHoldKind := hold_empty;
      PlayerHoldShip.RefreshDerivedStats(True);
      if not ShipScreen.IsCursorImageSelected('Main') then ShipScreen.SetCursorByName('Main');
      ShipScreen.RefreshShipView;
    end;
    6: begin
      av[0].AsDword := Cardinal(ShipScreen.SelectedHoldItem);
      ShipScreen.SelectedHoldItem := nil;
      ShipScreen.SelectedHoldKind := hold_empty;
      PlayerHoldShip.RefreshDerivedStats(True);
      if not ShipScreen.IsCursorImageSelected('Main') then ShipScreen.SetCursorByName('Main');
      ShipScreen.RefreshShipView;
    end;
    7: begin
      if (High(av) < 2) or (av[2].AsDword = 0) then raise Exception.Create('Error.Script FormShipCurItem no replacing item');
      if (ShipScreen.SelectedHoldItem = nil) or not (ShipScreen.SelectedHoldKind in [hold_equipment, hold_artefact]) then
        raise Exception.Create('Error.Script FormShipCurItem no item to replace');
      Item := TObject(av[2].AsDword);
      av[0].AsDword := Cardinal(ShipScreen.SelectedHoldItem);
      ShipScreen.SelectedHoldItem := TItem(Item);
      if Item is TArtefact then ShipScreen.SelectedHoldKind := hold_artefact else ShipScreen.SelectedHoldKind := hold_equipment;
      PlayerHoldShip.RefreshDerivedStats(True);
      ShipScreen.UpdateActionCursor(True);
      ShipScreen.RefreshShipView;
    end;
  else
    // Native creates this exception without raising or freeing it.
    Exception.Create('Error.Script FormShipCurItem - query not recognized: ' + IntToWideString(Query));
  end;
end;
{ @end $63683C }

{ @routine $636F3C SF_UpdateFormShip }
procedure SF_UpdateFormShip(av: array of TVarEC; code: TCodeEC);
begin
  if GetInnermostScreenLoop <> ShipScreen then Exit;
  ShipScreen.ShipStateChanged := True;
  ShipScreen.ReopenRequested := True;
  ShipScreen.PlayTransitionSounds := False;
  ShipScreen.CloseClicked(nil);
end;
{ @end $636F3C }

{ @routine $636FA4 SF_CurrentForm }
procedure SF_CurrentForm(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsString := GetInnermostScreenLoop.RegisteredLoopName;
end;
{ @end $636FA4 }

{ @routine $636FD4 SF_FormChange }
procedure SF_FormChange(av: array of TVarEC; code: TCodeEC);
var
  Id: TGameScreenId;
  Name: WideString;
begin
  if High(av) < 1 then
  begin
    if RegisteredScreens[RequestedScreenId] = nil then av[0].AsString := ''
    else av[0].AsString := TMessageLoopGI(RegisteredScreens[RequestedScreenId]).RegisteredLoopName;
    Exit;
  end;

  Name := av[1].AsString;
  for Id := screen_none to screen_achievements do
    if (RegisteredScreens[Id] <> nil) and
      (RegisteredScreens[Id] is TMessageLoopGI) and
      ((RegisteredScreens[Id] as TMessageLoopGI).RegisteredLoopName = Name) then
    begin
      RequestedScreenId := Id;
      if ShipScreen = RegisteredScreens[Id] then
      begin
        if High(av) >= 2 then ShipScreen.ShipToInspect := TShip(av[2].AsDword);
        ShipReturnScreenId := CurrentScreenId;
        if (CurrentScreenId = screen_star_map) or
          not (RegisteredScreens[CurrentScreenId] is TMessageLoopGIWithMainPanel) or
          (TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel = nil) then
        begin
          ShipReturnScreenId := CurrentScreenId;
          GetInnermostScreenLoop.RequestClose(1);
        end
        else TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.ShipClicked(nil);
        Exit;
      end;
      if ScannerScreen = RegisteredScreens[Id] then
      begin
        if High(av) >= 2 then ScannerTarget := TObject(av[2].AsDword) else ScannerTarget := nil;
        ScannerReturnScreenId := FormToId(GetInnermostScreenLoop);
      end;
      GetInnermostScreenLoop.RequestClose(1);
      Exit;
    end;
  raise Exception.Create('Error.Script FormChange - ML not found');
end;
{ @end $636FD4 }

{ @routine $637240 SF_RunChildForm }
procedure SF_RunChildForm(av: array of TVarEC; code: TCodeEC);
var
  Id: TGameScreenId;
  Name: WideString;
  Parent, Root, Child: TMessageLoopGI;
  Background, ChildBackground: TObjectGI;
  State: TCursorStateGI;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script RunChildForm');
  Name := av[1].AsString;
  for Id := screen_none to screen_achievements do
  begin
    if (RegisteredScreens[Id] = nil) or
      not (RegisteredScreens[Id] is TMessageLoopGI) or
      ((RegisteredScreens[Id] as TMessageLoopGI).RegisteredLoopName <> Name) then Continue;
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
    if (Child = GalaxyScreen) and (High(av) >= 2) then GalaxyScreen.ViewMode := av[2].AsInteger;
    if Child.Run = 1 then av[0].AsInteger := 1 else av[0].AsInteger := 0;
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
{ @end $637240 }

{ @routine $637540 SF_OpenCustomForm }
procedure SF_OpenCustomForm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script OpenCustomForm');
  av[0].AsInteger := ShowCustomDialog(GetInnermostScreenLoop, av[1].AsString);
end;
{ @end $637540 }

{ @routine $6375F0 SF_CloseCustomForm }
procedure SF_CloseCustomForm(av: array of TVarEC; code: TCodeEC);
var
  ResultCode: Integer;
begin
  if CurrentCustomDialog = nil then raise Exception.Create('Error.Script CloseCustomForm - no custom form');
  if High(av) > 0 then ResultCode := av[1].AsInteger else ResultCode := 1;
  CurrentCustomDialog.RequestClose(ResultCode);
end;
{ @end $6375F0 }

{ @routine $637688 SF_CustomInterfaceState }
procedure SF_CustomInterfaceState(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomInterfaceState');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfaceState - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfaceState - object not found');
  av[0].AsInteger := Ord(Control.Active);
  if High(av) > 1 then Control.SetActive(av[2].AsInteger > 0);
  if Control is TGraphButtonGI then
  begin
    if Control.Active then av[0].AsInteger := Ord(TGraphButtonGI(Control).Disabled) + av[0].AsInteger;
    if High(av) > 1 then TGraphButtonGI(Control).SetDisabled(av[2].AsInteger = 2);
  end;
end;
{ @end $637688 }

{ @routine $637860 SF_CustomInterfaceText }
procedure SF_CustomInterfaceText(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomInterfaceText');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfaceText - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfaceText - object not found: ' + av[1].AsString);
  if Control is TLabelGI then av[0].AsString := TLabelGI(Control).GetText
  else if Control is TEditGI then av[0].AsString := TEditGI(Control).Text
  else raise Exception.Create('Error.Script CustomInterfaceText - object is not a label or edit: ' + av[1].AsString);
  if High(av) > 1 then
  begin
    if Control is TLabelGI then TLabelGI(Control).SetText(av[2].AsString)
    else if Control is TEditGI then TEditGI(Control).SetText(av[2].AsString);
  end;
end;
{ @end $637860 }

{ @routine $637BB8 SF_CustomInterfaceImage }
procedure SF_CustomInterfaceImage(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script CustomInterfaceImage');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfaceImage - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfaceImage - object not found: ' + av[1].AsString);
  if Control is TgaiGI then
    begin
      av[0].AsString := TgaiGI(Control).GetImagePath;
      if TgaiGI(Control).GetFirstFrameImagePath <> '' then
        av[0].AsString := av[0].AsString + '|' + TgaiGI(Control).GetFirstFrameImagePath;
    end
      else if Control is TgiGI then av[0].AsString := TgiGI(Control).GetImagePath
      else if Control is TImageGI then av[0].AsString := TImageGI(Control).GetImagePath
      else av[0].AsString := Control.ConfigPath;
  if High(av) <= 1 then Exit;
  if (CountDelimitedPartsW(av[2].AsString, ':') > 1) and
        (ExtractDelimitedPartW(av[2].AsString, 0, ':') = 'Style') then
        Control.SetConfigPath(ExtractDelimitedPartW(av[2].AsString, 1, ':'))
      else if Control is TgaiGI then begin
        if CountDelimitedPartsW(av[2].AsString, '|') < 2 then
          TgaiGI(Control).SetImagePath(av[2].AsString)
        else
        begin
          TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(av[2].AsString, 1, '|'));
          TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(av[2].AsString, 0, '|'));
        end;
        TgaiGI(Control).PrimeImageCaches;
        TgaiGI(Control).SequenceIndex := 0;
        TgaiGI(Control).UpdateAutoGeometry;
        TgaiGI(Control).RestartPlayback;
      end
      else if Control is TgiGI then TgiGI(Control).SetImagePath(av[2].AsString)
      else if Control is TImageGI then TImageGI(Control).SetImagePath(av[2].AsString)
      else raise Exception.Create('Error.Script CustomInterfaceImage - object is not a image: ' + av[1].AsString);
end;
{ @end $637BB8 }

{ @routine $6380E4 SF_CustomInterfacePos }
procedure SF_CustomInterfacePos(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script CustomInterfacePos');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfacePos - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfacePos - object not found');
  Control.SetPosition(Point(av[2].AsInteger, av[3].AsInteger));
end;
{ @end $6380E4 }

{ @routine $63826C SF_CustomInterfacePosZ }
procedure SF_CustomInterfacePosZ(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script CustomInterfacePosZ');
  Form := CurrentCustomDialog;
  if Form = nil then raise Exception.Create('Error.Script CustomInterfacePosZ - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then raise Exception.Create('Error.Script CustomInterfacePosZ - object not found');
  Control.SetDepth(av[2].AsInteger);
end;
{ @end $63826C }

{ @routine $6383F0 SF_CustomInterfaceSize }
procedure SF_CustomInterfaceSize(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script CustomInterfacePos');
  Obj := CurrentCustomDialog;
  if Obj = nil then raise Exception.Create('Error.Script CustomInterfacePos - no custom form');
  Obj := TMessageLoopGI(Obj).FindControlByPath(av[1].AsString);
  if Obj = nil then raise Exception.Create('Error.Script CustomInterfacePos - object not found');
  TObjectGI(Obj).SetSize(Point(av[2].AsInteger, av[3].AsInteger));
end;
{ @end $6383F0 }

{ @routine $638578 SF_StarMapCenterView }
procedure SF_StarMapCenterView(av: array of TVarEC; code: TCodeEC);
var
  Position: TPointF;
  Index, Count: Integer;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script StarMapCenterView');
  Position.X := av[1].AsInteger;
  Position.Y := av[2].AsInteger;
  StarMapScreen.SetMapCenterManually(TruncatePointF(Position));
  SpaceViewPosition := Position;
  if (High(av) < 3) or (RegisteredScreens[CurrentScreenId] <> StarMapScreen) then Exit;
  Count := av[3].AsInteger;
  for Index := 0 to Count - 1 do
    StarMapScreen.AddMapAnimation(Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 200 * Index);
end;
{ @end $638578 }

{ @routine $6386F8 SF_StarMapCurPosX }
procedure SF_StarMapCurPosX(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := StarMapScreen.GetMapCenter.X;
end;
{ @end $6386F8 }

{ @routine $638734 SF_StarMapCurPosY }
procedure SF_StarMapCurPosY(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := StarMapScreen.GetMapCenter.Y;
end;
{ @end $638734 }

{ @routine $638770 SF_StarMapCustomSelectionMode }
procedure SF_StarMapCustomSelectionMode(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 10 then raise Exception.Create('Error.Script StarMapCustomSelectionMode');
  if GetInnermostScreenLoop <> StarMapScreen then Exit;
  if av[1].ValueKind = value_string then
  begin
    StarMapScreen.CustomSelectionInfoName := av[1].AsString;
    StarMapScreen.CustomSelectionItem := nil;
  end
  else
  begin
    StarMapScreen.CustomSelectionInfoName := '';
    StarMapScreen.CustomSelectionItem := TItem(av[1].AsDword);
  end;
  StarMapScreen.CustomSelectionRadius := av[2].AsInteger;
  StarMapScreen.CustomSelectionAllowedCursor := av[3].AsString;
  StarMapScreen.CustomSelectionDeniedCursor := av[4].AsString;
  StarMapScreen.CustomSelectionSuccessText := av[5].AsString;
  StarMapScreen.CustomSelectionOutOfRangeText := av[6].AsString;
  StarMapScreen.CustomSelectionFailureText := av[7].AsString;
  StarMapScreen.CustomSelectionColor := CurrentPixelFormat.PackRgb(av[8].AsInteger, av[9].AsInteger, av[10].AsInteger);
  StarMapScreen.BeginCustomSelection;
end;
{ @end $638770 }

{ @routine $638948 SF_StarMapBlinkingMessage }
procedure SF_StarMapBlinkingMessage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script StarMapBlinkingMessage');
  StarMapScreen.ShowLargeHelp(av[1].AsString);
end;
{ @end $638948 }

{ @routine $6389F8 SF_BlinkingWarning }
procedure SF_BlinkingWarning(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then raise Exception.Create('Error.Script BlinkingWarning');
  if av[1].AsString = 'Money' then
  begin
    if CurrentScreenId = screen_ship then ShipScreen.StartMoneyWarning
    else if (CurrentScreenId = screen_goods_shop) and GetPlayer.InNormalSpace then GoodsShopScreen.FlashMoneyWarning
    else if RegisteredScreens[CurrentScreenId] is TMessageLoopGIWithMainPanel then
      TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.FlashMoneyWarning;
  end
  else if (av[1].AsString = 'Space') then
    if (CurrentScreenId <> screen_ship) then
  begin
    if (CurrentScreenId = screen_goods_shop) and GetPlayer.InNormalSpace then GoodsShopScreen.FlashCargoWarning
    else if RegisteredScreens[CurrentScreenId] is TMessageLoopGIWithMainPanel then
      TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.FlashCargoWarning;
  end;
end;
{ @end $6389F8 }

{ @routine $638BD8 SF_CustomWeaponTypes }
procedure SF_CustomWeaponTypes(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then av[0].AsInteger := Galaxy.CustomWeaponTypes.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Galaxy.CustomWeaponTypes.Count > Index) then
      av[0].AsString := PWeaponInfo(Galaxy.CustomWeaponTypes[Index]).ConfigName
    else av[0].AsString := '';
  end;
end;
{ @end $638BD8 }

{ @routine $638C60 SF_InventNewCustomWeapon }
procedure SF_InventNewCustomWeapon(av: array of TVarEC; code: TCodeEC);
var
  Info, Base: PWeaponInfo;
  Kind: TItemType;
  I: Integer;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script InventNewCustomWeapon');
  Info := Galaxy.GetOrCreateCustomWeaponInfo(av[1].AsString);
  av[0].AsDword := Cardinal(Info);
  if High(av) > 1 then Kind := TItemType(av[2].AsInteger) else Kind := item_industrial_laser;
  if not (Kind in [item_industrial_laser..item_lirecron]) then raise Exception.Create(AnsiString('Error.Script InventNewCustomWeapon - invalid type ' + av[2].AsString));
  Base := @WeaponInfos[Kind];
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
  for I := Low(Info.DamageScaleByLevel) to High(Info.DamageScaleByLevel) do Info.DamageScaleByLevel[I] := Base.DamageScaleByLevel[I];
end;
{ @end $638C60 }

{ @routine $638ECC SF_GetCustomWeaponInfo }
procedure SF_GetCustomWeaponInfo(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetCustomWeaponInfo');
  av[0].AsDword := Cardinal(Galaxy.RequireCustomWeaponInfo(av[1].AsString));
end;
{ @end $638ECC }

{ @routine $638F84 SF_GetCustomWeaponData }
procedure SF_GetCustomWeaponData(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
  Key: WideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script GetCustomWeaponStats');
  if av[1].ValueKind = value_string then Info := Galaxy.RequireCustomWeaponInfo(av[1].AsString)
  else Info := @WeaponInfos[TItemType(av[1].AsInteger)];
  Key := av[2].AsString;
  if Key = 'TechLevel' then av[0].AsInteger := Info.TechLevel
  else if Key = 'AverageSize' then av[0].AsInteger := Info.AverageSize
  else if Key = 'AverageRadius' then av[0].AsInteger := Info.AverageRange
  else if Key = 'MissileRadius' then av[0].AsInteger := Info.MissileRange
  else if Key = 'SecondaryDamageRadius' then av[0].AsFloat := Info.SecondaryDamageRadius
  else if Key = 'MaxDamage' then av[0].AsInteger := Info.MaxDamage
  else if Key = 'MinDamage' then av[0].AsInteger := Info.MinDamage
  else if Key = 'DamageType' then av[0].AsDword := Dword(Info.DamageFlags)
  else if Key = 'kCost' then av[0].AsFloat := Info.CostFactor
  else if Key = 'AttackCount' then av[0].AsInteger := Info.AttackCount
  else if Key = 'ShotCount' then av[0].AsInteger := Info.ShotCount
  else if Key = 'ShotType' then
    case Info.ShotType of
      shot_single_target: av[0].AsString := 'Normal';
      shot_splash: av[0].AsString := 'Splash';
      shot_explode_on_kill: av[0].AsString := 'Exploder';
      shot_area_damage: av[0].AsString := 'AreaDamage';
      shot_torpedo: av[0].AsString := 'Torpedo';
      shot_missile: av[0].AsString := 'Missile';
      shot_rocket: av[0].AsString := 'Rocket';
      shot_chain: av[0].AsString := 'Chain';
    end
  else if Key = 'Availability' then
    case Info.Availability of
      availability_unrestricted: av[0].AsString := 'Free';
      availability_coalition_only: av[0].AsString := 'CoalitionOnly';
      availability_pirate_only: av[0].AsString := 'PirateOnly';
      availability_not_sold: av[0].AsString := 'NotSold';
      availability_not_sold_node_repair: av[0].AsString := 'NotSoldAndNodeRepair';
      availability_maloc_only: av[0].AsString := 'MalocOnly';
      availability_peleng_only: av[0].AsString := 'PelengOnly';
      availability_human_only: av[0].AsString := 'PeopleOnly';
      availability_feyan_only: av[0].AsString := 'FeiOnly';
      availability_gaal_only: av[0].AsString := 'GaalOnly';
      availability_system_only: av[0].AsString := 'SystemOnly';
    else raise Exception.Create('Error.Script GetCustomWeaponStats - unknown availability type');
    end
  else raise Exception.Create(AnsiString('Error.Script GetCustomWeaponStats - unknown stat ' + Key));
end;
{ @end $638F84 }

{ @routine $6397E8 SF_GetCustomWeaponPrimaryDamageType }
procedure SF_GetCustomWeaponPrimaryDamageType(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script GetCustomWeaponPrimaryDamageType');
  if av[1].ValueKind = value_string then Info := Galaxy.RequireCustomWeaponInfo(av[1].AsString)
  else Info := @WeaponInfos[TItemType(av[1].AsInteger)];
  av[0].AsInteger := Ord(ClassifyWeaponDamageFlags(Info.DamageFlags));
end;
{ @end $6397E8 }

{ @routine $6398E8 SF_SetCustomWeaponAvailability }
procedure SF_SetCustomWeaponAvailability(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
  Text: WideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetCustomWeaponAvailability');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := Cardinal(Info);
  Text := av[2].AsString;
  if Text = 'Free' then Info.Availability := availability_unrestricted
  else if Text = 'CoalitionOnly' then Info.Availability := availability_coalition_only
  else if Text = 'PirateOnly' then Info.Availability := availability_pirate_only
  else if Text = 'NotSold' then Info.Availability := availability_not_sold
  else if Text = 'NotSoldAndNodeRepair' then Info.Availability := availability_not_sold_node_repair
  else if Text = 'MalocOnly' then Info.Availability := availability_maloc_only
  else if Text = 'PelengOnly' then Info.Availability := availability_peleng_only
  else if Text = 'PeopleOnly' then Info.Availability := availability_human_only
  else if Text = 'FeiOnly' then Info.Availability := availability_feyan_only
  else if Text = 'GaalOnly' then Info.Availability := availability_gaal_only
  else if Text = 'SystemOnly' then Info.Availability := availability_system_only
  else Info.Availability := availability_unrestricted;
end;
{ @end $6398E8 }

{ @routine $639BC4 SF_SetCustomWeaponPrimaryData }
procedure SF_SetCustomWeaponPrimaryData(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script SetCustomWeaponPrimaryData');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := Cardinal(Info);
  Info.TechLevel := av[2].AsInteger;
  if not (TItemType(av[3].AsInteger) in [item_industrial_laser..item_lirecron]) then
    raise Exception.Create('Error.Script SetCustomWeaponPrimaryData invalid tech');
  Info.InventionIndex := WeaponInfos[TItemType(av[3].AsInteger)].InventionIndex;
  Info.ArcadeWeaponType := av[4].AsInteger;
end;
{ @end $639BC4 }

{ @routine $639CE4 SF_SetCustomWeaponSizeAndCost }
procedure SF_SetCustomWeaponSizeAndCost(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 3 then raise Exception.Create('Error.Script SetCustomWeaponSizeAndCost');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := Cardinal(Info);
  Info.CostFactor := av[2].AsFloat;
  Info.AverageSize := av[3].AsInteger;

end;
{ @end $639CE4 }

{ @routine $639D7C SF_SetCustomWeaponDamageData }
procedure SF_SetCustomWeaponDamageData(av: array of TVarEC; code: TCodeEC);
const EmptyFlags = [];
var
  Info: PWeaponInfo;
  Flag: Byte;
  Flags: TDamageFlagSet;
  I, Count: Integer;
  Text: WideString;
begin
  if High(av) < 4 then raise Exception.Create('Error.Script SetCustomWeaponDamageData');
  while True do
  begin
    Info := PWeaponInfo(av[1].AsDword);
    av[0].AsDword := Cardinal(Info);
    Info.MinDamage := av[2].AsInteger;
    Info.MaxDamage := av[3].AsInteger;
    Flags := EmptyFlags;
    if av[4].ValueKind = value_string then
    begin
      Text := ',' + av[4].AsString + ',';
      for Flag := Low(WeaponDamageFlagNames) to High(WeaponDamageFlagNames) do
        if Pos(',' + WeaponDamageFlagNames[Flag] + ',', Text) > 0 then Include(Flags, TDamageFlag(Flag));
      Break;
    end
    else
    begin
      Dword(Flags) := av[4].AsDword;
      Break;
    end;
  end;
  Info.DamageFlags := Flags;
  if (High(av) > 4) and (av[5].ValueKind = value_string) then
  begin
    Text := av[5].AsString;
    Count := CountDelimitedPartsW(Text, ',');
    for I := Low(Info.DamageScaleByLevel) to Min(High(Info.DamageScaleByLevel), Count) do
      Info.DamageScaleByLevel[I] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, I - 1, ','));
    Exit;
  end;
  for I := Low(Info.DamageScaleByLevel) to Min(High(Info.DamageScaleByLevel), High(av) - 4) do
    if not (av[4 + I].ValueKind in [value_int32, value_uint32]) or (av[4 + I].AsInteger <> 0) then
      Info.DamageScaleByLevel[I] := av[4 + I].AsFloat;
end;
{ @end $639D7C }

{ @routine $639FC8 SF_SetCustomWeaponShotData }
procedure SF_SetCustomWeaponShotData(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
  Text: WideString;
begin
  if High(av) < 2 then raise Exception.Create('Error.Script SetCustomWeaponShotData');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := Cardinal(Info);
  Text := av[2].AsString;
  Info.ShotType := shot_single_target;
  Info.ShotCount := 1;
  if Pos('Normal', Text) <= 0 then
  begin
    if Pos('Splash', Text) > 0 then Info.ShotType := shot_splash
    else if Pos('Exploder', Text) > 0 then Info.ShotType := shot_explode_on_kill
    else if Pos('AreaDamage', Text) > 0 then Info.ShotType := shot_area_damage
    else if Pos('Torpedo', Text) > 0 then Info.ShotType := shot_torpedo
    else if Pos('Missile', Text) > 0 then Info.ShotType := shot_missile
    else if Pos('Rocket', Text) > 0 then Info.ShotType := shot_rocket
    else if Pos('Chain', Text) > 0 then Info.ShotType := shot_chain;
  end;
  if Info.ShotType in [shot_chain, shot_missile, shot_rocket] then Info.ShotCount := ExtractDigitsToIntW(Text);
  if High(av) > 2 then Info.ShotSpeedPercent := av[3].AsInteger;
  if High(av) > 3 then Info.AverageRange := av[4].AsInteger;
  if High(av) > 4 then Info.SecondaryDamageRadius := av[5].AsInteger;
  if High(av) > 5 then Info.MiningFactor := av[6].AsFloat;
  if High(av) > 6 then Info.AttackCount := av[7].AsInteger;

end;
{ @end $639FC8 }

{ @routine $63A264 SF_SetCustomMissileWeaponStats }
procedure SF_SetCustomMissileWeaponStats(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 5 then raise Exception.Create('Error.Script SetCustomMissileWeaponStats');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := Cardinal(Info);
  Info.MissileRange := av[2].AsInteger;
  Info.MissileMaxSpeed := av[3].AsInteger;
  Info.MissileMinSpeed := av[4].AsInteger;
  Info.MissileChanceToBeHit := av[5].AsInteger;

end;
{ @end $63A264 }

{ @routine $63A314 SF_SetCustomWeaponSE }
procedure SF_SetCustomWeaponSE(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 5 then raise Exception.Create('Error.Script SetCustomWeaponSE');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := Cardinal(Info);
  Info.PrimarySE := av[2].AsString;
  Info.SecondarySE := av[3].AsString;
  Info.AreaSE := av[4].AsString;
  Info.DefaultPalette := av[5].AsInteger;

end;
{ @end $63A314 }

{ @routine $63A410 SF_StarCustomFaction }
procedure SF_StarCustomFaction(av: array of TVarEC; code: TCodeEC);
var
  Obj: TStar;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script StarCustomFaction');
  Obj := TStar(av[1].AsDword);
  av[0].AsString := Obj.Status.CustomFaction;
  if High(av) > 1 then
  begin
    Obj.Status.CustomFaction := av[2].AsString;
    if av[2].AsString = '' then Obj.ResetControlFaction;
  end;
end;
{ @end $63A410 }

{ @routine $63A4FC SF_ShipCustomFaction }
procedure SF_ShipCustomFaction(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ShipCustomFaction');
  Ship := TShip(av[1].AsDword);
  if GetPlayer = Ship then
  begin
    if High(av) > 1 then raise Exception.Create('Error.Script ShipCustomFaction Player');
    av[0].AsString := '';
    Exit;
  end;
  if Ship.ScriptShip = nil then
  begin
    if High(av) > 1 then raise Exception.Create('Error.Script ShipCustomFaction non-script ship');
    av[0].AsString := '';
    Exit;
  end;
    av[0].AsString := TScriptShip(Ship.ScriptShip).StateText;
    if High(av) > 1 then
    begin
      TScriptShip(Ship.ScriptShip).StateText := av[2].AsString;
      Ship.RefreshCurrentStanding;
    end;
end;
{ @end $63A4FC }

{ @routine $63A6A0 SF_EqCustomFaction }
procedure SF_EqCustomFaction(av: array of TVarEC; code: TCodeEC);
var
  Obj: TEquipment;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script EqCustomFaction');
  Obj := TEquipment(av[1].AsDword);
  av[0].AsString := Obj.CustomFaction;
  if High(av) > 1 then
  begin
    Obj.CustomFaction := av[2].AsString;
  end;
end;
{ @end $63A6A0 }

{ @routine $63A768 SF_PlanetCustomFaction }
procedure SF_PlanetCustomFaction(av: array of TVarEC; code: TCodeEC);
var
  Obj: TPlanet;
begin
  if High(av) < 1 then raise Exception.Create('Error.Script PlanetCustomFaction');
  Obj := TPlanet(av[1].AsDword);
  av[0].AsString := Obj.CustomFaction;
  if High(av) > 1 then
  begin
    Obj.CustomFaction := av[2].AsString;
  end;
end;
{ @end $63A768 }

{ @routine $63A838 SF_ImportedFunction }
procedure SF_ImportedFunction(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then raise Exception.Create('Error.Script ImportedFunction');
  av[0].ConvertToKind(value_library_function);
  av[0].AsString := av[1].AsString + ',' + av[2].AsString;
  if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
  ScriptLibraryCache.InitFunction(av[0]);
end;
{ @end $63A838 }

{ @routine $63A948 SF_ImportAll }
procedure SF_ImportAll(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then raise Exception.Create('Error.Script ImportAll');
  if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
  ScriptLibraryCache.GetLib(av[1].AsString).InitAllFunctions(code.LocalVar);
  code.LinkAll(code.LocalVar, False);
end;
{ @end $63A948 }

{ @routine $63AA20 SF_GalaxyPtr }
procedure SF_GalaxyPtr(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then av[0].AsDword := Cardinal(Galaxy)
  else if av[1].AsString = 'StarCnt' then av[0].AsDword := Cardinal(@GalaxyStarCount)
  else raise Exception.Create('Error.Script GalaxyPtr, unknown value ' + av[1].AsString);
end;
{ @end $63AA20 }

{ @routine $63AB6C InitializeScriptBuiltinsAndConstants }
procedure InitializeScriptBuiltinsAndConstants(Scope: TVarArrayEC);
var
  WeaponIndex: Integer;
  ActionIndex: TScriptEventKind;
  BonusIndex: TEquipmentBonusKind;
begin
  RegisterExpressionBuiltins(Scope);
  Scope.Add('GRun', value_host_function).AsExternFun := @SF_GRun;
  Scope.Add('GCntRun', value_host_function).AsExternFun := @SF_GCntRun;
  Scope.Add('GLastTurnRun', value_host_function).AsExternFun := @SF_GLastTurnRun;
  Scope.Add('GAllCntRun', value_host_function).AsExternFun := @SF_GAllCntRun;
  Scope.Add('IsScriptActive', value_host_function).AsExternFun := @SF_IsScriptActive;
  Scope.Add('GetValueFromScript', value_host_function).AsExternFun := @SF_GetValueFromScript;
  Scope.Add('RunFunctionFromScript', value_host_function).AsExternFun := @SF_RunFunctionFromScript;
  Scope.Add('GetVariableName', value_host_function).AsExternFun := @SF_GetVariableName;
  Scope.Add('GetVariableType', value_host_function).AsExternFun := @SF_GetVariableType;
  Scope.Add('StatusPlayer', value_host_function).AsExternFun := @SF_StatusPlayer;
  Scope.Add('AddPlanetNews', value_host_function).AsExternFun := @SF_AddPlanetNews;
  Scope.Add('AddJournalRecord', value_host_function).AsExternFun := @SF_AddJournalRecord;
  Scope.Add('AutoBattle', value_host_function).AsExternFun := @SF_AutoBattle;
  Scope.Add('GetOwner', value_host_function).AsExternFun := @SF_GetOwner;
  Scope.Add('GiveReward', value_host_function).AsExternFun := @SF_GiveReward;
  Scope.Add('GiveRewardByNom', value_host_function).AsExternFun := @SF_GiveRewardByNom;
  Scope.Add('CountReward', value_host_function).AsExternFun := @SF_CountReward;
  Scope.Add('CountRewardByNom', value_host_function).AsExternFun := @SF_CountRewardByNom;
  Scope.Add('DeleteRewardByNom', value_host_function).AsExternFun := @SF_DeleteRewardByNom;
  Scope.Add('Rnd', value_host_function).AsExternFun := @SF_Rnd;
  Scope.Add('GameDateTxtByTurn', value_host_function).AsExternFun := @SF_GameDateTxtByTurn;
  Scope.Add('Id', value_host_function).AsExternFun := @SF_Id;
  Scope.Add('SetName', value_host_function).AsExternFun := @SF_SetName;
  Scope.Add('UseTranclucator', value_host_function).AsExternFun := @SF_UseTranclucator;
  Scope.Add('HullDamage', value_host_function).AsExternFun := @SF_HullDamage;
  Scope.Add('Hitpoints', value_host_function).AsExternFun := @SF_Hitpoints;
  Scope.Add('Hit', value_host_function).AsExternFun := @SF_Hit;
  Scope.Add('ChangeGlobalRelationsShips', value_host_function).AsExternFun := @SF_ChangeGlobalRelationsShips;
  Scope.Add('ChangeGlobalRelationsPlanets', value_host_function).AsExternFun := @SF_ChangeGlobalRelationsPlanets;
  Scope.Add('GlobalRelationsShips', value_host_function).AsExternFun := @SF_GlobalRelationsShips;
  Scope.Add('GlobalRelationsPlanets', value_host_function).AsExternFun := @SF_GlobalRelationsPlanets;
  Scope.Add('SetRelationGroup', value_host_function).AsExternFun := @SF_SetRelationGroup;
  Scope.Add('SetRelationPlanet', value_host_function).AsExternFun := @SF_SetRelationPlanet;
  Scope.Add('GetRelationPlanet', value_host_function).AsExternFun := @SF_GetRelationPlanet;
  Scope.Add('CurTurn', value_host_function).AsExternFun := @SF_CurTurn;
  Scope.Add('ShipType', value_host_function).AsExternFun := @SF_ShipType;
  Scope.Add('ConName', value_host_function).AsExternFun := @SF_ConName;
  Scope.Add('StarName', value_host_function).AsExternFun := @SF_StarName;
  Scope.Add('StarMapLabel', value_host_function).AsExternFun := @SF_StarMapLabel;
  Scope.Add('PlanetName', value_host_function).AsExternFun := @SF_PlanetName;
  Scope.Add('IdToPlanet', value_host_function).AsExternFun := @SF_IdToPlanet;
  Scope.Add('IdToShip', value_host_function).AsExternFun := @SF_IdToShip;
  Scope.Add('IdToItem', value_host_function).AsExternFun := @SF_IdToItem;
  Scope.Add('PlanetSetGoods', value_host_function).AsExternFun := @SF_PlanetSetGoods;
  Scope.Add('ShipName', value_host_function).AsExternFun := @SF_ShipName;
  Scope.Add('ShipRank', value_host_function).AsExternFun := @SF_ShipRank;
  Scope.Add('ShipRankPoints', value_host_function).AsExternFun := @SF_ShipRankPoints;
  Scope.Add('ShipNextRankPoints', value_host_function).AsExternFun := @SF_ShipNextRankPoints;
  Scope.Add('ShipRaiseRank', value_host_function).AsExternFun := @SF_ShipRaiseRank;
  Scope.Add('ShipStar', value_host_function).AsExternFun := @SF_ShipStar;
  Scope.Add('StarToCon', value_host_function).AsExternFun := @SF_StarToCon;
  Scope.Add('ConNear', value_host_function).AsExternFun := @SF_ConNear;
  Scope.Add('ConStars', value_host_function).AsExternFun := @SF_ConStars;
  Scope.Add('ConStar', value_host_function).AsExternFun := @SF_ConStar;
  Scope.Add('GalaxyStars', value_host_function).AsExternFun := @SF_GalaxyStars;
  Scope.Add('GalaxyStar', value_host_function).AsExternFun := @SF_GalaxyStar;
  Scope.Add('StarAngleBetween', value_host_function).AsExternFun := @SF_StarAngleBetween;
  Scope.Add('FindPlanet', value_host_function).AsExternFun := @SF_FindPlanet;
  Scope.Add('IsPlayer', value_host_function).AsExternFun := @SF_IsPlayer;
  Scope.Add('GroupCount', value_host_function).AsExternFun := @SF_GroupCount;
  Scope.Add('GroupIn', value_host_function).AsExternFun := @SF_GroupIn;
  Scope.Add('CountIn', value_host_function).AsExternFun := @SF_CountIn;
  Scope.Add('ChangeState', value_host_function).AsExternFun := @SF_ChangeState;
  Scope.Add('NearestGroup', value_host_function).AsExternFun := @SF_NearestGroup;
  Scope.Add('StarAngle', value_host_function).AsExternFun := @SF_StarAngle;
  Scope.Add('NewsAdd', value_host_function).AsExternFun := @SF_NewsAdd;
  Scope.Add('MsgAdd', value_host_function).AsExternFun := @SF_MsgAdd;
  Scope.Add('Ether', value_host_function).AsExternFun := @SF_Ether;
  Scope.Add('CustomEther', value_host_function).AsExternFun := @SF_CustomEther;
  Scope.Add('EtherDelete', value_host_function).AsExternFun := @SF_EtherDelete;
  Scope.Add('EtherIdAdd', value_host_function).AsExternFun := @SF_EtherIdAdd;
  Scope.Add('EtherIdDelete', value_host_function).AsExternFun := @SF_EtherIdDelete;
  Scope.Add('EtherState', value_host_function).AsExternFun := @SF_EtherState;
  Scope.Add('ConChangeRelationToRanger', value_host_function).AsExternFun := @SF_ConChangeRelationToRanger;
  Scope.Add('GetData', value_host_function).AsExternFun := @SF_GetData;
  Scope.Add('SetData', value_host_function).AsExternFun := @SF_SetData;
  Scope.Add('ShipData', value_host_function).AsExternFun := @SF_ShipData;
  Scope.Add('Format', value_host_function).AsExternFun := @SF_Format;
  Scope.Add('DeleteTags', value_host_function).AsExternFun := @SF_DeleteTags;
  Scope.Add('Dialog', value_host_function).AsExternFun := @SF_Dialog;
  Scope.Add('DText', value_host_function).AsExternFun := @SF_DText;
  Scope.Add('DAddText', value_host_function).AsExternFun := @SF_DAddText;
  Scope.Add('DAdd', value_host_function).AsExternFun := @SF_DAdd;
  Scope.Add('DChange', value_host_function).AsExternFun := @SF_DChange;
  Scope.Add('DAnswer', value_host_function).AsExternFun := @SF_DAnswer;
  Scope.Add('Player', value_host_function).AsExternFun := @SF_Player;
  Scope.Add('ItemExist', value_host_function).AsExternFun := @SF_ItemExist;
  Scope.Add('ItemIn', value_host_function).AsExternFun := @SF_ItemIn;
  Scope.Add('ItemCost', value_host_function).AsExternFun := @SF_ItemCost;
  Scope.Add('ItemCount', value_host_function).AsExternFun := @SF_ItemCount;
  Scope.Add('ShipPicksItem', value_host_function).AsExternFun := @SF_ShipPicksItem;
  Scope.Add('DropItem', value_host_function).AsExternFun := @SF_DropItem;
  Scope.Add('DropScriptItem', value_host_function).AsExternFun := @SF_DropScriptItem;
  Scope.Add('DeleteEquipment', value_host_function).AsExternFun := @SF_DeleteEquipment;
  Scope.Add('DecayGoods', value_host_function).AsExternFun := @SF_DecayGoods;
  Scope.Add('UpsurgeGoods', value_host_function).AsExternFun := @SF_UpsurgeGoods;
  Scope.Add('GoodsAdd', value_host_function).AsExternFun := @SF_GoodsAdd;
  Scope.Add('GoodsCount', value_host_function).AsExternFun := @SF_GoodsCount;
  Scope.Add('GoodsCost', value_host_function).AsExternFun := @SF_GoodsCost;
  Scope.Add('GoodsRuinsForBuy', value_host_function).AsExternFun := @SF_GoodsRuinsForBuy;
  Scope.Add('ShipGoods', value_host_function).AsExternFun := @SF_ShipGoods;
  Scope.Add('ShipGoodsIllegalOnPlanet', value_host_function).AsExternFun := @SF_ShipGoodsIllegalOnPlanet;
  Scope.Add('GoodsDrop', value_host_function).AsExternFun := @SF_GoodsDrop;
  Scope.Add('UselessItemCreate', value_host_function).AsExternFun := @SF_UselessItemCreate;
  Scope.Add('GoodsSellPrice', value_host_function).AsExternFun := @SF_GoodsSellPrice;
  Scope.Add('GoodsBuyPrice', value_host_function).AsExternFun := @SF_GoodsBuyPrice;
  Scope.Add('CountTurn', value_host_function).AsExternFun := @SF_CountTurn;
  Scope.Add('ShipSetBad', value_host_function).AsExternFun := @SF_ShipSetBad;
  Scope.Add('GroupSetBad', value_host_function).AsExternFun := @SF_GroupSetBad;
  Scope.Add('ShipSetPartner', value_host_function).AsExternFun := @SF_ShipSetPartner;
  Scope.Add('ShipJoin', value_host_function).AsExternFun := @SF_ShipJoin;
  Scope.Add('ShipOut', value_host_function).AsExternFun := @SF_ShipOut;
  Scope.Add('AllShipOut', value_host_function).AsExternFun := @SF_AllShipOut;
  Scope.Add('ShipInScript', value_host_function).AsExternFun := @SF_ShipInScript;
  Scope.Add('ShipInGameEvent', value_host_function).AsExternFun := @SF_ShipInGameEvent;
  Scope.Add('ShipInCurScript', value_host_function).AsExternFun := @SF_ShipInCurScript;
  Scope.Add('ShipInNormalSpace', value_host_function).AsExternFun := @SF_ShipInNormalSpace;
  Scope.Add('ShipInHole', value_host_function).AsExternFun := @SF_ShipInHole;
  Scope.Add('ShipIsTakeoff', value_host_function).AsExternFun := @SF_ShipIsTakeoff;
  Scope.Add('ShipCntWeapon', value_host_function).AsExternFun := @SF_ShipCntWeapon;
  Scope.Add('ShipWeapon', value_host_function).AsExternFun := @SF_ShipWeapon;
  Scope.Add('ShipEqInSlot', value_host_function).AsExternFun := @SF_ShipEqInSlot;
  Scope.Add('ArtefactTypeInUse', value_host_function).AsExternFun := @SF_ArtefactTypeInUse;
  Scope.Add('ArtefactTypeBoosted', value_host_function).AsExternFun := @SF_ArtefactTypeBoosted;
  Scope.Add('ShipSpeed', value_host_function).AsExternFun := @SF_ShipSpeed;
  Scope.Add('EnginePower', value_host_function).AsExternFun := @SF_EnginePower;
  Scope.Add('ShipJump', value_host_function).AsExternFun := @SF_ShipJump;
  Scope.Add('ShipArmor', value_host_function).AsExternFun := @SF_ShipArmor;
  Scope.Add('ShipProtectability', value_host_function).AsExternFun := @SF_ShipProtectability;
  Scope.Add('ShipDroidRepair', value_host_function).AsExternFun := @SF_ShipDroidRepair;
  Scope.Add('ShipRadarRange', value_host_function).AsExternFun := @SF_ShipRadarRange;
  Scope.Add('ShipScanerPower', value_host_function).AsExternFun := @SF_ShipScanerPower;
  Scope.Add('ShipHookPower', value_host_function).AsExternFun := @SF_ShipHookPower;
  Scope.Add('ShipHookRange', value_host_function).AsExternFun := @SF_ShipHookRange;
  Scope.Add('ShipAverageDamage', value_host_function).AsExternFun := @SF_ShipAverageDamage;
  Scope.Add('ShipHealthFactor', value_host_function).AsExternFun := @SF_ShipHealthFactor;
  Scope.Add('ShipHealthFactorStatus', value_host_function).AsExternFun := @SF_ShipHealthFactorStatus;
  Scope.Add('PlayerImmunity', value_host_function).AsExternFun := @SF_PlayerImmunity;
  Scope.Add('ShipStatusEffect', value_host_function).AsExternFun := @SF_ShipStatusEffect;
  Scope.Add('ShipGroup', value_host_function).AsExternFun := @SF_ShipGroup;
  Scope.Add('ShipCanJump', value_host_function).AsExternFun := @SF_ShipCanJump;
  Scope.Add('ShipInStar', value_host_function).AsExternFun := @SF_ShipInStar;
  Scope.Add('ShipInPlanet', value_host_function).AsExternFun := @SF_ShipInPlanet;
  Scope.Add('ShipStatistic', value_host_function).AsExternFun := @SF_ShipStatistic;
  Scope.Add('PlayerDominatorStatistic', value_host_function).AsExternFun := @SF_PlayerDominatorStatistic;
  Scope.Add('ShipMoney', value_host_function).AsExternFun := @SF_ShipMoney;
  Scope.Add('ShipFuel', value_host_function).AsExternFun := @SF_ShipFuel;
  Scope.Add('ShipFuelLow', value_host_function).AsExternFun := @SF_ShipFuelLow;
  Scope.Add('ShipStrengthInBestRanger', value_host_function).AsExternFun := @SF_ShipStrengthInBestRanger;
  Scope.Add('ShipStrengthInAverageRanger', value_host_function).AsExternFun := @SF_ShipStrengthInAverageRanger;
  Scope.Add('ChanceToWin', value_host_function).AsExternFun := @SF_ChanceToWin;
  Scope.Add('ShipFind', value_host_function).AsExternFun := @SF_ShipFind;
  Scope.Add('RangerStatus', value_host_function).AsExternFun := @SF_RangerStatus;
  Scope.Add('RangerPlaceInRating', value_host_function).AsExternFun := @SF_RangerPlaceInRating;
  Scope.Add('RangerExcludedFromRating', value_host_function).AsExternFun := @SF_RangerExcludedFromRating;
  Scope.Add('GalaxyMoney', value_host_function).AsExternFun := @SF_GalaxyMoney;
  Scope.Add('ShipDestroy', value_host_function).AsExternFun := @SF_ShipDestroy;
  Scope.Add('ShipDestroyType', value_host_function).AsExternFun := @SF_ShipDestroyType;
  Scope.Add('ItemDestroy', value_host_function).AsExternFun := @SF_ItemDestroy;
  Scope.Add('RangersCapital', value_host_function).AsExternFun := @SF_RangersCapital;
  Scope.Add('GroupToShip', value_host_function).AsExternFun := @SF_GroupToShip;
  Scope.Add('OrderLanding', value_host_function).AsExternFun := @SF_OrderLanding;
  Scope.Add('OrderJump', value_host_function).AsExternFun := @SF_OrderJump;
  Scope.Add('GroupIs', value_host_function).AsExternFun := @SF_GroupIs;
  Scope.Add('StateIs', value_host_function).AsExternFun := @SF_StateIs;
  Scope.Add('Dist', value_host_function).AsExternFun := @SF_Dist;
  Scope.Add('Angle', value_host_function).AsExternFun := @SF_Angle;
  Scope.Add('Dist2Star', value_host_function).AsExternFun := @SF_Dist2Star;
  Scope.Add('BuyPirate', value_host_function).AsExternFun := @SF_BuyPirate;
  Scope.Add('BuyTransport', value_host_function).AsExternFun := @SF_BuyTransport;
  Scope.Add('Name', value_host_function).AsExternFun := @SF_Name;
  Scope.Add('ShortName', value_host_function).AsExternFun := @SF_ShortName;
  Scope.Add('FirstGiveMoney', value_host_function).AsExternFun := @SF_FirstGiveMoney;
  Scope.Add('HaveProgramm', value_host_function).AsExternFun := @SF_HaveProgramm;
  Scope.Add('GetProgramm', value_host_function).AsExternFun := @SF_GetProgramm;
  Scope.Add('SetProgramm', value_host_function).AsExternFun := @SF_SetProgramm;
  Scope.Add('DomikProgramm', value_host_function).AsExternFun := @SF_DomikProgramm;
  Scope.Add('DomikProgrammDate', value_host_function).AsExternFun := @SF_DomikProgrammDate;
  Scope.Add('HoleMamaCreate', value_host_function).AsExternFun := @SF_HoleMamaCreate;
  Scope.Add('HoleCreate', value_host_function).AsExternFun := @SF_HoleCreate;
  Scope.Add('TerronWeaponLock', value_host_function).AsExternFun := @SF_TerronWeaponLock;
  Scope.Add('TerronGrowLock', value_host_function).AsExternFun := @SF_TerronGrowLock;
  Scope.Add('TerronLandingLock', value_host_function).AsExternFun := @SF_TerronLandingLock;
  Scope.Add('TerronToStar', value_host_function).AsExternFun := @SF_TerronToStar;
  Scope.Add('KellerLeave', value_host_function).AsExternFun := @SF_KellerLeave;
  Scope.Add('KellerNewResearch', value_host_function).AsExternFun := @SF_KellerNewResearch;
  Scope.Add('KellerKill', value_host_function).AsExternFun := @SF_KellerKill;
  Scope.Add('BlazerLanding', value_host_function).AsExternFun := @SF_BlazerLanding;
  Scope.Add('BlazerSelfDestruction', value_host_function).AsExternFun := @SF_BlazerSelfDestruction;
  Scope.Add('GalaxyShipId', value_host_function).AsExternFun := @SF_GalaxyShipId;
  Scope.Add('NearCivilPlanet', value_host_function).AsExternFun := @SF_NearCivilPlanet;
  Scope.Add('SkipGreeting', value_host_function).AsExternFun := @SF_SkipGreeting;
  Scope.Add('Sound', value_host_function).AsExternFun := @SF_Sound;
  Scope.Add('Tips', value_host_function).AsExternFun := @SF_Tips;
  Scope.Add('TipsState', value_host_function).AsExternFun := @SF_TipsState;
  Scope.Add('CT', value_host_function).AsExternFun := @SF_CT;
  Scope.Add('BlockExist', value_host_function).AsExternFun := @SF_BlockExist;
  Scope.Add('GetMainData', value_host_function).AsExternFun := @SF_GetMainData;
  Scope.Add('GetGameOptions', value_host_function).AsExternFun := @SF_GetGameOptions;
  Scope.Add('ResourceExist', value_host_function).AsExternFun := @SF_ResourceExist;
  Scope.Add('SFT', value_host_function).AsExternFun := @SF_SFT;
  Scope.Add('CurrentMods', value_host_function).AsExternFun := @SF_CurrentMods;
  Scope.Add('RobotSupport', value_host_function).AsExternFun := @SF_RobotSupport;
  Scope.Add('UselessItem', value_int32).AsInteger := Ord(item_misc);
  Scope.Add('ForLiberationSystem', value_int32).AsInteger := Ord(award_liberation);
  Scope.Add('ForAccomplishment', value_int32).AsInteger := Ord(award_accomplishment);
  Scope.Add('ForSecretMission', value_int32).AsInteger := Ord(award_secret_mission);
  Scope.Add('ForCowardice', value_int32).AsInteger := Ord(award_cowardice);
  Scope.Add('ForPerfidy', value_int32).AsInteger := Ord(award_perfidy);
  Scope.Add('ForPlanetBattle', value_int32).AsInteger := Ord(award_planet_battle);
  Scope.Add('Maloc', value_int32).AsInteger := Ord(owner_maloc);
  Scope.Add('Peleng', value_int32).AsInteger := Ord(owner_peleng);
  Scope.Add('People', value_int32).AsInteger := Ord(owner_human);
  Scope.Add('Fei', value_int32).AsInteger := Ord(owner_feyan);
  Scope.Add('Gaal', value_int32).AsInteger := Ord(owner_gaal);
  Scope.Add('Kling', value_int32).AsInteger := Ord(owner_dominator);
  Scope.Add('None', value_int32).AsInteger := Ord(owner_uninhabited);
  Scope.Add('PirateClan', value_int32).AsInteger := Ord(owner_pirate);
  Scope.Add('t_Food', value_int32).AsInteger := Ord(item_food);
  Scope.Add('t_Medicine', value_int32).AsInteger := Ord(item_medicine);
  Scope.Add('t_Technics', value_int32).AsInteger := Ord(item_technical_goods);
  Scope.Add('t_Luxury', value_int32).AsInteger := Ord(item_luxury);
  Scope.Add('t_Minerals', value_int32).AsInteger := Ord(item_minerals);
  Scope.Add('t_Alcohol', value_int32).AsInteger := Ord(item_alcohol);
  Scope.Add('t_Arms', value_int32).AsInteger := Ord(item_arms);
  Scope.Add('t_Narcotics', value_int32).AsInteger := Ord(item_narcotics);
  Scope.Add('t_Artefact', value_int32).AsInteger := Ord(item_custom_artefact);
  Scope.Add('t_Artefact2', value_int32).AsInteger := Ord(item_custom_artefact_no_wear);
  Scope.Add('t_ArtefactHull', value_int32).AsInteger := Ord(artefact_hull);
  Scope.Add('t_ArtefactFuel', value_int32).AsInteger := Ord(artefact_fuel);
  Scope.Add('t_ArtefactSpeed', value_int32).AsInteger := Ord(artefact_speed);
  Scope.Add('t_ArtefactPower', value_int32).AsInteger := Ord(artefact_power);
  Scope.Add('t_ArtefactRadar', value_int32).AsInteger := Ord(artefact_radar);
  Scope.Add('t_ArtefactScaner', value_int32).AsInteger := Ord(artefact_scanner);
  Scope.Add('t_ArtefactDroid', value_int32).AsInteger := Ord(artefact_repair_robot);
  Scope.Add('t_ArtefactNano', value_int32).AsInteger := Ord(artefact_nano_repair);
  Scope.Add('t_ArtefactHook', value_int32).AsInteger := Ord(artefact_cargo_hook);
  Scope.Add('t_ArtefactDef', value_int32).AsInteger := Ord(artefact_defense);
  Scope.Add('t_ArtefactAnalyzer', value_int32).AsInteger := Ord(artefact_analyzer);
  Scope.Add('t_ArtefactMiniExpl', value_int32).AsInteger := Ord(artefact_extra_loot);
  Scope.Add('t_ArtefactAntigrav', value_int32).AsInteger := Ord(artefact_antigravity);
  Scope.Add('t_ArtefactTransmitter', value_int32).AsInteger := Ord(artefact_transmitter);
  Scope.Add('t_ArtefactBomb', value_int32).AsInteger := Ord(artefact_bomb);
  Scope.Add('t_ArtefactTranclucator', value_int32).AsInteger := Ord(artefact_tranclucator);
  Scope.Add('t_Hull', value_int32).AsInteger := Ord(item_hull);
  Scope.Add('t_FuelTanks', value_int32).AsInteger := Ord(item_fuel_tanks);
  Scope.Add('t_Engine', value_int32).AsInteger := Ord(item_engine);
  Scope.Add('t_Radar', value_int32).AsInteger := Ord(item_radar);
  Scope.Add('t_Scaner', value_int32).AsInteger := Ord(item_scanner);
  Scope.Add('t_RepairRobot', value_int32).AsInteger := Ord(item_repair_robot);
  Scope.Add('t_CargoHook', value_int32).AsInteger := Ord(item_cargo_hook);
  Scope.Add('t_DefGenerator', value_int32).AsInteger := Ord(item_defense_generator);
  for WeaponIndex := 1 to CountItemTypesInMask([item_industrial_laser..item_lirecron]) do
    Scope.Add('t_Weapon' + IntToStr(WeaponIndex), value_int32).AsInteger := Ord(GetItemTypeFromMask([item_industrial_laser..item_lirecron], WeaponIndex));
  Scope.Add('t_CustomWeapon', value_int32).AsInteger := Ord(item_custom_weapon);
  Scope.Add('t_Protoplasm', value_int32).AsInteger := Ord(item_nodes);
  Scope.Add('t_UselessItem', value_int32).AsInteger := Ord(item_misc);
  Scope.Add('ReWar', value_int32).AsInteger := Ord(relation_level_hostile);
  Scope.Add('ReBad', value_int32).AsInteger := Ord(relation_level_bad);
  Scope.Add('ReNormal', value_int32).AsInteger := Ord(relation_level_normal);
  Scope.Add('ReGood', value_int32).AsInteger := Ord(relation_level_good);
  Scope.Add('ReBest', value_int32).AsInteger := Ord(relation_level_excellent);
  Scope.Add('Trader', value_int32).AsInteger := Ord(career_trader);
  Scope.Add('Pirate', value_int32).AsInteger := Ord(career_pirate);
  Scope.Add('Warrior', value_int32).AsInteger := Ord(career_warrior);
  Scope.Add('t_Kling', value_int32).AsInteger := Ord(ship_dominator);
  Scope.Add('t_Ranger', value_int32).AsInteger := Ord(ship_ranger);
  Scope.Add('t_Transport', value_int32).AsInteger := Ord(ship_transport);
  Scope.Add('t_Pirate', value_int32).AsInteger := Ord(ship_pirate);
  Scope.Add('t_Warrior', value_int32).AsInteger := Ord(ship_warrior);
  Scope.Add('t_Tranclucator', value_int32).AsInteger := Ord(ship_tranclucator);
  Scope.Add('t_RC', value_int32).AsInteger := Ord(station_ranger_center);
  Scope.Add('t_PB', value_int32).AsInteger := Ord(station_pirate_base);
  Scope.Add('t_WB', value_int32).AsInteger := Ord(station_military_base);
  Scope.Add('t_SB', value_int32).AsInteger := Ord(station_science_base);
  Scope.Add('t_BK', value_int32).AsInteger := Ord(station_business_center);
  Scope.Add('t_MC', value_int32).AsInteger := Ord(station_medical_base);
  Scope.Add('t_CB', value_int32).AsInteger := Ord(station_dominion);
  Scope.Add('t_UB', value_int32).AsInteger := Ord(station_custom);
  Scope.Add('progKellerCall', value_int32).AsInteger := Ord(program_keller_call);
  Scope.Add('progLogicalNegation', value_int32).AsInteger := Ord(program_logical_negation);
  Scope.Add('progDematerial', value_int32).AsInteger := Ord(program_dematerial);
  Scope.Add('progEnergotron', value_int32).AsInteger := Ord(program_energotron);
  Scope.Add('progSabCrack', value_int32).AsInteger := Ord(program_sab_crack);
  Scope.Add('progIntercom', value_int32).AsInteger := Ord(program_intercom);
  Scope.Add('StarShips', value_host_function).AsExternFun := @SF_StarShips;
  Scope.Add('StarPlanets', value_host_function).AsExternFun := @SF_StarPlanets;
  Scope.Add('StarMissiles', value_host_function).AsExternFun := @SF_StarMissiles;
  Scope.Add('StarAsteroids', value_host_function).AsExternFun := @SF_StarAsteroids;
  Scope.Add('GroupShip', value_host_function).AsExternFun := @SF_GroupShip;
  Scope.Add('ShipItems', value_host_function).AsExternFun := @SF_ShipItems;
  Scope.Add('ShipArts', value_host_function).AsExternFun := @SF_ShipArts;
  Scope.Add('PlayerTranclucators', value_host_function).AsExternFun := @SF_PlayerTranclucators;
  Scope.Add('ArtTranclucatorToShip', value_host_function).AsExternFun := @SF_ArtTranclucatorToShip;
  Scope.Add('TranclucatorData', value_host_function).AsExternFun := @SF_TranclucatorData;
  Scope.Add('LinkItemToScript', value_host_function).AsExternFun := @SF_LinkItemToScript;
  Scope.Add('ReleaseItemFromScript', value_host_function).AsExternFun := @SF_ReleaseItemFromScript;
  Scope.Add('ScriptItemData', value_host_function).AsExternFun := @SF_ScriptItemData;
  Scope.Add('ScriptItemTextData', value_host_function).AsExternFun := @SF_ScriptItemTextData;
  Scope.Add('ScriptItemToItem', value_host_function).AsExternFun := @SF_ScriptItemToItem;
  Scope.Add('GetShipPirateRank', value_host_function).AsExternFun := @SF_GetShipPirateRank;
  Scope.Add('ShipPirateRankPoints', value_host_function).AsExternFun := @SF_ShipPirateRankPoints;
  Scope.Add('ShipNextPirateRankPoints', value_host_function).AsExternFun := @SF_ShipNextPirateRankPoints;
  Scope.Add('ShipInPirateClan', value_host_function).AsExternFun := @SF_ShipInPirateClan;
  Scope.Add('ShipOnSidePirateClan', value_host_function).AsExternFun := @SF_ShipOnSidePirateClan;
  Scope.Add('RaisePirateRank', value_host_function).AsExternFun := @SF_RaisePirateRank;
  Scope.Add('ItemType', value_host_function).AsExternFun := @SF_ItemType;
  Scope.Add('CustomWeaponType', value_host_function).AsExternFun := @SF_CustomWeaponType;
  Scope.Add('ItemName', value_host_function).AsExternFun := @SF_ItemName;
  Scope.Add('ItemFullName', value_host_function).AsExternFun := @SF_ItemFullName;
  Scope.Add('ItemSize', value_host_function).AsExternFun := @SF_ItemSize;
  Scope.Add('ItemOwner', value_host_function).AsExternFun := @SF_ItemOwner;
  Scope.Add('ItemSubrace', value_host_function).AsExternFun := @SF_ItemSubrace;
  Scope.Add('ItemIsInUse', value_host_function).AsExternFun := @SF_ItemIsInUse;
  Scope.Add('ItemIsInSet', value_host_function).AsExternFun := @SF_ItemIsInSet;
  Scope.Add('PlayerEqSet', value_host_function).AsExternFun := @SF_PlayerEqSet;
  Scope.Add('ItemIsBroken', value_host_function).AsExternFun := @SF_ItemIsBroken;
  Scope.Add('ShipCanUseEq', value_host_function).AsExternFun := @SF_ShipCanUseEq;
  Scope.Add('ShipCanRepairEq', value_host_function).AsExternFun := @SF_ShipCanRepairEq;
  Scope.Add('ShipTechLevelKnowledge', value_host_function).AsExternFun := @SF_ShipTechLevelKnowledge;
  Scope.Add('WeaponTarget', value_host_function).AsExternFun := @SF_WeaponTarget;
  Scope.Add('GetEquipmentStats', value_host_function).AsExternFun := @SF_GetEquipmentStats;
  Scope.Add('SetEquipmentStats', value_host_function).AsExternFun := @SF_SetEquipmentStats;
  Scope.Add('CreateHull', value_host_function).AsExternFun := @SF_CreateHull;
  Scope.Add('CreateEquipment', value_host_function).AsExternFun := @SF_CreateEquipment;
  Scope.Add('CreateArt', value_host_function).AsExternFun := @SF_CreateArt;
  Scope.Add('CreateCustomWeapon', value_host_function).AsExternFun := @SF_CreateCustomWeapon;
  Scope.Add('CreateCustomArt', value_host_function).AsExternFun := @SF_CreateCustomArt;
  Scope.Add('CustomArtData', value_host_function).AsExternFun := @SF_CustomArtData;
  Scope.Add('CustomArtTextData', value_host_function).AsExternFun := @SF_CustomArtTextData;
  Scope.Add('CreateMM', value_host_function).AsExternFun := @SF_CreateMM;
  Scope.Add('CreateNodes', value_host_function).AsExternFun := @SF_CreateNodes;
  Scope.Add('CreateCustomCountableItem', value_host_function).AsExternFun := @SF_CreateCustomCountableItem;
  Scope.Add('CreateZond', value_host_function).AsExternFun := @SF_CreateZond;
  Scope.Add('ExistingZonds', value_host_function).AsExternFun := @SF_ExistingZonds;
  Scope.Add('FreeItem', value_host_function).AsExternFun := @SF_FreeItem;
  Scope.Add('ShipJoinsClan', value_host_function).AsExternFun := @SF_ShipJoinsClan;
  Scope.Add('AddItemToShip', value_host_function).AsExternFun := @SF_AddItemToShip;
  Scope.Add('GetItemFromShip', value_host_function).AsExternFun := @SF_GetItemFromShip;
  Scope.Add('GetArtFromShip', value_host_function).AsExternFun := @SF_GetArtFromShip;
  Scope.Add('ArrangeItems', value_host_function).AsExternFun := @SF_ArrangeItems;
  Scope.Add('AddItemToPlanet', value_host_function).AsExternFun := @SF_AddItemToPlanet;
  Scope.Add('GetItemFromPlanet', value_host_function).AsExternFun := @SF_GetItemFromPlanet;
  Scope.Add('AddItemToShop', value_host_function).AsExternFun := @SF_AddItemToShop;
  Scope.Add('GetItemFromShop', value_host_function).AsExternFun := @SF_GetItemFromShop;
  Scope.Add('AddItemToStorage', value_host_function).AsExternFun := @SF_AddItemToStorage;
  Scope.Add('GetItemFromStorage', value_host_function).AsExternFun := @SF_GetItemFromStorage;
  Scope.Add('FindItemInStorage', value_host_function).AsExternFun := @SF_FindItemInStorage;
  Scope.Add('PutItemInVault', value_host_function).AsExternFun := @SF_PutItemInVault;
  Scope.Add('GetItemFromVault', value_host_function).AsExternFun := @SF_GetItemFromVault;
  Scope.Add('DropItemInSystem', value_host_function).AsExternFun := @SF_DropItemInSystem;
  Scope.Add('StopMovingItem', value_host_function).AsExternFun := @SF_StopMovingItem;
  Scope.Add('StarItems', value_host_function).AsExternFun := @SF_StarItems;
  Scope.Add('GetItemFromStar', value_host_function).AsExternFun := @SF_GetItemFromStar;
  Scope.Add('PlanetItems', value_host_function).AsExternFun := @SF_PlanetItems;
  Scope.Add('StorageItems', value_host_function).AsExternFun := @SF_StorageItems;
  Scope.Add('StorageItemLocation', value_host_function).AsExternFun := @SF_StorageItemLocation;
  Scope.Add('ShopItems', value_host_function).AsExternFun := @SF_ShopItems;
  Scope.Add('AddDialogOverride', value_host_function).AsExternFun := @SF_AddDialogOverride;
  Scope.Add('AddDialogInject', value_host_function).AsExternFun := @SF_AddDialogInject;
  Scope.Add('InjectAnswer', value_host_function).AsExternFun := @SF_InjectAnswer;
  Scope.Add('AddDialogBlock', value_host_function).AsExternFun := @SF_AddDialogBlock;
  Scope.Add('GotoGov', value_host_function).AsExternFun := @SF_GotoGov;
  Scope.Add('GetShipPlanet', value_host_function).AsExternFun := @SF_GetShipPlanet;
  Scope.Add('GetShipHomePlanet', value_host_function).AsExternFun := @SF_GetShipHomePlanet;
  Scope.Add('GetShipRuins', value_host_function).AsExternFun := @SF_GetShipRuins;
  Scope.Add('GetTalkShip', value_host_function).AsExternFun := @SF_GetTalkShip;
  Scope.Add('GetTalkType', value_host_function).AsExternFun := @SF_GetTalkType;
  Scope.Add('TalkByAI', value_host_function).AsExternFun := @SF_TalkByAI;
  Scope.Add('ScriptRun', value_host_function).AsExternFun := @SF_ScriptRun;
  Scope.Add('CreateABShip', value_host_function).AsExternFun := @SF_CreateABShip;
  Scope.Add('ConvertToABShip', value_host_function).AsExternFun := @SF_ConvertToABShip;
  Scope.Add('ABShipModifiers', value_host_function).AsExternFun := @SF_ABShipModifiers;
  Scope.Add('StartAB', value_host_function).AsExternFun := @SF_StartAB;
  Scope.Add('StartTextQuest', value_host_function).AsExternFun := @SF_StartTextQuest;
  Scope.Add('StartRobots', value_host_function).AsExternFun := @SF_StartRobots;
  Scope.Add('MarkRobotsMapAsUsed', value_host_function).AsExternFun := @SF_MarkRobotsMapAsUsed;
  Scope.Add('ShipOwner', value_host_function).AsExternFun := @SF_ShipOwner;
  Scope.Add('ShipPilotRace', value_host_function).AsExternFun := @SF_ShipPilotRace;
  Scope.Add('ShipSkill', value_host_function).AsExternFun := @SF_ShipSkill;
  Scope.Add('ShipFace', value_host_function).AsExternFun := @SF_ShipFace;
  Scope.Add('ShipFreeExp', value_host_function).AsExternFun := @SF_ShipFreeExp;
  Scope.Add('GetShipExpByType', value_host_function).AsExternFun := @SF_GetShipExpByType;
  Scope.Add('CoordX', value_host_function).AsExternFun := @SF_CoordX;
  Scope.Add('CoordY', value_host_function).AsExternFun := @SF_CoordY;
  Scope.Add('ShipSetCoords', value_host_function).AsExternFun := @SF_ShipSetCoords;
  Scope.Add('ShipAngle', value_host_function).AsExternFun := @SF_ShipAngle;
  Scope.Add('ObjectType', value_host_function).AsExternFun := @SF_ObjectType;
  Scope.Add('ShipInHyperSpace', value_host_function).AsExternFun := @SF_ShipInHyperSpace;
  Scope.Add('ShipStatus', value_host_function).AsExternFun := @SF_ShipStatus;
  Scope.Add('BuyRanger', value_host_function).AsExternFun := @SF_BuyRanger;
  Scope.Add('BuyWarrior', value_host_function).AsExternFun := @SF_BuyWarrior;
  Scope.Add('BuyBigWarrior', value_host_function).AsExternFun := @SF_BuyBigWarrior;
  Scope.Add('BuyDomik', value_host_function).AsExternFun := @SF_BuyDomik;
  Scope.Add('BuyDomikExtremal', value_host_function).AsExternFun := @SF_BuyDomikExtremal;
  Scope.Add('BuyTranclucator', value_host_function).AsExternFun := @SF_BuyTranclucator;
  Scope.Add('TransferShip', value_host_function).AsExternFun := @SF_TransferShip;
  Scope.Add('OrderForsage', value_host_function).AsExternFun := @SF_OrderForsage;
  Scope.Add('OrderNone', value_host_function).AsExternFun := @SF_OrderNone;
  Scope.Add('OrderMove', value_host_function).AsExternFun := @SF_OrderMove;
  Scope.Add('OrderTeleport', value_host_function).AsExternFun := @SF_OrderTeleport;
  Scope.Add('OrderTakeOff', value_host_function).AsExternFun := @SF_OrderTakeOff;
  Scope.Add('OrderFollowShip', value_host_function).AsExternFun := @SF_OrderFollowShip;
  Scope.Add('OrderJumpHole', value_host_function).AsExternFun := @SF_OrderJumpHole;
  Scope.Add('RelationToRanger', value_host_function).AsExternFun := @SF_RelationToRanger;
  Scope.Add('RelationToShip', value_host_function).AsExternFun := @SF_RelationToShip;
  Scope.Add('StarOwner', value_host_function).AsExternFun := @SF_StarOwner;
  Scope.Add('StarBattle', value_host_function).AsExternFun := @SF_StarBattle;
  Scope.Add('StarSeries', value_host_function).AsExternFun := @SF_StarSeries;
  Scope.Add('StarHoles', value_host_function).AsExternFun := @SF_StarHoles;
  Scope.Add('StarNearbyStars', value_host_function).AsExternFun := @SF_StarNearbyStars;
  Scope.Add('StarNearbyStarsDist', value_host_function).AsExternFun := @SF_StarNearbyStarsDist;
  Scope.Add('StarSetGraph', value_host_function).AsExternFun := @SF_StarSetGraph;
  Scope.Add('CreatePlanet', value_host_function).AsExternFun := @SF_CreatePlanet;
  Scope.Add('PlanetSetGraph', value_host_function).AsExternFun := @SF_PlanetSetGraph;
  Scope.Add('PlanetGetGraph', value_host_function).AsExternFun := @SF_PlanetGetGraph;
  Scope.Add('PlanetPopulation', value_host_function).AsExternFun := @SF_PlanetPopulation;
  Scope.Add('PlanetOwner', value_host_function).AsExternFun := @SF_PlanetOwner;
  Scope.Add('PlanetRace', value_host_function).AsExternFun := @SF_PlanetRace;
  Scope.Add('PlanetGov', value_host_function).AsExternFun := @SF_PlanetGov;
  Scope.Add('PlanetEco', value_host_function).AsExternFun := @SF_PlanetEco;
  Scope.Add('PlanetTerrain', value_host_function).AsExternFun := @SF_PlanetTerrain;
  Scope.Add('PlanetTerrainExplored', value_host_function).AsExternFun := @SF_PlanetTerrainExplored;
  Scope.Add('PlanetOrbitRadius', value_host_function).AsExternFun := @SF_PlanetOrbitRadius;
  Scope.Add('PlanetOrbitalVelocity', value_host_function).AsExternFun := @SF_PlanetOrbitalVelocity;
  Scope.Add('PlanetSize', value_host_function).AsExternFun := @SF_PlanetSize;
  Scope.Add('PlanetCurInvention', value_host_function).AsExternFun := @SF_PlanetCurInvention;
  Scope.Add('PlanetCurInventionPoints', value_host_function).AsExternFun := @SF_PlanetCurInventionPoints;
  Scope.Add('PlanetInventionLevel', value_host_function).AsExternFun := @SF_PlanetInventionLevel;
  Scope.Add('PlanetBoostInventions', value_host_function).AsExternFun := @SF_PlanetBoostInventions;
  Scope.Add('PlanetWarriors', value_host_function).AsExternFun := @SF_PlanetWarriors;
  Scope.Add('GalaxySectors', value_host_function).AsExternFun := @SF_GalaxySectors;
  Scope.Add('GalaxyTechLevel', value_host_function).AsExternFun := @SF_GalaxyTechLevel;
  Scope.Add('GalaxyDominatorResearchPercent', value_host_function).AsExternFun := @SF_GalaxyDominatorResearchPercent;
  Scope.Add('GalaxyDominatorResearchMaterial', value_host_function).AsExternFun := @SF_GalaxyDominatorResearchMaterial;
  Scope.Add('GalaxyDiffLevels', value_host_function).AsExternFun := @SF_GalaxyDiffLevels;
  Scope.Add('SectorVisible', value_host_function).AsExternFun := @SF_SectorVisible;
  Scope.Add('HullHP', value_host_function).AsExternFun := @SF_HullHP;
  Scope.Add('HullDamageSuspectibility', value_host_function).AsExternFun := @SF_HullDamageSuspectibility;
  Scope.Add('HullType', value_host_function).AsExternFun := @SF_HullType;
  Scope.Add('HullSpecial', value_host_function).AsExternFun := @SF_HullSpecial;
  Scope.Add('HullSeries', value_host_function).AsExternFun := @SF_HullSeries;
  Scope.Add('GalaxyHoles', value_host_function).AsExternFun := @SF_GalaxyHoles;
  Scope.Add('HoleCreate2', value_host_function).AsExternFun := @SF_HoleCreate2;
  Scope.Add('HoleStar1', value_host_function).AsExternFun := @SF_HoleStar1;
  Scope.Add('HoleStar2', value_host_function).AsExternFun := @SF_HoleStar2;
  Scope.Add('HoleX1', value_host_function).AsExternFun := @SF_HoleX1;
  Scope.Add('HoleY1', value_host_function).AsExternFun := @SF_HoleY1;
  Scope.Add('HoleX2', value_host_function).AsExternFun := @SF_HoleX2;
  Scope.Add('HoleY2', value_host_function).AsExternFun := @SF_HoleY2;
  Scope.Add('HoleTurnCreate', value_host_function).AsExternFun := @SF_HoleTurnCreate;
  Scope.Add('HoleMap', value_host_function).AsExternFun := @SF_HoleMap;
  Scope.Add('HoleGraph', value_host_function).AsExternFun := @SF_HoleGraph;
  Scope.Add('StarRuins', value_host_function).AsExternFun := @SF_StarRuins;
  Scope.Add('CreateQuestItem', value_host_function).AsExternFun := @SF_CreateQuestItem;
  Scope.Add('ShipOrder', value_host_function).AsExternFun := @SF_ShipOrder;
  Scope.Add('ShipTurnBeforeEndOrder', value_host_function).AsExternFun := @SF_ShipTurnBeforeEndOrder;
  Scope.Add('ShipOrderData1', value_host_function).AsExternFun := @SF_ShipOrderData1;
  Scope.Add('ShipOrderData2', value_host_function).AsExternFun := @SF_ShipOrderData2;
  Scope.Add('ShipOrderObj', value_host_function).AsExternFun := @SF_ShipOrderObj;
  Scope.Add('ShipDestination', value_host_function).AsExternFun := @SF_ShipDestination;
  Scope.Add('BuildRuins', value_host_function).AsExternFun := @SF_BuildRuins;
  Scope.Add('BuildCustomRuins', value_host_function).AsExternFun := @SF_BuildCustomRuins;
  Scope.Add('RuinsChangeType', value_host_function).AsExternFun := @SF_RuinsChangeType;
  Scope.Add('ShipStanding', value_host_function).AsExternFun := @SF_ShipStanding;
  Scope.Add('ShipSlots', value_host_function).AsExternFun := @SF_ShipSlots;
  Scope.Add('MissileStar', value_host_function).AsExternFun := @SF_MissileStar;
  Scope.Add('MissileType', value_host_function).AsExternFun := @SF_MissileType;
  Scope.Add('CustomMissileType', value_host_function).AsExternFun := @SF_CustomMissileType;
  Scope.Add('MissileOwner', value_host_function).AsExternFun := @SF_MissileOwner;
  Scope.Add('MissileWeaponID', value_host_function).AsExternFun := @SF_MissileWeaponID;
  Scope.Add('MissileTarget', value_host_function).AsExternFun := @SF_MissileTarget;
  Scope.Add('MissileMaxDamage', value_host_function).AsExternFun := @SF_MissileMaxDamage;
  Scope.Add('MissileMinDamage', value_host_function).AsExternFun := @SF_MissileMinDamage;
  Scope.Add('MissileLive', value_host_function).AsExternFun := @SF_MissileLive;
  Scope.Add('MissileSpeed', value_host_function).AsExternFun := @SF_MissileSpeed;
  Scope.Add('MissileAngle', value_host_function).AsExternFun := @SF_MissileAngle;
  Scope.Add('AsteroidMinerals', value_host_function).AsExternFun := @SF_AsteroidMinerals;
  Scope.Add('AsteroidGraph', value_host_function).AsExternFun := @SF_AsteroidGraph;
  Scope.Add('AsteroidRespawn', value_host_function).AsExternFun := @SF_AsteroidRespawn;
  Scope.Add('ArrayAdd', value_host_function).AsExternFun := @SF_ArrayAdd;
  Scope.Add('ArrayDelete', value_host_function).AsExternFun := @SF_ArrayDelete;
  Scope.Add('ArrayClear', value_host_function).AsExternFun := @SF_ArrayClear;
  Scope.Add('ArrayDim', value_host_function).AsExternFun := @SF_ArrayDim;
  Scope.Add('ArraySort', value_host_function).AsExternFun := @SF_ArraySort;
  Scope.Add('ArraySortPartial', value_host_function).AsExternFun := @SF_ArraySortPartial;
  Scope.Add('ArrayRandomize', value_host_function).AsExternFun := @SF_ArrayRandomize;
  Scope.Add('ArrayFind', value_host_function).AsExternFun := @SF_ArrayFind;
  Scope.Add('ArrayFindInSorted', value_host_function).AsExternFun := @SF_ArrayFindInSorted;
  Scope.Add('DistToNearestEnemySystem', value_host_function).AsExternFun := @SF_DistToNearestEnemySystem;
  Scope.Add('StarEnemyThreatLevel', value_host_function).AsExternFun := @SF_StarEnemyThreatLevel;
  Scope.Add('BuildListOfQuestPossibleLocations', value_host_function).AsExternFun := @SF_BuildListOfQuestPossibleLocations;
  Scope.Add('FindItemInShip', value_host_function).AsExternFun := @SF_FindItemInShip;
  Scope.Add('GalaxyRangers', value_host_function).AsExternFun := @SF_GalaxyRangers;
  Scope.Add('MakeShipEnterStar', value_host_function).AsExternFun := @SF_MakeShipEnterStar;
  Scope.Add('ShipGetBad', value_host_function).AsExternFun := @SF_ShipGetBad;
  Scope.Add('ShipAddDropItem', value_host_function).AsExternFun := @SF_ShipAddDropItem;
  Scope.Add('OrderLock', value_host_function).AsExternFun := @SF_OrderLock;
  Scope.Add('BonusCount', value_host_function).AsExternFun := @SF_BonusCount;
  Scope.Add('SeriesCount', value_host_function).AsExternFun := @SF_SeriesCount;
  Scope.Add('BonusPriority', value_host_function).AsExternFun := @SF_BonusPriority;
  Scope.Add('BonusIsSpecial', value_host_function).AsExternFun := @SF_BonusIsSpecial;
  Scope.Add('BonusName', value_host_function).AsExternFun := @SF_BonusName;
  Scope.Add('BonusNumInCfg', value_host_function).AsExternFun := @SF_BonusNumInCfg;
  Scope.Add('SeriesNumInCfg', value_host_function).AsExternFun := @SF_SeriesNumInCfg;
  Scope.Add('BonusValue', value_host_function).AsExternFun := @SF_BonusValue;
  Scope.Add('FindBonusByName', value_host_function).AsExternFun := @SF_FindBonusByName;
  Scope.Add('FindSeriesByName', value_host_function).AsExternFun := @SF_FindSeriesByName;
  Scope.Add('FindBonusByCustomTag', value_host_function).AsExternFun := @SF_FindBonusByCustomTag;
  Scope.Add('FindBonusByNameInCfg', value_host_function).AsExternFun := @SF_FindBonusByNameInCfg;
  Scope.Add('BonusCustomTag', value_host_function).AsExternFun := @SF_BonusCustomTag;
  Scope.Add('CreateEquipmentWithSpecial', value_host_function).AsExternFun := @SF_CreateEquipmentWithSpecial;
  Scope.Add('SpecialToEquipment', value_host_function).AsExternFun := @SF_SpecialToEquipment;
  Scope.Add('ModuleToEquipment', value_host_function).AsExternFun := @SF_ModuleToEquipment;
  Scope.Add('EqSpecial', value_host_function).AsExternFun := @SF_EqSpecial;
  Scope.Add('EqModule', value_host_function).AsExternFun := @SF_EqModule;
  Scope.Add('MayAddBonusToEq', value_host_function).AsExternFun := @SF_MayAddBonusToEq;
  Scope.Add('BuildListOfMMByPriority', value_host_function).AsExternFun := @SF_BuildListOfMMByPriority;
  Scope.Add('BuildListOfNewShips', value_host_function).AsExternFun := @SF_BuildListOfNewShips;
  Scope.Add('PlanetToStar', value_host_function).AsExternFun := @SF_PlanetToStar;
  Scope.Add('Chameleon', value_host_function).AsExternFun := @SF_Chameleon;
  Scope.Add('IsChameleon', value_host_function).AsExternFun := @SF_IsChameleon;
  Scope.Add('PlayerChameleonCharges', value_host_function).AsExternFun := @SF_PlayerChameleonCharges;
  Scope.Add('PlayerChameleonCurType', value_host_function).AsExternFun := @SF_PlayerChameleonCurType;
  Scope.Add('PlayerChameleonDetected', value_host_function).AsExternFun := @SF_PlayerChameleonDetected;
  Scope.Add('PlayerLogicChameleon', value_host_function).AsExternFun := @SF_PlayerLogicChameleon;
  Scope.Add('SwitchToMirrorImage', value_host_function).AsExternFun := @SF_SwitchToMirrorImage;
  Scope.Add('EquipmentImageName', value_host_function).AsExternFun := @SF_EquipmentImageName;
  Scope.Add('StarFonImage', value_host_function).AsExternFun := @SF_StarFonImage;
  Scope.Add('ExtremalTakeOff', value_host_function).AsExternFun := @SF_ExtremalTakeOff;
  Scope.Add('ForceNextDay', value_host_function).AsExternFun := @SF_ForceNextDay;
  Scope.Add('ScriptActionsRun', value_host_function).AsExternFun := @SF_ScriptActionsRun;
  Scope.Add('StarListToPlanetList', value_host_function).AsExternFun := @SF_StarListToPlanetList;
  Scope.Add('EndGame', value_host_function).AsExternFun := @SF_EndGame;
  Scope.Add('CustomWin', value_host_function).AsExternFun := @SF_CustomWin;
  Scope.Add('CustomLose', value_host_function).AsExternFun := @SF_CustomLose;
  Scope.Add('PirateWin', value_host_function).AsExternFun := @SF_PirateWin;
  Scope.Add('StartVideo', value_host_function).AsExternFun := @SF_StartVideo;
  Scope.Add('StartMusic', value_host_function).AsExternFun := @SF_StartMusic;
  Scope.Add('MusicControls', value_host_function).AsExternFun := @SF_MusicControls;
  Scope.Add('NoComeKlingToStar', value_host_function).AsExternFun := @SF_NoComeKlingToStar;
  Scope.Add('NoDropToShip', value_host_function).AsExternFun := @SF_NoDropToShip;
  Scope.Add('NoTargetToShip', value_host_function).AsExternFun := @SF_NoTargetToShip;
  Scope.Add('NoTalkToShip', value_host_function).AsExternFun := @SF_NoTalkToShip;
  Scope.Add('NoScanToShip', value_host_function).AsExternFun := @SF_NoScanToShip;
  Scope.Add('NoJump', value_host_function).AsExternFun := @SF_NoJump;
  Scope.Add('NoLanding', value_host_function).AsExternFun := @SF_NoLanding;
  Scope.Add('NoShopUpdate', value_host_function).AsExternFun := @SF_NoShopUpdate;
  Scope.Add('PlanetExtraFlags', value_host_function).AsExternFun := @SF_PlanetExtraFlags;
  Scope.Add('NoDropItem', value_host_function).AsExternFun := @SF_NoDropItem;
  Scope.Add('CanSellItem', value_host_function).AsExternFun := @SF_CanSellItem;
  Scope.Add('TruceBetweenShips', value_host_function).AsExternFun := @SF_TruceBetweenShips;
  Scope.Add('ShipInPrison', value_host_function).AsExternFun := @SF_ShipInPrison;
  Scope.Add('ShipPartners', value_host_function).AsExternFun := @SF_ShipPartners;
  Scope.Add('PlayerPirates', value_host_function).AsExternFun := @SF_PlayerPirates;
  Scope.Add('ShipIsPartner', value_host_function).AsExternFun := @SF_ShipIsPartner;
  Scope.Add('ShipFreeSpace', value_host_function).AsExternFun := @SF_ShipFreeSpace;
  Scope.Add('ShipWealth', value_host_function).AsExternFun := @SF_ShipWealth;
  Scope.Add('DomiksDefeated', value_host_function).AsExternFun := @SF_DomiksDefeated;
  Scope.Add('CoalitionDefeated', value_host_function).AsExternFun := @SF_CoalitionDefeated;
  Scope.Add('ShipRefuel', value_host_function).AsExternFun := @SF_ShipRefuel;
  Scope.Add('ShipRepairEq', value_host_function).AsExternFun := @SF_ShipRepairEq;
  Scope.Add('ItemInScript', value_host_function).AsExternFun := @SF_ItemInScript;
  Scope.Add('FindPlanetByAdvancement', value_host_function).AsExternFun := @SF_FindPlanetByAdvancement;
  Scope.Add('StarListToTransitPlanetList', value_host_function).AsExternFun := @SF_StarListToTransitPlanetList;
  Scope.Add('GalaxyEvents', value_host_function).AsExternFun := @SF_GalaxyEvents;
  Scope.Add('GalaxyEventDate', value_host_function).AsExternFun := @SF_GalaxyEventDate;
  Scope.Add('GalaxyEventType', value_host_function).AsExternFun := @SF_GalaxyEventType;
  Scope.Add('GalaxyEventData', value_host_function).AsExternFun := @SF_GalaxyEventData;
  Scope.Add('GalaxyEventsTextData', value_host_function).AsExternFun := @SF_GalaxyEventsTextData;
  Scope.Add('PlanetNews', value_host_function).AsExternFun := @SF_PlanetNews;
  Scope.Add('PlanetNewsDate', value_host_function).AsExternFun := @SF_PlanetNewsDate;
  Scope.Add('PlanetNewsType', value_host_function).AsExternFun := @SF_PlanetNewsType;
  Scope.Add('PlanetNewsText', value_host_function).AsExternFun := @SF_PlanetNewsText;
  Scope.Add('ControlledSystems', value_host_function).AsExternFun := @SF_ControlledSystems;
  Scope.Add('DeltaWin', value_host_function).AsExternFun := @SF_DeltaWin;
  Scope.Add('ShipInFear', value_host_function).AsExternFun := @SF_ShipInFear;
  Scope.Add('CreateGoods', value_host_function).AsExternFun := @SF_CreateGoods;
  Scope.Add('GetNodesFromShip', value_host_function).AsExternFun := @SF_GetNodesFromShip;
  Scope.Add('GetNodesFromStorage', value_host_function).AsExternFun := @SF_GetNodesFromStorage;
  Scope.Add('RangerBaseNodes', value_host_function).AsExternFun := @SF_RangerBaseNodes;
  Scope.Add('RuinsAllowModernization', value_host_function).AsExternFun := @SF_RuinsAllowModernization;
  Scope.Add('RuinsMicromoduleChain', value_host_function).AsExternFun := @SF_RuinsMicromoduleChain;
  Scope.Add('DomikKilledInCurSystem', value_host_function).AsExternFun := @SF_DomikKilledInCurSystem;
  Scope.Add('ShipTypeN', value_host_function).AsExternFun := @SF_ShipTypeN;
  Scope.Add('ShipSubType', value_host_function).AsExternFun := @SF_ShipSubType;
  Scope.Add('ShipChangeStar', value_host_function).AsExternFun := @SF_ShipChangeStar;
  Scope.Add('IsFilm', value_host_function).AsExternFun := @SF_IsFilm;
  Scope.Add('FilmFlags', value_host_function).AsExternFun := @SF_FilmFlags;
  Scope.Add('ShowEffect', value_host_function).AsExternFun := @SF_ShowEffect;
  Scope.Add('ShowStaticEffect', value_host_function).AsExternFun := @SF_ShowStaticEffect;
  Scope.Add('ShipConnect', value_host_function).AsExternFun := @SF_ShipConnect;
  Scope.Add('FilmSound', value_host_function).AsExternFun := @SF_FilmSound;
  Scope.Add('FireWeapon', value_host_function).AsExternFun := @SF_FireWeapon;
  Scope.Add('WeaponHit', value_host_function).AsExternFun := @SF_WeaponHit;
  Scope.Add('DealDamageToShip', value_host_function).AsExternFun := @SF_DealDamageToShip;
  Scope.Add('LaunchMissile', value_host_function).AsExternFun := @SF_LaunchMissile;
  Scope.Add('SpawnMissile', value_host_function).AsExternFun := @SF_SpawnMissile;
  Scope.Add('BonusText', value_host_function).AsExternFun := @SF_BonusText;
  Scope.Add('PlanetPirateClan', value_host_function).AsExternFun := @SF_PlanetPirateClan;
  Scope.Add('Blazer', value_host_function).AsExternFun := @SF_Blazer;
  Scope.Add('Keller', value_host_function).AsExternFun := @SF_Keller;
  Scope.Add('Terron', value_host_function).AsExternFun := @SF_Terron;
  Scope.Add('PirateType', value_host_function).AsExternFun := @SF_PirateType;
  Scope.Add('PlayerQuestInProgress', value_host_function).AsExternFun := @SF_PlayerQuestInProgress;
  Scope.Add('PlayerQuestsCompleted', value_host_function).AsExternFun := @SF_PlayerQuestsCompleted;
  Scope.Add('QuestsStatusByNom', value_host_function).AsExternFun := @SF_QuestsStatusByNom;
  Scope.Add('PlayerPlanetaryBattlesCompleted', value_host_function).AsExternFun := @SF_PlayerPlanetaryBattlesCompleted;
  Scope.Add('PlayerMayTakeSubCrack', value_host_function).AsExternFun := @SF_PlayerMayTakeSubCrack;
  Scope.Add('SubCrackCost', value_host_function).AsExternFun := @SF_SubCrackCost;
  Scope.Add('ShipCalcParam', value_host_function).AsExternFun := @SF_ShipCalcParam;
  Scope.Add('ShipRefit', value_host_function).AsExternFun := @SF_ShipRefit;
  Scope.Add('ShipImproveItems', value_host_function).AsExternFun := @SF_ShipImproveItems;
  Scope.Add('ItemImprovement', value_host_function).AsExternFun := @SF_ItemImprovement;
  Scope.Add('ShipFreeFlight', value_host_function).AsExternFun := @SF_ShipFreeFlight;
  Scope.Add('ShipKillFactionInCurSystem', value_host_function).AsExternFun := @SF_ShipKillFactionInCurSystem;
  Scope.Add('CapitalShipStats', value_host_function).AsExternFun := @SF_CapitalShipStats;
  Scope.Add('PlayerBridge', value_host_function).AsExternFun := @SF_PlayerBridge;
  Scope.Add('PlayerDebt', value_host_function).AsExternFun := @SF_PlayerDebt;
  Scope.Add('PlayerDebtDate', value_host_function).AsExternFun := @SF_PlayerDebtDate;
  Scope.Add('PlayerDebtCnt', value_host_function).AsExternFun := @SF_PlayerDebtCnt;
  Scope.Add('PlayerDeposit', value_host_function).AsExternFun := @SF_PlayerDeposit;
  Scope.Add('PlayerDepositDate', value_host_function).AsExternFun := @SF_PlayerDepositDate;
  Scope.Add('PlayerDepositDay', value_host_function).AsExternFun := @SF_PlayerDepositDay;
  Scope.Add('PlayerDepositPercent', value_host_function).AsExternFun := @SF_PlayerDepositPercent;
  Scope.Add('PlayerMedPolicy', value_host_function).AsExternFun := @SF_PlayerMedPolicy;
  Scope.Add('ShipCustomShipInfosCount', value_host_function).AsExternFun := @SF_ShipCustomShipInfosCount;
  Scope.Add('ShipAddCustomShipInfo', value_host_function).AsExternFun := @SF_ShipAddCustomShipInfo;
  Scope.Add('ShipDeleteCustomShipInfo', value_host_function).AsExternFun := @SF_ShipDeleteCustomShipInfo;
  Scope.Add('ShipFindCustomShipInfoByType', value_host_function).AsExternFun := @SF_ShipFindCustomShipInfoByType;
  Scope.Add('ShipCustomShipInfoDescription', value_host_function).AsExternFun := @SF_ShipCustomShipInfoDescription;
  Scope.Add('ShipCustomShipInfoData', value_host_function).AsExternFun := @SF_ShipCustomShipInfoData;
  Scope.Add('ShipCustomShipInfoTextData', value_host_function).AsExternFun := @SF_ShipCustomShipInfoTextData;
  Scope.Add('StarCustomStarInfosCount', value_host_function).AsExternFun := @SF_StarCustomStarInfosCount;
  Scope.Add('StarAddCustomStarInfo', value_host_function).AsExternFun := @SF_StarAddCustomStarInfo;
  Scope.Add('StarDeleteCustomStarInfo', value_host_function).AsExternFun := @SF_StarDeleteCustomStarInfo;
  Scope.Add('StarFindCustomStarInfoByType', value_host_function).AsExternFun := @SF_StarFindCustomStarInfoByType;
  Scope.Add('StarCustomStarInfoData', value_host_function).AsExternFun := @SF_StarCustomStarInfoData;
  Scope.Add('ItemCanBeBroken', value_host_function).AsExternFun := @SF_ItemCanBeBroken;
  Scope.Add('ItemFragility', value_host_function).AsExternFun := @SF_ItemFragility;
  Scope.Add('ItemDurability', value_host_function).AsExternFun := @SF_ItemDurability;
  Scope.Add('ItemLevel', value_host_function).AsExternFun := @SF_ItemLevel;
  Scope.Add('ContainerFuel', value_host_function).AsExternFun := @SF_ContainerFuel;
  Scope.Add('ItemCharge', value_host_function).AsExternFun := @SF_ItemCharge;
  Scope.Add('MissilesToRearm', value_host_function).AsExternFun := @SF_MissilesToRearm;
  Scope.Add('WeaponAmmunition', value_host_function).AsExternFun := @SF_WeaponAmmunition;
  Scope.Add('WeaponMaxAmmunition', value_host_function).AsExternFun := @SF_WeaponMaxAmmunition;
  Scope.Add('ShipSpecialBonuses', value_host_function).AsExternFun := @SF_ShipSpecialBonuses;
  Scope.Add('ItemExtraSpecials', value_host_function).AsExternFun := @SF_ItemExtraSpecials;
  Scope.Add('ItemExtraSpecialsCountByType', value_host_function).AsExternFun := @SF_ItemExtraSpecialsCountByType;
  Scope.Add('ItemExtraSpecialsAddByType', value_host_function).AsExternFun := @SF_ItemExtraSpecialsAddByType;
  Scope.Add('ItemExtraSpecialsDeleteByType', value_host_function).AsExternFun := @SF_ItemExtraSpecialsDeleteByType;
  Scope.Add('ExecuteCodeFromString', value_host_function).AsExternFun := @SF_ExecuteCodeFromString;
  Scope.Add('GenerateCodeStringFromBlock', value_host_function).AsExternFun := @SF_GenerateCodeStringFromBlock;
  Scope.Add('ItemOnUseCode', value_host_function).AsExternFun := @SF_ItemOnUseCode;
  Scope.Add('ItemOnActCode', value_host_function).AsExternFun := @SF_ItemOnActCode;
  Scope.Add('CreateActCodeEvent', value_host_function).AsExternFun := @SF_CreateActCodeEvent;
  Scope.Add('CurItem', value_host_function).AsExternFun := @SF_CurItem;
  Scope.Add('CurInfo', value_host_function).AsExternFun := @SF_CurInfo;
  Scope.Add('ScriptItemActShip', value_host_function).AsExternFun := @SF_ScriptItemActShip;
  Scope.Add('ScriptItemActObject1', value_host_function).AsExternFun := @SF_ScriptItemActObject1;
  Scope.Add('ScriptItemActObject2', value_host_function).AsExternFun := @SF_ScriptItemActObject2;
  Scope.Add('ScriptItemActParam', value_host_function).AsExternFun := @SF_ScriptItemActParam;
  Scope.Add('ScriptItemActionType', value_host_function).AsExternFun := @SF_ScriptItemActionType;
  Scope.Add('OnUseCodeTranclucator', value_host_function).AsExternFun := @SF_OnUseCodeTranclucator;
  Scope.Add('OnUseCodeTransmitter', value_host_function).AsExternFun := @SF_OnUseCodeTransmitter;
  Scope.Add('OnUseCodeBlackHole', value_host_function).AsExternFun := @SF_OnUseCodeBlackHole;
  Scope.Add('OnUseCodeMissileDef', value_host_function).AsExternFun := @SF_OnUseCodeMissileDef;
  Scope.Add('MessageBox', value_host_function).AsExternFun := @SF_MessageBox;
  Scope.Add('MessageBoxYesNo', value_host_function).AsExternFun := @SF_MessageBoxYesNo;
  Scope.Add('CountBox', value_host_function).AsExternFun := @SF_CountBox;
  Scope.Add('NumberBox', value_host_function).AsExternFun := @SF_NumberBox;
  Scope.Add('TextBox', value_host_function).AsExternFun := @SF_TextBox;
  Scope.Add('ListBox', value_host_function).AsExternFun := @SF_ListBox;
  Scope.Add('FormCurShip', value_host_function).AsExternFun := @SF_FormCurShip;
  Scope.Add('UselessItemText', value_host_function).AsExternFun := @SF_UselessItemText;
  Scope.Add('UselessItemData', value_host_function).AsExternFun := @SF_UselessItemData;
  Scope.Add('GetAchievementSHU', value_host_function).AsExternFun := @SF_GetAchievementSHU;
  Scope.Add('GetAchievementGIRLSHIRE', value_host_function).AsExternFun := @SF_GetAchievementGIRLSHIRE;
  Scope.Add('GetAchievementGIRLSQUEST', value_host_function).AsExternFun := @SF_GetAchievementGIRLSQUEST;
  Scope.Add('GetAchievementPIRATEWIN', value_host_function).AsExternFun := @SF_GetAchievementPIRATEWIN;
  Scope.Add('GetAchievementCOALLITION', value_host_function).AsExternFun := @SF_GetAchievementCOALLITION;
  Scope.Add('GetAchievementHULL', value_host_function).AsExternFun := @SF_GetAchievementHULL;
  Scope.Add('UICheckElement', value_host_function).AsExternFun := @SF_UICheckElement;
  Scope.Add('InterfaceState', value_host_function).AsExternFun := @SF_InterfaceState;
  Scope.Add('InterfaceText', value_host_function).AsExternFun := @SF_InterfaceText;
  Scope.Add('InterfaceImage', value_host_function).AsExternFun := @SF_InterfaceImage;
  Scope.Add('InterfacePos', value_host_function).AsExternFun := @SF_InterfacePos;
  Scope.Add('InterfaceSize', value_host_function).AsExternFun := @SF_InterfaceSize;
  Scope.Add('ButtonClick', value_host_function).AsExternFun := @SF_ButtonClick;
  Scope.Add('SetFocus', value_host_function).AsExternFun := @SF_SetFocus;
  Scope.Add('CurrentForm', value_host_function).AsExternFun := @SF_CurrentForm;
  Scope.Add('FormShipCurItem', value_host_function).AsExternFun := @SF_FormShipCurItem;
  Scope.Add('UpdateFormShip', value_host_function).AsExternFun := @SF_UpdateFormShip;
  Scope.Add('FormChange', value_host_function).AsExternFun := @SF_FormChange;
  Scope.Add('RunChildForm', value_host_function).AsExternFun := @SF_RunChildForm;
  Scope.Add('OpenCustomForm', value_host_function).AsExternFun := @SF_OpenCustomForm;
  Scope.Add('CloseCustomForm', value_host_function).AsExternFun := @SF_CloseCustomForm;
  Scope.Add('CustomInterfaceState', value_host_function).AsExternFun := @SF_CustomInterfaceState;
  Scope.Add('CustomInterfaceText', value_host_function).AsExternFun := @SF_CustomInterfaceText;
  Scope.Add('CustomInterfaceImage', value_host_function).AsExternFun := @SF_CustomInterfaceImage;
  Scope.Add('CustomInterfacePos', value_host_function).AsExternFun := @SF_CustomInterfacePos;
  Scope.Add('CustomInterfacePosZ', value_host_function).AsExternFun := @SF_CustomInterfacePosZ;
  Scope.Add('CustomInterfaceSize', value_host_function).AsExternFun := @SF_CustomInterfaceSize;
  Scope.Add('StarMapCenterView', value_host_function).AsExternFun := @SF_StarMapCenterView;
  Scope.Add('StarMapCurPosX', value_host_function).AsExternFun := @SF_StarMapCurPosX;
  Scope.Add('StarMapCurPosY', value_host_function).AsExternFun := @SF_StarMapCurPosY;
  Scope.Add('StarMapCustomSelectionMode', value_host_function).AsExternFun := @SF_StarMapCustomSelectionMode;
  Scope.Add('StarMapBlinkingMessage', value_host_function).AsExternFun := @SF_StarMapBlinkingMessage;
  Scope.Add('BlinkingWarning', value_host_function).AsExternFun := @SF_BlinkingWarning;
  Scope.Add('CustomWeaponTypes', value_host_function).AsExternFun := @SF_CustomWeaponTypes;
  Scope.Add('InventNewCustomWeapon', value_host_function).AsExternFun := @SF_InventNewCustomWeapon;
  Scope.Add('GetCustomWeaponInfo', value_host_function).AsExternFun := @SF_GetCustomWeaponInfo;
  Scope.Add('GetCustomWeaponData', value_host_function).AsExternFun := @SF_GetCustomWeaponData;
  Scope.Add('GetCustomWeaponPrimaryDamageType', value_host_function).AsExternFun := @SF_GetCustomWeaponPrimaryDamageType;
  Scope.Add('SetCustomWeaponAvailability', value_host_function).AsExternFun := @SF_SetCustomWeaponAvailability;
  Scope.Add('SetCustomWeaponSE', value_host_function).AsExternFun := @SF_SetCustomWeaponSE;
  Scope.Add('SetCustomWeaponPrimaryData', value_host_function).AsExternFun := @SF_SetCustomWeaponPrimaryData;
  Scope.Add('SetCustomWeaponSizeAndCost', value_host_function).AsExternFun := @SF_SetCustomWeaponSizeAndCost;
  Scope.Add('SetCustomWeaponDamageData', value_host_function).AsExternFun := @SF_SetCustomWeaponDamageData;
  Scope.Add('SetCustomWeaponShotData', value_host_function).AsExternFun := @SF_SetCustomWeaponShotData;
  Scope.Add('SetCustomMissileWeaponStats', value_host_function).AsExternFun := @SF_SetCustomMissileWeaponStats;
  Scope.Add('StarCustomFaction', value_host_function).AsExternFun := @SF_StarCustomFaction;
  Scope.Add('ShipCustomFaction', value_host_function).AsExternFun := @SF_ShipCustomFaction;
  Scope.Add('EqCustomFaction', value_host_function).AsExternFun := @SF_EqCustomFaction;
  Scope.Add('PlanetCustomFaction', value_host_function).AsExternFun := @SF_PlanetCustomFaction;
  Scope.Add('ImportedFunction', value_host_function).AsExternFun := @SF_ImportedFunction;
  Scope.Add('ImportAll', value_host_function).AsExternFun := @SF_ImportAll;
  Scope.Add('GalaxyPtr', value_host_function).AsExternFun := @SF_GalaxyPtr;
  Scope.Add('t_ArtDefToEnergy', value_int32).AsInteger := Ord(artefact_defense_to_energy);
  Scope.Add('t_ArtEnergyPulse', value_int32).AsInteger := Ord(artefact_energy_pulse);
  Scope.Add('t_ArtEnergyDef', value_int32).AsInteger := Ord(artefact_energy_defense);
  Scope.Add('t_ArtSplinter', value_int32).AsInteger := Ord(artefact_splinter);
  Scope.Add('t_ArtDecelerate', value_int32).AsInteger := Ord(artefact_decelerate);
  Scope.Add('t_ArtMissileDef', value_int32).AsInteger := Ord(artefact_missile_defense);
  Scope.Add('t_ArtForsage', value_int32).AsInteger := Ord(artefact_afterburner);
  Scope.Add('t_ArtWeaponToSpeed', value_int32).AsInteger := Ord(artefact_weapon_to_speed);
  Scope.Add('t_ArtGiperJump', value_int32).AsInteger := Ord(artefact_hyperjump);
  Scope.Add('t_ArtBlackHole', value_int32).AsInteger := Ord(artefact_black_hole);
  Scope.Add('t_ArtDefToArms1', value_int32).AsInteger := Ord(artefact_defense_to_weapon_slot);
  Scope.Add('t_ArtDefToArms2', value_int32).AsInteger := Ord(artefact_defense_slot_to_weapons);
  Scope.Add('t_ArtArtefactor', value_int32).AsInteger := Ord(artefact_artefactor);
  Scope.Add('t_ArtBio', value_int32).AsInteger := Ord(artefact_health_protection);
  Scope.Add('t_ArtPDTurret', value_int32).AsInteger := Ord(artefact_point_defense);
  Scope.Add('t_ArtFastRacks', value_int32).AsInteger := Ord(artefact_extra_missiles);
  Scope.Add('t_Cistern', value_int32).AsInteger := Ord(item_fuel_container);
  Scope.Add('t_Satellite', value_int32).AsInteger := Ord(item_satellite);
  Scope.Add('t_MicroModule', value_int32).AsInteger := Ord(item_micro_module);
  Scope.Add('t_UselessCountableItem', value_int32).AsInteger := Ord(item_stackable_misc);
  Scope.Add('TalkMoney', value_int32).AsInteger := Ord(talk_event_demand_money);
  Scope.Add('TalkGoods', value_int32).AsInteger := Ord(talk_event_demand_goods);
  Scope.Add('TalkTruce', value_int32).AsInteger := Ord(talk_event_offer_truce);
  Scope.Add('TalkAttack', value_int32).AsInteger := Ord(talk_event_attack);
  Scope.Add('TalkBreakPartner', value_int32).AsInteger := Ord(talk_event_partnership_broken);
  Scope.Add('TalkPartnerTheEnd', value_int32).AsInteger := Ord(talk_event_partnership_expired);
  Scope.Add('TalkPartnerRiot', value_int32).AsInteger := Ord(talk_event_partner_rebellion);
  for BonusIndex := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
    Scope.Add(EquipmentBonusNames[BonusIndex], value_int32).AsInteger := Ord(BonusIndex);
  for ActionIndex := Low(TScriptEventKind) to High(TScriptEventKind) do
    Scope.Add(ScriptActionTypeNames[ActionIndex], value_int32).AsInteger := Ord(ActionIndex);
  ScriptRequestThread := TScriptThread.Create;
  ScriptRequestThread.SetPriority(ThreadPriorityBelowNormal);
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
{ @end $63AB6C }

end.
