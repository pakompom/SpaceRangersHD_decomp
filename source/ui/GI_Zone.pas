unit GI_Zone;

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TZoneKindGI = (zkRect = 0, zkCircle = 1); // @size 1
  TZoneGI = class(TObjectGI) // @size 0x148
  public
    Kind: TZoneKindGI; // @offset 0x120
    CursorInside: Boolean; // @offset 0x121
    EnterCallback: TObjectNotifyEventGI; // @offset $128
    LeaveCallback: TObjectNotifyEventGI; // @offset $130
    ZoneMouseDownCallback: TObjectMouseEventGI; // @offset $138 Context/EAX, Sender/EDX, KeyState/ECX and Point on stack.
    ZoneMouseUpCallback: TObjectMouseEventGI; // @offset $140

    constructor Create(Owner: TObjectGI); // @addr 0x004B227C
    destructor Destroy; override; // @addr 0x004B22B4
    procedure SetKind(Value: TZoneKindGI); // @addr 0x004B22DC
    procedure Invalidate; override; // @addr $4B22EC Native no-op: hit zones do not draw.
    function HitTest(Point: TPoint): Boolean; // @addr 0x004B22F0 @note "Circle mode ignores Active and HitTestDisabled."
    procedure OnActivate; override; // @addr 0x004B23C4 @note "May invoke cursor enter/leave callbacks."
    procedure OnDeactivate; override; // @addr 0x004B2440
    procedure OnMouseEnter; override; // @addr $4B2474
    procedure OnMouseLeave; override; // @addr $4B24F0
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4B2524
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4B25A4
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4B2640 Native calls inherited ProcessLeftButtonDown before the zone's up callback.
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004B26DC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004B2708
    procedure LoadZoneProperties(Block: TBlockParEC); // @addr 0x004B2724
    procedure UpdateAutoGeometry; override; // @addr $4B27E4
  end;

implementation

uses EC_Struct, Math, GR_Main;

{ @routine $4B227C TZoneGI_Create }
constructor TZoneGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $4B227C }

{ @routine $4B22B4 TZoneGI_Destroy }
destructor TZoneGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4B22B4 }

{ @routine $4B22DC TZoneGI_SetKind }
procedure TZoneGI.SetKind(Value: TZoneKindGI);
begin
  if Kind <> Value then Kind := Value;
end;
{ @end $4B22DC }

{ @routine $4B22EC TZoneGI_Invalidate }
procedure TZoneGI.Invalidate;
begin
end;
{ @end $4B22EC }

{ @routine $4B22F0 TZoneGI_HitTest }
function TZoneGI.HitTest(Point: TPoint): Boolean;
var
  Diameter: Integer;
begin
  Result := False;
  if Kind = zkRect then Result := ContainsPoint(Point)
  else if Kind = zkCircle then
  begin
    if HitTestBounds.Right - HitTestBounds.Left < HitTestBounds.Bottom - HitTestBounds.Top then
      Diameter := HitTestBounds.Right - HitTestBounds.Left
    else Diameter := HitTestBounds.Bottom - HitTestBounds.Top;
    Result := Sqr(Diameter / 2) >= PointDistanceSquared(MakePointF((HitTestBounds.Left + HitTestBounds.Right) div 2,
      (HitTestBounds.Top + HitTestBounds.Bottom) div 2), PointToPointF(Point));
  end;
end;
{ @end $4B22F0 }

{ @routine $4B23C4 TZoneGI_OnActivate }
procedure TZoneGI.OnActivate;
begin
  inherited OnActivate;
  if HitTest(MessageLoop.GetCursorPoint) then
  begin
    if not CursorInside then
    begin
      CursorInside := True;
      if Assigned(EnterCallback) then EnterCallback(Self);
    end;
  end
  else if CursorInside = True then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4B23C4 }

{ @routine $4B2440 TZoneGI_OnDeactivate }
procedure TZoneGI.OnDeactivate;
begin
  inherited OnDeactivate;
  if CursorInside then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4B2440 }

{ @routine $4B2474 TZoneGI_OnMouseEnter }
procedure TZoneGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  if HitTest(MessageLoop.GetCursorPoint) then
  begin
    if not CursorInside then
    begin
      CursorInside := True;
      if Assigned(EnterCallback) then EnterCallback(Self);
    end;
  end
  else if CursorInside = True then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4B2474 }

{ @routine $4B24F0 TZoneGI_OnMouseLeave }
procedure TZoneGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if CursorInside then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4B24F0 }

{ @routine $4B2524 TZoneGI_ProcessMouseMove }
procedure TZoneGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessMouseMove(KeyState, Point);
  if HitTest(Point) then
  begin
    if not CursorInside then
    begin
      CursorInside := True;
      if Assigned(EnterCallback) then EnterCallback(Self);
    end;
  end
  else if CursorInside = True then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4B2524 }

{ @routine $4B25A4 TZoneGI_ProcessLeftButtonDown }
procedure TZoneGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if HitTest(Point) then
  begin
    if not CursorInside then
    begin
      CursorInside := True;
      if Assigned(EnterCallback) then EnterCallback(Self);
    end;
    if Assigned(ZoneMouseDownCallback) then ZoneMouseDownCallback(Self, KeyState, Point);
  end
  else if CursorInside = True then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4B25A4 }

{ @routine $4B2640 TZoneGI_ProcessLeftButtonUp }
procedure TZoneGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if HitTest(Point) then
  begin
    if not CursorInside then
    begin
      CursorInside := True;
      if Assigned(EnterCallback) then EnterCallback(Self);
    end;
    if Assigned(ZoneMouseUpCallback) then ZoneMouseUpCallback(Self, KeyState, Point);
  end
  else if CursorInside = True then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4B2640 }

{ @routine $4B26DC TZoneGI_LoadFromConfigPath }
procedure TZoneGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadZoneProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B26DC }

{ @routine $4B2708 TZoneGI_LoadFromBlock }
procedure TZoneGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadZoneProperties(Block);
end;
{ @end $4B2708 }

{ @routine $4B2724 TZoneGI_LoadZoneProperties }
procedure TZoneGI.LoadZoneProperties(Block: TBlockParEC);
var
  Value: WideString;
begin
  if Block.CountParams('Kind') > 0 then
  begin
    Value := Block.GetParam('Kind');
    if Value = 'Rect' then SetKind(zkRect)
    else if Value = 'Circle' then SetKind(zkCircle);
  end;
end;
{ @end $4B2724 }

{ @routine $4B27E4 TZoneGI_UpdateAutoGeometry }
procedure TZoneGI.UpdateAutoGeometry;
begin
  inherited UpdateAutoGeometry;
end;
{ @end $4B27E4 }

end.
