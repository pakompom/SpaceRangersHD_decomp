unit SE_Space;
// Unit bracket (inferred): .text 0x00838C6C..0x0083AB4F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Struct, GI_Circle, GI_GI, GI_MessageLoop, GI_Panel,
  GR_Sound, SE_SoundRnd, GI_Frame, GI_StarField, GI_StarFieldM, GI_StarFieldImg, GI_SpaceImg, Types;

type
  TSpaceSE = class;
  TSpaceScrollEventSE = procedure of object;

  TObjectSE = class(TObjectEx) // @size 0x4C
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

    constructor CreateEmpty; // @addr 0x838D98
    procedure CopyTo(Destination: TObjectSE); virtual; // @addr 0x839034 @slot 0x00 @note "Copies graph key, size, position and depth expression only."
    constructor Create(const AGraphKey: WideString; UnusedPosition: TPoint); // @addr 0x838DDC @note "UnusedPosition is copied but does not initialize Position."
    destructor Destroy; override; // @addr 0x838EC8
    procedure AttachToSpace(ASpace: TSpaceSE); virtual; // @addr 0x83908C @slot 0x04
    procedure DetachFromSpace; virtual; // @addr 0x8390EC @slot 0x08
    function IsAttachedToSpace: Boolean; // @addr 0x839134
    procedure SetPosition(APosition: TPointF); virtual; // @addr 0x839158 @slot 0x0C
    procedure SetDepth(Value: Single); virtual; // @addr $839180 @slot $10
    function GetDepth: Single; virtual; // @addr $83918C @slot $14
    procedure SetOrbitCenter(Center: TPointF); virtual; // @addr $8391A4 @slot $18
    function GetOrbitCenter: TPointF; virtual; // @addr $8391BC @slot $1C @note "Subclasses interpret this point differently: Sputnik returns the orbit center, Ship2 returns scaled dimensions."
    function GetAlpha: Byte; virtual; // @addr $8391D8 @slot $20
    procedure SetAlpha(Value: Byte); virtual; // @addr $8391EC @slot $24
    procedure SetAngle(Value: Byte); virtual; // @addr $839210 @slot $2C
    procedure SetText(const Value: WideString); virtual; // @addr $839238 @slot $34
    function BuildStateBuffer: TBufEC; virtual; // @addr $839248 @slot $38
    procedure LoadStateBuffer(Buffer: TBufEC); virtual; // @addr $839260 @slot $3C
    procedure Advance; virtual; // @addr $839270 @slot $40
    procedure SetSize(Value: TPoint); virtual; // @addr $8394B4 @slot $44
    procedure ConfigureLoopSound(const Name: WideString); // @addr $8394FC
    procedure ConfigureRandomSound(const Name: WideString); // @addr $8396B8
    function GetAngle: Byte; virtual; // @addr 0x8391FC @slot 0x28 @note "Base returns zero; TGateSE returns its stored angle."
    function GetText: WideString; virtual; // @addr 0x839220 @slot 0x30 @note "Base returns empty; TGateSE overrides it with the label text."
    function HitTestCursor: Boolean; virtual; // @addr 0x8394DC @slot 0x48
    procedure DrawMap; virtual; // @addr 0x8394F0 @slot 0x4C
    procedure LoadTemplate(Block: TBlockParEC); virtual; // @addr 0x839730 @slot 0x50
    procedure ApplyConfig(Block: TBlockParEC); virtual; // @addr 0x839848 @slot 0x54
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); virtual; // @addr 0x83992C @slot 0x58
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

    constructor Create(AMapPanel: TPanelGI; AScreen: TMessageLoopGI); // @addr 0x839940
    destructor Destroy; override; // @addr 0x839CD4 @note "Requires all timers to have been removed."
    procedure LinkObject(Obj: TObjectSE); // @addr 0x839DCC @note "Only changes list links; does not retain Obj or set Obj.Space."
    procedure UnlinkObject(Obj: TObjectSE); // @addr 0x839E20 @note "Does not release Obj or clear its links."
    procedure DeleteTimer(Timer: PSpaceTimerSE); // @addr 0x839F44 @note "Raises if Timer is NextTimerToProcess."
    function CreateTimer(DelayMs, RepeatMs: Integer; Callback: TSpaceTimerEventSE; UserData: Integer): PSpaceTimerSE; // @addr 0x839E90 @note "Converts milliseconds to ticks by rounding division by 18. Callback receives Context, Timer, UserData in Delphi registers. Zero delay still waits for AdvanceTimers."
    procedure AdvanceTimers; // @addr 0x83A00C
    procedure AdvanceObjects; // @addr 0x83A080
    procedure ClearPath; // @addr 0x83A0B4
    procedure SetPath(Points: PPointF; Count: Integer); // @addr 0x83A0E4 @note "Copies Count points. A nonpositive count clears the path."
    procedure CreateMinimapViewport; // @addr $83A5EC
    procedure FreeMinimapViewport; // @addr $83A6F8
    procedure MinimapMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $83A88C
    procedure MinimapMouseEnter(Sender: TObjectGI); // @addr $83A9D0
    procedure MinimapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $83A9E8
    procedure DrawMinimap; // @addr 0x83A134
    function ContainsMapPoint(Point: TPointF): Boolean; // @addr $83AAF4
    procedure MapScrollChanged(Sender: TObjectGI); // @addr 0x83A720
  end;

procedure RetainSpaceObject(var Dest: TObjectSE; Source: TObjectSE); // @addr 0x838FD4 @note "Overwrites Dest without releasing its previous reference."
procedure ReleaseSpaceObject(var Obj: TObjectSE); // @addr 0x838FF8 @note "Clears Obj; frees its previous value when the decremented reference count is nonpositive."

implementation

uses Windows, SysUtils, MMSystem, EC_Str, GR_Main, Globals, GlobalsV, aMyFunction,
  SE_Process, SE_Weapon, aEFilm, aEFilmEnd, EC_Mem, GI_Main, GR_GraphBuf, SE_Star, SE_Planet, GI_GraphButton, fStarMap, fFilm;

{ @routine $838D98 TObjectSE_CreateEmpty }
constructor TObjectSE.CreateEmpty;
begin
  inherited Create;
end;
{ @end $838D98 }

{ @routine $838DDC TObjectSE_Create }
constructor TObjectSE.Create(const AGraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create;
  GraphKey := AGraphKey;
  LoadTemplate(GameDataConfig.GetBlockByPath('SE.' + ExtractDelimitedPartW(AGraphKey, 0, ',')));
end;
{ @end $838DDC }

{ @routine $838EC8 TObjectSE_Destroy }
destructor TObjectSE.Destroy;
var
  Obj: TObjectSE;
begin
  DetachFromSpace;
  if GetCurrentThreadId = MainRuntimeThreadId then
    if SpaceProcess <> nil then
      if SpaceProcess.Space <> nil then
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
{ @end $838EC8 }

{ @routine $838FD4 RetainSpaceObject }
procedure RetainSpaceObject(var Dest: TObjectSE; Source: TObjectSE);
begin
  Dest := Source;
  if Source <> nil then Inc(Source.RefCount);
end;
{ @end $838FD4 }

{ @routine $838FF8 ReleaseSpaceObject }
procedure ReleaseSpaceObject(var Obj: TObjectSE);
var
  Previous: TObjectSE;
begin
  Previous := Obj;
  Obj := nil;
  if Previous <> nil then
  begin
    Dec(Previous.RefCount);
    if Previous.RefCount <= 0 then Previous.Free;
  end;
end;
{ @end $838FF8 }

{ @routine $839034 TObjectSE_CopyTo }
procedure TObjectSE.CopyTo(Destination: TObjectSE);
begin
  Destination.GraphKey := GraphKey;
  Destination.Size := Size;
  Destination.Position := Position;
  Destination.DepthExpression := DepthExpression;
end;
{ @end $839034 }

{ @routine $83908C TObjectSE_AttachToSpace }
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
{ @end $83908C }

{ @routine $8390EC TObjectSE_DetachFromSpace }
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
{ @end $8390EC }

{ @routine $839134 TObjectSE_IsAttachedToSpace }
function TObjectSE.IsAttachedToSpace: Boolean;
begin
  if Space = nil then Result := False else Result := True;
end;
{ @end $839134 }

{ @routine $839158 TObjectSE_SetPosition }
procedure TObjectSE.SetPosition(APosition: TPointF);
begin
  Position := APosition;
end;
{ @end $839158 }

{ @routine $839180 TObjectSE_SetDepth }
procedure TObjectSE.SetDepth(Value: Single);
begin

end;
{ @end $839180 }

{ @routine $83918C TObjectSE_GetDepth }
function TObjectSE.GetDepth: Single;
begin
  Result := 0;
end;
{ @end $83918C }

{ @routine $8391A4 TObjectSE_SetOrbitCenter }
procedure TObjectSE.SetOrbitCenter(Center: TPointF);
begin

end;
{ @end $8391A4 }

{ @routine $8391BC TObjectSE_GetOrbitCenter }
function TObjectSE.GetOrbitCenter: TPointF;
begin
  Result := MakePointF(0, 0);
end;
{ @end $8391BC }

{ @routine $8391D8 TObjectSE_GetAlpha }
function TObjectSE.GetAlpha: Byte;
begin
  Result := 0;
end;
{ @end $8391D8 }

{ @routine $8391EC TObjectSE_SetAlpha }
procedure TObjectSE.SetAlpha(Value: Byte);
begin

end;
{ @end $8391EC }

{ @routine $8391FC TObjectSE_GetAngle }
function TObjectSE.GetAngle: Byte;
begin
  Result := 0;
end;
{ @end $8391FC }

{ @routine $839210 TObjectSE_SetAngle }
procedure TObjectSE.SetAngle(Value: Byte);
begin

end;
{ @end $839210 }

{ @routine $839220 TObjectSE_GetText }
function TObjectSE.GetText: WideString;
begin
  Result := '';
end;
{ @end $839220 }

{ @routine $839238 TObjectSE_SetText }
procedure TObjectSE.SetText(const Value: WideString);
begin

end;
{ @end $839238 }

{ @routine $839248 TObjectSE_BuildStateBuffer }
function TObjectSE.BuildStateBuffer: TBufEC;
begin
  Result := nil;
end;
{ @end $839248 }

{ @routine $839260 TObjectSE_LoadStateBuffer }
procedure TObjectSE.LoadStateBuffer(Buffer: TBufEC);
begin

end;
{ @end $839260 }

{ @routine $839270 TObjectSE_Advance }
procedure TObjectSE.Advance;
var
  Distance: Single;
  Now: Cardinal;
  Delay: Integer;
begin
  if IsAttachedToSpace then
  begin
    if LoopSound <> nil then
    begin
      Distance := PointDistance(Position, SpaceViewPosition) / (Cardinal(GameScreenHeight) / 2);
      if Distance > 1 then LoopSound.SetVolume(0)
      else LoopSound.SetVolume((1 - Distance) * 0.5 + 0.5);
    end;
    try
      if RandomSound <> nil then
        if RandomSoundGroup >= 0 then
        begin
          Now := timeGetTime;
          if NextSoundTime < Now then
          begin
            Delay := RandomIntRange(RandomSound.Groups[RandomSoundGroup].NextTimeMin,
              RandomSound.Groups[RandomSoundGroup].NextTimeMax);
            NextSoundTime := Now + Delay;
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
{ @end $839270 }

{ @routine $8394B4 TObjectSE_SetSize }
procedure TObjectSE.SetSize(Value: TPoint);
begin
  Size := Value;
end;
{ @end $8394B4 }

{ @routine $8394DC TObjectSE_HitTestCursor }
function TObjectSE.HitTestCursor: Boolean;
begin
  Result := False;
end;
{ @end $8394DC }

{ @routine $8394F0 TObjectSE_DrawMap }
procedure TObjectSE.DrawMap;
begin

end;
{ @end $8394F0 }

{ @routine $8394FC TObjectSE_ConfigureLoopSound }
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
{ @end $8394FC }

{ @routine $8396B8 TObjectSE_ConfigureRandomSound }
procedure TObjectSE.ConfigureRandomSound(const Name: WideString);
begin
  RandomSound := FindRandomSound(Name, RandomSoundGroup);
  if RandomSoundGroup >= 0 then
    NextSoundTime := timeGetTime + RandomIntRange(RandomSound.Groups[RandomSoundGroup].NextTimeMin,
      RandomSound.Groups[RandomSoundGroup].NextTimeMax);
end;
{ @end $8396B8 }

{ @routine $839730 TObjectSE_LoadTemplate }
procedure TObjectSE.LoadTemplate(Block: TBlockParEC);
begin
  if Block.CountParams('PosZ') > 0 then DepthExpression := Block.GetParam('PosZ');
  if Block.CountParams('SoundLoop') > 0 then SoundLoopPath := Block.GetParam('SoundLoop');
  if Block.CountParams('SoundGroup') > 0 then SoundGroup := ExtractDigitsToIntW(Block.GetParam('SoundGroup'));
end;
{ @end $839730 }

{ @routine $839848 TObjectSE_ApplyConfig }
procedure TObjectSE.ApplyConfig(Block: TBlockParEC);
var
  Text: WideString;
begin
  if Block.CountParams('Pos') > 0 then
  begin
    Text := Block.GetParam('Pos');
    SetPosition(MakePointF(ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
      ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ','))));
  end;
end;
{ @end $839848 }

{ @routine $83992C TObjectSE_QueueImageLoad }
procedure TObjectSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin

end;
{ @end $83992C }

{ @routine $839940 TSpaceSE_Create }
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
    SetKind(ckShrLight);
    SetPosition(Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1));
    SetOrigin(Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1));
    SetSize(Classes.Point(RenderScratchBuffer.Width, RenderScratchBuffer.Height));
    SetShrLightInner(0);
    SetShrLightOuter(1);
  end;
  MinimapRangeCircle := TCircleGI.Create(SpaceObjectUiLoop.ContentPanel);
  with MinimapRangeCircle do
  begin
    SetKind(ckCircle);
    SetPosition(Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1));
    SetOrigin(Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1));
    SetSize(Classes.Point(RenderScratchBuffer.Width, RenderScratchBuffer.Height));
  end;
  MinimapBackground := TgiGI.Create(SpaceObjectUiLoop.ContentPanel);
  with MinimapBackground do
  begin
    SetImagePath('Bm.PanelSpace2.' + GiResourceSuffix + 'RadarT');
    SetSize(Classes.Point(RenderScratchBuffer.Width, RenderScratchBuffer.Height));
  end;
  StarField := TStarFieldGI(Screen.FindControlByPath('StarField'));
  StarFieldM := TStarFieldMGI(Screen.FindControlByPath('StarFieldM'));
  SpaceImages := TSpaceImgGI(Screen.FindControlByPath('SpaceImg'));
  StarFieldImages := TStarFieldImgGI(Screen.FindControlByPath('StarFieldImg'));
  AlphaShift := 0;
end;
{ @end $839940 }

{ @routine $839CD4 TSpaceSE_Destroy }
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
{ @end $839CD4 }

{ @routine $839DCC TSpaceSE_LinkObject }
procedure TSpaceSE.LinkObject(Obj: TObjectSE);
begin
  if LastObject <> nil then LastObject.Next := Obj;
  Obj.Prev := LastObject;
  Obj.Next := nil;
  LastObject := Obj;
  if FirstObject = nil then FirstObject := Obj;
end;
{ @end $839DCC }

{ @routine $839E20 TSpaceSE_UnlinkObject }
procedure TSpaceSE.UnlinkObject(Obj: TObjectSE);
begin
  if Obj.Prev <> nil then Obj.Prev.Next := Obj.Next;
  if Obj.Next <> nil then Obj.Next.Prev := Obj.Prev;
  if LastObject = Obj then LastObject := Obj.Prev;
  if FirstObject = Obj then FirstObject := Obj.Next;
end;
{ @end $839E20 }

{ @routine $839E90 TSpaceSE_CreateTimer }
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
{ @end $839E90 }

{ @routine $839F44 TSpaceSE_DeleteTimer }
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
{ @end $839F44 }

{ @routine $83A00C TSpaceSE_AdvanceTimers }
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
{ @end $83A00C }

{ @routine $83A080 TSpaceSE_AdvanceObjects }
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
{ @end $83A080 }

{ @routine $83A0B4 TSpaceSE_ClearPath }
procedure TSpaceSE.ClearPath;
begin
  if PathPoints <> nil then
  begin
    FreeEC(PathPoints);
    PathPoints := nil;
  end;
  PathPointCount := 0;
end;
{ @end $83A0B4 }

{ @routine $83A0E4 TSpaceSE_SetPath }
procedure TSpaceSE.SetPath(Points: PPointF; Count: Integer);
begin
  ClearPath;
  if Count < 1 then Exit;
  PathPointCount := Count;
  PathPoints := AllocEC(Count * SizeOf(TPointF));
  CopyMemory(PathPoints, Points, Count * SizeOf(TPointF));
end;
{ @end $83A0E4 }

{ @routine $83A134 TSpaceSE_DrawMinimap }
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
    Coordinate := Pointer(PathPoints);
    X1 := CenterX + Round(Coordinate^ * MinimapScale);
    Coordinate := Pointer(PAnsiChar(Coordinate) + SizeOf(Single));
    Y1 := CenterY + Round(Coordinate^ * MinimapScale);
    Coordinate := Pointer(PAnsiChar(Coordinate) + SizeOf(Single));
    for Index := 1 to PathPointCount - 1 do
    begin
      X2 := CenterX + Round(Coordinate^ * MinimapScale);
      Coordinate := Pointer(PAnsiChar(Coordinate) + SizeOf(Single));
      Y2 := CenterY + Round(Coordinate^ * MinimapScale);
      Coordinate := Pointer(PAnsiChar(Coordinate) + SizeOf(Single));
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
{ @end $83A134 }

{ @routine $83A5EC TSpaceSE_CreateMinimapViewport }
procedure TSpaceSE.CreateMinimapViewport;
var
  Width, Height: Integer;
begin
  FreeMinimapViewport;
  MinimapViewportFrame := TFrameGI.Create(SpaceObjectUiLoop.ContentPanel);
  MinimapViewportFrame.SetDepth(-99999);
  MinimapViewportFrame.SetKind(fkRect);
  MinimapViewportFrame.SetColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
  Width := Round(MapPanel.ClientSize.X * MinimapScale);
  Height := Round(MapPanel.ClientSize.Y * MinimapScale);
  MinimapViewportFrame.SetSize(Classes.Point(Width, Height));
  MinimapViewportFrame.SetOrigin(Classes.Point(Width div 2, Height div 2));
  MapPanel.ScrollChangedCallback := MapScrollChanged;
  MapScrollChanged(nil);
end;
{ @end $83A5EC }

{ @routine $83A6F8 TSpaceSE_FreeMinimapViewport }
procedure TSpaceSE.FreeMinimapViewport;
begin
  if MinimapViewportFrame <> nil then
  begin
    MinimapViewportFrame.Free;
    MinimapViewportFrame := nil;
  end;
end;
{ @end $83A6F8 }

{ @routine $83A720 TSpaceSE_MapScrollChanged }
procedure TSpaceSE.MapScrollChanged(Sender: TObjectGI);
begin
  if Sender = MapPanel then FilmCameraFollow := False;
  if MinimapViewportFrame <> nil then
    MinimapViewportFrame.SetPosition(Classes.Point(Round(MapPanel.ScrollOffset.X * MinimapScale),
      Round(MapPanel.ScrollOffset.Y * MinimapScale)));
  if StarField <> nil then StarField.SetViewPosition(PointToPointF(MapPanel.ScrollOffset));
  if Wind >= 1 then
    if StarFieldM <> nil then StarFieldM.SetViewPosition(PointToPointF(MapPanel.ScrollOffset));
  if SpaceImages <> nil then SpaceImages.SetViewPosition(PointToPointF(MapPanel.ScrollOffset));
  if Wind >= 2 then
    if StarFieldImages <> nil then StarFieldImages.SetViewPosition(PointToPointF(MapPanel.ScrollOffset));
  if Assigned(ScrollChangedCallback) then ScrollChangedCallback;
  (Process as TProcessSE).UpdateViewRect;
  SpaceViewPosition := PointToPointF(MapPanel.ScrollOffset);
end;
{ @end $83A720 }

{ @routine $83A88C TSpaceSE_MinimapMouseDown }
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
{ @end $83A88C }

{ @routine $83A9D0 TSpaceSE_MinimapMouseEnter }
procedure TSpaceSE.MinimapMouseEnter(Sender: TObjectGI);
begin
  MinimapDragging := False;
end;
{ @end $83A9D0 }

{ @routine $83A9E8 TSpaceSE_MinimapMouseMove }
procedure TSpaceSE.MinimapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Local: TPoint;
begin
  if MinimapDragging then
    if (Integer(KeyState and MK_LBUTTON) = MK_LBUTTON) or ((KeyState and MK_RBUTTON) = MK_RBUTTON) then
    begin
      if Sender.IsOccludedAtPoint(Point) then Exit;
      if Screen = StarMapScreen then
        if StarMapScreen.CenterShipButton.HitTest(Point) then Exit;
      if Screen = FilmScreen then
        if FilmScreen.CenterShipButton.HitTest(Point) then Exit;
      Local := Sender.ToLocalPoint(Point);
      MapPanel.SetScrollOffset(Classes.Point(Round(Local.X / MinimapScale), Round(Local.Y / MinimapScale)));
      MapScrollChanged(nil);
      MinimapFrameCounter := 0;
    end;
end;
{ @end $83A9E8 }

{ @routine $83AAF4 TSpaceSE_ContainsMapPoint }
function TSpaceSE.ContainsMapPoint(Point: TPointF): Boolean;
begin
  if MapPanel = nil then Result := False
  else Result := MapPanel.ContainsPoint(MapPanel.ToAbsolutePoint(TruncatePointF(Point)));
end;
{ @end $83AAF4 }

end.
