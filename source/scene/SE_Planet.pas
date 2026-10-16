unit SE_Planet;

interface

uses Classes, EC_BlockPar, EC_Struct, GI_AlphaImage, GI_GAI, GI_Image, GI_MessageLoop, GI_Planet, GR_GraphBuf, SE_Space, Types;

type
  PPlanetMapOrbitPoint = ^TPlanetMapOrbitPoint;
  TPlanetMapOrbitPoint = record // @size 0x0C
    Position: TPoint; // @offset 0x00
    PixelOffset: Integer; // @offset 0x08  Byte offset in the minimap's 16-bit pixel buffer.
  end;

  PPlanetCollisionCircle = ^TPlanetCollisionCircle;
  TPlanetCollisionCircle = record // @size 0x18
    Next: PPlanetCollisionCircle; // @offset 0x00
    Prev: PPlanetCollisionCircle; // @offset 0x04
    Position: TPointF; // @offset 0x08
    Radius: Single; // @offset 0x10
    RadiusSquared: Single; // @offset 0x14
  end;

  TPlanetSE = class(TObjectSE) // @size 0x138
  public
    ImagePath: WideString; // @offset 0x4C
    ImageOrigin: TPoint; // @offset 0x50
    SurfaceMapOffset: Integer; // @offset 0x58
    LightAngle: Byte; // @offset 0x5C  A full turn has 256 steps.
    RotationTimerInterval: Cardinal; // @offset 0x60  Milliseconds before conversion to space ticks; saved as a Word by TPlanet.
    SurfaceMapStep: Integer; // @offset 0x64
    MinimapImagePath: WideString; // @offset 0x68
    MinimapImageOrigin: TPoint; // @offset 0x6C
    OrbitalVelocity: Double; // @offset 0x78
    Radius: Integer; // @offset 0x80
    Cloud1ImagePath: WideString; // @offset $84
    Cloud1RelativeRotationSpeed: Single; // @offset $88
    Cloud1MapStep: Integer; // @offset $8C
    Cloud1Timer: PSpaceTimerSE; // @offset $90
    Cloud1MapOffset: Integer; // @offset $94
    Cloud2ImagePath: WideString; // @offset $98
    Cloud2RelativeRotationSpeed: Single; // @offset $9C
    Cloud2MapStep: Integer; // @offset $A0
    Cloud2Timer: PSpaceTimerSE; // @offset $A4
    Cloud2MapOffset: Integer; // @offset $A8
    Cloud3ImagePath: WideString; // @offset $AC
    Cloud3RelativeRotationSpeed: Single; // @offset $B0
    Cloud3MapStep: Integer; // @offset $B4
    Cloud3Timer: PSpaceTimerSE; // @offset $B8
    Cloud3MapOffset: Integer; // @offset $BC
    AtmosphereColor: Cardinal; // @offset 0xC0  0x00BBGGRR.
    SpaceConfigValues: array[0..2] of Integer; // @offset $C4 Water, land and hill exploration tile counts copied by planet generation.
    BackgroundGraph: WideString; // @offset 0xD0
    QuestEnabled: Boolean; // @offset 0xD4  Template's Quest parameter.
    RingKind: Byte; // @offset 0xD5  PlanetRing resource selector; 0 disables rings. Kinds 1/4/5 also select animation families.
    Civilized: Boolean; // @offset $D6 Film playback sets this from MinimapOwner <> 6.
    SurfaceAnimationMask: Integer; // @offset 0xD8
    SurfaceAnimationIndex: Integer; // @offset 0xDC
    PlanetControl: TPlanetGI; // @offset 0xE0
    RingControl1: TImageGI; // @offset 0xE4
    RingControl2: TImageGI; // @offset 0xE8
    MinimapControl: TAlphaImageGI; // @offset 0xEC
    RotationTimer: PSpaceTimerSE; // @offset 0xF0
    LegacySurfaceControl: TObjectGI; // @offset 0xF4  No creation/assignment path found in this build; only positioned, freed and cleared. Concrete descendant cannot be recovered.
    SurfaceImageControl: TImageGI; // @offset 0xF8
    SurfaceAnimationFrame: Integer; // @offset 0xFC
    SurfaceAnimationOffset: TPoint; // @offset 0x100
    MapOrbitPointCount: Integer; // @offset 0x108
    MapOrbitPoints: PPlanetMapOrbitPoint; // @offset 0x10C  Owned raw allocation.
    CollisionCircle: PPlanetCollisionCircle; // @offset 0x110
    MinimapOwner: Byte; // @offset 0x114  0..7 use owner names; higher values select numbered icons.
    RuinsAnimationPath: WideString; // @offset 0x118
    RuinsImagePath: WideString; // @offset 0x11C
    RuinsMinimapPath: WideString; // @offset 0x120
    RuinsAnimationControl: TgaiGI; // @offset 0x124
    RuinsImageControl: TImageGI; // @offset 0x128
    RuinsMinimapControl: TImageGI; // @offset 0x12C
    RuinsAnimationFrame: Integer; // @offset 0x130
    IsRuins: Boolean; // @offset 0x134  GraphKey starts with Ruins.

    constructor Create; // @addr 0x00691920
    constructor CreateFromGraph(const AGraphKey: WideString; UnusedPosition: TPoint); // @addr 0x00691958
    procedure CopyTo(Destination: TObjectSE); override; // @addr 0x006919D4 @slot 0x00 @note "Destination must be a TPlanetSE. Copies configuration, not attached controls/timers."
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr 0x00691B84
    procedure DetachFromSpace; override; // @addr 0x006927E4
    procedure RebuildRings; // @addr 0x0069299C
    procedure RebuildSurfaceAnimation; // @addr 0x00692EC0
    procedure StartRandomSurfaceAnimation; // @addr 0x00693038 @note "Requires an allocated image control and a mask with positive total animation weight."
    procedure SetMinimapOwner(Owner: Byte); // @addr 0x00693224
    procedure SetPosition(APosition: TPointF); override; // @addr 0x0069337C
    procedure SetSurfaceMapOffset(Value: Integer); // @addr 0x0069358C
    procedure SetCloud1MapOffset(Value: Integer); // @addr 0x006935B8
    procedure SetCloud2MapOffset(Value: Integer); // @addr 0x006935E8
    procedure SetCloud3MapOffset(Value: Integer); // @addr 0x00693618
    procedure SetLightAngle(Value: Byte); // @addr 0x00693648
    procedure SetRotationTimerInterval(Value: Cardinal); // @addr 0x00693674
    procedure SetSurfaceMapStep(Value: Integer); // @addr 0x00693B4C
    procedure SetRingKind(Kind: Byte); // @addr 0x00693B50 @note "Does nothing for ruins; rebuilds rings when attached to space."
    procedure SetSurfaceAnimationMask(Mask: Integer); // @addr 0x00693B78 @note "Does nothing for ruins; rebuilds the animation when attached to space."
    procedure UpdateLightAngleFromStar; // @addr 0x00693BA0
    procedure SurfaceAnimationFinished(Sender: TObjectGI); // @addr 0x00693C40
    procedure AdvanceRotationTimer(Timer: PSpaceTimerSE; UserData: Integer); // @addr 0x00693D68
    procedure AdvanceCloudTimer(Timer: PSpaceTimerSE; UserData: Integer); // @addr 0x00693D80 @note "UserData selects cloud 1..3."
    function HitTestCursor: Boolean; override; // @addr 0x00693E24
    procedure DrawMap; override; // @addr 0x00693E94
    procedure RenderToBuffer(Screen: TMessageLoopGI; Buffer: TGraphBufGR; SmallPreview: Boolean); // @addr 0x00694908 @note "SmallPreview affects detached normal planets only. Attached planets reuse their current surface renderer; ruins use their static image."
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr 0x00694BEC
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr 0x00695158
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr 0x00695340
  end;

function AllocatePlanetCollisionCircle: PPlanetCollisionCircle; // @addr 0x006954F4 @note "Links a new entry at the head; only links are initialized."
procedure FreePlanetCollisionCircle(Entry: PPlanetCollisionCircle); // @addr 0x0069551C

var
  FirstPlanetCollisionCircle: PPlanetCollisionCircle = nil; // @addr 0x0080F804

implementation

uses SysUtils, Math, EC_Str, SE_Star, GlobalsV, Globals, GR_Main, GI_Main, aConst, aMyFunction, EC_Mem, EC_Cache, EC_CacheBitmap, Windows, SE_Process;
{ @routine $691920 TPlanetSE_Create }
constructor TPlanetSE.Create;
begin
  inherited CreateEmpty;
end;
{ @end $691920 }

{ @routine $691958 TPlanetSE_CreateFromGraph }
constructor TPlanetSE.CreateFromGraph(const AGraphKey: WideString; UnusedPosition: TPoint);
begin
  IsRuins := FindTextOffsetW(AGraphKey, 'Ruins') = 0;
  inherited Create(AGraphKey, UnusedPosition);
end;
{ @end $691958 }

{ @routine $6919D4 TPlanetSE_CopyTo }
procedure TPlanetSE.CopyTo(Destination: TObjectSE);
begin
  inherited CopyTo(Destination);
  with Destination as TPlanetSE do
  begin
    ImagePath := Self.ImagePath;
    ImageOrigin := Self.ImageOrigin;
    SurfaceMapOffset := Self.SurfaceMapOffset;
    LightAngle := Self.LightAngle;
    RotationTimerInterval := Self.RotationTimerInterval;
    SurfaceMapStep := Self.SurfaceMapStep;
    MinimapImagePath := Self.MinimapImagePath;
    MinimapImageOrigin := Self.MinimapImageOrigin;
    OrbitalVelocity := Self.OrbitalVelocity;
    Radius := Self.Radius;
    RingKind := Self.RingKind;
    MinimapOwner := Self.MinimapOwner;
    Cloud1ImagePath := Self.Cloud1ImagePath;
    Cloud1RelativeRotationSpeed := Self.Cloud1RelativeRotationSpeed;
    Cloud1MapOffset := Self.Cloud1MapOffset;
    Cloud2ImagePath := Self.Cloud2ImagePath;
    Cloud2RelativeRotationSpeed := Self.Cloud2RelativeRotationSpeed;
    Cloud2MapOffset := Self.Cloud2MapOffset;
    Cloud3ImagePath := Self.Cloud3ImagePath;
    Cloud3RelativeRotationSpeed := Self.Cloud3RelativeRotationSpeed;
    Cloud3MapOffset := Self.Cloud3MapOffset;
    AtmosphereColor := Self.AtmosphereColor;
    SpaceConfigValues[0] := Self.SpaceConfigValues[0];
    SpaceConfigValues[1] := Self.SpaceConfigValues[1];
    SpaceConfigValues[2] := Self.SpaceConfigValues[2];
    BackgroundGraph := Self.BackgroundGraph;
    QuestEnabled := Self.QuestEnabled;
    IsRuins := Self.IsRuins;
    RuinsAnimationPath := Self.RuinsAnimationPath;
    RuinsImagePath := Self.RuinsImagePath;
    RuinsMinimapPath := Self.RuinsMinimapPath;
    RuinsAnimationFrame := Self.RuinsAnimationFrame;
  end;
end;
{ @end $6919D4 }

{ @routine $691B84 TPlanetSE_AttachToSpace }
procedure TPlanetSE.AttachToSpace(ASpace: TSpaceSE);
var
  Template: TPlanetTempl;
  Index, Count, Interval, OwnerIndex: Integer;
begin
  if IsAttachedToSpace then Exit;
  if Civilized then ConfigureLoopSound('Planet.Civil') else ConfigureLoopSound('Planet.NotCivil');
  if Civilized then ConfigureRandomSound('Planet.Civil') else ConfigureRandomSound('Planet.NotCivil');
  inherited AttachToSpace(ASpace);
  if IsRuins then
  begin
    if AnimShipFull or (CurrentScreenId = screen_arcade_battle) then
    begin
      RuinsAnimationControl := TgaiGI.Create(Space.MapPanel);
      RuinsAnimationControl.SetImagePath(RuinsAnimationPath);
      RuinsAnimationControl.ObjectSize := RuinsAnimationControl.GetContentSize;
      RuinsAnimationControl.Sme := HalfPoint(RuinsAnimationControl.ClientSize);
      RuinsAnimationControl.SetDepthByName(DepthExpression);
      RuinsAnimationControl.Pos := TruncatePointF(Position);
      RuinsAnimationControl.World := True;
      RuinsAnimationControl.SequenceIndex := 0;
      RuinsAnimationControl.UpdateAutoGeometry;
      RuinsAnimationControl.SetSequenceFrame(RuinsAnimationFrame);
      RuinsAnimationControl.RestartPlayback;
      RuinsAnimationControl.SetAlpha(255);
      Size := RuinsAnimationControl.ClientSize;
    end
    else
    begin
      RuinsImageControl := TImageGI.Create(Space.MapPanel);
      RuinsImageControl.ImageSourcePath := RuinsImagePath;
      RuinsImageControl.ObjectSize := RuinsImageControl.GetContentSize;
      RuinsImageControl.Sme := HalfPoint(RuinsImageControl.ClientSize);
      RuinsImageControl.SetDepthByName(DepthExpression);
      RuinsImageControl.Pos := TruncatePointF(Position);
      RuinsImageControl.World := True;
      RuinsImageControl.SetAlpha(255);
      Size := RuinsImageControl.ClientSize;
    end;
    RuinsMinimapControl := TImageGI.Create(SpaceObjectUiLoop.ContentPanel);
    RuinsMinimapControl.World := True;
    RuinsMinimapControl.SetDepthByName(DepthExpression);
    RuinsMinimapControl.Pos := TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale));
    RuinsMinimapControl.ImageSourcePath := RuinsMinimapPath;
    RuinsMinimapControl.ObjectSize := RuinsMinimapControl.GetContentSize;
    RuinsMinimapControl.Sme := HalfPoint(RuinsMinimapControl.ClientSize);
  end
  else
  begin
    Template := nil;
    Count := PlanetRenderTemplates.Count;
    for Index := 0 to Count - 1 do
    begin
      Template := PlanetRenderTemplates[Index];
      if Template.Radius = Radius then Break;
    end;
    if Template = nil then raise Exception.Create('Error in TPlanetSE.Connect');
    PlanetControl := TPlanetGI.Create(Space.MapPanel);
    PlanetControl.World := True;
    PlanetControl.SetDepthByName(DepthExpression);
    PlanetControl.Pos := Classes.Point(Trunc(Position.X), Trunc(Position.Y));
    PlanetControl.SetSurfaceMapOffset(SurfaceMapOffset);
    PlanetControl.Sme := ImageOrigin;
    PlanetControl.SetImageWithRadius(Template.MaskName, ImagePath, Template.LightName, Radius);
    if PlanetClouds then
    begin
      if Cloud1ImagePath <> '' then PlanetControl.SetCloud1Image(Cloud1ImagePath);
      if Cloud2ImagePath <> '' then PlanetControl.SetCloud2Image(Cloud2ImagePath);
      if Cloud3ImagePath <> '' then PlanetControl.SetCloud3Image(Cloud3ImagePath);
      PlanetControl.SetCloud1MapOffset(Cloud1MapOffset);
      PlanetControl.SetCloud2MapOffset(Cloud2MapOffset);
      PlanetControl.SetCloud3MapOffset(Cloud3MapOffset);
    end;
    PlanetControl.SetLightAngle(LightAngle);
    if PlanetAtm and (AtmosphereColor <> 0) then
    begin
      PlanetControl.SetAtmosphere('Bm.Atm.' + GiResourceSuffix + 'atm' + IntToStr(Radius * 2),
        'Bm.Atm.' + GiResourceSuffix + 'mask' + IntToStr(Radius * 2), AtmosphereColor);
      PlanetControl.Sme := HalfPoint(PlanetControl.ClientSize);
    end;
    MinimapControl := TAlphaImageGI.Create(SpaceObjectUiLoop.ContentPanel);
    MinimapControl.World := True;
    MinimapControl.SetDepthByName(DepthExpression);
    MinimapControl.Pos := TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale));
    MinimapControl.Sme := MinimapImageOrigin;
    if MinimapOwner <= 7 then
      MinimapControl.SetImagePath('Bm.Planet.M.' + OwnerInfo[TOwnerId(MinimapOwner)].InternalName)
    else
    begin
      OwnerIndex := MinimapOwner - 7 - 1;
      if OwnerIndex <= 9 then MinimapControl.SetImagePath('Bm.Planet.M.0' + IntToWideString(OwnerIndex))
      else MinimapControl.SetImagePath('Bm.Planet.M.' + IntToWideString(OwnerIndex));
    end;
    MinimapControl.ObjectSize := MinimapControl.GetContentSize;
    UpdateLightAngleFromStar;
    CollisionCircle := AllocatePlanetCollisionCircle;
    CollisionCircle.Position.X := Position.X;
    CollisionCircle.Position.Y := Position.Y;
    CollisionCircle.Radius := Radius;
    RebuildRings;
    RebuildSurfaceAnimation;
    RotationTimer := Space.CreateTimer(0, RotationTimerInterval, AdvanceRotationTimer, 0);
    if PlanetClouds then
    begin
      if (Cloud1ImagePath <> '') and (Cloud1RelativeRotationSpeed <> -1) then
      begin
        if Cloud1RelativeRotationSpeed > -1 then
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (1 + Cloud1RelativeRotationSpeed))));
          Cloud1MapStep := 1;
        end
        else
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (-Cloud1RelativeRotationSpeed - 1))));
          Cloud1MapStep := -1;
        end;
        Cloud1Timer := Space.CreateTimer(0, Abs(Interval), AdvanceCloudTimer, 1);
      end;
      if (Cloud2ImagePath <> '') and (Cloud2RelativeRotationSpeed <> -1) then
      begin
        if Cloud2RelativeRotationSpeed > -1 then
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (1 + Cloud2RelativeRotationSpeed))));
          Cloud2MapStep := 1;
        end
        else
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (-Cloud2RelativeRotationSpeed - 1))));
          Cloud2MapStep := -1;
        end;
        Cloud2Timer := Space.CreateTimer(0, Abs(Interval), AdvanceCloudTimer, 2);
      end;
      if (Cloud3ImagePath <> '') and (Cloud3RelativeRotationSpeed <> -1) then
      begin
        if Cloud3RelativeRotationSpeed > -1 then
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (1 + Cloud3RelativeRotationSpeed))));
          Cloud3MapStep := 1;
        end
        else
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (-Cloud3RelativeRotationSpeed - 1))));
          Cloud3MapStep := -1;
        end;
        Cloud3Timer := Space.CreateTimer(0, Abs(Interval), AdvanceCloudTimer, 3);
      end;
    end;
    Size := Classes.Point((Radius + 5) * 2, (Radius + 5) * 2);
  end;
end;
{ @end $691B84 }

{ @routine $6927E4 TPlanetSE_DetachFromSpace }
procedure TPlanetSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if IsRuins then
  begin
    if RuinsAnimationControl <> nil then
    begin
      RuinsAnimationFrame := RuinsAnimationControl.SequenceFrame;
      RuinsAnimationControl.Free;
      RuinsAnimationControl := nil;
    end;
    if RuinsImageControl <> nil then
    begin
      RuinsImageControl.IsActive := False;
      RuinsImageControl.Free;
      RuinsImageControl := nil;
    end;
    if RuinsMinimapControl <> nil then
    begin
      RuinsMinimapControl.Free;
      RuinsMinimapControl := nil;
    end;
  end
  else
  begin
    FreePlanetCollisionCircle(CollisionCircle);
    CollisionCircle := nil;
    if MapOrbitPoints <> nil then
    begin
      FreeEC(MapOrbitPoints);
      MapOrbitPoints := nil;
    end;
    if RotationTimer <> nil then
    begin
      Space.DeleteTimer(RotationTimer);
      RotationTimer := nil;
    end;
    if Cloud1Timer <> nil then
    begin
      Space.DeleteTimer(Cloud1Timer);
      Cloud1Timer := nil;
    end;
    if Cloud2Timer <> nil then
    begin
      Space.DeleteTimer(Cloud2Timer);
      Cloud2Timer := nil;
    end;
    if Cloud3Timer <> nil then
    begin
      Space.DeleteTimer(Cloud3Timer);
      Cloud3Timer := nil;
    end;
    Space.MapPanel.FreeOwnedChild(PlanetControl);
    PlanetControl := nil;
    if RingControl1 <> nil then
    begin
      RingControl1.Free;
      RingControl1 := nil;
    end;
    if RingControl2 <> nil then
    begin
      RingControl2.Free;
      RingControl2 := nil;
    end;
    if LegacySurfaceControl <> nil then
    begin
      LegacySurfaceControl.Free;
      LegacySurfaceControl := nil;
    end;
    if SurfaceImageControl <> nil then
    begin
      SurfaceImageControl.Free;
      SurfaceImageControl := nil;
    end;
    if MinimapControl <> nil then
    begin
      MinimapControl.Free;
      MinimapControl := nil;
    end;
  end;
  inherited DetachFromSpace;
end;
{ @end $6927E4 }

{ @routine $69299C TPlanetSE_RebuildRings }
procedure TPlanetSE.RebuildRings;
var
  Path: WideString;
  Center, Offset: TPoint;
  Bounds, FirstBounds, SecondBounds: TRect;
begin
  if IsRuins then Exit;
  if RingControl1 <> nil then
  begin
    RingControl1.Free;
    RingControl1 := nil;
  end;
  if RingControl2 <> nil then
  begin
    RingControl2.Free;
    RingControl2 := nil;
  end;
  if RingKind <> 0 then
  begin
    Path := 'GI,Bm.PlanetRing.' + GiResourceSuffix + 'r';
    if RingKind - 1 < 10 then Path := Path + '0';
    Path := Path + IntToStr(RingKind - 1) + '_';
    if RingKind >= 20 then Path := Path + '0'
    else if Radius = 100 then Path := Path + '0'
    else if Radius = 90 then Path := Path + '1'
    else if Radius = 80 then Path := Path + '2'
    else if Radius = 70 then Path := Path + '3'
    else if Radius = 60 then Path := Path + '4'
    else RaiseWideMessage('TPlanetSE.CreateRing');
    RingControl1 := TImageGI.Create(Space.MapPanel);
    RingControl1.World := True;
    RingControl1.SetDepth(PlanetControl.Depth - 0.01);
    RingControl1.ImageSourcePath := Path + '_1';
    RingControl1.ObjectSize := RingControl1.GetContentSize;
    RingControl1.Pos := PlanetControl.LocalPosition;
    RingControl2 := TImageGI.Create(Space.MapPanel);
    RingControl2.World := True;
    RingControl2.SetDepth(PlanetControl.Depth + 0.01);
    RingControl2.ImageSourcePath := Path + '_2';
    RingControl2.ObjectSize := RingControl2.GetContentSize;
    RingControl2.Pos := PlanetControl.LocalPosition;
    FirstBounds.TopLeft := RingControl1.GetContentOrigin;
    FirstBounds.BottomRight := AddPoints(FirstBounds.TopLeft, RingControl1.ClientSize);
    SecondBounds.TopLeft := RingControl2.GetContentOrigin;
    SecondBounds.BottomRight := AddPoints(SecondBounds.TopLeft, RingControl2.ClientSize);
    Windows.UnionRect(Bounds, FirstBounds, SecondBounds);
    Center := Classes.Point((Bounds.Right + Bounds.Left) div 2, (Bounds.Bottom + Bounds.Top) div 2);
    Offset := Classes.Point(0, Bounds.Right div 2 - Bounds.Bottom div 2);
    if RingKind = 8 then Inc(Offset.Y, GiScalePixels(10));
    if RingKind = 8 then Inc(Offset.X, GiScalePixels(5));
    if RingKind = 21 then Inc(Offset.Y, GiScalePixels(25))
    else if RingKind = 22 then Inc(Offset.Y, GiScalePixels(15));
    if RingKind = 21 then Dec(Offset.X, GiScalePixels(8))
    else if RingKind = 22 then Dec(Offset.X, GiScalePixels(5));
    RingControl1.Sme := SubtractPoints(SubtractPoints(Center, FirstBounds.TopLeft), Offset);
    RingControl2.Sme := SubtractPoints(SubtractPoints(Center, SecondBounds.TopLeft), Offset);
  end;
end;
{ @end $69299C }

{ @routine $692EC0 TPlanetSE_RebuildSurfaceAnimation }
procedure TPlanetSE.RebuildSurfaceAnimation;
var
  Scale: Single;
begin
  if IsRuins then Exit;
  if LegacySurfaceControl <> nil then
  begin
    LegacySurfaceControl.Free;
    LegacySurfaceControl := nil;
  end;
  if SurfaceImageControl <> nil then
  begin
    SurfaceImageControl.Free;
    SurfaceImageControl := nil;
  end;
  if (SurfaceAnimationMask > 0) and (GiResourceVariant = 2) and (Radius = 100) then
  begin
    SurfaceAnimationIndex := -1;
    Scale := (Radius - 60) / 40 * 0.7 + 0.3;
    SurfaceAnimationOffset.X := GiScalePixels(Round(PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Position.X * Scale));
    SurfaceAnimationOffset.Y := GiScalePixels(Round(PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Position.Y * Scale));
    SurfaceAnimationFrame := 0;
    SurfaceImageControl := TImageGI.Create(Space.MapPanel);
    SurfaceImageControl.World := True;
    SurfaceImageControl.SetDepth(PlanetControl.Depth - 0.02);
    StartRandomSurfaceAnimation;
  end;
end;
{ @end $692EC0 }

{ @routine $693038 TPlanetSE_StartRandomSurfaceAnimation }
procedure TPlanetSE.StartRandomSurfaceAnimation;
var
  Index, Attempts, TotalWeight, Choice: Integer;
begin
  if IsRuins then Exit;
  TotalWeight := 0;
  with PlanetAdvertDefinitions[SurfaceAnimationMask shr 24] do
  begin
    for Index := 0 to 23 do
      if (SurfaceAnimationMask and (1 shl Index)) <> 0 then Inc(TotalWeight, Lists[Index].Weight);
    Attempts := 10;
    while Attempts > 0 do
    begin
      Choice := RandomIntRange(0, TotalWeight - 1);
      for Index := 0 to 23 do
        if (SurfaceAnimationMask and (1 shl Index)) <> 0 then
        begin
          Dec(Choice, Lists[Index].Weight);
          if Choice < 0 then
          begin
            SurfaceAnimationIndex := Index;
            { Native compares the value just assigned; retain the unreachable assignment. }
            if SurfaceAnimationIndex <> Index then Attempts := 0;
            Break;
          end;
        end;
      Dec(Attempts);
    end;
  end;
  SurfaceAnimationFrame := 0;
    if GiResourceVariant = 1 then SurfaceImageControl.ImageSourcePath := PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Adverts[PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Lists[SurfaceAnimationIndex].Indices[SurfaceAnimationFrame]].Image1
    else SurfaceImageControl.ImageSourcePath := PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Adverts[PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Lists[SurfaceAnimationIndex].Indices[SurfaceAnimationFrame]].Image2;
  SurfaceImageControl.ObjectSize := SurfaceImageControl.GetContentSize;
  SurfaceImageControl.Sme := HalfPoint(SurfaceImageControl.ClientSize);
  SurfaceImageControl.Pos := AddPoints(PlanetControl.LocalPosition, SurfaceAnimationOffset);
  if SurfaceImageControl.GaiImageControl <> nil then SurfaceImageControl.GaiImageControl.CycleCompleteCallback := SurfaceAnimationFinished;
  SurfaceImageControl.RestartPlayback;
end;
{ @end $693038 }

{ @routine $693224 TPlanetSE_SetMinimapOwner }
procedure TPlanetSE.SetMinimapOwner(Owner: Byte);
var
  Index: Integer;
begin
  if IsRuins then Exit;
  if MinimapOwner = Owner then Exit;
  MinimapOwner := Owner;
  if MinimapControl <> nil then
  begin
    if MinimapOwner <= 7 then
      MinimapControl.SetImagePath('Bm.Planet.M.' + OwnerInfo[TOwnerId(MinimapOwner)].InternalName)
    else
    begin
      Index := MinimapOwner - 7 - 1;
      if Index <= 9 then MinimapControl.SetImagePath('Bm.Planet.M.0' + IntToWideString(Index))
      else MinimapControl.SetImagePath('Bm.Planet.M.' + IntToWideString(Index));
    end;
    MinimapControl.ObjectSize := MinimapControl.GetContentSize;
  end;
end;
{ @end $693224 }

{ @routine $69337C TPlanetSE_SetPosition }
procedure TPlanetSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsRuins then
  begin
    if IsAttachedToSpace then
    begin
      if RuinsImageControl <> nil then RuinsImageControl.Pos := TruncatePointF(APosition);
      if RuinsAnimationControl <> nil then RuinsAnimationControl.Pos := TruncatePointF(APosition);
      RuinsMinimapControl.Pos := TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale));
    end;
  end
  else
  begin
    if CollisionCircle <> nil then
    begin
      CollisionCircle.Position.X := Position.X;
      CollisionCircle.Position.Y := Position.Y;
      CollisionCircle.Radius := Radius;
      CollisionCircle.RadiusSquared := Radius * Radius;
    end;
    UpdateLightAngleFromStar;
    if IsAttachedToSpace then
    begin
      PlanetControl.Pos := Classes.Point(Round(APosition.X), Round(APosition.Y));
      MinimapControl.Pos := TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale));
      if RingControl1 <> nil then RingControl1.Pos := PlanetControl.LocalPosition;
      if RingControl2 <> nil then RingControl2.Pos := PlanetControl.LocalPosition;
      if LegacySurfaceControl <> nil then LegacySurfaceControl.Pos := AddPoints(PlanetControl.LocalPosition, SurfaceAnimationOffset);
      if SurfaceImageControl <> nil then SurfaceImageControl.Pos := AddPoints(PlanetControl.LocalPosition, SurfaceAnimationOffset);
    end;
  end;
end;
{ @end $69337C }

{ @routine $69358C TPlanetSE_SetSurfaceMapOffset }
procedure TPlanetSE.SetSurfaceMapOffset(Value: Integer);
begin
  SurfaceMapOffset := Value;
  if (not IsRuins) and IsAttachedToSpace then PlanetControl.SetSurfaceMapOffset(SurfaceMapOffset);
end;
{ @end $69358C }

{ @routine $6935B8 TPlanetSE_SetCloud1MapOffset }
procedure TPlanetSE.SetCloud1MapOffset(Value: Integer);
begin
  Cloud1MapOffset := Value;
  if (not IsRuins) and IsAttachedToSpace then PlanetControl.SetCloud1MapOffset(Cloud1MapOffset);
end;
{ @end $6935B8 }

{ @routine $6935E8 TPlanetSE_SetCloud2MapOffset }
procedure TPlanetSE.SetCloud2MapOffset(Value: Integer);
begin
  Cloud2MapOffset := Value;
  if (not IsRuins) and IsAttachedToSpace then PlanetControl.SetCloud2MapOffset(Cloud2MapOffset);
end;
{ @end $6935E8 }

{ @routine $693618 TPlanetSE_SetCloud3MapOffset }
procedure TPlanetSE.SetCloud3MapOffset(Value: Integer);
begin
  Cloud3MapOffset := Value;
  if (not IsRuins) and IsAttachedToSpace then PlanetControl.SetCloud3MapOffset(Cloud3MapOffset);
end;
{ @end $693618 }

{ @routine $693648 TPlanetSE_SetLightAngle }
procedure TPlanetSE.SetLightAngle(Value: Byte);
begin
  if IsRuins then Exit;
  LightAngle := Value;
  if IsAttachedToSpace then PlanetControl.SetLightAngle(LightAngle);
end;
{ @end $693648 }

{ @routine $693674 TPlanetSE_SetRotationTimerInterval }
procedure TPlanetSE.SetRotationTimerInterval(Value: Cardinal);
var
  Interval: Integer;
begin
  RotationTimerInterval := Value;
  if IsRuins then Exit;
  if IsAttachedToSpace then
  begin
    if RotationTimer <> nil then
    begin
      Space.DeleteTimer(RotationTimer);
      RotationTimer := nil;
    end;
    RotationTimer := Space.CreateTimer(0, RotationTimerInterval, AdvanceRotationTimer, 0);
    if Cloud1Timer <> nil then
    begin
      Space.DeleteTimer(Cloud1Timer);
      Cloud1Timer := nil;
    end;
    if Cloud2Timer <> nil then
    begin
      Space.DeleteTimer(Cloud2Timer);
      Cloud2Timer := nil;
    end;
    if Cloud3Timer <> nil then
    begin
      Space.DeleteTimer(Cloud3Timer);
      Cloud3Timer := nil;
    end;
    if PlanetClouds then
    begin
      if (Cloud1ImagePath <> '') and (Cloud1RelativeRotationSpeed <> -1) then
      begin
        if Cloud1RelativeRotationSpeed > -1 then
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (1 + Cloud1RelativeRotationSpeed))));
          Cloud1MapStep := 1;
        end
        else
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (-Cloud1RelativeRotationSpeed - 1))));
          Cloud1MapStep := -1;
        end;
        Cloud1Timer := Space.CreateTimer(0, Abs(Interval), AdvanceCloudTimer, 1);
      end;
      if (Cloud2ImagePath <> '') and (Cloud2RelativeRotationSpeed <> -1) then
      begin
        if Cloud2RelativeRotationSpeed > -1 then
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (1 + Cloud2RelativeRotationSpeed))));
          Cloud2MapStep := 1;
        end
        else
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (-Cloud2RelativeRotationSpeed - 1))));
          Cloud2MapStep := -1;
        end;
        Cloud2Timer := Space.CreateTimer(0, Abs(Interval), AdvanceCloudTimer, 2);
      end;
      if (Cloud3ImagePath <> '') and (Cloud3RelativeRotationSpeed <> -1) then
      begin
        if Cloud3RelativeRotationSpeed > -1 then
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (1 + Cloud3RelativeRotationSpeed))));
          Cloud3MapStep := 1;
        end
        else
        begin
          Interval := Max(10, Round(1000 / (1000 / RotationTimerInterval * (-Cloud3RelativeRotationSpeed - 1))));
          Cloud3MapStep := -1;
        end;
        Cloud3Timer := Space.CreateTimer(0, Abs(Interval), AdvanceCloudTimer, 3);
      end;
    end;
  end;
end;
{ @end $693674 }

{ @routine $693B4C TPlanetSE_SetSurfaceMapStep }
procedure TPlanetSE.SetSurfaceMapStep(Value: Integer);
begin
  SurfaceMapStep := Value;
end;
{ @end $693B4C }

{ @routine $693B50 TPlanetSE_SetRingKind }
procedure TPlanetSE.SetRingKind(Kind: Byte);
begin
  if IsRuins then Exit;
  RingKind := Kind;
  if IsAttachedToSpace then RebuildRings;
end;
{ @end $693B50 }

{ @routine $693B78 TPlanetSE_SetSurfaceAnimationMask }
procedure TPlanetSE.SetSurfaceAnimationMask(Mask: Integer);
begin
  if IsRuins then Exit;
  SurfaceAnimationMask := Mask;
  if IsAttachedToSpace then RebuildSurfaceAnimation;
end;
{ @end $693B78 }

{ @routine $693BA0 TPlanetSE_UpdateLightAngleFromStar }
procedure TPlanetSE.UpdateLightAngleFromStar;
var
  Obj: TObjectSE;
begin
  if IsAttachedToSpace and not IsRuins then
  begin
    Obj := Space.FirstObject;
    while Obj <> nil do
    begin
      if Obj is TStarSE then
      begin
        SetLightAngle(Trunc(ArcTan2(-(Position.X - Obj.Position.X), Position.Y - Obj.Position.Y) * 180 / GamePi * 256 / 360));
        Break;
      end;
      Obj := Obj.Next;
    end;
  end;
end;
{ @end $693BA0 }

{ @routine $693C40 TPlanetSE_SurfaceAnimationFinished }
procedure TPlanetSE.SurfaceAnimationFinished(Sender: TObjectGI);
begin
  if IsRuins then Exit;
  Inc(SurfaceAnimationFrame);
  if High(PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Lists[SurfaceAnimationIndex].Indices) < SurfaceAnimationFrame then
  begin
    StartRandomSurfaceAnimation;
    Exit;
  end;
  { Native retains this empty diagnostic branch. }
  if SurfaceAnimationFrame = 2 then
    if SurfaceAnimationFrame = 2 then begin end;
  if GiResourceVariant = 1 then SurfaceImageControl.ImageSourcePath := PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Adverts[PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Lists[SurfaceAnimationIndex].Indices[SurfaceAnimationFrame]].Image1
  else SurfaceImageControl.ImageSourcePath := PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Adverts[PlanetAdvertDefinitions[SurfaceAnimationMask shr 24].Lists[SurfaceAnimationIndex].Indices[SurfaceAnimationFrame]].Image2;
  if SurfaceImageControl.GaiImageControl <> nil then SurfaceImageControl.GaiImageControl.CycleCompleteCallback := SurfaceAnimationFinished;
  SurfaceImageControl.RestartPlayback;
end;
{ @end $693C40 }

{ @routine $693D68 TPlanetSE_AdvanceRotationTimer }
procedure TPlanetSE.AdvanceRotationTimer(Timer: PSpaceTimerSE; UserData: Integer);
begin
  if not IsRuins then SetSurfaceMapOffset(SurfaceMapOffset + SurfaceMapStep);
end;
{ @end $693D68 }

{ @routine $693D80 TPlanetSE_AdvanceCloudTimer }
procedure TPlanetSE.AdvanceCloudTimer(Timer: PSpaceTimerSE; UserData: Integer);
begin
  if IsRuins then Exit;
  if SurfaceMapStep > 0 then
  begin
    if UserData = 1 then SetCloud1MapOffset(Cloud1MapOffset + Cloud1MapStep)
    else if UserData = 2 then SetCloud2MapOffset(Cloud2MapOffset + Cloud2MapStep)
    else if UserData = 3 then SetCloud3MapOffset(Cloud3MapOffset + Cloud3MapStep);
  end
  else
  begin
    if UserData = 1 then SetCloud1MapOffset(Cloud1MapOffset - Cloud1MapStep)
    else if UserData = 2 then SetCloud2MapOffset(Cloud2MapOffset - Cloud2MapStep)
    else if UserData = 3 then SetCloud3MapOffset(Cloud3MapOffset - Cloud3MapStep);
  end;
end;
{ @end $693D80 }

{ @routine $693E24 TPlanetSE_HitTestCursor }
function TPlanetSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then
  begin
    Result := False;
    Exit;
  end;
  Result := False;
  if IsRuins then
  begin
    if RuinsAnimationControl <> nil then
      Result := RuinsAnimationControl.HitTestPixel(RuinsAnimationControl.MessageLoop.GetCursorPoint)
    else if RuinsImageControl <> nil then
      Result := RuinsImageControl.HitTestPixel(RuinsImageControl.MessageLoop.GetCursorPoint);
  end
  else Result := PlanetControl.HitTestCursor;
end;
{ @end $693E24 }

{ @routine $693E94 TPlanetSE_DrawMap }
procedure TPlanetSE.DrawMap;
var
  Capacity, Index, X, Y, CenterX, CenterY: Integer;
  ProjectedXi, ProjectedYi, Decision, OrbitRadius, Pitch: Integer;
  ProjectedX, ProjectedY: Single;
  Dest, P0, P1, P2, P3, P4, P5, P6, P7: PPlanetMapOrbitPoint;
  Pixels, Scratch: Pointer;
  OctantCount: Integer;
  Intensity, IntensityStep: Single;
begin
  with Space.Process as TProcessSE do
  begin
    if RadarRange <= 0 then Exit;
    if IsRuins then
      RuinsMinimapControl.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height))
    else
    begin
      Pixels := RenderScratchBuffer.GetPixels;
      Pitch := RenderScratchBuffer.PitchBytes;
      ProjectedX := Position.X * Self.Space.MinimapScale;
      ProjectedY := Position.Y * Self.Space.MinimapScale;
      ProjectedXi := Round(ProjectedX);
      ProjectedYi := Round(ProjectedY);
      if MapOrbitPoints = nil then
      begin
        Capacity := RenderScratchBuffer.Width shr 1;
        Scratch := AllocEC(Capacity * 8 * SizeOf(TPlanetMapOrbitPoint));
        OrbitRadius := Round(Sqrt(ProjectedXi * ProjectedXi + ProjectedYi * ProjectedYi));
        CenterX := RenderScratchBuffer.Width shr 1;
        CenterY := RenderScratchBuffer.Height shr 1;
        Decision := 3 - 2 * OrbitRadius;
        X := 0;
        Y := OrbitRadius - 1;
        P0 := Scratch;
        P1 := AddPointerOffset(P0, Capacity * SizeOf(TPlanetMapOrbitPoint));
        P2 := AddPointerOffset(P1, Capacity * SizeOf(TPlanetMapOrbitPoint));
        P3 := AddPointerOffset(P2, Capacity * SizeOf(TPlanetMapOrbitPoint));
        P4 := AddPointerOffset(P3, Capacity * SizeOf(TPlanetMapOrbitPoint));
        P5 := AddPointerOffset(P4, Capacity * SizeOf(TPlanetMapOrbitPoint));
        P6 := AddPointerOffset(P5, Capacity * SizeOf(TPlanetMapOrbitPoint));
        P7 := AddPointerOffset(P6, Capacity * SizeOf(TPlanetMapOrbitPoint));
        OctantCount := 0;
        repeat
          P0.Position.X := CenterX + X;
          P0.Position.Y := CenterY - Y;
          P0 := AddPointerOffset(P0, SizeOf(TPlanetMapOrbitPoint));
          P1.Position.X := CenterX + Y;
          P1.Position.Y := CenterY - X;
          P1 := AddPointerOffset(P1, SizeOf(TPlanetMapOrbitPoint));
          P2.Position.X := CenterX + Y;
          P2.Position.Y := CenterY + X;
          P2 := AddPointerOffset(P2, SizeOf(TPlanetMapOrbitPoint));
          P3.Position.X := CenterX + X;
          P3.Position.Y := CenterY + Y;
          P3 := AddPointerOffset(P3, SizeOf(TPlanetMapOrbitPoint));
          P4.Position.X := CenterX - X;
          P4.Position.Y := CenterY + Y;
          P4 := AddPointerOffset(P4, SizeOf(TPlanetMapOrbitPoint));
          P5.Position.X := CenterX - Y;
          P5.Position.Y := CenterY + X;
          P5 := AddPointerOffset(P5, SizeOf(TPlanetMapOrbitPoint));
          P6.Position.X := CenterX - Y;
          P6.Position.Y := CenterY - X;
          P6 := AddPointerOffset(P6, SizeOf(TPlanetMapOrbitPoint));
          P7.Position.X := CenterX - X;
          P7.Position.Y := CenterY - Y;
          P7 := AddPointerOffset(P7, SizeOf(TPlanetMapOrbitPoint));
          Inc(OctantCount);
          if Decision < 0 then
            Decision := 4 * X + Decision + 6
          else
          begin
            Decision := 4 * (X - Y) + Decision + 10;
            Dec(Y);
          end;
          Inc(X);
        until X > Y;
        MapOrbitPointCount := OctantCount * 8;
        MapOrbitPoints := AllocEC(MapOrbitPointCount * SizeOf(TPlanetMapOrbitPoint));
        Dest := MapOrbitPoints;
        P0 := Scratch;
        P1 := AddPointerOffset(Scratch, Capacity * SizeOf(TPlanetMapOrbitPoint) + (OctantCount - 1) * SizeOf(TPlanetMapOrbitPoint));
        P2 := AddPointerOffset(Scratch, Capacity * 2 * SizeOf(TPlanetMapOrbitPoint));
        P3 := AddPointerOffset(Scratch, Capacity * 3 * SizeOf(TPlanetMapOrbitPoint) + (OctantCount - 1) * SizeOf(TPlanetMapOrbitPoint));
        P4 := AddPointerOffset(Scratch, Capacity * 4 * SizeOf(TPlanetMapOrbitPoint));
        P5 := AddPointerOffset(Scratch, Capacity * 5 * SizeOf(TPlanetMapOrbitPoint) + (OctantCount - 1) * SizeOf(TPlanetMapOrbitPoint));
        P6 := AddPointerOffset(Scratch, Capacity * 6 * SizeOf(TPlanetMapOrbitPoint));
        P7 := AddPointerOffset(Scratch, Capacity * 7 * SizeOf(TPlanetMapOrbitPoint) + (OctantCount - 1) * SizeOf(TPlanetMapOrbitPoint));
        X := -10000;
        Y := -10000;
        { Preserve octant traversal and duplicate suppression at the joins. }
        for Index := 0 to OctantCount - 1 do
        begin
          if (P0.Position.X <> X) or (P0.Position.Y <> Y) then
          begin
            Dest.Position.X := P0.Position.X;
            Dest.Position.Y := P0.Position.Y;
            Dest.PixelOffset := 2 * Dest.Position.X + Dest.Position.Y * Pitch;
            X := Dest.Position.X;
            Y := Dest.Position.Y;
            Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
          end
          else Dec(MapOrbitPointCount);
          P0 := AddPointerOffset(P0, SizeOf(TPlanetMapOrbitPoint));
        end;
        for Index := 0 to OctantCount - 1 do
        begin
          if (P1.Position.X <> X) or (P1.Position.Y <> Y) then
          begin
            Dest.Position.X := P1.Position.X;
            Dest.Position.Y := P1.Position.Y;
            Dest.PixelOffset := 2 * Dest.Position.X + Dest.Position.Y * Pitch;
            X := Dest.Position.X;
            Y := Dest.Position.Y;
            Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
          end
          else Dec(MapOrbitPointCount);
          P1 := AddPointerOffset(P1, -SizeOf(TPlanetMapOrbitPoint));
        end;
        for Index := 0 to OctantCount - 1 do
        begin
          if (P2.Position.X <> X) or (P2.Position.Y <> Y) then
          begin
            Dest.Position.X := P2.Position.X;
            Dest.Position.Y := P2.Position.Y;
            Dest.PixelOffset := 2 * Dest.Position.X + Dest.Position.Y * Pitch;
            X := Dest.Position.X;
            Y := Dest.Position.Y;
            Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
          end
          else Dec(MapOrbitPointCount);
          P2 := AddPointerOffset(P2, SizeOf(TPlanetMapOrbitPoint));
        end;
        for Index := 0 to OctantCount - 1 do
        begin
          if (P3.Position.X <> X) or (P3.Position.Y <> Y) then
          begin
            Dest.Position.X := P3.Position.X;
            Dest.Position.Y := P3.Position.Y;
            Dest.PixelOffset := 2 * Dest.Position.X + Dest.Position.Y * Pitch;
            X := Dest.Position.X;
            Y := Dest.Position.Y;
            Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
          end
          else Dec(MapOrbitPointCount);
          P3 := AddPointerOffset(P3, -SizeOf(TPlanetMapOrbitPoint));
        end;
        for Index := 0 to OctantCount - 1 do
        begin
          if (P4.Position.X <> X) or (P4.Position.Y <> Y) then
          begin
            Dest.Position.X := P4.Position.X;
            Dest.Position.Y := P4.Position.Y;
            Dest.PixelOffset := 2 * Dest.Position.X + Dest.Position.Y * Pitch;
            X := Dest.Position.X;
            Y := Dest.Position.Y;
            Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
          end
          else Dec(MapOrbitPointCount);
          P4 := AddPointerOffset(P4, SizeOf(TPlanetMapOrbitPoint));
        end;
        for Index := 0 to OctantCount - 1 do
        begin
          if (P5.Position.X <> X) or (P5.Position.Y <> Y) then
          begin
            Dest.Position.X := P5.Position.X;
            Dest.Position.Y := P5.Position.Y;
            Dest.PixelOffset := 2 * Dest.Position.X + Dest.Position.Y * Pitch;
            X := Dest.Position.X;
            Y := Dest.Position.Y;
            Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
          end
          else Dec(MapOrbitPointCount);
          P5 := AddPointerOffset(P5, -SizeOf(TPlanetMapOrbitPoint));
        end;
        for Index := 0 to OctantCount - 1 do
        begin
          if (P6.Position.X <> X) or (P6.Position.Y <> Y) then
          begin
            Dest.Position.X := P6.Position.X;
            Dest.Position.Y := P6.Position.Y;
            Dest.PixelOffset := 2 * Dest.Position.X + Dest.Position.Y * Pitch;
            X := Dest.Position.X;
            Y := Dest.Position.Y;
            Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
          end
          else Dec(MapOrbitPointCount);
          P6 := AddPointerOffset(P6, SizeOf(TPlanetMapOrbitPoint));
        end;
        for Index := 0 to OctantCount - 1 do
        begin
          if (P7.Position.X <> X) or (P7.Position.Y <> Y) then
          begin
            Dest.Position.X := P7.Position.X;
            Dest.Position.Y := P7.Position.Y;
            Dest.PixelOffset := 2 * Dest.Position.X + Dest.Position.Y * Pitch;
            X := Dest.Position.X;
            Y := Dest.Position.Y;
            Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
          end
          else Dec(MapOrbitPointCount);
          P7 := AddPointerOffset(P7, -SizeOf(TPlanetMapOrbitPoint));
        end;
        FreeEC(Scratch);
      end;
      Index := Round(RadiansToHeadingDegrees(ArcTan2(ProjectedX, -ProjectedY)) / 360 * (MapOrbitPointCount - 1));
      Dest := AddPointerOffset(MapOrbitPoints, Index * SizeOf(TPlanetMapOrbitPoint));
      Intensity := 255;
      IntensityStep := -510 / MapOrbitPointCount;
      while Intensity > 0 do
      begin
        BlendPixel16(AddPointerOffset(Pixels, Dest.PixelOffset),
          ReadWordEC(AddPointerOffset(InterfaceBlendPalette, Round(Intensity) * 2)), Round(Intensity));
        if OrbitalVelocity > 0 then
        begin
          Dec(Index);
          if Index < 0 then
          begin
            Index := MapOrbitPointCount - 1;
            Dest := AddPointerOffset(MapOrbitPoints, Index * SizeOf(TPlanetMapOrbitPoint));
          end
          else Dest := AddPointerOffset(Dest, -SizeOf(TPlanetMapOrbitPoint));
        end
        else
        begin
          Inc(Index);
          if Index >= MapOrbitPointCount then
          begin
            Index := 0;
            Dest := MapOrbitPoints;
          end
          else Dest := AddPointerOffset(Dest, SizeOf(TPlanetMapOrbitPoint));
        end;
        Intensity := Intensity + IntensityStep;
      end;
      MinimapControl.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
    end;
  end;
end;
{ @end $693E94 }

{ @routine $694908 TPlanetSE_RenderToBuffer }
procedure TPlanetSE.RenderToBuffer(Screen: TMessageLoopGI; Buffer: TGraphBufGR; SmallPreview: Boolean);
var
  Template: TPlanetTempl;
  Planet: TPlanetGI;
  Index, Count, TemplateIndex, Diameter: Integer;
  Control: TCBitmapControlEC;
  RenderRadius: Integer;
  SatelliteTemplate: TSputnikTempl;
begin
  if IsRuins then
    LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(RuinsImagePath, 1, ','), Buffer)
  else if PlanetControl <> nil then PlanetControl.RenderSurfaceToBuffer(Buffer)
  else
  begin
    SatelliteTemplate := nil;
    Template := nil;
    if not SmallPreview then
    begin
      Count := PlanetRenderTemplates.Count;
      for Index := 0 to Count - 1 do
      begin
        Template := PlanetRenderTemplates[Index];
        if Template.Radius = Radius then Break;
      end;
      if Template = nil then raise Exception.Create('Error1 in TPlanetSE.DrawBufRGBA');
    end;
    if SmallPreview then RenderRadius := 25 else RenderRadius := (Radius * 2) div 2;
    Diameter := RenderRadius * 2;
    if Diameter < 1 then raise Exception.Create('Error2 in TPlanetSE.DrawBufRGBA');
    Planet := TPlanetGI.Create(Screen.ContentPanel);
    if SmallPreview then
    begin
      TemplateIndex := RenderRadius * 2 - MinimumSatelliteTemplateRadius;
      SatelliteTemplate := SatelliteRenderTemplates[TemplateIndex];
      Planet.SetImageFromTemplate(SatelliteTemplate.MaskName, ImagePath, SatelliteTemplate.Radius);
    end
    else Planet.SetImageWithRadius(Template.MaskName, ImagePath, Template.LightName, RenderRadius);
    Planet.SetLightAngle(224);
    Planet.HitTestBounds := Classes.Rect(-1, -1, Diameter, Diameter);
    Control := TCBitmapControlEC.Create;
    GlobalCache.ResetControl(Control);
    if SmallPreview then Control.SetCacheKey(ExtractDelimitedPartW(SatelliteTemplate.MaskName, 0, '?') + RgbaImagePathSuffix)
    else Control.SetCacheKey(Template.MaskName + RgbaImagePathSuffix);
    AcquireOrCreateBitmap(Control);
    Planet.RenderSurfaceToBuffer(Buffer);
    Planet.Free;
    Control.Release;
    Control.Free;
  end;
end;
{ @end $694908 }

{ @routine $694BEC TPlanetSE_LoadTemplate }
procedure TPlanetSE.LoadTemplate(Block: TBlockParEC);
var
  Text: WideString;
begin
  inherited LoadTemplate(Block);
  if IsRuins then
  begin
    RuinsAnimationPath := Block.GetParam('Image');
    RuinsImagePath := Block.GetParam('ImageI');
    RuinsMinimapPath := Block.GetParam('ImageMap');
  end
  else
  begin
    RotationTimerInterval := 100;
    SurfaceMapStep := -1;
    ImagePath := Block.GetParam('Image');
    MinimapImagePath := Block.GetParam('ImageMap');
    ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
    MinimapImageOrigin := GetPointGI(Block.GetParam('SmeImageMap'));
    Radius := StrToInt(Block.GetParam('Radius'));
    if Block.CountParams('Cloud0') > 0 then
    begin
      Text := Block.GetParam('Cloud0');
      Cloud1RelativeRotationSpeed := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ','));
      Cloud1ImagePath := ExtractDelimitedPartW(Text, 1, ',');
    end;
    if Block.CountParams('Cloud1') > 0 then
    begin
      Text := Block.GetParam('Cloud1');
      Cloud2RelativeRotationSpeed := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ','));
      Cloud2ImagePath := ExtractDelimitedPartW(Text, 1, ',');
    end;
    if Block.CountParams('Cloud2') > 0 then
    begin
      Text := Block.GetParam('Cloud2');
      Cloud3RelativeRotationSpeed := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ','));
      Cloud3ImagePath := ExtractDelimitedPartW(Text, 1, ',');
    end;
    if Block.CountParams('AtmColor') > 0 then
    begin
      Text := Block.GetParam('AtmColor');
      AtmosphereColor := (ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ',')) and $FF);
      AtmosphereColor := AtmosphereColor or ((ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 1, ',')) and $FF) shl 8);
      AtmosphereColor := AtmosphereColor or ((ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 2, ',')) and $FF) shl 16);
    end;
    if Block.CountParams('Space') > 0 then
    begin
      Text := Block.GetParam('Space');
      SpaceConfigValues[0] := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ','));
      SpaceConfigValues[1] := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 1, ','));
      SpaceConfigValues[2] := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 2, ','));
    end;
    if Block.CountParams('BG') > 0 then BackgroundGraph := Block.GetParam('BG');
    if Block.CountParams('Quest') > 0 then QuestEnabled := ParseEnabledNameGI(Block.GetParam('Quest'));
  end;
end;
{ @end $694BEC }

{ @routine $695158 TPlanetSE_ApplyConfig }
procedure TPlanetSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
  if IsRuins then Exit;
  if Block.CountParams('SmeMap') > 0 then SetSurfaceMapOffset(StrToInt(Block.GetParam('SmeMap')));
  if Block.CountParams('AngleLight') > 0 then SetLightAngle(StrToInt(Block.GetParam('AngleLight')));
  if Block.CountParams('SpeedRotate') > 0 then SetRotationTimerInterval(StrToInt(Block.GetParam('SpeedRotate')));
  if Block.CountParams('StepRotate') > 0 then SetSurfaceMapStep(StrToInt(Block.GetParam('StepRotate')));
end;
{ @end $695158 }

{ @routine $695340 TPlanetSE_QueueImageLoad }
procedure TPlanetSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Template: TPlanetTempl;
  Index, Count: Integer;
  Gai: TgaiGI;
  Image, MapImage: TImageGI;
begin
  if IsRuins then
  begin
    if AnimShipFull or (CurrentScreenId = screen_arcade_battle) then
    begin
      Gai := TgaiGI.Create(Owner);
      Gai.SetImagePath(RuinsAnimationPath);
      Gai.QueueImageLoad(PendingLoads);
      Gai.Free;
    end
    else
    begin
      Image := TImageGI.Create(Owner);
      Image.ImageSourcePath := RuinsImagePath;
      Image.QueueImageLoad(PendingLoads);
      Image.Free;
    end;
    MapImage := TImageGI.Create(Owner);
    MapImage.ImageSourcePath := RuinsMinimapPath;
    MapImage.QueueImageLoad(PendingLoads);
    MapImage.Free;
  end
  else
  begin
    Template := nil;
    Count := PlanetRenderTemplates.Count;
    for Index := 0 to Count - 1 do
    begin
      Template := PlanetRenderTemplates[Index];
      if Template.Radius = Radius then Break;
    end;
    if Template = nil then raise Exception.Create('Error in TPlanetSE.BuildLoadList');
    with TPlanetGI.Create(Owner) do
    begin
      SetImageWithRadius(Template.SmallMaskName, Self.ImagePath, Template.SmallLightName, Self.Radius);
      QueueImageLoad(PendingLoads);
      Free;
    end;
    with TAlphaImageGI.Create(Owner) do
    begin
      SetImagePath(Self.MinimapImagePath);
      QueueImageLoad(PendingLoads);
      Free;
    end;
  end;
end;
{ @end $695340 }

{ @routine $6954F4 AllocatePlanetCollisionCircle }
function AllocatePlanetCollisionCircle: PPlanetCollisionCircle;
var
  Entry: PPlanetCollisionCircle;
begin
  New(Entry);
  Entry.Next := FirstPlanetCollisionCircle;
  Entry.Prev := nil;
  if Entry.Next <> nil then Entry.Next.Prev := Entry;
  FirstPlanetCollisionCircle := Entry;
  Result := Entry;
end;
{ @end $6954F4 }

{ @routine $69551C FreePlanetCollisionCircle }
procedure FreePlanetCollisionCircle(Entry: PPlanetCollisionCircle);
begin
  if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
  if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
  if Entry = FirstPlanetCollisionCircle then FirstPlanetCollisionCircle := Entry.Next;
  Dispose(Entry);
end;
{ @end $69551C }

end.
