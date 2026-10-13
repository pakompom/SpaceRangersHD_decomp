unit aAsteroid;

interface

uses EC_Buf, EC_Struct, SE_Space, SE_Asteroid, aEFilm, aGalaxy;

type
  TAsteroid = class(TObjectEx) // @size 0x3C
  public
    Id: Cardinal; // @offset 0x04
    CurrentStar: TStar; // @offset 0x08
    Position: TPointF; // @offset 0x0C  World coordinates: PhysicsPosition multiplied by 6e-9.
    PhysicsPosition: TPointF; // @offset 0x14
    Velocity: TPointF; // @offset 0x1C  In the physics coordinate system.
    Mass: Single; // @offset 0x24
    GravityForceFactor: Single; // @offset 0x28  G * Mass * 2e30.
    InverseMass: Single; // @offset 0x2C
    MineralCount: Integer; // @offset 0x30
    GraphObject: TAsteroidSE; // @offset 0x34  Retained reference initialized by the Asteroid scene factory.
    FilmObject: TEFilmObj; // @offset 0x38  Borrowed from the film.

    constructor Create; // @addr 0x00727F8C
    destructor Destroy; override; // @addr 0x00727FE4
    procedure Init(Star: TStar; const GraphKey: WideString); // @addr 0x00728018 @note "Requires an unassigned GraphObject."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x0072806C
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x007280C8 @note "Caller sets CurrentStar. Requires an unassigned GraphObject."
    procedure RespawnIfOutsideSystem; // @addr 0x007281F8
    procedure PrepareTurnMovement(StartStepIndex: Integer; RecordFilm: Boolean); // @addr 0x00728228
    procedure AdvanceOrbitStep(StepIndex: Integer; RecordFilm: Boolean); // @addr 0x00728278
    procedure Respawn; // @addr 0x007282C0 @note "Keeps the ID and visual. May spawn another asteroid under the galaxy's special mode."
    procedure SpawnSiblingAsteroidInCurrentStar; // @addr 0x0072855C @note "The new asteroid belongs to CurrentStar.Asteroids; it does not copy this asteroid's visual or motion."
    procedure IntegrateMotion(TimeScale: Single); // @addr 0x00728760
    procedure WritePredictedPositions(Positions: PPointF; Count: Integer); // @addr 0x00728898 @note "Writes Count future positions at TimeScale=1, excluding the current position, then restores the live motion state. Caller supplies Count * 8 bytes."
    function GetDisplayName: WideString; // @addr 0x00728944
    function GetInfoText: WideString; // @addr 0x00728A10
  end;

const
  AsteroidGravitationalConstant: Single = 6.672041391597716e-11; // @addr $810054

implementation

uses Classes, Math, SE_Process, Globals, aMyFunction, EC_Str, EC_Mem, aConst, aPlayer, aShip, GR_Main, aGalaxyStruct;


const
  AsteroidCentralMass = 2e30 - 137438953472.0;
  AsteroidWorldScale = 5.9999999999999999993e-9;
  AsteroidInverseScaleSquared = 27777777777777777.78;

{ @routine $727F8C TAsteroid_Create }
constructor TAsteroid.Create;
begin
  inherited Create;
  if Galaxy <> nil then
  begin
    Id := Galaxy.NextAsteroidId;
    Inc(Galaxy.NextAsteroidId);
  end;
end;
{ @end $727F8C }

{ @routine $727FE4 TAsteroid_Destroy }
destructor TAsteroid.Destroy;
begin
  if GraphObject <> nil then ReleaseSpaceObject(GraphObject);
  inherited Destroy;
end;
{ @end $727FE4 }

{ @routine $728018 TAsteroid_Init }
procedure TAsteroid.Init(Star: TStar; const GraphKey: WideString);
begin
  CurrentStar := Star;
  RetainSpaceObject(GraphObject, CreateSpaceObjectByName('Asteroid', GraphKey, Classes.Point(0, 0)));
  Respawn;
end;
{ @end $728018 }

{ @routine $72806C TAsteroid_SaveToBuffer }
procedure TAsteroid.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddDWord(Id);
  Buffer.AddWideStringZ(GraphObject.GraphKey);
  Buffer.AddSingle(PhysicsPosition.X);
  Buffer.AddSingle(PhysicsPosition.Y);
  Buffer.AddSingle(Velocity.X);
  Buffer.AddSingle(Velocity.Y);
  Buffer.AddSingle(Mass);
  Buffer.AddIntegerValue(MineralCount);
end;
{ @end $72806C }

{ @routine $7280C8 TAsteroid_LoadFromBuffer }
procedure TAsteroid.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  Id := Buffer.GetUInt32;
  if Galaxy.NextAsteroidId <= Id then Galaxy.NextAsteroidId := Id + 1;
  RetainSpaceObject(GraphObject, TAsteroidSE.Create(Buffer.ReadWideString, Classes.Point(0, 0)));
  PhysicsPosition.X := Buffer.GetSingle;
  PhysicsPosition.Y := Buffer.GetSingle;
  Velocity.X := Buffer.GetSingle;
  Velocity.Y := Buffer.GetSingle;
  Mass := Buffer.GetSingle;
  InverseMass := 1 / Mass;
  GravityForceFactor := AsteroidGravitationalConstant * Mass * AsteroidCentralMass;
  MineralCount := Buffer.GetInt32;
  Position.X := PhysicsPosition.X * AsteroidWorldScale;
  Position.Y := PhysicsPosition.Y * AsteroidWorldScale;
end;
{ @end $7280C8 }

{ @routine $7281F8 TAsteroid_RespawnIfOutsideSystem }
procedure TAsteroid.RespawnIfOutsideSystem;
begin
  if Position.X * Position.X + Position.Y * Position.Y > Sqr(CurrentStar.MapDiameter) then Respawn;
end;
{ @end $7281F8 }

{ @routine $728228 TAsteroid_PrepareTurnMovement }
procedure TAsteroid.PrepareTurnMovement(StartStepIndex: Integer; RecordFilm: Boolean);
begin
  if RecordFilm then
  begin
    FilmObject := PrimaryFilm.AddObject(Id, GraphObject);
    PrimaryFilm.SetObjectPosition(StartStepIndex, FilmObject, Position);
    PrimaryFilm.AttachObject(StartStepIndex, FilmObject);
  end;
end;
{ @end $728228 }

{ @routine $728278 TAsteroid_AdvanceOrbitStep }
procedure TAsteroid.AdvanceOrbitStep(StepIndex: Integer; RecordFilm: Boolean);
begin
  IntegrateMotion(BaseMovementStepsPerTurn / CurrentStar.MovementStepCount);
  if RecordFilm then PrimaryFilm.SetObjectPosition(StepIndex, FilmObject, Position);
end;
{ @end $728278 }

{ @routine $7282C0 TAsteroid_Respawn }
procedure TAsteroid.Respawn;
var
  Angle, Radius, Speed, Reserved: Single; // Native reserves one additional scalar slot.
begin
  Mass := 1000000;
  InverseMass := 1 / Mass;
  GravityForceFactor := AsteroidGravitationalConstant * Mass * AsteroidCentralMass;
  Angle := HeadingDegreesToRadians(NextRandomIntRange(0, 360, CurrentStar.RandomState));
  Radius := CurrentStar.MapDiameter / 2 + 800 + 2000;
  Radius := Radius + NextRandomIntRange(0, 1000, CurrentStar.RandomState);
  if Radius > CurrentStar.MapDiameter then Radius := CurrentStar.MapDiameter - 50 - NextRandomIntRange(0, 100, CurrentStar.RandomState);
  Position.X := Sin(Angle) * Radius;
  Position.Y := -Cos(Angle) * Radius;
  PhysicsPosition.X := Position.X * (1 / AsteroidWorldScale);
  PhysicsPosition.Y := Position.Y * (1 / AsteroidWorldScale);
  Speed := NextRandomIntRange(0, 3000, CurrentStar.RandomState) + 7000;
  Angle := ArcTan2(0.0 - Position.X, -(0.0 - Position.Y));
  Angle := Angle + HeadingDegreesToRadians(NextRandomIntRange(-10, 10, CurrentStar.RandomState) + 25) *
    (2 * NextRandomIntRange(0, 1, CurrentStar.RandomState) - 1);
  Velocity.X := Sin(Angle) * Speed;
  Velocity.Y := -Cos(Angle) * Speed;
  MineralCount := NextRandomIntRange(20, 99, CurrentStar.RandomState);
  if Galaxy <> nil then
    if GetPlayer <> nil then
      if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then
        if (Galaxy.GodModEnabled = 2) and (NextRandomIntRange(0, 100, CurrentStar.RandomState) > 50) then
          SpawnSiblingAsteroidInCurrentStar;
end;
{ @end $7282C0 }

{ @routine $72855C TAsteroid_SpawnSiblingAsteroidInCurrentStar }
procedure TAsteroid.SpawnSiblingAsteroidInCurrentStar;
var
  Asteroid: TAsteroid;
  Text: WideString;
  Index, VariantCount, Variant: Integer;
begin
  if CurrentStar.BackgroundImage < 10 then Text := GameDataConfig.GetBlockByPath('StyleAsteroid').GetParam('0' + IntToWideString(CurrentStar.BackgroundImage))
  else Text := GameDataConfig.GetBlockByPath('StyleAsteroid').GetParam(IntToWideString(CurrentStar.BackgroundImage));
  Index := NextRandomIntRange(0, CountDelimitedPartsW(Text, ',') div 2 - 1, CurrentStar.RandomState) * 2;
  VariantCount := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, Index + 1, ','));
  Text := ExtractDelimitedPartW(Text, Index, ',');
  Variant := NextRandomIntRange(0, VariantCount - 1, CurrentStar.RandomState);
  Asteroid := TAsteroid.Create;
  if Variant < 10 then Asteroid.Init(CurrentStar, 'Asteroid.' + Text + '0' + IntToWideString(Variant))
  else Asteroid.Init(CurrentStar, 'Asteroid.' + Text + IntToWideString(Variant));
  CurrentStar.Asteroids.Add(Asteroid);
end;
{ @end $72855C }

{ @routine $728760 TAsteroid_IntegrateMotion }
procedure TAsteroid.IntegrateMotion(TimeScale: Single);
var
  ForceY, ForceX, DeltaY, DeltaX, AccelY, AccelX, InverseDistance, Force, DistanceSquared: Single;
begin
  DeltaX := 0.0 - Position.X;
  DeltaY := 0.0 - Position.Y;
  DistanceSquared := DeltaX * DeltaX + DeltaY * DeltaY;
  InverseDistance := 1 / Sqrt(DistanceSquared);
  if DistanceSquared < 10000 then DistanceSquared := 10000;
  Force := GravityForceFactor / (DistanceSquared * AsteroidInverseScaleSquared);
  ForceX := DeltaX * InverseDistance * Force;
  ForceY := DeltaY * InverseDistance * Force;
  AccelX := ForceX * InverseMass;
  AccelY := ForceY * InverseMass;
  Velocity.X := Velocity.X + AccelX * TimeScale * 19968;
  Velocity.Y := Velocity.Y + AccelY * TimeScale * 19968;
  PhysicsPosition.X := PhysicsPosition.X + Velocity.X * TimeScale * 19968;
  PhysicsPosition.Y := PhysicsPosition.Y + Velocity.Y * TimeScale * 19968;
  Position.X := PhysicsPosition.X * AsteroidWorldScale;
  Position.Y := PhysicsPosition.Y * AsteroidWorldScale;
end;
{ @end $728760 }

{ @routine $728898 TAsteroid_WritePredictedPositions }
procedure TAsteroid.WritePredictedPositions(Positions: PPointF; Count: Integer);
var
  SavedPosition, SavedPhysicsPosition, SavedVelocity: TPointF;
  Index: Integer;
begin
  SavedPosition := Position;
  SavedPhysicsPosition := PhysicsPosition;
  SavedVelocity := Velocity;
  for Index := 0 to Count - 1 do
  begin
    IntegrateMotion(1);
    WriteSingleEC(Positions, Position.X);
    Positions := AddPointerOffset(Positions, 4);
    WriteSingleEC(Positions, Position.Y);
    Positions := AddPointerOffset(Positions, 4);
  end;
  Position := SavedPosition;
  PhysicsPosition := SavedPhysicsPosition;
  Velocity := SavedVelocity;
end;
{ @end $728898 }

{ @routine $728944 TAsteroid_GetDisplayName }
function TAsteroid.GetDisplayName: WideString;
begin
  Result := LocalizedText('Asteroid.Name');
  ReplaceTextToken(Result, '<Number>', IntToWideString(Id), TextHighlightColorTag);
end;
{ @end $728944 }

{ @routine $728A10 TAsteroid_GetInfoText }
function TAsteroid.GetInfoText: WideString;
var Speed: Single;
begin
  Result := LocalizedText('Asteroid.Text');
  ReplaceTextToken(Result, '<Number>', IntToWideString(Id), TextHighlightColorTag);
  Speed := Sqrt(Sqr(Velocity.X) + Sqr(Velocity.Y));
  Speed := Speed * BaseMovementStepsPerTurn * 19968 * AsteroidWorldScale;
  ReplaceTextToken(Result, '<Speed>', IntToWideString(Round(Speed)), TextHighlightColorTag);
  ReplaceTextToken(Result, '<Count>', IntToWideString(MineralCount), TextHighlightColorTag);
end;
{ @end $728A10 }

end.
