unit SE_Space;

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Struct, GI_Circle, GI_GI, GI_MessageLoop, GI_Panel,
  GR_Sound, SE_SoundRnd, GI_Frame, GI_StarField, GI_StarFieldM, GI_StarFieldImg, GI_SpaceImg, Types;

type
  TSpaceSE = class;
  TSpaceScrollEventSE = procedure of object;

  TObjectSE = class(TObjectEx) // @size 0x4C @methodorder source
  public
    Prev: TObjectSE; // @offset 0x04
    Next: TObjectSE; // @offset 0x08
    ProcessPrev: TObjectSE; // @offset 0x0C
    ProcessNext: TObjectSE; // @offset 0x10
    Space: TSpaceSE; // @offset 0x14
    GraphKey: WideString; // @offset 0x18
    Size: TPoint; // @offset 0x1C
    Position: TPointF; // @offset 0x24
    DepthExpression: WideString; // @offset 0x2C
    SoundLoopPath: WideString; // @offset 0x30
    SoundGroup: Integer; // @offset 0x34
    LoopSound: TSoundBufferControl; // @offset $38
    RandomSound: TSoundRndSE; // @offset $3C
    RandomSoundGroup: Integer; // @offset $40
    NextSoundTime: Cardinal; // @offset $44
    RefCount: Integer; // @offset 0x48

    constructor CreateEmpty; // @addr 0x0078654C
    constructor Create(const AGraphKey: WideString; UnusedPosition: TPoint); // @addr 0x00786584 @note "UnusedPosition is copied but does not initialize Position."
    destructor Destroy; override; // @addr 0x00786664
    procedure CopyTo(Destination: TObjectSE); virtual; // @addr 0x00786774 @slot 0x00 @note "Copies graph key, size, position and depth expression only."
    property ObjPrev: TObjectSE read Prev write Prev;
    property ObjNext: TObjectSE read Next write Next;
    property PObjPrev: TObjectSE read ProcessPrev write ProcessPrev;
    property PObjNext: TObjectSE read ProcessNext write ProcessNext;
    property SpaceOwner: TSpaceSE read Space;
    procedure AttachToSpace(ASpace: TSpaceSE); virtual; // @addr 0x007867AC @slot 0x04
    procedure DetachFromSpace; virtual; // @addr 0x007867F0 @slot 0x08
    function IsAttachedToSpace: Boolean; // @addr 0x00786820
    property TypeO: WideString read GraphKey;
    procedure SetPosition(APosition: TPointF); virtual; // @addr 0x0078682C @slot 0x0C
    property Pos: TPointF read Position write SetPosition;
    procedure SetDepth(Value: Single); virtual; // @addr $78684C @slot $10
    function GetDepth: Single; virtual; // @addr $786854 @slot $14
    property DepthValue: Single read GetDepth write SetDepth;
    procedure SetOrbitCenter(Center: TPointF); virtual; // @addr $786860 @slot $18
    function GetOrbitCenter: TPointF; virtual; // @addr $786864 @slot $1C @note "Subclasses interpret this point differently: Sputnik returns the orbit center, Ship2 returns scaled dimensions."
    property OrbitCenter: TPointF read GetOrbitCenter write SetOrbitCenter;
    function GetAlpha: Byte; virtual; // @addr $786874 @slot $20
    procedure SetAlpha(Value: Byte); virtual; // @addr $786878 @slot $24
    property Alpha: Byte read GetAlpha write SetAlpha;
    function GetAngle: Byte; virtual; // @addr 0x0078687C @slot 0x28 @note "Base returns zero; TGateSE returns its stored angle."
    procedure SetAngle(Value: Byte); virtual; // @addr $786880 @slot $2C
    property Angle: Byte read GetAngle write SetAngle;
    function GetText: WideString; virtual; // @addr 0x00786884 @slot 0x30 @note "Base returns empty; TGateSE overrides it with the label text."
    procedure SetText(const Value: WideString); virtual; // @addr $786890 @slot $34
    property Text: WideString read GetText write SetText;
    function BuildStateBuffer: TBufEC; virtual; // @addr $786894 @slot $38
    procedure LoadStateBuffer(Buffer: TBufEC); virtual; // @addr $786898 @slot $3C
    procedure Advance; virtual; // @addr $78689C @slot $40
    procedure SetSize(Value: TPoint); virtual; // @addr $786A8C @slot $44
    property ObjectSize: TPoint read Size write SetSize;
    function HitTestCursor: Boolean; virtual; // @addr 0x00786AAC @slot 0x48
    procedure DrawMap; virtual; // @addr 0x00786AB0 @slot 0x4C
    procedure ConfigureLoopSound(const Name: WideString); // @addr $786AB4
    property LoopSoundName: WideString write ConfigureLoopSound;
    procedure ConfigureRandomSound(const Name: WideString); // @addr $786C34
    property RandomSoundName: WideString write ConfigureRandomSound;
    procedure LoadTemplate(Block: TBlockParEC); virtual; // @addr 0x00786C84 @slot 0x50
    procedure ApplyConfig(Block: TBlockParEC); virtual; // @addr 0x00786D8C @slot 0x54
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); virtual; // @addr 0x00786E68 @slot 0x58
  end;

  PSpaceTimerSE = ^TSpaceTimerSE;
  TSpaceTimerEventSE = procedure(Timer: PSpaceTimerSE; UserData: Integer) of object;
  TSpaceTimerSE = record // @size 0x20
    Prev: PSpaceTimerSE; // @offset 0x00
    Next: PSpaceTimerSE; // @offset 0x04
    TicksRemaining: Integer; // @offset 0x08
    RepeatTicks: Integer; // @offset 0x0C
    Callback: TSpaceTimerEventSE; // @offset $10
    UserData: Integer; // @offset 0x18
  end;

  TSpaceSE = class(TObject) // @size 0x6C
  public
    FirstObject: TObjectSE; // @offset 0x04
    LastObject: TObjectSE; // @offset 0x08
    FirstTimer: PSpaceTimerSE; // @offset 0x0C
    LastTimer: PSpaceTimerSE; // @offset 0x10
    NextTimerToProcess: PSpaceTimerSE; // @offset 0x14
    MinimapScale: Double; // @offset 0x18
    MapPanel: TPanelGI; // @offset 0x20
    MinimapControl: TObjectGI; // @offset 0x24
    MinimapViewportFrame: TFrameGI; // @offset $28
    Screen: TMessageLoopGI; // @offset 0x2C
    MinimapBackground: TgiGI; // @offset 0x30
    MinimapRangeShade: TCircleGI; // @offset 0x34
    MinimapRangeCircle: TCircleGI; // @offset 0x38
    StarField: TStarFieldGI; // @offset $3C
    StarFieldM: TStarFieldMGI; // @offset $40
    SpaceImages: TSpaceImgGI; // @offset $44
    StarFieldImages: TStarFieldImgGI; // @offset $48
    MinimapDragging: Boolean; // @offset $4C
    Process: TObject; // @offset 0x50 Native consumers cast this generic owner to TProcessSE.
    ScrollChangedCallback: TSpaceScrollEventSE; // @offset $58
    PathPoints: PPointF; // @offset 0x60  Owned copy, not a Delphi dynamic array.
    PathPointCount: Integer; // @offset 0x64
    AlphaShift: Integer; // @offset $68 Ship2 alpha is shifted by this amount.

    constructor Create(AMapPanel: TPanelGI; AScreen: TMessageLoopGI); // @addr 0x00786E6C
    destructor Destroy; override; // @addr 0x007871A8 @note "Requires all timers to have been removed."
    procedure LinkObject(Obj: TObjectSE); // @addr 0x00787268 @note "Only changes list links; does not retain Obj or set Obj.Space."
    procedure UnlinkObject(Obj: TObjectSE); // @addr 0x0078728C @note "Does not release Obj or clear its links."
    procedure DeleteTimer(Timer: PSpaceTimerSE); // @addr 0x00787344 @note "Raises if Timer is NextTimerToProcess."
    function CreateTimer(DelayMs, RepeatMs: Integer; Callback: TSpaceTimerEventSE; UserData: Integer): PSpaceTimerSE; // @addr 0x007872C0 @note "Converts milliseconds to ticks by rounding division by 18. Callback receives Context, Timer, UserData in Delphi registers. Zero delay still waits for AdvanceTimers."
    procedure AdvanceTimers; // @addr 0x007873C8
    procedure AdvanceObjects; // @addr 0x00787408
    procedure ClearPath; // @addr 0x00787420
    procedure SetPath(Points: PPointF; Count: Integer); // @addr 0x0078743C @note "Copies Count points. A nonpositive count clears the path."
    procedure CreateMinimapViewport; // @addr $7878B4
    procedure FreeMinimapViewport; // @addr $78798C
    procedure MinimapMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $787ABC
    procedure MinimapMouseEnter(Sender: TObjectGI); // @addr $787BD8
    procedure MinimapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $787BE0
    procedure DrawMinimap; // @addr 0x00787480
    function ContainsMapPoint(Point: TPointF): Boolean; // @addr $787CD0
    procedure MapScrollChanged(Sender: TObjectGI); // @addr 0x007879A4
  end;

// Untyped reference slots accept fields declared with concrete scene subclasses.
procedure RetainSpaceObject(var Dest; Source: TObjectSE); // @addr 0x0078674C @note "Overwrites Dest without releasing its previous reference."
procedure ReleaseSpaceObject(var Obj); // @addr 0x00786758 @note "Clears Obj; frees its previous value when the decremented reference count is nonpositive."

implementation

uses Windows, SysUtils, MMSystem, EC_Str, GR_Main, Globals, GlobalsV, aMyFunction,
  SE_Process, SE_Weapon, aEFilm, aEFilmEnd, EC_Mem, GI_Main, GR_GraphBuf, SE_Star, SE_Planet, GI_GraphButton, fStarMap, fFilm;

{ @routine $78654C TObjectSE_CreateEmpty }
constructor TObjectSE.CreateEmpty;
begin
  inherited Create;
end;
{ @end $78654C }

{ @routine $786584 TObjectSE_Create }
constructor TObjectSE.Create(const AGraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create;
  GraphKey := AGraphKey;
  LoadTemplate(GameDataConfig.GetBlockByPath('SE.' + ExtractDelimitedPartW(AGraphKey, 0, ',')));
end;
{ @end $786584 }

{ @routine $786664 TObjectSE_Destroy }
destructor TObjectSE.Destroy;
var
  Obj: TObjectSE;
begin
  DetachFromSpace;
  if (GetCurrentThreadId = MainRuntimeThreadId) and
    (SpaceProcess <> nil) and (SpaceProcess.Space <> nil) then
  begin
    Obj := TSpaceSE(SpaceProcess.Space).FirstObject;
    while Obj <> nil do
    begin
      if Obj is TWeaponSE then
        if Obj.IsAttachedToSpace then
          if (TWeaponSE(Obj).SourceObject = Self) or (TWeaponSE(Obj).TargetObject = Self) then
            Obj.DetachFromSpace;
      Obj := Obj.Next;
    end;
  end;
  if PrimaryFilm <> nil then PrimaryFilm.ReleaseObjectReferences(Self);
  if SecondaryFilm <> nil then SecondaryFilm.ReleaseObjectReferences(Self);
  if TrailingFilmEffects <> nil then TrailingFilmEffects.ReleaseObjectReferences(Self);
  inherited Destroy;
end;
{ @end $786664 }

{ @routine $78674C RetainSpaceObject }
procedure RetainSpaceObject(var Dest; Source: TObjectSE);
begin
  TObjectSE(Dest) := Source;
  if Source <> nil then Inc(Source.RefCount);
end;
{ @end $78674C }

{ @routine $786758 ReleaseSpaceObject }
procedure ReleaseSpaceObject(var Obj);
var
  Previous: TObjectSE;
begin
  Previous := TObjectSE(Obj);
  TObjectSE(Obj) := nil;
  if Previous <> nil then
  begin
    Dec(Previous.RefCount);
    if Previous.RefCount <= 0 then Previous.Free;
  end;
end;
{ @end $786758 }

{ @routine $786774 TObjectSE_CopyTo }
procedure TObjectSE.CopyTo(Destination: TObjectSE);
begin
  Destination.GraphKey := GraphKey;
  Destination.Size := Size;
  Destination.Position := Position;
  Destination.DepthExpression := DepthExpression;
end;
{ @end $786774 }

{ @routine $7867AC TObjectSE_AttachToSpace }
procedure TObjectSE.AttachToSpace(ASpace: TSpaceSE);
begin
  ASpace.LinkObject(Self);
  Space := ASpace;
  if SoundLoopPath <> '' then
  begin
    LoopSound := TSoundBufferControl.Create;
    LoopSound.Configure(SoundLoopPath, SoundGroup, True);
  end;
end;
{ @end $7867AC }

{ @routine $7867F0 TObjectSE_DetachFromSpace }
procedure TObjectSE.DetachFromSpace;
begin
  if LoopSound <> nil then
  begin
    LoopSound.Free;
    LoopSound := nil;
  end;
  if IsAttachedToSpace then
  begin
    Space.UnlinkObject(Self);
    Space := nil;
  end;
end;
{ @end $7867F0 }

{ @routine $786820 TObjectSE_IsAttachedToSpace }
function TObjectSE.IsAttachedToSpace: Boolean;
begin
  if Space = nil then Result := False else Result := True;
end;
{ @end $786820 }

{ @routine $78682C TObjectSE_SetPosition }
procedure TObjectSE.SetPosition(APosition: TPointF);
begin
  Position := APosition;
end;
{ @end $78682C }

{ @routine $78684C TObjectSE_SetDepth }
procedure TObjectSE.SetDepth(Value: Single);
begin

end;
{ @end $78684C }

{ @routine $786854 TObjectSE_GetDepth }
function TObjectSE.GetDepth: Single;
begin
  Result := 0;
end;
{ @end $786854 }

{ @routine $786860 TObjectSE_SetOrbitCenter }
procedure TObjectSE.SetOrbitCenter(Center: TPointF);
begin

end;
{ @end $786860 }

{ @routine $786864 TObjectSE_GetOrbitCenter }
function TObjectSE.GetOrbitCenter: TPointF;
begin
  Result := MakePointF(0, 0);
end;
{ @end $786864 }

{ @routine $786874 TObjectSE_GetAlpha }
function TObjectSE.GetAlpha: Byte;
begin
  Result := 0;
end;
{ @end $786874 }

{ @routine $786878 TObjectSE_SetAlpha }
procedure TObjectSE.SetAlpha(Value: Byte);
begin

end;
{ @end $786878 }

{ @routine $78687C TObjectSE_GetAngle }
function TObjectSE.GetAngle: Byte;
begin
  Result := 0;
end;
{ @end $78687C }

{ @routine $786880 TObjectSE_SetAngle }
procedure TObjectSE.SetAngle(Value: Byte);
begin

end;
{ @end $786880 }

{ @routine $786884 TObjectSE_GetText }
function TObjectSE.GetText: WideString;
begin
  Result := '';
end;
{ @end $786884 }

{ @routine $786890 TObjectSE_SetText }
procedure TObjectSE.SetText(const Value: WideString);
begin

end;
{ @end $786890 }

{ @routine $786894 TObjectSE_BuildStateBuffer }
function TObjectSE.BuildStateBuffer: TBufEC;
begin
  Result := nil;
end;
{ @end $786894 }

{ @routine $786898 TObjectSE_LoadStateBuffer }
procedure TObjectSE.LoadStateBuffer(Buffer: TBufEC);
begin

end;
{ @end $786898 }

{ @routine $78689C TObjectSE_Advance }
procedure TObjectSE.Advance;
var
  Distance: Single;
  Now: Cardinal;
  NextTime: Integer;
begin
  if IsAttachedToSpace then
  begin
    if LoopSound <> nil then
    begin
      Distance := PointDistance(Position, SpaceViewPosition) / (GameScreenHeight / 2);
      if Distance > 1 then LoopSound.SetVolume(0)
      else LoopSound.SetVolume((1 - Distance) * 0.5 + 0.5);
    end;
    try
      if RandomSound <> nil then
        if RandomSoundGroup >= 0 then
        begin
          Now := timeGetTime;
          if Now > NextSoundTime then
          begin
            NextTime := RandomIntRange(RandomSound.Groups[RandomSoundGroup].NextTimeMin,
              RandomSound.Groups[RandomSoundGroup].NextTimeMax) + Integer(Now);
            NextSoundTime := NextTime;
            if Space.ContainsMapPoint(Position) then
              SoundManager.PlayEffect(RandomSound.SelectSound(RandomSoundGroup),
                RandomSound.Groups[RandomSoundGroup].Group, 1, 0);
          end;
        end;
    except
      on E: Exception do AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
    end;
  end;
end;
{ @end $78689C }

{ @routine $786A8C TObjectSE_SetSize }
procedure TObjectSE.SetSize(Value: TPoint);
begin
  Size := Value;
end;
{ @end $786A8C }

{ @routine $786AAC TObjectSE_HitTestCursor }
function TObjectSE.HitTestCursor: Boolean;
begin
  Result := False;
end;
{ @end $786AAC }

{ @routine $786AB0 TObjectSE_DrawMap }
procedure TObjectSE.DrawMap;
begin

end;
{ @end $786AB0 }

{ @routine $786AB4 TObjectSE_ConfigureLoopSound }
procedure TObjectSE.ConfigureLoopSound(const Name: WideString);
var
  Block: TBlockParEC;
  Count, Index, Weight: Integer;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Sound.Loop.' + Name);
  Weight := 0;
  Count := Block.GetParamCount;
  if Count >= 1 then
  begin
    for Index := 0 to Count - 1 do Inc(Weight, ExtractDigitsToIntW(Block.GetParamName(Index)));
    Weight := RandomIntRange(0, Weight - 1);
    for Index := 0 to Count - 1 do
    begin
      Dec(Weight, ExtractDigitsToIntW(Block.GetParamName(Index)));
      if Weight < 0 then
      begin
        SoundLoopPath := Block.GetParamValue(Index);
        SoundGroup := ExtractDigitsToIntW(ExtractDelimitedPartW(SoundLoopPath, 0, ','));
        SoundLoopPath := ExtractDelimitedPartW(SoundLoopPath, 1, ',');
        Exit;
      end;
    end;
  end;
  SoundLoopPath := '';
  SoundGroup := 0;
end;
{ @end $786AB4 }

{ @routine $786C34 TObjectSE_ConfigureRandomSound }
procedure TObjectSE.ConfigureRandomSound(const Name: WideString);
begin
  RandomSound := FindRandomSound(Name, RandomSoundGroup);
  if RandomSoundGroup >= 0 then
    NextSoundTime := timeGetTime + RandomIntRange(RandomSound.Groups[RandomSoundGroup].NextTimeMin,
      RandomSound.Groups[RandomSoundGroup].NextTimeMax);
end;
{ @end $786C34 }

{ @routine $786C84 TObjectSE_LoadTemplate }
procedure TObjectSE.LoadTemplate(Block: TBlockParEC);
begin
  if Block.CountParams('PosZ') > 0 then DepthExpression := Block.GetParam('PosZ');
  if Block.CountParams('SoundLoop') > 0 then SoundLoopPath := Block.GetParam('SoundLoop');
  if Block.CountParams('SoundGroup') > 0 then SoundGroup := ExtractDigitsToIntW(Block.GetParam('SoundGroup'));
end;
{ @end $786C84 }

{ @routine $786D8C TObjectSE_ApplyConfig }
procedure TObjectSE.ApplyConfig(Block: TBlockParEC);
var
  Text: WideString;
begin
  if Block.CountParams('Pos') > 0 then
  begin
    Text := Block.GetParam('Pos');
    Pos := MakePointF(ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
      ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')));
  end;
end;
{ @end $786D8C }

{ @routine $786E68 TObjectSE_QueueImageLoad }
procedure TObjectSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin

end;
{ @end $786E68 }

{ @routine $786E6C TSpaceSE_Create }
constructor TSpaceSE.Create(AMapPanel: TPanelGI; AScreen: TMessageLoopGI);
begin
  inherited Create;
  MapPanel := AMapPanel;
  Screen := AScreen;
  MinimapScale := 0.125;
  MinimapViewportFrame := nil;
  MinimapRangeShade := TCircleGI.Create(SpaceObjectUiLoop.ContentPanel);
  with MinimapRangeShade do
  begin
    SetKind(circle_shift_light);
    Pos := Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1);
    Sme := Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1);
    ObjectSize := Classes.Point(RenderScratchBuffer.Width, RenderScratchBuffer.Height);
    SetShrLightInner(0);
    SetShrLightOuter(1);
  end;
  MinimapRangeCircle := TCircleGI.Create(SpaceObjectUiLoop.ContentPanel);
  with MinimapRangeCircle do
  begin
    SetKind(circle_outline);
    Pos := Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1);
    Sme := Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1);
    ObjectSize := Classes.Point(RenderScratchBuffer.Width, RenderScratchBuffer.Height);
  end;
  MinimapBackground := TgiGI.Create(SpaceObjectUiLoop.ContentPanel);
  with MinimapBackground do
  begin
    SetImagePath('Bm.PanelSpace2.' + GiResourceSuffix + 'RadarT');
    ObjectSize := Classes.Point(RenderScratchBuffer.Width, RenderScratchBuffer.Height);
  end;
  StarField := TStarFieldGI(Screen.FindControlByPath('StarField'));
  StarFieldM := TStarFieldMGI(Screen.FindControlByPath('StarFieldM'));
  SpaceImages := TSpaceImgGI(Screen.FindControlByPath('SpaceImg'));
  StarFieldImages := TStarFieldImgGI(Screen.FindControlByPath('StarFieldImg'));
  AlphaShift := 0;
end;
{ @end $786E6C }

{ @routine $7871A8 TSpaceSE_Destroy }
destructor TSpaceSE.Destroy;
begin
  ClearPath;
  MinimapRangeShade.Free;
  MinimapRangeShade := nil;
  MinimapRangeCircle.Free;
  MinimapRangeCircle := nil;
  MinimapBackground.Free;
  MinimapBackground := nil;
  StarField := nil;
  StarFieldM := nil;
  SpaceImages := nil;
  StarFieldImages := nil;
  while FirstObject <> nil do LastObject.DetachFromSpace;
  MapPanel := nil;
  if FirstTimer <> nil then raise Exception.Create('destructor TSpaceSE.Destroy;');
  inherited Destroy;
end;
{ @end $7871A8 }

{ @routine $787268 TSpaceSE_LinkObject }
procedure TSpaceSE.LinkObject(Obj: TObjectSE);
begin
  if LastObject <> nil then LastObject.Next := Obj;
  Obj.Prev := LastObject;
  Obj.Next := nil;
  LastObject := Obj;
  if FirstObject = nil then FirstObject := Obj;
end;
{ @end $787268 }

{ @routine $78728C TSpaceSE_UnlinkObject }
procedure TSpaceSE.UnlinkObject(Obj: TObjectSE);
begin
  if Obj.Prev <> nil then Obj.Prev.Next := Obj.Next;
  if Obj.Next <> nil then Obj.Next.Prev := Obj.Prev;
  if LastObject = Obj then LastObject := Obj.Prev;
  if FirstObject = Obj then FirstObject := Obj.Next;
end;
{ @end $78728C }

{ @routine $7872C0 TSpaceSE_CreateTimer }
function TSpaceSE.CreateTimer(DelayMs, RepeatMs: Integer; Callback: TSpaceTimerEventSE; UserData: Integer): PSpaceTimerSE;
var
  Timer: PSpaceTimerSE;
begin
  Timer := AllocEC(SizeOf(TSpaceTimerSE));
  if LastTimer <> nil then LastTimer.Next := Timer;
  Timer.Prev := LastTimer;
  Timer.Next := nil;
  LastTimer := Timer;
  if FirstTimer = nil then FirstTimer := Timer;
  Timer.TicksRemaining := Round(DelayMs / 18);
  Timer.RepeatTicks := Round(RepeatMs / 18);
  Timer.Callback := Callback;
  Timer.UserData := UserData;
  Result := Timer;
end;
{ @end $7872C0 }

{ @routine $787344 TSpaceSE_DeleteTimer }
procedure TSpaceSE.DeleteTimer(Timer: PSpaceTimerSE);
var
  Entry: PSpaceTimerSE;
begin
  Entry := Timer;
  if NextTimerToProcess = Entry then raise Exception.Create('procedure TSpaceSE.ST_Delete(id:DWORD);');
  if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
  if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
  if LastTimer = Entry then LastTimer := Entry.Prev;
  if FirstTimer = Entry then FirstTimer := Entry.Next;
  FreeEC(Entry);
end;
{ @end $787344 }

{ @routine $7873C8 TSpaceSE_AdvanceTimers }
procedure TSpaceSE.AdvanceTimers;
var
  Timer: PSpaceTimerSE;
begin
  NextTimerToProcess := FirstTimer;
  while NextTimerToProcess <> nil do
  begin
    Timer := NextTimerToProcess;
    NextTimerToProcess := NextTimerToProcess.Next;
    Dec(Timer.TicksRemaining);
    if Timer.TicksRemaining <= 0 then
    begin
      Timer.TicksRemaining := Timer.RepeatTicks;
      Timer.Callback(Timer, Timer.UserData);
    end;
  end;
  NextTimerToProcess := nil;
end;
{ @end $7873C8 }

{ @routine $787408 TSpaceSE_AdvanceObjects }
procedure TSpaceSE.AdvanceObjects;
var
  Obj: TObjectSE;
begin
  Obj := FirstObject;
  while Obj <> nil do
  begin
    Obj.Advance;
    Obj := Obj.Next;
  end;
end;
{ @end $787408 }

{ @routine $787420 TSpaceSE_ClearPath }
procedure TSpaceSE.ClearPath;
begin
  if PathPoints <> nil then
  begin
    FreeEC(PathPoints);
    PathPoints := nil;
  end;
  PathPointCount := 0;
end;
{ @end $787420 }

{ @routine $78743C TSpaceSE_SetPath }
procedure TSpaceSE.SetPath(Points: PPointF; Count: Integer);
begin
  ClearPath;
  if Count < 1 then Exit;
  PathPointCount := Count;
  PathPoints := AllocEC(Count * SizeOf(TPointF));
  CopyMemory(PathPoints, Points, Count * SizeOf(TPointF));
end;
{ @end $78743C }

{ @routine $787480 TSpaceSE_DrawMinimap }
procedure TSpaceSE.DrawMinimap;
var
  Obj: TObjectSE;
  SavedBuffer: TGraphBufGR;
  CurrentProcess: TProcessSE;
  Coordinate: PSingle;
  Index, X1, Y1, X2, Y2, CenterX, CenterY: Integer;
  Color: Cardinal;
  SavedHardware: Boolean;
  Clip: TRect;
begin
  SavedBuffer := ScreenRenderBuffer;
  ScreenRenderBuffer := RenderScratchBuffer;
  SavedHardware := HardwareRenderingEnabled;
  HardwareRenderingEnabled := False;
  CurrentProcess := Process as TProcessSE;
  Clip := Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height);
  MinimapBackground.HitTestBounds := Clip;
  MinimapBackground.Draw(Clip);
  Obj := FirstObject;
  while Obj <> nil do
  begin
    if Obj is TStarSE then Obj.DrawMap;
    Obj := Obj.Next;
  end;
  Obj := FirstObject;
  while Obj <> nil do
  begin
    if Obj is TPlanetSE then Obj.DrawMap;
    Obj := Obj.Next;
  end;
  Obj := FirstObject;
  while Obj <> nil do
  begin
    if not (Obj is TStarSE) then
      if not (Obj is TPlanetSE) then Obj.DrawMap;
    Obj := Obj.Next;
  end;
  if PathPoints <> nil then
  begin
    CenterX := RenderScratchBuffer.Width shr 1;
    CenterY := RenderScratchBuffer.Height shr 1;
    Coordinate := @PathPoints.X;
    X1 := CenterX + Round(Coordinate^ * MinimapScale);
    Inc(Coordinate);
    Y1 := CenterY + Round(Coordinate^ * MinimapScale);
    Inc(Coordinate);
    for Index := 1 to PathPointCount - 1 do
    begin
      X2 := CenterX + Round(Coordinate^ * MinimapScale);
      Inc(Coordinate);
      Y2 := CenterY + Round(Coordinate^ * MinimapScale);
      Inc(Coordinate);
      if not Odd(Index div 199) then Color := CurrentPixelFormat.PackRgbBytes($C3, $31, 0)
      else Color := CurrentPixelFormat.PackRgbBytes($8F, $C1, 0);
      Ex_OKGR_Line_DrawClip_WORD(RenderScratchBuffer.GetPixels, RenderScratchBuffer.PitchBytes,
        X1, Y1, X2, Y2, Color, Clip);
      X1 := X2;
      Y1 := Y2;
    end;
  end;
  if CurrentProcess.RadarRange > 0 then
  begin
    MinimapRangeShade.SetCenter(Classes.Point((RenderScratchBuffer.Width shr 1) + Round(CurrentProcess.RadarCenter.X * MinimapScale),
      (RenderScratchBuffer.Height shr 1) + Round(CurrentProcess.RadarCenter.Y * MinimapScale)));
    MinimapRangeShade.SetRadius(Round(CurrentProcess.ActionRange * MinimapScale));
    MinimapRangeShade.HitTestBounds := Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height);
    MinimapRangeShade.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
    MinimapRangeCircle.SetCenter(Classes.Point((RenderScratchBuffer.Width shr 1) + Round(CurrentProcess.RadarCenter.X * MinimapScale),
      (RenderScratchBuffer.Height shr 1) + Round(CurrentProcess.RadarCenter.Y * MinimapScale)));
    MinimapRangeCircle.SetRadius(Round(CurrentProcess.ActionRange * MinimapScale));
    MinimapRangeCircle.SetColor(CurrentProcess.ActionColor);
    MinimapRangeCircle.HitTestBounds := Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height);
    MinimapRangeCircle.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
  end;
  MinimapViewportFrame.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
  HardwareRenderingEnabled := SavedHardware;
  ScreenRenderBuffer := SavedBuffer;
end;
{ @end $787480 }

{ @routine $7878B4 TSpaceSE_CreateMinimapViewport }
procedure TSpaceSE.CreateMinimapViewport;
var
  Width, Height: Integer;
begin
  FreeMinimapViewport;
  MinimapViewportFrame := TFrameGI.Create(SpaceObjectUiLoop.ContentPanel);
  MinimapViewportFrame.SetDepth(-99999);
  MinimapViewportFrame.SetKind(frame_rect_border);
  MinimapViewportFrame.SetColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
  Width := Round(MapPanel.ClientSize.X * MinimapScale);
  Height := Round(MapPanel.ClientSize.Y * MinimapScale);
  MinimapViewportFrame.ObjectSize := Classes.Point(Width, Height);
  MinimapViewportFrame.Sme := Classes.Point(Width div 2, Height div 2);
  MapPanel.ScrollChangedCallback := MapScrollChanged;
  MapScrollChanged(nil);
end;
{ @end $7878B4 }

{ @routine $78798C TSpaceSE_FreeMinimapViewport }
procedure TSpaceSE.FreeMinimapViewport;
begin
  if MinimapViewportFrame <> nil then
  begin
    MinimapViewportFrame.Free;
    MinimapViewportFrame := nil;
  end;
end;
{ @end $78798C }

{ @routine $7879A4 TSpaceSE_MapScrollChanged }
procedure TSpaceSE.MapScrollChanged(Sender: TObjectGI);
begin
  if Sender = MapPanel then FilmCameraFollow := False;
  if MinimapViewportFrame <> nil then
    MinimapViewportFrame.Pos := Classes.Point(Round(MapPanel.ScrollOffset.X * MinimapScale),
      Round(MapPanel.ScrollOffset.Y * MinimapScale));
  if StarField <> nil then StarField.SetViewPosition(PointToPointF(MapPanel.ScrollOffset));
  if (Wind >= 1) and (StarFieldM <> nil) then
    StarFieldM.SetViewPosition(PointToPointF(MapPanel.ScrollOffset));
  if SpaceImages <> nil then SpaceImages.SetViewPosition(PointToPointF(MapPanel.ScrollOffset));
  if (Wind >= 2) and (StarFieldImages <> nil) then
    StarFieldImages.SetViewPosition(PointToPointF(MapPanel.ScrollOffset));
  if Assigned(ScrollChangedCallback) then ScrollChangedCallback;
  (Process as TProcessSE).UpdateViewRect;
  SpaceViewPosition := PointToPointF(MapPanel.ScrollOffset);
end;
{ @end $7879A4 }

{ @routine $787ABC TSpaceSE_MinimapMouseDown }
procedure TSpaceSE.MinimapMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Local: TPoint;
  Child: TObjectGI;
begin
  MinimapDragging := False;
  if Sender.IsOccludedAtPoint(Point) then Exit;
  if Screen = StarMapScreen then
  begin
    if StarMapScreen.CenterShipButton.HitTest(Point) then Exit;
    Child := StarMapScreen.SecondaryPartnerPanel.FirstChild;
    while Child <> nil do
    begin
      if (Child as TGraphButtonGI).HitTest(Point) then Exit;
      Child := Child.NextSibling;
    end;
  end;
  if Screen = FilmScreen then
    if FilmScreen.CenterShipButton.HitTest(Point) then Exit;
  MinimapDragging := True;
  FilmCameraFollow := False;
  Local := Sender.ToLocalPoint(Point);
  MapPanel.SetScrollOffset(Classes.Point(Round(Local.X / MinimapScale), Round(Local.Y / MinimapScale)));
  MapScrollChanged(nil);
  MinimapFrameCounter := 0;
end;
{ @end $787ABC }

{ @routine $787BD8 TSpaceSE_MinimapMouseEnter }
procedure TSpaceSE.MinimapMouseEnter(Sender: TObjectGI);
begin
  MinimapDragging := False;
end;
{ @end $787BD8 }

{ @routine $787BE0 TSpaceSE_MinimapMouseMove }
procedure TSpaceSE.MinimapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Local: TPoint;
begin
  if not MinimapDragging then Exit;
  if (Integer(KeyState and MK_LBUTTON) <> MK_LBUTTON) and ((KeyState and MK_RBUTTON) <> MK_RBUTTON) then Exit;
  if Sender.IsOccludedAtPoint(Point) then Exit;
  if StarMapScreen = Screen then
    if StarMapScreen.CenterShipButton.HitTest(Point) then Exit;
  if FilmScreen = Screen then
    if FilmScreen.CenterShipButton.HitTest(Point) then Exit;
  Local := Sender.ToLocalPoint(Point);
  MapPanel.SetScrollOffset(Classes.Point(Round(Local.X / MinimapScale), Round(Local.Y / MinimapScale)));
  MapScrollChanged(nil);
  MinimapFrameCounter := 0;
end;
{ @end $787BE0 }

{ @routine $787CD0 TSpaceSE_ContainsMapPoint }
function TSpaceSE.ContainsMapPoint(Point: TPointF): Boolean;
begin
  if MapPanel = nil then Result := False
  else Result := MapPanel.ContainsPoint(MapPanel.ToAbsolutePoint(TruncatePointF(Point)));
end;
{ @end $787CD0 }

end.
