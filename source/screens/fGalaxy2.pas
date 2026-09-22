unit fGalaxy2;
// Unit bracket (inferred): .text 0x0067182C..0x0067B5DF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_PolyLine, Classes, EC_BlockPar, EC_Struct, GI_GAI, GI_GraphBuf, GI_GraphButton, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, Types, aGalaxy, aShip, fPanelMain;

type
  TfGalaxy2 = class(TMessageLoopGIWithMainPanel) // @size 0x148
  public
    MapPanel: TPanelGI; // @offset 0xD4
    ViewMode: Byte; // @offset $D8 1 for modal HUD navigation, 2 for the star-map transition.
    CapturePreviewOnOpen: Boolean; // @offset $134 Set by CaptureGalaxyPreview; consumed by OnOpen.
    HideBuffer: TGraphBufGI; // @offset 0xDC
    MapPixelBounds: TRect; // @offset 0xE0  Right and Bottom are treated as inclusive by projection.
    GalaxyOrigin: TPointF; // @offset 0xF0
    GalaxyExtent: TPointF; // @offset 0xF8
    SelectedJumpStar: TStar; // @offset 0x100
    RouteStars: TList; // @offset $104 Borrowed TStar objects forming intermediate route markers.
    StarLinks: TPolyLineGI; // @offset $108 Constellation links owned by MapPanel.
    StarInfoHideTimer: PCallbackTimerGI; // @offset 0x10C
    JumpAnimationTimer: PCallbackTimerGI; // @offset 0x110
    JumpHintAnimationState: Integer; // @offset 0x114
    JumpLightTick: Integer; // @offset 0x118
    JumpButton: TGraphButtonGI; // @offset 0x11C
    JumpDestinationLabel: TLabelGI; // @offset 0x120
    JumpAnimation: TgaiGI; // @offset 0x124
    JumpLightImages: array[0..2] of TImageGI; // @offset 0x128
    CreateMarkerButton: TGraphButtonGI; // @offset 0x138
    CreateMarkerImagePath: WideString; // @offset 0x13C
    CreateMarkerActiveImagePath: WideString; // @offset 0x140
    CreateMarkerMode: Boolean; // @offset $144

    destructor Destroy; override; // @addr 0x67193C
    procedure OnOpen; override; // @addr 0x671EA0
    procedure OnClose; override; // @addr 0x674B00
    procedure ProcessCallbackTimers; override; // @addr 0x67B288
    procedure SelectMusic; override; // @addr 0x67AF54
    procedure InitializeLayout; override; // @addr 0x671994
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x67B57C
    function GalaxyPointToMapPoint(Point: TPointF): TPoint; // @addr 0x674FF4
    function GalaxyDistanceToMapDistance(Distance: Double): Integer; // @addr 0x675098 @note "Uses the horizontal projection scale."
    procedure ConfigureReadOnlyMap; // @addr 0x675C30
    procedure ConfigureJumpSelection; // @addr 0x675D64
    procedure ShowStarInfo(Star: TStar); // @addr 0x676DB8 @note "Nil hides the panel; cancels StarInfoHideTimer."
    procedure HideStarInfo(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x6764F8
    procedure UpdateJumpAnimations(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x67AB80
    function CanShowExtendedRadarInfo(Star: TStar): Boolean; // @addr 0x674E74 @note "Requires an active Prolonger effect as well as radar coverage."
    function GetRadarSummaryRadius: Integer; // @addr 0x674F18 @note "Measured in radar-summary units of 150 range units."
    function CanRevealBossPresence(Ship: TShip): Boolean; // @addr 0x679134 @note "Requires boss-specific scanner technology; does not test general visibility."

    procedure CloseClicked(Sender: TObjectGI); // @addr $674C50
    procedure JumpClicked(Sender: TObjectGI); // @addr $676518
    procedure JumpMouseEnter(Sender: TObjectGI); // @addr $676B74
    procedure JumpMouseLeave(Sender: TObjectGI); // @addr $676D58
    procedure CreateMarkerClicked(Sender: TObjectGI); // @addr $67B418
    procedure UndoMarkerClicked(Sender: TObjectGI); // @addr $67B500
    procedure ClearMarkersClicked(Sender: TObjectGI); // @addr $67B544
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $674C7C
    procedure MainPanelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $674D4C
    procedure MapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $675F90
    procedure MapLeftButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $675FC0
    procedure MapRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6762E4
    procedure MapButtonUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $67643C
    procedure MapDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6764AC
    procedure RebuildJumpPath; // @addr $6750DC
    procedure ClearJumpPath; // @addr $675BA0
    procedure ClearReadOnlyMapCallbacks; // @addr $675D2C
    procedure ClearJumpSelectionCallbacks; // @addr $675F20
    function MapPointToGalaxyPoint(Point: TPoint): TPointF; // @addr $674F4C
    function BuildStarShipSummary(Star: TStar; var LineCount: Integer): WideString; // @addr $6798E0

    constructor Create; // @addr 0x6718DC
  end;

procedure CaptureGalaxyPreview(ParentLoop: TMessageLoopGI); // @addr $67B3B0
function RunGalaxyMap(ParentLoop: TMessageLoopGI): Boolean; // @addr $67B2C8

const
  GalaxyMapFriendlyShipOrder: array[1..7] of Byte = (0, 1, 10, 2, 3, 4, 5); // @addr $87BF2C

implementation

uses EC_CacheBitmap, Globals, GR_Main, GR_GraphBuf, Windows, SysUtils, Math, aPlayer, aItem, aMyFunction, aGalaxyStruct, aKling, aConst, EC_Str, GR_Music, GI_Main, GlobalsV, aPlanet, fStarMap, aGalaxyEvent, SE_Hole, GI_MessageBox, aScript, aRanger, aTransport, aPirate, aWarrior, aTranclucator, aVector, GI_Circle, EC_Mem, GI_Window, SE_Star, SE_Planet, SE_Ruins, SE_Ship2, aRuins;

const
  GalaxySummaryWhiteColorTag = '<color=255,255,254>';

{ @routine $6718DC TfGalaxy2_Create }
constructor TfGalaxy2.Create;
begin
  inherited Create;
  RouteStars := TList.Create;
  ViewMode := 0;
end;
{ @end $6718DC }

{ @routine $67193C TfGalaxy2_Destroy }
destructor TfGalaxy2.Destroy;
begin
  if RouteStars <> nil then
  begin
    RouteStars.Free;
    RouteStars := nil;
  end;
  inherited Destroy;
end;
{ @end $67193C }

{ @routine $671994 TfGalaxy2_InitializeLayout }
procedure TfGalaxy2.InitializeLayout;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fGalaxy2... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('ButExit').Parent do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
  end;
  AppendLogLineThreadSafe('ok');
  with GetByName('MainPanel') do
  begin
    KeyDownCallback := MainPanelKeyDown;
    LeftButtonUpCallback := MainPanelMouseUp;
  end;
  (GetByName('ButExit') as TGraphButtonGI).UpCallback := CloseClicked;
  MapPanel := GetByName('Map') as TPanelGI;
  HideBuffer := GetByName('HideBuf') as TGraphBufGI;
  JumpButton := GetByName('ButJump') as TGraphButtonGI;
  JumpDestinationLabel := GetByName('LabelJumpTo') as TLabelGI;
  JumpAnimation := GetByName('Anim') as TgaiGI;
  JumpAnimation.StopAutoPlayback;
  JumpLightImages[0] := GetByName('Light1') as TImageGI;
  JumpLightImages[1] := GetByName('Light2') as TImageGI;
  JumpLightImages[2] := GetByName('Light3') as TImageGI;
  CreateMarkerButton := GetByName('ButCreate') as TGraphButtonGI;
  with CreateMarkerButton do
  begin
    UpCallback := CreateMarkerClicked;
    CreateMarkerImagePath := ImageNormal.GetImagePath;
    CreateMarkerActiveImagePath := ImageNormalActive.GetImagePath;
  end;
  (GetByName('ButUndo') as TGraphButtonGI).UpCallback := UndoMarkerClicked;
  (GetByName('ButDel') as TGraphButtonGI).UpCallback := ClearMarkersClicked;
end;
{ @end $671994 }

{ @routine $671EA0 TfGalaxy2_OnOpen }
procedure TfGalaxy2.OnOpen;
var
  I, J, K: Integer;
  Polygon: TPolygon2D;
  Constellation: TConstellation;
  Segment: PMapLineSegment;
  Color: Cardinal;
  Points: array of TPoint;
  Maximum: TPointF;
  Vertex: PPointF;
  First, Second: TPoint;
  StarImageCount: Integer;
  Block: TBlockParEC;
  Star: TStar;
  StarImage, BattleRing: TgaiGI;
  NameLabel, ForceLabel: TLabelGI;
  Text, ColoredName: WideString;
  Planet: TPlanet;
  OwnerId: TOwnerId;
  HoleImage: TImageGI;
  BufferOffset: TPoint;
  Hole, SelectedHole: THole;
  { No native accesses remain to these stack slots. }
  Reserved84, Reserved88, Reserved8C, Reserved90: Integer;
  ForceText, BossText: WideString;
  CoalitionCount, BlazerCount, KellerCount, TerronCount: Integer;
  ReservedAC: Integer;
  PirateCount, CustomCount, OtherCount: Integer;
  Strength: Extended;
  CoalitionPresent, DominatorsPresent, PiratesPresent, CustomPresent, PlayerPartyPresent: Boolean;
  CaptureBuffer: TGraphBufGR;
  CustomFaction, OtherFaction: WideString;
begin
  inherited OnOpen;
  if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True, 0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  if (GetPlayer <> nil) and not CapturePreviewOnOpen then GetPlayer.ScriptItemsAct(satOnEnteringForm, nil, nil, 0);
  MainPanel.OnOpen;
  (GetByName('PM_Ship') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Gal') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Quest') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_EndTurn') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Logo') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('ImagePanel') as TImageGI).SetActive(True);
  RouteStars.Clear;
  CreateMarkerMode := False;
  CreateMarkerButton.SetImageNormalPath(CreateMarkerImagePath);
  CreateMarkerButton.SetImageNormalActivePath(CreateMarkerActiveImagePath);
  GetPlayer.RefreshDerivedStats(True);
  Points := nil;
  HideBuffer.LoadBitmapPathAsRgba('Bm.FormGalaxy2.' + GiResourceSuffix + 'img?RGBA');
  if GiResourceVariant = 2 then MapPixelBounds := Classes.Rect(50, 50, 974, 718)
  else MapPixelBounds := Classes.Rect(39, 39, 761, 561);
  MapPixelBounds.TopLeft := Classes.Point(0, 0);
  MapPixelBounds.BottomRight := MapPanel.ClientSize;
  BufferOffset := HalfPoint(SubtractPoints(Classes.Point(HideBuffer.GraphBuf.Width, HideBuffer.GraphBuf.Height), MapPanel.ClientSize));
  GalaxyOrigin := MakePointF(1.0e20, 1.0e20);
  Maximum := MakePointF(-1.0e20, -1.0e20);
  for I := 0 to Galaxy.Constellations.Count - 1 do
  begin
    Constellation := TConstellation(Galaxy.Constellations[I]);
    for J := 0 to Constellation.OutlinePolygons.CountChain - 1 do
    begin
      Polygon := Constellation.OutlinePolygons.GetChainItem(J);
      for K := 0 to Polygon.Points.Count - 1 do
      begin
        Vertex := Polygon.Points[K];
        GalaxyOrigin.X := Min(GalaxyOrigin.X, Vertex.X);
        GalaxyOrigin.Y := Min(GalaxyOrigin.Y, Vertex.Y);
        Maximum.X := Max(Maximum.X, Vertex.X);
        Maximum.Y := Max(Maximum.Y, Vertex.Y);
      end;
    end;
  end;
  GalaxyExtent.X := Maximum.X - GalaxyOrigin.X;
  GalaxyExtent.Y := Maximum.Y - GalaxyOrigin.Y;
  StarLinks := TPolyLineGI.Create(MapPanel);
  StarLinks.SetDepth(10);
  if GameDataConfig.CountBlocks('StyleConstellation') > 0 then Block := GameDataConfig.GetBlock('StyleConstellation')
  else Block := nil;
  for I := 0 to Galaxy.Constellations.Count - 1 do
  begin
    Constellation := TConstellation(Galaxy.Constellations[I]);
    if Constellation.Visible then
      for J := 0 to Constellation.OutlinePolygons.CountChain - 1 do
      begin
        Polygon := Constellation.OutlinePolygons.GetChainItem(J);
        SetLength(Points, Polygon.Points.Count);
        for K := 0 to Polygon.Points.Count - 1 do
        begin
          Vertex := Polygon.Points[K];
          Points[K] := AddPoints(GalaxyPointToMapPoint(Vertex^), BufferOffset);
        end;
        HideBuffer.GraphBuf.FillPolygon32(Points, 0);
      end;
    if not Constellation.Visible then
      for J := 0 to Constellation.OutlineSegments.Count - 1 do
      begin
        Segment := Constellation.OutlineSegments[J];
        First := AddPoints(GalaxyPointToMapPoint(Segment.StartPoint), BufferOffset);
        Second := AddPoints(GalaxyPointToMapPoint(Segment.EndPoint), BufferOffset);
        HideBuffer.GraphBuf.DrawAntialiasedLine(First, Second, $FF008080);
      end;
    if Constellation.Visible then
      if (Block = nil) or (Block.CountParams('DrawLines') <= 0) or ParseEnabledNameGI(Block.GetParam('DrawLines')) then
        for J := 0 to Constellation.StarLinks.Count - 1 do
        begin
          Segment := Constellation.StarLinks[J];
          if (Block = nil) or (Block.CountParams('LinesColor') <= 0) then Color := CurrentPixelFormat.PackNormalizedRgb(1, 1, 0)
          else
          begin
            Text := Block.GetParam('LinesColor');
            Color := CurrentPixelFormat.PackNormalizedRgb(ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
              ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')), ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
          end;
          StarLinks.AddParentLine(GalaxyPointToMapPoint(Segment.StartPoint), GalaxyPointToMapPoint(Segment.EndPoint), Color, Constellation.Id).Animated := True;
        end;
  end;
  for I := 0 to Galaxy.Constellations.Count - 1 do
  begin
    Constellation := TConstellation(Galaxy.Constellations[I]);
    if Constellation.Visible then
      for J := 0 to Constellation.OutlineSegments.Count - 1 do
      begin
        Segment := Constellation.OutlineSegments[J];
        if Galaxy.CountVisibleConstellationsWithBoundaryPoints(Segment.StartPoint, Segment.EndPoint) <= 1 then
          HideBuffer.GraphBuf.DrawAntialiasedLine(AddPoints(GalaxyPointToMapPoint(Segment.StartPoint), BufferOffset), AddPoints(GalaxyPointToMapPoint(Segment.EndPoint), BufferOffset), $FFFFFF00)
        else
          HideBuffer.GraphBuf.DrawAntialiasedLine(AddPoints(GalaxyPointToMapPoint(Segment.StartPoint), BufferOffset), AddPoints(GalaxyPointToMapPoint(Segment.EndPoint), BufferOffset), $FF000090);
      end;
  end;
  for I := 0 to Galaxy.Constellations.Count - 1 do
  begin
    Constellation := TConstellation(Galaxy.Constellations[I]);
    if (Constellation.OutlineSegments <> nil) and (Constellation.OutlineSegments.Count <> 0) then
    begin
      if not Constellation.Visible then
      begin
        First := GalaxyPointToMapPoint(Constellation.CalculateLabelPosition);
        NameLabel := TLabelGI.Create(MapPanel);
        NameLabel.SetFontName(BigFontName);
        NameLabel.SetDepth(100);
        NameLabel.SetTextAlignX(taxCenter);
        NameLabel.SetTextAlignY(tayCenter);
        NameLabel.SetPositionModeW(False);
        NameLabel.SetSize(Classes.Point(250, 40));
        NameLabel.SetPosition(Classes.Point(First.X - 125, First.Y - 20));
        NameLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes($DB, $DA, $9C));
        NameLabel.SetTextBorderWidth(1);
        NameLabel.SetTextBorderColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
        if GiResourceVariant = 1 then NameLabel.SetShadowOffset(2)
        else NameLabel.SetShadowOffset(3);
        NameLabel.SetText(Constellation.GetName);
      end
      else
      begin
        First := GalaxyPointToMapPoint(Constellation.CalculateLabelPosition);
        NameLabel := TLabelGI.Create(MapPanel);
        NameLabel.SetFontName(BigFontName);
        NameLabel.SetDepth(1000);
        NameLabel.SetTextAlignX(taxCenter);
        NameLabel.SetTextAlignY(tayCenter);
        NameLabel.SetPositionModeW(False);
        NameLabel.SetSize(Classes.Point(200, 40));
        NameLabel.SetPosition(Classes.Point(First.X - 100, First.Y - 20));
        NameLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes($55, $66, $6E));
        NameLabel.SetText(Constellation.GetName);
      end;
    end;
  end;
  StarLinks.SetPositionModeW(False);
  StarLinks.SetActive(True);
  Block := GameDataConfig.GetBlock('GalaxyStar');
  StarImageCount := Block.GetParamCount;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if Star.IsConstellationVisible then
    begin
      StarImage := TgaiGI.Create(MapPanel);
      StarImage.SetImagePath(Block.GetParamValue(Integer(Star.GenerationSeed) mod StarImageCount));
      StarImage.SetSize(StarImage.GetContentSize);
      StarImage.SetOrigin(HalfPoint(StarImage.ClientSize));
      StarImage.SetPosition(GalaxyPointToMapPoint(Star.Position));
      StarImage.SetDepth(5);
      StarImage.SetPositionModeW(True);
      StarImage.SequenceIndex := 0;
      StarImage.UpdateAutoGeometry;
      StarImage.SetSequenceFrame(RandomIntRange(0, StarImage.SequenceFrameCount - 1));
      StarImage.SetName('gs_' + IntToStr(Star.Id));
      StarImage.UserValue := 1;
      StarImage.RestartPlayback;
      NameLabel := TLabelGI.Create(MapPanel);
      NameLabel.SetFontName(NormalBoldFontName);
      NameLabel.SetDepth(6);
      case GalaxyMapFontChoice of
        gmfRanger: NameLabel.SetFontName(RangerFontName);
        gmfMini: NameLabel.SetFontName(MiniFontName);
        gmfSmall: NameLabel.SetFontName(SmallFontName);
        gmfSmallBold: NameLabel.SetFontName(SmallBoldFontName);
        gmfNormal: NameLabel.SetFontName(NormalFontName);
        gmfNormalBold: NameLabel.SetFontName(NormalBoldFontName);
      else NameLabel.SetFontName(NormalBoldFontName);
      end;
      NameLabel.SetSize(Classes.Point(150, 1));
      NameLabel.SetTextAlignX(taxCenter);
      NameLabel.SetTextAlignY(tayAuto);
      NameLabel.SetPosition(Classes.Point(StarImage.LocalPosition.X - NameLabel.ClientSize.X div 2,
        StarImage.LocalPosition.Y + StarImage.ClientSize.Y div 2 - 5));
      NameLabel.SetPositionModeW(False);
      Planet := Star.Planets[0];
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        if Planet.OwnerId <> oiUninhabited then Break;
      end;
      Text := Star.Name;
      if Star.Status.CustomFaction <> '' then ColoredName := WrapTextInColor(Text, LookupNamedColorTag(Star.Status.CustomFaction))
      else
      begin
        ColoredName := '';
        J := 1;
        K := Length(Star.Name) div Star.CountDistinctInhabitedPlanetOwners;
        ColoredName := ColoredName + WrapTextInColor(Copy(Text, 1, K), OwnerInfo[Planet.OwnerId].ColorTag);
        Delete(Text, 1, K);
        if Text <> '' then
          for OwnerId := oiMaloc to oiPirate do
            if (OwnerId <> oiUninhabited) and (Star.CountPlanetsByOwner(OwnerId) > 0) and (Planet.OwnerId <> OwnerId) then
            begin
              K := Length(Star.Name) div Star.CountDistinctInhabitedPlanetOwners;
              Inc(J);
              if J = Star.CountDistinctInhabitedPlanetOwners then K := Length(Text);
              ColoredName := ColoredName + WrapTextInColor(Copy(Text, 1, K), OwnerInfo[OwnerId].ColorTag);
              Delete(Text, 1, K);
            end;
      end;
      ColoredName := ColoredName + Star.MapLabel;
      ForceLabel := TLabelGI.Create(MapPanel);
      ForceLabel.SetFontName(MiniFontName);
      ForceLabel.SetDepth(6);
      ForceLabel.SetSize(Classes.Point(150, 1));
      ForceLabel.SetTextAlignX(taxCenter);
      ForceLabel.SetTextAlignY(tayAuto);
      ForceLabel.SetPositionModeW(False);
      ForceText := '';
      BossText := '';
      if CanShowExtendedRadarInfo(Star) then
      begin
        CoalitionCount := Star.CountForcesByOwnerGroups(Strength, True, False, False, False);
        BlazerCount := Star.CountDominatorForces(dsBlazer, False, False, Strength);
        KellerCount := Star.CountDominatorForces(dsKeller, False, False, Strength);
        TerronCount := Star.CountDominatorForces(dsTerron, False, False, Strength);
        PirateCount := Star.CountPirateForces(False, Strength, True, True);
        CustomCount := Star.CountCustomFactionForces(False, CustomFaction, Strength);
        OtherCount := Star.CountOtherCustomFactionForces(False, OtherFaction, Strength);
        if (BlazerShip <> nil) and (BlazerShip.CurrentStar = Star) and BlazerShip.InNormalSpace then
        begin
          if CanRevealBossPresence(BlazerShip) and GetPlayer.CanResolveObjectWithScanner(BlazerShip) then
          begin
            if Length(BossText) > 0 then BossText := BossText + '-';
            BossText := BossText + WrapTextInColor(LocalizedText('FormGalaxy.Boss1')[1], RedColorTag);
          end
          else Inc(BlazerCount);
        end;
        if (KellerShip <> nil) and (KellerShip.CurrentStar = Star) and KellerShip.InNormalSpace then
        begin
          if CanRevealBossPresence(KellerShip) and GetPlayer.CanResolveObjectWithScanner(KellerShip) then
          begin
            if Length(BossText) > 0 then BossText := BossText + '-';
            BossText := BossText + WrapTextInColor(LocalizedText('FormGalaxy.Boss2')[1], AzureColorTag);
          end
          else Inc(KellerCount);
        end;
        if (TerronShip <> nil) and (TerronShip.CurrentStar = Star) and TerronShip.InNormalSpace then
        begin
          if CanRevealBossPresence(TerronShip) and GetPlayer.CanResolveObjectWithScanner(TerronShip) then
          begin
            if Length(BossText) > 0 then BossText := BossText + '-';
            BossText := BossText + WrapTextInColor(LocalizedText('FormGalaxy.Boss3')[1], GreenColorTag);
          end
          else Inc(TerronCount);
        end;
        if CoalitionCount > 0 then
        begin
          if Length(ForceText) > 0 then ForceText := ForceText + '-';
          ForceText := ForceText + WrapTextInColor(IntToStr(CoalitionCount), TextHighlightColorTag);
        end;
        if BlazerCount > 0 then
        begin
          if Length(ForceText) > 0 then ForceText := ForceText + '-';
          ForceText := ForceText + WrapTextInColor(IntToStr(BlazerCount), RedColorTag);
        end;
        if KellerCount > 0 then
        begin
          if Length(ForceText) > 0 then ForceText := ForceText + '-';
          ForceText := ForceText + WrapTextInColor(IntToStr(KellerCount), AzureColorTag);
        end;
        if TerronCount > 0 then
        begin
          if Length(ForceText) > 0 then ForceText := ForceText + '-';
          ForceText := ForceText + WrapTextInColor(IntToStr(TerronCount), GreenColorTag);
        end;
        if PirateCount > 0 then
        begin
          if Length(ForceText) > 0 then ForceText := ForceText + '-';
          ForceText := ForceText + WrapTextInColor(IntToStr(PirateCount), GalaxySummaryWhiteColorTag);
        end;
        if CustomCount > 0 then
        begin
          if Length(ForceText) > 0 then ForceText := ForceText + '-';
          ForceText := ForceText + WrapTextInColor(IntToStr(CustomCount), LookupNamedColorTag(CustomFaction));
        end;
        if OtherCount > 0 then
        begin
          if Length(ForceText) > 0 then ForceText := ForceText + '-';
          if OtherFaction <> '' then ForceText := ForceText + WrapTextInColor(IntToStr(OtherCount), LookupNamedColorTag(OtherFaction))
          else ForceText := ForceText + WrapTextInColor(IntToStr(OtherCount), GrayColorTag);
        end;
        if Length(BossText) > 0 then
        begin
          if Length(ForceText) > 0 then ForceText := ForceText + '-';
          ForceText := ForceText + BossText;
        end;
      end;
      NameLabel.SetText(ColoredName);
      ForceLabel.SetText(ForceText);
      ForceLabel.SetPosition(Classes.Point(NameLabel.LocalPosition.X, NameLabel.LocalPosition.Y + ForceLabel.ClientSize.Y + 2));
      Star.GetControlPresence(PlayerPartyPresent, CoalitionPresent, DominatorsPresent, PiratesPresent, CustomPresent);
      if CustomPresent then DominatorsPresent := True;
      if (Star.Battle <> 0) and (not PlayerPartyPresent or ((CoalitionPresent or PiratesPresent) and
        (PiratesPresent or DominatorsPresent) and (CoalitionPresent or DominatorsPresent))) then
      begin
        BattleRing := TgaiGI.Create(MapPanel);
        BattleRing.SetImagePath('Bm.FormGalaxy.RedRing');
        BattleRing.SetSize(BattleRing.GetContentSize);
        BattleRing.SetOrigin(Classes.Point(BattleRing.ClientSize.X div 2, BattleRing.ClientSize.Y div 2));
        BattleRing.SetPosition(GalaxyPointToMapPoint(Star.Position));
        BattleRing.SetDepth(4);
        BattleRing.SetPositionModeW(True);
        BattleRing.SequenceIndex := 0;
        BattleRing.UpdateAutoGeometry;
        BattleRing.RestartPlayback;
        StarImage := TgaiGI.Create(MapPanel);
        if (CoalitionPresent and PiratesPresent) and DominatorsPresent then StarImage.SetImagePath('Bm.FormGalaxy.BattleRoyale')
        else if CoalitionPresent and PiratesPresent then StarImage.SetImagePath('Bm.FormGalaxy.BattleNormalsVsPirates')
        else if CoalitionPresent and DominatorsPresent then StarImage.SetImagePath('Bm.FormGalaxy.BattleNormalsVsDominators')
        else if PiratesPresent and DominatorsPresent then StarImage.SetImagePath('Bm.FormGalaxy.BattlePiratesVsDominators')
        else StarImage.SetImagePath('Bm.FormGalaxy.Defend');
        StarImage.SetSize(StarImage.GetContentSize);
        StarImage.SetOrigin(Classes.Point(StarImage.ClientSize.X div 2, StarImage.ClientSize.Y div 2));
        StarImage.SetPosition(AddPoints(GalaxyPointToMapPoint(Star.Position), Classes.Point(BattleRing.ClientSize.X div 2 - 5, -BattleRing.ClientSize.Y div 2 + 5)));
        StarImage.SetDepth(3);
        StarImage.SetPositionModeW(True);
        StarImage.SequenceIndex := 0;
        StarImage.UpdateAutoGeometry;
        StarImage.RestartPlayback;
      end;
      SelectedHole := nil;
      for J := 0 to Galaxy.Holes.Count - 1 do
      begin
        Hole := THole(Galaxy.Holes[J]);
        if (Hole.ArcadeMapName <> 'NoEntry') and (Hole.Star1 = Star) and
          ((SelectedHole = nil) or (THoleSE(SelectedHole.Graphic).GalaxyPriority < THoleSE(Hole.Graphic).GalaxyPriority)) then SelectedHole := Hole;
      end;
      if SelectedHole <> nil then
      begin
        HoleImage := TImageGI.Create(MapPanel);
        HoleImage.SetImagePath(THoleSE(SelectedHole.Graphic).GalaxyImagePath);
        HoleImage.SetSize(HoleImage.GetContentSize);
        HoleImage.SetOrigin(Classes.Point(HoleImage.ClientSize.X div 2, HoleImage.ClientSize.Y div 2));
        HoleImage.SetPosition(AddPoints(GalaxyPointToMapPoint(Star.Position), Classes.Point(HoleImage.ClientSize.X div 2 + 3, HoleImage.ClientSize.Y div 2 + 3)));
        HoleImage.SetDepth(3);
        HoleImage.SetPositionModeW(True);
      end;
    end;
  end;
  with GetByName('PathCurPos') as TgaiGI do
  begin
    SetPosition(GalaxyPointToMapPoint(GetPlayer.CurrentStar.Position));
    SetOrigin(HalfPoint(ClientSize));
    SetActive(True);
    RestartPlayback;
  end;
  Points := nil;
  with GetByName('JampMaxShr') as TCircleGI do
  begin
    SetCenter(GalaxyPointToMapPoint(GetPlayer.CurrentStar.Position));
    if (GetPlayer.GetFuelTanks = nil) or not GetPlayer.CanUseEquipmentTech(GetPlayer.GetFuelTanks) then SetRadius(1)
    else SetRadius(GalaxyDistanceToMapDistance(GetPlayer.JumpRange));
    if ViewMode in [0, 3] then SetRadius(1000);
  end;
  with GetByName('JampMaxColor') as TCircleGI do
  begin
    SetCenter(ToAbsolutePoint(GalaxyPointToMapPoint(GetPlayer.CurrentStar.Position)));
    if (GetPlayer.GetFuelTanks = nil) or not GetPlayer.CanUseEquipmentTech(GetPlayer.GetFuelTanks) then SetRadius(1)
    else SetRadius(GalaxyDistanceToMapDistance(GetPlayer.JumpRange));
    if ViewMode in [0, 3] then SetRadius(1000);
  end;
  with GetByName('RadarDetect') as TCircleGI do
  begin
    if (GetPlayer.GetRadar <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactRadar) > 0) then
    begin
      SetActive(True);
      SetCenter(ToAbsolutePoint(GalaxyPointToMapPoint(GetPlayer.CurrentStar.Position)));
      SetRadius(GalaxyDistanceToMapDistance(GetRadarSummaryRadius));
    end
    else SetActive(False);
  end;
  if ViewMode = 1 then ConfigureReadOnlyMap
  else if ViewMode in [0, 2, 3] then ConfigureJumpSelection;
  if JumpAnimationTimer <> nil then
  begin
    CancelCallbackTimer(JumpAnimationTimer);
    JumpAnimationTimer := nil;
  end;
  JumpAnimationTimer := ScheduleCallbackTimer(20, 20, UpdateJumpAnimations);
  JumpHintAnimationState := 0;
  ShowStarInfo(nil);
  if CapturePreviewOnOpen then
  begin
    with GetByName('PathCurPos') as TgaiGI do SetSequenceFrame(SequenceFrameCount div 2);
    ClearJumpPath;
    (GetByName('ImagePanel') as TImageGI).SetActive(False);
    DrawQueuedUpdateRects;
    First := SubtractPoints(MapPanel.ToAbsolutePoint(GalaxyPointToMapPoint(GetPlayer.CurrentStar.Position)),
      Classes.Point(SecondarySavePreviewGraph.Width shr 1, SecondarySavePreviewGraph.Height shr 1));
    if First.X < MapPanel.HitTestBounds.Left then First.X := MapPanel.HitTestBounds.Left;
    if First.X + SecondarySavePreviewGraph.Width >= MapPanel.HitTestBounds.Right then First.X := MapPanel.HitTestBounds.Right - SecondarySavePreviewGraph.Width;
    if First.Y < MapPanel.HitTestBounds.Top then First.Y := MapPanel.HitTestBounds.Top;
    if First.Y + SecondarySavePreviewGraph.Height >= MapPanel.HitTestBounds.Bottom then First.Y := MapPanel.HitTestBounds.Bottom - SecondarySavePreviewGraph.Height;
    if HardwareRenderingEnabled then
    begin
      CaptureBuffer := TGraphBufGR.Create(False);
      CaptureBuffer.LoadFromScreen(1);
      CopyBgraToRgb24(SecondarySavePreviewGraph.GetPixels, SecondarySavePreviewGraph.PitchBytes,
        AddPointerOffset(CaptureBuffer.GetPixels, CaptureBuffer.PitchBytes * First.Y + First.X * 4),
        CaptureBuffer.PitchBytes, SecondarySavePreviewGraph.Width, SecondarySavePreviewGraph.Height);
      CaptureBuffer.Free;
      CaptureBuffer := nil;
    end
    else
      Ex_OKGF_Convert565toRGB(PAnsiChar(ScreenRenderBuffer.GetPixels) + First.X * 2 + First.Y * ScreenRenderBuffer.PitchBytes,
        ScreenRenderBuffer.PitchBytes, SecondarySavePreviewGraph.GetPixels, SecondarySavePreviewGraph.PitchBytes,
        SavePreviewGraph.Width, SavePreviewGraph.Height);
    RequestClose(1);
  end;
  Galaxy.PrimeIntegrityChecksum(1111);
  MainPanel.RebuildMessageButtons(False);
end;
{ @end $671EA0 }

{ @routine $674B00 TfGalaxy2_OnClose }
procedure TfGalaxy2.OnClose;
begin
  inherited OnClose;
  Galaxy.CheckIntegrityChecksum(1112);
  if (GetPlayer <> nil) and not CapturePreviewOnOpen then GetPlayer.ScriptItemsAct(satOnLeavingForm, nil, nil, 0);
  CapturePreviewOnOpen := False;
  if JumpAnimationTimer <> nil then
  begin
    CancelCallbackTimer(JumpAnimationTimer);
    JumpAnimationTimer := nil;
  end;
  if StarInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(StarInfoHideTimer);
    StarInfoHideTimer := nil;
  end;
  ClearJumpPath;
  if ViewMode in [0, 2, 3] then ClearJumpSelectionCallbacks
  else if ViewMode = 1 then ClearReadOnlyMapCallbacks;
  GetByName('InfoStarPanel').FreeOwnedChildren;
  MapPanel.FreeOwnedChildren;
  HideBuffer.ClearOwnedBuffer;
  MainPanel.OnClose;
  AuxRenderBuffer.Clear;
  ViewMode := 0;
end;
{ @end $674B00 }

{ @routine $674C50 TfGalaxy2_CloseClicked }
procedure TfGalaxy2.CloseClicked(Sender: TObjectGI);
begin
  RequestedScreenId := GalaxyReturnScreenId;
  RequestClose(1);
end;
{ @end $674C50 }

{ @routine $674C7C TfGalaxy2_MainPanelKeyDown }
procedure TfGalaxy2.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
  begin
    if Key = Ord('M') then CloseClicked(nil)
    else if (Key = VK_RETURN) or (Key = Ord('J')) then
    begin
      if not JumpButton.Disabled then JumpClicked(nil);
    end
    else if Key = VK_ESCAPE then CloseClicked(nil)
    else if Key = VK_F11 then
      if not MainPanel.RemoveDismissibleMessages('GOODS') then MainPanel.RemoveDismissibleMessages('');
  end;
end;
{ @end $674C7C }

{ @routine $674D4C TfGalaxy2_MainPanelMouseUp }
procedure TfGalaxy2.MainPanelMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if ClickAutoCloseForm then
    if not (GetByName('ImagePanel') as TImageGI).HitTestPixel(Point) and
      not GetByName('HideBuf').ContainsPoint(Point) and
      not (GetByName('ButExit') as TGraphButtonGI).ContainsPoint(Point) and
      not JumpButton.ContainsPoint(Point) and
      not GetByName('PM_PanelMsg').ContainsPoint(Point) then CloseClicked(nil);
end;
{ @end $674D4C }

{ @routine $674E74 TfGalaxy2_CanShowExtendedRadarInfo }
function TfGalaxy2.CanShowExtendedRadarInfo(Star: TStar): Boolean;
var First, Second: TPointF;
begin
  Result := False;
  if (GetPlayer.GetRadar <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactRadar) > 0) then
  begin
    First := Star.Position;
    Second := GetPlayer.CurrentStar.Position;
    if GetRadarSummaryRadius < Round(Sqrt(Sqr(First.X - Second.X) + Sqr(First.Y - Second.Y))) then Exit;
    Result := True;
  end;
end;
{ @end $674E74 }

{ @routine $674F18 TfGalaxy2_GetRadarSummaryRadius }
function TfGalaxy2.GetRadarSummaryRadius: Integer;
begin
  Result := Round(GetPlayer.GetRadarRange / 150);
end;
{ @end $674F18 }

{ @routine $674F4C TfGalaxy2_MapPointToGalaxyPoint }
function TfGalaxy2.MapPointToGalaxyPoint(Point: TPoint): TPointF;
begin
  Result.X := (Point.X - MapPixelBounds.Left) / (MapPixelBounds.Right - MapPixelBounds.Left + 1) * GalaxyExtent.X + GalaxyOrigin.X;
  Result.Y := (Point.Y - MapPixelBounds.Top) / (MapPixelBounds.Bottom - MapPixelBounds.Top + 1) * GalaxyExtent.Y + GalaxyOrigin.Y;
end;
{ @end $674F4C }

{ @routine $674FF4 TfGalaxy2_GalaxyPointToMapPoint }
function TfGalaxy2.GalaxyPointToMapPoint(Point: TPointF): TPoint;
begin
  Result.X := Round((Point.X - GalaxyOrigin.X) / GalaxyExtent.X * (MapPixelBounds.Right - MapPixelBounds.Left + 1)) + MapPixelBounds.Left;
  Result.Y := Round((Point.Y - GalaxyOrigin.Y) / GalaxyExtent.Y * (MapPixelBounds.Bottom - MapPixelBounds.Top + 1)) + MapPixelBounds.Top;
end;
{ @end $674FF4 }

{ @routine $675098 TfGalaxy2_GalaxyDistanceToMapDistance }
function TfGalaxy2.GalaxyDistanceToMapDistance(Distance: Double): Integer;
begin
  Result := Round(Distance / GalaxyExtent.X * (MapPixelBounds.Right - MapPixelBounds.Left + 1));
end;
{ @end $675098 }

{ @routine $6750DC TfGalaxy2_RebuildJumpPath }
procedure TfGalaxy2.RebuildJumpPath;
var
  I, TotalDistance, JumpDistance: Integer;
  ImageSize: TPoint;
  First, Second, DotPoint: TPointF;
  DotImage: TImageGI;
  Length, Distance, Slope, Step, Origin: Double;
  UseY, Reachable: Boolean;
begin
  ClearJumpPath;
  with GetByName('PathCurPos') as TgaiGI do
  begin
    SetPosition(GalaxyPointToMapPoint(GetPlayer.CurrentStar.Position));
    SetOrigin(HalfPoint(ClientSize));
    SetActive(True);
    RestartPlayback;
  end;
  (GetByName('Distance') as TLabelGI).SetText('');
  if (GetPlayer.CurrentStar <> SelectedJumpStar) and (SelectedJumpStar <> nil) then
  begin
    with GetByName('PathDesPos') as TgaiGI do
    begin
      SetPosition(GalaxyPointToMapPoint(SelectedJumpStar.Position));
      SetOrigin(HalfPoint(ClientSize));
      SetActive(True);
      RestartPlayback;
    end;
    First := PointToPointF(GalaxyPointToMapPoint(SelectedJumpStar.Position));
    Second := PointToPointF(GalaxyPointToMapPoint(GetPlayer.CurrentStar.Position));
    if Abs(First.X - Second.X) < Abs(First.Y - Second.Y) then UseY := True else UseY := False;
    Length := Sqrt((First.X - Second.X) * (First.X - Second.X) + (First.Y - Second.Y) * (First.Y - Second.Y));
    if UseY then
    begin
      Slope := (Second.X - First.X) / (Second.Y - First.Y);
      Step := 1 / Sqrt(Slope * Slope + 1);
      if Second.Y - First.Y < 0 then Step := -Step;
      Origin := First.Y;
    end
    else
    begin
      Slope := (Second.Y - First.Y) / (Second.X - First.X);
      Step := 1 / Sqrt(Slope * Slope + 1);
      if Second.X - First.X < 0 then Step := -Step;
      Origin := First.X;
    end;
    Distance := 0;
    while Distance < Length do
    begin
      if UseY then
      begin
        DotPoint.Y := Distance * Step + Origin;
        DotPoint.X := (DotPoint.Y - First.Y) * Slope + First.X;
      end
      else
      begin
        DotPoint.X := Distance * Step + Origin;
        DotPoint.Y := (DotPoint.X - First.X) * Slope + First.Y;
      end;
      DotImage := TImageGI.Create(MapPanel);
      DotImage.SetDepth(1);
      DotImage.SetPosition(TruncatePointF(DotPoint));
      DotImage.SetPositionModeW(True);
      DotImage.SetImagePath('GI,Bm.PI.Path1');
      ImageSize := DotImage.GetContentSize;
      DotImage.SetOrigin(Classes.Point(ImageSize.X div 2, ImageSize.Y div 2));
      DotImage.SetSize(ImageSize);
      Distance := Distance + 10;
    end;

    First := PointToPointF(GalaxyPointToMapPoint(SelectedJumpStar.Position));
    for I := 0 to RouteStars.Count - 1 do
    begin
      Second := PointToPointF(GalaxyPointToMapPoint(TStar(RouteStars[I]).Position));
      if Abs(First.X - Second.X) < Abs(First.Y - Second.Y) then UseY := True else UseY := False;
      Length := Sqrt((First.X - Second.X) * (First.X - Second.X) + (First.Y - Second.Y) * (First.Y - Second.Y));
      if UseY then
      begin
        Slope := (Second.X - First.X) / (Second.Y - First.Y);
        Step := 1 / Sqrt(Slope * Slope + 1);
        if Second.Y - First.Y < 0 then Step := -Step;
        Origin := First.Y;
      end
      else
      begin
        Slope := (Second.Y - First.Y) / (Second.X - First.X);
        Step := 1 / Sqrt(Slope * Slope + 1);
        if Second.X - First.X < 0 then Step := -Step;
        Origin := First.X;
      end;
      Distance := 0;
      while Distance < Length do
      begin
        if UseY then
        begin
          DotPoint.Y := Distance * Step + Origin;
          DotPoint.X := (DotPoint.Y - First.Y) * Slope + First.X;
        end
        else
        begin
          DotPoint.X := Distance * Step + Origin;
          DotPoint.Y := (DotPoint.X - First.X) * Slope + First.Y;
        end;
        DotImage := TImageGI.Create(MapPanel);
        DotImage.SetDepth(1);
        DotImage.SetPosition(TruncatePointF(DotPoint));
        DotImage.SetPositionModeW(True);
        DotImage.SetImagePath('GI,Bm.PI.Path2');
        ImageSize := DotImage.GetContentSize;
        DotImage.SetOrigin(Classes.Point(ImageSize.X div 2, ImageSize.Y div 2));
        DotImage.SetSize(ImageSize);
        Distance := Distance + 10;
      end;
      First := Second;
    end;
    Reachable := True;
    if RouteStars.Count <= 0 then
    begin
      First := SelectedJumpStar.Position;
      Second := GetPlayer.CurrentStar.Position;
      with GetByName('Distance') as TLabelGI do
      begin
        ImageSize := GalaxyPointToMapPoint(SelectedJumpStar.Position);
        SetPosition(Classes.Point(ImageSize.X + 15, ImageSize.Y - ClientSize.Y div 2));
        JumpDistance := Round(Sqrt(Sqr(First.X - Second.X) + Sqr(First.Y - Second.Y)));
        if GetPlayer.GetJumpRange < JumpDistance then Reachable := ViewMode in [0, 3];
        SetText(IntToStr(JumpDistance));
      end;
    end
    else
    begin
      First := GetPlayer.CurrentStar.Position;
      Second := SelectedJumpStar.Position;
      TotalDistance := Round(Sqrt(Sqr(First.X - Second.X) + Sqr(First.Y - Second.Y)));
      if GetPlayer.GetJumpRange < TotalDistance then Reachable := ViewMode in [0, 3];
      First := Second;
      for I := 0 to RouteStars.Count - 1 do
      begin
        Second := TStar(RouteStars[I]).Position;
        JumpDistance := Round(Sqrt(Sqr(First.X - Second.X) + Sqr(First.Y - Second.Y)));
        if GetPlayer.GetJumpRange < JumpDistance then Reachable := ViewMode in [0, 3];
        TotalDistance := TotalDistance + JumpDistance;
        First := Second;
      end;
      with GetByName('Distance') as TLabelGI do
      begin
        ImageSize := GalaxyPointToMapPoint(First);
        SetPosition(Classes.Point(ImageSize.X + 15, ImageSize.Y - ClientSize.Y div 2));
        SetText(IntToStr(TotalDistance));
      end;
    end;
    with GetByName('Distance') as TLabelGI do
      if Reachable then SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255))
      else SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 0, 0));
  end;
end;
{ @end $6750DC }

{ @routine $675BA0 TfGalaxy2_ClearJumpPath }
procedure TfGalaxy2.ClearJumpPath;
var Control, Current: TObjectGI;
begin
  Control := MapPanel.FirstChild;
  while Control <> nil do
  begin
    Current := Control;
    Control := Control.NextSibling;
    if Current.Depth = 1.0 then
    begin
      Current.SetActive(False);
      Current.Free;
    end;
  end;
  GetByName('PathDesPos').SetActive(False);
end;
{ @end $675BA0 }

{ @routine $675C30 TfGalaxy2_ConfigureReadOnlyMap }
procedure TfGalaxy2.ConfigureReadOnlyMap;
begin
  with JumpButton do
  begin
    SetDisabled(True);
    UpCallback := nil;
    MouseEnterCallback := nil;
    MouseLeaveCallback := nil;
  end;
  MapPanel.LeftButtonDownCallback := MapLeftButtonDown;
  MapPanel.LeftButtonUpCallback := MapButtonUp;
  MapPanel.MouseMoveCallback := MapMouseMove;
  MapPanel.RightButtonDownCallback := MapRightButtonDown;
  MapPanel.RightButtonUpCallback := MapButtonUp;
  SelectedJumpStar := GetPlayer.CurrentStar;
  RebuildJumpPath;
end;
{ @end $675C30 }

{ @routine $675D2C TfGalaxy2_ClearReadOnlyMapCallbacks }
procedure TfGalaxy2.ClearReadOnlyMapCallbacks;
begin
  MapPanel.LeftButtonDownCallback := nil;
  MapPanel.MouseMoveCallback := nil;
end;
{ @end $675D2C }

{ @routine $675D64 TfGalaxy2_ConfigureJumpSelection }
procedure TfGalaxy2.ConfigureJumpSelection;
begin
  MapPanel.LeftButtonDownCallback := MapLeftButtonDown;
  MapPanel.LeftButtonUpCallback := MapButtonUp;
  MapPanel.MouseMoveCallback := MapMouseMove;
  MapPanel.RightButtonDownCallback := MapRightButtonDown;
  MapPanel.RightButtonUpCallback := MapButtonUp;
  with JumpButton do
  begin
    SetDisabled(False);
    UpCallback := JumpClicked;
    MouseEnterCallback := JumpMouseEnter;
    MouseLeaveCallback := JumpMouseLeave;
  end;
  MapPanel.LeftButtonDoubleClickCallback := MapDoubleClick;
  if (GetPlayer.Order = soJump) and (GetPlayer.OrderTarget is TStar) then SelectedJumpStar := GetPlayer.OrderTarget as TStar
  else SelectedJumpStar := GetPlayer.CurrentStar;
  RebuildJumpPath;
  JumpButton.SetDisabled((SelectedJumpStar = nil) or (GetPlayer.CurrentStar = SelectedJumpStar) or (ViewMode = 1) or GetPlayer.NoJump);
end;
{ @end $675D64 }

{ @routine $675F20 TfGalaxy2_ClearJumpSelectionCallbacks }
procedure TfGalaxy2.ClearJumpSelectionCallbacks;
begin
  ClearJumpPath;
  MapPanel.LeftButtonDownCallback := nil;
  JumpButton.DownCallback := nil;
  MapPanel.MouseMoveCallback := nil;
  MapPanel.LeftButtonDoubleClickCallback := nil;
end;
{ @end $675F20 }

{ @routine $675F90 TfGalaxy2_MapMouseMove }
procedure TfGalaxy2.MapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if Sender.IsOccludedAtPoint(Point) then Exit;
end;
{ @end $675F90 }

{ @routine $675FC0 TfGalaxy2_MapLeftButtonDown }
procedure TfGalaxy2.MapLeftButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Selected, Star: TStar;
  GalaxyPoint: TPointF;
  BestDistance, Distance: Double;
  I: Integer;
begin
  if not IsVirtualKeyDown(VK_MENU) then MapRightButtonDown(Sender, KeyState, Point);
  if Sender.IsOccludedAtPoint(Point) then Exit;
  Point := MapPanel.ToLocalPoint(Point);
  GalaxyPoint := MapPointToGalaxyPoint(Point);
  Selected := nil;
  BestDistance := 1.0e20;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if not Star.IsConstellationVisible then Continue;
    Distance := (Star.Position.X - GalaxyPoint.X) * (Star.Position.X - GalaxyPoint.X) + (Star.Position.Y - GalaxyPoint.Y) * (Star.Position.Y - GalaxyPoint.Y);
    if Distance < BestDistance then
    begin
      Selected := Star;
      BestDistance := Distance;
    end;
  end;
  if (SelectedJumpStar <> nil) and (GetPlayer.CurrentStar <> SelectedJumpStar) and
    (CreateMarkerMode or IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU)) then
  begin
    if BestDistance < (GalaxySizeY * 0.1) * (GalaxySizeY * 0.1) then
    begin
      if (RouteStars.Count < 1) or (RouteStars[RouteStars.Count - 1] <> Selected) then
      begin
        RouteStars.Add(Selected);
        RebuildJumpPath;
      end
      else if (RouteStars.Count > 0) and (RouteStars[RouteStars.Count - 1] = Selected) then
      begin
        RouteStars.Delete(RouteStars.Count - 1);
        RebuildJumpPath;
      end;
    end;
  end
  else
  begin
    RouteStars.Clear;
    if BestDistance < (GalaxySizeY * 0.1) * (GalaxySizeY * 0.1) then SelectedJumpStar := Selected
    else SelectedJumpStar := GetPlayer.CurrentStar;
    RebuildJumpPath;
    JumpButton.SetDisabled((SelectedJumpStar = nil) or (GetPlayer.CurrentStar = SelectedJumpStar) or (ViewMode = 1) or GetPlayer.NoJump);
  end;
end;
{ @end $675FC0 }

{ @routine $6762E4 TfGalaxy2_MapRightButtonDown }
procedure TfGalaxy2.MapRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Selected, Star: TStar;
  GalaxyPoint: TPointF;
  BestDistance, Distance: Double;
  I: Integer;
begin
  if Sender.IsOccludedAtPoint(Point) then Exit;
  Point := MapPanel.ToLocalPoint(Point);
  GalaxyPoint := MapPointToGalaxyPoint(Point);
  BestDistance := 1.0e20;
  Selected := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if not Star.IsConstellationVisible then Continue;
    Distance := (Star.Position.X - GalaxyPoint.X) * (Star.Position.X - GalaxyPoint.X) + (Star.Position.Y - GalaxyPoint.Y) * (Star.Position.Y - GalaxyPoint.Y);
    if Distance < BestDistance then
    begin
      Selected := Star;
      BestDistance := Distance;
    end;
  end;
  if BestDistance >= (GalaxySizeY * 0.1) * (GalaxySizeY * 0.1) then Selected := nil;
  ShowStarInfo(Selected);
end;
{ @end $6762E4 }

{ @routine $67643C TfGalaxy2_MapButtonUp }
procedure TfGalaxy2.MapButtonUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if StarInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(StarInfoHideTimer);
    StarInfoHideTimer := nil;
  end;
  StarInfoHideTimer := ScheduleCallbackTimer(50, 50, HideStarInfo);
end;
{ @end $67643C }

{ @routine $6764AC TfGalaxy2_MapDoubleClick }
procedure TfGalaxy2.MapDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if ViewMode in [0, 2, 3] then
    if not GetPlayer.NoJump then JumpClicked(nil);
end;
{ @end $6764AC }

{ @routine $6764F8 TfGalaxy2_HideStarInfo }
procedure TfGalaxy2.HideStarInfo(Timer: PCallbackTimerGI; UserData: Integer);
begin
  ShowStarInfo(nil);
end;
{ @end $6764F8 }

{ @routine $676518 TfGalaxy2_JumpClicked }
procedure TfGalaxy2.JumpClicked(Sender: TObjectGI);
var
  First, Second: TPointF;
  Hole: THole;
  Angle, Radius: Double;
  Event: TGalaxyEvent;
begin
  if (GetPlayer.CurrentStar = SelectedJumpStar) or (SelectedJumpStar = nil) then Exit;
  if ViewMode = 2 then
  begin
    if GetPlayer.Speed <= 0 then
    begin
      ShowMessageBoxGI(Self, LocalizedColorText('Help.Speed0'), mbgCancel or mbgError);
      Exit;
    end;
    if not GetPlayer.HasPositiveSpeed then Exit;
    First := SelectedJumpStar.Position;
    Second := GetPlayer.CurrentStar.Position;
    Galaxy.CheckIntegrityChecksum(149);
    if GetPlayer.JumpRange < Round(Sqrt(Sqr(First.X - Second.X) + Sqr(First.Y - Second.Y))) then
    begin
      GetPlayer.OrderNone(False);
      Galaxy.PrimeIntegrityChecksum(152);
      ShowMessageBoxGI(Self, FormatText1(LocalizedText('FormGalaxy.NeedFuelOrEngine'),
        TextHighlightColorTag, '<Star>', SelectedJumpStar.Name), mbgCancel or mbgError);
      if Sender <> nil then BreakUiMessage;
      Exit;
    end
    else GetPlayer.OrderJump(SelectedJumpStar, False);
  end
  else if ViewMode = 3 then
  begin
    Galaxy.CheckIntegrityChecksum(153);
    Hole := THole.Create;
    Hole.InitializeGraphic('');
    THoleSE(Hole.Graphic).SetState(1);
    Hole.Star1 := GetPlayer.CurrentStar;
    Angle := ArcTan2(GetPlayer.Position.X, -GetPlayer.Position.Y);
    Radius := Max(GetPlayer.CurrentStar.SafeRadius + 100, Sqrt(PointDistanceSquared(GetPlayer.Position, MakePointF(0, 0))) + 200);
    Hole.Position1 := MakePointF(Sin(Angle) * Radius, -Cos(Angle) * Radius);
    Hole.Star2 := SelectedJumpStar;
    Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
    Radius := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
    Hole.Position2 := MakePointF(Sin(Angle) * Radius, -Cos(Angle) * Radius);
    Hole.CreatedTurn := Galaxy.CurrentTurn - 190;
    Hole.HoleType := 1;
    StarMapScreen.PendingHoleRefresh := Hole;
    Galaxy.Holes.Add(Hole);
    Hole.ArcadeMapName := 'SkipAB';
    GetPlayer.OrderJumpHole(Hole, False);
    GetPlayer.GetHull.Energy := Max(0, GetPlayer.GetHull.Energy - 600);
    Event := AddGalaxyEvent('PlayerCreatedStarDestroyerBH');
    Event.AddData(Hole.Id);
    Event.AddData(Hole.CreatedTurn);
  end
  else if ViewMode = 0 then
  begin
    Galaxy.CheckIntegrityChecksum(153);
    GetPlayer.OrderTeleport(SelectedJumpStar, GetPlayer.Position, 10, False);
  end
  else Galaxy.CheckIntegrityChecksum(152);
  PendingPlayerFollowTarget := nil;
  Galaxy.PrimeIntegrityChecksum(154);
  SpaceViewPosition := GetPlayer.Position;
  RequestedScreenId := screenStarMap;
  RequestClose(1);
end;
{ @end $676518 }

{ @routine $676B74 TfGalaxy2_JumpMouseEnter }
procedure TfGalaxy2.JumpMouseEnter(Sender: TObjectGI);
var First, Second: TPointF;
begin
  if ViewMode = 0 then Exit;
  if ViewMode = 2 then
  begin
    if (GetPlayer.CurrentStar = SelectedJumpStar) or (SelectedJumpStar = nil) then Exit;
    if not GetPlayer.HasPositiveSpeed then Exit;
    First := SelectedJumpStar.Position;
    Second := GetPlayer.CurrentStar.Position;
    if GetPlayer.JumpRange < Round(Sqrt(Sqr(First.X - Second.X) + Sqr(First.Y - Second.Y))) then Exit;
  end;
  JumpDestinationLabel.SetText(ReplaceAllWideString(LocalizedText('FormGalaxy.JumpTo'), '<Name>', SelectedJumpStar.Name));
  if JumpHintAnimationState = 0 then JumpHintAnimationState := 1
  else if JumpHintAnimationState = 4 then JumpHintAnimationState := 3
  else if JumpHintAnimationState = 5 then JumpHintAnimationState := 2;
end;
{ @end $676B74 }

{ @routine $676D58 TfGalaxy2_JumpMouseLeave }
procedure TfGalaxy2.JumpMouseLeave(Sender: TObjectGI);
begin
  if JumpHintAnimationState = 1 then JumpHintAnimationState := 0
  else if JumpHintAnimationState = 2 then JumpHintAnimationState := 5
  else if JumpHintAnimationState = 3 then JumpHintAnimationState := 4;
end;
{ @end $676D58 }

{ @routine $676DB8 TfGalaxy2_ShowStarInfo }
procedure TfGalaxy2.ShowStarInfo(Star: TStar);
var
  InfoPanel: TWindowGI;
  UnusedControl: TObjectGI; // Native O- frame retains this unused slot at -$10.
  Owner: TPanelGI;
  Objects: TList;
  I, J, RowHeight, IconX: Integer;
  IconInset: Cardinal;
  NameWidth, DetailWidth, RowCount, SummaryLines: Integer;
  ObjectDistance: Single;
  OwnerId: TOwnerId;
  CurrentChild: TObjectGI;
  Planet: TPlanet;
  CustomInfo: TCustomSystemInfo;
  Value: WideString;
begin
  if (Star <> nil) and (GetPlayer <> nil) then GetPlayer.ScriptItemsAct(satOnShowingStarInfo, Star, nil, 0);
  if StarInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(StarInfoHideTimer);
    StarInfoHideTimer := nil;
  end;
  InfoPanel := TWindowGI(GetByName('InfoStar'));
  if Star = nil then
  begin
    InfoPanel.SetActive(False);
    Exit;
  end;
  InfoPanel.SetActive(True);
  with GetByName('InfoStarImage') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TStarSE(Star.Graphic).StaticImagePath, 1, ','), GraphBuf);
    if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
      GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
    else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  Owner := GetByName('InfoStarPanel') as TPanelGI;
  Owner.FreeOwnedChildren;
  Owner.SetSize(Classes.Point(InfoPanel.ClientSize.X - InfoPanel.WorkSubRect.Left - InfoPanel.WorkSubRect.Right, Owner.ClientSize.Y));
  Objects := TList.Create;
  for I := 0 to Star.Planets.Count - 1 do Objects.Add(Star.Planets[I]);
  for I := 0 to Star.Ships.Count - 1 do
    if TObject(Star.Ships[I]) is TRuins then
      if (TObject(Star.Ships[I]) as TRuins).InNormalSpace then
        if ((TObject(Star.Ships[I]) as TRuins).Graphic is TRuinsSE) or
          (((TObject(Star.Ships[I]) as TRuins).Graphic is TShip2SE) and
          (((TObject(Star.Ships[I]) as TRuins).Graphic as TShip2SE).AlternateImagePath <> '')) then
        begin
          ObjectDistance := PointDistanceSquared(TShip(Star.Ships[I]).Position, MakePointF(0, 0));
          J := 0;
          while J < Objects.Count do
          begin
            if TObject(Objects[J]) is TPlanet then
            begin
              if PointDistanceSquared(TPlanet(Objects[J]).GetPosition, MakePointF(0, 0)) > ObjectDistance then Break;
            end
            else if PointDistanceSquared(TShip(Objects[J]).Position, MakePointF(0, 0)) > ObjectDistance then Break;
            Inc(J);
          end;
          Objects.Insert(J, Star.Ships[I]);
        end;
  for I := 0 to Star.CustomSystemInfos.Count - 1 do
  begin
    CustomInfo := TCustomSystemInfo(Star.CustomSystemInfos[I]);
    ObjectDistance := Sqr(CustomInfo.Distance);
    J := 0;
    while J < Objects.Count do
    begin
      if TObject(Objects[J]) is TPlanet then
      begin
        if PointDistanceSquared(TPlanet(Objects[J]).GetPosition, MakePointF(0, 0)) > ObjectDistance then Break;
      end
      else if TObject(Objects[J]) is TRuins then
      begin
        if PointDistanceSquared(TShip(Objects[J]).Position, MakePointF(0, 0)) > ObjectDistance then Break;
      end
      else if Sqr(TCustomSystemInfo(Objects[J]).Distance) > ObjectDistance then Break;
      Inc(J);
    end;
    Objects.Insert(J, CustomInfo);
  end;
  RowHeight := GiScalePixels(20);
  NameWidth := GiScalePixels(100);
  DetailWidth := GiScalePixels(100);
  for I := 0 to Objects.Count - 1 do
    with TLabelGI.Create(Owner) do
    begin
      SetFontName(NormalFontName);
      SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
      SetSize(Classes.Point(1, RowHeight));
      SetPosition(Classes.Point(0, RowHeight * I));
      SetWordWrapEnabled(False);
      SetTextAlignX(taxAuto);
      SetTextAlignY(tayCenterEx);
      if TObject(Objects[I]) is TPlanet then SetText(TPlanet(Objects[I]).Name)
      else if TObject(Objects[I]) is TShip then SetText(TShip(Objects[I]).Name)
      else SetText(TCustomSystemInfo(Objects[I]).Name);
      NameWidth := Max(NameWidth, ClientSize.X);
    end;
  CurrentChild := Owner.FirstChild;
  while CurrentChild <> nil do
  begin
    if CurrentChild is TLabelGI then
      with CurrentChild as TLabelGI do
      begin
        SetTextAlignX(taxRight);
        SetSize(Classes.Point(NameWidth, RowHeight));
      end;
    CurrentChild := CurrentChild.NextSibling;
  end;
  for I := 0 to Objects.Count - 1 do
  begin
    with TGraphBufGI.Create(Owner, False) do
    begin
      IconInset := 0;
      if TObject(Objects[I]) is TPlanet then
        if (TObject(Objects[I]) as TPlanet).Radius < 70 then IconInset := 4
        else if (TObject(Objects[I]) as TPlanet).Radius < 80 then IconInset := 3
        else if (TObject(Objects[I]) as TPlanet).Radius < 90 then IconInset := 2
        else if (TObject(Objects[I]) as TPlanet).Radius < 100 then IconInset := 1 else IconInset := 0;
      SourceHasPerPixelAlpha := True;
      SetPosition(Classes.Point(NameWidth + 5 + 1 + (IconInset shr 1), RowHeight * I + 1 + (IconInset shr 1)));
      SetSize(Classes.Point(RowHeight - 2 - IconInset, RowHeight - 2 - IconInset));
      if TObject(Objects[I]) is TPlanet then
      begin
        TPlanet(Objects[I]).Graphic.RenderToBuffer(Self, GraphBuf, True);
        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
          GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
        else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
      end
      else if TObject(Objects[I]) is TRuins then
      begin
        if TRuins(Objects[I]).Graphic is TRuinsSE then
          LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((TRuins(Objects[I]).Graphic as TRuinsSE).StaticImagePath, 1, ','), GraphBuf)
        else LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((TRuins(Objects[I]).Graphic as TShip2SE).AlternateImagePath, 1, ','), GraphBuf);
        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
          GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
        else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
      end
      else if TCustomSystemInfo(Objects[I]).Icon <> '' then
      begin
        LoadGiByPathIntoGraphBuf(TCustomSystemInfo(Objects[I]).Icon, GraphBuf);
        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
          GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
        else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
      end;
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
    end;
    if TObject(Objects[I]) is TPlanet then OwnerId := TPlanet(Objects[I]).OwnerId
    else if TObject(Objects[I]) is TRuins then OwnerId := TRuins(Objects[I]).OwnerId
    else OwnerId := oiUninhabited;
    if TObject(Objects[I]) is TRuins then
    begin
      with TLabelGI.Create(Owner) do
      begin
        if GiResourceVariant = 2 then SetFontName(MiniFontName) else SetFontName(SmallFontName);
        SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
        SetSize(Classes.Point(1, RowHeight));
        SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
        SetWordWrapEnabled(False);
        SetTextAlignX(taxAuto);
        SetTextAlignY(tayCenterEx);
        SetText(LowerCaseWideString(TShip(Objects[I]).GetLocalizedTypeName));
        DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
      end;
    end
    else if TObject(Objects[I]) is TCustomSystemInfo then
    begin
      CustomInfo := TCustomSystemInfo(Objects[I]);
      if (CountDelimitedPartsW(CustomInfo.Info, ':') > 1) and (ExtractDelimitedPartW(CustomInfo.Info, 0, ':') = 'Image') then
      begin
        Value := ExtractDelimitedPartW(CustomInfo.Info, 1, ':');
        IconX := NameWidth + 5 + RowHeight + 5 + 1;
        for J := 0 to CountDelimitedPartsW(Value, ',') - 1 do
          with TImageGI.Create(Owner) do
          begin
            SetImagePath('GI,' + ExtractDelimitedPartW(Value, J, ','));
            SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
            SetPosition(Classes.Point(IconX, RowHeight * I + 1));
            IconX := IconX + RowHeight + 2;
          end;
      end
      else if (CountDelimitedPartsW(CustomInfo.Info, ':') > 1) and (ExtractDelimitedPartW(CustomInfo.Info, 0, ':') = 'RGBA') then
      begin
        Value := ExtractDelimitedPartW(CustomInfo.Info, 1, ':');
        IconX := NameWidth + 5 + RowHeight + 5 + 1;
        for J := 0 to CountDelimitedPartsW(Value, ',') - 1 do
          with TGraphBufGI.Create(Owner, False) do
          begin
            SourceHasPerPixelAlpha := True;
            LoadBitmapPathAsRgba(ExtractDelimitedPartW(Value, J, ',') + RgbaImagePathSuffix);
            SetPosition(Classes.Point(IconX, RowHeight * I + 1));
            SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
            if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
            begin
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
              else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            end;
            SetImageKindX(ikxCenter);
            SetImageKindY(ikyCenter);
            IconX := IconX + RowHeight + 2;
          end;
      end
      else
        with TLabelGI.Create(Owner) do
        begin
          if GiResourceVariant = 2 then SetFontName(MiniFontName) else SetFontName(SmallFontName);
          SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
          SetSize(Classes.Point(1, RowHeight));
          SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
          SetWordWrapEnabled(False);
          SetTextAlignX(taxAuto);
          SetTextAlignY(tayCenterEx);
          SetText(CustomInfo.Info);
          DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
        end;
    end
    else if OwnerId <> oiUninhabited then
      if not (TObject(Objects[I]) is TPlanet) or not (TObject(Objects[I]) as TPlanet).IsMainPiratePlanet then
        with TGraphBufGI.Create(Owner, False) do
        begin
          SourceHasPerPixelAlpha := True;
          LoadBitmapPathAsRgba(ExtractDelimitedPartW(GetFactionEmblemPath((TObject(Objects[I]) as TPlanet).GetFactionResourceName), 1, ',') + RgbaImagePathSuffix);
          SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I + 1));
          SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
          if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
            GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
          else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
        end;
    if TObject(Objects[I]) is TPlanet then
    begin
      Planet := TPlanet(Objects[I]);
      if (Planet.OwnerId in [oiMaloc..oiGaal, oiPirate]) and not Planet.IsMainPiratePlanet and (Planet.CurrentStar.Status.CustomFaction = '') then
      begin
        IconX := NameWidth + 5 + RowHeight + 5 + 1;
        with TImageGI.Create(Owner) do
        begin
          case Ord((TObject(Objects[I]) as TPlanet).GetRelationLevelToShip(GetPlayer)) of
            0: SetImagePath('GI,Bm.FormGalaxy2.Face4');
            1: SetImagePath('GI,Bm.FormGalaxy2.Face3');
            2: SetImagePath('GI,Bm.FormGalaxy2.Face2');
            3: SetImagePath('GI,Bm.FormGalaxy2.Face1');
            4: SetImagePath('GI,Bm.FormGalaxy2.Face0');
          else SetImagePath('GI,Bm.FormGalaxy2.Face2');
          end;
          SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
          SetPosition(Classes.Point(IconX + RowHeight + 2, RowHeight * I + 1));
        end;
        IconX := IconX + RowHeight + 2;
        if Planet.Economy in [peAgricultural, peIndustrial] then
          with TImageGI.Create(Owner) do
          begin
            case Planet.Economy of
              peAgricultural: SetImagePath('GI,Bm.FormGalaxy.EconAgrar');
              peIndustrial: SetImagePath('GI,Bm.FormGalaxy.EconIndustr');
            end;
            SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
            SetPosition(Classes.Point(IconX + RowHeight, RowHeight * I + 1));
          end;
      end
      else if Planet.IsMainPiratePlanet then
        with TLabelGI.Create(Owner) do
        begin
          if GiResourceVariant = 2 then SetFontName(MiniFontName) else SetFontName(SmallFontName);
          SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
          SetSize(Classes.Point(1, RowHeight));
          SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
          SetWordWrapEnabled(False);
          SetTextAlignX(taxAuto);
          SetTextAlignY(tayCenterEx);
          SetText(LowerCaseWideString(LocalizedText('ShipType.TypeName.PB')));
          DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
        end
      else if (Planet.OwnerId = oiUninhabited) and (Planet.GetUnexploredSurfaceTileCount = 0) then
        with TLabelGI.Create(Owner) do
        begin
          if GiResourceVariant = 2 then SetFontName(MiniFontName) else SetFontName(SmallFontName);
          SetTextColor(CurrentPixelFormat.PackRgbBytes(140, 140, 140));
          SetSize(Classes.Point(1, RowHeight));
          SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
          SetWordWrapEnabled(False);
          SetTextAlignX(taxAuto);
          SetTextAlignY(tayCenterEx);
          SetText(LowerCaseWideString(LocalizedText('Planet.NotCivil.AllExplore')));
          DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
        end;
    end;
  end;
  RowCount := Objects.Count;
  if CanShowExtendedRadarInfo(Star) then
  begin
    with TLabelGI.Create(Owner) do
    begin
      SetFontName(SmallFontName);
      SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
      SetPosition(Classes.Point(0, RowCount * RowHeight));
      SetWordWrapEnabled(False);
      SetTextAlignX(taxCenter);
      SetTextAlignY(tayCenterEx);
      SetText(BuildStarShipSummary(Star, SummaryLines));
      SetSize(Classes.Point(NameWidth + DetailWidth, RowHeight * SummaryLines));
    end;
    Inc(RowCount, SummaryLines);
  end;
  Owner.SetSize(Classes.Point(NameWidth + DetailWidth, RowCount * RowHeight));
  Owner.SetPosition(InfoPanel.WorkSubRect.TopLeft);
  InfoPanel.SetSize(Classes.Point(Owner.ClientSize.X + InfoPanel.WorkSubRect.Left + InfoPanel.WorkSubRect.Right,
    InfoPanel.WorkSubRect.Top + InfoPanel.WorkSubRect.Bottom + RowCount * RowHeight));
  InfoPanel.UpdateAutoGeometry;
  with GetByName('InfoStarName') as TLabelGI do
  begin
    SetText(WrapTextInColor(Star.Name, InfoNameColorTag));
    SetSize(Classes.Point(InfoPanel.ClientSize.X - InfoPanel.WorkSubRect.Right - LocalPosition.X - 15, ClientSize.Y));
  end;
  Objects.Free;
  for I := 0 to 3 do
  begin
    if I = 0 then
      InfoPanel.SetPosition(AddPoints(MapPanel.ToAbsolutePoint(GalaxyPointToMapPoint(Star.Position)), Classes.Point(-InfoPanel.ClientSize.X - GiScalePixels(50), -InfoPanel.ClientSize.Y - GiScalePixels(50))))
    else if I = 1 then
      InfoPanel.SetPosition(AddPoints(MapPanel.ToAbsolutePoint(GalaxyPointToMapPoint(Star.Position)), Classes.Point(GiScalePixels(50), -InfoPanel.ClientSize.Y - GiScalePixels(50))))
    else if I = 2 then
      InfoPanel.SetPosition(AddPoints(MapPanel.ToAbsolutePoint(GalaxyPointToMapPoint(Star.Position)), Classes.Point(GiScalePixels(50), GiScalePixels(50))))
    else
      InfoPanel.SetPosition(AddPoints(MapPanel.ToAbsolutePoint(GalaxyPointToMapPoint(Star.Position)), Classes.Point(-InfoPanel.ClientSize.X - GiScalePixels(50), GiScalePixels(50))));
    if (InfoPanel.LocalPosition.X >= 0) and (InfoPanel.LocalPosition.Y >= 0) and
      (GameScreenWidth - GiScalePixels(100) >= InfoPanel.LocalPosition.X + InfoPanel.ClientSize.X) and
      (GameScreenHeight - GiScalePixels(100) >= InfoPanel.LocalPosition.Y + InfoPanel.ClientSize.Y) then Break;
  end;
end;
{ @end $676DB8 }

{ @routine $679134 TfGalaxy2_CanRevealBossPresence }
function TfGalaxy2.CanRevealBossPresence(Ship: TShip): Boolean;
var TechLevel: Integer;
begin
  if Ship = nil then begin Result := False; Exit; end;
  if (GetPlayer.GetScanner = nil) or (GetPlayer.GetScanner.BrokenFlag <> 0) then begin Result := False; Exit; end;
  if Ship.TypeId <> stKling then begin Result := True; Exit; end;
  TechLevel := GetPlayer.GetScanner.TechLevel;
  Result := True;
  if (BlazerShip = Ship) and (TechLevel < 7) then begin Result := False; Exit; end;
  if (KellerShip = Ship) and (TechLevel < 5) then begin Result := False; Exit; end;
  if (TerronShip = Ship) and (TechLevel < 3) then begin Result := False; Exit; end;
end;
{ @end $679134 }

{ @routine $6798E0 TfGalaxy2_BuildStarShipSummary }
function TfGalaxy2.BuildStarShipSummary(Star: TStar; var LineCount: Integer): WideString;
var
  Ship: TShip;
  UnknownCount, OtherFactionCount: Integer;
  OtherFaction, StarFaction: WideString;
  StarFactionCount: Integer;
  Kling: TKling;
  DominatorCounts: array[TDominatorSeries, TKlingType] of Integer;
  ScriptedPirates, ScriptedCoalition: Integer;
  RoleCounts: array[0..13] of Integer;
  Transport: TTransport;
  CoalitionTranclucators, PirateTranclucators: Integer;
  CoalitionStations, PirateStations: Integer;
  Series: TDominatorSeries;
  LineActive: Boolean;
  Summary, Line: WideString;
  I, J, GroupIndex: Integer;
  Planet: TPlanet;
  Kind: TKlingType;
  Role: Byte;
  PirateRole: Integer;
  ColorTag: WideString;
  HasSeparator: Boolean;

  // @nested $6791E4 AccumulateShip
  procedure AccumulateShip; cdecl; // @addr $6791E4 @ida "void __cdecl $name(void *ParentFrame);"
  var Faction: WideString;
  begin
    if Ship.InHyperspace then Exit;
    if not GetPlayer.CanResolveObjectWithScanner(Ship) or not CanRevealBossPresence(Ship) then
    begin
      Inc(UnknownCount);
      Exit;
    end;
    if Ship.CurrentStanding = ssCustom then
    begin
      if (Ship.ScriptShip = nil) or (TScriptShip(Ship.ScriptShip).StateText = '') then
      begin
        Inc(OtherFactionCount);
        OtherFaction := '';
      end
      else
      begin
        Faction := TScriptShip(Ship.ScriptShip).StateText;
        if Faction = StarFaction then Inc(StarFactionCount)
        else
        begin
          if OtherFactionCount = 0 then OtherFaction := Faction
          else if OtherFaction <> Faction then OtherFaction := '';
          Inc(OtherFactionCount);
        end;
      end;
    end
    else if Ship.TypeId = stKling then
    begin
      Kling := Ship as TKling;
      Inc(DominatorCounts[Kling.DominatorSeries, Kling.KlingType]);
    end
    else
      case Ship.TypeId of
        stRanger:
          if TRanger(Ship).ExcludedFromRating or Ship.HasScriptStateText then
          begin
            if ((GetPlayer = Ship) or (GetPlayer = Ship.PartnerShip)) and (GetPlayer.OwnerId = oiPirate) then Inc(ScriptedPirates)
            else Inc(ScriptedCoalition);
          end
          else if ((GetPlayer = Ship) or (GetPlayer = Ship.PartnerShip)) and (GetPlayer.OwnerId = oiPirate) then Inc(RoleCounts[11])
          else Inc(RoleCounts[0]);
        stPirate:
          if Ship.HasScriptStateText then
          begin
            if Ship.OwnerId = oiPirate then Inc(ScriptedPirates)
            else Inc(ScriptedCoalition);
          end
          else if Ship.OwnerId <> oiPirate then Inc(RoleCounts[2])
          else
          begin
            if TPirate(Ship).PirateType <> 0 then Inc(RoleCounts[12])
            else Inc(RoleCounts[13]);
          end;
        stWarrior:
          if Ship.HasScriptStateText then Inc(ScriptedCoalition)
          else if (Ship as TWarrior).WarriorType = wtFlagship then Inc(RoleCounts[10])
          else Inc(RoleCounts[1]);
        stTransport:
          begin
            Transport := Ship as TTransport;
            if Ship.HasScriptStateText then Inc(ScriptedCoalition)
            else
              case Transport.TransportType of
                ttTransport: Inc(RoleCounts[3]);
                ttLiner: Inc(RoleCounts[4]);
                ttDiplomat: Inc(RoleCounts[5]);
              end;
          end;
        stTranclucator:
          if Ship.HasScriptStateText then
          begin
            if (Ship as TTranclucator).OwnerShip = nil then Inc(ScriptedCoalition)
            else
            begin
              if (Ship as TTranclucator).OwnerShip.OwnerId in PlanetOwnerMasks.Coalition then Inc(ScriptedCoalition)
              else if (Ship as TTranclucator).OwnerShip.OwnerId in PlanetOwnerMasks.PirateClan then Inc(ScriptedPirates);
            end;
          end
          else if (Ship as TTranclucator).OwnerShip = nil then Inc(CoalitionTranclucators)
          else
          begin
            if (Ship as TTranclucator).OwnerShip.OwnerId in PlanetOwnerMasks.Coalition then Inc(CoalitionTranclucators)
            else if (Ship as TTranclucator).OwnerShip.OwnerId in PlanetOwnerMasks.PirateClan then Inc(PirateTranclucators);
          end;
      else
        if Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)] then
          case Star.ControlFaction of
            sfCoalition:
              if Ship.CurrentStanding in [ssCoalitionMilitary..ssPiratePassive] then Inc(CoalitionStations)
              else if Ship.CurrentStanding in [ssPirateActive..ssPirateMilitary] then Inc(PirateStations);
            sfPirates:
              if Ship.CurrentStanding in [ssCoalitionPassive..ssPirateMilitary] then Inc(PirateStations)
              else if Ship.CurrentStanding in [ssCoalitionMilitary..ssCoalitionActive] then Inc(CoalitionStations);
          else
            if Ship.CurrentStanding in [ssCoalitionMilitary..ssNeutral] then Inc(CoalitionStations)
            else if Ship.CurrentStanding in [ssPiratePassive..ssPirateMilitary] then Inc(PirateStations);
          end;
      end;
  end;

  // @nested $6797C8 SeriesColor
  function SeriesColor: WideString; // @addr $6797C8
  begin
    Result := '';
    case Series of
      dsBlazer: Result := RedColorTag;
      dsKeller: Result := AzureColorTag;
      dsTerron: Result := GreenColorTag;
    end;
  end;

  // @nested $67988C AppendLine
  procedure AppendLine; cdecl; // @addr $67988C @ida "void __cdecl $name(void *ParentFrame);"
  begin
    if LineActive then
    begin
      Summary := Summary + Line + #13#10;
      Inc(LineCount);
    end;
  end;

begin
  UnknownCount := 0;
  OtherFactionCount := 0;
  StarFactionCount := 0;
  CoalitionTranclucators := 0;
  PirateTranclucators := 0;
  CoalitionStations := 0;
  PirateStations := 0;
  ScriptedCoalition := 0;
  ScriptedPirates := 0;
  StarFaction := Star.Status.CustomFaction;
  OtherFaction := '';
  Summary := '';
  for Series := dsBlazer to dsTerron do
    for Kind := Low(TKlingType) to High(TKlingType) do DominatorCounts[Series, Kind] := 0;
  for Role := 0 to 10 do RoleCounts[Role] := 0;
  for I := 0 to Star.Ships.Count - 1 do
  begin
    Ship := Star.Ships[I];
    if (Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> oiUninhabited) then AccumulateShip;
  end;
  for I := 0 to Star.Planets.Count - 1 do
  begin
    Planet := Star.Planets[I];
    for J := 0 to Planet.Warriors.Count - 1 do
    begin
      Ship := TShip(Planet.Warriors[J]);
      if (Ship.CurrentStar = Star) and (Star.Ships.IndexOf(Ship) < 0) then AccumulateShip;
    end;
  end;
  Line := '';
  LineActive := False;
  HasSeparator := False;
  for GroupIndex := 1 to 7 do
  begin
    Role := GalaxyMapFriendlyShipOrder[GroupIndex];
    if RoleCounts[Role] > 0 then
    begin
      if HasSeparator then Line := Line + WrapTextInColor('-', GrayColorTag);
      HasSeparator := True;
      LineActive := True;
      Line := Line + WrapTextInColor(LocalizedText('FormGalaxy.FriendShip' + IntToStr(GroupIndex)), GoldColorTag);
      Line := Line + WrapTextInColor(IntToStr(RoleCounts[Role]), GalaxySummaryWhiteColorTag);
    end;
  end;
  if ScriptedCoalition > 0 then
  begin
    if HasSeparator then Line := Line + WrapTextInColor('-', GrayColorTag);
    Line := Line + WrapTextInColor('?', GoldColorTag);
    Line := Line + WrapTextInColor(IntToStr(ScriptedCoalition), GalaxySummaryWhiteColorTag);
    LineActive := True;
  end;
  if (CoalitionStations > 0) or (CoalitionTranclucators > 0) then Line := Line + '     ';
  if CoalitionStations > 0 then
  begin
    Line := Line + WrapTextInColor('(', GrayColorTag);
    Line := Line + WrapTextInColor(IntToStr(CoalitionStations), MagentaColorTag);
    Line := Line + WrapTextInColor(')', GrayColorTag);
    LineActive := True;
  end;
  if CoalitionTranclucators > 0 then
  begin
    Line := Line + WrapTextInColor('(', GrayColorTag);
    Line := Line + WrapTextInColor(IntToStr(CoalitionTranclucators), CyanColorTag);
    Line := Line + WrapTextInColor(')', GrayColorTag);
    LineActive := True;
  end;
  AppendLine;
  Line := '';
  LineActive := False;
  HasSeparator := False;
  for PirateRole := 1 to 3 do
    if RoleCounts[PirateRole + 10] > 0 then
    begin
      if HasSeparator then Line := Line + WrapTextInColor('-', GrayColorTag);
      HasSeparator := True;
      LineActive := True;
      Line := Line + WrapTextInColor(LocalizedText('FormGalaxy.PirateClanShip' + IntToStr(PirateRole)), GalaxySummaryWhiteColorTag);
      Line := Line + WrapTextInColor(IntToStr(RoleCounts[PirateRole + 10]), GalaxySummaryWhiteColorTag);
    end;
  if ScriptedPirates > 0 then
  begin
    if HasSeparator then Line := Line + WrapTextInColor('-', GrayColorTag);
    Line := Line + WrapTextInColor('?', GalaxySummaryWhiteColorTag);
    Line := Line + WrapTextInColor(IntToStr(ScriptedPirates), GalaxySummaryWhiteColorTag);
    LineActive := True;
  end;
  if (PirateStations > 0) or (PirateTranclucators > 0) then Line := Line + '     ';
  if PirateStations > 0 then
  begin
    Line := Line + WrapTextInColor('(', GrayColorTag);
    Line := Line + WrapTextInColor(IntToStr(PirateStations), MagentaColorTag);
    Line := Line + WrapTextInColor(')', GrayColorTag);
    LineActive := True;
  end;
  if PirateTranclucators > 0 then
  begin
    Line := Line + WrapTextInColor('(', GrayColorTag);
    Line := Line + WrapTextInColor(IntToStr(PirateTranclucators), CyanColorTag);
    Line := Line + WrapTextInColor(')', GrayColorTag);
    LineActive := True;
  end;
  AppendLine;
  Line := '';
  if StarFactionCount > 0 then
  begin
    Line := Line + WrapTextInColor('(', GrayColorTag);
    Line := Line + WrapTextInColor(IntToStr(StarFactionCount), LookupNamedColorTag(StarFaction));
    Line := Line + WrapTextInColor(')', GrayColorTag);
    LineActive := True;
  end;
  if OtherFactionCount > 0 then
  begin
    Line := Line + WrapTextInColor('(', GrayColorTag);
    if OtherFaction <> '' then Line := Line + WrapTextInColor(IntToStr(OtherFactionCount), LookupNamedColorTag(OtherFaction))
    else Line := Line + WrapTextInColor(IntToStr(OtherFactionCount), GrayColorTag);
    Line := Line + WrapTextInColor(')', GrayColorTag);
    LineActive := True;
  end;
  AppendLine;
  for Series := dsBlazer to dsTerron do
  begin
    Line := '';
    LineActive := False;
    HasSeparator := False;
    ColorTag := SeriesColor;
    for Kind := Low(TKlingType) to High(TKlingType) do
      if (DominatorDisplayOrder[Ord(Kind)] <> ktBoss) and (DominatorCounts[Series, DominatorDisplayOrder[Ord(Kind)]] > 0) then
      begin
        if HasSeparator then Line := Line + WrapTextInColor('-', GrayColorTag);
        HasSeparator := True;
        LineActive := True;
        Line := Line + WrapTextInColor(LocalizedText('FormGalaxy.DomikShip' + IntToStr(Ord(DominatorDisplayOrder[Ord(Kind)]))), ColorTag);
        Line := Line + WrapTextInColor(IntToStr(DominatorCounts[Series, DominatorDisplayOrder[Ord(Kind)]]), GalaxySummaryWhiteColorTag);
      end;
    AppendLine;
  end;
  Line := '';
  LineActive := False;
  GroupIndex := 1;
  for Series := dsBlazer to dsTerron do
  begin
    ColorTag := SeriesColor;
    if DominatorCounts[Series, ktBoss] > 0 then
    begin
      if LineActive then Line := Line + WrapTextInColor(', ', GrayColorTag);
      Line := Line + WrapTextInColor(LocalizedText('FormGalaxy.Boss' + IntToStr(GroupIndex)), ColorTag);
      LineActive := True;
    end;
    Inc(GroupIndex);
  end;
  AppendLine;
  Line := '';
  LineActive := False;
  if UnknownCount > 0 then
  begin
    Line := Line + WrapTextInColor(LocalizedText('FormGalaxy.UnknowShip') + ': ', GrayColorTag);
    Line := Line + WrapTextInColor(IntToStr(UnknownCount), GalaxySummaryWhiteColorTag);
    LineActive := True;
  end;
  AppendLine;
  Result := Summary;
end;
{ @end $6798E0 }

{ @routine $67AB80 TfGalaxy2_UpdateJumpAnimations }
procedure TfGalaxy2.UpdateJumpAnimations(Timer: PCallbackTimerGI; UserData: Integer);
var
  First, Second: TPointF;
  LightIndex: Integer;
begin
  if JumpHintAnimationState = 0 then
  begin
    JumpDestinationLabel.SetActive(False);
    JumpAnimation.SetActive(True);
    JumpAnimation.SetSequenceFrame(0);
  end
  else if JumpHintAnimationState = 1 then
  begin
    JumpDestinationLabel.SetActive(True);
    JumpAnimation.SetActive(True);
    JumpAnimation.SetSequenceFrame(0);
    JumpHintAnimationState := 2;
  end
  else if JumpHintAnimationState = 2 then
  begin
    JumpDestinationLabel.SetActive(True);
    JumpAnimation.SetActive(True);
    if JumpAnimation.SequenceFrame + 1 >= JumpAnimation.SequenceFrameCount then
    begin
      JumpHintAnimationState := 3;
      JumpAnimation.SetSequenceFrame(JumpAnimation.SequenceFrameCount - 1);
    end
    else JumpAnimation.SetSequenceFrame(JumpAnimation.SequenceFrame + 1);
  end
  else if JumpHintAnimationState = 3 then
  begin
    JumpDestinationLabel.SetActive(True);
    JumpAnimation.SetActive(True);
    JumpAnimation.SetSequenceFrame(JumpAnimation.SequenceFrameCount - 1);
  end
  else if JumpHintAnimationState = 4 then
  begin
    JumpDestinationLabel.SetActive(True);
    JumpAnimation.SetActive(True);
    JumpAnimation.SetSequenceFrame(JumpAnimation.SequenceFrameCount - 1);
    JumpHintAnimationState := 5;
  end
  else if JumpHintAnimationState = 5 then
  begin
    JumpDestinationLabel.SetActive(True);
    if JumpAnimation.SequenceFrame - 1 < 0 then
    begin
      JumpHintAnimationState := 0;
      JumpAnimation.SetSequenceFrame(0);
      JumpAnimation.SetActive(True);
    end
    else
    begin
      JumpAnimation.SetSequenceFrame(JumpAnimation.SequenceFrame - 1);
      JumpAnimation.SetActive(True);
    end;
  end;
  JumpLightImages[0].SetActive(False);
  JumpLightImages[1].SetActive(False);
  JumpLightImages[2].SetActive(False);
  if not JumpButton.Disabled and (GetPlayer.CurrentStar <> SelectedJumpStar) and
    (SelectedJumpStar <> nil) and GetPlayer.HasPositiveSpeed then
  begin
    First := SelectedJumpStar.Position;
    Second := GetPlayer.CurrentStar.Position;
    if GetPlayer.JumpRange < Round(Sqrt(Sqr(First.X - Second.X) + Sqr(First.Y - Second.Y))) then Exit;
    Inc(JumpLightTick);
    LightIndex := (JumpLightTick div 5) mod 3;
    JumpLightImages[0].SetActive(LightIndex = 2);
    JumpLightImages[1].SetActive(LightIndex = 1);
    JumpLightImages[2].SetActive(LightIndex = 0);
  end;
end;
{ @end $67AB80 }

{ @routine $67AF54 TfGalaxy2_SelectMusic }
procedure TfGalaxy2.SelectMusic;
begin
  if GetPlayer = nil then MusicManager.PlayCategory('Base')
  else if GetPlayer.IsOnPlanet then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
    begin
      if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
        MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.PiratePlanetMain');
    end
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
  end
  else if GetPlayer.IsDockedToShip then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else if GetPlayer.DockedTo.TypeId in [Ord(rstPirateBase), Ord(rstDominion)] then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end
  else if GetPlayer.InNormalSpace then
  begin
    if MusicInSpaceEnabled then
    begin
      if (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0, 100) < 20) then
      begin
        StarMapScreen.BattleMusicSelected := True;
        MusicManager.PlayCategory('Destroyer');
      end
      else
      begin
        StarMapScreen.BattleMusicSelected := False;
        MusicManager.PlayCategory('StarMap');
      end;
    end
    else MusicManager.RequestFadeOut;
  end;
end;
{ @end $67AF54 }

{ @routine $67B288 TfGalaxy2_ProcessCallbackTimers }
procedure TfGalaxy2.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $67B288 }

{ @routine $67B2C8 RunGalaxyMap }
function RunGalaxyMap(ParentLoop: TMessageLoopGI): Boolean;
var
  CursorAlignment: array[0..2] of Byte;
  State: TCursorStateGI;
begin
  ParentLoop.RootUiObject.OnModalSuspend;
  ParentLoop.CaptureCursorState(@State);
  ParentLoop.SetCursorActive(False);
  ParentLoop.DrawQueuedUpdateRects;
  GalaxyScreen.ParentLoop := ParentLoop;
  ParentLoop.ChildLoop := GalaxyScreen;
  if GalaxyScreen.Run = 1 then Result := True else Result := False;
  GalaxyScreen.ParentLoop := nil;
  ParentLoop.ChildLoop := nil;
  ParentLoop.InvalidateViewport;
  ParentLoop.RestoreCursorState(@State);
  ParentLoop.UpdateCursorPosition;
  ParentLoop.RootUiObject.OnModalResume;
  PostMouseMoveMessage;
end;
{ @end $67B2C8 }

{ @routine $67B3B0 CaptureGalaxyPreview }
procedure CaptureGalaxyPreview(ParentLoop: TMessageLoopGI);
begin
  GalaxyScreen.ParentLoop := nil;
  GalaxyScreen.CapturePreviewOnOpen := True;
  GalaxyScreen.PlayTransitionSounds := False;
  GalaxyScreen.Run;
  GalaxyScreen.PlayTransitionSounds := True;
  GalaxyScreen.ParentLoop := nil;
  ParentLoop.InvalidateViewport;
  ParentLoop.Present;
end;
{ @end $67B3B0 }

{ @routine $67B418 TfGalaxy2_CreateMarkerClicked }
procedure TfGalaxy2.CreateMarkerClicked(Sender: TObjectGI);
begin
  CreateMarkerMode := not CreateMarkerMode;
  if CreateMarkerMode then
  begin
    CreateMarkerButton.SetImageNormalPath(CreateMarkerButton.ImageDown.GetImagePath);
    CreateMarkerButton.SetImageNormalActivePath(CreateMarkerButton.ImageDown.GetImagePath);
  end
  else
  begin
    CreateMarkerButton.SetImageNormalPath(CreateMarkerImagePath);
    CreateMarkerButton.SetImageNormalActivePath(CreateMarkerActiveImagePath);
  end;
end;
{ @end $67B418 }

{ @routine $67B500 TfGalaxy2_UndoMarkerClicked }
procedure TfGalaxy2.UndoMarkerClicked(Sender: TObjectGI);
begin
  if RouteStars.Count > 0 then
  begin
    RouteStars.Delete(RouteStars.Count - 1);
    RebuildJumpPath;
  end;
end;
{ @end $67B500 }

{ @routine $67B544 TfGalaxy2_ClearMarkersClicked }
procedure TfGalaxy2.ClearMarkersClicked(Sender: TObjectGI);
begin
  if RouteStars.Count > 0 then
  begin
    RouteStars.Clear;
    RebuildJumpPath;
  end;
end;
{ @end $67B544 }

{ @routine $67B57C TfGalaxy2_ExecuteUiCode }
procedure TfGalaxy2.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not ExitScreenLoop and (TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10005);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20005);
  end;
end;
{ @end $67B57C }

end.
