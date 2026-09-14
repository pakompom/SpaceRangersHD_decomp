unit GI_Zone;
// Unit bracket (inferred): .text 0x004A79E8..0x004A8235; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    ZoneMouseDownCallback: TObjectMouseEventGI; // @offset $138 Verified at $4A7FD9: Context/EAX, Sender/EDX, KeyState/ECX and Point on stack.
    ZoneMouseUpCallback: TObjectMouseEventGI; // @offset $140

    constructor Create(Owner: TObjectGI); // @addr 0x4A7B28 @ida "TZoneGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4A7B70 @ida "void __usercall $name(TZoneGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetKind(Value: TZoneKindGI); // @addr 0x4A7BA4
    procedure Invalidate; override; // @addr $4A7BD0 Native no-op: hit zones do not draw.
    function HitTest(Point: TPoint): Boolean; // @addr 0x4A7BDC @ida "bool __usercall $name@<al>(TZoneGI *Self@<eax>, TPoint *Point@<edx>);" @note "Circle mode ignores Active and HitTestDisabled."
    procedure OnActivate; override; // @addr 0x4A7CE4 @note "May invoke cursor enter/leave callbacks."
    procedure OnDeactivate; override; // @addr 0x4A7D84
    procedure OnMouseEnter; override; // @addr $4A7DD0
    procedure OnMouseLeave; override; // @addr $4A7E70
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4A7EBC @ida "void __usercall $name(TZoneGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4A7F64 @ida "void __usercall $name(TZoneGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4A8030 @ida "void __usercall $name(TZoneGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);" Native calls inherited ProcessLeftButtonDown before the zone's up callback.
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4A80FC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4A8130
    procedure LoadZoneProperties(Block: TBlockParEC); // @addr 0x4A8158
    procedure UpdateAutoGeometry; override; // @addr $4A8224
  end;

implementation

uses EC_Struct, Math, GR_Main;

{ @routine $4A7B28 TZoneGI_Create }
constructor TZoneGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $4A7B28 }

{ @routine $4A7B70 TZoneGI_Destroy }
destructor TZoneGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4A7B70 }

{ @routine $4A7BA4 TZoneGI_SetKind }
procedure TZoneGI.SetKind(Value: TZoneKindGI);
begin
  if Kind <> Value then Kind := Value;
end;
{ @end $4A7BA4 }

{ @routine $4A7BD0 TZoneGI_Invalidate }
procedure TZoneGI.Invalidate;
begin
end;
{ @end $4A7BD0 }

{ @routine $4A7BDC TZoneGI_HitTest }
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
{ @end $4A7BDC }

{ @routine $4A7CE4 TZoneGI_OnActivate }
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
{ @end $4A7CE4 }

{ @routine $4A7D84 TZoneGI_OnDeactivate }
procedure TZoneGI.OnDeactivate;
begin
  inherited OnDeactivate;
  if CursorInside then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4A7D84 }

{ @routine $4A7DD0 TZoneGI_OnMouseEnter }
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
{ @end $4A7DD0 }

{ @routine $4A7E70 TZoneGI_OnMouseLeave }
procedure TZoneGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if CursorInside then
  begin
    CursorInside := False;
    if Assigned(LeaveCallback) then LeaveCallback(Self);
  end;
end;
{ @end $4A7E70 }

{ @routine $4A7EBC TZoneGI_ProcessMouseMove }
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
{ @end $4A7EBC }

{ @routine $4A7F64 TZoneGI_ProcessLeftButtonDown }
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
{ @end $4A7F64 }

{ @routine $4A8030 TZoneGI_ProcessLeftButtonUp }
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
{ @end $4A8030 }

{ @routine $4A80FC TZoneGI_LoadFromConfigPath }
procedure TZoneGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadZoneProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4A80FC }

{ @routine $4A8130 TZoneGI_LoadFromBlock }
procedure TZoneGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadZoneProperties(Block);
end;
{ @end $4A8130 }

{ @routine $4A8158 TZoneGI_LoadZoneProperties }
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
{ @end $4A8158 }

{ @routine $4A8224 TZoneGI_UpdateAutoGeometry }
procedure TZoneGI.UpdateAutoGeometry;
begin
  inherited UpdateAutoGeometry;
end;
{ @end $4A8224 }

end.
