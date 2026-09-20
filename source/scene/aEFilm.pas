unit aEFilm;
// Unit bracket (inferred): .text 0x007CEC0C..0x007D2610; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Str, EC_Struct, SE_Process, SE_Space, Types, aEObjInfo;

const
  // Native serialized tags. Kind remains Byte so unknown values stay representable.
  efcSetObjectPosition = 0;
  efcSetObjectOrbitCenter = 1;
  efcSetObjectAlpha = 2;
  efcSetObjectAngle = 3;
  efcAdvanceObject = 4; // No recovered writer; playback at $7D043F calls TObjectSE.Advance.
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
    Payload: array[0..15] of Byte; // @offset 0x10
  end;

  PEFilmObjectCommand = ^TEFilmObjectCommand;
  TEFilmObjectCommand = packed record // @size 0x20 Scalar object-command payload view.
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Value: Integer; // @offset 0x14
    ExtraValue: Integer; // @offset 0x18
    Flags: Integer; // @offset 0x1C
  end;

  PEFilmVectorCommand = ^TEFilmVectorCommand;
  TEFilmVectorCommand = packed record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Position: TPointF; // @offset 0x14
    ForceMovement: Boolean; // @offset 0x1C
  end;

  PEFilmSizeCommand = ^TEFilmSizeCommand;
  TEFilmSizeCommand = packed record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Size: TPoint; // @offset 0x14
    TailMode: Integer; // @offset 0x1C
  end;

  PEFilmByteCommand = ^TEFilmByteCommand;
  TEFilmByteCommand = packed record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Value: Byte; // @offset 0x14
  end;

  PEFilmHitCommand = ^TEFilmHitCommand;
  TEFilmHitCommand = packed record // @size 0x20
    Kind: Byte; // @offset 0x08
    StepIndex: Integer; // @offset 0x0C
    Obj: TEFilmObj; // @offset 0x10
    Color: Word; // @offset 0x14
    Damage: Integer; // @offset 0x18
    Destroyed: Boolean; // @offset 0x1C
    PlaySound: Boolean; // @offset 0x1D
  end;

  PEFilmEndpointsCommand = ^TEFilmEndpointsCommand;
  TEFilmEndpointsCommand = packed record // @size 0x20
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

    constructor Create; // @addr 0x7CED0C @ida "TEFilm *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7CED84 @ida "void __usercall $name(TEFilm *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr 0x7CEE60
    procedure ReserveCameraEventSlot; // @addr $7CEF04 Grows capacity and advances the used count without writing the new slot.
    procedure RemoveObject(Obj: TEFilmObj); // @addr $7CF1A4
    function ObjectCount: Integer; // @addr $7CF228
    function FindObjectIndex(Obj: TEFilmObj): Integer; // @addr $7CF300 Nil maps to 65535; an absent non-nil object maps to -1.
    procedure GrowCommandPool(Count: Integer); // @addr $7CF504
    procedure RecycleCommands(First, Last: PEFilmCommand); // @addr $7CF574 Moves an inclusive linked range to the free list.
    procedure AppendCommand(Command: PEFilmCommand); // @addr $7CF624
    procedure InsertCommand(Before, Command: PEFilmCommand); // @addr $7CF678 Nil Before appends.
    function AddCommand(StepIndex: Integer): PEFilmCommand; // @addr $7CF778 Stable insertion by step index.
    function CommandCount: Integer; // @addr $7CF81C
    function AllocateObject: TEFilmObj; // @addr 0x7CEFF4 @note "Appends an object owned by this film."
    function ObjToNom(Obj: TEFilmObj): Integer; // @addr 0x7CF264 @note "Zero-based list index; nil maps to 65535. Raises for an object outside this film."
    function NomToObj(Index: Integer): TEFilmObj; // @addr 0x7CF360 @note "Returns a borrowed object. Index 65535 maps to nil; other missing indexes raise."
    function FindObject(const KindName, GraphKey: WideString; ObjectId: Cardinal): TEFilmObj; // @addr 0x7CF438 @note "Matches all three keys; returns a borrowed object or nil."
    function FindObjectById(const KindName: WideString; ObjectId: Cardinal): TEFilmObj; // @addr $7CF4A8
    function AllocateCommand: PEFilmCommand; // @addr 0x7CF718 @note "Returns a zeroed pooled command without linking it into the command list."
    function AddObject(ObjectId: Cardinal; SceneObject: TObjectSE; Unused1: Integer = 0; Unused2: Integer = 0): TEFilmObj; // @addr 0x7CF858 @note "Retains SceneObject and copies its class name and graph key. Both stack arguments are unused."
    function ContainsObject(Obj: TEFilmObj): Boolean; // @addr 0x7CF3F4
    procedure AddCameraEvent(AStepIndex: Integer; AStartPosition, AEndPosition: TPointF; APriority: Integer); // @addr 0x7CEF4C @ida "void __userpurge $name(TEFilm *Self@<eax>, int AStepIndex@<edx>, TPointF *AStartPosition@<ecx>, TPointF *AEndPosition@<^4>, int APriority@<^0>);"
    procedure SetObjectPosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF); // @addr 0x7CF8F4 @ida "void __userpurge $name(TEFilm *Self@<eax>, int StepIndex@<edx>, TEFilmObj *Obj@<ecx>, TPointF *Position@<^0>);"
    procedure SetObjectAlpha(StepIndex: Integer; Obj: TEFilmObj; Alpha: Byte); // @addr 0x7CF9C0
    procedure SetObjectAngle(StepIndex: Integer; Obj: TEFilmObj; Angle: Byte); // @addr 0x7CFA28 @note "A full turn is 256 angle units."
    procedure AdvanceObjects(StepIndex: Integer); // @addr 0x7CFA90 @note "Queues slot 0x40 on each retained scene object."
    procedure SetWeaponHit(StepIndex: Integer; Obj: TEFilmObj; Color: Word; Damage: Integer; Destroyed, PlaySound: Boolean); // @addr 0x7CFC34
    procedure SetWeaponEndpoints(StepIndex: Integer; Obj, Source, Target: TEFilmObj); // @addr 0x7CFCBC @note "Source and Target may be nil; Obj must exist."
    procedure SetDestructionEffect(StepIndex: Integer; Obj: TEFilmObj; Value: Integer); // @addr 0x7CFD30 @note "Playback selects TWeaponSE destruction effects: 1=bomb, 2=asteroid, 5=kamikaze; other modes include fades and immediate removal."
    procedure AttachObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x7CFDF8
    procedure DetachObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x7CFE58
    procedure ReleaseObject(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x7CFEB8 @note "Playback detaches and releases the scene reference, retaining the film entry."
    procedure ReleaseWeaponEffects(StepIndex: Integer); // @addr 0x7CFEEC
    procedure CloseGate(StepIndex: Integer; Obj: TEFilmObj); // @addr 0x7D0014 @note "Playback changes gate state 2 to 3 and resets its timer."
    procedure SetGateState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr 0x7D0048
    procedure SetGateSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer); // @addr 0x7D0084
    procedure SetHoleState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr 0x7D00FC
    procedure SetObjectText(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString); // @addr 0x7D0138
    procedure BeginTrailingEffects(StepIndex: Integer); // @addr 0x7D0234 @note "Appends the kind-24 boundary consumed by film playback."

    procedure SetObjectOrbitCenter(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF); // @addr $7CF970 @ida "void __userpurge $name(TEFilm *Self@<eax>, int StepIndex@<edx>, TEFilmObj *Obj@<ecx>, TPointF *Position@<^0>);"
    procedure SetPlanetState(StepIndex: Integer; Obj: TEFilmObj; RotationInterval, SurfaceMapStep: Integer; ScaleThousandths: Word; RingKind, Owner: Byte); // @addr $7CFAB8 Scale is decoded as a signed 16-bit value divided by 1000 during playback.
    procedure SetShipSizeAndTailMode(StepIndex: Integer; Obj: TEFilmObj; Size: TPoint; TailMode: Integer); // @addr $7CFB48 @ida "void __userpurge $name(TEFilm *Self@<eax>, int StepIndex@<edx>, TEFilmObj *Obj@<ecx>, TPoint *Size@<^4>, int TailMode@<^0>);"
    procedure SetRuinsState(StepIndex: Integer; Obj: TEFilmObj; State: Integer); // @addr $7CFBCC
    procedure SetEffectImagePosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPoint); // @addr $7CFD6C @ida "void __userpurge $name(TEFilm *Self@<eax>, int StepIndex@<edx>, TEFilmObj *Obj@<ecx>, TPoint *Position@<^0>);"
    procedure SetEffectDurationScale(StepIndex: Integer; Obj: TEFilmObj; Scale: Single); // @addr $7CFDBC @ida "void __userpurge $name(TEFilm *Self@<eax>, int StepIndex@<edx>, TEFilmObj *Obj@<ecx>, float Scale@<^0>);" @note "Records the Single duration multiplier consumed by TGAIEffectSE.SetDurationScale."
    procedure SetGateEffectSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer); // @addr $7D00C0
    procedure OpenGate(StepIndex: Integer; Obj: TEFilmObj); // @addr $7CFFE0
    procedure PlayPickupSound(StepIndex: Integer; Obj: TEFilmObj); // @addr $7D025C
    procedure SetViewCenter(StepIndex: Integer; Position: TPointF); // @addr $7CFF14 @ida "void __usercall $name(TEFilm *Self@<eax>, int StepIndex@<edx>, TPointF *Position@<ecx>);"
    procedure SetRadarCenter(StepIndex: Integer; Position: TPointF); // @addr $7CFF54 @ida "void __usercall $name(TEFilm *Self@<eax>, int StepIndex@<edx>, TPointF *Position@<ecx>);"
    procedure SetCameraAnchor(StepIndex: Integer; Position: TPointF; ForceMovement: Boolean); // @addr $7CFF94 @ida "void __userpurge $name(TEFilm *Self@<eax>, int StepIndex@<edx>, TPointF *Position@<ecx>, bool ForceMovement@<^0>);"
    procedure PlayObjectSound(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString); // @addr $7D018C
    procedure SetObjectStateBuffer(StepIndex: Integer; Obj: TEFilmObj; Buffer: TBufEC); // @addr $7D01E0 Transfers ownership of Buffer to the film.

    procedure ExecuteCommand(Process: TProcessSE; Command: PEFilmCommand; ReplayMode: Boolean); // @addr 0x7D0290
    procedure ReleaseWeaponSceneObjects; // @addr $7D1174 Detaches weapon effects and releases their retained scene references.
    procedure ReleaseObjectReferences(Obj: TObjectSE); // @addr $7D11D4
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7D1240 @note "Clears Buffer. Serializes object identities and commands, excluding live scene references and Turn."
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x7D1BE8 @note "Clears the film and rewinds Buffer before reading. Scene objects are recreated separately."
  end;

const
  FilmFormatVersion: Integer = 6; // @addr $87C258 Native writer format, read from initialized storage.

implementation

uses SysUtils, EC_Mem, GR_Main, GR_DX, GR_GraphBuf, SE_Weapon, SE_Planet, SE_Ship2, SE_Ruins, SE_Gate, SE_Hole, SE_GAIEffect,
  Globals, GlobalsV, aPlayer, aMyFunction, fFilm, fStarMap;

{ @routine $7CED0C TEFilm_Create }
constructor TEFilm.Create;
begin
  inherited Create;
  StringTable := TStringsEC.Create;
  DataBuffers := TList.Create;
  ObjectInfo := TEObjInfo.Create;
end;
{ @end $7CED0C }

{ @routine $7CED84 TEFilm_Destroy }
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
{ @end $7CED84 }

{ @routine $7CEE60 TEFilm_Clear }
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
{ @end $7CEE60 }

{ @routine $7CEF04 TEFilm_ReserveCameraEventSlot }
procedure TEFilm.ReserveCameraEventSlot;
begin
  if High(CameraEvents) <= CameraEventCount then SetLength(CameraEvents, CameraEventCount + 30);
  Inc(CameraEventCount);
end;
{ @end $7CEF04 }

{ @routine $7CEF4C TEFilm_AddCameraEvent }
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
{ @end $7CEF4C }

{ @routine $7CEFF4 TEFilm_AllocateObject }
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
{ @end $7CEFF4 }

{ @routine $7CF1A4 TEFilm_RemoveObject }
procedure TEFilm.RemoveObject(Obj: TEFilmObj);
begin
  if Obj.Prev <> nil then Obj.Prev.Next := Obj.Next;
  if Obj.Next <> nil then Obj.Next.Prev := Obj.Prev;
  if LastObject = Obj then LastObject := Obj.Prev;
  if FirstObject = Obj then FirstObject := Obj.Next;
  ReleaseSpaceObject(Obj.SceneObject);
  Obj.Free;
end;
{ @end $7CF1A4 }

{ @routine $7CF228 TEFilm_ObjectCount }
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
{ @end $7CF228 }

{ @routine $7CF264 TEFilm_ObjToNom }
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
{ @end $7CF264 }

{ @routine $7CF300 TEFilm_FindObjectIndex }
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
{ @end $7CF300 }

{ @routine $7CF360 TEFilm_NomToObj }
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
{ @end $7CF360 }

{ @routine $7CF3F4 TEFilm_ContainsObject }
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
{ @end $7CF3F4 }

{ @routine $7CF438 TEFilm_FindObject }
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
{ @end $7CF438 }

{ @routine $7CF4A8 TEFilm_FindObjectById }
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
{ @end $7CF4A8 }

{ @routine $7CF504 TEFilm_GrowCommandPool }
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
{ @end $7CF504 }

{ @routine $7CF574 TEFilm_RecycleCommands }
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
{ @end $7CF574 }

{ @routine $7CF624 TEFilm_AppendCommand }
procedure TEFilm.AppendCommand(Command: PEFilmCommand);
begin
  if LastCommand <> nil then LastCommand.Next := Command;
  Command.Prev := LastCommand;
  Command.Next := nil;
  LastCommand := Command;
  if FirstCommand = nil then FirstCommand := Command;
end;
{ @end $7CF624 }

{ @routine $7CF678 TEFilm_InsertCommand }
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
{ @end $7CF678 }

{ @routine $7CF718 TEFilm_AllocateCommand }
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
{ @end $7CF718 }

{ @routine $7CF778 TEFilm_AddCommand }
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
{ @end $7CF778 }

{ @routine $7CF81C TEFilm_CommandCount }
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
{ @end $7CF81C }

{ @routine $7CF858 TEFilm_AddObject }
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
{ @end $7CF858 }

{ @routine $7CF8F4 TEFilm_SetObjectPosition }
procedure TEFilm.SetObjectPosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF);
var Command: PEFilmVectorCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectPosition;
  Command.Obj := Obj;
  Command.Position := Position;
end;
{ @end $7CF8F4 }

{ @routine $7CF970 TEFilm_SetObjectOrbitCenter }
procedure TEFilm.SetObjectOrbitCenter(StepIndex: Integer; Obj: TEFilmObj; Position: TPointF);
var Command: PEFilmVectorCommand;
begin
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectOrbitCenter;
  Command.Obj := Obj;
  Command.Position := Position;
end;
{ @end $7CF970 }

{ @routine $7CF9C0 TEFilm_SetObjectAlpha }
procedure TEFilm.SetObjectAlpha(StepIndex: Integer; Obj: TEFilmObj; Alpha: Byte);
var Command: PEFilmByteCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmByteCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectAlpha;
  Command.Obj := Obj;
  Command.Value := Alpha;
end;
{ @end $7CF9C0 }

{ @routine $7CFA28 TEFilm_SetObjectAngle }
procedure TEFilm.SetObjectAngle(StepIndex: Integer; Obj: TEFilmObj; Angle: Byte);
var Command: PEFilmByteCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmByteCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectAngle;
  Command.Obj := Obj;
  Command.Value := Angle;
end;
{ @end $7CFA28 }

{ @routine $7CFA90 TEFilm_AdvanceObjects }
procedure TEFilm.AdvanceObjects(StepIndex: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcAdvanceObjects;
end;
{ @end $7CFA90 }

{ @routine $7CFAB8 TEFilm_SetPlanetState }
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
{ @end $7CFAB8 }

{ @routine $7CFB48 TEFilm_SetShipSizeAndTailMode }
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
{ @end $7CFB48 }

{ @routine $7CFBCC TEFilm_SetRuinsState }
procedure TEFilm.SetRuinsState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmObjectCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetRuinsState;
  Command.Obj := Obj;
  Command.Value := State;
end;
{ @end $7CFBCC }

{ @routine $7CFC34 TEFilm_SetWeaponHit }
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
{ @end $7CFC34 }

{ @routine $7CFCBC TEFilm_SetWeaponEndpoints }
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
{ @end $7CFCBC }

{ @routine $7CFD30 TEFilm_SetDestructionEffect }
procedure TEFilm.SetDestructionEffect(StepIndex: Integer; Obj: TEFilmObj; Value: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetDestructionEffect;
  Command.Obj := Obj;
  Command.Value := Value;
end;
{ @end $7CFD30 }

{ @routine $7CFD6C TEFilm_SetEffectImagePosition }
procedure TEFilm.SetEffectImagePosition(StepIndex: Integer; Obj: TEFilmObj; Position: TPoint);
var Command: PEFilmSizeCommand;
begin
  Command := PEFilmSizeCommand(AddCommand(StepIndex));
  Command.Kind := efcSetEffectImagePosition;
  Command.Obj := Obj;
  Command.Size := Position;
end;
{ @end $7CFD6C }

{ @routine $7CFDBC TEFilm_SetEffectDurationScale }
procedure TEFilm.SetEffectDurationScale(StepIndex: Integer; Obj: TEFilmObj; Scale: Single);
var Command: PEFilmObjectCommand; ScaleBits: Integer absolute Scale;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetEffectDurationScale;
  Command.Obj := Obj;
  // Copy the Single payload without floating-point conversion or rounding.
  Command.Value := ScaleBits;
end;
{ @end $7CFDBC }

{ @routine $7CFDF8 TEFilm_AttachObject }
procedure TEFilm.AttachObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcAttachObject;
  Command.Obj := Obj;
end;
{ @end $7CFDF8 }

{ @routine $7CFE58 TEFilm_DetachObject }
procedure TEFilm.DetachObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  if Obj = nil then raise Exception.Create('obj=nil');
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcDetachObject;
  Command.Obj := Obj;
end;
{ @end $7CFE58 }

{ @routine $7CFEB8 TEFilm_ReleaseObject }
procedure TEFilm.ReleaseObject(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcReleaseObject;
  Command.Obj := Obj;
end;
{ @end $7CFEB8 }

{ @routine $7CFEEC TEFilm_ReleaseWeaponEffects }
procedure TEFilm.ReleaseWeaponEffects(StepIndex: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcReleaseWeaponEffects;
end;
{ @end $7CFEEC }

{ @routine $7CFF14 TEFilm_SetViewCenter }
procedure TEFilm.SetViewCenter(StepIndex: Integer; Position: TPointF);
var Command: PEFilmVectorCommand;
begin
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetViewCenter;
  Command.Position := Position;
end;
{ @end $7CFF14 }

{ @routine $7CFF54 TEFilm_SetRadarCenter }
procedure TEFilm.SetRadarCenter(StepIndex: Integer; Position: TPointF);
var Command: PEFilmVectorCommand;
begin
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetRadarCenter;
  Command.Position := Position;
end;
{ @end $7CFF54 }

{ @routine $7CFF94 TEFilm_SetCameraAnchor }
procedure TEFilm.SetCameraAnchor(StepIndex: Integer; Position: TPointF; ForceMovement: Boolean);
var Command: PEFilmVectorCommand;
begin
  Command := PEFilmVectorCommand(AddCommand(StepIndex));
  Command.Kind := efcSetCameraAnchor;
  Command.Position := Position;
  Command.ForceMovement := ForceMovement;
end;
{ @end $7CFF94 }

{ @routine $7CFFE0 TEFilm_OpenGate }
procedure TEFilm.OpenGate(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcOpenGate;
  Command.Obj := Obj;
end;
{ @end $7CFFE0 }

{ @routine $7D0014 TEFilm_CloseGate }
procedure TEFilm.CloseGate(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcCloseGate;
  Command.Obj := Obj;
end;
{ @end $7D0014 }

{ @routine $7D0048 TEFilm_SetGateState }
procedure TEFilm.SetGateState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetGateState;
  Command.Obj := Obj;
  Command.Value := State;
end;
{ @end $7D0048 }

{ @routine $7D0084 TEFilm_SetGateSize }
procedure TEFilm.SetGateSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetGateSize;
  Command.Obj := Obj;
  Command.Value := Size;
end;
{ @end $7D0084 }

{ @routine $7D00C0 TEFilm_SetGateEffectSize }
procedure TEFilm.SetGateEffectSize(StepIndex: Integer; Obj: TEFilmObj; Size: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetGateEffectSize;
  Command.Obj := Obj;
  Command.Value := Size;
end;
{ @end $7D00C0 }

{ @routine $7D00FC TEFilm_SetHoleState }
procedure TEFilm.SetHoleState(StepIndex: Integer; Obj: TEFilmObj; State: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetHoleState;
  Command.Obj := Obj;
  Command.Value := State;
end;
{ @end $7D00FC }

{ @routine $7D0138 TEFilm_SetObjectText }
procedure TEFilm.SetObjectText(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectText;
  Command.Obj := Obj;
  StringTable.Add(Text);
  Command.Value := StringTable.GetCount - 1;
end;
{ @end $7D0138 }

{ @routine $7D018C TEFilm_PlayObjectSound }
procedure TEFilm.PlayObjectSound(StepIndex: Integer; Obj: TEFilmObj; const Text: WideString);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcPlayObjectSound;
  Command.Obj := Obj;
  StringTable.Add(Text);
  Command.Value := StringTable.GetCount - 1;
end;
{ @end $7D018C }

{ @routine $7D01E0 TEFilm_SetObjectStateBuffer }
procedure TEFilm.SetObjectStateBuffer(StepIndex: Integer; Obj: TEFilmObj; Buffer: TBufEC);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcSetObjectStateBuffer;
  Command.Obj := Obj;
  DataBuffers.Add(Buffer);
  Command.Value := DataBuffers.Count - 1;
end;
{ @end $7D01E0 }

{ @routine $7D0234 TEFilm_BeginTrailingEffects }
procedure TEFilm.BeginTrailingEffects(StepIndex: Integer);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcBeginTrailingEffects;
end;
{ @end $7D0234 }

{ @routine $7D025C TEFilm_PlayPickupSound }
procedure TEFilm.PlayPickupSound(StepIndex: Integer; Obj: TEFilmObj);
var Command: PEFilmObjectCommand;
begin
  Command := PEFilmObjectCommand(AddCommand(StepIndex));
  Command.Kind := efcPlayPickupSound;
  Command.Obj := Obj;
end;
{ @end $7D025C }

{ @routine $7D0290 TEFilm_ExecuteCommand }
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
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
          PEFilmObjectCommand(Command).Obj.SceneObject.SetPosition(PEFilmVectorCommand(Command).Position);
      efcSetObjectOrbitCenter:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
          PEFilmObjectCommand(Command).Obj.SceneObject.SetOrbitCenter(PEFilmVectorCommand(Command).Position);
      efcSetObjectAlpha:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
          PEFilmObjectCommand(Command).Obj.SceneObject.SetAlpha(PEFilmByteCommand(Command).Value);
      efcSetObjectAngle:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
          PEFilmObjectCommand(Command).Obj.SceneObject.SetAngle(PEFilmByteCommand(Command).Value);
      efcAdvanceObject:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
          PEFilmObjectCommand(Command).Obj.SceneObject.Advance;
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
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TPlanetSE) then
        begin
          (PEFilmObjectCommand(Command).Obj.SceneObject as TPlanetSE).SetRotationTimerInterval(PEFilmObjectCommand(Command).Value and $FFFFFF);
          (PEFilmObjectCommand(Command).Obj.SceneObject as TPlanetSE).SetRingKind(PEFilmObjectCommand(Command).Value shr 24);
          (PEFilmObjectCommand(Command).Obj.SceneObject as TPlanetSE).SetSurfaceMapStep(PEFilmObjectCommand(Command).ExtraValue);
          (PEFilmObjectCommand(Command).Obj.SceneObject as TPlanetSE).OrbitalVelocity := SmallInt(PEFilmObjectCommand(Command).Flags and $FFFF) / 1000;
          (PEFilmObjectCommand(Command).Obj.SceneObject as TPlanetSE).SetMinimapOwner(PEFilmObjectCommand(Command).Flags shr 24);
          (PEFilmObjectCommand(Command).Obj.SceneObject as TPlanetSE).Civilized := (PEFilmObjectCommand(Command).Obj.SceneObject as TPlanetSE).MinimapOwner <> 6;
        end;
      efcSetShipSizeAndTailMode:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TShip2SE) then
        begin
          Ship := PEFilmObjectCommand(Command).Obj.SceneObject as TShip2SE;
          Ship.SetSize(PEFilmSizeCommand(Command).Size);
          if (ShipTail = 2) or ((ShipTail = 1) and (GetPlayer <> nil) and (GetPlayer.Id = Integer(PEFilmObjectCommand(Command).Obj.ObjectId))) then
            Ship.SetTailMode(PEFilmSizeCommand(Command).TailMode)
          else Ship.SetTailMode(0);
        end;
      efcSetRuinsState:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TRuinsSE) then
        begin
          Ruins := PEFilmObjectCommand(Command).Obj.SceneObject as TRuinsSE;
          Ruins.SetState(PEFilmObjectCommand(Command).Value);
        end;
      efcSetWeaponHit:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TWeaponSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TWeaponSE).SetHit(PEFilmHitCommand(Command).Color, PEFilmHitCommand(Command).Damage, PEFilmHitCommand(Command).Destroyed, PEFilmHitCommand(Command).PlaySound);
      efcSetWeaponEndpoints:
        begin
          { Both endpoint scene-object tests are repeated in the native code. }
        Source := nil;
          if (PEFilmEndpointsCommand(Command).Source <> nil) and (PEFilmEndpointsCommand(Command).Source.SceneObject <> nil) and (PEFilmEndpointsCommand(Command).Source.SceneObject <> nil) then Source := PEFilmEndpointsCommand(Command).Source.SceneObject;
          Target := nil;
          if (PEFilmEndpointsCommand(Command).Target <> nil) and (PEFilmEndpointsCommand(Command).Target.SceneObject <> nil) and (PEFilmEndpointsCommand(Command).Target.SceneObject <> nil) then Target := PEFilmEndpointsCommand(Command).Target.SceneObject;
          if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TWeaponSE) then
            (PEFilmObjectCommand(Command).Obj.SceneObject as TWeaponSE).SetEndpoints(Source, Target);
        end;
      efcSetDestructionEffect:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TWeaponSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TWeaponSE).DestructionEffect := PEFilmObjectCommand(Command).Value;
      efcSetEffectImagePosition:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TGAIEffectSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TGAIEffectSE).SetImagePosition(PEFilmSizeCommand(Command).Size);
      efcSetEffectDurationScale:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TGAIEffectSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TGAIEffectSE).SetDurationScale(PEFilmVectorCommand(Command).Position.X);
      efcAttachObject:
        begin
          ErrorStep := 1;
          if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
        begin
            ErrorStep := 2;
            if PEFilmObjectCommand(Command).Obj.SceneObject is TShip2SE then
          begin
              ErrorStep := 3;
              with PEFilmObjectCommand(Command).Obj.SceneObject as TShip2SE do
            begin
                ErrorStep := 4;
                if ((ShipTail <> 2) and ((ShipTail <> 1) or (GetPlayer = nil) or (GetPlayer.Id <> Integer(PEFilmObjectCommand(Command).Obj.ObjectId)))) or
                  (TailMode <= 0) then SetTailMode(0);
              end;
            end;
            ErrorStep := 5;
            PEFilmObjectCommand(Command).Obj.SceneObject.AttachToSpace(SpaceProcess.Space);
          end;
        end;
      efcDetachObject:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
          PEFilmObjectCommand(Command).Obj.SceneObject.DetachFromSpace;
      efcReleaseObject:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
        begin
          PEFilmObjectCommand(Command).Obj.SceneObject.DetachFromSpace;
          ReleaseSpaceObject(PEFilmObjectCommand(Command).Obj.SceneObject);
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
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TGateSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TGateSE).Open;
      efcCloseGate:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TGateSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TGateSE).Close;
      efcSetGateState:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TGateSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TGateSE).SetState(PEFilmObjectCommand(Command).Value);
      efcSetGateSize:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TGateSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TGateSE).SetSize(Classes.Point(PEFilmObjectCommand(Command).Value, PEFilmObjectCommand(Command).Value));
      efcSetGateEffectSize:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is TGateEffectSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as TGateEffectSE).SetSize(Classes.Point(PEFilmObjectCommand(Command).Value, PEFilmObjectCommand(Command).Value));
      efcSetHoleState:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject is THoleSE) then
          (PEFilmObjectCommand(Command).Obj.SceneObject as THoleSE).SetState(PEFilmObjectCommand(Command).Value);
      efcSetObjectText:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
          PEFilmObjectCommand(Command).Obj.SceneObject.SetText(StringTable.GetTextAt(PEFilmObjectCommand(Command).Value));
      efcPlayObjectSound:
        if FilmSoundEffectsEnabled and SoundInSpaceEnabled and (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and
          (PEFilmObjectCommand(Command).Obj.SceneObject.Space <> nil) and PEFilmObjectCommand(Command).Obj.SceneObject.Space.ContainsMapPoint(PEFilmObjectCommand(Command).Obj.SceneObject.Position) then
          SoundManager.PlaySound(StringTable.GetTextAt(PEFilmObjectCommand(Command).Value));
      efcSetObjectStateBuffer:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) then
          PEFilmObjectCommand(Command).Obj.SceneObject.LoadStateBuffer(TBufEC(DataBuffers[PEFilmObjectCommand(Command).Value]));
      efcPlayPickupSound:
        if (PEFilmObjectCommand(Command).Obj <> nil) and (PEFilmObjectCommand(Command).Obj.SceneObject <> nil) and SoundInSpaceEnabled and
          SpaceProcess.Space.ContainsMapPoint(PEFilmObjectCommand(Command).Obj.SceneObject.Position) then SoundManager.PlaySound('Sound.Take');
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('Error in procedure TEFilm.RunOrder, order = ' + IntToStr(Command.Kind) + ', label = ' + IntToStr(ErrorStep));
      if PEFilmObjectCommand(Command).Obj <> nil then
      begin
        AppendLogLineThreadSafe(PEFilmObjectCommand(Command).Obj.KindName);
        AppendLogLineThreadSafe(PEFilmObjectCommand(Command).Obj.GraphKey);
        if PEFilmObjectCommand(Command).Obj.SceneObject <> nil then AppendLogLineThreadSafe(PEFilmObjectCommand(Command).Obj.SceneObject.GraphKey);
      end;
      raise Exception.Create('Error in procedure TEFilm.RunOrder, order = ' + IntToStr(Command.Kind) + ', label = ' + IntToStr(ErrorStep));
    end;
  end;
end;
{ @end $7D0290 }

{ @routine $7D1174 TEFilm_ReleaseWeaponSceneObjects }
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
{ @end $7D1174 }

{ @routine $7D11D4 TEFilm_ReleaseObjectReferences }
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
{ @end $7D11D4 }

{ @routine $7D1240 TEFilm_SaveToBuffer }
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
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.Y);
    end
    else if Command.Kind = efcSetObjectOrbitCenter then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.Y);
    end
    else if Command.Kind = efcSetObjectAlpha then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddAnsiChar(AnsiChar(PEFilmByteCommand(Command).Value));
    end
    else if Command.Kind = efcSetObjectAngle then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddAnsiChar(AnsiChar(PEFilmByteCommand(Command).Value));
    end
    else if Command.Kind = efcAdvanceObject then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
    end
    else if Command.Kind = efcAdvanceObjects then
    begin
    end
    else if Command.Kind = efcSetPlanetState then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).ExtraValue);
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Flags);
    end
    else if Command.Kind = efcSetShipSizeAndTailMode then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddWideChar(WideChar(PEFilmSizeCommand(Command).Size.X));
      Buffer.AddWideChar(WideChar(PEFilmSizeCommand(Command).Size.Y));
      Buffer.AddAnsiChar(AnsiChar(PEFilmSizeCommand(Command).TailMode));
    end
    else if Command.Kind = efcSetRuinsState then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddAnsiChar(AnsiChar(PEFilmObjectCommand(Command).Value));
    end
    else if Command.Kind = efcSetWeaponHit then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddAnsiChar(AnsiChar(CurrentPixelFormat.UnpackRed(PEFilmHitCommand(Command).Color)));
      Buffer.AddAnsiChar(AnsiChar(CurrentPixelFormat.UnpackGreen(PEFilmHitCommand(Command).Color)));
      Buffer.AddAnsiChar(AnsiChar(CurrentPixelFormat.UnpackBlue(PEFilmHitCommand(Command).Color)));
      Buffer.AddIntegerValue(PEFilmHitCommand(Command).Damage);
      Buffer.AddBoolean(PEFilmHitCommand(Command).Destroyed);
      Buffer.AddBoolean(PEFilmHitCommand(Command).PlaySound);
    end
    else if Command.Kind = efcSetWeaponEndpoints then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
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
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddAnsiChar(AnsiChar(PEFilmObjectCommand(Command).Value));
    end
    else if Command.Kind = efcSetEffectImagePosition then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddIntegerValue(PEFilmSizeCommand(Command).Size.X);
      Buffer.AddIntegerValue(PEFilmSizeCommand(Command).Size.Y);
    end
    else if Command.Kind = efcSetEffectDurationScale then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddSingle(PEFilmVectorCommand(Command).Position.X);
    end
    else if Command.Kind = efcAttachObject then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
    end
    else if Command.Kind = efcDetachObject then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
    end
    else if Command.Kind = efcReleaseObject then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
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
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
    end
    else if Command.Kind = efcCloseGate then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
    end
    else if Command.Kind = efcSetGateState then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcSetGateSize then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcSetGateEffectSize then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcSetHoleState then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddBoolean(Boolean(PEFilmObjectCommand(Command).Value));
    end
    else if Command.Kind = efcSetObjectText then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcPlayObjectSound then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcSetObjectStateBuffer then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
      Buffer.AddIntegerValue(PEFilmObjectCommand(Command).Value);
    end
    else if Command.Kind = efcBeginTrailingEffects then
    begin
    end
    else if Command.Kind = efcPlayPickupSound then
    begin
      Buffer.AddWideChar(WideChar(ObjToNom(PEFilmObjectCommand(Command).Obj)));
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
{ @end $7D1240 }

{ @routine $7D1BE8 TEFilm_LoadFromBuffer }
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
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
      PEFilmVectorCommand(Command).Position.Y := Buffer.GetSingle;
    end
    else if Command.Kind = efcSetObjectOrbitCenter then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
      PEFilmVectorCommand(Command).Position.Y := Buffer.GetSingle;
    end
    else if Command.Kind = efcSetObjectAlpha then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmByteCommand(Command).Value := Buffer.GetByte;
    end
    else if Command.Kind = efcSetObjectAngle then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmByteCommand(Command).Value := Buffer.GetByte;
    end
    else if Command.Kind = efcAdvanceObject then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcAdvanceObjects then
    begin
    end
    else if Command.Kind = efcSetPlanetState then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
      PEFilmObjectCommand(Command).ExtraValue := Buffer.GetInt32;
      PEFilmObjectCommand(Command).Flags := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetShipSizeAndTailMode then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmSizeCommand(Command).Size.X := Buffer.GetWord;
      PEFilmSizeCommand(Command).Size.Y := Buffer.GetWord;
      PEFilmSizeCommand(Command).TailMode := Buffer.GetByte;
    end
    else if Command.Kind = efcSetRuinsState then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetByte;
    end
    else if Command.Kind = efcSetWeaponHit then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
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
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmEndpointsCommand(Command).Source := NomToObj(Buffer.GetWord);
      PEFilmEndpointsCommand(Command).Target := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcSetDestructionEffect then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetByte;
    end
    else if Command.Kind = efcSetEffectImagePosition then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmSizeCommand(Command).Size.X := Buffer.GetInt32;
      PEFilmSizeCommand(Command).Size.Y := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetEffectDurationScale then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmVectorCommand(Command).Position.X := Buffer.GetSingle;
    end
    else if Command.Kind = efcAttachObject then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcDetachObject then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcReleaseObject then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
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
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcCloseGate then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
    end
    else if Command.Kind = efcSetGateState then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetGateSize then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetGateEffectSize then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetHoleState then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Ord(Buffer.GetBoolean);
    end
    else if Command.Kind = efcSetObjectText then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcPlayObjectSound then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcSetObjectStateBuffer then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
      PEFilmObjectCommand(Command).Value := Buffer.GetInt32;
    end
    else if Command.Kind = efcBeginTrailingEffects then
    begin
    end
    else if Command.Kind = efcPlayPickupSound then
    begin
      PEFilmObjectCommand(Command).Obj := NomToObj(Buffer.GetWord);
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
{ @end $7D1BE8 }

end.
