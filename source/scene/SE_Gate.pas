unit SE_Gate;

interface

uses SE_Space, Types, Classes, EC_BlockPar, GI_MessageLoop, GI_RotateImageGAI, GI_Label;

type
  TGateState = (gate_closed, gate_opening, gate_open, gate_closing); // @size $04

  TGateSE = class(TObjectSE) // @size $74 @methodorder source
  public
    FAngle: Byte; // @offset $4C
    State: TGateState; // @offset $50
    StateStep: Integer; // @offset $54
    LabelText: WideString; // @offset $58
    Image: TRotateImageGaiGI; // @offset $5C
    TextLabel: TLabelGI; // @offset $60
    TextRed: Single; // @offset $64
    TextGreen: Single; // @offset $68
    TextBlue: Single; // @offset $6C
    TickCount: Integer; // @offset $70

    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $4D855C
    destructor Destroy; override; // @addr $4D8600
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $4D8628
    procedure DetachFromSpace; override; // @addr $4D8848
    procedure SetSize(Value: TPoint); override; // @addr $4D8894
    procedure Advance; override; // @addr $4D8C04
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $4D8C30
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $4D8C38
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $4D8C40
    procedure Open; // @addr $4D8930 Starts opening a closed gate.
    procedure Close; // @addr $4D895C Starts closing an open gate.
    procedure SetState(Value: TGateState); // @addr $4D8988 Resets StateStep and rebuilds attached graphics.
    procedure RebuildStateGraphics; // @addr $4D89A8
    procedure AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer); // @addr $4D8B68 Both native callers pass nil, 0; timer payload is unused.
    function GetAngle: Byte; override; // @addr $4D88C0
    procedure SetAngle(Value: Byte); override; // @addr $4D88C8
    function GetText: WideString; override; // @addr $4D88EC
    procedure SetText(const Value: WideString); override; // @addr $4D8900
  end;
  TGateEffectSE = class(TObjectSE) // @size $5C
  public
    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $4D8C44
    FAngle: Byte; // @offset $4C
    StateStep: Integer; // @offset $50
    Image: TRotateImageGaiGI; // @offset $54
    TickCount: Integer; // @offset $58
    destructor Destroy; override; // @addr $4D8CCC
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $4D8CF4
    procedure DetachFromSpace; override; // @addr $4D8E2C
    procedure SetSize(Value: TPoint); override; // @addr $4D8E60
    function GetAngle: Byte; override; // @addr $4D8E8C
    procedure SetAngle(Value: Byte); override; // @addr $4D8E94
    procedure RebuildStateGraphics; // @addr $4D8EB8
    procedure AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer); // @addr $4D8EEC Both native callers pass nil, 0; timer payload is unused.
    procedure Advance; override; // @addr $4D8F24
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $4D8F50
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $4D8F58
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $4D8F60
  end;

implementation

uses Math, GR_Main, GR_GraphBuf, GlobalsV;

{ @routine $4D855C TGateSE_Create }
constructor TGateSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
  State := gate_closed;
  TextRed := 1;
  TextGreen := 1;
  TextBlue := 1;
end;
{ @end $4D855C }

{ @routine $4D8600 TGateSE_Destroy }
destructor TGateSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $4D8600 }

{ @routine $4D8628 TGateSE_AttachToSpace }
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
  Image.World := True;
  Image.SetDepthByName(DepthExpression);
  Image.Pos := Classes.Point(Round(Position.X), Round(Position.Y));
  Image.SetAngle(FAngle + 128);
  Image.SetAlpha(255);
  ImageSize := GiScalePixels(Min(200, Size.X));
  Image.SetImage('Bm.Gate2.00?NoConvertPF', Classes.Point(ImageSize, ImageSize), Classes.Point(ImageSize div 2, ImageSize div 2));
  TextLabel := TLabelGI.Create(Space.MapPanel);
  TextLabel.IsActive := False;
  TextLabel.SetFontName(NormalFontName);
  TextLabel.World := True;
  TextLabel.SetDepthByName(DepthExpression);
  TextLabel.ObjectSize := Classes.Point(150, 20);
  TextLabel.Pos := Classes.Point(Round(Position.X - TextLabel.ClientSize.X / 2), Round(Position.Y + 50 + ImageSize div 2 - 40));
  TextLabel.Text := LabelText;
  TextLabel.SetWordWrapEnabled(False);
  TextLabel.SetTextAlignX(text_x_center);
  TextLabel.SetTextAlignY(text_y_fit_height);
  RebuildStateGraphics;
end;
{ @end $4D8628 }

{ @routine $4D8848 TGateSE_DetachFromSpace }
procedure TGateSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    Image.IsActive := False;
    Image.Free;
    Image := nil;
    if TextLabel <> nil then
    begin
      TextLabel.IsActive := False;
      TextLabel.Free;
      TextLabel := nil;
    end;
    inherited DetachFromSpace;
  end;
end;
{ @end $4D8848 }

{ @routine $4D8894 TGateSE_SetSize }
procedure TGateSE.SetSize(Value: TPoint);
begin
  if (Size.X <> Value.X) or (Size.Y <> Value.Y) then inherited SetSize(Value);
end;
{ @end $4D8894 }

{ @routine $4D88C0 TGateSE_GetAngle }
function TGateSE.GetAngle: Byte;
begin
  Result := FAngle;
end;
{ @end $4D88C0 }

{ @routine $4D88C8 TGateSE_SetAngle }
procedure TGateSE.SetAngle(Value: Byte);
begin
  FAngle := Value;
  if IsAttachedToSpace then Image.SetAngle(FAngle + 128);
end;
{ @end $4D88C8 }

{ @routine $4D88EC TGateSE_GetText }
function TGateSE.GetText: WideString;
begin
  Result := LabelText;
end;
{ @end $4D88EC }

{ @routine $4D8900 TGateSE_SetText }
procedure TGateSE.SetText(const Value: WideString);
begin
  LabelText := Value;
  if IsAttachedToSpace then
    if TextLabel <> nil then TextLabel.Text := LabelText;
end;
{ @end $4D8900 }

{ @routine $4D8930 TGateSE_Open }
procedure TGateSE.Open;
begin
  if State = gate_closed then
  begin
    State := gate_opening;
    StateStep := 0;
    if IsAttachedToSpace then RebuildStateGraphics;
  end;
end;
{ @end $4D8930 }

{ @routine $4D895C TGateSE_Close }
procedure TGateSE.Close;
begin
  if State = gate_open then
  begin
    State := gate_closing;
    StateStep := 0;
    if IsAttachedToSpace then RebuildStateGraphics;
  end;
end;
{ @end $4D895C }

{ @routine $4D8988 TGateSE_SetState }
procedure TGateSE.SetState(Value: TGateState);
begin
  State := Value;
  StateStep := 0;
  if IsAttachedToSpace then RebuildStateGraphics;
end;
{ @end $4D8988 }

{ @routine $4D89A8 TGateSE_RebuildStateGraphics }
procedure TGateSE.RebuildStateGraphics;
begin
  if State = gate_closed then
  begin
    Image.IsActive := False;
    if TextLabel <> nil then
      with TextLabel do IsActive := False;
  end
  else if State = gate_opening then
  begin
    Image.AnimationIndex := 0;
    Image.UpdateAutoGeometry;
    if (StateStep >= 0) and (Image.FrameCount > StateStep) then
    begin
      Image.IsActive := True;
      Image.SetFrame(StateStep);
      if TextLabel <> nil then
        with TextLabel do IsActive := False;
    end
    else
    begin
      Image.IsActive := False;
      if TextLabel <> nil then
        with TextLabel do IsActive := False;
    end;
  end
  else if State = gate_open then
  begin
    Image.AnimationIndex := 1;
    Image.UpdateAutoGeometry;
    if (StateStep >= 0) and (Image.FrameCount > StateStep) then
    begin
      Image.IsActive := True;
      Image.SetFrame(StateStep);
      repeat
        if TextLabel = nil then Break;
        TextLabel.SetTextColor(CurrentPixelFormat.PackNormalizedRgb(TextRed, TextGreen, TextBlue));
        TextLabel.IsActive := True;
      until True;
    end
    else
    begin
      Image.IsActive := False;
      if TextLabel <> nil then
        with TextLabel do IsActive := False;
    end;
  end
  else if State = gate_closing then
  begin
    Image.AnimationIndex := 2;
    Image.UpdateAutoGeometry;
    if (StateStep >= 0) and (Image.FrameCount > StateStep) then
    begin
      Image.IsActive := True;
      Image.SetFrame(StateStep);
      if TextLabel <> nil then
        with TextLabel do IsActive := False;
    end
    else
    begin
      Image.IsActive := False;
      if TextLabel <> nil then
        with TextLabel do IsActive := False;
    end;
  end;
end;
{ @end $4D89A8 }

{ @routine $4D8B68 TGateSE_AdvanceAnimation }
procedure TGateSE.AdvanceAnimation(UnusedTimer: Pointer; UnusedData: Integer);
begin
  Inc(StateStep);
  if State = gate_closed then Exit
  else if State = gate_opening then
  begin
    if Image.FrameCount <= StateStep then
    begin
      State := gate_open;
      StateStep := 0;
      RebuildStateGraphics;
    end
    else Image.SetFrame(StateStep);
  end
  else if State = gate_open then
  begin
    if Image.FrameCount <= StateStep then
    begin
      StateStep := 0;
      RebuildStateGraphics;
    end
    else Image.SetFrame(StateStep);
  end
  else if State = gate_closing then
  begin
    if Image.FrameCount <= StateStep then
    begin
      State := gate_closed;
      StateStep := 0;
      RebuildStateGraphics;
    end
    else Image.SetFrame(StateStep);
  end;
end;
{ @end $4D8B68 }

{ @routine $4D8C04 TGateSE_Advance }
procedure TGateSE.Advance;
begin
  inherited Advance;
  Inc(TickCount);
  if TickCount mod 5 = 0 then AdvanceAnimation(nil, 0);
end;
{ @end $4D8C04 }

{ @routine $4D8C30 TGateSE_LoadTemplate }
procedure TGateSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
end;
{ @end $4D8C30 }

{ @routine $4D8C38 TGateSE_ApplyConfig }
procedure TGateSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $4D8C38 }

{ @routine $4D8C40 TGateSE_QueueImageLoad }
procedure TGateSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin

end;
{ @end $4D8C40 }

{ @routine $4D8C44 TGateEffectSE_Create }
constructor TGateEffectSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
end;
{ @end $4D8C44 }

{ @routine $4D8CCC TGateEffectSE_Destroy }
destructor TGateEffectSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $4D8CCC }

{ @routine $4D8CF4 TGateEffectSE_AttachToSpace }
procedure TGateEffectSE.AttachToSpace(ASpace: TSpaceSE);
var
  ImageSize: Integer;
begin
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  TickCount := 0;
  Image := TRotateImageGaiGI.Create(Space.MapPanel);
  Image.World := True;
  Image.SetDepthByName(DepthExpression);
  Image.Pos := Classes.Point(Round(Position.X), Round(Position.Y));
  Image.SetAngle(FAngle + 128);
  Image.SetAlpha(255);
  Image.IsActive := True;
  ImageSize := GiScalePixels(Min(200, Size.X));
  Image.SetImage('Bm.Gate2.GateEffect?NoConvertPF', Classes.Point(ImageSize, ImageSize), Classes.Point(ImageSize div 2, ImageSize div 2));
  RebuildStateGraphics;
end;
{ @end $4D8CF4 }

{ @routine $4D8E2C TGateEffectSE_DetachFromSpace }
procedure TGateEffectSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    Image.IsActive := False;
    Image.Free;
    Image := nil;
    StateStep := 0;
    inherited DetachFromSpace;
  end;
end;
{ @end $4D8E2C }

{ @routine $4D8E60 TGateEffectSE_SetSize }
procedure TGateEffectSE.SetSize(Value: TPoint);
begin
  if (Size.X <> Value.X) or (Size.Y <> Value.Y) then inherited SetSize(Value);
end;
{ @end $4D8E60 }

{ @routine $4D8E8C TGateEffectSE_GetAngle }
function TGateEffectSE.GetAngle: Byte;
begin
  Result := FAngle;
end;
{ @end $4D8E8C }

{ @routine $4D8E94 TGateEffectSE_SetAngle }
procedure TGateEffectSE.SetAngle(Value: Byte);
begin
  FAngle := Value;
  if IsAttachedToSpace then Image.SetAngle(FAngle + 128);
end;
{ @end $4D8E94 }

{ @routine $4D8EB8 TGateEffectSE_RebuildStateGraphics }
procedure TGateEffectSE.RebuildStateGraphics;
begin
  Image.AnimationIndex := 0;
  Image.UpdateAutoGeometry;
  Image.IsActive := True;
  Image.SetFrame(StateStep);
end;
{ @end $4D8EB8 }

{ @routine $4D8EEC TGateEffectSE_AdvanceAnimation }
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
{ @end $4D8EEC }

{ @routine $4D8F24 TGateEffectSE_Advance }
procedure TGateEffectSE.Advance;
begin
  inherited Advance;
  Inc(TickCount);
  if TickCount mod 5 = 0 then AdvanceAnimation(nil, 0);
end;
{ @end $4D8F24 }

{ @routine $4D8F50 TGateEffectSE_LoadTemplate }
procedure TGateEffectSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
end;
{ @end $4D8F50 }

{ @routine $4D8F58 TGateEffectSE_ApplyConfig }
procedure TGateEffectSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $4D8F58 }

{ @routine $4D8F60 TGateEffectSE_QueueImageLoad }
procedure TGateEffectSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin

end;
{ @end $4D8F60 }

end.
