unit SE_Sputnik;
// Unit bracket (inferred): .text 0x006C45FC..0x006C4FAB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    OrbitTimer: PCallbackTimerGI; // @offset 0xAC
    RotationTimer: PCallbackTimerGI; // @offset 0xB0

    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr 0x6C46C4 @note "Does nothing when satellite graphics are disabled."
    procedure DetachFromSpace; override; // @addr 0x6C47E0
    procedure SetOrbitCenter(Center: TPointF); override; // @addr 0x6C4874 @slot 0x18 @ida "void __usercall $name(TSputnikSE *Self@<eax>, TPointF *Center@<edx>);"
    function GetOrbitCenter: TPointF; override; // @addr 0x6C48A4 @slot 0x1C @ida "void __usercall $name(TSputnikSE *Self@<eax>, TPointF *Result@<edx>);"
    function BuildStateBuffer: TBufEC; override; // @addr 0x6C48C8 @slot 0x38 @calls "0x76A417" @note "Returns a new buffer owned by the caller; excludes OrbitAngle."
    procedure LoadStateBuffer(Buffer: TBufEC); override; // @addr 0x6C497C @slot 0x3C @calls "0x76A4F0" @note "Rewinds Buffer to zero and rebuilds the orbit transform and display position."
    procedure RebuildOrbitTransform; // @addr 0x6C4A3C
    procedure UpdateOrbitDisplay; // @addr 0x6C4B0C @note "Requires a nonzero depth range when attached; updates position, apparent radius and drawing depth."
    procedure AdvanceOrbitTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x6C4E34
    procedure AdvanceRotationTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x6C4E74
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr 0x6C4EB0
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr 0x6C4F2C
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr 0x6C4F48
  end;

implementation

uses Math, GlobalsV, Globals, GR_Main, aMyFunction, Types;
{ @routine $6C46C4 TSputnikSE_AttachToSpace }
procedure TSputnikSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if not SputnikShow then Exit;
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  PlanetControl := TPlanetGI.Create(Space.MapPanel);
  PlanetControl.SetPositionModeW(True);
  PlanetControl.SetPosition(Classes.Point(Trunc(Position.X), Trunc(Position.Y)));
  PlanetControl.SetSurfaceMapOffset(SurfaceMapOffset);
  RebuildOrbitTransform;
  UpdateOrbitDisplay;
  OrbitTimer := Space.Screen.ScheduleCallbackTimer(OrbitTimerInterval, OrbitTimerInterval, AdvanceOrbitTimer);
  RotationTimer := Space.Screen.ScheduleCallbackTimer(RotationTimerInterval, RotationTimerInterval, AdvanceRotationTimer);
end;
{ @end $6C46C4 }

{ @routine $6C47E0 TSputnikSE_DetachFromSpace }
procedure TSputnikSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if OrbitTimer <> nil then
  begin
    Space.Screen.CancelCallbackTimer(OrbitTimer);
    OrbitTimer := nil;
  end;
  if RotationTimer <> nil then
  begin
    Space.Screen.CancelCallbackTimer(RotationTimer);
    RotationTimer := nil;
  end;
  PlanetControl.Free;
  PlanetControl := nil;
  inherited DetachFromSpace;
end;
{ @end $6C47E0 }

{ @routine $6C4874 TSputnikSE_SetOrbitCenter }
procedure TSputnikSE.SetOrbitCenter(Center: TPointF);
begin
  OrbitCenter := Center;
  UpdateOrbitDisplay;
end;
{ @end $6C4874 }

{ @routine $6C48A4 TSputnikSE_GetOrbitCenter }
function TSputnikSE.GetOrbitCenter: TPointF;
begin
  Result := OrbitCenter;
end;
{ @end $6C48A4 }

{ @routine $6C48C8 TSputnikSE_BuildStateBuffer }
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
{ @end $6C48C8 }

{ @routine $6C497C TSputnikSE_LoadStateBuffer }
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
{ @end $6C497C }

{ @routine $6C4A3C TSputnikSE_RebuildOrbitTransform }
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
{ @end $6C4A3C }

{ @routine $6C4B0C TSputnikSE_UpdateOrbitDisplay }
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
  if Cardinal(GameScreenHeight) < 768 then DisplayRadius := Round(DisplayRadius * 800 / 1024);
  LightAngle := Round(ArcTan2(-Position.X, Position.Y) * 180 / 3.1415926 * 256 / 360);
  Index := DisplayRadius - MinimumSatelliteTemplateRadius;
  Template := SatelliteRenderTemplates[Index];
  PlanetControl.SetImageFromTemplate(Template.MaskName, ImagePath, Template.Radius);
  PlanetControl.SetLightAngle(LightAngle);
  PlanetControl.SetPosition(TruncatePointF(Position));
  PlanetControl.SetOrigin(Classes.Point(Template.Radius, Template.Radius));
  if Z < 0 then PlanetControl.SetDepth(DepthOrder + PlanetDepth + 1)
  else PlanetControl.SetDepth(PlanetDepth - DepthOrder - 1);
end;
{ @end $6C4B0C }

{ @routine $6C4E34 TSputnikSE_AdvanceOrbitTimer }
procedure TSputnikSE.AdvanceOrbitTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  OrbitAngle := WrapHeadingDegrees(OrbitAngle + OrbitAngleStep);
  UpdateOrbitDisplay;
end;
{ @end $6C4E34 }

{ @routine $6C4E74 TSputnikSE_AdvanceRotationTimer }
procedure TSputnikSE.AdvanceRotationTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  SurfaceMapOffset := SurfaceMapOffset + SurfaceMapStep;
  PlanetControl.SetSurfaceMapOffset(SurfaceMapOffset);
end;
{ @end $6C4E74 }

{ @routine $6C4EB0 TSputnikSE_LoadTemplate }
procedure TSputnikSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
end;
{ @end $6C4EB0 }

{ @routine $6C4F2C TSputnikSE_ApplyConfig }
procedure TSputnikSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $6C4F2C }

{ @routine $6C4F48 TSputnikSE_QueueImageLoad }
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
{ @end $6C4F48 }

end.
