unit GI_Door;
// Unit bracket (inferred): .text 0x004AA00C..0x004AA5BD; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
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
    constructor Create(Owner: TObjectGI); // @addr $4AA128 @ida "TDoorGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $4AA188 @ida "void __usercall $name(TDoorGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr $4AA1DC
    procedure SetStepTime(Value: Integer); // @addr $4AA1E8
    procedure SetSize(Size: TPoint); override; // @addr $4AA228 @ida "void __usercall $name(TDoorGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure StartStepTimer; // @addr $4AA25C
    procedure StopStepTimer; // @addr $4AA2AC
    procedure StepFrame(Timer: PCallbackTimerGI; UserData: Integer); // @addr $4AA2E4
    procedure OnActivate; override; // @addr $4AA398
    procedure OnDeactivate; override; // @addr $4AA3C4
    procedure OnMouseEnter; override; // @addr $4AA3F0
    procedure OnMouseLeave; override; // @addr $4AA438
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4AA480 @ida "void __usercall $name(TDoorGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4AA4FC @ida "void __usercall $name(TDoorGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4AA564
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4AA598
    procedure LoadDoorProperties(Block: TBlockParEC); // @addr $4AA5C0
  end;

implementation

uses SysUtils, GI_Main;

{ @routine $4AA128 TDoorGI_Create }
constructor TDoorGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Image := TgaiGI.Create(Self);
end;
{ @end $4AA128 }

{ @routine $4AA188 TDoorGI_Destroy }
destructor TDoorGI.Destroy;
begin
  StopStepTimer;
  Image.Free;
  Image := nil;
  inherited Destroy;
end;
{ @end $4AA188 }

{ @routine $4AA1DC TDoorGI_Clear }
procedure TDoorGI.Clear;
begin
end;
{ @end $4AA1DC }

{ @routine $4AA1E8 TDoorGI_SetStepTime }
procedure TDoorGI.SetStepTime(Value: Integer);
begin
  if StepTime <> Value then
  begin
    StepTime := Value;
    if FrameStep <> 0 then StartStepTimer;
  end;
end;
{ @end $4AA1E8 }

{ @routine $4AA228 TDoorGI_SetSize }
procedure TDoorGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  Image.SetSize(Size);
end;
{ @end $4AA228 }

{ @routine $4AA25C TDoorGI_StartStepTimer }
procedure TDoorGI.StartStepTimer;
begin
  if FrameStep <> 0 then
  begin
    StopStepTimer;
    StepTimer := MessageLoop.ScheduleCallbackTimer(StepTime, StepTime, StepFrame);
  end;
end;
{ @end $4AA25C }

{ @routine $4AA2AC TDoorGI_StopStepTimer }
procedure TDoorGI.StopStepTimer;
begin
  if StepTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(StepTimer);
    StepTimer := nil;
  end;
end;
{ @end $4AA2AC }

{ @routine $4AA2E4 TDoorGI_StepFrame }
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
{ @end $4AA2E4 }

{ @routine $4AA398 TDoorGI_OnActivate }
procedure TDoorGI.OnActivate;
begin
  inherited OnActivate;
  Image.SetSequenceFrame(0);
  StopStepTimer;
end;
{ @end $4AA398 }

{ @routine $4AA3C4 TDoorGI_OnDeactivate }
procedure TDoorGI.OnDeactivate;
begin
  inherited OnDeactivate;
  Image.SetSequenceFrame(0);
  StopStepTimer;
end;
{ @end $4AA3C4 }

{ @routine $4AA3F0 TDoorGI_OnMouseEnter }
procedure TDoorGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  if not IsOccludedAtPoint(MessageLoop.GetCursorPoint) then
  begin
    FrameStep := 1;
    StartStepTimer;
  end;
end;
{ @end $4AA3F0 }

{ @routine $4AA438 TDoorGI_OnMouseLeave }
procedure TDoorGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if not IsOccludedAtPoint(MessageLoop.GetCursorPoint) then
  begin
    FrameStep := -1;
    StartStepTimer;
  end;
end;
{ @end $4AA438 }

{ @routine $4AA480 TDoorGI_ProcessMouseMove }
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
{ @end $4AA480 }

{ @routine $4AA4FC TDoorGI_ProcessLeftButtonUp }
procedure TDoorGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  if not IsOccludedAtPoint(MessageLoop.GetCursorPoint) then
    if Assigned(ClickCallback) then ClickCallback(Self);
end;
{ @end $4AA4FC }

{ @routine $4AA564 TDoorGI_LoadFromConfigPath }
procedure TDoorGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadDoorProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4AA564 }

{ @routine $4AA598 TDoorGI_LoadFromBlock }
procedure TDoorGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadDoorProperties(Block);
end;
{ @end $4AA598 }

{ @routine $4AA5C0 TDoorGI_LoadDoorProperties }
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
{ @end $4AA5C0 }

end.
