unit GI_SBPath;


interface

uses EC_BlockPar, GI_Image, GI_MessageLoop, Types;

type
  TSBPathPointsGI = array of TPoint;
  TSBPathGI = class(TObjectGI) // @size $148
  public
    PointCount: Integer; // @offset $120
    Points: array of TPoint; // @offset $124
    Minimum: Integer; // @offset $128
    Maximum: Integer; // @offset $12C
    Position: Integer; // @offset $130
    Dragging: Boolean; // @offset $134
    ThumbImage: TImageGI; // @offset $138
    HitRadius: Integer; // @offset $13C
    ChangeCallback: TObjectNotifyEventGI; // @offset $140
    constructor Create(Owner: TObjectGI); // @addr $4BB6F8
    destructor Destroy; override; // @addr $4BB76C
    procedure Clear; override; // @addr $4BB794
    procedure SetImagePath(Path: WideString); // @addr $4BB7C4
    procedure SetPositionValue(Value: Integer); // @addr $4BB860
    procedure UpdateThumbPosition; // @addr $4BB8B0
    function PositionFromPointIndex(Index: Integer): Integer; // @addr $4BB938
    function FindClosestPoint(Point: TPoint; var DistanceSquared: Integer): Integer; // @addr $4BB998
    procedure OnActivate; override; // @addr $4BBA1C
    procedure OnDeactivate; override; // @addr $4BBA30
    procedure OnMouseEnter; override; // @addr $4BBA44
    procedure OnMouseLeave; override; // @addr $4BBA4C
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4BBA54
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4BBB14
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4BBAEC
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4BBBAC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4BBBD8
    procedure LoadPathProperties(Block: TBlockParEC); // @addr $4BBBF4
  end;

implementation

uses Classes, SysUtils, GI_Main;

{ @routine $4BB6F8 TSBPathGI_Create }
constructor TSBPathGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ThumbImage := TImageGI.Create(Self);
  Minimum := 0;
  Maximum := 100;
  Position := 0;
  HitRadius := 40;
  UpdateThumbPosition;
end;
{ @end $4BB6F8 }

{ @routine $4BB76C TSBPathGI_Destroy }
destructor TSBPathGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4BB76C }

{ @routine $4BB794 TSBPathGI_Clear }
procedure TSBPathGI.Clear;
begin
  PointCount := 0;
  Points := nil;
  ThumbImage.Clear;
  inherited Clear;
end;
{ @end $4BB794 }

{ @routine $4BB7C4 TSBPathGI_SetImagePath }
procedure TSBPathGI.SetImagePath(Path: WideString);
begin
  ThumbImage.ImageSourcePath := Path;
  ThumbImage.ObjectSize := ThumbImage.GetContentSize;
  ThumbImage.Sme := Classes.Point(ThumbImage.ClientSize.X div 2, ThumbImage.ClientSize.Y div 2);
end;
{ @end $4BB7C4 }

{ @routine $4BB860 TSBPathGI_SetPositionValue }
procedure TSBPathGI.SetPositionValue(Value: Integer);
begin
  if Position = Value then Exit;
  if Value < Minimum then Value := Minimum;
  if Value > Maximum then Value := Maximum;
  if Position = Value then Exit;
  Position := Value;
  UpdateThumbPosition;
  if Assigned(ChangeCallback) then ChangeCallback(Self);
end;
{ @end $4BB860 }

{ @routine $4BB8B0 TSBPathGI_UpdateThumbPosition }
procedure TSBPathGI.UpdateThumbPosition;
begin
  if PointCount < 1 then Exit;
  if Maximum - Minimum < 1 then ThumbImage.Pos := Points[0]
  else ThumbImage.Pos := Points[Round((Position - Minimum) / (Maximum - Minimum) * (PointCount - 1))];
end;
{ @end $4BB8B0 }

{ @routine $4BB938 TSBPathGI_PositionFromPointIndex }
function TSBPathGI.PositionFromPointIndex(Index: Integer): Integer;
begin
  if PointCount < 2 then Result := Minimum
  else Result := Round(Index / (PointCount - 1) * (Maximum - Minimum) + Minimum);
end;
{ @end $4BB938 }

{ @routine $4BB998 TSBPathGI_FindClosestPoint }
function TSBPathGI.FindClosestPoint(Point: TPoint; var DistanceSquared: Integer): Integer;
var BestDistance, BestIndex, Distance, I: Integer;
begin
  BestDistance := 99999999;
  BestIndex := -1;
  for I := 0 to PointCount - 1 do
  begin
    Distance := Sqr(Point.X - Points[I].X) + Sqr(Point.Y - Points[I].Y);
    if Distance < BestDistance then
    begin
      BestDistance := Distance;
      BestIndex := I;
    end;
  end;
  DistanceSquared := BestDistance;
  Result := BestIndex;
end;
{ @end $4BB998 }

{ @routine $4BBA1C TSBPathGI_OnActivate }
procedure TSBPathGI.OnActivate;
begin
  inherited OnActivate;
  Dragging := False;
end;
{ @end $4BBA1C }

{ @routine $4BBA30 TSBPathGI_OnDeactivate }
procedure TSBPathGI.OnDeactivate;
begin
  inherited OnDeactivate;
  Dragging := False;
end;
{ @end $4BBA30 }

{ @routine $4BBA44 TSBPathGI_OnMouseEnter }
procedure TSBPathGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;
{ @end $4BBA44 }

{ @routine $4BBA4C TSBPathGI_OnMouseLeave }
procedure TSBPathGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
end;
{ @end $4BBA4C }

{ @routine $4BBA54 TSBPathGI_ProcessLeftButtonDown }
procedure TSBPathGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
var Index, Distance: Integer;
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if PointCount < 1 then Exit;
  Index := FindClosestPoint(ToLocalPoint(Point), Distance);
  if Sqr(HitRadius) > Distance then
  begin
    Position := PositionFromPointIndex(Index);
    UpdateThumbPosition;
    Dragging := True;
    if Assigned(ChangeCallback) then ChangeCallback(Self);
  end else Dragging := False;
end;
{ @end $4BBA54 }

{ @routine $4BBAEC TSBPathGI_ProcessLeftButtonUp }
procedure TSBPathGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  Dragging := False;
end;
{ @end $4BBAEC }

{ @routine $4BBB14 TSBPathGI_ProcessMouseMove }
procedure TSBPathGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
var Index, Distance: Integer;
begin
  inherited ProcessMouseMove(KeyState, LocalPosition);
  if not Dragging then Exit;
  Index := FindClosestPoint(ToLocalPoint(Point), Distance);
  if Sqr(HitRadius) > Distance then
  begin
    Position := PositionFromPointIndex(Index);
    UpdateThumbPosition;
    Dragging := True;
    if Assigned(ChangeCallback) then ChangeCallback(Self);
  end else Dragging := False;
end;
{ @end $4BBB14 }

{ @routine $4BBBAC TSBPathGI_LoadFromConfigPath }
procedure TSBPathGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadPathProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4BBBAC }

{ @routine $4BBBD8 TSBPathGI_LoadFromBlock }
procedure TSBPathGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadPathProperties(Block);
end;
{ @end $4BBBD8 }

{ @routine $4BBBF4 TSBPathGI_LoadPathProperties }
procedure TSBPathGI.LoadPathProperties(Block: TBlockParEC);
var Path: TBlockParEC; I: Integer;
begin
  if Block.CountBlocks('Path') > 0 then
  begin
    Points := nil;
    Path := Block.GetBlock('Path');
    PointCount := Path.GetParamCount;
    SetLength(Points, PointCount);
    for I := 0 to PointCount - 1 do Points[I] := GetPointGI(Path.GetParamValue(I));
  end;
  if Block.CountParams('Image') > 0 then SetImagePath(Block.GetParam('Image'));
  if Block.CountParams('Min') > 0 then Minimum := StrToInt(Block.GetParam('Min'));
  if Block.CountParams('Max') > 0 then Maximum := StrToInt(Block.GetParam('Max'));
  if Minimum > Maximum then Minimum := Maximum;
  if Block.CountParams('Position') > 0 then SetPositionValue(StrToInt(Block.GetParam('Position')));
  if Block.CountParams('RadiusHit') > 0 then HitRadius := StrToInt(Block.GetParam('RadiusHit'));
  UpdateThumbPosition;
end;
{ @end $4BBBF4 }

end.
