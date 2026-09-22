unit fFilm;
// Unit bracket (inferred): .text 0x006843C8..0x00686CF0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, EC_Thread, GI_GraphBuf, GI_GraphButton, GI_Label, GI_MessageLoop, GI_Panel, GI_ScrollBar, Types, aEFilm;

type
  TfFilmLoader = class(TThreadEC) // @size 0x2C
  public
    procedure Execute; override; // @addr 0x6844BC @note "Loads FilmScreen.PreloadHistoryIndex into PreloadedFilm and supplies its separately stored Turn."
  end;

  TfFilm = class(TMessageLoopGI) // @size 0x130
  public
    PanTimer: PCallbackTimerGI; // @offset 0xD0
    PanLeft: Boolean; // @offset 0xD4
    PanRight: Boolean; // @offset 0xD5
    PanUp: Boolean; // @offset 0xD6
    PanDown: Boolean; // @offset 0xD7
    Playing: Boolean; // @offset 0xD8
    CenterShipButton: TGraphButtonGI; // @offset 0xDC
    SpacePanel: TPanelGI; // @offset 0xE0
    MapPanel: TObjectGI; // @offset 0xE4
    FrameSlider: TScrollBarGI; // @offset 0xE8
    SpeedSlider: TScrollBarGI; // @offset 0xEC
    TurnSlider: TScrollBarGI; // @offset 0xF0
    PlayButton: TGraphButtonGI; // @offset 0xF4
    StopButton: TGraphButtonGI; // @offset 0xF8
    DateLabel: TLabelGI; // @offset 0xFC
    Loader: TfFilmLoader; // @offset 0x100
    CurrentFilm: TEFilm; // @offset 0x104
    PreloadedFilm: TEFilm; // @offset 0x108
    CurrentHistoryIndex: Integer; // @offset 0x10C
    PreloadHistoryIndex: Integer; // @offset 0x110
    CameraTarget: TPointF; // @offset 0x114
    FrameIntervalMs: Integer; // @offset 0x11C
    PlaybackTimer: PCallbackTimerGI; // @offset 0x120
    EffectsTimer: PCallbackTimerGI; // @offset 0x124
    StepIndex: Integer; // @offset 0x128
    NextCommand: PEFilmCommand; // @offset 0x12C

    procedure InitializeLayout; override; // @addr 0x684528
    procedure OnOpen; override; // @addr 0x684C3C
    procedure OnClose; override; // @addr 0x684FD4
    function GetViewOffset: TPoint; // @addr 0x685160
    procedure SetViewOffset(Offset: TPoint); // @addr 0x6851CC @note "Disables automatic camera following."
    procedure FollowViewOffset(Offset: TPoint); // @addr 0x685264 @note "Ignored while automatic camera following is disabled."
    procedure PanView(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x685300
    procedure KeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x685438
    procedure KeyUp(Sender: TObjectGI; Key: Cardinal); // @addr 0x6854FC
    procedure CopyLiveVisualStateToFilm; // @addr 0x685558
    procedure CopyFilmVisualStateToLive; // @addr 0x6858B8
    procedure ExitClicked(Sender: TObjectGI); // @addr 0x685C18
    procedure CenterShipClicked(Sender: TObjectGI); // @addr 0x685C48
    procedure SelectHistoryEntry(Index: Integer; InitialLoad: Boolean); // @addr 0x685C74 @note "Waits for the loader, swaps film buffers, resets the command cursor, then preloads the following entry. Requires a valid index and nonempty command stream."
    procedure CreateFilmSceneObjects(Film: TEFilm); // @addr 0x6860CC
    procedure ReleaseFilmSceneObjects(Film: TEFilm; ReleaseTrailingReferences: Boolean); // @addr 0x686130
    procedure ReuseSceneObjectsForPreloadedFilm; // @addr 0x686278
    procedure AdvancePausedEffects(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x686490
    procedure SetFrameInterval(IntervalMs: Integer; UpdateSlider: Boolean); // @addr 0x6864FC
    procedure SpeedSliderChanged(Sender: TObjectGI); // @addr 0x6865D8
    procedure FrameSliderChanged(Sender: TObjectGI); // @addr 0x686634 @note "Backward seeking reloads the recording and executes commands forward to the requested step."
    procedure PlayStopClicked(Sender: TObjectGI); // @addr 0x6866CC
    procedure TurnSliderChanged(Sender: TObjectGI); // @addr 0x686730
    procedure StartPlayback; // @addr 0x686780
    procedure PausePlayback; // @addr 0x68681C @note "Trailing effects continue on a separate timer."
    procedure AdvancePlayback(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x6868F0 @note "Automatically advances to the following retained recording when this one ends."
    procedure AdvanceOneStep; // @addr 0x68695C @note "Requires NextCommand <> nil."
    procedure InvalidateAnimatedControls; // @addr 0x686ACC
    procedure DrawFrame; override; // @addr 0x686B04
    procedure SelectMusic; override; // @addr 0x686C64
  end;

implementation

uses SysUtils, Math, Windows, fFilmFile, Globals, GlobalsV, GR_Main,
  GR_Sound, GI_Main, aMyFunction, aConst, aPlayer, aShip, aEFilmEnd, SE_Process,
  SE_Space, SE_Ship2, SE_Weapon, SE_Star, SE_Planet, SE_Sputnik, SE_Asteroid,
  aGalaxy, aPlanet, aAsteroid, GI_StarField, GI_StarFieldImg, GI_SpaceImg,
  GR_Rect, GR_GraphBuf, Classes, fStarMap;

{ @routine $6844BC TfFilmLoader_Execute }
procedure TfFilmLoader.Execute;
begin
  FilmHistory.LoadFilm(FilmHistory.GetEntry(FilmScreen.PreloadHistoryIndex), FilmScreen.PreloadedFilm);
  FilmScreen.PreloadedFilm.Turn := FilmHistory.GetEntry(FilmScreen.PreloadHistoryIndex).Turn;
end;
{ @end $6844BC }

{ @routine $684528 TfFilm_InitializeLayout }
procedure TfFilm.InitializeLayout;
var
  Main, Map, Center, Shade, ShadeNext, Fps, FilmPanel, SpaceImages, Stars, StarImages, StarM: TObjectGI;
  Graph: TGraphBufGI;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fFilm... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Main := GetByName('MainPanel');
  Main.Parent.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Main.SetPosition(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
  Main.SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
  Main.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Map := Main.FindByNameRecursive('MapPanel');
  Map.SetPosition(Classes.Point(Map.LocalPosition.X + ExtraScreenWidth div 2, Map.LocalPosition.Y - ExtraScreenHeight div 2));
  Center := Main.FindByNameRecursive('CenterShip');
  Center.SetPosition(Classes.Point(Center.LocalPosition.X + ExtraScreenWidth div 2, Center.LocalPosition.Y - ExtraScreenHeight div 2));
  Shade := Main.FindByNameRecursive('MapPanelA');
  Shade.SetPosition(Classes.Point(Shade.LocalPosition.X + ExtraScreenWidth div 2, Shade.LocalPosition.Y - ExtraScreenHeight div 2));
  ShadeNext := Shade.NextSibling;
  ShadeNext.SetPosition(Classes.Point(ShadeNext.LocalPosition.X + ExtraScreenWidth div 2, ShadeNext.LocalPosition.Y - ExtraScreenHeight div 2));
  Fps := Main.FindByNameRecursive('FPS');
  Fps.SetPosition(Classes.Point(Fps.LocalPosition.X, Fps.LocalPosition.Y - ExtraScreenHeight div 2));
  FilmPanel := Main.FindByNameRecursive('PanelFilm');
  FilmPanel.SetPosition(Classes.Point(FilmPanel.LocalPosition.X, FilmPanel.LocalPosition.Y + ExtraScreenHeight div 2));
  SpaceImages := Main.FindByNameRecursive('SpaceImg');
  SpaceImages.SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
  SpaceImages.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Stars := Main.FindByNameRecursive('StarField');
  Stars.SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
  Stars.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  StarImages := Main.FindByNameRecursive('StarFieldImg');
  StarImages.SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
  StarImages.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  StarM := Main.FindByNameRecursive('StarFieldM');
  StarM.SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
  StarM.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  AppendLogLineThreadSafe('ok');
  CenterShipButton := GetByName('CenterShip') as TGraphButtonGI;
  CenterShipButton.DownCallback := CenterShipClicked;
  SpacePanel := GetByName('MainPanel') as TPanelGI;
  MapPanel := GetByName('MapPanel');
  FrameSlider := GetByName('SBFrame') as TScrollBarGI;
  SpeedSlider := GetByName('SBSpeed') as TScrollBarGI;
  PlayButton := GetByName('PF_Play') as TGraphButtonGI;
  StopButton := GetByName('PF_Stop') as TGraphButtonGI;
  TurnSlider := GetByName('PF_SBTurn') as TScrollBarGI;
  DateLabel := GetByName('PF_Date') as TLabelGI;
  SpacePanel.ScrollType := pstSimple;
  Graph := MapPanel as TGraphBufGI;
  Graph.BindExternalGraphBuf(RenderScratchBuffer);
end;
{ @end $684528 }

{ @routine $684C3C TfFilm_OnOpen }
procedure TfFilm.OnOpen;
var Stars: TStarFieldImgGI;
begin
  GetByName('FPS').SetActive(ShowFrameRate);
  Stars := GetByName('StarFieldImg') as TStarFieldImgGI;
  Stars.SetActive(Wind >= 2);
  if Stars.StarCount <= 0 then Stars.SeedStars;
  Stars.CopyStarsFrom(StarMapScreen.GetByName('StarFieldImg') as TStarFieldImgGI);
  FindControlByPath('StarFieldM').SetActive(Wind >= 1);
  UpdateRectsEnabled := False;
  SetViewOffset(TruncatePointF(SpaceViewPosition));
  UpdateRectsEnabled := True;
  PreloadHistoryIndex := -1;
  if Loader <> nil then
  begin
    Loader.Free;
    Loader := nil;
  end;
  Loader := TfFilmLoader.Create;
  Loader.SetPriority(1);
  PanTimer := ScheduleCallbackTimer(ScrollTime, ScrollTime, PanView);
  ContentPanel.KeyDownCallback := KeyDown;
  ContentPanel.KeyUpCallback := KeyUp;
  CurrentFilm := TEFilm.Create;
  PreloadedFilm := TEFilm.Create;
  FrameSlider.PositionChangedCallback := FrameSliderChanged;
  SpeedSlider.PositionChangedCallback := SpeedSliderChanged;
  SpeedSlider.SetRange(0, 100);
  SetFrameInterval(18, True);
  (GetByName('PF_Exit') as TGraphButtonGI).UpCallback := ExitClicked;
  PlayButton.UpCallback := PlayStopClicked;
  StopButton.UpCallback := PlayStopClicked;
  TurnSlider.SetRange(0, FilmHistory.GetCount - 1);
  TurnSlider.PositionChangedCallback := TurnSliderChanged;
  GetByName('MapPanelA').SetActive((GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(heBlindness));
  SelectHistoryEntry(FilmHistory.GetCount - 1, True);
  CopyLiveVisualStateToFilm;
  AdvanceOneStep;
  StartPlayback;
  Galaxy.PrimeIntegrityChecksum(133);
end;
{ @end $684C3C }

{ @routine $684FD4 TfFilm_OnClose }
procedure TfFilm.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(134);
  (StarMapScreen.GetByName('StarFieldImg') as TStarFieldImgGI).CopyStarsFrom(GetByName('StarFieldImg') as TStarFieldImgGI);
  StarMapScreen.SaveSpaceImageState(GetByName('SpaceImg') as TSpaceImgGI);
  if TrailingFilmEffects <> nil then
  begin
    TrailingFilmEffects.Free;
    TrailingFilmEffects := nil;
  end;
  ReleaseFilmSceneObjects(CurrentFilm, True);
  if Loader <> nil then
  begin
    Loader.Free;
    Loader := nil;
  end;
  if CurrentFilm <> nil then
  begin
    CurrentFilm.Free;
    CurrentFilm := nil;
  end;
  if PreloadedFilm <> nil then
  begin
    PreloadedFilm.Free;
    PreloadedFilm := nil;
  end;
  if PanTimer <> nil then
  begin
    CancelCallbackTimer(PanTimer);
    PanTimer := nil;
  end;
  SpaceProcess.CloseSpace;
end;
{ @end $684FD4 }

{ @routine $685160 TfFilm_GetViewOffset }
function TfFilm.GetViewOffset: TPoint;
begin
  if SpacePanel = nil then SpacePanel := GetByName('MainPanel') as TPanelGI;
  Result := SpacePanel.ScrollOffset;
end;
{ @end $685160 }

{ @routine $6851CC TfFilm_SetViewOffset }
procedure TfFilm.SetViewOffset(Offset: TPoint);
begin
  if SpacePanel = nil then SpacePanel := GetByName('MainPanel') as TPanelGI;
  SpacePanel.SetScrollOffset(Offset);
  if SpaceProcess.Space <> nil then SpaceProcess.Space.MapScrollChanged(nil);
  FilmCameraFollow := False;
end;
{ @end $6851CC }

{ @routine $685264 TfFilm_FollowViewOffset }
procedure TfFilm.FollowViewOffset(Offset: TPoint);
begin
  if FilmCameraFollow then
  begin
    if SpacePanel = nil then SpacePanel := GetByName('MainPanel') as TPanelGI;
    SpacePanel.SetScrollOffset(Offset);
    if SpaceProcess.Space <> nil then SpaceProcess.Space.MapScrollChanged(nil);
  end;
end;
{ @end $685264 }

{ @routine $685300 TfFilm_PanView }
procedure TfFilm.PanView(Timer: PCallbackTimerGI; UserData: Integer);
var
  Offset, OldOffset: TPoint;
  X, Y: SmallInt;
begin
  OldOffset := GetViewOffset;
  Offset := OldOffset;
  if PanLeft then Dec(Offset.X, ScrollStep);
  if PanRight then Inc(Offset.X, ScrollStep);
  if PanUp then Dec(Offset.Y, ScrollStep);
  if PanDown then Inc(Offset.Y, ScrollStep);
  X := GetCursorPoint.X;
  Y := GetCursorPoint.Y;
  if X < ScrollSense then Dec(Offset.X, ScrollStep);
  if X > GameScreenWidth - ScrollSense - 1 then Inc(Offset.X, ScrollStep);
  if Y < ScrollSense then Dec(Offset.Y, ScrollStep);
  if Y > GameScreenHeight - ScrollSense - 1 then Inc(Offset.Y, ScrollStep);
  if (OldOffset.X <> Offset.X) or (OldOffset.Y <> Offset.Y) then SetViewOffset(Offset);
end;
{ @end $685300 }

{ @routine $685438 TfFilm_KeyDown }
procedure TfFilm.KeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
    if Key = VK_LEFT then PanLeft := True
    else if Key = VK_RIGHT then PanRight := True
    else if Key = VK_UP then PanUp := True
    else if Key = VK_DOWN then PanDown := True
    else if Key = Ord('C') then CenterShipClicked(nil)
    else if Key = VK_SPACE then PlayStopClicked(nil)
    else if Key = VK_ESCAPE then ExitClicked(nil);
end;
{ @end $685438 }

{ @routine $6854FC TfFilm_KeyUp }
procedure TfFilm.KeyUp(Sender: TObjectGI; Key: Cardinal);
begin
  if Key = VK_LEFT then PanLeft := False
  else if Key = VK_RIGHT then PanRight := False
  else if Key = VK_UP then PanUp := False
  else if Key = VK_DOWN then PanDown := False;
end;
{ @end $6854FC }

{ @routine $685558 TfFilm_CopyLiveVisualStateToFilm }
procedure TfFilm.CopyLiveVisualStateToFilm;
var
  Index, Count, SatelliteIndex, SatelliteCount: Integer;
  Planet: TPlanet;
  Satellite: TSputnik;
  Asteroid: TAsteroid;
  Obj: TEFilmObj;
begin
  Obj := CurrentFilm.FindObject(ClassSEtoName(PlayerStar.Graphic), PlayerStar.Graphic.GraphKey, PlayerStar.Id);
  if (Obj <> nil) and (Obj.SceneObject <> nil) then
    (Obj.SceneObject as TStarSE).SetSequenceFrameIndex(TStarSE(PlayerStar.Graphic).GetSequenceFrameIndex);
  Count := PlayerStar.Planets.Count;
  for Index := 0 to Count - 1 do
  begin
    Planet := TPlanet(PlayerStar.Planets[Index]);
    Obj := CurrentFilm.FindObject(ClassSEtoName(Planet.Graphic), Planet.Graphic.GraphKey, Planet.Id);
    if (Obj <> nil) and (Obj.SceneObject <> nil) then
    begin
      (Obj.SceneObject as TPlanetSE).SetSurfaceMapOffset(Planet.Graphic.SurfaceMapOffset);
      (Obj.SceneObject as TPlanetSE).SetCloud1MapOffset(Planet.Graphic.Cloud1MapOffset);
      (Obj.SceneObject as TPlanetSE).SetCloud2MapOffset(Planet.Graphic.Cloud2MapOffset);
      (Obj.SceneObject as TPlanetSE).SetCloud3MapOffset(Planet.Graphic.Cloud3MapOffset);
    end;
    SatelliteCount := Planet.Satellites.Count;
    for SatelliteIndex := 0 to SatelliteCount - 1 do
    begin
      Satellite := TSputnik(Planet.Satellites[SatelliteIndex]);
      Obj := CurrentFilm.FindObject(ClassSEtoName(Satellite.Graphic), Satellite.Graphic.GraphKey, Satellite.Id);
      if (Obj <> nil) and (Obj.SceneObject <> nil) then
      begin
        (Obj.SceneObject as TSputnikSE).SurfaceMapOffset := Satellite.Graphic.SurfaceMapOffset;
        (Obj.SceneObject as TSputnikSE).OrbitAngle := Satellite.Graphic.OrbitAngle;
      end;
    end;
  end;
  Count := PlayerStar.Asteroids.Count;
  for Index := 0 to Count - 1 do
  begin
    Asteroid := TAsteroid(PlayerStar.Asteroids[Index]);
    Obj := CurrentFilm.FindObject(ClassSEtoName(Asteroid.GraphObject), Asteroid.GraphObject.GraphKey, Asteroid.Id);
    if (Obj <> nil) and (Obj.SceneObject <> nil) then
      (Obj.SceneObject as TAsteroidSE).SetSequenceFrameIndex(TAsteroidSE(Asteroid.GraphObject).GetSequenceFrameIndex);
  end;
end;
{ @end $685558 }

{ @routine $6858B8 TfFilm_CopyFilmVisualStateToLive }
procedure TfFilm.CopyFilmVisualStateToLive;
var
  Index, Count, SatelliteIndex, SatelliteCount: Integer;
  Planet: TPlanet;
  Satellite: TSputnik;
  Asteroid: TAsteroid;
  Obj: TEFilmObj;
begin
  Obj := CurrentFilm.FindObject(ClassSEtoName(PlayerStar.Graphic), PlayerStar.Graphic.GraphKey, PlayerStar.Id);
  if (Obj <> nil) and (Obj.SceneObject <> nil) then
    TStarSE(PlayerStar.Graphic).SetSequenceFrameIndex((Obj.SceneObject as TStarSE).GetSequenceFrameIndex);
  Count := PlayerStar.Planets.Count;
  for Index := 0 to Count - 1 do
  begin
    Planet := TPlanet(PlayerStar.Planets[Index]);
    Obj := CurrentFilm.FindObject(ClassSEtoName(Planet.Graphic), Planet.Graphic.GraphKey, Planet.Id);
    if (Obj <> nil) and (Obj.SceneObject <> nil) then
    begin
      Planet.Graphic.SetSurfaceMapOffset((Obj.SceneObject as TPlanetSE).SurfaceMapOffset);
      Planet.Graphic.SetCloud1MapOffset((Obj.SceneObject as TPlanetSE).Cloud1MapOffset);
      Planet.Graphic.SetCloud2MapOffset((Obj.SceneObject as TPlanetSE).Cloud2MapOffset);
      Planet.Graphic.SetCloud3MapOffset((Obj.SceneObject as TPlanetSE).Cloud3MapOffset);
    end;
    SatelliteCount := Planet.Satellites.Count;
    for SatelliteIndex := 0 to SatelliteCount - 1 do
    begin
      Satellite := TSputnik(Planet.Satellites[SatelliteIndex]);
      Obj := CurrentFilm.FindObject(ClassSEtoName(Satellite.Graphic), Satellite.Graphic.GraphKey, Satellite.Id);
      if (Obj <> nil) and (Obj.SceneObject <> nil) then
      begin
        Satellite.Graphic.SurfaceMapOffset := (Obj.SceneObject as TSputnikSE).SurfaceMapOffset;
        Satellite.Graphic.OrbitAngle := (Obj.SceneObject as TSputnikSE).OrbitAngle;
      end;
    end;
  end;
  Count := PlayerStar.Asteroids.Count;
  for Index := 0 to Count - 1 do
  begin
    Asteroid := TAsteroid(PlayerStar.Asteroids[Index]);
    Obj := CurrentFilm.FindObject(ClassSEtoName(Asteroid.GraphObject), Asteroid.GraphObject.GraphKey, Asteroid.Id);
    if (Obj <> nil) and (Obj.SceneObject <> nil) then
      TAsteroidSE(Asteroid.GraphObject).SetSequenceFrameIndex((Obj.SceneObject as TAsteroidSE).GetSequenceFrameIndex);
  end;
end;
{ @end $6858B8 }

{ @routine $685C18 TfFilm_ExitClicked }
procedure TfFilm.ExitClicked(Sender: TObjectGI);
begin
  CopyFilmVisualStateToLive;
  RequestedScreenId := screenStarMap;
  RequestClose(1);
end;
{ @end $685C18 }

{ @routine $685C48 TfFilm_CenterShipClicked }
procedure TfFilm.CenterShipClicked(Sender: TObjectGI);
begin
  SetViewOffset(TruncatePointF(CameraTarget));
end;
{ @end $685C48 }

{ @routine $685C74 TfFilm_SelectHistoryEntry }
procedure TfFilm.SelectHistoryEntry(Index: Integer; InitialLoad: Boolean);
var SwapFilm: TEFilm;
begin
  if Loader.IsRunning then Loader.WaitForIdle(INFINITE);
  if PreloadHistoryIndex <> Index then
  begin
    PreloadHistoryIndex := Index;
    Loader.Start;
    Loader.WaitForIdle(INFINITE);
  end;
  if (CurrentHistoryIndex >= PreloadHistoryIndex) and (TrailingFilmEffects <> nil) then
  begin
    TrailingFilmEffects.Free;
    TrailingFilmEffects := nil;
  end;
  ReuseSceneObjectsForPreloadedFilm;
  ReleaseFilmSceneObjects(CurrentFilm, True);
  CreateFilmSceneObjects(PreloadedFilm);
  SwapFilm := CurrentFilm;
  CurrentFilm := PreloadedFilm;
  PreloadedFilm := SwapFilm;
  CurrentHistoryIndex := Index;
  PreloadHistoryIndex := 0;
  if not InitialLoad then StarMapScreen.SaveSpaceImageState(GetByName('SpaceImg') as TSpaceImgGI);
  StarMapScreen.BuildSpaceBackground(GetByName('StarField') as TStarFieldGI,
    GetByName('SpaceImg') as TSpaceImgGI, CurrentFilm.StarGenerationSeed, CurrentFilm.BackgroundImage);
  FullFrameRedrawRequested := True;
  InvalidateViewport;
  PreloadedFilm.StarGenerationSeed := 0;
  TurnSlider.SetPositionInternal(Index);
  DateLabel.SetText(Galaxy.FormatTurnDate(CurrentFilm.Turn));
  if GetPlayer <> nil then
  begin
    SpaceProcess.RadarCenter := MakePointF(0, 0);
    SpaceProcess.RadarRange := CurrentFilm.RadarRange;
    SpaceProcess.ActionRange := CurrentFilm.RadarRange;
    SpaceProcess.ActionColor := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
  end;
  SpaceProcess.SystemRadius := CurrentFilm.MapDiameter div 2;
  SpaceProcess.PopulateAmbientObjects(CurrentFilm.MapDiameter div 2, CurrentFilm.BackgroundImage, CurrentFilm.StarGenerationSeed);
  SpaceProcess.OpenSpace(SpacePanel, Self);
  SpaceProcess.Space.MinimapScale := 0.0000001;
  SpaceProcess.BindMinimap(MapPanel);
  SpaceProcess.Space.MinimapScale := MapPanel.ClientSize.X / CurrentFilm.MapDiameter;
  if GetPlayer <> nil then
    if GetPlayer.IsHealthEffectActive(heBlindness) then SpaceProcess.Space.AlphaShift := 2;
  SpaceProcess.Space.CreateMinimapViewport;
  StepIndex := 0;
  NextCommand := CurrentFilm.FirstCommand;
  FrameSlider.SetRange(1, CurrentFilm.LastCommand.StepIndex);
  PreloadHistoryIndex := Index + 1;
  if FilmHistory.GetCount <= PreloadHistoryIndex then PreloadHistoryIndex := FilmHistory.GetCount - 1;
  Loader.Start;
  MinimapFrameCounter := 0;
end;
{ @end $685C74 }

{ @routine $6860CC TfFilm_CreateFilmSceneObjects }
procedure TfFilm.CreateFilmSceneObjects(Film: TEFilm);
var Obj: TEFilmObj;
begin
  Obj := Film.FirstObject;
  while Obj <> nil do
  begin
    if Obj.SceneObject = nil then
      RetainSpaceObject(Obj.SceneObject, CreateSpaceObjectByName(Obj.KindName, Obj.GraphKey, Classes.Point(0, 0)));
    Obj := Obj.Next;
  end;
end;
{ @end $6860CC }

{ @routine $686130 TfFilm_ReleaseFilmSceneObjects }
procedure TfFilm.ReleaseFilmSceneObjects(Film: TEFilm; ReleaseTrailingReferences: Boolean);
var
  Obj: TEFilmObj;
  Entry, NextEntry: PEFilmEndEntry;
begin
  Obj := Film.FirstObject;
  while Obj <> nil do
  begin
    if Obj.SceneObject <> nil then
    begin
      Obj.SceneObject.DetachFromSpace;
      if ReleaseTrailingReferences then
        if TrailingFilmEffects <> nil then
        begin
          NextEntry := TrailingFilmEffects.FirstEntry;
          while NextEntry <> nil do
          begin
            Entry := NextEntry;
            NextEntry := NextEntry.Next;
            if Entry.RelatedObject1 = Obj.SceneObject then ReleaseSpaceObject(Entry.RelatedObject1);
            if Entry.RelatedObject2 = Obj.SceneObject then ReleaseSpaceObject(Entry.RelatedObject2);
            if (Entry.SceneObject is TWeaponSE) and
              (((Entry.SceneObject as TWeaponSE).SourceObject = Obj.SceneObject) or
               ((Entry.SceneObject as TWeaponSE).TargetObject = Obj.SceneObject)) then
            begin
              ReleaseSpaceObject(Entry.RelatedObject1);
              ReleaseSpaceObject(Entry.RelatedObject2);
              TrailingFilmEffects.RemoveEntry(Entry);
            end;
          end;
        end;
      ReleaseSpaceObject(Obj.SceneObject);
    end;
    Obj := Obj.Next;
  end;
end;
{ @end $686130 }

{ @routine $686278 TfFilm_ReuseSceneObjectsForPreloadedFilm }
procedure TfFilm.ReuseSceneObjectsForPreloadedFilm;
var NewObj, OldObj: TEFilmObj;
begin
  NewObj := PreloadedFilm.FirstObject;
  while NewObj <> nil do
  begin
    if NewObj.SceneObject = nil then
    begin
      OldObj := CurrentFilm.FindObject(NewObj.KindName, NewObj.GraphKey, NewObj.ObjectId);
      if OldObj <> nil then
        if OldObj.SceneObject <> nil then
        begin
          RetainSpaceObject(NewObj.SceneObject, OldObj.SceneObject);
          if (not (OldObj.SceneObject is TShip2SE) and (OldObj.SceneObject.GraphKey <> 'Ruins.WB')) or
            (CurrentHistoryIndex <> PreloadHistoryIndex - 1) then NewObj.SceneObject.DetachFromSpace;
          ReleaseSpaceObject(OldObj.SceneObject);
          if NewObj.SceneObject is TWeaponSE then
          begin
            ReleaseSpaceObject((NewObj.SceneObject as TWeaponSE).SourceObject);
            ReleaseSpaceObject((NewObj.SceneObject as TWeaponSE).TargetObject);
          end;
        end;
    end;
    NewObj := NewObj.Next;
  end;
  if CurrentHistoryIndex = PreloadHistoryIndex - 1 then
  begin
    OldObj := CurrentFilm.FirstObject;
    while OldObj <> nil do
    begin
      if (OldObj.SceneObject <> nil) and OldObj.SceneObject.IsAttachedToSpace and
        (OldObj.SceneObject.GraphKey = 'Ruins.WB') then
      begin
        NewObj := PreloadedFilm.AllocateObject;
        NewObj.ObjectId := OldObj.ObjectId;
        RetainSpaceObject(NewObj.SceneObject, OldObj.SceneObject);
        NewObj.KindName := OldObj.KindName;
        NewObj.GraphKey := OldObj.GraphKey;
        ReleaseSpaceObject(OldObj.SceneObject);
      end;
      OldObj := OldObj.Next;
    end;
  end;
end;
{ @end $686278 }

{ @routine $686490 TfFilm_AdvancePausedEffects }
procedure TfFilm.AdvancePausedEffects(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if TrailingFilmEffects <> nil then
  begin
    TrailingFilmEffects.AdvanceEffects;
    if TrailingFilmEffects.FirstEntry = nil then
    begin
      TrailingFilmEffects.Free;
      TrailingFilmEffects := nil;
    end;
  end;
  SpaceProcess.Space.AdvanceTimers;
  SpaceProcess.Space.AdvanceObjects;
end;
{ @end $686490 }

{ @routine $6864FC TfFilm_SetFrameInterval }
procedure TfFilm.SetFrameInterval(IntervalMs: Integer; UpdateSlider: Boolean);
begin
  FrameIntervalMs := IntervalMs;
  if Playing then
  begin
    PausePlayback;
    StartPlayback;
  end
  else
  begin
    if EffectsTimer <> nil then
    begin
      CancelCallbackTimer(EffectsTimer);
      EffectsTimer := nil;
    end;
    EffectsTimer := ScheduleCallbackTimer(FrameIntervalMs, FrameIntervalMs, AdvancePausedEffects);
  end;
  if UpdateSlider then SpeedSlider.SetPositionInternal(100 - Round((5 - FrameIntervalMs) / -95.0 * 100.0));
end;
{ @end $6864FC }

{ @routine $6865D8 TfFilm_SpeedSliderChanged }
procedure TfFilm.SpeedSliderChanged(Sender: TObjectGI);
begin
  SetFrameInterval(Round((100 - SpeedSlider.Position) / 100.0 * 95.0 + 5.0), False);
end;
{ @end $6865D8 }

{ @routine $686634 TfFilm_FrameSliderChanged }
procedure TfFilm.FrameSliderChanged(Sender: TObjectGI);
var
  Position: Integer;
begin
  Position := FrameSlider.Position;
  if Playing then PausePlayback;
  if Position <> StepIndex then
  begin
    if Position < StepIndex then
    begin
      SelectHistoryEntry(CurrentHistoryIndex, False);
      AdvanceOneStep;
    end;
    FilmSoundEffectsEnabled := False;
    while Position > StepIndex do AdvanceOneStep;
    FilmSoundEffectsEnabled := True;
  end;
end;
{ @end $686634 }

{ @routine $6866CC TfFilm_PlayStopClicked }
procedure TfFilm.PlayStopClicked(Sender: TObjectGI);
begin
  if Playing then PausePlayback
  else
  begin
    FilmCameraFollow := True;
    if NextCommand = nil then
    begin
      SelectHistoryEntry(FilmHistory.GetCount - 1, False);
      AdvanceOneStep;
    end;
    StartPlayback;
  end;
end;
{ @end $6866CC }

{ @routine $686730 TfFilm_TurnSliderChanged }
procedure TfFilm.TurnSliderChanged(Sender: TObjectGI);
begin
  if Playing then PausePlayback;
  FilmCameraFollow := True;
  SelectHistoryEntry(TurnSlider.Position, False);
  AdvanceOneStep;
end;
{ @end $686730 }

{ @routine $686780 TfFilm_StartPlayback }
procedure TfFilm.StartPlayback;
begin
  if not Playing then
  begin
    if EffectsTimer <> nil then
    begin
      CancelCallbackTimer(EffectsTimer);
      EffectsTimer := nil;
    end;
    PlaybackTimer := ScheduleCallbackTimer(FrameIntervalMs, FrameIntervalMs, AdvancePlayback);
    PlayButton.SetActive(False);
    StopButton.SetActive(True);
    Playing := True;
  end;
end;
{ @end $686780 }

{ @routine $68681C TfFilm_PausePlayback }
procedure TfFilm.PausePlayback;
begin
  if Playing then
  begin
    if PlaybackTimer <> nil then
    begin
      CancelCallbackTimer(PlaybackTimer);
      PlaybackTimer := nil;
    end;
    SpacePanel.SetDragScrollingEnabled(True);
    if EffectsTimer <> nil then
    begin
      CancelCallbackTimer(EffectsTimer);
      EffectsTimer := nil;
    end;
    EffectsTimer := ScheduleCallbackTimer(FrameIntervalMs, FrameIntervalMs, AdvancePausedEffects);
    PlayButton.SetActive(True);
    StopButton.SetActive(False);
    Playing := False;
  end;
end;
{ @end $68681C }

{ @routine $6868F0 TfFilm_AdvancePlayback }
procedure TfFilm.AdvancePlayback(Timer: PCallbackTimerGI; UserData: Integer);
begin
  AdvanceOneStep;
  if NextCommand = nil then
  begin
    PausePlayback;
    if CurrentHistoryIndex < FilmHistory.GetCount - 1 then
    begin
      SelectHistoryEntry(CurrentHistoryIndex + 1, False);
      AdvanceOneStep;
      StartPlayback;
    end;
  end;
end;
{ @end $6868F0 }

{ @routine $68695C TfFilm_AdvanceOneStep }
procedure TfFilm.AdvanceOneStep;
begin
  if TrailingFilmEffects <> nil then
  begin
    TrailingFilmEffects.AdvanceEffects;
    if TrailingFilmEffects.FirstEntry = nil then
    begin
      TrailingFilmEffects.Free;
      TrailingFilmEffects := nil;
    end;
  end;
  SpaceProcess.Space.AdvanceTimers;
  if NextCommand.Kind = efcBeginTrailingEffects then
  begin
    if TrailingFilmEffects <> nil then
    begin
      TrailingFilmEffects.Free;
      TrailingFilmEffects := nil;
    end;
    TrailingFilmEffects := TEFilmEnd.Create;
    TrailingFilmEffects.TakeTrailingEffects(CurrentFilm);
    Inc(StepIndex);
    FrameSlider.SetPositionInternal(StepIndex);
    NextCommand := NextCommand.Next;
  end
  else
  begin
    Inc(StepIndex);
    FrameSlider.SetPositionInternal(StepIndex);
    while NextCommand <> nil do
    begin
      if NextCommand.Kind = efcBeginTrailingEffects then Break;
      if NextCommand.StepIndex >= StepIndex then Break;
      CurrentFilm.ExecuteCommand(SpaceProcess, NextCommand, True);
      NextCommand := NextCommand.Next;
    end;
  end;
end;
{ @end $68695C }

{ @routine $686ACC TfFilm_InvalidateAnimatedControls }
procedure TfFilm.InvalidateAnimatedControls;
begin
  UpdateRectsEnabled := True;
  SpacePanel.InvalidateChildren(True);
  CursorControl.Invalidate;
  UpdateRectsEnabled := False;
end;
{ @end $686ACC }

{ @routine $686B04 TfFilm_DrawFrame }
procedure TfFilm.DrawFrame;
var
  RectNode: TRectGR;
  StarField: TStarFieldGI;
begin
  if (MinimapFrameCounter mod 16) = 0 then SpaceProcess.Space.DrawMinimap;
  Inc(MinimapFrameCounter);
  InvalidateAnimatedControls;
  StarField := GetByName('StarField') as TStarFieldGI;
  StarField.UpdateBackgroundBounds;
  if SkipSavedPixelRestore or FullFrameRedrawRequested then
  begin
    UpdateRects.Clear;
    UpdateRectsEnabled := True;
    InvalidateViewport;
    UpdateRectsEnabled := False;
  end;
  FullFrameRedrawRequested := False;
  RestoreSavedPixels16;
  ErasePreviousFrame;
  RectNode := UpdateRects.FirstRect;
  while RectNode <> nil do
  begin
    StarField.DrawBackground(RectNode.Bounds);
    RectNode := RectNode.Next;
  end;
  PrepareFrameDraw;
  DrawQueuedControlRects;
  if not BeginFramePresentation then
  begin
    RequestedScreenId := screenNone;
    PostLoadScreenId := FormToId(Self);
    RequestClose(1);
  end
  else
  begin
    FinishQueuedDraw;
    CommitFrameDraw;
    ResetSecondaryPixelCount;
    EndFramePresentation;
    InvalidateAnimatedControls;
  end;
end;
{ @end $686B04 }

{ @routine $686C64 TfFilm_SelectMusic }
procedure TfFilm.SelectMusic;
begin
  if MusicInSpaceEnabled then
  begin
    if (GetPlayer <> nil) and (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0, 100) < 20) then
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
{ @end $686C64 }

end.
