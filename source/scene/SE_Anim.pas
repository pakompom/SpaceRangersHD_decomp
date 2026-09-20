unit SE_Anim;
// Unit bracket (inferred): .text 0x008245CC..0x00824B19; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class and methods: $8245CC..$824B19.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_GAI, GI_MessageLoop, SE_Space, Types;

type
  TAnimSE = class(TObjectSE) // @size $68
  public
    ImagePath: WideString; // @offset $4C
    ImageOrigin: TPoint; // @offset $50
    LoopAnimation: Boolean; // @offset $58
    Animation: TgaiGI; // @offset $5C
    FinishedCallback: TNotifyEvent; // @offset $60
    destructor Destroy; override; // @addr $824690
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $8246C4
    procedure DetachFromSpace; override; // @addr $8247C4
    procedure SetPosition(APosition: TPointF); override; // @addr $824804
    procedure AnimationCycleComplete(Sender: TObjectGI); // @addr $824850
    function HitTestCursor: Boolean; override; // @addr $82488C
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $8248BC
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $8249E4
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $824AD4
  end;

implementation

uses GI_Main;

{ @routine $824690 TAnimSE_Destroy }
destructor TAnimSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $824690 }

{ @routine $8246C4 TAnimSE_AttachToSpace }
procedure TAnimSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if not IsAttachedToSpace then
  begin
    inherited AttachToSpace(ASpace);
    Animation := TgaiGI.Create(Space.MapPanel);
    Animation.SetImagePath(ImagePath);
    Animation.SequenceIndex := 0;
    Animation.UpdateAutoGeometry;
    Animation.SetPositionModeW(True);
    Animation.SetDepthByName(DepthExpression);
    Animation.SetPosition(TruncatePointF(Position));
    Animation.SetOrigin(ImageOrigin);
    Animation.SetSize(Animation.GetContentSize);
    Animation.CycleCompleteCallback := AnimationCycleComplete;
    Animation.RestartPlayback;
  end;
end;
{ @end $8246C4 }

{ @routine $8247C4 TAnimSE_DetachFromSpace }
procedure TAnimSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    Animation.SetActive(False);
    Animation.Free;
    Animation := nil;
    inherited DetachFromSpace;
  end;
end;
{ @end $8247C4 }

{ @routine $824804 TAnimSE_SetPosition }
procedure TAnimSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then Animation.SetPosition(TruncatePointF(Position));
end;
{ @end $824804 }

{ @routine $824850 TAnimSE_AnimationCycleComplete }
procedure TAnimSE.AnimationCycleComplete(Sender: TObjectGI);
begin
  if not LoopAnimation then
  begin
    DetachFromSpace;
    if Assigned(FinishedCallback) then FinishedCallback(Self);
  end;
end;
{ @end $824850 }

{ @routine $82488C TAnimSE_HitTestCursor }
function TAnimSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $82488C }

{ @routine $8248BC TAnimSE_LoadTemplate }
procedure TAnimSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  if Block.CountParams('LoopAnim') > 0 then LoopAnimation := ParseEnabledNameGI(Block.GetParam('LoopAnim'));
  if Block.CountParams('SmeImage') > 0 then ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
end;
{ @end $8248BC }

{ @routine $8249E4 TAnimSE_ApplyConfig }
procedure TAnimSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
  if Block.CountParams('LoopAnim') > 0 then LoopAnimation := ParseEnabledNameGI(Block.GetParam('LoopAnim'));
  if Block.CountParams('SmeImage') > 0 then ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
end;
{ @end $8249E4 }

{ @routine $824AD4 TAnimSE_QueueImageLoad }
procedure TAnimSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Image: TgaiGI;
begin
  Image := TgaiGI.Create(Owner);
  Image.SetImagePath(ImagePath);
  Image.QueueImageLoad(PendingLoads);
  Image.Free;
end;
{ @end $824AD4 }

end.
