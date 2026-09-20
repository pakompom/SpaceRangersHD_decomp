unit SE_GAIEffect;
// Unit bracket (inferred): .text 0x0060371C..0x00603BFB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    destructor Destroy; override; // @addr $603850
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $603884
    procedure DetachFromSpace; override; // @addr $603A60
    procedure SetImagePosition(Value: TPoint); // @addr $603A90
    procedure SetDurationScale(Value: Single); // @addr $603AB8
    procedure Advance; override; // @addr $603AD0
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $603B5C
    constructor Create(const GraphKey: WideString; UnusedPosition: TPoint); // @addr $6037EC
  end;

implementation

uses Math, EC_Struct, GlobalsV, GR_Sound;
{ @routine $6037EC TGAIEffectSE_Create }
constructor TGAIEffectSE.Create(const GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
  DurationScale := 1;
end;
{ @end $6037EC }

{ @routine $603850 TGAIEffectSE_Destroy }
destructor TGAIEffectSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $603850 }

{ @routine $603884 TGAIEffectSE_AttachToSpace }
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
{ @end $603884 }

{ @routine $603A60 TGAIEffectSE_DetachFromSpace }
procedure TGAIEffectSE.DetachFromSpace;
begin
  if Animation <> nil then
  begin
    Animation.Free;
    Animation := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $603A60 }

{ @routine $603A90 TGAIEffectSE_SetImagePosition }
procedure TGAIEffectSE.SetImagePosition(Value: TPoint);
begin
  ImagePosition := Value;
end;
{ @end $603A90 }

{ @routine $603AB8 TGAIEffectSE_SetDurationScale }
procedure TGAIEffectSE.SetDurationScale(Value: Single);
begin
  DurationScale := Value;
end;
{ @end $603AB8 }

{ @routine $603AD0 TGAIEffectSE_Advance }
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
{ @end $603AD0 }

{ @routine $603B5C TGAIEffectSE_LoadTemplate }
procedure TGAIEffectSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('GAI');
  if Block.CountParams('Sound') > 0 then SoundPath := Block.GetParam('Sound');
end;
{ @end $603B5C }

end.
