unit GI_Door;


interface

uses EC_BlockPar, GI_GAI, GI_MessageLoop, Types;

type
  TDoorGI = class(TObjectGI) // @size $138 @methodorder virtual
  public
    Image: TgaiGI; // @offset $120
    FrameStep: Integer; // @offset $124
    StepTimer: TCallbackTimerIdGI; // @offset $128
    StepTime: Integer; // @offset $12C
    ClickCallback: TObjectNotifyEventGI; // @offset $130
    constructor Create(Owner: TObjectGI); // @addr $4B44A0
    destructor Destroy; override; // @addr $4B44EC
    procedure Clear; override; // @addr $4B452C
    procedure SetStepTime(Value: Integer); // @addr $4B4530
    procedure SetSize(Size: TPoint); override; // @addr $4B4550
    procedure StartStepTimer; // @addr $4B457C
    procedure StopStepTimer; // @addr $4B45B4
    procedure StepFrame(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $4B45D8
    procedure OnActivate; override; // @addr $4B463C
    procedure OnDeactivate; override; // @addr $4B465C
    procedure OnMouseEnter; override; // @addr $4B467C
    procedure OnMouseLeave; override; // @addr $4B46B8
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4B46F4
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4B4758
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4B47AC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4B47D8
    procedure LoadDoorProperties(Block: TBlockParEC); // @addr $4B47F4
  end;

implementation

uses SysUtils, GI_Main;

{ @routine $4B44A0 TDoorGI_Create }
constructor TDoorGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Image := TgaiGI.Create(Self);
end;
{ @end $4B44A0 }

{ @routine $4B44EC TDoorGI_Destroy }
destructor TDoorGI.Destroy;
begin
  StopStepTimer;
  Image.Free;
  Image := nil;
  inherited Destroy;
end;
{ @end $4B44EC }

{ @routine $4B452C TDoorGI_Clear }
procedure TDoorGI.Clear;
begin
end;
{ @end $4B452C }

{ @routine $4B4530 TDoorGI_SetStepTime }
procedure TDoorGI.SetStepTime(Value: Integer);
begin
  if StepTime = Value then Exit;
  StepTime := Value;
  if FrameStep <> 0 then StartStepTimer;
end;
{ @end $4B4530 }

{ @routine $4B4550 TDoorGI_SetSize }
procedure TDoorGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  Image.ObjectSize := Size;
end;
{ @end $4B4550 }

{ @routine $4B457C TDoorGI_StartStepTimer }
procedure TDoorGI.StartStepTimer;
begin
  if FrameStep = 0 then Exit;
  StopStepTimer;
  StepTimer := MessageLoop.ScheduleCallbackTimer(StepTime, StepTime, StepFrame);
end;
{ @end $4B457C }

{ @routine $4B45B4 TDoorGI_StopStepTimer }
procedure TDoorGI.StopStepTimer;
begin
  if StepTimer = 0 then Exit;
  MessageLoop.CancelCallbackTimer(StepTimer);
  StepTimer := 0;
end;
{ @end $4B45B4 }

{ @routine $4B45D8 TDoorGI_StepFrame }
procedure TDoorGI.StepFrame(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Frame: Integer;
begin
  Frame := Image.SequenceFrame + FrameStep;
  if Frame <= 0 then
  begin
    Image.SetSequenceFrame(0);
    StopStepTimer;
    FrameStep := 0;
  end else if Frame >= Image.SequenceFrameCount - 1 then
  begin
    Image.SetSequenceFrame(Image.SequenceFrameCount - 1);
    StopStepTimer;
    FrameStep := 0;
  end else Image.SetSequenceFrame(Frame);
end;
{ @end $4B45D8 }

{ @routine $4B463C TDoorGI_OnActivate }
procedure TDoorGI.OnActivate;
begin
  inherited OnActivate;
  Image.SetSequenceFrame(0);
  StopStepTimer;
end;
{ @end $4B463C }

{ @routine $4B465C TDoorGI_OnDeactivate }
procedure TDoorGI.OnDeactivate;
begin
  inherited OnDeactivate;
  Image.SetSequenceFrame(0);
  StopStepTimer;
end;
{ @end $4B465C }

{ @routine $4B467C TDoorGI_OnMouseEnter }
procedure TDoorGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  if IsOccludedAtPoint(MessageLoop.GetCursorPoint) then Exit;
  FrameStep := 1;
  StartStepTimer;
end;
{ @end $4B467C }

{ @routine $4B46B8 TDoorGI_OnMouseLeave }
procedure TDoorGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if IsOccludedAtPoint(MessageLoop.GetCursorPoint) then Exit;
  FrameStep := -1;
  StartStepTimer;
end;
{ @end $4B46B8 }

{ @routine $4B46F4 TDoorGI_ProcessMouseMove }
procedure TDoorGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessMouseMove(KeyState, Point);
  if IsOccludedAtPoint(Point) then
  begin
    FrameStep := -1;
    if StepTimer = 0 then StartStepTimer;
  end else
  begin
    FrameStep := 1;
    if StepTimer = 0 then StartStepTimer;
  end;
end;
{ @end $4B46F4 }

{ @routine $4B4758 TDoorGI_ProcessLeftButtonUp }
procedure TDoorGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  if IsOccludedAtPoint(MessageLoop.GetCursorPoint) then Exit;
  if Assigned(ClickCallback) then ClickCallback(Self);
end;
{ @end $4B4758 }

{ @routine $4B47AC TDoorGI_LoadFromConfigPath }
procedure TDoorGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadDoorProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B47AC }

{ @routine $4B47D8 TDoorGI_LoadFromBlock }
procedure TDoorGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadDoorProperties(Block);
end;
{ @end $4B47D8 }

{ @routine $4B47F4 TDoorGI_LoadDoorProperties }
procedure TDoorGI.LoadDoorProperties(Block: TBlockParEC);
begin
  FrameStep := 0;
  if Block.CountParams('StepTime') > 0 then SetStepTime(StrToInt(Block.GetParam('StepTime')));
  if Block.CountParams('Image') > 0 then
  begin
    Image.SetImagePath(Block.GetParam('Image'));
    Image.SequenceIndex := 0;
    Image.UpdateAutoGeometry;
  end;
end;
{ @end $4B47F4 }

end.
