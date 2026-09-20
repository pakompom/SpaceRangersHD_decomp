unit aItem;
// Unit bracket (inferred): .text 0x007ED600..0x0080CF4C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Struct, SE_Space, Windows, aEFilm, aGalaxy, aGalaxyStruct;

const
  // AssignedSlotData is also copied into TabWeapon.SlotData. The arcade group
  // toggle XORs bit 7 at $540EB4; primary/secondary fire tests it at $502C0D/$502EE4.
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
    function GetShortName: WideString; virtual; // @addr 0x7EF144 @slot 0x1C @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; virtual; // @addr 0x7EF15C @slot 0x20 @ida "void __userpurge $name(TItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); virtual; // @addr 0x7EE7B4 @slot 0x00 @calls "0x7F0B04"
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); virtual; // @addr 0x7EE878 @slot 0x04 @calls "0x7F0B2F" @note "Object-reference fields in descendants hold saved IDs until ResolveLoadedReferences; updates Galaxy.NextItemId."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); virtual; // @addr 0x7EEF04 @slot 0x08 @calls "0x7F0B3F"
    procedure ClearReferences; virtual; // @addr 0x7EEF14 @slot 0x0C
    procedure SaveToBlock(Block: TBlockParEC); virtual; // @addr 0x7EE984 @slot 0x10
    procedure LoadFromBlock(Block: TBlockParEC); virtual; // @addr 0x7EEC08 @slot 0x14

    constructor Create; // @addr 0x7EE68C @ida "TItem *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7EE6FC @ida "void __usercall $name(TItem *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function GetGraphObject: TObjectSE; // @addr 0x7EF260 @note "Lazily creates and initializes the retained scene container; returns a borrowed reference. Appearance depends on item kind, size, faction, and drop flags."
    procedure ReleaseGraphObject; // @addr 0x7F0060
    function GetSmallInfoText: WideString; // @addr 0x7EEF20 @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Generic Items.SmallInfo label used outside radar range."
    function CalculateResaleValue(TradingSkill: Byte): Integer; // @addr 0x7EEF64 @note "Applies the trading-skill percentage to Cost minus repair cost; equipment has a minimum value of 1. Goods use Cost directly."
    function GetConditionAdjustedCost: Integer; // @addr 0x7EF050 @note "Equipment deducts repair cost, with a minimum result of 1; goods return Cost unchanged."

    function GetCategoryConfigName: WideString; // @addr 0x7EF0B8 @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Groups weapon types under Weapon and built-in artefacts under Artefact; otherwise returns the item-type configuration name."
    function GetOwnerConfigName: WideString; // @addr 0x7F0160 @ida "void __usercall $name(TItem *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Manufacturer/faction resource key, including custom factions and Dominator series."
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

    function GetDisplayName: WideString; override; // @addr 0x7F28A4 @slot 0x18 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetShortName: WideString; override; // @addr 0x7F2B74 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7F0368
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7F062C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7F0B6C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7F1064

    constructor Create; // @addr 0x7F028C @ida "TEquipment *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7F02DC @ida "void __usercall $name(TEquipment *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Equip; // @addr 0x7F12E8
    procedure Unequip; virtual; // @addr 0x7F1360 @slot 0x2C
    procedure Repair; virtual; // @addr 0x7F13D8 @slot 0x30
    function NeedsRepair: Boolean; // @addr 0x7F13F8 @note "Tests hull damage or supported equipment below 90 percent condition."
    function Clone: TItem; virtual; // @addr 0x7F0AC8 @slot 0x48 @note "Allocates a new item ID and resolves references in the current galaxy; changes LoadedSaveVersion."

    function GetLevel: Integer; // @addr 0x7F256C @note "Returns 0 for unsupported item types."
    function CalculateRepairCost: Integer; // @addr 0x7F147C @note "Undiscounted cost; hulls use HullPoints, other supported equipment uses ConditionPercent and BrokenFlag."
    function HasMicroModule: Boolean; // @addr 0x7F2CFC
    function GetStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x7F3354
    function GetFragilityFactor(DamageFlags: TDamageFlagSet): Single; virtual; // @addr 0x7F3194 @slot 0x40 @ida "float __usercall $name@<st0>(TEquipment *Self@<eax>, unsigned int DamageFlags@<edx>);"
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); virtual; // @addr 0x7F330C @slot 0x44
    function GetMicroModuleQuotedName: WideString; // @addr 0x7F2D18 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetSpecialModuleName: WideString; // @addr 0x7F2DBC @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"

    function GetDescriptionText: WideString; override; // @addr 0x7F2728 @slot 0x24 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x7F2F00 @slot 0x28 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure Improve(Kind: TImprovementKind); virtual; // @addr 0x7F2E00 @slot 0x34 @calls "0x633922 0x633938" @note "Base is a no-op. Overrides change statistics and Cost without checking CanImprove or charging money; ikAny selects one of the three strengths."
    function CalculateImprovementCost(Kind: TImprovementKind): Integer; virtual; // @addr 0x7F2E10 @slot 0x38 @calls "0x7F55A5 0x7F79F1 0x7F8AEB 0x7F9EC2 0x7FACB8 0x7FBB44 0x7FCF41 0x7FE418 0x8004AA" @note "Only ikMinor, ikMedium and ikMajor are valid: Cost times 0.3, 0.6 or 1.2, rounded then truncated to a multiple of 10, before service discounts."
    function HasStandardStats: Boolean; virtual; // @addr 0x7F2EEC @slot 0x3C @calls "0x633899" @note "Tests expected generated statistics after accounting for installed bonuses; this is not a stored upgraded flag. The base implementation returns True."
    procedure ImproveAtScientificBase; // @addr 0x7F2C98 @note "Selects strength and stat emphasis from Id, then calls Improve. Charging and eligibility checks belong to the caller."
    function CanImprove: Boolean; // @addr 0x7F41B8 @note "Requires HasStandardStats and no special module that blocks the special slot; does not check technology access."
    function GetDescriptionStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x7F34FC @note "Aggregate used by the bonus description, with SeparatedNumbers effects handled separately."
    function GetBonusDescription(ColorTag: WideString): WideString; // @addr 0x7F3AAC @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 *ColorTag@<edx>, unsigned __int16 **Result@<ecx>);"
    function GetConditionText(PrefixNewLine: Boolean): WideString; // @addr 0x7F170C @ida "void __usercall $name(TEquipment *Self@<eax>, bool PrefixNewLine@<dl>, unsigned __int16 **Result@<ecx>);" @note "Includes player technology restrictions as well as wear and breakage."
    function GetBrokenInBattleText: WideString; // @addr 0x7F1E24 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBrokenInUseText: WideString; // @addr 0x7F208C @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBrokenByForceText: WideString; // @addr 0x7F22EC @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetLevelLetter: WideString; // @addr 0x7F26E4 @ida "void __usercall $name(TEquipment *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "A through H for levels 1 through 8; empty for unsupported levels."
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

    function GetDisplayName: WideString; override; // @addr 0x7F5640 @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetShortName: WideString; override; // @addr 0x7F5C20 @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7F5C8C @ida "void __userpurge $name(THull *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7F43C8
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7F45AC
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x7F485C
    procedure ClearReferences; override; // @addr 0x7F4898
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7F48B4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7F4BF8

    procedure Init(Capacity: Integer; Level, Owner, HullType: Byte; Series: Integer; PirateBuilt: Boolean); // @addr 0x7F4200
    procedure Repair; override; // @addr 0x7F5398
    function GetSlotCount(Kind: TShipSlotKind): Integer; // @addr 0x7F6B4C
    function GetFragilityFactor(DamageFlags: TDamageFlagSet): Single; override; // @addr 0x7F7038 @ida "float __usercall $name@<st0>(THull *Self@<eax>, unsigned int DamageFlags@<edx>);" @note "Zero flags return the average of energy, splinter and missile factors."
    function CalculateMass: Integer; // @addr 0x7F6FB4 @note "Round(capacity * (0.6 + 0.2 * (clamped level - 1) / 7)); excludes carried cargo and ship mass modifiers."
    function CalculateGeneratedArmor: ShortInt; // @addr 0x7F4F10

    function GetBitmapResourceName: WideString; override; // @addr 0x7F6654 @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7F53B8
    function HasStandardStats: Boolean; override; // @addr 0x7F55C8
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7F5F7C
    procedure ApplySeriesSizeAndCost; // @addr 0x7F42C8 @note "Applies the current hull series, resets HullPoints to capacity, and bounds Cost."
    function CalculateGeneratedCost: Integer; // @addr 0x7F52FC @note "If cost generation overflows negative, repeatedly halves capacity and resets HullPoints before retrying."
    function GetSeriesName: WideString; // @addr 0x7F5ACC @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetSpecialKindGraph: WideString; // @addr 0x7F6AE4 @ida "void __usercall $name(THull *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Returns the special module KindGraph, or the literal 1 as fallback."
    function EstimateCapacityWithoutBonuses: Integer; // @addr 0x7F72B8 @note "Reverses module and series size percentages with rounding; extra-special multiplicities are not used."
  end;

  TFuelTanks = class(TEquipment) // @size 0x6C
  public
    TechLevel: Byte; // @offset 0x60
    Fuel: Integer; // @offset 0x64
    Capacity: Byte; // @offset 0x68

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7F7B40 @ida "void __userpurge $name(TFuelTanks *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7F7400
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7F7448
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7F7498
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7F762C

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x7F7390
    function CalculateGeneratedCapacity: Byte; // @addr 0x7F77B8
    function CalculateGeneratedCost: Integer; // @addr 0x7F78A0

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7F78CC
    function HasStandardStats: Boolean; override; // @addr 0x7F7A08
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7F7DB0
  end;

  TEngine = class(TEquipment) // @size 0x6C
  public
    TechLevel: Byte; // @offset 0x60
    Speed: Integer; // @offset 0x64
    JumpRange: ShortInt; // @offset 0x68
    OutputPercent: Byte; // @offset 0x69

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7F8BEC @ida "void __userpurge $name(TEngine *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7F8200
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7F8254
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7F82D4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7F8460

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x7F8188
    function CalculateGeneratedSpeed: Integer; // @addr 0x7F85E4
    function CalculateGeneratedJumpRange: ShortInt; // @addr 0x7F860C
    function CalculateGeneratedCost: Integer; // @addr 0x7F86C4

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7F86F0
    function HasStandardStats: Boolean; override; // @addr 0x7F8B0C
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7F8DF0
  end;

  TRadar = class(TEquipment) // @size 0x68
  public
    TechLevel: Byte; // @offset 0x60
    Range: Integer; // @offset 0x64

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7F9F4C @ida "void __userpurge $name(TRadar *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7F9990
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7F99C8
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7F9A08
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7F9B30

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x7F992C
    function CalculateGeneratedRange: Integer; // @addr 0x7F9C54
    function CalculateGeneratedCost: Integer; // @addr 0x7F9D10

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7F9D3C
    function HasStandardStats: Boolean; override; // @addr 0x7F9ED8
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7FA14C
  end;

  TScaner = class(TEquipment) // @size 0x64
  public
    TechLevel: Byte; // @offset 0x60
    ScanPower: ShortInt; // @offset 0x61

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7FAD48 @ida "void __userpurge $name(TScaner *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7FA76C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7FA7A4
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7FA810
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7FA934

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x7FA708
    function CalculateGeneratedScanPower: Integer; // @addr 0x7FAA50
    function CalculateGeneratedCost: Integer; // @addr 0x7FAB14

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7FAB40
    function HasStandardStats: Boolean; override; // @addr 0x7FACD0
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7FAF4C
  end;

  TRepairRobot = class(TEquipment) // @size 0x64
  public
    TechLevel: Byte; // @offset 0x60
    RepairPoints: Byte; // @offset 0x61

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7FBBD4 @ida "void __userpurge $name(TRepairRobot *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7FB56C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7FB5A4
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7FB6A0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7FB7C8

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x7FB508
    function CalculateGeneratedRepairPoints: Byte; // @addr 0x7FB8E8
    function CalculateGeneratedCost: Integer; // @addr 0x7FB9A0

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7FB9CC
    function HasStandardStats: Boolean; override; // @addr 0x7FBB5C
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7FBDF8
  end;

  TCargoHook = class(TEquipment) // @size 0x74
  public
    TechLevel: Byte; // @offset 0x60
    PickupPower: Integer; // @offset 0x64
    Range: Integer; // @offset 0x68
    MinPullSpeed: Single; // @offset 0x6C
    MaxPullSpeed: Single; // @offset 0x70

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7FD040 @ida "void __userpurge $name(TCargoHook *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7FC4A8
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7FC50C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7FC57C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7FC800

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x7FC418
    function CalculateGeneratedPickupPower: Integer; // @addr 0x7FCA30
    function CalculateGeneratedRange: Integer; // @addr 0x7FCA58
    function CalculateGeneratedMinPullSpeed: Single; // @addr 0x7FCA80
    function CalculateGeneratedMaxPullSpeed: Single; // @addr 0x7FCAA8
    function CalculateGeneratedCost: Integer; // @addr 0x7FCB64

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7FCB90
    function HasStandardStats: Boolean; override; // @addr 0x7FCF64
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7FD258
    constructor Create; // @addr 0x7FC3D4 @ida "TCargoHook *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
  end;

  TDefGenerator = class(TEquipment) // @size 0x68
  public
    TechLevel: Byte; // @offset 0x60
    DamageFactor: Single; // @offset 0x64

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x7FE4C4 @ida "void __userpurge $name(TDefGenerator *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7FDF44
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7FDF7C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7FDFBC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7FE0F0

    procedure Init(Weight: Integer; Level, Owner: Byte); // @addr 0x7FDED8
    function CalculateGeneratedDamageFactor: Single; // @addr 0x7FE1F8

    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7FE338
    function HasStandardStats: Boolean; override; // @addr 0x7FE42C
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x7FE6EC
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

    function GetDisplayName: WideString; override; // @addr 0x80050C @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetShortName: WideString; override; // @addr 0x80061C @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x8006D8 @ida "void __userpurge $name(TWeapon *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7FEEC0
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7FF090
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x7FF9CC
    procedure ClearReferences; override; // @addr 0x7FFA94
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7FF2C0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7FF640

    procedure Init(ItemType: TItemType; Weight: Integer; Level, Owner: Byte); // @addr 0x7FED1C
    procedure Unequip; override; // @addr 0x7FFAB8
    function GetConfigName: WideString; virtual; // @addr 0x8022F0 @slot 0x4C @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetWeaponInfo: PWeaponInfo; virtual; // @addr 0x8022A4 @slot 0x50 @calls "0x7599A7 0x801F73 0x7FFBC1 0x7FFD93"
    function CalculateGeneratedAmmoCapacity: Integer; // @addr 0x7FFAD4
    function CalculateGeneratedMinDamage: Integer; // @addr 0x7FFAF4
    function CalculateGeneratedMaxDamage: Integer; // @addr 0x7FFB34
    function CalculateGeneratedRange: Integer; // @addr 0x7FFB74
    function GetAttackCount: Integer; // @addr 0x8021D4
    function GetShotCount: Integer; // @addr 0x8020E4
    function GetShotDelayFactor: Double; // @addr 0x801BB8
    function NeedsAmmo: Boolean; // @addr 0x801F28
    function CalculateAmmoRefillCost: Integer; // @addr 0x801F60
    function GetShotPalette: Integer; // @addr 0x801FD4
    function GetDamageFlags: TDamageFlagSet; // @addr 0x80202C @ida "unsigned int __usercall $name@<eax>(TWeapon *Self@<eax>);" @note "Combines the weapon template and installed ordinary, special and extra-special module flags."

    function GetDescriptionText: WideString; override; // @addr 0x801B0C @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x801CC8 @ida "void __usercall $name(TWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure Improve(Kind: TImprovementKind); override; // @addr 0x7FFD5C
    function HasStandardStats: Boolean; override; // @addr 0x8004D0
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); override; // @addr 0x800988
    destructor Destroy; override; // @addr 0x7FECE8 @ida "void __usercall $name(TWeapon *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function CalculateStandardMaxDamage: Integer; // @addr 0x7FFBA8 @note "Generated maximum plus ordinary and special module damage bonuses; used by HasStandardStats."
    function CalculateStandardRange: Integer; // @addr 0x7FFC38 @note "Generated range plus ordinary and special module range bonuses; used by HasStandardStats."
  end;

  // Native class-name spelling.
  TCustomWeapon = class(TWeapon) // @size 0x84
  public
    CustomInfo: PWeaponInfo; // @offset 0x80

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x7FF060
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x7FF24C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x7FF5A4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x7FF918

    procedure InitCustom(Info: PWeaponInfo; Equipped: Boolean; Weight: Integer; Level, Owner: Byte); // @addr 0x7FEDE0
    function GetWeaponInfo: PWeaponInfo; override; // @addr 0x8022D4
    function GetConfigName: WideString; override; // @addr 0x802350 @ida "void __usercall $name(TCustomWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"

    function GetBitmapResourceName: WideString; override; // @addr 0x801DF0 @ida "void __usercall $name(TCustomWeapon *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TGoods = class(TItem) // @size 0x40
  public
    Quantity: Integer; // @offset 0x38
    NaturalFlag: Boolean; // @offset 0x3C

    function GetDisplayName: WideString; override; // @addr 0x802444 @slot 0x18 @ida "void __usercall $name(TGoods *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x802494 @ida "void __userpurge $name(TGoods *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x8023CC
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x802404

    procedure Init(ItemType: TItemType; Quantity: Integer); // @addr 0x802374

    function GetDescriptionText: WideString; override; // @addr 0x80258C @slot 0x24 @ida "void __usercall $name(TGoods *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x802634 @slot 0x28 @ida "void __usercall $name(TGoods *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TCountableItem = class(TEquipment) // @size 0x68
  public
    StackCount: Integer; // @offset 0x60
    DropFlag: Byte; // @offset 0x64

    function GetDisplayName: WideString; override; // @addr 0x8027E0 @ida "void __usercall $name(TCountableItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x8028AC @ida "void __userpurge $name(TCountableItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x8026BC
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x8026F4

    procedure Init(ConfigName: WideString; Count: Integer; DropFlag: Byte); // @addr 0x802734
    function GetUnitSize: Integer; // @addr 0x802C40 @note "Defaults to 1 when UnitSize is not configured."
    function CanMerge(Other: TObject): Boolean; // @addr 0x802FFC
    function Merge(Other: TObject): Boolean; // @addr 0x803078 @note "Leaves Other unchanged."

    function GetDescriptionText: WideString; override; // @addr 0x8029F0 @ida "void __usercall $name(TCountableItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x802AAC @ida "void __usercall $name(TCountableItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function Split(Count: Integer): TCountableItem; // @addr 0x802D38 @note "Allocates a new stack and removes up to Count units from Self; preserves the nodes subtype and may create a script wrapper. Self must be nonempty and Count positive."
  end;

  TProtoplasm = class(TCountableItem) // @size 0x68
  public

    function GetDisplayName: WideString; override; // @addr 0x803138 @ida "void __usercall $name(TProtoplasm *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x803244 @ida "void __userpurge $name(TProtoplasm *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure Init(Count: Integer; DropFlag: Byte); // @addr 0x8030D4

    function GetDescriptionText: WideString; override; // @addr 0x803310 @ida "void __usercall $name(TProtoplasm *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x803360 @ida "void __usercall $name(TProtoplasm *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TEquipmentWithActCode = class(TEquipment) // @size 0x68
  public
    ActionCode: Pointer; // @offset 0x60  Borrowed.
    ActCodeInitialized: Boolean; // @offset 0x64
    DisplayAsArtefact: Boolean; // @offset 0x65

    constructor Create; // @addr 0x8034E8 @ida "TEquipmentWithActCode *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x803538 @ida "void __usercall $name(TEquipmentWithActCode *Self@<eax>, __int8 DestroyFlags@<dl>);"
  end;

  TUselessItem = class(TEquipmentWithActCode) // @size 0x78
  public
    CustomText: WideString; // @offset 0x68  Script.UselessItemText.
    Data: array[0..2] of Integer; // @offset 0x6C  Script.UselessItemData uses indexes 1..3.

    function GetDisplayName: WideString; override; // @addr 0x803D28 @ida "void __usercall $name(TUselessItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x803E2C @ida "void __userpurge $name(TUselessItem *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x803AA4
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x803AF8
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x803BF0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x803C80

    constructor Create; // @addr 0x803574 @ida "TUselessItem *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x8035BC @ida "void __usercall $name(TUselessItem *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Init(ConfigName: WideString; Series: TDominatorSeries; Seed: Cardinal; ForceArtefactDisplay: Boolean); // @addr 0x803624
    procedure CheckIfWeDisplayAsArtefact; // @addr 0x804464
    function GetActionCode: Pointer; // @addr 0x80455C

    function GetDescriptionText: WideString; override; // @addr 0x804030 @ida "void __usercall $name(TUselessItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x804124 @ida "void __usercall $name(TUselessItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function IsDominatorRemains: Boolean; // @addr 0x804414 @note "Owner is Dominator and ConfigBlockName starts with Remains_."
    function GetOnUseCodeText: WideString; // @addr 0x8044C4 @ida "void __usercall $name(TUselessItem *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TCistern = class(TEquipment) // @size 0x68
  public
    Fuel: Integer; // @offset 0x60
    Capacity: Byte; // @offset 0x64

    function GetDisplayName: WideString; override; // @addr 0x804914 @ida "void __usercall $name(TCistern *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x80497C @ida "void __userpurge $name(TCistern *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x804674
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x8046AC
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x8046EC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x804804

    procedure Init(Fuel: Integer; Capacity, Owner: Byte); // @addr 0x8045F4

    function GetDescriptionText: WideString; override; // @addr 0x804AB8 @ida "void __usercall $name(TCistern *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x804B10 @ida "void __usercall $name(TCistern *Self@<eax>, unsigned __int16 **Result@<edx>);"
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

    function GetDisplayName: WideString; override; // @addr 0x805738 @calls "0x805BA8 0x805D12" @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x8058C4 @ida "void __userpurge $name(TSatellite *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x80515C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x8051FC
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x8056E0
    procedure ClearReferences; override; // @addr 0x80571C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x805280
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x8054CC

    procedure InitGenerated(TypeId, Owner: Byte; Seed: Cardinal); // @addr 0x804BE0 @note "Clears deployment state."

    function GetDescriptionText: WideString; override; // @addr 0x805E30 @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x805EF0 @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBrokenInUseText: WideString; // @addr 0x805B1C @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetIdleInfoText: WideString; // @addr 0x805C84 @ida "void __usercall $name(TSatellite *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TTreasureMap = class(TEquipment) // @size 0x70
  public
    TargetPlanet: Pointer; // @offset 0x60  Saved as an ID until ResolveLoadedReferences.
    SourceShipName: WideString; // @offset 0x64
    PreviewTablePage1: WideString; // @offset 0x68
    PreviewTablePage2: WideString; // @offset 0x6C

    function GetDisplayName: WideString; override; // @addr 0x8062C4 @ida "void __usercall $name(TTreasureMap *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x806334 @ida "void __userpurge $name(TTreasureMap *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x80613C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x8061B4
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x80626C
    procedure ClearReferences; override; // @addr 0x8062A8

    procedure Init(Planet: Pointer; Victim: Pointer); // @addr 0x805FF0
    function GetTargetPlanetName: WideString; // @addr 0x806624 @ida "void __usercall $name(TTreasureMap *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function BuildPreviewTable(PageIndex: Integer; Planet: Pointer): WideString; // @addr 0x8067B0 @ida "void __userpurge $name(TTreasureMap *Self@<eax>, int PageIndex@<edx>, TPlanet *Planet@<ecx>, unsigned __int16 **Result@<^0>);" @note "PageIndex is 1 or 2; Planet must be assigned."

    function GetDescriptionText: WideString; override; // @addr 0x8064C8 @ida "void __usercall $name(TTreasureMap *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x806528 @ida "void __usercall $name(TTreasureMap *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TMicroModule = class(TEquipment) // @size 0x60
  public

    function GetDisplayName: WideString; override; // @addr 0x8074A0 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x807758 @ida "void __userpurge $name(TMicroModule *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x80743C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x807458

    procedure Init(ModuleIndex: Integer); // @addr 0x8072F8 @note "ModuleIndex is zero-based and must identify an existing template."
    function GetPlainName: WideString; // @addr 0x807608 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);"

    function GetDescriptionText: WideString; override; // @addr 0x807BC0 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x807BD8 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetHighlightedName: WideString; // @addr 0x809260 @ida "void __usercall $name(TMicroModule *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Template name wrapped in the standard yellow highlight color."
    function CalculateNodeExchangeValue(LowPriorityOfferCost, MediumPriorityOfferCost: Integer): Integer; // @addr 0x808EF0 @note "Node refund at the current ranger center, using priority and docked station ID. Priorities 31..69 are capped by half LowPriorityOfferCost; 70..100 by half MediumPriorityOfferCost. Minimum 5 nodes."
    function CanInstallOn(Item: TEquipment): Boolean; // @addr 0x8092C0 @note "Uses this micromodule item's template and checks slot blockers and equipment compatibility."
  end;

  TArtefact = class(TEquipmentWithActCode) // @size 0x68
  public

    function GetDisplayName: WideString; override; // @addr 0x80A868 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x80A928 @ida "void __userpurge $name(TArtefact *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x809CF0

    constructor Create; // @addr 0x809C38 @ida "TArtefact *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x809C88 @ida "void __usercall $name(TArtefact *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Init(Owner: Byte; ItemType: TItemType); virtual; // @addr 0x809D38 @slot 0x4C
    function GetEffectiveType: TItemType; // @addr 0x80ADAC @note "Custom artefacts with SharedEffect use CountsAsItemType; otherwise returns ItemType."
    function GetOnUseCodeText: WideString; // @addr 0x80AB90 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Returns empty when the OnUseCode block is absent."
    function GetActionCode: Pointer; // @addr 0x80AC84 @note "Borrowed cached result, possibly nil. Marks initialization before resolving the configuration."
    function GetBoostStatusText: WideString; // @addr 0x80C3C0 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Uses the active equipment screen's ship; empty for broken artefacts or without a supported screen context."

    function GetDescriptionText: WideString; override; // @addr 0x80AAE0 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetBitmapResourceName: WideString; override; // @addr 0x80A760 @ida "void __usercall $name(TArtefact *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

  TArtefactTransmitter = class(TArtefact) // @size 0x6C
  public
    Power: Integer; // @offset 0x68

    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x80AFE8 @ida "void __userpurge $name(TArtefactTransmitter *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x80AE40
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x80AE6C
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x80AE9C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x80AF44

    procedure InitTransmitter(Owner: Byte); // @addr 0x80ADE8
  end;

  TArtefactTranclucator = class(TArtefact) // @size 0x6C
  public
    Ship: Pointer; // @offset 0x68  Owned while stored in the artefact; deployment transfers ownership.

    function GetDisplayName: WideString; override; // @addr 0x80B5A8 @ida "void __usercall $name(TArtefactTranclucator *Self@<eax>, unsigned __int16 **Result@<edx>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x80B31C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x80B350
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x80B54C
    procedure ClearReferences; override; // @addr 0x80B580
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x80B3BC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x80B484

    destructor Destroy; override; // @addr 0x80B138 @ida "void __usercall $name(TArtefactTranclucator *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitTranclucator(Owner: Byte; OwnerShip: Pointer; ExistingShip: Pointer); // @addr 0x80B188 @note "Takes ownership of ExistingShip, or creates a ship when nil."
    function Clone: TItem; override; // @addr 0x80B3A4 @note "Always returns nil."
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

    function GetDisplayName: WideString; override; // @addr 0x80C228 @ida "void __usercall $name(TArtefactCustom *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override; // @addr 0x80BF88 @ida "void __userpurge $name(TArtefactCustom *Self@<eax>, unsigned __int16 *ColorTag@<edx>, TShip *Ship@<ecx>, unsigned __int16 **Result@<^0>);"

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x80B9E4
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x80BAC8
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x80BBD8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x80BDC8

    procedure LoadConfig(ApplyConfiguredWeight: Boolean); // @addr 0x80B748 @note "Uses ConfigBlockName. Reloads NoWear, CountsAs, SharedUse and SharedEffect; preserves Data and TextData."

    function GetDescriptionText: WideString; override; // @addr 0x80C2FC @ida "void __usercall $name(TArtefactCustom *Self@<eax>, unsigned __int16 **Result@<edx>);"
  end;

// Nested native helpers include the caller's saved EBP explicitly in the IDA ABI.

function CreateRandomLootItem(Pool: TItemLootPool; Owner: Byte; Seed: Cardinal): TEquipmentWithActCode; // @addr 0x809AB0 @note "Selects across built-in artefacts, custom artefacts and configured useless items. Pool must be nonempty; AnyAvailable is the union of the three eligibility flags."

function ReadSavedMicroModuleIndex(Buffer: TBufEC): Integer; // @addr 0x7F0534 @note "Returns a one-based template index, or 0 if the saved template cannot be resolved."
function MigrateSavedItemType(ItemType: Byte): TItemType; // @addr 0x80CED4 @note "Applies the ordered item-type insertions for save versions before 164, 78, 131, 78 and 127; arithmetic wraps in a byte."

function GetBaseHullSlotCount(Kind: TShipSlotKind; HullType, Owner: Byte; Ship: Pointer): Integer; // @addr 0x7F6D68
function CalculateGeneratedHullCost(Capacity, Level: Cardinal; Owner, HullType: Byte): Integer; // @addr 0x7F4F38
function CalculateGeneratedFuelCapacity(Weight: Cardinal; Level: Integer): Integer; // @addr 0x7F77E0
function CalculateGeneratedFuelTanksCost(Weight: Cardinal; Level: Integer; Owner: Byte): Integer; // @addr 0x7F7834
function CalculateGeneratedEngineCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x7F8630
function CalculateGeneratedRadarCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x7F9C7C
function CalculateGeneratedScanerCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x7FAA80
function CalculateGeneratedRepairRobotCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x7FB90C
function CalculateGeneratedCargoHookCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x7FCAD0
function CalculateGeneratedDefGeneratorCost(Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x7FE2A4
function GetGeneratedDefenseDamageFactor(Level: Byte): Double; // @addr 0x7FE21C
function DefenseDamageFactorToPercent(Factor: Double): TPercent; // @addr 0x7FE240 @ida "unsigned __int8 __userpurge $name@<al>(double Factor@<^0>);"
function DefensePercentToDamageFactor(Percent: Integer): Double; // @addr 0x7FE26C

function GetMicroModuleInfoText(ModuleIndex: Integer; ColorTag: WideString): WideString; // @addr 0x8077B4 @ida "void __usercall $name(int ModuleIndex@<eax>, unsigned __int16 *ColorTag@<edx>, unsigned __int16 **Result@<ecx>);" @note "ModuleIndex is zero-based. Expands all bonus tokens in the configured description."

function GetMicroModulePriorityColorTier(ModuleIndex: Integer): Byte; // @addr 0x807C74
function GetMicroModuleNameColorTag(ModuleIndex: Integer): WideString; // @addr 0x807CBC @ida "void __usercall $name(int ModuleIndex@<eax>, unsigned __int16 **Result@<edx>);"
function GetMicroModuleTextColorTag(ModuleIndex: Integer): WideString; // @addr 0x807DE4 @ida "void __usercall $name(int ModuleIndex@<eax>, unsigned __int16 **Result@<edx>);"
function GetMicroModuleBitmapResourceName(ModuleIndex: Integer): WideString; // @addr 0x807E8C @ida "void __usercall $name(int ModuleIndex@<eax>, unsigned __int16 **Result@<edx>);"

function CreateConfiguredArtefactByItemType(ItemType: TItemType; Owner: Byte): TArtefact; // @addr 0x809A44 @note "Returns nil outside item types 10..41."

function CalculateGeneratedWeaponCost(Info: PWeaponInfo; Weight: Cardinal; Level, Owner: Byte): Integer; // @addr 0x7FFC98

function CreateItemByType(ItemType: TItemType): TItem; // @addr 0x80C5EC @note "Constructs the instance without calling its Init routine."
function CreateDefaultItemByType(ItemType: TItemType): TItem; // @addr 0x80C8A4
function CreateGeneratedEquipment(ItemType: TItemType; Weight, Level: Integer; Owner: Byte): TEquipment; // @addr 0x80CAAC @note "Clamps Level to 1..8; custom weapons require CreateGeneratedWeapon."
function CreateGeneratedWeapon(Info: PWeaponInfo; Weight, Level: Integer; Owner: Byte): TWeapon; // @addr 0x80CCA8

// Module indices are zero-based; compatibility checks also accept special bonuses.
function CanInstallMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x8093B0
function IsBonusCompatibleWithEquipment(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x8094A0
function IsBonusCompatibleWithHull(ModuleIndex: Integer; Hull: THull): Boolean; // @addr 0x809600
function IsBonusCompatibleWithWeapon(ModuleIndex: Integer; Weapon: TWeapon): Boolean; // @addr 0x809770
function ApplyMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean; // @addr 0x807FBC @note "Does not check compatibility or remove an existing module; -1 or nil returns False."
procedure ApplySpecialMicroModule(ModuleIndex: Integer; Item: TEquipment); // @addr 0x8089D8
procedure RemoveMicroModule(Item: TEquipment); // @addr 0x808524
procedure RemoveSpecialMicroModule(Item: TEquipment); // @addr 0x808C84

function CanCargoHookHandleItem(Item: TItem; Ship: Pointer): Boolean; // @addr 0x7F0080

function GetItemTypeBitmapPath(ItemType: TItemType): WideString; // @addr $80CD0C @ida "void __usercall $name(unsigned __int8 ItemType@<al>, unsigned __int16 **Result@<edx>);"

function GetStackableItemTypeName(ItemType: TItemType): WideString; // @addr $80CD90 @ida "void __usercall $name(unsigned __int8 ItemType@<al>, unsigned __int16 **Result@<edx>);" @note "Goods use their market display name; nodes use the generic node name; other types return empty."
function GetStackableItemName(Item: TItem): WideString; // @addr $80CE04 @ida "void __usercall $name(TItem *Item@<eax>, unsigned __int16 **Result@<edx>);" @note "Custom countables use their configured name; all other types use GetStackableItemTypeName. Ignores per-instance name overrides."

implementation

// @unit-initialization $8779AC
// @unit-finalization $80CF50

uses aPlanet, aTranclucator, aPirate, SysUtils, SE_Process, GR_Main, aConst, aPlayer, aScript, aMyFunction, Math, aShip, aKling, EC_Str, aAsteroid, aMissile, Globals, fShip2;

// Preserve the native evaluation order: select the percentage before clamping
// capacity. The inline helper also retains the compiler's separate temporaries.
procedure CalculateHullCapacityIncrease(const Hull: THull; const LowPercent, HighPercent: Integer;
  out Increase: Integer); inline;
var Capacity, Percent: Integer;
begin
  Percent := SeededRandomIntRange(LowPercent, HighPercent, Hull.Id * 214571);
  if Hull.Weight > 500 then Capacity := Hull.Weight else Capacity := 500;
  Increase := Round(Percent * Capacity * 0.01);
end;

{ @routine $7EE68C TItem_Create }
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
{ @end $7EE68C }

{ @routine $7EE6FC TItem_Destroy }
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
{ @end $7EE6FC }

{ @routine $7EE7B4 TItem_SaveToBuffer }
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
{ @end $7EE7B4 }

{ @routine $7EE878 TItem_LoadFromBuffer }
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
{ @end $7EE878 }

{ @routine $7EE984 TItem_SaveToBlock }
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
{ @end $7EE984 }

{ @routine $7EEC08 TItem_LoadFromBlock }
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
{ @end $7EEC08 }

{ @routine $7EEF04 TItem_ResolveLoadedReferences }
procedure TItem.ResolveLoadedReferences(Galaxy: TGalaxy);
begin

end;
{ @end $7EEF04 }

{ @routine $7EEF14 TItem_ClearReferences }
procedure TItem.ClearReferences;
begin

end;
{ @end $7EEF14 }

{ @routine $7EEF20 TItem_GetSmallInfoText }
function TItem.GetSmallInfoText: WideString;
begin
  Result := LookupLocalizedTextByKey('Items.SmallInfo');
end;
{ @end $7EEF20 }

{ @routine $7EEF64 TItem_CalculateResaleValue }
function TItem.CalculateResaleValue(TradingSkill: Byte): Integer;
begin
  if Self is TEquipment then
    Result := Max(1, Round((Cost - (Self as TEquipment).CalculateRepairCost) * 0.01 * PilotSkillEffects[TradingSkill, Ord(psTrading)]))
  else Result := Round(Cost * 0.01 * PilotSkillEffects[TradingSkill, Ord(psTrading)]);
end;
{ @end $7EEF64 }

{ @routine $7EF050 TItem_GetConditionAdjustedCost }
function TItem.GetConditionAdjustedCost: Integer;
begin
  if Self is TEquipment then Result := Max(1, Cost - (Self as TEquipment).CalculateRepairCost)
  else Result := Cost;
end;
{ @end $7EF050 }

{ @routine $7EF0B8 TItem_GetCategoryConfigName }
function TItem.GetCategoryConfigName: WideString;
begin
  if ItemType in [t_Weapon1..t_CustomWeapon] then Result := 'Weapon'
  else if ItemType in [t_ArtefactHull..t_ArtFastRacks] then Result := 'Artefact'
  else Result := ItemTypeNames[Ord(ItemType)];
end;
{ @end $7EF0B8 }

{ @routine $7EF144 TItem_GetShortName }
function TItem.GetShortName: WideString;
begin
  Result := '';
end;
{ @end $7EF144 }

{ @routine $7EF15C TItem_GetInfoText }
function TItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := '';
end;
{ @end $7EF15C }

{ @routine $7EF260 TItem_GetGraphObject }
function TItem.GetGraphObject: TObjectSE;

  // @nested $7EF1AC CreateContainer
  procedure CreateContainer(GraphKey: WideString); // @addr 0x7EF1AC @ida "void __usercall $name(unsigned __int16 *GraphKey@<eax>, void *ParentFrame@<^0>);" @note "Captures the item at ParentFrame-4; caller removes ParentFrame."
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
{ @end $7EF260 }

{ @routine $7F0060 TItem_ReleaseGraphObject }
procedure TItem.ReleaseGraphObject;
begin
  if GraphObject <> nil then ReleaseSpaceObject(GraphObject);
end;
{ @end $7F0060 }

{ @routine $7F0080 CanCargoHookHandleItem }
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
{ @end $7F0080 }

{ @routine $7F0160 TItem_GetOwnerConfigName }
function TItem.GetOwnerConfigName: WideString;
begin
  if Self is TGoods then Result := OwnerInfo[Ord(oiUninhabited)].InternalName
  else if TEquipment(Self).CustomFaction <> '' then Result := TEquipment(Self).CustomFaction
  else if (OwnerId = Byte(oiDominator)) and (Self is TEquipment) then Result := DominatorSeriesNames[Ord(TEquipment(Self).DominatorSeries)]
  else if (Self is THull) and (Self as THull).PirateBuilt then Result := OwnerInfo[Ord(oiPirate)].InternalName + OwnerToSys(OwnerId)
  else Result := OwnerInfo[OwnerId].InternalName;
end;
{ @end $7F0160 }

{ @routine $7F028C TEquipment_Create }
constructor TEquipment.Create;
begin
  inherited Create;
  ExtraSpecials := nil;
  EquippedFlag := 0;
end;
{ @end $7F028C }

{ @routine $7F02DC TEquipment_Destroy }
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
{ @end $7F02DC }

{ @routine $7F0368 TEquipment_SaveToBuffer }
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
{ @end $7F0368 }

{ @routine $7F0534 ReadSavedMicroModuleIndex }
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
{ @end $7F0534 }

{ @routine $7F062C TEquipment_LoadFromBuffer }
procedure TEquipment.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var ConfigNumber, Count, Index, ExistingIndex, ModuleIndex: Integer; Entry: PExtraSpecial;

  // @nested $7F05D0 FindLegacyMicroModuleIndex
  function FindLegacyMicroModuleIndex(ConfigNumber: Integer): Integer; // @addr 0x7F05D0 @ida "int __usercall $name@<eax>(int ConfigNumber@<eax>, void *ParentFrame@<^0>);" @note "Returns a one-based template index, or 0 if absent."
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
{ @end $7F062C }

{ @routine $7F0AC8 TEquipment_Clone }
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
{ @end $7F0AC8 }

{ @routine $7F0B6C TEquipment_SaveToBlock }
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
{ @end $7F0B6C }

{ @routine $7F1064 TEquipment_LoadFromBlock }
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
{ @end $7F1064 }

{ @routine $7F12E8 TEquipment_Equip }
procedure TEquipment.Equip;
begin
  EquippedFlag := 1;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then Exit;
  if ScriptItem <> nil then TScriptItem(ScriptItem).RunActionCode(satOnItemEquip, nil, nil, nil, 0);
  if Self is TEquipmentWithActCode then RunItemConfigActionCode(Self, satOnItemEquip, nil, nil, nil, 0);
end;
{ @end $7F12E8 }

{ @routine $7F1360 TEquipment_Unequip }
procedure TEquipment.Unequip;
begin
  EquippedFlag := 0;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then Exit;
  if ScriptItem <> nil then TScriptItem(ScriptItem).RunActionCode(satOnItemDeEquip, nil, nil, nil, 0);
  if Self is TEquipmentWithActCode then RunItemConfigActionCode(Self, satOnItemDeEquip, nil, nil, nil, 0);
end;
{ @end $7F1360 }

{ @routine $7F13D8 TEquipment_Repair }
procedure TEquipment.Repair;
begin
  ConditionPercent := 100;
  BrokenFlag := 0;
end;
{ @end $7F13D8 }

{ @routine $7F13F8 TEquipment_NeedsRepair }
function TEquipment.NeedsRepair: Boolean;
const
  RepairableTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
begin
  if ItemType = t_Hull then
    Result := (Self as THull).HullPoints < (Self as THull).Weight
  else
    Result := (Byte(ItemType) in RepairableTypes) and (ConditionPercent < 90);
end;
{ @end $7F13F8 }

{ @routine $7F147C TEquipment_CalculateRepairCost }
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
{ @end $7F147C }

{ @routine $7F170C TEquipment_GetConditionText }
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
{ @end $7F170C }

{ @routine $7F1E24 TEquipment_GetBrokenInBattleText }
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
{ @end $7F1E24 }

{ @routine $7F208C TEquipment_GetBrokenInUseText }
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
{ @end $7F208C }

{ @routine $7F22EC TEquipment_GetBrokenByForceText }
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
{ @end $7F22EC }

{ @routine $7F256C TEquipment_GetLevel }
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
{ @end $7F256C }

var
  EquipmentLevelLetters: array[1..8] of WideString = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'); // @addr $87CD2C Native managed-string defaults.
var
  TreasureMapColumnPositions: array[1..2, 0..3] of Integer = ((20, 40, 280, 380), (20, 40, 380, 490)); // @addr $87CD4C
  TreasureMapRuleLengths: array[1..2] of Integer = (76, 98); // @addr $87CD6C

{ @routine $7F26E4 TEquipment_GetLevelLetter }
function TEquipment.GetLevelLetter: WideString;
var Level: Integer;
begin
  Level := GetLevel;
  Result := '';
  if (Level >= 1) and (Level <= 8) then Result := EquipmentLevelLetters[Level];
end;
{ @end $7F26E4 }

{ @routine $7F2728 TEquipment_GetDescriptionText }
function TEquipment.GetDescriptionText: WideString;
begin
  if (ItemType in [t_FuelTanks..t_DefGenerator]) and (OwnerId = Byte(oiDominator)) then
    Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.KlingDescription.' + IntToStr(GetLevel))
  else Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.Description.' + IntToStr(GetLevel));
end;
{ @end $7F2728 }

{ @routine $7F28A4 TEquipment_GetDisplayName }
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
{ @end $7F28A4 }

{ @routine $7F2B74 TEquipment_GetShortName }
function TEquipment.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if OwnerId <> Byte(oiDominator) then
    Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.ShortName')
  else Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.KlingName');
end;
{ @end $7F2B74 }

{ @routine $7F2C98 TEquipment_ImproveAtScientificBase }
procedure TEquipment.ImproveAtScientificBase;
begin
  DetailImprovement := (Cardinal(Id) mod 2) + 1;
  case (Cardinal(Id) div 3) mod 6 of
    0: Improve(ikMajor);
    1..2: Improve(ikMedium);
  else Improve(ikMinor);
  end;
end;
{ @end $7F2C98 }

{ @routine $7F2CFC TEquipment_HasMicroModule }
function TEquipment.HasMicroModule: Boolean;
begin
  Result := MicroModuleIndex <> 0;
end;
{ @end $7F2CFC }

{ @routine $7F2D18 TEquipment_GetMicroModuleQuotedName }
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
{ @end $7F2D18 }

{ @routine $7F2DBC TEquipment_GetSpecialModuleName }
function TEquipment.GetSpecialModuleName: WideString;
begin
  if SpecialModuleIndex <> 0 then Result := MicroModuleTemplates[SpecialModuleIndex - 1].Name
  else Result := '';
end;
{ @end $7F2DBC }

{ @routine $7F2E00 TEquipment_Improve }
procedure TEquipment.Improve(Kind: TImprovementKind);
begin
end;
{ @end $7F2E00 }

{ @routine $7F2E10 TEquipment_CalculateImprovementCost }
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
{ @end $7F2E10 }

{ @routine $7F2EEC TEquipment_HasStandardStats }
function TEquipment.HasStandardStats: Boolean;
begin
  Result := True;
end;
{ @end $7F2EEC }

{ @routine $7F2F00 TEquipment_GetBitmapResourceName }
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
{ @end $7F2F00 }

{ @routine $7F3194 TEquipment_GetFragilityFactor }
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
{ @end $7F3194 }

{ @routine $7F330C TEquipment_ReplaceInfoTokens }
procedure TEquipment.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
begin
end;
{ @end $7F330C }

{ @routine $7F3354 TEquipment_GetStatBonus }
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
{ @end $7F3354 }

{ @routine $7F34FC TEquipment_GetDescriptionStatBonus }
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
{ @end $7F34FC }

{ @routine $7F3AAC TEquipment_GetBonusDescription }
function TEquipment.GetBonusDescription(ColorTag: WideString): WideString;
var
  Description: WideString;
  EffectPercent, PenaltyPercent, StatBonus: Integer;
  BonusKind: TEquipmentBonusKind;
  Index, ModuleIndexPlusOne: Integer;

  // @nested $7F3830 ExpandModuleTokens
  function ExpandModuleTokens(Text: WideString; ModuleIndexPlusOne, Count: Integer): WideString; // @addr 0x7F3830 @ida "void __userpurge $name(unsigned __int16 *Text@<eax>, int ModuleIndexPlusOne@<edx>, int Count@<ecx>, unsigned __int16 **Result@<^0>, void *ParentFrame@<^4>);" @calls "0x7F3B99 0x7F3D35 0x7F3E85" @stackpop 0x4 @note "Uses the parent description, bonus multipliers and color. RET 4 removes Result; the caller removes ParentFrame. Count 0 suppresses numeric bonuses."
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
{ @end $7F3AAC }

{ @routine $7F41B8 TEquipment_CanImprove }
function TEquipment.CanImprove: Boolean;
begin
  Result := HasStandardStats and ((SpecialModuleIndex = 0) or
    not MicroModuleTemplates[SpecialModuleIndex - 1].BlocksSpecialSlot);
end;
{ @end $7F41B8 }

{ @routine $7F4200 THull_Init }
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
{ @end $7F4200 }

{ @routine $7F42C8 THull_ApplySeriesSizeAndCost }
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
{ @end $7F42C8 }

{ @routine $7F43C8 THull_SaveToBuffer }
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
{ @end $7F43C8 }

{ @routine $7F45AC THull_LoadFromBuffer }
procedure THull.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var SavedHullType: Integer;

  // @nested $7F4504 ReadSavedHullSeriesIndex
  function ReadSavedHullSeriesIndex(Buffer: TBufEC): Integer; // @addr 0x7F4504 @ida "int __usercall $name@<eax>(TBufEC *Buffer@<eax>, void *ParentFrame@<^0>);" @note "Returns a zero-based series index, or -1 if absent or unresolved."
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
{ @end $7F45AC }

{ @routine $7F485C THull_ResolveLoadedReferences }
procedure THull.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  if InterceptorTarget <> nil then InterceptorTarget := TObject(Galaxy.IdToShip(Integer(InterceptorTarget), False)) as TShip;
end;
{ @end $7F485C }

{ @routine $7F4898 THull_ClearReferences }
procedure THull.ClearReferences;
begin
  inherited ClearReferences;
  InterceptorTarget := nil;
end;
{ @end $7F4898 }

{ @routine $7F48B4 THull_SaveToBlock }
procedure THull.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Hristophorisnotuse'), IntToStr(HullPoints)); // Decoded: 'Hitpoints'
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Alrumuotr'), IntToStr(Armor)); // Decoded: 'Armor'
  Block.AddParam(DecodeTextW('SohtiEprTtyopwec'), IntToStr(HullType)); // Decoded: 'ShipType'
  Block.AddParam(DecodeTextW('Stearoidess'), IntToStr(HullSeries)); // Decoded: 'Series'
  if HullSeries <> -1 then
    Block.AddParam(DecodeTextW('IfSoenrOilets2Noarmye'), GetSeriesName); // Decoded: 'ISeriesName'
  Block.AddParam(DecodeTextW('BlueivlitoBuyAPIinroaLtte'), BoolToWideString(PirateBuilt)); // Decoded: 'BuiltByPirate'
end;
{ @end $7F48B4 }

{ @routine $7F4BF8 THull_LoadFromBlock }
procedure THull.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  HullPoints := StrToInt(Block.GetParam(DecodeTextW('Hristophorisnotuse'))); // Decoded: 'Hitpoints'
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Armor := StrToInt(Block.GetParam(DecodeTextW('Alrumuotr'))); // Decoded: 'Armor'
  HullType := StrToInt(Block.GetParam(DecodeTextW('SohtiEprTtyopwec'))); // Decoded: 'ShipType'
  HullSeries := StrToInt(Block.GetParam(DecodeTextW('Stearoidess'))); // Decoded: 'Series'
  PirateBuilt := LowerCase(Block.GetParam(DecodeTextW('BlueivlitoBuyAPIinroaLtte'))) = 'true'; // Decoded: 'BuiltByPirate'
end;
{ @end $7F4BF8 }

{ @routine $7F4F10 THull_CalculateGeneratedArmor }
function THull.CalculateGeneratedArmor: ShortInt;
begin
  Result := HullLevelStats[TechLevel].Armor;
end;
{ @end $7F4F10 }

{ @routine $7F4F38 CalculateGeneratedHullCost }
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
{ @end $7F4F38 }

{ @routine $7F52FC THull_CalculateGeneratedCost }
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
{ @end $7F52FC }

{ @routine $7F5398 THull_Repair }
procedure THull.Repair;
begin
  inherited Repair;
  HullPoints := Weight;
end;
{ @end $7F5398 }

{ @routine $7F53B8 THull_Improve }
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
      ikMinor: CalculateHullCapacityIncrease(Self, 3, 7, ExtraCapacity);
      ikMedium: CalculateHullCapacityIncrease(Self, 8, 12, ExtraCapacity);
      ikMajor: CalculateHullCapacityIncrease(Self, 13, 17, ExtraCapacity);
    end;
    Inc(Weight, ExtraCapacity);
    Inc(HullPoints, ExtraCapacity);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;
{ @end $7F53B8 }

{ @routine $7F55C8 THull_HasStandardStats }
function THull.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)] = 0) then
    Result := CalculateGeneratedArmor = Armor
  else Result := CalculateGeneratedArmor = Armor - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonHull)];
end;
{ @end $7F55C8 }

{ @routine $7F5640 THull_GetDisplayName }
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
{ @end $7F5640 }

{ @routine $7F5ACC THull_GetSeriesName }
function THull.GetSeriesName: WideString;
begin
  if (OwnerShip <> nil) and TShip(OwnerShip).UsesVeteranHumanRangerAppearance then
    Result := FormatText1(LocalizedText('HullType.SeriesName'), '', '<Name>', LocalizedText('HullType.HullOldfag.Name'))
  else if HullSeries = -1 then Result := ''
  else Result := FormatText1(LocalizedText('HullType.SeriesName'), '', '<Name>', HullSeriesDefinitions[HullSeries].Name);
end;
{ @end $7F5ACC }

{ @routine $7F5C20 THull_GetShortName }
function THull.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Hull.ShortName');
end;
{ @end $7F5C20 }

{ @routine $7F5C8C THull_GetInfoText }
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
{ @end $7F5C8C }

{ @routine $7F5F7C THull_ReplaceInfoTokens }
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
{ @end $7F5F7C }

{ @routine $7F6654 THull_GetBitmapResourceName }
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
{ @end $7F6654 }

{ @routine $7F6AE4 THull_GetSpecialKindGraph }
function THull.GetSpecialKindGraph: WideString;
begin
  Result := '1';
  if SpecialModuleIndex = 0 then Exit;
  if MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '' then
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph;
end;
{ @end $7F6AE4 }

{ @routine $7F6B4C THull_GetSlotCount }
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
{ @end $7F6B4C }

{ @routine $7F6D68 GetBaseHullSlotCount }
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
{ @end $7F6D68 }

{ @routine $7F6FB4 THull_CalculateMass }
function THull.CalculateMass: Integer;
begin
  Result := Round(RemapClamped(TechLevel, 1, 8, Weight * 0.6, Weight * 0.8));
end;
{ @end $7F6FB4 }

{ @routine $7F7038 THull_GetFragilityFactor }
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
  DamageClass := ClassifyWeaponDamageFlags(Dword(DamageFlags));
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
{ @end $7F7038 }

{ @routine $7F72B8 THull_EstimateCapacityWithoutBonuses }
function THull.EstimateCapacityWithoutBonuses: Integer;
var I: Integer;

  // @nested $7F7274 UndoSizePercent
  procedure UndoSizePercent(Percent: Integer); // @addr 0x7F7274 @ida "void __usercall $name(int Percent@<eax>, void *ParentFrame@<^0>);" @note "Updates the parent's capacity accumulator; caller removes ParentFrame. Nonpositive Percent leaves it unchanged."
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
{ @end $7F72B8 }

{ @routine $7F7390 TFuelTanks_Init }
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
{ @end $7F7390 }

{ @routine $7F7400 TFuelTanks_SaveToBuffer }
procedure TFuelTanks.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Fuel));
  Buffer.AddAnsiChar(AnsiChar(Capacity));
end;
{ @end $7F7400 }

{ @routine $7F7448 TFuelTanks_LoadFromBuffer }
procedure TFuelTanks.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Fuel := Buffer.GetWord;
  Capacity := Buffer.GetByte;
end;
{ @end $7F7448 }

{ @routine $7F7498 TFuelTanks_SaveToBlock }
procedure TFuelTanks.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('FiuNeol'), IntToStr(Fuel)); // Decoded: 'Fuel'
  Block.AddParam(DecodeTextW('CraspiaNcliotay'), IntToStr(Capacity)); // Decoded: 'Capacity'
end;
{ @end $7F7498 }

{ @routine $7F762C TFuelTanks_LoadFromBlock }
procedure TFuelTanks.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Fuel := Word(StrToInt(Block.GetParam(DecodeTextW('FiuNeol')))); // Decoded: 'Fuel'
  Capacity := StrToInt(Block.GetParam(DecodeTextW('CraspiaNcliotay'))); // Decoded: 'Capacity'
end;
{ @end $7F762C }

{ @routine $7F77B8 TFuelTanks_CalculateGeneratedCapacity }
function TFuelTanks.CalculateGeneratedCapacity: Byte;
begin
  Result := CalculateGeneratedFuelCapacity(Weight, TechLevel);
end;
{ @end $7F77B8 }

{ @routine $7F77E0 CalculateGeneratedFuelCapacity }
function CalculateGeneratedFuelCapacity(Weight: Cardinal; Level: Integer): Integer;
begin
  Result := Round(Weight / FuelTanksBaseSize * 20 + FuelCapacityByLevel[Level]);
end;
{ @end $7F77E0 }

{ @routine $7F7834 CalculateGeneratedFuelTanksCost }
function CalculateGeneratedFuelTanksCost(Weight: Cardinal; Level: Integer; Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(Weight / FuelTanksBaseSize * Cardinal(Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7F7834 }

{ @routine $7F78A0 TFuelTanks_CalculateGeneratedCost }
function TFuelTanks.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedFuelTanksCost(Weight, TechLevel, OwnerId);
end;
{ @end $7F78A0 }

{ @routine $7F78CC TFuelTanks_Improve }
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
{ @end $7F78CC }

{ @routine $7F7A08 TFuelTanks_HasStandardStats }
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
{ @end $7F7A08 }

{ @routine $7F7B40 TFuelTanks_GetInfoText }
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
{ @end $7F7B40 }

{ @routine $7F7DB0 TFuelTanks_ReplaceInfoTokens }
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
{ @end $7F7DB0 }

{ @routine $7F8188 TEngine_Init }
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
{ @end $7F8188 }

{ @routine $7F8200 TEngine_SaveToBuffer }
procedure TEngine.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddIntegerValue(Speed);
  Buffer.AddAnsiChar(AnsiChar(JumpRange));
  Buffer.AddAnsiChar(AnsiChar(OutputPercent));
end;
{ @end $7F8200 }

{ @routine $7F8254 TEngine_LoadFromBuffer }
procedure TEngine.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  if LoadedSaveVersion >= 161 then Speed := Buffer.GetInt32 else Speed := Buffer.GetWord;
  JumpRange := ShortInt(Buffer.GetByte);
  OutputPercent := Buffer.GetByte;
  ItemType := t_Engine;
end;
{ @end $7F8254 }

{ @routine $7F82D4 TEngine_SaveToBlock }
procedure TEngine.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Sapreneld'), IntToStr(Speed)); // Decoded: 'Speed'
  Block.AddParam(DecodeTextW('JiuOmipa'), IntToStr(JumpRange)); // Decoded: 'Jump'
end;
{ @end $7F82D4 }

{ @routine $7F8460 TEngine_LoadFromBlock }
procedure TEngine.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Speed := Word(StrToInt(Block.GetParam(DecodeTextW('Sapreneld')))); // Decoded: 'Speed'
  JumpRange := StrToInt(Block.GetParam(DecodeTextW('JiuOmipa'))); // Decoded: 'Jump'
end;
{ @end $7F8460 }

{ @routine $7F85E4 TEngine_CalculateGeneratedSpeed }
function TEngine.CalculateGeneratedSpeed: Integer;
begin
  Result := EngineLevelStats[TechLevel].Speed;
end;
{ @end $7F85E4 }

{ @routine $7F860C TEngine_CalculateGeneratedJumpRange }
function TEngine.CalculateGeneratedJumpRange: ShortInt;
begin
  Result := EngineLevelStats[TechLevel].JumpRange;
end;
{ @end $7F860C }

{ @routine $7F8630 CalculateGeneratedEngineCost }
function CalculateGeneratedEngineCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(EngineBaseSize / Weight, 0.5, 2, 1, 2) * (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7F8630 }

{ @routine $7F86C4 TEngine_CalculateGeneratedCost }
function TEngine.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedEngineCost(Weight, TechLevel, OwnerId);
end;
{ @end $7F86C4 }

{ @routine $7F86F0 TEngine_Improve }
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
{ @end $7F86F0 }

{ @routine $7F8B0C TEngine_HasStandardStats }
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
{ @end $7F8B0C }

{ @routine $7F8BEC TEngine_GetInfoText }
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
{ @end $7F8BEC }

{ @routine $7F8DF0 TEngine_ReplaceInfoTokens }
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
{ @end $7F8DF0 }

{ @routine $7F992C TRadar_Init }
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
{ @end $7F992C }

{ @routine $7F9990 TRadar_SaveToBuffer }
procedure TRadar.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Range));
end;
{ @end $7F9990 }

{ @routine $7F99C8 TRadar_LoadFromBuffer }
procedure TRadar.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Range := Buffer.GetWord;
end;
{ @end $7F99C8 }

{ @routine $7F9A08 TRadar_SaveToBlock }
procedure TRadar.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // Decoded: 'Radius'
end;
{ @end $7F9A08 }

{ @routine $7F9B30 TRadar_LoadFromBlock }
procedure TRadar.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // Decoded: 'Radius'
end;
{ @end $7F9B30 }

{ @routine $7F9C54 TRadar_CalculateGeneratedRange }
function TRadar.CalculateGeneratedRange: Integer;
begin
  Result := RadarLevelRanges[TechLevel];
end;
{ @end $7F9C54 }

{ @routine $7F9C7C CalculateGeneratedRadarCost }
function CalculateGeneratedRadarCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(RadarBaseSize / Weight, 0.5, 2, 1, 2) * (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7F9C7C }

{ @routine $7F9D10 TRadar_CalculateGeneratedCost }
function TRadar.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedRadarCost(Weight, TechLevel, OwnerId);
end;
{ @end $7F9D10 }

{ @routine $7F9D3C TRadar_Improve }
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
{ @end $7F9D3C }

{ @routine $7F9ED8 TRadar_HasStandardStats }
function TRadar.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)] = 0) then
    Result := CalculateGeneratedRange = Range
  else Result := CalculateGeneratedRange = Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonRadar)];
end;
{ @end $7F9ED8 }

{ @routine $7F9F4C TRadar_GetInfoText }
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
{ @end $7F9F4C }

{ @routine $7FA14C TRadar_ReplaceInfoTokens }
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
{ @end $7FA14C }

{ @routine $7FA708 TScaner_Init }
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
{ @end $7FA708 }

{ @routine $7FA76C TScaner_SaveToBuffer }
procedure TScaner.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(ScanPower));
end;
{ @end $7FA76C }

{ @routine $7FA7A4 TScaner_LoadFromBuffer }
procedure TScaner.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  ScanPower := ShortInt(Buffer.GetByte);
  if (LoadedSaveVersion < 118) and (MicroModuleIndex <> 0) and
    (MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber = 122) then Inc(ScanPower);
end;
{ @end $7FA7A4 }

{ @routine $7FA810 TScaner_SaveToBlock }
procedure TScaner.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(ScanPower)); // Decoded: 'Power'
end;
{ @end $7FA810 }

{ @routine $7FA934 TScaner_LoadFromBlock }
procedure TScaner.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  ScanPower := StrToInt(Block.GetParam(DecodeTextW('Prouwseor'))); // Decoded: 'Power'
end;
{ @end $7FA934 }

{ @routine $7FAA50 TScaner_CalculateGeneratedScanPower }
function TScaner.CalculateGeneratedScanPower: Integer;
begin
  Result := DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(TechLevel)) + 1;
end;
{ @end $7FAA50 }

{ @routine $7FAA80 CalculateGeneratedScanerCost }
function CalculateGeneratedScanerCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(ScannerBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7FAA80 }

{ @routine $7FAB14 TScaner_CalculateGeneratedCost }
function TScaner.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedScanerCost(Weight, TechLevel, OwnerId);
end;
{ @end $7FAB14 }

{ @routine $7FAB40 TScaner_Improve }
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
{ @end $7FAB40 }

{ @routine $7FACD0 TScaner_HasStandardStats }
function TScaner.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonScan)] = 0) then
    Result := CalculateGeneratedScanPower = ScanPower
  else Result := CalculateGeneratedScanPower = ScanPower - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonScan)];
end;
{ @end $7FACD0 }

{ @routine $7FAD48 TScaner_GetInfoText }
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
{ @end $7FAD48 }

{ @routine $7FAF4C TScaner_ReplaceInfoTokens }
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
{ @end $7FAF4C }

{ @routine $7FB508 TRepairRobot_Init }
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
{ @end $7FB508 }

{ @routine $7FB56C TRepairRobot_SaveToBuffer }
procedure TRepairRobot.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(RepairPoints));
end;
{ @end $7FB56C }

{ @routine $7FB5A4 TRepairRobot_LoadFromBuffer }
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
{ @end $7FB5A4 }

{ @routine $7FB6A0 TRepairRobot_SaveToBlock }
procedure TRepairRobot.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Raenplavikr'), IntToStr(RepairPoints)); // Decoded: 'Repair'
end;
{ @end $7FB6A0 }

{ @routine $7FB7C8 TRepairRobot_LoadFromBlock }
procedure TRepairRobot.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  RepairPoints := StrToInt(Block.GetParam(DecodeTextW('Raenplavikr'))); // Decoded: 'Repair'
end;
{ @end $7FB7C8 }

{ @routine $7FB8E8 TRepairRobot_CalculateGeneratedRepairPoints }
function TRepairRobot.CalculateGeneratedRepairPoints: Byte;
begin
  Result := RepairRobotLevelPoints[TechLevel];
end;
{ @end $7FB8E8 }

{ @routine $7FB90C CalculateGeneratedRepairRobotCost }
function CalculateGeneratedRepairRobotCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(RepairRobotBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7FB90C }

{ @routine $7FB9A0 TRepairRobot_CalculateGeneratedCost }
function TRepairRobot.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedRepairRobotCost(Weight, TechLevel, OwnerId);
end;
{ @end $7FB9A0 }

{ @routine $7FB9CC TRepairRobot_Improve }
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
{ @end $7FB9CC }

{ @routine $7FBB5C TRepairRobot_HasStandardStats }
function TRepairRobot.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0) or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)] = 0) then
    Result := CalculateGeneratedRepairPoints = RepairPoints
  else Result := CalculateGeneratedRepairPoints = RepairPoints - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonDroid)];
end;
{ @end $7FBB5C }

{ @routine $7FBBD4 TRepairRobot_GetInfoText }
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
{ @end $7FBBD4 }

{ @routine $7FBDF8 TRepairRobot_ReplaceInfoTokens }
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
{ @end $7FBDF8 }

{ @routine $7FC3D4 TCargoHook_Create }
constructor TCargoHook.Create;
begin
  inherited Create;
end;
{ @end $7FC3D4 }

{ @routine $7FC418 TCargoHook_Init }
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
{ @end $7FC418 }

{ @routine $7FC4A8 TCargoHook_SaveToBuffer }
procedure TCargoHook.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(PickupPower));
  Buffer.AddWideChar(WideChar(Range));
  Buffer.AddSingle(MinPullSpeed);
  Buffer.AddSingle(MaxPullSpeed);
end;
{ @end $7FC4A8 }

{ @routine $7FC50C TCargoHook_LoadFromBuffer }
procedure TCargoHook.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  PickupPower := Buffer.GetWord;
  Range := Buffer.GetWord;
  MinPullSpeed := Buffer.GetSingle;
  MaxPullSpeed := Buffer.GetSingle;
end;
{ @end $7FC50C }

{ @routine $7FC57C TCargoHook_SaveToBlock }
procedure TCargoHook.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(PickupPower)); // Decoded: 'Power'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // Decoded: 'Radius'
  Block.AddParam(DecodeTextW('SapperenduMaidno'), FloatToStr(MinPullSpeed)); // Decoded: 'SpeedMin'
  Block.AddParam(DecodeTextW('Suplexe2d3Moarxi'), FloatToStr(MaxPullSpeed)); // Decoded: 'SpeedMax'
end;
{ @end $7FC57C }

{ @routine $7FC800 TCargoHook_LoadFromBlock }
procedure TCargoHook.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  PickupPower := Word(StrToInt(Block.GetParam(DecodeTextW('Prouwseor')))); // Decoded: 'Power'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // Decoded: 'Radius'
  MinPullSpeed := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('SapperenduMaidno'))); // Decoded: 'SpeedMin'
  MaxPullSpeed := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Suplexe2d3Moarxi'))); // Decoded: 'SpeedMax'
end;
{ @end $7FC800 }

{ @routine $7FCA30 TCargoHook_CalculateGeneratedPickupPower }
function TCargoHook.CalculateGeneratedPickupPower: Integer;
begin
  Result := CargoHookLevelStats[TechLevel].PickupPower;
end;
{ @end $7FCA30 }

{ @routine $7FCA58 TCargoHook_CalculateGeneratedRange }
function TCargoHook.CalculateGeneratedRange: Integer;
begin
  Result := CargoHookLevelStats[TechLevel].Range;
end;
{ @end $7FCA58 }

{ @routine $7FCA80 TCargoHook_CalculateGeneratedMinPullSpeed }
function TCargoHook.CalculateGeneratedMinPullSpeed: Single;
begin
  Result := CargoHookLevelStats[TechLevel].MinPullSpeed;
end;
{ @end $7FCA80 }

{ @routine $7FCAA8 TCargoHook_CalculateGeneratedMaxPullSpeed }
function TCargoHook.CalculateGeneratedMaxPullSpeed: Single;
begin
  Result := CargoHookLevelStats[TechLevel].MaxPullSpeed;
end;
{ @end $7FCAA8 }

{ @routine $7FCAD0 CalculateGeneratedCargoHookCost }
function CalculateGeneratedCargoHookCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(CargoHookBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7FCAD0 }

{ @routine $7FCB64 TCargoHook_CalculateGeneratedCost }
function TCargoHook.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedCargoHookCost(Weight, TechLevel, OwnerId);
end;
{ @end $7FCB64 }

{ @routine $7FCB90 TCargoHook_Improve }
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
{ @end $7FCB90 }

{ @routine $7FCF64 TCargoHook_HasStandardStats }
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
{ @end $7FCF64 }

{ @routine $7FD040 TCargoHook_GetInfoText }
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
{ @end $7FD040 }

{ @routine $7FD258 TCargoHook_ReplaceInfoTokens }
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
{ @end $7FD258 }

{ @routine $7FDED8 TDefGenerator_Init }
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
{ @end $7FDED8 }

{ @routine $7FDF44 TDefGenerator_SaveToBuffer }
procedure TDefGenerator.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddSingle(DamageFactor);
end;
{ @end $7FDF44 }

{ @routine $7FDF7C TDefGenerator_LoadFromBuffer }
procedure TDefGenerator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  DamageFactor := Buffer.GetSingle;
end;
{ @end $7FDF7C }

{ @routine $7FDFBC TDefGenerator_SaveToBlock }
procedure TDefGenerator.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // Decoded: 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), FloatToStr(1 - DamageFactor)); // Decoded: 'Power'
end;
{ @end $7FDFBC }

{ @routine $7FE0F0 TDefGenerator_LoadFromBlock }
procedure TDefGenerator.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // Decoded: 'TechLevel'
  DamageFactor := 1 - ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Prouwseor'))); // Decoded: 'Power'
end;
{ @end $7FE0F0 }

{ @routine $7FE1F8 TDefGenerator_CalculateGeneratedDamageFactor }
function TDefGenerator.CalculateGeneratedDamageFactor: Single;
begin
  Result := DefGeneratorLevelFactors[TechLevel];
end;
{ @end $7FE1F8 }

{ @routine $7FE21C GetGeneratedDefenseDamageFactor }
function GetGeneratedDefenseDamageFactor(Level: Byte): Double;
begin
  Result := DefGeneratorLevelFactors[Level];
end;
{ @end $7FE21C }

{ @routine $7FE240 DefenseDamageFactorToPercent }
function DefenseDamageFactorToPercent(Factor: Double): TPercent;
begin
  Result := Round((1 - Factor) * 100);
end;
{ @end $7FE240 }

{ @routine $7FE26C DefensePercentToDamageFactor }
function DefensePercentToDamageFactor(Percent: Integer): Double;
begin
  Result := 1 - Percent * 0.01;
end;
{ @end $7FE26C }

{ @routine $7FE2A4 CalculateGeneratedDefGeneratorCost }
function CalculateGeneratedDefGeneratorCost(Weight: Cardinal; Level, Owner: Byte): Integer;
begin
  Result := RoundAndTruncateToTens(RemapClamped(DefGeneratorBaseSize / Weight, 0.5, 2, 1, 2) *
    (Level * Level) * 500 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7FE2A4 }

{ @routine $7FE338 TDefGenerator_Improve }
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
{ @end $7FE338 }

{ @routine $7FE42C TDefGenerator_HasStandardStats }
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
{ @end $7FE42C }

{ @routine $7FE4C4 TDefGenerator_GetInfoText }
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
{ @end $7FE4C4 }

{ @routine $7FE6EC TDefGenerator_ReplaceInfoTokens }
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
{ @end $7FE6EC }

{ @routine $7FECE8 TWeapon_Destroy }
destructor TWeapon.Destroy;
begin
  inherited Destroy;
end;
{ @end $7FECE8 }

{ @routine $7FED1C TWeapon_Init }
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
{ @end $7FED1C }

{ @routine $7FEDE0 TCustomWeapon_InitCustom }
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
{ @end $7FEDE0 }

{ @routine $7FEEC0 TWeapon_SaveToBuffer }
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
{ @end $7FEEC0 }

{ @routine $7FF060 TCustomWeapon_SaveToBuffer }
procedure TCustomWeapon.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(CustomInfo.ConfigName);
  inherited SaveToBuffer(Buffer);
end;
{ @end $7FF060 }

{ @routine $7FF090 TWeapon_LoadFromBuffer }
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
{ @end $7FF090 }

{ @routine $7FF24C TCustomWeapon_LoadFromBuffer }
procedure TCustomWeapon.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  CustomInfo := Galaxy.RequireCustomWeaponInfo(Buffer.ReadWideString);
  inherited LoadFromBuffer(Buffer, Galaxy);
end;
{ @end $7FF24C }

{ @routine $7FF2C0 TWeapon_SaveToBlock }
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
{ @end $7FF2C0 }

{ @routine $7FF5A4 TCustomWeapon_SaveToBlock }
procedure TCustomWeapon.SaveToBlock(Block: TBlockParEC);
begin
  Block.AddParam(DecodeTextW('CrulsitroimaTryspie'), CustomInfo.ConfigName); // Decoded: 'CustomType'
  inherited SaveToBlock(Block);
end;
{ @end $7FF5A4 }

{ @routine $7FF640 TWeapon_LoadFromBlock }
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
{ @end $7FF640 }

{ @routine $7FF918 TCustomWeapon_LoadFromBlock }
procedure TCustomWeapon.LoadFromBlock(Block: TBlockParEC);
begin
  CustomInfo := Galaxy.RequireCustomWeaponInfo(Block.GetParam(DecodeTextW('CrulsitroimaTryspie'))); // Decoded: 'CustomType'
  inherited LoadFromBlock(Block);
end;
{ @end $7FF918 }

{ @routine $7FF9CC TWeapon_ResolveLoadedReferences }
procedure TWeapon.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  if LoadedTargetKind = wtkShip then Target := TObject(Galaxy.IdToShip(Integer(Target), True)) as TShip
  else if LoadedTargetKind = wtkItem then Target := TObject(Galaxy.IdToItem(Integer(Target), True)) as TItem
  else if LoadedTargetKind = wtkAsteroid then Target := TObject(Galaxy.IdToAsteroid(Integer(Target))) as TAsteroid
  else if LoadedTargetKind = wtkMissile then Target := TObject(Galaxy.IdToMissile(Integer(Target))) as TMissile;
end;
{ @end $7FF9CC }

{ @routine $7FFA94 TWeapon_ClearReferences }
procedure TWeapon.ClearReferences;
begin
  inherited ClearReferences;
  LoadedTargetKind := wtkNone;
  Target := nil;
end;
{ @end $7FFA94 }

{ @routine $7FFAB8 TWeapon_Unequip }
procedure TWeapon.Unequip;
begin
  inherited Unequip;
  Target := nil;
end;
{ @end $7FFAB8 }

{ @routine $7FFAD4 TWeapon_CalculateGeneratedAmmoCapacity }
function TWeapon.CalculateGeneratedAmmoCapacity: Integer;
begin
  Result := TechLevel * 5 + 25;
end;
{ @end $7FFAD4 }

{ @routine $7FFAF4 TWeapon_CalculateGeneratedMinDamage }
function TWeapon.CalculateGeneratedMinDamage: Integer;
begin
  Result := Round(GetWeaponInfo.MinDamage * GetWeaponInfo.DamageScaleByLevel[TechLevel]);
end;
{ @end $7FFAF4 }

{ @routine $7FFB34 TWeapon_CalculateGeneratedMaxDamage }
function TWeapon.CalculateGeneratedMaxDamage: Integer;
begin
  Result := Round(GetWeaponInfo.MaxDamage * GetWeaponInfo.DamageScaleByLevel[TechLevel]);
end;
{ @end $7FFB34 }

{ @routine $7FFB74 TWeapon_CalculateGeneratedRange }
function TWeapon.CalculateGeneratedRange: Integer;
begin
  Result := Round(GetWeaponInfo.AverageRange * WeaponRangeLevelFactors[TechLevel]);
end;
{ @end $7FFB74 }

{ @routine $7FFBA8 TWeapon_CalculateStandardMaxDamage }
function TWeapon.CalculateStandardMaxDamage: Integer;
var BonusKind: Byte;
begin
  Result := CalculateGeneratedMaxDamage;
  BonusKind := WeaponDamageClasses[Ord(ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags))].BonusKind;
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]);
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]);
end;
{ @end $7FFBA8 }

{ @routine $7FFC38 TWeapon_CalculateStandardRange }
function TWeapon.CalculateStandardRange: Integer;
begin
  Result := CalculateGeneratedRange;
  if MicroModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[Ord(bonWRadius)]);
  if SpecialModuleIndex <> 0 then Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[Ord(bonWRadius)]);
end;
{ @end $7FFC38 }

{ @routine $7FFC98 CalculateGeneratedWeaponCost }
function CalculateGeneratedWeaponCost(Info: PWeaponInfo; Weight: Cardinal; Level, Owner: Byte): Integer;
var LevelCost: Single;
begin
  LevelCost := RemapClamped(Level, 1, 8, 1, 4) * Info.CostFactor;
  Result := RoundAndTruncateToTens(RemapClamped(Info.AverageSize / Weight, 0.5, 2, 1, 2) *
    LevelCost * 250 * OwnerInfo[Owner].FuelPriceFactor);
end;
{ @end $7FFC98 }

{ @routine $7FFD5C TWeapon_Improve }
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
{ @end $7FFD5C }

{ @routine $8004D0 TWeapon_HasStandardStats }
function TWeapon.HasStandardStats: Boolean;
begin
  Result := (CalculateStandardMaxDamage = MaxDamage) and (CalculateStandardRange = Range);
end;
{ @end $8004D0 }

{ @routine $80050C TWeapon_GetDisplayName }
function TWeapon.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if (SpecialModuleIndex <> 0) and
    (MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace <> '') then
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].Name
  else Result := GetShortName;
  if HasMicroModule then Result := Result + ' ' + WrapTextInColor(GetMicroModuleQuotedName, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;
{ @end $80050C }

{ @routine $80061C TWeapon_GetShortName }
function TWeapon.GetShortName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Weapon.Name.' + GetConfigName);
end;
{ @end $80061C }

{ @routine $8006D8 TWeapon_GetInfoText }
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
{ @end $8006D8 }

{ @routine $800988 TWeapon_ReplaceInfoTokens }
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
{ @end $800988 }

{ @routine $801B0C TWeapon_GetDescriptionText }
function TWeapon.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.TWeapon.Description.' + GetConfigName);
end;
{ @end $801B0C }

{ @routine $801BB8 TWeapon_GetShotDelayFactor }
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
{ @end $801BB8 }

{ @routine $801CC8 TWeapon_GetBitmapResourceName }
function TWeapon.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0) and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)] + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)];
end;
{ @end $801CC8 }

{ @routine $801DF0 TCustomWeapon_GetBitmapResourceName }
function TCustomWeapon.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0) and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result := 'Bm.Items.' + GiResourceSuffix + 'W' + GetConfigName + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else Result := 'Bm.Items.' + GiResourceSuffix + 'W' + GetConfigName;
end;
{ @end $801DF0 }

{ @routine $801F28 TWeapon_NeedsAmmo }
function TWeapon.NeedsAmmo: Boolean;
begin
  Result := False;
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
    if Ammo < AmmoCapacity then Result := True;
end;
{ @end $801F28 }

{ @routine $801F60 TWeapon_CalculateAmmoRefillCost }
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
{ @end $801F60 }

{ @routine $801FD4 TWeapon_GetShotPalette }
function TWeapon.GetShotPalette: Integer;
begin
  if (SpecialModuleIndex = 0) or (MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual = -1) then
    Result := GetWeaponInfo.DefaultPalette
  else Result := MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual;
end;
{ @end $801FD4 }

{ @routine $80202C TWeapon_GetDamageFlags }
function TWeapon.GetDamageFlags: TDamageFlagSet;
var I: Integer; Entry: PExtraSpecial;
begin
  Result := TDamageFlagSet(GetWeaponInfo.DamageFlags);
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
{ @end $80202C }

{ @routine $8020E4 TWeapon_GetShotCount }
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
{ @end $8020E4 }

{ @routine $8021D4 TWeapon_GetAttackCount }
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
{ @end $8021D4 }

{ @routine $8022A4 TWeapon_GetWeaponInfo }
function TWeapon.GetWeaponInfo: PWeaponInfo;
begin
  Result := @WeaponInfos[Ord(ItemType)];
end;
{ @end $8022A4 }

{ @routine $8022D4 TCustomWeapon_GetWeaponInfo }
function TCustomWeapon.GetWeaponInfo: PWeaponInfo;
begin
  Result := CustomInfo;
end;
{ @end $8022D4 }

{ @routine $8022F0 TWeapon_GetConfigName }
function TWeapon.GetConfigName: WideString;
begin
  Result := IntToStr(Ord(ItemType) - Ord(t_Weapon1) + 1);
end;
{ @end $8022F0 }

{ @routine $802350 TCustomWeapon_GetConfigName }
function TCustomWeapon.GetConfigName: WideString;
begin
  Result := CustomInfo.ConfigName;
end;
{ @end $802350 }

{ @routine $802374 TGoods_Init }
procedure TGoods.Init(ItemType: TItemType; Quantity: Integer);
begin
  Self.ItemType := ItemType;
  Self.Quantity := Quantity;
  Weight := Quantity;
  Cost := GoodsMarket[Ord(Self.ItemType)].AveragePrice * Self.Quantity;
  NaturalFlag := False;
end;
{ @end $802374 }

{ @routine $8023CC TGoods_SaveToBuffer }
procedure TGoods.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Quantity);
  Buffer.AddBoolean(NaturalFlag);
end;
{ @end $8023CC }

{ @routine $802404 TGoods_LoadFromBuffer }
procedure TGoods.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Quantity := Buffer.GetInt32;
  NaturalFlag := Buffer.GetBoolean;
end;
{ @end $802404 }

{ @routine $802444 TGoods_GetDisplayName }
function TGoods.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := GoodsMarket[Ord(ItemType)].DisplayName;
end;
{ @end $802444 }

{ @routine $802494 TGoods_GetInfoText }
function TGoods.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var Text: WideString;
begin
  Text := LocalizedText('Items.Goods.Text' + IntToStr(Ord(ItemType) + 1));
  Result := WrapTextInColor(GetDisplayName, ColorTag) + Text;
end;
{ @end $802494 }

{ @routine $80258C TGoods_GetDescriptionText }
function TGoods.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Goods.Description.' + IntToStr(Ord(ItemType) + 1));
end;
{ @end $80258C }

{ @routine $802634 TGoods_GetBitmapResourceName }
function TGoods.GetBitmapResourceName: WideString;
begin
  Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)];
end;
{ @end $802634 }

{ @routine $8026BC TCountableItem_SaveToBuffer }
procedure TCountableItem.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(StackCount);
  Buffer.AddBoolean(Boolean(DropFlag));
end;
{ @end $8026BC }

{ @routine $8026F4 TCountableItem_LoadFromBuffer }
procedure TCountableItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  StackCount := Buffer.GetInt32;
  DropFlag := Byte(Buffer.GetBoolean);
end;
{ @end $8026F4 }

{ @routine $802734 TCountableItem_Init }
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
{ @end $802734 }

{ @routine $8027E0 TCountableItem_GetDisplayName }
function TCountableItem.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Name');
end;
{ @end $8027E0 }

{ @routine $8028AC TCountableItem_GetInfoText }
function TCountableItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Text');
  ReplaceTextToken(Result, '<N>', IntToStr(StackCount), ColorTag);
  if ScriptItem <> nil then Result := TScriptItem(ScriptItem).FormatDataText(Result, ColorTag);
end;
{ @end $8028AC }

{ @routine $8029F0 TCountableItem_GetDescriptionText }
function TCountableItem.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Description');
end;
{ @end $8029F0 }

{ @routine $802AAC TCountableItem_GetBitmapResourceName }
function TCountableItem.GetBitmapResourceName: WideString;
begin
  if StackCount <= 19 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '0_'
  else if StackCount <= 39 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '1_'
  else if StackCount <= 59 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '2_'
  else if StackCount <= 79 then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '3_'
  else Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '4_';
end;
{ @end $802AAC }

{ @routine $802C40 TCountableItem_GetUnitSize }
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
{ @end $802C40 }

{ @routine $802D38 TCountableItem_Split }
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
{ @end $802D38 }

{ @routine $802FFC TCountableItem_CanMerge }
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
{ @end $802FFC }

{ @routine $803078 TCountableItem_Merge }
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
{ @end $803078 }

{ @routine $8030D4 TProtoplasm_Init }
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
{ @end $8030D4 }

{ @routine $803138 TProtoplasm_GetDisplayName }
function TProtoplasm.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Nod.Name') + ' ' + LocalizedText('Items.Nod.S' + IntToStr(Ord(DominatorSeries)));
end;
{ @end $803138 }

{ @routine $803244 TProtoplasm_GetInfoText }
function TProtoplasm.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Nod.Text');
  ReplaceTextToken(Result, '<N>', IntToStr(StackCount), ColorTag);
end;
{ @end $803244 }

{ @routine $803310 TProtoplasm_GetDescriptionText }
function TProtoplasm.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Nod.Description');
end;
{ @end $803310 }

{ @routine $803360 TProtoplasm_GetBitmapResourceName }
function TProtoplasm.GetBitmapResourceName: WideString;
begin
  if StackCount <= 19 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod0_'
  else if StackCount <= 39 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod1_'
  else if StackCount <= 59 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod2_'
  else if StackCount <= 79 then Result := 'Bm.Items.' + GiResourceSuffix + 'Nod3_'
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Nod4_';
end;
{ @end $803360 }

{ @routine $8034E8 TEquipmentWithActCode_Create }
constructor TEquipmentWithActCode.Create;
begin
  inherited Create;
  ActionCode := nil;
  ActCodeInitialized := False;
end;
{ @end $8034E8 }

{ @routine $803538 TEquipmentWithActCode_Destroy }
destructor TEquipmentWithActCode.Destroy;
begin
  ActionCode := nil;
  inherited Destroy;
end;
{ @end $803538 }

{ @routine $803574 TUselessItem_Create }
constructor TUselessItem.Create;
begin
  inherited Create;
  DisplayAsArtefact := False;
end;
{ @end $803574 }

{ @routine $8035BC TUselessItem_Destroy }
destructor TUselessItem.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    RunItemConfigActionCode(Self, satOnItemDestroy, nil, nil, nil, 0);
  inherited Destroy;
end;
{ @end $8035BC }

{ @routine $803624 TUselessItem_Init }
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
{ @end $803624 }

{ @routine $803AA4 TUselessItem_SaveToBuffer }
procedure TUselessItem.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddWideStringZ(CustomText);
  Buffer.AddIntegerValue(Data[0]);
  Buffer.AddIntegerValue(Data[1]);
  Buffer.AddIntegerValue(Data[2]);
end;
{ @end $803AA4 }

{ @routine $803AF8 TUselessItem_LoadFromBuffer }
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
{ @end $803AF8 }

{ @routine $803BF0 TUselessItem_SaveToBlock }
procedure TUselessItem.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('SoyIsaNoarmoed'), ConfigBlockName); // Decoded: 'SysName'
end;
{ @end $803BF0 }

{ @routine $803C80 TUselessItem_LoadFromBlock }
procedure TUselessItem.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  ConfigBlockName := Block.GetParam(DecodeTextW('SoyIsaNoarmoed')); // Decoded: 'SysName'
  CheckIfWeDisplayAsArtefact;
end;
{ @end $803C80 }

{ @routine $803D28 TUselessItem_GetDisplayName }
function TUselessItem.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) <= 0 then Result := '' else Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Name');
end;
{ @end $803D28 }

{ @routine $803E2C TUselessItem_GetInfoText }
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
{ @end $803E2C }

{ @routine $804030 TUselessItem_GetDescriptionText }
function TUselessItem.GetDescriptionText: WideString;
begin
  if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) <= 0 then Result := '' else Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Description');
end;
{ @end $804030 }

{ @routine $804124 TUselessItem_GetBitmapResourceName }
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
{ @end $804124 }

{ @routine $804414 TUselessItem_IsDominatorRemains }
function TUselessItem.IsDominatorRemains: Boolean;
begin
  Result := (OwnerId = Byte(oiDominator)) and (Pos('Remains_', ConfigBlockName) = 1);
end;
{ @end $804414 }

{ @routine $804464 TUselessItem_CheckIfWeDisplayAsArtefact }
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
{ @end $804464 }

{ @routine $8044C4 TUselessItem_GetOnUseCodeText }
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
{ @end $8044C4 }

{ @routine $80455C TUselessItem_GetActionCode }
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
{ @end $80455C }

{ @routine $8045F4 TCistern_Init }
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
{ @end $8045F4 }

{ @routine $804674 TCistern_SaveToBuffer }
procedure TCistern.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(Capacity));
  Buffer.AddIntegerValue(Fuel);
end;
{ @end $804674 }

{ @routine $8046AC TCistern_LoadFromBuffer }
procedure TCistern.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Capacity := Buffer.GetByte;
  Fuel := Buffer.GetInt32;
end;
{ @end $8046AC }

{ @routine $8046EC TCistern_SaveToBlock }
procedure TCistern.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('FiuNeol'), IntToStr(Fuel)); // Decoded: 'Fuel'
  Block.AddParam(DecodeTextW('CraspiaNcliotay'), IntToStr(Capacity)); // Decoded: 'Capacity'
end;
{ @end $8046EC }

{ @routine $804804 TCistern_LoadFromBlock }
procedure TCistern.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Fuel := StrToInt(Block.GetParam(DecodeTextW('FiuNeol'))); // Decoded: 'Fuel'
  Capacity := StrToInt(Block.GetParam(DecodeTextW('CraspiaNcliotay'))); // Decoded: 'Capacity'
end;
{ @end $804804 }

{ @routine $804914 TCistern_GetDisplayName }
function TCistern.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.Cistern.Name');
end;
{ @end $804914 }

{ @routine $80497C TCistern_GetInfoText }
function TCistern.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Cistern.Text');
  ReplaceTextToken(Result, '<Fuel>', IntToStr(Fuel), ColorTag);
  ReplaceTextToken(Result, '<Capacity>', IntToStr(Capacity), ColorTag);
end;
{ @end $80497C }

{ @routine $804AB8 TCistern_GetDescriptionText }
function TCistern.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Cistern.Description');
end;
{ @end $804AB8 }

{ @routine $804B10 TCistern_GetBitmapResourceName }
function TCistern.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Cistern_';
end;
{ @end $804B10 }

{ @routine $804BE0 TSatellite_InitGenerated }
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
{ @end $804BE0 }

{ @routine $80515C TSatellite_SaveToBuffer }
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
{ @end $80515C }

{ @routine $8051FC TSatellite_LoadFromBuffer }
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
{ @end $8051FC }

{ @routine $805280 TSatellite_SaveToBlock }
procedure TSatellite.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('ToyIprey'), IntToStr(SatelliteTypeId)); // Decoded: 'Type'
  Block.AddParam(DecodeTextW('WuartTewrf'), IntToStr(WaterExplorationRate)); // Decoded: 'Water'
  Block.AddParam(DecodeTextW('LLagnsd3'), IntToStr(LandExplorationRate)); // Decoded: 'Land'
  Block.AddParam(DecodeTextW('HbiFldle'), IntToStr(HillExplorationRate)); // Decoded: 'Hill'
  Block.AddParam(DecodeTextW('WoeIamrr'), FloatToStr(WearPerTurn)); // Decoded: 'Wear'
end;
{ @end $805280 }

{ @routine $8054CC TSatellite_LoadFromBlock }
procedure TSatellite.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  SatelliteTypeId := StrToInt(Block.GetParam(DecodeTextW('ToyIprey'))); // Decoded: 'Type'
  WaterExplorationRate := StrToInt(Block.GetParam(DecodeTextW('WuartTewrf'))); // Decoded: 'Water'
  LandExplorationRate := StrToInt(Block.GetParam(DecodeTextW('LLagnsd3'))); // Decoded: 'Land'
  HillExplorationRate := StrToInt(Block.GetParam(DecodeTextW('HbiFldle'))); // Decoded: 'Hill'
  WearPerTurn := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('WoeIamrr'))); // Decoded: 'Wear'
end;
{ @end $8054CC }

{ @routine $8056E0 TSatellite_ResolveLoadedReferences }
procedure TSatellite.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  TargetPlanet := TObject(Galaxy.IdToPlanet(Cardinal(TargetPlanet))) as TPlanet;
end;
{ @end $8056E0 }

{ @routine $80571C TSatellite_ClearReferences }
procedure TSatellite.ClearReferences;
begin
  inherited ClearReferences;
  TargetPlanet := nil;
end;
{ @end $80571C }

{ @routine $805738 TSatellite_GetDisplayName }
function TSatellite.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LookupLocalizedTextByKey('Items.Satellite.Name') + ' ' +
    LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Name') + '-' + IntToStr(Cardinal(Id) mod 100 + 1);
end;
{ @end $805738 }

{ @routine $8058C4 TSatellite_GetInfoText }
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
{ @end $8058C4 }

{ @routine $805B1C TSatellite_GetBrokenInUseText }
function TSatellite.GetBrokenInUseText: WideString;
var PlanetName: WideString;
begin
  Result := LocalizedText('Items.' + ItemTypeNames[Ord(ItemType)] + '.BrokenInUse');
  if TargetPlanet <> nil then PlanetName := (TObject(TargetPlanet) as TPlanet).Name
  else PlanetName := '';
  ReplaceTextToken(Result, '<Name>', GetDisplayName, '<color=255,240,100>');
  ReplaceTextToken(Result, '<Planet>', PlanetName, '<color=255,240,100>');
end;
{ @end $805B1C }

{ @routine $805C84 TSatellite_GetIdleInfoText }
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
{ @end $805C84 }

{ @routine $805E30 TSatellite_GetDescriptionText }
function TSatellite.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Description');
end;
{ @end $805E30 }

{ @routine $805EF0 TSatellite_GetBitmapResourceName }
function TSatellite.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + 'Satellite' + IntToStr(SatelliteTypeId) + '_';
end;
{ @end $805EF0 }

{ @routine $805FF0 TTreasureMap_Init }
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
{ @end $805FF0 }

{ @routine $80613C TTreasureMap_SaveToBuffer }
procedure TTreasureMap.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  if TargetPlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord((TObject(TargetPlanet) as TPlanet).Id);
  Buffer.AddWideStringZ(SourceShipName);
  Buffer.AddWideStringZ(PreviewTablePage1);
  Buffer.AddWideStringZ(PreviewTablePage2);
end;
{ @end $80613C }

{ @routine $8061B4 TTreasureMap_LoadFromBuffer }
procedure TTreasureMap.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TargetPlanet := Pointer(Buffer.GetUInt32);
  SourceShipName := Buffer.ReadWideString;
  PreviewTablePage1 := Buffer.ReadWideString;
  PreviewTablePage2 := Buffer.ReadWideString;
end;
{ @end $8061B4 }

{ @routine $80626C TTreasureMap_ResolveLoadedReferences }
procedure TTreasureMap.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  TargetPlanet := TObject(Galaxy.IdToPlanet(Cardinal(TargetPlanet))) as TPlanet;
end;
{ @end $80626C }

{ @routine $8062A8 TTreasureMap_ClearReferences }
procedure TTreasureMap.ClearReferences;
begin
  inherited ClearReferences;
  TargetPlanet := nil;
end;
{ @end $8062A8 }

{ @routine $8062C4 TTreasureMap_GetDisplayName }
function TTreasureMap.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Items.TreasureMap.Name');
end;
{ @end $8062C4 }

{ @routine $806334 TTreasureMap_GetInfoText }
function TTreasureMap.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.TreasureMap.Text') + ' ' + LocalizedText('Items.TreasureMap.Hint');
  ReplaceTextToken(Result, '<Planet>', GetTargetPlanetName, '<color=255,240,100>');
  ReplaceTextToken(Result, '<Ship>', SourceShipName, '<color=255,240,100>');
end;
{ @end $806334 }

{ @routine $8064C8 TTreasureMap_GetDescriptionText }
function TTreasureMap.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.TreasureMap.Description');
end;
{ @end $8064C8 }

{ @routine $806528 TTreasureMap_GetBitmapResourceName }
function TTreasureMap.GetBitmapResourceName: WideString;
var Kind: Integer;
begin
  if OwnerId in [Ord(oiMaloc)..Ord(oiHuman)] then Kind := 1 else Kind := 2;
  Result := 'Bm.ItemsUseless.' + GiResourceSuffix + 'TreasureMap' + IntToStr(Kind) + '_';
end;
{ @end $806528 }

{ @routine $806624 TTreasureMap_GetTargetPlanetName }
function TTreasureMap.GetTargetPlanetName: WideString;
begin
  Result := (TObject(TargetPlanet) as TPlanet).Name;
end;
{ @end $806624 }

{ @routine $8067B0 TTreasureMap_BuildPreviewTable }
function TTreasureMap.BuildPreviewTable(PageIndex: Integer; Planet: Pointer): WideString;
var I, Number: Integer; Entry: PPlanetSurfaceLootEntry;
  Rows, Header, Caption, Rule: WideString; World: TPlanet;

  // @nested $806650 ItemColorTag
  function ItemColorTag(Item: TItem): WideString; // @addr $806650 @ida "void __usercall $name(TItem *Item@<eax>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x806D4B" @note "Nested helper of BuildPreviewTable; caller removes the unused static link."
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
{ @end $8067B0 }

{ @routine $8072F8 TMicroModule_Init }
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
{ @end $8072F8 }

{ @routine $80743C TMicroModule_SaveToBuffer }
procedure TMicroModule.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
end;
{ @end $80743C }

{ @routine $807458 TMicroModule_LoadFromBuffer }
procedure TMicroModule.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion < 113 then Buffer.GetInt32;
  if MicroModuleIndex = 0 then MicroModuleIndex := 1;
end;
{ @end $807458 }

{ @routine $8074A0 TMicroModule_GetDisplayName }
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
{ @end $8074A0 }

{ @routine $807608 TMicroModule_GetPlainName }
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
{ @end $807608 }

{ @routine $807758 TMicroModule_GetInfoText }
function TMicroModule.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := GetMicroModuleInfoText(MicroModuleIndex - 1, ColorTag);
end;
{ @end $807758 }

{ @routine $8077B4 GetMicroModuleInfoText }
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
{ @end $8077B4 }

{ @routine $807BC0 TMicroModule_GetDescriptionText }
function TMicroModule.GetDescriptionText: WideString;
begin
  Result := '';
end;
{ @end $807BC0 }

{ @routine $807BD8 TMicroModule_GetBitmapResourceName }
function TMicroModule.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := GetMicroModuleBitmapResourceName(MicroModuleIndex - 1);
end;
{ @end $807BD8 }

{ @routine $807C74 GetMicroModulePriorityColorTier }
function GetMicroModulePriorityColorTier(ModuleIndex: Integer): Byte;
begin
  case MicroModuleTemplates[ModuleIndex].Priority of
    0..30: Result := 3;
    31..69: Result := 2;
    70..100: Result := 1;
  else Result := 3;
  end;
end;
{ @end $807C74 }

{ @routine $807CBC GetMicroModuleNameColorTag }
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
{ @end $807CBC }

{ @routine $807DE4 GetMicroModuleTextColorTag }
function GetMicroModuleTextColorTag(ModuleIndex: Integer): WideString;
begin
  if MicroModuleTemplates[ModuleIndex].Color <> '' then
    Result := '<color=' + MicroModuleTemplates[ModuleIndex].Color + '>'
  else Result := '<color=255,167,84>';
end;
{ @end $807DE4 }

{ @routine $807E8C GetMicroModuleBitmapResourceName }
function GetMicroModuleBitmapResourceName(ModuleIndex: Integer): WideString;
begin
  if (ModuleIndex >= 0) and (MicroModuleTemplates[ModuleIndex].KindGraph <> '') then
    Result := 'Bm.Micromoduls.' + GiResourceSuffix + 'MM' + MicroModuleTemplates[ModuleIndex].KindGraph + '_'
  else Result := 'Bm.Micromoduls.' + GiResourceSuffix + 'MM' + IntToStr(GetMicroModulePriorityColorTier(ModuleIndex)) + '_';
end;
{ @end $807E8C }

{ @routine $807FBC ApplyMicroModule }
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
{ @end $807FBC }

{ @routine $808524 RemoveMicroModule }
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
{ @end $808524 }

{ @routine $8089D8 ApplySpecialMicroModule }
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
{ @end $8089D8 }

{ @routine $808C84 RemoveSpecialMicroModule }
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
{ @end $808C84 }

{ @routine $808EF0 TMicroModule_CalculateNodeExchangeValue }
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
{ @end $808EF0 }

{ @routine $809260 TMicroModule_GetHighlightedName }
function TMicroModule.GetHighlightedName: WideString;
begin
  Result := WrapTextInColor(MicroModuleTemplates[MicroModuleIndex - 1].Name, '<color=255,240,100>');
end;
{ @end $809260 }

{ @routine $8092C0 TMicroModule_CanInstallOn }
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
{ @end $8092C0 }

{ @routine $8093B0 CanInstallMicroModule }
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
{ @end $8093B0 }

{ @routine $8094A0 IsBonusCompatibleWithEquipment }
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
{ @end $8094A0 }

{ @routine $809600 IsBonusCompatibleWithHull }
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
{ @end $809600 }

{ @routine $809770 IsBonusCompatibleWithWeapon }
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
      else if (dkMissile in TDamageFlagSet(Info.DamageFlags)) and (Pos('<WMissile>', AllowedTypes) > 0) then Result := True
      else if (dkSplinter in TDamageFlagSet(Info.DamageFlags)) and (Pos('<WSplinter>', AllowedTypes) > 0) then Result := True
      else if (dkEnergy in TDamageFlagSet(Info.DamageFlags)) and (Pos('<WEnergy>', AllowedTypes) > 0) then Result := True
      else if Pos('<' + Info.ConfigName + '>', AllowedTypes) > 0 then Result := True;
    end
    else Result := True;
  end;
end;
{ @end $809770 }

{ @routine $809A44 CreateConfiguredArtefactByItemType }
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
{ @end $809A44 }

{ @routine $809AB0 CreateRandomLootItem }
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
{ @end $809AB0 }

{ @routine $809C38 TArtefact_Create }
constructor TArtefact.Create;
begin
  inherited Create;
  DisplayAsArtefact := True;
  Repair;
end;
{ @end $809C38 }

{ @routine $809C88 TArtefact_Destroy }
destructor TArtefact.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    RunItemConfigActionCode(Self, satOnItemDestroy, nil, nil, nil, 0);
  inherited Destroy;
end;
{ @end $809C88 }

{ @routine $809CF0 TArtefact_LoadFromBuffer }
procedure TArtefact.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if not (ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav,
    t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks]) then
    Repair;
end;
{ @end $809CF0 }

{ @routine $809D38 TArtefact_Init }
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
{ @end $809D38 }

{ @routine $80A760 TArtefact_GetBitmapResourceName }
function TArtefact.GetBitmapResourceName: WideString;
begin
  if Self is TArtefactCustom then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '_'
  else if ConfigBlockName <> '' then Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)] + '_';
end;
{ @end $80A760 }

{ @routine $80A868 TArtefact_GetDisplayName }
function TArtefact.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Name');
end;
{ @end $80A868 }

{ @routine $80A928 TArtefact_GetInfoText }
function TArtefact.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  if (ConfigBlockName <> '') and (LanguageDataConfig.GetBlock('Artefacts').CountBlocks(ConfigBlockName) > 0) then
    Result := LocalizedColorText('Artefacts.' + ConfigBlockName + '.Text') + GetBonusDescription(ColorTag) + GetConditionText(True) + GetBoostStatusText
  else
    Result := LocalizedColorText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Text') + GetBonusDescription(ColorTag) + GetConditionText(True) + GetBoostStatusText;
end;
{ @end $80A928 }

{ @routine $80AAE0 TArtefact_GetDescriptionText }
function TArtefact.GetDescriptionText: WideString;
begin
  Result := LocalizedColorText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Description');
end;
{ @end $80AAE0 }

{ @routine $80AB90 TArtefact_GetOnUseCodeText }
function TArtefact.GetOnUseCodeText: WideString;
var Block: TBlockParEC;
begin
  Result := '';
  if ItemType in [t_Artefact..t_Artefact2] then
    Block := LanguageDataConfig.GetBlock('Artefacts').GetBlock('CustomArtefacts').GetBlock(ConfigBlockName).FindBlock('OnUseCode')
  else Block := LanguageDataConfig.GetBlock('Artefacts').GetBlock(ItemTypeNames[Ord(ItemType)]).FindBlock('OnUseCode');
  if Block <> nil then Result := Block.ConcatenateValues;
end;
{ @end $80AB90 }

{ @routine $80AC84 TArtefact_GetActionCode }
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
{ @end $80AC84 }

{ @routine $80ADAC TArtefact_GetEffectiveType }
function TArtefact.GetEffectiveType: TItemType;
begin
  if (ItemType in [t_Artefact, t_Artefact2]) and TArtefactCustom(Self).SharedEffect then
    Result := TArtefactCustom(Self).CountsAsItemType
  else Result := ItemType;
end;
{ @end $80ADAC }

{ @routine $80ADE8 TArtefactTransmitter_InitTransmitter }
procedure TArtefactTransmitter.InitTransmitter(Owner: Byte);
begin
  Init(Owner, t_ArtefactTransmitter);
  Power := RoundAndTruncateToTens(SeededRandomIntRange(
    MinTransmitterPower, AverageTransmitterPower, Id * 317321));
end;
{ @end $80ADE8 }

{ @routine $80AE40 TArtefactTransmitter_SaveToBuffer }
procedure TArtefactTransmitter.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Power);
end;
{ @end $80AE40 }

{ @routine $80AE6C TArtefactTransmitter_LoadFromBuffer }
procedure TArtefactTransmitter.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Power := Buffer.GetInt32;
end;
{ @end $80AE6C }

{ @routine $80AE9C TArtefactTransmitter_SaveToBlock }
procedure TArtefactTransmitter.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(Power)); // Decoded: 'Power'
end;
{ @end $80AE9C }

{ @routine $80AF44 TArtefactTransmitter_LoadFromBlock }
procedure TArtefactTransmitter.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Power := StrToInt(Block.GetParam(DecodeTextW('Prouwseor'))); // Decoded: 'Power'
end;
{ @end $80AF44 }

{ @routine $80AFE8 TArtefactTransmitter_GetInfoText }
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
{ @end $80AFE8 }

{ @routine $80B138 TArtefactTranclucator_Destroy }
destructor TArtefactTranclucator.Destroy;
begin
  if Ship <> nil then begin
    TObject(Ship).Free;
    Ship := nil;
  end;
  inherited Destroy;
end;
{ @end $80B138 }

{ @routine $80B188 TArtefactTranclucator_InitTranclucator }
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
{ @end $80B188 }

{ @routine $80B31C TArtefactTranclucator_SaveToBuffer }
procedure TArtefactTranclucator.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  (TObject(Ship) as TTranclucator).SaveToBuffer(Buffer);
end;
{ @end $80B31C }

{ @routine $80B350 TArtefactTranclucator_LoadFromBuffer }
procedure TArtefactTranclucator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Ship := TTranclucator.Create;
  (TObject(Ship) as TTranclucator).LoadFromBuffer(Buffer, Galaxy);
end;
{ @end $80B350 }

{ @routine $80B3A4 TArtefactTranclucator_Clone }
function TArtefactTranclucator.Clone: TItem;
begin
  Result := nil;
end;
{ @end $80B3A4 }

{ @routine $80B3BC TArtefactTranclucator_SaveToBlock }
procedure TArtefactTranclucator.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  TTranclucator(Ship).SaveToBlock(Block.AddBlockByPath(DecodeTextW('S5heifphI4d') + IntToStr(Cardinal(TTranclucator(Ship).Id)))); // Decoded: 'ShipId'
end;
{ @end $80B3BC }

{ @routine $80B484 TArtefactTranclucator_LoadFromBlock }
procedure TArtefactTranclucator.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TTranclucator(Ship).LoadFromBlock(Block.GetBlockByPath(DecodeTextW('S5heifphI4d') + IntToStr(Cardinal(TTranclucator(Ship).Id)))); // Decoded: 'ShipId'
end;
{ @end $80B484 }

{ @routine $80B54C TArtefactTranclucator_ResolveLoadedReferences }
procedure TArtefactTranclucator.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  (TObject(Ship) as TTranclucator).ResolveLoadedReferences(Galaxy);
end;
{ @end $80B54C }

{ @routine $80B580 TArtefactTranclucator_ClearReferences }
procedure TArtefactTranclucator.ClearReferences;
begin
  inherited ClearReferences;
  (TObject(Ship) as TTranclucator).ClearObjectReferences;
end;
{ @end $80B580 }

{ @routine $80B5A8 TArtefactTranclucator_GetDisplayName }
function TArtefactTranclucator.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else if Ship <> nil then begin
    if Length((TObject(Ship) as TShip).Name) > 0 then Result := (TObject(Ship) as TShip).Name
    else Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Name') + '-' + IntToStr(Int64(Cardinal((TObject(Ship) as TShip).Id)));
  end else Result := LocalizedText('Artefacts.' + ItemTypeNames[Ord(ItemType)] + '.Name');
end;
{ @end $80B5A8 }

{ @routine $80B748 TArtefactCustom_LoadConfig }
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
{ @end $80B748 }

{ @routine $80B9E4 TArtefactCustom_SaveToBuffer }
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
{ @end $80B9E4 }

{ @routine $80BAC8 TArtefactCustom_LoadFromBuffer }
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
{ @end $80BAC8 }

{ @routine $80BBD8 TArtefactCustom_SaveToBlock }
procedure TArtefactCustom.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(1)), IntToStr(Data[1]));
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(2)), IntToStr(Data[2]));
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(3)), IntToStr(Data[3]));
end;
{ @end $80BBD8 }

{ @routine $80BDC8 TArtefactCustom_LoadFromBlock }
procedure TArtefactCustom.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Data[1] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(1))));
  Data[2] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(2))));
  Data[3] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(3))));
end;
{ @end $80BDC8 }

{ @routine $80BF88 TArtefactCustom_GetInfoText }
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
{ @end $80BF88 }

{ @routine $80C228 TArtefactCustom_GetDisplayName }
function TArtefactCustom.GetDisplayName: WideString;
begin
  if NameOverride <> '' then Result := NameOverride
  else Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Name');
end;
{ @end $80C228 }

{ @routine $80C2FC TArtefactCustom_GetDescriptionText }
function TArtefactCustom.GetDescriptionText: WideString;
begin
  Result := LocalizedColorText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Description');
end;
{ @end $80C2FC }

{ @routine $80C3C0 TArtefact_GetBoostStatusText }
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
{ @end $80C3C0 }

{ @routine $80C5EC CreateItemByType }
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
{ @end $80C5EC }

{ @routine $80C8A4 CreateDefaultItemByType }
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
{ @end $80C8A4 }

{ @routine $80CAAC CreateGeneratedEquipment }
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
          raise Exception.Create('Error CreateEq - cant create custom weapons')
        else if ItemType in [t_Weapon1..t_CustomWeapon] then TWeapon(Item).Init(ItemType, Weight, ActualLevel, Owner)
        else begin Item.Free; Result := nil; end;
      end;
    end;
  end;
end;
{ @end $80CAAC }

{ @routine $80CCA8 CreateGeneratedWeapon }
function CreateGeneratedWeapon(Info: PWeaponInfo; Weight, Level: Integer; Owner: Byte): TWeapon;
begin
  Result := TWeapon(CreateItemByType(Info.ItemType));
  if Info.ItemType in [t_Weapon1..t_Weapon18] then Result.Init(Info.ItemType, Weight, Level, Owner)
  else TCustomWeapon(Result).InitCustom(Info, False, Weight, Level, Owner);
end;
{ @end $80CCA8 }

{ @routine $80CD0C GetItemTypeBitmapPath }
function GetItemTypeBitmapPath(ItemType: TItemType): WideString;
begin
  Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[Ord(ItemType)];
end;
{ @end $80CD0C }

{ @routine $80CD90 GetStackableItemTypeName }
function GetStackableItemTypeName(ItemType: TItemType): WideString;
begin
  Result := '';
  if ItemType in [t_Food..t_Narcotics] then Result := GoodsMarket[Ord(ItemType)].DisplayName
  else if ItemType = t_Protoplasm then Result := LocalizedText('Items.Nod.Name');
end;
{ @end $80CD90 }

{ @routine $80CE04 GetStackableItemName }
function GetStackableItemName(Item: TItem): WideString;
begin
  if Item.ItemType = t_UselessCountableItem then
    Result := LocalizedText('Items.CustomCountables.' + (Item as TCountableItem).ConfigBlockName + '.Name')
  else Result := GetStackableItemTypeName(Item.ItemType);
end;
{ @end $80CE04 }

{ @routine $80CED4 MigrateSavedItemType }
function MigrateSavedItemType(ItemType: Byte): TItemType;
begin
  if (LoadedSaveVersion < 164) and (TItemType(ItemType) > t_Artefact) then Inc(ItemType);
  if (LoadedSaveVersion < 78) and (TItemType(ItemType) > t_ArtBio) then Inc(ItemType);
  if (LoadedSaveVersion < 131) and (TItemType(ItemType) > t_ArtPDTurret) then Inc(ItemType);
  if (LoadedSaveVersion < 78) and (TItemType(ItemType) > t_Weapon15) then Inc(ItemType, 3);
  if (LoadedSaveVersion < 127) and (TItemType(ItemType) > t_Weapon18) then Inc(ItemType);
  Result := TItemType(ItemType);
end;
{ @end $80CED4 }

end.
