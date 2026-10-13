unit GI_AImage;

interface

uses Classes, EC_BlockPar, GI_Main, GI_MessageLoop, Types;

type
  TAImageGI = class(TObjectGI) // @size 0x12C @methodorder source
  public
    FrameTimer: TCallbackTimerIdGI; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    HalfAlphaValue: Boolean; // @offset 0x126
    CurrentFrame: TObjectGI; // @offset 0x128

    constructor Create(Owner: TObjectGI); // @addr 0x00495C1C
    destructor Destroy; override; // @addr 0x00495C58
    procedure Clear; override; // @addr 0x00495C80 @note "Does not call inherited Clear."
    function GetContentSize: TPoint; // @addr 0x00495CB0 @note "Returns the componentwise maximum size over child frames."
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x00495D34
    property KindX: TImageKindXGI read ImageKindX write SetImageKindX;
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x00495D6C
    property KindY: TImageKindYGI read ImageKindY write SetImageKindY;
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x00495DA4
    property HalfAlpha: Boolean read HalfAlphaValue write SetHalfAlpha;
    procedure SetSize(Size: TPoint); override; // @addr 0x00495DDC
    procedure AdvanceFrame(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00495E18
    function HitTest(Point: TPoint): Boolean; // @addr 0x00495ECC @note "Uses rectangular child bounds, regardless of transparent pixels."
    procedure OnActivate; override; // @addr 0x00495EF4
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x00495F0C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00495F38
    procedure LoadAnimationProperties(Block: TBlockParEC); // @addr 0x00495F54 @note "Numeric parameter names supply frame delays; values select child images."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x00496160
  end;

implementation

uses GI_Image, EC_Str, SysUtils, GlobalsV;


{ @routine $495C1C TAImageGI_Create }
constructor TAImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  HalfAlphaValue := False;
end;
{ @end $495C1C }

{ @routine $495C58 TAImageGI_Destroy }
destructor TAImageGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $495C58 }

{ @routine $495C80 TAImageGI_Clear }
procedure TAImageGI.Clear;
begin
  HalfAlphaValue := False;
  if FrameTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(FrameTimer);
    FrameTimer := 0;
  end;
  CurrentFrame := nil;
end;
{ @end $495C80 }

{ @routine $495CB0 TAImageGI_GetContentSize }
function TAImageGI.GetContentSize: TPoint;
var Frame: TImageGI; Size: TPoint;
begin
  Result := Classes.Point(0, 0);
  Frame := FirstChild as TImageGI;
  if Frame <> nil then
  begin
    Result := Frame.GetContentSize;
    Frame := Frame.NextSibling as TImageGI;
  end;
  while Frame <> nil do
  begin
    Size := Frame.GetContentSize;
    if Result.X < Size.X then Result.X := Size.X;
    if Result.Y < Size.Y then Result.Y := Size.Y;
    Frame := Frame.NextSibling as TImageGI;
  end;
end;
{ @end $495CB0 }

{ @routine $495D34 TAImageGI_SetImageKindX }
procedure TAImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX = Value then Exit;
  ImageKindX := Value;
  if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetImageKindX(Value);
end;
{ @end $495D34 }

{ @routine $495D6C TAImageGI_SetImageKindY }
procedure TAImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY = Value then Exit;
  ImageKindY := Value;
  if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetImageKindY(Value);
end;
{ @end $495D6C }

{ @routine $495DA4 TAImageGI_SetHalfAlpha }
procedure TAImageGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlphaValue = Value then Exit;
  HalfAlphaValue := Value;
  if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetHalfAlpha(Value);
end;
{ @end $495DA4 }

{ @routine $495DDC TAImageGI_SetSize }
procedure TAImageGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetSize(Size);
end;
{ @end $495DDC }

{ @routine $495E18 TAImageGI_AdvanceFrame }
procedure TAImageGI.AdvanceFrame(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Previous: TObjectGI; Next: TImageGI;
begin
  Previous := TObjectGI(UserData);
  Next := Previous.NextSibling as TImageGI;
  if Next = nil then Next := FirstChild as TImageGI;
  MessageLoop.CancelCallbackTimer(FrameTimer);
  FrameTimer := MessageLoop.ScheduleCallbackTimer(Next.UserValue, $FFFFFF, AdvanceFrame, Integer(Next));
  Previous.SetActive(False);
  Next.SetActive(True);
  Next.SetOrigin(OriginPoint);
  Next.SetSize(ClientSize);
  Next.SetImageKindX(ImageKindX);
  Next.SetImageKindY(ImageKindY);
  Next.SetHalfAlpha(HalfAlphaValue);
  CurrentFrame := Next;
end;
{ @end $495E18 }

{ @routine $495ECC TAImageGI_HitTest }
function TAImageGI.HitTest(Point: TPoint): Boolean;
begin
  if CurrentFrame = nil then Result := False
  else Result := CurrentFrame.ContainsPoint(Point);
end;
{ @end $495ECC }

{ @routine $495EF4 TAImageGI_OnActivate }
procedure TAImageGI.OnActivate;
begin
  inherited OnActivate;
  AdvanceFrame(0, Integer(FirstChild));
end;
{ @end $495EF4 }

{ @routine $495F0C TAImageGI_LoadFromConfigPath }
procedure TAImageGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadAnimationProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $495F0C }

{ @routine $495F38 TAImageGI_LoadFromBlock }
procedure TAImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadAnimationProperties(Block);
end;
{ @end $495F38 }

{ @routine $495F54 TAImageGI_LoadAnimationProperties }
procedure TAImageGI.LoadAnimationProperties(Block: TBlockParEC);
var Count, Index: Integer; HaveFrame: Boolean; Frame, First: TImageGI;
begin
  HaveFrame := False;
  Count := Block.GetParamCount;
  for Index := 0 to Count - 1 do
    if IsIntegerTextW(Block.GetParamName(Index)) then
    begin
      if not HaveFrame then FreeOwnedChildren;
      Frame := TImageGI.Create(Self);
      Frame.UserValue := StrToInt(Block.GetParamName(Index));
      Frame.SetDepth(Count + 1 - Index);
      Frame.ImageSourcePath := Block.GetParamValue(Index);
      if HaveFrame then Frame.SetActive(False);
      HaveFrame := True;
    end;
  CurrentFrame := nil;
  if FrameTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(FrameTimer);
    FrameTimer := 0;
  end;
  First := FirstChild as TImageGI;
  if First <> nil then
  begin
    FrameTimer := MessageLoop.ScheduleCallbackTimer(First.UserValue, $FFFFFF, AdvanceFrame, Integer(First));
    First.SetSize(ClientSize);
    First.KindX := ImageKindX;
    First.KindY := ImageKindY;
    CurrentFrame := First;
  end;
  if Block.CountParams('HalfAlpha') > 0 then HalfAlpha := ParseEnabledNameGI(Block.GetParam('HalfAlpha'));
end;
{ @end $495F54 }

{ @routine $496160 TAImageGI_QueueImageLoad }
procedure TAImageGI.QueueImageLoad(PendingLoads: TList);
var Frame: TImageGI;
begin
  Frame := FirstChild as TImageGI;
  while Frame <> nil do
  begin
    Frame.QueueImageLoad(PendingLoads);
    Frame := Frame.NextSibling as TImageGI;
  end;
end;
{ @end $496160 }

end.
