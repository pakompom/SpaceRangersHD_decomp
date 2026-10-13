unit SE_Sputnik;

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Struct, GI_MessageLoop, GI_Planet, SE_Space;

type
  TSputnikSE = class(TObjectSE) // @size 0xB4
  public
    ImagePath: WideString; // @offset 0x4C
    DepthOrder: Integer; // @offset 0x50  Serialized as a byte; separates overlapping satellites in front of/behind the planet.
    OrbitCenter: TPointF; // @offset 0x54
    OrbitInclination: Single; // @offset 0x5C  Degrees.
    OrbitRotation: Single; // @offset 0x60  Degrees in the display plane.
    OrbitAngleStep: Single; // @offset 0x64
    OrbitTimerInterval: Cardinal; // @offset 0x68
    OrbitRadius: Single; // @offset 0x6C
    MinDisplayRadius: Integer; // @offset 0x70
    MaxDisplayRadius: Integer; // @offset 0x74
    RotationTimerInterval: Cardinal; // @offset 0x78
    SurfaceMapStep: Integer; // @offset 0x7C
    OrbitAngle: Single; // @offset 0x80  Saved separately by TSputnik.SaveToBuffer.
    SurfaceMapOffset: Integer; // @offset 0x84
    DisplayRadius: Integer; // @offset 0x88
    LightAngle: Byte; // @offset 0x8C  A full turn has 256 steps.
    InclinationCos: Single; // @offset 0x90
    InclinationSin: Single; // @offset 0x94
    RotationCos: Single; // @offset 0x98
    RotationSin: Single; // @offset 0x9C
    MinOrbitDepth: Single; // @offset 0xA0
    MaxOrbitDepth: Single; // @offset 0xA4
    PlanetControl: TPlanetGI; // @offset 0xA8  Owned while attached.
    OrbitTimer: TCallbackTimerIdGI; // @offset 0xAC
    RotationTimer: TCallbackTimerIdGI; // @offset 0xB0

    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr 0x00695618 @note "Does nothing when satellite graphics are disabled."
    procedure DetachFromSpace; override; // @addr 0x006956F8
    procedure SetOrbitCenter(Center: TPointF); override; // @addr 0x00695760 @slot 0x18
    function GetOrbitCenter: TPointF; override; // @addr 0x00695784 @slot 0x1C
    function BuildStateBuffer: TBufEC; override; // @addr 0x00695790 @slot 0x38 @note "Returns a new buffer owned by the caller; excludes OrbitAngle."
    procedure LoadStateBuffer(Buffer: TBufEC); override; // @addr 0x0069580C @slot 0x3C @note "Rewinds Buffer to zero and rebuilds the orbit transform and display position."
    procedure RebuildOrbitTransform; // @addr 0x00695898
    procedure UpdateOrbitDisplay; // @addr 0x00695940 @note "Requires a nonzero depth range when attached; updates position, apparent radius and drawing depth."
    procedure AdvanceOrbitTimer(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00695BE8
    procedure AdvanceRotationTimer(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00695C10
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr 0x00695C2C
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr 0x00695C9C
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr 0x00695CA4
  end;

implementation

uses Math, GlobalsV, Globals, GR_Main, aMyFunction, Types;
{ @routine $695618 TSputnikSE_AttachToSpace }
procedure TSputnikSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if not SputnikShow then Exit;
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  PlanetControl := TPlanetGI.Create(Space.MapPanel);
  PlanetControl.World := True;
  PlanetControl.Pos := Classes.Point(Trunc(Position.X), Trunc(Position.Y));
  PlanetControl.SetSurfaceMapOffset(SurfaceMapOffset);
  RebuildOrbitTransform;
  UpdateOrbitDisplay;
  OrbitTimer := Space.Screen.ScheduleCallbackTimer(OrbitTimerInterval, OrbitTimerInterval, AdvanceOrbitTimer);
  RotationTimer := Space.Screen.ScheduleCallbackTimer(RotationTimerInterval, RotationTimerInterval, AdvanceRotationTimer);
end;
{ @end $695618 }

{ @routine $6956F8 TSputnikSE_DetachFromSpace }
procedure TSputnikSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if OrbitTimer <> 0 then
  begin
    Space.Screen.CancelCallbackTimer(OrbitTimer);
    OrbitTimer := 0;
  end;
  if RotationTimer <> 0 then
  begin
    Space.Screen.CancelCallbackTimer(RotationTimer);
    RotationTimer := 0;
  end;
  PlanetControl.Free;
  PlanetControl := nil;
  inherited DetachFromSpace;
end;
{ @end $6956F8 }

{ @routine $695760 TSputnikSE_SetOrbitCenter }
procedure TSputnikSE.SetOrbitCenter(Center: TPointF);
begin
  OrbitCenter := Center;
  UpdateOrbitDisplay;
end;
{ @end $695760 }

{ @routine $695784 TSputnikSE_GetOrbitCenter }
function TSputnikSE.GetOrbitCenter: TPointF;
begin
  Result := OrbitCenter;
end;
{ @end $695784 }

{ @routine $695790 TSputnikSE_BuildStateBuffer }
function TSputnikSE.BuildStateBuffer: TBufEC;
var
  Buffer: TBufEC;
begin
  Buffer := TBufEC.Create;
  Buffer.AddAnsiChar(AnsiChar(DepthOrder));
  Buffer.AddSingle(OrbitInclination);
  Buffer.AddSingle(OrbitRotation);
  Buffer.AddSingle(OrbitAngleStep);
  Buffer.AddDWord(OrbitTimerInterval);
  Buffer.AddSingle(OrbitRadius);
  Buffer.AddIntegerValue(MinDisplayRadius);
  Buffer.AddIntegerValue(MaxDisplayRadius);
  Buffer.AddDWord(RotationTimerInterval);
  Buffer.AddIntegerValue(SurfaceMapStep);
  Result := Buffer;
end;
{ @end $695790 }

{ @routine $69580C TSputnikSE_LoadStateBuffer }
procedure TSputnikSE.LoadStateBuffer(Buffer: TBufEC);
begin
  Buffer.SetPosition(0);
  DepthOrder := Buffer.GetByte;
  OrbitInclination := Buffer.GetSingle;
  OrbitRotation := Buffer.GetSingle;
  OrbitAngleStep := Buffer.GetSingle;
  OrbitTimerInterval := Buffer.GetUInt32;
  OrbitRadius := Buffer.GetSingle;
  MinDisplayRadius := Buffer.GetInt32;
  MaxDisplayRadius := Buffer.GetInt32;
  RotationTimerInterval := Buffer.GetUInt32;
  SurfaceMapStep := Buffer.GetInt32;
  RebuildOrbitTransform;
  UpdateOrbitDisplay;
end;
{ @end $69580C }

{ @routine $695898 TSputnikSE_RebuildOrbitTransform }
procedure TSputnikSE.RebuildOrbitTransform;
var
  Angle: Single;
begin
  Angle := HeadingDegreesToRadians(OrbitRotation);
  RotationCos := Cos(Angle);
  RotationSin := Sin(Angle);
  Angle := HeadingDegreesToRadians(OrbitInclination);
  InclinationCos := Cos(Angle);
  InclinationSin := Sin(Angle);
  MaxOrbitDepth := Abs(-InclinationSin * OrbitRadius);
  MinOrbitDepth := -MaxOrbitDepth;
end;
{ @end $695898 }

{ @routine $695940 TSputnikSE_UpdateOrbitDisplay }
procedure TSputnikSE.UpdateOrbitDisplay;
var
  X, Y, Z, Angle, OrbitX, OrbitY: Single;
  Index: Integer;
  Template: TSputnikTempl;
begin
  if not IsAttachedToSpace then Exit;
  Angle := HeadingDegreesToRadians(OrbitAngle);
  OrbitX := Sin(Angle) * OrbitRadius;
  OrbitY := Cos(Angle) * -OrbitRadius;
  X := InclinationCos * RotationCos * OrbitX + -RotationSin * OrbitY + OrbitCenter.X;
  Y := InclinationCos * RotationSin * OrbitX + OrbitY * RotationCos + OrbitCenter.Y;
  Z := -InclinationSin * OrbitX;
  Position := MakePointF(X, Y);
  DisplayRadius := Round((Z - MinOrbitDepth) / (MaxOrbitDepth - MinOrbitDepth) * (MaxDisplayRadius - MinDisplayRadius) + MinDisplayRadius);
  if DisplayRadius < MinDisplayRadius then DisplayRadius := MinDisplayRadius
  else if DisplayRadius > MaxDisplayRadius then DisplayRadius := MaxDisplayRadius;
  if GameScreenHeight < 768 then DisplayRadius := Round(DisplayRadius * 800 / 1024);
  LightAngle := Round(ArcTan2(-Position.X, Position.Y) * 180 / GamePi * 256 / 360);
  Index := DisplayRadius - MinimumSatelliteTemplateRadius;
  Template := SatelliteRenderTemplates[Index];
  PlanetControl.SetImageFromTemplate(Template.MaskName, ImagePath, Template.Radius);
  PlanetControl.SetLightAngle(LightAngle);
  PlanetControl.Pos := TruncatePointF(Position);
  PlanetControl.Sme := Classes.Point(Template.Radius, Template.Radius);
  if Z < 0 then PlanetControl.SetDepth(DepthOrder + PlanetDepth + 1)
  else PlanetControl.SetDepth(PlanetDepth - DepthOrder - 1);
end;
{ @end $695940 }

{ @routine $695BE8 TSputnikSE_AdvanceOrbitTimer }
procedure TSputnikSE.AdvanceOrbitTimer(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  OrbitAngle := WrapHeadingDegrees(OrbitAngle + OrbitAngleStep);
  UpdateOrbitDisplay;
end;
{ @end $695BE8 }

{ @routine $695C10 TSputnikSE_AdvanceRotationTimer }
procedure TSputnikSE.AdvanceRotationTimer(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  SurfaceMapOffset := SurfaceMapOffset + SurfaceMapStep;
  PlanetControl.SetSurfaceMapOffset(SurfaceMapOffset);
end;
{ @end $695C10 }

{ @routine $695C2C TSputnikSE_LoadTemplate }
procedure TSputnikSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
end;
{ @end $695C2C }

{ @routine $695C9C TSputnikSE_ApplyConfig }
procedure TSputnikSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $695C9C }

{ @routine $695CA4 TSputnikSE_QueueImageLoad }
procedure TSputnikSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Template: TSputnikTempl;
begin
  Template := SatelliteRenderTemplates[0];
  with TPlanetGI.Create(Owner) do
  begin
    SetImageFromTemplate(Template.MaskName, Self.ImagePath, Template.Radius);
    QueueImageLoad(PendingLoads);
    Free;
  end;
end;
{ @end $695CA4 }

end.
