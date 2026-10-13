unit fFilm;

interface

uses EC_Struct, EC_Thread, GI_GraphBuf, GI_GraphButton, GI_Label, GI_MessageLoop, GI_Panel, GI_ScrollBar, Types, aEFilm;

type
  TfFilmLoader = class(TThreadEC) // @size 0x2C
  public
    procedure Execute; override; // @addr 0x00524EA0 @note "Loads FilmScreen.PreloadHistoryIndex into PreloadedFilm and supplies its separately stored Turn."
  end;

  TfFilm = class(TMessageLoopGI) // @size 0x130
  public
    PanTimer: TCallbackTimerIdGI; // @offset 0xD0
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
    PlaybackTimer: TCallbackTimerIdGI; // @offset 0x120
    EffectsTimer: TCallbackTimerIdGI; // @offset 0x124
    StepIndex: Integer; // @offset 0x128
    NextCommand: PEFilmCommand; // @offset 0x12C

    procedure InitializeLayout; override; // @addr 0x00524F04
    procedure OnOpen; override; // @addr 0x005255A8
    procedure OnClose; override; // @addr 0x005258C4
    function GetViewOffset: TPoint; // @addr 0x00525A0C
    procedure SetViewOffset(Offset: TPoint); // @addr 0x00525A64 @note "Disables automatic camera following."
    procedure FollowViewOffset(Offset: TPoint); // @addr 0x00525AEC @note "Ignored while automatic camera following is disabled."
    procedure PanView(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00525B74
    procedure KeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x00525C98
    procedure KeyUp(Sender: TObjectGI; Key: Cardinal); // @addr 0x00525D38
    procedure CopyLiveVisualStateToFilm; // @addr 0x00525D70
    procedure CopyFilmVisualStateToLive; // @addr 0x0052604C
    procedure ExitClicked(Sender: TObjectGI); // @addr 0x00526328
    procedure CenterShipClicked(Sender: TObjectGI); // @addr 0x00526348
    procedure SelectHistoryEntry(Index: Integer; InitialLoad: Boolean); // @addr 0x00526368 @note "Waits for the loader, swaps film buffers, resets the command cursor, then preloads the following entry. Requires a valid index and nonempty command stream."
    procedure CreateFilmSceneObjects(Film: TEFilm); // @addr 0x00526718
    procedure ReleaseFilmSceneObjects(Film: TEFilm; ReleaseTrailingReferences: Boolean); // @addr 0x00526758
    procedure ReuseSceneObjectsForPreloadedFilm; // @addr 0x0052684C
    procedure AdvancePausedEffects(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x005269D0
    procedure SetFrameInterval(IntervalMs: Integer; UpdateSlider: Boolean); // @addr 0x00526A28
    procedure SpeedSliderChanged(Sender: TObjectGI); // @addr 0x00526AD0
    procedure FrameSliderChanged(Sender: TObjectGI); // @addr 0x00526B1C @note "Backward seeking reloads the recording and executes commands forward to the requested step."
    procedure PlayStopClicked(Sender: TObjectGI); // @addr 0x00526B84
    procedure TurnSliderChanged(Sender: TObjectGI); // @addr 0x00526BD4
    procedure StartPlayback; // @addr 0x00526C10
    procedure PausePlayback; // @addr 0x00526C7C @note "Trailing effects continue on a separate timer."
    procedure AdvancePlayback(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00526D14 @note "Automatically advances to the following retained recording when this one ends."
    procedure AdvanceOneStep; // @addr 0x00526D64 @note "Requires NextCommand <> nil."
    procedure InvalidateAnimatedControls; // @addr 0x00526E88
    procedure DrawFrame; override; // @addr 0x00526EB0
    procedure SelectMusic; override; // @addr 0x00526FE0
  end;

implementation

uses SysUtils, Math, Windows, fFilmFile, Globals, GlobalsV, GR_Main,
  GR_Sound, GI_Main, aMyFunction, aConst, aPlayer, aShip, aEFilmEnd, SE_Process,
  SE_Space, SE_Ship2, SE_Weapon, SE_Star, SE_Planet, SE_Sputnik, SE_Asteroid,
  aGalaxy, aPlanet, aAsteroid, GI_StarField, GI_StarFieldImg, GI_SpaceImg,
  GR_Rect, GR_GraphBuf, Classes, fStarMap;

{ @routine $524EA0 TfFilmLoader_Execute }
procedure TfFilmLoader.Execute;
begin
  FilmHistory.LoadFilm(FilmHistory.GetEntry(FilmScreen.PreloadHistoryIndex), FilmScreen.PreloadedFilm);
  FilmScreen.PreloadedFilm.Turn := FilmHistory.GetEntry(FilmScreen.PreloadHistoryIndex).Turn;
end;
{ @end $524EA0 }

{ @routine $524F04 TfFilm_InitializeLayout }
procedure TfFilm.InitializeLayout;
var
  Main, Map, Center, Shade, ShadeNext, Fps, FilmPanel, SpaceImages, Stars, StarImages, StarM: TObjectGI;
  Graph: TGraphBufGI;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fFilm... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Main := GetByName('MainPanel');
  Main.Parent.ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
  Main.Pos := Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1);
  Main.Sme := Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1);
  Main.ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
  Map := Main.FindByNameRecursive('MapPanel');
  Map.Pos := Classes.Point(Map.LocalPosition.X + ExtraScreenWidth div 2, Map.LocalPosition.Y - ExtraScreenHeight div 2);
  Center := Main.FindByNameRecursive('CenterShip');
  Center.Pos := Classes.Point(Center.LocalPosition.X + ExtraScreenWidth div 2, Center.LocalPosition.Y - ExtraScreenHeight div 2);
  Shade := Main.FindByNameRecursive('MapPanelA');
  Shade.Pos := Classes.Point(Shade.LocalPosition.X + ExtraScreenWidth div 2, Shade.LocalPosition.Y - ExtraScreenHeight div 2);
  ShadeNext := Shade.NextSibling;
  ShadeNext.Pos := Classes.Point(ShadeNext.LocalPosition.X + ExtraScreenWidth div 2, ShadeNext.LocalPosition.Y - ExtraScreenHeight div 2);
  Fps := Main.FindByNameRecursive('FPS');
  Fps.Pos := Classes.Point(Fps.LocalPosition.X, Fps.LocalPosition.Y - ExtraScreenHeight div 2);
  FilmPanel := Main.FindByNameRecursive('PanelFilm');
  FilmPanel.Pos := Classes.Point(FilmPanel.LocalPosition.X, FilmPanel.LocalPosition.Y + ExtraScreenHeight div 2);
  SpaceImages := Main.FindByNameRecursive('SpaceImg');
  SpaceImages.Sme := Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1);
  SpaceImages.ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
  Stars := Main.FindByNameRecursive('StarField');
  Stars.Sme := Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1);
  Stars.ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
  StarImages := Main.FindByNameRecursive('StarFieldImg');
  StarImages.Sme := Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1);
  StarImages.ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
  StarM := Main.FindByNameRecursive('StarFieldM');
  StarM.Sme := Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1);
  StarM.ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
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
{ @end $524F04 }

{ @routine $5255A8 TfFilm_OnOpen }
procedure TfFilm.OnOpen;
var Stars: TStarFieldImgGI;
begin
  GetByName('FPS').IsActive := ShowFrameRate;
  Stars := GetByName('StarFieldImg') as TStarFieldImgGI;
  Stars.IsActive := Wind >= 2;
  if Stars.StarCount <= 0 then Stars.SeedStars;
  Stars.CopyStarsFrom(StarMapScreen.GetByName('StarFieldImg') as TStarFieldImgGI);
  FindControlByPath('StarFieldM').IsActive := Wind >= 1;
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
  Loader.SetPriority(ThreadPriorityLowest);
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
  GetByName('MapPanelA').IsActive := (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(heBlindness);
  SelectHistoryEntry(FilmHistory.GetCount - 1, True);
  CopyLiveVisualStateToFilm;
  AdvanceOneStep;
  StartPlayback;
  Galaxy.PrimeIntegrityChecksum(133);
end;
{ @end $5255A8 }

{ @routine $5258C4 TfFilm_OnClose }
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
  if PanTimer <> 0 then
  begin
    CancelCallbackTimer(PanTimer);
    PanTimer := 0;
  end;
  SpaceProcess.CloseSpace;
end;
{ @end $5258C4 }

{ @routine $525A0C TfFilm_GetViewOffset }
function TfFilm.GetViewOffset: TPoint;
begin
  if SpacePanel = nil then SpacePanel := GetByName('MainPanel') as TPanelGI;
  Result := SpacePanel.ScrollOffset;
end;
{ @end $525A0C }

{ @routine $525A64 TfFilm_SetViewOffset }
procedure TfFilm.SetViewOffset(Offset: TPoint);
begin
  if SpacePanel = nil then SpacePanel := GetByName('MainPanel') as TPanelGI;
  SpacePanel.SetScrollOffset(Offset);
  if SpaceProcess.Space <> nil then SpaceProcess.Space.MapScrollChanged(nil);
  FilmCameraFollow := False;
end;
{ @end $525A64 }

{ @routine $525AEC TfFilm_FollowViewOffset }
procedure TfFilm.FollowViewOffset(Offset: TPoint);
begin
  if FilmCameraFollow then
  begin
    if SpacePanel = nil then SpacePanel := GetByName('MainPanel') as TPanelGI;
    SpacePanel.SetScrollOffset(Offset);
    if SpaceProcess.Space <> nil then SpaceProcess.Space.MapScrollChanged(nil);
  end;
end;
{ @end $525AEC }

{ @routine $525B74 TfFilm_PanView }
procedure TfFilm.PanView(Timer: TCallbackTimerIdGI; UserData: Cardinal);
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
  if X > Integer(GameScreenWidth) - ScrollSense - 1 then Inc(Offset.X, ScrollStep);
  if Y < ScrollSense then Dec(Offset.Y, ScrollStep);
  if Y > Integer(GameScreenHeight) - ScrollSense - 1 then Inc(Offset.Y, ScrollStep);
  if (OldOffset.X <> Offset.X) or (OldOffset.Y <> Offset.Y) then SetViewOffset(Offset);
end;
{ @end $525B74 }

{ @routine $525C98 TfFilm_KeyDown }
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
{ @end $525C98 }

{ @routine $525D38 TfFilm_KeyUp }
procedure TfFilm.KeyUp(Sender: TObjectGI; Key: Cardinal);
begin
  if Key = VK_LEFT then PanLeft := False
  else if Key = VK_RIGHT then PanRight := False
  else if Key = VK_UP then PanUp := False
  else if Key = VK_DOWN then PanDown := False;
end;
{ @end $525D38 }

{ @routine $525D70 TfFilm_CopyLiveVisualStateToFilm }
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
    Planet := PlayerStar.Planets[Index];
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
      Satellite := Planet.Satellites[SatelliteIndex];
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
    Asteroid := PlayerStar.Asteroids[Index];
    Obj := CurrentFilm.FindObject(ClassSEtoName(Asteroid.GraphObject), Asteroid.GraphObject.GraphKey, Asteroid.Id);
    if (Obj <> nil) and (Obj.SceneObject <> nil) then
      (Obj.SceneObject as TAsteroidSE).SetSequenceFrameIndex(TAsteroidSE(Asteroid.GraphObject).GetSequenceFrameIndex);
  end;
end;
{ @end $525D70 }

{ @routine $52604C TfFilm_CopyFilmVisualStateToLive }
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
    Planet := PlayerStar.Planets[Index];
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
      Satellite := Planet.Satellites[SatelliteIndex];
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
    Asteroid := PlayerStar.Asteroids[Index];
    Obj := CurrentFilm.FindObject(ClassSEtoName(Asteroid.GraphObject), Asteroid.GraphObject.GraphKey, Asteroid.Id);
    if (Obj <> nil) and (Obj.SceneObject <> nil) then
      TAsteroidSE(Asteroid.GraphObject).SetSequenceFrameIndex((Obj.SceneObject as TAsteroidSE).GetSequenceFrameIndex);
  end;
end;
{ @end $52604C }

{ @routine $526328 TfFilm_ExitClicked }
procedure TfFilm.ExitClicked(Sender: TObjectGI);
begin
  CopyFilmVisualStateToLive;
  RequestedScreenId := screenStarMap;
  RequestClose(1);
end;
{ @end $526328 }

{ @routine $526348 TfFilm_CenterShipClicked }
procedure TfFilm.CenterShipClicked(Sender: TObjectGI);
begin
  SetViewOffset(TruncatePointF(CameraTarget));
end;
{ @end $526348 }

{ @routine $526368 TfFilm_SelectHistoryEntry }
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
  DateLabel.Text := Galaxy.FormatTurnDate(CurrentFilm.Turn);
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
  if PreloadHistoryIndex >= FilmHistory.GetCount then PreloadHistoryIndex := FilmHistory.GetCount - 1;
  Loader.Start;
  MinimapFrameCounter := 0;
end;
{ @end $526368 }

{ @routine $526718 TfFilm_CreateFilmSceneObjects }
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
{ @end $526718 }

{ @routine $526758 TfFilm_ReleaseFilmSceneObjects }
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
            if not (Entry.SceneObject is TWeaponSE) then Continue;
            if ((Entry.SceneObject as TWeaponSE).SourceObject <> Obj.SceneObject) and
              ((Entry.SceneObject as TWeaponSE).TargetObject <> Obj.SceneObject) then Continue;
            ReleaseSpaceObject(Entry.RelatedObject1);
            ReleaseSpaceObject(Entry.RelatedObject2);
            TrailingFilmEffects.RemoveEntry(Entry);
          end;
        end;
      ReleaseSpaceObject(Obj.SceneObject);
    end;
    Obj := Obj.Next;
  end;
end;
{ @end $526758 }

{ @routine $52684C TfFilm_ReuseSceneObjectsForPreloadedFilm }
procedure TfFilm.ReuseSceneObjectsForPreloadedFilm;
var NewObj, OldObj: TEFilmObj;
begin
  NewObj := PreloadedFilm.FirstObject;
  while NewObj <> nil do
  begin
    if NewObj.SceneObject = nil then
    begin
      OldObj := CurrentFilm.FindObject(NewObj.KindName, NewObj.GraphKey, NewObj.ObjectId);
      if (OldObj <> nil) and (OldObj.SceneObject <> nil) then
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
{ @end $52684C }

{ @routine $5269D0 TfFilm_AdvancePausedEffects }
procedure TfFilm.AdvancePausedEffects(Timer: TCallbackTimerIdGI; UserData: Cardinal);
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
{ @end $5269D0 }

{ @routine $526A28 TfFilm_SetFrameInterval }
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
    if EffectsTimer <> 0 then
    begin
      CancelCallbackTimer(EffectsTimer);
      EffectsTimer := 0;
    end;
    EffectsTimer := ScheduleCallbackTimer(FrameIntervalMs, FrameIntervalMs, AdvancePausedEffects);
  end;
  if UpdateSlider then SpeedSlider.SetPositionInternal(100 - Round((5 - FrameIntervalMs) / -95.0 * 100.0));
end;
{ @end $526A28 }

{ @routine $526AD0 TfFilm_SpeedSliderChanged }
procedure TfFilm.SpeedSliderChanged(Sender: TObjectGI);
begin
  SetFrameInterval(Round((100 - SpeedSlider.Position) / 100.0 * 95.0 + 5.0), False);
end;
{ @end $526AD0 }

{ @routine $526B1C TfFilm_FrameSliderChanged }
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
{ @end $526B1C }

{ @routine $526B84 TfFilm_PlayStopClicked }
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
{ @end $526B84 }

{ @routine $526BD4 TfFilm_TurnSliderChanged }
procedure TfFilm.TurnSliderChanged(Sender: TObjectGI);
begin
  if Playing then PausePlayback;
  FilmCameraFollow := True;
  SelectHistoryEntry(TurnSlider.Position, False);
  AdvanceOneStep;
end;
{ @end $526BD4 }

{ @routine $526C10 TfFilm_StartPlayback }
procedure TfFilm.StartPlayback;
begin
  if not Playing then
  begin
    if EffectsTimer <> 0 then
    begin
      CancelCallbackTimer(EffectsTimer);
      EffectsTimer := 0;
    end;
    PlaybackTimer := ScheduleCallbackTimer(FrameIntervalMs, FrameIntervalMs, AdvancePlayback);
    PlayButton.IsActive := False;
    StopButton.IsActive := True;
    Playing := True;
  end;
end;
{ @end $526C10 }

{ @routine $526C7C TfFilm_PausePlayback }
procedure TfFilm.PausePlayback;
begin
  if Playing then
  begin
    if PlaybackTimer <> 0 then
    begin
      CancelCallbackTimer(PlaybackTimer);
      PlaybackTimer := 0;
    end;
    SpacePanel.SetDragScrollingEnabled(True);
    if EffectsTimer <> 0 then
    begin
      CancelCallbackTimer(EffectsTimer);
      EffectsTimer := 0;
    end;
    EffectsTimer := ScheduleCallbackTimer(FrameIntervalMs, FrameIntervalMs, AdvancePausedEffects);
    PlayButton.IsActive := True;
    StopButton.IsActive := False;
    Playing := False;
  end;
end;
{ @end $526C7C }

{ @routine $526D14 TfFilm_AdvancePlayback }
procedure TfFilm.AdvancePlayback(Timer: TCallbackTimerIdGI; UserData: Cardinal);
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
{ @end $526D14 }

{ @routine $526D64 TfFilm_AdvanceOneStep }
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
{ @end $526D64 }

{ @routine $526E88 TfFilm_InvalidateAnimatedControls }
procedure TfFilm.InvalidateAnimatedControls;
begin
  UpdateRectsEnabled := True;
  SpacePanel.InvalidateChildren(True);
  CursorControl.Invalidate;
  UpdateRectsEnabled := False;
end;
{ @end $526E88 }

{ @routine $526EB0 TfFilm_DrawFrame }
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
{ @end $526EB0 }

{ @routine $526FE0 TfFilm_SelectMusic }
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
{ @end $526FE0 }

end.
