unit aEFilm;
// Unit bracket (inferred): .text 0x0080CFDC..0x008109E0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Str, EC_Struct, SE_Process, SE_Space, Types, aEObjInfo;

const
  // Native serialized tags. Kind remains Byte so unknown values stay representable.
  efcSetObjectPosition = 0;
  efcSetObjectOrbitCenter = 1;
  efcSetObjectAlpha = 2;
  efcSetObjectAngle = 3;
  efcAdvanceObject = 4; // No recovered writer; playback at $80E80F calls TObjectSE.Advance.
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

  PEFilmCameraEvent = ^TEFilmCameraEvent;
  TEFilmCameraEvent = packed record // @size 0x18
    StepIndex: Integer; // @offset 0x00
    Priority: Integer; // @offset 0x04
    StartPosition: TPointF; // @offset 0x08
    EndPosition: TPointF; // @offset 0x10
  end;

  PEFilmCameraEventArray = ^TEFilmCameraEventArray;
  TEFilmCameraEventArray = array[0..0] of TEFilmCameraEvent;
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
    InitialActivity: Integer; // @offset 0x48  Activity categories used to select film playback speed.
    FinalActivity: Integer; // @offset 0x4C
    CameraAnchor: TPointF; // @offset 0x50
    ForceCameraMovement: Boolean; // @offset 0x58
    ObjectInfo: TObject; // @offset 0x5C Native callers cast this snapshot to TEObjInfo.

    constructor Create; // @addr 0x80D0DC
    destructor Destroy; override; // @addr 0x80D154
    procedure Clear; // @addr 0x80D230
    procedure ReserveCameraEventSlot; // @addr $80D2D4 Grows capacity and advances the used count without writing the new slot.
    procedure RemoveObject(Obj: TEFilmObj); // @addr $80D574
    function ObjectCount: Integer; // @addr $80D5F8
    function FindObjectIndex(Obj: TEFilmObj): Integer; // @addr $80D6D0 Nil maps to 65535; an absent non-nil object maps to -1.
    procedure GrowCommandPool(Count: Integer); // @addr $80D8D4
    procedure RecycleCommands(First, Last: PEFilmCommand); // @addr $80D944 Moves an inclusive linked range to the free list.
    procedure AppendCommand(Command: PEFilmCommand); // @addr $80D9F4
    procedure InsertCommand(Before, Command: PEFilmCommand); // @addr $80DA48 Nil Before appends.
    function AddCommand(StepIndex: Integer): PEFilmCommand; // @addr $80DB48 Stable insertion by step index.
    function CommandCount: Integer; // @addr $80DBEC
    function AllocateObject: TEFilmObj; // @addr 0x80D3C4 @note "Appends an object owned by this film."
    function ObjToNom(Obj: TEFilmObj): Integer; // @addr 0x80D634 @note "Zero-based list index; nil maps to 65535. Raises for an object outside this film."
    function NomToObj(Index: Integer): TEFilmObj; // @addr 0x80D730 @note "Returns a borrowed object. Index 65535 maps to nil; other missing indexes raise."
    function FindObject(const KindName, GraphKey: WideString; ObjectId: Cardinal): TEFilmObj; // @addr 0x80D808 @note "Matches all three keys; returns a borrowed object or nil."
    function FindObjectById(const KindName: WideString; ObjectId: Cardinal): TEFilmObj; // @addr $80D878
    function AllocateCommand: PEFilmCommand; // @addr 0x80DAE8 @note "Returns a zeroed pooled command without linking it into the command list."
    function AddObject(ObjectId: Cardinal; SceneObject: TObjectSE; Unused1: Integer = 0; Unused2: Integer = 0): TEFilmObj; // @addr 0x80DC28 @note "Retains SceneObject and copies its class name and graph key. Both stack arguments are unused."
    function ContainsObject(Obj: TEFilmObj): Boolean; // @addr 0x80D7C4
    procedure AddCameraEvent(AStepIndex: Integer; AStartPosition, AEndPosition: TPointF; APriority: Integer); // @addr 0x80D31C
    procedure SetObjectPosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF); // @addr 0x80DCC4
    procedure SetObjectAlpha(StepIndex: Integer; Obj: TEFilmObj; Alpha: Byte); // @addr 0x80DD90
    procedure SetObjectAngle(StepIndex: Integer; Obj: TEFilmObj; Angle: Byte); // @addr 0x80DDF8 @note "A full turn is 256 angle units."
    procedure AdvanceObjects(StepIndex: Integer); // @addr 0x80DE60 @note "Queues slot 0x40 on each retained scene object."
    procedure SetWeaponHit(StepIndex: Integer; Obj: TEFilmObj; Color: Word; Damage: Integer; Destroyed, PlaySound: Boolean); // @addr 0x80E004
    procedure SetWeaponEndpoints(StepIndex: Integer; Obj, Source, Target: TEFilmObj); // @addr 0x80E08C @note "Source and Target may be nil; Obj must exist."
    procedure SetDestructionEffect(StepIndex: Integer; Obj: TEFilmObj; Value: Integer); // @addr 0x80E100 @note "Playback selects TWeaponSE destruction effects: 1=bomb, 2=asteroid, 5=kamikaze; other modes include fades and immediate removal."
    procedure AttachObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x80E1C8
    procedure DetachObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x80E228
    procedure ReleaseObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x80E288 @note "Playback detaches and releases the scene reference, retaining the film entry."
    procedure ReleaseWeaponEffects(StepIndex: Integer); // @addr 0x80E2BC
    procedure CloseGate(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x80E3E4 @note "Playback changes gate state 2 to 3 and resets its timer."
    procedure SetGateState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr 0x80E418
    procedure SetGateSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer); // @addr 0x80E454
    procedure SetHoleState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr 0x80E4CC
    procedure SetObjectText(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString); // @addr 0x80E508
    procedure BeginTrailingEffects(StepIndex: Integer); // @addr 0x80E604 @note "Appends the kind-24 boundary consumed by film playback."

    procedure SetObjectOrbitCenter(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF); // @addr $80DD40
    procedure SetPlanetState(StepIndex: Integer; Obj: TEFilmObj; RotationInterval, SurfaceMapStep: Integer; ScaleThousandths: Word; RingKind, Owner: Byte); // @addr $80DE88 Scale is decoded as a signed 16-bit value divided by 1000 during playback.
    procedure SetShipSizeAndTailMode(StepIndex: Integer; Obj: TEFilmObj; Size: TPoint; TailMode: Integer); // @addr $80DF18
    procedure SetRuinsState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr $80DF9C
    procedure SetEffectImagePosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPoint); // @addr $80E13C
    procedure SetEffectDurationScale(StepIndex: Integer; Obj: TEFilmObj; Scale: Single); // @addr $80E18C @note "Records the Single duration multiplier consumed by TGAIEffectSE.SetDurationScale."
    procedure SetGateEffectSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer); // @addr $80E490
    procedure OpenGate(StepIndex: Integer; Obj: TEFilmObj); // @addr $80E3B0
    procedure PlayPickupSound(StepIndex: Integer; Obj: TEFilmObj); // @addr $80E62C
    procedure SetViewCenter(StepIndex: Integer; Position: TPointF); // @addr $80E2E4
    procedure SetRadarCenter(StepIndex: Integer; Position: TPointF); // @addr $80E324
    procedure SetCameraAnchor(StepIndex: Integer; Position: TPointF; ForceMovement: Boolean); // @addr $80E364
    procedure PlayObjectSound(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString); // @addr $80E55C
    procedure SetObjectStateBuffer(StepIndex: Integer; Obj: TEFilmObj; Buffer: TBufEC); // @addr $80E5B0 Transfers ownership of Buffer to the film.

    procedure ExecuteCommand(Process: TProcessSE; Command: PEFilmCommand; ReplayMode: Boolean); // @addr 0x80E660
    procedure ReleaseWeaponSceneObjects; // @addr $80F544 Detaches weapon effects and releases their retained scene references.
    procedure ReleaseObjectReferences(Obj: TObjectSE); // @addr $80F5A4
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x80F610 @note "Clears Buffer. Serializes object identities and commands, excluding live scene references and Turn."
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x80FFB8 @note "Clears the film and rewinds Buffer before reading. Scene objects are recreated separately."
  end;

const
  FilmFormatVersion: Integer = 6; // @addr $87CD74 Native writer format, read from initialized storage.

implementation

uses SysUtils, EC_Mem, GR_Main, GR_DX, GR_GraphBuf, SE_Weapon, SE_Planet, SE_Ship2, SE_Ruins, SE_Gate, SE_Hole, SE_GAIEffect,
  Globals, GlobalsV, aPlayer, aMyFunction, fFilm, fStarMap;

{ @routine $80D0DC TEFilm_Create }
constructor TEFilm.Create;
begin
  inherited Create;
  StringTable := TStringsEC.Create;
  DataBuffers := TList.Create;
  ObjectInfo := TEObjInfo.Create;
end;
{ @end $80D0DC }

{ @routine $80D154 TEFilm_Destroy }
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
  if StringTable <> nil then begin StringTable.Free; StringTable := nil end;
  if DataBuffers <> nil then begin DataBuffers.Free; DataBuffers := nil end;
  if ObjectInfo <> nil then begin ObjectInfo.Free; ObjectInfo := nil end;
  CameraEvents := nil;
  inherited Destroy;
end;
{ @end $80D154 }

{ @routine $80D230 TEFilm_Clear }
procedure TEFilm.Clear;
var I, Count: Integer; Obj: TObject;
begin
  if FirstCommand <> nil then RecycleCommands(FirstCommand, LastCommand);
  while FirstObject <> nil do RemoveObject(LastObject);
  StringTable.Clear;
  Count := DataBuffers.Count;
  for I := 0 to Count - 1 do
  begin
    Obj := TObject(DataBuffers[I]);
    Obj.Free;
  end;
  DataBuffers.Clear;
  CameraEventCount := 0;
end;
{ @end $80D230 }

{ @routine $80D2D4 TEFilm_ReserveCameraEventSlot }
procedure TEFilm.ReserveCameraEventSlot;
begin
  if High(CameraEvents) <= CameraEventCount then SetLength(CameraEvents, CameraEventCount + 30);
  Inc(CameraEventCount);
end;
{ @end $80D2D4 }

{ @routine $80D31C TEFilm_AddCameraEvent }
procedure TEFilm.AddCameraEvent(AStepIndex: Integer; AStartPosition, AEndPosition: TPointF; APriority: Integer);
begin
  if High(CameraEvents) <= CameraEventCount then SetLength(CameraEvents, CameraEventCount + 30);
  with CameraEvents[CameraEventCount] do
  begin
    StepIndex := AStepIndex;
    Priority := APriority;
    StartPosition := AStartPosition;
    EndPosition := AEndPosition;
  end;
  Inc(CameraEventCount);
end;
{ @end $80D31C }

{ @routine $80D3C4 TEFilm_AllocateObject }
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
{ @end $80D3C4 }

{ @routine $80D574 TEFilm_RemoveObject }
procedure TEFilm.RemoveObject(Obj: TEFilmObj);
begin
  if Obj.Prev <> nil then Obj.Prev.Next := Obj.Next;
  if Obj.Next <> nil then Obj.Next.Prev := Obj.Prev;
  if LastObject = Obj then LastObject := Obj.Prev;
  if FirstObject = Obj then FirstObject := Obj.Next;
  ReleaseSpaceObject(Obj.SceneObject);
  Obj.Free;
end;
{ @end $80D574 }

{ @routine $80D5F8 TEFilm_ObjectCount }
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
{ @end $80D5F8 }

{ @routine $80D634 TEFilm_ObjToNom }
function TEFilm.ObjToNom(Obj: TEFilmObj): Integer;
var Index: Integer; Entry: TEFilmObj;
begin
  if Obj = nil then begin Result := FilmNullObjectIndex; Exit end;
  Index := 0;
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Entry = Obj then begin Result := Index; Exit end;
    Inc(Index);
    Entry := Entry.Next;
  end;
  raise Exception.Create('Error in TEFilm.ObjToNom');
  Result := -1; // Retained after the native raise.
end;
{ @end $80D634 }

{ @routine $80D6D0 TEFilm_FindObjectIndex }
function TEFilm.FindObjectIndex(Obj: TEFilmObj): Integer;
var Index: Integer; Entry: TEFilmObj;
begin
  if Obj = nil then begin Result := FilmNullObjectIndex; Exit end;
  Index := 0;
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Entry = Obj then begin Result := Index; Exit end;
    Inc(Index);
    Entry := Entry.Next;
  end;
  Result := -1;
end;
{ @end $80D6D0 }

{ @routine $80D730 TEFilm_NomToObj }
function TEFilm.NomToObj(Index: Integer): TEFilmObj;
var Entry: TEFilmObj;
begin
  if Index = FilmNullObjectIndex then begin Result := nil; Exit end;
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Index = 0 then begin Result := Entry; Exit end;
    Dec(Index);
    Entry := Entry.Next;
  end;
  raise Exception.Create('Error in TEFilm.NomToObj');
  Result := nil; // Retained after the native raise.
end;
{ @end $80D730 }

{ @routine $80D7C4 TEFilm_ContainsObject }
function TEFilm.ContainsObject(Obj: TEFilmObj): Boolean;
var Entry: TEFilmObj;
begin
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if Obj = Entry then begin Result := True; Exit end;
    Entry := Entry.Next;
  end;
  Result := False;
end;
{ @end $80D7C4 }

{ @routine $80D808 TEFilm_FindObject }
function TEFilm.FindObject(const KindName, GraphKey: WideString; ObjectId: Cardinal): TEFilmObj;
var Entry: TEFilmObj;
begin
  Entry := FirstObject;
  while Entry <> nil do
  begin
    if (Entry.ObjectId = ObjectId) and (Entry.KindName = KindName) and (Entry.GraphKey = GraphKey) then
    begin Result := Entry; Exit end;
    Entry := Entry.Next;
  end;
  Result := nil;
end;
{ @end $80D808 }

{ @routine $80D878 TEFilm_FindObjectById }
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
{ @end $80D878 }

{ @routine $80D8D4 TEFilm_GrowCommandPool }
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
{ @end $80D8D4 }

{ @routine $80D944 TEFilm_RecycleCommands }
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
{ @end $80D944 }

{ @routine $80D9F4 TEFilm_AppendCommand }
procedure TEFilm.AppendCommand(Command: PEFilmCommand);
begin
  if LastCommand <> nil then LastCommand.Next := Command;
  Command.Prev := LastCommand;
  Command.Next := nil;
  LastCommand := Command;
  if FirstCommand = nil then FirstCommand := Command;
end;
{ @end $80D9F4 }

{ @routine $80DA48 TEFilm_InsertCommand }
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
{ @end $80DA48 }

{ @routine $80DAE8 TEFilm_AllocateCommand }
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
{ @end $80DAE8 }

{ @routine $80DB48 TEFilm_AddCommand }
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
{ @end $80DB48 }

{ @routine $80DBEC TEFilm_CommandCount }
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
{ @end $80DBEC }

{ @routine $80DC28 TEFilm_AddObject }
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
{ @end $80DC28 }

{ @routine $80DCC4 TEFilm_SetObjectPosition }
procedure TEFilm.SetObjectPosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF);
var Command: PEFilmVectorCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectPosition;
  Command.Obj := Obj;
  Command.Position := Position;
end;
{ @end $80DCC4 }

{ @routine $80DD40 TEFilm_SetObjectOrbitCenter }
procedure TEFilm.SetObjectOrbitCenter(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF);
var Command: PEFilmVectorCommand;
begin
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectOrbitCenter;
  Command.Obj := Obj;
  Command.Position := Position;
end;
{ @end $80DD40 }

{ @routine $80DD90 TEFilm_SetObjectAlpha }
procedure TEFilm.SetObjectAlpha(StepIndex: Integer; Obj: TEFilmObj; Alpha: Byte);
var Command: PEFilmByteCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmByteCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectAlpha;
  Command.Obj := Obj;
  Command.Value := Alpha;
end;
{ @end $80DD90 }

{ @routine $80DDF8 TEFilm_SetObjectAngle }
procedure TEFilm.SetObjectAngle(StepIndex: Integer; Obj: TEFilmObj; Angle: Byte);
var Command: PEFilmByteCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmByteCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectAngle;
  Command.Obj := Obj;
  Command.Value := Angle;
end;
{ @end $80DDF8 }

{ @routine $80DE60 TEFilm_AdvanceObjects }
procedure TEFilm.AdvanceObjects(StepIndex: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcAdvanceObjects;
end;
{ @end $80DE60 }

{ @routine $80DE88 TEFilm_SetPlanetState }
procedure TEFilm.SetPlanetState(StepIndex: Integer; Obj: TEFilmObj; RotationInterval, SurfaceMapStep: Integer; ScaleThousandths: Word; RingKind, Owner: Byte);
var Command: PEFilmObjectCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetPlanetState;
  Command.Obj := Obj;
  Command.Value := (Integer(RingKind) shl 24) or RotationInterval;
  Command.ExtraValue := SurfaceMapStep;
  Command.Flags := ScaleThousandths or (Integer(Owner) shl 24);
end;
{ @end $80DE88 }

{ @routine $80DF18 TEFilm_SetShipSizeAndTailMode }
procedure TEFilm.SetShipSizeAndTailMode(StepIndex: Integer; Obj: TEFilmObj; Size: TPoint; TailMode: Integer);
var Command: PEFilmSizeCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmSizeCommand(AddCommand(StepIndex));
  Command.Kind := efcSetShipSizeAndTailMode;
  Command.Obj := Obj;
  Command.Size := Size;
  Command.TailMode := TailMode;
end;
{ @end $80DF18 }

{ @routine $80DF9C TEFilm_SetRuinsState }
procedure TEFilm.SetRuinsState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmObjectCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetRuinsState;
  Command.Obj := Obj;
  Command.Value := State;
end;
{ @end $80DF9C }

{ @routine $80E004 TEFilm_SetWeaponHit }
procedure TEFilm.SetWeaponHit(StepIndex: Integer; Obj: TEFilmObj; Color: Word; Damage: Integer; Destroyed, PlaySound: Boolean);
var Command: PEFilmHitCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmHitCommand(AddCommand(StepIndex));
  Command.Kind := efcSetWeaponHit;
  Command.Obj := Obj;
  Command.Color := Color;
  Command.Damage := Damage;
  Command.Destroyed := Destroyed;
  Command.PlaySound := PlaySound;
end;
{ @end $80E004 }

{ @routine $80E08C TEFilm_SetWeaponEndpoints }
procedure TEFilm.SetWeaponEndpoints(StepIndex: Integer; Obj, Source, Target: TEFilmObj);
var Command: PEFilmEndpointsCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmEndpointsCommand(AddCommand(StepIndex));
  Command.Kind := efcSetWeaponEndpoints;
  Command.Obj := Obj;
  Command.Source := Source;
  Command.Target := Target;
end;
{ @end $80E08C }

{ @routine $80E100 TEFilm_SetDestructionEffect }
procedure TEFilm.SetDestructionEffect(StepIndex: Integer; Obj: TEFilmObj; Value: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetDestructionEffect;
  Command.Obj := Obj;
  Command.Value := Value;
end;
{ @end $80E100 }

{ @routine $80E13C TEFilm_SetEffectImagePosition }
procedure TEFilm.SetEffectImagePosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPoint);
var Command: PEFilmSizeCommand;
begin
  Command := PEFilmSizeCommand(AddCommand(StepIndex));
  Command.Kind := efcSetEffectImagePosition;
  Command.Obj := Obj;
  Command.Size := Position;
end;
{ @end $80E13C }

{ @routine $80E18C TEFilm_SetEffectDurationScale }
procedure TEFilm.SetEffectDurationScale(StepIndex: Integer; Obj: TEFilmObj; Scale: Single);
var Command: PEFilmObjectCommand; ScaleBits: Integer absolute Scale;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetEffectDurationScale;
  Command.Obj := Obj;
  // Copy the Single payload without floating-point conversion or rounding.
  Command.Value := ScaleBits;
end;
{ @end $80E18C }

{ @routine $80E1C8 TEFilm_AttachObject }
procedure TEFilm.AttachObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcAttachObject;
  Command.Obj := Obj;
end;
{ @end $80E1C8 }

{ @routine $80E228 TEFilm_DetachObject }
procedure TEFilm.DetachObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcDetachObject;
  Command.Obj := Obj;
end;
{ @end $80E228 }

{ @routine $80E288 TEFilm_ReleaseObject }
procedure TEFilm.ReleaseObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcReleaseObject;
  Command.Obj := Obj;
end;
{ @end $80E288 }

{ @routine $80E2BC TEFilm_ReleaseWeaponEffects }
procedure TEFilm.ReleaseWeaponEffects(StepIndex: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcReleaseWeaponEffects;
end;
{ @end $80E2BC }

{ @routine $80E2E4 TEFilm_SetViewCenter }
procedure TEFilm.SetViewCenter(StepIndex: Integer; Position: TPointF);
var Command: PEFilmVectorCommand;
begin
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetViewCenter;
  Command.Position := Position;
end;
{ @end $80E2E4 }

{ @routine $80E324 TEFilm_SetRadarCenter }
procedure TEFilm.SetRadarCenter(StepIndex: Integer; Position: TPointF);
var Command: PEFilmVectorCommand;
begin
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetRadarCenter;
  Command.Position := Position;
end;
{ @end $80E324 }

{ @routine $80E364 TEFilm_SetCameraAnchor }
procedure TEFilm.SetCameraAnchor(StepIndex: Integer; Position: TPointF; ForceMovement: Boolean);
var Command: PEFilmVectorCommand;
begin
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetCameraAnchor;
  Command.Position := Position;
  Command.ForceMovement := ForceMovement;
end;
{ @end $80E364 }

{ @routine $80E3B0 TEFilm_OpenGate }
procedure TEFilm.OpenGate(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcOpenGate;
  Command.Obj := Obj;
end;
{ @end $80E3B0 }

{ @routine $80E3E4 TEFilm_CloseGate }
procedure TEFilm.CloseGate(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcCloseGate;
  Command.Obj := Obj;
end;
{ @end $80E3E4 }

{ @routine $80E418 TEFilm_SetGateState }
procedure TEFilm.SetGateState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetGateState;
  Command.Obj := Obj;
  Command.Value := State;
end;
{ @end $80E418 }

{ @routine $80E454 TEFilm_SetGateSize }
procedure TEFilm.SetGateSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetGateSize;
  Command.Obj := Obj;
  Command.Value := Size;
end;
{ @end $80E454 }

{ @routine $80E490 TEFilm_SetGateEffectSize }
procedure TEFilm.SetGateEffectSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetGateEffectSize;
  Command.Obj := Obj;
  Command.Value := Size;
end;
{ @end $80E490 }

{ @routine $80E4CC TEFilm_SetHoleState }
procedure TEFilm.SetHoleState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetHoleState;
  Command.Obj := Obj;
  Command.Value := State;
end;
{ @end $80E4CC }

{ @routine $80E508 TEFilm_SetObjectText }
procedure TEFilm.SetObjectText(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectText;
  Command.Obj := Obj;
  StringTable.Add(Text);
  Command.Value := StringTable.GetCount - 1;
end;
{ @end $80E508 }

{ @routine $80E55C TEFilm_PlayObjectSound }
procedure TEFilm.PlayObjectSound(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcPlayObjectSound;
  Command.Obj := Obj;
  StringTable.Add(Text);
  Command.Value := StringTable.GetCount - 1;
end;
{ @end $80E55C }

{ @routine $80E5B0 TEFilm_SetObjectStateBuffer }
procedure TEFilm.SetObjectStateBuffer(StepIndex: Integer; Obj: TEFilmObj; Buffer: TBufEC);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectStateBuffer;
  Command.Obj := Obj;
  DataBuffers.Add(Buffer);
  Command.Value := DataBuffers.Count - 1;
end;
{ @end $80E5B0 }

{ @routine $80E604 TEFilm_BeginTrailingEffects }
procedure TEFilm.BeginTrailingEffects(StepIndex: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcBeginTrailingEffects;
end;
{ @end $80E604 }

{ @routine $80E62C TEFilm_PlayPickupSound }
procedure TEFilm.PlayPickupSound(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcPlayPickupSound;
  Command.Obj := Obj;
end;
{ @end $80E62C }

// const preserves the repeated native loads when this guard is inlined.
// With sound flags, use a separate if to avoid compiler Boolean temporaries.
function HasSceneObject(const Command: PEFilmCommand): Boolean; overload; inline;
begin
  Result := (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil);
end;

// Keep all three tests in one expression: calling the overload adds Boolean temporaries.
function HasSceneObject(const Command: PEFilmCommand; const SceneClass: TClass): Boolean; overload; inline;
begin
  Result := (Command.Obj <> nil) and (Command.Obj.SceneObject <> nil) and (Command.Obj.SceneObject is SceneClass);
end;

{ @routine $80E660 TEFilm_ExecuteCommand }
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
        if HasSceneObject(Command) then
          Command.Obj.SceneObject.SetPosition(PEFilmVectorCommand(Command).Position);
      efcSetObjectOrbitCenter:
        if HasSceneObject(Command) then
          Command.Obj.SceneObject.SetOrbitCenter(PEFilmVectorCommand(Command).Position);
      efcSetObjectAlpha:
        if HasSceneObject(Command) then
          Command.Obj.SceneObject.SetAlpha(PEFilmByteCommand(Command).Value);
      efcSetObjectAngle:
        if HasSceneObject(Command) then
          Command.Obj.SceneObject.SetAngle(PEFilmByteCommand(Command).Value);
      efcAdvanceObject:
        if HasSceneObject(Command) then
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
        if HasSceneObject(Command, TPlanetSE) then
        begin
          (Command.Obj.SceneObject as TPlanetSE).SetRotationTimerInterval(PEFilmObjectCommand(Command).Value and $FFFFFF);
          (Command.Obj.SceneObject as TPlanetSE).SetRingKind(PEFilmObjectCommand(Command).Value shr 24);
          (Command.Obj.SceneObject as TPlanetSE).SetSurfaceMapStep(PEFilmObjectCommand(Command).ExtraValue);
          (Command.Obj.SceneObject as TPlanetSE).OrbitalVelocity := SmallInt(PEFilmObjectCommand(Command).Flags and $FFFF) / 1000;
          (Command.Obj.SceneObject as TPlanetSE).SetMinimapOwner(PEFilmObjectCommand(Command).Flags shr 24);
          (Command.Obj.SceneObject as TPlanetSE).Civilized := (Command.Obj.SceneObject as TPlanetSE).MinimapOwner <> 6;
        end;
      efcSetShipSizeAndTailMode:
        if HasSceneObject(Command, TShip2SE) then
        begin
          Ship := Command.Obj.SceneObject as TShip2SE;
          Ship.SetSize(PEFilmSizeCommand(Command).Size);
          if (ShipTail = 2) or ((ShipTail = 1) and (GetPlayer <> nil) and (GetPlayer.Id = Integer(Command.Obj.ObjectId))) then
            Ship.SetTailMode(PEFilmSizeCommand(Command).TailMode)
          else Ship.SetTailMode(0);
        end;
      efcSetRuinsState:
        if HasSceneObject(Command, TRuinsSE) then
        begin
          Ruins := Command.Obj.SceneObject as TRuinsSE;
          Ruins.SetState(PEFilmObjectCommand(Command).Value);
        end;
      efcSetWeaponHit:
        if HasSceneObject(Command, TWeaponSE) then
          (Command.Obj.SceneObject as TWeaponSE).SetHit(PEFilmHitCommand(Command).Color, PEFilmHitCommand(Command).Damage, PEFilmHitCommand(Command).Destroyed, PEFilmHitCommand(Command).PlaySound);
      efcSetWeaponEndpoints:
        begin
          { Both endpoint scene-object tests are repeated in the native code. }
        Source := nil;
          if (PEFilmEndpointsCommand(Command).Source <> nil) and (PEFilmEndpointsCommand(Command).Source.SceneObject <> nil) and (PEFilmEndpointsCommand(Command).Source.SceneObject <> nil) then Source := PEFilmEndpointsCommand(Command).Source.SceneObject;
          Target := nil;
          if (PEFilmEndpointsCommand(Command).Target <> nil) and (PEFilmEndpointsCommand(Command).Target.SceneObject <> nil) and (PEFilmEndpointsCommand(Command).Target.SceneObject <> nil) then Target := PEFilmEndpointsCommand(Command).Target.SceneObject;
          if HasSceneObject(Command, TWeaponSE) then
            (Command.Obj.SceneObject as TWeaponSE).SetEndpoints(Source, Target);
        end;
      efcSetDestructionEffect:
        if HasSceneObject(Command, TWeaponSE) then
          (Command.Obj.SceneObject as TWeaponSE).DestructionEffect := PEFilmObjectCommand(Command).Value;
      efcSetEffectImagePosition:
        if HasSceneObject(Command, TGAIEffectSE) then
          (Command.Obj.SceneObject as TGAIEffectSE).SetImagePosition(PEFilmSizeCommand(Command).Size);
      efcSetEffectDurationScale:
        if HasSceneObject(Command, TGAIEffectSE) then
          (Command.Obj.SceneObject as TGAIEffectSE).SetDurationScale(PEFilmVectorCommand(Command).Position.X);
      efcAttachObject:
        begin
          ErrorStep := 1;
          if HasSceneObject(Command) then
        begin
            ErrorStep := 2;
            if Command.Obj.SceneObject is TShip2SE then
          begin
              ErrorStep := 3;
              with Command.Obj.SceneObject as TShip2SE do
            begin
                ErrorStep := 4;
                if ((ShipTail <> 2) and ((ShipTail <> 1) or (GetPlayer = nil) or (GetPlayer.Id <> Integer(Command.Obj.ObjectId)))) or
                  (TailMode <= 0) then SetTailMode(0);
              end;
            end;
            ErrorStep := 5;
            Command.Obj.SceneObject.AttachToSpace(SpaceProcess.Space);
          end;
        end;
      efcDetachObject:
        if HasSceneObject(Command) then
          Command.Obj.SceneObject.DetachFromSpace;
      efcReleaseObject:
        if HasSceneObject(Command) then
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
        if ReplayMode then FilmScreen.FollowViewOffset(TruncatePointF(PEFilmVectorCommand(Command).Position))
        else StarMapScreen.SetMapCenter(TruncatePointF(PEFilmVectorCommand(Command).Position));
      efcSetRadarCenter:
        begin
          if ReplayMode then FilmScreen.CameraTarget := PEFilmVectorCommand(Command).Position;
          SpaceProcess.RadarCenter := PEFilmVectorCommand(Command).Position;
        end;
      efcSetCameraAnchor:
        begin
          CameraAnchor := PEFilmVectorCommand(Command).Position;
          ForceCameraMovement := PEFilmVectorCommand(Command).ForceMovement;
        end;
      efcOpenGate:
        if HasSceneObject(Command, TGateSE) then
          (Command.Obj.SceneObject as TGateSE).Open;
      efcCloseGate:
        if HasSceneObject(Command, TGateSE) then
          (Command.Obj.SceneObject as TGateSE).Close;
      efcSetGateState:
        if HasSceneObject(Command, TGateSE) then
          (Command.Obj.SceneObject as TGateSE).SetState(PEFilmObjectCommand(Command).Value);
      efcSetGateSize:
        if HasSceneObject(Command, TGateSE) then
          (Command.Obj.SceneObject as TGateSE).SetSize(Classes.Point(PEFilmObjectCommand(Command).Value, PEFilmObjectCommand(Command).Value));
      efcSetGateEffectSize:
        if HasSceneObject(Command, TGateEffectSE) then
          (Command.Obj.SceneObject as TGateEffectSE).SetSize(Classes.Point(PEFilmObjectCommand(Command).Value, PEFilmObjectCommand(Command).Value));
      efcSetHoleState:
        if HasSceneObject(Command, THoleSE) then
          (Command.Obj.SceneObject as THoleSE).SetState(PEFilmObjectCommand(Command).Value);
      efcSetObjectText:
        if HasSceneObject(Command) then
          Command.Obj.SceneObject.SetText(StringTable.GetTextAt(PEFilmObjectCommand(Command).Value));
      efcPlayObjectSound:
        if FilmSoundEffectsEnabled and SoundInSpaceEnabled then
          if HasSceneObject(Command) then
            if (Command.Obj.SceneObject.Space <> nil) and
              Command.Obj.SceneObject.Space.ContainsMapPoint(Command.Obj.SceneObject.Position) then
              SoundManager.PlaySound(StringTable.GetTextAt(PEFilmObjectCommand(Command).Value));
      efcSetObjectStateBuffer:
        if HasSceneObject(Command) then
          Command.Obj.SceneObject.LoadStateBuffer(TBufEC(DataBuffers[PEFilmObjectCommand(Command).Value]));
      efcPlayPickupSound:
        if HasSceneObject(Command) then
          if SoundInSpaceEnabled and SpaceProcess.Space.ContainsMapPoint(Command.Obj.SceneObject.Position) then
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
{ @end $80E660 }

{ @routine $80F544 TEFilm_ReleaseWeaponSceneObjects }
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
{ @end $80F544 }

{ @routine $80F5A4 TEFilm_ReleaseObjectReferences }
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
{ @end $80F5A4 }

{ @routine $80F610 TEFilm_SaveToBuffer }
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
  Count := StringTable.GetCount;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do Buffer.AddWideStringZ(StringTable.GetTextAt(I));
  Count := DataBuffers.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Data := TBufEC(DataBuffers[I]);
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
{ @end $80F610 }

{ @routine $80FFB8 TEFilm_LoadFromBuffer }
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
{ @end $80FFB8 }

end.
