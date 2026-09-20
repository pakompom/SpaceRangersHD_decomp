unit ab_WorldImage;
// Unit bracket (inferred): .text 0x0055667C..0x00556EA7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Grouped by native diagnostic prefix; original source-unit boundaries remain unresolved.

interface

uses EC_Struct, GI_Image;

const
  // ab_WorldImage_Update ($5569E8) applies these only when Dirty is set.
  // Other values, and ordinary front/back switches, preserve the current frame.
  afmRestart = 0;
  afmRandomStart = 1;

type
  PabWorldImage = ^TabWorldImage;
  TabWorldImage = record // @size $40
    Prev: PabWorldImage; // @offset $00
    Next: PabWorldImage; // @offset $04
    Position: TVector3D; // @offset $08
    Image: TImageGI; // @offset $20
    FrontImagePath: WideString; // @offset $24
    BackImagePath: WideString; // @offset $28
    FrontDepth: Single; // @offset $2C
    BackDepth: Single; // @offset $30
    Dirty: Boolean; // @offset $34
    FrameMode: Integer; // @offset $38  afm* behavior when refreshed; stored as an Integer.
    LoopAnimation: Boolean; // @offset $3C
    Finished: Boolean; // @offset $3D
    StopAnimation: Boolean; // @offset $3E
  end;

procedure ab_WorldImage_Clear; // @addr $55667C
function ab_WorldImage_Add: PabWorldImage; // @addr $5566B0 @note "Allocates and links a node owned by the world list."
procedure ab_WorldImage_Delete(Entry: PabWorldImage); // @addr $556778
function ab_WorldImage_Create(Position: TVector3D; const FrontPath, BackPath: WideString; StopAnimation: Boolean): PabWorldImage; // @addr $556820
procedure ab_WorldImage_Set(Entry: PabWorldImage; Position: TVector3D; const FrontPath, BackPath: WideString); // @addr $5568C4
procedure ab_WorldImage_SetPosition(Entry: PabWorldImage; Position: TVector3D); // @addr $55694C
procedure ab_WorldImage_SetDepth(Entry: PabWorldImage; FrontDepth, BackDepth: Single); // @addr $55697C
procedure ab_WorldImage_SetFrameMode(Entry: PabWorldImage; Value: Integer); // @addr $5569A4
procedure ab_WorldImage_SetLooping(Entry: PabWorldImage; Value: Boolean); // @addr $5569C0
procedure ab_WorldImage_Update; // @addr $5569E8

var
  WorldImageHeap: Cardinal = 0; // @addr $87AF54
  FirstWorldImage: PabWorldImage = nil; // @addr $87AF58
  LastWorldImage: PabWorldImage = nil; // @addr $87AF5C

implementation

uses Windows, Classes, SysUtils, EC_Mem, GI_Tail, ab_Global, Globals, aMyFunction;

{ @routine $55667C ab_WorldImage_Clear }
procedure ab_WorldImage_Clear;
begin
  while not (FirstWorldImage = nil) do ab_WorldImage_Delete(LastWorldImage);
  if WorldImageHeap <> 0 then
  begin
    HeapDestroy(WorldImageHeap);
    WorldImageHeap := 0;
  end;
end;
{ @end $55667C }

{ @routine $5566B0 ab_WorldImage_Add }
function ab_WorldImage_Add: PabWorldImage;
var
  Entry: PabWorldImage;
begin
  if WorldImageHeap = 0 then
  begin
    WorldImageHeap := HeapCreate(1, $8000, 0);
    if WorldImageHeap = 0 then raise Exception.Create('ab_WorldImage_Add.HeapCreate');
  end;
  Entry := AllocClearFromHeapEC(WorldImageHeap, SizeOf(TabWorldImage));
  if LastWorldImage <> nil then LastWorldImage.Next := Entry;
  Entry.Prev := LastWorldImage;
  Entry.Next := nil;
  LastWorldImage := Entry;
  if FirstWorldImage = nil then FirstWorldImage := Entry;
  Result := Entry;
end;
{ @end $5566B0 }

{ @routine $556778 ab_WorldImage_Delete }
procedure ab_WorldImage_Delete(Entry: PabWorldImage);
begin
  if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
  if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
  if LastWorldImage = Entry then LastWorldImage := Entry.Prev;
  if FirstWorldImage = Entry then FirstWorldImage := Entry.Next;
  if Entry.Image <> nil then
  begin
    Entry.Image.Free;
    Entry.Image := nil;
  end;
  Entry.FrontImagePath := '';
  Entry.BackImagePath := '';
  if WorldImageHeap <> 0 then FreeFromHeapEC(WorldImageHeap, Entry);
end;
{ @end $556778 }

{ @routine $556820 ab_WorldImage_Create }
function ab_WorldImage_Create(Position: TVector3D; const FrontPath, BackPath: WideString; StopAnimation: Boolean): PabWorldImage;
var
  Entry: PabWorldImage;
begin
  Entry := ab_WorldImage_Add;
  Entry.Position := Position;
  Entry.FrontImagePath := FrontPath;
  Entry.BackImagePath := BackPath;
  Entry.Dirty := True;
  Entry.LoopAnimation := True;
  Entry.Finished := False;
  Entry.FrontDepth := WorldImageFrontDepth;
  Entry.BackDepth := WorldImageBackDepth;
  Entry.FrameMode := afmRestart;
  Entry.StopAnimation := StopAnimation;
  Result := Entry;
end;
{ @end $556820 }

{ @routine $5568C4 ab_WorldImage_Set }
procedure ab_WorldImage_Set(Entry: PabWorldImage; Position: TVector3D; const FrontPath, BackPath: WideString);
begin
  Entry.Position := Position;
  Entry.FrontImagePath := FrontPath;
  Entry.BackImagePath := BackPath;
  Entry.LoopAnimation := True;
  Entry.Finished := False;
  Entry.FrontDepth := WorldImageFrontDepth;
  Entry.BackDepth := WorldImageBackDepth;
  Entry.FrameMode := afmRestart;
  Entry.Dirty := True;
end;
{ @end $5568C4 }

{ @routine $55694C ab_WorldImage_SetPosition }
procedure ab_WorldImage_SetPosition(Entry: PabWorldImage; Position: TVector3D);
begin
  Entry.Position := Position;
end;
{ @end $55694C }

{ @routine $55697C ab_WorldImage_SetDepth }
procedure ab_WorldImage_SetDepth(Entry: PabWorldImage; FrontDepth, BackDepth: Single);
begin
  Entry.FrontDepth := FrontDepth;
  Entry.BackDepth := BackDepth;
  Entry.Dirty := True;
end;
{ @end $55697C }

{ @routine $5569A4 ab_WorldImage_SetFrameMode }
procedure ab_WorldImage_SetFrameMode(Entry: PabWorldImage; Value: Integer);
begin
  Entry.FrameMode := Value;
end;
{ @end $5569A4 }

{ @routine $5569C0 ab_WorldImage_SetLooping }
procedure ab_WorldImage_SetLooping(Entry: PabWorldImage; Value: Boolean);
begin
  Entry.LoopAnimation := Value;
  Entry.Dirty := True;
  Entry.StopAnimation := False;
end;
{ @end $5569C0 }

{ @routine $5569E8 ab_WorldImage_Update }
procedure ab_WorldImage_Update;
var
  Entry: PabWorldImage;
  Frame: Integer;
  Position, Center: TVector3D;
begin
  Center := MakeVector3D(0, 0, 0);
  Center := ProjectPointByMatrix(SphereProjectionMatrix, Center);
  Entry := FirstWorldImage;
  while Entry <> nil do
  begin
    if Entry.Finished then
    begin
      if Entry.Image <> nil then Entry.Image.SetActive(False);
      Entry := Entry.Next;
      Continue;
    end;
    Position := ProjectPointByMatrix(SphereProjectionMatrix, Entry.Position);
    if Entry.Image = nil then Entry.Image := TImageGI.Create(ArcadeBattleScreen.WorldPanel);
    Frame := 0;
    if Entry.Image.GaiImageControl <> nil then Frame := Entry.Image.GaiImageControl.SequenceFrame;
    if not IsDepthBeforeSphereHorizon(Position.Z) then
    begin
      if (Entry.Image.Depth <> Entry.BackDepth) or Entry.Dirty then
      begin
        Entry.Image.SetActive(Entry.BackImagePath <> '');
        if Entry.Image.Active then
        begin
          Entry.Image.SetImagePath(Entry.BackImagePath);
          Entry.Image.SetSize(Entry.Image.GetContentSize);
          Entry.Image.SetOrigin(HalfPoint(Entry.Image.ClientSize));
          if (Entry.Image.GaiImageControl <> nil) and not Entry.StopAnimation then
          begin
            Entry.Image.GaiImageControl.UserValue := Integer(Entry);
            if not Entry.LoopAnimation then Entry.Image.GaiImageControl.CycleCompleteCallback := ArcadeBattleScreen.WorldImageCycleComplete
            else Entry.Image.GaiImageControl.CycleCompleteCallback := nil;
            if (Entry.FrameMode = afmRestart) and Entry.Dirty then Entry.Image.GaiImageControl.SetSequenceFrame(0)
            else if (Entry.FrameMode = afmRandomStart) and Entry.Dirty then
              Entry.Image.GaiImageControl.SetSequenceFrame(RandomIntRange(0, Entry.Image.GaiImageControl.SequenceFrameCount - 1))
            else Entry.Image.GaiImageControl.SetSequenceFrame(Frame);
            Entry.Image.RestartPlayback;
          end
          else Entry.Image.StopPlayback;
        end;
        Entry.Image.SetDepth(Entry.BackDepth);
      end;
    end
    else
    begin
      if (Entry.Image.Depth <> Entry.FrontDepth) or Entry.Dirty then
      begin
        Entry.Image.SetActive(Entry.FrontImagePath <> '');
        if Entry.Image.Active then
        begin
          Entry.Image.SetImagePath(Entry.FrontImagePath);
          Entry.Image.SetSize(Entry.Image.GetContentSize);
          Entry.Image.SetOrigin(HalfPoint(Entry.Image.ClientSize));
          if (Entry.Image.GaiImageControl <> nil) and not Entry.StopAnimation then
          begin
            Entry.Image.GaiImageControl.UserValue := Integer(Entry);
            if not Entry.LoopAnimation then Entry.Image.GaiImageControl.CycleCompleteCallback := ArcadeBattleScreen.WorldImageCycleComplete
            else Entry.Image.GaiImageControl.CycleCompleteCallback := nil;
            if (Entry.FrameMode = afmRestart) and Entry.Dirty then Entry.Image.GaiImageControl.SetSequenceFrame(0)
            else if (Entry.FrameMode = afmRandomStart) and Entry.Dirty then
              Entry.Image.GaiImageControl.SetSequenceFrame(RandomIntRange(0, Entry.Image.GaiImageControl.SequenceFrameCount - 1))
            else Entry.Image.GaiImageControl.SetSequenceFrame(Frame);
            Entry.Image.RestartPlayback;
          end
          else Entry.Image.StopPlayback;
        end;
        Entry.Image.SetDepth(Entry.FrontDepth);
      end;
    end;
    Entry.Dirty := False;
    Entry.Image.SetPosition(Classes.Point(Round(Position.X), Round(Position.Y)));
    Entry := Entry.Next;
  end;
end;
{ @end $5569E8 }

end.
