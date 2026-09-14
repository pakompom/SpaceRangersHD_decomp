unit GI_StarFieldM;
// Unit bracket (inferred): .text 0x0047D890..0x0047E9A5; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, GI_MessageLoop, GI_Panel, Types;

type
  // Native constructor allocates $400 bytes at $47DA3B and iterates 32 colors
  // per row and 16 rows at $47DADB/$47DAE8. Palette reads retain native helpers.
  TMovingStarPalette = array[0..31] of Word;
  TMovingStarColorTable = array[0..15] of TMovingStarPalette;
  PMovingStarColorTable = ^TMovingStarColorTable;

  TMovingStarPixel = record // @size $4C
    ByteOffset: Integer; // @offset $00
    PreviousByteOffset: Integer; // @offset $04
    SavedPixel: Word; // @offset $10
    Position: TPointF; // @offset $14
    Velocity: TPointF; // @offset $1C
    Acceleration: TPointF; // @offset $24
    Direction: TPointF; // @offset $2C
    PixelPosition: TPoint; // @offset $34
    PaletteIndex: Integer; // @offset $3C
    Color: Word; // @offset $40
    ColorPosition: Single; // @offset $44
    ColorStep: Single; // @offset $48
  end;
  PMovingStarPixel = ^TMovingStarPixel;

  TStarFieldMGI = class(TPanelGI) // @size $178 Native VMT $47D8DC.
  public
    Stars: PMovingStarPixel; // @offset $140
    StarCount: Integer; // @offset $144
    Capacity: Integer; // @offset $148
    FocusPoint: TPointF; // @offset $14C
    ViewPosition: TPointF; // @offset $154
    TargetHeading: Single; // @offset $15C
    CurrentHeading: Single; // @offset $160
    TargetFocusDistance: Single; // @offset $164
    CurrentFocusDistance: Single; // @offset $168
    MotionTicks: Integer; // @offset $16C
    AnimationTimer: PCallbackTimerGI; // @offset $170
    ColorTable: PMovingStarColorTable; // @offset $174 Owns sixteen rows of 32 RGB words; initialization currently selects row zero.

    constructor Create(Owner: TObjectGI); // @addr $47D9B8 @ida "TStarFieldMGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $47DB24 @ida "void __usercall $name(TStarFieldMGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure OnActivate; override; // @addr $47DBB0
    procedure OnDeactivate; override; // @addr $47DC10
    procedure ClearStars; // @addr $47DC48
    procedure GrowStars; // @addr $47DC90
    function AllocateStar: PMovingStarPixel; // @addr $47DCFC
    procedure InitializeStar(Star: PMovingStarPixel); // @addr $47DD54
    procedure SeedStars; // @addr $47DF28
    procedure AdvanceStars; // @addr $47DF90
    procedure RedirectStars; // @addr $47E11C
    procedure AnimateStars(Timer: PCallbackTimerGI; UserData: Integer); // @addr $47E264
    procedure SetViewPosition(Position: TPointF); // @addr $47E538 @ida "void __usercall $name(TStarFieldMGI *Self@<eax>, TPointF *Position@<edx>);"
    procedure Invalidate; override; // @addr $47E664
    procedure ErasePreviousFrame; override; // @addr $47E670
    procedure PrepareFrameDraw; override; // @addr $47E778
    procedure DrawUpdateRects(ClipRect: TRect); override; // @addr $47E828 @ida "void __usercall $name(TStarFieldMGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure Draw(ClipRect: TRect); override; // @addr $47E870 @ida "void __usercall $name(TStarFieldMGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure CommitFrameDraw; override; // @addr $47E94C
  end;

implementation

uses Classes, EC_Mem, aMyFunction, Math, GR_Main, GlobalsV, GR_DX;

{ @routine $47D9B8 TStarFieldMGI_Create }
constructor TStarFieldMGI.Create(Owner: TObjectGI);
var I, J: Integer;
begin
  inherited Create(Owner);
  FocusPoint := MakePointF(Cardinal(GameScreenWidth) / 2, Cardinal(GameScreenHeight) / 2);
  ColorTable := AllocEC(SizeOf(ColorTable^));
  for I := Low(ColorTable^) to High(ColorTable^) do
    for J := Low(TMovingStarPalette) to High(TMovingStarPalette) do
      WriteWordEC(AddPointerOffset(ColorTable, I * Length(ColorTable^[I]) * SizeOf(Word) + J * SizeOf(Word)),
        CurrentPixelFormat.PackNormalizedRgb(Random * 0.5 + 0.5, Random * 0.5 + 0.5, Random * 0.5 + 0.5));
  SeedStars;
end;
{ @end $47D9B8 }

{ @routine $47DB24 TStarFieldMGI_Destroy }
destructor TStarFieldMGI.Destroy;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  if ColorTable <> nil then
  begin
    FreeEC(ColorTable);
    ColorTable := nil;
  end;
  ClearStars;
  inherited Destroy;
end;
{ @end $47DB24 }

{ @routine $47DBB0 TStarFieldMGI_OnActivate }
procedure TStarFieldMGI.OnActivate;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  AnimationTimer := MessageLoop.ScheduleCallbackTimer(50, 50, AnimateStars);
end;
{ @end $47DBB0 }

{ @routine $47DC10 TStarFieldMGI_OnDeactivate }
procedure TStarFieldMGI.OnDeactivate;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
end;
{ @end $47DC10 }

{ @routine $47DC48 TStarFieldMGI_ClearStars }
procedure TStarFieldMGI.ClearStars;
begin
  if Stars <> nil then
  begin
    FreeEC(Stars);
    Stars := nil;
  end;
  StarCount := 0;
  Capacity := 0;
end;
{ @end $47DC48 }

{ @routine $47DC90 TStarFieldMGI_GrowStars }
procedure TStarFieldMGI.GrowStars;
var Tail: Pointer;
begin
  Inc(Capacity, 64);
  Stars := ReAllocREC(Stars, SizeOf(TMovingStarPixel) * Capacity);
  Tail := AddPointerOffset(Stars, SizeOf(TMovingStarPixel) * (Capacity - 64));
  FillChar(Tail^, SizeOf(TMovingStarPixel) * 64, 0);
end;
{ @end $47DC90 }

{ @routine $47DCFC TStarFieldMGI_AllocateStar }
function TStarFieldMGI.AllocateStar: PMovingStarPixel;
begin
  Inc(StarCount);
  if StarCount > Capacity then GrowStars;
  Result := AddPointerOffset(Stars, SizeOf(TMovingStarPixel) * (StarCount - 1));
end;
{ @end $47DCFC }

{ @routine $47DD54 TStarFieldMGI_InitializeStar }
procedure TStarFieldMGI.InitializeStar(Star: PMovingStarPixel);
var Angle, DX, DY, Speed, Factor: Single;
begin
  Star.Position.X := Random * (Cardinal(GameScreenWidth) - 1);
  Star.Position.Y := Random * (Cardinal(GameScreenHeight) - 1);
  Star.PixelPosition.X := Round(Star.Position.X);
  Star.PixelPosition.Y := Round(Star.Position.Y);
  Factor := Random;
  Angle := ArcTan2(Star.Position.X - FocusPoint.X, -(Star.Position.Y - FocusPoint.Y));
  DX := Sin(Angle);
  DY := -Cos(Angle);
  Star.Direction.X := DX;
  Star.Direction.Y := DY;
  Speed := 0.5 * Factor + 0.1;
  Star.Velocity.X := DX * Speed;
  Star.Velocity.Y := DY * Speed;
  Speed := 0.3 * Factor + 0.1;
  Star.Acceleration.X := DX * Speed;
  Star.Acceleration.Y := DY * Speed;
  Star.ColorPosition := 0;
  Star.ColorStep := 4 * Factor + 2;
  Star.PaletteIndex := 0;
  Star.Color := ReadWordEC(AddPointerOffset(ColorTable, Star.PaletteIndex * Length(ColorTable^[0]) * SizeOf(Word) + Round(Star.ColorPosition) * SizeOf(Word)));
end;
{ @end $47DD54 }

{ @routine $47DF28 TStarFieldMGI_SeedStars }
procedure TStarFieldMGI.SeedStars;
var I, Count: Integer; Star: PMovingStarPixel;
begin
  Count := 50;
  if Cardinal(GameScreenHeight) < 768 then Count := Round(Count * 0.6103515625);
  for I := 0 to Count - 1 do
  begin
    Star := AllocateStar;
    InitializeStar(Star);
  end;
end;
{ @end $47DF28 }

{ @routine $47DF90 TStarFieldMGI_AdvanceStars }
procedure TStarFieldMGI.AdvanceStars;
var Star: PMovingStarPixel; I, X, Y: Integer;
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
    if (X < HitTestBounds.Left) or (X >= HitTestBounds.Right) or
      (Y < HitTestBounds.Top) or (Y >= HitTestBounds.Bottom) then InitializeStar(Star);
    if Star.ColorPosition < High(TMovingStarPalette) then
    begin
      Star.ColorPosition := Star.ColorPosition + Star.ColorStep;
      if Star.ColorPosition > High(TMovingStarPalette) then
      begin
        Star.ColorPosition := High(TMovingStarPalette);
        Star.ColorStep := 0;
      end;
      Star.Color := ReadWordEC(AddPointerOffset(ColorTable, Star.PaletteIndex * Length(ColorTable^[0]) * SizeOf(Word) + Round(Star.ColorPosition) * SizeOf(Word)));
    end;
    Star := AddPointerOffset(Star, SizeOf(TMovingStarPixel));
  end;
end;
{ @end $47DF90 }

{ @routine $47E11C TStarFieldMGI_RedirectStars }
procedure TStarFieldMGI.RedirectStars;
var Star: PMovingStarPixel; I: Integer; Distance, Speed, DY, DX: Single;
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
    Star := AddPointerOffset(Star, SizeOf(TMovingStarPixel));
  end;
end;
{ @end $47E11C }

{ @routine $47E264 TStarFieldMGI_AnimateStars }
procedure TStarFieldMGI.AnimateStars(Timer: PCallbackTimerGI; UserData: Integer);
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
        CurrentFocusDistance := Max(TargetFocusDistance, CurrentFocusDistance - 90)
      else if TargetFocusDistance > CurrentFocusDistance then
        CurrentFocusDistance := Min(TargetFocusDistance, CurrentFocusDistance + 60);
      FocusPoint.X := Sin(HeadingDegreesToRadians(CurrentHeading)) * CurrentFocusDistance + Cardinal(GameScreenWidth) / 2;
      FocusPoint.Y := Cardinal(GameScreenHeight) / 2 - Cos(HeadingDegreesToRadians(CurrentHeading)) * CurrentFocusDistance;
      RedirectStars;
    end;
    AdvanceStars;
    Invalidate;
  end;
end;
{ @end $47E264 }

{ @routine $47E538 TStarFieldMGI_SetViewPosition }
procedure TStarFieldMGI.SetViewPosition(Position: TPointF);
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
      if Cardinal(GameScreenHeight) >= 768 then TargetFocusDistance := 1800
      else TargetFocusDistance := 1230;
      MotionTicks := 5;
      RedirectStars;
    end;
    ViewPosition := Position;
  end;
end;
{ @end $47E538 }

{ @routine $47E664 TStarFieldMGI_Invalidate }
procedure TStarFieldMGI.Invalidate;
begin
end;
{ @end $47E664 }

{ @routine $47E670 TStarFieldMGI_ErasePreviousFrame }
procedure TStarFieldMGI.ErasePreviousFrame;
var Star: PMovingStarPixel; Buffer: Pointer; I: Integer;
begin
  if not HardwareRenderingEnabled then
  begin
    Buffer := ScreenRenderBuffer.GetPixels;
    if not SkipSavedPixelRestore then
    begin
      if not BGImage then
      begin
        Star := Stars;
        for I := 0 to StarCount - 1 do
        begin
          WriteWordEC(AddPointerOffset(Buffer, Star.PreviousByteOffset), 0);
          Star := AddPointerOffset(Star, SizeOf(TMovingStarPixel));
        end;
      end
      else
      begin
        Star := Stars;
        for I := 0 to StarCount - 1 do
        begin
          WriteWordEC(AddPointerOffset(Buffer, Star.PreviousByteOffset), Star.SavedPixel);
          Star := AddPointerOffset(Star, SizeOf(TMovingStarPixel));
        end;
      end;
    end;
  end;
end;
{ @end $47E670 }

{ @routine $47E778 TStarFieldMGI_PrepareFrameDraw }
procedure TStarFieldMGI.PrepareFrameDraw;
var Star: PMovingStarPixel; I: Integer; Buffer: Pointer;
begin
  if not HardwareRenderingEnabled then
  begin
    Buffer := ScreenRenderBuffer.GetPixels;
    Star := Stars;
    I := StarCount;
    while I > 0 do
    begin
      Star.ByteOffset := Star.PixelPosition.X * 2 + Star.PixelPosition.Y * ScreenRenderBuffer.PitchBytes;
      if BGImage then Star.SavedPixel := ReadWordEC(AddPointerOffset(Buffer, Star.ByteOffset));
      Star := AddPointerOffset(Star, SizeOf(TMovingStarPixel));
      Dec(I);
    end;
  end;
end;
{ @end $47E778 }

{ @routine $47E828 TStarFieldMGI_DrawUpdateRects }
procedure TStarFieldMGI.DrawUpdateRects(ClipRect: TRect);
begin
  Draw(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
end;
{ @end $47E828 }

{ @routine $47E870 TStarFieldMGI_Draw }
procedure TStarFieldMGI.Draw(ClipRect: TRect);
var Pixel: PMovingStarPixel; Count: Integer; Buffer: Pointer;
begin
  Pixel := Stars;
  Count := StarCount;
  if HardwareRenderingEnabled then
  begin
    while Count > 0 do
    begin
      QueueDrawPoint(Pixel.PixelPosition.X, Pixel.PixelPosition.Y, Color565ToArgb(Pixel.Color), 255);
      Pixel := AddPointerOffset(Pixel, SizeOf(TMovingStarPixel));
      Dec(Count);
    end;
    FlushDrawPoints(nil);
  end
  else
  begin
    Buffer := ScreenRenderBuffer.GetPixels;
    while Count > 0 do
    begin
      WriteWordEC(AddPointerOffset(Buffer, Pixel.ByteOffset), Pixel.Color);
      Pixel := AddPointerOffset(Pixel, SizeOf(TMovingStarPixel));
      Dec(Count);
    end;
  end;
end;
{ @end $47E870 }

{ @routine $47E94C TStarFieldMGI_CommitFrameDraw }
procedure TStarFieldMGI.CommitFrameDraw;
var Star: PMovingStarPixel; I: Integer;
begin
  if not HardwareRenderingEnabled then
  begin
    Star := Stars;
    I := StarCount;
    while I > 0 do
    begin
      Star.PreviousByteOffset := Star.ByteOffset;
      Star := AddPointerOffset(Star, SizeOf(TMovingStarPixel));
      Dec(I);
    end;
  end;
end;
{ @end $47E94C }

end.
