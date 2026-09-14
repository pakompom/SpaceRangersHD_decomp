unit SE_Gate;
// Unit bracket (inferred): .text 0x004D6644..0x004D759E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses SE_Space, Types, Classes, EC_BlockPar, GI_MessageLoop, GI_RotateImageGAI, GI_Label;

type
  TGateSE = class(TObjectSE) // @size $74
  public
    State: Integer; // @offset $50
    StateStep: Integer; // @offset $54
    procedure Open; // @addr $4D6CAC Changes idle state 0 to opening state 1.
    procedure Close; // @addr $4D6CE8 Changes open state 2 to closing state 3.
    procedure SetState(Value: Integer); // @addr $4D6D24 Resets StateStep and rebuilds attached graphics.
    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $4D67C0 @ida "TGateSE *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int16 *GraphKey@<ecx>, TPoint *UnusedPosition@<^0>);"
    Angle: Byte; // @offset $4C
    LabelText: WideString; // @offset $58
    Image: TRotateImageGaiGI; // @offset $5C
    TextLabel: TLabelGI; // @offset $60
    TextRed: Single; // @offset $64
    TextGreen: Single; // @offset $68
    TextBlue: Single; // @offset $6C
    TickCount: Integer; // @offset $70
    destructor Destroy; override; // @addr $4D6874 @ida "void __usercall $name(TGateSE *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $4D68A8
    procedure DetachFromSpace; override; // @addr $4D6B4C
    procedure SetSize(Value: TPoint); override; // @addr $4D6BB4 @ida "void __usercall $name(TGateSE *Self@<eax>, TPoint *Value@<edx>);"
    function GetAngle: Byte; override; // @addr $4D6BF0
    procedure SetAngle(Value: Byte); override; // @addr $4D6C0C
    function GetText: WideString; override; // @addr $4D6C48 @ida "void __usercall $name(TGateSE *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure SetText(const Value: WideString); override; // @addr $4D6C68
    procedure RebuildStateGraphics; // @addr $4D6D5C
    procedure AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer); // @addr $4D6FE0 Both native callers pass nil, 0; timer payload is unused.
    procedure Advance; override; // @addr $4D70E4
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $4D711C
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $4D7138
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $4D7154
  end;
  TGateEffectSE = class(TObjectSE) // @size $5C
  public
    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $4D7168 @ida "TGateEffectSE *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int16 *GraphKey@<ecx>, TPoint *UnusedPosition@<^0>);"
    Angle: Byte; // @offset $4C
    StateStep: Integer; // @offset $50
    Image: TRotateImageGaiGI; // @offset $54
    TickCount: Integer; // @offset $58
    destructor Destroy; override; // @addr $4D71F4 @ida "void __usercall $name(TGateEffectSE *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $4D7228
    procedure DetachFromSpace; override; // @addr $4D73A8
    procedure SetSize(Value: TPoint); override; // @addr $4D73F0 @ida "void __usercall $name(TGateEffectSE *Self@<eax>, TPoint *Value@<edx>);"
    function GetAngle: Byte; override; // @addr $4D742C
    procedure SetAngle(Value: Byte); override; // @addr $4D7448
    procedure RebuildStateGraphics; // @addr $4D7484
    procedure AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer); // @addr $4D74C8 Both native callers pass nil, 0; timer payload is unused.
    procedure Advance; override; // @addr $4D751C
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $4D7554
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $4D7570
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $4D758C
  end;

implementation

uses Math, GR_Main, GR_GraphBuf, GlobalsV;

{ @routine $4D67C0 TGateSE_Create }
constructor TGateSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
  State := 0;
  TextRed := 1;
  TextGreen := 1;
  TextBlue := 1;
end;
{ @end $4D67C0 }

{ @routine $4D6874 TGateSE_Destroy }
destructor TGateSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $4D6874 }

{ @routine $4D68A8 TGateSE_AttachToSpace }
procedure TGateSE.AttachToSpace(ASpace: TSpaceSE);
var
  ImageSize: Integer;
begin
  if IsAttachedToSpace then Exit;
  ConfigureLoopSound('Gate');
  ConfigureRandomSound('Gate');
  inherited AttachToSpace(ASpace);
  TickCount := 0;
  Image := TRotateImageGaiGI.Create(Space.MapPanel);
  Image.SetPositionModeW(True);
  Image.SetDepthByName(DepthExpression);
  Image.SetPosition(Classes.Point(Round(Position.X), Round(Position.Y)));
  Image.SetAngle(Angle + 128);
  Image.SetAlpha(255);
  ImageSize := GiScalePixels(Min(200, Size.X));
  Image.SetImage('Bm.Gate2.00?NoConvertPF', Classes.Point(ImageSize, ImageSize), Classes.Point(ImageSize div 2, ImageSize div 2));
  TextLabel := TLabelGI.Create(Space.MapPanel);
  TextLabel.SetActive(False);
  TextLabel.SetFontName(NormalFontName);
  TextLabel.SetPositionModeW(True);
  TextLabel.SetDepthByName(DepthExpression);
  TextLabel.SetSize(Classes.Point(150, 20));
  TextLabel.SetPosition(Classes.Point(Round(Position.X - TextLabel.ClientSize.X / 2), Round(Position.Y + 50 + ImageSize div 2 - 40)));
  TextLabel.SetText(LabelText);
  TextLabel.SetWordWrapEnabled(False);
  TextLabel.SetTextAlignX(taxCenter);
  TextLabel.SetTextAlignY(tayAuto);
  RebuildStateGraphics;
end;
{ @end $4D68A8 }

{ @routine $4D6B4C TGateSE_DetachFromSpace }
procedure TGateSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    Image.SetActive(False);
    Image.Free;
    Image := nil;
    if TextLabel <> nil then
    begin
      TextLabel.SetActive(False);
      TextLabel.Free;
      TextLabel := nil;
    end;
    inherited DetachFromSpace;
  end;
end;
{ @end $4D6B4C }

{ @routine $4D6BB4 TGateSE_SetSize }
procedure TGateSE.SetSize(Value: TPoint);
begin
  if (Size.X <> Value.X) or (Size.Y <> Value.Y) then inherited SetSize(Value);
end;
{ @end $4D6BB4 }

{ @routine $4D6BF0 TGateSE_GetAngle }
function TGateSE.GetAngle: Byte;
begin
  Result := Angle;
end;
{ @end $4D6BF0 }

{ @routine $4D6C0C TGateSE_SetAngle }
procedure TGateSE.SetAngle(Value: Byte);
begin
  Angle := Value;
  if IsAttachedToSpace then Image.SetAngle(Angle + 128);
end;
{ @end $4D6C0C }

{ @routine $4D6C48 TGateSE_GetText }
function TGateSE.GetText: WideString;
begin
  Result := LabelText;
end;
{ @end $4D6C48 }

{ @routine $4D6C68 TGateSE_SetText }
procedure TGateSE.SetText(const Value: WideString);
begin
  LabelText := Value;
  if IsAttachedToSpace then
    if TextLabel <> nil then TextLabel.SetText(LabelText);
end;
{ @end $4D6C68 }

{ @routine $4D6CAC TGateSE_Open }
procedure TGateSE.Open;
begin
  if State = 0 then
  begin
    State := 1;
    StateStep := 0;
    if IsAttachedToSpace then RebuildStateGraphics;
  end;
end;
{ @end $4D6CAC }

{ @routine $4D6CE8 TGateSE_Close }
procedure TGateSE.Close;
begin
  if State = 2 then
  begin
    State := 3;
    StateStep := 0;
    if IsAttachedToSpace then RebuildStateGraphics;
  end;
end;
{ @end $4D6CE8 }

{ @routine $4D6D24 TGateSE_SetState }
procedure TGateSE.SetState(Value: Integer);
begin
  State := Value;
  StateStep := 0;
  if IsAttachedToSpace then RebuildStateGraphics;
end;
{ @end $4D6D24 }

{ @routine $4D6D5C TGateSE_RebuildStateGraphics }
procedure TGateSE.RebuildStateGraphics;
begin
  if State = 0 then
  begin
    Image.SetActive(False);
    if TextLabel <> nil then TextLabel.SetActive(False);
  end
  else if State = 1 then
  begin
    Image.AnimationIndex := 0;
    Image.UpdateAutoGeometry;
    if (StateStep >= 0) and (Image.FrameCount > StateStep) then
    begin
      Image.SetActive(True);
      Image.SetFrame(StateStep);
      if TextLabel <> nil then TextLabel.SetActive(False);
    end
    else
    begin
      Image.SetActive(False);
      if TextLabel <> nil then TextLabel.SetActive(False);
    end;
  end
  else if State = 2 then
  begin
    Image.AnimationIndex := 1;
    Image.UpdateAutoGeometry;
    if (StateStep >= 0) and (Image.FrameCount > StateStep) then
    begin
      Image.SetActive(True);
      Image.SetFrame(StateStep);
      if TextLabel <> nil then
      begin
        TextLabel.SetTextColor(CurrentPixelFormat.PackNormalizedRgb(TextRed, TextGreen, TextBlue));
        TextLabel.SetActive(True);
      end;
    end
    else
    begin
      Image.SetActive(False);
      if TextLabel <> nil then TextLabel.SetActive(False);
    end;
  end
  else if State = 3 then
  begin
    Image.AnimationIndex := 2;
    Image.UpdateAutoGeometry;
    if (StateStep >= 0) and (Image.FrameCount > StateStep) then
    begin
      Image.SetActive(True);
      Image.SetFrame(StateStep);
      if TextLabel <> nil then TextLabel.SetActive(False);
    end
    else
    begin
      Image.SetActive(False);
      if TextLabel <> nil then TextLabel.SetActive(False);
    end;
  end;
end;
{ @end $4D6D5C }

{ @routine $4D6FE0 TGateSE_AdvanceAnimation }
procedure TGateSE.AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer);
begin
  Inc(StateStep);
  if State = 0 then Exit
  else if State = 1 then
  begin
    if Image.FrameCount <= StateStep then
    begin
      State := 2;
      StateStep := 0;
      RebuildStateGraphics;
    end
    else Image.SetFrame(StateStep);
  end
  else if State = 2 then
  begin
    if Image.FrameCount <= StateStep then
    begin
      StateStep := 0;
      RebuildStateGraphics;
    end
    else Image.SetFrame(StateStep);
  end
  else if State = 3 then
  begin
    if Image.FrameCount <= StateStep then
    begin
      State := 0;
      StateStep := 0;
      RebuildStateGraphics;
    end
    else Image.SetFrame(StateStep);
  end;
end;
{ @end $4D6FE0 }

{ @routine $4D70E4 TGateSE_Advance }
procedure TGateSE.Advance;
begin
  inherited Advance;
  Inc(TickCount);
  if TickCount mod 5 = 0 then AdvanceAnimation(nil, 0);
end;
{ @end $4D70E4 }

{ @routine $4D711C TGateSE_LoadTemplate }
procedure TGateSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
end;
{ @end $4D711C }

{ @routine $4D7138 TGateSE_ApplyConfig }
procedure TGateSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $4D7138 }

{ @routine $4D7154 TGateSE_QueueImageLoad }
procedure TGateSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin

end;
{ @end $4D7154 }

{ @routine $4D7168 TGateEffectSE_Create }
constructor TGateEffectSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
end;
{ @end $4D7168 }

{ @routine $4D71F4 TGateEffectSE_Destroy }
destructor TGateEffectSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $4D71F4 }

{ @routine $4D7228 TGateEffectSE_AttachToSpace }
procedure TGateEffectSE.AttachToSpace(ASpace: TSpaceSE);
var
  ImageSize: Integer;
begin
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  TickCount := 0;
  Image := TRotateImageGaiGI.Create(Space.MapPanel);
  Image.SetPositionModeW(True);
  Image.SetDepthByName(DepthExpression);
  Image.SetPosition(Classes.Point(Round(Position.X), Round(Position.Y)));
  Image.SetAngle(Angle + 128);
  Image.SetAlpha(255);
  Image.SetActive(True);
  ImageSize := GiScalePixels(Min(200, Size.X));
  Image.SetImage('Bm.Gate2.GateEffect?NoConvertPF', Classes.Point(ImageSize, ImageSize), Classes.Point(ImageSize div 2, ImageSize div 2));
  RebuildStateGraphics;
end;
{ @end $4D7228 }

{ @routine $4D73A8 TGateEffectSE_DetachFromSpace }
procedure TGateEffectSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    Image.SetActive(False);
    Image.Free;
    Image := nil;
    StateStep := 0;
    inherited DetachFromSpace;
  end;
end;
{ @end $4D73A8 }

{ @routine $4D73F0 TGateEffectSE_SetSize }
procedure TGateEffectSE.SetSize(Value: TPoint);
begin
  if (Size.X <> Value.X) or (Size.Y <> Value.Y) then inherited SetSize(Value);
end;
{ @end $4D73F0 }

{ @routine $4D742C TGateEffectSE_GetAngle }
function TGateEffectSE.GetAngle: Byte;
begin
  Result := Angle;
end;
{ @end $4D742C }

{ @routine $4D7448 TGateEffectSE_SetAngle }
procedure TGateEffectSE.SetAngle(Value: Byte);
begin
  Angle := Value;
  if IsAttachedToSpace then Image.SetAngle(Angle + 128);
end;
{ @end $4D7448 }

{ @routine $4D7484 TGateEffectSE_RebuildStateGraphics }
procedure TGateEffectSE.RebuildStateGraphics;
begin
  Image.AnimationIndex := 0;
  Image.UpdateAutoGeometry;
  Image.SetActive(True);
  Image.SetFrame(StateStep);
end;
{ @end $4D7484 }

{ @routine $4D74C8 TGateEffectSE_AdvanceAnimation }
procedure TGateEffectSE.AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer);
begin
  if IsAttachedToSpace then
  begin
    Inc(StateStep);
    if Image.FrameCount <= StateStep then
    begin
      StateStep := 0;
      DetachFromSpace;
    end
    else RebuildStateGraphics;
  end;
end;
{ @end $4D74C8 }

{ @routine $4D751C TGateEffectSE_Advance }
procedure TGateEffectSE.Advance;
begin
  inherited Advance;
  Inc(TickCount);
  if TickCount mod 5 = 0 then AdvanceAnimation(nil, 0);
end;
{ @end $4D751C }

{ @routine $4D7554 TGateEffectSE_LoadTemplate }
procedure TGateEffectSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
end;
{ @end $4D7554 }

{ @routine $4D7570 TGateEffectSE_ApplyConfig }
procedure TGateEffectSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $4D7570 }

{ @routine $4D758C TGateEffectSE_QueueImageLoad }
procedure TGateEffectSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin

end;
{ @end $4D758C }

end.
