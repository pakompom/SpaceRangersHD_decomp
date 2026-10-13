unit SE_Missile;

interface

uses Classes, EC_BlockPar, EC_Struct, GI_MessageLoop, GI_RotateImage5, SE_Space;

type
  TMissileSE = class(TObjectSE) // @size 0x5C
  public
    Angle: Byte; // @offset $4C
    ImageScale: Single; // @offset $50
    Image: TRotateImage5GI; // @offset $54
    AnimationTimer: PSpaceTimerSE; // @offset $58

    destructor Destroy; override; // @addr $5CCCB0
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $5CCCD8 @slot $04 @note "Native diagnostic name: TMissileSE.Connect."
    procedure DetachFromSpace; override; // @addr $5CD2C8
    procedure SetPosition(APosition: TPointF); override; // @addr $5CD30C
    function GetAngle: Byte; override; // @addr $5CD360
    procedure SetAngle(Value: Byte); override; // @addr $5CD368
    function HitTestCursor: Boolean; override; // @addr $5CD388
    procedure AdvanceAnimationTimer(Timer: PSpaceTimerSE; UserData: Integer); // @addr $5CD3BC
    procedure DrawMap; override; // @addr $5CD4B4
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $5CD574
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $5CD608 @note "Native empty override."
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $5CD60C @note "Native empty override."
  end;

implementation

uses SysUtils, Types, EC_Str, Globals, GR_Main, SE_Process;

{ @routine $5CCCB0 TMissileSE_Destroy }
destructor TMissileSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $5CCCB0 }

{ @routine $5CCCD8 TMissileSE_AttachToSpace }
procedure TMissileSE.AttachToSpace(ASpace: TSpaceSE);
var
  Stage: Integer;
begin
  Stage := 0;
  try
    if IsAttachedToSpace then Exit;
    inherited AttachToSpace(ASpace);
    Stage := 1;
    Image := TRotateImage5GI.Create(nil);
    Stage := 2;
    if Space.MapPanel <> nil then Space.MapPanel.AttachOwnedChild(Image);
    Stage := 3;
    Image.World := True;
    Image.SetDepthByName(DepthExpression);
    Image.Pos := Classes.Point(Trunc(Position.X), Trunc(Position.Y));
    Image.SetAngle(Angle);
    Image.SetAlpha(255);
    Stage := 4;
    Image.SetImage('Bm.' + GraphKey,
      Classes.Point(Round(ImageScale * 32.0), Round(ImageScale * 32.0)),
      Classes.Point(Round(ImageScale * 16.0), Round(ImageScale * 16.0)));
    Stage := 5;
    Image.SetFrameIndex(0);
    AnimationTimer := Space.CreateTimer(50, 50, AdvanceAnimationTimer, 0);
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('TMissileSE.Connect');
      AppendLogLineThreadSafe(GraphKey);
      AppendLogLineThreadSafe('lastLabel=' + IntToWideString(RotateImageConstructionStage));
      AppendLogLineThreadSafe('self=' + IntToWideString(Integer(Self)));
      AppendLogLineThreadSafe('sp=' + IntToWideString(Integer(ASpace)));
      AppendLogLineThreadSafe('FSpace=' + IntToWideString(Integer(Space)));
      AppendLogLineThreadSafe('FImage=' + IntToWideString(Integer(Image)));
      if Space <> nil then AppendLogLineThreadSafe('PGI=' + IntToWideString(Integer(Space.MapPanel)));
      raise Exception.Create('Error in procedure TMissileSE.Connect, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5CCCD8 }

{ @routine $5CD2C8 TMissileSE_DetachFromSpace }
procedure TMissileSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if AnimationTimer <> nil then
  begin
    Space.DeleteTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  Image.IsActive := False;
  Image.Free;
  Image := nil;
  inherited DetachFromSpace;
end;
{ @end $5CD2C8 }

{ @routine $5CD30C TMissileSE_SetPosition }
procedure TMissileSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
    Image.Pos := Classes.Point(Trunc(APosition.X), Trunc(APosition.Y));
end;
{ @end $5CD30C }

{ @routine $5CD360 TMissileSE_GetAngle }
function TMissileSE.GetAngle: Byte;
begin
  Result := Angle;
end;
{ @end $5CD360 }

{ @routine $5CD368 TMissileSE_SetAngle }
procedure TMissileSE.SetAngle(Value: Byte);
begin
  Angle := Value;
  if IsAttachedToSpace then Image.SetAngle(Angle);
end;
{ @end $5CD368 }

{ @routine $5CD388 TMissileSE_HitTestCursor }
function TMissileSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Image.HitTestPixel(Image.MessageLoop.GetCursorPoint);
end;
{ @end $5CD388 }

{ @routine $5CD3BC TMissileSE_AdvanceAnimationTimer }
procedure TMissileSE.AdvanceAnimationTimer(Timer: PSpaceTimerSE; UserData: Integer);
var
  Bounds: PRect;
begin
  Bounds := @Image.HitTestBounds;
  if (GameScreenWidth * -0.1 <= Bounds.Right) and
     (GameScreenWidth * 1.1 >= Bounds.Left) and
     (GameScreenHeight * -0.1 <= Bounds.Bottom) and
     (GameScreenHeight * 1.1 >= Bounds.Top) then
  begin
    Image.SetFrameIndex(Image.FrameIndex + 1);
    with Image do
      if Integer(GetFrameCount) <= Integer(FrameIndex) then Self.Image.SetFrameIndex(0);
  end;
end;
{ @end $5CD3BC }

{ @routine $5CD4B4 TMissileSE_DrawMap }
procedure TMissileSE.DrawMap;
var
  CurrentProcess: TProcessSE;
  X, Y: Integer;
begin
  CurrentProcess := Space.Process as TProcessSE;
    if PointDistanceSquared(Position, CurrentProcess.RadarCenter) < Sqr(CurrentProcess.RadarRange) then
    begin
      X := Round(Position.X * Space.MinimapScale) + (RenderScratchBuffer.Width shr 1);
      Y := Round(Position.Y * Space.MinimapScale) + (RenderScratchBuffer.Height shr 1);
      if (X >= 0) and (Integer(RenderScratchBuffer.Width) > X) and
         (Y >= 0) and (Integer(RenderScratchBuffer.Height) > Y) then
        RenderScratchBuffer.SetPixel16(X, Y, CurrentPixelFormat.PackRgbBytes(0, 255, 0));
    end;
end;
{ @end $5CD4B4 }

{ @routine $5CD574 TMissileSE_LoadTemplate }
procedure TMissileSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  SetAngle(0);
  if Block.CountParams('Scale') > 0 then
    ImageScale := ExtractDecimalToSingleW(Block.GetParam('Scale'))
  else ImageScale := 1.0;
end;
{ @end $5CD574 }

{ @routine $5CD608 TMissileSE_ApplyConfig }
procedure TMissileSE.ApplyConfig(Block: TBlockParEC);
begin
end;
{ @end $5CD608 }

{ @routine $5CD60C TMissileSE_QueueImageLoad }
procedure TMissileSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
end;
{ @end $5CD60C }

end.
