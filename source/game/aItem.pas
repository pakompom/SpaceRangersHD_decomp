unit aItem;

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Struct, SE_Space, SE_Container, Windows, aEFilm, aGalaxy, aGalaxyStruct;

const
  // AssignedSlotData is also copied into TabWeapon.SlotData; bit 7 selects the weapon group.
  EquipmentSlotIndexMask = $7F;
  equipment_secondary_fire = $80;

type
  TTechLevel = 1..8; // @size $01 Native optimized promotion; equipment tables have eight levels.

  TItemTypeNameTable = array[TItemType] of WideString;
  PItemTypeNameTable = ^TItemTypeNameTable;

  TArtefactLootPool = array of TItemType;
  TArtefactLootPools = array[TItemLootPool] of TArtefactLootPool;
  PArtefactLootPools = ^TArtefactLootPools;
  TNamedItemLootPool = array of WideString;
  TNamedItemLootPools = array[TItemLootPool] of TNamedItemLootPool;
  PNamedItemLootPools = ^TNamedItemLootPools;

  TInterceptorTargetingStrategy = (
    interceptor_manual = 0,
    interceptor_most_health = 1,
    interceptor_least_health = 2,
    interceptor_strongest = 3,
    interceptor_best_defense = 4,
    interceptor_nearest = 5,
    interceptor_farthest = 6
  ); // @size 0x1

  TUpgradeKind = (
    upgrade_minor = 0,
    upgrade_medium = 1,
    upgrade_major = 2,
    upgrade_random = 3
  ); // @size 0x1

  TWeaponTargetKind = (
    weapon_target_none = 0,
    weapon_target_ship = 1,
    weapon_target_item = 2,
    weapon_target_asteroid = 3,
    weapon_target_missile = 4
  ); // @size 0x1

  TExtraSpecial = packed record // @size 0x8
    ModuleIndexPlusOne: Integer; // @offset 0x00
    Count: Integer; // @offset 0x04
  end;
  PExtraSpecial = ^TExtraSpecial;

  // Ship-valued parameters and fields are Pointer because aShip uses this unit.
  TItem = class;
  TEquipment = class;
  THull = class;
  TFuelTanks = class;
  TEngine = class;
  TRadar = class;
  TScaner = class;
  TRepairRobot = class;
  TCargoHook = class;
  TDefGenerator = class;
  TWeapon = class;
  TCustomWeapon = class;
  TGoods = class;
  TCountableItem = class;
  TProtoplasm = class;
  TEquipmentWithActCode = class;
  TUselessItem = class;
  TCistern = class;
  TSatellite = class;
  TTreasureMap = class;
  TMicroModule = class;
  TArtefact = class;
  TArtefactTransmitter = class;
  TArtefactTranclucator = class;
  TArtefactCustom = class;

  TItem = class(TObjectEx) // @size 0x38
  public
    GraphObject: TContainerSE; // @offset 0x04  Retained container scene reference; released on destruction.
    Id: Cardinal; // @offset 0x08
    ItemType: TItemType; // @offset 0x0C
    Position: TPointF; // @offset 0x10
    Weight: Integer; // @offset 0x18  Hull capacity for hull items.
    OwnerId: TOwnerId; // @offset 0x1C
    Cost: Integer; // @offset 0x20
    NameOverride: WideString; // @offset 0x24
    FilmObject: TEFilmObj; // @offset 0x28  Borrowed from the active film; not an integer object ID.
    ScriptItem: TObject; // @offset 0x2C  Borrowed TScriptItem; cleared when the wrapper is destroyed.
    DestroyFlag: Integer; // @offset 0x30  Script.ItemDestroy.
    NoDropFlag: Byte; // @offset 0x34  Script.NoDropItem; not restricted to Boolean values.


    procedure SaveToBuffer(Buffer: TBufEC); virtual; // @addr 0x006F57E4 @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); virtual; // @addr 0x006F5874 @slot 0x04 @note "Object-reference fields in descendants hold saved IDs until ResolveLoadedReferences; updates Galaxy.NextItemId."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); virtual; // @addr 0x006F5E90 @slot 0x08
    procedure ClearReferences; virtual; // @addr 0x006F5E94 @slot 0x0C
    procedure SaveToBlock(Block: TBlockParEC); virtual; // @addr 0x006F594C @slot 0x10
    procedure LoadFromBlock(Block: TBlockParEC); virtual; // @addr 0x006F5BB8 @slot 0x14
    function GetDisplayName: WideString; virtual; abstract; // @slot $18
    function GetShortName: WideString; virtual; // @addr 0x006F6070 @slot 0x1C
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; virtual; // @addr 0x006F607C @slot 0x20 @ida "void __userpurge $name(TItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"
    function GetDescriptionText: WideString; virtual; abstract; // @slot $24
    function GetBitmapResourceName: WideString; virtual; abstract; // @slot $28

    constructor Create; // @addr 0x006F56F0
    destructor Destroy; override; // @addr 0x006F5750
    function GetGraphObject: TContainerSE; // @addr 0x006F6164 @note "Lazily creates and initializes the retained scene container; returns a borrowed reference. Appearance depends on item kind, size, faction, and drop flags."
    procedure ReleaseGraphObject; // @addr 0x006F6F2C
    function GetSmallInfoText: WideString; // @addr 0x006F5E98 @note "Generic Items.SmallInfo label used outside radar range."
    function CalculateResaleValue(TradingSkill: Byte): Integer; // @addr 0x006F5ED0 @note "Applies the trading-skill percentage to Cost minus repair cost; equipment has a minimum value of 1. Goods use Cost directly."
    function GetConditionAdjustedCost: Integer; // @addr 0x006F5FB4 @note "Equipment deducts repair cost, with a minimum result of 1; goods return Cost unchanged."

    function GetCategoryConfigName: WideString; // @addr 0x006F5FF4 @note "Groups weapon types under Weapon and built-in artefacts under Artefact; otherwise returns the item-type configuration name."
    function GetOwnerConfigName: WideString; // @addr 0x006F6FF0 @note "Manufacturer/faction resource key, including custom factions and Dominator series."
  end;

  TEquipment = class(TItem) // @size 0x60
  public
    ConfigBlockName: WideString; // @offset 0x38
    CustomFaction: WideString; // @offset 0x3C  Script.EqCustomFaction.
    ConditionPercent: Double; // @offset 0x40  100 is fully maintained; hull integrity is tracked separately.
    BrokenFlag: Byte; // @offset 0x48
    EquippedFlag: Byte; // @offset 0x49
    AssignedSlotData: Dword; // @offset 0x4C  Low 7 bits: zero-based slot index; bit 7 selects secondary fire in arcade combat.
    // One-based MicroModuleTemplates indexes; zero means no module.
    // For a standalone TMicroModule, MicroModuleIndex identifies the item itself.
    MicroModuleIndex: Integer; // @offset 0x50
    SpecialModuleIndex: Integer; // @offset 0x54
    ExtraSpecials: TList; // @offset 0x58  Owns PExtraSpecial entries and the list; nil when absent.
    DominatorSeries: TDominatorSeries; // @offset 0x5C  Script.ItemSubrace.
    DetailImprovement: Byte; // @offset 0x5D  Transient selector: 0 chooses automatically; 1/2 emphasize different stats; weapons also accept 3 for range. Consumed by engine, gripper and weapon upgrades.

    function GetDisplayName: WideString; override; // @addr 0x006F9394 @slot 0x18
    function GetShortName: WideString; override; // @addr 0x006F962C

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x006F719C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x006F73C8
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x006F782C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x006F7CE4

    constructor Create; // @addr 0x006F70FC
    destructor Destroy; override; // @addr 0x006F713C
    procedure Equip; // @addr 0x006F7F4C
    procedure Unequip; virtual; // @addr 0x006F7FB0 @slot 0x2C
    procedure Repair; virtual; // @addr 0x006F8014 @slot 0x30
    function NeedsRepair: Boolean; // @addr 0x006F8028 @note "Tests hull damage or supported equipment below 90 percent condition."
    procedure Improve(Kind: TUpgradeKind); virtual; // @addr 0x006F9854 @slot 0x34 @note "Base is a no-op. Overrides change statistics and Cost without checking CanImprove or charging money; upgrade_random selects one of the three strengths."

    function GetLevel: Integer; // @addr 0x006F90C0 @note "Returns 0 for unsupported item types."
    function CalculateRepairCost: Integer; // @addr 0x006F8098 @note "Undiscounted cost; hulls use HullPoints, other supported equipment uses ConditionPercent and BrokenFlag."
    function HasMicroModule: Boolean; // @addr 0x006F9788
    function GetStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x006F9CF0
    function CalculateImprovementCost(Kind: TUpgradeKind): Integer; virtual; // @addr 0x006F9858 @slot 0x38 @note "Only upgrade_minor, upgrade_medium and upgrade_major are valid: Cost times 0.3, 0.6 or 1.2, rounded then truncated to a multiple of 10, before service discounts."
    function HasStandardStats: Boolean; virtual; // @addr 0x006F9908 @slot 0x3C @note "Tests expected generated statistics after accounting for installed bonuses; this is not a stored upgraded flag. The base implementation returns True."
    function GetMicroModuleQuotedName: WideString; // @addr 0x006F9790
    function GetSpecialModuleName: WideString; // @addr 0x006F9820

    function GetDescriptionText: WideString; override; // @addr 0x006F9224 @slot 0x24
    function GetBitmapResourceName: WideString; override; // @addr 0x006F990C @slot 0x28
    function GetFragilityFactor(DamageFlags: TDamageFlagSet): Single; virtual; // @addr 0x006F9B74 @slot 0x40 @ida "float __usercall $name@<st0>(TEquipment *Self@<eax>, unsigned int DamageFlags@<edx>);"
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); virtual; // @addr 0x006F9CC4 @slot 0x44
    function Clone: TItem; virtual; // @addr 0x006F779C @slot 0x48 @note "Allocates a new item ID and resolves references in the current galaxy; changes LoadedSaveVersion."
    procedure ImproveAtScientificBase; // @addr 0x006F9738 @note "Selects strength and stat emphasis from Id, then calls Improve. Charging and eligibility checks belong to the caller."
    function CanImprove: Boolean; // @addr 0x006FA9CC @note "Requires HasStandardStats and no special module that blocks the special slot; does not check technology access."
    function GetDescriptionStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x006F9E54 @note "Aggregate used by the bonus description, with SeparatedNumbers effects handled separately."
    function GetBonusDescription(ColorTag: WideString): WideString; // @addr 0x006FA354
    function GetConditionText(PrefixNewLine: Boolean): WideString; // @addr 0x006F830C @note "Includes player technology restrictions as well as wear and breakage."
    function GetBrokenInBattleText: WideString; // @addr 0x006F89E0
    function GetBrokenInUseText: WideString; // @addr 0x006F8C28
    function GetBrokenByForceText: WideString; // @addr 0x006F8E68
    function GetLevelLetter: WideString; // @addr 0x006F91F4 @note "A through H for levels 1 through 8; empty for unsupported levels."
  end;

  THull = class(TEquipment) // @size 0x84
  public
    HullPoints: Integer; // @offset 0x60
    TechLevel: Byte; // @offset 0x64
    Armor: ShortInt; // @offset 0x65
    HullType: THullType; // @offset 0x66 hull_* categories in aGalaxyStruct.
    HullSeries: Integer; // @offset 0x68  -1 means no series.
    OwnerShip: TObject; // @offset 0x6C  Borrowed; not serialized by the hull.
    CapitalShip: Byte; // @offset 0x70  Script.CapitalShipStats.
    PirateBuilt: Boolean; // @offset 0x71
    ImpulseShieldsEnabled: Boolean; // @offset 0x72
    InterceptorsEnabled: Boolean; // @offset 0x73
    Energy: Integer; // @offset 0x74
    EnergyMax: Integer; // @offset 0x78
    InterceptorTarget: TObject; // @offset 0x7C  Saved as an ID until ResolveLoadedReferences.
    InterceptorTargetingStrategy: TInterceptorTargetingStrategy; // @offset 0x80  Automatic target selection for the player.
    InterceptorPassCountOverride: Byte; // @offset 0x81  Zero selects five passes.

    function GetDisplayName: WideString; override; // @addr 0x006FBB44
    function GetShortName: WideString; override; // @addr 0x006FC0F4
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x006FC154 @ida "void __userpurge $name(THull *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x006FAB28
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x006FAC9C
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x006FAE98
    procedure ClearReferences; override; // @addr 0x006FAEC4
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x006FAED8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x006FB200

    procedure Init(Capacity: Integer; Level: Byte; Owner: TOwnerId; HullType: THullType; Series: Integer; PirateBuilt: Boolean); // @addr 0x006FAA04
    procedure Repair; override; // @addr 0x006FB938
    function GetSlotCount(Kind: TShipSlotKind): Integer; // @addr 0x006FCF08
    function GetFragilityFactor(DamageFlags: TDamageFlagSet): Single; override; // @addr 0x006FD2D0 @ida "float __usercall $name@<st0>(THull *Self@<eax>, unsigned int DamageFlags@<edx>);" @note "Zero flags return the average of energy, splinter and missile factors."
    function CalculateMass: Integer; // @addr 0x006FD264 @note "Round(capacity * (0.6 + 0.2 * (clamped level - 1) / 7)); excludes carried cargo and ship mass modifiers."
    function CalculateGeneratedArmor: ShortInt; // @addr 0x006FB500

    function GetBitmapResourceName: WideString; override; // @addr 0x006FCA80
    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x006FB94C
    function HasStandardStats: Boolean; override; // @addr 0x006FBAEC
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x006FC420
    procedure ApplySeriesSizeAndCost; // @addr 0x006FAA80 @note "Applies the current hull series, resets HullPoints to capacity, and bounds Cost."
    function CalculateGeneratedCost: Integer; // @addr 0x006FB8D0 @note "If cost generation overflows negative, repeatedly halves capacity and resets HullPoints before retrying."
    function GetSeriesName: WideString; // @addr 0x006FBFB0
    function GetSpecialKindGraph: WideString; // @addr 0x006FCEB4 @note "Returns the special module KindGraph, or the literal 1 as fallback."
    function EstimateCapacityWithoutBonuses: Integer; // @addr 0x006FD514 @note "Reverses module and series size percentages with rounding; extra-special multiplicities are not used."
  end;

  TFuelTanks = class(TEquipment) // @size 0x6C
  public
    TechLevel: Byte; // @offset 0x60
    Fuel: Integer; // @offset 0x64
    Capacity: Byte; // @offset 0x68

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x006FDC30 @ida "void __userpurge $name(TFuelTanks *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x006FD608
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x006FD63C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x006FD670
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x006FD7F8

    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x006FD5C0
    function CalculateGeneratedCapacity: Byte; // @addr 0x006FD978
    function CalculateGeneratedCost: Integer; // @addr 0x006FDA30

    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x006FDA44
    function HasStandardStats: Boolean; override; // @addr 0x006FDB44
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x006FDE78
  end;

  TEngine = class(TEquipment) // @size 0x6C
  public
    TechLevel: Byte; // @offset 0x60
    Speed: Integer; // @offset 0x64
    JumpRange: ShortInt; // @offset 0x68
    OutputPercent: Byte; // @offset 0x69

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x006FEAE8 @ida "void __userpurge $name(TEngine *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x006FE250
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x006FE290
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x006FE2EC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x006FE46C

    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x006FE204
    function CalculateGeneratedSpeed: Integer; // @addr 0x006FE5E4
    function CalculateGeneratedJumpRange: ShortInt; // @addr 0x006FE5F4
    function CalculateGeneratedCost: Integer; // @addr 0x006FE694

    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x006FE6A8
    function HasStandardStats: Boolean; override; // @addr 0x006FEA3C
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x006FECC8
  end;

  TRadar = class(TEquipment) // @size 0x68
  public
    TechLevel: Byte; // @offset 0x60
    Range: Integer; // @offset 0x64

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x006FFB88 @ida "void __userpurge $name(TRadar *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x006FF684
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x006FF6AC
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x006FF6D8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x006FF7F8

    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x006FF648
    function CalculateGeneratedRange: Integer; // @addr 0x006FF910
    function CalculateGeneratedCost: Integer; // @addr 0x006FF9B0

    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x006FF9C4
    function HasStandardStats: Boolean; override; // @addr 0x006FFB34
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x006FFD64
  end;

  TScaner = class(TEquipment) // @size 0x64
  public
    TechLevel: Byte; // @offset 0x60
    ScanPower: ShortInt; // @offset 0x61

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x007007BC @ida "void __userpurge $name(TScaner *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x007002A8
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x007002D0
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x0070031C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00700438

    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x0070026C
    function CalculateGeneratedScanPower: Integer; // @addr 0x0070054C
    function CalculateGeneratedCost: Integer; // @addr 0x007005FC

    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x00700610
    function HasStandardStats: Boolean; override; // @addr 0x00700764
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x0070099C
  end;

  TRepairRobot = class(TEquipment) // @size 0x64
  public
    TechLevel: Byte; // @offset 0x60
    RepairPoints: Byte; // @offset 0x61

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x00701428 @ida "void __userpurge $name(TRepairRobot *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x00700EAC
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x00700ED4
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x00700F90
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x007010B0

    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x00700E70
    function CalculateGeneratedRepairPoints: Byte; // @addr 0x007011C8
    function CalculateGeneratedCost: Integer; // @addr 0x00701268

    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x0070127C
    function HasStandardStats: Boolean; override; // @addr 0x007013D0
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x00701628
  end;

  TCargoHook = class(TEquipment) // @size 0x74
  public
    TechLevel: Byte; // @offset 0x60
    PickupPower: Integer; // @offset 0x64
    Range: Integer; // @offset 0x68
    MinPullSpeed: Single; // @offset 0x6C
    MaxPullSpeed: Single; // @offset 0x70

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x007025F0 @ida "void __userpurge $name(TCargoHook *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x00701BE0
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x00701C28
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x00701C74
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00701EE4

    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x00701B84
    function CalculateGeneratedPickupPower: Integer; // @addr 0x00702100
    function CalculateGeneratedRange: Integer; // @addr 0x00702114
    function CalculateGeneratedMinPullSpeed: Single; // @addr 0x00702128
    function CalculateGeneratedMaxPullSpeed: Single; // @addr 0x00702144
    function CalculateGeneratedCost: Integer; // @addr 0x007021F0

    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x00702204
    function HasStandardStats: Boolean; override; // @addr 0x00702548
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x007027E4
    constructor Create; // @addr 0x00701B4C
  end;

  TDefGenerator = class(TEquipment) // @size 0x68
  public
    TechLevel: Byte; // @offset 0x60
    DamageFactor: Single; // @offset 0x64

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x00703800 @ida "void __userpurge $name(TDefGenerator *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x00703334
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x0070335C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x00703384
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x007034B0

    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x007032E8
    function CalculateGeneratedDamageFactor: Single; // @addr 0x007035AC

    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x007036C8
    function HasStandardStats: Boolean; override; // @addr 0x0070378C
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x00703A04
  end;

  TWeapon = class(TEquipment) // @size 0x80 @methodorder source
  public
    TechLevel: Byte; // @offset 0x60
    Range: Integer; // @offset 0x64
    MinDamage: Integer; // @offset 0x68
    MaxDamage: Integer; // @offset 0x6C
    Target: TObject; // @offset 0x70  Saved as an ID until ResolveLoadedReferences.
    LoadedTargetKind: TWeaponTargetKind; // @offset 0x74  Discriminator read from the save, not a live target classification.
    Ammo: Integer; // @offset 0x78
    AmmoCapacity: Integer; // @offset 0x7C

    function GetDisplayName: WideString; override; // @addr 0x0070544C
    function GetShortName: WideString; override; // @addr 0x00705540
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x007055EC @ida "void __userpurge $name(TWeapon *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x007040B8
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x00704230
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x00704AAC
    procedure ClearReferences; override; // @addr 0x00704B40
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x007043E8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00704744

    procedure Init(ItemType: TItemType; Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x00703F74
    procedure Unequip; override; // @addr 0x00704B58
    function GetConfigName: WideString; virtual; // @addr 0x00706E74 @slot 0x4C
    function GetWeaponInfo: PWeaponInfo; virtual; // @addr 0x00706E50 @slot 0x50
    function CalculateGeneratedAmmoCapacity: Integer; // @addr 0x00704B6C
    function CalculateGeneratedMinDamage: Integer; // @addr 0x00704B78
    function CalculateGeneratedMaxDamage: Integer; // @addr 0x00704BAC
    function CalculateGeneratedRange: Integer; // @addr 0x00704BE0
    function GetAttackCount: Integer; // @addr 0x00706DC4
    function GetShotCount: Integer; // @addr 0x00706D1C
    function GetShotDelayFactor: Double; // @addr 0x007068C8
    function NeedsAmmo: Boolean; // @addr 0x00706BCC
    function CalculateAmmoRefillCost: Integer; // @addr 0x00706BF4
    function GetShotPalette: Integer; // @addr 0x00706C58
    function GetDamageFlags: TDamageFlagSet; // @addr 0x00706C94 @ida "unsigned int __usercall $name@<eax>(TWeapon *Self@<eax>);" @note "Combines the weapon template and installed ordinary, special and extra-special module flags."

    function GetDescriptionText: WideString; override; // @addr 0x00706824
    function GetBitmapResourceName: WideString; override; // @addr 0x00706990
    procedure Improve(Kind: TUpgradeKind); override; // @addr 0x00704D68
    function HasStandardStats: Boolean; override; // @addr 0x00705428
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x00705870
    destructor Destroy; override; // @addr 0x00703F4C
    function CalculateStandardMaxDamage: Integer; // @addr 0x00704C04 @note "Generated maximum plus ordinary and special module damage bonuses; used by HasStandardStats."
    function CalculateStandardRange: Integer; // @addr 0x00704C74 @note "Generated range plus ordinary and special module range bonuses; used by HasStandardStats."
  end;

  TCustomWeapon = class(TWeapon) // @size 0x84
  public
    CustomInfo: PWeaponInfo; // @offset 0x80

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0070420C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x00704384
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x007046B4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00704A04

    procedure InitCustom(Info: PWeaponInfo; Equipped: Boolean; Weight: Integer; Level: Byte; Owner: TOwnerId); // @addr 0x00704008
    function GetWeaponInfo: PWeaponInfo; override; // @addr 0x00706E6C
    function GetConfigName: WideString; override; // @addr 0x00706ECC

    function GetBitmapResourceName: WideString; override; // @addr 0x00706AA4
  end;

  TGoods = class(TItem) // @size 0x40
  public
    Quantity: Integer; // @offset 0x38
    NaturalFlag: Boolean; // @offset 0x3C

    function GetDisplayName: WideString; override; // @addr 0x00706F60 @slot 0x18
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x00706F9C @ida "void __userpurge $name(TGoods *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x00706F10
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x00706F38

    procedure Init(ItemType: TItemType; Quantity: Integer); // @addr 0x00706EE8

    function GetDescriptionText: WideString; override; // @addr 0x00707084 @slot 0x24
    function GetBitmapResourceName: WideString; override; // @addr 0x00707128 @slot 0x28
  end;

  TCountableItem = class(TEquipment) // @size 0x68
  public
    StackCount: Integer; // @offset 0x60
    DropFlag: Byte; // @offset 0x64

    function GetDisplayName: WideString; override; // @addr 0x00707278
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x00707334 @ida "void __userpurge $name(TCountableItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x007071A4
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x007071CC

    procedure Init(ConfigName: WideString; Count: Integer; DropFlag: Byte); // @addr 0x007071F4
    function GetUnitSize: Integer; // @addr 0x00707680 @note "Defaults to 1 when UnitSize is not configured."
    function CanMerge(Other: TObject): Boolean; // @addr 0x00707954
    function Merge(Other: TObject): Boolean; // @addr 0x007079AC @note "Leaves Other unchanged."

    function GetDescriptionText: WideString; override; // @addr 0x0070745C
    function GetBitmapResourceName: WideString; override; // @addr 0x00707510
    function Split(Count: Integer): TCountableItem; // @addr 0x00707764 @note "Allocates a new stack and removes up to Count units from Self; preserves the nodes subtype and may create a script wrapper. Self must be nonempty and Count positive."
  end;

  TProtoplasm = class(TCountableItem) // @size 0x68
  public

    function GetDisplayName: WideString; override; // @addr 0x00707A10
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x00707B14 @ida "void __userpurge $name(TProtoplasm *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure Init(Count: Integer; DropFlag: Byte); // @addr 0x007079E4

    function GetDescriptionText: WideString; override; // @addr 0x00707BD4
    function GetBitmapResourceName: WideString; override; // @addr 0x00707C18
  end;

  TEquipmentWithActCode = class(TEquipment) // @size 0x68
  public
    ActionCode: Pointer; // @offset 0x60  Borrowed.
    ActCodeInitialized: Boolean; // @offset 0x64
    DisplayAsArtefact: Boolean; // @offset 0x65

    constructor Create; // @addr 0x00707D8C
    destructor Destroy; override; // @addr 0x00707DCC
  end;

  TUselessItem = class(TEquipmentWithActCode) // @size 0x78
  public
    CustomText: WideString; // @offset 0x68  Script.UselessItemText.
    Data: array[0..2] of Integer; // @offset 0x6C  Script.UselessItemData uses indexes 1..3.

    function GetDisplayName: WideString; override; // @addr 0x007084E8
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x007085D8 @ida "void __userpurge $name(TUselessItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x007082C4
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x00708300
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x007083C8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x0070844C

    constructor Create; // @addr 0x00707DF8
    destructor Destroy; override; // @addr 0x00707E34
    procedure Init(ConfigName: WideString; Series: TDominatorSeries; Seed: Cardinal; ForceArtefactDisplay: Boolean); // @addr 0x00707E90
    procedure CheckIfWeDisplayAsArtefact; // @addr 0x00708BB0
    function GetActionCode: Pointer; // @addr 0x00708C78

    function GetDescriptionText: WideString; override; // @addr 0x007087BC
    function GetBitmapResourceName: WideString; override; // @addr 0x007088A4
    function IsDominatorRemains: Boolean; // @addr 0x00708B74 @note "Owner is Dominator and ConfigBlockName starts with Remains_."
    function GetOnUseCodeText: WideString; // @addr 0x00708BF4
  end;

  TCistern = class(TEquipment) // @size 0x68
  public
    Fuel: Integer; // @offset 0x60
    Capacity: Byte; // @offset 0x64

    function GetDisplayName: WideString; override; // @addr 0x00708F94
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x00708FF0 @ida "void __userpurge $name(TCistern *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x00708D2C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x00708D54
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x00708D7C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00708E8C

    procedure Init(Fuel: Integer; Capacity: Byte; Owner: TOwnerId); // @addr 0x00708CE8

    function GetDescriptionText: WideString; override; // @addr 0x0070911C
    function GetBitmapResourceName: WideString; override; // @addr 0x00709168
  end;

  TSatellite = class(TEquipment) // @size 0x74
  public
    SatelliteTypeId: Byte; // @offset 0x60
    TargetPlanet: TObject; // @offset 0x64
    TrajectoryIndex: Integer; // @offset 0x68
    WearPerTurn: Single; // @offset 0x6C
    WaterExplorationRate: Byte; // @offset 0x70
    LandExplorationRate: Byte; // @offset 0x71
    HillExplorationRate: Byte; // @offset 0x72

    function GetDisplayName: WideString; override; // @addr 0x00709C90
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x00709E0C @ida "void __userpurge $name(TSatellite *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0070973C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x007097BC
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x00709C50
    procedure ClearReferences; override; // @addr 0x00709C7C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x00709818
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00709A50

    procedure InitGenerated(TypeId: Byte; Owner: TOwnerId; Seed: Cardinal); // @addr 0x0070922C @note "Clears deployment state."

    function GetDescriptionText: WideString; override; // @addr 0x0070A33C
    function GetBitmapResourceName: WideString; override; // @addr 0x0070A3F8
    function GetBrokenInUseText: WideString; // @addr 0x0070A044
    function GetIdleInfoText: WideString; // @addr 0x0070A1A0
  end;

  TTreasureMap = class(TEquipment) // @size 0x70
  public
    TargetPlanet: TObject; // @offset 0x60  Saved as an ID until ResolveLoadedReferences.
    SourceShipName: WideString; // @offset 0x64
    PreviewTablePage1: WideString; // @offset 0x68
    PreviewTablePage2: WideString; // @offset 0x6C

    function GetDisplayName: WideString; override; // @addr 0x0070A744
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x0070A7A8 @ida "void __userpurge $name(TTreasureMap *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0070A610
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x0070A66C
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x0070A704
    procedure ClearReferences; override; // @addr 0x0070A730

    procedure Init(Planet: TObject; Victim: Pointer); // @addr 0x0070A4EC
    function GetTargetPlanetName: WideString; // @addr 0x0070AA5C
    function BuildPreviewTable(PageIndex: Integer; Planet: TObject): WideString; // @addr 0x0070ABCC @ida "void __userpurge $name(TTreasureMap *Self@<eax>, int PageIndex@<edx>, TPlanet *Planet@<ecx>, unsigned __int16 **Result@<^0>);" @note "PageIndex is 1 or 2; Planet must be assigned."

    function GetDescriptionText: WideString; override; // @addr 0x0070A91C
    function GetBitmapResourceName: WideString; override; // @addr 0x0070A970
  end;

  TMicroModule = class(TEquipment) // @size 0x60
  public

    function GetDisplayName: WideString; override; // @addr 0x0070B810
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x0070BA94 @ida "void __userpurge $name(TMicroModule *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0070B7D8
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x0070B7E0

    procedure Init(ModuleIndex: Integer); // @addr 0x0070B6A4 @note "ModuleIndex is zero-based and must identify an existing template."
    function GetPlainName: WideString; // @addr 0x0070B960

    function GetDescriptionText: WideString; override; // @addr 0x0070BE9C
    function GetBitmapResourceName: WideString; override; // @addr 0x0070BEA8
    function GetHighlightedName: WideString; // @addr 0x0070D3C8 @note "Template name wrapped in the standard yellow highlight color."
    function CalculateNodeExchangeValue(LowPriorityOfferCost, MediumPriorityOfferCost: Integer): Integer; // @addr 0x0070D034 @note "Node refund at the current ranger center, using priority and docked station ID. Priorities 31..69 are capped by half LowPriorityOfferCost; 70..100 by half MediumPriorityOfferCost. Minimum 5 nodes."
    function CanInstallOn(Item: TEquipment): Boolean; // @addr 0x0070D41C @note "Uses this micromodule item's template and checks slot blockers and equipment compatibility."
  end;

  TArtefact = class(TEquipmentWithActCode) // @size 0x68
  public

    function GetDisplayName: WideString; override; // @addr 0x0070E7E8
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x0070E898 @ida "void __userpurge $name(TArtefact *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x0070DCD0

    constructor Create; // @addr 0x0070DC34
    destructor Destroy; override; // @addr 0x0070DC74
    procedure Init(Owner: TOwnerId; ItemType: TItemType); virtual; // @addr 0x0070DD00 @slot 0x4C
    function GetEffectiveType: TItemType; // @addr 0x0070ECAC @note "Custom artefacts with SharedEffect use CountsAsItemType; otherwise returns ItemType."
    function GetOnUseCodeText: WideString; // @addr 0x0070EAD8 @note "Returns empty when the OnUseCode block is absent."
    function GetActionCode: Pointer; // @addr 0x0070EBB4 @note "Borrowed cached result, possibly nil. Marks initialization before resolving the configuration."
    function GetBoostStatusText: WideString; // @addr 0x00710090 @note "Uses the active equipment screen's ship; empty for broken artefacts or without a supported screen context."

    function GetDescriptionText: WideString; override; // @addr 0x0070EA30
    function GetBitmapResourceName: WideString; override; // @addr 0x0070E6F0
  end;

  TArtefactTransmitter = class(TArtefact) // @size 0x6C
  public
    Power: Integer; // @offset 0x68

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x0070EE88 @ida "void __userpurge $name(TArtefactTransmitter *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0070ED0C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x0070ED28
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x0070ED44
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x0070EDE8

    procedure InitTransmitter(Owner: TOwnerId); // @addr 0x0070ECC8
  end;

  TArtefactTranclucator = class(TArtefact) // @size 0x6C
  public
    Ship: TObject; // @offset 0x68  Owned while stored in the artefact; deployment transfers ownership.

    function GetDisplayName: WideString; override; // @addr 0x0070F36C

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0070F134
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x0070F15C
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x0070F324
    procedure ClearReferences; override; // @addr 0x0070F34C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x0070F1A4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x0070F264

    destructor Destroy; override; // @addr 0x0070EFBC
    procedure InitTranclucator(Owner: TOwnerId; OwnerShip: TObject; ExistingShip: TObject); // @addr 0x0070EFF4 @note "Takes ownership of ExistingShip, or creates a ship when nil."
    function Clone: TItem; override; // @addr 0x0070F1A0 @note "Always returns nil."
  end;

  TArtefactCustom = class(TArtefact) // @size 0x84
  public
    CountsAsItemType: TItemType; // @offset 0x68
    SharedUse: Boolean; // @offset 0x69  Shares the equipped-artefact duplicate check with CountsAsItemType.
    SharedEffect: Boolean; // @offset 0x6A  Shares the effective artefact type with CountsAsItemType.
    Data: array[1..3] of Integer; // @offset 0x6C  Description tokens <Data1> through <Data3>.
    TextData1: WideString; // @offset $78
    TextData2: WideString; // @offset $7C
    TextData3: WideString; // @offset $80

    function GetDisplayName: WideString; override; // @addr 0x0070FF10
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x0070FC94 @ida "void __userpurge $name(TArtefactCustom *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0070F760
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject); override; // @addr 0x0070F818
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x0070F8FC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x0070FAE0

    procedure LoadConfig(ApplyConfiguredWeight: Boolean); // @addr 0x0070F4F4 @note "Uses ConfigBlockName. Reloads NoWear, CountsAs, SharedUse and SharedEffect; preserves Data and TextData."

    function GetDescriptionText: WideString; override; // @addr 0x0070FFD4
  end;

function CreateRandomLootItem(Pool: TItemLootPool; Owner: TOwnerId; Seed: Cardinal): TEquipmentWithActCode; // @addr 0x0070DAF0 @note "Selects across built-in artefacts, custom artefacts and configured useless items. Pool must be nonempty; AnyAvailable is the union of the three eligibility flags."

function ReadSavedMicroModuleIndex(Buffer: TBufEC): Integer; // @addr 0x006F7310 @note "Returns a one-based template index, or 0 if the saved template cannot be resolved."
function MigrateSavedItemType(ItemType: Byte): TItemType; // @addr 0x00710AEC @note "Applies the ordered item-type insertions for save versions before 164, 78, 131, 78 and 127; arithmetic wraps in a byte."

function GetBaseHullSlotCount(Kind: TShipSlotKind; HullType: THullType; Owner: TOwnerId; Ship: Pointer): Integer; // @addr 0x006FD06C
function CalculateGeneratedHullCost(Capacity, Level: Cardinal; Owner: TOwnerId; HullType: THullType): Integer; // @addr 0x006FB514
function CalculateGeneratedFuelCapacity(Weight: Cardinal; Level: Integer): Integer; // @addr 0x006FD98C
function CalculateGeneratedFuelTanksCost(Weight: Cardinal; Level: Integer; Owner: TOwnerId): Integer; // @addr 0x006FD9D4
function CalculateGeneratedEngineCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer; // @addr 0x006FE604
function CalculateGeneratedRadarCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer; // @addr 0x006FF920
function CalculateGeneratedScanerCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer; // @addr 0x0070056C
function CalculateGeneratedRepairRobotCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer; // @addr 0x007011D8
function CalculateGeneratedCargoHookCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer; // @addr 0x00702160
function CalculateGeneratedDefGeneratorCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer; // @addr 0x00703638
function GetGeneratedDefenseDamageFactor(Level: TTechLevel): Double; // @addr 0x007035C4
function DefenseDamageFactorToPercent(Factor: Double): TPercent; // @addr 0x007035E0
function DefensePercentToDamageFactor(Percent: Integer): Double; // @addr 0x00703604

function GetMicroModuleInfoText(ModuleIndex: Integer; ColorTag: WideString): WideString; // @addr 0x0070BAE8 @note "ModuleIndex is zero-based. Expands all bonus tokens in the configured description."

function GetMicroModulePriorityColorTier(ModuleIndex: Integer): Byte; // @addr 0x0070BF34
function GetMicroModuleNameColorTag(ModuleIndex: Integer): WideString; // @addr 0x0070BF64
function GetMicroModuleTextColorTag(ModuleIndex: Integer): WideString; // @addr 0x0070C080
function GetMicroModuleBitmapResourceName(ModuleIndex: Integer): WideString; // @addr 0x0070C120

function CreateConfiguredArtefactByItemType(ItemType: TItemType; Owner: TOwnerId): TArtefact; // @addr 0x0070DA94 @note "Returns nil outside item types 10..41."

function CalculateGeneratedWeaponCost(Info: PWeaponInfo; Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer; // @addr 0x00704CB4

function CreateItemByType(ItemType: TItemType): TItem; // @addr 0x00710298 @note "Constructs the instance without calling its Init routine."
function CreateDefaultItemByType(ItemType: TItemType): TItem; // @addr 0x00710528
function CreateGeneratedEquipment(ItemType: TItemType; Weight, Level: Integer; Owner: TOwnerId): TEquipment; // @addr 0x00710708 @note "Clamps Level to 1..8; custom weapons require CreateGeneratedWeapon."
function CreateGeneratedWeapon(Info: PWeaponInfo; Weight, Level: Integer; Owner: TOwnerId): TWeapon; // @addr 0x007108E4

// Module indices are zero-based; compatibility checks also accept special bonuses.
function CanInstallMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x0070D4D0
function IsBonusCompatibleWithEquipment(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x0070D58C
function IsBonusCompatibleWithHull(ModuleIndex: Integer; Hull: THull): Boolean; // @addr 0x0070D6C0
function IsBonusCompatibleWithWeapon(ModuleIndex: Integer; Weapon: TWeapon): Boolean; // @addr 0x0070D80C
function ApplyMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x0070C244 @note "Does not check compatibility or remove an existing module; -1 or nil returns False."
procedure ApplySpecialMicroModule(ModuleIndex: Integer; Item: TEquipment); // @addr 0x0070CB98
procedure RemoveMicroModule(Item: TEquipment); // @addr 0x0070C74C
procedure RemoveSpecialMicroModule(Item: TEquipment); // @addr 0x0070CE04

function CanCargoHookHandleItem(Item: TItem; Ship: Pointer): Boolean; // @addr 0x006F6F3C

function GetItemTypeBitmapPath(ItemType: TItemType): WideString; // @addr $710940 @ida "void __usercall $name(unsigned __int8 ItemType@<al>, unsigned __int16 **Result@<edx>);"

function GetStackableItemTypeName(ItemType: TItemType): WideString; // @addr $7109BC @ida "void __usercall $name(unsigned __int8 ItemType@<al>, unsigned __int16 **Result@<edx>);" @note "Goods use their market display name; nodes use the generic node name; other types return empty."
function GetStackableItemName(Item: TItem): WideString; // @addr $710A24 @note "Custom countables use their configured name; all other types use GetStackableItemTypeName. Ignores per-instance name overrides."

implementation

// @unit-initialization $807984
// @unit-finalization $710B44

uses aPlanet, aTranclucator, aPirate, SysUtils, SE_Process, GR_Main, aConst, aPlayer, aScript, aMyFunction, Math, aShip, aKling, EC_Str, aAsteroid, aMissile, Globals, fShip2;

{ @routine $6F56F0 TItem_Create }
constructor TItem.Create;
begin
  inherited Create;
  if Galaxy <> nil then
  begin
    Id := Galaxy.NextItemId;
    Inc(Galaxy.NextItemId);
  end;
  NameOverride := '';
end;
{ @end $6F56F0 }

{ @routine $6F5750 TItem_Destroy }
destructor TItem.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) and (ScriptItem <> nil) then
    TScriptItem(ScriptItem).RunActionCode(event_item_destroy, nil, nil, nil, 0);
  Id := 0;
  if ScriptItem <> nil then
  begin
    (ScriptItem as TScriptItem).Item := nil;
    ScriptItem := nil;
  end;
  if GraphObject <> nil then ReleaseSpaceObject(GraphObject);
  inherited Destroy;
end;
{ @end $6F5750 }

{ @routine $6F57E4 TItem_SaveToBuffer }
procedure TItem.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddDWord(Id);
  Buffer.AddAnsiChar(AnsiChar(ItemType));
  Buffer.AddSingle(Position.X);
  Buffer.AddSingle(Position.Y);
  Buffer.AddIntegerValue(Weight);
  Buffer.AddAnsiChar(AnsiChar(OwnerId));
  Buffer.AddDWord(Cost);
  Buffer.AddIntegerValue(DestroyFlag);
  if NameOverride = '' then Buffer.AddBoolean(False)
  else begin Buffer.AddBoolean(True); Buffer.AddWideStringZ(NameOverride); end;
  Buffer.AddAnsiChar(AnsiChar(NoDropFlag));
end;
{ @end $6F57E4 }

{ @routine $6F5874 TItem_LoadFromBuffer }
procedure TItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  Id := Buffer.GetUInt32;
  if TGalaxy(Galaxy).NextItemId <= Id then TGalaxy(Galaxy).NextItemId := Id + 1;
  ItemType := MigrateSavedItemType(Buffer.GetByte);
  Position.X := Buffer.GetSingle;
  Position.Y := Buffer.GetSingle;
  Weight := Buffer.GetInt32;
  OwnerId := TOwnerId(Buffer.GetByte);
  Cost := Buffer.GetUInt32;
  DestroyFlag := Buffer.GetInt32;
  if Buffer.GetBoolean then NameOverride := Buffer.ReadWideString;
  NoDropFlag := Buffer.GetByte;
end;
{ @end $6F5874 }

{ @routine $6F594C TItem_SaveToBlock }
procedure TItem.SaveToBlock(Block: TBlockParEC);
begin
  Block.AddParam(DecodeTextW('IQNaaWmee'), GetDisplayName); // 'IName'
  Block.AddParam(DecodeTextW('InToyAple'), ItemTypeNames[ItemType]); // 'IType'
  Block.AddParam(DecodeTextW('OpwRn3ewr'), OwnerInfo[OwnerId].InternalName); // 'Owner'
  Block.AddParam(DecodeTextW('SaiRzoe'), IntToStr(Weight)); // 'Size'
  Block.AddParam(DecodeTextW('CfoTsat'), IntToStr(Cost)); // 'Cost'
  Block.AddParam(DecodeTextW('NeonDarlokpl'), IntToStr(NoDropFlag)); // 'NoDrop'
  if ScriptItem <> nil then
    Block.AddParam(DecodeTextW('IsSacaraiOpit'), TScriptItem(ScriptItem).Script.ScriptFileName); // 'IScript'
end;
{ @end $6F594C }

{ @routine $6F5BB8 TItem_LoadFromBlock }
procedure TItem.LoadFromBlock(Block: TBlockParEC);
var
  I: Integer;
  Text: WideString;
begin
  Text := Block.GetParam(DecodeTextW('OpwRn3ewr')); // 'Owner'
  for I := 0 to 7 do
    if Text = OwnerInfo[TOwnerId(I)].InternalName then OwnerId := TOwnerId(I);
  Weight := StrToInt(Block.GetParam(DecodeTextW('SaiRzoe'))); // 'Size'
  Cost := StrToInt(Block.GetParam(DecodeTextW('CfoTsat'))); // 'Cost'
  Text := LowerCase(Block.GetParam(DecodeTextW('NeonDarlokpl'))); // 'NoDrop'
  if Text = 'false' then NoDropFlag := 0
  else if Text = 'true' then NoDropFlag := 1
  else NoDropFlag := StrToInt(Text);
  if Self is TGoods then (Self as TGoods).Quantity := Weight;
  if Self is TCountableItem then (Self as TCountableItem).StackCount := Weight div (Self as TCountableItem).GetUnitSize;
  if (ItemType = artefact_tranclucator) and ((Self as TArtefactTranclucator).Ship <> nil) then
    TTranclucator((Self as TArtefactTranclucator).Ship).ArtefactSize := Weight;
end;
{ @end $6F5BB8 }

{ @routine $6F5E90 TItem_ResolveLoadedReferences }
procedure TItem.ResolveLoadedReferences(Galaxy: TGalaxy);
begin

end;
{ @end $6F5E90 }

{ @routine $6F5E94 TItem_ClearReferences }
procedure TItem.ClearReferences;
begin

end;
{ @end $6F5E94 }

{ @routine $6F5E98 TItem_GetSmallInfoText }
function TItem.GetSmallInfoText: WideString;
begin
  Result := LookupLocalizedTextByKey('Items.SmallInfo');
end;
{ @end $6F5E98 }

{ @routine $6F5ED0 TItem_CalculateResaleValue }
function TItem.CalculateResaleValue(TradingSkill: Byte): Integer;
begin
  if Self is TEquipment then
    Result := Max(1, Round((Cost - (Self as TEquipment).CalculateRepairCost) * 0.01 * PilotSkillEffects[TradingSkill, skill_trading]))
  else Result := Round(Cost * 0.01 * PilotSkillEffects[TradingSkill, skill_trading]);
end;
{ @end $6F5ED0 }

{ @routine $6F5FB4 TItem_GetConditionAdjustedCost }
function TItem.GetConditionAdjustedCost: Integer;
begin
  if Self is TEquipment then Result := Max(1, Cost - (Self as TEquipment).CalculateRepairCost)
  else Result := Cost;
end;
{ @end $6F5FB4 }

{ @routine $6F5FF4 TItem_GetCategoryConfigName }
function TItem.GetCategoryConfigName: WideString;
begin
  if ItemType in WeaponItemTypes then Result := 'Weapon'
  else if ItemType in [artefact_hull..artefact_extra_missiles] then Result := 'Artefact'
  else Result := ItemTypeNames[ItemType];
end;
{ @end $6F5FF4 }

{ @routine $6F6070 TItem_GetShortName }
function TItem.GetShortName: WideString;
begin
  Result := '';
end;
{ @end $6F6070 }

{ @routine $6F607C TItem_GetInfoText }
function TItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := '';
end;
{ @end $6F607C }

{ @routine $6F6164 TItem_GetGraphObject }
function TItem.GetGraphObject: TContainerSE;

  // @nested $6F60B0 CreateContainer
  procedure CreateContainer(GraphKey: WideString); // @addr 0x006F60B0 @note "Captures the item at ParentFrame-4; caller removes ParentFrame."
  begin
    RetainSpaceObject(GraphObject, CreateSpaceObjectByName('Container', 'Item.' + GraphKey, Classes.Point(0, 0)));
  end;

begin
  if GraphObject = nil then
  begin
    if Self is TMicroModule then
    begin
      if (MicroModuleTemplates[(Self as TMicroModule).MicroModuleIndex - 1].KindGraph <> '') and
        (GameDataConfig.GetBlock('SE').GetBlock('Item').FindBlock('mm_' + MicroModuleTemplates[(Self as TMicroModule).MicroModuleIndex - 1].KindGraph) <> nil) then
        CreateContainer('mm_' + MicroModuleTemplates[(Self as TMicroModule).MicroModuleIndex - 1].KindGraph)
      else CreateContainer('mm_' + IntToStr(GetMicroModulePriorityColorTier((Self as TMicroModule).MicroModuleIndex - 1)));
    end
    else if ItemType = artefact_bomb then CreateContainer('Bomb')
    else if (Self is TUselessItem) and (GameDataConfig.GetBlockByPath('SE.Item').CountBlocks(TUselessItem(Self).ConfigBlockName) > 0) then
      CreateContainer(TUselessItem(Self).ConfigBlockName)
    else if Self is TCistern then CreateContainer('Cistern')
    else if (Self is TGoods) and (Self as TGoods).NaturalFlag then
    begin
      if Weight <= 29 then CreateContainer('m0_' + IntToStr(SeededRandomIntRange(0, 2, Id * 25457)))
      else if Weight <= 59 then CreateContainer('m1_' + IntToStr(SeededRandomIntRange(0, 2, Id * 25457)))
      else CreateContainer('m2_' + IntToStr(SeededRandomIntRange(0, 2, Id * 25457)));
    end
    else if (Self is TProtoplasm) and ((Self as TProtoplasm).DropFlag <> 0) then
    begin
      if Weight <= 29 then CreateContainer('n0_' + IntToStr(Id mod 5))
      else if Weight <= 59 then CreateContainer('n1_' + IntToStr(Id mod 5))
      else if Weight <= 99 then CreateContainer('n2_' + IntToStr(Id mod 5))
      else CreateContainer('n3_' + IntToStr(Id mod 5));
    end
    else if (Self is TCountableItem) and ((Self as TCountableItem).DropFlag <> 0) then
    begin
      if Weight <= 29 then CreateContainer((Self as TCountableItem).ConfigBlockName + '0_' + WideString(IntToStr(Id mod 5)))
      else if Weight <= 59 then CreateContainer((Self as TCountableItem).ConfigBlockName + '1_' + WideString(IntToStr(Id mod 5)))
      else if Weight <= 99 then CreateContainer((Self as TCountableItem).ConfigBlockName + '2_' + WideString(IntToStr(Id mod 5)))
      else CreateContainer((Self as TCountableItem).ConfigBlockName + '3_' + WideString(IntToStr(Id mod 5)));
    end
    else if (Self is TEquipment) and ((Self as TEquipment).CustomFaction <> '') then
    begin
      if Weight <= 29 then CreateContainer((Self as TEquipment).CustomFaction + '0')
      else if Weight <= 59 then CreateContainer((Self as TEquipment).CustomFaction + '1')
      else if Weight <= 99 then CreateContainer((Self as TEquipment).CustomFaction + '2')
      else CreateContainer((Self as TEquipment).CustomFaction + '3');
    end
    else if (Self is TEquipment) and (OwnerId = owner_dominator) then
    begin
      if (Self as TEquipment).DominatorSeries = series_blazer then
      begin
        if Weight <= 29 then CreateContainer('db0')
        else if Weight <= 59 then CreateContainer('db1')
        else if Weight <= 99 then CreateContainer('db2')
        else CreateContainer('db3');
      end
      else if (Self as TEquipment).DominatorSeries = series_keller then
      begin
        if Weight <= 29 then CreateContainer('dk0')
        else if Weight <= 59 then CreateContainer('dk1')
        else if Weight <= 99 then CreateContainer('dk2')
        else CreateContainer('dk3');
      end
      else if (Self as TEquipment).DominatorSeries = series_terron then
      begin
        if Weight <= 29 then CreateContainer('dt0')
        else if Weight <= 59 then CreateContainer('dt1')
        else if Weight <= 99 then CreateContainer('dt2')
        else CreateContainer('dt3');
      end
      else RaiseWideMessage('Item graph');
    end
    else
    begin
      if Weight <= 29 then CreateContainer('c0_' + IntToStr(SeededRandomIntRange(0, 7, Id * 25457)))
      else if Weight <= 59 then CreateContainer('c1_' + IntToStr(SeededRandomIntRange(0, 7, Id * 25457)))
      else if Weight <= 99 then CreateContainer('c2_' + IntToStr(SeededRandomIntRange(0, 7, Id * 25457)))
      else CreateContainer('c3_' + IntToStr(SeededRandomIntRange(0, 7, Id * 25457)));
    end;
    GraphObject.SetPosition(Position);
  end;
  Result := GraphObject;
end;
{ @end $6F6164 }

{ @routine $6F6F2C TItem_ReleaseGraphObject }
procedure TItem.ReleaseGraphObject;
begin
  if GraphObject <> nil then ReleaseSpaceObject(GraphObject);
end;
{ @end $6F6F2C }

{ @routine $6F6F3C CanCargoHookHandleItem }
function CanCargoHookHandleItem(Item: TItem; Ship: Pointer): Boolean;
var Owner: TShip;
begin
  Owner := TShip(Ship);
  Result := False;
  if not Owner.IsEquipmentUsable(Owner.GetCargoHook) then Exit;
  if Owner.CalculateCargoHookPower(Owner.GetCargoHook) < Item.Weight then Exit;
  if (Item is TUselessItem) and (TUselessItem(Item).ConfigBlockName = 'ExampleAsteroid') then Exit;
  if (GetPlayer <> Owner) and
    (((Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '')) or
     (Item is TSatellite) or (Item.DestroyFlag > 0)) then Exit;
  Result := True;
end;
{ @end $6F6F3C }

{ @routine $6F6FF0 TItem_GetOwnerConfigName }
function TItem.GetOwnerConfigName: WideString;
begin
  if Self is TGoods then Result := OwnerInfo[owner_uninhabited].InternalName
  else if TEquipment(Self).CustomFaction <> '' then Result := TEquipment(Self).CustomFaction
  else if (OwnerId = owner_dominator) and (Self is TEquipment) then Result := DominatorSeriesNames[TEquipment(Self).DominatorSeries]
  else if (Self is THull) and (Self as THull).PirateBuilt then Result := OwnerInfo[owner_pirate].InternalName + OwnerToSys(OwnerId)
  else Result := OwnerInfo[OwnerId].InternalName;
end;
{ @end $6F6FF0 }

{ @routine $6F70FC TEquipment_Create }
constructor TEquipment.Create;
begin
  inherited Create;
  ExtraSpecials := nil;
  EquippedFlag := 0;
end;
{ @end $6F70FC }

{ @routine $6F713C TEquipment_Destroy }
destructor TEquipment.Destroy;
var I: Integer; Entry: PExtraSpecial;
begin
  if ExtraSpecials <> nil then
  begin
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Dispose(Entry);
    end;
    ExtraSpecials.Free;
  end;
  ExtraSpecials := nil;
  inherited Destroy;
end;
{ @end $6F713C }

{ @routine $6F719C TEquipment_SaveToBuffer }
procedure TEquipment.SaveToBuffer(Buffer: TBufEC);
var Index, ModuleIndex: Integer; Entry: PExtraSpecial;
begin
  inherited SaveToBuffer(Buffer);
  if CustomFaction = '' then Buffer.AddBoolean(False)
  else begin Buffer.AddBoolean(True); Buffer.AddWideStringZ(CustomFaction); end;
  if ConfigBlockName = '' then Buffer.AddBoolean(False)
  else begin Buffer.AddBoolean(True); Buffer.AddWideStringZ(ConfigBlockName); end;
  Buffer.AddBoolean(Boolean(EquippedFlag));
  Buffer.AddSingle(ConditionPercent);
  Buffer.AddBoolean(Boolean(BrokenFlag));
  Buffer.AddAnsiChar(AnsiChar(AssignedSlotData));
  Buffer.AddIntegerValue(MicroModuleIndex);
  if MicroModuleIndex > 0 then Buffer.AddDWord(MicroModuleTemplates[MicroModuleIndex - 1].ConfigNameHash);
  Buffer.AddIntegerValue(SpecialModuleIndex);
  if SpecialModuleIndex > 0 then Buffer.AddDWord(MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNameHash);
  if ExtraSpecials = nil then Buffer.AddIntegerValue(0)
  else
  begin
    Buffer.AddIntegerValue(ExtraSpecials.Count);
    for Index := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[Index];
      ModuleIndex := Entry.ModuleIndexPlusOne;
      Buffer.AddIntegerValue(ModuleIndex);
      if ModuleIndex > 0 then Buffer.AddDWord(MicroModuleTemplates[ModuleIndex - 1].ConfigNameHash);
      Buffer.AddIntegerValue(Entry.Count);
    end;
  end;
  Buffer.AddAnsiChar(AnsiChar(DominatorSeries));
end;
{ @end $6F719C }

{ @routine $6F7310 ReadSavedMicroModuleIndex }
function ReadSavedMicroModuleIndex(Buffer: TBufEC): Integer;
var
  I: Integer;
  NameHash: Cardinal;
begin
  Result := Buffer.GetInt32;
  if Result > 0 then
  begin
    NameHash := Buffer.GetUInt32;
    if (High(MicroModuleTemplates) + 1 < Result) or
      (MicroModuleTemplates[Result - 1].ConfigNameHash <> NameHash) then
    begin
      Result := 0;
      for I := 0 to High(MicroModuleTemplates) do
        if MicroModuleTemplates[I].ConfigNameHash = NameHash then
        begin
          Result := I + 1;
          Break;
        end;
    end;
  end;
end;
{ @end $6F7310 }

{ @routine $6F73C8 TEquipment_LoadFromBuffer }
procedure TEquipment.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
var ConfigNumber, Count, Index, ExistingIndex, ModuleIndex: Integer; Entry: PExtraSpecial;

  // @nested $6F7388 FindLegacyMicroModuleIndex
  function FindLegacyMicroModuleIndex(ConfigNumber: Integer): Integer; // @addr 0x006F7388 @note "Returns a one-based template index, or 0 if absent."
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to High(MicroModuleTemplates) do
      begin
        if MicroModuleTemplates[I].ConfigNumber <> ConfigNumber then Continue;
        Result := I + 1;
        Break;
      end;
  end;

begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion >= 152 then
    if Buffer.GetBoolean then CustomFaction := Buffer.ReadWideString;
  if LoadedSaveVersion >= 86 then
    if Buffer.GetBoolean then ConfigBlockName := Buffer.ReadWideString;
  EquippedFlag := Byte(Buffer.GetBoolean);
  ConditionPercent := Buffer.GetSingle;
  BrokenFlag := Byte(Buffer.GetBoolean);
  AssignedSlotData := Buffer.GetByte;
  if LoadedSaveVersion >= 157 then
  begin
    MicroModuleIndex := ReadSavedMicroModuleIndex(Buffer);
    SpecialModuleIndex := ReadSavedMicroModuleIndex(Buffer);
  end
  else if LoadedSaveVersion >= 67 then
  begin
    MicroModuleIndex := Buffer.GetInt32;
    SpecialModuleIndex := Buffer.GetInt32;
    if LoadedSaveVersion >= 98 then
    begin
      if MicroModuleIndex > 0 then
      begin
        ConfigNumber := Buffer.GetInt32;
        if (MicroModuleIndex > High(MicroModuleTemplates) + 1) or
          (MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber <> ConfigNumber) then
          MicroModuleIndex := FindLegacyMicroModuleIndex(ConfigNumber);
      end;
      if SpecialModuleIndex > 0 then
      begin
        ConfigNumber := Buffer.GetInt32;
        if (SpecialModuleIndex > High(MicroModuleTemplates) + 1) or
          (MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber <> ConfigNumber) then
          SpecialModuleIndex := FindLegacyMicroModuleIndex(ConfigNumber);
      end;
    end;
  end
  else
  begin
    MicroModuleIndex := Buffer.GetByte;
    SpecialModuleIndex := Buffer.GetByte;
  end;
  if LoadedSaveVersion < 98 then
  begin
    if MicroModuleIndex <> 0 then
    begin
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 24 then Inc(MicroModuleIndex);
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 124 then Inc(MicroModuleIndex);
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 219 then Inc(MicroModuleIndex);
    end;
    if SpecialModuleIndex <> 0 then
    begin
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 24 then Inc(SpecialModuleIndex);
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 124 then Inc(SpecialModuleIndex);
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 219 then Inc(SpecialModuleIndex);
    end;
  end;
  if LoadedSaveVersion >= 116 then
  begin
    Count := Buffer.GetInt32;
    if Count > 0 then
    begin
      ExtraSpecials := TList.Create;
      for Index := 0 to Count - 1 do
      begin
        if LoadedSaveVersion >= 157 then ModuleIndex := ReadSavedMicroModuleIndex(Buffer)
        else
        begin
          ModuleIndex := Buffer.GetInt32;
          ConfigNumber := Buffer.GetInt32;
          if (ModuleIndex > High(MicroModuleTemplates) + 1) or
            (MicroModuleTemplates[ModuleIndex - 1].ConfigNumber <> ConfigNumber) then
            ModuleIndex := FindLegacyMicroModuleIndex(ConfigNumber);
        end;
        if ModuleIndex = 0 then ModuleIndex := 1;
        if LoadedSaveVersion >= 140 then
        begin
          New(Entry);
          Entry.ModuleIndexPlusOne := ModuleIndex;
          Entry.Count := Buffer.GetInt32;
          ExtraSpecials.Add(Entry);
        end
        else
        begin
          Entry := nil;
          for ExistingIndex := 0 to ExtraSpecials.Count - 1 do
            if PExtraSpecial(ExtraSpecials[ExistingIndex]).ModuleIndexPlusOne = ModuleIndex then
            begin
              Entry := ExtraSpecials[ExistingIndex];
              Inc(Entry.Count);
              Break;
            end;
          if Entry = nil then
          begin
            New(Entry);
            Entry.ModuleIndexPlusOne := ModuleIndex;
            Entry.Count := 1;
            ExtraSpecials.Add(Entry);
          end;
        end;
      end;
    end;
  end;
  DominatorSeries := TDominatorSeries(Buffer.GetByte);
end;
{ @end $6F73C8 }

{ @routine $6F779C TEquipment_Clone }
function TEquipment.Clone: TItem;
var Buffer: TBufEC; NewId: Cardinal;
begin
  NewId := Galaxy.NextItemId;
  Result := CreateItemByType(ItemType);
  Buffer := TBufEC.Create;
  SaveToBuffer(Buffer);
  Buffer.SetPosition(0);
  LoadedSaveVersion := CurrentSaveVersion;
  Result.LoadFromBuffer(Buffer, Galaxy);
  Result.ResolveLoadedReferences(Galaxy);
  Result.Id := NewId;
  Galaxy.NextItemId := NewId + 1;
  Buffer.Free;
end;
{ @end $6F779C }

{ @routine $6F782C TEquipment_SaveToBlock }
procedure TEquipment.SaveToBlock(Block: TBlockParEC);
var
  I: Integer;
  Entry: PExtraSpecial;
  Text, ModuleName: WideString;
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('DyuRrdawbRiblNijtSyp'), FloatToStr(ConditionPercent)); // 'Durability'
  Block.AddParam(DecodeTextW('BorYorkNeln'), BoolToWideString(Boolean(BrokenFlag))); // 'Broken'
  Block.AddParam(DecodeTextW('BrognWulso'), IntToStr(MicroModuleIndex)); // 'Bonus'
  if MicroModuleIndex <> 0 then
    Block.AddParam(DecodeTextW('IQBaodn4ursTNgatm2e'), MicroModuleTemplates[MicroModuleIndex - 1].Name); // 'IBonusName'
  Block.AddParam(DecodeTextW('SrpeeIcjigaEl4'), IntToStr(SpecialModuleIndex)); // 'Special'
  if SpecialModuleIndex <> 0 then
    Block.AddParam(DecodeTextW('IaSopRefcGihajl6NtaEm3ew'), MicroModuleTemplates[SpecialModuleIndex - 1].Name); // 'ISpecialName'
  if ExtraSpecials <> nil then
  begin
    Text := '';
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      if Text <> '' then Text := Text + ', ';
      if (Entry.ModuleIndexPlusOne <= 0) or (Entry.ModuleIndexPlusOne > MicroModuleTemplateCount) then
        ModuleName := '<' + IntToWideString(Entry.ModuleIndexPlusOne - 1) + '>'
      else
      begin
        ModuleName := MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].Name;
        if ModuleName = '' then ModuleName := '[' + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].ConfigName + ']';
      end;
      if Entry.Count <> 1 then Text := Text + IntToWideString(Entry.Count) + 'x' + ModuleName
      else Text := Text + ModuleName;
    end;
    if Text <> '' then
      Block.AddParam(DecodeTextW('IaEoxRtfrGahSjp6etcEi3awlhs4'), Text); // 'IExtraSpecials'
  end;
  Block.AddParam(DecodeTextW('D9o5meScewr3iwegs4'), DominatorSeriesNames[DominatorSeries]); // 'DomSeries'
end;
{ @end $6F782C }

{ @routine $6F7CE4 TEquipment_LoadFromBlock }
procedure TEquipment.LoadFromBlock(Block: TBlockParEC);
var
  SeriesIndex: Integer;
  Text: WideString;
begin
  inherited LoadFromBlock(Block);
  ConditionPercent := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('DyuRrdawbRiblNijtSyp'))); // 'Durability'
  BrokenFlag := Byte(LowerCase(Block.GetParam(DecodeTextW('BorYorkNeln'))) = 'true'); // 'Broken'
  MicroModuleIndex := StrToInt(Block.GetParam(DecodeTextW('BrognWulso'))); // 'Bonus'
  SpecialModuleIndex := StrToInt(Block.GetParam(DecodeTextW('SrpeeIcjigaEl4'))); // 'Special'
  Text := Block.GetParam(DecodeTextW('D9o5meScewr3iwegs4')); // 'DomSeries'
  for SeriesIndex := Ord(Low(TDominatorSeries)) to Ord(High(TDominatorSeries)) do
    if Text = DominatorSeriesNames[TDominatorSeries(SeriesIndex)] then DominatorSeries := TDominatorSeries(SeriesIndex);
end;
{ @end $6F7CE4 }

{ @routine $6F7F4C TEquipment_Equip }
procedure TEquipment.Equip;
begin
  EquippedFlag := 1;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then Exit;
  if ScriptItem <> nil then TScriptItem(ScriptItem).RunActionCode(event_item_equip, nil, nil, nil, 0);
  if Self is TEquipmentWithActCode then RunItemConfigActionCode(Self, event_item_equip, nil, nil, nil, 0);
end;
{ @end $6F7F4C }

{ @routine $6F7FB0 TEquipment_Unequip }
procedure TEquipment.Unequip;
begin
  EquippedFlag := 0;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then Exit;
  if ScriptItem <> nil then TScriptItem(ScriptItem).RunActionCode(event_item_unequip, nil, nil, nil, 0);
  if Self is TEquipmentWithActCode then RunItemConfigActionCode(Self, event_item_unequip, nil, nil, nil, 0);
end;
{ @end $6F7FB0 }

{ @routine $6F8014 TEquipment_Repair }
procedure TEquipment.Repair;
begin
  ConditionPercent := 100;
  BrokenFlag := 0;
end;
{ @end $6F8014 }

{ @routine $6F8028 TEquipment_NeedsRepair }
function TEquipment.NeedsRepair: Boolean;
const
  RepairableTypes = [Low(TItemType)..High(TItemType)] - [item_food..item_narcotics, item_custom_artefact_no_wear, artefact_transmitter..artefact_tranclucator, artefact_black_hole..artefact_artefactor, item_hull, item_nodes..item_fuel_container, item_treasure_map..item_stackable_misc];
begin
  if ItemType = item_hull then
    Result := (Self as THull).HullPoints < (Self as THull).Weight
  else
    Result := (ItemType in RepairableTypes) and (ConditionPercent < 90);
end;
{ @end $6F8028 }

{ @routine $6F8098 TEquipment_CalculateRepairCost }
function TEquipment.CalculateRepairCost: Integer;
var DamagePercent: Double;
begin
  if Self is TCountableItem then
  begin
    Result := 0;
    Exit;
  end;
  if ItemType = item_hull then
  begin
    Result := 0;
    if (Self as THull).Weight - (Self as THull).HullPoints <> 0 then
    begin
      DamagePercent := 100 / (Self as THull).Weight * ((Self as THull).Weight - (Self as THull).HullPoints);
      Result := RoundAndTruncateToTens((Cost div 40) / 100 * DamagePercent + 10);
    end;
  end
  else if ItemType in [item_fuel_tanks..item_custom_weapon, item_satellite] then
  begin
    if ConditionPercent = 100 then Result := 0
    else Result := RoundAndTruncateToTens((100 - Round(ConditionPercent)) * ((Cost div 7) / 100) + Cost div 20 + 10);
    if BrokenFlag <> 0 then Result := Round(Result * 1.3);
  end
  else if ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles] then
  begin
    if ConditionPercent = 100 then Result := 0
    else Result := RoundAndTruncateToTens((100 - Round(ConditionPercent)) * ((Cost div 5) / 100) + Cost div 10 + 10);
    if BrokenFlag <> 0 then Result := Round(Result * 1.3);
    Result := Result * 2;
  end
  else Result := 0;
end;
{ @end $6F8098 }

{ @routine $6F830C TEquipment_GetConditionText }
function TEquipment.GetConditionText(PrefixNewLine: Boolean): WideString;
const SupportedTypes = [Low(TItemType)..High(TItemType)] - [item_food..item_narcotics, item_custom_artefact_no_wear, artefact_transmitter..artefact_tranclucator, artefact_black_hole..artefact_artefactor, item_hull, item_nodes..item_fuel_container, item_treasure_map..item_stackable_misc];
var Prefix: WideString;
begin
  if not (ItemType in SupportedTypes) then
  begin
    Result := '';
    Exit;
  end;
  if PrefixNewLine then Prefix := #13#10 else Prefix := '';
  if (GetPlayer <> nil) and not GetPlayer.CanUseEquipmentTech(Self) then
  begin
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeUsed'), RedColorTag);
    Exit;
  end;
  if (GetPlayer <> nil) and not GetPlayer.CanRepairEquipmentTech(Self) and (BrokenFlag <> 0) and
    not (ItemType in [item_fuel_tanks..item_engine]) then
  begin
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeUsed'), RedColorTag);
    Exit;
  end;
  if BrokenFlag <> 0 then
  begin
    if ItemType in UtilityEquipmentTypes then
      Result := WrapTextInColor(Prefix + LocalizedText('Items.' + ItemTypeNames[ItemType] + '.Broken'), RedColorTag)
    else if ItemType in WeaponItemTypes then
      Result := WrapTextInColor(Prefix + LocalizedText('Items.Weapon.Broken'), RedColorTag)
    else if ItemType in [item_custom_artefact..item_custom_artefact_no_wear] then
      Result := WrapTextInColor(Prefix + LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Broken'), RedColorTag)
    else if ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles] then
      Result := WrapTextInColor(Prefix + LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.Broken'), RedColorTag)
    else if ItemType = item_satellite then
      Result := WrapTextInColor(Prefix + LocalizedText('Items.Satellite.Broken'), RedColorTag)
    else Result := '';
  end
  else if Self is TArtefact then
  begin
    // Native retains this transmitter branch despite the initial supported-type set.
    if (ItemType = artefact_transmitter) and ((Self as TArtefactTransmitter).Power < MinTransmitterPower) then
      Result := WrapTextInColor(Prefix + LocalizedText('Artefacts.ArtTransmitter.Broken'), GoldColorTag)
    else Result := '';
  end
  else if ConditionPercent < 20 then
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.SmallDuration'), GoldColorTag)
  else if ConditionPercent < 50 then
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.AverageDuration'), GrayColorTag)
  else Result := '';
  if (GetPlayer <> nil) and not GetPlayer.CanRepairEquipmentTech(Self) then
  begin
    if not PrefixNewLine then Result := '';
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeRepaired'), GrayColorTag) + Result;
  end;
end;
{ @end $6F830C }

{ @routine $6F89E0 TEquipment_GetBrokenInBattleText }
function TEquipment.GetBrokenInBattleText: WideString;
begin
  if ItemType in UtilityEquipmentTypes then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.BrokenInBattle')
  else if ItemType in WeaponItemTypes then
    Result := FormatText1(LocalizedText('Items.Weapon.BrokenInBattle'), TextHighlightColorTag, '<Name>', GetDisplayName)
  else if ItemType in [item_custom_artefact..item_custom_artefact_no_wear] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenInBattle')
  else if ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.BrokenInBattle')
  else Result := '';
end;
{ @end $6F89E0 }

{ @routine $6F8C28 TEquipment_GetBrokenInUseText }
function TEquipment.GetBrokenInUseText: WideString;
begin
  if ItemType in UtilityEquipmentTypes then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.BrokenInUse')
  else if ItemType in WeaponItemTypes then
    Result := FormatText1(LocalizedText('Items.Weapon.BrokenInUse'), TextHighlightColorTag, '<Name>', GetDisplayName)
  else if ItemType in [item_custom_artefact..item_custom_artefact_no_wear] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenInUse')
  else if ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.BrokenInUse')
  else Result := '';
end;
{ @end $6F8C28 }

{ @routine $6F8E68 TEquipment_GetBrokenByForceText }
function TEquipment.GetBrokenByForceText: WideString;
begin
  Result := '';
  if ItemType in UtilityEquipmentTypes then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.BrokenByForce')
  else if ItemType in WeaponItemTypes then
    Result := FormatText1(LocalizedText('Items.Weapon.BrokenByForce'), TextHighlightColorTag, '<Name>', GetDisplayName)
  else if ItemType in [item_custom_artefact..item_custom_artefact_no_wear] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenByForce')
  else if ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.BrokenByForce')
  else Exit;
  if Result = '' then Result := GetBrokenInUseText;
end;
{ @end $6F8E68 }

{ @routine $6F90C0 TEquipment_GetLevel }
function TEquipment.GetLevel: Integer;
begin
  case ItemType of
    item_hull: Result := (Self as THull).TechLevel;
    item_fuel_tanks: Result := (Self as TFuelTanks).TechLevel;
    item_engine: Result := (Self as TEngine).TechLevel;
    item_radar: Result := (Self as TRadar).TechLevel;
    item_scanner: Result := (Self as TScaner).TechLevel;
    item_repair_robot: Result := (Self as TRepairRobot).TechLevel;
    item_cargo_hook: Result := (Self as TCargoHook).TechLevel;
    item_defense_generator: Result := (Self as TDefGenerator).TechLevel;
  else
    if ItemType in WeaponItemTypes then Result := (Self as TWeapon).TechLevel
    else Result := 0;
  end;
end;
{ @end $6F90C0 }

var
  EquipmentLevelLetters: array[1..8] of WideString = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'); // @addr $80FF58 Native managed-string defaults.
var
  TreasureMapColumnPositions: array[1..2, 0..3] of Integer = ((20, 40, 280, 380), (20, 40, 380, 490)); // @addr $80FF78
  TreasureMapRuleLengths: array[1..2] of Integer = (76, 98); // @addr $80FF98

{ @routine $6F91F4 TEquipment_GetLevelLetter }
function TEquipment.GetLevelLetter: WideString;
var Level: Integer;
begin
  Level := GetLevel;
  Result := '';
  if (Level >= 1) and (Level <= 8) then Result := EquipmentLevelLetters[Level];
end;
{ @end $6F91F4 }

{ @routine $6F9224 TEquipment_GetDescriptionText }
function TEquipment.GetDescriptionText: WideString;
begin
  if (ItemType in UtilityEquipmentTypes) and (OwnerId = owner_dominator) then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.KlingDescription.' + IntToStr(GetLevel))
  else Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.Description.' + IntToStr(GetLevel));
end;
{ @end $6F9224 }

{ @routine $6F9394 TEquipment_GetDisplayName }
function TEquipment.GetDisplayName: WideString;
var TypeName: WideString;
begin
  Result := '';
  if NameOverride <> '' then Result := NameOverride
  else if SpecialModuleIndex <> 0 then
    Result := WrapTextInColor(GetSpecialModuleName, GetMicroModuleTextColorTag(SpecialModuleIndex - 1))
  else if CustomFaction <> '' then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.' + CustomFaction + 'Name');
  if Result = '' then
  begin
    if OwnerId <> owner_dominator then
    begin
      TypeName := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.Type.' + IntToStr(GetLevel));
      Result := ReplaceColoredToken(LocalizedText('Items.' + ItemTypeNames[ItemType] + '.Name'), '<Type>', TypeName, '');
    end
    else Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.KlingName');
  end;
  if HasMicroModule then
    Result := Result + ' ' + WrapTextInColor(GetMicroModuleQuotedName, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;
{ @end $6F9394 }

{ @routine $6F962C TEquipment_GetShortName }
function TEquipment.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if OwnerId <> owner_dominator then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.ShortName')
  else Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.KlingName');
end;
{ @end $6F962C }

{ @routine $6F9738 TEquipment_ImproveAtScientificBase }
procedure TEquipment.ImproveAtScientificBase;
begin
  DetailImprovement := (Id mod 2) + 1;
  case (Id div 3) mod 6 of
    0: Improve(upgrade_major);
    1..2: Improve(upgrade_medium);
  else Improve(upgrade_minor);
  end;
end;
{ @end $6F9738 }

{ @routine $6F9788 TEquipment_HasMicroModule }
function TEquipment.HasMicroModule: Boolean;
begin
  Result := MicroModuleIndex <> 0;
end;
{ @end $6F9788 }

{ @routine $6F9790 TEquipment_GetMicroModuleQuotedName }
function TEquipment.GetMicroModuleQuotedName: WideString;
begin
  if HasMicroModule then
  begin
    if FindTextOffsetW(MicroModuleTemplates[MicroModuleIndex - 1].Name, '"') >= 0 then
      Result := MicroModuleTemplates[MicroModuleIndex - 1].Name
    else Result := '"' + MicroModuleTemplates[MicroModuleIndex - 1].Name + '"';
  end
  else Result := '';
end;
{ @end $6F9790 }

{ @routine $6F9820 TEquipment_GetSpecialModuleName }
function TEquipment.GetSpecialModuleName: WideString;
begin
  if SpecialModuleIndex <> 0 then Result := MicroModuleTemplates[SpecialModuleIndex - 1].Name
  else Result := '';
end;
{ @end $6F9820 }

{ @routine $6F9854 TEquipment_Improve }
procedure TEquipment.Improve(Kind: TUpgradeKind);
begin
end;
{ @end $6F9854 }

{ @routine $6F9858 TEquipment_CalculateImprovementCost }
function TEquipment.CalculateImprovementCost(Kind: TUpgradeKind): Integer;
begin
  case Kind of
    upgrade_minor: Result := RoundAndTruncateToTens(Cost * 0.3);
    upgrade_medium: Result := RoundAndTruncateToTens(Cost * 0.6);
    upgrade_major: Result := RoundAndTruncateToTens(Cost * 1.2);
  else
    RaiseWideMessage('Косяк в улучшении');
    Result := 0;
  end;
end;
{ @end $6F9858 }

{ @routine $6F9908 TEquipment_HasStandardStats }
function TEquipment.HasStandardStats: Boolean;
begin
  Result := True;
end;
{ @end $6F9908 }

{ @routine $6F990C TEquipment_GetBitmapResourceName }
function TEquipment.GetBitmapResourceName: WideString;
var Path: WideString;
begin
  Result := '';
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0) and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else if CustomFaction <> '' then
  begin
    Path := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + CustomFaction;
    if CacheDataRoot.FileExistsByPath(Path + 'a') and CacheDataRoot.FileExistsByPath(Path + 'i') and
      CacheDataRoot.FileExistsByPath(Path + 's') then Result := Path;
  end;
  if Result = '' then
    if OwnerId = owner_dominator then Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + 'Kling0'
    else Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + IntToStr(GetLevel - 1);
end;
{ @end $6F990C }

{ @routine $6F9B74 TEquipment_GetFragilityFactor }
function TEquipment.GetFragilityFactor(DamageFlags: TDamageFlagSet): Single;
var I: Integer; Entry: PExtraSpecial; Factor: Single;
begin
  Result := 1 / Max(0.001, OwnerInfo[OwnerId].EquipmentDurabilityFactor);
  if MicroModuleIndex <> 0 then Result := Result * MicroModuleTemplates[MicroModuleIndex - 1].FragilityFactor;
  if SpecialModuleIndex <> 0 then Result := Result * MicroModuleTemplates[SpecialModuleIndex - 1].FragilityFactor;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Factor := MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].FragilityFactor;
      if Abs(Factor - 1) > 0.000001 then
      begin
        if Entry.Count = 1 then Result := Result * Factor
        else Result := Power(Factor, Entry.Count) * Result;
      end;
    end;
end;
{ @end $6F9B74 }

{ @routine $6F9CC4 TEquipment_ReplaceInfoTokens }
procedure TEquipment.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
begin
end;
{ @end $6F9CC4 }

{ @routine $6F9CF0 TEquipment_GetStatBonus }
function TEquipment.GetStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var I, SpecialBonus: Integer; Entry: PExtraSpecial;
begin
  if (BonusKind in [bonus_accuracy..bonus_leadership, bonus_stimulant_capacity]) and (MicroModuleIndex <> 0) then
    Result := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]
  else Result := 0;
  if (ItemType in WeaponItemTypes) and
     (BonusKind in [bonus_energy_damage..bonus_weapon_range, bonus_missile_speed]) then Exit;
  if SpecialModuleIndex <> 0 then
    SpecialBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]
  else SpecialBonus := 0;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(SpecialBonus, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[BonusKind] * Entry.Count);
    end;
  if (SpecialBonus <> 0) and (MicroModuleIndex <> 0) and
     not (BonusKind in [bonus_acryn_effect, bonus_acryn_penalty]) then
  begin
    if (BonusKind in [bonus_mass]) = (SpecialBonus > 0) then
      Inc(SpecialBonus, Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_acryn_penalty] * SpecialBonus * 0.0001))
    else
      Inc(SpecialBonus, Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_acryn_effect] * SpecialBonus * 0.0001));
  end;
  Inc(Result, SpecialBonus);
end;
{ @end $6F9CF0 }

{ @routine $6F9E54 TEquipment_GetDescriptionStatBonus }
function TEquipment.GetDescriptionStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var
  Index, CombinedBonus, SeparatedBonus, ExtraSeparatedBonus, EffectPercent, PenaltyPercent: Integer;
  Entry: PExtraSpecial;
begin
  if (BonusKind in [bonus_accuracy..bonus_leadership, bonus_stimulant_capacity]) and (MicroModuleIndex <> 0) and
    not MicroModuleTemplates[MicroModuleIndex - 1].SeparatedNumbers then
    Result := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]
  else Result := 0;
  if (ItemType in WeaponItemTypes) and (BonusKind in [bonus_energy_damage..bonus_weapon_range, bonus_missile_speed]) then Exit;
  CombinedBonus := 0;
  SeparatedBonus := 0;
  ExtraSeparatedBonus := 0;
  if SpecialModuleIndex <> 0 then
    if MicroModuleTemplates[SpecialModuleIndex - 1].SeparatedNumbers then
      SeparatedBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]
    else CombinedBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind];
  if ExtraSpecials <> nil then
    for Index := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[Index];
      if MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].SeparatedNumbers then
        ExtraSeparatedBonus := CombinedBonus + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[BonusKind] * Entry.Count
      else CombinedBonus := CombinedBonus + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[BonusKind] * Entry.Count;
    end;
  if MicroModuleIndex <> 0 then
  begin
    EffectPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_acryn_effect];
    PenaltyPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_acryn_penalty];
  end
  else
  begin
    EffectPercent := 0;
    PenaltyPercent := 0;
  end;
  if ((EffectPercent <> 0) or (PenaltyPercent <> 0)) and
    ((CombinedBonus <> 0) or (SeparatedBonus <> 0) or (ExtraSeparatedBonus <> 0)) and
    not (BonusKind in [bonus_acryn_effect..bonus_acryn_penalty]) then
  begin
    CombinedBonus := CombinedBonus + SeparatedBonus + ExtraSeparatedBonus;
    if (BonusKind in [bonus_mass]) = (CombinedBonus > 0) then
      CombinedBonus := CombinedBonus + Round(CombinedBonus * PenaltyPercent * 0.0001)
    else CombinedBonus := CombinedBonus + Round(CombinedBonus * EffectPercent * 0.0001);
    if (BonusKind in [bonus_mass]) = (SeparatedBonus > 0) then
      SeparatedBonus := SeparatedBonus + Round(SeparatedBonus * PenaltyPercent * 0.0001)
    else SeparatedBonus := SeparatedBonus + Round(SeparatedBonus * EffectPercent * 0.0001);
    if (BonusKind in [bonus_mass]) = (ExtraSeparatedBonus > 0) then
      ExtraSeparatedBonus := ExtraSeparatedBonus + Round(ExtraSeparatedBonus * PenaltyPercent * 0.0001)
    else ExtraSeparatedBonus := ExtraSeparatedBonus + Round(ExtraSeparatedBonus * EffectPercent * 0.0001);
    CombinedBonus := CombinedBonus - SeparatedBonus - ExtraSeparatedBonus;
  end;
  Result := Result + CombinedBonus;
end;
{ @end $6F9E54 }

{ @routine $6FA354 TEquipment_GetBonusDescription }
function TEquipment.GetBonusDescription(ColorTag: WideString): WideString;
var
  Description: WideString;
  EffectPercent, PenaltyPercent, StatBonus: Integer;
  BonusKind: TEquipmentBonusKind;
  Index, ModuleIndexPlusOne: Integer;

  // @nested $6FA124 ExpandModuleTokens
  function ExpandModuleTokens(Text: WideString; ModuleIndexPlusOne, Count: Integer): WideString; // @addr 0x006FA124 @calls "0x006FA42E,0x006FA5B3,0x006FA6DA" @note "Uses the parent description, bonus multipliers and color. RET 4 removes Result; the caller removes ParentFrame. Count 0 suppresses numeric bonuses."
  var BonusIndex: TEquipmentBonusKind; Value: Integer;
  begin
    // The native helper reads the captured description; Text remains an unused managed parameter.
    Result := Description;
    for BonusIndex := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
    begin
      Value := MicroModuleTemplates[ModuleIndexPlusOne - 1].StatBonuses[BonusIndex];
      Value := Value * Count;
      if (Count <> 0) and (EffectPercent <> 0) and not (BonusIndex in [bonus_acryn_effect..bonus_acryn_penalty]) then
        if (BonusIndex in [bonus_mass]) = (Value > 0) then Value := Value + Round(Value * PenaltyPercent * 0.0001)
        else Value := Value + Round(Value * EffectPercent * 0.0001);
      if Value > 0 then
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[BonusIndex] + '>', '+' + IntToStr(Value), ColorTag)
      else if Value < 0 then
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[BonusIndex] + '>', IntToStr(Value), ColorTag)
      else ReplaceTextToken(Result, '<' + EquipmentBonusNames[BonusIndex] + '>', '--', ColorTag);
    end;
  end;

begin
  Result := '';
  if MicroModuleIndex <> 0 then
  begin
    EffectPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_acryn_effect];
    PenaltyPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_acryn_penalty];
  end
  else
  begin
    EffectPercent := 0;
    PenaltyPercent := 0;
  end;
  if SpecialModuleIndex <> 0 then
  begin
    Description := LocalizedColorText('MicroModuls.' + MicroModuleTemplates[SpecialModuleIndex - 1].ConfigName + '.Text');
    if MicroModuleTemplates[SpecialModuleIndex - 1].SeparatedNumbers then
      Description := ExpandModuleTokens(Description, SpecialModuleIndex, 1);
    if (Self is TWeapon) and (MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace = '') and
      (GetSpecialModuleName <> '') then
    begin
      Result := #13#10' '#13#10 + LocalizedText('Items.Weapon.WSpecial') + ' ' +
        WrapTextInColor(GetSpecialModuleName, TextHighlightColorTag);
      if Description <> '' then Result := Result + #13#10 + WrapTextInColor(Description, GetMicroModuleTextColorTag(SpecialModuleIndex - 1));
    end
    else if Description <> '' then Result := #13#10' '#13#10 + WrapTextInColor(Description, GetMicroModuleTextColorTag(SpecialModuleIndex - 1));
  end;
  if MicroModuleIndex <> 0 then
  begin
    Description := LocalizedColorText('MicroModuls.' + MicroModuleTemplates[MicroModuleIndex - 1].ConfigName + '.ExText');
    if Description <> '' then
    begin
      if MicroModuleTemplates[MicroModuleIndex - 1].SeparatedNumbers then
        Description := ExpandModuleTokens(Description, MicroModuleIndex, 0);
      Result := Result + #13#10 + WrapTextInColor(Description, GetMicroModuleTextColorTag(MicroModuleIndex - 1));
    end;
  end;
  if ExtraSpecials <> nil then
    for Index := 0 to ExtraSpecials.Count - 1 do
    begin
      ModuleIndexPlusOne := PExtraSpecial(ExtraSpecials[Index]).ModuleIndexPlusOne;
      if (ModuleIndexPlusOne <> MicroModuleIndex) or MicroModuleTemplates[ModuleIndexPlusOne - 1].SeparatedNumbers then
      begin
        Description := LocalizedColorText('MicroModuls.' + MicroModuleTemplates[ModuleIndexPlusOne - 1].ConfigName + '.ExText');
        if Description = '' then Continue;
        ReplaceTextToken(Description, '<ExCount>', IntToStr(PExtraSpecial(ExtraSpecials[Index]).Count), ColorTag);
        if MicroModuleTemplates[ModuleIndexPlusOne - 1].SeparatedNumbers then
          Description := ExpandModuleTokens(Description, ModuleIndexPlusOne, PExtraSpecial(ExtraSpecials[Index]).Count);
        Result := Result + #13#10 + WrapTextInColor(Description, GetMicroModuleTextColorTag(ModuleIndexPlusOne - 1));
      end;
    end;
  if Result = '' then Exit;
  for BonusKind := bonus_armor to bonus_none do
  begin
    StatBonus := GetDescriptionStatBonus(BonusKind);
    if StatBonus > 0 then
      ReplaceTextToken(Result, '<' + EquipmentBonusNames[BonusKind] + '>', '+' + IntToStr(StatBonus), ColorTag)
    else if StatBonus < 0 then
      ReplaceTextToken(Result, '<' + EquipmentBonusNames[BonusKind] + '>', IntToStr(StatBonus), ColorTag)
    else ReplaceTextToken(Result, '<' + EquipmentBonusNames[BonusKind] + '>', '--', ColorTag);
  end;
end;
{ @end $6FA354 }

{ @routine $6FA9CC TEquipment_CanImprove }
function TEquipment.CanImprove: Boolean;
begin
  Result := HasStandardStats and ((SpecialModuleIndex = 0) or
    not MicroModuleTemplates[SpecialModuleIndex - 1].BlocksSpecialSlot);
end;
{ @end $6FA9CC }

{ @routine $6FAA04 THull_Init }
procedure THull.Init(Capacity: Integer; Level: Byte; Owner: TOwnerId; HullType: THullType; Series: Integer; PirateBuilt: Boolean);
begin
  ItemType := item_hull;
  OwnerShip := nil;
  Weight := Capacity;
  HullPoints := Weight;
  Self.HullType := HullType;
  TechLevel := Level;
  OwnerId := Owner;
  Armor := CalculateGeneratedArmor;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
  HullSeries := Series;
  Self.PirateBuilt := PirateBuilt;
  ApplySeriesSizeAndCost;
  CapitalShip := 0;
  ImpulseShieldsEnabled := False;
  InterceptorsEnabled := False;
  Energy := 0;
  EnergyMax := 0;
  InterceptorTarget := nil;
end;
{ @end $6FAA04 }

{ @routine $6FAA80 THull_ApplySeriesSizeAndCost }
procedure THull.ApplySeriesSizeAndCost;
var NewWeight: Integer;
begin
  if HullSeries <> -1 then
  begin
    NewWeight := Round(Weight / 100 * HullSeriesDefinitions[HullSeries].SizePercent);
    if NewWeight < Weight then NewWeight := Min(Weight, Max(250, NewWeight));
    Weight := NewWeight;
    HullPoints := Weight;
    Cost := RoundAndTruncateToTens(Cost / 100 * HullSeriesDefinitions[HullSeries].CostPercent);
    if (Cost < 0) or (Cost > MaxMonetaryValue) then Cost := MaxMonetaryValue;
  end;
end;
{ @end $6FAA80 }

{ @routine $6FAB28 THull_SaveToBuffer }
procedure THull.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(HullPoints);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(Armor));
  Buffer.AddAnsiChar(AnsiChar(HullType));
  Buffer.AddIntegerValue(HullSeries);
  if HullSeries <> -1 then Buffer.AddDWord(HullSeriesDefinitions[HullSeries].SystemNameCRC);
  Buffer.AddBoolean(PirateBuilt);
  Buffer.AddAnsiChar(AnsiChar(CapitalShip));
  Buffer.AddBoolean(ImpulseShieldsEnabled);
  Buffer.AddBoolean(InterceptorsEnabled);
  Buffer.AddIntegerValue(Energy);
  Buffer.AddIntegerValue(EnergyMax);
  if InterceptorsEnabled then
  begin
    if InterceptorTarget <> nil then Buffer.AddDWord((InterceptorTarget as TShip).Id)
    else Buffer.AddDWord(0);
    Buffer.AddAnsiChar(AnsiChar(InterceptorTargetingStrategy));
    Buffer.AddAnsiChar(AnsiChar(InterceptorPassCountOverride));
  end;
end;
{ @end $6FAB28 }

{ @routine $6FAC9C THull_LoadFromBuffer }
procedure THull.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
var SavedHullType: Integer;

  // @nested $6FAC20 ReadSavedHullSeriesIndex
  function ReadSavedHullSeriesIndex(Buffer: TBufEC): Integer; // @addr 0x006FAC20 @note "Returns a zero-based series index, or -1 if absent or unresolved."
  var
    I: Integer;
    CRC: Cardinal;
  begin
    Result := Buffer.GetInt32;
    if Result <> -1 then
    begin
      CRC := Buffer.GetUInt32;
      if (Result > High(HullSeriesDefinitions)) or (HullSeriesDefinitions[Result].SystemNameCRC <> CRC) then
      begin
        Result := -1;
        for I := 0 to High(HullSeriesDefinitions) do
          if HullSeriesDefinitions[I].SystemNameCRC = CRC then
          begin
            Result := I;
            Break;
          end;
      end;
    end;
  end;

begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion >= 51 then HullPoints := Buffer.GetInt32 else HullPoints := Buffer.GetWord;
  TechLevel := Buffer.GetByte;
  Armor := ShortInt(Buffer.GetByte);
  SavedHullType := Buffer.GetByte;
  if LoadedSaveVersion >= 88 then HullType := THullType(SavedHullType)
  else if LoadedSaveVersion >= 67 then
  begin
    if (SavedHullType > 6) and (SavedHullType < 24) then SavedHullType := 6;
    if SavedHullType >= 24 then Dec(SavedHullType, 17);
    HullType := THullType(SavedHullType);
  end
  else if SavedHullType > 26 then HullType := hull_special
  else
  begin
    if (SavedHullType > 6) and (SavedHullType < 24) then SavedHullType := 6;
    if SavedHullType >= 24 then Dec(SavedHullType, 17);
    HullType := THullType(SavedHullType);
  end;
  if (HullType = hull_special) and (SpecialModuleIndex = 0) then HullType := hull_ranger;
  if LoadedSaveVersion >= 163 then HullSeries := ReadSavedHullSeriesIndex(Buffer)
  else
  begin
    HullSeries := Buffer.GetByte;
    if (HullSeries = 255) or (HullSeries > High(HullSeriesDefinitions)) then HullSeries := -1;
  end;
  if LoadedSaveVersion >= 50 then PirateBuilt := Buffer.GetBoolean else PirateBuilt := False;
  if LoadedSaveVersion >= 51 then
  begin
    CapitalShip := Buffer.GetByte;
    ImpulseShieldsEnabled := Buffer.GetBoolean;
    InterceptorsEnabled := Buffer.GetBoolean;
    Energy := Buffer.GetInt32;
    EnergyMax := Buffer.GetInt32;
  end
  else
  begin
    CapitalShip := 0;
    ImpulseShieldsEnabled := False;
    InterceptorsEnabled := False;
    Energy := 0;
    EnergyMax := 0;
  end;
  if LoadedSaveVersion >= 52 then
    if InterceptorsEnabled then
    begin
      InterceptorTarget := TObject(Buffer.GetUInt32);
      InterceptorTargetingStrategy := TInterceptorTargetingStrategy(Buffer.GetByte);
      InterceptorPassCountOverride := Buffer.GetByte;
    end
    else
    begin
      InterceptorTarget := nil;
      InterceptorTargetingStrategy := interceptor_manual;
      InterceptorPassCountOverride := 0;
    end
  else if LoadedSaveVersion = 51 then
  begin
    InterceptorTarget := TObject(Buffer.GetUInt32);
    InterceptorTargetingStrategy := interceptor_manual;
    InterceptorPassCountOverride := 0;
  end
  else
  begin
    InterceptorTarget := nil;
    InterceptorTargetingStrategy := interceptor_manual;
    InterceptorPassCountOverride := 0;
  end;
end;
{ @end $6FAC9C }

{ @routine $6FAE98 THull_ResolveLoadedReferences }
procedure THull.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  if InterceptorTarget <> nil then InterceptorTarget := Galaxy.IdToShip(Integer(InterceptorTarget), False) as TShip;
end;
{ @end $6FAE98 }

{ @routine $6FAEC4 THull_ClearReferences }
procedure THull.ClearReferences;
begin
  inherited ClearReferences;
  InterceptorTarget := nil;
end;
{ @end $6FAEC4 }

{ @routine $6FAED8 THull_SaveToBlock }
procedure THull.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Hristophorisnotuse'), IntToStr(HullPoints)); // 'Hitpoints'
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Alrumuotr'), IntToStr(Armor)); // 'Armor'
  Block.AddParam(DecodeTextW('SohtiEprTtyopwec'), IntToStr(Ord(HullType))); // 'ShipType'
  Block.AddParam(DecodeTextW('Stearoidess'), IntToStr(HullSeries)); // 'Series'
  if HullSeries <> -1 then
    Block.AddParam(DecodeTextW('IfSoenrOilets2Noarmye'), GetSeriesName); // 'ISeriesName'
  Block.AddParam(DecodeTextW('BlueivlitoBuyAPIinroaLtte'), BoolToWideString(PirateBuilt)); // 'BuiltByPirate'
end;
{ @end $6FAED8 }

{ @routine $6FB200 THull_LoadFromBlock }
procedure THull.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  HullPoints := StrToInt(Block.GetParam(DecodeTextW('Hristophorisnotuse'))); // 'Hitpoints'
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Armor := StrToInt(Block.GetParam(DecodeTextW('Alrumuotr'))); // 'Armor'
  HullType := THullType(StrToInt(Block.GetParam(DecodeTextW('SohtiEprTtyopwec')))); // 'ShipType'
  HullSeries := StrToInt(Block.GetParam(DecodeTextW('Stearoidess'))); // 'Series'
  PirateBuilt := LowerCase(Block.GetParam(DecodeTextW('BlueivlitoBuyAPIinroaLtte'))) = 'true'; // 'BuiltByPirate'
end;
{ @end $6FB200 }

{ @routine $6FB500 THull_CalculateGeneratedArmor }
function THull.CalculateGeneratedArmor: ShortInt;
begin
  Result := HullLevelStats[TechLevel].Armor;
end;
{ @end $6FB500 }

{ @routine $6FB514 CalculateGeneratedHullCost }
function CalculateGeneratedHullCost(Capacity, Level: Cardinal; Owner: TOwnerId; HullType: THullType): Integer;
var Kind: TShipSlotKind; Factor: Double;
begin
  Factor := 1;
  if HullType in [hull_ranger..hull_diplomat] then
  begin
    for Kind := slot_radar to slot_afterburner do
      case Kind of
        slot_radar: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.7 * Factor;
        slot_scanner: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.9 * Factor;
        slot_repair_robot: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.7 * Factor;
        slot_cargo_hook: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.6 * Factor;
        slot_defense_generator: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.7 * Factor;
        slot_weapon: Factor := RemapClamped(GetBaseHullSlotCount(Kind, HullType, Owner, nil), 2, 5, 0.5, 1) * Factor;
        slot_artefact: Factor := RemapClamped(GetBaseHullSlotCount(Kind, HullType, Owner, nil), 0, 4, 0.7, 1) * Factor;
        slot_afterburner: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.85 * Factor;
      end;
    if Factor < 0.2 then Factor := 0.2;
  end
  else if HullType = hull_flagship then Factor := 0.05;
  Result := RoundAndTruncateToTens(RemapClamped(Level, 1, 8, 1, 8) * 2000 * Factor *
    (Max(Capacity, 250) * 0.01 - 0.006) * (Max(Capacity, 1000) * 0.002 - 0.001) *
    (Max(Capacity, 2000) * 0.0005));
end;
{ @end $6FB514 }

{ @routine $6FB8D0 THull_CalculateGeneratedCost }
function THull.CalculateGeneratedCost: Integer;
var Value: Integer;
begin
  Value := CalculateGeneratedHullCost(Weight, TechLevel, OwnerId, HullType);
  while Value < 0 do
  begin
    Weight := Abs(Round(Weight / 2));
    HullPoints := Weight;
    Value := CalculateGeneratedHullCost(Weight, TechLevel, OwnerId, HullType);
  end;
  Result := Value;
end;
{ @end $6FB8D0 }

{ @routine $6FB938 THull_Repair }
procedure THull.Repair;
begin
  inherited Repair;
  HullPoints := Weight;
end;
{ @end $6FB938 }

{ @routine $6FB94C THull_Improve }
procedure THull.Improve(Kind: TUpgradeKind);
var ExtraCapacity: Integer;


begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    upgrade_minor: Inc(Armor, SeededRandomIntRange(1, 2, Id * 254571));
    upgrade_medium: Inc(Armor, SeededRandomIntRange(2, 3, Id * 254571));
    upgrade_major: Inc(Armor, SeededRandomIntRange(3, 4, Id * 254571));
  end;
  if HullType = hull_tranclucator then
  begin
    ExtraCapacity := 0;
    case Kind of
      upgrade_minor: ExtraCapacity := Round(SeededRandomIntRange(3, 7, Id * 214571) * Max(Weight, 500) * 0.01);
      upgrade_medium: ExtraCapacity := Round(SeededRandomIntRange(8, 12, Id * 214571) * Max(Weight, 500) * 0.01);
      upgrade_major: ExtraCapacity := Round(SeededRandomIntRange(13, 17, Id * 214571) * Max(Weight, 500) * 0.01);
    end;
    Inc(Weight, ExtraCapacity);
    Inc(HullPoints, ExtraCapacity);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $6FB94C }

{ @routine $6FBAEC THull_HasStandardStats }
function THull.HasStandardStats: Boolean;
var ModuleIndex: Integer;
begin
  ModuleIndex := MicroModuleIndex;
  if (ModuleIndex = 0) or (MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_armor] = 0) then
    Result := CalculateGeneratedArmor = Armor
  else Result := CalculateGeneratedArmor = Armor - MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_armor];
end;
{ @end $6FBAEC }

{ @routine $6FBB44 THull_GetDisplayName }
function THull.GetDisplayName: WideString;
var TypeName, ShipTypeName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if SpecialModuleIndex <> 0 then
  begin
    Result := WrapTextInColor(GetSpecialModuleName, GetMicroModuleTextColorTag(SpecialModuleIndex - 1));
    ReplaceTextToken(Result, '<Type>', LocalizedText('Items.Hull.Type.' + IntToStr(TechLevel)), '');
  end
  else
  begin
    TypeName := LocalizedText('Items.Hull.Type.' + IntToStr(TechLevel));
    case HullType of
      hull_ranger: ShipTypeName := LocalizedText('Items.Hull.ShipType.Ranger');
      hull_transport: ShipTypeName := LocalizedText('Items.Hull.ShipType.Transport');
      hull_liner: ShipTypeName := LocalizedText('Items.Hull.ShipType.Liner');
      hull_diplomat: ShipTypeName := LocalizedText('Items.Hull.ShipType.Diplomat');
      hull_pirate: ShipTypeName := LocalizedText('Items.Hull.ShipType.Pirate');
      hull_warrior: ShipTypeName := LocalizedText('Items.Hull.ShipType.Warrior');
      hull_dominator: ShipTypeName := LocalizedText('Items.Hull.ShipType.Kling');
    else ShipTypeName := '';
    end;
    Result := FormatText2(LocalizedText('Items.Hull.Name'), '', '<Type>', TypeName, '<ShipType>', ShipTypeName);
  end;
  if HasMicroModule then Result := Result + ' ' + WrapTextInColor(GetMicroModuleQuotedName, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;
{ @end $6FBB44 }

{ @routine $6FBFB0 THull_GetSeriesName }
function THull.GetSeriesName: WideString;
begin
  if (OwnerShip <> nil) and TShip(OwnerShip).UsesVeteranHumanRangerAppearance then
    Result := FormatText1(LocalizedText('HullType.SeriesName'), '', '<Name>', LocalizedText('HullType.HullOldfag.Name'))
  else if HullSeries = -1 then Result := ''
  else Result := FormatText1(LocalizedText('HullType.SeriesName'), '', '<Name>', HullSeriesDefinitions[HullSeries].Name);
end;
{ @end $6FBFB0 }

{ @routine $6FC0F4 THull_GetShortName }
function THull.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Hull.ShortName');
end;
{ @end $6FC0F4 }

{ @routine $6FC154 THull_GetInfoText }
function THull.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text, SizeColor: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if Text = '' then Text := LocalizedText('Items.Hull.Text');
  if (OwnerShip <> nil) and TShip(OwnerShip).UsesVeteranHumanRangerAppearance then
    Text := LocalizedText('HullType.HullOldfag.Text') + ' ' + Text
  else if HullSeries <> -1 then Text := HullSeriesDefinitions[HullSeries].Text + ' ' + Text;
  if HullPoints <= Weight / 2 then SizeColor := GoldColorTag else SizeColor := ColorTag;
  ReplaceTextToken(Text, '<Size>', IntToStr(HullPoints), SizeColor);
  ReplaceTextToken(Text, '<MaxSize>', IntToStr(Weight), ColorTag);
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text;
end;
{ @end $6FC154 }

{ @routine $6FC420 THull_ReplaceInfoTokens }
procedure THull.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseArmor, StatBonus: Integer;
begin
  ReplaceTextToken(Text, '<FragilityE>', IntToStr(Round(GetFragilityFactor([damage_flag_energy]) * 100)), ColorTag);
  ReplaceTextToken(Text, '<FragilityS>', IntToStr(Round(GetFragilityFactor([damage_flag_splinter]) * 100)), ColorTag);
  ReplaceTextToken(Text, '<FragilityM>', IntToStr(Round(GetFragilityFactor([damage_flag_missile]) * 100)), ColorTag);
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_armor] = 0) then BonusText := ''
  else
  begin
    if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_armor] > 0 then
      BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_armor]), GreenColorTag)
    else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_armor]), RedColorTag);
  end;
  StatBonus := GetStatBonus(bonus_armor);
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if OwnerShip <> nil then StatBonus := TShip(OwnerShip).GetTotalStatBonus(bonus_armor) - StatBonus
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then BaseArmor := Armor
  else BaseArmor := Armor - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_armor];
  if CalculateGeneratedArmor = BaseArmor then ReplaceTextToken(Text, '<HitProtect>', WideString(IntToStr(BaseArmor)) + BonusText, ColorTag)
  else if CalculateGeneratedArmor < BaseArmor then
    ReplaceTextToken(Text, '<HitProtect>', WrapTextInColor(IntToStr(BaseArmor), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<HitProtect>', WrapTextInColor(IntToStr(BaseArmor), RedColorTag) + BonusText, ColorTag);
end;
{ @end $6FC420 }

{ @routine $6FCA80 THull_GetBitmapResourceName }
function THull.GetBitmapResourceName: WideString;
var Ship: TShip;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if HullType = hull_ranger then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_R_'
  else if HullType = hull_warrior then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_W_'
  else if HullType = hull_pirate then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_P_'
  else if HullType = hull_transport then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_T_'
  else if HullType = hull_liner then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_L_'
  else if HullType = hull_diplomat then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_D_'
  else if (HullType = hull_special) and (SpecialModuleIndex <> 0) then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + GetSpecialKindGraph + '_'
  else RaiseWideMessage('THull.Image');
  Ship := TShip(OwnerShip);
  if Ship <> nil then
  begin
    if (HullType = hull_special) and (SpecialModuleIndex <> 0) and (GetSpecialKindGraph = 'J') and
      Ship.IsFemaleHumanPilot and (Ship.TypeId = ship_ranger) then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_J_alt_'
    else if (HullType = hull_ranger) and (SpecialModuleIndex = 0) and Ship.UsesVeteranHumanRangerAppearance then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_People_ROld_'
    else if (Ship.TypeId = ship_pirate) and (Ship.OwnerId = owner_pirate) and ((Ship as TPirate).PirateType <> 0) then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_PC_';
  end;
end;
{ @end $6FCA80 }

{ @routine $6FCEB4 THull_GetSpecialKindGraph }
function THull.GetSpecialKindGraph: WideString;
begin
  Result := '1';
  if (SpecialModuleIndex = 0) or
     (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph = '') then Exit;
  Result := MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph;
end;
{ @end $6FCEB4 }

{ @routine $6FCF08 THull_GetSlotCount }
function THull.GetSlotCount(Kind: TShipSlotKind): Integer;
var BonusKind: TEquipmentBonusKind; I, Maximum, Minimum: Integer; Entry: PExtraSpecial;
begin
  Result := GetBaseHullSlotCount(Kind, HullType, OwnerId, OwnerShip);
  BonusKind := HullSlotBonusKinds[Kind];
  Maximum := DefaultHullSlotCounts[Kind];
  Minimum := MinimumHullSlotCounts[Kind];
  if SpecialModuleIndex <> 0 then
    Result := Min(Maximum, Max(Minimum, Result + MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]));
  if ExtraSpecials <> nil then
  begin
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(Result, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[BonusKind] * Entry.Count);
    end;
    Result := Min(Maximum, Max(Minimum, Result));
  end;
  if HullSeries <> -1 then
    Result := Min(Maximum, Max(Minimum, Result + HullSeriesDefinitions[HullSeries].SlotBonuses[Kind]));
  if MicroModuleIndex <> 0 then
    Result := Min(Maximum, Max(Minimum, Result + MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]));
end;
{ @end $6FCF08 }

{ @routine $6FD06C GetBaseHullSlotCount }
function GetBaseHullSlotCount(Kind: TShipSlotKind; HullType: THullType; Owner: TOwnerId; Ship: Pointer): Integer;
begin
  Result := 0;
  case HullType of
    hull_ranger: Result := RangerHullSlots[Owner, Kind];
    hull_warrior: Result := WarriorHullSlots[Owner, Kind];
    hull_pirate: Result := PirateHullSlots[Owner, Kind];
    hull_transport: Result := TransportHullSlots[Owner, Kind];
    hull_liner: Result := LinerHullSlots[Owner, Kind];
    hull_diplomat: Result := DiplomatHullSlots[Owner, Kind];
    hull_tranclucator: Result := TranclucatorHullSlots[Kind];
    hull_dominator: if (Ship = nil) or not (TObject(Ship) is TKling) then
         Result := DominatorHullSlots[dominator_boss, Kind]
       else Result := DominatorHullSlots[(TObject(Ship) as TKling).KlingType, Kind];
    hull_station: if Ship = nil then Result := StationHullSlots[station_ranger_center, Kind]
       else if not (TShip(Ship).TypeId in [station_ranger_center..station_custom]) then
         Result := StationHullSlots[station_ranger_center, Kind]
       else Result := StationHullSlots[TShip(Ship).TypeId, Kind];
    hull_special: Result := SpecialHullSlots[Kind];
    hull_flagship: Result := FlagshipHullSlots[Kind];
  else RaiseWideMessage('SlotCount error');
  end;
end;
{ @end $6FD06C }

{ @routine $6FD264 THull_CalculateMass }
function THull.CalculateMass: Integer;
begin
  Result := Round(RemapClamped(TechLevel, 1, 8, Weight * 0.6, Weight * 0.8));
end;
{ @end $6FD264 }

{ @routine $6FD2D0 THull_GetFragilityFactor }
function THull.GetFragilityFactor(DamageFlags: TDamageFlagSet): Single;
var DamageClass: TWeaponDamageClass; Entry: PExtraSpecial; I: Integer; Factor: Single;
begin
  if DamageFlags = [] then
  begin
    Result := 0;
    for DamageClass := damage_class_energy to damage_class_missile do
      Result := GetFragilityFactor([TDamageFlag(WeaponDamageClasses[DamageClass].Kind)]) + Result;
    Result := Result / 3;
    Exit;
  end;
  DamageClass := ClassifyWeaponDamageFlags(DamageFlags);
  Result := HullFragilityByType[HullType] * HullLevelStats[TechLevel].Fragility[DamageClass] * HullFragilityByOwner[DamageClass, OwnerId];
  if PirateBuilt then Result := Result * HullFragilityByOwner[DamageClass, owner_pirate];
  if MicroModuleIndex <> 0 then Result := Result * MicroModuleTemplates[MicroModuleIndex - 1].FragilityFactorByDamageClass[DamageClass];
  if SpecialModuleIndex <> 0 then Result := Result * MicroModuleTemplates[SpecialModuleIndex - 1].FragilityFactorByDamageClass[DamageClass];
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Factor := MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].FragilityFactorByDamageClass[DamageClass];
      if Abs(Factor - 1) > 0.000001 then
      begin
        if Entry.Count = 1 then Result := Result * Factor
        else Result := Power(Factor, Entry.Count) * Result;
      end;
    end;
  if HullSeries <> -1 then Result := Result * HullSeriesDefinitions[HullSeries].FragilityByDamageClass[DamageClass];
end;
{ @end $6FD2D0 }

{ @routine $6FD514 THull_EstimateCapacityWithoutBonuses }
function THull.EstimateCapacityWithoutBonuses: Integer;
var I: Integer;

  // @nested $6FD4D4 UndoSizePercent
  procedure UndoSizePercent(Percent: Integer); // @addr 0x006FD4D4 @note "Updates the parent's capacity accumulator; caller removes ParentFrame. Nonpositive Percent leaves it unchanged."
  var Factor: Single;
  begin
    if Percent <= 0 then Factor := 1 else Factor := 100 / Percent;
    Result := Round(Result * Factor);
  end;


begin
  Result := Weight;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
      UndoSizePercent(MicroModuleTemplates[PExtraSpecial(ExtraSpecials[I]).ModuleIndexPlusOne - 1].SizePercent);
  if MicroModuleIndex <> 0 then UndoSizePercent(MicroModuleTemplates[MicroModuleIndex - 1].SizePercent);
  if SpecialModuleIndex <> 0 then UndoSizePercent(MicroModuleTemplates[SpecialModuleIndex - 1].SizePercent);
  if HullSeries <> -1 then UndoSizePercent(HullSeriesDefinitions[HullSeries].SizePercent);
end;
{ @end $6FD514 }

{ @routine $6FD5C0 TFuelTanks_Init }
procedure TFuelTanks.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := item_fuel_tanks;
  Self.Weight := Weight;
  TechLevel := Level;
  Capacity := CalculateGeneratedCapacity;
  Fuel := Capacity;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $6FD5C0 }

{ @routine $6FD608 TFuelTanks_SaveToBuffer }
procedure TFuelTanks.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Fuel));
  Buffer.AddAnsiChar(AnsiChar(Capacity));
end;
{ @end $6FD608 }

{ @routine $6FD63C TFuelTanks_LoadFromBuffer }
procedure TFuelTanks.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Fuel := Buffer.GetWord;
  Capacity := Buffer.GetByte;
end;
{ @end $6FD63C }

{ @routine $6FD670 TFuelTanks_SaveToBlock }
procedure TFuelTanks.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('FiuNeol'), IntToStr(Fuel)); // 'Fuel'
  Block.AddParam(DecodeTextW('CraspiaNcliotay'), IntToStr(Capacity)); // 'Capacity'
end;
{ @end $6FD670 }

{ @routine $6FD7F8 TFuelTanks_LoadFromBlock }
procedure TFuelTanks.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Fuel := Word(StrToInt(Block.GetParam(DecodeTextW('FiuNeol')))); // 'Fuel'
  Capacity := StrToInt(Block.GetParam(DecodeTextW('CraspiaNcliotay'))); // 'Capacity'
end;
{ @end $6FD7F8 }

{ @routine $6FD978 TFuelTanks_CalculateGeneratedCapacity }
function TFuelTanks.CalculateGeneratedCapacity: Byte;
begin
  Result := CalculateGeneratedFuelCapacity(Weight, TechLevel);
end;
{ @end $6FD978 }

{ @routine $6FD98C CalculateGeneratedFuelCapacity }
function CalculateGeneratedFuelCapacity(Weight: Cardinal; Level: Integer): Integer;
begin
  Result := Round(Weight / FuelTanksBaseSize * 20 + FuelCapacityByLevel[Level]);
end;
{ @end $6FD98C }

{ @routine $6FD9D4 CalculateGeneratedFuelTanksCost }
function CalculateGeneratedFuelTanksCost(Weight: Cardinal; Level: Integer; Owner: TOwnerId): Integer;
begin
  Result := RoundAndTruncateToTens(Weight / FuelTanksBaseSize * Cardinal(Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $6FD9D4 }

{ @routine $6FDA30 TFuelTanks_CalculateGeneratedCost }
function TFuelTanks.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedFuelTanksCost(Weight, TechLevel, OwnerId);
end;
{ @end $6FDA30 }

{ @routine $6FDA44 TFuelTanks_Improve }
procedure TFuelTanks.Improve(Kind: TUpgradeKind);
begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    upgrade_minor: Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + Capacity + 1;
    upgrade_medium: Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.1, 0.15)) + Capacity + 3;
    upgrade_major: Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.15, 0.2)) + Capacity + 5;
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $6FDA44 }

{ @routine $6FDB44 TFuelTanks_HasStandardStats }
function TFuelTanks.HasStandardStats: Boolean;
var BaseCapacity, ExpectedWeight, SizePercent: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity] = 0) then
    BaseCapacity := Capacity
  else BaseCapacity := Capacity - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity];
  ExpectedWeight := Round((BaseCapacity - FuelCapacityByLevel[TechLevel]) * FuelTanksBaseSize / 20);
  if MicroModuleIndex <> 0 then SizePercent := MicroModuleTemplates[MicroModuleIndex - 1].SizePercent else SizePercent := 0;
  if SizePercent > 0 then ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if SpecialModuleIndex <> 0 then SizePercent := MicroModuleTemplates[SpecialModuleIndex - 1].SizePercent else SizePercent := 0;
  if SizePercent > 0 then ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  Result := Abs(ExpectedWeight - Weight) <= 1;
end;
{ @end $6FDB44 }

{ @routine $6FDC30 TFuelTanks_GetInfoText }
function TFuelTanks.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.FuelTanks.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> owner_dominator then Text := LocalizedText('Items.FuelTanks.Text')
    else Text := LocalizedText('Items.FuelTanks.KlingText');
  ReplaceTextToken(Text, '<Fuel>', IntToStr(Fuel), ColorTag);
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $6FDC30 }

{ @routine $6FDE78 TFuelTanks_ReplaceInfoTokens }
procedure TFuelTanks.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, SizePercent, ExpectedWeight: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity]), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity]), RedColorTag);
  if MicroModuleIndex = 0 then BaseValue := Capacity
  else BaseValue := Capacity - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity];
  ExpectedWeight := Round((BaseValue - FuelCapacityByLevel[TechLevel]) * FuelTanksBaseSize / 20);
  if MicroModuleIndex <> 0 then SizePercent := MicroModuleTemplates[MicroModuleIndex - 1].SizePercent else SizePercent := 0;
  if SizePercent > 0 then ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if SpecialModuleIndex <> 0 then SizePercent := MicroModuleTemplates[SpecialModuleIndex - 1].SizePercent else SizePercent := 0;
  if SizePercent > 0 then ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if Abs(ExpectedWeight - Weight) <= 1 then ReplaceTextToken(Text, '<Capacity>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if ExpectedWeight > Weight then
    ReplaceTextToken(Text, '<Capacity>', WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Capacity>', WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText, ColorTag);
end;
{ @end $6FDE78 }

{ @routine $6FE204 TEngine_Init }
procedure TEngine.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := item_engine;
  MicroModuleIndex := 0;
  Self.Weight := Weight;
  TechLevel := Level;
  Speed := CalculateGeneratedSpeed;
  JumpRange := CalculateGeneratedJumpRange;
  OutputPercent := 100;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
end;
{ @end $6FE204 }

{ @routine $6FE250 TEngine_SaveToBuffer }
procedure TEngine.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddIntegerValue(Speed);
  Buffer.AddAnsiChar(AnsiChar(JumpRange));
  Buffer.AddAnsiChar(AnsiChar(OutputPercent));
end;
{ @end $6FE250 }

{ @routine $6FE290 TEngine_LoadFromBuffer }
procedure TEngine.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  if LoadedSaveVersion >= 161 then Speed := Buffer.GetInt32 else Speed := Buffer.GetWord;
  JumpRange := ShortInt(Buffer.GetByte);
  OutputPercent := Buffer.GetByte;
  ItemType := item_engine;
end;
{ @end $6FE290 }

{ @routine $6FE2EC TEngine_SaveToBlock }
procedure TEngine.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Sapreneld'), IntToStr(Speed)); // 'Speed'
  Block.AddParam(DecodeTextW('JiuOmipa'), IntToStr(JumpRange)); // 'Jump'
end;
{ @end $6FE2EC }

{ @routine $6FE46C TEngine_LoadFromBlock }
procedure TEngine.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Speed := Word(StrToInt(Block.GetParam(DecodeTextW('Sapreneld')))); // 'Speed'
  JumpRange := StrToInt(Block.GetParam(DecodeTextW('JiuOmipa'))); // 'Jump'
end;
{ @end $6FE46C }

{ @routine $6FE5E4 TEngine_CalculateGeneratedSpeed }
function TEngine.CalculateGeneratedSpeed: Integer;
begin
  Result := EngineLevelStats[TechLevel].Speed;
end;
{ @end $6FE5E4 }

{ @routine $6FE5F4 TEngine_CalculateGeneratedJumpRange }
function TEngine.CalculateGeneratedJumpRange: ShortInt;
begin
  Result := EngineLevelStats[TechLevel].JumpRange;
end;
{ @end $6FE5F4 }

{ @routine $6FE604 CalculateGeneratedEngineCost }
function CalculateGeneratedEngineCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(EngineBaseSize / Weight, 0.5, 2, 1, 2) * (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $6FE604 }

{ @routine $6FE694 TEngine_CalculateGeneratedCost }
function TEngine.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedEngineCost(Weight, TechLevel, OwnerId);
end;
{ @end $6FE694 }

{ @routine $6FE6A8 TEngine_Improve }
procedure TEngine.Improve(Kind: TUpgradeKind);
begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  if DetailImprovement = 0 then
    if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then DetailImprovement := 1
    else DetailImprovement := 2;
  if DetailImprovement = 1 then
    case Kind of
      upgrade_minor:
        begin
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.05) + SeededRandomIntRange(10, 30, Id * 254571)));
          Inc(JumpRange, SeededRandomIntRange(1, 2, Id * 354571));
        end;
      upgrade_medium:
        begin
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.02, 0.06) + SeededRandomIntRange(30, 60, Id * 254571)));
          Inc(JumpRange, SeededRandomIntRange(2, 4, Id * 354571));
        end;
      upgrade_major:
        begin
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.03, 0.07) + SeededRandomIntRange(50, 80, Id * 254571)));
          Inc(JumpRange, SeededRandomIntRange(3, 7, Id * 354571));
        end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      upgrade_minor:
        begin
          Inc(JumpRange, SeededRandomIntRange(2, 5, Id * 354571));
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.03) + SeededRandomIntRange(10, 20, Id * 254571)));
        end;
      upgrade_medium:
        begin
          Inc(JumpRange, SeededRandomIntRange(5, 7, Id * 354571));
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.04) + SeededRandomIntRange(20, 40, Id * 254571)));
        end;
      upgrade_major:
        begin
          Inc(JumpRange, SeededRandomIntRange(7, 12, Id * 354571));
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.05) + SeededRandomIntRange(30, 50, Id * 254571)));
        end;
    end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
  DetailImprovement := 0;
end;
{ @end $6FE6A8 }

{ @routine $6FEA3C TEngine_HasStandardStats }
function TEngine.HasStandardStats: Boolean;
var ModuleIndex: Integer; StandardSpeed, StandardJump: Boolean;
begin
  ModuleIndex := MicroModuleIndex;
  if (ModuleIndex = 0) or (MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_speed] = 0) then
    StandardSpeed := CalculateGeneratedSpeed = Speed
  else StandardSpeed := CalculateGeneratedSpeed = Speed - MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_speed];
  ModuleIndex := MicroModuleIndex;
  if (ModuleIndex = 0) or (MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_jump_range] = 0) then
    StandardJump := CalculateGeneratedJumpRange = JumpRange
  else StandardJump := CalculateGeneratedJumpRange = JumpRange - MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_jump_range];
  Result := StandardSpeed and StandardJump;
end;
{ @end $6FEA3C }

{ @routine $6FEAE8 TEngine_GetInfoText }
function TEngine.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Engine.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> owner_dominator then Text := LocalizedText('Items.Engine.Text')
    else Text := LocalizedText('Items.Engine.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $6FEAE8 }

{ @routine $6FECC8 TEngine_ReplaceInfoTokens }
procedure TEngine.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if MicroModuleIndex = 0 then StatBonus := 0
  else StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_speed];
  BaseValue := Max(0, Speed - StatBonus);
  StatBonus := Max(0, Speed) - BaseValue;
  if StatBonus = 0 then BonusText := ''
  else if StatBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(StatBonus), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(StatBonus), RedColorTag);
  StatBonus := Max(-Max(0, Speed), GetStatBonus(bonus_speed));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonus_speed) - StatBonus, -(Speed + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if CalculateGeneratedSpeed = BaseValue then ReplaceTextToken(Text, '<Speed>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedSpeed < BaseValue then
    ReplaceTextToken(Text, '<Speed>', WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Speed>', WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText, ColorTag);
  if MicroModuleIndex = 0 then StatBonus := 0
  else StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_jump_range];
  BaseValue := Max(0, JumpRange - StatBonus);
  StatBonus := Max(0, JumpRange) - BaseValue;
  if StatBonus = 0 then BonusText := ''
  else if StatBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(StatBonus), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(StatBonus), RedColorTag);
  StatBonus := Max(-Max(0, JumpRange), GetStatBonus(bonus_jump_range));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonus_jump_range) - StatBonus, -(JumpRange + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if CalculateGeneratedJumpRange = BaseValue then ReplaceTextToken(Text, '<Parsec>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedJumpRange < BaseValue then
    ReplaceTextToken(Text, '<Parsec>', WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Parsec>', WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText, ColorTag);
end;
{ @end $6FECC8 }

{ @routine $6FF648 TRadar_Init }
procedure TRadar.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := item_radar;
  Self.Weight := Weight;
  TechLevel := Level;
  Range := CalculateGeneratedRange;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $6FF648 }

{ @routine $6FF684 TRadar_SaveToBuffer }
procedure TRadar.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Range));
end;
{ @end $6FF684 }

{ @routine $6FF6AC TRadar_LoadFromBuffer }
procedure TRadar.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Range := Buffer.GetWord;
end;
{ @end $6FF6AC }

{ @routine $6FF6D8 TRadar_SaveToBlock }
procedure TRadar.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // 'Radius'
end;
{ @end $6FF6D8 }

{ @routine $6FF7F8 TRadar_LoadFromBlock }
procedure TRadar.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // 'Radius'
end;
{ @end $6FF7F8 }

{ @routine $6FF910 TRadar_CalculateGeneratedRange }
function TRadar.CalculateGeneratedRange: Integer;
begin
  Result := RadarLevelRanges[TechLevel];
end;
{ @end $6FF910 }

{ @routine $6FF920 CalculateGeneratedRadarCost }
function CalculateGeneratedRadarCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(RadarBaseSize / Weight, 0.5, 2, 1, 2) * (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $6FF920 }

{ @routine $6FF9B0 TRadar_CalculateGeneratedCost }
function TRadar.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedRadarCost(Weight, TechLevel, OwnerId);
end;
{ @end $6FF9B0 }

{ @routine $6FF9C4 TRadar_Improve }
procedure TRadar.Improve(Kind: TUpgradeKind);
begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    upgrade_minor: Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1) + SeededRandomIntRange(100, 200, Id * 254571)));
    upgrade_medium: Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1) + SeededRandomIntRange(300, 400, Id * 254571)));
    upgrade_major: Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1) + SeededRandomIntRange(400, 500, Id * 254571)));
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $6FF9C4 }

{ @routine $6FFB34 TRadar_HasStandardStats }
function TRadar.HasStandardStats: Boolean;
var ModuleIndex: Integer;
begin
  ModuleIndex := MicroModuleIndex;
  if (ModuleIndex = 0) or (MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_radar_range] = 0) then
    Result := CalculateGeneratedRange = Range
  else Result := CalculateGeneratedRange = Range - MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_radar_range];
end;
{ @end $6FFB34 }

{ @routine $6FFB88 TRadar_GetInfoText }
function TRadar.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Radar.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> owner_dominator then Text := LocalizedText('Items.Radar.Text')
    else Text := LocalizedText('Items.Radar.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $6FFB88 }

{ @routine $6FFD64 TRadar_ReplaceInfoTokens }
procedure TRadar.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_radar_range] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_radar_range] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_radar_range]), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_radar_range]), RedColorTag);
  StatBonus := Max(-Max(0, Range), GetStatBonus(bonus_radar_range));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonus_radar_range) - StatBonus, -(Range + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then BaseValue := Range
  else BaseValue := Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_radar_range];
  if HasStandardStats then ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedRange < BaseValue then
    ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText, ColorTag);
end;
{ @end $6FFD64 }

{ @routine $70026C TScaner_Init }
procedure TScaner.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := item_scanner;
  Self.Weight := Weight;
  TechLevel := Level;
  ScanPower := CalculateGeneratedScanPower;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $70026C }

{ @routine $7002A8 TScaner_SaveToBuffer }
procedure TScaner.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(ScanPower));
end;
{ @end $7002A8 }

{ @routine $7002D0 TScaner_LoadFromBuffer }
procedure TScaner.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  ScanPower := ShortInt(Buffer.GetByte);
  if (LoadedSaveVersion < 118) and (MicroModuleIndex <> 0) and
    (MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber = 122) then Inc(ScanPower);
end;
{ @end $7002D0 }

{ @routine $70031C TScaner_SaveToBlock }
procedure TScaner.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(ScanPower)); // 'Power'
end;
{ @end $70031C }

{ @routine $700438 TScaner_LoadFromBlock }
procedure TScaner.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  ScanPower := StrToInt(Block.GetParam(DecodeTextW('Prouwseor'))); // 'Power'
end;
{ @end $700438 }

{ @routine $70054C TScaner_CalculateGeneratedScanPower }
function TScaner.CalculateGeneratedScanPower: Integer;
begin
  Result := DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(TechLevel)) + 1;
end;
{ @end $70054C }

{ @routine $70056C CalculateGeneratedScanerCost }
function CalculateGeneratedScanerCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(ScannerBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $70056C }

{ @routine $7005FC TScaner_CalculateGeneratedCost }
function TScaner.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedScanerCost(Weight, TechLevel, OwnerId);
end;
{ @end $7005FC }

{ @routine $700610 TScaner_Improve }
procedure TScaner.Improve(Kind: TUpgradeKind);
begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    upgrade_minor: ScanPower := ScanPower + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + SeededRandomIntRange(1, 3, Id * 354571);
    upgrade_medium: ScanPower := ScanPower + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + SeededRandomIntRange(3, 5, Id * 354571);
    upgrade_major: ScanPower := ScanPower + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + SeededRandomIntRange(5, 7, Id * 354571);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $700610 }

{ @routine $700764 TScaner_HasStandardStats }
function TScaner.HasStandardStats: Boolean;
var ModuleIndex: Integer;
begin
  ModuleIndex := MicroModuleIndex;
  if (ModuleIndex = 0) or (MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_scanner_power] = 0) then
    Result := CalculateGeneratedScanPower = ScanPower
  else Result := CalculateGeneratedScanPower = ScanPower - MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_scanner_power];
end;
{ @end $700764 }

{ @routine $7007BC TScaner_GetInfoText }
function TScaner.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Scaner.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> owner_dominator then Text := LocalizedText('Items.Scaner.Text')
    else Text := LocalizedText('Items.Scaner.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $7007BC }

{ @routine $70099C TScaner_ReplaceInfoTokens }
procedure TScaner.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if MicroModuleIndex = 0 then StatBonus := 0
  else StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_scanner_power];
  BaseValue := Max(0, ScanPower - StatBonus);
  StatBonus := Max(0, ScanPower) - BaseValue;
  if StatBonus = 0 then BonusText := ''
  else if StatBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(StatBonus), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(StatBonus), RedColorTag);
  StatBonus := Max(-Max(0, ScanPower), GetStatBonus(bonus_scanner_power));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonus_scanner_power) - StatBonus, -(ScanPower + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if CalculateGeneratedScanPower = BaseValue then ReplaceTextToken(Text, '<Percent>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedScanPower < BaseValue then
    ReplaceTextToken(Text, '<Percent>', WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Percent>', WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText, ColorTag);
end;
{ @end $70099C }

{ @routine $700E70 TRepairRobot_Init }
procedure TRepairRobot.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := item_repair_robot;
  Self.Weight := Weight;
  TechLevel := Level;
  RepairPoints := CalculateGeneratedRepairPoints;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $700E70 }

{ @routine $700EAC TRepairRobot_SaveToBuffer }
procedure TRepairRobot.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(RepairPoints));
end;
{ @end $700EAC }

{ @routine $700ED4 TRepairRobot_LoadFromBuffer }
procedure TRepairRobot.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  RepairPoints := Buffer.GetByte;
  if LoadedSaveVersion < 118 then
  begin
    if TechLevel < 5 then Inc(RepairPoints, 5);
    if (MicroModuleIndex <> 0) and
      (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_repair_points] <> 0) then
      case MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber of
        122: Inc(RepairPoints, 7);
        21: Inc(RepairPoints, 4);
        7: Inc(RepairPoints, 3);
        204: Dec(RepairPoints, 5);
        14: Dec(RepairPoints, 5);
        110: Dec(RepairPoints, 5);
        16: Dec(RepairPoints, 3);
      end;
  end;
end;
{ @end $700ED4 }

{ @routine $700F90 TRepairRobot_SaveToBlock }
procedure TRepairRobot.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Raenplavikr'), IntToStr(RepairPoints)); // 'Repair'
end;
{ @end $700F90 }

{ @routine $7010B0 TRepairRobot_LoadFromBlock }
procedure TRepairRobot.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  RepairPoints := StrToInt(Block.GetParam(DecodeTextW('Raenplavikr'))); // 'Repair'
end;
{ @end $7010B0 }

{ @routine $7011C8 TRepairRobot_CalculateGeneratedRepairPoints }
function TRepairRobot.CalculateGeneratedRepairPoints: Byte;
begin
  Result := RepairRobotLevelPoints[TechLevel];
end;
{ @end $7011C8 }

{ @routine $7011D8 CalculateGeneratedRepairRobotCost }
function CalculateGeneratedRepairRobotCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(RepairRobotBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7011D8 }

{ @routine $701268 TRepairRobot_CalculateGeneratedCost }
function TRepairRobot.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedRepairRobotCost(Weight, TechLevel, OwnerId);
end;
{ @end $701268 }

{ @routine $70127C TRepairRobot_Improve }
procedure TRepairRobot.Improve(Kind: TUpgradeKind);
begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    upgrade_minor: RepairPoints := RepairPoints + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12)) + SeededRandomIntRange(1, 4, Id * 354571);
    upgrade_medium: RepairPoints := RepairPoints + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12)) + SeededRandomIntRange(4, 7, Id * 354571);
    upgrade_major: RepairPoints := RepairPoints + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12)) + SeededRandomIntRange(7, 10, Id * 354571);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $70127C }

{ @routine $7013D0 TRepairRobot_HasStandardStats }
function TRepairRobot.HasStandardStats: Boolean;
var ModuleIndex: Integer;
begin
  ModuleIndex := MicroModuleIndex;
  if (ModuleIndex = 0) or (MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_repair_points] = 0) then
    Result := CalculateGeneratedRepairPoints = RepairPoints
  else Result := CalculateGeneratedRepairPoints = RepairPoints - MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_repair_points];
end;
{ @end $7013D0 }

{ @routine $701428 TRepairRobot_GetInfoText }
function TRepairRobot.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.RepairRobot.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> owner_dominator then Text := LocalizedText('Items.RepairRobot.Text')
    else Text := LocalizedText('Items.RepairRobot.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $701428 }

{ @routine $701628 TRepairRobot_ReplaceInfoTokens }
procedure TRepairRobot.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_repair_points] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_repair_points] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_repair_points]), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_repair_points]), RedColorTag);
  StatBonus := Max(-Max(0, RepairPoints), GetStatBonus(bonus_repair_points));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonus_repair_points) - StatBonus, -(RepairPoints + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then BaseValue := RepairPoints
  else BaseValue := RepairPoints - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_repair_points];
  if HasStandardStats then ReplaceTextToken(Text, '<RecoverHitPoints>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedRepairPoints < BaseValue then
    ReplaceTextToken(Text, '<RecoverHitPoints>', WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<RecoverHitPoints>', WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText, ColorTag);
end;
{ @end $701628 }

{ @routine $701B4C TCargoHook_Create }
constructor TCargoHook.Create;
begin
  inherited Create;
end;
{ @end $701B4C }

{ @routine $701B84 TCargoHook_Init }
procedure TCargoHook.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := item_cargo_hook;
  Self.Weight := Weight;
  TechLevel := Level;
  PickupPower := CalculateGeneratedPickupPower;
  Range := CalculateGeneratedRange;
  MinPullSpeed := CalculateGeneratedMinPullSpeed;
  MaxPullSpeed := CalculateGeneratedMaxPullSpeed;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $701B84 }

{ @routine $701BE0 TCargoHook_SaveToBuffer }
procedure TCargoHook.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(PickupPower));
  Buffer.AddWideChar(WideChar(Range));
  Buffer.AddSingle(MinPullSpeed);
  Buffer.AddSingle(MaxPullSpeed);
end;
{ @end $701BE0 }

{ @routine $701C28 TCargoHook_LoadFromBuffer }
procedure TCargoHook.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  PickupPower := Buffer.GetWord;
  Range := Buffer.GetWord;
  MinPullSpeed := Buffer.GetSingle;
  MaxPullSpeed := Buffer.GetSingle;
end;
{ @end $701C28 }

{ @routine $701C74 TCargoHook_SaveToBlock }
procedure TCargoHook.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(PickupPower)); // 'Power'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // 'Radius'
  Block.AddParam(DecodeTextW('SapperenduMaidno'), FloatToStr(MinPullSpeed)); // 'SpeedMin'
  Block.AddParam(DecodeTextW('Suplexe2d3Moarxi'), FloatToStr(MaxPullSpeed)); // 'SpeedMax'
end;
{ @end $701C74 }

{ @routine $701EE4 TCargoHook_LoadFromBlock }
procedure TCargoHook.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  PickupPower := Word(StrToInt(Block.GetParam(DecodeTextW('Prouwseor')))); // 'Power'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // 'Radius'
  MinPullSpeed := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('SapperenduMaidno'))); // 'SpeedMin'
  MaxPullSpeed := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Suplexe2d3Moarxi'))); // 'SpeedMax'
end;
{ @end $701EE4 }

{ @routine $702100 TCargoHook_CalculateGeneratedPickupPower }
function TCargoHook.CalculateGeneratedPickupPower: Integer;
begin
  Result := CargoHookLevelStats[TechLevel].PickupPower;
end;
{ @end $702100 }

{ @routine $702114 TCargoHook_CalculateGeneratedRange }
function TCargoHook.CalculateGeneratedRange: Integer;
begin
  Result := CargoHookLevelStats[TechLevel].Range;
end;
{ @end $702114 }

{ @routine $702128 TCargoHook_CalculateGeneratedMinPullSpeed }
function TCargoHook.CalculateGeneratedMinPullSpeed: Single;
begin
  Result := CargoHookLevelStats[TechLevel].MinPullSpeed;
end;
{ @end $702128 }

{ @routine $702144 TCargoHook_CalculateGeneratedMaxPullSpeed }
function TCargoHook.CalculateGeneratedMaxPullSpeed: Single;
begin
  Result := CargoHookLevelStats[TechLevel].MaxPullSpeed;
end;
{ @end $702144 }

{ @routine $702160 CalculateGeneratedCargoHookCost }
function CalculateGeneratedCargoHookCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(CargoHookBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $702160 }

{ @routine $7021F0 TCargoHook_CalculateGeneratedCost }
function TCargoHook.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedCargoHookCost(Weight, TechLevel, OwnerId);
end;
{ @end $7021F0 }

{ @routine $702204 TCargoHook_Improve }
procedure TCargoHook.Improve(Kind: TUpgradeKind);
begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  if DetailImprovement = 0 then
    if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then DetailImprovement := 1
    else DetailImprovement := 2;
  if DetailImprovement = 1 then
    case Kind of
      upgrade_minor:
        begin
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12)) + SeededRandomIntRange(5, 10, Id * 254571);
          Inc(Range, SeededRandomIntRange(2, 4, Id * 354571));
        end;
      upgrade_medium:
        begin
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12)) + SeededRandomIntRange(10, 15, Id * 254571);
          Inc(Range, SeededRandomIntRange(5, 7, Id * 354571));
        end;
      upgrade_major:
        begin
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12)) + SeededRandomIntRange(15, 20, Id * 254571);
          Inc(Range, SeededRandomIntRange(8, 10, Id * 354571));
        end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      upgrade_minor:
        begin
          Inc(Range, SeededRandomIntRange(10, 15, Id * 354571));
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05)) + SeededRandomIntRange(2, 3, Id * 254571);
        end;
      upgrade_medium:
        begin
          Inc(Range, SeededRandomIntRange(15, 20, Id * 354571));
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05)) + SeededRandomIntRange(3, 4, Id * 254571);
        end;
      upgrade_major:
        begin
          Inc(Range, SeededRandomIntRange(20, 25, Id * 354571));
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05)) + SeededRandomIntRange(4, 5, Id * 254571);
        end;
    end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
  DetailImprovement := 0;
end;
{ @end $702204 }

{ @routine $702548 TCargoHook_HasStandardStats }
function TCargoHook.HasStandardStats: Boolean;
var ModuleIndex: Integer; StandardPower, StandardRange: Boolean;
begin
  ModuleIndex := MicroModuleIndex;
  if (ModuleIndex = 0) or (MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_hook_power] = 0) then
    StandardPower := CalculateGeneratedPickupPower = PickupPower
  else StandardPower := CalculateGeneratedPickupPower = PickupPower - MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_hook_power];
  ModuleIndex := MicroModuleIndex;
  if (ModuleIndex = 0) or (MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_hook_range] = 0) then
    StandardRange := CalculateGeneratedRange = Range
  else StandardRange := CalculateGeneratedRange = Range - MicroModuleTemplates[ModuleIndex - 1].StatBonuses[bonus_hook_range];
  Result := StandardPower and StandardRange;
end;
{ @end $702548 }

{ @routine $7025F0 TCargoHook_GetInfoText }
function TCargoHook.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.CargoHook.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> owner_dominator then Text := LocalizedText('Items.CargoHook.Text')
    else Text := LocalizedText('Items.CargoHook.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $7025F0 }

{ @routine $7027E4 TCargoHook_ReplaceInfoTokens }
procedure TCargoHook.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_power] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_power] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_power]), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_power]), RedColorTag);
  StatBonus := Max(-Max(0, PickupPower), GetStatBonus(bonus_hook_power));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonus_hook_power) - StatBonus, -(PickupPower + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then BaseValue := PickupPower
  else BaseValue := PickupPower - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_power];
  if CalculateGeneratedPickupPower = BaseValue then ReplaceTextToken(Text, '<PickUpSize>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedPickupPower < BaseValue then
    ReplaceTextToken(Text, '<PickUpSize>', WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<PickUpSize>', WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText, ColorTag);
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_range] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_range] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_range]), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_range]), RedColorTag);
  StatBonus := Max(-Max(0, Range), GetStatBonus(bonus_hook_range));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonus_hook_range) - StatBonus, -(Range + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then BaseValue := Range
  else BaseValue := Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_hook_range];
  if CalculateGeneratedRange = BaseValue then ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(BaseValue)) + BonusText, TextHighlightColorTag)
  else if CalculateGeneratedRange < BaseValue then
    ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText, ColorTag);
  ReplaceTextToken(Text, '<SpeedMin>', IntToStr(Round(CargoHookLevelStats[TechLevel].MinPullSpeed)), TextHighlightColorTag);
  ReplaceTextToken(Text, '<SpeedMax>', IntToStr(Round(CargoHookLevelStats[TechLevel].MaxPullSpeed)), TextHighlightColorTag);
end;
{ @end $7027E4 }

{ @routine $7032E8 TDefGenerator_Init }
procedure TDefGenerator.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := item_defense_generator;
  Self.Weight := Weight;
  TechLevel := Level;
  DamageFactor := CalculateGeneratedDamageFactor;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedDefGeneratorCost(Weight, Level, Owner);
  MicroModuleIndex := 0;
end;
{ @end $7032E8 }

{ @routine $703334 TDefGenerator_SaveToBuffer }
procedure TDefGenerator.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddSingle(DamageFactor);
end;
{ @end $703334 }

{ @routine $70335C TDefGenerator_LoadFromBuffer }
procedure TDefGenerator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  DamageFactor := Buffer.GetSingle;
end;
{ @end $70335C }

{ @routine $703384 TDefGenerator_SaveToBlock }
procedure TDefGenerator.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), FloatToStr(1 - DamageFactor)); // 'Power'
end;
{ @end $703384 }

{ @routine $7034B0 TDefGenerator_LoadFromBlock }
procedure TDefGenerator.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  DamageFactor := 1 - ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Prouwseor'))); // 'Power'
end;
{ @end $7034B0 }

{ @routine $7035AC TDefGenerator_CalculateGeneratedDamageFactor }
function TDefGenerator.CalculateGeneratedDamageFactor: Single;
begin
  Result := DefGeneratorLevelFactors[TechLevel];
end;
{ @end $7035AC }

{ @routine $7035C4 GetGeneratedDefenseDamageFactor }
function GetGeneratedDefenseDamageFactor(Level: TTechLevel): Double;
begin
  Result := DefGeneratorLevelFactors[Level];
end;
{ @end $7035C4 }

{ @routine $7035E0 DefenseDamageFactorToPercent }
function DefenseDamageFactorToPercent(Factor: Double): TPercent;
begin
  Result := Round((1 - Factor) * 100);
end;
{ @end $7035E0 }

{ @routine $703604 DefensePercentToDamageFactor }
function DefensePercentToDamageFactor(Percent: Integer): Double;
begin
  Result := 1 - Percent * 0.01;
end;
{ @end $703604 }

{ @routine $703638 CalculateGeneratedDefGeneratorCost }
function CalculateGeneratedDefGeneratorCost(Weight: Cardinal; Level: TTechLevel; Owner: TOwnerId): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(DefGeneratorBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $703638 }

{ @routine $7036C8 TDefGenerator_Improve }
procedure TDefGenerator.Improve(Kind: TUpgradeKind);
begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    upgrade_minor: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254573, 0.01, 0.03);
    upgrade_medium: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254572, 0.02, 0.04);
    upgrade_major: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254571, 0.03, 0.05);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $7036C8 }

{ @routine $70378C TDefGenerator_HasStandardStats }
function TDefGenerator.HasStandardStats: Boolean;
var ActualPercent, BonusPercent, GeneratedPercent: Integer;
begin
  ActualPercent := Round(DamageFactor * 100);
  GeneratedPercent := Round(CalculateGeneratedDamageFactor * 100);
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_defense] = 0) then
    Result := ActualPercent = GeneratedPercent
  else
  begin
    BonusPercent := Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_defense]);
    Result := ActualPercent + BonusPercent = GeneratedPercent;
  end;
end;
{ @end $70378C }

{ @routine $703800 TDefGenerator_GetInfoText }
function TDefGenerator.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.DefGenerator.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> owner_dominator then Text := LocalizedText('Items.DefGenerator.Text')
    else Text := LocalizedText('Items.DefGenerator.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $703800 }

{ @routine $703A04 TDefGenerator_ReplaceInfoTokens }
procedure TDefGenerator.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  ModuleBonus, ActualFactorPercent, GeneratedFactorPercent, StatBonus: Integer;
  DisplayPercent: Byte;
begin
  ModuleBonus := 0;
  if MicroModuleIndex <> 0 then ModuleBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_defense];
  DisplayPercent := DefenseDamageFactorToPercent(DamageFactor);
  if ModuleBonus = 0 then BonusText := ''
  else if ModuleBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), GreenColorTag)
  else BonusText := WrapTextInColor(IntToStr(ModuleBonus), RedColorTag);
  StatBonus := Max(-Max(0, DisplayPercent), GetStatBonus(bonus_defense));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonus_defense) - StatBonus, -(DisplayPercent + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);

  ActualFactorPercent := Round(DamageFactor * 100);
  GeneratedFactorPercent := Round(CalculateGeneratedDamageFactor * 100);
  if (MicroModuleIndex <> 0) and (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_defense] <> 0) then
    Inc(ActualFactorPercent, Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_defense]));
  if HasStandardStats then ReplaceTextToken(Text, '<Percent>', WideString(IntToStr(DisplayPercent - ModuleBonus)) + BonusText, ColorTag)
  else if ActualFactorPercent < GeneratedFactorPercent then
    ReplaceTextToken(Text, '<Percent>', WrapTextInColor(IntToStr(DisplayPercent - ModuleBonus), GreenColorTag) + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Percent>', WrapTextInColor(IntToStr(DisplayPercent - ModuleBonus), RedColorTag) + BonusText, ColorTag);
end;
{ @end $703A04 }

{ @routine $703F4C TWeapon_Destroy }
destructor TWeapon.Destroy;
begin
  inherited Destroy;
end;
{ @end $703F4C }

{ @routine $703F74 TWeapon_Init }
procedure TWeapon.Init(ItemType: TItemType; Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  Target := nil;
  Self.ItemType := ItemType;
  Self.Weight := Weight;
  TechLevel := Level;
  Range := CalculateGeneratedRange;
  MinDamage := CalculateGeneratedMinDamage;
  MaxDamage := CalculateGeneratedMaxDamage;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedWeaponCost(GetWeaponInfo, Weight, Level, Owner);
  if GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
  begin
    AmmoCapacity := CalculateGeneratedAmmoCapacity;
    Ammo := AmmoCapacity;
  end;
  MicroModuleIndex := 0;
end;
{ @end $703F74 }

{ @routine $704008 TCustomWeapon_InitCustom }
procedure TCustomWeapon.InitCustom(Info: PWeaponInfo; Equipped: Boolean; Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  Target := nil;
  ItemType := item_custom_weapon;
  CustomInfo := Info;
  if Equipped then Equip else Unequip;
  Self.Weight := Weight;
  TechLevel := Level;
  Range := CalculateGeneratedRange;
  MinDamage := CalculateGeneratedMinDamage;
  MaxDamage := CalculateGeneratedMaxDamage;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedWeaponCost(Info, Weight, Level, Owner);
  if GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
  begin
    AmmoCapacity := CalculateGeneratedAmmoCapacity;
    Ammo := AmmoCapacity;
  end;
  MicroModuleIndex := 0;
end;
{ @end $704008 }

{ @routine $7040B8 TWeapon_SaveToBuffer }
procedure TWeapon.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Range));
  Buffer.AddIntegerValue(MinDamage);
  Buffer.AddIntegerValue(MaxDamage);
  if Target = nil then Buffer.AddAnsiChar(#0)
  else if Target is TShip then
  begin
    Buffer.AddAnsiChar(#1);
    Buffer.AddDWord((Target as TShip).Id);
  end
  else if Target is TItem then
  begin
    Buffer.AddAnsiChar(#2);
    Buffer.AddDWord((Target as TItem).Id);
  end
  else if Target is TAsteroid then
  begin
    Buffer.AddAnsiChar(#3);
    Buffer.AddDWord((Target as TAsteroid).Id);
  end
  else if Target is TMissile then
  begin
    Buffer.AddAnsiChar(#4);
    Buffer.AddDWord((Target as TMissile).Id);
  end
  else Buffer.AddAnsiChar(#0);
  if GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
  begin
    Buffer.AddDWord(Ammo);
    Buffer.AddDWord(AmmoCapacity);
  end;
end;
{ @end $7040B8 }

{ @routine $70420C TCustomWeapon_SaveToBuffer }
procedure TCustomWeapon.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(CustomInfo.ConfigName);
  inherited SaveToBuffer(Buffer);
end;
{ @end $70420C }

{ @routine $704230 TWeapon_LoadFromBuffer }
procedure TWeapon.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Range := Buffer.GetWord;
  if LoadedSaveVersion >= 115 then
  begin
    MinDamage := Buffer.GetInt32;
    MaxDamage := Buffer.GetInt32;
  end
  else
  begin
    MinDamage := Buffer.GetByte;
    MaxDamage := Buffer.GetByte;
  end;
  LoadedTargetKind := TWeaponTargetKind(Buffer.GetByte);
  if LoadedTargetKind = weapon_target_none then Target := nil else Target := TObject(Buffer.GetUInt32);
  if GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
  begin
    Ammo := Buffer.GetUInt32;
    AmmoCapacity := Buffer.GetUInt32;
    if (LoadedSaveVersion < 118) and (MicroModuleIndex <> 0) and
      (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_missile_damage] <> 0) then
      case MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber of
        204: Inc(MaxDamage, 10);
        210: Inc(MaxDamage, 15);
        216: Inc(MaxDamage, 15);
        2: Inc(MaxDamage, 4);
        18: Inc(MaxDamage, 4);
        119: Dec(MaxDamage, 2);
      else
        Inc(MaxDamage, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_missile_damage] div 2);
      end;
  end;
end;
{ @end $704230 }

{ @routine $704384 TCustomWeapon_LoadFromBuffer }
procedure TCustomWeapon.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  CustomInfo := TGalaxy(Galaxy).RequireCustomWeaponInfo(Buffer.ReadWideString);
  inherited LoadFromBuffer(Buffer, Galaxy);
end;
{ @end $704384 }

{ @routine $7043E8 TWeapon_SaveToBlock }
procedure TWeapon.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // 'Radius'
  Block.AddParam(DecodeTextW('MailnoDrakmoarglen'), IntToStr(MinDamage)); // 'MinDamage'
  Block.AddParam(DecodeTextW('MianxaDoarmuavgre'), IntToStr(MaxDamage)); // 'MaxDamage'
  Block.AddParam(DecodeTextW('Almamuo'), IntToStr(Ammo)); // 'Ammo'
  Block.AddParam(DecodeTextW('MraixoAsmImGod'), IntToStr(AmmoCapacity)); // 'MaxAmmo'
end;
{ @end $7043E8 }

{ @routine $7046B4 TCustomWeapon_SaveToBlock }
procedure TCustomWeapon.SaveToBlock(Block: TBlockParEC);
begin
  Block.AddParam(DecodeTextW('CrulsitroimaTryspie'), CustomInfo.ConfigName); // 'CustomType'
  inherited SaveToBlock(Block);
end;
{ @end $7046B4 }

{ @routine $704744 TWeapon_LoadFromBlock }
procedure TWeapon.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // 'Radius'
  MinDamage := StrToInt(Block.GetParam(DecodeTextW('MailnoDrakmoarglen'))); // 'MinDamage'
  MaxDamage := StrToInt(Block.GetParam(DecodeTextW('MianxaDoarmuavgre'))); // 'MaxDamage'
  Ammo := StrToInt(Block.GetParam(DecodeTextW('Almamuo'))); // 'Ammo'
  AmmoCapacity := StrToInt(Block.GetParam(DecodeTextW('MraixoAsmImGod'))); // 'MaxAmmo'
end;
{ @end $704744 }

{ @routine $704A04 TCustomWeapon_LoadFromBlock }
procedure TCustomWeapon.LoadFromBlock(Block: TBlockParEC);
begin
  CustomInfo := Galaxy.RequireCustomWeaponInfo(Block.GetParam(DecodeTextW('CrulsitroimaTryspie'))); // 'CustomType'
  inherited LoadFromBlock(Block);
end;
{ @end $704A04 }

{ @routine $704AAC TWeapon_ResolveLoadedReferences }
procedure TWeapon.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  if LoadedTargetKind = weapon_target_ship then Target := Galaxy.IdToShip(Cardinal(Target), True) as TShip
  else if LoadedTargetKind = weapon_target_item then Target := TObject(Galaxy.IdToItem(Cardinal(Target), True)) as TItem
  else if LoadedTargetKind = weapon_target_asteroid then Target := TObject(Galaxy.IdToAsteroid(Cardinal(Target))) as TAsteroid
  else if LoadedTargetKind = weapon_target_missile then Target := TObject(Galaxy.IdToMissile(Cardinal(Target))) as TMissile;
end;
{ @end $704AAC }

{ @routine $704B40 TWeapon_ClearReferences }
procedure TWeapon.ClearReferences;
begin
  inherited ClearReferences;
  LoadedTargetKind := weapon_target_none;
  Target := nil;
end;
{ @end $704B40 }

{ @routine $704B58 TWeapon_Unequip }
procedure TWeapon.Unequip;
begin
  inherited Unequip;
  Target := nil;
end;
{ @end $704B58 }

{ @routine $704B6C TWeapon_CalculateGeneratedAmmoCapacity }
function TWeapon.CalculateGeneratedAmmoCapacity: Integer;
begin
  Result := TechLevel * 5 + 25;
end;
{ @end $704B6C }

{ @routine $704B78 TWeapon_CalculateGeneratedMinDamage }
function TWeapon.CalculateGeneratedMinDamage: Integer;
begin
  Result := Round(GetWeaponInfo.MinDamage * GetWeaponInfo.DamageScaleByLevel[TechLevel]);
end;
{ @end $704B78 }

{ @routine $704BAC TWeapon_CalculateGeneratedMaxDamage }
function TWeapon.CalculateGeneratedMaxDamage: Integer;
begin
  Result := Round(GetWeaponInfo.MaxDamage * GetWeaponInfo.DamageScaleByLevel[TechLevel]);
end;
{ @end $704BAC }

{ @routine $704BE0 TWeapon_CalculateGeneratedRange }
function TWeapon.CalculateGeneratedRange: Integer;
begin
  Result := Round(GetWeaponInfo.AverageRange * WeaponRangeLevelFactors[TechLevel]);
end;
{ @end $704BE0 }

{ @routine $704C04 TWeapon_CalculateStandardMaxDamage }
function TWeapon.CalculateStandardMaxDamage: Integer;
var BonusKind: TEquipmentBonusKind;
begin
  Result := CalculateGeneratedMaxDamage;
  BonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags)].BonusKind;
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]);
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]);
end;
{ @end $704C04 }

{ @routine $704C74 TWeapon_CalculateStandardRange }
function TWeapon.CalculateStandardRange: Integer;
begin
  Result := CalculateGeneratedRange;
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_weapon_range]);
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonus_weapon_range]);
end;
{ @end $704C74 }

{ @routine $704CB4 CalculateGeneratedWeaponCost }
function CalculateGeneratedWeaponCost(Info: PWeaponInfo; Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;
var LevelCost: Single;
begin
  LevelCost := RemapClamped(Level, 1, 8, 1, 4) * Info.CostFactor;
  Result := RoundAndTruncateToTens(RemapClamped(Info.AverageSize / Weight, 0.5, 2, 1, 2) *
    LevelCost * 250 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $704CB4 }

{ @routine $704D68 TWeapon_Improve }
procedure TWeapon.Improve(Kind: TUpgradeKind);
var CurrentDamage, BaseDamage, ModuleDamage: Integer; Info: PWeaponInfo;
begin
  if Kind = upgrade_random then Kind := TUpgradeKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  Info := GetWeaponInfo;
  if DetailImprovement = 0 then
    if Info.ShotType in [shot_torpedo..shot_rocket] then DetailImprovement := 1
    else if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then DetailImprovement := 1
    else DetailImprovement := 2;
  CurrentDamage := MaxDamage;
  BaseDamage := Info.MaxDamage;
  if (Info.ShotType in [shot_missile..shot_rocket]) and (MicroModuleIndex > 0) and not Galaxy.AreOldMissileBonusesEnabled then
  begin
    ModuleDamage := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[WeaponDamageClasses[ClassifyWeaponDamageFlags(Info.DamageFlags)].BonusKind];
    CurrentDamage := Ceil(CurrentDamage - (1 - 1 / GetShotCount) * ModuleDamage);
  end;
  if DetailImprovement = 1 then
    case Kind of
      upgrade_minor:
        begin
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.1, 0.2)) + 1;
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.02, 0.04)));
        end;
      upgrade_medium:
        begin
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.2, 0.3)) + 2;
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.03, 0.04)));
        end;
      upgrade_major:
        begin
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.3, 0.4)) + 3;
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.04, 0.06)));
        end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      upgrade_minor:
        begin
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.04, 0.07) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.03, 0.06)));
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.03, 0.06) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.05, 0.1)) + 1;
        end;
      upgrade_medium:
        begin
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.04, 0.07) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.06, 0.08)));
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.03, 0.06) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.1, 0.15)) + 2;
        end;
      upgrade_major:
        begin
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.04, 0.07) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.08, 0.11)));
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.03, 0.06) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.15, 0.2)) + 3;
        end;
    end
  else if DetailImprovement = 3 then
    Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 976247, 0.12, 0.18) + (Sqrt(Sqr(Info.AverageRange) + 90000) - Info.AverageRange)));
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
  DetailImprovement := 0;
end;
{ @end $704D68 }

{ @routine $705428 TWeapon_HasStandardStats }
function TWeapon.HasStandardStats: Boolean;
begin
  Result := (CalculateStandardMaxDamage = MaxDamage) and (CalculateStandardRange = Range);
end;
{ @end $705428 }

{ @routine $70544C TWeapon_GetDisplayName }
function TWeapon.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if (SpecialModuleIndex <> 0) and
    (MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace <> '') then
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].Name
  else Result := GetShortName;
  if HasMicroModule then Result := Result + ' ' + WrapTextInColor(GetMicroModuleQuotedName, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;
{ @end $70544C }

{ @routine $705540 TWeapon_GetShortName }
function TWeapon.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Weapon.Name.' + GetConfigName);
end;
{ @end $705540 }

{ @routine $7055EC TWeapon_GetInfoText }
function TWeapon.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text, LevelText: WideString; DamageClass: TWeaponDamageClass;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if Text = '' then Text := LocalizedText('Items.Weapon.Text.' + GetConfigName);
  DamageClass := ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags);
  ReplaceInfoTokens(Text, ColorTag, Ship);
  LevelText := ' (' + GetLevelLetter + ')';
  Text := Text + #13#10 + FormatText1(LocalizedText('Items.Weapon.AddText'), ColorTag, '<WeaponType>',
    LocalizedText('Items.Weapon.Type' + WeaponDamageClasses[DamageClass].Name) + LevelText);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $7055EC }

{ @routine $705870 TWeapon_ReplaceInfoTokens }
procedure TWeapon.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  UnusedNativeText: WideString; // Native initializes/finalizes this extra string slot without reading it.
  ModuleBonus, EffectiveBonus, BaseDamage, I: Integer;
  DamageClass: TWeaponDamageClass;
  ExpectedRange, CurrentRange, BaseRange, ExpectedDamage: Integer;
  Entry: PExtraSpecial;
  ShipBonus: Integer;
begin
  if Cardinal(GetDamageFlags) and damage_no_spread_mask <> 0 then // Native flag displays the maximum as the minimum too.
    ReplaceTextToken(Text, '<MinDamage>', IntToStr(Max(MaxDamage, MinDamage)), ColorTag)
  else ReplaceTextToken(Text, '<MinDamage>', IntToStr(MinDamage), ColorTag);
  ModuleBonus := 0;
  DamageClass := ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags);
  if MicroModuleIndex <> 0 then Inc(ModuleBonus, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[WeaponDamageClasses[DamageClass].BonusKind]);
  BonusText := '';
  BaseDamage := Max(MaxDamage, MinDamage) - ModuleBonus;
  ExpectedDamage := CalculateGeneratedMaxDamage;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(BaseDamage, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[WeaponDamageClasses[DamageClass].BonusKind] * Entry.Count);
    end;
  if ModuleBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), GreenColorTag);
  if ModuleBonus < 0 then BonusText := WrapTextInColor(IntToStr(ModuleBonus), RedColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then ShipBonus := TShip(Ship).GetTotalStatBonus(WeaponDamageClasses[DamageClass].BonusKind)
  else ShipBonus := 0;
  if ShipBonus <> 0 then
    if ShipBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(ShipBonus) + ')', EquipmentBonusColorTag)
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(ShipBonus) + ')', EquipmentBonusColorTag);
  if BaseDamage = ExpectedDamage then ReplaceTextToken(Text, '<MaxDamage>', IntToStr(BaseDamage), ColorTag)
  else if BaseDamage > ExpectedDamage then ReplaceTextToken(Text, '<MaxDamage>', WrapTextInColor(IntToStr(BaseDamage), GreenColorTag), ColorTag)
  else ReplaceTextToken(Text, '<MaxDamage>', WrapTextInColor(IntToStr(BaseDamage), RedColorTag), ColorTag);
  ReplaceTextToken(Text, '<Bonus>', BonusText, ColorTag);
  if GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
  begin
    ModuleBonus := 0;
    if ExtraSpecials <> nil then
      for I := 0 to ExtraSpecials.Count - 1 do
      begin
        Entry := ExtraSpecials[I];
        Inc(ModuleBonus, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonus_weapon_range] * Entry.Count);
      end;
    ExpectedRange := CalculateGeneratedRange + ModuleBonus;
    CurrentRange := Range + ModuleBonus;
    if MicroModuleIndex <> 0 then Inc(ModuleBonus, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_weapon_range])
    else ModuleBonus := 0;
    BaseRange := CurrentRange - ModuleBonus;
    EffectiveBonus := Max(CurrentRange, GetWeaponInfo.MissileRange) - Max(BaseRange, GetWeaponInfo.MissileRange);
    if ModuleBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(EffectiveBonus), GreenColorTag)
    else if ModuleBonus < 0 then
      if EffectiveBonus < 0 then BonusText := WrapTextInColor(IntToStr(EffectiveBonus), RedColorTag)
      else BonusText := WrapTextInColor('-0', RedColorTag)
    else BonusText := '';
    if (Ship <> nil) and (EquippedFlag <> 0) then ShipBonus := TShip(Ship).GetTotalStatBonus(bonus_weapon_range)
    else ShipBonus := 0;
    EffectiveBonus := Max(CurrentRange + ShipBonus, GetWeaponInfo.MissileRange) - Max(CurrentRange, GetWeaponInfo.MissileRange);
    if ShipBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(EffectiveBonus) + ')', EquipmentBonusColorTag)
    else if ShipBonus < 0 then
      if EffectiveBonus < 0 then BonusText := BonusText + WrapTextInColor(IntToStr(EffectiveBonus) + ')', EquipmentBonusColorTag) // Native negative branch omits the opening parenthesis.
      else BonusText := BonusText + WrapTextInColor('(-0)', EquipmentBonusColorTag);
    if BaseRange = ExpectedRange then ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange))) + BonusText, ColorTag)
    else if BaseRange > ExpectedRange then ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange)), GreenColorTag) + BonusText, ColorTag)
    else ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange)), RedColorTag) + BonusText, ColorTag);
    ReplaceTextToken(Text, '<Count>', IntToStr(Ammo), ColorTag);
    ReplaceTextToken(Text, '<MaxCount>', IntToStr(AmmoCapacity), ColorTag);
    ReplaceTextToken(Text, '<CntShots>', IntToStr(GetShotCount), ColorTag);
  end
  else
  begin
    ModuleBonus := 0;
    if ExtraSpecials <> nil then
      for I := 0 to ExtraSpecials.Count - 1 do
      begin
        Entry := ExtraSpecials[I];
        Inc(ModuleBonus, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonus_weapon_range] * Entry.Count);
      end;
    ExpectedRange := CalculateGeneratedRange + ModuleBonus;
    CurrentRange := Range + ModuleBonus;
    if MicroModuleIndex <> 0 then Inc(ModuleBonus, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_weapon_range])
    else ModuleBonus := 0;
    BaseRange := CurrentRange - ModuleBonus;
    if ModuleBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), GreenColorTag)
    else if ModuleBonus < 0 then BonusText := WrapTextInColor(IntToStr(ModuleBonus), RedColorTag)
    else BonusText := '';
    if (Ship <> nil) and (EquippedFlag <> 0) then ShipBonus := TShip(Ship).GetTotalStatBonus(bonus_weapon_range)
    else ShipBonus := 0;
    if ShipBonus <> 0 then
      if ShipBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(ShipBonus), EquipmentBonusColorTag)
      else BonusText := BonusText + WrapTextInColor(IntToStr(ShipBonus), EquipmentBonusColorTag);
    if BaseRange = ExpectedRange then ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(BaseRange)) + BonusText, ColorTag)
    else if BaseRange > ExpectedRange then ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseRange), GreenColorTag) + BonusText, ColorTag)
    else ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseRange), RedColorTag) + BonusText, ColorTag);
  end;
  ReplaceTextToken(Text, '<CntAttacks>', IntToStr(GetAttackCount), ColorTag);
end;
{ @end $705870 }

{ @routine $706824 TWeapon_GetDescriptionText }
function TWeapon.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.TWeapon.Description.' + GetConfigName);
end;
{ @end $706824 }

{ @routine $7068C8 TWeapon_GetShotDelayFactor }
function TWeapon.GetShotDelayFactor: Double;
var SpeedPercent, I: Integer; Entry: PExtraSpecial;
begin
  SpeedPercent := GetWeaponInfo.ShotSpeedPercent;
  if MicroModuleIndex <> 0 then Inc(SpeedPercent, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_shot_delay_reduction]);
  if SpecialModuleIndex <> 0 then Inc(SpeedPercent, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonus_shot_delay_reduction]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(SpeedPercent, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonus_shot_delay_reduction] * Entry.Count);
    end;
  SpeedPercent := Max(0, Min(100, SpeedPercent));
  Result := 1 - SpeedPercent * 0.01;
end;
{ @end $7068C8 }

{ @routine $706990 TWeapon_GetBitmapResourceName }
function TWeapon.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0) and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType];
end;
{ @end $706990 }

{ @routine $706AA4 TCustomWeapon_GetBitmapResourceName }
function TCustomWeapon.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0) and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result := 'Bm.Items.' + GiResourceSuffix + 'W' + GetConfigName + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else Result := 'Bm.Items.' + GiResourceSuffix + 'W' + GetConfigName;
end;
{ @end $706AA4 }

{ @routine $706BCC TWeapon_NeedsAmmo }
function TWeapon.NeedsAmmo: Boolean;
begin
  Result := False;
  if GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
    if Ammo < AmmoCapacity then Result := True;
end;
{ @end $706BCC }

{ @routine $706BF4 TWeapon_CalculateAmmoRefillCost }
function TWeapon.CalculateAmmoRefillCost: Integer;
var MissingAmmo: Integer; UnitCost: Single;
begin
  Result := 0;
  if not (GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) then Exit;
  if Ammo < AmmoCapacity then
  begin
    MissingAmmo := AmmoCapacity - Ammo;
    UnitCost := Galaxy.ScaleIntByTechLevel(10, 100);
    Result := Round(MissingAmmo * UnitCost);
  end;
end;
{ @end $706BF4 }

{ @routine $706C58 TWeapon_GetShotPalette }
function TWeapon.GetShotPalette: Integer;
begin
  if (SpecialModuleIndex = 0) or (MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual = -1) then
    Result := GetWeaponInfo.DefaultPalette
  else Result := MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual;
end;
{ @end $706C58 }

{ @routine $706C94 TWeapon_GetDamageFlags }
function TWeapon.GetDamageFlags: TDamageFlagSet;
var I: Integer; Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.DamageFlags;
  if SpecialModuleIndex <> 0 then
    Result := Result + MicroModuleTemplates[SpecialModuleIndex - 1].WeaponDamageFlags;
  if MicroModuleIndex <> 0 then
    Result := Result + MicroModuleTemplates[MicroModuleIndex - 1].WeaponDamageFlags;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Result := Result + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].WeaponDamageFlags;
    end;
end;
{ @end $706C94 }

{ @routine $706D1C TWeapon_GetShotCount }
function TWeapon.GetShotCount: Integer;
var I: Integer; Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.ShotCount;
  if not (GetWeaponInfo.ShotType in [shot_chain, shot_missile, shot_rocket]) then Exit;
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonus_shot_count]);
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_shot_count]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(Result, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonus_shot_count] * Entry.Count);
    end;
  Result := Max(Result, 1);
end;
{ @end $706D1C }

{ @routine $706DC4 TWeapon_GetAttackCount }
function TWeapon.GetAttackCount: Integer;
var I: Integer; Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.AttackCount;
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonus_attack_count]);
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_attack_count]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(Result, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonus_attack_count] * Entry.Count);
    end;
  Result := Max(Result, 1);
end;
{ @end $706DC4 }

{ @routine $706E50 TWeapon_GetWeaponInfo }
function TWeapon.GetWeaponInfo: PWeaponInfo;
begin
  Result := @WeaponInfos[ItemType];
end;
{ @end $706E50 }

{ @routine $706E6C TCustomWeapon_GetWeaponInfo }
function TCustomWeapon.GetWeaponInfo: PWeaponInfo;
begin
  Result := CustomInfo;
end;
{ @end $706E6C }

{ @routine $706E74 TWeapon_GetConfigName }
function TWeapon.GetConfigName: WideString;
begin
  Result := IntToStr(Ord(ItemType) - Ord(item_industrial_laser) + 1);
end;
{ @end $706E74 }

{ @routine $706ECC TCustomWeapon_GetConfigName }
function TCustomWeapon.GetConfigName: WideString;
begin
  Result := CustomInfo.ConfigName;
end;
{ @end $706ECC }

{ @routine $706EE8 TGoods_Init }
procedure TGoods.Init(ItemType: TItemType; Quantity: Integer);
begin
  Self.ItemType := ItemType;
  Self.Quantity := Quantity;
  Weight := Quantity;
  Cost := GoodsMarket[Ord(Self.ItemType)].AveragePrice * Self.Quantity;
  NaturalFlag := False;
end;
{ @end $706EE8 }

{ @routine $706F10 TGoods_SaveToBuffer }
procedure TGoods.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Quantity);
  Buffer.AddBoolean(NaturalFlag);
end;
{ @end $706F10 }

{ @routine $706F38 TGoods_LoadFromBuffer }
procedure TGoods.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Quantity := Buffer.GetInt32;
  NaturalFlag := Buffer.GetBoolean;
end;
{ @end $706F38 }

{ @routine $706F60 TGoods_GetDisplayName }
function TGoods.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := GoodsMarket[Ord(ItemType)].DisplayName;
end;
{ @end $706F60 }

{ @routine $706F9C TGoods_GetInfoText }
function TGoods.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := LocalizedText('Items.Goods.Text' + IntToStr(Ord(ItemType) + 1));
  Result := WrapTextInColor(GetDisplayName, ColorTag) + Text;
end;
{ @end $706F9C }

{ @routine $707084 TGoods_GetDescriptionText }
function TGoods.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Goods.Description.' + IntToStr(Ord(ItemType) + 1));
end;
{ @end $707084 }

{ @routine $707128 TGoods_GetBitmapResourceName }
function TGoods.GetBitmapResourceName: WideString;
begin
  Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType];
end;
{ @end $707128 }

{ @routine $7071A4 TCountableItem_SaveToBuffer }
procedure TCountableItem.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(StackCount);
  Buffer.AddBoolean(Boolean(DropFlag));
end;
{ @end $7071A4 }

{ @routine $7071CC TCountableItem_LoadFromBuffer }
procedure TCountableItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  StackCount := Buffer.GetInt32;
  DropFlag := Byte(Buffer.GetBoolean);
end;
{ @end $7071CC }

{ @routine $7071F4 TCountableItem_Init }
procedure TCountableItem.Init(ConfigName: WideString; Count: Integer; DropFlag: Byte);
begin
  ItemType := item_stackable_misc;
  ConfigBlockName := ConfigName;
  Self.DropFlag := DropFlag;
  StackCount := Count;
  Weight := GetUnitSize * Count;
  Cost := Count;
  OwnerId := owner_uninhabited;
  EquippedFlag := 0;
  ConditionPercent := 0;
  BrokenFlag := 1;
end;
{ @end $7071F4 }

{ @routine $707278 TCountableItem_GetDisplayName }
function TCountableItem.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Name');
end;
{ @end $707278 }

{ @routine $707334 TCountableItem_GetInfoText }
function TCountableItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Text');
  ReplaceTextToken(Result, '<N>', IntToStr(StackCount), ColorTag);
  if ScriptItem <> nil then Result := TScriptItem(ScriptItem).FormatDataText(Result, ColorTag);
end;
{ @end $707334 }

{ @routine $70745C TCountableItem_GetDescriptionText }
function TCountableItem.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Description');
end;
{ @end $70745C }

{ @routine $707510 TCountableItem_GetBitmapResourceName }
function TCountableItem.GetBitmapResourceName: WideString;
begin
  if StackCount <= 19 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '0_'
  else if StackCount <= 39 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '1_'
  else if StackCount <= 59 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '2_'
  else if StackCount <= 79 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '3_'
  else Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '4_';
end;
{ @end $707510 }

{ @routine $707680 TCountableItem_GetUnitSize }
function TCountableItem.GetUnitSize: Integer;
var Block: TBlockParEC;
begin
  Result := 1;
  if ItemType <> item_nodes then
  begin
    Block := LanguageDataConfig.GetBlockByPath('Items.CustomCountables.' + ConfigBlockName);
    if Block.CountParams('UnitSize') > 0 then Result := ExtractDigitsToIntW(Block.GetParam('UnitSize'));
  end;
end;
{ @end $707680 }

{ @routine $707764 TCountableItem_Split }
function TCountableItem.Split(Count: Integer): TCountableItem;
var
  SplitCount, I: Integer;
  NewScriptItem, OriginalScriptItem: TScriptItem;
begin
  SplitCount := Min(StackCount, Count);
  if ItemType = item_nodes then
  begin
    Result := TProtoplasm.Create;
    (Result as TProtoplasm).Init(SplitCount, 0);
  end
  else
  begin
    Result := TCountableItem.Create;
    Result.Init(ConfigBlockName, SplitCount, 0);
  end;
  Result.Cost := Max(1, Round(Cost / StackCount * SplitCount));
  Cost := Max(1, Cost - Result.Cost);
  Dec(StackCount, SplitCount);
  Weight := GetUnitSize * StackCount;
  Result.OwnerId := OwnerId;
  Result.DominatorSeries := DominatorSeries;
  Result.CustomFaction := CustomFaction;
  if (ScriptItem <> nil) and (TScriptItem(ScriptItem).Name = '') then
  begin
    OriginalScriptItem := TScriptItem(ScriptItem);
    NewScriptItem := nil;
    for I := 0 to OriginalScriptItem.Script.Items.Count - 1 do
    begin
      NewScriptItem := OriginalScriptItem.Script.Items[I];
      if (NewScriptItem.Name = '') and (NewScriptItem.Item = nil) then Break;
      NewScriptItem := nil;
    end;
    if NewScriptItem = nil then
    begin
      NewScriptItem := TScriptItem.Create;
      NewScriptItem.Script := OriginalScriptItem.Script;
      OriginalScriptItem.Script.Items.Add(NewScriptItem);
    end;
    NewScriptItem.Item := Result;
    Result.ScriptItem := NewScriptItem;
    if NewScriptItem.ActionCode <> nil then NewScriptItem.ActionCode.Free;
    NewScriptItem.ActionCode := nil;
    NewScriptItem.ActionCodeInitialized := False;
    NewScriptItem.OnActionText := OriginalScriptItem.OnActionText;
    NewScriptItem.OnUseText := OriginalScriptItem.OnUseText;
    NewScriptItem.CanSell := OriginalScriptItem.CanSell;
    NewScriptItem.Data[1] := OriginalScriptItem.Data[1];
    NewScriptItem.Data[2] := OriginalScriptItem.Data[2];
    NewScriptItem.Data[3] := OriginalScriptItem.Data[3];
    NewScriptItem.TextData1 := OriginalScriptItem.TextData1;
    NewScriptItem.TextData2 := OriginalScriptItem.TextData2;
    NewScriptItem.TextData3 := OriginalScriptItem.TextData3;
  end;
end;
{ @end $707764 }

{ @routine $707954 TCountableItem_CanMerge }
function TCountableItem.CanMerge(Other: TObject): Boolean;
var OtherStack: TCountableItem;
begin
  Result := False;
  if not (Other is TCountableItem) then Exit;
  if Self = Other then Exit else
  if TItem(Other).ItemType <> ItemType then Exit;
  OtherStack := TCountableItem(Other);
  if Self is TProtoplasm then
    if OtherStack.DominatorSeries <> DominatorSeries then Exit;
  if ConfigBlockName = OtherStack.ConfigBlockName then Result := True;
end;
{ @end $707954 }

{ @routine $7079AC TCountableItem_Merge }
function TCountableItem.Merge(Other: TObject): Boolean;
var OtherStack: TCountableItem;
begin
  Result := False;
  if CanMerge(Other) then
  begin
    OtherStack := TCountableItem(Other);
    Inc(StackCount, OtherStack.StackCount);
    Weight := GetUnitSize * StackCount;
    Inc(Cost, OtherStack.Cost);
    Result := True;
  end;
end;
{ @end $7079AC }

{ @routine $7079E4 TProtoplasm_Init }
procedure TProtoplasm.Init(Count: Integer; DropFlag: Byte);
begin
  ItemType := item_nodes;
  StackCount := Count;
  Weight := Count;
  Cost := Count * 10;
  OwnerId := owner_dominator;
  Self.DropFlag := DropFlag;
  EquippedFlag := 0;
  ConditionPercent := 0;
  BrokenFlag := 1;
end;
{ @end $7079E4 }

{ @routine $707A10 TProtoplasm_GetDisplayName }
function TProtoplasm.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Nod.Name') + ' ' + LocalizedText('Items.Nod.S' + IntToStr(Ord(DominatorSeries)));
end;
{ @end $707A10 }

{ @routine $707B14 TProtoplasm_GetInfoText }
function TProtoplasm.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Nod.Text');
  ReplaceTextToken(Result, '<N>', IntToStr(StackCount), ColorTag);
end;
{ @end $707B14 }

{ @routine $707BD4 TProtoplasm_GetDescriptionText }
function TProtoplasm.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Nod.Description');
end;
{ @end $707BD4 }

{ @routine $707C18 TProtoplasm_GetBitmapResourceName }
function TProtoplasm.GetBitmapResourceName: WideString;
begin
  if StackCount <= 19 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod0_'
  else if StackCount <= 39 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod1_'
  else if StackCount <= 59 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod2_'
  else if StackCount <= 79 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod3_'
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Nod4_';
end;
{ @end $707C18 }

{ @routine $707D8C TEquipmentWithActCode_Create }
constructor TEquipmentWithActCode.Create;
begin
  inherited Create;
  ActionCode := nil;
  ActCodeInitialized := False;
end;
{ @end $707D8C }

{ @routine $707DCC TEquipmentWithActCode_Destroy }
destructor TEquipmentWithActCode.Destroy;
begin
  ActionCode := nil;
  inherited Destroy;
end;
{ @end $707DCC }

{ @routine $707DF8 TUselessItem_Create }
constructor TUselessItem.Create;
begin
  inherited Create;
  DisplayAsArtefact := False;
end;
{ @end $707DF8 }

{ @routine $707E34 TUselessItem_Destroy }
destructor TUselessItem.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    RunItemConfigActionCode(Self, event_item_destroy, nil, nil, nil, 0);
  inherited Destroy;
end;
{ @end $707E34 }

{ @routine $707E90 TUselessItem_Init }
procedure TUselessItem.Init(ConfigName: WideString; Series: TDominatorSeries; Seed: Cardinal; ForceArtefactDisplay: Boolean);
var SizeValue, CostValue: Integer;
begin
  ItemType := item_misc;
  DominatorSeries := Series;
  if ConfigName = 'Remains' then begin
    repeat
      ConfigBlockName := 'Remains_' + IntToStr(SeededRandomIntRange(0, UselessItemRemainsCount - 1, Seed));
      if Pos(DominatorSeriesNames[Series], LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Owner')) > 0 then Break;
      Inc(Seed);
    until False;
  end else ConfigBlockName := ConfigName;
  if ForceArtefactDisplay then DisplayAsArtefact := True
  else CheckIfWeDisplayAsArtefact;
  if ConfigName = 'Remains' then OwnerId := owner_dominator
  else OwnerId := OwnerFromInternalName(LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Owner'));
  Weight := StrToInt(AnsiString(LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Size')));
  SizeValue := Weight;
  Weight := Max(1, Round(SeededRandomIntRange(0, SizeValue, Id * 71621723) * RemapClamped(Galaxy.TechLevel, 4, 8, 0.5, 3) + SizeValue));
  CostValue := Round(Galaxy.ResolveMoneySizeTag(LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Cost'), owner_human) * SeededRandomFloatRange(Id * 13567157, 0.5, 1.2));
  Cost := CostValue;
  Cost := RoundAndTruncateToTens(SeededRandomIntRange(150, 200, Id * 13567157) * RemapClamped(Galaxy.TechLevel, 4, 8, 1, 3) *
    RemapClamped(Weight, 10, 100, 1, 6) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].ArcadeRewardScale + CostValue);
  Repair;
  CustomText := '';
  Data[0] := 0; Data[1] := 0; Data[2] := 0;
end;
{ @end $707E90 }

{ @routine $7082C4 TUselessItem_SaveToBuffer }
procedure TUselessItem.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddWideStringZ(CustomText);
  Buffer.AddIntegerValue(Data[0]);
  Buffer.AddIntegerValue(Data[1]);
  Buffer.AddIntegerValue(Data[2]);
end;
{ @end $7082C4 }

{ @routine $708300 TUselessItem_LoadFromBuffer }
procedure TUselessItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion < 86 then ConfigBlockName := Buffer.ReadWideString;
  if LoadedSaveVersion >= 76 then begin
    CustomText := Buffer.ReadWideString;
    Data[0] := Buffer.GetInt32;
    Data[1] := Buffer.GetInt32;
    Data[2] := Buffer.GetInt32;
  end else begin
    CustomText := '';
    Data[0] := 0; Data[1] := 0; Data[2] := 0;
  end;
  CheckIfWeDisplayAsArtefact;
end;
{ @end $708300 }

{ @routine $7083C8 TUselessItem_SaveToBlock }
procedure TUselessItem.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('SoyIsaNoarmoed'), ConfigBlockName); // 'SysName'
end;
{ @end $7083C8 }

{ @routine $70844C TUselessItem_LoadFromBlock }
procedure TUselessItem.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  ConfigBlockName := Block.GetParam(DecodeTextW('SoyIsaNoarmoed')); // 'SysName'
  CheckIfWeDisplayAsArtefact;
end;
{ @end $70844C }

{ @routine $7084E8 TUselessItem_GetDisplayName }
function TUselessItem.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) <= 0 then Result := '' else Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Name');
end;
{ @end $7084E8 }

{ @routine $7085D8 TUselessItem_GetInfoText }
function TUselessItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := CustomText;
  if Result = '' then
    if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) > 0 then
      Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Text');
  ReplaceTextToken(Result, '<Data1>', IntToStr(Data[0]), ColorTag);
  ReplaceTextToken(Result, '<Data2>', IntToStr(Data[1]), ColorTag);
  ReplaceTextToken(Result, '<Data3>', IntToStr(Data[2]), ColorTag);
end;
{ @end $7085D8 }

{ @routine $7087BC TUselessItem_GetDescriptionText }
function TUselessItem.GetDescriptionText: WideString;
begin
  if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) <= 0 then Result := '' else Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Description');
end;
{ @end $7087BC }

{ @routine $7088A4 TUselessItem_GetBitmapResourceName }
function TUselessItem.GetBitmapResourceName: WideString;
begin
  if Pos('Remains', ConfigBlockName) > 0 then
    Result := 'Bm.ItemsUseless.' + GiResourceSuffix + ConfigBlockName + '_' + IntToStr(Ord(DominatorSeries)) + '_'
  else if Pos('Mimic', ConfigBlockName) > 0 then
    Result := 'Bm.Items.' + GiResourceSuffix + CopyWideStringUnchecked(ConfigBlockName, 6, Length(ConfigBlockName) - 5) + '_'
  else Result := 'Bm.ItemsUseless.' + GiResourceSuffix + ConfigBlockName + '_';
  if not CacheDataRoot.FileExistsByPath(Result + 's') then begin
    AppendLogLineThreadSafe(AnsiString('Can not find image for useless item ' + ConfigBlockName + ' changing to Usl_FishCont'));
    Result := 'Bm.ItemsUseless.' + GiResourceSuffix + 'Usl_FishCont_';
  end;
end;
{ @end $7088A4 }

{ @routine $708B74 TUselessItem_IsDominatorRemains }
function TUselessItem.IsDominatorRemains: Boolean;
begin
  Result := (OwnerId = owner_dominator) and (Pos('Remains_', ConfigBlockName) = 1);
end;
{ @end $708B74 }

{ @routine $708BB0 TUselessItem_CheckIfWeDisplayAsArtefact }
procedure TUselessItem.CheckIfWeDisplayAsArtefact;
var
  I: Integer;
begin
  DisplayAsArtefact := False;
  for I := 0 to Length(UselessItemLootPools[loot_any_available]) - 1 do
    if UselessItemLootPools[loot_any_available][I] = ConfigBlockName then
    begin
      DisplayAsArtefact := True;
      Break;
    end;
end;
{ @end $708BB0 }

{ @routine $708BF4 TUselessItem_GetOnUseCodeText }
function TUselessItem.GetOnUseCodeText: WideString;
var Block: TBlockParEC;
begin
  Result := '';
  Block := LanguageDataConfig.GetBlock('UselessItems').FindBlock(ConfigBlockName);
  if Block <> nil then begin
    Block := Block.FindBlock('OnUseCode');
    if Block <> nil then Result := Block.ConcatenateValues;
  end;
end;
{ @end $708BF4 }

{ @routine $708C78 TUselessItem_GetActionCode }
function TUselessItem.GetActionCode: Pointer;
var Config: TBlockParEC;
begin
  if ActCodeInitialized then
  begin
    Result := ActionCode;
    Exit;
  end;
  ActCodeInitialized := True;
  Result := nil;
  Config := LanguageDataConfig.GetBlock('UselessItems').FindBlock(ConfigBlockName);
  if Config <> nil then
  begin
    ActionCode := GetCachedActionCode(UselessItemScriptCache, ConfigBlockName, Config);
    Result := ActionCode;
  end;
end;
{ @end $708C78 }

{ @routine $708CE8 TCistern_Init }
procedure TCistern.Init(Fuel: Integer; Capacity: Byte; Owner: TOwnerId);
begin
  ItemType := item_fuel_container;
  Self.Capacity := Capacity;
  Weight := Capacity;
  Self.Fuel := Min(Self.Capacity, Fuel);
  Cost := 10 * Capacity;
  OwnerId := Owner;
  EquippedFlag := 0;
  Repair;
end;
{ @end $708CE8 }

{ @routine $708D2C TCistern_SaveToBuffer }
procedure TCistern.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(Capacity));
  Buffer.AddIntegerValue(Fuel);
end;
{ @end $708D2C }

{ @routine $708D54 TCistern_LoadFromBuffer }
procedure TCistern.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Capacity := Buffer.GetByte;
  Fuel := Buffer.GetInt32;
end;
{ @end $708D54 }

{ @routine $708D7C TCistern_SaveToBlock }
procedure TCistern.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('FiuNeol'), IntToStr(Fuel)); // 'Fuel'
  Block.AddParam(DecodeTextW('CraspiaNcliotay'), IntToStr(Capacity)); // 'Capacity'
end;
{ @end $708D7C }

{ @routine $708E8C TCistern_LoadFromBlock }
procedure TCistern.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Fuel := StrToInt(Block.GetParam(DecodeTextW('FiuNeol'))); // 'Fuel'
  Capacity := StrToInt(Block.GetParam(DecodeTextW('CraspiaNcliotay'))); // 'Capacity'
end;
{ @end $708E8C }

{ @routine $708F94 TCistern_GetDisplayName }
function TCistern.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Cistern.Name');
end;
{ @end $708F94 }

{ @routine $708FF0 TCistern_GetInfoText }
function TCistern.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Cistern.Text');
  ReplaceTextToken(Result, '<Fuel>', IntToStr(Fuel), ColorTag);
  ReplaceTextToken(Result, '<Capacity>', IntToStr(Capacity), ColorTag);
end;
{ @end $708FF0 }

{ @routine $70911C TCistern_GetDescriptionText }
function TCistern.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Cistern.Description');
end;
{ @end $70911C }

{ @routine $709168 TCistern_GetBitmapResourceName }
function TCistern.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Cistern_';
end;
{ @end $709168 }

{ @routine $70922C TSatellite_InitGenerated }
procedure TSatellite.InitGenerated(TypeId: Byte; Owner: TOwnerId; Seed: Cardinal);
var Roll: Single; SpeedText: WideString; WearLevel: Byte; BaseWeight, BaseCost: Integer;
begin
  ItemType := item_satellite;
  SatelliteTypeId := TypeId;
  OwnerId := Owner;
  TargetPlanet := nil;
  TrajectoryIndex := 0;
  SpeedText := LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Speed');
  WaterExplorationRate := StrToInt(ExtractDelimitedPartW(SpeedText, 0, ','));
  LandExplorationRate := StrToInt(ExtractDelimitedPartW(SpeedText, 1, ','));
  HillExplorationRate := StrToInt(ExtractDelimitedPartW(SpeedText, 2, ','));
  Roll := NextRandomUnitFloat(Seed);
  if Roll < 0.2 then Inc(WaterExplorationRate)
  else if Roll < 0.4 then Inc(LandExplorationRate)
  else if Roll < 0.6 then Inc(HillExplorationRate);
  EquippedFlag := 0;
  BaseWeight := StrToInt(LookupLocalizedTextByKey('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Size'));
  Weight := BaseWeight;
  Weight := Round(NextRandomIntRange(0, BaseWeight, Seed) * RemapClamped(aGalaxy.Galaxy.TechLevel, 4, 8, 1, 1.5) + BaseWeight div 2);
  BaseCost := Round(aGalaxy.Galaxy.ResolveMoneySizeTag(LookupLocalizedTextByKey('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Cost'), owner_human) *
    NextRandomFloatRange(1, 2, Seed));
  Cost := BaseCost;
  Cost := RoundAndTruncateToTens(NextRandomIntRange(150, 200, Seed) * RemapClamped(aGalaxy.Galaxy.TechLevel, 4, 8, 1, 3) *
    RemapClamped(Weight, 10, 50, 2, 1) / GalaxyDifficultyTuning[aGalaxy.Galaxy.DifficultyLevels[7]].QuestMoneyFactor + BaseCost);
  WearLevel := SizeTagToLevel(LookupLocalizedTextByKey('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Wear'));
  WearPerTurn := GenerateValueForSizeLevel(WearLevel, 1, 10, 30, Seed * $E73FE205) * 0.1;
  Repair;
end;
{ @end $70922C }

{ @routine $70973C TSatellite_SaveToBuffer }
procedure TSatellite.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(SatelliteTypeId));
  Buffer.AddIntegerValue(TrajectoryIndex);
  if TargetPlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord((TargetPlanet as TPlanet).Id);
  Buffer.AddAnsiChar(AnsiChar(WaterExplorationRate));
  Buffer.AddAnsiChar(AnsiChar(LandExplorationRate));
  Buffer.AddAnsiChar(AnsiChar(HillExplorationRate));
  Buffer.AddSingle(WearPerTurn);
end;
{ @end $70973C }

{ @routine $7097BC TSatellite_LoadFromBuffer }
procedure TSatellite.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  SatelliteTypeId := Buffer.GetByte;
  TrajectoryIndex := Buffer.GetInt32;
  TargetPlanet := TObject(Buffer.GetUInt32);
  WaterExplorationRate := Buffer.GetByte;
  LandExplorationRate := Buffer.GetByte;
  HillExplorationRate := Buffer.GetByte;
  WearPerTurn := Buffer.GetSingle;
end;
{ @end $7097BC }

{ @routine $709818 TSatellite_SaveToBlock }
procedure TSatellite.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('ToyIprey'), IntToStr(SatelliteTypeId)); // 'Type'
  Block.AddParam(DecodeTextW('WuartTewrf'), IntToStr(WaterExplorationRate)); // 'Water'
  Block.AddParam(DecodeTextW('LLagnsd3'), IntToStr(LandExplorationRate)); // 'Land'
  Block.AddParam(DecodeTextW('HbiFldle'), IntToStr(HillExplorationRate)); // 'Hill'
  Block.AddParam(DecodeTextW('WoeIamrr'), FloatToStr(WearPerTurn)); // 'Wear'
end;
{ @end $709818 }

{ @routine $709A50 TSatellite_LoadFromBlock }
procedure TSatellite.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  SatelliteTypeId := StrToInt(Block.GetParam(DecodeTextW('ToyIprey'))); // 'Type'
  WaterExplorationRate := StrToInt(Block.GetParam(DecodeTextW('WuartTewrf'))); // 'Water'
  LandExplorationRate := StrToInt(Block.GetParam(DecodeTextW('LLagnsd3'))); // 'Land'
  HillExplorationRate := StrToInt(Block.GetParam(DecodeTextW('HbiFldle'))); // 'Hill'
  WearPerTurn := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('WoeIamrr'))); // 'Wear'
end;
{ @end $709A50 }

{ @routine $709C50 TSatellite_ResolveLoadedReferences }
procedure TSatellite.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  TargetPlanet := Galaxy.IdToPlanet(Cardinal(TargetPlanet)) as TPlanet;
end;
{ @end $709C50 }

{ @routine $709C7C TSatellite_ClearReferences }
procedure TSatellite.ClearReferences;
begin
  inherited ClearReferences;
  TargetPlanet := nil;
end;
{ @end $709C7C }

{ @routine $709C90 TSatellite_GetDisplayName }
function TSatellite.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LookupLocalizedTextByKey('Items.Satellite.Name') + ' ' +
    LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Name') + '-' + IntToStr(Id mod 100 + 1);
end;
{ @end $709C90 }

{ @routine $709E0C TSatellite_GetInfoText }
function TSatellite.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Text');
  if WaterExplorationRate > 0 then ReplaceTextToken(Result, '<Water>', IntToStr(WaterExplorationRate), ColorTag)
  else ReplaceTextToken(Result, '<Water>', '-', '');
  if LandExplorationRate > 0 then ReplaceTextToken(Result, '<Land>', IntToStr(LandExplorationRate), ColorTag)
  else ReplaceTextToken(Result, '<Land>', '-', '');
  if HillExplorationRate > 0 then ReplaceTextToken(Result, '<Hill>', IntToStr(HillExplorationRate), ColorTag)
  else ReplaceTextToken(Result, '<Hill>', '-', '');
  Result := Result + GetConditionText(True);
end;
{ @end $709E0C }

{ @routine $70A044 TSatellite_GetBrokenInUseText }
function TSatellite.GetBrokenInUseText: WideString;
var PlanetName: WideString;
begin
  Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.BrokenInUse');
  if TargetPlanet <> nil then PlanetName := (TargetPlanet as TPlanet).Name
  else PlanetName := '';
  ReplaceTextToken(Result, '<Name>', GetDisplayName, TextHighlightColorTag);
  ReplaceTextToken(Result, '<Planet>', PlanetName, TextHighlightColorTag);
end;
{ @end $70A044 }

{ @routine $70A1A0 TSatellite_GetIdleInfoText }
function TSatellite.GetIdleInfoText: WideString;
var PlanetName: WideString;
begin
  Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.IdleInfo');
  if TargetPlanet <> nil then PlanetName := (TargetPlanet as TPlanet).Name
  else PlanetName := '';
  ReplaceTextToken(Result, '<Name>', GetDisplayName, TextHighlightColorTag);
  ReplaceTextToken(Result, '<Size>', IntToStr(Weight), TextHighlightColorTag);
  ReplaceTextToken(Result, '<Planet>', PlanetName, TextHighlightColorTag);
end;
{ @end $70A1A0 }

{ @routine $70A33C TSatellite_GetDescriptionText }
function TSatellite.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Description');
end;
{ @end $70A33C }

{ @routine $70A3F8 TSatellite_GetBitmapResourceName }
function TSatellite.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Satellite' + IntToStr(SatelliteTypeId) + '_';
end;
{ @end $70A3F8 }

{ @routine $70A4EC TTreasureMap_Init }
procedure TTreasureMap.Init(Planet: TObject; Victim: Pointer);
begin
  ItemType := item_treasure_map;
  Weight := 1;
  Cost := 1;
  OwnerId := (TObject(Victim) as TShip).OwnerId;
  if TObject(Victim) is TPirate then SourceShipName := (TObject(Victim) as TPirate).GetFullName(' ')
  else SourceShipName := (TObject(Victim) as TShip).GetFullName(' ');
  TargetPlanet := Planet;
  PreviewTablePage1 := BuildPreviewTable(1, Planet);
  PreviewTablePage2 := BuildPreviewTable(2, Planet);
  EquippedFlag := 0;
  Repair;
end;
{ @end $70A4EC }

{ @routine $70A610 TTreasureMap_SaveToBuffer }
procedure TTreasureMap.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  if TargetPlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord((TargetPlanet as TPlanet).Id);
  Buffer.AddWideStringZ(SourceShipName);
  Buffer.AddWideStringZ(PreviewTablePage1);
  Buffer.AddWideStringZ(PreviewTablePage2);
end;
{ @end $70A610 }

{ @routine $70A66C TTreasureMap_LoadFromBuffer }
procedure TTreasureMap.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TargetPlanet := TObject(Buffer.GetUInt32);
  SourceShipName := Buffer.ReadWideString;
  PreviewTablePage1 := Buffer.ReadWideString;
  PreviewTablePage2 := Buffer.ReadWideString;
end;
{ @end $70A66C }

{ @routine $70A704 TTreasureMap_ResolveLoadedReferences }
procedure TTreasureMap.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  TargetPlanet := Galaxy.IdToPlanet(Cardinal(TargetPlanet)) as TPlanet;
end;
{ @end $70A704 }

{ @routine $70A730 TTreasureMap_ClearReferences }
procedure TTreasureMap.ClearReferences;
begin
  inherited ClearReferences;
  TargetPlanet := nil;
end;
{ @end $70A730 }

{ @routine $70A744 TTreasureMap_GetDisplayName }
function TTreasureMap.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.TreasureMap.Name');
end;
{ @end $70A744 }

{ @routine $70A7A8 TTreasureMap_GetInfoText }
function TTreasureMap.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.TreasureMap.Text') + ' ' + LocalizedText('Items.TreasureMap.Hint');
  ReplaceTextToken(Result, '<Planet>', GetTargetPlanetName, TextHighlightColorTag);
  ReplaceTextToken(Result, '<Ship>', SourceShipName, TextHighlightColorTag);
end;
{ @end $70A7A8 }

{ @routine $70A91C TTreasureMap_GetDescriptionText }
function TTreasureMap.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.TreasureMap.Description');
end;
{ @end $70A91C }

{ @routine $70A970 TTreasureMap_GetBitmapResourceName }
function TTreasureMap.GetBitmapResourceName: WideString;
var Kind: Integer;
begin
  if OwnerId in [owner_maloc..owner_human] then Kind := 1 else Kind := 2;
  Result := 'Bm.ItemsUseless.' + GiResourceSuffix + 'TreasureMap' + IntToStr(Kind) + '_';
end;
{ @end $70A970 }

{ @routine $70AA5C TTreasureMap_GetTargetPlanetName }
function TTreasureMap.GetTargetPlanetName: WideString;
begin
  Result := (TargetPlanet as TPlanet).Name;
end;
{ @end $70AA5C }

{ @routine $70ABCC TTreasureMap_BuildPreviewTable }
function TTreasureMap.BuildPreviewTable(PageIndex: Integer; Planet: TObject): WideString;
var I, Number: Integer; Entry: PPlanetSurfaceLootEntry;
  Rows, Header, Caption, Rule: WideString; World: TPlanet; Item: TObject; Loot: TList;

  // @nested $70AA80 ItemColorTag
  function ItemColorTag(Item: TItem): WideString; // @addr $70AA80 @calls "0x0070B10C" @note "Nested helper of BuildPreviewTable; caller removes the unused static link."
  begin
    if Item is TGoods then Result := GrayColorTag
    else if Item is TArtefact then Result := RedColorTag
    else if Item is TCistern then Result := GrayColorTag
    else if Item is TMicroModule then Result := MagentaColorTag
    else if Item is TEquipment then Result := GoldColorTag
    else Result := '';
  end;

begin
  Rule := WrapTextInColor(StringOfChar('-', TreasureMapRuleLengths[PageIndex]), GrayColorTag);
  Caption := FormatText1(LocalizedColorText('FormGS.PlanetInfo'), TextHighlightColorTag, '<Planet>', (Planet as TPlanet).Name);
  Header := Header + #13#10 + '<td=' + IntToStr(0) + '>' + '<align=left>' + Caption + '</align>';
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 3] div 2) + '>' + '<align=center>' + WrapTextInColor(LocalizedText('Items.TreasureMap.Name'), GreenColorTag) + '</align>';
  Caption := FormatText1(LocalizedColorText('FormGS.StarInfo'), TextHighlightColorTag, '<Star>', (Planet as TPlanet).CurrentStar.Name);
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 3]) + '>' + '<align=right>' + WrapTextInColor(Caption, '') + '</align>';
  Header := Header + #13#10 + Rule + #13#10;
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 0]) + '>' + '<align=right>' + WrapTextInColor(LocalizedColorText('FormGS.ColumnNumber'), TextHighlightColorTag) + '</align>';
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 1]) + '>' + WrapTextInColor(LocalizedColorText('FormGS.ColumnName'), TextHighlightColorTag);
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 2]) + '>' + '<align=right>' + WrapTextInColor(LocalizedColorText('FormShip.StorageInfo.Size'), TextHighlightColorTag) + '</align>';
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 3]) + '>' + '<align=right>' + WrapTextInColor(LocalizedColorText('FormShip.StorageInfo.Cost'), TextHighlightColorTag) + '</align>';
  Header := Header + #13#10 + Rule;
  if Planet = nil then Exit;
  if not (Planet is TPlanet) then Exit;
  Rows := '';
  Number := 1;
  World := Planet as TPlanet;
  Loot := World.SurfaceLootEntries;
  if Loot = nil then Exit;
  for I := 0 to Loot.Count - 1 do
  begin
    Entry := World.SurfaceLootEntries[I];
    if Entry.Item = nil then Continue;
    if not GetPlayer.CanAccessSurfaceLootItem(Entry.Item) then Continue;
    Item := Entry.Item;
    if (Item is TGoods) or (Item is TCistern) then Continue;
    Rows := Rows + #13#10;
    Rows := Rows + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 0]) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Number), '') + '</align>';
    Rows := Rows + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 1]) + '>' + '' + WrapTextInColor(Entry.Item.GetDisplayName, ItemColorTag(Entry.Item)) + '';
    Rows := Rows + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 2]) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Entry.Item.Weight), GreenColorTag) + '</align>';
    Rows := Rows + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 3]) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Entry.Item.Cost), CyanColorTag) + '</align>';
    Inc(Number);
  end;
  Result := Header + Rows;
end;
{ @end $70ABCC }

{ @routine $70B6A4 TMicroModule_Init }
procedure TMicroModule.Init(ModuleIndex: Integer);
var BaseCost: Integer;
begin
  ItemType := item_micro_module;
  OwnerId := owner_uninhabited;
  MicroModuleIndex := ModuleIndex + 1;
  Repair;
  Weight := 1;
  BaseCost := RoundAndTruncateToTens(100 * Galaxy.ComputeScaledSmallMoney(owner_human) /
    (MicroModuleTemplates[MicroModuleIndex - 1].Priority + 20) * SeededRandomFloatRange(Id * 1367, 0.5, 1.2));
  Cost := BaseCost;
  Cost := RoundAndTruncateToTens(SeededRandomIntRange(150, 200, Id * 13567157) *
    RemapClamped(Galaxy.TechLevel, 4, 8, 1, 3) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestMoneyFactor + BaseCost);
end;
{ @end $70B6A4 }

{ @routine $70B7D8 TMicroModule_SaveToBuffer }
procedure TMicroModule.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
end;
{ @end $70B7D8 }

{ @routine $70B7E0 TMicroModule_LoadFromBuffer }
procedure TMicroModule.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion < 113 then Buffer.GetInt32;
  if MicroModuleIndex = 0 then MicroModuleIndex := 1;
end;
{ @end $70B7E0 }

{ @routine $70B810 TMicroModule_GetDisplayName }
function TMicroModule.GetDisplayName: WideString;
var Text: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else begin
    Result := MicroModuleTemplates[MicroModuleIndex - 1].NamePrefix;
    if Result = '' then Result := WrapTextInColor(LookupLocalizedTextOrEmpty('MicroModuls.Name'), '');
    Text := MicroModuleTemplates[MicroModuleIndex - 1].Name;
    if FindTextOffsetW(Text, '"') < 0 then Text := '"' + Text + '"';
    Result := Result + ' ' + WrapTextInColor(Text, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
  end;
end;
{ @end $70B810 }

{ @routine $70B960 TMicroModule_GetPlainName }
function TMicroModule.GetPlainName: WideString;
var Text: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else begin
    Result := MicroModuleTemplates[MicroModuleIndex - 1].NamePrefix;
    if Result = '' then Result := WrapTextInColor(LookupLocalizedTextOrEmpty('MicroModuls.Name'), '');
    Text := MicroModuleTemplates[MicroModuleIndex - 1].Name;
    if FindTextOffsetW(Text, '"') < 0 then Text := '"' + Text + '"';
    Result := Result + ' ' + Text;
  end;
end;
{ @end $70B960 }

{ @routine $70BA94 TMicroModule_GetInfoText }
function TMicroModule.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := GetMicroModuleInfoText(MicroModuleIndex - 1, ColorTag);
end;
{ @end $70BA94 }

{ @routine $70BAE8 GetMicroModuleInfoText }
function GetMicroModuleInfoText(ModuleIndex: Integer; ColorTag: WideString): WideString;
var Index, Value, Fraction: Integer; Text: WideString; Kind: TEquipmentBonusKind;
begin
  Index := ModuleIndex + 1;
  Result := LocalizedColorText('MicroModuls.' + MicroModuleTemplates[ModuleIndex].ConfigName + '.Text');
  for Kind := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
    if Kind in [bonus_acryn_effect..bonus_acryn_penalty] then begin
      Value := MicroModuleTemplates[Index - 1].StatBonuses[Kind];
      if Value = 0 then ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', '--', ColorTag)
      else begin
        if Value > 0 then Text := '+' else Text := '-';
        Value := Abs(Value);
        Fraction := Value mod 100;
        Value := Value div 100;
        if Fraction <> 0 then Text := Text + IntToStr(Value) + '.' + IntToStr(Fraction)
        else Text := Text + IntToStr(Value);
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', Text, ColorTag);
      end;
    end else begin
      Value := MicroModuleTemplates[Index - 1].StatBonuses[Kind];
      if Value > 0 then ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', '+' + IntToStr(Value), ColorTag)
      else if Value < 0 then ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', IntToStr(Value), ColorTag)
      else ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', '--', ColorTag);
    end;
end;
{ @end $70BAE8 }

{ @routine $70BE9C TMicroModule_GetDescriptionText }
function TMicroModule.GetDescriptionText: WideString;
begin
  Result := '';
end;
{ @end $70BE9C }

{ @routine $70BEA8 TMicroModule_GetBitmapResourceName }
function TMicroModule.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := GetMicroModuleBitmapResourceName(MicroModuleIndex - 1);
end;
{ @end $70BEA8 }

{ @routine $70BF34 GetMicroModulePriorityColorTier }
function GetMicroModulePriorityColorTier(ModuleIndex: Integer): Byte;
begin
  case MicroModuleTemplates[ModuleIndex].Priority of
    0..30: Result := 3;
    31..69: Result := 2;
    70..100: Result := 1;
  else Result := 3;
  end;
end;
{ @end $70BF34 }

{ @routine $70BF64 GetMicroModuleNameColorTag }
function GetMicroModuleNameColorTag(ModuleIndex: Integer): WideString;
begin
  if MicroModuleTemplates[ModuleIndex].Color <> '' then
    Result := '<color=' + MicroModuleTemplates[ModuleIndex].Color + '>'
  else
    case GetMicroModulePriorityColorTier(ModuleIndex) of
      2: Result := TextHighlightColorTag;
      3: Result := RedColorTag;
    else Result := MicroModuleHighPriorityColorTag;
    end;
end;
{ @end $70BF64 }

{ @routine $70C080 GetMicroModuleTextColorTag }
function GetMicroModuleTextColorTag(ModuleIndex: Integer): WideString;
begin
  if MicroModuleTemplates[ModuleIndex].Color <> '' then
    Result := '<color=' + MicroModuleTemplates[ModuleIndex].Color + '>'
  else Result := EquipmentBonusColorTag;
end;
{ @end $70C080 }

{ @routine $70C120 GetMicroModuleBitmapResourceName }
function GetMicroModuleBitmapResourceName(ModuleIndex: Integer): WideString;
begin
  if (ModuleIndex >= 0) and (MicroModuleTemplates[ModuleIndex].KindGraph <> '') then
    Result := 'Bm.Micromoduls.' + GiResourceSuffix + 'MM' + MicroModuleTemplates[ModuleIndex].KindGraph + '_'
  else Result := 'Bm.Micromoduls.' + GiResourceSuffix + 'MM' + IntToStr(GetMicroModulePriorityColorTier(ModuleIndex)) + '_';
end;
{ @end $70C120 }

{ @routine $70C244 ApplyMicroModule }
function ApplyMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean;
var BonusKind: TEquipmentBonusKind;
begin
  if (ModuleIndex = -1) or (Item = nil) then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
  Item.MicroModuleIndex := ModuleIndex + 1;
  Item.Weight := Round(Max(1, Item.Weight / 100 * MicroModuleTemplates[Item.MicroModuleIndex - 1].SizePercent));
  Item.Cost := Min(MaxMonetaryValue, Round(Max(1, Item.Cost / 100 * MicroModuleTemplates[Item.MicroModuleIndex - 1].CostPercent)));
  case Item.ItemType of
    item_hull:
      begin
        Inc((Item as THull).Armor, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_armor]);
        (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
      end;
    item_fuel_tanks: Inc((Item as TFuelTanks).Capacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity]);
    item_engine:
      begin
        Inc((Item as TEngine).Speed, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_speed]);
        Inc((Item as TEngine).JumpRange, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_jump_range]);
      end;
    item_radar: Inc((Item as TRadar).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_radar_range]);
    item_scanner: Inc((Item as TScaner).ScanPower, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_scanner_power]);
    item_repair_robot: Inc((Item as TRepairRobot).RepairPoints, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_repair_points]);
    item_cargo_hook:
      begin
        Inc((Item as TCargoHook).PickupPower, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_hook_power]);
        Inc((Item as TCargoHook).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_hook_range]);
        (Item as TCargoHook).MinPullSpeed := (Item as TCargoHook).MinPullSpeed + MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_hook_min_speed];
        (Item as TCargoHook).MaxPullSpeed := (Item as TCargoHook).MaxPullSpeed + MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_hook_max_speed];
      end;
    item_defense_generator:
      if MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_defense] <> 0 then
        (Item as TDefGenerator).DamageFactor := (Item as TDefGenerator).DamageFactor -
          (1 - DefensePercentToDamageFactor(MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_defense]));
  else
    if Item.ItemType in WeaponItemTypes then
    begin
      BonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags)].BonusKind;
      Inc((Item as TWeapon).MaxDamage, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[BonusKind]);
      Inc((Item as TWeapon).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_weapon_range]);
      if TWeapon(Item).GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
        Inc((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_ammo_capacity]);
    end
    else Exception.Create('Микромодуль в оборудование хотели вставить, в которое вставить микромодуль нельзя!'); // Native allocates without raising.
  end;
end;
{ @end $70C244 }

{ @routine $70C74C RemoveMicroModule }
procedure RemoveMicroModule(Item: TEquipment);
var BonusKind: TEquipmentBonusKind;
begin
  if (Item = nil) or (Item.MicroModuleIndex = 0) then Exit;
  Item.Weight := Round(Max(1, Item.Weight / MicroModuleTemplates[Item.MicroModuleIndex - 1].SizePercent * 100));
  Item.Cost := Round(Max(1, Item.Cost / MicroModuleTemplates[Item.MicroModuleIndex - 1].CostPercent * 100));
  case Item.ItemType of
    item_hull:
      begin
        Dec((Item as THull).Armor, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_armor]);
        (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
      end;
    item_fuel_tanks: Dec((Item as TFuelTanks).Capacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_fuel_capacity]);
    item_engine:
      begin
        Dec((Item as TEngine).Speed, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_speed]);
        Dec((Item as TEngine).JumpRange, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_jump_range]);
      end;
    item_radar: Dec((Item as TRadar).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_radar_range]);
    item_scanner: Dec((Item as TScaner).ScanPower, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_scanner_power]);
    item_repair_robot: Dec((Item as TRepairRobot).RepairPoints, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_repair_points]);
    item_cargo_hook:
      begin
        Dec((Item as TCargoHook).PickupPower, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_hook_power]);
        Dec((Item as TCargoHook).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_hook_range]);
        (Item as TCargoHook).MinPullSpeed := (Item as TCargoHook).MinPullSpeed - MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_hook_min_speed];
        (Item as TCargoHook).MaxPullSpeed := (Item as TCargoHook).MaxPullSpeed - MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_hook_max_speed];
      end;
    item_defense_generator:
      if MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_defense] <> 0 then
        (Item as TDefGenerator).DamageFactor := (Item as TDefGenerator).DamageFactor +
          (1 - DefensePercentToDamageFactor(MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_defense]));
  else
    if Item.ItemType in WeaponItemTypes then
    begin
      BonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags)].BonusKind;
      Dec((Item as TWeapon).MaxDamage, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[BonusKind]);
      Dec((Item as TWeapon).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_weapon_range]);
      if TWeapon(Item).GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
        Dec((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_ammo_capacity]);
    end;
  end;
  Item.MicroModuleIndex := 0;
end;
{ @end $70C74C }

{ @routine $70CB98 ApplySpecialMicroModule }
procedure ApplySpecialMicroModule(ModuleIndex: Integer; Item: TEquipment);
var BonusKind: TEquipmentBonusKind;
begin
  if (ModuleIndex = -1) or (Item = nil) or (Item.SpecialModuleIndex <> 0) then
  begin
    RaiseWideMessage('SpecialToEquipment');
    Exit;
  end;
  Item.SpecialModuleIndex := ModuleIndex + 1;
  Item.Weight := Round(Max(1, Item.Weight / 100 * MicroModuleTemplates[ModuleIndex].SizePercent));
  Item.Cost := Min(MaxMonetaryValue, RoundAndTruncateToTens(Max(10, Item.Cost / 100 * MicroModuleTemplates[ModuleIndex].CostPercent)));
  if Item.ItemType = item_hull then
  begin
    (Item as THull).HullType := hull_special;
    (Item as THull).HullPoints := Item.Weight;
    if (Item.Cost < 0) or (Item.Cost > MaxMonetaryValue) then Item.Cost := MaxMonetaryValue;
  end;
  if Item.ItemType in WeaponItemTypes then
  begin
    BonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags)].BonusKind;
    Inc((Item as TWeapon).MaxDamage, MicroModuleTemplates[ModuleIndex].StatBonuses[BonusKind]);
    Inc((Item as TWeapon).Range, MicroModuleTemplates[ModuleIndex].StatBonuses[bonus_weapon_range]);
    if TWeapon(Item).GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
      Inc((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[ModuleIndex].StatBonuses[bonus_ammo_capacity]);
  end;
  if MicroModuleTemplates[ModuleIndex].CustomFaction <> '' then Item.CustomFaction := MicroModuleTemplates[ModuleIndex].CustomFaction;
end;
{ @end $70CB98 }

{ @routine $70CE04 RemoveSpecialMicroModule }
procedure RemoveSpecialMicroModule(Item: TEquipment);
var BonusKind: TEquipmentBonusKind;
begin
  if (Item = nil) or (Item.SpecialModuleIndex = 0) then Exit;
  Item.Weight := Round(Max(1, Item.Weight * 100 / MicroModuleTemplates[Item.SpecialModuleIndex - 1].SizePercent));
  Item.Cost := Round(Max(1, Item.Cost * 100 / MicroModuleTemplates[Item.SpecialModuleIndex - 1].CostPercent));
  if Item.ItemType = item_hull then begin
    (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
    if (Item.Cost < 0) or (Item.Cost > MaxMonetaryValue) then Item.Cost := MaxMonetaryValue;
  end;
  if Item.ItemType in WeaponItemTypes then begin
    BonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags)].BonusKind;
    Dec((Item as TWeapon).MaxDamage, MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[BonusKind]);
    Dec((Item as TWeapon).Range, MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[bonus_weapon_range]);
    if TWeapon(Item).GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
      Dec((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[bonus_ammo_capacity]);
  end;
  if (Item.CustomFaction <> '') and (MicroModuleTemplates[Item.SpecialModuleIndex - 1].CustomFaction = Item.CustomFaction) then Item.CustomFaction := '';
  Item.SpecialModuleIndex := 0;
end;
{ @end $70CE04 }

{ @routine $70D034 TMicroModule_CalculateNodeExchangeValue }
function TMicroModule.CalculateNodeExchangeValue(LowPriorityOfferCost, MediumPriorityOfferCost: Integer): Integer;
begin
  Result := 0;
  if (MicroModuleTemplates[MicroModuleIndex - 1].Priority >= 0) and (MicroModuleTemplates[MicroModuleIndex - 1].Priority <= 30) then begin
    Result := Round(RemapClamped(MicroModuleTemplates[MicroModuleIndex - 1].Priority, 0, 100, 2000, 100));
    Result := SeededRandomIntRange(Round(Result * 0.8), Round(Result * 1.2), Result + GetPlayer.DockedTo.Id);
    Result := RoundAndTruncateToHundreds(Result / 1.5);
  end;
  if (MicroModuleTemplates[MicroModuleIndex - 1].Priority >= 31) and (MicroModuleTemplates[MicroModuleIndex - 1].Priority <= 69) then begin
    Result := Round(RemapClamped(MicroModuleTemplates[MicroModuleIndex - 1].Priority, 0, 100, 2000, 100));
    Result := SeededRandomIntRange(Round(Result * 0.8), Round(Result * 1.2), Result + GetPlayer.DockedTo.Id);
    Result := RoundAndTruncateToHundreds(Min(LowPriorityOfferCost div 2, Result / 1.5));
  end;
  if (MicroModuleTemplates[MicroModuleIndex - 1].Priority >= 70) and (MicroModuleTemplates[MicroModuleIndex - 1].Priority <= 100) then begin
    Result := Round(RemapClamped(MicroModuleTemplates[MicroModuleIndex - 1].Priority, 0, 100, 2000, 100));
    Result := SeededRandomIntRange(Round(Result * 0.8), Round(Result * 1.2), Result + GetPlayer.DockedTo.Id);
    Result := RoundAndTruncateToTens(Min(MediumPriorityOfferCost div 2, Result / 1.5));
  end;
  Result := Max(5, Round(Result * 0.3));
end;
{ @end $70D034 }

{ @routine $70D3C8 TMicroModule_GetHighlightedName }
function TMicroModule.GetHighlightedName: WideString;
begin
  Result := WrapTextInColor(MicroModuleTemplates[MicroModuleIndex - 1].Name, TextHighlightColorTag);
end;
{ @end $70D3C8 }

{ @routine $70D41C TMicroModule_CanInstallOn }
function TMicroModule.CanInstallOn(Item: TEquipment): Boolean;
begin
  Result := False;
  if Item.MicroModuleIndex <> 0 then Exit;
  if (Item.SpecialModuleIndex <> 0) and
    MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then Exit;
  if (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_acryn_effect] <> 0) and (Item.SpecialModuleIndex = 0) then Exit;
  if (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonus_acryn_penalty] <> 0) and (Item.SpecialModuleIndex = 0) then Exit;
  if Item is TWeapon then Result := IsBonusCompatibleWithWeapon(MicroModuleIndex - 1, TWeapon(Item))
  else if Item is THull then Result := IsBonusCompatibleWithHull(MicroModuleIndex - 1, THull(Item))
  else Result := IsBonusCompatibleWithEquipment(MicroModuleIndex - 1, Item);
end;
{ @end $70D41C }

{ @routine $70D4D0 CanInstallMicroModule }
function CanInstallMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean;
begin
  Result := False;
  if Item.MicroModuleIndex <> 0 then Exit;
  if (Item.SpecialModuleIndex <> 0) and
    MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then Exit;
  if (MicroModuleTemplates[ModuleIndex].StatBonuses[bonus_acryn_effect] <> 0) and
    (Item.SpecialModuleIndex = 0) then Exit;
  if (MicroModuleTemplates[ModuleIndex].StatBonuses[bonus_acryn_penalty] <> 0) and
    (Item.SpecialModuleIndex = 0) then Exit;
  if MicroModuleTemplates[ModuleIndex].SpecialOnly then Exit;
  if Item is TWeapon then Result := IsBonusCompatibleWithWeapon(ModuleIndex, TWeapon(Item))
  else if Item is THull then Result := IsBonusCompatibleWithHull(ModuleIndex, THull(Item))
  else Result := IsBonusCompatibleWithEquipment(ModuleIndex, Item);
end;
{ @end $70D4D0 }

{ @routine $70D58C IsBonusCompatibleWithEquipment }
function IsBonusCompatibleWithEquipment(ModuleIndex: Integer; Item: TEquipment): Boolean;
begin
  Result := False;
  if not (Item.ItemType in MicroModuleTemplates[ModuleIndex].AllowedItemTypes) then Exit;
  if Item.CustomFaction <> '' then
  begin
    if Pos('<' + Item.CustomFaction + '>', MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions) > 0 then
    begin
      Result := True;
      Exit;
    end;
    if (Item.OwnerId = owner_uninhabited) or ((Item.OwnerId = owner_dominator) and
      (MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask <> [series_blazer..series_terron])) then Exit;
  end;
  Result := Item.OwnerId in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask;
  if (Item.OwnerId = owner_dominator) and not (Item.DominatorSeries in
    MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) then Result := False;
end;
{ @end $70D58C }

{ @routine $70D6C0 IsBonusCompatibleWithHull }
function IsBonusCompatibleWithHull(ModuleIndex: Integer; Hull: THull): Boolean;
begin
  Result := False;
  if not (item_hull in MicroModuleTemplates[ModuleIndex].AllowedItemTypes) then Exit;
  if Hull.CustomFaction <> '' then
  begin
    if Pos('<' + Hull.CustomFaction + '>', MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions) > 0 then
    begin
      Result := True;
      Exit;
    end;
    if (Hull.OwnerId = owner_uninhabited) or ((Hull.OwnerId = owner_dominator) and
      (MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask <> [series_blazer..series_terron])) then Exit;
  end;
  if ((Hull.OwnerId in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) or
    (Hull.PirateBuilt and (owner_pirate in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask))) and
    ((Hull.OwnerId <> owner_dominator) or (Hull.DominatorSeries in
      MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask)) then Result := True;
end;
{ @end $70D6C0 }

{ @routine $70D80C IsBonusCompatibleWithWeapon }
function IsBonusCompatibleWithWeapon(ModuleIndex: Integer; Weapon: TWeapon): Boolean;
var AllowedTypes: WideString; Info: PWeaponInfo;
begin
  Result := False;
  if ((Weapon.CustomFaction <> '') and
    (Pos('<' + Weapon.CustomFaction + '>', MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions) > 0)) or
    ((Weapon.OwnerId in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) and
     ((Weapon.OwnerId <> owner_dominator) or (Weapon.DominatorSeries in MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask)) and
     ((Weapon.CustomFaction = '') or ((Weapon.OwnerId <> owner_uninhabited) and ((Weapon.OwnerId <> owner_dominator) or
       (MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask = [series_blazer..series_terron]))))) then
  begin
    if Weapon.ItemType in [item_industrial_laser..item_lirecron] then
    begin
      if Weapon.ItemType in MicroModuleTemplates[ModuleIndex].AllowedItemTypes then Result := True;
    end
    else if Weapon.ItemType = item_custom_weapon then
    begin
      Info := Weapon.GetWeaponInfo;
      AllowedTypes := MicroModuleTemplates[ModuleIndex].AllowedCustomWeaponTypes;
      if AllowedTypes = 'Any' then Result := True
      else if (damage_flag_missile in Info.DamageFlags) and (Pos('<WMissile>', AllowedTypes) > 0) then Result := True
      else if (damage_flag_splinter in Info.DamageFlags) and (Pos('<WSplinter>', AllowedTypes) > 0) then Result := True
      else if (damage_flag_energy in Info.DamageFlags) and (Pos('<WEnergy>', AllowedTypes) > 0) then Result := True
      else if Pos('<' + Info.ConfigName + '>', AllowedTypes) > 0 then Result := True;
    end
    else Result := True;
  end;
end;
{ @end $70D80C }

{ @routine $70DA94 CreateConfiguredArtefactByItemType }
function CreateConfiguredArtefactByItemType(ItemType: TItemType; Owner: TOwnerId): TArtefact;
var Item: TArtefact;
begin
  Result := nil;
  if ItemType in [artefact_hull..artefact_extra_missiles] then begin
    Item := TArtefact(CreateItemByType(ItemType));
    if ItemType = artefact_transmitter then TArtefactTransmitter(Item).InitTransmitter(Owner)
    else if ItemType = artefact_tranclucator then TArtefactTranclucator(Item).InitTranclucator(Owner, nil, nil)
    else Item.Init(Owner, ItemType);
    Result := Item;
  end;
end;
{ @end $70DA94 }

{ @routine $70DAF0 CreateRandomLootItem }
function CreateRandomLootItem(Pool: TItemLootPool; Owner: TOwnerId; Seed: Cardinal): TEquipmentWithActCode;
var Index, Count: Integer;
begin
  Count := Length(ArtefactLootPools[Pool]);
  Index := Count + Length(CustomArtefactLootPools[Pool]) + Length(UselessItemLootPools[Pool]);
  Index := SeededRandomIntRange(0, Index - 1, Seed);
  if Index < Length(ArtefactLootPools[Pool]) then
    Result := TObject(CreateConfiguredArtefactByItemType(ArtefactLootPools[Pool][Index], Owner)) as TEquipmentWithActCode
  else begin
    Dec(Index, Count);
    if Index < Length(CustomArtefactLootPools[Pool]) then begin
      Result := TArtefactCustom.Create;
      with TArtefactCustom(Result) do
      begin
        ConfigBlockName := CustomArtefactLootPools[Pool][Index];
        LoadConfig(True);
        Data[1] := 0;
        Data[2] := 0;
        Data[3] := 0;
        Init(Owner, ItemType);
      end;
    end else begin
      Dec(Index, Length(CustomArtefactLootPools[Pool]));
      Result := TUselessItem.Create;
      TUselessItem(Result).Init(UselessItemLootPools[Pool][Index], series_blazer, 0, True);
      Result.OwnerId := Owner;
    end;
  end;
end;
{ @end $70DAF0 }

{ @routine $70DC34 TArtefact_Create }
constructor TArtefact.Create;
begin
  inherited Create;
  DisplayAsArtefact := True;
  Repair;
end;
{ @end $70DC34 }

{ @routine $70DC74 TArtefact_Destroy }
destructor TArtefact.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    RunItemConfigActionCode(Self, event_item_destroy, nil, nil, nil, 0);
  inherited Destroy;
end;
{ @end $70DC74 }

{ @routine $70DCD0 TArtefact_LoadFromBuffer }
procedure TArtefact.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if not (ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity,
    artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles]) then
    Repair;
end;
{ @end $70DCD0 }

{ @routine $70DD00 TArtefact_Init }
procedure TArtefact.Init(Owner: TOwnerId; ItemType: TItemType);
var
  MinWeightScale, MaxWeightScale, MinCostScale, MaxCostScale: Single;
  MinExtraWeight, MaxExtraWeight, MinCost, MaxCost: Integer;
begin
  Self.ItemType := ItemType;
  OwnerId := Owner;
  if not (Self.ItemType in [item_custom_artefact..item_custom_artefact_no_wear]) then Weight := GetAverageItemSize(Self.ItemType);
  case ItemType of
    artefact_hull:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 3000;
      end;
    artefact_fuel:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 3000;
      end;
    artefact_speed:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 2000;
        MaxCost := 3000;
      end;
    artefact_power:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1000;
        MaxCost := 2000;
      end;
    artefact_radar:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 3;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1000;
        MaxCost := 1500;
      end;
    artefact_scanner:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 2;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 500;
        MaxCost := 1000;
      end;
    artefact_repair_robot:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 4;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 3000;
      end;
    artefact_nano_repair:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 4;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 2;
        MinCost := 2000;
        MaxCost := 4000;
      end;
    artefact_cargo_hook:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 3;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 500;
        MaxCost := 1000;
      end;
    artefact_defense:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_analyzer:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 2;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 2;
        MinCost := 500;
        MaxCost := 1000;
      end;
    artefact_extra_loot:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 3;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 2;
        MinCost := 1500;
        MaxCost := 3000;
      end;
    artefact_antigravity:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 3;
        MinWeightScale := 1;
        MaxWeightScale := 3;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1000;
        MaxCost := 2500;
      end;
    artefact_transmitter:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 2;
        MinWeightScale := 1;
        MaxWeightScale := 3;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 500;
        MaxCost := 1500;
      end;
    artefact_bomb:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 2;
        MinWeightScale := 1;
        MaxWeightScale := 6;
        MinCostScale := 1;
        MaxCostScale := 2;
        MinCost := 1000;
        MaxCost := 2000;
      end;
    artefact_tranclucator:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 3;
        MinWeightScale := 1;
        MaxWeightScale := 4;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1000;
        MaxCost := 2000;
      end;
    artefact_defense_to_energy:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_energy_pulse:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_energy_defense:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_splinter:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_decelerate:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_missile_defense:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_afterburner:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_weapon_to_speed:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_hyperjump:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_black_hole:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_defense_to_weapon_slot:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_defense_slot_to_weapons:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_artefactor:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_health_protection:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_point_defense:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 9;
        MinWeightScale := 1;
        MaxWeightScale := 4;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
    artefact_extra_missiles:
      begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
      end;
  else
    begin
        MinExtraWeight := 1;
        MaxExtraWeight := 5;
        MinWeightScale := 1;
        MaxWeightScale := 2;
        MinCostScale := 1;
        MaxCostScale := 3;
        MinCost := 1500;
        MaxCost := 2500;
    end;
  end;
  if GetPlayer <> nil then
    Inc(Weight, Round(SeededRandomIntRange(MinExtraWeight, MaxExtraWeight, Id * 317847) *
      RemapClamped(GetPlayer.GetHull.Weight, HullBaseSize * EquipmentSizeFactors[5] * 1.5, HullBaseSize * EquipmentSizeFactors[1], MinWeightScale, MaxWeightScale)));
  Cost := RoundAndTruncateToTens(SeededRandomIntRange(MinCost, MaxCost, Id + 135671) * RemapClamped(Galaxy.TechLevel, 4, 8, MinCostScale, MaxCostScale));
  Weight := Round(Weight * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[4]].QuestTimeAndExperienceFactor);
  Cost := RoundAndTruncateToTens(Cost * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].QuestTimeAndExperienceFactor);
end;
{ @end $70DD00 }

{ @routine $70E6F0 TArtefact_GetBitmapResourceName }
function TArtefact.GetBitmapResourceName: WideString;
begin
  if Self is TArtefactCustom then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '_'
  else if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + '_';
end;
{ @end $70E6F0 }

{ @routine $70E7E8 TArtefact_GetDisplayName }
function TArtefact.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.Name');
end;
{ @end $70E7E8 }

{ @routine $70E898 TArtefact_GetInfoText }
function TArtefact.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  if (ConfigBlockName <> '') and (LanguageDataConfig.GetBlock('Artefacts').CountBlocks(ConfigBlockName) > 0) then
    Result := LocalizedColorText('Artefacts.' + ConfigBlockName + '.Text') + GetBonusDescription(ColorTag) + GetConditionText(True) + GetBoostStatusText
  else
    Result := LocalizedColorText('Artefacts.' + ItemTypeNames[ItemType] + '.Text') + GetBonusDescription(ColorTag) + GetConditionText(True) + GetBoostStatusText;
end;
{ @end $70E898 }

{ @routine $70EA30 TArtefact_GetDescriptionText }
function TArtefact.GetDescriptionText: WideString;
begin
  Result := LocalizedColorText('Artefacts.' + ItemTypeNames[ItemType] + '.Description');
end;
{ @end $70EA30 }

{ @routine $70EAD8 TArtefact_GetOnUseCodeText }
function TArtefact.GetOnUseCodeText: WideString;
var Block: TBlockParEC;
begin
  Result := '';
  if ItemType in [item_custom_artefact..item_custom_artefact_no_wear] then
    Block := LanguageDataConfig.GetBlock('Artefacts').GetBlock('CustomArtefacts').GetBlock(ConfigBlockName).FindBlock('OnUseCode')
  else Block := LanguageDataConfig.GetBlock('Artefacts').GetBlock(ItemTypeNames[ItemType]).FindBlock('OnUseCode');
  if Block <> nil then Result := Block.ConcatenateValues;
end;
{ @end $70EAD8 }

{ @routine $70EBB4 TArtefact_GetActionCode }
function TArtefact.GetActionCode: Pointer;
var Config: TBlockParEC;
begin
  if ActCodeInitialized then
  begin
    Result := ActionCode;
    Exit;
  end;
  Result := nil;
  ActCodeInitialized := True;
  if ItemType in [item_custom_artefact..item_custom_artefact_no_wear] then
    Config := LanguageDataConfig.GetBlock('Artefacts').GetBlock('CustomArtefacts').GetBlock(ConfigBlockName)
  else Config := LanguageDataConfig.GetBlock('Artefacts').GetBlock(ItemTypeNames[ItemType]);
  if Config <> nil then
  begin
    if ItemType in [item_custom_artefact..item_custom_artefact_no_wear] then
      ActionCode := GetCachedActionCode(ArtefactScriptCache, ConfigBlockName, Config)
    else ActionCode := GetCachedActionCode(ArtefactKindScriptCache, ItemTypeNames[ItemType], Config);
    Result := ActionCode;
  end;
end;
{ @end $70EBB4 }

{ @routine $70ECAC TArtefact_GetEffectiveType }
function TArtefact.GetEffectiveType: TItemType;
begin
  if (ItemType in [item_custom_artefact, item_custom_artefact_no_wear]) and TArtefactCustom(Self).SharedEffect then
    Result := TArtefactCustom(Self).CountsAsItemType
  else Result := ItemType;
end;
{ @end $70ECAC }

{ @routine $70ECC8 TArtefactTransmitter_InitTransmitter }
procedure TArtefactTransmitter.InitTransmitter(Owner: TOwnerId);
begin
  Init(Owner, artefact_transmitter);
  Power := RoundAndTruncateToTens(SeededRandomIntRange(
    MinTransmitterPower, AverageTransmitterPower, Id * 317321));
end;
{ @end $70ECC8 }

{ @routine $70ED0C TArtefactTransmitter_SaveToBuffer }
procedure TArtefactTransmitter.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Power);
end;
{ @end $70ED0C }

{ @routine $70ED28 TArtefactTransmitter_LoadFromBuffer }
procedure TArtefactTransmitter.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Power := Buffer.GetInt32;
end;
{ @end $70ED28 }

{ @routine $70ED44 TArtefactTransmitter_SaveToBlock }
procedure TArtefactTransmitter.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(Power)); // 'Power'
end;
{ @end $70ED44 }

{ @routine $70EDE8 TArtefactTransmitter_LoadFromBlock }
procedure TArtefactTransmitter.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Power := StrToInt(Block.GetParam(DecodeTextW('Prouwseor'))); // 'Power'
end;
{ @end $70EDE8 }

{ @routine $70EE88 TArtefactTransmitter_GetInfoText }
function TArtefactTransmitter.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  DisplayPower: Integer;
begin
  Result := LocalizedColorText('Artefacts.' + ItemTypeNames[ItemType] + '.Text') +
    GetConditionText(True) + GetBoostStatusText;
  if Power < 0 then DisplayPower := 0
  else DisplayPower := Power;
  ReplaceTextToken(Result, '<Power>', IntToStr(DisplayPower), ColorTag);
end;
{ @end $70EE88 }

{ @routine $70EFBC TArtefactTranclucator_Destroy }
destructor TArtefactTranclucator.Destroy;
begin
  if Ship <> nil then begin
    Ship.Free;
    Ship := nil;
  end;
  inherited Destroy;
end;
{ @end $70EFBC }

{ @routine $70EFF4 TArtefactTranclucator_InitTranclucator }
procedure TArtefactTranclucator.InitTranclucator(Owner: TOwnerId; OwnerShip: TObject; ExistingShip: TObject);
var Companion: TTranclucator; I: Integer; Item: TItem;
begin
  Init(Owner, artefact_tranclucator);
  Ship := ExistingShip;
  if Ship = nil then
  begin
    Ship := TTranclucator.Create;
    Companion := Ship as TTranclucator;
    Companion.Init(OwnerShip as TShip, Owner, False);
    if OwnerShip <> nil then
    begin
      Companion.CurrentStar.Ships.Delete(Companion.CurrentStar.Ships.IndexOf(Companion));
      Companion.CurrentStar := nil;
    end;
  end;
  Companion := Ship as TTranclucator;
  if Companion.ArtefactSize > 0 then Weight := Companion.ArtefactSize
  else Companion.ArtefactSize := Weight;
  ConfigBlockName := Companion.ArtefactSystemName;
  OwnerId := Companion.GetHull.OwnerId;
  for I := 1 to Companion.Inventory.Count - 1 do
  begin
    Item := Companion.Inventory[I];
    Inc(Cost, Item.Cost);
  end;
  for I := 0 to Companion.Artefacts.Count - 1 do
  begin
    Item := Companion.Artefacts[I];
    Inc(Cost, Item.Cost);
  end;
end;
{ @end $70EFF4 }

{ @routine $70F134 TArtefactTranclucator_SaveToBuffer }
procedure TArtefactTranclucator.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  (Ship as TTranclucator).SaveToBuffer(Buffer);
end;
{ @end $70F134 }

{ @routine $70F15C TArtefactTranclucator_LoadFromBuffer }
procedure TArtefactTranclucator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Ship := TTranclucator.Create;
  (Ship as TTranclucator).LoadFromBuffer(Buffer, TGalaxy(Galaxy));
end;
{ @end $70F15C }

{ @routine $70F1A0 TArtefactTranclucator_Clone }
function TArtefactTranclucator.Clone: TItem;
begin
  Result := nil;
end;
{ @end $70F1A0 }

{ @routine $70F1A4 TArtefactTranclucator_SaveToBlock }
procedure TArtefactTranclucator.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  TTranclucator(Ship).SaveToBlock(Block.AddBlockByPath(DecodeTextW('S5heifphI4d') + IntToStr(TTranclucator(Ship).Id))); // 'ShipId'
end;
{ @end $70F1A4 }

{ @routine $70F264 TArtefactTranclucator_LoadFromBlock }
procedure TArtefactTranclucator.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TTranclucator(Ship).LoadFromBlock(Block.GetBlockByPath(DecodeTextW('S5heifphI4d') + IntToStr(TTranclucator(Ship).Id))); // 'ShipId'
end;
{ @end $70F264 }

{ @routine $70F324 TArtefactTranclucator_ResolveLoadedReferences }
procedure TArtefactTranclucator.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  (Ship as TTranclucator).ResolveLoadedReferences(Galaxy);
end;
{ @end $70F324 }

{ @routine $70F34C TArtefactTranclucator_ClearReferences }
procedure TArtefactTranclucator.ClearReferences;
begin
  inherited ClearReferences;
  (Ship as TTranclucator).ClearObjectReferences;
end;
{ @end $70F34C }

{ @routine $70F36C TArtefactTranclucator_GetDisplayName }
function TArtefactTranclucator.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if Ship <> nil then begin
    if Length((Ship as TShip).Name) > 0 then Result := (Ship as TShip).Name
    else Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.Name') + '-' + IntToStr((Ship as TShip).Id);
  end else Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.Name');
end;
{ @end $70F36C }

{ @routine $70F4F4 TArtefactCustom_LoadConfig }
procedure TArtefactCustom.LoadConfig(ApplyConfiguredWeight: Boolean);
var Block: TBlockParEC; Name: WideString; Kind: TItemType;
begin
  Block := LanguageDataConfig.GetBlockByPath('Artefacts.CustomArtefacts.' + ConfigBlockName);
  if (Block.CountParams('NoWear') > 0) and (ExtractDigitsToIntW(Block.GetParam('NoWear')) <> 0) then ItemType := item_custom_artefact_no_wear
  else ItemType := item_custom_artefact;
  if ApplyConfiguredWeight then
    if Block.CountParams('Size') <= 0 then Weight := 10
    else Weight := ExtractDigitsToIntW(Block.GetParam('Size'));
  CountsAsItemType := item_custom_artefact;
  SharedUse := False;
  SharedEffect := False;
  if Block.CountParams('CountsAs') > 0 then begin
    Name := Block.GetParam('CountsAs');
    for Kind := Low(TItemType) to High(TItemType) do
      if (Kind in [item_custom_artefact..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_defense_to_weapon_slot..artefact_extra_missiles]) and
         not (Kind in [item_custom_artefact..item_custom_artefact_no_wear]) and (ItemTypeNames[Kind] = Name) then begin
        CountsAsItemType := Kind;
        Break;
      end;
    if CountsAsItemType <> item_custom_artefact then begin
      if Block.CountParams('SharedUse') > 0 then SharedUse := ExtractDigitsToIntW(Block.GetParam('SharedUse')) <> 0;
      if Block.CountParams('SharedEffect') > 0 then SharedEffect := ExtractDigitsToIntW(Block.GetParam('SharedEffect')) <> 0;
    end;
  end;
end;
{ @end $70F4F4 }

{ @routine $70F760 TArtefactCustom_SaveToBuffer }
procedure TArtefactCustom.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Data[1]);
  Buffer.AddIntegerValue(Data[2]);
  Buffer.AddIntegerValue(Data[3]);
  if TextData1 = '' then Buffer.AddBoolean(False)
  else begin Buffer.AddBoolean(True); Buffer.AddWideStringZ(TextData1); end;
  if TextData2 = '' then Buffer.AddBoolean(False)
  else begin Buffer.AddBoolean(True); Buffer.AddWideStringZ(TextData2); end;
  if TextData3 = '' then Buffer.AddBoolean(False)
  else begin Buffer.AddBoolean(True); Buffer.AddWideStringZ(TextData3); end;
end;
{ @end $70F760 }

{ @routine $70F818 TArtefactCustom_LoadFromBuffer }
procedure TArtefactCustom.LoadFromBuffer(Buffer: TBufEC; Galaxy: TObject);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  LoadConfig(False);
  Data[1] := Buffer.GetInt32;
  Data[2] := Buffer.GetInt32;
  Data[3] := Buffer.GetInt32;
  if LoadedSaveVersion >= 96 then begin
    if Buffer.GetBoolean then TextData1 := Buffer.ReadWideString;
    if Buffer.GetBoolean then TextData2 := Buffer.ReadWideString;
    if Buffer.GetBoolean then TextData3 := Buffer.ReadWideString;
  end;
end;
{ @end $70F818 }

{ @routine $70F8FC TArtefactCustom_SaveToBlock }
procedure TArtefactCustom.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(1)), IntToStr(Data[1])); // 'Data1'
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(2)), IntToStr(Data[2])); // 'Data2'
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(3)), IntToStr(Data[3])); // 'Data3'
end;
{ @end $70F8FC }

{ @routine $70FAE0 TArtefactCustom_LoadFromBlock }
procedure TArtefactCustom.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Data[1] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(1)))); // 'Data1'
  Data[2] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(2)))); // 'Data2'
  Data[3] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(3)))); // 'Data3'
end;
{ @end $70FAE0 }

{ @routine $70FC94 TArtefactCustom_GetInfoText }
function TArtefactCustom.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedColorText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Text') + GetBonusDescription(ColorTag) + GetConditionText(True) + GetBoostStatusText;
  ReplaceTextToken(Result, '<Data1>', IntToStr(Data[1]), ColorTag);
  ReplaceTextToken(Result, '<Data2>', IntToStr(Data[2]), ColorTag);
  ReplaceTextToken(Result, '<Data3>', IntToStr(Data[3]), ColorTag);
  ReplaceTextToken(Result, '<TextData1>', TextData1, ColorTag);
  ReplaceTextToken(Result, '<TextData2>', TextData2, ColorTag);
  ReplaceTextToken(Result, '<TextData3>', TextData3, ColorTag);
end;
{ @end $70FC94 }

{ @routine $70FF10 TArtefactCustom_GetDisplayName }
function TArtefactCustom.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Name');
end;
{ @end $70FF10 }

{ @routine $70FFD4 TArtefactCustom_GetDescriptionText }
function TArtefactCustom.GetDescriptionText: WideString;
begin
  Result := LocalizedColorText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Description');
end;
{ @end $70FFD4 }

{ @routine $710090 TArtefact_GetBoostStatusText }
function TArtefact.GetBoostStatusText: WideString;
var
  Ship: TShip;
  I: Integer;
begin
  Result := '';
  if BrokenFlag <> 0 then Exit;
  Ship := nil;
  if GetInnermostScreenLoop = HangarScreen then Ship := HangarScreen.SelectedShip
  else if GetInnermostScreenLoop = ScannerScreen then Ship := ScannerScreen.ShipToInspect
  else if GetInnermostScreenLoop = ShipScreen then Ship := PlayerHoldShip;
  if Ship = nil then Exit;
  if Ship.CanBoostArtefact(GetEffectiveType, nil, True) then
  begin
    if EquippedFlag <> 0 then
      Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtGettingBoost')
    else
      Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtCanGetBoost');
  end
  else
    for I := 0 to Ship.Inventory.Count - 1 do
      if Ship.CanBoostArtefact(GetEffectiveType, TEquipment(Ship.Inventory[I]), True) then
      begin
        Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtCanGetBoost');
        Break;
      end;
end;
{ @end $710090 }

{ @routine $710298 CreateItemByType }
function CreateItemByType(ItemType: TItemType): TItem;
begin
  Result := nil;
  case ItemType of
    item_hull: Result := THull.Create;
    item_fuel_tanks: Result := TFuelTanks.Create;
    item_engine: Result := TEngine.Create;
    item_radar: Result := TRadar.Create;
    item_scanner: Result := TScaner.Create;
    item_repair_robot: Result := TRepairRobot.Create;
    item_cargo_hook: Result := TCargoHook.Create;
    item_defense_generator: Result := TDefGenerator.Create;
    item_nodes: Result := TProtoplasm.Create;
    item_misc: Result := TUselessItem.Create;
    item_micro_module: Result := TMicroModule.Create;
    item_fuel_container: Result := TCistern.Create;
    item_satellite: Result := TSatellite.Create;
    item_treasure_map: Result := TTreasureMap.Create;
    item_stackable_misc: Result := TCountableItem.Create;
    artefact_transmitter: Result := TArtefactTransmitter.Create;
    artefact_tranclucator: Result := TArtefactTranclucator.Create;
    item_custom_artefact, item_custom_artefact_no_wear: Result := TArtefactCustom.Create;
    item_custom_weapon: Result := TCustomWeapon.Create;
  else
    if ItemType in [item_industrial_laser..item_lirecron] then Result := TWeapon.Create
    else if ItemType in [item_food..item_narcotics] then Result := TGoods.Create
    else if ItemType in [artefact_hull..artefact_extra_missiles] then Result := TArtefact.Create
    else Exception.Create('Error CreateItemByType'); // Native allocates without raising.
  end;
end;
{ @end $710298 }

{ @routine $710528 CreateDefaultItemByType }
function CreateDefaultItemByType(ItemType: TItemType): TItem;
var Item: TItem;
begin
  if ItemType in [artefact_hull..artefact_extra_missiles] then begin
    Result := CreateConfiguredArtefactByItemType(ItemType, owner_uninhabited);
    Exit;
  end;
  if ItemType = item_hull then begin
    Item := CreateItemByType(ItemType);
    THull(Item).Init(250, 1, RaceToOwner(GetPlayer.PilotRace), hull_ranger, -1, False);
    Result := Item;
    Exit;
  end;
  if ItemType = item_custom_weapon then begin
    Result := nil;
    Exit;
  end;
  if ItemType in [item_hull..item_custom_weapon] then begin
    Result := CreateGeneratedEquipment(ItemType, 20, 1, owner_uninhabited);
    Exit;
  end;
  Item := CreateItemByType(ItemType);
  Result := Item;
  if Item <> nil then
    case ItemType of
      item_nodes: TProtoplasm(Item).Init(10, 0);
      item_misc: TUselessItem(Item).Init(DecodeTextW('EdxYahmrpelwefAjsktleoruoeiddc'), series_blazer, 0, False); // 'ExampleAsteroid'
      item_micro_module: TMicroModule(Item).Init(1);
      item_fuel_container: TCistern(Item).Init(10, 10, owner_uninhabited);
      item_satellite: TSatellite(Item).InitGenerated(1, GetPlayer.OwnerId, NextRandomIntRange(1, 10000, Galaxy.RandomState));
    else
      if ItemType in [item_food..item_narcotics] then TGoods(Item).Init(ItemType, 10)
      else begin Item.Free; Result := nil; end;
    end;
end;
{ @end $710528 }

{ @routine $710708 CreateGeneratedEquipment }
function CreateGeneratedEquipment(ItemType: TItemType; Weight, Level: Integer; Owner: TOwnerId): TEquipment;
var Item: TItem; MinimumLevel: Integer; ActualLevel: Byte;
begin
  MinimumLevel := Max(1, Level);
  Result := nil;
  if not (ItemType in [item_hull..item_custom_weapon]) then Exit;
  Item := CreateItemByType(ItemType);
  Result := TEquipment(Item);
  if Item = nil then Exit;
  ActualLevel := Max(0, Min(MinimumLevel, 8));
  case ItemType of
    item_hull: THull(Item).Init(Weight, ActualLevel, Owner, hull_ranger, -1, False);
    item_fuel_tanks: TFuelTanks(Item).Init(Weight, ActualLevel, Owner);
    item_engine: TEngine(Item).Init(Weight, ActualLevel, Owner);
    item_radar: TRadar(Item).Init(Weight, ActualLevel, Owner);
    item_scanner: TScaner(Item).Init(Weight, ActualLevel, Owner);
    item_repair_robot: TRepairRobot(Item).Init(Weight, ActualLevel, Owner);
    item_cargo_hook: TCargoHook(Item).Init(Weight, ActualLevel, Owner);
    item_defense_generator: TDefGenerator(Item).Init(Weight, ActualLevel, Owner);
  else
    if ItemType = item_custom_weapon then
      raise Exception.Create('Error CreateEq - cant create custom weapons')
    else if ItemType in WeaponItemTypes then TWeapon(Item).Init(ItemType, Weight, ActualLevel, Owner)
    else begin Item.Free; Result := nil; end;
  end;
end;
{ @end $710708 }

{ @routine $7108E4 CreateGeneratedWeapon }
function CreateGeneratedWeapon(Info: PWeaponInfo; Weight, Level: Integer; Owner: TOwnerId): TWeapon;
begin
  Result := TWeapon(CreateItemByType(Info.ItemType));
  if Info.ItemType in [item_industrial_laser..item_lirecron] then Result.Init(Info.ItemType, Weight, Level, Owner)
  else TCustomWeapon(Result).InitCustom(Info, False, Weight, Level, Owner);
end;
{ @end $7108E4 }

{ @routine $710940 GetItemTypeBitmapPath }
function GetItemTypeBitmapPath(ItemType: TItemType): WideString;
begin
  Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType];
end;
{ @end $710940 }

{ @routine $7109BC GetStackableItemTypeName }
function GetStackableItemTypeName(ItemType: TItemType): WideString;
begin
  Result := '';
  if ItemType in [item_food..item_narcotics] then Result := GoodsMarket[Ord(ItemType)].DisplayName
  else if ItemType = item_nodes then Result := LocalizedText('Items.Nod.Name');
end;
{ @end $7109BC }

{ @routine $710A24 GetStackableItemName }
function GetStackableItemName(Item: TItem): WideString;
begin
  if Item.ItemType = item_stackable_misc then
    Result := LocalizedText('Items.CustomCountables.' + (Item as TCountableItem).ConfigBlockName + '.Name')
  else Result := GetStackableItemTypeName(Item.ItemType);
end;
{ @end $710A24 }

{ @routine $710AEC MigrateSavedItemType }
function MigrateSavedItemType(ItemType: Byte): TItemType;
begin
  if (LoadedSaveVersion < 164) and (TItemType(ItemType) > item_custom_artefact) then Inc(ItemType);
  if (LoadedSaveVersion < 78) and (TItemType(ItemType) > artefact_health_protection) then Inc(ItemType);
  if (LoadedSaveVersion < 131) and (TItemType(ItemType) > artefact_point_defense) then Inc(ItemType);
  if (LoadedSaveVersion < 78) and (TItemType(ItemType) > item_torpedo_tube) then Inc(ItemType, 3);
  if (LoadedSaveVersion < 127) and (TItemType(ItemType) > item_lirecron) then Inc(ItemType);
  Result := TItemType(ItemType);
end;
{ @end $710AEC }

end.
