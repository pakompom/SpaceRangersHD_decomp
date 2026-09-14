unit SE_GAIEffect;
// Unit bracket (inferred): .text 0x0069F5F0..0x0069FACF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_GAI, SE_Space, Types;

type
  TGAIEffectSE = class(TObjectSE) // @size $6C
  public
    SoundPath: WideString; // @offset $4C
    ImagePosition: TPoint; // @offset $50
    DurationScale: Single; // @offset $58
    ImagePath: WideString; // @offset $5C
    Animation: TgaiGI; // @offset $60
    StepsPerFrame: Integer; // @offset $64
    StepIndex: Integer; // @offset $68
    destructor Destroy; override; // @addr $69F724 @ida "void __usercall $name(TGAIEffectSE *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $69F758
    procedure DetachFromSpace; override; // @addr $69F934
    procedure SetImagePosition(Value: TPoint); // @addr $69F964 @ida "void __usercall $name(TGAIEffectSE *Self@<eax>, TPoint *Value@<edx>);"
    procedure SetDurationScale(Value: Single); // @addr $69F98C @ida "void __userpurge $name(TGAIEffectSE *Self@<eax>, float Value@<^0>);"
    procedure Advance; override; // @addr $69F9A4
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $69FA30
    constructor Create(const GraphKey: WideString; UnusedPosition: TPoint); // @addr $69F6C0 @ida "TGAIEffectSE *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int16 *GraphKey@<ecx>, TPoint *UnusedPosition@<^0>);"
  end;

implementation

uses Math, EC_Struct, GlobalsV, GR_Sound;
{ @routine $69F6C0 TGAIEffectSE_Create }
constructor TGAIEffectSE.Create(const GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
  DurationScale := 1;
end;
{ @end $69F6C0 }

{ @routine $69F724 TGAIEffectSE_Destroy }
destructor TGAIEffectSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $69F724 }

{ @routine $69F758 TGAIEffectSE_AttachToSpace }
procedure TGAIEffectSE.AttachToSpace(ASpace: TSpaceSE);
var
  StepDuration, Duration: Integer;
begin
  inherited AttachToSpace(ASpace);
  Animation := TgaiGI.Create(Space.MapPanel);
  Animation.SetImagePath(ImagePath);
  Animation.SetSize(Animation.GetContentSize);
  Animation.SetOrigin(HalfPoint(Animation.ClientSize));
  Animation.SetDepthByName(DepthExpression);
  Animation.SetPositionModeW(True);
  Animation.SetPosition(ImagePosition);
  Animation.SequenceIndex := 0;
  Animation.UpdateAutoGeometry;
  Animation.StopAutoPlayback;
  StepsPerFrame := Math.Max(1, Round(DurationScale * 200 / Animation.SequenceFrameCount));
  if FilmSpeed = 0 then StepDuration := 18
  else if FilmSpeed = 1 then StepDuration := 14
  else StepDuration := 10;
  Duration := Animation.SequenceFrameCount * StepDuration * StepsPerFrame;
  Animation.SetOneCycleDuration(Duration);
  if FilmSoundEffectsEnabled then
    if SoundInSpaceEnabled then
      if Space.ContainsMapPoint(PointToPointF(Animation.LocalPosition)) then SoundManager.PlaySound(SoundPath);
  StepIndex := 0;
end;
{ @end $69F758 }

{ @routine $69F934 TGAIEffectSE_DetachFromSpace }
procedure TGAIEffectSE.DetachFromSpace;
begin
  if Animation <> nil then
  begin
    Animation.Free;
    Animation := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $69F934 }

{ @routine $69F964 TGAIEffectSE_SetImagePosition }
procedure TGAIEffectSE.SetImagePosition(Value: TPoint);
begin
  ImagePosition := Value;
end;
{ @end $69F964 }

{ @routine $69F98C TGAIEffectSE_SetDurationScale }
procedure TGAIEffectSE.SetDurationScale(Value: Single);
begin
  DurationScale := Value;
end;
{ @end $69F98C }

{ @routine $69F9A4 TGAIEffectSE_Advance }
procedure TGAIEffectSE.Advance;
begin
  if IsAttachedToSpace then
  begin
    if Animation <> nil then
    begin
      if Animation.SequenceFrame = Animation.SequenceFrameCount - 1 then
      begin
        Animation.Free;
        Animation := nil;
        DetachFromSpace;
      end
      else if StepIndex mod StepsPerFrame = 0 then
        Animation.SetSequenceFrame(Animation.SequenceFrame + 1);
    end;
    Inc(StepIndex);
  end;
end;
{ @end $69F9A4 }

{ @routine $69FA30 TGAIEffectSE_LoadTemplate }
procedure TGAIEffectSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('GAI');
  if Block.CountParams('Sound') > 0 then SoundPath := Block.GetParam('Sound');
end;
{ @end $69FA30 }

end.
