unit GI_Door;
// Unit bracket (inferred): .text 0x0049B774..0x0049BD25; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class ownership follows reference/unit_ownership.json.


interface

uses EC_BlockPar, GI_GAI, GI_MessageLoop, Types;

type
  TDoorGI = class(TObjectGI) // @size $138
  public
    Image: TgaiGI; // @offset $120
    FrameStep: Integer; // @offset $124
    StepTimer: PCallbackTimerGI; // @offset $128
    StepTime: Integer; // @offset $12C
    ClickCallback: TObjectNotifyEventGI; // @offset $130
    constructor Create(Owner: TObjectGI); // @addr $49B890
    destructor Destroy; override; // @addr $49B8F0
    procedure Clear; override; // @addr $49B944
    procedure SetStepTime(Value: Integer); // @addr $49B950
    procedure SetSize(Size: TPoint); override; // @addr $49B990
    procedure StartStepTimer; // @addr $49B9C4
    procedure StopStepTimer; // @addr $49BA14
    procedure StepFrame(Timer: PCallbackTimerGI; UserData: Integer); // @addr $49BA4C
    procedure OnActivate; override; // @addr $49BB00
    procedure OnDeactivate; override; // @addr $49BB2C
    procedure OnMouseEnter; override; // @addr $49BB58
    procedure OnMouseLeave; override; // @addr $49BBA0
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $49BBE8
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $49BC64
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $49BCCC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $49BD00
    procedure LoadDoorProperties(Block: TBlockParEC); // @addr $49BD28
  end;

implementation

uses SysUtils, GI_Main;

{ @routine $49B890 TDoorGI_Create }
constructor TDoorGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Image := TgaiGI.Create(Self);
end;
{ @end $49B890 }

{ @routine $49B8F0 TDoorGI_Destroy }
destructor TDoorGI.Destroy;
begin
  StopStepTimer;
  Image.Free;
  Image := nil;
  inherited Destroy;
end;
{ @end $49B8F0 }

{ @routine $49B944 TDoorGI_Clear }
procedure TDoorGI.Clear;
begin
end;
{ @end $49B944 }

{ @routine $49B950 TDoorGI_SetStepTime }
procedure TDoorGI.SetStepTime(Value: Integer);
begin
  if StepTime <> Value then
  begin
    StepTime := Value;
    if FrameStep <> 0 then StartStepTimer;
  end;
end;
{ @end $49B950 }

{ @routine $49B990 TDoorGI_SetSize }
procedure TDoorGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  Image.SetSize(Size);
end;
{ @end $49B990 }

{ @routine $49B9C4 TDoorGI_StartStepTimer }
procedure TDoorGI.StartStepTimer;
begin
  if FrameStep <> 0 then
  begin
    StopStepTimer;
    StepTimer := MessageLoop.ScheduleCallbackTimer(StepTime, StepTime, StepFrame);
  end;
end;
{ @end $49B9C4 }

{ @routine $49BA14 TDoorGI_StopStepTimer }
procedure TDoorGI.StopStepTimer;
begin
  if StepTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(StepTimer);
    StepTimer := nil;
  end;
end;
{ @end $49BA14 }

{ @routine $49BA4C TDoorGI_StepFrame }
procedure TDoorGI.StepFrame(Timer: PCallbackTimerGI; UserData: Integer);
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
{ @end $49BA4C }

{ @routine $49BB00 TDoorGI_OnActivate }
procedure TDoorGI.OnActivate;
begin
  inherited OnActivate;
  Image.SetSequenceFrame(0);
  StopStepTimer;
end;
{ @end $49BB00 }

{ @routine $49BB2C TDoorGI_OnDeactivate }
procedure TDoorGI.OnDeactivate;
begin
  inherited OnDeactivate;
  Image.SetSequenceFrame(0);
  StopStepTimer;
end;
{ @end $49BB2C }

{ @routine $49BB58 TDoorGI_OnMouseEnter }
procedure TDoorGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  if not IsOccludedAtPoint(MessageLoop.GetCursorPoint) then
  begin
    FrameStep := 1;
    StartStepTimer;
  end;
end;
{ @end $49BB58 }

{ @routine $49BBA0 TDoorGI_OnMouseLeave }
procedure TDoorGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if not IsOccludedAtPoint(MessageLoop.GetCursorPoint) then
  begin
    FrameStep := -1;
    StartStepTimer;
  end;
end;
{ @end $49BBA0 }

{ @routine $49BBE8 TDoorGI_ProcessMouseMove }
procedure TDoorGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessMouseMove(KeyState, Point);
  if IsOccludedAtPoint(Point) then
  begin
    FrameStep := -1;
    if StepTimer = nil then StartStepTimer;
  end else
  begin
    FrameStep := 1;
    if StepTimer = nil then StartStepTimer;
  end;
end;
{ @end $49BBE8 }

{ @routine $49BC64 TDoorGI_ProcessLeftButtonUp }
procedure TDoorGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  if not IsOccludedAtPoint(MessageLoop.GetCursorPoint) then
    if Assigned(ClickCallback) then ClickCallback(Self);
end;
{ @end $49BC64 }

{ @routine $49BCCC TDoorGI_LoadFromConfigPath }
procedure TDoorGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadDoorProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $49BCCC }

{ @routine $49BD00 TDoorGI_LoadFromBlock }
procedure TDoorGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadDoorProperties(Block);
end;
{ @end $49BD00 }

{ @routine $49BD28 TDoorGI_LoadDoorProperties }
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
{ @end $49BD28 }

end.
