unit ab_Global;
// Inferred original ownership: the native math contribution at $4E873C..$4EA2EF
// precedes GI_Tail's anonymous RTTI and VMT at $4EA2F0. Native PACKAGEINFO visits
// ab_Global from the arcade geometry family. Shared globals retain direct accesses.

interface

uses EC_Struct, SE_Process, EC_Buf, Types;

const
  // BonusTicks order from TabShip.ApplyDamage ($688438), UpdateState ($688E34)
  // and Advance ($689170); shared with map bonus flags and pickup handling.
  abkRegeneration = 0;
  abkSpeed = 1;
  abkSlow = 2;
  abkWeaponLock = 3;
  abkDamage = 4;
  abkRecharge = 5;
  abkShield = 6;
  abkInvisibility = 7;

  ArcadeBonusKindMask = $FF;
  ArcadeHiddenBonusFlag = $80000000;

type
  // Column-major storage: Matrix[Column][Row].
  TMatrix4D = array[0..3] of array[0..3] of Double; // @size 0x80

  TSphericalBearingState = record // @size 0x18
    LongitudeDegrees: Double; // @offset 0x00
    PolarAngleDegrees: Double; // @offset 0x08
    BearingDegrees: Double; // @offset 0x10
    // Polar angle is measured from -Y: 0 at -Y, 90 at the equator, 180 at +Y.
    // Longitude zero points toward -Z; positive longitude turns toward +X.
  end;

  TSphericalBearingDistance = record // @size 0x10
    BearingDeltaDegrees: Double; // @offset 0x00
    Distance: Double; // @offset 0x08
  end;

function MakeSphericalBearingState(LongitudeDegrees, PolarAngleDegrees, BearingDegrees: Double): TSphericalBearingState; // @addr 0x4E873C @ida "void __userpurge $name(TSphericalBearingState *Result@<eax>, double LongitudeDegrees@<^16>, double PolarAngleDegrees@<^8>, double BearingDegrees@<^0>);"
function SphericalToVector3D(LongitudeRadians, PolarAngleRadians, Radius: Double): TVector3D; // @addr 0x4E8774 @ida "void __userpurge $name(TVector3D *Result@<eax>, double LongitudeRadians@<^16>, double PolarAngleRadians@<^8>, double Radius@<^0>);"
procedure VectorToSphericalAngles(Vector: TVector3D; var LongitudeDegrees, PolarAngleDegrees: Double); // @addr 0x4E87FC @ida "void __usercall $name(TVector3D *Vector@<eax>, double *LongitudeDegrees@<edx>, double *PolarAngleDegrees@<ecx>);" @note "Requires a nonzero vector."
procedure AdvanceSphericalBearingState(var LongitudeDegrees, PolarAngleDegrees, BearingDegrees: Double; SphereRadius, ArcDistance: Double); // @addr 0x4E88B4 @ida "void __userpurge $name(double *LongitudeDegrees@<eax>, double *PolarAngleDegrees@<edx>, double *BearingDegrees@<ecx>, double SphereRadius@<^8>, double ArcDistance@<^0>);" @note "Negative distance moves backward. Longitude and bearing pass through Single precision when wrapped."
function AdvanceSphericalStateOnCurrentSphere(Source: TSphericalBearingState; ArcDistance: Double): TSphericalBearingState; // @addr 0x4E8CA0 @ida "void __userpurge $name(TSphericalBearingState *Source@<eax>, TSphericalBearingState *Result@<edx>, double ArcDistance@<^0>);"
function AdvanceSphericalStateAlongBearing(Source: TSphericalBearingState; TravelBearingDegrees, ArcDistance: Double): TSphericalBearingState; // @addr 0x4E8CF4 @ida "void __userpurge $name(TSphericalBearingState *Source@<eax>, TSphericalBearingState *Result@<edx>, double TravelBearingDegrees@<^8>, double ArcDistance@<^0>);" @note "Uses the current sphere radius; preserves the body's bearing relative to travel."
function AdvanceSphericalStateAndTravelBearing(Source: TSphericalBearingState; var TravelBearingDegrees: Double; ArcDistance: Double): TSphericalBearingState; // @addr 0x4E8D78 @ida "void __userpurge $name(TSphericalBearingState *Source@<eax>, double *TravelBearingDegrees@<edx>, TSphericalBearingState *Result@<ecx>, double ArcDistance@<^0>);" @note "Uses the current sphere radius; updates travel bearing and preserves the body's bearing relative to it."
procedure ComputeSphericalBearingAndDistance(var BearingDeltaDegrees, Distance: Double; SourceLongitudeDegrees, SourcePolarAngleDegrees, SourceBearingDegrees, TargetLongitudeDegrees, TargetPolarAngleDegrees, SphereRadius: Double); // @addr 0x4E8E04 @ida "void __userpurge $name(double *BearingDeltaDegrees@<eax>, double *Distance@<edx>, double SourceLongitudeDegrees@<^40>, double SourcePolarAngleDegrees@<^32>, double SourceBearingDegrees@<^24>, double TargetLongitudeDegrees@<^16>, double TargetPolarAngleDegrees@<^8>, double SphereRadius@<^0>);" @note "Bearing is relative to SourceBearingDegrees; coincident points return zero bearing delta and distance."
procedure ComputeSphericalDistance(var Distance: Double; SourceLongitudeDegrees, SourcePolarAngleDegrees, UnusedSourceBearingDegrees, TargetLongitudeDegrees, TargetPolarAngleDegrees, SphereRadius: Double); // @addr 0x4E9094 @ida "void __userpurge $name(double *Distance@<eax>, double SourceLongitudeDegrees@<^40>, double SourcePolarAngleDegrees@<^32>, double UnusedSourceBearingDegrees@<^24>, double TargetLongitudeDegrees@<^16>, double TargetPolarAngleDegrees@<^8>, double SphereRadius@<^0>);"
function GetSphericalBearingAndDistance(Source, Target: TSphericalBearingState): TSphericalBearingDistance; // @addr 0x4E91E4 @ida "void __usercall $name(TSphericalBearingState *Source@<eax>, TSphericalBearingState *Target@<edx>, TSphericalBearingDistance *Result@<ecx>);" @note "Uses the current sphere radius; ignores Target.BearingDegrees."
procedure UpdateSphereProjectionMetrics; // @addr 0x4E924C @note "Uses the shared sphere radius, camera distance, field of view and projection scale."
function IsDepthBeforeSphereHorizon(ProjectedDepth: Double): Boolean; // @addr 0x4E9558 @ida "bool __userpurge $name@<al>(double ProjectedDepth@<^0>);" @note "Compares against the horizon depth set by UpdateSphereProjectionMetrics."

function NormalizeVector3D(const Source: TVector3D): TVector3D; // @addr 0x4E9578 @ida "void __usercall $name(const TVector3D *Source@<eax>, TVector3D *Result@<edx>);" @note "Requires a nonzero vector."
function CrossProduct3D(const A, B: TVector3D): TVector3D; // @addr 0x4E95F8 @ida "void __usercall $name(const TVector3D *A@<eax>, const TVector3D *B@<edx>, TVector3D *Result@<ecx>);"
function DotProduct3D(const A, B: TVector3D): Double; // @addr 0x4E966C @ida "double __usercall $name@<st0>(const TVector3D *A@<eax>, const TVector3D *B@<edx>);"

procedure ClearMatrix4D(var Matrix: TMatrix4D); // @addr 0x4E96AC
procedure SetIdentityMatrix4D(var Matrix: TMatrix4D); // @addr 0x4E96F0
function BuildZAxisRotationMatrix(AngleRadians: Double): TMatrix4D; // @addr 0x4E97BC @ida "void __userpurge $name(TMatrix4D *Result@<eax>, double AngleRadians@<^0>);" @note "Rotates clockwise in the XY plane for positive angles."
function BuildPerspectiveProjectionMatrix(NearPlane, FarPlane, FovRadians, ProjectionScale: Double): TMatrix4D; // @addr 0x4E9834 @ida "void __userpurge $name(TMatrix4D *Result@<eax>, double NearPlane@<^24>, double FarPlane@<^16>, double FovRadians@<^8>, double ProjectionScale@<^0>);" @note "Uses the same scale for X and Y; projects NearPlane to depth 0 and FarPlane to depth 1."
function BuildLookAtMatrix(const CameraPos, TargetPos, UpVector: TVector3D): TMatrix4D; // @addr 0x4E98E0 @ida "void __userpurge $name(const TVector3D *CameraPos@<eax>, const TVector3D *TargetPos@<edx>, const TVector3D *UpVector@<ecx>, TMatrix4D *Result@<^0>);" @note "CameraPos must differ from TargetPos; UpVector must not be parallel to the viewing direction."
function InvertMatrix4D(const Matrix: TMatrix4D): TMatrix4D; // @addr 0x4E9F00 @ida "void __usercall $name(const TMatrix4D *Matrix@<eax>, TMatrix4D *Result@<edx>);" @note "Does not report singularity; zero pivots are replaced by 1e-20."
function MultiplyMatrix4D(const Left, Right: TMatrix4D): TMatrix4D; // @addr 0x4E9FB4 @ida "void __usercall $name(const TMatrix4D *Left@<eax>, const TMatrix4D *Right@<edx>, TMatrix4D *Result@<ecx>);"
function ProjectPointByMatrix(const Matrix: TMatrix4D; const Source: TVector3D): TVector3D; // @addr 0x4EA044 @ida "void __usercall $name(const TMatrix4D *Matrix@<eax>, const TVector3D *Source@<edx>, TVector3D *Result@<ecx>);" @note "Includes perspective division; homogeneous W must be nonzero."
function TryIntersectRayWithSphere(RayOrigin, RayPointOnRay, SphereCenter: TVector3D; SphereRadius: Double; var HitPoint: TVector3D): Boolean; // @addr 0x4EA0C4 @ida "bool __userpurge $name@<al>(TVector3D *RayOrigin@<eax>, TVector3D *RayPointOnRay@<edx>, TVector3D *SphereCenter@<ecx>, double SphereRadius@<^4>, TVector3D *HitPoint@<^0>);" @note "Ray points must differ. Rejects tangency. May write HitPoint on false; true requires forward distance greater than 0.001."

// Nested helpers of InvertMatrix4D. ParentFrame is a hidden, caller-popped argument.

var
  ArcadeViewMode: Byte = 0; // @addr $87A828 Shared camera/transition state; native TfAB accesses it through an external reference cell. Original unit unresolved.
  ArcadeSpaceProcess: TProcessSE = nil; // @addr $87A82C Shared scene process; native TfAB accesses it through external reference $882D3C. Original unit unresolved.
var
  ArcadeTickCount: Integer; // @addr $88922C
  ArcadeFrameCount: Integer; // @addr $889230
  ArcadeMapVersion: Cardinal; // @addr $889234 Second dword of the native abwm map header.
var

  SphereViewState: TSphericalBearingState; // @addr $889238 Shared view state via $882CAC; original data ownership unresolved.
  SphereViewMatrix: TMatrix4D; // @addr $889250
  SpherePerspectiveMatrix: TMatrix4D; // @addr $8892D0
  SphereProjectionMatrix: TMatrix4D; // @addr $889350 Shared projection matrix via reference cell $882638; original data ownership unresolved.
var
  ArcadeMapViewPosition: TPoint; // @addr $8893D0
  ArcadeMapCenter: TPoint; // @addr $8893D8
  ArcadeMapBounds: TRect; // @addr $8893E0
  ArcadeGridMode: Integer; // @addr $8893F0
  ArcadeMapColorBuffer: TBufEC; // @addr $8893F4 Loaded by the arcade map reader; stop lines and triangles borrow color pointers into Data.
  ArcadeAutopilotEnabled: Boolean; // @addr $8893F8
  ArcadeEnemiesDefeated: Boolean; // @addr $8893F9
  ArcadeLastInputTick: Integer; // @addr $8893FC
var

  SphereRadius: Double = 1000; // @addr $87A830
  SphereCameraDistance: Double = 2300; // @addr $87A838
  SphereNearCameraOffset: Double = 1300; // @addr $87A840
  SphereFarCameraOffset: Double = 20000; // @addr $87A848
  SphereFieldOfView: Double = 88; // @addr $87A850
  CameraFollowStep: Double = 14; // @addr $87A858 Maximum camera travel per tick; doubled for Keller dialogue framing.
  CameraLookAheadDistance: Double = 0; // @addr $87A860 Forward offset from the player when following.
  PlayerDriftTurnStep: Single = 1.8; // @addr $87A868
  PlayerInitialTurnSpeed: Single = 3.3; // @addr $87A86C Set on the player ship during TfAB.OnOpen.
  PlayerFastTurnSpeed: Single = 2.5; // @addr $87A870

  PlayerSlowTurnSpeed: Single = 3.8; // @addr $87A874
  SphereLowSpeedDrag: Single = 0.007; // @addr $87A878
  SphereHighSpeedDrag: Single = 0.18; // @addr $87A87C
  ArcadeMapNodeRadius: Integer = 60; // @addr $87A880
  ArcadeMapPanMargin: Integer = 200; // @addr $87A884
  ArcadePathStep: Single = 4; // @addr $87A888 Heading increment, straight-path spacing and endpoint snap distance.
  ArcadePathArcStep: Single = 4; // @addr $87A88C Initial spacing along turning arcs.
  SphereProjectedRadius: Single = 1; // @addr $87A890
  SphereNearHorizonDepth: Single = -1; // @addr $87A894
  SphereHorizonDepth: Single = 0; // @addr $87A898
  SphereFarHorizonDepth: Single = 1; // @addr $87A89C
  ShipFrontDepth: Single = 20; // @addr $87A8A0
  ShipBackDepth: Single = 30; // @addr $87A8A4
  ShipTailFrontDepth: Single = 21; // @addr $87A8A8
  ShipTailBackDepth: Single = 31; // @addr $87A8AC
  ItemFrontDepth: Single = 21; // @addr $87A8B0
  HitFrontDepth: Single = 19; // @addr $87A8B4
  HitBackDepth: Single = 29; // @addr $87A8B8
  WorldImageFrontDepth: Single = 22; // @addr $87A8BC
  WorldImageBackDepth: Single = 28; // @addr $87A8C0
  ExplosionFrontDepth: Single = 18; // @addr $87A8C4
  ExplosionBackDepth: Single = 28; // @addr $87A8C8
  ArcadeMapPalette: array[0..35] of Cardinal = (
    $FF28AC00, $8028AC00, $C028AC00, $0028AC00, $C028AC00, $C0FFFFFF,
    $FF003CFF, $80003CFF, $C0003CFF, $00003CFF, $C0003CFF, $C0FFFFFF,
    $FFFFFF00, $80FFFF00, $C0FFFF00, $00FFFF00, $C0FFFF00, $C0FFFFFF,
    $FFFFA636, $80FFA636, $C0FFA636, $00FFA636, $C0FFA636, $C0FFFFFF,
    $FFC80000, $80C80000, $C0C80000, $00C80000, $C0C80000, $C0FFFFFF,
    $FFA6002B, $80A6002B, $C0A6002B, $00A6002B, $C0A6002B, $C0FFFFFF); // @addr $87A8CC Six colors for each of six difficulty appearances.
  BonusRespawnSeconds: array[0..5] of Integer = (40, 60, 80, 100, 100, 150); // @addr $87A95C
  BonusDurationSeconds: array[0..7] of Integer = (12, 50, 40, 50, 40, 50, 60, 60); // @addr $87A974
  RegenerationHealthPerTick: Integer = 1; // @addr $87A994
  SpeedBonusScale: Single = 1.2; // @addr $87A998
  SpeedPenaltyScale: Single = 0.7; // @addr $87A99C
  WeaponDamageBonusScale: Single = 1.5; // @addr $87A9A0
  AmmoRechargeBonusScale: Single = 2; // @addr $87A9A4
  ShieldDamageScale: Single = 0.4; // @addr $87A9A8
  OtherInvisibleAlpha: Single = 0.2; // @addr $87A9AC
  PlayerInvisibleAlpha: Single = 0.5; // @addr $87A9B0
  RevealAfterFiringMs: Integer = 5500; // @addr $87A9B4
  WeaponSwitchDelayMs: Integer = 1200; // @addr $87A9B8
  ArcadeHighDangerThreshold: Single = 70; // @addr $87A9BC
  ManualCargoPickupDistance: Single = 200; // @addr $87A9C0
  CargoPickupDistance: Single = 80; // @addr $87A9C4

implementation

uses Math, aMyFunction, GR_Main;

{ @routine $4E873C MakeSphericalBearingState }
function MakeSphericalBearingState(LongitudeDegrees, PolarAngleDegrees, BearingDegrees: Double): TSphericalBearingState;
begin
  Result.LongitudeDegrees := LongitudeDegrees;
  Result.PolarAngleDegrees := PolarAngleDegrees;
  Result.BearingDegrees := BearingDegrees;
end;
{ @end $4E873C }

{ @routine $4E8774 SphericalToVector3D }
function SphericalToVector3D(LongitudeRadians, PolarAngleRadians, Radius: Double): TVector3D;
var V: TVector3D;
begin
  V.X := Sin(PolarAngleRadians) * Radius;
  V.Y := -Cos(PolarAngleRadians) * Radius;
  V.Z := 0;
  Result.X := Sin(LongitudeRadians) * V.X;
  Result.Y := V.Y;
  Result.Z := -Cos(LongitudeRadians) * V.X;
end;
{ @end $4E8774 }

{ @routine $4E87FC VectorToSphericalAngles }
procedure VectorToSphericalAngles(Vector: TVector3D; var LongitudeDegrees, PolarAngleDegrees: Double);
var Radius: Double;
begin
  Radius := Sqrt(Sqr(Vector.X) + Sqr(Vector.Y) + Sqr(Vector.Z));
  PolarAngleDegrees := RadiansToHeadingDegrees(ArcCos(-Vector.Y / Radius));
  LongitudeDegrees := RadiansToHeadingDegrees(Pi - ArcTan2(Vector.X, Vector.Z));
end;
{ @end $4E87FC }

{ @routine $4E88B4 AdvanceSphericalBearingState }
procedure AdvanceSphericalBearingState(var LongitudeDegrees, PolarAngleDegrees, BearingDegrees: Double; SphereRadius, ArcDistance: Double);
var ArcAngle, NewPolar, OldPolar, LongitudeDelta, OldBearing, NewBearing, InvSin, Value: Double;
    Reverse: Boolean;
begin
  if ArcDistance < 0 then
  begin
    Reverse := True;
    ArcDistance := -ArcDistance;
    BearingDegrees := WrapHeadingDegrees(BearingDegrees + 180);
  end
  else Reverse := False;
  OldBearing := HeadingDegreesToRadians(BearingDegrees);
  ArcAngle := ArcDistance / (2 * Pi * SphereRadius) * Pi * 2;
  OldPolar := HeadingDegreesToRadians(PolarAngleDegrees);
  NewPolar := ArcCos(Cos(OldPolar) * Cos(ArcAngle) + Sin(OldPolar) * Sin(ArcAngle) * Cos(OldBearing));
  if NewPolar < 0.00001 then InvSin := 99999999
  else InvSin := 1 / Sin(NewPolar);
  Value := (Sin(OldPolar) * Cos(ArcAngle) - Cos(OldPolar) * Sin(ArcAngle) * Cos(OldBearing)) * InvSin;
  if Value < -1 then Value := -1
  else if Value > 1 then Value := 1;
  LongitudeDelta := ArcCos(Value);
  Value := (Sin(ArcAngle) * Cos(OldPolar) - Cos(ArcAngle) * Sin(OldPolar) * Cos(OldBearing)) * InvSin;
  if Value < -1 then Value := -1
  else if Value > 1 then Value := 1;
  NewBearing := ArcCos(Value);
  if BearingDegrees > 180 then
  begin
    BearingDegrees := WrapHeadingDegrees(RadiansToHeadingDegrees(Pi + NewBearing));
    LongitudeDegrees := WrapHeadingDegrees(LongitudeDegrees - RadiansToHeadingDegrees(LongitudeDelta));
  end
  else
  begin
    BearingDegrees := WrapHeadingDegrees(RadiansToHeadingDegrees(Pi - NewBearing));
    LongitudeDegrees := WrapHeadingDegrees(LongitudeDegrees + RadiansToHeadingDegrees(LongitudeDelta));
  end;
  PolarAngleDegrees := RadiansToHeadingDegrees(NewPolar);
  if Reverse then BearingDegrees := WrapHeadingDegrees(BearingDegrees + 180);
end;
{ @end $4E88B4 }

{ @routine $4E8CA0 AdvanceSphericalStateOnCurrentSphere }
function AdvanceSphericalStateOnCurrentSphere(Source: TSphericalBearingState; ArcDistance: Double): TSphericalBearingState;
begin
  Result := Source;
  AdvanceSphericalBearingState(Result.LongitudeDegrees, Result.PolarAngleDegrees, Result.BearingDegrees, SphereRadius, ArcDistance);
end;
{ @end $4E8CA0 }

{ @routine $4E8CF4 AdvanceSphericalStateAlongBearing }
function AdvanceSphericalStateAlongBearing(Source: TSphericalBearingState; TravelBearingDegrees, ArcDistance: Double): TSphericalBearingState;
var RelativeBearing: Double;
begin
  Result := Source;
  RelativeBearing := HeadingDifferenceDegrees(TravelBearingDegrees, Result.BearingDegrees);
  AdvanceSphericalBearingState(Result.LongitudeDegrees, Result.PolarAngleDegrees, TravelBearingDegrees, SphereRadius, ArcDistance);
  Result.BearingDegrees := WrapHeadingDegrees(TravelBearingDegrees + RelativeBearing);
end;
{ @end $4E8CF4 }

{ @routine $4E8D78 AdvanceSphericalStateAndTravelBearing }
function AdvanceSphericalStateAndTravelBearing(Source: TSphericalBearingState; var TravelBearingDegrees: Double; ArcDistance: Double): TSphericalBearingState;
var RelativeBearing: Double;
begin
  Result := Source;
  RelativeBearing := HeadingDifferenceDegrees(TravelBearingDegrees, Result.BearingDegrees);
  AdvanceSphericalBearingState(Result.LongitudeDegrees, Result.PolarAngleDegrees, TravelBearingDegrees, SphereRadius, ArcDistance);
  Result.BearingDegrees := WrapHeadingDegrees(TravelBearingDegrees + RelativeBearing);
end;
{ @end $4E8D78 }

{ @routine $4E8E04 ComputeSphericalBearingAndDistance }
procedure ComputeSphericalBearingAndDistance(var BearingDeltaDegrees, Distance: Double; SourceLongitudeDegrees, SourcePolarAngleDegrees, SourceBearingDegrees, TargetLongitudeDegrees, TargetPolarAngleDegrees, SphereRadius: Double);
var ArcAngle, TargetPolar, SourcePolar, LongitudeDelta, Bearing, Value: Double;
begin
  TargetPolar := HeadingDegreesToRadians(TargetPolarAngleDegrees);
  SourcePolar := HeadingDegreesToRadians(SourcePolarAngleDegrees);
  LongitudeDelta := HeadingDegreesToRadians(WrapHeadingDegrees(TargetLongitudeDegrees - SourceLongitudeDegrees));
  Value := Cos(TargetPolar) * Cos(SourcePolar) + Sin(TargetPolar) * Sin(SourcePolar) * Cos(LongitudeDelta);
  if Value < -1 then Value := -1
  else if Value > 1 then Value := 1;
  ArcAngle := ArcCos(Value);
  Distance := ArcAngle / (2 * Pi) * 2 * Pi * SphereRadius;
  if ArcAngle = 0 then
  begin
    BearingDeltaDegrees := 0;
    Exit;
  end;
  Value := (Sin(SourcePolar) * Cos(TargetPolar) - Cos(SourcePolar) * Sin(TargetPolar) * Cos(LongitudeDelta)) / Sin(ArcAngle);
  if Value < -1 then Value := -1
  else if Value > 1 then Value := 1;
  Bearing := ArcCos(Value);
  if HeadingDifferenceDegrees(SourceLongitudeDegrees, TargetLongitudeDegrees) < 0 then Bearing := -Bearing;
  BearingDeltaDegrees := HeadingDifferenceDegrees(SourceBearingDegrees, RadiansToHeadingDegrees(Bearing));
end;
{ @end $4E8E04 }

{ @routine $4E9094 ComputeSphericalDistance }
procedure ComputeSphericalDistance(var Distance: Double; SourceLongitudeDegrees, SourcePolarAngleDegrees, UnusedSourceBearingDegrees, TargetLongitudeDegrees, TargetPolarAngleDegrees, SphereRadius: Double);
var ArcAngle, TargetPolar, SourcePolar, LongitudeDelta, Value: Double;
begin
  TargetPolar := HeadingDegreesToRadians(TargetPolarAngleDegrees);
  SourcePolar := HeadingDegreesToRadians(SourcePolarAngleDegrees);
  LongitudeDelta := HeadingDegreesToRadians(WrapHeadingDegrees(TargetLongitudeDegrees - SourceLongitudeDegrees));
  Value := Cos(TargetPolar) * Cos(SourcePolar) + Sin(TargetPolar) * Sin(SourcePolar) * Cos(LongitudeDelta);
  if Value < -1 then Value := -1
  else if Value > 1 then Value := 1;
  ArcAngle := ArcCos(Value);
  Distance := ArcAngle / (2 * Pi) * 2 * Pi * SphereRadius;
end;
{ @end $4E9094 }

{ @routine $4E91E4 GetSphericalBearingAndDistance }
function GetSphericalBearingAndDistance(Source, Target: TSphericalBearingState): TSphericalBearingDistance;
begin
  ComputeSphericalBearingAndDistance(Result.BearingDeltaDegrees, Result.Distance,
    Source.LongitudeDegrees, Source.PolarAngleDegrees, Source.BearingDegrees,
    Target.LongitudeDegrees, Target.PolarAngleDegrees, SphereRadius);
end;
{ @end $4E91E4 }

{ @routine $4E924C UpdateSphereProjectionMetrics }
procedure UpdateSphereProjectionMetrics;
var Angle: Double;
    V, Target, Up: TVector3D;
    View, Projection, Combined: TMatrix4D;
begin
  V := MakeVector3D(0, 0, SphereCameraDistance);
  Target := MakeVector3D(0, 0, 0);
  Up := MakeVector3D(0, 1, 0);
  View := BuildLookAtMatrix(V, Target, Up);
  Projection := BuildPerspectiveProjectionMatrix(SphereCameraDistance - SphereRadius - 100,
    SphereCameraDistance + SphereRadius + 100, HeadingDegreesToRadians(SphereFieldOfView), Cardinal(GameScreenWidth));
  Combined := MultiplyMatrix4D(Projection, View);
  Angle := 90 - (90 - RadiansToHeadingDegrees(ArcSin(SphereRadius / SphereCameraDistance)));
  V := MakeVector3D(0, 0, Sin(HeadingDegreesToRadians(Angle)) * SphereRadius);
  V := ProjectPointByMatrix(Combined, V);
  SphereHorizonDepth := V.Z;
  V := MakeVector3D(0, 0, Sin(HeadingDegreesToRadians(Angle - 15)) * SphereRadius);
  V := ProjectPointByMatrix(Combined, V);
  SphereNearHorizonDepth := V.Z;
  V := MakeVector3D(0, 0, Sin(HeadingDegreesToRadians(Angle + 15)) * SphereRadius);
  V := ProjectPointByMatrix(Combined, V);
  SphereFarHorizonDepth := V.Z;
  V := MakeVector3D(SphereRadius, 0, 0);
  V := ProjectPointByMatrix(Combined, V);
  SphereProjectedRadius := Max(Abs(V.X), Abs(V.Y));
end;
{ @end $4E924C }

{ @routine $4E9558 IsDepthBeforeSphereHorizon }
function IsDepthBeforeSphereHorizon(ProjectedDepth: Double): Boolean;
begin
  Result := ProjectedDepth < SphereHorizonDepth;
end;
{ @end $4E9558 }

{ @routine $4E9578 NormalizeVector3D }
function NormalizeVector3D(const Source: TVector3D): TVector3D;
var Scale: Double;
begin
  Scale := 1.0 / Sqrt(Source.X * Source.X + Source.Y * Source.Y + Source.Z * Source.Z);
  Result.X := Source.X * Scale;
  Result.Y := Source.Y * Scale;
  Result.Z := Source.Z * Scale;
end;
{ @end $4E9578 }

{ @routine $4E95F8 CrossProduct3D }
function CrossProduct3D(const A, B: TVector3D): TVector3D;
begin
  Result.X := A.Y * B.Z - A.Z * B.Y;
  Result.Y := A.Z * B.X - A.X * B.Z;
  Result.Z := A.X * B.Y - A.Y * B.X;
end;
{ @end $4E95F8 }

{ @routine $4E966C DotProduct3D }
function DotProduct3D(const A, B: TVector3D): Double;
begin
  Result := A.X * B.X + A.Y * B.Y + A.Z * B.Z;
end;
{ @end $4E966C }

{ @routine $4E96AC ClearMatrix4D }
procedure ClearMatrix4D(var Matrix: TMatrix4D);
var I, J: Integer;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do Matrix[I, J] := 0;
end;
{ @end $4E96AC }

{ @routine $4E96F0 SetIdentityMatrix4D }
procedure SetIdentityMatrix4D(var Matrix: TMatrix4D);
begin
  Matrix[0, 0] := 1; Matrix[1, 0] := 0; Matrix[2, 0] := 0; Matrix[3, 0] := 0;
  Matrix[0, 1] := 0; Matrix[1, 1] := 1; Matrix[2, 1] := 0; Matrix[3, 1] := 0;
  Matrix[0, 2] := 0; Matrix[1, 2] := 0; Matrix[2, 2] := 1; Matrix[3, 2] := 0;
  Matrix[0, 3] := 0; Matrix[1, 3] := 0; Matrix[2, 3] := 0; Matrix[3, 3] := 1;
end;
{ @end $4E96F0 }

{ @routine $4E97BC BuildZAxisRotationMatrix }
function BuildZAxisRotationMatrix(AngleRadians: Double): TMatrix4D;
var C, S: Double;
begin
  C := Cos(AngleRadians);
  S := Sin(AngleRadians);
  SetIdentityMatrix4D(Result);
  Result[0, 0] := C;
  Result[1, 1] := C;
  Result[0, 1] := -S;
  Result[1, 0] := S;
end;
{ @end $4E97BC }

{ @routine $4E9834 BuildPerspectiveProjectionMatrix }
function BuildPerspectiveProjectionMatrix(NearPlane, FarPlane, FovRadians, ProjectionScale: Double): TMatrix4D;
var C, S, Q: Double;
begin
  C := Cos(FovRadians * 0.5);
  S := Sin(FovRadians * 0.5);
  Q := S / (1.0 - NearPlane / FarPlane);
  ClearMatrix4D(Result);
  Result[0, 0] := C * ProjectionScale;
  Result[1, 1] := C * ProjectionScale;
  Result[2, 2] := Q;
  Result[3, 2] := -Q * NearPlane;
  Result[2, 3] := S;
end;
{ @end $4E9834 }

{ @routine $4E98E0 BuildLookAtMatrix }
function BuildLookAtMatrix(const CameraPos, TargetPos, UpVector: TVector3D): TMatrix4D;
var Forward, Right, Up: TVector3D;
begin
  SetIdentityMatrix4D(Result);
  Forward := MakeVector3D(TargetPos.X - CameraPos.X, TargetPos.Y - CameraPos.Y, TargetPos.Z - CameraPos.Z);
  Forward := NormalizeVector3D(Forward);
  Right := CrossProduct3D(UpVector, Forward);
  Up := CrossProduct3D(Forward, Right);
  Right := NormalizeVector3D(Right);
  Up := NormalizeVector3D(Up);
  Result[0, 0] := Right.X; Result[1, 0] := Right.Y; Result[2, 0] := Right.Z;
  Result[0, 1] := Up.X; Result[1, 1] := Up.Y; Result[2, 1] := Up.Z;
  Result[0, 2] := Forward.X; Result[1, 2] := Forward.Y; Result[2, 2] := Forward.Z;
  Result[3, 0] := -DotProduct3D(Right, CameraPos);
  Result[3, 1] := -DotProduct3D(Up, CameraPos);
  Result[3, 2] := -DotProduct3D(Forward, CameraPos);
end;
{ @end $4E98E0 }

{ @routine $4E9F00 InvertMatrix4D }
function InvertMatrix4D(const Matrix: TMatrix4D): TMatrix4D;
var Permutations: array[0..3] of Integer;
    Solution: array[0..3] of Double;
    I, J: Integer;
    PermutationSign: Double;
    Factors: TMatrix4D;

  // @nested $4E9A68 SolveMatrix4DLuSystem
  procedure SolveMatrix4DLuSystem(const Factors: TMatrix4D); // @addr 0x4E9A68 @ida "void __usercall $name(const TMatrix4D *Factors@<eax>, void *ParentFrame@<^0>);"
  var I, J, FirstNonzero, Pivot: Integer;
      Sum: Double;
  begin
    FirstNonzero := -1;
    for I := 0 to 3 do
    begin
      Pivot := Permutations[I];
      Sum := Solution[Pivot];
      Solution[Pivot] := Solution[I];
      if FirstNonzero >= 0 then
        for J := FirstNonzero to I - 1 do Sum := Sum - Factors[I, J] * Solution[J]
      else if Sum <> 0 then FirstNonzero := I;
      Solution[I] := Sum;
    end;
    for I := 3 downto 0 do
    begin
      Sum := Solution[I];
      for J := I + 1 to 3 do Sum := Sum - Factors[I, J] * Solution[J];
      Solution[I] := Sum / Factors[I, I];
    end;
  end;

  // @nested $4E9BB8 DecomposeMatrix4DLu
  procedure DecomposeMatrix4DLu(var Matrix: TMatrix4D; var PermutationSign: Double); // @addr 0x4E9BB8 @ida "void __usercall $name(TMatrix4D *Matrix@<eax>, double *PermutationSign@<edx>, void *ParentFrame@<^0>);"
  var Big, Temp, Sum, Magnitude: Double;
      I, Pivot, J, K: Integer;
      Scales: array[0..3] of Double;
  begin
    PermutationSign := 1;
    for I := 0 to 3 do
    begin
      Big := 0;
      for J := 0 to 3 do
      begin
        Magnitude := Abs(Matrix[I, J]);
        if Magnitude > Big then Big := Magnitude;
      end;
      Scales[I] := 1 / Big;
    end;
    for J := 0 to 3 do
    begin
      I := 0;
      while I < J do
      begin
        Sum := Matrix[I, J];
        K := 0;
        while K < I do
        begin
          Sum := Sum - Matrix[I, K] * Matrix[K, J];
          Inc(K);
        end;
        Matrix[I, J] := Sum;
        Inc(I);
      end;
      Pivot := 0;
      Big := 0;
      for I := J to 3 do
      begin
        Sum := Matrix[I, J];
        K := 0;
        while K < J do
        begin
          Sum := Sum - Matrix[I, K] * Matrix[K, J];
          Inc(K);
        end;
        Matrix[I, J] := Sum;
        Temp := Abs(Sum) * Scales[I];
        if Temp >= Big then
        begin
          Big := Temp;
          Pivot := I;
        end;
      end;
      if J <> Pivot then
      begin
        for K := 0 to 3 do
        begin
          Temp := Matrix[Pivot, K];
          Matrix[Pivot, K] := Matrix[J, K];
          Matrix[J, K] := Temp;
        end;
        PermutationSign := -PermutationSign;
        Scales[Pivot] := Scales[J];
      end;
      Permutations[J] := Pivot;
      if Matrix[J, J] = 0 then Matrix[J, J] := 1E-20;
      if J <> 3 then
      begin
        Temp := 1 / Matrix[J, J];
        for I := J + 1 to 3 do Matrix[I, J] := Matrix[I, J] * Temp;
      end;
    end;
  end;

begin
  Factors := Matrix;
  DecomposeMatrix4DLu(Factors, PermutationSign);
  for J := 0 to 3 do
  begin
    for I := 0 to 3 do Solution[I] := 0;
    Solution[J] := 1;
    SolveMatrix4DLuSystem(Factors);
    for I := 0 to 3 do Result[I, J] := Solution[I];
  end;
end;
{ @end $4E9F00 }

{ @routine $4E9FB4 MultiplyMatrix4D }
function MultiplyMatrix4D(const Left, Right: TMatrix4D): TMatrix4D;
var I, J, K: Integer;
begin
  ClearMatrix4D(Result);
  for I := 0 to 3 do
    for J := 0 to 3 do
      for K := 0 to 3 do
        Result[I, J] := Left[K, J] * Right[I, K] + Result[I, J];
end;
{ @end $4E9FB4 }

{ @routine $4EA044 ProjectPointByMatrix }
function ProjectPointByMatrix(const Matrix: TMatrix4D; const Source: TVector3D): TVector3D;
// Handwritten native x87 implementation: keeps X, Y, Z and reciprocal W on the
// FPU stack and writes the result without a Delphi frame or intermediate stores.
asm
  push ebx
  push edx
  push ecx
  mov ebx, edx
  mov edx, eax
  mov ecx, ecx
  fld qword ptr [ebx+$10]
  fld qword ptr [ebx+$08]
  fld qword ptr [ebx]
  fld qword ptr [edx+$18]
  fmul st, st(1)
  fld qword ptr [edx+$38]
  fmul st, st(3)
  faddp st(1), st
  fld qword ptr [edx+$58]
  fmul st, st(4)
  faddp st(1), st
  fadd qword ptr [edx+$78]
  fld1
  fdivrp st(1), st
  fld qword ptr [edx]
  fmul st, st(2)
  fld qword ptr [edx+$20]
  fmul st, st(4)
  faddp st(1), st
  fld qword ptr [edx+$40]
  fmul st, st(5)
  faddp st(1), st
  fadd qword ptr [edx+$60]
  fmul st, st(1)
  fstp qword ptr [ecx]
  fld qword ptr [edx+$08]
  fmul st, st(2)
  fld qword ptr [edx+$28]
  fmul st, st(4)
  faddp st(1), st
  fld qword ptr [edx+$48]
  fmul st, st(5)
  faddp st(1), st
  fadd qword ptr [edx+$68]
  fmul st, st(1)
  fstp qword ptr [ecx+$08]
  fld qword ptr [edx+$10]
  fmulp st(2), st
  fld qword ptr [edx+$30]
  fmulp st(3), st
  fld qword ptr [edx+$50]
  fmulp st(4), st
  fxch st(3)
  fadd qword ptr [edx+$70]
  faddp st(1), st
  faddp st(1), st
  fmulp st(1), st
  fstp qword ptr [ecx+$10]
  pop ecx
  pop edx
  pop ebx
end;
{ @end $4EA044 }

{ @routine $4EA0C4 TryIntersectRayWithSphere }
function TryIntersectRayWithSphere(RayOrigin, RayPointOnRay, SphereCenter: TVector3D; SphereRadius: Double; var HitPoint: TVector3D): Boolean;
var T, OtherT, Projection, Discriminant, DistanceSquared: Double;
    Direction, CenterDelta: TVector3D;
begin
  Direction.X := RayPointOnRay.X - RayOrigin.X;
  Direction.Y := RayPointOnRay.Y - RayOrigin.Y;
  Direction.Z := RayPointOnRay.Z - RayOrigin.Z;
  T := 1 / Sqrt(Direction.X * Direction.X + Direction.Y * Direction.Y + Direction.Z * Direction.Z);
  Direction.X := Direction.X * T;
  Direction.Y := Direction.Y * T;
  Direction.Z := Direction.Z * T;
  CenterDelta.X := SphereCenter.X - RayOrigin.X;
  CenterDelta.Y := SphereCenter.Y - RayOrigin.Y;
  CenterDelta.Z := SphereCenter.Z - RayOrigin.Z;
  DistanceSquared := CenterDelta.X * CenterDelta.X + CenterDelta.Y * CenterDelta.Y + CenterDelta.Z * CenterDelta.Z;
  Projection := CenterDelta.X * Direction.X + CenterDelta.Y * Direction.Y + CenterDelta.Z * Direction.Z;
  Discriminant := Sqr(SphereRadius) - DistanceSquared + Projection * Projection;
  if Discriminant <= 0 then
  begin
    Result := False;
    Exit;
  end;
  Discriminant := Sqrt(Discriminant);
  if Projection < Discriminant then
  begin
    T := Projection + Discriminant;
    OtherT := Projection - Discriminant;
  end
  else
  begin
    T := Projection - Discriminant;
    OtherT := Projection + Discriminant;
  end;
  if Abs(T) < 0.001 then T := OtherT;
  HitPoint.X := Direction.X * T + RayOrigin.X;
  HitPoint.Y := Direction.Y * T + RayOrigin.Y;
  HitPoint.Z := Direction.Z * T + RayOrigin.Z;
  Result := T > 0.001;
end;
{ @end $4EA0C4 }

end.
