unit GI_SBPath;
// Unit bracket (inferred): .text 0x004B24B0..0x004B2C95; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
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
    constructor Create(Owner: TObjectGI); // @addr $4B2600 @ida "TSBPathGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $4B2698 @ida "void __usercall $name(TSBPathGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr $4B26CC
    procedure SetImagePath(Path: WideString); // @addr $4B270C
    procedure SetPositionValue(Value: Integer); // @addr $4B27C4
    procedure UpdateThumbPosition; // @addr $4B285C
    function PositionFromPointIndex(Index: Integer): Integer; // @addr $4B290C
    function FindClosestPoint(Point: TPoint; var DistanceSquared: Integer): Integer; // @addr $4B297C @ida "int __usercall $name@<eax>(TSBPathGI *Self@<eax>, TPoint *Point@<edx>, int *DistanceSquared@<ecx>);"
    procedure OnActivate; override; // @addr $4B2A24
    procedure OnDeactivate; override; // @addr $4B2A40
    procedure OnMouseEnter; override; // @addr $4B2A5C
    procedure OnMouseLeave; override; // @addr $4B2A70
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4B2A84 @ida "void __usercall $name(TSBPathGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4B2B78 @ida "void __usercall $name(TSBPathGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4B2B44 @ida "void __usercall $name(TSBPathGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4B2C3C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4B2C70
    procedure LoadPathProperties(Block: TBlockParEC); // @addr $4B2C98
  end;

implementation

uses Classes, SysUtils, GI_Main;

{ @routine $4B2600 TSBPathGI_Create }
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
{ @end $4B2600 }

{ @routine $4B2698 TSBPathGI_Destroy }
destructor TSBPathGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4B2698 }

{ @routine $4B26CC TSBPathGI_Clear }
procedure TSBPathGI.Clear;
begin
  PointCount := 0;
  Points := nil;
  ThumbImage.Clear;
  inherited Clear;
end;
{ @end $4B26CC }

{ @routine $4B270C TSBPathGI_SetImagePath }
procedure TSBPathGI.SetImagePath(Path: WideString);
begin
  ThumbImage.SetImagePath(Path);
  ThumbImage.SetSize(ThumbImage.GetContentSize);
  ThumbImage.SetOrigin(Classes.Point(ThumbImage.ClientSize.X div 2, ThumbImage.ClientSize.Y div 2));
end;
{ @end $4B270C }

{ @routine $4B27C4 TSBPathGI_SetPositionValue }
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
{ @end $4B27C4 }

{ @routine $4B285C TSBPathGI_UpdateThumbPosition }
procedure TSBPathGI.UpdateThumbPosition;
begin
  if PointCount < 1 then Exit;
  if Maximum - Minimum < 1 then ThumbImage.SetPosition(Points[0])
  else ThumbImage.SetPosition(Points[Round((Position - Minimum) / (Maximum - Minimum) * (PointCount - 1))]);
end;
{ @end $4B285C }

{ @routine $4B290C TSBPathGI_PositionFromPointIndex }
function TSBPathGI.PositionFromPointIndex(Index: Integer): Integer;
begin
  if PointCount < 2 then Result := Minimum
  else Result := Round(Index / (PointCount - 1) * (Maximum - Minimum) + Minimum);
end;
{ @end $4B290C }

{ @routine $4B297C TSBPathGI_FindClosestPoint }
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
{ @end $4B297C }

{ @routine $4B2A24 TSBPathGI_OnActivate }
procedure TSBPathGI.OnActivate;
begin
  inherited OnActivate;
  Dragging := False;
end;
{ @end $4B2A24 }

{ @routine $4B2A40 TSBPathGI_OnDeactivate }
procedure TSBPathGI.OnDeactivate;
begin
  inherited OnDeactivate;
  Dragging := False;
end;
{ @end $4B2A40 }

{ @routine $4B2A5C TSBPathGI_OnMouseEnter }
procedure TSBPathGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;
{ @end $4B2A5C }

{ @routine $4B2A70 TSBPathGI_OnMouseLeave }
procedure TSBPathGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
end;
{ @end $4B2A70 }

{ @routine $4B2A84 TSBPathGI_ProcessLeftButtonDown }
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
{ @end $4B2A84 }

{ @routine $4B2B44 TSBPathGI_ProcessLeftButtonUp }
procedure TSBPathGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  Dragging := False;
end;
{ @end $4B2B44 }

{ @routine $4B2B78 TSBPathGI_ProcessMouseMove }
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
{ @end $4B2B78 }

{ @routine $4B2C3C TSBPathGI_LoadFromConfigPath }
procedure TSBPathGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadPathProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B2C3C }

{ @routine $4B2C70 TSBPathGI_LoadFromBlock }
procedure TSBPathGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadPathProperties(Block);
end;
{ @end $4B2C70 }

{ @routine $4B2C98 TSBPathGI_LoadPathProperties }
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
{ @end $4B2C98 }

end.
