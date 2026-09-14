unit GI_PSWeapon02FragCannon;
// Native fragment-cannon projectiles, impact particles and cyclic random pool.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PFragCannonParticle = ^TFragCannonParticle;
  TFragCannonParticle = record // @size $20
    Prev: PFragCannonParticle; // @offset $00
    Next: PFragCannonParticle; // @offset $04
    Position: TPointF; // @offset $08
    Color: Word; // @offset $10
    Alpha: Byte; // @offset $12
    Velocity: TPointF; // @offset $14
    State: Byte; // @offset $1C
    Unknown1E: Word; // @offset $1E  Initialized to 30000; unused by the native update.
  end;
  TFragCannonPalette = array[0..1] of Word;
  TFragCannonPalettes = array of TFragCannonPalette;

var
  FragCannonPalettes: array of TFragCannonPalette; // @addr $889814

type
  TPSWeapon02FragCannon = class(TPSWeaponGI) // @size $150
  public
    HalfWidth: Integer; // @offset $130
    FirstParticle: PFragCannonParticle; // @offset $134
    LastParticle: PFragCannonParticle; // @offset $138
    PrimaryColor: Word; // @offset $13C
    SecondaryColor: Word; // @offset $13E
    ProjectionBounds: TRect; // @offset $140

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $4FEAA4 @ida "TPSWeapon02FragCannon *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>, int APaletteIndex@<^0>);"
    destructor Destroy; override; // @addr $4FEB50 @ida "void __usercall $name(TPSWeapon02FragCannon *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetPosition(Position: TPoint); override; // @addr $4FEB8C @ida "void __usercall $name(TPSWeapon02FragCannon *Self@<eax>, TPoint *Position@<edx>);"
    procedure SetTargetPoint(Point: TPoint); override; // @addr $4FEBD0 @ida "void __usercall $name(TPSWeapon02FragCannon *Self@<eax>, TPoint *Point@<edx>);"
    procedure UpdateProjectionBounds; // @addr $4FEC24
    procedure UpdateHitTestBounds; override; // @addr $4FEF68
    function GetLocalBounds: TRect; override; // @addr $4FEFD4 @ida "void __usercall $name(TPSWeapon02FragCannon *Self@<eax>, TRect *Result@<edx>);"
    function AddParticle: PFragCannonParticle; // @addr $4FF038
    procedure ClearParticles; // @addr $4FF0B0
    procedure Invalidate; override; // @addr $4FF1D0 @note "Native empty override."
    procedure InvalidateRect(Rect: TRect); override; // @addr $4FF104 @ida "void __usercall $name(TPSWeapon02FragCannon *Self@<eax>, TRect *Rect@<edx>);"
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $4FF1DC
    procedure Draw(ClipRect: TRect); override; // @addr $4FF9FC @ida "void __usercall $name(TPSWeapon02FragCannon *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

function NextFragCannonRandom: Integer; // @addr $4FEA7C
procedure LoadFragCannonPalettes; // @addr $4FFC70

var
  FragCannonRandomIndex: Integer = 0; // @addr $87A9FC

implementation

// @unit-initialization $875868
// @unit-finalization $4FFF58

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

var
  FragCannonRandomValues: array[0..127] of Integer; // @addr $88981C

{ @routine $4FEA7C NextFragCannonRandom }
function NextFragCannonRandom: Integer;
begin
  FragCannonRandomIndex := (FragCannonRandomIndex + 1) and $7F;
  Result := FragCannonRandomValues[FragCannonRandomIndex];
end;
{ @end $4FEA7C }

{ @routine $4FEAA4 TPSWeapon02FragCannon_Create }
constructor TPSWeapon02FragCannon.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := 4;
  UpdateProjectionBounds;
  RemainingTicks := 60;
  LifetimeTicks := RemainingTicks;
  PrimaryColor := FragCannonPalettes[APaletteIndex][0];
  SecondaryColor := FragCannonPalettes[APaletteIndex][1];
end;
{ @end $4FEAA4 }

{ @routine $4FEB50 TPSWeapon02FragCannon_Destroy }
destructor TPSWeapon02FragCannon.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $4FEB50 }

{ @routine $4FEB8C TPSWeapon02FragCannon_SetPosition }
procedure TPSWeapon02FragCannon.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $4FEB8C }

{ @routine $4FEBD0 TPSWeapon02FragCannon_SetTargetPoint }
procedure TPSWeapon02FragCannon.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $4FEBD0 }

{ @routine $4FEC24 TPSWeapon02FragCannon_UpdateProjectionBounds }
procedure TPSWeapon02FragCannon.UpdateProjectionBounds;
var
  Angle, Sine, Cosine, Distance, A, B, C, D: Single;
  DY: Integer;
begin
  DY := -(TargetPoint.Y - LocalPosition.Y);
  if DY = 0 then Inc(DY);
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, DY);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
  A := (-HalfWidth * 2) * Cosine - -Distance * Sine;
  B := (HalfWidth * 2) * Cosine - -Distance * Sine;
  C := (-HalfWidth * 2) * Cosine;
  D := (HalfWidth * 2) * Cosine;
  ProjectionBounds.Left := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Right := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
  A := (-HalfWidth * 2) * Sine + -Distance * Cosine;
  B := (HalfWidth * 2) * Sine + -Distance * Cosine;
  C := (-HalfWidth * 2) * Sine;
  // Native uses Cosine for this final corner as well.
  D := (HalfWidth * 2) * Cosine;
  ProjectionBounds.Top := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Bottom := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
end;
{ @end $4FEC24 }

{ @routine $4FEF68 TPSWeapon02FragCannon_UpdateHitTestBounds }
procedure TPSWeapon02FragCannon.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X - 32;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y - 32;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X + 32;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y + 32;
end;
{ @end $4FEF68 }

{ @routine $4FEFD4 TPSWeapon02FragCannon_GetLocalBounds }
function TPSWeapon02FragCannon.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $4FEFD4 }

{ @routine $4FF038 TPSWeapon02FragCannon_AddParticle }
function TPSWeapon02FragCannon.AddParticle: PFragCannonParticle;
var
  Particle: PFragCannonParticle;
begin
  Particle := AllocEC(SizeOf(TFragCannonParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $4FF038 }

{ @routine $4FF0B0 TPSWeapon02FragCannon_ClearParticles }
procedure TPSWeapon02FragCannon.ClearParticles;
var
  Particle, Current: PFragCannonParticle;
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
{ @end $4FF0B0 }

{ @routine $4FF104 TPSWeapon02FragCannon_InvalidateRect }
procedure TPSWeapon02FragCannon.InvalidateRect(Rect: TRect);
var
  Target: TPoint;
  Intersection: TRect;
begin
  MessageLoop.UpdateRects.AddScreenClippedRect(HitTestBounds, Parent.ToAbsolutePoint(LocalPosition), Parent.ToAbsolutePoint(TargetPoint));
  Target := Parent.ToAbsolutePoint(TargetPoint);
  Rect.Left := Target.X - 32;
  Rect.Right := Target.X + 32;
  Rect.Top := Target.Y - 32;
  Rect.Bottom := Target.Y + 32;
  if IntersectRects(Intersection, Rect, GameScreenRect) then
    MessageLoop.QueueUpdateRect(Intersection);
end;
{ @end $4FF104 }

{ @routine $4FF1D0 TPSWeapon02FragCannon_Invalidate }
procedure TPSWeapon02FragCannon.Invalidate;
begin
end;
{ @end $4FF1D0 }

{ @routine $4FF1DC TPSWeapon02FragCannon_Advance }
procedure TPSWeapon02FragCannon.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Y: Single;
  I, Power, J: Integer;
  Distance: Single;
  Current, Spark, Particle: PFragCannonParticle;
  Speed: Single;
begin
  if (FirstParticle = nil) and (RemainingTicks > 20) then
  begin
    Y := 0;
    Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
    Speed := 4.1;
    if Distance / Speed > 38.0 then Speed := Distance / 38.0;
    while (Y < Distance) and (Y < 128.0) do
    begin
      for J := 0 to 0 do
      begin
        Particle := AddParticle;
        I := HalfWidth * (RandomIntRange(0, 1) * 2 - 1);
        Particle.Position.X := I + J;
        Particle.Position.Y := Y;
        Particle.Color := PrimaryColor;
        if Y < 32.0 then Particle.Alpha := Trunc(255.0 * Y) shr 5;
        Particle.Velocity.X := 0;
        Particle.Velocity.Y := Speed;
        Particle.State := 1;
        Particle.Unknown1E := 30000;
        Particle := AddParticle;
        Particle.Position.X := I + J;
        Particle.Position.Y := Y + 1.0;
        Particle.Color := PrimaryColor;
        if Y < 32.0 then Particle.Alpha := Trunc(255.0 * Y) shr 5;
        Particle.Velocity.X := 0;
        Particle.Velocity.Y := Speed;
        Particle.State := 1;
        Particle.Unknown1E := 30000;
        Particle := AddParticle;
        Particle.Position.X := I + J;
        Particle.Position.Y := Y + 2.0;
        Particle.Color := PrimaryColor;
        if Y < 32.0 then Particle.Alpha := Trunc(255.0 * Y) shr 5;
        Particle.Velocity.X := 0;
        Particle.Velocity.Y := Speed;
        Particle.State := 1;
        Particle.Unknown1E := 30000;
      end;
      Y := Y + 16.0;
    end;
  end
  else
  begin
    Distance := Trunc(Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y)));
    UpdateHitTestBounds;
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      Current := Particle;
      Particle := Particle.Next;
      case Current.State of
        1:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            if Current.Position.Y > Distance then
            begin
              for I := 0 to 11 do
              begin
                Spark := AddParticle;
                Spark.Position.X := Current.Position.X;
                Spark.Position.Y := Current.Position.Y;
                Spark.Color := SecondaryColor;
                Y := Random(16) / 8.0 * Pi;
                Power := Random(50);
                Spark.Velocity.X := Sin(Y) * (Power + 50) / 50.0;
                Spark.Velocity.Y := Cos(Y) * (Power + 50) / 50.0;
                Spark.State := 4;
                Power := (Current.Alpha shr 1) - NextFragCannonRandom;
                if Power < 0 then Power := 0;
                Spark.Alpha := Power;
              end;
              Current.State := 255;
              RemainingTicks := 20;
            end
            else
            begin
              if Current.Position.Y < 32.0 then Current.Alpha := Trunc(Current.Position.Y * 255.0) shr 5
              else Current.Alpha := 255;
              if NextFragCannonRandom < 5 then
              begin
                Spark := AddParticle;
                Spark.Position.X := Current.Position.X + NextFragCannonRandom / 100.0 - 0.5;
                Spark.Position.Y := Current.Position.Y - 1.0;
                Spark.Color := Current.Color;
                Spark.Velocity.X := Spark.Position.X - Current.Position.X;
                Spark.Velocity.Y := Current.Velocity.Y * 0.75;
                Spark.State := 2;
                Spark.Unknown1E := 30000;
                I := Current.Alpha - Random(128);
                if I > 255 then I := 255
                else if I < 0 then I := 0;
                Spark.Alpha := I;
              end;
            end;
          end;
        2: Inc(Current.State);
        3:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Velocity.Y := 0.95 * Current.Velocity.Y;
            if Current.Alpha > 8 then Dec(Current.Alpha, 9);
            if Current.Alpha < 15 then
            begin
              Current.State := 255;
              Current := nil;
            end;
            if (Current <> nil) and (NextFragCannonRandom < 14) then
            begin
              Spark := AddParticle;
              Spark.Position.X := Current.Position.X + NextFragCannonRandom / 400.0 - 0.125;
              Spark.Position.Y := Current.Position.Y - 1.0;
              Spark.Color := Current.Color;
              Spark.Velocity.X := Spark.Position.X - Current.Position.X + Current.Velocity.X;
              Spark.Velocity.Y := 0.7 * Current.Velocity.Y;
              Spark.State := 2;
              Spark.Unknown1E := 30000;
              I := Current.Alpha + Random(60) - 32;
              if I > 255 then I := 255
              else if I < 0 then I := 0;
              Spark.Alpha := I;
            end;
          end;
        4:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Velocity.Y := 0.95 * Current.Velocity.Y;
            Current.Velocity.X := 0.95 * Current.Velocity.X;
            if Current.Alpha < 246 then Inc(Current.Alpha, 10);
            if Current.Alpha > 245 then Current.State := 5;
          end;
        5:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Velocity.Y := 0.95 * Current.Velocity.Y;
            Current.Velocity.X := 0.95 * Current.Velocity.X;
            if Current.Alpha > 25 then Dec(Current.Alpha, 26);
            if Current.Alpha < 26 then Current.State := 255;
          end;
      end;
    end;
  end;
  Dec(RemainingTicks);
end;
{ @end $4FF1DC }

{ @routine $4FF9FC TPSWeapon02FragCannon_Draw }
procedure TPSWeapon02FragCannon.Draw(ClipRect: TRect);
var
  Angle, Sine, Cosine, PX, PY: Single;
  Particle: PFragCannonParticle;
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
        PX := Particle.Position.X;
        PY := -Particle.Position.Y;
        X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
        Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
        QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
        QueueDrawPoint(X - 1, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
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
        PX := Particle.Position.X;
        PY := -Particle.Position.Y;
        X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
        Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
        Dec(X);
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      end;
      Particle := Particle.Next;
    end;
  end;
end;
{ @end $4FF9FC }

{ @routine $4FFC70 LoadFragCannonPalettes }
procedure LoadFragCannonPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  for Index := Low(FragCannonRandomValues) to High(FragCannonRandomValues) do FragCannonRandomValues[Index] := Random(100);
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.1.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(FragCannonPalettes, Count);
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
          FragCannonPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
    end;
  end;
end;
{ @end $4FFC70 }

end.
