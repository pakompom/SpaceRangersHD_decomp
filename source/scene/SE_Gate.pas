unit SE_Gate;
// Unit bracket (inferred): .text 0x004D8534..0x004D948E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses SE_Space, Types, Classes, EC_BlockPar, GI_MessageLoop, GI_RotateImageGAI, GI_Label;

type
  TGateSE = class(TObjectSE) // @size $74
  public
    State: Integer; // @offset $50
    StateStep: Integer; // @offset $54
    procedure Open; // @addr $4D8B9C Changes idle state 0 to opening state 1.
    procedure Close; // @addr $4D8BD8 Changes open state 2 to closing state 3.
    procedure SetState(Value: Integer); // @addr $4D8C14 Resets StateStep and rebuilds attached graphics.
    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $4D86B0
    Angle: Byte; // @offset $4C
    LabelText: WideString; // @offset $58
    Image: TRotateImageGaiGI; // @offset $5C
    TextLabel: TLabelGI; // @offset $60
    TextRed: Single; // @offset $64
    TextGreen: Single; // @offset $68
    TextBlue: Single; // @offset $6C
    TickCount: Integer; // @offset $70
    destructor Destroy; override; // @addr $4D8764
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $4D8798
    procedure DetachFromSpace; override; // @addr $4D8A3C
    procedure SetSize(Value: TPoint); override; // @addr $4D8AA4
    function GetAngle: Byte; override; // @addr $4D8AE0
    procedure SetAngle(Value: Byte); override; // @addr $4D8AFC
    function GetText: WideString; override; // @addr $4D8B38
    procedure SetText(const Value: WideString); override; // @addr $4D8B58
    procedure RebuildStateGraphics; // @addr $4D8C4C
    procedure AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer); // @addr $4D8ED0 Both native callers pass nil, 0; timer payload is unused.
    procedure Advance; override; // @addr $4D8FD4
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $4D900C
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $4D9028
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $4D9044
  end;
  TGateEffectSE = class(TObjectSE) // @size $5C
  public
    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $4D9058
    Angle: Byte; // @offset $4C
    StateStep: Integer; // @offset $50
    Image: TRotateImageGaiGI; // @offset $54
    TickCount: Integer; // @offset $58
    destructor Destroy; override; // @addr $4D90E4
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $4D9118
    procedure DetachFromSpace; override; // @addr $4D9298
    procedure SetSize(Value: TPoint); override; // @addr $4D92E0
    function GetAngle: Byte; override; // @addr $4D931C
    procedure SetAngle(Value: Byte); override; // @addr $4D9338
    procedure RebuildStateGraphics; // @addr $4D9374
    procedure AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer); // @addr $4D93B8 Both native callers pass nil, 0; timer payload is unused.
    procedure Advance; override; // @addr $4D940C
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $4D9444
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $4D9460
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $4D947C
  end;

implementation

uses Math, GR_Main, GR_GraphBuf, GlobalsV;

{ @routine $4D86B0 TGateSE_Create }
constructor TGateSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
  State := 0;
  TextRed := 1;
  TextGreen := 1;
  TextBlue := 1;
end;
{ @end $4D86B0 }

{ @routine $4D8764 TGateSE_Destroy }
destructor TGateSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $4D8764 }

{ @routine $4D8798 TGateSE_AttachToSpace }
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
{ @end $4D8798 }

{ @routine $4D8A3C TGateSE_DetachFromSpace }
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
{ @end $4D8A3C }

{ @routine $4D8AA4 TGateSE_SetSize }
procedure TGateSE.SetSize(Value: TPoint);
begin
  if (Size.X <> Value.X) or (Size.Y <> Value.Y) then inherited SetSize(Value);
end;
{ @end $4D8AA4 }

{ @routine $4D8AE0 TGateSE_GetAngle }
function TGateSE.GetAngle: Byte;
begin
  Result := Angle;
end;
{ @end $4D8AE0 }

{ @routine $4D8AFC TGateSE_SetAngle }
procedure TGateSE.SetAngle(Value: Byte);
begin
  Angle := Value;
  if IsAttachedToSpace then Image.SetAngle(Angle + 128);
end;
{ @end $4D8AFC }

{ @routine $4D8B38 TGateSE_GetText }
function TGateSE.GetText: WideString;
begin
  Result := LabelText;
end;
{ @end $4D8B38 }

{ @routine $4D8B58 TGateSE_SetText }
procedure TGateSE.SetText(const Value: WideString);
begin
  LabelText := Value;
  if IsAttachedToSpace then
    if TextLabel <> nil then TextLabel.SetText(LabelText);
end;
{ @end $4D8B58 }

{ @routine $4D8B9C TGateSE_Open }
procedure TGateSE.Open;
begin
  if State = 0 then
  begin
    State := 1;
    StateStep := 0;
    if IsAttachedToSpace then RebuildStateGraphics;
  end;
end;
{ @end $4D8B9C }

{ @routine $4D8BD8 TGateSE_Close }
procedure TGateSE.Close;
begin
  if State = 2 then
  begin
    State := 3;
    StateStep := 0;
    if IsAttachedToSpace then RebuildStateGraphics;
  end;
end;
{ @end $4D8BD8 }

{ @routine $4D8C14 TGateSE_SetState }
procedure TGateSE.SetState(Value: Integer);
begin
  State := Value;
  StateStep := 0;
  if IsAttachedToSpace then RebuildStateGraphics;
end;
{ @end $4D8C14 }

{ @routine $4D8C4C TGateSE_RebuildStateGraphics }
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
{ @end $4D8C4C }

{ @routine $4D8ED0 TGateSE_AdvanceAnimation }
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
{ @end $4D8ED0 }

{ @routine $4D8FD4 TGateSE_Advance }
procedure TGateSE.Advance;
begin
  inherited Advance;
  Inc(TickCount);
  if TickCount mod 5 = 0 then AdvanceAnimation(nil, 0);
end;
{ @end $4D8FD4 }

{ @routine $4D900C TGateSE_LoadTemplate }
procedure TGateSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
end;
{ @end $4D900C }

{ @routine $4D9028 TGateSE_ApplyConfig }
procedure TGateSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $4D9028 }

{ @routine $4D9044 TGateSE_QueueImageLoad }
procedure TGateSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin

end;
{ @end $4D9044 }

{ @routine $4D9058 TGateEffectSE_Create }
constructor TGateEffectSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
end;
{ @end $4D9058 }

{ @routine $4D90E4 TGateEffectSE_Destroy }
destructor TGateEffectSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $4D90E4 }

{ @routine $4D9118 TGateEffectSE_AttachToSpace }
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
{ @end $4D9118 }

{ @routine $4D9298 TGateEffectSE_DetachFromSpace }
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
{ @end $4D9298 }

{ @routine $4D92E0 TGateEffectSE_SetSize }
procedure TGateEffectSE.SetSize(Value: TPoint);
begin
  if (Size.X <> Value.X) or (Size.Y <> Value.Y) then inherited SetSize(Value);
end;
{ @end $4D92E0 }

{ @routine $4D931C TGateEffectSE_GetAngle }
function TGateEffectSE.GetAngle: Byte;
begin
  Result := Angle;
end;
{ @end $4D931C }

{ @routine $4D9338 TGateEffectSE_SetAngle }
procedure TGateEffectSE.SetAngle(Value: Byte);
begin
  Angle := Value;
  if IsAttachedToSpace then Image.SetAngle(Angle + 128);
end;
{ @end $4D9338 }

{ @routine $4D9374 TGateEffectSE_RebuildStateGraphics }
procedure TGateEffectSE.RebuildStateGraphics;
begin
  Image.AnimationIndex := 0;
  Image.UpdateAutoGeometry;
  Image.SetActive(True);
  Image.SetFrame(StateStep);
end;
{ @end $4D9374 }

{ @routine $4D93B8 TGateEffectSE_AdvanceAnimation }
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
{ @end $4D93B8 }

{ @routine $4D940C TGateEffectSE_Advance }
procedure TGateEffectSE.Advance;
begin
  inherited Advance;
  Inc(TickCount);
  if TickCount mod 5 = 0 then AdvanceAnimation(nil, 0);
end;
{ @end $4D940C }

{ @routine $4D9444 TGateEffectSE_LoadTemplate }
procedure TGateEffectSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
end;
{ @end $4D9444 }

{ @routine $4D9460 TGateEffectSE_ApplyConfig }
procedure TGateEffectSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $4D9460 }

{ @routine $4D947C TGateEffectSE_QueueImageLoad }
procedure TGateEffectSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin

end;
{ @end $4D947C }

end.
