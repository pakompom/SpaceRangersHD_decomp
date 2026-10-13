unit SE_GAIEffect;

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
    destructor Destroy; override; // @addr $6742E0
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $674308
    procedure DetachFromSpace; override; // @addr $674490
    procedure SetImagePosition(Value: TPoint); // @addr $6744B0
    procedure SetDurationScale(Value: Single); // @addr $6744D0
    procedure Advance; override; // @addr $6744E0
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $674538
    constructor Create(const GraphKey: WideString; UnusedPosition: TPoint); // @addr $674288
  end;

implementation

uses Math, EC_Struct, GlobalsV, GR_Sound;
{ @routine $674288 TGAIEffectSE_Create }
constructor TGAIEffectSE.Create(const GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
  DurationScale := 1;
end;
{ @end $674288 }

{ @routine $6742E0 TGAIEffectSE_Destroy }
destructor TGAIEffectSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $6742E0 }

{ @routine $674308 TGAIEffectSE_AttachToSpace }
procedure TGAIEffectSE.AttachToSpace(ASpace: TSpaceSE);
var
  StepDuration, Duration: Integer;
begin
  inherited AttachToSpace(ASpace);
  Animation := TgaiGI.Create(Space.MapPanel);
  Animation.SetImagePath(ImagePath);
  Animation.ObjectSize := Animation.GetContentSize;
  Animation.Sme := HalfPoint(Animation.ClientSize);
  Animation.SetDepthByName(DepthExpression);
  Animation.World := True;
  Animation.Pos := ImagePosition;
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
{ @end $674308 }

{ @routine $674490 TGAIEffectSE_DetachFromSpace }
procedure TGAIEffectSE.DetachFromSpace;
begin
  if Animation <> nil then
  begin
    Animation.Free;
    Animation := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $674490 }

{ @routine $6744B0 TGAIEffectSE_SetImagePosition }
procedure TGAIEffectSE.SetImagePosition(Value: TPoint);
begin
  ImagePosition := Value;
end;
{ @end $6744B0 }

{ @routine $6744D0 TGAIEffectSE_SetDurationScale }
procedure TGAIEffectSE.SetDurationScale(Value: Single);
begin
  DurationScale := Value;
end;
{ @end $6744D0 }

{ @routine $6744E0 TGAIEffectSE_Advance }
procedure TGAIEffectSE.Advance;
begin
  if not IsAttachedToSpace then Exit;
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
{ @end $6744E0 }

{ @routine $674538 TGAIEffectSE_LoadTemplate }
procedure TGAIEffectSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('GAI');
  if Block.CountParams('Sound') > 0 then SoundPath := Block.GetParam('Sound');
end;
{ @end $674538 }

end.
