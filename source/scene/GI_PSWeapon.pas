unit GI_PSWeapon;

interface

uses GI_MessageLoop, Types;

type
  TPSWeaponGI = class(TObjectGI) // @size 0x130
  public
    TargetPoint: TPoint; // @offset $120
    RemainingTicks: Integer; // @offset 0x128
    LifetimeTicks: Integer; // @offset 0x12C

    constructor Create(Owner: TObjectGI); // @addr 0x004E9CAC
    procedure SetTargetPoint(Point: TPoint); virtual; abstract; // @slot $C8
    procedure Advance(Timer: TCallbackTimerIdGI; UserData: Cardinal); virtual; abstract; // @slot $CC
    function IsFinished: Boolean; // @addr $4E9CFC
    function GetElapsedTicks: Integer; virtual; // @addr 0x004E9D08 @slot 0xD0 @note "Returns LifetimeTicks minus RemainingTicks without clamping."
    function SampleGradientColor(const ColorValues: array of Single; Phase: Single): Cardinal; // @addr 0x004E9D18 @note "Cyclic interpolation of normalized RGB triples in the current pixel format. Requires at least one triple and nonnegative Phase; trailing incomplete triples are ignored."
  end;

implementation

uses GR_Main;


{ @routine $4E9CAC TPSWeaponGI_Create }
constructor TPSWeaponGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  LifetimeTicks := 65;
  RemainingTicks := LifetimeTicks;
end;
{ @end $4E9CAC }

{ @routine $4E9CFC TPSWeaponGI_IsFinished }
function TPSWeaponGI.IsFinished: Boolean;
begin
  Result := RemainingTicks <= 0;
end;
{ @end $4E9CFC }

{ @routine $4E9D08 TPSWeaponGI_GetElapsedTicks }
function TPSWeaponGI.GetElapsedTicks: Integer;
begin
  Result := LifetimeTicks - RemainingTicks;
end;
{ @end $4E9D08 }

{ @routine $4E9D18 TPSWeaponGI_SampleGradientColor }
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
    (ColorValues[3 * NextIndex] - ColorValues[Index * 3]) * Fraction + ColorValues[3 * Index],
    (ColorValues[3 * NextIndex + 1] - ColorValues[Index * 3 + 1]) * Fraction + ColorValues[3 * Index + 1],
    (ColorValues[3 * NextIndex + 2] - ColorValues[3 * Index + 2]) * Fraction + ColorValues[3 * Index + 2]);
end;
{ @end $4E9D18 }

end.
