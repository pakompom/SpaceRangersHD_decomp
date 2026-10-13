unit SE_Anim;

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
    destructor Destroy; override; // @addr $77F5A0
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $77F5C8
    procedure DetachFromSpace; override; // @addr $77F684
    procedure SetPosition(APosition: TPointF); override; // @addr $77F6B4
    procedure AnimationCycleComplete(Sender: TObjectGI); // @addr $77F6F8
    function HitTestCursor: Boolean; override; // @addr $77F71C
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $77F738
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $77F84C
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $77F934
  end;

implementation

uses GI_Main;

{ @routine $77F5A0 TAnimSE_Destroy }
destructor TAnimSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $77F5A0 }

{ @routine $77F5C8 TAnimSE_AttachToSpace }
procedure TAnimSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  Animation := TgaiGI.Create(Space.MapPanel);
  Animation.SetImagePath(ImagePath);
  Animation.SequenceIndex := 0;
  Animation.UpdateAutoGeometry;
  Animation.World := True;
  Animation.SetDepthByName(DepthExpression);
  Animation.Pos := TruncatePointF(Position);
  Animation.Sme := ImageOrigin;
  Animation.ObjectSize := Animation.GetContentSize;
  Animation.CycleCompleteCallback := AnimationCycleComplete;
  Animation.RestartPlayback;
end;
{ @end $77F5C8 }

{ @routine $77F684 TAnimSE_DetachFromSpace }
procedure TAnimSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  Animation.IsActive := False;
  Animation.Free;
  Animation := nil;
  inherited DetachFromSpace;
end;
{ @end $77F684 }

{ @routine $77F6B4 TAnimSE_SetPosition }
procedure TAnimSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then Animation.Pos := TruncatePointF(Position);
end;
{ @end $77F6B4 }

{ @routine $77F6F8 TAnimSE_AnimationCycleComplete }
procedure TAnimSE.AnimationCycleComplete(Sender: TObjectGI);
begin
  if LoopAnimation then Exit;
  DetachFromSpace;
  if Assigned(FinishedCallback) then FinishedCallback(Self);
end;
{ @end $77F6F8 }

{ @routine $77F71C TAnimSE_HitTestCursor }
function TAnimSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $77F71C }

{ @routine $77F738 TAnimSE_LoadTemplate }
procedure TAnimSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  if Block.CountParams('LoopAnim') > 0 then LoopAnimation := ParseEnabledNameGI(Block.GetParam('LoopAnim'));
  if Block.CountParams('SmeImage') > 0 then ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
end;
{ @end $77F738 }

{ @routine $77F84C TAnimSE_ApplyConfig }
procedure TAnimSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
  if Block.CountParams('LoopAnim') > 0 then LoopAnimation := ParseEnabledNameGI(Block.GetParam('LoopAnim'));
  if Block.CountParams('SmeImage') > 0 then ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
end;
{ @end $77F84C }

{ @routine $77F934 TAnimSE_QueueImageLoad }
procedure TAnimSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Image: TgaiGI;
begin
  Image := TgaiGI.Create(Owner);
  Image.SetImagePath(ImagePath);
  Image.QueueImageLoad(PendingLoads);
  Image.Free;
end;
{ @end $77F934 }

end.
