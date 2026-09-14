unit GI_PSWeapon;
// Unit bracket (inferred): .text 0x004EB898..0x004EBB6E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, Types;

type
  TPSWeaponGI = class(TObjectGI) // @size 0x130
  public
    TargetPoint: TPoint; // @offset $120
    RemainingTicks: Integer; // @offset 0x128
    LifetimeTicks: Integer; // @offset 0x12C

    constructor Create(Owner: TObjectGI); // @addr 0x4EB9C4 @ida "TPSWeaponGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    procedure SetTargetPoint(Point: TPoint); virtual; abstract; // @slot $C8 @ida "void __usercall $name(TPSWeaponGI *Self@<eax>, TPoint *Point@<edx>);"
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); virtual; abstract; // @slot $CC
    function IsFinished: Boolean; // @addr $4EBA2C
    function GetElapsedTicks: Integer; virtual; // @addr 0x4EBA4C @slot 0xD0 @note "Returns LifetimeTicks minus RemainingTicks without clamping."
    function SampleGradientColor(const ColorValues: array of Single; Phase: Single): Cardinal; // @addr 0x4EBA74 @ida "unsigned int __userpurge $name@<eax>(TPSWeaponGI *Self@<eax>, float *ColorValues@<edx>, int ColorValuesHigh@<ecx>, float Phase@<^0>);" @note "Cyclic interpolation of normalized RGB triples in the current pixel format. Requires at least one triple and nonnegative Phase; trailing incomplete triples are ignored."
  end;

implementation

uses GR_Main;


{ @routine $4EB9C4 TPSWeaponGI_Create }
constructor TPSWeaponGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  LifetimeTicks := 65;
  RemainingTicks := LifetimeTicks;
end;
{ @end $4EB9C4 }

{ @routine $4EBA2C TPSWeaponGI_IsFinished }
function TPSWeaponGI.IsFinished: Boolean;
begin
  Result := RemainingTicks <= 0;
end;
{ @end $4EBA2C }

{ @routine $4EBA4C TPSWeaponGI_GetElapsedTicks }
function TPSWeaponGI.GetElapsedTicks: Integer;
begin
  Result := LifetimeTicks - RemainingTicks;
end;
{ @end $4EBA4C }

{ @routine $4EBA74 TPSWeaponGI_SampleGradientColor }
function TPSWeaponGI.SampleGradientColor(const ColorValues: array of Single; Phase: Single): Cardinal;
var
  Count, Index, NextIndex: Integer;
  Fraction: Single;
begin
  Count := Length(ColorValues) div 3;
  Index := Trunc(Phase);
  Fraction := Phase - Index;
  Index := Index mod Count;
  NextIndex := Index + 1;
  if NextIndex >= Count then NextIndex := 0;
  Result := CurrentPixelFormat.PackNormalizedRgb(
    (ColorValues[3 * NextIndex] - ColorValues[3 * Index]) * Fraction + ColorValues[3 * Index],
    (ColorValues[3 * NextIndex + 1] - ColorValues[3 * Index + 1]) * Fraction + ColorValues[3 * Index + 1],
    (ColorValues[3 * NextIndex + 2] - ColorValues[3 * Index + 2]) * Fraction + ColorValues[3 * Index + 2]);
end;
{ @end $4EBA74 }

end.
