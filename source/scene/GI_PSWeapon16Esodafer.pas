unit GI_PSWeapon16Esodafer;
// Native Esodafer projectile, reusable particles and branching impact sparks.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PEsodaferParticle = ^TEsodaferParticle;
  TEsodaferParticle = record // @size $20
    Prev: PEsodaferParticle; // @offset $00
    Next: PEsodaferParticle; // @offset $04
    Position: TPointF; // @offset $08
    Color: Word; // @offset $10
    Alpha: Byte; // @offset $12
    Velocity: TPointF; // @offset $14
    State: Byte; // @offset $1C
  end;
  TEsodaferPalette = array[0..2] of Word;
  TEsodaferPalettes = array of TEsodaferPalette;

var
  EsodaferPalettes: array of TEsodaferPalette; // @addr $8895A4

type
  TPSWeapon16Esodafer = class(TPSWeaponGI) // @size $168
  public
    HalfWidth: Integer; // @offset $130
    FirstParticle: PEsodaferParticle; // @offset $134
    LastParticle: PEsodaferParticle; // @offset $138
    Colors: TEsodaferPalette; // @offset $13C
    ProjectionBounds: TRect; // @offset $142
    OriginalLength: Double; // @offset $158
    LengthScale: Double; // @offset $160

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $4F0D8C @ida "TPSWeapon16Esodafer *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>, int APaletteIndex@<^0>);"
    destructor Destroy; override; // @addr $4F0E5C @ida "void __usercall $name(TPSWeapon16Esodafer *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetColors(Primary, Secondary, Tertiary: Word); // @addr $4F0E98
    procedure SetPosition(Position: TPoint); override; // @addr $4F0EDC @ida "void __usercall $name(TPSWeapon16Esodafer *Self@<eax>, TPoint *Position@<edx>);"
    procedure SetTargetPoint(Point: TPoint); override; // @addr $4F0F20 @ida "void __usercall $name(TPSWeapon16Esodafer *Self@<eax>, TPoint *Point@<edx>);"
    procedure UpdateProjectionBounds; // @addr $4F0F74
    procedure UpdateHitTestBounds; override; // @addr $4F12C0
    function GetLocalBounds: TRect; override; // @addr $4F1320 @ida "void __usercall $name(TPSWeapon16Esodafer *Self@<eax>, TRect *Result@<edx>);"
    function AddParticle: PEsodaferParticle; // @addr $4F1384
    procedure ClearParticles; // @addr $4F13FC
    procedure InvalidateRect(Rect: TRect); override; // @addr $4F1450 @ida "void __usercall $name(TPSWeapon16Esodafer *Self@<eax>, TRect *Rect@<edx>);"
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $4F156C
    procedure Draw(ClipRect: TRect); override; // @addr $4F1EEC @ida "void __usercall $name(TPSWeapon16Esodafer *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

procedure LoadEsodaferPalettes; // @addr $4F2120

implementation

// @unit-initialization $875808
// @unit-finalization $4F23E8

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $4F0D8C TPSWeapon16Esodafer_Create }
constructor TPSWeapon16Esodafer.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := 50;
  LengthScale := 1;
  OriginalLength := 1;
  RemainingTicks := 160;
  UpdateProjectionBounds;
  SetColors(EsodaferPalettes[APaletteIndex][0], EsodaferPalettes[APaletteIndex][1], EsodaferPalettes[APaletteIndex][2]);
end;
{ @end $4F0D8C }

{ @routine $4F0E5C TPSWeapon16Esodafer_Destroy }
destructor TPSWeapon16Esodafer.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $4F0E5C }

{ @routine $4F0E98 TPSWeapon16Esodafer_SetColors }
procedure TPSWeapon16Esodafer.SetColors(Primary, Secondary, Tertiary: Word);
begin
  Colors[0] := Primary;
  Colors[1] := Secondary;
  Colors[2] := Tertiary;
end;
{ @end $4F0E98 }

{ @routine $4F0EDC TPSWeapon16Esodafer_SetPosition }
procedure TPSWeapon16Esodafer.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $4F0EDC }

{ @routine $4F0F20 TPSWeapon16Esodafer_SetTargetPoint }
procedure TPSWeapon16Esodafer.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $4F0F20 }

{ @routine $4F0F74 TPSWeapon16Esodafer_UpdateProjectionBounds }
procedure TPSWeapon16Esodafer.UpdateProjectionBounds;
var
  Sine, Cosine, Distance, A, B, C, D: Single;
begin
  Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
  if Distance = 0 then Distance := 1;
  Cosine := -(TargetPoint.Y - LocalPosition.Y) / Distance;
  Sine := (TargetPoint.X - LocalPosition.X) / Distance;
  A := (-HalfWidth - 12) * Cosine - (-Distance - 100.0) * Sine;
  B := (HalfWidth + 12) * Cosine - (-Distance - 100.0) * Sine;
  C := (-HalfWidth - 12) * Cosine;
  D := (HalfWidth + 12) * Cosine;
  ProjectionBounds.Left := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Right := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
  A := (-HalfWidth - 12) * Sine + (-Distance - 100.0) * Cosine;
  B := (HalfWidth + 12) * Sine + (-Distance - 100.0) * Cosine;
  C := (-HalfWidth - 12) * Sine;
  // Native uses Cosine for this final corner as well.
  D := (HalfWidth + 12) * Cosine;
  ProjectionBounds.Top := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Bottom := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
end;
{ @end $4F0F74 }

{ @routine $4F12C0 TPSWeapon16Esodafer_UpdateHitTestBounds }
procedure TPSWeapon16Esodafer.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y;
end;
{ @end $4F12C0 }

{ @routine $4F1320 TPSWeapon16Esodafer_GetLocalBounds }
function TPSWeapon16Esodafer.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $4F1320 }

{ @routine $4F1384 TPSWeapon16Esodafer_AddParticle }
function TPSWeapon16Esodafer.AddParticle: PEsodaferParticle;
var
  Particle: PEsodaferParticle;
begin
  Particle := AllocEC(SizeOf(TEsodaferParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $4F1384 }

{ @routine $4F13FC TPSWeapon16Esodafer_ClearParticles }
procedure TPSWeapon16Esodafer.ClearParticles;
var
  Particle, Current: PEsodaferParticle;
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
{ @end $4F13FC }

{ @routine $4F1450 TPSWeapon16Esodafer_InvalidateRect }
procedure TPSWeapon16Esodafer.InvalidateRect(Rect: TRect);
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
{ @end $4F1450 }

{ @routine $4F156C TPSWeapon16Esodafer_Advance }
procedure TPSWeapon16Esodafer.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  I: Integer;
  Distance, Angle, Speed: Single;
  Particle, Current, Spark: PEsodaferParticle;

  // @nested $4F151C AcquireEsodaferParticle
  function AcquireEsodaferParticle: PEsodaferParticle; // @addr $4F151C @ida "TEsodaferParticle *__usercall $name@<eax>(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4F19C4, 0x4F1B2C"
  var
    Candidate: PEsodaferParticle;
  begin
    Candidate := FirstParticle;
    while (Candidate <> nil) and (Candidate.State <> 255) do Candidate := Candidate.Next;
    if Candidate = nil then Candidate := AddParticle;
    Result := Candidate;
  end;

begin
  Invalidate;
  if (FirstParticle = nil) and (RemainingTicks >= 24) then
  begin
    Distance := Round(Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y)));
    OriginalLength := Math.Max(70, Distance);
    Particle := AddParticle;
    Particle.Position := MakePointF(0, 0);
    Particle.Color := Colors[1];
    Particle.Alpha := 0;
    Speed := 6.0 * Distance / RemainingTicks;
    Particle.Velocity := MakePointF(0, Speed);
    Particle.State := 1;
    LengthScale := 1;
    for I := 1 to 16 do
    begin
      Particle := AddParticle;
      Particle.Position := MakePointF(Cos(I * 3.14 * 0.125) * 2.0, Sin(I * 3.14 * 0.125) * 2.0 - 10.0);
      Particle.Color := Colors[1];
      Particle.Alpha := 0;
      Particle.Velocity := MakePointF(0, Speed);
      Particle.State := 2;
    end;
    for I := 1 to 16 do
    begin
      Particle := AddParticle;
      Particle.Position := MakePointF(Cos(I * 3.14 * 0.125) * 1.5, Sin(I * 3.14 * 0.125) * 1.5 - 20.0);
      Particle.Color := Colors[1];
      Particle.Alpha := 0;
      Particle.Velocity := MakePointF(Particle.Position.X * 0.5, Speed);
      Particle.State := 2;
    end;
    for I := 1 to 16 do
    begin
      Particle := AddParticle;
      Particle.Position := MakePointF(Cos(I * 3.14 * 0.125) * 1.0, Sin(I * 3.14 * 0.125) * 1.0 - 30.0);
      Particle.Color := Colors[1];
      Particle.Alpha := 0;
      Particle.Velocity := MakePointF(Particle.Position.X * 1.0, Speed);
      Particle.State := 2;
    end;
  end
  else
  begin
    Distance := OriginalLength;
    LengthScale := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y)) / OriginalLength;
    UpdateHitTestBounds;
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      Current := Particle;
      Particle := Particle.Next;
      if Current.State = 1 then
      begin
        Spark := AcquireEsodaferParticle;
        Spark.Position := Current.Position;
        Spark.Color := Colors[Random(3)];
        Spark.Alpha := Current.Alpha;
        Speed := 0.06 * Distance / RemainingTicks;
        Angle := Random(360) * 0.01745329252;
        Spark.Velocity := MakePointF(Cos(Angle) * Speed + Current.Velocity.X, Sin(Angle) * Speed + Current.Velocity.Y);
        Spark.State := 2;
      end
      else if ((Current.State = 2) and (Random(101) < 3)) or ((Current.State = 3) and (Random(101) < 10)) then
      begin
        if Current.Alpha > 100 then
        begin
          Dec(Current.Alpha, 70);
          Current.Velocity.X := 0.9 * Current.Velocity.X;
          Current.Velocity.Y := 0.9 * Current.Velocity.Y;
          for I := 1 to Current.State * 4 + 1 do
          begin
            Spark := AcquireEsodaferParticle;
            Spark.Position := Current.Position;
            Spark.Color := Colors[Random(3)];
            Spark.Alpha := Current.Alpha;
            if Current.State = 3 then Speed := 20.0 / RemainingTicks
            else Speed := 0.04 * Distance / RemainingTicks;
            Angle := Random(360) * 0.01745329252;
            Spark.Velocity := MakePointF(Cos(Angle) * Speed + Current.Velocity.X, Sin(Angle) * Speed + Current.Velocity.Y);
            Spark.State := Current.State;
          end;
        end
        else Current.State := 255;
      end;
      if (Current.State = 2) and (FirstParticle.State = 1) then
      begin
        if Current.Alpha >= 3 then Dec(Current.Alpha, 3);
        Current.Velocity.X := (Current.Velocity.X - FirstParticle.Velocity.X) * 0.8 + FirstParticle.Velocity.X;
        Current.Velocity.Y := (Current.Velocity.Y - FirstParticle.Velocity.Y) * 0.8 + FirstParticle.Velocity.Y;
      end;
      if (RemainingTicks > 150) and (Current.State in [1, 2]) then
        Current.Alpha := Math.Min(255, Current.Alpha + 30);
      if (RemainingTicks < 40) and (Current.State in [2, 3]) and (Current.Alpha >= 5) then Dec(Current.Alpha, 5);
      if (Current.Alpha < 100) and (RemainingTicks < 150) then Current.State := 255;
      Current.Position.X := Current.Position.X + Current.Velocity.X;
      Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
      if (Current.Position.Y >= Distance) and (Current.State in [1, 2]) then
      begin
        Current.Position.Y := (Current.Position.Y - Distance) * 0.3 + Distance;
        Speed := 40.0 / RemainingTicks;
        Angle := Random(360) * 0.01745329252;
        if Current.State = 2 then Current.Velocity := MakePointF(Cos(Angle) * Speed, Sin(Angle) * Speed)
        else Current.Velocity := MakePointF(0, 0);
        Current.State := 3;
      end;
    end;
  end;
  Dec(RemainingTicks);
end;
{ @end $4F156C }

{ @routine $4F1EEC TPSWeapon16Esodafer_Draw }
procedure TPSWeapon16Esodafer.Draw(ClipRect: TRect);
var
  Angle, Sine, Cosine, PX, PY: Single;
  Particle: PEsodaferParticle;
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
      if Particle.State <> 255 then
      begin
        PX := Particle.Position.X * LengthScale;
        PY := -Particle.Position.Y * LengthScale;
        X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
        Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
        QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      end;
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Particle <> nil do
    begin
      if Particle.State <> 255 then
      begin
        PX := Particle.Position.X * LengthScale;
        PY := -Particle.Position.Y * LengthScale;
        X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
        Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      end;
      Particle := Particle.Next;
    end;
  end;
end;
{ @end $4F1EEC }

{ @routine $4F2120 LoadEsodaferPalettes }
procedure LoadEsodaferPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.15.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(EsodaferPalettes, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      for ColorIndex := 0 to 2 do
        if PaletteBlock.CountParams('Color' + IntToStr(ColorIndex)) > 0 then
        begin
          Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex));
          EsodaferPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
    end;
  end;
end;
{ @end $4F2120 }

end.
