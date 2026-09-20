unit Variants;
// Unit bracket (inferred): .text 0x0041059C..0x00412EDB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00876144..0x008761ED; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TCustomVariantType = class(TObject) // @size 0xC
  public
    procedure Cast(var Dest: TVarData; const Source: TVarData); virtual; // @ida "void __usercall $name(TCustomVariantType *Self@<eax>, TVarData *Dest@<edx>, TVarData *Source@<ecx>);" @note "DCC32 MAP Variants.TCustomVariantType.Cast. Source rtl/sys/Variants.pas:5062." @slot 0x18
    procedure CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType); virtual; // @ida "void __userpurge $name(TCustomVariantType *Self@<eax>, TVarData *Dest@<edx>, TVarData *Source@<ecx>, TVarType AVarType@<^0>);" @note "DCC32 MAP Variants.TCustomVariantType.CastTo. Source rtl/sys/Variants.pas:5072." @slot 0x1C
    function CompareOp(const Left, Right: TVarData; const Operator: TVarOp): Boolean; virtual; // @ida "bool __userpurge $name@<al>(TCustomVariantType *Self@<eax>, TVarData *Left@<edx>, TVarData *Right@<ecx>, TVarOp Operator@<^0>);" @note "DCC32 MAP Variants.TCustomVariantType.CompareOp. Source rtl/sys/Variants.pas:5090." @slot 0x34
    procedure CastToOle(var Dest: TVarData; const Source: TVarData); virtual; // @ida "void __usercall $name(TCustomVariantType *Self@<eax>, TVarData *Dest@<edx>, TVarData *Source@<ecx>);" @note "DCC32 MAP Variants.TCustomVariantType.CastToOle. Source rtl/sys/Variants.pas:5108." @slot 0x20
    destructor Destroy; // @note "DCC32 MAP Variants.TCustomVariantType.Destroy. Source rtl/sys/Variants.pas:5157."
  end;

procedure TranslateResult(AResult: HResult); // @note "DCC32 MAP Variants.TranslateResult. Source rtl/sys/Variants.pas:565."

procedure VarResultCheck; // @nameonly @note "DCC32 MAP Variants.VarResultCheck. Prototype pending: no unique source declaration."

procedure VarArrayClear(var V: TVarData); // @note "DCC32 MAP Variants.VarArrayClear. Source rtl/sys/Variants.pas:631."

procedure VarClearDeep; // @nameonly @note "DCC32 MAP Variants.VarClearDeep. Prototype pending: no unique source declaration."

procedure VarArrayCopyForEach; // @nameonly @note "DCC32 MAP Variants.VarArrayCopyForEach. Source rtl/sys/Variants.pas:819. Prototype pending: unsupported source type TVarArrayForEach: procedure(var Dest: TVarData; const Src: TVarData)."

procedure VarCopyDeep(var Dest: TVarData; const Source: TVarData); // @ida "void __usercall $name(TVarData *Dest@<eax>, TVarData *Source@<edx>);" @note "DCC32 MAP Variants.VarCopyDeep. Source rtl/sys/Variants.pas:913."

procedure _VarCopy(var Dest: TVarData; const Source: TVarData); // @nameonly @note "DCC32 MAP Variants.@VarCopy. Source rtl/sys/Variants.pas:954. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure CurrToWStrViaOS; // @nameonly @note "DCC32 MAP Variants.CurrToWStrViaOS. Source rtl/sys/Variants.pas:2214. Prototype pending: source type not found: Currency."

function DateToWStrViaOS(const AValue: TDateTime): WideString; // @note "DCC32 MAP Variants.DateToWStrViaOS. Source rtl/sys/Variants.pas:2220."

procedure BoolToWStrViaOS; // @nameonly @note "DCC32 MAP Variants.BoolToWStrViaOS. Source rtl/sys/Variants.pas:2226. Prototype pending: source type not found: WordBool."

function VarToLStrViaOS(const V: TVarData): AnsiString; // @ida "void __usercall $name(TVarData *V@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Variants.VarToLStrViaOS. Source rtl/sys/Variants.pas:2239."

function VarToLStrCustom(const V: TVarData; out AValue: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(TVarData *V@<eax>, char * *AValue@<edx>);" @note "DCC32 MAP Variants.VarToLStrCustom. Source rtl/sys/Variants.pas:2267."

procedure _VarToLStr(var S: AnsiString; const V: TVarData); // @nameonly @note "DCC32 MAP Variants.@VarToLStr. Source rtl/sys/Variants.pas:2285. Prototype pending: compiler-helper ABI needs explicit analysis."

function VarToWStrViaOS(const V: TVarData): WideString; // @ida "void __usercall $name(TVarData *V@<eax>, unsigned __int16 * *Result@<edx>);" @note "DCC32 MAP Variants.VarToWStrViaOS. Source rtl/sys/Variants.pas:2353."

function VarToWStrCustom(const V: TVarData; out AValue: WideString): Boolean; // @ida "bool __usercall $name@<al>(TVarData *V@<eax>, unsigned __int16 * *AValue@<edx>);" @note "DCC32 MAP Variants.VarToWStrCustom. Source rtl/sys/Variants.pas:2381."

procedure _VarToWStr(var S: WideString; const V: TVarData); // @nameonly @note "DCC32 MAP Variants.@VarToWStr. Source rtl/sys/Variants.pas:2399. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _VarFromInt(var V: TVarData; const Value: Integer; const Range: ShortInt); // @nameonly @note "DCC32 MAP Variants.@VarFromInt. Source rtl/sys/Variants.pas:2529. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _VarFromInt64(var V: TVarData; const Value: Int64); // @nameonly @note "DCC32 MAP Variants.@VarFromInt64. Source rtl/sys/Variants.pas:2617. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _VarFromBool(var V: TVarData; const Value: Boolean); // @nameonly @note "DCC32 MAP Variants.@VarFromBool. Source rtl/sys/Variants.pas:2657. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _VarFromLStr(var V: TVarData; const Value: AnsiString); // @nameonly @note "DCC32 MAP Variants.@VarFromLStr. Source rtl/sys/Variants.pas:2695. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _VarFromWStr(var V: TVarData; const Value: WideString); // @nameonly @note "DCC32 MAP Variants.@VarFromWStr. Source rtl/sys/Variants.pas:2709. Prototype pending: compiler-helper ABI needs explicit analysis."

procedure _VarAddRef(var V: TVarData); // @nameonly @note "DCC32 MAP Variants.@VarAddRef. Source rtl/sys/Variants.pas:3971. Prototype pending: compiler-helper ABI needs explicit analysis."

function VarTypeAsText(const AType: TVarType): AnsiString; // @note "DCC32 MAP Variants.VarTypeAsText. Source rtl/sys/Variants.pas:3986."

procedure SetVarAsError(var V: TVarData; AResult: HResult); // @note "DCC32 MAP Variants.SetVarAsError. Source rtl/sys/Variants.pas:4224."

procedure ClearVariantTypeList; // @note "DCC32 MAP Variants.ClearVariantTypeList. Source rtl/sys/Variants.pas:5040."

procedure FindCustomVariantType; // @nameonly @note "DCC32 MAP Variants.FindCustomVariantType. Prototype pending: no unique source declaration."

procedure FindCustomVariantType_412D74; // @nameonly @note "DCC32 MAP Variants.FindCustomVariantType. Prototype pending: no unique source declaration."

procedure FinalizeVariants; // @nameonly @note "DCC32 MAP Variants.Finalization. Prototype pending: no unique source declaration."

implementation
end.
