unit aEFilm;

interface

uses Classes, EC_Buf, EC_Str, EC_Struct, SE_Process, SE_Space, Types, aEObjInfo;

const
  // Native serialized tags. Kind remains Byte so unknown values stay representable.
  efcSetObjectPosition = 0;
  efcSetObjectOrbitCenter = 1;
  efcSetObjectAlpha = 2;
  efcSetObjectAngle = 3;
  efcAdvanceObject = 4; // No known writer; playback calls TObjectSE.Advance.
  efcAdvanceObjects = 5;
  efcSetPlanetState = 6;
  efcSetShipSizeAndTailMode = 7;
  efcSetWeaponHit = 8;
  efcSetWeaponEndpoints = 9;
  efcSetDestructionEffect = 10;
  efcAttachObject = 11;
  efcDetachObject = 12;
  efcReleaseObject = 13;
  efcReleaseWeaponEffects = 14;
  efcSetViewCenter = 15;
  efcSetRadarCenter = 16;
  efcSetCameraAnchor = 17;
  efcOpenGate = 18;
  efcCloseGate = 19;
  efcSetGateState = 20;
  efcSetHoleState = 21;
  efcSetObjectText = 22;
  efcSetObjectStateBuffer = 23;
  efcBeginTrailingEffects = 24; // Playback barrier; ExecuteCommand has no action for this tag.
  efcPlayPickupSound = 25;
  efcSetRuinsState = 26;
  efcSetGateSize = 27;
  efcPlayObjectSound = 28;
  efcSetGateEffectSize = 29;
  efcSetEffectImagePosition = 30;
  efcSetEffectDurationScale = 31;

  FilmNullObjectIndex = 65535; // Serialized nil; -1 separately means an unlisted object.

type
  TEFilmObj = class(TObject) // @size 0x1C
  public
    Prev: TEFilmObj; // @offset 0x04
    Next: TEFilmObj; // @offset 0x08
    ObjectId: Cardinal; // @offset 0x0C
    SceneObject: TObjectSE; // @offset 0x10  Retained reference; nil after deserialization.
    KindName: WideString; // @offset 0x14
    GraphKey: WideString; // @offset 0x18
  end;

  PEFilmCommand = ^TEFilmCommand;
  TEFilmCommand = record // @size 0x20
    Prev: PEFilmCommand; // @offset 0x00
    Next: PEFilmCommand; // @offset 0x04
    Kind: Byte; // @offset 0x08  efc* tag; payload is interpreted through the command views below.
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10 Unused by commands without an object.
    Payload: array[0..11] of Byte; // @offset 0x14
  end;

  PEFilmObjectCommand = ^TEFilmObjectCommand;
  TEFilmObjectCommand = record // @size 0x20 Scalar object-command payload view.
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Value: Integer; // @offset 0x14
    ExtraValue: Integer; // @offset 0x18
    Flags: Integer; // @offset 0x1C
  end;

  PEFilmVectorCommand = ^TEFilmVectorCommand;
  TEFilmVectorCommand = record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Position: TPointF; // @offset 0x14
    ForceMovement: Boolean; // @offset 0x1C
  end;

  PEFilmSizeCommand = ^TEFilmSizeCommand;
  TEFilmSizeCommand = record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Size: TPoint; // @offset 0x14
    TailMode: Integer; // @offset 0x1C
  end;

  PEFilmByteCommand = ^TEFilmByteCommand;
  TEFilmByteCommand = record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Value: Byte; // @offset 0x14
  end;

  PEFilmHitCommand = ^TEFilmHitCommand;
  TEFilmHitCommand = record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Color: Word; // @offset 0x14
    Damage: Integer; // @offset 0x18
    Destroyed: Boolean; // @offset 0x1C
    PlaySound: Boolean; // @offset 0x1D
  end;

  PEFilmEndpointsCommand = ^TEFilmEndpointsCommand;
  TEFilmEndpointsCommand = record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Source: TEFilmObj; // @offset 0x14
    Target: TEFilmObj; // @offset 0x18
  end;

  TEFilmCameraEvent = record // @size 0x18
    StepIndex: Integer; // @offset 0x00
    Priority: Integer; // @offset 0x04
    StartPosition: TPointF; // @offset 0x08
    EndPosition: TPointF; // @offset 0x10
  end;

  TEFilmCameraEvents = array of TEFilmCameraEvent;

  TEFilm = class(TObjectEx) // @size 0x60
  public
    FirstObject: TEFilmObj; // @offset 0x04
    LastObject: TEFilmObj; // @offset 0x08
    FirstCommand: PEFilmCommand; // @offset 0x0C
    LastCommand: PEFilmCommand; // @offset 0x10
    FirstFreeCommand: PEFilmCommand; // @offset 0x14
    LastFreeCommand: PEFilmCommand; // @offset 0x18
    CameraEvents: array of TEFilmCameraEvent; // @offset 0x1C
    CameraEventCount: Integer; // @offset 0x20
    StringTable: TStringsEC; // @offset 0x24
    DataBuffers: TList; // @offset 0x28  Owned TBufEC entries.
    SystemProcessName: WideString; // @offset 0x2C
    MapDiameter: Integer; // @offset 0x30
    RadarRange: Integer; // @offset 0x34
    Turn: Integer; // @offset 0x38  Stored by TFilmFile, outside this film's serialized payload.
    PlayerCombatRecorded: Boolean; // @offset 0x3C  Set from RecordFilm and the star player-combat flag.
    BackgroundImage: Integer; // @offset 0x40
    StarGenerationSeed: Cardinal; // @offset 0x44
    InitialActivity: Cardinal; // @offset 0x48  Activity categories used to select film playback speed.
    FinalActivity: Cardinal; // @offset 0x4C
    CameraAnchor: TPointF; // @offset 0x50
    ForceCameraMovement: Boolean; // @offset 0x58
    ObjectInfo: TObject; // @offset 0x5C Native callers cast this snapshot to TEObjInfo.

    constructor Create; // @addr 0x00783154
    destructor Destroy; override; // @addr 0x007831B8
    procedure Clear; // @addr 0x0078324C
    procedure ReserveCameraEventSlot; // @addr $7832B4 Grows capacity and advances the used count without writing the new slot.
    procedure RemoveObject(Obj: TEFilmObj); // @addr $7834EC
    function ObjectCount: Integer; // @addr $783530
    function FindObjectIndex(Obj: TEFilmObj): Integer; // @addr $7835AC Nil maps to 65535; an absent non-nil object maps to -1.
    procedure GrowCommandPool(Count: Integer); // @addr $7836DC
    procedure RecycleCommands(First, Last: PEFilmCommand); // @addr $783720 Moves an inclusive linked range to the free list.
    procedure AppendCommand(Command: PEFilmCommand); // @addr $783774
    procedure InsertCommand(Before, Command: PEFilmCommand); // @addr $783798 Nil Before appends.
    function AddCommand(StepIndex: Integer): PEFilmCommand; // @addr $783814 Stable insertion by step index.
    function CommandCount: Integer; // @addr $783878
    function AllocateObject: TEFilmObj; // @addr 0x00783368 @note "Appends an object owned by this film."
    function ObjToNom(Obj: TEFilmObj): Integer; // @addr 0x00783544 @note "Zero-based list index; nil maps to 65535. Raises for an object outside this film."
    function NomToObj(Index: Integer): TEFilmObj; // @addr 0x007835D8 @note "Returns a borrowed object. Index 65535 maps to nil; other missing indexes raise."
    function FindObject(const KindName, GraphKey: WideString; ObjectId: Cardinal): TEFilmObj; // @addr 0x00783658 @note "Matches all three keys; returns a borrowed object or nil."
    function FindObjectById(const KindName: WideString; ObjectId: Cardinal): TEFilmObj; // @addr $7836A8
    function AllocateCommand: PEFilmCommand; // @addr 0x007837DC @note "Returns a zeroed pooled command without linking it into the command list."
    function AddObject(ObjectId: Cardinal; SceneObject: TObjectSE; Unused1: Integer = 0; Unused2: Integer = 0): TEFilmObj; // @addr 0x0078388C @note "Retains SceneObject and copies its class name and graph key. Both stack arguments are unused."
    function ContainsObject(Obj: TEFilmObj): Boolean; // @addr 0x0078363C
    procedure AddCameraEvent(AStepIndex: Integer; AStartPosition, AEndPosition: TPointF; APriority: Integer); // @addr 0x007832E8
    procedure SetObjectPosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF); // @addr 0x00783904
    procedure SetObjectAlpha(StepIndex: Integer; Obj: TEFilmObj; Alpha: Byte); // @addr 0x00783998
    procedure SetObjectAngle(StepIndex: Integer; Obj: TEFilmObj; Angle: Byte); // @addr 0x007839E0 @note "A full turn is 256 angle units."
    procedure AdvanceObjects(StepIndex: Integer); // @addr 0x00783A28 @note "Queues slot 0x40 on each retained scene object."
    procedure SetWeaponHit(StepIndex: Integer; Obj: TEFilmObj; AColor: Word; ADamage: Integer; ADestroyed, APlaySound: Boolean); // @addr 0x00783B44
    procedure SetWeaponEndpoints(StepIndex: Integer; Obj, ASource, ATarget: TEFilmObj); // @addr 0x00783BA4 @note "Source and Target may be nil; Obj must exist."
    procedure SetDestructionEffect(StepIndex: Integer; Obj: TEFilmObj; Value: Integer); // @addr 0x00783BF4 @note "Playback selects TWeaponSE destruction effects: 1=bomb, 2=asteroid, 5=kamikaze; other modes include fades and immediate removal."
    procedure AttachObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x00783C68
    procedure DetachObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x00783CA4
    procedure ReleaseObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x00783CE0 @note "Playback detaches and releases the scene reference, retaining the film entry."
    procedure ReleaseWeaponEffects(StepIndex: Integer); // @addr 0x00783CF4
    procedure CloseGate(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x00783D98 @note "Playback changes gate state 2 to 3 and resets its timer."
    procedure SetGateState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr 0x00783DAC
    procedure SetGateSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer); // @addr 0x00783DCC
    procedure SetHoleState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr 0x00783E0C
    procedure SetObjectText(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString); // @addr 0x00783E2C
    procedure BeginTrailingEffects(StepIndex: Integer); // @addr 0x00783ED4 @note "Appends the kind-24 boundary consumed by film playback."

    procedure SetObjectOrbitCenter(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF); // @addr $783964
    procedure SetPlanetState(StepIndex: Integer; Obj: TEFilmObj; RotationInterval, SurfaceMapStep: Integer; ScaleThousandths: Word; RingKind, Owner: Byte); // @addr $783A34 Scale is decoded as a signed 16-bit value divided by 1000 during playback.
    procedure SetShipSizeAndTailMode(StepIndex: Integer; Obj: TEFilmObj; ASize: TPoint; ATailMode: Integer); // @addr $783A98
    procedure SetRuinsState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr $783AFC
    procedure SetEffectImagePosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPoint); // @addr $783C14
    procedure SetEffectDurationScale(StepIndex: Integer; Obj: TEFilmObj; Scale: Single); // @addr $783C48 @note "Records the Single duration multiplier consumed by TGAIEffectSE.SetDurationScale."
    procedure SetGateEffectSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer); // @addr $783DEC
    procedure OpenGate(StepIndex: Integer; Obj: TEFilmObj); // @addr $783D84
    procedure PlayPickupSound(StepIndex: Integer; Obj: TEFilmObj); // @addr $783EE0
    procedure SetViewCenter(StepIndex: Integer; Position: TPointF); // @addr $783D00
    procedure SetRadarCenter(StepIndex: Integer; Position: TPointF); // @addr $783D28
    procedure SetCameraAnchor(StepIndex: Integer; APosition: TPointF; AForceMovement: Boolean); // @addr $783D50
    procedure PlayObjectSound(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString); // @addr $783E64
    procedure SetObjectStateBuffer(StepIndex: Integer; Obj: TEFilmObj; Buffer: TBufEC); // @addr $783E9C Transfers ownership of Buffer to the film.

    procedure ExecuteCommand(Process: TProcessSE; Command: PEFilmCommand; ReplayMode: Boolean); // @addr 0x00783EF4
    procedure ReleaseWeaponSceneObjects; // @addr $784C30 Detaches weapon effects and releases their retained scene references.
    procedure ReleaseObjectReferences(Obj: TObjectSE); // @addr $784C6C
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x00784CAC @note "Clears Buffer. Serializes object identities and commands, excluding live scene references and Turn."
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x0078542C @note "Clears the film and rewinds Buffer before reading. Scene objects are recreated separately."
  end;

const
  FilmFormatVersion: Integer = 6; // @addr $8101B8 Native writer format, read from initialized storage.

implementation

uses SysUtils, EC_Mem, GR_Main, GR_DX, GR_GraphBuf, SE_Weapon, SE_Planet, SE_Ship2, SE_Ruins, SE_Gate, SE_Hole, SE_GAIEffect,
  Globals, GlobalsV, aPlayer, aMyFunction, fFilm, fStarMap;

{ @routine $783154 TEFilm_Create }
constructor TEFilm.Create;
begin
  inherited Create;
  StringTable := TStringsEC.Create;
  DataBuffers := TList.Create;
  ObjectInfo := TEObjInfo.Create;
end;
{ @end $783154 }

{ @routine $7831B8 TEFilm_Destroy }
destructor TEFilm.Destroy;
var NextCommand, Command: PEFilmCommand;
begin
  Clear;
  NextCommand := FirstFreeCommand;
  while NextCommand <> nil do
  begin
    Command := NextCommand;
    NextCommand := NextCommand.Next;
    FreeEC(Command);
  end;
  FirstFreeCommand := nil;
  LastFreeCommand := nil;
  if StringTable <> nil then
  begin
    StringTable.Free;
    StringTable := nil;
  end;
  if DataBuffers <> nil then
  begin
    DataBuffers.Free;
    DataBuffers := nil;
  end;
  if ObjectInfo <> nil then
  begin
    ObjectInfo.Free;
    ObjectInfo := nil;
  end;
  CameraEvents := nil;
  inherited Destroy;
end;
{ @end $7831B8 }

{ @routine $78324C TEFilm_Clear }
procedure TEFilm.Clear;
var I, Count: Integer; Obj: TObject;
begin
  if FirstCommand <> nil then RecycleCommands(FirstCommand, LastCommand);
  while FirstObject <> nil do RemoveObject(LastObject);
  StringTable.Clear;
  Count := DataBuffers.Count;
  for I := 0 to Count - 1 do
  begin
    Obj := DataBuffers[I];
    Obj.Free;
  end;
  DataBuffers.Clear;
  CameraEventCount := 0;
end;
{ @end $78324C }

{ @routine $7832B4 TEFilm_ReserveCameraEventSlot }
procedure TEFilm.ReserveCameraEventSlot;
begin
  if CameraEventCount >= High(CameraEvents) then SetLength(CameraEvents, CameraEventCount + 30);
  Inc(CameraEventCount);
end;
{ @end $7832B4 }

{ @routine $7832E8 TEFilm_AddCameraEvent }
procedure TEFilm.AddCameraEvent(AStepIndex: Integer; AStartPosition, AEndPosition: TPointF; APriority: Integer);
begin
  if CameraEventCount >= High(CameraEvents) then SetLength(CameraEvents, CameraEventCount + 30);
  with CameraEvents[CameraEventCount] do
  begin
    StepIndex := AStepIndex;
    Priority := APriority;
    StartPosition := AStartPosition;
    EndPosition := AEndPosition;
  end;
  Inc(CameraEventCount);
end;
{ @end $7832E8 }

{ @routine $783368 TEFilm_AllocateObject }
function TEFilm.AllocateObject: TEFilmObj;
var Obj: TEFilmObj;
begin
  try Obj := TEFilmObj.Create except Obj := nil end;
  if Obj = nil then
  begin
    AppendLogTextThreadSafe('Failed to allocate memory for film object, trying to free some textures... ');
    EvictTextureCaches(True);
    try Obj := TEFilmObj.Create except Obj := nil end;
    if Obj <> nil then AppendLogLineThreadSafe('success')
    else
    begin
      AppendLogLineThreadSafe('fail');
      raise Exception.Create('Error in TEFilm.ObjAlloc');
    end;
  end;
  if LastObject <> nil then LastObject.Next := Obj;
  Obj.Prev := LastObject;
  Obj.Next := nil;
  LastObject := Obj;
  if FirstObject = nil then FirstObject := Obj;
  Result := Obj;
end;
{ @end $783368 }

{ @routine $7834EC TEFilm_RemoveObject }
procedure TEFilm.RemoveObject(Obj: TEFilmObj);
begin
  if Obj.Prev <> nil then Obj.Prev.Next := Obj.Next;
  if Obj.Next <> nil then Obj.Next.Prev := Obj.Prev;
  if LastObject = Obj then LastObject := Obj.Prev;
  if FirstObject = Obj then FirstObject := Obj.Next;
  ReleaseSpaceObject(Obj.SceneObject);
  Obj.Free;
end;
{ @end $7834EC }

{ @routine $783530 TEFilm_ObjectCount }
function TEFilm.ObjectCount: Integer;
var Count: Integer; Entry: TEFilmObj;
begin
  Count := 0;
  Entry := FirstObject;
  while Entry <> nil do
  begin
    Inc(Count);
    Entry := Entry.Next;
  end;
  Result := Count;
end;
{ @end $783530 }

{ @routine $783544 TEFilm_ObjToNom }
function TEFilm.ObjToNom(Obj: TEFilmObj): Integer;
var Index: Integer; Entry: TEFilmObj;
begin
  if Obj = nil then
  begin
    Result := FilmNullObjectIndex;
    Exit;
  end;
  Index := 0;
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Entry = Obj then
    begin
      Result := Index;
      Exit;
    end;
    Inc(Index);
    Entry := Entry.Next;
  end;
  raise Exception.Create('Error in TEFilm.ObjToNom');
  Result := -1; // Retained after the native raise.
end;
{ @end $783544 }

{ @routine $7835AC TEFilm_FindObjectIndex }
function TEFilm.FindObjectIndex(Obj: TEFilmObj): Integer;
var Index: Integer; Entry: TEFilmObj;
begin
  if Obj = nil then
  begin
    Result := FilmNullObjectIndex;
    Exit;
  end;
  Index := 0;
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Entry = Obj then
    begin
      Result := Index;
      Exit;
    end;
    Inc(Index);
    Entry := Entry.Next;
  end;
  Result := -1;
end;
{ @end $7835AC }

{ @routine $7835D8 TEFilm_NomToObj }
function TEFilm.NomToObj(Index: Integer): TEFilmObj;
var Entry: TEFilmObj;
begin
  if Index = FilmNullObjectIndex then
  begin
    Result := nil;
    Exit;
  end;
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Index = 0 then
    begin
      Result := Entry;
      Exit;
    end;
    Dec(Index);
    Entry := Entry.Next;
  end;
  raise Exception.Create('Error in TEFilm.NomToObj');
  Result := nil; // Retained after the native raise.
end;
{ @end $7835D8 }

{ @routine $78363C TEFilm_ContainsObject }
function TEFilm.ContainsObject(Obj: TEFilmObj): Boolean;
var Entry: TEFilmObj;
begin
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Obj = Entry then
    begin
      Result := True;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  Result := False;
end;
{ @end $78363C }

{ @routine $783658 TEFilm_FindObject }
function TEFilm.FindObject(const KindName, GraphKey: WideString; ObjectId: Cardinal): TEFilmObj;
var Entry: TEFilmObj;
begin
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if (Entry.ObjectId = ObjectId) and (Entry.KindName = KindName) and (Entry.GraphKey = GraphKey) then
    begin
      Result := Entry;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  Result := nil;
end;
{ @end $783658 }

{ @routine $7836A8 TEFilm_FindObjectById }
function TEFilm.FindObjectById(const KindName: WideString; ObjectId: Cardinal): TEFilmObj;
var
  Entry: TEFilmObj;
begin
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if (Entry.ObjectId = ObjectId) and (Entry.KindName = KindName) then
    begin
      Result := Entry;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  Result := nil;
end;
{ @end $7836A8 }

{ @routine $7836DC TEFilm_GrowCommandPool }
procedure TEFilm.GrowCommandPool(Count: Integer);
var Command: PEFilmCommand;
begin
  while Count > 0 do
  begin
    Command := AllocEC(SizeOf(TEFilmCommand));
    if LastFreeCommand <> nil then LastFreeCommand.Next := Command;
    Command.Prev := LastFreeCommand;
    Command.Next := nil;
    LastFreeCommand := Command;
    if FirstFreeCommand = nil then FirstFreeCommand := Command;
    Dec(Count);
  end;
end;
{ @end $7836DC }

{ @routine $783720 TEFilm_RecycleCommands }
procedure TEFilm.RecycleCommands(First, Last: PEFilmCommand);
begin
  if First.Prev <> nil then First.Prev.Next := Last.Next;
  if Last.Next <> nil then Last.Next.Prev := First.Prev;
  if Last = LastCommand then LastCommand := First.Prev;
  if First = FirstCommand then FirstCommand := Last.Next;
  if LastFreeCommand <> nil then LastFreeCommand.Next := First;
  First.Prev := LastFreeCommand;
  Last.Next := nil;
  LastFreeCommand := Last;
  if FirstFreeCommand = nil then FirstFreeCommand := First;
end;
{ @end $783720 }

{ @routine $783774 TEFilm_AppendCommand }
procedure TEFilm.AppendCommand(Command: PEFilmCommand);
begin
  if LastCommand <> nil then LastCommand.Next := Command;
  Command.Prev := LastCommand;
  Command.Next := nil;
  LastCommand := Command;
  if FirstCommand = nil then FirstCommand := Command;
end;
{ @end $783774 }

{ @routine $783798 TEFilm_InsertCommand }
procedure TEFilm.InsertCommand(Before, Command: PEFilmCommand);
begin
  if Before <> nil then
  begin
    Command.Prev := Before.Prev;
    Command.Next := Before;
    if Before.Prev <> nil then Before.Prev.Next := Command;
    Before.Prev := Command;
    if Before = FirstCommand then FirstCommand := Command;
  end
  else
  begin
    if LastCommand <> nil then LastCommand.Next := Command;
    Command.Prev := LastCommand;
    Command.Next := nil;
    LastCommand := Command;
    if FirstCommand = nil then FirstCommand := Command;
  end;
end;
{ @end $783798 }

{ @routine $7837DC TEFilm_AllocateCommand }
function TEFilm.AllocateCommand: PEFilmCommand;
var Command: PEFilmCommand;
begin
  if FirstFreeCommand = LastFreeCommand then GrowCommandPool(500);
  Command := FirstFreeCommand;
  Command.Next.Prev := nil;
  FirstFreeCommand := Command.Next;
  FillChar(Command^, SizeOf(TEFilmCommand), 0);
  Result := Command;
end;
{ @end $7837DC }

{ @routine $783814 TEFilm_AddCommand }
function TEFilm.AddCommand(StepIndex: Integer): PEFilmCommand;
var Command, Entry: PEFilmCommand;
begin
  Command := AllocateCommand;
  Command.StepIndex := StepIndex;
  if (LastCommand = nil) or (LastCommand.StepIndex <= StepIndex) then
  begin
    AppendCommand(Command);
    Result := Command;
  end
  else
  begin
    Entry := FirstCommand;
    while Entry <> nil do
    begin
      if Entry.StepIndex > StepIndex then
      begin
        InsertCommand(Entry, Command);
        Break;
      end;
      Entry := Entry.Next;
    end;
    if Entry = nil then AppendCommand(Command);
    Result := Command;
  end;
end;
{ @end $783814 }

{ @routine $783878 TEFilm_CommandCount }
function TEFilm.CommandCount: Integer;
var Count: Integer; Entry: PEFilmCommand;
begin
  Count := 0;
  Entry := FirstCommand;
  while Entry <> nil do
  begin
    Inc(Count);
    Entry := Entry.Next;
  end;
  Result := Count;
end;
{ @end $783878 }

{ @routine $78388C TEFilm_AddObject }
function TEFilm.AddObject(ObjectId: Cardinal; SceneObject: TObjectSE; Unused1, Unused2: Integer): TEFilmObj;
var Obj: TEFilmObj;
begin
  Obj := AllocateObject;
  Obj.ObjectId := ObjectId;
  RetainSpaceObject(Obj.SceneObject, SceneObject);
  Obj.KindName := ClassSEtoName(SceneObject);
  Obj.GraphKey := SceneObject.GraphKey;
  Result := Obj;
end;
{ @end $78388C }

{ @routine $783904 TEFilm_SetObjectPosition }
procedure TEFilm.SetObjectPosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetObjectPosition;
  Command.Obj := Obj;
  PEFilmVectorCommand(Command).Position := Position;
end;
{ @end $783904 }

{ @routine $783964 TEFilm_SetObjectOrbitCenter }
procedure TEFilm.SetObjectOrbitCenter(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetObjectOrbitCenter;
  Command.Obj := Obj;
  PEFilmVectorCommand(Command).Position := Position;
end;
{ @end $783964 }

{ @routine $783998 TEFilm_SetObjectAlpha }
procedure TEFilm.SetObjectAlpha(StepIndex: Integer; Obj: TEFilmObj; Alpha: Byte);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetObjectAlpha;
  Command.Obj := Obj;
  PEFilmByteCommand(Command).Value := Alpha;
end;
{ @end $783998 }

{ @routine $7839E0 TEFilm_SetObjectAngle }
procedure TEFilm.SetObjectAngle(StepIndex: Integer; Obj: TEFilmObj; Angle: Byte);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetObjectAngle;
  Command.Obj := Obj;
  PEFilmByteCommand(Command).Value := Angle;
end;
{ @end $7839E0 }

{ @routine $783A28 TEFilm_AdvanceObjects }
procedure TEFilm.AdvanceObjects(StepIndex: Integer);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcAdvanceObjects;
end;
{ @end $783A28 }

{ @routine $783A34 TEFilm_SetPlanetState }
procedure TEFilm.SetPlanetState(StepIndex: Integer; Obj: TEFilmObj; RotationInterval, SurfaceMapStep: Integer; ScaleThousandths: Word; RingKind, Owner: Byte);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetPlanetState;
  Command.Obj := Obj;
  with PEFilmObjectCommand(Command)^ do
  begin
    Value := (Integer(RingKind) shl 24) or RotationInterval;
    ExtraValue := SurfaceMapStep;
    Flags := ScaleThousandths or (Integer(Owner) shl 24);
  end;
end;
{ @end $783A34 }

{ @routine $783A98 TEFilm_SetShipSizeAndTailMode }
procedure TEFilm.SetShipSizeAndTailMode(StepIndex: Integer; Obj: TEFilmObj; ASize: TPoint; ATailMode: Integer);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetShipSizeAndTailMode;
  Command.Obj := Obj;
  with PEFilmSizeCommand(Command)^ do
  begin
    Size := ASize;
    TailMode := ATailMode;
  end;
end;
{ @end $783A98 }

{ @routine $783AFC TEFilm_SetRuinsState }
procedure TEFilm.SetRuinsState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetRuinsState;
  Command.Obj := Obj;
  PEFilmObjectCommand(Command).Value := State;
end;
{ @end $783AFC }

{ @routine $783B44 TEFilm_SetWeaponHit }
procedure TEFilm.SetWeaponHit(StepIndex: Integer; Obj: TEFilmObj; AColor: Word; ADamage: Integer; ADestroyed, APlaySound: Boolean);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetWeaponHit;
  Command.Obj := Obj;
  with PEFilmHitCommand(Command)^ do
  begin
    Color := AColor;
    Damage := ADamage;
    Destroyed := ADestroyed;
    PlaySound := APlaySound;
  end;
end;
{ @end $783B44 }

{ @routine $783BA4 TEFilm_SetWeaponEndpoints }
procedure TEFilm.SetWeaponEndpoints(StepIndex: Integer; Obj, ASource, ATarget: TEFilmObj);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetWeaponEndpoints;
  Command.Obj := Obj;
  with PEFilmEndpointsCommand(Command)^ do
  begin
    Source := ASource;
    Target := ATarget;
  end;
end;
{ @end $783BA4 }

{ @routine $783BF4 TEFilm_SetDestructionEffect }
procedure TEFilm.SetDestructionEffect(StepIndex: Integer; Obj: TEFilmObj; Value: Integer);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetDestructionEffect;
  Command.Obj := Obj;
  PEFilmObjectCommand(Command).Value := Value;
end;
{ @end $783BF4 }

{ @routine $783C14 TEFilm_SetEffectImagePosition }
procedure TEFilm.SetEffectImagePosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPoint);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetEffectImagePosition;
  Command.Obj := Obj;
  PEFilmSizeCommand(Command).Size := Position;
end;
{ @end $783C14 }

{ @routine $783C48 TEFilm_SetEffectDurationScale }
procedure TEFilm.SetEffectDurationScale(StepIndex: Integer; Obj: TEFilmObj; Scale: Single);
var Command: PEFilmCommand; ScaleBits: Integer absolute Scale;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetEffectDurationScale;
  Command.Obj := Obj;
  // Copy the Single payload without floating-point conversion or rounding.
  PEFilmObjectCommand(Command).Value := ScaleBits;
end;
{ @end $783C48 }

{ @routine $783C68 TEFilm_AttachObject }
procedure TEFilm.AttachObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcAttachObject;
  Command.Obj := Obj;
end;
{ @end $783C68 }

{ @routine $783CA4 TEFilm_DetachObject }
procedure TEFilm.DetachObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := AddCommand(StepIndex);
  Command.Kind := efcDetachObject;
  Command.Obj := Obj;
end;
{ @end $783CA4 }

{ @routine $783CE0 TEFilm_ReleaseObject }
procedure TEFilm.ReleaseObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcReleaseObject;
  Command.Obj := Obj;
end;
{ @end $783CE0 }

{ @routine $783CF4 TEFilm_ReleaseWeaponEffects }
procedure TEFilm.ReleaseWeaponEffects(StepIndex: Integer);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcReleaseWeaponEffects;
end;
{ @end $783CF4 }

{ @routine $783D00 TEFilm_SetViewCenter }
procedure TEFilm.SetViewCenter(StepIndex: Integer; Position: TPointF);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetViewCenter;
  PEFilmVectorCommand(Command).Position := Position;
end;
{ @end $783D00 }

{ @routine $783D28 TEFilm_SetRadarCenter }
procedure TEFilm.SetRadarCenter(StepIndex: Integer; Position: TPointF);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetRadarCenter;
  PEFilmVectorCommand(Command).Position := Position;
end;
{ @end $783D28 }

{ @routine $783D50 TEFilm_SetCameraAnchor }
procedure TEFilm.SetCameraAnchor(StepIndex: Integer; APosition: TPointF; AForceMovement: Boolean);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetCameraAnchor;
  with PEFilmVectorCommand(Command)^ do
  begin
    Position := APosition;
    ForceMovement := AForceMovement;
  end;
end;
{ @end $783D50 }

{ @routine $783D84 TEFilm_OpenGate }
procedure TEFilm.OpenGate(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcOpenGate;
  Command.Obj := Obj;
end;
{ @end $783D84 }

{ @routine $783D98 TEFilm_CloseGate }
procedure TEFilm.CloseGate(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcCloseGate;
  Command.Obj := Obj;
end;
{ @end $783D98 }

{ @routine $783DAC TEFilm_SetGateState }
procedure TEFilm.SetGateState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetGateState;
  Command.Obj := Obj;
  PEFilmObjectCommand(Command).Value := State;
end;
{ @end $783DAC }

{ @routine $783DCC TEFilm_SetGateSize }
procedure TEFilm.SetGateSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetGateSize;
  Command.Obj := Obj;
  PEFilmObjectCommand(Command).Value := Size;
end;
{ @end $783DCC }

{ @routine $783DEC TEFilm_SetGateEffectSize }
procedure TEFilm.SetGateEffectSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetGateEffectSize;
  Command.Obj := Obj;
  PEFilmObjectCommand(Command).Value := Size;
end;
{ @end $783DEC }

{ @routine $783E0C TEFilm_SetHoleState }
procedure TEFilm.SetHoleState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetHoleState;
  Command.Obj := Obj;
  PEFilmObjectCommand(Command).Value := State;
end;
{ @end $783E0C }

{ @routine $783E2C TEFilm_SetObjectText }
procedure TEFilm.SetObjectText(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetObjectText;
  Command.Obj := Obj;
  StringTable.Add(Text);
  PEFilmObjectCommand(Command).Value := StringTable.Count - 1;
end;
{ @end $783E2C }

{ @routine $783E64 TEFilm_PlayObjectSound }
procedure TEFilm.PlayObjectSound(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcPlayObjectSound;
  Command.Obj := Obj;
  StringTable.Add(Text);
  PEFilmObjectCommand(Command).Value := StringTable.Count - 1;
end;
{ @end $783E64 }

{ @routine $783E9C TEFilm_SetObjectStateBuffer }
procedure TEFilm.SetObjectStateBuffer(StepIndex: Integer; Obj: TEFilmObj; Buffer: TBufEC);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcSetObjectStateBuffer;
  Command.Obj := Obj;
  DataBuffers.Add(Buffer);
  PEFilmObjectCommand(Command).Value := DataBuffers.Count - 1;
end;
{ @end $783E9C }

{ @routine $783ED4 TEFilm_BeginTrailingEffects }
procedure TEFilm.BeginTrailingEffects(StepIndex: Integer);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcBeginTrailingEffects;
end;
{ @end $783ED4 }

{ @routine $783EE0 TEFilm_PlayPickupSound }
procedure TEFilm.PlayPickupSound(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmCommand;
begin
  Command := AddCommand(StepIndex);
  Command.Kind := efcPlayPickupSound;
  Command.Obj := Obj;
end;
{ @end $783EE0 }

{ @routine $783EF4 TEFilm_ExecuteCommand }
procedure TEFilm.ExecuteCommand(Process: TProcessSE; Command: PEFilmCommand; ReplayMode: Boolean);
var
  Obj: TEFilmObj;
  Source, Target: TObjectSE;
  ErrorStep: Integer;
  Ship: TShip2SE;
  Ruins: TRuinsSE;
begin
  { Process is unused in the native routine; playback uses the global SpaceProcess. }
  ErrorStep := 0;
  try
    case Command.Kind of
      efcSetObjectPosition:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
          Command.Obj.SceneObject.Pos := TEFilmVectorCommand(Command^).Position;
      efcSetObjectOrbitCenter:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
          Command.Obj.SceneObject.OrbitCenter := TEFilmVectorCommand(Command^).Position;
      efcSetObjectAlpha:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
          Command.Obj.SceneObject.Alpha := TEFilmByteCommand(Command^).Value;
      efcSetObjectAngle:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
          Command.Obj.SceneObject.Angle := TEFilmByteCommand(Command^).Value;
      efcAdvanceObject:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
          Command.Obj.SceneObject.Advance;
      efcAdvanceObjects:
        begin
          Obj := Self.FirstObject;
          while Obj <> nil do
          begin
            if Obj.SceneObject <> nil then Obj.SceneObject.Advance;
            Obj := Obj.Next;
          end;
        end;
      efcSetPlanetState:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TPlanetSE) then
        begin
          (Command.Obj.SceneObject as TPlanetSE).SetRotationTimerInterval(TEFilmObjectCommand(Command^).Value and $FFFFFF);
          (Command.Obj.SceneObject as TPlanetSE).SetRingKind(TEFilmObjectCommand(Command^).Value shr 24);
          (Command.Obj.SceneObject as TPlanetSE).SetSurfaceMapStep(TEFilmObjectCommand(Command^).ExtraValue);
          (Command.Obj.SceneObject as TPlanetSE).OrbitalVelocity := SmallInt(TEFilmObjectCommand(Command^).Flags and $FFFF) / 1000;
          (Command.Obj.SceneObject as TPlanetSE).SetMinimapOwner(TEFilmObjectCommand(Command^).Flags shr 24);
          (Command.Obj.SceneObject as TPlanetSE).Civilized := (Command.Obj.SceneObject as TPlanetSE).MinimapOwner <> 6;
        end;
      efcSetShipSizeAndTailMode:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TShip2SE) then
        begin
          Ship := Command.Obj.SceneObject as TShip2SE;
          Ship.ObjectSize := TEFilmSizeCommand(Command^).Size;
          if (ShipTail = 2) or ((ShipTail = 1) and (GetPlayer <> nil) and (GetPlayer.Id = Command.Obj.ObjectId)) then
            Ship.SetTailMode(TEFilmSizeCommand(Command^).TailMode)
          else Ship.SetTailMode(0);
        end;
      efcSetRuinsState:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TRuinsSE) then
        begin
          Ruins := Command.Obj.SceneObject as TRuinsSE;
          Ruins.SetState(TEFilmObjectCommand(Command^).Value);
        end;
      efcSetWeaponHit:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TWeaponSE) then
          (Command.Obj.SceneObject as TWeaponSE).SetHit(TEFilmHitCommand(Command^).Color, TEFilmHitCommand(Command^).Damage, TEFilmHitCommand(Command^).Destroyed, TEFilmHitCommand(Command^).PlaySound);
      efcSetWeaponEndpoints:
        begin
          { Both endpoint scene-object tests are repeated in the native code. }
          Source := nil;
          if (TEFilmEndpointsCommand(Command^).Source <> nil) and
            (TEFilmEndpointsCommand(Command^).Source.SceneObject <> nil) and
            (TEFilmEndpointsCommand(Command^).Source.SceneObject <> nil) then
            Source := TEFilmEndpointsCommand(Command^).Source.SceneObject;
          Target := nil;
          if (TEFilmEndpointsCommand(Command^).Target <> nil) and
            (TEFilmEndpointsCommand(Command^).Target.SceneObject <> nil) and
            (TEFilmEndpointsCommand(Command^).Target.SceneObject <> nil) then
            Target := TEFilmEndpointsCommand(Command^).Target.SceneObject;
          if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TWeaponSE) then
            (Command.Obj.SceneObject as TWeaponSE).SetEndpoints(Source, Target);
        end;
      efcSetDestructionEffect:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TWeaponSE) then
          (Command.Obj.SceneObject as TWeaponSE).DestructionEffect := TEFilmObjectCommand(Command^).Value;
      efcSetEffectImagePosition:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TGAIEffectSE) then
          (Command.Obj.SceneObject as TGAIEffectSE).SetImagePosition(TEFilmSizeCommand(Command^).Size);
      efcSetEffectDurationScale:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TGAIEffectSE) then
          (Command.Obj.SceneObject as TGAIEffectSE).SetDurationScale(TEFilmVectorCommand(Command^).Position.X);
      efcAttachObject:
        begin
          ErrorStep := 1;
          if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
        begin
            ErrorStep := 2;
            if Command.Obj.SceneObject is TShip2SE then
          begin
              ErrorStep := 3;
              with Command.Obj.SceneObject as TShip2SE do
            begin
                ErrorStep := 4;
                if ((ShipTail <> 2) and ((ShipTail <> 1) or (GetPlayer = nil) or (GetPlayer.Id <> Command.Obj.ObjectId))) or
                  (TailMode <= 0) then SetTailMode(0);
              end;
            end;
            ErrorStep := 5;
            Command.Obj.SceneObject.AttachToSpace(SpaceProcess.Space);
          end;
        end;
      efcDetachObject:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
          Command.Obj.SceneObject.DetachFromSpace;
      efcReleaseObject:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
        begin
          Command.Obj.SceneObject.DetachFromSpace;
          ReleaseSpaceObject(Command.Obj.SceneObject);
        end;
      efcReleaseWeaponEffects:
        begin
          Obj := Self.FirstObject;
          while Obj <> nil do
          begin
            if (Obj.SceneObject <> nil) and (Obj.SceneObject is TWeaponSE) then
          begin
              Obj.SceneObject.DetachFromSpace;
              ReleaseSpaceObject(Obj.SceneObject);
            end;
            Obj := Obj.Next;
          end;
        end;
      efcSetViewCenter:
        if ReplayMode then FilmScreen.FollowViewOffset(TruncatePointF(TEFilmVectorCommand(Command^).Position))
        else StarMapScreen.SetMapCenter(TruncatePointF(TEFilmVectorCommand(Command^).Position));
      efcSetRadarCenter:
        begin
          if ReplayMode then FilmScreen.CameraTarget := TEFilmVectorCommand(Command^).Position;
          SpaceProcess.RadarCenter := TEFilmVectorCommand(Command^).Position;
        end;
      efcSetCameraAnchor:
        begin
          CameraAnchor := TEFilmVectorCommand(Command^).Position;
          ForceCameraMovement := TEFilmVectorCommand(Command^).ForceMovement;
        end;
      efcOpenGate:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TGateSE) then
          (Command.Obj.SceneObject as TGateSE).Open;
      efcCloseGate:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TGateSE) then
          (Command.Obj.SceneObject as TGateSE).Close;
      efcSetGateState:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TGateSE) then
          (Command.Obj.SceneObject as TGateSE).SetState(TGateState(TEFilmObjectCommand(Command^).Value));
      efcSetGateSize:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TGateSE) then
          (Command.Obj.SceneObject as TGateSE).SetSize(Classes.Point(TEFilmObjectCommand(Command^).Value, TEFilmObjectCommand(Command^).Value));
      efcSetGateEffectSize:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is TGateEffectSE) then
          (Command.Obj.SceneObject as TGateEffectSE).SetSize(Classes.Point(TEFilmObjectCommand(Command^).Value, TEFilmObjectCommand(Command^).Value));
      efcSetHoleState:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is THoleSE) then
          (Command.Obj.SceneObject as THoleSE).SetState(TEFilmObjectCommand(Command^).Value);
      efcSetObjectText:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
          Command.Obj.SceneObject.Text := StringTable.Strings[TEFilmObjectCommand(Command^).Value];
      efcPlayObjectSound:
        if FilmSoundEffectsEnabled and SoundInSpaceEnabled then
          if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
            if (Command.Obj.SceneObject.Space <> nil) and
              Command.Obj.SceneObject.Space.ContainsMapPoint(Command.Obj.SceneObject.Position) then
              SoundManager.PlaySound(StringTable.Strings[TEFilmObjectCommand(Command^).Value]);
      efcSetObjectStateBuffer:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) then
          Command.Obj.SceneObject.LoadStateBuffer(TBufEC(DataBuffers[TEFilmObjectCommand(Command^).Value]));
      efcPlayPickupSound:
        if (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and
          SoundInSpaceEnabled and SpaceProcess.Space.ContainsMapPoint(Command.Obj.SceneObject.Position) then
          SoundManager.PlaySound('Sound.Take');
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('Error in procedure TEFilm.RunOrder, order = ' + IntToStr(Command.Kind) + ', label = ' + IntToStr(ErrorStep));
      if Command.Obj <> nil then
      begin
        AppendLogLineThreadSafe(Command.Obj.KindName);
        AppendLogLineThreadSafe(Command.Obj.GraphKey);
        if Command.Obj.SceneObject <> nil then AppendLogLineThreadSafe(Command.Obj.SceneObject.GraphKey);
      end;
      raise Exception.Create('Error in procedure TEFilm.RunOrder, order = ' + IntToStr(Command.Kind) + ', label = ' + IntToStr(ErrorStep));
    end;
  end;
end;
{ @end $783EF4 }

{ @routine $784C30 TEFilm_ReleaseWeaponSceneObjects }
procedure TEFilm.ReleaseWeaponSceneObjects;
var
  Entry: TEFilmObj;
begin
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Entry.SceneObject <> nil then
      if Entry.SceneObject is TWeaponSE then
      begin
        Entry.SceneObject.DetachFromSpace;
        ReleaseSpaceObject(Entry.SceneObject);
      end;
    Entry := Entry.Next;
  end;
end;
{ @end $784C30 }

{ @routine $784C6C TEFilm_ReleaseObjectReferences }
procedure TEFilm.ReleaseObjectReferences(Obj: TObjectSE);
var Entry: TEFilmObj;
begin
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Entry.SceneObject <> nil then
      if Entry.SceneObject = Obj then
      begin
        ReleaseSpaceObject(Entry.SceneObject);
        Entry.ObjectId := 0;
        Entry.KindName := '';
        Entry.GraphKey := '';
      end;
    Entry := Entry.Next;
  end;
end;
{ @end $784C6C }

{ @routine $784CAC TEFilm_SaveToBuffer }
procedure TEFilm.SaveToBuffer(Buffer: TBufEC);
var
  Obj: TEFilmObj;
  Command: PEFilmCommand;
  I, Count: Integer;
  Data: TBufEC;
  ObjectIndex: Integer;
begin
  Buffer.Clear;
  Buffer.AddWideStringZ(SystemProcessName);
  Buffer.AddIntegerValue(MaxInt);
  Buffer.AddIntegerValue(FilmFormatVersion);
  Buffer.AddIntegerValue(MapDiameter);
  Buffer.AddIntegerValue(RadarRange);
  Buffer.AddBoolean(PlayerCombatRecorded);
  Buffer.AddDWord(StarGenerationSeed);
  Buffer.AddIntegerValue(BackgroundImage);
  Buffer.AddDWord(InitialActivity);
  Buffer.AddDWord(FinalActivity);
  Buffer.AddSingle(CameraAnchor.X);
  Buffer.AddSingle(CameraAnchor.Y);
  Count := StringTable.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do Buffer.AddWideStringZ(StringTable.Strings[I]);
  Count := DataBuffers.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Data := DataBuffers[I];
    Buffer.AddBuffer(Data);
  end;
  Buffer.AddWideChar(WideChar(ObjectCount));
  Obj := FirstObject;
  while Obj <> nil do
  begin
    Buffer.AddDWord(Obj.ObjectId);
    Buffer.AddWideStringZ(Obj.KindName);
    Buffer.AddWideStringZ(Obj.GraphKey);
    Obj := Obj.Next;
  end;
  Buffer.AddDWord(CommandCount);
  Command := FirstCommand;
  while Command <> nil do
  begin
    Buffer.AddAnsiChar(AnsiChar(Command.Kind));
    Buffer.AddWideChar(WideChar(Command.StepIndex));
    if Command.Kind = efcSetObjectPosition then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.Y);
    end
    else if Command.Kind = efcSetObjectOrbitCenter then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.Y);
    end
    else if Command.Kind = efcSetObjectAlpha then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddAnsiChar(AnsiChar(PEFilmByteCommand(Command).Value));
    end
    else if Command.Kind = efcSetObjectAngle then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddAnsiChar(AnsiChar(PEFilmByteCommand(Command).Value));
    end
    else if Command.Kind = efcAdvanceObject then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
    end
    else if Command.Kind = efcAdvanceObjects then
    begin
    end
    else if Command.Kind = efcSetPlanetState then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).ExtraValue);
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Flags);
    end
    else if Command.Kind = efcSetShipSizeAndTailMode then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddWideChar(WideChar(PEFilmSizeCommand(Command).Size.X));
      Buffer.AddWideChar(WideChar(PEFilmSizeCommand(Command).Size.Y));
      Buffer.AddAnsiChar(AnsiChar(PEFilmSizeCommand(Command).TailMode));
    end
    else if Command.Kind = efcSetRuinsState then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddAnsiChar(AnsiChar(PEFilmObjectCommand(Command).Value));
    end
    else if Command.Kind = efcSetWeaponHit then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddAnsiChar(AnsiChar(CurrentPixelFormat.UnpackRed(PEFilmHitCommand(Command).Color)));
      Buffer.AddAnsiChar(AnsiChar(CurrentPixelFormat.UnpackGreen(PEFilmHitCommand(Command).Color)));
      Buffer.AddAnsiChar(AnsiChar(CurrentPixelFormat.UnpackBlue(PEFilmHitCommand(Command).Color)));
      Buffer.AddIntegerValue(PEFilmHitCommand(Command).Damage);
      Buffer.AddBoolean(PEFilmHitCommand(Command).Destroyed);
      Buffer.AddBoolean(PEFilmHitCommand(Command).PlaySound);
    end
    else if Command.Kind = efcSetWeaponEndpoints then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      ObjectIndex := FindObjectIndex(PEFilmEndpointsCommand(Command).Source);
      if ObjectIndex = -1 then
      begin
        ObjectIndex := FilmNullObjectIndex;
        PEFilmEndpointsCommand(Command).Source := nil;
      end;
      Buffer.AddWideChar(WideChar(ObjectIndex));
      ObjectIndex := FindObjectIndex(PEFilmEndpointsCommand(Command).Target);
      if ObjectIndex = -1 then
      begin
        ObjectIndex := FilmNullObjectIndex;
        PEFilmEndpointsCommand(Command).Target := nil;
      end;
      Buffer.AddWideChar(WideChar(ObjectIndex));
    end
    else if Command.Kind = efcSetDestructionEffect then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddAnsiChar(AnsiChar(PEFilmObjectCommand(Command).Value));
    end
    else if Command.Kind = efcSetEffectImagePosition then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddIntegerValue(PEFilmSizeCommand(Command).Size.X);
      Buffer.AddIntegerValue(PEFilmSizeCommand(Command).Size.Y);
    end
    else if Command.Kind = efcSetEffectDurationScale then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
    end
    else if Command.Kind = efcAttachObject then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
    end
    else if Command.Kind = efcDetachObject then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
    end
    else if Command.Kind = efcReleaseObject then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
    end
    else if Command.Kind = efcReleaseWeaponEffects then
    begin
    end
    else if Command.Kind = efcSetViewCenter then
    begin
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.Y);
    end
    else if Command.Kind = efcSetRadarCenter then
    begin
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.Y);
    end
    else if Command.Kind = efcSetCameraAnchor then
    begin
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.Y);
      Buffer.AddBoolean(PEFilmVectorCommand(Command).ForceMovement);
    end
    else if Command.Kind = efcOpenGate then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
    end
    else if Command.Kind = efcCloseGate then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
    end
    else if Command.Kind = efcSetGateState then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcSetGateSize then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcSetGateEffectSize then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcSetHoleState then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddBoolean(Boolean(PEFilmObjectCommand(Command).Value));
    end
    else if Command.Kind = efcSetObjectText then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcPlayObjectSound then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcSetObjectStateBuffer then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcBeginTrailingEffects then
    begin
    end
    else if Command.Kind = efcPlayPickupSound then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(Command.Obj)));
    end;
    Command := Command.Next;
  end;
  Buffer.AddIntegerValue(CameraEventCount);
  for I := 0 to CameraEventCount - 1 do
    with CameraEvents[I] do
    begin
      Buffer.AddIntegerValue(StepIndex);
      Buffer.AddIntegerValue(Priority);
      Buffer.AddSingle(StartPosition.X);
      Buffer.AddSingle(StartPosition.Y);
      Buffer.AddSingle(EndPosition.X);
      Buffer.AddSingle(EndPosition.Y);
    end;
  (ObjectInfo as TEObjInfo).SaveToBuffer(Buffer);
end;
{ @end $784CAC }

{ @routine $78542C TEFilm_LoadFromBuffer }
procedure TEFilm.LoadFromBuffer(Buffer: TBufEC);
var
  I, Count: Integer;
  Obj: TEFilmObj;
  Command: PEFilmCommand;
  Red, Green, Blue: Byte;
  Data: TBufEC;
  Version: Integer;
begin
  Version := 0;
  Clear;
  Buffer.SetPosition(0);
  SystemProcessName := Buffer.ReadWideString;
  MapDiameter := Buffer.GetInt32;
  if MapDiameter = MaxInt then
  begin
    Version := Buffer.GetInt32;
    MapDiameter := Buffer.GetInt32;
  end;
  RadarRange := Buffer.GetInt32;
  PlayerCombatRecorded := Buffer.GetBoolean;
  StarGenerationSeed := Buffer.GetUInt32;
  if Version >= 2 then BackgroundImage := Buffer.GetInt32
  else BackgroundImage := 0;
  InitialActivity := Buffer.GetUInt32;
  FinalActivity := Buffer.GetUInt32;
  CameraAnchor.X := Buffer.GetSingle;
  CameraAnchor.Y := Buffer.GetSingle;
  Count := Buffer.GetWord;
  for I := 0 to Count - 1 do StringTable.Add(Buffer.ReadWideString);
  Count := Buffer.GetWord;
  for I := 0 to Count - 1 do
  begin
    Data := TBufEC.Create;
    Buffer.ReadLengthPrefixedBuffer(Data);
    DataBuffers.Add(Data);
  end;
  Count := Buffer.GetWord;
  for I := 0 to Count - 1 do
  begin
    Obj := AllocateObject;
    Obj.ObjectId := Buffer.GetUInt32;
    Obj.KindName := Buffer.ReadWideString;
    Obj.GraphKey := Buffer.ReadWideString;
    Obj.SceneObject := nil;
  end;
  Count := Buffer.GetUInt32;
  for I := 0 to Count - 1 do
  begin
    Command := AllocateCommand;
    AppendCommand(Command);
    Command.Kind := Buffer.GetByte;
    Command.StepIndex := Buffer.GetWord;
    if Command.Kind = efcSetObjectPosition then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
      PEFilmVectorCommand(Command).Position.Y := Buffer.GetSingle;
    end
    else if Command.Kind = efcSetObjectOrbitCenter then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
      PEFilmVectorCommand(Command).Position.Y := Buffer.GetSingle;
    end
    else if Command.Kind = efcSetObjectAlpha then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmByteCommand(Command).Value := Buffer.GetByte;
    end
    else if Command.Kind = efcSetObjectAngle then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmByteCommand(Command).Value := Buffer.GetByte;
    end
    else if Command.Kind = efcAdvanceObject then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcAdvanceObjects then
    begin
    end
    else if Command.Kind = efcSetPlanetState then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
      PEFilmObjectCommand(Command).ExtraValue := Buffer.GetInt32;
      PEFilmObjectCommand(Command).Flags := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetShipSizeAndTailMode then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmSizeCommand(Command).Size.X := Buffer.GetWord;
      PEFilmSizeCommand(Command).Size.Y := Buffer.GetWord;
      PEFilmSizeCommand(Command).TailMode := Buffer.GetByte;
    end
    else if Command.Kind = efcSetRuinsState then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetByte;
    end
    else if Command.Kind = efcSetWeaponHit then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      Red := Buffer.GetByte;
      Green := Buffer.GetByte;
      Blue := Buffer.GetByte;
      PEFilmHitCommand(Command).Color := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
      PEFilmHitCommand(Command).Damage := Buffer.GetInt32;
      PEFilmHitCommand(Command).Destroyed := Buffer.GetBoolean;
      PEFilmHitCommand(Command).PlaySound := Buffer.GetBoolean;
    end
    else if Command.Kind = efcSetWeaponEndpoints then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmEndpointsCommand(Command).Source := NomToObj(Buffer.GetWord);
      PEFilmEndpointsCommand(Command).Target := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcSetDestructionEffect then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetByte;
    end
    else if Command.Kind = efcSetEffectImagePosition then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmSizeCommand(Command).Size.X := Buffer.GetInt32;
      PEFilmSizeCommand(Command).Size.Y := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetEffectDurationScale then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
    end
    else if Command.Kind = efcAttachObject then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcDetachObject then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcReleaseObject then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcReleaseWeaponEffects then
    begin
    end
    else if Command.Kind = efcSetViewCenter then
    begin
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
      PEFilmVectorCommand(Command).Position.Y := Buffer.GetSingle;
    end
    else if Command.Kind = efcSetRadarCenter then
    begin
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
      PEFilmVectorCommand(Command).Position.Y := Buffer.GetSingle;
    end
    else if Command.Kind = efcSetCameraAnchor then
    begin
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
      PEFilmVectorCommand(Command).Position.Y := Buffer.GetSingle;
      PEFilmVectorCommand(Command).ForceMovement := Buffer.GetBoolean;
    end
    else if Command.Kind = efcOpenGate then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcCloseGate then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcSetGateState then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetGateSize then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetGateEffectSize then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetHoleState then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Ord(Buffer.GetBoolean);
    end
    else if Command.Kind = efcSetObjectText then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcPlayObjectSound then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetObjectStateBuffer then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcBeginTrailingEffects then
    begin
    end
    else if Command.Kind = efcPlayPickupSound then
    begin
      Command.Obj := NomToObj(Buffer.GetWord);
    end;
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    ReserveCameraEventSlot;
    with CameraEvents[CameraEventCount - 1] do
    begin
      StepIndex := Buffer.GetInt32;
      Priority := Buffer.GetInt32;
      StartPosition.X := Buffer.GetSingle;
      StartPosition.Y := Buffer.GetSingle;
      EndPosition.X := Buffer.GetSingle;
      EndPosition.Y := Buffer.GetSingle;
    end;
  end;
  if Version > 0 then (ObjectInfo as TEObjInfo).LoadFromBuffer(Buffer, Version)
  else (ObjectInfo as TEObjInfo).Clear;
end;
{ @end $78542C }

end.
