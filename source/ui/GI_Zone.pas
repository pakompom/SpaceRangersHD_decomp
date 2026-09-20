unit GI_Zone;
// Unit bracket (inferred): .text 0x004A1080..0x004A18CD; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    ZoneMouseDownCallback: TObjectMouseEventGI; // @offset $138 Verified at $4A1671: Context/EAX, Sender/EDX, KeyState/ECX and Point on stack.
    ZoneMouseUpCallback: TObjectMouseEventGI; // @offset $140

    constructor Create(Owner: TObjectGI); // @addr 0x4A11C0
    destructor Destroy; override; // @addr 0x4A1208
    procedure SetKind(Value: TZoneKindGI); // @addr 0x4A123C
    procedure Invalidate; override; // @addr $4A1268 Native no-op: hit zones do not draw.
    function HitTest(Point: TPoint): Boolean; // @addr 0x4A1274 @note "Circle mode ignores Active and HitTestDisabled."
    procedure OnActivate; override; // @addr 0x4A137C @note "May invoke cursor enter/leave callbacks."
    procedure OnDeactivate; override; // @addr 0x4A141C
    procedure OnMouseEnter; override; // @addr $4A1468
    procedure OnMouseLeave; override; // @addr $4A1508
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4A1554
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4A15FC
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4A16C8 Native calls inherited ProcessLeftButtonDown before the zone's up callback.
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4A1794
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4A17C8
    procedure LoadZoneProperties(Block: TBlockParEC); // @addr 0x4A17F0
    procedure UpdateAutoGeometry; override; // @addr $4A18BC
  end;

implementation

uses EC_Struct, Math, GR_Main;

{ @routine $4A11C0 TZoneGI_Create }
constructor TZoneGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $4A11C0 }

{ @routine $4A1208 TZoneGI_Destroy }
destructor TZoneGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4A1208 }

{ @routine $4A123C TZoneGI_SetKind }
procedure TZoneGI.SetKind(Value: TZoneKindGI);
begin
  if Kind <> Value then Kind := Value;
end;
{ @end $4A123C }

{ @routine $4A1268 TZoneGI_Invalidate }
procedure TZoneGI.Invalidate;
begin
end;
{ @end $4A1268 }

{ @routine $4A1274 TZoneGI_HitTest }
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
{ @end $4A1274 }

{ @routine $4A137C TZoneGI_OnActivate }
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
{ @end $4A137C }

{ @routine $4A141C TZoneGI_OnDeactivate }
procedure TZoneGI.OnDeactivate;
begin
  inherited OnDeactivate;
  if CursorInside then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4A141C }

{ @routine $4A1468 TZoneGI_OnMouseEnter }
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
{ @end $4A1468 }

{ @routine $4A1508 TZoneGI_OnMouseLeave }
procedure TZoneGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if CursorInside then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4A1508 }

{ @routine $4A1554 TZoneGI_ProcessMouseMove }
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
{ @end $4A1554 }

{ @routine $4A15FC TZoneGI_ProcessLeftButtonDown }
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
{ @end $4A15FC }

{ @routine $4A16C8 TZoneGI_ProcessLeftButtonUp }
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
{ @end $4A16C8 }

{ @routine $4A1794 TZoneGI_LoadFromConfigPath }
procedure TZoneGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadZoneProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4A1794 }

{ @routine $4A17C8 TZoneGI_LoadFromBlock }
procedure TZoneGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadZoneProperties(Block);
end;
{ @end $4A17C8 }

{ @routine $4A17F0 TZoneGI_LoadZoneProperties }
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
{ @end $4A17F0 }

{ @routine $4A18BC TZoneGI_UpdateAutoGeometry }
procedure TZoneGI.UpdateAutoGeometry;
begin
  inherited UpdateAutoGeometry;
end;
{ @end $4A18BC }

end.
