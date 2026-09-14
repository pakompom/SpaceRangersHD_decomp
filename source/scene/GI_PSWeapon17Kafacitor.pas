unit GI_PSWeapon17Kafacitor;
// Native Kafacitor beam: linked control points and interpolated lateral movement.

interface

uses GI_PSWeapon, GI_MessageLoop, EC_Struct, Types;

type
  PKafacitorParticle = ^TKafacitorParticle;
  TKafacitorParticle = record // @size $20
    Prev: PKafacitorParticle; // @offset $00
    Next: PKafacitorParticle; // @offset $04
    Position: TPointF; // @offset $08
    Color: Word; // @offset $10
    Alpha: Byte; // @offset $12
    Velocity: TPointF; // @offset $14
    State: Byte; // @offset $1C
  end;
  TKafacitorPalette = array[0..1] of Word;
  TGAISet = array[0..0] of WideString;
  TKafacitorAnimationPaths = array of TGAISet;
  TKafacitorPalettes = array of TKafacitorPalette;

var
  KafacitorPalettes: array of TKafacitorPalette; // @addr $889598
  KafacitorAnimationPaths: array of TGAISet; // @addr $88959C

type
  TPSWeapon17Kafacitor = class(TPSWeaponGI) // @size $160
  public
    HalfWidth: Integer; // @offset $130
    FirstParticle: PKafacitorParticle; // @offset $134
    LastParticle: PKafacitorParticle; // @offset $138
    PrimaryColor: Word; // @offset $13C
    SecondaryColor: Word; // @offset $13E
    ProjectionBounds: TRect; // @offset $140
    OriginalLength: Double; // @offset $150
    LengthScale: Double; // @offset $158

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $4EFA9C @ida "TPSWeapon17Kafacitor *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>, int APaletteIndex@<^0>);"
    destructor Destroy; override; // @addr $4EFB54 @ida "void __usercall $name(TPSWeapon17Kafacitor *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetColors(Primary, Secondary: Word); // @addr $4EFB88
    procedure SetPosition(Position: TPoint); override; // @addr $4EFBBC @ida "void __usercall $name(TPSWeapon17Kafacitor *Self@<eax>, TPoint *Position@<edx>);"
    procedure SetTargetPoint(Point: TPoint); override; // @addr $4EFC00 @ida "void __usercall $name(TPSWeapon17Kafacitor *Self@<eax>, TPoint *Point@<edx>);"
    procedure UpdateProjectionBounds; // @addr $4EFC54
    procedure UpdateHitTestBounds; override; // @addr $4EFF84
    function GetLocalBounds: TRect; override; // @addr $4EFFE4 @ida "void __usercall $name(TPSWeapon17Kafacitor *Self@<eax>, TRect *Result@<edx>);"
    function AddParticle: PKafacitorParticle; // @addr $4F0048
    procedure InvalidateRect(Rect: TRect); override; // @addr $4F00C0 @ida "void __usercall $name(TPSWeapon17Kafacitor *Self@<eax>, TRect *Rect@<edx>);"
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $4F018C
    procedure Draw(ClipRect: TRect); override; // @addr $4F06A0 @ida "void __usercall $name(TPSWeapon17Kafacitor *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

procedure LoadKafacitorPalettes; // @addr $4F08B8

implementation

// @unit-initialization $875800
// @unit-finalization $4F0BD8

uses GR_Rect, EC_Mem, GR_DX, Globals, aMyFunction, EC_BlockPar, GR_Main, EC_Str, GlobalsV, GR_GraphBuf, Math, SysUtils;

{ @routine $4EFA9C TPSWeapon17Kafacitor_Create }
constructor TPSWeapon17Kafacitor.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := 10;
  LengthScale := 1;
  OriginalLength := 1;
  RemainingTicks := 40;
  UpdateProjectionBounds;
  SetColors(KafacitorPalettes[APaletteIndex][0], KafacitorPalettes[APaletteIndex][1]);
end;
{ @end $4EFA9C }

{ @routine $4EFB54 TPSWeapon17Kafacitor_Destroy }
destructor TPSWeapon17Kafacitor.Destroy;
begin
  // Native destructor does not release the allocated particle list.
  inherited Destroy;
end;
{ @end $4EFB54 }

{ @routine $4EFB88 TPSWeapon17Kafacitor_SetColors }
procedure TPSWeapon17Kafacitor.SetColors(Primary, Secondary: Word);
begin
  PrimaryColor := Primary;
  SecondaryColor := Secondary;
end;
{ @end $4EFB88 }

{ @routine $4EFBBC TPSWeapon17Kafacitor_SetPosition }
procedure TPSWeapon17Kafacitor.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $4EFBBC }

{ @routine $4EFC00 TPSWeapon17Kafacitor_SetTargetPoint }
procedure TPSWeapon17Kafacitor.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $4EFC00 }

{ @routine $4EFC54 TPSWeapon17Kafacitor_UpdateProjectionBounds }
procedure TPSWeapon17Kafacitor.UpdateProjectionBounds;
var
  Sine, Cosine, Distance, A, B, C, D: Single;
begin
  Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
  if Distance = 0 then Distance := 1;
  Cosine := -(TargetPoint.Y - LocalPosition.Y) / Distance;
  Sine := (TargetPoint.X - LocalPosition.X) / Distance;
  A := (-HalfWidth - 12) * Cosine - -Distance * Sine;
  B := (HalfWidth + 12) * Cosine - -Distance * Sine;
  C := (-HalfWidth - 12) * Cosine;
  D := (HalfWidth + 12) * Cosine;
  ProjectionBounds.Left := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Right := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
  A := (-HalfWidth - 12) * Sine + -Distance * Cosine;
  B := (HalfWidth + 12) * Sine + -Distance * Cosine;
  C := (-HalfWidth - 12) * Sine;
  // Native uses Cosine for this final corner as well.
  D := (HalfWidth + 12) * Cosine;
  ProjectionBounds.Top := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Bottom := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
end;
{ @end $4EFC54 }

{ @routine $4EFF84 TPSWeapon17Kafacitor_UpdateHitTestBounds }
procedure TPSWeapon17Kafacitor.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y;
end;
{ @end $4EFF84 }

{ @routine $4EFFE4 TPSWeapon17Kafacitor_GetLocalBounds }
function TPSWeapon17Kafacitor.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $4EFFE4 }

{ @routine $4F0048 TPSWeapon17Kafacitor_AddParticle }
function TPSWeapon17Kafacitor.AddParticle: PKafacitorParticle;
var
  Particle: PKafacitorParticle;
begin
  Particle := AllocEC(SizeOf(TKafacitorParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $4F0048 }

{ @routine $4F00C0 TPSWeapon17Kafacitor_InvalidateRect }
procedure TPSWeapon17Kafacitor.InvalidateRect(Rect: TRect);
var
  Target: TPoint;
  Intersection: TRect;
begin
  MessageLoop.UpdateRects.AddScreenClippedRect(HitTestBounds, Parent.ToAbsolutePoint(LocalPosition), Parent.ToAbsolutePoint(TargetPoint));
  Target := Parent.ToAbsolutePoint(TargetPoint);
  Rect.Left := Target.X - 24;
  Rect.Right := Target.X + 24;
  Rect.Top := Target.Y - 24;
  Rect.Bottom := Target.Y + 24;
  if IntersectRects(Intersection, Rect, GameScreenRect) then
    MessageLoop.QueueUpdateRect(Intersection);
end;
{ @end $4F00C0 }

{ @routine $4F018C TPSWeapon17Kafacitor_Advance }
procedure TPSWeapon17Kafacitor.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  I, Pass, Direction, SegmentPosition, SegmentLength, Offset: Integer;
  Distance, Spacing: Single;
  Particle, Current, PreviousControl, NextControl: PKafacitorParticle;
begin
  Invalidate;
  if (FirstParticle = nil) and (RemainingTicks >= 24) then
  begin
    I := 0;
    Distance := Round(Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y)));
    OriginalLength := Distance;
    if OriginalLength = 0 then OriginalLength := 1;
    HalfWidth := Math.Max(HalfWidth, Round(0.07 * OriginalLength));
    Spacing := Distance / 20.0;
    SegmentPosition := 0;
    SegmentLength := 0;
    LengthScale := 1;
    Direction := 1;
    for Pass := 1 to 2 do
    begin
      while ((Direction = 1) and (I <= 4.0 * Distance)) or ((Direction = -1) and (I >= 0)) do
      begin
        Particle := AddParticle;
        Particle.Position := MakePointF(0, I div 4);
        if Direction = 1 then Particle.Color := PrimaryColor
        else Particle.Color := SecondaryColor;
        Particle.Alpha := 255;
        Particle.Velocity := MakePointF(0, 0);
        if (I = 0) or (I = Distance) then
        begin
          Particle.State := 1;
          SegmentPosition := 0;
        end
        else if SegmentPosition < 4.0 * Spacing then
        begin
          Particle.State := 2;
          Inc(SegmentPosition);
        end
        else
        begin
          Particle.State := 3;
          SegmentPosition := 0;
          if SegmentLength = 1 then Particle.Velocity.X := 1
          else Particle.Velocity.X := -1;
          SegmentLength := 1 - SegmentLength;
        end;
        Inc(I, Direction);
      end;
      Direction := -Direction;
    end;
  end
  else
  begin
    Distance := OriginalLength;
    LengthScale := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y)) / OriginalLength;
    UpdateHitTestBounds;
    Particle := FirstParticle;
    NextControl := Particle;
    PreviousControl := Particle;
    SegmentLength := 1;
    Offset := 0;
    while Particle <> nil do
    begin
      Current := Particle;
      Particle := Particle.Next;
      if (Current.State in [1, 3]) and (Particle <> nil) then
      begin
        PreviousControl := Current;
        SegmentLength := 1;
        Offset := 0;
        NextControl := Particle;
        while not (NextControl.State in [1, 3]) do
        begin
          NextControl := NextControl.Next;
          Inc(SegmentLength);
        end;
        if (Abs(NextControl.Position.X) > 0.1 * Distance) and (NextControl.Position.X * NextControl.Velocity.X > 0.0) then
          NextControl.Velocity.X := NextControl.Velocity.X * -1.0
        else if (NextControl.Position.X * NextControl.Velocity.X > 0.0) and
          (Random(101) < (Abs(NextControl.Position.X) / (0.05 * Distance) - 1.0) * 100.0) then
          NextControl.Velocity.X := NextControl.Velocity.X * -1.0
        else if Random(101) < 15 then
          NextControl.Velocity.X := NextControl.Velocity.X * -1.0;
      end
      else Inc(Offset);
      Current.Position.X := (1.0 - Offset / SegmentLength) * PreviousControl.Velocity.X + Current.Position.X + Offset * NextControl.Velocity.X / SegmentLength;
      if RemainingTicks < 24 then
        if Current.Alpha - 10 > 0 then Dec(Current.Alpha, 10)
        else Current.Alpha := 0;
    end;
  end;
  Dec(RemainingTicks);
end;
{ @end $4F018C }

{ @routine $4F06A0 TPSWeapon17Kafacitor_Draw }
procedure TPSWeapon17Kafacitor.Draw(ClipRect: TRect);
var
  Angle, Sine, Cosine, PX, PY: Single;
  Particle: PKafacitorParticle;
  X, Y: Integer;
begin
  Y := -(TargetPoint.Y - LocalPosition.Y);
  if Y = 0 then Inc(Y);
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, Y);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Particle := FirstParticle;
  if HardwareRenderingEnabled then
  begin
    while Particle <> nil do
    begin
      PX := Particle.Position.X * LengthScale;
      PY := -Particle.Position.Y * LengthScale;
      X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
      Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
      QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Particle <> nil do
    begin
      PX := Particle.Position.X * LengthScale;
      PY := -Particle.Position.Y * LengthScale;
      X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
      Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
      if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
        ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      Particle := Particle.Next;
    end;
  end;
end;
{ @end $4F06A0 }

{ @routine $4F08B8 LoadKafacitorPalettes }
procedure LoadKafacitorPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.16.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(KafacitorPalettes, Count);
  SetLength(KafacitorAnimationPaths, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      for ColorIndex := 0 to 1 do
        if PaletteBlock.CountParams('Color' + IntToStr(ColorIndex)) > 0 then
        begin
          Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex));
          KafacitorPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
      if PaletteBlock.CountParams('GAI') > 0 then
        KafacitorAnimationPaths[Index][0] := PaletteBlock.GetParam('GAI');
    end;
  end;
end;
{ @end $4F08B8 }

end.
