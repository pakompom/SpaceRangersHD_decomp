unit aItem;
// Unit bracket (inferred): .text 0x00730524..0x0074FD78; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Struct, SE_Space, Windows, aEFilm, aGalaxy, aGalaxyStruct;

const
  // AssignedSlotData is also copied into TabWeapon.SlotData. The arcade group
  // toggle XORs bit 7 at $694644; primary/secondary fire tests it at $688761/$688A38.
  EquipmentSlotIndexMask = $7F;
  EquipmentSecondaryFireFlag = $80;

type
  TItemTypeNameTable = array[0..75] of WideString;
  PItemTypeNameTable = ^TItemTypeNameTable;

  TItemLootPool = (
    ilpArcadeBattle = 0,
    ilpTreasure = 1,
    ilpReward = 2,
    ilpAnyAvailable = 3
  ); // @size 0x1
  TArtefactLootPool = array of TItemType;
  TArtefactLootPools = array[0..3] of TArtefactLootPool;
  PArtefactLootPools = ^TArtefactLootPools;
  TNamedItemLootPool = array of WideString;
  TNamedItemLootPools = array[0..3] of TNamedItemLootPool;
  PNamedItemLootPools = ^TNamedItemLootPools;

  TInterceptorTargetingStrategy = (
    itsManual = 0,
    itsMostHullPoints = 1,
    itsFewestHullPoints = 2,
    itsGreatestStrength = 3,
    itsStrongestDefense = 4,
    itsNearest = 5,
    itsFarthest = 6
  ); // @size 0x1

  TImprovementKind = (
    ikMinor = 0,
    ikMedium = 1,
    ikMajor = 2,
    ikAny = 3
  ); // @size 0x1

  TWeaponTargetKind = (
    wtkNone = 0,
    wtkShip = 1,
    wtkItem = 2,
    wtkAsteroid = 3,
    wtkMissile = 4
  ); // @size 0x1

  TExtraSpecial = packed record // @size 0x8
    ModuleIndexPlusOne: Integer; // @offset 0x00
    Count: Integer; // @offset 0x04
  end;
  PExtraSpecial = ^TExtraSpecial;

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
    GraphObject: TObjectSE; // @offset 0x04  Retained scene reference; released on destruction.
    Id: Integer; // @offset 0x08
    ItemType: TItemType; // @offset 0x0C
    Position: TPointF; // @offset 0x10
    Weight: Integer; // @offset 0x18  Hull capacity for hull items.
    OwnerId: Byte; // @offset 0x1C
    Cost: Integer; // @offset 0x20
    NameOverride: WideString; // @offset 0x24
    FilmObject: TEFilmObj; // @offset 0x28  Borrowed from the active film; not an integer object ID.
    ScriptItem: TObject; // @offset 0x2C  Borrowed TScriptItem; cleared when the wrapper is destroyed.
    DestroyFlag: Integer; // @offset 0x30  Script.ItemDestroy.
    NoDropFlag: Byte; // @offset 0x34  Script.NoDropItem; not restricted to Boolean values.

    // Native TItem VMT slots $18, $24 and $28 point to the RTL abstract-method handler.
    function GetDisplayName: WideString; virtual; abstract; // @slot $18 @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetDescriptionText: WideString; virtual; abstract; // @slot $24 @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; virtual; abstract; // @slot $28 @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetShortName: WideString; virtual; // @addr 0x732068 @slot 0x1C @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; virtual; // @addr 0x732080 @slot 0x20 @ida "void __userpurge $name(TItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); virtual; // @addr 0x7316D8 @slot 0x00 @calls "0x733A28"
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); virtual; // @addr 0x73179C @slot 0x04 @calls "0x733A53" @note "Object-reference fields in descendants hold saved IDs until ResolveLoadedReferences; updates Galaxy.NextItemId."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); virtual; // @addr 0x731E28 @slot 0x08 @calls "0x733A63"
    procedure ClearReferences; virtual; // @addr 0x731E38 @slot 0x0C
    procedure SaveToBlock(Block: TBlockParEC); virtual; // @addr 0x7318A8 @slot 0x10
    procedure LoadFromBlock(Block: TBlockParEC); virtual; // @addr 0x731B2C @slot 0x14

    constructor Create; // @addr 0x7315B0 @ida "TItem *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x731620 @ida "void __usercall $name(TItem *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function GetGraphObject: TObjectSE; // @addr 0x732184 @note "Lazily creates and initializes the retained scene container; returns a borrowed reference. Appearance depends on item kind, size, faction, and drop flags."
    procedure ReleaseGraphObject; // @addr 0x732F84
    function GetSmallInfoText: WideString; // @addr 0x731E44 @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Generic Items.SmallInfo label used outside radar range."
    function CalculateResaleValue(TradingSkill: Byte): Integer; // @addr 0x731E88 @note "Applies the trading-skill percentage to Cost minus repair cost; equipment has a minimum value of 1. Goods use Cost directly."
    function GetConditionAdjustedCost: Integer; // @addr 0x731F74 @note "Equipment deducts repair cost, with a minimum result of 1; goods return Cost unchanged."

    function GetCategoryConfigName: WideString; // @addr 0x731FDC @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Groups weapon types under Weapon and built-in artefacts under Artefact; otherwise returns the item-type configuration name."
    function GetOwnerConfigName: WideString; // @addr 0x733084 @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Manufacturer/faction resource key, including custom factions and Dominator series."
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

    function GetDisplayName: WideString; override; // @addr 0x7357C8 @slot 0x18 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetShortName: WideString; override; // @addr 0x735A98 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x73328C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x733550
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x733A90
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x733F88

    constructor Create; // @addr 0x7331B0 @ida "TEquipment *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x733200 @ida "void __usercall $name(TEquipment *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Equip; // @addr 0x73420C
    procedure Unequip; virtual; // @addr 0x734284 @slot 0x2C
    procedure Repair; virtual; // @addr 0x7342FC @slot 0x30
    function NeedsRepair: Boolean; // @addr 0x73431C @note "Tests hull damage or supported equipment below 90 percent condition."
    function Clone: TItem; virtual; // @addr 0x7339EC @slot 0x48 @note "Allocates a new item ID and resolves references in the current galaxy; changes LoadedSaveVersion."

    function GetLevel: Integer; // @addr 0x735490 @note "Returns 0 for unsupported item types."
    function CalculateRepairCost: Integer; // @addr 0x7343A0 @note "Undiscounted cost; hulls use HullPoints, other supported equipment uses ConditionPercent and BrokenFlag."
    function HasMicroModule: Boolean; // @addr 0x735C20
    function GetStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x736278
    function GetFragilityFactor(DamageFlags: TDamageFlagSet): Single; virtual; // @addr 0x7360B8 @slot 0x40 @ida "float __usercall $name@<st0>(TEquipment *Self@<eax>, unsigned int DamageFlags@<edx>);"
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); virtual; // @addr 0x736230 @slot 0x44
    function GetMicroModuleQuotedName: WideString; // @addr 0x735C3C @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetSpecialModuleName: WideString; // @addr 0x735CE0 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"

    function GetDescriptionText: WideString; override; // @addr 0x73564C @slot 0x24 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x735E24 @slot 0x28 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure Improve(Kind: TImprovementKind); virtual; // @addr 0x735D24 @slot 0x34 @calls "0x651B22 0x651B38" @note "Base is a no-op. Overrides change statistics and Cost without checking CanImprove or charging money; ikAny selects one of the three strengths."
    function CalculateImprovementCost(Kind: TImprovementKind): Integer; virtual; // @addr 0x735D34 @slot 0x38 @calls "0x7383D5 0x73A821 0x73B91B 0x73CCF2 0x73DAE8 0x73E974 0x73FD71 0x741248 0x7432DA" @note "Only ikMinor, ikMedium and ikMajor are valid: Cost times 0.3, 0.6 or 1.2, rounded then truncated to a multiple of 10, before service discounts."
    function HasStandardStats: Boolean; virtual; // @addr 0x735E10 @slot 0x3C @calls "0x651A99" @note "Tests expected generated statistics after accounting for installed bonuses; this is not a stored upgraded flag. The base implementation returns True."
    procedure ImproveAtScientificBase; // @addr 0x735BBC @note "Selects strength and stat emphasis from Id, then calls Improve. Charging and eligibility checks belong to the caller."
    function CanImprove: Boolean; // @addr 0x7370DC @note "Requires HasStandardStats and no special module that blocks the special slot; does not check technology access."
    function GetDescriptionStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x736420 @note "Aggregate used by the bonus description, with SeparatedNumbers effects handled separately."
    function GetBonusDescription(ColorTag: WideString): WideString; // @addr 0x7369D0 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 *ColorTag@<edx>, unsigned __int16 **Result@<ecx>);"
    function GetConditionText(PrefixNewLine: Boolean): WideString; // @addr 0x734630 @ida "void __usercall $name(TEquipment *Self@<eax>, bool PrefixNewLine@<dl>, unsigned __int16 **Result@<ecx>);" @note "Includes player technology restrictions as well as wear and breakage."
    function GetBrokenInBattleText: WideString; // @addr 0x734D48 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBrokenInUseText: WideString; // @addr 0x734FB0 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBrokenByForceText: WideString; // @addr 0x735210 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetLevelLetter: WideString; // @addr 0x735608 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "A through H for levels 1 through 8; empty for unsupported levels."
  end;

  THull = class(TEquipment) // @size 0x84
  public
    HullPoints: Integer; // @offset 0x60
    TechLevel: Byte; // @offset 0x64
    Armor: ShortInt; // @offset 0x65
    HullType: Byte; // @offset 0x66 ht* categories in aGalaxyStruct.
    HullSeries: Integer; // @offset 0x68  -1 means no series.
    OwnerShip: Pointer; // @offset 0x6C  Borrowed; not serialized by the hull.
    CapitalShip: Byte; // @offset 0x70  Script.CapitalShipStats.
    PirateBuilt: Boolean; // @offset 0x71
    ImpulseShieldsEnabled: Boolean; // @offset 0x72
    InterceptorsEnabled: Boolean; // @offset 0x73
    Energy: Integer; // @offset 0x74
    EnergyMax: Integer; // @offset 0x78
    InterceptorTarget: Pointer; // @offset 0x7C  Saved as an ID until ResolveLoadedReferences.
    InterceptorTargetingStrategy: TInterceptorTargetingStrategy; // @offset 0x80  Automatic target selection for the player.
    InterceptorPassCountOverride: Byte; // @offset 0x81  Zero selects five passes.

    function GetDisplayName: WideString; override; // @addr 0x738470 @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetShortName: WideString; override; // @addr 0x738A50 @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x738ABC @ida "void __userpurge $name(THull *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7372EC
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7374D0
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x737780
    procedure ClearReferences; override; // @addr 0x7377BC
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7377D8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x737AA4

    procedure Init(Capacity: Integer; Level, Owner, HullType: Byte; Series: Integer; PirateBuilt: Boolean); // @addr 0x737124
    procedure Repair; override; // @addr 0x7381C8
    function GetSlotCount(Kind: TShipSlotKind): Integer; // @addr 0x73997C
    function GetFragilityFactor(DamageFlags: TDamageFlagSet): Single; override; // @addr 0x739E68 @ida "float __usercall $name@<st0>(THull *Self@<eax>, unsigned int DamageFlags@<edx>);" @note "Zero flags return the average of energy, splinter and missile factors."
    function CalculateMass: Integer; // @addr 0x739DE4 @note "Round(capacity * (0.6 + 0.2 * (clamped level - 1) / 7)); excludes carried cargo and ship mass modifiers."
    function CalculateGeneratedArmor: ShortInt; // @addr 0x737D40

    function GetBitmapResourceName: WideString; override; // @addr 0x739484 @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7381E8
    function HasStandardStats: Boolean; override; // @addr 0x7383F8
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x738DAC
    procedure ApplySeriesSizeAndCost; // @addr 0x7371EC @note "Applies the current hull series, resets HullPoints to capacity, and bounds Cost."
    function CalculateGeneratedCost: Integer; // @addr 0x73812C @note "If cost generation overflows negative, repeatedly halves capacity and resets HullPoints before retrying."
    function GetSeriesName: WideString; // @addr 0x7388FC @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetSpecialKindGraph: WideString; // @addr 0x739914 @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Returns the special module KindGraph, or the literal 1 as fallback."
    function EstimateCapacityWithoutBonuses: Integer; // @addr 0x73A0E8 @note "Reverses module and series size percentages with rounding; extra-special multiplicities are not used."
  end;

  TFuelTanks = class(TEquipment) // @size 0x6C
  public
    TechLevel: Byte; // @offset 0x60
    Fuel: Integer; // @offset 0x64
    Capacity: Byte; // @offset 0x68

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x73A970 @ida "void __userpurge $name(TFuelTanks *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x73A230
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x73A278
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x73A2C8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x73A45C

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x73A1C0
    function CalculateGeneratedCapacity: Byte; // @addr 0x73A5E8
    function CalculateGeneratedCost: Integer; // @addr 0x73A6D0

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x73A6FC
    function HasStandardStats: Boolean; override; // @addr 0x73A838
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x73ABE0
  end;

  TEngine = class(TEquipment) // @size 0x6C
  public
    TechLevel: Byte; // @offset 0x60
    Speed: Integer; // @offset 0x64
    JumpRange: ShortInt; // @offset 0x68
    OutputPercent: Byte; // @offset 0x69

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x73BA1C @ida "void __userpurge $name(TEngine *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x73B030
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x73B084
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x73B104
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x73B290

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x73AFB8
    function CalculateGeneratedSpeed: Integer; // @addr 0x73B414
    function CalculateGeneratedJumpRange: ShortInt; // @addr 0x73B43C
    function CalculateGeneratedCost: Integer; // @addr 0x73B4F4

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x73B520
    function HasStandardStats: Boolean; override; // @addr 0x73B93C
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x73BC20
  end;

  TRadar = class(TEquipment) // @size 0x68
  public
    TechLevel: Byte; // @offset 0x60
    Range: Integer; // @offset 0x64

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x73CD7C @ida "void __userpurge $name(TRadar *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x73C7C0
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x73C7F8
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x73C838
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x73C960

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x73C75C
    function CalculateGeneratedRange: Integer; // @addr 0x73CA84
    function CalculateGeneratedCost: Integer; // @addr 0x73CB40

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x73CB6C
    function HasStandardStats: Boolean; override; // @addr 0x73CD08
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x73CF7C
  end;

  TScaner = class(TEquipment) // @size 0x64
  public
    TechLevel: Byte; // @offset 0x60
    ScanPower: ShortInt; // @offset 0x61

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x73DB78 @ida "void __userpurge $name(TScaner *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x73D59C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x73D5D4
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x73D640
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x73D764

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x73D538
    function CalculateGeneratedScanPower: Integer; // @addr 0x73D880
    function CalculateGeneratedCost: Integer; // @addr 0x73D944

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x73D970
    function HasStandardStats: Boolean; override; // @addr 0x73DB00
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x73DD7C
  end;

  TRepairRobot = class(TEquipment) // @size 0x64
  public
    TechLevel: Byte; // @offset 0x60
    RepairPoints: Byte; // @offset 0x61

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x73EA04 @ida "void __userpurge $name(TRepairRobot *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x73E39C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x73E3D4
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x73E4D0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x73E5F8

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x73E338
    function CalculateGeneratedRepairPoints: Byte; // @addr 0x73E718
    function CalculateGeneratedCost: Integer; // @addr 0x73E7D0

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x73E7FC
    function HasStandardStats: Boolean; override; // @addr 0x73E98C
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x73EC28
  end;

  TCargoHook = class(TEquipment) // @size 0x74
  public
    TechLevel: Byte; // @offset 0x60
    PickupPower: Integer; // @offset 0x64
    Range: Integer; // @offset 0x68
    MinPullSpeed: Single; // @offset 0x6C
    MaxPullSpeed: Single; // @offset 0x70

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x73FE70 @ida "void __userpurge $name(TCargoHook *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x73F2D8
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x73F33C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x73F3AC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x73F630

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x73F248
    function CalculateGeneratedPickupPower: Integer; // @addr 0x73F860
    function CalculateGeneratedRange: Integer; // @addr 0x73F888
    function CalculateGeneratedMinPullSpeed: Single; // @addr 0x73F8B0
    function CalculateGeneratedMaxPullSpeed: Single; // @addr 0x73F8D8
    function CalculateGeneratedCost: Integer; // @addr 0x73F994

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x73F9C0
    function HasStandardStats: Boolean; override; // @addr 0x73FD94
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x740088
    constructor Create; // @addr 0x73F204 @ida "TCargoHook *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
  end;

  TDefGenerator = class(TEquipment) // @size 0x68
  public
    TechLevel: Byte; // @offset 0x60
    DamageFactor: Single; // @offset 0x64

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7412F4 @ida "void __userpurge $name(TDefGenerator *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x740D74
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x740DAC
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x740DEC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x740F20

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x740D08
    function CalculateGeneratedDamageFactor: Single; // @addr 0x741028

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x741168
    function HasStandardStats: Boolean; override; // @addr 0x74125C
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x74151C
  end;

  TWeapon = class(TEquipment) // @size 0x80
  public
    TechLevel: Byte; // @offset 0x60
    Range: Integer; // @offset 0x64
    MinDamage: Integer; // @offset 0x68
    MaxDamage: Integer; // @offset 0x6C
    Target: TObject; // @offset 0x70  Saved as an ID until ResolveLoadedReferences.
    LoadedTargetKind: TWeaponTargetKind; // @offset 0x74  Discriminator read from the save, not a live target classification.
    Ammo: Integer; // @offset 0x78
    AmmoCapacity: Integer; // @offset 0x7C

    function GetDisplayName: WideString; override; // @addr 0x74333C @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetShortName: WideString; override; // @addr 0x74344C @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x743508 @ida "void __userpurge $name(TWeapon *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x741CF0
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x741EC0
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x7427FC
    procedure ClearReferences; override; // @addr 0x7428C4
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7420F0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x742470

    procedure Init(ItemType: TItemType; Weight: Integer; Level, Owner: Byte); // @addr 0x741B4C
    procedure Unequip; override; // @addr 0x7428E8
    function GetConfigName: WideString; virtual; // @addr 0x745120 @slot 0x4C @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetWeaponInfo: PWeaponInfo; virtual; // @addr 0x7450D4 @slot 0x50 @calls "0x70995B 0x744DA3 0x7429F1 0x742BC3"
    function CalculateGeneratedAmmoCapacity: Integer; // @addr 0x742904
    function CalculateGeneratedMinDamage: Integer; // @addr 0x742924
    function CalculateGeneratedMaxDamage: Integer; // @addr 0x742964
    function CalculateGeneratedRange: Integer; // @addr 0x7429A4
    function GetAttackCount: Integer; // @addr 0x745004
    function GetShotCount: Integer; // @addr 0x744F14
    function GetShotDelayFactor: Double; // @addr 0x7449E8
    function NeedsAmmo: Boolean; // @addr 0x744D58
    function CalculateAmmoRefillCost: Integer; // @addr 0x744D90
    function GetShotPalette: Integer; // @addr 0x744E04
    function GetDamageFlags: TDamageFlagSet; // @addr 0x744E5C @ida "unsigned int __usercall $name@<eax>(TWeapon *Self@<eax>);" @note "Combines the weapon template and installed ordinary, special and extra-special module flags."

    function GetDescriptionText: WideString; override; // @addr 0x74493C @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x744AF8 @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure Improve(Kind: TImprovementKind); override; // @addr 0x742B8C
    function HasStandardStats: Boolean; override; // @addr 0x743300
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7437B8
    destructor Destroy; override; // @addr 0x741B18 @ida "void __usercall $name(TWeapon *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function CalculateStandardMaxDamage: Integer; // @addr 0x7429D8 @note "Generated maximum plus ordinary and special module damage bonuses; used by HasStandardStats."
    function CalculateStandardRange: Integer; // @addr 0x742A68 @note "Generated range plus ordinary and special module range bonuses; used by HasStandardStats."
  end;

  // Native class-name spelling.
  TCustomWeapon = class(TWeapon) // @size 0x84
  public
    CustomInfo: PWeaponInfo; // @offset 0x80

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x741E90
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x74207C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7423D4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x742748

    procedure InitCustom(Info: PWeaponInfo; Equipped: Boolean; Weight: Integer; Level, Owner: Byte); // @addr 0x741C10
    function GetWeaponInfo: PWeaponInfo; override; // @addr 0x745104
    function GetConfigName: WideString; override; // @addr 0x745180 @ida "void __usercall $name(TCustomWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"

    function GetBitmapResourceName: WideString; override; // @addr 0x744C20 @ida "void __usercall $name(TCustomWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TGoods = class(TItem) // @size 0x40
  public
    Quantity: Integer; // @offset 0x38
    NaturalFlag: Boolean; // @offset 0x3C

    function GetDisplayName: WideString; override; // @addr 0x745274 @slot 0x18 @ida "void __usercall $name(TGoods *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7452C4 @ida "void __userpurge $name(TGoods *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7451FC
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x745234

    procedure Init(ItemType: TItemType; Quantity: Integer); // @addr 0x7451A4

    function GetDescriptionText: WideString; override; // @addr 0x7453BC @slot 0x24 @ida "void __usercall $name(TGoods *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x745464 @slot 0x28 @ida "void __usercall $name(TGoods *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TCountableItem = class(TEquipment) // @size 0x68
  public
    StackCount: Integer; // @offset 0x60
    DropFlag: Byte; // @offset 0x64

    function GetDisplayName: WideString; override; // @addr 0x745610 @ida "void __usercall $name(TCountableItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7456DC @ida "void __userpurge $name(TCountableItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7454EC
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x745524

    procedure Init(ConfigName: WideString; Count: Integer; DropFlag: Byte); // @addr 0x745564
    function GetUnitSize: Integer; // @addr 0x745A70 @note "Defaults to 1 when UnitSize is not configured."
    function CanMerge(Other: TObject): Boolean; // @addr 0x745E2C
    function Merge(Other: TObject): Boolean; // @addr 0x745EA8 @note "Leaves Other unchanged."

    function GetDescriptionText: WideString; override; // @addr 0x745820 @ida "void __usercall $name(TCountableItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x7458DC @ida "void __usercall $name(TCountableItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function Split(Count: Integer): TCountableItem; // @addr 0x745B68 @note "Allocates a new stack and removes up to Count units from Self; preserves the nodes subtype and may create a script wrapper. Self must be nonempty and Count positive."
  end;

  TProtoplasm = class(TCountableItem) // @size 0x68
  public

    function GetDisplayName: WideString; override; // @addr 0x745F68 @ida "void __usercall $name(TProtoplasm *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x746074 @ida "void __userpurge $name(TProtoplasm *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure Init(Count: Integer; DropFlag: Byte); // @addr 0x745F04

    function GetDescriptionText: WideString; override; // @addr 0x746140 @ida "void __usercall $name(TProtoplasm *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x746190 @ida "void __usercall $name(TProtoplasm *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TEquipmentWithActCode = class(TEquipment) // @size 0x68
  public
    ActionCode: Pointer; // @offset 0x60  Borrowed.
    ActCodeInitialized: Boolean; // @offset 0x64
    DisplayAsArtefact: Boolean; // @offset 0x65

    constructor Create; // @addr 0x746318 @ida "TEquipmentWithActCode *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x746368 @ida "void __usercall $name(TEquipmentWithActCode *Self@<eax>, __int8 DestroyFlags@<dl>);"
  end;

  TUselessItem = class(TEquipmentWithActCode) // @size 0x78
  public
    CustomText: WideString; // @offset 0x68  Script.UselessItemText.
    Data: array[0..2] of Integer; // @offset 0x6C  Script.UselessItemData uses indexes 1..3.

    function GetDisplayName: WideString; override; // @addr 0x746B58 @ida "void __usercall $name(TUselessItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x746C5C @ida "void __userpurge $name(TUselessItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7468D4
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x746928
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x746A20
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x746AB0

    constructor Create; // @addr 0x7463A4 @ida "TUselessItem *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7463EC @ida "void __usercall $name(TUselessItem *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Init(ConfigName: WideString; Series: TDominatorSeries; Seed: Cardinal; ForceArtefactDisplay: Boolean); // @addr 0x746454
    procedure CheckIfWeDisplayAsArtefact; // @addr 0x747294
    function GetActionCode: Pointer; // @addr 0x74738C

    function GetDescriptionText: WideString; override; // @addr 0x746E60 @ida "void __usercall $name(TUselessItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x746F54 @ida "void __usercall $name(TUselessItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function IsDominatorRemains: Boolean; // @addr 0x747244 @note "Owner is Dominator and ConfigBlockName starts with Remains_."
    function GetOnUseCodeText: WideString; // @addr 0x7472F4 @ida "void __usercall $name(TUselessItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TCistern = class(TEquipment) // @size 0x68
  public
    Fuel: Integer; // @offset 0x60
    Capacity: Byte; // @offset 0x64

    function GetDisplayName: WideString; override; // @addr 0x747744 @ida "void __usercall $name(TCistern *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7477AC @ida "void __userpurge $name(TCistern *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7474A4
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7474DC
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x74751C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x747634

    procedure Init(Fuel: Integer; Capacity, Owner: Byte); // @addr 0x747424

    function GetDescriptionText: WideString; override; // @addr 0x7478E8 @ida "void __usercall $name(TCistern *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x747940 @ida "void __usercall $name(TCistern *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TSatellite = class(TEquipment) // @size 0x74
  public
    SatelliteTypeId: Byte; // @offset 0x60
    TargetPlanet: Pointer; // @offset 0x64
    TrajectoryIndex: Integer; // @offset 0x68
    WearPerTurn: Single; // @offset 0x6C
    WaterExplorationRate: Byte; // @offset 0x70
    LandExplorationRate: Byte; // @offset 0x71
    HillExplorationRate: Byte; // @offset 0x72

    function GetDisplayName: WideString; override; // @addr 0x748568 @calls "0x7489D8 0x748B42" @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7486F4 @ida "void __userpurge $name(TSatellite *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x747F8C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x74802C
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x748510
    procedure ClearReferences; override; // @addr 0x74854C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7480B0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7482FC

    procedure InitGenerated(TypeId, Owner: Byte; Seed: Cardinal); // @addr 0x747A10 @note "Clears deployment state."

    function GetDescriptionText: WideString; override; // @addr 0x748C60 @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x748D20 @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBrokenInUseText: WideString; // @addr 0x74894C @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetIdleInfoText: WideString; // @addr 0x748AB4 @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TTreasureMap = class(TEquipment) // @size 0x70
  public
    TargetPlanet: Pointer; // @offset 0x60  Saved as an ID until ResolveLoadedReferences.
    SourceShipName: WideString; // @offset 0x64
    PreviewTablePage1: WideString; // @offset 0x68
    PreviewTablePage2: WideString; // @offset 0x6C

    function GetDisplayName: WideString; override; // @addr 0x7490F4 @ida "void __usercall $name(TTreasureMap *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x749164 @ida "void __userpurge $name(TTreasureMap *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x748F6C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x748FE4
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x74909C
    procedure ClearReferences; override; // @addr 0x7490D8

    procedure Init(Planet: Pointer; Victim: Pointer); // @addr 0x748E20
    function GetTargetPlanetName: WideString; // @addr 0x749454 @ida "void __usercall $name(TTreasureMap *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function BuildPreviewTable(PageIndex: Integer; Planet: Pointer): WideString; // @addr 0x7495E0 @ida "void __userpurge $name(TTreasureMap *Self@<eax>, int PageIndex@<edx>, TPlanet *Planet@<ecx>, unsigned __int16 **Result@<^0>);" @note "PageIndex is 1 or 2; Planet must be assigned."

    function GetDescriptionText: WideString; override; // @addr 0x7492F8 @ida "void __usercall $name(TTreasureMap *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x749358 @ida "void __usercall $name(TTreasureMap *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TMicroModule = class(TEquipment) // @size 0x60
  public

    function GetDisplayName: WideString; override; // @addr 0x74A2D0 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x74A588 @ida "void __userpurge $name(TMicroModule *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x74A26C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x74A288

    procedure Init(ModuleIndex: Integer); // @addr 0x74A128 @note "ModuleIndex is zero-based and must identify an existing template."
    function GetPlainName: WideString; // @addr 0x74A438 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);"

    function GetDescriptionText: WideString; override; // @addr 0x74A9F0 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x74AA08 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetHighlightedName: WideString; // @addr 0x74C090 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Template name wrapped in the standard yellow highlight color."
    function CalculateNodeExchangeValue(LowPriorityOfferCost, MediumPriorityOfferCost: Integer): Integer; // @addr 0x74BD20 @note "Node refund at the current ranger center, using priority and docked station ID. Priorities 31..69 are capped by half LowPriorityOfferCost; 70..100 by half MediumPriorityOfferCost. Minimum 5 nodes."
    function CanInstallOn(Item: TEquipment): Boolean; // @addr 0x74C0F0 @note "Uses this micromodule item's template and checks slot blockers and equipment compatibility."
  end;

  TArtefact = class(TEquipmentWithActCode) // @size 0x68
  public

    function GetDisplayName: WideString; override; // @addr 0x74D698 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x74D758 @ida "void __userpurge $name(TArtefact *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x74CB20

    constructor Create; // @addr 0x74CA68 @ida "TArtefact *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x74CAB8 @ida "void __usercall $name(TArtefact *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Init(Owner: Byte; ItemType: TItemType); virtual; // @addr 0x74CB68 @slot 0x4C
    function GetEffectiveType: TItemType; // @addr 0x74DBDC @note "Custom artefacts with SharedEffect use CountsAsItemType; otherwise returns ItemType."
    function GetOnUseCodeText: WideString; // @addr 0x74D9C0 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Returns empty when the OnUseCode block is absent."
    function GetActionCode: Pointer; // @addr 0x74DAB4 @note "Borrowed cached result, possibly nil. Marks initialization before resolving the configuration."
    function GetBoostStatusText: WideString; // @addr 0x74F1F0 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Uses the active equipment screen's ship; empty for broken artefacts or without a supported screen context."

    function GetDescriptionText: WideString; override; // @addr 0x74D910 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x74D590 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TArtefactTransmitter = class(TArtefact) // @size 0x6C
  public
    Power: Integer; // @offset 0x68

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x74DE18 @ida "void __userpurge $name(TArtefactTransmitter *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x74DC70
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x74DC9C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x74DCCC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x74DD74

    procedure InitTransmitter(Owner: Byte); // @addr 0x74DC18
  end;

  TArtefactTranclucator = class(TArtefact) // @size 0x6C
  public
    Ship: Pointer; // @offset 0x68  Owned while stored in the artefact; deployment transfers ownership.

    function GetDisplayName: WideString; override; // @addr 0x74E3D8 @ida "void __usercall $name(TArtefactTranclucator *Self@<eax>, unsigned __int16 **Result@<edx>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x74E14C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x74E180
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x74E37C
    procedure ClearReferences; override; // @addr 0x74E3B0
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x74E1EC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x74E2B4

    destructor Destroy; override; // @addr 0x74DF68 @ida "void __usercall $name(TArtefactTranclucator *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitTranclucator(Owner: Byte; OwnerShip: Pointer; ExistingShip: Pointer); // @addr 0x74DFB8 @note "Takes ownership of ExistingShip, or creates a ship when nil."
    function Clone: TItem; override; // @addr 0x74E1D4 @note "Always returns nil."
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

    function GetDisplayName: WideString; override; // @addr 0x74F058 @ida "void __usercall $name(TArtefactCustom *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x74EDB8 @ida "void __userpurge $name(TArtefactCustom *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x74E814
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x74E8F8
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x74EA08
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x74EBF8

    procedure LoadConfig(ApplyConfiguredWeight: Boolean); // @addr 0x74E578 @note "Uses ConfigBlockName. Reloads NoWear, CountsAs, SharedUse and SharedEffect; preserves Data and TextData."

    function GetDescriptionText: WideString; override; // @addr 0x74F12C @ida "void __usercall $name(TArtefactCustom *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

// Nested native helpers include the caller's saved EBP explicitly in the IDA ABI.

function CreateRandomLootItem(Pool: TItemLootPool; Owner: Byte; Seed: Cardinal): TEquipmentWithActCode; // @addr 0x74C8E0 @note "Selects across built-in artefacts, custom artefacts and configured useless items. Pool must be nonempty; AnyAvailable is the union of the three eligibility flags."

function ReadSavedMicroModuleIndex(Buffer: TBufEC): Integer; // @addr 0x733458 @note "Returns a one-based template index, or 0 if the saved template cannot be resolved."
function MigrateSavedItemType(ItemType: Byte): TItemType; // @addr 0x74FD00 @note "Applies the ordered item-type insertions for save versions before 164, 78, 131, 78 and 127; arithmetic wraps in a byte."

function GetBaseHullSlotCount(Kind: TShipSlotKind; HullType, Owner: Byte; Ship: Pointer): Integer; // @addr 0x739B98
function CalculateGeneratedHullCost(Capacity, Level: Cardinal; Owner, HullType: Byte): Integer; // @addr 0x737D68
function CalculateGeneratedFuelCapacity(Weight: Cardinal; Level: Integer): Integer; // @addr 0x73A610
function CalculateGeneratedFuelTanksCost(Weight: Cardinal; Level: Integer; Owner: Byte): Integer; // @addr 0x73A664
function CalculateGeneratedEngineCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x73B460
function CalculateGeneratedRadarCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x73CAAC
function CalculateGeneratedScanerCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x73D8B0
function CalculateGeneratedRepairRobotCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x73E73C
function CalculateGeneratedCargoHookCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x73F900
function CalculateGeneratedDefGeneratorCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x7410D4
function GetGeneratedDefenseDamageFactor(Level: Byte): Double; // @addr 0x74104C
function DefenseDamageFactorToPercent(Factor: Double): TPercent; // @addr 0x741070 @ida "unsigned __int8 __userpurge $name@<al>(double Factor@<^0>);"
function DefensePercentToDamageFactor(Percent: Integer): Double; // @addr 0x74109C

function GetMicroModuleInfoText(ModuleIndex: Integer; ColorTag: WideString): WideString; // @addr 0x74A5E4 @ida "void __usercall $name(int ModuleIndex@<eax>, unsigned __int16 *ColorTag@<edx>, unsigned __int16 **Result@<ecx>);" @note "ModuleIndex is zero-based. Expands all bonus tokens in the configured description."

function GetMicroModulePriorityColorTier(ModuleIndex: Integer): Byte; // @addr 0x74AAA4
function GetMicroModuleNameColorTag(ModuleIndex: Integer): WideString; // @addr 0x74AAEC @ida "void __usercall $name(int ModuleIndex@<eax>, unsigned __int16 **Result@<edx>);"
function GetMicroModuleTextColorTag(ModuleIndex: Integer): WideString; // @addr 0x74AC14 @ida "void __usercall $name(int ModuleIndex@<eax>, unsigned __int16 **Result@<edx>);"
function GetMicroModuleBitmapResourceName(ModuleIndex: Integer): WideString; // @addr 0x74ACBC @ida "void __usercall $name(int ModuleIndex@<eax>, unsigned __int16 **Result@<edx>);"

function CreateConfiguredArtefactByItemType(ItemType: TItemType; Owner: Byte): TArtefact; // @addr 0x74C874 @note "Returns nil outside item types 10..41."

function CalculateGeneratedWeaponCost(Info: PWeaponInfo; Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x742AC8

function CreateItemByType(ItemType: TItemType): TItem; // @addr 0x74F41C @note "Constructs the instance without calling its Init routine."
function CreateDefaultItemByType(ItemType: TItemType): TItem; // @addr 0x74F6D4
function CreateGeneratedEquipment(ItemType: TItemType; Weight, Level: Integer; Owner: Byte): TEquipment; // @addr 0x74F8DC @note "Clamps Level to 1..8; custom weapons require CreateGeneratedWeapon."
function CreateGeneratedWeapon(Info: PWeaponInfo; Weight, Level: Integer; Owner: Byte): TWeapon; // @addr 0x74FAD4

// Module indices are zero-based; compatibility checks also accept special bonuses.
function CanInstallMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x74C1E0
function IsBonusCompatibleWithEquipment(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x74C2D0
function IsBonusCompatibleWithHull(ModuleIndex: Integer; Hull: THull): Boolean; // @addr 0x74C430
function IsBonusCompatibleWithWeapon(ModuleIndex: Integer; Weapon: TWeapon): Boolean; // @addr 0x74C5A0
function ApplyMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x74ADEC @note "Does not check compatibility or remove an existing module; -1 or nil returns False."
procedure ApplySpecialMicroModule(ModuleIndex: Integer; Item: TEquipment); // @addr 0x74B808
procedure RemoveMicroModule(Item: TEquipment); // @addr 0x74B354
procedure RemoveSpecialMicroModule(Item: TEquipment); // @addr 0x74BAB4

function CanCargoHookHandleItem(Item: TItem; Ship: Pointer): Boolean; // @addr 0x732FA4

function GetItemTypeBitmapPath(ItemType: TItemType): WideString; // @addr $74FB38 @ida "void __usercall $name(unsigned __int8 ItemType@<al>, unsigned __int16 **Result@<edx>);"

function GetStackableItemTypeName(ItemType: TItemType): WideString; // @addr $74FBBC @ida "void __usercall $name(unsigned __int8 ItemType@<al>, unsigned __int16 **Result@<edx>);" @note "Goods use their market display name; nodes use the generic node name; other types return empty."
function GetStackableItemName(Item: TItem): WideString; // @addr $74FC30 @ida "void __usercall $name(TItem *Item@<eax>, unsigned __int16 **Result@<edx>);" @note "Custom countables use their configured name; all other types use GetStackableItemTypeName. Ignores per-instance name overrides."

implementation

// @unit-initialization $876A1C
// @unit-finalization $74FD7C

uses aPlanet, aTranclucator, aPirate, SysUtils, SE_Process, GR_Main, aConst, aPlayer, aScript, aMyFunction, Math, aShip, aKling, EC_Str, aAsteroid, aMissile, Globals, fShip2;

{ @routine $7315B0 TItem_Create }
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
{ @end $7315B0 }

{ @routine $731620 TItem_Destroy }
destructor TItem.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) and (ScriptItem <> nil) then
    TScriptItem(ScriptItem).RunActionCode(satOnItemDestroy, nil, nil, nil, 0);
  Id := 0;
  if ScriptItem <> nil then
  begin
    (ScriptItem as TScriptItem).Item := nil;
    ScriptItem := nil;
  end;
  if GraphObject <> nil then ReleaseSpaceObject(GraphObject);
  inherited Destroy;
end;
{ @end $731620 }

{ @routine $7316D8 TItem_SaveToBuffer }
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
{ @end $7316D8 }

{ @routine $73179C TItem_LoadFromBuffer }
procedure TItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  Id := Buffer.GetUInt32;
  if Galaxy.NextItemId <= Cardinal(Id) then Galaxy.NextItemId := Id + 1;
  ItemType := MigrateSavedItemType(Buffer.GetByte);
  Position.X := Buffer.GetSingle;
  Position.Y := Buffer.GetSingle;
  Weight := Buffer.GetInt32;
  OwnerId := Buffer.GetByte;
  Cost := Buffer.GetUInt32;
  DestroyFlag := Buffer.GetInt32;
  if Buffer.GetBoolean then NameOverride := Buffer.ReadWideString;
  NoDropFlag := Buffer.GetByte;
end;
{ @end $73179C }

{ @routine $7318A8 TItem_SaveToBlock }
procedure TItem.SaveToBlock(Block: TBlockParEC);
begin
  Block.AddParam(DecodeTextW('IQNaaWmee'), GetDisplayName); // Decoded: 'IName'
  Block.AddParam(DecodeTextW('InToyAple'), ItemTypeNames[Ord(ItemType)]); // Decoded: 'IType'
  Block.AddParam(DecodeTextW('OpwRn3ewr'), OwnerInfo[OwnerId].InternalName); // Decoded: 'Owner'
  Block.AddParam(DecodeTextW('SaiRzoe'), IntToStr(Weight)); // Decoded: 'Size'
  Block.AddParam(DecodeTextW('CfoTsat'), IntToStr(Cost)); // Decoded: 'Cost'
  Block.AddParam(DecodeTextW('NeonDarlokpl'), IntToStr(NoDropFlag)); // Decoded: 'NoDrop'
  if ScriptItem <> nil then
    Block.AddParam(DecodeTextW('IsSacaraiOpit'), TScriptItem(ScriptItem).Script.ScriptFileName); // Decoded: 'IScript'
end;
{ @end $7318A8 }

{ @routine $731B2C TItem_LoadFromBlock }
procedure TItem.LoadFromBlock(Block: TBlockParEC);
var
  I: Integer;
  Text: WideString;
begin
  Text := Block.GetParam(DecodeTextW('OpwRn3ewr')); // Decoded: 'Owner'
  for I := 0 to 7 do
    if Text = OwnerInfo[Byte(I)].InternalName then OwnerId := I;
  Weight := StrToInt(Block.GetParam(DecodeTextW('SaiRzoe'))); // Decoded: 'Size'
  Cost := StrToInt(Block.GetParam(DecodeTextW('CfoTsat'))); // Decoded: 'Cost'
  Text := LowerCase(Block.GetParam(DecodeTextW('NeonDarlokpl'))); // Decoded: 'NoDrop'
  if Text = 'false' then NoDropFlag := 0
  else if Text = 'true' then NoDropFlag := 1
  else NoDropFlag := StrToInt(Text);
  if Self is TGoods then (Self as TGoods).Quantity := Weight;
  if Self is TCountableItem then (Self as TCountableItem).StackCount := Weight div (Self as TCountableItem).GetUnitSize;
  if (ItemType = t_ArtefactTranclucator) and ((Self as TArtefactTranclucator).Ship <> nil) then
    TTranclucator((Self as TArtefactTranclucator).Ship).ArtefactSize := Weight;
end;
{ @end $731B2C }

{ @routine $731E28 TItem_ResolveLoadedReferences }
procedure TItem.ResolveLoadedReferences(Galaxy: TGalaxy);
begin

end;
{ @end $731E28 }

{ @routine $731E38 TItem_ClearReferences }
procedure TItem.ClearReferences;
begin

end;
{ @end $731E38 }

{ @routine $731E44 TItem_GetSmallInfoText }
function TItem.GetSmallInfoText: WideString;
begin
  Result := LookupLocalizedTextByKey('Items.SmallInfo');
end;
{ @end $731E44 }

{ @routine $731E88 TItem_CalculateResaleValue }
function TItem.CalculateResaleValue(TradingSkill: Byte): Integer;
begin
  if Self is TEquipment then
    Result := Max(1, Round((Cost - (Self as TEquipment).CalculateRepairCost) * 0.01 * PilotSkillEffects[TradingSkill, Ord(psTrading)]))
  else Result := Round(Cost * 0.01 * PilotSkillEffects[TradingSkill, Ord(psTrading)]);
end;
{ @end $731E88 }

{ @routine $731F74 TItem_GetConditionAdjustedCost }
function TItem.GetConditionAdjustedCost: Integer;
begin
  if Self is TEquipment then Result := Max(1, Cost - (Self as TEquipment).CalculateRepairCost)
  else Result := Cost;
end;
{ @end $731F74 }

{ @routine $731FDC TItem_GetCategoryConfigName }
function TItem.GetCategoryConfigName: WideString;
begin
  if ItemType in [t_Weapon1..t_CustomWeapon] then Result := 'Weapon'
  else if ItemType in [t_ArtefactHull..t_ArtFastRacks] then Result := 'Artefact'
  else Result := ItemTypeNames[Ord(ItemType)];
end;
{ @end $731FDC }

{ @routine $732068 TItem_GetShortName }
function TItem.GetShortName: WideString;
begin
  Result := '';
end;
{ @end $732068 }

{ @routine $732080 TItem_GetInfoText }
function TItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := '';
end;
{ @end $732080 }

{ @routine $732184 TItem_GetGraphObject }
function TItem.GetGraphObject: TObjectSE;

  // @nested $7320D0 CreateContainer
  procedure CreateContainer(GraphKey: WideString); // @addr 0x7320D0 @ida "void __usercall $name(unsigned __int16 *GraphKey@<eax>, void *ParentFrame@<^0>);" @note "Captures the item at ParentFrame-4; caller removes ParentFrame."
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
    else if ItemType = t_ArtefactBomb then CreateContainer('Bomb')
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
      if Weight <= 29 then CreateContainer('n0_' + IntToStr(Cardinal(Id) mod 5))
      else if Weight <= 59 then CreateContainer('n1_' + IntToStr(Cardinal(Id) mod 5))
      else if Weight <= 99 then CreateContainer('n2_' + IntToStr(Cardinal(Id) mod 5))
      else CreateContainer('n3_' + IntToStr(Cardinal(Id) mod 5));
    end
    else if (Self is TCountableItem) and ((Self as TCountableItem).DropFlag <> 0) then
    begin
      if Weight <= 29 then CreateContainer((Self as TCountableItem).ConfigBlockName + '0_' + WideString(IntToStr(Cardinal(Id) mod 5)))
      else if Weight <= 59 then CreateContainer((Self as TCountableItem).ConfigBlockName + '1_' + WideString(IntToStr(Cardinal(Id) mod 5)))
      else if Weight <= 99 then CreateContainer((Self as TCountableItem).ConfigBlockName + '2_' + WideString(IntToStr(Cardinal(Id) mod 5)))
      else CreateContainer((Self as TCountableItem).ConfigBlockName + '3_' + WideString(IntToStr(Cardinal(Id) mod 5)));
    end
    else if (Self is TEquipment) and ((Self as TEquipment).CustomFaction <> '') then
    begin
      if Weight <= 29 then CreateContainer((Self as TEquipment).CustomFaction + '0')
      else if Weight <= 59 then CreateContainer((Self as TEquipment).CustomFaction + '1')
      else if Weight <= 99 then CreateContainer((Self as TEquipment).CustomFaction + '2')
      else CreateContainer((Self as TEquipment).CustomFaction + '3');
    end
    else if (Self is TEquipment) and (OwnerId = Byte(oiDominator)) then
    begin
      if (Self as TEquipment).DominatorSeries = dsBlazer then
      begin
        if Weight <= 29 then CreateContainer('db0')
        else if Weight <= 59 then CreateContainer('db1')
        else if Weight <= 99 then CreateContainer('db2')
        else CreateContainer('db3');
      end
      else if (Self as TEquipment).DominatorSeries = dsKeller then
      begin
        if Weight <= 29 then CreateContainer('dk0')
        else if Weight <= 59 then CreateContainer('dk1')
        else if Weight <= 99 then CreateContainer('dk2')
        else CreateContainer('dk3');
      end
      else if (Self as TEquipment).DominatorSeries = dsTerron then
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
{ @end $732184 }

{ @routine $732F84 TItem_ReleaseGraphObject }
procedure TItem.ReleaseGraphObject;
begin
  if GraphObject <> nil then ReleaseSpaceObject(GraphObject);
end;
{ @end $732F84 }

{ @routine $732FA4 CanCargoHookHandleItem }
function CanCargoHookHandleItem(Item: TItem; Ship: Pointer): Boolean;
var Owner: TShip;
begin
  Owner := TShip(Ship);
  Result := False;
  if not Owner.IsEquipmentUsable(Owner.GetCargoHook) then Exit;
  if Owner.CalculateCargoHookPower(Owner.GetCargoHook) < Item.Weight then Exit;
  if (Item is TUselessItem) and (TUselessItem(Item).ConfigBlockName = 'ExampleAsteroid') then Exit;
  if GetPlayer <> Owner then
  begin
    if (Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '') then Exit;
    if (Item is TSatellite) or (Item.DestroyFlag > 0) then Exit;
  end;
  Result := True;
end;
{ @end $732FA4 }

{ @routine $733084 TItem_GetOwnerConfigName }
function TItem.GetOwnerConfigName: WideString;
begin
  if Self is TGoods then Result := OwnerInfo[Ord(oiUninhabited)].InternalName
  else if TEquipment(Self).CustomFaction <> '' then Result := TEquipment(Self).CustomFaction
  else if (OwnerId = Byte(oiDominator)) and (Self is TEquipment) then Result := DominatorSeriesNames[Ord(TEquipment(Self).DominatorSeries)]
  else if (Self is THull) and (Self as THull).PirateBuilt then Result := OwnerInfo[Ord(oiPirate)].InternalName + OwnerToSys(OwnerId)
  else Result := OwnerInfo[OwnerId].InternalName;
end;
{ @end $733084 }

{ @routine $7331B0 TEquipment_Create }
constructor TEquipment.Create;
begin
  inherited Create;
  ExtraSpecials := nil;
  EquippedFlag := 0;
end;
{ @end $7331B0 }

{ @routine $733200 TEquipment_Destroy }
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
{ @end $733200 }

{ @routine $73328C TEquipment_SaveToBuffer }
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
{ @end $73328C }

{ @routine $733458 ReadSavedMicroModuleIndex }
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
{ @end $733458 }

{ @routine $733550 TEquipment_LoadFromBuffer }
procedure TEquipment.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var ConfigNumber, Count, Index, ExistingIndex, ModuleIndex: Integer; Entry: PExtraSpecial;

  // @nested $7334F4 FindLegacyMicroModuleIndex
  function FindLegacyMicroModuleIndex(ConfigNumber: Integer): Integer; // @addr 0x7334F4 @ida "int __usercall $name@<eax>(int ConfigNumber@<eax>, void *ParentFrame@<^0>);" @note "Returns a one-based template index, or 0 if absent."
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to High(MicroModuleTemplates) do
      if MicroModuleTemplates[I].ConfigNumber = ConfigNumber then
      begin
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
        if (High(MicroModuleTemplates) + 1 < MicroModuleIndex) or
          (MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber <> ConfigNumber) then
          MicroModuleIndex := FindLegacyMicroModuleIndex(ConfigNumber);
      end;
      if SpecialModuleIndex > 0 then
      begin
        ConfigNumber := Buffer.GetInt32;
        if (High(MicroModuleTemplates) + 1 < SpecialModuleIndex) or
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
          if (High(MicroModuleTemplates) + 1 < ModuleIndex) or
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
{ @end $733550 }

{ @routine $7339EC TEquipment_Clone }
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
{ @end $7339EC }

{ @routine $733A90 TEquipment_SaveToBlock }
procedure TEquipment.SaveToBlock(Block: TBlockParEC);
var
  I: Integer;
  Entry: PExtraSpecial;
  Text, ModuleName: WideString;
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('DyuRrdawbRiblNijtSyp'), FloatToStr(ConditionPercent)); // Decoded: 'Durability'
  Block.AddParam(DecodeTextW('BorYorkNeln'), BoolToWideString(Boolean(BrokenFlag))); // Decoded: 'Broken'
  Block.AddParam(DecodeTextW('BrognWulso'), IntToStr(MicroModuleIndex)); // Decoded: 'Bonus'
  if MicroModuleIndex <> 0 then
    Block.AddParam(DecodeTextW('IQBaodn4ursTNgatm2e'), MicroModuleTemplates[MicroModuleIndex - 1].Name); // Decoded: 'IBonusName'
  Block.AddParam(DecodeTextW('SrpeeIcjigaEl4'), IntToStr(SpecialModuleIndex)); // Decoded: 'Special'
  if SpecialModuleIndex <> 0 then
    Block.AddParam(DecodeTextW('IaSopRefcGihajl6NtaEm3ew'), MicroModuleTemplates[SpecialModuleIndex - 1].Name); // Decoded: 'ISpecialName'
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
      Block.AddParam(DecodeTextW('IaEoxRtfrGahSjp6etcEi3awlhs4'), Text); // Decoded: 'IExtraSpecials'
  end;
  Block.AddParam(DecodeTextW('D9o5meScewr3iwegs4'), DominatorSeriesNames[Ord(DominatorSeries)]); // Decoded: 'DomSeries'
end;
{ @end $733A90 }

{ @routine $733F88 TEquipment_LoadFromBlock }
procedure TEquipment.LoadFromBlock(Block: TBlockParEC);
var
  I: Integer;
  Text: WideString;
begin
  inherited LoadFromBlock(Block);
  ConditionPercent := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('DyuRrdawbRiblNijtSyp'))); // Decoded: 'Durability'
  BrokenFlag := Byte(LowerCase(Block.GetParam(DecodeTextW('BorYorkNeln'))) = 'true'); // Decoded: 'Broken'
  MicroModuleIndex := StrToInt(Block.GetParam(DecodeTextW('BrognWulso'))); // Decoded: 'Bonus'
  SpecialModuleIndex := StrToInt(Block.GetParam(DecodeTextW('SrpeeIcjigaEl4'))); // Decoded: 'Special'
  Text := Block.GetParam(DecodeTextW('D9o5meScewr3iwegs4')); // Decoded: 'DomSeries'
  for I := 0 to 2 do
    if Text = DominatorSeriesNames[Byte(I)] then DominatorSeries := TDominatorSeries(I);
end;
{ @end $733F88 }

{ @routine $73420C TEquipment_Equip }
procedure TEquipment.Equip;
begin
  EquippedFlag := 1;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then Exit;
  if ScriptItem <> nil then TScriptItem(ScriptItem).RunActionCode(satOnItemEquip, nil, nil, nil, 0);
  if Self is TEquipmentWithActCode then RunItemConfigActionCode(Self, satOnItemEquip, nil, nil, nil, 0);
end;
{ @end $73420C }

{ @routine $734284 TEquipment_Unequip }
procedure TEquipment.Unequip;
begin
  EquippedFlag := 0;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then Exit;
  if ScriptItem <> nil then TScriptItem(ScriptItem).RunActionCode(satOnItemDeEquip, nil, nil, nil, 0);
  if Self is TEquipmentWithActCode then RunItemConfigActionCode(Self, satOnItemDeEquip, nil, nil, nil, 0);
end;
{ @end $734284 }

{ @routine $7342FC TEquipment_Repair }
procedure TEquipment.Repair;
begin
  ConditionPercent := 100;
  BrokenFlag := 0;
end;
{ @end $7342FC }

{ @routine $73431C TEquipment_NeedsRepair }
function TEquipment.NeedsRepair: Boolean;
const
  RepairableTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
begin
  if ItemType = t_Hull then
    Result := (Self as THull).HullPoints < (Self as THull).Weight
  else
    Result := (Byte(ItemType) in RepairableTypes) and (ConditionPercent < 90);
end;
{ @end $73431C }

{ @routine $7343A0 TEquipment_CalculateRepairCost }
function TEquipment.CalculateRepairCost: Integer;
var DamagePercent: Double;
begin
  if Self is TCountableItem then
  begin
    Result := 0;
    Exit;
  end;
  if ItemType = t_Hull then
  begin
    Result := 0;
    if (Self as THull).Weight - (Self as THull).HullPoints <> 0 then
    begin
      DamagePercent := 100 / (Self as THull).Weight * ((Self as THull).Weight - (Self as THull).HullPoints);
      Result := RoundAndTruncateToTens((Cost div 40) / 100 * DamagePercent + 10);
    end;
  end
  else if ItemType in [t_FuelTanks..t_CustomWeapon, t_Satellite] then
  begin
    if ConditionPercent = 100 then Result := 0
    else Result := RoundAndTruncateToTens((100 - Round(ConditionPercent)) * ((Cost div 7) / 100) + Cost div 20 + 10);
    if BrokenFlag <> 0 then Result := Round(Result * 1.3);
  end
  else if ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks] then
  begin
    if ConditionPercent = 100 then Result := 0
    else Result := RoundAndTruncateToTens((100 - Round(ConditionPercent)) * ((Cost div 5) / 100) + Cost div 10 + 10);
    if BrokenFlag <> 0 then Result := Round(Result * 1.3);
    Result := Result * 2;
  end
  else Result := 0;
end;
{ @end $7343A0 }

{ @routine $734630 TEquipment_GetConditionText }
function TEquipment.GetConditionText(PrefixNewLine: Boolean): WideString;
const SupportedTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
var Prefix: WideString;
begin
  if not (Byte(ItemType) in SupportedTypes) then
  begin
    Result := '';
    Exit;
  end;
  if PrefixNewLine then Prefix := #13#10 else Prefix := '';
  if (GetPlayer <> nil) and not GetPlayer.CanUseEquipmentTech(Self) then
  begin
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeUsed'), '<color=255,0,0>');
    Exit;
  end;
  if (GetPlayer <> nil) and not GetPlayer.CanRepairEquipmentTech(Self) and (BrokenFlag <> 0) and
    not (ItemType in [t_FuelTanks..t_Engine]) then
  begin
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeUsed'), '<color=255,0,0>');
    Exit;
  end;
  if BrokenFlag <> 0 then
  begin
    if ItemType in [t_FuelTanks..t_DefGenerator] then
      Result := WrapTextInColor(Prefix + LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.Broken'), '<color=255,0,0>')
    else if ItemType in [t_Weapon1..t_CustomWeapon] then
      Result := WrapTextInColor(Prefix + LocalizedText('Items.Weapon.Broken'), '<color=255,0,0>')
    else if ItemType in [t_Artefact..t_Artefact2] then
      Result := WrapTextInColor(Prefix + LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Broken'), '<color=255,0,0>')
    else if ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks] then
      Result := WrapTextInColor(Prefix + LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Broken'), '<color=255,0,0>')
    else if ItemType = t_Satellite then
      Result := WrapTextInColor(Prefix + LocalizedText('Items.Satellite.Broken'), '<color=255,0,0>')
    else Result := '';
  end
  else if Self is TArtefact then
  begin
    // Native retains this transmitter branch despite the initial supported-type set.
    if (ItemType = t_ArtefactTransmitter) and ((Self as TArtefactTransmitter).Power < MinTransmitterPower) then
      Result := WrapTextInColor(Prefix + LocalizedText('Artefacts.ArtTransmitter.Broken'), '<color=254,217,7>')
    else Result := '';
  end
  else if ConditionPercent < 20 then
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.SmallDuration'), '<color=254,217,7>')
  else if ConditionPercent < 50 then
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.AverageDuration'), '<color=127,127,127>')
  else Result := '';
  if (GetPlayer <> nil) and not GetPlayer.CanRepairEquipmentTech(Self) then
  begin
    if not PrefixNewLine then Result := '';
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeRepaired'), '<color=127,127,127>') + Result;
  end;
end;
{ @end $734630 }

{ @routine $734D48 TEquipment_GetBrokenInBattleText }
function TEquipment.GetBrokenInBattleText: WideString;
begin
  if ItemType in [t_FuelTanks..t_DefGenerator] then
    Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.BrokenInBattle')
  else if ItemType in [t_Weapon1..t_CustomWeapon] then
    Result := FormatText1(LocalizedText('Items.Weapon.BrokenInBattle'), '<color=255,240,100>', '<Name>', GetDisplayName)
  else if ItemType in [t_Artefact..t_Artefact2] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenInBattle')
  else if ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.BrokenInBattle')
  else Result := '';
end;
{ @end $734D48 }

{ @routine $734FB0 TEquipment_GetBrokenInUseText }
function TEquipment.GetBrokenInUseText: WideString;
begin
  if ItemType in [t_FuelTanks..t_DefGenerator] then
    Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.BrokenInUse')
  else if ItemType in [t_Weapon1..t_CustomWeapon] then
    Result := FormatText1(LocalizedText('Items.Weapon.BrokenInUse'), '<color=255,240,100>', '<Name>', GetDisplayName)
  else if ItemType in [t_Artefact..t_Artefact2] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenInUse')
  else if ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.BrokenInUse')
  else Result := '';
end;
{ @end $734FB0 }

{ @routine $735210 TEquipment_GetBrokenByForceText }
function TEquipment.GetBrokenByForceText: WideString;
begin
  Result := '';
  if ItemType in [t_FuelTanks..t_DefGenerator] then
    Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.BrokenByForce')
  else if ItemType in [t_Weapon1..t_CustomWeapon] then
    Result := FormatText1(LocalizedText('Items.Weapon.BrokenByForce'), '<color=255,240,100>', '<Name>', GetDisplayName)
  else if ItemType in [t_Artefact..t_Artefact2] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenByForce')
  else if ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.BrokenByForce')
  else Exit;
  if Result = '' then Result := GetBrokenInUseText;
end;
{ @end $735210 }

{ @routine $735490 TEquipment_GetLevel }
function TEquipment.GetLevel: Integer;
begin
  case ItemType of
    t_Hull: Result := (Self as THull).TechLevel;
    t_FuelTanks: Result := (Self as TFuelTanks).TechLevel;
    t_Engine: Result := (Self as TEngine).TechLevel;
    t_Radar: Result := (Self as TRadar).TechLevel;
    t_Scaner: Result := (Self as TScaner).TechLevel;
    t_RepairRobot: Result := (Self as TRepairRobot).TechLevel;
    t_CargoHook: Result := (Self as TCargoHook).TechLevel;
    t_DefGenerator: Result := (Self as TDefGenerator).TechLevel;
  else
    if ItemType in [t_Weapon1..t_CustomWeapon] then Result := (Self as TWeapon).TechLevel
    else Result := 0;
  end;
end;
{ @end $735490 }

var
  EquipmentLevelLetters: array[1..8] of WideString = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'); // @addr $87BFF8 Native managed-string defaults.
var
  TreasureMapColumnPositions: array[1..2, 0..3] of Integer = ((20, 40, 280, 380), (20, 40, 380, 490)); // @addr $87C018
  TreasureMapRuleLengths: array[1..2] of Integer = (76, 98); // @addr $87C038

{ @routine $735608 TEquipment_GetLevelLetter }
function TEquipment.GetLevelLetter: WideString;
var Level: Integer;
begin
  Level := GetLevel;
  Result := '';
  if (Level >= 1) and (Level <= 8) then Result := EquipmentLevelLetters[Level];
end;
{ @end $735608 }

{ @routine $73564C TEquipment_GetDescriptionText }
function TEquipment.GetDescriptionText: WideString;
begin
  if (ItemType in [t_FuelTanks..t_DefGenerator]) and (OwnerId = Byte(oiDominator)) then
    Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.KlingDescription.' + IntToStr(GetLevel))
  else Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.Description.' + IntToStr(GetLevel));
end;
{ @end $73564C }

{ @routine $7357C8 TEquipment_GetDisplayName }
function TEquipment.GetDisplayName: WideString;
var TypeName: WideString;
begin
  Result := '';
  if NameOverride <> '' then Result := NameOverride
  else if SpecialModuleIndex <> 0 then
    Result := WrapTextInColor(GetSpecialModuleName, GetMicroModuleTextColorTag(SpecialModuleIndex - 1))
  else if CustomFaction <> '' then
    Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.' + CustomFaction + 'Name');
  if Result = '' then
  begin
    if OwnerId <> Byte(oiDominator) then
    begin
      TypeName := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.Type.' + IntToStr(GetLevel));
      Result := ReplaceColoredToken(LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.Name'), '<Type>', TypeName, '');
    end
    else Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.KlingName');
  end;
  if HasMicroModule then
    Result := Result + ' ' + WrapTextInColor(GetMicroModuleQuotedName, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;
{ @end $7357C8 }

{ @routine $735A98 TEquipment_GetShortName }
function TEquipment.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if OwnerId <> Byte(oiDominator) then
    Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.ShortName')
  else Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.KlingName');
end;
{ @end $735A98 }

{ @routine $735BBC TEquipment_ImproveAtScientificBase }
procedure TEquipment.ImproveAtScientificBase;
begin
  DetailImprovement := (Cardinal(Id) mod 2) + 1;
  case (Cardinal(Id) div 3) mod 6 of
    0: Improve(ikMajor);
    1..2: Improve(ikMedium);
  else Improve(ikMinor);
  end;
end;
{ @end $735BBC }

{ @routine $735C20 TEquipment_HasMicroModule }
function TEquipment.HasMicroModule: Boolean;
begin
  Result := MicroModuleIndex <> 0;
end;
{ @end $735C20 }

{ @routine $735C3C TEquipment_GetMicroModuleQuotedName }
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
{ @end $735C3C }

{ @routine $735CE0 TEquipment_GetSpecialModuleName }
function TEquipment.GetSpecialModuleName: WideString;
begin
  if SpecialModuleIndex <> 0 then Result := MicroModuleTemplates[SpecialModuleIndex - 1].Name
  else Result := '';
end;
{ @end $735CE0 }

{ @routine $735D24 TEquipment_Improve }
procedure TEquipment.Improve(Kind: TImprovementKind);
begin
end;
{ @end $735D24 }

{ @routine $735D34 TEquipment_CalculateImprovementCost }
function TEquipment.CalculateImprovementCost(Kind: TImprovementKind): Integer;
begin
  case Kind of
    ikMinor: Result := RoundAndTruncateToTens(Cost * 0.3);
    ikMedium: Result := RoundAndTruncateToTens(Cost * 0.6);
    ikMajor: Result := RoundAndTruncateToTens(Cost * 1.2);
  else
    RaiseWideMessage(#$041A#$043E#$0441#$044F#$043A' '#$0432' '#$0443#$043B#$0443#$0447#$0448#$0435#$043D#$0438#$0438);
    Result := 0;
  end;
end;
{ @end $735D34 }

{ @routine $735E10 TEquipment_HasStandardStats }
function TEquipment.HasStandardStats: Boolean;
begin
  Result := True;
end;
{ @end $735E10 }

{ @routine $735E24 TEquipment_GetBitmapResourceName }
function TEquipment.GetBitmapResourceName: WideString;
var Path: WideString;
begin
  Result := '';
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0) and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)] + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else if CustomFaction <> '' then
  begin
    Path := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)] + CustomFaction;
    if CacheDataRoot.FileExistsByPath(Path + 'a') and CacheDataRoot.FileExistsByPath(Path + 'i') and
      CacheDataRoot.FileExistsByPath(Path + 's') then Result := Path;
  end;
  if Result = '' then
    if OwnerId = Byte(oiDominator) then Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)] + 'Kling0'
    else Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)] + IntToStr(GetLevel - 1);
end;
{ @end $735E24 }

{ @routine $7360B8 TEquipment_GetFragilityFactor }
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
{ @end $7360B8 }

{ @routine $736230 TEquipment_ReplaceInfoTokens }
procedure TEquipment.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
begin
end;
{ @end $736230 }

{ @routine $736278 TEquipment_GetStatBonus }
function TEquipment.GetStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var I, SpecialBonus: Integer; Entry: PExtraSpecial;
begin
  if (BonusKind in [bonSkill1..bonSkill6, bonStimCapacity]) and (MicroModuleIndex <> 0) then
    Result := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(BonusKind)]
  else Result := 0;
  if (ItemType in [t_Weapon1..t_CustomWeapon]) and
     (BonusKind in [bonWEnergy..bonWRadius, bonMissileSpeed]) then Exit;
  if SpecialModuleIndex <> 0 then
    SpecialBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(BonusKind)]
  else SpecialBonus := 0;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(SpecialBonus, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(BonusKind)] * Entry.Count);
    end;
  if (SpecialBonus <> 0) and (MicroModuleIndex <> 0) and
     not (BonusKind in [bonExtraAkrinEff, bonExtraAkrinPenalty]) then
  begin
    if (BonusKind in [bonMass]) = (SpecialBonus > 0) then
      Inc(SpecialBonus, Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonExtraAkrinPenalty)] * SpecialBonus * 0.0001))
    else
      Inc(SpecialBonus, Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonExtraAkrinEff)] * SpecialBonus * 0.0001));
  end;
  Inc(Result, SpecialBonus);
end;
{ @end $736278 }

{ @routine $736420 TEquipment_GetDescriptionStatBonus }
function TEquipment.GetDescriptionStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var
  Index, CombinedBonus, SeparatedBonus, ExtraSeparatedBonus, EffectPercent, PenaltyPercent: Integer;
  Entry: PExtraSpecial;
begin
  if (BonusKind in [bonSkill1..bonSkill6, bonStimCapacity]) and (MicroModuleIndex <> 0) and
    not MicroModuleTemplates[MicroModuleIndex - 1].SeparatedNumbers then
    Result := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(BonusKind)]
  else Result := 0;
  if (ItemType in [t_Weapon1..t_CustomWeapon]) and (BonusKind in [bonWEnergy..bonWRadius, bonMissileSpeed]) then Exit;
  CombinedBonus := 0;
  SeparatedBonus := 0;
  ExtraSeparatedBonus := 0;
  if SpecialModuleIndex <> 0 then
    if MicroModuleTemplates[SpecialModuleIndex - 1].SeparatedNumbers then
      SeparatedBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(BonusKind)]
    else CombinedBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(BonusKind)];
  if ExtraSpecials <> nil then
    for Index := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[Index];
      if MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].SeparatedNumbers then
        ExtraSeparatedBonus := CombinedBonus + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(BonusKind)] * Entry.Count
      else CombinedBonus := CombinedBonus + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(BonusKind)] * Entry.Count;
    end;
  if MicroModuleIndex <> 0 then
  begin
    EffectPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonExtraAkrinEff)];
    PenaltyPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonExtraAkrinPenalty)];
  end
  else
  begin
    EffectPercent := 0;
    PenaltyPercent := 0;
  end;
  if ((EffectPercent <> 0) or (PenaltyPercent <> 0)) and
    ((CombinedBonus <> 0) or (SeparatedBonus <> 0) or (ExtraSeparatedBonus <> 0)) and
    not (BonusKind in [bonExtraAkrinEff..bonExtraAkrinPenalty]) then
  begin
    CombinedBonus := CombinedBonus + SeparatedBonus + ExtraSeparatedBonus;
    if (BonusKind in [bonMass]) = (CombinedBonus > 0) then
      CombinedBonus := CombinedBonus + Round(CombinedBonus * PenaltyPercent * 0.0001)
    else CombinedBonus := CombinedBonus + Round(CombinedBonus * EffectPercent * 0.0001);
    if (BonusKind in [bonMass]) = (SeparatedBonus > 0) then
      SeparatedBonus := SeparatedBonus + Round(SeparatedBonus * PenaltyPercent * 0.0001)
    else SeparatedBonus := SeparatedBonus + Round(SeparatedBonus * EffectPercent * 0.0001);
    if (BonusKind in [bonMass]) = (ExtraSeparatedBonus > 0) then
      ExtraSeparatedBonus := ExtraSeparatedBonus + Round(ExtraSeparatedBonus * PenaltyPercent * 0.0001)
    else ExtraSeparatedBonus := ExtraSeparatedBonus + Round(ExtraSeparatedBonus * EffectPercent * 0.0001);
    CombinedBonus := CombinedBonus - SeparatedBonus - ExtraSeparatedBonus;
  end;
  Result := Result + CombinedBonus;
end;
{ @end $736420 }

{ @routine $7369D0 TEquipment_GetBonusDescription }
function TEquipment.GetBonusDescription(ColorTag: WideString): WideString;
var
  Description: WideString;
  EffectPercent, PenaltyPercent, StatBonus: Integer;
  BonusKind: TEquipmentBonusKind;
  Index, ModuleIndexPlusOne: Integer;

  // @nested $736754 ExpandModuleTokens
  function ExpandModuleTokens(Text: WideString; ModuleIndexPlusOne, Count: Integer): WideString; // @addr 0x736754 @ida "void __userpurge $name(unsigned __int16 *Text@<eax>, int ModuleIndexPlusOne@<edx>, int Count@<ecx>, unsigned __int16 **Result@<^0>, void *ParentFrame@<^4>);" @calls "0x736ABD 0x736C59 0x736DA9" @stackpop 0x4 @note "Uses the parent description, bonus multipliers and color. RET 4 removes Result; the caller removes ParentFrame. Count 0 suppresses numeric bonuses."
  var BonusIndex: Byte; Value: Integer;
  begin
    // The native helper reads the captured description; Text remains an unused managed parameter.
    Result := Description;
    for BonusIndex := 0 to 42 do
    begin
      Value := MicroModuleTemplates[ModuleIndexPlusOne - 1].StatBonuses[BonusIndex];
      Value := Value * Count;
      if (Count <> 0) and (EffectPercent <> 0) and not (BonusIndex in [29..30]) then
        if (BonusIndex in [28]) = (Value > 0) then Value := Value + Round(Value * PenaltyPercent * 0.0001)
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
    EffectPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonExtraAkrinEff)];
    PenaltyPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonExtraAkrinPenalty)];
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
        WrapTextInColor(GetSpecialModuleName, '<color=255,240,100>');
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
        if Description <> '' then
        begin
          ReplaceTextToken(Description, '<ExCount>', IntToStr(PExtraSpecial(ExtraSpecials[Index]).Count), ColorTag);
          if MicroModuleTemplates[ModuleIndexPlusOne - 1].SeparatedNumbers then
            Description := ExpandModuleTokens(Description, ModuleIndexPlusOne, PExtraSpecial(ExtraSpecials[Index]).Count);
          Result := Result + #13#10 + WrapTextInColor(Description, GetMicroModuleTextColorTag(ModuleIndexPlusOne - 1));
        end;
      end;
    end;
  if Result <> '' then
    for BonusKind := bonHull to bonNull do
    begin
      StatBonus := GetDescriptionStatBonus(BonusKind);
      if StatBonus > 0 then
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[Ord(BonusKind)] + '>', '+' + IntToStr(StatBonus), ColorTag)
      else if StatBonus < 0 then
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[Ord(BonusKind)] + '>', IntToStr(StatBonus), ColorTag)
      else ReplaceTextToken(Result, '<' + EquipmentBonusNames[Ord(BonusKind)] + '>', '--', ColorTag);
    end;
end;
{ @end $7369D0 }

{ @routine $7370DC TEquipment_CanImprove }
function TEquipment.CanImprove: Boolean;
begin
  Result := HasStandardStats and ((SpecialModuleIndex = 0) or
    not MicroModuleTemplates[SpecialModuleIndex - 1].BlocksSpecialSlot);
end;
{ @end $7370DC }

{ @routine $737124 THull_Init }
procedure THull.Init(Capacity: Integer; Level, Owner, HullType: Byte; Series: Integer; PirateBuilt: Boolean);
begin
  ItemType := t_Hull;
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
{ @end $737124 }

{ @routine $7371EC THull_ApplySeriesSizeAndCost }
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
    if (Cost < 0) or (Cost > 100000000) then Cost := 100000000;
  end;
end;
{ @end $7371EC }

{ @routine $7372EC THull_SaveToBuffer }
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
    if InterceptorTarget <> nil then Buffer.AddDWord((TObject(InterceptorTarget) as TShip).Id)
    else Buffer.AddDWord(0);
    Buffer.AddAnsiChar(AnsiChar(InterceptorTargetingStrategy));
    Buffer.AddAnsiChar(AnsiChar(InterceptorPassCountOverride));
  end;
end;
{ @end $7372EC }

{ @routine $7374D0 THull_LoadFromBuffer }
procedure THull.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var SavedHullType: Integer;

  // @nested $737428 ReadSavedHullSeriesIndex
  function ReadSavedHullSeriesIndex(Buffer: TBufEC): Integer; // @addr 0x737428 @ida "int __usercall $name@<eax>(TBufEC *Buffer@<eax>, void *ParentFrame@<^0>);" @note "Returns a zero-based series index, or -1 if absent or unresolved."
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
  if LoadedSaveVersion >= 88 then HullType := SavedHullType
  else if LoadedSaveVersion >= 67 then
  begin
    if (SavedHullType > 6) and (SavedHullType < 24) then SavedHullType := 6;
    if SavedHullType >= 24 then Dec(SavedHullType, 17);
    HullType := SavedHullType;
  end
  else if SavedHullType > 26 then HullType := htSpecial
  else
  begin
    if (SavedHullType > 6) and (SavedHullType < 24) then SavedHullType := 6;
    if SavedHullType >= 24 then Dec(SavedHullType, 17);
    HullType := SavedHullType;
  end;
  if (HullType = htSpecial) and (SpecialModuleIndex = 0) then HullType := htRanger;
  if LoadedSaveVersion >= 163 then HullSeries := ReadSavedHullSeriesIndex(Buffer)
  else
  begin
    HullSeries := Buffer.GetByte;
    if (HullSeries = 255) or (High(HullSeriesDefinitions) < HullSeries) then HullSeries := -1;
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
      InterceptorTarget := Pointer(Buffer.GetUInt32);
      InterceptorTargetingStrategy := TInterceptorTargetingStrategy(Buffer.GetByte);
      InterceptorPassCountOverride := Buffer.GetByte;
    end
    else
    begin
      InterceptorTarget := nil;
      InterceptorTargetingStrategy := itsManual;
      InterceptorPassCountOverride := 0;
    end
  else if LoadedSaveVersion = 51 then
  begin
    InterceptorTarget := Pointer(Buffer.GetUInt32);
    InterceptorTargetingStrategy := itsManual;
    InterceptorPassCountOverride := 0;
  end
  else
  begin
    InterceptorTarget := nil;
    InterceptorTargetingStrategy := itsManual;
    InterceptorPassCountOverride := 0;
  end;
end;
{ @end $7374D0 }

{ @routine $737780 THull_ResolveLoadedReferences }
procedure THull.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  if InterceptorTarget <> nil then InterceptorTarget := TObject(Galaxy.IdToShip(Integer(InterceptorTarget), False)) as TShip;
end;
{ @end $737780 }

{ @routine $7377BC THull_ClearReferences }
procedure THull.ClearReferences;
begin
  inherited ClearReferences;
  InterceptorTarget := nil;
end;
{ @end $7377BC }

{ @routine $7377D8 THull_SaveToBlock }
procedure THull.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Alrumuotr'), IntToStr(Armor)); // Decoded: 'Armor'
  Block.AddParam(DecodeTextW('SohtiEprTtyopwec'), IntToStr(HullType)); // Decoded: 'ShipType'
  Block.AddParam(DecodeTextW('Stearoidess'), IntToStr(HullSeries)); // Decoded: 'Series'
  if HullSeries <> -1 then
    Block.AddParam(DecodeTextW('IfSoenrOilets2Noarmye'), GetSeriesName); // Decoded: 'ISeriesName'
  Block.AddParam(DecodeTextW('BlueivlitoBuyAPIinroaLtte'), BoolToWideString(PirateBuilt)); // Decoded: 'BuiltByPirate'
end;
{ @end $7377D8 }

{ @routine $737AA4 THull_LoadFromBlock }
procedure THull.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Armor := StrToInt(Block.GetParam(DecodeTextW('Alrumuotr'))); // Decoded: 'Armor'
  HullType := StrToInt(Block.GetParam(DecodeTextW('SohtiEprTtyopwec'))); // Decoded: 'ShipType'
  HullSeries := StrToInt(Block.GetParam(DecodeTextW('Stearoidess'))); // Decoded: 'Series'
  PirateBuilt := LowerCase(Block.GetParam(DecodeTextW('BlueivlitoBuyAPIinroaLtte'))) = 'true'; // Decoded: 'BuiltByPirate'
end;
{ @end $737AA4 }

{ @routine $737D40 THull_CalculateGeneratedArmor }
function THull.CalculateGeneratedArmor: ShortInt;
begin
  Result := HullLevelStats[TechLevel].Armor;
end;
{ @end $737D40 }

{ @routine $737D68 CalculateGeneratedHullCost }
function CalculateGeneratedHullCost(Capacity, Level: Cardinal; Owner, HullType: Byte): Integer;
var Kind: TShipSlotKind; Factor: Double;
begin
  Factor := 1;
  if HullType in [htRanger..htDiplomat] then
  begin
    for Kind := sskRadar to sskAfterburner do
      case Kind of
        sskRadar: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.7 * Factor;
        sskScanner: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.9 * Factor;
        sskRepairRobot: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.7 * Factor;
        sskCargoHook: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.6 * Factor;
        sskDefGenerator: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.7 * Factor;
        sskWeapon: Factor := RemapClamped(GetBaseHullSlotCount(Kind, HullType, Owner, nil), 2, 5, 0.5, 1) * Factor;
        sskArtefact: Factor := RemapClamped(GetBaseHullSlotCount(Kind, HullType, Owner, nil), 0, 4, 0.7, 1) * Factor;
        sskAfterburner: if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then Factor := 0.85 * Factor;
      end;
    if Factor < 0.2 then Factor := 0.2;
  end
  else if HullType = htFlagship then Factor := 0.05;
  Result := RoundAndTruncateToTens(RemapClamped(Level, 1, 8, 1, 8) * 2000 * Factor *
    (Max(Capacity, 250) * 0.01 - 0.006) * (Max(Capacity, 1000) * 0.002 - 0.001) *
    (Max(Capacity, 2000) * 0.0005));
end;
{ @end $737D68 }

{ @routine $73812C THull_CalculateGeneratedCost }
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
{ @end $73812C }

{ @routine $7381C8 THull_Repair }
procedure THull.Repair;
begin
  inherited Repair;
  HullPoints := Weight;
end;
{ @end $7381C8 }

{ @routine $7381E8 THull_Improve }
procedure THull.Improve(Kind: TImprovementKind);
var ExtraCapacity: Integer;


begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor: Inc(Armor, SeededRandomIntRange(1, 2, Id * 254571));
    ikMedium: Inc(Armor, SeededRandomIntRange(2, 3, Id * 254571));
    ikMajor: Inc(Armor, SeededRandomIntRange(3, 4, Id * 254571));
  end;
  if HullType = htTranclucator then
  begin
    ExtraCapacity := 0;
    case Kind of
      ikMinor: ExtraCapacity := Round(SeededRandomIntRange(3, 7, Id * 214571) * Max(Weight, 500) * 0.01);
      ikMedium: ExtraCapacity := Round(SeededRandomIntRange(8, 12, Id * 214571) * Max(Weight, 500) * 0.01);
      ikMajor: ExtraCapacity := Round(SeededRandomIntRange(13, 17, Id * 214571) * Max(Weight, 500) * 0.01);
    end;
    Inc(Weight, ExtraCapacity);
    Inc(HullPoints, ExtraCapacity);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $7381E8 }

{ @routine $7383F8 THull_HasStandardStats }
function THull.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)] = 0) then
    Result := CalculateGeneratedArmor = Armor
  else Result := CalculateGeneratedArmor = Armor - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)];
end;
{ @end $7383F8 }

{ @routine $738470 THull_GetDisplayName }
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
      htRanger: ShipTypeName := LocalizedText('Items.Hull.ShipType.Ranger');
      htTransport: ShipTypeName := LocalizedText('Items.Hull.ShipType.Transport');
      htLiner: ShipTypeName := LocalizedText('Items.Hull.ShipType.Liner');
      htDiplomat: ShipTypeName := LocalizedText('Items.Hull.ShipType.Diplomat');
      htPirate: ShipTypeName := LocalizedText('Items.Hull.ShipType.Pirate');
      htWarrior: ShipTypeName := LocalizedText('Items.Hull.ShipType.Warrior');
      htKling: ShipTypeName := LocalizedText('Items.Hull.ShipType.Kling');
    else ShipTypeName := '';
    end;
    Result := FormatText2(LocalizedText('Items.Hull.Name'), '', '<Type>', TypeName, '<ShipType>', ShipTypeName);
  end;
  if HasMicroModule then Result := Result + ' ' + WrapTextInColor(GetMicroModuleQuotedName, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;
{ @end $738470 }

{ @routine $7388FC THull_GetSeriesName }
function THull.GetSeriesName: WideString;
begin
  if (OwnerShip <> nil) and TShip(OwnerShip).UsesVeteranHumanRangerAppearance then
    Result := FormatText1(LocalizedText('HullType.SeriesName'), '', '<Name>', LocalizedText('HullType.HullOldfag.Name'))
  else if HullSeries = -1 then Result := ''
  else Result := FormatText1(LocalizedText('HullType.SeriesName'), '', '<Name>', HullSeriesDefinitions[HullSeries].Name);
end;
{ @end $7388FC }

{ @routine $738A50 THull_GetShortName }
function THull.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Hull.ShortName');
end;
{ @end $738A50 }

{ @routine $738ABC THull_GetInfoText }
function THull.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text, SizeColor: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if Text = '' then Text := LocalizedText('Items.Hull.Text');
  if (OwnerShip <> nil) and TShip(OwnerShip).UsesVeteranHumanRangerAppearance then
    Text := LocalizedText('HullType.HullOldfag.Text') + ' ' + Text
  else if HullSeries <> -1 then Text := HullSeriesDefinitions[HullSeries].Text + ' ' + Text;
  if HullPoints <= Weight / 2 then SizeColor := '<color=254,217,7>' else SizeColor := ColorTag;
  ReplaceTextToken(Text, '<Size>', IntToStr(HullPoints), SizeColor);
  ReplaceTextToken(Text, '<MaxSize>', IntToStr(Weight), ColorTag);
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text;
end;
{ @end $738ABC }

{ @routine $738DAC THull_ReplaceInfoTokens }
procedure THull.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseArmor, StatBonus: Integer;
begin
  ReplaceTextToken(Text, '<FragilityE>', IntToStr(Round(GetFragilityFactor([dkEnergy]) * 100)), ColorTag);
  ReplaceTextToken(Text, '<FragilityS>', IntToStr(Round(GetFragilityFactor([dkSplinter]) * 100)), ColorTag);
  ReplaceTextToken(Text, '<FragilityM>', IntToStr(Round(GetFragilityFactor([dkMissile]) * 100)), ColorTag);
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)] = 0) then BonusText := ''
  else
  begin
    if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)] > 0 then
      BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)]), '<color=0,255,0>')
    else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)]), '<color=255,0,0>');
  end;
  StatBonus := GetStatBonus(bonHull);
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if OwnerShip <> nil then StatBonus := TShip(OwnerShip).GetTotalStatBonus(Ord(bonHull)) - StatBonus
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');
  if MicroModuleIndex = 0 then BaseArmor := Armor
  else BaseArmor := Armor - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)];
  if CalculateGeneratedArmor = BaseArmor then ReplaceTextToken(Text, '<HitProtect>', WideString(IntToStr(BaseArmor)) + BonusText, ColorTag)
  else if CalculateGeneratedArmor < BaseArmor then
    ReplaceTextToken(Text, '<HitProtect>', WrapTextInColor(IntToStr(BaseArmor), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<HitProtect>', WrapTextInColor(IntToStr(BaseArmor), '<color=255,0,0>') + BonusText, ColorTag);
end;
{ @end $738DAC }

{ @routine $739484 THull_GetBitmapResourceName }
function THull.GetBitmapResourceName: WideString;
var Ship: TShip;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if HullType = htRanger then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_R_'
  else if HullType = htWarrior then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_W_'
  else if HullType = htPirate then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_P_'
  else if HullType = htTransport then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_T_'
  else if HullType = htLiner then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_L_'
  else if HullType = htDiplomat then Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_D_'
  else if (HullType = htSpecial) and (SpecialModuleIndex <> 0) then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + GetSpecialKindGraph + '_'
  else RaiseWideMessage('THull.Image');
  Ship := OwnerShip;
  if Ship <> nil then
  begin
    if (HullType = htSpecial) and (SpecialModuleIndex <> 0) and (GetSpecialKindGraph = 'J') and
      Ship.IsFemaleHumanPilot and (Ship.TypeId = stRanger) then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_J_alt_'
    else if (HullType = htRanger) and (SpecialModuleIndex = 0) and Ship.UsesVeteranHumanRangerAppearance then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_People_ROld_'
    else if (Ship.TypeId = stPirate) and (Ship.OwnerId = Byte(oiPirate)) and ((Ship as TPirate).PirateType <> 0) then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_PC_';
  end;
end;
{ @end $739484 }

{ @routine $739914 THull_GetSpecialKindGraph }
function THull.GetSpecialKindGraph: WideString;
begin
  Result := '1';
  if SpecialModuleIndex = 0 then Exit;
  if MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '' then
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph;
end;
{ @end $739914 }

{ @routine $73997C THull_GetSlotCount }
function THull.GetSlotCount(Kind: TShipSlotKind): Integer;
var BonusKind: TEquipmentBonusKind; I, Maximum, Minimum: Integer; Entry: PExtraSpecial;
begin
  Result := GetBaseHullSlotCount(Kind, HullType, OwnerId, OwnerShip);
  BonusKind := HullSlotBonusKinds[Ord(Kind)];
  Maximum := DefaultHullSlotCounts[Ord(Kind)];
  Minimum := MinimumHullSlotCounts[Ord(Kind)];
  if SpecialModuleIndex <> 0 then
    Result := Min(Maximum, Max(Minimum, Result + MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(BonusKind)]));
  if ExtraSpecials <> nil then
  begin
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(Result, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(BonusKind)] * Entry.Count);
    end;
    Result := Min(Maximum, Max(Minimum, Result));
  end;
  if HullSeries <> -1 then
    Result := Min(Maximum, Max(Minimum, Result + HullSeriesDefinitions[HullSeries].SlotBonuses[Ord(Kind)]));
  if MicroModuleIndex <> 0 then
    Result := Min(Maximum, Max(Minimum, Result + MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(BonusKind)]));
end;
{ @end $73997C }

{ @routine $739B98 GetBaseHullSlotCount }
function GetBaseHullSlotCount(Kind: TShipSlotKind; HullType, Owner: Byte; Ship: Pointer): Integer;
begin
  Result := 0;
  case HullType of
    htRanger: Result := RangerHullSlots[Owner, Ord(Kind)];
    htWarrior: Result := WarriorHullSlots[Owner, Ord(Kind)];
    htPirate: Result := PirateHullSlots[Owner, Ord(Kind)];
    htTransport: Result := TransportHullSlots[Owner, Ord(Kind)];
    htLiner: Result := LinerHullSlots[Owner, Ord(Kind)];
    htDiplomat: Result := DiplomatHullSlots[Owner, Ord(Kind)];
    htTranclucator: Result := TranclucatorHullSlots[Ord(Kind)];
    htKling: if (Ship = nil) or not (TObject(Ship) is TKling) then
         Result := DominatorHullSlots[0, Ord(Kind)]
       else Result := DominatorHullSlots[Ord((TObject(Ship) as TKling).KlingType), Ord(Kind)];
    htStation: if Ship = nil then Result := StationHullSlots[0, Ord(Kind)]
       else if not (TShip(Ship).TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) then
         Result := StationHullSlots[0, Ord(Kind)]
       else Result := StationHullSlots[TShip(Ship).TypeId - Ord(rstRangerCenter), Ord(Kind)];
    htSpecial: Result := HullType9Slots[Ord(Kind)];
    htFlagship: Result := HullType10Slots[Ord(Kind)];
  else RaiseWideMessage('SlotCount error');
  end;
end;
{ @end $739B98 }

{ @routine $739DE4 THull_CalculateMass }
function THull.CalculateMass: Integer;
begin
  Result := Round(RemapClamped(TechLevel, 1, 8, Weight * 0.6, Weight * 0.8));
end;
{ @end $739DE4 }

{ @routine $739E68 THull_GetFragilityFactor }
function THull.GetFragilityFactor(DamageFlags: TDamageFlagSet): Single;
var DamageClass: TWeaponDamageClass; Entry: PExtraSpecial; I: Integer; Factor: Single;
begin
  if DamageFlags = [] then
  begin
    Result := 0;
    for DamageClass := wdcEnergy to wdcMissile do
      Result := GetFragilityFactor([TDamageKind(WeaponDamageClasses[Ord(DamageClass)].Kind)]) + Result;
    Result := Result / 3;
    Exit;
  end;
  DamageClass := ClassifyWeaponDamageFlags(DamageFlags);
  Result := HullFragilityByType[HullType] * HullLevelStats[TechLevel].Fragility[Ord(DamageClass)] * HullFragilityByOwner[Ord(DamageClass), OwnerId];
  if PirateBuilt then Result := Result * HullFragilityByOwner[Ord(DamageClass), 7];
  if MicroModuleIndex <> 0 then Result := Result * MicroModuleTemplates[MicroModuleIndex - 1].FragilityFactorByDamageClass[Ord(DamageClass)];
  if SpecialModuleIndex <> 0 then Result := Result * MicroModuleTemplates[SpecialModuleIndex - 1].FragilityFactorByDamageClass[Ord(DamageClass)];
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Factor := MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].FragilityFactorByDamageClass[Ord(DamageClass)];
      if Abs(Factor - 1) > 0.000001 then
      begin
        if Entry.Count = 1 then Result := Result * Factor
        else Result := Power(Factor, Entry.Count) * Result;
      end;
    end;
  if HullSeries <> -1 then Result := Result * HullSeriesDefinitions[HullSeries].FragilityByDamageClass[Ord(DamageClass)];
end;
{ @end $739E68 }

{ @routine $73A0E8 THull_EstimateCapacityWithoutBonuses }
function THull.EstimateCapacityWithoutBonuses: Integer;
var I: Integer;

  // @nested $73A0A4 UndoSizePercent
  procedure UndoSizePercent(Percent: Integer); // @addr 0x73A0A4 @ida "void __usercall $name(int Percent@<eax>, void *ParentFrame@<^0>);" @note "Updates the parent's capacity accumulator; caller removes ParentFrame. Nonpositive Percent leaves it unchanged."
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
{ @end $73A0E8 }

{ @routine $73A1C0 TFuelTanks_Init }
procedure TFuelTanks.Init(Weight: Integer; Level, Owner: Byte);
begin
  ItemType := t_FuelTanks;
  Self.Weight := Weight;
  TechLevel := Level;
  Capacity := CalculateGeneratedCapacity;
  Fuel := Capacity;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $73A1C0 }

{ @routine $73A230 TFuelTanks_SaveToBuffer }
procedure TFuelTanks.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Fuel));
  Buffer.AddAnsiChar(AnsiChar(Capacity));
end;
{ @end $73A230 }

{ @routine $73A278 TFuelTanks_LoadFromBuffer }
procedure TFuelTanks.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Fuel := Buffer.GetWord;
  Capacity := Buffer.GetByte;
end;
{ @end $73A278 }

{ @routine $73A2C8 TFuelTanks_SaveToBlock }
procedure TFuelTanks.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('FiuNeol'), IntToStr(Fuel)); // Decoded: 'Fuel'
  Block.AddParam(DecodeTextW('CraspiaNcliotay'), IntToStr(Capacity)); // Decoded: 'Capacity'
end;
{ @end $73A2C8 }

{ @routine $73A45C TFuelTanks_LoadFromBlock }
procedure TFuelTanks.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Fuel := Word(StrToInt(Block.GetParam(DecodeTextW('FiuNeol')))); // Decoded: 'Fuel'
  Capacity := StrToInt(Block.GetParam(DecodeTextW('CraspiaNcliotay'))); // Decoded: 'Capacity'
end;
{ @end $73A45C }

{ @routine $73A5E8 TFuelTanks_CalculateGeneratedCapacity }
function TFuelTanks.CalculateGeneratedCapacity: Byte;
begin
  Result := CalculateGeneratedFuelCapacity(Weight, TechLevel);
end;
{ @end $73A5E8 }

{ @routine $73A610 CalculateGeneratedFuelCapacity }
function CalculateGeneratedFuelCapacity(Weight: Cardinal; Level: Integer): Integer;
begin
  Result := Round(Weight / FuelTanksBaseSize * 20 + FuelCapacityByLevel[Level]);
end;
{ @end $73A610 }

{ @routine $73A664 CalculateGeneratedFuelTanksCost }
function CalculateGeneratedFuelTanksCost(Weight: Cardinal; Level: Integer; Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(Weight / FuelTanksBaseSize * Cardinal(Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $73A664 }

{ @routine $73A6D0 TFuelTanks_CalculateGeneratedCost }
function TFuelTanks.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedFuelTanksCost(Weight, TechLevel, OwnerId);
end;
{ @end $73A6D0 }

{ @routine $73A6FC TFuelTanks_Improve }
procedure TFuelTanks.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor: Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + Capacity + 1;
    ikMedium: Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.1, 0.15)) + Capacity + 3;
    ikMajor: Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.15, 0.2)) + Capacity + 5;
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $73A6FC }

{ @routine $73A838 TFuelTanks_HasStandardStats }
function TFuelTanks.HasStandardStats: Boolean;
var BaseCapacity, ExpectedWeight, SizePercent: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)] = 0) then
    BaseCapacity := Capacity
  else BaseCapacity := Capacity - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)];
  ExpectedWeight := Round((BaseCapacity - FuelCapacityByLevel[TechLevel]) * FuelTanksBaseSize / 20);
  if MicroModuleIndex <> 0 then SizePercent := MicroModuleTemplates[MicroModuleIndex - 1].SizePercent else SizePercent := 0;
  if SizePercent > 0 then ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if SpecialModuleIndex <> 0 then SizePercent := MicroModuleTemplates[SpecialModuleIndex - 1].SizePercent else SizePercent := 0;
  if SizePercent > 0 then ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  Result := Abs(ExpectedWeight - Weight) <= 1;
end;
{ @end $73A838 }

{ @routine $73A970 TFuelTanks_GetInfoText }
function TFuelTanks.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.FuelTanks.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> Byte(oiDominator) then Text := LocalizedText('Items.FuelTanks.Text')
    else Text := LocalizedText('Items.FuelTanks.KlingText');
  ReplaceTextToken(Text, '<Fuel>', IntToStr(Fuel), ColorTag);
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $73A970 }

{ @routine $73ABE0 TFuelTanks_ReplaceInfoTokens }
procedure TFuelTanks.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, SizePercent, ExpectedWeight: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)]), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)]), '<color=255,0,0>');
  if MicroModuleIndex = 0 then BaseValue := Capacity
  else BaseValue := Capacity - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)];
  ExpectedWeight := Round((BaseValue - FuelCapacityByLevel[TechLevel]) * FuelTanksBaseSize / 20);
  if MicroModuleIndex <> 0 then SizePercent := MicroModuleTemplates[MicroModuleIndex - 1].SizePercent else SizePercent := 0;
  if SizePercent > 0 then ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if SpecialModuleIndex <> 0 then SizePercent := MicroModuleTemplates[SpecialModuleIndex - 1].SizePercent else SizePercent := 0;
  if SizePercent > 0 then ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if Abs(ExpectedWeight - Weight) <= 1 then ReplaceTextToken(Text, '<Capacity>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if ExpectedWeight > Weight then
    ReplaceTextToken(Text, '<Capacity>', WrapTextInColor(IntToStr(BaseValue), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Capacity>', WrapTextInColor(IntToStr(BaseValue), '<color=255,0,0>') + BonusText, ColorTag);
end;
{ @end $73ABE0 }

{ @routine $73AFB8 TEngine_Init }
procedure TEngine.Init(Weight: Integer; Level, Owner: Byte);
begin
  ItemType := t_Engine;
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
{ @end $73AFB8 }

{ @routine $73B030 TEngine_SaveToBuffer }
procedure TEngine.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddIntegerValue(Speed);
  Buffer.AddAnsiChar(AnsiChar(JumpRange));
  Buffer.AddAnsiChar(AnsiChar(OutputPercent));
end;
{ @end $73B030 }

{ @routine $73B084 TEngine_LoadFromBuffer }
procedure TEngine.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  if LoadedSaveVersion >= 161 then Speed := Buffer.GetInt32 else Speed := Buffer.GetWord;
  JumpRange := ShortInt(Buffer.GetByte);
  OutputPercent := Buffer.GetByte;
  ItemType := t_Engine;
end;
{ @end $73B084 }

{ @routine $73B104 TEngine_SaveToBlock }
procedure TEngine.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Sapreneld'), IntToStr(Speed)); // Decoded: 'Speed'
  Block.AddParam(DecodeTextW('JiuOmipa'), IntToStr(JumpRange)); // Decoded: 'Jump'
end;
{ @end $73B104 }

{ @routine $73B290 TEngine_LoadFromBlock }
procedure TEngine.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Speed := Word(StrToInt(Block.GetParam(DecodeTextW('Sapreneld')))); // Decoded: 'Speed'
  JumpRange := StrToInt(Block.GetParam(DecodeTextW('JiuOmipa'))); // Decoded: 'Jump'
end;
{ @end $73B290 }

{ @routine $73B414 TEngine_CalculateGeneratedSpeed }
function TEngine.CalculateGeneratedSpeed: Integer;
begin
  Result := EngineLevelStats[TechLevel].Speed;
end;
{ @end $73B414 }

{ @routine $73B43C TEngine_CalculateGeneratedJumpRange }
function TEngine.CalculateGeneratedJumpRange: ShortInt;
begin
  Result := EngineLevelStats[TechLevel].JumpRange;
end;
{ @end $73B43C }

{ @routine $73B460 CalculateGeneratedEngineCost }
function CalculateGeneratedEngineCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(EngineBaseSize / Weight, 0.5, 2, 1, 2) * (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $73B460 }

{ @routine $73B4F4 TEngine_CalculateGeneratedCost }
function TEngine.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedEngineCost(Weight, TechLevel, OwnerId);
end;
{ @end $73B4F4 }

{ @routine $73B520 TEngine_Improve }
procedure TEngine.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  if DetailImprovement = 0 then
    if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then DetailImprovement := 1
    else DetailImprovement := 2;
  if DetailImprovement = 1 then
    case Kind of
      ikMinor:
        begin
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.05) + SeededRandomIntRange(10, 30, Id * 254571)));
          Inc(JumpRange, SeededRandomIntRange(1, 2, Id * 354571));
        end;
      ikMedium:
        begin
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.02, 0.06) + SeededRandomIntRange(30, 60, Id * 254571)));
          Inc(JumpRange, SeededRandomIntRange(2, 4, Id * 354571));
        end;
      ikMajor:
        begin
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.03, 0.07) + SeededRandomIntRange(50, 80, Id * 254571)));
          Inc(JumpRange, SeededRandomIntRange(3, 7, Id * 354571));
        end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      ikMinor:
        begin
          Inc(JumpRange, SeededRandomIntRange(2, 5, Id * 354571));
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.03) + SeededRandomIntRange(10, 20, Id * 254571)));
        end;
      ikMedium:
        begin
          Inc(JumpRange, SeededRandomIntRange(5, 7, Id * 354571));
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.04) + SeededRandomIntRange(20, 40, Id * 254571)));
        end;
      ikMajor:
        begin
          Inc(JumpRange, SeededRandomIntRange(7, 12, Id * 354571));
          Inc(Speed, RoundAndTruncateToTens(Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.05) + SeededRandomIntRange(30, 50, Id * 254571)));
        end;
    end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
  DetailImprovement := 0;
end;
{ @end $73B520 }

{ @routine $73B93C TEngine_HasStandardStats }
function TEngine.HasStandardStats: Boolean;
var StandardSpeed, StandardJump: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonSpeed)] = 0) then
    StandardSpeed := CalculateGeneratedSpeed = Speed
  else StandardSpeed := CalculateGeneratedSpeed = Speed - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonSpeed)];
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonJump)] = 0) then
    StandardJump := CalculateGeneratedJumpRange = JumpRange
  else StandardJump := CalculateGeneratedJumpRange = JumpRange - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonJump)];
  Result := StandardSpeed and StandardJump;
end;
{ @end $73B93C }

{ @routine $73BA1C TEngine_GetInfoText }
function TEngine.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Engine.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> Byte(oiDominator) then Text := LocalizedText('Items.Engine.Text')
    else Text := LocalizedText('Items.Engine.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $73BA1C }

{ @routine $73BC20 TEngine_ReplaceInfoTokens }
procedure TEngine.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if MicroModuleIndex = 0 then StatBonus := 0
  else StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonSpeed)];
  BaseValue := Max(0, Speed - StatBonus);
  StatBonus := Max(0, Speed) - BaseValue;
  if StatBonus = 0 then BonusText := ''
  else if StatBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(StatBonus), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(StatBonus), '<color=255,0,0>');
  StatBonus := Max(-Max(0, Speed), GetStatBonus(bonSpeed));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(Ord(bonSpeed)) - StatBonus, -(Speed + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');
  if CalculateGeneratedSpeed = BaseValue then ReplaceTextToken(Text, '<Speed>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedSpeed < BaseValue then
    ReplaceTextToken(Text, '<Speed>', WrapTextInColor(IntToStr(BaseValue), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Speed>', WrapTextInColor(IntToStr(BaseValue), '<color=255,0,0>') + BonusText, ColorTag);
  if MicroModuleIndex = 0 then StatBonus := 0
  else StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonJump)];
  BaseValue := Max(0, JumpRange - StatBonus);
  StatBonus := Max(0, JumpRange) - BaseValue;
  if StatBonus = 0 then BonusText := ''
  else if StatBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(StatBonus), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(StatBonus), '<color=255,0,0>');
  StatBonus := Max(-Max(0, JumpRange), GetStatBonus(bonJump));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(Ord(bonJump)) - StatBonus, -(JumpRange + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');
  if CalculateGeneratedJumpRange = BaseValue then ReplaceTextToken(Text, '<Parsec>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedJumpRange < BaseValue then
    ReplaceTextToken(Text, '<Parsec>', WrapTextInColor(IntToStr(BaseValue), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Parsec>', WrapTextInColor(IntToStr(BaseValue), '<color=255,0,0>') + BonusText, ColorTag);
end;
{ @end $73BC20 }

{ @routine $73C75C TRadar_Init }
procedure TRadar.Init(Weight: Integer; Level, Owner: Byte);
begin
  ItemType := t_Radar;
  Self.Weight := Weight;
  TechLevel := Level;
  Range := CalculateGeneratedRange;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $73C75C }

{ @routine $73C7C0 TRadar_SaveToBuffer }
procedure TRadar.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Range));
end;
{ @end $73C7C0 }

{ @routine $73C7F8 TRadar_LoadFromBuffer }
procedure TRadar.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Range := Buffer.GetWord;
end;
{ @end $73C7F8 }

{ @routine $73C838 TRadar_SaveToBlock }
procedure TRadar.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // Decoded: 'Radius'
end;
{ @end $73C838 }

{ @routine $73C960 TRadar_LoadFromBlock }
procedure TRadar.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // Decoded: 'Radius'
end;
{ @end $73C960 }

{ @routine $73CA84 TRadar_CalculateGeneratedRange }
function TRadar.CalculateGeneratedRange: Integer;
begin
  Result := RadarLevelRanges[TechLevel];
end;
{ @end $73CA84 }

{ @routine $73CAAC CalculateGeneratedRadarCost }
function CalculateGeneratedRadarCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(RadarBaseSize / Weight, 0.5, 2, 1, 2) * (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $73CAAC }

{ @routine $73CB40 TRadar_CalculateGeneratedCost }
function TRadar.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedRadarCost(Weight, TechLevel, OwnerId);
end;
{ @end $73CB40 }

{ @routine $73CB6C TRadar_Improve }
procedure TRadar.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor: Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1) + SeededRandomIntRange(100, 200, Id * 254571)));
    ikMedium: Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1) + SeededRandomIntRange(300, 400, Id * 254571)));
    ikMajor: Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1) + SeededRandomIntRange(400, 500, Id * 254571)));
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $73CB6C }

{ @routine $73CD08 TRadar_HasStandardStats }
function TRadar.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)] = 0) then
    Result := CalculateGeneratedRange = Range
  else Result := CalculateGeneratedRange = Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)];
end;
{ @end $73CD08 }

{ @routine $73CD7C TRadar_GetInfoText }
function TRadar.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Radar.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> Byte(oiDominator) then Text := LocalizedText('Items.Radar.Text')
    else Text := LocalizedText('Items.Radar.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $73CD7C }

{ @routine $73CF7C TRadar_ReplaceInfoTokens }
procedure TRadar.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)]), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)]), '<color=255,0,0>');
  StatBonus := Max(-Max(0, Range), GetStatBonus(bonRadar));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(Ord(bonRadar)) - StatBonus, -(Range + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');
  if MicroModuleIndex = 0 then BaseValue := Range
  else BaseValue := Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)];
  if HasStandardStats then ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedRange < BaseValue then
    ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseValue), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseValue), '<color=255,0,0>') + BonusText, ColorTag);
end;
{ @end $73CF7C }

{ @routine $73D538 TScaner_Init }
procedure TScaner.Init(Weight: Integer; Level, Owner: Byte);
begin
  ItemType := t_Scaner;
  Self.Weight := Weight;
  TechLevel := Level;
  ScanPower := CalculateGeneratedScanPower;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $73D538 }

{ @routine $73D59C TScaner_SaveToBuffer }
procedure TScaner.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(ScanPower));
end;
{ @end $73D59C }

{ @routine $73D5D4 TScaner_LoadFromBuffer }
procedure TScaner.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  ScanPower := ShortInt(Buffer.GetByte);
  if (LoadedSaveVersion < 118) and (MicroModuleIndex <> 0) and
    (MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber = 122) then Inc(ScanPower);
end;
{ @end $73D5D4 }

{ @routine $73D640 TScaner_SaveToBlock }
procedure TScaner.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(ScanPower)); // Decoded: 'Power'
end;
{ @end $73D640 }

{ @routine $73D764 TScaner_LoadFromBlock }
procedure TScaner.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  ScanPower := StrToInt(Block.GetParam(DecodeTextW('Prouwseor'))); // Decoded: 'Power'
end;
{ @end $73D764 }

{ @routine $73D880 TScaner_CalculateGeneratedScanPower }
function TScaner.CalculateGeneratedScanPower: Integer;
begin
  Result := DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(TechLevel)) + 1;
end;
{ @end $73D880 }

{ @routine $73D8B0 CalculateGeneratedScanerCost }
function CalculateGeneratedScanerCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(ScannerBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $73D8B0 }

{ @routine $73D944 TScaner_CalculateGeneratedCost }
function TScaner.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedScanerCost(Weight, TechLevel, OwnerId);
end;
{ @end $73D944 }

{ @routine $73D970 TScaner_Improve }
procedure TScaner.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor: ScanPower := ScanPower + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + SeededRandomIntRange(1, 3, Id * 354571);
    ikMedium: ScanPower := ScanPower + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + SeededRandomIntRange(3, 5, Id * 354571);
    ikMajor: ScanPower := ScanPower + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + SeededRandomIntRange(5, 7, Id * 354571);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $73D970 }

{ @routine $73DB00 TScaner_HasStandardStats }
function TScaner.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonScan)] = 0) then
    Result := CalculateGeneratedScanPower = ScanPower
  else Result := CalculateGeneratedScanPower = ScanPower - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonScan)];
end;
{ @end $73DB00 }

{ @routine $73DB78 TScaner_GetInfoText }
function TScaner.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Scaner.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> Byte(oiDominator) then Text := LocalizedText('Items.Scaner.Text')
    else Text := LocalizedText('Items.Scaner.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $73DB78 }

{ @routine $73DD7C TScaner_ReplaceInfoTokens }
procedure TScaner.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if MicroModuleIndex = 0 then StatBonus := 0
  else StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonScan)];
  BaseValue := Max(0, ScanPower - StatBonus);
  StatBonus := Max(0, ScanPower) - BaseValue;
  if StatBonus = 0 then BonusText := ''
  else if StatBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(StatBonus), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(StatBonus), '<color=255,0,0>');
  StatBonus := Max(-Max(0, ScanPower), GetStatBonus(bonScan));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(Ord(bonScan)) - StatBonus, -(ScanPower + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');
  if CalculateGeneratedScanPower = BaseValue then ReplaceTextToken(Text, '<Percent>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedScanPower < BaseValue then
    ReplaceTextToken(Text, '<Percent>', WrapTextInColor(IntToStr(BaseValue), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Percent>', WrapTextInColor(IntToStr(BaseValue), '<color=255,0,0>') + BonusText, ColorTag);
end;
{ @end $73DD7C }

{ @routine $73E338 TRepairRobot_Init }
procedure TRepairRobot.Init(Weight: Integer; Level, Owner: Byte);
begin
  ItemType := t_RepairRobot;
  Self.Weight := Weight;
  TechLevel := Level;
  RepairPoints := CalculateGeneratedRepairPoints;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;
{ @end $73E338 }

{ @routine $73E39C TRepairRobot_SaveToBuffer }
procedure TRepairRobot.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(RepairPoints));
end;
{ @end $73E39C }

{ @routine $73E3D4 TRepairRobot_LoadFromBuffer }
procedure TRepairRobot.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  RepairPoints := Buffer.GetByte;
  if LoadedSaveVersion < 118 then
  begin
    if TechLevel < 5 then Inc(RepairPoints, 5);
    if (MicroModuleIndex <> 0) and
      (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)] <> 0) then
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
{ @end $73E3D4 }

{ @routine $73E4D0 TRepairRobot_SaveToBlock }
procedure TRepairRobot.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Raenplavikr'), IntToStr(RepairPoints)); // Decoded: 'Repair'
end;
{ @end $73E4D0 }

{ @routine $73E5F8 TRepairRobot_LoadFromBlock }
procedure TRepairRobot.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  RepairPoints := StrToInt(Block.GetParam(DecodeTextW('Raenplavikr'))); // Decoded: 'Repair'
end;
{ @end $73E5F8 }

{ @routine $73E718 TRepairRobot_CalculateGeneratedRepairPoints }
function TRepairRobot.CalculateGeneratedRepairPoints: Byte;
begin
  Result := RepairRobotLevelPoints[TechLevel];
end;
{ @end $73E718 }

{ @routine $73E73C CalculateGeneratedRepairRobotCost }
function CalculateGeneratedRepairRobotCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(RepairRobotBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $73E73C }

{ @routine $73E7D0 TRepairRobot_CalculateGeneratedCost }
function TRepairRobot.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedRepairRobotCost(Weight, TechLevel, OwnerId);
end;
{ @end $73E7D0 }

{ @routine $73E7FC TRepairRobot_Improve }
procedure TRepairRobot.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor: RepairPoints := RepairPoints + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12)) + SeededRandomIntRange(1, 4, Id * 354571);
    ikMedium: RepairPoints := RepairPoints + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12)) + SeededRandomIntRange(4, 7, Id * 354571);
    ikMajor: RepairPoints := RepairPoints + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12)) + SeededRandomIntRange(7, 10, Id * 354571);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $73E7FC }

{ @routine $73E98C TRepairRobot_HasStandardStats }
function TRepairRobot.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)] = 0) then
    Result := CalculateGeneratedRepairPoints = RepairPoints
  else Result := CalculateGeneratedRepairPoints = RepairPoints - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)];
end;
{ @end $73E98C }

{ @routine $73EA04 TRepairRobot_GetInfoText }
function TRepairRobot.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.RepairRobot.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> Byte(oiDominator) then Text := LocalizedText('Items.RepairRobot.Text')
    else Text := LocalizedText('Items.RepairRobot.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $73EA04 }

{ @routine $73EC28 TRepairRobot_ReplaceInfoTokens }
procedure TRepairRobot.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)]), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)]), '<color=255,0,0>');
  StatBonus := Max(-Max(0, RepairPoints), GetStatBonus(bonDroid));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(Ord(bonDroid)) - StatBonus, -(RepairPoints + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');
  if MicroModuleIndex = 0 then BaseValue := RepairPoints
  else BaseValue := RepairPoints - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)];
  if HasStandardStats then ReplaceTextToken(Text, '<RecoverHitPoints>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedRepairPoints < BaseValue then
    ReplaceTextToken(Text, '<RecoverHitPoints>', WrapTextInColor(IntToStr(BaseValue), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<RecoverHitPoints>', WrapTextInColor(IntToStr(BaseValue), '<color=255,0,0>') + BonusText, ColorTag);
end;
{ @end $73EC28 }

{ @routine $73F204 TCargoHook_Create }
constructor TCargoHook.Create;
begin
  inherited Create;
end;
{ @end $73F204 }

{ @routine $73F248 TCargoHook_Init }
procedure TCargoHook.Init(Weight: Integer; Level, Owner: Byte);
begin
  ItemType := t_CargoHook;
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
{ @end $73F248 }

{ @routine $73F2D8 TCargoHook_SaveToBuffer }
procedure TCargoHook.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(PickupPower));
  Buffer.AddWideChar(WideChar(Range));
  Buffer.AddSingle(MinPullSpeed);
  Buffer.AddSingle(MaxPullSpeed);
end;
{ @end $73F2D8 }

{ @routine $73F33C TCargoHook_LoadFromBuffer }
procedure TCargoHook.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  PickupPower := Buffer.GetWord;
  Range := Buffer.GetWord;
  MinPullSpeed := Buffer.GetSingle;
  MaxPullSpeed := Buffer.GetSingle;
end;
{ @end $73F33C }

{ @routine $73F3AC TCargoHook_SaveToBlock }
procedure TCargoHook.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(PickupPower)); // Decoded: 'Power'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // Decoded: 'Radius'
  Block.AddParam(DecodeTextW('SapperenduMaidno'), FloatToStr(MinPullSpeed)); // Decoded: 'SpeedMin'
  Block.AddParam(DecodeTextW('Suplexe2d3Moarxi'), FloatToStr(MaxPullSpeed)); // Decoded: 'SpeedMax'
end;
{ @end $73F3AC }

{ @routine $73F630 TCargoHook_LoadFromBlock }
procedure TCargoHook.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  PickupPower := Word(StrToInt(Block.GetParam(DecodeTextW('Prouwseor')))); // Decoded: 'Power'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // Decoded: 'Radius'
  MinPullSpeed := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('SapperenduMaidno'))); // Decoded: 'SpeedMin'
  MaxPullSpeed := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Suplexe2d3Moarxi'))); // Decoded: 'SpeedMax'
end;
{ @end $73F630 }

{ @routine $73F860 TCargoHook_CalculateGeneratedPickupPower }
function TCargoHook.CalculateGeneratedPickupPower: Integer;
begin
  Result := CargoHookLevelStats[TechLevel].PickupPower;
end;
{ @end $73F860 }

{ @routine $73F888 TCargoHook_CalculateGeneratedRange }
function TCargoHook.CalculateGeneratedRange: Integer;
begin
  Result := CargoHookLevelStats[TechLevel].Range;
end;
{ @end $73F888 }

{ @routine $73F8B0 TCargoHook_CalculateGeneratedMinPullSpeed }
function TCargoHook.CalculateGeneratedMinPullSpeed: Single;
begin
  Result := CargoHookLevelStats[TechLevel].MinPullSpeed;
end;
{ @end $73F8B0 }

{ @routine $73F8D8 TCargoHook_CalculateGeneratedMaxPullSpeed }
function TCargoHook.CalculateGeneratedMaxPullSpeed: Single;
begin
  Result := CargoHookLevelStats[TechLevel].MaxPullSpeed;
end;
{ @end $73F8D8 }

{ @routine $73F900 CalculateGeneratedCargoHookCost }
function CalculateGeneratedCargoHookCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(CargoHookBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $73F900 }

{ @routine $73F994 TCargoHook_CalculateGeneratedCost }
function TCargoHook.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedCargoHookCost(Weight, TechLevel, OwnerId);
end;
{ @end $73F994 }

{ @routine $73F9C0 TCargoHook_Improve }
procedure TCargoHook.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  if DetailImprovement = 0 then
    if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then DetailImprovement := 1
    else DetailImprovement := 2;
  if DetailImprovement = 1 then
    case Kind of
      ikMinor:
        begin
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12)) + SeededRandomIntRange(5, 10, Id * 254571);
          Inc(Range, SeededRandomIntRange(2, 4, Id * 354571));
        end;
      ikMedium:
        begin
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12)) + SeededRandomIntRange(10, 15, Id * 254571);
          Inc(Range, SeededRandomIntRange(5, 7, Id * 354571));
        end;
      ikMajor:
        begin
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12)) + SeededRandomIntRange(15, 20, Id * 254571);
          Inc(Range, SeededRandomIntRange(8, 10, Id * 354571));
        end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      ikMinor:
        begin
          Inc(Range, SeededRandomIntRange(10, 15, Id * 354571));
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05)) + SeededRandomIntRange(2, 3, Id * 254571);
        end;
      ikMedium:
        begin
          Inc(Range, SeededRandomIntRange(15, 20, Id * 354571));
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05)) + SeededRandomIntRange(3, 4, Id * 254571);
        end;
      ikMajor:
        begin
          Inc(Range, SeededRandomIntRange(20, 25, Id * 354571));
          PickupPower := PickupPower + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05)) + SeededRandomIntRange(4, 5, Id * 254571);
        end;
    end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
  DetailImprovement := 0;
end;
{ @end $73F9C0 }

{ @routine $73FD94 TCargoHook_HasStandardStats }
function TCargoHook.HasStandardStats: Boolean;
var StandardPower, StandardRange: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHook)] = 0) then
    StandardPower := CalculateGeneratedPickupPower = PickupPower
  else StandardPower := CalculateGeneratedPickupPower = PickupPower - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHook)];
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)] = 0) then
    StandardRange := CalculateGeneratedRange = Range
  else StandardRange := CalculateGeneratedRange = Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)];
  Result := StandardPower and StandardRange;
end;
{ @end $73FD94 }

{ @routine $73FE70 TCargoHook_GetInfoText }
function TCargoHook.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.CargoHook.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> Byte(oiDominator) then Text := LocalizedText('Items.CargoHook.Text')
    else Text := LocalizedText('Items.CargoHook.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $73FE70 }

{ @routine $740088 TCargoHook_ReplaceInfoTokens }
procedure TCargoHook.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var BonusText: WideString; BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHook)] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHook)] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHook)]), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHook)]), '<color=255,0,0>');
  StatBonus := Max(-Max(0, PickupPower), GetStatBonus(bonHook));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(Ord(bonHook)) - StatBonus, -(PickupPower + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');
  if MicroModuleIndex = 0 then BaseValue := PickupPower
  else BaseValue := PickupPower - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHook)];
  if CalculateGeneratedPickupPower = BaseValue then ReplaceTextToken(Text, '<PickUpSize>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedPickupPower < BaseValue then
    ReplaceTextToken(Text, '<PickUpSize>', WrapTextInColor(IntToStr(BaseValue), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<PickUpSize>', WrapTextInColor(IntToStr(BaseValue), '<color=255,0,0>') + BonusText, ColorTag);
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)] = 0) then BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)] > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)]), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)]), '<color=255,0,0>');
  StatBonus := Max(-Max(0, Range), GetStatBonus(bonHookRadius));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(Ord(bonHookRadius)) - StatBonus, -(Range + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');
  if MicroModuleIndex = 0 then BaseValue := Range
  else BaseValue := Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)];
  if CalculateGeneratedRange = BaseValue then ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(BaseValue)) + BonusText, '<color=255,240,100>')
  else if CalculateGeneratedRange < BaseValue then
    ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseValue), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseValue), '<color=255,0,0>') + BonusText, ColorTag);
  ReplaceTextToken(Text, '<SpeedMin>', IntToStr(Round(CargoHookLevelStats[TechLevel].MinPullSpeed)), '<color=255,240,100>');
  ReplaceTextToken(Text, '<SpeedMax>', IntToStr(Round(CargoHookLevelStats[TechLevel].MaxPullSpeed)), '<color=255,240,100>');
end;
{ @end $740088 }

{ @routine $740D08 TDefGenerator_Init }
procedure TDefGenerator.Init(Weight: Integer; Level, Owner: Byte);
begin
  ItemType := t_DefGenerator;
  Self.Weight := Weight;
  TechLevel := Level;
  DamageFactor := CalculateGeneratedDamageFactor;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedDefGeneratorCost(Weight, Level, Owner);
  MicroModuleIndex := 0;
end;
{ @end $740D08 }

{ @routine $740D74 TDefGenerator_SaveToBuffer }
procedure TDefGenerator.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddSingle(DamageFactor);
end;
{ @end $740D74 }

{ @routine $740DAC TDefGenerator_LoadFromBuffer }
procedure TDefGenerator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  DamageFactor := Buffer.GetSingle;
end;
{ @end $740DAC }

{ @routine $740DEC TDefGenerator_SaveToBlock }
procedure TDefGenerator.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), FloatToStr(1 - DamageFactor)); // Decoded: 'Power'
end;
{ @end $740DEC }

{ @routine $740F20 TDefGenerator_LoadFromBlock }
procedure TDefGenerator.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  DamageFactor := 1 - ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Prouwseor'))); // Decoded: 'Power'
end;
{ @end $740F20 }

{ @routine $741028 TDefGenerator_CalculateGeneratedDamageFactor }
function TDefGenerator.CalculateGeneratedDamageFactor: Single;
begin
  Result := DefGeneratorLevelFactors[TechLevel];
end;
{ @end $741028 }

{ @routine $74104C GetGeneratedDefenseDamageFactor }
function GetGeneratedDefenseDamageFactor(Level: Byte): Double;
begin
  Result := DefGeneratorLevelFactors[Level];
end;
{ @end $74104C }

{ @routine $741070 DefenseDamageFactorToPercent }
function DefenseDamageFactorToPercent(Factor: Double): TPercent;
begin
  Result := Round((1 - Factor) * 100);
end;
{ @end $741070 }

{ @routine $74109C DefensePercentToDamageFactor }
function DefensePercentToDamageFactor(Percent: Integer): Double;
begin
  Result := 1 - Percent * 0.01;
end;
{ @end $74109C }

{ @routine $7410D4 CalculateGeneratedDefGeneratorCost }
function CalculateGeneratedDefGeneratorCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(DefGeneratorBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7410D4 }

{ @routine $741168 TDefGenerator_Improve }
procedure TDefGenerator.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254573, 0.01, 0.03);
    ikMedium: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254572, 0.02, 0.04);
    ikMajor: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254571, 0.03, 0.05);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $741168 }

{ @routine $74125C TDefGenerator_HasStandardStats }
function TDefGenerator.HasStandardStats: Boolean;
var ActualPercent, BonusPercent, GeneratedPercent: Integer;
begin
  ActualPercent := Round(DamageFactor * 100);
  GeneratedPercent := Round(CalculateGeneratedDamageFactor * 100);
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDef)] = 0) then
    Result := ActualPercent = GeneratedPercent
  else
  begin
    BonusPercent := Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDef)]);
    Result := ActualPercent + BonusPercent = GeneratedPercent;
  end;
end;
{ @end $74125C }

{ @routine $7412F4 TDefGenerator_GetInfoText }
function TDefGenerator.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.DefGenerator.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> Byte(oiDominator) then Text := LocalizedText('Items.DefGenerator.Text')
    else Text := LocalizedText('Items.DefGenerator.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $7412F4 }

{ @routine $74151C TDefGenerator_ReplaceInfoTokens }
procedure TDefGenerator.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  ModuleBonus, ActualFactorPercent, GeneratedFactorPercent, StatBonus: Integer;
  DisplayPercent: Byte;
begin
  ModuleBonus := 0;
  if MicroModuleIndex <> 0 then ModuleBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDef)];
  DisplayPercent := DefenseDamageFactorToPercent(DamageFactor);
  if ModuleBonus = 0 then BonusText := ''
  else if ModuleBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), '<color=0,255,0>')
  else BonusText := WrapTextInColor(IntToStr(ModuleBonus), '<color=255,0,0>');
  StatBonus := Max(-Max(0, DisplayPercent), GetStatBonus(bonDef));
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), '<color=255,167,84>');
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(Ord(bonDef)) - StatBonus, -(DisplayPercent + StatBonus))
  else StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', '<color=255,167,84>');

  ActualFactorPercent := Round(DamageFactor * 100);
  GeneratedFactorPercent := Round(CalculateGeneratedDamageFactor * 100);
  if (MicroModuleIndex <> 0) and (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDef)] <> 0) then
    Inc(ActualFactorPercent, Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDef)]));
  if HasStandardStats then ReplaceTextToken(Text, '<Percent>', WideString(IntToStr(DisplayPercent - ModuleBonus)) + BonusText, ColorTag)
  else if ActualFactorPercent < GeneratedFactorPercent then
    ReplaceTextToken(Text, '<Percent>', WrapTextInColor(IntToStr(DisplayPercent - ModuleBonus), '<color=0,255,0>') + BonusText, ColorTag)
  else ReplaceTextToken(Text, '<Percent>', WrapTextInColor(IntToStr(DisplayPercent - ModuleBonus), '<color=255,0,0>') + BonusText, ColorTag);
end;
{ @end $74151C }

{ @routine $741B18 TWeapon_Destroy }
destructor TWeapon.Destroy;
begin
  inherited Destroy;
end;
{ @end $741B18 }

{ @routine $741B4C TWeapon_Init }
procedure TWeapon.Init(ItemType: TItemType; Weight: Integer; Level, Owner: Byte);
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
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    AmmoCapacity := CalculateGeneratedAmmoCapacity;
    Ammo := AmmoCapacity;
  end;
  MicroModuleIndex := 0;
end;
{ @end $741B4C }

{ @routine $741C10 TCustomWeapon_InitCustom }
procedure TCustomWeapon.InitCustom(Info: PWeaponInfo; Equipped: Boolean; Weight: Integer; Level, Owner: Byte);
begin
  Target := nil;
  ItemType := t_CustomWeapon;
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
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    AmmoCapacity := CalculateGeneratedAmmoCapacity;
    Ammo := AmmoCapacity;
  end;
  MicroModuleIndex := 0;
end;
{ @end $741C10 }

{ @routine $741CF0 TWeapon_SaveToBuffer }
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
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    Buffer.AddDWord(Ammo);
    Buffer.AddDWord(AmmoCapacity);
  end;
end;
{ @end $741CF0 }

{ @routine $741E90 TCustomWeapon_SaveToBuffer }
procedure TCustomWeapon.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(CustomInfo.ConfigName);
  inherited SaveToBuffer(Buffer);
end;
{ @end $741E90 }

{ @routine $741EC0 TWeapon_LoadFromBuffer }
procedure TWeapon.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
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
  if LoadedTargetKind = wtkNone then Target := nil else Target := TObject(Buffer.GetUInt32);
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    Ammo := Buffer.GetUInt32;
    AmmoCapacity := Buffer.GetUInt32;
    if (LoadedSaveVersion < 118) and (MicroModuleIndex <> 0) and
      (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonWMissile)] <> 0) then
      case MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber of
        204: Inc(MaxDamage, 10);
        210: Inc(MaxDamage, 15);
        216: Inc(MaxDamage, 15);
        2: Inc(MaxDamage, 4);
        18: Inc(MaxDamage, 4);
        119: Dec(MaxDamage, 2);
      else
        Inc(MaxDamage, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonWMissile)] div 2);
      end;
  end;
end;
{ @end $741EC0 }

{ @routine $74207C TCustomWeapon_LoadFromBuffer }
procedure TCustomWeapon.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  CustomInfo := Galaxy.RequireCustomWeaponInfo(Buffer.ReadWideString);
  inherited LoadFromBuffer(Buffer, Galaxy);
end;
{ @end $74207C }

{ @routine $7420F0 TWeapon_SaveToBlock }
procedure TWeapon.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // Decoded: 'Radius'
  Block.AddParam(DecodeTextW('MailnoDrakmoarglen'), IntToStr(MinDamage)); // Decoded: 'MinDamage'
  Block.AddParam(DecodeTextW('MianxaDoarmuavgre'), IntToStr(MaxDamage)); // Decoded: 'MaxDamage'
  Block.AddParam(DecodeTextW('Almamuo'), IntToStr(Ammo)); // Decoded: 'Ammo'
  Block.AddParam(DecodeTextW('MraixoAsmImGod'), IntToStr(AmmoCapacity)); // Decoded: 'MaxAmmo'
end;
{ @end $7420F0 }

{ @routine $7423D4 TCustomWeapon_SaveToBlock }
procedure TCustomWeapon.SaveToBlock(Block: TBlockParEC);
begin
  Block.AddParam(DecodeTextW('CrulsitroimaTryspie'), CustomInfo.ConfigName); // Decoded: 'CustomType'
  inherited SaveToBlock(Block);
end;
{ @end $7423D4 }

{ @routine $742470 TWeapon_LoadFromBlock }
procedure TWeapon.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // Decoded: 'Radius'
  MinDamage := StrToInt(Block.GetParam(DecodeTextW('MailnoDrakmoarglen'))); // Decoded: 'MinDamage'
  MaxDamage := StrToInt(Block.GetParam(DecodeTextW('MianxaDoarmuavgre'))); // Decoded: 'MaxDamage'
  Ammo := StrToInt(Block.GetParam(DecodeTextW('Almamuo'))); // Decoded: 'Ammo'
  AmmoCapacity := StrToInt(Block.GetParam(DecodeTextW('MraixoAsmImGod'))); // Decoded: 'MaxAmmo'
end;
{ @end $742470 }

{ @routine $742748 TCustomWeapon_LoadFromBlock }
procedure TCustomWeapon.LoadFromBlock(Block: TBlockParEC);
begin
  CustomInfo := Galaxy.RequireCustomWeaponInfo(Block.GetParam(DecodeTextW('CrulsitroimaTryspie'))); // Decoded: 'CustomType'
  inherited LoadFromBlock(Block);
end;
{ @end $742748 }

{ @routine $7427FC TWeapon_ResolveLoadedReferences }
procedure TWeapon.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  if LoadedTargetKind = wtkShip then Target := TObject(Galaxy.IdToShip(Integer(Target), True)) as TShip
  else if LoadedTargetKind = wtkItem then Target := TObject(Galaxy.IdToItem(Integer(Target), True)) as TItem
  else if LoadedTargetKind = wtkAsteroid then Target := TObject(Galaxy.IdToAsteroid(Integer(Target))) as TAsteroid
  else if LoadedTargetKind = wtkMissile then Target := TObject(Galaxy.IdToMissile(Integer(Target))) as TMissile;
end;
{ @end $7427FC }

{ @routine $7428C4 TWeapon_ClearReferences }
procedure TWeapon.ClearReferences;
begin
  inherited ClearReferences;
  LoadedTargetKind := wtkNone;
  Target := nil;
end;
{ @end $7428C4 }

{ @routine $7428E8 TWeapon_Unequip }
procedure TWeapon.Unequip;
begin
  inherited Unequip;
  Target := nil;
end;
{ @end $7428E8 }

{ @routine $742904 TWeapon_CalculateGeneratedAmmoCapacity }
function TWeapon.CalculateGeneratedAmmoCapacity: Integer;
begin
  Result := TechLevel * 5 + 25;
end;
{ @end $742904 }

{ @routine $742924 TWeapon_CalculateGeneratedMinDamage }
function TWeapon.CalculateGeneratedMinDamage: Integer;
begin
  Result := Round(GetWeaponInfo.MinDamage * GetWeaponInfo.DamageScaleByLevel[TechLevel]);
end;
{ @end $742924 }

{ @routine $742964 TWeapon_CalculateGeneratedMaxDamage }
function TWeapon.CalculateGeneratedMaxDamage: Integer;
begin
  Result := Round(GetWeaponInfo.MaxDamage * GetWeaponInfo.DamageScaleByLevel[TechLevel]);
end;
{ @end $742964 }

{ @routine $7429A4 TWeapon_CalculateGeneratedRange }
function TWeapon.CalculateGeneratedRange: Integer;
begin
  Result := Round(GetWeaponInfo.AverageRange * WeaponRangeLevelFactors[TechLevel]);
end;
{ @end $7429A4 }

{ @routine $7429D8 TWeapon_CalculateStandardMaxDamage }
function TWeapon.CalculateStandardMaxDamage: Integer;
var BonusKind: Byte;
begin
  Result := CalculateGeneratedMaxDamage;
  BonusKind := WeaponDamageClasses[Ord(ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags))].BonusKind;
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]);
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]);
end;
{ @end $7429D8 }

{ @routine $742A68 TWeapon_CalculateStandardRange }
function TWeapon.CalculateStandardRange: Integer;
begin
  Result := CalculateGeneratedRange;
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonWRadius)]);
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(bonWRadius)]);
end;
{ @end $742A68 }

{ @routine $742AC8 CalculateGeneratedWeaponCost }
function CalculateGeneratedWeaponCost(Info: PWeaponInfo; Weight: Cardinal; Level, Owner: Byte): Integer;
var LevelCost: Single;
begin
  LevelCost := RemapClamped(Level, 1, 8, 1, 4) * Info.CostFactor;
  Result := RoundAndTruncateToTens(RemapClamped(Info.AverageSize / Weight, 0.5, 2, 1, 2) *
    LevelCost * 250 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $742AC8 }

{ @routine $742B8C TWeapon_Improve }
procedure TWeapon.Improve(Kind: TImprovementKind);
var CurrentDamage, BaseDamage, ModuleDamage: Integer; Info: PWeaponInfo;
begin
  if Kind = ikAny then Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  Info := GetWeaponInfo;
  if DetailImprovement = 0 then
    if Info.ShotType in [wstTorpedo..wstRocket] then DetailImprovement := 1
    else if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then DetailImprovement := 1
    else DetailImprovement := 2;
  CurrentDamage := MaxDamage;
  BaseDamage := Info.MaxDamage;
  if (Byte(Info.ShotType) in [Ord(wstMissile)..Ord(wstRocket)]) and (MicroModuleIndex > 0) and not Galaxy.AreOldMissileBonusesEnabled then
  begin
    ModuleDamage := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[WeaponDamageClasses[Ord(ClassifyWeaponDamageFlags(Info.DamageFlags))].BonusKind];
    CurrentDamage := Ceil(CurrentDamage - (1 - 1 / GetShotCount) * ModuleDamage);
  end;
  if DetailImprovement = 1 then
    case Kind of
      ikMinor:
        begin
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.1, 0.2)) + 1;
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.02, 0.04)));
        end;
      ikMedium:
        begin
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.2, 0.3)) + 2;
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.03, 0.04)));
        end;
      ikMajor:
        begin
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.3, 0.4)) + 3;
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.04, 0.06)));
        end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      ikMinor:
        begin
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.04, 0.07) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.03, 0.06)));
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.03, 0.06) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.05, 0.1)) + 1;
        end;
      ikMedium:
        begin
          Inc(Range, RoundAndTruncateToTens(Range * SeededRandomFloatRange(Id * 354571, 0.04, 0.07) + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.06, 0.08)));
          MaxDamage := MaxDamage + Round(CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.03, 0.06) + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.1, 0.15)) + 2;
        end;
      ikMajor:
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
{ @end $742B8C }

{ @routine $743300 TWeapon_HasStandardStats }
function TWeapon.HasStandardStats: Boolean;
begin
  Result := (CalculateStandardMaxDamage = MaxDamage) and (CalculateStandardRange = Range);
end;
{ @end $743300 }

{ @routine $74333C TWeapon_GetDisplayName }
function TWeapon.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if (SpecialModuleIndex <> 0) and
    (MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace <> '') then
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].Name
  else Result := GetShortName;
  if HasMicroModule then Result := Result + ' ' + WrapTextInColor(GetMicroModuleQuotedName, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;
{ @end $74333C }

{ @routine $74344C TWeapon_GetShortName }
function TWeapon.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Weapon.Name.' + GetConfigName);
end;
{ @end $74344C }

{ @routine $743508 TWeapon_GetInfoText }
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
    LocalizedText('Items.Weapon.Type' + WeaponDamageClasses[Ord(DamageClass)].Name) + LevelText);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;
{ @end $743508 }

{ @routine $7437B8 TWeapon_ReplaceInfoTokens }
procedure TWeapon.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  UnusedNativeText: WideString; // Native initializes/finalizes this extra string slot without reading it.
  ModuleBonus, EffectiveBonus, BaseDamage, I: Integer;
  DamageClass: Byte;
  ExpectedRange, CurrentRange, BaseRange, ExpectedDamage: Integer;
  Entry: PExtraSpecial;
  ShipBonus: Integer;
begin
  if Cardinal(GetDamageFlags) and $100000 <> 0 then // Native flag displays the maximum as the minimum too.
    ReplaceTextToken(Text, '<MinDamage>', IntToStr(Max(MaxDamage, MinDamage)), ColorTag)
  else ReplaceTextToken(Text, '<MinDamage>', IntToStr(MinDamage), ColorTag);
  ModuleBonus := 0;
  DamageClass := Byte(ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags));
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
  if ModuleBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), '<color=0,255,0>');
  if ModuleBonus < 0 then BonusText := WrapTextInColor(IntToStr(ModuleBonus), '<color=255,0,0>');
  if (Ship <> nil) and (EquippedFlag <> 0) then ShipBonus := TShip(Ship).GetTotalStatBonus(WeaponDamageClasses[DamageClass].BonusKind)
  else ShipBonus := 0;
  if ShipBonus <> 0 then
    if ShipBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(ShipBonus) + ')', '<color=255,167,84>')
    else BonusText := BonusText + WrapTextInColor('(' + IntToStr(ShipBonus) + ')', '<color=255,167,84>');
  if BaseDamage = ExpectedDamage then ReplaceTextToken(Text, '<MaxDamage>', IntToStr(BaseDamage), ColorTag)
  else if BaseDamage > ExpectedDamage then ReplaceTextToken(Text, '<MaxDamage>', WrapTextInColor(IntToStr(BaseDamage), '<color=0,255,0>'), ColorTag)
  else ReplaceTextToken(Text, '<MaxDamage>', WrapTextInColor(IntToStr(BaseDamage), '<color=255,0,0>'), ColorTag);
  ReplaceTextToken(Text, '<Bonus>', BonusText, ColorTag);
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    ModuleBonus := 0;
    if ExtraSpecials <> nil then
      for I := 0 to ExtraSpecials.Count - 1 do
      begin
        Entry := ExtraSpecials[I];
        Inc(ModuleBonus, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(bonWRadius)] * Entry.Count);
      end;
    ExpectedRange := CalculateGeneratedRange + ModuleBonus;
    CurrentRange := Range + ModuleBonus;
    if MicroModuleIndex <> 0 then Inc(ModuleBonus, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonWRadius)])
    else ModuleBonus := 0;
    BaseRange := CurrentRange - ModuleBonus;
    EffectiveBonus := Max(CurrentRange, GetWeaponInfo.MissileRange) - Max(BaseRange, GetWeaponInfo.MissileRange);
    if ModuleBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(EffectiveBonus), '<color=0,255,0>')
    else if ModuleBonus < 0 then
      if EffectiveBonus < 0 then BonusText := WrapTextInColor(IntToStr(EffectiveBonus), '<color=255,0,0>')
      else BonusText := WrapTextInColor('-0', '<color=255,0,0>')
    else BonusText := '';
    if (Ship <> nil) and (EquippedFlag <> 0) then ShipBonus := TShip(Ship).GetTotalStatBonus(Ord(bonWRadius))
    else ShipBonus := 0;
    EffectiveBonus := Max(CurrentRange + ShipBonus, GetWeaponInfo.MissileRange) - Max(CurrentRange, GetWeaponInfo.MissileRange);
    if ShipBonus > 0 then BonusText := BonusText + WrapTextInColor('(+' + IntToStr(EffectiveBonus) + ')', '<color=255,167,84>')
    else if ShipBonus < 0 then
      if EffectiveBonus < 0 then BonusText := BonusText + WrapTextInColor(IntToStr(EffectiveBonus) + ')', '<color=255,167,84>') // Native negative branch omits the opening parenthesis.
      else BonusText := BonusText + WrapTextInColor('(-0)', '<color=255,167,84>');
    if BaseRange = ExpectedRange then ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange))) + BonusText, ColorTag)
    else if BaseRange > ExpectedRange then ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange)), '<color=0,255,0>') + BonusText, ColorTag)
    else ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange)), '<color=255,0,0>') + BonusText, ColorTag);
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
        Inc(ModuleBonus, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(bonWRadius)] * Entry.Count);
      end;
    ExpectedRange := CalculateGeneratedRange + ModuleBonus;
    CurrentRange := Range + ModuleBonus;
    if MicroModuleIndex <> 0 then Inc(ModuleBonus, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonWRadius)])
    else ModuleBonus := 0;
    BaseRange := CurrentRange - ModuleBonus;
    if ModuleBonus > 0 then BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), '<color=0,255,0>')
    else if ModuleBonus < 0 then BonusText := WrapTextInColor(IntToStr(ModuleBonus), '<color=255,0,0>')
    else BonusText := '';
    if (Ship <> nil) and (EquippedFlag <> 0) then ShipBonus := TShip(Ship).GetTotalStatBonus(Ord(bonWRadius))
    else ShipBonus := 0;
    if ShipBonus <> 0 then
      if ShipBonus > 0 then BonusText := BonusText + WrapTextInColor('+' + IntToStr(ShipBonus), '<color=255,167,84>')
      else BonusText := BonusText + WrapTextInColor(IntToStr(ShipBonus), '<color=255,167,84>');
    if BaseRange = ExpectedRange then ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(BaseRange)) + BonusText, ColorTag)
    else if BaseRange > ExpectedRange then ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseRange), '<color=0,255,0>') + BonusText, ColorTag)
    else ReplaceTextToken(Text, '<Radius>', WrapTextInColor(IntToStr(BaseRange), '<color=255,0,0>') + BonusText, ColorTag);
  end;
  ReplaceTextToken(Text, '<CntAttacks>', IntToStr(GetAttackCount), ColorTag);
end;
{ @end $7437B8 }

{ @routine $74493C TWeapon_GetDescriptionText }
function TWeapon.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.TWeapon.Description.' + GetConfigName);
end;
{ @end $74493C }

{ @routine $7449E8 TWeapon_GetShotDelayFactor }
function TWeapon.GetShotDelayFactor: Double;
var SpeedPercent, I: Integer; Entry: PExtraSpecial;
begin
  SpeedPercent := GetWeaponInfo.ShotSpeedPercent;
  if MicroModuleIndex <> 0 then Inc(SpeedPercent, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonShotSpeed)]);
  if SpecialModuleIndex <> 0 then Inc(SpeedPercent, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(bonShotSpeed)]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(SpeedPercent, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(bonShotSpeed)] * Entry.Count);
    end;
  SpeedPercent := Max(0, Min(100, SpeedPercent));
  Result := 1 - SpeedPercent * 0.01;
end;
{ @end $7449E8 }

{ @routine $744AF8 TWeapon_GetBitmapResourceName }
function TWeapon.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0) and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)] + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)];
end;
{ @end $744AF8 }

{ @routine $744C20 TCustomWeapon_GetBitmapResourceName }
function TCustomWeapon.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0) and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result := 'Bm.Items.' + GiResourceSuffix + 'W' + GetConfigName + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else Result := 'Bm.Items.' + GiResourceSuffix + 'W' + GetConfigName;
end;
{ @end $744C20 }

{ @routine $744D58 TWeapon_NeedsAmmo }
function TWeapon.NeedsAmmo: Boolean;
begin
  Result := False;
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
    if Ammo < AmmoCapacity then Result := True;
end;
{ @end $744D58 }

{ @routine $744D90 TWeapon_CalculateAmmoRefillCost }
function TWeapon.CalculateAmmoRefillCost: Integer;
var MissingAmmo: Integer; UnitCost: Single;
begin
  Result := 0;
  if not (GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) then Exit;
  if Ammo < AmmoCapacity then
  begin
    MissingAmmo := AmmoCapacity - Ammo;
    UnitCost := Galaxy.ScaleIntByTechLevel(10, 100);
    Result := Round(MissingAmmo * UnitCost);
  end;
end;
{ @end $744D90 }

{ @routine $744E04 TWeapon_GetShotPalette }
function TWeapon.GetShotPalette: Integer;
begin
  if (SpecialModuleIndex = 0) or (MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual = -1) then
    Result := GetWeaponInfo.DefaultPalette
  else Result := MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual;
end;
{ @end $744E04 }

{ @routine $744E5C TWeapon_GetDamageFlags }
function TWeapon.GetDamageFlags: TDamageFlagSet;
var I: Integer; Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.DamageFlags;
  if SpecialModuleIndex <> 0 then
    Result := Result + TDamageFlagSet(MicroModuleTemplates[SpecialModuleIndex - 1].WeaponDamageFlags);
  if MicroModuleIndex <> 0 then
    Result := Result + TDamageFlagSet(MicroModuleTemplates[MicroModuleIndex - 1].WeaponDamageFlags);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Result := Result + TDamageFlagSet(MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].WeaponDamageFlags);
    end;
end;
{ @end $744E5C }

{ @routine $744F14 TWeapon_GetShotCount }
function TWeapon.GetShotCount: Integer;
var I: Integer; Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.ShotCount;
  if not (GetWeaponInfo.ShotType in [wstChain, wstMissile, wstRocket]) then Exit;
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(bonShots)]);
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonShots)]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(Result, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(bonShots)] * Entry.Count);
    end;
  Result := Max(Result, 1);
end;
{ @end $744F14 }

{ @routine $745004 TWeapon_GetAttackCount }
function TWeapon.GetAttackCount: Integer;
var I: Integer; Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.AttackCount;
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(bonAttacks)]);
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonAttacks)]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(Result, MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[Ord(bonAttacks)] * Entry.Count);
    end;
  Result := Max(Result, 1);
end;
{ @end $745004 }

{ @routine $7450D4 TWeapon_GetWeaponInfo }
function TWeapon.GetWeaponInfo: PWeaponInfo;
begin
  Result := @WeaponInfos[Ord(ItemType)];
end;
{ @end $7450D4 }

{ @routine $745104 TCustomWeapon_GetWeaponInfo }
function TCustomWeapon.GetWeaponInfo: PWeaponInfo;
begin
  Result := CustomInfo;
end;
{ @end $745104 }

{ @routine $745120 TWeapon_GetConfigName }
function TWeapon.GetConfigName: WideString;
begin
  Result := IntToStr(Ord(ItemType) - Ord(t_Weapon1) + 1);
end;
{ @end $745120 }

{ @routine $745180 TCustomWeapon_GetConfigName }
function TCustomWeapon.GetConfigName: WideString;
begin
  Result := CustomInfo.ConfigName;
end;
{ @end $745180 }

{ @routine $7451A4 TGoods_Init }
procedure TGoods.Init(ItemType: TItemType; Quantity: Integer);
begin
  Self.ItemType := ItemType;
  Self.Quantity := Quantity;
  Weight := Quantity;
  Cost := GoodsMarket[Ord(Self.ItemType)].AveragePrice * Self.Quantity;
  NaturalFlag := False;
end;
{ @end $7451A4 }

{ @routine $7451FC TGoods_SaveToBuffer }
procedure TGoods.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Quantity);
  Buffer.AddBoolean(NaturalFlag);
end;
{ @end $7451FC }

{ @routine $745234 TGoods_LoadFromBuffer }
procedure TGoods.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Quantity := Buffer.GetInt32;
  NaturalFlag := Buffer.GetBoolean;
end;
{ @end $745234 }

{ @routine $745274 TGoods_GetDisplayName }
function TGoods.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := GoodsMarket[Ord(ItemType)].DisplayName;
end;
{ @end $745274 }

{ @routine $7452C4 TGoods_GetInfoText }
function TGoods.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := LocalizedText('Items.Goods.Text' + IntToStr(Ord(ItemType) + 1));
  Result := WrapTextInColor(GetDisplayName, ColorTag) + Text;
end;
{ @end $7452C4 }

{ @routine $7453BC TGoods_GetDescriptionText }
function TGoods.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Goods.Description.' + IntToStr(Ord(ItemType) + 1));
end;
{ @end $7453BC }

{ @routine $745464 TGoods_GetBitmapResourceName }
function TGoods.GetBitmapResourceName: WideString;
begin
  Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)];
end;
{ @end $745464 }

{ @routine $7454EC TCountableItem_SaveToBuffer }
procedure TCountableItem.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(StackCount);
  Buffer.AddBoolean(Boolean(DropFlag));
end;
{ @end $7454EC }

{ @routine $745524 TCountableItem_LoadFromBuffer }
procedure TCountableItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  StackCount := Buffer.GetInt32;
  DropFlag := Byte(Buffer.GetBoolean);
end;
{ @end $745524 }

{ @routine $745564 TCountableItem_Init }
procedure TCountableItem.Init(ConfigName: WideString; Count: Integer; DropFlag: Byte);
begin
  ItemType := t_UselessCountableItem;
  ConfigBlockName := ConfigName;
  Self.DropFlag := DropFlag;
  StackCount := Count;
  Weight := GetUnitSize * Count;
  Cost := Count;
  OwnerId := Byte(oiUninhabited);
  EquippedFlag := 0;
  ConditionPercent := 0;
  BrokenFlag := 1;
end;
{ @end $745564 }

{ @routine $745610 TCountableItem_GetDisplayName }
function TCountableItem.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Name');
end;
{ @end $745610 }

{ @routine $7456DC TCountableItem_GetInfoText }
function TCountableItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Text');
  ReplaceTextToken(Result, '<N>', IntToStr(StackCount), ColorTag);
  if ScriptItem <> nil then Result := TScriptItem(ScriptItem).FormatDataText(Result, ColorTag);
end;
{ @end $7456DC }

{ @routine $745820 TCountableItem_GetDescriptionText }
function TCountableItem.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Description');
end;
{ @end $745820 }

{ @routine $7458DC TCountableItem_GetBitmapResourceName }
function TCountableItem.GetBitmapResourceName: WideString;
begin
  if StackCount <= 19 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '0_'
  else if StackCount <= 39 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '1_'
  else if StackCount <= 59 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '2_'
  else if StackCount <= 79 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '3_'
  else Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '4_';
end;
{ @end $7458DC }

{ @routine $745A70 TCountableItem_GetUnitSize }
function TCountableItem.GetUnitSize: Integer;
var Block: TBlockParEC;
begin
  Result := 1;
  if ItemType <> t_Protoplasm then
  begin
    Block := LanguageDataConfig.GetBlockByPath('Items.CustomCountables.' + ConfigBlockName);
    if Block.CountParams('UnitSize') > 0 then Result := ExtractDigitsToIntW(Block.GetParam('UnitSize'));
  end;
end;
{ @end $745A70 }

{ @routine $745B68 TCountableItem_Split }
function TCountableItem.Split(Count: Integer): TCountableItem;
var
  SplitCount, I: Integer;
  NewScriptItem, OriginalScriptItem: TScriptItem;
begin
  SplitCount := Min(StackCount, Count);
  if ItemType = t_Protoplasm then
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
{ @end $745B68 }

{ @routine $745E2C TCountableItem_CanMerge }
function TCountableItem.CanMerge(Other: TObject): Boolean;
var OtherStack: TCountableItem;
begin
  Result := False;
  if not (Other is TCountableItem) then Exit;
  if Self = Other then Exit;
  if TItem(Other).ItemType <> ItemType then Exit;
  OtherStack := TCountableItem(Other);
  if Self is TProtoplasm then
    if OtherStack.DominatorSeries <> DominatorSeries then Exit;
  if ConfigBlockName = OtherStack.ConfigBlockName then Result := True;
end;
{ @end $745E2C }

{ @routine $745EA8 TCountableItem_Merge }
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
{ @end $745EA8 }

{ @routine $745F04 TProtoplasm_Init }
procedure TProtoplasm.Init(Count: Integer; DropFlag: Byte);
begin
  ItemType := t_Protoplasm;
  StackCount := Count;
  Weight := Count;
  Cost := Count * 10;
  OwnerId := Byte(oiDominator);
  Self.DropFlag := DropFlag;
  EquippedFlag := 0;
  ConditionPercent := 0;
  BrokenFlag := 1;
end;
{ @end $745F04 }

{ @routine $745F68 TProtoplasm_GetDisplayName }
function TProtoplasm.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Nod.Name') + ' ' + LocalizedText('Items.Nod.S' + IntToStr(Ord(DominatorSeries)));
end;
{ @end $745F68 }

{ @routine $746074 TProtoplasm_GetInfoText }
function TProtoplasm.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Nod.Text');
  ReplaceTextToken(Result, '<N>', IntToStr(StackCount), ColorTag);
end;
{ @end $746074 }

{ @routine $746140 TProtoplasm_GetDescriptionText }
function TProtoplasm.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Nod.Description');
end;
{ @end $746140 }

{ @routine $746190 TProtoplasm_GetBitmapResourceName }
function TProtoplasm.GetBitmapResourceName: WideString;
begin
  if StackCount <= 19 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod0_'
  else if StackCount <= 39 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod1_'
  else if StackCount <= 59 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod2_'
  else if StackCount <= 79 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod3_'
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Nod4_';
end;
{ @end $746190 }

{ @routine $746318 TEquipmentWithActCode_Create }
constructor TEquipmentWithActCode.Create;
begin
  inherited Create;
  ActionCode := nil;
  ActCodeInitialized := False;
end;
{ @end $746318 }

{ @routine $746368 TEquipmentWithActCode_Destroy }
destructor TEquipmentWithActCode.Destroy;
begin
  ActionCode := nil;
  inherited Destroy;
end;
{ @end $746368 }

{ @routine $7463A4 TUselessItem_Create }
constructor TUselessItem.Create;
begin
  inherited Create;
  DisplayAsArtefact := False;
end;
{ @end $7463A4 }

{ @routine $7463EC TUselessItem_Destroy }
destructor TUselessItem.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    RunItemConfigActionCode(Self, satOnItemDestroy, nil, nil, nil, 0);
  inherited Destroy;
end;
{ @end $7463EC }

{ @routine $746454 TUselessItem_Init }
procedure TUselessItem.Init(ConfigName: WideString; Series: TDominatorSeries; Seed: Cardinal; ForceArtefactDisplay: Boolean);
begin
  ItemType := t_UselessItem;
  DominatorSeries := Series;
  if ConfigName = 'Remains' then begin
    repeat
      ConfigBlockName := 'Remains_' + IntToStr(SeededRandomIntRange(0, UselessItemRemainsCount - 1, Seed));
      if Pos(DominatorSeriesNames[Ord(Series)], LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Owner')) > 0 then Break;
      Inc(Seed);
    until False;
  end else ConfigBlockName := ConfigName;
  if ForceArtefactDisplay then DisplayAsArtefact := True
  else CheckIfWeDisplayAsArtefact;
  if ConfigName = 'Remains' then OwnerId := Byte(oiDominator)
  else OwnerId := OwnerFromInternalName(LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Owner'));
  Weight := StrToInt(AnsiString(LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Size')));
  Weight := Max(1, Round(SeededRandomIntRange(0, Weight, Id * 71621723) * RemapClamped(Galaxy.TechLevel, 4, 8, 0.5, 3) + Weight));
  Cost := Round(Galaxy.ResolveMoneySizeTag(LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Cost'), 2) * SeededRandomFloatRange(Id * 13567157, 0.5, 1.2));
  Cost := RoundAndTruncateToTens(SeededRandomIntRange(150, 200, Id * 13567157) * RemapClamped(Galaxy.TechLevel, 4, 8, 1, 3) *
    RemapClamped(Weight, 10, 100, 1, 6) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].ArcadeRewardScale + Cost);
  Repair;
  CustomText := '';
  Data[0] := 0; Data[1] := 0; Data[2] := 0;
end;
{ @end $746454 }

{ @routine $7468D4 TUselessItem_SaveToBuffer }
procedure TUselessItem.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddWideStringZ(CustomText);
  Buffer.AddIntegerValue(Data[0]);
  Buffer.AddIntegerValue(Data[1]);
  Buffer.AddIntegerValue(Data[2]);
end;
{ @end $7468D4 }

{ @routine $746928 TUselessItem_LoadFromBuffer }
procedure TUselessItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
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
{ @end $746928 }

{ @routine $746A20 TUselessItem_SaveToBlock }
procedure TUselessItem.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('SoyIsaNoarmoed'), ConfigBlockName); // Decoded: 'SysName'
end;
{ @end $746A20 }

{ @routine $746AB0 TUselessItem_LoadFromBlock }
procedure TUselessItem.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  ConfigBlockName := Block.GetParam(DecodeTextW('SoyIsaNoarmoed')); // Decoded: 'SysName'
  CheckIfWeDisplayAsArtefact;
end;
{ @end $746AB0 }

{ @routine $746B58 TUselessItem_GetDisplayName }
function TUselessItem.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) <= 0 then Result := '' else Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Name');
end;
{ @end $746B58 }

{ @routine $746C5C TUselessItem_GetInfoText }
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
{ @end $746C5C }

{ @routine $746E60 TUselessItem_GetDescriptionText }
function TUselessItem.GetDescriptionText: WideString;
begin
  if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) <= 0 then Result := '' else Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Description');
end;
{ @end $746E60 }

{ @routine $746F54 TUselessItem_GetBitmapResourceName }
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
{ @end $746F54 }

{ @routine $747244 TUselessItem_IsDominatorRemains }
function TUselessItem.IsDominatorRemains: Boolean;
begin
  Result := (OwnerId = Byte(oiDominator)) and (Pos('Remains_', ConfigBlockName) = 1);
end;
{ @end $747244 }

{ @routine $747294 TUselessItem_CheckIfWeDisplayAsArtefact }
procedure TUselessItem.CheckIfWeDisplayAsArtefact;
var
  I: Integer;
begin
  DisplayAsArtefact := False;
  for I := 0 to Length(UselessItemLootPools[3]) - 1 do
    if UselessItemLootPools[3][I] = ConfigBlockName then
    begin
      DisplayAsArtefact := True;
      Break;
    end;
end;
{ @end $747294 }

{ @routine $7472F4 TUselessItem_GetOnUseCodeText }
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
{ @end $7472F4 }

{ @routine $74738C TUselessItem_GetActionCode }
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
{ @end $74738C }

{ @routine $747424 TCistern_Init }
procedure TCistern.Init(Fuel: Integer; Capacity, Owner: Byte);
begin
  ItemType := t_Cistern;
  Self.Capacity := Capacity;
  Weight := Capacity;
  Self.Fuel := Min(Self.Capacity, Fuel);
  Cost := 10 * Capacity;
  OwnerId := Owner;
  EquippedFlag := 0;
  Repair;
end;
{ @end $747424 }

{ @routine $7474A4 TCistern_SaveToBuffer }
procedure TCistern.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(Capacity));
  Buffer.AddIntegerValue(Fuel);
end;
{ @end $7474A4 }

{ @routine $7474DC TCistern_LoadFromBuffer }
procedure TCistern.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Capacity := Buffer.GetByte;
  Fuel := Buffer.GetInt32;
end;
{ @end $7474DC }

{ @routine $74751C TCistern_SaveToBlock }
procedure TCistern.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('FiuNeol'), IntToStr(Fuel)); // Decoded: 'Fuel'
  Block.AddParam(DecodeTextW('CraspiaNcliotay'), IntToStr(Capacity)); // Decoded: 'Capacity'
end;
{ @end $74751C }

{ @routine $747634 TCistern_LoadFromBlock }
procedure TCistern.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Fuel := StrToInt(Block.GetParam(DecodeTextW('FiuNeol'))); // Decoded: 'Fuel'
  Capacity := StrToInt(Block.GetParam(DecodeTextW('CraspiaNcliotay'))); // Decoded: 'Capacity'
end;
{ @end $747634 }

{ @routine $747744 TCistern_GetDisplayName }
function TCistern.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Cistern.Name');
end;
{ @end $747744 }

{ @routine $7477AC TCistern_GetInfoText }
function TCistern.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Cistern.Text');
  ReplaceTextToken(Result, '<Fuel>', IntToStr(Fuel), ColorTag);
  ReplaceTextToken(Result, '<Capacity>', IntToStr(Capacity), ColorTag);
end;
{ @end $7477AC }

{ @routine $7478E8 TCistern_GetDescriptionText }
function TCistern.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Cistern.Description');
end;
{ @end $7478E8 }

{ @routine $747940 TCistern_GetBitmapResourceName }
function TCistern.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Cistern_';
end;
{ @end $747940 }

{ @routine $747A10 TSatellite_InitGenerated }
procedure TSatellite.InitGenerated(TypeId, Owner: Byte; Seed: Cardinal);
var Roll: Single; SpeedText: WideString; WearLevel: Byte;
begin
  ItemType := t_Satellite;
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
  Weight := StrToInt(LookupLocalizedTextByKey('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Size'));
  Weight := Round(NextRandomIntRange(0, Weight, Seed) * RemapClamped(aGalaxy.Galaxy.TechLevel, 4, 8, 1, 1.5) + Weight div 2);
  Cost := Round(aGalaxy.Galaxy.ResolveMoneySizeTag(LookupLocalizedTextByKey('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Cost'), 2) *
    NextRandomFloatRange(1, 2, Seed));
  Cost := RoundAndTruncateToTens(NextRandomIntRange(150, 200, Seed) * RemapClamped(aGalaxy.Galaxy.TechLevel, 4, 8, 1, 3) *
    RemapClamped(Weight, 10, 50, 2, 1) / GalaxyDifficultyTuning[aGalaxy.Galaxy.DifficultyLevels[7]].QuestMoneyFactor + Cost);
  WearLevel := SizeTagToLevel(LookupLocalizedTextByKey('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Wear'));
  WearPerTurn := GenerateValueForSizeLevel(WearLevel, 1, 10, 30, Seed * $E73FE205) * 0.1;
  Repair;
end;
{ @end $747A10 }

{ @routine $747F8C TSatellite_SaveToBuffer }
procedure TSatellite.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(SatelliteTypeId));
  Buffer.AddIntegerValue(TrajectoryIndex);
  if TargetPlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord((TObject(TargetPlanet) as TPlanet).Id);
  Buffer.AddAnsiChar(AnsiChar(WaterExplorationRate));
  Buffer.AddAnsiChar(AnsiChar(LandExplorationRate));
  Buffer.AddAnsiChar(AnsiChar(HillExplorationRate));
  Buffer.AddSingle(WearPerTurn);
end;
{ @end $747F8C }

{ @routine $74802C TSatellite_LoadFromBuffer }
procedure TSatellite.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  SatelliteTypeId := Buffer.GetByte;
  TrajectoryIndex := Buffer.GetInt32;
  TargetPlanet := Pointer(Buffer.GetUInt32);
  WaterExplorationRate := Buffer.GetByte;
  LandExplorationRate := Buffer.GetByte;
  HillExplorationRate := Buffer.GetByte;
  WearPerTurn := Buffer.GetSingle;
end;
{ @end $74802C }

{ @routine $7480B0 TSatellite_SaveToBlock }
procedure TSatellite.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('ToyIprey'), IntToStr(SatelliteTypeId)); // Decoded: 'Type'
  Block.AddParam(DecodeTextW('WuartTewrf'), IntToStr(WaterExplorationRate)); // Decoded: 'Water'
  Block.AddParam(DecodeTextW('LLagnsd3'), IntToStr(LandExplorationRate)); // Decoded: 'Land'
  Block.AddParam(DecodeTextW('HbiFldle'), IntToStr(HillExplorationRate)); // Decoded: 'Hill'
  Block.AddParam(DecodeTextW('WoeIamrr'), FloatToStr(WearPerTurn)); // Decoded: 'Wear'
end;
{ @end $7480B0 }

{ @routine $7482FC TSatellite_LoadFromBlock }
procedure TSatellite.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  SatelliteTypeId := StrToInt(Block.GetParam(DecodeTextW('ToyIprey'))); // Decoded: 'Type'
  WaterExplorationRate := StrToInt(Block.GetParam(DecodeTextW('WuartTewrf'))); // Decoded: 'Water'
  LandExplorationRate := StrToInt(Block.GetParam(DecodeTextW('LLagnsd3'))); // Decoded: 'Land'
  HillExplorationRate := StrToInt(Block.GetParam(DecodeTextW('HbiFldle'))); // Decoded: 'Hill'
  WearPerTurn := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('WoeIamrr'))); // Decoded: 'Wear'
end;
{ @end $7482FC }

{ @routine $748510 TSatellite_ResolveLoadedReferences }
procedure TSatellite.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  TargetPlanet := TObject(Galaxy.IdToPlanet(Cardinal(TargetPlanet))) as TPlanet;
end;
{ @end $748510 }

{ @routine $74854C TSatellite_ClearReferences }
procedure TSatellite.ClearReferences;
begin
  inherited ClearReferences;
  TargetPlanet := nil;
end;
{ @end $74854C }

{ @routine $748568 TSatellite_GetDisplayName }
function TSatellite.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LookupLocalizedTextByKey('Items.Satellite.Name') + ' ' +
    LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Name') + '-' + IntToStr(Cardinal(Id) mod 100 + 1);
end;
{ @end $748568 }

{ @routine $7486F4 TSatellite_GetInfoText }
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
{ @end $7486F4 }

{ @routine $74894C TSatellite_GetBrokenInUseText }
function TSatellite.GetBrokenInUseText: WideString;
var PlanetName: WideString;
begin
  Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.BrokenInUse');
  if TargetPlanet <> nil then PlanetName := (TObject(TargetPlanet) as TPlanet).Name
  else PlanetName := '';
  ReplaceTextToken(Result, '<Name>', GetDisplayName, '<color=255,240,100>');
  ReplaceTextToken(Result, '<Planet>', PlanetName, '<color=255,240,100>');
end;
{ @end $74894C }

{ @routine $748AB4 TSatellite_GetIdleInfoText }
function TSatellite.GetIdleInfoText: WideString;
var PlanetName: WideString;
begin
  Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.IdleInfo');
  if TargetPlanet <> nil then PlanetName := (TObject(TargetPlanet) as TPlanet).Name
  else PlanetName := '';
  ReplaceTextToken(Result, '<Name>', GetDisplayName, '<color=255,240,100>');
  ReplaceTextToken(Result, '<Size>', IntToStr(Weight), '<color=255,240,100>');
  ReplaceTextToken(Result, '<Planet>', PlanetName, '<color=255,240,100>');
end;
{ @end $748AB4 }

{ @routine $748C60 TSatellite_GetDescriptionText }
function TSatellite.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Description');
end;
{ @end $748C60 }

{ @routine $748D20 TSatellite_GetBitmapResourceName }
function TSatellite.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Satellite' + IntToStr(SatelliteTypeId) + '_';
end;
{ @end $748D20 }

{ @routine $748E20 TTreasureMap_Init }
procedure TTreasureMap.Init(Planet: Pointer; Victim: Pointer);
begin
  ItemType := t_TreasureMap;
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
{ @end $748E20 }

{ @routine $748F6C TTreasureMap_SaveToBuffer }
procedure TTreasureMap.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  if TargetPlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord((TObject(TargetPlanet) as TPlanet).Id);
  Buffer.AddWideStringZ(SourceShipName);
  Buffer.AddWideStringZ(PreviewTablePage1);
  Buffer.AddWideStringZ(PreviewTablePage2);
end;
{ @end $748F6C }

{ @routine $748FE4 TTreasureMap_LoadFromBuffer }
procedure TTreasureMap.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TargetPlanet := Pointer(Buffer.GetUInt32);
  SourceShipName := Buffer.ReadWideString;
  PreviewTablePage1 := Buffer.ReadWideString;
  PreviewTablePage2 := Buffer.ReadWideString;
end;
{ @end $748FE4 }

{ @routine $74909C TTreasureMap_ResolveLoadedReferences }
procedure TTreasureMap.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  TargetPlanet := TObject(Galaxy.IdToPlanet(Cardinal(TargetPlanet))) as TPlanet;
end;
{ @end $74909C }

{ @routine $7490D8 TTreasureMap_ClearReferences }
procedure TTreasureMap.ClearReferences;
begin
  inherited ClearReferences;
  TargetPlanet := nil;
end;
{ @end $7490D8 }

{ @routine $7490F4 TTreasureMap_GetDisplayName }
function TTreasureMap.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.TreasureMap.Name');
end;
{ @end $7490F4 }

{ @routine $749164 TTreasureMap_GetInfoText }
function TTreasureMap.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.TreasureMap.Text') + ' ' + LocalizedText('Items.TreasureMap.Hint');
  ReplaceTextToken(Result, '<Planet>', GetTargetPlanetName, '<color=255,240,100>');
  ReplaceTextToken(Result, '<Ship>', SourceShipName, '<color=255,240,100>');
end;
{ @end $749164 }

{ @routine $7492F8 TTreasureMap_GetDescriptionText }
function TTreasureMap.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.TreasureMap.Description');
end;
{ @end $7492F8 }

{ @routine $749358 TTreasureMap_GetBitmapResourceName }
function TTreasureMap.GetBitmapResourceName: WideString;
var Kind: Integer;
begin
  if OwnerId in [Ord(oiMaloc)..Ord(oiHuman)] then Kind := 1 else Kind := 2;
  Result := 'Bm.ItemsUseless.' + GiResourceSuffix + 'TreasureMap' + IntToStr(Kind) + '_';
end;
{ @end $749358 }

{ @routine $749454 TTreasureMap_GetTargetPlanetName }
function TTreasureMap.GetTargetPlanetName: WideString;
begin
  Result := (TObject(TargetPlanet) as TPlanet).Name;
end;
{ @end $749454 }

{ @routine $7495E0 TTreasureMap_BuildPreviewTable }
function TTreasureMap.BuildPreviewTable(PageIndex: Integer; Planet: Pointer): WideString;
var I, Number: Integer; Entry: PPlanetSurfaceLootEntry;
  Rows, Header, Caption, Rule: WideString; World: TPlanet;

  // @nested $749480 ItemColorTag
  function ItemColorTag(Item: TItem): WideString; // @addr $749480 @ida "void __usercall $name(TItem *Item@<eax>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x749B7B" @note "Nested helper of BuildPreviewTable; caller removes the unused static link."
  begin
    if Item is TGoods then Result := '<color=127,127,127>'
    else if Item is TArtefact then Result := '<color=255,0,0>'
    else if Item is TCistern then Result := '<color=127,127,127>'
    else if Item is TMicroModule then Result := '<color=255,0,255>'
    else if Item is TEquipment then Result := '<color=254,217,7>'
    else Result := '';
  end;

begin
  Rule := WrapTextInColor(StringOfChar('-', TreasureMapRuleLengths[PageIndex]), '<color=127,127,127>');
  Caption := FormatText1(LocalizedColorText('FormGS.PlanetInfo'), '<color=255,240,100>', '<Planet>', (TObject(Planet) as TPlanet).Name);
  Header := Header + #13#10 + '<td=' + IntToStr(0) + '>' + '<align=left>' + Caption + '</align>';
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 3] div 2) + '>' + '<align=center>' + WrapTextInColor(LocalizedText('Items.TreasureMap.Name'), '<color=0,255,0>') + '</align>';
  Caption := FormatText1(LocalizedColorText('FormGS.StarInfo'), '<color=255,240,100>', '<Star>', (TObject(Planet) as TPlanet).CurrentStar.Name);
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 3]) + '>' + '<align=right>' + WrapTextInColor(Caption, '') + '</align>';
  Header := Header + #13#10 + Rule + #13#10;
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 0]) + '>' + '<align=right>' + WrapTextInColor(LocalizedColorText('FormGS.ColumnNumber'), '<color=255,240,100>') + '</align>';
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 1]) + '>' + WrapTextInColor(LocalizedColorText('FormGS.ColumnName'), '<color=255,240,100>');
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 2]) + '>' + '<align=right>' + WrapTextInColor(LocalizedColorText('FormShip.StorageInfo.Size'), '<color=255,240,100>') + '</align>';
  Header := Header + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 3]) + '>' + '<align=right>' + WrapTextInColor(LocalizedColorText('FormShip.StorageInfo.Cost'), '<color=255,240,100>') + '</align>';
  Header := Header + #13#10 + Rule;
  if Planet <> nil then
    if TObject(Planet) is TPlanet then begin
      Rows := '';
      Number := 1;
      World := TObject(Planet) as TPlanet;
      if World.SurfaceLootEntries <> nil then begin
        for I := 0 to World.SurfaceLootEntries.Count - 1 do begin
          Entry := World.SurfaceLootEntries[I];
          if Entry.Item <> nil then
            if GetPlayer.CanAccessSurfaceLootItem(Entry.Item) and not (Entry.Item is TGoods) and not (Entry.Item is TCistern) then begin
              Rows := Rows + #13#10;
              Rows := Rows + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 0]) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Number), '') + '</align>';
              Rows := Rows + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 1]) + '>' + '' + WrapTextInColor(Entry.Item.GetDisplayName, ItemColorTag(Entry.Item)) + '';
              Rows := Rows + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 2]) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Entry.Item.Weight), '<color=0,255,0>') + '</align>';
              Rows := Rows + '<td=' + IntToStr(TreasureMapColumnPositions[PageIndex, 3]) + '>' + '<align=right>' + WrapTextInColor(IntToStr(Entry.Item.Cost), '<color=0,255,255>') + '</align>';
              Inc(Number);
            end;
        end;
        Result := Header + Rows;
      end;
    end;
end;
{ @end $7495E0 }

{ @routine $74A128 TMicroModule_Init }
procedure TMicroModule.Init(ModuleIndex: Integer);
begin
  ItemType := t_MicroModule;
  OwnerId := Byte(oiUninhabited);
  MicroModuleIndex := ModuleIndex + 1;
  Repair;
  Weight := 1;
  Cost := RoundAndTruncateToTens(100 * Galaxy.ComputeScaledSmallMoney(2) /
    (MicroModuleTemplates[MicroModuleIndex - 1].Priority + 20) * SeededRandomFloatRange(Id * 1367, 0.5, 1.2));
  Cost := RoundAndTruncateToTens(SeededRandomIntRange(150, 200, Id * 13567157) *
    RemapClamped(Galaxy.TechLevel, 4, 8, 1, 3) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestMoneyFactor + Cost);
end;
{ @end $74A128 }

{ @routine $74A26C TMicroModule_SaveToBuffer }
procedure TMicroModule.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
end;
{ @end $74A26C }

{ @routine $74A288 TMicroModule_LoadFromBuffer }
procedure TMicroModule.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion < 113 then Buffer.GetInt32;
  if MicroModuleIndex = 0 then MicroModuleIndex := 1;
end;
{ @end $74A288 }

{ @routine $74A2D0 TMicroModule_GetDisplayName }
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
{ @end $74A2D0 }

{ @routine $74A438 TMicroModule_GetPlainName }
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
{ @end $74A438 }

{ @routine $74A588 TMicroModule_GetInfoText }
function TMicroModule.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := GetMicroModuleInfoText(MicroModuleIndex - 1, ColorTag);
end;
{ @end $74A588 }

{ @routine $74A5E4 GetMicroModuleInfoText }
function GetMicroModuleInfoText(ModuleIndex: Integer; ColorTag: WideString): WideString;
var Index, Value, Fraction: Integer; Text: WideString; Kind: TEquipmentBonusKind;
begin
  Index := ModuleIndex + 1;
  Result := LocalizedColorText('MicroModuls.' + MicroModuleTemplates[ModuleIndex].ConfigName + '.Text');
  for Kind := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
    if Kind in [bonExtraAkrinEff..bonExtraAkrinPenalty] then begin
      Value := MicroModuleTemplates[Index - 1].StatBonuses[Ord(Kind)];
      if Value = 0 then ReplaceTextToken(Result, '<' + EquipmentBonusNames[Ord(Kind)] + '>', '--', ColorTag)
      else begin
        if Value > 0 then Text := '+' else Text := '-';
        Value := Abs(Value);
        Fraction := Value mod 100;
        Value := Value div 100;
        if Fraction <> 0 then Text := Text + IntToStr(Value) + '.' + IntToStr(Fraction)
        else Text := Text + IntToStr(Value);
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[Ord(Kind)] + '>', Text, ColorTag);
      end;
    end else begin
      Value := MicroModuleTemplates[Index - 1].StatBonuses[Ord(Kind)];
      if Value > 0 then ReplaceTextToken(Result, '<' + EquipmentBonusNames[Ord(Kind)] + '>', '+' + IntToStr(Value), ColorTag)
      else if Value < 0 then ReplaceTextToken(Result, '<' + EquipmentBonusNames[Ord(Kind)] + '>', IntToStr(Value), ColorTag)
      else ReplaceTextToken(Result, '<' + EquipmentBonusNames[Ord(Kind)] + '>', '--', ColorTag);
    end;
end;
{ @end $74A5E4 }

{ @routine $74A9F0 TMicroModule_GetDescriptionText }
function TMicroModule.GetDescriptionText: WideString;
begin
  Result := '';
end;
{ @end $74A9F0 }

{ @routine $74AA08 TMicroModule_GetBitmapResourceName }
function TMicroModule.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := GetMicroModuleBitmapResourceName(MicroModuleIndex - 1);
end;
{ @end $74AA08 }

{ @routine $74AAA4 GetMicroModulePriorityColorTier }
function GetMicroModulePriorityColorTier(ModuleIndex: Integer): Byte;
begin
  case MicroModuleTemplates[ModuleIndex].Priority of
    0..30: Result := 3;
    31..69: Result := 2;
    70..100: Result := 1;
  else Result := 3;
  end;
end;
{ @end $74AAA4 }

{ @routine $74AAEC GetMicroModuleNameColorTag }
function GetMicroModuleNameColorTag(ModuleIndex: Integer): WideString;
begin
  if MicroModuleTemplates[ModuleIndex].Color <> '' then
    Result := '<color=' + MicroModuleTemplates[ModuleIndex].Color + '>'
  else
    case GetMicroModulePriorityColorTier(ModuleIndex) of
      2: Result := '<color=255,240,100>';
      3: Result := '<color=255,0,0>';
    else Result := '<color=17,139,255>';
    end;
end;
{ @end $74AAEC }

{ @routine $74AC14 GetMicroModuleTextColorTag }
function GetMicroModuleTextColorTag(ModuleIndex: Integer): WideString;
begin
  if MicroModuleTemplates[ModuleIndex].Color <> '' then
    Result := '<color=' + MicroModuleTemplates[ModuleIndex].Color + '>'
  else Result := '<color=255,167,84>';
end;
{ @end $74AC14 }

{ @routine $74ACBC GetMicroModuleBitmapResourceName }
function GetMicroModuleBitmapResourceName(ModuleIndex: Integer): WideString;
begin
  if (ModuleIndex >= 0) and (MicroModuleTemplates[ModuleIndex].KindGraph <> '') then
    Result := 'Bm.Micromoduls.' + GiResourceSuffix + 'MM' + MicroModuleTemplates[ModuleIndex].KindGraph + '_'
  else Result := 'Bm.Micromoduls.' + GiResourceSuffix + 'MM' + IntToStr(GetMicroModulePriorityColorTier(ModuleIndex)) + '_';
end;
{ @end $74ACBC }

{ @routine $74ADEC ApplyMicroModule }
function ApplyMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean;
var BonusKind: Byte;
begin
  if (ModuleIndex = -1) or (Item = nil) then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
  Item.MicroModuleIndex := ModuleIndex + 1;
  Item.Weight := Round(Max(1, Item.Weight / 100 * MicroModuleTemplates[Item.MicroModuleIndex - 1].SizePercent));
  Item.Cost := Min(100000000, Round(Max(1, Item.Cost / 100 * MicroModuleTemplates[Item.MicroModuleIndex - 1].CostPercent)));
  case Item.ItemType of
    t_Hull:
      begin
        Inc((Item as THull).Armor, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHull)]);
        (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
      end;
    t_FuelTanks: Inc((Item as TFuelTanks).Capacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)]);
    t_Engine:
      begin
        Inc((Item as TEngine).Speed, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonSpeed)]);
        Inc((Item as TEngine).JumpRange, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonJump)]);
      end;
    t_Radar: Inc((Item as TRadar).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)]);
    t_Scaner: Inc((Item as TScaner).ScanPower, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonScan)]);
    t_RepairRobot: Inc((Item as TRepairRobot).RepairPoints, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)]);
    t_CargoHook:
      begin
        Inc((Item as TCargoHook).PickupPower, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHook)]);
        Inc((Item as TCargoHook).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)]);
        (Item as TCargoHook).MinPullSpeed := (Item as TCargoHook).MinPullSpeed + MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHookMinSpeed)];
        (Item as TCargoHook).MaxPullSpeed := (Item as TCargoHook).MaxPullSpeed + MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHookMaxSpeed)];
      end;
    t_DefGenerator:
      if MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonDef)] <> 0 then
        (Item as TDefGenerator).DamageFactor := (Item as TDefGenerator).DamageFactor -
          (1 - DefensePercentToDamageFactor(MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonDef)]));
  else
    if Item.ItemType in [t_Weapon1..t_CustomWeapon] then
    begin
      BonusKind := WeaponDamageClasses[Ord(ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags))].BonusKind;
      Inc((Item as TWeapon).MaxDamage, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[BonusKind]);
      Inc((Item as TWeapon).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonWRadius)]);
      if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
        Inc((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonAmmo)]);
    end
    else Exception.Create('Микромодуль в оборудование хотели вставить, в которое вставить микромодуль нельзя!'); // Native allocates without raising.
  end;
end;
{ @end $74ADEC }

{ @routine $74B354 RemoveMicroModule }
procedure RemoveMicroModule(Item: TEquipment);
var BonusKind: Byte;
begin
  if (Item = nil) or (Item.MicroModuleIndex = 0) then Exit;
  Item.Weight := Round(Max(1, Item.Weight / MicroModuleTemplates[Item.MicroModuleIndex - 1].SizePercent * 100));
  Item.Cost := Round(Max(1, Item.Cost / MicroModuleTemplates[Item.MicroModuleIndex - 1].CostPercent * 100));
  case Item.ItemType of
    t_Hull:
      begin
        Dec((Item as THull).Armor, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHull)]);
        (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
      end;
    t_FuelTanks: Dec((Item as TFuelTanks).Capacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonFuel)]);
    t_Engine:
      begin
        Dec((Item as TEngine).Speed, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonSpeed)]);
        Dec((Item as TEngine).JumpRange, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonJump)]);
      end;
    t_Radar: Dec((Item as TRadar).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)]);
    t_Scaner: Dec((Item as TScaner).ScanPower, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonScan)]);
    t_RepairRobot: Dec((Item as TRepairRobot).RepairPoints, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)]);
    t_CargoHook:
      begin
        Dec((Item as TCargoHook).PickupPower, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHook)]);
        Dec((Item as TCargoHook).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHookRadius)]);
        (Item as TCargoHook).MinPullSpeed := (Item as TCargoHook).MinPullSpeed - MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHookMinSpeed)];
        (Item as TCargoHook).MaxPullSpeed := (Item as TCargoHook).MaxPullSpeed - MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonHookMaxSpeed)];
      end;
    t_DefGenerator:
      if MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonDef)] <> 0 then
        (Item as TDefGenerator).DamageFactor := (Item as TDefGenerator).DamageFactor +
          (1 - DefensePercentToDamageFactor(MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonDef)]));
  else
    if Item.ItemType in [t_Weapon1..t_CustomWeapon] then
    begin
      BonusKind := WeaponDamageClasses[Ord(ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags))].BonusKind;
      Dec((Item as TWeapon).MaxDamage, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[BonusKind]);
      Dec((Item as TWeapon).Range, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonWRadius)]);
      if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
        Dec((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[Ord(bonAmmo)]);
    end;
  end;
  Item.MicroModuleIndex := 0;
end;
{ @end $74B354 }

{ @routine $74B808 ApplySpecialMicroModule }
procedure ApplySpecialMicroModule(ModuleIndex: Integer; Item: TEquipment);
var BonusKind: Byte;
begin
  if (ModuleIndex = -1) or (Item = nil) or (Item.SpecialModuleIndex <> 0) then
  begin
    RaiseWideMessage('SpecialToEquipment');
    Exit;
  end;
  Item.SpecialModuleIndex := ModuleIndex + 1;
  Item.Weight := Round(Max(1, Item.Weight / 100 * MicroModuleTemplates[ModuleIndex].SizePercent));
  Item.Cost := Min(100000000, RoundAndTruncateToTens(Max(10, Item.Cost / 100 * MicroModuleTemplates[ModuleIndex].CostPercent)));
  if Item.ItemType = t_Hull then
  begin
    (Item as THull).HullType := htSpecial;
    (Item as THull).HullPoints := Item.Weight;
    if (Item.Cost < 0) or (Item.Cost > 100000000) then Item.Cost := 100000000;
  end;
  if Item.ItemType in [t_Weapon1..t_CustomWeapon] then
  begin
    BonusKind := WeaponDamageClasses[Ord(ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags))].BonusKind;
    Inc((Item as TWeapon).MaxDamage, MicroModuleTemplates[ModuleIndex].StatBonuses[BonusKind]);
    Inc((Item as TWeapon).Range, MicroModuleTemplates[ModuleIndex].StatBonuses[Ord(bonWRadius)]);
    if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
      Inc((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[ModuleIndex].StatBonuses[Ord(bonAmmo)]);
  end;
  if MicroModuleTemplates[ModuleIndex].CustomFaction <> '' then Item.CustomFaction := MicroModuleTemplates[ModuleIndex].CustomFaction;
end;
{ @end $74B808 }

{ @routine $74BAB4 RemoveSpecialMicroModule }
procedure RemoveSpecialMicroModule(Item: TEquipment);
var BonusKind: Byte;
begin
  if (Item = nil) or (Item.SpecialModuleIndex = 0) then Exit;
  Item.Weight := Round(Max(1, Item.Weight * 100 / MicroModuleTemplates[Item.SpecialModuleIndex - 1].SizePercent));
  Item.Cost := Round(Max(1, Item.Cost * 100 / MicroModuleTemplates[Item.SpecialModuleIndex - 1].CostPercent));
  if Item.ItemType = t_Hull then begin
    (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
    if (Item.Cost < 0) or (Item.Cost > 100000000) then Item.Cost := 100000000;
  end;
  if Item.ItemType in [t_Weapon1..t_CustomWeapon] then begin
    BonusKind := WeaponDamageClasses[Ord(ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags))].BonusKind;
    Dec((Item as TWeapon).MaxDamage, MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[BonusKind]);
    Dec((Item as TWeapon).Range, MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[Ord(bonWRadius)]);
    if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
      Dec((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[Ord(bonAmmo)]);
  end;
  if (Item.CustomFaction <> '') and (MicroModuleTemplates[Item.SpecialModuleIndex - 1].CustomFaction = Item.CustomFaction) then Item.CustomFaction := '';
  Item.SpecialModuleIndex := 0;
end;
{ @end $74BAB4 }

{ @routine $74BD20 TMicroModule_CalculateNodeExchangeValue }
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
{ @end $74BD20 }

{ @routine $74C090 TMicroModule_GetHighlightedName }
function TMicroModule.GetHighlightedName: WideString;
begin
  Result := WrapTextInColor(MicroModuleTemplates[MicroModuleIndex - 1].Name, '<color=255,240,100>');
end;
{ @end $74C090 }

{ @routine $74C0F0 TMicroModule_CanInstallOn }
function TMicroModule.CanInstallOn(Item: TEquipment): Boolean;
begin
  Result := False;
  if Item.MicroModuleIndex <> 0 then Exit;
  if (Item.SpecialModuleIndex <> 0) and
    MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then Exit;
  if (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonExtraAkrinEff)] <> 0) and (Item.SpecialModuleIndex = 0) then Exit;
  if (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonExtraAkrinPenalty)] <> 0) and (Item.SpecialModuleIndex = 0) then Exit;
  if Item is TWeapon then Result := IsBonusCompatibleWithWeapon(MicroModuleIndex - 1, TWeapon(Item))
  else if Item is THull then Result := IsBonusCompatibleWithHull(MicroModuleIndex - 1, THull(Item))
  else Result := IsBonusCompatibleWithEquipment(MicroModuleIndex - 1, Item);
end;
{ @end $74C0F0 }

{ @routine $74C1E0 CanInstallMicroModule }
function CanInstallMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean;
begin
  Result := False;
  if Item.MicroModuleIndex <> 0 then Exit;
  if (Item.SpecialModuleIndex <> 0) and
    MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then Exit;
  if (MicroModuleTemplates[ModuleIndex].StatBonuses[Ord(bonExtraAkrinEff)] <> 0) and
    (Item.SpecialModuleIndex = 0) then Exit;
  if (MicroModuleTemplates[ModuleIndex].StatBonuses[Ord(bonExtraAkrinPenalty)] <> 0) and
    (Item.SpecialModuleIndex = 0) then Exit;
  if MicroModuleTemplates[ModuleIndex].SpecialOnly then Exit;
  if Item is TWeapon then Result := IsBonusCompatibleWithWeapon(ModuleIndex, TWeapon(Item))
  else if Item is THull then Result := IsBonusCompatibleWithHull(ModuleIndex, THull(Item))
  else Result := IsBonusCompatibleWithEquipment(ModuleIndex, Item);
end;
{ @end $74C1E0 }

{ @routine $74C2D0 IsBonusCompatibleWithEquipment }
function IsBonusCompatibleWithEquipment(ModuleIndex: Integer; Item: TEquipment): Boolean;
begin
  Result := False;
  if not (Byte(Item.ItemType) in TItemTypeMask(MicroModuleTemplates[ModuleIndex].AllowedItemTypes)) then Exit;
  if Item.CustomFaction <> '' then
  begin
    if Pos('<' + Item.CustomFaction + '>', MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions) > 0 then
    begin
      Result := True;
      Exit;
    end;
    if (Item.OwnerId = Byte(oiUninhabited)) or ((Item.OwnerId = Byte(oiDominator)) and
      (TDominatorSeriesMask(MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) <> [Ord(dsBlazer)..Ord(dsTerron)])) then Exit;
  end;
  Result := Item.OwnerId in TOwnerMask(MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask);
  if (Item.OwnerId = Byte(oiDominator)) and not (Byte(Item.DominatorSeries) in
    TDominatorSeriesMask(MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask)) then Result := False;
end;
{ @end $74C2D0 }

{ @routine $74C430 IsBonusCompatibleWithHull }
function IsBonusCompatibleWithHull(ModuleIndex: Integer; Hull: THull): Boolean;
begin
  Result := False;
  if not (Ord(t_Hull) in TItemTypeMask(MicroModuleTemplates[ModuleIndex].AllowedItemTypes)) then Exit;
  if Hull.CustomFaction <> '' then
  begin
    if Pos('<' + Hull.CustomFaction + '>', MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions) > 0 then
    begin
      Result := True;
      Exit;
    end;
    if (Hull.OwnerId = Byte(oiUninhabited)) or ((Hull.OwnerId = Byte(oiDominator)) and
      (TDominatorSeriesMask(MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) <> [Ord(dsBlazer)..Ord(dsTerron)])) then Exit;
  end;
  if ((Hull.OwnerId in TOwnerMask(MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask)) or
    (Hull.PirateBuilt and (Ord(oiPirate) in TOwnerMask(MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask)))) and
    ((Hull.OwnerId <> Byte(oiDominator)) or (Byte(Hull.DominatorSeries) in
      TDominatorSeriesMask(MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask))) then Result := True;
end;
{ @end $74C430 }

{ @routine $74C5A0 IsBonusCompatibleWithWeapon }
function IsBonusCompatibleWithWeapon(ModuleIndex: Integer; Weapon: TWeapon): Boolean;
var AllowedTypes: WideString; Info: PWeaponInfo;
begin
  Result := False;
  if ((Weapon.CustomFaction <> '') and
    (Pos('<' + Weapon.CustomFaction + '>', MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions) > 0)) or
    ((Weapon.OwnerId in TOwnerMask(MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask)) and
     ((Weapon.OwnerId <> Byte(oiDominator)) or (Byte(Weapon.DominatorSeries) in TDominatorSeriesMask(MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask))) and
     ((Weapon.CustomFaction = '') or ((Weapon.OwnerId <> Byte(oiUninhabited)) and ((Weapon.OwnerId <> Byte(oiDominator)) or
       (TDominatorSeriesMask(MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) = [0..2]))))) then
  begin
    if Weapon.ItemType in [t_Weapon1..t_Weapon18] then
    begin
      if Byte(Weapon.ItemType) in TItemTypeMask(MicroModuleTemplates[ModuleIndex].AllowedItemTypes) then Result := True;
    end
    else if Weapon.ItemType = t_CustomWeapon then
    begin
      Info := Weapon.GetWeaponInfo;
      AllowedTypes := MicroModuleTemplates[ModuleIndex].AllowedCustomWeaponTypes;
      if AllowedTypes = 'Any' then Result := True
      else if (dkMissile in Info.DamageFlags) and (Pos('<WMissile>', AllowedTypes) > 0) then Result := True
      else if (dkSplinter in Info.DamageFlags) and (Pos('<WSplinter>', AllowedTypes) > 0) then Result := True
      else if (dkEnergy in Info.DamageFlags) and (Pos('<WEnergy>', AllowedTypes) > 0) then Result := True
      else if Pos('<' + Info.ConfigName + '>', AllowedTypes) > 0 then Result := True;
    end
    else Result := True;
  end;
end;
{ @end $74C5A0 }

{ @routine $74C874 CreateConfiguredArtefactByItemType }
function CreateConfiguredArtefactByItemType(ItemType: TItemType; Owner: Byte): TArtefact;
var Item: TArtefact;
begin
  Result := nil;
  if ItemType in [t_ArtefactHull..t_ArtFastRacks] then begin
    Item := TArtefact(CreateItemByType(ItemType));
    if ItemType = t_ArtefactTransmitter then TArtefactTransmitter(Item).InitTransmitter(Owner)
    else if ItemType = t_ArtefactTranclucator then TArtefactTranclucator(Item).InitTranclucator(Owner, nil, nil)
    else Item.Init(Owner, ItemType);
    Result := Item;
  end;
end;
{ @end $74C874 }

{ @routine $74C8E0 CreateRandomLootItem }
function CreateRandomLootItem(Pool: TItemLootPool; Owner: Byte; Seed: Cardinal): TEquipmentWithActCode;
var Index, Count: Integer;
begin
  Count := Length(ArtefactLootPools[Ord(Pool)]);
  Index := Count + Length(CustomArtefactLootPools[Ord(Pool)]) + Length(UselessItemLootPools[Ord(Pool)]);
  Index := SeededRandomIntRange(0, Index - 1, Seed);
  if Index < Length(ArtefactLootPools[Ord(Pool)]) then
    Result := TObject(CreateConfiguredArtefactByItemType(ArtefactLootPools[Ord(Pool)][Index], Owner)) as TEquipmentWithActCode
  else begin
    Dec(Index, Count);
    if Index < Length(CustomArtefactLootPools[Ord(Pool)]) then begin
      Result := TArtefactCustom.Create;
      Result.ConfigBlockName := CustomArtefactLootPools[Ord(Pool)][Index];
      TArtefactCustom(Result).LoadConfig(True);
      TArtefactCustom(Result).Data[1] := 0;
      TArtefactCustom(Result).Data[2] := 0;
      TArtefactCustom(Result).Data[3] := 0;
      TArtefactCustom(Result).Init(Owner, Result.ItemType);
    end else begin
      Dec(Index, Length(CustomArtefactLootPools[Ord(Pool)]));
      Result := TUselessItem.Create;
      TUselessItem(Result).Init(UselessItemLootPools[Ord(Pool)][Index], dsBlazer, 0, True);
      Result.OwnerId := Owner;
    end;
  end;
end;
{ @end $74C8E0 }

{ @routine $74CA68 TArtefact_Create }
constructor TArtefact.Create;
begin
  inherited Create;
  DisplayAsArtefact := True;
  Repair;
end;
{ @end $74CA68 }

{ @routine $74CAB8 TArtefact_Destroy }
destructor TArtefact.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    RunItemConfigActionCode(Self, satOnItemDestroy, nil, nil, nil, 0);
  inherited Destroy;
end;
{ @end $74CAB8 }

{ @routine $74CB20 TArtefact_LoadFromBuffer }
procedure TArtefact.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if not (ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav,
    t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks]) then
    Repair;
end;
{ @end $74CB20 }

{ @routine $74CB68 TArtefact_Init }
procedure TArtefact.Init(Owner: Byte; ItemType: TItemType);
var
  MinWeightScale, MaxWeightScale, MinCostScale, MaxCostScale: Single;
  MinExtraWeight, MaxExtraWeight, MinCost, MaxCost: Integer;
begin
  Self.ItemType := ItemType;
  OwnerId := Owner;
  if not (Self.ItemType in [t_Artefact..t_Artefact2]) then Weight := GetAverageItemSize(Ord(Self.ItemType));
  case ItemType of
    t_ArtefactHull:
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
    t_ArtefactFuel:
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
    t_ArtefactSpeed:
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
    t_ArtefactPower:
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
    t_ArtefactRadar:
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
    t_ArtefactScaner:
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
    t_ArtefactDroid:
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
    t_ArtefactNano:
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
    t_ArtefactHook:
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
    t_ArtefactDef:
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
    t_ArtefactAnalyzer:
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
    t_ArtefactMiniExpl:
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
    t_ArtefactAntigrav:
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
    t_ArtefactTransmitter:
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
    t_ArtefactBomb:
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
    t_ArtefactTranclucator:
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
    t_ArtDefToEnergy:
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
    t_ArtEnergyPulse:
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
    t_ArtEnergyDef:
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
    t_ArtSplinter:
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
    t_ArtDecelerate:
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
    t_ArtMissileDef:
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
    t_ArtForsage:
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
    t_ArtWeaponToSpeed:
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
    t_ArtGiperJump:
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
    t_ArtBlackHole:
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
    t_ArtDefToArms1:
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
    t_ArtDefToArms2:
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
    t_ArtArtefactor:
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
    t_ArtBio:
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
    t_ArtPDTurret:
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
    t_ArtFastRacks:
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
{ @end $74CB68 }

{ @routine $74D590 TArtefact_GetBitmapResourceName }
function TArtefact.GetBitmapResourceName: WideString;
begin
  if Self is TArtefactCustom then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '_'
  else if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)] + '_';
end;
{ @end $74D590 }

{ @routine $74D698 TArtefact_GetDisplayName }
function TArtefact.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Name');
end;
{ @end $74D698 }

{ @routine $74D758 TArtefact_GetInfoText }
function TArtefact.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  if (ConfigBlockName <> '') and (LanguageDataConfig.GetBlock('Artefacts').CountBlocks(ConfigBlockName) > 0) then
    Result := LocalizedColorText('Artefacts.' + ConfigBlockName + '.Text') + GetBonusDescription(ColorTag) + GetConditionText(True) + GetBoostStatusText
  else
    Result := LocalizedColorText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Text') + GetBonusDescription(ColorTag) + GetConditionText(True) + GetBoostStatusText;
end;
{ @end $74D758 }

{ @routine $74D910 TArtefact_GetDescriptionText }
function TArtefact.GetDescriptionText: WideString;
begin
  Result := LocalizedColorText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Description');
end;
{ @end $74D910 }

{ @routine $74D9C0 TArtefact_GetOnUseCodeText }
function TArtefact.GetOnUseCodeText: WideString;
var Block: TBlockParEC;
begin
  Result := '';
  if ItemType in [t_Artefact..t_Artefact2] then
    Block := LanguageDataConfig.GetBlock('Artefacts').GetBlock('CustomArtefacts').GetBlock(ConfigBlockName).FindBlock('OnUseCode')
  else Block := LanguageDataConfig.GetBlock('Artefacts').GetBlock(ItemTypeNames[Ord(ItemType)]).FindBlock('OnUseCode');
  if Block <> nil then Result := Block.ConcatenateValues;
end;
{ @end $74D9C0 }

{ @routine $74DAB4 TArtefact_GetActionCode }
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
  if ItemType in [t_Artefact..t_Artefact2] then
    Config := LanguageDataConfig.GetBlock('Artefacts').GetBlock('CustomArtefacts').GetBlock(ConfigBlockName)
  else Config := LanguageDataConfig.GetBlock('Artefacts').GetBlock(ItemTypeNames[Ord(ItemType)]);
  if Config <> nil then
  begin
    if ItemType in [t_Artefact..t_Artefact2] then
      ActionCode := GetCachedActionCode(ArtefactScriptCache, ConfigBlockName, Config)
    else ActionCode := GetCachedActionCode(ArtefactKindScriptCache, ItemTypeNames[Ord(ItemType)], Config);
    Result := ActionCode;
  end;
end;
{ @end $74DAB4 }

{ @routine $74DBDC TArtefact_GetEffectiveType }
function TArtefact.GetEffectiveType: TItemType;
begin
  if (ItemType in [t_Artefact, t_Artefact2]) and TArtefactCustom(Self).SharedEffect then
    Result := TArtefactCustom(Self).CountsAsItemType
  else Result := ItemType;
end;
{ @end $74DBDC }

{ @routine $74DC18 TArtefactTransmitter_InitTransmitter }
procedure TArtefactTransmitter.InitTransmitter(Owner: Byte);
begin
  Init(Owner, t_ArtefactTransmitter);
  Power := RoundAndTruncateToTens(SeededRandomIntRange(
    MinTransmitterPower, AverageTransmitterPower, Id * 317321));
end;
{ @end $74DC18 }

{ @routine $74DC70 TArtefactTransmitter_SaveToBuffer }
procedure TArtefactTransmitter.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Power);
end;
{ @end $74DC70 }

{ @routine $74DC9C TArtefactTransmitter_LoadFromBuffer }
procedure TArtefactTransmitter.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Power := Buffer.GetInt32;
end;
{ @end $74DC9C }

{ @routine $74DCCC TArtefactTransmitter_SaveToBlock }
procedure TArtefactTransmitter.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(Power)); // Decoded: 'Power'
end;
{ @end $74DCCC }

{ @routine $74DD74 TArtefactTransmitter_LoadFromBlock }
procedure TArtefactTransmitter.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Power := StrToInt(Block.GetParam(DecodeTextW('Prouwseor'))); // Decoded: 'Power'
end;
{ @end $74DD74 }

{ @routine $74DE18 TArtefactTransmitter_GetInfoText }
function TArtefactTransmitter.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  DisplayPower: Integer;
begin
  Result := LocalizedColorText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Text') +
    GetConditionText(True) + GetBoostStatusText;
  if Power < 0 then DisplayPower := 0
  else DisplayPower := Power;
  ReplaceTextToken(Result, '<Power>', IntToStr(DisplayPower), ColorTag);
end;
{ @end $74DE18 }

{ @routine $74DF68 TArtefactTranclucator_Destroy }
destructor TArtefactTranclucator.Destroy;
begin
  if Ship <> nil then begin
    TObject(Ship).Free;
    Ship := nil;
  end;
  inherited Destroy;
end;
{ @end $74DF68 }

{ @routine $74DFB8 TArtefactTranclucator_InitTranclucator }
procedure TArtefactTranclucator.InitTranclucator(Owner: Byte; OwnerShip: Pointer; ExistingShip: Pointer);
var Companion: TTranclucator; I: Integer; Item: TItem;
begin
  Init(Owner, t_ArtefactTranclucator);
  Ship := ExistingShip;
  if Ship = nil then
  begin
    Ship := TTranclucator.Create;
    Companion := TObject(Ship) as TTranclucator;
    Companion.Init(TObject(OwnerShip) as TShip, Owner, False);
    if OwnerShip <> nil then
    begin
      Companion.CurrentStar.Ships.Delete(Companion.CurrentStar.Ships.IndexOf(Companion));
      Companion.CurrentStar := nil;
    end;
  end;
  Companion := TObject(Ship) as TTranclucator;
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
{ @end $74DFB8 }

{ @routine $74E14C TArtefactTranclucator_SaveToBuffer }
procedure TArtefactTranclucator.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  (TObject(Ship) as TTranclucator).SaveToBuffer(Buffer);
end;
{ @end $74E14C }

{ @routine $74E180 TArtefactTranclucator_LoadFromBuffer }
procedure TArtefactTranclucator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Ship := TTranclucator.Create;
  (TObject(Ship) as TTranclucator).LoadFromBuffer(Buffer, Galaxy);
end;
{ @end $74E180 }

{ @routine $74E1D4 TArtefactTranclucator_Clone }
function TArtefactTranclucator.Clone: TItem;
begin
  Result := nil;
end;
{ @end $74E1D4 }

{ @routine $74E1EC TArtefactTranclucator_SaveToBlock }
procedure TArtefactTranclucator.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  TTranclucator(Ship).SaveToBlock(Block.AddBlockByPath(DecodeTextW('S5heifphI4d') + IntToStr(Cardinal(TTranclucator(Ship).Id)))); // Decoded: 'ShipId'
end;
{ @end $74E1EC }

{ @routine $74E2B4 TArtefactTranclucator_LoadFromBlock }
procedure TArtefactTranclucator.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TTranclucator(Ship).LoadFromBlock(Block.GetBlockByPath(DecodeTextW('S5heifphI4d') + IntToStr(Cardinal(TTranclucator(Ship).Id)))); // Decoded: 'ShipId'
end;
{ @end $74E2B4 }

{ @routine $74E37C TArtefactTranclucator_ResolveLoadedReferences }
procedure TArtefactTranclucator.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  (TObject(Ship) as TTranclucator).ResolveLoadedReferences(Galaxy);
end;
{ @end $74E37C }

{ @routine $74E3B0 TArtefactTranclucator_ClearReferences }
procedure TArtefactTranclucator.ClearReferences;
begin
  inherited ClearReferences;
  (TObject(Ship) as TTranclucator).ClearObjectReferences;
end;
{ @end $74E3B0 }

{ @routine $74E3D8 TArtefactTranclucator_GetDisplayName }
function TArtefactTranclucator.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if Ship <> nil then begin
    if Length((TObject(Ship) as TShip).Name) > 0 then Result := (TObject(Ship) as TShip).Name
    else Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Name') + '-' + IntToStr(Int64(Cardinal((TObject(Ship) as TShip).Id)));
  end else Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Name');
end;
{ @end $74E3D8 }

{ @routine $74E578 TArtefactCustom_LoadConfig }
procedure TArtefactCustom.LoadConfig(ApplyConfiguredWeight: Boolean);
var Block: TBlockParEC; Name: WideString; Kind: TItemType;
begin
  Block := LanguageDataConfig.GetBlockByPath('Artefacts.CustomArtefacts.' + ConfigBlockName);
  if (Block.CountParams('NoWear') > 0) and (ExtractDigitsToIntW(Block.GetParam('NoWear')) <> 0) then ItemType := t_Artefact2
  else ItemType := t_Artefact;
  if ApplyConfiguredWeight then
    if Block.CountParams('Size') <= 0 then Weight := 10
    else Weight := ExtractDigitsToIntW(Block.GetParam('Size'));
  CountsAsItemType := t_Artefact;
  SharedUse := False;
  SharedEffect := False;
  if Block.CountParams('CountsAs') > 0 then begin
    Name := Block.GetParam('CountsAs');
    for Kind := Low(TItemType) to High(TItemType) do
      if (Kind in [t_Artefact..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtDefToArms1..t_ArtFastRacks]) and
         not (Kind in [t_Artefact..t_Artefact2]) and (ItemTypeNames[Ord(Kind)] = Name) then begin
        CountsAsItemType := Kind;
        Break;
      end;
    if CountsAsItemType <> t_Artefact then begin
      if Block.CountParams('SharedUse') > 0 then SharedUse := ExtractDigitsToIntW(Block.GetParam('SharedUse')) <> 0;
      if Block.CountParams('SharedEffect') > 0 then SharedEffect := ExtractDigitsToIntW(Block.GetParam('SharedEffect')) <> 0;
    end;
  end;
end;
{ @end $74E578 }

{ @routine $74E814 TArtefactCustom_SaveToBuffer }
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
{ @end $74E814 }

{ @routine $74E8F8 TArtefactCustom_LoadFromBuffer }
procedure TArtefactCustom.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
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
{ @end $74E8F8 }

{ @routine $74EA08 TArtefactCustom_SaveToBlock }
procedure TArtefactCustom.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(1)), IntToStr(Data[1]));
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(2)), IntToStr(Data[2]));
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(3)), IntToStr(Data[3]));
end;
{ @end $74EA08 }

{ @routine $74EBF8 TArtefactCustom_LoadFromBlock }
procedure TArtefactCustom.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Data[1] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(1))));
  Data[2] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(2))));
  Data[3] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(3))));
end;
{ @end $74EBF8 }

{ @routine $74EDB8 TArtefactCustom_GetInfoText }
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
{ @end $74EDB8 }

{ @routine $74F058 TArtefactCustom_GetDisplayName }
function TArtefactCustom.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Name');
end;
{ @end $74F058 }

{ @routine $74F12C TArtefactCustom_GetDescriptionText }
function TArtefactCustom.GetDescriptionText: WideString;
begin
  Result := LocalizedColorText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Description');
end;
{ @end $74F12C }

{ @routine $74F1F0 TArtefact_GetBoostStatusText }
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
  if Ship.CanBoostArtefact(Ord(GetEffectiveType), nil, True) then
  begin
    if EquippedFlag <> 0 then
      Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtGettingBoost')
    else
      Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtCanGetBoost');
  end
  else
    for I := 0 to Ship.Inventory.Count - 1 do
      if Ship.CanBoostArtefact(Ord(GetEffectiveType), TEquipment(Ship.Inventory[I]), True) then
      begin
        Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtCanGetBoost');
        Break;
      end;
end;
{ @end $74F1F0 }

{ @routine $74F41C CreateItemByType }
function CreateItemByType(ItemType: TItemType): TItem;
begin
  Result := nil;
  case ItemType of
    t_Hull: Result := THull.Create;
    t_FuelTanks: Result := TFuelTanks.Create;
    t_Engine: Result := TEngine.Create;
    t_Radar: Result := TRadar.Create;
    t_Scaner: Result := TScaner.Create;
    t_RepairRobot: Result := TRepairRobot.Create;
    t_CargoHook: Result := TCargoHook.Create;
    t_DefGenerator: Result := TDefGenerator.Create;
    t_Protoplasm: Result := TProtoplasm.Create;
    t_UselessItem: Result := TUselessItem.Create;
    t_MicroModule: Result := TMicroModule.Create;
    t_Cistern: Result := TCistern.Create;
    t_Satellite: Result := TSatellite.Create;
    t_TreasureMap: Result := TTreasureMap.Create;
    t_UselessCountableItem: Result := TCountableItem.Create;
    t_ArtefactTransmitter: Result := TArtefactTransmitter.Create;
    t_ArtefactTranclucator: Result := TArtefactTranclucator.Create;
    t_Artefact, t_Artefact2: Result := TArtefactCustom.Create;
    t_CustomWeapon: Result := TCustomWeapon.Create;
  else
    if ItemType in [t_Weapon1..t_Weapon18] then Result := TWeapon.Create
    else if ItemType in [t_Food..t_Narcotics] then Result := TGoods.Create
    else if ItemType in [t_ArtefactHull..t_ArtFastRacks] then Result := TArtefact.Create
    else Exception.Create('Error CreateItemByType'); // Native allocates without raising.
  end;
end;
{ @end $74F41C }

{ @routine $74F6D4 CreateDefaultItemByType }
function CreateDefaultItemByType(ItemType: TItemType): TItem;
var Item: TItem;
begin
  if ItemType in [t_ArtefactHull..t_ArtFastRacks] then Result := CreateConfiguredArtefactByItemType(ItemType, 6)
  else if ItemType = t_Hull then begin
    Item := CreateItemByType(ItemType);
    THull(Item).Init(250, 1, RaceToOwner(GetPlayer.PilotRace), 0, -1, False);
    Result := Item;
  end else if ItemType = t_CustomWeapon then Result := nil
  else if ItemType in [t_Hull..t_CustomWeapon] then Result := CreateGeneratedEquipment(ItemType, 20, 1, 6)
  else begin
    Item := CreateItemByType(ItemType);
    Result := Item;
    if Item <> nil then
      case ItemType of
        t_Protoplasm: TProtoplasm(Item).Init(10, 0);
        t_UselessItem: TUselessItem(Item).Init(DecodeTextW('EdxYahmrpelwefAjsktleoruoeiddc'), dsBlazer, 0, False); // Decoded: 'ExampleAsteroid'
        t_MicroModule: TMicroModule(Item).Init(1);
        t_Cistern: TCistern(Item).Init(10, 10, 6);
        t_Satellite: TSatellite(Item).InitGenerated(1, GetPlayer.OwnerId, NextRandomIntRange(1, 10000, Galaxy.RandomState));
      else
        if ItemType in [t_Food..t_Narcotics] then TGoods(Item).Init(ItemType, 10)
        else begin Item.Free; Result := nil; end;
      end;
  end;
end;
{ @end $74F6D4 }

{ @routine $74F8DC CreateGeneratedEquipment }
function CreateGeneratedEquipment(ItemType: TItemType; Weight, Level: Integer; Owner: Byte): TEquipment;
var Item: TItem; MinimumLevel: Integer; ActualLevel: Byte;
begin
  MinimumLevel := Max(1, Level);
  Result := nil;
  if ItemType in [t_Hull..t_CustomWeapon] then
  begin
    Item := CreateItemByType(ItemType);
    Result := TEquipment(Item);
    if Item <> nil then
    begin
      ActualLevel := Max(0, Min(MinimumLevel, 8));
      case ItemType of
        t_Hull: THull(Item).Init(Weight, ActualLevel, Owner, 0, -1, False);
        t_FuelTanks: TFuelTanks(Item).Init(Weight, ActualLevel, Owner);
        t_Engine: TEngine(Item).Init(Weight, ActualLevel, Owner);
        t_Radar: TRadar(Item).Init(Weight, ActualLevel, Owner);
        t_Scaner: TScaner(Item).Init(Weight, ActualLevel, Owner);
        t_RepairRobot: TRepairRobot(Item).Init(Weight, ActualLevel, Owner);
        t_CargoHook: TCargoHook(Item).Init(Weight, ActualLevel, Owner);
        t_DefGenerator: TDefGenerator(Item).Init(Weight, ActualLevel, Owner);
      else
        if ItemType = t_CustomWeapon then
          Exception.Create('Error CreateEq - cant create custom weapons') // Native does not raise or free Item.
        else if ItemType in [t_Weapon1..t_CustomWeapon] then TWeapon(Item).Init(ItemType, Weight, ActualLevel, Owner)
        else begin Item.Free; Result := nil; end;
      end;
    end;
  end;
end;
{ @end $74F8DC }

{ @routine $74FAD4 CreateGeneratedWeapon }
function CreateGeneratedWeapon(Info: PWeaponInfo; Weight, Level: Integer; Owner: Byte): TWeapon;
begin
  Result := TWeapon(CreateItemByType(Info.ItemType));
  if Info.ItemType in [t_Weapon1..t_Weapon18] then Result.Init(Info.ItemType, Weight, Level, Owner)
  else TCustomWeapon(Result).InitCustom(Info, False, Weight, Level, Owner);
end;
{ @end $74FAD4 }

{ @routine $74FB38 GetItemTypeBitmapPath }
function GetItemTypeBitmapPath(ItemType: TItemType): WideString;
begin
  Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)];
end;
{ @end $74FB38 }

{ @routine $74FBBC GetStackableItemTypeName }
function GetStackableItemTypeName(ItemType: TItemType): WideString;
begin
  Result := '';
  if ItemType in [t_Food..t_Narcotics] then Result := GoodsMarket[Ord(ItemType)].DisplayName
  else if ItemType = t_Protoplasm then Result := LocalizedText('Items.Nod.Name');
end;
{ @end $74FBBC }

{ @routine $74FC30 GetStackableItemName }
function GetStackableItemName(Item: TItem): WideString;
begin
  if Item.ItemType = t_UselessCountableItem then
    Result := LocalizedText('Items.CustomCountables.' + (Item as TCountableItem).ConfigBlockName + '.Name')
  else Result := GetStackableItemTypeName(Item.ItemType);
end;
{ @end $74FC30 }

{ @routine $74FD00 MigrateSavedItemType }
function MigrateSavedItemType(ItemType: Byte): TItemType;
begin
  if (LoadedSaveVersion < 164) and (TItemType(ItemType) > t_Artefact) then Inc(ItemType);
  if (LoadedSaveVersion < 78) and (TItemType(ItemType) > t_ArtBio) then Inc(ItemType);
  if (LoadedSaveVersion < 131) and (TItemType(ItemType) > t_ArtPDTurret) then Inc(ItemType);
  if (LoadedSaveVersion < 78) and (TItemType(ItemType) > t_Weapon15) then Inc(ItemType, 3);
  if (LoadedSaveVersion < 127) and (TItemType(ItemType) > t_Weapon18) then Inc(ItemType);
  Result := TItemType(ItemType);
end;
{ @end $74FD00 }

end.
