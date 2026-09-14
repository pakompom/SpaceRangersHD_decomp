unit GI_AImage;
// Unit bracket (inferred): .text 0x00489144..0x0048998A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create(Owner: TObjectGI); // @addr 0x489264 @ida "TAImageGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4892B8 @ida "void __usercall $name(TAImageGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4892EC @note "Does not call inherited Clear."
    function GetContentSize: TPoint; // @addr 0x489338 @ida "void __usercall $name(TAImageGI *Self@<eax>, TPoint *Result@<edx>);" @note "Returns the componentwise maximum size over child frames."
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x4893E0
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x489434
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x489488
    procedure SetSize(Size: TPoint); override; // @addr 0x4894DC @ida "void __usercall $name(TAImageGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure AdvanceFrame(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x489528
    function HitTest(Point: TPoint): Boolean; // @addr 0x489624 @ida "bool __usercall $name@<al>(TAImageGI *Self@<eax>, TPoint *Point@<edx>);" @note "Uses rectangular child bounds, regardless of transparent pixels."
    procedure OnActivate; override; // @addr 0x489668
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x48968C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4896C0
    procedure LoadAnimationProperties(Block: TBlockParEC); // @addr 0x4896E8 @note "Numeric parameter names supply frame delays; values select child images."
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x48993C
  end;

implementation

uses GI_Image, EC_Str, SysUtils, GlobalsV;


{ @routine $489264 TAImageGI_Create }
constructor TAImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  HalfAlpha := False;
end;
{ @end $489264 }

{ @routine $4892B8 TAImageGI_Destroy }
destructor TAImageGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4892B8 }

{ @routine $4892EC TAImageGI_Clear }
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
{ @end $4892EC }

{ @routine $489338 TAImageGI_GetContentSize }
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
{ @end $489338 }

{ @routine $4893E0 TAImageGI_SetImageKindX }
procedure TAImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if ImageKindX <> Value then
  begin
    ImageKindX := Value;
    if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetImageKindX(Value);
  end;
end;
{ @end $4893E0 }

{ @routine $489434 TAImageGI_SetImageKindY }
procedure TAImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if ImageKindY <> Value then
  begin
    ImageKindY := Value;
    if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetImageKindY(Value);
  end;
end;
{ @end $489434 }

{ @routine $489488 TAImageGI_SetHalfAlpha }
procedure TAImageGI.SetHalfAlpha(Value: Boolean);
begin
  if HalfAlpha <> Value then
  begin
    HalfAlpha := Value;
    if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetHalfAlpha(Value);
  end;
end;
{ @end $489488 }

{ @routine $4894DC TAImageGI_SetSize }
procedure TAImageGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if CurrentFrame <> nil then (CurrentFrame as TImageGI).SetSize(Size);
end;
{ @end $4894DC }

{ @routine $489528 TAImageGI_AdvanceFrame }
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
{ @end $489528 }

{ @routine $489624 TAImageGI_HitTest }
function TAImageGI.HitTest(Point: TPoint): Boolean;
begin
  if CurrentFrame = nil then Result := False
  else Result := CurrentFrame.ContainsPoint(Point);
end;
{ @end $489624 }

{ @routine $489668 TAImageGI_OnActivate }
procedure TAImageGI.OnActivate;
begin
  inherited OnActivate;
  AdvanceFrame(nil, Integer(FirstChild));
end;
{ @end $489668 }

{ @routine $48968C TAImageGI_LoadFromConfigPath }
procedure TAImageGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadAnimationProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $48968C }

{ @routine $4896C0 TAImageGI_LoadFromBlock }
procedure TAImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadAnimationProperties(Block);
end;
{ @end $4896C0 }

{ @routine $4896E8 TAImageGI_LoadAnimationProperties }
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
{ @end $4896E8 }

{ @routine $48993C TAImageGI_QueueImageLoad }
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
{ @end $48993C }

end.
