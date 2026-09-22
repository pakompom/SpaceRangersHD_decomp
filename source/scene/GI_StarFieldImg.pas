unit GI_StarFieldImg;
// Unit bracket (inferred): .text 0x004B2478..0x004B38C5; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class ownership follows reference/unit_ownership.json.

interface

uses GI_MessageLoop, EC_BlockPar, EC_Struct, Types;

type
  TStarFieldImageGI = record // @size $4C
    TemplateIndex: Integer; // @offset $00
    FrameIndex: Integer; // @offset $04
    LastFrame: Integer; // @offset $08
    FramePosition: Single; // @offset $0C
    FrameStep: Single; // @offset $10
    Position: TPointF; // @offset $14
    Velocity: TPointF; // @offset $1C
    Acceleration: TPointF; // @offset $24
    Direction: TPointF; // @offset $2C
    ImageSize: TPoint; // @offset $34
    ImageOffset: TPoint; // @offset $3C Native positive half-size, added to the pixel position.
    PixelPosition: TPoint; // @offset $44
  end;
  PStarFieldImageGI = ^TStarFieldImageGI;

  TStarFieldImgGI = class(TObjectGI) // @size $158 Native VMT $4B24C4.
  public
    Stars: PStarFieldImageGI; // @offset $120
    StarCount: Integer; // @offset $124
    Capacity: Integer; // @offset $128
    ReservedDirty: Boolean; // @offset $12C Set by construction; no reads found in the native unit.
    FocusPoint: TPointF; // @offset $130 Stars accelerate away from this screen-space point.
    ViewPosition: TPointF; // @offset $138
    TargetHeading: Single; // @offset $140
    CurrentHeading: Single; // @offset $144
    TargetFocusDistance: Single; // @offset $148
    CurrentFocusDistance: Single; // @offset $14C
    MotionTicks: Integer; // @offset $150
    AnimationTimer: PCallbackTimerGI; // @offset $154

    procedure ClearStars; // @addr $4B26B0
    procedure GrowStars; // @addr $4B26F8 Adds 64 zeroed entries.
    function AllocateStar: PStarFieldImageGI; // @addr $4B2764
    procedure CopyStarsFrom(Source: TStarFieldImgGI); // @addr $4B27BC Copies particles only, not camera or timer state.
    procedure InitializeStar(Star: PStarFieldImageGI); // @addr $4B2848
    procedure AdvanceStars; // @addr $4B2D7C
    procedure RedirectStars; // @addr $4B2EE0
    procedure AnimateStars(Timer: PCallbackTimerGI; UserData: Integer); // @addr $4B3028
    procedure SetViewPosition(Position: TPointF); // @addr $4B32FC
    constructor Create(Owner: TObjectGI); // @addr $4B259C
    destructor Destroy; override; // @addr $4B264C
    procedure SeedStars; // @addr $4B2CF4 Clears/reseeds the animated image stars and advances 201 warm-up steps.
    procedure Invalidate; override; // @addr $4B3428
    procedure OnActivate; override; // @addr $4B34B8
    procedure OnDeactivate; override; // @addr $4B3520
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4B3560
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4B3594
    procedure ApplyStarConfig(Block: TBlockParEC); // @addr $4B35BC Native empty extension hook.
    procedure UpdateAutoGeometry; override; // @addr $4B35CC
    procedure Draw(ClipRect: TRect); override; // @addr $4B35D8
  end;

implementation

uses EC_Mem, EC_CacheGAI, GlobalsV, GR_Main, GR_Gi, GR_DX, Windows,
  Direct3D9, aMyFunction, Math;

{ @routine $4B259C TStarFieldImgGI_Create }
constructor TStarFieldImgGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ReservedDirty := True;
  FocusPoint := MakePointF(Cardinal(GameScreenWidth) / 2, Cardinal(GameScreenHeight) / 2);
end;
{ @end $4B259C }

{ @routine $4B264C TStarFieldImgGI_Destroy }
destructor TStarFieldImgGI.Destroy;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  ClearStars;
  inherited Destroy;
end;
{ @end $4B264C }

{ @routine $4B26B0 TStarFieldImgGI_ClearStars }
procedure TStarFieldImgGI.ClearStars;
begin
  if Stars <> nil then
  begin
    FreeEC(Stars);
    Stars := nil;
  end;
  StarCount := 0;
  Capacity := 0;
end;
{ @end $4B26B0 }

{ @routine $4B26F8 TStarFieldImgGI_GrowStars }
procedure TStarFieldImgGI.GrowStars;
var Tail: Pointer;
begin
  Inc(Capacity, 64);
  Stars := ReAllocREC(Stars, SizeOf(TStarFieldImageGI) * Capacity);
  Tail := AddPointerOffset(Stars, SizeOf(TStarFieldImageGI) * (Capacity - 64));
  FillChar(Tail^, SizeOf(TStarFieldImageGI) * 64, 0);
end;
{ @end $4B26F8 }

{ @routine $4B2764 TStarFieldImgGI_AllocateStar }
function TStarFieldImgGI.AllocateStar: PStarFieldImageGI;
begin
  Inc(StarCount);
  if StarCount > Capacity then GrowStars;
  Result := AddPointerOffset(Stars, SizeOf(TStarFieldImageGI) * (StarCount - 1));
end;
{ @end $4B2764 }

{ @routine $4B27BC TStarFieldImgGI_CopyStarsFrom }
procedure TStarFieldImgGI.CopyStarsFrom(Source: TStarFieldImgGI);
begin
  ClearStars;
  if Source.StarCount > 0 then
  begin
    StarCount := Source.StarCount;
    Capacity := StarCount;
    Stars := ReAllocREC(Stars, SizeOf(TStarFieldImageGI) * Capacity);
    CopyMemory(Stars, Source.Stars, SizeOf(TStarFieldImageGI) * StarCount);
  end;
end;
{ @end $4B27BC }

{ @routine $4B2848 TStarFieldImgGI_InitializeStar }
procedure TStarFieldImgGI.InitializeStar(Star: PStarFieldImageGI);
var
  Angle, DX, DY, Speed, Factor: Single;
  Data: TCGaiEC;
  Outside: Boolean;
  Intersection: TPointF;
begin
  if RandomIntRange(0, 1) = 0 then
  begin
    Star.Position.X := Random * (Cardinal(GameScreenWidth) - 1);
    Star.Position.Y := Random * (Cardinal(GameScreenHeight) - 1);
  end
  else
  begin
    Star.Position.X := Random * (Cardinal(GameScreenWidth) - 1) * 0.5 + Cardinal(GameScreenWidth) * 0.25;
    Star.Position.Y := Random * (Cardinal(GameScreenHeight) - 1) * 0.5 + Cardinal(GameScreenHeight) * 0.25;
  end;
  Outside := (FocusPoint.X < 0) or (FocusPoint.X >= Cardinal(GameScreenWidth)) or
    (FocusPoint.Y < 0) or (FocusPoint.Y >= Cardinal(GameScreenHeight));
  if Outside then
    if SegmentIntersectsRectEdges(MakePointF(Star.Position.X, Star.Position.Y), FocusPoint,
      MakePointF(0, 0), MakePointF(Cardinal(GameScreenWidth) - 1, Cardinal(GameScreenHeight) - 1), Intersection) then
    begin
      Factor := Random * 0.5 + 0.5;
      Star.Position.X := (Intersection.X - Star.Position.X) * Factor + Star.Position.X;
      Star.Position.Y := (Intersection.Y - Star.Position.Y) * Factor + Star.Position.Y;
    end;
  Star.PixelPosition.X := Round(Star.Position.X);
  Star.PixelPosition.Y := Round(Star.Position.Y);
  Factor := Random;
  Angle := ArcTan2(Star.Position.X - FocusPoint.X, -(Star.Position.Y - FocusPoint.Y));
  DX := Sin(Angle);
  DY := -Cos(Angle);
  Star.Direction.X := DX;
  Star.Direction.Y := DY;
  Speed := 0.25 * Factor + 0.05;
  if Outside then Speed := Speed * 4;
  Star.Velocity.X := DX * Speed;
  Star.Velocity.Y := DY * Speed;
  Speed := 0.15 * Factor + 0.05;
  if Outside then Speed := Speed * 2;
  Star.Acceleration.X := DX * Speed;
  Star.Acceleration.Y := DY * Speed;
  Star.TemplateIndex := RandomIntRange(0, High(StarFieldImageTemplates));
  Data := AcquireCachedGai(TCGaiControlEC(StarFieldImageTemplates[Star.TemplateIndex].CacheControl));
  try
    Star.ImageSize := Data.GetCanvasSize;
    Star.ImageOffset := HalfPoint(Star.ImageSize);
    Star.FrameIndex := 0;
    Star.FramePosition := 0;
    Star.LastFrame := Round((Data.GetSequenceFrameCount(0) - 1) * (Factor * 0.5 + 0.2));
    Star.FrameStep := (1 + Factor) * (Star.LastFrame / 100);
    if Outside then Star.FrameStep := Star.FrameStep * 4;
  finally
    TCGaiControlEC(StarFieldImageTemplates[Star.TemplateIndex].CacheControl).Release;
  end;
end;
{ @end $4B2848 }

{ @routine $4B2CF4 TStarFieldImgGI_SeedStars }
procedure TStarFieldImgGI.SeedStars;
var I, Count: Integer; Star: PStarFieldImageGI;
begin
  ClearStars;
  Count := 20;
  if Cardinal(GameScreenHeight) < 768 then Count := Round(Count * 0.6103515625);
  for I := 0 to Count - 1 do
  begin
    Star := AllocateStar;
    InitializeStar(Star);
  end;
  for I := 0 to 200 do AdvanceStars;
end;
{ @end $4B2CF4 }

{ @routine $4B2D7C TStarFieldImgGI_AdvanceStars }
procedure TStarFieldImgGI.AdvanceStars;
var Star: PStarFieldImageGI; I, X, Y: Integer;
begin
  Star := Stars;
  for I := 0 to StarCount - 1 do
  begin
    Star.Velocity.X := Star.Velocity.X + Star.Acceleration.X;
    Star.Velocity.Y := Star.Velocity.Y + Star.Acceleration.Y;
    Star.Position.X := Star.Position.X + Star.Velocity.X;
    Star.Position.Y := Star.Position.Y + Star.Velocity.Y;
    X := Round(Star.Position.X);
    Y := Round(Star.Position.Y);
    Star.PixelPosition.X := X;
    Star.PixelPosition.Y := Y;
    Star.FramePosition := Min(Star.LastFrame, Star.FramePosition + Star.FrameStep);
    Star.FrameIndex := Round(Star.FramePosition);
    if (X < HitTestBounds.Left - 30) or (X >= HitTestBounds.Right + 30) or
      (Y < HitTestBounds.Top - 30) or (Y >= HitTestBounds.Bottom + 30) then InitializeStar(Star);
    Star := AddPointerOffset(Star, SizeOf(TStarFieldImageGI));
  end;
end;
{ @end $4B2D7C }

{ @routine $4B2EE0 TStarFieldImgGI_RedirectStars }
procedure TStarFieldImgGI.RedirectStars;
var Star: PStarFieldImageGI; I: Integer; Distance, Speed, DY, DX: Single;
begin
  Star := Stars;
  for I := 0 to StarCount - 1 do
  begin
    DX := Star.Position.X - FocusPoint.X;
    DY := Star.Position.Y - FocusPoint.Y;
    Distance := Sqrt(DX * DX + DY * DY);
    DX := DX / Distance;
    DY := DY / Distance;
    Star.Direction.X := DX;
    Star.Direction.Y := DY;
    Speed := Sqrt(Star.Velocity.X * Star.Velocity.X + Star.Velocity.Y * Star.Velocity.Y);
    Star.Velocity.X := Speed * DX;
    Star.Velocity.Y := Speed * DY;
    Speed := Sqrt(Star.Acceleration.X * Star.Acceleration.X + Star.Acceleration.Y * Star.Acceleration.Y);
    Star.Acceleration.X := Speed * DX;
    Star.Acceleration.Y := Speed * DY;
    Star := AddPointerOffset(Star, SizeOf(TStarFieldImageGI));
  end;
end;
{ @end $4B2EE0 }

{ @routine $4B3028 TStarFieldImgGI_AnimateStars }
procedure TStarFieldImgGI.AnimateStars(Timer: PCallbackTimerGI; UserData: Integer);
var Delta: Single;
begin
  if StarCount > 0 then
  begin
    Dec(MotionTicks);
    if MotionTicks < 0 then
    begin
      TargetFocusDistance := 0;
      MotionTicks := 0;
    end;
    if (TargetHeading <> CurrentHeading) or (TargetFocusDistance <> CurrentFocusDistance) then
    begin
      Delta := HeadingDifferenceDegrees(CurrentHeading, TargetHeading);
      if Abs(Delta) <= 15 then CurrentHeading := TargetHeading
      else
      begin
        if Delta < 0 then CurrentHeading := WrapHeadingDegrees(CurrentHeading - 15)
        else if Delta > 0 then CurrentHeading := WrapHeadingDegrees(CurrentHeading + 15);
      end;
      if TargetFocusDistance < CurrentFocusDistance then
        CurrentFocusDistance := Max(TargetFocusDistance, CurrentFocusDistance - 150)
      else if TargetFocusDistance > CurrentFocusDistance then
        CurrentFocusDistance := Min(TargetFocusDistance, CurrentFocusDistance + 100);
      FocusPoint.X := Sin(HeadingDegreesToRadians(CurrentHeading)) * CurrentFocusDistance + Cardinal(GameScreenWidth) / 2;
      FocusPoint.Y := Cardinal(GameScreenHeight) / 2 - Cos(HeadingDegreesToRadians(CurrentHeading)) * CurrentFocusDistance;
      RedirectStars;
    end;
    AdvanceStars;
    Invalidate;
  end;
end;
{ @end $4B3028 }

{ @routine $4B32FC TStarFieldImgGI_SetViewPosition }
procedure TStarFieldImgGI.SetViewPosition(Position: TPointF);
var DY, DX: Single;
begin
  DX := Position.X - ViewPosition.X;
  DY := Position.Y - ViewPosition.Y;
  if DY * DY + DX * DX >= 25 then
  begin
    if (DX <> 0) or (DY <> 0) then
    begin
      TargetHeading := RadiansToHeadingDegrees(ArcTan2(DX, -DY));
      if CurrentFocusDistance = 0 then CurrentFocusDistance := TargetFocusDistance;
      if Cardinal(GameScreenHeight) >= 768 then TargetFocusDistance := 3000
      else TargetFocusDistance := 2050;
      MotionTicks := 5;
      RedirectStars;
    end;
    ViewPosition := Position;
  end;
end;
{ @end $4B32FC }

{ @routine $4B3428 TStarFieldImgGI_Invalidate }
procedure TStarFieldImgGI.Invalidate;
var Star: PStarFieldImageGI; I: Integer; Bounds: TRect;
begin
  Star := Stars;
  for I := 0 to StarCount - 1 do
  begin
    Bounds.Left := Star.PixelPosition.X + Star.ImageOffset.X;
    Bounds.Top := Star.PixelPosition.Y + Star.ImageOffset.Y;
    Bounds.Right := Bounds.Left + Star.ImageSize.X;
    Bounds.Bottom := Bounds.Top + Star.ImageSize.Y;
    MessageLoop.QueueUpdateRect(Bounds);
    Star := AddPointerOffset(Star, SizeOf(TStarFieldImageGI));
  end;
end;
{ @end $4B3428 }

{ @routine $4B34B8 TStarFieldImgGI_OnActivate }
procedure TStarFieldImgGI.OnActivate;
begin
  inherited OnActivate;
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  AnimationTimer := MessageLoop.ScheduleCallbackTimer(50, 50, AnimateStars);
end;
{ @end $4B34B8 }

{ @routine $4B3520 TStarFieldImgGI_OnDeactivate }
procedure TStarFieldImgGI.OnDeactivate;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  inherited OnDeactivate;
end;
{ @end $4B3520 }

{ @routine $4B3560 TStarFieldImgGI_LoadFromConfigPath }
procedure TStarFieldImgGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  ApplyStarConfig(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B3560 }

{ @routine $4B3594 TStarFieldImgGI_LoadFromBlock }
procedure TStarFieldImgGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  ApplyStarConfig(Block);
end;
{ @end $4B3594 }

{ @routine $4B35BC TStarFieldImgGI_ApplyStarConfig }
procedure TStarFieldImgGI.ApplyStarConfig(Block: TBlockParEC);
begin
end;
{ @end $4B35BC }

{ @routine $4B35CC TStarFieldImgGI_UpdateAutoGeometry }
procedure TStarFieldImgGI.UpdateAutoGeometry;
begin
end;
{ @end $4B35CC }

{ @routine $4B35D8 TStarFieldImgGI_Draw }
procedure TStarFieldImgGI.Draw(ClipRect: TRect);
var Star: PStarFieldImageGI; I: Integer; Data: TCGaiEC; Frame: TgiGR;
    Origin: TPoint; Bounds, Intersection: TRect;
begin
  for I := 0 to High(StarFieldImageTemplates) do StarFieldImageTemplates[I].CachedData := nil;
  try
    for I := 0 to High(StarFieldImageTemplates) do
      StarFieldImageTemplates[I].CachedData := AcquireCachedGai(TCGaiControlEC(StarFieldImageTemplates[I].CacheControl));
    Star := Stars;
    for I := 0 to StarCount - 1 do
    begin
      Bounds.Left := Star.PixelPosition.X + Star.ImageOffset.X;
      Bounds.Top := Star.PixelPosition.Y + Star.ImageOffset.Y;
      Bounds.Right := Bounds.Left + Star.ImageSize.X;
      Bounds.Bottom := Bounds.Top + Star.ImageSize.Y;
      if IntersectRects(Intersection, Bounds, ClipRect) then
      begin
        Data := TCGaiEC(StarFieldImageTemplates[Star.TemplateIndex].CachedData);
        if HardwareRenderingEnabled then
        begin
          Origin := Data.GetFrameOrigin(Data.GetSequenceFrameIndex(0, Star.FrameIndex));
          DrawTexture(Data.GetOrCreateFrameSurface(Data.GetSequenceFrameIndex(0, Star.FrameIndex)),
            Origin.X + Bounds.Left, Origin.Y + Bounds.Top, 255, RgbWhite, @ClipRect, False, False);
        end
        else
        begin
          Frame := Data.LoadFrameGi(Data.GetSequenceFrameIndex(0, Star.FrameIndex));
          Frame.DrawToGraphBuf(ScreenRenderBuffer,
            Bounds.Left + Frame.GetBoundsRect.Left - Data.GetBoundsRect.Left,
            Bounds.Top + Frame.GetBoundsRect.Top - Data.GetBoundsRect.Top, ClipRect, 0, 255);
        end;
      end;
      Star := AddPointerOffset(Star, SizeOf(TStarFieldImageGI));
    end;
  finally
    for I := 0 to High(StarFieldImageTemplates) do
      if TCGaiEC(StarFieldImageTemplates[I].CachedData) <> nil then
      begin
        TCGaiControlEC(StarFieldImageTemplates[I].CacheControl).Release;
        StarFieldImageTemplates[I].CachedData := nil;
      end;
  end;
end;
{ @end $4B35D8 }

end.
