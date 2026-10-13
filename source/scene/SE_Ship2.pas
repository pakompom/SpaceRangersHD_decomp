unit SE_Ship2;

interface

uses Classes, EC_BlockPar, EC_Struct, GI_AlphaImage, GI_MessageLoop, GI_RotateImage5,
  GI_Tail, SE_Space, Types;

type
  TShip2FrameIndicesSE = array of Word;
  TShip2FrameDelaysSE = array of Word;
  TShip2AnimSE = class(TObject) // @size $1C
  public
    Prev: TShip2AnimSE; // @offset $04
    Next: TShip2AnimSE; // @offset $08
    Weight: Integer; // @offset $0C
    FrameCount: Integer; // @offset $10
    Frames: array of Word; // @offset $14
    Delays: array of Word; // @offset $18
    destructor Destroy; override; // @addr $65B96C
    procedure Clear; // @addr $65B998
    procedure Load(Specification: WideString); // @addr $65B9D4
  end;

  TShip2SE = class(TObjectSE) // @size $1B8
  public
    ImageSize: TPoint; // @offset $4C
    ImageScale: TPointF; // @offset $54
    ImageOrigin: TPoint; // @offset $5C
    ImageCenter: TPointF; // @offset $64
    Angle: Byte; // @offset $6C
    Alpha: Byte; // @offset $6D
    AlphaLimit: Byte; // @offset $6E
    MinimapImagePath: WideString; // @offset $70
    AlternateImagePath: WideString; // @offset $74
    MinimapImageOrigin: TPoint; // @offset $78
    StateIntervalMs: Integer; // @offset $80
    ImagePath: WideString; // @offset $84
    ReducedImagePath: WideString; // @offset $88
    TailOrigins: array[1..10] of TPointF; // @offset $8C
    TailEmitIntervalMs: Cardinal; // @offset $DC
    Image: TRotateImage5GI; // @offset $E0
    MinimapImage: TAlphaImageGI; // @offset $E4
    Tails: array[1..10] of TTailGI; // @offset $E8
    TailPrefix: WideString; // @offset $110
    WeaponPortCount: Cardinal; // @offset $114
    WeaponPorts: array[1..10] of TPointF; // @offset $118
    SharedAnimations: Boolean; // @offset $168
    FirstAnimation: TShip2AnimSE; // @offset $16C
    LastAnimation: TShip2AnimSE; // @offset $170
    FirstReducedAnimation: TShip2AnimSE; // @offset $174
    LastReducedAnimation: TShip2AnimSE; // @offset $178
    CurrentAnimation: TShip2AnimSE; // @offset $17C
    NextAnimation: TShip2AnimSE; // @offset $180
    DefaultAnimation: TShip2AnimSE; // @offset $184
    DefaultReducedAnimation: TShip2AnimSE; // @offset $188
    CurrentFrameIndex: Integer; // @offset $18C
    AnimationTimer: TCallbackTimerIdGI; // @offset $190
    StateTimer: TCallbackTimerIdGI; // @offset $194
    TotalAnimationWeight: Integer; // @offset $198
    TotalReducedAnimationWeight: Integer; // @offset $19C
    TailMode: Integer; // @offset $1A0
    PanelPartnerImage: WideString; // @offset $1A4
    SmallSize: Integer; // @offset $1A8
    LargeSize: Integer; // @offset $1AC
    TargetSizeScale: Single; // @offset $1B0
    AngleOverride: Integer; // @offset $1B4
    constructor CreateEmpty; // @addr $65BC2C
    constructor Create(const GraphKey: WideString; UnusedPosition: TPoint); // @addr $65BC70
    destructor Destroy; override; // @addr $65BD64
    procedure CopyTo(Destination: TObjectSE); override; // @addr $65BDE8
    procedure CopyDataFromMirrorImage(Destination: TObjectSE); // @addr $65BF8C @note "Despite the diagnostic name, copies Self into Destination, which must be TShip2SE."
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $65C1BC @note "Native diagnostic name: TShip2SE.Connect."
    procedure DetachFromSpace; override; // @addr $65CB08
    procedure SetTailMode(Value: Integer); // @addr $65CB98
    function GetImagePath: WideString; // @addr $65CD78
    procedure SetSize(Value: TPoint); override; // @addr $65CDA8
    procedure SetPosition(APosition: TPointF); override; // @addr $65CDF0
    procedure SetTailDepth(Value: Single); // @addr $65CED4
    procedure SetDepth(Value: Single); override; // @addr $65CF10
    function GetDepth: Single; override; // @addr $65CF2C
    function GetAngle: Byte; override; // @addr $65CF40
    procedure SetAngle(Value: Byte); override; // @addr $65CF48
    procedure OffsetTailsAlongHeading(Distance: Single); // @addr $65CFF8
    procedure OffsetTails(Delta: TPointF); // @addr $65D0AC
    procedure SetTailsEmitting(Value: Boolean); // @addr $65D0E0
    function GetAlpha: Byte; override; // @addr $65D108
    procedure SetAlpha(Value: Byte); override; // @addr $65D110
    function GetOrbitCenter: TPointF; override; // @addr $65D178
    function ScaleImagePoint(Point: TPointF): TPointF; // @addr $65D18C
    function ImagePointToWorld(Point: TPointF): TPointF; // @addr $65D1B8
    function GetTargetPoint(Heading: Byte; Seed: Integer): TPointF; // @addr $65D274
    function GetWeaponPortPoint(Heading: Byte; Seed: Cardinal): TPointF; // @addr $65D36C
    function HitTestCursor: Boolean; override; // @addr $65D444
    function AddAnimation: TShip2AnimSE; // @addr $65D478
    procedure DeleteAnimation(Animation: TShip2AnimSE); // @addr $65D4BC
    function AddReducedAnimation: TShip2AnimSE; // @addr $65D504
    procedure DeleteReducedAnimation(Animation: TShip2AnimSE); // @addr $65D548
    procedure StartAnimationTimer; // @addr $65D590
    procedure StopAnimationTimer; // @addr $65D5D0
    procedure StartStateTimer; // @addr $65D5F4
    procedure StopStateTimer; // @addr $65D630
    procedure AdvanceAnimation(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $65D654
    procedure SelectNextAnimation(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $65D810
    procedure DrawMap; override; // @addr $65D89C
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $65D938
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $65E228
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $65E2C4
  end;

implementation

uses Math, SysUtils, aMyFunction, aPlayer, EC_Str, GI_Main, Globals, GlobalsV,
  GR_Main, SE_Process;

{ @routine $65B96C TShip2AnimSE_Destroy }
destructor TShip2AnimSE.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $65B96C }

{ @routine $65B998 TShip2AnimSE_Clear }
procedure TShip2AnimSE.Clear;
begin
  if Frames <> nil then Frames := nil;
  if Delays <> nil then Delays := nil;
  Weight := 1;
  FrameCount := 0;
end;
{ @end $65B998 }

{ @routine $65B9D4 TShip2AnimSE_Load }
procedure TShip2AnimSE.Load(Specification: WideString);
var
  Index, RangeCount, FrameOffset, Count, Delay, First, Last: Integer;
  RangeText: WideString;
begin
  Clear;
  Index := CountDelimitedPartsW(Specification, ',');
  if Index < 3 then raise Exception.Create('Error in TShip2AnimSE.Load');
  Weight := ExtractDigitsToIntW(ExtractDelimitedPartW(Specification, 0, ','));
  Specification := ExtractDelimitedRangeW(Specification, 1, Index - 1, ',');
  RangeCount := (CountDelimitedPartsW(Specification, '[]') - 1) div 2;
  for Index := 0 to RangeCount - 1 do
  begin
    RangeText := ExtractDelimitedPartW(Specification, Index * 2 + 1, '[]');
    Delay := ExtractDigitsToIntW(ExtractDelimitedPartW(RangeText, 0, ',-'));
    First := ExtractDigitsToIntW(ExtractDelimitedPartW(RangeText, 1, ',-'));
    Last := ExtractDigitsToIntW(ExtractDelimitedPartW(RangeText, 2, ',-'));
    Count := Abs(First - Last) + 1;
    Inc(FrameCount, Count);
    SetLength(Frames, FrameCount);
    SetLength(Delays, FrameCount);
    for FrameOffset := 0 to Count - 1 do
    begin
      Frames[FrameCount - Count + FrameOffset] := First;
      Delays[FrameCount - Count + FrameOffset] := Delay;
      if First < Last then Inc(First) else Dec(First);
    end;
  end;
end;
{ @end $65B9D4 }

{ @routine $65BC2C TShip2SE_CreateEmpty }
constructor TShip2SE.CreateEmpty;
begin
  inherited CreateEmpty;
  AlphaLimit := 255;
  AngleOverride := -1;
end;
{ @end $65BC2C }

{ @routine $65BC70 TShip2SE_Create }
constructor TShip2SE.Create(const GraphKey: WideString; UnusedPosition: TPoint);
begin
  AngleOverride := -1;
  if CountDelimitedPartsW(GraphKey, ',') > 1 then
  begin
    inherited Create(ExtractDelimitedPartW(GraphKey, 0, ','), UnusedPosition);
    AlphaLimit := ExtractDigitsToIntW(ExtractDelimitedPartW(GraphKey, 1, ','));
  end
  else
  begin
    inherited Create(GraphKey, UnusedPosition);
    AlphaLimit := 255;
  end;
end;
{ @end $65BC70 }

{ @routine $65BD64 TShip2SE_Destroy }
destructor TShip2SE.Destroy;
begin
  StopStateTimer;
  StopAnimationTimer;
  CurrentAnimation := nil;
  NextAnimation := nil;
  if not SharedAnimations then
  begin
    while FirstAnimation <> nil do DeleteAnimation(LastAnimation);
    while FirstReducedAnimation <> nil do DeleteReducedAnimation(LastReducedAnimation);
  end;
  SharedAnimations := False;
  inherited Destroy;
end;
{ @end $65BD64 }

{ @routine $65BDE8 TShip2SE_CopyTo }
procedure TShip2SE.CopyTo(Destination: TObjectSE);
var
  Ship: TShip2SE;
  Index: Integer;
begin
  inherited CopyTo(Destination);
  Ship := Destination as TShip2SE;
  Ship.ImagePath := ImagePath;
  Ship.ReducedImagePath := ReducedImagePath;
  Ship.ImageSize := ImageSize;
  Ship.ImageScale := ImageScale;
  Ship.ImageOrigin := ImageOrigin;
  Ship.ImageCenter := ImageCenter;
  Ship.Angle := Angle;
  Ship.Alpha := Alpha;
  Ship.AlphaLimit := AlphaLimit;
  Ship.MinimapImagePath := MinimapImagePath;
  Ship.MinimapImageOrigin := MinimapImageOrigin;
  Ship.StateIntervalMs := StateIntervalMs;
  Ship.SharedAnimations := True;
  Ship.FirstAnimation := FirstAnimation;
  Ship.LastAnimation := LastAnimation;
  Ship.DefaultAnimation := DefaultAnimation;
  Ship.FirstReducedAnimation := FirstReducedAnimation;
  Ship.LastReducedAnimation := LastReducedAnimation;
  Ship.DefaultReducedAnimation := DefaultReducedAnimation;
  Ship.TotalAnimationWeight := TotalAnimationWeight;
  Ship.TotalReducedAnimationWeight := TotalReducedAnimationWeight;
  for Index := Low(TailOrigins) to High(TailOrigins) do Ship.TailOrigins[Index] := TailOrigins[Index];
  Ship.TailPrefix := TailPrefix;
  Ship.WeaponPortCount := WeaponPortCount;
  for Index := Low(WeaponPorts) to High(WeaponPorts) do Ship.WeaponPorts[Index] := WeaponPorts[Index];
  Ship.SmallSize := SmallSize;
  Ship.LargeSize := LargeSize;
  Ship.TargetSizeScale := TargetSizeScale;
end;
{ @end $65BDE8 }

{ @routine $65BF8C TShip2SE_CopyDataFromMirrorImage }
procedure TShip2SE.CopyDataFromMirrorImage(Destination: TObjectSE);
var
  Ship: TShip2SE;
  SourceAnimation, DestinationAnimation: TShip2AnimSE;
  Index: Integer;
begin
  Ship := Destination as TShip2SE;
  Ship.GraphKey := GraphKey;
  if (Ship.ImagePath <> ImagePath) or (Ship.ReducedImagePath <> ReducedImagePath) then
  begin
    AppendLogLineThreadSafe('Warning from CopyDataFromMirrorImage: image mismatch');
    Ship.ImagePath := ImagePath;
    Ship.ReducedImagePath := ReducedImagePath;
  end;
  Ship.MinimapImagePath := MinimapImagePath;
  SourceAnimation := FirstAnimation;
  DestinationAnimation := Ship.FirstAnimation;
  while (SourceAnimation <> nil) and (DestinationAnimation <> nil) do
  begin
    if DefaultAnimation = SourceAnimation then Ship.DefaultAnimation := DestinationAnimation;
    DestinationAnimation.Weight := SourceAnimation.Weight;
    DestinationAnimation := DestinationAnimation.Next;
    SourceAnimation := SourceAnimation.Next;
  end;
  if (SourceAnimation <> nil) or (DestinationAnimation <> nil) then
    AppendLogLineThreadSafe('Warning from CopyDataFromMirrorImage: animation mismatch');
  SourceAnimation := FirstReducedAnimation;
  DestinationAnimation := Ship.FirstReducedAnimation;
  while (SourceAnimation <> nil) and (DestinationAnimation <> nil) do
  begin
    if DefaultReducedAnimation = SourceAnimation then Ship.DefaultReducedAnimation := DestinationAnimation;
    DestinationAnimation.Weight := SourceAnimation.Weight;
    DestinationAnimation := DestinationAnimation.Next;
    SourceAnimation := SourceAnimation.Next;
  end;
  if (SourceAnimation <> nil) or (DestinationAnimation <> nil) then
    AppendLogLineThreadSafe('Warning from CopyDataFromMirrorImage: animation mismatch');
  Ship.TotalAnimationWeight := TotalAnimationWeight;
  Ship.TotalReducedAnimationWeight := TotalReducedAnimationWeight;
  for Index := Low(TailOrigins) to High(TailOrigins) do Ship.TailOrigins[Index] := TailOrigins[Index];
  Ship.TailPrefix := TailPrefix;
  Ship.WeaponPortCount := WeaponPortCount;
  for Index := Low(WeaponPorts) to High(WeaponPorts) do Ship.WeaponPorts[Index] := WeaponPorts[Index];
  Ship.SmallSize := SmallSize;
  Ship.LargeSize := LargeSize;
  Ship.TargetSizeScale := TargetSizeScale;
end;
{ @end $65BF8C }

{ @routine $65C1BC TShip2SE_AttachToSpace }
procedure TShip2SE.AttachToSpace(ASpace: TSpaceSE);
var
  Index, Stage: Integer;
begin
  Stage := 0;
  try
    if IsAttachedToSpace then Exit;
    ConfigureLoopSound('Ship');
    ConfigureRandomSound('Ship');
    Stage := 1;
    inherited AttachToSpace(ASpace);
    Stage := 2;
    Image := TRotateImage5GI.Create(nil);
    Stage := 3;
    if Space.MapPanel <> nil then Space.MapPanel.AttachOwnedChild(Image);
    Stage := 4;
    Image.World := True;
    Image.SetDepthByName(DepthExpression);
    Image.Pos := Classes.Point(Trunc(Position.X), Trunc(Position.Y));
    if AngleOverride >= 0 then Image.SetAngle(AngleOverride) else Image.SetAngle(Angle);
    Image.SetAlpha(Math.Min(Alpha, AlphaLimit) shr ASpace.AlphaShift);
    Stage := 5;
    MinimapImage := TAlphaImageGI.Create(SpaceObjectUiLoop.ContentPanel);
    Stage := 6;
    MinimapImage.World := True;
    MinimapImage.SetDepthByName(DepthExpression);
    MinimapImage.Pos := TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale));
    MinimapImage.SetImagePath(MinimapImagePath);
    MinimapImage.ObjectSize := MinimapImage.GetContentSize;
    MinimapImage.Sme := HalfPoint(MinimapImage.GetContentSize);
    Stage := 7;
    if AnimShipFull then CurrentAnimation := FirstAnimation
    else CurrentAnimation := FirstReducedAnimation;
    NextAnimation := CurrentAnimation;
    CurrentFrameIndex := RandomIntRange(0, CurrentAnimation.FrameCount - 1);
    Stage := 8;
    if AnimShipFull then Image.SetImage(ImagePath, Size, RoundPointF(GetOrbitCenter))
    else Image.SetImage(ReducedImagePath, Size, RoundPointF(GetOrbitCenter));
    Image.SetFrameIndex(CurrentAnimation.Frames[CurrentFrameIndex]);
    Stage := 9;
    if TailMode > 0 then
      for Index := Low(TailOrigins) to High(TailOrigins) do
        if TailOrigins[Index].Y > 0 then
        begin
          Tails[Index] := TTailGI.Create(Space.MapPanel);
          if TailEmitIntervalMs > 0 then Tails[Index].EmitIntervalMs := TailEmitIntervalMs;
          Tails[Index].ObjectSize := Classes.Point(1000000, 1000000);
          Tails[Index].Sme := HalfPoint(Tails[Index].ClientSize);
          Tails[Index].SetDepthByName('Tail');
          Tails[Index].World := True;
          Tails[Index].SetImagePath('Bm.Tail.' + TailPrefix + '0' + IntToStr(TailMode - 1));
          Tails[Index].SetEmitting((Alpha = 255) and (Space.AlphaShift = 0));
        end;
    Stage := 10;
    StartAnimationTimer;
    StartStateTimer;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('TShip2SE.Connect');
      AppendLogLineThreadSafe(GraphKey);
      AppendLogLineThreadSafe('lastLabel=' + IntToWideString(RotateImageConstructionStage));
      AppendLogLineThreadSafe('self=' + IntToWideString(Integer(Self)));
      AppendLogLineThreadSafe('sp=' + IntToWideString(Integer(ASpace)));
      AppendLogLineThreadSafe('FSpace=' + IntToWideString(Integer(Space)));
      AppendLogLineThreadSafe('FImage=' + IntToWideString(Integer(Image)));
      if Space <> nil then AppendLogLineThreadSafe('PGI=' + IntToWideString(Integer(Space.MapPanel)));
      raise Exception.Create('Error in procedure TShip2SE.Connect, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $65C1BC }

{ @routine $65CB08 TShip2SE_DetachFromSpace }
procedure TShip2SE.DetachFromSpace;
var
  Index: Integer;
begin
  if IsAttachedToSpace then
  begin
    StopStateTimer;
    StopAnimationTimer;
    CurrentAnimation := nil;
    NextAnimation := nil;
    Image.IsActive := False;
    Image.Free;
    Image := nil;
    MinimapImage.Free;
    MinimapImage := nil;
    for Index := Low(Tails) to High(Tails) do
      if Tails[Index] <> nil then
      begin
        Tails[Index].Free;
        Tails[Index] := nil;
      end;
    inherited DetachFromSpace;
  end;
end;
{ @end $65CB08 }

{ @routine $65CB98 TShip2SE_SetTailMode }
procedure TShip2SE.SetTailMode(Value: Integer);
var
  Index: Integer;
begin
  TailMode := Value;
  for Index := Low(Tails) to High(Tails) do
    if Tails[Index] <> nil then
    begin
      Tails[Index].IsActive := Value > 0;
      if Value > 0 then
      begin
        if TailMode = 1 then
          if Tails[Index].GetImagePath <> 'Bm.Tail.' + TailPrefix + '00' then
          begin
            Tails[Index].SetImagePath('Bm.Tail.' + TailPrefix + '00');
            Tails[Index].SetEmitting((Alpha = 255) and (Space.AlphaShift = 0));
            Continue;
          end;
        if TailMode = 2 then
          if Tails[Index].GetImagePath <> 'Bm.Tail.' + TailPrefix + '01' then
          begin
            Tails[Index].SetImagePath('Bm.Tail.' + TailPrefix + '01');
            Tails[Index].SetEmitting((Alpha = 255) and (Space.AlphaShift = 0));
          end;
      end;
    end;
end;
{ @end $65CB98 }

{ @routine $65CD78 TShip2SE_GetImagePath }
function TShip2SE.GetImagePath: WideString;
begin
  if AnimShipFull then Result := ImagePath else Result := ReducedImagePath;
end;
{ @end $65CD78 }

{ @routine $65CDA8 TShip2SE_SetSize }
procedure TShip2SE.SetSize(Value: TPoint);
begin
  if (Size.X <> Value.X) or (Size.Y <> Value.Y) then
  begin
    inherited SetSize(Value);
    ImageScale.X := Size.X / ImageSize.X;
    ImageScale.Y := Size.Y / ImageSize.Y;
  end;
end;
{ @end $65CDA8 }

{ @routine $65CDF0 TShip2SE_SetPosition }
procedure TShip2SE.SetPosition(APosition: TPointF);
var
  PixelPosition: TPoint;
  Index: Integer;
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    PixelPosition := Classes.Point(Trunc(APosition.X), Trunc(APosition.Y));
    Image.Pos := PixelPosition;
    MinimapImage.Pos := TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale));
    for Index := Low(Tails) to High(Tails) do
      if Tails[Index] <> nil then Tails[Index].EmitterPosition := ImagePointToWorld(TailOrigins[Index]);
  end;
end;
{ @end $65CDF0 }

{ @routine $65CED4 TShip2SE_SetTailDepth }
procedure TShip2SE.SetTailDepth(Value: Single);
var
  Index: Integer;
begin
  if TailMode > 0 then
    for Index := Low(Tails) to High(Tails) do
    begin
      if Tails[Index] = nil then Break;
      Tails[Index].SetDepth(Value);
    end;
end;
{ @end $65CED4 }

{ @routine $65CF10 TShip2SE_SetDepth }
procedure TShip2SE.SetDepth(Value: Single);
begin
  Image.SetDepth(Value);
end;
{ @end $65CF10 }

{ @routine $65CF2C TShip2SE_GetDepth }
function TShip2SE.GetDepth: Single;
begin
  Result := Image.Depth;
end;
{ @end $65CF2C }

{ @routine $65CF40 TShip2SE_GetAngle }
function TShip2SE.GetAngle: Byte;
begin
  Result := Angle;
end;
{ @end $65CF40 }

{ @routine $65CF48 TShip2SE_SetAngle }
procedure TShip2SE.SetAngle(Value: Byte);
var
  Index: Integer;
  Velocity: TPointF;
begin
  Angle := Value;
  if IsAttachedToSpace then
  begin
    if AngleOverride >= 0 then Image.SetAngle(AngleOverride) else Image.SetAngle(Angle);
    Velocity.X := 0;
    Velocity.Y := 0;
    for Index := Low(Tails) to High(Tails) do
      if Tails[Index] <> nil then
      begin
        Tails[Index].EmitterPosition := ImagePointToWorld(TailOrigins[Index]);
        Tails[Index].SegmentVelocity := Velocity;
      end;
  end;
end;
{ @end $65CF48 }

{ @routine $65CFF8 TShip2SE_OffsetTailsAlongHeading }
procedure TShip2SE.OffsetTailsAlongHeading(Distance: Single);
var
  Radians: Single;
  Delta: TPointF;
  Index: Integer;
begin
  if IsAttachedToSpace then
  begin
    Radians := GetAngle / 256 * (2 * Pi) + Pi;
    Delta.X := Sin(Radians) * Distance;
    Delta.Y := Cos(Radians) * -Distance;
    for Index := Low(Tails) to High(Tails) do
      if Tails[Index] <> nil then Tails[Index].OffsetSegments(Delta);
  end;
end;
{ @end $65CFF8 }

{ @routine $65D0AC TShip2SE_OffsetTails }
procedure TShip2SE.OffsetTails(Delta: TPointF);
var
  Index: Integer;
begin
  for Index := Low(Tails) to High(Tails) do
    if Tails[Index] <> nil then Tails[Index].OffsetSegments(Delta);
end;
{ @end $65D0AC }

{ @routine $65D0E0 TShip2SE_SetTailsEmitting }
procedure TShip2SE.SetTailsEmitting(Value: Boolean);
var
  Index: Integer;
begin
  for Index := Low(Tails) to High(Tails) do
    if Tails[Index] <> nil then Tails[Index].SetEmitting(Value);
end;
{ @end $65D0E0 }

{ @routine $65D108 TShip2SE_GetAlpha }
function TShip2SE.GetAlpha: Byte;
begin
  Result := Alpha;
end;
{ @end $65D108 }

{ @routine $65D110 TShip2SE_SetAlpha }
procedure TShip2SE.SetAlpha(Value: Byte);
var
  Index: Integer;
begin
  Alpha := Value;
  if IsAttachedToSpace then
  begin
    Image.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
    for Index := Low(Tails) to High(Tails) do
      if Tails[Index] <> nil then Tails[Index].SetEmitting((Alpha = 255) and (Space.AlphaShift = 0));
  end;
end;
{ @end $65D110 }

{ @routine $65D178 TShip2SE_GetOrbitCenter }
function TShip2SE.GetOrbitCenter: TPointF;
begin
  Result.X := ImageOrigin.X * ImageScale.X;
  Result.Y := ImageOrigin.Y * ImageScale.Y;
end;
{ @end $65D178 }

{ @routine $65D18C TShip2SE_ScaleImagePoint }
function TShip2SE.ScaleImagePoint(Point: TPointF): TPointF;
begin
  Result.X := (Point.X - ImageOrigin.X) * ImageScale.X;
  Result.Y := (Point.Y - ImageOrigin.Y) * ImageScale.Y;
end;
{ @end $65D18C }

{ @routine $65D1B8 TShip2SE_ImagePointToWorld }
function TShip2SE.ImagePointToWorld(Point: TPointF): TPointF;
var
  Radians, Sine, Cosine: Double;
begin
  Point := ScaleImagePoint(Point);
  Radians := Angle / 256 * GameTwoPi;
  Sine := Sin(Radians);
  Cosine := Cos(Radians);
  Result.X := Point.X * Cosine - Point.Y * Sine + Position.X;
  Result.Y := Point.X * Sine + Point.Y * Cosine + Position.Y;
end;
{ @end $65D1B8 }

{ @routine $65D274 TShip2SE_GetTargetPoint }
function TShip2SE.GetTargetPoint(Heading: Byte; Seed: Integer): TPointF;
var
  Radians, Sine, Cosine: Double;
  Point: TPointF;
begin
  Point := ScaleImagePoint(MakePointF(Seed mod ImageSize.X, (Seed * 45452 + 3247) mod ImageSize.Y));
  Point.X := Point.X * TargetSizeScale;
  Point.Y := Point.Y * TargetSizeScale;
  Radians := Heading / 256 * GameTwoPi;
  Sine := Sin(Radians);
  Cosine := Cos(Radians);
  Result.X := Point.X * Cosine - Point.Y * Sine + Position.X;
  Result.Y := Point.X * Sine + Point.Y * Cosine + Position.Y;
end;
{ @end $65D274 }

{ @routine $65D36C TShip2SE_GetWeaponPortPoint }
function TShip2SE.GetWeaponPortPoint(Heading: Byte; Seed: Cardinal): TPointF;
var
  Radians, Sine, Cosine: Double;
  Point: TPointF;
begin
  if WeaponPortCount < 1 then
  begin
    Result := Position;
    Exit;
  end;
  Point := ScaleImagePoint(WeaponPorts[1 + (Sqr(Seed) div 11) mod WeaponPortCount]);
  Radians := Heading / 256 * GameTwoPi;
  Sine := Sin(Radians);
  Cosine := Cos(Radians);
  Result.X := Point.X * Cosine - Point.Y * Sine + Position.X;
  Result.Y := Point.X * Sine + Point.Y * Cosine + Position.Y;
end;
{ @end $65D36C }

{ @routine $65D444 TShip2SE_HitTestCursor }
function TShip2SE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Image.HitTestPixel(Image.MessageLoop.GetCursorPoint);
end;
{ @end $65D444 }

{ @routine $65D478 TShip2SE_AddAnimation }
function TShip2SE.AddAnimation: TShip2AnimSE;
var
  Animation: TShip2AnimSE;
begin
  Animation := TShip2AnimSE.Create;
  if LastAnimation <> nil then LastAnimation.Next := Animation;
  Animation.Prev := LastAnimation;
  Animation.Next := nil;
  LastAnimation := Animation;
  if FirstAnimation = nil then FirstAnimation := Animation;
  Result := Animation;
end;
{ @end $65D478 }

{ @routine $65D4BC TShip2SE_DeleteAnimation }
procedure TShip2SE.DeleteAnimation(Animation: TShip2AnimSE);
begin
  if Animation.Prev <> nil then Animation.Prev.Next := Animation.Next;
  if Animation.Next <> nil then Animation.Next.Prev := Animation.Prev;
  if LastAnimation = Animation then LastAnimation := Animation.Prev;
  if FirstAnimation = Animation then FirstAnimation := Animation.Next;
  Animation.Free;
end;
{ @end $65D4BC }

{ @routine $65D504 TShip2SE_AddReducedAnimation }
function TShip2SE.AddReducedAnimation: TShip2AnimSE;
var
  Animation: TShip2AnimSE;
begin
  Animation := TShip2AnimSE.Create;
  if LastReducedAnimation <> nil then LastReducedAnimation.Next := Animation;
  Animation.Prev := LastReducedAnimation;
  Animation.Next := nil;
  LastReducedAnimation := Animation;
  if FirstReducedAnimation = nil then FirstReducedAnimation := Animation;
  Result := Animation;
end;
{ @end $65D504 }

{ @routine $65D548 TShip2SE_DeleteReducedAnimation }
procedure TShip2SE.DeleteReducedAnimation(Animation: TShip2AnimSE);
begin
  if Animation.Prev <> nil then Animation.Prev.Next := Animation.Next;
  if Animation.Next <> nil then Animation.Next.Prev := Animation.Prev;
  if LastReducedAnimation = Animation then LastReducedAnimation := Animation.Prev;
  if FirstReducedAnimation = Animation then FirstReducedAnimation := Animation.Next;
  Animation.Free;
end;
{ @end $65D548 }

{ @routine $65D590 TShip2SE_StartAnimationTimer }
procedure TShip2SE.StartAnimationTimer;
var
  Delay: Integer;
begin
  StopAnimationTimer;
  Delay := CurrentAnimation.Delays[CurrentFrameIndex];
  AnimationTimer := Space.Screen.ScheduleCallbackTimer(Delay, Delay, AdvanceAnimation);
end;
{ @end $65D590 }

{ @routine $65D5D0 TShip2SE_StopAnimationTimer }
procedure TShip2SE.StopAnimationTimer;
begin
  if AnimationTimer <> 0 then
  begin
    Space.Screen.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := 0;
  end;
end;
{ @end $65D5D0 }

{ @routine $65D5F4 TShip2SE_StartStateTimer }
procedure TShip2SE.StartStateTimer;
begin
  StopStateTimer;
  SelectNextAnimation(0, 0);
  StateTimer := Space.Screen.ScheduleCallbackTimer(StateIntervalMs, StateIntervalMs, SelectNextAnimation);
end;
{ @end $65D5F4 }

{ @routine $65D630 TShip2SE_StopStateTimer }
procedure TShip2SE.StopStateTimer;
begin
  if StateTimer <> 0 then
  begin
    Space.Screen.CancelCallbackTimer(StateTimer);
    StateTimer := 0;
  end;
end;
{ @end $65D630 }

{ @routine $65D654 TShip2SE_AdvanceAnimation }
procedure TShip2SE.AdvanceAnimation(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  with Image.HitTestBounds do
    if (GameScreenWidth * -0.1 > Right) or (GameScreenWidth * 1.1 < Left) or
       (GameScreenHeight * -0.1 > Bottom) or (GameScreenHeight * 1.1 < Top) then
    begin
      SetTailsEmitting(False);
      Exit;
    end;
  SetTailsEmitting(True);
  Inc(CurrentFrameIndex);
  if CurrentAnimation.FrameCount > CurrentFrameIndex then
  begin
    Image.SetFrameIndex(CurrentAnimation.Frames[CurrentFrameIndex]);
    StartAnimationTimer;
    Exit;
  end;
  CurrentFrameIndex := 0;
  if AnimShipFull then
  begin
    if CurrentAnimation = LastAnimation then CurrentAnimation := DefaultAnimation
    else CurrentAnimation := NextAnimation;
    NextAnimation := DefaultAnimation;
  end
  else
  begin
    if CurrentAnimation = LastReducedAnimation then CurrentAnimation := DefaultReducedAnimation
    else CurrentAnimation := NextAnimation;
    NextAnimation := DefaultReducedAnimation;
  end;
  Image.SetFrameIndex(CurrentAnimation.Frames[CurrentFrameIndex]);
  StartAnimationTimer;
end;
{ @end $65D654 }

{ @routine $65D810 TShip2SE_SelectNextAnimation }
procedure TShip2SE.SelectNextAnimation(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var
  Weight: Integer;
  Animation: TShip2AnimSE;
begin
  if AnimShipFull then
  begin
    if NextAnimation = LastAnimation then Exit;
    Weight := Random(TotalAnimationWeight);
    Animation := FirstAnimation;
    while Animation <> nil do
    begin
      if Weight < Animation.Weight then
      begin
        NextAnimation := Animation;
        Exit;
      end;
      Dec(Weight, Animation.Weight);
      Animation := Animation.Next;
    end;
  end
  else
  begin
    if NextAnimation = LastReducedAnimation then Exit;
    Weight := Random(TotalReducedAnimationWeight);
    Animation := FirstReducedAnimation;
    while Animation <> nil do
    begin
      if Weight < Animation.Weight then
      begin
        NextAnimation := Animation;
        Exit;
      end;
      Dec(Weight, Animation.Weight);
      Animation := Animation.Next;
    end;
  end;
end;
{ @end $65D810 }

{ @routine $65D89C TShip2SE_DrawMap }
procedure TShip2SE.DrawMap;
var
  CurrentProcess: TProcessSE;
begin
  CurrentProcess := Space.Process as TProcessSE;
  if (PointDistanceSquared(Position, CurrentProcess.RadarCenter) < Sqr(CurrentProcess.RadarRange)) or
     ((AlternateImagePath <> '') and (CurrentProcess.RadarRange > 0)) or
     ((GetPlayer <> nil) and (GetPlayer.Graphic = Self)) then
    MinimapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $65D89C }

{ @routine $65D938 TShip2SE_LoadTemplate }
procedure TShip2SE.LoadTemplate(Block: TBlockParEC);
var
  AnimBlock: TBlockParEC;
  Index: Integer;
  Normal, Animation, ReducedNormal, ReducedAnimation: TShip2AnimSE;
begin
  inherited LoadTemplate(Block);
  SharedAnimations := False;
  if Block.CountParams('AngleOverride') > 0 then AngleOverride := ExtractDigitsToIntW(Block.GetParam('AngleOverride'))
  else AngleOverride := -1;
  SetAngle(0);
  SetAlpha(255);
  ImagePath := Block.GetParam('Image');
  ReducedImagePath := Block.GetParam('ImageS');
  MinimapImagePath := Block.GetParam('ImageMap');
  if Block.CountParams('ImageI') > 0 then AlternateImagePath := Block.GetParam('ImageI')
  else AlternateImagePath := '';
  if Block.CountParams('PanelPartnerImage') > 0 then PanelPartnerImage := Block.GetParam('PanelPartnerImage')
  else PanelPartnerImage := '';
  ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
  MinimapImageOrigin := GetPointGI(Block.GetParam('SmeImageMap'));
  ImageSize := GetPointGI(Block.GetParam('SizeImage'));
  ImageCenter := PointToPointF(GetPointGI(Block.GetParam('SmeCenterImage')));
  for Index := Low(TailOrigins) to High(TailOrigins) do
  begin
    TailOrigins[Index] := MakePointF(0, 0);
    if Block.CountParams('Tail' + IntToWideString(Index)) > 0 then
      TailOrigins[Index] := PointToPointF(GetPointGI(Block.GetParam('Tail' + IntToWideString(Index))));
  end;
  if Block.CountParams('TailPrefix') > 0 then TailPrefix := Block.GetParam('TailPrefix')
  else TailPrefix := '';
  WeaponPortCount := 0;
  for Index := Low(WeaponPorts) to High(WeaponPorts) do
  begin
    if Block.CountParams('WeaponPort' + IntToWideString(Index)) <= 0 then Break;
    WeaponPorts[Index] := PointToPointF(GetPointGI(Block.GetParam('WeaponPort' + IntToWideString(Index))));
    Inc(WeaponPortCount);
  end;
  StateIntervalMs := StrToInt(Block.GetParam('StateTime'));
  AnimBlock := Block.GetBlock('Anim');
  Normal := AddAnimation;
  Normal.Load(AnimBlock.GetParam('Normal'));
  TotalAnimationWeight := Normal.Weight;
  DefaultAnimation := LastAnimation;
  Index := 0;
  while AnimBlock.CountParams(IntToStr(Index)) > 0 do
  begin
    Animation := AddAnimation;
    Animation.Load(AnimBlock.GetParam(IntToStr(Index)));
    Inc(TotalAnimationWeight, Animation.Weight);
    if LastAnimation.Weight > DefaultAnimation.Weight then DefaultAnimation := LastAnimation;
    Inc(Index);
  end;
  AnimBlock := Block.GetBlock('AnimS');
  ReducedNormal := AddReducedAnimation;
  ReducedNormal.Load(AnimBlock.GetParam('Normal'));
  TotalReducedAnimationWeight := ReducedNormal.Weight;
  DefaultReducedAnimation := LastReducedAnimation;
  Index := 0;
  while AnimBlock.CountParams(IntToStr(Index)) > 0 do
  begin
    ReducedAnimation := AddReducedAnimation;
    ReducedAnimation.Load(AnimBlock.GetParam(IntToStr(Index)));
    Inc(TotalReducedAnimationWeight, ReducedAnimation.Weight);
    if LastReducedAnimation.Weight > DefaultReducedAnimation.Weight then DefaultReducedAnimation := LastReducedAnimation;
    Inc(Index);
  end;
  if Block.CountParams('SizeSmall') > 0 then SmallSize := ExtractDigitsToIntW(Block.GetParam('SizeSmall'))
  else SmallSize := 0;
  if Block.CountParams('SizeLarge') > 0 then LargeSize := ExtractDigitsToIntW(Block.GetParam('SizeLarge'))
  else LargeSize := 0;
  if Block.CountParams('TargetSizeK') > 0 then TargetSizeScale := ExtractDecimalToSingleW(Block.GetParam('TargetSizeK'))
  else TargetSizeScale := 0.3;
  ObjectSize := Classes.Point(64, 64);
end;
{ @end $65D938 }

{ @routine $65E228 TShip2SE_ApplyConfig }
procedure TShip2SE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
  if Block.CountParams('Angle') > 0 then SetAngle(StrToInt(Block.GetParam('Angle')));
end;
{ @end $65E228 }

{ @routine $65E2C4 TShip2SE_QueueImageLoad }
procedure TShip2SE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  MainImage: TRotateImage5GI;
  MapImage: TAlphaImageGI;
begin
  MainImage := TRotateImage5GI.Create(Owner);
  if AnimShipFull then MainImage.QueueImagePath(PendingLoads, ImagePath)
  else MainImage.QueueImagePath(PendingLoads, ReducedImagePath);
  MainImage.Free;
  MapImage := TAlphaImageGI.Create(Owner);
  MapImage.SetImagePath(MinimapImagePath);
  MapImage.QueueImageLoad(PendingLoads);
  MapImage.Free;
end;
{ @end $65E2C4 }

end.
