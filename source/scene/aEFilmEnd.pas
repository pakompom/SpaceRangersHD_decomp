unit aEFilmEnd;
// Unit bracket (inferred): .text 0x007D2614..0x007D2F3E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

// $7D2660 is the Pascal class-name string "TEFilmEnd", referenced by its VMT.
// The former 12-byte IDA function there was metadata, not a tenth routine.

interface

uses EC_Struct, SE_Space, aEFilm;

type
  PEFilmEndEntry = ^TEFilmEndEntry;
  TEFilmEndEntry = packed record // @size 0x14
    Prev: PEFilmEndEntry; // @offset 0x00
    Next: PEFilmEndEntry; // @offset 0x04
    SceneObject: TObjectSE; // @offset 0x08
    RelatedObject1: TObjectSE; // @offset 0x0C
    RelatedObject2: TObjectSE; // @offset 0x10
  end;

  TEFilmEnd = class(TObjectEx) // @size 0x0C
  public
    FirstEntry: PEFilmEndEntry; // @offset 0x04
    LastEntry: PEFilmEndEntry; // @offset 0x08

    constructor Create; // @addr 0x7D266C @ida "TEFilmEnd *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7D26B0 @ida "void __usercall $name(TEFilmEnd *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure RemoveLinkedWeaponEffects; // @addr $7D2ED4 Removes weapon entries whose Projectile is nonzero.
    procedure Clear; // @addr 0x7D26EC
    function AppendEntry: PEFilmEndEntry; // @addr 0x7D2710
    procedure RemoveEntry(Entry: PEFilmEndEntry); // @addr 0x7D2790 @note "Detaches and releases all three retained scene references, then frees Entry."
    procedure TakeTrailingEffects(Film: TEFilm); // @addr 0x7D2860 @note "Transfers selected scene references from Film. Requires its 0x18 command marker."
    procedure AdvanceEffects; // @addr 0x7D2A38
    procedure ReleaseObjectReferences(Obj: TObjectSE); // @addr 0x7D2E48 @note "Clears matching references without unlinking entries."
  end;


implementation

uses SysUtils, EC_Mem, GR_Main, SE_GAIEffect, SE_Hole, SE_Weapon;


{ @routine $7D266C TEFilmEnd_Create }
constructor TEFilmEnd.Create;
begin inherited Create end;
{ @end $7D266C }

{ @routine $7D26B0 TEFilmEnd_Destroy }
destructor TEFilmEnd.Destroy;
begin Clear; inherited Destroy end;
{ @end $7D26B0 }

{ @routine $7D26EC TEFilmEnd_Clear }
procedure TEFilmEnd.Clear;
begin while FirstEntry <> nil do RemoveEntry(LastEntry) end;
{ @end $7D26EC }

{ @routine $7D2710 TEFilmEnd_AppendEntry }
function TEFilmEnd.AppendEntry: PEFilmEndEntry;
var Entry: PEFilmEndEntry;
begin
  Entry := AllocEC(SizeOf(TEFilmEndEntry));
  if LastEntry <> nil then LastEntry.Next := Entry;
  Entry.Prev := LastEntry;
  Entry.Next := nil;
  LastEntry := Entry;
  if FirstEntry = nil then FirstEntry := Entry;
  Entry.SceneObject := nil;
  Entry.RelatedObject1 := nil;
  Entry.RelatedObject2 := nil;
  Result := Entry;
end;
{ @end $7D2710 }

{ @routine $7D2790 TEFilmEnd_RemoveEntry }
procedure TEFilmEnd.RemoveEntry(Entry: PEFilmEndEntry);
begin
  if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
  if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
  if LastEntry = Entry then LastEntry := Entry.Prev;
  if FirstEntry = Entry then FirstEntry := Entry.Next;
  if Entry.SceneObject <> nil then
  begin Entry.SceneObject.DetachFromSpace; ReleaseSpaceObject(Entry.SceneObject) end;
  if Entry.RelatedObject1 <> nil then
  begin Entry.RelatedObject1.DetachFromSpace; ReleaseSpaceObject(Entry.RelatedObject1) end;
  if Entry.RelatedObject2 <> nil then
  begin Entry.RelatedObject2.DetachFromSpace; ReleaseSpaceObject(Entry.RelatedObject2) end;
  FreeEC(Entry);
end;
{ @end $7D2790 }

{ @routine $7D2860 TEFilmEnd_TakeTrailingEffects }
procedure TEFilmEnd.TakeTrailingEffects(Film: TEFilm);
var
  Command, FirstTrailing: PEFilmCommand;
  Obj: TEFilmObj;
  Entry: PEFilmEndEntry;
  Weapon: TWeaponSE;
begin
  FirstTrailing := Film.LastCommand;
  while FirstTrailing <> nil do
  begin
    if FirstTrailing.Kind = efcBeginTrailingEffects then Break;
    FirstTrailing := FirstTrailing.Prev;
  end;
  FirstTrailing := FirstTrailing.Next;
  Obj := Film.FirstObject;
  while Obj <> nil do
  begin
    if Obj.SceneObject is TGAIEffectSE then
    begin
      if TGAIEffectSE(Obj.SceneObject).Animation <> nil then
        TGAIEffectSE(Obj.SceneObject).Animation.RestartPlayback;
    end
    else if Obj.SceneObject is TWeaponSE then
    begin
      Weapon := Obj.SceneObject as TWeaponSE;
      Entry := AppendEntry;
      RetainSpaceObject(Entry.SceneObject, Weapon);
      if Weapon.TargetDestroyed then
      begin
        Command := FirstTrailing;
        while Command <> nil do
        begin
          if (Command.Kind = efcReleaseObject) and (PEFilmObjectCommand(Command).Obj <> nil) and
            (PEFilmObjectCommand(Command).Obj.SceneObject = Weapon.TargetObject) then
          begin
            RetainSpaceObject(Entry.RelatedObject1, PEFilmObjectCommand(Command).Obj.SceneObject);
            ReleaseSpaceObject(PEFilmObjectCommand(Command).Obj.SceneObject);
            Break;
          end;
          Command := Command.Next;
        end;
      end;
      ReleaseSpaceObject(Obj.SceneObject);
    end
    else if Obj.SceneObject is THoleSE then
    begin
      Command := FirstTrailing;
      while Command <> nil do
      begin
        if (Command.Kind = efcReleaseObject) and (PEFilmObjectCommand(Command).Obj <> nil) and
          (PEFilmObjectCommand(Command).Obj.SceneObject = Obj.SceneObject) then
        begin
          Entry := AppendEntry;
          RetainSpaceObject(Entry.SceneObject, Obj.SceneObject);
          ReleaseSpaceObject(Obj.SceneObject);
          Break;
        end;
        Command := Command.Next;
      end;
    end;
    Obj := Obj.Next;
  end;
end;
{ @end $7D2860 }

{ @routine $7D2A38 TEFilmEnd_AdvanceEffects }
procedure TEFilmEnd.AdvanceEffects;
var NextEntry, Entry: PEFilmEndEntry;
begin
  NextEntry := FirstEntry;
  while NextEntry <> nil do
  begin
    Entry := NextEntry;
    NextEntry := NextEntry.Next;
    try
      Entry.SceneObject.Advance;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        AppendLogLineThreadSafe('Error in Event.Step');
        if Entry.SceneObject <> nil then
          AppendLogLineThreadSafe('event ' + Entry.SceneObject.ClassName + ' ' + Entry.SceneObject.GraphKey);
        if Entry.RelatedObject1 <> nil then
          AppendLogLineThreadSafe('obj ' + Entry.RelatedObject1.ClassName + ' ' + Entry.RelatedObject1.GraphKey);
        if Entry.RelatedObject2 <> nil then
          AppendLogLineThreadSafe('obj2 ' + Entry.RelatedObject2.ClassName + ' ' + Entry.RelatedObject2.GraphKey);
        raise Exception.Create('Error in TEFilmEnd.Run');
      end;
    end;
    if not Entry.SceneObject.IsAttachedToSpace then
    begin
      Entry.SceneObject.DetachFromSpace;
      ReleaseSpaceObject(Entry.SceneObject);
      if Entry.RelatedObject1 <> nil then
      begin
        Entry.RelatedObject1.DetachFromSpace;
        ReleaseSpaceObject(Entry.RelatedObject1);
      end;
      if Entry.RelatedObject2 <> nil then
      begin
        Entry.RelatedObject2.DetachFromSpace;
        ReleaseSpaceObject(Entry.RelatedObject2);
      end;
      RemoveEntry(Entry);
    end;
  end;
end;
{ @end $7D2A38 }

{ @routine $7D2E48 TEFilmEnd_ReleaseObjectReferences }
procedure TEFilmEnd.ReleaseObjectReferences(Obj: TObjectSE);
var Entry: PEFilmEndEntry;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if Entry.SceneObject <> nil then
      if Entry.SceneObject = Obj then ReleaseSpaceObject(Entry.SceneObject);
    if Entry.RelatedObject1 <> nil then
      if Entry.RelatedObject1 = Obj then ReleaseSpaceObject(Entry.RelatedObject1);
    if Entry.RelatedObject2 <> nil then
      if Entry.RelatedObject2 = Obj then ReleaseSpaceObject(Entry.RelatedObject2);
    Entry := Entry.Next;
  end;
end;
{ @end $7D2E48 }

{ @routine $7D2ED4 TEFilmEnd_RemoveLinkedWeaponEffects }
procedure TEFilmEnd.RemoveLinkedWeaponEffects;
var
  NextEntry, Entry: PEFilmEndEntry;
begin
  NextEntry := FirstEntry;
  while NextEntry <> nil do
  begin
    Entry := NextEntry;
    NextEntry := NextEntry.Next;
    if Entry.SceneObject is TWeaponSE then
      if (Entry.SceneObject as TWeaponSE).Projectile <> nil then RemoveEntry(Entry);
  end;
end;
{ @end $7D2ED4 }

end.
