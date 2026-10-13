unit Variants;

interface

type
  TCustomVariantType = class(TObject) // @size 0xC
  public
    procedure Cast(var Dest: TVarData; const Source: TVarData); virtual; // @ida "void __usercall $name(TCustomVariantType *Self@<eax>, TVarData *Dest@<edx>, TVarData *Source@<ecx>);" @slot 0x18
    procedure CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType); virtual; // @ida "void __userpurge $name(TCustomVariantType *Self@<eax>, TVarData *Dest@<edx>, TVarData *Source@<ecx>, TVarType AVarType@<^0>);" @slot 0x1C
    procedure CastToOle(var Dest: TVarData; const Source: TVarData); virtual; // @ida "void __usercall $name(TCustomVariantType *Self@<eax>, TVarData *Dest@<edx>, TVarData *Source@<ecx>);" @slot 0x20
    function CompareOp(const Left, Right: TVarData; const Operator: TVarOp): Boolean; virtual; // @ida "bool __userpurge $name@<al>(TCustomVariantType *Self@<eax>, TVarData *Left@<edx>, TVarData *Right@<ecx>, TVarOp Operator@<^0>);" @slot 0x34
    destructor Destroy;
  end;

procedure TranslateResult(AResult: HResult);

procedure VarResultCheck; // @nameonly

procedure VarArrayClear(var V: TVarData);

procedure VarClearDeep; // @nameonly

procedure VarArrayCopyForEach; // @nameonly

procedure VarCopyDeep(var Dest: TVarData; const Source: TVarData); // @ida "void __usercall $name(TVarData *Dest@<eax>, TVarData *Source@<edx>);"

procedure _VarCopy(var Dest: TVarData; const Source: TVarData); // @nameonly

procedure CurrToWStrViaOS; // @nameonly

function DateToWStrViaOS(const AValue: TDateTime): WideString;

procedure BoolToWStrViaOS; // @nameonly

function VarToLStrViaOS(const V: TVarData): AnsiString; // @ida "void __usercall $name(TVarData *V@<eax>, char * *Result@<edx>);"

function VarToLStrCustom(const V: TVarData; out AValue: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(TVarData *V@<eax>, char * *AValue@<edx>);"

procedure _VarToLStr(var S: AnsiString; const V: TVarData); // @nameonly

function VarToWStrViaOS(const V: TVarData): WideString; // @ida "void __usercall $name(TVarData *V@<eax>, unsigned __int16 * *Result@<edx>);"

function VarToWStrCustom(const V: TVarData; out AValue: WideString): Boolean; // @ida "bool __usercall $name@<al>(TVarData *V@<eax>, unsigned __int16 * *AValue@<edx>);"

procedure _VarToWStr(var S: WideString; const V: TVarData); // @nameonly

procedure _VarFromInt(var V: TVarData; const Value: Integer; const Range: ShortInt); // @nameonly

procedure _VarFromInt64(var V: TVarData; const Value: Int64); // @nameonly

procedure _VarFromBool(var V: TVarData; const Value: Boolean); // @nameonly

procedure _VarFromLStr(var V: TVarData; const Value: AnsiString); // @nameonly

procedure _VarFromWStr(var V: TVarData; const Value: WideString); // @nameonly

procedure _VarAddRef(var V: TVarData); // @nameonly

function VarTypeAsText(const AType: TVarType): AnsiString;

procedure SetVarAsError(var V: TVarData; AResult: HResult);

procedure ClearVariantTypeList;

procedure FindCustomVariantType; // @nameonly

procedure FindCustomVariantType_412D74; // @nameonly

procedure FinalizeVariants; // @nameonly

implementation
end.
