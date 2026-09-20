unit GI_SBPath;
// Unit bracket (inferred): .text 0x00492768..0x00492F4D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class ownership follows reference/unit_ownership.json.


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
    constructor Create(Owner: TObjectGI); // @addr $4928B8
    destructor Destroy; override; // @addr $492950
    procedure Clear; override; // @addr $492984
    procedure SetImagePath(Path: WideString); // @addr $4929C4
    procedure SetPositionValue(Value: Integer); // @addr $492A7C
    procedure UpdateThumbPosition; // @addr $492B14
    function PositionFromPointIndex(Index: Integer): Integer; // @addr $492BC4
    function FindClosestPoint(Point: TPoint; var DistanceSquared: Integer): Integer; // @addr $492C34
    procedure OnActivate; override; // @addr $492CDC
    procedure OnDeactivate; override; // @addr $492CF8
    procedure OnMouseEnter; override; // @addr $492D14
    procedure OnMouseLeave; override; // @addr $492D28
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $492D3C
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $492E30
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $492DFC
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $492EF4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $492F28
    procedure LoadPathProperties(Block: TBlockParEC); // @addr $492F50
  end;

implementation

uses Classes, SysUtils, GI_Main;

{ @routine $4928B8 TSBPathGI_Create }
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
{ @end $4928B8 }

{ @routine $492950 TSBPathGI_Destroy }
destructor TSBPathGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $492950 }

{ @routine $492984 TSBPathGI_Clear }
procedure TSBPathGI.Clear;
begin
  PointCount := 0;
  Points := nil;
  ThumbImage.Clear;
  inherited Clear;
end;
{ @end $492984 }

{ @routine $4929C4 TSBPathGI_SetImagePath }
procedure TSBPathGI.SetImagePath(Path: WideString);
begin
  ThumbImage.SetImagePath(Path);
  ThumbImage.SetSize(ThumbImage.GetContentSize);
  ThumbImage.SetOrigin(Classes.Point(ThumbImage.ClientSize.X div 2, ThumbImage.ClientSize.Y div 2));
end;
{ @end $4929C4 }

{ @routine $492A7C TSBPathGI_SetPositionValue }
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
{ @end $492A7C }

{ @routine $492B14 TSBPathGI_UpdateThumbPosition }
procedure TSBPathGI.UpdateThumbPosition;
begin
  if PointCount < 1 then Exit;
  if Maximum - Minimum < 1 then ThumbImage.SetPosition(Points[0])
  else ThumbImage.SetPosition(Points[Round((Position - Minimum) / (Maximum - Minimum) * (PointCount - 1))]);
end;
{ @end $492B14 }

{ @routine $492BC4 TSBPathGI_PositionFromPointIndex }
function TSBPathGI.PositionFromPointIndex(Index: Integer): Integer;
begin
  if PointCount < 2 then Result := Minimum
  else Result := Round(Index / (PointCount - 1) * (Maximum - Minimum) + Minimum);
end;
{ @end $492BC4 }

{ @routine $492C34 TSBPathGI_FindClosestPoint }
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
{ @end $492C34 }

{ @routine $492CDC TSBPathGI_OnActivate }
procedure TSBPathGI.OnActivate;
begin
  inherited OnActivate;
  Dragging := False;
end;
{ @end $492CDC }

{ @routine $492CF8 TSBPathGI_OnDeactivate }
procedure TSBPathGI.OnDeactivate;
begin
  inherited OnDeactivate;
  Dragging := False;
end;
{ @end $492CF8 }

{ @routine $492D14 TSBPathGI_OnMouseEnter }
procedure TSBPathGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;
{ @end $492D14 }

{ @routine $492D28 TSBPathGI_OnMouseLeave }
procedure TSBPathGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
end;
{ @end $492D28 }

{ @routine $492D3C TSBPathGI_ProcessLeftButtonDown }
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
{ @end $492D3C }

{ @routine $492DFC TSBPathGI_ProcessLeftButtonUp }
procedure TSBPathGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  Dragging := False;
end;
{ @end $492DFC }

{ @routine $492E30 TSBPathGI_ProcessMouseMove }
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
{ @end $492E30 }

{ @routine $492EF4 TSBPathGI_LoadFromConfigPath }
procedure TSBPathGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadPathProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $492EF4 }

{ @routine $492F28 TSBPathGI_LoadFromBlock }
procedure TSBPathGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadPathProperties(Block);
end;
{ @end $492F28 }

{ @routine $492F50 TSBPathGI_LoadPathProperties }
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
{ @end $492F50 }

end.
