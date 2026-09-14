unit GI_PSEyes;
// Unit bracket (inferred): .text 0x004EE16C..0x004EF8E7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native eye/lightning effect, particles and dormant line-list storage.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PEyesParticle = ^TEyesParticle;
  TEyesParticle = record // @size $2C
    Prev: PEyesParticle; // @offset $00
    Next: PEyesParticle; // @offset $04
    Origin: TPointF; // @offset $08
    Position: TPointF; // @offset $10
    Color: Word; // @offset $18
    Alpha: Byte; // @offset $1A
    Velocity: TPointF; // @offset $1C
    State: Byte; // @offset $24
    Countdown: Integer; // @offset $28
  end;
  PEyesLine = ^TEyesLine;
  TEyesLine = packed record // @size $9C
    Next: PEyesLine; // @offset $00
    First: TPoint; // @offset $08
    Last: TPoint; // @offset $10
    Color: Word; // @offset $18
    // Other native line-cache fields are unused by this renderer.
    Alpha: Byte; // @offset $9B
  end;

  TPSEyesGI = class(TPSWeaponGI) // @size $15C
  public
    HalfWidth: Integer; // @offset $130
    FirstParticle: PEyesParticle; // @offset $134
    LastParticle: PEyesParticle; // @offset $138
    FirstLine: PEyesLine; // @offset $13C
    LastLine: PEyesLine; // @offset $140
    ProjectionBounds: TRect; // @offset $144
    PrimaryColor: Word; // @offset $154
    SecondaryColor: Word; // @offset $156
    BeamTicks: Integer; // @offset $158

    constructor Create(Owner: TObjectGI); // @addr $4EE298 @ida "TPSEyesGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $4EE398 @ida "void __usercall $name(TPSEyesGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetPosition(Position: TPoint); override; // @addr $4EE3EC @ida "void __usercall $name(TPSEyesGI *Self@<eax>, TPoint *Position@<edx>);"
    procedure SetTargetPoint(Point: TPoint); override; // @addr $4EE430 @ida "void __usercall $name(TPSEyesGI *Self@<eax>, TPoint *Point@<edx>);"
    procedure UpdateProjectionBounds; // @addr $4EE484
    procedure UpdateHitTestBounds; override; // @addr $4EE7A0
    function GetLocalBounds: TRect; override; // @addr $4EE800 @ida "void __usercall $name(TPSEyesGI *Self@<eax>, TRect *Result@<edx>);"
    function AddParticle: PEyesParticle; // @addr $4EE864
    procedure ClearParticles; // @addr $4EE8DC
    procedure ClearLines; // @addr $4EE930
    procedure EmitBurst(Point: TPoint; Radius: Integer); // @addr $4EEA74 @ida "void __usercall $name(TPSEyesGI *Self@<eax>, TPoint *Point@<edx>, int Radius@<ecx>);"
    procedure Invalidate; override; // @addr $4EE984 @note "Native empty override."
    procedure InvalidateRect(Rect: TRect); override; // @addr $4EE990 @ida "void __usercall $name(TPSEyesGI *Self@<eax>, TRect *Rect@<edx>);"
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $4EEC6C
    procedure Draw(ClipRect: TRect); override; // @addr $4EEE9C @ida "void __usercall $name(TPSEyesGI *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

implementation

uses SysUtils, Classes, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $4EE298 TPSEyesGI_Create }
constructor TPSEyesGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  HalfWidth := 32;
  RemainingTicks := 60;
  LifetimeTicks := RemainingTicks;
  PrimaryColor := CurrentPixelFormat.PackNormalizedRgb(0.9, 0.7, 1.0);
  SecondaryColor := CurrentPixelFormat.PackNormalizedRgb(0.25, 0.15, 0.6);
  BeamTicks := 20;
  UpdateProjectionBounds;
  FirstLine := nil;
  LastLine := nil;
end;
{ @end $4EE298 }

{ @routine $4EE398 TPSEyesGI_Destroy }
destructor TPSEyesGI.Destroy;
begin
  InvalidateRect(HitTestBounds);
  ClearLines;
  ClearParticles;
  inherited Destroy;
end;
{ @end $4EE398 }

{ @routine $4EE3EC TPSEyesGI_SetPosition }
procedure TPSEyesGI.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $4EE3EC }

{ @routine $4EE430 TPSEyesGI_SetTargetPoint }
procedure TPSEyesGI.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $4EE430 }

{ @routine $4EE484 TPSEyesGI_UpdateProjectionBounds }
procedure TPSEyesGI.UpdateProjectionBounds;
var
  Distance, Angle, Sine, Cosine, A, B, C, D: Single;
  DY: Integer;
begin
  DY := -(TargetPoint.Y - LocalPosition.Y);
  if DY = 0 then Inc(DY);
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, DY);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
  A := -HalfWidth * Cosine - -Distance * Sine;
  B := HalfWidth * Cosine - -Distance * Sine;
  C := -HalfWidth * Cosine;
  D := HalfWidth * Cosine;
  ProjectionBounds.Left := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Right := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
  A := -HalfWidth * Sine + -Distance * Cosine;
  B := HalfWidth * Sine + -Distance * Cosine;
  C := -HalfWidth * Sine;
  // Native uses Cosine for this final corner as well.
  D := HalfWidth * Cosine;
  ProjectionBounds.Top := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Bottom := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
end;
{ @end $4EE484 }

{ @routine $4EE7A0 TPSEyesGI_UpdateHitTestBounds }
procedure TPSEyesGI.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y;
end;
{ @end $4EE7A0 }

{ @routine $4EE800 TPSEyesGI_GetLocalBounds }
function TPSEyesGI.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $4EE800 }

{ @routine $4EE864 TPSEyesGI_AddParticle }
function TPSEyesGI.AddParticle: PEyesParticle;
var
  Particle: PEyesParticle;
begin
  Particle := AllocEC(SizeOf(TEyesParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $4EE864 }

{ @routine $4EE8DC TPSEyesGI_ClearParticles }
procedure TPSEyesGI.ClearParticles;
var
  Particle, Current: PEyesParticle;
begin
  Particle := FirstParticle;
  while Particle <> nil do
  begin
    Current := Particle;
    Particle := Particle.Next;
    FreeEC(Current);
  end;
  FirstParticle := nil;
  LastParticle := nil;
end;
{ @end $4EE8DC }

{ @routine $4EE930 TPSEyesGI_ClearLines }
procedure TPSEyesGI.ClearLines;
var
  Particle, Current: PEyesLine;
begin
  Particle := FirstLine;
  while Particle <> nil do
  begin
    Current := Particle;
    Particle := Particle.Next;
    FreeEC(Current);
  end;
  FirstLine := nil;
  LastLine := nil;
end;
{ @end $4EE930 }

{ @routine $4EE984 TPSEyesGI_Invalidate }
procedure TPSEyesGI.Invalidate;
begin
end;
{ @end $4EE984 }

{ @routine $4EE990 TPSEyesGI_InvalidateRect }
procedure TPSEyesGI.InvalidateRect(Rect: TRect);
var
  Target: TPoint;
  Intersection: TRect;
begin
  MessageLoop.UpdateRects.AddScreenClippedRect(HitTestBounds, Parent.ToAbsolutePoint(LocalPosition), Parent.ToAbsolutePoint(TargetPoint));
  Target := Parent.ToAbsolutePoint(TargetPoint);
  Rect.Left := Target.X - HalfWidth;
  Rect.Right := Target.X + HalfWidth;
  Rect.Top := Target.Y - HalfWidth;
  Rect.Bottom := Target.Y + HalfWidth;
  if IntersectRects(Intersection, Rect, GameScreenRect) then
    MessageLoop.QueueUpdateRect(Intersection);
end;
{ @end $4EE990 }

{ @routine $4EEA74 TPSEyesGI_EmitBurst }
procedure TPSEyesGI.EmitBurst(Point: TPoint; Radius: Integer);
var
  X, Y: Integer;
  Particle: PEyesParticle;
begin
  for Y := -Radius to Radius do
    for X := -Radius + Abs(Y) to Radius - Abs(Y) do
    begin
      Particle := AddParticle;
      Particle.Origin := MakePointF(Point.X, Point.Y);
      Particle.Position := Particle.Origin;
      Particle.Color := PrimaryColor;
      Particle.Alpha := 255;
      Particle.State := 1;
      Particle.Countdown := 7;
      Particle.Velocity := MakePointF(X / Radius * 1.1, Y / Radius * 1.1);
      if Particle.Velocity.X < 0 then Particle.Velocity.X := Particle.Velocity.X - Random(11) / 16.0
      else Particle.Velocity.X := Particle.Velocity.X + Random(11) / 16.0;
      if Particle.Velocity.Y < 0 then Particle.Velocity.Y := Particle.Velocity.Y - Random(11) / 16.0
      else Particle.Velocity.Y := Particle.Velocity.Y + Random(11) / 16.0;
    end;
end;
{ @end $4EEA74 }

{ @routine $4EEC6C TPSEyesGI_Advance }
procedure TPSEyesGI.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Particle, Current: PEyesParticle;
begin
  if (FirstParticle = nil) and (RemainingTicks >= 20) then
  begin
    EmitBurst(Classes.Point(-6, -6), 8);
    EmitBurst(Classes.Point(6, 0), 8);
    EmitBurst(Classes.Point(0, 6), 8);
    EmitBurst(Classes.Point(-6, 1), 8);
    BeamTicks := 20;
  end
  else
  begin
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      Current := Particle;
      Particle := Particle.Next;
      case Current.State of
        2:
        begin
          Current.Position := MakePointF(Current.Position.X + Current.Velocity.X, Current.Position.Y + Current.Velocity.Y);
          Current.Velocity.X := 0.95 * Current.Velocity.X;
          Current.Velocity.Y := 0.95 * Current.Velocity.Y;
          Dec(Current.Countdown);
          if Current.Countdown = 0 then
        begin
            Current.State := 3;
            Current.Countdown := 50;
        end;
        end;
        3:
        begin
          Current.Position := MakePointF(Current.Position.X + Current.Velocity.X, Current.Position.Y + Current.Velocity.Y);
          Current.Velocity.X := 0.95 * Current.Velocity.X;
          Current.Velocity.Y := 0.95 * Current.Velocity.Y;
          if Current.Alpha > 10 then Dec(Current.Alpha, 4);
          Dec(Current.Countdown);
        end;
      end;
    end;
  end;
  Dec(RemainingTicks);
  Dec(BeamTicks);
end;
{ @end $4EEC6C }

{ @routine $4EEE9C TPSEyesGI_Draw }
procedure TPSEyesGI.Draw(ClipRect: TRect);
var
  Particle: PEyesParticle;
  DX, DY, X, Y, Progress, Distance, Step: Integer;
  P: TPoint;
  Line, Shadow: TEyesLine;
begin
  X := TargetPoint.X - LocalPosition.X + AbsolutePosition.X;
  Y := TargetPoint.Y - LocalPosition.Y + AbsolutePosition.Y;
  Particle := FirstParticle;
  if HardwareRenderingEnabled then
  begin
    while Particle <> nil do
    begin
      DX := Round(Particle.Position.X) + X;
      DY := Round(Particle.Position.Y) + Y;
      QueueDrawPoint(DX, DY, Color565ToArgb(Particle.Color), Particle.Alpha);
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
    X := AbsolutePosition.X;
    Y := AbsolutePosition.Y;
    DX := TargetPoint.X - LocalPosition.X;
    DY := TargetPoint.Y - LocalPosition.Y;
    if Abs(DX) > Abs(DY) then Distance := Abs(DX)
    else Distance := Abs(DY);
    if Distance = 0 then Distance := 1;
    Progress := 0;
    Step := Distance div 4;
    if Step < 1 then Step := 1;
    if Step > 32 then Step := 32;
    if BeamTicks > 0 then
    begin
      P := Classes.Point(X, Y);
      while Distance - Progress > Step do
      begin
        Line.First := P;
        P := Classes.Point(X + (Progress + Step) * DX div Distance + RandomIntRange(-5, 5),
          Y + (Progress + Step) * DY div Distance + RandomIntRange(-5, 5));
        Line.Last := P;
        Line.Alpha := (Progress + Step) * 191 div Distance + 64;
        Line.Color := SecondaryColor;
        if Abs(DX) > Abs(DY) then
        begin
          Shadow.First := Classes.Point(Line.First.X, Line.First.Y - 1);
          Shadow.Last := Classes.Point(Line.Last.X, Line.Last.Y - 1);
        end
        else
        begin
          Shadow.First := Classes.Point(Line.First.X - 1, Line.First.Y);
          Shadow.Last := Classes.Point(Line.Last.X - 1, Line.Last.Y);
        end;
        Shadow.Alpha := Line.Alpha;
        Shadow.Color := PrimaryColor;
        Inc(Progress, Step);
        DrawAntialiasedLineDX(Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y, Color565ToArgb(Line.Color), Line.Alpha, @ClipRect);
        DrawAntialiasedLineDX(Shadow.First.X, Shadow.First.Y, Shadow.Last.X, Shadow.Last.Y, Color565ToArgb(Shadow.Color), Line.Alpha, @ClipRect);
      end;
      Line.First := P;
      Line.Last := Classes.Point(X + DX, Y + DY);
      Line.Alpha := 255;
      Line.Color := PrimaryColor;
      if Abs(DX) > Abs(DY) then
      begin
        Shadow.First := Classes.Point(Line.First.X, Line.First.Y - 1);
        Shadow.Last := Classes.Point(Line.Last.X, Line.Last.Y - 1);
      end
      else
      begin
        Shadow.First := Classes.Point(Line.First.X - 1, Line.First.Y);
        Shadow.Last := Classes.Point(Line.Last.X - 1, Line.Last.Y);
      end;
      Shadow.Alpha := Line.Alpha;
      Shadow.Color := PrimaryColor;
      DrawAntialiasedLineDX(Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y, Color565ToArgb(Line.Color), Line.Alpha, @ClipRect);
      DrawAntialiasedLineDX(Shadow.First.X, Shadow.First.Y, Shadow.Last.X, Shadow.Last.Y, Color565ToArgb(Shadow.Color), Line.Alpha, @ClipRect);
    end;
  end
  else
  begin
    while Particle <> nil do
    begin
      DX := Round(Particle.Position.X) + X;
      DY := Round(Particle.Position.Y) + Y;
      if (DX >= ClipRect.Left) and (DX < ClipRect.Right) and (DY >= ClipRect.Top) and (DY < ClipRect.Bottom) then
        ScreenRenderBuffer.BlendPixel16(DX, DY, Particle.Color, Particle.Alpha);
      Particle := Particle.Next;
    end;
    X := AbsolutePosition.X;
    Y := AbsolutePosition.Y;
    DX := TargetPoint.X - LocalPosition.X;
    DY := TargetPoint.Y - LocalPosition.Y;
    if Abs(DX) > Abs(DY) then Distance := Abs(DX)
    else Distance := Abs(DY);
    if Distance = 0 then Distance := 1;
    Progress := 0;
    Step := Distance div 4;
    if Step < 1 then Step := 1;
    if Step > 32 then Step := 32;
    if BeamTicks > 0 then
    begin
      P := Classes.Point(X, Y);
      while Distance - Progress > Step do
      begin
        Line.First := P;
        P := Classes.Point(X + (Progress + Step) * DX div Distance + RandomIntRange(-5, 5),
          Y + (Progress + Step) * DY div Distance + RandomIntRange(-5, 5));
        Line.Last := P;
        Line.Alpha := (Progress + Step) * 191 div Distance + 64;
        Line.Color := SecondaryColor;
        if Abs(DX) > Abs(DY) then
        begin
          Shadow.First := Classes.Point(Line.First.X, Line.First.Y - 1);
          Shadow.Last := Classes.Point(Line.Last.X, Line.Last.Y - 1);
        end
        else
        begin
          Shadow.First := Classes.Point(Line.First.X - 1, Line.First.Y);
          Shadow.Last := Classes.Point(Line.Last.X - 1, Line.Last.Y);
        end;
        Shadow.Alpha := Line.Alpha;
        Shadow.Color := PrimaryColor;
        Inc(Progress, Step);
        ScreenRenderBuffer.DrawAlphaLine16(Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y, Line.Color, Line.Alpha, ClipRect);
        ScreenRenderBuffer.DrawAlphaLine16(Shadow.First.X, Shadow.First.Y, Shadow.Last.X, Shadow.Last.Y, Shadow.Color, Line.Alpha, ClipRect);
      end;
      Line.First := P;
      Line.Last := Classes.Point(X + DX, Y + DY);
      Line.Alpha := 255;
      Line.Color := PrimaryColor;
      if Abs(DX) > Abs(DY) then
      begin
        Shadow.First := Classes.Point(Line.First.X, Line.First.Y - 1);
        Shadow.Last := Classes.Point(Line.Last.X, Line.Last.Y - 1);
      end
      else
      begin
        Shadow.First := Classes.Point(Line.First.X - 1, Line.First.Y);
        Shadow.Last := Classes.Point(Line.Last.X - 1, Line.Last.Y);
      end;
      Shadow.Alpha := Line.Alpha;
      Shadow.Color := PrimaryColor;
      ScreenRenderBuffer.DrawAlphaLine16(Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y, Line.Color, Line.Alpha, ClipRect);
      ScreenRenderBuffer.DrawAlphaLine16(Shadow.First.X, Shadow.First.Y, Shadow.Last.X, Shadow.Last.Y, Shadow.Color, Line.Alpha, ClipRect);
    end;
  end;
end;
{ @end $4EEE9C }

end.
