unit GI_AImage;
// Unit bracket (inferred): .text 0x00483244..0x00483A8A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, GI_Main, GI_MessageLoop, Types;

type
  TAImageGI = class(TObjectGI) // @size 0x12C
  public
    FrameTimer: PCallbackTimerGI; // @offset 0x120
    ImageKindX: TImageKindXGI; // @offset 0x124
    ImageKindY: TImageKindYGI; // @offset 0x125
    HalfAlpha: Boolean; // @offset 0x126
    CurrentFrame: TObjectGI; // @offset 0x128

    constructor Create(Owner: TObjectGI); // @addr 0x483364
    destructor Destroy; override; // @addr 0x4833B8
    procedure Clear; override; // @addr 0x4833EC @note "Does not call inherited Clear."
    function GetContentSize: TPoint; // @addr 0x483438 @note "Returns the componentwise maximum size over child frames."
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x4834E0
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x483534
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x483588
    procedure SetSize(Size: TPoint); override; // @addr 0x4835DC
    procedure AdvanceFrame(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x483628
    function HitTest(Point: TPoint): Boolean; // @addr 0x483724 @note "Uses rectangular child bounds, regardless of transparent pixels."
    procedure OnActivate; override; // @addr 0x483768
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x48378C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4837C0
    procedure LoadAnimationProperties(Block: TBlockParEC); // @addr 0x4837E8 @note "Numeric parameter names supply frame delays; values select child images."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x483A3C
  end;

implementation

uses GI_Image, EC_Str, SysUtils, GlobalsV;


{ @routine $483364 TAImageGI_Create }
constructor TAImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  HalfAlpha := False;
end;
{ @end $483364 }

{ @routine $4833B8 TAImageGI_Destroy }
destructor TAImageGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4833B8 }

{ @routine $4833EC TAImageGI_Clear }
procedure TAImageGI.Clear;
begin
  HalfAlpha := False;
  if FrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(FrameTimer);
    FrameTimer := nil;
  end;
  CurrentFrame := nil;
end;
{ @end $4833EC }

{ @routine $483438 TAImageGI_GetContentSize }
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
{ @end $483438 }

{ @routine $4834E0 TAImageGI_SetImageKindX }
procedure TAImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetImageKindX(Value);
  end;
end;
{ @end $4834E0 }

{ @routine $483534 TAImageGI_SetImageKindY }
procedure TAImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetImageKindY(Value);
  end;
end;
{ @end $483534 }

{ @routine $483588 TAImageGI_SetHalfAlpha }
procedure TAImageGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlpha <> Value then
  begin
    HalfAlpha := Value;
    if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetHalfAlpha(Value);
  end;
end;
{ @end $483588 }

{ @routine $4835DC TAImageGI_SetSize }
procedure TAImageGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetSize(Size);
end;
{ @end $4835DC }

{ @routine $483628 TAImageGI_AdvanceFrame }
procedure TAImageGI.AdvanceFrame(Timer: PCallbackTimerGI; UserData: Integer);
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
  Next.SetHalfAlpha(HalfAlpha);
  CurrentFrame := Next;
end;
{ @end $483628 }

{ @routine $483724 TAImageGI_HitTest }
function TAImageGI.HitTest(Point: TPoint): Boolean;
begin
  if CurrentFrame = nil then Result := False
  else Result := CurrentFrame.ContainsPoint(Point);
end;
{ @end $483724 }

{ @routine $483768 TAImageGI_OnActivate }
procedure TAImageGI.OnActivate;
begin
  inherited OnActivate;
  AdvanceFrame(nil, Integer(FirstChild));
end;
{ @end $483768 }

{ @routine $48378C TAImageGI_LoadFromConfigPath }
procedure TAImageGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadAnimationProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $48378C }

{ @routine $4837C0 TAImageGI_LoadFromBlock }
procedure TAImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadAnimationProperties(Block);
end;
{ @end $4837C0 }

{ @routine $4837E8 TAImageGI_LoadAnimationProperties }
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
      Frame.SetImagePath(Block.GetParamValue(Index));
      if HaveFrame then Frame.SetActive(False);
      HaveFrame := True;
    end;
  CurrentFrame := nil;
  if FrameTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(FrameTimer);
    FrameTimer := nil;
  end;
  First := FirstChild as TImageGI;
  if First <> nil then
  begin
    FrameTimer := MessageLoop.ScheduleCallbackTimer(First.UserValue, $FFFFFF, AdvanceFrame, Integer(First));
    First.SetSize(ClientSize);
    First.SetImageKindX(ImageKindX);
    First.SetImageKindY(ImageKindY);
    CurrentFrame := First;
  end;
  if Block.CountParams('HalfAlpha') > 0 then SetHalfAlpha(ParseEnabledNameGI(Block.GetParam('HalfAlpha')));
end;
{ @end $4837E8 }

{ @routine $483A3C TAImageGI_QueueImageLoad }
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
{ @end $483A3C }

end.
