unit SE_Anim;
// Unit bracket (inferred): .text 0x007CA604..0x007CAB51; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class and methods: $7CA604..$7CAB51.

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
    destructor Destroy; override; // @addr $7CA6C8 @ida "void __usercall $name(TAnimSE *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $7CA6FC
    procedure DetachFromSpace; override; // @addr $7CA7FC
    procedure SetPosition(APosition: TPointF); override; // @addr $7CA83C @ida "void __usercall $name(TAnimSE *Self@<eax>, TPointF *APosition@<edx>);"
    procedure AnimationCycleComplete(Sender: TObjectGI); // @addr $7CA888
    function HitTestCursor: Boolean; override; // @addr $7CA8C4
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $7CA8F4
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $7CAA1C
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $7CAB0C
  end;

implementation

uses GI_Main;

{ @routine $7CA6C8 TAnimSE_Destroy }
destructor TAnimSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $7CA6C8 }

{ @routine $7CA6FC TAnimSE_AttachToSpace }
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
{ @end $7CA6FC }

{ @routine $7CA7FC TAnimSE_DetachFromSpace }
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
{ @end $7CA7FC }

{ @routine $7CA83C TAnimSE_SetPosition }
procedure TAnimSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then Animation.SetPosition(TruncatePointF(Position));
end;
{ @end $7CA83C }

{ @routine $7CA888 TAnimSE_AnimationCycleComplete }
procedure TAnimSE.AnimationCycleComplete(Sender: TObjectGI);
begin
  if not LoopAnimation then
  begin
    DetachFromSpace;
    if Assigned(FinishedCallback) then FinishedCallback(Self);
  end;
end;
{ @end $7CA888 }

{ @routine $7CA8C4 TAnimSE_HitTestCursor }
function TAnimSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $7CA8C4 }

{ @routine $7CA8F4 TAnimSE_LoadTemplate }
procedure TAnimSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  if Block.CountParams('LoopAnim') > 0 then LoopAnimation := ParseEnabledNameGI(Block.GetParam('LoopAnim'));
  if Block.CountParams('SmeImage') > 0 then ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
end;
{ @end $7CA8F4 }

{ @routine $7CAA1C TAnimSE_ApplyConfig }
procedure TAnimSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
  if Block.CountParams('LoopAnim') > 0 then LoopAnimation := ParseEnabledNameGI(Block.GetParam('LoopAnim'));
  if Block.CountParams('SmeImage') > 0 then ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
end;
{ @end $7CAA1C }

{ @routine $7CAB0C TAnimSE_QueueImageLoad }
procedure TAnimSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Image: TgaiGI;
begin
  Image := TgaiGI.Create(Owner);
  Image.SetImagePath(ImagePath);
  Image.QueueImageLoad(PendingLoads);
  Image.Free;
end;
{ @end $7CAB0C }

end.
